--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_BASIC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_BASIC_DATA" AS
--  /* $Header: pqpgbpsibas.pkb 120.5.12010000.3 2009/09/09 05:14:00 jvaradra ship $ */



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

    g_bank_detail_report_y_n  := NULL;
    --g_current_run             := NULL;
    g_altkey                  := NULL;

    -- globals set by set_shared_globals
    g_paypoint                := NULL;
    g_cutover_date            := NULL;
    g_ext_dfn_id              := NULL;

  --
    g_marital_status_mapping.DELETE;


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
-- |------------------------< set_basic_data_globals >----------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE set_basic_data_globals
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    )
  IS
  --

    l_proc_name           VARCHAR2(61):=
     g_proc_name||'set_basic_data_globals';

    l_person_id               NUMBER        := NULL;
    l_bank_detail_report_y_n  VARCHAR2(2)   := NULL;
    l_assignment_number       VARCHAR2(30)  := NULL;

    -- table of records for configuration types

      l_pay_point_config_value        pqp_utilities.t_config_values;
      l_cutover_date_config_value     pqp_utilities.t_config_values;
      l_bank_details_yn_config_value  pqp_utilities.t_config_values;
    l_config_value                  pqp_utilities.t_config_values;

      i NUMBER;
      l_index NUMBER;
  --
  BEGIN

  debug_enter(l_proc_name);

    debug('Entering set_basic_data_globals ...',10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_assignment_id:'||p_assignment_id);



    -- fetch configuration value for bank_detail_reporting_y_n
    debug('Fetching configuration value for bank details ...', 60);
    pqp_utilities.get_config_type_values
                   ( p_configuration_type   => 'PQP_GB_PENSERVER_BANKACC_DTLS'
                                ,p_business_group_id    => p_business_group_id
                                ,p_legislation_code     => NULL
                                ,p_tab_config_values    => l_config_value
                     );

      IF l_config_value.COUNT > 0 -- config value found
      THEN
        g_bank_detail_report_y_n := l_config_value(l_config_value.FIRST).pcv_information1;        --
      ELSE
        debug('g_bank_detail_report_y_n was not found in the config level',65);
        g_bank_detail_report_y_n := 'N';
      END IF;


    -- fetch configuration value for employment type mapping
    debug('Fetching configuration value for marital status mapping ...', 40);

    pqp_utilities.get_config_type_values
             ( p_configuration_type   => 'PQP_GB_PENSERVER_MAR_STAT_MAP'
              ,p_business_group_id    => p_business_group_id
              ,p_legislation_code     => NULL
              ,p_tab_config_values    => g_marital_status_mapping --caching in global
                                                                   -- for future use
             );

  debug('Exiting set_basic_data_globals ...',60);
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

  END set_basic_data_globals;



-- ----------------------------------------------------------------------------
-- |------------------------< chk_basic_data_cutover_crit >-------------------|
-- ----------------------------------------------------------------------------

FUNCTION chk_basic_data_cutover_crit
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    )
  RETURN VARCHAR2
IS
--
  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_basic_data_cutover_crit';

  l_return              VARCHAR2(1) := 'N';
--
BEGIN

-- trace

  debug_enter(l_proc_name);

  debug('Entering chk_basic_data_cutover_crit ...',10);
  debug ('p_business_group_id:'||p_business_group_id);
  debug ('p_assignment_id:'||p_assignment_id);

  g_current_run := 'CUTOVER';

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
      -- (1) g_bank_detail_report_y_n = Y/N
      set_basic_data_globals
           (p_business_group_id => p_business_group_id
           ,p_effective_date    => p_effective_date
           ,p_assignment_id     => p_assignment_id
           );

      g_business_group_id := p_business_group_id;

      debug('now raise setup exceptions ...',15);
      -- raise setup errors and warnings
      PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions(p_extract_type => 'S');

      -- now clearing cache of assign_cat in basic criteria
      --PQP_GB_PSI_FUNCTIONS.g_assign_category_mapping.DELETE;
    END IF; -- shared and basic_data globals have been set


    -- calling the basic criteria for this person assignment
    l_return :=
      PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
          (p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date
          ,p_assignment_id      => p_assignment_id
          ,p_person_dtl         => g_person_dtl
          ,p_assignment_dtl     => g_assignment_dtl
          );

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

END chk_basic_data_cutover_crit;




-- ----------------------------------------------------------------------------
-- |------------------------< chk_basic_data_periodic_crit >--------------------|
-- ----------------------------------------------------------------------------

FUNCTION chk_basic_data_periodic_crit
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    )
  RETURN VARCHAR2
IS

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_basic_data_periodic_crit';

  l_return              VARCHAR2(1) := 'N';
  l_curr_evt_index      NUMBER;

BEGIN


  debug_enter(l_proc_name);

  debug('Entering chk_basic_data_periodic_crit ...',10);
  debug ('p_business_group_id:'||p_business_group_id);
  debug ('p_assignment_id:'||p_assignment_id);

  debug ('g_business_group_id:'||g_business_group_id);

  g_current_run := 'PERIODIC';

    -- being called only once in complete extract run
    IF g_business_group_id IS NULL THEN
      -- clearing cache
      clear_cache();

      -- for switching trace ON/OFF
      g_debug             := pqp_gb_psi_functions.check_debug(p_business_group_id);
      -- setting shared globals
      -- 1) paypoint
      -- 2) cutover date
      -- 3) extract def id
      PQP_GB_PSI_FUNCTIONS.set_shared_globals
           (p_business_group_id => p_business_group_id
           ,p_paypoint          => g_paypoint
           ,p_cutover_date      => g_cutover_date
           ,p_ext_dfn_id        => g_ext_dfn_id
           );

      -- setting extract specific globals
      -- (1) g_bank_detail_report_y_n = Y/N
      set_basic_data_globals
           (p_business_group_id => p_business_group_id
           ,p_effective_date    => p_effective_date
           ,p_assignment_id     => p_assignment_id
           );

      g_business_group_id := p_business_group_id;


      debug('now raise setup exceptions ...',15);
      -- raise setup errors and warnings
      PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions(p_extract_type => 'S');

    END IF; -- shared and basic_data globals have been set




    -- calling the basic criteria for this person assignment
    l_return :=
      PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
          (p_business_group_id  => p_business_group_id
          ,p_effective_date     => p_effective_date
          ,p_assignment_id      => p_assignment_id
          ,p_person_dtl         => g_person_dtl
          ,p_assignment_dtl     => g_assignment_dtl
          );


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

    -- calling include_event
    debug('Calling the common include event proc');

    debug('include_event returned: '||l_return);

    IF l_return = 'N' THEN
       debug('Returning : '||l_return,20);
       debug_exit(l_proc_name);
       return l_return;
    END IF; --IF l_include = 'N'

    l_return := pqp_gb_psi_functions.include_event
                       (p_actual_date => g_pay_proc_evt_tab(l_curr_evt_index).actual_date
                       ,p_effective_date => g_pay_proc_evt_tab(l_curr_evt_index).effective_date
                       );




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

         -- For Bug 8790100
         -- Reset the global values for every new assignment.

         g_title_change_exists    := 'N';
         g_honors_change_exists   := 'N';
         g_location_change_exists := 'N';
         g_prevsur_change_exists  := 'N';
         g_midname_change_exists  := 'N';

        IF g_debug
        THEN
          -- only for debugging
          show_events;
        END IF;

        debug('this is a new assignment, need to set globals',15);
      ELSE
        debug('this is the same assignment, NO need to set globals',15);
      END IF;
    END IF; -- l_return <> 'N'



  debug('Exiting chk_basic_data_cutover_crit ...',20);
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

END chk_basic_data_periodic_crit;






-- ----------------------------------------------------------------------------
-- |------------------------< Location >--------------------------------------|
-- ----------------------------------------------------------------------------
  FUNCTION location
    (p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_assignment_id        IN NUMBER
    ,p_return               IN OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --
      l_proc_name           VARCHAR2(61):=
           g_proc_name||'location';
      l_location_code hr_location_extra_info.lei_information2%TYPE;
      l_value NUMBER;
      -- For bug 8790100
      l_ret_location varchar2(30);
  --
  BEGIN

  debug_enter(l_proc_name);

  debug('Entering location ...',10);
  debug ('p_business_group_id:'||p_business_group_id);
  debug ('p_effective_date:'||p_effective_date);
  debug ('p_assignment_id:'||p_assignment_id);
  debug('Fetching location code ....',10);

  --BEGIN FOR Bug 8790100

  debug('g_assignment_dtl.location_id ....'||g_assignment_dtl.location_id,10);
  -- check if location is present on this assignment

  IF g_assignment_dtl.location_id IS NOT NULL
  THEN

     -- fetch location code for this location
     OPEN  csr_location_code
           (p_location_id  => g_assignment_dtl.location_id -- IN
           );
     FETCH csr_location_code into l_location_code;
        IF csr_location_code%FOUND
        THEN
           debug('l_location_code:' || l_location_code, 20);

           IF NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> l_location_code)
           THEN
              l_value := PQP_GB_PSI_FUNCTIONS.raise_extract_error
                           (p_error_number        =>    94476
                           ,p_error_text          =>    'BEN_94476_INV_LOC_CODE'
                           ,p_token1              =>    p_effective_date
                           );
           END IF;

          l_ret_location := l_location_code;
        ELSE
           --ERR : no location code found for this location
           debug('ERROR!!! : no location code found for this location', 20);
           -- store error for 'NO Location Code'
           l_value := PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                        (p_error_number        =>    94475
                        ,p_error_text          =>    'BEN_94475_NO_LOCATION_CODE'
                        ,p_token1              =>    p_effective_date
                        );
             l_ret_location := '  ';
        END IF;
     CLOSE csr_location_code;

  ELSE -- no location on assignment

     l_ret_location := ' '; --NULL;

  END IF;

  IF l_ret_location = ' '
  THEN

     IF g_current_run = 'PERIODIC'
     THEN

        IF g_location_change_exists = 'Y'
        THEN
           l_ret_location := '******';
        ELSE

           debug('location:' || l_ret_location, 30);
           debug('ben_ext_person.g_chg_pay_table:' || ben_ext_person.g_chg_pay_table, 30);
           debug('ben_ext_person.g_chg_pay_column:' || ben_ext_person.g_chg_pay_column, 30);
           debug('ben_ext_person.g_chg_update_type:' || ben_ext_person.g_chg_update_type, 30);

           --
           IF ben_ext_person.g_chg_pay_table = 'PER_ALL_ASSIGNMENTS_F'
           AND ben_ext_person.g_chg_pay_column = 'LOCATION_ID'
           AND ben_ext_person.g_chg_update_type <> 'I'
           THEN -- this is checking location_event for case (3) and (4)

              l_ret_location := '******';
              g_location_change_exists := 'Y';

           ELSE
              l_ret_location := ' ';

           END IF;

        END IF;
     ELSE
         l_ret_location := '******';
     END IF;
  END IF;

  p_return := l_ret_location;


  debug('p_return (location function)' || p_return, 30);
  debug('Exiting location ...',40);

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

  END location;

-- ----------------------------------------------------------------------------
-- |------------------------< age_verification_indicator >--------------------|
-- ----------------------------------------------------------------------------
  FUNCTION age_verification_indicator
    (p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_person_id            IN NUMBER
    ,p_return               IN OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --
      l_proc_name           VARCHAR2(61):=
           g_proc_name||'age_verification_indicator';
      l_age_verification_indicator per_all_people_f.date_employee_data_verified%TYPE;
  --
  BEGIN

  debug_enter(l_proc_name);

    debug('Entering age_verification_indicator ...',10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_person_id:'||p_person_id);

    -- cursor to fetch employee data verification date
      IF g_person_dtl.date_employee_data_verified IS NOT NULL
      THEN
        debug('verification date found :' || l_age_verification_indicator,30);
        p_return := 'Y';
      ELSE
        debug('verification date not found, setting p_return to N',30);
        p_return := 'N';
      END IF;

    debug('p_return (age_verification_indicator function)' || p_return, 40);
    debug('Exiting age_verification_indicator ...',50);


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

  END age_verification_indicator;


-- ----------------------------------------------------------------------------
-- |------------------------< person_decoration >-----------------------------|
-- ----------------------------------------------------------------------------
  FUNCTION person_decoration
    (p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_person_id            IN NUMBER
    ,p_return               IN OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --
      l_proc_name           VARCHAR2(61):=
           g_proc_name||'person_decoration';
      l_person_decoration per_all_people_f.honors%TYPE;
      -- For Bug 8790100
      l_ret_person_decoration per_all_people_f.honors%TYPE;
  --
  BEGIN

  debug_enter(l_proc_name);

  debug('Entering person_decoration ...',10);
  debug ('p_business_group_id:'||p_business_group_id);
  debug ('p_effective_date:'||p_effective_date);
  debug ('p_person_id:'||p_person_id);

  -- BEGIN For Bug 8790100
  -- cursor to fetch person decoration (honors)
  IF g_person_dtl.honors IS NOT NULL
  THEN
     debug('person decoration (honors) : ' || g_person_dtl.honors,30);
     l_ret_person_decoration := g_person_dtl.honors;
  ELSE
     --ERR : no person decoration (honors) found
     debug('person decoration (honors) not found ',30);
     l_ret_person_decoration := ' '; --NULL;
  END IF;

  IF l_ret_person_decoration = ' '
  THEN

     IF g_current_run = 'PERIODIC'
     THEN

        IF g_honors_change_exists = 'Y'
        THEN
           l_ret_person_decoration := '********';
        ELSE

            debug('honors:' || l_ret_person_decoration, 30);
            debug('ben_ext_person.g_chg_pay_table:' || ben_ext_person.g_chg_pay_table, 30);
            debug('ben_ext_person.g_chg_pay_column:' || ben_ext_person.g_chg_pay_column, 30);
            debug('ben_ext_person.g_chg_update_type:' || ben_ext_person.g_chg_update_type, 30);

            --
            IF ben_ext_person.g_chg_pay_table = 'PER_ALL_PEOPLE_F'
            AND
            ben_ext_person.g_chg_pay_column = 'HONORS'
            AND
            ben_ext_person.g_chg_update_type <> 'I'
            THEN -- this is checking location_event for case (3) and (4)
                l_ret_person_decoration := '********';
                g_honors_change_exists := 'Y';
            ELSE
                l_ret_person_decoration := ' ';
            END IF;

        END IF;

     ELSE

        l_ret_person_decoration := '********';
     END IF;
  END IF;

  p_return := l_ret_person_decoration;

  debug('p_return (person_decoration function)' || p_return, 40);
  debug('Exiting person_decoration ...',50);
  debug_exit(l_proc_name);
  return 0;  -- For Bug 8790100

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

  END person_decoration;



-- ----------------------------------------------------------------------------
-- |------------------------< title >-----------------------------------------|
-- ----------------------------------------------------------------------------
  FUNCTION title
    (p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_person_id            IN NUMBER
    ,p_return               IN OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --
      l_proc_name           VARCHAR2(61):=
           g_proc_name||'title';
      l_title               VARCHAR2(30);
      -- For bug 8790100
      l_ret_title      VARCHAR2(30);
  --
  BEGIN

    debug_enter(l_proc_name);

    debug('Entering title  ...',10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_person_id:'||p_person_id);

      l_title := HR_GENERAL.DECODE_LOOKUP
                     (
                      p_lookup_type   =>  'TITLE'
                     ,p_lookup_code   =>  g_person_dtl.title
                     );

      -- BEGIN For bug 8790100
      -- Firstly, check for the value, if Null then check if it is for PERIODIC/CUTOVER.
      -- IF PERIODIC  --> IF change in TITLE event then set the global to 'Y' and return asterisks
      --                  ELSE return space
      -- IF CUTOVER   --> Return asterisks.

      debug('p_return (title function)' || l_title, 40);

      IF l_title IS NULL
      THEN
         l_ret_title := ' ';
      ELSE
        l_ret_title := l_title;
      END IF;

      debug('l_ret_title (title function)' || l_ret_title, 41);
      debug('g_current_run' || g_current_run, 42);
      debug('g_title_change_exists' || g_title_change_exists, 43);

      IF l_ret_title = ' '
      THEN

         IF g_current_run = 'PERIODIC'
         THEN

            IF g_title_change_exists = 'Y'
            THEN
               l_ret_title := '******';
            ELSE

               debug('title:' || l_ret_title, 30);
               debug('ben_ext_person.g_chg_pay_table:' || ben_ext_person.g_chg_pay_table, 44);
               debug('ben_ext_person.g_chg_pay_column:' || ben_ext_person.g_chg_pay_column, 44);
               debug('ben_ext_person.g_chg_update_type:' || ben_ext_person.g_chg_update_type, 44);
               --
               IF ben_ext_person.g_chg_pay_table = 'PER_ALL_PEOPLE_F'
               AND ben_ext_person.g_chg_pay_column = 'TITLE'
               AND ben_ext_person.g_chg_update_type <> 'I'
               THEN
                  l_ret_title := '******';
                  g_title_change_exists := 'Y';
               ELSE
                  l_ret_title := ' ';
               END IF;

            END IF;
         ELSE
            l_ret_title := '******';
         END IF;

      END IF;

    p_return := l_ret_title;

    -- END For bug 8790100

    debug('p_return (title function)' || p_return, 40);
    debug('Exiting title ...',50);
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

  END title;


-- ----------------------------------------------------------------------------
-- |------------------------< bank_account_details >--------------------------|
-- ----------------------------------------------------------------------------
  FUNCTION bank_account_details
    (p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_assignment_id        IN NUMBER
    ,p_rule_parameter       IN VARCHAR2
    ,p_return               IN OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --
      l_proc_name           VARCHAR2(61):=
           g_proc_name||'bank_account_details';
  --
  BEGIN

  debug_enter(l_proc_name);

    debug('Entering bank_account_details ...',10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_assignment_id:'||p_assignment_id);
    debug ('p_rule_parameter:'|| p_rule_parameter);

    -- the first call to this function is for fetching sort code
    -- we will now fetch all details, and cache them for remaining
    -- bank detail function calls as well
    IF g_bank_detail_report_y_n = 'Y' THEN -- details to be reported
      debug('Configuration value based flag - Y',20);
      IF p_rule_parameter = 'BankAccountSortCode' THEN

        debug('Fetching BankAccountSortCode ... ',30);
        OPEN  csr_bank_details
                 (p_business_group_id  => p_business_group_id -- IN
                 ,p_effective_date     => p_effective_date    -- IN
                 ,p_assignment_id      => p_assignment_id     -- IN
                 );
        FETCH csr_bank_details into g_asg_bank_details;
          IF csr_bank_details%FOUND THEN
            g_bank_details_found := 'Y'; -- details found
            p_return := g_asg_bank_details.segment3;
          ELSE
            g_bank_details_found := 'N';
            -- p_return := ' ';
            p_return := NULL;
          END IF;
        CLOSE csr_bank_details;

      ELSIF p_rule_parameter = 'BankAccountNumber'
            and g_bank_details_found = 'Y'
      THEN
        debug('Fetching BankAccountNumber ... ',30);
        p_return := g_asg_bank_details.segment4;
      ELSIF p_rule_parameter = 'BankAccountType'
            and g_bank_details_found = 'Y'
      THEN
        debug('Fetching BankAccountType ... ',30);
        p_return := g_asg_bank_details.segment6;
      ELSIF p_rule_parameter = 'BuildingSocietyRollNumber'
            and g_bank_details_found = 'Y'
      THEN
        debug('Fetching BuildingSocietyRollNumber ... ',30);
        p_return := g_asg_bank_details.segment7;
      ELSE
        -- p_return := ' ';
        p_return := NULL;
      END IF;

    ELSE
      -- p_return := ' ';
      p_return := NULL;
    END IF;

  --Bug 8758650: This logic was added to suppress reporting the asterisks
  --in bank account fields when:
  --1)PenServer configuration for basic data has Report Bank Account
  --  Details option set to No.
  --2)Run is cutover and value is NULL
  --3)Run is periodic, value is NULL and it a new bank account or
  --the bank account has not changed
    IF g_bank_detail_report_y_n = 'N'
    THEN
         p_return := 'X';
    ELSE
         IF p_return IS NULL
         THEN
              IF g_current_run = 'CUTOVER'
              THEN
                   p_return := 'X';
              ELSE --run is PERIODIC
                   IF (ben_ext_person.g_chg_pay_table = 'PAY_PERSONAL_PAYMENT_METHODS_F'
                       AND ben_ext_person.g_chg_update_type = 'I')
                       OR ben_ext_person.g_chg_pay_table <> 'PAY_PERSONAL_PAYMENT_METHODS_F'
                   THEN
                        p_return := 'X';
                   END IF;
              END IF;
         END IF;
    END IF;

    debug('p_return (bank_account_details function)' || p_return, 40);
    debug('BankAccountSortCode g_asg_bank_details.segment3 : ' || g_asg_bank_details.segment3,50);
    debug('BankAccountNumber g_asg_bank_details.segment4 : ' || g_asg_bank_details.segment4,50);
    debug('BankAccountType g_asg_bank_details.segment6 : ' || g_asg_bank_details.segment6,50);
    debug('BuildingSocietyRollNumber g_asg_bank_details.segment7 : ' || g_asg_bank_details.segment7,50);

    debug('Exiting bank_account_details ...',10);

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

  END bank_account_details;



-- ----------------------------------------------------------------------------
-- |------------------------< multiple_appointment_indicator >----------------|
-- ----------------------------------------------------------------------------
  FUNCTION multiple_appointment_indicator
    (p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_person_id            IN NUMBER
    ,p_return               IN OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --

      l_proc_name           VARCHAR2(61):=
           g_proc_name||'multiple_appointment_indicator';
      l_assignment_count            NUMBER := NULL;
      l_assignment_count_old_run    NUMBER := NULL;
  --
  BEGIN

  debug_enter(l_proc_name);

    debug('Entering multiple_appointment_indicator ...',10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_person_id:'||p_person_id);


    /*
    -- find previous run's number of assignments
    debug('Fetching number of assignments for previous run ....',20);
    OPEN  csr_mult_assignment_y_n
             (p_business_group_id  => p_business_group_id -- IN

-- IMP !! NOTE !! DATE !!??
             ,p_effective_date     => p_effective_date    -- IN
             ,p_person_id          => p_person_id     -- IN
             );
    FETCH csr_mult_assignment_y_n into l_assignment_count_old_run;
      IF csr_mult_assignment_y_n%NOTFOUND THEN
        --ERR : could not find assignment/person_id !!
        debug('ERROR!!! : no data returned for this person!!', 30);
        p_return := ' ';
        l_assignment_count_old_run := 0;
      ELSE
        p_return := ' ';
      END IF;
    CLOSE csr_mult_assignment_y_n;

    debug('l_assignment_count_old_run : '|| l_assignment_count_old_run, 40);

    --
    -- find current date's mult assignment indicator
    debug('Fetching number of assignments for current run/person ....',50);
    OPEN  csr_mult_assignment_y_n
             (p_business_group_id  => p_business_group_id -- IN
             ,p_effective_date     => p_effective_date    -- IN
             ,p_person_id          => p_person_id     -- IN
             );
    FETCH csr_mult_assignment_y_n into l_assignment_count;
      IF csr_mult_assignment_y_n%FOUND THEN
        --
        IF l_assignment_count > 1 THEN
          -- check if previous run also had mult_ind = 'Y'
          IF l_assignment_count_old_run > 1 AND g_current_run = 'PERIODIC' THEN
            debug('l_assignment_count_old_run > 1 and l_assignment_count > 1 - PERIODIC',60);
            p_return := ' '; -- no change, leave blank
          ELSE
            debug('l_assignment_count_old_run > 1 and l_assignment_count > 1 - CUTOVER',60);
            p_return := 'Y';
          END IF;
        ELSE
          -- check if previous run also had mult_ind = 'Y'
          IF l_assignment_count_old_run < 2 AND l_assignment_count_old_run > 0
                AND g_current_run = 'PERIODIC' THEN
            debug('l_assignment_count_old_run < 2 and l_assignment_count < 2 - PERIODIC',60);
            p_return := ' '; -- no change, leave blank
          ELSE
            debug('l_assignment_count_old_run < 2 and l_assignment_count < 2 - CUTOVER',60);
            p_return := 'N';
          END IF;
        END IF;
        --
      ELSE
      --ERR : could not find assignment/person_id !!
      debug('could not find assignment/person_id !!',65);
      p_return := ' ';
      END IF;

    CLOSE csr_mult_assignment_y_n;
    */


    --
    -- find current date's mult assignment indicator
    debug('Fetching number of assignments for current run/person ....',50);
    OPEN  csr_mult_assignment_y_n
             (p_business_group_id  => p_business_group_id -- IN
             ,p_effective_date     => p_effective_date    -- IN
             ,p_person_id          => p_person_id     -- IN
             );
    FETCH csr_mult_assignment_y_n into l_assignment_count;
      IF csr_mult_assignment_y_n%FOUND THEN
        --
        IF l_assignment_count > 1 THEN
          -- check if previous run also had mult_ind = 'Y'
            p_return := 'Y';
        ELSE
            p_return := 'N';
        END IF;
        --
      ELSE
        --ERR : could not find assignment/person_id !!
        debug('could not find assignment/person_id !!',65);
        -- p_return := ' ';
        p_return := NULL;
      END IF;

    CLOSE csr_mult_assignment_y_n;

    debug('p_return (multiple_appointment_indicator function)' || p_return, 70);
    debug('Exitng multiple_appointment_indicator ...',80);

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

  END multiple_appointment_indicator;




-- ----------------------------------------------------------------------------
-- |------------------------< spouse_date_of_birth >---------------------------|
-- ----------------------------------------------------------------------------
  FUNCTION spouse_date_of_birth
    (p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_person_id            IN NUMBER
    ,p_return               IN OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --

      l_proc_name           VARCHAR2(61):=
           g_proc_name||'spouse_date_of_birth';
      l_spouse_date_of_birth per_all_people_f.date_of_birth%TYPE;
  --
  BEGIN

  debug_enter(l_proc_name);

    debug('Entering spouse_date_of_birth ...',10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_person_id:'||p_person_id);

    -- cursor to fetch spouse_date_of_birth
    debug('Fetching spouse_date_of_birth ....',20);
    OPEN  csr_spouse_dob
             (p_business_group_id  => p_business_group_id -- IN
             ,p_effective_date     => p_effective_date    -- IN
             ,p_person_id          => p_person_id     -- IN
             );
    FETCH csr_spouse_dob into l_spouse_date_of_birth;
      IF csr_spouse_dob%FOUND THEN
        debug('l_spouse_date_of_birth : ' || l_spouse_date_of_birth,30);

        -- For Bug 8790100
        -- p_return := to_char(l_spouse_date_of_birth,'DD/MM/YYYY');
           p_return := to_char(l_spouse_date_of_birth,'YYYY/MM/DD');
      ELSE
        --ERR : no spouse date
        debug('l_spouse_date_of_birth not found ',30);
        -- p_return := ' ';
        p_return := NULL;
      END IF;
    CLOSE csr_spouse_dob;

    debug('p_return (spouse_date_of_birth function)' || p_return, 40);
    debug('Exiting spouse_date_of_birth ...',50);

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

  END spouse_date_of_birth;


-- ----------------------------------------------------------------------------
-- |------------------------< marital_status >--------------------------------|
-- ----------------------------------------------------------------------------
  FUNCTION marital_status
    (p_business_group_id    IN NUMBER
    ,p_effective_date       IN DATE
    ,p_person_id            IN NUMBER
    ,p_return               IN OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --

    l_proc_name           VARCHAR2(61):=
           g_proc_name||'marital_status';
    l_marital_status      varchar2(2) := NULL;
    l_index               NUMBER;
  --
  BEGIN

  debug_enter(l_proc_name);

    debug('Entering csr_marital_status ...',10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_person_id:'||p_person_id);



    -- check that marital_status is not null
    IF g_person_dtl.marital_status IS NOT NULL
    THEN
      debug('g_person_dtl.marital_status : ' || g_person_dtl.marital_status,50);

      -- search thru the mapping for this marital status
      FOR i IN 1..g_marital_status_mapping.COUNT
      LOOP

        IF i=1 THEN -- finding next index
        l_index:=g_marital_status_mapping.FIRST;
        ELSE
        l_index:=g_marital_status_mapping.NEXT(l_index);
        END IF;

        debug('g_marital_status_mapping('||l_index||').pcv_information1 : '
                      || g_marital_status_mapping(l_index).pcv_information1);
        debug('g_marital_status_mapping('||l_index||').pcv_information2 : '
                      || g_marital_status_mapping(l_index).pcv_information2);

        -- start comparing
        IF g_person_dtl.marital_status =
           g_marital_status_mapping(l_index).pcv_information1 -- match found!!
        THEN
          l_marital_status := g_marital_status_mapping(l_index).pcv_information2;

          debug('l_marital_status : '|| l_marital_status,65);
          debug('g_marital_status_mapping('||l_index||').pcv_information2 : '
                      || g_marital_status_mapping(l_index).pcv_information2,66);
        ELSE
          debug('Not a match !!',70);
        END IF;

        -- is still NULL implies that no match was found
        IF l_marital_status IS NULL
        THEN
          l_marital_status := 'U';
        END IF;

      END LOOP; -- end of FOR loop

    ELSE -- g_person_dtl.marital_status IS NOT NULL
      l_marital_status := 'U';
    END IF;

    p_return := l_marital_status;

    debug('p_return (marital_status function)' || p_return, 40);
    debug('Exiting marital_status ...',50);

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

  END marital_status;

-- ----------------------------------------------------------------------------
-- |------------------------< basic_extract_main >----------------------------|
-- ----------------------------------------------------------------------------

  FUNCTION basic_extract_main
    (p_business_group_id        IN         NUMBER  -- context
    ,p_effective_date           IN         DATE    -- context
    ,p_assignment_id            IN         NUMBER  -- context
    ,p_rule_parameter           IN         VARCHAR2 -- parameter
    ,p_output                   OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --

      l_proc_name           VARCHAR2(61):=
           g_proc_name||'basic_extract_main';
      l_value number;
      l_effective_date DATE;
      -- For Bug 8790100
      l_ret_prevsur  per_all_people_f.previous_last_name%type;
      l_ret_midname  per_all_people_f.middle_names%type;
  --
  BEGIN

  debug_enter(l_proc_name);

  -- switch on the trace

    debug('Entering basic_extract_main ...',0);
    debug('p_business_group_id'||p_business_group_id,1);
    debug('p_effective_date'||p_effective_date,1);
    debug('p_assignment_id'|| p_assignment_id,1);
    debug('p_rule_parameter'||p_rule_parameter,1);


    l_effective_date := p_effective_date;

    -- select the function call based on the parameter being passed to the rule
    IF p_rule_parameter = 'Location' THEN
      debug('About to enter location',20);
      l_value := location
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_assignment_id      => p_assignment_id     -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'AgeVerificationIndicator' THEN
      debug('About to enter age_verification_indicator function',30);
      l_value := age_verification_indicator
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_person_id          => g_person_dtl.person_id     -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'PersonDecoration' THEN
      debug('About to enter Person_decoration',40);
      l_value := person_decoration
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_person_id          => g_person_dtl.person_id     -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'BankAccountSortCode' THEN
      debug('About to enter bank_account_details - BankAccountSortCode',40);

      -- g_asg_bank_details.DELETE;

      l_value := bank_account_details
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_assignment_id      => p_assignment_id     -- IN
                    ,p_rule_parameter     => p_rule_parameter    -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'BankAccountNumber' THEN
      debug('About to enter bank_account_details - BankAccountNumber',40);
      l_value := bank_account_details
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_assignment_id      => p_assignment_id     -- IN
                    ,p_rule_parameter     => p_rule_parameter    -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'BankAccountType' THEN
      debug('About to enter bank_account_details - BankAccountType',40);
      l_value := bank_account_details
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_assignment_id      => p_assignment_id     -- IN
                    ,p_rule_parameter     => p_rule_parameter    -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'BuildingSocietyRollNumber' THEN
      debug('About to enter bank_account_details - BuildingSocietyRollNumber',40);
      l_value := bank_account_details
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_assignment_id      => p_assignment_id     -- IN
                    ,p_rule_parameter     => p_rule_parameter    -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'MultipleAppointmentIndicator' THEN
      debug('About to enter Multiple_Appointment_Indicator ',40);

      l_value := multiple_appointment_indicator
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_person_id          => g_person_dtl.person_id         -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'SpouseDOB' THEN
      debug('About to enter spouse_date_of_birth',40);
      l_value := spouse_date_of_birth
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_person_id          => g_person_dtl.person_id         -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'MarStatus' THEN
      debug('About to enter MarStatus',40);
      l_value := marital_status
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_person_id          => g_person_dtl.person_id         -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'Title' THEN
      debug('About to enter Title',40);
      l_value := title
                    (p_business_group_id  => p_business_group_id -- IN
                    ,p_effective_date     => l_effective_date    -- IN
                    ,p_person_id          => g_person_dtl.person_id         -- IN
                    ,p_return             => p_output            -- OUT
                    );

    ELSIF p_rule_parameter = 'PayPoint' THEN
      p_output := g_paypoint;

    ELSIF p_rule_parameter = 'AltKey' THEN
      p_output := g_altkey;

    ELSIF p_rule_parameter = 'FirstForeName' THEN
      -- check if first name is NULL
      -- anshghos: 115.4
      IF g_person_dtl.first_name IS NULL
      THEN
        -- store error for 'NO First Name'
        l_value := PQP_GB_PSI_FUNCTIONS.raise_extract_error
                     (p_error_number        =>    94474
                     ,p_error_text          =>    'BEN_94474_NO_FIRST_NAME'
                     );
        p_output := '';
      ELSE -- first name is not null
        p_output := g_person_dtl.first_name;
      END IF;

   -- BEGIN For Bug 8790100
   ELSIF p_rule_parameter = 'PreviousSurname' THEN

      IF g_person_dtl.PREVIOUS_LAST_NAME IS NULL
      THEN
        l_ret_prevsur := ' ';
      ELSE
        l_ret_prevsur := g_person_dtl.PREVIOUS_LAST_NAME;
      END IF;

      debug('p_return (previuos surname)' || l_ret_prevsur, 40);

      IF l_ret_prevsur = ' '
      THEN

        IF g_current_run = 'PERIODIC'
        THEN -- this is case (3) + case (4)

          IF g_prevsur_change_exists = 'Y'
          THEN
             l_ret_prevsur := '********************';
          ELSE
            debug('prev surname:' || l_ret_prevsur, 30);
            debug('ben_ext_person.g_chg_pay_table:' || ben_ext_person.g_chg_pay_table, 30);
            debug('ben_ext_person.g_chg_pay_column:' || ben_ext_person.g_chg_pay_column, 30);
            debug('ben_ext_person.g_chg_update_type:' || ben_ext_person.g_chg_update_type, 30);
            --
            IF ben_ext_person.g_chg_pay_table = 'PER_ALL_PEOPLE_F'
            AND ben_ext_person.g_chg_pay_column = 'PREVIOUS_LAST_NAME'
            AND ben_ext_person.g_chg_update_type <> 'I'
            THEN -- this is checking location_event for case (3) and (4)
              l_ret_prevsur := '********************';
              g_prevsur_change_exists := 'Y';
            ELSE
              l_ret_prevsur := ' ';
            END IF;
          END IF;
        ELSE
          l_ret_prevsur := '********************';
        END IF;

      END IF;

      p_output := l_ret_prevsur;

   ELSIF p_rule_parameter = 'SecondForename' THEN

     IF g_person_dtl.MIDDLE_NAMES IS NULL
     THEN
       l_ret_midname := ' ';
     ELSE
       l_ret_midname := g_person_dtl.MIDDLE_NAMES;
     END IF;

     debug('p_return (middle name)' || l_ret_midname, 40);

     IF l_ret_midname = ' '
     THEN
       IF g_current_run = 'PERIODIC'
       THEN
         IF g_midname_change_exists = 'Y'
         THEN
            l_ret_midname := '********************';
         ELSE

           debug('middle name:' || l_ret_midname, 30);
           debug('ben_ext_person.g_chg_pay_table:' || ben_ext_person.g_chg_pay_table, 30);
           debug('ben_ext_person.g_chg_pay_column:' || ben_ext_person.g_chg_pay_column, 30);
           debug('ben_ext_person.g_chg_update_type:' || ben_ext_person.g_chg_update_type, 30);

           --
           IF ben_ext_person.g_chg_pay_table = 'PER_ALL_PEOPLE_F'
           AND ben_ext_person.g_chg_pay_column = 'MIDDLE_NAMES'
           AND ben_ext_person.g_chg_update_type <> 'I'
           THEN -- this is checking location_event for case (3) and (4)
             l_ret_midname := '********************';
             g_midname_change_exists := 'Y';
           ELSE
             l_ret_midname := ' ';
           END IF;
         END IF;
       ELSE
         l_ret_midname := '********************';
       END IF;
     END IF;

     p_output := l_ret_midname;
   -- Enf For bug 8790100

    ELSIF p_rule_parameter = 'CurrentRun' THEN
        debug('g_current_run: '||g_current_run);
--        p_output    :=  g_current_run;

        -- Bugfix : 5378812
        -- The "CurrentRun" data element decides whether asterisk (***) are to be
        -- reported for data elements or not. For cutover, asterisk are not to be reported.
        -- Also, in case of new hires, asterisk for missing data elements should not be reported.
        -- the logic below is to handle new_hires
        -- if new_hire, asterisk behaviour should be like "CUTOVER"
        IF g_current_run = 'PERIODIC'
         and
          ben_ext_person.g_chg_pay_table = 'PER_ALL_ASSIGNMENTS_F'
         and
           ben_ext_person.g_chg_update_type = 'I'
        THEN
          p_output := 'CUTOVER';
        ELSE
          p_output := g_current_run;
        END IF;

    ELSE
      -- p_output := '';
      p_output := NULL;
    END IF;

  debug('p_output: '||p_output);
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

  END basic_extract_main;



-- ----------------------------------------------------------------------------
-- |------------------------< basic_data_post_processing >---------------------|
-- ----------------------------------------------------------------------------

  FUNCTION basic_data_post_processing RETURN VARCHAR2
  IS

    -- Variable Declaration

    -- Rowtype Variable Declaration

    l_proc_name          VARCHAR2(61):=
       g_proc_name||'basic_data_post_processing';

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

  END basic_data_post_processing; -- basic_data_post_proc_rule

END PQP_GB_PSI_BASIC_DATA;

/
