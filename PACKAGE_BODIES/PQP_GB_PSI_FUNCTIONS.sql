--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_FUNCTIONS" AS
--  /* $Header: pqpgbpsifunc.pkb 120.18.12010000.25 2009/12/08 14:39:33 jvaradra ship $ */

--
--
-- Exceptions
hr_application_error exception;
pragma exception_init (hr_application_error, -20001);


g_sth_single VARCHAR2(10);  -- For Bug 7010282


FUNCTION get_time
RETURN NUMBER
IS

  t NUMBER;

 BEGIN

   SELECT TO_CHAR(SYSDATE,'SSSSS') INTO t FROM dual;

   return t;

END get_time;


-- ----------------------------------------------------------------------------
-- |--------------------------------< check_debug >---------------------------------|
-- ----------------------------------------------------------------------------

FUNCTION check_debug
    (p_business_group_id IN     VARCHAR2 -- context
 )
RETURN boolean
IS

 l_proc_name           VARCHAR2(61):=
  g_proc_name||'check_debug';

 l_config_value        pqp_utilities.t_config_values;
 l_return              VARCHAR2(20);
 l_debug_enable_mode   fnd_concurrent_requests.argument3%type;
 l_process_parameters  csr_debug_enable_mode%rowtype;
 l_parent_process_parameters  csr_debug_enable_mode%rowtype;

--
BEGIN

--

  IF g_debug_flag IS NULL
  THEN
  --
    OPEN csr_debug_enable_mode;
    FETCH csr_debug_enable_mode INTO l_process_parameters;

      IF csr_debug_enable_mode%NOTFOUND
      THEN

        OPEN csr_debug_enable_mode_parent;
        FETCH csr_debug_enable_mode_parent INTO l_parent_process_parameters;
          IF csr_debug_enable_mode_parent%NOTFOUND
          THEN

            g_debug := FALSE;
          ELSE
            IF l_parent_process_parameters.argument3 = '3DBG'
            THEN

              g_debug := TRUE;
              g_debug_flag := 'Y';

            ELSE

              g_debug := FALSE;
              g_debug_flag := 'N';
            END IF;
          END IF;
        CLOSE csr_debug_enable_mode_parent;

      ELSE -- IF csr_debug_enable_mode%NOTFOUND
        IF l_process_parameters.argument3 = '3DBG'
        THEN
          g_debug := TRUE;
          g_debug_flag := 'Y';

        ELSE
          g_debug := FALSE;
          g_debug_flag := 'N';

        END IF;
        -- also, save the params for future use
        g_extract_type := l_process_parameters.argument5;
        g_dfn_name     := l_process_parameters.argument6;

      END IF;
    CLOSE csr_debug_enable_mode;

    IF g_debug = TRUE THEN
      -- fetch configuration value for paypoint
      -- debug('Fetching configuration value for debug flag  ...', 20);
      pqp_utilities.get_config_type_values
           ( p_configuration_type   => 'PQP_GB_PENSERVER_DEFINITION'
            ,p_business_group_id    => p_business_group_id
            ,p_legislation_code     => NULL
            ,p_tab_config_values    => l_config_value
           );

      IF l_config_value.COUNT > 0 -- config value found
      THEN
        g_debug_flag := l_config_value(l_config_value.FIRST).pcv_information1;
        --
        IF g_debug_flag = 'Y' THEN
          g_debug :=  TRUE;
        ELSE
          g_debug :=  FALSE;
        END IF;
        --
      ELSE
        g_debug_flag := 'N';
        g_debug :=  FALSE;
      END IF;
    END IF;
  --
  END IF;

  return g_debug;

END check_debug;


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

/* For bug 8359083
-- ----------------------------------------------------------------------------
-- |----------------------------< get_penserver_date >-------------------------|
-- Description : For each assignment fetch the least effective date
-- ----------------------------------------------------------------------------

FUNCTION get_penserver_date
                (p_assignment_id      IN   NUMBER
                ,p_business_group_id  IN   NUMBER
                ,p_lapp_date          IN   DATE
                ,p_end_date           IN   DATE
                 )  RETURN date
    IS

    l_penserver_date date;

    -- This cursor will fetch the minimum efective on which a penserver event has
    -- occured for the employee having the creation_date in the current period.
    cursor csr_pen_eff_date
        is select min(ppe.effective_date)
             from pay_process_events ppe
            where trunc(ppe.creation_date) between p_lapp_date and p_end_date
              and ppe.assignment_id = p_assignment_id
              and ppe.business_group_id = p_business_group_id
              and ppe.effective_date >= ben_ext_thread.g_effective_start_date
              and  exists (select pde.event_group_id
                             from pay_datetracked_events pde,
                                  pay_event_updates peu
                            where pde.event_group_id in (select becv.val_1
                                                           from ben_ext_crit_val becv,
                                                                ben_ext_crit_typ bect,
                                                                ben_ext_dfn  bed
                                                          where becv.ext_crit_typ_id = bect.ext_crit_typ_id
                                                            and bect.ext_crit_prfl_id = bed.ext_crit_prfl_id
                                                            and bed.ext_dfn_id = ben_ext_thread.g_ext_dfn_id
                                                            and bect.crit_typ_cd = 'CPE')
                             and ppe.event_update_id = peu.event_update_id
                             and peu.dated_table_id = pde.dated_table_id);


   BEGIN

    open csr_pen_eff_date;
    fetch csr_pen_eff_date into l_penserver_date;
    if l_penserver_date is null
    then
       l_penserver_date := p_lapp_date;
    end if;
    close csr_pen_eff_date;


    if l_penserver_date > p_lapp_date
    then
       l_penserver_date := p_lapp_date;
    end if;

    l_penserver_date := l_penserver_date - 1;

    debug( 'p_lapp_date :' ||p_lapp_date,20);
    debug( 'l_penserver_date :' ||l_penserver_date,20);

    RETURN l_penserver_date;

   END; */

-- ----------------------------------------------------------------------------
-- |------------------------< GET_CURRENT_EXTRACT_PERSON >---------------------|
-- ----------------------------------------------------------------------------

--  GET_CURRENT_EXTRACT_PERSON
--
--    Returns the ext_rslt_id for the current extract process
--    if one is running, else returns -1
--
  FUNCTION get_current_extract_person
    (p_assignment_id NUMBER  -- context
    )
  RETURN NUMBER
  IS
    l_person_id  NUMBER;
  BEGIN
    SELECT person_id
    INTO   l_person_id
    FROM   per_all_assignments_f
    WHERE  assignment_id = p_assignment_id
      AND  ROWNUM < 2;
    RETURN l_person_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;
--

-- ----------------------------------------------------------------------------
-- |------------------------< GET_CURRENT_EXTRACT_RESULT >-----------------------|
-- ----------------------------------------------------------------------------

--
--  GET_CURRENT_EXTRACT_RESULT
--
--    Returns the person id associated with the given assignment.
--    If none is found,it returns NULL. This may arise if the
--    user calls this from a header/trailer record, where
--    a dummy context of assignment_id = -1 is passed.
--
--
  FUNCTION get_current_extract_result
    RETURN NUMBER
  IS
     e_extract_process_not_running EXCEPTION;
     PRAGMA EXCEPTION_INIT(e_extract_process_not_running,-8002);
     l_ext_rslt_id  NUMBER;
  --
  BEGIN
  --
--    SELECT ben_ext_rslt_s.CURRVAL
--    INTO   l_ext_rslt_id
--    FROM   DUAL;

    l_ext_rslt_id := ben_ext_thread.g_ext_rslt_id;

    RETURN l_ext_rslt_id;
  --
  EXCEPTION
    WHEN e_extract_process_not_running THEN
      RETURN -1;
  END;



-- ----------------------------------------------------------------------------
-- |---------------------------< is_alphanumeric >--------------------|
-- ----------------------------------------------------------------------------
function is_alphanumeric
  (p_string                in varchar2
  ) Return Boolean is
--
  l_proc_name   varchar2(72) := g_proc_name||'is_alphanumeric';

begin
--
  debug_enter(l_proc_name);

  IF
    TRIM(TRANSLATE(p_string,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz '
    ,'                                                              _'))
  IS NULL

  THEN
    debug('true');
    debug_exit(l_proc_name);
    return true;
  ELSE
    debug('false');
    debug_exit(l_proc_name);
    return false;
  END IF;
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

  --
end is_alphanumeric;

-- ----------------------------------------------------------------------------
-- |---------------------------< is_alphanumeric_space_allowed >--------------------|
-- ----------------------------------------------------------------------------
function is_alphanumeric_space_allowed
  (p_string                in varchar2
  ) Return Boolean is
--
  l_proc_name   varchar2(72) := g_proc_name||'is_alphanumeric';

begin
--
  debug_enter(l_proc_name);

  IF
    TRIM(TRANSLATE(p_string,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz '
    ,'                                                               '))
  IS NULL

  THEN
    debug('true');
    debug_exit(l_proc_name);
    return true;
  ELSE
    debug('false');
    debug_exit(l_proc_name);
    return false;
  END IF;
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

  --
end is_alphanumeric_space_allowed;
-- ----------------------------------------------------------------------------
-- |---------------------------< is_numeric >--------------------|
-- ----------------------------------------------------------------------------
function is_numeric
  (p_string                in varchar2
  ) Return Boolean is
--
  l_proc_name   varchar2(72) := g_proc_name||'is_numeric';

begin
--
  debug_enter(l_proc_name);

  IF
    TRIM(TRANSLATE(p_string,'0123456789'
    ,'          '))
  IS NULL

  THEN
    debug('true');
    debug_exit(l_proc_name);
    return true;
  ELSE
    debug('false');
    debug_exit(l_proc_name);
    return false;
  END IF;
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

  --
end is_numeric;



-- =============================================================================
-- This procedure gets the bonus codes information from pay_element_type_extra_info
-- if bonus code is alphanumeric then information is passed to the output file
-- else to the log file
-- =============================================================================
  PROCEDURE get_bonus_codes
                          (p_business_group_id IN VARCHAR2
                                      ,p_from_date         IN DATE
                                  ,p_to_date           IN DATE) IS

  l_column_separator       VARCHAR2(10) := ' , ';
  l_pay_point              VARCHAR2(10);
  l_filler1                CHAR(16):=' ';
  l_filler2                CHAR(86):=' ';
  l_bonus_codes            t_bonus_codes;
  l_bonus_index            NUMBER:=0;
  l_alphanum_code          VARCHAR2(200);
  l_proc_name              VARCHAR2(200):= g_proc_name || 'get_bonus_codes';

  BEGIN

  debug_enter(l_proc_name);

  -- get paypoint value for business group id passed
  l_pay_point := paypoint(p_business_group_id);

    debug ('l_pay_point:'||l_pay_point);


    IF l_pay_point = ''
       or
       NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> l_pay_point)
    THEN
      -- Raise error as Paypoint is unknown(E)
      hr_utility.set_message(805, 'BEN_94453_INV_PAYPOINT');
      fnd_file.put_line(fnd_file.LOG
                          , RPAD('Error', 30) || ': ' || hr_utility.get_message);
      fnd_file.put_line(fnd_file.LOG, ' ');
    END IF;


  -- Pass context as PQP_GB_PENSERV_BONUS_INFO to get the bonus codes information
  FOR  l_bonus_rec IN csr_get_extra_bonus_info
                        (p_from_date         => p_from_date
                                    ,p_to_date           => p_to_date)
  LOOP

     debug ('l_bonus_rec.code:'||l_bonus_rec.code);
     -- set error code to null
     l_alphanum_code := NULL;

     IF l_bonus_rec.code IS NULL THEN
       l_alphanum_code := 'NULL';
     ELSIF NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> l_bonus_rec.code) THEN
       -- raise error against this element/code
       l_alphanum_code := l_bonus_rec.code;
     END IF;

     IF l_alphanum_code IS NOT NULL THEN
       --
             fnd_file.put_line(fnd_file.LOG,
                                RPAD(nvl(l_pay_point,' '),6,' ') ||
                                RPAD(nvl(l_bonus_rec.code,' '),4,' ') ||
                                RPAD(nvl(l_bonus_rec.description,' '),34,' ') ||
                                RPAD(nvl(l_bonus_rec.pension_flag,' '),1,' ') ||
                                RPAD(nvl(l_bonus_rec.industrial_flag,' '),1,' ') ||
                                RPAD(l_filler1,16,' ') ||
                                RPAD(nvl(l_bonus_rec.basic_pay_reckonable,' '),1,' ') ||
                                RPAD(nvl(l_bonus_rec.pre_75_reckonable,' '),1,' ') ||
                                RPAD(l_filler2,86,' '));
       --
          -- Raise error as Special characters are not permitted in the allowance code(E)
          hr_utility.set_message(805, 'BEN_94458_PEN_SPCL_CHAR_CHK');
          fnd_file.put_line(fnd_file.LOG
                               , RPAD('Error', 30) || ': ' || hr_utility.get_message);

          fnd_file.put_line(fnd_file.log, 'INTERFACE : Bonus');

          fnd_file.put_line(fnd_file.log, 'ELEMENT : '||  l_bonus_rec.element_name);

          fnd_file.put_line(fnd_file.log, 'BONUS CODE : '||  l_alphanum_code);
          fnd_file.put_line(fnd_file.log, ' ');
          fnd_file.put_line(fnd_file.log, ' ');
       --

     --
     ELSE
     --
       -- increase the counter
       l_bonus_index := l_bonus_index +1;
       l_bonus_codes(l_bonus_index).pay_point            :=RPAD(nvl(l_pay_point,' '),6,' ');
       l_bonus_codes(l_bonus_index).bonus_code           :=RPAD(nvl(l_bonus_rec.code,' '),4,' ');
       l_bonus_codes(l_bonus_index).bonus_descr          :=RPAD(nvl(l_bonus_rec.description,' '),34,' ');
       l_bonus_codes(l_bonus_index).pension_flag         :=RPAD(nvl(l_bonus_rec.pension_flag,' '),1,' ');
       l_bonus_codes(l_bonus_index).industrial_flag      :=RPAD(nvl(l_bonus_rec.industrial_flag,' '),1,' ');
       l_bonus_codes(l_bonus_index).filler1              :=RPAD(l_filler1,16,' ');
       l_bonus_codes(l_bonus_index).basic_pay_reckonable :=RPAD(nvl(l_bonus_rec.basic_pay_reckonable,' '),1,' ');
       l_bonus_codes(l_bonus_index).pre_75_reckonable    :=RPAD(nvl(l_bonus_rec.pre_75_reckonable,' '),1,' ');
       l_bonus_codes(l_bonus_index).filler2              :=RPAD(l_filler2,86,' ');
     --
     END IF;

  END LOOP;

  IF l_bonus_codes.COUNT > 0
  THEN
    -- insert correct bonus information into output file
    FOR l_bonus_index IN l_bonus_codes.FIRST..l_bonus_codes.LAST
    LOOP

           fnd_file.put_line(fnd_file.output,
                             l_bonus_codes(l_bonus_index).pay_point ||
                             l_bonus_codes(l_bonus_index).bonus_code ||
                             l_bonus_codes(l_bonus_index).bonus_descr ||
                             l_bonus_codes(l_bonus_index).pension_flag ||
                             l_bonus_codes(l_bonus_index).industrial_flag ||
                             l_bonus_codes(l_bonus_index).filler1 ||
                             l_bonus_codes(l_bonus_index).basic_pay_reckonable ||
                             l_bonus_codes(l_bonus_index).pre_75_reckonable ||
                             l_bonus_codes(l_bonus_index).filler2 );

    END LOOP;
  END IF;

  debug_exit(l_proc_name);

 EXCEPTION
      WHEN OTHERS  THEN
       debug_exit(' Error  in '||l_proc_name);
           RAISE;

 END get_bonus_codes;

-- =============================================================================
-- This procedure gets allowance code information from pay_element_type_extra_info
-- if allowance code is alphanumeric then information is passed to the output file
-- else to the log file.
-- =============================================================================
 PROCEDURE get_allowance_codes
           (p_business_group_id IN VARCHAR2
                       ,p_from_date         IN DATE
                   ,p_to_date           IN DATE) IS

  l_column_separator          VARCHAR2(10) := ' , ';
  l_pay_point                 VARCHAR2(10);
  l_filler1                   CHAR(16)     :=' ';
  l_filler2                   CHAR(79)     :=' ';
  l_allowance_codes           t_allowance_codes;
  l_allowance_index           NUMBER       :=0;
  l_alphanum_code             VARCHAR2(200);
  l_proc_name                 VARCHAR2(200):= g_proc_name || 'get_allowance_codes';

  BEGIN

    debug_enter(l_proc_name);
    debug('Entering get_allowance_codes');

  -- get paypoint value for business group id passed
  l_pay_point := paypoint(p_business_group_id);
  debug ('l_pay_point:'||l_pay_point);

    IF l_pay_point = ''
       or
       NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> l_pay_point)
    THEN
       -- Raise error as Paypoint is unknown(E)
       hr_utility.set_message(805, 'BEN_94453_INV_PAYPOINT');
       fnd_file.put_line(fnd_file.LOG
                          , RPAD('Error', 30) || ': ' || hr_utility.get_message);
       fnd_file.put_line(fnd_file.LOG, ' ');
    END IF;
  --Pass context as PQP_GB_PENSERV_ALLOWANCE_INFO to get the allowance codes information
  FOR  l_allowance_rec IN csr_get_extra_allow_info
                        (p_from_date         => p_from_date
                                    ,p_to_date           => p_to_date)
  LOOP

       debug ('l_allowance_rec.code:'||l_allowance_rec.code);
       -- set error code to null
       l_alphanum_code := NULL;

       IF l_allowance_rec.code IS NULL THEN
         l_alphanum_code := 'NULL';
       ELSIF NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> l_allowance_rec.code) THEN
         -- raise error against this element/code
         l_alphanum_code := l_allowance_rec.code;
       END IF;

       IF l_alphanum_code IS NOT NULL THEN
       --
             fnd_file.put_line(fnd_file.LOG,
                                RPAD(nvl(l_pay_point,' '),6,' ') ||
                                RPAD(nvl(l_allowance_rec.code,' '),10,' ') ||
                                RPAD(nvl(l_allowance_rec.description,' '),34,' ') ||
                                RPAD(nvl(l_allowance_rec.pension_flag,' '),1,' ') ||
                                RPAD(nvl(l_allowance_rec.industrial_flag,' '),1,' ') ||
                                RPAD(nvl(l_allowance_rec.spread_bonus_flag,' '),1,' ') ||
                                RPAD(l_filler1,16,' ') ||
                                RPAD(nvl(l_allowance_rec.basic_pay_reckonable,' '),1,' ') ||
                                RPAD(nvl(l_allowance_rec.pre_75_reckonable,' '),1,' ') ||
                                RPAD(l_filler2,79,' '));
       --
          -- Raise error as Special characters are not permitted in the allowance code(E)
          hr_utility.set_message(805, 'BEN_94458_PEN_SPCL_CHAR_CHK');
          fnd_file.put_line(fnd_file.LOG
                               , RPAD('Error', 30) || ': ' || hr_utility.get_message);

          fnd_file.put_line(fnd_file.log, 'INTERFACE : Allowance');

          fnd_file.put_line(fnd_file.log, 'ELEMENT : '||  l_allowance_rec.element_name);

          fnd_file.put_line(fnd_file.log, 'ALLOWANCE CODE : '||  l_alphanum_code);
          fnd_file.put_line(fnd_file.log, ' ');
          fnd_file.put_line(fnd_file.log, ' ');
       --
       ELSE
       --
         -- increase the counter
         l_allowance_index := l_allowance_index + 1;
         l_allowance_codes(l_allowance_index).pay_point           :=RPAD(nvl(l_pay_point,' '),6,' ');
         l_allowance_codes(l_allowance_index).allowance_code      :=RPAD(nvl(l_allowance_rec.code,' '),10,' ');
         l_allowance_codes(l_allowance_index).allowance_descr     :=RPAD(nvl(l_allowance_rec.description,' '),34,' ');
         l_allowance_codes(l_allowance_index).pension_flag        :=RPAD(nvl(l_allowance_rec.pension_flag,' '),1,' ');
         l_allowance_codes(l_allowance_index).industrial_flag     :=RPAD(nvl(l_allowance_rec.industrial_flag,' '),1,' ');
         l_allowance_codes(l_allowance_index).spread_bonus_flag   :=RPAD(nvl(l_allowance_rec.spread_bonus_flag,' '),1,' ');
         l_allowance_codes(l_allowance_index).filler1             :=RPAD(l_filler1,16,' ');
         l_allowance_codes(l_allowance_index).basic_pay_reckonable:=RPAD(nvl(l_allowance_rec.basic_pay_reckonable,' '),1,' ');
         l_allowance_codes(l_allowance_index).pre_75_reckonable   :=RPAD(nvl(l_allowance_rec.pre_75_reckonable,' '),1,' ');
         l_allowance_codes(l_allowance_index).filler2             :=RPAD(l_filler2,79,' ');
       --
       END IF;

  END LOOP;
  debug ('Before writing into file');

  IF l_allowance_codes.COUNT > 0
  THEN
    -- insert correct allowance information into output file
    FOR l_allowance_index IN l_allowance_codes.FIRST..l_allowance_codes.LAST
    LOOP

         fnd_file.put_line(fnd_file.output,
                           l_allowance_codes(l_allowance_index).pay_point ||
                           l_allowance_codes(l_allowance_index).allowance_code ||
                           l_allowance_codes(l_allowance_index).allowance_descr ||
                           l_allowance_codes(l_allowance_index).pension_flag ||
                           l_allowance_codes(l_allowance_index).industrial_flag ||
                           l_allowance_codes(l_allowance_index).spread_bonus_flag ||
                           l_allowance_codes(l_allowance_index).filler1 ||
                           l_allowance_codes(l_allowance_index).basic_pay_reckonable ||
                           l_allowance_codes(l_allowance_index).pre_75_reckonable ||
                           l_allowance_codes(l_allowance_index).filler2 );

    END LOOP;
  END IF;
 debug_exit(l_proc_name);

 EXCEPTION
      WHEN OTHERS  THEN
      debug_exit(' Error  in '||l_proc_name);
      RAISE;
 END get_allowance_codes;



-- Function returns extract result id for a given request id
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_ext_rslt_frm_req >----------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_ext_rslt_frm_req (p_request_id        IN NUMBER
                              ,p_business_group_id IN NUMBER
                              )
  RETURN NUMBER IS
--
  CURSOR csr_get_ext_rslt_id
  IS
  SELECT ext_rslt_id
    FROM ben_ext_rslt
   WHERE request_id = p_request_id
     AND business_group_id = p_business_group_id;

  l_ext_rslt_id  NUMBER;
  l_proc_name    VARCHAR2 (80) := g_proc_name
                                 || 'get_ext_rslt_frm_req';
  l_proc_step    NUMBER;

--
BEGIN
  --
  IF g_debug
  THEN
     l_proc_step                := 10;
     DEBUG (   'Entering: '
            || l_proc_name, l_proc_step);
  END IF;

  OPEN csr_get_ext_rslt_id;
  FETCH csr_get_ext_rslt_id INTO l_ext_rslt_id;

  IF csr_get_ext_rslt_id%NOTFOUND THEN
     fnd_message.set_name ('BEN', 'BEN_91873_EXT_NOT_FOUND');
     fnd_file.put_line(fnd_file.log, 'Error: '
                                    || fnd_message.get);
     fnd_file.put_line(fnd_file.log, ' ');
     CLOSE csr_get_ext_rslt_id;
     fnd_message.raise_error;
  END IF; -- End if of row not found check ...
  CLOSE csr_get_ext_rslt_id;

  IF g_debug
  THEN
     DEBUG (   'Extract Result ID: '
            || TO_CHAR(l_ext_rslt_id));
     l_proc_step                := 20;
     DEBUG (   'Leaving: '
            || l_proc_name, l_proc_step);
  END IF;

  RETURN l_ext_rslt_id;

END get_ext_rslt_frm_req;
--



-- =============================================================================
-- Build_Metadata_Ext_Names
-- =============================================================================

PROCEDURE Build_Metadata_Ext_Names  IS
  l_proc_name    VARCHAR2(120):=  g_proc_name||'Build_Metadata_Ext_Names';
BEGIN
  debug_enter(l_proc_name);

/*
1  BASIC DATA              -- DONE
2  ADDRESS                 -- DONE
3  SERVICE HISTORY         -- DONE
4  PART-TIME HOURS HISTORY
5  SHORT-TIME HOURS HISTORY - Single Records
6  SHORT-TIME HOURS HISTORY - Accumulated Records
7  SALARY HISTORY          -- DONE
8  ALLOWANCE HISTORY
9  BONUS HISTORY
10 EARNINGS HISTORY        -- DONE
11 WPS CONTRIBUTION RATE HISTORY
*/

  ---define Penserver Cutover extract names and codes
  g_cutover_ext_names(1).extract_name       :='PQP GB PenServer Cutover Interface - Basic Data';
  g_cutover_ext_names(1).extract_code       :='BDI';
  g_cutover_ext_names(2).extract_name       :='PQP GB PenServer Cutover Interface - Address';
  g_cutover_ext_names(2).extract_code       :='ADI';
  g_cutover_ext_names(3).extract_name       :='PQP GB PenServer Cutover Interface - Service History';
  g_cutover_ext_names(3).extract_code       :='SVI';
  g_cutover_ext_names(4).extract_name       :='PQP GB PenServer Cutover Interface - Part Time Hours History';
  g_cutover_ext_names(4).extract_code       :='PTH';
  g_cutover_ext_names(5).extract_name       :=' ';
  g_cutover_ext_names(5).extract_code       :=' ';
  g_cutover_ext_names(6).extract_name       :=' ';
  g_cutover_ext_names(6).extract_code       :=' ';
  g_cutover_ext_names(7).extract_name       :='PQP GB PenServer Cutover Interface - Salary History';
  g_cutover_ext_names(7).extract_code       :='SDI';
  g_cutover_ext_names(8).extract_name       :='PQP GB PenServer Cutover Interface - Allowance History';
  g_cutover_ext_names(8).extract_code       :='AHI';
  g_cutover_ext_names(9).extract_name       :='PQP GB PenServer Cutover Interface - Bonus History';
  g_cutover_ext_names(9).extract_code       :='BHI';
  g_cutover_ext_names(10).extract_name      :='PQP GB PenServer Standard Interface - Earnings History';
  g_cutover_ext_names(10).extract_code      :='EDI';
  g_cutover_ext_names(11).extract_name      :='PQP GB PenServer Cutover Interface - WPS History';
  g_cutover_ext_names(11).extract_code      :='WPS';


  ---define Penserver Periodic extract names and codes
  g_periodic_ext_names(1).extract_name       :='PQP GB PenServer Periodic Changes Interface - Basic Data';
  g_periodic_ext_names(1).extract_code       :='BDI';
  g_periodic_ext_names(2).extract_name       :='PQP GB PenServer Periodic Changes Interface - Address';
  g_periodic_ext_names(2).extract_code       :='ADI';
  g_periodic_ext_names(3).extract_name       :='PQP GB PenServer Periodic Changes Interface - Service History';
  g_periodic_ext_names(3).extract_code       :='SVI';
  g_periodic_ext_names(4).extract_name       :='PQP GB PenServer Periodic Changes Interface - Part Time Hours History';
  g_periodic_ext_names(4).extract_code       :='PTH';
  -- For Bug 7010282
  IF g_sth_single = 'EXCLUDE'
  THEN
     g_periodic_ext_names(5).extract_name       :=' ';
     g_periodic_ext_names(5).extract_code       :=' ';
  ELSE
     g_periodic_ext_names(5).extract_name       :='PQP GB PenServer Periodic Changes Interface - Short Time Hours History (Single Records)';
     g_periodic_ext_names(5).extract_code       :='STS';
  END IF;
  g_periodic_ext_names(6).extract_name       :='PQP GB PenServer Periodic Changes Interface - Short Time Hours History (Accumulated Records)';
  g_periodic_ext_names(6).extract_code       :='STA';
  g_periodic_ext_names(7).extract_name       :='PQP GB PenServer Periodic Changes Interface - Salary History';
  g_periodic_ext_names(7).extract_code       :='SDI';
  g_periodic_ext_names(8).extract_name       :='PQP GB PenServer Periodic Changes Interface - Allowance History';
  g_periodic_ext_names(8).extract_code       :='AHI';
  g_periodic_ext_names(9).extract_name       :='PQP GB PenServer Periodic Changes Interface - Bonus History';
  g_periodic_ext_names(9).extract_code       :='BHI';
  g_periodic_ext_names(10).extract_name      :='PQP GB PenServer Standard Interface - Earnings History';
  g_periodic_ext_names(10).extract_code      :='EDI';
  g_periodic_ext_names(11).extract_name      :='PQP GB PenServer Periodic Interface - WPS History';
  g_periodic_ext_names(11).extract_code      :='WPS';


  ---define Penserver Codes extract names
  g_code_ext_names(1).extract_name   :='PQP GB PenServer Standard Interface - Grade Codes';
  g_code_ext_names(1).extract_code   :='GCI';
  g_code_ext_names(2).extract_name   :='PQP GB PenServer Standard Interface - Location Codes';
  g_code_ext_names(2).extract_code   :='LCI';
  g_code_ext_names(3).extract_name   :='PQP GB PenServer Standard Interface- Allowance Codes';
  g_code_ext_names(3).extract_code   :='ACI';
  g_code_ext_names(4).extract_name   :='PQP GB PenServer Standard Interface- Bonus Codes';
  g_code_ext_names(4).extract_code   :='BCI';


  debug_exit(l_proc_name);

END  Build_Metadata_Ext_Names;


-- =============================================================================
-- ~ PQP_Penserver_Extract: This is called by the conc. program
-- ~ to run cutover Penserver extracts and is basically a
-- ~ wrapper around the benefits conc. program Extract Process.
-- =============================================================================

PROCEDURE PQP_Penserver_Extract
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_benefit_action_id           IN     NUMBER
           ,p_business_group_id           IN     NUMBER
               ,p_execution_mode              IN     VARCHAR2 -- 1GEN/3DBG/2SET/1REP
           ,p_execution_mode_type         IN     VARCHAR2
           ,p_extract_type                IN     VARCHAR2 -- 3CUT/1PED/2CODE
           ,p_dfn_name                    IN     VARCHAR2 -- 1ALL/BDI/ADI/SDI/EDI/ACI/BCI/GCI/LCI
           ,p_start_date                  IN     VARCHAR2
           ,p_eff_date                    IN     VARCHAR2
           ,p_submit_request_y_n          IN     VARCHAR2 default 'N'
           ,p_concurrent_request_id       IN     NUMBER DEFAULT NULL
           ,p_year_end_close              IN     VARCHAR2 default 'N'  -- /* Nuvos Changes */
           ,p_short_time_hours_single     IN     VARCHAR2 default 'INCLUDE'  -- For Bug 7010282
           ) IS

  l_ext_dfn_id        ben_ext_dfn.ext_dfn_id%TYPE;
  l_proc_name         VARCHAR2(61):=  g_proc_name||'PQP_Penserver_Extract';
  l_errbuff           VARCHAR2(3000);
  l_retcode           NUMBER;
  l_extract_name      ben_ext_dfn.name%TYPE;
  l_extract_shortname VARCHAR2(80);
  l_extract_count     NUMBER;

  l_request_id        fnd_concurrent_requests.request_id%TYPE;
  l_index             fnd_concurrent_requests.request_id%TYPE;

  l_wait_success      BOOLEAN := FALSE;
  l_effective_date    DATE;
  l_cutover_date      DATE;
  l_rolling_window_length NUMBER;

  l_config_value      pqp_utilities.t_config_values;

  -- Concurrent program
  l_phase             VARCHAR2(80);
  l_status            VARCHAR2(80);
  l_dev_phase         VARCHAR2(80);
  l_dev_status        VARCHAR2(80);
  l_message           VARCHAR2(80);
  l_err_msg           fnd_new_messages.message_text%TYPE;
  PROGRAM_FAILURE     CONSTANT NUMBER := 2 ;
  PROGRAM_SUCCESS     CONSTANT NUMBER := 0 ;

  -- to store extract names and codes
  l_ext_names          t_ext_dfn_names;
  l_eff_date           VARCHAR2(40);
  l_eff_start_date     VARCHAR2(40);
  l_threads            NUMBER;
  l_chunk_size         NUMBER;
  l_max_errors_allowed NUMBER;

   -- For 115.81

  l_penserv_mode       VARCHAR2(1);


BEGIN

--***************************************
-- IMP!! -- remove this later
-- g_debug := TRUE;
--***************************************

--    fnd_file.put_line(fnd_file.log, l_proc_name || to_char(SYSDATE,'dd-Mon-yyyy hh:mm:ss am'));
    fnd_file.put_line(fnd_file.log, l_proc_name || ' : ' || get_time);

    IF (p_submit_request_y_n = 'N') THEN
      fnd_file.put_line(fnd_file.log, 'First call to ' || l_proc_name );
    ELSE
      fnd_file.put_line(fnd_file.log, 'Second call to ' || l_proc_name );
    END IF;


    -- 115.60
    -- there are cases when some common functions dont get business_group_id
    -- as a paramater. In such cases, this variable shall be referenced
    g_business_group_id_backup := p_business_group_id;

    -- store extract type and name in global
    g_extract_type := p_extract_type;
    g_dfn_name     := p_dfn_name;
    g_sth_single   := p_short_time_hours_single;   -- Bug 7010282


    --115.87: Bug 7291713
    /*
    --115.85
    g_bas_eff_date := p_eff_date;
    */

    -- check for enabling trace
    IF p_execution_mode = '3DBG'
    THEN
      g_debug           :=  pqp_gb_psi_functions.check_debug(p_business_group_id);
    END IF;

    debug_enter(l_proc_name);
    --Maintaining all Penserver extracts in record,so that
    --if at all there will be any name change ,we can modify only this
    Build_Metadata_Ext_Names;
    -- Checking the p_extract_type to decide which extract type to process

    debug('p_business_group_id :' || p_business_group_id);
    debug('p_execution_mode :' || p_execution_mode);
    debug('p_extract_type :' || p_extract_type);
    debug('p_dfn_name :' || p_dfn_name);
    debug('p_start_date :' || p_start_date);
    debug('p_eff_date :' || p_eff_date);
    debug('p_submit_request_y_n :' || p_submit_request_y_n);

    --Now set interface name
    -- BDI/ADI/SDI/EDI
    -- GCI/LCI/ACI/BCI

      -- check for 3CUT/1PED/2CODE
      -- and store in l_ext_names for later use
      IF p_extract_type = '3CUT' THEN
        l_ext_names := g_cutover_ext_names;
      ELSIF p_extract_type = '1PED' THEN
        l_ext_names := g_periodic_ext_names;
      ELSE
        l_ext_names := g_code_ext_names;
      END IF;

    -- Added for serial mode run
    -- in ALL mode and multi-thread
    benutils.get_parameter
      (p_business_group_id => p_business_group_id
      ,p_batch_exe_cd => 'BENXTRCT'
      ,p_threads => l_threads
      ,p_chunk_size => l_chunk_size
      ,p_max_errors => l_max_errors_allowed);

    -- Check if this is the parent thread call
    -- if = N => this is parent -> launch child threads for the extracts
    -- if = Y => this is not parent
    IF p_submit_request_y_n = 'N' and p_execution_mode <> '2SET' THEN

      debug('p_submit_request_y_n is N !',20);

      IF p_dfn_name <> '1ALL' THEN -- single extract submission case
        -- find the short name of the dfn_code
        -- this is the meaning of the lookup code
        l_extract_shortname := HR_GENERAL.DECODE_LOOKUP
                             (p_lookup_type   =>  'PQP_GB_PENSERVER_INTERFACES'
                             ,p_lookup_code   =>  p_dfn_name
                             );

        debug('l_extract_shortname :' || l_extract_shortname,30);
        -- append cutover/periodic to names
        -- codes already have 'code' attached to their name
        IF p_extract_type = '3CUT' THEN
          l_extract_shortname := l_extract_shortname||' - '||'Cutover';
        ELSIF p_extract_type = '1PED' THEN
          l_extract_shortname := l_extract_shortname||' - '||'Periodic';
        END IF;

        IF p_execution_mode = '1REP' THEN
          l_extract_shortname := 'Reprocess'||' - '||l_extract_shortname;
        END IF;

        debug('l_extract_shortname (appended) :' || l_extract_shortname,30);

        debug('p_dfn_name != 1ALL !',20);
        -- Submit the process again, this time with 'Y'
        debug('now launching : '|| l_extract_shortname, 25);

        l_request_id :=
                    fnd_request.submit_request
                          (application => 'PQP'
                          ,program     => 'PQPGBPENSERVER'
                          ,description => l_extract_shortname
                          ,sub_request => FALSE -- TRUE, still not decide on this one
                          ,argument1   => NULL -- benefit_action_id
                          ,argument2   => p_business_group_id
                          ,argument3   => p_execution_mode
                          ,argument4   => p_execution_mode_type
                          ,argument5   => p_extract_type
                          ,argument6   => p_dfn_name
                          ,argument7   => p_start_date
                          ,argument8   => p_eff_date
                          ,argument9   => 'Y'
                          ,argument10   => p_concurrent_request_id
                                  ,argument11  => p_year_end_close         -- For Nuvos changes
                                      ,argument12  => p_short_time_hours_single  -- -- For Bug 7010282
                          );

         -- check for process submit error
         IF l_request_id = 0 THEN

           fnd_message.set_name('PQP', 'PQP_230228_PSI_EXT_SUBMIT_ERR');
           fnd_message.set_token('EXTNAME',g_ext_dtls(1).extract_name);
           l_err_msg := fnd_message.get;
           errbuf := l_err_msg;
           fnd_file.put_line(fnd_file.log, l_err_msg);
           l_err_msg := NULL;
         END IF;

         COMMIT;
         -- now search for extract name in this collection
         -- and store in global collection
         -- we are basically storing extract_name, request_id
         FOR j in 1..l_ext_names.count
         LOOP
           IF l_ext_names(j).extract_code = p_dfn_name
           THEN
             -- store the details in a global collection
             g_ext_dtls(j).extract_name     := l_ext_names(j).extract_name;
             g_ext_dtls(j).extract_code     := l_ext_names(j).extract_code;
             g_ext_dtls(j).short_name       := l_extract_shortname;
             g_ext_dtls(j).request_id       := l_request_id;
             /*
             g_ext_dtls(j).extract_rslt_id  := get_ext_rslt_frm_req
                           (p_request_id        => l_request_id
                           ,p_business_group_id => p_business_group_id
                           );
             */
           ELSE
             g_ext_dtls(j).extract_name := NULL;
           END IF;
         END LOOP;

         debug('Launched : '|| l_extract_shortname, 30);
         --


      ELSE -- submit all extract threads

        debug('p_dfn_name = 1ALL !',20);

        -- = ALL => submit all processes
        FOR i in 1..l_ext_names.count
        LOOP

           -- check for presence in lookup
           -- find the short name of the dfn_code
           l_extract_shortname := HR_GENERAL.DECODE_LOOKUP
                             (p_lookup_type   =>  'PQP_GB_PENSERVER_INTERFACES'
                             ,p_lookup_code   =>  l_ext_names(i).extract_code
                             );

           debug('l_extract_shortname :' || l_extract_shortname,30);

           -- submit the new process only if present in lookup
           IF  l_extract_shortname IS NOT NULL -- if present in lookup, then submit
           THEN
             -- append cutover/periodic to names
             IF p_extract_type = '3CUT' THEN
               l_extract_shortname := l_extract_shortname||' - '||'Cutover';
             ELSIF p_extract_type = '1PED' THEN
               l_extract_shortname := l_extract_shortname||' - '||'Periodic';
             END IF;

             debug('l_extract_shortname (appended) :' || l_extract_shortname,40);
             debug('now launching : '|| l_extract_shortname, 45);

             l_request_id :=
                      fnd_request.submit_request
                                (application => 'PQP'
                                ,program     => 'PQPGBPENSERVER'
                                ,description => l_extract_shortname
                                ,sub_request => FALSE -- TRUE, still not decide on this one
                                ,argument1   => NULL -- benefit_action_id
                                ,argument2   => p_business_group_id
                                ,argument3   => p_execution_mode -- is already canonical
                                ,argument4   => p_execution_mode_type
                                ,argument5   => p_extract_type
                                ,argument6   => l_ext_names(i).extract_code
                                ,argument7   => p_start_date
                                ,argument8   => p_eff_date
                                ,argument9   => 'Y'
                                ,argument10   => p_concurrent_request_id
                                         ,argument11  => p_year_end_close  -- Nuvos Changes
                                 ,argument12  => p_short_time_hours_single  -- -- For Bug 7010282
                                );

             -- check for process submit error
             IF l_request_id = 0 THEN

               fnd_message.set_name('PQP', 'PQP_230228_PSI_EXT_SUBMIT_ERR');
               fnd_message.set_token('EXTNAME',l_ext_names(i).extract_name);
               l_err_msg := fnd_message.get;
               errbuf := l_err_msg;
               fnd_file.put_line(fnd_file.log, l_err_msg);
               l_err_msg := NULL;
               EXIT;
             END IF;

             COMMIT;
             -- store extract details in the collection
             g_ext_dtls(i).extract_name     := l_ext_names(i).extract_name;
             g_ext_dtls(i).extract_code     := l_ext_names(i).extract_code;
             g_ext_dtls(i).short_name       := l_extract_shortname;
             g_ext_dtls(i).request_id       := l_request_id;

             -- fnd_file.put_line(fnd_file.log, 'Request ID: ' ||l_request_id || ' Extract Name: '|| l_ext_names(i).extract_name);

             /*
             g_ext_dtls(i).extract_rslt_id  := get_ext_rslt_frm_req
                           (p_request_id        => l_request_id
                           ,p_business_group_id => p_business_group_id
                           );
             */
             debug('Launched : '|| l_extract_shortname, 50);



             IF l_threads <> 1 THEN
               l_wait_success := fnd_concurrent.wait_for_request
                                   (request_id => l_request_id
                                   ,interval   => (g_wait_interval - 30)
                                   ,max_wait   => g_max_wait
                                   ,phase      => l_phase          -- OUT
                                   ,status     => l_status         -- OUT
                                   ,dev_phase  => l_dev_phase      -- OUT
                                   ,dev_status => l_dev_status     -- OUT
                                   ,message    => l_message        -- OUT
                                   );

               -- Do some error checking here
               IF (NOT l_wait_success
                  )
                  OR
                  (l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL'
                  ) THEN

                 fnd_file.put_line(fnd_file.log, l_message);

                 fnd_message.set_name('PQP', 'PQP_230229_PSI_EXT_EXEC_ERR');
                 fnd_message.set_token('EXTNAME',l_ext_names(i).extract_name);
                 l_err_msg := fnd_message.get;
                 errbuf := l_err_msg;
                 fnd_file.put_line(fnd_file.log, l_err_msg);
                 l_retcode := PROGRAM_FAILURE ;
                 l_err_msg:= NULL;
--                 EXIT;

               END IF; -- (l_dev_phase = 'COMPLETE'

             END IF; -- l_threads <> 1 check ...

           ELSE -- l_extract_shortname IS NOT NULL
             g_ext_dtls(i).extract_name := NULL;
           END IF; -- l_extract short name is NULL check ...
        END LOOP; -- FOR i in 1..g_cutover_ext_names.count

      END IF; -- IF p_dfn_name <> '1ALL' THEN

      -------------- wait for child processes to end
      -- parent to wait till all child process end
      -- parent to error if any child fails

      -- dump data for debugging
      FOR i in 1..g_ext_dtls.count
      LOOP
        debug('g_ext_dtls('||i||').extract_name :' || g_ext_dtls(i).extract_name);
        debug('g_ext_dtls('||i||').extract_code : ' || g_ext_dtls(i).extract_code);
        debug('g_ext_dtls('||i||').short_name : ' || g_ext_dtls(i).short_name);
        debug('g_ext_dtls('||i||').request_id : ' || g_ext_dtls(i).request_id);
      END LOOP;


      l_index := g_ext_dtls.FIRST;

      -- start browsing thru collection of child thread details
      debug('start browsing thru collection of child thread details',60);

      WHILE l_index IS NOT NULL AND (p_dfn_name <> '1ALL' OR
                                     (p_dfn_name = '1ALL' AND l_threads = 1))
      LOOP
        IF g_ext_dtls(l_index).extract_name IS NOT NULL
        THEN

          l_wait_success := fnd_concurrent.wait_for_request
                              (request_id => g_ext_dtls(l_index).request_id
                              ,interval   => (g_wait_interval - 30)
                              ,max_wait   => g_max_wait
                              ,phase      => l_phase          -- OUT
                              ,status     => l_status         -- OUT
                              ,dev_phase  => l_dev_phase      -- OUT
                              ,dev_status => l_dev_status     -- OUT
                              ,message    => l_message        -- OUT
                              );

          -- Do some error checking here
          IF (NOT l_wait_success
             )
             OR
             (l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL'
             ) THEN

            fnd_file.put_line(fnd_file.log, l_message);

            fnd_message.set_name('PQP', 'PQP_230229_PSI_EXT_EXEC_ERR');
            fnd_message.set_token('EXTNAME',g_ext_dtls(l_index).extract_name);
            l_err_msg := fnd_message.get;
            errbuf := l_err_msg;
            fnd_file.put_line(fnd_file.log, l_err_msg);
            l_retcode := PROGRAM_FAILURE ;
            l_err_msg:= NULL;
--            EXIT;
          END IF; -- (l_dev_phase = 'COMPLETE'

--            fnd_file.put_line(fnd_file.log, 'Completed the extract' || to_char(SYSDATE,'dd-Mon-yyyy hh:mm:ss am'));
            fnd_file.put_line(fnd_file.log, 'Completed the extract' || ' : ' || get_time);

            debug('Completed Request ID :'||
                            to_char(g_ext_dtls(l_index).request_id), 160);
        END IF;

        l_index := g_ext_dtls.NEXT(l_index);

      END LOOP; --     WHILE l_index IS NOT NULL

      ---------------------------------------
      -- All extracts have been launched --
      -- now launch control totals
      ---------------------------------------

      debug('p_extract_type : ' || p_extract_type);
      -- now launch control total thread and then wait for it to finish
      IF p_extract_type <> '2CODE' THEN -- IF code files, then dont need to
        debug('now launch control total thread and then wait for it to finish ',70);
        -- fetch rslt_ids from request_ids
        FOR i in 1..g_ext_dtls.count
        LOOP
          IF g_ext_dtls(i).request_id IS NOT NULL
          THEN
            g_ext_dtls(i).extract_rslt_id  := get_ext_rslt_frm_req
                        (p_request_id        => g_ext_dtls(i).request_id
                        ,p_business_group_id => p_business_group_id
                        );
          END IF;
        END LOOP;

        /* The Claybrook order
        1  BASIC DATA              -- DONE
        2  ADDRESS                 -- DONE
        3  SERVICE HISTORY         -- DONE
        4  PART-TIME HOURS HISTORY
        5  SHORT-TIME HOURS HISTORY - Single Records
        6  SHORT-TIME HOURS HISTORY - Accumulated Records
        7  SALARY HISTORY          -- DONE
        8  ALLOWANCE HISTORY
        9  BONUS HISTORY
        10 EARNINGS HISTORY        -- DONE
        11 WPS CONTRIBUTION RATE HISTORY
        */

        /* In control totals
        1 Basic Data                                -- 1
        2 Address                                   -- 2
        3 Service                                   -- 3
        4 Salary                                    -- 7
        5 Earnings                                  -- 10
        6 Allowance                                 -- 8
        7 Bonus                                     -- 9
        8 WPS                                       -- 11
        9 Part-time hours                           -- 4
        10 Short-time hours Single records          -- 5
        11 Short-time hours Accumulated records     -- 6
        */

        --**************
        --
        -- We need to match the order for correct processing, as the order in code is different
        -- from that in control totals.
        --
        --**************
        debug('Submitting control totals ... ',80);
        l_request_id :=
                      fnd_request.submit_request
                                (application => 'PQP'
                                ,program     => 'PQPPENTTL'
                                ,description => ''
                                ,sub_request => FALSE -- TRUE, still not decide on this one
                                ,argument1   => p_extract_type -- NULL
                                ,argument2   => NULL
                                ,argument3   => NULL
                                ,argument4   => g_ext_dtls(1).extract_rslt_id
                                ,argument5   => g_ext_dtls(2).extract_rslt_id
                                ,argument6   => g_ext_dtls(3).extract_rslt_id
                                ,argument7   => g_ext_dtls(7).extract_rslt_id
                                ,argument8   => g_ext_dtls(10).extract_rslt_id
                                ,argument9   => g_ext_dtls(8).extract_rslt_id
                                ,argument10  => g_ext_dtls(9).extract_rslt_id
                                ,argument11  => g_ext_dtls(11).extract_rslt_id
                                ,argument12  => g_ext_dtls(4).extract_rslt_id
                                ,argument13  => g_ext_dtls(5).extract_rslt_id
                                ,argument14  => g_ext_dtls(6).extract_rslt_id
                                ,argument15  => p_business_group_id
                                ,argument16  => p_year_end_close  -- Nuvos Changes
                                );

        -- check for process submit error
        IF l_request_id = 0 THEN

          fnd_message.set_name('PQP', 'PQP_230228_PSI_EXT_SUBMIT_ERR');
          fnd_message.set_token('EXTNAME','PenServer Control Totals Process');
          l_err_msg := fnd_message.get;
          errbuf := l_err_msg;
          fnd_file.put_line(fnd_file.log, l_err_msg);
          l_err_msg := NULL;
        END IF;

        COMMIT;

      -- now wait for control totals to finish
        l_wait_success := fnd_concurrent.wait_for_request
                            (request_id => l_request_id
                            ,interval   => (g_wait_interval - 30)
                            ,max_wait   => g_max_wait
                            ,phase      => l_phase          -- OUT
                            ,status     => l_status         -- OUT
                            ,dev_phase  => l_dev_phase      -- OUT
                            ,dev_status => l_dev_status     -- OUT
                            ,message    => l_message        -- OUT
                            );

        -- Do some error checking here
        IF (NOT l_wait_success
           )
           OR
           (l_dev_phase = 'COMPLETE' AND l_dev_status <> 'NORMAL'
           ) THEN

          fnd_file.put_line(fnd_file.log, l_message);

          fnd_message.set_name('PQP', 'PQP_230229_PSI_EXT_EXEC_ERR');
          fnd_message.set_token('EXTNAME','PenServer Control Totals');
          l_err_msg := fnd_message.get;
          errbuf := l_err_msg;
          fnd_file.put_line(fnd_file.log, l_err_msg);
          l_retcode := PROGRAM_FAILURE ;
          l_err_msg:= NULL;

        END IF; -- (l_dev_phase = 'COMPLETE'
      END IF;
      debug('Completed Request ID :'|| to_char(l_request_id), 160);

      -------------------------

      -- Check the return code for any failure
      IF l_retcode = PROGRAM_FAILURE THEN

          debug('Program Failure, erroring.', 170);

          retcode := l_retcode;
          fnd_message.raise_error;
          RETURN;
      END IF;

      -- Write a summary in the log file
      fnd_file.put_line(fnd_file.log, '----------------------------------------------------------------------   ');
      fnd_file.put_line(fnd_file.log, '**********************************************************************   ');
      fnd_file.put_line(fnd_file.log, ' ');
      fnd_file.put_line(fnd_file.log, 'PenServer Interface Process completed successfully.');
      fnd_file.put_line(fnd_file.log, ' ');
      fnd_file.put_line(fnd_file.log, '                                             Extract Name                                         Request Id    ');
      fnd_file.put_line(fnd_file.log, '---------------------------------------------------------------------------------------------    ------------   ');


      l_extract_count := 0;
      l_index         := g_ext_dtls.FIRST;

      WHILE l_index IS NOT NULL
      LOOP

        IF g_ext_dtls(l_index).extract_name IS NOT NULL
        THEN
          fnd_file.put(fnd_file.log, rpad(g_ext_dtls(l_index).extract_name, 100));
          fnd_file.put_line(fnd_file.log, rpad(g_ext_dtls(l_index).request_id, 15));

          l_extract_count := l_extract_count + 1;
        END IF;

        l_index := g_ext_dtls.NEXT(l_index);

      END LOOP; --     WHILE l_index IS NOT NULL

      fnd_file.put_line(fnd_file.log, 'Total Extracts processed :' ||to_char(l_extract_count));
      fnd_file.put_line(fnd_file.log, ' ');

      fnd_file.put_line(fnd_file.log, ' ');
      fnd_file.put_line(fnd_file.log, '**********************************************************************   ');
      fnd_file.put_line(fnd_file.log, '----------------------------------------------------------------------   ');


    -- the follwoing ELSE is for the case when this process is NOT a parent
    -- it is in fact one of the threads launched by Penserver Interface Process
    -- to launch individual extract processes
    ELSE -- IF p_submit_request_y_n = 'N' THEN

        -- This is a child thread, prepare to submit extract processes
        l_eff_date       := p_eff_date;

        debug('substr(p_eff_date,1,10) : '|| substr(p_eff_date,1,10));
        debug('l_eff_date :' || l_eff_date);

      --***************************
      -- fetch configuration value for cutover date
      debug('Fetching configuration value for cutover date ...', 40);
      pqp_utilities.get_config_type_values
                   ( p_configuration_type   => 'PQP_GB_PENSERVER_PAYPOINT_INFO' --'PQP_GB_PENSERVER_CUTOVER_DATE'
                                ,p_business_group_id    => p_business_group_id
                                ,p_legislation_code     => NULL
                                ,p_tab_config_values    => l_config_value
                     );

      IF l_config_value.COUNT > 0 -- config value found
      THEN
        l_cutover_date := to_date(substr(l_config_value(l_config_value.FIRST).pcv_information2,1,10),'YYYY/MM/DD HH24:MI:SS');
      ELSE
        l_cutover_date := NULL;
      END IF;

      -- fetch Effective rolling date window length
      debug('Fetching Effective rolling date window length ...', 40);
      pqp_utilities.get_config_type_values
                   ( p_configuration_type   => 'PQP_GB_PENSERVER_DEFINITION'
                                ,p_business_group_id    => p_business_group_id
                                ,p_legislation_code     => NULL
                                ,p_tab_config_values    => l_config_value
                     );

      IF l_config_value.COUNT > 0 -- config value found
      THEN
        IF l_rolling_window_length < 1
        THEN
          l_rolling_window_length := 6;
        ELSE
          l_rolling_window_length :=
            fnd_number.canonical_to_number(l_config_value(l_config_value.FIRST).pcv_information2);
        END IF;

        -- performance fix : 1
        g_reference_extract := l_config_value(l_config_value.FIRST).pcv_information3;

      ELSE
        l_rolling_window_length := 6;

        -- performance fix : 1
        g_reference_extract := 'BASIC';
      END IF;


      debug('l_rolling_window_length : '|| l_rolling_window_length);
      -- effective date window restrictions
      -- if effective start date < cutover date, pick cutover date for window start
      IF  l_cutover_date IS NOT NULL and
        (add_months(to_date(p_eff_date,'YYYY/MM/DD HH24:MI:SS'),(-1 * l_rolling_window_length))) < l_cutover_date
      THEN
        l_eff_start_date := to_char(l_cutover_date,'YYYY/MM/DD HH24:MI:SS');
      ELSE
        l_eff_start_date :=
            to_char(add_months(to_date(p_eff_date,'YYYY/MM/DD HH24:MI:SS'),(-1 * l_rolling_window_length)),'YYYY/MM/DD HH24:MI:SS');
      END IF;

      IF p_dfn_name not in ('STA','STS') THEN
        l_eff_start_date :=
            to_char(to_date(l_eff_start_date,'YYYY/MM/DD HH24:MI:SS')+1,'YYYY/MM/DD HH24:MI:SS');
      END IF;

      debug('After add_months/cutover date check : l_eff_start_date :' || l_eff_start_date);

      -- set the start date of the range to '00:00:00'
      -- and set the end date of the range to '23:59:59'
        --l_eff_start_date := TO_CHAR(l_eff_start_date,'YYYY/MM/DD');
        --l_eff_date       := TO_CHAR(l_eff_date,'YYYY/MM/DD')||' 23:59:59';
        debug('setting start date to 00:00:00 and end date to 23:59:59');
        l_eff_start_date := substr(l_eff_start_date,1,10)|| ' 00:00:00';
        l_eff_date := substr(l_eff_date,1,10)|| ' 23:59:59';

        debug('l_eff_start_date :' || l_eff_start_date);
        debug('l_eff_date :' || l_eff_date);
      --

      --***************************

        -- Call the actual benefit extract process with the effective date as
        -- the extract end date along with the ext def. id and business group id.

        IF p_dfn_name = 'ACI' THEN --Allowance Codes Interface
           debug('p_dfn_name = ACI !',30);
           get_allowance_codes
                  (p_business_group_id  => p_business_group_id
                  ,p_from_date          => to_date(l_eff_start_date,'YYYY/MM/DD HH24:MI:SS')
                  ,p_to_date            => to_date(l_eff_date,'YYYY/MM/DD HH24:MI:SS'));
        ELSIF p_dfn_name ='BCI' THEN --Bonus Codes Interface
           debug('p_dfn_name = BCI !',30);
           get_bonus_codes
                  (p_business_group_id  => p_business_group_id
                  ,p_from_date          => to_date(l_eff_start_date,'YYYY/MM/DD HH24:MI:SS')
                  ,p_to_date            => to_date(l_eff_date,'YYYY/MM/DD HH24:MI:SS'));
        ELSE
          -- submit the extract

          -- now search for extract name in this collection
          FOR i in 1..l_ext_names.count
          LOOP
            IF l_ext_names(i).extract_code = p_dfn_name
            THEN
              l_extract_name := l_ext_names(i).extract_name;
              EXIT;
            END IF;
          END LOOP;

          debug('will now find ext_dfn_id and submit extract');
          debug('p_extract_type : ' || p_extract_type );
          debug('p_dfn_name : ' || p_dfn_name );

          --
           --p_benefit_action_id
           --p_business_group_id
               --p_execution_mode
           --p_execution_mode_type
           --p_extract_type
           --p_dfn_name
           --p_start_date
           --p_eff_date
           --p_submit_request_y_n
           --p_concurrent_request_id
          --

          -- find ext_dfn_id
          OPEN csr_ext_dfn_id(c_extract_name => l_extract_name);
          FETCH csr_ext_dfn_id INTO l_ext_dfn_id;
          CLOSE csr_ext_dfn_id;


          -- Start 115.77.11511.3
         OPEN csr_get_run_date(c_ext_dfn_id         => l_ext_dfn_id
                              ,c_business_group_id  => g_business_group_id_backup);
         FETCH csr_get_run_date INTO g_last_app_date,g_output_name;
         CLOSE csr_get_run_date;

         debug('g_last_approved_date : ' || g_last_app_date );
         debug('g_output_name : ' || g_output_name );
         -- End 115.77.11511.3


          IF l_ext_dfn_id IS NOT NULL THEN

            IF p_execution_mode = '1REP'
            THEN
              ben_ext_thread.restart
                  (errbuf                    => l_errbuff
                  ,retcode                   => l_retcode
                  ,p_ext_dfn_id              => l_ext_dfn_id
                  ,p_concurrent_request_id   => p_concurrent_request_id
                  );
            ELSE


--              fnd_file.put_line(fnd_file.log, 'calling ben_process' || to_char(SYSDATE,'dd-Mon-yyyy hh:mm:ss am'));
              fnd_file.put_line(fnd_file.log, 'calling ben_process' || ' : ' || get_time);

              IF p_extract_type <> '1PED' -- cutover/code extract (full profile)
              THEN
                ben_ext_thread.process
                   (errbuf                     => l_errbuff
                   ,retcode                    => l_retcode
                   ,p_benefit_action_id        => NULL
                   ,p_ext_dfn_id               => l_ext_dfn_id
                   ,p_effective_date           => l_eff_date
                   ,p_business_group_id        => p_business_group_id
                   ,p_penserv_date             => g_last_app_date        --for Bug 7358374
                   );
              ELSE -- (is = '1PED') -- periodic type

            -- Start 115.81
             -- start 115.84 7165575
              -- Modifed for 115.85
               IF  p_dfn_name = 'ADI'
               THEN
                  l_penserv_mode   := 'A' ;
               ELSE
                  l_penserv_mode   := 'Y';
               END IF;
                -- End 115.84
            -- End 115.81

            debug('p_dfn_name : ' || p_dfn_name );
            debug('l_penserv_mode : ' || l_penserv_mode );

                ben_ext_thread.process
                   (errbuf                     => l_errbuff
                   ,retcode                    => l_retcode
                   ,p_benefit_action_id        => NULL
                   ,p_ext_dfn_id               => l_ext_dfn_id
                   ,p_effective_date           => l_eff_date
                   ,p_business_group_id        => p_business_group_id
                   ,p_eff_start_date           => l_eff_start_date
                   ,p_eff_end_date             => l_eff_date
                   ,p_penserv_date             => g_last_app_date
                   ,p_penserv_mode             => l_penserv_mode
                   --,p_act_start_date           => hr_api.g_sot
                   --,p_act_end_date             => l_eff_date
                   );
              END IF; -- p_extract_type <> '1PED'
            END IF; -- p_execution_mode = '1REP'
          END IF; -- l_ext_dfn_id IS NOT NULL
        END IF; -- IF p_dfn_name = 'ACI' THEN

    END IF; -- IF p_submit_request_y_n = 'N'

 debug_exit(l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Error  in '||l_proc_name);
    RAISE;
END PQP_Penserver_Extract;



-- =============================================================================
-- This procedure gets control totals information
-- =============================================================================
PROCEDURE Get_Penserver_CntrlTtl_Process
           (errbuf                OUT NOCOPY  VARCHAR2
           ,retcode               OUT NOCOPY  VARCHAR2
           ,p_extract_type        IN     VARCHAR2 DEFAULT NULL
           ,p_parent_request_id       IN     NUMBER DEFAULT NULL
           ,p_parent_selected     IN     VARCHAR2 DEFAULT NULL
           ,p_ext_bdi_rslt_id     IN     NUMBER DEFAULT NULL
           ,p_ext_adi_rslt_id     IN     NUMBER DEFAULT NULL
               ,p_ext_sehi_rslt_id    IN     NUMBER DEFAULT NULL
           ,p_ext_sahi_rslt_id    IN     NUMBER DEFAULT NULL
           ,p_ext_ehi_rslt_id     IN     NUMBER DEFAULT NULL
           ,p_ext_ahi_rslt_id     IN     NUMBER DEFAULT NULL
               ,p_ext_bhi_rslt_id     IN     NUMBER DEFAULT NULL
           ,p_ext_wps_rslt_id     IN     NUMBER DEFAULT NULL
           ,p_ext_pthi_rslt_id    IN     NUMBER DEFAULT NULL
           ,p_ext_sthi_rslt_id    IN     NUMBER DEFAULT NULL
           ,p_ext_sthai_rslt_id   IN     NUMBER DEFAULT NULL
           ,p_business_group_id   IN     NUMBER
           ,p_year_end_close      IN     VARCHAR2 DEFAULT 'N'   -- For Nuvos Changes
           ) IS


CURSOR csr_get_ttl_rslt(c_ext_rslt_id    IN Number) IS
  SELECT val_01,val_02,val_03,val_04,val_05
    FROM ben_ext_rslt_dtl dtl
        ,ben_ext_rcd     rcd
   WHERE dtl.ext_rslt_id = c_ext_rslt_id
     AND dtl.ext_rcd_id  = rcd.ext_rcd_id
     AND rcd.rcd_type_cd = 'T';

CURSOR csr_get_rsltid (c_get_rsltid IN number) IS
SELECT req.request_id  req_id
        ,bba.pl_id             rslt_id
        ,bba.pgm_id      ext_dfn_id
        ,argument3     Execution_Mode
        ,argument5     Extract_Type
        ,argument6     Interface_File
          ,argument8     Extract_eff_date        --- For Nuvos
            ,request_date      req_date
    FROM  fnd_concurrent_requests req, ben_benefit_actions bba
    WHERE parent_request_id = c_get_rsltid
      AND bba.request_id = req.request_id
      AND bba.business_group_id = p_business_group_id;


  -- For Nuvos

  CURSOR csr_get_eff_date (c_ext_rslt_id IN number) IS
  SELECT argument8     Extract_eff_date        --- For Nuvos
    FROM fnd_concurrent_requests req ,ben_ext_rslt ben
   where req.request_id = ben.request_id
     and ben.ext_rslt_id = c_ext_rslt_id
     and ben.business_group_id = p_business_group_id;

   -- For Nuvos Earnings

  CURSOR csr_get_ern_ttl_rslt(c_ext_rslt_id    IN Number) IS
   SELECT  val_01 payhcnt,
          nvl(val_03,0) + nvl(val_04,0) pearntot,
          nvl(val_02,0) + nvl(val_05,0) + nvl(val_06,0) + nvl(val_07,0) + nvl(val_08,0) + nvl(val_09,0) + nvl(val_10,0) + nvl(val_11,0) + nvl(val_12,0) pdedstot
    FROM ben_ext_rslt_dtl dtl
        ,ben_ext_rcd     rcd
   WHERE dtl.ext_rslt_id = c_ext_rslt_id
     AND dtl.ext_rcd_id  = rcd.ext_rcd_id
     AND rcd.rcd_type_cd = 'T';



  l_ext_bdi_rslt_id        NUMBER;
  l_ext_adi_rslt_id        NUMBER;
  l_ext_sehi_rslt_id       NUMBER;
  l_ext_sahi_rslt_id       NUMBER;
  l_ext_ehi_rslt_id        NUMBER;
  l_ext_ahi_rslt_id        NUMBER;
  l_ext_bhi_rslt_id        NUMBER;
  l_ext_wps_rslt_id        NUMBER;
  l_ext_pthi_rslt_id       NUMBER;
  l_ext_sthi_rslt_id       NUMBER;
  l_ext_sthai_rslt_id      NUMBER;
  l_ext_date               DATE;

  l_total_amount            NUMBER;


  l_pay_point              VARCHAR2(15);
  l_column_separator       VARCHAR2(10):= ' , ';
  l_cntrl_tot              t_cntrl_tot;
  l_Basic_Data_Cnt         VARCHAR2(10);
  l_Service_Hist_Cnt       VARCHAR2(10);
  l_Salary_Hist_Cnt        VARCHAR2(10);
  l_Sal_hist_Nat_Pay_Cnt   VARCHAR2(16);
  l_Address_Data_Cnt       VARCHAR2(10);
  l_Earning_Hist_Cnt       VARCHAR2(10);
  l_Earning_Tot_Cnt        VARCHAR2(16);
  l_Bonus_Hist_Cnt         VARCHAR2(10);
  l_Bonus_Tot_Cnt          VARCHAR2(16);
  l_STA_Hist_Cnt           VARCHAR2(10);
  l_STA_Tot_AdjHrs_Cnt     VARCHAR2(16);
  l_STS_Hist_Cnt           VARCHAR2(10);
  l_STS_Tot_AdjHrs_Cnt     VARCHAR2(16);
  l_WPS_Hist_Cnt           VARCHAR2(10);
  l_WPS_Tot_Cnt            VARCHAR2(16);
  l_Allowance_Hist_Cnt     VARCHAR2(10);
  l_Allowance_Tot_Cnt      VARCHAR2(16);
  l_PTH_Hist_Cnt            VARCHAR2(10);
  l_Tot_Part_Time_Hours_Cnt VARCHAR2(16);

  -- For Nuvos
  l_Pay_Hist_Cnt            VARCHAR2(10);
  l_Pay_Tot_EARN_Cnt        VARCHAR2(16);
  l_Pay_Tot_DEDS_Cnt        VARCHAR2(16);



  l_proc_name              VARCHAR2(200):= g_proc_name || 'Get_Penserver_CntrlTtl_Process';

  l_get_ttl_rslt           csr_get_ttl_rslt%ROWTYPE;   -- to fetch from the cursor.
  l_get_rsltid             csr_get_rsltid%ROWTYPE;
  l_ext_dfn_id             NUMBER;
  l_run_date               DATE;
  l_year_close             VARCHAR2(4);    -- For Nuvos
  l_per_end_date           DATE;           -- For Nuvos
  l_eff_date_arg8          VARCHAR2(30);   -- For Nuvos
  l_get_ern_ttl_rslt           csr_get_ern_ttl_rslt%ROWTYPE;  -- For Nuvos


BEGIN


  hr_utility.set_location('p_ext_ehi_rslt_id: ' || p_ext_ehi_rslt_id, 10);
  -- check for enabling trace
  g_debug         :=  pqp_gb_psi_functions.check_debug(p_business_group_id);

  l_ext_bdi_rslt_id   :=         p_ext_bdi_rslt_id;
  l_ext_adi_rslt_id   :=         p_ext_adi_rslt_id;
  l_ext_sehi_rslt_id  :=         p_ext_sehi_rslt_id;
  l_ext_sahi_rslt_id  :=         p_ext_sahi_rslt_id;
  l_ext_ehi_rslt_id   :=         p_ext_ehi_rslt_id;
  l_ext_ahi_rslt_id   :=         p_ext_ahi_rslt_id;
  l_ext_bhi_rslt_id   :=         p_ext_bhi_rslt_id;
  l_ext_wps_rslt_id   :=         p_ext_wps_rslt_id;
  l_ext_pthi_rslt_id  :=         p_ext_pthi_rslt_id;
  l_ext_sthi_rslt_id  :=         p_ext_sthi_rslt_id;
  l_ext_sthai_rslt_id :=         p_ext_sthai_rslt_id;
  l_ext_date          :=         sysdate;

  debug_enter(l_proc_name);

  Build_Metadata_Ext_Names;

  -- get paypoint value for business group id passed
  l_pay_point := paypoint(p_business_group_id);
  debug ('l_pay_point:'||l_pay_point);

  IF l_pay_point = ''
     or
     NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> l_pay_point)
  THEN
    -- Raise error as Paypoint is unknown(E)
    hr_utility.set_message(805, 'BEN_94453_INV_PAYPOINT');
    fnd_file.put_line(fnd_file.LOG
                         , RPAD('Error', 30) || ': ' || hr_utility.get_message);
    fnd_file.put_line(fnd_file.LOG, ' ');
  END IF;


  debug('p_parent_request_id ' || p_parent_request_id, 20);
  -- If parent request id is supplied instead of individual result ids.

  IF p_parent_request_id IS NOT NULL THEN
      OPEN csr_get_rsltid(c_get_rsltid=>p_parent_request_id);
      LOOP
          FETCH csr_get_rsltid INTO l_get_rsltid;
          EXIT WHEN csr_get_rsltid%NOTFOUND;
            l_ext_date := l_get_rsltid.req_date;
              l_per_end_date := fnd_date.canonical_to_date(l_get_rsltid.Extract_eff_date);  -- For Nuvos change
            hr_utility.set_location('l_per_end_date: ' || l_per_end_date, 10);
            IF l_get_rsltid.Interface_File = g_periodic_ext_names(1).extract_code THEN
               l_ext_bdi_rslt_id  := l_get_rsltid.rslt_id;  -- dbms_output.put_line(l_ext_bdi_rslt_id);
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 20);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(2).extract_code THEN
               l_ext_adi_rslt_id  := l_get_rsltid.rslt_id;  -- dbms_output.put_line(l_ext_adi_rslt_id);
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 30);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(3).extract_code THEN
               l_ext_sehi_rslt_id  := l_get_rsltid.rslt_id; -- dbms_output.put_line(l_ext_sehi_rslt_id);
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 40);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(4).extract_code THEN
               l_ext_pthi_rslt_id  := l_get_rsltid.rslt_id;
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 50);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(5).extract_code THEN
               l_ext_sthi_rslt_id  := l_get_rsltid.rslt_id;
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 60);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(6).extract_code THEN
               l_ext_sthai_rslt_id := l_get_rsltid.rslt_id;
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 70);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(7).extract_code THEN
               l_ext_sahi_rslt_id  := l_get_rsltid.rslt_id; -- dbms_output.put_line(l_ext_sahi_rslt_id);
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 80);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(8).extract_code THEN
               l_ext_ahi_rslt_id   := l_get_rsltid.rslt_id;
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 90);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(9).extract_code THEN
               l_ext_bhi_rslt_id   := l_get_rsltid.rslt_id;
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 100);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(10).extract_code THEN
               l_ext_ehi_rslt_id   := l_get_rsltid.rslt_id; -- dbms_output.put_line(l_ext_ehi_rslt_id);
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 110);
            ELSIF l_get_rsltid.Interface_File = g_periodic_ext_names(11).extract_code THEN
               l_ext_wps_rslt_id   := l_get_rsltid.rslt_id;
               debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 120);
            END IF;
      END LOOP;


    CLOSE csr_get_rsltid;

  debug('l_get_rsltid.rslt_id '|| l_get_rsltid.rslt_id, 125);
  END IF;

  hr_utility.set_location('l_ext_ehi_rslt_id: ' || l_ext_ehi_rslt_id, 30);
  --Basic Data interface Count
  IF l_ext_bdi_rslt_id IS NOT NULL THEN
    OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_bdi_rslt_id);
    FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
      IF csr_get_ttl_rslt%NOTFOUND
      THEN
        l_Basic_Data_Cnt := RPAD(' ',10,' ');
      ELSE
        l_Basic_Data_Cnt :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
      END IF;
    CLOSE csr_get_ttl_rslt;

    -- For Nuvos
    OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_bdi_rslt_id);
    FETCH csr_get_eff_date into l_eff_date_arg8;
       IF csr_get_eff_date%NOTFOUND
       THEN
          l_per_end_date := sysdate;
       ELSE
          l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
       END IF;
    CLOSE csr_get_eff_date;
  ELSE
    l_Basic_Data_Cnt := RPAD(' ',10,' ');
  END IF;


  --Address data interface Count

  IF l_ext_adi_rslt_id IS NOT NULL THEN
    OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_adi_rslt_id);
    FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
      IF csr_get_ttl_rslt%NOTFOUND
      THEN
        l_Address_Data_Cnt := RPAD(' ',10,' ');
      ELSE
        l_Address_Data_Cnt :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_03),'0999999999')));
      END IF;
    CLOSE csr_get_ttl_rslt;
     -- For Nuvos
    OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_adi_rslt_id);
    FETCH csr_get_eff_date into l_eff_date_arg8;
       IF csr_get_eff_date%NOTFOUND
       THEN
          l_per_end_date := sysdate;
       ELSE
          l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
       END IF;
    CLOSE csr_get_eff_date;
  ELSE
    l_Address_Data_Cnt := RPAD(' ',10,' ');
  END IF;


 --Salary History interface Count

 IF l_ext_sahi_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_sahi_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_Salary_Hist_Cnt      := RPAD(' ',10,' ');
       l_Sal_hist_Nat_Pay_Cnt := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ttl_rslt.val_01 IS NOT NULL THEN
         l_Salary_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
       ELSE
         l_Salary_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ttl_rslt.val_02 IS NOT NULL THEN

          l_total_amount  :=  fnd_number.canonical_to_number(l_get_ttl_rslt.val_02);
          IF l_total_amount < 0 THEN
              l_Sal_hist_Nat_Pay_Cnt:=rtrim(ltrim(to_char(l_total_amount,'S099999999999.99')));
          ELSE
              l_Sal_hist_Nat_Pay_Cnt:=rtrim(ltrim(to_char(l_total_amount,'0999999999999.99')));
          END IF;

       ELSE
         l_Sal_hist_Nat_Pay_Cnt := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ttl_rslt;
   -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_sahi_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;

 ELSE
   l_Salary_Hist_Cnt      := RPAD(' ',10,' ');
   l_Sal_hist_Nat_Pay_Cnt := RPAD(' ',16,' ');
 END IF;

 debug(l_Salary_Hist_Cnt);
 debug(l_Sal_hist_Nat_Pay_Cnt);
 debug(l_ext_sahi_rslt_id);


 --Service History interface Count
 IF l_ext_sehi_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_sehi_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_Service_Hist_Cnt := RPAD(' ',10,' ');
     ELSE
       l_Service_Hist_Cnt :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
     END IF;
   CLOSE csr_get_ttl_rslt;
   -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_sehi_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;
 ELSE
   l_Service_Hist_Cnt := RPAD(' ',10,' ');
 END IF;
 debug(l_Service_Hist_Cnt);
 debug(l_ext_sehi_rslt_id);

 /*--Earning History interface Count
    -- commented for nuvos changes
 IF l_ext_ehi_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_ehi_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_Earning_Hist_Cnt      := RPAD(' ',10,' ');
       l_Earning_Tot_Cnt       := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ttl_rslt.val_01 IS NOT NULL THEN
         l_Earning_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
       ELSE
         l_Earning_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ttl_rslt.val_02 IS NOT NULL THEN

          l_total_amount  :=  fnd_number.canonical_to_number(l_get_ttl_rslt.val_02);
          IF l_total_amount < 0 THEN
              l_Earning_Tot_Cnt:=rtrim(ltrim(to_char(l_total_amount,'S099999999999.99')));
          ELSE
              l_Earning_Tot_Cnt:=rtrim(ltrim(to_char(l_total_amount,'0999999999999.99')));
          END IF;

            -- l_Earning_Tot_Cnt      :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'0999999999999.99')));
       ELSE
         l_Earning_Tot_Cnt       := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ttl_rslt;

   -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_ehi_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;
   hr_utility.set_location('l_per_end_date: '||l_per_end_date,64);
 ELSE
   l_Earning_Hist_Cnt      := RPAD(' ',10,' ');
   l_Earning_Tot_Cnt       := RPAD(' ',16,' ');
 END IF;

   debug(l_Earning_Hist_Cnt);
   debug(l_Earning_Tot_Cnt);
   debug(l_ext_ehi_rslt_id);  */

   --Earning History interface Count
 IF l_ext_ehi_rslt_id IS NOT NULL THEN
   OPEN csr_get_ern_ttl_rslt(c_ext_rslt_id => l_ext_ehi_rslt_id);
   FETCH csr_get_ern_ttl_rslt INTO l_get_ern_ttl_rslt;
     IF csr_get_ern_ttl_rslt%NOTFOUND
     THEN
       l_Pay_Hist_Cnt          := RPAD(' ',10,' ');
       l_Pay_Tot_EARN_Cnt      := RPAD(' ',16,' ');
       l_Pay_Tot_DEDS_Cnt      := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ern_ttl_rslt.payhcnt IS NOT NULL THEN
         l_Pay_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ern_ttl_rslt.payhcnt),'0999999999')));
       ELSE
         l_Pay_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ern_ttl_rslt.pearntot IS NOT NULL THEN

          l_total_amount  :=  fnd_number.canonical_to_number(l_get_ern_ttl_rslt.pearntot);
          IF l_total_amount < 0 THEN
              l_Pay_Tot_EARN_Cnt:=rtrim(ltrim(to_char(l_total_amount,'S099999999999.99')));
          ELSE
              l_Pay_Tot_EARN_Cnt:=rtrim(ltrim(to_char(l_total_amount,'0999999999999.99')));
          END IF;

            -- l_Earning_Tot_Cnt      :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'0999999999999.99')));
       ELSE
         l_Pay_Tot_EARN_Cnt       := RPAD(' ',16,' ');
       END IF;
       IF l_get_ern_ttl_rslt.pdedstot IS NOT NULL THEN

          l_total_amount  :=  fnd_number.canonical_to_number(l_get_ern_ttl_rslt.pdedstot);
          IF l_total_amount < 0 THEN
              l_Pay_Tot_DEDS_Cnt:=rtrim(ltrim(to_char(l_total_amount,'S099999999999.99')));
          ELSE
              l_Pay_Tot_DEDS_Cnt:=rtrim(ltrim(to_char(l_total_amount,'0999999999999.99')));
          END IF;

            -- l_Earning_Tot_Cnt      :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'0999999999999.99')));
       ELSE
         l_Pay_Tot_DEDS_Cnt       := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ern_ttl_rslt;

   -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_ehi_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
       hr_utility.set_location('l_eff_date_arg8'|| l_eff_date_arg8,31);
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;
   hr_utility.set_location('l_per_end_date: '||l_per_end_date,64);
 ELSE
   l_Pay_Hist_Cnt      := RPAD(' ',10,' ');
   l_Pay_Tot_EARN_Cnt       := RPAD(' ',16,' ');
   l_Pay_Tot_DEDS_Cnt       := RPAD(' ',16,' ');
 END IF;

   debug(l_Pay_Hist_Cnt);
   debug(l_Pay_Tot_EARN_Cnt);
   debug(l_Pay_Tot_DEDS_Cnt);
   debug(l_ext_ehi_rslt_id);


  --Bonus History interface Count

 IF l_ext_bhi_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_bhi_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_Bonus_Hist_Cnt      := RPAD(' ',10,' ');
       l_Bonus_Tot_Cnt := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ttl_rslt.val_01 IS NOT NULL THEN
         l_Bonus_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
       ELSE
         l_Bonus_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ttl_rslt.val_02 IS NOT NULL THEN

          l_total_amount  :=  fnd_number.canonical_to_number(l_get_ttl_rslt.val_02);
          IF l_total_amount < 0 THEN
              l_Bonus_Tot_Cnt:=rtrim(ltrim(to_char(l_total_amount,'S099999999999.99')));
          ELSE
              l_Bonus_Tot_Cnt:=rtrim(ltrim(to_char(l_total_amount,'0999999999999.99')));
          END IF;

          -- l_Bonus_Tot_Cnt:=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'0999999999999.99')));
       ELSE
         l_Bonus_Tot_Cnt := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ttl_rslt;
   -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_bhi_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;

 ELSE
   l_Bonus_Hist_Cnt      := RPAD(' ',10,' ');
   l_Bonus_Tot_Cnt := RPAD(' ',16,' ');
 END IF;

 debug(l_Bonus_Hist_Cnt);
 debug(l_Bonus_Tot_Cnt);
 debug(l_ext_bhi_rslt_id);

 --WPS History interface Count

 IF l_ext_wps_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_wps_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_WPS_Hist_Cnt      := RPAD(' ',10,' ');
       l_WPS_Tot_Cnt := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ttl_rslt.val_01 IS NOT NULL THEN
         l_WPS_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
       ELSE
         l_WPS_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ttl_rslt.val_02 IS NOT NULL THEN

          l_total_amount  :=  fnd_number.canonical_to_number(l_get_ttl_rslt.val_02);
          IF l_total_amount < 0 THEN
              l_WPS_Tot_Cnt:=rtrim(ltrim(to_char(l_total_amount,'S099999999999.99')));
          ELSE
              l_WPS_Tot_Cnt:=rtrim(ltrim(to_char(l_total_amount,'0999999999999.99')));
          END IF;

          -- l_WPS_Tot_Cnt:=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'0999999999999.99')));
       ELSE
         l_WPS_Tot_Cnt := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ttl_rslt;
  -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_wps_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;

 ELSE
   l_WPS_Hist_Cnt      := RPAD(' ',10,' ');
   l_WPS_Tot_Cnt := RPAD(' ',16,' ');
 END IF;

 debug(l_WPS_Hist_Cnt);
 debug(l_WPS_Tot_Cnt);
 debug(l_ext_wps_rslt_id);

 --Short-Time Hours ( Accumulated ) History interface Count

 IF l_ext_sthai_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_sthai_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_STA_Hist_Cnt      := RPAD(' ',10,' ');
       l_STA_Tot_AdjHrs_Cnt := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ttl_rslt.val_01 IS NOT NULL THEN
         l_STA_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
       ELSE
         l_STA_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ttl_rslt.val_02 IS NOT NULL THEN
         l_STA_Tot_AdjHrs_Cnt:=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'S099999999999D99')));
       ELSE
         l_STA_Tot_AdjHrs_Cnt := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ttl_rslt;
  -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_sthai_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;

 ELSE
   l_STA_Hist_Cnt      := RPAD(' ',10,' ');
   l_STA_Tot_AdjHrs_Cnt := RPAD(' ',16,' ');
 END IF;

 debug(l_STA_Hist_Cnt);
 debug(l_STA_Tot_AdjHrs_Cnt);
 debug(l_ext_sthai_rslt_id);

 --Short-Time Hours ( Single ) History interface Count

 IF l_ext_sthi_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_sthi_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_STS_Hist_Cnt      := RPAD(' ',10,' ');
       l_STS_Tot_AdjHrs_Cnt := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ttl_rslt.val_01 IS NOT NULL THEN
         l_STS_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
       ELSE
         l_STS_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ttl_rslt.val_02 IS NOT NULL THEN
         l_STS_Tot_AdjHrs_Cnt:=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'S099999999999D99')));
       ELSE
         l_STS_Tot_AdjHrs_Cnt := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ttl_rslt;
  -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_sthi_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;

 ELSE
   l_STS_Hist_Cnt      := RPAD(' ',10,' ');
   l_STS_Tot_AdjHrs_Cnt := RPAD(' ',16,' ');
 END IF;

 debug(l_STS_Hist_Cnt);
 debug(l_STS_Tot_AdjHrs_Cnt);
 debug(l_ext_sthi_rslt_id);

 --Allowance History interface Count

 IF l_ext_ahi_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_ahi_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_Allowance_Hist_Cnt      := RPAD(' ',10,' ');
       l_Allowance_Tot_Cnt := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ttl_rslt.val_01 IS NOT NULL THEN
         l_Allowance_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
       ELSE
         l_Allowance_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ttl_rslt.val_02 IS NOT NULL THEN

          l_total_amount  :=  fnd_number.canonical_to_number(l_get_ttl_rslt.val_02);
          IF l_total_amount < 0 THEN
              l_Allowance_Tot_Cnt:=rtrim(ltrim(to_char(l_total_amount,'S099999999999.99')));
          ELSE
              l_Allowance_Tot_Cnt:=rtrim(ltrim(to_char(l_total_amount,'0999999999999.99')));
          END IF;

          -- l_Allowance_Tot_Cnt:=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'0999999999999.99')));
       ELSE
         l_Allowance_Tot_Cnt := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ttl_rslt;
  -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_ahi_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;

 ELSE
   l_Allowance_Hist_Cnt      := RPAD(' ',10,' ');
   l_Allowance_Tot_Cnt := RPAD(' ',16,' ');
 END IF;

 debug(l_Allowance_Hist_Cnt);
 debug(l_Allowance_Tot_Cnt);
 debug(l_ext_ahi_rslt_id);


--Part-Time Hours ( Single ) History interface Count

 IF l_ext_pthi_rslt_id IS NOT NULL THEN
   OPEN csr_get_ttl_rslt(c_ext_rslt_id => l_ext_pthi_rslt_id);
   FETCH csr_get_ttl_rslt INTO l_get_ttl_rslt;
     IF csr_get_ttl_rslt%NOTFOUND
     THEN
       l_PTH_Hist_Cnt          := RPAD(' ',10,' ');
       l_Tot_Part_Time_Hours_Cnt := RPAD(' ',16,' ');
     ELSE
       --
       IF l_get_ttl_rslt.val_01 IS NOT NULL THEN
         l_PTH_Hist_Cnt     :=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_01),'0999999999')));
       ELSE
         l_PTH_Hist_Cnt      := RPAD(' ',10,' ');
       END IF;
       IF l_get_ttl_rslt.val_02 IS NOT NULL THEN
         l_Tot_Part_Time_Hours_Cnt:=rtrim(ltrim(to_char(fnd_number.canonical_to_number(l_get_ttl_rslt.val_02),'S099999999999D99')));
       ELSE
         l_Tot_Part_Time_Hours_Cnt := RPAD(' ',16,' ');
       END IF;
       --
     END IF;
   CLOSE csr_get_ttl_rslt;
   -- For Nuvos
   OPEN csr_get_eff_date(c_ext_rslt_id => l_ext_pthi_rslt_id);
   FETCH csr_get_eff_date into l_eff_date_arg8;
      IF csr_get_eff_date%NOTFOUND
      THEN
        l_per_end_date := sysdate;
      ELSE
         l_per_end_date := fnd_date.canonical_to_date(l_eff_date_arg8);
      END IF;
   CLOSE csr_get_eff_date;

 ELSE
   l_PTH_Hist_Cnt      := RPAD(' ',10,' ');
   l_Tot_Part_Time_Hours_Cnt := RPAD(' ',16,' ');
 END IF;

 debug(l_PTH_Hist_Cnt);
 debug(l_Tot_Part_Time_Hours_Cnt);
 debug(l_ext_pthi_rslt_id);


-----------

     OPEN csr_ext_dfn_id(c_extract_name => 'PQP GB PenServer Periodic Changes Interface - Basic Data');
     FETCH csr_ext_dfn_id INTO l_ext_dfn_id;
     CLOSE csr_ext_dfn_id;

     -- Get the run date
     OPEN csr_get_run_date(c_ext_dfn_id         => l_ext_dfn_id
                          ,c_business_group_id  => p_business_group_id);
     FETCH csr_get_run_date INTO l_run_date,g_output_name;
     CLOSE csr_get_run_date;


   IF p_extract_type = '3CUT' THEN
     l_cntrl_tot(1).seq_num := '001';
   ELSE
     IF g_output_name IS NULL THEN
       l_cntrl_tot(1).seq_num := '002';
     ELSE
       IF p_parent_request_id IS NULL THEN
         l_cntrl_tot(1).seq_num := rtrim(ltrim(to_char(fnd_number.canonical_to_number(substr(g_output_name,INSTR(g_output_name,'.')+1))+1,'099')));
       ELSE
         l_cntrl_tot(1).seq_num := rtrim(ltrim(to_char(fnd_number.canonical_to_number(substr(g_output_name,INSTR(g_output_name,'.')+1)),'099')));
       END IF;
     END IF;
   END IF;

------------
 hr_utility.set_location('l_year_close1: ' || l_year_close , 11);
 hr_utility.set_location('p_year_end_close: ' || p_year_end_close , 11);

/* For Nuvps */
   IF p_year_end_close = 'Yes'
   THEN

       IF l_per_end_date between to_date('01-04-'||to_char(l_per_end_date,'YYYY'),'DD-MM-YYYY') and to_date('31-12-'||to_char(l_per_end_date,'YYYY'),'DD-MM-YYYY')
      THEN
         l_year_close := to_number(to_char(l_per_end_date,'yyyy'));

      ELSE

         l_year_close := to_number(to_char(l_per_end_date,'yyyy')) -1;

      END IF;
   ELSE
      l_year_close := RPAD(' ' ,4,' ');

   END IF;

   l_per_end_date := last_day(l_per_end_date);
   hr_utility.set_location('l_per_end_date: ' || l_per_end_date, 20);
   hr_utility.set_location('l_year_close6: ' || l_year_close , 11);

   l_Earning_Hist_Cnt      := RPAD(' ',10,' ');
   l_Earning_Tot_Cnt       := RPAD(' ',16,' ');



          l_cntrl_tot(1).pay_point                       :=RPAD(nvl(l_pay_point,' ') ,6,' ');
          l_cntrl_tot(1).file_extract_date               :=to_char(l_ext_date, 'DD/MM/YYYY HH24:MI');
        --Not done
          -- l_cntrl_tot(1).seq_num                         :=RPAD(' ',3,' ');
        --This one is related to Basic Data interface
          l_cntrl_tot(1).basic_cnt                       :=l_Basic_Data_Cnt;
        --This one is related to Service History interface
          l_cntrl_tot(1).serv_hist_cnt                   :=l_Service_Hist_Cnt;
        --These two are related to Salary History interface
          l_cntrl_tot(1).sal_hist_cnt                    :=l_Salary_Hist_Cnt;
          l_cntrl_tot(1).sal_hist_tot_national_pay       :=l_Sal_hist_Nat_Pay_Cnt;
    --This one is related to Address data interface
          l_cntrl_tot(1).addr_data_tot_rec               :=l_Address_Data_Cnt;
       --These two are related to Earnings History interface,Which is not done for this QA drop
          l_cntrl_tot(1).earn_hist_cnt                   :=l_Earning_Hist_Cnt;
          l_cntrl_tot(1).earn_hist_tot_WPS               :=l_Earning_Tot_Cnt;

    --All below fields are not either supported or building for this drop,so hardcoded the values

        --These two are related to Allowance History interface
          l_cntrl_tot(1).allw_hist_rec_cnt               :=l_Allowance_Hist_Cnt;
          l_cntrl_tot(1).allw_hist_tot_allw_rate         :=l_Allowance_Tot_Cnt;
        --These two are related to Bonus History interface
          l_cntrl_tot(1).bonus_hist_rec_cnt              := l_Bonus_Hist_Cnt;
          l_cntrl_tot(1).bonus_hist_tot_bonus_amt        := l_Bonus_Tot_Cnt;
        --These two are related to WPS Contributions History interface
          l_cntrl_tot(1).WPS_contrbt_hist_rec_cnt        := l_WPS_Hist_Cnt;
          l_cntrl_tot(1).WPS_contrbt_hist_tot_perc       := l_WPS_Tot_Cnt;
        --This left blank ,because we are  not building AVC History interface
          l_cntrl_tot(1).AVC_hist_rec_cnt                :=RPAD(' ' ,10,' ');
          l_cntrl_tot(1).EECONT_tot                      :=RPAD(' ' ,16,' ');
        --This left blank ,because we are  not building Transfer in and other benefits interface.
          l_cntrl_tot(1).other_benef_rec_cnt             :=RPAD(' ' ,10,' ');
          l_cntrl_tot(1).PUP_tot                         :=RPAD(' ' ,16,' ');
        --These two are related to Part-time Hours History interface,Which is not done for this QA drop
          l_cntrl_tot(1).prt_tm_hr_hist_rec_cnt          :=l_PTH_Hist_Cnt;
          l_cntrl_tot(1).prt_tm_hr_hist_tot_pthrs        :=l_Tot_Part_Time_Hours_Cnt;
        --These two are related to Short-time Hours History (Single record)
          l_cntrl_tot(1).srt_tm_hr_hist_sing_rec_cnt     := l_STS_Hist_Cnt;
          l_cntrl_tot(1).srt_tm_hr_hist_sing_tot_hr_var  := l_STS_Tot_AdjHrs_Cnt;
        --These two are related to Short-time Hours History (Accumulated record)
          l_cntrl_tot(1).srt_tm_hr_hist_accu_rec_cnt     := l_STA_Hist_Cnt;
          l_cntrl_tot(1).srt_tm_hr_hist_accu_tot_hr_var  := l_STA_Tot_AdjHrs_Cnt;
        --This left blank ,because we are  not building Dated Event Details interface
          l_cntrl_tot(1).event_det_tot_rec               :=RPAD(' ' ,10,' ');
          l_cntrl_tot(1).event_det_tot_amt               :=RPAD(' ' ,16,' ');
        --This left blank ,because we are  not building Remarks interface interface
          l_cntrl_tot(1).remarks_interface_tot_rec       :=RPAD(' ' ,10,' ');
        --This left blank ,because we are  not building Beneficiary Details interface
          l_cntrl_tot(1).benef_det_tot_rec               :=RPAD(' ' ,10,' ');
       -- Nuvos Pay file
          l_cntrl_tot(1).pay_hist_cnt                   :=l_Pay_Hist_Cnt;
          l_cntrl_tot(1).pay_hist_tot_EARN              :=l_Pay_Tot_EARN_Cnt;
          l_cntrl_tot(1).pay_hist_tot_DEDS              :=l_Pay_Tot_DEDS_Cnt;
         -- For Nuvos
          l_cntrl_tot(1).year_end_close                  :=l_year_close;
          l_cntrl_tot(1).pay_per_end_date                :=substr(to_char(l_per_end_date, 'DD/MM/YYYY HH24:MI'),1,10);


      /*  --These two are related to Earnings History interface,Which is not done for this QA drop
          l_cntrl_tot(1).earn_hist_cnt                   :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).earn_hist_tot_WPS               :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --These two are related to Allowance History interface,Which is not done for this QA drop
          l_cntrl_tot(1).allw_hist_rec_cnt               :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).allw_hist_tot_allw_rate         :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --These two are related to Allowance History interface,Which is not done for this QA drop
          l_cntrl_tot(1).bonus_hist_rec_cnt              :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).bonus_hist_tot_bonus_amt        :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --These two are related to WPS Contributions History interface,Which is not done for this QA drop
          l_cntrl_tot(1).WPS_contrbt_hist_rec_cnt        :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).WPS_contrbt_hist_tot_perc       :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --This left blank ,because we are  not building AVC History interface
          l_cntrl_tot(1).AVC_hist_rec_cnt                :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).EECONT_tot                      :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --This left blank ,because we are  not building Transfer in and other benefits interface.
          l_cntrl_tot(1).other_benef_rec_cnt             :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).PUP_tot                         :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --These two are related to Part-time Hours History interface,Which is not done for this QA drop
          l_cntrl_tot(1).prt_tm_hr_hist_rec_cnt          :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).prt_tm_hr_hist_tot_pthrs    :=rtrim(ltrim(to_char(0, '0999999999999999')));
        --These two are related to Short-time Hours History (Single record),Which is not done for this QA drop
          l_cntrl_tot(1).srt_tm_hr_hist_sing_rec_cnt     :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).srt_tm_hr_hist_sing_tot_hr_var  :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --These two are related to Short-time Hours History (Accumulated record),Which is not done for this QA drop
          l_cntrl_tot(1).srt_tm_hr_hist_accu_rec_cnt     :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).srt_tm_hr_hist_accu_tot_hr_var  :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --This left blank ,because we are  not building Dated Event Details interface
          l_cntrl_tot(1).event_det_tot_rec               :=rtrim(ltrim(to_char(0, '0999999999')));
          l_cntrl_tot(1).event_det_tot_amt               :=rtrim(ltrim(to_char(0, '0999999999999999V99')));
        --This left blank ,because we are  not building Remarks interface interface
          l_cntrl_tot(1).remarks_interface_tot_rec       :=rtrim(ltrim(to_char(0, '0999999999')));
        --This left blank ,because we are  not building Beneficiary Details interface
          l_cntrl_tot(1).benef_det_tot_rec               :=rtrim(ltrim(to_char(0, '0999999999'))); */

  debug ('Before writing into file');
  -- insert control totals information into output file
        fnd_file.put_line(fnd_file.output,
                         l_cntrl_tot(1).pay_point ||
                         l_cntrl_tot(1).file_extract_date ||
                         l_cntrl_tot(1).seq_num ||
                         l_cntrl_tot(1).basic_cnt ||
                         l_cntrl_tot(1).serv_hist_cnt ||
                         l_cntrl_tot(1).earn_hist_cnt ||
                         l_cntrl_tot(1).earn_hist_tot_WPS ||
                         l_cntrl_tot(1).sal_hist_cnt ||
                         l_cntrl_tot(1).sal_hist_tot_national_pay ||
                         l_cntrl_tot(1).allw_hist_rec_cnt ||
                         l_cntrl_tot(1).allw_hist_tot_allw_rate ||
                         l_cntrl_tot(1).bonus_hist_rec_cnt ||
                         l_cntrl_tot(1).bonus_hist_tot_bonus_amt ||
                         l_cntrl_tot(1).WPS_contrbt_hist_rec_cnt ||
                         l_cntrl_tot(1).WPS_contrbt_hist_tot_perc ||
                         l_cntrl_tot(1).AVC_hist_rec_cnt ||
                         l_cntrl_tot(1).EECONT_tot ||
                         l_cntrl_tot(1).other_benef_rec_cnt ||
                         l_cntrl_tot(1).PUP_tot ||
                         l_cntrl_tot(1).prt_tm_hr_hist_rec_cnt ||
                         l_cntrl_tot(1).prt_tm_hr_hist_tot_pthrs ||
                         l_cntrl_tot(1).srt_tm_hr_hist_sing_rec_cnt ||
                         l_cntrl_tot(1).srt_tm_hr_hist_sing_tot_hr_var ||
                         l_cntrl_tot(1).srt_tm_hr_hist_accu_rec_cnt ||
                         l_cntrl_tot(1).srt_tm_hr_hist_accu_tot_hr_var ||
                         l_cntrl_tot(1).event_det_tot_rec ||
                         l_cntrl_tot(1).event_det_tot_amt ||
                         l_cntrl_tot(1).remarks_interface_tot_rec ||
                         l_cntrl_tot(1).addr_data_tot_rec ||
                         l_cntrl_tot(1).benef_det_tot_rec ||
                         l_cntrl_tot(1).pay_hist_cnt ||
                         l_cntrl_tot(1).pay_hist_tot_EARN ||
                         l_cntrl_tot(1).pay_hist_tot_DEDS ||
                               l_cntrl_tot(1).year_end_close ||       -- for nuvos
                               l_cntrl_tot(1).pay_per_end_date);


        debug(' file content : ' || l_cntrl_tot(1).pay_point ||
                         l_cntrl_tot(1).file_extract_date ||
                         l_cntrl_tot(1).seq_num ||
                         l_cntrl_tot(1).basic_cnt ||
                         l_cntrl_tot(1).serv_hist_cnt ||
                         l_cntrl_tot(1).earn_hist_cnt ||
                         l_cntrl_tot(1).earn_hist_tot_WPS ||
                         l_cntrl_tot(1).sal_hist_cnt ||
                         l_cntrl_tot(1).sal_hist_tot_national_pay ||
                         l_cntrl_tot(1).allw_hist_rec_cnt ||
                         l_cntrl_tot(1).allw_hist_tot_allw_rate ||
                         l_cntrl_tot(1).bonus_hist_rec_cnt ||
                         l_cntrl_tot(1).bonus_hist_tot_bonus_amt ||
                         l_cntrl_tot(1).WPS_contrbt_hist_rec_cnt ||
                         l_cntrl_tot(1).WPS_contrbt_hist_tot_perc ||
                         l_cntrl_tot(1).AVC_hist_rec_cnt ||
                         l_cntrl_tot(1).EECONT_tot ||
                         l_cntrl_tot(1).other_benef_rec_cnt ||
                         l_cntrl_tot(1).PUP_tot ||
                         l_cntrl_tot(1).prt_tm_hr_hist_rec_cnt ||
                         l_cntrl_tot(1).prt_tm_hr_hist_tot_pthrs ||
                         l_cntrl_tot(1).srt_tm_hr_hist_sing_rec_cnt ||
                         l_cntrl_tot(1).srt_tm_hr_hist_sing_tot_hr_var ||
                         l_cntrl_tot(1).srt_tm_hr_hist_accu_rec_cnt ||
                         l_cntrl_tot(1).srt_tm_hr_hist_accu_tot_hr_var ||
                         l_cntrl_tot(1).event_det_tot_rec ||
                         l_cntrl_tot(1).event_det_tot_amt ||
                         l_cntrl_tot(1).remarks_interface_tot_rec ||
                         l_cntrl_tot(1).addr_data_tot_rec ||
                         l_cntrl_tot(1).benef_det_tot_rec ||
                         l_cntrl_tot(1).pay_hist_cnt ||
                         l_cntrl_tot(1).pay_hist_tot_EARN ||
                         l_cntrl_tot(1).pay_hist_tot_DEDS ||
                         l_cntrl_tot(1).year_end_close ||    -- for nuvos
                         l_cntrl_tot(1).pay_per_end_date);


 debug_exit(l_proc_name);
 EXCEPTION
      WHEN OTHERS  THEN
      debug_exit(' Error  in '||l_proc_name);
      RAISE;
  END Get_Penserver_CntrlTtl_Process;

-- ----------------------------------------------------------------------------
-- |--------------------------------< employer_code >-------------------------|
-- ----------------------------------------------------------------------------

  FUNCTION employer_code
      (p_business_group_id       NUMBER
      ,p_effective_date          DATE
      ,p_assignment_id           NUMBER
      ) RETURN VARCHAR2
  IS
     -- Cursor to get assignment details
     CURSOR csr_get_org_id(c_basic_date DATE)
     IS
     SELECT organization_id
       FROM per_all_assignments_f
      WHERE assignment_id = p_assignment_id
        AND c_basic_date BETWEEN effective_start_date
                                 AND effective_end_date;

     -- Cursor to get employer code
     CURSOR csr_get_emp_code (c_organization_id NUMBER)
     IS
     SELECT org_information1
       FROM hr_organization_information
      WHERE organization_id = c_organization_id
        AND org_information_context = 'PQP_GB_PENSERV_REPORTING_INFO';

     l_proc_name           VARCHAR2(61):=
     g_proc_name||'employer_code';

    l_org_id       NUMBER;
    l_employer_code hr_organization_information.org_information1%TYPE;
    l_value        NUMBER;
    --115.85
    l_basic_date   DATE;

    --115.87/115.88:Bug 7291713: Start
    CURSOR csr_get_bas_ext_dfn_id
    IS
      SELECT ext_dfn_id
      FROM BEN_EXT_DFN
      WHERE name = 'PQP GB PenServer Periodic Changes Interface - Basic Data'
      AND legislation_code ='GB';

    CURSOR csr_get_max_asg_end_date
    IS
      SELECT max(effective_end_date)
      FROM per_all_assignments_f
      WHERE assignment_id = p_assignment_id;

    l_max_asg_end_date  DATE;
    l_bas_ext_dfn_id    NUMBER;
    --115.87/115.88:Bug 7291713: Stop

  BEGIN
  --
    debug_enter(l_proc_name);
  -- 115.85

  --115.88:Bug 7291713: Start
    OPEN csr_get_bas_ext_dfn_id;
    FETCH csr_get_bas_ext_dfn_id INTO l_bas_ext_dfn_id;
    CLOSE csr_get_bas_ext_dfn_id;

    debug('l_bas_ext_dfn_id: '|| l_bas_ext_dfn_id);
    debug('ben_ext_thread.g_ext_dfn_id: '|| ben_ext_thread.g_ext_dfn_id);

    IF l_bas_ext_dfn_id = ben_ext_thread.g_ext_dfn_id
  --115.88:Bug 7291713: Stop
    THEN

       --115.87:Bug 7291713: Start
       OPEN csr_get_max_asg_end_date;
       FETCH csr_get_max_asg_end_date INTO l_max_asg_end_date;
       CLOSE csr_get_max_asg_end_date;

       debug('ben_ext_person.g_effective_date: '|| ben_ext_person.g_effective_date);

       IF l_max_asg_end_date < ben_ext_person.g_effective_date
       THEN
           l_basic_date := l_max_asg_end_date;
       ELSE
            l_basic_date := ben_ext_person.g_effective_date;
       END IF;
    --115.87:Bug 7291713: Stop

    ELSE --g_dfn_name <> 'BDI'
       l_basic_date := p_effective_date;
    END IF;

    debug('g_dfn_name : '|| g_dfn_name);
    debug('l_basic_date : '|| l_basic_date);

    OPEN csr_get_org_id(l_basic_date);
    FETCH csr_get_org_id INTO l_org_id;
    CLOSE csr_get_org_id;

    -- If employer code exists for this organization
    -- return it from collection otherwise fetch and
    -- store in the collection
    IF g_employer_code.EXISTS(l_org_id) THEN
      l_employer_code := g_employer_code(l_org_id);
    ELSE
      l_employer_code := NULL;
      OPEN csr_get_emp_code(l_org_id);
      FETCH csr_get_emp_code INTO l_employer_code;
      IF csr_get_emp_code%NOTFOUND OR
         l_employer_code IS NULL
      THEN
        -- store error
        l_value := raise_extract_error
                     (p_error_number        =>    92369
                     ,p_error_text          =>    'BEN_92369_EXT_PSI_NO_EMP_CODE'
                     );
      ELSE -- employer code information found
        g_employer_code(l_org_id) := l_employer_code;
      END IF;
      CLOSE csr_get_emp_code;
    END IF; -- End if of code exists in collection check ...

    debug('Employer Code: '|| l_employer_code);
    debug_exit(l_proc_name);

    RETURN l_employer_code;

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

  END employer_code;



-- ----------------------------------------------------------------------------
-- |--------------------------------< altkey >--------------------------------|
-- ----------------------------------------------------------------------------

  FUNCTION altkey
    --(p_assignment_number IN     VARCHAR2 -- context
    --,p_paypoint          IN     VARCHAR2 -- context
    --)
    RETURN VARCHAR2
  IS
    l_proc_name           VARCHAR2(61):=
     g_proc_name||'altkey';

    l_return       VARCHAR2(20);
    CURSOR csr_get_assignment_number
    IS
        SELECT assignment_number
        FROM per_all_assignments_f
        WHERE assignment_id = g_assignment_id
        AND g_effective_date BETWEEN effective_start_date
                             AND effective_end_date;

  BEGIN
  --
    debug_enter(l_proc_name);
    debug('g_paypoint : '||g_paypoint,10);
    debug('g_assignment_number : '||g_assignment_number,20);

    -- added by kkarri
    -- g_assignment_number will be set in basic criteria
    -- but for bonus history the basic criteria will be called
    -- for claim date. When a claim date is invalid, assignment_number
    -- will remain null.
    IF g_assignment_number IS NULL THEN
        DEBUG('assignment_number NOT FOUND',30);
        DEBUG('g_effective_date'||g_effective_date,30);
        OPEN csr_get_assignment_number;
        FETCH csr_get_assignment_number INTO g_assignment_number;
        CLOSE csr_get_assignment_number;

        g_assignment_number := TRIM(REPLACE(g_assignment_number,'-',''));

        debug('g_assignment_number : '||g_assignment_number,30);
    END IF;

    l_return := g_paypoint || g_assignment_number;
    debug('l_return : '||l_return,30);
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

  END altkey;



-- ----------------------------------------------------------------------------
-- |--------------------------------< paypoint >--------------------------------|
-- ----------------------------------------------------------------------------

  FUNCTION paypoint
    (p_business_group_id IN     VARCHAR2 -- context
    )
    RETURN VARCHAR2
  IS
    l_proc_name           VARCHAR2(61):=
     g_proc_name||'paypoint';

    l_config_value        pqp_utilities.t_config_values;
    l_return              VARCHAR2(20);

  BEGIN
  --
    debug_enter(l_proc_name);


    IF g_paypoint IS NULL -- 115.58 (4)
    THEN
      -- fetch configuration value for paypoint
      debug('Fetching configuration value for paypoint ...', 20);
        pqp_utilities.get_config_type_values
             ( p_configuration_type   => 'PQP_GB_PENSERVER_PAYPOINT_INFO'
              ,p_business_group_id    => p_business_group_id
              ,p_legislation_code     => NULL
              ,p_tab_config_values    => l_config_value
             );

      IF l_config_value.COUNT > 0 -- config value found
      THEN
        g_paypoint := l_config_value(l_config_value.FIRST).pcv_information1;

      ELSE
      -- ERR store error

        g_paypoint := '';
      END IF;

    END IF;

    debug_exit(l_proc_name);

    RETURN g_paypoint;

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

  END paypoint;




/*

-- ----------------------------------------------------------------------------
-- |------------------------< exclude_errored_people >-------------------------------|
-- ----------------------------------------------------------------------------
-- procedure to mark errored persons as 'U' (unprocessed)


Procedure exclude_errored_people
          (p_business_group_id in number
          ) Is

  l_conc_reqest_id      Number(20);
  l_exists              Varchar2(2);

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'exclude_errored_people';

   l_ben_params             csr_ben%ROWTYPE;


   cursor csr_err_per_action_id
      (c_benefit_action_id IN NUMBER
      ,c_ext_rslt_id       IN NUMBER)

   IS
   select person_action_id
    from ben_person_actions bpa
   Where bpa.benefit_action_id = c_benefit_action_id
     and EXISTS
              ( SELECT ers.PERSON_ID
     FROM BEN_EXT_RSLT_ERR ers
     WHERE ers.person_id = bpa.person_id
        AND ers.EXT_RSLT_ID= c_ext_rslt_id
        AND typ_cd = 'E');


Begin

debug_enter(l_proc_name);


   OPEN csr_ben (c_ext_dfn_id        => Ben_Ext_Thread.g_ext_dfn_id
                ,c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
                ,c_business_group_id => p_business_group_id);
   Fetch csr_ben Into l_ben_params;
   CLOSE csr_ben;

   debug('l_ben_params.benefit_action_id :' || l_ben_params.benefit_action_id);


  Update ben_person_actions bpa
     Set bpa.action_status_cd = 'U'
   Where bpa.benefit_action_id = l_ben_params.benefit_action_id -- 3629 -- p_benefit_action_id
     and bpa.person_id  -- = p_person_id;
            IN ( SELECT PERSON_ID
     FROM BEN_EXT_RSLT_ERR
     WHERE EXT_RSLT_ID= Ben_Ext_Thread.g_ext_rslt_id -- 2891 -- c_ext_rslt_id
        AND typ_cd = 'E');

  Update ben_batch_ranges bbr
    set bbr.range_status_cd = 'E'
  Where bbr.benefit_action_id = l_ben_params.benefit_action_id
    AND EXISTS(
      Select 1 -- distinct(bere.person_id)
        From ben_person_actions bpa, BEN_EXT_RSLT_ERR bere
      Where bpa.benefit_action_id = l_ben_params.benefit_action_id
        AND bbr.benefit_action_id = bpa.benefit_action_id
        AND (bpa.person_action_id Between
             bbr.starting_person_action_id And bbr.ending_person_action_id)
        And bpa.person_id = bere.person_id
        AND bere.EXT_RSLT_ID= Ben_Ext_Thread.g_ext_rslt_id
        AND bere.typ_cd = 'E');

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
End exclude_errored_people;

*/

--
-- modified as part of 115.58 (1)
--
-- ----------------------------------------------------------------------------
-- |------------------------< exclude_errored_people >-------------------------------|
-- ----------------------------------------------------------------------------
-- procedure to mark errored persons as 'U' (unprocessed)


Procedure exclude_errored_people
          (p_business_group_id in number
          ) Is

  l_conc_reqest_id      Number(20);
  l_exists              Varchar2(2);

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'exclude_errored_people';

  CURSOR csr_err_person_id
        (p_ext_rslt_id       IN NUMBER)
  IS
  SELECT distinct(ers.PERSON_ID)
   FROM BEN_EXT_RSLT_ERR ers
   WHERE ers.EXT_RSLT_ID = p_ext_rslt_id
      AND typ_cd = 'E';

  CURSOR csr_range_id
         (p_person_action_id  IN NUMBER
         ,p_benefit_action_id IN NUMBER
         )
  IS
    SELECT bbr.range_id
    FROM ben_batch_ranges bbr
    WHERE bbr.benefit_action_id = p_benefit_action_id
      AND p_person_action_id Between
              bbr.starting_person_action_id And bbr.ending_person_action_id;

  TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_person_collection         t_number;
  l_RangeId_collection        t_number;
  l_per_action_id_collection  t_number;

  l_range_id  NUMBER;
  l_itr       NUMBER;
  i           NUMBER;

  l_ben_params             csr_ben%ROWTYPE;

Begin

  debug_enter(l_proc_name);


   OPEN csr_ben (c_ext_dfn_id        => Ben_Ext_Thread.g_ext_dfn_id
                ,c_ext_rslt_id       => Ben_Ext_Thread.g_ext_rslt_id
                ,c_business_group_id => p_business_group_id);
   Fetch csr_ben Into l_ben_params;
   CLOSE csr_ben;

   debug('l_ben_params.benefit_action_id :' || l_ben_params.benefit_action_id);


     -- (1) fetch all person_ids which have errored
     OPEN csr_err_person_id(p_ext_rslt_id => Ben_Ext_Thread.g_ext_rslt_id);
     FETCH csr_err_person_id BULK COLLECT INTO l_person_collection;
     CLOSE csr_err_person_id;

     debug('Step 1 Completed');


     -- (2) update using FORALL and bulk collect all person_action_id
     FORALL i in 1..l_person_collection.COUNT
       Update ben_person_actions bpa
         Set bpa.action_status_cd = 'U'
       Where bpa.benefit_action_id = l_ben_params.benefit_action_id
         and bpa.person_id = l_person_collection(i)
       RETURNING person_action_id BULK COLLECT INTO l_per_action_id_collection;

     debug('Step 2 Completed');
     debug('l_per_action_id_collection.COUNT : ' || l_per_action_id_collection.COUNT);


     -- (3) run thru the PL/SQL collection and populate a range_id collection
     IF l_per_action_id_collection.COUNT > 0
     THEN

       FOR l_index IN l_per_action_id_collection.FIRST..l_per_action_id_collection.LAST
       LOOP

         OPEN csr_range_id
              (p_person_action_id  => l_per_action_id_collection(l_index)
              ,p_benefit_action_id => l_ben_params.benefit_action_id
              );
         FETCH csr_range_id INTO l_range_id;
         CLOSE csr_range_id;

         IF NOT l_RangeId_collection.EXISTS(l_range_id) THEN
            l_RangeID_collection(l_range_id) := l_range_id;
         END IF;
       END LOOP;
     END IF; -- l_per_action_id_collection.COUNT > 0

     debug('Step 3 Completed');
     debug('l_RangeID_collection.COUNT : ' || l_RangeID_collection.COUNT);


     -- (4) now use the range Id collection to update the batch ranges
     FOR i IN 1..l_RangeID_collection.COUNT
     LOOP

       IF i=1 THEN
         l_itr :=l_RangeID_collection.FIRST;
       ELSE
         l_itr :=l_RangeID_collection.NEXT(l_itr);
       END IF;

         Update ben_batch_ranges bbr
            set bbr.range_status_cd = 'E'
          Where bbr.range_id = l_RangeID_collection(l_itr);

     END LOOP;

    debug('Step 4 Completed');


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
End exclude_errored_people;




-- ----------------------------------------------------------------------------
-- |------------------------< common_post_process >-------------------------------|
-- ----------------------------------------------------------------------------
-- procedure to mark errored persons as 'U' (unprocessed)


Procedure common_post_process
          (p_business_group_id in number
          ) Is


  l_proc_name           VARCHAR2(61):=
     g_proc_name||'common_post_process';

  CURSOR csr_dfn_code
  IS
  Select output_name
  from ben_ext_dfn
  where ext_dfn_id = ben_ext_thread.g_ext_dfn_id;

  l_extract_code        csr_dfn_code%rowtype;
  l_file_name           VARCHAR2(100);
  l_run_date            DATE;
  l_business_group_id   NUMBER := NULL;

Begin

  debug_enter(l_proc_name);

--    fnd_file.put_line(fnd_file.log, l_proc_name || to_char(SYSDATE,'dd-Mon-yyyy hh:mm:ss am'));
    fnd_file.put_line(fnd_file.log, l_proc_name || ' : ' || get_time);

    -- 115.60
    -- this happens when persons are rejected at the system extract level
    -- in such cases, set_shared_globals doesnt get called, and the globals
    -- need to be set here
    IF p_business_group_id IS NULL
    THEN
      l_business_group_id := g_business_group_id_backup;
    ELSE
      l_business_group_id := p_business_group_id;
    END IF;

    -- set paypoint if not found
    debug('g_paypoint :' || g_paypoint);
    IF g_paypoint IS NULL
    THEN
      g_paypoint := paypoint(l_business_group_id);
      debug('g_paypoint :' || g_paypoint);
    END IF;

    -- function call to exclude errored people
    exclude_errored_people(l_business_group_id);

    debug('g_extract_type : ' || g_extract_type);
    debug('g_output_name : ' || g_output_name);
    debug('g_sequence_number : ' || g_sequence_number);


    -- Get the output file name
    OPEN csr_get_run_date(c_ext_dfn_id         => ben_ext_thread.g_ext_dfn_id
                         ,c_business_group_id  => l_business_group_id);
    FETCH csr_get_run_date INTO l_run_date,g_output_name;
    CLOSE csr_get_run_date;


    IF g_extract_type = '3CUT' THEN
      g_sequence_number := '001';
    ELSE
      IF g_output_name IS NULL THEN
        g_sequence_number := '002';
      ELSE
        g_sequence_number := rtrim(ltrim(to_char(fnd_number.canonical_to_number(substr(g_output_name,INSTR(g_output_name,'.')+1))+1,'099')));
      END IF;
    END IF;

    debug('g_extract_type : ' || g_extract_type);
    debug('g_output_name : ' || g_output_name);
    debug('g_sequence_number : ' || g_sequence_number);

    OPEN csr_dfn_code;
    FETCH csr_dfn_code INTO l_extract_code;
    CLOSE csr_dfn_code;

    debug('l_extract_code.output_name :' || l_extract_code.output_name);


    l_file_name := l_extract_code.output_name || g_paypoint || '.' || g_sequence_number;

    debug('l_file_name :' || l_file_name );

    update ben_ext_rslt
    SET output_name = l_file_name
    WHERE business_group_id = l_business_group_id
      AND ext_rslt_id = ben_ext_thread.g_ext_rslt_id;

  debug_exit(l_proc_name);

--  fnd_file.put_line(fnd_file.log, 'Done : ' || l_proc_name || to_char(SYSDATE,'dd-Mon-yyyy hh:mm:ss am'));
  fnd_file.put_line(fnd_file.log, 'Done : ' || l_proc_name || ' : ' || get_time);

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
End common_post_process;

--
--
-- ----------------------------------------------------------------------------
-- |------------------------< raise_extract_warning >-----------------------|
-- ----------------------------------------------------------------------------


--
--    RAISE_EXTRACT_WARNING
--
--    "Smart" warning function.
--    When called from the Rule of a extract detail data element
--    it logs a warning in the ben_ext_rslt_err table against
--    the person being processed (or as specified by context of
--    assignment id ). It prefixes all warning messages with a
--    string "Warning raised in data element "||element_name
--    This allows the same Rule to be called from different data
--    elements.
--
--    usage example.
--
--    RAISE_EXTRACT_WARNING("No initials were found.")
--
--    RRTURNCODE  MEANING
--    -1          Cannot raise warning against a header/trailer
--                record. System Extract does not allow it.
--
--    -2          No current extract process was found.
--
--    -3          No person was found.A Warning in System Extract
--                is always raised against a person.
--

  FUNCTION raise_extract_warning
    (p_assignment_id     IN     NUMBER    DEFAULT g_assignment_id     -- context
    ,p_error_text        IN     VARCHAR2
    ,p_error_number      IN     NUMBER    DEFAULT NULL
    ,p_token1            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token2            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token3            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token4            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ) RETURN NUMBER
  IS

    l_proc_name           VARCHAR2(61):=
     g_proc_name||'raise_extract_warning';

     l_ext_rslt_id   NUMBER;
     l_person_id     NUMBER;
     l_error_text    VARCHAR2(2000);
     l_return_value  NUMBER:= 0;
  BEGIN
  --

    debug_enter(l_proc_name);

      l_ext_rslt_id:= get_current_extract_result;

      IF l_ext_rslt_id <> -1 THEN
      --


        If p_error_number is null Then

          l_error_text:= 'Warning raised in data element '||
                           ben_ext_fmt.g_elmt_name||'. '||
                         p_error_text;
        --if no message token is defined then egt the message from
        --ben_ext_fmt.
        Elsif p_token1 is null Then

          ben_ext_thread.g_err_num  := p_error_number;
          ben_ext_thread.g_err_name := p_error_text;
          l_error_text :=
            ben_ext_fmt.get_error_msg(fnd_number.canonical_to_number(substr(p_error_text, 5, 5)),
              p_error_text,ben_ext_fmt.g_elmt_name);

        -- if any token is defined than replace the tokens in the message.
        -- and get the message text from fnd_messages.
        Elsif p_token1 is not null Then

        -- set the Tokens in the warning message and then
        -- get the warning message from fnd_messages.

          ben_ext_thread.g_err_num  := p_error_number;
          ben_ext_thread.g_err_name := p_error_text;

          fnd_message.set_name('BEN',p_error_text);
          fnd_message.set_token('TOKEN1',p_token1);
          debug('token1 : '||p_token1);
          -- this is based on the logic that tokens are passed in order
          -- i.e. when 3 tokens are to be used, it will be passed as token1,
          -- token2 and token3. Hence, if we find token2 as NULL, we conclude
          -- that token3 and token4 are not present.
          if p_token2 is not null Then
            debug('token2 : '||p_token2);
            fnd_message.set_token('TOKEN2',p_token2);
            if p_token3 is not null Then
              debug('token3 : '||p_token3);
              fnd_message.set_token('TOKEN3',p_token3);
              if p_token4 is not null Then
                debug('token4 : '||p_token4);
                fnd_message.set_token('TOKEN4',p_token4);
              end if;
            end if;
          end if;

          l_error_text := fnd_message.get ;

        End If;


        -- for setup related warnings, assignment_id is NULL
        -- so raise these warnings independent of person
        IF p_assignment_id < 0 -- IS NULL
        THEN
          --l_person_id := -1; --p_assignment_id ; -- independent of person
          l_person_id := p_assignment_id ; -- independent of person
        ELSE -- DE related warning
          l_person_id:= NVL(get_current_extract_person(p_assignment_id)
                       ,ben_ext_person.g_person_id);
        END IF;
        debug('l_person_id : '||l_person_id, 99);

        IF l_person_id IS NOT NULL THEN
        --
          ben_ext_util.write_err
            (p_err_num           => p_error_number
            ,p_err_name          => l_error_text
            ,p_typ_cd            => 'W'
            ,p_person_id         => l_person_id
            ,p_request_id        => fnd_global.conc_request_id
            ,p_business_group_id => fnd_global.per_business_group_id
            ,p_ext_rslt_id       => get_current_extract_result
            );
          l_return_value:= 0;  /* All Well ! */
        --
        ELSE
        --
          l_return_value:= -3; /* Person not found  */
        --
        END IF;
      --
      ELSE
      --
        l_return_value:= -2; /* No current extract process was found */
      --
      END IF;

     debug_exit(l_proc_name);
  --
  RETURN l_return_value;
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

  END raise_extract_warning;


-- ----------------------------------------------------------------------------
-- |------------------------< raise_extract_error >-----------------------|
-- ----------------------------------------------------------------------------

  FUNCTION raise_extract_error
    (p_business_group_id IN     NUMBER    DEFAULT g_business_group_id -- context
    ,p_assignment_id     IN     NUMBER    DEFAULT g_assignment_id     -- context
    ,p_error_text        IN     VARCHAR2
    ,p_error_number      IN     NUMBER    DEFAULT NULL
    ,p_token1            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token2            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token3            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token4            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ) RETURN NUMBER
  IS

      l_proc_name           VARCHAR2(61):=
     g_proc_name||'raise_extract_error';

     l_ext_rslt_id   NUMBER;
     l_person_id     NUMBER;
     l_error_text    VARCHAR2(2000);
     l_error_message VARCHAR2(2000);
     l_return_value  NUMBER:= 0;
     l_err_typ_cd    VARCHAR2(1) := NULL;

  BEGIN

  debug_enter(l_proc_name);
  --
    IF p_business_group_id is not null THEN
    --
      debug('p_business_group_id is not null');
      l_ext_rslt_id:= get_current_extract_result;
      IF l_ext_rslt_id <> -1 THEN
      --

        If p_error_number is null Then

          l_error_text:= 'Error raised in data element '||
                          NVL(ben_ext_person.g_elmt_name,ben_ext_fmt.g_elmt_name)||'. '||
                         p_error_text;


            Elsif p_token1 is null Then

          debug('p_token1 is null');
          ben_ext_thread.g_err_num  := p_error_number;
          ben_ext_thread.g_err_name := p_error_text;
          l_error_text :=
            ben_ext_fmt.get_error_msg(fnd_number.canonical_to_number(substr(p_error_text, 5, 5)),
              p_error_text,ben_ext_fmt.g_elmt_name);

        -- if any token is defined than replace the tokens in the message.
        -- and get the message text from fnd_messages.
        Elsif p_token1 is not null Then

        -- set the Tokens in the warning message and then
        -- get the warning message from fnd_messages.

          ben_ext_thread.g_err_num  := p_error_number;
          ben_ext_thread.g_err_name := p_error_text;

          fnd_message.set_name('BEN',p_error_text);
          fnd_message.set_token('TOKEN1',p_token1);

          if p_token2 is not null Then
            debug('token2 : '||p_token2);
            fnd_message.set_token('TOKEN2',p_token2);
            if p_token3 is not null Then
              debug('token3 : '||p_token3);
              fnd_message.set_token('TOKEN3',p_token3);
              if p_token4 is not null Then
                debug('token4 : '||p_token4);
                fnd_message.set_token('TOKEN4',p_token4);
              end if;
            end if;
          end if;

          l_error_text := fnd_message.get ;

        End If; -- End if of error number is null check ...

        -- for setup related errors, assignment_id is NULL
        -- so raise these errors independent of person
        IF p_assignment_id < 0 -- IS NULL (setup error)
        THEN
          --l_person_id := -1; --p_assignment_id ; -- independent of person
          l_person_id  := p_assignment_id ; -- independent of person
          -- 115.10
          l_err_typ_cd := 'F'; -- all setup errors are fatal
        ELSE -- DE related error
          l_person_id  := NVL(get_current_extract_person(p_assignment_id)
                          ,ben_ext_person.g_person_id);
          -- 115.10
          l_err_typ_cd := 'E'; -- all data element related errors are 'E'
        END IF;
        debug('l_person_id : '||l_person_id, 99);

          ben_ext_util.write_err
            (p_err_num           => p_error_number
            ,p_err_name          => l_error_text
            ,p_typ_cd            => l_err_typ_cd -- 'F'
            ,p_person_id         => l_person_id
            ,p_request_id        => fnd_global.conc_request_id
            ,p_business_group_id => p_business_group_id
            ,p_ext_rslt_id       => get_current_extract_result
            );

          --commit;

          --raise ben_ext_thread.g_job_failure_error;
          l_return_value:= 0;  /* All Well ! */
      --
      ELSE
      --
        l_return_value:= -2; /* No current extract process was found */
      --
      END IF;
    --
    ELSE
    --
      l_return_value := -1; /* Cannot raise warnings against header/trailers */
    --
    END IF;
  --

  debug_exit(l_proc_name);

  RETURN l_return_value;
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

  END raise_extract_error;


-- ----------------------------------------------------------------------------
-- |------------------------< store_extract_exceptions >-----------------------|
-- ----------------------------------------------------------------------------

  PROCEDURE store_extract_exceptions
           (-- pass <interface_name> / 'DE' to indicate
            -- the level at which error/warning has been raised
            -- (1) <interface_name> (eg BASIC_DATA) = interface setup exceptions
            -- (2) DE = person/data element level
            p_extract_type        IN VARCHAR2 -- <interface_name>/'DE'
           ,p_error_number        IN NUMBER
           ,p_error_text          IN VARCHAR2
           ,p_token1              IN VARCHAR2 DEFAULT NULL
           ,p_token2              IN VARCHAR2 DEFAULT NULL
           ,p_token3              IN VARCHAR2 DEFAULT NULL
           ,p_token4              IN VARCHAR2 DEFAULT NULL
           ,p_error_warning_flag  IN VARCHAR2 -- E (error) / W (warning)
           )
  IS
  --
    l_proc_name           VARCHAR2(61):=
     g_proc_name||'store_extract_exceptions';

    l_error_index               NUMBER;
    l_warning_index             NUMBER;

  --
  BEGIN

  debug_enter(l_proc_name);

  l_error_index := 0;
  l_warning_index := 0;

  debug('g_errors.COUNT : '|| g_errors.COUNT);
  debug('g_warnings.COUNT : '|| g_warnings.COUNT);


  IF   p_error_warning_flag = 'e'
    OR p_error_warning_flag = 'E'
  THEN -- enter a new record in errors table
    l_error_index           := g_errors.COUNT;

    g_errors(l_error_index + 1).extract_type  := p_extract_type;
    g_errors(l_error_index + 1).error_number  := p_error_number;
    g_errors(l_error_index + 1).error_text    := p_error_text;
    g_errors(l_error_index + 1).token1        := p_token1;
    g_errors(l_error_index + 1).token2        := p_token2;
    g_errors(l_error_index + 1).token3        := p_token3;
    g_errors(l_error_index + 1).token4        := p_token4;

    -- assignment_id need to be set for DE level errors
    IF p_extract_type = 'DE' THEN
      g_errors(l_error_index + 1).assignment_id := g_assignment_id;
    ELSE
       --g_errors(l_error_index + 1).assignment_id := NULL;
       g_errors(l_error_index + 1).assignment_id := -(l_error_index+1);
    END IF;

    -- store extract result ID for cases of multiple parallel extracts run
    g_errors(l_error_index + 1).ext_rslt_id     := ben_ext_thread.g_ext_rslt_id;

    -- debug
    --=================================
    debug('g_errors('||(l_error_index + 1)||').extract_type : '|| g_errors(l_error_index + 1).extract_type);
    debug('g_errors('||(l_error_index + 1)||').error_number : '|| g_errors(l_error_index + 1).error_number);
    debug('g_errors('||(l_error_index + 1)||').error_text : '|| g_errors(l_error_index + 1).error_text);
    debug('g_errors('||(l_error_index + 1)||').token1 : '|| g_errors(l_error_index + 1).token1);
    debug('g_errors('||(l_error_index + 1)||').token2 : '|| g_errors(l_error_index + 1).token2);
    debug('g_errors('||(l_error_index + 1)||').token3 : '|| g_errors(l_error_index + 1).token3);
    debug('g_errors('||(l_error_index + 1)||').token4 : '|| g_errors(l_error_index + 1).token4);
    debug('g_errors('||(l_error_index + 1)||').assignment_id : '|| g_errors(l_error_index + 1).assignment_id);
    debug('g_errors('||(l_error_index + 1)||').ext_rslt_id : '|| g_errors(l_error_index + 1).ext_rslt_id);
    --=================================

  ELSE -- enter a new record in the warnings table

    l_warning_index           := g_warnings.COUNT;

    g_warnings(l_warning_index + 1).extract_type := p_extract_type;
    g_warnings(l_warning_index + 1).error_number := p_error_number;
    g_warnings(l_warning_index + 1).error_text   := p_error_text;
    g_warnings(l_warning_index + 1).token1       := p_token1;
    g_warnings(l_warning_index + 1).token2       := p_token2;
    g_warnings(l_warning_index + 1).token3       := p_token3;
    g_warnings(l_warning_index + 1).token4       := p_token4;

    -- assignment_id need to be set for DE level errors
    IF p_extract_type = 'DE' THEN
      g_warnings(l_warning_index + 1).assignment_id := g_assignment_id;
    ELSE
      --g_warnings(l_warning_index + 1).assignment_id := NULL;
      g_warnings(l_warning_index + 1).assignment_id :=  -(l_warning_index+1);
    END IF;

    -- store extract result ID for cases of multiple parallel extracts run
    g_warnings(l_warning_index + 1).ext_rslt_id     := ben_ext_thread.g_ext_rslt_id;


    -- debug
    --=================================
    debug('g_warnings('||(l_warning_index + 1)||').extract_type : '|| g_warnings(l_warning_index + 1).extract_type);
    debug('g_warnings('||(l_warning_index + 1)||').error_number : '|| g_warnings(l_warning_index + 1).error_number);
    debug('g_warnings('||(l_warning_index + 1)||').error_text : '|| g_warnings(l_warning_index + 1).error_text);
    debug('g_warnings('||(l_warning_index + 1)||').token1 : '|| g_warnings(l_warning_index + 1).token1);
    debug('g_warnings('||(l_warning_index + 1)||').token2 : '|| g_warnings(l_warning_index + 1).token2);
    debug('g_warnings('||(l_warning_index + 1)||').token3 : '|| g_warnings(l_warning_index + 1).token3);
    debug('g_warnings('||(l_warning_index + 1)||').token4 : '|| g_warnings(l_warning_index + 1).token4);
    debug('g_warnings('||(l_warning_index + 1)||').assignment_id : '|| g_warnings(l_warning_index + 1).assignment_id);
    debug('g_warnings('||(l_warning_index + 1)||').ext_rslt_id : '|| g_warnings(l_warning_index + 1).ext_rslt_id);
    --=================================

  END IF;

  --

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

  END store_extract_exceptions;



-- ----------------------------------------------------------------------------
-- |------------------------< raise_extract_exceptions >-----------------------|
-- ----------------------------------------------------------------------------

-- (1) pass <interface_name> as parameter to raise setup related errors/warnings that were
-- stored during set_shared_globals and set_extract_globals
-- (2) Dont pass any parameter,data element level errors/warnings will be raised
  PROCEDURE raise_extract_exceptions
           (p_extract_type        IN VARCHAR2 DEFAULT 'DE'
           )
  IS
  --
    l_proc_name           VARCHAR2(61):=
     g_proc_name||'raise_extract_exceptions';

    l_index               NUMBER;
    l_value               NUMBER;
    l_fatal_error_flag    VARCHAR2(1) := 'N';
  --
  BEGIN

  debug_enter(l_proc_name);

  l_index := 0;

  -- this flag is to track whether one of the errors raised were a fatal error
  l_fatal_error_flag := 'N';

  FOR i IN 1..g_errors.COUNT
  LOOP

    -- IF error_type = DE and g_errors has assignment_id, raise
    -- OR
    -- IF error_type = SETUP and g_errors doesnt have assignment_id, raise
    -- all DE errors will have g_error.assignment_id,
    -- all setup errors will have g_error.assignment_id = NULL
    debug('This is the loop for raising errors - ',20);


    -- setting the index
    IF i=1 THEN
      l_index:=g_errors.FIRST;
    ELSE
      l_index:=g_errors.NEXT(l_index);
    END IF;

    debug('l_index : ' || l_index,25);
      -- debug
      --=================================
      debug('g_errors('||(l_index)||').extract_type : '|| g_errors(l_index).extract_type);
      debug('g_errors('||(l_index)||').error_number : '|| g_errors(l_index).error_number);
      debug('g_errors('||(l_index)||').error_text : '|| g_errors(l_index).error_text);
      debug('g_errors('||(l_index)||').token1 : '|| g_errors(l_index).token1);
      debug('g_errors('||(l_index)||').token2 : '|| g_errors(l_index).token2);
      debug('g_errors('||(l_index)||').token3 : '|| g_errors(l_index).token3);
      debug('g_errors('||(l_index)||').token4 : '|| g_errors(l_index).token4);
      debug('g_errors('||(l_index)||').assignment_id : '|| g_errors(l_index).assignment_id);
      debug('g_errors('||(l_index)||').ext_rslt_id : '|| g_errors(l_index).ext_rslt_id);
      --=================================

    -- check error type
    IF (
        (p_extract_type = 'DE'
        and
        g_errors(l_index).assignment_id  > 0 -- IS NOT NULL
        )
        or
        (p_extract_type <> 'DE'
        and
        g_errors(l_index).assignment_id  < 0 --  IS NULL
        )
       )
       and
        g_errors(l_index).ext_rslt_id = ben_ext_thread.g_ext_rslt_id


    THEN
      debug('This error qualified to be raised - ',30);

      l_value:=
        raise_extract_error
          (p_business_group_id => g_business_group_id
          ,p_assignment_id     => g_errors(l_index).assignment_id
          ,p_error_text        => g_errors(l_index).error_text
          ,p_error_number      => g_errors(l_index).error_number
          ,p_token1            => g_errors(l_index).token1
          ,p_token2            => g_errors(l_index).token2
          ,p_token3            => g_errors(l_index).token3
          ,p_token4            => g_errors(l_index).token4
          );

      -- delete this record as this error has already been reported above
      g_errors.DELETE(l_index);

      -- setting flag to error out extract in case the error
      -- raised was of setup type
      IF p_extract_type <> 'DE' and l_fatal_error_flag = 'N'
      THEN
        l_fatal_error_flag := 'Y';
      END IF;

    ELSE
      debug('This error was NOT raised - ',30);
      debug('p_extract_type : ' || p_extract_type);
      debug('g_errors('||l_index||').assignment_id : ' || g_errors(l_index).assignment_id);

    END IF;
  END LOOP;


  FOR i IN 1..g_warnings.COUNT
  LOOP
    -- IF error_type = DE and g_errors has assignment_id, raise
    -- OR
    -- IF error_type = SETUP and g_errors doesnt have assignment_id, raise
    -- all DE errors will have g_error.assignment_id,
    -- all setup errors will have g_error.assignment_id = NULL

    debug('This is the loop for raising warnings - ',20);


    -- setting the index
    IF i=1 THEN
      l_index:=g_warnings.FIRST;
    ELSE
      l_index:=g_warnings.NEXT(l_index);
    END IF;

    -- debug
    --=================================
    debug('g_warnings('||(l_index)||').extract_type : '|| g_warnings(l_index).extract_type);
    debug('g_warnings('||(l_index)||').error_number : '|| g_warnings(l_index).error_number);
    debug('g_warnings('||(l_index)||').error_text : '|| g_warnings(l_index).error_text);
    debug('g_warnings('||(l_index)||').token1 : '|| g_warnings(l_index).token1);
    debug('g_warnings('||(l_index)||').token2 : '|| g_warnings(l_index).token2);
    debug('g_warnings('||(l_index)||').token3 : '|| g_warnings(l_index).token3);
    debug('g_warnings('||(l_index)||').token4 : '|| g_warnings(l_index).token4);
    debug('g_warnings('||(l_index)||').assignment_id : '|| g_warnings(l_index).assignment_id);
    debug('g_warnings('||(l_index)||').ext_rslt_id : '|| g_warnings(l_index).ext_rslt_id);
    --=================================

    -- check warning type
    IF (
        (p_extract_type = 'DE'
        and
        g_warnings(l_index).assignment_id  > 0 -- IS NOT NULL
        )
        or
        (p_extract_type <> 'DE'
        and
        g_warnings(l_index).assignment_id  < 0 -- IS NULL
        )
       )
       and
        g_warnings(l_index).ext_rslt_id = ben_ext_thread.g_ext_rslt_id

    THEN
      debug('This warning qualified to be raised - ',30);

      l_value:=
        raise_extract_warning
          (p_assignment_id     => g_warnings(l_index).assignment_id
          ,p_error_text        => g_warnings(l_index).error_text
          ,p_error_number      => g_warnings(l_index).error_number
          ,p_token1            => g_warnings(l_index).token1
          ,p_token2            => g_warnings(l_index).token2
          ,p_token3            => g_warnings(l_index).token3
          ,p_token4            => g_warnings(l_index).token4
          );

        -- delete this record as this warning has already been reported above
        g_warnings.DELETE(l_index);

    ELSE
      debug('This warning was NOT raised - ',30);
    END IF;

  END LOOP;


  -- fail extract if fatal errors were there
  IF l_fatal_error_flag = 'Y'
  THEN
    commit;

    raise ben_ext_thread.g_job_failure_error;
  END IF;

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

  END raise_extract_exceptions;


-- ----------------------------------------------------------------------------
-- |------------------------< set_shared_globals >-----------------------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE set_shared_globals
    (p_business_group_id        IN      NUMBER
    ,p_paypoint                 OUT NOCOPY VARCHAR2
    ,p_cutover_date             OUT NOCOPY VARCHAR2
    ,p_ext_dfn_id               OUT NOCOPY NUMBER
    )
  IS
  --
    l_proc_name           VARCHAR2(61):=
     g_proc_name||'set_shared_globals';


    l_paypoint                VARCHAR2(5)   := NULL;
    l_cutover_date            DATE;
    l_ext_dfn_id              NUMBER;
    l_config_value            pqp_utilities.t_config_values;
  --
  BEGIN


  g_debug         :=  pqp_gb_psi_functions.check_debug(p_business_group_id);

  debug_enter(l_proc_name);

--  fnd_file.put_line(fnd_file.log, l_proc_name || to_char(SYSDATE,'dd-Mon-yyyy hh:mm:ss am'));
  fnd_file.put_line(fnd_file.log, l_proc_name || ' : ' || get_time);


    debug('Entering set_shared_globals ...',10);
    debug ('p_business_group_id:'||p_business_group_id);

    g_business_group_id := p_business_group_id;


    -- paypoint
    p_paypoint := paypoint(p_business_group_id);
    debug('p_paypoint : ' || p_paypoint, 30);
    -- check if paypoint is present or valid
    IF p_paypoint = ''
       or
       p_paypoint IS NULL
       or
       NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> p_paypoint)
    THEN
      -- error
      PQP_GB_PSI_FUNCTIONS.store_extract_exceptions
                   (p_extract_type        =>    'Pay Point'
                   ,p_error_number        =>    94453
                   ,p_error_text          =>    'BEN_94453_INV_PAYPOINT'
                   ,p_error_warning_flag  =>    'E'
                   );
    END IF;

    -- fetch configuration value for cutover date
    debug('Fetching configuration value for cutover date ...', 40);
      pqp_utilities.get_config_type_values
                   ( p_configuration_type   => 'PQP_GB_PENSERVER_PAYPOINT_INFO' --'PQP_GB_PENSERVER_CUTOVER_DATE'
                                ,p_business_group_id    => p_business_group_id
                                ,p_legislation_code     => NULL
                                ,p_tab_config_values    => l_config_value
                     );
      --ERR : no configuration value found ???
      --debug('ERROR!!! : no configuration value found for cutover date', 50);
      IF l_config_value.COUNT > 0 -- config value found
      THEN
        p_cutover_date := to_date(substr(l_config_value(l_config_value.FIRST).pcv_information2,1,10),'YYYY/MM/DD');
        debug('p_cutover_date : ' || p_cutover_date, 50);
      ELSE
        p_cutover_date := NULL;
      END IF;

      -- store in a global
      g_cutover_date := p_cutover_date;

    -- extract definition ID
      p_ext_dfn_id := ben_ext_thread.g_ext_dfn_id;
      debug('p_ext_dfn_id : ' || p_ext_dfn_id, 60);


    -- fetch configuration value for employment type mapping
    debug('Fetching configuration value for employment type mapping ...', 65);

      pqp_utilities.get_config_type_values
             ( p_configuration_type   => 'PQP_GB_PENSERVER_EMPLYMT_TYPE'
              ,p_business_group_id    => p_business_group_id
              ,p_legislation_code     => NULL
              ,p_tab_config_values    => g_assign_category_mapping --caching in global
                                                                   -- for future use
             );
      debug('g_assign_category_mapping has been populated !',66);


      -- fetch configuration value for pension scheme mapping
      debug('Fetching configuration value for pension scheme mapping ...', 65);

      pqp_utilities.get_config_type_values
             ( p_configuration_type   => 'PQP_GB_PENSERV_SCHEME_MAP_INFO'
              ,p_business_group_id    => p_business_group_id
              ,p_legislation_code     => NULL
              ,p_tab_config_values    => g_pension_scheme_mapping --caching in global
                                                                  -- for future use
             );
      debug('g_pension_scheme_mapping has been populated !',66);


  debug('Exiting set_shared_globals ...',70);
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

  END set_shared_globals;


--
-- modified as part of 115.58 (5)
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_employee_pension_scheme >-------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_employee_pension_scheme
      (p_business_group_id       IN NUMBER
      ,p_effective_date          IN DATE
      ,p_assignment_id           IN NUMBER
      ,p_psi_pension_scheme      IN VARCHAR2
      ,p_pension_element_type_id OUT NOCOPY NUMBER
      )  RETURN VARCHAR2 -- Y or N
IS
  --

    l_proc_name           VARCHAR2(61):=
     g_proc_name||'check_employee_pension_scheme';

    l_return              VARCHAR2(1) := 'N';
    l_config_value        pqp_utilities.t_config_values;
    l_index               NUMBER;
    l_element_type_id     NUMBER := NULL;

BEGIN
  debug_enter(l_proc_name);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_assignment_id:'||p_assignment_id);

      -- search thru the mapping for this assignment category
      FOR i IN 1..g_pension_scheme_mapping.COUNT
      LOOP

        IF i=1 THEN -- finding next index
          l_index:=g_pension_scheme_mapping.FIRST;
        ELSE
          l_index:=g_pension_scheme_mapping.NEXT(l_index);
        END IF;

        debug('g_pension_scheme_mapping('||l_index||').pcv_information1 : '
                      || g_pension_scheme_mapping(l_index).pcv_information1);
        debug('g_pension_scheme_mapping('||l_index||').pcv_information2 : '
                      || g_pension_scheme_mapping(l_index).pcv_information2);

        -- start comparing
        --IF g_pension_scheme_mapping(l_index).pcv_information2 = 'PARTNER' -- match found!!
        IF g_pension_scheme_mapping(l_index).pcv_information2 = p_psi_pension_scheme -- match found!!
        THEN
          l_element_type_id := g_pension_scheme_mapping(l_index).pcv_information1;

          debug('l_element_type_id : '|| l_element_type_id,65);
          debug('g_pension_scheme_mapping('||l_index||').pcv_information1 : '
                      || g_pension_scheme_mapping(l_index).pcv_information1,66);
          debug('g_pension_scheme_mapping('||l_index||').pcv_information2 : '
                      || g_pension_scheme_mapping(l_index).pcv_information2,66);

          debug('match found! Need to check presence on assignment ',67);

            -- now check for presence of this element_type_id on assignment
            debug('now checking for scheme membership for '||p_psi_pension_scheme||'...',70);
            -- open cursor
            OPEN csr_partnership_scheme_flag
                 (p_business_group_id  => p_business_group_id
                 ,p_effective_date     => p_effective_date
                 ,p_assignment_id      => p_assignment_id
                 ,p_element_type_id    => l_element_type_id
                 );
            FETCH csr_partnership_scheme_flag into l_return;
                  IF csr_partnership_scheme_flag%FOUND THEN
                    l_return := 'Y';
                    debug('l_return : ' || l_return,75);
                    CLOSE csr_partnership_scheme_flag;
                    EXIT; -- match found, exit the FOR loop
                  ELSE
                    l_return := 'N';
                    debug('l_return : ' || l_return,76);
                  END IF;
            CLOSE csr_partnership_scheme_flag;
            --

        ELSE
          -- ERR - no matching employment category
          debug('Not a match !!',70);
        END IF;

      END LOOP; -- end of FOR loop


    -- out parameter of this pension scheme
    p_pension_element_type_id := l_element_type_id;

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

END check_employee_pension_scheme;


-- ----------------------------------------------------------------------------
-- |------------------------< check_employee_eligibility >-------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_employee_eligibility
              (p_business_group_id       IN NUMBER
              ,p_assignment_id           IN NUMBER
              ,p_effective_date          IN DATE
              ,p_chg_value               OUT NOCOPY VARCHAR2 -- the scheme name entered.
              )  RETURN VARCHAR2 -- Y or N
IS
  --
    l_proc_name  VARCHAR2(61):= g_proc_name||'check_employee_eligibility';
    l_return              VARCHAR2(1) := 'Y';
    l_config_values         PQP_UTILITIES.t_config_values;

    l_query   VARCHAR2(1000);
    TYPE base_table_ref_csr_typ IS REF CURSOR;
    c_base_table        base_table_ref_csr_typ;

BEGIN
  debug_enter(l_proc_name);
  debug('p_business_group_id: '||p_business_group_id,10);
  debug('p_effective_date: '||p_effective_date,10);
  debug('p_assignment_id: '||p_assignment_id,10);

  IF g_asg_membership_col IS NULL THEN
      -- fetch the value if g_asg_membership_col is null
      debug('Fetch the column name for the first time.',30);
      PQP_UTILITIES.get_config_type_values(
                     p_configuration_type   =>    'PQP_GB_PENSERVER_ELIGBLTY_CONF'
                    ,p_business_group_id    =>    g_business_group_id
                    ,p_legislation_code     =>    g_legislation_code
                    ,p_tab_config_values    =>    l_config_values
                  );
      IF l_config_values.COUNT > 0 THEN
          g_asg_membership_context  :=  l_config_values(l_config_values.FIRST).pcv_information1;
          g_asg_membership_col      :=  l_config_values(l_config_values.FIRST).pcv_information2;
      ELSE
          -- no configuration value
          -- riase errorr
          debug('ERROR: No configuration for the eligibility column',20);
          store_extract_exceptions
                 (p_extract_type        =>    'Employee Eligibility'
                 ,p_error_number        =>    93917
                 ,p_error_text          =>    'BEN_93917_NO_PEN_ELIGBLTY_CONF'
                 ,p_error_warning_flag  =>    'E'
                 );
      END IF;
  END IF;

  IF g_asg_membership_col IS NOT NULL THEN
      debug('g_asg_membership_col: '||g_asg_membership_col,40);
      /*l_query :=  'select '||g_asg_membership_col||'
                   from per_all_assignments_f '||
                   'where business_group_id = '||p_business_group_id||' '||
                   'and assignment_id = '||p_assignment_id||' '||
                   'and ASS_ATTRIBUTE_CATEGORY = '||''''||g_asg_membership_context||''''||
                   'and to_date('||''''||TO_CHAR(p_effective_date,'dd/mm/yyyy')||''''||
                   ',''dd/mm/yyyy'')'||' between effective_start_date '||
                                         'and effective_end_date';*/
         /* commented to use bind variable instead of parameter */
     /* l_query :=   'select '||g_asg_membership_col||' '||
                   'from per_all_assignments_f '||' '||
                   'where business_group_id = '||p_business_group_id||' '||
                   'and assignment_id = '||p_assignment_id||' ';
      IF g_asg_membership_context <> 'Global Data Elements' THEN
            l_query := l_query||
                  'and ASS_ATTRIBUTE_CATEGORY = '''||g_asg_membership_context||''' ';
      END IF;

      l_query := l_query||
                'and to_date('||''''||TO_CHAR(p_effective_date,'dd/mm/yyyy')||''''||
                ',''dd/mm/yyyy'')'||' between effective_start_date '||
                                   'and effective_end_date';
      debug('l_query: '||l_query,30);
      -- fetch the value of from the column name
      OPEN c_base_table FOR l_query; */

       l_query :=  'select '||g_asg_membership_col||' '||'from per_all_assignments_f '||' '||
                   'where business_group_id = :p_business_group_id '||
                   'and assignment_id = :p_assignment_id '||
                   'and :p_effective_date between effective_start_date and effective_end_date ';

      IF g_asg_membership_context <> 'Global Data Elements'
      THEN
        l_query := l_query || ' and ASS_ATTRIBUTE_CATEGORY = :g_asg_membership_context';
      END IF;

      IF g_asg_membership_context <> 'Global Data Elements'
      THEN

         OPEN c_base_table FOR l_query using p_business_group_id,p_assignment_id,p_effective_date,g_asg_membership_context;

      ELSE

         OPEN c_base_table FOR l_query using p_business_group_id,p_assignment_id,p_effective_date;

      END IF;

      FETCH c_base_table INTO p_chg_value;
      CLOSE c_base_table;
      debug('l_assg_membership_value: '||p_chg_value,30);

      IF p_chg_value IS NULL THEN
          l_return  :=  'N';
          debug('l_return: '||l_return,40);
      END IF;
  END IF;



  debug('l_return: '||l_return,10);
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

END check_employee_eligibility;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_penserver_basic_criteria >-------------------|
-- ----------------------------------------------------------------------------
  FUNCTION chk_penserver_basic_criteria
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    ,p_person_dtl               OUT NOCOPY per_all_people_f%rowtype
    ,p_assignment_dtl           OUT NOCOPY per_all_assignments_f%rowtype
    ) RETURN VARCHAR2 -- Y or N
  IS

  --

    l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_penserver_basic_criteria';

    l_inclusion_flag            VARCHAR2(1) := 'Y';
    l_assignment_category       VARCHAR2(30):= NULL;
    l_last_hire_date_indicator  VARCHAR2(1) := NULL;
    l_person_id                 NUMBER;

    l_person_dtl                per_all_people_f%rowtype;
    l_assignment_dtl            per_all_assignments_f%rowtype;
    i                           NUMBER;
    l_index                     NUMBER;
    l_value                     NUMBER;
    l_pension_element_type_id   NUMBER;


  --

  BEGIN

  debug_enter(l_proc_name);

  IF (g_count = 0) THEN
--    fnd_file.put_line(fnd_file.log, l_proc_name || to_char(SYSDATE,'dd-Mon-yyyy hh:mm:ss am'));
    fnd_file.put_line(fnd_file.log, l_proc_name || ' : ' || get_time);
    g_count := 1;
  END IF;



    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_assignment_id:'||p_assignment_id);

    debug ('g_extract_type:'||g_extract_type);
    debug ('g_dfn_name:'||g_dfn_name);

--for PF
    IF (g_prev_assignment_id = p_assignment_id
        AND
        g_prev_effective_date = p_effective_date)
    THEN
      l_inclusion_flag := g_prev_inclusion_flag;
      p_assignment_dtl := g_assignment_dtl;
      p_person_dtl     := g_person_dtl;

      return l_inclusion_flag;
    END IF;
--for PF


    -- 115.60
    -- for cutover extracts and basic data
    -- pick person only till actual termination date
    IF g_extract_type = '3CUT'
       OR
       g_dfn_name = 'BDI'
    THEN
      -- open cursor to store assignment details
      open csr_get_assignment_dtl_cut
               (
                p_business_group_id  => p_business_group_id -- IN
               ,p_effective_date     => p_effective_date    -- IN
               ,p_assignment_id      => p_assignment_id     -- IN
               );
      fetch csr_get_assignment_dtl_cut into l_assignment_dtl;
        IF csr_get_assignment_dtl_cut%FOUND THEN
          debug('storing assignment details ...', 15);
          p_assignment_dtl := l_assignment_dtl;

          ---- Bugfix 6196433
          IF g_dfn_name = 'BDI' THEN
            g_assignment_dtl := l_assignment_dtl;  --location fix
          END IF;

        ELSE
          --ERR : no assignment details found
          debug('Assignment did not qualify !!', 20);
          p_assignment_dtl := NULL;
          l_inclusion_flag := 'N';
        END IF;
      close csr_get_assignment_dtl_cut;

    ELSE -- ='1PED' : periodic interfaces
         -- pick person till final close date

      -- open cursor to store assignment details
      open csr_get_assignment_dtl_per
               (
                p_business_group_id  => p_business_group_id -- IN
               ,p_effective_date     => p_effective_date    -- IN
               ,p_assignment_id      => p_assignment_id     -- IN
               );
      fetch csr_get_assignment_dtl_per into l_assignment_dtl;
        IF csr_get_assignment_dtl_per%FOUND THEN
          debug('storing assignment details ...', 21);
          p_assignment_dtl := l_assignment_dtl;

          g_assignment_dtl := l_assignment_dtl;      -- for PF


        ELSE
          --ERR : no assignment details found
          debug('Assignment did not qualify !!', 22);
          p_assignment_dtl := NULL;
          l_inclusion_flag := 'N';
        END IF;
      close csr_get_assignment_dtl_per;
    END IF;


      IF g_assignment_id IS NULL
           OR p_assignment_id <> nvl(g_assignment_id,0) THEN
           -- set assignment globals
           g_retro_event_date_reported  :=  FALSE;
      END IF;
          -- store globals
          g_assignment_id := p_assignment_id;

      -- remove all occurences of '-'
      g_assignment_number := TRIM(REPLACE(l_assignment_dtl.assignment_number,'-',''));
      debug('g_assignment_number : ' || g_assignment_number , 25);
      -- check altkey size <= 12 and alphanumeric check
      -- anshghos : 115.9
      IF ( length(g_assignment_number) + length(g_paypoint)) > 12
      THEN
        -- store error
        l_value := raise_extract_error
                     (p_error_number        =>    94454
                     ,p_error_text          =>    'BEN_94454_INV_ASSIGNMENT_NUM'
                     -- 115.11 : invalid assignment_number passed as token
                     ,p_token1              =>    g_assignment_number
                     );
      END IF;

      IF NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> g_assignment_number)
      THEN
        -- store error
        l_value := raise_extract_error
                     (p_error_number        =>    94467
                     ,p_error_text          =>    'BEN_94467_INV_ASSIGNMENT_NUM'
                     -- 115.11 : invalid assignment_number passed as token
                     ,p_token1              =>    g_assignment_number
                     );
      END IF;

        -- 115.11 (anshghos) : person no longer excluded for invalid altkey
        -- truncating assignment number so that altkey is 12 characters
          g_assignment_number := substr(g_assignment_number,1,(12-length(g_paypoint)));

    debug('l_inclusion_flag : '|| l_inclusion_flag,25);


    IF l_inclusion_flag <> 'N' -- not yet ruled out
    THEN
      -- open cursor to store person details
      open csr_get_person_dtl
               (
                p_business_group_id  => p_business_group_id         -- IN
               ,p_effective_date     => p_effective_date            -- IN
               ,p_person_id          => l_assignment_dtl.person_id  -- IN
               );
      fetch csr_get_person_dtl into l_person_dtl;
        IF csr_get_person_dtl%FOUND THEN
          debug('storing person details ...', 20);
          p_person_dtl := l_person_dtl;

          g_person_dtl := l_person_dtl;               -- for PF

        ELSE
          --ERR : no assignment details found
          debug('ERROR!!! : no person details fetched for the person id', 30);
          p_person_dtl := NULL;
          l_inclusion_flag := 'N';


        -- ERR raised for this person
        -- store error
        l_value := raise_extract_error
                     (p_error_number        =>    94455
                     ,p_error_text          =>    'BEN_94455_PERSON_DTLS_MISSING'
                     );

        END IF;
      close csr_get_person_dtl;
    END IF;

    debug('l_inclusion_flag : '|| l_inclusion_flag,35);


    -- assignment and person details are available
    -- employee_type = 'E', category IS NOT NULL

    IF l_inclusion_flag <> 'N' -- => assignment/person details were found
    THEN
      debug('l_inclusion_flag : '|| l_inclusion_flag,60);

      -- search thru the mapping for this assignment category
      FOR i IN 1..g_assign_category_mapping.COUNT
      LOOP

        IF i=1 THEN -- finding next index
        l_index:=g_assign_category_mapping.FIRST;
        ELSE
        l_index:=g_assign_category_mapping.NEXT(l_index);
        END IF;

        debug('g_assign_category_mapping('||l_index||').pcv_information1 : '
                      || g_assign_category_mapping(l_index).pcv_information1);
        debug('g_assign_category_mapping('||l_index||').pcv_information2 : '
                      || g_assign_category_mapping(l_index).pcv_information2);

        -- start comparing
        IF l_assignment_dtl.employment_category =
           g_assign_category_mapping(l_index).pcv_information1 -- match found!!
        THEN
          l_assignment_category := g_assign_category_mapping(l_index).pcv_information2;

          debug('l_assignment_category : '|| l_assignment_category,65);
          debug('g_assign_category_mapping('||l_index||').pcv_information2 : '
                      || g_assign_category_mapping(l_index).pcv_information2,66);
          debug('match found, exiting FOR loop!',67);

          EXIT; -- match found, exit the FOR loop
        ELSE
          -- ERR - no matching employment category
          debug('Not a match !!',70);
        END IF;

      END LOOP; -- end of FOR loop

      -- match not found after looping thru
      IF l_assignment_category IS NULL
      THEN
        debug('No match was found, this category type doesnt exist in config value mapping!!',75);

        l_inclusion_flag := 'N';
      ELSE -- assignment category match found - casual or regular

        debug('employment category mapping has been found :'||l_assignment_category,90);

        -- 1) if permanent (regular) or fixed term  employee, report
        --115.70 5897563
        IF l_assignment_category in ('REGULAR','FIXED') THEN
          debug('employee is '||l_assignment_category||' , inclusion = Y',110);
          l_inclusion_flag := 'Y';
        ELSE -- not regular, is casual
        -- 2) check if person employed for more than 3 months

          debug('employee is CASUAL, further checks ...',120);

          --
          /*
          debug('Fetching last_hire_date_indicator  ...', 130);
          OPEN  csr_last_hire_date_indicator
                   (
                    p_business_group_id  => p_business_group_id     -- IN
                   ,p_effective_date     => p_effective_date        -- IN
                   ,p_person_id          => l_person_dtl.person_id  -- IN
                   );
          FETCH csr_last_hire_date_indicator into l_last_hire_date_indicator;
            IF csr_last_hire_date_indicator%NOTFOUND THEN
              debug('last hire date < 3 months old',140);
              l_inclusion_flag := 'N'; -- cursor empty as last hire date = within 3 months
            ELSE
              -- further check pension scheme, in case its partner, 'Y' else 'N'
              l_inclusion_flag := check_employee_pension_scheme -- Y/N last hire date > 3 months older
                                  (p_business_group_id  => p_business_group_id
                                  ,p_effective_date     => p_effective_date
                                  ,p_assignment_id      => p_assignment_id
                                  ,p_psi_pension_scheme => 'PARTNER'
                                  ,p_pension_element_type_id => l_pension_element_type_id
                                  );
              --
            END IF;
          CLOSE csr_last_hire_date_indicator;
          */

            -- 115.60
            -- the check for 3 months of service for part timers has been removed
            -- direct check for partnership scheme for part timers

            debug('Check if employee is in PARTNERship scheme...', 130);
            l_inclusion_flag := check_employee_pension_scheme -- Y/N last hire date > 3 months older
                                (p_business_group_id  => p_business_group_id
                                ,p_effective_date     => p_effective_date
                                ,p_assignment_id      => p_assignment_id
                                ,p_psi_pension_scheme => 'PARTNER'
                                ,p_pension_element_type_id => l_pension_element_type_id
                                );
         --Bug 6770167 begin
           IF l_inclusion_flag = 'N'
           THEN
            l_inclusion_flag := check_employee_pension_scheme -- Y/N last hire date > 3 months older
                                (p_business_group_id  => p_business_group_id
                                ,p_effective_date     => p_effective_date
                                ,p_assignment_id      => p_assignment_id
                                ,p_psi_pension_scheme => 'NUVOS'
                                ,p_pension_element_type_id => l_pension_element_type_id
                                 );
            END IF;
            --Bug 6770167 End

        END IF; -- IF l_assignment_category = 'REGULAR' THEN

      END IF; -- IF l_assignment_category IS NULL
    END IF; -- IF l_inclusion_flag <> 'N' -- => assignment/person details were found

    IF l_inclusion_flag <> 'N' THEN
         l_inclusion_flag :=  check_employee_eligibility
                                  (p_business_group_id   =>   p_business_group_id
                                  ,p_assignment_id       =>   p_assignment_id
                                  ,p_effective_date      =>   p_effective_date
                                  ,p_chg_value           =>   g_pension_scheme
                                  );
    END IF;

    debug('l_inclusion_flag (final) : ' || l_inclusion_flag,150);
    debug_exit(l_proc_name);
                                                          -- for PF

      g_prev_assignment_id := p_assignment_id;

      g_prev_effective_date := p_effective_date;
      g_prev_inclusion_flag := l_inclusion_flag;


  return l_inclusion_flag;

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

  END chk_penserver_basic_criteria;

  ----
    FUNCTION is_curr_last_event RETURN BOOLEAN
    IS
        l_proc varchar2(72) := g_proc_name||'.is_curr_last_event';
        l_prev_event_dtl_rec    ben_ext_person.t_detailed_output_tab_rec;
        l_flag                  VARCHAR2(1);
        l_curr_idx   NUMBER;
        l_next_event_dtl_rec  ben_ext_person.t_detailed_output_tab_rec;
        l_curr_event_dtl_rec  ben_ext_person.t_detailed_output_tab_rec;
        l_return     BOOLEAN;
    BEGIN
      debug_enter(l_proc);
      l_curr_idx  :=  ben_ext_person.g_chg_pay_evt_index;

      IF l_curr_idx = ben_ext_person.g_pay_proc_evt_tab.COUNT
        OR l_curr_idx = ben_ext_person.g_pay_proc_evt_tab.COUNT - 1 THEN
          IF l_curr_idx = ben_ext_person.g_pay_proc_evt_tab.COUNT - 1 THEN
             -- if the current is last-1 event. check for duplicate row.
             debug('the current is last-1 event.',30);
             l_curr_event_dtl_rec :=  ben_ext_person.g_pay_proc_evt_tab(l_curr_idx);
             l_next_event_dtl_rec :=  ben_ext_person.g_pay_proc_evt_tab(l_curr_idx+1);
             l_next_event_dtl_rec.change_mode  :=  l_curr_event_dtl_rec.change_mode;
             l_flag  :=  'Y';
              IF l_curr_event_dtl_rec.dated_table_id <>   l_next_event_dtl_rec.dated_table_id THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.datetracked_event <>   l_next_event_dtl_rec.datetracked_event THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.update_type <>   l_next_event_dtl_rec.update_type THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.surrogate_key <>   l_next_event_dtl_rec.surrogate_key THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.column_name <>   l_next_event_dtl_rec.column_name THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.effective_date <>   l_next_event_dtl_rec.effective_date THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.old_value <>   l_next_event_dtl_rec.old_value THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.new_value <>   l_next_event_dtl_rec.new_value THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.change_values <>   l_next_event_dtl_rec.change_values THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.proration_type <>   l_next_event_dtl_rec.proration_type THEN
                  l_flag  :=  'N';
              ELSIF l_curr_event_dtl_rec.event_group_id <>   l_next_event_dtl_rec.event_group_id THEN
                  l_flag  :=  'N';
             ELSIF l_curr_event_dtl_rec.actual_date <>   l_next_event_dtl_rec.actual_date THEN
                  l_flag  :=  'N';
              END IF;
              IF l_flag = 'N' THEN
                  debug('the next event is not the same as the curr one.');
                  l_return := FALSE;
              ELSE
                  debug('the next event is the same as the curr one.');
                  l_return := TRUE;
              END IF;
          ELSE
             debug('Current event is the last one',30);
             l_return := TRUE;
          END IF;
      ELSE
          debug('Current event is NOT the last one',30);
          l_return := FALSE;
      END IF;


      debug_exit(l_proc);
      RETURN l_return;
    END is_curr_last_event;
    ----
-- This function returns the last approved run date for
-- periodic changes
-- ----------------------------------------------------------------------------
-- |----------------------------< get_last_run_date >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_last_run_date
                (p_run_from_cutover_date IN VARCHAR2 -- Bugfix 4969368
                )
     RETURN DATE
   IS
     --

     /*
     -- Cursor to fetch the last successful approved run date
     CURSOR csr_get_run_date
     IS
     SELECT MAX(eff_dt)
       FROM ben_ext_rslt
      WHERE ext_dfn_id = ben_ext_thread.g_ext_dfn_id
        AND business_group_id = g_business_group_id
        AND ext_stat_cd = 'A';
     */

     l_proc_name VARCHAR2(80) := g_proc_name || 'get_last_run_date';
     l_proc_step PLS_INTEGER;
     l_run_date  DATE;
     l_config_value   PQP_UTILITIES.t_config_values;

     l_reference_extract  VARCHAr2(30);
     l_ext_dfn_id     NUMBER;
     --
   BEGIN
     --
     IF g_debug
     THEN
       l_proc_step := 10;
       debug_enter(l_proc_name, l_proc_step);
     END IF;

      /*
      -- fetch reference extract name
      debug('Fetching Effective rolling date window length ...', 40);
      pqp_utilities.get_config_type_values
                   ( p_configuration_type   => 'PQP_GB_PENSERVER_DEFINITION'
                                ,p_business_group_id    => g_business_group_id
                                ,p_legislation_code     => NULL
                                ,p_tab_config_values    => l_config_value
                     );

      IF l_config_value.COUNT > 0 -- config value found
      THEN
        l_reference_extract := l_config_value(l_config_value.FIRST).pcv_information3;
      ELSE
        l_reference_extract := 'BASIC';
      END IF;

      */

      -- performance fix : 1
      IF g_reference_extract = 'BASIC' THEN
        OPEN csr_ext_dfn_id(c_extract_name => 'PQP GB PenServer Periodic Changes Interface - Basic Data');
        FETCH csr_ext_dfn_id INTO l_ext_dfn_id;
        CLOSE csr_ext_dfn_id;
      ELSE
        l_ext_dfn_id := ben_ext_thread.g_ext_dfn_id;
      END IF;


     -- Get the run date
     OPEN csr_get_run_date(c_ext_dfn_id         => l_ext_dfn_id
                          ,c_business_group_id  => g_business_group_id);
     FETCH csr_get_run_date INTO l_run_date,g_output_name;
     CLOSE csr_get_run_date;

     IF g_debug
     THEN
       debug('l_run_date: '||TO_CHAR(l_run_date, 'DD/MON/YYYY'));
     END IF;

     -- Set the run date to cutover date only if this is a
     -- first run
     -- Bugfix 4969368: Setting run date to cutover date if
     --  current interfaces needs to run from cutover date
     --  rather than cutover date +1
     --  Currently only short time hours needs to do this
     IF l_run_date IS NULL THEN
       -- This is the first run, using cutover date
       IF p_run_from_cutover_date = 'Y' THEN
         -- Set the run date to be cutover date
         l_run_date    := g_cutover_date;
       ELSE
         l_run_date    := g_cutover_date + 1;
       END IF;
       --
     ELSE
       -- Bugfix 4969368: Moved +1 logic up here for bugfix
       -- This is not the first run
       -- l_run_date := l_run_date + 1;
       -- For Bug 7615709, commented the above + 1 logic.
       -- This might lead to re-reporting of data that got reported in the last period but
       -- re-reporting is fine as far as we dont miss the data that got created on the last approved date.

         l_run_date := l_run_date;

     END IF; -- End if of l_run_date is null check ...

     -- When this is the first run and the cutover date is not
     -- present default the dates to pension year start date
     IF l_run_date IS NULL
     THEN
        l_run_date    :=
           TO_DATE(
              '01-04-' || TO_CHAR(ben_ext_person.g_effective_date, 'YYYY')
             ,'DD-MM-YYYY'
           );
        IF l_run_date > ben_ext_person.g_effective_date
        THEN
           l_run_date    := ADD_MONTHS(l_run_date, -12);
        END IF;
     -- Bugfix 4969368: Moving this logic of run_date +1 above
     -- to cater for short time hours which should run from
     -- cutover date always
     --ELSE -- run date is not null
     --  l_run_date := l_run_date + 1;
     END IF; -- End if of run date is null check ..

     IF g_debug
     THEN
       l_proc_step := 20;
       debug('l_run_date: '||TO_CHAR(l_run_date, 'DD/MON/YYYY'));
       debug_exit(l_proc_name);
     END IF;

     RETURN l_run_date;
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
   END get_last_run_date;

   -- ----------------------------------------------------------------------------
    -- |---------------------< is_curr_evt_processed >---------------------|
    -- ----------------------------------------------------------------------------
   FUNCTION is_curr_evt_processed RETURN BOOLEAN
    IS
        l_proc varchar2(72) := g_proc_name||'is_curr_evt_processed';
        l_prev_event_dtl_rec    ben_ext_person.t_detailed_output_tab_rec;
        l_flag                  VARCHAR2(1);
    BEGIN
      debug_enter(l_proc);

      IF g_prev_event_dtl_rec.dated_table_id IS NOT NULL THEN
          l_prev_event_dtl_rec  :=  ben_ext_person.g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index);
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
              g_prev_event_dtl_rec  :=  ben_ext_person.g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index);
          END IF;
      ELSE
          debug('First event');
          g_prev_event_dtl_rec  :=  ben_ext_person.g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index);
      END IF;

      debug_exit(l_proc);
      RETURN FALSE;
    END is_curr_evt_processed;
    ----
-- This function evaluates whether an event should be included in the current
-- report or not based on the effectiveness and application date logic
-- ----------------------------------------------------------------------------
-- |----------------------------< include_event >-----------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION include_event (
     p_actual_date IN DATE
    ,p_effective_date IN DATE
    ,p_run_from_cutover_date IN VARCHAR2 -- Bugfix 4969368
    )
    RETURN VARCHAR2
  IS
    --
    l_proc_name VARCHAR2(80) := g_proc_name || 'include_event';
    l_proc_step PLS_INTEGER;
    l_return    VARCHAR2(10);
    l_chg_date  DATE;
    l_chg_table VARCHAR2(80);
    l_chg_type VARCHAR2(10);
    --
  BEGIN
    --
    IF g_debug
    THEN
      l_proc_step := 10;
      debug_enter(l_proc_name);
      debug('p_actual_date: '||TO_CHAR(p_actual_date, 'DD/MON/YYYY'));
      debug('p_effective_date: '||TO_CHAR(p_effective_date, 'DD/MON/YYYY'));
    END IF;

    IF g_effective_start_date IS NULL
    THEN
      -- populate the effective dates
      g_effective_start_date :=
        get_last_run_date(p_run_from_cutover_date => p_run_from_cutover_date -- Bugfix 4969368
                         );
      g_effective_end_date := ben_ext_person.g_effective_date;
    END IF;

    IF g_debug
    THEN
      l_proc_step := 20;
      debug(l_proc_name, l_proc_step);
      debug('g_effective_start_date: '||TO_CHAR(g_effective_start_date, 'DD/MON/YYYY'));
      debug('g_effective_end_date: '||TO_CHAR(g_effective_end_date, 'DD/MON/YYYY'));
    END IF;

    IF NVL(g_person_id, hr_api.g_number) <> ben_ext_person.g_person_id
    THEN
      g_person_id := ben_ext_person.g_person_id;
      g_min_eff_date_exists := 'N';
      debug('NVL(g_person_id, hr_api.g_number) <> ben_ext_person.g_person_id',20);
    END IF;

      -- set the start date of the range to '00:00:00'
      -- and set the end date of the range to '23:59:59'
        g_effective_start_date :=
          fnd_date.canonical_to_date(TO_CHAR(g_effective_start_date,'YYYY/MM/DD'));
        g_effective_end_date   :=
          fnd_date.canonical_to_date((TO_CHAR(g_effective_end_date,'YYYY/MM/DD')||'23:59:59'));

        IF g_debug
        THEN
          debug('g_effective_start_date: '||g_effective_start_date,25);
          debug('g_effective_end_date: '||g_effective_end_date,25);
        END IF;

      --
    l_return := 'Y';

    -- Check whether the actual date is between last run date and extract effective
    -- date or we have already found the earliest effective date or
    -- the effective date is within the run date range and the actual date
    -- is not in the future

    IF l_return <> 'N' AND NOT is_curr_evt_processed THEN
        --
        l_return := 'N';

        IF    (p_actual_date BETWEEN g_effective_start_date AND g_effective_end_date
                AND
               p_effective_date <= g_effective_end_date  -- bug fix 4944134
              )
           OR (
                   (
                       g_min_eff_date_exists = 'Y'
                    OR p_effective_date BETWEEN g_effective_start_date
                                            AND g_effective_end_date
                   )
               AND p_actual_date <= g_effective_end_date
              )
        THEN
          debug('Inside the Then ... ',30);
               IF g_min_eff_date_exists = 'N' AND
                  NOT p_effective_date BETWEEN g_effective_start_date
                                           AND g_effective_end_date
               THEN
                 debug('g_min_eff_date_exists = N and p_effective_date is not between '||
                     'g_eff start and end dates',40);
                 debug('g_assignment_id : '||g_assignment_id,50);

                 g_min_effective_date(g_assignment_id) := p_effective_date;
                 g_min_eff_date_exists := 'Y';


                 IF g_debug
                 THEN

                   l_proc_step := 30;
                   debug(l_proc_name, l_proc_step);
                   IF g_min_effective_date.EXISTS(g_assignment_id) THEN

                     debug(
                           'g_min_effective_date('
                        || g_assignment_id
                        || '): '
                        || TO_CHAR(g_min_effective_date(g_assignment_id), 'DD/MON/YYYY')
                     );
                   ELSE
                     debug('g_min_effective_date.(g_assignment_id) doesnt Exist!',60);
                     debug('g_assignment_id : '|| g_assignment_id,70);
                   END IF;
                   debug('g_min_eff_date_exists: '||g_min_eff_date_exists);

                 END IF;
               END IF;

               l_return := 'Y';
        END IF; -- End if of actual date check ...
    ELSE
        debug('the current event is already processed');
        l_return := 'N';
    END IF;

    -- reject all purge events on element entries
        l_chg_type            :=  ben_ext_person.g_chg_update_type;
        l_chg_table           :=  ben_ext_person.g_chg_pay_table;
        l_chg_date            :=  ben_ext_person.g_chg_eff_dt;

        IF l_chg_table = 'PAY_ELEMENT_ENTRIES_F'
            AND l_chg_type = 'P'
        THEN
            debug('Current event is a Purge on element entries',20);
            debug('This event will be rejected.',20);
            l_return := 'N';
        END IF;
    ----------

    IF g_debug
    THEN
      l_proc_step := 40;
      debug('l_return: '||l_return);
      debug_exit(l_proc_name);
    END IF;

    RETURN l_return;
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
   END include_event;


-- This procedure will be used in the future to add any new logic for
-- retro event processing
-- ----------------------------------------------------------------------------
-- |----------------------------< process_retro_event >-----------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE process_retro_event
              (
              p_include   VARCHAR2  DEFAULT 'Y'
              )
   IS
      --
      l_proc_name   VARCHAR2(80) := g_proc_name || 'process_retro_event';
      l_proc_step   PLS_INTEGER;
      l_value       NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step    := 10;
         debug_enter(l_proc_name);
      END IF;

      -- At the moment check for presence of any retro events and raise a
      -- suitable warning message
      IF g_min_effective_date.EXISTS(g_assignment_id)
      THEN
         IF g_debug
         THEN
            DEBUG('Raise Warning Message: Retro Event Exists');
            DEBUG(
                  'g_min_effective_date('
               || g_assignment_id
               || '): '
               || g_min_effective_date(g_assignment_id)
            );
         END IF;

         -- retro event exists
         l_value    :=
            raise_extract_warning(
               p_error_text        => 'BEN_94482_EXT_PSI_OVR_EVNT_WRN'
              ,p_error_number      => 94482
              ,p_token1 => fnd_date.date_to_displaydt(g_min_effective_date(g_assignment_id))
            );


          IF NOT g_retro_event_date_reported THEN
              -- if the retro event date is not reported in the DE
              -- if p_include is 'N' check if this is the last event.
              debug('Retro event date is not reported',20);
              IF p_include = 'N' THEN
                  IF is_curr_last_event() THEN
                      -- raise data error
                      debug('Raise an error as the delete event could not be reported',30);
                      debug('Current event is the last event, g_retro_event_date_reported is rest to true.',30);
                      l_value    :=
                                    raise_extract_error(
                                       p_error_text        => 'BEN_94540_FIRST_RETRO_DATE'
                                      ,p_error_number      => 94540
                                      ,p_token1 => fnd_date.date_to_displaydt(g_min_effective_date(g_assignment_id))
                                    );
                      g_retro_event_date_reported :=  TRUE;
                  END IF;
              ELSE
                  debug('Delete date should be reported in the current row: '||g_min_effective_date(g_assignment_id),20);
              END IF;
          ELSE
              -- clear the retro_event_date global value, so that the DE reports a null value.
              debug('retro event date is already reported.',20);

          END IF; --IF NOT g_retro_event_date_reported

      END IF; -- End if of min effective date exists check ...
      IF g_debug
      THEN
         l_proc_step    := 20;
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
   END process_retro_event;
-- ----------------------------------------------------------------------------
    -- |--------------------------< get_dated_table_name >-------------------------|
    --  Description:
    -- ----------------------------------------------------------------------------
    FUNCTION get_dated_table_name
                (
                p_dated_table_id    NUMBER
                )RETURN VARCHAR2
    IS
        l_table_name        VARCHAR2(80);
        CURSOR csr_dated_table_name
        IS
            SELECT table_name
            FROM pay_dated_tables
            WHERE dated_table_id = p_dated_table_id;
    BEGIN
        IF NOT g_dated_tables.exists(p_dated_table_id) THEN
            OPEN csr_dated_table_name;
            FETCH csr_dated_table_name INTO l_table_name;
            CLOSE csr_dated_table_name;
            g_dated_tables(p_dated_table_id)  :=  l_table_name;
        END IF;

        return g_dated_tables(p_dated_table_id);
    END get_dated_table_name;


   -- ----------------------------------------------------------------------------
    -- |----------------------< chk_is_employee_a_leaver >--------------------------|
    --  Description:  This is to check if the assignment is ending on the effective date
    --                  p_leaver_date will be the value of the assignment leaver date.
    -- ----------------------------------------------------------------------------
    FUNCTION chk_is_employee_a_leaver
                (
                p_assignment_id     NUMBER
                ,p_effective_date   DATE
                ,p_leaver_date      OUT NOCOPY DATE
                ) RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_proc_name||'chk_is_employee_a_leaver';
        l_leaver  VARCHAR2(1) := 'N';
        l_pay_assg_status   VARCHAR2(20);
        CURSOR csr_asg_details_up -- effective first then future rows
                   (p_assignment_id     NUMBER
                   ,p_effective_date    DATE  DEFAULT NULL
                   )
        IS
           SELECT asg.person_id                          person_id
                ,asg.assignment_id                      assignment_id
                ,asg.business_group_id                  business_group_id
                ,asg.effective_start_date               start_date
                ,asg.effective_end_date                 effective_end_date
                ,asg.creation_date                      creation_date
                ,asg.assignment_status_type_id          status_type_id
                ,'                              '       status_type
            FROM per_all_assignments_f asg

           WHERE asg.assignment_id = p_assignment_id
             AND (( p_effective_date BETWEEN asg.effective_start_date
                                          AND asg.effective_end_date )
                  OR
                   ( asg.effective_start_date = p_effective_date + 1 ) -- modified for 115.68
                 )
           ORDER BY asg.effective_start_date ASC; -- effective first then future rows

        CURSOR csr_assignment_status
                  (
                  p_assignment_status_type_id NUMBER
                  )
        IS
             SELECT DECODE(pay_system_status,'D','DO NOT PROCESS','P','PROCESS')
                    ,per_system_status
             FROM per_assignment_status_types
             WHERE ASSIGNMENT_STATUS_TYPE_ID = p_assignment_status_type_id
             AND  primary_flag = 'P';

        l_asg_details          csr_asg_details_up%ROWTYPE;
        l_next_asg_details     csr_asg_details_up%ROWTYPE;
    BEGIN
        debug_enter(l_proc);

        OPEN csr_asg_details_up
                (p_assignment_id
                ,p_effective_date - 1
                );
        FETCH csr_asg_details_up INTO l_asg_details;
        IF csr_asg_details_up%FOUND THEN
               debug('Inside IF , found ASG record',30);
               -- Get the per_system_status for the assignment_status_type_id
               OPEN csr_assignment_status(l_asg_details.status_type_id);
               FETCH csr_assignment_status INTO l_pay_assg_status,l_asg_details.status_type;
               CLOSE csr_assignment_status;

               debug('l_asg_details.status_type: '||l_asg_details.status_type,20);
               debug('l_asg_details.effective_start_date: '||l_asg_details.start_date,20);
               debug('l_asg_details.effective_end_date: '||l_asg_details.effective_end_date,20);

               -- Get the next assignment and compare status type
               FETCH csr_asg_details_up INTO l_next_asg_details;
               OPEN csr_assignment_status(l_next_asg_details.status_type_id);
               FETCH csr_assignment_status INTO l_pay_assg_status,l_next_asg_details.status_type;
               CLOSE csr_assignment_status;

               debug('After second fetch',40);
               debug('l_next_asg_details.status_type: '||l_next_asg_details.status_type,20);
               debug('l_next_asg_details.effective_start_date: '||l_next_asg_details.start_date,20);
               debug('l_next_asg_details.effective_end_date: '||l_next_asg_details.effective_end_date,20);
                IF (csr_asg_details_up%FOUND
                    AND
                    l_asg_details.status_type <> l_next_asg_details.status_type
                    AND
                    l_next_asg_details.status_type IN ('TERM_ASSIGN','SUSP_ASSIGN','END')
                   )
                   OR
                   -- No future rows found
                   (csr_asg_details_up%NOTFOUND
                    AND
                    -- But the current assignment has been suspended or is Active
                    -- Added Active as a bugfix as END Employment does not change status
                    -- when the termination happens on the last day of the payroll period

                    --l_asg_details.status_type IN ('SUSP_ASSIGN','ACTIVE_ASSIGN')
                     l_asg_details.effective_end_date = p_effective_date
                   )
                   THEN

                  -- Assignment has been terminated/suspended/ended
                  l_leaver := 'Y';
                  p_leaver_date := l_asg_details.effective_end_date;

                  debug('Assignment is a leaver',50);

              END IF; -- csr_asg_details_up%FOUND THEN
        END IF; -- IF csr_asg_details_up%FOUND

        IF csr_asg_details_up%ISOPEN THEN
          CLOSE csr_asg_details_up;
        END IF;

        debug_exit(l_proc);
        return l_leaver;
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
    END chk_is_employee_a_leaver;
    ------


    -- ----------------------------------------------------------------------------
    -- |-----------------------< is_proper_claim_date >--------------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION is_proper_claim_date
                (
                p_claim_date        IN DATE
                ,p_element_name     IN VARCHAR2
                ,p_element_entry_id IN NUMBER
                ,p_assg_start_date  IN DATE
                )RETURN BOOLEAN
    IS
        l_proc varchar2(72) := g_proc_name||'is_proper_claim_date';
        l_temp    NUMBER;
        l_return  BOOLEAN;
        l_include   VARCHAR2(10)  :=  'Y';
        l_assignment_status_type_id NUMBER;
        l_pay_assg_status   VARCHAR2(20);
        l_per_assg_status   per_assignment_status_types.per_system_status%TYPE;
        l_curr_person_dtls             per_all_people_f%ROWTYPE;
                -- this contains the person details on effective date

        l_curr_assg_dtls               per_all_assignments_f%ROWTYPE;
                -- this contains the person details on effective date
        CURSOR csr_assignment_status
                      (
                      p_assignment_status_type_id NUMBER
                      )
            IS
                 SELECT DECODE(pay_system_status,'D','DO NOT PROCESS','P','PROCESS')
                        ,per_system_status
                 FROM per_assignment_status_types
                 WHERE ASSIGNMENT_STATUS_TYPE_ID = p_assignment_status_type_id
                 AND  primary_flag = 'P';

    BEGIN -- is_future_claim
        debug_enter(l_proc);
        IF g_debug THEN
            debug('Inputs are: ',10);
            debug('p_claim_date: '||p_claim_date,10);
            debug('p_element_name: '||p_element_name,10);
            debug('p_element_entry_id: '||p_element_entry_id,10);
            debug('p_assg_start_date: '||p_assg_start_date,10);

            debug('g_effective_start_date: '||PQP_GB_PSI_FUNCTIONS.g_effective_start_date);
            debug('g_effective_end_date: '||PQP_GB_PSI_FUNCTIONS.g_effective_end_date);
        END IF;


        IF p_claim_date < p_assg_start_date THEN
            -- claim date is before the start date of the person
            debug('ERROR: Future Claim Date: '||ben_ext_person.g_chg_surrogate_key);
            l_temp :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94513
                               ,p_error_text          =>    'BEN_94513_EARLY_CLAIM_DATE'
                               ,p_token1              =>    p_claim_date
                               ,p_token2              =>    SUBSTR(p_element_name
                                                                     ||'('||p_element_entry_id||')',1,80)
                               );

            debug('Returning FALSE',20);
            debug_exit(l_proc);
            RETURN FALSE;

        END IF; --IF p_claim_date > PQP_GB_PSI_FUNCTIONS.g_effective_end_date THEN

        IF p_claim_date > PQP_GB_PSI_FUNCTIONS.g_effective_end_date THEN

            debug('ERROR: Future Claim Date: '||ben_ext_person.g_chg_surrogate_key);
            l_temp :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94512
                               ,p_error_text          =>    'BEN_94512_FUTURE_CLAIM_DATE'
                               ,p_token1              =>    p_claim_date
                               ,p_token2              =>    SUBSTR(p_element_name
                                                                     ||'('||p_element_entry_id||')',1,80)
                               );

            debug('Returning FALSE',20);
            debug_exit(l_proc);
            RETURN FALSE;

        END IF;

        l_assignment_status_type_id :=  l_curr_assg_dtls.assignment_status_type_id;
        OPEN csr_assignment_status(l_assignment_status_type_id);
        FETCH csr_assignment_status INTO l_pay_assg_status,l_per_assg_status;
        CLOSE csr_assignment_status;

        debug('l_assignment_status_type_id: '||l_assignment_status_type_id,20);
        debug('l_pay_assg_status: '||l_pay_assg_status,20);
        debug('l_per_assg_status: '||l_per_assg_status,20);
        IF l_pay_assg_status = 'DO NOT PROCESS'
          OR l_per_assg_status IN ('TERM_ASSIGN','SUSP_ASSIGN','END') THEN

            debug('ERROR: Assignment does not qualify on the claim date');
            l_temp :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                               (p_error_number        =>    94539
                               ,p_error_text          =>    'BEN_94539_ASG_TERM_CLAIM_DATE'
                               ,p_token1              =>    p_claim_date
                               ,p_token2              =>    SUBSTR(p_element_name
                                                                 ||'('||p_element_entry_id||')',1,80)
                               );
            l_include :=  'N';
        ELSE
            debug('Assignment status is a valid one.',30);
            l_include :=  'Y';
        END IF;

        IF l_include <> 'N' THEN

              l_include :=  PQP_GB_PSI_FUNCTIONS.chk_penserver_basic_criteria
                                (p_business_group_id        =>  g_business_group_id
                                ,p_effective_date           =>  p_claim_date
                                ,p_assignment_id            =>  g_assignment_id
                                ,p_person_dtl               =>  l_curr_person_dtls
                                ,p_assignment_dtl           =>  l_curr_assg_dtls
                                );

              IF l_include = 'N' THEN
                    debug('ERROR: Assignment does not qualify on the claim date');
                    l_temp :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                     (p_error_number        =>    94542
                                     ,p_error_text          =>    'BEN_94542_ASG_INV_CLAIM_DATE'
                                     ,p_token1              =>    p_claim_date
                                     ,p_token2              =>    SUBSTR(p_element_name
                                                                           ||'('||p_element_entry_id||')',1,80)
                                     );
                    l_include :=  'N';

              END IF;

        END IF;
        IF l_include =  'N' THEN
           l_return :=  FALSE;
           debug('Returning FALSE',20);
        ELSE
           l_return :=  TRUE;
           debug('Returning TRUE',20);
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
    END is_proper_claim_date;



-- ----------------------------------------------------------------------------
-- |------------------------< get_elements_of_info_type >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE get_elements_of_info_type
      (p_information_type         IN VARCHAR2
      ,p_input_value              IN VARCHAR2 DEFAULT 'PAY VALUE'
      ,p_input_value_mandatory_yn IN VARCHAR2 DEFAULT 'Y'
      )
IS
  --
    l_proc_name           VARCHAR2(61):=
     g_proc_name||'get_elements_of_info_type';


BEGIN
  debug_enter(l_proc_name);
  debug ('p_information_type:'||p_information_type);

  IF p_input_value_mandatory_yn = 'Y'
  THEN

    FOR l_elements_rec in csr_get_elements_of_info_type
                          (c_information_type => p_information_type
                          ,c_input_value      => p_input_value
                          )
    LOOP

      IF l_elements_rec.element_type_id IS NOT NULL
      THEN
        debug('element_type_id : '||l_elements_rec.element_type_id);
        debug('element_name : '||l_elements_rec.element_name);
        debug('input_value_id : '||l_elements_rec.input_value_id);
        debug('processing_type : '||l_elements_rec.processing_type);
        debug('eei_information1 : '||l_elements_rec.eei_information1);
        debug('eei_information2 : '||l_elements_rec.eei_information2);
        debug('eei_information3 : '||l_elements_rec.eei_information3);
        debug('eei_information4 : '||l_elements_rec.eei_information4);
        debug('eei_information5 : '||l_elements_rec.eei_information5);
        debug('eei_information6 : '||l_elements_rec.eei_information6);
        debug('eei_information7 : '||l_elements_rec.eei_information7);
        debug('eei_information8 : '||l_elements_rec.eei_information8);
        debug('eei_information9 : '||l_elements_rec.eei_information9);
        debug('eei_information10 : '||l_elements_rec.eei_information10);
        debug('retro_summ_ele_id : '||l_elements_rec.retro_summ_ele_id);

        g_elements_of_info_type(l_elements_rec.element_type_id) := l_elements_rec;
      END IF;

    END LOOP;
  ELSE
    FOR l_elements_rec_no_inp_val in csr_ele_info_type_no_inp_val
                                      (c_information_type => p_information_type
                                      )
    LOOP

      IF l_elements_rec_no_inp_val.element_type_id IS NOT NULL
      THEN
        debug('element_type_id : '||l_elements_rec_no_inp_val.element_type_id);
        debug('element_name : '||l_elements_rec_no_inp_val.element_name);
        debug('processing_type : '||l_elements_rec_no_inp_val.processing_type);
        debug('eei_information1 : '||l_elements_rec_no_inp_val.eei_information1);
        debug('eei_information2 : '||l_elements_rec_no_inp_val.eei_information2);
        debug('eei_information3 : '||l_elements_rec_no_inp_val.eei_information3);
        debug('eei_information4 : '||l_elements_rec_no_inp_val.eei_information4);
        debug('eei_information5 : '||l_elements_rec_no_inp_val.eei_information5);
        debug('eei_information6 : '||l_elements_rec_no_inp_val.eei_information6);
        debug('eei_information7 : '||l_elements_rec_no_inp_val.eei_information7);
        debug('eei_information8 : '||l_elements_rec_no_inp_val.eei_information8);
        debug('eei_information9 : '||l_elements_rec_no_inp_val.eei_information9);
        debug('eei_information10 : '||l_elements_rec_no_inp_val.eei_information10);
        debug('retro_summ_ele_id : '||l_elements_rec_no_inp_val.retro_summ_ele_id);

        g_elements_of_info_type(l_elements_rec_no_inp_val.element_type_id) := l_elements_rec_no_inp_val;
      END IF;

    END LOOP;
  END IF;

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

END get_elements_of_info_type;



-- ----------------------------------------------------------------------------
-- |------------------------< check_if_element_qualifies >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_if_element_qualifies
      (p_element_entry_id                  IN  NUMBER
      ,p_element_type_id                   OUT NOCOPY NUMBER
      ,p_include                           OUT NOCOPY VARCHAR2 -- Y/N
      ,p_extract_type                      IN  VARCHAR2 DEFAULT 'PERIODIC'
      ,p_element_type_id_from_crit         IN  NUMBER DEFAULT NULL
      )
IS
  --
    l_proc_name           VARCHAR2(61):=
     g_proc_name||'check_if_element_qualifies';

    l_element_type_id     NUMBER;

BEGIN
  debug_enter(l_proc_name);
  debug ('p_element_entry_id:'||p_element_entry_id);

  -- check if this element_entry_id has been processed earlier
  -- if yes, return data from global collection
  IF g_elements_processed.EXISTS(p_element_entry_id)
  THEN
    debug('found p_element_entry_id in g_elements_processed',10);

    p_element_type_id :=
      g_elements_processed(p_element_entry_id).element_type_id;

    /*
    -- if cutover, then dont process the same element twice
    -- hence send inclusion flag as 'N' if found in collection
    IF    p_extract_type = 'CUTOVER'
    THEN
      p_include := 'N';
    ELSE
      p_include :=
        g_elements_processed(p_element_entry_id).inclusion_flag;
    END IF;
    */

    p_include :=
      g_elements_processed(p_element_entry_id).inclusion_flag;

    g_curr_element_type_id  := p_element_type_id;
    g_curr_element_entry_id := p_element_entry_id;

    debug('g_curr_element_type_id : '||g_curr_element_type_id, 20);
    debug('g_curr_element_entry_id : '||g_curr_element_entry_id, 30);


  ELSE -- 1st time processing, not found in g_elements_processed

    -- if CUTOVER, implies that this has been called from Payroll_Rule
    -- and element_type_id has been passed as p_element_type_id_from_crit
    --
    debug('first time processing ...');
    debug('p_extract_type :' || p_extract_type, 20);
    debug('p_element_type_id_from_crit :' || p_element_type_id_from_crit, 30);

    IF   p_extract_type = 'CUTOVER' -- from cutover rule : element repeating
      OR p_element_type_id_from_crit IS NOT NULL -- from periodic rule : element repeating
    THEN
      p_element_type_id := p_element_type_id_from_crit;
    ELSE -- PERIODIC run : person repeating

      OPEN csr_get_element_type_id
           (c_element_entry_id => p_element_entry_id
           );
      FETCH csr_get_element_type_id INTO l_element_type_id;
        IF csr_get_element_type_id%NOTFOUND
        THEN
          debug('element_type_id not found', 40);
          p_element_type_id := -1; -- returning -1 when not found
          p_include         := 'N';
        ELSE
          p_element_type_id := l_element_type_id;
          debug('l_element_type_id : ' || l_element_type_id, 50);
        END IF; -- csr_get_element_type_id%NOTFOUND
      CLOSE csr_get_element_type_id;

    END IF;
    --

    -- now check if this element_type_id exists in the global collection
    IF g_elements_of_info_type.EXISTS(p_element_type_id)
    THEN
      p_include       := 'Y';
    ELSE
      p_include       := 'N';
    END IF;
    debug('p_include : ' || p_include, 60);

    -- store in a collection for future use in the beginning IF statement
    g_elements_processed(p_element_entry_id).element_type_id := p_element_type_id;
    g_elements_processed(p_element_entry_id).inclusion_flag := p_include;

    g_curr_element_type_id := p_element_type_id;
    g_curr_element_entry_id := p_element_entry_id;

    debug('g_curr_element_type_id : '||g_curr_element_type_id, 70);
    debug('g_curr_element_entry_id : '||g_curr_element_entry_id, 80);

  END IF; -- g_elements_processed.EXISTS(p_element_entry_id)


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

END check_if_element_qualifies;




-- ----------------------------------------------------------------------------
-- |------------------------< calc_payment_by_run_rslt >----------------------|
-- ----------------------------------------------------------------------------
-- to return the run result value for the assignment

FUNCTION calc_payment_by_run_rslt
      (p_assignment_id    IN NUMBER
  ,p_element_entry_id IN NUMBER
  ,p_element_type_id  IN NUMBER
  ,p_date_earned      IN DATE
  )  RETURN NUMBER
IS

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'calc_payment_by_run_rslt';


  l_asg_act_id         NUMBER := NULL;
  l_retro_asg_act_id NUMBER := NULL;

  l_run_result_value NUMBER := NULL;
  l_retro_run_result_value NUMBER := 0;
  l_run_result_id    NUMBER;

  l_element_type_id  NUMBER;
  l_input_value_id   NUMBER;

  l_retro_element_type_id NUMBER;

  -- cursor to find retro_element_type_id
  CURSOR csr_get_retro_ele_type_id
  IS
  select retro_summ_ele_id
    from pay_element_types_f
   where element_type_id = p_element_type_id
   and rownum=1;


BEGIN
  debug_enter(l_proc_name);

    debug('p_assignment_id :' || p_assignment_id);
    debug('p_element_entry_id :'||p_element_entry_id);
    debug('p_element_type_id :'||p_element_type_id);
    debug('p_date_earned :' || p_date_earned);


    -- Step 1) get assignment action id
    OPEN csr_get_asg_act_id
           ( p_assignment_id   => p_assignment_id
            ,p_date_earned     => p_date_earned
           );
    LOOP -- 115.60 : loop thru all assignment actions

      FETCH csr_get_asg_act_id INTO l_asg_act_id;
      EXIT WHEN csr_get_asg_act_id%NOTFOUND;

        debug('l_asg_act_id : '||l_asg_act_id, 15);
        debug('call csr_get_run_result_value for this assignment action id ...',17);

        -- Step 2) find run_results for this assignment_action, element entry and input value
        OPEN csr_get_run_result_value
            (p_element_entry_id => p_element_entry_id -- p_element_type_id
            ,p_input_value_id   =>
                g_elements_of_info_type(p_element_type_id).input_value_id
            ,p_asg_act_id       => l_asg_act_id
            );
        FETCH csr_get_run_result_value INTO l_run_result_value, l_run_result_id;
          IF csr_get_run_result_value%FOUND
          THEN
            debug('l_run_result_value found....',20);
            debug('l_run_result_value : '||l_run_result_value);
            CLOSE csr_get_run_result_value;
            EXIT; -- if the run result was found in this assignment_action_id,
                  -- then exit
                  -- else go for next assignment_action_id
          END IF;
          debug('l_run_result_value not found yet',25);
        CLOSE csr_get_run_result_value;

    END LOOP;
    CLOSE csr_get_asg_act_id;

    --
    -- added as part of 115.58 (3)
    --
    -- BLOCK for retro payments

    -- 1) find if this element has a retro element
    IF g_elements_of_info_type(p_element_type_id).retro_summ_ele_id IS NOT NULL
    THEN -- retro element is attached to this element

      debug('this main element has a retro element ',40);

      l_retro_element_type_id :=
          g_elements_of_info_type(p_element_type_id).retro_summ_ele_id;
      debug('l_retro_element_type_id :' || l_retro_element_type_id,50);

      -- 2) retro element has been found for this main element,
      --    now find retro assignment action id

      OPEN csr_get_asg_act_id_retro
             ( p_assignment_id   => p_assignment_id
              ,p_date_earned     => p_date_earned
             );
      LOOP
        FETCH csr_get_asg_act_id_retro INTO l_retro_asg_act_id;
        EXIT WHEN csr_get_asg_act_id_retro%NOTFOUND;

          debug('l_retro_asg_act_id : '||l_retro_asg_act_id, 35);

          -- 3) now find and add retro payments which were earned in this month
          FOR l_retro_run_results IN csr_get_retro_run_value
                                     (p_assignment_action_id => l_retro_asg_act_id
                                     ,p_effective_date       => ben_ext_person.g_effective_date
                                     )
          LOOP
            debug('input_value_id : '|| l_retro_run_results.input_value_id,60);
            debug('result_value : '|| l_retro_run_results.result_value);
            debug('effective_date : '|| l_retro_run_results.effective_date);
            debug('element_entry_id : '|| l_retro_run_results.element_entry_id);
            debug('element_type_id : '|| l_retro_run_results.element_type_id);
            debug('effective_start_date : '|| l_retro_run_results.effective_start_date);
            debug('effective_end_date : '|| l_retro_run_results.effective_end_date);
            debug('Element source_id : '|| l_retro_run_results.ee_source_id);
            debug('Run Result source_id : '|| l_retro_run_results.rr_source_id);
            debug('status : '|| l_retro_run_results.status);
            debug('source_type : '|| l_retro_run_results.source_type);


            IF l_retro_run_results.result_value IS NOT NULL
              and l_retro_run_results.element_type_id = l_retro_element_type_id
              and l_retro_run_results.ee_source_id = l_run_result_id
            THEN -- run result is not empty
                 -- and element_type_id of retro element = retro_summ_ele_id of main element
              -- 3) add all retro values of this element and this payroll period
              l_retro_run_result_value :=
                l_retro_run_result_value + l_retro_run_results.result_value;

              debug('l_retro_run_result_value : '|| l_retro_run_result_value);
            END IF;
          END LOOP;

      END LOOP; -- OPEN csr_get_asg_act_id_retro
      CLOSE csr_get_asg_act_id_retro;

    END IF; -- IF g_elements_of_info_type(p_element_type_id).retro_summ_ele_id IS NOT NULL


    debug('l_run_result_value : ' || l_run_result_value,70);
    debug('l_retro_run_result_value : ' || l_retro_run_result_value,80);
    -- add the run results and retro results
    IF l_run_result_value IS NOT NULL
      OR l_retro_run_result_value IS NOT NULL
    THEN
      l_run_result_value := nvl(l_run_result_value,0) + nvl(l_retro_run_result_value,0);
    END IF;

    debug('l_run_result_value : ' || l_run_result_value,90);

  debug_exit(l_proc_name);

  return l_run_result_value;

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

END calc_payment_by_run_rslt;


-- ----------------------------------------------------------------------------
-- |------------------------< get_element_payment >---------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_element_payment
      (p_assignment_id      IN NUMBER
  ,p_element_entry_id   IN NUMBER
  ,p_element_type_id    IN NUMBER
  ,p_effective_date     IN DATE
  )  RETURN NUMBER
IS


  l_proc_name           VARCHAR2(61):=
     g_proc_name||'get_element_payment';

  l_date_earned   DATE;
  l_payment       NUMBER := NULL;

BEGIN

  debug_enter(l_proc_name);
  debug('p_assignment_id :' || p_assignment_id) ;
  debug('p_effective_date :' ||to_char(p_effective_date,'DD/MM/YYYY')) ;

    OPEN csr_get_next_payroll_date
           ( p_assignment_id    => p_assignment_id
            ,p_effective_date   => p_effective_date
            );
    FETCH csr_get_next_payroll_date INTO l_date_earned;

      IF csr_get_next_payroll_date%FOUND THEN

        debug('l_date_earned :' ||to_char(l_date_earned,'DD/MM/YYYY')) ;
        l_payment := calc_payment_by_run_rslt
                         ( p_assignment_id    => p_assignment_id
                          ,p_element_entry_id => p_element_entry_id
                          ,p_element_type_id  => p_element_type_id
                          ,p_date_earned      => l_date_earned
                          );
        debug('l_payment :' || l_payment);

      ELSE
        debug('csr_get_next_payroll_date not found') ;
        --l_payment := 0;
      END IF;

    CLOSE csr_get_next_payroll_date;

  debug_exit(l_proc_name);
  return l_payment;

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

END get_element_payment;



-- ----------------------------------------------------------------------------
-- |------------------------< get_value_from_balance >----------------------|
-- ----------------------------------------------------------------------------
-- to return the balance value of an assignment, date earned, element entry
FUNCTION get_value_from_balance
      (p_assignment_id    IN NUMBER
  ,p_element_entry_id IN NUMBER
  ,p_balance_type_id  IN NUMBER
  ,p_date_earned      IN DATE
  ,p_asg_act_id       OUT NOCOPY NUMBER
  ,p_retro_asg_act_id OUT NOCOPY NUMBER
  )  RETURN NUMBER
IS

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'get_value_from_balance';

  l_asg_act_id          NUMBER := NULL;
  l_source_asg_act_id NUMBER := NULL;
  l_balance_value NUMBER := NULL;

BEGIN

  debug_enter(l_proc_name);

    -- Step 1) get assignment action id
    OPEN csr_get_all_asg_act_id
           ( p_assignment_id   => p_assignment_id
            ,p_date_earned     => p_date_earned
            ,p_element_entry_id => p_element_entry_id
           );
    LOOP -- loop thru all assignment actions

      FETCH csr_get_all_asg_act_id INTO l_asg_act_id, l_source_asg_act_id;
      EXIT WHEN csr_get_all_asg_act_id%NOTFOUND;

        debug('l_asg_act_id : '||l_asg_act_id, 15);
        debug('l_source_asg_act_id : '||l_source_asg_act_id, 16);
        debug('call hr_gbbal.calc_element_ptd_bal for this assignment action id ...',17);

        -- Step 2) fetch from balance for this assignment_action and element entry
        l_balance_value :=
             hr_gbbal.calc_element_ptd_bal(p_assignment_action_id => l_asg_act_id
                                          ,p_balance_type_id      => p_balance_type_id
                                          ,p_source_id                => p_element_entry_id);


        IF l_balance_value IS NOT NULL
        THEN

          debug('l_balance_value found....',20);
          debug('l_balance_value : '||l_balance_value,21);
          debug('l_asg_act_id : '||l_asg_act_id, 22);
          debug('l_source_asg_act_id : '||l_source_asg_act_id, 23);
          p_asg_act_id       := l_asg_act_id;
          p_retro_asg_act_id := l_source_asg_act_id;

          EXIT; -- if the run result was found in this assignment_action_id,
                -- then exit
                -- else go for next assignment_action_id
        END IF;
        debug('l_balance_value not found yet',25);

    END LOOP;
    CLOSE csr_get_all_asg_act_id;

  debug_exit(l_proc_name);

  return l_balance_value;

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

END get_value_from_balance;



-- ----------------------------------------------------------------------------
-- |------------------------< calc_payment_from_balance >----------------------|
-- ----------------------------------------------------------------------------
-- to return the run result value for the assignment

FUNCTION calc_payment_from_balance
      (p_assignment_id    IN NUMBER
  ,p_element_entry_id IN NUMBER
  ,p_element_type_id  IN NUMBER
  ,p_balance_type_id  IN NUMBER
  ,p_date_earned      IN DATE
  )  RETURN NUMBER
IS

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'calc_payment_from_balance';


  l_asg_act_id          NUMBER := NULL;
  l_retro_asg_act_id  NUMBER := NULL;
  l_number            NUMBER := NULL;

  l_balance_ele_value         NUMBER := NULL;
  l_retro_balance_ele_value   NUMBER := NULL;
  l_total_retro_bal_ele_value NUMBER := 0;


  l_run_results_dtls csr_run_rslt_indirect_ele%rowtype;
  l_retro_ele        csr_retro_ele%rowtype;

  -- For Bug 9150874
  l_retro_ele_check        csr_retro_ele_check%rowtype;

  -- cursor to find retro_element_type_id
  CURSOR csr_get_retro_ele_type_id
  IS
  select retro_summ_ele_id
    from pay_element_types_f
   where element_type_id = p_element_type_id
   and rownum=1;


BEGIN
  debug_enter(l_proc_name);

    debug('p_assignment_id :' || p_assignment_id);
    debug('p_element_entry_id :'||p_element_entry_id);
    debug('p_element_type_id :'||p_element_type_id);
    debug('p_date_earned :' || p_date_earned);

    -- get the balance value for this element and its indirects
    l_balance_ele_value := get_value_from_balance
                              (p_assignment_id    => p_assignment_id
                              ,p_element_entry_id => p_element_entry_id
                              ,p_balance_type_id  => p_balance_type_id
                              ,p_date_earned      => p_date_earned
                              ,p_asg_act_id       => l_asg_act_id -- OUT
                              ,p_retro_asg_act_id => l_retro_asg_act_id -- OUT
                              );


    --
    -- BLOCK for retro payments
    --

    -- Step 1) get data from pay_run_results
    --         for this element_entry_id and assignment action
    -- Note : l_asg_act_id is the assignment_action which had returned
    -- the balance value in the call above
    IF l_asg_act_id IS NOT NULL
     and
       l_retro_asg_act_id IS NOT NULL
    THEN

      -- get run_result details for this element entry and its indirect elements
      OPEN csr_run_rslt_indirect_ele
         (p_source_id      => p_element_entry_id
         ,p_asg_act_id     => l_asg_act_id
         );
      LOOP -- loop thru all the run_result_ids
        FETCH csr_run_rslt_indirect_ele INTO l_run_results_dtls;
        EXIT WHEN csr_run_rslt_indirect_ele%NOTFOUND;

          debug('l_run_results_dtls.run_result_id : '||l_run_results_dtls.run_result_id, 30);
          debug('ELEMENT_TYPE_ID      : '||l_run_results_dtls.run_result_id, 30);
          debug('ASSIGNMENT_ACTION_ID : '||l_run_results_dtls.assignment_action_id, 30);
          debug('ENTRY_TYPE           : '||l_run_results_dtls.entry_type, 30);
          debug('SOURCE_ID            : '||l_run_results_dtls.source_id, 30);
          debug('SOURCE_TYPE          : '||l_run_results_dtls.source_type, 30);
          debug('STATUS               : '||l_run_results_dtls.status, 30);
          debug('ELEMENT_ENTRY_ID     : '||l_run_results_dtls.element_entry_id, 30);

          debug('l_run_results_dtls.run_result_id : ' || l_run_results_dtls.run_result_id);
          debug('l_retro_asg_act_id : ' || l_retro_asg_act_id );
          debug('ben_ext_person.g_effective_date : ' || ben_ext_person.g_effective_date );

          -- fetch retro elements using this main elements run_result_id
          -- For bug 8652303, Added paramater p_ele_enry_id
          OPEN csr_retro_ele
                 (p_assignment_id        => p_assignment_id
                 ,p_source_id            => l_run_results_dtls.run_result_id
                 ,p_source_asg_action_id => l_retro_asg_act_id
                 ,p_effective_date       => ben_ext_person.g_effective_date -- p_date_earned
                 ,p_ele_entry_id         => l_run_results_dtls.element_entry_id
                 );
          LOOP -- loop thru all the retro elements returned
            FETCH csr_retro_ele INTO l_retro_ele;
            EXIT WHEN csr_retro_ele%NOTFOUND;

              debug('l_retro_ele.element_entry_id : '||l_retro_ele.element_entry_id, 40);
              debug('effective_start_date         : '||l_retro_ele.effective_start_date, 40);
              debug('effective_end_date           : '||l_retro_ele.effective_end_date, 40);
              debug('source_id                    : '||l_retro_ele.source_id, 40);
              debug('source_asg_action_id         : '||l_retro_ele.source_asg_action_id, 40);
              debug('source_start_date            : '||l_retro_ele.source_start_date, 40);
              debug('source_end_date              : '||l_retro_ele.source_end_date, 40);
              debug('element_type_id              : '||l_retro_ele.element_type_id, 40);
              debug('p_assignment_id              : '||p_assignment_id, 40);

              -- get the balance value for this element and its indirects
              l_retro_balance_ele_value := get_value_from_balance
                                            (p_assignment_id        => p_assignment_id
                                            ,p_element_entry_id => l_retro_ele.element_entry_id
                                            ,p_balance_type_id  => p_balance_type_id
                                            ,p_date_earned      => l_retro_ele.effective_end_date
                                            ,p_asg_act_id       => l_number -- OUT
                                            ,p_retro_asg_act_id => l_number -- OUT
                                            );
              IF l_retro_balance_ele_value IS NOT NULL
              THEN
                -- add all retro values of each element returned as retro elements.
                -- All retro elements pertaining to the main element's run_Result_id need
                -- to be summed up
                l_total_retro_bal_ele_value :=
                    l_total_retro_bal_ele_value + l_retro_balance_ele_value;
              END IF;

              debug('l_total_retro_bal_ele_value : '||l_total_retro_bal_ele_value, 40);
          END LOOP;
          CLOSE csr_retro_ele;
          --
      END LOOP;
      CLOSE csr_run_rslt_indirect_ele;

    -- For bug 9150874 BEGIN. If the original Bonus element entry id didn't process in the payroll run
    -- Check if there was any retro entries and if yes proceed with accumulating the balance values
    ELSE

      debug('Entered in ELSE PART IF l_asg_act_id IS NOT NULL');
	debug('p_element_entry_id : '||p_element_entry_id, 40);

	OPEN csr_retro_ele_check(p_assignment_id         => p_assignment_id
                              ,p_effective_end_date    => ben_ext_person.g_effective_date -- End date
                              ,p_effective_start_date  => p_date_earned                   -- p_date_earned
                              ,p_ele_entry_id          => p_element_entry_id
                               );

      LOOP -- loop thru all the retro elements returned
         FETCH csr_retro_ele_check INTO l_retro_ele_check;
         EXIT WHEN csr_retro_ele_check%NOTFOUND;

	   debug('l_retro_ele_check.element_entry_id : '||l_retro_ele_check.element_entry_id, 40);
   	   debug('l_retro_ele_check.effective_end_date : '||l_retro_ele_check.effective_end_date, 40);
	   debug('source_id                    : '||l_retro_ele.source_id, 40);
         debug('source_asg_action_id         : '||l_retro_ele.source_asg_action_id, 40);

         -- get the balance value for this element and its indirects
         l_retro_balance_ele_value := get_value_from_balance
                                            (p_assignment_id        => p_assignment_id
                                            ,p_element_entry_id => l_retro_ele_check.element_entry_id
                                            ,p_balance_type_id  => p_balance_type_id
                                            ,p_date_earned      => l_retro_ele_check.effective_end_date
                                            ,p_asg_act_id       => l_number -- OUT
                                            ,p_retro_asg_act_id => l_number -- OUT
                                            );
         IF l_retro_balance_ele_value IS NOT NULL
         THEN
             -- add all retro values of each element returned as retro elements.
             -- All retro elements pertaining to the main element's run_Result_id need
             -- to be summed up
             l_total_retro_bal_ele_value :=
                 l_total_retro_bal_ele_value + l_retro_balance_ele_value;
         END IF;

              debug('l_total_retro_bal_ele_value : '||l_total_retro_bal_ele_value, 40);
      END LOOP;
      CLOSE csr_retro_ele_check;
      -- For bug 9150874 END.

    END IF; -- l_asg_act_id IS NOT NULL

    debug('l_balance_ele_value : ' || l_balance_ele_value,50);
    debug('l_total_retro_bal_ele_value : ' || l_total_retro_bal_ele_value,60);

    -- add the element balance value and the retro value
    IF l_balance_ele_value IS NOT NULL
      OR
       l_total_retro_bal_ele_value IS NOT NULL
    THEN
      l_balance_ele_value := nvl(l_balance_ele_value,0) + nvl(l_total_retro_bal_ele_value,0);
    END IF;


    debug('l_balance_ele_value : ' || l_balance_ele_value,70);

  debug_exit(l_proc_name);

  return l_balance_ele_value;

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

END calc_payment_from_balance;



-- ----------------------------------------------------------------------------
-- |------------------------< get_element_payment_balance >--------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_element_payment_balance
      (p_assignment_id      IN NUMBER
  ,p_element_entry_id   IN NUMBER
  ,p_element_type_id    IN NUMBER
  ,p_balance_type_id    IN NUMBER
  ,p_effective_date     IN DATE
  )  RETURN NUMBER
IS


  l_proc_name           VARCHAR2(61):=
     g_proc_name||'get_element_payment_balance';

  l_date_earned   DATE;
  l_payment       NUMBER := NULL;

BEGIN

  debug_enter(l_proc_name);
  debug('p_assignment_id :' || p_assignment_id) ;
  debug('p_effective_date :' ||to_char(p_effective_date,'DD/MM/YYYY')) ;

    OPEN csr_get_next_payroll_date
           ( p_assignment_id    => p_assignment_id
            ,p_effective_date   => p_effective_date
            );
    FETCH csr_get_next_payroll_date INTO l_date_earned;

      IF csr_get_next_payroll_date%FOUND THEN

        debug('l_date_earned :' ||to_char(l_date_earned,'DD/MM/YYYY')) ;
        l_payment := calc_payment_from_balance
                         ( p_assignment_id    => p_assignment_id
                          ,p_element_entry_id => p_element_entry_id
                          ,p_element_type_id  => p_element_type_id
                          ,p_balance_type_id  => p_balance_type_id
                          ,p_date_earned      => l_date_earned
                          );
        debug('l_payment :' || l_payment);

      ELSE
        debug('csr_get_next_payroll_date not found') ;
        --l_payment := 0;
      END IF;

    CLOSE csr_get_next_payroll_date;

  debug_exit(l_proc_name);
  return l_payment;

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

END get_element_payment_balance;










-- ----------------------------------------------------------------------------
-- |--------------------< ele_entry_inp_val_cut_crit >----------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION ele_entry_inp_val_cut_crit
            (
              p_ext_pay_input_value   IN VARCHAR2
             ,p_ext_pay_element_type  IN VARCHAR2
             ,p_ext_pay_element_entry IN VARCHAR2
             ,p_output                OUT NOCOPY VARCHAR2
            )RETURN VARCHAR2
IS

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'ele_entry_inp_val_cut_crit';

    l_include  varchar2(1) :=  'Y';
    l_curr_evt_index        NUMBER;
    l_input_value_id        NUMBER;
    l_element_type_id       NUMBER;
    l_return                NUMBER;
BEGIN
  debug_enter(l_proc_name);

  debug('p_ext_pay_input_value :'|| p_ext_pay_input_value);
  debug('p_ext_pay_element_type :'|| p_ext_pay_element_type);
  debug('p_ext_pay_element_entry :'|| p_ext_pay_element_entry);


  check_if_element_qualifies
      (p_element_entry_id           => p_ext_pay_element_entry -- IN  NUMBER
      ,p_element_type_id            => l_element_type_id  -- OUT NOCOPY NUMBER
      ,p_include                    => p_output -- OUT NOCOPY VARCHAR2 -- Y/N
      ,p_extract_type               => 'CUTOVER' -- IN  VARCHAR2 DEFAULT 'PERIODIC'
      ,p_element_type_id_from_crit  => p_ext_pay_element_type  -- IN  NUMBER DEFAULT NULL
      );

  IF p_output = 'Y' THEN
    IF g_elements_of_info_type(g_curr_element_type_id).eei_information4 <> 'Y' THEN
         debug('ERROR: Not a Pensionable Allowance, will not be processed.');
         l_return :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                      (p_error_number        =>    94528
                      ,p_error_text          =>    'BEN_94528_NOT_PEN_ALLOWANCE'
                      ,p_token1              =>
                           g_elements_of_info_type(g_curr_element_type_id).element_name
                      );
         debug('Returning N ..');
         p_output := 'N';

    --ELSE
    --    debug('Is a Pensionable Allowance');
        -- check for dupliate bonus types
    --    chk_dup_bon_types();
    END IF;
  END IF;

  debug_exit(l_proc_name);
  RETURN p_output;

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

END ele_entry_inp_val_cut_crit;



-- ----------------------------------------------------------------------------
-- |--------------------< ele_entry_inp_val_per_crit >----------------------|
-- Description:
-- ----------------------------------------------------------------------------
FUNCTION ele_entry_inp_val_per_crit
            (
              p_ext_pay_input_value   IN VARCHAR2
             ,p_ext_pay_element_type  IN VARCHAR2
             ,p_ext_pay_element_entry IN VARCHAR2
             ,p_output                OUT NOCOPY VARCHAR2
            )RETURN VARCHAR2
IS

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'ele_entry_inp_val_per_crit';


    CURSOR csr_get_element_entry_id
            (p_element_entry_value_id    IN NUMBER
            )
     IS
            SELECT element_entry_id
            FROM PAY_ELEMENT_ENTRY_VALUES_F
            WHERE element_entry_value_id =p_element_entry_value_id
            AND ROWNUM=1;


    l_include             varchar2(1) :=  'Y';
    l_curr_evt_index      NUMBER;
    l_input_value_id      NUMBER;
    l_element_type_id     NUMBER;
    l_element_entry_id    NUMBER;
    l_index               NUMBER;
    l_return              NUMBER;

    l_chg_table_id        NUMBER;
    l_chg_column_name     VARCHAR2(30);
    l_chg_table           VARCHAR2(30);
    l_chg_type            VARCHAR2(10);
    l_chg_date            DATE;
    l_chg_surrogate_key   NUMBER;
    l_update_type         VARCHAR2(5);

    l_chg_of_element_yn   VARCHAR2(1);
    l_report_all          VARCHAR2(1);
    l_is_terminated       VARCHAR2(1) := 'N';
    l_is_spread_bonus_yn  VARCHAR2(1) := NULL;
    l_claim_date          VARCHAR2(60);

BEGIN
  debug_enter(l_proc_name);

  debug('p_ext_pay_input_value :'|| p_ext_pay_input_value);
  debug('p_ext_pay_element_type :'|| p_ext_pay_element_type);
  debug('p_ext_pay_element_entry :'|| p_ext_pay_element_entry);

/*
PQP_GB_PSI_ASSIGNMENT_STATUS - yes
PQP_GB_PSI_FTE_VALUE - no
PQP_GB_PSI_NEW_HIRE - will go into today_sal_start
PQP_GB_PSI_SAL_CONTRACT - no
PQP_GB_PSI_ALL_ELEMENT_ENTRIES
-- PQP_GB_PSI_SAL_GRADE
PQP_GB_PSI_EMP_TERMINATIONS - yes
*/
  l_index := ben_ext_person.g_chg_pay_evt_index;

  debug('l_index :'|| l_index,20);

  l_chg_type            :=  g_pay_proc_evt_tab(l_index).update_type;
    debug('l_chg_type : ' || l_chg_type);
  l_chg_table_id        :=  g_pay_proc_evt_tab(l_index).dated_table_id;
    debug('l_chg_table_id :' || l_chg_table_id);
  l_chg_table           :=  get_dated_table_name(l_chg_table_id);
    debug('l_chg_table : ' || l_chg_table);
  l_chg_date            :=  g_pay_proc_evt_tab(l_index).effective_date;
    debug('l_chg_date : ' || l_chg_date);
  l_chg_column_name     :=  g_pay_proc_evt_tab(l_index).column_name;
    debug('l_chg_column_name : ' || l_chg_column_name);
  l_chg_surrogate_key :=  ben_ext_person.g_chg_surrogate_key;
    debug('l_chg_surrogate_key : ' || l_chg_surrogate_key);




  IF   l_chg_table <> 'PAY_ELEMENT_ENTRIES_F'
    AND l_chg_table <> 'PAY_ELEMENT_ENTRY_VALUES_F'
    -- OR (l_chg_table = 'PAY_ELEMENT_ENTRIES_F' AND l_chg_type = 'E')
  THEN
    l_chg_of_element_yn := 'N'; -- event not of element type
  ELSE
    l_chg_of_element_yn := 'Y';
  END IF;



    IF is_today_sal_start() = 'Y' THEN -- salary start => report all elements
      --g_is_terminated := 'N'; -- change termination status to N
      l_is_terminated := 'N'; -- change termination status to N
      l_report_all    := 'Y';
    ELSIF is_today_sal_end() = 'Y' THEN -- salary end => report all
      -- g_is_terminated := 'Y'; -- change termination status to 'Y'
      l_is_terminated := 'Y'; -- change termination status to 'Y'
      l_report_all    := 'Y';
    ELSIF ( l_chg_table = 'PER_ALL_ASSIGNMENTS_F'
      AND l_chg_column_name = 'ASSIGNMENT_STATUS_TYPE_ID') THEN

        -- if the event is on assignment_status_type_id
        -- reject the event
        debug('Salary not Started or Ended Today');
        debug('l_chg_table: '||l_chg_table, 15);
        debug('l_chg_column_name: '||l_chg_column_name, 20);
        debug('Not a valid event, will not be processed',25);
        p_output := 'N';
        debug_exit(l_proc_name);
        RETURN p_output;

    ELSIF l_chg_of_element_yn = 'N' THEN -- event not of element_entries/value type => report all
      l_is_terminated := NULL;
      l_report_all := 'Y';
    ELSE -- event of element type, report for that element
      l_is_terminated := NULL;
      l_report_all := 'N';
    END IF;
    --
    debug('l_is_terminated : ' || l_is_terminated,20);
    debug('l_report_all :' || l_report_all, 30);


  IF   g_is_terminated = 'N'
    OR l_is_terminated = 'Y'
    OR (l_is_terminated = 'N' AND l_report_all = 'Y') -- Added as part of 115.58 (3)

  THEN
      --
/*    IF   is_today_sal_start() = 'Y' -- salary start => report all elements
      OR is_today_sal_end () = 'Y'  -- salary end => report all
      OR l_chg_of_element_yn = 'N' -- event not of element_entries/value type => report all
*/

    -- check for element end
    IF l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'
        AND l_chg_type = 'E' THEN
        debug(' element end event ',25);
        g_allowance_has_end_dated := 'Y';
    ELSE
        g_allowance_has_end_dated := 'N';
    END IF;


    IF l_report_all = 'Y'
    THEN
      check_if_element_qualifies
          (p_element_entry_id           => p_ext_pay_element_entry -- IN  NUMBER
          ,p_element_type_id            => l_element_type_id  -- OUT NOCOPY NUMBER
          ,p_include                    => p_output -- OUT NOCOPY VARCHAR2 -- Y/N
          ,p_extract_type               => 'CUTOVER' -- IN  VARCHAR2 DEFAULT 'PERIODIC'
          ,p_element_type_id_from_crit  => p_ext_pay_element_type  -- IN  NUMBER DEFAULT NULL
          );
    ELSE

          IF    l_chg_table  <> 'PAY_ELEMENT_ENTRIES_F'
            AND l_chg_type = 'I' THEN

                debug('Not a valid event, will not be processed',30);
                p_output := 'N';
                debug_exit(l_proc_name);
                RETURN p_output;
          END IF;


        -- if correction, implies that it is on screen entry value
        -- on pay_element_entry_values_f and the surrogate key is
        -- not element_entry_id, but rather element_entry_value_id
        IF l_chg_type = 'C'
        THEN
          debug('correction event');
          OPEN csr_get_element_entry_id
                (p_element_entry_value_id => l_chg_surrogate_key
                );
          FETCH csr_get_element_entry_id into l_element_entry_id;
             IF csr_get_element_entry_id%NOTFOUND
             THEN
               debug('element entry id not found for this correction event',40);
               p_output := 'N';
               l_element_entry_id := NULL;
             END IF;
          CLOSE csr_get_element_entry_id;
        ELSE
          debug('not a correction event',50);
          l_element_entry_id := l_chg_surrogate_key;
        END IF;

        IF    l_element_entry_id IS NOT NULL
          AND p_ext_pay_element_entry = l_element_entry_id
        THEN
          check_if_element_qualifies
              (p_element_entry_id           => p_ext_pay_element_entry -- IN  NUMBER
              ,p_element_type_id            => l_element_type_id  -- OUT NOCOPY NUMBER
              ,p_include                    => p_output -- OUT NOCOPY VARCHAR2 -- Y/N
              ,p_extract_type               => 'PERIODIC' -- IN  VARCHAR2 DEFAULT 'PERIODIC'
              ,p_element_type_id_from_crit  => p_ext_pay_element_type  -- IN  NUMBER DEFAULT NULL
              );
        END IF;

    END IF;


  ELSIF g_elements_of_info_type.EXISTS(p_ext_pay_element_type) THEN -- this is in the terminated state
                                                                    -- but it exists in collection
    debug('this is in the terminated state, but it exists in collection',70);
    l_is_spread_bonus_yn  -- get spread bonus flag
        :=  g_elements_of_info_type(p_ext_pay_element_type).eei_information6;

    IF l_is_spread_bonus_yn IS NULL
    THEN
      l_is_spread_bonus_yn := 'N';
    END IF;
    debug('l_is_spread_bonus_yn :'|| l_is_spread_bonus_yn,80);

    debug('now fetch the claim date for this element',75);

    IF l_is_spread_bonus_yn = 'Y' THEN
        OPEN PQP_GB_PSI_ALLOWANCE_HISTORY.csr_get_entry_value
           (c_effective_date    => g_effective_date
           ,c_element_entry_id  => p_ext_pay_element_entry
           ,c_input_value       => 'CLAIM DATE' -- DEFAULT 'PAY VALUE'
           );
        FETCH PQP_GB_PSI_ALLOWANCE_HISTORY.csr_get_entry_value INTO l_claim_date;
          IF PQP_GB_PSI_ALLOWANCE_HISTORY.csr_get_entry_value%NOTFOUND
            OR l_claim_date IS NULL
          THEN
            l_return :=  raise_extract_error
                   (p_error_number        =>    94532
                   ,p_error_text          =>    'BEN_94532_NO_ENTRY_VALUE'
                   ,p_token1              =>
                        g_elements_of_info_type(p_ext_pay_element_type).element_name
                        || '(Spread Bonus)'
                   ,p_token2              => 'CLAIM DATE'
                   ,p_token3              => to_char(g_effective_date,'DD/MM/YYYY')
                   );

            p_output := 'N';
          ELSE
            IF is_proper_claim_date -- function to check valid claim date
                        (p_claim_date       => fnd_date.canonical_to_date(l_claim_date)
                        ,p_element_name     => g_elements_of_info_type(p_ext_pay_element_type).element_name
                        ,p_element_entry_id => p_ext_pay_element_entry
                        ,p_assg_start_date  => PQP_GB_PSI_ALLOWANCE_HISTORY.g_assg_start_date
                        )
            THEN
              g_curr_element_type_id := p_ext_pay_element_type;
              g_curr_element_entry_id := p_ext_pay_element_entry;

              p_output := 'Y'; -- this element is spread_bonus and valid claim date
              debug('this element is spread_bonus and valid claim date',90);
            ELSE
              p_output := 'N'; -- either not a spread bonus, or claim date didnt qualify
              debug('either not a spread bonus, or claim date didnt qualify',110);
            END IF;
          END IF;
        CLOSE PQP_GB_PSI_ALLOWANCE_HISTORY.csr_get_entry_value;

    END IF;

  ELSE -- IF g_is_terminated = 'N' and not a spread bonus
    p_output := 'N'; -- reject as assignment is in ternminated state
    debug('p_output : '|| p_output, 120);
  END IF; -- IF g_is_terminated = 'N'


    -- check for pensionable flag
    debug('now checking for pensionable flag status ',130);
    IF p_output = 'Y' THEN
      IF g_elements_of_info_type(g_curr_element_type_id).eei_information4 <> 'Y' THEN
         debug('ERROR: Not a Pensionable Allowance, will not be processed.',60);
         l_return := raise_extract_error
                      (p_error_number        =>    94528
                      ,p_error_text          =>    'BEN_94528_NOT_PEN_ALLOWANCE'
                      ,p_token1              =>
                           g_elements_of_info_type(g_curr_element_type_id).element_name
                      );
         debug('Returning N ..');
         p_output := 'N';

      END IF;
    END IF;



  IF l_is_terminated IS NOT NULL
  THEN
    g_is_terminated := l_is_terminated;
  END IF;


  debug_exit(l_proc_name);
  RETURN p_output;

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

END ele_entry_inp_val_per_crit;


    -- ----------------------------------------------------------------------------
    -- |--------------------------< is_today_sal_end >-----------------------------|
    --  Description: This Procedure is to check if salary is ending on the current
    --                processing date.
    --                Salary is considered to be terminatied if assignment status
    --                  is changed to one with 'No Payroll process'
    -- ----------------------------------------------------------------------------
    FUNCTION is_today_sal_end RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_proc_name||'.is_today_sal_end';
        l_chg_column_name           VARCHAR2(30);
        l_chg_table                 VARCHAR2(30);
        l_chg_table_id              NUMBER;
        l_assignment_status_type_id NUMBER;
        l_chg_date                  DATE;
        l_update_type               VARCHAR2(10);
        l_salary_ended              VARCHAR2(1);
        l_index                     NUMBER;
        l_elements_exist            VARCHAR2(1);
        l_assignment_status         VARCHAR2(20);
        l_per_assg_status           VARCHAR2(80);
        l_leaver_date               DATE;
    BEGIN
        debug_enter(l_proc);
        debug('g_effective_date: '||g_effective_date);
        debug('g_salary_end_date: '||g_salary_end_date);

        IF g_salary_end_date = (g_effective_date - 1) THEN
            -- current date has been process by another event
            --  and today is set as end date previously.
            g_salary_ended_today := 'Y';

            debug('Returning Y'||10);
            debug_exit(l_proc);
            RETURN 'Y';
        END IF;

        l_index := ben_ext_person.g_chg_pay_evt_index;
        LOOP
            l_chg_column_name     :=  g_pay_proc_evt_tab(l_index).column_name;
            l_chg_table_id        :=  g_pay_proc_evt_tab(l_index).dated_table_id;
            l_chg_date            :=  g_pay_proc_evt_tab(l_index).effective_date;
            l_update_type         :=  g_pay_proc_evt_tab(l_index).update_type;

            l_chg_table           :=  get_dated_table_name(l_chg_table_id);

            IF g_effective_date < l_chg_date THEN
              debug('finished processing all the events on g_effective_date');
              EXIT;
            END IF;

            -- check for changes on assignment status
            IF l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
                AND  (l_chg_column_name  = 'ASSIGNMENT_STATUS_TYPE_ID'
                      OR l_update_type  =  'E')  THEN

                  IF PQP_GB_PSI_FUNCTIONS.chk_is_employee_a_leaver
                        (
                        p_assignment_id     =>  g_assignment_id
                        ,p_effective_date   =>  l_chg_date
                        ,p_leaver_date      =>  l_leaver_date
                        ) = 'Y' THEN

                         -- set today as salary end date.
                         debug('l_leaver_date: '||l_leaver_date,20);
                        g_salary_end_date := l_leaver_date;
                        g_salary_ended_today := 'Y';

                        debug('Returning Y');
                        debug_exit(l_proc);
                        RETURN 'Y';

                  END IF;

                  l_assignment_status_type_id :=  g_pay_proc_evt_tab(l_index).new_value;
                  OPEN csr_assignment_status(l_assignment_status_type_id);
                  FETCH csr_assignment_status INTO l_assignment_status,l_per_assg_status;
                  CLOSE csr_assignment_status;
                  IF l_assignment_status <> 'PROCESS' THEN

                        debug('Returning Y as assignemnt status is changed to: '||l_assignment_status);
                        -- set today as salary end date.
                        g_salary_end_date := g_effective_date-1;
                        g_salary_ended_today := 'Y';

                        debug('Returning Y');
                        debug_exit(l_proc);
                        RETURN 'Y';

                  END IF; --IF l_assignment_status <> 'PROCESS'

            END IF;--IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'

            -- looping condition
            IF l_index = g_pay_proc_evt_tab.LAST THEN
                EXIT;
            ELSE
                l_index := g_pay_proc_evt_tab.NEXT(l_index);
            END IF; --IF l_index = g_pay_proc_evt_tab.LAST

        END LOOP; -- LOOP

        g_salary_ended_today := 'N';
        debug('Returning N');
        debug_exit(l_proc);
        return 'N';
    END is_today_sal_end;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------------< is_curr_sal_end >-----------------------------|
    --  Description: This Procedure is to check if salary is ending on the current
    --                processing event.
    -- ----------------------------------------------------------------------------
    FUNCTION is_curr_sal_end RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_proc_name||'.is_curr_sal_end';
        l_chg_column_name VARCHAR2(30);
        l_chg_table   VARCHAR2(30);
        l_assignment_status_type_id NUMBER;
    BEGIN
        debug_enter(l_proc);
        l_chg_column_name := ben_ext_person.g_chg_pay_column;
        l_chg_table       := ben_ext_person.g_chg_pay_table;

        -- check for changes on assignment status
        IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
            AND  l_chg_column_name  = 'ASSIGNMENT_STATUS_TYPE_ID')  THEN

              debug('Returning Y for the event on assignment_status_type_id');
              debug_exit(l_proc);
              RETURN 'Y';

        END IF; --IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'

        debug('Returning N');
        debug_exit(l_proc);
        return 'N';
    END is_curr_sal_end;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------------< is_today_sal_start >--------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION is_today_sal_start RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_proc_name||'.is_today_sal_start';
        l_chg_column_name   VARCHAR2(30);
        l_chg_table         VARCHAR2(30);
        l_chg_table_id      NUMBER;
        l_assignment_status_type_id NUMBER;
        l_salary_ended      VARCHAR2(1);
        l_elements_exist    VARCHAR2(1);
        l_index             NUMBER;
        l_assignment_status VARCHAR2(20);
        l_per_assg_status   VARCHAR2(80);
        l_update_type     VARCHAR2(10);

    BEGIN
        debug_enter(l_proc);

        l_index := ben_ext_person.g_chg_pay_evt_index;
        LOOP
            l_chg_column_name     :=  g_pay_proc_evt_tab(l_index).column_name;
            l_chg_table_id        :=  g_pay_proc_evt_tab(l_index).dated_table_id;
            l_chg_table           :=  get_dated_table_name(l_chg_table_id);
            l_update_type         :=  g_pay_proc_evt_tab(l_index).update_type;

            debug('g_effective_date :' || g_effective_date, 009);

            IF g_effective_date < g_pay_proc_evt_tab(l_index).effective_date THEN
              debug('finished processing all the events on g_effective_date',30);
              EXIT;
            END IF; --IF g_effective_date

            -- check for changes on assignment status
            IF l_chg_table  = 'PER_ALL_ASSIGNMENTS_F' THEN

                IF l_chg_column_name  = 'ASSIGNMENT_STATUS_TYPE_ID'  THEN

                  l_assignment_status_type_id :=  g_pay_proc_evt_tab(l_index).new_value;
                  debug('l_assignment_status_type_id: '||l_assignment_status_type_id,40);
                  OPEN csr_assignment_status(l_assignment_status_type_id);
                  FETCH csr_assignment_status INTO l_assignment_status,l_per_assg_status;
                  CLOSE csr_assignment_status;
                  debug('l_assignment_status: '||l_assignment_status);
                  debug('l_per_assg_status: '||l_per_assg_status);
                  IF l_assignment_status = 'PROCESS'
                  AND l_per_assg_status NOT IN ('TERM_ASSIGN','SUSP_ASSIGN','END') THEN

                          debug('Returning Y as assignemnt status is : '||l_assignment_status,50);
                          g_salary_ended_today := 'N';
                          debug_exit(l_proc);
                          RETURN 'Y';

                  ELSE
                          debug('Returning N as assignemnt status is : '||l_assignment_status,50);
                          debug_exit(l_proc);
                          RETURN 'N';

                  END IF; -- IF l_assignment_status <> 'PROCESS'
               ELSIF  l_update_type = 'I' THEN
                    debug('Returning Y , Insert event on assignments ',40);
                    g_salary_ended_today := 'N';
                    debug_exit(l_proc);
                    RETURN 'Y';
               END IF;

            END IF; --IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'


            -- looping condition
            IF l_index = g_pay_proc_evt_tab.LAST THEN
                EXIT;
            ELSE
                l_index := g_pay_proc_evt_tab.NEXT(l_index);
            END IF;--IF l_index = g_pay_proc_evt_tab.LAST

        END LOOP; -- LOOP

        debug('Returning N');
        debug_exit(l_proc);
        return 'N';
    END is_today_sal_start;
    ---
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------------< is_today_sal_ele_end >-----------------------------|
    --  Description: This Procedure is to check if salary element ending on the current
    --                processing date.
    -- ----------------------------------------------------------------------------
    FUNCTION is_today_sal_ele_end  RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_proc_name||'.is_today_sal_ele_end';
        l_sal_ele_end VARCHAR2(1) := 'N';
        l_index           NUMBER;
        l_chg_table_id        NUMBER;
        l_chg_column_name VARCHAR2(30);
        l_chg_table       VARCHAR2(30);
        l_chg_type        VARCHAR2(10);
        l_chg_date        DATE;
        l_chg_surrogate_key NUMBER;
        l_is_fte_abv      VARCHAR2(1);

      --Bug 7611963: Added new variable
        l_ele_end_date    DATE;

    BEGIN
        debug_enter(l_proc);
        debug('g_effective_date: '||g_effective_date);
        debug('g_salary_ele_end_date: '||g_salary_ele_end_date);
        debug('g_non_salary_ele_end_date: '||g_non_salary_ele_end_date);

        IF g_salary_ele_end_date = g_effective_date THEN
            -- if current event date is already processed
            debug('g_sal_chg_event_exists: '||g_sal_chg_event_exists);
            debug('Returning: Y');
            debug_exit(l_proc);
            return 'Y';
        END IF;

        IF g_non_salary_ele_end_date = g_effective_date THEN
            -- if current event date is already processed
            debug('g_sal_chg_event_exists: '||g_sal_chg_event_exists);
            debug('Returning: N');
            debug_exit(l_proc);
            return 'N';
        END IF;

        -- reset g_sal_chg_event_exists
        g_sal_chg_event_exists  :=  'N';

        l_index := ben_ext_person.g_chg_pay_evt_index;
        LOOP
            l_chg_type            :=  g_pay_proc_evt_tab(l_index).update_type;
            l_chg_table_id        :=  g_pay_proc_evt_tab(l_index).dated_table_id;
            l_chg_table           :=  get_dated_table_name(l_chg_table_id);
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
            IF l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'
                AND l_chg_type = 'E'
            THEN
              --Bug 7611963: Check if ele end date is still valid
                OPEN csr_get_ele_end_date(g_pay_proc_evt_tab(l_index).surrogate_key);
                FETCH csr_get_ele_end_date INTO l_ele_end_date;
                CLOSE csr_get_ele_end_date;

                debug('l_ele_end_date:'||l_ele_end_date);
                debug('g_effective_date:'||g_effective_date);

                IF g_effective_date = l_ele_end_date
                THEN
                    debug('Salary element end event ');
                    g_salary_ele_end_date := g_effective_date;
                    l_sal_ele_end := 'Y';
                END IF;
              --Bug 7611963: End
            END IF;

            IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
                AND  (l_chg_column_name  IN ('GRADE_ID','NORMAL_HOURS') OR l_chg_type = 'I'))
               OR (l_chg_table  = 'PQP_ASSIGNMENT_ATTRIBUTES_F'
                AND  (l_chg_column_name  = 'CONTRACT_TYPE' OR l_chg_type = 'I'))
               OR (l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'
                AND  l_chg_type  <> 'E')
               OR (l_chg_table  = 'PAY_ELEMENT_ENTRY_VALUES_F') THEN

                    g_sal_chg_event_exists  := 'Y';

            END IF; --IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'

            IF (l_chg_table  = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
                AND  (l_chg_column_name  = 'VALUE' OR l_chg_type = 'I' )) THEN

                    l_chg_surrogate_key   :=  g_pay_proc_evt_tab(l_index).surrogate_key;
                    debug('l_chg_surrogate_key: '||l_chg_surrogate_key);
                    OPEN csr_is_fte_abv
                              (
                              p_assignment_budget_value_id  =>  l_chg_surrogate_key
                              );
                    FETCH csr_is_fte_abv INTO l_is_fte_abv;
                    CLOSE csr_is_fte_abv;
                    debug('l_is_fte_abv: '||l_is_fte_abv);
                    IF NVL(l_is_fte_abv,' ') = 'Y' THEN
                          debug('Change on FTE Value');
                          g_sal_chg_event_exists  := 'Y';

                    END IF;

            END IF;
            -- looping condition
            IF l_index = g_pay_proc_evt_tab.LAST THEN
                EXIT;
            ELSE
                l_index := g_pay_proc_evt_tab.NEXT(l_index);
            END IF;
        END LOOP; -- LOOP

        IF l_sal_ele_end = 'N' THEN
          -- current date does not have a sal ele end event
          g_non_salary_ele_end_date := g_effective_date;
        END IF;

        debug('g_sal_chg_event_exists: '||g_sal_chg_event_exists);
        debug('Returning: '||l_sal_ele_end);
        debug_exit(l_proc);
        return l_sal_ele_end;
    END is_today_sal_ele_end;
    ---
    -- ----------------------------------------------------------------------------
    -- |------------------------< is_curr_sal_ele_end >---------------------------|
    --  Description:  This procedure is to check whether the current event is a
    --                  salary element end event.
    -- ----------------------------------------------------------------------------
    FUNCTION is_curr_sal_ele_end RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_proc_name||'.is_curr_sal_ele_end';
        l_chg_table   VARCHAR2(30);
        l_chg_type    VARCHAR2(10);

      --Bug 7611963: Added variable
        l_ele_end_date DATE;

    BEGIN
        debug_enter(l_proc);
        l_chg_type        := ben_ext_person.g_chg_update_type;
        l_chg_table       := ben_ext_person.g_chg_pay_table;
        debug('l_chg_table: '||l_chg_table||'  l_chg_type: '||l_chg_type);

        IF l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'
                AND l_chg_type = 'E'
      THEN
            --Bug 7611963: Chk is ele end date is still valid
             OPEN csr_get_ele_end_date(ben_ext_person.g_chg_surrogate_key);
             FETCH csr_get_ele_end_date INTO l_ele_end_date;
             CLOSE csr_get_ele_end_date;

             debug('l_ele_end_date:'||l_ele_end_date);
             debug('g_effective_date:'||g_effective_date);

             IF g_effective_date = l_ele_end_date
             THEN
                  debug('Returning Y ');
                  debug_exit(l_proc);
                  RETURN 'Y';
             END IF;
           --Bug 7611963: End
        END IF; --IF l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'

        debug('Returning N ');
        debug_exit(l_proc);
        RETURN 'N';
    END is_curr_sal_ele_end;

  --Bug 7611963
    -- ----------------------------------------------------------------------------
    -- |--------------------------< get_next_valid_event_date >--------------------------|
    --This procedure is called from is_next_sal_end and ignores the events recorded
    --due to reverse termination.
    -- ----------------------------------------------------------------------------
    PROCEDURE get_next_valid_event_date
             (p_index    IN OUT NOCOPY NUMBER
             ,p_next_chg_date IN OUT NOCOPY DATE
            )
    IS
      Cursor csr_get_abv_end_date(p_assignment_budget_value_id IN NUMBER)
        Is
          Select max(effective_end_date)
          From per_assignment_budget_values_f
          Where assignment_budget_value_id = p_assignment_budget_value_id;

        l_chg_table_id    NUMBER;
        l_update_type     VARCHAR2(10);
        l_chg_column_name VARCHAR2(30);
        l_chg_table       VARCHAR2(30);

        l_rev_term_index           NUMBER;
        l_chg_date_rev_term        DATE;
        l_old_asg_status_typ_id    NUMBER;
        l_old_assignment_status    VARCHAR2(20);
        l_old_per_assg_status      VARCHAR2(80);
        l_found_rev_term_event     VARCHAR2(5) := 'N';

      l_ele_end_date DATE;
      l_abv_end_date  DATE;
    BEGIN
      debug('Entering: get_next_valid_event_date');
      debug('p_index: '||p_index);
      debug('p_next_chg_date: '||p_next_chg_date);

      l_rev_term_index := p_index;

      LOOP
          l_chg_table_id     :=  g_pay_proc_evt_tab(l_rev_term_index).dated_table_id;
          l_update_type      :=  g_pay_proc_evt_tab(l_rev_term_index).update_type;
          l_chg_column_name  :=  g_pay_proc_evt_tab(l_rev_term_index).column_name;

          l_chg_table        :=  get_dated_table_name(l_chg_table_id);
          l_chg_date_rev_term :=  g_pay_proc_evt_tab(l_rev_term_index).effective_date;

          debug('l_chg_table:'||l_chg_table);
          debug('l_chg_column_name:'||l_chg_column_name);
          debug('l_update_type:'||l_update_type);
          debug('l_chg_date_rev_term:'||l_chg_date_rev_term);

          IF l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
             AND l_chg_column_name  = 'ASSIGNMENT_STATUS_TYPE_ID'
             AND l_update_type  =  'C'
          THEN
              debug('Found Reverse Term event');
              l_found_rev_term_event := 'Y';
          ELSIF l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'
                AND l_chg_column_name  = 'EFFECTIVE_END_DATE'
                AND l_update_type  =  'E'
          THEN
               l_ele_end_date := NULL;

             debug('g_pay_proc_evt_tab(l_rev_term_index).surrogate_key:'||g_pay_proc_evt_tab(l_rev_term_index).surrogate_key);

             OPEN csr_get_ele_end_date(g_pay_proc_evt_tab(l_rev_term_index).surrogate_key);
               FETCH csr_get_ele_end_date INTO l_ele_end_date;
               CLOSE csr_get_ele_end_date;

               debug('l_ele_end_date:'||l_ele_end_date);

               IF l_chg_date_rev_term <> l_ele_end_date
               THEN
                   debug('Found Reverse Term event');
                   l_found_rev_term_event := 'Y';
               END IF;
          ELSIF l_chg_table  = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
                AND l_chg_column_name  = 'EFFECTIVE_END_DATE'
                AND l_update_type  =  'C'
          THEN
               l_abv_end_date := NULL;

             debug('g_pay_proc_evt_tab(l_rev_term_index).surrogate_key:'||g_pay_proc_evt_tab(l_rev_term_index).surrogate_key);

             OPEN csr_get_abv_end_date(g_pay_proc_evt_tab(l_rev_term_index).surrogate_key);
               FETCH csr_get_abv_end_date INTO l_abv_end_date;
               CLOSE csr_get_abv_end_date;

               debug('l_abv_end_date:'||l_abv_end_date);

               IF l_chg_date_rev_term <> l_abv_end_date
               THEN
                   debug('Found Reverse Term event');
                   l_found_rev_term_event := 'Y';
               END IF;
          ELSE
              debug('Event other than Reverse Term found');
              p_index := l_rev_term_index;
            p_next_chg_date := l_chg_date_rev_term;
              EXIT;
          END IF;

          IF l_rev_term_index = g_pay_proc_evt_tab.LAST
          THEN
              p_index := p_index;
            p_next_chg_date := p_next_chg_date;
              EXIT;
          ELSE
              l_rev_term_index := g_pay_proc_evt_tab.NEXT(l_rev_term_index);
          END IF;
      END LOOP;

      debug('p_index: '||p_index);
      debug('p_next_chg_date: '||p_next_chg_date);
      debug('Leaving: get_next_valid_event_date');
    END get_next_valid_event_date;

    ---
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------------< is_next_sal_end >--------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION is_next_sal_end
                  (
                  p_end_date   OUT NOCOPY DATE
                  )RETURN VARCHAR2
    IS
        l_proc varchar2(72) := g_proc_name||'.is_next_sal_end';
        l_next_event_date       DATE;
        l_assignment_status_type_id NUMBER;
        l_index           NUMBER;
        l_chg_column_name VARCHAR2(30);
        l_chg_table       VARCHAR2(30);
        l_chg_table_id    NUMBER;
        l_chg_date        DATE;
        l_leaver_date     DATE;
        l_update_type     VARCHAR2(10);
        l_sal_ele_end_evt_exist VARCHAR2(1) :=  'Y';
        l_other_event_exist     VARCHAR2(1) :=  'N';
        l_is_fte_abv            VARCHAR2(1);
        l_chg_surrogate_key     NUMBER;
        l_assignment_status     VARCHAR2(20);
        l_per_assg_status       VARCHAR2(80);
        l_return                VARCHAR2(1) :=  'N';
      --Bug 7611963: Added variable
        l_ele_end_date DATE;

    BEGIN
        debug_enter(l_proc);
        p_end_date  :=  NULL;
        -- loop till the next event date
        l_index := ben_ext_person.g_chg_pay_evt_index;
        LOOP
            l_update_type         :=  g_pay_proc_evt_tab(l_index).update_type;
            l_chg_table_id        :=  g_pay_proc_evt_tab(l_index).dated_table_id;
            l_chg_table           :=  get_dated_table_name(l_chg_table_id);
            l_chg_date            :=  g_pay_proc_evt_tab(l_index).effective_date;

            IF g_effective_date < l_chg_date THEN
              debug('finished processing all the events on g_effective_date');
              EXIT;
            END IF; --IF g_effective_date
            debug('l_chg_date: '||l_chg_date);

            -- looping condition
            IF l_index = g_pay_proc_evt_tab.LAST THEN
                EXIT;
            ELSE
                l_index := g_pay_proc_evt_tab.NEXT(l_index);
            END IF;
        END LOOP;

        -- loop for next event date
        IF l_chg_date > g_effective_date
      THEN

        --Bug 7611963: Call procedure for ignoring Reverser Term events
            get_next_valid_event_date
                         ( p_index          => l_index
                          ,p_next_chg_date  => l_chg_date
                          );

          l_next_event_date   :=    l_chg_date;
            debug('Looping through the events on next event date');
            LOOP
                l_chg_table_id        :=  g_pay_proc_evt_tab(l_index).dated_table_id;
                l_update_type         :=  g_pay_proc_evt_tab(l_index).update_type;
                l_chg_column_name     :=  g_pay_proc_evt_tab(l_index).column_name;

                l_chg_table           :=  get_dated_table_name(l_chg_table_id);
                l_chg_date            :=  g_pay_proc_evt_tab(l_index).effective_date;

                -- looping condition
                IF l_next_event_date < l_chg_date THEN
                  debug('finished processing all the events on g_effective_date');
                  EXIT;
                END IF; --IF g_effective_date

                debug('l_chg_table: '||l_chg_table||'  l_chg_date: '||l_chg_date||
                      '   l_update_type: '||l_update_type||'  l_chg_column_name: '||l_chg_column_name);

                IF l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
                AND  (l_chg_column_name  = 'ASSIGNMENT_STATUS_TYPE_ID'
                      OR l_update_type  =  'E')  THEN

                      IF PQP_GB_PSI_FUNCTIONS.chk_is_employee_a_leaver
                            (
                            p_assignment_id     =>  g_assignment_id
                            ,p_effective_date   =>  l_chg_date
                            ,p_leaver_date      =>  l_leaver_date
                            ) = 'Y' THEN

                             -- set today as salary end date.
                             debug('l_leaver_date: '||l_leaver_date,20);
                            g_salary_end_date := l_leaver_date;
                            p_end_date        := l_leaver_date;
                            debug('Returning Y');
                            debug_exit(l_proc);
                            RETURN 'Y';

                      END IF;

                      l_assignment_status_type_id :=  g_pay_proc_evt_tab(l_index).new_value;
                      OPEN csr_assignment_status(l_assignment_status_type_id);
                      FETCH csr_assignment_status INTO l_assignment_status,l_per_assg_status;
                      CLOSE csr_assignment_status;
                      IF l_assignment_status <> 'PROCESS' THEN

                            debug('Returning Y as assignemnt status is changed to: '||l_assignment_status);
                            -- set today as salary end date.
                            g_salary_end_date := l_chg_date-1;
                            p_end_date        := l_chg_date-1;
                            debug('Returning Y');
                            debug_exit(l_proc);
                            RETURN 'Y';

                      END IF; --IF l_assignment_status <> 'PROCESS'
                ELSIF l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'
                      AND l_update_type  =  'E'
             THEN
                     --Bug 7611963:Chk if ele end date is valid
                      l_ele_end_date := NULL;

                      OPEN csr_get_ele_end_date(g_pay_proc_evt_tab(l_index).surrogate_key);
                      FETCH csr_get_ele_end_date INTO l_ele_end_date;
                      CLOSE csr_get_ele_end_date;

                      debug('l_ele_end_date:'||l_ele_end_date);
                      debug('l_chg_date:'||l_chg_date);

                      IF l_chg_date = l_ele_end_date
                      THEN
                          -- if there is a element entry end.
                          l_sal_ele_end_evt_exist :=  'Y';
                      ELSE
                          l_sal_ele_end_evt_exist :=  'N';
                      END IF;
                   --Bug 7611963: End

            ELSIF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
                    AND  (l_chg_column_name  IN ('GRADE_ID','NORMAL_HOURS') OR l_update_type = 'I'))
                   OR (l_chg_table  = 'PQP_ASSIGNMENT_ATTRIBUTES_F'
                    AND  (l_chg_column_name  = 'CONTRACT_TYPE' OR l_update_type = 'I'))
                   OR (l_chg_table  = 'PAY_ELEMENT_ENTRY_VALUES_F') THEN

                        l_other_event_exist := 'Y';

                ELSIF (l_chg_table  = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
                    AND  (l_chg_column_name  = 'VALUE' OR l_update_type = 'I' )) THEN

                        l_chg_surrogate_key   :=  ben_ext_person.g_chg_surrogate_key;
                        debug('l_chg_surrogate_key: '||l_chg_surrogate_key);
                        OPEN csr_is_fte_abv
                                  (
                                  p_assignment_budget_value_id  =>  l_chg_surrogate_key
                                  );
                        FETCH csr_is_fte_abv INTO l_is_fte_abv;
                        CLOSE csr_is_fte_abv;

                        IF l_is_fte_abv IS NOT NULL
                            AND l_is_fte_abv = 'Y' THEN

                              l_other_event_exist := 'Y';

                        END IF;--IF l_is_fte_abv IS NOT NULL

                END IF;--IF l_chg_table  =

                -- looping condition
                IF l_index = g_pay_proc_evt_tab.LAST THEN
                    EXIT;
                ELSE
                    l_index := g_pay_proc_evt_tab.NEXT(l_index);
                END IF;--IF l_index = g_pay_proc_evt_tab.LAST

            END LOOP;

        END IF;--IF l_chg_date > g_effective_date

        IF l_sal_ele_end_evt_exist  =   'Y'
            AND   l_other_event_exist = 'N' THEN
        -- if on the next event date, there is a salary element end
        --    and there are no other salary change events, we have to check on the next event date + 1.
        --    if this next event date + 1 is a salary end event, this date should be reported as end date
        --    on the current event date.
              IF l_chg_date = (l_next_event_date + 1)  THEN
                  -- if the next event is on the very next day
                  -- then check employee is a leaver on that date
                  l_chg_table_id        :=  g_pay_proc_evt_tab(l_index).dated_table_id;
                  l_update_type         :=  g_pay_proc_evt_tab(l_index).update_type;
                  l_chg_column_name     :=  g_pay_proc_evt_tab(l_index).column_name;

                  IF l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
                    AND  (l_chg_column_name  = 'ASSIGNMENT_STATUS_TYPE_ID'
                          OR l_update_type  =  'E')  THEN

                          IF PQP_GB_PSI_FUNCTIONS.chk_is_employee_a_leaver
                                (
                                p_assignment_id     =>  g_assignment_id
                                ,p_effective_date   =>  l_chg_date
                                ,p_leaver_date      =>  l_leaver_date
                                ) = 'Y' THEN

                                 -- set today as salary end date.
                                 debug('l_leaver_date: '||l_leaver_date,20);
                                g_salary_end_date := l_leaver_date;
                                p_end_date        := l_leaver_date;
                                debug('Returning Y');
                                debug_exit(l_proc);
                                RETURN 'Y';

                          END IF;

                          l_assignment_status_type_id :=  g_pay_proc_evt_tab(l_index).new_value;
                          OPEN csr_assignment_status(l_assignment_status_type_id);
                          FETCH csr_assignment_status INTO l_assignment_status,l_per_assg_status;
                          CLOSE csr_assignment_status;
                          IF l_assignment_status <> 'PROCESS' THEN

                                debug('Returning Y as assignemnt status is changed to: '||l_assignment_status);
                                -- set today as salary end date.
                                g_salary_end_date := l_chg_date-1;
                                p_end_date        := l_chg_date-1;
                                debug('Returning Y');
                                debug_exit(l_proc);
                                RETURN 'Y';

                          END IF; --IF l_assignment_status <> 'PROCESS'

                    END IF; -- IF l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'

              END IF; -- IF l_chg_date = (l_next_event_date + 1)

        END IF; --IF l_sal_ele_end_evt_exist  =   'Y'


        debug('p_end_date: '||p_end_date);
        debug_exit(l_proc);
        RETURN l_return;
    END is_next_sal_end;
    ---
    -- ----------------------------------------------------------------------------
    -- |--------------------------< is_curr_sal_change_event >--------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION is_curr_sal_change_event RETURN VARCHAR2
    IS

     --For Bug 7013325: Added cursor to fetch mapped DFF segment
       CURSOR csr_get_configured_dff_segment(c_business_group_id NUMBER)
       IS
         SELECT trim(nvl(pcv_information3,'NULLCOLUMN'))
         FROM pqp_configuration_values
         WHERE pcv_information_category='PQP_GB_PENSERVER_ELIGBLTY_CONF'
         AND business_group_id = c_business_group_id;

    --For Bug 9110093: Added cursor to fetch Uniform Grade Mapping
      CURSOR csr_get_uni_grade_config(c_business_group_id NUMBER)
      IS
       SELECT PCV_INFORMATION1, PCV_INFORMATION2, PCV_INFORMATION3, PCV_INFORMATION4
       FROM pqp_configuration_values
       WHERE pcv_information_category like 'PQP_GB_PENSERVER_UNIGRD_MAP'
       AND business_group_id = c_business_group_id;

      TYPE get_uni_grd_oldval_ref_csr_typ IS REF CURSOR;
      c_get_uni_grd_old_val      get_uni_grd_oldval_ref_csr_typ;

      TYPE get_uni_grd_newval_ref_csr_typ IS REF CURSOR;
      c_get_uni_grd_new_val      get_uni_grd_newval_ref_csr_typ;


      l_proc varchar2(72) := g_proc_name||'.is_curr_sal_change_event';
      l_next_event_date       DATE;
      l_next_pay_event_rec  ben_ext_person.t_detailed_output_tab_rec;
      l_chg_column_name VARCHAR2(30);
      l_chg_table       VARCHAR2(30);
      l_chg_type        VARCHAR2(10);
      l_chg_date        DATE;
      l_chg_surrogate_key NUMBER;
      l_is_fte_abv      VARCHAR2(1);
     --For Bug 7013325: Added Variable
      l_configured_dff_segment  VARCHAR2(30);

     --For Bug 9110093:Added Variables
      l_unigrade_source      VARCHAR2(30);
      l_assignment_context   VARCHAR2(30);
      l_assignment_column    VARCHAR2(30);
      l_people_group_column  VARCHAR2(30);

      l_uni_grade_old_val_query    VARCHAR2(1000);
      l_uni_grd_old_value          VARCHAR2(50);
      l_uni_grade_new_val_query    VARCHAR2(1000);
      l_uni_grd_new_value          VARCHAR2(50);

      l_change_value    varchar2(80);
      l_old_value       VARCHAR2(20);
      l_new_value       VARCHAR2(20);
      l_arrow_pos       NUMBER;

    BEGIN
        debug_enter(l_proc);

        l_chg_type            :=  ben_ext_person.g_chg_update_type;
        l_chg_table           :=  ben_ext_person.g_chg_pay_table;
        l_chg_date            :=  ben_ext_person.g_chg_eff_dt;
        l_chg_column_name     :=  ben_ext_person.g_chg_pay_column;

        debug('l_chg_table: '||l_chg_table);
        debug('l_chg_date: '||l_chg_date);
        debug('l_chg_type: '||l_chg_type);
        debug('l_chg_column_name: '||l_chg_column_name);

      --For Bug 7013325
      OPEN csr_get_configured_dff_segment(g_business_group_id);
        FETCH csr_get_configured_dff_segment INTO l_configured_dff_segment;
        CLOSE csr_get_configured_dff_segment;

        IF(l_configured_dff_segment='NULLCOLUMN')
        THEN
            debug('Customer specific DFF Segment not mapped on configuration page');
            debug('Refer to bug 7013325 for setup details');
        ELSE
            debug('l_configured_dff_segment: '||l_configured_dff_segment);
            debug('g_business_group_id: '||g_business_group_id);
        END IF;
      --For Bug 7013325


    --For Bug 5998108: Added new column EMPLOYMENT_CATEGORY
    --For bug 7013325: Added new column l_configured_dff_segment
        IF (l_chg_table  = 'PAY_ELEMENT_ENTRIES_F'
            AND  l_chg_type  <> 'E')
           OR (l_chg_table  = 'PAY_ELEMENT_ENTRY_VALUES_F')
           OR (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'
            AND  (l_chg_column_name  IN ('GRADE_ID','NORMAL_HOURS','EMPLOYMENT_CATEGORY',l_configured_dff_segment) OR l_chg_type = 'I'))
           OR (l_chg_table  = 'PQP_ASSIGNMENT_ATTRIBUTES_F'
            AND  (l_chg_column_name  = 'CONTRACT_TYPE' OR l_chg_type = 'I'))THEN

                debug('Returning Y');
                debug_exit(l_proc);
                RETURN 'Y';

        END IF; --IF (l_chg_table  = 'PER_ALL_ASSIGNMENTS_F'

        IF (l_chg_table  = 'PER_ASSIGNMENT_BUDGET_VALUES_F'
            AND  (l_chg_column_name  = 'VALUE' OR l_chg_type = 'I' )) THEN

                l_chg_surrogate_key   :=  ben_ext_person.g_chg_surrogate_key;
                debug('l_chg_surrogate_key: '||l_chg_surrogate_key);
                OPEN csr_is_fte_abv
                          (
                          p_assignment_budget_value_id  =>  l_chg_surrogate_key
                          );
                FETCH csr_is_fte_abv INTO l_is_fte_abv;
                CLOSE csr_is_fte_abv;

                IF l_is_fte_abv IS NOT NULL
                    AND l_is_fte_abv = 'Y' THEN

                      debug('Returning Y');
                      debug_exit(l_proc);
                      RETURN 'Y';

                END IF;

        END IF;

      --For Bug 9110093:Logic for tracking Uniform grade change events
        OPEN csr_get_uni_grade_config(g_business_group_id);
        FETCH csr_get_uni_grade_config INTO l_unigrade_source, l_assignment_context,
                                            l_assignment_column, l_people_group_column ;
        CLOSE csr_get_uni_grade_config;

        debug('l_unigrade_source: '||l_unigrade_source);
        debug('l_assignment_context: '||l_assignment_context);
        debug('l_assignment_column: '||l_assignment_column);
        debug('l_people_group_column: '||l_people_group_column);

        IF l_unigrade_source = 'PEOPLE_GROUP' AND l_people_group_column IS NOT NULL
        THEN
             IF(l_chg_table= 'PER_ALL_ASSIGNMENTS_F'
                AND l_chg_column_name= 'PEOPLE_GROUP_ID')
             THEN
                --Compare the new and old value of uni grade segment
                  l_change_value := ben_ext_person.g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index).change_values;
                  l_old_value := ben_ext_person.g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index).old_value;
                  l_new_value := ben_ext_person.g_pay_proc_evt_tab(ben_ext_person.g_chg_pay_evt_index).new_value;

                  debug('l_chg_type: '||l_chg_type);
                  debug('l_change_value: '||l_change_value);
                  debug('l_old_value: '||l_old_value);
                  debug('l_new_value: '||l_new_value);

                  IF l_chg_type = 'C'
                  THEN
                      debug('For correction type pick the value by parsing change_values');
                      l_arrow_pos :=  instr(l_change_value,'->');
                      l_old_value :=  ltrim(rtrim(SUBSTR(l_change_value,1,l_arrow_pos-1)));
                      l_new_value :=  ltrim(rtrim(SUBSTR(l_change_value,l_arrow_pos+2)));

                      debug('l_old_value: '||l_old_value);
                      debug('l_new_value: '||l_new_value);
                  END IF;

                  IF ((l_old_value IS NULL) OR l_old_value = '<null>' OR l_old_value = '<NULL>')
                  THEN
                       l_uni_grd_old_value := 'NULLValue';
                  ELSE
                       l_uni_grade_old_val_query := 'select '||l_people_group_column||' '||
                                                    'from pay_people_groups'||' '||
                                                    'where PEOPLE_GROUP_ID = '||l_old_value;
                       debug('l_uni_grade_old_val_query: '||l_uni_grade_old_val_query);

                       OPEN c_get_uni_grd_old_val FOR l_uni_grade_old_val_query;
                       FETCH c_get_uni_grd_old_val INTO l_uni_grd_old_value;
                       CLOSE c_get_uni_grd_old_val;

		       IF l_uni_grd_old_value IS NULL
                       THEN
                            l_uni_grd_old_value := 'NULLValue';
                       END IF;
                  END IF;

		  IF ((l_new_value IS NULL) OR l_new_value = '<null>' OR l_new_value = '<NULL>')
                  THEN
                       l_uni_grd_new_value := 'NULLValue';
                  ELSE
                       l_uni_grade_new_val_query := 'select '||l_people_group_column||' '||
                                                    'from pay_people_groups'||' '||
                                                    'where PEOPLE_GROUP_ID = '||l_new_value;
                       debug('l_uni_grade_new_val_query: '||l_uni_grade_new_val_query);

                       OPEN c_get_uni_grd_new_val FOR l_uni_grade_new_val_query;
                       FETCH c_get_uni_grd_new_val INTO l_uni_grd_new_value;
                       CLOSE c_get_uni_grd_new_val;

		       IF l_uni_grd_new_value IS NULL
                       THEN
                            l_uni_grd_new_value := 'NULLValue';
                       END IF;
                  END IF;

                  debug('l_uni_grd_old_value: '||l_uni_grd_old_value);
                  debug('l_uni_grd_new_value: '||l_uni_grd_new_value);

                  IF l_uni_grd_old_value <> l_uni_grd_new_value
                  THEN
                       debug('Returning Y');
                       debug_exit(l_proc);
                       RETURN 'Y';
                  END IF;
            END IF;

        ELSIF l_unigrade_source = 'ASSIGNMENT' AND l_assignment_column IS NOT NULL
         THEN
            IF (l_chg_table= 'PER_ALL_ASSIGNMENTS_F' AND l_chg_column_name= trim(l_assignment_column))
            THEN
                 debug('Returning Y');
                 debug_exit(l_proc);
                 RETURN 'Y';
            END IF;
        END IF;

	debug('Returning N');
        debug_exit(l_proc);
        RETURN 'N';
    END is_curr_sal_change_event;
    ---
    -- ----------------------------------------------------------------------------
    -- |---------------------< get_start_end_date >------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_start_end_date
                (
                p_assignment_id         NUMBER
                ,p_business_group_id    NUMBER
                ,p_effective_date       DATE
                ,p_start_date           OUT NOCOPY DATE
                ,p_end_date             OUT NOCOPY DATE
                )RETURN NUMBER
    IS
        l_proc varchar2(72) := g_proc_name||'.get_start_end_date';
        l_temp_date       DATE;
        l_error           NUMBER;
        l_return          VARCHAR2(10);
    BEGIN --get_start_end_date
        debug_enter(l_proc);

        IF g_effective_date <> p_effective_date THEN
            -- reset globals for every new date
            g_salary_ele_end_date          := c_highest_date;
            g_non_salary_ele_end_date      := c_highest_date;
            g_sal_chg_event_exists         := 'N';
        END IF;

        g_effective_date := p_effective_date;

        IF g_salary_ended = 'Y' AND is_today_sal_start() = 'Y' THEN
            p_start_date  :=  g_effective_date;
            l_return  :=  is_next_sal_end
                            (
                            p_end_date  =>  g_salary_end_date
                            );
            IF g_salary_end_date IS NULL THEN
                g_salary_ended    := 'N';
                g_salary_started  := 'Y';
            END IF;
            p_end_date    :=  g_salary_end_date;
            debug('p_start_date: '||p_start_date||'   p_end_date: '||p_end_date);
            debug_exit(l_proc);
            RETURN 0;
        END IF;

        -- Check if the current event is salary end event.
        IF is_today_sal_end() = 'Y' THEN
          /*IF  is_curr_sal_end() = 'Y' THEN
                p_start_date  :=  NULL;
                g_salary_end_date    :=  NULL;
                debug('p_start_date: '||p_start_date||'   g_salary_end_date: '||g_salary_end_date);
          ELSE
                p_start_date  :=  g_effective_date;
                g_salary_end_date    :=  g_effective_date;
                debug('p_start_date: '||p_start_date||'   g_salary_end_date: '||g_salary_end_date);
          END IF;*/
          p_start_date  :=  NULL;
          g_salary_end_date    :=  NULL;
          g_salary_ended    := 'Y';
          g_salary_started  := 'N';
          p_end_date    :=  g_salary_end_date;
          debug('p_start_date: '||p_start_date||'   p_end_date: '||p_end_date);
          debug_exit(l_proc);
          RETURN 0;
        END IF;

        IF g_salary_started = 'Y' THEN

            IF is_today_sal_ele_end = 'Y' THEN
                IF is_curr_sal_ele_end  = 'Y' THEN
                      debug('g_sal_chg_event_exists: '||g_sal_chg_event_exists);
                      IF g_sal_chg_event_exists = 'Y' THEN
                          p_start_date  :=  g_effective_date;
                          g_salary_end_date    :=  NULL;

                      ELSE
                          p_start_date  :=  g_effective_date+1;
                          l_return  :=  is_next_sal_end
                                          (
                                          p_end_date  =>  g_salary_end_date
                                          );
                      END IF;

                ELSE
                      p_start_date  :=  g_effective_date+1;
                      l_return  :=  is_next_sal_end
                                          (
                                          p_end_date  =>  g_salary_end_date
                                          );


                END IF; --IF is_curr_sal_ele_end()  = 'Y'
                p_end_date    :=  g_salary_end_date;
                debug('p_start_date: '||p_start_date||'   p_end_date: '||p_end_date);
                debug_exit(l_proc);
                RETURN 0;
            END IF; -- IF is_today_sal_ele_end() = 'Y'

            IF is_curr_sal_change_event()  = 'Y' THEN
                p_start_date  :=  g_effective_date;
                l_return  :=  is_next_sal_end
                                    (
                                    p_end_date  =>  g_salary_end_date
                                    );
            ELSE
                p_start_date  :=  NULL;
                g_salary_end_date    :=  NULL;
            END IF;--IF is_curr_sal_change_event()  = 'Y'
            p_end_date    :=  g_salary_end_date;
            debug('p_start_date: '||p_start_date||'   p_end_date: '||p_end_date);
            debug_exit(l_proc);
            return 0;

        ELSE -- IF g_salary_started = 'Y'
            p_start_date  :=  NULL;
            g_salary_end_date    :=  NULL;
            p_end_date    :=  g_salary_end_date;
            debug('p_start_date: '||p_start_date||'   p_end_date: '||p_end_date);
            debug_exit(l_proc);
            RETURN 0;
        END IF; -- IF g_salary_started = 'Y'

        p_end_date    :=  g_salary_end_date;
        debug('p_start_date: '||p_start_date||'   p_end_date: '||p_end_date);
        debug_exit(l_proc);
        RETURN 0;
    END get_start_end_date;
    ---
    -- ----------------------------------------------------------------------------
    -- |-------------------------< get_contract_type >-----------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_contract_type
                (
                p_assignment_id          NUMBER
                ,p_business_group_id     NUMBER
                ,p_effective_date        IN DATE
                ,p_contract_type         OUT NOCOPY VARCHAR2
                ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_proc_name||'.get_contract_type';
        l_contract_type pqp_assignment_attributes_f.contract_type%type;
        l_work_pattern  pqp_assignment_attributes_f.work_pattern%type;
        l_period_divisor    VARCHAR2(10);
        l_error_msg         VARCHAR2(100);
        l_err_no            NUMBER;
        l_error             NUMBER;
    BEGIN
        debug_enter(l_proc);
        /* Currently for all MOD employees the contract type will be 'M'*/
        p_contract_type  :=  'M';

        /* The following code should be uncommented if contract type will
            not be a hard-coded value*/

        /*IF g_penserver_contract_type IS NOT NULL
          AND g_contract_type_effective_date  =  p_effective_date THEN
              p_contract_type  :=  g_penserver_contract_type;
        ELSE
            OPEN csr_get_contract_type
                    (
                    p_effective_date  =>  p_effective_date
                    );
            FETCH csr_get_contract_type INTO l_contract_type;
            CLOSE csr_get_contract_type;

            IF l_contract_type IS NULL THEN
                -- Raise warning that the contract type is missing
                debug('WARNING: Contract type for the person is missing',20);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                               (p_error_number        =>    94441
                               ,p_error_text          =>    'BEN_94441_NO_CONTRACT_TYPE'
                               ,p_token1              =>    to_char(g_effective_date,'dd-MON-yyyy')
                               );
            ELSE
                debug('l_contract_type: '||l_contract_type,20);
                l_err_no := pqp_utilities.pqp_gb_get_table_value(
                              p_business_group_id         =>    p_business_group_id
                             ,p_effective_date            =>    p_effective_date
                             ,p_table_name                =>    'PQP_CONTRACT_TYPES'
                             ,p_column_name               =>    'PenServer Contract Type'
                             ,p_row_name                  =>    l_contract_type
                             ,p_value                     =>    p_contract_type
                             ,p_error_msg                 =>    l_error_msg
                             ,p_refresh_cache             =>    'N'
                            );
                IF p_output IS NULL THEN
                    -- raise warning that the PenServer Contract Type is missing in the UDT PQP_CONTRACT_TYPES for the contract
                    debug('WARNING: PenServer Contract Type is missing in the'||
                                'UDT PQP_CONTRACT_TYPES for the contract: '||l_contract_type,20);
                    l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                               (p_error_number        =>    94442
                               ,p_error_text          =>    'BEN_94442_NO_PEN_CONTRACT_TYPE'
                               ,p_token1              =>    to_char(g_effective_date,'dd-MON-yyyy')
                               );
                ELSE
                    p_output := upper(p_output);
                    g_contract_type                 :=  l_contract_type;
                    g_penserver_contract_type       :=  p_contract_type;
                    g_contract_type_effective_date  :=  p_effective_date;
                END IF; -- IF p_output IS NULL
            END IF; -- IF l_contract_type IS NULL
        END IF; -- IF g_penserver_contract_type IS NOT NULL*/

        debug('PenServer Contract Type: '||p_contract_type);
        debug_exit(l_proc);
        return l_error;
    END get_contract_type;
    ---
    ----------------------------------------------------------------------------
    -- |------------------------< get_element_attribution >--------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE get_element_attribution
              (
              p_element_name      VARCHAR2
              ,p_ele_attribution  OUT NOCOPY  r_ele_attribution
              )
    IS
          l_proc varchar2(72) := g_proc_name||'get_element_attribution';
          l_element_type_id   NUMBER;
          l_ele_attribution   r_ele_attribution;

          CURSOR csr_get_ele_type_id
          IS
             SELECT element_type_id
             FROM pay_element_types_f
             WHERE element_name = p_element_name
             AND rownum=1;

          CURSOR csr_get_ele_attribution
                     (
                     p_element_type_id    NUMBER
                     )
          IS
             SELECT pei.eei_information1  from_time_dimension
                    ,pei.eei_information2  pay_source_value
                    ,pei.eei_information3  qualifier
                    ,pei.eei_information4  fte
                    ,pei.eei_information5  termtime
                    ,pei.eei_information7  calc_type
                    ,pei.eei_information8  calc_value
                    ,pei.eei_information9  input_value
                    ,NVL(pei.eei_information10
                        ,decode(pei.eei_information2,'IV','Y','N')) link_to_assign
                    ,NVL(pei.eei_information12,'Y') term_time_yes_no  -- ! be careful
                    ,NVL(pei.eei_information13,'N') sum_multiple_entries_yn
                    ,NVL(pei.eei_information14,'N') lookup_input_values_yn
                    ,pei.eei_information16 column_name_source_type
                    ,pei.eei_information17 column_name_source_name
                    ,pei.eei_information18 row_name_source_type
                    ,pei.eei_information19 row_name_source_name
              FROM -- pay_element_types_f pet
                    pay_element_type_extra_info pei
              WHERE pei.element_type_id = p_element_type_id
              AND pei.information_type = 'PQP_UK_ELEMENT_ATTRIBUTION';
    BEGIN
          debug_enter(l_proc);

          OPEN csr_get_ele_type_id;
          FETCH csr_get_ele_type_id INTO l_element_type_id;
          CLOSE csr_get_ele_type_id;

          debug('l_element_type_id: '||l_element_type_id);

          IF g_ele_attribution.exists(l_element_type_id) THEN
              debug('Element attribution is already fetched for this element: '||p_element_name);
              p_ele_attribution :=  g_ele_attribution(l_element_type_id);
          ELSE
              debug('Fetch the Element attribution for this element: '||p_element_name);
              OPEN csr_get_ele_attribution(l_element_type_id);
              FETCH csr_get_ele_attribution INTO l_ele_attribution;
              IF csr_get_ele_attribution%FOUND THEN
                  g_ele_attribution(l_element_type_id)  :=  l_ele_attribution;
                  p_ele_attribution   :=    l_ele_attribution;
              END IF;
              CLOSE csr_get_ele_attribution;
          END IF;

          debug_exit(l_proc);
    END get_element_attribution;
    ------------------------------------------------------------------------------
    --|-------------------------< get_notional_pay >-----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_notional_pay
                (
                p_assignment_id       IN NUMBER
                ,p_business_group_id  IN NUMBER
                ,p_effective_date  IN DATE
                ,p_name            IN VARCHAR2
                ,p_rt_element      IN VARCHAR2
                ,p_rate            IN OUT NOCOPY NUMBER
                ,p_custom_function IN VARCHAR2
                ,p_allowance_code   IN VARCHAR2
                ,p_allowance_pet_id IN NUMBER
                ) RETURN NUMBER
    IS
        l_proc varchar2(72) := g_proc_name||'.get_notional_pay';
        l_contract_type           VARCHAR2(1);
        l_to_time_dim             VARCHAR2(1);
        l_basic_sal_rate          VARCHAR2(80);
        l_err_no                  NUMBER;
        l_err_msg                 VARCHAR2(100);
        l_assignment_category     VARCHAR2(20);
        l_fte                     VARCHAR2(1) := 'Y';
        l_notional_pay            NUMBER;
        l_error                   NUMBER;
        l_sqlstr                  VARCHAR2(2000);
        l_user_rate               NUMBER  :=  0;
        l_ele_attribution         r_ele_attribution;
        l_fte_value               NUMBER;
    BEGIN
        debug_enter(l_proc);

        debug('Parameters: ');
        debug('p_business_group_id:' || p_business_group_id,10);
        debug('p_assignment_id:' || p_assignment_id,10);
        debug('p_effective_date:' || p_effective_date,10);
        debug('p_name:' || p_name,10);
        debug('p_rt_element:' || p_rt_element,10);
        -- get contract type
        l_error :=  get_contract_type
                       (
                       p_assignment_id          =>    p_assignment_id
                       ,p_business_group_id     =>    p_business_group_id
                       ,p_effective_date        =>    p_effective_date
                       ,p_contract_type         =>    l_contract_type
                       );
        IF l_contract_type IS NOT NULL THEN
            -- depending on the contract type the to-time-dimension is decided
            IF l_contract_type = '5' OR l_contract_type = '6' THEN
                l_to_time_dim := 'W';
            ELSE
                l_to_time_dim := 'A';
            END IF;

            debug('l_to_time_dim:' || l_to_time_dim,10);


            l_err_no  :=  pqp_rates_history_calc.rates_history
                                (p_assignment_id             =>   p_assignment_id
                                ,p_calculation_date          =>   p_effective_date
                                ,p_name                      =>   p_name
                                ,p_rt_element                =>   p_rt_element
                                ,p_to_time_dim               =>   l_to_time_dim
                                ,p_rate                      =>   l_notional_pay
                                ,p_error_message             =>   l_err_msg
                                --,p_contract_type             =>   g_contract_type
                                --,p_contract_type_usage       =>   'OVERRIDE'
                                );

            if l_err_no <> -1 then

                -- 115.60
                IF p_rt_element = 'E' THEN
                    -- for element mode call check for the FTE attribution
                    --  and reverse it.
                    get_element_attribution
                          (
                          p_element_name      =>    p_name
                          ,p_ele_attribution  =>    l_ele_attribution
                          );
                   IF l_ele_attribution.fte <> 'N' THEN
                      --if fte attribution is other than 'N'
                      -- fetch the FTE value of that date and reverse
                      --    the fte value in the notional pay value;
                      l_fte_value :=  get_fte_value
                                        (
                                        p_assignment_id   =>  g_assignment_id
                                        ,p_effective_date =>  p_effective_date
                                        );
                     debug('l_fte_value: '||l_fte_value);
                     IF l_fte_value > 0 THEN
                        -- fte value is returned as -1 when the value is not there.
                        l_notional_pay :=  l_notional_pay/nvl(l_fte_value,1);
                     END IF;
                   END IF;
                END IF;
                -- get the user notional pay value
                IF p_custom_function IS NOT NULL THEN
                    BEGIN
                        -- build the call to the user function.
                        l_sqlstr    :=
                               'BEGIN '
                            || p_custom_function
                            || '( :assignment_id,:business_group_id,:effective_date,'
                            || ':source_name,:source_qualifier,:to_time_dim,:notional_rate,:allowance_code,'
                            || ':allowance_pet_id,:user_rate);'
                            || 'END;';

                        IF g_debug
                        THEN
                           debug('l_sqlstr: ' || l_sqlstr);
                        END IF;

                        EXECUTE IMMEDIATE l_sqlstr
                           USING              p_assignment_id
                                        ,     p_business_group_id
                                        ,     p_effective_date
                                        ,     p_name                -- name of the element or rate type
                                        ,     p_rt_element          -- 'R' / 'E'
                                        ,     l_to_time_dim         -- 'W' / 'A'
                                        ,     l_notional_pay        -- Historic Rates values
                                        ,     p_allowance_code
                                        ,     p_allowance_pet_id
                                        ,OUT    l_user_rate;          -- value returned by the user function

                        p_rate          :=  NVL(l_user_rate,0);
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
                              debug('ERROR: Error Raised during calculation of Notional Pay',20);
                              l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                               (p_error_number        =>    94541
                                               ,p_error_text          =>    'BEN_94541_ERR_USR_NOTIONAL_PAY'
                                               ,p_token1              =>    p_custom_function
                                               );
                          ELSE
                              RAISE;
                          END IF;
                    END;
                ELSE
                    debug('Without using the callout fucntion.',30);
                    p_rate          :=  NVL(l_notional_pay,0);
                END IF; --IF p_custom_function IS NOT NULL THEN
            else
                debug('ERROR: Error Raised during calculation of Notional Pay',20);
                l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_error
                                   (p_error_number        =>    94456
                                   ,p_error_text          =>    'BEN_94456_ERR_NOTIONAL_PAY'
                                   ,p_token1              =>    SUBSTR(l_err_msg,1,30)
                                   );
                p_rate          :=  0;
            end if; --if l_err_no <> -1

        END IF; --IF l_contract_type IS NOT NULL

        debug('Notional Pay: '||p_rate,10);
        debug_exit(l_proc);
        return 0;
    END get_notional_pay;
    ---
    ----------------------------------------------------------------------------
    -- |------------------------< get_fte_value >--------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_fte_value
              (
              p_assignment_id   NUMBER
              ,p_effective_date  DATE
              )RETURN NUMBER
    IS
        l_proc varchar2(72) := g_proc_name||'.get_fte_value';
        l_fte_value NUMBER;
        CURSOR csr_get_fte_value
        IS
          SELECT value
          FROM PER_ASSIGNMENT_BUDGET_VALUES_F
          WHERE assignment_id = p_assignment_id
          AND UNIT = 'FTE'
          AND p_effective_date between effective_start_date
                          AND effective_end_date;
    BEGIN
        debug_enter(l_proc);
        OPEN csr_get_fte_value;
        FETCH csr_get_fte_value INTO l_fte_value;
        CLOSE csr_get_fte_value;
        IF l_fte_value IS NOT NULL THEN
          return l_fte_value;
        END IF;
        return -1;
        debug_exit(l_proc);
    END get_fte_value;
    ---
    -- ----------------------------------------------------------------------------
    -- |------------------------< get_actual_pay >--------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_actual_pay
                (
                p_assignment_id   IN NUMBER
                ,p_notional_pay   IN NUMBER
                ,p_effective_date IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                )RETURN NUMBER
    IS
        l_proc varchar2(72) := g_proc_name||'.get_actual_pay';
        l_assignment_category     VARCHAR2(20);
        l_fte_value               NUMBER;
        l_error                   NUMBER;
    BEGIN
      debug_enter(l_proc);
      l_fte_value :=  get_fte_value(p_assignment_id,p_effective_date);
      IF l_fte_value <> -1 THEN
        debug('Par-time employee.. FTE value is less than 1',10);
        IF l_fte_value < 1 THEN
            p_output  :=  (p_notional_pay * l_fte_value);
            debug('Actual pay: '||to_char(p_output),20);
        END IF;
      ELSE
        -- data error.
        debug('Data Error: FTE value for the person is missing on: '||to_char(g_effective_date,'dd/mm/yyyy'),20);
        l_error :=  PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                       (p_error_number        =>    94449
                       ,p_error_text          =>    'BEN_94449_NO_FTE_VALUE'
                       ,p_token1              =>    to_char(g_effective_date,'dd-MON-yyyy')
                       );
      END IF;
      debug_exit(l_proc);
      return 0;
    END get_actual_pay;
    ---
    -- ----------------------------------------------------------------------------
    -- |------------------------< init_st_end_date_glob --------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE init_st_end_date_glob
    IS
        l_proc varchar2(72) := g_proc_name||'.init_st_end_date_glob';
    BEGIN
      debug_enter(l_proc);

      -- reset assignment level globals
      g_pay_proc_evt_tab             :=  ben_ext_person.g_pay_proc_evt_tab;
      g_salary_ended                 := 'N';
      g_salary_started               := 'Y';
      g_salary_ele_end_date          := c_highest_date;
      g_non_salary_ele_end_date      := c_highest_date;
      g_sal_chg_event_exists         := 'N';
      g_salary_end_date              := NULL;
      g_is_terminated                := 'N';
      g_salary_ended_today           := 'N';
      g_allowance_has_end_dated      := 'N';

      debug_exit(l_proc);
    END init_st_end_date_glob;
    ---
    ---
    -- ----------------------------------------------------------------------------
    -- |-------------------< get_first_retro_event_date --------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_first_retro_event_date
                (
                p_assignment_id    IN  NUMBER
                ,p_retro_event_date OUT NOCOPY DATE
                )RETURN NUMBER
    IS
          l_proc varchar2(72) := g_proc_name||'get_first_retro_event_date';
    BEGIN
          debug_enter(l_proc);

        IF  g_min_effective_date.EXISTS(p_assignment_id)
        THEN
          debug('g_min_effective_date(g_assignment_id): '||g_min_effective_date(p_assignment_id),20);
          p_retro_event_date  :=  g_min_effective_date(p_assignment_id);

          g_retro_event_date_reported :=  TRUE;

          debug('p_retro_event_date: '||p_retro_event_date,10);
        END IF;

        debug_exit(l_proc);
        RETURN 0;
    END get_first_retro_event_date;
    ---

    ---
    -- ----------------------------------------------------------------------------
    -- |------------------------< get_rate_usr_func_name >--------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE get_rate_usr_func_name
                (
                p_business_group_id   NUMBER
                ,p_legislation_code   VARCHAR2
                ,p_interface_name     VARCHAR2    -- expected to be SALARY / ALLOWANCE
                ,p_rate_name          OUT NOCOPY VARCHAR2
                ,p_rate_code          OUT NOCOPY VARCHAR2
                ,p_usr_rate_function  OUT NOCOPY VARCHAR2
                ,p_sal_ele_fte_attr   OUT NOCOPY VARCHAR2 -- 115.60
                )
    IS
          c_seeded_basic_sal_rate_name   CONSTANT VARCHAR2(80) := 'PenServer Pensionable Salary';
          c_seeded_basic_sal_rate_code   CONSTANT VARCHAR2(80) := 'PEN_SALARY';
          l_rate_code          VARCHAR2(80);
          l_rate_name          VARCHAR2(80);
          l_config_value   PQP_UTILITIES.t_config_values;
          l_proc varchar2(72) := g_proc_name||'get_rate_usr_func_name';
          l_itr NUMBER;
    BEGIN
          debug_enter(l_proc);

          debug('p_business_group_id: '||p_business_group_id,10);
          debug('p_legislation_code: '||p_legislation_code,10);
          debug('p_interface_name: '||p_interface_name,10);


          PQP_UTILITIES.get_config_type_values(
                             p_configuration_type   =>    'PQP_GB_PENSERVER_RATE_TYPES'
                            ,p_business_group_id    =>    p_business_group_id
                            ,p_legislation_code     =>    p_legislation_code
                            ,p_tab_config_values    =>    l_config_value
                          );
          IF l_config_value.COUNT > 0 THEN
              FOR i in 1..l_config_value.COUNT
              LOOP
                  IF i = 1 THEN
                      l_itr := l_config_value.FIRST;
                  ELSE
                      l_itr := l_config_value.NEXT(l_itr);
                  END IF;
                  IF p_interface_name = 'SALARY' AND l_config_value(l_itr).pcv_information1 = 'BAS_SALARY' THEN
                      p_rate_code          :=  l_config_value(l_itr).pcv_information2;
                      p_usr_rate_function  :=  l_config_value(l_itr).pcv_information3;
                      p_sal_ele_fte_attr   :=  l_config_value(l_itr).pcv_information4;
                      EXIT;
                  ELSIF p_interface_name = 'ALLOWANCE' AND l_config_value(l_itr).pcv_information1 = 'ALLOWANCE' THEN
                      --p_rate_code           :=  l_config_value(l_itr).pcv_information2;
                      p_usr_rate_function  :=  l_config_value(l_itr).pcv_information3;
                      EXIT;
                  END IF;
              END LOOP;
          END IF;

          IF p_rate_code IS NOT NULL THEN
              p_rate_name :=  HR_GENERAL.DECODE_LOOKUP
                                            (
                                            p_lookup_type   =>  'PQP_RATE_TYPE'
                                            ,p_lookup_code  =>  p_rate_code
                                            );

          END IF;

          debug('p_rate_name: '||p_rate_name);
          debug('p_rate_code: '||p_rate_code);
          debug('p_usr_rate_function: '||p_usr_rate_function);
          debug('p_sal_ele_fte_attr: '||p_sal_ele_fte_attr);
          debug_exit(l_proc);
    END get_rate_usr_func_name;
    ---

END PQP_GB_PSI_FUNCTIONS;

/
