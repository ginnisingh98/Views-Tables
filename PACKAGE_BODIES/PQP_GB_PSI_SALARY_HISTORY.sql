--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_SALARY_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_SALARY_HISTORY" AS
    --  /* $Header: pqpgbpssal.pkb 120.0.12000000.6 2007/06/27 15:52:13 rlingama noship $ */
    --
    --
    --
    --
    --
    -- Exceptions
    hr_application_error exception;
    pragma exception_init (hr_application_error, -20001);

    g_nested_level       NUMBER(5) := pqp_utilities.g_nested_level;
    -- ----------------------------------------------------------------------------
    -- |--------------------------------< debug >---------------------------------|
    -- ----------------------------------------------------------------------------

       PROCEDURE DEBUG (p_trace_message IN VARCHAR2
                        , p_trace_location IN NUMBER DEFAULT NULL)
       IS

    --
       BEGIN
          --
          IF g_debug THEN
              pqp_utilities.DEBUG (
                 p_trace_message               => p_trace_message
                ,p_trace_location              => p_trace_location
              );
          END IF;
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
    -- ----------------------------------------------------------------------------
    -- |--------------------< reset_salary_history_globals >----------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE reset_salary_history_globals
    IS
        l_proc varchar2(72) := g_package||'.set_salary_history_globals';
    BEGIN
        debug_enter(l_proc);

        debug_exit(l_proc);
    END reset_salary_history_globals;
    ---
    -- ----------------------------------------------------------------------------
    -- |------------------------< set_salary_rate_name >--------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE set_salary_rate_name
    IS
          c_seeded_basic_sal_rate_name   CONSTANT VARCHAR2(80) := 'PenServer Pensionable Salary';
          c_seeded_basic_sal_rate_code   CONSTANT VARCHAR2(80) := 'PEN_SALARY';
          l_basic_sal_rate_code          VARCHAR2(80);
          l_config_values   PQP_UTILITIES.t_config_values;
          l_proc varchar2(72) := g_package||'.set_salary_rate_name';
          l_itr NUMBER;
    BEGIN
          debug_enter(l_proc);
          --reset salary rate name
          g_basic_sal_rate_name :=  NULL;

          pqp_gb_psi_functions.get_rate_usr_func_name
                                (
                                p_business_group_id   =>  g_business_group_id
                                ,p_legislation_code   =>  g_legislation_code
                                ,p_interface_name     =>  'SALARY'
                                ,p_rate_name          =>  g_basic_sal_rate_name
                                ,p_rate_code          =>  l_basic_sal_rate_code
                                ,p_usr_rate_function  =>  g_user_rate_function
                                ,p_sal_ele_fte_attr   =>  g_sal_ele_fte_attr
                                );

          IF l_basic_sal_rate_code IS NULL THEN
              -- if there is no configuration provided for the basic salary rate, use the seeded rate type
              g_basic_sal_rate_name :=  c_seeded_basic_sal_rate_name;
              l_basic_sal_rate_code :=  c_seeded_basic_sal_rate_code;
          END IF;

          debug('g_basic_sal_rate_name: '||g_basic_sal_rate_name);
          debug('l_basic_sal_rate_code: '||l_basic_sal_rate_code);
          debug('g_user_rate_function: '||g_user_rate_function);
          debug_exit(l_proc);
    END set_salary_rate_name;
    ---
    -- ----------------------------------------------------------------------------
    -- |-------------------< set_unigrade_config_values >-------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE set_unigrade_config_values
    IS
          l_proc varchar2(72) := g_package||'.set_unigrade_config_values';
          l_config_values       PQP_UTILITIES.t_config_values;
          l_error               NUMBER;
    BEGIN
          debug_enter(l_proc);
          PQP_UTILITIES.get_config_type_values(
                         p_configuration_type   =>    'PQP_GB_PENSERVER_UNIGRD_MAP'
                        ,p_business_group_id    =>    g_business_group_id
                        ,p_legislation_code     =>    g_legislation_code
                        ,p_tab_config_values    =>    l_config_values
                      );
          IF l_config_values.COUNT > 0 THEN
              g_unigrade_source     := l_config_values(l_config_values.FIRST).pcv_information1;
              g_assignment_context  := l_config_values(l_config_values.FIRST).pcv_information2;
              g_assignment_column   := l_config_values(l_config_values.FIRST).pcv_information3;
              g_people_group_column := l_config_values(l_config_values.FIRST).pcv_information4;

              debug('g_unigrade_source: '||g_unigrade_source,20);
              debug('g_assignment_context: '||g_assignment_context,20);
              debug('g_assignment_column: '||g_assignment_column,20);
              debug('g_people_group_column: '||g_people_group_column,20);

              IF g_unigrade_source = 'PEOPLE_GROUP' THEN
                  -- override to uniformed grade flag can be in People Group Flexfield
                  debug('override to uniformed grade flag can be in People Group Flexfield',30);

                  IF g_people_group_column IS NULL THEN
                      debug('Error: People Group Column is null in the Unigrade Config Value');
                      PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                                       (p_extract_type        =>    'SALARY'
                                       ,p_error_number        =>    94444
                                       ,p_error_text          =>    'BEN_94444_NO_PEOPLE_GRP_COLUMN'
                                       ,p_error_warning_flag  =>    'E'
                                       );
                  END IF; --IF g_people_group_column IS NULL


              ELSE --IF l_source = 'PEOPLE_GROUP'
                  -- override to uniformed grade flag can be in Assignment Flexfield
                  debug('override to uniformed grade flag can be in Assignment Flexfield',20);
                  IF g_assignment_context IS NULL THEN

                      debug('Error: Assignment Column is null in the Unigrade Config Value',30);
                      PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                                       (p_extract_type        =>    'SALARY'
                                       ,p_error_number        =>    94446
                                       ,p_error_text          =>    'BEN_94446_NO_ASSG_CONTEXT'
                                       ,p_error_warning_flag  =>    'E'
                                       );
                  END IF; --IF g_assignment_column IS NOT NULL
                  IF g_assignment_column IS NULL THEN

                      debug('Error: Assignment Column is null in the Unigrade Config Value',30);
                      PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                                       (p_extract_type        =>    'SALARY'
                                       ,p_error_number        =>    94445
                                       ,p_error_text          =>    'BEN_94445_NO_ASSIGNMENT_COLUMN'
                                       ,p_error_warning_flag  =>    'E'
                                       );
                  END IF; --IF g_assignment_column IS NOT NULL
              END IF; --IF l_source = 'PEOPLE_GROUP'
          ELSE
            debug('No Configuration for Uniformed Grade Override',20);
            PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                             (p_extract_type        =>    'SALARY'
                             ,p_error_number        =>    94440
                             ,p_error_text          =>    'BEN_94440_NO_UNIGRD_CONFIG'
                             ,p_error_warning_flag  =>    'E'
                             );
          END IF; --IF l_config_information_values.COUNT >0
          debug_exit(l_proc);
    END set_unigrade_config_values;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------< set_salary_history_globals >------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE set_salary_history_globals
              (
              p_business_group_id     IN NUMBER
              ,p_assignment_id        IN NUMBER
              ,p_effective_date       IN DATE
              )
    IS
        l_proc varchar2(72) := g_package||'.set_salary_history_globals';

    BEGIN --set_salary_history_globals
      debug_enter(l_proc);
      -- set global business group id
      g_business_group_id := p_business_group_id;
      debug('g_business_group_id: '||g_business_group_id,10);

      set_salary_rate_name();

      set_unigrade_config_values();

      debug_exit(l_proc);
    EXCEPTION
           WHEN others THEN
               IF SQLCODE <> hr_utility.hr_error_number
               THEN
                   debug_others (l_proc, 10);
                   IF g_debug
                   THEN
                     DEBUG (   'Leaving: '
                            || l_proc, -999);
                    END IF;
                    fnd_message.raise_error;
                ELSE
                    RAISE;
                END IF;
    END set_salary_history_globals;
    ---
    -- ----------------------------------------------------------------------------
    -- |-----------------------< set_assignment_globals >--------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE set_assignment_globals
                (
                p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )
    IS
        l_proc varchar2(72) := g_package||'.set_assignment_globals';
    BEGIN -- set_assignment_globals
        debug_enter(l_proc);
        debug('Inputs are: ',10);
        debug('p_assignment_id: '||p_assignment_id,10);
        debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);

        PQP_GB_PSI_FUNCTIONS.init_st_end_date_glob();
        -- reset assignment level globals
        g_salary_start_date            := NULL;
        g_salary_end_date              := NULL;

        -- set global assignment_id
        g_assignment_id     := p_assignment_id;
        debug('g_assignment_id: '||g_assignment_id,10);

        -- set the global events table
        g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;
        -- set global person id
        g_person_id := PQP_GB_PSI_FUNCTIONS.get_current_extract_person
                              (
                              p_assignment_id => p_assignment_id
                              );
        debug('g_person_id: '||g_person_id,10);

        g_grade_chg_date   :=  hr_api.g_eot;

        debug_exit(l_proc);
    EXCEPTION
           WHEN others THEN
               IF SQLCODE <> hr_utility.hr_error_number
               THEN
                   debug_others (l_proc, 10);
                   IF g_debug
                   THEN
                     DEBUG (   'Leaving: '
                            || l_proc, -999);
                    END IF;
                    fnd_message.raise_error;
                ELSE
                    RAISE;
                END IF;
    END set_assignment_globals;
    ---
    -- ----------------------------------------------------------------------------
    -- |------------------< salary_cutover_ext_criteria >---------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION salary_cutover_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2
    IS
          l_include     varchar2(1) := 'Y';
          l_proc varchar2(72) := g_package||'.salary_cutover_ext_criteria';
          l_debug   VARCHAR2(1);
          l_error NUMBER;
    BEGIN
          debug_enter(l_proc);
          debug('Inputs are: ');
          debug('p_business_group_id: '||p_business_group_id);
          debug('p_assignment_id: '||p_assignment_id);
          debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'));
          -- reset salary globals
          g_current_run := 'CUTOVER';


          IF g_business_group_id IS NULL
             OR p_business_group_id <> nvl(g_business_group_id,0) THEN

              g_business_group_id :=  p_business_group_id;
              -- set the global debug value
              g_debug :=  pqp_gb_psi_functions.check_debug(g_business_group_id);

              debug_enter(l_proc);
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
              g_effective_date  :=  p_effective_date;

              set_salary_history_globals
                      (
                      p_business_group_id     =>    p_business_group_id
                      ,p_assignment_id        =>    p_assignment_id
                      ,p_effective_date       =>    p_effective_date
                      );
              --Raise extract exceptions which are stored while checking for the setup
              debug('Raising the set-up errors, with input parameter as S');
              PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions('S');
          END IF;
          l_include :=  PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
                        (p_business_group_id        =>  p_business_group_id
                        ,p_effective_date           =>  p_effective_date
                        ,p_assignment_id            =>  p_assignment_id
                        ,p_person_dtl               =>  g_curr_person_dtls
                        ,p_assignment_dtl           =>  g_curr_assg_dtls
                        );
          IF l_include <> 'N'
            AND (g_assignment_id IS NULL
             OR p_assignment_id <> nvl(g_assignment_id,0)) THEN

              set_assignment_globals
                    (
                    p_assignment_id         =>    p_assignment_id
                    ,p_effective_date       =>    p_effective_date
                    );
          END IF;

          g_salary_start_date :=  g_effective_date;
          g_salary_end_date   :=  NULL;
          debug('Returning : '||l_include,10);
          debug_exit(l_proc);
          return l_include;
    EXCEPTION
           WHEN others THEN
               IF SQLCODE <> hr_utility.hr_error_number
               THEN
                   debug_others (l_proc, 10);
                   IF g_debug
                   THEN
                     DEBUG (   'Leaving: '
                            || l_proc, -999);
                    END IF;
                    fnd_message.raise_error;
                ELSE
                    RAISE;
                END IF;
    END salary_cutover_ext_criteria;
    -- ----------------------------------------------------------------------------
    -- |---------------------< salary_periodic_ext_criteria >---------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION salary_periodic_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2
    IS
          l_include     varchar2(1) := 'Y';
          l_proc varchar2(72) := g_package||'.salary_periodic_ext_criteria';
          l_error NUMBER;
          l_curr_evt_index    NUMBER;
          ----
          PROCEDURE show_events
          IS
              l_proc varchar2(72) := g_package||'.show_events';
          BEGIN
            IF g_debug THEN
                debug_enter(l_proc);
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
                     debug('creation_date    :'||to_char(g_pay_proc_evt_tab(i).actual_date,'DD/MM/YYYY'),20);
                     debug('old_value         :'||g_pay_proc_evt_tab(i).old_value        ,20);
                     debug('new_value         :'||g_pay_proc_evt_tab(i).new_value        ,20);
                     debug('change_values     :'||g_pay_proc_evt_tab(i).change_values    ,20);
                     debug('proration_type    :'||g_pay_proc_evt_tab(i).proration_type   ,20);
                     debug('change_mode       :'||g_pay_proc_evt_tab(i).change_mode      ,20);
                  END LOOP;
                ELSE
                    debug('No Events',20);
                END IF;
                debug_exit(l_proc);
            END IF;
          END show_events;
          ----
    BEGIN --salary_periodic_ext_criteria
          debug_enter(l_proc);
          debug('Inputs are: ',10);
          debug('p_business_group_id: '||p_business_group_id,10);
          debug('p_assignment_id: '||p_assignment_id,10);
          debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);
          -- reset salary globals
          g_current_run := 'PERIODIC';

          IF nvl(g_effective_date,c_highest_date) <> p_effective_date
	       OR p_assignment_id <> nvl(g_assignment_id,0) THEN           -- for grade fix(6156192)
              -- reset globals for every new date
              g_grade_chg_date   :=  hr_api.g_eot;
              g_todays_grade_code := '###';
          END IF;

          g_effective_date := p_effective_date;


          IF g_business_group_id IS NULL
             OR p_business_group_id <> nvl(g_business_group_id,0) THEN

              g_business_group_id :=  p_business_group_id;
              -- set the global debug value
              g_debug :=  pqp_gb_psi_functions.check_debug(to_char(g_business_group_id));
              debug_enter(l_proc);
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

              set_salary_history_globals
                      (
                      p_business_group_id     =>    p_business_group_id
                      ,p_assignment_id        =>    p_assignment_id
                      ,p_effective_date       =>    p_effective_date
                      );
              --Raise extract exceptions which are stored while checking for the setup
              debug('Raising the set-up errors, with input parameter as S');
              PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions('S');
          END IF; --IF g_business_group_id IS NULL

          l_include :=  PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
                        (p_business_group_id        =>  p_business_group_id
                        ,p_effective_date           =>  p_effective_date
                        ,p_assignment_id            =>  p_assignment_id
                        ,p_person_dtl               =>  g_curr_person_dtls
                        ,p_assignment_dtl           =>  g_curr_assg_dtls
                        );

          IF l_include <> 'N' THEN

              IF g_assignment_id IS NULL
                 OR p_assignment_id <> nvl(g_assignment_id,0) THEN

                  set_assignment_globals
                        (
                        p_assignment_id         =>    p_assignment_id
                        ,p_effective_date       =>    p_effective_date
                        );
                  -- use the following for only debugging purposes
                  show_events();
              END IF;

              l_curr_evt_index    :=    ben_ext_person.g_chg_pay_evt_index;

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

              IF l_include <> 'N' THEN
                  debug('Calling the common include event proc');
                  l_include := pqp_gb_psi_functions.include_event
                               (p_actual_date => g_pay_proc_evt_tab(l_curr_evt_index).actual_date
                               ,p_effective_date => g_pay_proc_evt_tab(l_curr_evt_index).effective_date
                               );

                  debug('include_event returned: '||l_include);

              END IF; --IF l_include <> 'N'

              IF l_include <> 'N' THEN
                  -- set start and end dates.
                  --l_error := set_salary_start_end_date();
                  l_error := PQP_GB_PSI_FUNCTIONS.get_start_end_date
                                          (
                                          p_assignment_id         =>  g_assignment_id
                                          ,p_business_group_id    =>  g_business_group_id
                                          ,p_effective_date       =>  g_effective_date
                                          ,p_start_date           =>  g_salary_start_date
                                          ,p_end_date             =>  g_salary_end_date
                                          );
                  IF g_salary_start_date IS NULL
                    OR g_salary_start_date > NVL(g_salary_end_date,c_highest_date) THEN
                    IF g_current_run = 'PERIODIC' THEN

                      g_salary_start_date :=  NULL;
                      g_salary_end_date :=  NULL;
                      l_include := 'N';

                    ELSIF g_current_run = 'CUTOVER' THEN

                      g_salary_start_date :=  g_effective_date;

                    END IF;--IF g_current_run = 'PERIODIC'

                  END IF;-- IF g_salary_start_date IS NULL

              END IF; --IF l_include <> 'N'
          END IF; --IF l_include <> 'N'
          pqp_gb_psi_functions.process_retro_event(l_include);
          debug('Returning : '||l_include,10);
          debug_exit(l_proc);
          return l_include;
    EXCEPTION
           WHEN others THEN
               IF SQLCODE <> hr_utility.hr_error_number
               THEN
                   debug_others (l_proc, 10);
                   IF g_debug
                   THEN
                     DEBUG (   'Leaving: '
                            || l_proc, -999);
                    END IF;
                    fnd_message.raise_error;
                ELSE
                    RAISE;
                END IF;
    END salary_periodic_ext_criteria;
    ---
    -- ----------------------------------------------------------------------------
    -- |-------------------------< get_salary_start_date >-------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_salary_start_date
                (
                p_effective_date  IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                ) RETURN NUMBER
    IS
        CURSOR csr_hire_date
        IS
            select PPS.DATE_START --DECODE(PER.CURRENT_EMPLOYEE_FLAG,'Y',PPS.DATE_START,NULL)
            from per_all_people_f PER, per_periods_of_service PPS
            where per.person_id = g_person_id
              and pps.person_id = g_person_id
              and g_effective_date
                between per.effective_start_date
                        and NVL(per.effective_end_date,c_highest_date)
              and g_effective_date
                between pps.date_start
                        and NVL(pps.last_standard_process_date,c_highest_date);

        l_proc varchar2(72) := g_package||'.get_salary_start_date';
        l_hire_date      DATE :=  NULL;
        l_error          NUMBER;
    BEGIN
        debug_enter(l_proc);
        IF g_current_run = 'CUTOVER' THEN
            OPEN csr_hire_date;
            FETCH csr_hire_date INTO l_hire_date;
            CLOSE csr_hire_date;

            IF l_hire_date IS NULL THEN
                -- Raise error
                debug('This person does not have joining date. Please check and correct person details.');
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                 (p_error_number        =>    94450
                                 ,p_error_text          =>    'BEN_94450_NO_JOINING_DATE'
                                 ,p_token1              =>    to_char(g_effective_date,'dd-MON-yyyy')
                                 );
               p_output := NULL;
               debug_exit(l_proc);
               return 0;
            END IF; --IF l_hire_date IS NULL
            debug('l_hire_date: '||l_hire_date);
            p_output := to_char(l_hire_date,'dd/mm/yyyy');

        ELSE --IF g_current_run = 'CUTOVER'
            p_output := to_char(g_salary_start_date,'dd/mm/yyyy');
        END IF;


        debug_exit(l_proc);
        return 0;
    EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
    END get_salary_start_date;
    ---
    ----------------------------------------------------------------------------
    -- |---------------------------< get_salary_end_date >---------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_salary_end_date
                (
                p_effective_date  IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.get_salary_end_date';
    BEGIN
        debug_enter(l_proc);
        IF g_current_run = 'CUTOVER' THEN
            p_output := NULL;
            debug_exit(l_proc);
            return 0;
        END IF;
          IF g_salary_end_date IS NOT NULL THEN
              p_output := to_char(g_salary_end_date,'dd/mm/yyyy');
          ELSE
              p_output := NULL;
          END IF;
        debug_exit(l_proc);
        return 0;
    EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
    END get_salary_end_date;
    ---
    -- ----------------------------------------------------------------------------
    -- |-------------------------< get_contract_type >-----------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_contract_type
                (
                p_effective_date  IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.get_contract_type';
        l_contract_type pqp_assignment_attributes_f.contract_type%type;
        l_work_pattern  pqp_assignment_attributes_f.work_pattern%type;
        l_period_divisor    VARCHAR2(10);
        l_error_msg         VARCHAR2(100);
        l_err_no            NUMBER;
        l_error             NUMBER;
    BEGIN
        debug_enter(l_proc);

        l_error := PQP_GB_PSI_FUNCTIONS.get_contract_type
                                (
                                p_assignment_id          => g_assignment_id
                                ,p_business_group_id     => g_business_group_id
                                ,p_effective_date        => p_effective_date
                                ,p_contract_type         => p_output
                                );

        debug('PenServer Contract Type: '||p_output);
        debug_exit(l_proc);
        return l_error;
    EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
    END get_contract_type;
    ---
    ------------------------------------------------------------------------------
    --|-------------------------< get_salary_notional_pay >-----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_salary_notional_pay
                (
                p_effective_date  IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.get_salary_notional_pay';
        l_notional_pay            NUMBER;
        l_error                   NUMBER;
        l_fte_value               NUMBER;
    BEGIN
        debug_enter(l_proc);

        ----------------------------------------------
        l_error :=  PQP_GB_PSI_FUNCTIONS.get_notional_pay
                                (
                                p_assignment_id       =>  g_assignment_id
                                ,p_business_group_id  =>  g_business_group_id
                                ,p_effective_date     =>  g_salary_start_date
                                ,p_name               =>  g_basic_sal_rate_name
                                ,p_rt_element         =>  'R'
                                ,p_rate               =>  p_output
                                ,p_custom_function    =>  g_user_rate_function
                                );

        l_notional_pay  :=  fnd_number.canonical_to_number(p_output);

        IF nvl(g_sal_ele_fte_attr,'NONE') = 'ALL' THEN
            l_fte_value :=  PQP_GB_PSI_FUNCTIONS.get_fte_value
                                              (
                                              p_assignment_id   =>  g_assignment_id
                                              ,p_effective_date =>  g_effective_date
                                              );
           debug('l_fte_value: '||l_fte_value);
           IF l_fte_value > 0 THEN
              -- fte value is returned as -1 when the value is not there.
              l_notional_pay :=  l_notional_pay/nvl(l_fte_value,1);
           END IF;
        END IF;

        -- the following if clause is added in 115.23
        IF NOT ( l_notional_pay >= -99999999.99 AND l_notional_pay <= 999999999.99 ) THEN
            -- raise error that the bonus amount is out of range
            -- bug fix 4998232
            debug('ERROR: Bonus Amount out of range: '||l_notional_pay,20);
            l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                             (p_error_number        =>    94569
                             ,p_error_text          =>    'BEN_94569_INV_SALARY_AMOUNT'
                             ,p_token1              =>    to_char(g_effective_date,'dd/mm/yyyy')
                             ,p_token2              =>    p_output
                             );
        ELSE
            IF l_notional_pay < 0 THEN
                p_output  :=  ltrim(rtrim(to_char(l_notional_pay,'099999999D99')));
            ELSE
                p_output  :=  ltrim(rtrim(to_char(l_notional_pay,'099999999D99')));
            END IF;
        END IF;

        g_notional_pay  :=  p_output;
        debug('Notional Pay: '||p_output,10);
        debug_exit(l_proc);
        return 0;
        ----------------------------------------------
    EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
    END get_salary_notional_pay;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------------< get_uniformed_grade >-------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_uniformed_grade
                (
                p_effective_date  IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.get_uniformed_grade';
        l_grade_id            VARCHAR2(30);
        l_people_group_id     NUMBER;
        l_grade_code          VARCHAR2(30);
        l_uniform_grade_flag  VARCHAR2(30);
        l_flag                VARCHAR2(1) := 'N';
        TYPE base_table_ref_csr_typ IS REF CURSOR;
        c_base_table        base_table_ref_csr_typ;
        l_query         VARCHAR2(1000);
        l_error          NUMBER;
    BEGIN
        debug_enter(l_proc);

        -- get the configuration values of people group flexfield
        IF g_unigrade_source = 'PEOPLE_GROUP' AND g_people_group_column IS NOT NULL THEN
            -- override to uniformed grade flag can be in People Group Flexfield
            debug('override to uniformed grade flag can be in People Group Flexfield',30);
            l_people_group_id := g_curr_assg_dtls.people_group_id;

            IF l_people_group_id IS NULL THEN
                -- Raise warning
                debug('People Group flexfield details not attached',40);
            ELSE
                pqp_utilities.get_kflex_value
                      (p_entity_name                =>  'PAY_PEOPLE_GROUPS'
                      ,p_key_column_name            =>  'PEOPLE_GROUP_ID'
                      ,p_key_column_value           =>  l_people_group_id
                      ,p_segment_column_name        =>  g_people_group_column
                      ,p_segment_column_value       =>  l_uniform_grade_flag
                      );
                IF l_uniform_grade_flag IS NOT NULL THEN
                  l_flag    :=  'Y';
                ELSE
                  debug('Value not entered for Uniformed Grade Flag',40);
                END IF; --IF l_uniform_grade_flag IS NOT NULL

            END IF;--IF l_people_group_id IS NULL


        ELSIF g_unigrade_source = 'ASSIGNMENT'
        AND g_assignment_column IS NOT NULL
        AND g_assignment_context  IS NOT NULL THEN
            -- override to uniformed grade flag can be in Assignment Flexfield
            debug('override to uniformed grade flag can be in Assignment Flexfield',20);

            /*l_query := 'select '||g_assignment_column||' '||'
                         from per_all_assignments_f '||
                         'where business_group_id = '||g_business_group_id||' '||
                         'and assignment_id = '||g_assignment_id||' '||
                         'and ASS_ATTRIBUTE_CATEGORY = '||''''||g_assignment_context||''''||
                         'and to_date('||''''||TO_CHAR(p_effective_date,'dd/mm/yyyy')||''''||
                         ',''dd/mm/yyyy'')'||' between effective_start_date
                                                    and effective_end_date';*/

            l_query :=   'select '||g_assignment_column||' '||
                         'from per_all_assignments_f '||' '||
                         'where business_group_id = '||g_business_group_id||' '||
                         'and assignment_id = '||g_assignment_id||' ';
            IF g_assignment_context <> 'Global Data Elements' THEN
                  l_query := l_query||
                              'and ASS_ATTRIBUTE_CATEGORY = '''||g_assignment_context||''' ';
                              -- fixed this in v115.26
            END IF;
            l_query := l_query||
                      'and to_date('||''''||TO_CHAR(p_effective_date,'dd/mm/yyyy')||''''||
                      ',''dd/mm/yyyy'')'||' between effective_start_date '||
                                         'and effective_end_date';
            --debug('l_query: '||l_query,30);

            OPEN c_base_table FOR l_query;
            FETCH c_base_table INTO l_uniform_grade_flag;
            CLOSE c_base_table;
            IF l_uniform_grade_flag IS NOT NULL THEN
                  l_flag    :=  'Y';
            END IF;

        END IF; -- IF g_unigrade_source = 'PEOPLE_GROUP'

        IF l_flag = 'Y' THEN
            IF l_uniform_grade_flag NOT IN ('Y','N','y','n') THEN
                -- DATA ERROR
                debug('ERROR: The Overridden Uniformed Grade Flag is neither Y nor N',20);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                       (p_error_number        =>    94443
                                       ,p_error_text          =>    'BEN_94443_INVALID_UNIGRD_FLAG'
                                       ,p_token1              =>    to_char(g_effective_date,'dd-MON-yyyy')
                                       ,p_token2              =>    p_output
                                       );
               debug_exit(l_proc);
               return 0;
            ELSE
                p_output  :=  UPPER(l_uniform_grade_flag);
            END IF;
        END IF;--IF l_flag = 'Y' AND p_output <> 'N' AND p_output <> 'Y'

        debug_exit(l_proc);
        return 0;
    EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
    END get_uniformed_grade;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------------< get_grade_code >-------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_grade_code
                (p_grade_id   NUMBER
                ) RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.get_grade_code';
        l_grade_code          VARCHAR2(30);
        l_uniform_grade_flag  VARCHAR2(30);
    BEGIN
        debug_enter(l_proc);
        debug('p_grade_id: '||p_grade_id);

        IF p_grade_id IS NULL THEN
          debug('Returning : NULL');
          debug_exit(l_proc);
          return NULL;
        END IF;

        IF g_grade_codes.exists(p_grade_id) THEN
            debug('available in the cache',20);
            l_grade_code  :=  g_grade_codes(p_grade_id);
        ELSE
            debug('not available in the cache',20);
            OPEN csr_get_grade_extra_info
                    (
                    p_grade_id  =>  p_grade_id
                    );
            FETCH csr_get_grade_extra_info INTO l_grade_code,l_uniform_grade_flag;
            CLOSE csr_get_grade_extra_info;

            debug('l_grade_code: '||l_grade_code);
            debug('l_uniform_grade_flag: '||l_uniform_grade_flag);

            g_grade_codes(p_grade_id) :=  l_grade_code;
        END IF;

        debug('Returning : '||l_grade_code);
        debug_exit(l_proc);
        return l_grade_code;
    EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
    END get_grade_code;
    -- ----------------------------------------------------------------------------
    -- |--------------------------< is_today_grade_change >-----------------------------|
    --  Description: This Procedure is to check if there is a change on grade on current
    --                processign date.
    -- ----------------------------------------------------------------------------
    FUNCTION is_today_grade_change
                (p_old_value   OUT NOCOPY VARCHAR2
                ,p_new_value   OUT NOCOPY VARCHAR2
                ) RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.is_today_grade_change';
        l_grade_event_exists VARCHAR2(1) := 'N';
        l_index           NUMBER;
        l_chg_table_id        NUMBER;
        l_chg_column_name VARCHAR2(30);
        l_chg_table       VARCHAR2(30);
        l_chg_type        VARCHAR2(10);
        l_chg_date        DATE;
        l_chg_surrogate_key NUMBER;
        l_is_fte_abv      VARCHAR2(1);
        l_old_value       VARCHAR2(20);
        l_new_value       VARCHAR2(20);
        l_change_value    varchar2(80);
        l_arrow_pos       NUMBER;
    BEGIN
        debug_enter(l_proc);
        debug('g_effective_date: '||g_effective_date);
        debug('g_grade_chg_date: '||g_grade_chg_date);

        IF g_grade_chg_date = g_effective_date THEN
            -- if current event date is already processed
            debug('Returning: Y');
            debug_exit(l_proc);
            return 'Y';
        ELSIF g_grade_chg_date <> c_highest_date THEN
            debug('Returning: N');
            debug_exit(l_proc);
            return 'N';
        END IF;

        l_index := ben_ext_person.g_chg_pay_evt_index;
        LOOP
            l_chg_type            :=  g_pay_proc_evt_tab(l_index).update_type;
            l_chg_table_id        :=  g_pay_proc_evt_tab(l_index).dated_table_id;
            l_chg_table           :=  PQP_GB_PSI_FUNCTIONS.get_dated_table_name(l_chg_table_id);
            l_chg_date            :=  g_pay_proc_evt_tab(l_index).effective_date;
            l_chg_column_name     :=  g_pay_proc_evt_tab(l_index).column_name;

            debug('l_chg_date: '||l_chg_date);
            debug('l_chg_table: '||l_chg_table);
            debug('l_chg_column_name: '||l_chg_column_name);
            debug('l_chg_type: '||l_chg_type);

            IF g_effective_date < g_pay_proc_evt_tab(l_index).effective_date THEN
              debug('finished processing all the events on g_effective_date');
              EXIT;
            END IF; --IF g_effective_date
            debug('l_chg_table: '||l_chg_table||'  l_chg_type: '||l_chg_type);

            -- check for salary element end
            IF l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
                AND l_chg_column_name  = 'GRADE_ID' THEN
                debug('Grade event ');
                IF l_chg_type = 'U' THEN
                   debug('For update type pick the value from new_value',40);
                   l_old_value             :=  g_pay_proc_evt_tab(l_index).old_value;
                   l_new_value             :=  g_pay_proc_evt_tab(l_index).new_value;
                 ELSIF l_chg_type = 'C' THEN
                   debug('For correction type pic the value by parsing change_values',40);
                   l_change_value :=  g_pay_proc_evt_tab(l_index).change_values;
                   l_arrow_pos    :=  instr(l_change_value,'->');
                   debug('l_change_value: '||l_change_value,40);
                   l_old_value              :=  ltrim(rtrim(SUBSTR(l_change_value,1,l_arrow_pos-1)));
                   l_new_value              :=  ltrim(rtrim(SUBSTR(l_change_value,l_arrow_pos+2)));
                END IF;

                debug('l_old_value: '||l_old_value);
                debug('l_new_value: '||l_new_value);

                -- latest versions of pay_interpreter_pkg return the string <null>
                -- when the old_value/new_value is null
                -- the non-numeric exception is caught here.
                IF l_old_value IS NOT NULL THEN
                   BEGIN
                      p_old_value  :=  get_grade_code(fnd_number.canonical_to_number(l_old_value));
                   EXCEPTION
                      WHEN others THEN
                          debug('l_old_value is not numeric');
                   END;

                END IF;

                IF l_new_value IS NOT NULL THEN
                   BEGIN
                      p_new_value  :=  get_grade_code(fnd_number.canonical_to_number(l_new_value));
                   EXCEPTION
                      WHEN others THEN
                          debug('l_old_value is not numeric');
                   END;

                END IF;

                g_grade_chg_date := g_effective_date;
                l_grade_event_exists := 'Y';
                EXIT;
            END IF;

            -- looping condition
            IF l_index = g_pay_proc_evt_tab.LAST THEN
                EXIT;
            ELSE
                l_index := g_pay_proc_evt_tab.NEXT(l_index);
            END IF;
        END LOOP; -- LOOP

        debug('p_old_value: '||p_old_value);
        debug('p_new_value: '||p_new_value);
        debug('Returning: '||l_grade_event_exists);
        debug_exit(l_proc);
        return l_grade_event_exists;
    END is_today_grade_change;
    -- ----------------------------------------------------------------------------
    -- |---------------------------< get_grade_code >-----------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_grade_code
                (
                p_effective_date  IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.get_grade_code';
        l_grade_id    per_all_assignments_f.grade_id%type;
        l_grade_change        VARCHAR2(1);
        l_grade_code          VARCHAR2(10);
        l_error               NUMBER;
        l_old_value           VARCHAR2(20);
        l_new_value           VARCHAR2(20);
    BEGIN
        debug_enter(l_proc);
        -- get the grade code of the person from the for the effective date passed

        l_grade_id  :=  g_curr_assg_dtls.grade_id;

        IF g_current_run  =   'PERIODIC' THEN
            debug('for Periodic runs');
            debug('g_todays_grade_code: '||g_todays_grade_code);
            IF g_todays_grade_code = '###' THEN
                debug('grade code NOT set');
                /* for first even on a the current event date,
                    calculate the grade code and set the value */
                l_grade_change  :=  is_today_grade_change
                                        (p_old_value   =>   l_old_value
                                        ,p_new_value   =>   l_new_value
                                        );
                IF l_grade_change = 'Y' THEN
                    -- there is a grade change on current date
                    IF l_old_value  IS NULL
                        AND l_new_value IS NULL THEN
                        -- condition when there was no grade code and
                        -- there is no grade code now also
                        -- report a space, to prevent reporting *s
                        l_grade_code  :=  ' ';
                    ELSE
                        -- on all cases report the new value
                        -- when the value is null, the value will be padded by *s
                        -- when the value is not null, actual value is reported
                        l_grade_code  :=  l_new_value;
                    END IF;
                ELSE -- IF l_grade_change = 'Y'
                    -- there is no grade change on current date

                    IF l_grade_id IS NULL THEN -- bugfix 5902824
                        l_grade_code  :=   ' ';
                    ELSE
                        l_grade_code  :=  get_grade_code(l_grade_id);
                        IF l_grade_code IS NULL THEN
                            -- when there is no change on grade code and the value is null
                            -- report a space, to prevent reporting *s
                            l_grade_code  :=   ' ';
                        END IF;
                    END IF;

                END IF;

                g_todays_grade_code := l_grade_code;

              ELSE

                debug('grade code already set');
                /* if the grade code is already set for the current event date
                     use the global grade code */
                l_grade_code := g_todays_grade_code;
            END IF;
        ELSE -- IF g_current_run  =   'PERIODIC'
            debug('for cutover runs');
            l_grade_code  :=  get_grade_code(l_grade_id);
            IF l_grade_code IS NULL THEN
                -- when there is no grade code, on cutover run,
                -- report a space, to prevent reporting *s
                l_grade_code  :=   ' ';
            END IF;
        END IF;

            /*OPEN csr_get_grade_extra_info
                    (
                    p_grade_id  =>  l_grade_id
                    );
            FETCH csr_get_grade_extra_info INTO l_grade_code,l_uniform_grade_flag;
            CLOSE csr_get_grade_extra_info;*/

            IF l_grade_id IS NOT NULL THEN
              IF ltrim(l_grade_code) IS NULL THEN
                -- Raise warning when a grade is attahced which has no grade code
                debug('Warning: Grade attached to the person has no extra information: '||l_grade_id,30);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                               (p_error_number        =>    94448
                               ,p_error_text          =>    'BEN_94448_NO_GRADE_EIT'
                               ,p_token1              =>    to_char(g_effective_date,'dd-MON-yyyy')
                               );
              ELSIF NOT pqp_gb_psi_functions.is_alphanumeric(l_grade_code) THEN
                -- Raise error when the grade code is not alphanumeric
                debug('ERROR: Grade code is invalid: '||p_output,30);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94447
                               ,p_error_text          =>    'BEN_94447_INV_GRD_CODE'
                               ,p_token1              =>    to_char(g_effective_date,'dd-MON-yyyy')
                               ,p_token2              =>    l_grade_code
                               );
              END IF;
            END IF;

        p_output := l_grade_code;

        debug('p_output: '||p_output,10);
        debug_exit(l_proc);
        return 0;
    EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
    END get_grade_code;
    ---
    -- ----------------------------------------------------------------------------
    -- |------------------------< get_salary_actual_pay >--------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_salary_actual_pay
                (
                p_effective_date  IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                )RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.get_salary_actual_pay';
        l_actual_pay  NUMBER;
        l_error       NUMBER;
        --
    BEGIN
      debug_enter(l_proc);
      l_error :=  PQP_GB_PSI_FUNCTIONS.get_actual_pay
                          (
                          p_assignment_id   =>  g_assignment_id
                          ,p_notional_pay   =>  g_notional_pay
                          ,p_effective_date =>  g_salary_start_date
                          ,p_output         =>  p_output
                          );

      l_actual_pay  :=  fnd_number.canonical_to_number(p_output);

      -- the following if clause is added in 115.23
      IF l_actual_pay < 0 THEN
          p_output  :=  ltrim(rtrim(to_char(l_actual_pay,'099999999D99')));
      ELSE
          p_output  :=  ltrim(rtrim(to_char(l_actual_pay,'099999999D99')));
      END IF;

      debug('Actual Pay: '||p_output,10);
      debug_exit(l_proc);
      return l_error;
    EXCEPTION
       WHEN others THEN
           IF SQLCODE <> hr_utility.hr_error_number
           THEN
               debug_others (l_proc, 10);
               IF g_debug
               THEN
                 DEBUG (   'Leaving: '
                        || l_proc, -999);
                END IF;
                fnd_message.raise_error;
            ELSE
                RAISE;
            END IF;
    END get_salary_actual_pay;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------< salary_data_element_value >-------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION salary_data_element_value
             (
             p_ext_user_value     IN VARCHAR2
             ,p_output_value       OUT NOCOPY VARCHAR2
             ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.salary_data_element_value';
        l_error   NUMBER;

    BEGIN --salary_data_element_value

      debug_enter(l_proc);
      debug('p_ext_user_value: '||p_ext_user_value,10);

      IF p_ext_user_value = 'SalaryStartDate' THEN
          l_error :=  get_salary_start_date
                        (
                        p_effective_date  =>  g_effective_date
                        ,p_output         =>  p_output_value
                        );
      ELSIF p_ext_user_value = 'SalaryEndDate' THEN
          l_error :=  get_salary_end_date
                        (
                        p_effective_date  =>  g_effective_date
                        ,p_output         =>  p_output_value
                        );
      ELSIF p_ext_user_value = 'SalaryNotionalPay' THEN
          l_error :=  get_salary_notional_pay
                        (
                        p_effective_date  =>  g_effective_date
                        ,p_output         =>  p_output_value
                        );
      ELSIF p_ext_user_value = 'ContractType' THEN
          l_error :=  get_contract_type
                        (
                        p_effective_date  =>  g_effective_date
                        ,p_output         =>  p_output_value
                        );
      ELSIF p_ext_user_value = 'UniformedGrade' THEN
          l_error :=  get_uniformed_grade
                        (
                        p_effective_date  =>  g_effective_date
                        ,p_output         =>  p_output_value
                        );
      ELSIF p_ext_user_value = 'GradeCode' THEN
          l_error :=  get_grade_code
                        (
                        p_effective_date  =>  g_effective_date
                        ,p_output         =>  p_output_value
                        );
      ELSIF p_ext_user_value = 'SalaryActualPay' THEN
          l_error :=  get_salary_actual_pay
                        (
                        p_effective_date  =>  g_effective_date
                        ,p_output         =>  p_output_value
                        );
      END IF;
      debug('p_output_value: '||p_output_value,10);
      debug_exit(l_proc);
      return l_error;
    EXCEPTION
           WHEN others THEN
               IF SQLCODE <> hr_utility.hr_error_number
               THEN
                   debug_others (l_proc, 10);
                   IF g_debug
                   THEN
                     DEBUG (   'Leaving: '
                            || l_proc, -999);
                    END IF;
                    fnd_message.raise_error;
                ELSE
                    RAISE;
                END IF;
    END salary_data_element_value;
    ------
    -- ----------------------------------------------------------------------------
    -- |----------------------< salary_post_processing >--------------------------|
    --  Description:  This is the post-processing rule  for the Salary History.
    -- ----------------------------------------------------------------------------
    FUNCTION salary_post_processing RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.salary_post_processing';
    BEGIN
        debug_enter(l_proc);

        --Raise extract exceptions which are stored while processing the data elements
        --PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions();

        --call the common post processing function
        PQP_GB_PSI_FUNCTIONS.common_post_process(g_business_group_id);

        debug_exit(l_proc);
        return 'Y';
    EXCEPTION
           WHEN others THEN
               IF SQLCODE <> hr_utility.hr_error_number
               THEN
                   debug_others (l_proc, 10);
                   IF g_debug
                   THEN
                     DEBUG (   'Leaving: '
                            || l_proc, -999);
                    END IF;
                    fnd_message.raise_error;
                ELSE
                    RAISE;
                END IF;
    END salary_post_processing;
    ------
END PQP_GB_PSI_SALARY_HISTORY;

/
