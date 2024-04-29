--------------------------------------------------------
--  DDL for Package Body PQP_GB_PSI_LOCATION_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PSI_LOCATION_CODES" AS
--  /* $Header: pqpgbpsiloc.pkb 120.0 2006/04/13 05:02:20 anshghos noship $ */

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
-- |------------------------< chk_location_codes_crit >-------------------|
-- ----------------------------------------------------------------------------

FUNCTION chk_location_codes_crit
    (p_business_group_id       IN         NUMBER
    ,p_loc_id                  IN         VARCHAR2
    )
  RETURN VARCHAR2
IS
--
  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_location_codes_crit';

  l_return              VARCHAR2(1) := 'N';
  l_loc_id              NUMBER;
  l_location_name       VARCHAR2(80) := NULL;
  l_value               NUMBER;
--
BEGIN
--

  debug_enter(l_proc_name);

  IF g_business_group_id IS NULL
  THEN
    clear_cache;
    g_business_group_id := p_business_group_id;
    g_paypoint          :=  PQP_GB_PSI_FUNCTIONS.paypoint(p_business_group_id);

    g_debug		:=  pqp_gb_psi_functions.check_debug(g_business_group_id);

    IF g_paypoint = ''
       or
       NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> g_paypoint)
    THEN
      l_value := PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                    (p_assignment_id       =>    -1
                    ,p_error_number        =>    94453
                    ,p_error_text          =>    'BEN_94453_INV_PAYPOINT'
                    );
    END IF;

  END IF;

  debug('Entering chk_location_codes_crit ...',10);

    l_loc_id := FND_NUMBER.canonical_to_number(p_loc_id);


    IF l_loc_id = -1
    THEN
      l_return := 'Y';
      debug('l_loc_id (was null) : ' || l_loc_id, 14);
    ELSE
      OPEN csr_location_code(l_loc_id);
      FETCH csr_location_code into g_loc_code;
        IF csr_location_code%FOUND THEN

          l_return := 'Y';
          -- check for special characters
          IF NOT PQP_GB_PSI_FUNCTIONS.is_alphanumeric(p_string=> g_loc_code) THEN
            -- store warning
            OPEN csr_location_name(l_loc_id);
            FETCH csr_location_name into l_location_name;
              IF csr_location_name%FOUND THEN
                l_value := PQP_GB_PSI_FUNCTIONS.raise_extract_warning
                             (p_assignment_id       =>    -(l_loc_id)
                             ,p_error_number        =>    94451
                             ,p_error_text          =>    'BEN_94451_INV_LOC_CODE'
                             ,p_token1              =>    l_location_name
                             );
              END IF;
            CLOSE csr_location_name;

          END IF;
        ELSE
          l_return := 'N';
        END IF;
      CLOSE csr_location_code;
    END IF;

    debug('l_return : ' || l_return,17);

  debug('Exiting chk_location_codes_crit ...',20);
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

END chk_location_codes_crit;




-- ----------------------------------------------------------------------------
-- |------------------------< location_extract_main >----------------------------|
-- ----------------------------------------------------------------------------

  FUNCTION location_extract_main
    (p_rule_parameter           IN         VARCHAR2 -- parameter
    ,p_output                   OUT NOCOPY VARCHAR2
    )
  RETURN number IS
  --

      l_proc_name           VARCHAR2(61):=
           g_proc_name||'location_extract_main';
      l_value number;
      l_effective_date DATE;
  --
  BEGIN

  debug_enter(l_proc_name);

  -- switch on the trace

    debug('Entering basic_extract_main ...',0);
    debug('p_rule_parameter'||p_rule_parameter,1);


    -- select the function call based on the parameter being passed to the rule
    IF p_rule_parameter = 'PayPoint' THEN
      debug('About to enter PayPoint location',20);
      p_output :=  g_paypoint;
      debug('paypoint : '|| p_output,25);

    ELSIF p_rule_parameter = 'LocCode' THEN
      debug('About to enter LocCode function',30);
      p_output := g_loc_code;
      debug('LocCode : '|| p_output,25);

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

  END location_extract_main;


-- ----------------------------------------------------------------------------
-- |------------------------< location_codes_post_processing >------------------|
-- ----------------------------------------------------------------------------

  FUNCTION location_codes_post_processing RETURN VARCHAR2
  IS

    l_proc_name          VARCHAR2(61):=
       g_proc_name||'location_codes_post_processing';

  BEGIN -- basic_data_post_proc_rule

    debug_enter(l_proc_name);

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

  END location_codes_post_processing; -- basic_data_post_proc_rule


END PQP_GB_PSI_LOCATION_CODES;

/
