--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_BON_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_BON_HISTORY" AS
    --  /* $Header: pqpgbpsibon.pkb 120.5.12010000.2 2008/08/05 14:06:39 ubhat ship $ */
    --
    --
    --
    --
    --
    -- Exceptions
    hr_application_error exception;
    pragma exception_init (hr_application_error, -20001);

    g_nested_level       NUMBER(5) := pqp_utilities.g_nested_level;

-- For BUG 5998129
    l_element_of_bonus_type VARCHAR2(1);
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

       PROCEDURE debug_enter (p_proc_name IN VARCHAR2
                             ,p_trace_on IN VARCHAR2 DEFAULT NULL)
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

       PROCEDURE debug_exit (p_proc_name IN VARCHAR2
                            ,p_trace_off IN VARCHAR2  DEFAULT NULL )
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

    ---
    -- ----------------------------------------------------------------------------
    -- |---------------< set_bonus_balance_type >-------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    PROCEDURE set_bonus_balance_type
    IS
        l_proc varchar2(72) := g_package||'.set_bonus_balance_type';
        l_config_values   PQP_UTILITIES.t_config_values;
    BEGIN
        debug_enter(l_proc);
        -- fetch the adj hrs source configuration values
        PQP_UTILITIES.get_config_type_values(
                     p_configuration_type   =>    'PQP_GB_PENSERVER_BONBAL_VALUE'
                    ,p_business_group_id    =>    g_business_group_id
                    ,p_legislation_code     =>    g_legislation_code
                    ,p_tab_config_values    =>    l_config_values
                  );
        IF l_config_values.COUNT > 0 THEN
            debug('Configration value exists',20);

            g_bon_bal_type_id   :=  l_config_values(l_config_values.FIRST).pcv_information1;

            debug('g_bon_bal_type_id: '||g_bon_bal_type_id,20);

        ELSE
            debug('ERROR: Configration value is not present',20);
            -- raise error
            PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                               (p_extract_type        =>    'BONUS HISTORY'
                               ,p_error_number        =>    94639
                               ,p_error_text          =>    'BEN_94639_NO_BON_BAL_CONFIG'
                               ,p_error_warning_flag  =>    'E'
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
    END set_bonus_balance_type;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------< set_bonus_history_globals >-------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    PROCEDURE set_bonus_history_globals
              (
              p_business_group_id     IN NUMBER
              ,p_assignment_id        IN NUMBER
              ,p_effective_date       IN DATE
              )
    IS
        l_proc varchar2(72) := g_package||'.set_bonus_history_globals';
    BEGIN
        debug_enter(l_proc);
        -- set global business group id
        g_business_group_id := p_business_group_id;
        g_legislation_code  :=  'GB';

        debug('g_legislation_code: '||g_legislation_code,10);
        debug('g_business_group_id: '||g_business_group_id,10);

        -- set the bonus balance type id from the configuration
        set_bonus_balance_type;

        -- set the globals in pqp_gb_psi_function for all valid bonus types.
        PQP_GB_PSI_FUNCTIONS.get_elements_of_info_type
                                (p_information_type          =>   'PQP_GB_PENSERV_BONUS_INFO'
                                ,p_input_value_mandatory_yn  =>   'N'
                                );

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
    END set_bonus_history_globals;
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

        CURSOR csr_start_date
        IS
            select PPS.DATE_START -- DECODE(PER.CURRENT_EMPLOYEE_FLAG,'Y',PPS.DATE_START,NULL)
            from per_all_people_f PER, per_periods_of_service PPS
            where per.person_id = g_person_id
              and pps.person_id = g_person_id
              and p_effective_date  between per.effective_start_date
                       and NVL(per.effective_end_date,hr_api.g_eot)
              and p_effective_date  between pps.date_start
                       and NVL(pps.final_process_date,hr_api.g_eot);

    BEGIN -- set_assignment_globals
        debug_enter(l_proc);
        debug('Inputs are: ',10);
        debug('p_assignment_id: '||p_assignment_id,10);
        debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);

--For BUG 5998129

        -- set the global values to NULL each time when a new assignment processsed.
        g_first_retro_event             := NULL;
        g_first_retro_event_start       := NULL;
        g_first_approved_event          := NULL;


        -- set the global events table
        g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;
        -- clear the global cache for the duplicate bonus codes check
        g_proc_bon_codes.DELETE;

        -- set global assignment_id
        g_assignment_id     := p_assignment_id;
        debug('g_assignment_id: '||g_assignment_id,10);
        g_person_id         :=  PQP_GB_PSI_FUNCTIONS.get_current_extract_person
                              (
                              p_assignment_id => p_assignment_id
                              );
        --set the assignment start date
        OPEN csr_start_date;
        FETCH csr_start_date INTO g_assg_start_date;
        CLOSE csr_start_date;

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
    -- |-----------------------< chk_dup_bon_types >--------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE chk_dup_bon_types
                  (
                  p_effective_date  DATE DEFAULT g_effective_date
                  )
    IS
        l_proc varchar2(72) := g_package||'.chk_dup_bon_types';
        l_return            NUMBER;
        l_effective_date_no NUMBER;
        l_curr_bon_code     VARCHAR2(4);
        l_position          NUMBER;
        l_element_entry_id  VARCHAR2(20);
    BEGIN -- set_assignment_globals
        debug_enter(l_proc);

        -----
        l_effective_date_no :=  to_char(p_effective_date,'ddmmyyyy');
        l_curr_bon_code :=  PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(g_curr_element_type_id).eei_information2;

        debug('l_effective_date_no: '||l_effective_date_no);
        debug('l_curr_bon_code: '||l_curr_bon_code);
        debug('g_curr_element_entry_id: '||g_curr_element_entry_id);
        IF g_proc_bon_codes.EXISTS(l_effective_date_no) THEN
            debug('Value of the string: '||g_proc_bon_codes(l_effective_date_no));

            l_position  :=  instr(g_proc_bon_codes(l_effective_date_no),RPAD(l_curr_bon_code,4,'*'));

            IF l_position > 0 THEN
                debug('Found similar Bous Code');
                l_element_entry_id  :=  SUBSTR(g_proc_bon_codes(l_effective_date_no)
                                          ,l_position+4
                                          ,(INSTR(g_proc_bon_codes(l_effective_date_no),';',l_position)-(l_position+4))
                                          );
                debug('Element Entry id of the dup bonus code: '||l_element_entry_id);
                IF g_curr_element_entry_id <> to_number(l_element_entry_id) THEN
                    -- found a similar bonus code with for a different element entry
                    -- raise a warning;
                    debug('found a similar bonus code with for a different element entry');
                    debug('WARNING: Duplicate Bonus Type on same date');
                    l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                                     (p_error_number        =>    94526
                                     ,p_error_text          =>    'BEN_94526_DUP_BON_TYPE'
                                     ,p_token1              =>    to_char(p_effective_date,'dd/mm/yyyy')
                                     );
                ELSE
                    -- found a similar bonus code is for the same element entry
                    -- no warnign will be raised
                    debug('found a similar bonus code is for the same element entry');
                END IF;


            ELSE
                debug('This Bonus type is not processed.');
                g_proc_bon_codes(l_effective_date_no) :=  g_proc_bon_codes(l_effective_date_no)
                                                            ||
                                                          RPAD(l_curr_bon_code,4,'*')||g_curr_element_entry_id||';' ;
            END IF;
        ELSE
            debug('No entry for the current effective date');
            g_proc_bon_codes(l_effective_date_no) :=  RPAD(l_curr_bon_code,4,'*')||g_curr_element_entry_id||';' ;
        END IF;
        -----

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
    END chk_dup_bon_types;
    ---
    -- ----------------------------------------------------------------------------
    -- |-----------------------< set_curr_row_values >----------------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION set_curr_row_values RETURN BOOLEAN
    IS
        l_proc varchar2(72) := g_package||'.set_curr_row_values';
        l_chg_table                 VARCHAR2(30);
        l_chg_type                  VARCHAR2(30);
        l_chg_surrogate_key         NUMBER;
        l_chg_date                  DATE;
        l_include           VARCHAR2(1);
        l_return            NUMBER;
        CURSOR csr_get_ee_id
                  (
                  p_ele_entry_value_id    NUMBER
                  )
        IS
            SELECT element_entry_id
            FROM pay_element_entry_values_f
            WHERE element_entry_value_id = p_ele_entry_value_id
            AND ROWNUM = 1;
    BEGIN
        debug_enter(l_proc);

        IF g_current_layout = 'PERIODIC' THEN
            -- person repeating level
            l_chg_table         :=  ben_ext_person.g_chg_pay_table;
            l_chg_type          :=  ben_ext_person.g_chg_update_type;
            l_chg_surrogate_key :=  ben_ext_person.g_chg_surrogate_key;
            l_chg_date          :=  ben_ext_person.g_chg_eff_dt;
            debug('l_chg_table: '||l_chg_table,10);
            debug('l_chg_type: '||l_chg_type,10);
            debug('l_chg_surrogate_key: '||l_chg_surrogate_key,10);
            debug('l_chg_date: '||l_chg_date,10);

            IF l_chg_table  <> 'PAY_ELEMENT_ENTRIES_F'
            AND (l_chg_type = 'I' OR l_chg_type = 'C')THEN

                debug('Not a valid event, will not be processed',20);
                debug('Returning FALSE');
                debug_exit(l_proc);
                RETURN FALSE;

            END IF;


        ELSIF g_current_layout = 'CUTOVER' THEN
            -- element repeating level
            g_curr_element_type_id    :=  ben_ext_person.g_element_id;
            g_curr_ee_start_date      :=  ben_ext_person.g_element_entry_eff_start_date;
            g_curr_ee_end_date        :=  ben_ext_person.g_element_entry_eff_end_date;
            g_curr_element_type_name  :=  ben_ext_person.g_element_name;
        END IF;

        IF g_current_layout = 'PERIODIC' THEN
            g_curr_element_entry_id   :=  fnd_number.canonical_to_number(l_chg_surrogate_key);

            IF l_chg_type = 'C' THEN
                -- for correction events on pay_element_entry_values_f
                --  the surrogate key is element_entry_value_id
                --  this should be re-set to element_entry_id
                debug('element_entry_value_id: '||g_curr_element_entry_id,20);
                OPEN csr_get_ee_id(g_curr_element_entry_id);
                FETCH csr_get_ee_id INTO g_curr_element_entry_id;
                CLOSE csr_get_ee_id;
                debug('element_entry_id: '||g_curr_element_entry_id,20);
            END IF;
        ELSE
            g_curr_element_entry_id  :=  ben_ext_person.g_element_entry_id;
        END IF;

        debug('g_curr_element_entry_id: '||g_curr_element_entry_id,10);
        debug('g_curr_element_type_id: '||g_curr_element_type_id,10);
        debug('g_curr_ee_start_date: '||g_curr_ee_start_date,10);
        debug('g_curr_ee_end_date: '||g_curr_ee_end_date,10);

        IF g_current_layout = 'PERIODIC' THEN
            PQP_GB_PSI_FUNCTIONS.check_if_element_qualifies
                                  (p_element_entry_id   =>  g_curr_element_entry_id
                                  ,p_element_type_id    =>  g_curr_element_type_id
                                  ,p_include            =>  l_include
                                  );

            IF l_include = 'N'  THEN
                debug('Rejected by check_if_element_qualifies',30);
                debug('Returning FALSE',30);

--For BUG 5998129
                -- Setting the No flag for the elements of non bonus type
                -- use to check before the call pqp_gb_psi_functions.process_retro_event
                l_element_of_bonus_type := 'N';
--END For BUG 5998129

                debug_exit(l_proc);
                RETURN FALSE;
            END IF;
        END IF; --g_current_layout = 'PERIODIC' THEN

        IF PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type.exists(g_curr_element_type_id) THEN

            g_curr_element_type_name
                :=  PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(g_curr_element_type_id).element_name;
            --check if non-recurring element
            IF PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(g_curr_element_type_id).processing_type = 'R' THEN
                  debug('ERROR: Recurring element, will not be processed.',30);
                  l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error --Bug fix 5015173
                               (p_error_number        =>    94530
                               ,p_error_text          =>    'BEN_94530_REC_BON_ELEMENT'
                               ,p_token1              =>
                                    pqp_gb_psi_functions.g_elements_of_info_type(g_curr_element_type_id).element_name
                               );
                  debug('Returning FALSE',30);
                  debug_exit(l_proc);
                  RETURN FALSE;
            ELSE
                  debug('Is a non-recurring element',20);
            END IF;

            --check if pensionable bonus
            IF PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(g_curr_element_type_id).eei_information4 <> 'Y' THEN
                  debug('ERROR: Not a Pensionable Bonus, will not be processed.',30);
                  l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94527
                               ,p_error_text          =>    'BEN_94527_NOT_PEN_BONUS'
                               ,p_token1              =>
                                    pqp_gb_psi_functions.g_elements_of_info_type(g_curr_element_type_id).element_name
                               );
                  debug('Returning FALSE',30);
                  debug_exit(l_proc);
                  RETURN FALSE;
            ELSE
                  debug('Is a Pensionable Bonus',20);
            END IF;
        ELSE
            debug('Not a valid element type',20);
            debug('Returning FALSE',20);
            debug_exit(l_proc);
            RETURN FALSE;
        END IF;

        -- check for dupliate bonus types
        chk_dup_bon_types();
        debug('Returning TRUE',10);
        debug_exit(l_proc);
        RETURN TRUE;
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
    END set_curr_row_values;
    ----
    -- ----------------------------------------------------------------------------
    -- |--------------------< bonus_cutover_ext_criteria >----------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION bonus_cutover_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.bonus_cutover_ext_criteria';
        l_include  varchar2(1) :=  'Y';
        l_cutover_date  DATE;
    BEGIN
        debug_enter(l_proc);
        g_current_layout  :=  'CUTOVER';

        debug_enter(l_proc);
        debug('Inputs are: ');
        debug('p_business_group_id: '||p_business_group_id,10);
        debug('p_assignment_id: '||p_assignment_id,10);
        debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);


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
                 ,p_cutover_date      => l_cutover_date
                 ,p_ext_dfn_id        => g_ext_dfn_id
                 );

            g_effective_date  :=  p_effective_date;

            set_bonus_history_globals
                    (
                    p_business_group_id     =>    p_business_group_id
                    ,p_assignment_id        =>    p_assignment_id
                    ,p_effective_date       =>    p_effective_date
                    );

            --Raise extract exceptions which are stored while checking for the setup
            debug('Raising the set-up errors, with input parameter as S',10);
            PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions('S');
        END IF; --IF g_business_group_id IS NULL

        IF l_include <> 'N' THEN

            IF g_assignment_id IS NULL
               OR p_assignment_id <> nvl(g_assignment_id,0) THEN

                -- dummy call to basic criteria to set the globals in common package.
                l_include :=  PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
                      (p_business_group_id        =>  p_business_group_id
                      ,p_effective_date           =>  p_effective_date
                      ,p_assignment_id            =>  p_assignment_id
                      ,p_person_dtl               =>  g_curr_person_dtls
                      ,p_assignment_dtl           =>  g_curr_assg_dtls
                      );
                --l_include is set to 'Y' because basic criteria will be called again for
                --  claim date.
                l_include :=  'Y';

                set_assignment_globals
                      (
                      p_assignment_id         =>    p_assignment_id
                      ,p_effective_date       =>    p_effective_date
                      );
            END IF;

        END IF; --IF l_include <> 'N' THEN

        pqp_gb_psi_functions.g_effective_date :=  p_effective_date;

        debug('l_include: '||l_include);
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
    END bonus_cutover_ext_criteria;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------< bonus_periodic_ext_criteria >----------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION bonus_periodic_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.bonus_periodic_ext_criteria';
        l_include  varchar2(1) :=  'Y';
        l_cutover_date        DATE;
        l_curr_evt_index        NUMBER;

--For BUG 5998129
        l_bon_effective_date DATE;
        l_bon_curr_evt_index NUMBER;
        -- l_first_eff_date BOOLEAN; /* For Bug: 6791275 */


    BEGIN
        debug_enter(l_proc);
        g_current_layout  :=  'PERIODIC';
        g_effective_date := p_effective_date;

--For BUG 5998129
        l_element_of_bonus_type := 'Y';

        debug_enter(l_proc);
        debug('Inputs are: ');
        debug('p_business_group_id: '||p_business_group_id,10);
        debug('p_assignment_id: '||p_assignment_id,10);
        debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);


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
                 ,p_cutover_date      => l_cutover_date
                 ,p_ext_dfn_id        => g_ext_dfn_id
                 );

            set_bonus_history_globals
                    (
                    p_business_group_id     =>    p_business_group_id
                    ,p_assignment_id        =>    p_assignment_id
                    ,p_effective_date       =>    p_effective_date
                    );
            --Raise extract exceptions which are stored while checking for the setup
            debug('Raising the set-up errors, with input parameter as S',10);
            PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions('S');
        END IF; --IF g_business_group_id IS NULL

        IF l_include <> 'N' THEN

            IF g_assignment_id IS NULL
               OR p_assignment_id <> nvl(g_assignment_id,0) THEN

                -- dummy call to basic criteria to set the globals in common package.
                l_include :=  PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
                      (p_business_group_id        =>  p_business_group_id
                      ,p_effective_date           =>  p_effective_date
                      ,p_assignment_id            =>  p_assignment_id
                      ,p_person_dtl               =>  g_curr_person_dtls
                      ,p_assignment_dtl           =>  g_curr_assg_dtls
                      );
                --l_include is set to 'Y' because basic criteria will be called again for
                --  claim date.
                l_include :=  'Y';

--For BUG 5998129

                g_first_eff_date := TRUE; /* For Bug: 6791275 */

                set_assignment_globals
                      (
                      p_assignment_id         =>    p_assignment_id
                      ,p_effective_date       =>    p_effective_date
                      );
--For BUG 5998129
                 -- store in l_bon_curr_evt_index, so that we can restore
                 -- ben_ext_person.g_chg_pay_evt_index with current value later on
                 l_bon_effective_date := NULL;
                 l_bon_curr_evt_index    :=    ben_ext_person.g_chg_pay_evt_index;

                 debug('l_bon_effective_date : '||l_bon_effective_date);
                 debug('total events : '||g_pay_proc_evt_tab.count);
                 debug('l_bon_curr_evt_index : '||l_bon_curr_evt_index);

                  FOR i in l_bon_curr_evt_index..g_pay_proc_evt_tab.count
                  LOOP
                             l_include := pqp_gb_psi_functions.include_event
                                          (p_actual_date => g_pay_proc_evt_tab(i).actual_date
                                          ,p_effective_date => g_pay_proc_evt_tab(i).effective_date
                                          );

                    IF l_include = 'Y' -- AND PQP_GB_PSI_FUNCTIONS.g_min_eff_date_exists = 'Y'
                    THEN

                      -- if retro event was found, store retro date details in globals
                      IF PQP_GB_PSI_FUNCTIONS.g_min_eff_date_exists = 'Y'
                      THEN
                       debug('first retro event found');
                        -- retro event
                        l_bon_effective_date := g_pay_proc_evt_tab(i).effective_date; --p_effective_date;
                        g_first_retro_event  := g_pay_proc_evt_tab(i).effective_date; --p_effective_date;
                        g_first_approved_event := g_pay_proc_evt_tab(i).effective_date; --p_effective_date;

                        l_bon_effective_date := trunc(l_bon_effective_date,'MM');
                        g_first_retro_event_start := l_bon_effective_date;

                       debug('p_effective_date :' ||p_effective_date);

                       debug('first retro event date :' ||g_first_retro_event);
                       debug('first retro event start date :' ||g_first_retro_event_start);

                      ELSE
                        debug('first normal event found ');
                         g_first_approved_event := g_pay_proc_evt_tab(i).effective_date;
                        debug('first normal event date '||g_first_approved_event);

                      END IF;

                      EXIT;

                    END IF;

                     debug('i value :'||i);
                     -- incrementing ben_ext_person.g_chg_pay_evt_index now,
                     -- will be restored after the FOR loop
                     ben_ext_person.g_chg_pay_evt_index := ben_ext_person.g_chg_pay_evt_index + 1;
                  END LOOP;

                 debug('after loop l_bon_effective_date :'||l_bon_effective_date);

                 -- restoring ben_ext_person.g_chg_pay_evt_index
                 ben_ext_person.g_chg_pay_evt_index := l_bon_curr_evt_index;
--END For BUG 5998129
            END IF;

            l_curr_evt_index    :=    ben_ext_person.g_chg_pay_evt_index;
            debug('----------');
            debug('Record :'||l_curr_evt_index);
            debug('----------');
            debug('surrogate_key     :'||g_pay_proc_evt_tab(l_curr_evt_index).surrogate_key    ,20);
            debug('update_type       :'||g_pay_proc_evt_tab(l_curr_evt_index).update_type      ,20);
            debug('effective_date    :'||to_char(g_pay_proc_evt_tab(l_curr_evt_index).effective_date,'DD/MM/YYYY'),20);
            debug('actual_date       :'||to_char(g_pay_proc_evt_tab(l_curr_evt_index).actual_date,'DD/MM/YYYY'),20);
            debug('----------');


--For BUG 5998129
            -- events till first 'Y' have already been evaluated above, when the first event was found
            IF g_first_retro_event IS NOT NULL
            THEN

                -- for use by process_retro_event function
                PQP_GB_PSI_FUNCTIONS.g_min_effective_date(g_assignment_id) := g_first_retro_event_start;

                -- reject all events till start of retro-event-month
                IF (g_pay_proc_evt_tab(l_curr_evt_index).effective_date < g_first_retro_event_start)
                THEN
                  l_include := 'N';
                ELSIF (g_pay_proc_evt_tab(l_curr_evt_index).effective_date <= g_first_retro_event)
                THEN
                  l_include := 'Y';
                ELSE -- include event has to be called here onwards

                  debug('Calling the common include event proc');
                  l_include := pqp_gb_psi_functions.include_event
                               (p_actual_date => g_pay_proc_evt_tab(l_curr_evt_index).actual_date
                               ,p_effective_date => g_pay_proc_evt_tab(l_curr_evt_index).effective_date
                               );
                  debug('include_event returned: '||l_include);
                END IF;

            ELSE -- no retro events, so reject all events till g_first_approved_event

                IF g_first_approved_event IS NULL
                THEN

                  l_include := 'N';

                ELSIF (g_pay_proc_evt_tab(l_curr_evt_index).effective_date < g_first_approved_event)
                THEN

                  l_include := 'N';

                ELSE -- include event has to be called here onwards

                  debug('Calling the common include event proc');
                  l_include := pqp_gb_psi_functions.include_event
                               (p_actual_date => g_pay_proc_evt_tab(l_curr_evt_index).actual_date
                               ,p_effective_date => g_pay_proc_evt_tab(l_curr_evt_index).effective_date
                               );
                  debug('include_event returned: '||l_include);
                END IF;
            END IF;

            -- For first p_effective_date, make the include flag set to 'Y', since
            -- this date might get rejected as curr_event already processed .
            IF g_first_eff_date
            THEN
               -- l_first_eff_date := FALSE; /* For Bug: 6791275 */
               IF g_first_retro_event_start IS NOT NULL
                  OR g_first_approved_event IS NOT NULL
               THEN
                  IF p_effective_date = NVL(g_first_retro_event,g_first_approved_event)
                  THEN
                     l_include := 'Y';
		     g_first_eff_date := FALSE; /* For Bug: 6791275 */
                  END IF;
               END IF;
            END IF;

            --- call set_curr_row_values() for all events only after g_first_retro_event_start
            --- or g_first_approved_event
            IF p_effective_date >= NVL(g_first_retro_event_start,g_first_approved_event)
            THEN
               IF NOT set_curr_row_values()
                  OR l_include = 'N'
               THEN
                  --current event is not accepted
                  l_include := 'N';
               END IF;
            ELSE
               l_include := 'N';
            END IF;
--END For BUG 5998129

        END IF; --IF l_include <> 'N' THEN

        pqp_gb_psi_functions.g_effective_date :=  p_effective_date;

--For BUG 5998129
        debug('l_element_of_bonus_type: '||l_element_of_bonus_type);
        IF g_first_retro_event_start IS NOT NULL
        THEN
          IF l_element_of_bonus_type = 'Y' AND p_effective_date >= g_first_retro_event_start
          THEN
              pqp_gb_psi_functions.process_retro_event(l_include);
           END IF;
         END IF;
--END For BUG 5998129

        debug('l_include: '||l_include);
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
    END bonus_periodic_ext_criteria;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------< bonus_history_data_ele_val >----------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION bonus_history_data_ele_val
                 (
                 p_ext_user_value     IN VARCHAR2
                 ,p_output_value       OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.bonus_history_data_ele_val';
        l_include  NUMBER  :=  0;
        -- ----------------------------------------------------------------------------
        -- |---------------------------< get_effective_date >--------------------------|
        -- Description:
        -- ----------------------------------------------------------------------------
        FUNCTION get_effective_date
                    (
                    p_output_value       OUT NOCOPY VARCHAR2
                    )RETURN NUMBER
        IS
            l_proc varchar2(72) := g_package||'.get_effective_date';
            l_date_char     VARCHAR2(20);
            l_claim_date    DATE;
            l_return        NUMBER;

            CURSOR csr_get_claim_date
            IS
               SELECT  peev.screen_entry_value
              FROM pay_element_entry_values_f peev
                  ,pay_input_values_f piv
              WHERE peev.element_entry_id = g_curr_element_entry_id
              AND peev.input_value_id = piv.input_value_id
              AND UPPER(piv.NAME) = 'CLAIM DATE'
              --AND peev.effective_start_date = p_effective_date
              ORDER BY piv.name;
        BEGIN
            debug_enter(l_proc);

            /*IF g_current_layout = 'CUTOVER' THEN
                p_output_value  :=  to_char(ben_ext_person.g_element_entry_eff_start_date,'dd/mm/yyyy');
            ELSE
                p_output_value  :=  to_char(g_effective_date,'dd/mm/yyyy');
            END IF;*/

            OPEN csr_get_claim_date;
            FETCH csr_get_claim_date INTO l_date_char;
            CLOSE csr_get_claim_date;

            IF l_date_char IS null THEN
                -- raise error - no claim date value
                l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94683
                               ,p_error_text          =>    'BEN_94683_BON_NO_CLM_DT_VAL'
                               ,p_token1              =>
                                    pqp_gb_psi_functions.g_elements_of_info_type(g_curr_element_type_id).element_name
                               ,p_token2              =>    to_char(g_effective_date,'dd/mm/yyyy')
                               );
            ELSE
                --
                l_claim_date  :=  fnd_date.canonical_to_date(l_date_char);
                IF pqp_gb_psi_functions.is_proper_claim_date
                            (l_claim_date
                            ,g_curr_element_type_name
                            ,g_curr_element_entry_id
                            ,g_assg_start_date
                            ) THEN
                     -- is a proper claim date
                     debug('the claim date is proper');
                     p_output_value := to_char(l_claim_date,'dd/mm/yyyy');
                 ELSE
                    debug('the claim date is not proper');
                 END IF;
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
        END get_effective_date;
        ---
        -- ----------------------------------------------------------------------------
        -- |---------------------------< get_bonus_code >--------------------------|
        -- Description:
        -- ----------------------------------------------------------------------------
        FUNCTION get_bonus_code
                    (
                    p_output_value       OUT NOCOPY VARCHAR2
                    )RETURN NUMBER
        IS
            l_proc varchar2(72) := g_package||'.get_bonus_code';
            l_return    NUMBER;
        BEGIN
            debug_enter(l_proc);

            IF PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type.exists(g_curr_element_type_id) THEN
                p_output_value
                    :=  PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(g_curr_element_type_id).eei_information2;
            END IF;

            IF NOT pqp_gb_psi_functions.is_alphanumeric(p_output_value) THEN
                -- Bug Fix 5015236
               debug('ERROR: the bonus code is non-alphanumeric',20);
               l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94557
                               ,p_error_text          =>    'BEN_94557_INVALID_CODE'
                               ,p_token1              =>    'Bonus'
                               ,p_token2              =>
                                    pqp_gb_psi_functions.g_elements_of_info_type(g_curr_element_type_id).element_name
                               ,p_token3              =>    p_output_value
                               );
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
        END get_bonus_code;
        ---
        -- ----------------------------------------------------------------------------
        -- |----------------------------< get_bonus_amount >-----------------------------|
        -- Description:
        -- ----------------------------------------------------------------------------
        FUNCTION get_bonus_amount
                    (
                    p_output_value       OUT NOCOPY VARCHAR2
                    )RETURN NUMBER
        IS
            l_proc varchar2(72) := g_package||'.get_bonus_amount';
            l_include  NUMBER  :=  0;
            l_bonus_amount  NUMBER;
        BEGIN
            debug_enter(l_proc);

            l_bonus_amount    :=  pqp_gb_psi_functions.get_element_payment_balance
                                                (p_assignment_id       =>  g_assignment_id
                                                 ,p_element_entry_id   =>  g_curr_element_entry_id
                                                 ,p_element_type_id    =>  g_curr_element_type_id
                                                 ,p_balance_type_id    =>  g_bon_bal_type_id
                                                 ,p_effective_date     =>  g_effective_date
                                                 );
            /*l_bonus_amount  :=  pqp_gb_psi_functions.get_element_payment
                                            (p_assignment_id          =>  g_assignment_id
                                            ,p_element_entry_id   =>  g_curr_element_entry_id
                                            ,p_element_type_id    =>  g_curr_element_type_id
                                            ,p_effective_date     =>  g_effective_date
                                            );*/
            IF l_bonus_amount IS NULL THEN
                -- raise error that the bonus amount is null and value will not be reported.
                debug('ERROR: No Bonus Amount',20);
                l_include :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                 (p_error_number        =>    94531
                                 ,p_error_text          =>    'BEN_94531_NO_BONUS_AMOUNT'
                                 ,p_token1              =>    g_curr_element_type_name
                                                                 ||'('||g_curr_element_entry_id||')'
                                 ,p_token2              =>    to_char(g_effective_date,'dd/mm/yyyy')
                                 );
            ELSIF NOT ( l_bonus_amount >= -99999999.99 AND l_bonus_amount <= 999999999.99 ) THEN
                -- raise error that the bonus amount is out of range
                -- bug fix 4998232
                debug('ERROR: Bonus Amount out of range: '||l_bonus_amount,20);
                l_include :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                 (p_error_number        =>    94567
                                 ,p_error_text          =>    'BEN_94567_INVALID_BONUS_AMOUNT'
                                 ,p_token1              =>    g_curr_element_type_name
                                                                 ||'('||g_curr_element_entry_id||')'
                                 ,p_token2              =>    to_char(g_effective_date,'dd/mm/yyyy')
                                 ,p_token3              =>    l_bonus_amount
                                 );
               p_output_value :=  l_bonus_amount;
            ELSE
                -- bug fix 5026913.
                IF l_bonus_amount < 0 THEN
                    p_output_value  :=  ltrim(rtrim(to_char(l_bonus_amount,'S09999999D99')));
                ELSE
                    p_output_value  :=  ltrim(rtrim(to_char(l_bonus_amount,'099999999D99')));
                END IF;
            END IF;

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
        END get_bonus_amount;
        ---
        -- ----------------------------------------------------------------------------
        -- |---------------------------< get_ind_flag >--------------------------|
        -- Description:
        -- ----------------------------------------------------------------------------
        FUNCTION get_ind_flag
                    (
                    p_output_value       OUT NOCOPY VARCHAR2
                    )RETURN NUMBER
        IS
            l_proc varchar2(72) := g_package||'.get_ind_flag';
        BEGIN
            debug_enter(l_proc);

            IF PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type.exists(g_curr_element_type_id) THEN
                p_output_value
                    :=  PQP_GB_PSI_FUNCTIONS.g_elements_of_info_type(g_curr_element_type_id).eei_information5;
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
        END get_ind_flag;
        ---
        -- ----------------------------------------------------------------------------
        -- |---------------------------< get_bonus_ee_id >--------------------------|
        -- Description:
        -- ----------------------------------------------------------------------------
        FUNCTION get_bonus_ee_id
                    (
                    p_output_value       OUT NOCOPY VARCHAR2
                    )RETURN NUMBER
        IS
            l_proc varchar2(72) := g_package||'.get_bonus_ee_id';
        BEGIN
            debug_enter(l_proc);

            p_output_value :=  g_curr_element_entry_id;

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
        END get_bonus_ee_id;
        ---
    BEGIN  --bonus_history_data_ele_val
        debug_enter(l_proc);
        debug('p_ext_user_value: '||p_ext_user_value,10);

        IF g_current_layout = 'CUTOVER' THEN
            IF p_ext_user_value = 'BonusEffectiveDate' THEN
              debug('For Cutover run, for effective date element',20);
              IF NOT set_curr_row_values() THEN
                --current event is not accepted
                g_include_current_row :=  FALSE;
                p_output_value  :=  NULL;
                debug('Returning : '||l_include,20);
                debug_exit(l_proc);
                return l_include;
            ELSE
                g_include_current_row :=  TRUE;
            END IF;

          END IF; --IF p_ext_user_value = 'BonusEffectiveDate'
        ELSE
            -- for periodic
            debug('For Periodic run g_include_current_row is always true.',20);
            g_include_current_row :=  TRUE;
        END IF;

        IF g_include_current_row THEN
          debug('g_include_current_row is true.',20);
          IF p_ext_user_value = 'BonusEffectiveDate' THEN
             l_include :=  get_effective_date
                            (
                            p_output_value  =>  p_output_value
                            );
          ELSIF p_ext_user_value = 'BonusCode' THEN
             l_include :=  get_bonus_code
                            (
                            p_output_value  =>  p_output_value
                            );
          ELSIF p_ext_user_value = 'BonusAmount' THEN
             l_include :=  get_bonus_amount
                            (
                            p_output_value  =>  p_output_value
                            );
          ELSIF p_ext_user_value = 'BonusIndFlag' THEN
             l_include :=  get_ind_flag
                            (
                            p_output_value  =>  p_output_value
                            );
          ELSIF p_ext_user_value = 'BonusEEId' THEN
             l_include :=  get_bonus_ee_id
                            (
                            p_output_value  =>  p_output_value
                            );
          END IF; -- IF p_ext_user_value =

        ELSE

            debug('g_include_current_row is true.',20);

        END IF; --IF g_include_current_row THEN

        debug('p_output_value : '||p_output_value,10);
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
    END bonus_history_data_ele_val;
    ---
    -- ----------------------------------------------------------------------------
    -- |----------------------< bonus_history_post_proc >--------------------------|
    --  Description:  This is the post-processing rule  for the BONUS History.
    -- ----------------------------------------------------------------------------
    FUNCTION bonus_history_post_proc RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.bonus_history_post_proc';
    BEGIN
        debug_enter(l_proc);

        --Raise extract exceptions which are stored while processing the data elements
        --PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions();

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
    END bonus_history_post_proc;
    ------
END PQP_GB_PSI_BON_HISTORY;

/
