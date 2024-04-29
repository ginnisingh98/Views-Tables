--------------------------------------------------------
--  DDL for Package Body PQP_GB_TP_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_TP_PENSION_EXTRACTS" AS
--  /* $Header: pqpgbtp4.pkb 120.1.12010000.3 2009/05/29 07:07:08 nchinnam ship $ */
--
--
--
  PROCEDURE debug
    (p_trace_message  IN     VARCHAR2
    ,p_trace_location IN     NUMBER
    )
  IS
     l_padding VARCHAR2(12);
     l_MAX_MESSAGE_LENGTH NUMBER:= 72;
  BEGIN

      IF p_trace_location IS NOT NULL THEN

        l_padding := SUBSTR
                      (RPAD(' ',LEAST(g_nested_level,5)*2,' ')
                      ,1,l_MAX_MESSAGE_LENGTH
                         - LEAST(LENGTH(p_trace_message)
                                ,l_MAX_MESSAGE_LENGTH)
                      );

       hr_utility.set_location
        (l_padding||
         SUBSTR(p_trace_message
               ,GREATEST(-LENGTH(p_trace_message),-l_MAX_MESSAGE_LENGTH))
        ,p_trace_location);

      ELSE

       hr_utility.trace(SUBSTR(p_trace_message,1,250));

      END IF;

  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_number   IN     NUMBER )
  IS
  BEGIN
      debug(fnd_number.number_to_canonical(p_trace_number));
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_date     IN     DATE )
  IS
  BEGIN
      debug(fnd_date.date_to_canonical(p_trace_date));
  END debug;
--
--
--
  PROCEDURE debug_enter
    (p_proc_name IN VARCHAR2
    ,p_trace_on  IN VARCHAR2
    )
  IS
--     l_trace_options    VARCHAR2(200);
  l_extract_attributes    pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes%ROWTYPE;
  l_business_group_id     per_all_assignments_f.business_group_id%TYPE;

  BEGIN

-- --Uncomment this code to run the extract with a debug trace
--
--   IF  g_nested_level = 0 -- swtich tracing on/off at the top level only
--   AND NVL(p_trace_on,'N') = 'Y'
--   THEN
--
--      hr_utility.trace_on(NULL,'REQID'); -- Pipe name REQIDnnnnnn
--
--   END IF; -- if nested level = 0
--
-- --Uncomment this code to run the extract with a debug trace

    -- Added for Tracing as Type 1 calls Type 4 functions
  IF  g_nested_level = 0 THEN -- swtich tracing on/off at the top level only

    -- Set the trace flag, but only the first time around
    IF g_trace IS NULL THEN

      OPEN pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes;
      FETCH pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes INTO l_extract_attributes;
      CLOSE pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes;

      l_business_group_id := fnd_global.per_business_group_id;

      BEGIN
        g_trace := hruserdt.get_table_value
                  (p_bus_group_id   => l_business_group_id
                  ,p_table_name     => l_extract_attributes.user_table_name
                  ,p_col_name       => 'Attribute Location Qualifier 1'
                  ,p_row_value      => 'Debug'
                  ,p_effective_date => NULL -- don't hv the date
                  );
      EXCEPTION
        WHEN OTHERS THEN
          g_trace := 'N';
      END;

      g_trace := nvl(g_trace,'N');

      debug('UDT Trace Flag : '||g_trace);

    END IF; -- g_trace IS NULL THEN

    IF NVL(p_trace_on,'N') = 'Y'
       OR
       g_trace = 'Y' THEN

      hr_utility.trace_on(NULL,'REQID'); -- Pipe name REQIDnnnnnn
      g_debug := hr_utility.debug_enabled;

    END IF; -- NVL(p_trace_on,'N') = 'Y'
    --
  END IF; -- if nested level = 0

    g_nested_level :=  g_nested_level + 1;
    debug('Entered: '||NVL(p_proc_name,g_proc_name),g_nested_level*100);

  END debug_enter;
--
--
--
  PROCEDURE debug_exit
    (p_proc_name IN VARCHAR2
    ,p_trace_off IN VARCHAR2
    )
  IS
  BEGIN

    debug('Leaving: '||NVL(p_proc_name,g_proc_name),-g_nested_level*100);
    g_nested_level := g_nested_level - 1;

  -- debug enter sets trace ON when g_trace = 'Y' and nested level = 0
  -- so we must turn it off for the same condition
  -- Also turn off tracing when the override flag of p_trace_off has been passed as Y
  IF (g_nested_level = 0
      AND
      g_trace = 'Y'
     )
     OR
     NVL(p_trace_off,'N') = 'Y' THEN

    hr_utility.trace_off;

  END IF; -- (g_nested_level = 0


--  --Uncomment this code to run the extract with a debug trace
--
--  IF  g_nested_level = 0
--  AND NVL(p_trace_off,'Y') = 'Y'
--  THEN
--
--    hr_utility.trace_off;
--
--  END IF;
--
--  --Uncomment this code to run the extract with a debug trace


  END debug_exit;
--
--
--
  FUNCTION get_extract_udt_info
    (p_udt_column_name VARCHAR2
    ,p_udt_row_name    VARCHAR2
    ,p_effective_date  DATE
    ) RETURN VARCHAR2 -- row value
  IS
    l_udt_value  pay_user_column_instances_f.value%type;
    l_proc_name  VARCHAR2(61):= 'get_extract_udt_info';
  BEGIN
    debug_enter(l_proc_name);

    l_udt_value := hruserdt.get_table_value
      (p_bus_group_id   => g_business_group_id
      ,p_table_name     => g_extract_udt_name
      ,p_col_name       => p_udt_column_name
      ,p_row_value      => p_udt_row_name
      ,p_effective_date => NVL(p_effective_date,g_effective_date)
      );
    debug('l_udt_value:'||l_udt_value,1030) ;
    debug_exit(l_proc_name);
    RETURN l_udt_value;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug_exit(' No data found in '||l_proc_name);
      l_udt_value := NULL;
      RETURN l_udt_value;
  END get_extract_udt_info;
--
--
--
--  FUNCTION get_establishment_details
--    (l_location_id        IN         NUMBER
--    ) RETURN pqp_gb_tp_pension_extracts.csr_estb_details%ROWTYPE
--  IS
--
--    l_estb_details      csr_estb_details%ROWTYPE;
--    l_proc_name         VARCHAR2(61):= 'get_establishment_details';
--
--  BEGIN
--      debug_enter(l_proc_name);
--
--     OPEN csr_estb_details(l_location_id);
--     FETCH csr_estb_details INTO l_estb_details;
--     CLOSE csr_estb_details;
--
--     debug_exit(l_proc_name);
--     RETURN l_estb_details;
--
--  END get_establishment_details;
----
--
--
  PROCEDURE fetch_criteria_establishments
    (p_estb_details IN csr_estb_details%ROWTYPE)
  IS

   l_estb_details       csr_estb_details%ROWTYPE;
   l_lea_dets_by_loc    csr_lea_details_by_loc%ROWTYPE ;

   l_organization_id    NUMBER ;          --Added for non-lea Location

   l_proc_name          VARCHAR2(61):= 'fetch_criteria_establishments';

  BEGIN
    debug_enter(l_proc_name);
    debug (l_proc_name, 1210);

    debug ('p_estb_details.business_group_id:'||p_estb_details.business_group_id);
    debug ('p_estb_details.location_id:'||p_estb_details.location_id);
    debug ('p_estb_details.lea_estb_yn:'||p_estb_details.lea_estb_yn);
    debug ('p_estb_details.estb_number:'||p_estb_details.estb_number);
    debug ('p_estb_details.estb_name:'||p_estb_details.estb_name);
    debug ('p_estb_details.estb_type:'||p_estb_details.estb_type);
    debug ('p_estb_details.school_number:'||p_estb_details.school_number);
    --debug ('p_estb_details.organization_id:'||p_estb_details.organization_id);

    IF g_estb_number = '0000' THEN
      debug ('inside IF g_estb_number = 0000', 1220);
      OPEN csr_estb_details
       (p_estb_number => p_estb_details.estb_number
       ,p_lea_estb_yn => 'Y'
       );
    ELSE
      debug ('inside ELSE of g_estb_number = 0000', 1230);
      -- changes fro non-Lea Estb
     /* OPEN csr_lea_details_by_loc(p_location_id => p_estb_details.location_id);
      FETCH csr_lea_details_by_loc INTO l_lea_dets_by_loc;

      IF (csr_lea_details_by_loc%FOUND
          AND
          l_lea_dets_by_loc.lea_number IS NOT NULL
        ) THEN
        debug ('l_lea_dets_by_loc.organization_id: '||l_lea_dets_by_loc.organization_id);
        l_organization_id := l_lea_dets_by_loc.organization_id ;
      ELSE
        l_organization_id := NULL;
      END IF ;

      CLOSE csr_lea_details_by_loc ;*/


      OPEN csr_estb_details
       (p_estb_number => p_estb_details.estb_number
       ,p_estb_type   => p_estb_details.estb_type
       ,p_lea_estb_yn => 'N'
       );
    END IF;

    LOOP
      FETCH csr_estb_details INTO l_estb_details;
      EXIT WHEN csr_estb_details%NOTFOUND;
      g_criteria_estbs(l_estb_details.location_id):= l_estb_details;
      debug('Establishment Details...');
      debug(g_criteria_estbs(l_estb_details.location_id).location_id);
      debug(g_criteria_estbs(l_estb_details.location_id).lea_estb_yn);
      debug(g_criteria_estbs(l_estb_details.location_id).estb_number);
      debug(g_criteria_estbs(l_estb_details.location_id).estb_name);
      debug(g_criteria_estbs(l_estb_details.location_id).estb_type);
      -- Added new segment school number for salary scale changes
      debug(g_criteria_estbs(l_estb_details.location_id).school_number);
      debug('...Establishment Details');
    END LOOP;
    CLOSE csr_estb_details;

    debug_exit(l_proc_name);
  END fetch_criteria_establishments;
--
--
--
  FUNCTION get_translate_asg_emp_cat_code
    (p_asg_emp_cat_cd   VARCHAR2
    ,p_effective_date   DATE
    ) RETURN VARCHAR2
  IS
  --
    l_proc_name VARCHAR2(61):= 'get_translate_asg_emp_cat_code';
    l_udt_value VARCHAR2(1):= '?';
    CURSOR csr_get_emp_cat_code (p_effective_date DATE) IS
    SELECT extv.value
      FROM pay_user_tables  tbls
          ,pay_user_columns asgc
          ,pay_user_columns extc
          ,pay_user_rows_f  urws
          ,pay_user_column_instances_f asgv
          ,pay_user_column_instances_f extv
      WHERE tbls.user_table_name =
        'PQP_GB_TP_EMPLOYMENT_CATEGORY_TRANSALATION_TABLE'
        AND asgc.user_table_id = tbls.user_table_id
        AND extc.user_table_id = tbls.user_table_id
        AND asgc.user_column_name = 'Assignment Employment Category Lookup Code'
        AND extc.user_column_name = 'Pension Extracts Employment Category Code'
        AND urws.user_table_id = tbls.user_table_id
        AND (urws.business_group_id = g_business_group_id
            OR
             (urws.business_group_id IS NULL
              AND urws.legislation_code = g_legislation_code)
            OR
             (urws.business_group_id IS NULL AND urws.legislation_code IS NULL)
            )
        AND p_effective_date BETWEEN urws.effective_start_date
                                 AND urws.effective_end_date
        AND asgv.user_column_id = asgc.user_column_id
        AND p_effective_date BETWEEN asgv.effective_start_date
                                 AND asgv.effective_end_date
        AND extv.user_column_id = extc.user_column_id
        AND p_effective_date BETWEEN extv.effective_start_date
                                 AND extv.effective_end_date
        AND asgv.user_row_id = urws.user_row_id
        AND extv.user_row_id = asgv.user_row_id
        AND asgv.value = p_asg_emp_cat_cd;
  --
  BEGIN

    debug_enter(l_proc_name);
  --

    IF p_asg_emp_cat_cd = g_asg_emp_cat_cd AND g_ext_emp_cat_cd IS NOT NULL
    THEN
       l_udt_value := g_ext_emp_cat_cd;
    ELSE
    --
       OPEN csr_get_emp_cat_code (NVL(p_effective_date,g_effective_date));
      FETCH csr_get_emp_cat_code INTO l_udt_value;
      g_asg_emp_cat_cd := p_asg_emp_cat_cd;
      g_ext_emp_cat_cd := l_udt_value;
      CLOSE csr_get_emp_cat_code;
    --
    END IF;
    --
    debug_exit(l_proc_name);
    RETURN l_udt_value;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('No Data Found in Translate UDT');
      debug_exit;
      l_udt_value := NULL;
    RETURN l_udt_value;
  END get_translate_asg_emp_cat_code;
--
--
--
  PROCEDURE set_run_effective_dates
  IS
     l_proc_name VARCHAR2(61):= 'set_run_effective_dates';
     l_year      NUMBER; --RET2.a : New Variable

     CURSOR csr_last_run_details IS
     SELECT MAX(TRUNC(rslt.eff_dt)) -- highest effective date of all prev runs
       FROM pqp_extract_attributes  pqea
           ,ben_ext_rslt            rslt
           ,ben_ext_rslt_dtl        rdtl
           ,ben_ext_rcd             drcd
            WHERE pqea.ext_dfn_type = g_extract_type
        AND rslt.ext_dfn_id   = pqea.ext_dfn_id
        AND rslt.business_group_id = g_business_group_id
        AND rslt.ext_stat_cd NOT IN
              ('F' -- Job Failure
              ,'R' -- Rejected By User
              ,'X' -- Executing
              )
        AND rdtl.ext_rslt_id  = rslt.ext_rslt_id
        AND drcd.ext_rcd_id   = rdtl.ext_rcd_id
        AND drcd.rcd_type_cd  = 'H'
        AND SUBSTR(rdtl.val_01
                  ,1
                  ,INSTR(rdtl.val_01,':',1,3)--upto third occurence
                  )
            =
             SUBSTR(g_header_system_element
                   ,1
                   ,INSTR(g_header_system_element,':',1,3)
                   )
        AND rslt.eff_dt < g_effective_date
        -- The following part check the successful runs only for the LEA
        -- for which the report is run currently.
        -- the g_lea_number has already been set by the set_extract_globals.
              AND SUBSTR(rdtl.val_01
               ,INSTR(rdtl.val_01,':',1,1)+1 --lea Number
               ,INSTR(rdtl.val_01,':',1,2)-INSTR(rdtl.val_01,':',1,1)-1) = g_lea_number ;



     CURSOR csr_next_run_details IS
     SELECT MIN(TRUNC(rslt.eff_dt))  -- least effective date of all future runs
       FROM pqp_extract_attributes  pqea
           ,ben_ext_rslt            rslt
           ,ben_ext_rslt_dtl        rdtl
           ,ben_ext_rcd             drcd
          WHERE pqea.ext_dfn_type = g_extract_type
        AND rslt.ext_dfn_id   = pqea.ext_dfn_id
        AND rslt.business_group_id = g_business_group_id
-- even failed future runs are to be considered
-- since pay process events might have completed
--        AND rslt.ext_stat_cd NOT IN
--              ('F' -- Job Failure
--              ,'R' -- Rejected By User
--              ,'X' -- Executing
--              )
        AND rdtl.ext_rslt_id  = rslt.ext_rslt_id
        AND drcd.ext_rcd_id   = rdtl.ext_rcd_id
        AND drcd.rcd_type_cd  = 'H'
        AND SUBSTR(rdtl.val_01
                  ,1
                  ,INSTR(rdtl.val_01,':',1,3) --upto third occurence of
                  )
            =
             SUBSTR(g_header_system_element
                   ,1
                   ,INSTR(g_header_system_element,':',1,3)
                   )
        AND rslt.eff_dt >= g_effective_date -- include any runs on the same day
        -- The following part check the successful runs only for the LEA
        -- for which the report is run currently.
        -- the g_lea_number has already been set by the set_extract_globals.
        AND SUBSTR(rdtl.val_01
               ,INSTR(rdtl.val_01,':',1,1)+1 --lea Number
               ,INSTR(rdtl.val_01,':',1,2)-INSTR(rdtl.val_01,':',1,1)-1) = g_lea_number ;

  BEGIN
    debug_enter(l_proc_name);

      debug(TO_CHAR(g_effective_date,'DD-MON-YYYY'), 10);
      debug('g_effective_date: '||
        fnd_date.date_to_canonical(g_effective_date));

      g_effective_run_date := -- "end of day" of a day before effective date
        fnd_date.canonical_to_date
          (TO_CHAR(g_effective_date - 1,'YYYY/MM/DD')||'23:59:59');

      debug('g_effective_run_date: '||to_char(g_effective_run_date));

      OPEN csr_last_run_details;
      FETCH csr_last_run_details INTO g_last_effective_date;

      debug('g_last_effective_date just after fetch: '||
        fnd_date.date_to_canonical(g_last_effective_date), 30);

      IF csr_last_run_details%NOTFOUND -- not likely ever bcos of use of MAX
        OR
         g_last_effective_date IS NULL
      THEN

         debug('No succeful last completed run was found',40);

         g_last_effective_date :=
           TO_DATE(get_extract_udt_info
                     ('Initial Extract Date' -- column
                     ,'Criteria' )
                  ,'DD-MM-YYYY');

         IF g_last_effective_date IS NULL THEN -- use tax year first of april

           debug('Initial Extract Date at UDT not defined', 50);

           SELECT TO_DATE('01-04-'||
                      DECODE
                        (SIGN(TO_NUMBER(TO_CHAR(g_effective_date,'MM')) - 04)
                        ,-1,TO_CHAR(ADD_MONTHS(g_effective_date,-12),'YYYY')
                        ,TO_CHAR(g_effective_date,'YYYY'))
                    ,'DD-MM-YYYY')
             INTO g_last_effective_date
             FROM DUAL;

         END IF;

      END IF;
      CLOSE csr_last_run_details;

      debug('g_last_effective_date: '||
        fnd_date.date_to_canonical(g_last_effective_date),60);

      OPEN csr_next_run_details;
      FETCH csr_next_run_details INTO g_next_effective_date;
      CLOSE csr_next_run_details;

      debug('g_next_effective_date: '||
        fnd_date.date_to_canonical(g_next_effective_date), 70);

      g_header_system_element:=
        g_header_system_element||
        fnd_date.date_to_canonical(g_last_effective_date)||':'||
        fnd_date.date_to_canonical(g_effective_run_date) ||':'||
        fnd_date.date_to_canonical(g_next_effective_date)||':';

      debug('g_header_system_element: '||g_header_system_element, 80);

      -- Setting all the required date globals of tp1 package
      -- other tp1 globals are already set by set_extract_globals function
      pqp_gb_t1_pension_extracts.g_effective_date         := g_effective_date ;
      pqp_gb_t1_pension_extracts.g_last_effective_date    := g_last_effective_date ;
      pqp_gb_t1_pension_extracts.g_next_effective_date    := g_next_effective_date ;
      pqp_gb_t1_pension_extracts.g_effective_run_date     := g_effective_run_date ;
      pqp_gb_t1_pension_extracts.g_header_system_element  := g_header_system_element;

      -- RET2.a : Changes related to Legislative updates to Retention Allowance
      -- The Pension Year start date is required : as changes are effective from
      -- 01-APR-2004.
      -- Need to set the g_pension_year_start_date of Type1 Package
      -- as we are not holding a pension_year_start_date in Type4 Package

      debug(l_proc_name, 90);
      IF to_number(to_char(g_effective_date, 'MM'))
         BETWEEN 1 AND 3 THEN
        debug(l_proc_name, 110);
        -- Pension year should end YY - 1
        l_year := to_number(to_char(g_effective_date, 'YYYY')) - 1;

      ELSE
        debug(l_proc_name, 120);
        -- Pension year should end YY
        l_year := to_number(to_char(g_effective_date, 'YYYY'));

      END IF; -- End if of month check...

      debug('l_year: '||to_char(l_year), 130);

      pqp_gb_t1_pension_extracts.g_pension_year_start_date
                              := to_date('01/04/'||to_char(l_year), 'DD/MM/YYYY');

      debug('g_pension_year_start_date: '||
        fnd_date.date_to_canonical(pqp_gb_t1_pension_extracts.g_pension_year_start_date),140);

      debug_exit(l_proc_name);
  END set_run_effective_dates;
--
-- The following three functions were added for salary scale changes
-- This function returns the udt id for a given udt name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_udt_id >---------------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_udt_id (p_udt_name  IN VARCHAR2)
      RETURN NUMBER
   IS

   --
     -- Cursor to get user_table_id
     CURSOR csr_get_udt_id
     IS
        SELECT user_table_id
          FROM pay_user_tables
         WHERE user_table_name = p_udt_name
           AND (   (    business_group_id IS NULL
                    AND legislation_code = g_legislation_code
                   )
                OR (    business_group_id IS NOT NULL
                    AND business_group_id = g_business_group_id
                   )
               );

      l_proc_name   VARCHAR2 (60) :=    g_proc_name
                                     || 'get_udt_id';
      l_udt_id      NUMBER;
      l_proc_step   NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      OPEN csr_get_udt_id;
      FETCH csr_get_udt_id INTO l_udt_id;
      CLOSE csr_get_udt_id;

      IF g_debug
      THEN
         DEBUG (   'UDT Name: '
                || p_udt_name);
         DEBUG (   'UDT ID: '
                || TO_CHAR(l_udt_id));
         l_proc_step                := 20;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      RETURN l_udt_id;
   END get_udt_id;

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_allow_ele_info >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_allow_ele_info (p_assignment_id  IN NUMBER
                               ,p_effective_date IN DATE
                               ,p_table_name     IN VARCHAR2
                               ,p_row_name       IN VARCHAR2
                               ,p_column_name    IN VARCHAR2
                               )
                                RETURN NUMBER
   IS
     --
     l_proc_name         VARCHAR2 (80) :=    g_proc_name
                                             || 'get_allow_ele_info';
     l_proc_step         NUMBER;
     l_return            NUMBER;
     l_user_value        pay_user_column_instances_f.value%TYPE;
     l_error_msg         VARCHAR2(2000);
     l_element_type_id   NUMBER := NULL;

     --
   BEGIN
   --
         debug_enter(l_proc_name);

      l_return := pqp_utilities.pqp_gb_get_table_value
                    (p_business_group_id => g_business_group_id
                    ,p_effective_date    => p_effective_date
                    ,p_table_name        => p_table_name
                    ,p_column_name       => p_column_name
                    ,p_row_name          => p_row_name
                    ,p_value             => l_user_value
                    ,p_error_msg         => l_error_msg
                    );

      --
      IF l_return <> -1 THEN

	       --
         IF l_user_value IS NOT NULL THEN

            -- fetch the element type id information
               debug ('User Value: ' || l_user_value, 10);

            l_element_type_id := pqp_utilities.pqp_get_element_type_id
                                   (p_business_group_id => g_business_group_id
                                   ,p_legislation_code  => g_legislation_code
                                   ,p_effective_date    => p_effective_date
                                   ,p_element_type_name => l_user_value
                                   ,p_error_code        => l_return
                                   ,p_message           => l_error_msg
                                   );

	          --
	          IF l_return <> -1 THEN -- no error

             debug ('Element Type ID: '
                         || TO_CHAR(l_element_type_id),20);
            --
            ELSE -- Else of return <> -1 , error
            --
	            --
                  debug_exit(l_proc_name);
              --
	            -- Raise an error for element does not exist
              l_return := pqp_gb_tp_extract_functions.raise_extract_error
                           (p_business_group_id => g_business_group_id
                           ,p_assignment_id     => p_assignment_id
                           ,p_error_text        =>'BEN_93026_EXT_TP1_ELE_NOTEXIST'
                           ,p_error_number      => 93026
			                     ,p_token1            => l_user_value);

            END IF; -- End if of element type exists return check ...
            --
         END IF; -- End if of user value is not null check ...
         --
      ELSE -- Else return = -1 from get table value function

            debug_exit(l_proc_name);

         fnd_message.set_name ('PQP', 'PQP_230661_OSP_DUMMY_MSG');
         fnd_message.set_token ('TOKEN', l_error_msg);
         fnd_message.raise_error;

      END IF; -- End if of return <> -1 check from get table value func...

         debug_exit(l_proc_name);

      RETURN l_element_type_id;
   --
   END get_allow_ele_info;
   --
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_allow_rt_ele_info >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_allow_rt_ele_info (p_assignment_id IN NUMBER
                                  ,p_effective_date IN DATE
                                  ,p_table_name     IN VARCHAR2
                                  ,p_row_name       IN VARCHAR2
                                  ,p_column_name    IN VARCHAR2
                                  ,p_tab_aln_eles   IN t_allowance_eles
                                  )
                                  RETURN t_allowance_eles
   IS
     --
     l_proc_name          VARCHAR2 (80)
                                  :=    g_proc_name
                                     || 'get_allow_rt_ele_info';
     l_proc_step          NUMBER;
     l_return             NUMBER;
     l_user_value         pay_user_column_instances_f.value%TYPE;
     l_error_msg          VARCHAR2(2000);
     l_element_type_id    NUMBER := NULL;
     l_tab_allowance_eles t_allowance_eles := p_tab_aln_eles;

     -- RET1.a : new variables to store element_type_extra_info_id
     l_element_type_extra_info_id  pay_element_type_extra_info.element_type_extra_info_id%type ;
     l_retval		 NUMBER;
     l_token     VARCHAR2(80);
     --
   BEGIN
   --
     debug_enter (l_proc_name);

     l_return := pqp_utilities.pqp_gb_get_table_value
                  (p_business_group_id => g_business_group_id
                  ,p_effective_date    => p_effective_date
                  ,p_table_name        => p_table_name
                  ,p_column_name       => p_column_name
                  ,p_row_name          => p_row_name
                  ,p_value             => l_user_value
                  ,p_error_msg         => l_error_msg
                  );
     --
     IF l_return <> -1
     THEN
         --
         IF l_user_value IS NOT NULL THEN

            -- fetch the element type id information
            -- for this rate type the rate type validation
            -- is already added in the UDT so no need to
            -- check for validation again

               debug ('User Value: '
                      || l_user_value, 10);

	          --
            OPEN csr_get_eles_frm_rate (p_effective_date
                                       ,l_user_value
                                       );
            LOOP
              FETCH csr_get_eles_frm_rate INTO l_element_type_id;
              EXIT WHEN csr_get_eles_frm_rate%NOTFOUND;

              l_tab_allowance_eles (l_element_type_id).element_type_id
                := l_element_type_id;
              l_tab_allowance_eles (l_element_type_id).salary_scale_code
                               := p_row_name;

              -- check which type of allowance, do only for retention allowance
              IF p_column_name = 'Retention Allowance Rate Type'
              THEN
                l_token := 'Retention Allowance';

                -- RET1.a : start of block
                -- get element_type_extra_info_id
                l_retval := pqp_utilities.pqp_get_ele_type_extra_info_id
                           (p_element_type_id             => l_element_type_id
                           ,p_information_type            => 'PQP_UK_ELEMENT_ATTRIBUTION'
                           ,p_element_type_extra_info_id  => l_element_type_extra_info_id
                           ,p_error_msg                   => l_error_msg
                           );

                --
                IF l_retval <> -1 -- no error
                THEN

                  debug('l_element_type_extra_info_id: '||l_element_type_extra_info_id,20);

                  -- store element_type_extra_info_id in the collection
                  l_tab_allowance_eles (l_element_type_id).element_type_extra_info_id
                                                     := l_element_type_extra_info_id ;

                ELSE -- error case

                  debug('l_element_type_extra_info_id not found',30);

                  debug_exit(l_proc_name);

                  /*
                  -- check which type of allowance, and set error token
                  IF p_column_name = 'Management Allowance Rate Type' THEN
                    l_token := 'Management Allowance';
                  ELSIF p_column_name = 'Retention Allowance Rate Type' THEN
                    l_token := 'Retention Allowance';
                  ELSIF p_column_name = 'TLR Allowance Rate Type' THEN
                    l_token := 'TLR Allowance';
                  END IF;
                  */

                  --
                  -- Raise an error for failure to get element_type_extra_info_id
                  l_return := pqp_gb_tp_extract_functions.raise_extract_error
                               (p_business_group_id => g_business_group_id
                               ,p_assignment_id     => p_assignment_id
                               -- RET1.a : Added error BEN_94155_EXT_TP1_ERR_RET_ALL
                               ,p_error_text        =>'BEN_94155_EXT_TP1_ERR_RET_ALL'
                               ,p_error_number      => 94155
                               ,p_token1            => l_token
                               );

                END IF; -- IF l_retval <> -1 -- no error
              END IF; -- IF p_column_name = 'Retention Allowance Rate Type'
              -- RET1.a : end of block


              debug ('Element Type ID: '
                         || TO_CHAR(l_element_type_id),40);
            END LOOP; -- End loop of eles from rate cursor...
            CLOSE csr_get_eles_frm_rate;
	          --

	          --
            IF l_tab_allowance_eles.COUNT = 0 THEN

                 debug_exit(l_proc_name);

               -- Raise an error for no element are associated
               -- with this rate type

               l_return := pqp_gb_tp_extract_functions.raise_extract_error
                            (p_business_group_id => g_business_group_id
                            ,p_assignment_id     => p_assignment_id
                            ,p_error_text        =>'BEN_93640_EXT_TP_NO_ELE_FOR_RT'
                            ,p_error_number      => 93640 );

            END IF; -- End if of element type count = 0 check ...
            --
         END IF; -- End if of user value is not null check ...
         --

      ELSE -- Else return = -1 from get table value function

            debug_exit(l_proc_name);

         fnd_message.set_name ('PQP', 'PQP_230661_OSP_DUMMY_MSG');
         fnd_message.set_token ('TOKEN', l_error_msg);
         fnd_message.raise_error;

      END IF; -- End if of return <> -1 check from get table value func...
      --

         debug_exit(l_proc_name);

      RETURN l_tab_allowance_eles;
   --
   END get_allow_rt_ele_info;
   --

-- ----------------------------------------------------------------------------
-- |----------------------------< fetch_allow_eles_frm_udt >------------------|
-- ----------------------------------------------------------------------------
   PROCEDURE fetch_allow_eles_frm_udt
               (p_assignment_id  IN NUMBER
               ,p_effective_date IN DATE
               )
   IS
      --

      CURSOR csr_get_user_rows (c_udt_id NUMBER)
      IS
      SELECT row_low_range_or_name
        FROM pay_user_rows_f
        WHERE user_table_id = c_udt_id
        AND p_effective_date BETWEEN effective_start_date
                                   AND effective_end_date
        ORDER BY display_sequence;


      l_proc_name         VARCHAR2 (80) :=    g_proc_name
                                           || 'fetch_allow_eles_frm_udt';
      l_proc_step         NUMBER;
      l_element_type_id   NUMBER;
      l_tab_mng_aln_eles  t_allowance_eles;
      l_tab_ret_aln_eles  t_allowance_eles;

      -- 115.49 : TLR
      l_tab_tlr_aln_eles  t_allowance_eles;

      l_user_row_name     pay_user_rows_f.row_low_range_or_name%TYPE;
      l_udt_name          pay_user_tables.user_table_name%TYPE :=
                           'PQP_GB_TP_ALLOWANCE_ELEMENTS_MAPPING_TABLE';
      l_return            NUMBER;
      l_udt_id            NUMBER;
      l_user_value        pay_user_column_instances_f.value%TYPE;
      l_error_msg         VARCHAR2(2000);

      -- RET1.a : new variables to store element_type_extra_info_id
      l_element_type_extra_info_id  pay_element_type_extra_info.element_type_extra_info_id%type;
      l_retval		 NUMBER;
      --
   --
   BEGIN
      --
      debug_enter(l_proc_name);
      debug('p_effective_date: '|| p_effective_date);



      -- Get UDT ID
      l_udt_id := get_udt_id
                    (p_udt_name => l_udt_name);

      -- Get the user rows information for this UDT
      --
      IF l_udt_id IS NOT NULL THEN

           debug(l_proc_name, 10);

        --
        OPEN csr_get_user_rows (l_udt_id);
        LOOP
          FETCH csr_get_user_rows INTO l_user_row_name;
          EXIT WHEN csr_get_user_rows%NOTFOUND;

          -- Get the user value for this row if one exist
          -- for each type of allowance and store it in their
          -- respective collections
             debug('User Row Name: '
                    || l_user_row_name,20);
             debug('User Column Name: Management Allowance Element Type');

          l_element_type_id := get_allow_ele_info
                                 (p_assignment_id  => p_assignment_id
                                 ,p_effective_date => p_effective_date
                                 ,p_table_name     => l_udt_name
                                 ,p_row_name       => l_user_row_name
                                 ,p_column_name    => 'Management Allowance Element Type'
                                 );
          debug('l_element_type_id : '|| to_char(l_element_type_id));

      	  IF l_element_type_id IS NOT NULL
          THEN

             -- Check whether users have specified any rate type information
             -- for this salary scale
             debug(l_proc_name, 30);
             debug('p_effective_date: '|| p_effective_date,31);
             debug('udT_name :' || l_udt_name,32);

             l_return := pqp_utilities.pqp_gb_get_table_value
                           (p_business_group_id => g_business_group_id
                           ,p_effective_date    => p_effective_date
                           ,p_table_name        => l_udt_name
                           ,p_column_name       => 'Management Allowance Rate Type'
                           ,p_row_name          => l_user_row_name
                           ,p_value             => l_user_value
                           ,p_error_msg         => l_error_msg
                          );

      	     debug('l_user_row_name : '|| l_user_row_name,33);
             debug('l_user_value : '|| l_user_value,34);
             debug('l_return : '|| to_char(l_return),35);

	           --
             IF l_return <> -1 THEN
                --
                IF l_user_value IS NOT NULL THEN
                   -- Raise an error

                     debug_exit(l_proc_name);

                   -- Raise an error as one cannot enter a value
                   -- for both rate type and element type for the
                   -- same salary scale

                   l_return := pqp_gb_tp_extract_functions.raise_extract_error
                                 (p_business_group_id => g_business_group_id
                                 ,p_assignment_id     => p_assignment_id
                                 ,p_error_text        =>'BEN_93639_EXT_TP_ELE_RT_EXISTS'
                                 ,p_error_number      => 93639
				                         ,p_token1            => 'Management Allowance' );

                END IF; -- End if of user value check ...
                --
      	     ELSE -- Else return = -1 from get table value function
                 debug('Leaving: '
                         || l_proc_name, 40);

               fnd_message.set_name ('PQP', 'PQP_230661_OSP_DUMMY_MSG');
               fnd_message.set_token ('TOKEN', l_error_msg);
               fnd_message.raise_error;

             END IF; -- End if of return <> -1 check from get table value func...
             --
             -- Store it in the management allowance collection
             l_tab_mng_aln_eles (l_element_type_id).salary_scale_code
                               := l_user_row_name;
             l_tab_mng_aln_eles (l_element_type_id).element_type_id
                               := l_element_type_id;

          ELSE -- element type id is null
            -- Check for rate type
                debug(l_proc_name, 50);

            l_tab_mng_aln_eles := get_allow_rt_ele_info
                                    (p_assignment_id  => p_assignment_id
                                    ,p_effective_date => p_effective_date
                                    ,p_table_name     => l_udt_name
                                    ,p_row_name       => l_user_row_name
                                    ,p_column_name    => 'Management Allowance Rate Type'
                                    ,p_tab_aln_eles   => l_tab_mng_aln_eles
                                    );

          END IF; -- End if of element type id not null check ...
          -- end of code for "Management Allowance Element Type" --

	        -- start of code for "Retention Allowance Element Type" --

             debug('User Row Name: '
                    || l_user_row_name,60);
             debug('User Column Name: Retention Allowance Element Type');


          l_element_type_id := get_allow_ele_info
                                 (p_assignment_id  => p_assignment_id
                                 ,p_effective_date => p_effective_date
                                 ,p_table_name     => l_udt_name
                                 ,p_row_name       => l_user_row_name
                                 ,p_column_name    => 'Retention Allowance Element Type'
                                 );

          IF l_element_type_id IS NOT NULL THEN

             -- Check whether users have specified any rate type information
             -- for this salary scale
             debug(l_proc_name, 70);

             l_return := pqp_utilities.pqp_gb_get_table_value
                           (p_business_group_id => g_business_group_id
                           ,p_effective_date    => p_effective_date
                           ,p_table_name        => l_udt_name
                           ,p_column_name       => 'Retention Allowance Rate Type'
                           ,p_row_name          => l_user_row_name
                           ,p_value             => l_user_value
                           ,p_error_msg         => l_error_msg
                          );

      	     debug('l_user_row_name : '|| l_user_row_name);
             debug('l_user_value : '|| l_user_value);
             debug('l_return : '|| to_char(l_return));

             IF l_return <> -1 THEN

                IF l_user_value IS NOT NULL THEN
                   -- Raise an error
                   debug_exit(l_proc_name);

                   -- Raise an error as one cannot enter a value
                   -- for both rate type and element type for the
                   -- same salary scale

                   l_return := pqp_gb_tp_extract_functions.raise_extract_error
                                 (p_business_group_id => g_business_group_id
                                 ,p_assignment_id     => p_assignment_id
                                 ,p_error_text        =>'BEN_93639_EXT_TP_ELE_RT_EXISTS'
                                 ,p_error_number      => 93639
			                        	 ,p_token1            => 'Retention Allowance');

                END IF; -- End if of user value check ...
             ELSE -- Else return = -1 from get table value function

                debug('Leaving: ' || l_proc_name,80);

                fnd_message.set_name ('PQP', 'PQP_230661_OSP_DUMMY_MSG');
                fnd_message.set_token ('TOKEN', l_error_msg);
                fnd_message.raise_error;

             END IF; -- End if of return <> -1 check from get table value func...

             -- RET1.a : start of block
             -- get element_type_extra_info_id
             l_retval := pqp_utilities.pqp_get_ele_type_extra_info_id
                         (p_element_type_id             => l_element_type_id
                         ,p_information_type            => 'PQP_UK_ELEMENT_ATTRIBUTION'
                         ,p_element_type_extra_info_id  => l_element_type_extra_info_id
                         ,p_error_msg                   => l_error_msg
			                    );

		         --
	           IF l_retval <> -1 -- no error
	           THEN
               debug('l_element_type_extra_info_id: '||l_element_type_extra_info_id);

             ELSE -- error case
                 debug('l_element_type_extra_info_id not found');
                 debug_exit(l_proc_name);
                 --
                 -- Raise an error for failure to get element_type_extra_info_id
                 l_return := pqp_gb_tp_extract_functions.raise_extract_error
                            (p_business_group_id => g_business_group_id
                            ,p_assignment_id     => p_assignment_id
                            -- RET1.a : Added error BEN_94155_EXT_TP1_ERR_RET_ALL
                            ,p_error_text        =>'BEN_94155_EXT_TP1_ERR_RET_ALL'
                            ,p_error_number      => 94155
                            ,p_token1            => 'Retention Allowance'
                            );
             END IF;
	           -- RET1.a : end of block


             -- Store it in the retention allowance collection
             l_tab_ret_aln_eles (l_element_type_id).salary_scale_code
                               := TO_NUMBER(l_user_row_name);
             l_tab_ret_aln_eles (l_element_type_id).element_type_id
                               := l_element_type_id;

	           -- RET1.a : storing the element_type_extra_info_id
             l_tab_ret_aln_eles (l_element_type_id).element_type_extra_info_id
			                                         := l_element_type_extra_info_id;

	        ELSE -- element type id is null
                -- Check for rate type
            debug(l_proc_name, 90);

            l_tab_ret_aln_eles := get_allow_rt_ele_info
                                    (p_assignment_id  => p_assignment_id
                                    ,p_effective_date => p_effective_date
                                    ,p_table_name     => l_udt_name
                                    ,p_row_name       => l_user_row_name
                                    ,p_column_name    => 'Retention Allowance Rate Type'
                                    ,p_tab_aln_eles   => l_tab_ret_aln_eles
                                    );

          END IF; -- End if of element type id not null check ...
          --

          -- 115.49 TLR (1)
          -- start of code for fetching TLR elements

             debug('User Row Name: '
                    || l_user_row_name,90);
             debug('User Column Name: TLR Allowance Element Type');

          l_element_type_id := get_allow_ele_info
                                 (p_assignment_id  => p_assignment_id
                                 ,p_effective_date => p_effective_date
                                 ,p_table_name     => l_udt_name
                                 ,p_row_name       => l_user_row_name
                                 ,p_column_name    => 'TLR Allowance Element Type'
                                 );
          debug('l_element_type_id : '|| to_char(l_element_type_id));

      	  IF l_element_type_id IS NOT NULL
          THEN

             -- Check whether users have specified any rate type information
             -- for this salary scale
             debug(l_proc_name, 30);
             debug('p_effective_date: '|| p_effective_date,110);
             debug('udT_name :' || l_udt_name,120);

             l_return := pqp_utilities.pqp_gb_get_table_value
                           (p_business_group_id => g_business_group_id
                           ,p_effective_date    => p_effective_date
                           ,p_table_name        => l_udt_name
                           ,p_column_name       => 'TLR Allowance Rate Type'
                           ,p_row_name          => l_user_row_name
                           ,p_value             => l_user_value
                           ,p_error_msg         => l_error_msg
                          );

      	     debug('l_user_row_name : '|| l_user_row_name,130);
             debug('l_user_value : '|| l_user_value,130);
             debug('l_return : '|| to_char(l_return),130);

	           --
             IF l_return <> -1 THEN
                --
                IF l_user_value IS NOT NULL THEN
                   -- Raise an error

                     debug_exit(l_proc_name);

                   -- Raise an error as one cannot enter a value
                   -- for both rate type and element type for the
                   -- same salary scale

                   l_return := pqp_gb_tp_extract_functions.raise_extract_error
                                 (p_business_group_id => g_business_group_id
                                 ,p_assignment_id     => p_assignment_id
                                 ,p_error_text        =>'BEN_93639_EXT_TP_ELE_RT_EXISTS'
                                 ,p_error_number      => 93639
				                         ,p_token1            => 'TLR Allowance' );

                END IF; -- End if of user value check ...
                --
      	     ELSE -- Else return = -1 from get table value function
                 debug('Leaving: '
                         || l_proc_name, 140);

               fnd_message.set_name ('PQP', 'PQP_230661_OSP_DUMMY_MSG');
               fnd_message.set_token ('TOKEN', l_error_msg);
               fnd_message.raise_error;

             END IF; -- End if of return <> -1 check from get table value func...
             --
             -- Store it in the TLR allowance collection
             l_tab_tlr_aln_eles (l_element_type_id).salary_scale_code
                               := l_user_row_name;
             l_tab_tlr_aln_eles (l_element_type_id).element_type_id
                               := l_element_type_id;

          ELSE -- element type id is null
            -- Check for rate type
                debug(l_proc_name, 150);

            l_tab_tlr_aln_eles := get_allow_rt_ele_info
                                    (p_assignment_id  => p_assignment_id
                                    ,p_effective_date => p_effective_date
                                    ,p_table_name     => l_udt_name
                                    ,p_row_name       => l_user_row_name
                                    ,p_column_name    => 'TLR Allowance Rate Type'
                                    ,p_tab_aln_eles   => l_tab_tlr_aln_eles
                                    );

          END IF; -- End if of element type id not null check ...
          -- end of code for "Management Allowance Element Type" --



        END LOOP;
        CLOSE csr_get_user_rows;
      END IF; -- End if of udt id is not null check ...

      debug('Managment collection count: '||TO_CHAR(l_tab_mng_aln_eles.COUNT));
      debug('Retention collection count: '||TO_CHAR(l_tab_ret_aln_eles.COUNT));

      g_tab_mng_aln_eles := l_tab_mng_aln_eles;
      g_tab_ret_aln_eles := l_tab_ret_aln_eles;
      g_tab_tlr_aln_eles := l_tab_tlr_aln_eles;

      debug_exit(l_proc_name);
    --
    END fetch_allow_eles_frm_udt;
--
--
--
  PROCEDURE set_extract_globals
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    )
  IS

     l_proc_name VARCHAR2(61):= 'set_extract_globals';

     l_error              NUMBER ;
     l_tp1_nested_level   NUMBER ;
     l_request_id         NUMBER ;
     l_conc_prog_name     VARCHAR2(30);

     l_udt_id             pay_user_tables.user_table_id%TYPE;
     l_lea_details        csr_lea_details%ROWTYPE;
     l_lea_details_1      csr_lea_details%ROWTYPE;  -- Added for checking if
                                                    -- there are multiple LEA's with same LEA number
     l_lea_dets_by_loc     csr_lea_details_by_loc%ROWTYPE;
     l_estb_details        csr_estb_details%ROWTYPE;
     l_estb_details_by_loc csr_estb_details_by_loc%ROWTYPE;
     l_req_dets            pqp_gb_t1_pension_extracts.csr_request_dets%ROWTYPE;
     l_lea_dets_frm_bg     csr_lea_details%ROWTYPE;



  BEGIN
    debug_enter(l_proc_name);

    debug(l_proc_name, 10);
    debug ('p_business_group_id:'||p_business_group_id);
    debug ('p_effective_date:'||p_effective_date);
    debug ('p_assignment_id:'||p_assignment_id);

    g_business_group_id := p_business_group_id;
    g_effective_date    := p_effective_date;

    -- get the parent request Id.
    -- It is required to fetch the correct LEA number
    -- from the pqp_ext_cross_person_records table.

    OPEN pqp_gb_t1_pension_extracts.csr_request_dets;
    FETCH pqp_gb_t1_pension_extracts.csr_request_dets INTO l_req_dets;
    CLOSE pqp_gb_t1_pension_extracts.csr_request_dets;

    l_request_id := l_req_dets.parent_request_id ;
    debug ('l_request_id:'||l_request_id, 20);

    -- Check for the paerntID till the request Id of TPEP
    -- Coz, there may be requests, which are generating sub requests.
    -- and we are only interested in the main parent process.
    WHILE (l_request_id <> -1)
    LOOP
      g_parent_request_id := l_request_id ;

      OPEN pqp_gb_t1_pension_extracts.csr_request_dets (p_request_id => l_request_id);
      FETCH pqp_gb_t1_pension_extracts.csr_request_dets INTO l_req_dets;
      CLOSE pqp_gb_t1_pension_extracts.csr_request_dets;
      l_conc_prog_name :=  l_req_dets.concurrent_program_name ;
      debug ('l_conc_prog_name:'||l_conc_prog_name, 25);
      l_request_id := l_req_dets.parent_request_id ;
    END LOOP;

    --Extract Process itself generates threads,
    -- We need to be sure if it is TPEP or EP
    --check the concurrent Program Name
    -- BENXTRCT = Extract Process
    -- PQPXTRCT = TPEP
    IF l_conc_prog_name = 'BENXTRCT' THEN  --Extracp Process
      g_parent_request_id := -1 ;
    END IF ;


    -- if the Extract Process is running on its own., then g_parent_request_id = -1
    debug ('g_parent_request_id:'||g_parent_request_id, 30);
    -- This request ID will be furhter used in pqp_gb_t1_pension_extracts.reset_proc_status.

    IF (g_parent_request_id <> -1) THEN
      debug  ('*********this is a TPEP run***********', 40);
    ELSE
      debug  ('*********this is a EXTRACT Process run***********', 50);
    END IF ;

    debug('open csr_pqp_extract_attributes:', 60);

    OPEN csr_pqp_extract_attributes;
    FETCH csr_pqp_extract_attributes INTO g_extract_type, g_extract_udt_name, l_udt_id;
    CLOSE csr_pqp_extract_attributes;

    debug ('g_extract_type:'||g_extract_type, 70);
    debug ('g_extract_udt_name:'||g_extract_udt_name);
    debug ('l_udt_id:'||l_udt_id);

     g_criteria_location_code := get_extract_udt_info
                       ('Location Code' -- column
                       ,'Criteria'      -- row
                       ,p_effective_date
                       );
    debug ('g_criteria_location_code:'||g_criteria_location_code, 80);

    IF g_criteria_location_code IS NOT NULL THEN
      -- it could be a non-lea run to confirm get location EIT Details
      debug ('inside IF g_criteria_location_code IS NOT NULL ', 90);

      OPEN csr_estb_details_by_loc(p_location_code     => g_criteria_location_code
                                   );
      FETCH csr_estb_details_by_loc INTO l_estb_details_by_loc;

      -- Bug on Type 4
      -- Check whether criteria establishment exists
      IF csr_estb_details_by_loc%notfound THEN

              debug ('inside csr_estb_details_by_loc%notfound ', 110);

        l_error := pqp_gb_tp_extract_functions.raise_extract_error
                      (p_business_group_id => p_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_error_text        => 'BEN_93008_EXT_TP4_INVALID_LOC'
                      ,p_error_number      => 93008
                      );
        debug ('raised error:'||l_error, 120);
      END IF; -- End if of not found check...
      CLOSE csr_estb_details_by_loc;

      debug ('l_estb_details_by_loc.business_group_id: '||l_estb_details_by_loc.business_group_id, 130);
      debug ('l_estb_details_by_loc.location_id: '||l_estb_details_by_loc.location_id);
      debug ('l_estb_details_by_loc.lea_estb_yn: '||l_estb_details_by_loc.lea_estb_yn);
      debug ('l_estb_details_by_loc.estb_number: '||l_estb_details_by_loc.estb_number);
      debug ('l_estb_details_by_loc.estb_name: '||l_estb_details_by_loc.estb_name);
      debug ('l_estb_details_by_loc.lea_number: '||l_estb_details_by_loc.lea_number);


      IF l_estb_details_by_loc.lea_estb_yn = 'Y' THEN
      -- it is a lea run in the guise of a non-lea run
        debug ('inside csr_estb_details_by_loc.lea_estb_yn = Y ', 140);
        debug ('***It is an LEA Run *** ', 150);
        g_estb_number:= '0000';
        --g_originators_title := SUBSTR(l_lea_details.lea_name,1,16);
      ELSE -- l_estb_details_by_loc.lea_estb_yn = 'Y'
              debug ('inside ELSE of csr_estb_details_by_loc.lea_estb_yn = Y ', 160);
        debug ('***It is an NON - LEA Run *** ', 170);

        g_estb_number       := l_estb_details_by_loc.estb_number;
        g_originators_title := SUBSTR(l_estb_details_by_loc.estb_name,1,16);

      END IF ;  --l_estb_details_by_loc.lea_estb_yn = 'Y'
    ELSE -- g_criteria_location_code IS NULL
      -- it is a lea run
      debug ('inside ELSE g_criteria_location_code IS NOT NULL ', 180);
      debug ('***It is an LEA Run *** ', 190);
      g_estb_number := '0000' ;
    END IF; -- g_criteria_location_code IS NULL


    -- At this point we know if it is a LEA or a Non-LEA run
    -- And whether it is TPEP or EP...
    -- We need to get the LEA number accordingly.
    debug ('g_lea_number:>'||g_lea_number||'<', 210);
    g_lea_number := NULL; -- coz g_lea_number is a padded string
                          -- and it will fail the csr_lea_details later.

    IF (g_estb_number <> '0000' AND g_parent_request_id <> -1) THEN  --set the g_lea_number
      debug ('***It is an NON- LEA --- TPEP Run *** ', 220);
      -- LEA Number is already s et by the Extract process.
      -- fetch from the cross Person table.
      -- The Cursor fetches the LEA numebr for the current Run.
      OPEN csr_lea_number ;
      FETCH csr_lea_number INTO g_lea_number ;

      IF csr_lea_number%notfound THEN
        debug ('LEA Number not found at pqp_ext_cross_person_records ',230);
        -- it is an Extract Process thread ..
        -- set g_parent_request_id = -1
        g_parent_request_id := -1 ;
      END IF ;
      CLOSE csr_lea_number;
      debug ('g_lea_number:'||g_lea_number, 240);
    ELSIF (g_estb_number <> '0000' AND g_parent_request_id = -1) THEN  ----set the g_lea_number
      debug ('***It is an NON- LEA --- EXTRACT Process Run *** ', 250);
      -- Bugfix 3671727:ENH1 : Get the LEA Number in this order
      --  1) from the location EIT
      --  2) Org linked to that location
      --  3) The BG
      IF l_estb_details_by_loc.lea_number IS NOT NULL  THEN
        -- Step 1) Getting LEA Number from location EIT
        g_lea_number     := l_estb_details_by_loc.lea_number ;
         --For warning msg if more than one LEA are found
        g_token_org_name := l_estb_details_by_loc.estb_name ;
      END IF ;
        debug ('g_lea_number:'||g_lea_number,260);

      IF g_lea_number IS NULL THEN -- fetch it from the Org linked to Location

        -- Step 2) Getting LEA Number from Org linked to the location
        OPEN csr_lea_details_by_loc(l_estb_details_by_loc.location_id);
        FETCH csr_lea_details_by_loc INTO l_lea_dets_by_loc;

        IF (csr_lea_details_by_loc%FOUND
            AND
            l_lea_dets_by_loc.lea_number IS NOT NULL
           ) THEN
          g_lea_number := l_lea_dets_by_loc.lea_number;
          debug ('g_lea_number:'||g_lea_number,270);
        END IF ;
        CLOSE csr_lea_details_by_loc ;
      END IF ;

      IF g_lea_number IS NULL THEN -- fetch it from the BG
        -- LEA Number is not present on org linked to location
        -- Step 3) Look for LEA Number at BG level
        OPEN csr_lea_details
                (p_organization_id => p_business_group_id
                ,p_lea_number      => NULL
                );
        FETCH csr_lea_details INTO l_lea_dets_frm_bg;
        IF (csr_lea_details%FOUND
              AND
              l_lea_dets_frm_bg.lea_number IS NOT NULL
             ) THEN
            g_lea_number        := l_lea_dets_frm_bg.lea_number;
            --For warning msg if more than one LEA are found
            g_token_org_name    := l_lea_dets_frm_bg.organization_name ;
            debug ('g_lea_number:'||g_lea_number,280);
            CLOSE csr_lea_details;
        ELSE -- NOT FOUND or LEA Number is NULL
          -- Close both cursors
          CLOSE csr_lea_details;
            -- Error out as the current BG is not set up as an LEA

          l_error := pqp_gb_tp_extract_functions.raise_extract_error
                      (p_business_group_id => p_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_error_text        => 'BEN_94017_CURR_BG_NOT_LEA_ERR'
                      ,p_error_number      => 94017
                      );
        debug ('raised error:'||l_error, 285);
          RETURN;

        END IF; -- NOT FOUND or LEA Number is NULL
      END IF ; ---- fetch it from the BG

    ELSIF (g_estb_number = '0000') THEN  --set the g_lea_number
      IF  (g_parent_request_id <> -1 ) THEN
        debug ('***It is an LEA --- TPEP Run *** ', 290);
        -- LEA Numebr is already set by the Extract process.
        -- fetch from the cross Person table.
        -- The Cursor fetches the LEA numebr for the current Run.
        OPEN csr_lea_number ;
        FETCH csr_lea_number INTO g_lea_number ;
        IF csr_lea_number%notfound THEN
          debug ('LEA Number not found at pqp_ext_cross_person_records ', 310);
          g_lea_number := NULL ;
        END IF ;
        CLOSE csr_lea_number;
        debug ('g_lea_number:'||g_lea_number,320);
      ELSE
        debug ('***It is an LEA --- EXTRACT Process Run *** ', 330);

      END IF ; -- (g_parent_request_id <> -1 )

      debug('open csr_lea_details:', 340);
      debug ('g_business_group_id:'||g_business_group_id);
      debug ('g_lea_number:>'||g_lea_number||'<');

      OPEN csr_lea_details(p_organization_id => g_business_group_id
      -- ENH1 : added a new parameter to fetch the
      -- LEA details only for the required LEA
                          ,p_lea_number      => g_lea_number);
      FETCH csr_lea_details INTO l_lea_details;
      -- IF no LEA details are found , RAISE an ERROR and EXIT.
      -- The case can arise only if The Extract Process is Run
      -- and there is no LEA defined at BG level at all.
      IF (csr_lea_details%NOTFOUND OR l_lea_details.lea_number IS NULL) THEN
        l_error := pqp_gb_tp_extract_functions.raise_extract_error
                      (p_business_group_id => g_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_error_text        => 'BEN_94017_CURR_BG_NOT_LEA_ERR'
                      ,p_error_number      => 94017
                      );
        debug ('raised error:'||l_error, 350);
        RETURN;
      ELSE  -- csr_lea_details%NOTFOUND
        g_lea_number        := l_lea_details.lea_number;
        g_crossbg_enabled   := nvl(l_lea_details.crossbg_enabled, 'N');
        g_token_org_name    := l_lea_details.organization_name ;
        g_originators_title := SUBSTR(l_lea_details.lea_name,1,16);
      END IF ; -- csr_lea_details%NOTFOUND
      CLOSE csr_lea_details;

    END IF ;  --set the g_lea_number


    debug ('g_business_group_id:'||g_business_group_id, 360);
    debug ('g_effective_date:'||g_effective_date);
    debug ('g_lea_number:'||g_lea_number);

    -- check for more than one LEA with the same LEA_number in a BG .
    OPEN csr_lea_details(p_organization_id => g_business_group_id
                        ,p_lea_number      => g_lea_number);
    FETCH csr_lea_details INTO l_lea_details_1;
        debug ('1. l_lea_details_1.organization_name: '||l_lea_details_1.organization_name, 370);
        debug ('1. l_lea_details_1.CrossBG_Enabled: '||l_lea_details_1.CrossBG_Enabled);
        debug ('1. l_lea_details_1.organization_id: '||l_lea_details_1.organization_id);

    FETCH csr_lea_details INTO l_lea_details_1;
    IF csr_lea_details%FOUND THEN
        debug ('2. l_lea_details_1.organization_name: '||l_lea_details_1.organization_name,380);
        debug ('2. l_lea_details_1.CrossBG_Enabled: '||l_lea_details_1.CrossBG_Enabled);
        debug ('1. l_lea_details_1.organization_id: '||l_lea_details_1.organization_id);
        g_multi_lea_exist  := 'Y'; --set the warning flag o 'Y' .
    END IF;
    CLOSE csr_lea_details;

    debug ('g_estb_number:'||g_estb_number,390);
    debug ('g_originators_title:'||g_originators_title);

    -- Setting all the required globals of tp1 package
    -- global Dates for tp1 will be set in set_run_effective_dates procedure.
    -- These globals are required if the Type4 report is running.
    -- Type1 report sets these globals itself from the Type4 globals

    pqp_gb_t1_pension_extracts.g_business_group_id      := g_business_group_id ;
    pqp_gb_t1_pension_extracts.g_lea_number             := g_lea_number ;
    pqp_gb_t1_pension_extracts.g_crossbg_enabled        := g_crossbg_enabled ;
    pqp_gb_t1_pension_extracts.g_primary_assignment_id  := p_assignment_id ;
    pqp_gb_t1_pension_extracts.g_extract_type           := g_extract_type ;

    -- Extract the list of criteria organizations which will be used to search
    IF g_estb_number = '0000'  THEN -- LEA Run

      fetch_criteria_establishments(l_estb_details);
      -- Call tp1 package procedure to store cross BG details..
      -- If its the LEA run
      -- AND current BG is enabled for cross BG reporting
      IF g_crossbg_enabled = 'Y' THEN
        -- Store all BGs with same LEA Number and
        -- enabled for cross BG reporting
        l_tp1_nested_level := pqp_gb_t1_pension_extracts.g_nested_level; --115.34
        pqp_gb_t1_pension_extracts.g_nested_level := g_nested_level;
        pqp_gb_t1_pension_extracts.store_cross_bg_details ;
        pqp_gb_t1_pension_extracts.g_nested_level :=  l_tp1_nested_level ; --115.34
      ELSE
        -- Bugfix 3823873 :
        -- Setting the master BG Id. It was not being set for single Bg
        -- set up for LEA run. Discovered when debugging issue with date
        -- track updates on NI
        pqp_gb_t1_pension_extracts.g_master_bg_id := g_business_group_id;
      END IF;

    ELSE  --non LEA run
      fetch_criteria_establishments(l_estb_details_by_loc);
      pqp_gb_t1_pension_extracts.g_master_bg_id := g_business_group_id;
    END IF ;

    -- Added for salary scale changes
    -- at the moment do this only for Type 1 and Type 4

    IF g_extract_type IN ('TP4', 'TP1P', 'TP1') THEN

      debug ('inside IF g_extract_type IN (TP4, TP1P, TP1) ', 410);

      g_tab_mng_aln_eles.DELETE;
      g_tab_ret_aln_eles.DELETE;
      g_tab_tlr_aln_eles.DELETE;

      fetch_allow_eles_frm_udt (p_assignment_id  => p_assignment_id
                               ,p_effective_date => p_effective_date
                               );
    END IF; -- End if of extract type check ...

    g_header_system_element
      := g_extract_type||':'||g_lea_number||':'||g_estb_number||':';

    debug ('g_header_system_element:'||g_header_system_element, 420);

    -- Reset the processing status in multiproc data table to U
    -- if the extract process is running on its own.
    l_tp1_nested_level := pqp_gb_t1_pension_extracts.g_nested_level; --115.34
    pqp_gb_t1_pension_extracts.g_nested_level := g_nested_level;

    pqp_gb_t1_pension_extracts.reset_proc_status ;

    pqp_gb_t1_pension_extracts.g_nested_level :=  l_tp1_nested_level ; --115.34

    debug_exit(l_proc_name);
  END set_extract_globals;
--
--
--
  PROCEDURE set_pay_proc_events_to_process
    (p_assignment_id    IN      NUMBER
    ,p_status           IN      VARCHAR2
    ,p_start_date       IN      DATE
    ,p_end_date         IN      DATE
    )
  IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    l_proc_name VARCHAR2(61):= 'set_pay_proc_events_to_process';

  BEGIN
    debug_enter(l_proc_name);

    debug('p_status: '||p_status);
    debug('p_start_date: '||fnd_date.date_to_canonical(p_start_date));
    debug('p_end_date: '||fnd_date.date_to_canonical(p_end_date));

    --
    -- Mark pay_process_events to process
    -- as determined by the date range. The maxmim allowed range
    -- is the last eff date and a day before the current eff date

    UPDATE pay_process_events
       SET retroactive_status = p_status
          ,status             = p_status
     WHERE assignment_id = p_assignment_id
       AND change_type = 'REPORTS'
       AND creation_date -- allow all events as of and on last eff dt
            BETWEEN  GREATEST(NVL(p_start_date,g_last_effective_date)
                             ,g_last_effective_date)
                AND  LEAST(NVL(p_end_date,g_effective_run_date)
                          ,g_effective_run_date)
    ;                    -- allow all events upto end of day (eff_dt - 1)

    COMMIT;

    debug(fnd_number.number_to_canonical(SQL%ROWCOUNT)||' PPE row(s) updated.');

    debug_exit(l_proc_name);
  END set_pay_proc_events_to_process;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_tp4_is_teacher_new_starter >--------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION chk_tp4_is_teacher_new_starter
    (p_business_group_id        IN      NUMBER  -- context
    ,p_effective_date           IN      DATE    -- context
    ,p_assignment_id            IN      NUMBER  -- context
    ) RETURN VARCHAR2                           -- Y or N
IS

  l_inclusion_flag        VARCHAR2(1):='N';
  l_starter_flag          VARCHAR2(1):='N';
--  l_leaver_flag           VARCHAR2(1):='N';
--  l_itr                   NUMBER;
--  l_location_changed      BOOLEAN:= FALSE;
  l_teacher_start_date    DATE;
  l_estb_number_flag      VARCHAR2(1) := 'N' ; -- ENH6
  l_cdt_tchr_start_date   DATE ;  --to keep the start date of candidate assignment
--  l_leaver_date           DATE ;
  l_tp1_nested_level      NUMBER ;
  idx                     NUMBER := 0; --Loop counter
--  cntr                    NUMBER := 0; --Loop counter
  -- these two variabel will be used to check the start and leaver date
  -- for assignments to check if there is any continious assignment
  l_prev_start_date       DATE ;
  l_earliest_start_date   DATE ;
  l_error                 NUMBER;


  l_asg_details           csr_asg_details%ROWTYPE;
  --l_asg_details_up        pqp_gb_t1_pension_extracts.csr_asg_details_up%ROWTYPE;
  l_candidate_asg         csr_asg_details%ROWTYPE; --to keep the candidate assignment for reporting.
  l_pqp_asg_attributes    csr_pqp_asg_attributes_dn%ROWTYPE;
  --l_pqp_asg_attributes_up pqp_gb_t1_pension_extracts.csr_pqp_asg_attributes_up%ROWTYPE;
  l_cdt_asg_attributes    csr_pqp_asg_attributes_dn%ROWTYPE; --to keep the assignment attribues of candidate assignment.

  l_proc_name          VARCHAR2(61):= g_proc_name||'chk_tp4_is_teacher_new_starter';

BEGIN

  debug_enter(l_proc_name);

  debug('Checking Type 4 For Assignment: '
        ||fnd_number.number_to_canonical(p_assignment_id),10);
  debug('p_business_group_id:'||p_business_group_id);
  debug('p_effective_date:'||p_effective_date);
  debug('g_business_group_id:'||g_business_group_id);

    -- set all the globals here, if not already set.

  IF g_business_group_id IS NULL THEN
    debug('Globals are not already set..setting now..', 20);

    -- Added a new param p_assignment_id for type 4 Bug fix
    set_extract_globals(p_business_group_id => p_business_group_id
                          ,p_effective_date    => p_effective_date
                                            ,p_assignment_id     => p_assignment_id
                                      ) ;

    debug('after set_extract_globals', 30);

    -- set the effective dates for the particular LEA.
    -- the Procedure looks for the LEA number at g_lea_number.
    set_run_effective_dates;
    debug('after set_run_effective_dates', 40);
  END IF;

  -- Print all the globals in the log
  debug('-------GLOBALS-----------', 50);
  debug('g_business_group_id:'||g_business_group_id);
  debug('g_effective_date:'||g_effective_date);
  debug('g_lea_number:'||g_lea_number);
  debug('g_extract_type:'||g_extract_type);
  debug('g_extract_udt_name:'||g_extract_udt_name);
  debug('g_crossbg_enabled:'||g_crossbg_enabled);
  debug('pqp_gb_t1_pension_extracts.g_cross_per_enabled:'||pqp_gb_t1_pension_extracts.g_cross_per_enabled);
  debug('g_criteria_location_code:'||g_criteria_location_code);
  debug('g_estb_number:'||g_estb_number);
  debug('g_originators_title:'||g_originators_title);
  debug('g_last_effective_date:'||g_last_effective_date);
  debug('g_next_effective_date:'||g_next_effective_date);
  debug('g_header_system_element:'||g_header_system_element);
  debug('g_effective_run_date:'||g_effective_run_date);
  debug('g_token_org_name:'||g_token_org_name);
  debug('g_multi_lea_exist:'||g_multi_lea_exist);
  debug('g_parent_request_id:'||g_parent_request_id);
  debug('g_warn_no_location:'||g_warn_no_location);
  debug('-------GLOBALS-----------');

  -- Check if there are location existing for the LEA passed to Extract.
  -- IF no Location exists, Raise a warning (for the first assignment only in this thread)
  -- and RETURN..
  IF g_criteria_estbs.COUNT = 0 THEN
  -- the assignment will eventually fail for validity as no location exists.
    l_inclusion_flag := 'N' ;
    -- Raise a warning ..
    warn_if_no_loc_exist(p_assignment_id => p_assignment_id) ;

  ELSE   -- g_criteria_estbs.COUNT = 0

    -- Step 1. Check if no other process is processing the record
    -- for the person to which the p_assignment_id is attached.
    -- the method 'chk_report_person'in type1 report code does that,
    -- by checking for the same national_identifier

    -- If other process is not processing then goto step 2 else STOP.
    l_tp1_nested_level := pqp_gb_t1_pension_extracts.g_nested_level; --115.34
    pqp_gb_t1_pension_extracts.g_nested_level := g_nested_level;

    IF ( pqp_gb_t1_pension_extracts.chk_report_person
                 (p_business_group_id     => p_business_group_id
                 ,p_effective_date        => p_effective_date
                 ,p_assignment_id         => p_assignment_id)
                 ) THEN

      pqp_gb_t1_pension_extracts.g_nested_level := l_tp1_nested_level;
      debug('inside IF chk_report_person', 60);

      -- check if the assignment has raised a starter event in the duration...
      -- if yes, then it is a candidate assignment for this report run
      l_starter_flag := assignment_has_a_starter_event(
                                    p_business_group_id  => g_business_group_id
                                   ,p_assignment_id      => p_assignment_id
                                         ,p_pqp_asg_attributes => l_pqp_asg_attributes  --OUT
                                                           ,p_asg_details        => l_asg_details  --OUT
                                                           ,p_teacher_start_date => l_teacher_start_date  --OUT
                                  ) ;
      debug('after assignment_has_a_starter_event', 70 );
      debug('l_starter_flag:'||l_starter_flag);
      debug('l_teacher_start_date:'||l_teacher_start_date);

      print_debug_asg (l_asg_details) ; --To Remove later
      print_debug_asg_atr (l_pqp_asg_attributes) ; --To Remove Later

      IF l_starter_flag = 'Y' THEN
        -- make this assignment a candidae assignment
        -- and store the l_earliest_start_date
        debug('inside IF l_starter_flag = Y', 80);

        -- Fetch the Estb number for the assignment.
        l_asg_details.estb_number   := g_criteria_estbs(l_asg_details.location_id).estb_number ;
        -- this is a candidate assignment for the reporting.
        -- add this assignment to g_ext_asg_details
        -- and set report_asg = 'N'
        -- (will decide later, if this has to be reported.)
        g_ext_asg_details(p_assignment_id)             := l_asg_details ;
        g_ext_asg_details(p_assignment_id).report_asg  := 'N' ;

        --keep the candidate assignment for further verification.
        l_candidate_asg       := l_asg_details;
        l_cdt_asg_attributes  := l_pqp_asg_attributes ;
        l_cdt_tchr_start_date := l_teacher_start_date ;
        l_earliest_start_date := l_teacher_start_date ;
        debug('l_earliest_start_date:'||l_earliest_start_date, 90);

      ELSE  --l_starter_flag = 'Y' THEN
        debug('inside ELSE l_starter_flag = Y', 110);
        -- as there is no starter event in the report run period,
        -- so this assignment is not valid for the report
        debug('Primary asignment is not a valid teacher asssignment..',120);

        -- As the Primary asignment is not a valid teaching assignment,
        -- we need to fetch the sec assignments for the Same person rec.
        -- we need to fetch the person ID from the primary assignment.
        OPEN pqp_gb_t1_pension_extracts.csr_asg_details_up (p_assignment_id  => p_assignment_id
                                                           ,p_effective_date => g_last_effective_date ) ; --Pension Period Start Date.
        FETCH pqp_gb_t1_pension_extracts.csr_asg_details_up INTO l_asg_details ;
        CLOSE pqp_gb_t1_pension_extracts.csr_asg_details_up ;
        debug('Adding the primary assignment to the global collection..',130);
          g_ext_asg_details(p_assignment_id)            := l_asg_details ;
        g_ext_asg_details(p_assignment_id).report_asg := 'N' ;
      END IF ; -- l_starter_flag .

      -- Fetch all the secondary assignments for the person
      -- with same National Identifier
      -- from all the BGs.  (if Cross BG reporting is enabled)
      debug('Primary assignment has been checked. now fetch all Secondary asignments', 140);
      -- initialize the count of total concurrent
      -- part-time assignment starting on the same date
      pqp_gb_t1_pension_extracts.g_part_time_asg_count := 0 ;
      idx := 0; -- loop counter.....
      FOR l_sec_asgs IN pqp_gb_t1_pension_extracts.csr_sec_assignments(
                                p_primary_assignment_id => p_assignment_id
                               ,p_person_id             => l_asg_details.person_id
                               ,p_effective_date        => g_last_effective_date -- Report period start date
                              )
      -- and loop them to find the final reporting assignment.
      LOOP      -- Check all Sec asignment
        idx := idx + 1;
        debug('Inside csr_sec_assignment loop',210+idx/100000);
        debug('l_sec_asgs.assignment_id:'||to_char(l_sec_asgs.assignment_id));
        debug('l_sec_asgs.person_id:'||to_char(l_sec_asgs.person_id));
        debug('l_sec_asgs.business_group_id:'||to_char(l_sec_asgs.business_group_id));
        debug('l_sec_asgs.bizgrpcol:'||to_char(l_sec_asgs.bizgrpcol));

        l_starter_flag := assignment_has_a_starter_event(
                                 p_business_group_id  => l_sec_asgs.business_group_id
                                ,p_assignment_id      => l_sec_asgs.assignment_id
                                ,p_pqp_asg_attributes => l_pqp_asg_attributes  --OUT
                                            ,p_asg_details        => l_asg_details  --OUT
                                                  ,p_teacher_start_date => l_teacher_start_date  --OUT
                                                 ) ;
        debug('after assignment_has_a_starter_event', 220+idx/100000 );
        debug('l_starter_flag:'||l_starter_flag);
        debug('l_teacher_start_date:'||l_teacher_start_date);
        print_debug_asg (l_asg_details) ; --Need to remove later
        print_debug_asg_atr (l_pqp_asg_attributes) ; --Need to remove later

        IF l_starter_flag = 'Y' THEN
          debug('inside IF l_starter_flag = Y', 230+idx/100000);
          --Check if the assignment is starting effectivly before the earlier chosen assignment
          IF (l_earliest_start_date IS NOT NULL ) THEN

            IF (l_teacher_start_date <= l_earliest_start_date)  THEN --It is a candidate assignment.

              debug('l_teacher_start_date <= l_earliest_start_date', 235+idx/100000);
              l_inclusion_flag := 'Y' ;
              l_earliest_start_date := l_teacher_start_date ;
              debug('l_earliest_start_date:'||l_earliest_start_date);
                  -- check if the assignment_start_date is less
              -- then the start_date of previously choosen candidaet_assignment
              -- if yes, then make the current assignment as the new candidate_asg.
              debug('inside IF (l_candidate_asg <> NULL)', 240+idx/100000);
              debug('l_candidate_asg.start_date:'||l_candidate_asg.start_date);
              debug('l_candidate_asg.ext_emp_cat_cd:'||l_candidate_asg.ext_emp_cat_cd);

              -- ENH6: if there are 2 or more concurrent part-time eligible assignment
              -- report the estb_number = '0953'
              IF((l_asg_details.start_date = l_candidate_asg.start_date) --Conc Part Time chk
                  AND (l_asg_details.ext_emp_cat_cd = 'P')
                  AND (l_candidate_asg.ext_emp_cat_cd = 'P'))THEN
                -- set this flag for concurrent part_time assignments
                -- starting on the same date.
                l_estb_number_flag := 'Y' ;
                debug('l_estb_number_flag:'||l_estb_number_flag, 250+idx/100000);
                -- set the part time assignment count to 2.
                -- get_estb_number function checks this flag and returns '0953' if it is >1
                pqp_gb_t1_pension_extracts.g_part_time_asg_count := 2 ;

              ELSIF (l_asg_details.start_date < l_candidate_asg.start_date) THEN ---Conc Part Time chk
                l_candidate_asg       := l_asg_details ;
                l_cdt_asg_attributes  := l_pqp_asg_attributes ;
                l_cdt_tchr_start_date := l_teacher_start_date ;
                l_estb_number_flag    := 'N' ;  --reset for further loops...
                pqp_gb_t1_pension_extracts.g_part_time_asg_count := 0 ; --reset for further loops.
                debug('l_estb_number_flag:'||l_estb_number_flag, 260+idx/100000);
              END IF; --Conc Part Time chk
              debug('l_estb_number_flag:'||l_estb_number_flag, 270+idx/100000);
            END IF ;  --(l_teacher_start_date <= l_earliest_start_date)
                ELSE --l_earliest_start_date <> NULL
            debug('inside ELSE of l_earliest_start_date IS NOT NULL', 280+idx/100000);
            l_candidate_asg := l_asg_details ; -- First time assignment....
            l_earliest_start_date := l_teacher_start_date ;
                END IF;  --l_earliest_start_date <> NULL
        ELSE  --l_starter_flag = 'Y' THEN
          debug('else of l_starter_flag = Y', 290+idx/100000) ;
        END IF ;  --l_starter_flag = 'Y' THEN
        debug('Moving to next assignment . . . .', 310 + idx/100000);
      END LOOP ;        -- Check all Sec assignment

      debug('After secondary assignment loop....',320);
      debug('l_inclusion_flag:'||l_inclusion_flag);
      debug('total secondary assignments checked:'||idx);
      debug('l_earliest_start_date:'||l_earliest_start_date);
      debug('l_estb_number_flag:'||l_estb_number_flag);
      debug('---------CANDIDATE ASSIGNMENT_DETAILS---------');
      print_debug_asg (l_candidate_asg) ; -- Need to remove later

      IF (l_inclusion_flag = 'N' AND (l_candidate_asg.assignment_id IS NULL)) THEN
        debug('Assignment is not a valid assignemnt to be included in the report.',330);
        g_ext_asg_details(p_assignment_id) := NULL ;
      ELSE -- (l_inclusion_flag = 'N' AND (l_candidate_asg.assignment_id = NULL))
        -- now check all the previous results. to determine the actual report date
        l_prev_start_date := get_prev_tp4_result(l_candidate_asg.person_id) ;
        debug ('l_prev_start_date :'||l_prev_start_date, 335) ;
        IF l_prev_start_date IS NULL THEN
          -- there are no previous results. so the assignment found so far is the candidate asg.
          -- and the earliest start date is correct.
          debug ('l_prev_start_date IS NULL', 340) ;
        ELSIF l_prev_start_date <= l_earliest_start_date THEN
          --raise a warning : "Already reported with start_date = l_prev_start_date"
          l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                                       (p_assignment_id => p_assignment_id
                                       ,p_error_text    => 'BEN_94018_TPA_ALREADY_REPORTED'
                                       ,p_error_number  => 94018
                                       ,p_token1        => fnd_date.date_to_displaydate(l_prev_start_date)
                                       );
          debug ('raised warning for Already reported with start_date:'||l_error,350);
          l_inclusion_flag := 'Y' ;
        ELSIF l_prev_start_date > l_earliest_start_date THEN
          --raise a warning : "Already reported with start_date = l_prev_start_date, new starter found at date = l_earliest_start_date".
          l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                                       (p_assignment_id => p_assignment_id
                                       ,p_error_text    => 'BEN_94019_TPA_RPRTD_NEW_FOUND'
                                       ,p_error_number  => 94019
                                       ,p_token1        => fnd_date.date_to_displaydate(l_prev_start_date)
                                       ,p_token2        => fnd_date.date_to_displaydate(l_earliest_start_date)
                                       );
          debug ('raised warning for Already reported with start_date:'||l_error,360);
          debug ('new starter found.........:'||l_error,370);
          l_inclusion_flag := 'Y' ;
        END IF ;

        -- ENH6: check if there are concurrent part_time assignments,
        -- starting on the same date, set the estb no = '0953'
        debug ('l_candidate_asg.estb_number: '||g_criteria_estbs(l_candidate_asg.location_id).estb_number, 380) ;
        l_candidate_asg.estb_number := g_criteria_estbs(l_candidate_asg.location_id).estb_number;

        -- IF the finally chosen assignment is Primary Assignment,
        IF (l_candidate_asg.assignment_id  = p_assignment_id)  THEN
          g_ext_asg_details(p_assignment_id).report_asg           := 'Y';
          g_ext_asg_details(p_assignment_id).tp_safeguarded_grade := l_cdt_asg_attributes.tp_safeguarded_grade ;
          g_ext_asg_details(p_assignment_id).tp_sf_spinal_point_id:= l_cdt_asg_attributes.tp_sf_spinal_point_id ;
          g_ext_asg_details(p_assignment_id).start_date           := l_earliest_start_date ;
          l_inclusion_flag :='Y' ;

        ELSE --(l_candidate_asg.assignment_id  = p_assignment_id)  THEN

          -- Add l_candidate_asg assignment to g_ext_asg_details
          -- and set report_asg flag = 'Y' for this assignment in g_ext_asg_details.
          -- though this flag does not have any significance here.

          l_candidate_asg.tp_safeguarded_grade  := l_cdt_asg_attributes.tp_safeguarded_grade;
          l_candidate_asg.tp_sf_spinal_point_id := l_cdt_asg_attributes.tp_sf_spinal_point_id;
          l_candidate_asg.start_date            := l_earliest_start_date ;
          g_ext_asg_details(l_candidate_asg.assignment_id)            := l_candidate_asg ;
          g_ext_asg_details(l_candidate_asg.assignment_id).report_asg := 'Y' ;

          -- overwirte the details of primary assignment with that of the candidate assignment
          -- coz, these details are to be shown on the reports. else the details of
          -- Primary assignment will be displayed (which actuallly is not a valid assignment)
          -- But, don't set the flag report_asg for Primary assignment to 'Y' (set only details)

          g_ext_asg_details(p_assignment_id)  :=  l_candidate_asg ;
          l_inclusion_flag :='Y' ;

        END IF;  --(l_candidate_asg.assignment_id  = p_assignment_id)  THEN

        -- This number is the total number of rec in the collection,
        -- not the actual numebr to be reported
        -- as now we are adding a few primary asgs also,
        -- even though these are not to be reported

        debug('Number of TP4 teachers :'||
                     fnd_number.number_to_canonical(g_ext_asg_details.COUNT),440);

        l_asg_details := g_ext_asg_details(p_assignment_id) ;

        debug('--ASSIGNMENT_DETAILS  -  FINAL (Primary)--');
        print_debug_asg (l_asg_details) ; --Need to remove later

        IF (l_asg_details.report_asg <> 'Y') THEN  -- There is one more record present...

          l_asg_details := g_ext_asg_details(l_candidate_asg.assignment_id) ;
          debug('--ASSIGNMENT_DETAILS  -  FINAL (Secondary)--');
          print_debug_asg (l_asg_details) ; --Need to remove Later
        END IF ;

      END IF ; --(l_inclusion_flag = 'N' AND (l_candidate_asg.assignment_id = NULL))

    ELSE ---- chk_report_person
      -- this person is being reported by some other process. no need to process here..............
      pqp_gb_t1_pension_extracts.g_nested_level := l_tp1_nested_level; -- l_tp1_nested_level ;
      debug(l_proc_name,450);
      l_inclusion_flag := 'N';
    END IF ; -- chk_report_person

  END IF  ; --  g_criteria_estbs.COUNT = 0.

  debug('Just before return, Inclusion Flag :'||l_inclusion_flag,460);

  -- The following piece of code raises a warning if
  -- there exist more than one lea with the same lea Number within a BG.
  -- the warning is raised for the first valid assignment for a single Run.
  -- the flag for warning is set during the global setting through set_extract_globals.
  IF l_inclusion_flag = 'Y' THEN
    warn_if_multi_lea_exist (p_assignment_id => l_candidate_asg.assignment_id);
  END IF;

  debug('++++++++++++++++++++++++ assignment CHECK IS OVER +++++++++++++++++++++++++++++++');

  debug_exit(l_proc_name);
  RETURN l_inclusion_flag;

EXCEPTION
  WHEN OTHERS THEN
    debug('SQLCODE :'||to_char(SQLCODE));
    debug('SQLERRM :'||SQLERRM);
    debug_exit(' Others in '||l_proc_name
              ,'Y' -- turn trace off
              );
    RAISE;
END chk_tp4_is_teacher_new_starter;

--
--
--

FUNCTION get_header_system_element
--  ( p_trace IN VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2
  IS

    l_proc_name         VARCHAR2(61):= g_proc_name||'get_header_system_element';

  BEGIN

    debug_enter(l_proc_name);

    debug(pqp_gb_tp_pension_extracts.g_header_system_element);

    debug_exit(l_proc_name);
    RETURN pqp_gb_tp_pension_extracts.g_header_system_element;

  END get_header_system_element;
--
--
--
  FUNCTION get_lea_number
--   (p_trace IN VARCHAR2 DEFAULT 'N')
   RETURN VARCHAR2
  IS

    l_proc_name  VARCHAR2(61):= g_proc_name||'get_tp_lea_number';

  BEGIN

    debug_enter(l_proc_name);

    debug(pqp_gb_tp_pension_extracts.g_lea_number);

    debug_exit(l_proc_name);

    RETURN pqp_gb_tp_pension_extracts.g_lea_number;

  EXCEPTION
    WHEN OTHERS THEN
      debug_exit(l_proc_name);
      RAISE;
  END get_lea_number;
--
--
--
  FUNCTION get_estb_number
    (p_assignment_id    IN      NUMBER   -- context -1 for header
--    ,p_trace            IN      VARCHAR2 DEFAULT 'N'
    )RETURN VARCHAR2
  IS

    l_proc_name VARCHAR2(61):= g_proc_name||'get_tp_estb_number';
    l_estb_number VARCHAR2(4);

    l_report_asg        VARCHAR2(1) ;
    l_tp1_nested_level  NUMBER ;
    l_assignment_id     per_all_assignments_f.assignment_id%TYPE;

  BEGIN

    debug_enter(l_proc_name);

    debug('p_assignment_id :'||
      fnd_number.number_to_canonical(p_assignment_id));

    -- Bugfix 3820719 : Added to get the effective sec asg
    --    id if primary is not effective
    IF NVL(p_assignment_id, -1) = -1 THEN
      -- p_assignment_id is -1 when the header record
      -- calls this func thru the FF
      l_assignment_id := p_assignment_id;
    ELSIF (g_extract_type = 'TP1' -- Extract type is Type 1 annual
           OR
           g_extract_type = 'TP1P' -- Extract type is Type 1 periodic
          ) THEN

      -- Chk whether the primary is to be reported
      -- The l_assignment_id OUT var will hv the primary
      -- asg id (=p_assignment_id) if yes, otherwise  it will
      -- hv the secondary asg id that is to be used to get estb number

      l_tp1_nested_level := pqp_gb_t1_pension_extracts.g_nested_level;
      pqp_gb_t1_pension_extracts.g_nested_level := g_nested_level;

      l_report_asg := pqp_gb_t1_pension_extracts.chk_report_assignment
                        (p_assignment_id            => p_assignment_id
                        ,p_secondary_assignment_id  => l_assignment_id -- OUT
                        );

      -- Added this line to fix issue with loggin in Type 1 after this
      -- function has been called
      pqp_gb_t1_pension_extracts.g_nested_level :=  l_tp1_nested_level;

    ELSE
      l_assignment_id := p_assignment_id;
    END IF;

    debug('l_assignment_id :'||
      fnd_number.number_to_canonical(l_assignment_id));

    IF NVL(l_assignment_id,-1) = -1 THEN
      l_estb_number := pqp_gb_tp_pension_extracts.g_estb_number;

    ELSIF pqp_gb_t1_pension_extracts.g_override_ft_asg_id IS NOT NULL THEN
      -- Bugfix 3803760:FTSUPPLY
      -- If override ft asg is set, always use that for estb number
      l_estb_number := g_ext_asg_details(l_assignment_id).estb_number;
    ELSIF (pqp_gb_t1_pension_extracts.g_part_time_asg_count > 1) THEN
      -- Added for bugfix 3641851:ENH6
      --Concurrent Part time employees are to be reported on estb-number = 0953.
      l_estb_number := '0953';
    ELSE
      l_estb_number := g_ext_asg_details(l_assignment_id).estb_number;
    END IF;

    debug_exit(l_proc_name);

    RETURN l_estb_number;

  EXCEPTION
    WHEN OTHERS THEN
      debug(SQLCODE);
      debug(SQLERRM);
      debug_exit('Others In '||l_proc_name);
      RAISE;
  END get_estb_number;
--
--
--
  FUNCTION get_originators_title
   --( p_trace     IN      VARCHAR2 DEFAULT 'N' )
   RETURN VARCHAR2
  IS

    l_proc_name VARCHAR2(61):= g_proc_name||'get_tp_originators_title';

  BEGIN

    debug_enter(l_proc_name);

    debug(pqp_gb_tp_pension_extracts.g_originators_title);

    debug_exit(l_proc_name);

    RETURN pqp_gb_tp_pension_extracts.g_originators_title;

  EXCEPTION
    WHEN OTHERS THEN
      debug_exit(l_proc_name);
      RAISE;
  END get_originators_title;
--
--
--
  FUNCTION get_tp4_employment_category
    (p_assignment_id    IN      NUMBER
--    ,p_trace            IN      VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2
  IS

    l_proc_name         VARCHAR2(61):= g_proc_name||
      'get_tp4_employment_category';

    l_report_asg        VARCHAR2(1) ;
    l_tp1_nested_level  NUMBER ;
    l_assignment_id     per_all_assignments_f.assignment_id%TYPE;

  BEGIN

    debug_enter(l_proc_name);
    IF (g_extract_type = 'TP1' -- Extract type is Type 1 annual
        OR
        g_extract_type = 'TP1P' -- Extract type is Type 1 periodic
       ) THEN

      -- Chk whether the primary is to be reported
      -- The l_assignment_id OUT var will hv the primary
      -- asg id (=p_assignment_id) if yes, otherwise  it will
      -- hv the secondary asg id that is to be used to get employment caetgory

      -- Added this line to fix issue with loggin in Type 1 after this
      -- function has been called
      l_tp1_nested_level := pqp_gb_t1_pension_extracts.g_nested_level; --115.34
      pqp_gb_t1_pension_extracts.g_nested_level := g_nested_level;

      l_report_asg := pqp_gb_t1_pension_extracts.chk_report_assignment
                        (p_assignment_id            => p_assignment_id
                        ,p_secondary_assignment_id  => l_assignment_id -- OUT
                        );

      -- Added this line to fix issue with loggin in Type 1 after this
      -- function has been called
      pqp_gb_t1_pension_extracts.g_nested_level :=  l_tp1_nested_level; --115.34

    ELSE
      l_assignment_id := p_assignment_id;
    END IF;

    -- Bugfix 8407293
    IF (g_extract_type = 'TP4') THEN
      debug('p_assignment_id:'||p_assignment_id,25);
      l_assignment_id :=g_ext_asg_details(p_assignment_id).assignment_id;
      debug('l_assignment_id:'||l_assignment_id,26);
    END IF;

    debug('l_report_asg:'||l_report_asg);
    debug('l_assignment_id:'||l_assignment_id) ;
    debug(g_ext_asg_details(l_assignment_id).ext_emp_cat_cd);

    debug_exit(l_proc_name);

    RETURN g_ext_asg_details(l_assignment_id).ext_emp_cat_cd;

  END get_tp4_employment_category;
--
--
--
  FUNCTION get_qualification_mno
    (p_person_id          IN      NUMBER    -- Person Id
    ,p_memb_type          IN      VARCHAR2  -- Membership Type
    ,p_memb_body_name     IN      VARCHAR2  -- Membership Body Name
    ,p_business_group_id  IN      NUMBER
    ,p_effective_date     IN      DATE
    ) RETURN VARCHAR2
  IS

    l_proc_name          VARCHAR2(61)  := g_proc_name||'get_qualification_mno';

    l_membership_number   per_qualifications.membership_number%type := NULL;
    l_membership_number2  per_qualifications.membership_number%type := NULL;

  BEGIN

    debug_enter(l_proc_name);

    OPEN csr_membership_no
           (p_person_id            => p_person_id
           ,p_business_group_id    => p_business_group_id
           ,p_effective_date       => p_effective_date
           ,p_memb_body_name       => p_memb_body_name
           ,p_memb_type            => p_memb_type
           );
    FETCH csr_membership_no INTO l_membership_number;

    IF csr_membership_no%NOTFOUND THEN

      -- Not Found, set to UNKNOWN
      l_membership_number := 'UNKNOWN';

    ELSE -- Found, look again

      FETCH csr_membership_no INTO l_membership_number2;

      IF csr_membership_no%FOUND THEN

        -- Too many found
        l_membership_number := 'TOOMANY';

      END IF;

    END IF;

    CLOSE csr_membership_no;

    debug_exit(l_proc_name);

    RETURN l_membership_number;

  END get_qualification_mno;
--
--
--
  FUNCTION get_dflex_value
    (p_value              OUT NOCOPY   VARCHAR2               -- return value
    ,p_desc_flex_name     IN    VARCHAR2               -- Desc Flex Name
    ,p_column_name        IN    VARCHAR2               -- Base Table Column Name
    ,p_effective_date     IN    DATE                   -- Default Session date
    ,p_entity_key_name    IN    VARCHAR2               --
    ,p_entity_key_value   IN    VARCHAR2               --
    ,p_busnsgrp_id        IN    NUMBER                 --
    ,p_entity_busnsgrp_yn IN    VARCHAR2               --
    ,p_entity_eff_date_yn IN    VARCHAR2               --
    ) RETURN NUMBER -- Success/Failure Error Return code.
  IS

    l_proc_name          VARCHAR2(61)  := g_proc_name||'get_dflex_value';

    l_return_code           NUMBER:= 0;
    l_entity_key_name       VARCHAR2(32):= LOWER(p_entity_key_name);
    l_entity_key_value      VARCHAR2(4000):= p_entity_key_value;
    l_entity_eff_date_yn    VARCHAR2(1):=
       NVL(SUBSTR(UPPER(p_entity_eff_date_yn),1,1),'N');
    l_entity_busnsgrp_yn    VARCHAR2(1):=
      NVL(SUBSTR(UPPER(p_entity_busnsgrp_yn),1,1),'N');
    l_table_specific_clause VARCHAR2(2000);

    TYPE base_table_ref_csr_typ IS REF CURSOR;
    base_table_csr        base_table_ref_csr_typ;

    l_effective_date_clause VARCHAR2(2000):=
      ' AND TO_DATE('''||TO_CHAR(p_effective_date,'DD-MM-YYYY')||
      ''',''DD-MM-YYYY'')'||
          ' BETWEEN effective_start_date AND effective_end_date ';


    CURSOR csr_fnd_desc_flex IS
    SELECT *
     FROM fnd_descriptive_flexs_vl
     WHERE descriptive_flexfield_name = UPPER(p_desc_flex_name);

     rec_fnd_desc_flex      csr_fnd_desc_flex%ROWTYPE;
  --
  BEGIN

    debug_enter(l_proc_name);

    OPEN  csr_fnd_desc_flex;
    FETCH csr_fnd_desc_flex INTO rec_fnd_desc_flex;

    IF csr_fnd_desc_flex%NOTFOUND THEN

       l_return_code := -2;
       p_value := NVL(p_desc_flex_name,'UNKNOWN');

    ELSE

        l_table_specific_clause :=
          ' FROM '||rec_fnd_desc_flex.APPLICATION_TABLE_NAME||' '||
          ' WHERE '||l_entity_key_name||' = '||l_entity_key_value||
          ' ';

        IF l_entity_eff_date_yn = 'Y' THEN

           l_table_specific_clause := l_table_specific_clause||
           l_effective_date_clause;

        END IF;

        IF l_entity_busnsgrp_yn = 'Y' AND p_busnsgrp_id IS NOT NULL THEN

            l_table_specific_clause := l_table_specific_clause||
              '  AND ( business_group_id = '||TO_CHAR(p_busnsgrp_id) ||
              '      ) ';
        END IF;


        debug('SELECT '||p_column_name);
        debug(l_table_specific_clause);

        OPEN base_table_csr FOR 'SELECT '||p_column_name||
        l_table_specific_clause;
        FETCH base_table_csr INTO p_value;
        CLOSE base_table_csr;

    END IF;

    CLOSE csr_fnd_desc_flex;

    debug_exit(l_proc_name);

    RETURN l_return_code;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       p_value := null;
       RETURN -1;

  END get_dflex_value;
--
--
--
  FUNCTION get_formatted_dfee_refno
    ( p_dfee_refno  IN    VARCHAR2 -- Dfee Ref Number Value
    ) RETURN VARCHAR2
    IS

    l_proc_name          VARCHAR2(61):=
      g_proc_name||'get_formatted_dfee_refno';

    l_value       per_all_assignments_f.ass_attribute1%type;
      --Keep len same as that of l_dfee_refno
    l_num_pos     NUMBER := 0;
    l_sep_pos     NUMBER := -1;
    l_sep_count   NUMBER := 0;
    l_len         NUMBER := 0;
    l_pre         VARCHAR2(2);
    l_post        VARCHAR2(5);
    l_char        VARCHAR2(1);

  BEGIN

    debug_enter(l_proc_name);

    -- Strip the blanks
    l_value := NVL(TRIM(p_dfee_refno),'UNKNOWN');
    l_pre   := '';
    l_post  := '';
    l_len   := length(l_value);
    l_char  := ' ';

    IF l_value = 'UNKNOWN' OR l_value = 'TOOMANY' THEN
      debug_exit(l_proc_name);
      RETURN l_value;
    END IF;

    IF l_len = 0 OR l_len > 8 THEN
      debug_exit(l_proc_name);
      RETURN 'INVALID';
    END IF;

    FOR i in 1 .. l_len
    LOOP

      l_char    := substr(l_value,i,1);
      l_num_pos := instr('0123456789',l_char);

      IF l_num_pos <> 0 THEN
       IF i < 3 THEN
        l_pre := l_pre || l_char;
       ELSE
        l_post := l_post || l_char;
       END IF;
      ELSE
        l_sep_count := l_sep_count + 1;
        l_sep_pos := i;
      END IF;
    END LOOP;

    IF   l_sep_count > 1  -- More than one seperators
      OR (l_sep_pos > -1
          AND l_sep_pos NOT BETWEEN 2 AND 3
         )                -- Seperator found but not in positions 2 OR 3
      OR l_pre IS NULL    -- Part 1 not entered
      OR l_post IS NULL   -- Part 2 not entered
    THEN

      debug_exit(l_proc_name);
      RETURN 'INVALID';

    ELSE

      debug_exit(l_proc_name);
      RETURN LPAD(nvl(l_pre,'0'),2,'0')||LPAD(nvl(l_post,'0'),5,'0');

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      debug_exit(l_proc_name);
      RETURN 'INVALID';
  END get_formatted_dfee_refno;
--
--
--
  FUNCTION get_dfee_reference_number
    (p_assignment_id     IN      NUMBER
--    ,p_trace             IN      VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2
  IS
    l_proc_name          VARCHAR2(61):=
      g_proc_name||'get_tp_dfee_reference_number';
    l_status_code        NUMBER;
    l_asg_start_date     DATE;
    l_person_id          NUMBER;
    l_busnsgrp_id        NUMBER;

-- QA failed due to length 30 increased to 100
-- Max length based on the highest possible length of all its sources
-- PAY_USER_COLUMN_INSTANCES_F VALUE                   VARCHAR2(80)
-- PER_QUALIFICATIONS_V        NAME  NOT NULL          VARCHAR2(100)
-- PER_QUALIFICATIONS_V        PROFESSIONAL_BODY_NAME  VARCHAR2(80)
-- FND_DESCRIPTIVE_FLEXS_VL    DESCRIPTIVE_FLEXFIELD_NAME VARCHAR2(40)
-- ALL_TAB_COLUMNS             COLUMN_NAME             VARCHAR2(30)

    l_attr_location_type        pay_user_column_instances_f.value%type;
       -- Attribute Location Type
    l_flexfield_name            pay_user_column_instances_f.value%type;
       -- Flexfield Name
    l_column_name               pay_user_column_instances_f.value%type;
       -- Flexfield Segment Name

    l_dfee_refno                per_all_assignments_f.ass_attribute1%type;
-- Max length based on the highest possible length of all its sources
-- PER_QUALIFICATIONS_V MEMBERSHIP_NUMBER  VARCHAR2(80)
-- PER_ALL_PEOPLE_F     PER_INFORMATION1   VARCHAR2(150)

  BEGIN

    debug_enter(l_proc_name);

    --  Step 1 Get Asg Date

    l_asg_start_date := g_ext_asg_details(p_assignment_id).start_date;

    --  Step 2 Get the person_id and the business group id
    l_person_id         := g_ext_asg_details(p_assignment_id).person_id;
    l_busnsgrp_id       := g_business_group_id;


    -- Step 3 Get Flexfield Name and the Column Name from the UDTable

      l_attr_location_type := get_extract_udt_info
                                (p_udt_column_name => 'Attribute Location Type'
                                ,p_udt_row_name    => 'DfEE Reference Number'
                                );

      debug('DfEE Attribute Location Type'||l_attr_location_type);
      l_flexfield_name := get_extract_udt_info
                            (p_udt_column_name =>
                              'Attribute Location Qualifier 1'
                            ,p_udt_row_name    => 'DfEE Reference Number'
                            );

      debug('DfEE Attribute Location Qualifier 1'||l_flexfield_name);
      l_column_name := get_extract_udt_info
                         (p_udt_column_name => 'Attribute Location Qualifier 2'
                         ,p_udt_row_name    => 'DfEE Reference Number'
                         );

      debug('DfEE Attribute Location Qualifier 2'||l_column_name);

      IF l_attr_location_type = 'Qualifications' THEN

        -- Step 4  Get DfEE Ref No stored in Qualification Table
        l_dfee_refno := get_qualification_mno
                                (p_person_id            => l_person_id
                                ,p_memb_type            => l_flexfield_name
                                ,p_memb_body_name       => l_column_name
                                ,p_business_group_id    => l_busnsgrp_id
                                ,p_effective_date       => l_asg_start_date
                                );

      ELSE

        IF l_attr_location_type = 'People' THEN

          -- Step 5  Get DfEE Ref No stored in per_people_f Table
          l_status_code := get_dflex_value(l_dfee_refno
                                          ,l_flexfield_name
                                          ,l_column_name
                                          ,l_asg_start_date
                                          ,'PERSON_ID'
                                          ,TO_CHAR(l_person_id)
                                          ,l_busnsgrp_id
                                          ,'Y'
                                          ,'Y'
                                          );

        ELSIF l_attr_location_type = 'Assignments' THEN

          -- Step 6  Get DfEE Ref No stored in per_assignment Table
          l_status_code := get_dflex_value(l_dfee_refno
                                          ,l_flexfield_name
                                          ,l_column_name
                                          ,l_asg_start_date
                                          ,'ASSIGNMENT_ID'
                                          ,TO_CHAR(p_assignment_id)
                                          ,l_busnsgrp_id
                                          ,'Y'
                                          ,'Y'
                                          );
        END IF;
      END IF;

      -- Step 7 ReFormat the Ref No.

      debug(' DfEE before formatting '||l_dfee_refno);

      l_dfee_refno := NVL(TRIM(l_dfee_refno),'UNKNOWN');

      l_dfee_refno := get_formatted_dfee_refno(l_dfee_refno);

      debug(' DfEE after formatting '||l_dfee_refno);

      debug_exit(l_proc_name);

      RETURN l_dfee_refno;

  END get_dfee_reference_number;
--
--
--
  FUNCTION get_tp4_start_date
    (p_assignment_id     IN      NUMBER
--    ,p_trace             IN      VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2
  IS

    l_proc_name VARCHAR2(61):= g_proc_name||'get_tp4_start_date';

  BEGIN

    debug_enter(l_proc_name);
    debug('p_assignment_id: '||p_assignment_id);
    debug('tp4_start_date: '||g_ext_asg_details(p_assignment_id).start_date);

    debug_exit(l_proc_name);

    RETURN
      TO_CHAR(g_ext_asg_details(p_assignment_id).start_date
             ,'DDMMYY');

  END get_tp4_start_date;
--
--
--
  FUNCTION get_flex_segment_value
    (p_entity_name        IN VARCHAR2 -- name of the table holding the values
    ,p_entity_rowid       IN ROWID    -- Row Id
    ,p_segment_col_name   IN VARCHAR2 -- Segment column name
    ) RETURN VARCHAR2
  IS
  -- Type Declarations
    TYPE base_table_ref_csr_typ IS REF CURSOR;

  -- Variable Declarations
    c_base_table        base_table_ref_csr_typ;

    l_query               VARCHAR2(4000); -- Dynamically constructed query
    l_segment_value       per_grade_definitions.segment1%type := NULL;  -- Return value

    l_proc_name VARCHAR2(61):= g_proc_name||'get_flex_segment_value';

  BEGIN

    debug_enter(l_proc_name);

    IF (p_entity_name is not null) AND
       (p_entity_rowid is not null) AND
       (p_segment_col_name is not null) THEN


      l_query :=
        'SELECT '||p_segment_col_name||' '||
        'FROM   '||p_entity_name||' '||
        'WHERE  rowid = :b_rowid ';

      debug('Before opening dynamic query',10);

      OPEN c_base_table FOR l_query USING p_entity_rowid;
      FETCH c_base_table INTO l_segment_value;
      CLOSE c_base_table;

      debug('After precessing dynamic query',20);
    END IF;

    debug_exit(l_proc_name);

    RETURN l_segment_value;

  END get_flex_segment_value;
--
--
--
  FUNCTION get_kflex_value
     (p_context_id         IN NUMBER       -- Context Id
     ,p_flexfield_name     IN VARCHAR2     -- Flexfield Name
     ,p_segment_name       IN VARCHAR2     -- Flexfield Segment Name
     ,p_effective_date     IN DATE         -- Effective Date
     ) RETURN VARCHAR2
  IS
    -- Variable Declarations
    l_segment_col_value   per_grade_definitions.segment1%type;
      -- Keep len same as l_ret_salary_scale
    l_entity_rowid        ROWID;

    l_proc_name VARCHAR2(61):= g_proc_name||'get_kflex_value';

  BEGIN

    debug_enter(l_proc_name);

    OPEN csr_grade_definition_rowid
      (p_context_id
      ,p_effective_date);
    FETCH csr_grade_definition_rowid INTO l_entity_rowid;
    CLOSE csr_grade_definition_rowid;

    debug('After getting rowid',10);

    l_segment_col_value :=
      get_flex_segment_value
        (p_entity_name          => 'PER_GRADE_DEFINITIONS'
        ,p_entity_rowid         => l_entity_rowid
        ,p_segment_col_name     => p_segment_name
        );

    debug_exit(l_proc_name);

    RETURN l_segment_col_value;

  END get_kflex_value;
--
--
--
  FUNCTION chk_grade_format
    ( p_sal_grade         IN    VARCHAR2 -- Salary Grade
    ) RETURN VARCHAR2 -- Return Y if correct format, N otherwise
  IS

  CURSOR chkformat IS
  SELECT 'Y'
    FROM DUAL
   WHERE LENGTH(NVL(p_sal_grade,'x')) <= 3
     AND ASCII( SUBSTR(p_sal_grade,1,1))
           BETWEEN 65 AND 90
     AND TO_NUMBER(SUBSTR(p_sal_grade,2)) <= 99;

    l_proc_name   VARCHAR2(61)  := g_proc_name||'chk_grade_format';
    l_formatvalid VARCHAR2(1) := 'N';

  BEGIN

    debug_enter(l_proc_name);

    BEGIN
      OPEN chkformat;
      FETCH chkformat INTO l_formatvalid;
      CLOSE chkformat;
    EXCEPTION
      WHEN OTHERS THEN
        l_formatvalid := 'N';
    END;

    debug_exit(l_proc_name);

    RETURN l_formatvalid;

  END chk_grade_format;
--
--
--
  FUNCTION get_tp4_salary_scale
    (p_assignment_id    IN      NUMBER
--    ,p_trace            IN      VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2
  IS
    l_proc_name VARCHAR2(61):= g_proc_name||'get_tp4_salary_scale';

    l_teacher_start_date        DATE;         -- Teacher Start Date

-- QA failed due to length 30 increased to 100
-- Max length based on the highest possible length of all its sources
-- PAY_USER_COLUMN_INSTANCES_F VALUE                   VARCHAR2(80)
-- FND_DESCRIPTIVE_FLEXS_VL    DESCRIPTIVE_FLEXFIELD_NAME VARCHAR2(40)
-- ALL_TAB_COLUMNS             COLUMN_NAME             VARCHAR2(30)

    l_flexfield_name            pay_user_column_instances_f.value%type;
      -- Flexfield Name
    l_segment_name              pay_user_column_instances_f.value%type;
      -- Flexfield Segment Name

    l_ret_salary_scale          per_grade_definitions.segment1%type;
      -- Salary Scale Return Value
-- Max length based on the highest of all its sources
-- PER_GRADE_DEFINITIONS SEGMENTn VARCHAR2(60)

    l_assignment_id             per_all_assignments_f.assignment_id%TYPE;
    l_report_asg                VARCHAR2(1);

-- Added for salary scale changes

    l_first_sal_code            VARCHAR2(2);
    l_second_sal_code           VARCHAR2(2);
    l_third_sal_code            VARCHAR2(2);
    l_location_id               NUMBER;
    l_exists                    VARCHAR2(1);
    l_spinal_point              per_spinal_points.spinal_point%TYPE;
    i                           NUMBER;
    l_tp1_nested_level          NUMBER;
    -- RET2.a
    l_count                     NUMBER; --Loop counter
    -- variable to store head teacher group code.
    l_asg_attributes           csr_pqp_asg_attributes_dn%ROWTYPE;
    l_headteacher_grp_code     NUMBER;

  BEGIN
-- The terms Salary Scale and Grade have been used   interchangably

    debug_enter(l_proc_name);

    -- Bugfix 3073562:GAP6
    -- Adding this check to support reporting on secondary asgs in Type 1
    IF (g_extract_type = 'TP1' -- Extract type is Type 1 annual
        OR
        g_extract_type = 'TP1P' -- Extract type is Type 1 periodic
       ) THEN
      debug (l_proc_name, 10);
      -- Chk whether the primary is to be reported
      -- The l_assignment_id OUT var will hv the primary
      -- asg id (=p_assignment_id) if yes, otherwise  it will
      -- hv the secondary asg id that is to be used to get sal scale

      -- Added this line to fix issue with loggin in Type 1 after this
      -- function has been called
      l_tp1_nested_level := pqp_gb_t1_pension_extracts.g_nested_level; --115.34
      pqp_gb_t1_pension_extracts.g_nested_level := g_nested_level;

      l_report_asg := pqp_gb_t1_pension_extracts.chk_report_assignment
                        (p_assignment_id            => p_assignment_id
                        ,p_secondary_assignment_id  => l_assignment_id -- OUT
                        );

      -- Added this line to fix issue with loggin in Type 1 after this
      -- function has been called
      pqp_gb_t1_pension_extracts.g_nested_level :=l_tp1_nested_level; --115.34

    ELSE
      debug (l_proc_name, 20);
      l_assignment_id := p_assignment_id;
    END IF;

    -- Bugfix 8407293
    IF (g_extract_type = 'TP4') THEN
      debug('p_assignment_id:'||p_assignment_id,25);
      l_assignment_id :=g_ext_asg_details(p_assignment_id).assignment_id;
      debug('l_assignment_id:'||l_assignment_id,26);
    END IF;

    -- Set Teachers start date

    l_teacher_start_date := g_ext_asg_details(l_assignment_id).start_date;


    debug ('Assignment ID: '||TO_CHAR(l_assignment_id),30);
    debug ('Start Date: '||TO_CHAR(l_teacher_start_date, 'DD/MM/YYYY'));

    -- Step 1 : Check for the Safeguarded Salary Scale
    IF TRIM(g_ext_asg_details(l_assignment_id).tp_safeguarded_grade)
       IS NOT NULL
    THEN
    -- 1

      debug(l_proc_name,40);

      -- Step 2 : Fetch Sageguarded Grade found in PQP_ASSIGNMENT_ATTRIBUTES_F
      l_ret_salary_scale :=
        g_ext_asg_details(l_assignment_id).tp_safeguarded_grade;

    ELSE -- 1 Salary Scale not found in PQP_ASSIGNMENT_ATTRIBUTES_F

      debug(l_proc_name,50);

      -- Step 3 : Get Flexfield Name and Segment Name from User Table
      l_flexfield_name := get_extract_udt_info
                            (p_udt_column_name =>
                            'Attribute Location Qualifier 1'
                            ,p_udt_row_name    => 'Salary Scale'
                            );
      debug ('l_flexfield_name: '||l_flexfield_name,60);
      l_segment_name := get_extract_udt_info
                          (p_udt_column_name => 'Attribute Location Qualifier 2'
                          ,p_udt_row_name    => 'Salary Scale'
                          );

      debug ('l_segment_name: '||l_segment_name,70);

      -- Step 4 : Get Salary scale from key flexfield
      l_ret_salary_scale := get_kflex_value
                              (p_context_id     => l_assignment_id
                              ,p_flexfield_name => l_flexfield_name
                              ,p_segment_name   => l_segment_name
                              ,p_effective_date => l_teacher_start_date
                              );
      debug ('l_ret_salary_scale: '||l_ret_salary_scale,80);

    END IF; -- 1

    -- Check that the salary grade is of a valid format
    debug(l_proc_name||' :Before Check Format',90);

    IF TRIM(l_ret_salary_scale) IS NULL THEN

      l_ret_salary_scale := 'UNKNOWN';

    ELSIF chk_grade_format(l_ret_salary_scale) = 'N' THEN
      -- Added changes to fetch the salary scale information
      -- based on management and retention allowance information
      debug(l_proc_name,110);

      l_first_sal_code := SUBSTR(l_ret_salary_scale, 1, 1);

      debug('First Sal Code: '||l_first_sal_code,120);

      -- Check whether the first letter matches with Qualified or Post
      -- Threshold Teachers salary scale

      IF l_first_sal_code IN ('W', 'P') THEN

         debug(l_proc_name,130);

         -- Initialize the second and third digit sal code variables
         -- to zero

         l_second_sal_code := '0';
         l_third_sal_code  := '0';

         -- Check whether the salary scale represents the safeguraded one

        IF g_ext_asg_details(l_assignment_id).tp_safeguarded_grade IS NOT NULL
        THEN
              debug(l_proc_name,140);
              l_second_sal_code := '0';
              l_third_sal_code  := '0';

        ELSE -- safeguarded information not provided

           debug(l_proc_name,150);
           -- Get the element entries effective for this assignment
           -- loop through the management allowance element collection first
           i := g_tab_mng_aln_eles.FIRST;
           l_count := 1; -- initialize the lop counter..

           WHILE i IS NOT NULL
           LOOP
             OPEN csr_ele_entry_exists (l_assignment_id
                                       ,g_tab_mng_aln_eles(i).element_type_id
                                       ,l_teacher_start_date
                                       );
             FETCH csr_ele_entry_exists INTO l_exists;
             IF csr_ele_entry_exists%FOUND THEN
                debug('Management Element Type: '||TO_CHAR(i), 160+l_count/100);
                l_second_sal_code
                  := TO_CHAR(g_tab_mng_aln_eles(i).salary_scale_code);
                CLOSE csr_ele_entry_exists;
                EXIT;
             END IF; -- End if of row found check ...
             CLOSE csr_ele_entry_exists;
             i := g_tab_mng_aln_eles.NEXT(i);
             l_count := l_count + 1;
           END LOOP;
           debug(l_proc_name, 170);


           -- TLR :
           -- Third Sal Code reporting
           -- 1) if l_teacher_start_date >= 01-01-2006 -> report TLR code
           -- 2) if l_teacher_start_date < 01-01-2006 -> report Retention code
                -- 2-a) if l_teacher_start_date < 01-04-2004, report 1-5 Retension Code
                -- 2-b) if l_teacher_start_date >= 01-04-2004, report 0/1 Retension Code

           -- This is Step (1)
           IF l_teacher_start_date  >= to_date('01-01-2006','DD-MM-YYYY')
           THEN -- calculate third sal code using TLR g_tab_tlr_aln_eles

             -- loop through the TLR allowance element collection
             i := g_tab_tlr_aln_eles.FIRST;
             l_count := 1; -- initialize the lop counter..

             WHILE i IS NOT NULL
             LOOP
               OPEN csr_ele_entry_exists (l_assignment_id
                                         ,g_tab_tlr_aln_eles(i).element_type_id
                                         ,l_teacher_start_date
                                         );
               FETCH csr_ele_entry_exists INTO l_exists;
               IF csr_ele_entry_exists%FOUND THEN
                  debug('TLR Element Type: '||TO_CHAR(i),180+l_count/100);
                  debug('salary_scale_code : '|| TO_CHAR(g_tab_tlr_aln_eles(i).salary_scale_code));

                  l_third_sal_code
                    := TO_CHAR(g_tab_tlr_aln_eles(i).salary_scale_code);
                  CLOSE csr_ele_entry_exists;
                  EXIT;
               END IF; -- End if of row found check ...
               CLOSE csr_ele_entry_exists;
               i := g_tab_tlr_aln_eles.NEXT(i);
               l_count := l_count + 1;
             END LOOP;

             debug(l_proc_name, 180);

           ELSE -- before 01/jan/2006, calculate third sal code using retention allowance
           -- This is Step (2)

             -- loop through the retention allowance element collection
             i := g_tab_ret_aln_eles.FIRST;
             l_count := 1; -- initialize the lop counter..

             WHILE i IS NOT NULL
             LOOP
               OPEN csr_ele_entry_exists (l_assignment_id
                                         ,g_tab_ret_aln_eles(i).element_type_id
                                         ,l_teacher_start_date
                                         );
               FETCH csr_ele_entry_exists INTO l_exists;
               IF csr_ele_entry_exists%FOUND THEN
                  debug('Retention Element Type: '||TO_CHAR(i),180+l_count/100);
                  debug('salary_scale_code : '|| TO_CHAR(g_tab_ret_aln_eles(i).salary_scale_code));

                  l_third_sal_code
                    := TO_CHAR(g_tab_ret_aln_eles(i).salary_scale_code);
                  CLOSE csr_ele_entry_exists;
                  EXIT;
               END IF; -- End if of row found check ...
               CLOSE csr_ele_entry_exists;
               i := g_tab_ret_aln_eles.NEXT(i);
               l_count := l_count + 1;
             END LOOP;

             debug(l_proc_name, 190);
           END IF; -- l_teacher_start_date  >= to_date('01-01-2006','DD-MM-YYYY')

        END IF; -- End if of safeguarded information specified check ...

        -- RET2.a
        -- Check the g_pension_year_start_date
        -- IF g_pension_year_start_date > = 01-APR-2004 AND Retention Allowance is being paid THEN
        --   Override the value for Retention Allowances code by '1' .
        -- END IF;

        debug('g_pension_year_start_date: '
                 ||to_char(pqp_gb_t1_pension_extracts.g_pension_year_start_date,
                          'DD/MM/YYYY'), 210);
        debug('l_third_sal_code: '||l_third_sal_code);


        -- This is Step 2-a and 2-b.
        -- At this point of time, if l_teacher_start_date > 01-01-2006, then this code is TLR code
        -- If l_teacher_start_date < 01-01-2006, it has retention code, now check if
           -- if >= 01-04-2004, then override
           -- else report retention code

        IF pqp_gb_t1_pension_extracts.g_pension_year_start_date >= to_date('01-04-2004','DD-MM-YYYY')
          AND l_teacher_start_date < to_date('01-01-2006','DD-MM-YYYY') -- => it is TLR code
          AND l_third_sal_code <> '0' THEN
          debug(l_proc_name, 220);
          -- Override the retention allowance code by '1'.
          l_third_sal_code := '1' ;
        END IF;

        debug('Third Sal Code: ' || l_third_sal_code, 230);
        l_ret_salary_scale := l_first_sal_code  ||
                               l_second_sal_code ||
                               l_third_sal_code;

        debug('l_ret_salary_scale: ' || l_ret_salary_scale);

      ELSIF l_first_sal_code = 'H' -- Head Teacher
      THEN
         debug(l_proc_name,240);
         l_second_sal_code := NULL;
         l_location_id     := NULL;

         -- Check whether the salary scale represents the safeguraded one

        IF g_ext_asg_details(l_assignment_id).tp_safeguarded_grade IS NOT NULL
        THEN
              debug(l_proc_name,250);
              l_second_sal_code := '01';

--            -- Get the location id information from the global
--            l_location_id
--              := g_ext_asg_details(p_assignment_id).tp_sg_location_id;

        ELSE -- safeguarded salary information not provided
          debug(l_proc_name,260);

          -- SSC: If a head teacher group code is defined for the teacher
          -- get the salary scale code from the group code.
          -- else get it from the location attached to the assignment

          OPEN csr_pqp_asg_attributes_dn
                        ( p_assignment_id  => p_assignment_id
                         ,p_effective_date => l_teacher_start_date
                        );
          FETCH csr_pqp_asg_attributes_dn INTO l_asg_attributes;

            IF csr_pqp_asg_attributes_dn%FOUND THEN
              debug(l_proc_name,265);
              l_headteacher_grp_code := l_asg_attributes.tp_headteacher_grp_code ;
            END IF ;

          CLOSE csr_pqp_asg_attributes_dn;


          debug('l_headteacher_grp_code: '||to_char(l_headteacher_grp_code), 270) ;

          IF l_headteacher_grp_code IS NOT NULL THEN
		        l_second_sal_code :=   lpad((to_char(l_headteacher_grp_code)),2,'0') ;

          ELSE  -- get teh location from the assignment
            l_location_id  := g_ext_asg_details(l_assignment_id).location_id;

            debug('l_location_id: '||to_char(l_location_id), 275) ;

            IF g_criteria_estbs.EXISTS(l_location_id) THEN

		          debug('school_number: '||g_criteria_estbs(l_location_id).school_number, 280) ;
              l_second_sal_code := TRIM(g_criteria_estbs(l_location_id).school_number);

            END IF; --g_criteria_estbs.EXISTS(l_location_id) THEN

		      END IF; -- l_headteacher_grp_code IS NOT NULL THEN

        END IF; -- End if of safeguarded information provided check ...

        debug('Second Sal Code: ' || l_second_sal_code,310);

        l_ret_salary_scale := l_first_sal_code ||
                               l_second_sal_code;


        debug('l_ret_salary_scale: ' || l_ret_salary_scale,320);

      ELSIF l_first_sal_code = 'A' -- Advanced Skilled Teacher
      THEN
         debug(l_proc_name,330);
         l_second_sal_code := NULL;
         l_spinal_point    := NULL;

         -- Check whether the salary scale represents the safeguraded one

        IF g_ext_asg_details(l_assignment_id).tp_safeguarded_grade IS NOT NULL
        THEN
            debug(l_proc_name,340);
            -- Get the spinal point ID information
            OPEN csr_get_sf_spinal_point
              (g_ext_asg_details(l_assignment_id).tp_sf_spinal_point_id);
            FETCH csr_get_sf_spinal_point INTO l_spinal_point;
            CLOSE csr_get_sf_spinal_point;
        ELSE -- safeguarded information not specified
            debug(l_proc_name,350);
            -- Get spinal point id from per_spinal_points
            OPEN csr_get_spinal_point (l_assignment_id
                                      ,l_teacher_start_date
                                      );
            FETCH csr_get_spinal_point INTO l_spinal_point;
            CLOSE csr_get_spinal_point;

        END IF; -- End if of safeguarded grade specified check ...

        IF l_spinal_point IS NOT NULL THEN
           debug(l_proc_name,360);
           l_second_sal_code := TRIM(TO_CHAR((TO_NUMBER(l_spinal_point) - 1), '09'));


        END IF; -- End if of spinal point not null check ...
        debug('l_second_sal_code: ' || l_second_sal_code,370);

        l_ret_salary_scale := l_first_sal_code ||
                              l_second_sal_code;

        debug('l_ret_salary_scale: ' || l_ret_salary_scale,380);


      END IF; -- End if of first sal code in W or P check ...

      IF chk_grade_format(l_ret_salary_scale) = 'N' THEN
        debug(l_proc_name,390);
        l_ret_salary_scale := 'INVALID';
      END IF;

      debug('Return Salary Scale: '||l_ret_salary_scale,410);

    END IF;

    debug('Return Salary Scale: '||l_ret_salary_scale,420);

    debug_exit(l_proc_name);

    -- Step 5 : Return Salary Scale / Grade value
    RETURN l_ret_salary_scale;

  END get_tp4_salary_scale;
--
--
  --
 FUNCTION get_total_number_data_records
     (p_type            IN      VARCHAR2
--     ,p_trace           IN      VARCHAR2 DEFAULT 'N'
     ) RETURN VARCHAR2
  IS

    l_proc_name VARCHAR2(61):= g_proc_name||'get_total_number_data_records';

    l_ext_rcd_id            ben_ext_rcd.ext_rcd_id%TYPE;

    CURSOR count_extract_details
    (p_ext_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE)
    IS
    SELECT COUNT(*)
      FROM ben_ext_rslt_dtl dtl
          --,ben_ext_rcd      rcd
     WHERE dtl.ext_rslt_id = ben_ext_thread.g_ext_rslt_id
       --AND rcd.ext_rcd_id  = dtl.ext_rcd_id
       --AND rcd.rcd_type_cd = 'D'
       AND dtl.ext_rcd_id = p_ext_rcd_id
       AND DECODE(NVL(TRIM(p_type),hr_api.g_varchar2)
            ,hr_api.g_varchar2,hr_api.g_varchar2
            ,dtl.val_01
            ) = NVL(TRIM(p_type),hr_api.g_varchar2)
       AND dtl.val_01 <> 'DELETE';

    l_count             NUMBER:= 0;
    l_count_099999      VARCHAR2(6):= '000000';

  BEGIN

    debug_enter(l_proc_name);

    -- 11.5.10_CU2: Performance fix :
    -- get the ben_ext_rcd.ext_rcd_id
    -- and use this one for next cursor
    -- This will prevent FTS on the table.

    OPEN pqp_gb_t1_pension_extracts.csr_ext_rcd_id
                            (p_hide_flag       => 'N'
                            ,p_rcd_type_cd     => 'D'
                            );
    FETCH pqp_gb_t1_pension_extracts.csr_ext_rcd_id INTO l_ext_rcd_id;
    CLOSE pqp_gb_t1_pension_extracts.csr_ext_rcd_id ;

    debug('l_ext_rcd_id: '|| l_ext_rcd_id, 10) ;


    OPEN count_extract_details (p_ext_rcd_id => l_ext_rcd_id );
    FETCH count_extract_details INTO l_count;

    debug('l_count: '|| l_count, 10) ;

    IF l_count < 999999 THEN

      l_count_099999 := TRIM(TO_CHAR(l_count,'099999'));

    ELSE

      l_count_099999 := '999999';

    END IF;
    CLOSE count_extract_details;

    debug('l_count: '|| l_count, 20) ;

    debug_exit(l_proc_name);

    RETURN l_count_099999;

  END get_total_number_data_records;

--
-- ----------------------------------------------------------------------------
-- |---------------------< assignment_has_a_starter_event >--------------------|
-- ----------------------------------------------------------------------------
--

FUNCTION assignment_has_a_starter_event
    (p_business_group_id        IN      NUMBER
   -- ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    ,p_pqp_asg_attributes       OUT NOCOPY  csr_pqp_asg_attributes_dn%ROWTYPE
    ,p_asg_details              OUT NOCOPY  csr_asg_details%ROWTYPE
    ,p_teacher_start_date       OUT NOCOPY  DATE
    ) RETURN VARCHAR2                    -- 'Y' or 'N'
IS

     l_inclusion_flag           VARCHAR2(1):='N';
     l_itr                      NUMBER;
     l_location_changed         BOOLEAN:= FALSE;
     l_teacher_start_date       DATE;
     l_no_of_events             NUMBER;
     idx                        NUMBER := 0; --Loop counter
     cntr                       NUMBER := 0; --Loop counter

     l_asg_details              csr_asg_details%ROWTYPE;
     l_prev_asg_details         csr_asg_details%ROWTYPE;
     l_proration_dates          pay_interpreter_pkg.t_proration_dates_table_type;
     l_proration_changes        pay_interpreter_pkg.t_proration_type_table_type;
     l_pqp_asg_attributes       csr_pqp_asg_attributes_dn%ROWTYPE;
     l_last_pqp_asg_attributes  csr_pqp_asg_attributes_dn%ROWTYPE;
     l_pqp_aat                  csr_pqp_asg_attributes_up%ROWTYPE;
     l_event_group_details      csr_event_group_details%ROWTYPE;

     l_proc_name                VARCHAR2(61):=
                    g_proc_name||'assignment_has_a_starter_event';
BEGIN


  debug_enter(l_proc_name) ;

        -- Check if the person is a new gb starter
        -- check teacher flag
        -- at the end of this step we will know the whether
        -- 1. the person became teacher or not and is effective at
        --    any since the last run date
        -- 2. the person start date as a teacher
        -- 3. the person's location details
        --

        -- Update retro status on PPE for this asg
        -- Bug 3015917 : Removed set_pay_proc... call, we now use new style DTI

        -- Now invoke the date track interpreter
        -- Bug 3015917 : New DTI call
  debug('Calling pqp_utilities.get_events', 10);
  debug('p_assignment_id: '||p_assignment_id);
  debug('p_element_entry_id: NULL');
  debug('p_business_group_id: '||p_business_group_id);
  debug('p_process_mode: ENTRY_CREATION_DATE');
  debug('p_event_group_name: PQP_GB_TP_IS_TEACHER');
  debug('p_start_date: '||g_last_effective_date);
  debug('p_end_date: '||g_effective_run_date);

  l_no_of_events := pqp_utilities.get_events
           (p_assignment_id             => p_assignment_id
           ,p_element_entry_id          => NULL
           ,p_business_group_id         => p_business_group_id
           ,p_process_mode              => 'ENTRY_CREATION_DATE'
           ,p_event_group_name          => 'PQP_GB_TP_IS_TEACHER'
           ,p_start_date                => g_last_effective_date
           ,p_end_date                  => g_effective_run_date
           ,t_proration_dates           => l_proration_dates -- OUT
           ,t_proration_change_type     => l_proration_changes -- OUT
            );
  debug('l_no_of_events: '||l_no_of_events, 20);

-- Sample Outputs
--              l_proration_changes
--              C
--              I
--              U
--              C
--              C
----              U
--              l_proration_dates6
--              19-DEC-01
--              19-DEC-01
--              20-DEC-01
--              25-DEC-01
--              30-DEC-01
--              30-DEC-01


  -- Now search in the marked events for change in teacher job status
  -- that caused the asg to "become" a teacher
  -- ie search for a change from NULL/NONT to TCHR

  debug('Number of IS_TEACHER Events: '||
      fnd_number.number_to_canonical(l_proration_dates.COUNT),30);
  debug('Number of t_proration_change_type: '||
      fnd_number.number_to_canonical(l_proration_changes.COUNT),40);

  l_itr := l_proration_dates.FIRST;
  debug('l_itr: '||l_itr, 50);
  WHILE l_itr <= l_proration_dates.LAST
  LOOP
    --
    idx := idx + 1 ;   --Loop Counter
    debug('l_itr: '||l_itr, 60 + idx/100000);

    IF l_itr = l_proration_dates.FIRST -- eliminate duplicate dates
       OR
      ( l_proration_dates(l_itr) <>
          l_proration_dates(l_proration_dates.PRIOR(l_itr))
      )
    THEN
      -- Fetch the effective set of attributes
      debug('inside Eliminate duplicate Dates...', 70);
      debug('Open Cursor csr_pqp_asg_attributes_dn, l_proration_dates(l_itr):'||l_proration_dates(l_itr), 80);

      OPEN csr_pqp_asg_attributes_dn
          (p_assignment_id
          ,l_proration_dates(l_itr)
          );
      FETCH csr_pqp_asg_attributes_dn INTO l_pqp_asg_attributes;
      IF csr_pqp_asg_attributes_dn%FOUND
         AND l_pqp_asg_attributes.tp_is_teacher = 'TCHR'
      THEN
        -- Fetch the previous set of attributes
        debug('Assignment Attributes Details ', 90) ;
        print_debug_asg_atr (l_pqp_asg_attributes);

        FETCH csr_pqp_asg_attributes_dn INTO l_last_pqp_asg_attributes;
          IF csr_pqp_asg_attributes_dn%NOTFOUND -- Insert
            OR
             l_last_pqp_asg_attributes.tp_is_teacher = 'NONT' -- Update
          THEN
          --
            debug('This assignment HAS become a teacher.', 110);
            print_debug_asg_atr (l_last_pqp_asg_attributes);

            l_inclusion_flag     := 'Y';
            l_location_changed   := FALSE;
            l_teacher_start_date := l_pqp_asg_attributes.effective_start_date;

            OPEN csr_asg_details
             (p_assignment_id
             ,l_teacher_start_date
             );
            FETCH csr_asg_details INTO l_asg_details;
              debug('l_asg_details.person_id: '||l_asg_details.person_id,120);
              print_debug_asg (l_asg_details) ;

              l_asg_details.ext_emp_cat_cd
                      := get_translate_asg_emp_cat_code
                         (l_asg_details.asg_emp_cat_cd
                         ,l_teacher_start_date);

                  debug('After translation : l_asg_details.ext_emp_cat_cd: '||l_asg_details.ext_emp_cat_cd,130);
            CLOSE csr_asg_details;
          CLOSE csr_pqp_asg_attributes_dn;
          EXIT; -- quit loop -- no need to search for other events
          --
          END IF; --csr_pqp_asg_attributes_dn%NOTFOUND
        --
        END IF;  --csr_pqp_asg_attributes_dn%FOUND
                 --   AND l_pqp_asg_attributes.tp_is_teacher = 'TCHR'
        CLOSE csr_pqp_asg_attributes_dn;
      --
      END IF; -- l_itr = l_proration_dates.FIRST
      l_itr := l_proration_dates.NEXT(l_itr);
      debug('at the end of loop : l_itr: '||l_itr, 140 + idx/100000);
    --
    END LOOP;

    l_proration_dates.DELETE;
    l_proration_changes.DELETE;

    -- Unmark events back to unprocessed
    -- Bug 3015917 : Removed set_pay_proc... call, we now use new style DTI

    debug('l_inclusion_flag: '||l_inclusion_flag, 150 );
    --debug('g_criteria_estbs.EXISTS(l_asg_details.location_id):'||g_criteria_estbs.EXISTS(l_asg_details.location_id), 1700 );

    IF  l_inclusion_flag = 'N'
    -- AND g_estb_number <> '0000' -- MAYBE Reference Allan McMorland.
    -- ie the person is NOT eligibe by virtue of "becoming" a teacher
    OR
    (
      -- This assignment HAS become a Teacher
      l_inclusion_flag = 'Y'

      AND

      -- But, the location is not the same as the one we are reporting for.
      -- In this case, look for location changes within the run date range
      -- PS : If we donot do this check, later on when we check whether the
      -- location (for the assignment details found during Teacher check)
      -- is a criteria establishment, it will be rejected as NOT being a
      -- criteria establishment.
      NOT g_criteria_estbs.EXISTS(l_asg_details.location_id)
    )
    THEN
    -- serach for change in location as of that day
    -- but for that he must first have been a teacher from the
    -- effective in the extract run period.

      debug('This assignment has NOT become a teacher.', 160);
      idx  := 0  ;  --Loop counter
      OPEN csr_pqp_asg_attributes_up
        (p_assignment_id
        ,g_last_effective_date
        );
      LOOP
        idx := idx +1;
        debug('inside LOOP pqp_asg_attributes ', 170+idx/100000);
        FETCH csr_pqp_asg_attributes_up INTO l_pqp_asg_attributes;

          IF csr_pqp_asg_attributes_up%FOUND THEN
           debug('l_pqp_asg_attributes.effective_start_date: '||l_pqp_asg_attributes.effective_start_date, 180);
           debug('l_pqp_asg_attributes.effective_end_date: '||l_pqp_asg_attributes.effective_end_date);
           debug('l_pqp_asg_attributes.tp_is_teacher: '||l_pqp_asg_attributes.tp_is_teacher);
           debug('l_pqp_asg_attributes.creation_date: '||l_pqp_asg_attributes.creation_date);
               END IF;


         IF csr_pqp_asg_attributes_up%NOTFOUND
           OR
            l_pqp_asg_attributes.effective_start_date > g_effective_run_date
         THEN
           debug('EXITING From Loop', 190);
           EXIT;

         END IF; -- if pqp asg not found or pqp asg started after run date

         IF l_pqp_asg_attributes.tp_is_teacher IN ('TCHR','TTR6')

           AND -- the assignment was created before effective date
               -- needed to allow that in reruns we do not see
               -- records which were not created then

            l_pqp_asg_attributes.creation_date < g_effective_date

         THEN

           l_proration_dates.DELETE;
           l_proration_changes.DELETE;

           -- Now invoke the date track interpreter
           -- Bug 3015917 : Removed set_pay_proc.. call, now using new style DTI

           l_no_of_events := 0;
           debug('Calling pqp_utilities.get_events', 210);
           debug('p_assignment_id: '||p_assignment_id);
           debug('p_element_entry_id: NULL');
           debug('p_business_group_id: '||p_business_group_id);
           debug('p_process_mode: ENTRY_CREATION_DATE');
           debug('p_event_group_name: PQP_GB_TP_IS_TEACHER');
           debug('p_start_date: '||g_last_effective_date);
           debug('p_end_date: '||g_effective_run_date);

           l_no_of_events :=
           pqp_utilities.get_events
               (p_assignment_id             => p_assignment_id
               ,p_element_entry_id          => NULL
               ,p_business_group_id         => p_business_group_id
               ,p_process_mode              => 'ENTRY_CREATION_DATE'
               ,p_event_group_name          => 'PQP_GB_TP_ASG_LOCATION'
               ,p_start_date                => GREATEST(l_pqp_asg_attributes.effective_start_date
                                                       ,g_last_effective_date)
               ,p_end_date                  => LEAST(l_pqp_asg_attributes.effective_end_date
                                                    ,g_effective_run_date)
               ,t_proration_dates           => l_proration_dates -- OUT
               ,t_proration_change_type     => l_proration_changes -- OUT
               );

           debug('Number of ASG_LOCATION Events: '||fnd_number.number_to_canonical(l_proration_dates.COUNT),220);
           debug('Number of Prorotaion Changes: '||fnd_number.number_to_canonical(l_proration_changes.COUNT));
           debug('l_no_of_events: '||l_no_of_events);

           cntr := 0;   --Loop Counter
           l_itr := l_proration_dates.FIRST;
           debug('l_itr: '||l_itr, 230);
           WHILE l_itr <= l_proration_dates.LAST
           LOOP
                   cntr := cntr + 1 ;   --Loop Counter
             debug('l_itr: '||l_itr, 240 + cntr/100000);

             -- a location change event did take place, correction or update
             -- loop thru all the dates
             -- and query asg for location value
             -- check if location is a criteria location
             -- if so flag location changed and store teacher start date
             -- and exit else continue

            --
            -- eliminate duplicate dates
                  -- compare the last value to the current one
                  -- always process the first date
             IF l_itr = l_proration_dates.FIRST
                OR
                 ( l_proration_dates(l_itr) <>
                   l_proration_dates(l_proration_dates.PRIOR(l_itr))
                 )
             THEN

               OPEN csr_asg_details
                  (p_assignment_id
                  ,l_proration_dates(l_itr)
                  );
               FETCH csr_asg_details INTO l_asg_details;
          --
          --                                              Loc Change
          --                                              Effective 3
          --                               Loc Change     |
          --             Loc Change        Effective 2    |
          ---            Effective 1       |              |
          --             |                 |              |
          -----ASG-------|<-------------|--|------------->|------->
          --                            |
          --                            |
          -----PQP--------N----------|--|---Y---|----|--N---------->
          --                    |    |  |            |
          --                    |    |  |            |
          --                    |    |  Loc Change   |
          --                    |    |  Actual       |
          --                    |    |               |
          --                    |    TCHR            |
          --                    |    Effective       |
          --                    |                    |
          --                    |                    |
          --                    |                    |
          --                    Last                 This
          --                    Run                  Run
          --
          --

                 IF  csr_asg_details%FOUND

                     -- the location is a criteria location
                 AND

                   g_criteria_estbs.EXISTS(l_asg_details.location_id)

                 AND -- the location should have started before the TCHR ended

                   l_asg_details.start_date
                     <= l_pqp_asg_attributes.effective_end_date

                 AND -- the location should have ended after the TCHR started

                   l_asg_details.effective_end_date
                     >= l_pqp_asg_attributes.effective_start_date

                 THEN


                  -- need to check if it was an establishment number change
                  -- from the last period

                    debug('This assignment has HAD a change in location.', 250);

                  -- fetch the previous asg history row
                  -- to see if its a valid

                    FETCH csr_asg_details INTO l_prev_asg_details;
                      IF (csr_asg_details%NOTFOUND -- correction of first asg row

                      AND
                      (
                        -- For an existing Teacher (TCHR)
                        l_pqp_asg_attributes.tp_is_teacher = 'TCHR'

                        OR

                        (-- The assignment is a new Teacher and has a TR6 raised
                         l_pqp_asg_attributes.tp_is_teacher = 'TTR6'

                         AND

                         -- IF the location started on the same day as the
                         -- assignment became a TTR6 Teacher, we DON'T report this.
                         -- We only report a location change if it happened
                         -- on a date later than the assignment became a TR6 Teacher.
                         l_asg_details.start_date
                          > l_pqp_asg_attributes.effective_start_date
                        )

                      )
                     )

                    OR -- changed from a non estb or a non criteria estb

                    (
                     csr_asg_details%FOUND

                     AND

                     NOT g_criteria_estbs.EXISTS(l_prev_asg_details.location_id)
                    )

                    OR -- changed from another criteria estb and has a diff number

                   (csr_asg_details%FOUND

                     AND

                    g_criteria_estbs.EXISTS(l_prev_asg_details.location_id )

                    AND

                    g_criteria_estbs(l_asg_details.location_id).estb_number <>
                       g_criteria_estbs(l_prev_asg_details.location_id).estb_number

                    AND -- ignore change for estbs reporting thru the same LEA
                        -- note we do not explicilt check for "same LEA"
                        -- since that is guranteed by locations being in the
                        -- same business group, we check for a change in
                        -- the reporting thru lea yes-no flag
                        -- change between two independent establishments
                        -- is an acceptable change of establishments

                    (g_criteria_estbs(l_asg_details.location_id).lea_estb_yn <>
                        g_criteria_estbs(l_prev_asg_details.location_id).lea_estb_yn

                    OR

                     (g_criteria_estbs(l_asg_details.location_id).lea_estb_yn
                         = 'N'

                     AND

                     g_criteria_estbs(l_asg_details.location_id).lea_estb_yn
                         = g_criteria_estbs(l_prev_asg_details.location_id).lea_estb_yn

                     ) -- or change of ind schools,lea_yn is N, ie N->N change

                    ) -- "reporting thru lea" is diff (ie Y->N or N->Y)

                   ) -- estb exists and estb numbers are diff and
                   THEN

                     debug('This assignment has HAD a change in establishment.',260);

                     l_location_changed := TRUE;

                     l_inclusion_flag := 'Y';

                     l_teacher_start_date :=
                      GREATEST -- of location start or teacher start
                       (l_asg_details.start_date
                       ,l_pqp_asg_attributes.effective_start_date
                       );
                     debug('l_teacher_start_date: '||l_teacher_start_date,270);

                    CLOSE csr_asg_details;
                    EXIT; -- the asg details loop

                  END IF; -- if the location change is a estb change also

                END IF; -- if location change is valid
                CLOSE csr_asg_details;

            END IF; -- if this date <> last date to eliminate duplicates
            l_itr := l_proration_dates.NEXT(l_itr);
            debug('l_itr: '||l_itr,280);
          --
          END LOOP; -- location change proration dates

          l_proration_dates.DELETE;
          l_proration_changes.DELETE;

         -- AUTONOMOUS TRANSACTION
         -- Unmark events to unprocessed
         -- Bug 3015917 : Removed set_pay_proc... as we now use new style DTI

         END IF; -- if pqp asg is a tchr and was created before effective date


         IF l_pqp_asg_attributes.effective_end_date > g_effective_run_date

           OR  -- or a valid location change has been found
               -- we only report the first location change in that period

            l_location_changed = TRUE

         THEN

           EXIT; -- the pqp asg loop

         END IF; -- if this was the last pqp asg effective in the run period


       END LOOP; -- pqp asg attributes
       CLOSE csr_pqp_asg_attributes_up;

--  ELSE -- FYI Only
    -- person has a new teacher event so no need to check for location changes

    END IF; -- l_incl = N ie person did not "become" a new teacher


    IF l_inclusion_flag = 'Y' THEN

-- yes person has become a teacher or a exitsing teacher has changed locations
-- but we do not know if the persons location is one of the criteria ones
-- so by default exclude the person
-- note this check is redundant for existing teachers who have had a location
-- change since we have allready checked that the location is one of the
-- criteria estbs
--

       l_inclusion_flag := 'N';

       debug('Checking asg details for criteria establishment match.',290);
       debug('location_id: '||l_asg_details.location_id);


--       IF location_changed -- requery pqp asg to get attribs as of tchr start
--       THEN
--         OPEN csr_pqp_asg_attributes_up
--          (p_assigment_id
--          ,
--
--       END IF;

       -- check to see if he belongs to one of the criteria establsihments

      IF g_criteria_estbs.EXISTS(l_asg_details.location_id) THEN

        debug('This assignment HAS a valid criteria estbalishment.');
        debug('Estb type: '||g_criteria_estbs(l_asg_details.location_id).estb_type, 310);
        -- The persons location is one of the criteria estb
        -- Now evaluate criteria specific to the estb type
        -- of the assignments criteria
        -- NOTE the default is to exclude the person
        -- so we only evaluate inclusion criteria for each estb type

        IF g_criteria_estbs(l_asg_details.location_id).estb_type = 'LEA_ESTB'
        THEN

          l_inclusion_flag := 'Y';

        ELSIF g_criteria_estbs(l_asg_details.location_id).estb_type = 'HGR_ESTB'
        THEN

          debug('Checking employment category code for HGR_ESTBs.');
          debug('l_asg_details.ext_emp_cat_cd: '||l_asg_details.ext_emp_cat_cd, 320);
          IF l_asg_details.ext_emp_cat_cd = 'P' THEN

            -- include part-timers only if pension elected

            debug('Checking pension elected for part timers in HGR_ESTBs.');
            debug('tp_elected_pension: '||l_pqp_asg_attributes.tp_elected_pension, 330);

            IF l_pqp_asg_attributes.tp_elected_pension = 'Y' THEN
              l_inclusion_flag := 'Y';
            END IF;

          ELSE
            -- include all full-timers
            l_inclusion_flag := 'Y';

          END IF;
        ELSIF g_criteria_estbs(l_asg_details.location_id).estb_type = 'IND_ESTB'
        THEN

          -- regardless of employment category inlcude only if pension elected
          debug('Checking pension elected in IND_ESTBs.');
          debug('tp_elected_pension: '||l_pqp_asg_attributes.tp_elected_pension, 340);

            IF l_pqp_asg_attributes.tp_elected_pension = 'Y' THEN
               l_inclusion_flag := 'Y';
            ELSE
              -- Bugfix(Enhancement ) : 2264062
              -- Added this ELSE part has a bugix enhancement
                -- Requirement : The start date for a new appointment at a
                -- 'Voluntary' establishment should be the date the teacher
                -- joined the pension scheme (this is currently set as the
                -- date the teacher joined the voluntary establishment).

              -- Find assignment attributes between Teacher start date
              -- and g_effective_run_date where the elected pension flag
              -- has become Y.
              debug('Checking if the flag became Y during the reporting period.', 350);

              OPEN csr_pqp_asg_attributes_up
               (p_assignment_id
               ,l_teacher_start_date
               );

              LOOP
                --
                FETCH csr_pqp_asg_attributes_up INTO l_pqp_aat;
                --
                IF csr_pqp_asg_attributes_up%NOTFOUND
                   OR
                   l_pqp_asg_attributes.effective_start_date > g_effective_run_date THEN

                  EXIT;

                ELSIF l_pqp_aat.tp_elected_pension = 'Y' -- Has Elected Pension
                      AND
                      -- And flag bcame Y between teacher start date and g_effective_run_date
                      l_pqp_aat.effective_start_date
                        BETWEEN l_teacher_start_date
                            AND g_effective_run_date THEN

                  l_inclusion_flag := 'Y';
                  l_teacher_start_date := GREATEST(l_teacher_start_date
                                                  ,l_pqp_aat.effective_start_date
                                                  );
                  EXIT;
                  --
                END IF;
                --
              END LOOP;
              --
              CLOSE csr_pqp_asg_attributes_up;
              --
            END IF; -- l_pqp_asg_attributes.tp_elected_pension = 'Y' THEN
            --
        ELSE -- No Other Estb Type is acceptable

          l_inclusion_flag := 'N'; --FYI only , exclsuion is default

        END IF;

      --ELSE -- person;s locations does not belong to the critera estbs

      --l_inclusion_flag := 'N';  -- FYI only, exclusion is default.

      END IF;
    ELSE

      debug('This assignment has NOT had a change in establishment.', 360);

    END IF;--if l_incl = Y ie new teacher or existing teacher changed locations

    debug(fnd_number.number_to_canonical(p_assignment_id)||
         ' l_inclusion_flag: '||l_inclusion_flag, 370);

  -- set OUT variables....
  p_asg_details        := l_asg_details;
  p_teacher_start_date := l_teacher_start_date ;
  p_pqp_asg_attributes := l_pqp_asg_attributes ;

  debug_exit(l_proc_name);

  RETURN l_inclusion_flag;


  EXCEPTION
    WHEN OTHERS THEN
      p_pqp_asg_attributes := NULL;
      p_asg_details        := NULL;
      p_teacher_start_date := NULL;
      debug_exit(' Others in '||l_proc_name);
      RAISE;
END assignment_has_a_starter_event ;

-- The procedure checks the flag g_multi_lea_exist
-- to check if there are more than one lea with the same lea numebr in tha same BG.
-- This flag will be set while setting the globals. and for the first valid assignment
-- warning msg will be displayed.
-- Reset the flag as soon as the first warning is raised.

PROCEDURE warn_if_multi_lea_exist (p_assignment_id IN NUMBER)
IS
l_proc_name  VARCHAR2(61):= 'warn_if_multi_lea_exist';
l_error      NUMBER;

BEGIN
    debug_enter(l_proc_name);

   IF g_multi_lea_exist = 'Y' THEN
     -- Raise Warinig here
     --fnd_message.set_name ('BEN', 'BEN_23014_TPA_MANY_LEA');
     --fnd_message.set_token ('TOKEN1',g_lea_number);
     --fnd_message.set_token ('TOKEN2',g_token_org_name);
     --More than one organizations have been set up with the LEA Number <token >.
     --The organization <org name> was used to get the LEA Details for this report.
     l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94006_TPA_MANY_LEA'
                 ,p_error_number  => 94006
                 ,p_token1        => g_lea_number
                 ,p_token2        => g_token_org_name
                 );
      debug ('raised error for many lea orgs:'||l_error);
      g_multi_lea_exist := 'N'; --Reset the warning flag.
    END IF;

  debug_exit(l_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
     debug_exit(' Others in '||l_proc_name);
    RAISE;
END warn_if_multi_lea_exist ;

-- The procedure raises a warning if there is no Location defined for LEA
-- This will set the flag g_warn_no_location to 'N'
-- flag will be set while setting the globals.
-- and for the first assignment only warning msg will be displayed.
-- Reset the flag as soon as the first warning is raised.

PROCEDURE warn_if_no_loc_exist (p_assignment_id IN NUMBER)
IS
l_proc_name  VARCHAR2(61):= 'warn_if_no_loc_exist';
l_error      NUMBER;

BEGIN
    debug_enter(l_proc_name);

   IF g_warn_no_location = 'Y' THEN
     -- Raise Warning here
     --fnd_message.set_name ('PQP', 'PQP_230151_NO_LOC_MAP_ON_LEA');
     --fnd_message.set_token ('TOKEN1',g_lea_number);
     -- These is no Location defined for LEA <Token1>
     l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94007_NO_LOC_MAP_ON_LEA'
                 ,p_error_number  => 94007
                 ,p_token1        => g_lea_number
                 );
      debug ('raised error for no location for LEA:'||l_error);
      g_warn_no_location := 'N'; --reset the warning flag.
    END IF;

  debug_exit(l_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
     debug_exit(' Others in '||l_proc_name);
    RAISE;
END warn_if_no_loc_exist ;

--
--
--

FUNCTION get_prev_tp4_result( p_person_id IN NUMBER )
RETURN DATE
IS
  l_prev_start_date DATE := NULL ;
  l_proc_name  VARCHAR2(61):= 'get_prev_tp4_result';
BEGIN
  debug_enter(l_proc_name);

  OPEN csr_prev_tp4_results (p_person_id);
  FETCH csr_prev_tp4_results INTO l_prev_start_date ;
  CLOSE csr_prev_tp4_results ;

  debug_exit(l_proc_name) ;

  RETURN l_prev_start_date ;
  EXCEPTION
    WHEN OTHERS THEN
     debug_exit(' Others in '||l_proc_name);
    RAISE;
END get_prev_tp4_result ;

--
--
--

-- DEBUG procs ....
PROCEDURE print_debug_asg(p_asg_detail IN csr_asg_details%ROWTYPE)
IS
  l_asg_details csr_asg_details%ROWTYPE ;
BEGIN
      l_asg_details := p_asg_detail ;
      debug('---------ASSIGNMENT_DETAILS---------');
      debug('l_asg_details.person_id:'||l_asg_details.person_id);
      debug('l_asg_details.assignment_id:'||l_asg_details.assignment_id);
      debug('l_asg_details.business_group_id:'||l_asg_details.business_group_id);
      debug('l_asg_details.start_date:'||l_asg_details.start_date);
      debug('l_asg_details.effective_end_date:'||l_asg_details.effective_end_date);
      debug('l_asg_details.creation_date:'||l_asg_details.creation_date);
      debug('l_asg_details.location_id:'||l_asg_details.location_id);
      debug('l_asg_details.asg_emp_cat_cd:'||l_asg_details.asg_emp_cat_cd);
      debug('l_asg_details.ext_emp_cat_cd:'||l_asg_details.ext_emp_cat_cd);
      debug('l_asg_details.estb_number:'||l_asg_details.estb_number);
      debug('l_asg_details.status_type:'||l_asg_details.status_type);
      debug('l_asg_details.leaver_date:'||l_asg_details.leaver_date);
      debug('l_asg_details.restarter_date:'||l_asg_details.restarter_date);
      debug('l_asg_details.report_asg:'||l_asg_details.report_asg);
END print_debug_asg;

--
--
--

PROCEDURE print_debug_asg_atr_up(p_pqp_asg_attributes_up IN pqp_gb_t1_pension_extracts.csr_pqp_asg_attributes_up%ROWTYPE)
IS
  l_pqp_asg_attributes_up pqp_gb_t1_pension_extracts.csr_pqp_asg_attributes_up%ROWTYPE ;
BEGIN
  l_pqp_asg_attributes_up := p_pqp_asg_attributes_up ;
      debug('---------ASSIGNMENT_ATTRIBUTES---------');
      debug('l_pqp_asg_attributes_up.assignment_attribute_id:'||l_pqp_asg_attributes_up.assignment_attribute_id);
      debug('l_pqp_asg_attributes_up.assignment_id:'||l_pqp_asg_attributes_up.assignment_id);
      debug('l_pqp_asg_attributes_up.effective_start_date:'||l_pqp_asg_attributes_up.effective_start_date);
      debug('l_pqp_asg_attributes_up.effective_end_date:'||l_pqp_asg_attributes_up.effective_end_date);
      debug('l_pqp_asg_attributes_up.tp_is_teacher:'||l_pqp_asg_attributes_up.tp_is_teacher);
      debug('l_pqp_asg_attributes_up.tp_safeguarded_grade:'||l_pqp_asg_attributes_up.tp_safeguarded_grade);
      debug('l_pqp_asg_attributes_up.tp_safeguarded_grade_id:'||l_pqp_asg_attributes_up.tp_safeguarded_grade_id);
      debug('l_pqp_asg_attributes_up.tp_safeguarded_rate_type:'||l_pqp_asg_attributes_up.tp_safeguarded_rate_type);
      debug('l_pqp_asg_attributes_up.tp_safeguarded_rate_id:'||l_pqp_asg_attributes_up.tp_safeguarded_rate_id);
      debug('l_pqp_asg_attributes_up.tp_safeguarded_spinal_point_id:'||l_pqp_asg_attributes_up.tp_safeguarded_spinal_point_id);
      debug('l_pqp_asg_attributes_up.tp_fast_track:'||l_pqp_asg_attributes_up.tp_fast_track);
      debug('l_pqp_asg_attributes_up.tp_elected_pension:'||l_pqp_asg_attributes_up.tp_elected_pension);
      debug('l_pqp_asg_attributes_up.creation_date:'||l_pqp_asg_attributes_up.creation_date);
END print_debug_asg_atr_up ;

--
--
--

PROCEDURE print_debug_asg_atr(p_pqp_asg_attributes IN csr_pqp_asg_attributes_dn%ROWTYPE)
IS
  l_pqp_asg_attributes csr_pqp_asg_attributes_dn%ROWTYPE ;
BEGIN
  l_pqp_asg_attributes := p_pqp_asg_attributes ;
      debug('---------ASSIGNMENT_ATTRIBUTES---------');
          debug('l_pqp_asg_attributes.assignment_attribute_id:'||l_pqp_asg_attributes.assignment_attribute_id);
          debug('l_pqp_asg_attributes.assignment_id:'||l_pqp_asg_attributes.assignment_id);
          debug('l_pqp_asg_attributes.effective_start_date:'||l_pqp_asg_attributes.effective_start_date);
          debug('l_pqp_asg_attributes.effective_end_date:'||l_pqp_asg_attributes.effective_end_date);
          debug('l_pqp_asg_attributes.tp_is_teacher:'||l_pqp_asg_attributes.tp_is_teacher);
          --debug('l_pqp_asg_attributes.tp_safeguarded_grade:'||l_pqp_asg_attributes.tp_safeguarded_grade);
          --debug('l_pqp_asg_attributes.tp_safeguarded_grade_id:'||l_pqp_asg_attributes.tp_safeguarded_grade_id);
         -- debug('l_pqp_asg_attributes.tp_safeguarded_rate_type:'||l_pqp_asg_attributes.tp_safeguarded_rate_type);
         -- debug('l_pqp_asg_attributes.tp_safeguarded_rate_id:'||l_pqp_asg_attributes.tp_safeguarded_rate_id);
         -- debug('l_pqp_asg_attributes.tp_safeguarded_spinal_point_id:'||l_pqp_asg_attributes.tp_safeguarded_spinal_point_id);
         -- debug('l_pqp_asg_attributes.tp_fast_track:'||l_pqp_asg_attributes.tp_fast_track);
          debug('l_pqp_asg_attributes.tp_elected_pension:'||l_pqp_asg_attributes.tp_elected_pension);
          debug('l_pqp_asg_attributes.creation_date:'||l_pqp_asg_attributes.creation_date);
END print_debug_asg_atr ;

   FUNCTION get_allow_code_rt_ele_info (p_assignment_id IN NUMBER
                                  ,p_effective_date IN DATE
                                  ,p_table_name     IN VARCHAR2
                                  ,p_row_name       IN VARCHAR2
                                  ,p_column_name    IN VARCHAR2
                                  ,p_tab_aln_eles   IN pqp_gb_t1_pension_extracts.t_allowance_eles
                                  ,p_allowance_code IN VARCHAR2
                                  )
                                  RETURN pqp_gb_t1_pension_extracts.t_allowance_eles
   IS
     --
     l_proc_name          VARCHAR2 (80)
                                  :=    g_proc_name
                                     || 'get_allow_code_rt_ele_info';
     l_proc_step          NUMBER;
     l_return             NUMBER;
     l_user_value         pay_user_column_instances_f.value%TYPE;
     l_error_msg          VARCHAR2(2000);
     l_element_type_id    NUMBER := NULL;
     l_tab_allowance_eles pqp_gb_t1_pension_extracts.t_allowance_eles := p_tab_aln_eles;

     -- RET1.a : new variables to store element_type_extra_info_id
     l_element_type_extra_info_id  pay_element_type_extra_info.element_type_extra_info_id%type ;
     l_retval		 NUMBER;
     l_token     VARCHAR2(80);
     --
   BEGIN
   --
     debug_enter (l_proc_name);

     l_return := pqp_utilities.pqp_gb_get_table_value
                  (p_business_group_id => g_business_group_id
                  ,p_effective_date    => p_effective_date
                  ,p_table_name        => p_table_name
                  ,p_column_name       => p_column_name
                  ,p_row_name          => p_row_name
                  ,p_value             => l_user_value
                  ,p_error_msg         => l_error_msg
                  );
     --
     IF l_return <> -1
     THEN
         --
         IF l_user_value IS NOT NULL THEN

            -- fetch the element type id information
            -- for this rate type the rate type validation
            -- is already added in the UDT so no need to
            -- check for validation again

               debug ('User Value: '
                      || l_user_value, 10);

	          --
            OPEN csr_get_eles_frm_rate (p_effective_date
                                       ,l_user_value
                                       );
            LOOP
              FETCH csr_get_eles_frm_rate INTO l_element_type_id;
              EXIT WHEN csr_get_eles_frm_rate%NOTFOUND;

              l_tab_allowance_eles (l_element_type_id).element_type_id
                := l_element_type_id;
              l_tab_allowance_eles (l_element_type_id).salary_scale_code
                               := p_allowance_code;

              debug ('Element Type ID: '
                         || TO_CHAR(l_element_type_id),40);
            END LOOP; -- End loop of eles from rate cursor...
            CLOSE csr_get_eles_frm_rate;
	          --

	          --
            IF l_tab_allowance_eles.COUNT = 0 THEN

                 debug_exit(l_proc_name);

               -- Raise an error for no element are associated
               -- with this rate type

               l_return := pqp_gb_tp_extract_functions.raise_extract_error
                            (p_business_group_id => g_business_group_id
                            ,p_assignment_id     => p_assignment_id
                            ,p_error_text        =>'BEN_93640_EXT_TP_NO_ELE_FOR_RT'
                            ,p_error_number      => 93640 );

            END IF; -- End if of element type count = 0 check ...
            --
         END IF; -- End if of user value is not null check ...
         --

      ELSE -- Else return = -1 from get table value function

            debug_exit(l_proc_name);

         fnd_message.set_name ('PQP', 'PQP_230661_OSP_DUMMY_MSG');
         fnd_message.set_token ('TOKEN', l_error_msg);
         fnd_message.raise_error;

      END IF; -- End if of return <> -1 check from get table value func...
      --

         debug_exit(l_proc_name);

      RETURN l_tab_allowance_eles;
   --
   END get_allow_code_rt_ele_info;
   --

END pqp_gb_tp_pension_extracts;

/
