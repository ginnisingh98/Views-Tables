--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_SERVICE_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_SERVICE_HISTORY" 
--  /* $Header: pqpgbpsiser.pkb 120.17.12010000.18 2010/01/07 13:40:39 namgoyal ship $ */
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

--       g_nested_level := g_nested_level + 1;
--       debug('Entering: ' || NVL(p_proc_name, g_proc_name)
--            ,g_nested_level * 100);

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
--       DEBUG (
--             'Leaving: '
--          || NVL (p_proc_name, g_proc_name),
--          -g_nested_level * 100
--       );
--       g_nested_level :=   g_nested_level
--                         - 1;
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
      g_start_reason            := NULL;
      g_scheme_category         := NULL;
      g_scheme_status           := NULL;
      g_opt_in                  := NULL;
      g_opt_out                 := NULL;
      g_active_asg_sts_id       := NULL;
      g_terminate_asg_sts_id    := NULL;
      g_prev_pay_proc_evnts     := NULL;
      -- Clear all global collections
      g_tab_event_map_cv.DELETE;
      g_tab_abs_types.DELETE;
      g_tab_asg_status.DELETE;
      g_tab_pen_sch_map_cv.DELETE;
      g_tab_pen_ele_ids.DELETE;
      g_tab_prs_dfn_cv.DELETE;
      g_tab_dated_table.DELETE;
      g_tab_lvrsn_map_cv.DELETE;

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

-- This procedure is used to clear all cached assignment variables
--
-- ----------------------------------------------------------------------------
-- |----------------------------< clear_per_cache >---------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE clear_per_cache
   IS
      --
      l_proc_name   VARCHAR2(80) := g_proc_name || 'clear_per_cache';
      l_proc_step   PLS_INTEGER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      g_event_counter          := ben_ext_person.g_pay_proc_evt_tab.FIRST;
      g_min_effective_date     := NULL;
      g_min_eff_date_exists    := 'N';

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
   END clear_per_cache;

-- This function returns input value id for a given element type id
-- and input value name


-- This procedure is used to fetch event map configuration values for
-- this business group setup
-- ----------------------------------------------------------------------------
-- |----------------------------< get_input_value_id >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_input_value_id(
      p_element_type_id    IN   NUMBER
     ,p_effective_date     IN   DATE
     ,p_input_value_name   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      -- Cursor to get input value id
      CURSOR csr_get_iv_id
      IS
         SELECT input_value_id
           FROM pay_input_values_f
          WHERE element_type_id = p_element_type_id
            AND NAME = p_input_value_name
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

      l_proc_name        VARCHAR2(80) := g_proc_name || 'get_input_value_id';
      l_proc_step        PLS_INTEGER;
      l_input_value_id   NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_element_type_id: ' || p_element_type_id);
         DEBUG('p_effective_date: '
            || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
         DEBUG('p_input_value_name: ' || p_input_value_name);
      END IF;

      OPEN csr_get_iv_id;
      FETCH csr_get_iv_id INTO l_input_value_id;
      CLOSE csr_get_iv_id;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_input_value_id: ' || l_input_value_id);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_input_value_id;
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
   END get_input_value_id;

-- This function returns screen entry value for a given element entry id
-- ----------------------------------------------------------------------------
-- |----------------------------< get_screen_entry_value >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_screen_entry_value(
      p_element_entry_id       IN   NUMBER
     ,p_effective_start_date   IN   DATE
     ,p_effective_end_date     IN   DATE
     ,p_input_value_id         IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      --
      -- Cursor to fetch screen entry value
      CURSOR csr_get_screen_ent_val
      IS
         SELECT screen_entry_value
           FROM pay_element_entry_values_f
          WHERE element_entry_id = p_element_entry_id
            AND effective_start_date = p_effective_start_date
            AND effective_end_date = p_effective_end_date
            AND input_value_id = p_input_value_id;

      l_proc_name          VARCHAR2(80)
                                    := g_proc_name || 'get_screen_entry_value';
      l_proc_step          PLS_INTEGER;
      l_screen_ent_value   pay_element_entry_values_f.screen_entry_value%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_element_entry_id: ' || p_element_entry_id);
         DEBUG(
               'p_effective_start_date: '
            || TO_CHAR(p_effective_start_date, 'DD/MON/YYYY')
         );
         DEBUG(
               'p_effective_end_date: '
            || TO_CHAR(p_effective_end_date, 'DD/MON/YYYY')
         );
         DEBUG('p_input_value_id: ' || p_input_value_id);
      END IF;

      OPEN csr_get_screen_ent_val;
      FETCH csr_get_screen_ent_val INTO l_screen_ent_value;
      CLOSE csr_get_screen_ent_val;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_screen_ent_value: ' || l_screen_ent_value);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_screen_ent_value;
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
   END get_screen_entry_value;

-- This function returns the configuration type description for a given
-- configuration type
-- ----------------------------------------------------------------------------
-- |----------------------------< get_config_type_desc >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_config_type_desc(p_config_type IN VARCHAR2)
      RETURN VARCHAR2
   IS
      --
      -- Cursor to fetch config desc
      CURSOR csr_get_config_desc
      IS
         SELECT dfc.descriptive_flex_context_name
           FROM pqp_configuration_types pct, fnd_descr_flex_contexts_vl dfc
          WHERE pct.configuration_type = p_config_type
            AND dfc.descriptive_flex_context_code = pct.configuration_type
            AND dfc.application_id = 8303
            AND dfc.descriptive_flexfield_name =
                                                'Configuration Value Info DDF'
            AND dfc.enabled_flag = 'Y';

      l_proc_name     VARCHAR2(80)    := g_proc_name || 'get_config_type_desc';
      l_proc_step     PLS_INTEGER;
      l_config_desc   fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_config_type: ' || p_config_type);
      END IF;

      OPEN csr_get_config_desc;
      FETCH csr_get_config_desc INTO l_config_desc;
      CLOSE csr_get_config_desc;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_config_desc: ' || l_config_desc);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_config_desc;
   --
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
   END get_config_type_desc;

-- Ths function returns a yes or no flag to identify whether a value
-- is in the collection or not
-- ----------------------------------------------------------------------------
-- |---------------------< chk_value_in_collection >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_value_in_collection(
      p_collection_name   IN              t_number
     ,p_value             IN              NUMBER
     ,p_index             OUT NOCOPY      NUMBER
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name   VARCHAR2(80) := g_proc_name || 'chk_value_in_collection';
      l_proc_step   PLS_INTEGER;
      i             NUMBER;
      l_return      VARCHAR2(10);
      l_index       NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_value: ' || p_value);
      END IF;

      i           := p_collection_name.FIRST;
      l_return    := 'N';
      l_index     := NULL;

      WHILE i IS NOT NULL
      LOOP
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('i: ' || i);
            DEBUG('p_collection_name(i): ' || p_collection_name(i));
         END IF;

         IF p_collection_name(i) = p_value
         THEN
            l_return    := 'Y';
            l_index     := i;
            EXIT;
         END IF;

         i    := p_collection_name.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG('l_return: ' || l_return);
         debug_exit(l_proc_name);
      END IF;

      p_index     := l_index;
      RETURN l_return;
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
   END chk_value_in_collection;

-- Ths function returns a yes or no flag to identify whether a code
-- is in the collection or not
-- ----------------------------------------------------------------------------
-- |---------------------< chk_event_in_collection >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_event_in_collection(
      p_event_code   IN   pqp_configuration_values.pcv_information1%TYPE
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name   VARCHAR2(80) := g_proc_name || 'chk_event_in_collection';
      l_proc_step   PLS_INTEGER;
      i             NUMBER;
      l_return      VARCHAR2(10);
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_event_code: ' || p_event_code);
      END IF;

      i           := g_tab_event_desc_lov.FIRST;
      l_return    := 'Y';

      WHILE i IS NOT NULL
      LOOP
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('i: ' || i);
            DEBUG(
                  'g_tab_event_desc_lov(i).lookup_code: '
               || g_tab_event_desc_lov(i).lookup_code
            );
         END IF;

         IF g_tab_event_desc_lov(i).lookup_code = p_event_code
         THEN
            l_return    := 'N';
            EXIT;
         END IF;

         i    := g_tab_event_desc_lov.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG('l_return: ' || l_return);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_return;
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
   END chk_event_in_collection;

-- Ths function returns a yes or no flag to identify whether a code
-- is in the collection or not
-- ----------------------------------------------------------------------------
-- |---------------------< chk_lvrsn_in_collection >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_lvrsn_in_collection(
      p_leave_reason   IN  pqp_configuration_values.pcv_information1%TYPE
     ,p_index          OUT NOCOPY      NUMBER
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name   VARCHAR2(80) := g_proc_name || 'chk_lvrsn_in_collection';
      l_proc_step   PLS_INTEGER;
      i             NUMBER;
      l_return      VARCHAR2(10);
      l_value       NUMBER;
      l_configuration_desc   fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE;
      l_meaning     hr_lookups.meaning%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_leave_reason: ' || p_leave_reason);
      END IF;

      i           := g_tab_lvrsn_map_cv.FIRST;
      l_return    := 'N';

      WHILE i IS NOT NULL
      LOOP
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('i: ' || i);
            DEBUG(
                  'g_tab_lvrsn_map_cv(i).pcv_information1: '
               || g_tab_lvrsn_map_cv(i).pcv_information1
            );
         END IF;

         IF g_tab_lvrsn_map_cv(i).pcv_information1 = p_leave_reason
         THEN
            l_return    := 'Y';
            p_index     := i;
            EXIT;
         END IF;

         i    := g_tab_lvrsn_map_cv.NEXT(i);
      END LOOP;

      IF l_return = 'N' THEN

         IF g_debug
         THEN
           DEBUG('Raise data error..Leave reason map is missing');
         END IF;

         l_meaning    :=
              hr_general.decode_lookup(
                 p_lookup_type      => 'LEAV_REAS'
                ,p_lookup_code      => p_leave_reason
              );

         l_configuration_desc    :=
                   get_config_type_desc(p_config_type => 'PQP_GB_PENSERVER_SER_LVRSN_MAP');

         -- Raise data error
         l_value    :=
            pqp_gb_psi_functions.raise_extract_error(
               p_error_number      => 94635
              ,p_error_text        => 'BEN_94635_EXT_PSI_MISS_LVRSN'
              ,p_token1            => l_meaning
              ,p_token2            => l_configuration_desc
            );
      END IF; -- End if of l_return = N check ...

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG('l_return: ' || l_return);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_return;
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
   END chk_lvrsn_in_collection;

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

      l_proc_name          VARCHAR2(80)
                                      := g_proc_name || 'get_asg_status_type';
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

      l_proc_name     VARCHAR2(80)    := g_proc_name || 'get_asg_status_type';
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

-- This function returns the absence type name
-- for a given absence type id
-- ----------------------------------------------------------------------------
-- |----------------------< get_abs_type_name >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_abs_type_name(p_absence_type_id IN NUMBER)
      RETURN per_absence_attendance_types.NAME%TYPE
   IS
      --
      CURSOR csr_get_abs_type_name
      IS
         SELECT NAME
           FROM per_absence_attendance_types
          WHERE absence_attendance_type_id = p_absence_type_id;

      l_proc_name       VARCHAR2(80)    := g_proc_name || 'get_abs_type_name';
      l_proc_step       PLS_INTEGER;
      l_abs_type_name   per_absence_attendance_types.NAME%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_absence_type_id: ' || p_absence_type_id);
      END IF;

      OPEN csr_get_abs_type_name;
      FETCH csr_get_abs_type_name INTO l_abs_type_name;
      CLOSE csr_get_abs_type_name;

      IF g_debug
      THEN
         DEBUG('l_abs_type_name: ' || l_abs_type_name);
         l_proc_step    := 20;
         debug_exit(l_proc_name);
      END IF;

      RETURN l_abs_type_name;
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
   END get_abs_type_name;

-- This procedures fetches the process definition configuration
-- for penserver
-- ----------------------------------------------------------------------------
-- |----------------------------< fetch_process_defn_cv >---------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE fetch_process_defn_cv(p_business_group_id IN NUMBER)
   IS
      --
      l_proc_name            VARCHAR2(80)
                                    := g_proc_name || 'fetch_process_defn_cv';
      l_proc_step            PLS_INTEGER;
      l_configuration_type   pqp_configuration_types.configuration_type%TYPE;
      l_tab_config_values    pqp_utilities.t_config_values;
      i                      NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      -- Call configuration value function to retrieve all data
      -- for a configuration type
      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('p_business_group_id: ' || p_business_group_id);
      END IF;

      l_configuration_type    := 'PQP_GB_PENSERVER_DEFINITION';
      pqp_utilities.get_config_type_values(
         p_configuration_type      => l_configuration_type
        ,p_business_group_id       => p_business_group_id
        ,p_legislation_code        => g_legislation_code
        ,p_tab_config_values       => l_tab_config_values
      );

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_configuration_type: ' || l_configuration_type);
         DEBUG('l_tab_config_values.count: ' || l_tab_config_values.COUNT);
      END IF;

      -- Store the config values in the global collection
      -- for event map
      g_tab_prs_dfn_cv        := l_tab_config_values;

      -- Debug    PCV_INFORMATION1
      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      i                       := g_tab_prs_dfn_cv.FIRST;

      WHILE i IS NOT NULL
      LOOP
         IF g_debug
         THEN
            DEBUG('Debug: ' || l_tab_config_values(i).pcv_information1);
         END IF;

         i    := g_tab_prs_dfn_cv.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 50;
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
   END fetch_process_defn_cv;

-- This procedure fetches event mapping configuration value
-- for service history
-- ----------------------------------------------------------------------------
-- |----------------------------< fetch_event_map_cv >------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE fetch_event_map_cv
   IS
      --
      -- Cursor to fetch values from event desc lookup
      CURSOR csr_get_event_desc
      IS
         SELECT   lookup_code, meaning
             FROM hr_lookups
            WHERE lookup_type = 'PQP_PENSERVER_EVENT_DESC'
              AND enabled_flag = 'Y'
              AND g_effective_date BETWEEN NVL(
                                             start_date_active
                                            ,g_effective_date
                                          )
                                       AND NVL(end_date_active
                                            ,g_effective_date)
         ORDER BY lookup_code;

      l_proc_name            VARCHAR2(80)
                                        := g_proc_name || 'fetch_event_map_cv';
      l_proc_step            PLS_INTEGER;
      l_configuration_type   pqp_configuration_types.configuration_type%TYPE;
      l_tab_config_values    pqp_utilities.t_config_values;
      i                      NUMBER;
      j                      NUMBER;
      l_event_code           hr_lookups.lookup_code%TYPE;
      l_event_desc           hr_lookups.meaning%TYPE;
      l_token1               VARCHAR2(2000);
      l_token2               VARCHAR2(2000);
      l_new_joiner           VARCHAR2(10);
      l_ret_break            VARCHAR2(10);
      l_meaning              hr_lookups.meaning%TYPE;
      l_configuration_desc   fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE;
      l_abs_type_name        per_absence_attendance_types.NAME%TYPE;
      l_asg_status           per_assignment_status_types.user_status%TYPE;
      l_miss_events          VARCHAR2(32000);
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      -- Call configuration value function to retrieve all data
      -- for a configuration type

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_business_group_id: ' || g_business_group_id);
      END IF;

      l_configuration_type    := 'PQP_GB_PENSERVER_SEREVENT_INFO';
      l_configuration_desc    :=
                   get_config_type_desc(p_config_type => l_configuration_type);
      pqp_utilities.get_config_type_values(
         p_configuration_type      => l_configuration_type
        ,p_business_group_id       => g_business_group_id
        ,p_legislation_code        => g_legislation_code
        ,p_tab_config_values       => l_tab_config_values
      );

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_configuration_type: ' || l_configuration_type);
         DEBUG('l_tab_config_values.count: ' || l_tab_config_values.COUNT);
      END IF;

      -- Store the config values in the global collection
      -- for event map
      g_tab_event_map_cv      := l_tab_config_values;

      -- For bug 7145485

      hr_api.set_legislation_context('GB');

      -- End Bug 7145485
     -- Event Description  PCV_INFORMATION1
     -- Event Source         PCV_INFORMATION4
--    Absence Type           PCV_INFORMATION7
--    Assignment Status PCV_INFORMATION8
--    Employment Type           PCV_INFORMATION9
--    Pension Scheme         PCV_INFORMATION10
--    Start Reason           PCV_INFORMATION11
--    Scheme Category           PCV_INFORMATION2
--    Scheme Status          PCV_INFORMATION3

      -- Loop through the event description lookup
      -- and store it in the collection
      -- we will use this information to check atleast
      -- one value exist in the event map collection
      -- for this event description
      i                       := 1;
      OPEN csr_get_event_desc;

      LOOP
         FETCH csr_get_event_desc INTO l_event_code, l_event_desc;
         EXIT WHEN csr_get_event_desc%NOTFOUND;
         g_tab_event_desc_lov(i).lookup_code    := l_event_code;
         g_tab_event_desc_lov(i).meaning        := l_event_desc;

         IF g_debug
         THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_event_code: ' || l_event_code);
            DEBUG('l_event_desc: ' || l_event_desc);
         END IF;

         i                                      := i + 1;
      END LOOP;

      CLOSE csr_get_event_desc;

      IF g_debug
      THEN
         l_proc_step    := 50;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      i                       := g_tab_event_map_cv.FIRST;

      WHILE i IS NOT NULL
      LOOP
         IF g_debug
         THEN
            DEBUG('Configuration Value ID: ' || i);
            DEBUG('Event Description:'
               || g_tab_event_map_cv(i).pcv_information1);
            DEBUG('Event Source: ' || g_tab_event_map_cv(i).pcv_information4);
            DEBUG('Absence Type: ' || g_tab_event_map_cv(i).pcv_information7);
            DEBUG(
               'Assignment Status: ' || g_tab_event_map_cv(i).pcv_information8
            );
            DEBUG('Employment Type: '
               || g_tab_event_map_cv(i).pcv_information9);
            DEBUG('Pension Scheme: '
               || g_tab_event_map_cv(i).pcv_information10);
            DEBUG('Start Reason: ' || g_tab_event_map_cv(i).pcv_information11);
            DEBUG('Scheme Category: '
               || g_tab_event_map_cv(i).pcv_information2);
            DEBUG('Scheme Status: ' || g_tab_event_map_cv(i).pcv_information3);
         END IF;

         -- Populate assignment status and absence type global collection
         -- based of event source
         IF g_tab_event_map_cv(i).pcv_information4 = 'ABS'
         THEN
            -- Event is absence type
            -- populate absence type collection
            IF g_tab_event_map_cv(i).pcv_information7 IS NOT NULL
            THEN
               g_tab_abs_types(i)    :=
                  fnd_number.canonical_to_number(g_tab_event_map_cv(i).pcv_information7);
            ELSE
               l_meaning    :=
                  hr_general.decode_lookup(
                     p_lookup_type      => 'PQP_PENSERVER_EVENT_DESC'
                    ,p_lookup_code      => g_tab_event_map_cv(i).pcv_information1
                  );

               IF g_debug
               THEN
                  DEBUG('l_meaning: ' || l_meaning);
               END IF;

               -- Raise setup error
               pqp_gb_psi_functions.store_extract_exceptions(
                  p_extract_type            => 'SERVICE_HISTORY'
                 ,p_error_number            => 93774
                 ,p_error_text              => 'BEN_93774_EXT_PSI_NO_ABS_TYPE'
                 ,p_token1                  => l_configuration_desc
                 ,p_token2                  => l_meaning
                 ,p_error_warning_flag      => 'E'
               );
            END IF; -- End if of abs not null check ...
         ELSIF g_tab_event_map_cv(i).pcv_information4 = 'ASG'
         THEN
            -- Event is assignment status
            -- populate assignment status collection
            IF g_tab_event_map_cv(i).pcv_information8 IS NOT NULL
            THEN
               g_tab_asg_status(i)    :=
                  fnd_number.canonical_to_number(g_tab_event_map_cv(i).pcv_information8);
            ELSE
               l_meaning    :=
                  hr_general.decode_lookup(
                     p_lookup_type      => 'PQP_PENSERVER_EVENT_DESC'
                    ,p_lookup_code      => g_tab_event_map_cv(i).pcv_information1
                  );

               IF g_debug
               THEN
                  DEBUG('l_meaning: ' || l_meaning);
               END IF;

               -- Raise setup error
               pqp_gb_psi_functions.store_extract_exceptions(
                  p_extract_type            => 'SERVICE_HISTORY'
                 ,p_error_number            => 93776
                 ,p_error_text              => 'BEN_93776_EXT_PSI_NO_ASG_STS'
                 ,p_token1                  => l_configuration_desc
                 ,p_token2                  => l_meaning
                 ,p_error_warning_flag      => 'E'
               );
            END IF; -- End if of asg status not null check ...
         END IF; -- End if of event source value check ...

                 -- Delete lookup collection if an event is found

         j    := g_tab_event_desc_lov.FIRST;

         WHILE j IS NOT NULL
         LOOP
            IF g_tab_event_desc_lov(j).lookup_code =
                                       g_tab_event_map_cv(i).pcv_information1
            THEN
               IF g_debug
               THEN
                  l_proc_step    := 60;
                  DEBUG(l_proc_name, l_proc_step);
                  DEBUG(
                        'g_tab_event_desc_lov(j): '
                     || g_tab_event_desc_lov(j).lookup_code
                  );
               END IF;

               g_tab_event_desc_lov.DELETE(j);
               EXIT; -- Exit the collection
            END IF;

            j    := g_tab_event_desc_lov.NEXT(j);
         END LOOP;

         i    := g_tab_event_map_cv.NEXT(i);
      END LOOP;

      IF g_tab_event_desc_lov.COUNT <> 0
      THEN
         IF g_debug
         THEN
            l_proc_step    := 70;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- There are some events for which event mapping
         -- do not exist
         -- Check for new joiner events and return from
         -- break events not set up
         l_new_joiner    := chk_event_in_collection(p_event_code => 'N');
         l_ret_break     := chk_event_in_collection(p_event_code => 'RB');

         IF l_new_joiner = 'N'
         THEN
            l_token1    := 'New Joiner';
         END IF;

         IF l_ret_break = 'N'
         THEN
            l_token2    := 'Return from Break';
         END IF;

         IF l_new_joiner = 'N' OR l_ret_break = 'N'
         THEN
            -- Raise a setup error
            pqp_gb_psi_functions.store_extract_exceptions(
               p_extract_type            => 'SERVICE_HISTORY'
              ,p_error_number            => 93777
              ,p_error_text              => 'BEN_93777_EXT_PSI_SER_EVNT_MAP'
              ,p_token1                  => l_configuration_desc
              ,p_token2                  => l_token1
              ,p_token3                  => l_token2
              ,p_error_warning_flag      => 'E'
            );
         END IF;

         -- Enhancement 5040543
         -- Get a list of events that are not mapped
         i             := g_tab_event_desc_lov.FIRST;
         l_miss_events := NULL;
         WHILE i IS NOT NULL
         LOOP

           IF l_miss_events IS NULL
           THEN
             l_miss_events := g_tab_event_desc_lov(i).meaning;
           ELSE
             l_miss_events := l_miss_events || ', ' || g_tab_event_desc_lov(i).meaning;
           END IF;

           IF g_debug
           THEN
             debug('Event Code: '|| g_tab_event_desc_lov(i).lookup_code);
             debug('Event Name: '|| g_tab_event_desc_lov(i).meaning);
           END IF;

           i := g_tab_event_desc_lov.NEXT(i);
         END LOOP;

         IF g_debug
         THEN
           debug('Missing Events: '|| l_miss_events);
         END IF;

         -- Raise a setup warning
         pqp_gb_psi_functions.store_extract_exceptions(
            p_extract_type            => 'SERVICE_HISTORY'
           ,p_error_number            => 94363
           ,p_error_text              => 'BEN_94363_EXT_PSI_EVNT_MAP_WRN'
           ,p_token1                  => l_configuration_desc
           ,p_token2                  => l_miss_events
           ,p_error_warning_flag      => 'W'
         );

         -- commente for bug 8470684
         --g_opt_in        := chk_event_in_collection(p_event_code => 'OI');
         --g_opt_out       := chk_event_in_collection(p_event_code => 'OO');

         -- Loop through the absence type collection
         -- to ensure that there are no two events used
         -- for same absence type
         IF g_debug
         THEN
            l_proc_step    := 80;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         i               := g_tab_abs_types.FIRST;

         WHILE i IS NOT NULL
         LOOP
            IF g_debug
            THEN
               l_proc_step    := 90;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('Absence Type ID: ' || g_tab_abs_types(i));
            END IF;

            j    := g_tab_abs_types.NEXT(i);

            WHILE j IS NOT NULL
            LOOP
               IF g_debug
               THEN
                  l_proc_step    := 100;
                  DEBUG(l_proc_name, l_proc_step);
                  DEBUG('Absence Type ID: ' || g_tab_abs_types(j));
               END IF;

               IF g_tab_abs_types(i) = g_tab_abs_types(j)
               THEN
                  IF g_debug
                  THEN
                     l_proc_step    := 110;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG(
                           'first code: '
                        || g_tab_event_map_cv(i).pcv_information1
                     );
                     DEBUG(
                           'seconde code: '
                        || g_tab_event_map_cv(j).pcv_information1
                     );
                  END IF;

                  -- check whether the codes are same
                  IF     g_tab_event_map_cv(i).pcv_information1 <>
                                        g_tab_event_map_cv(j).pcv_information1
                     AND (
                             SUBSTR(g_tab_event_map_cv(i).pcv_information1, 1
                               ,1) NOT IN('S', 'M')
                          OR (
                                  SUBSTR(
                                     g_tab_event_map_cv(i).pcv_information1
                                    ,1
                                    ,1
                                  ) IN('S', 'M')
                              AND SUBSTR(
                                     g_tab_event_map_cv(i).pcv_information1
                                    ,1
                                    ,1
                                  ) <>
                                     SUBSTR(
                                        g_tab_event_map_cv(j).pcv_information1
                                       ,1
                                       ,1
                                     )
                             )
                         )
                  THEN
                     -- Get the absence type name
                     l_abs_type_name    :=
                        get_abs_type_name(p_absence_type_id => g_tab_abs_types(i));
                     l_meaning          :=
                        hr_general.decode_lookup(
                           p_lookup_type      => 'PQP_PENSERVER_EVENT_DESC'
                          ,p_lookup_code      => g_tab_event_map_cv(i).pcv_information1
                        );

                     IF g_debug
                     THEN
                        DEBUG('l_meaning: ' || l_meaning);
                     END IF;

                     l_meaning          :=
                            l_meaning
                         || ', '
                         || hr_general.decode_lookup(
                               p_lookup_type      => 'PQP_PENSERVER_EVENT_DESC'
                              ,p_lookup_code      => g_tab_event_map_cv(j).pcv_information1
                            );

                     IF g_debug
                     THEN
                        DEBUG('l_meaning: ' || l_meaning);
                     END IF;

                     pqp_gb_psi_functions.store_extract_exceptions(
                        p_extract_type            => 'SERVICE_HISTORY'
                       ,p_error_number            => 94364
                       ,p_error_text              => 'BEN_94364_EXT_PSI_DUP_EVNT_MAP'
                       ,p_token1                  => 'Absence Type'
                       ,p_token2                  => l_abs_type_name
                       ,p_token3                  => l_meaning
                       ,p_token4                  => l_configuration_desc
                       ,p_error_warning_flag      => 'E'
                     );
                     -- Raise error
                     EXIT;
                  END IF; -- End if of event codes not same check ...
               END IF; -- Same absence type ids ...

               j    := g_tab_abs_types.NEXT(j);
            END LOOP; -- j loop

            i    := g_tab_abs_types.NEXT(i);
         END LOOP; -- i loop

                   -- Loop through the assignment status collection
                   -- to ensure that there are no two events used
                   -- for same assignment status

         IF g_debug
         THEN
            l_proc_step    := 120;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         i               := g_tab_asg_status.FIRST;

         WHILE i IS NOT NULL
         LOOP
            IF g_debug
            THEN
               l_proc_step    := 130;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('Assignment Status ID: ' || g_tab_asg_status(i));
            END IF;

            j    := g_tab_asg_status.NEXT(i);

            WHILE j IS NOT NULL
            LOOP
               IF g_debug
               THEN
                  l_proc_step    := 140;
                  DEBUG(l_proc_name, l_proc_step);
                  DEBUG('Assignment Status ID: ' || g_tab_asg_status(j));
               END IF;

               IF     g_tab_asg_status(i) = g_tab_asg_status(j)
                  AND g_tab_asg_status(i) <> g_active_asg_sts_id
               THEN
                  IF g_debug
                  THEN
                     l_proc_step    := 150;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG(
                           'first code: '
                        || g_tab_event_map_cv(i).pcv_information1
                     );
                     DEBUG(
                           'seconde code: '
                        || g_tab_event_map_cv(j).pcv_information1
                     );
                  END IF;

                  -- check whether the codes are same
                  IF g_tab_event_map_cv(i).pcv_information1 <>
                                        g_tab_event_map_cv(j).pcv_information1
                  THEN
                     l_asg_status    :=
                        get_asg_status_type(p_asg_sts_type_id => g_tab_asg_status(i));
                     l_meaning       :=
                        hr_general.decode_lookup(
                           p_lookup_type      => 'PQP_PENSERVER_EVENT_DESC'
                          ,p_lookup_code      => g_tab_event_map_cv(i).pcv_information1
                        );

                     IF g_debug
                     THEN
                        DEBUG('l_meaning: ' || l_meaning);
                     END IF;

                     l_meaning       :=
                            l_meaning
                         || ', '
                         || hr_general.decode_lookup(
                               p_lookup_type      => 'PQP_PENSERVER_EVENT_DESC'
                              ,p_lookup_code      => g_tab_event_map_cv(j).pcv_information1
                            );

                     IF g_debug
                     THEN
                        DEBUG('l_meaning: ' || l_meaning);
                     END IF;

                     pqp_gb_psi_functions.store_extract_exceptions(
                        p_extract_type            => 'SERVICE_HISTORY'
                       ,p_error_number            => 94364
                       ,p_error_text              => 'BEN_94364_EXT_PSI_DUP_EVNT_MAP'
                       ,p_token1                  => 'Assignment Status'
                       ,p_token2                  => l_asg_status
                       ,p_token3                  => l_meaning
                       ,p_token4                  => l_configuration_desc
                       ,p_error_warning_flag      => 'E'
                     );
                     -- Raise error
                     EXIT;
                  END IF; -- End if of event codes not same check ...
               END IF; -- Same assignment status type ids ...

               j    := g_tab_asg_status.NEXT(j);
            END LOOP; -- j loop

            i    := g_tab_asg_status.NEXT(i);
         END LOOP; -- i loop
      END IF; -- End if of even desc lov count <> 0 check ...

      -- For bug 8470684

      IF g_debug
      THEN
         DEBUG('Calling g_opt_in and g_opt_out');
      END IF;

      g_opt_in        := chk_event_in_collection(p_event_code => 'OI');
      g_opt_out       := chk_event_in_collection(p_event_code => 'OO');

      IF g_debug
      THEN
         l_proc_step    := 160;
         DEBUG('g_opt_in: ' || g_opt_in);
         DEBUG('g_opt_out: ' || g_opt_out);
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
   END fetch_event_map_cv;

-- This procedure fetches elements mapped to civil service pension schemes
-- ----------------------------------------------------------------------------
-- |----------------------------< fetch_pension_scheme_map_cv >---------------|
-- ----------------------------------------------------------------------------
   PROCEDURE fetch_pension_scheme_map_cv(
      p_business_group_id    IN              NUMBER
     ,p_tab_pen_sch_map_cv   OUT NOCOPY      pqp_utilities.t_config_values
   )
   IS
      --
      l_proc_name            VARCHAR2(80)
                              := g_proc_name || 'fetch_pension_scheme_map_cv';
      l_proc_step            PLS_INTEGER;
      l_element_type_id      NUMBER;
      l_configuration_type   pqp_configuration_types.configuration_type%TYPE;
      l_tab_config_values    pqp_utilities.t_config_values;
      i                      NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      --
      -- Call configuration value function to retrieve all data
      -- for a configuration type

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('p_business_group_id: ' || p_business_group_id);
      END IF;

      l_configuration_type    := 'PQP_GB_PENSERV_SCHEME_MAP_INFO';

      IF pqp_gb_psi_functions.g_pension_scheme_mapping.COUNT = 0
      THEN
         pqp_utilities.get_config_type_values(
            p_configuration_type      => l_configuration_type
           ,p_business_group_id       => p_business_group_id
           ,p_legislation_code        => g_legislation_code
           ,p_tab_config_values       => l_tab_config_values
         );
      ELSE -- get it from cached collection
         l_tab_config_values    :=
                                pqp_gb_psi_functions.g_pension_scheme_mapping;
      END IF;

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_configuration_type: ' || l_configuration_type);
         DEBUG('l_tab_config_values.count: ' || l_tab_config_values.COUNT);
      END IF;

      -- Return the
      -- collection for pension scheme elements
      p_tab_pen_sch_map_cv    := l_tab_config_values;
      -- Penserver Pension Scheme PCV_INFORMATION2
      -- Template Pension Scheme          PCV_INFORMATION1

      i                       := l_tab_config_values.FIRST;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      WHILE i IS NOT NULL
      LOOP
         IF g_debug
         THEN
            DEBUG(
                  'Penserver Pension Scheme: '
               || l_tab_config_values(i).pcv_information2
            );
            DEBUG(
                  'Template Pension Scheme: '
               || l_tab_config_values(i).pcv_information1
            );
            DEBUG('Partnership Scheme: '||
                  l_tab_config_values(i).pcv_information3);
         END IF;

         i    := l_tab_config_values.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 50;
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
   END fetch_pension_scheme_map_cv;

-- This procedure fetches leaving reason configuration mapping information
-- ----------------------------------------------------------------------------
-- |----------------------------< fetch_leaving_reason_map_cv >---------------|
-- ----------------------------------------------------------------------------
   PROCEDURE fetch_leaving_reason_map_cv(
      p_business_group_id    IN              NUMBER
     ,p_tab_lvrsn_map_cv     OUT NOCOPY      pqp_utilities.t_config_values
   )
   IS
      --
      l_proc_name            VARCHAR2(80)
                              := g_proc_name || 'fetch_leaving_reason_map_cv';
      l_proc_step            PLS_INTEGER;
      l_element_type_id      NUMBER;
      l_configuration_type   pqp_configuration_types.configuration_type%TYPE;
      l_tab_config_values    pqp_utilities.t_config_values;
      i                      NUMBER;
      l_configuration_desc   fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      --
      -- Call configuration value function to retrieve all data
      -- for a configuration type

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('p_business_group_id: ' || p_business_group_id);
      END IF;

      l_configuration_type    := 'PQP_GB_PENSERVER_SER_LVRSN_MAP';
      l_configuration_desc    :=
                   get_config_type_desc(p_config_type => l_configuration_type);

      pqp_utilities.get_config_type_values(
         p_configuration_type      => l_configuration_type
        ,p_business_group_id       => p_business_group_id
        ,p_legislation_code        => g_legislation_code
        ,p_tab_config_values       => l_tab_config_values
      );

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_configuration_type: ' || l_configuration_type);
         DEBUG('l_tab_config_values.count: ' || l_tab_config_values.COUNT);
      END IF;

      -- Return the
      -- collection for leaving reason map
      p_tab_lvrsn_map_cv    := l_tab_config_values;

      IF l_tab_config_values.COUNT = 0 THEN

         -- Raise setup error
         pqp_gb_psi_functions.store_extract_exceptions(
           p_extract_type            => 'SERVICE_HISTORY'
          ,p_error_number            => 92799
          ,p_error_text              => 'BEN_92799_EXT_PSI_NO_CONFIG'
          ,p_token1                  => 'Penserver Interface'
          ,p_token2                  => l_configuration_desc
          ,p_error_warning_flag      => 'E'
          );

      END IF; -- End if of config values count check ...

      -- Leaving Reason                         PCV_INFORMATION1
      -- Penserver Leaving Reason Code          PCV_INFORMATION2

      i                       := l_tab_config_values.FIRST;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      WHILE i IS NOT NULL
      LOOP
         IF g_debug
         THEN
            DEBUG(
                  'Leaving Reason: '
               || l_tab_config_values(i).pcv_information1
            );
            DEBUG(
                  'Penserver Leaving Reason Code: '
               || l_tab_config_values(i).pcv_information2
            );
         END IF;

         i    := l_tab_config_values.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 50;
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
   END fetch_leaving_reason_map_cv;

-- This procedure fetches the employment type configuration values
-- for penserver
-- ----------------------------------------------------------------------------
-- |----------------------------< fetch_empl_type_map_cv >--------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE fetch_empl_type_map_cv
   IS
      --
      l_proc_name            VARCHAR2(80)
                                   := g_proc_name || 'fetch_empl_type_map_cv';
      l_proc_step            PLS_INTEGER;
      l_configuration_type   pqp_configuration_types.configuration_type%TYPE;
      i                      NUMBER;
      l_tab_config_values    pqp_utilities.t_config_values;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      --
      -- Call configuration value function to retrieve all data
      -- for a configuration type

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_business_group_id: ' || g_business_group_id);
      END IF;

      l_configuration_type    := 'PQP_GB_PENSERVER_EMPLYMT_TYPE';

      IF pqp_gb_psi_functions.g_assign_category_mapping.COUNT > 0
      THEN
         -- available from cache
         l_tab_config_values    :=
                               pqp_gb_psi_functions.g_assign_category_mapping;
      ELSE -- not available so fetch it
         pqp_utilities.get_config_type_values(
            p_configuration_type      => l_configuration_type
           ,p_business_group_id       => g_business_group_id
           ,p_legislation_code        => g_legislation_code
           ,p_tab_config_values       => l_tab_config_values
         );
      END IF; -- Check whether cv available from collection ...

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_configuration_type: ' || l_configuration_type);
         DEBUG('l_tab_config_values.count: ' || l_tab_config_values.COUNT);
      END IF;

      -- Store the collection in the global
      -- collection for pension scheme elements
      g_tab_emp_typ_map_cv    := l_tab_config_values;
      -- Assignment Category       PCV_INFORMATION1
      -- Penserver Employment Type PCV_INFORMATION2

      i                       := l_tab_config_values.FIRST;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG(l_proc_name, l_proc_step);

         WHILE i IS NOT NULL
         LOOP
            DEBUG(
                  'Assignment Category: '
               || l_tab_config_values(i).pcv_information1
            );
            DEBUG(
                  'Penserver Employment Type: '
               || l_tab_config_values(i).pcv_information2
            );
            i    := l_tab_config_values.NEXT(i);
         END LOOP;
      END IF;

      IF g_debug
      THEN
         l_proc_step    := 50;
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
   END fetch_empl_type_map_cv;

-- This function determines whether an extract is a periodic interface or
-- cutover interface based on the data_typ_cd
-- ----------------------------------------------------------------------------
-- |----------------------------< get_extract_type >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_extract_type(p_ext_dfn_id IN NUMBER)
      RETURN VARCHAR2
   IS
      --
      -- F -> Full Profile
      -- C -> Changes Only
      CURSOR csr_get_ext_type
      IS
         SELECT DECODE(data_typ_cd, 'F', 'CUTOVER', 'C', 'PERIODIC')
           FROM ben_ext_dfn
          WHERE ext_dfn_id = p_ext_dfn_id;

      l_proc_name      VARCHAR2(80) := g_proc_name || 'get_extract_type';
      l_proc_step      PLS_INTEGER;
      l_extract_type   VARCHAR2(50);
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_ext_dfn_id: ' || p_ext_dfn_id);
      END IF;

      OPEN csr_get_ext_type;
      FETCH csr_get_ext_type INTO l_extract_type;
      CLOSE csr_get_ext_type;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_extract_type: ' || l_extract_type);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_extract_type;
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
   END get_extract_type;

-- This function returns the pension scheme membership details at a given date
-- ----------------------------------------------------------------------------
-- |----------------------------< get_pen_scheme_memb >-----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_pen_scheme_memb(
      p_assignment_id         IN              NUMBER
     ,p_effective_date        IN              DATE
     ,p_tab_pen_sch_map_cv    IN              pqp_utilities.t_config_values
     ,p_rec_ele_ent_details   OUT NOCOPY      r_ele_ent_details
     ,p_partnership_scheme    OUT NOCOPY      Varchar2
   )
      RETURN VARCHAR2
   IS
      --
      -- Cursor to get pension scheme element details
      -- for this person
      CURSOR csr_get_ele_ent_details(c_element_type_id NUMBER)
      IS
         SELECT   pee.element_entry_id, pee.effective_start_date
                 ,pee.effective_end_date, pel.element_type_id
             FROM pay_element_entries_f pee, pay_element_links_f pel
            WHERE pee.assignment_id = p_assignment_id
              AND pee.entry_type = 'E'
              AND pee.element_link_id = pel.element_link_id
              AND p_effective_date BETWEEN pee.effective_start_date
                                       AND pee.effective_end_date
              AND pel.element_type_id = c_element_type_id
              AND p_effective_date BETWEEN pel.effective_start_date
                                       AND pel.effective_end_date
         ORDER BY pee.effective_start_date DESC;

      l_proc_name             VARCHAR2(80)
                                       := g_proc_name || 'get_pen_scheme_memb';
      l_proc_step             PLS_INTEGER;
      l_pension_category      pqp_configuration_values.pcv_information1%TYPE;
      l_rec_ele_ent_details   r_ele_ent_details;
      l_element_type_id       NUMBER;
      i                       NUMBER;
      l_eff_start_date        DATE      := TO_DATE('01-01-0001', 'DD-MM-YYYY');
      l_partnership_scheme    varchar2(30);
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_effective_date: '
            || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
      END IF;

      i                        := g_tab_pen_sch_map_cv.FIRST;

      WHILE i IS NOT NULL
      LOOP
         l_element_type_id    :=
            fnd_number.canonical_to_number(p_tab_pen_sch_map_cv(i).pcv_information1);

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_element_type_id: ' || l_element_type_id);
         END IF;

         OPEN csr_get_ele_ent_details(l_element_type_id);
         FETCH csr_get_ele_ent_details INTO l_rec_ele_ent_details;

         -- We are only interested in the latest pension scheme
         -- membership details
         IF     csr_get_ele_ent_details%FOUND
            AND l_eff_start_date < l_rec_ele_ent_details.effective_start_date
         THEN
            l_pension_category    := p_tab_pen_sch_map_cv(i).pcv_information2;
            l_eff_start_date      :=
                                   l_rec_ele_ent_details.effective_start_date;
            --valid only if partnerhip scheme is partner
             l_partnership_scheme:=  p_tab_pen_sch_map_cv(i).pcv_information3;

            IF g_debug
            THEN
               l_proc_step    := 30;
               DEBUG('l_pension_category: ' || l_pension_category);
               DEBUG('l_partnership_scheme: '||l_partnership_scheme);
               DEBUG(
                     'l_eff_start_date: '
                  || TO_CHAR(l_eff_start_date, 'DD/MON/YYYY')
               );
               DEBUG(l_proc_name, l_proc_step);
            END IF;
         END IF; -- cursor found check ...

         CLOSE csr_get_ele_ent_details;
         i                    := p_tab_pen_sch_map_cv.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG('l_eff_start_date: '
            || TO_CHAR(l_eff_start_date, 'DD/MON/YYYY'));
         DEBUG('l_pension_category: ' || l_pension_category);
         DEBUG(
               'l_rec_ele_ent_details.element_entry_id: '
            || l_rec_ele_ent_details.element_entry_id
         );
         DEBUG(
               'l_rec_ele_ent_details.effective_start_date: '
            || l_rec_ele_ent_details.effective_start_date
         );
         DEBUG(
               'l_rec_ele_ent_details.effective_end_date: '
            || l_rec_ele_ent_details.effective_end_date
         );
         DEBUG('l_partnership_scheme: '||l_partnership_scheme);
         DEBUG('l_element_type_id: ' || l_element_type_id);
         debug_exit(l_proc_name);
      END IF;

      p_rec_ele_ent_details    := l_rec_ele_ent_details;
      p_partnership_scheme     :=l_partnership_scheme;
      RETURN l_pension_category;
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
   END get_pen_scheme_memb;

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
      l_table_name(i)      := 'PAY_ELEMENT_ENTRY_VALUES_F';
      i                    := i + 1;
      l_table_name(i)      := 'PER_ALL_PEOPLE_F';
      i                    := i + 1;
      l_table_name(i)      := 'PER_ABSENCE_ATTENDANCES';
      i                    := i + 1;
      l_table_name(i)      := 'PER_PERIODS_OF_SERVICE';
      i                    := i + 1;
      l_table_name(i)      := 'PQP_GAP_DURATION_SUMMARY';

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
            DEBUG('Surrogate Key Col: '
               || l_rec_dated_table.surrogate_key_name);
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
      l_event_group(i)     := 'PQP_GB_PSI_SER_ABSENCES';
      i                    := i + 1;

    --For Bug 7034476:Removed event group
     /*
      l_event_group(i)     := 'PQP_GB_PSI_ASSIGNMENT_STATUS';
      i                    := i + 1;
     */

      l_event_group(i)     := 'PQP_GB_PSI_SER_LEAVER';
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_SER_PENSIONS';
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_NEW_HIRE';
--       i                    := i + 1;
--       l_event_group(i)     := 'PQP_GB_PSI_NI_NUMBER';
--       i                    := i + 1;
--       l_event_group(i)     := 'PQP_GB_PSI_ASSIGNMENT_NUMBER';
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_SER_NEW_ABSENCES';

    --For Bug 7034476:Removed event groups
     /*
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_EMP_TERMINATIONS';
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_SER_GAP_TRANSITION';
     */

 --For Bug 5998108:Start
      i                    := i + 1;
      l_event_group(i)     := 'PQP_GB_PSI_ASG_CATEGORY';
 --For Bug 5998108:End

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
               p_extract_type            => 'SERVICE_HISTORY'
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

-- This function returns the last approved run date for
-- periodic changes
-- ----------------------------------------------------------------------------
-- |----------------------------< get_last_run_date >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_last_run_date
      RETURN DATE
   IS
      --
      -- Cursor to fetch the last successful approved run date
      CURSOR csr_get_run_date
      IS
         SELECT MAX(eff_dt)
           FROM ben_ext_rslt
          WHERE ext_dfn_id = g_ext_dfn_id
            AND business_group_id = g_business_group_id
            AND ext_stat_cd = 'A';

      l_proc_name   VARCHAR2(80) := g_proc_name || 'get_last_run_date';
      l_proc_step   PLS_INTEGER;
      l_run_date    DATE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name, l_proc_step);
      END IF;

      -- Get the run date
      OPEN csr_get_run_date;
      FETCH csr_get_run_date INTO l_run_date;
      CLOSE csr_get_run_date;

      IF g_debug
      THEN
         DEBUG('l_run_date: ' || TO_CHAR(l_run_date, 'DD/MON/YYYY'));
      END IF;

      IF l_run_date IS NULL
      THEN
         -- Set the run date to be cutover date
         l_run_date    := g_cutover_date;
      END IF; -- End if of l_run_date is null check ...

      l_run_date    := l_run_date + 1;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_run_date: ' || TO_CHAR(l_run_date, 'DD/MON/YYYY'));
         debug_exit(l_proc_name);
      END IF;

      RETURN l_run_date;
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
   END get_last_run_date;

-- This procedure is used to set any globals needed for this extract
--
-- ----------------------------------------------------------------------------
-- |----------------------------< set_service_history_globals >---------------|
-- ----------------------------------------------------------------------------
   PROCEDURE set_service_history_globals(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
   )
   IS
      --
      l_proc_name           VARCHAR2(80)
                              := g_proc_name || 'set_service_history_globals';
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
      g_extract_type            :=
                                get_extract_type(p_ext_dfn_id => g_ext_dfn_id);
--       IF g_extract_type = 'CUTOVER'
--       THEN
--          g_effective_date    := g_cutover_date;
--       ELSIF g_extract_type = 'PERIODIC'
--       THEN
--          g_effective_date    := p_effective_date;
--       END IF; -- End if of p_extract_type is cutover check ...

      -- Cutover date is passed down from concurrent request

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

      fetch_empl_type_map_cv;

      -- Fetch data from configuration values and store in a
      -- global collection
      -- Fetch event map configuration values

      IF g_debug
      THEN
         l_proc_step    := 50;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      -- Fetch event map configuration values
      fetch_event_map_cv;

      IF g_debug
      THEN
        l_proc_step := 75;
        DEBUG(l_proc_name, l_proc_step);
      END IF;

      -- Fetch leaving reason configuration map
      fetch_leaving_reason_map_cv
        (p_business_group_id => p_business_group_id
        ,p_tab_lvrsn_map_cv  => g_tab_lvrsn_map_cv
        );


      IF g_debug
      THEN
         l_proc_step    := 60;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      -- Fetch pension scheme configuration values
      fetch_pension_scheme_map_cv(
         p_business_group_id       => p_business_group_id
        ,p_tab_pen_sch_map_cv      => g_tab_pen_sch_map_cv
      );
      i                         := g_tab_pen_sch_map_cv.FIRST;
      l_input_value_name        := 'Opt Out Date';

      IF g_debug
      THEN
         l_proc_step    := 70;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      WHILE i IS NOT NULL
      LOOP
         l_element_type_id                                        :=
            fnd_number.canonical_to_number(g_tab_pen_sch_map_cv(i).pcv_information1);
         l_input_value_id                                         :=
            get_input_value_id(
               p_element_type_id       => l_element_type_id
              ,p_effective_date        => g_effective_date
              ,p_input_value_name      => l_input_value_name
            );
         g_tab_pen_ele_ids(l_element_type_id).element_type_id     :=
                                                             l_element_type_id;
         g_tab_pen_ele_ids(l_element_type_id).input_value_name    :=
                                                            l_input_value_name;
         g_tab_pen_ele_ids(l_element_type_id).input_value_id      :=
                                                              l_input_value_id;

         IF g_debug
         THEN
            DEBUG(
                  'Penserver Pension Scheme: '
               || g_tab_pen_sch_map_cv(i).pcv_information2
            );
            DEBUG(
                  'Template Pension Scheme: '
               || g_tab_pen_sch_map_cv(i).pcv_information1
            );
            DEBUG('Element Type ID: ' || l_element_type_id);
            DEBUG('Input Value Name: ' || l_input_value_name);
            DEBUG('Input Value ID: ' || l_input_value_id);
         END IF;

         i                                                        :=
                                                  g_tab_pen_sch_map_cv.NEXT(i);
      END LOOP;

      IF g_extract_type = 'PERIODIC'
      THEN

         IF g_debug
         THEN
            l_proc_step    := 80;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- populated dated table ids
         set_dated_table_collection;

         -- populate event group colleciton
         IF g_debug
         THEN
            l_proc_step    := 90;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         set_event_group_collection;
      END IF; -- End if of extract type = periodic check ...

      IF g_debug
      THEN
         l_proc_step    := 100;
         DEBUG('g_business_group_id: ' || g_business_group_id);
         DEBUG('g_effective_date: '
            || TO_CHAR(g_effective_date, 'DD/MON/YYYY'));
         DEBUG(
               'g_effective_start_date: '
            || TO_CHAR(g_effective_start_date, 'DD/MON/YYYY')
         );
         DEBUG(
               'g_effective_end_date: '
            || TO_CHAR(g_effective_end_date, 'DD/MON/YYYY')
         );
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
   END set_service_history_globals;

-- This function returns the penserv category for
-- a given assignment category
-- ----------------------------------------------------------------------------
-- |---------------------< get_psi_emp_type >---------------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_psi_emp_type(p_employment_category IN VARCHAR2)
      RETURN VARCHAR2
   IS
      --
      l_proc_name      VARCHAR2(80)      := g_proc_name || 'get_psi_emp_type';
      l_proc_step      PLS_INTEGER;
      i                NUMBER;
      l_psi_emp_type   pqp_configuration_values.pcv_information1%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_employment_category: ' || p_employment_category);
      END IF;

      i    := g_tab_emp_typ_map_cv.FIRST;

      WHILE i IS NOT NULL
      LOOP
         IF g_tab_emp_typ_map_cv(i).pcv_information1 = p_employment_category
         THEN
            l_psi_emp_type    := g_tab_emp_typ_map_cv(i).pcv_information2;
            EXIT;
         END IF; -- assignment category in collection check ...

         i    := g_tab_emp_typ_map_cv.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_psi_emp_type: ' || l_psi_emp_type);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_psi_emp_type;
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
   END get_psi_emp_type;

-- This function returns the latest start date for a person
-- ----------------------------------------------------------------------------
-- |---------------------< get_per_latest_start_date >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_per_latest_start_date(
      p_person_id        IN   NUMBER
     ,p_effective_date   IN   DATE
   )
      RETURN DATE
   IS
      --
      -- Cursor to get latest start date
      CURSOR csr_get_latest_date
      IS
         SELECT DECODE(per.current_employee_flag, 'Y', pps.date_start, NULL)
           FROM per_all_people_f per, per_periods_of_service pps
          WHERE per.person_id = p_person_id
            AND pps.person_id = p_person_id
            AND p_effective_date BETWEEN per.effective_start_date
                                     AND NVL(
                                           per.effective_end_date
                                          ,TO_DATE('31/12/4712', 'DD/MM/YYYY')
                                        )
            AND p_effective_date BETWEEN pps.date_start
                                     AND NVL(
                                           pps.actual_termination_date
                                          ,TO_DATE('31/12/4712', 'DD/MM/YYYY')
                                        );

      l_proc_name           VARCHAR2(80)
                                 := g_proc_name || 'get_per_latest_start_date';
      l_proc_step           PLS_INTEGER;
      l_latest_start_date   DATE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_person_id: ' || p_person_id);
         DEBUG('p_effective_date: '
            || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
      END IF;

      OPEN csr_get_latest_date;
      FETCH csr_get_latest_date INTO l_latest_start_date;
      CLOSE csr_get_latest_date;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(
               'l_latest_start_date: '
            || TO_CHAR(l_latest_start_date, 'DD/MON/YYYY')
         );
         debug_exit(l_proc_name);
      END IF;

      RETURN l_latest_start_date;
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
   END get_per_latest_start_date;

-- This procedure gets assignment details for a given assignment id
-- ----------------------------------------------------------------------------
-- |---------------------< get_asg_details >----------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_asg_details(
      p_assignment_id     IN              NUMBER
     ,p_effective_date    IN              DATE
     ,p_rec_asg_details   OUT NOCOPY      r_asg_details
   )
   IS
      --
      -- cursor to fetch assignment details for a given assignment
      CURSOR csr_get_asg_details
      IS
         SELECT   person_id, effective_start_date, effective_end_date
                 ,assignment_number, primary_flag, normal_hours
                 ,assignment_status_type_id, employment_category
             FROM per_all_assignments_f
            WHERE assignment_id = p_assignment_id
              AND p_effective_date BETWEEN effective_start_date
                                       AND effective_end_date
         ORDER BY effective_start_date DESC;

      l_proc_name         VARCHAR2(80)  := g_proc_name || 'get_asg_details';
      l_proc_step         PLS_INTEGER;
      l_rec_asg_details   r_asg_details;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_effective_date: '
            || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
      END IF;

      OPEN csr_get_asg_details;
      FETCH csr_get_asg_details INTO l_rec_asg_details;
      CLOSE csr_get_asg_details;
      p_rec_asg_details    := l_rec_asg_details;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('Person ID: ' || l_rec_asg_details.person_id);
         DEBUG(
               'Effective Start Date: '
            || TO_CHAR(l_rec_asg_details.effective_start_date, 'DD/MON/YYYY')
         );
         DEBUG(
               'Effective End Date: '
            || TO_CHAR(l_rec_asg_details.effective_end_date, 'DD/MON/YYYY')
         );
         DEBUG('Assignment Number: ' || l_rec_asg_details.assignment_number);
         DEBUG('Primary Flag: ' || l_rec_asg_details.primary_flag);
         DEBUG('Normal Hours: ' || l_rec_asg_details.normal_hours);
         DEBUG(
               'Assignment Status Type ID: '
            || l_rec_asg_details.assignment_status_type_id
         );
         DEBUG('Assignment Category: '
            || l_rec_asg_details.employment_category);
      END IF;

      IF g_debug
      THEN
         l_proc_step    := 30;
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
   END get_asg_details;

-- This procedure returns the codes for a particular event from
-- configuration event mappings value
-- ----------------------------------------------------------------------------
-- |---------------------< get_service_history_code >-------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_service_history_code(
      p_event_desc         IN              VARCHAR2
     ,p_pension_scheme     IN              VARCHAR2
     ,p_employment_type    IN              VARCHAR2
     ,p_event_source       IN              VARCHAR2
     ,p_absence_type       IN              NUMBER
     ,p_asg_status         IN              NUMBER
     ,p_partnership_scheme IN              VARCHAR2 --115.14
     ,p_start_reason       OUT NOCOPY      VARCHAR2
     ,p_scheme_category    OUT NOCOPY      VARCHAR2
     ,p_scheme_status      OUT NOCOPY      VARCHAR2
   )
   IS
      --
      l_proc_name               VARCHAR2(80)
                                 := g_proc_name || 'get_service_history_code';
      l_proc_step               PLS_INTEGER;
      l_start_reason            pqp_configuration_values.pcv_information1%TYPE;
      l_scheme_category         pqp_configuration_values.pcv_information1%TYPE;
      l_scheme_status           pqp_configuration_values.pcv_information1%TYPE;
      l_match                   VARCHAR2(10);
      i                         NUMBER;
      l_source_pension_scheme   pqp_configuration_values.pcv_information1%TYPE;
      l_event_description       pqp_configuration_values.pcv_information1%TYPE;
      l_pension_scheme          pqp_configuration_values.pcv_information1%TYPE;
      l_employment_type         pqp_configuration_values.pcv_information1%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_event_desc: ' || p_event_desc);
         DEBUG('p_pension_scheme: ' || p_pension_scheme);
         DEBUG('p_partnership_scheme: '||p_partnership_scheme);
         DEBUG('p_employment_type: ' || p_employment_type);
         DEBUG('p_event_source: ' || p_event_source);
         DEBUG('p_absence_type: ' || p_absence_type);
         DEBUG('p_asg_status: ' || p_asg_status);
      END IF;

      -- Translate all classic plus scheme to classic
      l_source_pension_scheme    := p_pension_scheme;

      IF p_pension_scheme = 'CLASSPLUS'
      THEN
         l_source_pension_scheme    := 'PREMIUM';
      END IF;

      l_match                    := 'N';
      i                          := g_tab_event_map_cv.FIRST;

      WHILE i IS NOT NULL
      LOOP
         l_event_description    := g_tab_event_map_cv(i).pcv_information1;
         l_employment_type      := g_tab_event_map_cv(i).pcv_information9;
         l_pension_scheme       := g_tab_event_map_cv(i).pcv_information10;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_source_pension_scheme: ' || l_source_pension_scheme);
            DEBUG('l_event_description: ' || l_event_description);
            DEBUG('l_employment_type: ' || l_employment_type);
            DEBUG('l_pension_scheme: ' || l_pension_scheme);
         END IF;

         IF     p_event_desc = l_event_description
            AND (
                    (
                     NVL(l_source_pension_scheme, hr_api.g_varchar2) =
                                      NVL(l_pension_scheme, hr_api.g_varchar2)
                    )
                 OR (
                         l_source_pension_scheme IS NOT NULL
                     AND l_pension_scheme = 'ANY'
                    )
                 OR (
                         l_source_pension_scheme IN('CLASSIC', 'PREMIUM')
                     AND l_pension_scheme = 'CLASSPREM'
                    )
                )
            AND (
                    p_employment_type = l_employment_type
                 OR ( --115.70 5897563
                      --ANY refers only to REGULAR and CASUAL employment types
                      -- p_employment_type IS NOT NULL
                       nvl( p_employment_type,hr_api.g_varchar2) in
                                            ('REGULAR','CASUAL')
                     AND l_employment_type = 'ANY'
                    )
                )
         THEN
            IF p_event_source = 'ABS'
            THEN
               IF p_absence_type = g_tab_event_map_cv(i).pcv_information7
               THEN
                  l_match    := 'Y';
               END IF; -- absence type
            ELSIF p_event_source = 'ASG'
            THEN
               IF p_asg_status = g_tab_event_map_cv(i).pcv_information8
               THEN
                  l_match    := 'Y';
               END IF; -- asg status
            ELSE -- not abs or asg
               l_match    := 'Y';
            END IF; -- event source abs
         END IF; -- code match check ...

         IF l_match = 'Y'
         THEN
            l_start_reason       := g_tab_event_map_cv(i).pcv_information11;
            l_scheme_category    := g_tab_event_map_cv(i).pcv_information2;

           --115.14 Replace n in scheme category with Partnership scheme code
            if l_source_pension_scheme='PARTNER'
               and l_scheme_category in ('Qn','Nn','Sn') then
              l_scheme_category:=
                   substr(l_scheme_category,1,length(l_scheme_category)-1)||p_partnership_scheme;
            end if;

            l_scheme_status      := g_tab_event_map_cv(i).pcv_information3;
            EXIT;
         END IF;

         i                      := g_tab_event_map_cv.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_match: ' || l_match);
         DEBUG('l_start_reason: ' || l_start_reason);
         DEBUG('l_scheme_category: ' || l_scheme_category);
         DEBUG('l_scheme_status: ' || l_scheme_status);
      END IF;

      IF l_match = 'N'
      THEN
         -- codes does not match
         -- raise error
         NULL;
      END IF;

      p_start_reason             := l_start_reason;
      p_scheme_category          := l_scheme_category;
      p_scheme_status            := l_scheme_status;

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
   END get_service_history_code;

-- This procedure returns the absence event code for sickness and
-- maternity absence for pay transitions
-- ----------------------------------------------------------------------------
-- |---------------------< get_gap_transition_code >--------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_gap_transition_code(
      p_assignment_id           IN              NUMBER
     ,p_absence_attendance_id   IN              NUMBER
     ,p_effective_date          IN              DATE
     ,p_psi_event_code          IN              VARCHAR2
     ,p_absence_event_code      OUT NOCOPY      VARCHAR2
     ,p_rec_gap_details         OUT NOCOPY      csr_chk_pay_trans%ROWTYPE
   )
   IS
      --

      l_proc_name         VARCHAR2(80)
                                  := g_proc_name || 'get_gap_transition_code';
      l_proc_step         PLS_INTEGER;
      l_rec_gap_details   csr_chk_pay_trans%ROWTYPE;
      l_absence_code      VARCHAR2(10);
      l_return            VARCHAR2(10);
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_effective_date: '
            || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
         DEBUG('p_absence_attendance_id: ' || p_absence_attendance_id);
         DEBUG('p_psi_event_code: ' || p_psi_event_code);
      END IF;

      -- Check whether there is a possible transition to half pay/no pay or
      -- pension rate from the OSP summary table
      OPEN csr_chk_pay_trans(p_assignment_id, p_effective_date
            ,p_absence_attendance_id);

      LOOP
         FETCH csr_chk_pay_trans INTO l_rec_gap_details;
         EXIT WHEN csr_chk_pay_trans%NOTFOUND;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('p_psi_event_code: ' || p_psi_event_code);
           DEBUG('l_rec_gap_details.gap_level: '|| l_rec_gap_details.gap_level);
         END IF;

         IF p_psi_event_code = 'S'
         THEN -- Sickness
            IF l_rec_gap_details.gap_level = 'BAND2'
            THEN
               l_absence_code    := p_psi_event_code || 'H';
            ELSIF l_rec_gap_details.gap_level = 'NOBANDMIN'
            THEN
               --5549469 Replaced Px with P
               l_absence_code    := p_psi_event_code || 'P';
            ELSIF l_rec_gap_details.gap_level = 'NOBAND'
            THEN
               --5549469 Replaced Nx with N
               l_absence_code    := p_psi_event_code || 'N';

              --5549469 115.16
              --Undid prev change
             --ELSE
             --l_return           := 'N';
            END IF; -- End if of gap level = BAND 2 check ...
         ELSIF p_psi_event_code = 'M'
         THEN -- Maternity
            IF l_rec_gap_details.gap_level = 'BAND1'
            THEN
               l_absence_code    := p_psi_event_code || 'F'; -- For maternity
            ELSIF l_rec_gap_details.gap_level = 'NOBAND'
            THEN
               l_absence_code    := p_psi_event_code || 'N';
            --ELSE 5549489 Undid previous change.This is required only in
              --           function eval_gap_transition_event
              --l_return         := 'N';
            END IF; -- End if of gap level = BAND1 check ...
         END IF;         -- End if of sickness check ...
                 -- populate the variables only if the codes are in the
                 -- collection

         IF g_debug
         THEN
            l_proc_step    := 30;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_absence_code: ' || l_absence_code);
         END IF;

         IF l_absence_code IS NOT NULL
         THEN
            l_return    :=
                      chk_event_in_collection(p_event_code => l_absence_code);

            IF l_return = 'Y'
            THEN
               p_rec_gap_details       := l_rec_gap_details;
               p_absence_event_code    := l_absence_code;
               EXIT; -- Exit from cursor loop
            END IF; -- return check...
         END IF; -- absence code is not null check ...
      END LOOP; -- check pay transition cursor ...

      CLOSE csr_chk_pay_trans;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_return: ' || l_return);
         DEBUG('p_absence_event_code: '||p_absence_event_code);
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
   END get_gap_transition_code;

-- This function is used to get service history data
-- for an assignment as of a cutover date
-- ----------------------------------------------------------------------------
-- |---------------------< get_asg_ser_cutover_data >-------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_asg_ser_cutover_data(p_assignment_id IN NUMBER)
   IS
      --
      CURSOR csr_get_asg_status(
         c_effective_start_date   DATE
        ,c_effective_end_date     DATE
      )
      IS
         SELECT   asg1.assignment_id curr_assignment_id
                 ,asg1.assignment_status_type_id curr_status_type_id
                 ,asg1.effective_start_date curr_effective_start_date
                 ,asg1.effective_end_date curr_effective_end_date
                 ,asg2.assignment_status_type_id prev_status_type_id
                 ,asg2.effective_start_date prev_effective_start_date
                 ,asg2.effective_end_date prev_effective_end_date
             FROM per_all_assignments_f asg1, per_all_assignments_f asg2
            WHERE asg1.assignment_id = p_assignment_id
              AND (
                      (
                       asg1.effective_start_date BETWEEN c_effective_start_date
                                                     AND c_effective_end_date
                      )
                   OR (
                       asg1.effective_end_date BETWEEN c_effective_start_date
                                                   AND c_effective_end_date
                      )
                  )
              AND asg2.assignment_id = asg1.assignment_id
              AND asg2.effective_end_date = asg1.effective_start_date - 1
              AND asg2.assignment_status_type_id <>
                                                asg1.assignment_status_type_id
         ORDER BY asg1.effective_start_date DESC;

      -- Cursor to fetch min assignment effective start date
      -- for this employment category
      CURSOR csr_get_asg_start_date(c_employment_category VARCHAR2)
      IS
         SELECT MIN(effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id
            AND employment_category = c_employment_category;

      -- Cursor to fetch absence details for this person
      CURSOR csr_get_abs_details(
         c_person_id              NUMBER
        ,c_effective_start_date   DATE
        ,c_effective_end_date     DATE
      )
      IS
         SELECT   absence_attendance_type_id, absence_attendance_id
                 ,date_start, date_end
             FROM per_absence_attendances
            WHERE person_id = c_person_id
              AND (
                      (
                       date_start BETWEEN c_effective_start_date
                                      AND c_effective_end_date
                      )
                   OR (
                       ( NVL(date_end, c_effective_start_date)
                          BETWEEN c_effective_start_date
                              AND c_effective_end_date
                       )
                       AND
                       (date_start <= c_effective_end_date)
                      )
                  )
         ORDER BY date_start DESC;

      -- Cursor to get pension scheme element details
      -- for this person
      CURSOR csr_get_ele_ent_details(
         c_element_type_id        NUMBER
        ,c_effective_start_date   DATE
        ,c_effective_end_date     DATE
      )
      IS
         SELECT   pee.element_entry_id, pee.effective_start_date
                 ,pee.effective_end_date, pel.element_type_id
             FROM pay_element_entries_f pee, pay_element_links_f pel
            WHERE pee.assignment_id = p_assignment_id
              AND pee.entry_type = 'E'
              AND pee.element_link_id = pel.element_link_id
              AND (
                      (
                       pee.effective_start_date BETWEEN c_effective_start_date
                                                    AND c_effective_end_date
                      )
                   OR (
                       pee.effective_end_date BETWEEN c_effective_start_date
                                                  AND c_effective_end_date
                      )
                  )
              AND pel.element_type_id = c_element_type_id
              AND g_effective_date BETWEEN pel.effective_start_date
                                       AND pel.effective_end_date
         ORDER BY pee.effective_start_date DESC;

      -- Cursor to fetch opt out date information
      -- for a given element entry id
      CURSOR csr_chk_opt_out_info(
         c_element_type_id        NUMBER
        ,c_input_value_id         NUMBER
        ,c_effective_start_date   DATE
        ,c_effective_end_date     DATE
      )
      IS
         SELECT   pee.element_entry_id, pee.effective_start_date
                 ,pee.effective_end_date
             FROM pay_element_entries_f pee, pay_element_links_f pel
            WHERE pee.assignment_id = p_assignment_id
              AND pee.entry_type = 'E'
              AND pee.element_link_id = pel.element_link_id
              AND (
                      (
                       pee.effective_start_date BETWEEN c_effective_start_date
                                                    AND c_effective_end_date
                      )
                   OR (
                       pee.effective_end_date BETWEEN c_effective_start_date
                                                  AND c_effective_end_date
                      )
                  )
              AND pel.element_type_id = c_element_type_id
              AND g_effective_date BETWEEN pel.effective_start_date
                                       AND pel.effective_end_date
              AND EXISTS(
                     SELECT 1
                       FROM pay_element_entry_values_f pev
                      WHERE pev.element_entry_id = pee.element_entry_id
                        AND pev.effective_start_date =
                                                      pee.effective_start_date
                        AND pev.effective_end_date = pee.effective_end_date
                        AND pev.input_value_id = c_input_value_id
                        AND pev.screen_entry_value IS NOT NULL)
         ORDER BY pee.effective_start_date DESC;

      -- Cursor to check assignment details
      CURSOR csr_get_asg_details(c_effective_date DATE)
      IS
         SELECT   effective_end_date
             FROM per_all_assignments_f
            WHERE assignment_id = p_assignment_id
              AND c_effective_date BETWEEN effective_start_date
                                       AND effective_end_date
         ORDER BY effective_start_date;

      -- Cursor to fetch leaving reason for non period of service
      -- events
      CURSOR csr_get_leaving_reason(c_person_id      NUMBER
                                   ,c_effective_date DATE)
      IS
         SELECT pps.leaving_reason, pps.actual_termination_date
           FROM per_periods_of_service pps
          WHERE pps.person_id = c_person_id
            AND pps.date_start = (SELECT MAX(date_start)
                                FROM per_periods_of_service pps1
                               WHERE pps1.person_id = c_person_id
                                 AND pps1.date_start <= c_effective_date);

--For bug 7705147: Cursor to get Actual Termination Date
      CURSOR csr_get_atd
      IS
         SELECT pos.actual_termination_date
         FROM per_all_assignments_f asg,
              per_periods_of_service pos
         WHERE asg.assignment_id = p_assignment_id
           AND g_effective_date between asg.effective_start_date AND asg.effective_end_date
           AND asg.period_of_service_id = pos.period_of_service_id;

      l_act_term_date  DATE;
--

      l_proc_name                 VARCHAR2(80)
                                  := g_proc_name || 'get_asg_ser_cutover_data';
      l_proc_step                 PLS_INTEGER;
      l_rec_asg_status            csr_get_asg_status%ROWTYPE;
      l_rec_asg_details           r_asg_details;
      l_rec_abs_details           csr_get_abs_details%ROWTYPE;
      l_rec_ele_ent_details       r_ele_ent_details;
      l_rec_opt_out_info          csr_chk_opt_out_info%ROWTYPE;
      l_rec_gap_details           csr_chk_pay_trans%ROWTYPE;
      l_ser_start_date            DATE;
      l_start_reason              VARCHAR2(10);
      l_event_source              VARCHAR2(20);
      l_asg_start_date            DATE;
      l_psi_code                  VARCHAR2(10);
      l_element_type_id           NUMBER;
      l_input_value_id            NUMBER;
      l_char                      VARCHAR2(100);
      l_psi_emp_type              pqp_configuration_values.pcv_information1%TYPE;
      l_opt_out_date              DATE;
      l_asg_status_type_id        NUMBER;
      l_prev_asg_status_type_id   NUMBER;
      l_absence_type_id           NUMBER;
      l_pension_category          pqp_configuration_values.pcv_information1%TYPE;
      i                           NUMBER;
      j                           NUMBER;
      l_absence_event_code        VARCHAR2(10);
      l_effective_date            DATE;
      l_next_effective_date       DATE;
      l_value                     NUMBER;
      l_leaver_date               DATE;
      l_rec_leaving_reason        csr_get_leaving_reason%ROWTYPE;
      l_return                    VARCHAR2(10);
      l_index                     NUMBER;
      l_partnership_scheme        VARCHAR2(30);
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

      -- Get assignment details as of the cutover date
      -- To begin with, treat all employees as New Joiners
      -- with the start date as their latest start date
      -- We should get this information from basic criteria function
      IF g_assignment_dtl.assignment_id IS NULL
      THEN
         get_asg_details(
            p_assignment_id        => p_assignment_id
           ,p_effective_date       => g_effective_date
           ,p_rec_asg_details      => l_rec_asg_details
         );
      ELSE
         l_rec_asg_details.person_id                    :=
                                                   g_assignment_dtl.person_id;
         l_rec_asg_details.effective_start_date         :=
                                        g_assignment_dtl.effective_start_date;
         l_rec_asg_details.effective_end_date           :=
                                          g_assignment_dtl.effective_end_date;
         l_rec_asg_details.assignment_number            :=
                                           g_assignment_dtl.assignment_number;
         l_rec_asg_details.primary_flag                 :=
                                                g_assignment_dtl.primary_flag;
         l_rec_asg_details.normal_hours                 :=
                                                g_assignment_dtl.normal_hours;
         l_rec_asg_details.assignment_status_type_id    :=
                                   g_assignment_dtl.assignment_status_type_id;
         l_rec_asg_details.employment_category          :=
                                         g_assignment_dtl.employment_category;
      END IF; -- assignment dtl global record is null check ...

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('Person ID: ' || l_rec_asg_details.person_id);
         DEBUG(
               'Effective Start Date: '
            || TO_CHAR(l_rec_asg_details.effective_start_date, 'DD/MON/YYYY')
         );
         DEBUG(
               'Effective End Date: '
            || TO_CHAR(l_rec_asg_details.effective_end_date, 'DD/MON/YYYY')
         );
         DEBUG('Assignment Number: ' || l_rec_asg_details.assignment_number);
         DEBUG('Primary Flag: ' || l_rec_asg_details.primary_flag);
         DEBUG('Normal Hours: ' || l_rec_asg_details.normal_hours);
         DEBUG(
               'Assignment Status Type ID: '
            || l_rec_asg_details.assignment_status_type_id
         );
         DEBUG('Assignment Category: '
            || l_rec_asg_details.employment_category);
      END IF;

      -- Assign latest start date as the service date to start with
      l_ser_start_date    :=
         get_per_latest_start_date(
            p_person_id           => l_rec_asg_details.person_id
           ,p_effective_date      => l_rec_asg_details.effective_start_date
         );

      IF g_debug
      THEN
         DEBUG('l_ser_start_date: '
            || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY'));
      END IF;

      l_start_reason      := 'N';
      l_event_source      := 'SER';
      -- Get the earliest assignment effective start date when this
      -- person became eligible to be reported
      OPEN csr_get_asg_start_date(l_rec_asg_details.employment_category);
      FETCH csr_get_asg_start_date INTO l_asg_start_date;
      CLOSE csr_get_asg_start_date;

      IF l_ser_start_date < l_asg_start_date
      THEN
         l_ser_start_date    := l_asg_start_date;
      END IF;

    --For bug 7705147
    --Commented out the old logic for checking leaver
    /*
      IF pqp_gb_psi_functions.chk_is_employee_a_leaver(
          p_assignment_id       => p_assignment_id
         ,p_effective_date      => g_effective_date
         ,p_leaver_date         => l_leaver_date
         ) = 'Y'
      THEN
         IF l_leaver_date <= g_effective_date
         THEN
             l_ser_start_date    := l_leaver_date;
             l_start_reason      := 'ZZ'; -- Leaver
             l_event_source      := 'ASG';
         END IF; -- End if of leaver date <= g_effective_date
      END IF; -- employee a leaver check ...
    */
    --Added new logic for leaver
      OPEN csr_get_atd;
      FETCH csr_get_atd INTO l_act_term_date;

      IF csr_get_atd%FOUND
      THEN

          DEBUG('l_act_term_date: ' || l_act_term_date);
          DEBUG('g_effective_date: ' || g_effective_date);

          IF l_act_term_date IS NOT NULL
             AND l_act_term_date <= g_effective_date
          THEN
              l_ser_start_date    := l_act_term_date;
              l_start_reason      := 'ZZ'; -- Leaver
              l_event_source      := 'ASG';
          END IF;
      END IF;
      CLOSE csr_get_atd;
    --For bug 7705147: Till here

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_start_reason: ' || l_start_reason);
         DEBUG('l_event_source: ' || l_event_source);
         DEBUG('l_ser_start_date: '
            || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY'));
         DEBUG('l_asg_start_date: '
            || TO_CHAR(l_asg_start_date, 'DD/MON/YYYY'));
         DEBUG('Pension Event Processing: ');
      END IF;

      -- Check the employee's pension scheme membership as of the cutover date
      -- Loop through the scheme map ele collection
      -- to identify the pension scheme
      -- Proceed only if opt in and opt out events mapping code is available


      l_psi_emp_type      :=
         get_psi_emp_type(p_employment_category => l_rec_asg_details.employment_category);

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_opt_in: ' || g_opt_in);
         DEBUG('g_opt_out: ' || g_opt_out);
         DEBUG('l_psi_emp_type: ' || l_psi_emp_type);
      END IF;

      i                   := g_tab_pen_sch_map_cv.FIRST;

      WHILE i IS NOT NULL AND(g_opt_in = 'Y' OR g_opt_out = 'Y')
      LOOP
         l_element_type_id    :=
            fnd_number.canonical_to_number(g_tab_pen_sch_map_cv(i).pcv_information1);
         l_input_value_id     :=
                          g_tab_pen_ele_ids(l_element_type_id).input_value_id;

         IF g_debug
         THEN
            DEBUG('l_element_type_id: ' || l_element_type_id);
            DEBUG('l_input_value_id: ' || l_input_value_id);
         END IF;

         OPEN csr_get_ele_ent_details(l_element_type_id, l_ser_start_date
               ,g_effective_date     );
         FETCH csr_get_ele_ent_details INTO l_rec_ele_ent_details;

         IF csr_get_ele_ent_details%FOUND
         THEN
            -- Check whether this person has opted in
            -- We do this check based on CS rules
            -- All regular/fixed term employees become member of CS from
            -- day one.so the effective start date should match when the
            -- assignment started
            -- apart from casuals who will be enrolled 3 months later
            -- Get penserver category as at the element entry effective
            -- start date
            -- Casuals can become regular
            -- so check the status at element entry effective date
            IF g_debug
            THEN
               l_proc_step    := 50;
               DEBUG(l_proc_name, l_proc_step);
            END IF;

--         get_asg_details(p_assignment_id => p_assignment_id
--                        ,p_effective_date => l_rec_ele_ent_details.effective_start_date
--                        ,p_rec_asg_details => l_rec_asg_details
--                        );
            IF g_debug
            THEN
               l_proc_step    := 60;
               DEBUG(l_proc_name, l_proc_step);
            END IF;

            IF l_psi_emp_type <> 'CASUAL'
            THEN
   -- Regular/fixed term employees can opt into partnership schemes as well
--           IF g_tab_pen_sch_map_cv(i).pcv_information1 <> 'PARTNER'
--           THEN
               IF     l_rec_ele_ent_details.effective_end_date <>
                                                                 hr_api.g_eot
                  AND -- Bug 4873436: chk opt out only as of or b4 cutover date
                      l_rec_ele_ent_details.effective_end_date <=
                                                              g_effective_date
                  AND g_opt_out = 'Y'
               THEN
                  IF g_debug
                  THEN
                     l_proc_step    := 70;
                     DEBUG(l_proc_name, l_proc_step);
                  END IF;

                  -- Retrieve opt out date
                  -- Get the opt out date information
                  l_char                :=
                     get_screen_entry_value(
                        p_element_entry_id          => l_rec_ele_ent_details.element_entry_id
                       ,p_effective_start_date      => l_rec_ele_ent_details.effective_start_date
                       ,p_effective_end_date        => l_rec_ele_ent_details.effective_end_date
                       ,p_input_value_id            => l_input_value_id
                     );
                  l_opt_out_date        := fnd_date.canonical_to_date(l_char);

                  IF g_debug
                  THEN
                     l_proc_step    := 80;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG(
                           'l_opt_out_date: '
                        || TO_CHAR(l_opt_out_date, 'DD/MON/YYYY')
                     );
                  END IF;

                  l_ser_start_date      :=
                     LEAST(
                        NVL(
                           l_opt_out_date
                          ,l_rec_ele_ent_details.effective_end_date
                        )
                       ,l_rec_ele_ent_details.effective_end_date
                     );
                  l_event_source        := 'PENSION';
                  l_start_reason        := 'OO';
                  l_pension_category    :=
                                      g_tab_pen_sch_map_cv(i).pcv_information2;
                  l_partnership_scheme :=g_tab_pen_sch_map_cv(i).pcv_information3;

               ELSIF l_rec_ele_ent_details.effective_start_date <>
                                                              l_asg_start_date
               THEN
                  IF g_debug
                  THEN
                     l_proc_step    := 90;
                     DEBUG(l_proc_name, l_proc_step);
                  END IF;

                  -- Person has opted in
                  IF     l_ser_start_date <
                                    l_rec_ele_ent_details.effective_start_date
                     AND g_opt_in = 'Y'
                  THEN
                          -- Double check to ensure there was an opt out event
                          -- before opting in
                     -- Check whether this person has opted out anytime
                     -- Check this only for classic and premium
                     -- Can't check this as the person would have opted out on a
                     -- different scheme
--                      IF g_tab_pen_sch_map_cv(i).pcv_information1 <> 'PARTNER'
--                      THEN
--                         OPEN csr_chk_opt_out_info(
--                                l_element_type_id
--                               ,l_input_value_id
--                               ,l_asg_start_date
--                               ,g_effective_date
--                                                  );
--                         FETCH csr_chk_opt_out_info INTO l_rec_opt_out_info;
--
--                         IF csr_chk_opt_out_info%FOUND
--                         THEN
                     IF g_debug
                     THEN
                        l_proc_step    := 100;
                        DEBUG(l_proc_name, l_proc_step);
                     END IF;

                           -- Store this information
--                            l_ser_start_date      :=
--                                       l_rec_ele_ent_details.effective_start_date;
--                            l_event_source        := 'PENSION';
--                            l_start_reason        := 'OI';
--                            l_pension_category    :=
--                                         g_tab_pen_sch_map_cv(i).pcv_information1;
--                         END IF; -- End if of opt out cursor check ...
--
--                         CLOSE csr_chk_opt_out_info;
--                      ELSE -- Partnership
                     l_ser_start_date      :=
                                    l_rec_ele_ent_details.effective_start_date;
                     l_event_source        := 'PENSION';
                     l_start_reason        := 'OI';
                     l_pension_category    :=
                                      g_tab_pen_sch_map_cv(i).pcv_information2;
                     l_partnership_scheme :=g_tab_pen_sch_map_cv(i).pcv_information3;
--                     END IF; -- End if of partner check ...
                  END IF; -- End if of service start date < element entry start date ...
               END IF;
                     -- check element entry end date is set ...
--           END IF; -- Employee member of <> partner scheme check ...
            ELSIF l_psi_emp_type = 'CASUAL'
            THEN
               IF g_debug
               THEN
                  l_proc_step    := 110;
                  DEBUG(l_proc_name, l_proc_step);
               END IF;

               -- Check whether person is a member of partnership scheme
               IF g_tab_pen_sch_map_cv(i).pcv_information2 = 'PARTNER'
               THEN
                  IF     l_rec_ele_ent_details.effective_end_date <>
                                                                 hr_api.g_eot
                     AND -- Bug 4873436: chk opt out only as of or b4 cutover date
                         l_rec_ele_ent_details.effective_end_date <=
                                                              g_effective_date
                     AND g_opt_out = 'Y'
                  THEN
                     -- Get the opt out date information
                     l_char                :=
                        get_screen_entry_value(
                           p_element_entry_id          => l_rec_ele_ent_details.element_entry_id
                          ,p_effective_start_date      => l_rec_ele_ent_details.effective_start_date
                          ,p_effective_end_date        => l_rec_ele_ent_details.effective_end_date
                          ,p_input_value_id            => l_input_value_id
                        );
                     l_opt_out_date        :=
                                            fnd_date.canonical_to_date(l_char);

                     IF g_debug
                     THEN
                        l_proc_step    := 120;
                        DEBUG(l_proc_name, l_proc_step);
                     END IF;

                     l_ser_start_date      :=
                        LEAST(
                           NVL(
                              l_opt_out_date
                             ,l_rec_ele_ent_details.effective_end_date
                           )
                          ,l_rec_ele_ent_details.effective_end_date
                        );
                     l_event_source        := 'PENSION';
                     l_start_reason        := 'OO';
                     l_pension_category    :=
                                      g_tab_pen_sch_map_cv(i).pcv_information2;
                     l_partnership_scheme :=
                                      g_tab_pen_sch_map_cv(i).pcv_information3;
                  -- Remove the three month rule check for casuals
                  ELSIF l_rec_ele_ent_details.effective_start_date <> l_asg_start_date
                                               -- ADD_MONTHS(l_asg_start_date, 3)
                  THEN
                     -- Person has opted in
                     IF     l_ser_start_date <
                                   l_rec_ele_ent_details.effective_start_date
                        AND g_opt_in = 'Y'
                     THEN
                               -- Double check to ensure there was an opt out event
                             -- before opting in
                        -- Check whether this person has opted out anytime
                        -- Can't do this check as the person could have
                        -- enrolled into a different scheme
                        IF g_debug
                        THEN
                           l_proc_step    := 130;
                           DEBUG(l_proc_name, l_proc_step);
                        END IF;

--                         OPEN csr_chk_opt_out_info(
--                                l_element_type_id
--                               ,l_input_value_id
--                               ,l_asg_start_date
--                               ,g_effective_date
--                                                  );
--                         FETCH csr_chk_opt_out_info INTO l_rec_opt_out_info;
--
--                         IF csr_chk_opt_out_info%FOUND
--                         THEN
                           -- Store this information
                        l_ser_start_date      :=
                                    l_rec_ele_ent_details.effective_start_date;
                        l_event_source        := 'PENSION';
                        l_start_reason        := 'OI';
                        l_pension_category    :=
                                      g_tab_pen_sch_map_cv(i).pcv_information2;
                        l_partnership_scheme  :=g_tab_pen_sch_map_cv(i).pcv_information3;
--                         END IF; -- End if of opt out info found check ...
--
--                         CLOSE csr_chk_opt_out_info;
                     END IF; -- Service date lesser than element entry start date ...
                  END IF; -- check element entry end date is set ...

                          -- CLOSE csr_get_ele_ent_details;
                          -- EXIT; -- From collection loop
               END IF; -- End if of partner check ...
            END IF; -- End if of employment type <> casual check ...
         END IF; -- cursor found check ...

         CLOSE csr_get_ele_ent_details;
         i                    := g_tab_pen_sch_map_cv.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 140;
         DEBUG('l_start_reason: ' || l_start_reason);
         DEBUG('l_event_source: ' || l_event_source);
         DEBUG('l_ser_start_date: '
            || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY'));
         DEBUG('l_pension_category: ' || l_pension_category);
         DEBUG('l_partnership_scheme: '||l_partnership_scheme);
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('Absence Event Processing: ');
      END IF;

      -- Check the employee's absence records as of the cutover date
      --
      -- Only procced if there is atleast one  absence event source
      IF g_tab_abs_types.COUNT > 0
      THEN
         OPEN csr_get_abs_details(
                l_rec_asg_details.person_id
               ,l_ser_start_date
               ,g_effective_date
                                 );

         LOOP
            FETCH csr_get_abs_details INTO l_rec_abs_details;
            EXIT WHEN csr_get_abs_details%NOTFOUND;

            -- Loop through global absence type collection
            -- to check whether the fetched absence type matches
            IF g_debug
            THEN
               l_proc_step    := 150;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG(
                     'Absence attendance id: '
                  || l_rec_abs_details.absence_attendance_id
               );
               DEBUG(
                     'Absence Type Id: '
                  || l_rec_abs_details.absence_attendance_type_id
               );
               DEBUG(
                     'Date Start: '
                  || TO_CHAR(l_rec_abs_details.date_start, 'DD/MON/YYYY')
               );
               DEBUG(
                     'Date End: '
                  || TO_CHAR(l_rec_abs_details.date_end, 'DD/MON/YYYY')
               );
            END IF;

            i    := g_tab_abs_types.FIRST;

            WHILE i IS NOT NULL
            LOOP
               IF g_tab_abs_types(i) =
                                 l_rec_abs_details.absence_attendance_type_id
               THEN
                  IF     l_rec_abs_details.date_end IS NOT NULL
                     AND l_rec_abs_details.date_end <= g_effective_date
                  THEN
                     IF g_debug
                     THEN
                        l_proc_step    := 155;
                        DEBUG(l_proc_name, l_proc_step);
                        DEBUG('g_tab_abs_types(i): ' || g_tab_abs_types(i));
                     END IF;

                     -- Person has returned from absence
                     -- Use RB code instead
                     --RB for Sickness/Maternity to be returned only
                     --if there is a PAY transition
                     l_psi_code    :=
                         SUBSTR(g_tab_event_map_cv(i).pcv_information1, 1, 1);
                     IF l_psi_code in ('S','M') then

                        IF g_debug
                        THEN
                           l_proc_step    := 157;
                           DEBUG(l_proc_name, l_proc_step);
                           DEBUG('l_psi_code: ' || l_psi_code);
                        END IF;

                       get_gap_transition_code(
                          p_assignment_id           => p_assignment_id
                         ,p_absence_attendance_id   =>
                                         l_rec_abs_details.absence_attendance_id
                          ,p_effective_date         =>l_rec_abs_details.date_end
                          ,p_psi_event_code         => l_psi_code
                          ,p_absence_event_code     => l_absence_event_code
                          ,p_rec_gap_details        => l_rec_gap_details
                                                 );
                        IF l_absence_event_code is not NULL
                        THEN
                           IF g_debug
                           THEN
                           l_proc_step    := 160;
                           DEBUG(l_proc_name, l_proc_step);
                           DEBUG(
                              'l_absence_event_code: ' || l_absence_event_code
                           );
                           END IF;--g_debug
                         l_ser_start_date    := l_rec_abs_details.date_end + 1;
                         l_event_source      := 'ABSBREAK';
                         l_start_reason      := 'RB';
                        END IF;--absence_event_code is not NULL
                     ELSE --l_psi_code in ('S','M')
                           IF g_debug
                           THEN
                              l_proc_step    := 163;
                              DEBUG(l_proc_name, l_proc_step);
                              DEBUG('l_psi_code: ' || l_psi_code);
                           END IF;
                         l_ser_start_date    := l_rec_abs_details.date_end + 1;
                         l_event_source      := 'ABSBREAK';
                         l_start_reason      := 'RB';
                     END IF; --l_psi_code in ('S','M')
                  ELSE
                     -- Add additional logic to check whether the absence type
                     -- relates to sickness / maternity absence in which case we will have to
                     -- add this event only if there is a sickness / maternity transition from full pay to
                     -- half pay or to no pay or to pension rate
                     l_psi_code    :=
                         SUBSTR(g_tab_event_map_cv(i).pcv_information1, 1, 1);

                     IF l_psi_code IN('S', 'M') -- Sickness and Maternity
                     THEN
                        IF g_debug
                        THEN
                           l_proc_step    := 165;
                           DEBUG(l_proc_name, l_proc_step);
                           DEBUG('l_psi_code: ' || l_psi_code);
                        END IF;

                        get_gap_transition_code(
                           p_assignment_id              => p_assignment_id
                          ,p_absence_attendance_id      => l_rec_abs_details.absence_attendance_id
                          ,p_effective_date             => g_effective_date
                          ,p_psi_event_code             => l_psi_code
                          ,p_absence_event_code         => l_absence_event_code
                          ,p_rec_gap_details            => l_rec_gap_details
                        );

                        IF g_debug
                        THEN
                           l_proc_step    := 170;
                           DEBUG(l_proc_name, l_proc_step);
                           DEBUG(
                              'l_absence_event_code: ' || l_absence_event_code
                           );
                        END IF;

                        IF l_absence_event_code IS NOT NULL
                        THEN
                           l_ser_start_date     :=
                                                 l_rec_gap_details.date_start;
                           l_event_source       := 'ABS';
                           l_start_reason       := l_absence_event_code;
                           l_absence_type_id    :=
                                 l_rec_abs_details.absence_attendance_type_id;
                        END IF; -- End if of absence event code not null check ...
                     ELSE -- Not sickness or maternity
                        l_ser_start_date     := l_rec_abs_details.date_start;
                        l_event_source       := 'ABS';
                        l_start_reason       :=
                                      g_tab_event_map_cv(i).pcv_information11;
                        l_absence_type_id    :=
                                 l_rec_abs_details.absence_attendance_type_id;
                     END IF; -- End if of sickess type absence check ...
                  END IF; -- End if of date end is not null check ...

                  EXIT; -- exit from collection loop
               END IF; -- absence type in collection check ...

               i    := g_tab_abs_types.NEXT(i);
            END LOOP; -- collection loop

            IF l_event_source IN('ABS', 'ABSBREAK')
            THEN
               EXIT; -- Exit from absence cursor loop
            END IF;
         END LOOP; -- absence cursor loop

         CLOSE csr_get_abs_details;
      END IF; -- End if of atleast one absence event exists check ...

      IF g_debug
      THEN
         l_proc_step    := 180;
         DEBUG('l_start_reason: ' || l_start_reason);
         DEBUG('l_event_source: ' || l_event_source);
         DEBUG('l_ser_start_date: '
            || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY'));
         DEBUG('l_absence_type_id: ' || l_absence_type_id);
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('Assignment Status Event Processing: ');
      END IF;

      -- Check the employee's assignment status (if active ignore) as
      -- of cutover date
      -- Only proceed if there is atleast one assignment status event code
      IF g_tab_asg_status.COUNT > 0
      THEN
         OPEN csr_get_asg_status(l_ser_start_date, g_effective_date);

         LOOP
            FETCH csr_get_asg_status INTO l_rec_asg_status;
            EXIT WHEN csr_get_asg_status%NOTFOUND;

            IF g_debug
            THEN
               l_proc_step    := 190;
               DEBUG(
                     'l_rec_asg_status.curr_effective_start_date: '
                  || TO_CHAR(
                        l_rec_asg_status.curr_effective_start_date
                       ,'DD/MON/YYYY'
                     )
               );
               DEBUG(
                  'Assignment Status: '
                  || l_rec_asg_status.curr_status_type_id
               );
               DEBUG(l_proc_name, l_proc_step);
            END IF;

            -- Loop through the assignment status collection
            -- and check whether the current status matches
            i    := g_tab_asg_status.FIRST;

            WHILE i IS NOT NULL
            LOOP
               l_asg_status_type_id    :=
                          fnd_number.canonical_to_number(g_tab_asg_status(i));

               IF l_rec_asg_status.curr_status_type_id = l_asg_status_type_id
               THEN
                  IF g_debug
                  THEN
                     l_proc_step    := 200;
                     DEBUG('l_asg_status_type_id: ' || l_asg_status_type_id);
                     DEBUG(
                           'l_rec_asg_status.curr_status_type_id: '
                        || l_rec_asg_status.curr_status_type_id
                     );
                     DEBUG(
                           'l_rec_asg_status.prev_status_type_id: '
                        || l_rec_asg_status.prev_status_type_id
                     );
                     DEBUG(l_proc_name, l_proc_step);
                  END IF;

                  -- Check whether this is an active status
                  -- it could be that the person has returned from break

                  IF l_asg_status_type_id = g_active_asg_sts_id
                  THEN
                     -- Check whether the previous assignment status
                     -- is in the collection to signify a suspension
                     -- or non reckonable event
                     j    := g_tab_asg_status.FIRST;

                     WHILE j IS NOT NULL
                     LOOP
                        l_prev_asg_status_type_id    :=
                           fnd_number.canonical_to_number(g_tab_asg_status(j));

                        IF l_rec_asg_status.prev_status_type_id =
                                                    l_prev_asg_status_type_id
                        THEN
                           IF g_debug
                           THEN
                              l_proc_step    := 210;
                              DEBUG(l_proc_name, l_proc_step);
                              DEBUG(
                                 'g_active_asg_sts_id: '
                                 || g_active_asg_sts_id
                              );
                           END IF;

                           -- Can't be an active status
                           -- so mark as return from break
                           l_ser_start_date    :=
                                    l_rec_asg_status.curr_effective_start_date;
                           l_event_source      := 'ASGBREAK';
                           l_start_reason      := 'RB'; -- Return from break
                           EXIT; -- inner loop
                        END IF; -- End if of prev asg status type check ...

                        j                            :=
                                                      g_tab_asg_status.NEXT(j);
                     END LOOP;
                  ELSE -- not an active status
                     IF g_debug
                     THEN
                        l_proc_step    := 220;
                        DEBUG(l_proc_name, l_proc_step);
                     END IF;

                     l_ser_start_date    :=
                                    l_rec_asg_status.curr_effective_start_date;
                     l_event_source      := 'ASG';
                     l_start_reason      :=
                                       g_tab_event_map_cv(i).pcv_information11;
                  END IF; -- End if of asg status type = active ...

                  EXIT; -- Exit collection loop
               END IF; -- End if of status type in collection check ...

               i                       := g_tab_asg_status.NEXT(i);
            END LOOP; -- collection loop;

            IF l_event_source IN('ASG', 'ASGBREAK')
            THEN
               -- Exit from cursor as well
               EXIT;
            END IF;
         END LOOP; -- cursor loop

         CLOSE csr_get_asg_status;
      END IF; -- End if of at least one asg status event exists in colleciton ...

      IF g_debug
      THEN
         l_proc_step    := 230;
         DEBUG('l_start_reason: ' || l_start_reason);
         DEBUG('l_event_source: ' || l_event_source);
         DEBUG('l_ser_start_date: '
            || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY'));
         DEBUG('l_asg_status_type_id: ' || l_asg_status_type_id);
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      IF g_debug
      THEN
         l_proc_step    := 240;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_pension_category: ' || l_pension_category);
      END IF;

      -- Fetch the codes for service history DE from event map cv
      -- Penserv Category
      IF l_event_source <> 'PENSION' OR l_pension_category IS NULL
      THEN
         l_pension_category    :=
            get_pen_scheme_memb(
               p_assignment_id            => p_assignment_id
              ,p_effective_date           => l_ser_start_date
              ,p_tab_pen_sch_map_cv       => g_tab_pen_sch_map_cv
              ,p_rec_ele_ent_details      => l_rec_ele_ent_details
              ,p_partnership_scheme       => l_partnership_scheme
            );
      ELSIF l_event_source = 'PENSION' AND l_start_reason = 'OO'
      THEN
         IF g_debug
         THEN
            l_proc_step    := 245;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- Ensure that this is not due to a termination event
         -- Bug Fix 4873436
         OPEN csr_get_asg_details(l_ser_start_date);
         FETCH csr_get_asg_details INTO l_effective_date;
         FETCH csr_get_asg_details INTO l_next_effective_date;

         IF l_effective_date <> hr_api.g_eot
            AND csr_get_asg_details%NOTFOUND
         THEN
            -- This is due to termination event
            l_start_reason    := 'ZZ';
            l_event_source    := 'ASG';
         END IF; -- End if of effective date not eot
      END IF; -- End if of event source <> pension check ...

      IF g_debug
      THEN
         l_proc_step    := 250;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

--      get_asg_details(p_assignment_id => p_assignment_id
--                      ,p_effective_date => l_ser_start_date
--                      ,p_rec_asg_details => l_rec_asg_details
--                      );
--      IF g_debug THEN
--         l_proc_step := 240;
--         debug(l_proc_name, l_proc_step);
--      END IF;
--
--      l_psi_emp_type := get_psi_emp_type
--                          (p_employment_category => l_rec_asg_details.employment_category);

      IF g_debug
      THEN
         l_proc_step    := 260;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_psi_emp_type: ' || l_psi_emp_type);
      END IF;

      g_ser_start_date    := l_ser_start_date;

      IF     l_start_reason = 'ZZ'
         AND NVL(l_asg_status_type_id, hr_api.g_number) <>
                                                        g_terminate_asg_sts_id
      THEN
         l_asg_status_type_id    := g_terminate_asg_sts_id;
      END IF;

      IF l_start_reason = 'ZZ' AND
         g_leaving_reason IS NULL
      THEN
         -- Get the leaving reason code
         IF g_debug
         THEN
           l_proc_step := 270;
           DEBUG(l_proc_name, l_proc_step);
         END IF;
         OPEN csr_get_leaving_reason(l_rec_asg_details.person_id
                                    ,l_ser_start_date);
         FETCH csr_get_leaving_reason INTO l_rec_leaving_reason;
         CLOSE csr_get_leaving_reason;

         -- Get the penserver leaving reason code
         -- for this termination event
         IF l_rec_leaving_reason.leaving_reason IS NOT NULL
         THEN

            IF g_debug
            THEN
              l_proc_step := 280;
              DEBUG(l_proc_name, l_proc_step);
              DEBUG('l_rec_leaving_reason.leaving_reason: '
                 || l_rec_leaving_reason.leaving_reason
              );
            END IF;
            l_index := NULL;
            l_return :=
              chk_lvrsn_in_collection
                (p_leave_reason => l_rec_leaving_reason.leaving_reason
                ,p_index        => l_index
                );
             IF l_return = 'Y' THEN
               IF g_debug
               THEN
                 DEBUG('g_tab_lvrsn_map_cv(l_index).pcv_information2: '
                   ||  g_tab_lvrsn_map_cv(l_index).pcv_information2
                 );
               END IF;
               g_leaving_reason := g_tab_lvrsn_map_cv(l_index).pcv_information2;
             END IF; -- End if of l_index is not null check ...
         ELSE
             -- Raise data error
             IF g_debug
             THEN
               DEBUG('Raise Data Error: Leaving Reason Missing');
             END IF;
              l_value    :=
                      pqp_gb_psi_functions.raise_extract_error(
                        p_error_number      => 94479
                       ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                       ,p_token1            => 'Leaving Reason'
                       );

         END IF; -- End if of leaving reason is not null check ...
      END IF; -- End if of l_start_reason = 'ZZ' check ...


      -- Enhancement 5040543
      -- Add a warning message when pension category is null
      IF l_pension_category IS NULL
      THEN

        IF g_debug
        THEN
          l_proc_step := 290;
          DEBUG(l_proc_name, l_proc_step);
          DEBUG('Not a member of CS scheme');
        END IF;

        l_value    :=
             pqp_gb_psi_functions.raise_extract_warning(
               p_error_number      => 93775
              ,p_error_text        => 'BEN_93775_EXT_PSI_NOT_PEN_MEMB'
              ,p_token1            => p_assignment_id
              ,p_token2            => fnd_date.date_to_displaydt(g_effective_date)
              );
      END IF; -- End if of pension category is null check ...

      get_service_history_code(
         p_event_desc           => l_start_reason
        ,p_pension_scheme       => l_pension_category
        ,p_employment_type      => l_psi_emp_type
        ,p_event_source         => l_event_source
        ,p_absence_type         => l_absence_type_id
        ,p_asg_status           => NVL(
                                      l_asg_status_type_id
                                     ,l_rec_asg_details.assignment_status_type_id
                                   )
        ,p_partnership_scheme   =>l_partnership_scheme
        ,p_start_reason         => g_start_reason
        ,p_scheme_category      => g_scheme_category
        ,p_scheme_status        => g_scheme_status
      );

      -- Check whether the person has opted out of the pension scheme
      -- on the joining day (hired day)
      IF l_start_reason = 'OO' AND l_asg_start_date = l_ser_start_date
      THEN
         g_start_reason    := 'N';
      END IF;

      IF g_debug
      THEN
         l_proc_step    := 300;
         DEBUG('l_asg_status_type_id: ' || l_asg_status_type_id);
         DEBUG('g_start_reason: ' || g_start_reason);
         DEBUG('g_scheme_category: ' || g_scheme_category);
         DEBUG('g_scheme_status: ' || g_scheme_status);
         DEBUG('g_ser_start_date: '
            || TO_CHAR(g_ser_start_date, 'DD/MON/YYYY'));
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
   END get_asg_ser_cutover_data;

-- This function evaluates assignment status events for
-- service history interface
-- ----------------------------------------------------------------------------
-- |---------------------< eval_asg_status_event >----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION eval_asg_status_event(
      p_assignment_id         IN              NUMBER
     ,p_curr_status_type_id   IN              NUMBER
     ,p_prev_status_type_id   IN              NUMBER
     ,p_start_reason          OUT NOCOPY      pqp_configuration_values.pcv_information1%TYPE
     ,p_event_source          OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name        VARCHAR2(80)
                                    := g_proc_name || 'eval_asg_status_event';
      l_proc_step        PLS_INTEGER;
      l_return           VARCHAR2(10);
      l_start_reason     pqp_configuration_values.pcv_information1%TYPE;
      l_ser_start_date   DATE;
      l_event_source     VARCHAR2(100);
      l_index            NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_curr_status_type_id :' || p_curr_status_type_id);
         DEBUG('p_prev_status_type_id: ' || p_prev_status_type_id);
      END IF;

      l_return          := 'N';

      -- Check whether the current status type is active
      IF p_curr_status_type_id = g_active_asg_sts_id
      THEN
         -- If the current status type id is active
         -- Check whether the previous status type id is in the collection
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         IF p_prev_status_type_id <> g_terminate_asg_sts_id -- ignore rehires
         THEN
            l_return    :=
               chk_value_in_collection(
                  p_collection_name      => g_tab_asg_status
                 ,p_value                => p_prev_status_type_id
                 ,p_index                => l_index
               );

            IF l_return = 'Y'
            THEN
               IF g_debug
               THEN
                  l_proc_step    := 30;
                  DEBUG(l_proc_name, l_proc_step);
                  DEBUG('l_return: ' || l_return);
               END IF;

               -- Yes is in the collection
               -- so this should be a return from break status
               l_start_reason    := 'RB'; -- Return from break
               l_event_source    := 'ASGBREAK';
            END IF; -- End if of value in collection check ...
         END IF; -- End if of prev status not in terminations ...
      ELSIF     p_curr_status_type_id <> g_active_asg_sts_id
            AND p_curr_status_type_id <> g_terminate_asg_sts_id
      -- we are not interested in terminations
      THEN
         -- current status is not active
         -- check whether the current status is in the collection
         IF g_debug
         THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         l_return    :=
            chk_value_in_collection(
               p_collection_name      => g_tab_asg_status
              ,p_value                => p_curr_status_type_id
              ,p_index                => l_index
            );

         IF l_return = 'Y'
         THEN
            IF g_debug
            THEN
               l_proc_step    := 50;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_return: ' || l_return);
            END IF;

            -- We are interested in this status
            -- Return the codes
            l_start_reason    := g_tab_event_map_cv(l_index).pcv_information11;
            l_event_source    := 'ASG';
         END IF; -- End if of value in collection check ...
      END IF; -- End if of current status type is active check ...

      p_start_reason    := l_start_reason;
      p_event_source    := l_event_source;

      IF g_debug
      THEN
         l_proc_step    := 60;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('p_start_reason: ' || l_start_reason);
         DEBUG('p_event_source: ' || l_event_source);
         DEBUG('l_return: ' || l_return);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_return;
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
   END eval_asg_status_event;

-- This function evaluates absence events for service
-- history interface
-- ----------------------------------------------------------------------------
-- |---------------------< eval_absence_event >-------------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION eval_absence_event(
      p_assignment_id           IN              NUMBER
     ,p_absence_attendance_id   IN              NUMBER
     ,p_event_group_name        IN              pay_event_groups.event_group_name%TYPE
     ,p_absence_type_id         OUT NOCOPY      NUMBER
     ,p_start_reason            OUT NOCOPY      pqp_configuration_values.pcv_information1%TYPE
     ,p_ser_start_date          OUT NOCOPY      DATE
     ,p_event_source            OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
   IS
      --
      CURSOR csr_get_abs_dtls
      IS
         SELECT absence_attendance_id, absence_attendance_type_id
               ,date_start, date_end
           FROM per_absence_attendances
          WHERE absence_attendance_id = p_absence_attendance_id;

-- For Bug 5970465
      CURSOR csr_get_term_date
      IS
         SELECT actual_termination_date
           FROM per_all_assignments_f paf,
                per_periods_of_service pos
          WHERE paf.assignment_id=p_assignment_id
            AND paf.period_of_service_id = pos.period_of_service_id;



      l_proc_name            VARCHAR2(80)
                                       := g_proc_name || 'eval_absence_event';
      l_proc_step            PLS_INTEGER;
      l_rec_abs_dtls         csr_get_abs_dtls%ROWTYPE;
      l_rec_gap_details      csr_chk_pay_trans%ROWTYPE;
      l_return               VARCHAR2(10);
      l_value_in_collection  VARCHAR2(10);
      l_start_reason         pqp_configuration_values.pcv_information1%TYPE;
      l_ser_start_date       DATE;
      l_event_source         VARCHAR2(100);
      l_index                NUMBER;
      l_absence_event_code   VARCHAR2(10);
      l_psi_code             VARCHAR2(10);
      l_absence_type_id      NUMBER;
      l_actual_term_date     DATE;
   --

   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_absence_attendance_id: ' || p_absence_attendance_id);
         DEBUG('p_event_group_name: ' || p_event_group_name);
      END IF;

      l_return             := 'N';
      OPEN csr_get_abs_dtls;
      FETCH csr_get_abs_dtls INTO l_rec_abs_dtls;

      IF csr_get_abs_dtls%NOTFOUND
      THEN
         -- Might be a delete event
         IF g_tab_pay_proc_evnts(g_event_counter).update_type = 'P'
         THEN
            --
            NULL;
         END IF;
      ELSE
         -- Check whether absence type is in collection
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         l_value_in_collection    :=
            chk_value_in_collection(
             p_collection_name      => g_tab_abs_types
            ,p_value                => l_rec_abs_dtls.absence_attendance_type_id
            ,p_index                => l_index
            );
         --115.21 Collection to be accessed only if value is in collection
         --Moved inside IF block=> SUBSTR(g_tab_event_map_cv(l_index)

         IF l_value_in_collection = 'Y'
         THEN

         l_psi_code    :=
                   SUBSTR(g_tab_event_map_cv(l_index).pcv_information1, 1, 1);

            IF     l_rec_abs_dtls.date_end IS NOT NULL
               AND l_rec_abs_dtls.date_end <=
                                     pqp_gb_psi_functions.g_effective_end_date
               AND p_event_group_name = 'PQP_GB_PSI_SER_ABSENCES'
            THEN
              -- For Bug 5970465
              OPEN csr_get_term_date;
              FETCH csr_get_term_date INTO l_actual_term_date;
              CLOSE csr_get_term_date;

              IF  l_actual_term_date is NULL
              or  (l_actual_term_date is NOT NULL AND l_actual_term_date > l_rec_abs_dtls.date_end + 1) -- For Bug 6024703
              THEN

               -- This should be a return from break
               -- populate service start date
               --115.16 RB event for Sickness,Maternity to be reported
               --only if a transition event exists.
               IF l_psi_code in ('S','M') then

                  get_gap_transition_code
                    (p_assignment_id         => p_assignment_id
                    ,p_absence_attendance_id => p_absence_attendance_id
                    ,p_effective_date        => l_rec_abs_dtls.date_end
                    ,p_psi_event_code        => l_psi_code
                    ,p_absence_event_code    => l_absence_event_code
                    ,p_rec_gap_details       => l_rec_gap_details
                    );
                  IF g_debug
                  THEN
                    l_proc_step := 25;
                    debug(l_proc_name, l_proc_step);
                    debug('l_absence_event_code: '||l_absence_event_code);
                  END IF;

                  IF l_absence_event_code is not null then
                   l_ser_start_date    := l_rec_abs_dtls.date_end + 1;
                   l_start_reason      := 'RB';
                   l_event_source      := 'ABSBREAK';
                   l_return            := 'Y';
                  END IF;

                ELSE
                --Not Sickness or maternity.Return RB without checking for
                --transition
                 l_ser_start_date    := l_rec_abs_dtls.date_end + 1;
                 l_start_reason      := 'RB';
                 l_event_source      := 'ABSBREAK';
                 l_return            := 'Y';
                  IF g_debug
                   THEN
                    l_proc_step    := 30;
                    DEBUG(l_proc_name, l_proc_step);
                    DEBUG(
                          'Event Code: '
                       || g_tab_event_map_cv(l_index).pcv_information1
                     );
                  END IF;
               END IF;--l_psi_code in('S','M')
              END IF; --For Bug 5970465
--          ELSIF l_psi_code IN ('S','M')
--          THEN
--            IF g_debug
--            THEN
--              l_proc_step := 40;
--              debug(l_proc_name, l_proc_step);
--              debug('l_psi_code: '||l_psi_code);
--            END IF;
--            -- still an open ended absence
--            -- check for gap transition code
--          get_gap_transition_code
--            (p_assignment_id         => p_assignment_id
--                 ,p_absence_attendance_id => p_absence_attendance_id
--                 ,p_effective_date        => g_effective_date
--                 ,p_psi_event_code        => l_psi_code
--                 ,p_absence_event_code    => l_absence_event_code
--                 ,p_rec_gap_details       => l_rec_gap_details
--                 );
--          IF l_absence_event_code IS NOT NULL THEN
--            l_start_reason := l_absence_event_code;
--            l_ser_start_date := l_rec_gap_details.date_start;
--            l_event_source := 'ABS';
--          END IF;
            ELSIF l_psi_code NOT IN('S', 'M')
            THEN -- Not sickness and maternity -- end date is null
               IF g_debug
               THEN
                  l_proc_step    := 50;
                  DEBUG(l_proc_name, l_proc_step);
               END IF;

               l_start_reason       :=
                                 g_tab_event_map_cv(l_index).pcv_information11;
               l_ser_start_date     := l_rec_abs_dtls.date_start;
               l_event_source       := 'ABS';
               l_absence_type_id    :=
                                     l_rec_abs_dtls.absence_attendance_type_id;
               l_return             := 'Y';
            END IF; -- date end is not null check ...
         END IF; -- Return = 'Y' check ...
      END IF; -- End if of cursor not found check ...

      CLOSE csr_get_abs_dtls;
      p_absence_type_id    := l_absence_type_id;
      p_start_reason       := l_start_reason;
      p_ser_start_date     := l_ser_start_date;
      p_event_source       := l_event_source;

      IF g_debug
      THEN
         l_proc_step    := 60;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('p_absence_type_id: ' || l_absence_type_id);
         DEBUG('p_start_reason: ' || l_start_reason);
         DEBUG('p_ser_start_date: '
            || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY'));
         DEBUG('p_event_source: ' || l_event_source);
         DEBUG('l_return: '       || l_return);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_return;
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
   END eval_absence_event;

-- This function evaluates gap transition events for service
-- history interface
-- ----------------------------------------------------------------------------
-- |---------------------< eval_gap_transition_event >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION eval_gap_transition_event(
      p_assignment_id             IN              NUMBER
     ,p_gap_duration_summary_id   IN              NUMBER
     ,p_absence_type_id           OUT NOCOPY      NUMBER
     ,p_start_reason              OUT NOCOPY      pqp_configuration_values.pcv_information1%TYPE
     ,p_ser_start_date            OUT NOCOPY      DATE
     ,p_event_source              OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
   IS
      --
      CURSOR csr_get_abs_dtls(c_absence_attendance_id NUMBER)
      IS
         SELECT absence_attendance_id, absence_attendance_type_id
               ,date_start, date_end
           FROM per_absence_attendances
          WHERE absence_attendance_id = c_absence_attendance_id;

      -- Cursor to get gap duration summary details
      CURSOR csr_get_gap_summary_dtls
      IS
         SELECT gap.absence_attendance_id, glds.gap_absence_plan_id
               ,glds.gap_level, glds.date_start, glds.date_end
               ,glds.summary_type
           FROM pqp_gap_absence_plans gap, pqp_gap_duration_summary glds
          WHERE glds.gap_absence_plan_id = gap.gap_absence_plan_id
            AND glds.gap_duration_summary_id = p_gap_duration_summary_id;

      --For Bug 6972649 from here
      CURSOR csr_get_act_term_date
      IS
         SELECT actual_termination_date
         FROM per_all_assignments_f paf,
              per_periods_of_service pos
         WHERE paf.assignment_id=p_assignment_id
           AND paf.period_of_service_id = pos.period_of_service_id;
      --For Bug 6972649 till here

      l_proc_name                 VARCHAR2(80)
                                 := g_proc_name || 'eval_gap_transition_event';
      l_proc_step                 PLS_INTEGER;
      l_rec_abs_dtls              csr_get_abs_dtls%ROWTYPE;
      l_rec_gap_details           csr_get_gap_summary_dtls%ROWTYPE;
      l_return                    VARCHAR2(10);
      l_start_reason              pqp_configuration_values.pcv_information1%TYPE;
      l_ser_start_date            DATE;
      l_event_source              VARCHAR2(100);
      l_index                     NUMBER;
      l_absence_code              VARCHAR2(10);
      l_psi_code                  VARCHAR2(10);
      l_absence_type_id           NUMBER;
      l_gap_duration_summary_id   NUMBER;
      --For Bug 6972649 from here
      l_actual_term_date     DATE;
      --For Bug 6972649 till here

   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_gap_duration_summary_id: ' || p_gap_duration_summary_id);
      END IF;

      l_return             := 'N';
      -- Get gap duration summary details
      OPEN csr_get_gap_summary_dtls;
      FETCH csr_get_gap_summary_dtls INTO l_rec_gap_details;

      IF csr_get_gap_summary_dtls%NOTFOUND
      THEN
         -- Might be a delete event
         IF g_tab_pay_proc_evnts(g_event_counter).update_type = 'P'
         THEN
            --
            NULL;
         END IF;
      ELSE -- row found
         OPEN csr_get_abs_dtls(l_rec_gap_details.absence_attendance_id);
         FETCH csr_get_abs_dtls INTO l_rec_abs_dtls;
         CLOSE csr_get_abs_dtls;

         -- Check whether absence type is in collection
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);

         END IF;

         l_return      :=
            chk_value_in_collection(
             p_collection_name      => g_tab_abs_types
            ,p_value                => l_rec_abs_dtls.absence_attendance_type_id
            ,p_index                => l_index
            );

       --115.21 Collection to be accessed only if value is in collection
       --Moved inside IF block=> SUBSTR(g_tab_event_map_cv(l_index)

         IF l_return = 'Y'
         THEN
             l_psi_code    :=
                     SUBSTR(g_tab_event_map_cv(l_index).pcv_information1, 1, 1);

            IF g_debug THEN
               DEBUG('l_psi_code '||l_psi_code);
               DEBUG('l_rec_gap_details.summary_type '
                     ||l_rec_gap_details.summary_type);
               DEBUG(' l_rec_gap_details.gap_level '
                     ||l_rec_gap_details.gap_level);
            END IF;


            IF  l_rec_gap_details.summary_type = 'PAY'
               --115.21 gap_transitions to be checked only for S and M
            AND l_psi_code in ('S','M')
            THEN
                  --For Bug 6972649 from here
                   OPEN csr_get_act_term_date;
                   FETCH csr_get_act_term_date INTO l_actual_term_date;
                   CLOSE csr_get_act_term_date;

                   IF  l_actual_term_date is NULL
                       or (l_actual_term_date is NOT NULL
                     AND l_actual_term_date > l_rec_gap_details.date_start)
                   THEN
                   DEBUG('ATD is null or it is greater than start date');
                     DEBUG('l_actual_term_date: '||l_actual_term_date);
                     DEBUG('l_rec_gap_details.date_start: '||l_rec_gap_details.date_start);
                     DEBUG('l_psi_code: '||l_psi_code);
                   DEBUG('l_rec_gap_details.gap_level: '||l_rec_gap_details.gap_level);
                  --For Bug 6972649 till here

                       --   l_absence_code    := NULL; 115.16.By default it is null.
                         IF l_psi_code = 'S'
                         THEN -- Sickness
                               IF l_rec_gap_details.gap_level = 'BAND2'
                               THEN
                                    l_absence_code    := l_psi_code || 'H';
                               ELSIF l_rec_gap_details.gap_level = 'NOBANDMIN'
                                THEN
                              --5549469 Replaced Px with P
                              l_absence_code    := l_psi_code || 'P';
                         ELSIF l_rec_gap_details.gap_level = 'NOBAND'
                        THEN
                              --5549469 Replaced Nx with N
                              l_absence_code    := l_psi_code || 'N';
                         ELSE
                                     --5549469.Return N if gap_level is not
                             --what we checked for.
                              l_return            := 'N';
                               END IF; -- End if of gap level = BAND 2 check ...
                         ELSIF l_psi_code = 'M'
                          THEN -- Maternity
                               IF l_rec_gap_details.gap_level = 'BAND1'
                               THEN
                                    l_absence_code    := l_psi_code || 'F'; -- For maternity
                               ELSIF l_rec_gap_details.gap_level = 'NOBAND'
                                THEN
                                     l_absence_code    := l_psi_code || 'N';
                               ELSE
                                --5549469.Return N if gap_level is not
                            --what we checked for.
                                l_return          := 'N';
                         END IF; -- End if of gap level = BAND1 check ...
                   END IF;                 -- End if of sickness check ...

                   --For Bug 6972649 from here
                         DEBUG('l_absence_code: '||l_absence_code);
                   Else --actual termination date is not null and it is less than start date
                        l_return          := 'N';
                        DEBUG('ATD is not null and it is less than start date');
                        DEBUG('l_return: '||l_return);
                   End IF;--actual termination date is NULL
                   --For Bug 6972649 till here

                    -- populate the variables only if the codes are in the
                    -- collection

            IF g_debug
            THEN
               l_proc_step    := 30;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_absence_code: ' || l_absence_code);
            END IF;

            IF l_absence_code IS NOT NULL
            THEN
               l_return    :=
                      chk_event_in_collection(p_event_code => l_absence_code);

               IF l_return = 'Y'
               THEN
                  IF g_debug
                  THEN
                     l_proc_step    := 50;
                     DEBUG(l_proc_name, l_proc_step);
                  END IF;

                  l_start_reason       := l_absence_code;
                  l_ser_start_date     := l_rec_gap_details.date_start;
                  l_event_source       := 'ABS';
                  l_absence_type_id    :=
                                     l_rec_abs_dtls.absence_attendance_type_id;
               END IF; -- End if of l_return = Y check ...
            END IF; -- absence code is not null check ...
         ELSE
           --5549469 115.16
           --return N if l_rec_gap_details.summary_type <> 'PAY'
          l_return := 'N';
         END IF; -- Return = 'Y' check ...
       END IF;-- summary_type = 'PAY'and l_psi_code in ('S','M')
      END IF; -- End if of cursor not found check ...

      CLOSE csr_get_gap_summary_dtls;
      p_absence_type_id    := l_absence_type_id;
      p_start_reason       := l_start_reason;
      p_ser_start_date     := l_ser_start_date;
      p_event_source       := l_event_source;

      IF g_debug
      THEN
         l_proc_step    := 60;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('p_absence_type_id: ' || l_absence_type_id);
         DEBUG('p_start_reason: ' || l_start_reason);
         DEBUG('p_ser_start_date: '
            || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY'));
         DEBUG('p_event_source: ' || l_event_source);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_return;
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
   END eval_gap_transition_event;

   -- Function to check if there is a change in pension scheme
   -- on the following day.(i.e same pension element is end dated or attached the previous /following day)
   -- For Bug: 6524143
   FUNCTION change_in_pension_scheme (p_assignment_id       IN  NUMBER,
                                      p_pension_change_date IN  DATE,
                                      p_start_reason        IN  VARCHAR2,
                              p_element_type_id         IN  NUMBER
                             )
      RETURN BOOLEAN
   IS

      CURSOR csr_get_opt_in_info_next_day
      IS
      SELECT element_type_id
        FROM pay_element_entries_f
       WHERE assignment_id = p_assignment_id
         AND element_type_id = p_element_type_id
         AND effective_start_date = p_pension_change_date + 1;

      CURSOR csr_get_opt_out_info_prev_day
      IS
      SELECT element_type_id
        FROM pay_element_entries_f
       WHERE assignment_id = p_assignment_id
         AND element_type_id = p_element_type_id
         AND effective_end_date = p_pension_change_date - 1;

      l_proc_name                 VARCHAR2(80):= g_proc_name || 'change_in_pension_scheme';
      l_proc_step                 PLS_INTEGER;
      l_return_flag     BOOLEAN := FALSE;
      l_element_type_id NUMBER := NULL;

   BEGIN
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_start_reason: ' || p_start_reason);
         DEBUG('p_element_type_id: ' || p_element_type_id);
         DEBUG('p_pension_change_date: ' || p_pension_change_date);
      END IF;

      l_return_flag := FALSE;

     IF p_start_reason = 'OI' THEN
         -- check old pension element on prev day.
       OPEN csr_get_opt_out_info_prev_day;
       FETCH csr_get_opt_out_info_prev_day INTO l_element_type_id;
       IF l_element_type_id IS NOT NULL
       THEN
          l_return_flag := TRUE;
       END IF;
      close csr_get_opt_out_info_prev_day;

      ELSIF  p_start_reason = 'OO' THEN
         -- check new pension element on next day.
         OPEN csr_get_opt_in_info_next_day;
       FETCH csr_get_opt_in_info_next_day INTO l_element_type_id;
       IF l_element_type_id IS NOT NULL
       THEN
          l_return_flag := TRUE;
       END IF;
        close csr_get_opt_in_info_next_day;
     END IF;

      IF g_debug
         THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
       IF  l_return_flag = TRUE THEN
         DEBUG('l_return_flag: ' || 'TRUE');
       ELSE
         DEBUG('l_return_flag: ' || 'FALSE');
       END IF;
         debug_exit(l_proc_name);
      END IF;

   RETURN l_return_flag;
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
   END change_in_pension_scheme;

-- This function is used to evaluate pension events for
-- service history periodic interface
-- ----------------------------------------------------------------------------
-- |--------------------------< eval_pension_event >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION eval_pension_event(
      p_assignment_id      IN              NUMBER
     ,p_table_name         IN              VARCHAR2
     ,p_surrogate_key      IN              NUMBER
     ,p_ser_start_date     OUT NOCOPY      DATE
     ,p_start_reason       OUT NOCOPY      VARCHAR2
     ,p_event_source       OUT NOCOPY      VARCHAR2
     ,p_pension_category   OUT NOCOPY      VARCHAR2
     ,p_partnership_scheme OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
   IS
      --
      -- Cursor to fetch element entry information
      CURSOR csr_get_ele_ent_info(c_element_entry_id NUMBER)
      IS
         SELECT pel.element_type_id, pee.effective_start_date
               ,pee.effective_end_date, pee.element_entry_id
           FROM pay_element_entries_f pee, pay_element_links_f pel
          WHERE pee.element_entry_id = c_element_entry_id
            AND g_effective_date BETWEEN pee.effective_start_date
                                     AND pee.effective_end_date
            AND pel.element_link_id = pee.element_link_id
            AND g_effective_date BETWEEN pee.effective_start_date
                                     AND pee.effective_end_date;

      -- Cursor to fetch element entry value information
      CURSOR csr_get_ele_ent_val(c_element_entry_value_id NUMBER)
      IS
         SELECT input_value_id, screen_entry_value, element_entry_id
           FROM pay_element_entry_values_f
          WHERE element_entry_value_id = c_element_entry_value_id
            AND g_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

      -- Cursor to fetch min assignment effective start date
      -- for this employment category
      CURSOR csr_get_asg_start_date(c_employment_category VARCHAR2)
      IS
         SELECT MIN(effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id
            AND employment_category = c_employment_category;

      -- Cursor to check assignment details
      -- For Bug 5930973
      --------------------
      -- Cursor to check Emp termination details
      -- For Bug 6836466
     CURSOR csr_get_asg_details
      IS
           SELECT effective_end_date
             FROM per_all_assignments_f paaf,
                  per_periods_of_service pps,
                  per_assignment_status_types past
            WHERE paaf.assignment_id = p_assignment_id
              AND paaf.assignment_status_type_id = past.assignment_status_type_id
              and pps.person_id = paaf.person_id
              and pps.period_of_service_id = paaf.period_of_service_id
              AND past.per_system_status = 'ACTIVE_ASSIGN'
              and g_effective_date <> NVL(pps.final_process_date, hr_api.g_eot)
              AND g_effective_date BETWEEN paaf.effective_start_date
                                       AND paaf.effective_end_date
         ORDER BY paaf.effective_start_date;

    --For bug 7013325: Start here
     CURSOR csr_get_hire_date
     IS
     SELECT MIN(effective_start_date)
     FROM per_all_assignments_f
     WHERE assignment_id = p_assignment_id;
    --For bug 7013325: End here

     --For Bug 5998108
     --Cursor to fetch element type id's for assignment between
     --start of employment_category and pension element start date
     CURSOR csr_get_ele_type (asg_start_date DATE,ele_start_date DATE)
     IS
          SELECT element_type_id
          FROM pay_element_entries_f
          WHERE assignment_id = p_assignment_id
          AND effective_start_date BETWEEN asg_start_date
                                   AND (ele_start_date-1)
          ORDER BY effective_start_date;
    --For Bug 5998108


      l_proc_name                 VARCHAR2(80)
                                        := g_proc_name || 'eval_pension_event';
      l_proc_step                 PLS_INTEGER;
      l_rec_ele_ent_info          csr_get_ele_ent_info%ROWTYPE;
      l_rec_ele_ent_val           csr_get_ele_ent_val%ROWTYPE;
      l_return                    VARCHAR2(10);
      l_start_reason              pqp_configuration_values.pcv_information1%TYPE;
      l_ser_start_date            DATE;
      l_event_source              VARCHAR2(100);
      l_opt_out_date              DATE;
      l_asg_start_date            DATE;
      l_leaver_date               DATE;
      l_psi_emp_type              pqp_configuration_values.pcv_information1%TYPE;
      l_input_value_id            NUMBER;
      l_char                      pay_element_entry_values_f.screen_entry_value%TYPE;
      l_pension_category          pqp_configuration_values.pcv_information1%TYPE;
      l_partnership_scheme        VARCHAR2(30);
      i                           NUMBER;
      l_effective_end_date        DATE;
      l_next_effective_end_date   DATE;
   --For Bug 5998108
      Flag                        VARCHAR2(10):= 'N';
   --For bug 7013325: Start here
      l_hire_date                 DATE;
   --For bug 7013325: End here
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_table_name: ' || p_table_name);
         DEBUG('p_surrogate_key: ' || p_surrogate_key);
      END IF;

      l_return              := 'N';

      IF p_table_name = 'PAY_ELEMENT_ENTRIES_F'
      THEN
           IF g_debug
           THEN
                l_proc_step    := 20;
                DEBUG(l_proc_name, l_proc_step);
           END IF;

         -- Check whether this is an element entry we are interested
         -- in
           OPEN csr_get_ele_ent_info(p_surrogate_key);
           FETCH csr_get_ele_ent_info INTO l_rec_ele_ent_info;

           IF csr_get_ele_ent_info%NOTFOUND
           THEN
               -- May be a purge event
               IF g_tab_pay_proc_evnts(g_event_counter).update_type = 'P'
               THEN
                    --
                    NULL;
               END IF;
           ELSE -- row found
                IF g_tab_pay_proc_evnts(g_event_counter).update_type = 'I'
                   --Bug 9179022: Added update of EFFECTIVE_START_DATE as a valid event
                   OR (g_tab_pay_proc_evnts(g_event_counter).update_type = 'U'
                       AND
                       g_tab_pay_proc_evnts(g_event_counter).column_name = 'EFFECTIVE_START_DATE')
		THEN
                    -- This is an insert event
                    -- Check whether this element type id exists in the
                    -- pension element collection
                    IF g_debug
                    THEN
                        l_proc_step    := 30;
                        DEBUG(l_proc_name, l_proc_step);
                        DEBUG('l_rec_ele_ent_info.element_type_id : '
                              || l_rec_ele_ent_info.element_type_id);
                    END IF;

                    IF g_tab_pen_ele_ids.EXISTS(l_rec_ele_ent_info.element_type_id)
                       AND g_opt_in = 'Y'
                    THEN
                        -- Yes this is a pension element
                        -- We are interested in this event
                        -- Check whether the effective start date matches with
                        -- the assignment start date
                        -- Get the employment type
                        l_psi_emp_type    := get_psi_emp_type(p_employment_category
                                         => g_assignment_dtl.employment_category);

                        OPEN csr_get_asg_start_date(g_assignment_dtl.employment_category);
                        FETCH csr_get_asg_start_date INTO l_asg_start_date;
                        CLOSE csr_get_asg_start_date;

                        --For bug 7013325: Start here
                        OPEN csr_get_hire_date;
                        FETCH csr_get_hire_date INTO l_hire_date;
                        CLOSE csr_get_hire_date;
                        --For bug 7013325: End here

                        IF g_debug
                        THEN
                             l_proc_step    := 40;
                             DEBUG(l_proc_name, l_proc_step);
                             DEBUG('l_psi_emp_type: ' || l_psi_emp_type);
                             DEBUG('l_asg_start_date: '|| TO_CHAR(l_asg_start_date, 'DD/MON/YYYY'));
                             DEBUG('l_rec_ele_ent_info.effective_start_date: '
                                   || TO_CHAR(l_rec_ele_ent_info.effective_start_date,'DD/MON/YYYY'));
                        END IF;

                        IF l_psi_emp_type = 'CASUAL'
                        THEN

                        --For bug 7013325:Start
                        -- Check if the effective start date of the pension element
                        -- is equal to the change in asg_category
                        IF l_rec_ele_ent_info.effective_start_date = l_asg_start_date
                        THEN
                                --Check if asg_cate change date is equal to hire date
                          IF l_asg_start_date = l_hire_date
                        THEN
                                     --Report a New Joiner
                             l_start_reason      := 'N';
                                     l_event_source      := 'SER';
                                     l_ser_start_date    := l_rec_ele_ent_info.effective_start_date;
                                     l_return            := 'Y';

                        ELSE
                            --check if any pension element was attached to this assignmrnt before
                             For rec_get_ele_type in csr_get_ele_type(l_hire_date,l_rec_ele_ent_info.effective_start_date)
                                     Loop
                                          IF g_tab_pen_ele_ids.EXISTS(rec_get_ele_type.element_type_id)
                                          THEN
                                               Flag := 'Y';
                                               DEBUG('Flag = '||Flag);
                                               Exit;
                                          End IF;
                                     End Loop;

                                     IF Flag = 'Y'
                             THEN
                                          --For change in pension scheme
                                IF change_in_pension_scheme (p_assignment_id,
                                                                       l_rec_ele_ent_info.effective_start_date,
                                                             'OI',
                                                                       l_rec_ele_ent_info.element_type_id )
                                    THEN
                                               --Report a New Joiner
                                               l_start_reason      := 'N';
                                               l_event_source      := 'SER';
                                               l_ser_start_date    := l_rec_ele_ent_info.effective_start_date;
                                               l_return            := 'Y';

                                    ELSE

                                               l_start_reason      := 'OI';
                                               l_event_source      := 'PENSION';
                                               l_ser_start_date    :=
                                               l_rec_ele_ent_info.effective_start_date;
                                               l_return            := 'Y';
                                          END IF; -- END if of change_in_pension_scheme

                             ELSE
                                          --Report a New Joiner
                                  l_start_reason      := 'N';
                                          l_event_source      := 'SER';
                                          l_ser_start_date    := l_rec_ele_ent_info.effective_start_date;
                                          l_return            := 'Y';
                             END IF; --end of if Flag = 'Y'
                        END IF; --end of if  l_asg_start_date = l_hire_date
                        END IF; --end of if pension element start date = asg_cate change date
                        --For bug 7013325: End


                        -- Check whether the effective start date of the pension element
                            -- is 3 months later than the assignment start date
                            -- Remove the three month rule check for casuals
                            IF l_rec_ele_ent_info.effective_start_date > l_asg_start_date
                                             -- ADD_MONTHS(l_asg_start_date, 3)
                            THEN
                                 IF g_debug
                                 THEN
                                     l_proc_step    := 50;
                                     DEBUG(l_proc_name, l_proc_step);
                                 END IF;

                                --For Bug 5998108
                                --For bug 7013325: Changed variable passed to open cursor to l_hire_date
                                For rec_get_ele_type in csr_get_ele_type(l_hire_date,l_rec_ele_ent_info.effective_start_date)
                                Loop

                             IF g_tab_pen_ele_ids.EXISTS(rec_get_ele_type.element_type_id)
                                     THEN
                                          Flag := 'Y';
                                          DEBUG('Flag = '||Flag);
                                          Exit;
                                     End IF;

                        End Loop;

                          IF (Flag = 'N')
                          THEN
                               --Report New Joiner
                                     l_start_reason      := 'N';
                                     l_event_source      := 'SER';
                                     l_ser_start_date    := l_rec_ele_ent_info.effective_start_date;
                                     l_return            := 'Y';
                              ELSE
                                  --For Bug 5998108

                                --  change_in_pension_scheme is called before returning the value
                            -- to check same pension element is end dated and re-attached on following day
                              -- if yes then assingment should not report OPT IN event
                                   IF change_in_pension_scheme (p_assignment_id,
                                               l_rec_ele_ent_info.effective_start_date,
                                     'OI',
                                               l_rec_ele_ent_info.element_type_id ) -- Bug: 6524143
                               THEN
                                          l_return            := 'N';
                               ELSE

                                          l_start_reason      := 'OI';
                                          l_event_source      := 'PENSION';
                                          l_ser_start_date    :=
                                          l_rec_ele_ent_info.effective_start_date;
                                          l_return            := 'Y';
                                     END IF; -- END if of change_in_pension_scheme
                          END IF; --End of if Flag = N, For bug 5998108
                            END IF; -- End if of effective start date > 3 months check ...

                    ELSIF l_psi_emp_type in ('REGULAR','FIXED') --5897563 115.19
                        THEN

                       --For bug 7013325:Start
                         -- Check if the effective start date of the pension element
                         -- is equal to the change in asg_category
                         IF l_rec_ele_ent_info.effective_start_date = l_asg_start_date
                         THEN
                                  --Check if asg_cate change date is equal to hire date
                            IF l_asg_start_date = l_hire_date
                          THEN
                                      --Report a New Joiner
                              l_start_reason      := 'N';
                                      l_event_source      := 'SER';
                                      l_ser_start_date    := l_rec_ele_ent_info.effective_start_date;
                                      l_return            := 'Y';

                          ELSE
                              --check if any pension element was attached to this assignmrnt before
                              For rec_get_ele_type in csr_get_ele_type(l_hire_date,l_rec_ele_ent_info.effective_start_date)
                                      Loop
                                           IF g_tab_pen_ele_ids.EXISTS(rec_get_ele_type.element_type_id)
                                           THEN
                                                Flag := 'Y';
                                                DEBUG('Flag = '||Flag);
                                                Exit;
                                           End IF;
                                      End Loop;

                                      IF Flag = 'Y'
                              THEN
                                           --For change in pension scheme
                                 IF change_in_pension_scheme (p_assignment_id,
                                                                        l_rec_ele_ent_info.effective_start_date,
                                                              'OI',
                                                                        l_rec_ele_ent_info.element_type_id )
                                     THEN
                                                --Report a New Joiner
                                                l_start_reason      := 'N';
                                                l_event_source      := 'SER';
                                                l_ser_start_date    := l_rec_ele_ent_info.effective_start_date;
                                                l_return            := 'Y';

                                     ELSE

                                                l_start_reason      := 'OI';
                                                l_event_source      := 'PENSION';
                                                l_ser_start_date    :=
                                                            l_rec_ele_ent_info.effective_start_date;
                                                l_return            := 'Y';
                                           END IF; -- END if of change_in_pension_scheme

                                      ELSE
                                           --Report a New Joiner
                                   l_start_reason      := 'N';
                                           l_event_source      := 'SER';
                                           l_ser_start_date    := l_rec_ele_ent_info.effective_start_date;
                                           l_return            := 'Y';
                              END IF; --end of if Flag = 'Y'
                          END IF; --end of if  l_asg_start_date = l_hire_date
                         END IF; --end of if pension element start date = asg_cate change date
                        --For bug 7013325: End


                            -- Check whether the effective start date of the pension element
                            -- is NOT the same day as assignment start date
                            IF l_rec_ele_ent_info.effective_start_date > l_asg_start_date
                            THEN

                         IF g_debug
                                 THEN
                                      l_proc_step    := 60;
                                      DEBUG(l_proc_name, l_proc_step);
                                 END IF;

                        --  change_in_pension_scheme is called before returning the value
                              -- to check same pension element is end dated and re-attached on following day
                              -- if yes then assingment should not report OPT IN event
                            IF change_in_pension_scheme (p_assignment_id,
                                                             l_rec_ele_ent_info.effective_start_date,
                                                   'OI',
                                                 l_rec_ele_ent_info.element_type_id ) -- Bug: 6524143
                          THEN
                                      l_return            := 'N';
                          ELSE
                                      l_start_reason      := 'OI';
                                      l_event_source      := 'PENSION';
                                      l_ser_start_date    := l_rec_ele_ent_info.effective_start_date;
                            --For bug 7013325:Start
                              l_return            := 'Y';
                                END IF; -- END if of change_in_pension_scheme
                            END IF; -- End if of effective start date > asg start date check ...
                      --For bug 7013325: End

                            -- Get pension category
                            i   := g_tab_pen_sch_map_cv.FIRST;
                      WHILE i IS NOT NULL
                            LOOP
                                 IF fnd_number.canonical_to_number(g_tab_pen_sch_map_cv(i).pcv_information1) =
                                                                            l_rec_ele_ent_info.element_type_id
                                 THEN
                                      l_pension_category    :=
                                                g_tab_pen_sch_map_cv(i).pcv_information2;
                                      l_partnership_scheme :=g_tab_pen_sch_map_cv(i).pcv_information3;
                                 END IF;

                                 i    := g_tab_pen_sch_map_cv.NEXT(i);
                            END LOOP;

                         --For bug 7013325: Start
                          /*            l_return            := 'Y';
                                END IF; -- END if of change_in_pension_scheme
                            END IF; -- End if of effective start date > asg start date check ... */
                       --For bug 7013325: End

                  END IF; -- End if of employment tyep is casual check ...
                    END IF; -- Pension element exists check ...

         -- ELSIF g_tab_pay_proc_evnts(g_event_counter).update_type = 'U'
           ELSIF g_tab_pay_proc_evnts(g_event_counter).update_type
                                                 in ('U','E') --115.20 5930973
              THEN
               -- Date track update
               -- Check whether the effective end date of the element entry
               -- is not end of time
               -- Do this check only if this is a pension element and
               -- ensure that this is not because of a termination event
               IF g_debug
               THEN
                  l_proc_step    := 70;
                  DEBUG(l_proc_name, l_proc_step);
                  DEBUG(
                        'l_rec_ele_ent_info.effective_end_date: '
                     || TO_CHAR(
                           l_rec_ele_ent_info.effective_end_date
                          ,'DD/MON/YYYY'
                        )
                  );
               END IF;

                   IF g_tab_pen_ele_ids.EXISTS(l_rec_ele_ent_info.element_type_id)
                  AND g_opt_out = 'Y'
                  AND l_rec_ele_ent_info.effective_end_date <> hr_api.g_eot
                  AND l_rec_ele_ent_info.effective_end_date <=
                                     pqp_gb_psi_functions.g_effective_end_date
               THEN
                  -- Yes this is an end date event
                  IF g_debug
                  THEN
                     l_proc_step    := 80;
                     DEBUG(l_proc_name, l_proc_step);
                  END IF;

                  OPEN csr_get_asg_details;
                  FETCH csr_get_asg_details INTO l_effective_end_date;
                 -- FETCH csr_get_asg_details INTO l_next_effective_end_date;

                  IF    l_effective_end_date = hr_api.g_eot
                     OR csr_get_asg_details%FOUND
                  THEN
                     -- This is NOT due to a leaver event
                     -- might be an opt out event
                     -- double check by getting the opt out information
                     IF g_debug
                     THEN
                        l_proc_step    := 90;
                        DEBUG(l_proc_name, l_proc_step);
                     END IF;

                     l_input_value_id    :=
                        g_tab_pen_ele_ids(l_rec_ele_ent_info.element_type_id).input_value_id;

                     l_char              :=
                        get_screen_entry_value(
                           p_element_entry_id          => l_rec_ele_ent_info.element_entry_id
                          ,p_effective_start_date      => l_rec_ele_ent_info.effective_start_date
                          ,p_effective_end_date        => l_rec_ele_ent_info.effective_end_date
                          ,p_input_value_id            => l_input_value_id
                        );
                     l_opt_out_date      := fnd_date.canonical_to_date(l_char);

                     IF l_opt_out_date IS NULL
                     THEN
                        l_ser_start_date    :=
                                        l_rec_ele_ent_info.effective_end_date + 1;    -- For Bug 5930973
                     ELSE
                        l_ser_start_date    :=
                           LEAST(
                              l_opt_out_date
                             ,l_rec_ele_ent_info.effective_end_date + 1              -- For Bug 5930973
                           );
                     END IF; -- End if of opt out date is null check ...

            --  change_in_pension_scheme is called before returning the value
                -- to check same pension element is end dated and re-attached on following day
              -- if yes then assingment should not report OPT IN event
                 IF change_in_pension_scheme (p_assignment_id,
                                                  l_rec_ele_ent_info.effective_end_date,
                                            'OO',
                                      l_rec_ele_ent_info.element_type_id ) -- Bug: 6524143
                   THEN
                        l_return            := 'N';
                 ELSE

                     l_start_reason      := 'OO';
                     l_event_source      := 'PENSION';
                     -- Get pension category
                     i                   := g_tab_pen_sch_map_cv.FIRST;

                     WHILE i IS NOT NULL
                     LOOP
                        IF fnd_number.canonical_to_number(g_tab_pen_sch_map_cv(i).pcv_information1) =
                                           l_rec_ele_ent_info.element_type_id
                        THEN
                           l_pension_category    :=
                                     g_tab_pen_sch_map_cv(i).pcv_information2;
                           l_partnership_scheme :=
                                     g_tab_pen_sch_map_cv(i).pcv_information3;
                        END IF;

                        i    := g_tab_pen_sch_map_cv.NEXT(i);
                     END LOOP;

                     l_return            := 'Y';
                   END IF; --END if of change_in_pension_scheme
                  END IF; -- End if of asg details found check ...

                  CLOSE csr_get_asg_details;
               END IF; -- End if of opt out exists check ...
            END IF; -- End if of update_type check ...
         END IF; -- End if of row not found check ...

         CLOSE csr_get_ele_ent_info;
      ELSIF p_table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
      THEN
         IF g_debug
         THEN
            l_proc_step    := 100;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- Get the element entry value details
         -- to double check whether this is of pension element
         -- opt out date input value
         OPEN csr_get_ele_ent_val(p_surrogate_key);
         FETCH csr_get_ele_ent_val INTO l_rec_ele_ent_val;

         IF csr_get_ele_ent_val%FOUND
         THEN
            -- Get the element entry details
            IF g_debug
            THEN
               l_proc_step    := 110;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG(
                     'l_rec_ele_ent_val.element_entry_id: '
                  || l_rec_ele_ent_val.element_entry_id
               );
            END IF;

            OPEN csr_get_ele_ent_info(l_rec_ele_ent_val.element_entry_id);
            FETCH csr_get_ele_ent_info INTO l_rec_ele_ent_info;

            IF csr_get_ele_ent_info%FOUND
            THEN
               -- Check whether this is a pension element
               IF g_debug
               THEN
                  l_proc_step    := 120;
                  DEBUG(l_proc_name, l_proc_step);
                  DEBUG(
                        'l_rec_ele_ent_info.element_type_id: '
                     || l_rec_ele_ent_info.element_type_id
                  );
               END IF;

               IF     g_tab_pen_ele_ids.EXISTS(l_rec_ele_ent_info.element_type_id)
                  AND g_opt_out = 'Y'
               THEN
                  IF g_debug
                  THEN
                     l_proc_step    := 130;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG(
                           'l_rec_ele_ent_val.input_value_id: '
                        || l_rec_ele_ent_val.input_value_id
                     );
                     DEBUG(
                           'l_rec_ele_ent_val.screen_entry_value: '
                        || l_rec_ele_ent_val.screen_entry_value
                     );
                  END IF;

                  IF g_tab_pen_ele_ids(l_rec_ele_ent_info.element_type_id).input_value_id =
                                              l_rec_ele_ent_val.input_value_id
                  THEN
                     -- Yes this is the opt out date input value
                     IF g_debug
                     THEN
                        l_proc_step    := 140;
                        DEBUG(l_proc_name, l_proc_step);
                     END IF;

                     l_opt_out_date    :=
                        fnd_date.canonical_to_date(l_rec_ele_ent_val.screen_entry_value);

                     IF     l_opt_out_date IS NOT NULL
                        AND l_opt_out_date <=
                                     pqp_gb_psi_functions.g_effective_end_date
                     THEN
                        l_ser_start_date    :=
                           LEAST(
                              l_opt_out_date
                             ,l_rec_ele_ent_info.effective_end_date
                           );
                        l_event_source      := 'PENSION';
                        l_start_reason      := 'OO';
                        -- Get pension category
                        i                   := g_tab_pen_sch_map_cv.FIRST;

                        WHILE i IS NOT NULL
                        LOOP
                           IF fnd_number.canonical_to_number(g_tab_pen_sch_map_cv(i).pcv_information1) =
                                           l_rec_ele_ent_info.element_type_id
                           THEN
                              l_pension_category    :=
                                     g_tab_pen_sch_map_cv(i).pcv_information2;
                              l_partnership_scheme :=
                                     g_tab_pen_sch_map_cv(i).pcv_information3;
                           END IF;

                           i    := g_tab_pen_sch_map_cv.NEXT(i);
                        END LOOP;

                        l_return            := 'Y';
                     END IF; -- End if of opt out date is not null check ...
                  END IF; -- End if of input value check ...
               END IF; -- End if of pension element check ...
            END IF; -- End if of ele entry row found check ..

            CLOSE csr_get_ele_ent_info;
         END IF; -- End if of ele entry value row found check ...

         CLOSE csr_get_ele_ent_val;
      END IF; -- End if of table name check ...

      p_start_reason        := l_start_reason;
      p_ser_start_date      := l_ser_start_date;
      p_event_source        := l_event_source;
      p_pension_category    := l_pension_category;
      p_partnership_scheme  := l_partnership_scheme;

      IF g_debug
      THEN
         l_proc_step    := 150;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('p_start_reason: ' || l_start_reason);
         DEBUG('p_ser_start_date: '
            || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY'));
         DEBUG('p_event_source: ' || l_event_source);
         DEBUG('p_pension_category: ' || l_pension_category);
         DEBUG('-_partnership_scheme: '||l_partnership_scheme);
         DEBUG('l_return: ' || l_return);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_return;
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
   END eval_pension_event;

-- This procedure is used to check whether assignment
-- qualifies for service history periodic changes
-- ----------------------------------------------------------------------------
-- |---------------------< chk_ser_periodic_criteria >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_ser_periodic_criteria(p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS
      --
      -- Cursor to fetch min assignment effective start date
      -- for this employment category
      CURSOR csr_get_asg_start_date(c_employment_category VARCHAR2)
      IS
         SELECT MIN(effective_start_date)
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id
            AND employment_category = c_employment_category;

      -- Cursor to fetch termination details
      --115.21 5945283  CURSOR csr_get_ser_details modified

          CURSOR csr_get_ser_details IS --in 115.21 5945283
          SELECT leaving_reason, actual_termination_date,final_process_date
           FROM  per_all_assignments_f paf,
                 per_periods_of_service pos
          WHERE  paf.assignment_id=p_assignment_id
            AND  paf.period_of_service_id = pos.period_of_service_id;
             --date join not required as all rows will have same data.

      -- Cursor to fetch leaving reason for non period of service
      -- events
      CURSOR csr_get_leaving_reason(c_person_id      NUMBER
                                   ,c_effective_date DATE)
      IS
         SELECT pps.leaving_reason, pps.actual_termination_date
           FROM per_periods_of_service pps
          WHERE pps.person_id = c_person_id
            AND pps.date_start = (SELECT MAX(date_start)
                                FROM per_periods_of_service pps1
                               WHERE pps1.person_id = c_person_id
                                 AND pps1.date_start <= c_effective_date);

    --For bug 7013325:Start
    --Cursor to fetch elements attached on asg_category change date
      CURSOR cur_get_asg_chg_dt_ele(c_asg_cate_chng_date DATE)
      IS
        SELECT element_type_id, element_entry_id
        FROM pay_element_entries_f
        WHERE assignment_id = p_assignment_id
        AND effective_start_date = c_asg_cate_chng_date;

   --Cursor to check if the event on Element Entries is an Insert or Update
     CURSOR cur_get_ele_entry_id(c_element_entry_id NUMBER, c_asg_cate_chng_date DATE)
     IS
       SELECT element_entry_id
       FROM pay_element_entries_f
       WHERE assignment_id = p_assignment_id
       AND element_entry_id = c_element_entry_id
       AND effective_end_date = c_asg_cate_chng_date -1;
    --For bug 7013325: End

      l_proc_name                 VARCHAR2(80)
                                 := g_proc_name || 'chk_ser_periodic_criteria';
      l_proc_step                 PLS_INTEGER;
      l_include_flag              VARCHAR2(10);
      i                           NUMBER;
      l_tab_pay_proc_evnts        ben_ext_person.t_detailed_output_table;
      l_latest_start_date         DATE;
      l_rec_asg_details           r_asg_details;
      l_ser_start_date            DATE;
      l_start_reason              VARCHAR2(10);
      l_event_source              VARCHAR2(20);
      l_asg_start_date            DATE;
      l_psi_code                  VARCHAR2(10);
      l_psi_emp_type              pqp_configuration_values.pcv_information1%TYPE;
      l_absence_type_id           NUMBER;
      l_pension_category          pqp_configuration_values.pcv_information1%TYPE;
      l_rec_ele_ent_details       r_ele_ent_details;
      l_asg_status_type_id        NUMBER;
      l_event_group_id            NUMBER;
      l_event_group_name          pay_event_groups.event_group_name%TYPE;
      l_absence_attendance_id     NUMBER;
      l_assignment_id             NUMBER;
      l_rec_ser_details           csr_get_ser_details%ROWTYPE;
      l_dated_table_id            NUMBER;
      l_table_name                pay_dated_tables.table_name%TYPE;
 --115.21     l_period_of_service_id      NUMBER;
      l_curr_status_type_id       NUMBER;
      l_prev_status_type_id       NUMBER;
      l_return                    VARCHAR2(10);
      l_leaver_date               DATE;
      l_surrogate_key             NUMBER;
      l_gap_duration_summary_id   NUMBER;
      l_process_flag              VARCHAR2(10);
      l_value                     NUMBER;
      l_index                     NUMBER;
      l_rec_leaving_reason        csr_get_leaving_reason%ROWTYPE;
      l_partnership_scheme        VARCHAR2(30);
    --For bug 7013325:Start
      l_element_entry_id          NUMBER := NULL;
      l_flag                      VARCHAR2(10):= 'N';
    --For bug 7013325:End

    --For Bug 7034476: Added new variable
      l_column_name                VARCHAR2(40);

   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_include_flag          := 'N';
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
            DEBUG(
                  'g_prev_pay_proc_evnts.dated_table_id: '
               || g_prev_pay_proc_evnts.dated_table_id
            );
         END IF;

         IF g_prev_pay_proc_evnts.dated_table_id IS NOT NULL
         THEN
            --
            IF    l_tab_pay_proc_evnts(g_event_counter).dated_table_id <>
                                         g_prev_pay_proc_evnts.dated_table_id
               OR l_tab_pay_proc_evnts(g_event_counter).datetracked_event <>
                                       g_prev_pay_proc_evnts.datetracked_event
               OR l_tab_pay_proc_evnts(g_event_counter).update_type <>
                                             g_prev_pay_proc_evnts.update_type
               OR l_tab_pay_proc_evnts(g_event_counter).surrogate_key <>
                                           g_prev_pay_proc_evnts.surrogate_key
               OR l_tab_pay_proc_evnts(g_event_counter).column_name <>
                                             g_prev_pay_proc_evnts.column_name
               OR l_tab_pay_proc_evnts(g_event_counter).effective_date <>
                                          g_prev_pay_proc_evnts.effective_date
               OR l_tab_pay_proc_evnts(g_event_counter).old_value <>
                                               g_prev_pay_proc_evnts.old_value
               OR l_tab_pay_proc_evnts(g_event_counter).new_value <>
                                               g_prev_pay_proc_evnts.new_value
               OR l_tab_pay_proc_evnts(g_event_counter).change_values <>
                                           g_prev_pay_proc_evnts.change_values
               OR l_tab_pay_proc_evnts(g_event_counter).proration_type <>
                                          g_prev_pay_proc_evnts.proration_type
               OR l_tab_pay_proc_evnts(g_event_counter).event_group_id <>
                                          g_prev_pay_proc_evnts.event_group_id
               OR l_tab_pay_proc_evnts(g_event_counter).actual_date <>
                                             g_prev_pay_proc_evnts.actual_date
            THEN
               l_process_flag    := 'Y';
            ELSE
               l_process_flag    := 'N';
            END IF;
         ELSE
            l_process_flag    := 'Y';
         END IF; -- End if of dated table id not null check ...

         IF g_debug
         THEN
            DEBUG('l_process_flag: ' || l_process_flag);
         END IF;

         g_prev_pay_proc_evnts    := l_tab_pay_proc_evnts(g_event_counter);
         g_tab_pay_proc_evnts     := l_tab_pay_proc_evnts;
         -- Check whether we are interested in this event
         l_event_group_id         :=
                          l_tab_pay_proc_evnts(g_event_counter).event_group_id;

         IF g_tab_event_group.EXISTS(l_event_group_id)
            AND l_process_flag = 'Y'
         THEN
            IF g_debug
            THEN
               l_proc_step    := 35;
               DEBUG(l_proc_name, l_proc_step);
            END IF;

            l_return    :=
               pqp_gb_psi_functions.include_event(
                  p_actual_date         => l_tab_pay_proc_evnts(g_event_counter).actual_date
                 ,p_effective_date      => l_tab_pay_proc_evnts(g_event_counter).effective_date
               );

            IF g_debug
            THEN
               l_proc_step    := 36;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_return: ' || l_return);
            END IF;

            IF l_return = 'Y'
            THEN
               -- We are interested in this event
               -- We will need pl/sql event qualifiers for assignment status and
               -- absence types
               -- Check for absence types first
               l_dated_table_id      :=
                         l_tab_pay_proc_evnts(g_event_counter).dated_table_id;

             --For Bug 7034476: Start
                 l_column_name   :=
                        l_tab_pay_proc_evnts(g_event_counter).column_name;
             --For Bug 7034476: End

               l_table_name          :=
                               g_tab_dated_table(l_dated_table_id).table_name;
               l_event_group_name    :=
                         g_tab_event_group(l_event_group_id).event_group_name;

               IF g_debug
               THEN
                  l_proc_step    := 40;
                  DEBUG(l_proc_name, l_proc_step);
                  DEBUG('l_event_group_name: ' || l_event_group_name);
                  DEBUG('l_dated_table_id: ' || l_dated_table_id);
                  DEBUG('l_table_name: ' || l_table_name);
               END IF;

--     PQP_GB_PSI_SER_ABSENCES
--     PQP_GB_PSI_ASSIGNMENT_STATUS
--     PQP_GB_PSI_SER_LEAVER
--     PQP_GB_PSI_SER_PENSIONS
--     PQP_GB_PSI_NEW_HIRE
--     PQP_GB_PSI_NI_NUMBER
--     PQP_GB_PSI_ASSIGNMENT_NUMBER
--     PQP_GB_PSI_SER_NEW_ABSENCES
--     PQP_GB_PSI_EMP_TERMINATIONS
--     PQP_GB_PSI_SER_GAP_TRANSITION

               -- Check whether event group relates to Absences

               IF    l_event_group_name = 'PQP_GB_PSI_SER_ABSENCES'
                  OR l_event_group_name = 'PQP_GB_PSI_SER_NEW_ABSENCES'
               THEN
                  -- This should be an absence event
                  -- Evaluate absences

                 --For Bug 7034476: Start
                   IF l_table_name = 'PER_ABSENCE_ATTENDANCES'
                   THEN
                 --For Bug 7034476: End

                        l_absence_attendance_id    :=
                           fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).surrogate_key);

                        IF g_debug
                        THEN
                              l_proc_step    := 50;
                              DEBUG(l_proc_name, l_proc_step);
                              DEBUG('l_absence_attendance_id: ' || l_absence_attendance_id);
                        END IF;

                        l_include_flag := eval_absence_event(
                          p_assignment_id              => p_assignment_id
                         ,p_absence_attendance_id      => l_absence_attendance_id
                         ,p_event_group_name           => l_event_group_name
                         ,p_absence_type_id            => l_absence_type_id
                         ,p_start_reason               => l_start_reason
                         ,p_ser_start_date             => l_ser_start_date
                         ,p_event_source               => l_event_source
                          );

                 --For Bug 7034476: Start
                   ELSIF l_table_name = 'PQP_GAP_DURATION_SUMMARY'
                      THEN
                           -- This should be a sickness/maternity transition
                           l_gap_duration_summary_id    :=
                              fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).surrogate_key);

                           IF g_debug
                           THEN
                                l_proc_step    := 60;
                                DEBUG(l_proc_name, l_proc_step);
                                DEBUG('l_gap_duration_summary_id: '
                                       || l_gap_duration_summary_id);
                           END IF;

                           l_include_flag := eval_gap_transition_event
                            (p_assignment_id                => p_assignment_id
                            ,p_gap_duration_summary_id      => l_gap_duration_summary_id
                            ,p_absence_type_id              => l_absence_type_id
                            ,p_start_reason                 => l_start_reason
                            ,p_ser_start_date               => l_ser_start_date
                            ,p_event_source                 => l_event_source
                            );
                      END IF; --End of table name chk
              /*
               ELSIF l_event_group_name = 'PQP_GB_PSI_SER_GAP_TRANSITION'
               THEN
                  -- This should be a sickness/maternity transition
                  l_gap_duration_summary_id    :=
                     fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).surrogate_key);

                  IF g_debug
                  THEN
                     l_proc_step    := 60;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG(
                           'l_gap_duration_summary_id: '
                        || l_gap_duration_summary_id
                     );
                  END IF;

                  l_include_flag               :=
                     eval_gap_transition_event(
                        p_assignment_id                => p_assignment_id
                       ,p_gap_duration_summary_id      => l_gap_duration_summary_id
                       ,p_absence_type_id              => l_absence_type_id
                       ,p_start_reason                 => l_start_reason
                       ,p_ser_start_date               => l_ser_start_date
                       ,p_event_source                 => l_event_source
                     );
                   */
                 --For Bug 7034476: End


    --For Bug 5998108
             ELSIF ((l_event_group_name = 'PQP_GB_PSI_NEW_HIRE')OR(l_event_group_name = 'PQP_GB_PSI_ASG_CATEGORY'))
               THEN
                  -- This is a new hire event (includes rehires)
                  -- Evaluate new joiners
                  -- We are only interested in primary assignments
                  l_assignment_id    :=
                     fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).surrogate_key);

                  IF g_debug
                  THEN
                     l_proc_step    := 60;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG('l_assignment_id: ' || l_assignment_id);
                  END IF;

                  IF l_assignment_id = p_assignment_id
                  THEN
                  --For bug 7013325:Start
                  --Exclude case from here
                      IF l_event_group_name = 'PQP_GB_PSI_ASG_CATEGORY'
                      THEN

                           DEBUG('l_tab_pay_proc_evnts(g_event_counter).effective_date = '||l_tab_pay_proc_evnts(g_event_counter).effective_date);

                           For rec_get_asg_chg_dt_ele in cur_get_asg_chg_dt_ele(l_tab_pay_proc_evnts(g_event_counter).effective_date)
                           Loop
                               IF g_tab_pen_ele_ids.EXISTS(rec_get_asg_chg_dt_ele.element_type_id)
                               THEN

                                    DEBUG('rec_get_asg_chg_dt_ele.element_type_id = '||rec_get_asg_chg_dt_ele.element_type_id);

                                    OPEN cur_get_ele_entry_id(rec_get_asg_chg_dt_ele.element_entry_id, l_tab_pay_proc_evnts(g_event_counter).effective_date);
                                    FETCH cur_get_ele_entry_id INTO l_element_entry_id;
                                    CLOSE cur_get_ele_entry_id;

                                    IF l_element_entry_id IS NULL
                                      THEN
                                      l_flag := 'Y';
                                      DEBUG('l_flag = '||l_flag);
                                        Exit;
                                    END IF;
                               End IF;
                           End Loop;
                      END IF;--End of if event group is ASG_CATEGORY

                      IF l_flag = 'N'
                      THEN
                           l_include_flag      := 'Y';
                           l_ser_start_date    :=
                           l_tab_pay_proc_evnts(g_event_counter).effective_date;
                           l_start_reason      := 'N'; -- New Joiner
                           l_event_source      := 'SER';
                      END IF;

                    /* l_include_flag      := 'Y';
                     l_ser_start_date    :=
                         l_tab_pay_proc_evnts(g_event_counter).effective_date;
                     l_start_reason      := 'N'; -- New Joiner
                     l_event_source      := 'SER'; */
               --For bug 7013325:End

                  END IF; -- Primary assignment check ...
               ELSIF l_event_group_name = 'PQP_GB_PSI_SER_LEAVER'
               THEN
                  -- This is a leaver event
                  -- Ensure that the assignment status represents
                  -- Termination as of the event date
                  IF l_table_name = 'PER_PERIODS_OF_SERVICE'
                  THEN
                    --115.21 5945283
                      /* l_period_of_service_id    :=
                        fnd_number.canonical_to_number(
                           l_tab_pay_proc_evnts(g_event_counter).surrogate_key
                        );*/

                     IF g_debug
                     THEN
                        l_proc_step    := 70;
                        DEBUG(l_proc_name, l_proc_step);
                     END IF;

                     OPEN csr_get_ser_details;
                     FETCH csr_get_ser_details INTO l_rec_ser_details;
                     CLOSE csr_get_ser_details;

                     IF     l_rec_ser_details.actual_termination_date IS NOT NULL
                        AND l_rec_ser_details.actual_termination_date <=
                                     pqp_gb_psi_functions.g_effective_end_date
                     THEN
                        IF g_debug
                        THEN
                           DEBUG(
                                 'l_rec_ser_details.actual_termination_date'
                              || TO_CHAR(
                                    l_rec_ser_details.actual_termination_date
                                   ,'DD/MON/YYYY'
                                 )
                           );
                        END IF;

                        get_asg_details(
                           p_assignment_id        => p_assignment_id
                          ,p_effective_date       =>   l_rec_ser_details.actual_termination_date
                                                     + 1
                          ,p_rec_asg_details      => l_rec_asg_details
                        );
                        l_asg_status_type_id    :=
                                   l_rec_asg_details.assignment_status_type_id;

                        -- We are only interested if the status is termination
                        IF l_asg_status_type_id = g_terminate_asg_sts_id
                        THEN
                           l_include_flag      := 'Y';
                           l_ser_start_date    :=
                                    l_rec_ser_details.actual_termination_date;
                           l_start_reason      := 'ZZ'; -- Leaver
                           l_event_source      := 'ASG';

                           -- Get the penserver leaving reason code
                           -- for this termination event
                           IF l_rec_ser_details.leaving_reason IS NOT NULL
                           THEN

                              IF g_debug
                              THEN
                                l_proc_step := 75;
                                DEBUG(l_proc_name, l_proc_step);
                                DEBUG('l_rec_ser_details.leaving_reason: '
                                   || l_rec_ser_details.leaving_reason
                                );
                              END IF;

                              l_index := NULL;
                              l_return :=
                                chk_lvrsn_in_collection
                                  (p_leave_reason => l_rec_ser_details.leaving_reason
                                  ,p_index        => l_index
                                  );
                              IF l_return = 'Y' THEN
                                IF g_debug
                                THEN
                                  DEBUG('g_tab_lvrsn_map_cv(l_index).pcv_information2: '
                                    ||  g_tab_lvrsn_map_cv(l_index).pcv_information2
                                  );
                                END IF;
                                g_leaving_reason := g_tab_lvrsn_map_cv(l_index).pcv_information2;
                              END IF; -- End if of l_index is not null check ...
                           ELSE
                              -- Raise data error
                              IF g_debug
                              THEN
                                DEBUG('Raise Data Error: Leaving Reason Missing');
                              END IF;

                              l_value    :=
                                       pqp_gb_psi_functions.raise_extract_error(
                                         p_error_number      => 94479
                                        ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                                        ,p_token1            => 'Leaving Reason'
                                        );

                           END IF; -- End if of leaving reason is not null check ...
                        END IF; -- Check for assignment status is termination
                     END IF; -- Check whether actual termination date is not null ...
                  ELSIF l_table_name = 'PER_ALL_ASSIGNMENTS_F'
                  THEN
                     -- This is an assignment status change

                     --For Bug 7034476:Start
                       IF l_column_name = 'ASSIGNMENT_STATUS_TYPE_ID'
                       THEN
                     --For Bug 7034476: End

                             IF g_debug
                             THEN
                                  l_proc_step    := 76;
                                  DEBUG(l_proc_name, l_proc_step);
                                  DEBUG('g_assignment_dtl.assignment_status_type_id: '
                                        || g_assignment_dtl.assignment_status_type_id);
                             END IF;

                             IF g_terminate_asg_sts_id =
                                    g_assignment_dtl.assignment_status_type_id
                             THEN -- confirmed termination

                          --Added for bug 7608779: Start
                          --this is to make sure that termination is reported only
                          --once.
                                  OPEN  csr_get_ser_details;
                                  FETCH csr_get_ser_details INTO l_rec_ser_details;
                                  CLOSE csr_get_ser_details;

                                  DEBUG('l_tab_pay_proc_evnts(g_event_counter).effective_date: '
                                        ||l_tab_pay_proc_evnts(g_event_counter).effective_date);
                                  DEBUG('l_rec_ser_details.actual_termination_date: '
                                        ||l_rec_ser_details.actual_termination_date);

                                  IF (l_tab_pay_proc_evnts(g_event_counter).effective_date - 1)
                                      = l_rec_ser_details.actual_termination_date
                                  THEN
                                       l_include_flag      := 'Y';
                                       l_ser_start_date    :=
                                                l_tab_pay_proc_evnts(g_event_counter).effective_date - 1;
                                       l_start_reason      := 'ZZ'; -- Leaver
                                       l_event_source      := 'ASG';
                                  END IF;

                           --For Bug 7034476:Start
                             ELSE
                                  IF g_debug
                                  THEN
                                       l_proc_step    := 90;
                                       DEBUG(l_proc_name, l_proc_step);
                                  END IF;

                                  l_curr_status_type_id    :=
                                      fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).new_value);
                                  l_prev_status_type_id    :=
                                      fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).old_value);
                                  l_include_flag   := eval_asg_status_event(
                                      p_assignment_id            => p_assignment_id
                                     ,p_curr_status_type_id      => l_curr_status_type_id
                                     ,p_prev_status_type_id      => l_prev_status_type_id
                                     ,p_start_reason             => l_start_reason
                                     ,p_event_source             => l_event_source
                                     );

                                  IF l_include_flag = 'Y'
                                  THEN
                                       l_ser_start_date    :=
                                            l_tab_pay_proc_evnts(g_event_counter).effective_date;
                                  END IF;
                           --For Bug 7034476: End

                             END IF; -- termination status check ...

                     --For Bug 7034476:Start
                       ELSE
                           --115.21 5945283
                             OPEN  csr_get_ser_details;
                             FETCH csr_get_ser_details INTO l_rec_ser_details;
                             CLOSE csr_get_ser_details;

                             IF g_debug
                             THEN
                                  l_proc_step    := 80;
                                  DEBUG(l_proc_name, l_proc_step);
                                  DEBUG('Final Process Date: '
                                        ||l_rec_ser_details.final_process_date);
                                  DEBUG('Actual Termination Date: '
                                        ||l_rec_ser_details.actual_termination_date);
                             END IF;

                             IF l_rec_ser_details.final_process_date=
                                 l_rec_ser_details.actual_termination_date
                             THEN
                                --report leaver event only if fpd is same as atd
                                  IF pqp_gb_psi_functions.chk_is_employee_a_leaver(
                                        p_assignment_id       => p_assignment_id
                                        ,p_effective_date      => g_effective_date
                                        ,p_leaver_date         => l_leaver_date
                                        ) = 'Y'
                                  THEN
                                        l_include_flag      := 'Y';
                                        l_ser_start_date    := l_leaver_date;
                                        l_start_reason      := 'ZZ'; -- Leaver
                                        l_event_source      := 'ASG';
                                  END IF; -- employee a leaver check ...
                             END IF;---report leaver event only if fpd is same as atd
                       END IF; --end of if l_column_name = 'ASSIGNMENT_STATUS_TYPE_ID'
                    --For Bug 7034476: End

                  END IF; -- End if of table name is periods of service ...

             --For Bug 7034476: Removed code for event group
             --PQP_GB_PSI_EMP_TERMINATIONS and PQP_GB_PSI_ASSIGNMENT_STATUS
               /*
               ELSIF l_event_group_name = 'PQP_GB_PSI_EMP_TERMINATIONS'
               THEN -- Terminations

                 --115.21 5945283
                  OPEN  csr_get_ser_details;
                  FETCH csr_get_ser_details INTO l_rec_ser_details;
                  CLOSE csr_get_ser_details;

                  IF g_debug
                  THEN
                     l_proc_step    := 80;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG('Final Process Date: '
                           ||l_rec_ser_details.final_process_date);
                     DEBUG('Actual Termination Date: '
                           ||l_rec_ser_details.actual_termination_date);
                  END IF;


                  IF l_rec_ser_details.final_process_date=
                     l_rec_ser_details.actual_termination_date THEN
                      --report leaver event only if fpd is same as atd
                      IF pqp_gb_psi_functions.chk_is_employee_a_leaver(
                         p_assignment_id       => p_assignment_id
                        ,p_effective_date      => g_effective_date
                        ,p_leaver_date         => l_leaver_date
                      ) = 'Y'
                   THEN
                      l_include_flag      := 'Y';
                      l_ser_start_date    := l_leaver_date;
                      l_start_reason      := 'ZZ'; -- Leaver
                      l_event_source      := 'ASG';
                   END IF; -- employee a leaver check ...
                 END IF;---report leaver event only if fpd is same as atd

              ELSIF l_event_group_name = 'PQP_GB_PSI_ASSIGNMENT_STATUS'
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
                  l_include_flag           :=
                     eval_asg_status_event(
                        p_assignment_id            => p_assignment_id
                       ,p_curr_status_type_id      => l_curr_status_type_id
                       ,p_prev_status_type_id      => l_prev_status_type_id
                       ,p_start_reason             => l_start_reason
                       ,p_event_source             => l_event_source
                     );

                  IF l_include_flag = 'Y'
                  THEN
                     l_ser_start_date    :=
                         l_tab_pay_proc_evnts(g_event_counter).effective_date;
                  END IF;
                 */

               ELSIF l_event_group_name = 'PQP_GB_PSI_SER_PENSIONS'
               THEN
                  IF g_debug
                  THEN
                     l_proc_step    := 100;
                     DEBUG(l_proc_name, l_proc_step);
                  END IF;

                  l_surrogate_key    :=
                     fnd_number.canonical_to_number(l_tab_pay_proc_evnts(g_event_counter).surrogate_key);
                  l_include_flag     :=
                     eval_pension_event(
                        p_assignment_id         => p_assignment_id
                       ,p_table_name            => l_table_name
                       ,p_surrogate_key         => l_surrogate_key
                       ,p_ser_start_date        => l_ser_start_date
                       ,p_start_reason          => l_start_reason
                       ,p_event_source          => l_event_source
                       ,p_pension_category      => l_pension_category
                       ,p_partnership_scheme    => l_partnership_scheme
                     );
               END IF; -- Event group name check ...
            END IF; -- End if of l_return = 'Y' check ...
         END IF; -- event group exists check ...
      END IF; -- Event collection count > 0 check ...

      IF l_include_flag = 'Y'
      THEN
         IF g_debug
         THEN
            l_proc_step    := 110;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- Get assignment details as of the event effective date
         IF g_assignment_dtl.assignment_id IS NULL
         THEN
            get_asg_details(
               p_assignment_id        => p_assignment_id
              ,p_effective_date       => l_ser_start_date
              ,p_rec_asg_details      => l_rec_asg_details
            );
         ELSE
            l_rec_asg_details.person_id                    :=
                                                   g_assignment_dtl.person_id;
            l_rec_asg_details.effective_start_date         :=
                                        g_assignment_dtl.effective_start_date;
            l_rec_asg_details.effective_end_date           :=
                                          g_assignment_dtl.effective_end_date;
            l_rec_asg_details.assignment_number            :=
                                           g_assignment_dtl.assignment_number;
            l_rec_asg_details.primary_flag                 :=
                                                g_assignment_dtl.primary_flag;
            l_rec_asg_details.normal_hours                 :=
                                                g_assignment_dtl.normal_hours;
            l_rec_asg_details.assignment_status_type_id    :=
                                   g_assignment_dtl.assignment_status_type_id;
            l_rec_asg_details.employment_category          :=
                                         g_assignment_dtl.employment_category;
         END IF; -- assignment dtl global record is null check ...

         IF g_debug
         THEN
            l_proc_step    := 120;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('Person ID: ' || l_rec_asg_details.person_id);
            DEBUG(
                  'Effective Start Date: '
               || TO_CHAR(l_rec_asg_details.effective_start_date
                    ,'DD/MON/YYYY')
            );
            DEBUG(
                  'Effective End Date: '
               || TO_CHAR(l_rec_asg_details.effective_end_date, 'DD/MON/YYYY')
            );
            DEBUG('Assignment Number: ' || l_rec_asg_details.assignment_number);
            DEBUG('Primary Flag: ' || l_rec_asg_details.primary_flag);
            DEBUG('Normal Hours: ' || l_rec_asg_details.normal_hours);
            DEBUG(
                  'Assignment Status Type ID: '
               || l_rec_asg_details.assignment_status_type_id
            );
            DEBUG(
               'Assignment Category: '
               || l_rec_asg_details.employment_category
            );
         END IF;

         -- Assign latest start date as the service date to start with
         l_latest_start_date    :=
            get_per_latest_start_date(
               p_person_id           => l_rec_asg_details.person_id
              ,p_effective_date      => l_rec_asg_details.effective_start_date
            );

         IF g_debug
         THEN
            l_proc_step    := 130;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG(
                  'l_latest_start_date: '
               || TO_CHAR(l_latest_start_date, 'DD/MON/YYYY')
            );
         END IF;

         -- Get the earliest assignment effective start date when this
         -- person became eligible to be reported
         OPEN csr_get_asg_start_date(l_rec_asg_details.employment_category);
         FETCH csr_get_asg_start_date INTO l_asg_start_date;
         CLOSE csr_get_asg_start_date;

         IF l_latest_start_date < l_asg_start_date
         THEN
            l_latest_start_date    := l_asg_start_date;
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 140;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_start_reason: ' || l_start_reason);
            DEBUG('l_event_source: ' || l_event_source);
            DEBUG(
                  'l_latest_start_date: '
               || TO_CHAR(l_latest_start_date, 'DD/MON/YYYY')
            );
            DEBUG(
               'l_asg_start_date: '
               || TO_CHAR(l_asg_start_date, 'DD/MON/YYYY')
            );
            DEBUG(
               'l_ser_start_date: '
               || TO_CHAR(l_ser_start_date, 'DD/MON/YYYY')
            );
            DEBUG('l_event_source: ' || l_event_source);
         END IF;

         IF l_pension_category IS NULL
         THEN
            l_pension_category    :=
               get_pen_scheme_memb(
                  p_assignment_id            => p_assignment_id
                 ,p_effective_date           => l_ser_start_date
                 ,p_tab_pen_sch_map_cv       => g_tab_pen_sch_map_cv
                 ,p_rec_ele_ent_details      => l_rec_ele_ent_details
                 ,p_partnership_scheme       => l_partnership_scheme
               );
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 150;
            DEBUG('l_pension_category: ' || l_pension_category);
            DEBUG('l_partnership_scheme: '||l_partnership_scheme);
         END IF;

         l_psi_emp_type         :=
            get_psi_emp_type(p_employment_category => l_rec_asg_details.employment_category);

         IF g_debug
         THEN
            l_proc_step    := 160;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_psi_emp_type: ' || l_psi_emp_type);
         END IF;

         g_ser_start_date       := l_ser_start_date;

         IF l_start_reason = 'ZZ' AND
            g_leaving_reason IS NULL
         THEN
            -- Get the leaving reason code
            IF g_debug
            THEN
              l_proc_step := 165;
              DEBUG(l_proc_name, l_proc_step);
            END IF;
            OPEN csr_get_leaving_reason(l_rec_asg_details.person_id
                                       ,l_ser_start_date);
            FETCH csr_get_leaving_reason INTO l_rec_leaving_reason;
            CLOSE csr_get_leaving_reason;

            -- Get the penserver leaving reason code
            -- for this termination event
            IF l_rec_leaving_reason.leaving_reason IS NOT NULL
            THEN

               IF g_debug
               THEN
                 l_proc_step := 166;
                 DEBUG(l_proc_name, l_proc_step);
                 DEBUG('l_rec_leaving_reason.leaving_reason: '
                    || l_rec_leaving_reason.leaving_reason
                 );
               END IF;
               l_index := NULL;
               l_return :=
                 chk_lvrsn_in_collection
                   (p_leave_reason => l_rec_leaving_reason.leaving_reason
                   ,p_index        => l_index
                   );
                IF l_return = 'Y' THEN
                  IF g_debug
                  THEN
                    DEBUG('g_tab_lvrsn_map_cv(l_index).pcv_information2: '
                      ||  g_tab_lvrsn_map_cv(l_index).pcv_information2
                    );
                  END IF;
                  g_leaving_reason := g_tab_lvrsn_map_cv(l_index).pcv_information2;
                END IF; -- End if of l_index is not null check ...
            ELSE
                -- Raise data error
                IF g_debug
                THEN
                  DEBUG('Raise Data Error: Leaving Reason Missing');
                END IF;
                 l_value    :=
                         pqp_gb_psi_functions.raise_extract_error(
                           p_error_number      => 94479
                          ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                          ,p_token1            => 'Leaving Reason'
                          );

            END IF; -- End if of leaving reason is not null check ...
         END IF; -- End if of l_start_reason = 'ZZ' check ...

         IF     l_start_reason = 'ZZ'
            AND NVL(l_asg_status_type_id, hr_api.g_number) <>
                                                        g_terminate_asg_sts_id
         THEN
            l_asg_status_type_id    := g_terminate_asg_sts_id;
         END IF;

         -- Enhancement 5040543
         -- Add a warning message when pension category is null
         IF l_pension_category IS NULL
         THEN

           IF g_debug
           THEN
             l_proc_step := 165;
             DEBUG(l_proc_name, l_proc_step);
             DEBUG('Not a member of CS scheme');
           END IF;

           l_value    :=
                 pqp_gb_psi_functions.raise_extract_warning(
                   p_error_number      => 93775
                  ,p_error_text        => 'BEN_93775_EXT_PSI_NOT_PEN_MEMB'
                  ,p_token1            => p_assignment_id
                  ,p_token2            => fnd_date.date_to_displaydt(g_effective_date)
                  );
         END IF; -- End if of pension category is null check ...

         get_service_history_code(
            p_event_desc           => l_start_reason
           ,p_pension_scheme       => l_pension_category
           ,p_employment_type      => l_psi_emp_type
           ,p_event_source         => l_event_source
           ,p_absence_type         => l_absence_type_id
           ,p_asg_status           => NVL(
                                         l_asg_status_type_id
                                        ,l_rec_asg_details.assignment_status_type_id
                                      )
           ,p_partnership_scheme   => l_partnership_scheme --115.14
           ,p_start_reason         => g_start_reason
           ,p_scheme_category      => g_scheme_category
           ,p_scheme_status        => g_scheme_status
         );

         -- Check whether the person has opted out of the pension scheme
         -- on the joining day (hired day)
         IF l_start_reason = 'OO' AND l_asg_start_date = l_ser_start_date
         THEN
            g_start_reason    := 'N';
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 170;
            DEBUG('l_asg_status_type_id: ' || l_asg_status_type_id);
            DEBUG('g_start_reason: ' || g_start_reason);
            DEBUG('g_scheme_category: ' || g_scheme_category);
            DEBUG('g_scheme_status: ' || g_scheme_status);
            DEBUG(
               'g_ser_start_date: '
               || TO_CHAR(g_ser_start_date, 'DD/MON/YYYY')
            );
         END IF;
      END IF; -- End if of l_include_flag = 'Y' check ...

--       IF    l_event_group_name = 'PQP_GB_PSI_NI_NUMBER'
--          OR l_event_group_name = 'PQP_GB_PSI_ASSIGNMENT_NUMBER'
--       THEN
--          IF g_debug
--          THEN
--             l_proc_step    := 180;
--             DEBUG(l_proc_name, l_proc_step);
--          END IF;
--
--          -- event qualifies
--          l_include_flag      := 'Y';
--          -- Get the service history as of the event date
--          -- call cutover function to return this date
--          -- g_effective_date will be set to event date
--          get_asg_ser_cutover_data(p_assignment_id => p_assignment_id);
--          g_ser_start_date    := g_effective_date;
--       END IF; -- End if of event group name check ...

      IF g_debug
      THEN
         l_proc_step    := 190;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_include_flag: ' || l_include_flag);
         DEBUG('g_ser_start_date: '
            || TO_CHAR(g_ser_start_date, 'DD/MON/YYYY'));
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
   END chk_ser_periodic_criteria;

-- This function is used to evaluate assignments that
-- qualify for penserver service history interface
-- ----------------------------------------------------------------------------
-- |---------------------< chk_service_history_criteria  ---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_service_history_criteria(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name        VARCHAR2(80)
                             := g_proc_name || 'chk_service_history_criteria';
      l_proc_step        PLS_INTEGER;
      l_include_flag     VARCHAR2(10);
      l_debug            VARCHAR2(10);
      i                  NUMBER;
      l_pension_category pqp_configuration_values.pcv_information1%TYPE;
--
   BEGIN
      --

      IF g_business_group_id IS NULL
      THEN
         -- Always clear cache before proceeding to set globals
         clear_cache;
         g_debug    := pqp_gb_psi_functions.check_debug(p_business_group_id);
--          -- set g_debug based on process definition configuration
--          IF g_tab_prs_dfn_cv.COUNT = 0
--          THEN
--             fetch_process_defn_cv(p_business_group_id => p_business_group_id);
--             i    := g_tab_prs_dfn_cv.FIRST;
--
--             WHILE i IS NOT NULL
--             LOOP
--                l_debug    := g_tab_prs_dfn_cv(i).pcv_information1;
--                i          := g_tab_prs_dfn_cv.NEXT(i);
--             END LOOP;
--
--             IF l_debug = 'Y'
--             THEN
--                g_debug    := TRUE;
--             END IF;
--          END IF; -- End if of prs dfn collection count is zero check ...
      END IF; -- End if of g_business_group_id is NULL check ...

      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_business_group_id: ' || p_business_group_id);
         DEBUG('p_effective_date: '
            || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_include_flag       := 'N';

      IF g_business_group_id IS NULL
      THEN
         -- Call clear cache function to clear cached variables
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
         set_service_history_globals(
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

      IF g_extract_type = 'PERIODIC'
      THEN
         g_effective_date    := p_effective_date;

         IF g_debug
         THEN
            DEBUG(
               'g_effective_date: '
               || TO_CHAR(g_effective_date, 'DD/MON/YYYY')
            );
         END IF;
      END IF;

      g_ser_start_date     := NULL;
      g_start_reason       := NULL;
      g_scheme_category    := NULL;
      g_scheme_status      := NULL;
      g_leaving_reason     := NULL;

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

      -- Initialize counter only for a different person (tested for rehires)
      IF NVL(g_person_id, hr_api.g_number) <> g_assignment_dtl.person_id
      THEN
         clear_per_cache;
         g_person_id    := g_assignment_dtl.person_id;
--       ELSE
--          g_event_counter    :=
--                         ben_ext_person.g_pay_proc_evt_tab.NEXT(g_event_counter);
      END IF;

      IF g_debug
      THEN
         l_proc_step    := 60;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_include_flag: ' || l_include_flag);
         DEBUG('g_extract_type: ' || g_extract_type);
      END IF;

      IF l_include_flag = 'Y'
      THEN
         -- Check basic criteria
         IF g_extract_type = 'CUTOVER'
         THEN
            IF g_debug
            THEN
               l_proc_step    := 70;
               DEBUG(l_proc_name, l_proc_step);
            END IF;

            get_asg_ser_cutover_data(p_assignment_id => p_assignment_id);
            -- return assignment qualifies
            l_include_flag    := 'Y';
         ELSIF g_extract_type = 'PERIODIC'
         THEN
            -- Set counter index to pay evt index
            g_event_counter    := ben_ext_person.g_chg_pay_evt_index;

            IF g_debug
            THEN
               l_proc_step    := 80;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('g_event_counter: ' || g_event_counter);
            END IF;

            l_include_flag     :=
                 chk_ser_periodic_criteria(p_assignment_id => p_assignment_id);
            -- get_asg_ser_periodic_data (p_assignment_id => p_assignment_id);
            -- Call process retro event for the last counter
--            IF g_event_counter = ben_ext_person.g_pay_proc_evt_tab.LAST
--            THEN
--               IF g_debug
--               THEN
--                 l_proc_step := 90;
--                 DEBUG(l_proc_name, l_proc_step);
--                 DEBUG('Last Counter: ' || ben_ext_person.g_pay_proc_evt_tab.LAST);
--                 DEBUG('g_event_counter: ' || g_event_counter);
--               END IF;
            pqp_gb_psi_functions.process_retro_event;
--            END IF; -- End if of event counter is last check ...
         END IF; -- End if of g_extract_type = 'CUTOVER' check ...
      END IF; -- End if of l_include_flag = Y check ...

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
   END chk_service_history_criteria;

-- This function is used to get service history data
-- for an assignment
-- ----------------------------------------------------------------------------
-- |---------------------< get_service_history_data >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_service_history_data(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
     ,p_rule_parameter      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name      VARCHAR2(80)
                                 := g_proc_name || 'get_service_history_data';
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
         DEBUG('p_effective_date: '
            || TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_rule_parameter: ' || p_rule_parameter);
      END IF;

      -- Call local functions based on rule_parameter value
      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      -- Return Start Date
      IF p_rule_parameter = 'StartDate'
      THEN
         l_return_value    := fnd_date.date_to_canonical(g_ser_start_date);

         IF g_ser_start_date IS NULL
         THEN
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
      -- Return End Date
      ELSIF p_rule_parameter = 'EndDate'
      THEN
         IF g_start_reason = 'ZZ' THEN
           -- This is a termination event
           -- populate end date as well
           l_return_value    := fnd_date.date_to_canonical(g_ser_start_date);

           IF g_ser_start_date IS NULL
           THEN
              IF g_debug
              THEN
                 DEBUG('Raise Data Error: End Date Missing');
              END IF;

              -- Raise data error
              l_value    :=
                 pqp_gb_psi_functions.raise_extract_error(
                    p_error_number      => 94479
                   ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                   ,p_token1            => 'End Date'
                 );
           END IF; -- End if of start date is null check ...
         END IF; -- End if of start reason is ZZ ...
      ELSIF p_rule_parameter = 'StartReason'
      THEN
         l_return_value    := TRIM(RPAD(g_start_reason, 4, ' '));

         IF g_start_reason IS NULL
         THEN
            IF g_debug
            THEN
               DEBUG('Raise Data Error: Start Reason Missing');
            END IF;

            -- Raise data error
            l_value    :=
               pqp_gb_psi_functions.raise_extract_error(
                  p_error_number      => 94479
                 ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                 ,p_token1            => 'Start Reason'
               );
         END IF;
      ELSIF p_rule_parameter = 'SchemeCategory'
      THEN
         l_return_value    := TRIM(RPAD(g_scheme_category, 4, ' '));

         IF g_scheme_category IS NULL
         THEN
            IF g_debug
            THEN
               DEBUG('Raise Data Error: Scheme Category Missing');
            END IF;

            -- Raise data error
            l_value    :=
               pqp_gb_psi_functions.raise_extract_error(
                  p_error_number      => 94479
                 ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                 ,p_token1            => 'Scheme Category'
               );
         END IF;
      ELSIF p_rule_parameter = 'SchemeStatus'
      THEN
         l_return_value    := TRIM(RPAD(g_scheme_status, 2, ' '));

         IF g_scheme_category IS NULL
         THEN
            IF g_debug
            THEN
               DEBUG('Raise Data Error: Scheme Status Missing');
            END IF;

            -- Raise data error
            l_value    :=
               pqp_gb_psi_functions.raise_extract_error(
                  p_error_number      => 94479
                 ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                 ,p_token1            => 'Scheme Status'
               );
         END IF;
      ELSIF p_rule_parameter = 'ServiceReason'
      THEN
         IF g_start_reason = 'ZZ'
         THEN
           l_return_value    := TRIM(RPAD(g_leaving_reason, 2, ' '));

           IF g_leaving_reason IS NULL THEN
             IF g_debug
             THEN
                DEBUG('Raise Data Error: End Reason Missing');
             END IF;

             -- Raise data error
             l_value    :=
                pqp_gb_psi_functions.raise_extract_error(
                   p_error_number      => 94479
                  ,p_error_text        => 'BEN_94479_EXT_PSI_REQ_FLD_MISS'
                  ,p_token1            => 'End Reason'
                );
           END IF; -- End if of leaving reason is null check ...
         END IF; -- End if of start reason is ZZ check ...
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
   END get_service_history_data;

-- This function is used for post processing in service history interface
-- ----------------------------------------------------------------------------
-- |---------------------< service_history_post_process >---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION service_history_post_process(p_ext_rslt_id IN NUMBER)
      RETURN VARCHAR2
   IS
      --
      l_proc_name      VARCHAR2(80)
                             := g_proc_name || 'service_history_post_process';
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
      pqp_gb_psi_functions.common_post_process(p_business_group_id => g_business_group_id);

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
   END service_history_post_process;
END pqp_gb_psi_service_history;

/
