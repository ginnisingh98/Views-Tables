--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_ALLOWANCE_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_ALLOWANCE_HISTORY" AS
--  /* $Header: pqpgbpsiall.pkb 120.4.12010000.7 2009/02/11 06:40:27 namgoyal ship $ */



-- Exceptions
hr_application_error exception;
pragma exception_init (hr_application_error, -20001);


g_nested_level       NUMBER(5) := pqp_utilities.g_nested_level;

-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE DEBUG (p_trace_message IN VARCHAR2, p_trace_location IN NUMBER)
   IS

--
   BEGIN
      --

      pqp_utilities.DEBUG (
         p_trace_message               => p_trace_message
        ,p_trace_location              => p_trace_location
      );
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
       BEGIN
          --
          IF g_debug THEN
            IF pqp_utilities.g_nested_level = 0 THEN
              hr_utility.trace_on(NULL, 'REQID'); -- Pipe name REQIDnnnnn
            END IF;
            pqp_utilities.debug_enter (
              p_proc_name                   => p_proc_name
             ,p_trace_on                    => p_trace_on
           );
          END IF;
          --

       END debug_enter;


    -- This procedure is used for debug purposes
    --
    -- ----------------------------------------------------------------------------
    -- |----------------------------< debug_exit >--------------------------------|
    -- ----------------------------------------------------------------------------

       PROCEDURE debug_exit (p_proc_name IN VARCHAR2, p_trace_off IN VARCHAR2)
       IS
       BEGIN
          --
          IF g_debug THEN
            pqp_utilities.debug_exit (
              p_proc_name                   => p_proc_name
             ,p_trace_off                    => p_trace_off
           );

           IF pqp_utilities.g_nested_level = 0 THEN
              hr_utility.trace_off;
           END IF;
          END IF;
          --
       END debug_exit;

-- This procedure is used for debug purposes
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_others >------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_others (p_proc_name IN VARCHAR2, p_proc_step IN NUMBER)
   IS
   BEGIN
      --
      pqp_utilities.debug_others (
         p_proc_name                   => p_proc_name
        ,p_proc_step                   => p_proc_step
      );
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
     l_proc_name VARCHAR2(80) := g_proc_name || 'clear_cache';
     l_proc_step PLS_INTEGER;
     --
   BEGIN
     --
     IF g_debug
     THEN
       l_proc_step := 10;
       debug_enter(l_proc_name);
     END IF;

    -- start clearing globals
    g_business_group_id       := NULL;
    g_assignment_id           := NULL;
    g_person_id               := NULL;
    g_person_dtl              := NULL;
    g_assignment_dtl          := NULL;
    g_effective_date          := NULL;
    g_extract_type            := NULL;

    g_current_run             := NULL;
    g_current_layout          := NULL;
    g_altkey                  := NULL;

    -- globals set by set_shared_globals
    g_paypoint                := NULL;
    g_cutover_date            := NULL;
    g_ext_dfn_id              := NULL;

  --

     IF g_debug
     THEN
       debug_exit(l_proc_name);
     END IF;
   EXCEPTION
     WHEN others THEN
         IF SQLCODE <> hr_utility.hr_error_number
         THEN
             debug_others (l_proc_name, l_proc_step);
             IF g_debug
             THEN
               DEBUG (   'Leaving: '
                      || l_proc_name, -999);
              END IF;
              fnd_message.raise_error;
          ELSE
              RAISE;
          END IF;
   END clear_cache;



-- ----------------------------------------------------------------------------
-- |------------------------< set_allowance_history_globals >-----------------|
-- ----------------------------------------------------------------------------
  PROCEDURE set_allowance_history_globals
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    )
  IS
  --

    l_proc_name           VARCHAR2(61):=
     g_proc_name||'set_allowance_history_globals';

    l_rate_name VARCHAR2(80);
    l_rate_code VARCHAR2(80);
    l_sal_ele_fte_attr VARCHAR2(80) := NULL;

  --
  BEGIN

  debug_enter(l_proc_name);

    debug('Entering set_allowance_history_globals ...',10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_assignment_id:'||p_assignment_id);

    PQP_GB_PSI_FUNCTIONS.get_elements_of_info_type
          (p_information_type => 'PQP_GB_PENSERV_ALLOWANCE_INFO' -- IN VARCHAR2
          --,p_input_value      => 'CLAIM DATE' -- IN VARCHAR2 DEFAULT 'PAY VALUE'
          );

    debug('p_business_group_id: '||p_business_group_id,10);

    pqp_gb_psi_functions.get_rate_usr_func_name
                          (
                          p_business_group_id   =>  p_business_group_id
                          ,p_legislation_code   =>  'GB' -- g_legislation_code
                          ,p_interface_name     =>  'ALLOWANCE'
                          ,p_rate_name          =>  l_rate_name
                          ,p_rate_code          =>  l_rate_code
                          ,p_usr_rate_function  =>  g_user_rate_function
                          ,p_sal_ele_fte_attr   =>  l_sal_ele_fte_attr -- dummy, not used
                          );


  debug('Exiting set_allowance_history_globals ...',60);
  debug_exit(l_proc_name);

  EXCEPTION
    WHEN others THEN
        IF SQLCODE <> hr_utility.hr_error_number
        THEN
            debug_others (l_proc_name, 10);
            IF g_debug
            THEN
              DEBUG (   'Leaving: '
                     || l_proc_name, -999);
             END IF;
             fnd_message.raise_error;
         ELSE
             RAISE;
         END IF;

  END set_allowance_history_globals;


  -- ----------------------------------------------------------------------------
  -- |-----------------------< set_assignment_globals >--------------------------|
  -- ----------------------------------------------------------------------------
  PROCEDURE set_assignment_globals
              (
              p_assignment_id         IN NUMBER
              ,p_effective_date        IN DATE
              )
  IS
      l_proc_name varchar2(72) := g_proc_name||'.set_assignment_globals';

        CURSOR csr_start_date
        IS
            select DECODE(PER.CURRENT_EMPLOYEE_FLAG,'Y',PPS.DATE_START,NULL)
            from per_all_people_f PER, per_periods_of_service PPS
            where per.person_id = g_person_id
              and pps.person_id = g_person_id
              and rownum=1
              order by per.effective_start_date;

  BEGIN -- set_assignment_globals
      debug_enter(l_proc_name);
      debug('Inputs are: ',10);
      debug('p_assignment_id: '||p_assignment_id,10);
      debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);

      -- set the global events table
      g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;

      -- set global assignment_id
      g_assignment_id := p_assignment_id;
      debug('g_assignment_id: '||g_assignment_id,10);

      g_person_id     :=  PQP_GB_PSI_FUNCTIONS.get_current_extract_person
                            (
                            p_assignment_id => p_assignment_id
                            );

      --set the assignment start date
      OPEN csr_start_date;
      FETCH csr_start_date INTO g_assg_start_date;
      CLOSE csr_start_date;

      PQP_GB_PSI_FUNCTIONS.init_st_end_date_glob();

      debug_exit(l_proc_name);
  EXCEPTION
         WHEN others THEN
             IF SQLCODE <> hr_utility.hr_error_number
             THEN
                 debug_others (l_proc_name, 10);
                 IF g_debug
                 THEN
                   DEBUG (   'Leaving: '
                          || l_proc_name, -999);
                  END IF;
                  fnd_message.raise_error;
              ELSE
                  RAISE;
              END IF;
  END set_assignment_globals;



    FUNCTION is_curr_evt_processed RETURN BOOLEAN
    IS
        l_proc varchar2(72) := g_proc_name||'.is_curr_evt_processed';
        l_prev_event_dtl_rec    ben_ext_person.t_detailed_output_tab_rec;
        l_flag                  VARCHAR2(1);
    BEGIN
      debug_enter(l_proc);
      IF g_prev_event_dtl_rec.dated_table_id IS NOT NULL THEN
          l_prev_event_dtl_rec  :=  g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index);
          l_prev_event_dtl_rec.change_mode  :=  g_prev_event_dtl_rec.change_mode;
          l_flag  :=  'Y';
          IF l_prev_event_dtl_rec.dated_table_id <>   g_prev_event_dtl_rec.dated_table_id THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.datetracked_event <>   g_prev_event_dtl_rec.datetracked_event THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.update_type <>   g_prev_event_dtl_rec.update_type THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.surrogate_key <>   g_prev_event_dtl_rec.surrogate_key THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.column_name <>   g_prev_event_dtl_rec.column_name THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.effective_date <>   g_prev_event_dtl_rec.effective_date THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.old_value <>   g_prev_event_dtl_rec.old_value THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.new_value <>   g_prev_event_dtl_rec.new_value THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.change_values <>   g_prev_event_dtl_rec.change_values THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.proration_type <>   g_prev_event_dtl_rec.proration_type THEN
              l_flag  :=  'N';
          ELSIF l_prev_event_dtl_rec.event_group_id <>   g_prev_event_dtl_rec.event_group_id THEN
              l_flag  :=  'N';
         ELSIF l_prev_event_dtl_rec.actual_date <>   g_prev_event_dtl_rec.actual_date THEN
              l_flag  :=  'N';
          END IF;

          IF l_flag = 'Y' THEN
              debug('Event already processed',30);
              debug_exit(l_proc);
              RETURN TRUE;
          ELSE
              g_prev_event_dtl_rec  :=  g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index);
          END IF;
      ELSE
          debug('First event');
          g_prev_event_dtl_rec  :=  g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index);
      END IF;

      debug_exit(l_proc);
      RETURN FALSE;
    END is_curr_evt_processed;
    ----




    -- ----------------------------------------------------------------------------
    -- |------------------< all_cutover_ext_criteria >---------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION all_cutover_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2
    IS
          l_include  VARCHAR2(1) := 'Y';
          l_proc_name     VARCHAR2(80) := g_proc_name ||'all_cutover_ext_criteria';
          l_debug    VARCHAR2(1);
          l_error    NUMBER;
    BEGIN

      debug_enter(l_proc_name);
      debug('Inputs are: ');
      debug('p_business_group_id: '||p_business_group_id);
      debug('p_assignment_id: '||p_assignment_id);
      debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'));
      -- reset salary globals
      g_current_layout := 'CUTOVER';
      g_current_run    := 'CUTOVER';
      g_effective_date  :=  p_effective_date;

      IF g_business_group_id IS NULL
      THEN

          clear_cache;

          -- set the global debug value
          g_debug :=  pqp_gb_psi_functions.check_debug(p_business_group_id);

          debug('Inputs are: ');
          debug('p_business_group_id: '||p_business_group_id);
          debug('p_assignment_id: '||p_assignment_id);
          debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'));

          PQP_GB_PSI_FUNCTIONS.set_shared_globals
               (p_business_group_id => p_business_group_id
               ,p_paypoint          => g_paypoint
               ,p_cutover_date      => g_cutover_date
               ,p_ext_dfn_id        => g_ext_dfn_id
               );

          set_allowance_history_globals
                  (
                  p_business_group_id     =>    p_business_group_id
                  ,p_assignment_id        =>    p_assignment_id
                  ,p_effective_date       =>    p_effective_date
                  );

          g_business_group_id := p_business_group_id;
          g_legislation_code  :=  'GB';

          --Raise extract exceptions which are stored while checking for the setup
          debug('Raising the set-up errors, with input parameter as S',10);
          PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions(p_extract_type => 'S');

      END IF;

          l_include :=  PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
                        (p_business_group_id        =>  p_business_group_id
                        ,p_effective_date           =>  p_effective_date
                        ,p_assignment_id            =>  p_assignment_id
                        ,p_person_dtl               =>  g_curr_person_dtls
                        ,p_assignment_dtl           =>  g_curr_assg_dtls
                        );

          IF l_include = 'N' THEN
              debug('Returning : '||l_include,30);
              debug_exit(l_proc_name);
              return l_include;
          END IF; --IF l_include = 'N'

          IF g_assignment_id IS NULL
             OR p_assignment_id <> nvl(g_assignment_id,0) THEN

              set_assignment_globals
                    (
                    p_assignment_id         =>    p_assignment_id
                    ,p_effective_date       =>    p_effective_date
                    );
          END IF;

          /*
          IF l_include = 'N'
            OR NOT set_curr_row_values() THEN
              --current event is not accepted
              l_include := 'N';
              debug('Returning : '||l_include,20);
              debug_exit(l_proc_name);
              return l_include;
          END IF;
          */

        debug('Returning : '||l_include,20);
        debug_exit(l_proc_name);
        RETURN l_include;
    EXCEPTION
           WHEN others THEN
               IF SQLCODE <> hr_utility.hr_error_number
               THEN
                   debug_others (l_proc_name, 10);
                   IF g_debug
                   THEN
                     DEBUG (   'Leaving: '
                            || l_proc_name, -999);
                    END IF;
                    fnd_message.raise_error;
                ELSE
                    RAISE;
                END IF;
    END all_cutover_ext_criteria;


--For bug 7829676: Added new function
-- ----------------------------------------------------------------------------
-- |---------------------< is_next_allow_code_same >---------------------|
--This function checks if there is an allowance element attached on the next day,
--which has same allowance code, as the allowance element which is currently
--getting end dated. If true, then we don't want the end date record to be
--reported
-- ----------------------------------------------------------------------------
  FUNCTION is_next_allow_code_same(p_element_entry_id	IN  NUMBER,
                                 p_eve_eff_date	        IN  DATE,
				 p_assignment_id        IN  NUMBER
			        )
  RETURN BOOLEAN
  IS
   --Cursor to get allowance code of current Allowance element
   CURSOR csr_curr_ele_allow_code
   IS
      Select info.eei_information2
      From pay_element_entries_f ent,
           pay_element_type_extra_info info
      Where info.eei_information_category = 'PQP_GB_PENSERV_ALLOWANCE_INFO'
        and info.element_type_id = ent.element_type_id
        and ent.element_entry_id = p_element_entry_id
   	and p_eve_eff_date BETWEEN ent.effective_start_date AND effective_end_date;

   --Cursor to get the element attached on the following day
   CURSOR csr_get_new_ele
   IS
      Select element_type_id
      From   pay_element_entries_f
      Where  assignment_id = p_assignment_id
        and  effective_start_date = p_eve_eff_date+1;

   --Cursor to check if the new element is an allownance element and having a same
   --allowance code.
   CURSOR csr_match_allowance_code(c_element_type_id NUMBER, c_allow_code VARCHAR2)
   IS
      Select 'x'
      From   pay_element_type_rules elerule,
             pay_event_group_usages eveusg,
             pay_event_groups evegrp,
             pay_element_type_extra_info elextra
      Where  elerule.element_type_id = c_element_type_id
        and  elerule.element_set_id = eveusg.element_set_id
        and  eveusg.event_group_id = evegrp.event_group_id
        and  evegrp.event_group_name = 'PQP_GB_PSI_ALL_ELEMENT_ENTRIES'
        and  elextra.element_type_id = elerule.element_type_id
        and  elextra.eei_information_category = 'PQP_GB_PENSERV_ALLOWANCE_INFO'
        and  elextra.eei_information2 = c_allow_code;

   --Declare variables
   l_allow_code            VARCHAR2(20);
   l_return_flag           BOOLEAN := FALSE;
   l_new_element_type_id   NUMBER;
   l_exists                VARCHAR2(5);

  BEGIN
     debug('Entering: is_next_allow_code_same',100);
     debug('p_element_entry_id :'||p_element_entry_id,100);
     debug('p_eve_eff_date :'||p_eve_eff_date,100);
     debug('p_assignment_id :'||p_assignment_id,100);

     --get allowance code of current Allowance element
     OPEN csr_curr_ele_allow_code;
     FETCH csr_curr_ele_allow_code INTO l_allow_code;

     IF csr_curr_ele_allow_code%NOTFOUND
        OR l_allow_code IS NULL
     THEN
         CLOSE csr_curr_ele_allow_code;
         l_return_flag := FALSE;
         debug('No Allownace code found for this element',101);
         debug('Return False', 101);
         RETURN l_return_flag;
     END IF;

     debug('l_allow_code :'||l_allow_code,101);
     CLOSE csr_curr_ele_allow_code;

     --get the element attached on the following day and match the
     --allownace code
     OPEN csr_get_new_ele;
     FETCH csr_get_new_ele INTO l_new_element_type_id;

     IF csr_get_new_ele%NOTFOUND
     THEN
         CLOSE csr_get_new_ele;
         l_return_flag := FALSE;
         debug('No element attached on next day',102);
         debug('Return False', 102);
	     RETURN l_return_flag;
     END IF;

     LOOP
          debug('l_allow_code :'||l_allow_code,101);
          OPEN csr_match_allowance_code(l_new_element_type_id, l_allow_code);
          FETCH csr_match_allowance_code INTO l_exists;

	  IF csr_match_allowance_code%FOUND
          THEN
              CLOSE csr_match_allowance_code;
	          l_return_flag := TRUE;
              debug('Allowance code is same for new element',103);
              debug('Set Return flag to TRUE', 103);
              EXIT;
	  END IF;

          CLOSE csr_match_allowance_code;

          FETCH csr_get_new_ele INTO l_new_element_type_id;
	  EXIT WHEN csr_get_new_ele%NOTFOUND;

     END LOOP;
     CLOSE csr_get_new_ele;

     RETURN l_return_flag;

  EXCEPTION
    WHEN others THEN
    IF SQLCODE <> hr_utility.hr_error_number
    THEN
        debug_others ('is_next_allow_code_same', 10);
        IF g_debug
        THEN
            DEBUG ('Leaving: is_next_allow_code_same', -999);
        END IF;
        fnd_message.raise_error;
     ELSE
         RAISE;
     END IF;
  END is_next_allow_code_same;

-- ----------------------------------------------------------------------------
-- |---------------------< all_periodic_ext_criteria >---------------------|
-- ----------------------------------------------------------------------------
FUNCTION all_periodic_ext_criteria
            (
             p_business_group_id     IN NUMBER
            ,p_assignment_id         IN NUMBER
            ,p_effective_date        IN DATE
            )RETURN VARCHAR2
IS
      l_include         VARCHAR2(1) := 'Y';
      l_proc_name       VARCHAR2(80) := g_proc_name ||'all_periodic_ext_criteria';
      l_error           NUMBER;
      l_curr_evt_index  NUMBER;
      l_return          VARCHAR2(1) := 'Y';
	-- For Bug 6082338
	l_dated_table_id  pay_dated_tables.dated_table_id%TYPE;
      l_chg_table_name  VARCHAR2(61);
      l_chg_column_name pay_event_updates.column_name%TYPE;
      l_update_type     pay_datetracked_events.update_type%TYPE;

    --For bug 7158117: Added new cursor
      Cursor csr_get_ele_end_date (c_element_entry_id number)
      IS
        Select max(effective_end_date)
        From PAY_ELEMENT_ENTRIES_F
        Where element_entry_id = c_element_entry_id;

      l_surrogate_key  NUMBER;
      l_ele_end_date   DATE;
    --For bug 7158117: End

    --For bug 7229852: Added new cursor
      CURSOR csr_get_atd
      IS
       Select actual_termination_date
       From per_all_assignments_f asg, per_periods_of_service per
       Where asg.assignment_id = p_assignment_id
       And per.period_of_service_id = asg.period_of_service_id
       AND p_effective_date between asg.effective_start_date and asg.effective_end_date;

      l_eve_effective_date   DATE;
      l_actual_termination_date DATE;
    --For bug 7229852: End

BEGIN --all_periodic_ext_criteria

  debug_enter(l_proc_name);

  debug('Inputs are: ',10);
  debug('p_business_group_id: '||p_business_group_id,10);
  debug('p_assignment_id: '||p_assignment_id,10);
  debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);

  g_current_layout := 'PERIODIC';
  g_current_run    := 'PERIODIC';
  g_effective_date := p_effective_date;

  --
  IF g_business_group_id IS NULL
     OR p_business_group_id <> nvl(g_business_group_id,0) THEN

      -- clear cache
      clear_cache;

      -- for trace switching ON/OFF
      g_debug		  := PQP_GB_PSI_FUNCTIONS.check_debug(p_business_group_id);
      -- setting shared globals
      -- 1) paypoint
      -- 2) cutover date
      -- 3) extract def id
      PQP_GB_PSI_FUNCTIONS.set_shared_globals
           (p_business_group_id => p_business_group_id
           ,p_paypoint          => g_paypoint     -- OUT
           ,p_cutover_date      => g_cutover_date -- OUT
           ,p_ext_dfn_id        => g_ext_dfn_id   -- OUT
           );

      -- setting extract specific globals
      set_allowance_history_globals
              (p_business_group_id     =>    p_business_group_id
              ,p_assignment_id        =>    p_assignment_id
              ,p_effective_date       =>    p_effective_date
              );

      g_business_group_id := p_business_group_id;
      g_legislation_code  :=  'GB';

      debug('now raise setup exceptions ...',15);
      -- raise setup errors and warnings
      PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions(p_extract_type => 'S');

  END IF; --IF g_business_group_id IS NULL

  g_current_run := 'PERIODIC';
  g_current_layout := 'PERIODIC';

  debug('g_current_run :'||g_current_run);

    debug('calling the basic criteria for this person assignment');
    -- calling the basic criteria for this person assignment
    l_return :=
      PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
          (p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date
          ,p_assignment_id      => p_assignment_id
          ,p_person_dtl         => g_person_dtl
          ,p_assignment_dtl     => g_assignment_dtl
          );

    debug ('p_assignment_id:'||p_assignment_id);
    debug('l_return: '||l_return);


    IF l_return <> 'N'
    THEN
      debug('Calling the common include event proc');
      -- set the global events table
      g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;
      l_curr_evt_index    :=  ben_ext_person.g_chg_pay_evt_index;

        debug('----------');
        debug('Record :'||l_curr_evt_index);
        debug('----------');
        debug('dated_table_id    :'||g_pay_proc_evt_tab(l_curr_evt_index).dated_table_id   ,20);
        debug('datetracked_event :'||g_pay_proc_evt_tab(l_curr_evt_index).datetracked_event,20);
        debug('surrogate_key     :'||g_pay_proc_evt_tab(l_curr_evt_index).surrogate_key    ,20);
        debug('column_name       :'||g_pay_proc_evt_tab(l_curr_evt_index).column_name      ,20);
        debug('update_type       :'||g_pay_proc_evt_tab(l_curr_evt_index).update_type      ,20);
        debug('effective_date    :'||to_char(g_pay_proc_evt_tab(l_curr_evt_index).effective_date,'DD/MM/YYYY'),20);
        debug('actual_date       :'||to_char(g_pay_proc_evt_tab(l_curr_evt_index).actual_date,'DD/MM/YYYY'),20);
        debug('old_value         :'||g_pay_proc_evt_tab(l_curr_evt_index).old_value        ,20);
        debug('new_value         :'||g_pay_proc_evt_tab(l_curr_evt_index).new_value        ,20);
        debug('change_values     :'||g_pay_proc_evt_tab(l_curr_evt_index).change_values    ,20);
        debug('proration_type    :'||g_pay_proc_evt_tab(l_curr_evt_index).proration_type   ,20);
        debug('change_mode       :'||g_pay_proc_evt_tab(l_curr_evt_index).change_mode      ,20);
	  -- For Bug 6082338
	  l_dated_table_id    :=  g_pay_proc_evt_tab(l_curr_evt_index).dated_table_id;
        l_chg_column_name   :=  g_pay_proc_evt_tab(l_curr_evt_index).column_name;
        l_update_type       :=  g_pay_proc_evt_tab(l_curr_evt_index).update_type;
        l_chg_table_name    :=  pqp_gb_psi_functions.get_dated_table_name(l_dated_table_id);

        IF  (l_chg_table_name  = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
            AND
            l_chg_column_name  = 'EFFECTIVE_END_DATE'
            AND
            l_update_type = 'C') THEN
            l_return   :=  'N';
		debug('Returning : '||l_return,22);
            debug_exit(l_proc_name);
		return l_return;
        END IF;

      --For bug 7158117: Added condn to supress end date record
        IF (l_chg_table_name  = 'PAY_ELEMENT_ENTRIES_F'
            AND l_chg_column_name  = 'EFFECTIVE_END_DATE'
            AND l_update_type = 'E')
        THEN
             l_surrogate_key := g_pay_proc_evt_tab(l_curr_evt_index).surrogate_key;
             debug('l_surrogate_key :'||l_surrogate_key,23);

           --For bug 7229852: Start
             l_eve_effective_date := g_pay_proc_evt_tab(l_curr_evt_index).effective_date;
             debug('l_eve_effective_date :'||l_eve_effective_date,23);
           --For bug 7229852: End

             OPEN csr_get_ele_end_date(l_surrogate_key);
             FETCH csr_get_ele_end_date INTO l_ele_end_date;
             CLOSE csr_get_ele_end_date;

             debug('l_ele_end_date :'||l_ele_end_date,23);
             --debug('hr_api.g_eot :'||hr_api.g_eot,23);

           --For bug 7229852: Changed logic
             OPEN csr_get_atd;
             FETCH csr_get_atd INTO l_actual_termination_date;
             CLOSE csr_get_atd;

             debug('l_actual_termination_date :'||l_actual_termination_date,23);

             IF l_ele_end_date <> l_eve_effective_date
                OR
                (l_actual_termination_date IS NOT NULL
                  AND
                 l_actual_termination_date < l_eve_effective_date)
             THEN
                  l_return   :=  'N';
		          debug('Returning : '||l_return,23);
                  debug_exit(l_proc_name);
		          return l_return;
             END IF;

	     --For bug 7829676: Start
             IF is_next_allow_code_same(l_surrogate_key,
                                        l_eve_effective_date,
                                        p_assignment_id)
             THEN
                  l_return   :=  'N';
		          debug('Returning : '||l_return,23);
                  debug_exit(l_proc_name);
		          return l_return;
             END IF;
             --For bug 7829676: End

        END IF;
      --For bug 7158117: End

      --For Bug 7149468: Start
        g_leaver_event := 'N';

      --For Bug 7229852: Start
        g_act_term_date := NULL;
      --For Bug 7229852: End

        IF (l_chg_table_name = 'PER_ALL_ASSIGNMENTS_F'
            AND l_chg_column_name = 'ASSIGNMENT_STATUS_TYPE_ID'
            AND l_update_type in ('U','C') --For bug 7229852: Added Correction event
            )
        THEN
              g_leaver_event := 'Y';

            --For Bug 7229852: Start
              OPEN csr_get_atd;
              FETCH csr_get_atd INTO g_act_term_date;
              CLOSE csr_get_atd;

              debug('g_act_term_date :'||g_act_term_date,23);
            --For Bug 7229852: End

        END IF;

        debug('g_leaver_event : '||g_leaver_event ,22);
      --For Bug 7149468: End


	IF is_curr_evt_processed()
	THEN
		l_return   :=  'N';
		debug('Returning : '||l_return,20);
		debug_exit(l_proc_name);
		return l_return;
	END IF;

      l_return := pqp_gb_psi_functions.include_event
                          (p_actual_date => g_pay_proc_evt_tab(l_curr_evt_index).actual_date
                          ,p_effective_date => g_pay_proc_evt_tab(l_curr_evt_index).effective_date
                          );

       pqp_gb_psi_functions.process_retro_event();

      debug ('p_assignment_id:'||p_assignment_id);
      debug('include_event returned: '||l_return);

    END IF;


    -- IF l_return <> 'N' THEN
			pqp_gb_psi_functions.g_effective_date := p_effective_date;

      -- set assignment globals
      IF g_assignment_id IS NULL
         OR p_assignment_id <> nvl(g_assignment_id,0) THEN

          set_assignment_globals
                (
                p_assignment_id         =>    p_assignment_id
                ,p_effective_date       =>    p_effective_date
                );
      END IF;
    -- END IF;

    debug('l_return: '||l_return);

    debug_exit(l_proc_name);
    RETURN l_return;

EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc_name, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc_name, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
  END all_periodic_ext_criteria;
  ---

-- ----------------------------------------------------------------------------
-- |---------------------------< get_allowance_code >--------------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION get_allowance_code
            (p_output       OUT NOCOPY VARCHAR2
            )RETURN NUMBER
IS
    l_proc_name varchar2(72) := g_proc_name||'.get_allowance_code';
    l_return     NUMBER;
BEGIN
    debug_enter(l_proc_name);

    IF PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type.exists(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id) THEN
        g_allowance_code
            :=  PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id).eei_information2;
    ELSE
      g_allowance_code := ' ';
    END IF;

    IF NOT pqp_gb_psi_functions.is_alphanumeric(g_allowance_code) THEN
        debug('ERROR: the allowance code is non-alphanumeric',20);
        l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                        (p_error_number        =>    94557
                        ,p_error_text          =>    'BEN_94557_INVALID_CODE'
                        ,p_token1              =>    'Allowance'
                        ,p_token2              =>
                           PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id).element_name
                        ,p_token3              =>    g_allowance_code
                        );
    END IF;


    p_output := g_allowance_code;

    debug_exit(l_proc_name);
    return 0;
EXCEPTION
   WHEN others THEN
       IF SQLCODE <> hr_utility.hr_error_number
       THEN
           debug_others (l_proc_name, 10);
           IF g_debug
           THEN
             DEBUG (   'Leaving: '
                    || l_proc_name, -999);
            END IF;
            fnd_message.raise_error;
        ELSE
            RAISE;
        END IF;
END get_allowance_code;



-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dup_allow_types >--------------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION chk_dup_allow_types
            (p_assignment_id            IN NUMBER
            ,p_effective_date           IN DATE
            ) RETURN NUMBER
IS

    cursor csr_check_dup_allow_types
    is
    select 1
    from pay_element_entries_f pee, pay_element_type_extra_info petei
    where pee.assignment_id = p_assignment_id
    and pee.element_type_id = petei.element_type_id
    and p_effective_date between pee.effective_start_date and pee.effective_end_date
    and pee.element_entry_id <> PQP_GB_PSI_FUNCTIONS.g_curr_element_entry_id
    and petei.information_type = 'PQP_GB_PENSERV_ALLOWANCE_INFO'
    and petei.eei_information2 = g_allowance_code
    and rownum=1;

    l_proc_name varchar2(72) := g_proc_name||'.chk_dup_allow_types';
    l_return     NUMBER;
    l_result     NUMBER;

BEGIN
    debug_enter(l_proc_name);

    OPEN csr_check_dup_allow_types;
    FETCH csr_check_dup_allow_types into l_result;
      IF csr_check_dup_allow_types%NOTFOUND
      THEN l_result := 0;
      END IF;
    CLOSE csr_check_dup_allow_types;

    IF l_result = 1
    THEN
      debug('WARNING: Duplicate Allowance Type on same date');
      l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                                   (p_error_number        =>    94595
                                   ,p_error_text          =>    'BEN_94595_DUP_ALLOW_TYPE'
                                   ,p_token1              =>    to_char(p_effective_date,'dd/mm/yyyy')
                                   );
    END IF;

    debug_exit(l_proc_name);
    return 0;
EXCEPTION
   WHEN others THEN
       IF SQLCODE <> hr_utility.hr_error_number
       THEN
           debug_others (l_proc_name, 10);
           IF g_debug
           THEN
             DEBUG (   'Leaving: '
                    || l_proc_name, -999);
            END IF;
            fnd_message.raise_error;
        ELSE
            RAISE;
        END IF;
END chk_dup_allow_types;


-- ----------------------------------------------------------------------------
-- |---------------------------< get_allowance_ind_flag >--------------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION get_allowance_ind_flag
            (p_output       OUT NOCOPY VARCHAR2
            )RETURN NUMBER
IS
    l_proc_name varchar2(72) := g_proc_name||'get_allowance_ind_flag';
BEGIN
    debug_enter(l_proc_name);

    IF PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type.exists(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id) THEN
        p_output
            :=  PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id).eei_information5;
    END IF;

    IF p_output IS NULL
    THEN
      p_output := 'N';
    END IF;

    debug_exit(l_proc_name);
    return 0;
EXCEPTION
   WHEN others THEN
       IF SQLCODE <> hr_utility.hr_error_number
       THEN
           debug_others (l_proc_name, 10);
           IF g_debug
           THEN
             DEBUG (   'Leaving: '
                    || l_proc_name, -999);
            END IF;
            fnd_message.raise_error;
        ELSE
            RAISE;
        END IF;
END get_allowance_ind_flag;



-- ----------------------------------------------------------------------------
-- |---------------------< get_notional_allowance_rate >----------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION get_notional_allowance_rate
            (p_business_group_id        IN NUMBER
            ,p_effective_date           IN DATE
            ,p_assignment_id            IN NUMBER
            ,p_output                   OUT NOCOPY VARCHAR2
            )  RETURN number
IS
    l_proc_name varchar2(72) := g_proc_name||'get_notional_allowance_rate';
    l_include NUMBER;
    l_custom_function VARCHAR2(100) :=  'get_user_notional_pay';
BEGIN
  debug_enter(l_proc_name);

  debug('PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id : '||PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id,10);

  IF g_is_spread_bonus_yn = 'N' THEN
      IF g_allowance_end_dated_today <> 'Y'
      THEN
        l_include := PQP_GB_PSI_FUNCTIONS.get_notional_pay
                        (p_assignment_id     => p_assignment_id -- IN NUMBER
                        ,p_business_group_id => p_business_group_id -- IN NUMBER
                        ,p_effective_date    => p_effective_date -- IN DATE
                        ,p_name              =>
                           PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id).element_name
                           -- IN VARCHAR2
                        ,p_rt_element        => 'E'
                        ,p_rate              => p_output -- OUT
                        ,p_custom_function   => g_user_rate_function -- IN VARCHAR2  DEFAULT NULL
                        ,p_allowance_code    => g_allowance_code -- IN VARCHAR2  DEFAULT NULL
                        ,p_allowance_pet_id  => PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id -- IN NUMBER  DEFAULT NULL
                        );

      ELSE
        p_output := '0';
      END IF;
  ELSE
    p_output  :=  pqp_gb_psi_functions.get_element_payment
                      (p_assignment_id	    =>  p_assignment_id
                      ,p_element_entry_id   =>  PQP_GB_PSI_FUNCTIONS.g_curr_element_entry_id
                      ,p_element_type_id    =>  PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id
                      ,p_effective_date     =>  p_effective_date
                      );

  END IF;

  g_notional_rate := p_output;


  debug_exit(l_proc_name);
  return 0;
EXCEPTION
   WHEN others THEN
       IF SQLCODE <> hr_utility.hr_error_number
       THEN
           debug_others (l_proc_name, 10);
           IF g_debug
           THEN
             DEBUG (   'Leaving: '
                    || l_proc_name, -999);
            END IF;
            fnd_message.raise_error;
        ELSE
            RAISE;
        END IF;
END get_notional_allowance_rate;



-- ----------------------------------------------------------------------------
-- |---------------------< get_allowance_actual_pay >----------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION get_allowance_actual_pay
            (p_business_group_id   IN NUMBER
            ,p_assignment_id       IN NUMBER
            ,p_notional_pay        IN NUMBER
            ,p_effective_date      IN DATE
            ,p_output              OUT NOCOPY VARCHAR2
            )  RETURN number
IS
    l_proc_name varchar2(72) := g_proc_name||'get_allowance_actual_pay';
    l_include NUMBER;
BEGIN
  debug_enter(l_proc_name);

  IF g_is_spread_bonus_yn = 'N' THEN
    IF g_allowance_end_dated_today <> 'Y'
    THEN
      l_include := PQP_GB_PSI_FUNCTIONS.get_actual_pay
                      (
                       p_assignment_id  => p_assignment_id -- IN NUMBER
                      ,p_notional_pay   => g_notional_rate -- IN NUMBER
                      ,p_effective_date => p_effective_date -- IN DATE
                      ,p_output         => p_output -- OUT NOCOPY VARCHAR2
                      );
    ELSE
      p_output := '0';
    END IF;
  ELSE
    p_output               := g_notional_rate;
    g_allowance_actual_pay := g_notional_rate;
  END IF;

  debug_exit(l_proc_name);
  return 0;
EXCEPTION
   WHEN others THEN
       IF SQLCODE <> hr_utility.hr_error_number
       THEN
           debug_others (l_proc_name, 10);
           IF g_debug
           THEN
             DEBUG (   'Leaving: '
                    || l_proc_name, -999);
            END IF;
            fnd_message.raise_error;
        ELSE
            RAISE;
        END IF;
END get_allowance_actual_pay;


-- ----------------------------------------------------------------------------
-- |---------------------< get_allowance_start_date >----------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION get_allowance_start_date
            (p_effective_date           IN DATE
            ,p_output                   OUT NOCOPY VARCHAR2
            )  RETURN number
IS
    l_proc_name  varchar2(72) := g_proc_name||'get_allowance_start_date';
    l_include    NUMBER;
    l_claim_date VARCHAR2(60);
    l_date       VARCHAR2(30);
    l_start_date DATE;
    l_return     NUMBER;

BEGIN
  debug_enter(l_proc_name);


  IF   PQP_GB_PSI_FUNCTIONS.g_salary_ended_today = 'Y'
    OR PQP_GB_PSI_FUNCTIONS.g_allowance_has_end_dated = 'Y'
  THEN
      g_allowance_end_dated_today := 'Y';
  ELSE
      g_allowance_end_dated_today := 'N';
  END IF;

  debug('PQP_GB_PSI_FUNCTIONS.g_salary_ended_today :' || PQP_GB_PSI_FUNCTIONS.g_salary_ended_today,20);
  debug('PQP_GB_PSI_FUNCTIONS.g_allowance_has_end_dated :' || PQP_GB_PSI_FUNCTIONS.g_allowance_has_end_dated,20);
  debug('g_allowance_end_dated_today :' || g_allowance_end_dated_today,20);
  debug('p_effective_date :' || p_effective_date,20);


  IF g_is_spread_bonus_yn = 'N' THEN
    IF g_current_layout <> 'CUTOVER'
    THEN
       --For Bug 7149468:Start
         IF g_allowance_end_dated_today = 'Y'
         THEN
              IF g_leaver_event = 'N'
              THEN
                    p_output := to_char(p_effective_date + 1,'DD/MM/YYYY');
              ELSE
                 --For bug 7229852: Replaced effective date with ATD+1
		    p_output := to_char(g_act_term_date + 1,'DD/MM/YYYY');
              END IF;
         ELSE
       --For Bug 7149468:End
              p_output := to_char(p_effective_date,'DD/MM/YYYY');
       --For Bug 7149468:Start
         END IF;
      --For Bug 7149468:End
    ELSE
      	OPEN csr_get_start_date_cut
              (p_element_entry_id => PQP_GB_PSI_FUNCTIONS.g_curr_element_entry_id
              );
        FETCH csr_get_start_date_cut INTO l_start_date;
          IF csr_get_start_date_cut%NOTFOUND
          THEN
            p_output := NULL;
            debug('csr_get_start_date_cut NOTFOUND');
          ELSE
            p_output := to_char(l_start_date,'DD/MM/YYYY');
          END IF;
        CLOSE csr_get_start_date_cut;
    END IF;
  ELSE
    debug('g_claim_date :' || g_claim_date);
    p_output := to_char( (fnd_date.canonical_to_date(g_claim_date) + (7 - to_char(fnd_date.canonical_to_date(g_claim_date), 'D')) - 6),'DD/MM/YYYY');
    debug('p_output :' || p_output,99);

  END IF;

  debug_exit(l_proc_name);
  return 0;
EXCEPTION
   WHEN others THEN
       IF SQLCODE <> hr_utility.hr_error_number
       THEN
           debug_others (l_proc_name, 10);
           IF g_debug
           THEN
             DEBUG (   'Leaving: '
                    || l_proc_name, -999);
            END IF;
            fnd_message.raise_error;
        ELSE
            RAISE;
        END IF;
END get_allowance_start_date;


-- ----------------------------------------------------------------------------
-- |---------------------< get_allowance_end_date >----------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION get_allowance_end_date
            (p_effective_date           IN DATE
            ,p_output                   OUT NOCOPY VARCHAR2
            )  RETURN number
IS
    l_proc_name  varchar2(72) := g_proc_name||'get_allowance_end_date';
    l_claim_date VARCHAR2(60);
    l_date       VARCHAR2(30);
    l_return     NUMBER;
    l_include    NUMBER;

BEGIN
  debug_enter(l_proc_name);

  IF g_allowance_end_dated_today = 'Y'
  THEN
      --For bug 7829676: Commented following section to make
      --the end date field blank
      /*
      --For Bug 7149468: Start
       IF g_leaver_event = 'N'
       THEN
            p_output := to_char(p_effective_date + 1,'DD/MM/YYYY');
       ELSE
     --For Bug 7149468: End

	 --For bug 7229852: Replaced effective date with ATD+1
            p_output := to_char(g_act_term_date + 1,'DD/MM/YYYY');

     --For Bug 7149468:Start
       END IF;
     --For Bug 7149468:End
  ELSE
  */
    p_output := ' ';
  END IF;


  IF g_is_spread_bonus_yn = 'Y' THEN
    debug('g_claim_date :' || g_claim_date);
    p_output := to_char( fnd_date.canonical_to_date(g_claim_date) + (7 - to_char(fnd_date.canonical_to_date(g_claim_date), 'D')),'DD/MM/YYYY');
    debug('p_output :' || p_output,99);
  END IF;

  debug_exit(l_proc_name);
  return 0;
EXCEPTION
   WHEN others THEN
       IF SQLCODE <> hr_utility.hr_error_number
       THEN
           debug_others (l_proc_name, 10);
           IF g_debug
           THEN
             DEBUG (   'Leaving: '
                    || l_proc_name, -999);
            END IF;
            fnd_message.raise_error;
        ELSE
            RAISE;
        END IF;
END get_allowance_end_date;

-- ----------------------------------------------------------------------------
-- |------------------------< allowance_history_main >-------------------------|
-- ----------------------------------------------------------------------------

  FUNCTION allowance_history_main
    (p_business_group_id        IN         NUMBER  -- context
    ,p_effective_date           IN         DATE    -- context
    ,p_assignment_id            IN         NUMBER  -- context
    ,p_rule_parameter           IN         VARCHAR2 -- parameter
    ,p_output                   OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --

      l_proc_name           VARCHAR2(61):=
           g_proc_name||'allowance_history_main';
      l_value          NUMBER;
      l_effective_date DATE;
      l_return         VARCHAR2(1) := 'Y';
      l_output_value   NUMBER;
  --
  BEGIN

  debug_enter(l_proc_name);

  -- switch on the trace

    debug('Entering allowance_history_main ...',0);
    debug('p_business_group_id'||p_business_group_id,1);
    debug('p_effective_date'||p_effective_date,1);
    debug('p_assignment_id'|| p_assignment_id,1);
    debug('p_rule_parameter'||p_rule_parameter,1);


    -- select the function call based on the parameter being passed to the rule
    IF p_rule_parameter = 'AllowanceStartDate' THEN
      -- setting some globals which need to be set for the 1st data element
      -- and to be used by later data elements

      IF PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type.exists(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id) THEN
        g_is_spread_bonus_yn
          :=  PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id).eei_information6;
      END IF;

      IF g_is_spread_bonus_yn IS NULL
      THEN
        g_is_spread_bonus_yn := 'N';
      END IF;

      IF g_is_spread_bonus_yn = 'Y' THEN
        OPEN csr_get_entry_value
           (c_effective_date    => p_effective_date
           ,c_element_entry_id  => PQP_GB_PSI_FUNCTIONS.g_curr_element_entry_id
           ,c_input_value       => 'CLAIM DATE' -- DEFAULT 'PAY VALUE'
           );
        FETCH csr_get_entry_value INTO g_claim_date;
          IF csr_get_entry_value%NOTFOUND
          OR g_claim_date IS NULL
          THEN
            l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                   (p_error_number        =>    94532
                   ,p_error_text          =>    'BEN_94532_NO_ENTRY_VALUE'
                   ,p_token1              =>
                        pqp_gb_psi_functions.g_elements_of_info_type(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id).element_name
                        || '(Spread Bonus)'
                   ,p_token2              => 'CLAIM DATE'
                   ,p_token3              => to_char(p_effective_date,'DD/MM/YYYY')
                   );

            g_claim_date := NULL;

          END IF;
        CLOSE csr_get_entry_value;
      END IF;
      --
      l_value := get_allowance_start_date
                      (p_effective_date => p_effective_date
                      ,p_output         => p_output
                      );
    ELSIF p_rule_parameter = 'AllowanceCode' THEN
      l_value :=  get_allowance_code
                    (
                     p_output  =>  p_output
                    );
      -- check for presence of this allowance code on this assignment

      l_value := chk_dup_allow_types
                    (p_assignment_id    => p_assignment_id
                    ,p_effective_date   => p_effective_date
                    );

    ELSIF p_rule_parameter = 'NotionalAllowanceRate' THEN
      l_value :=  get_notional_allowance_rate
                      (p_business_group_id => p_business_group_id
                      ,p_effective_date    => p_effective_date
                      ,p_assignment_id     => p_assignment_id
                      ,p_output            => p_output -- OUT
                      );
      --
            l_output_value := fnd_number.canonical_to_number(p_output);

            -- !!! IMP - new error message
            IF p_output IS NULL THEN
                -- raise error that the bonus amount is null and value will not be reported.
                debug('ERROR: No Allowance Amount');
                l_value :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                 (p_error_number        =>    94566
                                 ,p_error_text          =>    'BEN_94566_NO_ALLOWANCE_AMOUNT'
                                 ,p_token1              =>
                                        PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id).element_name
                                 ,p_token2              =>    to_char(p_effective_date,'dd/mm/yyyy')
                                 );

                -- bugfix 5055150
                -- null value, hence setting to zero
                l_output_value := 0;

            ELSIF NOT ( l_output_value >= -999999.99 AND l_output_value <= 9999999.99 ) THEN
                -- raise error that the bonus amount is out of range
                debug('ERROR: Allowance Amount out of range: '||p_output,20);
                l_value :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                 (p_error_number        =>    94568
                                 ,p_error_text          =>    'BEN_94568_INV_ALLOWANCE_AMOUNT'
                                 ,p_token1              =>
                                        PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(PQP_GB_PSI_FUNCTIONS.g_curr_element_type_id).element_name
                                 ,p_token2              =>    to_char(p_effective_date,'dd/mm/yyyy')
                                 ,p_token3              =>    p_output
                                 );
            END IF;

            IF l_output_value < 0 THEN
              p_output := rtrim(ltrim(to_char(l_output_value,'S099999D99')));
            ELSE
              p_output := rtrim(ltrim(to_char(l_output_value,'0999999D99')));
            END IF;
      --
    ELSIF p_rule_parameter = 'AllowanceIndustrialFlag' THEN
      l_value :=  get_allowance_ind_flag
                    (
                     p_output  =>  p_output
                    );
    ELSIF p_rule_parameter = 'AllowanceEndDate' THEN
      l_value := get_allowance_end_date
                      (p_effective_date => p_effective_date
                      ,p_output         => p_output
                      );

    ELSIF p_rule_parameter = 'ActualAllowancePay' THEN
      l_value := get_allowance_actual_pay
                    (p_business_group_id => p_business_group_id
                    ,p_assignment_id  => p_assignment_id
                    ,p_notional_pay   => g_notional_rate
                    ,p_effective_date => p_effective_date
                    ,p_output         => p_output
                    );

       l_output_value := fnd_number.canonical_to_number(p_output);

       IF l_output_value < 0 THEN
         p_output := rtrim(ltrim(to_char(l_output_value,'S09999999D99')));
       ELSE
         p_output := rtrim(ltrim(to_char(l_output_value,'099999999D99')));
       END IF;

    ELSIF p_rule_parameter = 'AllowanceEEId' THEN
      p_output := PQP_GB_PSI_FUNCTIONS.g_curr_element_entry_id;

    ELSE
      p_output := '';
    END IF;


  debug_exit(l_proc_name);
  RETURN 0;


  EXCEPTION
    WHEN others THEN
        IF SQLCODE <> hr_utility.hr_error_number
        THEN
            debug_others (l_proc_name, 10);
            IF g_debug
            THEN
              DEBUG (   'Leaving: '
                     || l_proc_name, -999);
             END IF;
             fnd_message.raise_error;
         ELSE
             RAISE;
         END IF;

  END allowance_history_main;


-- ----------------------------------------------------------------------------
-- |------------------------< allowance_post_processing >---------------------|
-- ----------------------------------------------------------------------------

  FUNCTION allowance_post_processing RETURN VARCHAR2
  IS

    l_proc_name          VARCHAR2(61):=
       g_proc_name||'allowance_post_processing';

  BEGIN -- basic_data_post_proc_rule

    debug_enter(l_proc_name);

      PQP_GB_PSI_FUNCTIONS.common_post_process(g_business_group_id);

    debug_exit(l_proc_name);
    RETURN 'Y';

  EXCEPTION
    WHEN others THEN
        IF SQLCODE <> hr_utility.hr_error_number
        THEN
            debug_others (l_proc_name, 10);
            IF g_debug
            THEN
              DEBUG (   'Leaving: '
                     || l_proc_name, -999);
             END IF;
             fnd_message.raise_error;
         ELSE
             RAISE;
         END IF;

  END allowance_post_processing; -- allowance_post_proc_rule

END PQP_GB_PSI_ALLOWANCE_HISTORY;

/
