--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_STH_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_STH_HISTORY" AS
    --  /* $Header: pqpgbpsisth.pkb 120.2.12000000.3 2007/03/01 13:39:44 mseshadr noship $ */
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
    -- ----------------------------------------------------------------------------
    -- |---------------< get_element_type_details >-------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    PROCEDURE get_element_type_details
              (
               p_element_type_id       OUT NOCOPY t_number
               ,p_element_name         OUT NOCOPY t_varchar2
               ,p_processing_type      OUT NOCOPY t_varchar2
               ,p_input_value_id       OUT NOCOPY t_number
               ,p_name                 OUT NOCOPY t_varchar2
               ,p_uom                  OUT NOCOPY t_varchar2
               ,p_unit_of_measure      OUT NOCOPY t_varchar2
              )
    IS
        l_proc varchar2(72) := g_package||'.get_element_type_details';
        l_element_set_ids t_number;
        l_index               NUMBER;
        l_match_exists        VARCHAR2(10);

        TYPE r_element_type_details IS RECORD
              (
              element_type_id       t_number
              ,element_name         t_varchar2
              ,processing_type      t_varchar2
              ,input_value_id       t_number
              ,name                 t_varchar2
              ,uom                  t_varchar2
              ,unit_of_measure      t_varchar2
              );

        l_element_type_details  r_element_type_details;

        CURSOR csr_get_element_set_ids
        IS
              SELECT element_set_id
              FROM pay_event_group_usages pegu
                  ,pay_event_groups peg
              WHERE peg.event_group_name = 'PQP_GB_PSI_STH_ELEMENT_ENTRIES'
              AND peg.legislation_code = 'GB'
              AND peg.business_group_id IS NULL
              AND peg.event_group_id = pegu.event_group_id;

        CURSOR csr_get_element_type_details
                  (
                  p_element_set_id  pay_element_set_members.element_set_id%TYPE
                  )
        IS
            SELECT  pet.element_type_id
                    ,pet.element_name
                    ,pet.processing_type
                    ,piv.input_value_id
                    ,piv.name
                    ,piv.uom
                    ,piv.unit_of_measure
            FROM pay_element_set_members pes
                ,pay_input_values_v piv
                ,pay_element_types_f pet
            WHERE pes.element_set_id = p_element_set_id
            AND pes.element_type_id = pet.element_type_id
            AND pet.element_type_id = piv.element_type_id (+)
            ORDER BY ELEMENT_NAME;

    BEGIN
        debug_enter(l_proc);
        OPEN csr_get_element_set_ids;
        FETCH csr_get_element_set_ids BULK COLLECT INTO l_element_set_ids;
        CLOSE csr_get_element_set_ids;

        IF l_element_set_ids.COUNT > 0 THEN
            debug('No of element sets attached: '||l_element_set_ids.COUNT);
            FOR i IN l_element_set_ids.FIRST..l_element_set_ids.LAST
            LOOP
                debug('l_element_set_ids('||i||'): '||l_element_set_ids(i));
                OPEN csr_get_element_type_details(l_element_set_ids(i));
                FETCH csr_get_element_type_details BULK COLLECT INTO l_element_type_details;
                CLOSE csr_get_element_type_details;

                debug('l_element_type_details.element_type_id.COUNT: '||
                                      l_element_type_details.element_type_id.COUNT);

                FOR i IN 1..l_element_type_details.element_type_id.COUNT LOOP
                  IF p_element_type_id.COUNT = 0 THEN
                    debug('First entry',30);
                    p_element_type_id := l_element_type_details.element_type_id;
                    p_element_name := l_element_type_details.element_name;
                    p_processing_type := l_element_type_details.processing_type;
                    p_input_value_id := l_element_type_details.input_value_id;
                    p_name := l_element_type_details.name;
                    p_uom := l_element_type_details.uom;
                    p_unit_of_measure := l_element_type_details.unit_of_measure;
                    EXIT;
                  ELSE -- count is non zero
                    l_index := p_element_type_id.LAST;
                    l_match_exists := 'N';
                    debug('p_element_type_id.COUNT: '||p_element_type_id.COUNT);
                    FOR j IN 1..p_element_type_id.COUNT LOOP
                      IF p_element_type_id(j) = l_element_type_details.element_type_id(i) AND
                         p_input_value_id(j) = l_element_type_details.input_value_id(i)
                      THEN
                        -- Combination exist so do nothing
                        debug('Element type already exists',40);
                        l_match_exists := 'Y';
                        EXIT;
                      END IF; -- End if of match exists check ...
                    END LOOP; -- j loop

                    debug('Out of j loop');
                    IF l_match_exists = 'N' THEN
                       -- store the information
                       l_index := l_index + 1;
                       p_element_type_id(l_index) := l_element_type_details.element_type_id(i);
                       p_element_name(l_index) := l_element_type_details.element_name(i);
                       p_processing_type(l_index) := l_element_type_details.processing_type(i);
                       p_input_value_id(l_index) := l_element_type_details.input_value_id(i);
                       p_name(l_index) := l_element_type_details.name(i);
                       p_uom(l_index) := l_element_type_details.uom(i);
                       p_unit_of_measure(l_index) := l_element_type_details.unit_of_measure(i);
                    END IF; -- End if of match does not exist ...
                  END IF; -- End if of return collection count is zero check ...
               END LOOP; -- i loop

            END LOOP;

            IF g_debug THEN
              FOR i IN 1..p_element_type_id.COUNT
              LOOP
                  debug('**********ROW : '||i||' *******');
                  debug('element_type_id: '||p_element_type_id(i));
                  debug('element_name: '||p_element_name(i));
                  debug('processing_type: '||p_processing_type(i));
                  debug('input_value_id: '||p_input_value_id(i));
                  debug('name: '||p_name(i));
                  debug('uom: '||p_uom(i));
                  debug('unit_of_measure: '||p_unit_of_measure(i));
                  debug('*******************************');
              END LOOP;
            END IF;-- IF g_debug THEN

        ELSE
            debug('No element set attached');
        END IF; --IF l_element_set_ids.COUNT)  > 0

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
    END get_element_type_details;
    -- ----------------------------------------------------------------------------
    -- |------------------------< chk_valid_elements >----------------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    PROCEDURE chk_valid_elements
    IS
        l_proc varchar2(72) := g_package||'.chk_valid_elements';
        l_claim_date_exists   BOOLEAN;
        l_adj_hours_exists    BOOLEAN;
        l_err_claim_date      BOOLEAN;
        l_err_adj_hours       BOOLEAN;
        l_ele_proc_type       VARCHAR2(1);
        l_index               NUMBER;
        l_prev_ele_type_id    NUMBER;
        l_curr_ele_type_id    NUMBER;
        l_element_type_details  r_element_type_details;
        l_element_name        VARCHAR2(80);
        l_last_ele_proc       BOOLEAN :=  FALSE;

        /*TYPE t_number IS TABLE OF NUMBER
                INDEX BY BINARY_INTEGER;
        TYPE t_varchar2 IS TABLE OF VARCHAR2(80)
                INDEX BY BINARY_INTEGER;
        -- these variable types are declared globally
        */

        l_element_type_ids  t_number;
        l_element_names     t_varchar2;
        l_processing_type   t_varchar2;
        l_input_value_ids   t_number;
        l_input_values      t_varchar2;
        l_unit_of_measure   t_varchar2;
        l_uom_meaning       t_varchar2;

        /*CURSOR csr_get_element_type_details
        IS
            SELECT  pet.element_type_id
                    ,pet.element_name
                    ,pet.processing_type
                    ,piv.name
                    ,piv.uom
                    ,piv.unit_of_measure
            FROM pay_event_groups peg
                ,pay_event_group_usages pegu
                ,pay_element_set_members pes
                ,pay_input_values_v piv
                ,pay_element_types_f pet
            WHERE peg.event_group_name = 'PQP_GB_PSI_STH_ELEMENT_ENTRIES'
            AND peg.event_group_id = pegu.event_group_id
            AND pegu.element_set_id = pes.element_set_id
            AND pes.element_type_id = pet.element_type_id
            AND pet.element_type_id = piv.element_type_id (+)
            ORDER BY ELEMENT_NAME;*/
        -- not using the above cursor after perf fix
        -- this cursor is split into two as in pqp_utilities.entries.effected
        --  and made as a new procedure get_element_type_details

    BEGIN
        debug_enter(l_proc);

        -- clear g_valid_element_type_details
        g_valid_element_type_details.DELETE;

        get_element_type_details
              (
               p_element_type_id       => l_element_type_ids
               ,p_element_name         => l_element_names
               ,p_processing_type      => l_processing_type
               ,p_input_value_id       => l_input_value_ids
               ,p_name                 => l_input_values
               ,p_uom                  => l_unit_of_measure
               ,p_unit_of_measure      => l_uom_meaning
              );

        debug('l_element_type_ids.count: '||l_element_type_ids.count);

        IF l_element_type_ids.COUNT > 0 THEN

            l_claim_date_exists :=  FALSE;
            l_adj_hours_exists  :=  FALSE;
            l_err_claim_date    :=  FALSE;
            l_err_adj_hours     :=  FALSE;
            l_index := l_element_type_ids.FIRST;
            l_prev_ele_type_id  :=  l_element_type_ids(l_index);


            LOOP
                l_curr_ele_type_id  :=  l_element_type_ids(l_index);
                IF g_debug THEN
                      debug('---------------------');
                      debug('Record: '||l_index);
                      debug('l_curr_ele_type_id: '||l_curr_ele_type_id,20);
                      debug('l_prev_ele_type_id: '||l_prev_ele_type_id,20);

                      IF l_claim_date_exists THEN
                          debug('l_claim_date_exists: TRUE',20);
                      ELSE
                          debug('l_claim_date_exists: FALSE',20);
                      END IF;
                      IF l_adj_hours_exists THEN
                          debug('l_adj_hours_exists: TRUE',20);
                      ELSE
                          debug('l_adj_hours_exists: FALSE',20);
                      END IF;
                      IF l_err_claim_date THEN
                          debug('l_err_claim_date: TRUE',20);
                      ELSE
                          debug('l_err_claim_date: FALSE',20);
                      END IF;
                      IF l_err_adj_hours THEN
                          debug('l_err_adj_hours: TRUE',20);
                      ELSE
                          debug('l_err_adj_hours: FALSE',20);
                      END IF;
                END IF;


                IF l_curr_ele_type_id <> l_prev_ele_type_id
                    OR (l_index = l_element_type_ids.LAST
                        AND l_last_ele_proc) THEN
                    -- new element type being processed
                    IF l_prev_ele_type_id = l_curr_ele_type_id
                        AND l_index = l_element_type_ids.LAST THEN
                        l_element_name  :=  l_element_names(l_index);
                        l_ele_proc_type :=  l_processing_type(l_index);
                    ELSE
                        l_element_name  :=  l_element_names(l_index-1);
                        l_ele_proc_type :=  l_processing_type(l_index-1);
                    END IF;

                    IF NOT l_claim_date_exists
                        AND ( g_current_layout = 'SINGLE'
                              OR
                              nvl(g_adj_hrs_source,' ') <> 'BALANCE'
                             )
                        THEN -- check only for single records
                              --  need not check for Accumulated records
                              --  if it uses balance type for adjusted hours
                              --  bug abcedfg

                          -- raise error that the element type has no claim date
                          debug('ERROR: No Claim Date for element type: '||l_element_names(l_index),40);
                          PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                                       (p_extract_type        =>    'SHORT-TIME HOURS HISTORY'
                                       ,p_error_number        =>    94502
                                       ,p_error_text          =>    'BEN_94502_NO_CLAIM_DATE_IV'
                                       ,p_token1              =>    l_element_name
                                       ,p_error_warning_flag  =>    'E'
                                       );
                    END IF;--IF NOT l_claim_date_exists THEN

                  --  IF NOT l_adj_hours_exists THEN
                  --5549469 l_adj_hours_exists not to be checked in
                  --balance mode
                    IF NOT l_adj_hours_exists
                       AND ( g_current_layout = 'SINGLE'
                             OR
                             nvl(g_adj_hrs_source,' ') <> 'BALANCE' )
                       THEN
                          -- raise error that the element type has no adjusted hours
                          debug('ERROR: No Adjusted Hours for element type: '||l_element_names(l_index),40);
                          PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                                       (p_extract_type        =>    'SHORT-TIME HOURS HISTORY'
                                       ,p_error_number        =>    94503
                                       ,p_error_text          =>    'BEN_94503_NO_ADJ_HOURS_IV'
                                       ,p_token1              =>    l_element_name
                                       ,p_error_warning_flag  =>    'E'
                                       );
                    END IF;--IF NOT l_adj_hours_exists THEN

                    IF (l_claim_date_exists
                       OR
                          NOT l_claim_date_exists AND nvl(g_adj_hrs_source,' ') = 'BALANCE'
                       )
                      AND (
                           l_adj_hours_exists --5902824
                            OR
                            ( NOT l_adj_hours_exists
                              AND nvl(g_adj_hrs_source,' ')='BALANCE'
                            )
                           )

                      AND NOT (l_err_claim_date OR l_err_adj_hours)
                      AND l_ele_proc_type =  'N' THEN -- only non-recurrign elements wil be added

                        debug('Element Type '||l_element_name||' Qualifies initial check',40);
                        IF l_prev_ele_type_id = l_curr_ele_type_id
                            AND l_index = l_element_type_ids.LAST THEN
                            debug('Finished processing',50);
                            g_valid_element_type_details(l_prev_ele_type_id).element_type_name
                                  :=  l_element_names(l_index);
                            EXIT;
                        END IF;
                        l_index :=  l_index - 1;
                        g_valid_element_type_details(l_prev_ele_type_id).element_type_name
                            :=  l_element_names(l_index);
                    ELSE
                        debug('Element Type '||l_element_name||' does NOT Qualify initial check',40);
                        IF l_ele_proc_type =  'R' THEN
                            debug('WARNING: Element Type '||l_element_name||' is recurring element');
                            PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                                       (p_extract_type        =>    'SHORT-TIME HOURS HISTORY'
                                       ,p_error_number        =>    94529
                                       ,p_error_text          =>    'BEN_94529_REC_STH_ELEMENT'
                                       ,p_token1              =>    l_element_name
                                       ,p_error_warning_flag  =>    'W'
                                       );
                        END IF;
                        IF l_prev_ele_type_id = l_curr_ele_type_id
                            AND l_index = l_element_type_ids.LAST THEN
                            debug('Finished processing',50);
                            EXIT;
                        END IF;
                        l_index :=  l_index - 1;
                    END IF;--IF l_claim_date_exists AND l_adj_hours_exists

                    l_prev_ele_type_id  :=  l_curr_ele_type_id;

                    -- reset values
                    l_claim_date_exists :=  FALSE;
                    l_adj_hours_exists  :=  FALSE;
                    l_err_claim_date    :=  FALSE;
                    l_err_adj_hours     :=  FALSE;
                    l_curr_ele_type_id  :=  l_element_type_ids(l_index);
                    debug('Start Processing new element type');

                ELSE --IF l_curr_ele_type_id <> l_prev_ele_type_id
                    -- for same element type
                    IF UPPER(l_input_values(l_index)) = 'CLAIM DATE'
                       AND ( g_current_layout = 'SINGLE'
                            OR
                             nvl(g_adj_hrs_source,' ') <> 'BALANCE'
                           )
                       THEN -- check only for single records
                            --  need not check for Accumulated records
                            --  if it uses balance type for adjusted hours
                            --  bug abcedfg

                            IF l_unit_of_measure(l_index) = 'D' THEN
                                -- valid data type for claim date
                                debug('valid data type for claim date',30);
                                l_claim_date_exists :=  TRUE;
                                l_err_claim_date    :=  FALSE;
                            ELSE
                                l_claim_date_exists :=  TRUE;
                                -- error on the data type of the claim date
                                l_err_claim_date    :=  TRUE;
                                debug('ERROR: Invalid Claim Date for element type: '||l_element_names(l_index),30);
                                PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                                             (p_extract_type        =>    'SHORT-TIME HOURS HISTORY'
                                             ,p_error_number        =>    94504
                                             ,p_error_text          =>    'BEN_94504_ERR_CLAIM_DATE_IV'
                                             ,p_token1              =>    l_element_names(l_index)
                                             ,p_token2              =>    l_uom_meaning(l_index)
                                             ,p_error_warning_flag  =>    'E'
                                             );
                            END IF;--IF l_unit_of_measure(l_index) = 'D'

                    END IF;--IF UPPER(l_input_values(l_index)) = 'CLAIM DATE'

                    --5549469
                    IF UPPER(l_input_values(l_index)) = 'ADJUSTED HOURS'
                       AND ( g_current_layout = 'SINGLE'
                            OR
                             nvl(g_adj_hrs_source,' ') <> 'BALANCE'
                           )
                       THEN
                            IF l_unit_of_measure(l_index)
                                          IN  ('H_DECIMAL1'
                                              ,'H_DECIMAL2'
                                              ,'H_DECIMAL3'
                                              ,'H_HH'
                                              ,'H_HHMM'
                                              ,'H_HHMMSS'
                                              ,'N') THEN
                                debug('valid data type for adjusted hours',30);
                                l_adj_hours_exists :=  TRUE;
                                l_err_adj_hours    :=  FALSE;

                            ELSE
                                l_adj_hours_exists :=  TRUE;
                                -- error on the data type of the claim date
                                l_err_adj_hours    :=  TRUE;
                                debug('ERROR: Invalid Adjusted Hours for element type: '||l_element_names(l_index),30);
                                PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                                             (p_extract_type        =>    'SHORT-TIME HOURS HISTORY'
                                             ,p_error_number        =>    94505
                                             ,p_error_text          =>    'BEN_94505_ERR_ADJ_HOURS_IV'
                                             ,p_token1              =>    l_element_names(l_index)
                                             ,p_token2              =>    l_uom_meaning(l_index)
                                             ,p_error_warning_flag  =>    'E'
                                             );
                            END IF;--IF l_unit_of_measure(l_index)

                    END IF;--IF UPPER(l_input_values(l_index)) = 'ADJUSTED HOURS'

                    IF l_index = l_element_type_ids.LAST THEN
                        l_index := l_index - 1;
                        l_last_ele_proc :=  true;
                    END IF;

                END IF;--IF l_curr_ele_type_id <> l_prev_ele_type_id THEN


                -- loop condition
                IF l_index = l_element_type_ids.LAST THEN
                    debug('Finished processing',30);
                    EXIT;
                ELSE
                    l_index :=  l_index+1;
                END IF;

            END LOOP;

        END IF; --IF l_element_type_ids.COUNT > 0

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
    END chk_valid_elements;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------< get_adj_hrs_conf_values >-------------------|
    -- Description: This procedure will be called only for Accumulated records.
    --                This is used to fetch the configuration value for the
    --                Adjusted Hours.
    -- ----------------------------------------------------------------------------
    PROCEDURE get_adj_hrs_conf_values
    IS
        l_proc varchar2(72) := g_package||'.get_adj_hrs_conf_values';
        l_config_values   PQP_UTILITIES.t_config_values;
    BEGIN
        debug_enter(l_proc);
        -- fetch the adj hrs source configuration values
        PQP_UTILITIES.get_config_type_values(
                     p_configuration_type   =>    'PQP_GB_PENSERVER_STH_ADJHR_MAP'
                    ,p_business_group_id    =>    g_business_group_id
                    ,p_legislation_code     =>    g_legislation_code
                    ,p_tab_config_values    =>    l_config_values
                  );
        IF l_config_values.COUNT > 0 THEN
            debug('Configration value exists',20);

            g_adj_hrs_source    :=  l_config_values(l_config_values.FIRST).pcv_information1;
            g_adj_hrs_bal_type  :=  l_config_values(l_config_values.FIRST).pcv_information2;

            debug('g_adj_hrs_source: '||g_adj_hrs_source,20);
            debug('g_adj_hrs_bal_type: '||g_adj_hrs_bal_type,20);

            IF g_adj_hrs_source = 'BALANCE'
                AND g_adj_hrs_bal_type  IS NULL THEN
                debug('ERROR: No value provided for balance type.',30);
                PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                               (p_extract_type        =>    'SHORT-TIME HOURS HISTORY'
                               ,p_error_number        =>    94632
                               ,p_error_text          =>    'BEN_94632_NO_ADJ_HRS_BAL_TYPE'
                               ,p_error_warning_flag  =>    'E'
                               );
            END IF;
        ELSE
            debug('Configration value is nto present',20);
            -- raise error
            PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                               (p_extract_type        =>    'SHORT-TIME HOURS HISTORY'
                               ,p_error_number        =>    94633
                               ,p_error_text          =>    'BEN_94633_NO_ADJ_HRS_CONFIG'
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
    END get_adj_hrs_conf_values;
    --------------
    -- ----------------------------------------------------------------------------
    -- |---------------< get_curr_val_from_bal >-------------------|
    -- Description: This procedure will be called only for Accumulated records.
    --                This is used to fetch the configuration value for the
    --                Adjusted Hours.
    -- ----------------------------------------------------------------------------
    PROCEDURE get_curr_val_from_bal
    IS
        l_proc varchar2(72) := g_package||'.get_curr_val_from_bal';
        l_adjusted_hours   NUMBER;
        l_start_date  DATE;
        l_end_date    DATE;
        CURSOR csr_ele_entry_dates
        IS
            SELECT effective_start_date,
                  effective_end_date
            FROM PAY_ELEMENT_ENTRIES_F
            WHERE element_entry_id = g_curr_element_entry_id;

    BEGIN
        debug_enter(l_proc);

        OPEN csr_ele_entry_dates;
        FETCH csr_ele_entry_dates INTO l_start_date, l_end_date;
        CLOSE csr_ele_entry_dates;

        l_adjusted_hours := hr_gbbal.calc_asg_proc_ptd_date
                                       (p_assignment_id   => g_assignment_id
                                       ,p_balance_type_id => g_adj_hrs_bal_type
                                       ,p_effective_date  => l_end_date
                                       );
        debug('l_start_date: '||l_start_date,10);
        debug('l_end_date: '||l_end_date,10);
        debug('l_adjusted_hours: '||l_adjusted_hours,10);

        IF g_start_date IS NULL THEN
            --first row
            debug('First row reported');
            g_start_date  :=  l_start_date;
            g_end_date    :=  l_end_date;
            g_adjusted_hours  :=  l_adjusted_hours;
        ELSE
            -- next rows
           debug('Not the first row reported');
           g_end_date     :=  l_end_date;
           g_adjusted_hours :=  g_adjusted_hours  + l_adjusted_hours;
        END IF;

        debug('g_start_date: '||g_start_date,10);
        debug('g_end_date: '||g_end_date,10);
        debug('g_adjusted_hours: '||g_adjusted_hours,10);

        debug('Marking that the current pay period is processed',10);
        g_reported_pay_periods(fnd_number.canonical_to_number(TO_CHAR(l_start_date,'ddmmyyyy')))  :=  'Y';

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
    END get_curr_val_from_bal;
    --------------
    -- ----------------------------------------------------------------------------
    -- |---------------< set_short_time_hours_globals >-------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    PROCEDURE set_short_time_hours_globals
              (
              p_business_group_id     IN NUMBER
              ,p_assignment_id        IN NUMBER
              ,p_effective_date       IN DATE
              )
    IS
        l_proc varchar2(72) := g_package||'.set_short_time_hours_globals';
    BEGIN
        debug_enter(l_proc);
        -- set global business group id
        g_business_group_id := p_business_group_id;
        g_valid_element_type_details.DELETE;
        g_legislation_code  :=  'GB';

        -- fetch the adjusted hours cofiguration value for accumulated records
        IF g_current_layout = 'ACCUMULATED' THEN
          debug('Fetch the adj hrs config values for accumulated records',20);
          get_adj_hrs_conf_values();
        END IF;

        --check for the element types, thier input values and thier data types.
        chk_valid_elements();


        debug('g_legislation_code: '||g_legislation_code,10);
        debug('g_business_group_id: '||g_business_group_id,10);
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
    END set_short_time_hours_globals;
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

        -- reset assignment level globals
        g_start_date  := NULL;
        g_end_date    := NULL;
        g_effective_date  :=  NULL;
        g_adjusted_hours  :=  NULL;
        g_proc_ele_entries.DELETE;
        g_reported_claim_dates.DELETE;
        g_reported_pay_periods.DELETE;

        -- set the global events table
        g_pay_proc_evt_tab  :=  ben_ext_person.g_pay_proc_evt_tab;

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
    -- |-----------------------< is_proper_adj_hours >--------------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION is_proper_adj_hours
                (
                p_adj_hours     IN NUMBER
                ,p_element_name IN VARCHAR2
                ,p_element_entry_id IN NUMBER
                )RETURN BOOLEAN
    IS
        l_proc varchar2(72) := g_package||'.is_proper_adj_hours';
        l_temp    NUMBER;
        l_return  BOOLEAN :=  TRUE;
    BEGIN -- is_future_claim
        debug_enter(l_proc);
        debug('Inputs are: ',10);
        debug('p_adj_hours: '||p_adj_hours,10);

        IF round(p_adj_hours,2) > +99999999.99 OR p_adj_hours < -99999999.99 THEN
            -- raise ERROR
            debug('ERROR: Adjusted hours is not in the range of -99999999.99 to +99999999.99',30);
            l_temp :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94538
                               ,p_error_text          =>    'BEN_94538_INV_ADJ_HOURS'
                               ,p_token1              =>    SUBSTR(p_element_name
                                                              ||'('||p_element_entry_id||')',1,80)
                               ,p_token2              =>    p_adj_hours
                               );
            l_return  :=  FALSE;
            debug('Returning FALSE.',20);
        END IF;

        debug_exit(l_proc);
        RETURN l_return;
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
    END is_proper_adj_hours;
    ---
    -- ----------------------------------------------------------------------------
    -- |-----------------------< chk_part_timer >--------------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    PROCEDURE chk_part_timer
                (
                p_claim_date        IN DATE
                )
    IS
        l_proc varchar2(72) := g_package||'.chk_part_timer';
        l_fte_value NUMBER;
        l_return    NUMBER;
        CURSOR csr_get_fte_value
        IS
          SELECT value
          FROM PER_ASSIGNMENT_BUDGET_VALUES_F
          WHERE assignment_id = g_assignment_id
          AND UNIT = 'FTE'
          AND p_claim_date between effective_start_date
                          AND effective_end_date;
    BEGIN -- is_future_claim
        debug_enter(l_proc);
        debug('Inputs are: ',10);
        debug('p_claim_date: '||p_claim_date,10);

        OPEN csr_get_fte_value;
        FETCH csr_get_fte_value INTO l_fte_value;
        CLOSE csr_get_fte_value;

        IF l_fte_value IS NULL THEN
            debug('WARNING: No FTE Value');
            l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                                 (p_error_number        =>    94515
                                 ,p_error_text          =>    'BEN_94515_NO_FTE_VALUE'
                                 ,p_token1              =>    to_char(p_claim_date,'dd/mm/yyyy')
                                 ,p_token2              =>    SUBSTR(g_curr_element_type_name
                                                                 ||'('||ben_ext_person.g_chg_surrogate_key||')',1,80)
                                 );

        ElSIF l_fte_value >= 1 THEN
            debug('WARNING: Full Timer');
            l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                                 (p_error_number        =>    94516
                                 ,p_error_text          =>    'BEN_94516_STH_FULL_TIMER'
                                 ,p_token1              =>    to_char(p_claim_date,'dd/mm/yyyy')
                                 ,p_token2              =>    SUBSTR(g_curr_element_type_name
                                                                 ||'('||ben_ext_person.g_chg_surrogate_key||')',1,80)
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
    END chk_part_timer;
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
        l_input_value_name          VARCHAR2(30);
        l_adj_hours                 VARCHAR2(60);
        l_adj_hours_num             NUMBER;
        l_claim_date                VARCHAR2(20);
        l_claim_date_dt             DATE;
        l_claim_date_no   NUMBER;
        l_return          NUMBER;

        CURSOR csr_curr_element_input_values
                  (
                  p_element_entry_id  pay_element_entries_f.element_entry_id%TYPE
                  ,p_effective_date   DATE
                  )
        IS
            SELECT  piv.NAME
                   ,peev.screen_entry_value
            FROM pay_element_entry_values_f peev
                ,pay_input_values_f piv
            WHERE peev.element_entry_id = p_element_entry_id
            AND peev.input_value_id = piv.input_value_id
            AND UPPER(piv.NAME) IN ('CLAIM DATE','ADJUSTED HOURS')
            --AND peev.effective_start_date = p_effective_date
            ORDER BY piv.name;

        CURSOR  csr_get_element_type_details
                    (
                    p_element_entry_id    NUMBER
                    )
        IS
            SELECT peef.element_type_id
                   ,pet.element_name
            FROM pay_element_entries_f peef
                 ,pay_element_types_f pet
            WHERE peef.element_entry_id = p_element_entry_id
            AND pet.element_type_id = peef.element_type_id;

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
        l_chg_table         :=  ben_ext_person.g_chg_pay_table;
        l_chg_type          :=  ben_ext_person.g_chg_update_type;
        l_chg_surrogate_key :=  ben_ext_person.g_chg_surrogate_key;
        l_chg_date          :=  ben_ext_person.g_chg_eff_dt;
        debug('l_chg_table: '||l_chg_table,10);
        debug('l_chg_type: '||l_chg_type,10);
        debug('l_chg_surrogate_key: '||l_chg_surrogate_key,10);
        debug('l_chg_date: '||l_chg_date,10);

        IF l_chg_table  <> 'PAY_ELEMENT_ENTRIES_F'
            AND (l_chg_type  NOT IN ('I','C') ) THEN

            debug('Not a valid event, will not be processed',20);
            debug_exit(l_proc);
            RETURN FALSE;

        END IF;

        g_curr_element_entry_id :=  fnd_number.canonical_to_number(l_chg_surrogate_key);

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

        IF g_proc_ele_entries.exists(g_curr_element_entry_id)  THEN
            debug('The element entry is already processed.',20);
            debug_exit(l_proc);
            RETURN FALSE;
        ELSE
            g_proc_ele_entries(g_curr_element_entry_id) := 'Y';
        END IF;

        IF nvl(g_adj_hrs_source,' ') <> 'BALANCE' THEN
            -- this is for Single records or for Accumulated records
            -- and the adj hrs source is element entries.
            OPEN csr_get_element_type_details(g_curr_element_entry_id);
            FETCH csr_get_element_type_details INTO g_curr_element_type_id, g_curr_element_type_name;
            CLOSE csr_get_element_type_details;

            IF NOT g_valid_element_type_details.EXISTS(g_curr_element_type_id) THEN
                debug('Not a valid element type, will not be processed',20);
                debug_exit(l_proc);
                RETURN FALSE;
            END IF;

            OPEN csr_curr_element_input_values
                      (
                      p_element_entry_id  =>  g_curr_element_entry_id
                      ,p_effective_date   =>  l_chg_date
                      );
            FETCH csr_curr_element_input_values INTO l_input_value_name,l_adj_hours;
            debug('After first fetch',10);

            IF csr_curr_element_input_values%FOUND THEN
                IF UPPER(l_input_value_name) = 'ADJUSTED HOURS' THEN
                    debug('l_input_value_name: '||l_input_value_name
                                ||'  l_adj_hours: '||l_adj_hours,20);
                    debug('Input value is Accumulated Hours',20);


                    FETCH csr_curr_element_input_values INTO l_input_value_name,l_claim_date;
                    debug('After second fetch',20);

                    IF csr_curr_element_input_values%FOUND THEN
                          -- if second fetch got some value, it will be for
                          --    claim date
                          debug('l_input_value_name: '||l_input_value_name
                                    ||'  l_claim_date: '||l_claim_date,30);

                    ELSIF g_current_layout = 'SINGLE' THEN

                          debug('No Claim Date',30);
                          g_effective_date  :=  NULL;

                    END IF; --IF csr_curr_element_input_values%FOUND

                ELSE -- first input value is Claim Date

                    -- this means that there is no adjusted hours for this element
                    IF g_current_layout = 'SINGLE' THEN

                          debug('No Adjusted Hours input value for this element',40);
                          g_adjusted_hours  :=  NULL;

                    END IF;

                    debug('Input value is Claim Date',30);
                    l_claim_date  :=  l_adj_hours;

                END IF; --IF UPPER(l_input_value_name) = 'ADJUSTED HOURS'


            ELSIF g_current_layout = 'SINGLE' THEN
                g_effective_date  :=  NULL;
                g_adjusted_hours  :=  NULL;
            END IF; --IF csr_curr_element_input_values%FOUND

            IF l_claim_date IS NOT NULL THEN
                  debug('Claim Date is not null',20);
                  l_claim_date_dt :=  fnd_date.canonical_to_date(l_claim_date);
                  l_claim_date_no :=  fnd_number.canonical_to_number(TO_CHAR(l_claim_date_dt,'ddmmyyyy'));



                  IF pqp_gb_psi_functions.is_proper_claim_date(l_claim_date_dt
                                                              ,g_curr_element_type_name
                                                              ,g_curr_element_entry_id
                                                              ,g_assg_start_date) THEN

                      IF NOT g_reported_claim_dates.EXISTS(l_claim_date_no) THEN
                          debug('The Claim date is NOT reported',30);
                          g_reported_claim_dates(l_claim_date_no)
                                          :=  g_curr_element_type_name||'('||g_curr_element_entry_id||')';

                          -- check whether the assignment is ful-time on the claim date or else raise a warning.
                          chk_part_timer(l_claim_date_dt);

                          IF g_current_layout = 'SINGLE' THEN
                                debug('assign the claim date to g_effective_date for SINGLE records',40);
                                g_effective_date  :=  l_claim_date_dt;
                                debug('g_effective_date: '||g_effective_date);
                          ELSE  -- ACCUMULATED Records
                                IF NVL(g_start_date,hr_api.g_eot) > l_claim_date_dt THEN
                                    debug(l_claim_date_dt||' is less than '||g_start_date,50);
                                    g_start_date  :=  l_claim_date_dt;
                                END IF;
                                IF NVL(g_end_date,hr_api.g_sot) < l_claim_date_dt THEN
                                    debug(l_claim_date_dt||' is greater than '||g_end_date,50);
                                    g_end_date  :=  l_claim_date_dt;
                                END IF;
                                debug('g_start_date: '||g_start_date,40);
                                debug('g_end_date:  '||g_end_date,40);
                          END IF;--IF g_current_layout = 'SINGLE'
                       ELSE
                          debug('ERROR: the claim date is already reported by element entry id: '
                                    ||g_reported_claim_dates(l_claim_date_no));
                          l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                             (p_error_number        =>    94514
                                             ,p_error_text          =>    'BEN_94514_DUP_CLAIM_DATE'
                                             ,p_token1              =>    to_date(l_claim_date_dt,'dd/mm/yyyy')
                                             ,p_token2              =>    SUBSTR(g_curr_element_type_name
                                                                            ||'('||ben_ext_person.g_chg_surrogate_key||')',1,80)
                                             ,p_token3              =>    g_reported_claim_dates(l_claim_date_no)
                                             );
                          debug('Returning : FALSE',30);
                          debug_exit(l_proc);
                          return FALSE;
                      END IF;--IF NOT g_reported_claim_dates.EXISTS(l_claim_date_no)
                  ELSE
                      -- the claim date is not proper
                      debug('Returning : FALSE',20);
                      debug_exit(l_proc);
                      return FALSE;
                  END IF;--IF is_proper_claim_date(l_claim_date)
            ELSIF g_current_layout = 'SINGLE' THEN
                  debug('No Claim Date');
                  g_effective_date  :=  NULL;
            END IF; --IF l_claim_date IS NOT NULL

            debug('g_adjusted_hours: '||g_adjusted_hours,10);

            l_adj_hours_num  :=  fnd_number.canonical_to_number(l_adj_hours);

            debug('l_adj_hours_num: '||l_adj_hours_num);

            IF l_adj_hours IS NOT NULL
              AND is_proper_adj_hours(l_adj_hours_num,g_curr_element_type_name,g_curr_element_entry_id) THEN

                debug('adjusted hours is proper and is not null',30);
                IF g_current_layout = 'ACCUMULATED'  THEN
                    g_adjusted_hours  :=  NVL(g_adjusted_hours,0)
                                                +
                                          l_adj_hours_num;
                ELSIF g_current_layout = 'SINGLE' THEN
                    g_adjusted_hours  :=  l_adj_hours_num;
                END IF; --IF g_current_layout = 'ACCUMULATED'

            END IF;--IF l_adj_hours IS NOT NULL

            debug('g_adjusted_hours: '||g_adjusted_hours,10);

        ELSE
            -- balance approach for accumulated records
            get_curr_val_from_bal();

        END IF; -- IF nvl(g_adj_hrs_source,' ') = 'BALANCE'
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
    -- |--------------------< short_time_hours_criteria >----------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.short_time_hours_criteria';
        l_include         VARCHAR2(1) :=  'Y';
        l_cutover_date    DATE;
        l_curr_evt_index  NUMBER;

    BEGIN
        debug_enter(l_proc);
        debug('Inputs are: ');
        debug('p_business_group_id: '||p_business_group_id,10);
        debug('p_assignment_id: '||p_assignment_id,10);
        debug('p_effective_date: '||to_char(p_effective_date,'dd/mm/yyyy'),10);


        IF g_business_group_id IS NULL
           OR p_business_group_id <> nvl(g_business_group_id,0) THEN

            g_business_group_id :=  p_business_group_id;

            PQP_GB_PSI_FUNCTIONS.set_shared_globals
                 (p_business_group_id => p_business_group_id
                 ,p_paypoint          => g_paypoint
                 ,p_cutover_date      => l_cutover_date
                 ,p_ext_dfn_id        => g_ext_dfn_id
                 );

            set_short_time_hours_globals
                    (
                    p_business_group_id     =>    p_business_group_id
                    ,p_assignment_id        =>    p_assignment_id
                    ,p_effective_date       =>    p_effective_date
                    );

             IF g_valid_element_type_details.COUNT > 0 THEN
                debug('Count of valid elements: '||g_valid_element_type_details.COUNT,20);
             ELSE
                --raise error saying that there are no valid elements
                debug('ERROR: No Valid Elements',30);
                PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                             (p_extract_type        =>    'SHORT-TIME HOURS HISTORY'
                             ,p_error_number        =>    94506
                             ,p_error_text          =>    'BEN_94506_NO_VALID_STH_ELEMENT'
                             ,p_error_warning_flag  =>    'E'
                             );
                l_include  :=  'N';

            END IF;--IF g_valid_element_type_details.COUNT > 0


            --Raise extract exceptions which are stored while checking for the setup
            debug('Raising the set-up errors, with input parameter as S',10);
            PQP_GB_PSI_FUNCTIONS.raise_extract_exceptions('S');
        END IF; --IF g_business_group_id IS NULL

        IF l_include = 'N' THEN
            debug('Returning : '||l_include,20);
            debug_exit(l_proc);
            return l_include;
        END IF; --IF l_include = 'N'


        IF (g_assignment_id IS NULL
           OR p_assignment_id <> nvl(g_assignment_id,0) )
           OR nvl(g_adj_hrs_source,' ') = 'BALANCE' THEN

            -- if adj hrs source is balance or fro a new assignment
            l_include :=  PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
                          (p_business_group_id        =>  p_business_group_id
                          ,p_effective_date           =>  p_effective_date
                          ,p_assignment_id            =>  p_assignment_id
                          ,p_person_dtl               =>  g_curr_person_dtls
                          ,p_assignment_dtl           =>  g_curr_assg_dtls
                          );

            IF nvl(g_adj_hrs_source,' ') <> 'BALANCE' THEN
                -- if the adj hrs source is not balance, then calle to
                --  basic criteria is a dummy one.
                l_include :=  'Y';
            END IF;

            IF l_include = 'N'
              AND nvl(g_adj_hrs_source,' ') = 'BALANCE' THEN

                -- reject the event if not valid on effective date
                --  only if the adj hrs source is balance type.
                --  if adj hrs source is element entries, basic criteria
                --  will be validated on the claim date.
                debug('Returning : '||l_include,30);
                debug_exit(l_proc);
                return l_include;

            END IF; --IF l_include = 'N'

            IF (g_assignment_id IS NULL
              OR p_assignment_id <> nvl(g_assignment_id,0) )  THEN

                -- for every new assignment
                set_assignment_globals
                      (
                      p_assignment_id         =>    p_assignment_id
                      ,p_effective_date       =>    p_effective_date
                      );
            END IF;
        END IF;

        -- bug fix 5365237
        IF nvl(g_adj_hrs_source,' ') = 'BALANCE'
            AND g_reported_pay_periods.EXISTS(fnd_number.canonical_to_number
                                                (
                                                TO_CHAR(ben_ext_person.g_chg_eff_dt,'ddmmyyyy')
                                                )
                                             )THEN
            -- if the current pay period is already reported.
            debug('Current pay period starting on :'||ben_ext_person.g_chg_eff_dt||' is already processed');
            l_include :=  'N';
            debug('Returning : '||l_include,20);
            debug_exit(l_proc);
            return l_include;
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

        debug('Calling the common include event proc');
        l_include := pqp_gb_psi_functions.include_event
                     (p_actual_date => g_pay_proc_evt_tab(l_curr_evt_index).actual_date
                     ,p_effective_date => g_pay_proc_evt_tab(l_curr_evt_index).effective_date
                     ,p_run_from_cutover_date =>  'Y'  ---- Bugfix 4969368
                     );
        debug('include_event returned: '||l_include);

        IF l_include = 'N'
        OR NOT set_curr_row_values() THEN
            --current event is not accepted
            l_include := 'N';
        END IF;

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
    END short_time_hours_criteria;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------< short_time_hours_sin_criteria >----------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_sin_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.short_time_hours_sin_criteria';
        l_return  varchar2(1) :=  'Y';
    BEGIN
        debug_enter(l_proc);
        g_current_layout  :=  'SINGLE';

        IF g_business_group_id IS NULL
           OR p_business_group_id <> nvl(g_business_group_id,0) THEN

            -- set the global debug value
            g_debug :=  pqp_gb_psi_functions.check_debug(p_business_group_id);
            debug_enter(l_proc);
        END IF;
        l_return  :=  short_time_hours_criteria
                          (
                          p_business_group_id      =>    p_business_group_id
                          ,p_assignment_id         =>    p_assignment_id
                          ,p_effective_date        =>    p_effective_date
                          );

        debug('l_return: '||l_return);
        debug_exit(l_proc);
        RETURN l_return;
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
    END short_time_hours_sin_criteria;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------< short_time_hours_acc_criteria >----------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_acc_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.short_time_hours_acc_criteria';
        l_return  varchar2(1) :=  'Y';
    BEGIN
        debug_enter(l_proc);
        g_current_layout  :=  'ACCUMULATED';

        IF g_business_group_id IS NULL
           OR p_business_group_id <> nvl(g_business_group_id,0) THEN

            -- set the global debug value
            g_debug :=  pqp_gb_psi_functions.check_debug(p_business_group_id);
            debug_enter(l_proc);
        END IF;

        l_return  :=  short_time_hours_criteria
                          (
                          p_business_group_id      =>    p_business_group_id
                          ,p_assignment_id         =>    p_assignment_id
                          ,p_effective_date        =>    p_effective_date
                          );
        debug('l_return: '||l_return);
        debug_exit(l_proc);
        return l_return;
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
    END short_time_hours_acc_criteria;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------< short_time_hours_data_ele_val >----------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_data_ele_val
                 (
                 p_ext_user_value     IN VARCHAR2
                 ,p_output_value       OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.short_time_hours_data_ele_val';
        l_return  NUMBER  :=  0;
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
            l_return  NUMBER  :=  0;
        BEGIN
            debug_enter(l_proc);

            IF g_effective_date IS NULL THEN
                p_output_value  :=  NULL;
                debug('ERROR: No Claim Date for the element entry');
                l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                   (p_error_number        =>    94507
                                   ,p_error_text          =>    'BEN_94507_NO_CLAIM_DATE_SIN'
                                   ,p_token1              =>    SUBSTR(g_curr_element_type_name
                                                                 ||'('||ben_ext_person.g_chg_surrogate_key||')',1,80)
                                   );
            ELSE
                p_output_value  :=  to_char(g_effective_date,'dd/mm/yyyy');
            END IF;

            debug_exit(l_proc);
            return l_return;
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
        -- |----------------------------< get_start_date >-----------------------------|
        -- Description:
        -- ----------------------------------------------------------------------------
        FUNCTION get_start_date
                    (
                    p_output_value       OUT NOCOPY VARCHAR2
                    )RETURN NUMBER
        IS
            l_proc varchar2(72) := g_package||'.get_start_date';
            l_return  NUMBER  :=  0;
            l_curr_index  NUMBER;
        BEGIN
            debug_enter(l_proc);
            l_curr_index  := ben_ext_person.g_chg_pay_evt_index;
            IF l_curr_index = g_pay_proc_evt_tab.LAST - 1 THEN
                debug('Last event on the current person');
                IF g_start_date IS NULL THEN
                    p_output_value  :=  NULL;
                    --raise error
                    l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                   (p_error_number        =>    94509
                                   ,p_error_text          =>    'BEN_94509_NO_START_END_DATE'
                                   );
                ELSE
                    p_output_value  :=  to_char(g_start_date,'dd/mm/yyyy');
                END IF;
            ELSE
                IF g_start_date IS NULL THEN
                    p_output_value  :=  NULL;
                ELSE
                    p_output_value  :=  to_char(g_start_date,'dd/mm/yyyy');
                END IF;
            END IF;

            debug_exit(l_proc);
            return l_return;
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
        END get_start_date;
        ---
        -- ----------------------------------------------------------------------------
        -- |----------------------------< get_end_date >-----------------------------|
        -- Description:
        -- ----------------------------------------------------------------------------
        FUNCTION get_end_date
                    (
                    p_output_value       OUT NOCOPY VARCHAR2
                    )RETURN NUMBER
        IS
            l_proc varchar2(72) := g_package||'.get_end_date';
            l_return  NUMBER  :=  0;
            l_curr_index  NUMBER;
        BEGIN
            debug_enter(l_proc);

            l_curr_index  := ben_ext_person.g_chg_pay_evt_index;

            IF g_end_date IS NULL THEN
                p_output_value  :=  NULL;
            ELSE
                p_output_value  :=  to_char(g_end_date,'dd/mm/yyyy');
            END IF;

            debug_exit(l_proc);
            return l_return;
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
        END get_end_date;
        ---
        -- ----------------------------------------------------------------------------
        -- |----------------------------< get_adjusted_hours >-----------------------------|
        -- Description:
        -- ----------------------------------------------------------------------------
        FUNCTION get_adjusted_hours
                    (
                    p_output_value       OUT NOCOPY VARCHAR2
                    )RETURN NUMBER
        IS
            l_proc varchar2(72) := g_package||'.get_adjusted_hours';
            l_return  NUMBER  :=  0;
            l_curr_index  NUMBER;
            -- ----------------------------------------------------------------------------
            -- |----------------------------< format_adj_hours >-----------------------------|
            -- Description:
            -- ----------------------------------------------------------------------------
            FUNCTION format_adj_hours RETURN VARCHAR2
            IS
                l_proc varchar2(72) := g_package||'.format_adj_hours';
                l_return VARCHAR2(12) :=  '';
            BEGIN
                debug_enter(l_proc);

                -- round the value of g_adjusted_hours
                IF g_adjusted_hours IS NULL THEN
                  debug_exit(l_proc);
                  RETURN l_return;
                END IF;
                debug('g_adjusted_hours before rounding: '||g_adjusted_hours);
                --  g_adjusted_hours  :=  round(g_adjusted_hours,2);
                -- Bug fix 5152505
                -- adjusted hours is rounded off to the nearest quarter.
                    g_adjusted_hours :=  pqp_utilities.round_value_up_down
                                                (p_value_to_round => g_adjusted_hours
                                                ,p_base_value     => 0.25
                                                ,p_rounding_type  => 'NEAREST'
                                                );
                debug('g_adjusted_hours after rounding: '||g_adjusted_hours);

                -- format it to S09999999.99

                l_return  :=  to_char(g_adjusted_hours,'S09999999D99');
                --l_return :=  g_adjusted_hours;
                /*IF g_adjusted_hours = 0 THEN
                    l_return  :=  '0.00';
                ELSE
                    l_return  :=  g_adjusted_hours;
                END IF;

                IF g_adjusted_hours >= 0 THEN
                      l_return  :=  '+'||LPAD(l_return,11,'0');
                ELSE
                      l_return  :=  '-'||LPAD(SUBSTR(l_return,2),11,'0');
                END IF;*/

                debug('l_return after formatting: '||l_return);
                debug_exit(l_proc);
                return l_return;
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
            END format_adj_hours;
            ---
        BEGIN
            debug_enter(l_proc);

            l_curr_index  := ben_ext_person.g_chg_pay_evt_index;

            IF l_curr_index = g_pay_proc_evt_tab.LAST - 1
                AND g_current_layout = 'ACCUMULATED' THEN
                debug('Last event on the current person');
                IF g_adjusted_hours IS NULL THEN
                    p_output_value  :=  NULL;
                    --raise error
                    l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                   (p_error_number        =>    94510
                                   ,p_error_text          =>    'BEN_94510_NO_ADJ_HRS_ACC'
                                   );
                ELSE
                    p_output_value  :=  format_adj_hours();
                END IF;
            ELSE
                IF g_adjusted_hours IS NULL THEN
                    p_output_value  :=  NULL;
                ELSE
                    p_output_value  :=  format_adj_hours();
                END IF;
            END IF;
            IF g_current_layout = 'SINGLE' AND p_output_value IS NULL THEN
                -- raise error
                l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                   (p_error_number        =>    94511
                                   ,p_error_text          =>    'BEN_94511_NO_ADJ_HRS_SIN'
                                   ,p_token1              =>    SUBSTR(g_curr_element_type_name
                                                                 ||'('||ben_ext_person.g_chg_surrogate_key||')',1,80)
                                   );
            END IF;
            debug_exit(l_proc);
            return l_return;
        END get_adjusted_hours;
        ---
    BEGIN
        debug_enter(l_proc);
        debug('p_ext_user_value: '||p_ext_user_value,10);
        debug('------------------------------------------');
        debug('g_start_date: '||g_start_date,10);
        debug('g_end_date: '||g_end_date,10);
        debug('g_effective_date: '||g_effective_date,10);
        debug('g_adjusted_hours: '||g_adjusted_hours,10);
        debug('------------------------------------------');
        IF p_ext_user_value = 'StartDate'  THEN
           l_return :=  get_start_date
                          (
                          p_output_value  =>  p_output_value
                          );
        ELSIF p_ext_user_value = 'EndDate' THEN
           l_return :=  get_end_date
                          (
                          p_output_value  =>  p_output_value
                          );
        ELSIF p_ext_user_value = 'HoursVariation' THEN
           l_return :=  get_adjusted_hours
                          (
                          p_output_value  =>  p_output_value
                          );
        ELSIF p_ext_user_value = 'EffectiveDate' THEN
           l_return :=  get_effective_date
                          (
                          p_output_value  =>  p_output_value
                          );
        END IF;

        debug_exit(l_proc);
        return l_return;
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
    END short_time_hours_data_ele_val;
    ---
    -- ----------------------------------------------------------------------------
    -- |----------------------< short_time_hours_claim_date >--------------------------|
    --  Description:
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_claim_date
                 (
                 p_ext_user_value     IN VARCHAR2
                 ,p_output_value       OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_package||'.short_time_hours_claim_date';
        l_output_value    VARCHAR2(10);
        l_return    NUMBER;
    BEGIN
        debug_enter(l_proc);

        l_return  :=  short_time_hours_data_ele_val
                             (
                             p_ext_user_value     =>    p_ext_user_value
                             ,p_output_value      =>    l_output_value
                             );

        p_output_value  :=  to_date(l_output_value,'dd/mm/yyyy');
        debug('l_output_value: '||l_output_value);
        debug('p_output_value: '||p_output_value);
        debug_exit(l_proc);
        return l_return;
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
    END short_time_hours_claim_date;
    ------
    -- ----------------------------------------------------------------------------
    -- |----------------------< short_time_hours_post_proc >--------------------------|
    --  Description:  This is the post-processing rule  for the Short-Time Hours History.
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_post_proc RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_package||'.short_time_hours_post_proc';
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
    END short_time_hours_post_proc;
    ------
END PQP_GB_PSI_STH_HISTORY;

/
