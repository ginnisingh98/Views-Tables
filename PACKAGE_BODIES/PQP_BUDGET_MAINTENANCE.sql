--------------------------------------------------------
--  DDL for Package Body PQP_BUDGET_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_BUDGET_MAINTENANCE" AS
/* $Header: pqabvmaintain.pkb 120.8.12010000.5 2009/02/17 13:08:05 dchindar ship $ */
   g_package_name                VARCHAR2(31)    := 'pqp_budget_maintenance.';
   g_debug                       BOOLEAN          := hr_utility.debug_enabled;
   hr_application_error          EXCEPTION;
   PRAGMA EXCEPTION_INIT (hr_application_error, -20001);
-- output record structure
   TYPE g_output_file_rec_type IS RECORD(
      assignment_id       per_all_assignments_f.assignment_id%TYPE
     ,status              VARCHAR2(80)
     ,uom                 VARCHAR2(80)
     ,employee_number     per_all_people_f.employee_number%TYPE
     ,assignment_number   per_all_assignments_f.assignment_number%TYPE
     ,effective_date      per_all_assignments_f.effective_start_date%TYPE
     ,old_budget_value    per_assignment_budget_values_f.VALUE%TYPE
     ,change_type         VARCHAR2(80)
     ,new_budget_value    per_assignment_budget_values_f.VALUE%TYPE
     ,MESSAGE             fnd_new_messages.MESSAGE_TEXT%TYPE
   );

   TYPE t_output_file_record_type IS TABLE OF g_output_file_rec_type
      INDEX BY BINARY_INTEGER;

   g_output_file_records         t_output_file_record_type; -- do not include in clear cache
   g_column_separator            VARCHAR2(10)                         := ' , ';
-- global Variables for concurrent program
   g_person_id                   NUMBER;
   g_formula_id                  NUMBER;
   g_assignment_set_id           NUMBER;
   g_parameter_list              pay_payroll_actions.legislative_parameters%TYPE;
   g_uom                         VARCHAR2(30);
   g_action                      VARCHAR2(30);
   g_effective_date              DATE;
   g_payroll_id                  NUMBER;
   g_contract                    pqp_assignment_attributes_f.contract_type%TYPE;
-- global variables for storing configuration values
   g_configuration_data          csr_get_configuration_data%ROWTYPE;
   g_additional_information      csr_get_configuration_data%ROWTYPE;
-- global variables for legislative_data
   g_business_group_id           per_business_groups.business_group_id%TYPE;
   g_legislation_code            per_business_groups.legislation_code%TYPE;
-- cache for configuration value ids
   g_defn_configuration_id       pqp_configuration_values.configuration_value_id%TYPE;
   g_additional_config_id        pqp_configuration_values.configuration_value_id%TYPE;
   g_not_cached_constants        BOOLEAN;
   g_is_concurrent_program_run   BOOLEAN                              := FALSE;
-- global for printing header of the output file
   g_is_header_printed           BOOLEAN                              :=FALSE;

   CURSOR get_business_group_id(p_assignment_id NUMBER)
   IS
      SELECT business_group_id
        FROM per_all_assignments_f
       WHERE assignment_id = p_assignment_id;

--
--
   CURSOR get_legislation_code(p_business_group_id NUMBER)
   IS
      SELECT legislation_code
        FROM per_business_groups
       WHERE business_group_id = p_business_group_id;

   PROCEDURE debug(
      p_trace_message    IN   VARCHAR2
     ,p_trace_location   IN   NUMBER DEFAULT NULL
   )
   IS
   BEGIN
--
      IF NOT g_is_concurrent_program_run
      THEN
         pqp_utilities.debug(p_trace_message, p_trace_location);
      ELSE
         IF p_trace_location IS NULL
         THEN
            fnd_file.put_line(fnd_file.LOG, p_trace_message);
         ELSE
            fnd_file.put_line(fnd_file.LOG
                             ,    RPAD(p_trace_message, 80, ' ')
                               || TO_CHAR(p_trace_location)
                             );
         END IF;
      END IF;
   END DEBUG;

   PROCEDURE debug_enter(
      p_proc_name   IN   VARCHAR2
     ,p_trace_on    IN   VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
      IF NOT g_is_concurrent_program_run
      THEN
         pqp_utilities.debug_enter(p_proc_name, p_trace_on);
      ELSE
         fnd_file.put_line(fnd_file.LOG, RPAD(p_proc_name, 80, ' ') || '+0');
      END IF;
   END debug_enter;

   PROCEDURE debug_exit(
      p_proc_name   IN   VARCHAR2
     ,p_trace_off   IN   VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
      IF NOT g_is_concurrent_program_run
      THEN
         pqp_utilities.debug_exit(p_proc_name, p_trace_off);
      ELSE
         fnd_file.put_line(fnd_file.LOG, RPAD(p_proc_name, 80, ' ') || '-0');
      END IF;
   END debug_exit;

   PROCEDURE debug_others(
      p_proc_name   IN   VARCHAR2
     ,p_proc_step   IN   NUMBER DEFAULT NULL
   )
   IS
   BEGIN
      pqp_utilities.debug_others(p_proc_name, p_proc_step);
   END debug_others;

   PROCEDURE clear_cache
   IS
   BEGIN
--
-- cache for get_installation_status
-- g_application_id            := NULL;
-- g_status                    := NULL;
--
-- cache for concurrent process
      g_parameter_list            := NULL;
      g_person_id                 := NULL;
      g_formula_id                := NULL;
      g_assignment_set_id         := NULL;
      g_uom                       := NULL;
      g_action                    := NULL;
      g_effective_date            := NULL;
      g_payroll_id                := NULL;
      g_contract                  := NULL;
      g_tab_asg_set_amnds.DELETE;
-- cache for legislative data
      g_business_group_id         := NULL;
      g_legislation_code          := NULL;
--cache for configuration id
      g_defn_configuration_id     := NULL;
      g_additional_config_id      := NULL;
-- cache for configuration value
      g_configuration_data        := NULL;
      g_additional_information    := NULL;
-- cache for load_cached_constants
      g_not_cached_constants      := TRUE;
   END clear_cache;

----------------------------------------------------------------------
--------PROCEDURE FOR LOAD CACHE-----------------------------------
---------------------------------------------------------------------
   PROCEDURE load_cache(
      p_uom                    IN              VARCHAR2
     ,p_business_group_id      IN              NUMBER
     ,p_legislation_code       IN              VARCHAR2
     ,p_information_category   IN              VARCHAR2
     ,p_configuration_data     IN OUT NOCOPY   csr_get_configuration_data%ROWTYPE
   )
   IS
      l_log_string   VARCHAR2(4000);
      l_proc_step    NUMBER(20, 10) := 0;
      l_proc_name    VARCHAR2(61)   := g_package_name || 'load_cache';
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_uom: ' || p_uom);
         debug('p_business_group_id: ' || p_business_group_id);
         debug('p_legislation_code: ' || p_legislation_code);
         debug('p_information_category: ' || p_information_category);
      END IF;

-- fetch the required configuration data for PQP_ABVM_DEFINITION

      OPEN csr_get_configuration_data(p_uom                       => p_uom
                                     ,p_business_group_id         => p_business_group_id
                                     ,p_legislation_code          => p_legislation_code
                                     ,p_information_category      => p_information_category
                                     );
      FETCH csr_get_configuration_data INTO p_configuration_data;
      CLOSE csr_get_configuration_data;

      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END load_cache;

/* ----------------------------------------------------------- */
/* --------------------- Load Cache--------------------------- */
/* ----------------------------------------------------------- */
   PROCEDURE load_cache(p_payroll_action_id IN NUMBER)
   IS
   BEGIN
      -- initialise globals to null before reloading
      g_parameter_list          := NULL;
      g_uom                     := NULL;
      g_action                  := NULL;
      g_effective_date          := NULL;
      g_business_group_id       := NULL;
      g_payroll_id              := NULL;
      g_contract                := NULL;
      GET_PARAMETER_LIST(p_pay_action_id       => p_payroll_action_id -- IN
                        ,p_parameter_list      => g_parameter_list -- OUT
                        );
      g_uom                     :=
                                  get_parameter_value('UOM', g_parameter_list);
      g_action                  :=
                               get_parameter_value('ACTION', g_parameter_list);
      g_effective_date          :=
         fnd_date.canonical_to_date(get_parameter_value('EFFECTIVE DATE'
                                                       ,g_parameter_list
                                                       )
                                   );
      g_business_group_id       := fnd_profile.VALUE('PER_BUSINESS_GROUP_ID');
      g_effective_date          :=
         fnd_date.canonical_to_date(get_parameter_value('EFFECTIVE DATE'
                                                       ,g_parameter_list
                                                       )
                                   );
      g_payroll_id              :=
                              get_parameter_value('PAYROLL', g_parameter_list);
      g_contract                :=
                             get_parameter_value('CONTRACT', g_parameter_list);
      g_not_cached_constants    := FALSE;
   END load_cache;

------------------------------------------------------------
--------CONVERT_RECORD_TO_OUTPUTSTRING----------------------
------------------------------------------------------------
   FUNCTION convert_record_to_outputstring(
      p_output_file_record   g_output_file_rec_type
   )
      RETURN VARCHAR2
   IS
      l_proc_step      NUMBER(20, 10):= 0;
      l_proc_name      VARCHAR2(61)
                        := g_package_name || 'convert_record_to_outputstring';
      l_outputstring   VARCHAR2(4000);
   BEGIN -- convert_record_to_outputstring
      IF g_debug
      THEN
         debug_enter(l_proc_name);
      END IF;

      l_outputstring    :=
             RPAD(NVL(p_output_file_record.status, ' '), 30, ' ')
          || g_column_separator
          || RPAD(NVL(p_output_file_record.uom, ' '), 30, ' ')
          || g_column_separator
          || RPAD(NVL(p_output_file_record.employee_number, ' '), 20, ' ')
          || g_column_separator
          || RPAD(NVL(p_output_file_record.assignment_number
                     , 'AsgId:' || p_output_file_record.assignment_id
                     )
                 ,30
                 ,' '
                 )
          || g_column_separator
          || RPAD(NVL(fnd_date.date_to_displaydate(p_output_file_record.effective_date
                                                  )
                     ,' '
                     )
                 ,15
                 ,' '
                 )
          || g_column_separator
          || RPAD(NVL(TO_CHAR(p_output_file_record.old_budget_value), ' ')
                 ,30
                 ,' '
                 )
          || g_column_separator
          || RPAD(NVL(p_output_file_record.change_type, ' '), 15, ' ')
          || g_column_separator
          || RPAD(NVL(TO_CHAR(p_output_file_record.new_budget_value), ' ')
                 ,30
                 ,' '
                 )
          || g_column_separator
          || RPAD(p_output_file_record.MESSAGE, 400, ' ');

      IF g_debug
      THEN
         debug_exit(l_proc_name);
         debug('l_outputstring_1_200:' || SUBSTR(l_outputstring, 1, 200));
         debug('l_outputstring_201_400:' || SUBSTR(l_outputstring, 201, 200));
         debug('l_outputstring_401_600:' || SUBSTR(l_outputstring, 401, 600));
         debug('l_outputstring_601_800:' || SUBSTR(l_outputstring, 601, 800));
      END IF;

      RETURN l_outputstring;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END convert_record_to_outputstring;

---------------------------------------------------------------------
----------------WRITE_OUTPUT_FILE_RECORDS----------------------------
---------------------------------------------------------------------
   PROCEDURE write_output_file_records
   IS
      l_proc_step   NUMBER(20, 10):= 0;
      l_proc_name   VARCHAR2(61)
                             := g_package_name || 'write_output_file_records';
      i             BINARY_INTEGER;
   BEGIN -- write_output_file_records
      IF g_debug
      THEN
         debug_enter(l_proc_name);
      END IF;
      -- prepare output file header
      --
      IF NOT g_is_header_printed THEN
      fnd_file.put_line(fnd_file.output
                       ,    RPAD('Status', 30, ' ')
                         || g_column_separator
                         || RPAD('UOM', 30, ' ')
                         || g_column_separator
                         || RPAD('Employee Number', 20, ' ')
                         || g_column_separator
                         || RPAD('Assignment_Number', 30, ' ')
                         || g_column_separator
                         || RPAD('Effective Date', 15, ' ')
                         || g_column_separator
                         || RPAD('Budget Value - Before Change', 30, ' ')
                         || g_column_separator
                         || RPAD('Change Type', 15, ' ')
                         || g_column_separator
                         || RPAD('Budget Value - After Change', 30, ' ')
                         || g_column_separator
                         || RPAD('Message', 400, ' ')
                       );
      fnd_file.put_line(fnd_file.output
                       ,    RPAD('-', 30, '-')
                         || g_column_separator
                         || RPAD('-', 30, '-')
                         || g_column_separator
                         || RPAD('-', 20, '-')
                         || g_column_separator
                         || RPAD('-', 30, '-')
                         || g_column_separator
                         || RPAD('-', 15, '-')
                         || g_column_separator
                         || RPAD('-', 30, '-')
                         || g_column_separator
                         || RPAD('-', 15, '-')
                         || g_column_separator
                         || RPAD('-', 30, '-')
                         || g_column_separator
                         || RPAD('-', 400, '-')
                       );
      g_is_header_printed := TRUE;

      END IF;

      i    := g_output_file_records.FIRST;

      WHILE i IS NOT NULL
      LOOP
         fnd_file.put_line(fnd_file.output
                          ,convert_record_to_outputstring(g_output_file_records(i
                                                                               )
                                                         )
                          );
         i    := g_output_file_records.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END write_output_file_records;

------------------------------------------------------------
--------------------- Get Parameter List -------------------
------------------------------------------------------------
   PROCEDURE GET_PARAMETER_LIST(
      p_pay_action_id    IN              NUMBER
     ,p_parameter_list   OUT NOCOPY      VARCHAR2
   )
   IS
--
      CURSOR csr_get_param_string
      IS
         SELECT legislative_parameters
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_pay_action_id;

      l_proc_step        NUMBER(38, 10)                                  := 0;
      l_proc_name        VARCHAR2(61)
                                    := g_package_name || 'get_parameter_list';
      l_parameter_list   pay_payroll_actions.legislative_parameters%TYPE;
--
   BEGIN
--
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_pay_action_id: ' || p_pay_action_id);
      END IF;

      l_proc_step         := 10;
      l_parameter_list    := NULL;
-- Get the parameter list from legislative parameters
-- for this payroll action id

      OPEN csr_get_param_string;
      FETCH csr_get_param_string INTO l_parameter_list;
      CLOSE csr_get_param_string;
      p_parameter_list    := l_parameter_list;
      l_proc_step         := 20;

      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
--
   END GET_PARAMETER_LIST;

/* ------------------------------------------------------------ */
/* --------------------- Get Parameter Value ------------------ */
/* ------------------------------------------------------------ */
   FUNCTION get_parameter_value(
      p_string           IN   VARCHAR2
     ,p_parameter_list   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
--

      l_proc_step   NUMBER(38, 10)                                    := 0;
      l_proc_name   VARCHAR2(61)   := g_package_name || 'get_parameter_value';
      l_start_ptr   NUMBER;
      l_end_ptr     NUMBER;
      l_token_val   pay_payroll_actions.legislative_parameters%TYPE;
      l_par_value   pay_payroll_actions.legislative_parameters%TYPE;
--
   BEGIN
--
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_string: ' || p_string);
         debug('p_parameter_list: ' || p_parameter_list);
      END IF;

      l_proc_step    := 10;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
      END IF;

      l_token_val    := p_string || '="';
      l_start_ptr    :=
                        INSTR(p_parameter_list, l_token_val)
                      + LENGTH(l_token_val);
      l_end_ptr      := INSTR(p_parameter_list, '"', l_start_ptr);

      IF l_end_ptr = 0
      THEN
         l_end_ptr    := LENGTH(p_parameter_list) + 1;
      END IF;

      l_proc_step    := 20;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('Start Ptr: ' || l_start_ptr);
         debug('End Ptr: ' || l_end_ptr);
      END IF;

      IF INSTR(p_parameter_list, l_token_val) = 0
      THEN
         l_par_value    := NULL;
      -- dbms_output.put_line('par_value: '||par_value);
      ELSE
         l_par_value    :=
              SUBSTR(p_parameter_list, l_start_ptr
                    ,(l_end_ptr - l_start_ptr));
      -- dbms_output.put_line('par_value: '||par_value);
      END IF;

      l_proc_step    := 30;

      IF g_debug
      THEN
         debug('l_par_value: ' || l_par_value);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_par_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
--
   END get_parameter_value;

------------------------------------------------------------
--------------------- Get Assignment Set Details -----------
------------------------------------------------------------
   PROCEDURE get_asg_set_details(
      p_assignment_set_id   IN              NUMBER
     ,p_formula_id          OUT NOCOPY      NUMBER
     ,p_tab_asg_set_amnds   OUT NOCOPY      t_asg_set_amnds
   )
   IS
--
-- Cursor to get information about assignment set
      CURSOR csr_get_asg_set_info(c_asg_set_id NUMBER)
      IS
         SELECT formula_id
           FROM hr_assignment_sets ags
          WHERE assignment_set_id = c_asg_set_id
            AND EXISTS(SELECT 1
                         FROM hr_assignment_set_criteria agsc
                        WHERE agsc.assignment_set_id = ags.assignment_set_id);

-- Cursor to get assignment ids from asg set amendments
      CURSOR csr_get_asg_amnd(c_asg_set_id NUMBER)
      IS
         SELECT assignment_id, NVL(include_or_exclude
                                  ,'I') include_or_exclude
           FROM hr_assignment_set_amendments
          WHERE assignment_set_id = c_asg_set_id;

      l_proc_step           NUMBER(38, 10)             := 0;
      l_proc_name           VARCHAR2(61)
                                    := g_package_name || 'get_asg_set_details';
      l_asg_set_amnds       csr_get_asg_amnd%ROWTYPE;
      l_tab_asg_set_amnds   t_asg_set_amnds;
      l_formula_id          NUMBER;
--
   BEGIN
--
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_assignment_set_id: ' || p_assignment_set_id);
      END IF;

      l_proc_step            := 10;
-- Check whether the assignment set id has a criteria
-- if a formula id is attached or check whether this
-- is an amendments only


      l_formula_id           := NULL;
      OPEN csr_get_asg_set_info(p_assignment_set_id);
      FETCH csr_get_asg_set_info INTO l_formula_id;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('l_formula_id: ' || l_formula_id);
      END IF;

      IF csr_get_asg_set_info%FOUND
      THEN
         -- Criteria exists check for formula id
         IF l_formula_id IS NULL
         THEN
            -- Raise error as the criteria is not generated
            hr_utility.set_message(8303, 'PQP_230458_ABV_ASGSET_NO_FMLA');
            fnd_file.put_line(fnd_file.LOG
                             , RPAD('Error', 30) || ': ' || hr_utility.get_message
                             );
            fnd_file.put_line(fnd_file.LOG, ' ');
            l_proc_step    := 20;

            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
               debug('Error: ' || hr_utility.get_message);
            END IF;

            CLOSE csr_get_asg_set_info;
            hr_utility.raise_error;
         END IF; -- End if of formula id is null check ...
      END IF; -- End if of asg criteria row found check ...

      CLOSE csr_get_asg_set_info;
      l_proc_step            := 30;
      OPEN csr_get_asg_amnd(p_assignment_set_id);
      LOOP
         FETCH csr_get_asg_amnd INTO l_asg_set_amnds;
         EXIT WHEN csr_get_asg_amnd%NOTFOUND;
         l_tab_asg_set_amnds(l_asg_set_amnds.assignment_id)    :=
                                           l_asg_set_amnds.include_or_exclude;

         IF g_debug
         THEN
            debug(   'l_tab_asg_set_amnds('
                  || l_asg_set_amnds.assignment_id
                  || '): '
                  || l_asg_set_amnds.include_or_exclude
                 );
         END IF;
      END LOOP;

      CLOSE csr_get_asg_amnd;
      p_formula_id           := l_formula_id;
      p_tab_asg_set_amnds    := l_tab_asg_set_amnds;
      l_proc_step            := 40;

      IF g_debug
      THEN
         debug('l_tab_asg_set_amnds.COUNT: ' || l_tab_asg_set_amnds.COUNT);
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
--
   END get_asg_set_details;

--
/* ------------------------------------------------------------ */
/* --------------------- Range Cursor ------------------------- */
/* ------------------------------------------------------------ */
   PROCEDURE range_cursor(
      p_pay_action_id   IN              NUMBER
     ,p_sqlstr          OUT NOCOPY      VARCHAR2
   )
   IS
--
-- Cursor to check whether at least one amendment
-- has an inclusion
      CURSOR csr_get_asg_amnd_incl(c_asg_set_id NUMBER)
      IS
         SELECT 'X'
           FROM hr_assignment_set_amendments
          WHERE assignment_set_id = c_asg_set_id
            AND NVL(include_or_exclude, 'I') =
                                     'I' -- hard coded as it's from lookup code
            AND ROWNUM < 2;

      l_proc_step           NUMBER(38, 10)  := 0;
      l_proc_name           VARCHAR2(61)   := g_package_name || 'range_cursor';
      l_person_id           NUMBER;
      l_assignment_id       NUMBER;
      l_assignment_set_id   NUMBER;
      l_string              VARCHAR2(32000);
      l_exists              VARCHAR2(10);
      l_formula_id          NUMBER;
      l_tab_asg_set_amnds   t_asg_set_amnds;
--
   BEGIN
--
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_pay_action_id: ' || p_pay_action_id);
      END IF;

      -- Initialize global variables

      l_string               := NULL;
      g_person_id            := NULL;
      g_formula_id           := NULL;
      g_tab_asg_set_amnds.DELETE;
      g_assignment_set_id    := NULL;
      l_formula_id           := NULL;
      l_person_id            := NULL;
      l_assignment_set_id    := NULL;
      g_business_group_id    := NULL;
      g_parameter_list       := NULL;
      g_uom                  := NULL;
      g_action               := NULL;
      g_effective_date       := NULL;
      g_payroll_id           := NULL;
      g_contract             := NULL;
      -- Get business group id
      g_business_group_id    := fnd_profile.VALUE('PER_BUSINESS_GROUP_ID');
      -- Get parameter list
      l_proc_step            := 10;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
      END IF;

      GET_PARAMETER_LIST(p_pay_action_id       => p_pay_action_id -- IN
                        ,p_parameter_list      => g_parameter_list -- OUT
                        );
      -- Get person id from get_parameter_value
      l_proc_step            := 20;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
      END IF;

      l_person_id            :=
         get_parameter_value(p_string              => 'PERSON' -- IN
                            ,p_parameter_list      => g_parameter_list -- IN
                            );

      IF g_uom IS NULL
      THEN
         -- load cache
         l_proc_step    := 25;
         load_cache(p_payroll_action_id => p_pay_action_id);
      END IF;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('Person ID: ' || l_person_id);
         debug('g_uom: ' || g_uom);
         debug('g_action: ' || g_action);
         debug('g_effective_date: ' || g_effective_date);
         debug('g_business_group_id: ' || g_business_group_id);
         debug('g_payroll_id: ' || g_payroll_id);
         debug('g_contract: ' || g_contract);
      END IF;

      IF l_person_id IS NULL
      THEN
         l_string    :=
            'SELECT DISTINCT person_id FROM per_people_f ppf
                                    ,pay_payroll_actions ppa
       WHERE ppf.business_group_id = ppa.business_group_id
         AND ppa.payroll_action_id = :payroll_action_id
       ORDER BY ppf.person_id';
      ELSE -- l_person_id IS NOT NULL
         l_string       :=
                'SELECT DISTINCT person_id FROM per_people_f ppf
                                     ,pay_payroll_actions ppa
        WHERE ppf.business_group_id = ppa.business_group_id
          AND ppa.payroll_action_id = :payroll_action_id
          AND ppf.person_id = '
             || l_person_id
             || ' ORDER BY ppf.person_id';
         -- Store the person id in a global variable
         g_person_id    := l_person_id;
      END IF; -- End if of person id is null check ...

-- In addition to checks for person id
-- We may have to determine whether an assignment set
-- has been supplied

-- Get assignment set id from get_parameter_value

      l_proc_step            := 40;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('l_string: ' || l_string);
         debug('g_person_id: ' || g_person_id);
      END IF;

      l_assignment_set_id    :=
         get_parameter_value(p_string              => 'ASSIGNMENT SET' -- IN
                            ,p_parameter_list      => g_parameter_list -- IN
                            );

      IF l_assignment_set_id IS NOT NULL
      THEN
         l_proc_step            := 50;
         g_assignment_set_id    := l_assignment_set_id;
         -- call local procedure to get assignment set details
         get_asg_set_details(p_assignment_set_id      => l_assignment_set_id
                            ,p_formula_id             => l_formula_id
                            ,p_tab_asg_set_amnds      => l_tab_asg_set_amnds
                            );

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('l_formula_id: ' || l_formula_id);
            debug('l_tab_asg_set_amnds.COUNT: ', l_tab_asg_set_amnds.COUNT);
         END IF;

         l_proc_step            := 60;
         g_tab_asg_set_amnds    := l_tab_asg_set_amnds;

         IF l_formula_id IS NOT NULL
         THEN
            -- we will use the selective logic at assignment
            -- action level, store the formula id in the
            -- global variable
            g_formula_id    := l_formula_id;

            IF g_debug
            THEN
               debug('g_formula_id: ' || g_formula_id);
            END IF;
         -- PS: If both are specified then we are not going
         -- to modify the range cursor with the assignments in
         -- the assignment set, this also applies to exclude only
         -- amendments

         -- Create a temporary table dynamically
         -- to store all the person ids
         -- drop the table before creating one


--        BEGIN
--          SELECT 'x' INTO l_exists
--            FROM pqp_person_id_temp
--           WHERE rownum < 2;
--          EXECUTE IMMEDIATE 'DROP TABLE pqp_person_id_temp';
--          IF g_debug THEN
--            debug(l_proc_name, l_proc_step);
--            debug('g_amendment_exits: '||g_amendment_exists);
--          END IF;
--        EXCEPTION
--          WHEN no_data_found THEN
--            null;
--        END;
--        l_proc_step := 80;
--
--        l_create_string := 'CREATE TABLE pqp_person_id_temp
--                            AS SELECT DISTINCT paa.person_id
--                                     ,paa.assignment_id
--                                     ,haa.include_or_exclude
--                                 FROM per_all_assignments_f        paa
--                                     ,hr_assignment_set_amendments haa
--                                WHERE paa.assignment_id = haa.assignment_id
--                                  AND haa.assignment_set_id = '
--                            || l_assignment_set_id;
--        EXECUTE IMMEDIATE l_create_string;
--
--        IF g_debug THEN
--          debug(l_proc_name, l_proc_step);
--          debug('l_create_string: '||l_create_string);
--        END IF;

         ELSE -- formula id is null

              -- Modify the sql string only if there is at least
              -- one inclusion in the assignment set amendment
              -- and if the assignment set is not based on criteria
            OPEN csr_get_asg_amnd_incl(l_assignment_set_id);
            FETCH csr_get_asg_amnd_incl INTO l_exists;

            IF csr_get_asg_amnd_incl%FOUND
            THEN
               l_proc_step    := 70;
               l_string       :=
                      'SELECT DISTINCT person_id
                         FROM per_all_assignments_f        paa
                             ,hr_assignment_set_amendments hasa
                             ,pay_payroll_actions          ppa
         WHERE paa.business_group_id = ppa.business_group_id
                          AND ppa.payroll_action_id = :payroll_action_id
                          AND paa.assignment_id = hasa.assignment_id
                          AND NVL(hasa.include_or_exclude,'
                   || '''I'''
                   || ') = '
                   || '''I'''
                   || ' AND hasa.assignment_set_id = '
                   || l_assignment_set_id;
            END IF; -- End if of inclusion amendments found ...

            CLOSE csr_get_asg_amnd_incl;

            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
               debug('l_string: ' || l_string);
            END IF;
         END IF; -- End if of formula id not null check ...
      END IF; -- End if of assignment set id not null check ...

      p_sqlstr               := l_string;
      l_proc_step            := 80;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('l_string: ' || l_string);
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
--
   END range_cursor;

--
/* ------------------------------------------------------------ */
/* ------------ Check Asg Qualifies for Assignment Set -------- */
/* ------------------------------------------------------------ */
   FUNCTION chk_is_asg_in_asg_set(
      p_assignment_id       IN   NUMBER
     ,p_formula_id          IN   NUMBER
     ,p_tab_asg_set_amnds   IN   t_asg_set_amnds
     ,p_effective_date      IN   DATE
   )
      RETURN VARCHAR2
   IS
--
  -- Cursor to get session date
      CURSOR csr_get_session_date
      IS
         SELECT NVL(effective_date, SYSDATE)
           FROM fnd_sessions
          WHERE session_id = USERENV('SESSIONID');

      l_proc_step           NUMBER(38, 10)    := 0;
      l_proc_name           VARCHAR2(61)
                                 := g_package_name || 'chk_is_asg_in_asg_set';
      l_session_date        DATE;
      l_include_flag        VARCHAR2(10);
      l_tab_asg_set_amnds   t_asg_set_amnds;
      l_inputs              ff_exec.inputs_t;
      l_outputs             ff_exec.outputs_t;
--
   BEGIN
--

      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_assignment_id: ' || p_assignment_id);
         debug('p_formula_id: ' || p_formula_id);
         debug('p_effective_date: ' || p_effective_date);
      END IF;

      l_include_flag         := 'N';
      l_tab_asg_set_amnds    := p_tab_asg_set_amnds;
      l_proc_step            := 10;

      -- Check whether the assignment exists in the collection
      -- first as the static assignment set overrides the
      -- criteria one
      IF l_tab_asg_set_amnds.EXISTS(p_assignment_id)
      THEN
         -- Check whether to include or exclude
         IF l_tab_asg_set_amnds(p_assignment_id) = 'I'
         THEN
            l_include_flag    := 'Y';
         ELSIF l_tab_asg_set_amnds(p_assignment_id) = 'E'
         THEN
            l_include_flag    := 'N';
         END IF; -- End if of include or exclude flag check ...
      ELSIF p_formula_id IS NOT NULL
      THEN
         -- assignment does not exist in assignment set amendments
         -- check whether a formula criteria exists for this
         -- assignment set
         -- Initialize the formula
         l_proc_step    := 30;
         ff_exec.init_formula(p_formula_id          => p_formula_id
                             ,p_effective_date      => p_effective_date
                             ,p_inputs              => l_inputs
                             ,p_outputs             => l_outputs
                             );

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('p_formula_id: ' || p_formula_id);
            debug('p_effective_date: ' || p_effective_date);
         END IF;

         l_proc_step    := 40;

         -- Get session date
--         OPEN csr_get_session_date;
--         FETCH csr_get_session_date INTO l_session_date;
--         CLOSE csr_get_session_date;

         -- Set the inputs first
         -- Loop through them to set the contexts

         FOR i IN l_inputs.FIRST .. l_inputs.LAST
         LOOP
            IF l_inputs(i).NAME = 'ASSIGNMENT_ID'
            THEN
               l_inputs(i).VALUE    := p_assignment_id;
            ELSIF l_inputs(i).NAME = 'DATE_EARNED'
            THEN
               l_inputs(i).VALUE    :=
                                 fnd_date.date_to_canonical(p_effective_date);
            END IF;

            IF g_debug
            THEN
               debug('l_inputs(' || i || ').name: ' || l_inputs(i).NAME);
               debug('l_inputs(' || i || ').value: ' || l_inputs(i).VALUE);
            END IF;
         END LOOP;

         l_proc_step    := 50;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         -- Run the formula
         ff_exec.run_formula(l_inputs, l_outputs);
         -- Check whether the assignment has to be included
         -- by checking the output flag

         l_proc_step    := 60;

         FOR i IN l_outputs.FIRST .. l_outputs.LAST
         LOOP
            IF g_debug
            THEN
               debug('l_outputs(' || i || ').name: ' || l_outputs(i).NAME);
               debug('l_outputs(' || i || ').value: ' || l_outputs(i).VALUE);
            END IF;

            IF l_outputs(i).NAME = 'INCLUDE_FLAG'
            THEN
               IF l_outputs(i).VALUE = 'Y'
               THEN
                  l_include_flag    := 'Y';
               ELSIF l_outputs(i).VALUE = 'N'
               THEN
                  l_include_flag    := 'N';
               END IF;

               EXIT;
            END IF;
         END LOOP;
      END IF; -- End if of assignment exists in amendments check ...

      l_proc_step            := 70;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('l_include_flag: ' || l_include_flag);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_include_flag;
   EXCEPTION

      WHEN hr_application_error
      THEN
      	RETURN l_include_flag;

      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
--
   END chk_is_asg_in_asg_set;

--
/* ------------------------------------------------------------ */
/* --------------------- Action Creation ---------------------- */
/* ------------------------------------------------------------ */
   PROCEDURE action_creation(
      p_pay_action_id   IN   NUMBER
     ,p_start_person    IN   NUMBER
     ,p_end_person      IN   NUMBER
     ,p_chunk           IN   NUMBER
   )
   IS
--
  -- Cursor to fetch assignments based on person id
      CURSOR csr_get_eff_assignments(
         c_assignment_id     NUMBER
	,c_business_group_id NUMBER
        ,c_effective_date    DATE
      )
      IS
         SELECT   asg.assignment_id assignment_id, asg.payroll_id
             FROM per_all_assignments_f asg
            WHERE asg.person_id BETWEEN p_start_person AND p_end_person
              AND asg.assignment_id = NVL(c_assignment_id, asg.assignment_id)
	      AND asg.business_group_id = c_business_group_id
              AND (   c_effective_date BETWEEN asg.effective_start_date
                                           AND asg.effective_end_date
                   OR (    asg.effective_start_date > c_effective_date
                       AND asg.effective_end_date =
                                (SELECT MIN(asg2.effective_end_date)
                                   FROM per_all_assignments_f asg2
                                  WHERE asg2.assignment_id = asg.assignment_id)
                      )
                )
               AND asg.assignment_type NOT IN ('C', 'A', 'B')     -- Bug 6847750, 7718235
         ORDER BY asg.assignment_id;

      -- Cursor to get next value from assignment action seq
      CURSOR csr_get_asg_action_seq
      IS
         SELECT pay_assignment_actions_s.NEXTVAL
           FROM DUAL;

      -- Cursor to get assignments from assignment amendments
      -- that does not fall within the effective date range
      CURSOR csr_get_asg_out_date(
         c_assignment_set_id   NUMBER
        ,c_effective_date      DATE
      )
      IS
         SELECT   asg.assignment_id
             FROM per_all_assignments_f asg
                 ,hr_assignment_set_amendments hasa
            WHERE asg.assignment_id = hasa.assignment_id
              AND hasa.assignment_set_id = c_assignment_set_id
              AND NVL(hasa.include_or_exclude, 'I') = 'I'
              AND asg.person_id BETWEEN p_start_person AND p_end_person
              AND asg.effective_end_date < c_effective_date
              AND NOT EXISTS(
                     SELECT 1
                       FROM per_all_assignments_f asg2
                      WHERE asg2.assignment_id = asg.assignment_id
                        AND (   c_effective_date
                                   BETWEEN asg2.effective_start_date
                                       AND asg2.effective_end_date
                             OR asg2.effective_start_date > c_effective_date
                            ))
         ORDER BY asg.assignment_id;

      -- Cursor to check for assignment contract
      CURSOR csr_chk_asg_contract(
         c_assignment_id    NUMBER
        ,c_contract         VARCHAR2
        ,c_effective_date   DATE
      )
      IS
         SELECT 'X'
           FROM pqp_assignment_attributes_f
          WHERE assignment_id = c_assignment_id
            AND contract_type = c_contract
            AND (   c_effective_date BETWEEN effective_start_date
                                         AND effective_end_date
                 OR effective_start_date > c_effective_date
                );

      l_proc_step           NUMBER(38, 10)                                := 0;
      l_proc_name           VARCHAR2(61)
                                        := g_package_name || 'action_creation';
      l_assignment_id       NUMBER;
      l_assignment_set_id   NUMBER;
      l_payroll_id          NUMBER;
      l_contract            pqp_assignment_attributes_f.contract_type%TYPE;
      l_business_group_id   per_business_groups.business_group_id%TYPE;
      l_effective_date      DATE;
      l_tab_asg_set_amnds   t_asg_set_amnds;
      l_include_flag        VARCHAR2(10);
      l_exists              VARCHAR2(10);
      l_report_assignment   NUMBER;
      l_asg_action_seq      NUMBER;
-- Bug 6147019 Begin
      l_formula_id          NUMBER;
-- Bug 6147019 End
   BEGIN
--
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_pay_action_id: ' || p_pay_action_id);
         debug('p_start_person: ' || p_start_person);
         debug('p_end_person: ' || p_end_person);
         debug('p_chunk: ' || p_chunk);
      END IF;

      l_proc_step            := 10;

      IF g_uom IS NULL
      THEN
         -- load cache
         load_cache(p_payroll_action_id => p_pay_action_id);
      END IF;

      l_assignment_id        :=
                           get_parameter_value('ASSIGNMENT', g_parameter_list);
-- Bug 6147019 Begin       l_assignment_set_id    := g_assignment_set_id;
      l_assignment_set_id    :=
                           get_parameter_value(p_string              => 'ASSIGNMENT SET' -- IN
                            ,p_parameter_list      => g_parameter_list -- IN
                            );
-- Bug 6147019 End
      l_effective_date       := g_effective_date;
      l_payroll_id           := g_payroll_id;
      l_contract             := g_contract;
      l_business_group_id    := g_business_group_id;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('l_assignment_id: ' || l_assignment_id);
         debug('l_assignment_set: ' || l_assignment_set_id);
         debug('l_payroll: ' || l_payroll_id);
         debug('l_contract: ' || l_contract);
         debug('l_effective_date: ' || l_effective_date);
      END IF;

-- Bug 6147019 Begin
IF l_assignment_set_id IS NOT NULL
      THEN
         l_proc_step            := 15;
         g_assignment_set_id    := l_assignment_set_id;
         -- call local procedure to get assignment set details
         get_asg_set_details(p_assignment_set_id      => l_assignment_set_id
                            ,p_formula_id             => l_formula_id
                            ,p_tab_asg_set_amnds      => l_tab_asg_set_amnds
                            );
   IF l_formula_id IS NOT NULL
         THEN
            -- we will use the selective logic at assignment
            -- action level, store the formula id in the
            -- global variable
            g_formula_id    := l_formula_id;

            IF g_debug
            THEN
               debug('g_formula_id: ' || g_formula_id);
            END IF;
   END IF;

END IF;
-- Bug 6147019 End
      -- Log Messages
      fnd_file.put_line(fnd_file.LOG
                       ,    RPAD('Assignment Set Id', 30)
                         || ': '
                         || l_assignment_set_id
                       );
      fnd_file.put_line(fnd_file.LOG
                       , RPAD('Payroll Id', 30) || ': ' || l_payroll_id
                       );
      fnd_file.put_line(fnd_file.LOG
                       , RPAD('Contract', 30) || ': ' || l_contract);
      fnd_file.put_line(fnd_file.LOG
                       ,    RPAD('Effective Date', 30)
                         || ': '
                         || fnd_date.date_to_displaydate(l_effective_date)
                       );
      l_proc_step            := 20;

      -- Loop through effective assignments for this person
      -- and check whether an assignment action has to be created
      -- after satisfying several criteria
      FOR l_asg_rec IN csr_get_eff_assignments(l_assignment_id
                                              ,l_business_group_id
                                              ,l_effective_date
                                              )
      LOOP
         l_include_flag    := 'N';
         -- Log messages
         fnd_file.put_line(fnd_file.LOG
                          ,    RPAD('Processing Assignment', 30)
                            || ': '
                            || l_asg_rec.assignment_id
                          );

         --
         -- Check whether an assignmet set is specified
         --
         IF l_assignment_set_id IS NOT NULL
         THEN
            -- Check whether this assignment is in the assignment set
            l_proc_step       := 30;
            l_include_flag    :=
               chk_is_asg_in_asg_set(p_assignment_id          => l_asg_rec.assignment_id
                                    ,p_formula_id             => g_formula_id
                                    ,p_tab_asg_set_amnds      => g_tab_asg_set_amnds
                                    ,p_effective_date         => l_effective_date
                                    );
         ELSE -- assignment set is null
            l_include_flag    := 'Y';
         END IF; -- End if of assignment_set IS NOT NULL check ...

         l_proc_step       := 60;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('Assignment ID: ' || l_asg_rec.assignment_id);
            debug('l_include_flag: ' || l_include_flag);
         END IF;

         IF l_include_flag = 'Y'
         THEN
            l_proc_step    := 70;

            -- Check whether a payroll has been specified
            IF l_payroll_id IS NOT NULL
            THEN
               -- Check whether the payroll id of assignment matches with
               -- this payroll id

               IF l_payroll_id = l_asg_rec.payroll_id
               THEN
                  l_include_flag    := 'Y';
               ELSE
                  l_include_flag    := 'N';
               END IF;

               IF g_debug
               THEN
                  debug(l_proc_name, l_proc_step);
                  debug('l_asg_rec.payroll_id: ' || l_asg_rec.payroll_id);
                  debug('l_include_flag: ' || l_include_flag);
               END IF;
            END IF; -- End if of payroll id not null check ...

            l_proc_step    := 80;

            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
               debug('l_include_flag: ' || l_include_flag);
            END IF;

            IF l_include_flag = 'Y' AND l_contract IS NOT NULL
            THEN
               l_proc_step    := 100;
               -- Check whether this assignment belongs to this contract
               OPEN csr_chk_asg_contract(l_asg_rec.assignment_id
                                        ,l_contract
                                        ,l_effective_date
                                        );
               FETCH csr_chk_asg_contract INTO l_exists;

               IF csr_chk_asg_contract%FOUND
               THEN
                  l_include_flag    := 'Y';
               ELSE
                  l_include_flag    := 'N';
               END IF;

               CLOSE csr_chk_asg_contract;

               IF g_debug
               THEN
                  debug(l_proc_name, l_proc_step);
                  debug('l_include_flag: ' || l_include_flag);
               END IF;
            END IF; -- End if of contract not null check ...
         END IF; -- End if of l_include_flag = 'Y' check ...

         l_proc_step       := 110;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('l_include_flag: ' || l_include_flag);
         END IF;

         IF l_include_flag = 'Y'
         THEN
            -- Log messages
            fnd_file.put_line(fnd_file.LOG
                             , RPAD('Include Assignment', 30) || ': Yes'
                             );
            -- Create the assignment action to represent the person
            OPEN csr_get_asg_action_seq;
            FETCH csr_get_asg_action_seq INTO l_asg_action_seq;
            CLOSE csr_get_asg_action_seq;
            fnd_file.put_line(fnd_file.LOG
                             ,    RPAD('Assignment Action Id', 30)
                               || ': '
                               || l_asg_action_seq
                             );
            -- insert into pay_assignment_actions
            hr_nonrun_asact.insact(l_asg_action_seq
                                  ,l_asg_rec.assignment_id
                                  ,p_pay_action_id
                                  ,p_chunk
                                  ,NULL
                                  );
         ELSE
            -- Log Messages
            fnd_file.put_line(fnd_file.LOG
                             , RPAD('Include Assignment', 30) || ': No'
                             );
         END IF; -- END if of l_include_flag = 'Y' check ...
      END LOOP;

      -- Report all assignments that are in the static assignment sets
      -- that fall outside the effective date range
      -- i.e. within or in the future

      IF g_tab_asg_set_amnds.COUNT > 0
      THEN
         l_proc_step    := 120;
         OPEN csr_get_asg_out_date(l_assignment_set_id, l_effective_date);
         LOOP
            FETCH csr_get_asg_out_date INTO l_report_assignment;
            EXIT WHEN csr_get_asg_out_date%NOTFOUND;

            IF l_proc_step = 120 THEN
              fnd_file.put_line(fnd_file.LOG
                               ,'The following assignments in the static assignment set were unprocessed:'
                               );
            END IF;
            l_proc_step := 121;

            fnd_file.put_line(fnd_file.LOG
                             ,    RPAD('Assignment ID', 30)
                               || ': '
                               || l_report_assignment
                             );

            IF g_debug
            THEN
               debug('l_report_assignment: ' || l_report_assignment);
            END IF;
         END LOOP;

         CLOSE csr_get_asg_out_date;
      END IF; -- End if of assignment amendments exist

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END action_creation;

/* ------------------------------------------------------------ */
/* --------------------- Archive Data ------------------------- */
/* ------------------------------------------------------------ */
   PROCEDURE archive_data(
      p_assignment_action_id   IN   NUMBER
     ,p_effective_date         IN   DATE
   )
   IS
      CURSOR csr_assignment_id(p_assignment_action_id NUMBER)
      IS
         SELECT assignment_id, payroll_action_id
           FROM pay_assignment_actions
          WHERE assignment_action_id = p_assignment_action_id;

      l_asg_action_details   csr_assignment_id%ROWTYPE;
      l_proc_step            NUMBER(38, 10)              := 0;
      l_proc_name            VARCHAR2(61) := g_package_name || 'archive_data';
   BEGIN
      g_is_concurrent_program_run    := TRUE;
      g_debug                        := hr_utility.debug_enabled;
      g_output_file_records.DELETE;

      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_assignment_action_id: ' || p_assignment_action_id);
         debug('p_effective_date: ' || p_effective_date);
      END IF;

      OPEN csr_assignment_id(p_assignment_action_id);
      FETCH csr_assignment_id INTO l_asg_action_details;
      CLOSE csr_assignment_id;
      l_proc_step                    := 10;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug(   'l_asg_action_details.assignment_id: '
               || l_asg_action_details.assignment_id
              );
         debug(   'l_asg_action_details.payroll_action_id: '
               || l_asg_action_details.payroll_action_id
              );
      END IF;

      IF g_uom IS NULL
      THEN
         load_cache(l_asg_action_details.payroll_action_id);
      END IF;

      pqp_budget_maintenance.maintain_abv_for_assignment(p_uom                    => g_uom
                                                        ,p_assignment_id          => l_asg_action_details.assignment_id
                                                        ,p_business_group_id      => g_business_group_id
                                                        ,p_effective_date         => g_effective_date
                                                        ,p_action                 => g_action
                                                        );

      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END archive_data;

-------------------------------------------------
----------SORT_EVENT_DATES---------------------
-------------------------------------------------

   PROCEDURE sort_event_dates(
      p_base_table      IN OUT NOCOPY   t_indexed_dates
     ,p_compare_table   IN OUT NOCOPY   pqp_table_of_dates
   )
   IS
      l_current     NUMBER;
      l_proc_step   NUMBER(20, 10) := 0;
      l_proc_name   VARCHAR2(61)   := g_package_name || 'sort_event_dates';
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name);
      END IF;

--
-- This procedure is called when we execute the custom function
-- to populate impact dates. This takes care of the fact that user
-- function returned dates may not be sorted.

      l_current    := p_compare_table.FIRST;

      WHILE l_current IS NOT NULL
      LOOP
         l_proc_step                                               :=
                                                       10
                                                       + l_current / 100000;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         p_base_table(TO_CHAR(p_compare_table(l_current), 'j'))    :=
                                                    p_compare_table(l_current);
         l_current                                                 :=
                                               p_compare_table.NEXT(l_current);
      END LOOP; -- WHILE l_current IS NOT NULL

      IF g_debug
      THEN
         debug('Sorted List of dates');
         l_current    := p_base_table.FIRST;

         WHILE l_current IS NOT NULL
         LOOP
            debug(p_base_table(l_current));
            l_current    := p_base_table.NEXT(l_current);
         END LOOP;

         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END sort_event_dates;


-------------------------------------------------------------
---------------GET_EARLIEST_FTE_DATE-------------------------
-------------------------------------------------------------

   FUNCTION get_earliest_possible_fte_date(p_assignment_id NUMBER
                                          ,p_effective_date DATE)
      RETURN DATE
   IS
      l_proc_step                  NUMBER(20, 10) := 0;
      l_proc_name                  VARCHAR2(61)
                        := g_package_name || 'get_earliest_possible_FTE_date';

      CURSOR csr_min_aat_start_date(p_assignment_id NUMBER)
      IS
         SELECT MIN(aat.effective_start_date)
           FROM pqp_assignment_attributes_f aat
          WHERE aat.assignment_id = p_assignment_id
            AND aat.contract_type IS NOT NULL;

      CURSOR csr_min_asg_start_date(p_assignment_id NUMBER)
      IS
         SELECT MIN(asg.effective_start_date)
           FROM per_all_assignments_f asg
          WHERE asg.assignment_id = p_assignment_id
            AND asg.normal_hours IS NOT NULL;

      l_aat_effective_start_date   DATE;
      l_asg_effective_start_date   DATE;
      l_earliest_effective_date    DATE;
   BEGIN -- get_earliest_possible_FTE_date
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_assignment_id:' || p_assignment_id);
      END IF;

       OPEN csr_min_aat_start_date(p_assignment_id);
      FETCH csr_min_aat_start_date INTO l_aat_effective_start_date;
         IF csr_min_aat_start_date%NOTFOUND
	    OR
            l_aat_effective_start_date IS NULL
         THEN
            l_proc_step    := 10;
            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;
            CLOSE csr_min_aat_start_date;
            hr_utility.set_message(8303, 'PQP_230113_AAT_MISSING_CONTRCT');
            hr_utility.set_message_token('EFFECTIVEDATE',
	                           fnd_date.date_to_displaydate(p_effective_date)
				  );
	    hr_utility.raise_error;
         END IF;
       CLOSE csr_min_aat_start_date;

       OPEN csr_min_asg_start_date(p_assignment_id);
      FETCH csr_min_asg_start_date INTO l_asg_effective_start_date;
         IF csr_min_asg_start_date%NOTFOUND
	 OR
         l_asg_effective_start_date IS NULL
         THEN
            l_proc_step    := 20;
            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;
            CLOSE csr_min_asg_start_date;
            hr_utility.set_message(8303, 'PQP_230456_FTE_NO_ASG_DETAILS');
            hr_utility.set_message_token('EFFECTIVEDATE',
                                  fnd_date.date_to_displaydate(p_effective_date)
				  );
	    hr_utility.raise_error;
         END IF;
      CLOSE csr_min_asg_start_date;

      IF g_debug
      THEN
         debug('l_aat_effective_start_date:' || l_aat_effective_start_date);
         debug('l_asg_effective_start_date:' || l_asg_effective_start_date);
      END IF;

      l_earliest_effective_date    :=
              GREATEST(l_aat_effective_start_date, l_asg_effective_start_date);

      l_proc_step := 30;
      IF g_debug
      THEN
         debug(l_proc_name,l_proc_step);
         debug(   'l_earliest_effective_date:'
               || fnd_date.date_to_canonical(l_earliest_effective_date)
              );
         debug_exit(l_proc_name);
      END IF;

      RETURN l_earliest_effective_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_earliest_possible_fte_date;

----------------------------------------------------------------------
------------------MAINTAIN_ABV_FOR_ASSIGNMENT-------------------------
----------------------------------------------------------------------

   PROCEDURE maintain_abv_for_assignment(
      p_uom                 IN   VARCHAR2
     ,p_assignment_id       IN   NUMBER
     ,p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_action              IN   VARCHAR2
   )
   IS
      l_proc_step                 NUMBER(20, 10)                         := 0;
      l_proc_name                 VARCHAR2(61)
                           := g_package_name || 'maintain_abv_for_assignment';
      l_current                   NUMBER;
      l_effective_date            DATE;
      l_log_string                VARCHAR2(4000);
      l_uom                       pqp_configuration_values.pcv_information1%TYPE;
      l_event_dates_source        pqp_configuration_values.pcv_information1%TYPE;
      l_track_event_group_id      pqp_configuration_values.pcv_information1%TYPE;
      l_custom_function_name      pqp_configuration_values.pcv_information1%TYPE;
      l_budget_fast_formula_id    pqp_configuration_values.pcv_information1%TYPE;
      l_this_change_date          DATE;
      l_last_change_date          DATE;
      t_impact_dates              t_indexed_dates; -- table containing the final ordered dates
      l_maintenance_information   csr_get_configuration_data%ROWTYPE;
      c_verify                    CONSTANT VARCHAR2(20)                             := 'Verify';

--7636627
      l_asg_effective_end_date Date;

      CURSOR csr_max_asg_end_date(p_assignment_id NUMBER)
      IS
         SELECT MAX(asg.effective_end_date)
           FROM per_all_assignments_f asg
          WHERE asg.assignment_id = p_assignment_id
            AND asg.normal_hours IS NOT NULL;
--
   BEGIN
      SAVEPOINT maintain_abv_savepoint;

      IF NOT g_is_concurrent_program_run
      THEN
         g_debug    := hr_utility.debug_enabled;
      END IF;

      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_assignment_id: ' || p_assignment_id);
         debug('p_effective_date: ' || p_effective_date);
         debug('p_uom: ' || p_uom);
         debug(   'g_configuration_data.pcv_information1: '
               || g_configuration_data.pcv_information1
              );
         debug('p_business_group_id: ' || p_business_group_id);
         debug('g_business_group_id: ' || g_business_group_id);
      END IF;

--
-- if the cached process definition uom or business group
-- is not equal to the current uom or business group obtain the
-- new configuration values
--
      IF (   (p_uom <> NVL(g_configuration_data.pcv_information1, '~null'))
          OR (p_business_group_id <> g_business_group_id)
         )
      THEN
         l_proc_step             := 5;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         -- empty cache before populating
         --
         g_business_group_id     := NULL;
         g_legislation_code      := NULL;
         g_configuration_data    := NULL;
         OPEN get_business_group_id(p_assignment_id => p_assignment_id);
         FETCH get_business_group_id INTO g_business_group_id;
         IF get_business_group_id%NOTFOUND
         THEN
            l_proc_step    := 10;
            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;
            CLOSE get_business_group_id;
            RAISE NO_DATA_FOUND;
         END IF;
         CLOSE get_business_group_id;

	 OPEN get_legislation_code(p_business_group_id      => g_business_group_id);
         FETCH get_legislation_code INTO g_legislation_code;
         IF get_legislation_code%NOTFOUND
         THEN
            l_proc_step    := 20;
            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;
            CLOSE get_legislation_code;
            RAISE NO_DATA_FOUND;
         END IF;
         CLOSE get_legislation_code;

	 l_proc_step             := 30;
         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('g_business_group_id: ' || g_business_group_id);
            debug('g_legislation_code: ' || g_legislation_code);
         END IF;

         -- check for maintenance enabled
         -- if disabled signal error and stop processing
         load_cache(p_uom                       => p_uom
                   ,p_business_group_id         => g_business_group_id
                   ,p_legislation_code          => g_legislation_code
                   ,p_information_category      => c_abvm_maintenance
                   ,p_configuration_data        => l_maintenance_information
                   );

         IF g_debug
         THEN
            debug(   'l_maintenance_information.pcv_information1: '
                  || l_maintenance_information.pcv_information1
                 );
            debug(   'l_maintenance_information.pcv_information2: '
                  || l_maintenance_information.pcv_information2
                 );
         END IF;

	 l_proc_step := 40;
         IF (l_maintenance_information.pcv_information2 <> 'Y')
         THEN
            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;
            hr_utility.raise_error;
         END IF;

         l_log_string            := NULL;

         IF g_is_concurrent_program_run
         THEN
            SELECT NAME
              INTO l_log_string
              FROM per_business_groups_perf
             WHERE business_group_id = g_business_group_id;

            fnd_file.put_line(fnd_file.LOG
                             ,    RPAD('Business Group', 30, ' ')
                               || ': '
                               || l_log_string
                             );
            fnd_file.put_line(fnd_file.LOG
                             ,    RPAD('Effective Date', 30, ' ')
                               || ': '
                               || fnd_date.date_to_displaydate(p_effective_date
                                                              )
                             );
         END IF;

         load_cache(p_uom                       => p_uom
                   ,p_business_group_id         => g_business_group_id
                   ,p_legislation_code          => g_legislation_code
                   ,p_information_category      => c_abvm_definition
                   ,p_configuration_data        => g_configuration_data
                   );

         -- g_configuration_data
              -- UOM                                  pcv_information1
	      -- Event Dates Source                   pcv_information2
	      -- Event Dates - Event Group            pcv_information3
	      -- Event Dates - Custom Function        pcv_information4
	      -- Budget Value Formula                 pcv_information5

	 l_log_string                := NULL;

         IF g_is_concurrent_program_run
         THEN
            -- make log entry for configuration data used for batch process run
            -- making an entry here ensures that log is made only when the
            -- configuration data changes
            fnd_file.put_line(fnd_file.LOG
                          ,    RPAD('Process Definition', 30, ' ')
                            || ': '
                            || g_configuration_data.configuration_name
                          );

            fnd_file.put_line(fnd_file.LOG, RPAD('UOM', 30, ' ') || ': '
	                       ||g_configuration_data.pcv_information1);
            fnd_file.put_line(fnd_file.LOG
                          ,    RPAD('Event Dates Source', 30, ' ')
                            || ': '
                            || g_configuration_data.pcv_information2
                          );
           -- log event group
           IF g_configuration_data.pcv_information3 IS NOT NULL
           THEN
              SELECT event_group_name
                INTO l_log_string
                FROM pay_event_groups
               WHERE event_group_id = g_configuration_data.pcv_information3;
            END IF;

            l_proc_step    := 50;

            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;

            fnd_file.put_line(fnd_file.LOG
                          ,    RPAD('Track Event Group', 30, ' ')
                            || ': '
                            || l_log_string
                          );
            fnd_file.put_line(fnd_file.LOG
                          ,    RPAD('Custom Function', 30, ' ')
                            || ': '
                            || g_configuration_data.pcv_information4
                          );
            -- log fast formula
            SELECT formula_name
              INTO l_log_string
              FROM ff_formulas_f
             WHERE formula_id = g_configuration_data.pcv_information5;

             l_proc_step    := 60;

             IF g_debug
             THEN
               debug(l_proc_name, l_proc_step);
             END IF;

             fnd_file.put_line(fnd_file.LOG
                          ,    RPAD('Budget Fast Formula', 30, ' ')
                            || ': '
                            || l_log_string
                          );
          END IF; -- IF g_is_concurrent_program_run
      END IF; -- IF ((p_uom <> nvl(g_definition_data_record.uom,'~null'))

      g_defn_configuration_id     :=
                                   g_configuration_data.configuration_value_id;
      l_uom                       := g_configuration_data.pcv_information1;
      l_event_dates_source        := g_configuration_data.pcv_information2;
      l_track_event_group_id      := g_configuration_data.pcv_information3;
      l_custom_function_name      := g_configuration_data.pcv_information4;
      l_budget_fast_formula_id    := g_configuration_data.pcv_information5;
      l_proc_step                 := 70;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('g_defn_configuration_id: ' || g_defn_configuration_id);
         debug('UOM: ' || l_uom);
         debug('Event Dates Source: ' || l_event_dates_source);
         debug('Track Event Group: ' || l_track_event_group_id);
         debug('Custom Function: ' || l_custom_function_name);
         debug('Budget Fast Formula: ' || l_budget_fast_formula_id);
      END IF;


-- create output records for concurrent process
-- and fix the start calculation date
IF g_is_concurrent_program_run
  THEN
    l_proc_step         := 75;
    IF g_debug
    THEN
            debug(l_proc_name, l_proc_step);
    END IF;

    g_output_file_records(1).assignment_id                               :=
                                                              p_assignment_id;
    g_output_file_records(g_output_file_records.FIRST).uom               :=
                                                                        p_uom;

    SELECT employee_number
      INTO g_output_file_records(g_output_file_records.FIRST).employee_number
      FROM per_all_people_f a
     WHERE a.person_id =
               (SELECT asg.person_id
                  FROM per_all_assignments_f asg
                 WHERE asg.assignment_id = p_assignment_id AND ROWNUM < 2)
                   AND effective_start_date = (SELECT MAX(b.effective_start_date)
                                                 FROM per_all_people_f b
                                                WHERE b.person_id = a.person_id);

   l_proc_step                                                          := 80;

   IF g_debug
   THEN
       debug(l_proc_name, l_proc_step);
   END IF;

   SELECT assignment_number
     INTO g_output_file_records(g_output_file_records.FIRST).assignment_number
     FROM per_all_assignments_f a
    WHERE a.assignment_id = p_assignment_id
      AND a.effective_start_date =
                          (SELECT MAX(b.effective_start_date)
                             FROM per_all_assignments_f b
                            WHERE b.assignment_id = a.assignment_id);

END IF; -- IF g_is_concurrent_program_run

-- to support all assignments which have a later starting date than the effective
-- date passed, the earliest possible effective date of the assignment will be used
-- note : this is applicable for all UOMs, the only criteria being that the
-- inbuilt custom function is being used

IF (   g_is_concurrent_program_run
        AND
        (LOWER(l_custom_function_name) =
                                  'pqp_budget_maintenance.get_fte_event_dates')
   )
THEN
      l_proc_step         := 90;
      IF g_debug
      THEN
          debug(l_proc_name, l_proc_step);
      END IF;

      l_effective_date    :=
                          get_earliest_possible_fte_date(p_assignment_id
			                                     ,p_effective_date);
ELSE
      l_effective_date    := p_effective_date;
END IF; -- IF ( LOWER(l_custom_function_name)...

-- enter effective date in output record
IF g_is_concurrent_program_run
THEN
    g_output_file_records(g_output_file_records.FIRST).effective_date    :=
                                                             l_effective_date;
END IF;

l_proc_step                 := 100;
IF g_debug
THEN
    debug(l_proc_name, l_proc_step);
    debug('l_effective_date: ' || l_effective_date);
END IF;

-- empty table of dates before populating for assignment
t_impact_dates.DELETE;
get_event_dates(p_uom                     => l_uom
               ,p_assignment_id           => p_assignment_id
               ,p_business_group_id       => p_business_group_id
               ,p_event_dates_source      => l_event_dates_source
               ,p_event_group_id          => l_track_event_group_id
               ,p_custom_function         => l_custom_function_name
               ,p_effective_date          => l_effective_date
               ,p_impact_dates            => t_impact_dates
               );
--
-- irrespective of the configuration value options the final
-- impact dates should be populated in t_impact_dates in sorted order
--
-- insert the first row as of the effective date calculated previously
update_value_for_event_dates(p_uom                    => p_uom
                            ,p_assignment_id          => p_assignment_id
                            ,p_business_group_id      => g_business_group_id
                            ,p_formula_id             => l_budget_fast_formula_id
                            ,p_action                 => p_action
                            ,p_effective_date         => l_effective_date
                            );
-- t_impact_dates is a sorted and unique dates table
-- based on a julian index
-- all duplicates have already been removed during sorting
-- hence duplicate elimination logic need not be implemented here

l_last_change_date          := l_effective_date;
l_current                   :=
                           t_impact_dates.NEXT(TO_CHAR(l_effective_date, 'J'));

-- 7636627
     OPEN csr_max_asg_end_date(p_assignment_id);
      FETCH csr_max_asg_end_date INTO l_asg_effective_end_date;
         IF csr_max_asg_end_date%NOTFOUND
	 OR
         l_asg_effective_end_date IS NULL
         THEN
            l_proc_step    := 101;
            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;
          END IF;
      CLOSE csr_max_asg_end_date;
--

WHILE l_current IS NOT NULL
LOOP
         l_proc_step           := 100 + l_current / 100000;
         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('t_impact_dates(l_current): ' || t_impact_dates(l_current));
         END IF;

         l_this_change_date    := t_impact_dates(l_current);
         IF (l_this_change_date <= l_last_change_date)
         THEN
               -- check to ensure that the current processing date is not less than or equal
               -- to the previous change date
               -- if so , signal error and stop further processing
               IF g_debug
               THEN
                  debug(l_proc_name, l_proc_step);
               END IF;
               RAISE NO_DATA_FOUND;
         END IF;


      If l_this_change_date <= l_asg_effective_end_date THEN  -- 7636627
         IF g_is_concurrent_program_run and p_action <> c_verify
         THEN
               g_output_file_records(g_output_file_records.LAST + 1).assignment_id    :=
                                                              p_assignment_id;
               g_output_file_records(g_output_file_records.LAST).uom                  :=
                    g_output_file_records(g_output_file_records.LAST - 1).uom;
               g_output_file_records(g_output_file_records.LAST).employee_number      :=
                  g_output_file_records(g_output_file_records.LAST - 1).employee_number;
               g_output_file_records(g_output_file_records.LAST).assignment_number    :=
                  g_output_file_records(g_output_file_records.LAST - 1).assignment_number;
               g_output_file_records(g_output_file_records.LAST).effective_date       :=
                                                   t_impact_dates(l_current);
            END IF;

            update_value_for_event_dates(p_uom                    => p_uom
                                        ,p_assignment_id          => p_assignment_id
                                        ,p_business_group_id      => g_business_group_id
                                        ,p_formula_id             => l_budget_fast_formula_id
					,p_action                 => p_action
                                        ,p_effective_date         => t_impact_dates(l_current
                                                                                   )
                                        );
       End IF;
            l_current    := t_impact_dates.NEXT(l_current);
      END LOOP; -- WHILE l_current IS NOT NULL

--ROLLBACK TO maintain_abv_savepoint;

-- when action is VERIFY and the run is succesful enter status in output record
IF p_action = c_verify AND g_is_concurrent_program_run THEN
      g_output_file_records(g_output_file_records.LAST).status     :=
                                                                    'Verified';
END IF;

IF g_is_concurrent_program_run THEN
   -- write the output records
   write_output_file_records;
END IF;

IF g_debug
THEN
    debug_exit(l_proc_name);
END IF;

EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;
         IF SQLCODE <> hr_utility.hr_error_number
          THEN
             debug_others(l_proc_name, l_proc_step);
	     IF g_debug THEN
                  debug('Leaving: ' || l_proc_name, -999);
             END IF;
             IF g_is_concurrent_program_run THEN
                   g_output_file_records(g_output_file_records.LAST).status     :=
                                                         'Errored(Fatal)';
                   g_output_file_records(g_output_file_records.LAST).MESSAGE    :=
                                    l_proc_name
                                    || '{'
                                    || fnd_number.number_to_canonical(l_proc_step)
                                    || '}: '
                                    || SUBSTRB(SQLERRM, 1, 2000);

		   fnd_file.put_line(fnd_file.LOG
                                ,    RPAD(NVL(g_output_file_records(g_output_file_records.LAST
                                                            ).employee_number
                                , 'Asg_Id:' || p_assignment_id
                                       )
                                       ,15
                                       ,' '
                                   )
                                     || g_column_separator
                                     || RPAD(g_output_file_records(g_output_file_records.LAST
                                                               ).MESSAGE
                                         ,400
                                         ,' '
                                         )
                                );
		   write_output_file_records;
		   g_output_file_records.DELETE;
	     END IF;
             hr_utility.raise_error;

         ELSE
             IF g_is_concurrent_program_run THEN
                  g_output_file_records(g_output_file_records.LAST).status     :=
                                                               'Errored';
                  g_output_file_records(g_output_file_records.LAST).MESSAGE    :=
                                                     hr_utility.get_message;

	          fnd_file.put_line(fnd_file.LOG
                                ,    RPAD(NVL(g_output_file_records(g_output_file_records.LAST
                                                            ).employee_number
                                , 'Asg_Id:' || p_assignment_id
                                       )
                                       ,15
                                       ,' '
                                   )
                                     || g_column_separator
                                     || RPAD(g_output_file_records(g_output_file_records.LAST
                                                               ).MESSAGE
                                         ,400
                                         ,' '
                                         )
                                );
		   write_output_file_records;
		   g_output_file_records.DELETE; -- do not include in clear cache
	     END IF;
	     RAISE;
	 END IF;
END maintain_abv_for_assignment;

---------------------------------------------------------------------------
-----------------GET_EVENT_DATES-----------------------------------------
---------------------------------------------------------------------------

   PROCEDURE get_event_dates(
      p_uom                  IN              VARCHAR2
     ,p_assignment_id        IN              NUMBER
     ,p_business_group_id    IN              NUMBER
     ,p_event_dates_source   IN              VARCHAR2
     ,p_event_group_id       IN              NUMBER
     ,p_custom_function      IN              VARCHAR2
     ,p_effective_date       IN              DATE
     ,p_impact_dates         IN OUT NOCOPY   t_indexed_dates
   )
   IS
      l_proc_step            NUMBER(20, 10) := 0;
      l_proc_name            VARCHAR2(61)
                                       := g_package_name || 'get_event_dates';

      c_custom_function      CONSTANT VARCHAR2(30)   := 'A Custom Function';
      c_event_group          CONSTANT VARCHAR2(30)   := 'An Event Group';
      c_custom_event_group   CONSTANT VARCHAR2(30)   := 'Both Event Group and Function';

      t_event_dates          pqp_table_of_dates;
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name, l_proc_step);
         debug('p_uom: ' || p_uom);
         debug('p_assignment_id: ' || p_assignment_id);
         debug('p_business_group_id: ' || p_business_group_id);
         debug('p_event_dates_source: ' || p_event_dates_source);
         debug('p_event_group_id: ' || p_event_group_id);
         debug('p_custom_function: ' || p_custom_function);
         debug('p_effective_date: ' || p_effective_date);
      END IF;

-- branch on event dates source in configuration values
-- event group
-- custom function
-- event group and custom function
      IF (p_event_dates_source = c_event_group)
      THEN
         --
         -- event dates source is payroll events
         --
         l_proc_step    := 10;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         -- here p_impact dates is passed by reference
         -- and will be populated with the final set of dates
         -- sort_event_dates procedure cannot be used for this
         -- as the arguements passed to it are of type nested
         -- table and index by table and in this case we would
         -- require both to be index by tables
         get_change_dates_from_dti(p_assignment_id          => p_assignment_id
                                  ,p_business_group_id      => p_business_group_id
                                  ,p_event_group_id         => p_event_group_id
                                  ,p_calculation_date       => p_effective_date
                                  ,p_impact_dates           => p_impact_dates
                                  );
      ELSIF(p_event_dates_source = c_custom_function)
      THEN
         --
         -- event dates source is custom function
         --
         l_proc_step    := 20;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         --
         -- here the sort function will be used to sort the dates returned
         -- by custom function in t_event_dates into p_impact_dates
         execute_custom_function(p_uom                     => p_uom
                                ,p_assignment_id           => p_assignment_id
                                ,p_business_group_id       => p_business_group_id
                                ,p_custom_function         => p_custom_function
                                ,p_effective_date          => p_effective_date
                                ,p_event_dates             => t_event_dates
                                );
         sort_event_dates(p_base_table         => p_impact_dates
                         ,p_compare_table      => t_event_dates
                         );
      ELSIF(p_event_dates_source = c_custom_event_group)
      THEN
         --
         -- dates will be fetched using both custom function
         -- and datetrack interpreter
         --
         l_proc_step    := 30;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         --
         -- get_change_dates_from_dti populates
         -- p_impact_dates with sorted impact dates
         --
         get_change_dates_from_dti(p_assignment_id          => p_assignment_id
                                  ,p_business_group_id      => p_business_group_id
                                  ,p_event_group_id         => p_event_group_id
                                  ,p_calculation_date       => p_effective_date
                                  ,p_impact_dates           => p_impact_dates
                                  );
         --
         -- execute_custom_function will populate dates in t_event_dates
         --
         execute_custom_function(p_uom                     => p_uom
                                ,p_assignment_id           => p_assignment_id
                                ,p_business_group_id       => p_business_group_id
                                ,p_custom_function         => p_custom_function
                                ,p_effective_date          => p_effective_date
                                ,p_event_dates             => t_event_dates
                                );
         --
         --
         sort_event_dates(p_base_table         => p_impact_dates
                         ,p_compare_table      => t_event_dates
                         );
      ELSE
         --
         --error check, code should never reach here
         --
         IF g_debug
         THEN
            debug('Invalid value for Event Dates Source.');
         END IF;
      END IF; --IF (l_event_dates_source = 'P') THEN

      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_event_dates;

---------------------------------------------------------------------------------
----------PAYROLL EVENT DATES -----------------------
---------------------------------------------------------------------------------
   PROCEDURE get_change_dates_from_dti(
      p_assignment_id       IN              NUMBER
     ,p_business_group_id   IN              NUMBER
     ,p_event_group_id      IN              NUMBER
     ,p_calculation_date    IN              DATE
     ,p_impact_dates        IN OUT NOCOPY   t_indexed_dates
   )
   IS
      l_proc_step           NUMBER(20, 10)                               := 0;
      l_proc_name           VARCHAR2(61)
                             := g_package_name || 'get_change_dates_from_dti';

      l_event_group_name    pay_event_groups.event_group_name%TYPE;
      l_no_of_events        NUMBER; -- count of total number of events tracked
      l_cntr                NUMBER;
      l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
      l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;

      CURSOR csr_event_group_name(p_event_group_id NUMBER)
      IS
         SELECT event_group_name
           FROM pay_event_groups
          WHERE event_group_id = p_event_group_id;
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_assignment_id: ' || p_assignment_id);
         debug('p_business_group_id: ' || p_business_group_id);
         debug('p_event_group_id: ' || p_event_group_id);
         debug('p_calculation_date: ' || p_calculation_date);
         debug('p_process_mode: ENTRY_EFFECTIVE_DATE');
         debug('p_start_date: ' || p_calculation_date);
         debug('p_end_date: ' || hr_api.g_eot);
      END IF;

--
--required to know if the entry exists at/after p_calculation_date regardless of when it is created
--hence processing mode used will be ENTRY_EFFECTIVE_DATE
--
      OPEN csr_event_group_name(p_event_group_id);
      FETCH csr_event_group_name INTO l_event_group_name;
      IF csr_event_group_name%NOTFOUND
      THEN
         l_proc_step    := 10;
         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;
         CLOSE csr_event_group_name;
         RAISE NO_DATA_FOUND;
      END IF;
      CLOSE csr_event_group_name;

      IF g_debug
      THEN
         debug('l_event_group_name: ' || l_event_group_name);
      END IF;

      l_no_of_events    :=
         pqp_utilities.get_events(p_assignment_id              => p_assignment_id
                                 ,p_element_entry_id           => NULL
                                 ,p_business_group_id          => p_business_group_id
                                 ,p_process_mode               => 'ENTRY_EFFECTIVE_DATE'
                                 ,p_event_group_name           => l_event_group_name
                                 ,p_start_date                 => p_calculation_date
                                 ,p_end_date                   => hr_api.g_eot -- hardcoded as end of time
                                 ,t_proration_dates            => l_proration_dates -- OUT
                                 ,t_proration_change_type      => l_proration_changes -- OUT
                                 );

      l_proc_step       := 20;
      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('l_no_of_events: ' || l_no_of_events);
      END IF;

	-- clear global cache of dates before populating
	-- this is a required step as the final table of dates must be on julian index
      p_impact_dates.DELETE;

      l_cntr            := l_proration_dates.FIRST;

      WHILE l_cntr IS NOT NULL
      LOOP
         l_proc_step                                                :=
                                                          20
                                                          + l_cntr / 100000;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         p_impact_dates(TO_CHAR(l_proration_dates(l_cntr), 'j'))    :=
                                                     l_proration_dates(l_cntr);
         l_cntr                                                     :=
                                                l_proration_dates.NEXT(l_cntr);
      END LOOP;

      IF g_debug
      THEN
         l_cntr    := p_impact_dates.FIRST;

         WHILE l_cntr IS NOT NULL
         LOOP
            debug('p_impact_dates(l_cntr): ' || p_impact_dates(l_cntr));
            l_cntr    := p_impact_dates.NEXT(l_cntr);
         END LOOP;

         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_change_dates_from_dti;

--------------------------------------------------------------------------
----------------PROCEDURE FOR DYNAMIC EXECUTION OF CUSTOM FUNCTION-------
--------------------------------------------------------------------------
   PROCEDURE execute_custom_function(
      p_uom                  IN              VARCHAR2
     ,p_assignment_id        IN              NUMBER
     ,p_business_group_id    IN              NUMBER
     ,p_custom_function      IN              VARCHAR2
     ,p_effective_date       IN              DATE
     ,p_event_dates          IN OUT NOCOPY   pqp_table_of_dates
   )
   IS
      l_proc_step         NUMBER(20, 10) := 0;
      l_proc_name         VARCHAR2(61)
                               := g_package_name || 'execute_custom_function';

      sqlstr              VARCHAR2(1000);
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_uom: ' || p_uom);
         debug('p_assignment_id: ' || p_assignment_id);
         debug('p_business_group_id: ' || p_business_group_id);
         debug('p_custom_function: ' || p_custom_function);
         debug('p_effective_date: ' || p_effective_date);
      END IF;

--
-- dynamic function template
--
-- PROCEDURE get_fte_event_dates
--          ( p_uom                     IN   VARCHAR2
--           ,p_assignment_id           IN   NUMBER
--           ,p_business_group_id       IN   NUMBER
--           ,p_effective_date          IN   DATE
--           ,p_event_dates             IN OUT NOCOPY pqp_table_of_dates
--          ) RETURN NUMBER;

-- hardwired function call
-- IF g_definition_data_record.custom_function_name = 'pqp_budget_maintenance.get_fte_event_dates' THEN
--
--          get_fte_event_dates
--                     ( p_uom                 => p_uom
--                      ,p_assignment_id       => p_assignment_id
--                      ,p_business_group_id   => p_business_group_id
--                      ,p_effective_date      => p_effective_date
--                      ,p_event_dates         => p_event_dates
--                      );
--

      IF g_debug
      THEN
         l_proc_step    := 10;
         debug(l_proc_name, l_proc_step);
      END IF;

      sqlstr    :=
             'BEGIN '
          || p_custom_function
          || '( :uom, :assignment_id, :business_group_id, :effective_date, :p_event_dates); END;';

      IF g_debug
      THEN
         debug('sqlstr: ' || sqlstr);
      END IF;

      EXECUTE IMMEDIATE sqlstr
         USING                 p_uom
                       ,       p_assignment_id
                       ,       p_business_group_id
                       ,       p_effective_date
                       ,IN OUT p_event_dates;

      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END execute_custom_function;

----------------------------------------------------------
--------------GET_FTE_EVENT_DATES--------------------------
----------------------------------------------------------

   PROCEDURE get_fte_event_dates(
      p_uom                 IN              VARCHAR2
     ,p_assignment_id       IN              NUMBER
     ,p_business_group_id   IN              NUMBER
     ,p_effective_date      IN              DATE
     ,p_event_dates         IN OUT NOCOPY   pqp_table_of_dates
   )
   IS
      l_coverage                   pqp_configuration_values.pcv_information1%TYPE;
      l_proc_step                  NUMBER(20, 10)                        := 0;
      l_proc_name                  VARCHAR2(61)
                                   := g_package_name || 'get_fte_event_dates';

      CURSOR csr_pqp_contract_table(p_legislation_code VARCHAR2)
      IS
         SELECT user_table_id
           FROM pay_user_tables
          WHERE user_table_name = 'PQP_CONTRACT_TYPES'
	    AND legislation_code = p_legislation_code;

      CURSOR csr_assignment_contract(
         p_assignment_id           NUMBER
        ,p_effective_date          DATE
        ,p_pqp_contract_table_id   NUMBER
      )
      IS
         SELECT pur.user_row_id
           FROM pqp_assignment_attributes_f aat, pay_user_rows_f pur
          WHERE aat.assignment_id = p_assignment_id
            AND p_effective_date BETWEEN aat.effective_start_date
                                     AND aat.effective_end_date
            AND pur.user_table_id = p_pqp_contract_table_id
            AND pur.business_group_id = aat.business_group_id
            AND pur.row_low_range_or_name = aat.contract_type
            AND aat.effective_start_date BETWEEN pur.effective_start_date
                                             AND pur.effective_end_date;

      CURSOR csr_get_udt_change_dates(
         p_effective_start_date    IN   DATE
        ,p_pqp_contract_table_id   IN   NUMBER
        ,p_user_row_id             IN   NUMBER
      )
      IS
         SELECT   inst2.effective_start_date
             FROM pay_user_column_instances_f inst1
                 ,pay_user_column_instances_f inst2
            WHERE (   inst1.effective_start_date >= p_effective_start_date
                   OR p_effective_start_date BETWEEN inst1.effective_start_date
                                                 AND inst1.effective_end_date
                  )
              AND inst1.user_row_id = p_user_row_id
              AND inst2.user_column_instance_id =
                                                 inst1.user_column_instance_id
              AND inst2.effective_start_date = inst1.effective_end_date + 1
              AND NVL(inst2.VALUE, '{null}') <> NVL(inst1.VALUE, '~NULL~')
         ORDER BY 1;

--
      CURSOR csr_get_all_change_dates(
         p_assignment_id           IN   NUMBER
        ,p_effective_start_date    IN   DATE
        ,p_pqp_contract_table_id   IN   NUMBER
        ,p_user_row_id             IN   NUMBER
      )
      IS
         SELECT   asg2.effective_start_date
             FROM per_all_assignments_f asg1, per_all_assignments_f asg2
            WHERE asg1.assignment_id = p_assignment_id
              AND (   asg1.effective_start_date >= p_effective_start_date
                   OR p_effective_start_date BETWEEN asg1.effective_start_date
                                                 AND asg1.effective_end_date
                  )
              AND asg2.assignment_id = asg1.assignment_id
              AND asg2.effective_start_date = asg1.effective_end_date + 1
              AND NVL(asg2.normal_hours, -1) <> NVL(asg1.normal_hours, -2)
         UNION ALL
         SELECT   aat2.effective_start_date
             FROM pqp_assignment_attributes_f aat1
                 ,pqp_assignment_attributes_f aat2
            WHERE aat1.assignment_id = p_assignment_id
              AND (   aat1.effective_start_date >= p_effective_start_date
                   OR p_effective_start_date BETWEEN aat1.effective_start_date
                                                 AND aat1.effective_end_date
                  )
              AND aat1.assignment_id = aat2.assignment_id
              AND aat2.effective_start_date = aat1.effective_end_date + 1
              AND NVL(aat2.contract_type, '{null}') <>
                                             NVL(aat1.contract_type, '[NULL]')
         UNION ALL
         SELECT   inst2.effective_start_date
             FROM pay_user_column_instances_f inst1
                 ,pay_user_column_instances_f inst2
            WHERE (   inst1.effective_start_date >= p_effective_start_date
                   OR p_effective_start_date BETWEEN inst1.effective_start_date
                                                 AND inst1.effective_end_date
                  )
              AND inst1.user_row_id = p_user_row_id
              AND inst2.user_column_instance_id =
                                                 inst1.user_column_instance_id
              AND inst2.effective_start_date = inst1.effective_end_date + 1
              AND NVL(inst2.VALUE, '{null}') <> NVL(inst1.VALUE, '~NULL~')
         ORDER BY 1;

      l_legislation_code           VARCHAR2(10);
--
      l_pqp_contract_table_id      pay_user_tables.user_table_id%TYPE;
--
      l_assignment_contract        csr_assignment_contract%ROWTYPE;

      c_udt                        CONSTANT pqp_configuration_values.pcv_information1%TYPE
                                                        := 'User Table Values';
      c_assignment_udt             CONSTANT pqp_configuration_values.pcv_information1%TYPE
                                            := 'Assignment, User Table Values';
      l_maintenance_information    csr_get_configuration_data%ROWTYPE;
      l_count                      NUMBER;
      l_log_string                 VARCHAR2(4000);
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_uom: ' || p_uom);
         debug('p_assignment_id: ' || p_assignment_id);
         debug('p_business_group_id: ' || p_business_group_id);
         debug('p_effective_date: ' || p_effective_date);
      END IF;

       OPEN get_legislation_code(p_business_group_id);
      FETCH get_legislation_code INTO l_legislation_code;
      CLOSE get_legislation_code;

      l_proc_step := 10;
      IF g_debug THEN
          debug(l_proc_name,l_proc_step);
          debug('l_legislation_code: '||l_legislation_code);
          debug('p_uom: ' || p_uom);
          debug(   'g_additional_information.pcv_information1: '
               || g_additional_information.pcv_information1
              );
      END IF;

      IF (p_uom <> NVL(g_additional_information.pcv_information1, '~null'))
      THEN
         -- empty cache of configuration values before populating
         -- include check for when to load
         g_additional_information    := NULL;
         g_additional_config_id      := NULL;

	 l_proc_step                 := 20;
         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         load_cache(p_uom                       => p_uom
                   ,p_business_group_id         => p_business_group_id
                   ,p_legislation_code          => l_legislation_code
                   ,p_information_category      => c_abvm_fte_additional
                   ,p_configuration_data        => g_additional_information
                   );

         l_proc_step                 := 30;
         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

	 l_log_string              := NULL;
         IF g_is_concurrent_program_run
         THEN
             fnd_file.put_line(fnd_file.LOG
                          ,    RPAD('Seeded FTE Configuration', 30, ' ')
                            || ': '
                            || g_additional_information.configuration_name
                          );
             fnd_file.put_line(fnd_file.LOG
                          , RPAD('Coverage', 30, ' ') || ': ' || g_additional_information.pcv_information2
                          );
         END IF;
      END IF; -- IF (p_uom <> NVL(g_additional_information.pcv_information1, '~null'))

      g_additional_config_id    :=
                               g_additional_information.configuration_value_id;
      l_coverage                := g_additional_information.pcv_information2;

      l_proc_step               := 40;
      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('g_additional_config_id: ' || g_additional_config_id);
         debug('l_coverage: ' || l_coverage);
      END IF;

       OPEN csr_pqp_contract_table(p_legislation_code => l_legislation_code);
      FETCH csr_pqp_contract_table INTO l_pqp_contract_table_id;
      IF csr_pqp_contract_table%NOTFOUND
      THEN
         l_proc_step    := 50;
         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;
         CLOSE csr_pqp_contract_table;
         RAISE NO_DATA_FOUND;
      END IF;
      CLOSE csr_pqp_contract_table;

      l_proc_step               := 60;
      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug('l_pqp_contract_table_id:' || l_pqp_contract_table_id);
      END IF;

      OPEN csr_assignment_contract(p_assignment_id              => p_assignment_id
                                  ,p_effective_date             => p_effective_date
                                  ,p_pqp_contract_table_id      => l_pqp_contract_table_id
                                  );
      FETCH csr_assignment_contract INTO l_assignment_contract;
      IF csr_assignment_contract%NOTFOUND
      THEN
         l_proc_step    := 70;
         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;
	 CLOSE csr_assignment_contract;

	 load_cache(p_uom                       => p_uom
                   ,p_business_group_id         => g_business_group_id
                   ,p_legislation_code          => g_legislation_code
                   ,p_information_category      => c_abvm_maintenance
                   ,p_configuration_data        => l_maintenance_information
                   );

         IF g_debug
         THEN
            debug(   'l_maintenance_information.pcv_information1: '
                  || l_maintenance_information.pcv_information1
                 );
            debug(   'l_maintenance_information.pcv_information2: '
                  || l_maintenance_information.pcv_information2
                 );
         END IF;

         IF g_is_concurrent_program_run
	    OR  l_maintenance_information.pcv_information2 = 'Y'
	 THEN
	    l_proc_step    := 75;
            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;
	    hr_utility.set_message(8303, 'PQP_230113_AAT_MISSING_CONTRCT');
            hr_utility.set_message_token('EFFECTIVEDATE'
                              ,fnd_date.date_to_displaydate(p_effective_date
                                                          )
                              );
            hr_utility.raise_error;
         END IF;

      END IF;
      CLOSE csr_assignment_contract;


      l_proc_step               := 80;
      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug(   'l_assignment_contract.user_row_id:'
               || l_assignment_contract.user_row_id
              );
      END IF;

--
--coverage values   'User Table Values'                 Table Values PQP_CONTRACT_TYPES
--                  'Assignment, User Table Values'     Assignment Details,Extra Details Of Service, PQP_CONTRACT_TYPES
--

      IF l_coverage = c_udt
      THEN
         l_proc_step    := 90;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug(   'p_effective_date:'
                  || fnd_date.date_to_canonical(p_effective_date)
                 );
            debug('l_pqp_contract_table_id:' || l_pqp_contract_table_id);
            debug(   'l_assignment_contract.user_row_id:'
                  || l_assignment_contract.user_row_id
                 );
         END IF;

         OPEN csr_get_udt_change_dates(p_effective_start_date       => p_effective_date
                                      ,p_pqp_contract_table_id      => l_pqp_contract_table_id
                                      ,p_user_row_id                => l_assignment_contract.user_row_id
                                      );
         FETCH csr_get_udt_change_dates BULK COLLECT INTO p_event_dates;
         CLOSE csr_get_udt_change_dates;
      ELSIF l_coverage = c_assignment_udt
      THEN
         l_proc_step    := 100;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('p_assignment_id: ' || p_assignment_id);
            debug('p_effective_date: ' || p_effective_date);
            debug('l_pqp_contract_table_id: ' || l_pqp_contract_table_id);
            debug(   'l_assignment_contract.user_row_id: '
                  || l_assignment_contract.user_row_id
                 );
         END IF;

         OPEN csr_get_all_change_dates(p_assignment_id              => p_assignment_id
                                      ,p_effective_start_date       => p_effective_date
                                      ,p_pqp_contract_table_id      => l_pqp_contract_table_id
                                      ,p_user_row_id                => l_assignment_contract.user_row_id
                                      );
         FETCH csr_get_all_change_dates BULK COLLECT INTO p_event_dates;
         CLOSE csr_get_all_change_dates;

      ELSE -- code should never reach here
         IF g_debug
         THEN
            debug('Invalid value in PQP_ABVM_UOM_ADDITIONAL: COVERAGE');
         END IF;
      END IF; --IF l_coverage = 'UDT'

      l_proc_step               := 108;
      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         l_count                   := p_event_dates.FIRST;
         WHILE l_count IS NOT NULL
         LOOP
            IF g_debug
            THEN
               debug('p_event_dates(l_count): ' || p_event_dates(l_count));
            END IF;
            l_count        := p_event_dates.NEXT(l_count);
        END LOOP;

        debug_exit(l_proc_name);
     END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;
         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_fte_event_dates;

----------------------------------------------------------
-----------UPDATE_VALUE_FOR_EVENT_DATES-------------------
----------------------------------------------------------
   PROCEDURE update_value_for_event_dates(
      p_uom                 IN   VARCHAR2
     ,p_assignment_id       IN   NUMBER
     ,p_business_group_id   IN   NUMBER
     ,p_formula_id          IN   NUMBER
     ,p_action              IN   VARCHAR2
     ,p_effective_date      IN   DATE
   )
   IS
      CURSOR csr_formula_name(p_formula_id NUMBER)
      IS
         SELECT formula_name
           FROM ff_formulas_f
          WHERE formula_id = p_formula_id;

      l_inputs         ff_exec.inputs_t; -- fast formula inputs
      l_outputs        ff_exec.outputs_t; -- fast formula outputs
      l_results        NUMBER;
      l_formula_name   ff_formulas_f.formula_name%TYPE;
      c_action         CONSTANT VARCHAR2(20)                      := 'Verify';
      l_message        VARCHAR2(1000);
      l_proc_step      NUMBER(20, 10)                    := 0;
      l_proc_name      VARCHAR2(61)
                          := g_package_name || 'update_value_for_event_dates';
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_uom: ' || p_uom);
         debug('p_assignment_id: ' || p_assignment_id);
         debug('p_business_group_id: ' || p_business_group_id);
         debug('p_effective_date: ' || p_effective_date);
         debug('p_formula_id: ' || p_formula_id);
      END IF;

      ff_exec.init_formula(p_formula_id, p_effective_date, l_inputs
                          ,l_outputs);
      l_proc_step    := 10;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
      END IF;

      FOR l_in_cnt IN l_inputs.FIRST .. l_inputs.LAST
      LOOP
-- set formula contexts
         l_proc_step := 10 + l_in_cnt/100000;
         IF g_debug
         THEN
           debug(l_proc_name, l_proc_step);
         END IF;

         IF (l_inputs(l_in_cnt).NAME = 'ASSIGNMENT_ID')
         THEN
            l_inputs(l_in_cnt).VALUE    := p_assignment_id;
         ELSIF(l_inputs(l_in_cnt).NAME = 'DATE_EARNED')
         THEN
            l_inputs(l_in_cnt).VALUE    :=
                                 fnd_date.date_to_canonical(p_effective_date);
         ELSIF(l_inputs(l_in_cnt).NAME = 'BUSINESS_GROUP_ID')
         THEN
            l_inputs(l_in_cnt).VALUE    := p_business_group_id;
         END IF;

         IF g_debug
         THEN
            debug(   'input: '
                  || l_inputs(l_in_cnt).NAME
                  || ' = '
                  || l_inputs(l_in_cnt).VALUE
                 );
         END IF;
      END LOOP;

      ff_exec.run_formula(l_inputs, l_outputs, FALSE);  -- dbi caching set to false
--
-- update the abv value obtained
--
      l_proc_step    := 20;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
      END IF;

      FOR l_out_cnt IN l_outputs.FIRST .. l_outputs.LAST
      LOOP
         l_proc_step := 25;
         IF g_debug THEN
	     debug(l_proc_name,l_proc_step);
         END IF;

         IF l_outputs(l_out_cnt).NAME = 'ERROR_MESSAGE'
         THEN
            IF l_outputs(l_out_cnt).VALUE IS NOT NULL
            THEN
               --
               -- output error message
               --
               l_proc_step  := 30;
               IF g_debug
               THEN
                  debug(l_outputs(l_out_cnt).VALUE);
                  debug(l_proc_name, l_proc_step);
               END IF;

              OPEN csr_formula_name(p_formula_id);
	      FETCH csr_formula_name INTO l_formula_name;
	      CLOSE csr_formula_name;

              hr_utility.set_message(8303, 'PQP_230459_ABV_FORMULA_ERROR');
	      hr_utility.set_message_token('FORMULANAME',l_formula_name);
	      hr_utility.set_message_token('MESSAGE',l_outputs(l_out_cnt).VALUE);
              hr_utility.raise_error;
            END IF; -- IF l_outputs(l_out_cnt).value IS NOT NULL THEN

	 ELSIF(   UPPER(l_outputs(l_out_cnt).NAME) =
                     TRANSLATE(UPPER(hr_general.decode_lookup('BUDGET_MEASUREMENT_TYPE'
                                                             ,p_uom)),' ','_')
               OR UPPER(l_outputs(l_out_cnt).NAME) = UPPER(p_uom)
              )
         THEN

	    l_proc_step := 35;
	    IF g_debug THEN
	      debug(l_proc_name,l_proc_step);
	    END IF;

            IF g_is_concurrent_program_run and (p_action <> c_action)
            THEN
               g_output_file_records(g_output_file_records.LAST).new_budget_value    :=
                                                fnd_number.canonical_to_number(l_outputs(l_out_cnt).VALUE);
            END IF;

            IF l_outputs(l_out_cnt).VALUE IS NOT NULL
            THEN
               l_proc_step    := 40;

               IF g_debug
               THEN
                  debug(l_proc_name, l_proc_step);
		  debug('fnd_number.canonical_to_number(l_outputs(l_out_cnt).VALUE): '||fnd_number.canonical_to_number(l_outputs(l_out_cnt).VALUE));
               END IF;

               update_and_store_abv(p_uom                    => p_uom
                                   ,p_assignment_id          => p_assignment_id
                                   ,p_business_group_id      => p_business_group_id
                                   ,p_abv_value              => fnd_number.canonical_to_number(l_outputs(l_out_cnt
                                                                         ).VALUE)  -- bug 4372165
				   ,p_action                 => p_action
                                   ,p_effective_date         => p_effective_date
                                   );
            --
            -- else formula has returned a null assignment budget value
            --
            ELSE
               l_proc_step    := 50;
               IF g_debug
               THEN
                  debug(l_proc_name, l_proc_step);
               END IF;
            END IF; --IF l_outputs(l_out_cnt).value IS NOT NULL THEN

	 ELSE -- l_outputs(l_out_cnt).name <> p_uom
            l_proc_step    := 60;
            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
               debug('l_outputs(l_out_cnt).NAME: '||l_outputs(l_out_cnt).NAME);
	       debug('l_outputs(l_out_cnt).VALUE: '||fnd_number.canonical_to_number(l_outputs(l_out_cnt).VALUE));
            END IF;

            OPEN csr_formula_name(p_formula_id);
	    FETCH csr_formula_name INTO l_formula_name;
	    CLOSE csr_formula_name;

            hr_utility.set_message(8303, 'PQP_230459_ABV_FORMULA_ERROR');
            hr_utility.set_message_token('FORMULANAME',l_formula_name);
	    l_message := 'The UOM being processed "'||p_uom||'" does not match the UOM "'
	                  ||l_outputs(l_out_cnt).NAME||'" returned';
	    hr_utility.set_message_token('MESSAGE',l_message);
            hr_utility.raise_error;

         END IF; --IF l_outputs(l_out_cnt).name = 'ERROR_MESSAGE'
      END LOOP;-- FOR l_out_cnt IN l_outputs.FIRST .. l_outputs.LAST

      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END update_value_for_event_dates;

-------------------------------------------------------------------
-------------------UPDATE_AND_STORE_ABV----------------------------
-------------------------------------------------------------------

   PROCEDURE update_and_store_abv(
      p_uom                 IN   VARCHAR2
     ,p_assignment_id       IN   NUMBER
     ,p_business_group_id   IN   NUMBER
     ,p_abv_value           IN   NUMBER
     ,p_action              IN   VARCHAR2
     ,p_effective_date      IN   DATE
   )
   IS
      CURSOR csr_abv_exists(p_assignment_id NUMBER, p_uom VARCHAR2)
      IS
         SELECT 1
           FROM per_assignment_budget_values_f
          WHERE assignment_id = p_assignment_id AND unit = p_uom
                AND ROWNUM < 2;

      CURSOR csr_effective_abv(
         p_assignment_id    NUMBER
        ,p_effective_date   DATE
        ,p_uom              VARCHAR2
      )
      IS
         SELECT assignment_budget_value_id, VALUE, effective_start_date
               ,effective_end_date, object_version_number
           FROM per_assignment_budget_values_f
          WHERE assignment_id = p_assignment_id
            AND unit = p_uom
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

      CURSOR csr_chk_future_abv_rows(
         p_assignment_budget_value_id   NUMBER
        ,p_effective_date               DATE
      )
      IS
         SELECT effective_end_date
           FROM per_assignment_budget_values_f
          WHERE assignment_budget_value_id = p_assignment_budget_value_id
            AND effective_start_date > p_effective_date
            AND ROWNUM < 2;

      l_proc_step           NUMBER(20, 10)              := 0;
      l_proc_name           VARCHAR2(61)
                                   := g_package_name || 'update_and_store_abv';
      l_exists              NUMBER;
      l_effective_abv_row   csr_effective_abv%ROWTYPE;
      l_future_end_date     DATE;
      l_datetrack_mode      VARCHAR2(30);
      c_verify              CONSTANT VARCHAR2(20)            := 'Verify';
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_uom: ' || p_uom);
         debug('p_assignment_id: ' || p_assignment_id);
         debug('p_business_group_id: ' || p_business_group_id);
         debug('p_effective_date: ' || p_effective_date);
         debug('p_abv_value: ' || p_abv_value);
      END IF;

--
-- Check if there are already existing abv rows for this assignment
-- and uom
      OPEN csr_abv_exists(p_assignment_id  => p_assignment_id,
                          p_uom            => p_uom);
      FETCH csr_abv_exists INTO l_exists;

      IF csr_abv_exists%NOTFOUND AND (p_action <> c_verify)
      THEN
         -- No existing abv rows
         -- Therefore create a new row
         -- Datetrack mode = Insert
         l_proc_step    := 10;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         per_abv_ins.ins(p_effective_date                  => p_effective_date
                        ,p_business_group_id               => p_business_group_id
                        ,p_assignment_id                   => p_assignment_id
                        ,p_unit                            => p_uom
                        ,p_value                           => p_abv_value
                        ,p_request_id                      => NULL
                        ,p_program_application_id          => NULL
                        ,p_program_id                      => NULL
                        ,p_program_update_date             => NULL
                        ,p_assignment_budget_value_id      => l_effective_abv_row.assignment_budget_value_id
                        ,p_object_version_number           => l_effective_abv_row.object_version_number
                        ,p_effective_start_date            => l_effective_abv_row.effective_start_date
                        ,p_effective_end_date              => l_effective_abv_row.effective_end_date
                        );

         IF g_is_concurrent_program_run
         THEN
            g_output_file_records(g_output_file_records.LAST).status         :=
                                                                  'Processed';
            g_output_file_records(g_output_file_records.LAST).change_type    :=
                                                                     'INSERT';
         END IF;
      ELSIF csr_abv_exists%FOUND
      THEN
         l_proc_step    := 20;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;

         -- Obtain data for already existing ABV row
         --
         OPEN csr_effective_abv(p_assignment_id       => p_assignment_id
                               ,p_effective_date      => p_effective_date
                               ,p_uom                 => p_uom
                               );
         FETCH csr_effective_abv INTO l_effective_abv_row;

         IF csr_effective_abv%NOTFOUND
         THEN
            -- Indicates that as of the effective date passed there is no
            -- existing ABV rows and yet there are future ABV rows existing
            -- Error out, as this is not a valid case
            l_proc_step                                                  :=
                                                                           30;

            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
            END IF;
            CLOSE csr_effective_abv;
            hr_utility.set_message(8303, 'PQP_230460_ABV_FUTURE_ROWS');
            hr_utility.set_message_token('ABVUOM', p_uom);
            hr_utility.raise_error;
         END IF; -- IF csr_effective_abv%NOTFOUND

         CLOSE csr_effective_abv;
        IF p_action <> c_verify THEN
         IF g_debug
         THEN
            debug('ROUND(p_abv_value,5):' || ROUND(p_abv_value, 5));
            debug('p_effective_date: ' || p_effective_date);
            debug(   'l_effective_abv_row.assignment_budget_value_id:'
                  || l_effective_abv_row.assignment_budget_value_id
                 );
            debug(   'l_effective_abv_row.object_version_number:'
                  || l_effective_abv_row.object_version_number
                 );
            debug(   'l_effective_abv_row.effective_start_date:'
                  || fnd_date.date_to_canonical(l_effective_abv_row.effective_start_date
                                               )
                 );
            debug(   'l_effective_abv_row.effective_end_date:'
                  || fnd_date.date_to_canonical(l_effective_abv_row.effective_end_date
                                               )
                 );
            debug('l_effective_abv_row.value:' || l_effective_abv_row.VALUE);
         END IF;

         IF g_is_concurrent_program_run
         THEN
            g_output_file_records(g_output_file_records.LAST).old_budget_value    :=
                                                    l_effective_abv_row.VALUE;
         END IF;

         -- Obtain details of existing future ABV rows
         --
         OPEN csr_chk_future_abv_rows(l_effective_abv_row.assignment_budget_value_id
                                     ,p_effective_date
                                     );
         FETCH csr_chk_future_abv_rows INTO l_future_end_date;

         IF csr_chk_future_abv_rows%FOUND
         THEN
            --
            --
            -- For updates, if future rows exist, use update override.
            -- This has been agreed as a valid requirement
            --
            l_datetrack_mode    := 'UPDATE_OVERRIDE';
         ELSE
            IF (l_effective_abv_row.effective_start_date <> p_effective_date)
            THEN
               l_datetrack_mode    := 'UPDATE';
            ELSE
               l_datetrack_mode    := 'CORRECTION';
            END IF;
         END IF; --IF csr_chk_future_abv_rows%FOUND

         CLOSE csr_chk_future_abv_rows;
         l_proc_step    := 40;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('l_datetrack_mode: ' || l_datetrack_mode);
         END IF;

         IF l_datetrack_mode <> 'UPDATE_OVERRIDE'
         THEN
            --
            -- only do a datetrack UPDATE or correction if the value is different
            --
            l_proc_step    := 45;

            IF g_debug
            THEN
               debug(l_proc_name, l_proc_step);
               debug(   'ROUND(fnd_number.canonical_to_number(l_effective_abv_row.value),5): '
                     || ROUND(fnd_number.canonical_to_number(l_effective_abv_row.VALUE), 5)
                    );                                     -- bug 4372165
               debug('ROUND(p_abv_value,5): ' || ROUND(p_abv_value, 5));
            END IF;

            IF ROUND(fnd_number.canonical_to_number(l_effective_abv_row.VALUE), 5) <> ROUND(p_abv_value, 5)
            THEN
               l_proc_step    := 50;

               IF g_debug
               THEN
                  debug(l_proc_name, l_proc_step);
               END IF;

               per_abv_upd.upd(p_effective_date                  => p_effective_date
                              ,p_datetrack_mode                  => l_datetrack_mode
                              ,p_assignment_budget_value_id      => l_effective_abv_row.assignment_budget_value_id
                              ,p_object_version_number           => l_effective_abv_row.object_version_number
                              ,p_unit                            => p_uom
                              ,p_value                           => p_abv_value
                              ,p_request_id                      => NULL
                              ,p_program_application_id          => NULL
                              ,p_program_id                      => NULL
                              ,p_program_update_date             => NULL
                              ,p_effective_start_date            => l_effective_abv_row.effective_start_date
                              ,p_effective_end_date              => l_effective_abv_row.effective_end_date
                              );

               IF g_is_concurrent_program_run
               THEN
                  g_output_file_records(g_output_file_records.LAST).status         :=
                                                                  'Processed';
                  g_output_file_records(g_output_file_records.LAST).change_type    :=
                                                             l_datetrack_mode;
               END IF;
            ELSE
               l_proc_step    := 60;

               IF g_debug
               THEN
                  debug(l_proc_name, l_proc_step);
               END IF;

               IF g_is_concurrent_program_run
               THEN
                  g_output_file_records(g_output_file_records.LAST).status         :=
                                                       'Processed(No Change)';
                  g_output_file_records(g_output_file_records.LAST).change_type    :=
                                                             l_datetrack_mode;
               END IF;
            END IF; --IF ROUND(l_effective_abv_row.value,5) <> ROUND(p_abv_value,5)
         ELSE -- l_datetrack_mode = 'UPDATE_OVERRIDE' THEN
            IF g_debug
            THEN
               IF g_is_concurrent_program_run
               THEN
                  debug('g_is_concurrent_program_run:TRUE');
               ELSE
                  debug('g_is_concurrent_program_run:FALSE');
               END IF;
            END IF;

            IF    (    g_is_concurrent_program_run
                   AND ROUND(fnd_number.canonical_to_number(l_effective_abv_row.VALUE), 5) <>
                                                         ROUND(p_abv_value, 5)            --bug 4372165
                  )
               OR NOT g_is_concurrent_program_run
            THEN
               IF l_effective_abv_row.effective_start_date <>
                                                             p_effective_date
               THEN
                  l_proc_step    := 70;

                  IF g_debug
                  THEN
                     debug(l_proc_name, l_proc_step);
                  END IF;

                  per_abv_upd.upd(p_effective_date                  => p_effective_date
                                 ,p_datetrack_mode                  => l_datetrack_mode
                                 ,p_assignment_budget_value_id      => l_effective_abv_row.assignment_budget_value_id
                                 ,p_object_version_number           => l_effective_abv_row.object_version_number -- new param added
                                 ,p_unit                            => p_uom
                                 ,p_value                           => p_abv_value
                                 ,p_request_id                      => NULL
                                 ,p_program_application_id          => NULL
                                 ,p_program_id                      => NULL
                                 ,p_program_update_date             => NULL
                                 ,p_effective_start_date            => l_effective_abv_row.effective_start_date
                                 ,p_effective_end_date              => l_effective_abv_row.effective_end_date
                                 );
               ELSE -- l_effective_abv_row.effective_start_date = p_effective_date
                  l_proc_step         := 80;

                  IF g_debug
                  THEN
                     debug(l_proc_name, l_proc_step);
                  END IF;

                  l_datetrack_mode    := hr_api.g_future_change;
                  per_abv_del.del(p_effective_date                  => p_effective_date
                                 ,p_datetrack_mode                  => l_datetrack_mode
                                 ,p_assignment_budget_value_id      => l_effective_abv_row.assignment_budget_value_id
                                 ,p_object_version_number           => l_effective_abv_row.object_version_number
                                 ,p_effective_start_date            => l_effective_abv_row.effective_start_date
                                 ,p_effective_end_date              => l_effective_abv_row.effective_end_date
                                 );
                  l_datetrack_mode    := hr_api.g_correction;
                  per_abv_upd.upd(p_effective_date                  => p_effective_date
                                 ,p_datetrack_mode                  => l_datetrack_mode
                                 ,p_assignment_budget_value_id      => l_effective_abv_row.assignment_budget_value_id
                                 ,p_object_version_number           => l_effective_abv_row.object_version_number
                                 ,p_unit                            => p_uom
                                 ,p_value                           => p_abv_value
                                 ,p_request_id                      => NULL
                                 ,p_program_application_id          => NULL
                                 ,p_program_id                      => NULL
                                 ,p_program_update_date             => NULL
                                 ,p_effective_start_date            => l_effective_abv_row.effective_start_date
                                 ,p_effective_end_date              => l_effective_abv_row.effective_end_date
                                 );
               END IF; -- IF l_effective_abv_row.effective_start_date <> p_effective_date

               IF g_is_concurrent_program_run
               THEN
                  g_output_file_records(g_output_file_records.LAST).change_type    :=
                                                            'UPDATE_OVERRIDE';
                  g_output_file_records(g_output_file_records.LAST).status         :=
                                                                  'Processed';
               END IF;
            ELSE -- IF ( g_is_concurrent_program_run AND ROUND(l_effective_abv_row.value,5) <> ROUND(p_abv_value,5)...
               l_proc_step    := 90;

               IF g_debug
               THEN
                  debug(l_proc_name, l_proc_step);
               END IF;

               IF g_is_concurrent_program_run
               THEN
                  g_output_file_records(g_output_file_records.LAST).change_type    :=
                                                            'UPDATE_OVERRIDE';
                  g_output_file_records(g_output_file_records.LAST).status         :=
                                                       'Processed(No Change)';
               END IF;
            END IF; -- IF ( g_is_concurrent_program_run AND ROUND(l_effective_abv_row.value,5) <> ROUND(p_abv_value,5)...
         END IF; -- IF l_datetrack_mode <> 'UPDATE_OVERRIDE' THEN
       END IF; -- IF p_action <> c_verify THEN
      ELSE --code should never reach here
         l_proc_step    := 100;

         IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
         END IF;
      END IF; --IF csr_abv_exists%NOTFOUND

      CLOSE csr_abv_exists;
      l_proc_step    := 110;

      IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug(   'l_effective_abv_row.assignment_budget_value_id:'
               || l_effective_abv_row.assignment_budget_value_id
              );
         debug(   'l_effective_abv_row.object_version_number:'
               || l_effective_abv_row.object_version_number
              );
         debug(   'l_effective_abv_row.effective_start_date:'
               || fnd_date.date_to_canonical(l_effective_abv_row.effective_start_date
                                            )
              );
         debug(   'l_effective_abv_row.effective_end_date:'
               || fnd_date.date_to_canonical(l_effective_abv_row.effective_end_date
                                            )
              );
         debug('l_effective_abv_row.value:' || l_effective_abv_row.VALUE);
         debug('ROUND(p_abv_value,5):' || ROUND(p_abv_value, 5));
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END update_and_store_abv;

/* ------------------------------------------------------------ */
/* --------------------- Deinitialise ------------------------- */
/* ------------------------------------------------------------ */
   PROCEDURE deinitialization_code(p_pay_action_id IN NUMBER)
   IS
-- Cursor to fetch assignment actions that are set to status
-- complete
      CURSOR csr_get_comp_asg_acts
      IS
         SELECT assignment_action_id
           FROM pay_assignment_actions
          WHERE payroll_action_id = p_pay_action_id AND action_status = 'C';

-- Cursor to get count of assignment actions for
-- a given payroll action
      CURSOR csr_get_asg_act_cnt
      IS
         SELECT COUNT(*)
           FROM pay_assignment_actions
          WHERE payroll_action_id = p_pay_action_id;

      l_proc_step       NUMBER(38, 10) := 0;
      l_proc_name       VARCHAR2(61)
                                 := g_package_name || 'deinitialization_code';
      l_asg_action_id   NUMBER;
      l_count           NUMBER;
   BEGIN
      IF g_debug
      THEN
         debug_enter(l_proc_name);
         debug('p_pay_action_id: ' || p_pay_action_id);
      END IF;

/* Comment the following as we do not want to
   delete assignment actions

l_proc_step    := 10;
-- Get the assignment actions
 OPEN csr_get_comp_asg_acts;
 LOOP
     FETCH csr_get_comp_asg_acts INTO l_asg_action_id;
     EXIT WHEN csr_get_comp_asg_acts%NOTFOUND;

     -- Delete from pay_action_interlocks
      IF g_debug
         THEN
            debug(l_proc_name, l_proc_step);
            debug('l_asg_action_id: ' || l_asg_action_id);
      END IF;

      l_proc_step    := 20;
      DELETE FROM pay_action_interlocks
               WHERE locking_action_id = l_asg_action_id;

      IF g_debug
       THEN
          debug(l_proc_name, l_proc_step);
          debug(SQL%ROWCOUNT || ' pay_action_interlocks rows deleted');
      END IF;

      l_proc_step    := 30;
      -- Delete from pay_message_lines
      DELETE FROM pay_message_lines
            WHERE source_id = l_asg_action_id AND source_type = 'A';

      IF g_debug
        THEN
          debug(l_proc_name, l_proc_step);
          debug(SQL%ROWCOUNT || ' pay_message_lines rows deleted');
      END IF;

      l_proc_step    := 40;
      -- Delete from assignment actions
      DELETE FROM pay_assignment_actions
             WHERE assignment_action_id = l_asg_action_id;

      IF g_debug
       THEN
          debug(l_proc_name, l_proc_step);
          debug(SQL%ROWCOUNT || ' pay_assignment_action rows deleted');
      END IF;
 END LOOP;
CLOSE csr_get_comp_asg_acts;

l_proc_step    := 50;
l_count        := NULL;
 OPEN csr_get_asg_act_cnt;
FETCH csr_get_asg_act_cnt INTO l_count;
CLOSE csr_get_asg_act_cnt;

IF g_debug
  THEN
    debug(l_proc_name, l_proc_step);
    debug('l_count: ' || l_count);
END IF;

IF l_count = 0
   THEN
   -- Delete underlying tables
     l_proc_step    := 60;

     DELETE FROM pay_message_lines
           WHERE source_id = p_pay_action_id AND source_type = 'P';

     IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug(SQL%ROWCOUNT || ' pay_message_lines rows deleted');
     END IF;

     -- Delete pay_population_ranges
     l_proc_step    := 70;

     DELETE FROM pay_population_ranges
               WHERE payroll_action_id = p_pay_action_id;

     IF g_debug
       THEN
         debug(l_proc_name, l_proc_step);
         debug(SQL%ROWCOUNT || ' pay_population_ranges rows deleted');
     END IF;

     -- Delete pay_payroll_actions
     l_proc_step    := 80;
     DELETE FROM pay_payroll_actions
               WHERE payroll_action_id = p_pay_action_id;

     IF g_debug
      THEN
         debug(l_proc_name, l_proc_step);
         debug(SQL%ROWCOUNT || ' pay_payroll_actions rows deleted');
     END IF;
 END IF; -- End if of l_count = 0 check ...

*/
      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;

      hr_utility.trace_off;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               debug('Leaving: ' || l_proc_name, -999);
            END IF;

            hr_utility.raise_error;
         ELSE
            RAISE;
         END IF;
   END deinitialization_code;
END pqp_budget_maintenance;

/
