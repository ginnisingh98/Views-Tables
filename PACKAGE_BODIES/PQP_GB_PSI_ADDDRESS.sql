--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_ADDDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_ADDDRESS" AS
    --  /* $Header: pqpgbpsadd.pkb 120.2.12010000.2 2008/08/05 14:04:17 ubhat ship $ */
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

       PROCEDURE DEBUG (p_trace_message IN VARCHAR2, p_trace_location IN NUMBER)
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
    -- |----------------------< set_address_extract_globals >---------------------|
    --  Description: This procedure is to obtain set the extract level globals.
    -- ----------------------------------------------------------------------------
    PROCEDURE set_address_extract_globals
                (
                p_business_group_id     IN NUMBER
                ,p_assignment_id        IN NUMBER
                )
    IS
        l_include     varchar2(1) := 'Y';
        l_proc varchar2(72) := g_package||'.set_address_extract_globals';
        l_config_values   PQP_UTILITIES.t_config_values;
    BEGIN
        debug_enter(l_proc);

        -- set global business group id
        g_business_group_id :=  p_business_group_id;
        g_legislation_code  :=  'GB';
        g_person_id              :=   NULL;
        g_assignment_id          :=   NULL;
        g_office_address_type    :=   NULL;
        g_home_address_type      :=   NULL;
        g_office_address_id      :=   NULL;
        g_home_address_id        :=   NULL;
        g_country                :=   NULL;
        g_person_addresses.DELETE;
        g_person_cutover_addresses.DELETE;
        g_office_address_changed := 'N';
        g_home_address_changed   := 'N';

        debug('g_business_group_id: '||g_business_group_id,10);

        -- set the address types
        -- fetch the configuration values for PQP_GB_PENSERVER_ADDRESS_MAP
        -- if there is no configuration value an error will be raised at
        -- extract level
        PQP_UTILITIES.get_config_type_values(
                     p_configuration_type   =>    c_configuration_type
                    ,p_business_group_id    =>    g_business_group_id
                    ,p_legislation_code     =>    g_legislation_code
                    ,p_tab_config_values    =>    l_config_values
                  );
        IF l_config_values.COUNT > 0 THEN
            g_office_address_type   :=    l_config_values(l_config_values.FIRST).pcv_information1;
            g_home_address_type     :=    l_config_values(l_config_values.FIRST).pcv_information2;
            debug('g_office_address_type: '||g_office_address_type,20);
            debug('g_home_address_type: '||g_home_address_type,20);
        ELSE
            -- No configuration for address types.
            debug('ERROR: No configuration for address types.',20);
            PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                   (p_extract_type        =>    'ADDRESS'
                   ,p_error_number        =>    94436
                   ,p_error_text          =>    'BEN_94436_NO_ADD_TYPES_CONFIG'
                   ,p_error_warning_flag  =>    'E'
                   );
        END IF; --IF l_config_values.COUNT > 0

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
    END set_address_extract_globals;
    ---
    -- ----------------------------------------------------------------------------
    -- |----------------------< set_assignment_globals >--------------------------|
    --  Description:  This procedure is to set the assignment level globals.
    -- ----------------------------------------------------------------------------
    PROCEDURE set_assignment_globals
                (
                p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )
    IS
        l_include             varchar2(1) := 'Y';
        l_proc varchar2(72) := g_package||'.set_assignment_globals';
        l_address_details     csr_get_addr_dtls%ROWTYPE;
        l_address_exists      boolean := false;
        l_add_not_effective   boolean := false;
        l_no_add_type         boolean := false;
        l_add_type_not_mapped boolean := false;
        l_error               NUMBER;
        l_errors_table        pqp_gb_psi_functions.t_error_collection;
        l_error_index         NUMBER  := 1;
    BEGIN
        debug_enter(l_proc);
        debug('Inputs are: ',10);
        debug('p_assignment_id: '||p_assignment_id,10);
        debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);

        --reset assignment level globals
        g_person_id              :=   NULL;
        g_assignment_id          :=   NULL;
        g_office_address_id      :=   NULL;
        g_home_address_id        :=   NULL;
        g_country                :=   NULL;

        g_person_addresses.DELETE;
        g_person_cutover_addresses.DELETE;

        g_office_address_changed      := 'N';
        g_home_address_changed        := 'N';

        g_include_home_address        := 'Y';
        g_include_office_address      := 'Y';
        g_office_address_reported     :=  false;

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

        -- get all the address details  for the person
        FOR l_address_details IN csr_get_addr_dtls
        LOOP
            debug('g_current_run: '||g_current_run,20);
            l_address_exists  := true;
            -- if current run is cutover
            IF g_current_run  =  'CUTOVER' THEN
                -- insert into cutover addresses table - g_person_cutover_addresses
                debug('For Cutover extract',30);
                -- if the current address is effective on the cutover date
                IF p_effective_date BETWEEN l_address_details.date_from
                                  AND NVL(l_address_details.date_to,c_highest_date) THEN
                    -- if the address is effective on the cutover date
                    IF NVL(l_address_details.address_type,' ')  =   g_office_address_type  THEN
                        g_office_address_changed    :=    'Y';
                        g_office_address_id   :=    l_address_details.address_id;
                        g_person_cutover_addresses(g_office_address_id)  :=  l_address_details;
                        debug('Office address is there for cutover run',40);
                        debug('g_office_address_id: '||g_office_address_id);
                    ELSIF NVL(l_address_details.address_type,' ')  =   g_home_address_type THEN
                        g_home_address_changed    :=    'Y';
                        g_home_address_id   :=   l_address_details.address_id;
                        g_person_cutover_addresses(g_home_address_id)  :=  l_address_details;
                        debug('Home address is there for cutover run',40);
                        debug('g_home_address_id: '||g_home_address_id);
                    ELSE -- if the address is neither home nor office address type
                        -- if address type is null
                        IF l_address_details.address_type IS NULL THEN
                            debug('Address type is null');
                            l_no_add_type := true;
                            -- Raise Error: there are no addresses for the person
                            l_errors_table(l_error_index).error_number    :=    94481;
                            l_errors_table(l_error_index).error_text      :=    'BEN_94481_NO_ADD_TYPE';
                            l_errors_table(l_error_index).token1          :=    l_address_details.address_id;
                            l_error_index :=  l_error_index + 1;
                        ELSE
                            debug('Address type of the Current address is not mapped');
                            l_add_type_not_mapped := true;
                            -- Raise Error: there are no addresses for the person
                            l_errors_table(l_error_index).error_number    :=    94469;
                            l_errors_table(l_error_index).error_text      :=    'BEN_94469_ADD_TYPE_NOT_MAPPED';
                            l_errors_table(l_error_index).token1          :=    l_address_details.address_meaning;
                            l_error_index :=  l_error_index + 1;
                        END IF;
                    END IF; --IF l_address_details.address_type  =   g_office_address_type
                ELSE -- address is not effective on cutover date
                    debug('Current address is not effective on the cutover date.');
                    l_add_not_effective := true;
                    -- Raise Error: there are no addresses for the person
                    l_errors_table(l_error_index).error_number    :=    94473;
                    l_errors_table(l_error_index).error_text      :=    'BEN_94473_ADD_NOT_EFFECTIVE';
                    l_errors_table(l_error_index).token1          :=    l_address_details.address_meaning;
                    l_errors_table(l_error_index).token2          :=    to_char(l_address_details.date_from,'dd/mm/yyyy');
                    l_errors_table(l_error_index).token3          :=    to_char(l_address_details.date_to,'dd/mm/yyyy');
                    l_error_index :=  l_error_index + 1;
                END IF; --IF p_effective_date BETWEEN l_address_details.date_from

            ELSE -- if current run is periodic
                debug('For Periodic Changes extract',30);
                g_person_addresses(l_address_details.address_id)  :=  l_address_details;

            END IF; --IF g_current_run  =   'CUTOVER'

        END LOOP;
        IF NOT l_address_exists THEN
            -- Raise Error: there are no addresses for the person
            debug('ERROR: There are no addresses for the person');
            l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                   (p_error_number        =>    94437
                   ,p_error_text          =>    'BEN_94437_NO_ADDRESSES'
                   );
        ELSIF (g_current_run  =  'CUTOVER' AND g_person_cutover_addresses.COUNT = 0) THEN

                debug('raise the stored errors if there are no PenServer addresses');
                FOR i IN l_errors_table.FIRST..l_errors_table.LAST LOOP
                   l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                     (p_error_number        =>    l_errors_table(i).error_number
                                     ,p_error_text          =>    l_errors_table(i).error_text
                                     ,p_token1              =>    l_errors_table(i).token1
                                     ,p_token2              =>    l_errors_table(i).token2
                                     ,p_token3              =>    l_errors_table(i).token3
                                     ,p_token4              =>    l_errors_table(i).token4
                                     );
                END LOOP;
                debug('ERROR: There are no addresses for the person');
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94437
                       ,p_error_text          =>    'BEN_94437_NO_ADDRESSES'
                       );

        END IF;
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
    -- |---------------------< address_cutover_ext_criteria >---------------------|
    --  Description: Cutover extract criteria.
    -- ----------------------------------------------------------------------------
    FUNCTION address_cutover_ext_criteria
                (
                p_business_group_id      NUMBER
                ,p_assignment_id         NUMBER
                ,p_effective_date        DATE
                )RETURN VARCHAR2
    IS
        l_include     varchar2(1) := 'Y';
        l_proc varchar2(72) := g_package||'.address_cutover_ext_criteria';
    BEGIN
        debug_enter(l_proc);
        debug('Inputs are: ',10);
        debug('p_business_group_id: '||p_business_group_id,10);
        debug('p_assignment_id: '||p_assignment_id);
        debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);

        -- reset salary globals
        g_current_run := 'CUTOVER';

        IF g_business_group_id IS NULL
           OR p_business_group_id <> nvl(g_business_group_id,0) THEN

           g_business_group_id :=  p_business_group_id;
           -- set the global debug value
           g_debug :=  pqp_gb_psi_functions.check_debug(g_business_group_id);
           debug_enter(l_proc);
           debug('Inputs are: ',20);
           debug('p_business_group_id: '||p_business_group_id,20);
           debug('p_assignment_id: '||p_assignment_id,20);
           debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),20);

            -- when business group id is null, all the globals shud be reset
            PQP_GB_PSI_FUNCTIONS.set_shared_globals
                   (p_business_group_id => p_business_group_id
                   ,p_paypoint          => g_paypoint
                   ,p_cutover_date      => g_cutover_date
                   ,p_ext_dfn_id        => g_ext_dfn_id
                   );
            -- to allow the users to run cutover run for dates other than cutover date
            --    set in the configuration values.
            --g_effective_date := g_cutover_date;

            -- set extract level globals
            set_address_extract_globals
                    (
                    p_business_group_id     =>    p_business_group_id
                    ,p_assignment_id        =>    p_assignment_id
                    );

            IF g_office_address_type IS NULL AND
               g_home_address_type  IS NULL THEN

               l_include :=  'N';
               debug('Returning : '||l_include,30);
               debug_exit(l_proc);

               RETURN l_include;
            END IF; --IF g_office_address_type IS NULL
            --Raise extract exceptions which are stored while checking for the setup
            debug('Raising the set-up errors, with input parameter as S');
            PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions('S');
        END IF;--IF g_business_group_id IS NULL

        l_include :=  PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
                        (p_business_group_id        =>  p_business_group_id
                        ,p_effective_date           =>  p_effective_date
                        ,p_assignment_id            =>  p_assignment_id
                        ,p_person_dtl               =>  g_curr_person_dtls
                        ,p_assignment_dtl           =>  g_curr_assg_dtls
                        );
        IF l_include = 'N' THEN
            debug('Returning : '||l_include,20);
            debug_exit(l_proc);
            return l_include;
        END IF; --IF l_include = 'N'

        debug('Person passed the basic criteria',10);
        debug('g_assignment_id: '||g_assignment_id);

        IF g_assignment_id IS NULL
           OR p_assignment_id <> nvl(g_assignment_id,0) THEN
            g_effective_date  :=  p_effective_date;
            set_assignment_globals
                  (
                  p_assignment_id         =>    p_assignment_id
                  ,p_effective_date       =>    p_effective_date
                  );
        END IF;

        debug('Returning : '||l_include,10);
        debug_exit(l_proc);

        RETURN l_include;
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
    END address_cutover_ext_criteria;
    -- ----------------------------------------------------------------------------
    -- |--------------------< address_periodic_ext_criteria >---------------------|
    --  Description:  Address Periodic extract Criteria.
    -- ----------------------------------------------------------------------------
    FUNCTION address_periodic_ext_criteria
                (
                p_business_group_id      NUMBER
                ,p_assignment_id         NUMBER
                ,p_effective_date        DATE
                )RETURN VARCHAR2
    IS
          l_include     varchar2(1) := 'Y';
          l_proc varchar2(72) := g_package||'.address_periodic_ext_criteria';
          l_chg_surrogate_key   VARCHAR2(30);
          l_change_table        VARCHAR2(30);
          l_change_column       VARCHAR2(30);
          l_curr_evt_index      NUMBER;
          l_error               NUMBER;
    BEGIN
        debug_enter(l_proc);
        debug('Inputs are: ',10);
        debug('p_business_group_id: '||p_business_group_id,10);
        debug('p_assignment_id: '||p_assignment_id,10);

        debug('ben_ext_person.g_chg_pay_table '||ben_ext_person.g_chg_pay_table,10);
        debug('ben_ext_person.g_chg_pay_column '||ben_ext_person.g_chg_pay_column,10);
        debug('ben_ext_person.g_chg_eff_dt '||ben_ext_person.g_chg_eff_dt,10);
        debug('ben_ext_person.g_chg_update_type '||ben_ext_person.g_chg_update_type,10);
        debug('ben_ext_person.g_chg_surrogate_key '||ben_ext_person.g_chg_surrogate_key,10);

        -- reset salary globals
        g_current_run := 'PERIODIC';
        g_effective_date := p_effective_date;

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

            -- set extract level globals
            set_address_extract_globals
                    (
                    p_business_group_id     =>    p_business_group_id
                    ,p_assignment_id        =>    p_assignment_id
                    );
             IF g_office_address_type IS NULL AND
               g_home_address_type  IS NULL THEN

               l_include :=  'N';
               debug('Returning : '||l_include,30);
               debug_exit(l_proc);
               RETURN l_include;
            END IF;
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
        IF l_include = 'N' THEN
            debug('Returning : '||l_include,30);
            debug_exit(l_proc);
            return l_include;
        END IF; --IF l_include = 'N'

        IF g_assignment_id IS NULL
           OR p_assignment_id <> nvl(g_assignment_id,0) THEN

            -- set assignment level globals
            set_assignment_globals
                  (
                  p_assignment_id         =>    p_assignment_id
                  ,p_effective_date       =>    p_effective_date
                  );
        END IF;
        ----------- added in version 115.15
        l_chg_surrogate_key   :=    ben_ext_person.g_chg_surrogate_key;
        l_change_table        :=    ben_ext_person.g_chg_pay_table;
        l_change_column       :=    ben_ext_person.g_chg_pay_column;
        l_curr_evt_index      :=    ben_ext_person.g_chg_pay_evt_index;

        debug('Calling the common include event proc');
        l_include := pqp_gb_psi_functions.include_event
                     (p_actual_date => g_pay_proc_evt_tab(l_curr_evt_index).actual_date
                     ,p_effective_date => g_pay_proc_evt_tab(l_curr_evt_index).effective_date
                     );
        IF l_include = 'N' THEN
            debug('Returning : '||l_include,30);
            debug_exit(l_proc);
            return l_include;
        END IF; --IF l_include = 'N'

        IF UPPER(l_change_table) = 'PER_ADDRESSES' THEN
            IF g_person_addresses.exists(l_chg_surrogate_key)
                AND (g_person_addresses(l_chg_surrogate_key).address_type
                        NOT IN (g_office_address_type,g_home_address_type)
                     OR g_person_addresses(l_chg_surrogate_key).address_type IS NULL) THEN
                 debug('Change on a non-penserver address');
                 IF NOT chk_pen_addresses_exist(g_effective_date) THEN
                    debug('There are no penserver addresses active on the date: '||g_effective_date);
                    IF g_person_addresses(l_chg_surrogate_key).address_type IS NULL THEN
                        debug('Address type is null');
                        -- Raise Error: there are no addresses for the person
                        l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94481
                               ,p_error_text          =>    'BEN_94481_NO_ADD_TYPE'
                               ,p_token1              =>    l_chg_surrogate_key
                               );
                    ELSE
                        debug('Address type of the Current address is not mapped');
                        -- Raise Error: there are no addresses for the person
                        l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94469
                               ,p_error_text          =>    'BEN_94469_ADD_TYPE_NOT_MAPPED'
                               ,p_token1              =>    g_person_addresses(l_chg_surrogate_key).address_meaning
                               );
                      g_report_non_pen_address  :=  true;
                    END IF; --IF g_person_addresses(l_chg_surrogate_key).address_type

                 END IF;--IF NOT chk_pen_addresses_exist(g_effective_date)

            END IF;---IF g_person_addresses.exists(l_chg_surrogate_key)

        END IF; --IF UPPER(l_change_table) = 'PER_ADDRESSES'
        --------------------------

        debug('Returning : '||l_include,10);
        debug_exit(l_proc);
        RETURN l_include;
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
    END address_periodic_ext_criteria;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------< chk_office_address_changed >-----------------------|
    -- Description: This procedure is to set the global g_office_address_changed,
    --                which indicates whether
    --                 1)there are any changes in office address for periodic extract,
    --                 2)there is an office address active on the cutover date for
    --                                                              cutover extract.
    -- ----------------------------------------------------------------------------
    FUNCTION chk_office_address_changed RETURN VARCHAR2
    IS
          l_proc varchar2(72) := g_package||'.chk_office_address_changed';
          l_error               NUMBER;
          l_chg_surrogate_key   VARCHAR2(30);
          l_change_table        VARCHAR2(30);
          l_change_column       VARCHAR2(30);
          l_index               VARCHAR2(10);
    BEGIN
          debug_enter(l_proc);

          --set global variable that the current layout is 'OFFICE' address
          g_current_layout := 'OFFICE';
          debug('g_current_layout: '||g_current_layout,10);
          debug('g_current_run: '||g_current_run,10);
          debug('g_office_address_changed: '||g_office_address_changed,10);
          --
          IF  g_current_run = 'PERIODIC' THEN
              g_office_address_changed   :=   'N';
              l_chg_surrogate_key   :=    ben_ext_person.g_chg_surrogate_key;
              l_change_table        :=    ben_ext_person.g_chg_pay_table;
              l_change_column       :=    ben_ext_person.g_chg_pay_column;
              debug('l_chg_surrogate_key: '||l_chg_surrogate_key,20);
              debug('l_change_table: '||l_change_table,20);
              debug('l_change_column: '||l_change_column,20);
              debug('g_current_run: '||g_current_run,20);

              IF (l_change_table = 'PER_ALL_PEOPLE_F'
                  AND (l_change_column IN ('EMAIL_ADDRESS','MAILSTOP','NATIONAL_IDENTIFIER')))
                 OR l_change_table = 'PER_ALL_ASSIGNMENTS_F'
              THEN
                   g_office_address_id  :=  NULL;
                   FOR i IN 1..g_person_addresses.COUNT
                   LOOP
                      IF i=1 THEN
                        l_index  :=  g_person_addresses.FIRST;
                      ELSE
                        l_index :=  g_person_addresses.NEXT(l_index);
                      END IF; --IF i=1

                      IF (g_effective_date BETWEEN g_person_addresses(l_index).date_from
                            AND NVL(g_person_addresses(l_index).date_to,c_highest_date))
                         AND g_person_addresses(l_index).address_type = g_office_address_type THEN

                             g_office_address_id  :=  g_person_addresses(l_index).address_id;

                      END IF;--IF (p_effective_date BETWEEN
                   END LOOP;
                   g_office_address_changed := 'Y';
                   debug('g_office_address_id: '||g_office_address_id,30);
                   debug('g_office_address_changed: '||g_office_address_changed,30);
                   debug('Returning: Y',30);
                   debug_exit(l_proc);
                   RETURN g_office_address_changed;
              END IF;
              IF g_person_addresses.exists(l_chg_surrogate_key) THEN
                 IF g_person_addresses(l_chg_surrogate_key).address_type = g_office_address_type  THEN
                    g_office_address_id   :=   l_chg_surrogate_key;
                    g_office_address_changed  := 'Y';
                    g_office_address_reported :=  true;
                    debug('g_office_address_id: '||g_office_address_id,40);
                    debug('Returning: Y',40);
                    debug_exit(l_proc);
                    RETURN g_office_address_changed;

                END IF; --IF g_asg_salary_ele_dtls(l_index).address_type = 'OF'
              END IF;

          END IF;--IF  g_current_run = 'PERIODIC'
          debug('Returning: '||g_office_address_changed,10);
          debug_exit(l_proc);
          RETURN g_office_address_changed;
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
    END chk_office_address_changed;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------< chk_home_address_changed >------------------------|
    -- Description: This procedure is to set the global g_home_address_changed,
    --                which indicates whether
    --                 1)there are any changes in home address for periodic extract,
    --                 2)there is an home address active on the cutover date for
    --                                                              cutover extract.
    -- ----------------------------------------------------------------------------
    FUNCTION chk_home_address_changed RETURN VARCHAR2
    IS
            l_proc varchar2(72) := g_package||'.chk_home_address_changed';
            l_error               NUMBER;
            l_chg_surrogate_key   VARCHAR2(30);
            l_change_table        VARCHAR2(30);
            l_change_column       VARCHAR2(30);
            l_index               VARCHAR2(10);
    BEGIN
          debug_enter(l_proc);

          --set global variable that the current layout is 'OFFICE' address
          g_current_layout := 'HOME';
          debug('g_current_layout: '||g_current_layout,10);
          debug('g_current_run: '||g_current_run,10);
          debug('g_home_address_changed: '||g_home_address_changed,10);
          --
          IF  g_current_run = 'PERIODIC' THEN
              g_home_address_changed   :=   'N';
              l_chg_surrogate_key   :=    ben_ext_person.g_chg_surrogate_key;
              l_change_table        :=    ben_ext_person.g_chg_pay_table;
              l_change_column       :=    ben_ext_person.g_chg_pay_column;
              debug('l_chg_surrogate_key: '||l_chg_surrogate_key,20);
              debug('l_change_table: '||l_change_table,20);
              debug('l_change_column: '||l_change_column,20);
              debug('g_current_run: '||g_current_run,20);

              IF (l_change_table = 'PER_ALL_PEOPLE_F'
                  AND (l_change_column IN ('EMAIL_ADDRESS','MAILSTOP','NATIONAL_IDENTIFIER')))
                 OR l_change_table = 'PER_ALL_ASSIGNMENTS_F'
              THEN
                   g_home_address_id  :=  NULL;
                   FOR i IN 1..g_person_addresses.COUNT
                   LOOP
                      IF i=1 THEN
                        l_index  :=  g_person_addresses.FIRST;
                      ELSE
                        l_index :=  g_person_addresses.NEXT(l_index);
                      END IF; --IF i=1

                      IF (g_effective_date BETWEEN g_person_addresses(l_index).date_from
                            AND NVL(g_person_addresses(l_index).date_to,c_highest_date))
                         AND g_person_addresses(l_index).address_type = g_home_address_type THEN

                             g_home_address_id  :=  g_person_addresses(l_index).address_id;

                      END IF;--IF (p_effective_date BETWEEN
                   END LOOP;
                   g_home_address_changed := 'Y';
                   debug('g_home_address_id: '||g_home_address_id,30);
                   debug('g_home_address_changed: '||g_home_address_changed,30);
                   debug('Returning: Y',30);
                   debug_exit(l_proc);
                   RETURN g_home_address_changed;
              END IF;--IF (l_change_table = 'PER_ALL_PEOPLE_F'

              IF g_person_addresses.exists(l_chg_surrogate_key) THEN
                 IF g_person_addresses(l_chg_surrogate_key).address_type = g_home_address_type  THEN
                    g_home_address_id   :=   l_chg_surrogate_key;
                    g_home_address_changed := 'Y';
                    debug('g_home_address_id: '||g_home_address_id,40);
                    debug('Returning: Y',40);
                    debug_exit(l_proc);
                    RETURN g_home_address_changed;
                END IF; --IF g_asg_salary_ele_dtls(l_index).address_type = 'OF'
              END IF; --IF g_person_addresses.exists

          END IF;--IF  g_current_run = 'PERIODIC'
          debug('Returning: '||g_home_address_changed,10);
          debug_exit(l_proc);
          RETURN g_home_address_changed;
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
    END chk_home_address_changed;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------< is_office_address_changed >------------------------|
    --  Description:  This process will return the value of the global variable
    --                  g_include_office_address, which indicates whether the office
    --                  address is to be picked or not. The value of this is checked
    --                  in the extra conditions on the office address record.
    --                  g_include_office_address is set to 'N' if there are any data
    --                  errors raised.
    -- ----------------------------------------------------------------------------
    FUNCTION is_office_address_changed RETURN VARCHAR2
    IS
          l_proc varchar2(72) := g_package||'.is_office_address_changed';
    BEGIN
          debug_enter(l_proc);

          debug('g_include_office_address: '||g_include_office_address,10);

          debug_exit(l_proc);
          RETURN g_include_office_address;
    END is_office_address_changed;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------< is_home_address_changed >------------------------|
    --  Description:  This process will return the value of the global variable
    --                  g_include_home_address, which indicates whether the home
    --                  address is to be picked or not. The value of this is checked
    --                  in the extra conditions on the home address record.
    --                  g_include_home_address is set to 'N' if there are any data
    --                  errors raised.
    -- ----------------------------------------------------------------------------
    FUNCTION is_home_address_changed RETURN VARCHAR2
    IS
            l_proc varchar2(72) := g_package||'.is_home_address_changed';
    BEGIN
          debug_enter(l_proc);

          debug('g_include_home_address: '||g_include_home_address,10);

          debug_exit(l_proc);
          RETURN g_include_home_address;
    END is_home_address_changed;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------< address_data_element_value >-----------------------|
    --  Description:  This is a common function used by all the data elements to fetch
    --                  thier respective values. Depending the parameter p_ext_user_value
    --                  this procedure decides which value to be returned.
    -- ----------------------------------------------------------------------------
    FUNCTION address_data_element_value
             (
             p_ext_user_value     IN VARCHAR2
             ,p_output_value       OUT NOCOPY VARCHAR2
             ) RETURN NUMBER
    IS
          l_proc varchar2(72) := g_package||'.address_data_element_value';
          l_error   NUMBER;
          l_chg_surrogate_key   NUMBER;
          l_change_table        VARCHAR2(30);
          l_change_column       VARCHAR2(30);
          l_index               NUMBER;
          -- ----------------------------------------------------------------------------
          -- |--------------------------< get_address_code >-----------------------------|
          --  Description: This procedure is to fetch the address code, HM/OF for Home &
          --                Office address respectively.
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_code
                  (
                  p_address_code       OUT NOCOPY VARCHAR2
                  ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_code';
          BEGIN
              debug_enter(l_proc);
              IF g_current_layout =  'HOME' THEN
                  p_address_code  := 'HM';
              ELSE
                  p_address_code  :=  'OF';
              END IF;
              debug_exit(l_proc);
              return 0;
          END get_address_code;
          ------
          -- ----------------------------------------------------------------------------
          -- |-------------------------< get_address_line1 >----------------------------|
          --  Description: This procedure is to fetch address line 1 of the current address
          --                  being processed
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_line1
              (
              p_address_line1       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_line1';
              l_address_line1     per_addresses.address_line1%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_address_line1  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line1  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).address_line1,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line1  :=  NVL(g_person_addresses(l_chg_surrogate_key).address_line1,'');

                  END IF;
              END IF;
              p_address_line1   :=   l_address_line1;
              IF p_address_line1 IS NULL THEN
                  -- raise error
                  debug('ERROR: No Address Line 1. This is a mandatory field',20);
                  l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                         (p_error_number        =>    94462
                         ,p_error_text          =>    'BEN_94462_NO_ADD_LINE1'
                         ,p_token1              =>    l_chg_surrogate_key
                         );
                  /*
                  -- currently errored records are also reported
                  -- uncomment this part when they need not be reported.
                  IF g_current_layout =  'HOME' THEN
                      g_include_home_address  :=  'N';
                  ELSE
                      g_include_office_address  :=  'N';
                  END IF; -- IF g_current_layout =  'HOME'*/

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
          END get_address_line1;
          ------
          -- ----------------------------------------------------------------------------
          -- |-------------------------< get_address_line2 >----------------------------|
          --  Description: This procedure is to fetch address line 2 of the current address
          --                  being processed
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_line2
              (
              p_address_line2       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_line2';
              l_address_line2     per_addresses.address_line2%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_address_line2  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line2  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).address_line2,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line2  :=  NVL(g_person_addresses(l_chg_surrogate_key).address_line2,'');

                  END IF;
              END IF;
              p_address_line2   :=   l_address_line2;
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
          END get_address_line2;
          ------
          -- ----------------------------------------------------------------------------
          -- |-------------------------< get_address_line3 >----------------------------|
          --  Description: This procedure is to fetch address line 3 of the current address
          --                  being processed
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_line3
              (
              p_address_line3       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_line3';
              l_address_line3     per_addresses.address_line3%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_address_line3  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line3  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).address_line3,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line3  :=  NVL(g_person_addresses(l_chg_surrogate_key).address_line3,'');

                  END IF;
              END IF;
              /*-- check data type
              IF NOT pqp_gb_psi_functions.is_alphanumeric(l_address_line3) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94464
                       ,p_error_text          =>    'BEN_94464_INVALID_ADD_LIN3'
                       ,p_token1              =>    l_chg_surrogate_key
                       );

              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_address_line3)*/

              p_address_line3   :=   l_address_line3;
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
          END get_address_line3;
          ------
          -- ----------------------------------------------------------------------------
          -- |------------------------< get_address_line4 >-----------------------------|
          --  Description: This procedure is to fetch address line 4 of the current address
          --                  being processed. The value of this is Town/City.
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_line4
              (
              p_address_line4       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_line4';
              l_address_line4     per_addresses.region_1%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_address_line4  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line4  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).address_line4,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line4  :=  NVL(g_person_addresses(l_chg_surrogate_key).address_line4,'');

                  END IF;
              END IF;
              /*-- check data type
              IF NOT pqp_gb_psi_functions.is_alphanumeric(l_address_line4) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94464
                       ,p_error_text          =>    'BEN_94464_INVALID_ADD_LIN4'
                       ,p_token1              =>    l_chg_surrogate_key
                       );

              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_address_line4)*/

              p_address_line4   :=   l_address_line4;
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
          END get_address_line4;
          ------
          -- ----------------------------------------------------------------------------
          -- |------------------------< get_address_line5 >-----------------------------|
          --  Description: This procedure is to fetch address line 5 of the current address
          --                  being processed. The value of this is Town/City.
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_line5
              (
              p_address_line5       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_line5';
              l_address_line5     per_addresses.region_1%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_address_line5  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line5  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).address_line5,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_address_line5  :=  NVL(g_person_addresses(l_chg_surrogate_key).address_line5,'');

                  END IF;
              END IF;
              /*-- check data type
              IF NOT pqp_gb_psi_functions.is_alphanumeric(l_address_line5) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94464
                       ,p_error_text          =>    'BEN_94464_INVALID_ADD_LIN4'
                       ,p_token1              =>    l_chg_surrogate_key
                       );

              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_address_line5)*/

              p_address_line5   :=   l_address_line5;
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
          END get_address_line5;
          ------
          -- ----------------------------------------------------------------------------
          -- |------------------------< get_address_postcode >--------------------------|
          --  Description: This procedure is to fetch Postcode of the current address
          --                  being processed. The value of Postcode shuould not be null
          --                  when Country is United Kingdom.
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_postcode
              (
              p_address_postcode       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_postcode';
              l_postal_code     per_addresses.postal_code%TYPE;
              l_country         per_addresses.country%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_postal_code  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_postal_code  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).postal_code,'');
                      l_country      :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).country,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_postal_code  :=  NVL(g_person_addresses(l_chg_surrogate_key).postal_code,'');
                      l_country      :=  NVL(g_person_addresses(l_chg_surrogate_key).country,'');

                  END IF;
              END IF;
              IF UPPER(l_country)='UNITED KINGDOM' AND l_postal_code IS NULL THEN
                  -- raise error
                  debug('ERROR: Postal Code cannot be empty for UK Addresses.',40);
                  l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                         (p_error_number        =>    94438
                         ,p_error_text          =>    'BEN_94438_INVALID_POST_CODE'
                         ,p_token1              =>    l_chg_surrogate_key
                         );

              END IF;
              /*-- check data type
              IF NOT pqp_gb_psi_functions.is_alphanumeric(l_postal_code) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94464
                       ,p_error_text          =>    ' BEN_94438_INVALID_POSTAL_CODE'
                       ,p_token1              =>    l_chg_surrogate_key
                       );

              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_postal_code)*/

              p_address_postcode   :=   l_postal_code;
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
          END get_address_postcode;
          ------
          -- ----------------------------------------------------------------------------
          -- |------------------------< get_country >-----------------------------|
          --  Description: This procedure is to fetch country of the current address
          --                  being processed.
          -- ----------------------------------------------------------------------------
          FUNCTION get_country
              (
              p_country       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_country';
              l_country     per_addresses.country%TYPE;
          BEGIN
              debug_enter(l_proc);
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_country  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).country,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_country  :=  NVL(g_person_addresses(l_chg_surrogate_key).country,'');

                  END IF;
              END IF;
              IF l_country IS NULL THEN
                  debug('ERROR: Country field is mandatory if not UK',40);
                  l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                         (p_error_number        =>    94439
                         ,p_error_text          =>    'BEN_94439_INVALID_COUNTRY'
                         ,p_token1              =>    l_chg_surrogate_key
                         );

              ELSIF UPPER(l_country) = 'UNITED KINGDOM' THEN

                 l_country := '';

              END IF;
              /*-- check data type
              IF NOT pqp_gb_psi_functions.is_alphanumeric(l_country) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94439
                       ,p_error_text          =>    'BEN_94439_INVALID_COUNTRY'
                       ,p_token1              =>    l_chg_surrogate_key
                       );

              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_country)*/

              p_country   :=   l_country;
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
          END get_country;
          ------
          -- ----------------------------------------------------------------------------
          -- |------------------------< get_address_effdate >---------------------------|
          --  Description: This procedure is to fetch effective start date of the current
          --                  address being processed.
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_effdate
              (
              p_address_effdate       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_effdate';
              l_date_from     per_addresses.date_from%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_date_from  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_date_from  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).date_from,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_date_from  :=  NVL(g_person_addresses(l_chg_surrogate_key).date_from,'');

                  END IF;
              END IF;
              p_address_effdate   :=   to_char(NVL(l_date_from,''),'dd/mm/yyyy');
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
          END get_address_effdate;
          ------
          -- ----------------------------------------------------------------------------
          -- |-----------------------< get_address_mailstop >---------------------------|
          --  Description: This procedure is to fetch MailSort code of the current Person.
          --                This value will be reported in Office address only.
          -- ----------------------------------------------------------------------------
          FUNCTION get_address_mailstop
              (
              p_address_mailstop       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_address_mailstop';
              l_mailstop     PER_ALL_PEOPLE_F.mailstop%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_mailstop  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN

                  l_mailstop  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).mailstop,'');

              ELSE

                  OPEN csr_get_email_mailstop;
                  FETCH csr_get_email_mailstop INTO g_email_address,l_mailstop;
                  CLOSE csr_get_email_mailstop;

              END IF;
              IF NOT pqp_gb_psi_functions.is_numeric(l_mailstop) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94472
                       ,p_error_text          =>    'BEN_94472_INVALID_MAILSTOP'
                       ,p_token1              =>    l_mailstop
                       );

              ELSIF length(l_mailstop) > 5
                  OR hr_number.canonical_to_number(l_mailstop) NOT BETWEEN 0 AND 99999 THEN
                  -- raise error
                  debug('ERROR: Invalid Length.',40);
                  l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                         (p_error_number        =>    94985
                         ,p_error_text          =>    'BEN_94985_INVALID_MAILSTOP_LEN'
                         ,p_token1              =>    l_mailstop
                         );
                  l_mailstop  := substr(l_mailstop,-5);
              ELSE
                  debug('Apply format mask 09999 on correct mailstop',40);
                  l_mailstop  :=  ltrim(rtrim(to_char(hr_number.canonical_to_number(l_mailstop),'09999')));
              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_mailstop)

              p_address_mailstop   :=   l_mailstop;
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
          END get_address_mailstop;
          ------
          -- ----------------------------------------------------------------------------
          -- |--------------------------< get_emailaddress >-----------------------------|
          --  Description: This procedure is to fetch email address of the current Person.
          --                This value will be reported in Office address only.
          -- ----------------------------------------------------------------------------
          FUNCTION get_emailaddress
              (
              p_emailaddress       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_emailaddress';
              l_email_address     per_all_people_f.email_address%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_email_address  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN

                  l_email_address  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).email_address,'');

              ELSE

                  l_email_address  :=  g_email_address;

              END IF;
              /*-- check data type
              IF NOT pqp_gb_psi_functions.is_alphanumeric(l_email_address) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94464
                       ,p_error_text          =>    'BEN_94464_INVALID_EMAIL_ID'
                       ,p_token1              =>    l_chg_surrogate_key
                       ,p_token2              =>    l_email_address
                       );

              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_email_address)*/
              p_emailaddress   :=   l_email_address;
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
          END get_emailaddress;
          ------
          -- ----------------------------------------------------------------------------
          -- |------------------------< get_telephone_number_1 >------------------------|
          --  Description: This procedure is to fetch Primary telephone number of the current
          --                  address being processed.
          -- ----------------------------------------------------------------------------
          FUNCTION get_telephone_number_1
              (
              p_telephone_number_1       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_telephone_number_1';
              l_telephone_number_1     per_addresses.telephone_number_1%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_telephone_number_1  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_telephone_number_1  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).telephone_number_1,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_telephone_number_1  :=  NVL(g_person_addresses(l_chg_surrogate_key).telephone_number_1,'');

                  END IF;
              END IF;
              -- check data type
              IF NOT pqp_gb_psi_functions.is_alphanumeric_space_allowed(l_telephone_number_1) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94470
                       ,p_error_text          =>    'BEN_94470_INVALID_TELE_PH1'
                       ,p_token1              =>    l_chg_surrogate_key
                       ,p_token2              =>    l_telephone_number_1
                       );
              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_telephone_number_1)

              p_telephone_number_1   :=   l_telephone_number_1;
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
          END get_telephone_number_1;
          ------

          -- ----------------------------------------------------------------------------
          -- |-----------------------< get_telephone_number_2 >--------------------------|
          --  Description: This procedure is to fetch Secondary telephone number of the current
          --                  address being processed.
          -- ----------------------------------------------------------------------------
          FUNCTION get_telephone_number_2
              (
              p_telephone_number_2       OUT NOCOPY VARCHAR2
              ) RETURN NUMBER
          IS
              l_proc varchar2(72) := g_package||'.get_telephone_number_2';
              l_telephone_number_2     per_addresses.telephone_number_2%TYPE;
          BEGIN
              debug_enter(l_proc);
              l_telephone_number_2  :=  NULL;
              IF g_current_run  =   'CUTOVER'   THEN
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_telephone_number_2  :=  NVL(g_person_cutover_addresses(l_chg_surrogate_key).telephone_number_2,'');

                  END IF;
              ELSE
                  IF (g_current_layout =  'HOME'  AND g_home_address_changed = 'Y') OR
                      (g_current_layout =  'OFFICE'  AND g_office_address_changed = 'Y') THEN

                      l_telephone_number_2  :=  NVL(g_person_addresses(l_chg_surrogate_key).telephone_number_2,'');

                  END IF;
              END IF;
              -- check data type
              IF NOT pqp_gb_psi_functions.is_alphanumeric_space_allowed(l_telephone_number_2) THEN
                -- raise error
                debug('ERROR: Invalid Datatype.',40);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                       (p_error_number        =>    94471
                       ,p_error_text          =>    'BEN_94471_INVALID_TELE_PH2'
                       ,p_token1              =>    g_person_id
                       ,p_token2              =>    l_telephone_number_2
                       );
              END IF; --IF NOT pqp_gb_psi_functions.is_numeric(l_telephone_number_2)

              p_telephone_number_2   :=   l_telephone_number_2;
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
          END get_telephone_number_2;
          ------
    BEGIN -- address_data_element_value
          --
          debug_enter(l_proc);
          IF (g_current_run  =  'CUTOVER' AND g_person_cutover_addresses.COUNT = 0)
            OR (g_current_run  =  'PERIODIC' AND g_person_addresses.COUNT = 0) THEN

                debug('There are no penserver addresses');
                g_include_office_address  :=  'N'; --For Bug 7255335:Changed flag to N
                g_include_home_address    :=  'N';
                debug('p_output_value: '||p_output_value,10);
                debug_exit(l_proc);
                return l_error;

          END IF;

          -- check if the data element is to check whether office address
          --    is to be reported or not.
          IF p_ext_user_value = 'OFFICE' then

                g_include_office_address  :=  chk_office_address_changed();
                debug('p_output_value: '||p_output_value,10);
                debug_exit(l_proc);
                return l_error;

          END IF;
          -- check if the data element is to check whether home address
          --    is to be reported or not
          IF p_ext_user_value = 'HOME' then

                g_include_home_address  :=  chk_home_address_changed();
                debug('p_output_value: '||p_output_value,10);
                debug_exit(l_proc);
                return l_error;

          END IF;

          -- for cutover run, the office/home address id is set while
          --    setting the assignment globals. and this is used as the
          --    surrogate key to the individual data element functions.
          IF g_current_run = 'CUTOVER' THEN
              IF g_current_layout = 'OFFICE' THEN
                  l_chg_surrogate_key   :=    g_office_address_id;
              ELSE
                  l_chg_surrogate_key   :=    g_home_address_id;
              END IF;
          ELSE
              l_chg_surrogate_key   :=    ben_ext_person.g_chg_surrogate_key;
              l_change_table        :=    ben_ext_person.g_chg_pay_table;
              l_change_column       :=    ben_ext_person.g_chg_pay_column;
              -- added in version 115.15
              IF UPPER(l_change_table) = 'PER_ADDRESSES'
                AND g_person_addresses.exists(l_chg_surrogate_key)
                    AND (g_person_addresses(l_chg_surrogate_key).address_type
                            NOT IN (g_office_address_type,g_home_address_type)
                        OR g_person_addresses(l_chg_surrogate_key).address_type IS NULL)
                    AND g_report_non_pen_address  = true  THEN
                    IF nvl(g_office_address_reported,false) THEN
                        debug('Office address reported');
                        debug('Including the non-penserver address details in home address');
                        g_include_home_address  :=  'Y';
                    ELSE
                        debug('Office address not reported');
                        debug('Including the non-penserver address details in office address');
                        g_include_office_address  :=  'Y';
                    END IF;
                    debug('p_output_value: '||p_output_value,10);
                    debug_exit(l_proc);
                    return l_error;
              END IF;--IF UPPER(l_change_table) = 'PER_ADDRESSES'
              ----------
          END IF;--IF g_current_run = 'CUTOVER'

          debug('l_change_table: '||l_change_table,10);
          debug('l_change_column: '||l_change_column,10);
          debug('g_current_layout: '||g_current_layout);
          debug('g_effective_date: '||g_effective_date);
          debug('g_office_address_changed: '||g_office_address_changed,10);
          debug('g_home_address_changed: '||g_home_address_changed,10);

          IF (g_current_layout = 'OFFICE' AND g_office_address_changed = 'Y') OR
                  (g_current_layout = 'HOME' AND g_home_address_changed = 'Y') THEN
                  debug('Record changed: '||g_current_layout,20);

                  -- if the chaged values are on per_all_people_f, the surrogate key
                  --    will be person_id. It is to be set to current address id.
                  --    The home/office address id are picked up from the respective
                  --    global variable. These values are set while setting the assignment
                  --    globals for a cutover run. and during chk_xxx_address_changed function
                  --    for periodic changes extract.
                  IF l_change_table <> 'PER_ADDRESSES' THEN
                      IF g_current_layout = 'OFFICE' THEN
                        l_chg_surrogate_key := g_office_address_id;
                     ELSE
                        l_chg_surrogate_key := g_home_address_id;
                     END IF;

                  END IF;
                  debug('l_chg_surrogate_key: '||l_chg_surrogate_key,10);
                  IF g_current_run='PERIODIC'
                     AND NOT (g_person_addresses.exists(l_chg_surrogate_key)) THEN
                    debug('No addresses for the surrogate key');
                     IF g_current_layout = 'OFFICE' THEN
                        g_include_office_address := 'N';
                     ELSE
                        g_include_home_address := 'N';
                     END IF;
                     debug('p_output_value: '||p_output_value,10);
                     debug_exit(l_proc);
                     return l_error;
                  END IF;
                  -- fetch the value from the individual data element functions
                  --    depending on the p_ext_user_value.
                  if p_ext_user_value = 'AddressCode' then
                  debug('Fetching Address Code',30);
                    l_error := get_address_code
                                  (
                                  p_address_code        =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'AddEffectiveDate' then
                  debug('Fetching AddEffectiveDate',30);
                     l_error := get_address_effdate
                                  (
                                  p_address_effdate     =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'AddressLine1' then
                  debug('Fetching AddressLine1',30);
                     l_error := get_address_line1
                                  (
                                  p_address_line1       =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'AddressLine2' then
                  debug('Fetching AddressLine2',30);
                     l_error := get_address_line2
                                  (
                                  p_address_line2       =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'AddressLine3' then
                  debug('Fetching AddressLine3',30);
                     l_error := get_address_line3
                                  (
                                  p_address_line3       =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'AddressLine4' then
                  debug('Fetching AddressLine4',30);
                     l_error := get_address_line4
                                  (
                                  p_address_line4       =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'AddressLine5' then
                  debug('Fetching AddressLine4',30);
                     l_error := get_address_line5
                                  (
                                  p_address_line5       =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'Country' then
                  debug('Fetching Country',30);
                      l_error := get_country
                                  (
                                  p_country             =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'EmailAddress' then
                  debug('Fetching EmailAddress',30);
                     l_error := get_emailaddress
                                  (
                                  p_emailaddress        =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'MailStop' then
                  debug('Fetching MailStop',30);
                     l_error := get_address_mailstop
                                  (
                                  p_address_mailstop    =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'PostCode' then
                  debug('Fetching PostCode',30);
                     l_error := get_address_postcode
                                  (
                                  p_address_postcode    =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'TelephoneNumber1' then
                  debug('Fetching TelephoneNumber1',30);
                     l_error := get_telephone_number_1
                                  (
                                  p_telephone_number_1  =>  p_output_value
                                  );
                  elsif p_ext_user_value = 'TelephoneNumber2' then
                  debug('Fetching TelephoneNumber2',30);
                     l_error := get_telephone_number_2
                                  (
                                  p_telephone_number_2  =>  p_output_value
                                  );
                  end if; --if p_ext_user_value
          ELSE
                debug('No changes in the record: '||g_current_layout);
          END IF; --IF (g_current_layout = 'PRIMARY' AND g_primary_address_changed = 'Y') OR
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
    END address_data_element_value;
    ------
    -- ----------------------------------------------------------------------------
    -- |----------------------< address_post_processing >--------------------------|
    --  Description:  This is the post-processing rule  for the address layout.
    -- ----------------------------------------------------------------------------
    FUNCTION address_post_processing RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.address_post_processing';
    BEGIN
        debug_enter(l_proc);

        --Raise extract exceptions which are stored while processing the data elements
        --debug('Raising the DE errors, with input parameter as S');
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
    END address_post_processing;
    ------
    -- ----------------------------------------------------------------------------
    -- |----------------------< chk_pen_addresses_exist >--------------------------|
    --  Description:  This function is used to check if there are any perserver addresses
    --                  active on a particular date.
    -- ----------------------------------------------------------------------------
    FUNCTION chk_pen_addresses_exist
              (
              p_effective_date  DATE
              ) RETURN BOOLEAN
    IS
        l_proc varchar2(72) := g_package||'.chk_pen_addresses_exist';
        l_index         NUMBER;
    BEGIN
        debug_enter(l_proc);

        FOR i IN 1..g_person_addresses.COUNT
        LOOP
          IF i=1 THEN
            l_index  :=  g_person_addresses.FIRST;
          ELSE
            l_index :=  g_person_addresses.NEXT(l_index);
          END IF; --IF i=1

          IF (p_effective_date BETWEEN g_person_addresses(l_index).date_from
                AND NVL(g_person_addresses(l_index).date_to,c_highest_date))
             AND (g_person_addresses(l_index).address_type IN
                              (g_office_address_type,g_home_address_type)) THEN

                 return TRUE;
          END IF;--IF (p_effective_date BETWEEN
        END LOOP;

        debug_exit(l_proc);
        return FALSE;
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
    END chk_pen_addresses_exist;
    ------
END PQP_GB_PSI_ADDDRESS;

/
