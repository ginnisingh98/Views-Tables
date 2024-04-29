--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_HRS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_HRS_HISTORY" 
--  /* $Header: pqpgbpsihrs.pkb 120.0.12000000.2 2007/02/13 13:48:38 mseshadr noship $ */
AS
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE DEBUG(p_trace_message IN VARCHAR2, p_trace_location IN NUMBER)
   IS
--
   BEGIN
      --

      pqp_utilities.DEBUG(
         p_trace_message       => p_trace_message
        ,p_trace_location      => p_trace_location
      );
   --
   END DEBUG;

-- This procedure is used for debug purposes
-- debug_enter checks the debug flag and sets the trace on/off
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_enter >-------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_enter(p_proc_name IN VARCHAR2, p_trace_on IN VARCHAR2)
   IS
   BEGIN
      --
      IF pqp_utilities.g_nested_level = 0
      THEN
         hr_utility.trace_on(NULL, 'REQID'); -- Pipe name REQIDnnnnn
      END IF;

      pqp_utilities.debug_enter(p_proc_name => p_proc_name
        ,p_trace_on       => p_trace_on);
   --
   END debug_enter;

-- This procedure is used for debug purposes
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_exit >--------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_exit(p_proc_name IN VARCHAR2, p_trace_off IN VARCHAR2)
   IS
   BEGIN
      --
      pqp_utilities.debug_exit(p_proc_name => p_proc_name
        ,p_trace_off      => p_trace_off);

      -- debug enter sets trace ON when g_trace = 'Y' and nested level = 0
       -- so we must turn it off for the same condition
       -- Also turn off tracing when the override flag of p_trace_off has been passed as Y
      IF pqp_utilities.g_nested_level = 0
      THEN
         hr_utility.trace_off;
      END IF; -- (g_nested_level = 0

              --
   END debug_exit;

-- This procedure is used for debug purposes
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_others >------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_others(p_proc_name IN VARCHAR2, p_proc_step IN NUMBER)
   IS
   BEGIN
      --
      pqp_utilities.debug_others(p_proc_name => p_proc_name
        ,p_proc_step      => p_proc_step);
   --
   END debug_others;

-- This procedure is used to clear all cached global variables
--
-- ----------------------------------------------------------------------------
-- |----------------------------< clear_cache >-------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE clear_cache
   IS
      --
      l_proc_name   VARCHAR2(80) := g_proc_name || 'clear_cache';
      l_proc_step   PLS_INTEGER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      -- Clear all global variables first
      g_business_group_id       := NULL;
      g_effective_date          := NULL;
      g_extract_type            := NULL;
      g_paypoint                := NULL;
      g_cutover_date            := NULL;
      g_ext_dfn_id              := NULL;
      g_active_asg_sts_id       := NULL;
      g_terminate_asg_sts_id    := NULL;
      g_prev_pay_proc_evnts     := NULL;
      -- Clear all global collections
      g_tab_event_map_cv.DELETE;
      g_tab_asg_status.DELETE;
      g_tab_pen_sch_map_cv.DELETE;
      g_tab_pen_ele_ids.DELETE;
      g_tab_prs_dfn_cv.DELETE;
      g_tab_dated_table.DELETE;

      IF g_debug
      THEN
         debug_exit(l_proc_name);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END clear_cache;

-- This procedure returns the assignment status details
-- for a given assignment status
-- ----------------------------------------------------------------------------
-- |----------------------< get_asg_status_type >-----------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_asg_status_type(
      p_per_system_status   IN              per_assignment_status_types.per_system_status%TYPE
     ,p_rec_asg_sts_dtls    OUT NOCOPY      csr_get_asg_sts_dtls%ROWTYPE
   )
   IS
      --

      l_proc_name          VARCHAR2(80) := g_proc_name || 'get_asg_status_type';
      l_proc_step          PLS_INTEGER;
      l_rec_asg_sts_dtls   csr_get_asg_sts_dtls%ROWTYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_per_system_status: ' || p_per_system_status);
      END IF;

      OPEN csr_get_asg_sts_dtls(p_per_system_status);
      FETCH csr_get_asg_sts_dtls INTO l_rec_asg_sts_dtls;
      CLOSE csr_get_asg_sts_dtls;
      p_rec_asg_sts_dtls    := l_rec_asg_sts_dtls;

      IF g_debug
      THEN
         DEBUG(
               'assignment_status_type_id: '
            || l_rec_asg_sts_dtls.assignment_status_type_id
         );
         DEBUG('user_status: ' || l_rec_asg_sts_dtls.user_status);
         l_proc_step    := 20;
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
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_asg_status_type;

-- This function returns user status
-- for a given assignment status
-- ----------------------------------------------------------------------------
-- |----------------------< get_asg_status_type >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_asg_status_type(p_asg_sts_type_id IN NUMBER)
      RETURN per_assignment_status_types.user_status%TYPE
   IS
      --
      CURSOR csr_get_asg_sts_dtls
      IS
         SELECT user_status
           FROM per_assignment_status_types
          WHERE assignment_status_type_id = p_asg_sts_type_id;

      l_proc_name     VARCHAR2(80)      := g_proc_name || 'get_asg_status_type';
      l_proc_step     PLS_INTEGER;
      l_user_status   per_assignment_status_types.user_status%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_asg_sts_type_id: ' || p_asg_sts_type_id);
      END IF;

      OPEN csr_get_asg_sts_dtls;
      FETCH csr_get_asg_sts_dtls INTO l_user_status;
      CLOSE csr_get_asg_sts_dtls;

      IF g_debug
      THEN
         DEBUG('user_status: ' || l_user_status);
         l_proc_step    := 20;
         debug_exit(l_proc_name);
      END IF;

      RETURN l_user_status;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_asg_status_type;

-- This procedure populates pay dated tables with dated table id
-- and table name so that it can be used in the change event
-- collection
-- ----------------------------------------------------------------------------
-- |----------------------------< set_dated_table_collection >----------------|
-- ----------------------------------------------------------------------------
   PROCEDURE set_dated_table_collection
   IS
      --
      l_proc_name         VARCHAR2(80)
                                 := g_proc_name || 'set_dated_table_collection';
      l_proc_step         PLS_INTEGER;
      l_rec_dated_table   csr_get_dated_table_info%ROWTYPE;
      l_tab_dated_table   t_dated_table;
      i                   NUMBER;
      l_table_name        t_varchar2;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      i                    := 1;
      l_table_name(i)      := 'PER_ALL_ASSIGNMENTS_F';
      i                    := i + 1;
      l_table_name(i)      := 'PAY_ELEMENT_ENTRIES_F';
      i                    := i + 1;
      l_table_name(i)      := 'PER_ALL_PEOPLE_F';
      i                    := i + 1;
      l_table_name(i)      := 'PER_ASSIGNMENT_BUDGET_VALUES_F';
      i                    := i + 1;
      l_table_name(i)      := 'PQP_ASSIGNMENT_ATTRIBUTES_F';

      WHILE i > 0
      LOOP
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_table_name(' || i || '): ' || l_table_name(i));
         END IF;

         OPEN csr_get_dated_table_info(l_table_name(i));
         FETCH csr_get_dated_table_info INTO l_rec_dated_table;
         CLOSE csr_get_dated_table_info;
         l_tab_dated_table(l_rec_dated_table.dated_table_id)    :=
                                                               l_rec_dated_table;

         IF g_debug
         THEN
            l_proc_step    := 30;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('dated_table_id: ' || l_rec_dated_table.dated_table_id);
            DEBUG('Table Name: ' || l_rec_dated_table.table_name);
            DEBUG('Surrogate Key Col: ' || l_rec_dated_table.surrogate_key_name);
         END IF;

         i                                                      := i - 1;
      END LOOP;

      -- set the global
      g_tab_dated_table    := l_tab_dated_table;

      IF g_debug
      THEN
         l_proc_step    := 40;
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
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END set_dated_table_collection;

   --

-- This procedure is used to populate event groups collection
-- for service history
-- ----------------------------------------------------------------------------
-- |----------------------------< set_event_group_collection >----------------|
-- ----------------------------------------------------------------------------
   PROCEDURE set_event_group_collection
   IS
      --
      l_proc_name         VARCHAR2(80)
                                 := g_proc_name || 'set_event_group_collection';
      l_proc_step         PLS_INTEGER;
      l_rec_event_group   csr_get_event_group_info%ROWTYPE;
      l_tab_event_group   t_event_group;
      i                   NUMBER;
      l_event_group       t_varchar2;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      i                    := 1;
      l_event_group(i)     := 'PQP_GB_PSI_FTE_VALUE';
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_ASSIGNMENT_STATUS';
--       i                    := i + 1;
--       l_event_group(i)     := 'PQP_GB_PSI_NEW_HIRE';
--       i                    := i + 1;
--       l_event_group(i)     := 'PQP_GB_PSI_NI_NUMBER';
--       i                    := i + 1;
--       l_event_group(i)     := 'PQP_GB_PSI_ASSIGNMENT_NUMBER';
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_EMP_TERMINATIONS';
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_SAL_CONTRACT';

      WHILE i > 0
      LOOP
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_event_group(' || i || '): ' || l_event_group(i));
         END IF;

         OPEN csr_get_event_group_info(l_event_group(i));
         FETCH csr_get_event_group_info INTO l_rec_event_group;

         IF csr_get_event_group_info%NOTFOUND
         THEN
            -- Raise an error
            pqp_gb_psi_functions.store_extract_exceptions(
               p_extract_type            => 'PART_TIME_HOURS'
              ,p_error_number            => 94423
              ,p_error_text              => 'BEN_94423_EXT_PSI_NO_EVNT_GRP'
              ,p_token1                  => l_event_group(i)
              ,p_error_warning_flag      => 'E'
            );
         END IF;

         CLOSE csr_get_event_group_info;
         l_tab_event_group(l_rec_event_group.event_group_id)    :=
                                                               l_rec_event_group;

         IF g_debug
         THEN
            l_proc_step    := 30;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('event_group_id: ' || l_rec_event_group.event_group_id);
            DEBUG('event_group_name: ' || l_rec_event_group.event_group_name);
            DEBUG('event_group_type: ' || l_rec_event_group.event_group_type);
         END IF;

         i                                                      := i - 1;
      END LOOP;

      -- set the global
      g_tab_event_group    := l_tab_event_group;

      IF g_debug
      THEN
         l_proc_step    := 40;
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
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END set_event_group_collection;

-- This procedure is used to set any globals needed for this extract
--
-- ----------------------------------------------------------------------------
-- |----------------------------< set_hrs_history_globals >-------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE set_hrs_history_globals(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
   )
   IS
      --
      l_proc_name           VARCHAR2(80)
                              := g_proc_name || 'set_hrs_history_globals';
      l_proc_step           PLS_INTEGER;
      l_input_value_name    pay_input_values_f.NAME%TYPE;
      l_input_value_id      NUMBER;
      l_element_type_id     NUMBER;
      l_tab_config_values   pqp_utilities.t_config_values;
      i                     NUMBER;
      l_rec_asg_sts_dtls    csr_get_asg_sts_dtls%ROWTYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_business_group_id: ' || p_business_group_id);
         DEBUG('p_effective_date: '
            || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
      END IF;

      -- set global variables
      g_business_group_id       := p_business_group_id;

      g_effective_date          := p_effective_date;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      -- Get the assignment status type id for
      -- active assignments
      get_asg_status_type(
         p_per_system_status      => 'ACTIVE_ASSIGN'
        ,p_rec_asg_sts_dtls       => l_rec_asg_sts_dtls
      );
      g_active_asg_sts_id       :=
                                  l_rec_asg_sts_dtls.assignment_status_type_id;

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      -- Get the assignment status type id for
      -- terminations
      get_asg_status_type(
         p_per_system_status      => 'TERM_ASSIGN'
        ,p_rec_asg_sts_dtls       => l_rec_asg_sts_dtls
      );
      g_terminate_asg_sts_id    :=
                                  l_rec_asg_sts_dtls.assignment_status_type_id;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      IF g_extract_type = 'PERIODIC'
      THEN
         IF g_debug
         THEN
            l_proc_step    := 50;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- populated dated table ids
         set_dated_table_collection;

         -- populate event group colleciton
         IF g_debug
         THEN
            l_proc_step    := 60;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         set_event_group_collection;
      END IF; -- End if of extract type = periodic check ...

      IF g_debug
      THEN
         l_proc_step    := 70;
         DEBUG('g_business_group_id: ' || g_business_group_id);
         DEBUG('g_effective_date: '
            || TO_CHAR(g_effective_date, 'DD/MON/YYYY'));
         DEBUG('g_extract_type: ' || g_extract_type);
         DEBUG('g_active_asg_sts_id: ' || g_active_asg_sts_id);
         DEBUG('g_terminate_asg_sts_id: ' || g_terminate_asg_sts_id);
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
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END set_hrs_history_globals;

-- This procedure gets assignment budget value information
-- for a given assignment as at an effective date
-- ----------------------------------------------------------------------------
-- |---------------------< get_abv_details >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_abv_details (p_assignment_id  IN            NUMBER
                             ,p_effective_date IN            DATE
                             ,p_rec_abv_dtls      OUT NOCOPY csr_abv_dtls%ROWTYPE
                             )
   IS
   --
     l_proc_name    VARCHAR2(80) := g_proc_name || 'get_abv_details';
     l_proc_step    PLS_INTEGER;
     l_rec_abv_dtls csr_abv_dtls%ROWTYPE;
     l_value        NUMBER;
   --
   BEGIN
     --
     IF g_debug
     THEN
       --
       l_proc_step := 10;
       debug_enter(l_proc_name);
       debug('p_assignment_id: '||p_assignment_id);
       debug('p_effective_date: '||TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
     END IF;

     OPEN csr_abv_dtls (p_assignment_id
                       ,p_effective_date
                       );
     FETCH csr_abv_dtls INTO l_rec_abv_dtls;
     IF csr_abv_dtls%NOTFOUND THEN
       -- Raise an error
       IF g_debug THEN
         --
         l_proc_step := 20;
         debug(l_proc_name, l_proc_step);
         debug('Raise abv not found error');
       END IF;
       -- Raise data error
       l_value    :=
            pqp_gb_psi_functions.raise_extract_error(
               p_error_number      => 94479
              ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
              ,p_token1            => 'FTE'
            );
     END IF;
     CLOSE csr_abv_dtls;
     p_rec_abv_dtls := l_rec_abv_dtls;

      IF g_debug
      THEN
         l_proc_step    := 30;
         debug('l_rec_abv_dtls.assignment_id: '|| l_rec_abv_dtls.assignment_id);
         debug('l_rec_abv_dtls.effective_start_date: '||TO_CHAR(l_rec_abv_dtls.effective_start_date, 'DD/MON/YYYY'));
         debug('l_rec_abv_dtls.effective_end_date: '||TO_CHAR(l_rec_abv_dtls.effective_end_date, 'DD/MON/YYYY'));
         debug('l_rec_abv_dtls.unit: '||l_rec_abv_dtls.unit);
         debug('l_rec_abv_dtls.value: '||l_rec_abv_dtls.value);
         debug('l_rec_abv_dtls.assignment_budget_value_id: '||l_rec_abv_dtls.assignment_budget_value_id);
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
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_abv_details;

-- This procedure gets assignment budget value information
-- for a given assignment as at an effective date
-- ----------------------------------------------------------------------------
-- |---------------------< get_abv_details >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_abv_details (p_abv_id         IN            NUMBER
                             ,p_effective_date IN            DATE
                             ,p_rec_abv_dtls      OUT NOCOPY csr_abv_dtls%ROWTYPE
                             )
   IS
   --
     -- Cursor to get abv details
     CURSOR csr_get_abv_dtls
     IS
     SELECT assignment_budget_value_id
           ,assignment_id
           ,effective_start_date
           ,effective_end_date
           ,unit
           ,value
       FROM per_assignment_budget_values_f
      WHERE assignment_budget_value_id = p_abv_id
        AND p_effective_date BETWEEN effective_start_date
                                 AND effective_end_date;

     l_proc_name    VARCHAR2(80) := g_proc_name || 'get_abv_details';
     l_proc_step    PLS_INTEGER;
     l_rec_abv_dtls csr_abv_dtls%ROWTYPE;
     l_value        NUMBER;
   --
   BEGIN
     --
     IF g_debug
     THEN
       --
       l_proc_step := 10;
       debug_enter(l_proc_name);
       debug('p_abv_id: '||p_abv_id);
       debug('p_effective_date: '||TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
     END IF;

     OPEN csr_get_abv_dtls;
     FETCH csr_get_abv_dtls INTO l_rec_abv_dtls;
     CLOSE csr_get_abv_dtls;
     p_rec_abv_dtls := l_rec_abv_dtls;

      IF g_debug
      THEN
         l_proc_step    := 20;
         debug('l_rec_abv_dtls.assignment_id: '|| l_rec_abv_dtls.assignment_id);
         debug('l_rec_abv_dtls.effective_start_date: '||TO_CHAR(l_rec_abv_dtls.effective_start_date, 'DD/MON/YYYY'));
         debug('l_rec_abv_dtls.effective_end_date: '||TO_CHAR(l_rec_abv_dtls.effective_end_date, 'DD/MON/YYYY'));
         debug('l_rec_abv_dtls.unit: '||l_rec_abv_dtls.unit);
         debug('l_rec_abv_dtls.value: '||l_rec_abv_dtls.value);
         debug('l_rec_abv_dtls.assignment_budget_value_id: '||l_rec_abv_dtls.assignment_budget_value_id);
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
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_abv_details;

-- This procedure gets full time hours and part time hours
-- information for a given assignment
-- ----------------------------------------------------------------------------
-- |---------------------< get_hrs_data >-------------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_hrs_data (p_assignment_id IN NUMBER
                          ,p_fte           IN NUMBER
                          ,p_ft_hours         OUT NOCOPY NUMBER
                          ,p_pt_hours         OUT NOCOPY NUMBER
                          ,p_hours_type       OUT NOCOPY VARCHAR2
                          )
   IS
   --
     CURSOR csr_get_aat_details
     IS
     SELECT assignment_attribute_id
           ,effective_start_date
           ,effective_end_date
           ,contract_type
       FROM pqp_assignment_attributes_f
      WHERE assignment_id = p_assignment_id
        AND g_effective_date BETWEEN effective_start_date
                                 AND effective_end_date;

     l_proc_name VARCHAR2(80) := g_proc_name || 'get_hrs_data';
     l_proc_step PLS_INTEGER;
     l_ft_hours  NUMBER;
     l_pt_hours  NUMBER;
     l_rec_aat_dtls csr_get_aat_details%ROWTYPE;
     l_period_divisor NUMBER;
     l_return    NUMBER;
     l_error_msg  VARCHAR2(2000);
     l_value     NUMBER;
     l_hours_type pay_user_column_instances_f.value%TYPE;

   --
   BEGIN
     --
     IF g_debug
     THEN
       l_proc_step := 10;
       debug_enter(l_proc_name);
       debug('p_assignment_id: '||p_assignment_id);
       debug('p_fte: '|| p_fte);
     END IF;

     -- Get the normal hours and frequency
     -- for this assignment
     l_pt_hours := 0;

     IF g_debug THEN
       debug('l_pt_hours: '||l_pt_hours);
       debug('g_assignment_dtl.frequency: '||g_assignment_dtl.frequency);
     END IF;

     -- Get the contract type on assignment attributes
     OPEN csr_get_aat_details;
     FETCH csr_get_aat_details INTO l_rec_aat_dtls;

     IF csr_get_aat_details%NOTFOUND THEN
       -- Raise an error
       IF g_debug THEN
          --
          l_proc_step := 20;
          debug(l_proc_name, l_proc_step);
          debug('Raise aat not found error');
       END IF;
       -- Raise data error
       l_value    :=
          pqp_gb_psi_functions.raise_extract_error(
             p_error_number      => 94479
            ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
            ,p_token1            => 'Assignment Attribute'
          );
     ELSIF l_rec_aat_dtls.contract_type IS NULL THEN
       -- Raise an error
       IF g_debug THEN
          --
          l_proc_step := 30;
          debug(l_proc_name, l_proc_step);
          debug('Raise contract type is null error');
       END IF;
       -- Raise data error
       l_value    :=
          pqp_gb_psi_functions.raise_extract_error(
             p_error_number      => 94479
            ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
            ,p_token1            => 'Contract Type'
          );
     ELSE -- contract type exists
       IF g_debug
       THEN
         l_proc_step := 40;
         debug(l_proc_name, l_proc_step);
         debug('l_rec_aat_dtls.contract_type: '||l_rec_aat_dtls.contract_type);
         debug('l_rec_aat_dtls.assignment_attribute_id: '||l_rec_aat_dtls.assignment_attribute_id);
         debug('l_rec_aat_dtls.effective_start_date: '||TO_CHAR(l_rec_aat_dtls.effective_start_date, 'DD/MON/YYYY'));
         debug('l_rec_aat_dtls.effective_end_date: '||TO_CHAR(l_rec_aat_dtls.effective_end_date, 'DD/MON/YYYY'));
       END IF;

       -- Get hours type
       l_return := pqp_utilities.pqp_gb_get_table_value
                     (p_business_group_id => g_business_group_id
                     ,p_effective_date => g_effective_date
                     ,p_table_name => 'PQP_CONTRACT_TYPES'
                     ,p_column_name => 'Penserver P/T Hours Type'
                     ,p_row_name => l_rec_aat_dtls.contract_type
                     ,p_value => l_hours_type
                     ,p_error_msg => l_error_msg
                     );
       IF g_debug
       THEN
          debug('l_return: '||l_return);
          debug('l_hours_type: '||l_hours_type);
       END IF;

       IF l_return = -1 THEN
         -- Raise error
         l_value :=
           pqp_gb_psi_functions.raise_extract_error(
	     p_error_number      => 94479
	    ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
	    ,p_token1            => 'Penserver P/T Hours Type'
            );
       ELSE
         IF UPPER(l_hours_type) = 'G' OR
            UPPER(l_hours_type) = 'GROSS'
         THEN
           l_hours_type := 'G';
         ELSIF UPPER(l_hours_type) = 'N' OR
               UPPER(l_hours_type) = 'NET'
         THEN
           l_hours_type := 'N';
         ELSIF l_hours_type IS NULL
         THEN
         -- Raise error
         l_value :=
           pqp_gb_psi_functions.raise_extract_error(
	     p_error_number      => 94479
	    ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
	    ,p_token1            => 'Penserver P/T Hours Type'
            );
         ELSE
           l_value :=
             pqp_gb_psi_functions.raise_extract_error(
    	       p_error_number      => 94636
	      ,p_error_text        => 'BEN_94636_EXT_PSI_INV_HRS_TYPE'
	      ,p_token1            => l_hours_type
	      ,p_token2            => l_rec_aat_dtls.contract_type
              );
         END IF;
       END IF; -- End if of l_return = -1 for P/T Hours Type check ...
       -- Check whether frequency is not weekly
       IF g_assignment_dtl.frequency <> 'W' THEN
          IF g_debug
          THEN
            l_proc_step := 50;
            debug('g_assignment_dtl.frequency: '|| g_assignment_dtl.frequency);
          END IF;
          -- Get period divisor value

          l_return := pqp_utilities.pqp_gb_get_table_value
                        (p_business_group_id => g_business_group_id
                        ,p_effective_date => g_effective_date
                        ,p_table_name => 'PQP_CONTRACT_TYPES'
                        ,p_column_name => 'Period Divisor'
                        ,p_row_name => l_rec_aat_dtls.contract_type
                        ,p_value => l_period_divisor
                        ,p_error_msg => l_error_msg
                        );
          IF g_debug
          THEN
            debug('l_return: '||l_return);
            debug('l_period_divisor: '||l_period_divisor);
          END IF;
          IF l_return = -1 THEN
            -- Raise error
            l_value :=
             pqp_gb_psi_functions.raise_extract_error(
                p_error_number      => 94479
               ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
               ,p_token1            => 'Period Divisor'
             );
          ELSE
            l_pt_hours := g_assignment_dtl.normal_hours;
            l_pt_hours := ROUND((l_pt_hours * l_period_divisor)/52, 2);
          END IF; -- End if of l_return = -1 check ...
       ELSE -- frequency is weekly

         l_pt_hours := g_assignment_dtl.normal_hours;

       END IF; -- End if of frequency <> W check ...
     END IF; -- End if of aat details not found check ...
     IF g_debug
     THEN
       l_proc_step := 60;
       debug(l_proc_name, l_proc_step);
       debug('l_pt_hours: '||l_pt_hours);
     END IF;

     l_ft_hours := ROUND((l_pt_hours/p_fte), 2);

     p_ft_hours   := l_ft_hours;
     p_pt_hours   := l_pt_hours;
     p_hours_type := l_hours_type;


     IF g_debug
     THEN
       l_proc_step := 70;
       debug('l_ft_hours: '||l_ft_hours);
       debug('l_hours_type: '||l_hours_type);
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
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_hrs_data;


-- This function is used to get part time hours history data
-- for an assignment as of a cutover date
-- ----------------------------------------------------------------------------
-- |---------------------< get_asg_hrs_cutover_data >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_asg_hrs_cutover_data(p_assignment_id IN NUMBER)
     RETURN VARCHAR2
   IS
   --
      l_proc_name                 VARCHAR2(80)
                                  := g_proc_name || 'get_asg_hrs_cutover_data';
      l_proc_step                 PLS_INTEGER;
      l_include_flag              VARCHAR2(10);
      l_rec_abv_dtls              csr_abv_dtls%ROWTYPE;
      l_ft_hours                  NUMBER;
      l_pt_hours                  NUMBER;
      l_hours_type                pay_user_column_instances_f.value%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         --
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_include_flag := 'N';

      -- Get the FTE value as at the cutover date whether this person
      -- will have to be reported
      get_abv_details
        (p_assignment_id => p_assignment_id
        ,p_effective_date => g_effective_date
        ,p_rec_abv_dtls => l_rec_abv_dtls
        );


      IF l_rec_abv_dtls.value < 1 AND l_rec_abv_dtls.value > 0 AND
         l_rec_abv_dtls.value IS NOT NULL
      THEN
        -- This is a part time employee
        -- report this person
        IF g_debug
        THEN
          --
          l_proc_step := 20;
          debug(l_proc_name, l_proc_step);
        END IF;

        l_include_flag := 'Y';
        g_start_date := l_rec_abv_dtls.effective_start_date;

        IF l_rec_abv_dtls.effective_end_date <> hr_api.g_eot AND
           l_rec_abv_dtls.effective_end_date <= ben_ext_person.g_effective_date
        THEN
          g_end_date := l_rec_abv_dtls.effective_end_date;
        END IF; -- end date not eot check ...

        get_hrs_data (p_assignment_id => p_assignment_id
                     ,p_fte        => l_rec_abv_dtls.value
                     ,p_ft_hours   => l_ft_hours
                     ,p_pt_hours   => l_pt_hours
                     ,p_hours_type => l_hours_type
                     );
        g_ft_hours   := l_ft_hours;
        g_pt_hours   := l_pt_hours;
        g_hours_type := l_hours_type;
      END IF; -- End if of fte value < 1 check ...

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG('l_include_flag: '||l_include_flag);
         DEBUG('g_ft_hours: ' || g_ft_hours);
         DEBUG('g_pt_hours: ' || g_pt_hours);
         DEBUG('g_hours_type: ' || g_hours_type);
         DEBUG('g_start_date: '
            || TO_CHAR(g_start_date, 'DD/MON/YYYY'));
         DEBUG('g_end_date: '
            || TO_CHAR(g_end_date, 'DD/MON/YYYY'));
         debug_exit(l_proc_name);
      END IF;
      RETURN l_include_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_asg_hrs_cutover_data;

-- This function is used to evaluate fte event
-- for an assignment for periodic changes
-- ----------------------------------------------------------------------------
-- |---------------------< eval_fte_event >-----------------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION eval_fte_event(p_assignment_id IN NUMBER
                          ,p_table_name    IN VARCHAR2
                          ,p_surrogate_key IN NUMBER
                          )
     RETURN VARCHAR2
   IS
   --
     l_proc_name VARCHAR2(80) := g_proc_name || 'eval_fte_event';
     l_proc_step PLS_INTEGER;
     l_rec_abv_dtls csr_abv_dtls%ROWTYPE;
     l_ft_hours  NUMBER;
     l_pt_hours  NUMBER;
     l_include_flag VARCHAR2(10);
     l_hours_type   pay_user_column_instances_f.value%TYPE;
   --
   BEGIN
     --
     IF g_debug
     THEN
       l_proc_step := 10;
       debug_enter(l_proc_name);
       DEBUG('p_assignment_id: '||p_assignment_id);
       DEBUG('p_table_name: '||p_table_name);
       DEBUG('p_surrogate_key: '||p_surrogate_key);
     END IF;

     l_include_flag := 'N';

     IF p_table_name = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
     THEN
       IF g_debug
       THEN
         l_proc_step := 20;
         DEBUG(l_proc_name, l_proc_step);
       END IF;
       get_abv_details
         (p_abv_id => p_surrogate_key
         ,p_effective_date => g_effective_date
         ,p_rec_abv_dtls => l_rec_abv_dtls
         );
       IF l_rec_abv_dtls.unit = 'FTE'
       THEN
         IF l_rec_abv_dtls.value < 1 AND l_rec_abv_dtls.value > 0 AND
            l_rec_abv_dtls.value IS NOT NULL
         THEN
           -- This is a part time employee
           -- report this person
           IF g_debug
           THEN
             --
             l_proc_step := 30;
             debug(l_proc_name, l_proc_step);
           END IF;

           l_include_flag := 'Y';
           g_start_date := l_rec_abv_dtls.effective_start_date;

           IF l_rec_abv_dtls.effective_end_date <> hr_api.g_eot AND
              l_rec_abv_dtls.effective_end_date <= ben_ext_person.g_effective_date
           THEN
             g_end_date := l_rec_abv_dtls.effective_end_date;
           END IF; -- end date not eot check ...

           get_hrs_data (p_assignment_id => p_assignment_id
                        ,p_fte      => l_rec_abv_dtls.value
                        ,p_ft_hours => l_ft_hours
                        ,p_pt_hours => l_pt_hours
                        ,p_hours_type => l_hours_type
                        );
           g_ft_hours   := l_ft_hours;
           g_pt_hours   := l_pt_hours;
           g_hours_type := l_hours_type;
         END IF; -- End if of fte value < 1 check ...
       END IF; -- End if of unit is fte check ...
     ELSIF p_table_name = 'PER_ALL_ASSIGNMENTS_F'
     THEN
       IF g_debug
       THEN
         l_proc_step := 40;
         DEBUG(l_proc_name, l_proc_step);
       END IF;
       l_include_flag := get_asg_hrs_cutover_data
                           (p_assignment_id => p_assignment_id);
     END IF; -- End if of table name = assignment budget values check ...

     IF g_debug
     THEN
         l_proc_step    := 50;
         DEBUG('l_include_flag: '||l_include_flag);
         DEBUG('g_ft_hours: ' || g_ft_hours);
         DEBUG('g_pt_hours: ' || g_pt_hours);
         DEBUG('g_hours_type: ' || g_hours_type);
         DEBUG('g_start_date: '
            || TO_CHAR(g_start_date, 'DD/MON/YYYY'));
         DEBUG('g_end_date: '
            || TO_CHAR(g_end_date, 'DD/MON/YYYY'));
         debug_exit(l_proc_name);
     END IF;
     RETURN l_include_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END eval_fte_event;

-- This function is used to get part time hours history data
-- for an assignment for periodic changes
-- ----------------------------------------------------------------------------
-- |---------------------< get_asg_hrs_periodic_data >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_asg_hrs_periodic_data(p_assignment_id IN NUMBER)
     RETURN VARCHAR2
   IS
   --
      l_proc_name                 VARCHAR2(80)
                                  := g_proc_name || 'get_asg_hrs_periodic_data';
      l_proc_step                 PLS_INTEGER;
      l_include_flag              VARCHAR2(10);
      l_rec_abv_dtls              csr_abv_dtls%ROWTYPE;
      l_ft_hours                  NUMBER;
      l_pt_hours                  NUMBER;
      l_tab_pay_proc_evnts        ben_ext_person.t_detailed_output_table;
      l_event_group_id            NUMBER;
      l_event_group_name          pay_event_groups.event_group_name%TYPE;
      l_dated_table_id            NUMBER;
      l_table_name                pay_dated_tables.table_name%TYPE;
      l_curr_status_type_id       NUMBER;
      l_prev_status_type_id       NUMBER;
      l_return                    VARCHAR2(10);
      l_leaver_date               DATE;
      l_surrogate_key             NUMBER;
      l_process_flag              VARCHAR2(10);
      l_assignment_id             NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         --
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_include_flag := 'N';

      l_tab_pay_proc_evnts    := ben_ext_person.g_pay_proc_evt_tab;

      IF l_tab_pay_proc_evnts.COUNT > 0
      THEN
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 30;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('g_event_counter :' || g_event_counter);
            DEBUG(
                  'dated_table_id    :'
               || l_tab_pay_proc_evnts(g_event_counter).dated_table_id
            );
            DEBUG(
                  'datetracked_event :'
               || l_tab_pay_proc_evnts(g_event_counter).datetracked_event
            );
            DEBUG(
                  'update type: '
               || l_tab_pay_proc_evnts(g_event_counter).update_type
            );
            DEBUG(
                  'surrogate_key     :'
               || l_tab_pay_proc_evnts(g_event_counter).surrogate_key
            );
            DEBUG(
                  'column_name       :'
               || l_tab_pay_proc_evnts(g_event_counter).column_name
            );
            DEBUG(
                  'effective_date    :'
               || TO_CHAR(
                     l_tab_pay_proc_evnts(g_event_counter).effective_date
                    ,'DD/MON/YYYY'
                  )
            );
            DEBUG(
                  'old_value         :'
               || l_tab_pay_proc_evnts(g_event_counter).old_value
            );
            DEBUG(
                  'new_value         :'
               || l_tab_pay_proc_evnts(g_event_counter).new_value
            );
            DEBUG(
                  'change_values     :'
               || l_tab_pay_proc_evnts(g_event_counter).change_values
            );
            DEBUG(
                  'proration_type    :'
               || l_tab_pay_proc_evnts(g_event_counter).proration_type
            );
            DEBUG(
                  'change_mode       :'
               || l_tab_pay_proc_evnts(g_event_counter).change_mode
            );
            DEBUG(
                  'event_group_id    :'
               || l_tab_pay_proc_evnts(g_event_counter).event_group_id
            );
            DEBUG(
                  'next_evt_start_date: '
               || TO_CHAR(
                     l_tab_pay_proc_evnts(g_event_counter).next_evt_start_date
                    ,'DD/MON/YYYY'
                  )
            );
            DEBUG(
                  'actual_date: '
               || TO_CHAR(
                     l_tab_pay_proc_evnts(g_event_counter).actual_date
                    ,'DD/MON/YYYY'
                  )
            );
            DEBUG('g_prev_pay_proc_evnts.dated_table_id: '
               || g_prev_pay_proc_evnts.dated_table_id
            );
         END IF;

         IF g_prev_pay_proc_evnts.dated_table_id IS NOT NULL THEN

           --
           IF l_tab_pay_proc_evnts(g_event_counter).dated_table_id <>
              g_prev_pay_proc_evnts.dated_table_id  OR
              l_tab_pay_proc_evnts(g_event_counter).datetracked_event <>
              g_prev_pay_proc_evnts.datetracked_event OR
              l_tab_pay_proc_evnts(g_event_counter).update_type <>
              g_prev_pay_proc_evnts.update_type OR
              l_tab_pay_proc_evnts(g_event_counter).surrogate_key <>
              g_prev_pay_proc_evnts.surrogate_key OR
              l_tab_pay_proc_evnts(g_event_counter).column_name <>
              g_prev_pay_proc_evnts.column_name OR
              l_tab_pay_proc_evnts(g_event_counter).effective_date <>
              g_prev_pay_proc_evnts.effective_date OR
              l_tab_pay_proc_evnts(g_event_counter).old_value <>
              g_prev_pay_proc_evnts.old_value OR
              l_tab_pay_proc_evnts(g_event_counter).new_value <>
              g_prev_pay_proc_evnts.new_value OR
              l_tab_pay_proc_evnts(g_event_counter).change_values <>
              g_prev_pay_proc_evnts.change_values OR
              l_tab_pay_proc_evnts(g_event_counter).proration_type <>
              g_prev_pay_proc_evnts.proration_type OR
              l_tab_pay_proc_evnts(g_event_counter).event_group_id <>
              g_prev_pay_proc_evnts.event_group_id OR
              l_tab_pay_proc_evnts(g_event_counter).actual_date <>
              g_prev_pay_proc_evnts.actual_date
            THEN

              l_process_flag := 'Y';
            ELSE
              l_process_flag := 'N';
            END IF;
         ELSE
           l_process_flag := 'Y';
         END IF; -- End if of dated table id not null check ...

         IF g_debug THEN
           DEBUG('l_process_flag: ' || l_process_flag);
         END IF;

         g_prev_pay_proc_evnts := l_tab_pay_proc_evnts(g_event_counter);


         g_tab_pay_proc_evnts    := l_tab_pay_proc_evnts;
         -- Check whether we are interested in this event
         l_event_group_id        :=
                            l_tab_pay_proc_evnts(g_event_counter).event_group_id;

         IF g_tab_event_group.EXISTS(l_event_group_id) AND l_process_flag = 'Y'
         THEN
            IF g_debug
            THEN
               l_proc_step    := 40;
               DEBUG(l_proc_name, l_proc_step);
            END IF;

            l_return    :=
               pqp_gb_psi_functions.include_event(
                  p_actual_date         => l_tab_pay_proc_evnts(g_event_counter).actual_date
                 ,p_effective_date      => l_tab_pay_proc_evnts(g_event_counter).effective_date
               );

            IF g_debug
            THEN
               l_proc_step    := 50;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_return: ' || l_return);
            END IF;

            IF l_return = 'Y'
            THEN
               -- We are interested in this event
               l_dated_table_id      :=
                           l_tab_pay_proc_evnts(g_event_counter).dated_table_id;
               l_table_name          :=
                                 g_tab_dated_table(l_dated_table_id).table_name;
               l_event_group_name    :=
                           g_tab_event_group(l_event_group_id).event_group_name;

               IF g_debug
               THEN
                  l_proc_step    := 60;
                  DEBUG(l_proc_name, l_proc_step);
                  DEBUG('l_event_group_name: ' || l_event_group_name);
                  DEBUG('l_dated_table_id: ' || l_dated_table_id);
                  DEBUG('l_table_name: ' || l_table_name);
               END IF;

--     PQP_GB_PSI_FTE_VALUE
--     PQP_GB_PSI_ASSIGNMENT_STATUS
--     PQP_GB_PSI_NI_NUMBER
--     PQP_GB_PSI_ASSIGNMENT_NUMBER
--     PQP_GB_PSI_EMP_TERMINATIONS
--     PQP_GB_PSI_SAL_CONTRACT

               -- Check whether event group relates to assignment number
               -- or NI Number change in which case get the part time hour
               -- information as of the event date
--                IF l_event_group_name = 'PQP_GB_PSI_NI_NUMBER' OR
--                   l_event_group_name = 'PQP_GB_PSI_ASSIGNMENT_NUMBER'
--                THEN
--                  IF g_debug
--                  THEN
--                    l_proc_step := 70;
--                    DEBUG(l_proc_name, l_proc_step);
--                  END IF;
--                  l_include_flag := get_asg_hrs_cutover_data
--                                      (p_assignment_id => p_assignment_id);
--                ELSIF l_event_group_name = 'PQP_GB_PSI_NEW_HIRE'
--                THEN
--                   -- This is a new hire event (includes rehires)
--                   -- Evaluate new joiners
--                   -- We are only interested in primary assignments
--                   l_assignment_id    :=
--                      fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).surrogate_key);
--
--                   IF g_debug
--                   THEN
--                      l_proc_step    := 80;
--                      DEBUG(l_proc_name, l_proc_step);
--                      DEBUG('l_assignment_id: ' || l_assignment_id);
--                   END IF;
--
--                   IF l_assignment_id = p_assignment_id
--                   THEN
--                      l_include_flag := get_asg_hrs_cutover_data
--                                          (p_assignment_id => p_assignment_id);
--                   END IF; -- End if of l_assignment_id = p_assignment_id check ...

               IF l_event_group_name = 'PQP_GB_PSI_ASSIGNMENT_STATUS'
               THEN -- Assignment status event group
                  IF g_debug
                  THEN
                     l_proc_step    := 90;
                     DEBUG(l_proc_name, l_proc_step);
                  END IF;

                  l_curr_status_type_id    :=
                     fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).new_value);
                  l_prev_status_type_id    :=
                     fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).old_value);
                  IF l_curr_status_type_id = g_terminate_asg_sts_id
                  THEN
                    IF g_debug
                    THEN
                      l_proc_step := 100;
                      DEBUG(l_proc_name, l_proc_step);
                      DEBUG('l_curr_status_type_id: '||l_curr_status_type_id);
                      DEBUG('l_prev_status_type_id: '||l_prev_status_type_id);
                    END IF;
                    l_include_flag := get_asg_hrs_cutover_data
                                        (p_assignment_id => p_assignment_id);
                  END IF;
               ELSIF l_event_group_name = 'PQP_GB_PSI_EMP_TERMINATIONS'
               THEN -- Terminations
                  IF g_debug
                  THEN
                     l_proc_step    := 110;
                     DEBUG(l_proc_name, l_proc_step);
                  END IF;

                  IF pqp_gb_psi_functions.chk_is_employee_a_leaver(
                        p_assignment_id       => p_assignment_id
                       ,p_effective_date      => g_effective_date
                       ,p_leaver_date         => l_leaver_date
                     ) = 'Y'
                  THEN
                    IF g_debug
                    THEN
                      l_proc_step := 120;
                      DEBUG(l_proc_name, l_proc_step);
                    END IF;
                    l_include_flag := get_asg_hrs_cutover_data
                                        (p_assignment_id => p_assignment_id);
                  END IF; -- End if of chk is employee a leaver check ...
               ELSIF l_event_group_name = 'PQP_GB_PSI_FTE_VALUE'
               THEN
                 IF g_debug
                 THEN
                   l_proc_step := 130;
                   DEBUG(l_proc_name, l_proc_step);
                 END IF;
                 l_surrogate_key    :=
                     fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).surrogate_key);

                 l_include_flag := eval_fte_event
                                     (p_assignment_id => p_assignment_id
                                     ,p_table_name    => l_table_name
                                     ,p_surrogate_key => l_surrogate_key
                                     );
               ELSIF l_event_group_name = 'PQP_GB_PSI_SAL_CONTRACT'
               THEN
                 IF g_debug
                 THEN
                   l_proc_step := 140;
                   DEBUG(l_proc_Name, l_proc_step);
                 END IF;
                 l_include_flag := get_asg_hrs_cutover_data
                                     (p_assignment_id => p_assignment_id);
               END IF; -- Event group name check ...
            END IF; -- End if of l_return = 'Y' check ...
         END IF; -- event group exists check ...
      END IF; -- Event collection count > 0 check ...
      IF g_debug
      THEN
         l_proc_step    := 150;
         DEBUG('l_include_flag: '||l_include_flag);
         DEBUG('g_ft_hours: ' || g_ft_hours);
         DEBUG('g_pt_hours: ' || g_pt_hours);
         DEBUG('g_hours_type: ' || g_hours_type);
         DEBUG('g_start_date: '
            || TO_CHAR(g_start_date, 'DD/MON/YYYY'));
         DEBUG('g_end_date: '
            || TO_CHAR(g_end_date, 'DD/MON/YYYY'));
         debug_exit(l_proc_name);
      END IF;

      RETURN l_include_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_asg_hrs_periodic_data;

-- This function is used to evaluate assignments that
-- qualify for penserver part time hours history cutover interface
-- ----------------------------------------------------------------------------
-- |---------------------< chk_hrs_cutover_criteria  -----------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_hrs_cutover_criteria(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name      VARCHAR2(80)
                               := g_proc_name || 'chk_hrs_cutover_criteria';
      l_proc_step      PLS_INTEGER;
      l_include_flag   VARCHAR2(10);
      l_debug          VARCHAR2(10);
      i                NUMBER;
--
   BEGIN
      --
      IF g_business_group_id IS NULL
      THEN
         -- Always clear cache before proceeding to set globals
         clear_cache;
         g_debug    := pqp_gb_psi_functions.check_debug(p_business_group_id);
      END IF; -- End if of g_business_group_id is Null check ...

      IF g_debug
      THEN
        l_proc_step := 10;
        debug_enter(l_proc_name);
        debug('p_business_group_id: '|| p_business_group_id);
        debug('p_effective_date: '||TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
        debug('p_assignment_id: '||p_assignment_id);
      END IF;

      l_include_flag       := 'N';

      IF g_business_group_id IS NULL
      THEN

         IF g_debug
         THEN
            DEBUG('g_business_group_id: ' || g_business_group_id);
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- set shared globals
         pqp_gb_psi_functions.set_shared_globals(
            p_business_group_id      => p_business_group_id
           ,p_paypoint               => g_paypoint
           ,p_cutover_date           => g_cutover_date
           ,p_ext_dfn_id             => g_ext_dfn_id
         );

         g_extract_type := 'CUTOVER';

         IF g_debug
         THEN
            l_proc_step    := 30;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('g_paypoint: ' || g_paypoint);
            DEBUG('g_cutover_date: '
               || TO_CHAR(g_cutover_date, 'DD/MON/YYYY'));
            DEBUG('g_ext_dfn_id: ' || g_ext_dfn_id);
         END IF;

         -- set extract global variables
         set_hrs_history_globals(
            p_business_group_id      => p_business_group_id
           ,p_effective_date         => p_effective_date
         );

         IF g_debug
         THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- Raise Extract Exceptions
         pqp_gb_psi_functions.raise_extract_exceptions('S');
      END IF; -- End if of business group id is null check ...

      g_start_date := NULL;
      g_end_date   := NULL;
      g_pt_hours   := NULL;
      g_ft_hours   := NULL;
      g_hours_type := NULL;

      -- Check penserver basic criteria
      IF g_debug
      THEN
         l_proc_step    := 50;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      l_include_flag       :=
         pqp_gb_psi_functions.chk_penserver_basic_criteria(
            p_business_group_id      => g_business_group_id
           ,p_effective_date         => g_effective_date
           ,p_assignment_id          => p_assignment_id
           ,p_person_dtl             => g_person_dtl
           ,p_assignment_dtl         => g_assignment_dtl
         );

      IF g_debug
      THEN
         l_proc_step    := 60;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_include_flag: ' || l_include_flag);
         DEBUG('g_extract_type: ' || g_extract_type);
      END IF;

      IF l_include_flag = 'Y'
      THEN
        IF g_debug
        THEN
          l_proc_step    := 70;
          DEBUG(l_proc_name, l_proc_step);
        END IF;

        l_include_flag := get_asg_hrs_cutover_data(p_assignment_id => p_assignment_id);
      END IF; -- End if of l_include_flag = 'Y' check ...

      IF g_debug
      THEN
         l_proc_step    := 80;
         DEBUG('l_include_flag: ' || l_include_flag);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_include_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END chk_hrs_cutover_criteria;

-- This function is used to evaluate assignments that
-- qualify for penserver part time hours history periodic interface
-- ----------------------------------------------------------------------------
-- |---------------------< chk_hrs_periodic_criteria  -----------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_hrs_periodic_criteria(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name      VARCHAR2(80)
                               := g_proc_name || 'chk_hrs_periodic_criteria';
      l_proc_step      PLS_INTEGER;
      l_include_flag   VARCHAR2(10);
      l_debug          VARCHAR2(10);
      i                NUMBER;
--
   BEGIN
      --
      --
      IF g_business_group_id IS NULL
      THEN
         -- Always clear cache before proceeding to set globals
         clear_cache;
         g_debug    := pqp_gb_psi_functions.check_debug(p_business_group_id);
      END IF; -- End if of g_business_group_id is Null check ...

      IF g_debug
      THEN
        l_proc_step := 10;
        debug_enter(l_proc_name);
        debug('p_business_group_id: '|| p_business_group_id);
        debug('p_effective_date: '||TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
        debug('p_assignment_id: '||p_assignment_id);
      END IF;

      l_include_flag       := 'N';

      IF g_business_group_id IS NULL
      THEN

         IF g_debug
         THEN
            DEBUG('g_business_group_id: ' || g_business_group_id);
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- set shared globals
         pqp_gb_psi_functions.set_shared_globals(
            p_business_group_id      => p_business_group_id
           ,p_paypoint               => g_paypoint
           ,p_cutover_date           => g_cutover_date
           ,p_ext_dfn_id             => g_ext_dfn_id
         );

         g_extract_type := 'PERIODIC';

         IF g_debug
         THEN
            l_proc_step    := 30;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('g_paypoint: ' || g_paypoint);
            DEBUG('g_cutover_date: '
               || TO_CHAR(g_cutover_date, 'DD/MON/YYYY'));
            DEBUG('g_ext_dfn_id: ' || g_ext_dfn_id);
         END IF;

         -- set extract global variables
         set_hrs_history_globals(
            p_business_group_id      => p_business_group_id
           ,p_effective_date         => p_effective_date
         );

         IF g_debug
         THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- Raise Extract Exceptions
         pqp_gb_psi_functions.raise_extract_exceptions('S');
      END IF; -- End if of business group id is null check ...

      g_start_date := NULL;
      g_end_date   := NULL;
      g_pt_hours   := NULL;
      g_ft_hours   := NULL;
      g_hours_type := NULL;
      g_effective_date := p_effective_date;
      g_event_counter := ben_ext_person.g_chg_pay_evt_index;


      -- Check penserver basic criteria
      IF g_debug
      THEN
         l_proc_step    := 50;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      l_include_flag       :=
         pqp_gb_psi_functions.chk_penserver_basic_criteria(
            p_business_group_id      => g_business_group_id
           ,p_effective_date         => g_effective_date
           ,p_assignment_id          => p_assignment_id
           ,p_person_dtl             => g_person_dtl
           ,p_assignment_dtl         => g_assignment_dtl
         );

      IF g_debug
      THEN
         l_proc_step    := 60;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_include_flag: ' || l_include_flag);
         DEBUG('g_extract_type: ' || g_extract_type);
         DEBUG('g_effective_date: '||TO_CHAR(g_effective_date, 'DD/MON/YYYY'));
         DEBUG('g_event_counter: '||g_event_counter);
      END IF;

      IF l_include_flag = 'Y'
      THEN
        IF g_debug
        THEN
          l_proc_step    := 70;
          DEBUG(l_proc_name, l_proc_step);
        END IF;

        l_include_flag := get_asg_hrs_periodic_data(p_assignment_id => p_assignment_id);

        IF l_include_flag = 'Y' THEN
          IF g_debug
          THEN
            l_proc_step := 80;
            DEBUG(l_proc_name, l_proc_step);
          END IF;
          pqp_gb_psi_functions.process_retro_event;
        END IF;
      END IF; -- End if of l_include_flag = 'Y' check ...

      IF g_debug
      THEN
         l_proc_step    := 100;
         DEBUG('l_include_flag: ' || l_include_flag);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_include_flag;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END chk_hrs_periodic_criteria;

-- This function is used to get part time hours history data
-- for an assignment
-- ----------------------------------------------------------------------------
-- |---------------------< get_hrs_history_data >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_hrs_history_data(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
     ,p_rule_parameter      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name      VARCHAR2(80)
                                   := g_proc_name || 'get_hrs_history_data';
      l_proc_step      PLS_INTEGER;
      l_return_value   VARCHAR2(150);
      l_value          NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_business_group_id: ' || p_business_group_id);
         DEBUG('p_effective_date: ' || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_rule_parameter: ' || p_rule_parameter);
      END IF;

      IF p_rule_parameter = 'StartDate' THEN
        l_return_value := fnd_date.date_to_canonical(g_start_date);
        IF g_start_date IS NULL THEN
            IF g_debug
            THEN
               DEBUG('Raise Data Error: Start Date Missing');
            END IF;

            -- Raise data error
            l_value    :=
               pqp_gb_psi_functions.raise_extract_error(
                  p_error_number      => 94479
                 ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                 ,p_token1            => 'Start Date'
               );
         END IF;
      ELSIF p_rule_parameter = 'EndDate' THEN
        l_return_value := fnd_date.date_to_canonical(g_end_date);
      ELSIF p_rule_parameter = 'PartTimeHours' THEN
        IF g_pt_hours < 0 THEN
          l_return_value := TRIM(TO_CHAR(g_pt_hours,'S09D99'));
        ELSE
          l_return_value := TRIM(TO_CHAR(g_pt_hours,'099D99'));
        END IF;
         IF g_pt_hours IS NULL
         THEN
            IF g_debug
            THEN
               DEBUG('Raise Data Error: Part Time Hours is Missing');
            END IF;

            -- Raise data error
            l_value    :=
               pqp_gb_psi_functions.raise_extract_error(
                  p_error_number      => 94479
                 ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                 ,p_token1            => 'Part Time Hours'
               );
         END IF;
      ELSIF p_rule_parameter = 'FullTimeHours' THEN
        IF g_ft_hours < 0 THEN
          l_return_value := TRIM(TO_CHAR(g_ft_hours,'S09D99'));
        ELSE
          l_return_value := TRIM(TO_CHAR(g_ft_hours,'099D99'));
        END IF;
         IF g_ft_hours IS NULL
         THEN
            IF g_debug
            THEN
               DEBUG('Raise Data Error: Full Time Hours is missing');
            END IF;

            -- Raise data error
            l_value    :=
               pqp_gb_psi_functions.raise_extract_error(
                  p_error_number      => 94479
                 ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                 ,p_token1            => 'Full Time Hours'
               );
         END IF;
      ELSIF p_rule_parameter = 'HoursType' THEN
        l_return_value := TRIM(RPAD(g_hours_type,1,' '));
      END IF; -- End if of rule parameter check ...

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG('l_return_value: ' || l_return_value);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_hrs_history_data;

-- This function is used for post processing in part time hours history interface
-- ----------------------------------------------------------------------------
-- |---------------------< hrs_history_post_process >---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION hrs_history_post_process(p_ext_rslt_id IN NUMBER)
      RETURN VARCHAR2
   IS
      --
      l_proc_name      VARCHAR2(80)
                               := g_proc_name || 'hrs_history_post_process';
      l_proc_step      PLS_INTEGER;
      l_return_value   VARCHAR2(100);
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      -- pqp_gb_psi_functions.raise_extract_exceptions('DE');
      pqp_gb_psi_functions.common_post_process(
        p_business_group_id => g_business_group_id
        );

      IF g_debug
      THEN
         l_proc_step    := 20;
         debug_exit(l_proc_name);
      END IF;

      RETURN l_return_value;
   EXCEPTION
      WHEN OTHERS
      THEN
         clear_cache;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others(l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG('Leaving: ' || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END hrs_history_post_process;
END pqp_gb_psi_hrs_history;

/
