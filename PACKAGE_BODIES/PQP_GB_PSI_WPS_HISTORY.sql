--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_WPS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_WPS_HISTORY" AS
--  /* $Header: pqpgbpsiwps.pkb 120.6.12010000.2 2009/03/25 16:23:04 jvaradra ship $ */



-- Exceptions
hr_application_error exception;
pragma exception_init (hr_application_error, -20001);


g_nested_level       NUMBER(5) := pqp_utilities.g_nested_level;

--For Bug 6071527
  l_element_type_id              NUMBER;
  l_end_date_basic_ele           VARCHAR2(1);

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




-- This procedure is used to show all events
--
-- ----------------------------------------------------------------------------
-- |----------------------------< show_events >-------------------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE show_events
   IS
       l_proc_name VARCHAR2(80) := g_proc_name || 'show_events';
   BEGIN
     debug_enter(l_proc_name);
     IF g_pay_proc_evt_tab.COUNT > 0 THEN
       debug('====== Detailed Output =======');
       FOR i IN g_pay_proc_evt_tab.FIRST..g_pay_proc_evt_tab.LAST
       LOOP
          debug('----------');
          debug('Record :'||i);
          debug('----------');
          debug('dated_table_id    :'||g_pay_proc_evt_tab(i).dated_table_id   ,20);
          debug('datetracked_event :'||g_pay_proc_evt_tab(i).datetracked_event,20);
          debug('surrogate_key     :'||g_pay_proc_evt_tab(i).surrogate_key    ,20);
          debug('column_name       :'||g_pay_proc_evt_tab(i).column_name      ,20);
          debug('update_type       :'||g_pay_proc_evt_tab(i).update_type      ,20);
          debug('effective_date    :'||to_char(g_pay_proc_evt_tab(i).effective_date,'DD/MM/YYYY'),20);
          debug('old_value         :'||g_pay_proc_evt_tab(i).old_value        ,20);
          debug('new_value         :'||g_pay_proc_evt_tab(i).new_value        ,20);
          debug('change_values     :'||g_pay_proc_evt_tab(i).change_values    ,20);
          debug('proration_type    :'||g_pay_proc_evt_tab(i).proration_type   ,20);
          debug('change_mode       :'||g_pay_proc_evt_tab(i).change_mode      ,20);
       END LOOP;
     ELSE
         debug('No Events',20);
     END IF;
   debug_exit(l_proc_name);
   END show_events;


-- ----------------------------------------------------------------------------
-- |---------------< set_wps_history_globals >-------------------|
-- Description:
-- ----------------------------------------------------------------------------
PROCEDURE set_wps_history_globals
          (
          p_business_group_id     IN NUMBER
          ,p_assignment_id        IN NUMBER
          ,p_effective_date       IN DATE
          )
IS
    l_index NUMBER;
    l_proc_name  varchar2(72) := g_proc_name||'set_wps_history_globals';
   -- l_element_type_id     NUMBER := NULL;

BEGIN
    debug_enter(l_proc_name);
    -- set global business group id
    g_business_group_id := p_business_group_id;
    g_legislation_code  :=  'GB';


  -- store in global, to be used in periodic criteria

    debug('g_legislation_code: '||g_legislation_code,10);
    debug('g_business_group_id: '||g_business_group_id,20);
    debug('p_effective_date: '||p_effective_date,30);

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
END set_wps_history_globals;

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

  BEGIN -- set_assignment_globals

      debug_enter(l_proc_name);
      debug('Inputs are: ',10);
      debug('p_assignment_id: '||p_assignment_id,10);
      debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);

      -- set the global events table
      g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;

      -- set global assignment_id
      g_assignment_id := p_assignment_id;
      debug('g_assignment_id: '||g_assignment_id,20);


      debug('now calling PQP_GB_PSI_FUNCTIONS.init_st_end_date_glob ',30);
      PQP_GB_PSI_FUNCTIONS.init_st_end_date_glob();

      g_is_terminated := 'N';
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

-- ----------------------------------------------------------------------------
-- |------------------------< is_curr_evt_processed >-------------------|
-- ----------------------------------------------------------------------------

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
-- |------------------------< chk_wps_cutover_crit >-------------------|
-- ----------------------------------------------------------------------------

FUNCTION chk_wps_cutover_crit
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    )
  RETURN VARCHAR2
IS
--
  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_wps_cutover_crit';

  l_return              VARCHAR2(1) := 'N';
--
BEGIN

-- trace

  debug_enter(l_proc_name);

  debug('Entering chk_wps_cutover_crit ...',10);
  debug ('p_business_group_id:'||p_business_group_id);
  debug ('p_assignment_id:'||p_assignment_id);

    -- being called only once in complete extract run
    IF g_business_group_id IS NULL THEN
       -- clear the cached globals
       clear_cache;


      -- for trace switching ON/OFF
      g_debug             := PQP_GB_PSI_FUNCTIONS.check_debug(p_business_group_id);
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
      set_wps_history_globals
           (p_business_group_id    =>    p_business_group_id
           ,p_assignment_id        =>    p_assignment_id
           ,p_effective_date       =>    p_effective_date
           );

      g_business_group_id := p_business_group_id;

      debug('now raise setup exceptions ...',15);
      -- raise setup errors and warnings
      PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions(p_extract_type => 'S');

    END IF; -- shared and basic_data globals have been set
    g_current_run := 'CUTOVER';
    debug('g_current_run :'||g_current_run);


    -- calling the basic criteria for this person assignment
    l_return :=
      PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
          (p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date
          ,p_assignment_id      => p_assignment_id
          ,p_person_dtl         => g_person_dtl
          ,p_assignment_dtl     => g_assignment_dtl
          );


            --calling function to check the pension scheme of the person
    IF l_return = 'Y'
    THEN
      debug('calling function to check the pension scheme of the person',20);
      --calling function to check the pension scheme of the person
      l_return :=PQP_GB_PSI_FUNCTIONS.check_employee_pension_scheme
                  (p_business_group_id        => p_business_group_id
                  ,p_effective_date           => p_effective_date
                  ,p_assignment_id            => p_assignment_id
                  ,p_psi_pension_scheme       => 'CLASSIC'
                  ,p_pension_element_type_id  => g_pension_element_type_id
                  );
      debug('l_return: '||l_return,25);

--****This commented loop is for 'Classic Plus' type of element.****--
/*      IF l_return = 'N' THEN
        l_return :=PQP_GB_PSI_FUNCTIONS.check_employee_pension_scheme
                  (p_business_group_id        => p_business_group_id
                  ,p_effective_date           => p_effective_date
                  ,p_assignment_id            => p_assignment_id
                  ,p_psi_pension_scheme       => 'CLASSPLUS'
                  ,p_pension_element_type_id  => g_pension_element_type_id
                  );
      END IF;
      debug('l_return: '||l_return,30);*/
    END IF;

--For Bug 6071527
    IF l_return = 'Y'
    THEN
       OPEN get_wps_ele_scheme_name(p_element_type_id => g_pension_element_type_id
                                       );
       FETCH get_wps_ele_scheme_name into g_pension_scheme_name;

       IF get_wps_ele_scheme_name%NOTFOUND
       THEN
          l_return       := 'N';
       END IF;
       CLOSE get_wps_ele_scheme_name;
    END IF;
--For Bug 6071527 End

    IF l_return <> 'N' -- no need to set alt_key for person not picked up
    THEN
      -- to ensure that this is called only once for an assignment
      IF g_assignment_id IS NULL
         OR
         (
         g_assignment_id IS NOT NULL and g_assignment_id <> p_assignment_id
         ) THEN
         -- put a fucntion here which is to be called only once per person
        g_assignment_id := p_assignment_id;
        debug('this is a new assignment, need to set globals',15);
      ELSE
        debug('this is the same assignment, NO need to set globals',15);
      END IF;
    END IF; -- l_return <> 'N'


  debug_exit(l_proc_name);
  return l_return;

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

END chk_wps_cutover_crit;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_wps_periodic_crit >-------------------|
-- ----------------------------------------------------------------------------

FUNCTION chk_wps_periodic_crit
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    )
  RETURN VARCHAR2
IS
--

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_wps_periodic_crit';

  l_return                       VARCHAR2(1) := 'N';
  l_curr_evt_index               NUMBER;
--  l_element_type_id              NUMBER;
  l_chg_surrogate_key            NUMBER;
  l_update_type                  VARCHAR2(5);
  l_element_entry_id             NUMBER;
  l_entry_type                   VARCHAR2(5);
  l_dated_table_id               NUMBER;
  l_chg_table                    VARCHAR2(61);
  l_chg_column_name              VARCHAR2(61);
  l_return_01                    VARCHAR2(1) := 'N';
  l_opt_out_date                 VARCHAR2(61);
  l_error                        NUMBER;
--
--For Bug 6071527
  l_chk_assignment_id            NUMBER;
  l_wps_eff_end_date             DATE;
  l_assgn_eff_end_date           DATE;
  l_wps_byb_scheme               VARCHAR2(60);

--Bug 7611963: Add cursor to get ele end date
l_surrogate_key        NUMBER;
l_eve_effective_date   DATE;
l_ele_end_date         DATE;

CURSOR csr_get_ele_end_date (c_element_entry_id NUMBER)
IS
  SELECT max(effective_end_date)
  FROM PAY_ELEMENT_ENTRIES_F
  WHERE element_entry_id = c_element_entry_id;

BEGIN

-- trace

  debug_enter(l_proc_name);

  debug('Entering chk_wps_periodic_crit ...',10);
  debug ('p_business_group_id:'||p_business_group_id);
  debug ('p_assignment_id:'||p_assignment_id);
  debug('p_effective_date : ' || p_effective_date);


    -- being called only once in complete extract run
    IF g_business_group_id IS NULL THEN
       -- clear the cached globals
       clear_cache;

      -- for trace switching ON/OFF
      g_debug             := PQP_GB_PSI_FUNCTIONS.check_debug(p_business_group_id);

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
      --g_effective_date := p_effective_date;

      -- setting extract specific globals
      set_wps_history_globals
           (p_business_group_id    =>    p_business_group_id
           ,p_assignment_id        =>    p_assignment_id
           ,p_effective_date       =>    p_effective_date
           );

      g_business_group_id := p_business_group_id;

      debug('now raise setup exceptions ...',15);
      -- raise setup errors and warnings
      PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions(p_extract_type => 'S');

      -- now clearing cache of assign_cat in basic criteria
      --PQP_GB_PSI_FUNCTIONS.g_assign_category_mapping.DELETE;
    END IF; -- shared and basic_data globals have been set

        g_current_run := 'PERIODIC';
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

    IF l_return = 'Y'
    THEN
      debug('Calling the common include event proc');
      -- set the global events table
      g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;
      l_curr_evt_index    :=  ben_ext_person.g_chg_pay_evt_index;
      l_chg_surrogate_key :=  ben_ext_person.g_chg_surrogate_key;
      l_update_type       :=  g_pay_proc_evt_tab(l_curr_evt_index).update_type;
      l_dated_table_id    :=  g_pay_proc_evt_tab(l_curr_evt_index).dated_table_id;
      l_chg_column_name   :=  g_pay_proc_evt_tab(l_curr_evt_index).column_name;
      l_chg_table           :=  pqp_gb_psi_functions.get_dated_table_name(l_dated_table_id);

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


      IF is_curr_evt_processed()  THEN
            l_return   :=  'N';
            debug('Returning : '||l_return,20);
            debug_exit(l_proc_name);
            return l_return;
      END IF;

      l_return := pqp_gb_psi_functions.include_event
                          (p_actual_date => g_pay_proc_evt_tab(l_curr_evt_index).actual_date
                          ,p_effective_date => g_pay_proc_evt_tab(l_curr_evt_index).effective_date
                          );


      debug ('p_assignment_id:'||p_assignment_id);
      debug('include_event returned: '||l_return);
    END IF;

        IF l_return = 'Y'
            THEN
                  --setting assignment globals
      IF (g_assignment_id IS NULL
       OR p_assignment_id <> nvl(g_assignment_id,0))AND l_return = 'Y'
              THEN
      set_assignment_globals
            (
            p_assignment_id         =>    p_assignment_id
            ,p_effective_date       =>    p_effective_date
            );
      END IF;

      pqp_gb_psi_functions.g_effective_date := p_effective_date;
                  debug('g_effective_date: '||g_effective_date);
                  debug('p_effective_date: '||p_effective_date);
                  IF pqp_gb_psi_functions.is_today_sal_start() = 'Y' THEN -- salary start
                              g_is_terminated := 'N'; -- change termination status to N
          IF l_chg_table = 'PER_ALL_ASSIGNMENTS_F' AND l_update_type = 'I'
          THEN
            l_return        := 'N'; -- this event is because of PQP_GB_PSI_NEW_HIRE event group.
          END IF;
                  END IF;
      IF g_is_terminated = 'Y' THEN
                                    l_return := 'N';
                  END IF;
            END IF;

            --calling function to check the pension scheme of the person
    IF l_return = 'Y'
    THEN
      debug('calling function to check the pension scheme of the person');
      --calling function to check the pension scheme of the person
      l_return := PQP_GB_PSI_FUNCTIONS.check_employee_pension_scheme
                    (p_business_group_id        => p_business_group_id
                    ,p_effective_date           => p_effective_date
                    ,p_assignment_id            => p_assignment_id
                    ,p_psi_pension_scheme       => 'CLASSIC'
                    ,p_pension_element_type_id  => g_pension_element_type_id
                    );
      debug('l_return: '||l_return,25);

--****This commented loop is for 'Classic Plus' type of element.****--
/*      IF l_return = 'N' THEN
        l_return := PQP_GB_PSI_FUNCTIONS.check_employee_pension_scheme
                      (p_business_group_id        => p_business_group_id
                      ,p_effective_date           => p_effective_date
                      ,p_assignment_id            => p_assignment_id
                      ,p_psi_pension_scheme       => 'CLASSPLUS'
                      ,p_pension_element_type_id  => g_pension_element_type_id
                      );
      END IF;
      debug('l_return: '||l_return,40);*/
    END IF;


    debug('l_chk_assignment_id : '||l_chk_assignment_id);
    debug('p_assignment_id : '||p_assignment_id);

    -- For Bug 6071527

    IF (l_chk_assignment_id IS NULL OR l_chk_assignment_id <> p_assignment_id)
        AND l_return = 'Y'
    THEN
       OPEN get_wps_ele_scheme_name(p_element_type_id => g_pension_element_type_id
                                    );
       FETCH get_wps_ele_scheme_name into g_pension_scheme_name;

       IF get_wps_ele_scheme_name%NOTFOUND
       THEN
          l_return       := 'N';
       END IF;
       CLOSE get_wps_ele_scheme_name;
       l_chk_assignment_id := p_assignment_id;

    END IF;

    debug('g_pension_scheme_name : '||g_pension_scheme_name);

    l_end_date_basic_ele := 'Y';

     --For Bug 6071527 End

    debug('g_is_terminated: '||g_is_terminated, 30);

            IF l_return = 'Y'
            THEN
                  IF l_chg_table  <> 'PER_ALL_ASSIGNMENTS_F'
                  THEN
                        debug('l_return: '||l_return);
                        IF l_return = 'Y'               --To check if element type is classic type.
                        THEN
                              debug('checking whether this event is of WPS type');
                              --checking whether this event is of WPS type.
                              debug('l_chg_surrogate_key '||l_chg_surrogate_key,25);

                              IF l_update_type = 'C'
                              THEN
                                    debug('correction event');
                                    OPEN csr_get_element_entry_id
                                                      (p_element_entry_value_id => l_chg_surrogate_key
                                                      );
                                    FETCH csr_get_element_entry_id into l_element_entry_id;
                                           IF csr_get_element_entry_id%NOTFOUND
                                           THEN
                                                 debug('element entry id not found for this correction event');
                                                 l_return := 'N';
                                           END IF;
                                    CLOSE csr_get_element_entry_id;
                              ELSE
                                    debug('not a correction event');
                                    l_element_entry_id := l_chg_surrogate_key;
                              END IF;

                            --Bug 7611963: Add chk for reverse terminations
                              IF (l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'
                                  AND l_chg_column_name  = 'EFFECTIVE_END_DATE'
                                  AND l_update_type = 'E')
                              THEN
                                   l_surrogate_key := g_pay_proc_evt_tab(l_curr_evt_index).surrogate_key;
                                   debug('l_surrogate_key :'||l_surrogate_key,23);

                                   l_eve_effective_date := g_pay_proc_evt_tab(l_curr_evt_index).effective_date;
                                   debug('l_eve_effective_date :'||l_eve_effective_date,23);

                                   OPEN csr_get_ele_end_date(l_surrogate_key);
                                   FETCH csr_get_ele_end_date INTO l_ele_end_date;
                                   CLOSE csr_get_ele_end_date;

                                   debug('l_ele_end_date :'||l_ele_end_date,23);

                                   IF l_ele_end_date <> l_eve_effective_date
                                   THEN
                                        l_return   :=  'N';
                                        debug('l_return : '||l_return,23);
                                   END IF;
                              END IF;
                              --Bug 7611963: End

                              IF l_return = 'Y'
                              THEN
                                    debug('element entry id '||l_element_entry_id);
                                    OPEN csr_get_element_type_id
                                                 (c_element_entry_id => l_element_entry_id
                                                 );
                                    FETCH csr_get_element_type_id INTO l_element_type_id;
                                          IF csr_get_element_type_id%NOTFOUND
                                          THEN
                                                debug('element_type_id not found', 10);
                                                l_return         := 'N';
                                          ELSE
                                                debug('l_element_type_id : ' || l_element_type_id, 10);
                                                debug('g_pension_element_type_id : ' || g_pension_element_type_id, 20);

                                                --For Bug 6071527
                                                IF l_element_type_id <> g_pension_element_type_id
                                                THEN

                                                   OPEN get_wps_byb_ele_scheme_name(p_element_type_id => l_element_type_id
                                                                                   ,p_pension_scheme_name => g_pension_scheme_name
                                                                                    );
                                                   FETCH get_wps_byb_ele_scheme_name INTO l_wps_byb_scheme;
                                                   IF get_wps_byb_ele_scheme_name%NOTFOUND
                                                   THEN
                                                      l_return       := 'N';
                                                   ELSE
                                                      l_return       := 'Y';
                                                   END IF;
                                                   CLOSE get_wps_byb_ele_scheme_name;

                                                   IF l_update_type = 'E' and l_return = 'Y'
                                                   THEN
                                                      l_wps_eff_end_date := p_effective_date + 1;

                                                      OPEN get_wps_eff_end_date(p_element_type_id => g_pension_element_type_id
                                                                               ,p_assignment_id => p_assignment_id
                                                                               ,p_effective_date => l_wps_eff_end_date);

                                                      Fetch get_wps_eff_end_date into l_wps_eff_end_date;
                                                      IF get_wps_eff_end_date%NOTFOUND
                                                      THEN
                                                         l_return       := 'N';
                                                       ELSE
                                                         l_end_date_basic_ele :='N';
                                                      END IF;
                                                      CLOSE get_wps_eff_end_date;
                                                      debug('l_wps_eff_end_date : ' || l_wps_eff_end_date, 31);
                                                      debug('l_end_date_basic_ele : ' || l_end_date_basic_ele, 32);

                                                      IF l_return = 'Y'
                                                      THEN
                                                         OPEN get_assgn_eff_end_date(p_assignment_id => p_assignment_id
                                                                                    ,p_effective_date => p_effective_date);
                                                         Fetch get_assgn_eff_end_date into l_assgn_eff_end_date;
                                                         IF get_assgn_eff_end_date%FOUND
                                                         THEN
                                                            l_return       := 'N';
                                                         END IF;
                                                         CLOSE get_assgn_eff_end_date;
                                                         debug('l_assgn_eff_end_date : ' || l_assgn_eff_end_date, 33);
                                                      END IF;
                                                   END IF;

                                                ELSE
                                                    l_return       := 'Y';
                                                END IF;
                                                --For Bug 6071527 End
                                                debug('l_return : ' || l_return, 30);
                                          END IF; -- csr_get_element_type_id%NOTFOUND
                                    CLOSE csr_get_element_type_id;
                              END IF;
                        END IF;

                        --To check if the event is of 'override'. such events are to be discarded.
                        IF l_return = 'Y'
                        THEN
                              OPEN csr_get_entry_type
                                                (p_element_entry_id => l_element_entry_id
                                                 ,p_effective_date  => p_effective_date
                                                );
                              FETCH csr_get_entry_type INTO l_entry_type;
                              IF csr_get_entry_type%NOTFOUND
                              THEN
                                    debug('entry_type not found');
                                    l_return         := 'N';
                              ELSE
                                    debug('l_entry_type : ' ||l_entry_type);
                                    IF l_entry_type = 'S'
                                    THEN
                                          l_return := 'N';
                                    END IF;
                              END IF;
                              CLOSE csr_get_entry_type;
                        END IF;
                  END IF;
            END IF;

    --Final Check -- if Opt Out Date is before the event date then reject and raise warning.
    IF l_return = 'Y'
    THEN
      OPEN get_wps_percent_cont_cut
             (p_assignment_id   => p_assignment_id
             ,p_effective_date  => p_effective_date
             ,p_element_type_id => g_pension_element_type_id
             ,p_input_value_name=> 'Opt Out Date'
             );
      FETCH get_wps_percent_cont_cut INTO l_opt_out_date,l_element_entry_id;
      IF get_wps_percent_cont_cut%NOTFOUND
      THEN
        l_opt_out_date            := NULL;
        debug('get_wps_percent_cont_cut NOTFOUND for opt out date');
      END IF;
      IF l_opt_out_date IS NOT NULL
      THEN
        IF p_effective_date > TO_DATE(SUBSTR(l_opt_out_date,1,10),'yyyy/mm/dd')
        THEN
          l_return := 'N';
          l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                               (p_error_number => 94594
                               ,p_error_text => 'BEN_94594_OPTED_OUT_OF_SCHEME'
                               ,p_token1 => to_char(p_effective_date,'DD/MM/YYYY')
                               ,p_token2 => to_char(TO_DATE(SUBSTR(l_opt_out_date,1,10),'YYYY/MM/DD'),'DD/MM/YYYY')
                               );
          debug('Event is after the opt out date');
        END IF;
      END IF;
      CLOSE get_wps_percent_cont_cut;
    END IF;

    IF l_return = 'Y' THEN
      pqp_gb_psi_functions.process_retro_event(p_include => l_return);

      IF pqp_gb_psi_functions.is_today_sal_end() = 'Y' THEN -- salary end
                g_is_terminated := 'Y'; -- change termination status to 'Y'
        debug('Salary Ended Today');

        -- For Bug 6033545
        IF (l_chg_table = 'PER_ALL_ASSIGNMENTS_F' or l_chg_table = 'PAY_ELEMENT_ENTRIES_F')
            AND l_chg_column_name = 'EFFECTIVE_END_DATE'
        THEN
          l_return := 'N';
        END IF;

      ELSE
        -- if the event is on assignment_status_type_id
        -- reject the event
        debug('Salary not Ended Today');
        debug('l_chg_table: '||l_chg_table, 10);
        debug('l_chg_column_name: '||l_chg_column_name, 20);
        IF l_chg_table = 'PER_ALL_ASSIGNMENTS_F'
        AND l_chg_column_name = 'ASSIGNMENT_STATUS_TYPE_ID' THEN
          l_return := 'N';
        END IF;
      END IF;
    END IF;
    debug('g_is_terminated: '||g_is_terminated, 40);

    IF l_return <> 'N' -- no need to set alt_key for person not picked up
    THEN
      -- to ensure that this is called only once for an assignment
      IF g_assignment_id IS NULL
         OR
         (
         g_assignment_id IS NOT NULL and g_assignment_id <> p_assignment_id
         ) THEN
         -- put a fucntion here which is to be called only once per person
         g_altkey :=
              PQP_GB_PSI_FUNCTIONS.altkey;
                  --(p_assignment_number  => g_assignment_dtl.assignment_number
                  --,p_paypoint           => g_paypoint
                  --);
        g_assignment_id := p_assignment_id;
        debug('this is a new assignment, need to set globals',15);
      ELSE
        debug('this is the same assignment, NO need to set globals',15);
      END IF;
    END IF; -- l_return <> 'N'

  debug_exit(l_proc_name);
  return l_return;

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

END chk_wps_periodic_crit;

-- ----------------------------------------------------------------------------
-- |------------------------< get_wpsPercent >-------------------------|
-- ----------------------------------------------------------------------------
  FUNCTION get_wpsPercent
    (p_business_group_id        IN         NUMBER  -- context
    ,p_effective_date           IN         DATE    -- context
    ,p_assignment_id            IN         NUMBER  -- context
    )
  RETURN VARCHAR2 IS
    l_proc_name           VARCHAR2(61):=
         g_proc_name||'get_wpsPercent';
    l_value number;
    l_effective_start_date VARCHAR2(60);
    l_effective_end_date   VARCHAR2(60);
    l_element_entry_id     NUMBER;
    l_chg_surrogate_key    NUMBER;
    l_update_type          VARCHAR2(5);
    l_curr_evt_index       NUMBER;
    l_effective_date       DATE;
    wps_percent            VARCHAR2(60);
    l_start_date           DATE;
    l_end_date             DATE;
    l_return               NUMBER;
    l_flag                 BOOLEAN := TRUE;      --To check l_element_id.
            l_dated_table_id               NUMBER;
            l_chg_table            VARCHAR2(61);

--For Bug 6071527
   wps_byb_percent        VARCHAR2(60) := '0';
   l_g_effective_date     DATE;
   l_chg_column_name   VARCHAR2(61);

  BEGIN
            debug_enter(l_proc_name);
            debug('g_current_run: '||g_current_run);
    IF g_current_run = 'PERIODIC'
    THEN
      g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;
      l_curr_evt_index    :=  ben_ext_person.g_chg_pay_evt_index;
      l_chg_surrogate_key :=  ben_ext_person.g_chg_surrogate_key;
      l_update_type       :=  g_pay_proc_evt_tab(l_curr_evt_index).update_type;
      l_dated_table_id    :=  g_pay_proc_evt_tab(l_curr_evt_index).dated_table_id;
      l_chg_table         :=  pqp_gb_psi_functions.get_dated_table_name(l_dated_table_id);

--For Bug 6071527
      l_chg_column_name   :=  g_pay_proc_evt_tab(l_curr_evt_index).column_name;

      debug('l_chg_column_name    :-'||l_chg_column_name );
      debug('l_update_type   :-'||l_update_type);

      IF l_element_type_id <> g_pension_element_type_id and l_update_type = 'E'
         and l_end_date_basic_ele = 'N'
      THEN
         l_g_effective_date := p_effective_date + 1;
      ELSE
         l_g_effective_date := p_effective_date;
      END IF;
--For Bug 6071527 End

                  debug('l_chg_table   :-'||l_chg_table);

                  IF  l_chg_table <> 'PER_ALL_ASSIGNMENTS_F'
                  THEN
                        debug('l_update_type:-'||l_update_type);
                        IF l_update_type = 'C'
                        THEN
                              debug('correction event');
                              OPEN csr_get_element_entry_id
                                                (p_element_entry_value_id => l_chg_surrogate_key
                                                );
                              FETCH csr_get_element_entry_id into l_element_entry_id;
                                     IF csr_get_element_entry_id%NOTFOUND
                                     THEN
                                           debug('element entry id not found for this correction event');
                                           l_flag := FALSE;
                                     END IF;
                              CLOSE csr_get_element_entry_id;
                        ELSE
                              debug('not a correction event');
                              l_element_entry_id := l_chg_surrogate_key;
                        END IF;
                        IF l_flag = TRUE
                        THEN
                          --For Bug 6071527
                           OPEN get_wps_percent_cont(p_assignment_id   => p_assignment_id
                                                    ,p_effective_date  => l_g_effective_date -- p_effective_date
                                                    ,p_element_type_id => g_pension_element_type_id
                                                    ,p_input_value_name=> 'Contribution Percent'
                                                     );
                           FETCH get_wps_percent_cont INTO wps_percent;
                           IF get_wps_percent_cont%NOTFOUND
                           THEN
                              wps_percent            := '0';
                           END IF;
                           CLOSE get_wps_percent_cont;

                           OPEN get_wps_byb_percent_cont(p_effective_date   => l_g_effective_date --p_effective_date
                                                        ,p_assignment_id     => p_assignment_id
                                                        ,p_input_value_name => 'Contribution Percent'
                                                        ,p_scheme_name      => g_pension_scheme_name
                                                        );
                           FETCH get_wps_byb_percent_cont into wps_byb_percent;
                           IF get_wps_byb_percent_cont%NOTFOUND
                           THEN
                              wps_byb_percent            := '0';
                           END IF;
                           CLOSE get_wps_byb_percent_cont;

                           debug('wps_byb_percent: '||wps_byb_percent);
                           wps_percent  := wps_percent + wps_byb_percent;
                           --For Bug 6071527 End

                        END IF;
                  END IF;
            END IF;
    IF g_current_run = 'CUTOVER' OR
                                    (l_chg_table = 'PER_ALL_ASSIGNMENTS_F' AND g_current_run = 'PERIODIC')
    THEN
       --For Bug 6071527
       IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
          AND
          l_chg_column_name  = 'ASSIGNMENT_STATUS_TYPE_ID'
          AND
          g_is_terminated = 'Y')
       THEN
          l_g_effective_date := p_effective_date -1;
       ELSE
          l_g_effective_date := p_effective_date;
       END IF;
       --For Bug 6071527 End

       debug('p_effective_date: '||p_effective_date);
       debug('l_g_effective_date: '||l_g_effective_date);
       debug('g_is_terminated: '||g_is_terminated);

      OPEN get_wps_percent_cont_cut
           (p_assignment_id   => p_assignment_id
           ,p_effective_date  => l_g_effective_date --p_effective_date
                               ,p_element_type_id => g_pension_element_type_id
           ,p_input_value_name=> 'Contribution Percent'
           );
      FETCH get_wps_percent_cont_cut INTO wps_percent,l_element_entry_id;
      IF get_wps_percent_cont_cut%NOTFOUND
      THEN
        wps_percent            := '0';
                        debug('get_wps_percent_cont_cut NOTFOUND');
      END IF;
      CLOSE get_wps_percent_cont_cut;

      debug('wps_percent: '||wps_percent);

     --For Bug 6071527

      OPEN get_wps_byb_percent_cont(p_effective_date   => l_g_effective_date --p_effective_date
                                   ,p_assignment_id     => p_assignment_id
                                   ,p_input_value_name => 'Contribution Percent'
                                   ,p_scheme_name      => g_pension_scheme_name
                                   );
      FETCH get_wps_byb_percent_cont into wps_byb_percent;
      IF get_wps_byb_percent_cont%NOTFOUND
      THEN
         wps_byb_percent            := '0';
      END IF;
      CLOSE get_wps_byb_percent_cont;

      debug('wps_byb_percent: '||wps_byb_percent);
      wps_percent  := wps_percent + wps_byb_percent;
      --For Bug 6071527 End
    END IF;
            debug('wps_percent: '||wps_percent);
            debug_exit(l_proc_name);
    RETURN wps_percent;
 END get_wpsPercent;

-- ----------------------------------------------------------------------------
-- |------------------------< get_start_end_date >-------------------------|
-- ----------------------------------------------------------------------------
  FUNCTION get_start_end_date
    (p_business_group_id        IN         NUMBER
    ,p_effective_date           IN         DATE
    ,p_assignment_id            IN         NUMBER
    ,p_effective_start_date     OUT NOCOPY VARCHAR2
    ,p_effective_end_date       OUT NOCOPY VARCHAR2
    )
  RETURN NUMBER IS
    l_proc_name           VARCHAR2(61):=
         g_proc_name||'get_start_end_date';
      l_value number;
      l_effective_start_date VARCHAR2(60);
      l_effective_end_date   VARCHAR2(60);
      l_element_entry_id     NUMBER;
      l_chg_surrogate_key    NUMBER;
      l_update_type          VARCHAR2(5);
      l_curr_evt_index       NUMBER;
      l_effective_date       DATE;
      wps_percent            VARCHAR2(60);
      opt_out_date           VARCHAR2(60);
      l_start_date           DATE;
      l_end_date             DATE;
      l_return               NUMBER;
      l_flag                 BOOLEAN := TRUE;      --To check l_element_id.

      -- For Bug 5998123
      l_dated_table_id       NUMBER;
      l_chg_table            VARCHAR2(61);
      l_chg_column_name      VARCHAR2(61);

      --For Bug 6071527
      l_g_effective_date     DATE;

  BEGIN
    debug_enter(l_proc_name);
    IF g_current_run = 'PERIODIC'
    THEN
      g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;
      l_curr_evt_index    :=  ben_ext_person.g_chg_pay_evt_index;
      l_chg_surrogate_key :=  ben_ext_person.g_chg_surrogate_key;
      l_update_type       :=  g_pay_proc_evt_tab(l_curr_evt_index).update_type;

      -- For Bug 5998123
      l_dated_table_id    :=  g_pay_proc_evt_tab(l_curr_evt_index).dated_table_id;
      l_chg_column_name   :=  g_pay_proc_evt_tab(l_curr_evt_index).column_name;
      l_chg_table           :=  pqp_gb_psi_functions.get_dated_table_name(l_dated_table_id);


      --debug('g_pay_proc_evt_tab: '||g_pay_proc_evt_tab);
      debug('l_update_type:-'||l_update_type);

      --For Bug 6071527
      IF l_element_type_id <> g_pension_element_type_id and l_update_type = 'E'
      and l_end_date_basic_ele = 'N'
      THEN
         l_g_effective_date := p_effective_date + 1;
      ELSE
         l_g_effective_date := p_effective_date;
      END IF;
      --For Bug 6071527 End

      p_effective_start_date := to_char(l_g_effective_date,'DD/MM/YYYY');
      p_effective_end_date   := NULL;


      IF (l_update_type = 'E' AND l_element_type_id = g_pension_element_type_id)  --For Bug 6071527
      or g_is_terminated = 'Y'
      THEN
        OPEN get_wps_percent_cont_per
                                          (p_element_entry_id => l_chg_surrogate_key
                                          ,p_effective_date   => p_effective_date
              ,p_input_value_name => 'Opt Out Date'
                                          );
                        FETCH get_wps_percent_cont_per INTO opt_out_date;
                        IF get_wps_percent_cont_per%NOTFOUND
                        THEN
          p_effective_end_date := to_char(p_effective_date,'DD/MM/YYYY');
        ELSIF opt_out_date IS NULL
        THEN
          p_effective_end_date := to_char(p_effective_date,'DD/MM/YYYY');
        ELSE
          p_effective_end_date := to_char(least(p_effective_date,TO_DATE(SUBSTR(opt_out_date,1,10),'yyyy/mm/dd')),'DD/MM/YYYY');
        END IF;
        CLOSE get_wps_percent_cont_per;
        p_effective_start_date := p_effective_end_date;

      END IF;

        -- For Bug 5998123

        IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
            AND
            l_chg_column_name  = 'ASSIGNMENT_STATUS_TYPE_ID'
            AND
            p_effective_start_date = p_effective_end_date
            AND
            g_is_terminated = 'Y')
        THEN
            p_effective_start_date := to_char(to_date(p_effective_start_date,'DD/MM/YYYY')-1,'DD/MM/YYYY');
            p_effective_end_date   := p_effective_start_date;

        END IF;


    ELSIF g_current_run = 'CUTOVER'
    THEN
      p_effective_end_date   := NULL;
      debug('p_business_group_id'||p_business_group_id,1);
                  debug('p_effective_date'||p_effective_date,1);
                  debug('p_assignment_id'|| p_assignment_id,1);
                  debug('g_pension_element_type_id'||g_pension_element_type_id,1);
                  OPEN get_wps_percent_cont_cut
           (p_assignment_id   => p_assignment_id
           ,p_effective_date  => p_effective_date
                               ,p_element_type_id => g_pension_element_type_id
           ,p_input_value_name=> 'Contribution Percent'
           );
      FETCH get_wps_percent_cont_cut INTO wps_percent,l_element_entry_id;
      IF get_wps_percent_cont_cut%NOTFOUND
      THEN
        p_effective_start_date := NULL;
                        debug('get_wps_percent_cont_cut NOTFOUND');

      ELSE
        debug('get_wps_percent_cont_cut FOUND');
                        OPEN csr_get_start_date_cut
              (p_element_entry_id => l_element_entry_id
              );
        FETCH csr_get_start_date_cut INTO l_start_date;
        IF csr_get_start_date_cut%NOTFOUND
        THEN
          p_effective_start_date := NULL;
                              debug('csr_get_start_date_cut NOTFOUND');
        ELSE
          p_effective_start_date := to_char(l_start_date,'DD/MM/YYYY');
        END IF;
        CLOSE csr_get_start_date_cut;
      END IF;
      CLOSE get_wps_percent_cont_cut;
    ELSE
      debug('g_current_run :'||g_current_run||'is not valid');
    END IF;
            debug_exit(l_proc_name);
    RETURN 0;
 END get_start_end_date;

-- ----------------------------------------------------------------------------
-- |------------------------< wps_history_main >-------------------------|
-- ----------------------------------------------------------------------------

  FUNCTION wps_history_main
    (p_business_group_id        IN         NUMBER  -- context
    ,p_effective_date           IN         DATE    -- context
    ,p_assignment_id            IN         NUMBER  -- context
    ,p_rule_parameter           IN         VARCHAR2 -- parameter
    ,p_output                   OUT NOCOPY VARCHAR2
    )
  RETURN NUMBER IS
  --

      l_proc_name           VARCHAR2(61):=
           g_proc_name||'wps_history_main';
      l_value number;
      l_effective_start_date VARCHAR2(60);
      l_effective_end_date   VARCHAR2(60);
      l_element_entry_id     NUMBER;
      l_chg_surrogate_key    NUMBER;
      l_update_type          VARCHAR2(5);
      l_curr_evt_index       NUMBER;
      l_effective_date       DATE;
      wps_percent            VARCHAR2(60);
      l_start_date           DATE;
      l_end_date             DATE;
      l_return               NUMBER;
      l_flag                 BOOLEAN := TRUE;      --To check l_element_id.
      l_error                NUMBER;
      l_element_name         VARCHAR2(80);
  --
  BEGIN

  debug_enter(l_proc_name);

  -- switch on the trace

    debug('Entering wps_history_main ...',0);
    debug('p_business_group_id'||p_business_group_id,1);
    debug('p_effective_date'||p_effective_date,1);
    debug('p_assignment_id'|| p_assignment_id,1);
    debug('p_rule_parameter'||p_rule_parameter,1);

   -- select the function call based on the parameter being passed to the rule
    IF p_rule_parameter = 'WPSPercent'
    THEN
      debug('Fetching WPS percent Contribution',20);
      wps_percent := get_wpsPercent(p_business_group_id      => p_business_group_id
                                   ,p_effective_date        => p_effective_date
                                   ,p_assignment_id         => p_assignment_id
                                   );
      IF wps_percent IS NULL
      THEN
        OPEN get_wps_element_name
              (p_element_type_id => g_pension_element_type_id
              );
        FETCH get_wps_element_name INTO l_element_name;
        IF get_wps_element_name%FOUND
        THEN
          l_error := PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                       (p_error_number => 94532
                                       ,p_error_text => 'BEN_94532_NO_ENTRY_VALUE'
                                       ,p_token1 => l_element_name
                                       ,p_token2 => 'CONTRIBUTION PERCENT'
                                       ,p_token3 => to_char(p_effective_date,'DD/MM/YYYY')
                                       );
        ELSE
          debug('Element Name Not Found',30);
        END IF;
        CLOSE get_wps_element_name;
        wps_percent := '0000000';
      ELSIF (fnd_number.canonical_to_number(wps_percent) > 100)
      THEN
        l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                                       (p_error_number => 94533
                                       ,p_error_text => 'BEN_94533_IMPRACTICABLE_VALUE'
                                       ,p_token1 => wps_percent
                                       );
        wps_percent := rtrim(ltrim(to_char(fnd_number.canonical_to_number(wps_percent),'0999D99')));
      ELSIF (fnd_number.canonical_to_number(wps_percent) < 0)
      THEN
        l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                                       (p_error_number => 94533
                                       ,p_error_text => 'BEN_94533_IMPRACTICABLE_VALUE'
                                       ,p_token1 => wps_percent
                                       );
        wps_percent := rtrim(ltrim(to_char(fnd_number.canonical_to_number(wps_percent),'099D99')));
      ELSE
        wps_percent := rtrim(ltrim(to_char(fnd_number.canonical_to_number(wps_percent),'0999D99')));
      END IF;

      p_output := wps_percent;
      debug('p_output '||p_output);

    ELSIF p_rule_parameter = 'WPSStartDate' THEN
      l_return := get_start_end_date(p_business_group_id  => p_business_group_id
                                 ,p_effective_date        => p_effective_date
                                 ,p_assignment_id         => p_assignment_id
                                 ,p_effective_start_date  => l_effective_start_date
                                 ,p_effective_end_date    => l_effective_end_date
                                 );
      p_output := l_effective_start_date;
                  debug('p_output '||p_output);
    ELSIF p_rule_parameter = 'WPSEndDate' THEN
      l_return := get_start_end_date(p_business_group_id => p_business_group_id
                                 ,p_effective_date       => p_effective_date
                                 ,p_assignment_id        => p_assignment_id
                                 ,p_effective_start_date => l_effective_start_date
                                 ,p_effective_end_date   => l_effective_end_date
                                 );
      p_output := l_effective_end_date;
      debug('p_output '||p_output);
    ELSE
      p_output := ' ';
      debug('p_output '||p_output);
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

  END wps_history_main;

          -- ----------------------------------------------------------------------------
    -- |----------------------< wps_post_processing >--------------------------|
    --  Description:  This is the post-processing rule  for the WPS History.
    -- ----------------------------------------------------------------------------
    FUNCTION wps_post_processing RETURN VARCHAR2
    IS
        l_proc_name varchar2(72) := g_proc_name||'.wps_post_processing';
    BEGIN
        debug_enter(l_proc_name);

        --Raise extract exceptions which are stored while processing the data elements
        --PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions();

        PQP_GB_PSI_FUNCTIONS.common_post_process(p_business_group_id => g_business_group_id);
        debug_exit(l_proc_name);
        return 'Y';
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
    END wps_post_processing;
    ------
    ------
END PQP_GB_PSI_WPS_HISTORY;

/
