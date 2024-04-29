--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_EARNINGS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_EARNINGS_HISTORY" 
--  /* $Header: pqpgbpsiern.pkb 120.16.12010000.10 2009/06/02 17:23:29 jvaradra ship $ */
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
      g_ni_ele_type_id          := NULL;
      g_ni_category_iv_id       := NULL;
      g_ni_pension_iv_id        := NULL;
      g_ni_euel_bal_type_id     := NULL;
      g_ni_euel_ptd_bal_id      := NULL;
      g_ni_eet_bal_type_id      := NULL;
      g_ni_eet_ptd_bal_id       := NULL;

      --Bug 8517132: Added for NI UAP
      g_ni_euap_bal_type_id     := NULL;
      g_ni_euap_ptd_bal_id      := NULL;

      -- Commenting the below variables as not used
     /* g_tot_byb_cont_bal_id     := NULL;
      g_tot_byb_ptd_bal_id      := NULL; */

      g_tot_ayr_cont_bal_id     := NULL;
      g_tot_ayr_ptd_bal_id      := NULL;
      -- For 115.29
      g_tot_ayr_ytd_bal_id      := NULL;

      g_tot_ayr_fb_cont_bal_id     := NULL;
      g_tot_ayr_fb_ptd_bal_id      := NULL;
      -- For 115.29
      g_tot_ayr_fb_ytd_bal_id      := NULL;

      /* BEGIN Nuvos changes */
      g_tot_apavc_cont_bal_id     := NULL;
      g_tot_apavc_ptd_bal_id      := NULL;
      -- For 115.29
      g_tot_apavc_ytd_bal_id      := NULL;

      g_tot_apavcm_cont_bal_id     := NULL;
      g_tot_apavcm_ptd_bal_id      := NULL;
      -- For 115.29
      g_tot_apavcm_ytd_bal_id      := NULL;

      /* END Nuvos Changes */

      g_effective_start_date    := NULL;
      g_effective_end_date      := NULL;
      g_procptd_dimension_id    := NULL;
      -- For 115.29
      g_penytd_dimension_id     := NULL;
      g_tdptd_dimension_id      := NULL;
      g_ayfwd_bal_conts         := NULL;
      -- Clear all global collections
      g_tab_clas_pen_bal_dtls.DELETE;
      g_tab_clap_pen_bal_dtls.DELETE;
      g_tab_prem_pen_bal_dtls.DELETE;
      g_tab_part_pen_bal_dtls.DELETE;
      g_tab_pen_sch_map_cv.DELETE;
      g_tab_pen_ele_ids.DELETE;
      g_tab_prs_dfn_cv.DELETE;
      g_tab_eei_info.DELETE;
      g_tab_avc_pen_bal_dtls.DELETE;
      g_tab_ni_cont_out_bals.DELETE;

      g_tab_nuvos_pen_bal_dtls.DELETE;       -- For Nuvos

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
-- |----------------------------< clear_asg_cache >---------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE clear_asg_cache
   IS
      --
      l_proc_name   VARCHAR2(80) := g_proc_name || 'clear_asg_cache';
      l_proc_step   PLS_INTEGER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      g_assignment_id         := NULL;
      g_ni_ele_ent_details    := NULL;
      g_ni_e_cat_exists       := NULL;
      g_member                := 'N';

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
   END clear_asg_cache;

-- For bug 7297812
-- This function will be used to fetch the latest assignment_action_id
-- for a given assignment_id
------------------------------------------------------------------
----------------------get_latest_action_id----------------------------
-------------------------------------------------------------------

FUNCTION get_latest_action_id (p_assignment_id IN NUMBER,
             p_effective_start_date IN DATE,
             p_effective_end_date IN DATE)
RETURN NUMBER IS
--
   l_assignment_action_id   NUMBER;
   l_master_asg_action_id       NUMBER;
   l_child_asg_action_id       NUMBER;
--

cursor get_master_latest_id (c_assignment_id IN NUMBER,
                 c_effective_start_date IN DATE,
                 c_effective_end_date IN DATE) is
    SELECT /*+ USE_NL(paa, ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.source_action_id is null
    AND  ppa.effective_date  between c_effective_start_date and c_effective_end_date
    AND  ppa.action_type     in ('R', 'Q', 'I', 'V', 'B');
 -- AND  paa.action_status   = 'C';
--

cursor get_latest_id (c_assignment_id IN NUMBER,
          c_effective_date IN DATE,
          c_master_asg_action_id IN NUMBER) is
    SELECT /*+ USE_NL(paa, ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.source_action_id is not null
    AND  ppa.effective_date <= c_effective_date
    AND  ppa.action_type        in ('R', 'Q')
  --AND  paa.action_status = 'C'
    AND  paa.source_action_id = c_master_asg_action_id ;
--
BEGIN
--

    open  get_master_latest_id(p_assignment_id,p_effective_start_date,p_effective_end_date);
    fetch get_master_latest_id into l_master_asg_action_id;

    if   get_master_latest_id%found then

   open  get_latest_id(p_assignment_id, p_effective_end_date,l_master_asg_action_id);
   fetch get_latest_id into l_child_asg_action_id;

   if l_child_asg_action_id is not null then
      l_assignment_action_id := l_child_asg_action_id;
   else
      l_assignment_action_id := l_master_asg_action_id;
   end if;
   close get_latest_id;
    end if;
    close get_master_latest_id;
--
RETURN l_assignment_action_id;
--
END get_latest_action_id;

-- This function returns the element name for a given element type id
-- and effective date
-- ----------------------------------------------------------------------------
-- |----------------------------< get_element_name >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_element_name(
      p_element_type_id   IN   NUMBER
     ,p_effective_date    IN   DATE
   )
      RETURN VARCHAR2
   IS
      --
      -- Cursor to get element name
      CURSOR csr_get_element_name
      IS
         SELECT petl.element_name
           FROM pay_element_types_f pet, pay_element_types_f_tl petl
          WHERE petl.element_type_id = pet.element_type_id
            AND petl.LANGUAGE = USERENV('LANG')
            AND pet.element_type_id = p_element_type_id
            AND p_effective_date BETWEEN pet.effective_start_date
                                     AND pet.effective_end_date;

      l_proc_name      VARCHAR2(80)       := g_proc_name || 'get_element_name';
      l_proc_step      PLS_INTEGER;
      l_element_name   pay_element_types_f.element_name%TYPE;
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
      END IF;

      OPEN csr_get_element_name;
      FETCH csr_get_element_name INTO l_element_name;
      CLOSE csr_get_element_name;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_element_name: ' || l_element_name);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_element_name;
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
   END get_element_name;

-- This function returns input value id for a given element type id
-- and input value name
-- ----------------------------------------------------------------------------
-- |----------------------------< get_input_value_id >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_input_value_id(
      p_element_type_id    IN   NUMBER
     ,p_effective_date     IN   DATE
     ,p_input_value_name   IN   VARCHAR2
     ,p_element_name       IN   VARCHAR2
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
         DEBUG('p_element_name: ' || p_element_name);
      END IF;

      OPEN csr_get_iv_id;
      FETCH csr_get_iv_id INTO l_input_value_id;

      IF csr_get_iv_id%NOTFOUND
      THEN
         -- Raise setup error
         pqp_gb_psi_functions.store_extract_exceptions(
            p_extract_type            => 'EARNINGS_HISTORY'
           ,p_error_number            => 92493
           ,p_error_text              => 'BEN_92493_EXT_PSI_NO_INPUT_VAL'
           ,p_token1                  => p_element_name
           ,p_token2                  => p_input_value_name
           ,p_token3                  => fnd_date.date_to_displaydt(p_effective_date)
           ,p_error_warning_flag      => 'E'
         );
      END IF; -- End if of row not found check ...

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

-- This function returns template id for a given template name
-- and business group id
-- ----------------------------------------------------------------------------
-- |----------------------------< get_template_id >---------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_template_id(
      p_template_name       IN   VARCHAR2
     ,p_business_group_id   IN   NUMBER
     ,p_template_type       IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      -- Cursor to get template id
      CURSOR csr_get_template_id
      IS
         SELECT template_id
           FROM pay_element_templates
          WHERE template_name = p_template_name
            AND template_type = p_template_type
            AND (
                    (
                         p_business_group_id IS NOT NULL
                     AND business_group_id = p_business_group_id
                    )
                 OR (
                     business_group_id IS NULL AND p_business_group_id IS NULL
                    )
                );

      l_proc_name     VARCHAR2(80) := g_proc_name || 'get_template_id';
      l_proc_step     PLS_INTEGER;
      l_template_id   NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_template_name: ' || p_template_name);
         DEBUG('p_business_group_id: ' || p_business_group_id);
         DEBUG('p_template_type: ' || p_template_type);
      END IF;

      OPEN csr_get_template_id;
      FETCH csr_get_template_id INTO l_template_id;
      CLOSE csr_get_template_id;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_template_id: ' || l_template_id);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_template_id;
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
   END get_template_id;

-- This procedure gets element extra information for a given element type
-- and information type
-- ----------------------------------------------------------------------------
-- |----------------------------< get_eeit_info >-----------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_eeit_info(
      p_element_type_id    IN              NUMBER
     ,p_information_type   IN              VARCHAR2
     ,p_rec_eeit_info      OUT NOCOPY      pay_element_type_extra_info%ROWTYPE
   )
   IS
      --
      -- Cursor to get eei information
      CURSOR csr_get_eei_info
      IS
         SELECT *
           FROM pay_element_type_extra_info
          WHERE element_type_id = p_element_type_id
            AND information_type = p_information_type;

      l_proc_name       VARCHAR2(80)         := g_proc_name || 'get_eeit_info';
      l_proc_step       PLS_INTEGER;
      l_rec_eeit_info   pay_element_type_extra_info%ROWTYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_element_type_id: ' || p_element_type_id);
         DEBUG('p_information_type: ' || p_information_type);
      END IF;

      OPEN csr_get_eei_info;
      FETCH csr_get_eei_info INTO l_rec_eeit_info;

      IF csr_get_eei_info%NOTFOUND
      THEN
         -- Raise setup error
         pqp_gb_psi_functions.store_extract_exceptions(
            p_extract_type            => 'EARNINGS_HISTORY'
           ,p_error_number            => 92583
           ,p_error_text              => 'BEN_92583_EXT_PSI_NO_EEI_INFO'
           ,p_token1                  => g_tab_pen_ele_ids(p_element_type_id).element_name
           ,p_token2                  => p_information_type
           ,p_error_warning_flag      => 'E'
         );
      END IF; -- End if of row not found check ...

      CLOSE csr_get_eei_info;
      p_rec_eeit_info    := l_rec_eeit_info;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(
               'l_rec_eeit_info.eei_information1: '
            || l_rec_eeit_info.eei_information1
         );
         DEBUG(
               'l_rec_eeit_info.eei_information2: '
            || l_rec_eeit_info.eei_information2
         );
         DEBUG(
               'l_rec_eeit_info.eei_information3: '
            || l_rec_eeit_info.eei_information3
         );
         DEBUG(
               'l_rec_eeit_info.eei_information4: '
            || l_rec_eeit_info.eei_information4
         );
         DEBUG(
               'l_rec_eeit_info.eei_information5: '
            || l_rec_eeit_info.eei_information5
         );
         DEBUG(
               'l_rec_eeit_info.eei_information6: '
            || l_rec_eeit_info.eei_information6
         );
         DEBUG(
               'l_rec_eeit_info.eei_information7: '
            || l_rec_eeit_info.eei_information7
         );
         DEBUG(
               'l_rec_eeit_info.eei_information8: '
            || l_rec_eeit_info.eei_information8
         );
         DEBUG(
               'l_rec_eeit_info.eei_information9: '
            || l_rec_eeit_info.eei_information9
         );
         DEBUG(
               'l_rec_eeit_info.eei_information10: '
            || l_rec_eeit_info.eei_information10
         );
         DEBUG(
               'l_rec_eeit_info.eei_information11: '
            || l_rec_eeit_info.eei_information11
         );
         DEBUG(
               'l_rec_eeit_info.eei_information12: '
            || l_rec_eeit_info.eei_information12
         );
         DEBUG(
               'l_rec_eeit_info.eei_information13: '
            || l_rec_eeit_info.eei_information13
         );
         DEBUG(
               'l_rec_eeit_info.eei_information14: '
            || l_rec_eeit_info.eei_information14
         );
         DEBUG(
               'l_rec_eeit_info.eei_information15: '
            || l_rec_eeit_info.eei_information15
         );
         DEBUG(
               'l_rec_eeit_info.eei_information16: '
            || l_rec_eeit_info.eei_information16
         );
         DEBUG(
               'l_rec_eeit_info.eei_information17: '
            || l_rec_eeit_info.eei_information17
         );
         DEBUG(
               'l_rec_eeit_info.eei_information18: '
            || l_rec_eeit_info.eei_information18
         );
         DEBUG(
               'l_rec_eeit_info.eei_information19: '
            || l_rec_eeit_info.eei_information19
         );
         DEBUG(
               'l_rec_eeit_info.eei_information20: '
            || l_rec_eeit_info.eei_information20
         );
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
   END get_eeit_info;
/* BEGIN Nuvos Change */
-- This procedure gets assignment extra information for a given assignment
-- ----------------------------------------------------------------------------
-- |----------------------------< get_asg_eit_info >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_asg_eit_info(
      p_assignment_id    IN              NUMBER
     ,p_information_type   IN              VARCHAR2
   )
   RETURN VARCHAR2

   IS
      --
      -- Cursor to get eei information
      CURSOR csr_get_aei_info
      IS
         SELECT aei_information1
           FROM per_assignment_extra_info
          WHERE assignment_id = p_assignment_id
            AND information_type = p_information_type;

      l_proc_name       VARCHAR2(80)         := g_proc_name || 'get_asg_eit_info';
      l_proc_step       PLS_INTEGER;
      l_svpn_no   per_assignment_extra_info.aei_information1%TYPE;
      l_value            NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_information_type: ' || p_information_type);
      END IF;

      OPEN csr_get_aei_info;
      FETCH csr_get_aei_info INTO  l_svpn_no;

      IF csr_get_aei_info%NOTFOUND
      THEN
         l_svpn_no := '01';
        -- l_value := pqp_gb_psi_functions.raise_extract_warning(p_error_text => 'SPN not found');
        /* -- Raise setup error
         pqp_gb_psi_functions.store_extract_exceptions(
            p_extract_type            => 'EARNINGS_HISTORY'
           ,p_error_number            => 92583
           ,p_error_text              => 'BEN_92583_EXT_PSI_NO_EEI_INFO'
           ,p_token1                  => p_assignment_id
           ,p_token2                  => p_information_type
           ,p_error_warning_flag      => 'W'
         );*/
      END IF; -- End if of row not found check ...

     CLOSE csr_get_aei_info;

     RETURN  l_svpn_no;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(
               'l_svpn_no: '
            || l_svpn_no
         );

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
   END get_asg_eit_info;

/* END NUvos Change */

-- This function returns ptd balance value over a date range
-- for a given assignment id, effective date range and balance dimension
-- ----------------------------------------------------------------------------
-- |----------------------------< get_total_ptd_bal_value >-------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_total_ptd_bal_value(
      p_assignment_id          IN   NUMBER
     ,p_defined_balance_id     IN   NUMBER
     ,p_effective_start_date   IN   DATE
     ,p_effective_end_date     IN   DATE
   )
      RETURN NUMBER
   IS
      --
      -- Cursor to fetch end date from time period
      CURSOR csr_get_end_date
      IS
         SELECT /*+ leading(paa) */
                DISTINCT (ptp.end_date) end_date
           FROM pay_assignment_actions paa
               ,pay_payroll_actions ppa
               ,per_time_periods ptp
          WHERE ptp.time_period_id = ppa.time_period_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND ppa.effective_date BETWEEN p_effective_start_date AND p_effective_end_date
            AND ppa.action_type IN('R', 'Q', 'I', 'V', 'B')
            AND NVL(ppa.business_group_id, g_business_group_id) = g_business_group_id
            AND paa.assignment_id = p_assignment_id
       ORDER BY ptp.end_date;

      l_proc_name             VARCHAR2(80)
                                       := g_proc_name || 'get_balance_type_id';
      l_proc_step             PLS_INTEGER;
      l_balance_value         NUMBER;
      l_total_balance_value   NUMBER;
      l_effective_date        DATE;

      TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
      l_ptpenddt              t_date;

      l_ptpenddt1              t_date;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG('p_defined_balance_id: ' || p_defined_balance_id);
         DEBUG(
               'p_effective_start_date: '
            || TO_CHAR(p_effective_start_date, 'DD/MON/YYYY')
         );
         DEBUG(
               'p_effective_end_date: '
            || TO_CHAR(p_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      l_total_balance_value    := 0;

      l_ptpenddt := l_ptpenddt1;

      OPEN csr_get_end_date;
      FETCH csr_get_end_date BULK COLLECT INTO l_ptpenddt;
      CLOSE csr_get_end_date;

       DEBUG('lptpenddt.count: ' || l_ptpenddt.count);

      IF l_ptpenddt.count > 0
      THEN
         FOR ptpi in l_ptpenddt.first..l_ptpenddt.last
         LOOP

            l_balance_value          := 0;

            IF g_debug
            THEN
               l_proc_step    := 20;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('Before calling function pay_balance_pkg.get_value');
               DEBUG( 'l_ptpenddt: ' || TO_CHAR(l_ptpenddt(ptpi), 'DD/MON/YYYY'));
            END IF;

            BEGIN
               l_balance_value    :=
                  pay_balance_pkg.get_value(
                     p_defined_balance_id      => p_defined_balance_id
                    ,p_assignment_id           => p_assignment_id
                    ,p_virtual_date            => l_ptpenddt(ptpi)
                  );
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     IF g_debug
                     THEN
                        DEBUG('Exception: No data found');
                     END IF;

                     l_balance_value    := 0;
            END;

            IF g_debug
            THEN
               DEBUG('Balance Value: ' || TO_CHAR(l_balance_value));
            END IF;

            l_total_balance_value    := l_total_balance_value + l_balance_value;

         END LOOP;
      END IF;


     /* LOOP  --Commented as bul collect logic is used
         FETCH csr_get_end_date INTO l_effective_date;
         EXIT WHEN csr_get_end_date%NOTFOUND;
         l_balance_value          := 0;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('Before calling function pay_balance_pkg.get_value');
            DEBUG(
               'l_effective_date: '
               || TO_CHAR(l_effective_date, 'DD/MON/YYYY')
            );
         END IF;

         BEGIN
            l_balance_value    :=
               pay_balance_pkg.get_value(
                  p_defined_balance_id      => p_defined_balance_id
                 ,p_assignment_id           => p_assignment_id
                 ,p_virtual_date            => l_effective_date
               );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               IF g_debug
               THEN
                  DEBUG('Exception: No data found');
               END IF;

               l_balance_value    := 0;
         END;

         IF g_debug
         THEN
            DEBUG('Balance Value: ' || TO_CHAR(l_balance_value));
         END IF;

         l_total_balance_value    := l_total_balance_value + l_balance_value;
      END LOOP;

      CLOSE csr_get_end_date; */

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG('l_total_balance_value: ' || l_total_balance_value);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_total_balance_value;
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
   END get_total_ptd_bal_value;

-- This function returns balance type id for a given balance name
-- and business group id and legislation code
-- ----------------------------------------------------------------------------
-- |----------------------------< get_balance_type_id >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_balance_type_id(
      p_balance_name        IN   VARCHAR2
     ,p_business_group_id   IN   NUMBER
     ,p_legislation_code    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      -- Cursor to get balance type id
      CURSOR csr_get_bal_id
      IS
         SELECT balance_type_id
           FROM pay_balance_types
          WHERE balance_name = p_balance_name
            AND (
                    (business_group_id = p_business_group_id)
                 OR (
                         business_group_id IS NULL
                     AND (
                             legislation_code IS NULL
                          OR legislation_code = p_legislation_code
                         )
                    )
                );

      l_proc_name         VARCHAR2(80) := g_proc_name || 'get_balance_type_id';
      l_proc_step         PLS_INTEGER;
      l_balance_type_id   NUMBER;
      l_value             Number;  -- For bug 7428527
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_balance_name: ' || p_balance_name);
         DEBUG('p_business_group_id: ' || p_business_group_id);
         DEBUG('p_legislation_code: ' || p_legislation_code);
      END IF;

      OPEN csr_get_bal_id;
      FETCH csr_get_bal_id INTO l_balance_type_id;

      -- Added For Bug 6082532
      IF     csr_get_bal_id%NOTFOUND
         AND NOT (p_balance_name LIKE '%Buy Back FWC Contribution'
                  or
                  p_balance_name LIKE '%Added Years Family Benefit')
      THEN
        /* -- Raise setup error
         pqp_gb_psi_functions.store_extract_exceptions(
            p_extract_type            => 'EARNINGS_HISTORY'
           ,p_error_number            => 92642
           ,p_error_text              => 'BEN_92642_EXT_PSI_BAL_NOTFOUND'
           ,p_token1                  => p_balance_name
           ,p_token2                  => NULL
           ,p_error_warning_flag      => 'E'
         ); */

         -- For bug 7428527
         l_value := pqp_gb_psi_functions.raise_extract_error
                     (p_error_number        =>    92642
                     ,p_error_text          =>    'BEN_92642_EXT_PSI_BAL_NOTFOUND'
                     ,p_token1              =>    p_balance_name
                     );

      END IF; -- End if of row not found check ...

      CLOSE csr_get_bal_id;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_balance_type_id: ' || l_balance_type_id);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_balance_type_id;
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
   END get_balance_type_id;

-- This function returns balance dimension id for a given dimension name
-- and legislation code, business group
-- ----------------------------------------------------------------------------
-- |---------------------------< get_bal_dimension_id >-----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_bal_dimension_id(
      p_dimension_name      IN   VARCHAR2
     ,p_business_group_id   IN   NUMBER
     ,p_legislation_code    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      -- Cursor to get bal dimension id
      CURSOR csr_get_bal_dimension_id
      IS
         SELECT balance_dimension_id
           FROM pay_balance_dimensions
          WHERE dimension_name = p_dimension_name
            AND (
                    (business_group_id = p_business_group_id)
                 OR (
                         business_group_id IS NULL
                     AND (
                             legislation_code IS NULL
                          OR legislation_code = p_legislation_code
                         )
                    )
                );

      l_proc_name          VARCHAR2(80)
                                      := g_proc_name || 'get_bal_dimension_id';
      l_proc_step          PLS_INTEGER;
      l_bal_dimension_id   NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_dimension_name: ' || p_dimension_name);
         DEBUG('p_business_group_id: ' || p_business_group_id);
         DEBUG('p_legislation_code: ' || p_legislation_code);
      END IF;

      OPEN csr_get_bal_dimension_id;
      FETCH csr_get_bal_dimension_id INTO l_bal_dimension_id;

      IF csr_get_bal_dimension_id%NOTFOUND
      THEN
         -- Raise setup error
         pqp_gb_psi_functions.store_extract_exceptions(
            p_extract_type            => 'EARNINGS_HISTORY'
           ,p_error_number            => 92766
           ,p_error_text              => 'BEN_92766_EXT_PSI_NO_BAL_DIM'
           ,p_token1                  => p_dimension_name
           ,p_token2                  => NULL
           ,p_error_warning_flag      => 'E'
         );
      END IF;

      CLOSE csr_get_bal_dimension_id;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_bal_dimension_id: ' || l_bal_dimension_id);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_bal_dimension_id;
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
   END get_bal_dimension_id;

-- This function returns defined balance for a given balance type
-- and dimension
-- ----------------------------------------------------------------------------
-- |---------------------------< get_defined_balance >------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_defined_balance(
      p_balance_type_id        IN   NUMBER
     ,p_balance_dimension_id   IN   NUMBER
   )
      RETURN NUMBER
   IS
      --
      -- Cursor to get defined balance id
      CURSOR csr_get_def_bal_id
      IS
         SELECT defined_balance_id
           FROM pay_defined_balances
          WHERE balance_type_id = p_balance_type_id
            AND balance_dimension_id = p_balance_dimension_id;

      l_proc_name        VARCHAR2(80) := g_proc_name || 'get_defined_balance';
      l_proc_step        PLS_INTEGER;
      l_def_balance_id   NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_balance_type_id: ' || p_balance_type_id);
         DEBUG('p_balance_dimension_id: ' || p_balance_dimension_id);
      END IF;

      OPEN csr_get_def_bal_id;
      FETCH csr_get_def_bal_id INTO l_def_balance_id;

      IF csr_get_def_bal_id%NOTFOUND
      THEN
         -- Raise setup error
         pqp_gb_psi_functions.store_extract_exceptions(
            p_extract_type            => 'EARNINGS_HISTORY'
           ,p_error_number            => 92780
           ,p_error_text              => 'BEN_92780_EXT_PSI_NO_DEF_BAL'
           ,p_token1                  => p_balance_type_id
           ,p_token2                  => p_balance_dimension_id
           ,p_error_warning_flag      => 'E'
         );
      END IF; -- End if of row not found check ...

      CLOSE csr_get_def_bal_id;

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG('l_def_balance_id: ' || l_def_balance_id);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_def_balance_id;
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
   END get_defined_balance;

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

-- Ths function returns a yes or no flag to identify whether a value
-- is in the collection or not
-- ----------------------------------------------------------------------------
-- |---------------------< chk_value_in_collection >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_value_in_collection(
      p_collection_name   IN              t_varchar2
     ,p_value             IN              VARCHAR2
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
         END IF;

         i    := l_tab_config_values.NEXT(i);
      END LOOP;

      IF l_tab_config_values.COUNT = 0
      THEN
         -- Raise setup error
         pqp_gb_psi_functions.store_extract_exceptions(
            p_extract_type            => 'EARNINGS_HISTORY'
           ,p_error_number            => 94268
           ,p_error_text              => 'BEN_92799_EXT_PSI_NO_CONFIG'
           ,p_token1                  => 'Penserver Interface'
           ,p_token2                  => 'Pension Scheme Mapping'
           ,p_error_warning_flag      => 'E'
         );
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
   END fetch_pension_scheme_map_cv;

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

-- This function gets the element entry details for a given element type
-- ----------------------------------------------------------------------------
-- |----------------------------< get_ele_ent_details >-----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ele_ent_details(
      p_assignment_id          IN              NUMBER
     ,p_effective_start_date   IN              DATE
     ,p_effective_end_date     IN              DATE
     ,p_element_type_id        IN              NUMBER
     ,p_rec_ele_ent_details    OUT NOCOPY      r_ele_ent_details
   )
      RETURN VARCHAR2
   IS
      --
      -- Cursor to get pension scheme element details
      -- for this person
      CURSOR csr_get_ele_ent_details(c_element_type_id NUMBER)
      IS
         SELECT   pee.element_entry_id,
                  pee.effective_start_date,
                  pee.effective_end_date,
            --    pel.element_type_id
                  pee.element_type_id
             FROM pay_element_entries_f pee
                  --pay_element_links_f pel
            WHERE pee.assignment_id = p_assignment_id
              AND pee.entry_type = 'E'
             -- AND pee.element_link_id = pel.element_link_id
              AND (
                      p_effective_start_date BETWEEN pee.effective_start_date
                                                 AND pee.effective_end_date
                   OR p_effective_end_date BETWEEN pee.effective_start_date
                                               AND pee.effective_end_date
                   OR pee.effective_start_date BETWEEN p_effective_start_date
                                                   AND p_effective_end_date
                   OR pee.effective_end_date BETWEEN p_effective_start_date
                                                 AND p_effective_end_date
                  )
              AND pee.element_type_id = c_element_type_id
              /*AND pel.element_type_id = c_element_type_id
              AND (
                      p_effective_start_date BETWEEN pel.effective_start_date
                                                 AND pel.effective_end_date
                   OR p_effective_end_date BETWEEN pel.effective_start_date
                                               AND pel.effective_end_date
                   OR pel.effective_start_date BETWEEN p_effective_start_date
                                                   AND p_effective_end_date
                   OR pel.effective_end_date BETWEEN p_effective_start_date
                                                 AND p_effective_end_date
                  )*/
         ORDER BY pee.effective_start_date DESC;

      l_proc_name             VARCHAR2(80)
                                       := g_proc_name || 'get_ele_ent_details';
      l_proc_step             PLS_INTEGER;
      l_rec_ele_ent_details   r_ele_ent_details;
      l_return                VARCHAR2(10);
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG(
               'p_effective_start_date: '
            || TO_CHAR(p_effective_start_date, 'DD/MON/YYYY')
         );
         DEBUG(
               'p_effective_end_date: '
            || TO_CHAR(p_effective_end_date, 'DD/MON/YYYY')
         );
         DEBUG('p_element_type_id: ' || p_element_type_id);
      END IF;

      l_return                 := 'N';
      OPEN csr_get_ele_ent_details(p_element_type_id);
      FETCH csr_get_ele_ent_details INTO l_rec_ele_ent_details;

      IF csr_get_ele_ent_details%FOUND
      THEN
         l_return    := 'Y';

         IF g_debug
         THEN
            l_proc_step    := 30;
            DEBUG(l_proc_name, l_proc_step);
         END IF;
      END IF; -- cursor found check ...

      CLOSE csr_get_ele_ent_details;
      p_rec_ele_ent_details    := l_rec_ele_ent_details;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG('l_return: ' || l_return);
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
   END get_ele_ent_details;

-- This function returns the pension scheme membership details at a given date
-- ----------------------------------------------------------------------------
-- |----------------------------< get_pen_scheme_memb >-----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_pen_scheme_memb(
      p_assignment_id          IN              NUMBER
     ,p_effective_start_date   IN              DATE
     ,p_effective_end_date     IN              DATE
     ,p_tab_pen_sch_map_cv     IN              pqp_utilities.t_config_values
     ,p_rec_ele_ent_details    OUT NOCOPY      r_ele_ent_details
   )
      RETURN VARCHAR2
   IS
--
      l_proc_name             VARCHAR2(80)
                                      := g_proc_name || 'get_pen_scheme_memb';
      l_proc_step             PLS_INTEGER;
      l_rec_ele_ent_details   r_ele_ent_details;
      l_element_type_id       NUMBER;
      i                       NUMBER;
      l_return                VARCHAR2(10);
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
         DEBUG(
               'p_effective_start_date: '
            || TO_CHAR(p_effective_start_date, 'DD/MON/YYYY')
         );
         DEBUG(
               'p_effective_end_date: '
            || TO_CHAR(p_effective_end_date, 'DD/MON/YYYY')
         );
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

         l_return             :=
            get_ele_ent_details(
               p_assignment_id             => p_assignment_id
              ,p_effective_start_date      => p_effective_start_date
              ,p_effective_end_date        => p_effective_end_date
              ,p_element_type_id           => l_element_type_id
              ,p_rec_ele_ent_details       => l_rec_ele_ent_details
            );

         -- We are only interested in the latest pension scheme
         -- membership details
         IF l_return = 'Y'
         THEN
            IF g_debug
            THEN
               l_proc_step    := 30;
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
               DEBUG(l_proc_name, l_proc_step);
            END IF;

            EXIT;
         END IF; -- element entry details exist ...

         i                    := p_tab_pen_sch_map_cv.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG('l_return: ' || l_return);
         DEBUG('l_element_type_id: ' || l_element_type_id);
         debug_exit(l_proc_name);
      END IF;

      p_rec_ele_ent_details    := l_rec_ele_ent_details;
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
   END get_pen_scheme_memb;

-- This procedure gets all the relevant pension scheme balances for
-- reporting purposes
-- ----------------------------------------------------------------------------
-- |----------------------------< get_pen_balance_details >-------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_pen_balance_details(
      p_element_type_id     IN              NUMBER
     ,p_base_name           IN              VARCHAR2
     ,p_pension_category    IN              VARCHAR2
     ,p_psi_pens_category   IN              VARCHAR2
     ,p_rec_pen_bal_dtls    OUT NOCOPY      r_pen_bal_dtls
   )
   IS
      --
      l_proc_name           VARCHAR2(80)
                                  := g_proc_name || 'get_pen_balance_details';
      l_proc_step           PLS_INTEGER;
      i                     NUMBER;
      l_tab_bal_name        t_varchar2;
      l_ees_bal_name        pay_balance_types.balance_name%TYPE;
      l_ees_bal_type_id     NUMBER;
      l_ees_ptd_bal_id      NUMBER;
      -- For 115.29
      l_ees_ytd_bal_id      NUMBER;
      l_ers_bal_name        pay_balance_types.balance_name%TYPE;
      l_ers_bal_type_id     NUMBER;
      l_ers_ptd_bal_id      NUMBER;
      -- For 115.29
      l_ers_ytd_bal_id      NUMBER;
      -- Commenting the below variables as they are not used
     /* l_add_bal_name        pay_balance_types.balance_name%TYPE;
      l_add_bal_type_id     NUMBER;
      l_add_ptd_bal_id      NUMBER;
      l_ayr_bal_name        pay_balance_types.balance_name%TYPE;
      l_ayr_bal_type_id     NUMBER;
      l_ayr_ptd_bal_id      NUMBER;
      l_fwd_bal_name        pay_balance_types.balance_name%TYPE;
      l_fwd_bal_type_id     NUMBER;
      l_fwd_ptd_bal_id      NUMBER; */
      l_ayfwd_bal_name      pay_balance_types.balance_name%TYPE;
      l_ayfwd_bal_type_id   NUMBER;
      l_ayfwd_ptd_bal_id    NUMBER;
      -- For 115.29
      l_ayfwd_ytd_bal_id      NUMBER;

     /* l_ayfb_bal_name       pay_balance_types.balance_name%TYPE; -- For Bug 6082532
      l_ayfb_bal_type_id    NUMBER;
      l_ayfb_ptd_bal_id     NUMBER; */

      l_nuvos_sa_bal_name     pay_balance_types.balance_name%TYPE;    -- For Nuvos
      l_nuvos_sa_bal_type_id  NUMBER;
      l_nuvos_sa_ptd_bal_id   NUMBER;
      -- For 115.29
      l_nuvos_sa_ytd_bal_id   NUMBER;

      l_balance_type_id     NUMBER;
      l_defined_bal_id      NUMBER;
      -- For 115.29
      l_pen_defined_bal_id      NUMBER;

      l_rec_pen_bal_dtls    r_pen_bal_dtls;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_element_type_id: ' || p_element_type_id);
         DEBUG('p_base_name: ' || p_base_name);
         DEBUG('p_pension_category: ' || p_pension_category);
         DEBUG('p_psi_pens_category: ' || p_psi_pens_category);
      -- debug('p_template_id: '||p_template_id);
      END IF;

      -- Only proceed if eeit information exists
      IF g_tab_eei_info.EXISTS(p_element_type_id)
      THEN
         i                    := 1;
         l_tab_bal_name(i)    :=
               p_base_name || ' ' || p_pension_category
               || ' EES Contribution';
         l_ees_bal_name       := l_tab_bal_name(i);

         -- For Bug 6082532 (Added years Family Benefit balance)
       /*  i                    := i + 1;
         l_tab_bal_name(i)    :=
               p_base_name|| ' Added Years Family Benefit';
         l_ayfb_bal_name     := l_tab_bal_name(i); */

         -- ERS Contribution balance
         IF g_tab_eei_info(p_element_type_id).eei_information7 IS NOT NULL
         THEN
            i                    := i + 1;
            l_tab_bal_name(i)    :=
                p_base_name || ' ' || p_pension_category
                || ' ERS Contribution';
            l_ers_bal_name       := l_tab_bal_name(i);
         END IF; -- End if of eer deduction method check ...

         IF p_pension_category = 'OCP'
         THEN
            IF g_debug
            THEN
               l_proc_step    := 20;
               DEBUG(l_proc_name, l_proc_step);
            END IF;

            -- Commenting the below code as they are not used to retrieve the balances
            -- Look for other balances
            -- Additional Contribution balance
           /* IF g_tab_eei_info(p_element_type_id).eei_information13 = 'Y'
            THEN
               i                    := i + 1;
               l_tab_bal_name(i)    :=
                                     p_base_name
                                     || ' Additional Contribution';
               l_add_bal_name       := l_tab_bal_name(i);
            ELSIF g_tab_eei_info(p_element_type_id).eei_information14 IS NOT NULL   -- For BUG 6082532
            THEN
               -- Added Years Contribution
               i                    := i + 1;
               l_tab_bal_name(i)    :=
                                    p_base_name
                                    || ' Added Years Contribution';
               l_ayr_bal_name       := l_tab_bal_name(i);
            ELSIF g_tab_eei_info(p_element_type_id).eei_information15 = 'Y'
            THEN
               -- Family or Widower Benefit Contribution
               i                    := i + 1;
               l_tab_bal_name(i)    :=
                                 p_base_name
                                 || ' Family Widower Contribution';
               l_fwd_bal_name       := l_tab_bal_name(i);
            END IF; */

            IF p_psi_pens_category = 'CLASSIC'
            THEN
               -- Added Years for FW contribution
               i                    := i + 1;
               l_tab_bal_name(i)    :=
                                   p_base_name
                                   || ' Buy Back FWC Contribution';
               l_ayfwd_bal_name     := l_tab_bal_name(i);

            ELSIF p_psi_pens_category = 'NUVOS'
            THEN
               -- Added Years for Nuvos contributions
               i                    := i + 1;
               l_tab_bal_name(i)    :=
                                   p_base_name
                                   || ' Superannuable Salary';
               l_nuvos_sa_bal_name     := l_tab_bal_name(i);

            END IF; -- End if of psi pension category is classic check ...
         END IF; -- End if of pension category is OCP check ...
      END IF; -- End if of eeit information exists
              -- for this element type check ...

              -- Get the balance information

      i                                        := l_tab_bal_name.FIRST;

      WHILE i IS NOT NULL
      LOOP
         l_balance_type_id    :=
            get_balance_type_id(
               p_balance_name           => l_tab_bal_name(i)
              ,p_business_group_id      => g_business_group_id
              ,p_legislation_code       => NULL
            );
         l_defined_bal_id     := NULL;

         IF l_balance_type_id IS NOT NULL
         THEN
            l_defined_bal_id    :=
               get_defined_balance(
                  p_balance_type_id           => l_balance_type_id
                 ,p_balance_dimension_id      => g_procptd_dimension_id
               );
         END IF;

         -- For 115.29
         l_pen_defined_bal_id     := NULL;

         IF l_balance_type_id IS NOT NULL
         THEN
            l_pen_defined_bal_id    :=
               get_defined_balance(
                  p_balance_type_id           => l_balance_type_id
                 ,p_balance_dimension_id      => g_penytd_dimension_id
               );
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 30;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_tab_bal_name(i): ' || l_tab_bal_name(i));
            DEBUG('l_balance_type_id: ' || l_balance_type_id);
            DEBUG('l_defined_bal_id: ' || l_defined_bal_id);
            DEBUG('l_pen_defined_bal_id: ' || l_pen_defined_bal_id);
         END IF;

         -- Check the balance names and store it against the
         -- relevant variables

         IF l_tab_bal_name(i) = l_ees_bal_name
         THEN
            l_ees_bal_type_id    := l_balance_type_id;
            l_ees_ptd_bal_id     := l_defined_bal_id;
            -- For 115.29
            l_ees_ytd_bal_id     := l_pen_defined_bal_id;
         ELSIF l_tab_bal_name(i) = l_ers_bal_name
         THEN
            l_ers_bal_type_id    := l_balance_type_id;
            l_ers_ptd_bal_id     := l_defined_bal_id;
            -- For 115.29
            l_ers_ytd_bal_id     := l_pen_defined_bal_id;
         -- Commenting the below code as they are not used
        /* ELSIF l_tab_bal_name(i) = l_add_bal_name
         THEN
            l_add_bal_type_id    := l_balance_type_id;
            l_add_ptd_bal_id     := l_defined_bal_id;
         ELSIF l_tab_bal_name(i) = l_ayr_bal_name
         THEN
            l_ayr_bal_type_id    := l_balance_type_id;
            l_ayr_ptd_bal_id     := l_defined_bal_id;
         ELSIF l_tab_bal_name(i) = l_fwd_bal_name
         THEN
            l_fwd_bal_type_id    := l_balance_type_id;
            l_fwd_ptd_bal_id     := l_defined_bal_id; */
         ELSIF l_tab_bal_name(i) = l_ayfwd_bal_name
         THEN
            l_ayfwd_bal_type_id    := l_balance_type_id;
            l_ayfwd_ptd_bal_id     := l_defined_bal_id;
            -- For 115.29
            l_ayfwd_ytd_bal_id     := l_pen_defined_bal_id;
/*         ELSIF l_tab_bal_name(i) = l_ayfb_bal_name       -- For Bug 6082532
         THEN
            l_ayfb_bal_type_id    := l_balance_type_id;
            l_ayfb_ptd_bal_id     := l_defined_bal_id; */

         ELSIF l_tab_bal_name(i) = l_nuvos_sa_bal_name      -- For Nuvos
         THEN
            l_nuvos_sa_bal_type_id    := l_balance_type_id;
            l_nuvos_sa_ptd_bal_id     := l_defined_bal_id;
            -- For 115.29
            l_nuvos_sa_ytd_bal_id     := l_pen_defined_bal_id;

         END IF; -- End if of balance name check ...

         i                    := l_tab_bal_name.NEXT(i);
      END LOOP;

      l_rec_pen_bal_dtls.element_type_id       := p_element_type_id;
      l_rec_pen_bal_dtls.ees_balance_name      := l_ees_bal_name;
      l_rec_pen_bal_dtls.ees_bal_type_id       := l_ees_bal_type_id;
      l_rec_pen_bal_dtls.ees_ptd_bal_id        := l_ees_ptd_bal_id;
      -- For 115.29
      l_rec_pen_bal_dtls.ees_ytd_bal_id        := l_ees_ytd_bal_id;
      l_rec_pen_bal_dtls.ers_balance_name      := l_ers_bal_name;
      l_rec_pen_bal_dtls.ers_bal_type_id       := l_ers_bal_type_id;
      l_rec_pen_bal_dtls.ers_ptd_bal_id        := l_ers_ptd_bal_id;
      -- For 115.29
      l_rec_pen_bal_dtls.ers_ytd_bal_id        := l_ers_ytd_bal_id;
      -- Commenting the below codes as they are not used
     /* l_rec_pen_bal_dtls.add_balance_name      := l_add_bal_name;
      l_rec_pen_bal_dtls.add_bal_type_id       := l_add_bal_type_id;
      l_rec_pen_bal_dtls.add_ptd_bal_id        := l_add_ptd_bal_id;
      l_rec_pen_bal_dtls.ayr_balance_name      := l_ayr_bal_name;
      l_rec_pen_bal_dtls.ayr_bal_type_id       := l_ayr_bal_type_id;
      l_rec_pen_bal_dtls.ayr_ptd_bal_id        := l_ayr_ptd_bal_id;
      l_rec_pen_bal_dtls.fwd_balance_name      := l_fwd_bal_name;
      l_rec_pen_bal_dtls.fwd_bal_type_id       := l_fwd_bal_type_id;
      l_rec_pen_bal_dtls.fwd_ptd_bal_id        := l_fwd_ptd_bal_id; */
      l_rec_pen_bal_dtls.ayfwd_balance_name    := l_ayfwd_bal_name;
      l_rec_pen_bal_dtls.ayfwd_bal_type_id     := l_ayfwd_bal_type_id;
      l_rec_pen_bal_dtls.ayfwd_ptd_bal_id      := l_ayfwd_ptd_bal_id;
      -- For 115.29
      l_rec_pen_bal_dtls.ayfwd_ytd_bal_id      := l_ayfwd_ytd_bal_id;
    /*  l_rec_pen_bal_dtls.ayfb_balance_name     := l_ayfb_bal_name;     -- For Bug 6082532
      l_rec_pen_bal_dtls.ayfb_bal_type_id      := l_ayfb_bal_type_id;
      l_rec_pen_bal_dtls.ayfb_ptd_bal_id       := l_ayfb_ptd_bal_id; */

      l_rec_pen_bal_dtls.nuvos_sa_balance_name  := l_nuvos_sa_bal_name;     -- For Bug 6082532
      l_rec_pen_bal_dtls.nuvos_sa_bal_type_id      := l_nuvos_sa_bal_type_id;
      l_rec_pen_bal_dtls.nuvos_sa_ptd_bal_id       := l_nuvos_sa_ptd_bal_id;
      -- For 115.29
      l_rec_pen_bal_dtls.nuvos_sa_ytd_bal_id      := l_nuvos_sa_ytd_bal_id;


      p_rec_pen_bal_dtls                       := l_rec_pen_bal_dtls;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG('l_ees_bal_name: ' || l_ees_bal_name);
         DEBUG('l_ees_bal_type_id: ' || l_ees_bal_type_id);
         DEBUG('l_ees_ptd_bal_id: ' || l_ees_ptd_bal_id);
         -- For 115.29
         DEBUG('l_ees_ytd_bal_id: ' || l_ees_ytd_bal_id);
         DEBUG('l_ers_bal_name: ' || l_ers_bal_name);
         DEBUG('l_ers_bal_type_id: ' || l_ers_bal_type_id);
         DEBUG('l_ers_ptd_bal_id: ' || l_ers_ptd_bal_id);
         -- For 115.29
         DEBUG('l_ers_ytd_bal_id: ' || l_ers_ytd_bal_id);
          -- Commenting the below codes
       /*  DEBUG('l_add_bal_name: ' || l_add_bal_name);
         DEBUG('l_add_bal_type_id: ' || l_add_bal_type_id);
         DEBUG('l_add_ptd_bal_id: ' || l_add_ptd_bal_id);
         DEBUG('l_ayr_bal_name: ' || l_ayr_bal_name);
         DEBUG('l_ayr_bal_type_id: ' || l_ayr_bal_type_id);
         DEBUG('l_ayr_ptd_bal_id: ' || l_ayr_ptd_bal_id);
         DEBUG('l_fwd_bal_type_id: ' || l_fwd_bal_type_id);
         DEBUG('l_fwd_ptd_bal_id: ' || l_fwd_ptd_bal_id); */
         DEBUG('l_ayfwd_bal_type_id: ' || l_ayfwd_bal_type_id);
         DEBUG('l_ayfwd_ptd_bal_id: ' || l_ayfwd_ptd_bal_id);
         -- For 115.29
         DEBUG('l_ayfwd_ytd_bal_id: ' || l_ayfwd_ytd_bal_id);
        /* DEBUG('l_ayfb_bal_type_id: ' || l_ayfb_bal_type_id);    -- For Bug 6082532
         DEBUG('l_ayfb_ptd_bal_id: ' || l_ayfb_ptd_bal_id); */
         DEBUG('l_nuvos_sa_bal_type_id: ' || l_nuvos_sa_bal_type_id);    -- For Nuvos
         DEBUG('l_nuvos_sa_ptd_bal_id: ' || l_nuvos_sa_ptd_bal_id);
         -- For 115.29
         DEBUG('l_nuvos_sa_ytd_bal_id: ' || l_nuvos_sa_ytd_bal_id);

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
   END get_pen_balance_details;

-- This procedure gets all the avc details that has an associated COMP
-- OCP
-- ----------------------------------------------------------------------------
-- |----------------------------< get_avc_pen_balance_details >---------------|
-- ----------------------------------------------------------------------------
   PROCEDURE get_avc_pen_balance_details(
      p_associated_ocp_ele_id   IN              NUMBER
     ,p_information_type        IN              VARCHAR2
     ,p_tab_avc_pen_bal_dtls    IN OUT NOCOPY   t_ele_bal_dtls
   )
   IS
      --
      -- Cursor to fetch eei information
      CURSOR csr_get_avc_eei_info
      IS
         SELECT *
           FROM pay_element_type_extra_info
          WHERE information_type = p_information_type
            AND eei_information16 = p_associated_ocp_ele_id
            AND eei_information12 IS NULL;

      CURSOR csr_chk_classification (
                                      p_element_type_id NUMBER
                                    )
      IS
        SELECT pec.classification_name
          FROM pay_element_types_f petf, pay_element_classifications pec
         WHERE petf.element_type_id = p_element_type_id
           AND pec.classification_id = petf.classification_id;



      l_proc_name              VARCHAR2(80)
                               := g_proc_name || 'get_avc_pen_balance_details';
      l_proc_step              PLS_INTEGER;
      l_rec_avc_eei_info       pay_element_type_extra_info%ROWTYPE;
      l_ele_classification     pay_element_classifications.classification_name%TYPE;
      l_element_type_id        NUMBER;
      l_scheme_prefix          pay_element_type_extra_info.eei_information18%TYPE;
      l_balance_name           pay_balance_types.balance_name%TYPE;
      l_balance_type_id        NUMBER;
      l_defined_bal_id         NUMBER;
      -- For 115.29
      l_pen_defined_bal_id         NUMBER;
      l_tab_avc_pen_bal_dtls   t_ele_bal_dtls;
      l_value                 NUMBER;
   --
   BEGIN
      --

      l_element_type_id         := NULL;
      l_scheme_prefix           := NULL;
      l_balance_name            := NULL;
      l_defined_bal_id          := NULL;
      -- For 115.29
      l_pen_defined_bal_id          := NULL;
      l_tab_avc_pen_bal_dtls    := p_tab_avc_pen_bal_dtls;
      OPEN csr_get_avc_eei_info;

      LOOP
         FETCH csr_get_avc_eei_info INTO l_rec_avc_eei_info;
         EXIT WHEN csr_get_avc_eei_info%NOTFOUND;

         IF g_debug
         THEN
            l_proc_step    := 10;
            debug_enter(l_proc_name);
            DEBUG('p_associated_ocp_ele_id: ' || p_associated_ocp_ele_id);
            DEBUG('p_information_type: ' || p_information_type);
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- If this AVC is of COMP type, pick up details
         IF l_rec_avc_eei_info.eei_information8 = 'COMP'
         THEN

           -- Get the scheme prefix
           l_element_type_id                                               :=
                                              l_rec_avc_eei_info.element_type_id;
           l_scheme_prefix                                                 :=
                                            l_rec_avc_eei_info.eei_information18;
           l_balance_name                                                  :=
                                       l_scheme_prefix
                                       || ' AVC EES Contribution';
           l_balance_type_id                                               :=
              get_balance_type_id(
                 p_balance_name           => l_balance_name
                ,p_business_group_id      => g_business_group_id
                ,p_legislation_code       => NULL
              );
           l_defined_bal_id                                                :=
              get_defined_balance(
                 p_balance_type_id           => l_balance_type_id
                ,p_balance_dimension_id      => g_procptd_dimension_id
              );
           -- For 115.29
            l_pen_defined_bal_id                                                :=
              get_defined_balance(
                 p_balance_type_id           => l_balance_type_id
                ,p_balance_dimension_id      => g_penytd_dimension_id
              );

           l_tab_avc_pen_bal_dtls(l_element_type_id).balance_name          :=
                                                                  l_balance_name;
           l_tab_avc_pen_bal_dtls(l_element_type_id).balance_type_id       :=
                                                               l_balance_type_id;
           l_tab_avc_pen_bal_dtls(l_element_type_id).defined_balance_id    :=
                                                                l_defined_bal_id;
           -- For 115.29
           l_tab_avc_pen_bal_dtls(l_element_type_id).pen_defined_balance_id    :=
                                                                l_pen_defined_bal_id;

           IF g_debug
           THEN
              l_proc_step    := 30;
              DEBUG(l_proc_name, l_proc_step);
              DEBUG('l_element_type_id: ' || l_element_type_id);
              DEBUG('l_scheme_prefix: ' || l_scheme_prefix);
              DEBUG('l_balance_name: ' || l_balance_name);
              DEBUG('l_balance_type_id: ' || l_balance_type_id);
              DEBUG('l_defined_bal_id: ' || l_defined_bal_id);
              -- For 115.29
              DEBUG('l_pen_defined_bal_id: ' || l_pen_defined_bal_id);

           END IF;

         ELSIF l_rec_avc_eei_info.eei_information8 IS NULL -- AVC not of COMP type
         THEN

           -- now check if this AVC element is 'Pre Tax Deductions'
           -- or 'Voluntary Deductions' type
           OPEN csr_chk_classification (l_rec_avc_eei_info.element_type_id) ;
           FETCH csr_chk_classification INTO l_ele_classification;
           CLOSE csr_chk_classification;

           -- if 'Pre Tax Deductions' then it should not be null
           -- should be COMP or COSR, raise warning
           IF l_ele_classification = 'Pre Tax Deductions'
           THEN

              l_value  :=
                  pqp_gb_psi_functions.raise_extract_warning(
                     p_error_number      => 94892
                    ,p_error_text        => 'BEN_94892_NO_AVC_CLASSIFIC'
                    ,p_token1            => l_rec_avc_eei_info.eei_information1
                  );
           END IF;
         END IF; -- IF l_rec_avc_eei_info.eei_information8 = 'COMP'


         l_element_type_id                                               :=
                                                                          NULL;
         l_scheme_prefix                                                 :=
                                                                          NULL;
         l_balance_name                                                  :=
                                                                          NULL;
         l_defined_bal_id                                                :=
                                                                          NULL;
         l_pen_defined_bal_id                                                :=
                                                                          NULL;
      END LOOP;

      CLOSE csr_get_avc_eei_info;
      p_tab_avc_pen_bal_dtls    := l_tab_avc_pen_bal_dtls;

      IF g_debug
      THEN
         l_proc_step    := 40;
         DEBUG(l_proc_name, l_proc_step);
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
   END get_avc_pen_balance_details;

-- This procedure is used to set any globals needed for this extract
--
-- ----------------------------------------------------------------------------
-- |----------------------------< set_earnings_history_globals >--------------|
-- ----------------------------------------------------------------------------
   PROCEDURE set_earnings_history_globals(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
   )
   IS
      --
      l_proc_name                VARCHAR2(80)
                             := g_proc_name || 'set_earnings_history_globals';
      l_proc_step                PLS_INTEGER;
      l_input_value_name         pay_input_values_f.NAME%TYPE;
      l_input_value_id           NUMBER;
      l_element_type_id          NUMBER;
      l_tab_config_values        pqp_utilities.t_config_values;
      i                          NUMBER;
      l_error_code               NUMBER;
      l_error_message            VARCHAR2(2400);
      l_year                     VARCHAR2(10);
      l_scheme_prefix            pay_element_type_extra_info.eei_information18%TYPE;
      l_tab_avc_pen_bal_dtls     t_ele_bal_dtls;
      l_psi_pens_category        pqp_configuration_values.pcv_information1%TYPE;
      l_template_pens_category   pay_element_type_extra_info.eei_information4%TYPE;
      l_rec_pen_bal_dtls         r_pen_bal_dtls;
      l_rec_eeit_info            pay_element_type_extra_info%ROWTYPE;
      l_element_name             pay_element_types_f.element_name%TYPE;
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
      g_effective_date          := p_effective_date;

--      IF g_extract_type = 'CUTOVER' THEN
--         g_effective_date := g_cutover_date;
--      ELSIF g_extract_type = 'PERIODIC' THEN
--         g_effective_date := p_effective_date;
--      END IF; -- End if of p_extract_type is cutover check ...

      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      -- set effective end date
      IF TO_NUMBER(TO_CHAR(g_effective_date, 'MM')) < 4
      THEN
         -- subtract a year
         l_year    := TO_CHAR(ADD_MONTHS(g_effective_date, -12), 'YYYY');
      ELSE
         l_year    := TO_CHAR(g_effective_date, 'YYYY');
      END IF;

      g_effective_start_date    := TO_DATE('01/04/' || l_year, 'DD/MM/YYYY');
      g_effective_end_date      := LAST_DAY(g_effective_date);

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG(
               'g_effective_start_date: '
            || TO_CHAR(g_effective_start_date, 'DD/MM/YYYY')
         );
         DEBUG(
               'g_effective_end_date: '
            || TO_CHAR(g_effective_end_date, 'DD/MM/YYYY')
         );
      END IF;

      -- Get the assignment status type id for
      -- active assignments
--       get_asg_status_type
--         (p_per_system_status => 'ACTIVE_ASSIGN'
--         ,p_rec_asg_sts_dtls => l_rec_asg_sts_dtls
--         );
--       g_active_asg_sts_id := l_rec_asg_sts_dtls.assignment_status_type_id;
--
--      IF g_debug
--      THEN
--        l_proc_step := 40;
--        debug(l_proc_name, l_proc_step);
--      END IF;
--
--       -- Get the assignment status type id for
--       -- terminations
--       get_asg_status_type
--         (p_per_system_status => 'TERM_ASSIGN'
--         ,p_rec_asg_sts_dtls => l_rec_asg_sts_dtls
--         );
--       g_terminate_asg_sts_id := l_rec_asg_sts_dtls.assignment_status_type_id;

--      IF g_debug
--      THEN
--        l_proc_step := 50;
--        debug(l_proc_name, l_proc_step);
--      END IF;

--     fetch_empl_type_map_cv;

      -- Get the bal dimension id for dimension _ASG_PROC_PTD
      g_procptd_dimension_id    :=
         get_bal_dimension_id(
            p_dimension_name         => '_ASG_PROC_PTD'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      -- For 115.29
      -- Get the bal dimension id for dimension _ASG_PEN_YTD
      g_penytd_dimension_id    :=
         get_bal_dimension_id(
            p_dimension_name         => '_ASG_PEN_YTD'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );


      -- Get the bal dimension id for dimension _ASG_TRANSFER_PTD
--      g_tdptd_dimension_id      :=
--         get_bal_dimension_id(
--            p_dimension_name         => '_ASG_TRANSFER_PTD'
--           ,p_business_group_id      => NULL
--           ,p_legislation_code       => g_legislation_code
--         );

      -- Fetch data from configuration values and store in a
      -- global collection
      IF g_debug
      THEN
         l_proc_step    := 60;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_procptd_dimension_id: ' || g_procptd_dimension_id);
         DEBUG('g_penytd_dimension_id ' || g_penytd_dimension_id);         -- For 115.29
      END IF;

      -- Fetch pension scheme configuration values
      fetch_pension_scheme_map_cv(
         p_business_group_id       => p_business_group_id
        ,p_tab_pen_sch_map_cv      => g_tab_pen_sch_map_cv
      );
      i                         := g_tab_pen_sch_map_cv.FIRST;

--     l_input_value_name := 'Opt Out Date';
      IF g_debug
      THEN
         l_proc_step    := 70;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      WHILE i IS NOT NULL
      LOOP
         l_element_type_id                                       :=
            fnd_number.canonical_to_number(g_tab_pen_sch_map_cv(i).pcv_information1);
         l_psi_pens_category                                     :=
                                     g_tab_pen_sch_map_cv(i).pcv_information2;
--         l_input_value_id := get_input_value_id(p_element_type_id  => l_element_type_id
--                                               ,p_effective_date => g_effective_date
--                                               ,p_input_value_name => l_input_value_name
--                                               );
         l_element_name                                          :=
            get_element_name(
               p_element_type_id      => l_element_type_id
              ,p_effective_date       => g_effective_date
            );
         g_tab_pen_ele_ids(l_element_type_id).element_type_id    :=
                                                             l_element_type_id;
         g_tab_pen_ele_ids(l_element_type_id).element_name       :=
                                                                l_element_name;
--         g_tab_pen_ele_ids(l_element_type_id).input_value_name := l_input_value_name;
--         g_tab_pen_ele_ids(l_element_type_id).input_value_id := l_input_value_id;

         get_eeit_info(
            p_element_type_id       => l_element_type_id
           ,p_information_type      => 'PQP_GB_PENSION_SCHEME_INFO'
           ,p_rec_eeit_info         => l_rec_eeit_info
         );
         l_scheme_prefix                                         :=
                                             l_rec_eeit_info.eei_information18;
         l_template_pens_category                                :=
                                              l_rec_eeit_info.eei_information4;
         g_tab_eei_info(l_element_type_id)                       :=
                                                               l_rec_eeit_info;

         IF g_debug
         THEN
            l_proc_step    := 80;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

--         l_template_id := get_template_id
--                            (p_template_name => 'GB Pensions'
--                            ,p_business_group_id => g_business_group_id
--                            ,p_template_type => 'U'
--                            );

         get_pen_balance_details(
            p_element_type_id        => l_element_type_id
           ,p_base_name              => l_scheme_prefix
           ,p_pension_category       => l_template_pens_category
           ,p_psi_pens_category      => l_psi_pens_category
           ,p_rec_pen_bal_dtls       => l_rec_pen_bal_dtls
         );

         IF l_psi_pens_category = 'CLASSIC'
         THEN
            -- Classic Scheme store the pension balance information
            g_tab_clas_pen_bal_dtls(l_element_type_id)    :=
                                                           l_rec_pen_bal_dtls;
         ELSIF l_psi_pens_category = 'PREMIUM'
         THEN
            -- Premium scheme store the pension balance information
            g_tab_prem_pen_bal_dtls(l_element_type_id)    :=
                                                           l_rec_pen_bal_dtls;
         ELSIF l_psi_pens_category = 'CLASSPLUS'
         THEN
            -- Classic Plus scheme store the pension balance information
            g_tab_clap_pen_bal_dtls(l_element_type_id)    :=
                                                           l_rec_pen_bal_dtls;
         ELSIF l_psi_pens_category = 'PARTNER'
         THEN
            -- Partnership scheme store the pension balance information
            g_tab_part_pen_bal_dtls(l_element_type_id)    :=
                                                           l_rec_pen_bal_dtls;
         /* For Nuvos */
         ELSIF l_psi_pens_category = 'NUVOS'
         THEN
            -- Nuvos scheme store the pension balance information
            g_tab_nuvos_pen_bal_dtls(l_element_type_id)    :=
                                                           l_rec_pen_bal_dtls;
         END IF; -- End if of pension category check ...

         IF g_debug
         THEN
            l_proc_step    := 90;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         IF     g_tab_eei_info.EXISTS(l_element_type_id)
            -- AND g_tab_eei_info(l_element_type_id).eei_information8 = 'COMP'
            -- Above line is commented as we dont check for COMP at OCP level,
            -- pick all OCPs, check COMP at AVC level
            AND l_template_pens_category = 'OCP'
         THEN
            -- This is a money purchase scheme OCP
            -- Get all the AVCs associated with it
            get_avc_pen_balance_details(
               p_associated_ocp_ele_id      => l_element_type_id
              ,p_information_type           => 'PQP_GB_PENSION_SCHEME_INFO'
              ,p_tab_avc_pen_bal_dtls       => l_tab_avc_pen_bal_dtls
            );
            g_tab_avc_pen_bal_dtls    := l_tab_avc_pen_bal_dtls;
         END IF;

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
            DEBUG('Scheme Prefix: ' || l_scheme_prefix);
            DEBUG('PSI Pension Category: ' || l_psi_pens_category);
         END IF;

         i                                                       :=
                                                  g_tab_pen_sch_map_cv.NEXT(i);
      END LOOP;

      -- Get NI element type ID and category input value ID
      IF g_debug
      THEN
         l_proc_step    := 100;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      g_ni_ele_type_id          :=
         pqp_utilities.pqp_get_element_type_id(
            p_business_group_id      => NULL -- look for seeded
           ,p_legislation_code       => g_legislation_code
           ,p_effective_date         => g_effective_date
           ,p_element_type_name      => 'NI'
           ,p_error_code             => l_error_code
           ,p_message                => l_error_message
         );

      IF g_debug
      THEN
         l_proc_step    := 110;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_ni_ele_type_id: ' || g_ni_ele_type_id);
      END IF;

      IF g_ni_ele_type_id IS NOT NULL
      THEN
         -- Get the input value id as well
         g_ni_category_iv_id    :=
            get_input_value_id(
               p_element_type_id       => g_ni_ele_type_id
              ,p_effective_date        => g_effective_date
              ,p_input_value_name      => 'Category'
              ,p_element_name          => 'NI'
            );

         IF g_debug
         THEN
            l_proc_step    := 100;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('g_ni_category_iv_id: ' || g_ni_category_iv_id);
         END IF;

         g_ni_pension_iv_id     :=
            get_input_value_id(
               p_element_type_id       => g_ni_ele_type_id
              ,p_effective_date        => g_effective_date
              ,p_input_value_name      => 'Pension'
              ,p_element_name          => 'NI'
            );

         IF g_debug
         THEN
            l_proc_step    := 110;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('g_ni_pension_iv_id: ' || g_ni_pension_iv_id);
         END IF;
      END IF; -- End if of g_ni_ele_type_id is not null check ...

              -- Get the NI E UEL and ET defined balance ids

      g_ni_euel_bal_type_id     :=
         get_balance_type_id(
            p_balance_name           => 'NI E Able UEL'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      IF g_ni_euel_bal_type_id IS NOT NULL
      THEN
         g_ni_euel_ptd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_ni_euel_bal_type_id
              ,p_balance_dimension_id      => g_procptd_dimension_id
            );
      END IF; -- End if of g_ni_euel_bal_type_id is not null check ...

      g_ni_eet_bal_type_id      :=
         get_balance_type_id(
            p_balance_name           => 'NI E Able ET'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      IF g_ni_eet_bal_type_id IS NOT NULL
      THEN
         g_ni_eet_ptd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_ni_eet_bal_type_id
              ,p_balance_dimension_id      => g_procptd_dimension_id
            );
      END IF; -- End if of g_ni_eet_bal_type_id is not null check ...

      --Bug 8517132: Added for NI UAP
      g_ni_euap_bal_type_id     :=
         get_balance_type_id(
            p_balance_name           => 'NI E Able UAP'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      IF g_ni_euap_bal_type_id IS NOT NULL
      THEN
         g_ni_euap_ptd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_ni_euap_bal_type_id
              ,p_balance_dimension_id      => g_procptd_dimension_id
            );
      END IF; -- End if of g_ni_euap_bal_type_id is not null check ...

      IF g_debug
      THEN
         l_proc_step    := 120;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_ni_euel_bal_type_id: ' || g_ni_euel_bal_type_id);
         DEBUG('g_ni_euel_ptd_bal_id: ' || g_ni_euel_ptd_bal_id);
         DEBUG('g_ni_eet_bal_type_id: ' || g_ni_eet_bal_type_id);
         DEBUG('g_ni_eet_ptd_bal_id: ' || g_ni_eet_ptd_bal_id);
         --Bug 8517132: Added for NI UAP
         DEBUG('g_ni_euap_bal_type_id: ' || g_ni_euap_bal_type_id);
         DEBUG('g_ni_euap_ptd_bal_id: ' || g_ni_euap_ptd_bal_id);
      END IF;

      -- Get the balance type ids for generic balance
      -- Total BuyBack Contributions
      -- Commenting the below code as not used
/*      g_tot_byb_cont_bal_id     :=
         get_balance_type_id(
            p_balance_name           => 'Total BuyBack Contributions'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      IF g_tot_byb_cont_bal_id IS NOT NULL
      THEN
         g_tot_byb_ptd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_tot_byb_cont_bal_id
              ,p_balance_dimension_id      => g_procptd_dimension_id
            );
      END IF; -- End if of g_tot_byb_cont_bal_id is not null check ...

      IF g_debug
      THEN
         l_proc_step    := 130;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_tot_byb_cont_bal_id: ' || g_tot_byb_cont_bal_id);
         DEBUG('g_tot_byb_ptd_bal_id: ' || g_tot_byb_ptd_bal_id);
      END IF; */

      -- Get the balance type ids for generic balance
      -- Pensrv Added Years Contribution

      g_tot_ayr_cont_bal_id     :=
         get_balance_type_id(
            p_balance_name           => 'Pensrv Added Years Contribution'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      IF g_tot_ayr_cont_bal_id IS NOT NULL
      THEN
         g_tot_ayr_ptd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_tot_ayr_cont_bal_id
              ,p_balance_dimension_id      => g_procptd_dimension_id
            );
         -- For 115.29
         g_tot_ayr_ytd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_tot_ayr_cont_bal_id
              ,p_balance_dimension_id      => g_penytd_dimension_id
            );

      END IF; -- End if of g_tot_byb_cont_bal_id is not null check ...

      IF g_debug
      THEN
         l_proc_step    := 131;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_tot_ayr_cont_bal_id: ' || g_tot_ayr_cont_bal_id);
         DEBUG('g_tot_ayr_ptd_bal_id: ' || g_tot_ayr_ptd_bal_id);
         -- For 115.29
         DEBUG('g_tot_ayr_ytd_bal_id: ' || g_tot_ayr_ytd_bal_id);
      END IF;


      -- Get the balance type ids for generic balance
      -- Pensrv Added Years Family Benefit Contribution

      g_tot_ayr_fb_cont_bal_id     :=
         get_balance_type_id(
            p_balance_name           => 'Pensrv Added Years Family Benefit Contribution'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      IF g_tot_ayr_fb_cont_bal_id IS NOT NULL
      THEN
         g_tot_ayr_fb_ptd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_tot_ayr_fb_cont_bal_id
              ,p_balance_dimension_id      => g_procptd_dimension_id
            );
         -- For 115.29
          g_tot_ayr_fb_ytd_bal_id    :=
             get_defined_balance(
               p_balance_type_id           => g_tot_ayr_fb_cont_bal_id
              ,p_balance_dimension_id      => g_penytd_dimension_id
            );

      END IF; -- End if of g_tot_byb_cont_bal_id is not null check ...

      IF g_debug
      THEN
         l_proc_step    := 132;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_tot_ayr_fb_cont_bal_id: ' || g_tot_ayr_fb_cont_bal_id);
         DEBUG('g_tot_ayr_fb_ptd_bal_id: ' || g_tot_ayr_fb_ptd_bal_id);
         DEBUG('g_tot_ayr_fb_ytd_bal_id: ' || g_tot_ayr_fb_ytd_bal_id);
      END IF;

      /* Begin For Nuvos Change */
      -- Get the balance type ids for generic balance
      -- Pensrv APAVC Contribution

      g_tot_apavc_cont_bal_id     :=
         get_balance_type_id(
            p_balance_name           => 'Pensrv APAVC Contribution'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      IF g_tot_ayr_cont_bal_id IS NOT NULL
      THEN
         g_tot_apavc_ptd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_tot_apavc_cont_bal_id
              ,p_balance_dimension_id      => g_procptd_dimension_id
            );
         -- For 115.29
         g_tot_apavc_ytd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_tot_apavc_cont_bal_id
              ,p_balance_dimension_id      => g_penytd_dimension_id
            );
      END IF; -- End if of g_tot_byb_cont_bal_id is not null check ...

      IF g_debug
      THEN
         l_proc_step    := 133;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_tot_apavc_cont_bal_id: ' || g_tot_apavc_cont_bal_id);
         DEBUG('g_tot_apavc_ptd_bal_id: ' || g_tot_apavc_ptd_bal_id);
         -- For 115.29
         DEBUG('g_tot_apavc_ytd_bal_id: ' || g_tot_apavc_ytd_bal_id);
      END IF;

      -- Get the balance type ids for generic balance
      -- Pensrv APAVC Contribution

      g_tot_apavcm_cont_bal_id     :=
         get_balance_type_id(
            p_balance_name           => 'Pensrv APAVCM Contribution'
           ,p_business_group_id      => NULL
           ,p_legislation_code       => g_legislation_code
         );

      IF g_tot_apavcm_cont_bal_id IS NOT NULL
      THEN
         g_tot_apavcm_ptd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_tot_apavcm_cont_bal_id
              ,p_balance_dimension_id      => g_procptd_dimension_id
            );
         -- For 115.29
         g_tot_apavcm_ytd_bal_id    :=
            get_defined_balance(
               p_balance_type_id           => g_tot_apavcm_cont_bal_id
              ,p_balance_dimension_id      => g_penytd_dimension_id
            );
      END IF; -- End if of g_tot_byb_cont_bal_id is not null check ...

      IF g_debug
      THEN
         l_proc_step    := 133;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('g_tot_apavcm_cont_bal_id: ' || g_tot_apavcm_cont_bal_id);
         DEBUG('g_tot_apavcm_ptd_bal_id: ' || g_tot_apavcm_ptd_bal_id);
         -- For 115.29
          DEBUG('g_tot_apavcm_ytd_bal_id: ' || g_tot_apavcm_ytd_bal_id);
      END IF;

      /* END For Nuvos Change */

--      IF g_extract_type = 'PERIODIC' THEN
--        IF g_debug
--        THEN
--          l_proc_step := 80;
--          debug(l_proc_name, l_proc_step);
--        END IF;
--        -- populated dated table ids
--        set_dated_table_collection;
--
--        -- populate event group colleciton
--        IF g_debug
--        THEN
--          l_proc_step := 90;
--          debug(l_proc_name, l_proc_step);
--        END IF;
--        set_event_group_collection;
--      END IF; -- End if of extract type = periodic check ...


      IF g_debug
      THEN
         l_proc_step    := 140;
         DEBUG('g_business_group_id: ' || g_business_group_id);
         DEBUG('g_effective_date: '
            || TO_CHAR(g_effective_date, 'DD/MON/YYYY'));
         DEBUG('g_extract_type: ' || g_extract_type);
--        DEBUG('g_active_asg_sts_id: '||g_active_asg_sts_id);
--        DEBUG('g_terminate_asg_sts_id: '||g_terminate_asg_sts_id);
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
   END set_earnings_history_globals;

-- This function is used to evaluate assignments that
-- qualify for penserver earnings history interface
-- ----------------------------------------------------------------------------
-- |---------------------< chk_earnings_history_criteria >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_earnings_history_criteria(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      --
      l_proc_name             VARCHAR2(80)
                            := g_proc_name || 'chk_earnings_history_criteria';
      l_proc_step             PLS_INTEGER;
      l_include_flag          VARCHAR2(10);
      l_debug                 VARCHAR2(10);
      i                       NUMBER;
      l_effective_end_date    DATE;
      l_return                VARCHAR2(10);
      l_rec_ele_ent_details   r_ele_ent_details;
      l_value                 NUMBER;
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
         DEBUG(
               'ben_ext_person.g_effective_date: '
            || TO_CHAR(ben_ext_person.g_effective_date, 'DD/MON/YYYY')
         );
         DEBUG(
               'ben_ext_person.g_person_ext_dt: '
            || TO_CHAR(ben_ext_person.g_person_ext_dt, 'DD/MON/YYYY')
         );
      END IF;

      l_include_flag    := 'N';

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
         set_earnings_history_globals(
            p_business_group_id      => p_business_group_id
           ,p_effective_date         => ben_ext_person.g_effective_date
         );

         IF g_debug
         THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- Raise Extract Exceptions
         pqp_gb_psi_functions.raise_extract_exceptions('S');
      END IF; -- End if of business group id is null check ...

--       IF g_extract_type = 'PERIODIC' THEN
--         g_effective_date := p_effective_date;
--         IF g_debug
--         THEN
--           debug('g_effective_date: '||TO_CHAR(g_effective_date, 'DD/MON/YYYY'));
--         END IF;
--       END IF;

      IF p_effective_date BETWEEN g_effective_start_date AND g_effective_end_date
      THEN
         l_effective_end_date    := g_effective_end_date;

         IF g_effective_date <> p_effective_date
         THEN
            l_effective_end_date    :=
                                LEAST(g_effective_end_date, p_effective_date);
         END IF;

         -- Check penserver basic criteria
         IF g_debug
         THEN
            l_proc_step    := 50;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG(
                  'l_effective_end_date: '
               || TO_CHAR(l_effective_end_date, 'DD/MM/YYYY')
            );
         END IF;

         g_person_dtl            := NULL;
         g_assignment_dtl        := NULL;
         l_include_flag          :=
            pqp_gb_psi_functions.chk_penserver_basic_criteria(
               p_business_group_id      => g_business_group_id
              ,p_effective_date         => l_effective_end_date
              ,p_assignment_id          => p_assignment_id
              ,p_person_dtl             => g_person_dtl
              ,p_assignment_dtl         => g_assignment_dtl
            );

         IF NVL(g_assignment_id, hr_api.g_number) <> p_assignment_id
         THEN
            clear_asg_cache;
            g_assignment_id    := p_assignment_id;
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 60;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_include_flag: ' || l_include_flag);
            DEBUG('g_extract_type: ' || g_extract_type);
            DEBUG('Person ID: ' || g_person_dtl.person_id);
            DEBUG('Full Name: ' || g_person_dtl.full_name);
            DEBUG('Assignment Number: ' || g_assignment_dtl.assignment_number);
         END IF;

         IF l_include_flag = 'Y'
         THEN
            -- Check earnings history criteria
            l_return    :=
               get_pen_scheme_memb(
                  p_assignment_id             => p_assignment_id
                 ,p_effective_start_date      => g_effective_start_date
                 ,p_effective_end_date        => l_effective_end_date
                 ,p_tab_pen_sch_map_cv        => g_tab_pen_sch_map_cv
                 ,p_rec_ele_ent_details       => l_rec_ele_ent_details
               );
            g_member    := l_return;

            IF l_return = 'N'
            THEN
               IF g_debug
               THEN
                  l_proc_step    := 75;
                  DEBUG(l_proc_name, l_proc_step);
               END IF;

               l_value    :=
                  pqp_gb_psi_functions.raise_extract_warning(
                     p_error_number      => 93775
                    ,p_error_text        => 'BEN_93775_EXT_PSI_NOT_PEN_MEMB'
                    ,p_token1            => p_assignment_id
                    ,p_token2            => fnd_date.date_to_displaydt(g_effective_date)
                  );
            END IF;
         END IF; -- End if of l_include_flag is Y check ...

--         ELSIF g_extract_type = 'PERIODIC' THEN
--
--           IF g_debug
--           THEN
--             l_proc_step := 80;
--             debug(l_proc_name, l_proc_step);
--
--           END IF;
--
--           l_include_flag := chk_ern_periodic_criteria
--                               (p_assignment_id => p_assignment_id);
--           IF l_include_flag = 'Y' THEN
--             NULL;
--           END IF;
--        END IF; -- End if of g_extract_type = 'CUTOVER' check ...
      END IF; -- termination date within extract run dates check  ...

      -- For Bug 7297812. For every Assignment get the latest assignment action id
      -- in the given date range

       IF l_include_flag = 'Y'
         THEN
             g_asst_action_id := get_latest_action_id(p_assignment_id,g_effective_start_date,l_effective_end_date);
             IF g_asst_action_id is null
             then
               g_check_balance := 'N';  -- added for bug 8425023
             else
               g_check_balance := 'Y';
              end if;

          END IF;

      IF g_debug
      THEN
         l_proc_step    := 80;
         DEBUG('l_return: ' || l_return);
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
   END chk_earnings_history_criteria;

-- This function returns the current NI category
-- for an assignment
-- ----------------------------------------------------------------------------
-- |------------------------------< get_ni_category >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ni_category(p_assignment_id IN NUMBER)
      RETURN VARCHAR2
   IS
      --
      l_proc_name             VARCHAR2(80)
                                          := g_proc_name || 'get_ni_category';
      l_proc_step             PLS_INTEGER;
      l_ni_category           VARCHAR2(10);
      l_return                VARCHAR2(10);
      l_rec_ele_ent_details   r_ele_ent_details;
      l_value                 NUMBER;
      l_effective_end_date    DATE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_ni_category           := NULL;
      l_effective_end_date    := g_effective_end_date;

      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      -- Get the NI element entry details for this assignment
      l_return                :=
         get_ele_ent_details(
            p_assignment_id             => p_assignment_id
           ,p_effective_start_date      => g_effective_start_date
           ,p_effective_end_date        => l_effective_end_date
           ,p_element_type_id           => g_ni_ele_type_id
           ,p_rec_ele_ent_details       => l_rec_ele_ent_details
         );

      IF l_return = 'Y'
      THEN
         -- NI element exists
         -- Find the NI category
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         l_ni_category           :=
            get_screen_entry_value(
               p_element_entry_id          => l_rec_ele_ent_details.element_entry_id
              ,p_effective_start_date      => l_rec_ele_ent_details.effective_start_date
              ,p_effective_end_date        => l_rec_ele_ent_details.effective_end_date
              ,p_input_value_id            => g_ni_category_iv_id
            );
         g_ni_ele_ent_details    := l_rec_ele_ent_details;
      ELSE -- raise person data warning
         l_value    :=
            pqp_gb_psi_functions.raise_extract_warning(
               p_error_number      => 94480
              ,p_error_text        => 'BEN_94480_EXT_PSI_NO_NI_ELEMT'
              ,p_token1            => p_assignment_id
              ,p_token2            => fnd_date.date_to_displaydt(g_effective_date)
            );
      END IF; -- End if of ni element entry exists check ...

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG(l_proc_name, l_proc_step);
         DEBUG('l_ni_category: ' || l_ni_category);
         debug_exit(l_proc_name);
      END IF;

      RETURN l_ni_category;
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
   END get_ni_category;

-- This function returns the contracted out earnings figure
-- for an assignment
-- ----------------------------------------------------------------------------
-- |--------------------------< get_contracted_out_earnings >-----------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_contracted_out_earnings(p_assignment_id IN NUMBER
                                       ,p_ptd_balance   IN BOOLEAN DEFAULT FALSE) -- For Bug 5941475
      RETURN NUMBER
   IS
      --
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

      l_proc_name                VARCHAR2(80)
                               := g_proc_name || 'get_contracted_out_earnings';
      l_proc_step                PLS_INTEGER;
      l_rec_screen_ent_val       csr_get_screen_ent_val%ROWTYPE;
      l_tab_ni_cont_out_bals     t_varchar2;
      l_effective_end_date       DATE;
      l_ni_category              pay_element_entry_values_f.screen_entry_value%TYPE;
      l_ni_pension               pay_element_entry_values_f.screen_entry_value%TYPE;
      i                          NUMBER;
      l_ni_bal_name              t_varchar2;
      l_return                   VARCHAR2(10);
      l_index                    NUMBER;
      l_balance_type_id          NUMBER;
      l_defined_balance_id       NUMBER;
      l_ni_cont_out_earn         NUMBER;
      l_total_ni_cont_out_earn   NUMBER;
      l_element_entry_id         NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_effective_end_date        := g_effective_end_date;

      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      l_element_entry_id          := g_ni_ele_ent_details.element_entry_id;
      l_total_ni_cont_out_earn    := 0;
      l_ni_cont_out_earn          := 0;

      IF l_element_entry_id IS NOT NULL
      THEN
         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_element_entry_id: ' || l_element_entry_id);
         END IF;

         -- Get all the category / pension details for this NI element
         -- entry id
         OPEN csr_get_screen_ent_val(
                l_element_entry_id
               ,g_ni_category_iv_id
               ,g_effective_start_date
               ,l_effective_end_date
                                    );

         LOOP
            FETCH csr_get_screen_ent_val INTO l_rec_screen_ent_val;
            EXIT WHEN csr_get_screen_ent_val%NOTFOUND;

            IF g_debug
            THEN
               l_proc_step    := 30;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG(
                     'l_rec_screen_ent_val.screen_entry_value: '
                  || l_rec_screen_ent_val.screen_entry_value
               );
               DEBUG(
                     'l_rec_screen_ent_val.effective_start_date: '
                  || TO_CHAR(
                        l_rec_screen_ent_val.effective_start_date
                       ,'DD/MM/YYYY'
                     )
               );
               DEBUG(
                     'l_rec_screen_ent_val.effective_end_date: '
                  || TO_CHAR(l_rec_screen_ent_val.effective_end_date
                       ,'DD/MM/YYYY')
               );
            END IF;

            l_ni_category    := l_rec_screen_ent_val.screen_entry_value;

            IF l_ni_category = 'E'
            THEN
               -- NI E category exists for this assignment
               -- for this extract period
               g_ni_e_cat_exists    := 'Y';
            END IF;

            -- Get the NI pension info
            l_ni_pension     :=
               get_screen_entry_value(
                  p_element_entry_id          => g_ni_ele_ent_details.element_entry_id
                 ,p_effective_start_date      => l_rec_screen_ent_val.effective_start_date
                 ,p_effective_end_date        => l_rec_screen_ent_val.effective_end_date
                 ,p_input_value_id            => g_ni_pension_iv_id
               );

            IF g_debug
            THEN
               l_proc_step    := 40;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_ni_pension: ' || l_ni_pension);
            END IF;

            IF l_ni_pension IN('C', 'M') -- contracted out
            THEN
               -- We are interested in this category only
               -- if it is contracted out
               l_ni_category       := l_rec_screen_ent_val.screen_entry_value;
               -- Get the balance information
               i                   := 1;
               l_ni_bal_name(i)    := 'NI ' || l_ni_category || ' Able UEL';
               i                   := i + 1;
               l_ni_bal_name(i)    := 'NI ' || l_ni_category || ' Able ET';
               --Bug 8517132: Added for NI UAP
               i                   := i + 1;
               l_ni_bal_name(i)    := 'NI ' || l_ni_category || ' Able UAP';

               i                   := l_ni_bal_name.FIRST;

               WHILE i IS NOT NULL
               LOOP
                  l_return    :=
                     chk_value_in_collection(
                        p_collection_name      => l_tab_ni_cont_out_bals
                       ,p_value                => l_ni_bal_name(i)
                       ,p_index                => l_index
                     );

                  IF l_return = 'N'
                  THEN
                     l_return    :=
                        chk_value_in_collection(
                           p_collection_name      => g_tab_ni_cont_out_bals
                          ,p_value                => l_ni_bal_name(i)
                          ,p_index                => l_index
                        );

                     IF l_return = 'Y'
                     THEN
                        l_defined_balance_id    := l_index;
                     ELSE
                        l_balance_type_id       :=
                           get_balance_type_id(
                              p_balance_name           => l_ni_bal_name(i)
                             ,p_business_group_id      => NULL
                             ,p_legislation_code       => g_legislation_code
                           );

                        -- For bug 7428527
                        IF l_balance_type_id is not null
                        then

                        l_defined_balance_id    :=
                           get_defined_balance(
                              p_balance_type_id           => l_balance_type_id
                             ,p_balance_dimension_id      => g_procptd_dimension_id
                           );
                        end if;

                        IF g_debug
                        THEN
                           l_proc_step    := 50;
                           DEBUG(l_proc_name, l_proc_step);
                           DEBUG(
                              'l_ni_bal_name( ' || i || ')'
                              || l_ni_bal_name(i)
                           );
                           DEBUG('l_defined_balance_id: '
                              || l_defined_balance_id);
                           DEBUG('l_balance_type_id: ' || l_balance_type_id);
                        END IF;

                        -- Store it in the NI contracted out global collection
                        IF l_defined_balance_id IS NOT NULL
                        THEN
                           g_tab_ni_cont_out_bals(l_defined_balance_id)    :=
                                                             l_ni_bal_name(i);
                        END IF;
                     END IF; -- End if of l_return = 'Y' check ...

                     IF g_debug
                     THEN
                        l_proc_step    := 60;
                        DEBUG(l_proc_name, l_proc_step);
                        DEBUG('l_defined_balance_id: '
                           || l_defined_balance_id);
                     END IF;

                     IF l_defined_balance_id IS NOT NULL
                     THEN
                        l_tab_ni_cont_out_bals(l_defined_balance_id)    :=
                                                             l_ni_bal_name(i);
                     END IF;
                  END IF; -- if not already in local collection check ...

                  i           := l_ni_bal_name.NEXT(i);
               END LOOP;
            END IF; -- End if of ni pension is C check ...
         END LOOP;

         CLOSE csr_get_screen_ent_val;
      END IF; -- End if of element entry id is not null check ...

      i                           := l_tab_ni_cont_out_bals.FIRST;

      WHILE i IS NOT NULL
      LOOP
         IF g_debug
         THEN
            l_proc_step    := 70;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_defined_balance_id: ' || i);
            DEBUG('l_balance_name: ' || l_tab_ni_cont_out_bals(i));
         END IF;

         l_ni_cont_out_earn          := 0;
--         BEGIN

         -- For Bug 5941475
         IF NOT p_ptd_balance
         THEN
            l_ni_cont_out_earn          :=
               get_total_ptd_bal_value(
                  p_assignment_id             => p_assignment_id
                 ,p_defined_balance_id        => i
                 ,p_effective_start_date      => g_effective_start_date
                 ,p_effective_end_date        => l_effective_end_date
               );
         ELSE
            l_ni_cont_out_earn   :=
               pay_balance_pkg.get_value(
                  p_defined_balance_id      => i
                 ,p_assignment_id           => p_assignment_id
                 ,p_virtual_date            => l_effective_end_date);

         END IF; -- IF NOT p_ptd_balance

--                pay_balance_pkg.get_value(
--                   p_defined_balance_id      => i
--                  ,p_assignment_id           => p_assignment_id
--                  ,p_virtual_date            => l_effective_end_date);
--          EXCEPTION
--             WHEN NO_DATA_FOUND
--             THEN
--                IF g_debug
--                THEN
--                   DEBUG('No data found exception: ');
--                END IF;
--
--                l_ni_cont_out_earn    := 0;
--          END;

         l_total_ni_cont_out_earn    :=
                                  l_total_ni_cont_out_earn
                                  + l_ni_cont_out_earn;

         IF g_debug
         THEN
            -- For Bug 5941475
            IF NOT p_ptd_balance
            THEN
               l_proc_step    := 80;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_ni_cont_out_earn: ' || l_ni_cont_out_earn);
               DEBUG('l_total_ni_cont_out_earn: ' || l_total_ni_cont_out_earn);
            END IF;

         END IF;

         i                           := l_tab_ni_cont_out_bals.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         -- For Bug 5941475
         IF NOT p_ptd_balance
         THEN
            l_proc_step    := 90;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_total_ni_cont_out_earn: ' || l_total_ni_cont_out_earn);
            debug_exit(l_proc_name);
         END IF;

      END IF;

      RETURN l_total_ni_cont_out_earn;
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
   END get_contracted_out_earnings;

-- This function returns the WPS contributions for an
-- assignment
-- ----------------------------------------------------------------------------
-- |---------------------< get_WPS_contributions >----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_wps_contributions(p_assignment_id IN NUMBER
                                 ,p_ptd_balance   IN   BOOLEAN DEFAULT FALSE)  -- For Bug 5941475
      RETURN NUMBER
   IS
      --
      l_proc_name                VARCHAR2(80)
                                    := g_proc_name || 'get_wps_contributions';
      l_proc_step                PLS_INTEGER;
      l_wps_contribution         NUMBER;
      l_total_wps_contribution   NUMBER;
      l_effective_end_date       DATE;
      l_defined_balance_id       t_number;
      -- For 115.29
      l_pen_defined_balance_id       t_number;
      i                          NUMBER;
      j                          NUMBER;
      l_return                   VARCHAR2(10);
      l_rec_ele_ent_details      r_ele_ent_details;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      -- WPS contributions has feeds from
      -- Classic OCP EES contribution balance and
      -- Classic Buy Back FWD contribution

      l_wps_contribution          := 0;
      l_total_wps_contribution    := 0;
      l_effective_end_date        := g_effective_end_date;
      --Reset to 0
      IF NOT p_ptd_balance
      THEN
         g_ayfwd_bal_conts           := 0;
      END IF;

      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      -- Get the balance information for classic
      -- ocp ees contribution balance

      j                           := g_tab_clas_pen_bal_dtls.FIRST;

      WHILE j IS NOT NULL
      LOOP
         i           := 0;

         -- For 115.29
         IF NOT p_ptd_balance
         THEN     -- get the YTD defined balance id
            IF g_tab_clas_pen_bal_dtls(j).ees_ytd_bal_id IS NOT NULL
            THEN
               i                          := i + 1;
               l_defined_balance_id(i)    :=
                                       g_tab_clas_pen_bal_dtls(j).ees_ytd_bal_id;
            END IF;
            -- Get the balance information for classic
            -- ayr fwd contribution balance
            IF g_tab_clas_pen_bal_dtls(j).ayfwd_ytd_bal_id IS NOT NULL
            THEN
               i                          := i + 1;
               l_defined_balance_id(i)    :=
                                     g_tab_clas_pen_bal_dtls(j).ayfwd_ytd_bal_id;
            END IF;
         ELSE -- get the PTD defined balance id
            IF g_tab_clas_pen_bal_dtls(j).ees_ptd_bal_id IS NOT NULL
            THEN
               i                          := i + 1;
               l_defined_balance_id(i)    :=
                                       g_tab_clas_pen_bal_dtls(j).ees_ptd_bal_id;
            END IF;
            -- Get the balance information for classic
            -- ayr fwd contribution balance
            IF g_tab_clas_pen_bal_dtls(j).ayfwd_ptd_bal_id IS NOT NULL
            THEN
               i                          := i + 1;
               l_defined_balance_id(i)    :=
                                     g_tab_clas_pen_bal_dtls(j).ayfwd_ptd_bal_id;
            END IF;
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- Check whether this person is enrolled into classic scheme

         l_return    :=
            get_ele_ent_details(
               p_assignment_id             => p_assignment_id
              ,p_effective_start_date      => g_effective_start_date
              ,p_effective_end_date        => l_effective_end_date
              ,p_element_type_id           => j
              ,p_rec_ele_ent_details       => l_rec_ele_ent_details
            );
         i           := l_defined_balance_id.FIRST;

         WHILE i IS NOT NULL
         LOOP
            IF g_debug
            THEN
               l_proc_step    := 30;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('i: ' || i);
               DEBUG('j: ' || j);
               DEBUG('l_defined_balance_id: ' || l_defined_balance_id(i));
            END IF;

            l_wps_contribution          := 0;

            IF l_return = 'Y'
            THEN
--           BEGIN

               -- For Bug 5941475
               IF NOT p_ptd_balance
               THEN
                  -- For Bug 7297812
                  l_wps_contribution    :=

                   pay_balance_pkg.get_value(l_defined_balance_id(i),g_asst_action_id);
                     -- For 115.29
                   /*  pay_balance_pkg.get_value(
                        p_defined_balance_id      => l_defined_balance_id(i)
                       ,p_assignment_id           => p_assignment_id
                       ,p_virtual_date            => l_effective_end_date); */
               ELSE
                   -- For Bug 7297812
                   l_wps_contribution    :=
                       pay_balance_pkg.get_value(l_defined_balance_id(i),g_prev_asst_action_id);
                  /*   pay_balance_pkg.get_value(
                        p_defined_balance_id      => l_defined_balance_id(i)
                       ,p_assignment_id           => p_assignment_id
                       ,p_virtual_date            => l_effective_end_date); */

               END IF; --End if Not p_ptd_balance

--               pay_balance_pkg.get_value(
--                   p_defined_balance_id      => l_defined_balance_id(i)
--                  ,p_assignment_id           => p_assignment_id
--                  ,p_virtual_date            => l_effective_end_date);
--          EXCEPTION
--             WHEN NO_DATA_FOUND
--             THEN
--                IF g_debug
--                THEN
--                   DEBUG('No data found exception: ');
--                END IF;
--
--                l_wps_contribution    := 0;
--          END;
               -- Commented the below codes as not used
             /* IF l_defined_balance_id(i) =
                                   g_tab_clas_pen_bal_dtls(j).ayfwd_ptd_bal_id
               THEN
                  -- For Bug 5941475
                  IF NOT p_ptd_balance
                  THEN
                     g_ayfwd_bal_conts    :=
                                           nvl(g_ayfwd_bal_conts,0)
                                           + l_wps_contribution;
                  END IF;

               END IF; */

               IF g_debug
               THEN
                     l_proc_step    := 40;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG('l_wps_contribution: ' || l_wps_contribution);
               END IF;
            END IF; -- End if of l_return = 'Y' check ...

            l_total_wps_contribution    :=
                                  l_total_wps_contribution
                                  + l_wps_contribution;
            i                           := l_defined_balance_id.NEXT(i);
         END LOOP; -- collection loop

         j           := g_tab_clas_pen_bal_dtls.NEXT(j);
      END LOOP; -- Balance collection loop

      IF g_debug
      THEN
         -- For Bug 5941475
         IF NOT p_ptd_balance
         THEN
            l_proc_step    := 50;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_total_wps_contribution: ' || l_total_wps_contribution);
            debug_exit(l_proc_name);

         END IF;
      END IF;

      RETURN l_total_wps_contribution;
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
   END get_wps_contributions;
-- BEGIN For BUG 6082532
-- This function returns the Added Years contributions
-- for an assignment as of the effective date
-- ----------------------------------------------------------------------------
-- |---------------------< get_added_years_conts >-------------------------|
-- ----------------------------------------------------------------------------

/*FUNCTION get_added_years_conts(p_assignment_id IN NUMBER
                                 ,p_ptd_balance   IN   BOOLEAN DEFAULT FALSE)  -- For Bug 5941475
      RETURN NUMBER
   IS
      --
      l_proc_name                VARCHAR2(80)
                                    := g_proc_name || 'get_added_years_conts';
      l_proc_step                PLS_INTEGER;
      l_add_yrs_contributions         NUMBER;
      l_total_add_yrs_contributions   NUMBER;
      l_effective_end_date       DATE;
      l_defined_balance_id       t_number;
      i                          NUMBER;
      j                          NUMBER;
      l_return                   VARCHAR2(10);
      l_rec_ele_ent_details      r_ele_ent_details;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      -- Added Yeras contributions has feeds from
      -- Classic Added Years contribution balance and
      -- Classic Added Years Family benefit contribution

      l_add_yrs_contributions          := 0;
      l_total_add_yrs_contributions    := 0;
      l_effective_end_date        := g_effective_end_date;


      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      -- Get the balance information for classic
      -- Added yeras and classic Added Years Family Benefit contribution balance

      j                           := g_tab_clas_pen_bal_dtls.FIRST;

      WHILE j IS NOT NULL
      LOOP
         i           := 0;

         IF g_tab_clas_pen_bal_dtls(j).ayr_ptd_bal_id IS NOT NULL
         THEN
            i                          := i + 1;
            l_defined_balance_id(i)    :=
                                    g_tab_clas_pen_bal_dtls(j).ayr_ptd_bal_id;
         END IF;

         -- Get the balance information for classic
         -- ayr family benefit contribution balance
         IF g_tab_clas_pen_bal_dtls(j).ayfb_ptd_bal_id IS NOT NULL
         THEN
            i                          := i + 1;
            l_defined_balance_id(i)    :=
                                  g_tab_clas_pen_bal_dtls(j).ayfb_ptd_bal_id;
         END IF;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
         END IF;

         -- Check whether this person is enrolled into classic scheme

         l_return    :=
            get_ele_ent_details(
               p_assignment_id             => p_assignment_id
              ,p_effective_start_date      => g_effective_start_date
              ,p_effective_end_date        => l_effective_end_date
              ,p_element_type_id           => j
              ,p_rec_ele_ent_details       => l_rec_ele_ent_details
            );
         i           := l_defined_balance_id.FIRST;

         WHILE i IS NOT NULL
         LOOP
            IF g_debug
            THEN
               l_proc_step    := 30;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('i: ' || i);
               DEBUG('j: ' || j);
               DEBUG('l_defined_balance_id: ' || l_defined_balance_id(i));
            END IF;

            l_add_yrs_contributions          := 0;

            IF l_return = 'Y'
            THEN
--           BEGIN

               -- For Bug 5941475
               IF NOT p_ptd_balance
               THEN
                  l_add_yrs_contributions    :=
                     get_total_ptd_bal_value(
                        p_assignment_id             => p_assignment_id
                       ,p_defined_balance_id        => l_defined_balance_id(i)
                       ,p_effective_start_date      => g_effective_start_date
                       ,p_effective_end_date        => l_effective_end_date
                     );
               ELSE
                   l_add_yrs_contributions    :=
                     pay_balance_pkg.get_value(
                        p_defined_balance_id      => l_defined_balance_id(i)
                       ,p_assignment_id           => p_assignment_id
                       ,p_virtual_date            => l_effective_end_date);

               END IF; --End if Not p_ptd_balance

               IF l_defined_balance_id(i) =
                                   g_tab_clas_pen_bal_dtls(j).ayfb_ptd_bal_id
               THEN
                  -- For Bug 5941475
                  IF NOT p_ptd_balance
                  THEN
                     g_ayfb_bal_conts    :=
                                           nvl(g_ayfb_bal_conts,0)
                                           + l_add_yrs_contributions;
                  END IF;

               END IF;

               IF g_debug
               THEN
                  -- For Bug 5941475
                  IF NOT p_ptd_balance
                  THEN
                     l_proc_step    := 40;
                     DEBUG(l_proc_name, l_proc_step);
                     DEBUG('l_add_yrs_contributions: ' || l_add_yrs_contributions);
                     DEBUG('g_ayfb_bal_conts: ' || g_ayfb_bal_conts);

                  END IF;
               END IF;
            END IF; -- End if of l_return = 'Y' check ...

            l_total_add_yrs_contributions    :=
                                  l_total_add_yrs_contributions
                                  + l_add_yrs_contributions;
            i                           := l_defined_balance_id.NEXT(i);
         END LOOP; -- collection loop

         j           := g_tab_clas_pen_bal_dtls.NEXT(j);
      END LOOP; -- Balance collection loop

      IF g_debug
      THEN
         -- For Bug 5941475
         IF NOT p_ptd_balance
         THEN
            l_proc_step    := 50;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_total_add_yrs_contributions: ' || l_total_add_yrs_contributions);
            debug_exit(l_proc_name);

         END IF;
      END IF;

      RETURN l_total_add_yrs_contributions;
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
   END get_added_years_conts; */

-- This function returns the money purchase AVC contributions
-- for an assignment as of the effective date
-- ----------------------------------------------------------------------------
-- |---------------------< get_moneypurchase_conts >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_moneypurchase_conts(p_assignment_id IN NUMBER
                                   ,p_ptd_balance   IN  BOOLEAN DEFAULT FALSE)  -- For Bug 5941475
      RETURN NUMBER
   IS
      --
      l_proc_name                VARCHAR2(80)
                                  := g_proc_name || 'get_moneypurchase_conts';
      l_proc_step                PLS_INTEGER;
      l_effective_end_date       DATE;
      l_mp_contributions         NUMBER;
      l_total_mp_contributions   NUMBER;
      i                          NUMBER;
      l_defined_balance_id       NUMBER;
      -- For 115.29
      l_pen_defined_balance_id       NUMBER;
      l_return                   VARCHAR2(10);
      l_rec_ele_ent_details      r_ele_ent_details;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_effective_end_date        := g_effective_end_date;

      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      l_mp_contributions          := 0;
      l_total_mp_contributions    := 0;
      -- Loop through the AVC balance collection
      -- fetch the balance value only if an avc element entry
      -- exists for this assignment

      i                           := g_tab_avc_pen_bal_dtls.FIRST;

      WHILE i IS NOT NULL
      LOOP
         -- For 115.29
         IF NOT p_ptd_balance
         THEN
            l_defined_balance_id    :=
                                  g_tab_avc_pen_bal_dtls(i).pen_defined_balance_id;
         ELSE
            l_defined_balance_id    :=
                                  g_tab_avc_pen_bal_dtls(i).defined_balance_id;
         END IF;

         l_mp_contributions      := 0;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('i: ' || i);
            DEBUG(
                  'g_tab_avc_pen_bal_dtls(i).balance_name: '
               || g_tab_avc_pen_bal_dtls(i).balance_name
            );
            DEBUG('l_defined_balance_id ' || l_defined_balance_id);
         END IF;

         -- Check whether this person is enrolled into this scheme

         l_return                :=
            get_ele_ent_details(
               p_assignment_id             => p_assignment_id
              ,p_effective_start_date      => g_effective_start_date
              ,p_effective_end_date        => l_effective_end_date
              ,p_element_type_id           => i
              ,p_rec_ele_ent_details       => l_rec_ele_ent_details
            );

         IF l_return = 'Y'
         THEN
            -- For Bug 5941475
            IF NOT p_ptd_balance
            THEN
              -- For Bug 7297812
               l_mp_contributions          :=
                pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_asst_action_id);
              /*    -- For 115.29
               pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                    ,p_assignment_id           => p_assignment_id
                    ,p_virtual_date            => l_effective_end_date); */
              /* get_total_ptd_bal_value(
                     p_assignment_id             => p_assignment_id
                    ,p_defined_balance_id        => l_defined_balance_id
                    ,p_effective_start_date      => g_effective_start_date
                    ,p_effective_end_date        => l_effective_end_date
                  ); */

            ELSE
               l_mp_contributions          :=
              -- For Bug 7297812
               pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_prev_asst_action_id);
                /*  pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                    ,p_assignment_id           => p_assignment_id
                    ,p_virtual_date            => l_effective_end_date); */

            END IF; --End if Not p_ptd_balance
--                pay_balance_pkg.get_value(
--                   p_defined_balance_id      => l_defined_balance_id
--                  ,p_assignment_id           => p_assignment_id
--                  ,p_virtual_date            => l_effective_end_date);
            l_total_mp_contributions    :=
                                  l_total_mp_contributions
                                  + l_mp_contributions;
         END IF; -- End if of element entry exists check ...

         IF g_debug
         THEN
            -- For Bug 5941475
            IF NOT p_ptd_balance
            THEN
               l_proc_step    := 30;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_mp_contributions: ' || l_mp_contributions);
               DEBUG('l_total_mp_contributions: ' || l_total_mp_contributions);
             END IF;

          END IF;

         i                       := g_tab_avc_pen_bal_dtls.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         -- For Bug 5941475
         IF NOT p_ptd_balance
         THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_total_mp_contributions: ' || l_total_mp_contributions);
            debug_exit(l_proc_name);
         END IF;

      END IF;

      RETURN l_total_mp_contributions;
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
   END get_moneypurchase_conts;

-- This function returns the contribution amount
-- for an assignment and collection as of the effective date
-- ----------------------------------------------------------------------------
-- |---------------------< get_contribution_amount >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_contribution_amount(
      p_assignment_id      IN   NUMBER
     ,p_tab_pen_bal_dtls   IN   t_pen_bal_dtls
     ,p_ptd_balance        IN   BOOLEAN DEFAULT FALSE  -- For Bug 5941475
     ,p_employer_only      IN   BOOLEAN DEFAULT FALSE
   )
      RETURN NUMBER
   IS
      --
      l_proc_name             VARCHAR2(80)
                                  := g_proc_name || 'get_contribution_amount';
      l_proc_step             PLS_INTEGER;
      l_effective_end_date    DATE;
      l_contributions         NUMBER;
      l_total_contributions   NUMBER;
      i                       NUMBER;
      l_defined_balance_id    NUMBER;
      l_return                VARCHAR2(10);
      l_rec_ele_ent_details   r_ele_ent_details;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_effective_end_date     := g_effective_end_date;

      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      l_contributions          := 0;
      l_total_contributions    := 0;
      -- Loop through the balance collection
      -- fetch the balance value only if an element entry
      -- exists for this assignment and element type

      i                        := p_tab_pen_bal_dtls.FIRST;

      WHILE i IS NOT NULL
      LOOP
         IF NOT p_employer_only
         THEN
            -- For 115.29
            IF NOT p_ptd_balance
            THEN
               l_defined_balance_id    := p_tab_pen_bal_dtls(i).ees_ytd_bal_id;
            ELSE
               l_defined_balance_id    := p_tab_pen_bal_dtls(i).ees_ptd_bal_id;
             END IF;
         ELSE
            IF NOT p_ptd_balance
            THEN
               l_defined_balance_id    := p_tab_pen_bal_dtls(i).ers_ytd_bal_id;
            ELSE
               l_defined_balance_id    := p_tab_pen_bal_dtls(i).ers_ptd_bal_id;
             END IF;
         END IF;

         l_contributions    := 0;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('i: ' || i);
            DEBUG(
                  'p_tab_pen_bal_dtls(i).ees_balance_name: '
               || p_tab_pen_bal_dtls(i).ees_balance_name
            );
            DEBUG(
                  'p_tab_pen_bal_dtls(i).ers_balance_name: '
               || p_tab_pen_bal_dtls(i).ers_balance_name
            );
            DEBUG('l_defined_balance_id ' || l_defined_balance_id);
         END IF;

         -- Check whether this person is enrolled into this scheme

         l_return           :=
            get_ele_ent_details(
               p_assignment_id             => p_assignment_id
              ,p_effective_start_date      => g_effective_start_date
              ,p_effective_end_date        => l_effective_end_date
              ,p_element_type_id           => i
              ,p_rec_ele_ent_details       => l_rec_ele_ent_details
            );

         IF l_return = 'Y'
         THEN
            -- For Bug 5941475
            IF NOT p_ptd_balance
            THEN
        -- For Bug 7297812
               l_contributions          :=
               pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_asst_action_id);
               /*  -- For 115.29
                  pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                    ,p_assignment_id           => p_assignment_id
                    ,p_virtual_date            => l_effective_end_date); */

              /*   get_total_ptd_bal_value(
                     p_assignment_id             => p_assignment_id
                    ,p_defined_balance_id        => l_defined_balance_id
                    ,p_effective_start_date      => g_effective_start_date
                    ,p_effective_end_date        => l_effective_end_date
                  ); */
            ELSE
              -- For Bug 7297812
               l_contributions          :=
                 pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_prev_asst_action_id);
                /*  pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                    ,p_assignment_id           => p_assignment_id
                    ,p_virtual_date            => l_effective_end_date); */

            END IF; --End if Not p_ptd_balance

--                pay_balance_pkg.get_value(
--                   p_defined_balance_id      => l_defined_balance_id
--                  ,p_assignment_id           => p_assignment_id
--                  ,p_virtual_date            => l_effective_end_date);
            l_total_contributions    :=
                                        l_total_contributions
                                        + l_contributions;
         END IF; -- End if of element entry exists check ...

         IF g_debug
         THEN
            -- For Bug 5941475
            IF NOT p_ptd_balance
            THEN
               l_proc_step    := 30;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_contributions: ' || l_contributions);
               DEBUG('l_total_contributions: ' || l_total_contributions);
            END IF;

         END IF;

         i                  := p_tab_pen_bal_dtls.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         -- For Bug 5941475
         IF NOT p_ptd_balance
         THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_total_contributions: ' || l_total_contributions);
            debug_exit(l_proc_name);
         END IF;
      END IF;

      RETURN l_total_contributions;
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
   END get_contribution_amount;

/* For Nuvos */
-- This function returns the Nuvos contribution amount
-- for an assignment and collection as of the effective date
-- ----------------------------------------------------------------------------
-- |---------------------< get_nuvos_contribution_amount >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_nuvos_contribution_amount(
      p_assignment_id      IN   NUMBER
     ,p_ptd_balance        IN   BOOLEAN DEFAULT FALSE ) -- For Bug 5941475

      RETURN NUMBER
   IS
      --
      l_proc_name             VARCHAR2(80)
                                  := g_proc_name || 'get_nuvos_contribution_amount';
      l_proc_step             PLS_INTEGER;
      l_effective_end_date    DATE;
      l_contributions         NUMBER;
      l_total_contributions   NUMBER;
      i                       NUMBER;
      l_defined_balance_id    NUMBER;
      l_return                VARCHAR2(10);
      l_rec_ele_ent_details   r_ele_ent_details;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_effective_end_date     := g_effective_end_date;

      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      l_contributions          := 0;
      l_total_contributions    := 0;
      -- Loop through the balance collection
      -- fetch the balance value only if an element entry
      -- exists for this assignment and element type

      i                        := g_tab_nuvos_pen_bal_dtls.FIRST;

      WHILE i IS NOT NULL
      LOOP
         IF NOT p_ptd_balance -- For bug 5941475
         THEN
            l_defined_balance_id    := g_tab_nuvos_pen_bal_dtls(i).nuvos_sa_ytd_bal_id;
         ELSE
            l_defined_balance_id    := g_tab_nuvos_pen_bal_dtls(i).nuvos_sa_ptd_bal_id;
         END IF;

         l_contributions    := 0;

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('i: ' || i);
            DEBUG(
                  'g_tab_nuvos_pen_bal_dtls(i).nuvos_sa_balance_name: '
               || g_tab_nuvos_pen_bal_dtls(i).nuvos_sa_balance_name
            );
            DEBUG(
                  'g_tab_nuvos_pen_bal_dtls(i).nuvos_sa_balance_name: '
               || g_tab_nuvos_pen_bal_dtls(i).nuvos_sa_balance_name
            );
            DEBUG('l_defined_balance_id ' || l_defined_balance_id);
         END IF;

         -- Check whether this person is enrolled into this scheme

         l_return           :=
            get_ele_ent_details(
               p_assignment_id             => p_assignment_id
              ,p_effective_start_date      => g_effective_start_date
              ,p_effective_end_date        => l_effective_end_date
              ,p_element_type_id           => i
              ,p_rec_ele_ent_details       => l_rec_ele_ent_details
            );

         IF l_return = 'Y'
         THEN
           IF NOT p_ptd_balance -- For bug 5941475
           THEN
              -- For Bug 7297812
             l_contributions          :=
                 pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_asst_action_id);
                /*  -- For 115.29
                 pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                    ,p_assignment_id           => p_assignment_id
                    ,p_virtual_date            => l_effective_end_date); */

                 /* get_total_ptd_bal_value(
                     p_assignment_id             => p_assignment_id
                    ,p_defined_balance_id        => l_defined_balance_id
                    ,p_effective_start_date      => g_effective_start_date
                    ,p_effective_end_date        => l_effective_end_date
                  ); */
           ELSE
              -- For Bug 7297812
           l_contributions          :=
               pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_prev_asst_action_id);

      /*          pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                    ,p_assignment_id           => p_assignment_id
                    ,p_virtual_date            => l_effective_end_date); */

         END IF; --End if Not p_ptd_balance

          l_total_contributions    :=
                                        l_total_contributions
                                        + l_contributions;
          EXIT;

         END IF; -- End if of element entry exists check ...

         IF g_debug
         THEN
              l_proc_step    := 30;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_contributions: ' || l_contributions);
               DEBUG('l_total_contributions: ' || l_total_contributions);
          END IF;

         i                  := g_tab_nuvos_pen_bal_dtls.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_total_contributions: ' || l_total_contributions);
            debug_exit(l_proc_name);
       END IF;

      RETURN l_total_contributions;
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
   END get_nuvos_contribution_amount;
/*For Nuvos END*/

-- This function returns the contracted out E earnings figure
-- for a given assignment as of an effective date
-- ----------------------------------------------------------------------------
-- |---------------------< get_contracted_out_E_earnings >---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_contracted_out_e_earnings(p_assignment_id IN NUMBER
                                         ,p_ptd_balance   IN BOOLEAN DEFAULT FALSE)  -- For Bug 5941475
      RETURN VARCHAR2
   IS
      --
      l_proc_name             VARCHAR2(80)
                            := g_proc_name || 'get_contracted_out_E_earnings';
      l_proc_step             PLS_INTEGER;
      l_effective_end_date    DATE;
      l_ni_e_earnings         NUMBER;
      l_total_ni_e_earnings   NUMBER;
      i                       NUMBER;
      l_ni_e_def_bal_id       t_number;
      l_defined_balance_id    NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
         DEBUG('p_assignment_id: ' || p_assignment_id);
      END IF;

      l_effective_end_date     := g_effective_end_date;

      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      l_ni_e_earnings          := 0;
      l_total_ni_e_earnings    := 0;

      -- Only proceed with there is a NI E category
      -- for this assignment within the extract period

      IF g_ni_e_cat_exists = 'Y'
      THEN
         i    := 0;

         IF g_ni_euel_ptd_bal_id IS NOT NULL
         THEN
            i                       := i + 1;
            l_ni_e_def_bal_id(i)    := g_ni_euel_ptd_bal_id;
         END IF;

         IF g_ni_eet_ptd_bal_id IS NOT NULL
         THEN
            i                       := i + 1;
            l_ni_e_def_bal_id(i)    := g_ni_eet_ptd_bal_id;
         END IF;

         --Bug 8517132: Added globals for NI UAP
         IF g_ni_euap_ptd_bal_id IS NOT NULL
         THEN
            i                       := i + 1;
            l_ni_e_def_bal_id(i)    := g_ni_euap_ptd_bal_id;
         END IF;

      END IF; -- End if of NI E category exists check ...

      i                        := l_ni_e_def_bal_id.FIRST;

      WHILE i IS NOT NULL
      LOOP
         l_defined_balance_id     := l_ni_e_def_bal_id(i);

         IF g_debug
         THEN
            l_proc_step    := 20;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
         END IF;

         l_ni_e_earnings          := 0;
--         BEGIN

         -- For Bug 5941475
         IF NOT p_ptd_balance
         THEN
            l_ni_e_earnings          :=
               get_total_ptd_bal_value(
                  p_assignment_id             => p_assignment_id
                 ,p_defined_balance_id        => l_defined_balance_id
                 ,p_effective_start_date      => g_effective_start_date
                 ,p_effective_end_date        => l_effective_end_date
               );
         ELSE
            l_ni_e_earnings          :=
               pay_balance_pkg.get_value(
                  p_defined_balance_id      => l_defined_balance_id
                 ,p_assignment_id           => p_assignment_id
                 ,p_virtual_date            => l_effective_end_date);

         END IF; --End if Not p_ptd_balance
--                pay_balance_pkg.get_value(
--                   p_defined_balance_id      => l_defined_balance_id
--                  ,p_assignment_id           => p_assignment_id
--                  ,p_virtual_date            => l_effective_end_date);
--          EXCEPTION
--             WHEN NO_DATA_FOUND
--             THEN
--                IF g_debug
--                THEN
--                   DEBUG('No data found exception: ');
--                END IF;
--
--                l_ni_e_earnings    := 0;
--          END;

         l_total_ni_e_earnings    := l_total_ni_e_earnings + l_ni_e_earnings;

         IF g_debug
         THEN
            -- For Bug 5941475
            IF NOT p_ptd_balance
            THEN
               l_proc_step    := 30;
               DEBUG(l_proc_name, l_proc_step);
               DEBUG('l_ni_e_earnings: ' || l_ni_e_earnings);
               DEBUG('l_total_ni_e_earnings: ' || l_total_ni_e_earnings);
            END IF;

         END IF;

         i                        := l_ni_e_def_bal_id.NEXT(i);
      END LOOP;

      IF g_debug
      THEN
         -- For Bug 5941475
         IF NOT p_ptd_balance
         THEN
            l_proc_step    := 40;
            DEBUG(l_proc_name, l_proc_step);
            DEBUG('l_total_ni_e_earnings: ' || l_total_ni_e_earnings);
            debug_exit(l_proc_name);
         END IF;

      END IF;

      RETURN l_total_ni_e_earnings;
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
   END get_contracted_out_e_earnings;

-- This function is used to get earnings history data
-- for an assignment
-- ----------------------------------------------------------------------------
-- |---------------------< get_earnings_history_data >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_earnings_history_data(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
     ,p_rule_parameter      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      --

      -- Cursor to get actual termination date
      CURSOR csr_get_actual_term_dt(c_effective_date DATE)
      IS
         SELECT actual_termination_date
           FROM per_periods_of_service pps
          WHERE pps.person_id = g_person_dtl.person_id
            AND pps.date_start =
                   (SELECT MAX(pps1.date_start) -- this gets most recent
                      FROM per_periods_of_service pps1
                     WHERE pps1.person_id = g_person_dtl.person_id
                       AND pps1.date_start <= c_effective_date)
            AND pps.actual_termination_date <=
                       last_day(add_months(g_effective_end_date, -1)); -- Bug: 6801704

      l_proc_name            VARCHAR2(80)
                                 := g_proc_name || 'get_earnings_history_data';
      l_proc_step            PLS_INTEGER;
      l_return_value         VARCHAR2(150);
      l_earnings             NUMBER;
      l_effective_end_date   DATE;
      l_defined_balance_id   NUMBER;
      -- For 115.29
      l_pen_defined_balance_id   NUMBER;
      l_field_name           VARCHAR2(240);
      l_value                NUMBER;
      l_actual_term_date     DATE;

      -- For Bug 5941475
      l_current_earnings     NUMBER;
      l_check_current_balance VARCHAR2(10) := 'N';

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

      l_effective_end_date    := g_effective_end_date;

      IF g_effective_date <> ben_ext_person.g_person_ext_dt
      THEN
         l_effective_end_date    :=
                  LEAST(g_effective_end_date, ben_ext_person.g_person_ext_dt);
      END IF;

      IF g_debug
      THEN
         DEBUG(
               'l_effective_end_date: '
            || TO_CHAR(l_effective_end_date, 'DD/MON/YYYY')
         );
      END IF;

      l_earnings              := 0;

      -- For Bug 5941475
      l_current_earnings      := 0;

      OPEN csr_get_actual_term_dt(l_effective_end_date);
      FETCH csr_get_actual_term_dt INTO l_actual_term_date;
      CLOSE csr_get_actual_term_dt;

      IF l_actual_term_date IS NOT NULL
      THEN
         l_check_current_balance := 'Y';
      END IF;

     -- For Bug 7297812

     IF g_debug
     THEN
       DEBUG('g_prev_asst_action_id: '||g_prev_asst_action_id);
       DEBUG('g_prev_assg_id: '||g_prev_assg_id);
     END IF;

     -- For Bug 7297812
     -- For every new assignment check the assignment_action_id in the current period if the employee is
     -- terminated

     IF g_prev_assg_id <> p_assignment_id
     THEN

        g_prev_assg_id := p_assignment_id;
        g_prev_asst_action_id := NULL;

        IF l_check_current_balance = 'Y'
        THEN

          g_prev_asst_action_id := get_latest_action_id(p_assignment_id,trunc(l_effective_end_date,'MONTH'),l_effective_end_date);
          IF g_debug
          THEN
             DEBUG('g_prev_asst_action_id: '||g_prev_asst_action_id);
          END IF;

        END IF;

     END IF;


      -- Call local functions based on rule_parameter value
      IF g_debug
      THEN
         l_proc_step    := 20;
         DEBUG(l_proc_name, l_proc_step);
      END IF;

      IF p_rule_parameter = 'StartDate'
      THEN
         l_return_value    :=
                           fnd_date.date_to_canonical(g_effective_start_date);
      ELSIF p_rule_parameter = 'EndDate'
      THEN

         /*
         OPEN csr_get_actual_term_dt(l_effective_end_date);
         FETCH csr_get_actual_term_dt INTO l_actual_term_date;
         CLOSE csr_get_actual_term_dt;

         IF l_actual_term_date IS NULL
         THEN
            l_actual_term_date    := l_effective_end_date;
         END IF;

         l_return_value    := fnd_date.date_to_canonical(l_actual_term_date);
         */

         -- bugfix : 5948932
         -- The above code was for reporting the actual termination date as the end date.
         -- From this version (115.16) onwards, reverting back to reporting the end date
         -- with the value of the period end date.
         l_return_value    := fnd_date.date_to_canonical(g_effective_end_date);

      ELSIF p_rule_parameter = 'NICategory'
      THEN
         l_return_value    :=
                          get_ni_category(p_assignment_id => p_assignment_id);
         l_return_value    := RPAD(NVL(l_return_value, ' '), 1, ' ');
      ELSIF p_rule_parameter = 'ContractedOut' and g_check_balance = 'Y'
      THEN
         l_field_name    := 'Contracted Out Earnings';
         l_earnings      :=
              get_contracted_out_earnings(p_assignment_id => p_assignment_id);

         -- For Bug 5941475
         IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
         THEN
            l_current_earnings :=
                get_contracted_out_earnings(p_assignment_id => p_assignment_id,
                                            p_ptd_balance   => TRUE);

            IF l_current_earnings <> 0
            THEN
               pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
            END IF;

         END IF; --l_check_current_balance = 'Y'

         IF l_earnings > 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;
      ELSIF p_rule_parameter = 'WPSContributions' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'Classic Scheme WPS Contributions';
         g_ayfwd_bal_conts           := 0;

         IF g_member = 'Y'
         THEN
            l_earnings    :=
                    get_wps_contributions(p_assignment_id => p_assignment_id);

            -- For Bug 5941475
            IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
            THEN
               l_current_earnings :=
                    get_wps_contributions(p_assignment_id => p_assignment_id,
                                          p_ptd_balance   => TRUE);

               IF l_current_earnings <> 0
               THEN
                  pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
               END IF;

            END IF; --End if l_check_current_balance = 'Y'

         END IF; -- End if of is member check ...

         IF l_earnings > 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;
      ELSIF p_rule_parameter = 'AddedYearsContributions' AND g_check_balance = 'Y'
      THEN
         l_field_name            := 'Added Years Contributions';
         g_ayfb_bal_conts        := 0;

         l_defined_balance_id    := g_tot_ayr_ptd_bal_id;
         -- For 115.29
         l_pen_defined_balance_id    := g_tot_ayr_ytd_bal_id;

         IF g_debug
         THEN
            DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
         END IF;

         IF l_defined_balance_id IS NOT NULL
            -- For 115.29
            AND l_pen_defined_balance_id is NOT NULL
            AND g_member = 'Y'
         THEN
--            BEGIN
              -- For Bug 7297812
            l_earnings    :=
             pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_pen_defined_balance_id
                     ,p_assignment_action_id          => g_asst_action_id);
              /*    -- For 115.29
                  pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_pen_defined_balance_id
                     ,p_assignment_id          => p_assignment_id
                     ,p_virtual_date           => l_effective_end_date); */

            /*   get_total_ptd_bal_value(
                  p_assignment_id             => p_assignment_id
                 ,p_defined_balance_id        => l_defined_balance_id
                 ,p_effective_start_date      => g_effective_start_date
                 ,p_effective_end_date        => l_effective_end_date
               ); */

            -- For Bug 5941475
            IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
            THEN
              -- For Bug 7297812
               l_current_earnings :=
               pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_prev_asst_action_id);
                /*  pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_id          => p_assignment_id
                     ,p_virtual_date           => l_effective_end_date); */

               IF l_current_earnings <> 0
               THEN
                  pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
               END IF;

            END IF; --End if l_check_current_balance = 'Y'

--                   pay_balance_pkg.get_value(
--                      p_defined_balance_id      => l_defined_balance_id
--                     ,p_assignment_id           => p_assignment_id
--                     ,p_virtual_date            => l_effective_end_date);
--             EXCEPTION
--                WHEN NO_DATA_FOUND
--                THEN
--                   IF g_debug
--                   THEN
--                      DEBUG('No data found exception: ');
--                   END IF;
--
--                   l_earnings    := 0;
--             END;
         END IF; -- End if of defined balance id is not null check ..
        /* -- BEGIN For BUG 6082532
         IF g_member = 'Y'
         THEN
            l_earnings    :=
                    get_added_years_conts(p_assignment_id => p_assignment_id);

            -- For Bug 5941475
            IF l_check_current_balance = 'Y'
            THEN
               l_current_earnings :=
                    get_added_years_conts(p_assignment_id => p_assignment_id,
                                          p_ptd_balance   => TRUE);

               IF l_current_earnings <> 0
               THEN
                  pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
               END IF;

            END IF; --End if l_check_current_balance = 'Y'

         END IF; -- End if of is member check ...*/
         -- END For BUG 6082532

         IF l_earnings > 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;
      ELSIF p_rule_parameter = 'MoneyPurchase' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'Money Purchase Contributions';

         IF g_member = 'Y'
         THEN
            l_earnings    :=
                  get_moneypurchase_conts(p_assignment_id => p_assignment_id);

            -- For Bug 5941475
            IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
            THEN
               l_current_earnings :=
                     get_moneypurchase_conts(p_assignment_id => p_assignment_id
                                            ,p_ptd_balance   => TRUE);

               IF l_current_earnings <> 0
               THEN
                  pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
               END IF;

            END IF; --End if l_check_current_balance = 'Y'

         END IF; -- End if of is member check ...

         IF l_earnings > 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;
      ELSIF p_rule_parameter = 'ContractedOutE' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'Contracted Out E Earnings';
         l_earnings      :=
            get_contracted_out_e_earnings(p_assignment_id => p_assignment_id);

         -- For Bug 5941475
         IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
         THEN
            l_current_earnings :=
                get_contracted_out_e_earnings(p_assignment_id => p_assignment_id,
                                              p_ptd_balance   => TRUE);

            IF l_current_earnings <> 0
            THEN
               pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
            END IF;

         END IF; --l_check_current_balance = 'Y'

         IF l_earnings > 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;
      ELSIF p_rule_parameter = 'AddedYearsFamilyBenefit' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'Added Years Family Benefit Contributions';

         l_defined_balance_id    := g_tot_ayr_fb_ptd_bal_id;
         -- For 115.29
         l_pen_defined_balance_id    := g_tot_ayr_fb_ytd_bal_id;

         IF g_debug
         THEN
            DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
            -- For 115.29
            DEBUG('l_pen_defined_balance_id: ' || l_defined_balance_id);
         END IF;

         IF l_defined_balance_id IS NOT NULL
            -- For 115.29
            AND l_pen_defined_balance_id IS NOT NULL
            AND g_member = 'Y'
         THEN
--            BEGIN
              -- For Bug 7297812
            l_earnings    :=
            pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_pen_defined_balance_id
                     ,p_assignment_action_id          => g_asst_action_id);
             /*  -- For 115.29
               pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_pen_defined_balance_id
                     ,p_assignment_id          => p_assignment_id
                     ,p_virtual_date           => l_effective_end_date); */
               /* get_total_ptd_bal_value(
                  p_assignment_id             => p_assignment_id
                 ,p_defined_balance_id        => l_defined_balance_id
                 ,p_effective_start_date      => g_effective_start_date
                 ,p_effective_end_date        => l_effective_end_date
               ); */

            -- For Bug 5941475
            IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
            THEN
              -- For Bug 7297812
               l_current_earnings :=
                pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_prev_asst_action_id);
               /*   pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_id          => p_assignment_id
                     ,p_virtual_date           => l_effective_end_date); */

               IF l_current_earnings <> 0
               THEN
                  pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
               END IF;

            END IF; --End if l_check_current_balance = 'Y'

--                   pay_balance_pkg.get_value(
--                      p_defined_balance_id      => l_defined_balance_id
--                     ,p_assignment_id           => p_assignment_id
--                     ,p_virtual_date            => l_effective_end_date);
--             EXCEPTION
--                WHEN NO_DATA_FOUND
--                THEN
--                   IF g_debug
--                   THEN
--                      DEBUG('No data found exception: ');
--                   END IF;
--
--                   l_earnings    := 0;
--             END;
         END IF; -- End if of defined balance id is not null check .

         IF l_earnings > 0
         THEN
            l_return_value    :=
                             TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    :=
                             TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;

      ELSIF p_rule_parameter = 'SchemeContributions' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'Premium and Classic Plus Scheme Contributions';
         IF g_member = 'Y'
         THEN
           -- Get premium scheme contributions
           l_earnings      :=
              get_contribution_amount(
                 p_assignment_id         => p_assignment_id
                ,p_tab_pen_bal_dtls      => g_tab_prem_pen_bal_dtls
              );
--          l_defined_balance_id    := g_prem_pen_bal_dtls.ees_ptd_bal_id;
--
--          IF g_debug
--          THEN
--             DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
--          END IF;
--
--          IF l_defined_balance_id IS NOT NULL AND g_member = 'Y'
--          THEN
-- --            BEGIN
--             l_earnings    :=
--                get_total_ptd_bal_value(
--                   p_assignment_id             => p_assignment_id
--                  ,p_defined_balance_id        => l_defined_balance_id
--                  ,p_effective_start_date      => g_effective_start_date
--                  ,p_effective_end_date        => l_effective_end_date
--                );
--                   pay_balance_pkg.get_value(
--                      p_defined_balance_id      => l_defined_balance_id
--                     ,p_assignment_id           => p_assignment_id
--                     ,p_virtual_date            => l_effective_end_date);
--             EXCEPTION
--                WHEN NO_DATA_FOUND
--                THEN
--                   IF g_debug
--                   THEN
--                      DEBUG('No data found exception: ');
--                   END IF;
--
--                   l_earnings    := 0;
--             END;
--         END IF; -- End if of defined balance id is not null check ...

           -- Get Classic Plus scheme contributions
           l_earnings      :=
                 l_earnings
               + get_contribution_amount(
                    p_assignment_id         => p_assignment_id
                   ,p_tab_pen_bal_dtls      => g_tab_clap_pen_bal_dtls
                 );

         -- For Bug: 6788647
         -- Get Nuvos scheme contributions
           l_earnings      :=
                 l_earnings
               + get_contribution_amount(
                    p_assignment_id         => p_assignment_id
                   ,p_tab_pen_bal_dtls      => g_tab_nuvos_pen_bal_dtls
                 );

           -- For Bug 5941475
           IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
           THEN
              -- Get premium scheme contributions
              l_current_earnings :=
                 get_contribution_amount(
                    p_assignment_id         => p_assignment_id
                   ,p_tab_pen_bal_dtls      => g_tab_prem_pen_bal_dtls
                   ,p_ptd_balance           => TRUE
                 );

              l_current_earnings :=
                 l_current_earnings
                 + get_contribution_amount(
                    p_assignment_id         => p_assignment_id
                   ,p_tab_pen_bal_dtls      => g_tab_clap_pen_bal_dtls
                   ,p_ptd_balance           => TRUE
                 );

              -- For Bug: 6788647
            l_current_earnings :=
                 l_current_earnings
                 + get_contribution_amount(
                    p_assignment_id         => p_assignment_id
                   ,p_tab_pen_bal_dtls      => g_tab_nuvos_pen_bal_dtls
                   ,p_ptd_balance           => TRUE
                 );

              IF l_current_earnings <> 0
              THEN
                 pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
              END IF;

           END IF; --l_check_current_balance = 'Y'

         END IF; -- End if of g_member = 'Y' check ...

--          l_defined_balance_id    := g_clap_pen_bal_dtls.ees_ptd_bal_id;
--
--          IF g_debug
--          THEN
--             DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
--          END IF;
--
--          IF l_defined_balance_id IS NOT NULL AND g_member = 'Y'
--          THEN
-- --            BEGIN
--             l_earnings    :=
--                   l_earnings
--                 + get_total_ptd_bal_value(
--                      p_assignment_id             => p_assignment_id
--                     ,p_defined_balance_id        => l_defined_balance_id
--                     ,p_effective_start_date      => g_effective_start_date
--                     ,p_effective_end_date        => l_effective_end_date
--                   );
--                   pay_balance_pkg.get_value(
--                      p_defined_balance_id      => l_defined_balance_id
--                     ,p_assignment_id           => p_assignment_id
--                     ,p_virtual_date            => l_effective_end_date);
--             EXCEPTION
--                WHEN NO_DATA_FOUND
--                THEN
--                   IF g_debug
--                   THEN
--                      DEBUG('No data found exception: ');
--                   END IF;
--             END;
--         END IF; -- End if of defined balance id is not null check ...

         IF l_earnings > 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;
      ELSIF p_rule_parameter = 'EmployeeContributions' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'Partnership Scheme Employee Contributions';
         IF g_member = 'Y'
         THEN
           l_earnings      :=
              get_contribution_amount(
                 p_assignment_id         => p_assignment_id
                ,p_tab_pen_bal_dtls      => g_tab_part_pen_bal_dtls
              );

            -- For Bug 5941475
            IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
            THEN
               l_current_earnings :=
                  get_contribution_amount(
                     p_assignment_id         => p_assignment_id
                    ,p_tab_pen_bal_dtls      => g_tab_part_pen_bal_dtls
                    ,p_ptd_balance           => TRUE
                  );

               IF l_current_earnings <> 0
               THEN
                  pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
               END IF;

             END IF; --l_check_current_balance = 'Y'

          END IF; -- End if of g_member = 'Y' check ...

--          l_defined_balance_id    := g_part_pen_bal_dtls.ees_ptd_bal_id;
--
--          IF g_debug
--          THEN
--             DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
--          END IF;
--
--          IF l_defined_balance_id IS NOT NULL AND g_member = 'Y'
--          THEN
-- --            BEGIN
--             l_earnings    :=
--                get_total_ptd_bal_value(
--                   p_assignment_id             => p_assignment_id
--                  ,p_defined_balance_id        => l_defined_balance_id
--                  ,p_effective_start_date      => g_effective_start_date
--                  ,p_effective_end_date        => l_effective_end_date
--                );
--                   pay_balance_pkg.get_value(
--                      p_defined_balance_id      => l_defined_balance_id
--                     ,p_assignment_id           => p_assignment_id
--                     ,p_virtual_date            => l_effective_end_date);
--             EXCEPTION
--                WHEN NO_DATA_FOUND
--                THEN
--                   IF g_debug
--                   THEN
--                      DEBUG('No data found exception: ');
--                   END IF;
--
--                   l_earnings    := 0;
--             END;
--         END IF; -- End if of defined balance id is not null check ...

         IF l_earnings > 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;
      ELSIF p_rule_parameter = 'EmployerContributions' AND g_check_balance = 'Y' -- for bug 8555515
      THEN

      IF g_member = 'Y'
      THEN
         l_field_name    := 'Partnership Scheme Employer Contributions';
         l_earnings      :=
            get_contribution_amount(
               p_assignment_id         => p_assignment_id
              ,p_tab_pen_bal_dtls      => g_tab_part_pen_bal_dtls
              ,p_employer_only         => TRUE
            );

         -- For Bug 5941475
         IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
         THEN
            l_current_earnings :=
               get_contribution_amount(
                  p_assignment_id         => p_assignment_id
                 ,p_tab_pen_bal_dtls      => g_tab_part_pen_bal_dtls
                 ,p_ptd_balance           => TRUE
                 ,p_employer_only         => TRUE
               );

            IF l_current_earnings <> 0
            THEN
               pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
            END IF;

         END IF; --l_check_current_balance = 'Y'
       END IF; -- g_member = 'Y'


--          l_defined_balance_id    := g_part_pen_bal_dtls.ers_ptd_bal_id;
--
--          IF g_debug
--          THEN
--             DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
--          END IF;
--
--          IF l_defined_balance_id IS NOT NULL
--          THEN
-- --            BEGIN
--             l_earnings    :=
--                get_total_ptd_bal_value(
--                   p_assignment_id             => p_assignment_id
--                  ,p_defined_balance_id        => l_defined_balance_id
--                  ,p_effective_start_date      => g_effective_start_date
--                  ,p_effective_end_date        => l_effective_end_date
--                );
--                   pay_balance_pkg.get_value(
--                      p_defined_balance_id      => l_defined_balance_id
--                     ,p_assignment_id           => p_assignment_id
--                     ,p_virtual_date            => l_effective_end_date);
--             EXCEPTION
--                WHEN NO_DATA_FOUND
--                THEN
--                   IF g_debug
--                   THEN
--                      DEBUG('No data found exception: ');
--                   END IF;
--
--                   l_earnings    := 0;
--             END;
--         END IF; -- End if of defined balance id is not null check ...

         IF l_earnings > 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    := TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;
      ELSIF p_rule_parameter = 'Scheme' THEN
        l_return_value := TRIM(RPAD(pqp_gb_psi_functions.g_pension_scheme,4,' '));

     /* BEGIN For Nuvos */

     ELSIF p_rule_parameter = 'APAVC' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'APAVC Contribtuions';

         l_defined_balance_id    := g_tot_apavc_ptd_bal_id;
         -- For 115.29
         l_pen_defined_balance_id    := g_tot_apavc_ytd_bal_id;

         IF g_debug
         THEN
            DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
            -- For 115.29
            DEBUG('l_pen_defined_balance_id: ' || l_pen_defined_balance_id);
         END IF;

         IF l_defined_balance_id IS NOT NULL
            AND l_pen_defined_balance_id IS NOT NULL
            AND g_member = 'Y'
         THEN
--            BEGIN
        -- For Bug 7297812
            l_earnings    :=
            pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_pen_defined_balance_id
                     ,p_assignment_action_id          => g_asst_action_id);
             /*  -- For 115.29
               pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_pen_defined_balance_id
                     ,p_assignment_id          => p_assignment_id
                     ,p_virtual_date           => l_effective_end_date); */

            /*   get_total_ptd_bal_value(
                  p_assignment_id             => p_assignment_id
                 ,p_defined_balance_id        => l_defined_balance_id
                 ,p_effective_start_date      => g_effective_start_date
                 ,p_effective_end_date        => l_effective_end_date
               ); */

            -- For Bug 5941475
            IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
            THEN
              -- For Bug 7297812
               l_current_earnings :=
                 pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_prev_asst_action_id);

            /*    pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_id          => p_assignment_id
                     ,p_virtual_date           => l_effective_end_date); */

               IF l_current_earnings <> 0
               THEN
                  pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
               END IF;

            END IF;

         END IF; -- End if of defined balance id is not null check .

         IF l_earnings > 0
         THEN
            l_return_value    :=
                             TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    :=
                             TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;

      -- APAVCM Contributions */
      ELSIF p_rule_parameter = 'APAVCM' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'APAVCM Contribtuions';

         l_defined_balance_id    := g_tot_apavcm_ptd_bal_id;
         -- For 115.29
         l_pen_defined_balance_id    := g_tot_apavcm_ytd_bal_id;

         IF g_debug
         THEN
            DEBUG('l_defined_balance_id: ' || l_defined_balance_id);
            DEBUG('l_pen_defined_balance_id: ' || l_pen_defined_balance_id);
         END IF;

         IF l_defined_balance_id IS NOT NULL
            AND l_pen_defined_balance_id IS NOT NULL
            AND g_member = 'Y'
         THEN
--            BEGIN
              -- For Bug 7297812
            l_earnings    :=
             pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_pen_defined_balance_id
                     ,p_assignment_action_id          => g_asst_action_id);
            /*   -- For 115.29
               pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_pen_defined_balance_id
                     ,p_assignment_id          => p_assignment_id
                     ,p_virtual_date           => l_effective_end_date); */

             /*  get_total_ptd_bal_value(
                  p_assignment_id             => p_assignment_id
                 ,p_defined_balance_id        => l_defined_balance_id
                 ,p_effective_start_date      => g_effective_start_date
                 ,p_effective_end_date        => l_effective_end_date
               ); */

            -- For Bug 5941475
            IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
            THEN
              -- For Bug 7297812
               l_current_earnings :=
                pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_action_id          => g_prev_asst_action_id);
                /*  pay_balance_pkg.get_value(
                     p_defined_balance_id      => l_defined_balance_id
                     ,p_assignment_id          => p_assignment_id
                     ,p_virtual_date           => l_effective_end_date); */

               IF l_current_earnings <> 0
               THEN
                  pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
               END IF;

            END IF;

         END IF; -- End if of defined balance id is not null check .

         IF l_earnings > 0
         THEN
            l_return_value    :=
                             TRIM(TO_CHAR(l_earnings, '099999999.99'));
         ELSIF l_earnings < 0
         THEN
            l_return_value    :=
                             TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
         ELSE
            l_return_value    := RPAD(' ', 12, ' ');
         END IF;

         -- SPN

      ELSIF p_rule_parameter = 'SPN'
      THEN
         l_field_name    := 'Service Period Number';

         l_return_value := get_asg_eit_info(p_assignment_id       => p_assignment_id
                                           ,p_information_type      => 'PQP_GB_PENSERV_SVPN'
                                           );


      ELSIF p_rule_parameter = 'EARNINGS' AND g_check_balance = 'Y'
      THEN
         l_field_name    := 'Pensionable Earnings for Nuvos Members';

         l_earnings :=  get_nuvos_contribution_amount(p_assignment_id => p_assignment_id);

         -- For bug: 5941475
         IF l_check_current_balance = 'Y' AND g_prev_asst_action_id IS NOT NULL
         THEN
            l_current_earnings :=
                  get_nuvos_contribution_amount(
                     p_assignment_id         => p_assignment_id
                    ,p_ptd_balance           => TRUE
                  );

            IF l_current_earnings <> 0
            THEN
               pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'N';
            END IF;

         END IF; --l_check_current_balance = 'Y'

         IF l_earnings >= 0
         THEN
            l_return_value    :=
                             TRIM(TO_CHAR(l_earnings, '099999999.99'));
          ELSIF l_earnings < 0
          THEN
            l_return_value    :=
                             TRIM(TO_CHAR(l_earnings, 'S09999999.99'));
          ELSE
              l_return_value    := RPAD(' ', 12, ' ');
          END IF;

       /* END For Nuvos */

      -- For Bug 5941475
      ELSIF p_rule_parameter = 'Check' THEN

        IF pqp_gb_psi_earnings_history.g_ern_term_exclude_flag = 'Y' and l_check_current_balance = 'Y'
        THEN
           l_return_value := NULL;
        ELSE
           l_return_value := 'INCLUDE';
        END IF;

        pqp_gb_psi_earnings_history.g_ern_term_exclude_flag := 'Y';

      END IF; -- End if of rule parameter check ...

      IF NOT l_earnings BETWEEN -99999999.99 AND 999999999.99
      THEN
         IF g_debug
         THEN
            DEBUG('Maximum length error');
         END IF;

         l_value    :=
            pqp_gb_psi_functions.raise_extract_error(
               p_error_number      => 94589
              ,p_error_text        => 'BEN_94589_EXT_MAX_LENGTH_ERROR'
              ,p_token1            => l_field_name || ' '
                                      || TO_CHAR(l_earnings)
              ,p_token2            => '999999999.99'
            );
      END IF; -- End if of earnings value check ...

      IF g_debug
      THEN
         l_proc_step    := 30;
         DEBUG('l_field_name: ' || l_field_name);
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
   END get_earnings_history_data;

-- This function is used for post processing in earnings history interface
-- ----------------------------------------------------------------------------
-- |---------------------< earnings_history_post_process >---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION earnings_history_post_process(p_ext_rslt_id IN NUMBER)
      RETURN VARCHAR2
   IS
      --
      l_proc_name      VARCHAR2(80)
                            := g_proc_name || 'earnings_history_post_process';
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

      pqp_gb_psi_functions.raise_extract_exceptions('S');
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
   END earnings_history_post_process;
END pqp_gb_psi_earnings_history;

/
