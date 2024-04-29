--------------------------------------------------------
--  DDL for Package Body PQP_GB_CPX_EXTRACT_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_CPX_EXTRACT_FUNCTIONS" 
--  /* $Header: pqpgbcpx.pkb 120.8.12010000.5 2009/10/22 05:37:22 nchinnam ship $ */
AS

--

-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE DEBUG (
      p_trace_message    IN   VARCHAR2,
      p_trace_location   IN   NUMBER DEFAULT NULL
   )
   IS

--
      l_padding              VARCHAR2 (12);
      l_max_message_length   NUMBER        := 72;

--
   BEGIN
      --
      IF p_trace_location IS NOT NULL
      THEN
         l_padding := SUBSTR (
                         RPAD (' ', LEAST (g_nested_level, 5) * 2, ' '),
                         1,
                           l_max_message_length
                         - LEAST (
                              LENGTH (p_trace_message),
                              l_max_message_length
                           )
                      );
         hr_utility.set_location (
               l_padding
            || SUBSTR (
                  p_trace_message,
                  GREATEST (-LENGTH (p_trace_message), -l_max_message_length)
               ),
            p_trace_location
         );
      ELSE
         hr_utility.TRACE (SUBSTR (p_trace_message, 1, 250));
      END IF;
   --

   END DEBUG;


--
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE DEBUG (p_trace_number IN NUMBER)
   IS

--
   BEGIN
      --
      DEBUG (fnd_number.number_to_canonical (p_trace_number));
   --

   END DEBUG;


--
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE DEBUG (p_trace_date IN DATE)
   IS

--
   BEGIN
      --
      DEBUG (fnd_date.date_to_canonical (p_trace_date));
   --

   END DEBUG;


-- This procedure is used for debug purposes
-- debug_enter checks the debug flag and sets the trace on/off
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_enter >-------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_enter (p_proc_name IN VARCHAR2, p_trace_on IN VARCHAR2)
   IS
      l_extract_attributes   csr_pqp_extract_attributes%ROWTYPE;
      l_business_group_id    per_all_assignments_f.business_group_id%TYPE;
   BEGIN
      IF g_nested_level = 0
      THEN -- swtich tracing on/off at the top level only
         -- Set the trace flag, but only the first time around
         IF g_trace IS NULL
         THEN
            OPEN csr_pqp_extract_attributes;
            FETCH csr_pqp_extract_attributes INTO l_extract_attributes;
            CLOSE csr_pqp_extract_attributes;
            l_business_group_id := fnd_global.per_business_group_id;

            BEGIN
               g_trace :=
                     hruserdt.get_table_value (
                        p_bus_group_id=> l_business_group_id,
                        p_table_name=> l_extract_attributes.user_table_name,
                        p_col_name=> 'Attribute Location Qualifier 1',
                        p_row_value=> 'Debug',
                        p_effective_date=> NULL -- don't hv the date
                     );
            EXCEPTION
               WHEN OTHERS
               THEN
                  g_trace := 'N';
            END;

            g_trace := NVL (g_trace, 'N');
            DEBUG (   'UDT Trace Flag : '
                   || g_trace);
         END IF; -- g_trace IS NULL THEN

         IF    NVL (p_trace_on, 'N') = 'Y'
            OR g_trace = 'Y'
         THEN
            hr_utility.trace_on (NULL, 'REQID'); -- Pipe name REQIDnnnnnn
         END IF; -- NVL(p_trace_on,'N') = 'Y'
      --
      END IF; -- if nested level = 0

      g_nested_level :=   g_nested_level
                        + 1;
      DEBUG (
            'Entered: '
         || NVL (p_proc_name, g_proc_name),
         g_nested_level * 100
      );
   END debug_enter;


-- This procedure is used for debug purposes
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_exit >--------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_exit (p_proc_name IN VARCHAR2, p_trace_off IN VARCHAR2)
   IS
   BEGIN
      DEBUG (
            'Leaving: '
         || NVL (p_proc_name, g_proc_name),
         -g_nested_level * 100
      );
      g_nested_level :=   g_nested_level
                        - 1;

      -- debug enter sets trace ON when g_trace = 'Y' and nested level = 0
      -- so we must turn it off for the same condition
      -- Also turn off tracing when the override flag of p_trace_off has been passed as Y
      IF    (g_nested_level = 0 AND g_trace = 'Y')
         OR NVL (p_trace_off, 'N') = 'Y'
      THEN
         hr_utility.trace_off;
      END IF; -- (g_nested_level = 0
   END debug_exit;


-- This function sets the run dates for periodic type of extract
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_periodic_run_dates >------------------------|
-- ----------------------------------------------------------------------------

   FUNCTION set_periodic_run_dates (
      p_error_number   OUT NOCOPY   NUMBER,
      p_error_text     OUT NOCOPY   VARCHAR2
   )
      RETURN NUMBER
   IS

--
-- Modified cursor for performance fix

      CURSOR csr_last_run_details
        (p_ext_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE)
      IS
         SELECT MAX (
                   TRUNC (rslt.eff_dt)
                ) -- highest effective date of all prev runs
           FROM pqp_extract_attributes pqea,
                ben_ext_rslt rslt,
                ben_ext_rslt_dtl rdtl
--                ben_ext_rcd drcd
          WHERE pqea.ext_dfn_type = g_extract_type
            AND rslt.ext_dfn_id = pqea.ext_dfn_id
            AND rslt.business_group_id = g_business_group_id
            AND rslt.ext_stat_cd NOT IN ('F' -- Job Failure
                                            ,
                                         'R' -- Rejected By User
                                            ,
                                         'X' -- Executing
                                        )
            AND rdtl.ext_rslt_id = rslt.ext_rslt_id
            AND rdtl.ext_rcd_id  = p_ext_rcd_id
--            AND drcd.ext_rcd_id = rdtl.ext_rcd_id
--            AND drcd.rcd_type_cd = 'H'
            AND SUBSTR (
                   rdtl.val_01,
                   1,
                   INSTR (g_header_system_element, ':', 1)
                ) = SUBSTR (
                       g_header_system_element,
                       1,
                       INSTR (g_header_system_element, ':', 1)
                    )
            AND rslt.eff_dt < g_effective_date;

      CURSOR csr_next_run_details
        (p_ext_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE)
      IS
         SELECT MIN (
                   TRUNC (rslt.eff_dt)
                ) -- least effective date of all future runs
           FROM pqp_extract_attributes pqea,
                ben_ext_rslt rslt,
                ben_ext_rslt_dtl rdtl
--                ben_ext_rcd drcd
          WHERE pqea.ext_dfn_type = g_extract_type
            AND rslt.ext_dfn_id = pqea.ext_dfn_id
            AND rslt.business_group_id = g_business_group_id
            AND rdtl.ext_rslt_id = rslt.ext_rslt_id
            AND rdtl.ext_rcd_id = p_ext_rcd_id
--            AND drcd.ext_rcd_id = rdtl.ext_rcd_id
--            AND drcd.rcd_type_cd = 'H'
            AND SUBSTR (
                   rdtl.val_01,
                   1,
                   INSTR (g_header_system_element, ':', 1)
                ) = SUBSTR (
                       g_header_system_element,
                       1,
                       INSTR (g_header_system_element, ':', 1)
                    )
            AND rslt.eff_dt >= g_effective_date; -- include any runs on the same day

      CURSOR csr_get_tax_year_date
      IS
         SELECT TO_DATE (
                      '01-04-'
                   || DECODE (
                         SIGN (
                              TO_NUMBER (TO_CHAR (g_effective_date, 'MM'))
                            - 04
                         ),
                         -1, TO_CHAR (
                                ADD_MONTHS (g_effective_date, -12),
                                'YYYY'
                             ),
                         TO_CHAR (g_effective_date, 'YYYY')
                      ),
                   'DD-MM-YYYY'
                )
           FROM DUAL;

      l_proc_name          VARCHAR2 (60)
                                   :=    g_proc_name
                                      || 'set_periodic_run_date';
      l_initial_ext_date   DATE;
      l_value              pay_user_column_instances_f.value%TYPE;
      l_error_text         VARCHAR2 (200);
      l_ext_rcd_id         NUMBER;
   BEGIN
      debug_enter (l_proc_name);
      DEBUG (TO_CHAR (g_effective_date, 'DD-MON-YYYY'));
      DEBUG (
            'g_effective_date: '
         || fnd_date.date_to_canonical (g_effective_date)
      );
      g_effective_end_date := -- "end of day" of a day before effective date
            fnd_date.canonical_to_date (
                  TO_CHAR (  g_effective_date
                           - 1, 'YYYY/MM/DD')
               || '23:59:59'
            );
      DEBUG (
            'g_effective_end_date: '
         || fnd_date.date_to_canonical (g_effective_end_date)
      );
      -- 11.5.10_CU2: Performance fix :
      -- get the ben_ext_rcd.ext_rcd_id
      -- and use this one for next cursor
      -- This will prevent FTS on the table.

      OPEN csr_ext_rcd_id (p_hide_flag       => 'Y'
                          ,p_rcd_type_cd     => 'H'
                          );
      FETCH csr_ext_rcd_id INTO l_ext_rcd_id;
      CLOSE csr_ext_rcd_id ;

      OPEN csr_last_run_details(l_ext_rcd_id);
      FETCH csr_last_run_details INTO g_effective_start_date;
      DEBUG (
            'g_effective_start_date just after fetch: '
         || fnd_date.date_to_canonical (g_effective_start_date)
      );

      IF    csr_last_run_details%NOTFOUND -- not likely ever bcos of use of MAX
         OR g_effective_start_date IS NULL
      THEN
         DEBUG ('No successful last completed run was found');
         -- Call utility function to get the UDT values
         -- for the initial extract date information only for
         -- Starters and Hour Change reports

         DEBUG ('Get Initial Extract Date');
         DEBUG ('Calling function pqp_gb_get_table_value');

         IF pqp_utilities.pqp_gb_get_table_value (
               p_business_group_id=> g_business_group_id,
               p_effective_date=> g_effective_date,
               p_table_name=> g_extract_udt_name,
               p_column_name=> 'Initial Extract Date',
               p_row_name=> 'Criteria Date',
               p_value=> l_value,
               p_error_msg=> l_error_text
            ) <> 0
         THEN
            DEBUG (   'Function in Error: '
                   || l_error_text);
            p_error_text := l_error_text;
            debug_exit (l_proc_name);
            RETURN -1;
         END IF; -- End if of function in error check ...
         l_initial_ext_date := fnd_date.displaydate_to_date(l_value);

         DEBUG (   'Initial Extract Date: '
                || TO_CHAR(l_initial_ext_date, 'DD-MM-YYYY'));
         DEBUG ('End of call to function pqp_gb_get_table_value');

         IF l_initial_ext_date IS NULL
         THEN
            -- Get tax year date
            DEBUG ('Get Tax year date');
            OPEN csr_get_tax_year_date;
            FETCH csr_get_tax_year_date INTO g_initial_ext_date;
            CLOSE csr_get_tax_year_date;
         ELSE
            g_initial_ext_date := l_initial_ext_date;
         END IF; -- End if of intial extract date check ...

         DEBUG (   'Initial Extract Date: '
                || TO_CHAR(g_initial_ext_date, 'DD-MM-YYYY'));
         g_effective_start_date := g_initial_ext_date;

         IF g_effective_start_date IS NULL
         THEN -- use tax year first of april
            SELECT TO_DATE (
                         '01-04-'
                      || DECODE (
                            SIGN (
                                 TO_NUMBER (TO_CHAR (g_effective_date, 'MM'))
                               - 04
                            ),
                            -1, TO_CHAR (
                                   ADD_MONTHS (g_effective_date, -12),
                                   'YYYY'
                                ),
                            TO_CHAR (g_effective_date, 'YYYY')
                         ),
                      'DD-MM-YYYY'
                   )
              INTO g_effective_start_date
              FROM DUAL;
         END IF; -- End if of g_effective_start_date is Null check ...
      END IF; -- End if of csr_last_run_details not found check ...

      IF g_effective_start_date > g_effective_end_date
      THEN
         -- Reduce the effective start date by a year
         -- this can happen when the effective date is
         -- the same as tax year date '01-04'
         DEBUG ('Start date greater than end date - Reduce it');
         g_effective_start_date := ADD_MONTHS (g_effective_start_date, -12);
      END IF; -- g_effective_start_date > g_effective_end_date check ...

      CLOSE csr_last_run_details;
      DEBUG (
            'g_effective_start_date: '
         || fnd_date.date_to_canonical (g_effective_start_date)
      );
      OPEN csr_next_run_details(l_ext_rcd_id);
      FETCH csr_next_run_details INTO g_next_effective_date;
      CLOSE csr_next_run_details;
      DEBUG (
            'g_next_effective_date: '
         || fnd_date.date_to_canonical (g_next_effective_date)
      );
      g_header_system_element :=
               g_header_system_element
            || fnd_date.date_to_canonical (g_effective_start_date)
            || ':'
            || fnd_date.date_to_canonical (g_effective_end_date)
            || ':'
            || fnd_date.date_to_canonical (g_next_effective_date)
            || ':';
      DEBUG (   'g_header_system_element: '
             || g_header_system_element);
      debug_exit (l_proc_name);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others Exception'
                || l_proc_name);
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END set_periodic_run_dates;


-- This procedure sets the run dates for annual type CPX extract
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_annual_run_dates >--------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE set_annual_run_dates
   IS
      l_year        NUMBER;
      l_proc_name   VARCHAR2 (61) := 'set_annual_run_dates';
   BEGIN
      debug_enter (l_proc_name);
      DEBUG (TO_CHAR (g_effective_date, 'DD-MON-YYYY'));
      DEBUG (
            'g_effective_date: '
         || fnd_date.date_to_canonical (g_effective_date)
      );
      g_effective_end_date := g_effective_date;
      g_effective_start_date := ADD_MONTHS ((  g_effective_date
                                             + 1
                                            ), -12);
      DEBUG (
            'g_effective_start_date: '
         || fnd_date.date_to_canonical (g_effective_start_date)
      );
      DEBUG (
            'g_effective_end_date: '
         || fnd_date.date_to_canonical (g_effective_end_date)
      );
      g_header_system_element :=
               g_header_system_element
            || fnd_date.date_to_canonical (g_effective_start_date)
            || ':'
            || fnd_date.date_to_canonical (g_effective_end_date)
            || ':'
            || fnd_date.date_to_canonical (g_effective_date)
            || ':';
      DEBUG (   'g_header_system_element: '
             || g_header_system_element);
      debug_exit (l_proc_name);
   END set_annual_run_dates;


-- This function returns the input value id for a given element type id
-- and input value name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_input_value_id >--------------------------|
-- ----------------------------------------------------------------------------

   FUNCTION get_input_value_id (
      p_element_type_id    IN   NUMBER,
      p_input_value_name   IN   VARCHAR2,
      p_effective_date     IN   DATE
   )
      RETURN NUMBER
   IS

--
      l_proc_name        VARCHAR2 (60)
                                      :=    g_proc_name
                                         || 'get_input_value_id';
      l_input_value_id   pay_input_values_f.input_value_id%TYPE;

--
   BEGIN
      debug_enter (l_proc_name);
      OPEN csr_get_pay_iv_id (
         p_element_type_id,
         p_input_value_name,
         p_effective_date
      );
      FETCH csr_get_pay_iv_id INTO l_input_value_id;
      CLOSE csr_get_pay_iv_id;
      DEBUG (
            p_input_value_name
         || ' Input Value ID: '
         || TO_CHAR (l_input_value_id)
      );
      debug_exit (l_proc_name);
      RETURN l_input_value_id;
   END get_input_value_id;


-- This function gets the balance type id for a given balance name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_pay_bal_id >------------------------------|
-- ----------------------------------------------------------------------------

   FUNCTION get_pay_bal_id (p_balance_name IN VARCHAR2)
      RETURN NUMBER
   IS

--
      l_proc_name     VARCHAR2 (60)             :=    g_proc_name
                                                   || 'get_pay_bal_id';
      l_bal_type_id   csr_get_pay_bal_id%ROWTYPE;

--
   BEGIN
      debug_enter (l_proc_name);
      OPEN csr_get_pay_bal_id (c_balance_name => p_balance_name);
      FETCH csr_get_pay_bal_id INTO l_bal_type_id;
      CLOSE csr_get_pay_bal_id;
      DEBUG (
            p_balance_name
         || ' Balance ID: '
         || TO_CHAR (l_bal_type_id.balance_type_id)
      );
      debug_exit (l_proc_name);
      RETURN l_bal_type_id.balance_type_id;
   END get_pay_bal_id;


-- This function returns the element type id's  as collectionfrom the balance
-- accepting the balance type id
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_pay_ele_ids_from_bal >---------------------|
-- ----------------------------------------------------------------------------

   FUNCTION get_pay_ele_ids_from_bal (
      p_balance_type_id        IN              NUMBER,
      p_effective_start_date   IN              DATE,
      p_effective_end_date     IN              DATE,
      p_tab_ele_ids            OUT NOCOPY      t_ele_ids_from_bal,
      p_error_number           OUT NOCOPY      NUMBER,
      p_error_text             OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS

--
      l_proc_name    VARCHAR2 (60)
                                :=    g_proc_name
                                   || 'get_pay_ele_ids_from_bal';
      l_iv_ids       csr_get_pay_iv_ids_from_bal%ROWTYPE;
      l_ele_ids      csr_get_pay_ele_ids_from_bal%ROWTYPE;
      l_error_text   VARCHAR2 (200);
      l_return       NUMBER                                 := 0;

--
   BEGIN
      debug_enter (l_proc_name);
      OPEN csr_get_pay_iv_ids_from_bal (
         c_balance_type_id=> p_balance_type_id,
         c_effective_start_date=> p_effective_start_date,
         c_effective_end_date=> p_effective_end_date
      );

      LOOP
         FETCH csr_get_pay_iv_ids_from_bal INTO l_iv_ids;
         EXIT WHEN csr_get_pay_iv_ids_from_bal%NOTFOUND;
         --
         OPEN csr_get_pay_ele_ids_from_bal (l_iv_ids.input_value_id);
         FETCH csr_get_pay_ele_ids_from_bal INTO l_ele_ids;

         IF csr_get_pay_ele_ids_from_bal%FOUND
         THEN
            p_tab_ele_ids (l_ele_ids.element_type_id) := l_ele_ids;
         END IF; -- End if of get pay ele ids found check ...

         CLOSE csr_get_pay_ele_ids_from_bal;
      --
      END LOOP;

      IF csr_get_pay_iv_ids_from_bal%ROWCOUNT = 0
      THEN
         DEBUG ('Balance feeds not found');
         p_error_number := 93342;
         p_error_text := 'BEN_93342_EXT_CPX_BAL_NOFEEDS';
         l_return := -1;
      END IF;

      CLOSE csr_get_pay_iv_ids_from_bal;
      debug_exit (l_proc_name);
      RETURN l_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others Exception'
                || l_proc_name);
         p_tab_ele_ids.DELETE;
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END get_pay_ele_ids_from_bal;


-- This function fetches the details from the CPX extract definition UDT
--
-- ----------------------------------------------------------------------------
-- |---------------------------< fetch_CPX_UDT_details >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION fetch_cpx_udt_details (
      p_error_number   OUT NOCOPY   NUMBER,
      p_error_text     OUT NOCOPY   VARCHAR2
   )
      RETURN NUMBER
   IS
      --

      l_proc_name             VARCHAR2 (61)
                                   :=    g_proc_name
                                      || 'fetch_CPX_UDT_details';
      l_initial_ext_date      DATE;
      l_pension_source_type   pay_user_column_instances_f.VALUE%TYPE;
      l_pension_source_name   pay_user_column_instances_f.VALUE%TYPE;
      i                       NUMBER;
      l_row_name              t_varchar2;
      l_value                 t_varchar2;
      l_error_text            VARCHAR2 (200);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Call utility function to get the UDT values
      -- for the Pension Scheme Name

      DEBUG ('Get Pension Scheme Source Type');
      DEBUG ('Calling function pqp_gb_get_table_value');

      IF pqp_utilities.pqp_gb_get_table_value (
            p_business_group_id=> g_business_group_id,
            p_effective_date=> g_effective_date,
            p_table_name=> g_extract_udt_name,
            p_column_name=> 'Attribute Location Type',
            p_row_name=> 'Pension Schemes',
            p_value=> l_pension_source_type,
            p_error_msg=> l_error_text
         ) <> 0
      THEN
         DEBUG (   'Function in Error: '
                || l_error_text);
         p_error_text := l_error_text;
         RETURN -1;
      END IF; -- End if of function in error check ...

      DEBUG (   'Pension Scheme Source Type: '
             || l_pension_source_type);
      DEBUG ('End of call to function pqp_gb_get_table_value');

      -- Check whether a pension source type is specified in the
      -- UDT

      IF l_pension_source_type IS NULL
      THEN
         -- Raise Extract Error, as this information is mandatory

         DEBUG ('Raise Error no pension source type');
         debug_exit (l_proc_name);
         p_error_text := 'BEN_93344_EXT_CPX_UDT_NOPEN_SR';
         p_error_number := 93344;
         RETURN -1;
      END IF; -- End if of pension source type is null check ...

      DEBUG ('Get Pension Scheme Source Name');
      DEBUG ('Calling function pqp_gb_get_table_value');

      IF pqp_utilities.pqp_gb_get_table_value (
            p_business_group_id=> g_business_group_id,
            p_effective_date=> g_effective_date,
            p_table_name=> g_extract_udt_name,
            p_column_name=> 'Attribute Location Qualifier 1',
            p_row_name=> 'Pension Schemes',
            p_value=> l_pension_source_name,
            p_error_msg=> l_error_text
         ) <> 0
      THEN
         DEBUG (   'Function in Error: '
                || l_error_text);
         p_error_text := l_error_text;
         debug_exit (l_proc_name);
         RETURN -1;
      END IF; -- End if of function in error check ...

      DEBUG (   'Pension Scheme Source Name: '
             || l_pension_source_name);
      DEBUG ('End of call to function pqp_gb_get_table_value');

      -- Check whether the pension source type is element
      -- and whether an element name is provided in the UDT

      IF  l_pension_source_type = 'Element' AND l_pension_source_name IS NULL
      THEN
         -- Raise Extract Error, as this information is mandatory

         DEBUG ('Raise Error pension source name is missing');
         p_error_text := 'BEN_93345_EXT_CPX_UDT_NO_ELENM';
         p_error_number := 93345;
         debug_exit (l_proc_name);
         RETURN -1;
      ELSIF l_pension_source_type = 'Balance'
      THEN
         -- Elsif of source type = element ...

         g_pension_bal_name :=
                    NVL (l_pension_source_name, 'Total Pension Contributions');
         DEBUG (   'Pension Balance Name: '
                || g_pension_bal_name);
      ELSE -- Else of source type = Element ...
         g_pension_ele_name := l_pension_source_name;
         DEBUG (   'Pension Element Name: '
                || g_pension_ele_name);
      END IF; -- End if of pension source type = element check ...

      -- Get the Employee Contribution input value information
      -- from the UDT

      i := 0;
      i :=   i
           + 1;
      l_row_name (i) := 'Employee Contribution';
      i :=   i
           + 1;
      l_row_name (i) := 'Superannuation Reference Number';

      FOR i IN 1 .. l_row_name.COUNT
      LOOP
         DEBUG (   'Get '
                || l_row_name (i)
                || ' information');
         DEBUG ('Calling function pqp_gb_get_table_value');

         IF pqp_utilities.pqp_gb_get_table_value (
               p_business_group_id=> g_business_group_id,
               p_effective_date=> g_effective_date,
               p_table_name=> g_extract_udt_name,
               p_column_name=> 'Attribute Location Qualifier 1',
               p_row_name=> l_row_name (i),
               p_value=> l_value (i),
               p_error_msg=> l_error_text
            ) <> 0
         THEN
            DEBUG (   'Function in Error: '
                   || l_error_text);
            p_error_text := l_error_text;
            debug_exit (l_proc_name);
            RETURN -1;
         END IF; -- End if of function in error check ...

         DEBUG ('End of call to function pqp_gb_get_table_value');
         DEBUG (   l_row_name (i)
                || ' value is: '
                || l_value (i));

         IF l_value (i) IS NULL
         THEN
            -- Raise Extract Error, as this information is mandatory
            -- now made optional

            DEBUG ('Raise Error');
            p_error_text := 'BEN_93343_EXT_CPX_UDT_NO_IV';
            p_error_number := 93343;
         -- raise just a warning message
         -- debug_exit (l_proc_name);
         -- RETURN -1;
         END IF; -- End if of l_value(i) is null check ...
      END LOOP; -- End loop of l_row_name ...

      i := 0;
      i :=   i
           + 1;
      g_emp_cont_iv_name := l_value (i);
      i :=   i
           + 1;
      g_superann_refno_iv_name := l_value (i);
      i := 0;
      l_row_name.DELETE;
      l_value.DELETE;
      i :=   i
           + 1;
      l_row_name (i) := 'Superannuable Salary';
      i :=   i
           + 1;
      l_row_name (i) := 'Additional Contributions';
      i :=   i
           + 1;
      l_row_name (i) := 'Buy-Back Contributions';

      FOR i IN 1 .. l_row_name.COUNT
      LOOP
         DEBUG (   'Get '
                || l_row_name (i)
                || ' information');
         DEBUG ('Calling function pqp_gb_get_table_value');

         IF pqp_utilities.pqp_gb_get_table_value (
               p_business_group_id=> g_business_group_id,
               p_effective_date=> g_effective_date,
               p_table_name=> g_extract_udt_name,
               p_column_name=> 'Attribute Location Qualifier 1',
               p_row_name=> l_row_name (i),
               p_value=> l_value (i),
               p_error_msg=> l_error_text
            ) <> 0
         THEN
            DEBUG (   'Function in Error: '
                   || l_error_text);
            p_error_text := l_error_text;
            debug_exit (l_proc_name);
            RETURN -1;
         END IF; -- End if of function in error check ...

         DEBUG ('End of call to function pqp_gb_get_table_value');
         DEBUG (   l_row_name (i)
                || ' value is: '
                || l_value (i));
      END LOOP; -- End loop of l_row_name ...

      i := 0;
      i :=   i
           + 1;
      g_superann_sal_bal_name := NVL (l_value (i), 'Superannuable Salary');
      i :=   i
           + 1;
      g_additional_cont_bal_name :=
                            NVL (l_value (i), 'Total Additional Contributions');
      i :=   i
           + 1;
      g_buyback_cont_bal_name :=
                               NVL (l_value (i), 'Total BuyBack Contributions');
      debug_exit (l_proc_name);
      RETURN 0;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   'Others Exception Raised'
                || l_proc_name);
         p_error_text := SQLERRM;
         p_error_number := SQLCODE;
         RAISE;
   END fetch_cpx_udt_details;


-- This function sets the extract global variables
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_extract_globals >------------------------|
-- ----------------------------------------------------------------------------

   FUNCTION set_extract_globals (
      p_assignment_id       IN              NUMBER,
      p_business_group_id   IN              NUMBER,
      p_effective_date      IN              DATE,
      p_error_number        OUT NOCOPY      NUMBER,
      p_error_text          OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS

--
      l_proc_name          VARCHAR2 (60)
                                     :=    g_proc_name
                                        || 'set_extract_globals';
      l_element_type_id    NUMBER;
      l_input_value_name   t_varchar2;
      l_input_value_id     pay_input_values_f.input_value_id%TYPE;
      l_bal_type_name      t_varchar2;
      l_bal_type_id        t_number;
      i                    NUMBER;
      j                    NUMBER;
      l_error_number       NUMBER;
      l_error_text         VARCHAR2 (200);
      l_return             NUMBER;

--
   BEGIN
      debug_enter (l_proc_name);
      DEBUG (   'Business Group ID: '
             || p_business_group_id);
      g_business_group_id := p_business_group_id;
      DEBUG (   'Effective Date: '
             || p_effective_date);
      g_effective_date := p_effective_date;
      OPEN csr_pqp_extract_attributes;
      FETCH csr_pqp_extract_attributes INTO g_extract_type, g_extract_udt_name;
      CLOSE csr_pqp_extract_attributes;
      --
      -- Based on extract type set the effective dates accordingly
      --

      DEBUG (   'Extract Type: '
             || g_extract_type);

      IF g_extract_type = 'LYNX_ANNUAL'
      THEN
         DEBUG ('Before calling procedure set_annual_run_dates');
         set_annual_run_dates;
      ELSE -- Else of extract type = Annual
         DEBUG ('Before calling function set_periodic_run_dates');
         l_return := set_periodic_run_dates (
                        p_error_number=> l_error_number,
                        p_error_text=> l_error_text
                     );

         IF l_return <> 0
         THEN
            -- Raise error
            DEBUG ('Raise Error');
            p_error_text := l_error_text;
            p_error_number := l_error_number;
            debug_exit (l_proc_name);
            RETURN -1;
         END IF; -- End if of set_periodic_run func for error check ...
      END IF; -- End if of extract type = Annual check ...

      DEBUG ('Before calling function fetch_CPX_UDT_details');
      l_return := fetch_cpx_udt_details (
                     p_error_number=> l_error_number,
                     p_error_text=> l_error_text
                  );

      IF l_return <> 0
      THEN
         -- Raise error
         DEBUG ('Raise Error');
         p_error_text := l_error_text;
         p_error_number := l_error_number;
         debug_exit (l_proc_name);
         RETURN -1;
      END IF; -- End if of fetch_UDT_details func for error check ...

      IF l_error_number = 93343
      THEN
         -- Raise just a warning message
         l_return :=
               pqp_gb_tp_extract_functions.raise_extract_warning (
                  p_assignment_id=> p_assignment_id,
                  p_error_text=> l_error_text,
                  p_error_number=> l_error_number
               );
      END IF; -- End if of error number check ...

      --
      -- Populate the collection with pension elements
      --

      --
      -- Check whether the user have specified a balance or element
      -- for their pension schemes in the UDT
      --

      IF g_pension_bal_name IS NULL
      THEN
         --
         -- The users have specified an element name
         --
         DEBUG ('Element Name specified in the UDT');
         -- Get element type id
         DEBUG ('Get element type id');
         OPEN csr_get_pay_ele_id (g_pension_ele_name, g_effective_date);
         FETCH csr_get_pay_ele_id INTO l_element_type_id;

         IF csr_get_pay_ele_id%NOTFOUND
         THEN
            DEBUG (   'Element: '
                   || g_pension_ele_name
                   || ' does not exist');
            -- Raise error
            DEBUG ('Raise Error');
            p_error_text := 'BEN_93347_EXT_CPX_ELE_NOTEXIST';
            p_error_number := 93347;
            debug_exit (l_proc_name);
            RETURN -1;
         END IF; -- End if of element exists check ...

         CLOSE csr_get_pay_ele_id;
         g_pension_ele_ids (l_element_type_id).element_type_id :=
                                                             l_element_type_id;
         DEBUG (   'Element Name: '
                || g_pension_ele_name);
         DEBUG (   'Element type id: '
                || TO_CHAR (l_element_type_id));
      ELSE -- Pension balance Name is specified
         DEBUG ('Balance name exists');
         -- Get the balance type id

         DEBUG (
               'Get the balance type id for balance '
            || g_pension_bal_name
         );
         g_pension_bal_id :=
                        get_pay_bal_id (p_balance_name => g_pension_bal_name);

         IF g_pension_bal_id IS NOT NULL
         THEN
            --
            DEBUG (   'Pension Balance Id: '
                   || g_pension_bal_id);
            DEBUG ('Before calling procedure get_pay_ele_ids_from_bal');
            --
            --
            -- Get Pension Scheme Elements
            --
            l_return :=
                  get_pay_ele_ids_from_bal (
                     p_balance_type_id=> g_pension_bal_id,
                     p_effective_start_date=> g_effective_start_date,
                     p_effective_end_date=> g_effective_end_date,
                     p_tab_ele_ids=> g_pension_ele_ids,
                     p_error_number=> l_error_number,
                     p_error_text=> l_error_text
                  );

            IF l_return <> 0
            THEN
               -- Raise error
               DEBUG ('Raise Error');
               p_error_number := l_error_number;
               p_error_text := l_error_text;
               debug_exit (l_proc_name);
               RETURN -1;
            END IF; -- End if of pay ele ids in error check ...
         ELSE -- Else pension bal id is null ...
            DEBUG ('Pension Balance Id is Null');
            DEBUG ('Raise Error');
            p_error_text := 'BEN_93348_EXT_CPX_BAL_NOTEXIST';
            p_error_number := 93348;
            debug_exit (l_proc_name);
            RETURN -1;
         END IF; -- End if of pension bal id check...
      END IF; -- End if of pension balance name is null check ...

      -- Populate the input value id's for superannuation reference number
      -- and Employee contribution

      IF    g_emp_cont_iv_name IS NOT NULL
         OR g_superann_refno_iv_name IS NOT NULL
      THEN
         i := g_pension_ele_ids.FIRST;

         WHILE i IS NOT NULL
         LOOP
            DEBUG (   'Element Type ID: '
                   || TO_CHAR (i));
            j := 0;

            IF g_emp_cont_iv_name IS NOT NULL
            THEN
               j :=   j
                    + 1;
               l_input_value_name (j) := g_emp_cont_iv_name;
            END IF; -- End if of emp cont iv not null check ...

            IF g_superann_refno_iv_name IS NOT NULL
            THEN
               j :=   j
                    + 1;
               l_input_value_name (j) := g_superann_refno_iv_name;
            END IF; -- End if of super ann not null check ...

            FOR j IN 1 .. l_input_value_name.COUNT
            LOOP
               -- Get input value id for the input value name
               DEBUG (   'Get input value id for '
                      || l_input_value_name (j));
               DEBUG ('Before calling get_input_value_id procedure');
               l_input_value_id := NULL;
               l_input_value_id :=
                     get_input_value_id (
                        p_element_type_id=> g_pension_ele_ids (i).element_type_id,
                        p_input_value_name=> l_input_value_name (j),
                        p_effective_date=> g_effective_date
                     );
               DEBUG (
                     'Input value id for '
                  || l_input_value_name (j)
                  || TO_CHAR (l_input_value_id)
               );

               -- Check whether input value exists

               IF l_input_value_id IS NULL
               THEN
                  DEBUG ('Input value does not exist Raise error');
                  p_error_text := 'BEN_93346_EXT_CPX_IV_NOT_EXIST';
                  p_error_number := 93346;
                  debug_exit (l_proc_name);
                  RETURN -1;
               END IF; -- End if of input value exists check ...
            END LOOP; -- End loop for j counter (input value names) ...

            i := g_pension_ele_ids.NEXT (i);
         END LOOP; -- End loop for i counter (element type id's) ...
      END IF; -- End if of check whether any of ip val is not null ...

      -- Get balance type id's for Additional and Buy-Back Contribution
      -- balances

      DEBUG ('Get balance type ids for additional and buy-back contribution');
      i := 0;
      i :=   i
           + 1;
      l_bal_type_name (i) := g_superann_sal_bal_name;
      i :=   i
           + 1;
      l_bal_type_name (i) := g_additional_cont_bal_name;
      i :=   i
           + 1;
      l_bal_type_name (i) := g_buyback_cont_bal_name;

      FOR i IN 1 .. l_bal_type_name.COUNT
      LOOP
         DEBUG (
               'Get the balance type id for balance '
            || l_bal_type_name (i)
         );
         l_bal_type_id (i) :=
                       get_pay_bal_id (p_balance_name => l_bal_type_name (i));
         DEBUG (   'Balance type id is : '
                || TO_CHAR (l_bal_type_id (i)));

         IF l_bal_type_id (i) IS NULL
         THEN
            DEBUG ('Balance does not exist Raise error');
            p_error_number := 93348;
            p_error_text := 'BEN_93348_EXT_CPX_BAL_NOTEXIST';
            debug_exit (l_proc_name);
            RETURN -1;
         END IF; -- End if of balance type id is null check ...
      END LOOP;

      i := 0;
      i :=   i
           + 1;
      g_superann_sal_bal_id := l_bal_type_id (i);
      i :=   i
           + 1;
      g_additional_cont_bal_id := l_bal_type_id (i);
      i :=   i
           + 1;
      g_buyback_cont_bal_id := l_bal_type_id (i);

      -- Bug 4721921 Fix
      OPEN csr_get_pay_ele_id ('NI', g_effective_date);
      FETCH csr_get_pay_ele_id INTO l_element_type_id;
      CLOSE csr_get_pay_ele_id;
      g_ni_ele_type_id := l_element_type_id;
      DEBUG (   'Element Name: NI');
      DEBUG (   'Element type id: '
             || TO_CHAR (l_element_type_id));

      g_ni_cat_iv_id := get_input_value_id
                          (p_element_type_id  => g_ni_ele_type_id
                          ,p_input_value_name => 'Category'
                          ,p_effective_date   => g_effective_date
                          );

      DEBUG ('g_ni_cat_iv_id: '|| g_ni_cat_iv_id);
--       g_ni_pen_iv_id := get_input_value
--                           (p_element_type_id  => g_ni_ele_type_id
--                           ,p_input_value_name => 'Pension'
--                           ,p_effective_date   => g_effective_date
--                           );
--       DEBUG ('g_ni_pen_iv_id : '|| g_ni_pen_iv_id);

       DEBUG ('Before calling get_NI_cont_out_ele_details function');
       l_return :=
             get_ni_cont_out_ele_details (
                p_error_number=> l_error_number,
                p_error_text=> l_error_text
             );

       IF l_return <> 0
       THEN
          DEBUG (
             'Function get_NI_cont_out_ele_details function is in Error'
          );
          p_error_text := l_error_text;
          p_error_number := l_error_number;
          debug_exit (l_proc_name);
          RETURN -1;
       END IF; -- End if of return <> 0 check...


      -- Bug 4721921 Fix End

      debug_exit (l_proc_name);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   'Others Exception Raised'
                || l_proc_name);
         p_error_text := SQLERRM;
         p_error_number := SQLCODE;
         RAISE;
   END set_extract_globals;


-- This function returns the udt id for a given udt name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_udt_id >---------------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_udt_id (p_udt_name IN VARCHAR2)
      RETURN NUMBER
   IS

--

      l_proc_name   VARCHAR2 (60) :=    g_proc_name
                                     || 'get_udt_id';
      l_udt_id      NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      OPEN csr_get_udt_id (p_udt_name);
      FETCH csr_get_udt_id INTO l_udt_id;
      DEBUG (   'UDT ID: '
             || l_udt_id);
      CLOSE csr_get_udt_id;
      DEBUG (   p_udt_name
             || ' UDT ID: '
             || TO_CHAR (l_udt_id));
      debug_exit (l_proc_name);
      RETURN l_udt_id;
   END get_udt_id;


-- This function returns the user row id for a given udt id and user row
-- name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_user_row_id >----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_user_row_id (
      p_user_table_id   IN   NUMBER,
      p_user_row_name   IN   VARCHAR2,
      p_effective_date  IN   DATE
   )
      RETURN NUMBER
   IS

--

      l_proc_name     VARCHAR2 (60) :=    g_proc_name
                                       || 'get_user_row_id';
      l_user_row_id   NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      OPEN csr_get_user_row_id (p_user_table_id, p_user_row_name, p_effective_date);
      FETCH csr_get_user_row_id INTO l_user_row_id;
      DEBUG (   'User Row ID: '
             || l_user_row_id);
      CLOSE csr_get_user_row_id;
      DEBUG (
            p_user_row_name
         || ' User Row ID: '
         || TO_CHAR (l_user_row_id)
      );
      debug_exit (l_proc_name);
      RETURN l_user_row_id;
   END get_user_row_id;


-- This function returns the user column id for a given udt id and user column
-- name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_user_column_id >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_user_column_id (
      p_user_table_id   IN   NUMBER,
      p_user_col_name   IN   VARCHAR2
   )
      RETURN NUMBER
   IS

--

      l_proc_name     VARCHAR2 (60) :=    g_proc_name
                                       || 'get_user_column_id';
      l_user_col_id   NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      OPEN csr_get_user_column_id (p_user_table_id, p_user_col_name);
      FETCH csr_get_user_column_id INTO l_user_col_id;
      DEBUG (   'User Column ID: '
             || l_user_col_id);
      CLOSE csr_get_user_column_id;
      DEBUG (
            p_user_col_name
         || ' User Column ID: '
         || TO_CHAR (l_user_col_id)
      );
      debug_exit (l_proc_name);
      RETURN l_user_col_id;
   END get_user_column_id;


-- This function returns the user column name for a given user table id and
-- user row id
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_user_column_name >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_user_column_name (
      p_user_table_id    IN   NUMBER,
      p_user_row_id      IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN t_varchar2
   IS

--

      l_proc_name       VARCHAR2 (60)
                                    :=    g_proc_name
                                       || 'get_user_column_name';
      l_user_col_name   pay_user_columns.user_column_name%TYPE;
      l_user_col_coll   t_varchar2;
      i                 NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      i := 0;
      OPEN csr_get_user_col_name (
         p_user_table_id,
         p_user_row_id,
         p_effective_date
      );

      LOOP
         FETCH csr_get_user_col_name INTO l_user_col_name;
         EXIT WHEN csr_get_user_col_name%NOTFOUND;
         i :=   i
              + 1;
         l_user_col_coll (i) := l_user_col_name;
         DEBUG (   'User Column Name: '
                || l_user_col_name);
      END LOOP;

      CLOSE csr_get_user_col_name;
      debug_exit (l_proc_name);
      RETURN l_user_col_coll;
   END get_user_column_name;


-- This function returns the translated code for a given udt id and user column
-- ids and value from the translated UDT
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_udt_translated_code >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_udt_translated_code (
      p_user_table_name     IN   VARCHAR2,
      p_effective_date      IN   DATE,
      p_asg_user_col_name   IN   VARCHAR2,
      p_ext_user_col_name   IN   VARCHAR2,
      p_value               IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS

--

      l_proc_name         VARCHAR2 (60)
                                 :=    g_proc_name
                                    || 'get_udt_translated_code';
      l_value             pay_user_column_instances_f.VALUE%TYPE;
      l_user_table_id     NUMBER;
      l_asg_user_col_id   NUMBER;
      l_ext_user_col_id   NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Get the UDT id for the employment category translation table
      l_user_table_id := get_udt_id (p_udt_name => p_user_table_name);
      -- Get the assignment user column id
      l_asg_user_col_id :=
            get_user_column_id (
               p_user_table_id=> l_user_table_id,
               p_user_col_name=> p_asg_user_col_name
            );
      -- Get the extract user column id
      l_ext_user_col_id :=
            get_user_column_id (
               p_user_table_id=> l_user_table_id,
               p_user_col_name=> p_ext_user_col_name
            );
      OPEN csr_get_udt_translated_code (
         l_user_table_id,
         p_effective_date,
         l_asg_user_col_id,
         l_ext_user_col_id,
         p_value
      );
      FETCH csr_get_udt_translated_code INTO l_value;
      DEBUG (   'UDT Translated Code: '
             || l_value);
      CLOSE csr_get_udt_translated_code;
      debug_exit (l_proc_name);
      RETURN l_value;
   END get_udt_translated_code;


-- This function gets the NI contracted out element details from the
-- Lynx NI LG Pension mapping UDT
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_NI_cont_out_ele_details >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ni_cont_out_ele_details (
      p_error_number   OUT NOCOPY   NUMBER,
      p_error_text     OUT NOCOPY   VARCHAR2
   )
      RETURN NUMBER
   IS

--
      l_proc_name             VARCHAR2 (60)
                             :=    g_proc_name
                                || 'get_NI_cont_out_ele_details';
      l_return                NUMBER;
      l_ni_cont_out_ele_ids   csr_get_ni_ele_ids_from_udt%ROWTYPE;
      l_user_table_id         NUMBER;
      l_user_col_id           NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      DEBUG ('Before calling function get_udt_id');
      l_user_table_id :=
             get_udt_id (p_udt_name => 'PQP_GB_LYNX_HEYWOOD_NI_MAPPING_TABLE');
      DEBUG ('UDT Name: PQP_GB_LYNX_HEYWOOD_NI_MAPPING_TABLE');
      DEBUG (   'UDT ID: '
             || l_user_table_id);

      IF l_user_table_id IS NULL
      THEN
         DEBUG ('UDT not found Raise Error');
         p_error_number := 93349;
         p_error_text := 'BEN_93349_EXT_CPX_UDT_NOTEXIST';
         debug_exit (l_proc_name);
         RETURN -1;
      END IF; -- End if of error check ...

      DEBUG (   'NI UDT ID: '
             || TO_CHAR (l_user_table_id));
      -- Get the user column id
      DEBUG ('Before calling function get_user_column_id');
      l_user_col_id := get_user_column_id (
                          p_user_table_id=> l_user_table_id,
                          p_user_col_name=> 'Contracted Out'
                       );
      DEBUG ('User column Name: Contracted Out');
      DEBUG (   'User column ID is: '
             || l_user_col_id);

      IF l_user_col_id IS NULL
      THEN
         DEBUG ('User Column not found Raise Error');
         p_error_number := 93350;
         p_error_text := 'BEN_93350_EXT_CPX_UDTCOL_NOTEX';
         debug_exit (l_proc_name);
         RETURN -1;
      END IF; -- End if of error check ...

      -- Get the NI Contracted Out details

      OPEN csr_get_ni_ele_ids_from_udt (
         l_user_table_id,
         l_user_col_id,
         g_effective_date
      );

      LOOP
         FETCH csr_get_ni_ele_ids_from_udt INTO l_ni_cont_out_ele_ids;
         EXIT WHEN csr_get_ni_ele_ids_from_udt%NOTFOUND;
         -- Store the ele details in the collection
         DEBUG (   'NI Category : '
                || l_ni_cont_out_ele_ids.category);
         DEBUG (
               'User Row ID: '
            || l_ni_cont_out_ele_ids.user_row_id
         );
         g_ni_cont_out_ele_ids (l_ni_cont_out_ele_ids.user_row_id) :=
                                                        l_ni_cont_out_ele_ids;
      END LOOP; -- End loop of NI cont cursor ...

      CLOSE csr_get_ni_ele_ids_from_udt;

      IF g_ni_cont_out_ele_ids.COUNT = 0
      THEN
         DEBUG ('No NI Contracted out elements');
         p_error_number := 93351;
         p_error_text := 'BEN_93351_EXT_CPX_NICONT_NOELE';
         debug_exit (l_proc_name);
         RETURN -1;
      END IF; -- End if of NI cont out elements exists...

      debug_exit (l_proc_name);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   'Others Exception Raised'
                || l_proc_name);
         p_error_text := SQLERRM;
         p_error_number := SQLCODE;
         RAISE;
   END get_ni_cont_out_ele_details;


-- This procedure gets the NI element details from the NI LG Pension Mapping
-- UDT
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_NI_element_details>--------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_ni_element_details
   IS

--
      l_proc_name         VARCHAR2 (60)
                                  :=    g_proc_name
                                     || 'get_NI_element_details';
      l_user_table_id     NUMBER;
      l_element_type_id   NUMBER;
      l_ni_ele_details    csr_get_ni_ele_name%ROWTYPE;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Get the user table id for pension mapping UDT
      l_user_table_id := get_udt_id ('PQP_GB_LYNX_HEYWOOD_NI_MAPPING_TABLE');
      -- Fetch the NI elements from the UDT
      OPEN csr_get_ni_ele_name (l_user_table_id);

      LOOP
         FETCH csr_get_ni_ele_name INTO l_ni_ele_details;
         EXIT WHEN csr_get_ni_ele_name%NOTFOUND;
         -- Get the element type id for the given element name

--          DEBUG (
--                'Get element type id for given element name '
--             || l_ni_ele_details.row_low_range_or_name
--          );
--          OPEN csr_get_pay_ele_id (
--             l_ni_ele_details.row_low_range_or_name,
--             g_effective_date
--          );
--          FETCH csr_get_pay_ele_id INTO l_element_type_id;
--
--          IF csr_get_pay_ele_id%FOUND
--          THEN
            DEBUG (   'User Row ID: '
                   || TO_CHAR (l_ni_ele_details.user_row_id));
            -- Store the element details
--             g_ni_ele_details (l_ni_ele_details.user_row_id).element_type_id :=
--                                                             l_element_type_id;
            g_ni_ele_details (l_ni_ele_details.user_row_id).user_row_id :=
                                                 l_ni_ele_details.user_row_id;
            g_ni_ele_details (l_ni_ele_details.user_row_id).category :=
                                       l_ni_ele_details.row_low_range_or_name;
            g_ni_ele_details (l_ni_ele_details.user_row_id).user_table_id :=
                                                              l_user_table_id;
--         END IF; -- End if of element exists check ...

--         CLOSE csr_get_pay_ele_id;
      END LOOP; -- End loop of ni elements from the UDT cursor ...

      CLOSE csr_get_ni_ele_name;
      --
      debug_exit (l_proc_name);
   --

   END get_ni_element_details;

   --

-- This function returns the employment category information for a given
-- assignment id
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_asg_employment_cat >---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_asg_employment_cat (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2
   IS

--
      l_proc_name            VARCHAR2 (60)
                                  :=    g_proc_name
                                     || 'get_asg_employment_cat';
      l_asg_employment_cat   hr_lookups.meaning%TYPE;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      OPEN csr_get_asg_employment_cat (p_assignment_id, p_effective_date);
      FETCH csr_get_asg_employment_cat INTO l_asg_employment_cat;
      CLOSE csr_get_asg_employment_cat;
      DEBUG (   'Assignment employment category: '
             || l_asg_employment_cat);
      debug_exit (l_proc_name);
      RETURN l_asg_employment_cat;
   END get_asg_employment_cat;


-- This function determines whether an assignment qualifies for CPX
-- starters report
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_is_employee_a_starter >-------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_is_employee_a_starter (
      p_assignment_id          IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2
   IS

--
      l_proc_name        VARCHAR2 (60)
                               :=    g_proc_name
                                  || 'chk_is_employee_a_starter';
      l_eet_details      csr_get_starters_eet_info%ROWTYPE;
      l_inclusion_flag   VARCHAR2 (1);

--
   BEGIN
      debug_enter (l_proc_name);
      DEBUG ('Check Element entries exists with pension elements');
      -- Check element entries exist with pension ele's
      l_inclusion_flag := 'N';
      OPEN csr_get_starters_eet_info (
         c_assignment_id=> p_assignment_id,
         c_effective_start_date=> p_effective_start_date,
         c_effective_end_date=> p_effective_end_date
      );

      LOOP
         DEBUG ('Fetch element entries');
         FETCH csr_get_starters_eet_info INTO l_eet_details;
         EXIT WHEN csr_get_starters_eet_info%NOTFOUND;

         -- Check atleast one pension element exists for this assignment
         IF g_pension_ele_ids.EXISTS (l_eet_details.element_type_id)
         THEN
            -- Element exists, set the inclusion flag to 'Y'
            DEBUG ('Pension element entry exists');
            DEBUG (
                  'Pension Element Id: '
               || TO_CHAR (l_eet_details.element_type_id)
            );
            IF l_inclusion_flag = 'N'
            THEN
              g_ele_entry_details (p_assignment_id).element_type_id :=
                                                  l_eet_details.element_type_id;
              g_ele_entry_details (p_assignment_id).element_entry_id :=
                                                 l_eet_details.element_entry_id;
              g_ele_entry_details (p_assignment_id).effective_start_date :=
                                             l_eet_details.effective_start_date;
              g_ele_entry_details (p_assignment_id).effective_end_date :=
                                               l_eet_details.effective_end_date;
              g_ele_entry_details (p_assignment_id).assignment_id :=
                                                                p_assignment_id;
              l_inclusion_flag := 'Y';
            END IF; -- l_inclusion flag is N check ...


            g_index := g_index + 1;
            DEBUG('g_index: '|| g_index);
            g_pen_ele_details (g_index).element_entry_id :=
                                                l_eet_details.element_entry_id;
            g_pen_ele_details (g_index).element_type_id :=
                                                l_eet_details.element_type_id;
            g_pen_ele_details (g_index).effective_start_date :=
                                                l_eet_details.effective_start_date;
            g_pen_ele_details (g_index).effective_end_date :=
                                                l_eet_details.effective_end_date;
            g_pen_ele_details (g_index).assignment_id :=
                                                p_assignment_id;
            EXIT;
         END IF; -- End if of pension element entry exists ...
      END LOOP;

      CLOSE csr_get_starters_eet_info;
      debug_exit (l_proc_name);
      RETURN l_inclusion_flag;
   END chk_is_employee_a_starter;


-- This function returns the element entry value for a given element entry id
-- and input value id
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_ele_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ele_entry_value (
      p_element_entry_id       IN   NUMBER,
      p_input_value_id         IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2
   IS

--
      l_proc_name         VARCHAR2 (60)
                                     :=    g_proc_name
                                        || 'get_ele_entry_value';
      l_ele_entry_value   pay_element_entry_values_f.screen_entry_value%TYPE;

--
   BEGIN
      debug_enter (l_proc_name);
      OPEN csr_get_ele_entry_value (
         p_element_entry_id,
         p_input_value_id,
         p_effective_start_date,
         p_effective_end_date
      );
      FETCH csr_get_ele_entry_value INTO l_ele_entry_value;
      CLOSE csr_get_ele_entry_value;
      DEBUG (   'Element Entry ID: '
             || TO_CHAR (p_element_entry_id));
      DEBUG (   'Input Value ID: '
             || TO_CHAR (p_input_value_id));
      DEBUG (   'Entry Value: '
             || l_ele_entry_value);
      debug_exit (l_proc_name);
      RETURN l_ele_entry_value;
   END get_ele_entry_value;


-- This procedure gets all the secondary assignment information for any given
-- primary assignment
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_all_sec_assignments >------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_all_sec_assignments (
      p_assignment_id       IN              NUMBER,
      p_secondary_asg_ids   OUT NOCOPY      t_number
   )
   IS

--
      l_proc_name       VARCHAR2 (60)
                           :=    g_proc_name
                              || 'get_all_secondary_assignments';
      l_mult_asg_info   csr_get_multiple_assignments%ROWTYPE;

--
   BEGIN
      debug_enter (l_proc_name);
      -- Check for multiple assignments

      DEBUG ('Check for multiple assignments');
      OPEN csr_get_multiple_assignments (c_assignment_id => p_assignment_id);

      LOOP
         FETCH csr_get_multiple_assignments INTO l_mult_asg_info;
         EXIT WHEN csr_get_multiple_assignments%NOTFOUND;
         DEBUG (
               'Secondary Assignments for '
            || TO_CHAR (p_assignment_id)
            || TO_CHAR (l_mult_asg_info.assignment_id)
         );
         p_secondary_asg_ids (l_mult_asg_info.assignment_id) :=
                                                l_mult_asg_info.assignment_id;
      END LOOP;

      CLOSE csr_get_multiple_assignments;
      debug_exit (l_proc_name);
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   'Others Exception'
                || l_proc_name);
         p_secondary_asg_ids.DELETE;
         RAISE;
   END get_all_sec_assignments;


-- This procedure evaluates the secondary assignments and eliminates all the
-- secondary assignments that does not meet the eligibility criteria
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_eligible_sec_assignments >-------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_eligible_sec_assignments (
      p_assignment_id       IN              NUMBER,
      p_secondary_asg_ids   OUT NOCOPY      t_number
   )
   IS

--
      l_proc_name         VARCHAR2 (60)
                            :=    g_proc_name
                               || 'get_eligible_sec_assignments';
      l_all_sec_asg_ids   t_number;
      i                   NUMBER;

--
   BEGIN
      debug_enter (l_proc_name);
      DEBUG ('Before calling procedure get_all_sec_assignments');
      -- Get all secondary assignments

      get_all_sec_assignments (
         p_assignment_id=> p_assignment_id,
         p_secondary_asg_ids=> l_all_sec_asg_ids
      );
      DEBUG (
            'Check whether the assignment exists in the global '
         || 'eligible assignment collection'
      );
      -- Check whether this assignment exist in the Global collection

      i := l_all_sec_asg_ids.FIRST;

      WHILE i IS NOT NULL
      LOOP
         IF g_secondary_asg_ids.EXISTS (i)
         THEN
            DEBUG (   TO_CHAR (i)
                   || ' Secondary assignment exists');
            p_secondary_asg_ids (i) := l_all_sec_asg_ids (i);
         END IF; -- End if of asg exists in global collection ...

         i := l_all_sec_asg_ids.NEXT (i);
      END LOOP; -- End loop of secondary assignments ...

      debug_exit (l_proc_name);
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   'Others Exception'
                || l_proc_name);
         p_secondary_asg_ids.DELETE;
         RAISE;
   END get_eligible_sec_assignments;


-- This function will get the latest assignment action id for a given
-- assignment id and effective date
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_latest_action_id >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_latest_action_id (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN NUMBER
   IS

--
      l_assignment_action_id   NUMBER;
      l_proc_name              VARCHAR2 (60)
                                    :=    g_proc_name
                                       || 'get_latest_action_id';


--
      CURSOR get_latest_id (c_assignment_id IN NUMBER, c_effective_date IN DATE)
      IS
         SELECT fnd_number.canonical_to_number (
                   SUBSTR (
                      MAX (
                            LPAD (paa.action_sequence, 15, '0')
                         || paa.assignment_action_id
                      ),
                      16
                   )
                )
           FROM pay_assignment_actions paa, pay_payroll_actions ppa
          WHERE paa.assignment_id = c_assignment_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND paa.source_action_id IS NOT NULL
            AND ppa.effective_date <= c_effective_date
            AND ppa.action_type IN ('R', 'Q', 'I', 'V', 'B');

--
   BEGIN

--
      debug_enter (l_proc_name);
      OPEN get_latest_id (p_assignment_id, p_effective_date);
      FETCH get_latest_id INTO l_assignment_action_id;
      CLOSE get_latest_id;
      DEBUG (   'Latest Action Id: '
             || TO_CHAR (l_assignment_action_id));
      debug_exit (l_proc_name);

--
      RETURN l_assignment_action_id;

--
   END get_latest_action_id;


-- This function returns the sum of run result value for a given assignment id
-- element type id and input value id
-- Please note that this function should only be used when a balance is not
-- available
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_asg_ele_rresult_value >-----------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_asg_ele_rresult_value (
      p_assignment_id          IN   NUMBER,
      p_element_type_id        IN   NUMBER,
      p_input_value_id         IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER
   IS

--
      l_proc_name              VARCHAR2 (60)
                               :=    g_proc_name
                                  || 'get_asg_ele_rresult_value';
      l_rresult_value          NUMBER        := 0;
      l_effective_date         DATE;
      l_assignment_action_id   NUMBER;
      l_value                  NUMBER;
      i                        NUMBER;

--
   BEGIN
      debug_enter (l_proc_name);
      i := g_pen_ele_details.FIRST;
      WHILE i IS NOT NULL
      LOOP
        IF g_pen_ele_details(i).assignment_id = p_assignment_id AND
           g_pen_ele_details(i).element_type_id = p_element_type_id
        THEN
          DEBUG('g_pen_ele_details(i).element_type_id: '
                || g_pen_ele_details(i).element_type_id);
          DEBUG('g_pen_ele_details(i).effective_start_date: '
                || TO_CHAR(g_pen_ele_details(i).effective_start_date, 'DD/MON/YYYY'));
          DEBUG('g_pen_ele_details(i).effective_end_date: '
                || TO_CHAR(g_pen_ele_details(i).effective_end_date, 'DD/MON/YYYY'));

          OPEN csr_get_end_date (
            c_assignment_id=> p_assignment_id,
            c_effective_start_date=> GREATEST(p_effective_start_date,
                                      g_pen_ele_details(i).effective_start_date),
             c_effective_end_date=> LEAST(p_effective_end_date,
                                    g_pen_ele_details(i).effective_end_date)
          );

          LOOP
             FETCH csr_get_end_date INTO l_effective_date;
             EXIT WHEN csr_get_end_date%NOTFOUND;
             -- Call function to get the latest assignment action id
             DEBUG ('Before calling function get_latest_assignment_action_id');
             l_assignment_action_id :=
                   get_latest_action_id (
                      p_assignment_id=> p_assignment_id,
                      p_effective_date=> l_effective_date
                   );
             -- Get the sum of run result period for this assignment action
             OPEN csr_get_rresult_value (
                l_assignment_action_id,
                p_element_type_id,
                p_input_value_id
             );
             FETCH csr_get_rresult_value INTO l_value;
             CLOSE csr_get_rresult_value;
             DEBUG (   'Run Result Value: '
                    || TO_CHAR (l_value));
             l_rresult_value :=   l_rresult_value
                                + l_value;
          END LOOP;

          CLOSE csr_get_end_date;
        END IF; -- End if of element type and assignment id equals check ...
        i := g_pen_ele_details.NEXT(i);
      END LOOP; -- pl/sql loop

      l_rresult_value := l_rresult_value * 100;
      DEBUG (   'Final Run Result Value: '
             || TO_CHAR (l_rresult_value));
      debug_exit (l_proc_name);
      RETURN l_rresult_value;
   --
   END get_asg_ele_rresult_value;


-- This function returns the sum of run result value for the person accepting
-- assignment id, element type id and input value id
-- Please note, this function will have to be used only when there is no
-- balance available
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_person_ele_rresult_value >-------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_person_ele_rresult_value (
      p_assignment_id          IN   NUMBER,
      p_element_type_id        IN   NUMBER,
      p_input_value_id         IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER
   IS

--
      l_proc_name              VARCHAR2 (60)
                            :=    g_proc_name
                               || 'get_person_ele_rresult_value';
      l_secondary_asg_ids      t_number;
      l_person_rresult_value   NUMBER;
      l_rresult_value          NUMBER        := 0;
      i                        NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Determine the element runresult value for primary assignment

      DEBUG ('Primary Assignment');
      l_rresult_value :=
            get_asg_ele_rresult_value (
               p_assignment_id=> p_assignment_id,
               p_element_type_id=> p_element_type_id,
               p_input_value_id=> p_input_value_id,
               p_effective_start_date=> p_effective_start_date,
               p_effective_end_date=> p_effective_end_date
            );
      DEBUG (   'Run Result Value: '
             || TO_CHAR (l_rresult_value));
      -- Check for secondary assignments


      get_eligible_sec_assignments (
         p_assignment_id=> p_assignment_id,
         p_secondary_asg_ids=> l_secondary_asg_ids
      );
      i := l_secondary_asg_ids.FIRST;

      WHILE i IS NOT NULL
      LOOP
         DEBUG ('Secondary Assignment');
         l_rresult_value :=
                 l_rresult_value
               + get_asg_ele_rresult_value (
                    p_assignment_id=> l_secondary_asg_ids (i),
                    p_element_type_id=> p_element_type_id,
                    p_input_value_id=> p_input_value_id,
                    p_effective_start_date=> p_effective_start_date,
                    p_effective_end_date=> p_effective_end_date
                 );
         DEBUG (   'Run Result Value: '
                || TO_CHAR (l_rresult_value));
         i := l_secondary_asg_ids.NEXT (i);
      END LOOP;

      l_person_rresult_value := l_rresult_value;
      DEBUG (   'Person Run Result Value: '
             || TO_CHAR (l_person_rresult_value));
      debug_exit (l_proc_name);
      RETURN l_person_rresult_value;
   --

   END get_person_ele_rresult_value;


-- This function returns the balance value for a given assignment and
-- balance type id
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_asg_bal_value >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_asg_bal_value (
      p_assignment_id          IN   NUMBER,
      p_balance_type_id        IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER
   IS

--
      l_proc_name        VARCHAR2 (60) :=    g_proc_name
                                          || 'get_asg_bal_value';
      l_bal_value        NUMBER        := 0;
      l_effective_date   DATE;
      i                  NUMBER;

--
   BEGIN
      debug_enter (l_proc_name);
      i := g_pen_ele_details.FIRST;
      WHILE i IS NOT NULL
      LOOP
        IF g_pen_ele_details(i).assignment_id = p_assignment_id
        THEN
          DEBUG('g_pen_ele_details(i).effective_start_date: '
                || TO_CHAR(g_pen_ele_details(i).effective_start_date, 'DD/MON/YYYY'));
          DEBUG('g_pen_ele_details(i).effective_end_date: '
                || TO_CHAR(g_pen_ele_details(i).effective_end_date, 'DD/MON/YYYY'));

          OPEN csr_get_end_date (
             c_assignment_id=> p_assignment_id,
             c_effective_start_date=> GREATEST(p_effective_start_date,
                                      g_pen_ele_details(i).effective_start_date),
             c_effective_end_date=> LEAST(p_effective_end_date,
                                    g_pen_ele_details(i).effective_end_date)
          );

          LOOP
             FETCH csr_get_end_date INTO l_effective_date;
             EXIT WHEN csr_get_end_date%NOTFOUND;
             DEBUG ('Before calling function hr_gbbal.calc_asg_proc_ptd_date');
             l_bal_value :=
                     l_bal_value
                   + hr_gbbal.calc_asg_proc_ptd_date (
                        p_assignment_id=> p_assignment_id,
                        p_balance_type_id=> p_balance_type_id,
                        p_effective_date=> l_effective_date
                     );
             DEBUG (   'Balance Value: '
                    || TO_CHAR (l_bal_value));
          END LOOP;

          CLOSE csr_get_end_date;
        END IF; -- End if of assignment id equals check ...
        i := g_pen_ele_details.NEXT(i);
      END LOOP; -- pl/sql loop
      l_bal_value := l_bal_value * 100;
      DEBUG (   'Final Balance Value: '
             || TO_CHAR (l_bal_value));
      debug_exit (l_proc_name);
      RETURN l_bal_value;
   END get_asg_bal_value;


-- This function returns the person balance value for a given assignment
-- and balance type id
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_person_bal_value >---------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_person_bal_value (
      p_assignment_id          IN   NUMBER,
      p_balance_type_id        IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER
   IS

--
      l_proc_name           VARCHAR2 (60)
                                    :=    g_proc_name
                                       || 'get_person_bal_value';
      l_secondary_asg_ids   t_number;
      l_person_bal_value    NUMBER;
      l_bal_value           NUMBER        := 0;
      i                     NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Determine the balance value for primary assignment

      l_bal_value :=
            get_asg_bal_value (
               p_assignment_id=> p_assignment_id,
               p_balance_type_id=> p_balance_type_id,
               p_effective_start_date=> p_effective_start_date,
               p_effective_end_date=> p_effective_end_date
            );
      DEBUG (   'Bal Value: '
             || TO_CHAR (l_bal_value));
      -- Check for secondary assignments

      get_eligible_sec_assignments (
         p_assignment_id=> p_assignment_id,
         p_secondary_asg_ids=> l_secondary_asg_ids
      );
      i := l_secondary_asg_ids.FIRST;

      WHILE i IS NOT NULL
      LOOP
         l_bal_value :=
                 l_bal_value
               + get_asg_bal_value (
                    p_assignment_id=> l_secondary_asg_ids (i),
                    p_balance_type_id=> p_balance_type_id,
                    p_effective_start_date=> p_effective_start_date,
                    p_effective_end_date=> p_effective_end_date
                 );
         DEBUG (   'Bal Value: '
                || TO_CHAR (l_bal_value));
         i := l_secondary_asg_ids.NEXT (i);
      END LOOP;

      l_person_bal_value := NVL (l_bal_value, 0);
      DEBUG (   'Person Bal Value: '
             || TO_CHAR (l_person_bal_value));
      debug_exit (l_proc_name);
      RETURN l_person_bal_value;
   --

   END get_person_bal_value;


-- This function should be used when ASG_PROC_PTD dimension is not available for
-- a balance to determine its value
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_balance_value >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_balance_value (
      p_assignment_id          IN   NUMBER,
      p_balance_type_id        IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER
   IS

--
      l_proc_name           VARCHAR2 (60)
                                       :=    g_proc_name
                                          || 'get_balance_value';
      l_secondary_asg_ids   t_number;
      l_balance_value       NUMBER;
      l_value               NUMBER        := 0;
      i                     NUMBER;
      j                     NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Determine the balance value for primary assignment
      i := g_pen_ele_details.FIRST;
      WHILE i IS NOT NULL
      LOOP
        IF g_pen_ele_details(i).assignment_id = p_assignment_id
        THEN
          DEBUG('g_pen_ele_details(i).effective_start_date: '
                || TO_CHAR(g_pen_ele_details(i).effective_start_date, 'DD/MON/YYYY'));
          DEBUG('g_pen_ele_details(i).effective_end_date: '
                || TO_CHAR(g_pen_ele_details(i).effective_end_date, 'DD/MON/YYYY'));

          DEBUG ('Primary Assignment');
          DEBUG ('Before calling function hr_gbbal.calc_balance');
          l_value := l_value +
                hr_gbbal.calc_balance (
                   p_assignment_id=> p_assignment_id,
                   p_balance_type_id=> p_balance_type_id,
                   p_period_from_date=> GREATEST(p_effective_start_date,
                                        g_pen_ele_details(i).effective_start_date),
                   p_event_from_date=> GREATEST(p_effective_start_date,
                                        g_pen_ele_details(i).effective_start_date),
                   p_to_date=> LEAST(p_effective_end_date,
                               g_pen_ele_details(i).effective_end_date),
                   p_action_sequence=> NULL
                );
        END IF; -- assignment id equals check ...
        i := g_pen_ele_details.NEXT(i);
      END LOOP;
      DEBUG (   'Bal Value: '
             || TO_CHAR (l_value));
      -- Check for secondary assignments

      get_eligible_sec_assignments (
         p_assignment_id=> p_assignment_id,
         p_secondary_asg_ids=> l_secondary_asg_ids
      );
      DEBUG ('Secondary Assignments');
      i := l_secondary_asg_ids.FIRST;

      WHILE i IS NOT NULL
      LOOP
        j := g_pen_ele_details.FIRST;
        WHILE j IS NOT NULL
        LOOP
          IF g_pen_ele_details(j).assignment_id = l_secondary_asg_ids (i)
          THEN
            DEBUG('g_pen_ele_details(j).effective_start_date: '
                  || TO_CHAR(g_pen_ele_details(j).effective_start_date, 'DD/MON/YYYY'));
            DEBUG('g_pen_ele_details(j).effective_end_date: '
                  || TO_CHAR(g_pen_ele_details(j).effective_end_date, 'DD/MON/YYYY'));

            DEBUG ('Before calling function hr_gbbal.calc_balance');
            l_value :=
                    l_value
                  + hr_gbbal.calc_balance (
                       p_assignment_id=> l_secondary_asg_ids (i),
                       p_balance_type_id=> p_balance_type_id,
                       p_period_from_date=> GREATEST(p_effective_start_date,
                                            g_pen_ele_details(j).effective_start_date),
                       p_event_from_date=> GREATEST(p_effective_start_date,
                                            g_pen_ele_details(j).effective_start_date),
                       p_to_date=> LEAST(p_effective_end_date,
                                   g_pen_ele_details(j).effective_end_date),
                       p_action_sequence=> NULL
                    );
            DEBUG (   'Bal Value: '
                   || TO_CHAR (l_value));
          END IF; -- assignment id equals check ...
          j := g_pen_ele_details.NEXT(j);
         END LOOP;
         i := l_secondary_asg_ids.NEXT (i);
      END LOOP;

      l_balance_value := l_value;
      DEBUG (   'Final Bal Value: '
             || TO_CHAR (l_balance_value));
      debug_exit (l_proc_name);
      RETURN l_balance_value;
   --

   END get_balance_value;


-- This procedure sets the assignment details for a given assignment
-- PS Amend this code if you want to fetch any other assignment details
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_assignment_details >-------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE set_assignment_details (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
   IS

--
      l_proc_name   VARCHAR2 (60) :=    g_proc_name
                                     || 'set_assignment_details';
   --
   BEGIN
      --
      debug_enter (l_proc_name);
      OPEN csr_get_asg_details (p_assignment_id, p_effective_date);
      FETCH csr_get_asg_details INTO g_asg_details (p_assignment_id);
      CLOSE csr_get_asg_details;
      DEBUG (
            'Person ID: '
         || TO_CHAR (g_asg_details (p_assignment_id).person_id)
      );
      DEBUG (
            'Assignment Number: '
         || g_asg_details (p_assignment_id).assignment_number
      );
      DEBUG (
            'Employee Category: '
         || g_asg_details (p_assignment_id).employee_category
      );
      debug_exit (l_proc_name);
   --
   END set_assignment_details;


-- This function checks whether an assignment qualifies for starters
-- and returns a Y or N or Error if there is an error
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_employee_qual_for_starters >-----------------|
-- ----------------------------------------------------------------------------

   FUNCTION chk_employee_qual_for_starters (
      p_business_group_id   IN              NUMBER -- context
                                                  ,
      p_effective_date      IN              DATE -- context
                                                ,
      p_assignment_id       IN              NUMBER -- context
                                                  ,
      p_error_number        OUT NOCOPY      NUMBER,
      p_error_text          OUT NOCOPY      VARCHAR2
   -- ,p_trace                    in      varchar2  default null
   )
      RETURN VARCHAR2 -- Y or N
   IS

--
      l_inclusion_flag      VARCHAR2 (20)  := 'N';
      l_proc_name           VARCHAR2 (61)
                          :=    g_proc_name
                             || 'chk_employee_qual_for_starters';
      l_secondary_asg_ids   t_number;
      l_error_number        NUMBER;
      l_error_text          VARCHAR2 (200);
      l_return              NUMBER;
      i                     NUMBER;

--
   BEGIN
      debug_enter (l_proc_name);
      l_error_text := NULL;
      l_error_number := NULL;
      DEBUG (   'Business Group ID: '
             || TO_CHAR (g_business_group_id));
      DEBUG (   'Assignment ID: '
             || TO_CHAR (p_assignment_id));
      DEBUG (   'Session Date: '
             || p_effective_date);

      IF g_business_group_id IS NULL
      THEN
         g_pension_ele_ids.DELETE;
         g_pension_bal_name := NULL;
         g_pension_ele_name := NULL;
         g_initial_ext_date := NULL;
         g_emp_cont_iv_name := NULL;
         g_superann_refno_iv_name := NULL;
         g_superann_sal_bal_name := NULL;
         g_additional_cont_bal_name := NULL;
         g_buyback_cont_bal_name := NULL;
         g_superann_sal_bal_id := NULL;
         g_additional_cont_bal_id := NULL;
         g_buyback_cont_bal_id := NULL;
         g_ele_entry_details.DELETE;
         g_secondary_asg_ids.DELETE;
         g_asg_details.DELETE;
         g_ni_cont_out_ele_ids.DELETE;
         g_ni_ele_details.DELETE;
         g_ni_ele_type_id  := NULL;
	 g_ni_cat_iv_id    := NULL;
         g_ni_pen_iv_id    := NULL;
         g_pen_ele_details.DELETE;
         g_index := 0;


         -- Use STARTERS for starters, HOURCHANGE for hour change and ANNUAL
         -- for Annual report
         g_header_system_element := 'STARTERS:';
         DEBUG ('Before calling set_extract_globals function');
         l_return :=
               set_extract_globals (
                  p_assignment_id=> p_assignment_id,
                  p_business_group_id=> p_business_group_id,
                  p_effective_date=> ben_ext_person.g_effective_date,
                  -- Do not use the effective date (session date) as this may have been
                  -- reset to terminated assignment end date for override rule
                  p_error_number=> l_error_number,
                  p_error_text=> l_error_text
               );

         IF l_return <> 0
         THEN
            DEBUG ('Function set_extract_globals function is in Error');
            p_error_text := l_error_text;
            p_error_number := l_error_number;
            l_inclusion_flag := 'ERROR';
            debug_exit (l_proc_name);
            RETURN l_inclusion_flag;
         END IF; -- End if of return <> 0 check...

         DEBUG ('Before calling get_NI_element_details procedure');
--         get_ni_element_details;
-- Move this function to set_extract_globals
--
--          DEBUG ('Before calling get_NI_cont_out_ele_details function');
--          l_return :=
--                get_ni_cont_out_ele_details (
--                   p_error_number=> l_error_number,
--                   p_error_text=> l_error_text
--                );
--
--          IF l_return <> 0
--          THEN
--             DEBUG (
--                'Function get_NI_cont_out_ele_details function is in Error'
--             );
--             p_error_text := l_error_text;
--             p_error_number := l_error_number;
--             l_inclusion_flag := 'ERROR';
--             debug_exit (l_proc_name);
--             RETURN l_inclusion_flag;
--          END IF; -- End if of return <> 0 check...
      END IF;

      g_pen_ele_details.DELETE;
      g_index := 0;

      DEBUG ('Before calling chk_is_employee_a_starter function');
      --
      -- Check the person is a member and a new starter
      --

      l_inclusion_flag :=
            chk_is_employee_a_starter (
               p_assignment_id=> p_assignment_id,
               p_effective_start_date=> g_effective_start_date,
               p_effective_end_date=> g_effective_end_date
            );
      DEBUG (   'Inclusion Flag: '
             || l_inclusion_flag);

      IF l_inclusion_flag = 'Y'
      THEN
         DEBUG ('Assignment qualifies for starters');
         -- Populate assignment details

         set_assignment_details (
            p_assignment_id=> p_assignment_id,
            p_effective_date=> g_ele_entry_details (p_assignment_id).effective_start_date
         );
         DEBUG ('Get Secondary Assignments');
         -- Get Secondary Assignments

         DEBUG ('Before calling all secondary assignments procedure');
         get_all_sec_assignments (
            p_assignment_id=> p_assignment_id,
            p_secondary_asg_ids=> l_secondary_asg_ids
         );
         i := l_secondary_asg_ids.FIRST;

         WHILE i IS NOT NULL
         LOOP
            DEBUG ('Secondary assignment exist');
            DEBUG ('Check this secondary asg qualifies for starters');
            DEBUG ('Before calling function chk_is_employee_a_starter');

            IF chk_is_employee_a_starter (
                  p_assignment_id=> l_secondary_asg_ids (i),
                  p_effective_start_date=> g_effective_start_date,
                  p_effective_end_date=> g_effective_end_date
               ) = 'Y'
            THEN
               DEBUG (
                     TO_CHAR (l_secondary_asg_ids (i))
                  || ' Secondary assignment qualifies'
               );
               g_secondary_asg_ids (i) := l_secondary_asg_ids (i);
            END IF; -- End if of secondary asg check for starters ..

            i := l_secondary_asg_ids.NEXT (i);
         END LOOP; -- End loop of secondary assignments ...
      END IF; -- End if of inclusion Flag Check...

      debug_exit (l_proc_name);
      RETURN l_inclusion_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
         debug_exit (   ' Others in '
                     || l_proc_name, 'Y' -- turn trace off
                                        );
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END chk_employee_qual_for_starters;


-- This function returns the superannuation reference number for a given
-- assignment
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_superannuation_ref_no >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_superannuation_ref_no (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name         VARCHAR2 (61)
                               :=    g_proc_name
                                  || 'get_superannuation_ref_no';
      l_superann_ref_no   VARCHAR2 (60)                := TRIM (
                                                             RPAD (
                                                                ' ',
                                                                12,
                                                                ' '
                                                             )
                                                          );
      l_input_value_id    pay_input_values_f.input_value_id%TYPE;

--
   BEGIN
      debug_enter (l_proc_name);

      IF g_superann_refno_iv_name IS NOT NULL
      THEN
         -- Call function to get the first element entry details for this
         -- assignment id


         IF g_ele_entry_details.EXISTS (p_assignment_id)
         THEN
            -- Get superannuation reference number

            DEBUG ('Before calling get_ele_entry_value function');
            -- Get input value id for superannuation ref number

            l_input_value_id :=
                  get_input_value_id (
                     p_element_type_id=> g_ele_entry_details (
                                 p_assignment_id
                              ).element_type_id,
                     p_input_value_name=> g_superann_refno_iv_name,
                     p_effective_date=> g_ele_entry_details (p_assignment_id).effective_start_date
                  );
            l_superann_ref_no :=
                  get_ele_entry_value (
                     p_element_entry_id=> g_ele_entry_details (
                                 p_assignment_id
                              ).element_entry_id,
                     p_input_value_id=> l_input_value_id,
                     p_effective_start_date=> g_ele_entry_details (
                                 p_assignment_id
                              ).effective_start_date,
                     p_effective_end_date=> g_ele_entry_details (
                                 p_assignment_id
                              ).effective_end_date
                  );
            DEBUG (
                  'Superannuation reference number is '
               || l_superann_ref_no
            );
         END IF; -- End if of element entry details exists check ...
      END IF; -- End if of superann ip value not null check ...

      debug_exit (l_proc_name);
      RETURN l_superann_ref_no;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_superannuation_ref_no;


-- This function returns the employee contribution rate for the person
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_emp_cont_rate >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_emp_cont_rate (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name           VARCHAR2 (61)
                                       :=    g_proc_name
                                          || 'get_emp_cont_rate';
      l_emp_cont_rate       VARCHAR2 (6)                             := '000000';
      l_rate                NUMBER                                   := 0;
      l_input_value_id      pay_input_values_f.input_value_id%TYPE;
      l_secondary_asg_ids   t_number;
      i                     NUMBER;
      l_value               NUMBER;

--
   BEGIN
      debug_enter (l_proc_name);

      IF g_emp_cont_iv_name IS NOT NULL
      THEN
         -- Call function to get the first element entry details for this
         -- assignment id

         IF g_ele_entry_details.EXISTS (p_assignment_id)
         THEN
            -- Get input value id for superannuation ref number
            DEBUG ('Before calling get_input_value_id function');
            l_input_value_id :=
                  get_input_value_id (
                     p_element_type_id=> g_ele_entry_details (
                                 p_assignment_id
                              ).element_type_id,
                     p_input_value_name=> g_emp_cont_iv_name,
                     p_effective_date=> g_ele_entry_details (p_assignment_id).effective_start_date
                  );
            DEBUG (   'Input Value ID: '
                   || TO_CHAR (l_input_value_id));
            DEBUG ('Before calling get_ele_entry_value function');
            l_rate :=
                  NVL (
                     TO_NUMBER (
                        get_ele_entry_value (
                           p_element_entry_id=> g_ele_entry_details (
                                       p_assignment_id
                                    ).element_entry_id,
                           p_input_value_id=> l_input_value_id,
                           p_effective_start_date=> g_ele_entry_details (
                                       p_assignment_id
                                    ).effective_start_date,
                           p_effective_end_date=> g_ele_entry_details (
                                       p_assignment_id
                                    ).effective_end_date
                        )
                     ),
                     0
                  );
            DEBUG (   'Contribution Rate is '
                   || l_rate);
         END IF; -- End if of element entry details exists check ...

       -- Coomented to report only contribution from Primary assignment
       -- Bug 5459147 Contribution from secondary assignments should not be cosnidered.
       /*
         -- Check for secondary assignments

         get_eligible_sec_assignments (
            p_assignment_id=> p_assignment_id,
            p_secondary_asg_ids=> l_secondary_asg_ids
         );
         i := l_secondary_asg_ids.FIRST;

         WHILE i IS NOT NULL
         LOOP
            IF g_ele_entry_details.EXISTS (i)
            THEN
               -- Get input value id for Contribution Rate
               DEBUG ('Before calling get_input_value_id function');
               l_input_value_id :=
                     get_input_value_id (
                        p_element_type_id=> g_ele_entry_details (
                                    l_secondary_asg_ids (i)
                                 ).element_type_id,
                        p_input_value_name=> g_emp_cont_iv_name,
                        p_effective_date=> g_ele_entry_details (
                                    l_secondary_asg_ids (i)
                                 ).effective_start_date
                     );
               DEBUG (   'Input Value ID: '
                      || TO_CHAR (l_input_value_id));
               DEBUG ('Before calling get_ele_entry_value function');
               l_rate :=
                       l_rate
                     + NVL (
                          TO_NUMBER (
                             get_ele_entry_value (
                                p_element_entry_id=> g_ele_entry_details (
                                            l_secondary_asg_ids (i)
                                         ).element_entry_id,
                                p_input_value_id=> l_input_value_id,
                                p_effective_start_date=> g_ele_entry_details (
                                            l_secondary_asg_ids (i)
                                         ).effective_start_date,
                                p_effective_end_date=> g_ele_entry_details (
                                            l_secondary_asg_ids (i)
                                         ).effective_end_date
                             )
                          ),
                          0
                       );
               DEBUG (   'Contribution Rate is '
                      || l_rate);
            END IF; -- End if of element entry details exists check ...

            i := l_secondary_asg_ids.NEXT (i);
         END LOOP; -- End loop of secondary asgn ...
         */
      END IF; -- End if of emp cont rate not null check ...

      l_rate := l_rate * 100;

      -- Bug Fix 5021075
      IF l_rate > 999999
      THEN
         l_rate := 999999;
      ELSIF l_rate < 0 THEN
        l_value := pqp_gb_tp_extract_functions.raise_extract_error
                     (p_business_group_id => g_business_group_id
                     ,p_assignment_id => p_assignment_id
                     ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                     ,p_error_number => 94556
                     ,p_token1 => 'Employee Contribution Rate'
                     ,p_fatal_flag => 'N'
                     );
      END IF; -- End if of rate exceed max limit check ...

      IF l_rate >= 0 THEN
        l_emp_cont_rate := TRIM (TO_CHAR ((l_rate), '099999'));
      ELSE
        l_emp_cont_rate := TRIM (TO_CHAR ((l_rate), 'S09999'));
      END IF;
      DEBUG (   'Emp Contribution: '
             || l_emp_cont_rate);
      debug_exit (l_proc_name);
      RETURN l_emp_cont_rate;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_emp_cont_rate;


-- This function returns the scheme number for the given assignment
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_scheme_number >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_scheme_number (
      p_assignment_id   IN              NUMBER,
      p_scheme_number   OUT NOCOPY      VARCHAR2,
      p_error_number    OUT NOCOPY      NUMBER,
      p_error_text      OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS

--
      l_proc_name       VARCHAR2 (60)  :=    g_proc_name
                                          || 'get_scheme_number';
      l_scheme_number   pay_element_type_extra_info.eei_information1%TYPE
                                       := TRIM (RPAD (' ', 3, ' '));
      l_return          NUMBER;
      l_error_text      VARCHAR2 (200);
      l_truncated       VARCHAR2 (1);

--
   BEGIN
      debug_enter (l_proc_name);
      -- Get the element type id from the global collection
      DEBUG ('Get the element type id from the global collection');

      IF g_ele_entry_details.EXISTS (p_assignment_id)
      THEN
         -- Get the scheme number from the element extra info type
         DEBUG ('Get the scheme number from the element EIT');
         -- Call function pqp_utility_function
         DEBUG (
            'Before calling function pqp_utilities.pqp_get_extra_element_info'
         );
         l_return := 0;
         l_return :=
               pqp_utilities.pqp_get_extra_element_info (
                  p_element_type_id=> g_ele_entry_details (p_assignment_id).element_type_id,
                  p_information_type=> 'PQP_GB_PENSION_SCHEME_INFO',
                  p_segment_name=> 'Scheme Number',
                  p_value=> l_scheme_number,
                  p_truncated_yes_no=> l_truncated,
                  p_error_msg=> l_error_text
               );
         DEBUG (   'Scheme Number: '
                || l_scheme_number);

         IF l_return <> 0
         THEN
            -- Error Occurred
            DEBUG (   'Error Occurred report error '
                   || l_error_text);
            p_error_text := l_error_text;
         ELSIF l_scheme_number IS NULL
         THEN -- l_return = 0
            -- Raise mandatory message
            DEBUG ('Scheme Number is mandatory');
            p_error_text := 'Scheme number is missing.';
            l_return := -1;
         END IF; -- End if of error check ...
      END IF; -- End if of element entry details exist check ...

      p_scheme_number := TRIM (RPAD (l_scheme_number, 3, ' '));
      DEBUG (   'Scheme Number: '
             || l_scheme_number);
      debug_exit (l_proc_name);
      RETURN l_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         p_scheme_number := NULL;
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END get_scheme_number;


-- This function returns the employer reference number for the assignment
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_employer_reference_number >------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_employer_reference_number (
      p_assignment_id     IN              NUMBER,
      p_employer_ref_no   OUT NOCOPY      VARCHAR2,
      p_error_number      OUT NOCOPY      NUMBER,
      p_error_text        OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS

--
      l_proc_name         VARCHAR2 (60)
                           :=    g_proc_name
                              || 'get_employer_reference_number';
      l_employer_ref_no   pay_element_type_extra_info.eei_information1%TYPE
                           := TRIM (RPAD (' ', 10, ' '));
      l_return            NUMBER;
      l_error_text        VARCHAR2 (200);
      l_truncated         VARCHAR2 (1);

--
   BEGIN
      debug_enter (l_proc_name);
      -- Get the element type id from the global collection
      DEBUG ('Get the element type id from the global collection');

      IF g_ele_entry_details.EXISTS (p_assignment_id)
      THEN
         -- Get the scheme number from the element extra info type
         DEBUG ('Get the employer number from the element EIT');
         -- Call function pqp_utility_function
         DEBUG (
            'Before calling function pqp_utilities.pqp_get_extra_element_info'
         );
         l_return := 0;
         l_return :=
               pqp_utilities.pqp_get_extra_element_info (
                  p_element_type_id=> g_ele_entry_details (p_assignment_id).element_type_id,
                  p_information_type=> 'PQP_GB_PENSION_SCHEME_INFO',
                  p_segment_name=> 'Employer Reference Number',
                  p_value=> l_employer_ref_no,
                  p_truncated_yes_no=> l_truncated,
                  p_error_msg=> l_error_text
               );
         DEBUG (   'Employer Reference Number: '
                || l_employer_ref_no);

         IF l_return <> 0
         THEN
            -- Error Occurred
            DEBUG ('Error Occurred report error');
            p_error_text := l_error_text;
         ELSIF l_employer_ref_no IS NULL
         THEN -- l_return = 0
            -- Raise mandatory message
            DEBUG ('Employer Reference Number is mandatory');
            p_error_text := 'Employer reference number is missing.';
            l_return := -1;
         END IF; -- End if of error check ...
      END IF; -- End if of element entry details exist check ...

      p_employer_ref_no := TRIM (RPAD (l_employer_ref_no, 10, ' '));
      DEBUG (   'Employer Reference Number: '
             || l_employer_ref_no);
      debug_exit (l_proc_name);
      RETURN l_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         p_employer_ref_no := NULL;
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END get_employer_reference_number;


-- This function returns the date the person joined the pension fund
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_date_joined_pens_fund >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_date_joined_pens_fund (
      p_assignment_id    IN              NUMBER,
      p_dt_joined_pens   OUT NOCOPY      DATE,
      p_error_number     OUT NOCOPY      NUMBER,
      p_error_text       OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS

--
      l_proc_name        VARCHAR2 (60)
                               :=    g_proc_name
                                  || 'get_date_joined_pens_fund';
      l_dt_joined_pens   DATE;
      l_return           NUMBER;
      l_input_value_id   pay_input_values_f.input_value_id%TYPE;

--
   BEGIN
      debug_enter (l_proc_name);
      -- Determine the Override Start Date
      DEBUG ('Determine the Override Start Date');

      IF g_ele_entry_details.EXISTS (p_assignment_id)
      THEN
         -- Get input value id for Override Start Date
         DEBUG ('Before calling get_input_value_id function');
         l_input_value_id :=
               get_input_value_id (
                  p_element_type_id=> g_ele_entry_details (p_assignment_id).element_type_id,
                  p_input_value_name=> 'Override Start Date',
                  p_effective_date=> g_ele_entry_details (p_assignment_id).effective_start_date
               );
         DEBUG (   'Input Value ID: '
                || TO_CHAR (l_input_value_id));

         IF l_input_value_id IS NOT NULL
         THEN
            DEBUG ('Before calling get_ele_entry_value function');
            l_dt_joined_pens :=
                  fnd_date.canonical_to_date (
                     get_ele_entry_value (
                        p_element_entry_id=> g_ele_entry_details (
                                    p_assignment_id
                                 ).element_entry_id,
                        p_input_value_id=> l_input_value_id,
                        p_effective_start_date=> g_ele_entry_details (
                                    p_assignment_id
                                 ).effective_start_date,
                        p_effective_end_date=> g_ele_entry_details (
                                    p_assignment_id
                                 ).effective_end_date
                     )
                  );
         END IF; -- End if of input value id not null check ...

         DEBUG (   'Date Joined Pens Fund: '
                || l_dt_joined_pens);

         IF l_dt_joined_pens IS NULL
         THEN
            l_dt_joined_pens :=
                   g_ele_entry_details (p_assignment_id).effective_start_date;
         END IF; -- End if of override start date is null check ...
      END IF; -- End if of element entry details exist check ...

      IF l_dt_joined_pens IS NULL
      THEN
         DEBUG ('Raise Error');
         p_error_text := 'Date joined pension fund is missing';
         l_return := -1;
      ELSE -- date joined pension fund has a value ...
         p_dt_joined_pens := l_dt_joined_pens;
         l_return := 0;
      END IF; -- End if of date joined pens is null check ...

      DEBUG (   'Date Joined Pens Fund: '
             || l_dt_joined_pens);
      debug_exit (l_proc_name);
      RETURN l_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         p_dt_joined_pens := NULL;
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END get_date_joined_pens_fund;


-- This function returns the first (MIN) date the person contracted out of
-- National Insurance Contributions
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_date_contracted_out >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_date_contracted_out (
      p_assignment_id   IN              NUMBER,
      p_dt_cont_out     OUT NOCOPY      DATE,
      p_error_number    OUT NOCOPY      NUMBER,
      p_error_text      OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS

--

     CURSOR csr_get_ni_ele_info (c_effective_date DATE)
     IS
           SELECT   pee.element_entry_id, pee.effective_start_date
                   ,pee.effective_end_date
               FROM pay_element_entries_f pee, pay_element_links_f pel
              WHERE pee.assignment_id = p_assignment_id
                AND pee.entry_type = 'E'
                AND pee.element_link_id = pel.element_link_id
                AND c_effective_date BETWEEN pee.effective_start_date
                                         AND pee.effective_end_date
                AND pel.element_type_id = g_ni_ele_type_id
                AND c_effective_date BETWEEN pel.effective_start_date
                                         AND pel.effective_end_date
           ORDER BY pee.effective_start_date;

      l_proc_name        VARCHAR2 (60)
                                 :=    g_proc_name
                                    || 'get_date_contracted_out';
      l_dt_cont_out      DATE          := NULL;
      l_return           NUMBER;
      i                  NUMBER;
      l_min_start_date   DATE          := NULL;
      l_rec_ni_ele_info  csr_get_ni_ele_info%ROWTYPE;
      l_effective_date   DATE;
      l_ni_category      VARCHAR2(10);

--
   BEGIN
      debug_enter (l_proc_name);
      -- The contracted out elements should be available from the
      -- Global Collection

      -- Bug Fix 4721921
      l_effective_date := LEAST (
                                 g_ele_entry_details (p_assignment_id).effective_end_date,
                                 g_effective_end_date
                                );
      OPEN csr_get_ni_ele_info (l_effective_date);
      LOOP
        FETCH csr_get_ni_ele_info INTO l_rec_ni_ele_info;
        EXIT WHEN csr_get_ni_ele_info%NOTFOUND;

        l_ni_category := get_ele_entry_value
                                (p_element_entry_id     => l_rec_ni_ele_info.element_entry_id
                                ,p_input_value_id       => g_ni_cat_iv_id
                                ,p_effective_start_date => l_rec_ni_ele_info.effective_start_date
                                ,p_effective_end_date   => l_rec_ni_ele_info.effective_end_date
                                );


        i := g_ni_cont_out_ele_ids.FIRST;
        l_dt_cont_out := NULL;
        l_min_start_date := NULL;

        WHILE i IS NOT NULL
        LOOP
           -- Retrieve the min effective start date
           DEBUG (   'NI Category : '
                  || g_ni_cont_out_ele_ids (i).category);
           IF l_ni_category = g_ni_cont_out_ele_ids (i).category
           THEN
             l_min_start_date := l_rec_ni_ele_info.effective_start_date;
             l_dt_cont_out := l_min_start_date;
             EXIT;
           END IF;


--          OPEN csr_get_ele_ent_min_start_dt (
--             p_assignment_id,
--             g_ni_cont_out_ele_ids (i).category
--          );
--          FETCH csr_get_ele_ent_min_start_dt INTO l_min_start_date;
--          CLOSE csr_get_ele_ent_min_start_dt;
           DEBUG (   'Min start date: '
                  || l_min_start_date);

--          IF NVL (l_min_start_date, hr_api.g_eot) <
--                                             NVL (l_dt_cont_out, hr_api.g_eot)
--          -- hr_api.g_eot = 31/12/4712
--          THEN
--             l_dt_cont_out := l_min_start_date;
--          END IF; -- End if of min start date check ...

           DEBUG (   'Date Contracted Out: '
                  || l_dt_cont_out);
           i := g_ni_cont_out_ele_ids.NEXT (i);
        END LOOP; -- End loop of cont out ele ids ...
        DEBUG (   'Min start date: '
               || l_min_start_date);
        DEBUG (   'Date Contracted Out: '
               || l_dt_cont_out);
        IF l_dt_cont_out IS NOT NULL THEN
          EXIT;
        END IF;

      END LOOP; -- End loop of asg cursor
      CLOSE csr_get_ni_ele_info;

      DEBUG (   'Final Date Contracted Out: '
             || l_dt_cont_out);

      IF l_dt_cont_out IS NULL
      THEN
         DEBUG ('Date Contracted OUT missing');
         p_error_text := 'Date contracted out is missing';
         l_return := -1;
      ELSE -- date cont out exists
         p_dt_cont_out := l_dt_cont_out;
         l_return := 0;
      END IF; -- End if of date cont out is null check ...

      debug_exit (l_proc_name);
      RETURN l_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         p_dt_cont_out := NULL;
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END get_date_contracted_out;


-- This function returns the part time indicator information for the assignment
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_part_time_indicator >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_part_time_indicator (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2
   IS

--
      l_proc_name            VARCHAR2 (60)
                                 :=    g_proc_name
                                    || 'get_part_time_indicator';
      l_part_time_ind        VARCHAR2 (1)                  := ' ';
      l_asg_employment_cat   hr_lookups.lookup_code%TYPE;
      l_error_text           VARCHAR2 (200);
      l_return               NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Get the assignment employment category

      DEBUG ('Before calling function get_asg_employment_category');
      l_asg_employment_cat :=
            get_asg_employment_cat (
               p_assignment_id=> p_assignment_id,
               p_effective_date=> p_effective_date
            );

      IF l_asg_employment_cat IS NOT NULL
      THEN
         -- Get the part time translation code from the UDT
         DEBUG ('Before calling get_udt_translated_code function');
         l_part_time_ind :=
               get_udt_translated_code (
                  p_user_table_name=> 'PQP_GB_TP_EMPLOYMENT_CATEGORY_TRANSALATION_TABLE',
                  p_effective_date=> g_effective_date,
                  p_asg_user_col_name=> 'Assignment Employment Category Lookup Code',
                  p_ext_user_col_name=> 'Lynx Heywood Employment Category Code',
                  p_value=> l_asg_employment_cat
               );
         DEBUG (   'Part Time Indicator: '
                || l_part_time_ind);
      END IF; -- End if of asg employment cat is not null check ...

      l_part_time_ind := NVL (l_part_time_ind, ' ');
      debug_exit (l_proc_name);
      RETURN l_part_time_ind;
   --
   END get_part_time_indicator;


-- This function should be called from the fast formula and is a wrapper to the
-- low level function get_part_time_indicator
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_STARTERS_part_time_ind >-------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_starters_part_time_ind (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name       VARCHAR2 (60)
                              :=    g_proc_name
                                 || 'get_STARTERS_part_time_ind';
      l_part_time_ind   VARCHAR2 (1);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_part_time_ind :=
            get_part_time_indicator (
               p_assignment_id=> p_assignment_id,
               p_effective_date=> g_ele_entry_details (p_assignment_id).effective_start_date
            );
      debug_exit (l_proc_name);
      RETURN l_part_time_ind;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_starters_part_time_ind;


-- This function should be called from the fast formula and is a wrapper to the
-- low level function get_part_time_indicator
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_CPX_part_time_ind >-------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_cpx_part_time_ind (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name       VARCHAR2 (60)
                                   :=    g_proc_name
                                      || 'get_CPX_part_time_ind';
      l_part_time_ind   VARCHAR2 (1);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_part_time_ind :=
            get_part_time_indicator (
               p_assignment_id=> p_assignment_id,
               p_effective_date=> LEAST (
                           g_ele_entry_details (p_assignment_id).effective_end_date,
                           g_effective_end_date
                        )
            );
      debug_exit (l_proc_name);
      RETURN l_part_time_ind;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_cpx_part_time_ind;


-- This function returns the marital status for the person
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_marital_status >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_marital_status (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2
   IS

--
      l_proc_name             VARCHAR2 (60)
                                      :=    g_proc_name
                                         || 'get_marital_status';
      l_person_marital_sts    VARCHAR2 (30);
      l_pens_marital_status   VARCHAR2 (1)   := ' ';
      l_return                NUMBER;
      l_error_text            VARCHAR2 (200);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Get the person marital status

      OPEN csr_get_marital_status (
         g_asg_details (p_assignment_id).person_id,
         p_effective_date
      );
      FETCH csr_get_marital_status INTO l_person_marital_sts;
      CLOSE csr_get_marital_status;
      DEBUG (   'Person Marital Status: '
             || l_person_marital_sts);

      IF l_person_marital_sts IS NOT NULL
      THEN
         -- Get the marital status from UDT
         DEBUG ('Before calling get_udt_translated_code function');
         l_pens_marital_status :=
               get_udt_translated_code (
                  p_user_table_name=> 'PQP_GB_LYNX_HEYWOOD_MARITAL_STATUS_TABLE',
                  p_effective_date=> g_effective_date,
                  p_asg_user_col_name=> 'Person Marital Status Lookup Value',
                  p_ext_user_col_name=> 'Pension Extracts Marital Status Code',
                  p_value=> l_person_marital_sts
               );
      END IF; -- End if of person marital status not null check ...

      DEBUG (   'Pension Marital Status: '
             || l_pens_marital_status);
      l_pens_marital_status := NVL (l_pens_marital_status, ' ');
      debug_exit (l_proc_name);
      RETURN l_pens_marital_status;
   END get_marital_status;


-- This function should be called by the fast formula, this in turn calls the
-- low level function get_marital_status
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_STARTERS_marital_status >------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_starters_marital_status (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name        VARCHAR2 (60)
                             :=    g_proc_name
                                || 'get_STARTERS_marital_status';
      l_marital_status   VARCHAR2 (1);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_marital_status :=
            get_marital_status (
               p_assignment_id=> p_assignment_id,
               p_effective_date=> g_ele_entry_details (p_assignment_id).effective_start_date
            );
      debug_exit (l_proc_name);
      RETURN l_marital_status;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_starters_marital_status;


-- This function should be called by the fast formula, this in turn calls the
-- low level function get_marital_status
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_CPX_marital_status >-----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_cpx_marital_status (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name        VARCHAR2 (60)
                                  :=    g_proc_name
                                     || 'get_CPX_marital_status';
      l_marital_status   VARCHAR2 (1);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_marital_status :=
            get_marital_status (
               p_assignment_id=> p_assignment_id,
               p_effective_date=> LEAST (
                           g_ele_entry_details (p_assignment_id).effective_end_date,
                           g_effective_end_date
                        )
            );
      debug_exit (l_proc_name);
      RETURN l_marital_status;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_cpx_marital_status;


-- This function returns the spouses date of birth information for the person
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_spouses_date_of_birth >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_spouses_date_of_birth (p_assignment_id IN NUMBER)
      RETURN DATE
   IS

--
      l_proc_name         VARCHAR2 (60)
                               :=    g_proc_name
                                  || 'get_spouses_date_of_birth';
      l_spouses_details   csr_get_spouses_details%ROWTYPE;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Get contact details
      OPEN csr_get_spouses_details (
         g_asg_details (p_assignment_id).person_id,
         g_ele_entry_details (p_assignment_id).effective_start_date
      );
      FETCH csr_get_spouses_details INTO l_spouses_details;
      CLOSE csr_get_spouses_details;
      DEBUG (   'Spouses DOB'
             || l_spouses_details.date_of_birth);
      debug_exit (l_proc_name);
      RETURN l_spouses_details.date_of_birth;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_spouses_date_of_birth;


-- This function returns the spouses' initials for the person
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_spouses_initials >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_spouses_initials (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name           VARCHAR2 (60)
                                    :=    g_proc_name
                                       || 'get_spouses_initials';
      l_spouses_details     csr_get_spouses_details%ROWTYPE;
      l_space_position      NUMBER;
      l_spouses_initials    VARCHAR2 (2)                := TRIM (
                                                              RPAD (
                                                                 ' ',
                                                                 2,
                                                                 ' '
                                                              )
                                                           );
      l_spouses_finitials   VARCHAR2 (2);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Get contact details
      OPEN csr_get_spouses_details (
         g_asg_details (p_assignment_id).person_id,
         g_ele_entry_details (p_assignment_id).effective_start_date
      );
      FETCH csr_get_spouses_details INTO l_spouses_details;
      CLOSE csr_get_spouses_details;
      DEBUG (   'First Name: '
             || l_spouses_details.first_name);
      DEBUG (   'Middle Names: '
             || l_spouses_details.middle_names);

      -- Check first name exists

      IF l_spouses_details.first_name IS NOT NULL
      THEN
         -- Get the first character from first name
         l_spouses_finitials := SUBSTR (l_spouses_details.first_name, 1, 1);
         DEBUG (   'Spouses Finitials: '
                || l_spouses_finitials);
         -- Check whether the first name has two name components
         l_space_position := INSTR (l_spouses_details.first_name, ' ', 1);

         IF l_space_position <> 0
         THEN
            l_spouses_finitials :=    l_spouses_finitials
                                   || SUBSTR (
                                         l_spouses_details.first_name,
                                         (  l_space_position
                                          + 1
                                         ),
                                         1
                                      );
            DEBUG (   'Spouses Initials: '
                   || l_spouses_finitials);
         END IF; -- End if of space position check ...
      END IF; -- End if of first name not null check ...

      -- Check whether the initial has first two characters

      IF LENGTH (NVL (l_spouses_finitials, 0)) < 2
      THEN
         IF l_spouses_details.middle_names IS NOT NULL
         THEN
            -- Get the first character from middle name
            l_spouses_finitials :=    l_spouses_finitials
                                  || SUBSTR (
                                        l_spouses_details.middle_names,
                                        1,
                                        1
                                     );
         END IF; -- End if of middle name not null check ...
      END IF; -- End if of length check ...

      l_spouses_initials := TRIM (RPAD (l_spouses_finitials, 2, ' '));
      DEBUG (   'Spouses Initials: '
             || l_spouses_initials);
      debug_exit (l_proc_name);
      RETURN l_spouses_initials;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_spouses_initials;


-- This function returns the National insurance indicator for the assignment
-- the indicator includes the reduced contribution indicator and the category
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_NI_indicator >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ni_indicator (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2
   IS

--
      CURSOR csr_get_ni_red_ind (c_column_name VARCHAR2)
      IS
         SELECT DECODE (
                   c_column_name,
                   'P = Reduced Rate Conts but now Full Rate', 'P',
                   'Y = Reduced Rate Conts Current', 'Y'
                )
           FROM DUAL;

      --

      l_proc_name            VARCHAR2 (60)
                                        :=    g_proc_name
                                           || 'get_NI_indicator';
      l_asg_ni_ele_details   csr_get_asg_ni_ele_info%ROWTYPE;
      l_max_start_date       DATE;
      l_ni_table_letter      VARCHAR2 (1)                      := ' ';
      l_ni_reduced_ind       VARCHAR2 (1)                      := ' ';
      l_ni_indicator         VARCHAR2 (2);
      l_user_col_coll        t_varchar2;
      i                      NUMBER;
      l_user_table_id        NUMBER;
      l_user_row_id          NUMBER;
      l_rec_ni_ele_info      csr_get_asg_ni_ele_info%ROWTYPE;


--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Get the NI ele details from the collection

--       i := g_ni_ele_details.FIRST;
--
--       WHILE i IS NOT NULL
--       LOOP
--          DEBUG (
--                'Element Type ID: '
--             || TO_CHAR (g_ni_ele_details (i).element_type_id)
--          );
         -- Get the effective NI element assigned to this assignment
         DEBUG ('Get the effective NI element assigned to this assignment');
         -- Bug Fix 4721921
         OPEN csr_get_asg_ni_ele_info (
            p_assignment_id,
            g_ni_ele_type_id,
            p_effective_date
         );
         FETCH csr_get_asg_ni_ele_info INTO l_rec_ni_ele_info;
         CLOSE csr_get_asg_ni_ele_info;

         l_ni_table_letter := get_ele_entry_value
                                (p_element_entry_id     => l_rec_ni_ele_info.element_entry_id
                                ,p_input_value_id       => g_ni_cat_iv_id
                                ,p_effective_start_date => l_rec_ni_ele_info.effective_start_date
                                ,p_effective_end_date   => l_rec_ni_ele_info.effective_end_date
                                );
         DEBUG (' l_rec_ni_ele_info.effective_start_date: '|| TO_CHAR( l_rec_ni_ele_info.effective_start_date,'DD/MON/YYYY'));
         DEBUG (' l_rec_ni_ele_info.effective_end_date: '|| TO_CHAR( l_rec_ni_ele_info.effective_end_date,'DD/MON/YYYY'));

--          -- Check whether an NI element exist ...
--          DEBUG (   'Start Date: '
--                 || l_asg_ni_ele_details.start_date);
--
--          -- Check whether this NI element entry start date is greater than
--          -- the previous NI element entry start date (effective)
--
--          IF      l_asg_ni_ele_details.start_date IS NOT NULL
--              AND l_asg_ni_ele_details.start_date >
--                                         NVL (l_max_start_date, hr_api.g_date)
--          THEN
--             -- If this date is greater then store the NI attributes
--             -- Get the NI Table Letter
--             l_ni_table_letter :=
--                              SUBSTR (g_ni_ele_details (i).element_name, 4, 1);
--             l_max_start_date := l_asg_ni_ele_details.start_date;
--             l_user_row_id := g_ni_ele_details (i).user_row_id;
--             l_user_table_id := g_ni_ele_details (i).user_table_id;
--             DEBUG (   'NI Table Letter: '
--                    || l_ni_table_letter);
--             DEBUG (   'Max Start Date: '
--                    || l_max_start_date);
--             DEBUG (   'User Row id: '
--                    || TO_CHAR (l_user_row_id));
--             DEBUG (   'User Table id: '
--                    || TO_CHAR (l_user_table_id));
--          END IF; -- End if of start date > check ...
--
--          i := g_ni_ele_details.NEXT (i);
--       END LOOP; -- End loop of g_NI_ele_details collection loop ...

      -- Check whether there is a NI table letter

      IF l_ni_table_letter IS NOT NULL
      THEN

         -- Get the user table id for pension mapping UDT
         l_user_table_id := get_udt_id ('PQP_GB_LYNX_HEYWOOD_NI_MAPPING_TABLE');
         l_user_row_id   := get_user_row_id
                              (p_user_table_id=> l_user_table_id
                              ,p_user_row_name=> 'NI '||l_ni_table_letter
                              ,p_effective_date=> p_effective_date
                              );

         -- Get the contribution indicator
         l_user_col_coll :=
               get_user_column_name (
                  p_user_table_id=> l_user_table_id,
                  p_user_row_id=> l_user_row_id,
                  p_effective_date=> p_effective_date
               );
         i := l_user_col_coll.FIRST;

         WHILE i IS NOT NULL
         LOOP
            -- Please note that the columns are seeded so the names
            -- are very unlikely to change, but if the user seed their
            -- own column names starting with P or Y then this will be a problem,
            -- so to ensure that we pick up the right column name
            -- we use the exact name match for checking
            IF l_user_col_coll (i) IN
                     ('P = Reduced Rate Conts but now Full Rate',
                      'Y = Reduced Rate Conts Current'
                     )
            THEN

--                OPEN csr_get_ni_red_ind (l_user_col_coll(i));
--                FETCH csr_get_ni_red_ind INTO l_ni_reduced_ind;
--                CLOSE csr_get_ni_red_ind;
               l_ni_reduced_ind := SUBSTR (l_user_col_coll (i), 1, 1);
               DEBUG (   'Reduced NI Ind: '
                      || l_ni_reduced_ind);
               EXIT;
            END IF; -- End if of user col check in P,Y ...

            i := l_user_col_coll.NEXT (i);
         END LOOP;
      END IF; -- End if of NI table letter exists check ...

      l_ni_indicator :=    l_ni_table_letter
                        || l_ni_reduced_ind;
      l_ni_indicator := TRIM (RPAD (l_ni_indicator, 2, ' '));
      DEBUG (   'NI Indicator: '
             || l_ni_indicator);
      debug_exit (l_proc_name);
      RETURN l_ni_indicator;
   --

   END get_ni_indicator;


-- This function should be called from the fast formula, and is a wrapper to
-- the low level function get_ni_indicator
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_STARTERS_NI_indicator >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_starters_ni_indicator (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name      VARCHAR2 (60)
                               :=    g_proc_name
                                  || 'get_STARTERS_NI_indicator';
      l_ni_indicator   VARCHAR2 (2);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      DEBUG ('Before calling function get_NI_indicator');
      l_ni_indicator :=
            get_ni_indicator (
               p_assignment_id=> p_assignment_id,
               p_effective_date=> g_ele_entry_details (p_assignment_id).effective_start_date
            );
      debug_exit (l_proc_name);
      RETURN l_ni_indicator;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_starters_ni_indicator;


-- This function should be called from the fast formula, and is a wrapper to
-- the low level function get_ni_indicator
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_CPX_NI_indicator >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_cpx_ni_indicator (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name      VARCHAR2 (60)
                                    :=    g_proc_name
                                       || 'get_CPX_NI_indicator';
      l_ni_indicator   VARCHAR2 (2);

--
   BEGIN
      --
      debug_enter (l_proc_name);
      DEBUG ('Before calling function get_NI_indicator');
      l_ni_indicator :=
            get_ni_indicator (
               p_assignment_id=> p_assignment_id,
               p_effective_date=> LEAST (
                           g_ele_entry_details (p_assignment_id).effective_end_date,
                           g_effective_end_date
                        )
            );
      debug_exit (l_proc_name);
      RETURN l_ni_indicator;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_cpx_ni_indicator;


-- This function returns the employment number (assignment number) for the
-- given assignment
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_employment_number >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_employment_number (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name       VARCHAR2 (60)
                                   :=    g_proc_name
                                      || 'get_employment_number';
      l_employment_no   per_all_assignments_f.assignment_number%TYPE
                                                  := TRIM (RPAD (' ', 2, ' '));

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_employment_no := g_asg_details (p_assignment_id).assignment_number;
      l_employment_no := TRIM (RPAD (l_employment_no, 2, ' '));
      DEBUG (   'Employment No: '
             || l_employment_no);
      debug_exit (l_proc_name);
      RETURN l_employment_no;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_employment_number;


-- This function returns the employee category information for the assignment
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_employee_category >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_employee_category (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name           VARCHAR2 (60)
                                   :=    g_proc_name
                                      || 'get_employee_category';
      l_employee_category   per_all_assignments_f.employee_category%TYPE;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_employee_category :=
                            g_asg_details (p_assignment_id).employee_category;
      DEBUG (   'Employee Category: '
             || l_employee_category);
      debug_exit (l_proc_name);
      RETURN l_employee_category;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_employee_category;


-- This function determines the remuneration amount from a balance
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_remuneration_from_bal >-------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_remuneration_from_bal (
      p_assignment_id          IN   NUMBER,
      p_balance_type_id        IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2
   IS

--
      l_proc_name      VARCHAR2 (60)
                               :=    g_proc_name
                                  || 'get_remuneration_from_bal';
      l_remuneration   VARCHAR2 (11);
      l_value          NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_value :=
            get_person_bal_value (
               p_assignment_id=> p_assignment_id,
               p_balance_type_id=> p_balance_type_id,
               p_effective_start_date=> p_effective_start_date,
               p_effective_end_date=> p_effective_end_date
            );

      IF l_value > 99999999999
      THEN
         l_value := 99999999999;
      END IF; -- End if of value exceed max limit check ...

      IF l_value >= 0 THEN
         l_remuneration := TRIM (TO_CHAR (l_value, '09999999999'));
      ELSE
         l_remuneration := TRIM (TO_CHAR (l_value, 'S0999999999'));
      END IF;

      DEBUG (   'Remuneration: '
             || l_remuneration);
      debug_exit (l_proc_name);
      RETURN l_remuneration;
   --

   END get_remuneration_from_bal;


-- This function returns the actual remuneration for a given assignment
-- PS Actual remuneration has a balance called "Gross Pay"
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_actual_remuneration >---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_actual_remuneration (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name     VARCHAR2 (60)
                                 :=    g_proc_name
                                    || 'get_actual_remuneration';
      l_actual_rem    VARCHAR2 (11);
      l_bal_type_id   NUMBER;
      l_value         NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_bal_type_id := get_pay_bal_id (p_balance_name => 'Gross Pay');
      l_actual_rem :=
            get_remuneration_from_bal (
               p_assignment_id=> p_assignment_id,
               p_balance_type_id=> l_bal_type_id,
               p_effective_start_date=> g_effective_start_date,
               p_effective_end_date=> g_effective_end_date
            );
      -- Bug Fix 5021075
      IF TO_NUMBER(l_actual_rem) < 0
      THEN
        l_value := pqp_gb_tp_extract_functions.raise_extract_error
                     (p_business_group_id => g_business_group_id
                     ,p_assignment_id => p_assignment_id
                     ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                     ,p_error_number => 94556
                     ,p_token1 => 'Actual Remuneration'
                     ,p_fatal_flag => 'N'
                     );
      END IF;
      debug_exit (l_proc_name);
      RETURN l_actual_rem;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_actual_remuneration;


-- This function returns the pensionable remuneration for a given assignment
-- PS Pensionable remuneration has a balance called "Superannuable Salary"
-- (Default) or the user provided balance name in the CPX definition UDT
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_pensionable_remuneration >-----------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_pensionable_remuneration (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name         VARCHAR2 (60)
                            :=    g_proc_name
                               || 'get_pensionable_remuneration';
      l_pensionable_rem   VARCHAR2 (11);
      l_value             NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_pensionable_rem :=
            get_remuneration_from_bal (
               p_assignment_id=> p_assignment_id,
               p_balance_type_id=> g_superann_sal_bal_id,
               p_effective_start_date=> g_effective_start_date,
               p_effective_end_date=> g_effective_end_date
            );
      -- Bug Fix 5021075
      IF TO_NUMBER(l_pensionable_rem) < 0
      THEN
        l_value := pqp_gb_tp_extract_functions.raise_extract_error
                     (p_business_group_id => g_business_group_id
                     ,p_assignment_id => p_assignment_id
                     ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                     ,p_error_number => 94556
                     ,p_token1 => 'Pensionable Remuneration'
                     ,p_fatal_flag => 'N'
                     );
      END IF;
      debug_exit (l_proc_name);
      RETURN l_pensionable_rem;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_pensionable_remuneration;


-- This function gets the header system data element information
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_system_data_element >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_system_data_element
      RETURN VARCHAR2
   IS

--
      l_proc_name   VARCHAR2 (60)
                                 :=    g_proc_name
                                    || 'get_system_data_element';

--
   BEGIN
      --
      debug_enter (l_proc_name);
      debug_exit (l_proc_name);
      RETURN g_header_system_element;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_system_data_element;


-- This function returns the total number of detail records for an extract type
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_total_number_data_records >----------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_total_number_data_records (p_type IN VARCHAR2)
      RETURN VARCHAR2
   IS

--
      l_proc_name      VARCHAR2 (61)
                           :=    g_proc_name
                              || 'get_total_number_data_records';

      CURSOR count_extract_details
        (p_ext_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE)
      IS
         SELECT COUNT (*)
           FROM ben_ext_rslt_dtl dtl
--               ,ben_ext_rcd rcd
          WHERE dtl.ext_rslt_id = ben_ext_thread.g_ext_rslt_id
            AND dtl.ext_rcd_id = p_ext_rcd_id
--            AND rcd.ext_rcd_id = dtl.ext_rcd_id
--            AND rcd.rcd_type_cd = 'D'
            AND DECODE (
                   NVL (TRIM (p_type), hr_api.g_varchar2),
                   hr_api.g_varchar2, hr_api.g_varchar2,
                   dtl.val_01
                ) = NVL (TRIM (p_type), hr_api.g_varchar2)
            AND dtl.val_01 <> 'DELETE';

      l_count          NUMBER        := 0;
      l_count_099999   VARCHAR2 (6)  := '000000';
      l_ext_rcd_id     NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      --

      -- 11.5.10_CU2: Performance fix :
      -- get the ben_ext_rcd.ext_rcd_id
      -- and use this one for next cursor
      -- This will prevent FTS on the table.

      OPEN csr_ext_rcd_id (p_hide_flag       => 'N'
                          ,p_rcd_type_cd     => 'D'
                          );
      FETCH csr_ext_rcd_id INTO l_ext_rcd_id;
      CLOSE csr_ext_rcd_id ;

      OPEN count_extract_details(l_ext_rcd_id);
      FETCH count_extract_details INTO l_count;

      IF l_count < 999999
      THEN
         l_count_099999 := TRIM (TO_CHAR (l_count, '099999'));
      ELSE
         l_count_099999 := '999999';
      END IF;

      CLOSE count_extract_details;
      DEBUG (   'Total Count: '
             || l_count_099999);
      debug_exit (l_proc_name);
      RETURN l_count_099999;
   --

   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_total_number_data_records;


-- This function determines the sum of a particular data element in a detail
-- record if available
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_data_element_total_value >-------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_data_element_total_value (p_val_seq IN NUMBER)
      RETURN VARCHAR2
   IS

   -- Dynamic cursor does not work on version 8.0
   -- so use decode statements
   -- please include additional sequence values
   -- if you use any of them

      CURSOR csr_get_total
        (p_ext_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE)
       IS
          SELECT NVL (SUM (TO_NUMBER(DECODE (p_val_seq,
                                   23, VAL_23,
                                   25, VAL_25,
                                   27, VAL_27,
                                   29, VAL_29,
                                   31, VAL_31,
                                   33, VAL_33,
                                   35, VAL_35,
                                   42, VAL_42,
                                   44, VAL_44
                                  )
                           )), 0) total_value
            FROM ben_ext_rslt_dtl dtl
--                ,ben_ext_rcd rcd
           WHERE dtl.ext_rslt_id = ben_ext_thread.g_ext_rslt_id
             AND dtl.ext_rcd_id  = p_ext_rcd_id;
--             AND rcd.ext_rcd_id = dtl.ext_rcd_id
--             AND rcd.rcd_type_cd = 'D';

      l_proc_name         VARCHAR2 (60)
                            :=    g_proc_name
                               || 'get_data_element_total_value';

--      TYPE ref_get_total IS REF CURSOR;

--      csr_get_total       ref_get_total;
      l_rslt_id           NUMBER         := ben_ext_thread.g_ext_rslt_id;
      l_total_value       NUMBER         := 0;
      l_fmt_total_value   VARCHAR2 (12);
      l_val_seq           VARCHAR2 (100);
      l_ext_rcd_id        NUMBER;
      l_value             NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);

      --

--       IF p_val_seq < 10
--       THEN
--          l_val_seq :=    '0'
--                       || TO_CHAR (p_val_seq);
--       ELSE
--          l_val_seq := TO_CHAR (p_val_seq);
--       END IF; -- End if of val seq < 10 check ...
--
--       l_val_seq :=    'dtl.val_'
--                    || l_val_seq;
      -- 11.5.10_CU2: Performance fix :
      -- get the ben_ext_rcd.ext_rcd_id
      -- and use this one for next cursor
      -- This will prevent FTS on the table.

      OPEN csr_ext_rcd_id (p_hide_flag       => 'N'
                          ,p_rcd_type_cd     => 'D'
                          );
      FETCH csr_ext_rcd_id INTO l_ext_rcd_id;
      CLOSE csr_ext_rcd_id ;

      OPEN csr_get_total(l_ext_rcd_id);
      FETCH csr_get_total INTO l_total_value;
      CLOSE csr_get_total;

      -- Bug Fix 5021075
      IF l_total_value > 999999999999
      THEN
         l_total_value := 999999999999;
      ELSIF l_total_value < 0
      THEN
        l_value := pqp_gb_tp_extract_functions.raise_extract_error
                     (p_business_group_id => g_business_group_id
                     ,p_assignment_id => NULL
                     ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                     ,p_error_number => 94556
                     ,p_token1 => 'Total Contribution'
                     ,p_fatal_flag => 'Y'
                     );
      END IF; -- End if of total value exceed limit check ...

      IF l_total_value >= 0 THEN
        l_fmt_total_value := TRIM (TO_CHAR (l_total_value, '099999999999'));
      ELSE
        l_fmt_total_value := TRIM (TO_CHAR (l_total_value, 'S09999999999'));
      END IF;
      DEBUG (   'Total Value: '
             || l_fmt_total_value);
      debug_exit (l_proc_name);
      RETURN l_fmt_total_value;
   END get_data_element_total_value;


--
-- End of Starters Report functions
--
-- Annual Report Function Begins

-- This function checks whether an employee is a member of the pension scheme
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_is_employee_a_member >-------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_is_employee_a_member (
      p_assignment_id          IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2
   IS

--
      l_proc_name        VARCHAR2 (60)
                                :=    g_proc_name
                                   || 'chk_is_employee_a_member';
      l_eet_details      csr_get_eet_info%ROWTYPE;
      l_inclusion_flag   VARCHAR2 (1);

--
   BEGIN
      debug_enter (l_proc_name);
      DEBUG ('Check Element entries exists with pension elements');
      -- Check element entries exist with pension ele's
      l_inclusion_flag := 'N';
      OPEN csr_get_eet_info (
         c_assignment_id=> p_assignment_id,
         c_effective_start_date=> p_effective_start_date,
         c_effective_end_date=> p_effective_end_date
      );

      LOOP
         DEBUG ('Fetch element entries');
         FETCH csr_get_eet_info INTO l_eet_details;
         EXIT WHEN csr_get_eet_info%NOTFOUND;

         -- Check atleast one pension element exists for this assignment
         IF g_pension_ele_ids.EXISTS (l_eet_details.element_type_id)
         THEN
            -- Element exists, set the inclusion flag to 'Y'
            DEBUG ('Pension element entry exists');
            DEBUG (
                  'Pension Element Id: '
               || TO_CHAR (l_eet_details.element_type_id)
            );
            DEBUG ('effective start date: '|| TO_CHAR(l_eet_details.effective_start_date, 'DD/MON/YYYY'));
            DEBUG ('effective end date: '|| TO_CHAR(l_eet_details.effective_end_date, 'DD/MON/YYYY'));
            IF l_inclusion_flag = 'N' THEN
              g_ele_entry_details (p_assignment_id).element_type_id :=
                                                  l_eet_details.element_type_id;
              g_ele_entry_details (p_assignment_id).element_entry_id :=
                                                 l_eet_details.element_entry_id;
              g_ele_entry_details (p_assignment_id).effective_start_date :=
                                             l_eet_details.effective_start_date;
              g_ele_entry_details (p_assignment_id).effective_end_date :=
                                               l_eet_details.effective_end_date;
              g_ele_entry_details (p_assignment_id).assignment_id :=
                                                                p_assignment_id;
            END IF;
            l_inclusion_flag := 'Y';
--            EXIT;
            IF g_index > 0 AND
               g_pen_ele_details (g_index).element_entry_id = l_eet_details.element_entry_id
            THEN
                -- Extend the dates
                g_pen_ele_details (g_index).effective_start_date := l_eet_details.effective_start_date;
            ELSE
              g_index := g_index + 1;
              DEBUG('g_index: '|| g_index);
              g_pen_ele_details (g_index).element_entry_id :=
                                                  l_eet_details.element_entry_id;
              g_pen_ele_details (g_index).element_type_id :=
                                                  l_eet_details.element_type_id;
              g_pen_ele_details (g_index).effective_start_date :=
                                                  l_eet_details.effective_start_date;
              g_pen_ele_details (g_index).effective_end_date :=
                                                  l_eet_details.effective_end_date;
              g_pen_ele_details (g_index).assignment_id :=
                                                  p_assignment_id;
            END IF; -- End if of g_index > 1 check ...

         END IF; -- End if of pension element entry exists ...
      END LOOP;

      CLOSE csr_get_eet_info;
      debug_exit (l_proc_name);
      RETURN l_inclusion_flag;
   END chk_is_employee_a_member;


-- This function checks whether an assignment/person qualifies for annual CPX
-- report and returns a 'Y', 'N' or 'ERROR'
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_employee_qual_for_annual >------------------|
-- ----------------------------------------------------------------------------

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
      RETURN VARCHAR2 -- Y or N
   IS

--
      l_inclusion_flag      VARCHAR2 (20)  := 'N';
      l_proc_name           VARCHAR2 (61)
                            :=    g_proc_name
                               || 'chk_employee_qual_for_annual';
      l_secondary_asg_ids   t_number;
      l_error_number        NUMBER;
      l_error_text          VARCHAR2 (200);
      l_return              NUMBER;
      i                     NUMBER;

--
   BEGIN
      debug_enter (l_proc_name);
      l_error_text := NULL;
      l_error_number := NULL;
      DEBUG (   'Business Group ID: '
             || TO_CHAR (g_business_group_id));
      DEBUG (   'Assignment ID: '
             || TO_CHAR (p_assignment_id));
      DEBUG (   'Session Date: '
             || p_effective_date);

      IF g_business_group_id IS NULL
      THEN
         g_pension_ele_ids.DELETE;
         g_pension_bal_name := NULL;
         g_pension_ele_name := NULL;
         g_initial_ext_date := NULL;
         g_emp_cont_iv_name := NULL;
         g_superann_refno_iv_name := NULL;
         g_superann_sal_bal_name := NULL;
         g_additional_cont_bal_name := NULL;
         g_buyback_cont_bal_name := NULL;
         g_superann_sal_bal_id := NULL;
         g_additional_cont_bal_id := NULL;
         g_buyback_cont_bal_id := NULL;
         g_ele_entry_details.DELETE;
         g_secondary_asg_ids.DELETE;
         g_asg_details.DELETE;
         g_ni_ele_details.DELETE;
         g_ni_ele_type_id  := NULL;
	 g_ni_cat_iv_id    := NULL;
         g_ni_pen_iv_id    := NULL;
         g_pen_ele_details.DELETE;
         g_index           := 0;

         -- Use STARTERS for starters, HOURCHANGE for hour change and ANNUAL
         -- for Annual report
         g_header_system_element := 'ANNUAL:';
         DEBUG ('Before calling set_extract_globals function');
         l_return :=
               set_extract_globals (
                  p_assignment_id=> p_assignment_id,
                  p_business_group_id=> p_business_group_id,
                  p_effective_date=> ben_ext_person.g_effective_date,
                  p_error_number=> l_error_number,
                  p_error_text=> l_error_text
               );

         IF l_return <> 0
         THEN
            DEBUG ('Function set_extract_globals function is in Error');
            p_error_text := l_error_text;
            p_error_number := l_error_number;
            l_inclusion_flag := 'ERROR';
            debug_exit (l_proc_name);
            RETURN l_inclusion_flag;
         END IF; -- End if of return <> 0 check...

         -- Call procedure get_NI_element_details to populate NI collection
         DEBUG ('Before calling get_NI_element_details procedure');
--         get_ni_element_details;
      END IF;

      DEBUG ('Before calling chk_is_employee_a_member function');
      --
      -- Check the person is a member
      --

      g_pen_ele_details.DELETE;
      g_index := 0;

      l_inclusion_flag :=
            chk_is_employee_a_member (
               p_assignment_id=> p_assignment_id,
               p_effective_start_date=> g_effective_start_date,
               p_effective_end_date=> g_effective_end_date
            );
      DEBUG (   'Inclusion Flag: '
             || l_inclusion_flag);

      IF l_inclusion_flag = 'Y'
      THEN
         DEBUG ('Assignment qualifies for annual report');
         -- Populate assignment details

         set_assignment_details (
            p_assignment_id=> p_assignment_id,
            p_effective_date=> LEAST (
                        g_ele_entry_details (p_assignment_id).effective_end_date,
                        g_effective_end_date
                     )
         );
         DEBUG ('Get Secondary Assignments');
         -- Get Secondary Assignments

         DEBUG ('Before calling all secondary assignments procedure');
         get_all_sec_assignments (
            p_assignment_id=> p_assignment_id,
            p_secondary_asg_ids=> l_secondary_asg_ids
         );
         i := l_secondary_asg_ids.FIRST;

         WHILE i IS NOT NULL
         LOOP
            DEBUG ('Secondary assignment exist');
            DEBUG ('Check this secondary asg qualifies for Annual report');
            DEBUG ('Before calling function chk_is_employee_a_member');

            IF chk_is_employee_a_member (
                  p_assignment_id=> l_secondary_asg_ids (i),
                  p_effective_start_date=> g_effective_start_date,
                  p_effective_end_date=> g_effective_end_date
               ) = 'Y'
            THEN
               DEBUG (
                     TO_CHAR (l_secondary_asg_ids (i))
                  || ' Secondary assignment qualifies'
               );
               g_secondary_asg_ids (i) := l_secondary_asg_ids (i);
            END IF; -- End if of secondary asg check for annual ..

            i := l_secondary_asg_ids.NEXT (i);
         END LOOP; -- End loop of secondary assignments ...
      END IF; -- End if of inclusion Flag Check...

      debug_exit (l_proc_name);
      RETURN l_inclusion_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
         debug_exit (   ' Others in '
                     || l_proc_name, 'Y' -- turn trace off
                                        );
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END chk_employee_qual_for_annual;


-- This function returns the member contribution for a given assignment
-- PS member contribution may use a balance called "Total Pension Contributions"
-- (Default) or the user provided balance name in the CPX definition UDT or
-- determine it from the element/input value run result combo
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_member_contributions >---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_member_contributions (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name              VARCHAR2 (60)
                                :=    g_proc_name
                                   || 'get_member_contributions';
      l_member_contributions   VARCHAR2 (11);
      l_value                  NUMBER        := 0;
      l_input_value_id         NUMBER;
      l_return                 NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);

      IF g_pension_bal_id IS NULL
      THEN
         -- The setup may be in element mode
         -- Get the contribution amount from the run result

         -- Determine the input value id for "Pay Value" name
         DEBUG ('Before calling get_input_value_id function');
         l_input_value_id :=
               get_input_value_id (
                  p_input_value_name=> 'Pay Value',
                  p_element_type_id=> g_ele_entry_details (p_assignment_id).element_type_id,
                  p_effective_date=> g_effective_date
               );

         IF l_input_value_id IS NOT NULL
         THEN
            -- Get the person runresult value for the element/iv combo
            DEBUG ('Before calling get_person_ele_rresult_value function');
            l_value :=
                  get_person_ele_rresult_value (
                     p_assignment_id=> p_assignment_id,
                     p_element_type_id=> g_ele_entry_details (
                                 p_assignment_id
                              ).element_type_id,
                     p_input_value_id=> l_input_value_id,
                     p_effective_start_date=> g_effective_start_date,
                     p_effective_end_date=> g_effective_end_date
                  );
         END IF; -- End if of input value id is not null check ...
      -- Bug Fix 5021075
      -- Bug Fix 5057187

         IF l_value > 99999999999
         THEN
            l_value := 99999999999;
         ELSIF l_value < 0 THEN
           l_return := pqp_gb_tp_extract_functions.raise_extract_error
                        (p_business_group_id => g_business_group_id
                        ,p_assignment_id => p_assignment_id
                        ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                        ,p_error_number => 94556
                        ,p_token1 => 'Member Contributions'
                        ,p_fatal_flag => 'N'
                        );
         END IF; -- End if of value exceed max limit check ...

         IF l_value >= 0 THEN
           l_member_contributions := TRIM (TO_CHAR (l_value, '09999999999'));
         ELSE
           l_member_contributions := TRIM (TO_CHAR (l_value, 'S0999999999'));
         END IF;
      ELSE -- Otherwise use the pension bal id from global
         l_member_contributions :=
               get_remuneration_from_bal (
                  p_assignment_id=> p_assignment_id,
                  p_balance_type_id=> g_pension_bal_id,
                  p_effective_start_date=> g_effective_start_date,
                  p_effective_end_date=> g_effective_end_date
               );
         IF TO_NUMBER(l_member_contributions) < 0
         THEN
           l_return := pqp_gb_tp_extract_functions.raise_extract_error
                        (p_business_group_id => g_business_group_id
                        ,p_assignment_id => p_assignment_id
                        ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                        ,p_error_number => 94556
                        ,p_token1 => 'Member Contributions'
                        ,p_fatal_flag => 'N'
                        );
         END IF;
      END IF; -- End if of pension bal id is null check ...

      DEBUG (   'Member Contributions: '
             || l_member_contributions);
      debug_exit (l_proc_name);
      RETURN l_member_contributions;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_member_contributions;


-- This function returns the Employees' National Earnings for a given assignment
-- PS NI Earnings has a balance called "NI Employee"
-- This balance has no dimensions so a different function has to be used to
-- determine it's value
-- Change the NI Employee to NIable Pay as we need earnings figure
-- and not contributions
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_NI_earnings >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ni_earnings (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      -- Cursor to get NI element details
      -- for this person
      CURSOR csr_get_ele_ent_details (c_assignment_id NUMBER
                                     ,c_effective_start_date DATE
                                     ,c_effective_end_date DATE)
      IS
         SELECT   pee.element_entry_id, pee.effective_start_date
                 ,pee.effective_end_date, pel.element_type_id
             FROM pay_element_entries_f pee, pay_element_links_f pel
            WHERE pee.assignment_id = c_assignment_id
              AND pee.entry_type = 'E'
              AND pee.element_link_id = pel.element_link_id
              AND (
                      c_effective_start_date BETWEEN pee.effective_start_date
                                                 AND pee.effective_end_date
                   OR c_effective_end_date BETWEEN pee.effective_start_date
                                               AND pee.effective_end_date
                   OR pee.effective_start_date BETWEEN c_effective_start_date
                                                   AND c_effective_end_date
                   OR pee.effective_end_date BETWEEN c_effective_start_date
                                                 AND c_effective_end_date
                  )
              AND pel.element_type_id = g_ni_ele_type_id
              AND (
                      c_effective_start_date BETWEEN pel.effective_start_date
                                                 AND pel.effective_end_date
                   OR c_effective_end_date BETWEEN pel.effective_start_date
                                               AND pel.effective_end_date
                   OR pel.effective_start_date BETWEEN c_effective_start_date
                                                   AND c_effective_end_date
                   OR pel.effective_end_date BETWEEN c_effective_start_date
                                                 AND c_effective_end_date
                  )
         ORDER BY pee.effective_start_date DESC;

      -- Cursor to get screen entry value

      CURSOR csr_get_screen_ent_val(
         c_element_entry_id       NUMBER
        ,c_input_value_id         NUMBER
        ,c_effective_start_date   DATE
        ,c_effective_end_date     DATE
      )
      IS
         SELECT screen_entry_value, effective_start_date, effective_end_date
           FROM pay_element_entry_values_f
          WHERE element_entry_id = c_element_entry_id
            AND (
                    effective_start_date BETWEEN c_effective_start_date
                                             AND c_effective_end_date
                 OR effective_end_date BETWEEN c_effective_start_date
                                           AND c_effective_end_date
                 OR c_effective_start_date BETWEEN effective_start_date
                                               AND effective_end_date
                 OR c_effective_end_date BETWEEN effective_start_date
                                             AND effective_end_date
                )
            AND input_value_id = c_input_value_id;

      CURSOR csr_get_end_date (
          c_assignment_id          NUMBER,
          c_effective_date         DATE
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
                      AND c_effective_date BETWEEN ptp.start_date
                                               AND ptp.end_date
                      AND ppa.action_type IN ('R', 'Q', 'I', 'V', 'B')
                      AND NVL (ppa.business_group_id, g_business_group_id) =
                                                              g_business_group_id
                      AND paa.assignment_id = c_assignment_id
                 ORDER BY ptp.end_date;



      l_proc_name      VARCHAR2 (60) :=    g_proc_name
                                        || 'get_NI_earnings';
      l_ni_earnings    VARCHAR2 (11);
      l_bal_type_id    NUMBER;
      l_value          NUMBER := 0;
      l_rec_ele_ent_details csr_get_ele_ent_details%ROWTYPE;
      l_rec_screen_ent_val  csr_get_screen_ent_val%ROWTYPE;
      l_balance_name   pay_balance_types.balance_name%TYPE;
      l_total_value    NUMBER := 0;
      i                NUMBER;
      j                NUMBER;
      l_effective_date DATE;
      l_return         NUMBER;
      l_secondary_asg_ids t_number;
      l_ni_category    pay_element_entry_values_f.screen_entry_value%TYPE;
      l_end_date       DATE;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      -- Bug Fix 4721921
--       l_effective_date := LEAST (
--                                  g_ele_entry_details (p_assignment_id).effective_end_date,
--                                  g_effective_end_date
--                                 );
      get_eligible_sec_assignments (
         p_assignment_id=> p_assignment_id,
         p_secondary_asg_ids=> l_secondary_asg_ids
      );

      i := g_pen_ele_details.FIRST;
      WHILE i IS NOT NULL
      LOOP
        DEBUG('g_pen_ele_details(i).effective_start_date: '
              || TO_CHAR(g_pen_ele_details(i).effective_start_date, 'DD/MON/YYYY'));
        DEBUG('g_pen_ele_details(i).effective_end_date: '
              || TO_CHAR(g_pen_ele_details(i).effective_end_date, 'DD/MON/YYYY'));
        DEBUG('g_pen_ele_details(i).assignment_id: '
              || g_pen_ele_details(i).assignment_id);

        IF g_pen_ele_details(i).assignment_id = p_assignment_id OR
           l_secondary_asg_ids.EXISTS(g_pen_ele_details(i).assignment_id)
        THEN
          OPEN csr_get_ele_ent_details(g_pen_ele_details(i).assignment_id
                                      ,GREATEST(g_effective_start_date,
                                       g_pen_ele_details(i).effective_start_date)
                                      ,LEAST(g_effective_end_date,
                                       g_pen_ele_details(i).effective_end_date)
                                      );
          LOOP
            FETCH csr_get_ele_ent_details INTO l_rec_ele_ent_details;
            EXIT WHEN csr_get_ele_ent_details%NOTFOUND;

            l_ni_category := get_ele_entry_value
                                  (p_element_entry_id     => l_rec_ele_ent_details.element_entry_id
                                  ,p_input_value_id       => g_ni_cat_iv_id
                                  ,p_effective_start_date => l_rec_ele_ent_details.effective_start_date
                                  ,p_effective_end_date   => l_rec_ele_ent_details.effective_end_date
                                  );
            DEBUG('l_ni_category: '||l_ni_category);
            j := g_ni_cont_out_ele_ids.FIRST;
            WHILE j IS NOT NULL
            LOOP
              DEBUG ('g_ni_cont_out_ele_ids(j).category: '||g_ni_cont_out_ele_ids(j).category);
              IF g_ni_cont_out_ele_ids(j).category = l_ni_category
              THEN
                l_balance_name := 'NI '|| g_ni_cont_out_ele_ids(j).category || ' Able UEL';
                DEBUG('l_balance_name: '||l_balance_name);
                l_bal_type_id := get_pay_bal_id (p_balance_name => l_balance_name);
                l_end_date := NULL;
                OPEN csr_get_end_date (g_pen_ele_details(i).assignment_id,
                                       LEAST(g_effective_end_date,
                                       g_pen_ele_details(i).effective_end_date,
                                       l_rec_ele_ent_details.effective_end_date));
                FETCH csr_get_end_date INTO l_end_date;
                CLOSE csr_get_end_date;
                DEBUG('l_end_date: '|| TO_CHAR(l_end_date, 'DD/MON/YYYY'));
                l_value := hr_gbbal.calc_balance (
                   p_assignment_id=> g_pen_ele_details(i).assignment_id,
                   p_balance_type_id=> l_bal_type_id,
                   p_period_from_date=> GREATEST(g_effective_start_date,
                                        g_pen_ele_details(i).effective_start_date,
                                        l_rec_ele_ent_details.effective_start_date),
                   p_event_from_date=> GREATEST(g_effective_start_date,
                                        g_pen_ele_details(i).effective_start_date,
                                        l_rec_ele_ent_details.effective_start_date),
                   p_to_date=> l_end_date,
                   p_action_sequence=> NULL
                );
                DEBUG ('l_value: '|| l_value);
                l_total_value := l_total_value + l_value;

                l_balance_name := 'NI '|| g_ni_cont_out_ele_ids(j).category || ' Able ET';
                DEBUG('l_balance_name: '||l_balance_name);
                l_bal_type_id := get_pay_bal_id (p_balance_name => l_balance_name);
                l_value := hr_gbbal.calc_balance (
                   p_assignment_id=> g_pen_ele_details(i).assignment_id,
                   p_balance_type_id=> l_bal_type_id,
                   p_period_from_date=> GREATEST(g_effective_start_date,
                                        g_pen_ele_details(i).effective_start_date,
                                        l_rec_ele_ent_details.effective_start_date),
                   p_event_from_date=> GREATEST(g_effective_start_date,
                                        g_pen_ele_details(i).effective_start_date,
                                        l_rec_ele_ent_details.effective_start_date),
                   p_to_date=> l_end_date,
                   p_action_sequence=> NULL
                );
                DEBUG ('l_value: '|| l_value);
                l_total_value := l_total_value + l_value;

--Start of Bug 7312374 Fix for UAP Changes
                l_balance_name := 'NI '|| g_ni_cont_out_ele_ids(j).category || ' Able UAP';
                DEBUG('l_balance_name: '||l_balance_name);
                l_bal_type_id := null;
                l_bal_type_id := get_pay_bal_id (p_balance_name => l_balance_name);
                if l_bal_type_id is not null
                then
                    l_value := hr_gbbal.calc_balance (
                       p_assignment_id=> g_pen_ele_details(i).assignment_id,
                       p_balance_type_id=> l_bal_type_id,
                       p_period_from_date=> GREATEST(g_effective_start_date,
                                            g_pen_ele_details(i).effective_start_date,
                                            l_rec_ele_ent_details.effective_start_date),
                       p_event_from_date=> GREATEST(g_effective_start_date,
                                            g_pen_ele_details(i).effective_start_date,
                                            l_rec_ele_ent_details.effective_start_date),
                       p_to_date=> l_end_date,
                       p_action_sequence=> NULL
                    );
                    DEBUG ('l_value: '|| l_value);
                    l_total_value := l_total_value + l_value;
                end if;

--End of Bug 7312374 Fix for UAP Changes

                EXIT;
              END IF; -- Category matches
              j := g_ni_cont_out_ele_ids.NEXT(j);
            END LOOP; -- contracted out ele ids pl/sql collection
          END LOOP; -- cursor loop
          CLOSE csr_get_ele_ent_details;
        END IF; -- End if of assignment id matches check ...
        i := g_pen_ele_details.NEXT(i);
      END LOOP; -- pen ele details collection

      l_total_value := l_total_value * 100;
      -- Bug Fix 5021075

      IF l_total_value > 99999999999
      THEN
         l_total_value := 99999999999;
      ELSIF l_total_value < 0
      THEN
        l_return := pqp_gb_tp_extract_functions.raise_extract_error
                     (p_business_group_id => g_business_group_id
                     ,p_assignment_id => p_assignment_id
                     ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                     ,p_error_number => 94556
                     ,p_token1 => 'NI Earnings'
                     ,p_fatal_flag => 'N'
                     );
      END IF; -- End if of value exceed max limit check ...

      IF l_total_value >= 0 THEN
        l_ni_earnings := TRIM (TO_CHAR (l_total_value, '09999999999'));
      ELSE
        l_ni_earnings := TRIM (TO_CHAR (l_total_value, 'S0999999999'));
      END IF;
      DEBUG (   'NI Earnings: '
             || l_ni_earnings);
      debug_exit (l_proc_name);
      RETURN l_ni_earnings;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_ni_earnings;


-- This function returns the additional contribution for a given assignment
-- PS Additional Contribution has a balance called "Total Additional Contributions"
-- (Default) or the user provided balance name in the CPX definition UDT
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_additional_contributions >-----------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_additional_contributions (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name           VARCHAR2 (60)
                            :=    g_proc_name
                               || 'get_additional_contributions';
      l_add_contributions   VARCHAR2 (11);
      l_value               NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_add_contributions :=
            get_remuneration_from_bal (
               p_assignment_id=> p_assignment_id,
               p_balance_type_id=> g_additional_cont_bal_id,
               p_effective_start_date=> g_effective_start_date,
               p_effective_end_date=> g_effective_end_date
            );
      -- Bug Fix 5021075
      IF TO_NUMBER(l_add_contributions) < 0 THEN
        l_value := pqp_gb_tp_extract_functions.raise_extract_error
                     (p_business_group_id => g_business_group_id
                     ,p_assignment_id => p_assignment_id
                     ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                     ,p_error_number => 94556
                     ,p_token1 => 'Additional Contributions'
                     ,p_fatal_flag => 'N'
                     );
      END IF;
      DEBUG (   'Additional Contributions: '
             || l_add_contributions);
      debug_exit (l_proc_name);
      RETURN l_add_contributions;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_additional_contributions;


-- This function returns the buy back contribution for a given assignment
-- PS BuyBack contribution has a balance called "Total BuyBack Contributions"
-- (Default) or the user provided balance name in the CPX definition UDT
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_buyback_contributions >-----------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_buyback_contributions (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name               VARCHAR2 (60)
                               :=    g_proc_name
                                  || 'get_buyback_contributions';
      l_buyback_contributions   VARCHAR2 (11);
      l_value                   NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      l_buyback_contributions :=
            get_remuneration_from_bal (
               p_assignment_id=> p_assignment_id,
               p_balance_type_id=> g_buyback_cont_bal_id,
               p_effective_start_date=> g_effective_start_date,
               p_effective_end_date=> g_effective_end_date
            );
      -- Bug Fix 5021075
      IF TO_NUMBER(l_buyback_contributions) < 0 THEN
        l_value := pqp_gb_tp_extract_functions.raise_extract_error
                     (p_business_group_id => g_business_group_id
                     ,p_assignment_id => p_assignment_id
                     ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                     ,p_error_number => 94556
                     ,p_token1 => 'BuyBack Contribution'
                     ,p_fatal_flag => 'N'
                     );
      END IF;
      DEBUG (   'BuyBack Contributions: '
             || l_buyback_contributions);
      debug_exit (l_proc_name);
      RETURN l_buyback_contributions;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_buyback_contributions;


--
-- Added for Hour Change Report
--



-- This function checks whether an assignment/person qualifies for PTHRCH CPX
-- report and returns a 'Y', 'N' or 'ERROR'
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_employee_qual_for_pthrch >------------------|
-- ----------------------------------------------------------------------------

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
      RETURN VARCHAR2 -- Y or N
   IS

--
      l_inclusion_flag      VARCHAR2 (20)                            := 'N';
      l_proc_name           VARCHAR2 (61)
                            :=    g_proc_name
                               || 'chk_employee_qual_for_pthrch';
      l_secondary_asg_ids   t_number;
      l_error_number        NUMBER;
      l_error_text          VARCHAR2 (200);
      l_return              NUMBER;
      i                     NUMBER;
      l_event_details       pqp_utilities.t_event_details_table_type;

--
   BEGIN
      debug_enter (l_proc_name);
      l_error_text := NULL;
      l_error_number := NULL;
      DEBUG (   'Business Group ID: '
             || TO_CHAR (g_business_group_id));
      DEBUG (   'Assignment ID: '
             || TO_CHAR (p_assignment_id));
      DEBUG (   'Session Date: '
             || p_effective_date);

      IF g_business_group_id IS NULL
      THEN
         g_pension_ele_ids.DELETE;
         g_pension_bal_name := NULL;
         g_pension_ele_name := NULL;
         g_initial_ext_date := NULL;
         g_emp_cont_iv_name := NULL;
         g_superann_refno_iv_name := NULL;
         g_superann_sal_bal_name := NULL;
         g_additional_cont_bal_name := NULL;
         g_buyback_cont_bal_name := NULL;
         g_superann_sal_bal_id := NULL;
         g_additional_cont_bal_id := NULL;
         g_buyback_cont_bal_id := NULL;
         g_ele_entry_details.DELETE;
         g_secondary_asg_ids.DELETE;
         g_asg_details.DELETE;
         g_ni_ele_details.DELETE;
         g_ni_ele_type_id  := NULL;
	 g_ni_cat_iv_id    := NULL;
         g_ni_pen_iv_id    := NULL;
         g_pen_ele_details.DELETE;
         g_index           := 0;

         -- Use STARTERS for starters, HOURCHANGE for hour change and ANNUAL
         -- for Annual report
         g_header_system_element := 'HOURCHANGE:';
         DEBUG ('Before calling set_extract_globals function');
         l_return :=
               set_extract_globals (
                  p_assignment_id=> p_assignment_id,
                  p_business_group_id=> p_business_group_id,
                  p_effective_date=> ben_ext_person.g_effective_date,
                  p_error_number=> l_error_number,
                  p_error_text=> l_error_text
               );

         IF l_return <> 0
         THEN
            DEBUG ('Function set_extract_globals function is in Error');
            p_error_text := l_error_text;
            p_error_number := l_error_number;
            l_inclusion_flag := 'ERROR';
            debug_exit (l_proc_name);
            RETURN l_inclusion_flag;
         END IF; -- End if of return <> 0 check...
      END IF;

      DEBUG ('Before calling chk_is_employee_a_member function');
      --
      -- Check the person is a member
      --

      g_pen_ele_details.DELETE;
      g_index := 0;

      l_inclusion_flag :=
            chk_is_employee_a_member (
               p_assignment_id=> p_assignment_id,
               p_effective_start_date=> g_effective_start_date,
               p_effective_end_date=> g_effective_end_date
            );
      DEBUG (   'Inclusion Flag: '
             || l_inclusion_flag);
      l_event_details.DELETE;

      IF      l_inclusion_flag = 'Y'
          AND -- One or more HOUR CHANGE events have been found
             pqp_utilities.get_events (
                p_assignment_id=> p_assignment_id,
                p_business_group_id=> p_business_group_id,
                p_process_mode=> 'ENTRY_CREATION_DATE',
                p_event_group_name=> 'PQP_GB_CPX_HOUR_CHANGE',
                p_start_date=> g_effective_start_date,
                p_end_date=> g_effective_end_date,
                t_event_details=> l_event_details -- OUT
             ) > 0 -- Zero
      THEN
         DEBUG ('Assignment qualifies for PTHRCH report');
         -- Populate assignment details

         set_assignment_details (
            p_assignment_id=> p_assignment_id,
            p_effective_date=> LEAST (
                        g_ele_entry_details (p_assignment_id).effective_end_date,
                        g_effective_end_date
                     )
         );
         DEBUG ('Get Secondary Assignments');
         -- Get Secondary Assignments

         DEBUG ('Before calling all secondary assignments procedure');
         get_all_sec_assignments (
            p_assignment_id=> p_assignment_id,
            p_secondary_asg_ids=> l_secondary_asg_ids
         );
         i := l_secondary_asg_ids.FIRST;

         WHILE i IS NOT NULL
         LOOP
            DEBUG ('Secondary assignment exist');
            DEBUG ('Check this secondary asg qualifies for PTHRCH report');
            DEBUG ('Before calling function chk_is_employee_a_member');
            l_event_details.DELETE;

            IF      chk_is_employee_a_member (
                       p_assignment_id=> l_secondary_asg_ids (i),
                       p_effective_start_date=> g_effective_start_date,
                       p_effective_end_date=> g_effective_end_date
                    ) = 'Y'
                AND -- One or more HOUR CHANGE events have been found
                   pqp_utilities.get_events (
                      p_assignment_id=> l_secondary_asg_ids (i),
                      p_business_group_id=> p_business_group_id,
                      p_process_mode=> 'ENTRY_CREATION_DATE',
                      p_event_group_name=> 'PQP_GB_CPX_HOUR_CHANGE',
                      p_start_date=> g_effective_start_date,
                      p_end_date=> g_effective_end_date,
                      t_event_details=> l_event_details -- OUT
                   ) > 0 -- Zero
            THEN
               DEBUG (
                     TO_CHAR (l_secondary_asg_ids (i))
                  || ' Secondary assignment qualifies'
               );
               g_secondary_asg_ids (i) := l_secondary_asg_ids (i);
            END IF; -- End if of secondary asg check for pthrch ..

            i := l_secondary_asg_ids.NEXT (i);
         END LOOP; -- End loop of secondary assignments ...
      --
      ELSE -- Either HOUR CHANGE events NOTFOUND OR flag was already N
         l_inclusion_flag := 'N';
      END IF; -- End if of inclusion Flag Check...

      debug_exit (l_proc_name);
      RETURN l_inclusion_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
         debug_exit (   ' Others in '
                     || l_proc_name, 'Y' -- turn trace off
                                        );
         p_error_number := SQLCODE;
         p_error_text := SQLERRM;
         RAISE;
   END chk_employee_qual_for_pthrch;


-- This function gets the fte value for a given assignment and effective date
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_fte_value >---------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_fte_value (p_assignment_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER
   IS

--
      l_proc_name   VARCHAR2 (60) :=    g_proc_name
                                     || 'get_fte_value';
      l_fte_value   NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      OPEN csr_get_fte_value (p_assignment_id, p_effective_date);
      FETCH csr_get_fte_value INTO l_fte_value;
      CLOSE csr_get_fte_value;
      l_fte_value := NVL (l_fte_value, 0);
      DEBUG (
            TO_CHAR (p_assignment_id)
         || ' FTE Value: '
         || TO_CHAR (l_fte_value)
      );
      debug_exit (l_proc_name);
      RETURN l_fte_value;
   END get_fte_value;


--

-- This function gets the part time hours or percent value for a given
-- assignment
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_part_time_percent >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_part_time_percent (p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS

--
      l_proc_name           VARCHAR2 (60)
                                   :=    g_proc_name
                                      || 'get_part_time_percent';
      l_part_time_percent   VARCHAR2 (11);
      l_value               NUMBER;
      i                     NUMBER;
      l_secondary_asg_ids   t_number;
      l_return_value        NUMBER;

--
   BEGIN
      --
      debug_enter (l_proc_name);
      DEBUG ('Primary Assignment');
      -- Get fte value for primary assignment
      l_value :=
            get_fte_value (
               p_assignment_id=> p_assignment_id,
               p_effective_date=> LEAST (
                           g_ele_entry_details (p_assignment_id).effective_end_date,
                           g_effective_end_date
                        )
            );
      -- Check for secondary assignments
      DEBUG ('Secondary Assignment');
      get_eligible_sec_assignments (
         p_assignment_id=> p_assignment_id,
         p_secondary_asg_ids=> l_secondary_asg_ids
      );
      i := l_secondary_asg_ids.FIRST;

      WHILE i IS NOT NULL
      LOOP
         IF g_ele_entry_details.EXISTS (i)
         THEN
            -- Get fte value for this assignment
            l_value :=
                    l_value
                  + get_fte_value (
                       p_assignment_id=> l_secondary_asg_ids (i),
                       p_effective_date=> GREATEST (
                                   g_ele_entry_details (
                                      l_secondary_asg_ids (i)
                                   ).effective_start_date,
                                   g_effective_start_date
                                )
                    );
         END IF; -- End if of element entry details exists check...

         i := l_secondary_asg_ids.NEXT (i);
      END LOOP; -- End loop of secondary assignments ...

      l_value := l_value * POWER (10, 10);
      DEBUG (   'Value before formatting : '
             || TO_CHAR (l_value));
      -- Bug Fix 5021075
      IF l_value < 0 THEN
        l_return_value := pqp_gb_tp_extract_functions.raise_extract_error
                       (p_business_group_id => g_business_group_id
                       ,p_assignment_id => p_assignment_id
                       ,p_error_text => 'BEN_94556_EXT_VALUE_ERROR'
                       ,p_error_number => 94556
                       ,p_token1 => 'Part Time Percent'
                       ,p_fatal_flag => 'N'
                       );
      END IF;
      IF l_value >= 0 THEN
        l_part_time_percent := TRIM (TO_CHAR (l_value, '09999999999'));
      ELSE
        l_part_time_percent := TRIM (TO_CHAR (l_value, 'S0999999999'));
      END IF;
      DEBUG (   'Part Time Percent: '
             || l_part_time_percent);
      debug_exit (l_proc_name);
      RETURN l_part_time_percent;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (   ' Others in '
                || l_proc_name, 'Y' -- turn trace off
                                   );
         RAISE;
   END get_part_time_percent;
   --
--
END pqp_gb_cpx_extract_functions;

/
