--------------------------------------------------------
--  DDL for Package Body PQP_GB_T1_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_T1_PENSION_EXTRACTS" AS
--  /* $Header: pqpgbtp1.pkb 120.22.12010000.16 2010/03/17 07:22:36 dchindar ship $ */
--
-- Exceptions
hr_application_error exception;
pragma exception_init (hr_application_error, -20001);


--
-- Overloaded Debug procedures
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

  l_extract_attributes    pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes%ROWTYPE;
  l_business_group_id     per_all_assignments_f.business_group_id%TYPE;

BEGIN

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

    END IF; -- NVL(p_trace_on,'N') = 'Y'
    --
  END IF; -- if nested level = 0

  g_nested_level :=  g_nested_level + 1;
  debug('Entered: '||NVL(p_proc_name,g_proc_name),g_nested_level*100);

END debug_enter;
--
-- debug_exit
--   The exception handler of top level functions must call debug_ext
--   with p_trace_off = 'Y'
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

END debug_exit;


-- 8iComp Changes: IMORTANT NOTE

-- Removing the definition for Table Of Table datastructure
-- as Oracle 8i does not support this.
-- Later as Oracle 9i becomes the minimum pre requisite for Apps
-- we can move back to this logic
-- till then we will use a common table for keeping Leaver-restarter dates
-- for all the assignmets together.
-- The new solution is not as performant as the older one.

-- The Following function sets the leaver-restarter rows for as assignment
-- in the global collection g_per_asg_leaver_dates
FUNCTION set_g_per_asg_leaver_dates
            ( p_leaver_dates_type IN t_leaver_dates_type
            ) RETURN NUMBER
IS

  l_return     NUMBER;
  l_nxt_count  NUMBER;
  l_itr        NUMBER;
--
  l_proc_name           VARCHAR2(61):=
     g_proc_name||'set_g_per_asg_leaver_dates';

BEGIN
  debug_enter(l_proc_name) ;

  l_nxt_count := g_per_asg_leaver_dates.COUNT;

  debug('g_per_asg_leaver_dates.COUNT: '||g_per_asg_leaver_dates.COUNT, 10);
  debug('p_leaver_dates_type.COUNT: '||p_leaver_dates_type.COUNT);

  IF p_leaver_dates_type.COUNT  > 0 THEN

    debug(l_proc_name, 20);
    FOR l_itr IN p_leaver_dates_type.FIRST..p_leaver_dates_type.LAST
    LOOP
      debug('l_itr: '|| l_itr, 30) ;
      debug('p_leaver_dates_type(l_itr).start_date: '|| p_leaver_dates_type(l_itr).start_date) ;
      debug('p_leaver_dates_type(l_itr).leaver_date: '|| p_leaver_dates_type(l_itr).leaver_date) ;
      debug('p_leaver_dates_type(l_itr).restarter_date: '|| p_leaver_dates_type(l_itr).restarter_date) ;
      debug('p_leaver_dates_type(l_itr).assignment_id: '|| p_leaver_dates_type(l_itr).assignment_id) ;

      l_nxt_count := l_nxt_count + 1 ;
      g_per_asg_leaver_dates(l_nxt_count).start_date    :=  p_leaver_dates_type(l_itr).start_date ;
      g_per_asg_leaver_dates(l_nxt_count).leaver_date   :=  p_leaver_dates_type(l_itr).leaver_date ;
      g_per_asg_leaver_dates(l_nxt_count).restarter_date:=  p_leaver_dates_type(l_itr).restarter_date ;
      g_per_asg_leaver_dates(l_nxt_count).assignment_id :=  p_leaver_dates_type(l_itr).assignment_id ;
      debug('l_nxt_count: '|| l_nxt_count, 40) ;

    END LOOP ;
    debug(l_proc_name, 50);

  END IF ;

  debug_exit(l_proc_name);

  return   l_itr ;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END set_g_per_asg_leaver_dates;

-- 8iComp Changes: IMORTANT NOTE

-- Removing the definition for Table Of Table datastructure
-- as Oracle 8i does not support this.
-- Later as Oracle 9i becomes the minimum pre requisite for Apps
-- we can move back to this logic
-- till then we will use a common table for keeping Leaver-restarter dates
-- for all the assignmets together.
-- The new solution is not as performant as the older one.

-- The Following function get the leaver-restarter rows for an assignment
-- in the global collection g_per_asg_leaver_dates

FUNCTION get_g_per_asg_leaver_dates
            ( p_assignment_id IN NUMBER
             ,p_leaver_dates_type OUT NOCOPY t_leaver_dates_type
            ) RETURN NUMBER
IS
  l_leaver_dates_type t_leaver_dates_type;
  l_counter NUMBER := 0;
  l_found   VARCHAR2(1) := 'N' ;

  l_itr        NUMBER;
--
  l_proc_name           VARCHAR2(61):=
     g_proc_name||'get_g_per_asg_leaver_dates';

BEGIN

  debug_enter(l_proc_name);
  debug ('p_assignment_idT: '||p_assignment_id,10);
  debug ('g_per_asg_leaver_dates.COUNT: '|| g_per_asg_leaver_dates.COUNT);

  IF g_per_asg_leaver_dates.COUNT  > 0 THEN
    debug(l_proc_name,20);

    FOR l_itr IN g_per_asg_leaver_dates.FIRST..g_per_asg_leaver_dates.LAST
    LOOP
    EXIT WHEN ( l_found = 'Y'
                AND g_per_asg_leaver_dates(l_itr).assignment_id <> p_assignment_id ) ;

      debug('assignment_id: '||g_per_asg_leaver_dates(l_itr).assignment_id, 30) ;

      IF (g_per_asg_leaver_dates(l_itr).assignment_id = p_assignment_id) THEN

        debug(l_proc_name, 40) ;
        l_counter := l_counter + 1 ;
        l_found := 'Y';
        l_leaver_dates_type(l_counter).start_date    :=  g_per_asg_leaver_dates(l_itr).start_date ;
        l_leaver_dates_type(l_counter).leaver_date   :=  g_per_asg_leaver_dates(l_itr).leaver_date ;
        l_leaver_dates_type(l_counter).restarter_date:=  g_per_asg_leaver_dates(l_itr).restarter_date ;
        l_leaver_dates_type(l_counter).assignment_id :=  g_per_asg_leaver_dates(l_itr).assignment_id ;
        debug('l_counter: '||l_counter, 50 );
        debug('l_found: '||l_found );

      END IF ;
      debug(l_proc_name, 60);

    END LOOP ;
    debug(l_proc_name, 70);

  END IF ;
    debug(l_proc_name, 80) ;
    p_leaver_dates_type := l_leaver_dates_type;
    debug_exit(l_proc_name);

    return l_counter;
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END get_g_per_asg_leaver_dates;

-- 8iComp Changes: IMORTANT NOTE
-- Changing he following function to use the 8iComp code.
-- Now it does not reference g_asg_leaver_events_table global
-- but references g_per_asg_leaver_dates global
-- and calls get_g_per_asg_leaver_dates to get the
-- collection for Leaver-Restarter dates for an assignment

-- MULT-LR --
FUNCTION chk_effective_asg(p_assignment_id IN  NUMBER
                          ,p_effective_date IN DATE
                           ) RETURN VARCHAR2 IS

l_proc_name      VARCHAR2(60)        := g_proc_name || 'chk_effective_asg';
l_effective      VARCHAR2(1)         := NULL ;
l_current        NUMBER ;
l_start_date     DATE ;
l_leaver_date    DATE ;
l_restarter_date DATE ;

l_returned_count  NUMBER;

l_asg_events     t_leaver_dates_type ;

BEGIN

  debug_enter (l_proc_name) ;

  debug('p_assignment_id         : ' || to_char(p_assignment_id),10) ;
  debug('g_primary_assignment_id : ' || to_char(g_primary_assignment_id)) ;
  debug('p_effective_date        : ' || to_char(p_effective_date)) ;


  -- PERF_ENHANC_3A : Performance Enhancements
  -- check if record corresponding to p_assignment_id is present in the
  -- collection g_asg_recalc_details.
  -- If yes, check for matching start_date of the record and the LOS
  -- if they match, return the value from the record, else compute the
  -- effectiveness of the assignment
  -- This step is to avoid unnecessary checking of assignment status for
  -- a given LOS

  IF (g_asg_recalc_details.EXISTS(p_assignment_id)
      AND
      g_asg_recalc_details(p_assignment_id).eff_start_date = p_effective_date
      ) THEN

    l_effective := g_asg_recalc_details(p_assignment_id).effective_status;

  ELSE -- check effectiveness of assignment


    -- check if there is any Full time asg for the period
    IF g_override_ft_asg_id IS NULL THEN
      debug(l_proc_name, 12);
      --debug('g_asg_leaver_events_table.COUNT: '||g_asg_leaver_events_table.COUNT);
      debug('g_per_asg_leaver_dates.COUNT: '||g_per_asg_leaver_dates.COUNT);

      -- check if leaver-restarter dates have been captured
      --IF g_asg_leaver_events_table.COUNT > 0 THEN

      -- 8iComp
      IF g_per_asg_leaver_dates.COUNT > 0 THEN
        debug(l_proc_name, 15);

        -- Check if the assignment is present in global collection
        -- Primary may be available even if not to be reported.
        -- So check the report flag for primary assignment
        IF ( g_ext_asg_details.EXISTS(p_assignment_id)
           AND
           (   -- Primary Assignment
            ( p_assignment_id = g_primary_assignment_id
              AND
              g_ext_asg_details(p_assignment_id).report_asg = 'Y'
             )
             -- Secondary Assignment
            OR p_assignment_id <> g_primary_assignment_id
           )
         ) THEN
          debug(l_proc_name, 20) ;

          -- 8iComp
          --l_asg_events   := g_asg_leaver_events_table(p_assignment_id);
          l_returned_count :=  get_g_per_asg_leaver_dates
                                  ( p_assignment_id     => p_assignment_id
                                   ,p_leaver_dates_type => l_asg_events
                                   ) ;
          debug('l_returned_count : '|| l_returned_count) ;
          debug(l_proc_name, 25) ;

          debug('l_asg_events.count: '||to_char(l_asg_events.count), 30) ;
          IF l_asg_events.count = 0 THEN
            debug(l_proc_name, 40) ;

            -- check the effective assignment
            -- There is no leaver event for the assignment
            -- else it would have had an entry in the table.
            IF ( p_effective_date
                 BETWEEN g_ext_asg_details(p_assignment_id).start_date
                     AND g_effective_run_date
                ) THEN
              debug(l_proc_name, 50);
              l_effective := 'Y';
            ELSE
              l_effective := 'N' ;
            END IF ;   --p_effective_date BETWEEN start and run_date
          ELSE
            l_current := l_asg_events.FIRST ;
            debug('l_current: '||to_char(l_current), 55) ;

            -- Iterate through the collection
            -- and break out of loop, if the condition is satisfied

            WHILE (l_current <= l_asg_events.LAST
                  AND l_effective IS NULL )
            LOOP
              debug (l_proc_name, 60+l_current/100000) ;

              l_start_date     := l_asg_events(l_current).start_date ;
              l_leaver_date    := l_asg_events(l_current).leaver_date ;
              l_restarter_date := l_asg_events(l_current).restarter_date ;

              debug ('l_start_date     : '||to_char(l_start_date), 70+l_current/100000) ;
              debug ('l_leaver_date    : '||to_char(l_leaver_date) ) ;
              debug ('l_restarter_date : '||to_char(l_restarter_date)) ;

              -- Date is before the Assignment start date
              IF p_effective_date < l_start_date THEN
                debug (l_proc_name, 80 + l_current/100000) ;
                l_effective := 'N' ;
              ELSIF p_effective_date BETWEEN
                    l_start_date AND l_leaver_date THEN
                -- date is between a pair of start and end date.
                -- therefor it is effective.
                debug (l_proc_name, 120 + l_current/100000) ;
                l_effective := 'Y' ;
              ELSIF p_effective_date > l_leaver_date
                    AND l_restarter_date IS NULL THEN
                -- Date is greater than leaver date and there is
                -- no restarter event thereafter
                -- therefor asg is not affective anymore.
                -- not a restarter, so not effective on the date.
                debug (l_proc_name, 130 + l_current/100000) ;
                l_effective := 'N' ;
              ELSIF l_restarter_date IS NOT NULL
                    AND p_effective_date BETWEEN
                        (l_leaver_date + 1)  AND (l_restarter_date - 1) THEN
                --date is between leaver and restarter dates.
                debug (l_proc_name, 165 + l_current/100000) ;
                l_effective := 'N' ;
              ELSIF p_effective_date >= l_restarter_date
                    AND l_asg_events.NEXT(l_current) IS NOT NULL THEN
                -- Date is greater than restarter date and there is
                -- another set of start-leaver date therefor
                -- can not decide for the effectiveness at this point.
                -- Loop thru for the next set of dates.
                debug (l_proc_name, 170 + l_current/100000) ;
                l_current := l_asg_events.NEXT(l_current) ;
                debug('l_current: '||to_char(l_current), 180 + l_current/100000 ) ;
              ELSE   -- p_effective_date > l_restarter_date
                   -- AND l_asg_events.NEXT(l_current) IS NULL

                -- There are no more leaver events for the current restarter event,
                -- and the restarter event exists so the asg is effective through
                -- out the year after the restarter date
                debug (l_proc_name, 190 + l_current/100000) ;
                l_effective := 'Y' ;
              END IF; --l_restarter_date IS NOT NULL

              debug (l_proc_name, 220 + l_current/100000) ;

            END LOOP;
          END IF; --l_current IS NULL or l_current = ''

          debug ('l_effective      : ' ||l_effective, 230) ;
          debug ('l_start_date     : ' ||to_char(l_start_date)) ;
          debug ('l_leaver_date    : '||to_char(l_leaver_date) ) ;
          debug ('l_restarter_date : '||to_char(l_restarter_date)) ;

        ELSE -- g_ext_asg_details.EXISTS(p_assignment_id)
          debug (l_proc_name,240) ;
          l_effective := 'N' ;
        END IF ;
      ELSE --  g_per_asg_leaver_dates.COUNT > 0 THEN
        --debug ('g_asg_leaver_events_table.COUNT is ZERO', 250) ;

        IF (g_ext_asg_details.EXISTS(p_assignment_id)
           AND
           (   -- Primary Assignment
            ( g_primary_assignment_id IS NOT NULL
               AND
               p_assignment_id = g_primary_assignment_id
               AND
               g_ext_asg_details(p_assignment_id).report_asg = 'Y'
              )
               -- Secondary Assignment
             OR
             (
              g_primary_assignment_id IS NOT NULL
              AND
              p_assignment_id <> g_primary_assignment_id
             )
            )
            AND
            (p_effective_date
              BETWEEN nvl(g_ext_asg_details(p_assignment_id).start_date, p_effective_date )
                      AND
                      nvl(g_ext_asg_details(p_assignment_id).leaver_date, g_effective_run_date)
           OR
           (g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL
            AND
            p_effective_date >= g_ext_asg_details(p_assignment_id).restarter_date
           )
          )
         ) THEN

          l_effective := 'Y';
          debug(l_proc_name, 260);

        ELSE  --g_ext_asg_details.EXISTS(p_assignment_id)

          debug(l_proc_name, 290);
          l_effective := 'N';

        END IF;
      END IF ; --  g_per_asg_leaver_dates.COUNT > 0 THEN
    ELSIF g_override_ft_asg_id = p_assignment_id THEN

      l_effective := 'Y';
      debug(l_proc_name, 310);

    ELSE  --g_override_ft_asg_id IS NULL

      debug(l_proc_name, 320);
      l_effective := 'N';

    END IF;  --g_override_ft_asg_id IS NULL

    debug('l_effective: ' || l_effective,330);

    -- PERF_ENHANC_3A : performance enhancement
    -- insert a new row in the collection of records for this assignment_id
    g_asg_recalc_details(p_assignment_id).assignment_id      := p_assignment_id;
    g_asg_recalc_details(p_assignment_id).eff_start_date     := p_effective_date;
    g_asg_recalc_details(p_assignment_id).eff_end_date       := NULL;
    g_asg_recalc_details(p_assignment_id).effective_status   := l_effective;
    g_asg_recalc_details(p_assignment_id).part_time_sal_paid := NULL;
    g_asg_recalc_details(p_assignment_id).full_time_sal_rate := NULL;

  END IF;


    debug_exit(l_proc_name ) ;
    RETURN l_effective ;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END chk_effective_asg ;

--

-- 8iComp Changes: IMORTANT NOTE
-- Changing he following function to use the 8iComp code.
-- Now it does not reference g_asg_leaver_events_table global
-- but references g_per_asg_leaver_dates global
-- and calls get_g_per_asg_leaver_dates to get the
-- collection for Leaver-Restarter dates for an assignment.

PROCEDURE print_events_table IS

l_proc_name      VARCHAR2(60)        := g_proc_name || 'print_events_table';
l_effective      VARCHAR2(1)         := 'N' ;
l_current        NUMBER ;
l_start_date     DATE ;
l_leaver_date    DATE ;
l_restarter_date DATE ;
l_asg_events     t_leaver_dates_type ;
l_asg_events_current  NUMBER ;

BEGIN

  debug_enter (l_proc_name) ;
  debug('g_per_asg_leaver_dates.COUNT: '|| g_per_asg_leaver_dates.COUNT,10);

  IF g_per_asg_leaver_dates.COUNT > 0 THEN
    debug ('asg_id    start_date   leaver_date    restarter_date  ',20) ;

    FOR l_itr IN g_per_asg_leaver_dates.FIRST..g_per_asg_leaver_dates.LAST
    LOOP

      debug(g_per_asg_leaver_dates(l_itr).assignment_id || '   '||g_per_asg_leaver_dates(l_itr).start_date||'    '||
      g_per_asg_leaver_dates(l_itr).leaver_date ||'   '||g_per_asg_leaver_dates(l_itr).restarter_date,30 ) ;

    END LOOP ; -- outer

    debug ('outside loop ' ,210) ;
  ELSE
    debug ('No records to print .....' ) ;
  END IF ;
  debug_exit(l_proc_name ) ;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END print_events_table ;

-- 8iComp Changes: IMORTANT NOTE
-- Changing he following function to use the 8iComp code.
-- Now it does not reference g_asg_leaver_events_table global
-- but references g_per_asg_leaver_dates global
-- and calls get_g_per_asg_leaver_dates to get the
-- collection for Leaver-Restarter dates for an assignment

-- MULT-LR --
FUNCTION get_eff_end_date ( p_assignment_id IN  NUMBER
                            ,p_effective_start_date IN DATE
                            ,p_effective_end_date IN DATE
                            ) RETURN DATE IS

l_proc_name      VARCHAR2(60)        := g_proc_name || 'get_eff_end_date';
l_effective      VARCHAR2(1)         := 'N' ;
l_current        NUMBER ;
l_start_date     DATE ;
l_leaver_date    DATE ;
l_restarter_date DATE ;
l_asg_events     t_leaver_dates_type ;
l_counter        NUMBER ;

l_return_date    DATE := NULL;
l_returned_count  NUMBER;
BEGIN

  debug_enter (l_proc_name) ;

  debug('p_assignment_id         : ' || to_char(p_assignment_id),10) ;
  debug('g_primary_assignment_id : ' || to_char(g_primary_assignment_id)) ;
  debug('p_effective_start_date  : ' || to_char(p_effective_start_date)) ;
  debug('p_effective_end_date    : ' || to_char(p_effective_end_date)) ;

  --debug('g_asg_leaver_events_table.COUNT : '|| g_asg_leaver_events_table.COUNT) ;
  debug('g_per_asg_leaver_dates.COUNT : '|| g_per_asg_leaver_dates.COUNT) ;

  -- 8iComp changes
  --IF g_asg_leaver_events_table.COUNT > 0 THEN
  IF g_per_asg_leaver_dates.COUNT > 0 THEN

         -- Present in global collection ..
         -- Primary may be available even
         -- if not to be reported.
    IF ( g_ext_asg_details.EXISTS(p_assignment_id)
       AND
       (  -- Primary Assignment
        ( p_assignment_id = g_primary_assignment_id
          AND
          g_ext_asg_details(p_assignment_id).report_asg = 'Y'
         )
         -- Secondary Assignment
        OR p_assignment_id <> g_primary_assignment_id
       )
     ) THEN

      -- 8iComp
      -- l_asg_events   := g_asg_leaver_events_table(p_assignment_id);
      l_returned_count :=  get_g_per_asg_leaver_dates
                                ( p_assignment_id     => p_assignment_id
                                 ,p_leaver_dates_type => l_asg_events
                                 ) ;
        debug('l_returned_count : '|| l_returned_count) ;
      debug('l_asg_events.count: '||to_char(l_asg_events.count), 20) ;

      IF l_asg_events.count = 0  THEN
        debug(l_proc_name, 25) ;
        -- There is no leaver event for the assignment.
        -- otherwise, there shud be atleast one row in the table.
        l_return_date := p_effective_end_date ;

      ELSE  --l_asg_events.count = 0
        debug(l_proc_name, 30) ;
        l_current := l_asg_events.FIRST ;
        debug('l_current: '||to_char(l_current), 40) ;

        WHILE (l_current <= l_asg_events.LAST
              AND l_return_date IS NULL )
        LOOP
          debug (l_proc_name, 60+l_current/100000) ;
          l_start_date     := l_asg_events(l_current).start_date ;
          l_leaver_date    := l_asg_events(l_current).leaver_date ;
          l_restarter_date := l_asg_events(l_current).restarter_date ;

          debug ('l_start_date     : '||to_char(l_start_date), 70+l_current/100000) ;
          debug ('l_leaver_date    : '||to_char(l_leaver_date) ) ;
          debug ('l_restarter_date : '||to_char(l_restarter_date)) ;


          IF p_effective_end_date < l_start_date THEN
            debug (l_proc_name, 80 + l_current/100000) ;
            debug('THIS CONDITION SHOULD NOT ARISE.......') ;
            l_return_date  := p_effective_end_date ;

          ELSIF p_effective_end_date BETWEEN
                l_start_date AND l_leaver_date THEN
            -- Period end date is between a pair of start and end date
            debug (l_proc_name, 120 + l_current/100000) ;
            l_return_date  := p_effective_end_date ;

          ELSIF p_effective_end_date > l_leaver_date
                AND l_restarter_date IS NULL THEN
            -- period end date is after asg leaver date
            -- and there is no restarter event
            -- therefor the asg leaver date is the end date.
            debug (l_proc_name, 140 + l_current/100000) ;
            l_return_date  := l_leaver_date ;

          ELSIF l_restarter_date IS NOT NULL
                AND p_effective_end_date BETWEEN
                (l_leaver_date + 1) AND (l_restarter_date - 1) THEN
            -- period end date is between leaver and restarter date.
            debug (l_proc_name, 170 + l_current/100000) ;
            l_return_date := l_leaver_date ;

          ELSIF l_restarter_date IS NOT NULL
                AND p_effective_end_date >= l_restarter_date
                AND l_asg_events.NEXT(l_current) IS NOT NULL THEN
            debug (l_proc_name, 170 + l_current/100000) ;
            l_current := l_asg_events.NEXT(l_current) ;
            debug('l_current: '||to_char(l_current), 180 + l_current/100000 ) ;
          ELSE  -- l_restarter_date IS NOT NULL
                -- AND p_effective_end_date >= l_restarter_date
                -- AND l_asg_events.NEXT(l_current) IS NOT NULL THEN
              debug (l_proc_name, 190 + l_current/100000) ;
              l_return_date := p_effective_end_date ;
          END IF ;

          debug (l_proc_name, 220 + l_current/100000) ;

        END LOOP;
      END IF; --l_asg_events.count = 0

      debug ('l_return_date    : ' ||to_char(l_return_date), 230) ;
      debug ('l_start_date     : ' ||to_char(l_start_date)) ;
      debug ('l_leaver_date    : '||to_char(l_leaver_date) ) ;
      debug ('l_restarter_date : '||to_char(l_restarter_date)) ;

    ELSE -- g_ext_asg_details.EXISTS(p_assignment_id)
      debug (l_proc_name,240) ;
      debug('THIS CONDITION SHOULD NOT ARISE ....') ;
      l_return_date  := p_effective_end_date ;
    END IF ;
  ELSE -- g_per_asg_leaver_dates.COUNT > 0 THEN
    debug ('g_per_asg_leaver_dates.COUNT is ZERO',250) ;

    IF ( g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL
         AND (p_effective_end_date >= g_ext_asg_details(p_assignment_id).restarter_date )
        ) THEN
      debug (l_proc_name,260) ;
      l_return_date := p_effective_end_date ;

    ELSE
      debug (l_proc_name,270) ;
      l_return_date := LEAST(p_effective_end_date
                             ,nvl(g_ext_asg_details(p_assignment_id).leaver_date
                                 ,p_effective_end_date
                                 )
                             );
    END IF ;
  END IF ; -- g_per_asg_leaver_dates.COUNT > 0 THEN
 debug('l_return_date : ' ||to_char(l_return_date) ) ;
 debug_exit(l_proc_name ) ;
 RETURN l_return_date ;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END get_eff_end_date ;


-- 8iComp Changes: IMORTANT NOTE
-- Changing he following function to use the 8iComp code.
-- Now it does not reference g_asg_leaver_events_table global
-- but references g_per_asg_leaver_dates global
-- and calls get_g_per_asg_leaver_dates to get the
-- collection for Leaver-Restarter dates for an assignment
--
-- PER_LVR : New functionto check for the person level lever events.
--
FUNCTION chk_person_leaver
  (p_assignment_id            IN      NUMBER  -- context
   ,p_person_id               IN      NUMBER
  ) RETURN VARCHAR2
IS

  -- Variable Declaration
  l_curr_asg_id         per_all_assignments_f.assignment_id%TYPE;
  l_prev_asg_id         per_all_assignments_f.assignment_id%TYPE;
  l_sec_asg_id          per_all_assignments_f.assignment_id%TYPE;

  l_itr                 NUMBER(3);
  l_next_itr            NUMBER(3);
  l_skip_itr            NUMBER(3) := NULL;
  l_next_of_next_itr    NUMBER(3);
  l_prev_asg_count      NUMBER(3);
  l_inclusion_flag      VARCHAR2(1) := 'N';
  l_reported            VARCHAR2(1) := 'N';

  l_person_leaver_date  DATE ;
  l_person_id           NUMBER;
  -- QAB1: Added to temporarily store g_asg_count Value
  l_asg_count           NUMBER;

  -- Rowtype Variable Declaration
  l_all_sec_asgs        t_sec_asgs_type;

  -- 8iComp
  l_insert_rec          NUMBER;
  l_leaver_assignments  t_leaver_asgs_type;
  l_leaver_yn           boolean;
  i                     NUMBER;



  --l_sec_asg_details   csr_sec_assignments%ROWTYPE := NULL;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'chk_person_leaver';

BEGIN -- chk_person_leaver

  debug_enter(l_proc_name);
  debug('p_assignment_id: '||to_char(p_assignment_id), 10) ;
  debug('p_person_id: '||to_char(p_person_id)) ;

  -- QAB1: Store the value of g_asg_count as
  -- it may get change during the leaver check
  -- we need to restore this value
  -- before returning from the function.
  l_asg_count := g_asg_count ;

  -- Step 0) Reset the global variable, it may contain events for the previous person processed
  --   If events will be stored in this global by the basic criteria, then the following
  --   line will need to be commented out
  --   Also, set the global variable for primary assignment id

  debug('Count in g_asg_events :'||to_char(g_asg_events.COUNT), 20);

  g_primary_leaver_dates.DELETE;
  g_primary_assignment_id := p_assignment_id;

  -- Bugfix 3803760:FTSUPPLY : Resetting override ft asg id
  --  This is needed coz if for the frist line one of
  --  the secondary was FT, then chk_report_assignment
  --  will return N for the primary asg below and
  --  we will not pick up any new line and leaver restarter
  --  events for the primary asg
  g_override_ft_asg_id := NULL;
  g_tab_sec_asgs.DELETE;

  IF chk_report_assignment
       (p_assignment_id            => p_assignment_id
       ,p_secondary_assignment_id  => l_sec_asg_id
       ) = 'Y' THEN


    -- Store all the leaver and restarter dates for the primary asg
    store_leaver_restarter_dates
          (p_assignment_id => p_assignment_id
          );

    -- MULT-LR changes
    -- g_asg_leaver_events_table(p_assignment_id) := g_primary_leaver_dates ;

    --8iComp
    debug('inserting in new collection...', 22);
    l_insert_rec := set_g_per_asg_leaver_dates
                       ( p_leaver_dates_type => g_primary_leaver_dates) ;

    debug('l_insert_rec: '|| l_insert_rec, 24) ;


  ELSE

    -- Bugfix 3880543:REHIRE
    -- Setting the sec asg id as the primary asg
    -- We will treat the sec asg as promary so all
    --  leaver restarter events for this secondary
    --  will b treated as primary leaver restarter events
    g_primary_assignment_id := l_sec_asg_id;

  END IF; -- IF chk_report_assignment

  -- Step 1b) Get secondary assignments
  l_all_sec_asgs := get_all_secondary_asgs
                     (p_primary_assignment_id   => p_assignment_id
                     ,p_effective_date          => g_ext_asg_details(p_assignment_id).teacher_start_date
                     );

  -- Have we found any secondary assignments?
  IF l_all_sec_asgs.COUNT > 0 THEN

    l_curr_asg_id := l_all_sec_asgs.FIRST;

    WHILE l_curr_asg_id IS NOT NULL
    LOOP

      debug('Processing Secondary Asg :'||to_char(l_curr_asg_id),30);

      -- Delete the global for lever restarter dates for secondary asg.
      g_sec_leaver_dates.DELETE;

      -- Store all the leaver and restarter dates for the secondary asg
      store_leaver_restarter_dates
                (p_assignment_id => l_curr_asg_id
                );

      -- MULT-LR changes
      IF l_curr_asg_id = g_primary_assignment_id THEN
        --g_asg_leaver_events_table(l_curr_asg_id) := g_primary_leaver_dates ;

        --8iComp
        debug('inserting in new collection...', 32);
        l_insert_rec := set_g_per_asg_leaver_dates
                       ( p_leaver_dates_type => g_primary_leaver_dates) ;
        debug('l_insert_rec: '|| l_insert_rec, 34) ;

      ELSE
        --g_asg_leaver_events_table(l_curr_asg_id) := g_sec_leaver_dates ;
        --8iComp
        debug('inserting in new collection...', 36);
        l_insert_rec := set_g_per_asg_leaver_dates
                     ( p_leaver_dates_type => g_sec_leaver_dates) ;
        debug('l_insert_rec: '|| l_insert_rec, 38) ;

      END IF;

      -- Assign the current asg id to prev asg id
      -- and reset curr asg id, ready for the next one
      l_prev_asg_id := l_curr_asg_id;
      l_curr_asg_id := NULL;

      -- Get next secondary assignment
      l_curr_asg_id := l_all_sec_asgs.NEXT(l_prev_asg_id);

    END LOOP; -- l_curr_asg_id IS NOT NULL
    --
  END IF; -- l_all_sec_asgs.COUNT > 0 THEN

  -- MULT-LR --
  -- print all the events stored so far.
  -- Print the Events table only if Debug is switched on.
  IF NVL(g_trace,'N') = 'Y' THEN
    print_events_table ();
  END IF;

  -- rest the g_primary_assignment_id
  g_primary_assignment_id := p_assignment_id;

  debug('g_asg_events.COUNT: '||to_char(g_asg_events.COUNT),40) ;

  -- This function is basically used by TP1P report, since we are using this function for TP1 report
  -- till now code for both report is common, following portion will used only by TP1 report
  IF g_extract_type = 'TP1' THEN
      IF g_per_asg_leaver_dates.COUNT > 0 THEN --chk this table has any leaver events for the person
         FOR l_itr IN g_per_asg_leaver_dates.FIRST..g_per_asg_leaver_dates.LAST
           loop
	          debug('Checking asg from g_per_asg_leaver_dates : '||g_per_asg_leaver_dates(l_itr).assignment_id,41) ;
	          if l_leaver_assignments.EXISTS(g_per_asg_leaver_dates(l_itr).assignment_id) then
                     debug('asg already exist in l_leaver_assignments',42) ;
	             NULL;
                   else
		     debug('Storing in l_leaver_assignments ', 43) ;
                  l_leaver_assignments(g_per_asg_leaver_dates(l_itr).assignment_id) := g_per_asg_leaver_dates(l_itr).assignment_id; -- sore leaver asg ids
	         end if;
          end loop;
       end if;

   debug('l_leaver_assignments.count: '||l_leaver_assignments.count,44) ;
   debug('Teacher assignment Count :'||g_teach_asg_count,45) ;

     if g_teach_asg_count = l_leaver_assignments.count THEN -- if all asgs of person have some leaver events
        i := l_leaver_assignments.first;                                                          -- need to chk all asgs for restarter event
        WHILE i IS NOT NULL
         loop
         debug('Checking Asg from l_leaver_assignments : '||l_leaver_assignments(i),46) ;
         l_leaver_yn := FALSE;
         FOR i_itr_1 IN g_per_asg_leaver_dates.FIRST..g_per_asg_leaver_dates.LAST
           LOOP
              IF l_leaver_assignments(i) = g_per_asg_leaver_dates(i_itr_1).assignment_id AND
                 g_per_asg_leaver_dates(i_itr_1).restarter_date IS NULL THEN --for each asgs check coresponding restarter event
                 l_leaver_yn := TRUE;
		 debug(l_leaver_assignments(i)||' Asg is leaver' , 47) ;
              END if;
           END LOOP ; --

       IF NOT l_leaver_yn THEN -- if any asg is not leaver person must be reported , and no need to chk further
          l_inclusion_flag:= 'Y';
          debug(l_leaver_assignments(i)||' Asg is not leaver for this pension Year, person should be reported' , 48);
	  debug('l_inclusion_flag : '||l_inclusion_flag, 49);
          RETURN l_inclusion_flag ;
        END if;
        i:= l_leaver_assignments.NEXT(i);
      END loop;

      debug(' All Asgs are leaver for this person' , 49);
      l_inclusion_flag:= 'N'; -- all asg has leaver events and no corresponding restarter event
   Else
    l_inclusion_flag:= 'Y';   -- not all asg of person has leaver event
    debug(' Not all asgs of this person are leavers ' , 50);
    debug('l_inclusion_flag : '||l_inclusion_flag, 50);
  END IF; --g_ext_asg_details.COUNT = l_leaver_assignments.count

 RETURN l_inclusion_flag ; -- following part of code is for TP1P report hence returning
END IF;

  -- Step 1d) Sort events by Ascending Date if we have found more than 1 events
  IF g_asg_events.COUNT > 1 THEN
    sort_stored_events;
  END IF;

  IF g_asg_events.COUNT > 0 THEN

    -- If the first event is a primary leaver event, then we need
    -- a W on withdrawal conf and
    -- the end date should be set as the event date
    IF (g_asg_count
        +
        nvl(g_asg_events(g_asg_events.FIRST).asg_count_change, 0)
       ) <= 0 THEN

      l_person_leaver_date := g_asg_events(g_asg_events.FIRST).event_date ;

      debug('l_person_leaver_date: '||to_char(l_person_leaver_date),50) ;

      -- changed function with the date parameter.
      l_reported := chk_has_teacher_been_reported
                          ( p_person_id => p_person_id
                           ,p_leaver_date  => l_person_leaver_date
                           );

      debug('l_reported: '||l_reported,60) ;

      IF l_reported = 'N' THEN
        l_inclusion_flag := 'Y' ;
      END IF;
    END IF;

    debug('l_inclusion_flag: '||l_inclusion_flag, 70) ;
    debug('g_latest_start_date: '||to_char(g_latest_start_date)) ;

    IF l_inclusion_flag = 'N' THEN

      -- Process each event in the global collection
      FOR l_itr IN g_asg_events.FIRST..g_asg_events.LAST
      LOOP -- through the sorted stored events

        debug('g_asg_events(l_itr).event_date: '||to_char(g_asg_events(l_itr).event_date),80) ;
        -- check if the event date is before the g_latest_start_date
        -- coz after this date there are no more person leaver events.
        IF (g_asg_events(l_itr).event_date < g_latest_start_date)
        THEN
          l_prev_asg_count := g_asg_count;

          -- Check if this event needs to be skipped
          IF (l_skip_itr IS NULL
              OR
              l_itr <> l_skip_itr
             ) THEN

            g_asg_count := g_asg_count
                           +
                           nvl(g_asg_events(l_itr).asg_count_change
                              , 0);
          END IF;

          -- Eliminate duplicate changes as we will be re-calculating all
          -- data elements that are non-static
          -- Also eliminate the event if its a primary leaver event as
          -- we process these when deciding on withdrawal conf
          -- Now we also skip events if they are set in l_skip_itr
          IF (l_itr = g_asg_events.FIRST -- The event is the first one
              OR -- the date is not the same as previous event date
              g_asg_events(l_itr).event_date <>
               g_asg_events(g_asg_events.PRIOR(l_itr)).event_date
             )
             AND
             (g_asg_count > 0
             )
             AND
             -- Check if this event needs to be skipped
             (l_skip_itr IS NULL
              OR
              l_itr <> l_skip_itr
             ) THEN

            l_next_itr := g_asg_events.NEXT(l_itr);

            --  Bugfix 3880543:REHIRE :
            -- We need to pre-Evaluate the next event
            --  We might want to skip the next event if the
            --  next event date is equal to current event date+1
            --  as it could result in a line with start date
            --  greater than end date. We only want to skip
            --  if the next event will not result in a primary
            --  leaver event, meaning it will not coz g_asg_count
            --  to become zero.
            IF l_next_itr IS NOT NULL
               AND
               ( (g_asg_count
                  +
                  nvl(g_asg_events(l_next_itr).asg_count_change, 0)
                 ) > 0
               )  THEN

              -- The start date greater than end data problem
              -- can only occur in the following situation
              -- If the current event is a (new line) leaver event AND
              -- Next event is NOT a leaver event AND
              -- Next event date is EQUAL to current event date + 1
              IF (INSTR(nvl(g_asg_events(l_itr).event_type,'XX')
                      ,'LEAVER'
                      ) > 0
                 )
                 AND
                 (INSTR(nvl(g_asg_events(l_next_itr).event_type,'XX')
                       ,'LEAVER'
                       ) <= 0
                 )
                 AND
                 ( g_asg_events(l_itr).event_date + 1
                   =
                   g_asg_events(l_next_itr).event_date
                 ) THEN
                 -- We want to skip the next event, Set skip itr
                l_skip_itr := l_next_itr;

                l_prev_asg_count := g_asg_count;

                g_asg_count := g_asg_count
                               +
                               nvl(g_asg_events(l_skip_itr).asg_count_change
                                , 0);

                -- Get next-of-next and treat it as the next event
                l_next_of_next_itr := g_asg_events.NEXT(l_next_itr);
                l_next_itr := l_next_of_next_itr;

              ELSE
                l_skip_itr := NULL;
              END IF;

            ELSE -- Pre-Evaluating

              l_skip_itr := NULL;

            END IF; -- Pre-Evaluating

            -- Now doing the real processing
            IF l_next_itr IS NOT NULL THEN

              -- Also check if the next event is a Primary Leaver event
              IF -- If the next event will cause g_asg_count to become zero
                 ( (g_asg_count
                    +
                    nvl(g_asg_events(l_next_itr).asg_count_change, 0)
                   ) <= 0
                 )   THEN

                l_person_leaver_date := g_asg_events(l_next_itr).event_date ;

                debug('l_person_leaver_date: '||to_char(l_person_leaver_date),90) ;
                -- changed function with the date parameter.
                l_reported := chk_has_teacher_been_reported
                                     ( p_person_id  => p_person_id
                                      ,p_leaver_date => l_person_leaver_date
                                     );
                debug('l_reported: '||l_reported,110) ;

                IF l_reported = 'N' THEN
                  l_inclusion_flag := 'Y' ;
                  EXIT;
                END IF;

              END IF;

            END IF; -- l_next_itr IS NOT NULL THEN

          END IF; -- if this date <> last date to eliminate duplicates and primary leaver

        ELSE
          -- There were no person level leaver events found
          -- that have not been reported earlier.
          -- so set the return value and Exit.
          l_inclusion_flag := 'N' ;
          EXIT ;
        END IF ; -- g_asg_events(l_itr).event_date < g_latest_start_date
        --
      END LOOP; -- through the sorted stored events
    END IF ; -- l_inclusion_flag = 'N' ;
    --
  END IF; -- g_asg_events.COUNT > 0 THEN

  -- QAB1: Restore the value of g_asg_count.
  g_asg_count := l_asg_count ;

  debug('l_inclusion_flag: '||l_inclusion_flag, 120);
  debug_exit(l_proc_name);

  RETURN l_inclusion_flag ;

EXCEPTION
    WHEN OTHERS THEN

      -- Reset the global variable containing events for this person
      g_asg_events.DELETE;
      -- QAB1: reset the global.
      g_asg_count := l_asg_count;

      debug('SQLCODE :'||to_char(SQLCODE), 40);
      debug('SQLERRM :'||SQLERRM, 50);

      debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
      RAISE;
END; -- chk_person_leaver

--
--
Procedure Get_Udt_Data ( p_udt_name       in varchar2
                        ,p_effective_date in date ) Is

Cursor Get_table_id ( c_udt_name in varchar2 ) Is
 select tbls.user_table_id
   from pay_user_tables  tbls
  where tbls.user_table_name = c_udt_name
    and ((business_group_id is null and legislation_code is null)
                      or (legislation_code is not null
                            and legislation_code = 'GB')
                      or (business_group_id is not null
                            and business_group_id = g_business_group_id)
        );

Cursor Get_Col_Name ( c_user_table_id in number ) Is
 Select user_column_id, user_column_name
   from pay_user_columns
  where user_table_id = c_user_table_id
    and ((business_group_id is null and legislation_code is null)
                      or (legislation_code is not null
                            and legislation_code = 'GB')
                      or (business_group_id is not null
                            and business_group_id = g_business_group_id)
        )
  order by user_column_id;

Cursor Get_Row_Name ( c_user_table_id  in number
                     ,c_effective_date in date ) Is
 Select user_row_id, row_low_range_or_name
   from pay_user_rows_f
  where user_table_id = c_user_table_id
    and trunc(c_effective_date) between effective_start_date
                                    and effective_end_date
    and ((business_group_id is null and legislation_code is null)
                      or (legislation_code is not null
                            and legislation_code = 'GB')
                      or (business_group_id is not null
                            and business_group_id = g_business_group_id)
        )
  order by display_sequence;

Cursor Get_Matrix_Value ( c_user_column_id in number
                         ,c_user_row_id    in number ) Is
 Select value, effective_start_date, effective_end_date
   from pay_user_column_instances_f
  where user_column_id = c_user_column_id
    and user_row_id    = c_user_row_id
    and ((business_group_id is null and legislation_code is null)
                      or (legislation_code is not null
                            and legislation_code = 'GB')
                      or (business_group_id is not null
                            and business_group_id = g_business_group_id)
        );

-- Comment this out as this is not needed as a local collection
-- This has been declared in the pkg header as global collection
-- g_udt_rec          t_udt_array;
l_user_column_name pay_user_columns.user_column_name%TYPE;
l_user_row_name    pay_user_rows_f.row_low_range_or_name%TYPE;
l_matrix_value     pay_user_column_instances_f.value%TYPE;
l_user_table_id    pay_user_tables.user_table_id%TYPE;
l_user_column_id   pay_user_columns.user_column_id%TYPE;
l_user_row_id      pay_user_rows_f.user_row_id%TYPE;
l_idx              number;
l_proc_name        varchar2(60) := g_proc_name || 'get_udt_data';

Begin
   debug_enter(l_proc_name);

   Open  Get_table_id ( c_udt_name => p_udt_name);
   Fetch Get_table_id Into l_user_table_id;
   Close Get_table_id;
   l_idx := 1;
   For i in  Get_Col_Name (c_user_table_id => l_user_table_id) Loop
     debug(l_proc_name, 20);
     l_user_column_id   := i.user_column_id;
     l_user_column_name := i.user_column_name;
     For j in Get_Row_Name (c_user_table_id  => l_user_table_id
                           ,c_effective_date => p_effective_date) Loop
       debug(l_proc_name, 30);
       l_user_row_id   := j.user_row_id;
       l_user_row_name := j.row_low_range_or_name;
        For k in Get_Matrix_Value ( c_user_column_id => l_user_column_id
                                   ,c_user_row_id    => l_user_row_id ) Loop
           g_udt_rec(l_idx).column_name  := l_user_column_name;
           g_udt_rec(l_idx).row_name     := l_user_row_name;
           g_udt_rec(l_idx).matrix_value := k.value;
           g_udt_rec(l_idx).start_date   := Trunc(k.effective_start_date);
           g_udt_rec(l_idx).end_date     := Trunc(k.effective_end_date);
           l_idx := l_idx + 1; l_matrix_value := Null;
           debug(l_proc_name, 40);
        End Loop;
        l_user_row_name:=Null;
     End Loop;
   End Loop;

   debug_exit (l_proc_name);

End Get_Udt_Data;
--
Procedure Get_Elements_Frm_UDT
                    (p_assignment_id    IN  NUMBER -- 4336613 : LARP_SPAP_3A : new param
                    ) Is

l_counter     number;
l_proc_name          varchar2(70):= g_proc_name||'Get_Elements_Frm_UDT';

-- 4336613 : LARP_SPAP_3A
l_error            number;

Begin

  debug_enter(l_proc_name);

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ First element details from UDT for London Allowance ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  l_counter :=0;

  -- 4336613 : LARP_SPAP_3A : add this check for all the LARP elements
  -- Only if present in UDT, put values to global (record) variable
  IF ( Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                     ,p_row_name    => 'LARP Inner Allowance'
                     ) IS NOT NULL
      )
  THEN

    l_counter := l_counter + 1;
    g_udt_element_LondAll(l_counter).element_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 1'
                                          ,p_row_name    => 'LARP Inner Allowance'
                                           );

    g_udt_element_LondAll(l_counter).allowance_code := Get_Udt_Value
                                          (p_column_name => 'Allowance Code'
                                          ,p_row_name    => 'LARP Inner Allowance'
                                           );

    g_udt_element_LondAll(l_counter).input_value_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 2'
                                          ,p_row_name    => 'LARP Inner Allowance'
                                           );

    debug('LondonAll Ele Count :'||to_char(g_udt_element_LondAll.COUNT), 20);
  END IF;


  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Second element details from UDT for London Allowance ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  -- 4336613 : LARP_SPAP_3A : add this check for all the LARP elements
  -- Only if present in UDT, put values to global (record) variable
  IF ( Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                     ,p_row_name    => 'LARP Outer Allowance'
                     ) IS NOT NULL
      )
  THEN

    l_counter := l_counter + 1;
    g_udt_element_LondAll(l_counter).allowance_code := Get_Udt_Value
                                          (p_column_name => 'Allowance Code'
                                          ,p_row_name    => 'LARP Outer Allowance'
                                           );
    g_udt_element_LondAll(l_counter).element_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 1'
                                          ,p_row_name    => 'LARP Outer Allowance'
                                           );
    g_udt_element_LondAll(l_counter).input_value_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 2'
                                          ,p_row_name    => 'LARP Outer Allowance'
                                           );
    debug('LondonAll Ele Count :'||to_char(g_udt_element_LondAll.COUNT), 30);
  END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Third element details from UDT for London Allowance ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  -- 4336613 : LARP_SPAP_3A : add this check for all the LARP elements
  -- Only if present in UDT, put values to global (record) variable
  IF ( Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                     ,p_row_name    => 'LARP Fringe Allowance'
                     ) IS NOT NULL
      )
  THEN

    l_counter := l_counter + 1;
    g_udt_element_LondAll(l_counter).allowance_code := Get_Udt_Value
                                          (p_column_name => 'Allowance Code'
                                          ,p_row_name    => 'LARP Fringe Allowance'
                                           );
    g_udt_element_LondAll(l_counter).element_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 1'
                                          ,p_row_name    => 'LARP Fringe Allowance'
                                           );
    g_udt_element_LondAll(l_counter).input_value_name  := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 2'
                                          ,p_row_name    => 'LARP Fringe Allowance'
                                           );
    debug('LondonAll Ele Count :'||to_char(g_udt_element_LondAll.COUNT), 40);
  END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Fourth element details from UDT for London Allowance ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  -- 4336613 : LARP_SPAP_3A : add this check for all the LARP elements
  -- Only if present in UDT, put values to global (record) variable
  IF ( Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                     ,p_row_name    => 'LARP Inner Plus Inner Supplement'
                     ) IS NOT NULL
      )
  THEN

    l_counter := l_counter + 1;
    g_udt_element_LondAll(l_counter).allowance_code := Get_Udt_Value
                                          (p_column_name => 'Allowance Code'
                                          ,p_row_name    => 'LARP Inner Plus Inner Supplement'
                                           );
    g_udt_element_LondAll(l_counter).element_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 1'
                                          ,p_row_name    => 'LARP Inner Plus Inner Supplement'
                                           );
    g_udt_element_LondAll(l_counter).input_value_name  := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 2'
                                          ,p_row_name    => 'LARP Inner Plus Inner Supplement'
                                           );
    debug('LondonAll Ele Count :'||to_char(g_udt_element_LondAll.COUNT), 50);
  END IF;

  -- 4336613 : LARP_SPAP_3A : raise an error if no LARP entried found in the UDT
  IF g_udt_element_LondAll.COUNT = 0 THEN
    debug(' ---------  No LARP entries found in UDT ---------', 55);

    -- 4336613 : LARP_SPAP_3A : new error message for LARP
    l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94227_T1_LARP_ELE_NOTEXIST'
                 ,p_error_number  => 94227
                 );
  END IF;


  --debug('Entering the Special Allowance element from UDT');
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ First element details from UDT for Special Allowance ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  l_counter :=0;

  -- 4336613 : LARP_SPAP_3A : add this check for all the SPAP elements
  -- Only if present in UDT, put values to global (record) variable
  IF ( Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                     ,p_row_name    => 'SPAP Lower Rate'
                     ) IS NOT NULL
      )
  THEN

    l_counter := l_counter + 1;
    g_udt_element_SpcAll(l_counter).allowance_code := Get_Udt_Value
                                          (p_column_name => 'Allowance Code'
                                          ,p_row_name    => 'SPAP Lower Rate'
                                           );
    g_udt_element_SpcAll(l_counter).element_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 1'
                                          ,p_row_name    => 'SPAP Lower Rate'
                                           );
    g_udt_element_SpcAll(l_counter).input_value_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 2'
                                          ,p_row_name    => 'SPAP Lower Rate'
                                           );
    debug('SpcAll Ele Count :'||to_char(g_udt_element_SpcAll.COUNT), 60);
  END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Second element details from UDT for Special Allowance ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  -- 4336613 : LARP_SPAP_3A : add this check for all the SPAP elements
  -- Only if present in UDT, put values to global (record) variable
  IF ( Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                     ,p_row_name    => 'SPAP Higher Rate'
                     ) IS NOT NULL
      )
  THEN

    l_counter := l_counter + 1;
    g_udt_element_SpcAll(l_counter).allowance_code := Get_Udt_Value
                                          (p_column_name => 'Allowance Code'
                                          ,p_row_name    => 'SPAP Higher Rate'
                                           );
    g_udt_element_SpcAll(l_counter).element_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 1'
                                          ,p_row_name    => 'SPAP Higher Rate'
                                           );
    g_udt_element_SpcAll(l_counter).input_value_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 2'
                                          ,p_row_name    => 'SPAP Higher Rate'
                                           );
    debug('SpcAll Ele Count :'||to_char(g_udt_element_SpcAll.COUNT), 70);
  END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Third element details from UDT for Special Allowance ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  -- 4336613 : LARP_SPAP_3A : add this check for all the SPAP elements
  -- Only if present in UDT, put values to global (record) variable
  IF ( Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                     ,p_row_name    => 'SPAP Special Needs Lower Rate'
                     ) IS NOT NULL
      )
  THEN

    l_counter := l_counter + 1;
    g_udt_element_SpcAll(l_counter).allowance_code := Get_Udt_Value
                                          (p_column_name => 'Allowance Code'
                                          ,p_row_name    => 'SPAP Special Needs Lower Rate'
                                          );
    g_udt_element_SpcAll(l_counter).element_name := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 1'
                                          ,p_row_name    => 'SPAP Special Needs Lower Rate'
                                          );
    g_udt_element_SpcAll(l_counter).input_value_name  := Get_Udt_Value
                                          (p_column_name => 'Attribute Location Qualifier 2'
                                          ,p_row_name    => 'SPAP Special Needs Lower Rate'
                                           );
    debug('SpcAll Ele Count :'||to_char(g_udt_element_SpcAll.COUNT), 80);
  END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- ~ Fourth element details from UDT for Special Allowance ~
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  -- 4336613 : LARP_SPAP_3A : add this check for all the SPAP elements
  -- Only if present in UDT, put values to global (record) variable
  IF ( Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                     ,p_row_name    => 'SPAP Special Needs Higher Rate'
                     ) IS NOT NULL
      )
  THEN

  l_counter := l_counter + 1;
  g_udt_element_SpcAll(l_counter).allowance_code := Get_Udt_Value
                                        (p_column_name => 'Allowance Code'
                                        ,p_row_name    => 'SPAP Special Needs Higher Rate'
                                         );
  g_udt_element_SpcAll(l_counter).element_name := Get_Udt_Value
                                        (p_column_name => 'Attribute Location Qualifier 1'
                                        ,p_row_name    => 'SPAP Special Needs Higher Rate'
                                         );
  g_udt_element_SpcAll(l_counter).input_value_name  := Get_Udt_Value
                                        (p_column_name => 'Attribute Location Qualifier 2'
                                        ,p_row_name    => 'SPAP Special Needs Higher Rate'
                                         );
  debug('SpcAll Ele Count :'||to_char(g_udt_element_SpcAll.COUNT), 90);
  END IF;

  -- 4336613 : LARP_SPAP_3A : raise an error if no SPAP entried found in the UDT
  IF g_udt_element_SpcAll.COUNT = 0 THEN
    debug(' ---------  No SPAP entries found in UDT ---------', 95);

    -- 4336613 : LARP_SPAP_3A : new error message for SPAP
    l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94228_T1_SPAP_ELE_NOTEXIST'
                 ,p_error_number  => 94228
                 );
  END IF;


  debug_exit(l_proc_name);

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
End Get_Elements_Frm_UDT;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_pay_bal_id >------------------------------|
-- ----------------------------------------------------------------------------
function get_pay_bal_id
  (p_balance_name      in         varchar2
  ,p_business_group_id in         number
  ,p_legislation_code  OUT NOCOPY VARCHAR2) -- 4336613 : new param added
  return number is
--
  l_proc_name        varchar2(60) := g_proc_name || 'get_pay_bal_id';
  l_bal_type_id      csr_get_pay_bal_id%rowtype;
--
begin

  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 5);
  --
  debug_enter(l_proc_name);

  open csr_get_pay_bal_id
    (c_balance_name      => p_balance_name
    ,c_business_group_id => p_business_group_id);
  fetch csr_get_pay_bal_id into l_bal_type_id;
  IF csr_get_pay_bal_id%NOTFOUND THEN
    debug('Not found', 20);
  END IF;

  close csr_get_pay_bal_id;

  debug_exit(l_proc_name);

  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 15);
  --
  p_legislation_code := l_bal_type_id.legislation_code;

  return l_bal_type_id.balance_type_id;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end get_pay_bal_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_pay_ele_ids_from_bal >---------------------|
-- ----------------------------------------------------------------------------
procedure get_pay_ele_ids_from_bal
  (p_assignment_id        in     number
  ,p_balance_type_id      in     number
  ,p_effective_date       in     date
  ,p_error_text           in     varchar2
  ,p_error_number         in     number
  ,p_business_group_id    in     number
  ,p_tab_ele_ids          out nocopy t_ele_ids_from_bal
  ,p_token                in     varchar2 default null
  ) is
--
  l_proc_name        varchar2(60) := g_proc_name || 'get_pay_ele_ids_from_bal';
  l_ele_ids          csr_get_pay_ele_ids_from_bal%rowtype;
  l_error            number ;
  l_ele_type_id      number ;

--
begin

  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 5);
  --

  debug_enter(l_proc_name);

  debug('p_assignment_id: '||to_char(p_assignment_id),10) ;
  debug('p_balance_type_id: '||to_char(p_balance_type_id)) ;
  debug('p_effective_date: '||to_char(p_effective_date)) ;
  debug('p_error_text: '||p_error_text) ;
  debug('p_error_number: '||to_char(p_error_number)) ;
  debug('p_token: '||p_token) ;


  open csr_get_pay_ele_ids_from_bal
    (c_balance_type_id      => p_balance_type_id
    ,c_effective_date       => p_effective_date
    ,c_business_group_id    => p_business_group_id
    );
  loop

    fetch csr_get_pay_ele_ids_from_bal into l_ele_ids;
    exit when csr_get_pay_ele_ids_from_bal%notfound;
      --
      p_tab_ele_ids(l_ele_ids.element_type_id).element_type_id := l_ele_ids.element_type_id;
      p_tab_ele_ids(l_ele_ids.element_type_id).input_value_id  := l_ele_ids.input_value_id;
      --
      debug(l_proc_name, 20);
  end loop;

  if csr_get_pay_ele_ids_from_bal%rowcount = 0
  and p_error_text IS NOT NULL -- don't raise an error, as in OSLA case.
  then

     debug(l_proc_name, 30);
     l_error := pqp_gb_tp_extract_functions.raise_extract_error
                      (p_business_group_id => g_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_error_text        => p_error_text
                      ,p_error_number      => p_error_number
                      ,p_token1            => p_token
                      );

  end if;
  close csr_get_pay_ele_ids_from_bal;


  -- debug the element type ids fetched for a balance
  debug('p_balance_type_id: '||to_char(p_balance_type_id),40) ;
  l_ele_type_id := p_tab_ele_ids.FIRST;
  WHILE l_ele_type_id IS NOT NULL
  LOOP
    debug('element_type_id : '||to_char(l_ele_type_id), 50);
    l_ele_type_id := p_tab_ele_ids.NEXT(l_ele_type_id);
  END LOOP;
  -----

  debug_exit(l_proc_name);

--Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(l_proc_name);
       p_tab_ele_ids.delete;
       raise;

end get_pay_ele_ids_from_bal;

--
Function Get_Udt_Value( p_table_name        in varchar2
                       ,p_column_name       in varchar2
                       ,p_row_name          in varchar2
                       ,p_effective_date    in date
                       ,p_business_group_id in number)     Return varchar2 Is

/*
Cursor Get_Matrix_Value ( c_user_table_name  in varchar
                         ,c_user_column_name in varchar
                         ,c_user_row_name    in varchar
                         ,c_effective_date   in date) Is
 select  put.user_table_name
        ,puc.user_column_name
        ,pur.row_low_range_or_name
        ,pci.value
 from    pay_user_tables             put
        ,pay_user_columns            puc
        ,pay_user_rows_f             pur
        ,pay_user_column_instances_f pci
 where   put.user_table_name       = c_user_table_name
   and   puc.user_table_id         = put.user_table_id
   and   puc.user_column_name      = c_user_column_name
   and   pur.row_low_range_or_name = c_user_row_name
   and   pur.user_table_id         = put.user_table_id
   and   pci.user_column_id        = puc.user_column_id
   and   pci.user_row_id           = pur.user_row_id
   and   Trunc(c_effective_date) between pur.effective_start_date
                                     and pur.effective_end_date
   and   Trunc(c_effective_date) between pci.effective_start_date
                                     and pci.effective_end_date
    and ((pci.business_group_id is null and pci.legislation_code is null)
                      or (pci.legislation_code is not null
                            and pci.legislation_code = 'GB')
                      or (pci.business_group_id is not null
                            and pci.business_group_id = NVL(p_business_group_id, g_business_group_id))
        )
 order by put.user_table_name, puc.user_column_name, pur.display_sequence;
*/

l_return_value       pay_user_column_instances_f.value%TYPE;
l_udt_row            Get_Matrix_Value%ROWTYPE;
l_notfound_UDTCache  Boolean;
l_effective_date     date;
l_table_name         pay_user_tables.user_table_name%TYPE;
l_proc_name          varchar2(70) := g_proc_name || 'get_udt_value';

Begin
    debug_enter (l_proc_name);
    -- If the effective date or the UDT table name are
    -- null then take the ones defined in the package header.
    l_effective_date := NVL(p_effective_date,g_effective_date);
    l_table_name     := NVL(p_table_name,g_extract_udt_name);
    l_notfound_UDTCache := True;
    IF NVL(p_business_group_id, g_business_group_id) = g_business_group_id THEN
      -- Check if the value can be found in the cached
      -- PL/SQL record table for the given effective date
      For i In 1..g_udt_rec.count Loop
          debug(l_proc_name, 20);
          If g_udt_rec(i).column_name = p_column_name And
             g_udt_rec(i).row_name    = p_row_name    And
             (l_effective_date Between g_udt_rec(i).start_date
                                   and g_udt_rec(i).end_date)   Then
               l_return_value := g_udt_rec(i).matrix_value;
               l_notfound_UDTCache := False;
               debug(l_proc_name, 30);
               Exit;
           End If;
      End Loop;
    END IF; -- End if of p_business_group = g_business_group check ...
    --
    debug(l_proc_name, 40);
    -- If the value could not found in the cached PL/SQL
    -- table then get the value from the UDT database tables
    If l_notfound_UDTCache  Then
      debug(l_proc_name, 50);
      Open Get_Matrix_Value( c_user_table_name  => l_table_name
                            ,c_user_column_name => p_column_name
                            ,c_user_row_name    => p_row_name
                            ,c_effective_date   => l_effective_date
                            ,c_business_group_id => p_business_group_id);
      Fetch Get_Matrix_Value Into l_udt_row;
      If Get_Matrix_Value%NOTFOUND Then
         debug(l_proc_name, 60);
         l_return_value := Null;
         Close Get_Matrix_Value;
      Else
         Close Get_Matrix_Value;
         l_return_value := l_udt_row.value;
      End If;
    End If;
    debug('Return Value :'||l_return_value, 70);
    debug_exit (l_proc_name);
    Return l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
End Get_Udt_Value;


-- 4336613 : OSLA_3A : new function for defined_balance_id, moved from calc_part_time_sal
-- into a separate generic function based on balance_type_id
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_defined_balance_id >-----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE get_defined_balance_id(p_assignment_id     IN NUMBER
                                ,p_bal_type_id       IN NUMBER
                                ,p_business_group_id IN NUMBER
                                ,p_tab_bal_name      IN VARCHAR2
                                ,p_seed_flag         IN VARCHAR2)

IS
--
  l_proc_name      VARCHAR2(60) := g_proc_name || 'get_defined_balance_id';
  l_error          NUMBER;
  l_error_text     VARCHAR2(60);
  l_error_number   NUMBER;
--
BEGIN
  --
  debug_enter (l_proc_name);

  debug('p_assignment_id: '|| to_char(p_assignment_id), 10) ;
  debug('p_bal_type_id: '|| to_char(p_bal_type_id)) ;
  debug('p_business_group_id: '|| to_char(p_business_group_id)) ;

  IF NOT g_def_bal_id.EXISTS(p_bal_type_id) THEN  -- value is not set yet.
    -- get the defined balance id for the designaetd Balance type
    -- for Retro payments calculation
    debug('Setting the defined balance id ',40);
    OPEN csr_get_defined_balance_id
              ( p_balance_type_id   => p_bal_type_id
               ,p_dimension_name    => '_ASG_RETROELE_RUN'
               ,p_business_group_id => p_business_group_id
              );
    FETCH csr_get_defined_balance_id INTO g_def_bal_id(p_bal_type_id);

      IF csr_get_defined_balance_id%NOTFOUND THEN
        debug('Balance Dimension not defined',50);
        debug('THIS CONDITION SHOULD NEVER ARISE - RAISE ERROR',60);

        IF p_seed_flag = 'Y' THEN -- raise error for a seeded balance
          l_error_text   := 'BEN_94208_EXT_TP1_DEF_BAL_ERR';
          l_error_number := 94208;
        ELSE -- raise error for user defined balance
          l_error_text   := 'BEN_94246_EXT_TP1_DEF_BAL_ERR';
          l_error_number := 94246;
        END IF;

        l_error := pqp_gb_tp_extract_functions.raise_extract_error
                          (p_business_group_id => g_business_group_id
                          ,p_assignment_id     => p_assignment_id
                          ,p_error_text        => l_error_text
                          ,p_error_number      => l_error_number
                          ,p_token1            => p_tab_bal_name
                          );

      ELSE
        debug('g_def_bal_id(p_bal_type_id): '||to_char(g_def_bal_id(p_bal_type_id)),70);
      END IF ;

    CLOSE csr_get_defined_balance_id ;
  END IF ;

  debug('AFTER: g_def_bal_id (p_bal_type_id):'|| to_char(g_def_bal_id(p_bal_type_id)),80) ;


  debug_exit (l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
  RAISE;

END get_defined_balance_id;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< fetch_eles_from_bals >-----------------------|
-- ----------------------------------------------------------------------------
procedure fetch_eles_from_bals (p_assignment_id     in     number
                               ,p_effective_date    in     date
                               ,p_business_group_id in     number)
is
--
  l_proc_name      varchar2(60) := g_proc_name || 'fetch_eles_from_bals';

  l_tab_bal_name     t_varchar;
  l_bal_type_id      pay_balance_types.balance_type_id%type;
  l_legislation_code VARCHAR2(30); -- to hold legislation code of balance
  l_error            NUMBER ;
  l_seed_flag        VARCHAR2(1); -- flag to signify if balance is seeded/user defined
--
begin
  --
  -- hr_utility.set_location ('Entering: '||l_proc_name, 10);
  --
  debug_enter (l_proc_name);

  -- Get Absence balance name from the UDT

  l_tab_bal_name(1) := get_udt_value (p_column_name       => 'Attribute Location Qualifier 1'
                                     ,p_row_name          => 'Days Excluded Balance'
                                     ,p_business_group_id => p_business_group_id
                                     );
  -- Check whether a balance name is specified otherwise use
  -- the seeded generic balance for days excluded

  if l_tab_bal_name(1) is null then

     l_tab_bal_name(1) := 'Teachers Total Days Excluded';

  end if; -- end if of balance name specified check ...

  --
  debug(l_proc_name, 20);
  debug('Business Group: '||to_char(p_business_group_id));
  --

  -- Get Superannuable Salary balance name from the UDT

  l_tab_bal_name(2) := get_udt_value (p_column_name       => 'Attribute Location Qualifier 1'
                                     ,p_row_name          => 'Superannuable Salary Balance'
                                     ,p_business_group_id => p_business_group_id
                                     );
  -- Check whether a balance name is specified otherwise use
  -- the seeded generic balance for superannuable salary

  if l_tab_bal_name(2) is null then

     l_tab_bal_name(2) := 'Teachers Superannuable Salary';

  end if; -- end if of balance name specified check ...


  --4336613 : OSLA_3A : new balance seeded for OSLA calculations
  -- Get Teachers OSLA Payments balance name from the UDT

  l_tab_bal_name(3) := get_udt_value (p_column_name       => 'Attribute Location Qualifier 1'
                                     ,p_row_name          => 'Teachers OSLA Payments Balance'
                                     ,p_business_group_id => p_business_group_id
                                     );
  -- Check whether a balance name is specified otherwise use
  -- the seeded generic balance for superannuable salary

  if l_tab_bal_name(3) is null then

     l_tab_bal_name(3) := 'Teachers OSLA Payments';

  end if; -- end if of balance name specified check ...
  -- end of OSLA section

  l_tab_bal_name(4) := get_udt_value (p_column_name       => 'Attribute Location Qualifier 1'
                                     ,p_row_name          => 'Superannuable Claims Balance'
                                     ,p_business_group_id => p_business_group_id
                                     );
  -- Check whether a balance name is specified otherwise use
  -- the seeded generic balance for superannuable salary

  if l_tab_bal_name(4) is null then

     l_tab_bal_name(4) := 'Teachers Superannuable Claims';

  end if; -- end if of balance name specified check ...
  -- end of OSLA section

  -- Get Teachers OSLA Payments balance name from the UDT

  l_tab_bal_name(5) := get_udt_value (p_column_name       => 'Attribute Location Qualifier 1'
                                     ,p_row_name          => 'Teachers OSLA Claims Balance'
                                     ,p_business_group_id => p_business_group_id
                                     );
  -- Check whether a balance name is specified otherwise use
  -- the seeded generic balance for superannuable salary

  if l_tab_bal_name(5) is null then

     l_tab_bal_name(5) := 'Teachers OSLA Claims';

  end if; -- end if of balance name specified check ...
  -- end of OSLA section

  -- Get Teachers GTC Payments balance name from the UDT

  l_tab_bal_name(6) := get_udt_value (p_column_name       => 'Attribute Location Qualifier 1'
                                     ,p_row_name          => 'GTC Payments Balance'
                                     ,p_business_group_id => p_business_group_id
                                     );
  -- Check whether a balance name is specified otherwise use
  -- the seeded generic balance for GTC Payments

  if l_tab_bal_name(6) is null then

     l_tab_bal_name(6) := 'GTC Payments';

  end if; -- end if of balance name specified check ...


  FOR i IN 1..l_tab_bal_name.count LOOP
    --
    debug(l_proc_name, 30);
    debug('Balance Name: '||l_tab_bal_name(i));
    --
    -- Get balance type id for this balance name
    l_bal_type_id := get_pay_bal_id (p_balance_name      => l_tab_bal_name(i)
                                    ,p_business_group_id => p_business_group_id
                                    ,p_legislation_code  => l_legislation_code); --OUT

    debug('Balance ID: '||to_char(l_bal_type_id),40);

    -- store bal_type_id in global
    IF i = 1 THEN
       g_abs_bal_type_id(p_business_group_id) := l_bal_type_id;
    ELSIF i=2 THEN
      g_sal_bal_type_id(p_business_group_id) := l_bal_type_id;
    ELSIF i=3 THEN
      g_osla_bal_type_id(p_business_group_id) := l_bal_type_id; --4336613 : OSLA_3A: new global
    ELSIF i=4 THEN
      g_cl_bal_type_id(p_business_group_id) := l_bal_type_id;
    ELSIF i=5 THEN
      g_osla_cl_bal_type_id(p_business_group_id) := l_bal_type_id;
    ELSE
      g_gtc_bal_type_id(p_business_group_id) := l_bal_type_id;
    END IF;


    -- 4336613 : OSLA_3A : moved from inside calc_part_time_sal to here
    -- call to function to store defined balance id for i=2 and 3,
    -- i.e. Teachers Superannuable Sal and OSLA Payments balance
    IF i=2 OR i=3 THEN

      IF l_legislation_code IS NOT NULL THEN -- for case when user balance name is
      -- same as the seeded balance, leg_code will be GB for seeded balance
      -- and NULL for user balance
        l_seed_flag := 'Y'; -- not NULL,implies is a seeded balance name in UDT
      ELSE
        l_seed_flag := 'N'; -- user defined balance in the UDT
      END IF; -- end if of balance name specified check ...

      -- store balance type id
      get_defined_balance_id(p_assignment_id     => p_assignment_id
                            ,p_bal_type_id       => l_bal_type_id
                            ,p_business_group_id => p_business_group_id
                            ,p_tab_bal_name      => l_tab_bal_name(i)
                            ,p_seed_flag         => l_seed_flag
                            );

    END IF;


  END LOOP;

  --
  debug(l_proc_name, 60);
  --
  -- Get element type id's feeding absence balance
  --
  get_pay_ele_ids_from_bal (p_assignment_id        => p_assignment_id
                           ,p_balance_type_id      => g_abs_bal_type_id(p_business_group_id)
                           ,p_effective_date       => p_effective_date
                           ,p_error_text           => 'BEN_93025_EXT_TP1_BAL_NOFEEDS'
                           ,p_error_number         => 93025
                           ,p_business_group_id    => p_business_group_id
                           ,p_tab_ele_ids          => g_tab_abs_ele_ids
                           ,p_token                => 'Days Excluded Balance'
                           );

  debug(l_proc_name, 70);
  --
  -- Get element type id's feeding salary balance
  --
  -- Bug 3015917 : Added this as we need to cache PET Ids for Sal Balance
  get_pay_ele_ids_from_bal (p_assignment_id        => p_assignment_id
                           ,p_balance_type_id      => g_sal_bal_type_id(p_business_group_id)
                           ,p_effective_date       => p_effective_date
                           ,p_error_text           => 'BEN_93025_EXT_TP1_BAL_NOFEEDS'
                           ,p_error_number         => 93025
                           ,p_business_group_id    => p_business_group_id
                           ,p_tab_ele_ids          => g_tab_sal_ele_ids -- OUT
                           ,p_token                => 'Superannuable Salary Balance'
                           );

  -- Bug 6689648
  -- Superannuable Claims Balance is applicable only when Date Worked mode is Used
  if g_date_work_mode = 'Y' then
     get_pay_ele_ids_from_bal (p_assignment_id        => p_assignment_id
                           ,p_balance_type_id      => g_cl_bal_type_id(p_business_group_id)
                           ,p_effective_date       => p_effective_date
                           ,p_error_text           => 'BEN_93025_EXT_TP1_BAL_NOFEEDS'
                           ,p_error_number         => 93025
                           ,p_business_group_id    => p_business_group_id
                           ,p_tab_ele_ids          => g_tab_cl_ele_ids -- OUT
                           ,p_token                => 'Superannuable Claims Balance'
                           );
  end if ;

  -- 4336613 : OSLA_3A : fetching values in g_tab_osla_ele_ids
  --
  -- Get element type id's feeding OSLA Payments balance
  --
  get_pay_ele_ids_from_bal (p_assignment_id        => p_assignment_id
                           ,p_balance_type_id      => g_osla_bal_type_id(p_business_group_id)
                           ,p_effective_date       => p_effective_date
                           ,p_error_text           => NULL -- 'BEN_93025_EXT_TP1_BAL_NOFEEDS'
                           ,p_error_number         => NULL --  93025
                           ,p_business_group_id    => p_business_group_id
                           ,p_tab_ele_ids          => g_tab_osla_ele_ids
                           );

  -- Bug 6689648
  -- Teachers OSLA Claims Balance is applicable only when Date Worked mode is Used
  if g_date_work_mode = 'Y' then
     get_pay_ele_ids_from_bal (p_assignment_id        => p_assignment_id
                           ,p_balance_type_id      => g_osla_bal_type_id(p_business_group_id)
                           ,p_effective_date       => p_effective_date
                           ,p_error_text           => NULL -- 'BEN_93025_EXT_TP1_BAL_NOFEEDS'
                           ,p_error_number         => NULL --  93025
                           ,p_business_group_id    => p_business_group_id
                           ,p_tab_ele_ids          => g_tab_osla_cl_ele_ids
                           );
  end if ;

  get_pay_ele_ids_from_bal (p_assignment_id        => p_assignment_id
                           ,p_balance_type_id      => g_gtc_bal_type_id(p_business_group_id)
                           ,p_effective_date       => p_effective_date
                           ,p_error_text           => NULL -- 'BEN_93025_EXT_TP1_BAL_NOFEEDS'
                           ,p_error_number         => NULL --  93025
                           ,p_business_group_id    => p_business_group_id
                           ,p_tab_ele_ids          => g_tab_gtc_ele_ids
                           );

  -- Raise a warning if no element is feeding the
  -- OSLA balance.
  IF g_tab_osla_ele_ids.COUNT = 0 THEN
    debug(l_proc_name,80 )   ;
    l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94240_T1_OSLA_ELE_NOTEXIST'
                 ,p_error_number  => 94240
                 );
     debug('l_error: '|| to_char(l_error), 90 ) ;
  END IF;

  -- Bug 6689648
  -- Teachers OSLA Claims Balance is applicable only when Date Worked mode is Used
  if g_date_work_mode = 'Y' then
     IF g_tab_osla_cl_ele_ids.COUNT = 0 THEN
        debug(l_proc_name,80 )   ;
        l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94240_T1_OSLA_ELE_NOTEXIST'
                 ,p_error_number  => 94240
                 );
       debug('l_error: '|| to_char(l_error), 90 ) ;
     END IF;
  end if ;

  debug_exit (l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end fetch_eles_from_bals;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< fetch_eles_for_t1_bals >----------------------|
-- ----------------------------------------------------------------------------
procedure fetch_eles_for_t1_bals (p_assignment_id  in     number
                                 ,p_effective_date in     date)
is
--
  l_proc_name      varchar2(60) := g_proc_name || 'fetch_eles_for_t1_bals';

  l_tab_bal_name   t_varchar;
  l_bal_type_id    pay_balance_types.balance_type_id%type;
  i                number;

--
begin
  --
  -- hr_utility.set_location ('Entering: '||l_proc_name, 10);
  --
  debug_enter (l_proc_name);

  g_abs_bal_type_id.DELETE;
  g_sal_bal_type_id.DELETE;
  g_cl_bal_type_id.DELETE;
  g_tab_abs_ele_ids.DELETE;
  g_tab_sal_ele_ids.DELETE;

  -- 4336613 : OSLA_3A : new globals for OSLA
  g_osla_bal_type_id.DELETE;
  g_osla_cl_bal_type_id.DELETE;
  g_tab_osla_ele_ids.DELETE;

  -- Fetch the elements from balances for master business group first

  debug(l_proc_name, 10);

  fetch_eles_from_bals (p_assignment_id     => p_assignment_id
                       ,p_effective_date    => p_effective_date
                       ,p_business_group_id => g_business_group_id
                       );

  -- Check whether the collection g_LEA_business_groups has more than one count
  IF g_lea_business_groups.COUNT > 0 THEN

    i := g_lea_business_groups.FIRST;

    WHILE i IS NOT NULL
    LOOP

      debug(l_proc_name, 20);

      fetch_eles_from_bals (p_assignment_id     => p_assignment_id
                           ,p_effective_date    => p_effective_date
                           ,p_business_group_id => g_lea_business_groups(i).business_group_id
                           );
      i := g_lea_business_groups.NEXT(i);

    END LOOP;

  END IF; -- End if of multiple business groups exists check ...

  --
  -- hr_utility.set_location ('Leaving: '||l_proc_name, 30);
  --
  debug_exit (l_proc_name);

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end fetch_eles_for_t1_bals;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_rate_type_from_udt >----------------------|
-- ----------------------------------------------------------------------------
procedure get_rate_type_from_udt (p_assignment_id in    number) is
--
  l_proc_name      varchar2(60) := g_proc_name || 'get_rate_type_from_udt';

  cursor csr_rate_type_check (p_meaning varchar2) is
  select 'Y'
    from hr_lookups
  where meaning         = p_meaning
    and lookup_type     = 'PQP_RATE_TYPE'
    and enabled_flag    = 'Y'
    and g_effective_date between
          nvl(start_date_active, g_effective_date)
          and nvl(end_date_active, g_effective_date);

  l_tab_rate_type  t_varchar;
  l_tab_rate_name  t_varchar;
  l_exists         varchar2(1);
  l_error          number;
--
begin
  --
  -- hr_utility.set_location ('Entering: '||l_proc_name, 10);
  --
  debug_enter (l_proc_name);

  l_tab_rate_type(1) := 'Other Allowances';
  l_tab_rate_type(2) := 'Salary';
  l_tab_rate_type(3) := 'Safeguarded Salary';
  l_tab_rate_type(4) := 'LARP and SPAP Allowances';

  for i in 1..l_tab_rate_type.count loop

    --
    debug (l_proc_name, 20);
    --
    l_tab_rate_name(i) := get_udt_value (p_column_name => 'Attribute Location Qualifier 1'
                                        ,p_row_name    => l_tab_rate_type(i)
                                        );

    -- Check whether a rate type has been specified
    -- Bug fix 2786740
    -- Raise error only for "Salary" rate type

    if l_tab_rate_name(i) is null and l_tab_rate_type(i) = 'Salary' then

      l_error := pqp_gb_tp_extract_functions.raise_extract_error
                      (p_business_group_id => g_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_error_text        => 'BEN_93023_EXT_TP1_NO_RATE_TYPE'
                      ,p_error_number      => 93023
                      );

    end if; -- end if of rate type specified check ...

    -- Modified for bug fix 2350695
    -- Check whether this rate type exists in the lookup type 'PQP_RATE_TYPE'

    IF l_tab_rate_name(i) IS NOT NULL THEN

       debug (l_proc_name, 30);
       open csr_rate_type_check (l_tab_rate_name(i));
       fetch csr_rate_type_check into l_exists;

       if csr_rate_type_check%notfound then

          close csr_rate_type_check;
          l_error := pqp_gb_tp_extract_functions.raise_extract_error
                         (p_business_group_id => g_business_group_id
                         ,p_assignment_id     => p_assignment_id
                         ,p_error_text        => 'BEN_93046_EXT_TP1_INV_RATE_TYP'
                         ,p_error_number      => 93046
                        );

       end if; -- end if of rate type exists in lookup check ...
       close csr_rate_type_check;

    END IF; -- End if of rate name not null check ...

  end loop;

  g_oth_rate_type := l_tab_rate_name(1);
  g_sal_rate_type := l_tab_rate_name(2);
  g_sf_rate_type  := l_tab_rate_name(3);
  g_lon_rate_type := l_tab_rate_name(4);

  --
  -- hr_utility.set_location ('Leaving: '||l_proc_name, 30);
  --
  debug_exit (l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end get_rate_type_from_udt;

-- Commenting the following function
-- as this is not required now.
-- the replacement function is chk_effective_asg
/*--
-- chk_eff_primary_asg
-- Procedure returns 'Y' if the primary is a valid TCHR assignment
-- on p_effective_date.
--
FUNCTION chk_eff_primary_asg
    (p_assignment_id            IN  NUMBER
    ,p_effective_date           IN  DATE
    ) RETURN VARCHAR2
IS

  l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
  l_retval              VARCHAR2(1) := 'Y';
  l_effective_date      DATE;



  l_proc_name           varchar2(60) := g_proc_name || 'chk_eff_primary_asg';

BEGIN -- chk_eff_primary_asg

  debug_enter(l_proc_name);
  debug('p_assignment_id :'||to_char(p_assignment_id), 10);
  debug('p_effective_date :'||to_char(p_effective_date), 20);


  -- Bugfix 3803760:FTSUPPLY : Added the overrid ft asg logic
  IF g_override_ft_asg_id IS NULL THEN

    IF (g_ext_asg_details.EXISTS(p_assignment_id)
        AND
        g_ext_asg_details(p_assignment_id).report_asg = 'Y' -- is to be reported
        AND
        (p_effective_date
            BETWEEN nvl(g_ext_asg_details(p_assignment_id).start_date, p_effective_date )
                    AND
                    nvl(g_ext_asg_details(p_assignment_id).leaver_date, g_effective_run_date)
         OR
         (g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL
          AND
          p_effective_date >= g_ext_asg_details(p_assignment_id).restarter_date
         )
        )
       ) THEN

      l_retval := 'Y';
      debug(l_proc_name, 30);

    ELSE

      debug(l_proc_name, 50);
      l_retval := 'N';

    END IF;

  ELSIF g_override_ft_asg_id = p_assignment_id THEN

    l_retval := 'Y';
    debug(l_proc_name, 60);

  ELSE

    debug(l_proc_name, 70);
    l_retval := 'N';

  END IF;

  debug('l_retval ' ||l_retval) ;
  debug_exit(l_proc_name);

  RETURN l_retval;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- chk_eff_primary_asg
*/

-- This procedure will find all BGs which have the same
-- LEA number and have been enabled for cross BG reporting
-- and store them in global collection
PROCEDURE store_cross_bg_details
IS

  l_BG_dets             csr_all_business_groups%ROWTYPE;
  l_master_bg_dets      csr_multiproc_data%ROWTYPE;

  l_proc_name      varchar2(60) := g_proc_name || 'store_cross_bg_details';

BEGIN  -- store_cross_bg_details

  debug_enter(l_proc_name);

  IF pqp_gb_tp_pension_extracts.g_parent_request_id <> -1 THEN

    -- We are running the TPEP, get the master bg id
    OPEN csr_multiproc_data(p_record_type => 'M');
    FETCH csr_multiproc_data INTO l_master_bg_dets;

    IF csr_multiproc_data%FOUND
       AND
       l_master_bg_dets.business_group_id IS NOT NULL  THEN
      g_master_bg_id := l_master_bg_dets.business_group_id;
    ELSE
     -- We might need an ERROR here
     -- If we do raise an error, plaese also
     -- do a CLOSE cursor here
     debug('This situation should never arise', 10);
    END IF;

    CLOSE csr_multiproc_data;

  ELSE -- We are running the Extract Process

    -- The Type 1 extract process has been submitted
    -- directly for an LEA report instead of using the new
    -- master process for TPA reports which sets the
    -- master BG in the multiproc data table.
    -- We can safely make this assumption and set the current
    -- BG as master BG.
    g_master_bg_id := g_business_group_id;

    -- Should we still leave cross BG reporting enabled
    -- Answer is NO
    g_crossbg_enabled := 'N';

    -- Also change the flag in Type 4 pkg
    pqp_gb_tp_pension_extracts.g_crossbg_enabled := 'N';

  END IF;

  debug('MasterBG :'||to_char(g_master_bg_id)||
        ' CurrentBG :'||to_char(g_business_group_id)
       , 20
       );

  g_lea_business_groups.DELETE;

  IF g_crossbg_enabled = 'Y' THEN

    -- Loop thru all the LEA BGs enabled for Cross BG reporting
    FOR l_BG_dets IN csr_all_business_groups(g_lea_number)
    LOOP -- 1

      g_lea_business_groups(l_BG_dets.business_group_id) := l_BG_dets;

      debug(l_proc_name, 30);

      -- Store all criteria establishments from this BG
      FOR l_estb_details IN pqp_gb_tp_pension_extracts.csr_estb_details
                              (p_business_group_id => l_BG_dets.business_group_id
                              ,p_lea_estb_yn => 'Y')
      LOOP -- 2

        pqp_gb_tp_pension_extracts.g_criteria_estbs(l_estb_details.location_id):= l_estb_details;

        debug('Establishment Details...', 40);
        debug(pqp_gb_tp_pension_extracts.g_criteria_estbs(l_estb_details.location_id).location_id);
        debug(pqp_gb_tp_pension_extracts.g_criteria_estbs(l_estb_details.location_id).lea_estb_yn);
        debug(pqp_gb_tp_pension_extracts.g_criteria_estbs(l_estb_details.location_id).estb_number);
        debug(pqp_gb_tp_pension_extracts.g_criteria_estbs(l_estb_details.location_id).estb_name);
        debug(pqp_gb_tp_pension_extracts.g_criteria_estbs(l_estb_details.location_id).estb_type);
        debug('...Establishment Details', 50);

      END LOOP; -- 2
      --
    END LOOP; -- 1

  END IF; -- g_crossbg_enabled = 'Y' THEN

  debug_exit (l_proc_name);

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- store_cross_bg_details

--
-- reset_proc_status
--
PROCEDURE reset_proc_status IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  l_req_dets    csr_request_dets%ROWTYPE;

  l_proc_name VARCHAR2(61):= 'reset_proc_status';

BEGIN

  debug_enter(l_proc_name);

  -- Reset the processing status to U in the multiproc data table
  -- if the Extract Process is running on its own

  -- Bugfix 3671727:ENH2
  --   Commenting out the cursor call coz the parent
  --   request id is not being set in a global in
  --   Type 4 code coz its needed to get the master
  --   rec from pqp_ext_cross_person_records
  /* OPEN csr_request_dets;
     FETCH csr_request_dets INTO l_req_dets;
     CLOSE csr_request_dets;
  */

  IF pqp_gb_tp_pension_extracts.g_parent_request_id = -1 THEN

    debug(l_proc_name, 20);
    UPDATE pqp_ext_cross_person_records
       SET processing_status = 'U'
          ,request_id            = fnd_global.conc_request_id
          ,last_updated_by       = fnd_global.user_id
          ,last_update_date      = SYSDATE
          ,last_update_login     = fnd_global.login_id
          ,object_version_number = (object_version_number + 1)
     WHERE record_type = 'X'
       AND ext_dfn_id  = ben_ext_thread.g_ext_dfn_id    --ENH2
       AND lea_number  = g_lea_number;                  --ENH1

  END IF;

  COMMIT;

  debug_exit(l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END reset_proc_status;

--
-- set_t1_extract_globals
--
PROCEDURE set_t1_extract_globals
  (p_business_group_id        IN      NUMBER
  ,p_effective_date           IN      DATE
  ,p_assignment_id            IN      NUMBER
  )
IS

  l_proc_name VARCHAR2(61):= 'set_t1_extract_globals';

  -- 4336613 : PROSWITCH_3A :
  -- temporary variables to store value fetched from UDT
  l_calc_sal_new VARCHAR2(100);
  l_calendar_avg VARCHAR2(100);
  l_date_work_mode VARCHAR2(100);   -- rahul supply

  l_error        NUMBER;


BEGIN
  debug_enter(l_proc_name);

  -- Set the globals in this package
  g_business_group_id := p_business_group_id;
  debug(p_effective_date);
  g_effective_date    := p_effective_date;

  -- Call the Type 4 function to set globals in Type 4 package
  pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
  pqp_gb_tp_pension_extracts.set_extract_globals
        (p_business_group_id
        ,p_effective_date
        ,p_assignment_id
        );
  pqp_gb_tp_pension_extracts.g_nested_level := 0;

  -- Set the globals in this package before exiting this function
  -- ********* Variables ***************
  g_extract_type                := pqp_gb_tp_pension_extracts.g_extract_type;
  g_extract_udt_name            := pqp_gb_tp_pension_extracts.g_extract_udt_name;
  g_criteria_location_code      := pqp_gb_tp_pension_extracts.g_criteria_location_code;
  g_lea_number                  := pqp_gb_tp_pension_extracts.g_lea_number;
  g_crossbg_enabled             := pqp_gb_tp_pension_extracts.g_crossbg_enabled;
  g_estb_number                 := pqp_gb_tp_pension_extracts.g_estb_number;
  g_originators_title           := pqp_gb_tp_pension_extracts.g_originators_title;
  g_header_system_element       := pqp_gb_tp_pension_extracts.g_header_system_element;

  /************ Collections ***********
  Sh we duplicate or just use the one in Type 4??
  Current thought is reuse from Type 4

  g_criteria_estbs
  */
  --ENH1:The store_cross_bg details is being called by set_extract_globals
  --from type4.
/*
  -- Bugfix 3073562:GAP1:GAP2
  -- If its the LEA run
  -- AND current BG is enabled for cross BG reporting
  IF g_estb_number = '0000'
     AND
     g_crossbg_enabled = 'Y'
  THEN
    -- Store all BGs with same LEA Number and
    -- enabled for cross BG reporting
    store_cross_bg_details;
  ELSE -- Non-LEA Run
    g_master_bg_id := g_business_group_id;
  END IF;
*/
      g_tab_lon_aln_eles.DELETE;
      g_tab_spl_aln_eles.DELETE;

      g_spl_all_grd_src := 'N';
      g_lon_all_grd_src := 'N';

  -- Get UDT Data
  get_udt_data (p_udt_name       => 'PQP_GB_TP_TYPE1_EXTRACT_DEFINITIONS'
               ,p_effective_date => p_effective_date
               );

  -- Get Element information from UDT
  --get_elements_frm_udt (p_assignment_id => p_assignment_id);

  -- Get Rate Type Name from UDT
  get_rate_type_from_udt (p_assignment_id => p_assignment_id);

-- changed for 5743209
   fetch_allow_eles_frm_udt (p_assignment_id  => p_assignment_id
                               ,p_effective_date => p_effective_date
                               );
  --CALC_PT_SAL_OPTIONS : BUG: 4135481
  -- Two new rows are now seeded in the UDT for the role of switches
  -- 1. "Part Time Salary Paid - Enable Date Earned Mode"
  -- 2. "Part Time Salary Paid - Enable Calendar Day Proration"
  -- First switch is for enabling / disabling the new logic for calculating part
  -- time salary (based on date earned) or revert back to previous logic (date paid).
  -- The second switch is for enabling / disabling calendar averaging, in case NO
  -- matching proration events are found.

  l_calc_sal_new := Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                                  ,p_row_name    => 'Part Time Salary Paid - Enable Date Earned Mode'
                                  );

  debug('l_calc_sal_new: ' || l_calc_sal_new,10);

  l_calendar_avg := Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'
                                  ,p_row_name    => 'Part Time Salary Paid - Enable Calendar Day Proration'
                                  );

  debug('l_calendar_avg: ' || l_calendar_avg,20);


  --CALC_PT_SAL_OPTIONS :
  -- One new row is now seeded in the UDT for the role of switch
  -- 3. "Date Worked Payment Mode"
  -- The third switch is for enabling / disabling the new logic for calculating part time salary
  -- only for supply teachers (based on date worked) or revert back to previous logic (date earned or date paid).
  l_date_work_mode := Get_Udt_Value (p_column_name => 'Attribute Location Qualifier 1'                     -- rahul supply
                                    ,p_row_name    => 'Date Worked Payment Mode'
                                  );

  debug('l_date_work_mode: ' || l_date_work_mode,21);                               -- rahul supply



  -- The following globals will be used to provide additional options for part
  -- time salary computation methods in calc_part_time_sal function

  -- If Switch1 is not set and Switch2 is not set, then Switch1=Switch2 = 'Y'.
  -- If Switch1 is set and Switch2 is not set, then Switch2 = Switch1.
  -- If Switch1 is not set and Switch2 is set, then Switch1 = 'Y' and
  -- Switch2 is whatever it is set to.

  -- switch 1
  l_calc_sal_new  := nvl(l_calc_sal_new, 'Y'); -- use old/new method


  -- 4336613 : PROSWITCH_3A :
  -- raise an error if the value of g_calc_sal_new switch in UDT is not
  -- among 'Y', 'YES', 'N', or 'NO' (i.e. is an invalid value)

  IF( UPPER(l_calc_sal_new) NOT IN ('Y', 'YES', 'N', 'NO')
    ) THEN

    debug('--- Raise error : invalid switch values in UDT ---',25);

    -- new error message for invalid values in UDT
    l_error := pqp_gb_tp_extract_functions.raise_extract_error
                      (p_business_group_id => g_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_error_text        => 'BEN_94231_TP1_INVALID_UDT_VAL'
                      ,p_error_number      => 94231
                      ,p_token1            => 'Part Time Salary Paid - Enable Date Earned Mode'
                      );

  ELSIF((UPPER(l_calc_sal_new) = 'Y')
         OR
        (UPPER(l_calc_sal_new) = 'YES')
       )THEN
       l_calc_sal_new := 'Y';
  ELSE
       l_calc_sal_new := 'N';

  END IF;

  -- setting the validated value to global
  g_calc_sal_new := l_calc_sal_new;



  -- setting globals after checking validity of values of g_calc_sal_new
  g_proration     := g_calc_sal_new; -- set this to Y if new method is to be used

  -- switch 2
  l_calendar_avg  := nvl(l_calendar_avg, g_proration) ;


  -- 4336613 : PROSWITCH_3A :
  -- raise an error if the value of g_calendar_avg switch in UDT is not
  -- among 'Y', 'YES', 'N', or 'NO' (i.e. is an invalid value)

  IF( UPPER(l_calendar_avg) NOT IN ('Y', 'YES', 'N', 'NO')
    ) THEN

    debug('--- Raise error : invalid switch values in UDT ---',25);

    -- new error message for invalid values in UDT
    l_error := pqp_gb_tp_extract_functions.raise_extract_error
                      (p_business_group_id => g_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_error_text        => 'BEN_94231_TP1_INVALID_UDT_VAL'
                      ,p_error_number      => 94231
                      ,p_token1            => 'Part Time Salary Paid - Enable Calendar Day Proration'
                      );

  ELSIF((UPPER(l_calendar_avg) = 'Y')
         OR
        (UPPER(l_calendar_avg) = 'YES')
       )THEN
       l_calendar_avg := 'Y';
  ELSE
       l_calendar_avg := 'N';

  END IF;

  -- setting validated value to global
  g_calendar_avg := l_calendar_avg;

  -- Switch 3

  l_date_work_mode := nvl(l_date_work_mode,'N');                      -- rahul supply

  IF( UPPER(l_date_work_mode) NOT IN ('Y', 'YES', 'N', 'NO')          -- rahul supply
    ) THEN

    debug('--- Raise error : invalid switch values in UDT ---',25);

    -- new error message for invalid values in UDT
    l_error := pqp_gb_tp_extract_functions.raise_extract_error
                      (p_business_group_id => g_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_error_text        => 'BEN_94231_TP1_INVALID_UDT_VAL'
                      ,p_error_number      => 94231
                      ,p_token1            => 'Date Worked Payment Mode'
                      );

  ELSIF((UPPER(l_date_work_mode) = 'Y')
         OR
        (UPPER(l_date_work_mode) = 'YES')
       )THEN
       l_date_work_mode := 'Y';
  ELSE
       l_date_work_mode := 'N';

  END IF;

  -- Setting the validated value to global
  g_date_work_mode := l_date_work_mode;                             -- rahul supply

  debug('g_calc_sal_new: ' || g_calc_sal_new,30);
  debug('g_proration: ' || g_proration,40);
  debug('g_calendar_avg: ' || g_calendar_avg,50);
  debug('g_date_work_mode: ' || g_date_work_mode,55);



  -- Get the record id for the Type 1 Detail record
  OPEN csr_ext_rcd_id(p_hide_flag       => 'N'
                     ,p_rcd_type_cd     => 'D'
                     );
  FETCH csr_ext_rcd_id INTO g_ext_dtl_rcd_id;
  -- Do we need to raise an error if there are 2 diplayed detail records??
  -- If yes, then Fetch ... , check .. and raise error
  -- Alternatively, modify the cursor to return the required id by querying on name.
  CLOSE csr_ext_rcd_id;

  --ENH1:The reset_proc_status details is being called by set_extract_globals
  --from type4.
  -- Reset the processing status in multiproc data table to U
  --  reset_proc_status;

  debug_exit(l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END set_t1_extract_globals;

--
-- set_periodic_run_dates
--
PROCEDURE set_periodic_run_dates
  IS

  l_proc_name VARCHAR2(61):= 'set_periodic_run_dates';

BEGIN

  debug_enter(l_proc_name);

  -- Call the Type 4 function to set run dates in Type 4 package
  pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
  pqp_gb_tp_pension_extracts.set_run_effective_dates;
  pqp_gb_tp_pension_extracts.g_nested_level := 0;

  -- Set the globals in this package before exiting this function
  -- ********* Variables ****************
  g_last_effective_date     := pqp_gb_tp_pension_extracts.g_last_effective_date;
  g_next_effective_date     := pqp_gb_tp_pension_extracts.g_next_effective_date;
  g_effective_run_date      := pqp_gb_tp_pension_extracts.g_effective_run_date;

  -- For the sake of periodic report only
  --  pension year end date is being set as the run end date.
  g_pension_year_end_date   := g_effective_run_date;

  -- Changed by Raju T. on 08/05/2002 as a development bugfix
  -- Commented out as this is now being created differently for Type 1
  --  g_header_system_element   := pqp_gb_tp_pension_extracts.g_header_system_element;

  -- Set the start date of the pension year, i.e. 01-04-YYYY
  SELECT TO_DATE('01-04-'||
                        DECODE
                          (SIGN(TO_NUMBER(TO_CHAR(g_effective_run_date,'MM')) - 04)
                          ,-1,TO_CHAR(ADD_MONTHS(g_effective_run_date,-12),'YYYY')
                          ,TO_CHAR(g_effective_run_date,'YYYY'))
                      ,'DD-MM-YYYY')
               INTO g_pension_year_start_date
             FROM DUAL;

  -- Changed by Raju T. on 08/05/2002 as a development bugfix
  -- The last eff date and header sys element is now being created
  -- differently for Type 1 and being overwritten in the Type 4 Pkg
  -- Changes START here
  g_last_effective_date := GREATEST(g_last_effective_date
                                   ,g_pension_year_start_date
                                   );

  IF g_last_effective_date <> pqp_gb_tp_pension_extracts.g_last_effective_date THEN

    pqp_gb_tp_pension_extracts.g_last_effective_date := g_last_effective_date;

  END IF;

  g_header_system_element:=
          g_header_system_element||
          fnd_date.date_to_canonical(g_last_effective_date)||':'||
          fnd_date.date_to_canonical(g_effective_run_date) ||':'||
          fnd_date.date_to_canonical(g_next_effective_date)||':';

  -- Assign the newly created system element to the type4 global
  pqp_gb_tp_pension_extracts.g_header_system_element := g_header_system_element;

  debug('New Type 1 Header System Element :'||g_header_system_element);
  -- Changes END here

  debug_exit(l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END set_periodic_run_dates;

--
-- set_annual_run_dates
--
PROCEDURE set_annual_run_dates
  IS

  l_year        NUMBER;
  l_proc_name   VARCHAR2(61):= 'set_annual_run_dates';

BEGIN

  debug_enter(l_proc_name);

  debug(TO_CHAR(g_effective_date,'DD-MON-YYYY'));

  debug('g_effective_date: '||
        fnd_date.date_to_canonical(g_effective_date));

  IF to_number(to_char(g_effective_date, 'MM'))
       BETWEEN 1 AND 3 THEN

     -- Pension year should end YY - 1
     l_year := to_number(to_char(g_effective_date, 'YYYY')) - 1;

  ELSE

    -- Pension year should end YY
    l_year := to_number(to_char(g_effective_date, 'YYYY'));

  END IF; -- End if of month check...

  g_pension_year_start_date := to_date('01/04/'||to_char(l_year), 'DD/MM/YYYY');
  g_pension_year_end_date   := to_date('31/03/'||to_char(l_year+1)||
                              '23:59:59', 'DD/MM/YYYY HH24:MI:SS');


  g_header_system_element:=
        g_header_system_element||
        fnd_date.date_to_canonical(g_pension_year_start_date)||':'||
        fnd_date.date_to_canonical(g_pension_year_end_date)||':'||
        fnd_date.date_to_canonical(g_effective_date)||':';

  -- Set the globals in this package
  g_last_effective_date     := g_pension_year_start_date;
  g_next_effective_date     := g_effective_date;
  g_effective_run_date      := g_pension_year_end_date;

  -- Now set the Type 4 globals
  pqp_gb_tp_pension_extracts.g_last_effective_date      := g_last_effective_date;
  pqp_gb_tp_pension_extracts.g_next_effective_date      := g_next_effective_date;
  pqp_gb_tp_pension_extracts.g_effective_run_date       := g_effective_run_date;
  pqp_gb_tp_pension_extracts.g_header_system_element    := g_header_system_element;

  debug('Header System Element :'||g_header_system_element);

  debug_exit(l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END set_annual_run_dates;

--
-- set_pay_proc_events_to_process
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
  -- as determined by the date range. The maxmum allowed range
  -- is the pension year start date and a day before the current eff date

  UPDATE pay_process_events
     SET retroactive_status = p_status
        ,status             = p_status
   WHERE assignment_id = p_assignment_id
     AND change_type = 'REPORTS'
     AND effective_date -- allow all events effective as of and on pension year start date
          BETWEEN  GREATEST(NVL(p_start_date,g_pension_year_start_date)
                           ,g_pension_year_start_date)
              AND  LEAST(NVL(p_end_date,g_effective_run_date)
                        ,g_effective_run_date)
  ;                    -- allow all events upto end of day (eff_dt - 1)

  COMMIT;
  --
  debug(fnd_number.number_to_canonical(SQL%ROWCOUNT)||' PPE row(s) updated.');
  --
  debug_exit(l_proc_name);
  --
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END set_pay_proc_events_to_process;

--
-- set_pay_proc_events_to_process
-- Overloaded procedure, this one has an extra parameter p_element_entry_id
--
PROCEDURE set_pay_proc_events_to_process
            (p_assignment_id    IN      NUMBER
            ,p_element_entry_id IN      NUMBER
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
  -- as determined by the date range. The maxmum allowed range
  -- is the pension year start date and a day before the current eff date

  -- First update for PAY_ELEMENT_ENTRIES_F
  UPDATE pay_process_events ppe
     SET ppe.retroactive_status = p_status
        ,ppe.status             = p_status
   WHERE ppe.assignment_id = p_assignment_id
     AND ppe.change_type = 'REPORTS'
     AND ppe.effective_date -- allow all events effective as of and on pension year start date
             BETWEEN  GREATEST(NVL(p_start_date,g_pension_year_start_date)
                              ,g_pension_year_start_date)
                 AND  LEAST(NVL(p_end_date,g_effective_run_date)
                      ,g_effective_run_date)
     AND ppe.surrogate_key = p_element_entry_id
     AND EXISTS (SELECT 1
                   FROM pay_dated_tables pdt
                       ,pay_event_updates peu
                  WHERE pdt.table_name = 'PAY_ELEMENT_ENTRIES_F'
                    AND peu.dated_table_id = pdt.dated_table_id
                    AND peu.change_type = ppe.change_type
                    AND peu.event_update_id = ppe.event_update_id
                )
  ;

  debug(fnd_number.number_to_canonical(SQL%ROWCOUNT)||' PPE row(s) updated.');

  -- Now update for PAY_ELEMENT_ENTRY_VALUES_F
  UPDATE pay_process_events ppe
     SET ppe.retroactive_status = p_status
        ,ppe.status             = p_status
   WHERE ppe.assignment_id = p_assignment_id
     AND ppe.change_type = 'REPORTS'
     AND ppe.effective_date -- allow all events effective as of and on pension year start date
             BETWEEN  GREATEST(NVL(p_start_date,g_pension_year_start_date)
                              ,g_pension_year_start_date)
                 AND  LEAST(NVL(p_end_date,g_effective_run_date)
                    ,g_effective_run_date)
     AND EXISTS (SELECT 1
                   FROM pay_dated_tables pdt
                       ,pay_event_updates peu
                  WHERE pdt.table_name = 'PAY_ELEMENT_ENTRY_VALUES_F'
                    AND peu.dated_table_id = pdt.dated_table_id
                    AND peu.change_type = ppe.change_type
                    AND peu.event_update_id = ppe.event_update_id
                )
     AND EXISTS (SELECT 1
                   FROM pay_element_entry_values_f peev
                  WHERE peev.element_entry_id = p_element_entry_id
                    AND peev.element_entry_value_id = ppe.surrogate_key
                )
  ;


  COMMIT;
  --
  debug(fnd_number.number_to_canonical(SQL%ROWCOUNT)||' PPE row(s) updated.');
  --
  debug_exit(l_proc_name);
  --
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END set_pay_proc_events_to_process;

--
-- get_events
--
-- Generic function to return events found by the date track
-- interpreter for the given event group and assignment id
--
-- Bug 3015917 : Added params p_start_date and p_end_date
-- Bugfix 3073562:GAP1:GAP2 Added p_business_group_id parameter
--   This param needs to be passed only when the get_events proc
--   is called during the criteria chk process as the asg
--   collection will not hv a row for this asg id at this point.
--   For all other calls, the proc will find the bg id from
--   the global asg collection.
FUNCTION get_events(p_event_group               IN VARCHAR2
                   ,p_assignment_id             IN NUMBER
                   ,p_element_entry_id          IN NUMBER -- DEFAULT NULL
                   ,p_business_group_id         IN NUMBER -- DEFAULT NULL
                   ,p_start_date                IN DATE
                   ,p_end_date                  IN DATE
                   ,t_proration_dates           OUT NOCOPY pay_interpreter_pkg.t_proration_dates_table_type
                   ,t_proration_changes         OUT NOCOPY pay_interpreter_pkg.t_proration_type_table_type
                   ) RETURN NUMBER
IS

  -- Variable Declaration
  l_no_of_events NUMBER;

  -- Rowtype Variable Declaration
  l_event_group_details pqp_gb_tp_pension_extracts.csr_event_group_details%ROWTYPE;
  l_business_group_id   per_all_assignments_f.business_group_id%TYPE;
  l_assignment_action_id number;
  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_events';

 -- Added to pass assignment action ID for event PQP_GB_TP_GRADE_RULES(5547471)
  CURSOR c_get_aact(p_assignment_id NUMBER) IS
  SELECT assignment_action_id
  FROM pay_assignment_actions
  WHERE assignment_id = p_assignment_id
  AND rownum = 1;

BEGIN

  debug_enter(l_proc_name);

  -- Bugfix 3073562:GAP1:GAP2
  IF p_business_group_id IS NULL THEN

    -- If the asg is present in the global collections
    -- then get the bg id from there
    -- otherwise use g_business_groupd_id
    IF g_ext_asg_details.EXISTS(p_assignment_id) THEN

      -- Doing NVL for no reason, just being over cautios...
      l_business_group_id :=
                NVL(g_ext_asg_details(p_assignment_id).business_group_id
                   ,g_business_group_id
                   );
    ELSE -- does not exist
      l_business_group_id := g_business_group_id;
    END IF;

  ELSE -- Not null
    l_business_group_id := p_business_group_id;
  END IF; -- p_business_group_id IS NULL THEN

  debug('Business_group_id :'||to_char(l_business_group_id), 10);

  -- Now invoke the date track interpreter
  -- Bug 3015917 : Replaced old DTI call with this new DTI call
  IF p_event_group <> 'PQP_GB_TP_GRADE_RULES' THEN
  l_no_of_events := pqp_utilities.get_events
                     (p_assignment_id             => p_assignment_id
                     ,p_element_entry_id          => p_element_entry_id
                     ,p_business_group_id         => l_business_group_id
                     ,p_process_mode              => 'ENTRY_EFFECTIVE_DATE'
                     ,p_event_group_name          => p_event_group
                     ,p_start_date                => p_start_date
                     ,p_end_date                  => p_end_date
                     ,t_proration_dates          => t_proration_dates -- OUT
                     ,t_proration_change_type    => t_proration_changes -- OUT
                     );
   ELSE
 -- Added to pass assignment action ID for event PQP_GB_TP_GRADE_RULES(5547471)
   	  OPEN c_get_aact(p_assignment_id);
	  FETCH c_get_aact INTO l_assignment_action_id;
	  CLOSE c_get_aact;
	  l_no_of_events := pqp_utilities.get_events
			     (p_assignment_id             => p_assignment_id,
			      p_assignment_action_id      => l_assignment_action_id
			     ,p_element_entry_id          => p_element_entry_id
			     ,p_business_group_id         => l_business_group_id
			     ,p_process_mode              => 'ENTRY_EFFECTIVE_DATE'
			     ,p_event_group_name          => p_event_group
			     ,p_start_date                => p_start_date
			     ,p_end_date                  => p_end_date
			     ,t_proration_dates          => t_proration_dates -- OUT
			     ,t_proration_change_type    => t_proration_changes -- OUT
			     );
   END IF;
  debug_exit(l_proc_name);

  RETURN t_proration_dates.COUNT;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    t_proration_dates.delete;
    t_proration_changes.delete;

    RAISE;
END; -- get_events

--
-- Get the per system status from per_assignment_status_types
--
FUNCTION get_status_type
   (p_status_type_id IN NUMBER
   ) RETURN VARCHAR2
IS

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_status_type';

  CURSOR csr_status_type IS
  SELECT per_system_status
  FROM per_assignment_status_types
  WHERE assignment_status_type_id = p_status_type_id;

  l_per_system_status   per_assignment_status_types.per_system_status%TYPE;

BEGIN -- get_status_type

  debug_enter(l_proc_name);

  OPEN csr_status_type;
  FETCH csr_status_type INTO l_per_system_status;
  CLOSE csr_status_type ;

  debug('l_per_system_status :'||l_per_system_status, 10);
  debug_exit(l_proc_name);

  RETURN l_per_system_status;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- get_status_type

--
-- Check if the assignment satisfies the basic criteria
--
FUNCTION chk_has_tchr_elected_pension
  (p_business_group_id        IN      NUMBER  -- context
  ,p_effective_date           IN      DATE    -- context
  ,p_assignment_id            IN      NUMBER  -- context
  ,p_asg_details              OUT NOCOPY     csr_asg_details_up%ROWTYPE
  ,p_asg_attributes           OUT NOCOPY     csr_pqp_asg_attributes_up%ROWTYPE
  ) RETURN VARCHAR2 -- Y or N
IS

  -- Variable Declaration
  l_pension_start_date DATE := NULL;

  -- Rowtype Variable Declaration
  l_asg_details        csr_asg_details_up%ROWTYPE;
  l_pqp_asg_attributes csr_pqp_asg_attributes_up%ROWTYPE;

  -- Flag variable declaration
  l_inclusion_flag      VARCHAR2(1) := 'Y'; -- Include all Teachers
  l_quit_asg_loop       BOOLEAN := FALSE;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'chk_has_tchr_elected_pension';

BEGIN -- chk_has_tchr_elected_pension

  debug_enter(l_proc_name);

  OPEN csr_pqp_asg_attributes_up
          (p_assignment_id
          ,p_effective_date
          );
  LOOP -- Find the first effective assignment attributes in the run date range.

    FETCH csr_pqp_asg_attributes_up INTO l_pqp_asg_attributes;

    debug('Inside AAT LOOP ',20);

    IF csr_pqp_asg_attributes_up%NOTFOUND THEN
      -- aat not found, hence this assignment does not qualify

       l_inclusion_flag := 'N';
       debug('AAT Data not found',30);

    ELSIF (l_pqp_asg_attributes.effective_start_date <= g_effective_run_date
          )
          AND
          (nvl(l_pqp_asg_attributes.tp_is_teacher,'NONT')
                IN ('TCHR','TTR6')
          ) THEN
        -- Only interested in teacher aat recs effective in the run date range.

      -- Get assignment details
      OPEN csr_asg_details_up
                (p_assignment_id
                ,GREATEST(l_pqp_asg_attributes.effective_start_date
                         ,p_effective_date)
                );

      l_quit_asg_loop := FALSE;

      LOOP -- Through assignment records to check if there is an assignment
           -- record with a valid criteria establishment
           -- But make sure that the check is only for the run date range.

          debug('Inside ASG LOOP ',40);

          FETCH csr_asg_details_up INTO l_asg_details;

          IF csr_asg_details_up%NOTFOUND THEN

            l_quit_asg_loop := TRUE;
            debug('ASG Data not found',50);

          ELSE -- asg record FOUND

            -- Bugfix 3073562:GAP1:GAP2
            -- Replacing the type4 func call with the type 1 function
            l_asg_details.ext_emp_cat_cd :=
                get_translate_asg_emp_cat_code
                        (l_asg_details.asg_emp_cat_cd
                        ,GREATEST(l_pqp_asg_attributes.effective_start_date
                                 ,p_effective_date)
                        ,'Pension Extracts Employment Category Code'
                        ,l_asg_details.business_group_id
                        );

            -- Bugfix 3873376:SUSP : Suspended assignments fix
            --   We need to ignore suspended asgs to fix a bug where
            --   assignments suspended in the previous pension year
            --   are being picked up and reported
            l_asg_details.status_type := get_status_type(l_asg_details.status_type_id);

            -- If the establishment is NOT part of the criteria establishment(s)
            -- which we are reporting for, check the next record
            -- Also, if the start date is outside our date range, not look at this record.
          IF l_asg_details.start_date <= g_effective_run_date
               AND
               pqp_gb_tp_pension_extracts.g_criteria_estbs.EXISTS(l_asg_details.location_id)
               AND -- Bugfix 3873376:SUSP Ignore suspended assignments
               l_asg_details.status_type <> 'SUSP_ASSIGN'
               AND -- Bugfix 4336613 :IGNR_TERMASG_3A Ignore terminated assignments
               l_asg_details.status_type <> 'TERM_ASSIGN' THEN

            IF nvl(l_pqp_asg_attributes.tp_elected_pension,'X') = 'Y' THEN

              -- Do not exlude this assignment, get his pension start date.
              l_pension_start_date := GREATEST(l_pqp_asg_attributes.effective_start_date
                                          ,p_effective_date
                                          ,l_asg_details.start_date
                                          );
              debug('Teacher has Elected Pension',60);
              -- Teacher has elected pension,
              -- No need to check further assignments, set flag to quit the loop
              l_quit_asg_loop := TRUE;

            ELSIF nvl(l_pqp_asg_attributes.tp_elected_pension,'X') = 'N' THEN

              debug('Teacher has not Elected Pension',70);
              -- As this teacher has not elected pension, we need to
              -- do further checks before deciding on this assignment.

                -- If this estb is part of the criteria establishment(s)
                -- Then Exclude this assignment only if
                --   1) This assignment belongs to a Relief Teacher and Estb Type is Voluntary.
                --   2) This is a part-time assignment
                --   3) This is a full-time assignment and Estb Type is Voluntary.
                -- Include otherwise

                IF NOT
                   (-- To be excluded
                    pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number
                        = '0966'
                    OR
                    (l_asg_details.ext_emp_cat_cd = 'P'
                     -- Bugfix 3641851:ENH7 : Added this AND clause to INCLUDE
                     --          part-time asgs at LEA establishment only
                     AND
                     pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_type
                        <> 'LEA_ESTB'
                    )
                    OR
                    (l_asg_details.ext_emp_cat_cd = 'F'
                     AND
                     pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_type
                        = 'IND_ESTB'
                    )
                   ) THEN

                  -- Do not exluce this assignment, get his pension start date.
                  l_pension_start_date := GREATEST(l_pqp_asg_attributes.effective_start_date
                                              ,p_effective_date
                                              ,l_asg_details.start_date
                                              );

                  debug('Teacher has not Elected Pension, but passes validation',80);
                  -- Teacher has elected pension, but passes other validation
                  -- No need to check further assignments, set flag to quit the loop
                l_quit_asg_loop := TRUE;

                END IF; -- NOT...
              --
            ELSIF l_pqp_asg_attributes.tp_elected_pension IS NULL THEN

              -- Check the next aat record, might be a valid one
              -- But first, exit the asg loop
              l_quit_asg_loop := TRUE;
              debug('Elected pension flag is NULL for this teacher',90);

            END IF; -- nvl(l_pqp_asg_attributes.tp_elected_pension,'N') = 'N' THEN
            --
          END IF; -- l_asg_details.start_date <= g_effective_run_date
          --
        END IF; -- csr_asg_details_up%NOTFOUND THEN
        --
        IF l_quit_asg_loop THEN

          debug('Quitting ASG Loop',100);
          EXIT;

        END IF;
        --
      END LOOP; -- Through assignment records to check if there is an assignment

      CLOSE csr_asg_details_up;
      debug('Pension Start Date :'||to_char(l_pension_start_date,'DD/MM/YYYY'),110);

    --ELSE -- csr_pqp_asg_attributes%NOTFOUND THEN
    --
    -- -- Either the aat record is with a start date higher than the date range
    -- -- or not a teaching record.
    -- -- We are not interested in this record
    -- -- Look at further records

    END IF; -- csr_pqp_asg_attributes%NOTFOUND THEN

    -- We do not need to look at the next record if this aat record qualifies.
    IF (l_pension_start_date is not null
          AND
          l_inclusion_flag = 'Y'
         )
         OR
         l_inclusion_flag = 'N'
         THEN

         -- Assign the pension start date to start date in asg record variable
         -- PS : If the original assignment start date is needed elsewhere, we might
         --      need to create a new column in the assignment or aat collection
         --      to hold the pension start date of the assignment.
         l_asg_details.start_date := l_pension_start_date;
         -- Bugfix 3641851:CBF1 : Assigning pension start date to teacher start date
         l_asg_details.teacher_start_date := l_pension_start_date;

         debug('Quitting AAT LOOP',120);
         EXIT;

    END IF; -- (l_pension_start_date is not null..

  END LOOP; -- Find the first effective assignment attributes in the run date range.

  CLOSE csr_pqp_asg_attributes_up;

  -- At this point,
  -- IF l_pension_start_date is not null and l_inclusion_flag = 'Y' THEN
  -- 1) the rowtype variable l_pqp_asg_attributes contains a valid EFFECTIVE aat row
  -- 2) the rowtype variable l_asg_details contains a valid EFFECTIVE asg row
  -- 3) the variable l_pension_start_date contains the start date which should be on
  --    the report. This has already been assigned to start date in l_asg_details.
  --
  -- These can be be passed back to the calling point
  -- Assign the local record variable to the return variables
  p_asg_details         := l_asg_details;
  p_asg_attributes      := l_pqp_asg_attributes;

  debug('Is this teacher being included by Basic Criteria ? '||l_inclusion_flag,130);

  debug_exit(l_proc_name);
  RETURN l_inclusion_flag;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    p_asg_details     := NULL;
    p_asg_attributes  := NULL;
    RAISE;
END; -- chk_has_tchr_elected_pension

--
-- Check if the teacher's is a leaver
--
FUNCTION chk_is_teacher_a_leaver
  (p_business_group_id        IN      NUMBER
  ,p_effective_start_date     IN      DATE
  ,p_effective_end_date       IN      DATE
  ,p_assignment_id            IN      NUMBER
  ,p_leaver_date              OUT NOCOPY      DATE
  ) RETURN VARCHAR2 -- Y or N
IS

  -- Variable Declaration
  l_leaver              VARCHAR2(1) := 'N';
  l_leaver_date         DATE;
  l_itr                 NUMBER;
  l_no_of_events        NUMBER(5);
  l_inclusion_flag      VARCHAR2(1) := 'Y';
  l_new_event_itr       NUMBER(5);

  -- Rowtype Variable Declaration
  l_event_group_details pqp_gb_tp_pension_extracts.csr_event_group_details%ROWTYPE;
  l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
  l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
  l_asg_details         csr_asg_details_up%ROWTYPE;
  l_prev_asg_details    csr_asg_details_up%ROWTYPE;
  l_next_asg_details    csr_asg_details_up%ROWTYPE;
  l_pqp_asg_attributes       pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%ROWTYPE;
  l_last_pqp_asg_attributes  pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%ROWTYPE;

  l_temp_asg_details    csr_asg_details_up%ROWTYPE;
  l_temp_aat_details    csr_pqp_asg_attributes_up%ROWTYPE;

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_is_teacher_a_leaver';

BEGIN -- chk_is_teacher_a_leaver

  debug_enter(l_proc_name);
  debug('p_effective_start_date: '||to_char(p_effective_start_date), 1) ;
  debug('p_effective_end_date: '||to_char(p_effective_end_date), 1) ;

  -- Update the events in pay_process_events to 'P' for "in process".
  -- Bug 3015917 : Removed set_pay_process.. as we now use the new style DTI

  -- Check for following leaver events here :
  -- Even if a leaver event is found, continue looking for more leaver evnts
  -- as we want the EARLIEST date of any of the leaver events
  --   1) Assignment Status change
  --   2) Location change resulting in change in Establishment from
  --            a) LEA estb to Non-LEA estb
  --            b) Non-LEA estb to LEA estb
  --            c) Non-LEA estb to Non-LEA estb
  --   3) Change in Elected pension flag resulting in the flag changing from 'Y' to 'N'
  --   4) Change in Teacher Status such that the status changes from
  --            'TCHR'/'TTR6' to 'NONT' / 'NULL'.(PS : NULL sh not be possible)

  -- 1) Assignment Status change

  -- Now invoke the date track interpreter
  -- Bug 3015917 : Replaced old DTI call with new style DTI call
  l_no_of_events := get_events(p_event_group            => 'PQP_GB_TP_ASG_STATUS'
                              ,p_assignment_id          => p_assignment_id
                              ,p_business_group_id      => p_business_group_id
                              ,p_start_date             => p_effective_start_date
                              ,p_end_date               => p_effective_end_date
                              ,t_proration_dates        => l_proration_dates   -- OUT
                              ,t_proration_changes      => l_proration_changes -- OUT
                              );

  debug('Number of ASG_STATUS Events: '||
      fnd_number.number_to_canonical(l_no_of_events));

  l_itr := l_proration_dates.FIRST;

  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through the dates when some status change event happened

    debug('Inside ASG Dates LOOP',20);
    --
    -- eliminate duplicate dates
    -- compare the last value to the current one
    -- always process the first date
    IF l_itr = l_proration_dates.FIRST
       OR
       ( l_proration_dates(l_itr) <>
         l_proration_dates(l_proration_dates.PRIOR(l_itr))
       ) THEN

      debug('Event date  :'||to_char(l_proration_dates(l_itr),'DD/MM/YYYY'), 25);
      debug('Update Type :'||l_proration_changes(l_itr), 26);
      debug('l_proration_dates(l_itr) - 1 :' ||to_char(l_proration_dates(l_itr) - 1),27);


      -- IMP : Changing to date - 1 as part of bugfix for end employment not begin picked up
      OPEN csr_asg_details_up
        (p_assignment_id
        ,l_proration_dates(l_itr) - 1
        );
      FETCH csr_asg_details_up INTO l_asg_details;

      IF csr_asg_details_up%FOUND THEN

        debug('Inside IF , found ASG record',30);
        -- Get the per_system_status for the assignment_status_type_id
        l_asg_details.status_type := get_status_type(l_asg_details.status_type_id);

        -- Get the next assignment and compare status type
        FETCH csr_asg_details_up INTO l_next_asg_details;
        l_next_asg_details.status_type := get_status_type(l_next_asg_details.status_type_id);

        debug('After second fetch',40);
        IF (csr_asg_details_up%FOUND
            AND
            l_asg_details.status_type <> l_next_asg_details.status_type
            AND
            l_next_asg_details.status_type IN ('TERM_ASSIGN','SUSP_ASSIGN','END')
            -- LVRDATE changes
            -- checking the assignment start date
            -- it should start on or before the period end date.
            AND
            l_next_asg_details.start_date <= p_effective_end_date
           )
           OR
           -- No future rows found
           (csr_asg_details_up%NOTFOUND
            AND
            -- But the current assignment has been suspended or is Active
            -- Added Active as a bugfix as END Employment does not change status
            -- when the termination happens on the last day of the payroll period
            l_asg_details.status_type IN ('SUSP_ASSIGN','ACTIVE_ASSIGN')
            -- Bugfix 3641851:CBF2 : Added this AND Clause
            --   We need to ensure that end date of asg record is <= end
            --   date of the period v r chking for. Ideally, DTI should
            --   not return a date if its outside our range, but a
            --   (potential) bug in DTI is causing such a situation and
            --   this check is a safety net, just in case.
            AND
            l_asg_details.effective_end_date <= p_effective_end_date
           )
           THEN

          -- Assignment has been terminated/suspended/ended
          l_leaver := 'Y';
          l_leaver_date := l_asg_details.effective_end_date;

          debug('Assignment is a leaver, Quitting LOOP ',50);

          --TERM_LSP: BUG: 4135481
          -- Store the assignement status change event as a new line of service event

          l_new_event_itr := g_asg_events.COUNT+1;
          debug('l_new_event_itr = '|| to_char(l_new_event_itr),55);
          debug('event_date: '|| to_char(l_proration_dates(l_itr)),56) ;
          debug('l_leaver_date: '|| to_char(l_leaver_date),57) ;

          g_asg_events(l_new_event_itr).event_date        := l_leaver_date;
          g_asg_events(l_new_event_itr).event_type        := 'PQP_GB_TP_ASG_STATUS';
          g_asg_events(l_new_event_itr).assignment_id     := p_assignment_id;




          CLOSE csr_asg_details_up;
          EXIT;
          --
        END IF; -- l_asg_details.status_type <> l_next_asg_details.status_type...

      END IF; -- csr_asg_details_up%FOUND THEN
      --
      CLOSE csr_asg_details_up;

    END IF; -- if this date <> last date, to eliminate duplicates
    --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through the dates when some status change event happened

  l_proration_dates.DELETE;
  l_proration_changes.DELETE;

  l_asg_details         := NULL;
  l_next_asg_details    := NULL;

  debug('After Assignment Status Events check - Deleted Proration Dates',60);

  -- Check for the next set of events which qualify an assignment as leaver.
  --   2) Location change resulting in change in Establishment
  --            a) LEA estb to Non-LEA estb
  --            b) Non-LEA estb to LEA estb
  --            c) Non-LEA estb to Non-LEA estb
  debug('Now Checking for location change',70);

  -- Bug 3015917 : Replaced old DTI call with new style DTI call
  l_no_of_events := 0;
  l_no_of_events := get_events(p_event_group            => 'PQP_GB_TP_ASG_LOCATION'
                              ,p_assignment_id          => p_assignment_id
                              ,p_business_group_id      => p_business_group_id
                              ,p_start_date             => p_effective_start_date
                              ,p_end_date               => p_effective_end_date
                              ,t_proration_dates        => l_proration_dates   -- OUT
                              ,t_proration_changes      => l_proration_changes -- OUT
                              );


  debug('Number of ASG_LOCATION Events: '||
   fnd_number.number_to_canonical(l_no_of_events));

  l_itr := l_proration_dates.FIRST;
  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through location change proration dates

    -- a location change event did take place, correction or update
    -- loop thru all the dates
    -- and query asg for location value
    -- check if location is a criteria location
    -- if so flag location changed and store teacher start date
    -- and exit else continue

    debug('Inside LOC events loop, Location change event found',80);

    --
    -- eliminate duplicate dates
    -- compare the last value to the current one
    -- always process the first date
    IF l_itr = l_proration_dates.FIRST
       OR
        ( l_proration_dates(l_itr) <>
          l_proration_dates(l_proration_dates.PRIOR(l_itr))
        )
       -- Bugfix 3470242:BUG3 : Need to make sure that we chk the next
       --        event just in case correction was returned b4 update
       OR
        (l_proration_changes(l_itr) <>
         l_proration_changes(l_proration_changes.PRIOR(l_itr))
        )
       THEN

      debug('Event date  :'||to_char(l_proration_dates(l_itr),'DD/MM/YYYY'), 85);
      debug('Update Type :'||l_proration_changes(l_itr), 86);

      OPEN csr_asg_details_dn
          (p_assignment_id
          ,l_proration_dates(l_itr)
          );
      FETCH csr_asg_details_dn INTO l_asg_details;

      debug('Inside IF, After first fetch',90);

      IF (
          (csr_asg_details_dn%FOUND
           AND
           l_proration_changes(l_itr) = 'C' -- Correction
           AND -- asg start date > pension start date
               -- this is coz we don't want to pick an asg where
               -- the pension has started on that day.
               -- I.e. The correction sh have happened in the current pension year
           (l_asg_details.start_date >
              p_effective_start_date
                -- g_ext_asg_details(p_assignment_id).start_date
            AND -- the start dat eof the asg record is <= effective run date
            l_asg_details.start_date <= p_effective_end_date
            -- l_asg_details.start_date <= g_effective_run_date
           )
          )

          OR

          (csr_asg_details_dn%FOUND
           AND
           l_proration_changes(l_itr) = 'U' -- Update
          )
         ) THEN

        -- Get the previous assignment record
        -- Currently not needed, will uncomment if needed
        --FETCH csr_asg_details_dn INTO l_prev_asg_details;

        debug('Event worth considering',100);

        --  Check if the locaiton change is a valid one to report as leaver
        -- The new establishment is not a criteria establishment
        IF NOT pqp_gb_tp_pension_extracts.g_criteria_estbs.EXISTS(l_asg_details.location_id) THEN

          -- The assignment has had a location change such that it has become a leaver
          l_leaver := 'Y';
          l_leaver_date := LEAST((l_asg_details.start_date - 1)
                                ,nvl(l_leaver_date
                                    ,(l_asg_details.start_date - 1)
                                    )
                                );

          debug('Leaver date  :'||to_char(l_leaver_date,'DD/MM/YYYY'), 105);
          debug('Assignment is a leaver due to location change, Quitting loop',110);

          CLOSE csr_asg_details_dn;
          EXIT;

        ELSE -- Location change is not a leaver event

          -- Bugfix 3073562:GAP10
          -- But as the location has changed form LEA Estb to
          -- another LEA Estb this is a new line of service event,
          -- store the event in the global collection.

          -- Get the previous assignment record
          FETCH csr_asg_details_dn INTO l_prev_asg_details;

          debug(l_proc_name, 120);

          IF l_proration_changes(l_itr) = 'U' -- Event was an update
             AND
             -- Prev rec was found. Redundant chk, sh always b found
             csr_asg_details_dn%FOUND
             AND
             -- Bugfix 3641851:CBF4 : Added just to avoid exception
             l_prev_asg_details.location_id IS NOT NULL
             AND
             -- The current and new Establishment nos. are different
             -- This chk is to ensure that the current location
             -- was not corrected after doing a datetrack update
             (-- Bugfix 3641851:CBF4 : Added EXISTS just to avoid exception
              pqp_gb_tp_pension_extracts.g_criteria_estbs.EXISTS(l_prev_asg_details.location_id)
              AND
              pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number
              <>
              pqp_gb_tp_pension_extracts.g_criteria_estbs(l_prev_asg_details.location_id).estb_number
             ) THEN

            debug('Location change is a new line of service event, storing', 130);

            l_new_event_itr := g_asg_events.COUNT+1;

            -- Store the location change event as a new line of service event
            g_asg_events(l_new_event_itr).event_date        := l_proration_dates(l_itr);
            g_asg_events(l_new_event_itr).event_type        := 'PQP_GB_TP_ASG_LOCATION';
            g_asg_events(l_new_event_itr).assignment_id     := p_assignment_id;

            -- Bugfix 3470242:BUG1 : Now using new_location_id, estb_number can
            --     always be sought using the location id
            --g_asg_events(l_new_event_itr).new_estb_number   :=
            --  pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number;
            g_asg_events(l_new_event_itr).new_location_id := l_asg_details.location_id;

            debug('New Location Id  :'||to_char(l_asg_details.location_id), 135);

          END IF; -- l_proration_changes(l_itr) = 'U'
          --
        END IF; -- Check if the locaiton change is a valid one to report as leaver
        --
      END IF; -- csr_asg_details_dn%FOUND THEN
      --
      CLOSE csr_asg_details_dn;
      --
    END IF; -- if this date <> last date to eliminate duplicates
    --
    l_itr := l_proration_dates.NEXT(l_itr);

    l_asg_details := NULL;
    l_prev_asg_details := NULL;
    --
  END LOOP; -- through location change proration dates

  l_proration_dates.DELETE;
  l_proration_changes.DELETE;

  debug('After Location Change check - Deleted Proration Dates',140);

  -- Check for the next set of events which qualify an assignment as leaver.
  --   3) Change in Elected pension flag resulting in the flag changing from 'Y' to 'N'

  -- Get the events
  l_no_of_events := 0;
  l_no_of_events := get_events(p_event_group            => 'PQP_GB_TP_ELECTED_PENSION'
                              ,p_assignment_id          => p_assignment_id
                              ,p_business_group_id      => p_business_group_id
                              ,p_start_date             => p_effective_start_date
                              ,p_end_date               => p_effective_end_date
                              ,t_proration_dates        => l_proration_dates -- OUT
                              ,t_proration_changes      => l_proration_changes -- OUT
                              );

  debug('Number of '||'PQP_GB_TP_ELECTED_PENSION'||' Events: '||
     fnd_number.number_to_canonical(l_no_of_events), 150);

  -- b) Loop through the events and check if any have changed.
  l_itr := l_proration_dates.FIRST;
  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through change proration dates

    IF l_itr = l_proration_dates.FIRST
       OR
       ( l_proration_dates(l_itr) <>
         l_proration_dates(l_proration_dates.PRIOR(l_itr))
       ) THEN

      debug('Inside IF for Elected pension changes check',160);
      debug('Event date  :'||to_char(l_proration_dates(l_itr),'DD/MM/YYYY'), 165);
      debug('Update Type :'||l_proration_changes(l_itr), 166);

      OPEN pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn
                        (p_assignment_id
                        ,l_proration_dates(l_itr)
                        );
      FETCH pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn INTO l_pqp_asg_attributes;
      --
      IF pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
         AND
         NVL(l_pqp_asg_attributes.tp_elected_pension,'N') = 'N' THEN

        -- Fetch the previous set of attributes
        FETCH pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn INTO l_last_pqp_asg_attributes;
        --
        IF pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
           AND
           nvl(l_last_pqp_asg_attributes.tp_elected_pension,'N') = 'Y' THEN

          debug('B4 checking if asg passes chk_has_tchr_elected_pension',170);

          -- Pension flag has changed to 'N', but check if this change to 'N'
          -- qualifies as leaver event. If the assignment satisfies the
          -- chk_has_teacher_elected_pension on this event date
          -- then the assignment is not a leaver, else, the assignment is a leaver
          l_inclusion_flag := chk_has_tchr_elected_pension
                                (p_business_group_id            => p_business_group_id
                                ,p_effective_date               => l_proration_dates(l_itr)
                                ,p_assignment_id                => p_assignment_id
                                ,p_asg_details                  => l_temp_asg_details   -- OUT
                                ,p_asg_attributes               => l_temp_aat_details -- OUT
                                );

          IF l_inclusion_flag = 'N'
             -- BUGFIX 2414035 : Added the following condition to fix this bug
             OR
             (l_inclusion_flag = 'Y' -- Has again become eligible in this pension year
              AND --  but on a future date
              l_temp_asg_details.start_date > l_proration_dates(l_itr)
             ) THEN

            debug('This assignment HAS opted out nocopy of the pension scheme.',180);

            l_leaver := 'Y';
            l_leaver_date := LEAST((l_pqp_asg_attributes.effective_start_date - 1)
                                  ,nvl(l_leaver_date
                                      ,(l_pqp_asg_attributes.effective_start_date - 1)
                                      )
                                  );
            debug('Leaver Date :'||to_char(l_leaver_date,'DD/MM/YYYY'), 185);

            CLOSE pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn;
            EXIT; -- quit loop -- no need to search for other events

          END IF; -- l_inclusion_flag = 'N' THEN
        --
        END IF; -- 2 pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
      --
      END IF; -- 1 pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
      --
      CLOSE pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn;
      --
      debug('Assignment attributes have had changes',190);
      --
    END IF; -- if this date <> last date to eliminate duplicates
    --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through elected pension change proration dates

  l_proration_dates.DELETE;
  l_proration_changes.DELETE;

  l_pqp_asg_attributes := NULL;
  l_last_pqp_asg_attributes := NULL;

  debug('After Elected Pension Flag change check - Deleted Proration Dates',200);

  -- Check for the next set of events which qualify an assignment as leaver.
  --   4) Change in Teacher Status such that the status changes from
  --            'TCHR'/'TTR6' to 'NONT' / 'NULL'.(PS : NULL sh not be possible)

  -- Get the events
  l_no_of_events := 0;
  l_no_of_events := get_events(p_event_group            => 'PQP_GB_TP_IS_TEACHER'
                              ,p_assignment_id          => p_assignment_id
                              ,p_business_group_id      => p_business_group_id
                              ,p_start_date             => p_effective_start_date
                              ,p_end_date               => p_effective_end_date
                              ,t_proration_dates        => l_proration_dates -- OUT
                              ,t_proration_changes      => l_proration_changes -- OUT
                              );

  debug('Number of '||'PQP_GB_TP_IS_TEACHER'||' Events: '||
     fnd_number.number_to_canonical(l_no_of_events),210);

  -- b) Loop through the events and check if any have changed.
  l_itr := l_proration_dates.FIRST;
  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through change proration dates

    IF (l_itr = l_proration_dates.FIRST
        OR
        ( l_proration_dates(l_itr) <>
          l_proration_dates(l_proration_dates.PRIOR(l_itr))
        )
       )
       AND
       (l_proration_changes(l_itr) <> 'C' -- Not a Correction
       ) THEN

      debug('Event date  :'||to_char(l_proration_dates(l_itr),'DD/MM/YYYY'), 215);
      debug('Update Type :'||l_proration_changes(l_itr), 216);

      OPEN pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn
                        (p_assignment_id
                        ,l_proration_dates(l_itr)
                        );
      FETCH pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn INTO l_pqp_asg_attributes;
      --
      IF pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
         AND
         NVL(l_pqp_asg_attributes.tp_is_teacher,'NONT') = 'NONT' THEN

        -- Fetch the previous set of attributes
        FETCH pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn INTO l_last_pqp_asg_attributes;
        --
        IF pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
           AND
           nvl(l_last_pqp_asg_attributes.tp_is_teacher,'NONT') IN ('TCHR','TTR6') THEN

          debug('This assignment HAS become a Non-Teacher.',220);

          l_leaver := 'Y';
          l_leaver_date := LEAST((l_pqp_asg_attributes.effective_start_date - 1)
                                  ,nvl(l_leaver_date
                                      ,(l_pqp_asg_attributes.effective_start_date - 1)
                                      )
                                );
          debug('Leaver Date :'||to_char(l_leaver_date,'DD/MM/YYYY'), 225);

          CLOSE pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn;
          EXIT; -- quit loop -- no need to search for other events
          --
        END IF; -- 2 pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
      --
      END IF; -- 1 pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
      --
      CLOSE pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn;
      --
      debug('Assignment attributes have had changes',230);
      --
    END IF; -- if this date <> last date to eliminate duplicates and ignore corrections
    --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through elected pension change proration dates

  debug('After Teacher Status change check',240);

  -- Reset the events in pay_process_events to 'U' for "Unprocessed".
  -- Bug 3015917 : Removed set_pay_process.. as we now use the new style DTI

  l_proration_dates.DELETE;
  l_proration_changes.DELETE;

  debug('Leaver Flag :'||l_leaver,250);
  debug('Leaver Date :'||to_char(l_leaver_date,'dd/mm/yyyy'),260);

  -- Assign the leaver date value to the return parameter
  p_leaver_date := l_leaver_date;

  debug_exit(l_proc_name);
  RETURN l_leaver;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    p_leaver_date := NULL;
    RAISE;
END; -- chk_is_teacher_a_leaver

--
-- Check if the leaver teacher is also a re-starter
--
FUNCTION chk_is_leaver_a_restarter
  (p_business_group_id        IN      NUMBER
  ,p_effective_start_date     IN      DATE
  ,p_effective_end_date       IN      DATE
  ,p_assignment_id            IN      NUMBER
  ,p_restarter_date           OUT     NOCOPY  DATE
  ) RETURN VARCHAR2 -- Y or N
IS

  -- Variable Declaration
  l_restarter           VARCHAR2(1) := 'N';
  l_restarter_date      DATE;
  l_itr                 NUMBER;
  l_no_of_events        NUMBER(5);
  l_inclusion_flag      VARCHAR2(1) := 'N';

  -- Rowtype Variable Declaration
  l_event_group_details pqp_gb_tp_pension_extracts.csr_event_group_details%ROWTYPE;
  l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
  l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
  l_asg_details         csr_asg_details_up%ROWTYPE;
  l_prev_asg_details    csr_asg_details_up%ROWTYPE;
  l_pqp_asg_attributes       pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%ROWTYPE;
  l_last_pqp_asg_attributes  pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%ROWTYPE;

  l_temp_asg_details    csr_asg_details_up%ROWTYPE;
  l_temp_aat_details    csr_pqp_asg_attributes_up%ROWTYPE;

  -- BUG : 3873376
  --RSTRT: new variables added
  l_asg_details_restart         csr_asg_details_up%ROWTYPE;
  l_pqp_asg_attributes_restart  csr_pqp_asg_attributes_up%ROWTYPE;

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_is_leaver_a_restarter';

BEGIN -- chk_is_leaver_a_restarter

  debug_enter(l_proc_name);
  debug('p_effective_start_date '||p_effective_start_date);
  debug('p_effective_end_date '||p_effective_end_date);

  -- Update the events in pay_process_events to 'P' for "in process".
  -- Bug 3015917 : Removed set_pay_process.. as we now use the new style DTI

  -- Check for following restarter events here :
  -- Even if a restarter event is found, continue looking for more restarter events
  -- as we want the EARLIEST date of any of the restarter events
  --   1) Assignment Status change, back to ACTIVE from SUSPENDED ONLY
  --   2) Location change resulting in change in Establishment from
  --            a) LEA estb to Non-LEA estb
  --            b) Non-LEA estb to LEA estb
  --            c) Non-LEA estb to Non-LEA estb
  --   3) Change in Elected pension flag resulting in the flag changing from 'N' to 'Y'
  --   4) Change in Teacher Status such that the status changes from
  --            'NONT' / 'NULL' to 'TCHR'/'TTR6'


  --   1) Assignment Status change, back to ACTIVE from SUSPENDED ONLY
  -- Get the events
  l_no_of_events := get_events(p_event_group            => 'PQP_GB_TP_ASG_STATUS'
                              ,p_assignment_id          => p_assignment_id
                              ,p_business_group_id      => p_business_group_id
                              ,p_start_date             => p_effective_start_date
                              ,p_end_date               => p_effective_end_date
                              ,t_proration_dates        => l_proration_dates -- OUT
                              ,t_proration_changes      => l_proration_changes -- OUT
                              );

  debug('Number of ASG_STATUS Events: '||
      fnd_number.number_to_canonical(l_proration_dates.COUNT));

  l_itr := l_proration_dates.FIRST;

  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through the dates when some status change event happened

    debug('Inside ASG Dates LOOP',20);
    --
    -- eliminate duplicate dates
    -- compare the last value to the current one
    -- always process the first date
    IF l_itr = l_proration_dates.FIRST
       OR
       ( l_proration_dates(l_itr) <>
         l_proration_dates(l_proration_dates.PRIOR(l_itr))
       ) THEN

      OPEN csr_asg_details_dn
        (p_assignment_id
        ,l_proration_dates(l_itr)
        );
      FETCH csr_asg_details_dn INTO l_asg_details;

      IF csr_asg_details_dn%FOUND THEN

        debug('Inside IF , found ASG record',30);
        -- Get the per_system_status for the assignment_status_type_id
        l_asg_details.status_type := get_status_type(l_asg_details.status_type_id);

        -- Get the previous assignment and compare status type
        FETCH csr_asg_details_dn INTO l_prev_asg_details;
        l_prev_asg_details.status_type := get_status_type(l_prev_asg_details.status_type_id);

        debug('After second fetch',40);
        debug('l_asg_details.location_id '||l_asg_details.location_id,41);

        IF (csr_asg_details_dn%FOUND
            AND
            l_prev_asg_details.status_type = 'SUSP_ASSIGN'
            AND
            l_asg_details.status_type = 'ACTIVE_ASSIGN'
            -- check if the location is a valid location
            AND
            pqp_gb_tp_pension_extracts.g_criteria_estbs.EXISTS(l_asg_details.location_id)
           ) THEN

          debug('now checking chk_has_tchr_elected_pension',42);
          -- BUG : 3873376
          --:RSTRT --check if the asg is a valid tchr assignment on restart date.
          l_inclusion_flag := chk_has_tchr_elected_pension
                                (p_business_group_id => p_business_group_id
                                ,p_effective_date    => l_asg_details.start_date
                                ,p_assignment_id     => p_assignment_id
                                ,p_asg_details       => l_asg_details_restart        -- OUT
                                ,p_asg_attributes    => l_pqp_asg_attributes_restart -- OUT
                                );
          debug('l_inclusion_flag :' ||l_inclusion_flag,43);
          debug('l_asg_details_restart.start_date :'||l_asg_details_restart.start_date);

          IF l_inclusion_flag = 'Y'
             -- Valid tchr on the same date as of restart_date and not in future.
             -- future events will be taken care of in the other events check
             AND NOT(l_asg_details_restart.start_date > l_asg_details.start_date)
          THEN
            -- Assignment has been restarted
            l_restarter := 'Y';
            l_restarter_date := l_asg_details.start_date;

            debug('Assignment is a restarter, Quitting LOOP ',50);
            CLOSE csr_asg_details_dn;
            EXIT;
            --
          END IF; --l_inclusion_flag = 'Y' THEN

        END IF; -- FOUND and previous status = 'SUSP_ASSIGN' and current status = 'ACTIVE_ASSIGN'
        --
      END IF; -- csr_asg_details_dn%FOUND THEN
      --
      CLOSE csr_asg_details_dn;

    END IF; -- if this date <> last date, to eliminate duplicates
    --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through the dates when some status change event happened

  l_proration_dates.DELETE;
  l_proration_changes.DELETE;

  l_asg_details         := NULL;
  l_prev_asg_details    := NULL;

  l_asg_details_restart        := NULL;
  l_pqp_asg_attributes_restart := NULL ;

  debug('After Assignment Status Events check - Deleted Proration Dates',60);

  -- Check for the next set of events which qualify an assignment as restarter.
  --   2) Location change resulting in change in Establishment
  --            a) LEA estb to Non-LEA estb
  --            b) Non-LEA estb to LEA estb
  --            c) Non-LEA estb to Non-LEA estb
  debug('Now Checking for location change',70);

  -- Get the events
  l_no_of_events := get_events(p_event_group            => 'PQP_GB_TP_ASG_LOCATION'
                              ,p_assignment_id          => p_assignment_id
                              ,p_business_group_id      => p_business_group_id
                              ,p_start_date             => p_effective_start_date
                              ,p_end_date               => p_effective_end_date
                              ,t_proration_dates        => l_proration_dates -- OUT
                              ,t_proration_changes      => l_proration_changes -- OUT
                              );

  debug('Number of ASG_LOCATION Events: '||
   fnd_number.number_to_canonical(l_proration_dates.COUNT));

  l_itr := l_proration_dates.FIRST;
  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through location change proration dates

    -- a location change event did take place, correction or update
    -- PS : Currently ignoring corrections, but if later there is a
    --      need to include corrections then
    --      ONLY include if asg start date is > p_effective_start_date
    --      coz if the asg start date is = p_effective_date then the
    --      asg will mostly not be reported as a leaver in the first place
    -- loop thru all the dates
    -- and query asg for location value
    -- check if location is a criteria location
    -- also confirm that the previous location was a non criteria location
    -- if so flag location changed and store teacher start date
    -- and exit else continue

    debug('Inside LOC events loop, Location change event found',80);

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

      OPEN csr_asg_details_dn
          (p_assignment_id
          ,l_proration_dates(l_itr)
          );
      FETCH csr_asg_details_dn INTO l_asg_details;

      debug('Inside IF, After first fetch',90);

      IF (csr_asg_details_dn%FOUND
          AND
          l_proration_changes(l_itr) <> 'C' -- Not a Correction
         ) THEN

        -- Get the previous assignment record
        FETCH csr_asg_details_dn INTO l_prev_asg_details;

        debug('Event worth considering',100);

        --  Check if the locaiton change is a valid one to report as restarter
        -- The new establishment must be a criteria establishment
        -- and the previous establishment must not be a criteria establishment
        IF (csr_asg_details_dn%FOUND
            AND -- the new asg location is a criteria location
            pqp_gb_tp_pension_extracts.g_criteria_estbs.EXISTS(l_asg_details.location_id)
            AND -- the previous was not a criteria location
            (NOT pqp_gb_tp_pension_extracts.g_criteria_estbs.EXISTS(l_prev_asg_details.location_id)
            )
           ) THEN
          debug('now checking chk_has_tchr_elected_pension',101);
          -- BUG : 3873376
          --:RSTRT --check if the asg is a valid tchr assignment on restart date.
          l_inclusion_flag := chk_has_tchr_elected_pension
                                (p_business_group_id => p_business_group_id
                                ,p_effective_date    => l_asg_details.start_date
                                ,p_assignment_id     => p_assignment_id
                                ,p_asg_details       => l_asg_details_restart        -- OUT
                                ,p_asg_attributes    => l_pqp_asg_attributes_restart -- OUT
                                );
          debug('l_inclusion_flag :' ||l_inclusion_flag,102);
          debug('l_asg_details_restart.start_date :' ||l_asg_details_restart.start_date);

          IF l_inclusion_flag = 'Y'
             -- Valid tchr on the same dateas the restart_Date, not in future.
             -- future events will be taken care of in the other events check
             AND NOT(l_asg_details_restart.start_date > l_asg_details.start_date)THEN
            -- The assignment has had a location change such that it has become a restarter
            l_restarter := 'Y';
            l_restarter_date := LEAST(l_asg_details.start_date
                                     ,nvl(l_restarter_date,l_asg_details.start_date)
                                     );

            debug('Assignment is a restarter due to location change, Quitting loop',110);

            CLOSE csr_asg_details_dn;
            EXIT;
          END IF ; --l_inclusion_flag = 'Y'

        END IF; -- Check if the locaiton change is a valid one to report as restarter
        --
      END IF; -- csr_asg_details_dn%FOUND THEN
      --
      CLOSE csr_asg_details_dn;
      --
    END IF; -- if this date <> last date to eliminate duplicates
    --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through location change proration dates

  l_proration_dates.DELETE;
  l_proration_changes.DELETE;

  l_asg_details_restart        := NULL;
  l_pqp_asg_attributes_restart := NULL ;


  debug('After Location Change check - Deleted Proration Dates',120);

  -- Check for the next set of events which qualify an assignment as restarter.
  --   3) Change in Elected pension flag resulting in the flag changing from 'N' to 'Y'

  -- Get the events
  l_no_of_events := 0;
  l_no_of_events := get_events(p_event_group            => 'PQP_GB_TP_ELECTED_PENSION'
                              ,p_assignment_id          => p_assignment_id
                              ,p_business_group_id      => p_business_group_id
                              ,p_start_date             => p_effective_start_date
                              ,p_end_date               => p_effective_end_date
                              ,t_proration_dates        => l_proration_dates -- OUT
                              ,t_proration_changes      => l_proration_changes -- OUT
                              );

  debug('Number of '||'PQP_GB_TP_ELECTED_PENSION'||' Events: '||
     fnd_number.number_to_canonical(l_no_of_events));

  -- b) Loop through the events and check if any have changed.
  l_itr := l_proration_dates.FIRST;
  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through change proration dates

    IF l_itr = l_proration_dates.FIRST
       OR
       ( l_proration_dates(l_itr) <>
         l_proration_dates(l_proration_dates.PRIOR(l_itr))
       ) THEN

      OPEN pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn
                        (p_assignment_id
                        ,l_proration_dates(l_itr)
                        );
      FETCH pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn INTO l_pqp_asg_attributes;
      --
      IF pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
         AND
         NVL(l_pqp_asg_attributes.tp_elected_pension,'N') = 'Y' THEN

        -- Fetch the previous set of attributes
        FETCH pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn INTO l_last_pqp_asg_attributes;
        --
        IF pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
           AND
           nvl(l_last_pqp_asg_attributes.tp_elected_pension,'N') = 'N' THEN

          debug('now checking chk_has_tchr_elected_pension',121);
          -- BUG : 3873376
          --:RSTRT --check if the asg is a valid tchr assignment on restart date.
          l_inclusion_flag := chk_has_tchr_elected_pension
                                (p_business_group_id => p_business_group_id
                                ,p_effective_date    => l_pqp_asg_attributes.effective_start_date
                                ,p_assignment_id     => p_assignment_id
                                ,p_asg_details       => l_asg_details_restart        -- OUT
                                ,p_asg_attributes    => l_pqp_asg_attributes_restart -- OUT
                                );
          debug('l_inclusion_flag :' ||l_inclusion_flag,122);
          debug('l_asg_details_restart.start_date :' ||l_asg_details_restart.start_date);

          IF l_inclusion_flag = 'Y'
             -- Valid tchr on the same dateas the restart_Date, not in future.
             -- future events will be taken care of in the other events check
             AND NOT(l_asg_details_restart.start_date > l_pqp_asg_attributes.effective_start_date) THEN
            -- Pension flag has changed to 'Y' from 'N'/NULL
            debug('This assignment HAS opted back into the pension scheme.');
            l_restarter := 'Y';
            l_restarter_date := LEAST(l_pqp_asg_attributes.effective_start_date
                                     ,nvl(l_restarter_date,l_pqp_asg_attributes.effective_start_date)
                                     );

            CLOSE pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn;
            EXIT; -- quit loop -- no need to search for other events
          END IF ; --l_inclusion_flag = 'Y' THEN

        --
        END IF; -- 2 pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
      --
      END IF; -- 1 pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
      --
      CLOSE pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn;
      --
      debug('Assignment attributes have had changes',130);
      --
    END IF; -- if this date <> last date to eliminate duplicates
    --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through elected pension change proration dates

  l_proration_dates.DELETE;
  l_proration_changes.DELETE;

  l_pqp_asg_attributes := NULL;
  l_last_pqp_asg_attributes := NULL;

  l_asg_details_restart        := NULL;
  l_pqp_asg_attributes_restart := NULL ;


  debug('After Elected Pension Flag change check - Deleted Proration Dates',140);

  -- Check for the next set of events which qualify an assignment as restarter.
  --   4) Change in Teacher Status such that the status changes from
  --            'NONT' / 'NULL' to 'TCHR'/'TTR6'

  -- Get the events
  l_no_of_events := 0;
  l_no_of_events := get_events(p_event_group            => 'PQP_GB_TP_IS_TEACHER'
                              ,p_assignment_id          => p_assignment_id
                              ,p_business_group_id      => p_business_group_id
                              ,p_start_date             => p_effective_start_date
                              ,p_end_date               => p_effective_end_date
                              ,t_proration_dates        => l_proration_dates -- OUT
                              ,t_proration_changes      => l_proration_changes -- OUT
                              );

  debug('Number of '||'PQP_GB_TP_IS_TEACHER'||' Events: '||
     fnd_number.number_to_canonical(l_no_of_events));

  -- b) Loop through the events and check if any have changed.
  l_itr := l_proration_dates.FIRST;
  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through change proration dates

    IF (l_itr = l_proration_dates.FIRST
        OR
        ( l_proration_dates(l_itr) <>
          l_proration_dates(l_proration_dates.PRIOR(l_itr))
        )
       )
       AND
       (l_proration_changes(l_itr) <> 'C' -- Not a Correction
       ) THEN

      OPEN pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn
                        (p_assignment_id
                        ,l_proration_dates(l_itr)
                        );
      FETCH pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn INTO l_pqp_asg_attributes;
      --
      IF pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
         AND
         NVL(l_pqp_asg_attributes.tp_is_teacher,'NONT') IN ('TCHR','TTR6') THEN

        -- Fetch the previous set of attributes
        FETCH pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn INTO l_last_pqp_asg_attributes;
        --
        IF pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
           AND
           nvl(l_last_pqp_asg_attributes.tp_is_teacher,'NONT') = 'NONT' THEN

          debug('now checking chk_has_tchr_elected_pension',141);
          -- BUG : 3873376
          --:RSTRT --check if the asg is a valid tchr assignment on restart date.
          l_inclusion_flag := chk_has_tchr_elected_pension
                                (p_business_group_id => p_business_group_id
                                ,p_effective_date    => l_pqp_asg_attributes.effective_start_date
                                ,p_assignment_id     => p_assignment_id
                                ,p_asg_details       => l_asg_details_restart        -- OUT
                                ,p_asg_attributes    => l_pqp_asg_attributes_restart -- OUT
                                );
          debug('l_inclusion_flag :' ||l_inclusion_flag,142);
          debug('l_asg_details_restart.start_date :' ||l_asg_details_restart.start_date);

          IF l_inclusion_flag = 'Y'
             -- Valid tchr on the same dateas the restart_Date, not in future.
             -- future events will be taken care of in the other events check
             AND NOT(l_asg_details_restart.start_date > l_pqp_asg_attributes.effective_start_date) THEN

            debug('The leaver HAS become a Teacher again.');
            l_restarter := 'Y';
            l_restarter_date := LEAST(l_pqp_asg_attributes.effective_start_date
                                   ,nvl(l_restarter_date,l_pqp_asg_attributes.effective_start_date)
                                   );

            CLOSE pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn;
            EXIT; -- quit loop -- no need to search for other events
          END IF ; -- l_inclusion_flag = 'Y' THEN
          --
        END IF; -- 2 pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
      --
      END IF; -- 1 pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn%FOUND
      --
      CLOSE pqp_gb_tp_pension_extracts.csr_pqp_asg_attributes_dn;
      --
      debug('Assignment attributes have had changes',150);
      --
    END IF; -- if this date <> last date to eliminate duplicates and ignore corrections
    --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through elected pension change proration dates

  debug('After Teacher Status change check',160);

  -- Reset the events in pay_process_events to 'U' for "Unprocessed".
  -- Bug 3015917 : Removed set_pay_process.. as we now use the new style DTI

  l_proration_dates.DELETE;
  l_proration_changes.DELETE;

  l_asg_details_restart        := NULL;
  l_pqp_asg_attributes_restart := NULL ;


  debug('Restarter Flag :'||l_restarter,170);
  debug('Restarter Date :'||to_char(l_restarter_date,'dd/mm/yyyy'),180);

  -- Assign the restarter date value to the return parameter
  p_restarter_date := l_restarter_date;

  debug_exit(l_proc_name);
  RETURN l_restarter;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    p_restarter_date := NULL;
    RAISE;
END; -- chk_is_leaver_a_restarter

--
-- Check if this teacher has already been reported in previous runs
--
FUNCTION chk_has_teacher_been_reported
   (p_person_id         IN NUMBER
    -- ALRD_RPT change
    ,p_leaver_date          IN DATE
   ) RETURN VARCHAR2
IS

  -- Variable declaration
  l_reported_flag       VARCHAR2(1) := 'N';

  -- Cursor declaration
  CURSOR csr_person_reported IS
SELECT 'Y'
  FROM pqp_extract_attributes  pqea
      ,ben_ext_rslt            rslt
      ,ben_ext_rslt_dtl        rdtl
      ,ben_ext_rcd             drcd
  WHERE pqea.ext_dfn_type      = g_extract_type
    AND rslt.ext_dfn_id        = pqea.ext_dfn_id
    -- Bugfix 3073562:GAP1:GAP2, now using master bg id
    AND rslt.business_group_id = g_master_bg_id
    AND rslt.ext_stat_cd NOT IN
          ('F' -- Job Failure
          ,'R' -- Rejected By User
          ,'X' -- Executing
          )
    AND rdtl.ext_rslt_id  = rslt.ext_rslt_id
    AND drcd.ext_rcd_id   = rdtl.ext_rcd_id
    AND drcd.rcd_type_cd  = 'D' -- detail records only
    -- changed the person_id check to NI Number check.
    --AND rdtl.person_id = p_person_id
    AND rdtl.val_04 IN
            ( SELECT national_identifier
                FROM per_all_people_f per2
               WHERE per2.person_id = p_person_id
            )
    -- match the header element
    AND EXISTS
       ( SELECT 'Y'
           FROM  ben_ext_rslt_dtl rdtl1
          WHERE  rdtl1.business_group_id = g_master_bg_id
            AND  EXISTS
                ( SELECT 'Y'
                    FROM ben_ext_rcd drcd1
                   WHERE drcd1.rcd_type_cd = 'H'
                     AND drcd1.ext_rcd_id  = rdtl1.ext_rcd_id
                 )
            AND rdtl.ext_rslt_id = rdtl1.ext_rslt_id
            AND SUBSTR(rdtl1.val_01
                     ,1
                     ,INSTR(rdtl1.val_01,':',1,3)--upto third occurence
                     )
              =SUBSTR(g_header_system_element
                     ,1
                     ,INSTR(g_header_system_element,':',1,3)
                     )
        )
    -- only in the current pension year and upto the end of last run
    AND rslt.eff_dt between g_pension_year_start_date and g_last_effective_date
    -- ALRD_RPT change
    -- checking for the matching date and withdrawl flag.
    AND to_date(rdtl.val_14,'DDMMRR') = p_leaver_date  -- Leaver Date
    AND rdtl.val_15 = 'W'  --Withdrawl Flag
    -- only need to look for one record
    AND ROWNUM < 2;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'chk_has_teacher_been_reported';

BEGIN -- chk_has_teacher_been_reported

  debug_enter(l_proc_name);
  debug('p_person_id  : '||to_char(p_person_id),10);
  debug('p_leaver_date: '||to_char(p_leaver_date));

  -- ALRDRPT changes.
  -- check for the global variable
  -- if already set by the previous call to the function return that.
  -- else execute the logic to find the flag.

  -- ALRD_RPT changes

  -- PER_LVR:  removed the check
  -- coz we need to check for each leaver date separatly.

  --IF g_person_already_reported IS NULL THEN

    debug(l_proc_name,10) ;
    OPEN csr_person_reported;
    FETCH csr_person_reported INTO l_reported_flag;
    CLOSE csr_person_reported;

    -- PER_LVR:  removed the check
    --g_person_already_reported := l_reported_flag ;

  --ELSE
    --debug(l_proc_name,20) ;
    --l_reported_flag := g_person_already_reported ;
  --END IF;

  debug('Teacher Already Reported:'||l_reported_flag);
  debug_exit(l_proc_name);

  RETURN l_reported_flag;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- chk_has_teacher_been_reported
--
-- Bugfix 3073562:GAP9a
-- Added this procedure for GAP9a
--
PROCEDURE warn_if_supply_tchr_is_ft
            (p_assignment_id            IN NUMBER
            ,p_establishment_number     IN VARCHAR2
            ,p_ext_emp_cat_code         IN VARCHAR2
            ) IS

  l_error           number;

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'warn_if_supply_tchr_is_ft';

BEGIN -- warn_if_supply_tchr_is_ft

  debug_enter(l_proc_name);

  IF p_establishment_number = '0966' -- Supply Establishment
     AND -- Full time
     p_ext_emp_cat_code = 'F' THEN

    debug(l_proc_name, 20);
    l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_93655_SUPPLY_TCHR_FULLTIME'
                 ,p_error_number  => 93655
                 );
  END IF;

  debug_exit(l_proc_name);

END; -- warn_if_supply_tchr_is_ft

--
-- Function to get the Extract Employment category code
--
FUNCTION get_ext_emp_cat_cd
  (p_assignment_id            IN      NUMBER
  ,p_effective_date           IN      DATE
  ) RETURN VARCHAR2 -- F or P
IS

  l_asg_details         csr_asg_details_up%ROWTYPE;
  l_ext_emp_cat_cd      VARCHAR2(1);

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_ext_emp_cat_cd';

BEGIN

  debug_enter(l_proc_name);
  debug('p_assignment_id :'||to_char(p_assignment_id), 10);
  debug('p_effective_date :'||to_char(p_effective_date, 'DD/MM/YYYY'), 20);

  OPEN csr_asg_details_up
        (p_assignment_id
        ,p_effective_date
        );
  FETCH csr_asg_details_up INTO l_asg_details;
  IF csr_asg_details_up%NOTFOUND THEN
    -- This situation should never happen, but
    -- if it does, we will assume part time
    debug('IMP : This situation should never happen', 30);
    l_ext_emp_cat_cd := 'P';
  ELSE -- asg record FOUND
    -- Bugfix 3073562:GAP1:GAP2
    l_ext_emp_cat_cd :=
        get_translate_asg_emp_cat_code
                (l_asg_details.asg_emp_cat_cd
                ,p_effective_date
                ,'Pension Extracts Employment Category Code'
                ,l_asg_details.business_group_id
                );
  END IF;

  CLOSE csr_asg_details_up;

  debug('Extract Emp Cat Code :'||l_ext_emp_cat_cd, 40);
  debug_exit(l_proc_name);

  RETURN l_ext_emp_cat_cd;
EXCEPTION
  WHEN OTHERS THEN
    CLOSE csr_asg_details_up;
    debug('SQLCODE :'||to_char(SQLCODE), 60);
    debug('SQLERRM :'||SQLERRM, 70);
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END get_ext_emp_cat_cd;

--
-- Fetch and save Secondary assignments
--
PROCEDURE fetch_secondary_assignments
   (p_primary_assignment_id     IN NUMBER
   ,p_person_id                 IN NUMBER
   ,p_effective_date            IN DATE
   ,p_must_be_a_leaver          IN BOOLEAN
   )
IS

  -- Variable Declaration
  l_inclusion_flag              VARCHAR2(1) := 'Y';
  l_leaver                      VARCHAR2(1) := 'N';
  l_leaver_date                 DATE := NULL;
  l_restarter                   VARCHAR2(1) := 'N';
  l_restarter_date              DATE := NULL;
  l_first_time                  BOOLEAN := TRUE;
  l_primary_asg_leaver_date     DATE := NULL;
  l_new_event_itr               NUMBER(5);
  -- LVRDATE change
  l_period_end_date             DATE := NULL;

  -- ALRDRPT change
  l_already_reported            VARCHAR2(1) := 'N';
  --PROFILING changes
  l_start_time                  NUMBER;
  l_end_time                    NUMBER;

  -- Rowtype Variable Declaration
  l_asg_details         csr_asg_details_up%ROWTYPE;
  l_pqp_asg_attributes  csr_pqp_asg_attributes_up%ROWTYPE;
  l_sec_asgs            csr_sec_assignments%ROWTYPE;
  l_starter_event       stored_events_type;

  --
  l_proc_name           VARCHAR2(61):=
     g_proc_name||'fetch_secondary_assignments';

BEGIN -- fetch_secondary_assignments

  debug_enter(l_proc_name);

  debug('g_cross_per_enabled :'||g_cross_per_enabled, 10);
  debug('g_crossbg_enabled :'||g_crossbg_enabled, 11);
  debug('p_person_id :'||to_char(p_person_id), 12);

  -- Fetch secondary assignments and save them only if
  -- Teacher has elected pension.
  -- However, find the leaver date for all secondary asgs.
  FOR l_sec_asgs IN csr_sec_assignments(p_primary_assignment_id
                                       ,p_person_id
                                       ,p_effective_date
                                       )
  LOOP

    debug('Inside Loop, secondary asg id :'||to_char(l_sec_asgs.assignment_id),20);

    -- Check if the secondary assignment qualifies to be on the Periodic Returns
    --    Pass g_pension_year_start_date as the effective date as we are
    --    checking as of start date of pension year. Basically, we are
    --    reporting annual returns from start of pension year.
    l_inclusion_flag := chk_has_tchr_elected_pension
                        (p_business_group_id            => l_sec_asgs.business_group_id
                        ,p_effective_date               => g_pension_year_start_date
                        ,p_assignment_id                => l_sec_asgs.assignment_id
                        ,p_asg_details                  => l_asg_details        -- OUT
                        ,p_asg_attributes               => l_pqp_asg_attributes -- OUT
                        );

    IF l_inclusion_flag = 'Y' THEN
    -- 1)

      -- Check for leaver events between pension year start date and effective run date
      --    Basically, we are reporting annual returns starting from the
      --    start of the pension year to the leaver date, and we want to check
      --    for people who have become leavers in the same date range.
      --    However as we donot want to report people who have already been reported,
      --    we will need to look at previous run results to exclude people who
      --    have already been reported.
      -- Dates :
      --   Start date should be pension year start date
      --   End Date should be the end date of the run date range.
      debug('Secondary asg passes chk_has_teacher_elected_pension, doing leaver chk',30);

      -- LVRDATE changes
      -- Changed the date passed based on Annual/Periodic Criteria

      debug ('g_extract_type: '|| g_extract_type) ;

      IF g_extract_type = 'TP1' THEN
        l_period_end_date := g_effective_run_date;
      ELSIF g_extract_type = 'TP1P' THEN
        l_period_end_date := g_effective_run_date + 1;
      END IF ;

      debug ('l_period_end_date: '|| l_period_end_date) ;

      l_leaver := chk_is_teacher_a_leaver
                        (p_business_group_id            => l_sec_asgs.business_group_id
                        ,p_effective_start_date         => GREATEST(g_pension_year_start_date
                                                                   ,nvl(l_asg_details.start_date
                                                                       ,g_pension_year_start_date
                                                                       )
                                                                   )
                         -- LVRDATE change: changed the date passed based on Annual/Periodic Criteria
                        ,p_effective_end_date           => l_period_end_date
                        --,p_effective_end_date           => g_effective_run_date
                        ,p_assignment_id                => l_sec_asgs.assignment_id
                        ,p_leaver_date                  => l_leaver_date -- OUT
                        );

      IF l_leaver = 'Y' THEN

        debug('Secondary asg is leaver storing leaver date',40);

        -- Bugfix 3073562:GAP6
        -- Adding this for secondary teaching asg support.
        -- This check is needed as there might not be any
        -- primary assignment row in g_ext_asg_details if this
        -- is the first secondary asg being processed.
        IF g_ext_asg_details.EXISTS(p_primary_assignment_id)
           -- Bugfix 3641851:CBF3b : Only do this if primary is to be reported
           AND
           g_ext_asg_details(p_primary_assignment_id).report_asg = 'Y' THEN
          l_primary_asg_leaver_date := g_ext_asg_details(p_primary_assignment_id).leaver_date;
        ELSE
          l_primary_asg_leaver_date := NULL;
        END IF;

        -- Store the leaver date
        -- Bugfix 3734942 : We don't need to overwrite the
        --   sec asg leaver date with primary leaver date.
        --   Infact we need the actual leaver date of the
        --   secondary assignment
        l_asg_details.leaver_date := l_leaver_date;

      ELSE -- l_leaver = 'N'

        debug('Secondary asg is NOT a leaver',50);

        l_asg_details.leaver_date := NULL;

       -- Return 'N' for Periodic Report if assignment is not terminated.
       -- Bug 5408932
        IF g_extract_type = 'TP1P' THEN
           l_asg_details.report_asg := 'N';
           l_inclusion_flag := 'N';
        END IF;

        -- PER_LVR change.
        -- Store the minimum of latest start date, in case it is not a leaver asg.
        g_latest_start_date := LEAST (g_latest_start_date,l_asg_details.start_date) ;

      END IF;

      IF l_inclusion_flag = 'Y' THEN
      -- 2)

        -- Assignment has passed all checks save the details in
        --   1) Type 4 global collection g_ext_asg_details
        --   2) Type 1 global collection g_ext_asg_details
        --        Has more stuff than the Type 4 counterpart
        --   3) Type 1 global collection g_ext_aat_details
        --

        -- Even secondary asgs which are leavers are stored in the global ASG and AAT
        -- collections as this will be necessary at the time of creating multiple lines
        -- of service even in annual with exclude leavers mode.

        -- Check if the leaver is also a re-starter,
        -- i.e. there is break in service in this pension year
        --   But, do this only if the leaver date is present and
        --   less than the g_effective_run_date
        l_asg_details.restarter_date := NULL;

        IF l_leaver = 'Y'
           AND
           l_leaver_date < g_effective_run_date THEN

          debug('Chk if Secondary leaver is also a restarter',60);

          l_restarter := chk_is_leaver_a_restarter
                              (p_business_group_id        => l_sec_asgs.business_group_id
                              ,p_effective_start_date     => (l_leaver_date + 1)
                              -- Bugfix 3734942 Chk for restarter event to end of run period
                              ,p_effective_end_date       => g_effective_run_date
                              ,p_assignment_id            => l_sec_asgs.assignment_id
                              ,p_restarter_date           => l_restarter_date -- OUT
                              );

          IF l_restarter = 'Y' THEN

            debug('Sec. leaver is also a restarter, restarter date :'||to_char(l_restarter_date,'DDMMYY'),70);

            l_asg_details.restarter_date := l_restarter_date;

          END IF; -- l_restarter = 'Y' THEN

        END IF; -- l_leaver = 'Y' AND l_leaver_date < g_effective_run_date THEN

        debug('Storing values to globals',80);

        --   1) Type 4 global collection g_ext_asg_details
        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).person_id          := l_asg_details.person_id;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).assignment_id      := l_asg_details.assignment_id;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).start_date         := l_asg_details.start_date;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).effective_end_date := l_asg_details.effective_end_date;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).creation_date      := l_asg_details.creation_date;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).location_id        := l_asg_details.location_id;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).asg_emp_cat_cd     := l_asg_details.asg_emp_cat_cd;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).ext_emp_cat_cd     := l_asg_details.ext_emp_cat_cd;

        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).estb_number        :=
          pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number;

        pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id).tp_safeguarded_grade :=
          l_pqp_asg_attributes.tp_safeguarded_grade;

        --   2) Type 1 global collection g_ext_asg_details
	g_teach_asg_count := g_teach_asg_count +1;
        g_ext_asg_details(l_sec_asgs.assignment_id) := l_asg_details;

        -- 3) Type 1 global collection g_ext_aat_details
        g_ext_asg_attributes(l_pqp_asg_attributes.assignment_id) := l_pqp_asg_attributes;

        -- Bugfix 3073562:GAP9a
        -- Raise a warning if the assignment is at a
        -- supply location and full time
        warn_if_supply_tchr_is_ft
          (p_assignment_id            => l_sec_asgs.assignment_id
          ,p_establishment_number     =>
              pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number
          ,p_ext_emp_cat_code         => l_asg_details.ext_emp_cat_cd
          );

        -- Bugfix 3073562:GAP9b
        -- Increment the supply asg count if this is a supply assignment
        IF pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number = '0966' THEN
          g_supply_asg_count := g_supply_asg_count + 1;
          debug('Incrementing supply teacher count',90);
        END IF;

        -- Bugfix 3641851:ENH6
        -- Increment the part time assignment count if the asg is part time
        -- Bugfix 3734942
        -- Moved the increment of part time asg count into the
        -- IF logic below coz we don't always want to increment
        -- We only increment if this assignment is the one
        -- to replace the teacher start date now.
        -- Otherwise, we just store the event and increment
        -- only when the event is being processed, i.e. only
        -- increment part time asg count when the event actually
        -- happens, not from the start of the period itself
        --IF l_asg_details.ext_emp_cat_cd = 'P' THEN
        --  g_part_time_asg_count := g_part_time_asg_count + 1;
        --  debug('Incrementing part time assignment count',100);
        --END IF;

        -- Setting NULL before deciding if an event is needed
        --  for this sec asg. NULLing as there mite be an event
        --  stored from prvious asg
        l_starter_event := NULL;

        -- Bugfix 3073562:GAP6
        IF l_first_time
           AND -- the primary asg is not being included
           (NOT g_ext_asg_details.EXISTS(p_primary_assignment_id))
        THEN

          debug('First Time and Primary not being included',110);
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_primary_assignment_id) :=
                  pqp_gb_tp_pension_extracts.g_ext_asg_details(l_sec_asgs.assignment_id);

          g_ext_asg_details(p_primary_assignment_id) := g_ext_asg_details(l_sec_asgs.assignment_id);
          g_ext_asg_details(p_primary_assignment_id).report_asg := 'N';

          -- Bugfix 3470242:GAP4 : We need to store the person id of the primary asg
          --                  as we have to update the results data for this person id
          --                  while creating new LOS.
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_primary_assignment_id).person_id := p_person_id;
          g_ext_asg_details(p_primary_assignment_id).person_id := p_person_id;

          g_ext_asg_details(p_primary_assignment_id).secondary_assignment_id :=
                  l_sec_asgs.assignment_id;

          g_ext_asg_attributes(p_primary_assignment_id) :=
                  g_ext_asg_attributes(l_pqp_asg_attributes.assignment_id);

          IF l_asg_details.ext_emp_cat_cd = 'P' THEN
            g_part_time_asg_count := g_part_time_asg_count + 1;
            debug('Incrementing part time assignment count',120);
          END IF;

          -- Bugfix 3803760:TERMASG
          g_asg_count := g_asg_count + 1;

          l_first_time := FALSE;

        ELSIF
             ( -- the primary asg is present in g_ext_asg_details
              g_ext_asg_details.EXISTS(p_primary_assignment_id)
              AND
              -- but not to be reported coz we r only reporting on a sec asg
              g_ext_asg_details(p_primary_assignment_id).report_asg = 'N'
              ) THEN

          debug('Not First Time and Primary not being included',130);
          -- Then we need to set the sec asgs start and leaver
          -- dates into the primary asgs record

          -- Bugfix 3734942 : We need to store the events for secondary
          --  and primary assignments starting in the middle of the
          --  period or starting after the least teacher start date
          --  for this person as these are new LOS events

          IF (g_ext_asg_details(l_sec_asgs.assignment_id).start_date
              >
              g_ext_asg_details(p_primary_assignment_id).teacher_start_date
             ) THEN

            debug('Event for this secondary asg to be recorded', 140);
            l_starter_event.event_type := 'SECONDARY_STARTER';
            l_starter_event.event_date
                := g_ext_asg_details(l_sec_asgs.assignment_id).start_date;
            l_starter_event.assignment_id := l_sec_asgs.assignment_id;
            IF l_asg_details.ext_emp_cat_cd = 'P' THEN
              l_starter_event.pt_asg_count_change := 1;
            END IF;

            -- Bugfix 3803760:TERMASG
            l_starter_event.asg_count_change := 1;

          ELSIF (g_ext_asg_details(l_sec_asgs.assignment_id).start_date
                 <  -- Sec asg start date LESS than teacher start date
                 g_ext_asg_details(p_primary_assignment_id).teacher_start_date
                ) THEN

            debug('Event for the other stored secondary asg to be recorded', 150);
            l_starter_event.event_type := 'SECONDARY_STARTER';
            l_starter_event.event_date
                := g_ext_asg_details(p_primary_assignment_id).teacher_start_date;
            l_starter_event.assignment_id :=
                g_ext_asg_details(p_primary_assignment_id).secondary_assignment_id;
            -- If the other sec asg is PT the count needs to be incremented
            IF g_ext_asg_details(l_starter_event.assignment_id).ext_emp_cat_cd = 'P' THEN
              -- Decrement the pt asg count coz we r moving this
              -- asgs start date into an event to be processed later
              g_part_time_asg_count := g_part_time_asg_count - 1;
              l_starter_event.pt_asg_count_change := 1;
            END IF;

            -- Bugfix 3803760:TERMASG
            g_asg_count := g_asg_count - 1;
            l_starter_event.asg_count_change := 1;

            -- Bugfix 3678324 : Now only assigning secondary assingment id
            --    and start date to teacher start date if it is actually
            --    less then the already stored teacher start date
            --    Previously we were incorrectly storing the sec asgs
            --    start date in start date of primary instead of teacher_start_date
            --    We were also not assigning the sec asg id into primary row
            g_ext_asg_details(p_primary_assignment_id).teacher_start_date
                := g_ext_asg_details(l_sec_asgs.assignment_id).start_date;
            g_ext_asg_details(p_primary_assignment_id).secondary_assignment_id
                := l_sec_asgs.assignment_id;

            -- Since this assignment is being stored as teacher start
            --  increment the pt asg count if its PT
            IF l_asg_details.ext_emp_cat_cd = 'P' THEN
              g_part_time_asg_count := g_part_time_asg_count + 1;
              debug('Incrementing part time assignment count',160);
            END IF;

            -- Bugfix 3803760:TERMASG
            g_asg_count := g_asg_count + 1;

            debug('Teacher start date :'||
                to_char(g_ext_asg_details(p_primary_assignment_id).teacher_start_date, 'DD/MM/YYYY')
               ,170);
          ELSE -- dates are equal
            debug('Dates are equal, no event needed', 180);
            -- But since this assignment is also on the same
            -- date as teacher start, we should increment the
            -- pt asg count if this asg is PT. BUT we do have
            -- a problem now. If in the next iteration
            -- another asg has start date LESS than teacher
            -- start date, then the current sec asg will get
            -- pushed out and an event will be stored for it.
            -- We then hv no way of knowing that the pt asg count
            -- sh be decremented more than one times coz
            -- two asgs had started on the same date
            -- But we will still increment the Pt asg count
            --  coz otherwise we will not get 0953 for any
            --  asg that has had multi PT asgs for long
            -- Drawbak is it will show 0953 even when
            --  one of the two asgs that started together
            --  leaver resulting in single Pt asgs, but this
            --  case will be very rare comparitively
            IF l_asg_details.ext_emp_cat_cd = 'P' THEN
              g_part_time_asg_count := g_part_time_asg_count + 1;
              debug('Incrementing part time assignment count',175);
            END IF;

            -- Bugfix 3803760:TERMASG
            g_asg_count := g_asg_count + 1;

          END IF;

          -- Not sure bout leaver date logic yet, change later.
          --g_ext_asg_details(p_primary_assignment_id).leaver_date :=
          --                LEAST(g_ext_asg_details(p_primary_assignment_id).leaver_date
          --                     ,g_ext_asg_details(l_sec_asgs.assignment_id).leaver_date
          --                     );

        -- Bugfix 3641851:CBF1 : Added ELSE part
        ELSE -- Primary assignment is present and is to be reported

          debug('Setting teacher start date for Primary asg',190);
          -- Bugfix 3641851:CBF1 : Assigning least start date of primary
          --    teacher start date (which sh be least of primary start date
          --    and previous secondary asg start date, if any) and current
          --    sec asg start date to teacher start date of primary asg

          -- Bugfix 3734942 : We need to store the events for secondary
          --  and primary assignments starting in the middle of the
          --  period or starting after the least teacher start date
          --  for this person as these are new LOS events

          -- Bugfix 3678324 : Now only assigning secondary assingment id
          --    and start date to teacher start date if it is actually
          --    less then the already stored teacher start date
          IF g_ext_asg_details(l_sec_asgs.assignment_id).start_date
             <  -- Sec asg start date LESS than teacher start date
             g_ext_asg_details(p_primary_assignment_id).teacher_start_date THEN

            debug('Sec asg start date :'||
                   to_char(g_ext_asg_details(l_sec_asgs.assignment_id).start_date
                          ,'DD/MM/YYYY')
                 ,191);
            debug('Primary Tchr Start Date :'||
                     to_char(g_ext_asg_details(p_primary_assignment_id).teacher_start_date
                                      ,'DD/MM/YYYY HH24:MI')
                 ,191);
            debug('Primary Start Date :'||
                     to_char(g_ext_asg_details(p_primary_assignment_id).start_date
                                      ,'DD/MM/YYYY HH24:MI')
                 ,191);
            debug('Sec asg id on primary row :'||
                     to_char(g_ext_asg_details(p_primary_assignment_id).secondary_assignment_id)
                 ,191);
            -- IF teacher start date and start date on primary row are
            --    same, and secondary asg id is NULL then the primary is
            --    being reported, push it into an event for future processing
            -- ELSE it will be another secondary asg being report, push
            --      that sec asg into an event as primary wud hv already been
            --      pushed into an event in a previous iteration
            -- Bugfix 3823873 : Changed secondary_assignment_id IS NULL to
            --     is equal to primary asg id
            --     This should b the case if this is the first time
            --     v r trying to assign a id to secondary_assignment_id
            IF ((g_ext_asg_details(p_primary_assignment_id).teacher_start_date
                 =
                 g_ext_asg_details(p_primary_assignment_id).start_date
                )
                AND
                (g_ext_asg_details(p_primary_assignment_id).secondary_assignment_id
                 =
                 p_primary_assignment_id
                )
               )
               THEN

              debug('Storing PRIMARY_STARTER event',192);
              -- Event for the primary asg to be recorded
              l_starter_event.event_type := 'PRIMARY_STARTER';
              l_starter_event.event_date
                  := g_ext_asg_details(p_primary_assignment_id).start_date;
              l_starter_event.assignment_id := p_primary_assignment_id;
              IF g_ext_asg_details(p_primary_assignment_id).ext_emp_cat_cd = 'P' THEN
                g_part_time_asg_count := g_part_time_asg_count - 1;
                l_starter_event.pt_asg_count_change := 1;
              END IF;

              -- Bugfix 3803760:TERMASG
              g_asg_count := g_asg_count - 1;
              l_starter_event.asg_count_change := 1;

            ELSE

              debug('Storing SECONDARY_STARTER event',193);
              -- Event for the other stored secondary asg to be recorded
              l_starter_event.event_type := 'SECONDARY_STARTER';
              l_starter_event.event_date
                := g_ext_asg_details(p_primary_assignment_id).teacher_start_date;
              l_starter_event.assignment_id :=
                g_ext_asg_details(p_primary_assignment_id).secondary_assignment_id;
              -- If the other sec asg is PT the count needs to be incremented
              IF g_ext_asg_details(l_starter_event.assignment_id).ext_emp_cat_cd = 'P' THEN
                -- Decrement the pt asg count coz we r moving this
                -- asgs start date into an event to be processed later
                g_part_time_asg_count := g_part_time_asg_count - 1;
                l_starter_event.pt_asg_count_change := 1;
              END IF;

              -- Bugfix 3803760:TERMASG
              g_asg_count := g_asg_count - 1;
              l_starter_event.asg_count_change := 1;

              debug('Stored sec asg id :'||to_char(l_starter_event.assignment_id),194);


            END IF;

            g_ext_asg_details(p_primary_assignment_id).teacher_start_date
                := g_ext_asg_details(l_sec_asgs.assignment_id).start_date;
            g_ext_asg_details(p_primary_assignment_id).secondary_assignment_id
                := l_sec_asgs.assignment_id;

            -- Since this assignment is being stored as teacher start
            --  increment the pt asg count if its PT
            IF l_asg_details.ext_emp_cat_cd = 'P' THEN
              g_part_time_asg_count := g_part_time_asg_count + 1;
              debug('Incrementing part time assignment count',200);
            END IF;

            -- Bugfix 3803760:TERMASG
            g_asg_count := g_asg_count + 1;

            debug('Teacher start date :'||
                to_char(g_ext_asg_details(p_primary_assignment_id).teacher_start_date, 'DD/MM/YYYY')
               ,210);

          ELSIF g_ext_asg_details(l_sec_asgs.assignment_id).start_date
                >  -- Sec asg start date GREATER than teacher start date
                g_ext_asg_details(p_primary_assignment_id).teacher_start_date THEN

            debug('Event for this secondary asg to be recorded', 220);
            l_starter_event.event_type := 'SECONDARY_STARTER';
            l_starter_event.event_date
                := g_ext_asg_details(l_sec_asgs.assignment_id).start_date;
            l_starter_event.assignment_id := l_sec_asgs.assignment_id;
            IF l_asg_details.ext_emp_cat_cd = 'P' THEN
              l_starter_event.pt_asg_count_change := 1;
            END IF;

            -- Bugfix 3803760:TERMASG
            l_starter_event.asg_count_change := 1;

          ELSE -- dates are equal
            debug('Dates are equal, no event needed', 230);
            -- But since this assignment is also on the same
            -- date as teacher start, we should increment the
            -- pt asg count if this asg is PT. BUT we do have
            -- a problem now. If in the next iteration
            -- another asg has start date LESS than teacher
            -- start date, then the current sec asg will get
            -- pushed out and an event will be stored for it.
            -- We then hv no way of knowing that the pt asg count
            -- sh be decremented more than one times coz
            -- two asgs had started on the same date
            -- But we will still increment the Pt asg count
            --  coz otherwise we will not get 0953 for any
            --  asg that has had multi PT asgs for long
            -- Drawbak is it will show 0953 even when
            --  one of the two asgs that started together
            --  leaver resulting in single Pt asgs, but this
            --  case will be very rare comparitively
            IF l_asg_details.ext_emp_cat_cd = 'P' THEN
              g_part_time_asg_count := g_part_time_asg_count + 1;
              debug('Incrementing part time assignment count',175);
            END IF;

            -- Bugfix 3803760:TERMASG
            g_asg_count := g_asg_count + 1;

          END IF;

        END IF; -- IF l_first_time

        debug('Teacher start date :'||
                to_char(g_ext_asg_details(p_primary_assignment_id).teacher_start_date, 'DD/MM/YYYY')
               ,240);

        -- Store the starter event as a new line of service event
        IF l_starter_event.event_date IS NOT NULL THEN
          debug('Storing the starter event', 250);
          l_new_event_itr := g_asg_events.COUNT+1;
          g_asg_events(l_new_event_itr) := l_starter_event;
        END IF;

      END IF; -- 2) l_inclusion_flag = 'Y' THEN
      --
    END IF; -- 1) l_inclusion_flag = 'Y' THEN

    -- Reset local variables to default values
    -- before processing next secondary assingnment
    l_inclusion_flag    := 'Y';
    l_leaver            := 'N';
    l_leaver_date       := NULL;

  END LOOP; -- l_sec_asg_details IN csr_sec_asg_details

  debug_exit(l_proc_name);
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- fetch_secondary_assignments

--
-- Return secondary assignments that are effective and in the future
--
FUNCTION get_all_secondary_asgs
   (p_primary_assignment_id     IN NUMBER
   ,p_effective_date            IN DATE
   ) RETURN t_sec_asgs_type
IS

  -- Rowtype Variable Declaration
  l_sec_asgs            csr_sec_assignments%ROWTYPE;
  l_all_sec_asgs        t_sec_asgs_type;
  --
  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_all_secondary_asgs';

BEGIN -- get_all_secondary_asgs

  debug_enter(l_proc_name);

  -- Fetch secondary assignments and save them only if
  -- Teacher has elected pension.
  -- However, find the leaver date for all secondary asgs.
  FOR l_sec_asgs IN csr_sec_assignments(p_primary_assignment_id
                                       ,g_ext_asg_details(p_primary_assignment_id).person_id
                                       ,p_effective_date
                                       )
  LOOP

    -- If the secondary assignment is part of the global ASG collection
    IF g_ext_asg_details.EXISTS(l_sec_asgs.assignment_id) THEN

      -- Add this to the table of valid secondary asgs
      l_all_sec_asgs(l_sec_asgs.assignment_id) := l_sec_asgs;

    END IF; -- g_ext_asg_details.EXISTS(l_sec_asgs.assignment_id) THEN
    --
  END LOOP; -- l_sec_asg_details IN csr_sec_asg_details

  debug_exit(l_proc_name);
  --
  RETURN l_all_sec_asgs;
  --
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- get_all_secondary_asgs

--
-- Return secondary assignments that are effective only
--
FUNCTION get_eff_secondary_asgs
   (p_primary_assignment_id     IN NUMBER
   ,p_effective_date            IN DATE
   ) RETURN t_sec_asgs_type
IS

  -- Rowtype Variable Declaration
  l_sec_asgs            csr_eff_sec_assignments%ROWTYPE;
  l_eff_sec_asgs        t_sec_asgs_type;
  --
  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_eff_secondary_asgs';

BEGIN -- get_eff_secondary_asgs

  debug_enter(l_proc_name);
  debug('p_primary_assignment_id ' || p_primary_assignment_id, 10) ;
  debug('p_effective_date ' || p_effective_date, 20) ;
  debug('g_effective_run_date ' || g_effective_run_date, 30) ;


  -- Fetch secondary assignments and save them only if
  -- Teacher has elected pension.
  -- However, find the leaver date for all secondary asgs.
  FOR l_sec_asgs IN csr_eff_sec_assignments(p_primary_assignment_id
                                           ,g_ext_asg_details(p_primary_assignment_id).person_id
                                           ,p_effective_date
                                           )
  LOOP
    debug('l_sec_asgs.assignment_id ' || l_sec_asgs.assignment_id, 50) ;
    -- If the secondary assignment is part of the global ASG collection
    IF g_ext_asg_details.EXISTS(l_sec_asgs.assignment_id) THEN

      debug(l_proc_name,60);
      debug('teacher_start_date ' || g_ext_asg_details(l_sec_asgs.assignment_id).teacher_start_date) ;
      debug('leaver_date ' || g_ext_asg_details(l_sec_asgs.assignment_id).leaver_date) ;
      debug('restarter_date ' || g_ext_asg_details(l_sec_asgs.assignment_id).restarter_date) ;

      -- MULT-LR --
      -- Use the new Function to check the effectivness of an assignment
      -- it takes care of multiple Leaver-Restarter events
      -- where as the old logic used to take into account
      -- only the first restarter event.
      IF ( chk_effective_asg ( p_assignment_id  => l_sec_asgs.assignment_id
                              ,p_effective_date => p_effective_date
                             )  = 'Y' ) THEN
        debug(l_proc_name,70);
        -- Add this to the table of valid secondary asgs
        l_eff_sec_asgs(l_sec_asgs.assignment_id) := l_sec_asgs;

      END IF ;  --Valid Tchr in the period

    END IF; -- g_ext_asg_details.EXISTS(l_sec_asgs.assignment_id) THEN
    --
  END LOOP; -- l_sec_asg_details IN csr_sec_asg_details

  debug_exit(l_proc_name);
  --
  RETURN l_eff_sec_asgs;
  --
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- get_eff_secondary_asgs

--
-- set_effective_assignments
--
-- Bugfix 3803760:FTSUPPLY
-- New Function to check all assignments for effectiveness
-- Purpose : Chcks all assignments for effectiveness and
--    do the following considering the new rule where
--    if any assignment is FT, only process that assignment
--    and leave out the other assignments
-- 1) If primary assignment is effecitve and FT, set it as
--    g_override_ft_asg_id and do not get secondary assignments
-- 2) If primary not FT, then call get_eff_secondary_asgs.
-- 3) If any effective secondary is FT, set it as override and
--    add to g_tab_sec_asgs
-- 4) If no secondary is FT, store all effective secondary
--    asgs in g_tab_sec_asgs
--
PROCEDURE set_effective_assignments
   (p_primary_assignment_id     IN NUMBER
   ,p_effective_date            IN DATE
   )
IS

  -- Rowtype Variable Declaration
  l_sec_asgs            csr_eff_sec_assignments%ROWTYPE;
  l_sec_asg_id          per_all_assignments_f.assignment_id%TYPE;
  l_tab_eff_sec_asgs    t_sec_asgs_type;
  l_rep_primary_asg     VARCHAR2(1);
  l_prev_asg_id         per_all_assignments_f.assignment_id%TYPE;

  l_asg_details         csr_asg_details_up%ROWTYPE;

  --
  l_proc_name          VARCHAR2(61):=
     g_proc_name||'set_effective_assignments';

BEGIN

  debug_enter(l_proc_name);
  debug('p_primary_assignment_id ' || p_primary_assignment_id, 10) ;
  debug('p_effective_date ' || p_effective_date, 20) ;
  debug('g_effective_run_date ' || g_effective_run_date, 30) ;

  g_override_ft_asg_id := NULL;
  g_tab_sec_asgs.DELETE;

  -- Bugfix 3880543:REHIRE : Done this as we need to nominate one
  --  sec asg for reporting if primary is not valid

  -- MULT-LR --
  -- Use the new Function to check the effectivness of an assignment
  -- it takes care of multiple Leaver-Restarter events
  -- where as the old logic used to take into account
  -- only the first restarter event.
  l_rep_primary_asg := chk_effective_asg (
                           p_assignment_id  => p_primary_assignment_id
                          ,p_effective_date => p_effective_date
                                          );

  IF (l_rep_primary_asg = 'Y'
     )
     AND
     (get_ext_emp_cat_cd
         (p_assignment_id  => p_primary_assignment_id
         ,p_effective_date => p_effective_date
         ) = 'F'
     ) THEN

    g_override_ft_asg_id := p_primary_assignment_id;
    debug('Primary asg is FT, setting as override', 40);

  ELSE -- check the secondary assignments

    debug('Getting effective sec asgs', 50);
    l_tab_eff_sec_asgs := get_eff_secondary_asgs
                           (p_primary_assignment_id  => p_primary_assignment_id
                           ,p_effective_date         => p_effective_date
                           );

    -- Bugfix 3880543:REHIRE : We are now setting the first sec asg id
    --  as the secondary_assignment in row for the primary.
    --  And then the 2nd sec asg id in as secondary_assignment
    --  in the row for 1st sec asg and so on
    l_prev_asg_id := p_primary_assignment_id;
    l_sec_asg_id := l_tab_eff_sec_asgs.FIRST;
    WHILE l_sec_asg_id IS NOT NULL
    LOOP

      debug('Processing sec asg id :'||to_char(l_sec_asg_id), 60);
      IF get_ext_emp_cat_cd
          (p_assignment_id  => l_sec_asg_id
          ,p_effective_date => p_effective_date
          ) = 'F' -- Full time
          THEN

        debug('This sec asg is FT, setting as override', 70);

        g_tab_sec_asgs.DELETE;
        g_tab_sec_asgs(l_sec_asg_id) := l_tab_eff_sec_asgs(l_sec_asg_id);
        g_override_ft_asg_id := l_sec_asg_id;

        -- Bugfix 3880543:REHIRE : Need to nomindate this sec for reporting
        --  coz its the FT asg
        g_ext_asg_details(p_primary_assignment_id).secondary_assignment_id
                := g_override_ft_asg_id;
        EXIT;

      ELSE

        debug('Adding this sec asg to global collection', 80);
        g_tab_sec_asgs(l_sec_asg_id) := l_tab_eff_sec_asgs(l_sec_asg_id);

        -- Bugfix 3880543:REHIRE : Need to nominate one sec for reporting if
        --  primary OR the current secondary is not to be reported,
        --  The first secondary asg will b stored in secondary_assignment_id
        --  in the row for primary asg
        --  In the future if needed we can add logic to choose the
        --  secondary asg based on some criteria
        g_ext_asg_details(l_prev_asg_id).secondary_assignment_id := l_sec_asg_id;

      END IF;

      -- Set the current as previous
      l_prev_asg_id := l_sec_asg_id;

      -- Get the next secondary assignment
      l_sec_asg_id := l_tab_eff_sec_asgs.NEXT(l_sec_asg_id);

    END LOOP;
    debug('Total eff sec asgs :'||to_char(g_tab_sec_asgs.COUNT), 90);

  END IF; -- (l_rep_primary_asg

  debug('Override FT Assignment ID :'||to_char(nvl(g_override_ft_asg_id, -1)), 100);

  -- If the override asg was found re-evaluate the asg details
  -- as of effective date and store in g_ext_asg_details
  IF g_override_ft_asg_id IS NOT NULL
     AND
     -- If effective date is > teacher start date
     -- this sh b for a new line, we should refresh
     -- some columns on g_ext_asg_details for the override
     -- asg as new values need to be used. For the first
     -- line, the values should be current
     p_effective_date > g_ext_asg_details(p_primary_assignment_id).teacher_start_date THEN

    OPEN csr_asg_details_up
          (g_override_ft_asg_id
          ,p_effective_date
          );
    FETCH csr_asg_details_up INTO l_asg_details;
    IF csr_asg_details_up%NOTFOUND THEN
      -- This situation should never happen,
      debug('IMP : This situation should never happen', 100);
      NULL;
    ELSE -- asg record FOUND

      IF l_asg_details.location_id IS NOT NULL
         AND
         pqp_gb_tp_pension_extracts.g_criteria_estbs.EXISTS(l_asg_details.location_id) THEN


        debug('Re-evaluating override asg details', 110);
        -- Setting the current ext_emp_cat_cd, location_id and estb_number
        g_ext_asg_details(g_override_ft_asg_id).ext_emp_cat_cd := 'F';
        debug('l_asg_details.location_id :'||to_char(l_asg_details.location_id), 111);
        g_ext_asg_details(g_override_ft_asg_id).location_id := l_asg_details.location_id;
        debug('g_ext_asg_details(g_override_ft_asg_id).estb_number :'||g_ext_asg_details(g_override_ft_asg_id).estb_number, 111);
        debug('Estb number in Global :'||pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number, 112);
        g_ext_asg_details(g_override_ft_asg_id).estb_number :=
          pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number;

      ELSE
        debug('WARNING: This asg might hv multiple leaver events', 113);
      END IF;

    END IF;
    debug('After IF Asg_Record_Found ' , 114);

    CLOSE csr_asg_details_up;

  END IF; -- g_override_ft_asg_id IS NOT NULL

  debug_exit(l_proc_name);
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    debug('SQLCODE :'||to_char(SQLCODE), 150);
    debug('SQLERRM :'||SQLERRM, 160);
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- set_effective_assignments

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ To get the corresponding Pension Extract Emp Category code  ~
-- ~ and Pension Extract Working Pattern Code                    ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function Get_Translate_Asg_Emp_Cat_Code (p_asg_emp_cat_cd   in varchar2
                                        ,p_effective_date   in Date
                                        ,p_udt_column_name  in varchar2
                                        ,p_business_group_id IN NUMBER
                                        ) Return Varchar2  Is

 l_proc_name          varchar2(70):= g_proc_name||'Get_Translate_Asg_Emp_Cat_Code';
 l_udt_value VARCHAR2(1):= '?';

 Cursor csr_get_emp_cat_code (c_effective_date    in date
                             ,c_asg_emp_cat_cd    in varchar2
                             ,c_udt_column_name   in varchar2
                             ,c_business_group_id in number
                             ,c_legislation_code  in varchar2)  Is
  Select  extv.value,extv.business_group_id
    From   pay_user_tables   tbls
          ,pay_user_columns asgc
          ,pay_user_columns extc
          ,pay_user_rows_f  urws
          ,pay_user_column_instances_f asgv
          ,pay_user_column_instances_f extv
   where  tbls.user_table_name ='PQP_GB_TP_EMPLOYMENT_CATEGORY_TRANSALATION_TABLE'
     and  asgc.user_table_id = tbls.user_table_id
     and  extc.user_table_id = tbls.user_table_id
     and  asgc.user_column_name = 'Assignment Employment Category Lookup Code'
     and  extc.user_column_name = c_udt_column_name
     and  urws.user_table_id = tbls.user_table_id
     and  (urws.business_group_id = c_business_group_id
            OR
             (urws.business_group_id IS NULL
              AND urws.legislation_code = c_legislation_code)
            OR
             (urws.business_group_id IS NULL AND urws.legislation_code IS NULL)
            )
     and  c_effective_date BETWEEN urws.effective_start_date
                               AND urws.effective_end_date
     and  asgv.user_column_id = asgc.user_column_id
     and  c_effective_date BETWEEN asgv.effective_start_date
                               AND asgv.effective_end_date
     and  extv.user_column_id = extc.user_column_id
     and  c_effective_date BETWEEN extv.effective_start_date
                               AND extv.effective_end_date
     and  asgv.user_row_id = urws.user_row_id
     and  extv.user_row_id = asgv.user_row_id
     and  asgv.value = c_asg_emp_cat_cd;

Begin
    debug_enter(l_proc_name);
    debug('c_effective_date : '|| to_char(NVL(p_effective_date,g_effective_date)),10);
    debug('p_asg_emp_cat_cd : '|| p_asg_emp_cat_cd);
    debug('p_udt_column_name : '|| p_udt_column_name);

-- Changed the procedure to return business group level values if values are defined both at Legislation
-- and Business Group Level Bug 5498514
    FOR l_idx in csr_get_emp_cat_code (c_effective_date    =>  NVL(p_effective_date,g_effective_date)
			      ,c_asg_emp_cat_cd    =>  p_asg_emp_cat_cd
			      ,c_udt_column_name   =>  p_udt_column_name
			      ,c_business_group_id =>  p_business_group_id
			      ,c_legislation_code  =>  g_legislation_code
			       ) LOOP
  --  Fetch csr_get_emp_cat_code Into l_udt_value;

    -- Added by Babu and Raju as a fix for Invalid Emp Cat warning
    -- Date : 10/04/2002
    -- Assigns value if leg level data and no bg level data exists
    -- If bg level data exists always use the same
      IF (l_idx.business_group_id IS NULL AND l_udt_value = '?') OR
	 (l_idx.business_group_id IS NOT NULL AND l_idx.value IS NOT NULL) THEN
	  l_udt_value :=  l_idx.value;
      END IF;
    END LOOP;

    IF l_udt_value = '?' THEN
      l_udt_value := NULL;
    END IF;

--    END LOOP;
 --   Close csr_get_emp_cat_code;

    debug('Return Value :'||l_udt_value, 20);
    debug_exit(l_proc_name);
    RETURN l_udt_value;

Exception
    When No_Data_Found Then
     --debug('No Data Found in Translate UDT');
      --debug_exit;
      debug_exit(' No Data Found in '||l_proc_name);
      l_udt_value := NULL;
    Return l_udt_value;
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
End Get_Translate_Asg_Emp_Cat_Code;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ Function returns the special class rules for teachers, based on emp category code ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function Get_Special_ClassRule ( p_assignment_id  in number
                                ,p_effective_date in date
                                ) Return varchar2 Is

 Cursor csr_get_empcat ( c_assignment_id  in number
                        ,c_effective_date in date ) Is
  Select paa.employment_category
    from per_all_assignments_f paa
   where paa.assignment_id = c_assignment_id
     and c_effective_date between paa.effective_start_date
                              and paa.effective_end_date;
 l_assig_emp_catcode     per_all_assignments_f.employment_category%TYPE;
 l_pension_ext_empcode   per_all_assignments_f.employment_category%TYPE;
 l_pension_ext_wrkpat    per_all_assignments_f.employment_category%TYPE;
 l_return_value          varchar2(7) :=' ';
 l_error_value           number;
 l_proc_name          varchar2(70):= g_proc_name||'Get_Special_ClassRule';

Begin
     debug_enter(l_proc_name);
     Open csr_get_empcat ( c_assignment_id  => p_assignment_id
                          ,c_effective_date => p_effective_date);
     Fetch csr_get_empcat Into l_assig_emp_catcode;
     If csr_get_empcat%NOTFOUND Then
        Close csr_get_empcat;
        l_return_value := 'UNKNOWN';
     Else
        Close csr_get_empcat;

       debug('Get the Pension Ext EmpCat and WrkPat codes', 10);

       -- Bugfix 3073562:GAP1:GAP2
       -- Only use cached copies if the assignment is frm
       -- the current BG, otherwise fetch from DB
       If g_ext_asg_details(p_assignment_id).business_group_id = g_business_group_id
          AND
          l_assig_emp_catcode = g_asg_emp_cat_cd
          And
          g_ext_emp_cat_cd Is Not Null Then

         l_pension_ext_empcode := g_ext_emp_cat_cd;
         l_pension_ext_wrkpat  := g_ext_emp_wrkp_cd;

       Else
          l_pension_ext_empcode := Get_Translate_Asg_Emp_Cat_Code
                                    (p_asg_emp_cat_cd  => l_assig_emp_catcode
                                    ,p_effective_date  => p_effective_date
                                    ,p_udt_column_name => 'Pension Extracts Employment Category Code'
                                    ,p_business_group_id =>
                                        g_ext_asg_details(p_assignment_id).business_group_id
                                    );
          l_pension_ext_wrkpat  := Get_Translate_Asg_Emp_Cat_Code
                                    (p_asg_emp_cat_cd  => l_assig_emp_catcode
                                    ,p_effective_date  => p_effective_date
                                    ,p_udt_column_name => 'Pension Extracts Working Pattern Code'
                                    ,p_business_group_id =>
                                        g_ext_asg_details(p_assignment_id).business_group_id
                                    );

          l_pension_ext_empcode := nvl(l_pension_ext_empcode,'F');
          l_pension_ext_wrkpat := nvl(l_pension_ext_wrkpat,'R');

          -- Bugfix 3073562:GAP1:GAP2
          -- Update the globals with new values only for current BG
          IF g_ext_asg_details(p_assignment_id).business_group_id = g_business_group_id THEN
            debug(l_proc_name, 20);
            g_asg_emp_cat_cd  := l_assig_emp_catcode;
            g_ext_emp_cat_cd  := l_pension_ext_empcode;
            g_ext_emp_wrkp_cd := l_pension_ext_wrkpat;
          END IF;
       End If;
     End If;

     debug('Check the conditions', 30);

     If  l_pension_ext_empcode Is Not Null And
         l_pension_ext_empcode ='F' Then
         l_return_value := '0';
     Elsif l_pension_ext_empcode ='P' And
           l_pension_ext_wrkpat Is Not Null Then

           If l_pension_ext_wrkpat ='R' Then
              l_return_value := '7';
           Elsif l_pension_ext_wrkpat ='T' Then
              l_return_value := '8';
           Else
              l_return_value := 'INVALID';
           End If;
     Else
      l_return_value := 'INVALID';

     End If;
     debug('Return Value :'||l_return_value, 40);
     debug_exit(l_proc_name);
     Return l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
End Get_Special_ClassRule;

Function Get_Allowance_Code ( p_assignment_id   in number
                             ,p_effective_date  in date
                             ,p_allowance_type  in varchar2 ) Return varchar2 Is
--
-- Cursor to get the element_type_id
--
Cursor csr_ele_type_id ( c_element_name   in varchar2
                        ,c_effective_date in date ) Is
 Select pet.element_type_id
   from pay_element_types_f pet
  where c_effective_date between pet.effective_start_date
                             and pet.effective_end_date
    and pet.element_name = c_element_name;
--
-- Cursor to check if the element exits in element entries
--
Cursor csr_ele_entries ( c_assignment_id   in number
                        ,c_effective_date  in date
                        ,c_element_type_id in number ) Is
 Select  pee.element_entry_id
   from  pay_element_entries_f pee
        ,pay_element_links_f   pel
  where  pee.assignment_id   = c_assignment_id
    and  pel.element_link_id = pee.element_link_id
    and  pel.element_type_id = c_element_type_id
    and  c_effective_date between pee.effective_start_date
                              and pee.effective_end_date
    and  c_effective_date between pel.effective_start_date
                              and pel.effective_end_date;

Type t_allowance_code Is Table of varchar2(1) Index By BINARY_INTEGER;

l_udt_allowance_code t_allowance_code;
l_allowance_code     varchar2(1);
l_element_name       pay_element_types_f.element_name%TYPE;
l_input_value_name   pay_input_values_f.name%TYPE;
l_element_type_id    pay_element_types_f.element_type_id%TYPE;
l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
l_count_ele_entries  Number;
l_return_value       char(7) := ' ';
l_error_value        number;
l_proc_name          varchar2(60) := g_proc_name || 'Get_Allowance_Code';

-- 4336613 : LARP_SPAP_3A : new local variable to hold count of LARP/SPAP entries in UDT
l_larp_spap_count    NUMBER;


Begin
     -- hr_utility.set_location('Entering: '||l_proc_name, 5);
     debug_enter(l_proc_name);
     debug('p_allowance_type :'||p_allowance_type, 10);
     l_count_ele_entries := 0;
     For i in 1..4 Loop
        l_udt_allowance_code(i) := Null;
     End Loop;
     --
     -- check if the assignment has one or more element entry as defined in the UDT
     --


     -- 4336613 : LARP_SPAP_3A : depending on LARP/SPAP entries being considered,
     -- assign number of entried to l_larp_spap_count to be used in for loop
     -- incase none are found, raise a warning (instead of an error as was being
     -- done earlier)
     IF p_allowance_type = 'LONDON_ALLOWANCE_RULE' THEN
       l_larp_spap_count := g_udt_element_LondAll.COUNT;
     ELSIF p_allowance_type = 'SPECIAL_ALLOWANCE_RULE' THEN
       l_larp_spap_count := g_udt_element_SpcAll.COUNT;
     ELSE
       l_error_value := pqp_gb_tp_extract_functions.raise_extract_error
                         (p_business_group_id => g_business_group_id
                         ,p_assignment_id     => p_assignment_id
                         ,p_error_text        =>'BEN_93024_EXT_TP1_INVALID_ALOW'
                         ,p_error_number      => 93024 );
     END IF;


     For i_idx in 1..l_larp_spap_count Loop -- 4336613 : LARP_SPAP_3A : now from 1 to
                                            -- l_larp_spap instead of 1 to 4
          debug('Idx :'||to_char(i_idx), 20);
        If p_allowance_type = 'LONDON_ALLOWANCE_RULE' Then
           l_allowance_code   := g_udt_element_LondAll(i_idx).allowance_code;
           l_element_name     := g_udt_element_LondAll(i_idx).element_name;
           l_input_value_name := g_udt_element_LondAll(i_idx).input_value_name;
        Elsif p_allowance_type = 'SPECIAL_ALLOWANCE_RULE' Then
           l_allowance_code   := g_udt_element_SpcAll(i_idx).allowance_code;
           l_element_name     := g_udt_element_SpcAll(i_idx).element_name;
           l_input_value_name := g_udt_element_SpcAll(i_idx).input_value_name;

        End if;
        debug('Checking if : '||l_element_name ||' is defined', 30);
        Open csr_ele_type_id ( c_element_name   => l_element_name
                              ,c_effective_date => p_effective_date);
        Fetch csr_ele_type_id Into l_element_type_id;

        If csr_ele_type_id%NOTFOUND Then
           Close csr_ele_type_id;
           l_error_value := pqp_gb_tp_extract_functions.raise_extract_error
                           (p_business_group_id => g_business_group_id
                           ,p_assignment_id     => p_assignment_id
                           ,p_error_text        => 'BEN_93026_EXT_TP1_ELE_NOTEXIST'
                           ,p_error_number      => 93026
                           ,p_token1            => l_element_name
                           );

        Else
           Close csr_ele_type_id;
           debug('Checking for : '||l_element_name||' in element entries', 40);
           Open csr_ele_entries ( c_assignment_id   => p_assignment_id
                                 ,c_effective_date  => p_effective_date
                                 ,c_element_type_id => l_element_type_id);
           Fetch csr_ele_entries Into l_element_entry_id;
           If csr_ele_entries%FOUND Then
              -- Check to see if their are multiple entries for the element
              -- for the same pay period; if found raise error
              debug(l_proc_name, 50);
              l_count_ele_entries := l_count_ele_entries + 1;
              Fetch csr_ele_entries Into l_element_entry_id;
              If csr_ele_entries%FOUND Then
                 debug('More than one entry found for element :'||l_element_name, 60);
                 l_count_ele_entries := l_count_ele_entries + 1;
              Else
                 debug('Idx :'||to_char(i_idx)||' l_allowance_code :'||l_allowance_code, 70);
                 l_udt_allowance_code(i_idx):= l_allowance_code;
              End If;
           Else
              debug('Setting NULL', 80);
              l_udt_allowance_code(i_idx):= Null;
           End If;
               Close csr_ele_entries;
        End If;
        -- If the assignment has more than one element then exit and raise error
        Exit When l_count_ele_entries > 1;

     End Loop;
     debug(l_proc_name, 90);

     If l_count_ele_entries > 1 Then
        l_return_value := 'TOOMANY';
     Elsif l_count_ele_entries = 0 Then
        l_return_value := 'UNKNOWN';
     Else
         For i in 1..4 Loop
           debug(l_proc_name, 100);
           If l_udt_allowance_code(i) Is Not Null Then
              l_return_value := l_udt_allowance_code(i);
              Exit;
           End If;
         End Loop;
     End If;
     debug('Return value :'||l_return_value, 110);
     debug_exit(l_proc_name);
     -- hr_utility.set_location('Leaving: '||l_proc_name, 15);

     Return l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
End Get_Allowance_Code;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ Function checks the Safeguarded Grade and Fast Track Indicator ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function Get_Grade_Fasttrack_Info (p_assignment_id   In    number
                                  ,p_effective_date  In    date) Return char Is

Cursor csr_get_aat_info (c_assignment_id  In number
                        ,c_effective_date In date ) Is
 select assignment_attribute_id
       ,assignment_id
       ,tp_is_teacher
       ,tp_safeguarded_grade
       ,tp_fast_track
       ,tp_elected_pension
       -- added the new column for the new safeguarded logic based on safeguarded rate type
       ,tp_safeguarded_rate_type
   from pqp_assignment_attributes_f
  where  assignment_id = c_assignment_id
    and  c_effective_date between effective_start_date
                              and effective_end_date
  order by effective_start_date;

 l_proc_name     varchar2(60) := g_proc_name || 'Get_Grade_Fasttrack_Info';
 l_aat_info      csr_get_aat_info%rowtype;
 l_return_value  char(1):= ' ';
Begin
  -- hr_utility.set_location('Entering: '||l_proc_name, 5);
  debug_enter(l_proc_name);
  Open csr_get_aat_info
    (c_assignment_id  => p_assignment_id
    ,c_effective_date => p_effective_date
    );
  Fetch csr_get_aat_info into l_aat_info;

  If csr_get_aat_info%FOUND Then
     debug(l_proc_name, 10);
      -- SFG:4135481 : modified the criteria for deciding safegarded check
      -- Instead of using safeguarded grade , now using safeguarded rate type field.
      If (l_aat_info.tp_safeguarded_rate_type Is Not Null ) Then
        l_return_value := 'S';
     Elsif l_aat_info.tp_fast_track ='Y' Then
        l_return_value := 'F';
     End If;
  End If;

  Close csr_get_aat_info;

  debug('Return value :'||l_return_value, 20);
  debug_exit(l_proc_name);
  -- hr_utility.set_location('Leaving: '||l_proc_name, 15);

  Return l_return_value;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
End Get_Grade_Fasttrack_Info;

--
-- ----------------------------------------------------------------------------
-- |------------------------< process_element >-------------------------------|
-- ----------------------------------------------------------------------------
function process_element (p_assignment_id    in   number
                         ,p_calculation_date in   date
                         ,p_rate_name        in   varchar2
                         ,p_rate_type        in   varchar2
                         ,p_from_time_dim    in   varchar2
                         ,p_to_time_dim      in   varchar2
                         ,p_fte              in   varchar2
                         ,p_term_time_yes_no in   varchar2
                         )
  return number is
--
  l_proc_name        varchar2(60) := g_proc_name || 'process_element';
  l_ele_rate         csr_ele_rate_id%rowtype;
  l_paa_rate         csr_paa_rate_id%rowtype;
  l_paa_attribute_id pqp_assignment_attributes_f.assignment_attribute_id%type := null;
  l_value            number := 0;
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter (l_proc_name);

  open csr_ele_rate_id (c_rate_name => p_rate_name
                       ,c_rate_type => p_rate_type);
  fetch csr_ele_rate_id into l_ele_rate;
  close csr_ele_rate_id;

  -- Check whether the rate id is the same in aat
  open csr_paa_rate_id (c_assignment_id  => p_assignment_id
                       ,c_effective_date => p_calculation_date
                       );
  loop

    debug(l_proc_name, 10);
    fetch csr_paa_rate_id into l_paa_rate;
    exit when csr_paa_rate_id%notfound;

    if l_paa_rate.tp_safeguarded_rate_id = l_ele_rate.rate_id
    then

       debug(l_proc_name, 15);
       l_paa_attribute_id := l_paa_rate.assignment_attribute_id;
       exit;
    end if; -- end if of rate id check...

  end loop;
  close csr_paa_rate_id;

  if l_paa_attribute_id is not null then

     if p_rate_type = 'SP' then

        --
        debug(l_proc_name, 20);
        --
        open csr_scale_rate(c_attribute_id   => l_paa_attribute_id
                           ,c_effective_date => p_calculation_date
                           );
        fetch csr_scale_rate into l_value;
        close csr_scale_rate;

     elsif p_rate_type = 'GR' then

       --
       debug(l_proc_name, 30);
       --
       open csr_grade_rate (c_attribute_id   => l_paa_attribute_id
                           ,c_effective_date => p_calculation_date
                           );
       fetch csr_grade_rate into l_value;
       close csr_grade_rate;

     end if; -- end if of rate type check ...

     if l_value is not null then

       --
       debug(l_proc_name, 40);
       --
       l_value := pqp_rates_history_calc.convert_values
                    (p_assignment_id   => p_assignment_id
                    ,p_date            => p_calculation_date
                    ,p_value           => l_value
                    ,p_to_time_dim     => p_to_time_dim
                    ,p_from_time_dim   => p_from_time_dim
                    ,p_fte             => p_fte
                    ,p_service_history => 'N'
                    ,p_term_time_yes_no => p_term_time_yes_no
                    );

     end if; -- end if of value not null check...

  end if; -- end if of attribute id not null check ...

  debug('Return Value :'||to_char(l_value), 50);
  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 50);
  --
  debug_exit (l_proc_name);

  return l_value;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end process_element;
--
-- ----------------------------------------------------------------------------
-- |------------------------< rates_history >---------------------------------|
-- ----------------------------------------------------------------------------
function rates_history (p_assignment_id    in     number
                       ,p_calculation_date in     date
                       ,p_rate_type_name   in     varchar2
                       ,p_fte              in     varchar2
                       ,p_to_time_dim      in     varchar2
                       ,p_safeguarded_yn   in     varchar2
                       ,p_rate             in out nocopy number
                       )
  return number is
--

-- Cursor to check if an element is linked to a assignment

      CURSOR c_link_assign (
                         p_assignment_id   IN NUMBER
                        ,p_element_type_id IN NUMBER
                        ,p_date            IN DATE )IS
      select 'Y'
        from   pay_element_links_f pel
              ,pay_element_entries_f pee
              ,pay_element_types_f pet
       where pet.element_type_id = pel.element_type_id
         and pel.element_link_id = pee.element_link_id
         and pee.assignment_id   = p_assignment_id
         and pet.element_type_id = p_element_type_id
         and p_date between pel.effective_start_date and
                                        pel.effective_end_date
         and p_date between pee.effective_start_date and
                                        pee.effective_end_date
         and p_date between pet.effective_start_date and
                                        pet.effective_end_date ;

  l_proc_name        varchar2(60) := g_proc_name || 'rates_history';
  l_element_set      csr_element_set%rowtype;
  l_service_history  pay_element_type_extra_info.eei_information5%type;
  l_fte              pay_element_type_extra_info.eei_information4%type;
  l_pay_source_value pay_element_type_extra_info.eei_information2%type;
  l_qualifier        pay_element_type_extra_info.eei_information3%type;
  l_from_time_dim    pay_element_type_extra_info.eei_information1%type;
  l_element_rate     number := 0;
  l_total_rate       number := 0;

  l_calculation_type             pay_element_type_extra_info.eei_information1%type;
  l_calculation_value            pay_element_type_extra_info.eei_information1%type;
  l_input_value                  pay_element_type_extra_info.eei_information1%type;
  l_linked_to_assignment         pay_element_type_extra_info.eei_information1%type;
  l_term_time_yes_no             pay_element_type_extra_info.eei_information1%type;
  l_chk_assign_link              fnd_lookup_values.lookup_code%TYPE;
  l_sum_multiple_entries_yn      fnd_lookup_values.lookup_code%TYPE;
  l_lookup_input_values_yn       fnd_lookup_values.lookup_code%TYPE;
  l_column_name_source_type      pay_element_type_extra_info.eei_information16%TYPE;
  l_column_name_source_name      pay_element_type_extra_info.eei_information17%TYPE;
  l_row_name_source_type         pay_element_type_extra_info.eei_information18%TYPE;
  l_row_name_source_name         pay_element_type_extra_info.eei_information19%TYPE;


  -- Added a new varaibale to hold the element details .
  l_element_dtl     pqp_gb_tp_pension_extracts.t_allowance_eles;
  l_element_type_id NUMBER;
  l_count   NUMBER := 0;
  l_error NUMBER;

  l_rate_nc          number;
--
BEGIN

  -- nocopy changes
  l_rate_nc := p_rate;

  debug_enter(l_proc_name);

  debug('p_assignment_id :'||to_char(p_assignment_id),10);
  debug('Calculation Date :'||to_char(p_calculation_date,'dd/mm/yyyy'));
  debug('p_rate_type_name :'||p_rate_type_name);
  debug('p_fte :'||p_fte);
  debug('p_to_time_dim :'||p_to_time_dim);
  debug('p_safeguarded_yn :'||p_safeguarded_yn);


  BEGIN
    -- Get Element Attribution for the given rate type
    IF p_rate_type_name IS NULL THEN
    -- Retention elements are defined so we need to create the element set
    -- using the l_tab_ret_aln_eles
      debug('g_tab_ret_aln_eles.COUNT: '||to_char(pqp_gb_tp_pension_extracts.g_tab_ret_aln_eles.COUNT),20);

      l_element_dtl := pqp_gb_tp_pension_extracts.g_tab_ret_aln_eles;

    ELSE
      -- Create the element set from the rate type passed.
      OPEN csr_element_set (c_name => p_rate_type_name
                         ,c_eff_date => p_calculation_date
                         ,c_business_group_id =>
                                g_ext_asg_details(p_assignment_id).business_group_id
                         );
      LOOP
        FETCH csr_element_set into l_element_set;
        EXIT WHEN csr_element_set%NOTFOUND;

        debug('element_type_id: '||to_char(l_element_type_id), 30);
        debug('element_type_extra_info_id: '||to_char(l_element_set.element_type_extra_info_id));

        l_element_dtl(l_element_set.element_type_id).element_type_id
                     := l_element_set.element_type_id ;
        l_element_dtl(l_element_set.element_type_id).element_type_extra_info_id
                     := l_element_set.element_type_extra_info_id ;
      END LOOP;
      CLOSE csr_element_set;

    END IF ;

    debug('l_element_dtl.COUNT: '||l_element_dtl.COUNT, 40) ;
    l_element_type_id := l_element_dtl.FIRST;

    l_count := 1 ; -- Loop counter ;

    WHILE l_element_type_id IS NOT NULL
    LOOP
      --
      debug('element_type_id: '|| l_element_type_id,50+l_count/100 );
      --
      pqp_rates_history_calc.get_element_attributes
        (--p_element_type_extra_info_id  => l_element_set.element_type_extra_info_id
         p_element_type_extra_info_id  => l_element_dtl(l_element_type_id).element_type_extra_info_id
        ,p_service_history             => l_service_history    -- out
        ,p_fte                         => l_fte                -- out
        ,p_pay_source_value            => l_pay_source_value   -- out
        ,p_qualifier                   => l_qualifier          -- out
        ,p_from_time_dim               => l_from_time_dim      -- out
        ,p_calculation_type            => l_calculation_type   -- out
        ,p_calculation_value           => l_calculation_value  -- out
        ,p_input_value                 => l_input_value        -- out
        ,p_linked_to_assignment        => l_linked_to_assignment -- out
        ,p_term_time_yes_no            => l_term_time_yes_no   -- out
        ,p_sum_multiple_entries_yn    => l_sum_multiple_entries_yn --out
        ,p_lookup_input_values_yn     => l_lookup_input_values_yn  --out
        ,p_column_name_source_type    => l_column_name_source_type -- out
        ,p_column_name_source_name    => l_column_name_source_name -- out
        ,p_row_name_source_type       => l_row_name_source_type  -- out
        ,p_row_name_source_name       => l_row_name_source_name -- out
        );

      -- The value Linked to Assignment is Yes indicates that
      -- the element should be considered only if it is linked to
      -- assignment

      IF l_linked_to_assignment = 'Y' THEN

        -- Checking whether linked to Assignment

        OPEN c_link_assign (
                        p_assignment_id   => p_assignment_id
                       ,p_element_type_id => l_element_type_id -- l_element_set.element_type_id
                       ,p_date            => p_calculation_date ) ;

        FETCH c_link_assign INTO l_chk_assign_link ;
          IF c_link_assign%NOTFOUND THEN

              -- The element is not linked to assignment
              l_chk_assign_link := 'N' ;
          END IF ;
        CLOSE c_link_assign ;

        debug('l_chk_assign_link' ||l_chk_assign_link, 30);

      ELSE -- IF l_linked_to_assignment = 'N'

             -- Element Need not be Linked to Assignment
             l_chk_assign_link := 'Y' ;

      END IF ; -- IF l_link_to_assign = 'Y'

      debug('l_chk_assign_link' || l_chk_assign_link, 40);
      --hr_utility.set_location('l_chk_assign_link' ||l_chk_assign_link, 40);

      IF l_chk_assign_link = 'Y' THEN

        --debug('Element Type Id :'||l_element_set.element_type_id);
        debug('Element Type Id :'||l_element_type_id);
        debug('Qualifier :'||l_qualifier);
        debug('Pay Source Value :'||l_pay_source_value);

        IF l_pay_source_value in ('SP', 'GR') THEN

            debug('Pay Source is SP or GR');

            -- Check whether process should calculate rate based on safeguarded scale
            IF p_safeguarded_yn = 'Y' THEN

              --
              debug(l_proc_name, 30);
              --
              l_element_rate :=
                process_element -- only processes SP and GR so doesn't need entry value related params
                  (p_assignment_id                => p_assignment_id
                  ,p_calculation_date             => p_calculation_date
                  ,p_rate_name                    => l_qualifier
                  ,p_rate_type                    => l_pay_source_value
                  ,p_from_time_dim                => l_from_time_dim
                  ,p_to_time_dim                  => p_to_time_dim
                  ,p_fte                          => p_fte
                  ,p_term_time_yes_no             => l_term_time_yes_no
                  );

             debug('Element Rate for SF :'||l_element_rate);

           ELSE -- if not paid on safeguarded scale

             --
             debug(l_proc_name, 40);
             --
             l_element_rate := pqp_rates_history_calc.process_element
                                 (p_assignment_id                => p_assignment_id
                                 ,p_date                         => p_calculation_date
                                 --,p_element_type_id              => l_element_set.element_type_id
                                 ,p_element_type_id              => l_element_type_id
                                 ,p_to_time_dim                  => p_to_time_dim
                                 ,p_fte                          => p_fte
                                 ,p_service_history              => 'N'
                                 ,p_pay_source_value             => l_pay_source_value
                                 ,p_qualifier                    => l_qualifier
                                 ,p_from_time_dim                => l_from_time_dim
                                 ,p_calculation_type             => l_calculation_type
                                 ,p_calculation_value            => l_calculation_value
                                 ,p_input_value                  => l_input_value
                                 ,p_term_time_yes_no             => l_term_time_yes_no
                                 ,p_sum_multiple_entries_yn      => l_sum_multiple_entries_yn
                                 ,p_lookup_input_values_yn       => l_lookup_input_values_yn
                                 ,p_column_name_source_type      => l_column_name_source_type
                                 ,p_column_name_source_name      => l_column_name_source_name
                                 ,p_row_name_source_type         => l_row_name_source_type
                                 ,p_row_name_source_name         => l_row_name_source_name
                                 );

             debug('Element Rate for non-SF :'||l_element_rate);

           END IF; -- end if of safeguarded flag check...

        ELSE -- if pay source is not SP or GR

          --
          debug(l_proc_name, 50);
          debug('Pay Source NOT SP or GR');
           -- Additional parameters following rates history changes
          l_element_rate := pqp_rates_history_calc.process_element
                              (p_assignment_id                => p_assignment_id
                              ,p_date                         => p_calculation_date
                              --,p_element_type_id              => l_element_set.element_type_id
                              ,p_element_type_id              => l_element_type_id
                              ,p_to_time_dim                  => p_to_time_dim
                              ,p_fte                          => p_fte
                              ,p_service_history              => 'N'
                              ,p_pay_source_value             => l_pay_source_value
                              ,p_qualifier                    => l_qualifier
                              ,p_from_time_dim                => l_from_time_dim
                              ,p_calculation_type             => l_calculation_type
                              ,p_calculation_value            => l_calculation_value
                              ,p_input_value                  => l_input_value
                              ,p_term_time_yes_no             => l_term_time_yes_no
                              ,p_sum_multiple_entries_yn      => l_sum_multiple_entries_yn
                              ,p_lookup_input_values_yn       => l_lookup_input_values_yn
                              ,p_column_name_source_type      => l_column_name_source_type
                              ,p_column_name_source_name      => l_column_name_source_name
                              ,p_row_name_source_type         => l_row_name_source_type
                              ,p_row_name_source_name         => l_row_name_source_name
                              );

          debug('Element Rate for non-SF :'||l_element_rate);

        end if; -- end of of pay source check ...

        l_total_rate := l_total_rate + nvl(l_element_rate,0);

      END IF; -- End if of chk link to assignment check ...

      l_element_type_id := l_element_dtl.NEXT(l_element_type_id);

    END LOOP;
    --close csr_element_set;

    p_rate := round(l_total_rate, 5);

    debug('p_rate :'||to_char(p_rate), 60);
    --
    -- hr_utility.set_location('Leaving: '||l_proc_name, 60);
    --
    debug_exit(l_proc_name);

    return 0;


  debug('con_err: SQLCODE' || to_char(SQLCODE), 97);
  debug('con_err: SQLERRM' || SQLERRM, 97);

    --
  exception
    when hr_application_error then
    --
      debug('con_err: SQLCODE' || to_char(SQLCODE), 98);
      debug('con_err: SQLERRM' || SQLERRM, 98);
    --
      p_rate := 0;

      if csr_element_set%ISOPEN then -- BUG 4431495 : checking if cursor is open
        close csr_element_set;
      end if;

      debug('error message for contract missing :' || hr_utility.get_message, 98);

      debug('hr_application_error RAISED in Type1 rates_history function', 70);

      debug('Trying to raise a PQP error message', 98);

      -- BUG 4431495 : raising a warning message, which is being caught as an exception
      -- from pqp_rates_history_calc in SQLERRM, and passed on as token in dummy BEN messg
      -- having text as only a TOKEN

      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94268_DUMMY_MESSAGE'
                 ,p_error_number  => 94268
                 ,p_token1        => SQLERRM
                 );

      debug('Have raised a PQP error message, check on extract results ', 98);

      debug_exit(l_proc_name);
      return -1;

    WHEN OTHERS THEN
    --
      debug('con_err: SQLCODE' || to_char(SQLCODE), 99);
      debug('con_err: SQLERRM' || SQLERRM, 99);
    --

      p_rate := l_rate_nc;
      debug_exit(' Others in '||l_proc_name);
      raise;
  --
  end;

end rates_history;
--
-- RET: BUG 4135481: New function added to return the Retention Allowance Rate
-- Following the Legislative Updates to Management and Retention Allowance
-- Effective from 01-APR-2004.
-- ----------------------------------------------------------------------------
-- |------------------------< get_tp1_retention_allow_rate >--------------------|
-- ----------------------------------------------------------------------------
function get_tp1_retention_allow_rate (p_assignment_id in     number
                                      ,p_ret_allow     out    nocopy varchar2
                                    )
  return number is
--
  l_proc_name            varchar2(60) := g_proc_name || 'get_tp1_retention_allow_rate';
  l_return               number;
  l_ret_allow            number;
--
begin

  debug_enter(l_proc_name);

  l_return := calc_tp1_retention_allow_rate
                (p_assignment_id        => p_assignment_id
                ,p_effective_start_date => greatest
                                             (g_pension_year_start_date
                                             ,g_ext_asg_details(p_assignment_id).teacher_start_date
                                             )
                ,p_effective_end_date   => least
                                             (g_effective_run_date
                                             ,nvl(g_ext_asg_details(p_assignment_id).leaver_date,
                                                    g_effective_run_date)
                                             )
                ,p_rate                 => l_ret_allow
                );

  debug_exit(l_proc_name);

  if l_return <> -1 then

     p_ret_allow                  := trim(to_char(l_ret_allow,'09999'));
     return 0;

  else

    p_ret_allow := '00000';
    return -1;

  end if; -- end if of l_return check ...

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name
              ,'Y' -- turn trace off
              );
    p_ret_allow := NULL;
    RAISE;
end get_tp1_retention_allow_rate;


-- RET: BUG 4135481: New function added to return the Retention Allowance Rate
-- Following the Legislative Updates to Management and Retention Allowance
-- Effective from 01-APR-2004.
-- ----------------------------------------------------------------------------
-- |------------------------< calc_tp1_retention_allow_rate >---------------|
-- ----------------------------------------------------------------------------

FUNCTION calc_tp1_retention_allow_rate
                        (p_assignment_id        in     number
                        ,p_effective_start_date in     date
                        ,p_effective_end_date   in     date
                        ,p_rate                 in out nocopy number
                        )
                        RETURN NUMBER IS

--
  l_proc_name varchar2(60) := g_proc_name ||
                                        'calc_tp1_retention_allow_rate';


  l_tab_mult_asg            t_sec_asgs_type;
  l_sec_effective_date      date;
  l_primary_esd             date;
  l_return                  number;
  l_error                   number;
  l_rate_nc                 number;
  i                         number;
  l_primary_eed             date;
  l_sec_eed                 date;

  l_total_rert_allowance_rate number := 0;
  l_retention_allowance_rate number;
 --


BEGIN
--

  debug_enter(l_proc_name);

  -- nocopy changes
  l_rate_nc := p_rate;

  --
  debug('p_assignment_id :'||to_char(p_assignment_id), 10);
  debug('Start date :'||to_char(p_effective_start_date,'DD/MM/YY'));
  debug('End date   :'||to_char(p_effective_end_date,'DD/MM/YY'));
  --

  -- Check if the primary asg is valid TCHR assignment
  -- on the p_effective_start_date
  -- MULT-LR --
  -- Use the new Function to check the effectivness of an assignment
  -- it takes care of multiple Leaver-Restarter events
  -- where as the old logic used to take into account
  -- only the first restarter event.

  IF ( chk_effective_asg (p_assignment_id   => p_assignment_id
                         ,p_effective_date  => p_effective_start_date
                         ) = 'Y'
      )
  THEN
  --
    debug(l_proc_name, 20);
    --     We need to calculate
    --     from start of primary asg as its possible that
    --     primary asg bcomes a teacher after secondary
    l_primary_esd := GREATEST(p_effective_start_date
                             ,g_ext_asg_details(p_assignment_id).start_date
                              );

    debug('l_primary_esd :'||to_char(l_primary_esd,'DD/MM/YY'),30);

    -- MULT-LR --
    -- Use the new Function to get the correct end date
    -- based on the multiple restarter events
    -- It takes care of multiple Leaver-Restarter events
    -- where as the old logic used to take into account
    -- only the first restarter event.

    -- Performance changes
    -- no need to call tihs function as we are checking assignment status in chk_effective_asg
    /*
    l_primary_eed := get_eff_end_date
                             (p_assignment_id        => p_assignment_id
                             ,p_effective_start_date => p_effective_start_date
                             ,p_effective_end_date   => p_effective_end_date
                             ) ;
    */

    l_primary_eed := p_effective_end_date;

    debug('l_primary_eed :'||to_char(l_primary_eed,'DD/MM/YY'),40);

    -- Call rates_history function for primary assignment
    -- No Rate type available, so PASS Null, this will work as an identifier
    -- for rates_history function to derive the Ratention Allowance Rate
    -- Which otherwise expects a Rate Type as input.

    l_return :=  rates_history
                        (p_assignment_id    => p_assignment_id
                        ,p_calculation_date => l_primary_esd
                        ,p_rate_type_name   => NULL
                        ,p_fte              => 'N'
                        ,p_to_time_dim      => 'A'
                        ,p_safeguarded_yn   => NULL
                        ,p_rate             => l_retention_allowance_rate
                        );
        --
        if l_return <> -1 then
          debug('l_retention_allowance_rate :'||to_char(l_retention_allowance_rate), 50);
          l_total_rert_allowance_rate := l_total_rert_allowance_rate + l_retention_allowance_rate;
                debug('l_total_rert_allowance_rate :'||to_char(l_total_rert_allowance_rate), 60);
        else
          debug_exit(l_proc_name);
          p_rate      := 0;
          return -1;
        end if;
        --

  --
  ELSE -- primary not valid asg
  --
    debug(l_proc_name, 70);
    l_total_rert_allowance_rate := 0;
    l_return                       := 0;
  --

  END IF; -- primary not valid asg

  --
  IF l_return <> -1 THEN

    -- Check for multiple assignments
    debug(l_proc_name, 80);

    --
    -- Bugfix 3803760:FTSUPPLY : Now using g_tab_sec_asgs instead of
    --  calling get_eff_secondary_asgs
    l_tab_mult_asg := g_tab_sec_asgs;

    debug('l_tab_mult_asg.count :'|| to_char(l_tab_mult_asg.count),90);

    IF l_tab_mult_asg.count > 0 THEN
      --
      debug(l_proc_name, 110);
      --

      i := l_tab_mult_asg.FIRST;

      -- get the annual_salary_rate for secondary assignments
      -- and check for equality
      -- store the slaary rates and dates in global collection,
      -- as it may be required later.

      WHILE i IS NOT NULL
      LOOP
        --
        debug (l_proc_name||'Assignment Id:'||to_char(nvl(l_tab_mult_asg(i).assignment_id,99999)),120);
        l_sec_effective_date := greatest
                               (p_effective_start_date
                               ,g_ext_asg_details(l_tab_mult_asg(i).assignment_id).start_date);

        debug('l_sec_effective_date :'|| to_char(l_sec_effective_date,'DD/MM/YYYY'),130);


        -- MULT-LR --
        -- Use the new Function to get the correct end date
        -- based on the multiple restarter events
        -- It takes care of multiple Leaver-Restarter events
        -- where as the old logic used to take into account
        -- only the first restarter event.

        -- Performance changes
        -- no need to call tihs function as we are checking assignment status in chk_effective_asg
        /*
        l_sec_eed := get_eff_end_date ( p_assignment_id        => l_tab_mult_asg(i).assignment_id
                                       ,p_effective_start_date => p_effective_start_date
                                       ,p_effective_end_date   => p_effective_end_date
                                       ) ;
        */
        l_sec_eed := p_effective_end_date;

        debug('l_sec_eed :'||to_char(l_sec_eed,'DD/MM/YYYY'),140);

        -- Call rates_history function for secondary assignments
        -- No Rate type available, so PASS Null, this will work as an identifier
        -- for rates_history function to derive the Ratention Allowance Rate
        -- Which otherwise expects a Rate Type as input.

        l_return :=  rates_history
                        (p_assignment_id    => l_tab_mult_asg(i).assignment_id
                        ,p_calculation_date => l_sec_effective_date
                        ,p_rate_type_name   => NULL
                        ,p_fte              => 'N'
                        ,p_to_time_dim      => 'A'
                        ,p_safeguarded_yn   => NULL
                        ,p_rate             => l_retention_allowance_rate
                        );

              --
        if l_return <> -1 then
          debug('l_retention_allowance_rate :'||to_char(l_retention_allowance_rate), 150);
          l_total_rert_allowance_rate := l_total_rert_allowance_rate + l_retention_allowance_rate;
                debug('l_total_rert_allowance_rate :'||to_char(l_total_rert_allowance_rate), 160);
        else
          debug_exit(l_proc_name);
          p_rate      := 0;
          return -1;
        end if;
        --


        i := l_tab_mult_asg.NEXT(i);

      END LOOP;

      debug('After loop----', 170);

    END IF;  -- l_tab_mult_asg.count > 0

    debug('Retention Allowance : '||to_char(l_total_rert_allowance_rate),175);

   -- Check whether retention allowance rate has exceeded the 4 digit limit ...
    IF l_total_rert_allowance_rate > 99999 THEN

            l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_93041_EXT_TP1_ANN_VAL_EXC'
                 ,p_error_number  => 93041
                 -- RET: token introduced in error message
                 ,p_token1        => 'Recruitment Retention '|| TO_CHAR(l_total_rert_allowance_rate)
                 ,p_token2        => TO_CHAR(99999) -- bug : 4336613
                 );

      p_rate := 99999;

    ELSE  -- end if of annual sal rate limit check ...
      debug('Total Retention Allowance Rate :'||to_char(l_total_rert_allowance_rate),180);
      p_rate := l_total_rert_allowance_rate;

    END IF ; -- end if of annual sal rate limit check ...

    debug('p_rate : '||to_char(p_rate),185);


    debug_exit (l_proc_name);

    RETURN 0;

  ELSE -- else of return <> -1 on prim asg check...

    debug_exit (l_proc_name);
    p_rate      := 0;

    RETURN -1;

  END IF ; -- end if of return <> -1 on prim asg check...

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(' Others in '||l_proc_name);
       p_rate := l_rate_nc;
       raise;

END calc_tp1_retention_allow_rate;

--
-- ----------------------------------------------------------------------------
-- |------------------------< calc_annual_sal_rate >---------------------------|
-- ----------------------------------------------------------------------------
function calc_annual_sal_rate (p_assignment_id        in     number
                              ,p_calculation_date     in     date
                              ,p_safeguarded_yn       in     varchar2
                              ,p_fte                  in     varchar2
                              ,p_to_time_dim          in     varchar2
                              ,p_rate                 in out nocopy number
                              ,p_effective_start_date in     date
                              ,p_effective_end_date   in     date
                              )
  return number is
--
  l_proc_name        varchar2(60) := g_proc_name || 'calc_annual_sal_rate';
  l_annual_rate      number := 0;
  l_lonsoc_allowance number;
  l_other_allowance  number;
  l_basic_salary     number;
  l_return           number;
  l_rate_name        per_grades.name%type;

  l_rate_nc          number;

  -- 4336613 : OSLA_3A
  l_grossed_osla_payment number;

--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- nocopy changes
  l_rate_nc := p_rate;


  -- PERF_ENHANC_3A : Performance Enhancements
  -- check if record corresponding to p_assignment_id is present in the
  -- collection g_asg_recalc_details.
  -- If yes, check for matching start_date (a double check,although not necessary)
  -- If full_time_sal_rate has been calculated before, then the row
  -- will contain the value,return it.
  -- If full_time_sal_rate for this assignment has not been calculated before,
  -- compute it, store it in a row for this assignment_id and return it
  -- This step is to avoid recomputing the value for a given LOS. Originally,
  -- calculations were repeated for each data element

  IF (g_asg_recalc_details.EXISTS(p_assignment_id)
      AND
      g_asg_recalc_details(p_assignment_id).eff_start_date = p_effective_start_date
      AND
      g_asg_recalc_details(p_assignment_id).full_time_sal_rate IS NOT NULL
      ) THEN

    p_rate := g_asg_recalc_details(p_assignment_id).full_time_sal_rate;
    debug('full_time_sal_rate is already present !! '||p_rate, 5);

  ELSE -- calc_part_time_paid has to be computed for this assignment_id for this LOS


    -- Bug fix 2786740
    -- London rate type, other allowance need not have a value
    -- always

    IF g_lon_rate_type IS NOT NULL THEN

       -- Find annual rate for London and special needs allowance
       l_return := rates_history
                     (p_assignment_id    => p_assignment_id
                     ,p_calculation_date => p_calculation_date
                     ,p_rate_type_name   => g_lon_rate_type
                     ,p_fte              => p_fte
                     ,p_to_time_dim      => p_to_time_dim
                     ,p_safeguarded_yn   => p_safeguarded_yn
                     ,p_rate             => l_lonsoc_allowance
                     );

       if l_return <> -1 then

          l_annual_rate := l_annual_rate + nvl(l_lonsoc_allowance, 0);

       else

         debug_exit(l_proc_name);
         p_rate      := 0;
         return -1;

       end if; -- end if of london allowance return value check...

    END IF; -- End if of g_lon_rate_type is not null check ...

    --
    debug(l_proc_name, 20);
    --

    IF g_oth_rate_type IS NOT NULL THEN

       -- Find rate for Other allowance
       l_return := rates_history
                     (p_assignment_id    => p_assignment_id
                     ,p_calculation_date => p_calculation_date
                     ,p_rate_type_name   => g_oth_rate_type
                     ,p_fte              => p_fte
                     ,p_to_time_dim      => p_to_time_dim
                     ,p_safeguarded_yn   => p_safeguarded_yn
                     ,p_rate             => l_other_allowance
                     );

       if l_return <> -1 then

          debug('l_other_allowance: '||l_other_allowance,25);
          l_annual_rate                      := l_annual_rate + nvl(l_other_allowance,0);
          debug('l_annual_rate: '||l_annual_rate,25);
          g_other_allowance(p_assignment_id) := nvl(l_other_allowance, 0);

       else

         debug_exit(l_proc_name);
         p_rate      := 0;
         return -1;

       end if; -- end if of other allowance return value check...

    ELSE
      g_other_allowance(p_assignment_id) := 0; -- Bug 4454427 :resetting value to 0

    END IF; -- End if of g_oth_rate_type is not null check ...

    debug('g_other_allowance(p_assignment_id): '||g_other_allowance(p_assignment_id),26);


    -- 4336613 : OSLA_3A : OSLA grossed payment function call
    l_grossed_osla_payment := get_grossed_osla_payments
                                     (p_assignment_id        => p_assignment_id
                                     ,p_effective_start_date => p_effective_start_date
                                     ,p_effective_end_date   => p_effective_end_date
                                     ,p_business_group_id    => g_business_group_id
                                     );

      -- 4336613 : OSLA_3A : add OSLA payments to annual sal rate and other allowances

    debug('l_grossed_osla_payment: '||l_grossed_osla_payment,27);
    l_annual_rate                        := l_annual_rate + l_grossed_osla_payment;
    debug('l_annual_rate: '||l_annual_rate,27);

    -- if grossed OSLA payments exist (non-zero), then add to Other Allowance
    IF l_grossed_osla_payment <> 0 THEN
      -- this is to avoid adding to a NULL value
      -- in case other_allowance has a value, add to it. Else, assign to it.
      IF (g_oth_rate_type IS NOT NULL) THEN
        g_other_allowance(p_assignment_id) := g_other_allowance(p_assignment_id) + l_grossed_osla_payment;
      ELSE
        g_other_allowance(p_assignment_id) := l_grossed_osla_payment;
      END IF;
    END IF;

    debug('g_other_allowance(p_assignment_id): '||g_other_allowance(p_assignment_id),28);


    --
    debug(l_proc_name, 30);
    --
    -- Find rate for Basic Salary
    select decode(p_safeguarded_yn
                 ,'Y'
                 ,g_sf_rate_type
                 ,g_sal_rate_type)
      into l_rate_name
      from dual;

    debug('l_rate_name :'||l_rate_name, 40);

    l_return := rates_history
                  (p_assignment_id    => p_assignment_id
                  ,p_calculation_date => p_calculation_date
                  ,p_rate_type_name   => l_rate_name
                  ,p_fte              => p_fte
                  ,p_to_time_dim      => p_to_time_dim
                  ,p_safeguarded_yn   => p_safeguarded_yn
                  ,p_rate             => l_basic_salary
                  );

    debug('Basic Salary :'||l_basic_salary, 50);

    if l_return <> -1 then

       l_annual_rate := l_annual_rate + nvl(l_basic_salary,0);

    else

      debug_exit(l_proc_name);
      p_rate      := 0;
      return -1;

    end if; -- end if of basic salary return value check...

    debug('Total Annual Rate :'||l_annual_rate);

    --
    -- hr_utility.set_location('Leaving: '||l_proc_name, 50);
    --
    debug_exit(l_proc_name);

    --PERF_ENHANC_3A : performance enhancements
    -- computed full_time_sal_rate value being stored in the collection for future use
    g_asg_recalc_details(p_assignment_id).full_time_sal_rate := l_annual_rate;
    debug('full_time_sal_rate (1st time computation) :'|| l_annual_rate,55);

    p_rate := l_annual_rate;


  END IF; -- IF (g_asg_recalc_details.EXISTS.... )

  return 0;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       p_rate := l_rate_nc;
       debug_exit(' Others in '||l_proc_name);
       raise;

  --
end calc_annual_sal_rate;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_safeguarded_info >--------------------------|
-- ----------------------------------------------------------------------------
function get_safeguarded_info (p_assignment_id  in    number
                              ,p_effective_date in    date
                              )
  return varchar2 is
--
  l_proc_name            varchar2(60) := g_proc_name || 'get_safeguarded_info';
  l_paa_info             csr_paa_rate_id%rowtype;
  l_safeguarded_yn       varchar2(1) := 'N';
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  open csr_paa_rate_id (c_assignment_id  => p_assignment_id
                       ,c_effective_date => p_effective_date
                       );
  fetch csr_paa_rate_id into l_paa_info;
  close csr_paa_rate_id;

  if (( l_paa_info.tp_safeguarded_rate_type is not null)
        and (l_paa_info.tp_safeguarded_rate_type <> 'SN' )) then

     l_safeguarded_yn := 'Y';

  end if; -- end if of tp_safeguarded_grade is not null check...

  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 20);
  --
  debug_exit(l_proc_name);

  return l_safeguarded_yn;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end get_safeguarded_info;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_fte_for_asg >----------------------|
-- ----------------------------------------------------------------------------
-- Bug 3889646
-- The function will fetch the FTE value
-- from assignment budget values
-- using fte_utilities.
-- if not found then
-- it calculates the fte from
-- average salary calculations.

FUNCTION get_fte_for_asg(p_assignment_id         IN  NUMBER
                        ,p_effective_start_date  IN  DATE
                        ,p_effective_end_date    IN  DATE
                        ,p_annual_sal_rate       IN  NUMBER
                        ,p_business_group_id     IN  NUMBER
                         )
return NUMBER IS

  l_proc_name                varchar2(60) := g_proc_name || 'get_fte_for_asg';
  l_days_in_period           NUMBER ;
  l_no_of_days_in_year       NUMBER := 365;
  l_total_part_time_sal_paid NUMBER;
  l_avg_sal_for_period       NUMBER;
  l_fte                      NUMBER := 0;

BEGIN
  debug_enter(l_proc_name);

  debug('p_assignment_id '|| to_char(p_assignment_id) ,10 ) ;
  debug('p_effective_start_date '|| to_char(p_effective_start_date,'DD/MM/YYYY') ) ;
  debug('p_effective_end_date '|| to_char(p_effective_end_date,'DD/MM/YYYY') ) ;
  debug('p_annual_sal_rate '|| to_char(p_annual_sal_rate) ) ;
  debug('p_business_group_id '|| to_char(p_business_group_id) ) ;

  -- Get FTE value for primary assignment
  l_fte := pqp_fte_utilities.get_fte_value
                 (p_assignment_id    => p_assignment_id
                 ,p_calculation_date => p_effective_start_date
                  );
  debug('l_fte '|| l_fte ,20 ) ;
  IF l_fte is null or l_fte = 0  THEN

    debug(l_proc_name, 30) ;

    l_days_in_period := (trunc(p_effective_end_date) - trunc(p_effective_start_date)) + 1;

    debug('l_days_in_period '|| to_char(l_days_in_period) ,40 ) ;
    IF l_days_in_period > l_no_of_days_in_year THEN
      l_days_in_period := l_no_of_days_in_year ;
    END IF ;
    debug('l_days_in_period :'||to_char(l_days_in_period), 50);

    l_total_part_time_sal_paid := calc_part_time_sal
                                        (p_assignment_id        => p_assignment_id
                                        ,p_effective_start_date => p_effective_start_date
                                        ,p_effective_end_date   => p_effective_end_date
                                        ,p_business_group_id    => p_business_group_id
                                        );
    debug('l_total_part_time_sal_paid :'||to_char(l_total_part_time_sal_paid),60);

    IF l_total_part_time_sal_paid = 0 THEN
      debug('Part Time salary paid is ZERO for the period ' , 70);
      debug(to_char(p_effective_start_date,'dd/mm/yyyy') || ' to ' || to_char(p_effective_end_date,'dd/mm/yyyy')) ;
      debug('need to RAISE a warning here') ;
    END IF;

    l_avg_sal_for_period := (p_annual_sal_rate/l_no_of_days_in_year) * l_days_in_period ;
    debug('l_avg_sal_for_period :'||to_char(l_avg_sal_for_period), 80);

    IF l_avg_sal_for_period <> 0 THEN
      debug(l_proc_name, 90);
      l_fte  := (l_total_part_time_sal_paid/l_avg_sal_for_period);
    ELSE
      debug(l_proc_name, 110);
      l_fte := 0;
    END IF ;
  END IF ; --l_fte = 0 or NULL

  debug('l_fte :'||to_char(l_fte));

  debug_exit (l_proc_name);
  RETURN l_fte;

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(' Others in '||l_proc_name);
       raise;

END get_fte_for_asg;

-- ----------------------------------------------------------------------------
-- |------------------------< get_annual_sal_rate_date >----------------------|
-- ----------------------------------------------------------------------------
function get_annual_sal_rate_date (p_assignment_id        in     number
                                  ,p_effective_start_date in     date
                                  ,p_effective_end_date   in     date
                                  ,p_rate                 in out nocopy number
                                  )
  return number is
--
  l_proc_name               varchar2(60) := g_proc_name || 'get_annual_sal_rate_date';
  l_safeguarded_yn          varchar2(1);
  l_annual_sal_rate         number;
  l_actual_ann_sal_rate     number := 0;
  l_actual_other_allowance  number := 0;
  l_fte                     number := 0;
  l_total_fte               number := 0;
  l_total_oth_alo_fte       number := 0;
  l_sec_annual_sal_rate     number;
  l_total_annual_sal_rate   number := 0;
  l_total_other_allowance   number := 0;
  l_tab_mult_asg            t_sec_asgs_type;
  l_sec_effective_date      date;
  l_primary_esd             date;
  l_return                  number;
  l_error                   number;

  l_rate_nc                 number;
  i                         number;
  -- new Variable added for FTE calculation changes.
  l_total_part_time_sal_paid number := 0;
  l_no_of_days_in_year       number := 365 ;
  l_days_in_period           number := 0 ;
  l_avg_sal_for_period       number := 0;
  l_primary_eed              date;
  l_sec_eed                  date;
  --new variable added for FTE calc changes.
  l_prev_annual_sal_rate     number := NULL;
  l_equal_sal_rate           varchar2(1) := 'Y';
  --Flags for showing warning for a LoS
  l_warn_for_sal_rate        varchar2(1) := 'N';
  l_warn_for_sal_paid        varchar2(1) := 'N';

  -- changed g_asg_sal_rate to a local variable as
  -- this is not being eferenced from outside this function.
  l_asg_sal_rate             t_asg_salary_rate_type;
  l_gtc_payments             number;

 --
BEGIN
  -- Bug 3889646
  -- This function is enhanced and
  -- the following logic is applied.
  -- This function gets the salary rates
  -- for all assignments valid in the period.
  -- if all the salary rates are equal, then
  -- this salary rate is returned
  -- as Full Time Salary Rate
  -- else we do the average salary rate calculation

  -- Average salary rate calculation :
  -- first we check for the stored FTE
  -- at assignment budget values.
  -- if found then
  -- this value is used as
  -- the FTE for the assignment
  -- else FTE is calculated on the fly
  -- by calculating average salary rate
  -- and Part time salary paid.
  -- all the FTE calculation is done separatly
  -- in the get_fte_for_asg function
  -- then this FTE value is used as
  -- per the following formula
  -- for average salary rate calculation

  -- Average Salary Rate Formula
  -- avg sal rate = (sal_rate1 * fte1 + sal_rate2 * fte2 +....)/(fte1 + fte2 + ....)

  debug_enter(l_proc_name);

  -- nocopy changes
  l_rate_nc := p_rate;

  -- This global has been removed.
  -- clear the global values.
  -- g_asg_sal_rate.DELETE;

  --
  debug('p_assignment_id :'||to_char(p_assignment_id), 10);
  debug('Start date :'||to_char(p_effective_start_date,'DD/MM/YY'));
  debug('End date   :'||to_char(p_effective_end_date,'DD/MM/YY'));

  -- Get the safeguarded information and the annual rate
  -- for primary assignment only if the assignment qualifies
  -- for inclusion in the report
  -- Bug Fix 3073562:GAP6

  -- Check if the primary asg is valid TCHR assignment
  -- on the p_effective_start_date
  -- MULT-LR --
  -- Use the new Function to check the effectivness of an assignment
  -- it takes care of multiple Leaver-Restarter events
  -- where as the old logic used to take into account
  -- only the first restarter event.
  IF ( chk_effective_asg (
           p_assignment_id   => p_assignment_id
          ,p_effective_date  => p_effective_start_date
                          ) = 'Y'
      )
  THEN
    debug(l_proc_name, 20);
    -- Bugfix 3641851:CBF1 : We need to calculate the sal rate
    --     from start of primary asg as its possible that
    --     primary asg bcomes a teacher after secondary
    l_primary_esd := GREATEST(p_effective_start_date
                              ,g_ext_asg_details(p_assignment_id).start_date
                              );
    debug('l_primary_esd :'||to_char(l_primary_esd,'DD/MM/YY'),30);


    -- MULT-LR --
    -- Use the new Function to get the correct end date
    -- based on the multiple restarter events
    -- It takes care of multiple Leaver-Restarter events
    -- where as the old logic used to take into account
    -- only the first restarter event.

    -- Performance changes
    -- no need to call tihs function as we are checking assignment status in chk_effective_asg
    /*
    l_primary_eed := get_eff_end_date ( p_assignment_id        => p_assignment_id
                                       ,p_effective_start_date => p_effective_start_date
                                       ,p_effective_end_date   => p_effective_end_date
                                       ) ;
    */

    l_primary_eed := p_effective_end_date;


    debug('l_primary_eed :'||to_char(l_primary_eed,'DD/MM/YY'),40);
    --
    -- Get safeguarded information

    l_safeguarded_yn := get_safeguarded_info
                           (p_assignment_id  => p_assignment_id
                           -- Bugfix 3641851:CBF1 : Changed to l_primary_esd
                           ,p_effective_date => l_primary_esd
                           );

    --
    debug('Safeguarded :'||l_safeguarded_yn,50);
    --
    -- Get the annual sal rate for primary assignment

    l_return := calc_annual_sal_rate
                  (p_assignment_id        => p_assignment_id
                   -- Bugfix 3641851:CBF1 : Changed to l_primary_esd
                  ,p_calculation_date     => l_primary_esd
                  ,p_safeguarded_yn       => l_safeguarded_yn
                  ,p_fte                  => 'N'
                  ,p_to_time_dim          => 'A'
                  ,p_rate                 => l_annual_sal_rate
                  ,p_effective_start_date => p_effective_start_date
                  ,p_effective_end_date   => p_effective_end_date
                  );
    debug('l_annual_sal_rate '||to_char(l_annual_sal_rate), 60) ;
    debug('l_return '||to_char(l_return)) ;

    IF l_return <> -1 THEN  --No error
      IF l_annual_sal_rate <> 0 THEN
        -- store the values in the global
        -- may be required later for average salary calculation
        l_asg_sal_rate(p_assignment_id).salary_rate    := l_annual_sal_rate ;
        l_asg_sal_rate(p_assignment_id).eff_start_date := l_primary_esd ;
        l_asg_sal_rate(p_assignment_id).eff_end_date   := l_primary_eed ;
        --Store the val in another var for comparison later.
        l_prev_annual_sal_rate                         := l_annual_sal_rate ;

        IF g_other_allowance.exists(p_assignment_id) THEN
          debug(l_proc_name, 70);
          l_total_other_allowance := g_other_allowance(p_assignment_id);
        END IF;

        debug('l_total_other_allowance :'||to_char(l_total_other_allowance),80);

        l_gtc_payments := get_gtc_payments(p_assignment_id => p_assignment_id,
                                   p_effective_start_date =>p_effective_start_date,
                                   p_effective_end_date   => p_effective_end_date,
                                   p_business_group_id  => g_business_group_id
                                   );

        g_gtc_payments:= g_gtc_payments + l_gtc_payments;

      ELSE  --l_annual_sal_rate <> 0
        debug(l_proc_name, 90);
        -- if Annual Salary rate is ZERO
        -- set the warning flag to 'Y'
        -- will warn at the end of the function
        l_warn_for_sal_rate  := 'Y' ;

        l_asg_sal_rate(p_assignment_id).salary_rate    := 0 ;
        l_asg_sal_rate(p_assignment_id).eff_start_date := l_primary_esd ;
        l_asg_sal_rate(p_assignment_id).eff_end_date   := l_primary_eed ;

      END IF ;  --l_annual_sal_rate <> 0
    END IF;  --l_return <> -1


  ELSE -- primary not valid asg
    debug(l_proc_name, 110);
    l_annual_sal_rate := 0;
    l_return          := 0;
  END IF; -- primary not valid asg

  debug('Annual Sal Rate :'||to_char(l_annual_sal_rate), 120);

  --
  IF l_return <> -1 THEN
    -- Check for multiple assignments
    debug(l_proc_name, 130);
    --
    -- Bugfix 3803760:FTSUPPLY : Now using g_tab_sec_asgs instead of
    --  calling get_eff_secondary_asgs
    l_tab_mult_asg := g_tab_sec_asgs;

    debug('l_tab_mult_asg.count :'|| to_char(l_tab_mult_asg.count),140);
    IF l_tab_mult_asg.count > 0 THEN
      --
      debug(l_proc_name, 150);
      --
      i := l_tab_mult_asg.FIRST;
      -- get the annual_salary_rate for secondary assignments
      -- and check for equality
      -- store the slaary rates and dates in global collection,
      -- as it may be required later.

      WHILE i IS NOT NULL
      LOOP
        --
        debug (l_proc_name||'Assignment Id:'||to_char(nvl(l_tab_mult_asg(i).assignment_id,99999)),160);

        l_sec_effective_date := greatest
                               (p_effective_start_date
                               ,g_ext_asg_details(l_tab_mult_asg(i).assignment_id).start_date);
        debug('l_sec_effective_date :'|| to_char(l_sec_effective_date,'DD/MM/YYYY'),170);
        l_gtc_payments := 0;

        -- MULT-LR --
        -- Use the new Function to get the correct end date
        -- based on the multiple restarter events
        -- It takes care of multiple Leaver-Restarter events
        -- where as the old logic used to take into account
        -- only the first restarter event.

        -- Performance changes
        -- no need to call tihs function as we are checking assignment status in chk_effective_asg
        /*

        l_sec_eed := get_eff_end_date ( p_assignment_id        => l_tab_mult_asg(i).assignment_id
                                       ,p_effective_start_date => p_effective_start_date
                                       ,p_effective_end_date   => p_effective_end_date
                                       ) ;
        */

        l_sec_eed := p_effective_end_date;


        debug('l_sec_eed :'||to_char(l_sec_eed,'DD/MM/YYYY'),180);

        l_safeguarded_yn := get_safeguarded_info
                               (p_assignment_id  => l_tab_mult_asg(i).assignment_id
                               ,p_effective_date => l_sec_effective_date
                               );
        debug('l_safeguarded_yn :'||l_safeguarded_yn,190);

        -- Get annual sal rate for secondary assignments
        l_return := calc_annual_sal_rate
                    (p_assignment_id        => l_tab_mult_asg(i).assignment_id
                    ,p_calculation_date     => l_sec_effective_date
                    ,p_safeguarded_yn       => l_safeguarded_yn
                    ,p_fte                  => 'N'
                    ,p_to_time_dim          => 'A'
                    ,p_rate                 => l_sec_annual_sal_rate
                    ,p_effective_start_date => p_effective_start_date
                    ,p_effective_end_date   => p_effective_end_date
                    );
        debug('l_sec_annual_sal_rate :'||l_sec_annual_sal_rate, 195);

        IF l_return <> -1 THEN
          IF l_sec_annual_sal_rate = 0 THEN

            debug('RAISE A warning for ZERO sal rate ----',210);
            -- Set the flag for Warning Message
            l_warn_for_sal_rate := 'Y' ;

            l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).salary_rate     := 0 ;
            l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).eff_start_date  := l_sec_effective_date ;
            l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).eff_end_date    := l_sec_eed ;

          ELSE

            debug(l_proc_name, 215);
            l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).salary_rate     := l_sec_annual_sal_rate;
            l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).eff_start_date  := l_sec_effective_date ;
            l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).eff_end_date    := l_sec_eed ;

            IF g_other_allowance.exists(l_tab_mult_asg(i).assignment_id) THEN
              debug(l_proc_name, 220);
              l_total_other_allowance := l_total_other_allowance + nvl(g_other_allowance(l_tab_mult_asg(i).assignment_id), 0);
            END IF ;

            debug('l_total_other_allowance :'||to_char(l_total_other_allowance),230);

            --compare with the previous salary rate and set the flag to 'N'
            -- as soon as a different sal_rate is found.
            IF l_prev_annual_sal_rate is not NULL THEN
               debug(l_proc_name, 240);

               IF l_sec_annual_sal_rate <> l_prev_annual_sal_rate THEN
                 debug(l_proc_name, 250);
                 l_equal_sal_rate := 'N' ;
               ELSE
                 debug('sal_rate are equal for this iteration',260);
               END IF;

             ELSE  -- l_prev_annual_sal_rate is not Null
               --The first valid assignment
               debug(l_proc_name, 270);
               l_prev_annual_sal_rate := l_sec_annual_sal_rate ;
             END IF ; --l_prev_annual_sal_rate <> 0

          END IF ; --l_sec_annual_sal_rate = 0

        ELSE  --l_return <> -1
          debug('error returned from calc_annual_sal_rate',280) ;
          debug('need to raise a warning from here....') ;
          p_rate      := 0;
          debug_exit (l_proc_name);
          RETURN -1;
        END IF ;  --l_return <> -1

        l_gtc_payments := get_gtc_payments(p_assignment_id => l_tab_mult_asg(i).assignment_id,
                                   p_effective_start_date =>p_effective_start_date,
                                   p_effective_end_date   => p_effective_end_date,
                                   p_business_group_id  => g_business_group_id
                                   );
         g_gtc_payments := g_gtc_payments + l_gtc_payments;

        i := l_tab_mult_asg.NEXT(i);

      END LOOP;
      debug('After loop----', 290);

    END IF;  -- l_tab_mult_asg.count > 0

    debug('l_equal_sal_rate '|| l_equal_sal_rate, 310);

    -- check if the flag is still 'Y'
    -- return the salary rate .
    -- else go to the average calculation
    -- Added for 5460058
    g_equal_sal_rate  := l_equal_sal_rate;
    IF l_equal_sal_rate = 'Y'  THEN
      debug(l_proc_name, 320);

      IF l_prev_annual_sal_rate is NOT NULL THEN
        l_actual_ann_sal_rate := l_prev_annual_sal_rate ;
      ELSE
        l_actual_ann_sal_rate := 0;
      END IF ;

      l_actual_other_allowance := l_total_other_allowance ;

    ELSE  ----l_equal_sal_rate = 'Y'
    -- need to get the average salary calculation and calculate the FTE.

      debug(l_proc_name, 330);

      -- reset the two variables
      -- as average calcultions will be done here as well.
      l_actual_other_allowance := 0;
      l_total_other_allowance  := 0;

      -- MULT-LR --
      -- Use the new Function to check the effectivness of an assignment
      -- it takes care of multiple Leaver-Restarter events
      -- where as the old logic used to take into account
      -- only the first restarter event.

      IF ( chk_effective_asg (
               p_assignment_id  => p_assignment_id
              ,p_effective_date => p_effective_start_date
                              ) = 'Y'
          )
      THEN
        debug(l_proc_name, 340);
        l_fte := get_fte_for_asg(
                     p_assignment_id        => p_assignment_id
                    ,p_effective_start_date => l_asg_sal_rate(p_assignment_id).eff_start_date
                    ,p_effective_end_date   => l_asg_sal_rate(p_assignment_id).eff_end_date
                    ,p_annual_sal_rate      => l_asg_sal_rate(p_assignment_id).salary_rate
                    ,p_business_group_id    => g_ext_asg_details(p_assignment_id).business_group_id
                                );

        debug('l_fte ' ||to_char(l_fte), 350);
        IF l_fte = 0 THEN
           debug('set warning for FTE = 0', 355) ;
          l_warn_for_sal_paid :='Y' ;
        END IF;
        --storing FTE, just in case we need it in future.
        l_asg_sal_rate(p_assignment_id).fte := l_fte ;

        l_total_annual_sal_rate := l_fte * l_asg_sal_rate(p_assignment_id).salary_rate;
        l_total_fte             := l_fte;
        debug('l_total_annual_sal_rate :'||l_total_annual_sal_rate,360);
        debug('l_total_fte :'||l_total_fte);

        IF g_other_allowance.exists(p_assignment_id) AND
           g_other_allowance(p_assignment_id) <> 0
        THEN
          debug(l_proc_name, 370);
          l_total_other_allowance  := g_other_allowance(p_assignment_id) * l_fte;
          l_total_oth_alo_fte      := l_fte;
        END IF; -- end if of other allowance check ...
      END IF ;  --Check if Priamry is Valid

      i := l_tab_mult_asg.FIRST;
      WHILE i IS NOT NULL
      LOOP
        --
        debug (l_proc_name||'Assignment Id:'||to_char(nvl(l_tab_mult_asg(i).assignment_id,99999)),380);

        l_fte := get_fte_for_asg(
                      p_assignment_id        => l_tab_mult_asg(i).assignment_id
                     ,p_effective_start_date => l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).eff_start_date
                     ,p_effective_end_date   => l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).eff_end_date
                     ,p_annual_sal_rate      => l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).salary_rate
                     ,p_business_group_id    => g_ext_asg_details(l_tab_mult_asg(i).assignment_id).business_group_id
                                );

        debug('l_fte :'|| to_char(l_fte), 390);

        IF l_fte = 0 THEN
          debug('set warning for FTE = 0', 395) ;
          l_warn_for_sal_paid :='Y' ;
        END IF;
        --storing FTE, just in case we need it in future.
        l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).fte := l_fte ;

        l_total_annual_sal_rate := l_total_annual_sal_rate +
                                   (l_asg_sal_rate(l_tab_mult_asg(i).assignment_id).salary_rate * l_fte);
        l_total_fte             := l_total_fte + l_fte;
        debug('l_total_annual_sal_rate :'|| to_char(l_total_annual_sal_rate),410);
        debug('l_total_fte :'|| to_char(l_total_fte));

        IF g_other_allowance.exists(l_tab_mult_asg(i).assignment_id) AND
           g_other_allowance(l_tab_mult_asg(i).assignment_id) <> 0
        THEN
          debug(l_proc_name, 420);
          l_total_other_allowance := l_total_other_allowance +
                                     (g_other_allowance(l_tab_mult_asg(i).assignment_id) * l_fte);
          l_total_oth_alo_fte     := l_total_oth_alo_fte + l_fte;
        END IF; -- end if of other allowance exists check...

        i := l_tab_mult_asg.NEXT(i);

      END LOOP;

      debug (l_proc_name ||'Total Secondary Asgs: '||TO_CHAR(l_tab_mult_asg.COUNT),430);

      debug('l_total_fte ' ||to_char(l_total_fte), 440);
      debug('l_total_annual_sal_rate ' ||to_char(l_total_annual_sal_rate));

      IF l_total_fte <> 0 THEN
        debug(l_proc_name, 450);
        l_actual_ann_sal_rate    := l_total_annual_sal_rate/l_total_fte;
        debug('l_actual_ann_sal_rate ' ||to_char(l_actual_ann_sal_rate));
      ELSE
        debug(l_proc_name,460);
        l_actual_ann_sal_rate := 0 ;
        --p_rate := 0;
      END IF ;

      IF l_total_oth_alo_fte <> 0 THEN
        debug(l_proc_name,470);
        l_actual_other_allowance := l_total_other_allowance/l_total_oth_alo_fte;
      ELSE
          debug(l_proc_name,480);
          l_actual_other_allowance := 0;
      END IF; -- end if of other allowance exists check ...

    END IF ; --l_equal_sal_rate = 'Y'

    debug('l_actual_ann_sal_rate ' ||to_char(l_actual_ann_sal_rate));

    l_actual_ann_sal_rate :=l_actual_ann_sal_rate + NVL(g_gtc_payments,0);

    g_other_allowance(p_assignment_id) := round(l_actual_other_allowance);
    l_actual_ann_sal_rate              := round(l_actual_ann_sal_rate);

    debug('g_other_allowance(p_assignment_id) ' ||to_char(g_other_allowance(p_assignment_id)),490);
    debug('l_actual_ann_sal_rate after adding GTC payments '||to_char(l_actual_ann_sal_rate));

    g_gtc_payments:=0;
    -- 4336613 : SAL_VALIDAT_3A : Check whether annual sal rate has exceeded the 5 digit limit
    -- If yes, raise warning.
    IF l_actual_ann_sal_rate > 999999 THEN

      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_93041_EXT_TP1_ANN_VAL_EXC'
                 ,p_error_number  => 93041
                 -- token introduced in error message
                 ,p_token1        => 'Annual Salary Rate ' || TO_CHAR(l_actual_ann_sal_rate) -- bug : 4336613
                 ,p_token2        => TO_CHAR(999999) -- bug : 4336613
                 );

      p_rate := 999999; -- 4336613 : SAL_VALIDAT_3A : set to 99999 if > 99999
    ELSE  -- end if of annual sal rate limit check ...
      debug('Actual Annual Salary Rate :'||to_char(l_actual_ann_sal_rate),510);
      p_rate := l_actual_ann_sal_rate;
    END IF ; -- end if of annual sal rate limit check ...

    debug('p_rate : '||to_char(p_rate),515);

    debug('l_warn_for_sal_rate: '||l_warn_for_sal_rate,520) ;
    -- Check for the Warning flag
    IF l_warn_for_sal_rate = 'Y' THEN
      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94044_ZERO_SAL_RATE'
                 ,p_error_number  => 94044
                 ,p_token1        => fnd_date.date_to_displaydate(p_effective_start_date)
                );
    END IF ;

    debug('l_warn_for_sal_paid: '||l_warn_for_sal_paid,530) ;
    -- Check for the Warning flag
    IF l_warn_for_sal_paid = 'Y' THEN
      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94045_ZERO_PT_SAL_PAID'
                 ,p_error_number  => 94045
                 ,p_token1        => fnd_date.date_to_displaydate(p_effective_start_date)
                );
    END IF ;


    debug_exit (l_proc_name);
    RETURN 0;

  ELSE -- else of return <> -1 on prim asg check...

    debug_exit (l_proc_name);
    p_rate      := 0;
    RETURN -1;

  END IF ; -- end if of return <> -1 on prim asg check...

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(' Others in '||l_proc_name);
       p_rate := l_rate_nc;
       raise;

END get_annual_sal_rate_date;


-- BUG 4135481
-- TERM_LSP: get_terminated_payments finds the
-- Final process date of employee if he/she
-- has been terminated with in the reporting period and
-- sums up salary paid upto Final close Date.
-- NB: If for a terminated employee there is no Final Close Date
-- then it picks up the Last Standard Process Date if it exists, else
-- (ie. LSP date is Null and Final Close Date is Null ) then it picks up the
-- actual Termination Date. Since no upper bound for payroll date
-- is found the payments are done till actual termination date
-- which is  calculated as per adjust_post_part_payments.
Function get_terminated_payments (p_assignment_id        IN     NUMBER
                                 ,p_effective_start_date IN     DATE
                                 ,p_effective_end_date   IN     DATE
                                 ,p_business_group_id    IN     NUMBER
                                 ,p_part_payment         OUT NOCOPY NUMBER
                                 ,p_balance_type_id      IN NUMBER -- 4336613 : OSLA_3A
                                 )
RETURN VARCHAR2 IS

l_proc_name               VARCHAR2(60) := g_proc_name || 'get_terminated_payments';
l_terminated              VARCHAR2(1);
l_term_proc_date          DATE ;
l_effective_date          DATE;
l_total_term_payment      NUMBER := 0;
l_count                   NUMBER := 0;
l_term_payment            NUMBER := 0;
l_effective_start_date    DATE;

l_get_term_details            csr_get_termination_details%ROWTYPE;

-- RETRO:BUG: 4135481
l_asg_act_dtl             csr_get_asg_act_id_retro%ROWTYPE;
l_supp_claim              NUMBER := 0;

BEGIN

  debug_enter(l_proc_name);
  debug('p_assignment_id :' ||to_char(p_assignment_id  ),10);
  debug('p_effective_start_date :' ||to_char(p_effective_start_date,'DD/MM/YYYY') );
  debug('p_effective_end_date :' ||to_char(p_effective_end_date,'DD/MM/YYYY'));

  -- get the final close date (if exists)
  OPEN csr_get_termination_details
           (p_assignment_id        => p_assignment_id
           ,p_effective_end_date   => p_effective_end_date
           ,p_business_group_id    => p_business_group_id
           );

  FETCH  csr_get_termination_details INTO l_get_term_details;


  IF csr_get_termination_details%FOUND THEN
     -- employee has been terminated with in the reporting period (line of service)
      debug('actual_termination_date: '||
                to_char(l_get_term_details.actual_termination_date,'DD-MM-YYYY'),20);

      l_term_proc_date := NVL(l_get_term_details.final_process_date ,
                                  NVL(l_get_term_details.last_standard_process_date,
                                      l_get_term_details.actual_termination_date));

      IF l_term_proc_date <> l_get_term_details.actual_termination_date THEN
        l_terminated := 'Y'; -- flag to check employee being terminated.

      ELSE
      --actual_termination_date = either of Last Std Process date or Final Close date
      --i.e. actual_termination_date  is on last day of the Pay period
        debug('actual_termination_date  is on last day of the Pay period',23);
        l_terminated := 'N';
        --person's payments included in regular payroll
      END IF;


      debug('termination payment date: '||
                  to_char( l_term_proc_date,'DD-MM-YYYY'),25);



  ELSE  --csr_get_lsp_date%FOUND THEN
    debug('No Termination Date found ', 30);
    l_terminated := 'N';

  END IF;
  CLOSE csr_get_termination_details;


  IF l_terminated ='Y' THEN

    -- If there is a case where person is terminated and
    -- there is no pay period after that current month then
    -- p_effective start_date is NULL after pre_payment is done.
    -- In that case if any days exist between terminated day and
    -- Last Standard process date then we want to calculate
    -- the terminated payment as well by setting the effective start date
    -- to p_effective_end_date.

--    IF p_effective_start_date is NULL THEN
--      l_effective_start_date := p_effective_end_date;
--    ELSE
      l_effective_start_date := p_effective_start_date;
--    END IF;

    debug('l_effective_start_date :'||to_char(l_effective_start_date, 'DD/MM/YYYY'),40) ;

    -- RETRO:BUG: 4135481/4273915
    -- Check if the RETRO flag g_calc_sal_new is set to 'Y'

    debug('g_calc_sal_new: ' ||g_calc_sal_new, 50);


    IF ( g_calc_sal_new = 'Y' ) THEN

      debug('g_def_bal_id(p_balance_type_id): '||to_char(g_def_bal_id(p_balance_type_id)),60);
      -- get the assignment_action_id and
      -- use the new seeded route to fetch the payments including the
      -- retro payments.

      l_count := 1;
      OPEN csr_get_asg_act_id_retro
                 (p_assignment_id        => p_assignment_id
                 ,p_effective_start_date => l_effective_start_date
                 ,p_effective_end_date   =>  l_term_proc_date
                  );
      LOOP

        FETCH csr_get_asg_act_id_retro INTO l_asg_act_dtl;
        EXIT WHEN csr_get_asg_act_id_retro%NOTFOUND;

        --
        debug('assignment_action_id: '||to_char(l_asg_act_dtl.assignment_action_id),70);
        debug('date_earned: '||to_char(l_asg_act_dtl.date_earned,'DD/MM/YYYY'));
        --
        l_term_payment := pay_balance_pkg.get_value
                              ( p_defined_balance_id   => g_def_bal_id(p_balance_type_id)
                               ,p_assignment_action_id => l_asg_act_dtl.assignment_action_id
                              ) ;

        debug('l_term_payment :'||to_char(l_term_payment), 80+l_count/10000) ;

        l_total_term_payment := l_total_term_payment + l_term_payment;

        debug('l_total_term_payment :'||to_char(l_total_term_payment),90+l_count/10000) ;

        l_count := l_count + 1 ;
      END LOOP;
      CLOSE csr_get_asg_act_id_retro;

      debug('l_total_term_payment :'||to_char(l_total_term_payment),110) ;
  /*
      IF g_date_work_mode = 'Y' AND g_supp_teacher = 'Y' THEN
        OPEN csr_get_supp_ded(p_balance_type_id,p_assignment_id,l_effective_start_date,l_term_proc_date);
        FETCH csr_get_supp_ded INTO l_supp_claim;
        CLOSE csr_get_supp_ded;
        debug('l_supp_claim :'||to_char(l_supp_claim),208);
        l_total_term_payment := l_total_term_payment - l_supp_claim;
        debug('l_total_term_payment after supply claims deduction:'||to_char(l_total_term_payment),209) ;
      END IF;
   */
      debug('....retro payments calc over....') ;

    ELSE  -- ( g_calc_sal_new = 'N' ) THEN

      -- get the payments using the usual balance route.

      OPEN csr_get_end_date (c_assignment_id        => p_assignment_id
                            ,c_effective_start_date => l_effective_start_date
                            ,c_effective_end_date   =>  l_term_proc_date
                          );
      LOOP

        FETCH csr_get_end_date INTO l_effective_date;
        EXIT when csr_get_end_date%notfound;

        debug('l_effective_date :'||to_char(l_effective_date, 'DD/MM/YYYY'),120) ;

        l_term_payment := hr_gbbal.calc_asg_proc_ptd_date
                           (p_assignment_id   => p_assignment_id
                           ,p_balance_type_id => p_balance_type_id
                           ,p_effective_date  => l_effective_date
                           );


        debug('l_term_payment :'||to_char(l_term_payment), 130+l_count/10000) ;

        l_total_term_payment := l_total_term_payment + l_term_payment;

        debug('l_total_term_payment :'||to_char(l_total_term_payment),140+l_count/10000) ;

        l_count := l_count + 1 ;
      END LOOP;
      debug('l_total_term_payment :'||to_char(l_total_term_payment),150) ;
      CLOSE csr_get_end_date;
   /*
      IF g_date_work_mode = 'Y' AND g_supp_teacher = 'Y' THEN
        OPEN csr_get_supp_ded(p_balance_type_id,p_assignment_id,l_effective_start_date,l_term_proc_date);
        FETCH csr_get_supp_ded INTO l_supp_claim;
        CLOSE csr_get_supp_ded;
        debug('l_supp_claim :'||to_char(l_supp_claim),208);
        l_total_term_payment := l_total_term_payment - l_supp_claim;
        debug('l_total_term_payment after supply claims deduction:'||to_char(l_total_term_payment),209) ;

      END IF;
   */
    END IF;  --( g_calc_sal_new = 'N' ) THEN


  END IF; --l_terminated ='Y' THEN

  debug('l_total_term_payment :'||to_char(l_total_term_payment),160) ;

  IF l_total_term_payment IS NULL THEN
    p_part_payment := 0;
  ELSE
    p_part_payment := l_total_term_payment;
  END IF;

  debug('p_part_payment: '|| to_char(p_part_payment), 170);
  debug_exit(l_proc_name);

  RETURN l_terminated;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    p_part_payment := NULL;
    RAISE;

END get_terminated_payments;


-- PTS: BUG 4135481
-- This is a utility function that calculates the
-- number of overlapping days in the two sets of dates.
-- set1 (p_start_date1, p_end_date1)
-- set2 (p_start_date2,p_end_date2)
-- RETURNS 0 if no overlap period is found.
FUNCTION get_overlap_days
          (p_start_date1 DATE
          ,p_end_date1   DATE
          ,p_start_date2 DATE
          ,p_end_date2   DATE
          ) RETURN NUMBER

 IS

 l_overlap_days NUMBER :=0 ;
 l_proc_name   VARCHAR2(60) := 'get_overlap_days' ;

BEGIN

  debug_enter(l_proc_name) ;

  debug('p_start_date1: '||to_char(p_start_date1,'DD/MM/YYYY')) ;
  debug('p_end_date1: '||to_char(p_end_date1,'DD/MM/YYYY')) ;
  debug('p_start_date2: '||to_char(p_start_date2,'DD/MM/YYYY')) ;
  debug('p_end_date2: '||to_char(p_end_date2,'DD/MM/YYYY')) ;

  IF ( (p_end_date1 < p_start_date2) OR (p_end_date2 < p_start_date1) ) THEN
    debug(l_proc_name, 10);
    l_overlap_days := 0;
  ELSIF ( (p_end_date1 = p_start_date2) OR (p_end_date2 = p_start_date1) ) THEN
    debug(l_proc_name, 20);
    l_overlap_days := 1 ;
  ELSIF ( (p_start_date1 <= p_start_date2) AND (p_end_date2 <= p_end_date1) ) THEN
    debug(l_proc_name, 30);
    l_overlap_days := p_end_date2 - p_start_date2 + 1 ;
  ELSIF ( (p_start_date2 <= p_start_date1) AND (p_end_date1 <= p_end_date2) ) THEN
    debug(l_proc_name, 40);
    l_overlap_days := p_end_date1 - p_start_date1 + 1;
  ELSIF ( (p_start_date2 <= p_start_date1) AND (p_end_date2 <= p_end_date1) ) THEN
    debug(l_proc_name, 50);
    l_overlap_days := p_end_date2 - p_start_date1 + 1;
  ELSE
    debug(l_proc_name, 60);
    l_overlap_days := p_end_date1 - p_start_date2 + 1;
  END IF;

  debug('l_overlap_days: '|| l_overlap_days, 70);
  debug_exit(l_proc_name);

  RETURN abs(l_overlap_days);

END get_overlap_days;


-- PTS: BUG 4135481:
------<calc_payment_by_run_rslt>--------------
-- function gets the sum of run result values for
-- the assignment for the period
-- p_start_date to p_end_date
-- for the payments earned on p_date_earned (payroll run date)
-- p_val returns the value of payments.
-- Returns -1 in case of error
FUNCTION calc_payment_by_run_rslt
                         ( p_assignment_id     IN NUMBER
                          ,p_start_date        IN DATE
                          ,p_end_date          IN DATE
                          ,p_pay_period_start  IN DATE
                          ,p_date_earned       IN DATE
                          ,p_balance_type_id   IN NUMBER
                          ,p_val               OUT NOCOPY NUMBER
                          ,p_tab_bal_ele_ids   IN t_ele_ids_from_bal -- 4336613 : OSLA_3A
                          ) RETURN NUMBER
IS

l_proc_name         VARCHAR2(60) := g_proc_name || 'calc_payment_by_run_rslt';

l_element_type_id   NUMBER;
l_input_val_id      NUMBER;
l_total_val         NUMBER:= 0;

l_asg_act_id        NUMBER;
l_count             NUMBER; -- Loop counter

l_overlap_days      NUMBER      := 0;
l_avg_payment       NUMBER      := 0;
l_proration         VARCHAR2(1) :='N' ;
l_balance_val       NUMBER      := 0;
l_balance_type_id   NUMBER;

--l_rr                csr_get_run_result_value%ROWTYPE;
l_rr1               csr_get_run_results%ROWTYPE;             -- 5403512
l_element_info      csr_get_eet_info%ROWTYPE;
i                     NUMBER :=0;
l_qualify           VARCHAR2(1) := 'Y';
--
BEGIN

  debug_enter(l_proc_name);

  debug('p_start_date :' ||to_char(p_start_date, 'DD/MM/YYYY'),10) ;
  debug('p_end_date :' ||to_char(p_end_date, 'DD/MM/YYYY')) ;
  debug('p_pay_period_start :' ||to_char(p_pay_period_start, 'DD/MM/YYYY')) ;
  debug('p_date_earned :' ||to_char(p_date_earned, 'DD/MM/YYYY')) ;
  debug('p_assignment_id :' ||to_char(p_assignment_id)) ;
  debug('p_balance_type_id :' ||to_char(p_balance_type_id)) ;
  debug('p_tab_bal_ele_ids.COUNT :' ||to_char(p_tab_bal_ele_ids.COUNT)) ;

  -- get the assignment_action_id

  OPEN csr_get_asg_act_id
           ( p_assignment_id   => p_assignment_id
            ,p_date_earned     => p_date_earned
           );
  FETCH csr_get_asg_act_id INTO l_asg_act_id;

  IF csr_get_asg_act_id%NOTFOUND THEN
    CLOSE csr_get_asg_act_id;
    debug('Assignment action id not found....',30);
    l_total_val := 0 ;

  ELSE -- csr_get_asg_act_id%NOTFOUND THEN
    CLOSE csr_get_asg_act_id;

    -- Run Results exist so get the element Ids
    debug('l_asg_act_id: '||to_char(l_asg_act_id),40 );

    -- get_elements from element entries
    -- for the assignment
    l_count := 1 ; -- Loop counter

/*    OPEN csr_get_eet_info                               -- 5403512
        ( c_assignment_id         => p_assignment_id
         ,c_effective_start_date  => p_start_date
         ,c_effective_end_date    => p_end_date
         ) ;      */
 --   LOOP
--      FETCH csr_get_eet_info INTO l_element_info;
--      EXIT WHEN csr_get_eet_info%NOTFOUND;

       -- check if the element is feeding the
       -- 'Teachers Supperannuable Salary' Balance'

--      l_element_type_id := l_element_info.element_type_id;


      debug('element_type_id :' ||to_char(l_element_type_id),50+l_count/10000) ;

      -- 4336613 : OSLA_3A : check for payment type (OSLA/NULL)
      -- IF OSLA, then use g_tab_osla_ele_ids, else use g_tab_sal_ele_ids

/*        IF p_tab_bal_ele_ids.EXISTS(l_element_type_id) THEN

          debug('input_value_id :' ||
                     to_char(p_tab_bal_ele_ids(l_element_type_id).input_value_id),60+l_count/10000) ;   */   -- 5403512

          l_balance_type_id := p_balance_type_id;
          -- Get the run_results
          -- for this element type id
 /*         FOR l_rr IN csr_get_run_result_value        -- 5403512
                         (  p_start_date      => p_pay_period_start --p_start_date
                           ,p_end_date        => p_date_earned --p_end_date
                           ,p_element_type_id => l_element_type_id
                           ,p_input_value_id  => p_tab_bal_ele_ids(l_element_type_id).input_value_id
                           ,p_asg_act_id      => l_asg_act_id
                          )   */
          FOR l_rr1 IN csr_get_run_results              -- 5403512
	                 (  p_start_date      => p_pay_period_start --p_start_date
                           ,p_end_date        => p_date_earned --p_end_date
			   ,p_asg_act_id      => l_asg_act_id
			   ,p_balance_type_id => l_balance_type_id
			 )
          LOOP
            debug('l_total_val       :' ||to_char(l_total_val), 70+l_count/10000) ;
            debug('l_rr.start_date   :'||to_char(l_rr1.start_date,'DD/MM/YYYY'));
            debug('l_rr.end_date     :'||to_char(l_rr1.end_date,'DD/MM/YYYY'));
            debug('l_rr.result_value :'||to_char(l_rr1.result));
            debug('l_rr.run_result_id       :' ||to_char(l_rr1.run_result_id));

            l_proration := 'Y' ;
            l_qualify   := 'Y' ;

            IF g_date_work_mode = 'Y' AND g_supp_teacher = 'Y' THEN
              OPEN csr_is_supp_claim(l_rr1.run_result_id,p_start_date,p_end_date);
              FETCH csr_is_supp_claim INTO l_qualify;
              CLOSE csr_is_supp_claim;
              debug('l_qualify       :' ||l_qualify, 79) ;
            END IF;
              debug('l_qualify       :' ||l_qualify, 80) ;
            IF l_qualify = 'Y' THEN
            debug(l_proc_name, 80);

            IF (l_rr1.start_date >= p_start_date
               AND
               l_rr1.end_date <= p_end_date)  THEN

               debug(l_proc_name, 90) ;
               l_total_val := l_total_val + l_rr1.result * l_rr1.scale;   -- 5403512

            -- CALC_PT_SAL_OPTIONS: BUG : 4135481
            -- perform average calculations if specified
            ELSIF g_calendar_avg = 'Y' THEN --(l_rr.start_date >= p_start_date

               debug(l_proc_name, 110) ;
               -- need average calculation
               -- get the number of days in the period that overlap with the payroll period
               l_overlap_days := get_overlap_days
                                      (p_start_date1 => p_start_date
                                      ,p_end_date1   => p_end_date
                                      ,p_start_date2 => l_rr1.start_date
                                      ,p_end_date2   => l_rr1.end_date
                                      );

               debug('l_overlap_days: '||to_char(l_overlap_days), 120);

               IF l_overlap_days <> 0 THEN
                 l_avg_payment := (l_rr1.result*l_overlap_days)/(l_rr1.end_date - l_rr1.start_date + 1 );
                 debug('l_avg_payment: '||to_char(l_avg_payment), 130);
                 l_total_val   := l_total_val + l_avg_payment * l_rr1.scale;
                 debug('l_total_val: '||to_char(l_total_val), 140);
               END IF ;

            ELSIF (l_rr1.end_date BETWEEN p_start_date
                                     AND p_end_date
                   ) THEN -- g_calendar_avg = 'N', direct addition, no average calculation
              debug(l_proc_name, 150) ;
              l_total_val   := l_total_val + l_rr1.result * l_rr1.scale;
            END IF; --(l_rr.start_date >= p_start_date
           END IF;
            debug('l_total_val :' ||to_char(l_total_val),160) ;
          END LOOP;

          debug('l_proration: '||l_proration, 170);
          -- There is no proration on this asignment, need to get the
          -- payroll balance and average calculation is required.
          IF l_proration = 'N' THEN
            debug(l_proc_name, 180);

            l_proration := 'Y'; -- 4336613 : ensuring that we pick the balance only once

            --get the balance value as of date earned
            -- and get the average value for the number of days in the period.

            l_balance_val := hr_gbbal.calc_asg_proc_ptd_date
                            (p_assignment_id   => p_assignment_id
                            ,p_balance_type_id => p_balance_type_id
                            ,p_effective_date  => p_date_earned
                            );

            debug('l_balance_val: '||to_char(l_balance_val), 190);
            -- get the number of days in the period that overlap with the payroll period
            IF l_balance_val > 0 THEN

              debug(l_proc_name, 210);
              l_overlap_days := get_overlap_days
                                   (p_start_date1 => p_start_date
                                   ,p_end_date1   => p_end_date
                                   ,p_start_date2 => p_pay_period_start
                                   ,p_end_date2   => p_date_earned
                                    );
              debug('l_overlap_days: '||to_char(l_overlap_days), 220);
              l_avg_payment := (l_balance_val*l_overlap_days)/(p_date_earned - p_pay_period_start + 1 );

            END IF; --l_balance_val > 0 THEN

            debug('l_avg_payment: '||to_char(l_avg_payment), 230);
            l_total_val   := l_total_val + l_avg_payment;

          END IF;  --l_proration = 'N'
          debug('l_total_val :' ||to_char(l_total_val), 240+l_count/10000) ;

 --       END IF; --p_tab_bal_ele_ids.EXISTS(l_element_type_id) THEN -- 5403512

        debug(l_proc_name, 250);

--    END LOOP;
--    CLOSE csr_get_eet_info;     -- 5403512

    debug('l_total_val :' ||to_char(l_total_val), 260) ;
  END IF; -- csr_get_asg_act_id%NOTFOUND THEN


  IF l_total_val IS NULL THEN
    l_total_val := 0;
  END IF;

  p_val := l_total_val ;

  debug_exit(l_proc_name);
  RETURN 0 ;

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(' Others in '||l_proc_name);
       p_val := NULL;
       raise;

END calc_payment_by_run_rslt ;


--
--
-- PTS: BUG 4135481:
-----adjust_pre_part_payments------
--
-- The following function is used to get the prorated payments for the
-- period at the begining of the Line of Service
-- IN PARAMS:
-- p_balance_type_id: Balance ID for the balance 'Teachers Supperannuable Salary'
-- OUT PARAMS:
-- p_effective_start_date : Start date for the non prorated payments
-- p_effective_end_date : END date for the non prorated payments
-- p_part_payment : Prorated payment for the period.

FUNCTION adjust_pre_part_payments(p_assignment_id        IN NUMBER -- in
                                 ,p_balance_type_id      IN NUMBER
                                 ,p_effective_start_date IN OUT NOCOPY DATE
                                 ,p_effective_end_date   IN OUT NOCOPY DATE
                                 ,p_part_payment         OUT NOCOPY NUMBER
                                 ,p_tab_bal_ele_ids      IN t_ele_ids_from_bal
                                 ) RETURN NUMBER
IS

--
  l_proc_name           varchar2(60) := g_proc_name || 'adjust_pre_part_payments';

  -- Required for nocopy
  l_nc_effective_start_date DATE ;
  l_nc_effective_end_date   DATE ;

  l_return_start_date       DATE;
  l_return_end_date         DATE;
  l_effective_start_date    DATE;
  l_effective_end_date      DATE;
  l_temp_end_date           DATE;
  l_pre_payroll_date        DATE;
  l_pre_part_payment        NUMBER := 0 ;
  l_pre_payment_exist       VARCHAR2(1) := NULL ;
  l_return                  NUMBER := 0;
  l_date_earned             DATE;

  -- RETRO:BUG: 4135481
  l_retro_entry             VARCHAR2(1):= 'N' ;
  l_count                   NUMBER := 0;
  l_retro_dtl               csr_get_date_earned_retro%ROWTYPE;


BEGIN
  --
  debug_enter(l_proc_name);

  debug('p_assignment_id :' ||to_char(p_assignment_id),10) ;
  debug('p_balance_type_id :' ||to_char(p_balance_type_id)) ;
  debug('p_effective_start_date :' ||to_char(p_effective_start_date, 'DD/MM/YYYY')) ;
  debug('p_effective_end_date :' ||to_char(p_effective_end_date, 'DD/MM/YYYY')) ;


  -- Nocopy changes
  l_nc_effective_start_date := p_effective_start_date;
  l_nc_effective_end_date   := p_effective_end_date;
  --

  -- initialize the two dates,
  -- we may return these dates back as it is ..
  l_return_start_date := p_effective_start_date;
  l_return_end_date   := p_effective_end_date;

  -- Get the recent payroll date
  -- and check if there are any prorated periods
  -- in the date range
  OPEN csr_get_previous_payroll_date
         ( p_assignment_id        => p_assignment_id
          ,p_effective_start_date => p_effective_start_date
         );
  FETCH csr_get_previous_payroll_date INTO l_pre_payroll_date;

  IF csr_get_previous_payroll_date%NOTFOUND THEN
    -- there is no payroll defined before this date so
    -- we can safely assume that this is the start of the period.

    l_pre_payment_exist := 'Y' ;

    l_effective_start_date := p_effective_start_date ;
    l_return_start_date    := NULL;  --p_effective_start_date ;

    debug('l_effective_start_date :' ||to_char(l_effective_start_date, 'DD/MM/YYYY'),20) ;

  ELSE  --csr_get_previous_payroll_date%NOTFOUND THEN
    debug('l_pre_payroll_date :' ||to_char(l_pre_payroll_date, 'DD/MM/YYYY'),30) ;

    -- if  p_effective_start_date is not start of some payroll period
    IF p_effective_start_date > l_pre_payroll_date + 1 THEN
       debug(l_proc_name,40) ;
       -- Calculate the part payment for start date
       l_pre_payment_exist := 'Y' ;
       l_effective_start_date := p_effective_start_date;
       l_return_start_date    := NULL ; -- nedd to set it later...

       debug('l_effective_start_date :' ||to_char(l_effective_start_date, 'DD/MM/YYYY'),50) ;
    ELSE  --p_effective_start_date > l_pre_payroll_date + 1 THEN
       debug(l_proc_name, 60);
       -- there are no pre_part_payments ..
       -- Period start date is the payroll period start date, so we will calculate by
       -- using the default logic to get the balance values.
       l_pre_payment_exist    := 'N' ;
       l_return_start_date    := p_effective_start_date ;
       l_return_end_date      := p_effective_end_date ;
    END IF  ; -- p_effective_start_date > l_pre_payroll_date + 1 THEN

  END IF;  --sr_get_previous_payroll_date%NOTFOUND THEN

  CLOSE csr_get_previous_payroll_date;

  debug('l_pre_payment_exist :' ||l_pre_payment_exist, 70) ;
  debug('l_effective_start_date :' ||to_char(l_effective_start_date, 'DD/MM/YYYY')) ;
  debug('l_return_start_date :' ||to_char(l_return_start_date, 'DD/MM/YYYY')) ;

  -- Calculate prorated Period End Date
  IF l_pre_payment_exist = 'Y' THEN

    debug(l_proc_name, 80);
    -- get the end date of the prorateed period....
    OPEN csr_get_pre_end_date (c_assignment_id        => p_assignment_id
                              ,c_effective_start_date => l_effective_start_date
                              ,c_effective_end_date   => p_effective_end_date
                              );
    FETCH csr_get_pre_end_date INTO l_temp_end_date;

    IF csr_get_pre_end_date%NOTFOUND THEN
      -- the period is less than one payroll period defined.
      -- hence no Pyroll defined in that period.

      debug(l_proc_name, 90);
      CLOSE csr_get_pre_end_date;

      l_effective_end_date := p_effective_end_date ;
      -- theer are no more payroll periods to get the values from.
      l_return_end_date := p_effective_end_date;
      l_return_start_date := l_effective_start_date;

      debug('l_effective_end_date :' ||to_char(l_effective_end_date, 'DD/MM/YYYY'),110) ;

    ELSE --csr_get_pre_end_date%NOT FOUND THE


      debug(l_proc_name, 120);
      CLOSE csr_get_pre_end_date;

      debug('l_temp_end_date :' ||to_char(l_temp_end_date, 'DD/MM/YYYY'),130) ;

      IF l_temp_end_date = p_effective_end_date THEN
        debug(l_proc_name, 135);
        -- There are some prorated payments
        l_effective_end_date := p_effective_end_date ;
        debug('l_effective_end_date :' ||to_char(l_effective_end_date, 'DD/MM/YYYY'),140) ;

        -- No more payments left....
        l_return_end_date := NULL;

      ELSIF l_temp_end_date < p_effective_end_date THEN
        -- There are some prorated payments  and
        -- there are more payments also
        debug(l_proc_name, 150);
        l_effective_end_date := l_temp_end_date ;
        debug('l_effective_end_date :' ||to_char(l_effective_end_date, 'DD/MM/YYYY'),160) ;

        -- More payments left....
        -- could be full apyment period or part post payments ...
        l_return_start_date := l_effective_end_date + 1;
        l_return_end_date   := p_effective_end_date ;

      END IF;

      debug('l_effective_end_date :' ||to_char(l_effective_end_date, 'DD/MM/YYYY'),170) ;

    END IF; -- --csr_get_pre_end_date%NOT FOUND THEN

    debug('l_effective_start_date :' ||to_char(l_effective_start_date, 'DD/MM/YYYY'),180) ;
    debug('l_effective_end_date   :' ||to_char(l_effective_end_date, 'DD/MM/YYYY')) ;
    debug('l_return_start_date    :' ||to_char(l_return_start_date, 'DD/MM/YYYY')) ;
    debug('l_return_end_date      :' ||to_char(l_return_end_date, 'DD/MM/YYYY')) ;

    OPEN csr_get_next_payroll_date
           ( p_assignment_id        => p_assignment_id
            ,p_effective_start_date => p_effective_start_date
            ) ;
    FETCH csr_get_next_payroll_date INTO l_date_earned;

    IF csr_get_next_payroll_date%FOUND THEN

      CLOSE csr_get_next_payroll_date;

      debug('l_date_earned :' ||to_char(l_date_earned,'DD/MM/YYYY'),190) ;

      l_return := calc_payment_by_run_rslt
                       ( p_assignment_id    => p_assignment_id
                        ,p_start_date       => l_effective_start_date --in
                        ,p_end_date         => l_effective_end_date --in
                        ,p_pay_period_start => l_pre_payroll_date + 1
                        ,p_date_earned      => l_date_earned
                        ,p_balance_type_id  => p_balance_type_id
                        ,p_val              => l_pre_part_payment --out
                        ,p_tab_bal_ele_ids  => p_tab_bal_ele_ids -- in -- 4336613 : OSLA_3A
                        ) ;
      debug('l_return :' ||to_char(l_return),210) ;
      debug('l_pre_part_payment :' ||to_char(l_pre_part_payment)) ;

    ELSE
      CLOSE csr_get_next_payroll_date;
      debug(l_proc_name, 220);
    END IF;


    p_part_payment         := l_pre_part_payment;
    p_effective_start_date := l_return_start_date ;
    p_effective_end_date   := l_return_end_date ;

    -- RETRO:BUG: 4135481
    -- check if there are any retro earnings existing
    -- for the period.
    -- If there are any raise a warning.
    -- Still exploring the possibility to fix this.
    -- so that we can show the actual payments made in the period

    l_count := 1 ;
    FOR l_retro_dtl IN csr_get_date_earned_retro
                           (p_assignment_id => p_assignment_id
                           ,p_start_date    => l_pre_payroll_date + 1
                           ,p_end_date      => l_date_earned
                           )
    LOOP
      l_retro_entry := 'Y';
      debug('|-----------------------------------------------|', 230+l_count/10000);
      debug('element_entry_id    : '||to_char(l_retro_dtl.element_entry_id));
      debug('element_type_id     : '||to_char(l_retro_dtl.element_type_id));
      debug('creator_type        : '||l_retro_dtl.creator_type);
      debug('effective_start_date: '||to_char(l_retro_dtl.effective_start_date,'DD/MM/YYYY'));
      debug('effective_end_date  : '||to_char(l_retro_dtl.effective_end_date,'DD/MM/YYYY'));
      debug('source_start_date   : '||to_char(l_retro_dtl.source_start_date,'DD/MM/YYYY'));
      debug('source_end_date     : '||to_char(l_retro_dtl.source_end_date,'DD/MM/YYYY'));
      debug('date_earned         : '||to_char(l_retro_dtl.date_earned,'DD/MM/YYYY'));
      debug('|-----------------------------------------------|', 240+l_count/10000);
      l_count := l_count + 1 ;
    END LOOP;

    /*    IF (l_retro_entry = 'Y') THEN                        -- changed to remove the warning.
      debug('RAISE A WARNING FOR RETRO ENTRIES.......', 250);
      -- Find the retro payments here and show them along
      -- with the warning message
      -- Still investigating the possibility to show the
      -- correct payments if both Proration and Retro are
      -- enabled and applied on the period.


      -- Set the global here to raise a warning from recalc_data_element
      -- can not raise a warning from this place,
      -- as we don't have the primary assignment id
      -- and this function can be called multiple times
      -- from Salary Rate/Days Excluded/parttime sal paid functions.

      g_raise_retro_warning := 'Y' ;
    END IF;     */


  ELSE --l_pre_payment_exist = 'Y' THEN
    debug(l_proc_name, 260);

    p_effective_start_date := l_return_start_date ;
    p_effective_end_date   := l_return_end_date ;
    p_part_payment         := 0;

  END IF ; --l_pre_payment_exist = 'Y' THEN

  debug_exit(l_proc_name);

  RETURN l_return ;

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(' Others in '||l_proc_name);
       p_effective_start_date := l_nc_effective_start_date  ;
       p_effective_end_date   := l_nc_effective_end_date ;
       p_part_payment         := 0;
       raise;

END adjust_pre_part_payments;


-- PTS: BUG 4135481:
-----adjust_post_part_payments------
--
-- The following function is used to get
-- the prorated payments for the period at
-- the end of the Line of Service . The function
-- checks first if the assigment is terminated.If
-- it is then it fetches the terminated pay amount
-- else it goes and calculates prorated payments
-- at the end of Lines of service.

FUNCTION adjust_post_part_payments(p_assignment_id        IN NUMBER
                                  ,p_balance_type_id      IN NUMBER
                                  ,p_effective_start_date IN DATE
                                  ,p_effective_end_date   IN DATE
                                  ,p_part_payment         OUT NOCOPY NUMBER
                                  ,p_tab_bal_ele_ids      IN t_ele_ids_from_bal
                                 ) RETURN NUMBER
IS

--
  l_proc_name             VARCHAR2(60) := g_proc_name || 'adjust_post_part_payments';
  l_post_part_payment     NUMBER := 0;
  l_return                NUMBER := 0;
  l_date_earned           DATE;
  --TERM_LSP:BUG :4135481 Check for terminated employees
  l_is_terminated         VARCHAR2(1) := 'N';

  -- RETRO:BUG: 4135481
  l_retro_entry           VARCHAR2(1):= 'N' ;
  l_count                 NUMBER := 0;
  l_retro_dtl             csr_get_date_earned_retro%ROWTYPE;
--
BEGIN
  --
  debug_enter(l_proc_name);

  debug('p_assignment_id       :' ||to_char(p_assignment_id),10) ;
  debug('p_balance_type_id     :' ||to_char(p_balance_type_id)) ;
  debug('p_effective_start_date:' ||to_char(p_effective_start_date, 'DD/MM/YYYY')) ;
  debug('p_effective_end_date  :' ||to_char(p_effective_end_date, 'DD/MM/YYYY')) ;
  debug('g_terminated_person   :' || g_terminated_person) ;


   -- check if period length is not ZERO days.
   IF( (p_effective_start_date IS NULL) -- no period exists
        OR ( (p_effective_start_date IS NOT NULL)
             AND (p_effective_start_date > p_effective_end_date)
           )
     )THEN
     debug(l_proc_name,30) ;
     -- there are no post_part_payments
     -- so return 0
     l_post_part_payment := 0 ;

   ELSE
     -- get the part_payments from run_results
     debug(l_proc_name,40) ;

     OPEN csr_get_next_payroll_date
          ( p_assignment_id        => p_assignment_id
           ,p_effective_start_date => p_effective_start_date
           ) ;
     FETCH csr_get_next_payroll_date INTO l_date_earned;

     IF csr_get_next_payroll_date%FOUND THEN

       CLOSE csr_get_next_payroll_date;

       debug('l_date_earned :' ||to_char(l_date_earned,'DD/MM/YYYY'),50) ;

       l_return := calc_payment_by_run_rslt
                        ( p_assignment_id    => p_assignment_id
                         ,p_start_date       => p_effective_start_date -- in
                         ,p_end_date         => p_effective_end_date   -- in
                         ,p_pay_period_start => p_effective_start_date -- for Avg calc ...
                         ,p_date_earned      => l_date_earned
                         ,p_balance_type_id  => p_balance_type_id
                         ,p_val              => l_post_part_payment --out
                         ,p_tab_bal_ele_ids  => p_tab_bal_ele_ids -- in -- 4336613 : OSLA_3A
                         ) ;
       debug('l_return :' ||to_char(l_return),60) ;
       debug('l_post_part_payment :' ||to_char(l_post_part_payment)) ;


       -- RETRO:BUG: 4135481
       -- check if there are any retro earnings existing
       -- for the period
       -- If there are any raise a warning.
       -- exploring the possibility to fix this.
       -- so that we can show the actual payments made in the period
       --
       l_count := 1 ;
       FOR l_retro_dtl IN csr_get_date_earned_retro
                           (p_assignment_id => p_assignment_id
                           ,p_start_date    => p_effective_start_date
                           ,p_end_date      => l_date_earned
                           )
       LOOP
         l_retro_entry := 'Y';
         debug('|-----------------------------------------------|', 70+l_count/10000);
         debug('element_entry_id    : '||to_char(l_retro_dtl.element_entry_id));
         debug('element_type_id     : '||to_char(l_retro_dtl.element_type_id));
         debug('creator_type        : '||l_retro_dtl.creator_type);
         debug('effective_start_date: '||to_char(l_retro_dtl.effective_start_date,'DD/MM/YYYY'));
         debug('effective_end_date  : '||to_char(l_retro_dtl.effective_end_date,'DD/MM/YYYY'));
         debug('source_start_date   : '||to_char(l_retro_dtl.source_start_date,'DD/MM/YYYY'));
         debug('source_end_date     : '||to_char(l_retro_dtl.source_end_date,'DD/MM/YYYY'));
         debug('date_earned         : '||to_char(l_retro_dtl.date_earned,'DD/MM/YYYY'));
         debug('|-----------------------------------------------|', 210+l_count/10000);
         l_count := l_count + 1 ;
       END LOOP;

       /*     IF (l_retro_entry = 'Y') THEN                         -- Changed to remove the warning.
         debug('......raise a warning for retro entries.......',80);
         -- Find the retro payments here and show them along
         -- with the warning message
         -- Still investigating the possibility to show the
         -- correct payments if both Proration and Retro are
         -- enabled and applied on the period.

         -- Set the global here to raise a warning from recalc_data_element.
         -- Can not raise a warning from this place,
         -- as we don't have the primary assignment id
         -- and this function can be called multiple times
         -- from Salary Rate/Days Excluded/parttime sal paid functions.

         g_raise_retro_warning := 'Y' ;

       END IF;    */


     ELSE
       CLOSE csr_get_next_payroll_date;
       debug(l_proc_name, 90);
     END IF;


   END IF ; --p_effective_start_date > p_effective_end_date THEN


  debug(l_proc_name,110) ;

  p_part_payment   := l_post_part_payment;

  debug_exit(l_proc_name);

  RETURN l_return ;

END adjust_post_part_payments;






-- CALC_PT_SAL_OPTIONS: BUG : 4135481
-- this function is the older implementation of calc_part_time_sal
-- this is used when g_calc_sal_new is 'N'
-- ----------------------------------------------------------------------------
-- |------------------------< calc_part_time_sal_old >----------------------------|
-- ----------------------------------------------------------------------------
function calc_part_time_sal_old (p_assignment_id           in     number
                                ,p_effective_start_date    in     date
                                ,p_effective_end_date      in     date
                                ,p_business_group_id       in     number
                                ,p_next_payroll_start_date out    nocopy date -- new parameter to track
                                                                --last complete payroll run date
                                ,p_sal_bal_type_id         in     number -- 4336613 : OSLA_3A
                                )
  return number is
--
  l_proc_name           varchar2(60) := g_proc_name || 'calc_part_time_sal_old';
  l_effective_date      date;
  l_total_part_time_sal number := 0;
  l_part_time_sal       number := 0;
  l_supp_claim          number := 0;
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  debug('p_assignment_id :' ||to_char(p_assignment_id),10) ;
  debug('p_effective_start_date :' ||to_char(p_effective_start_date, 'DD/MM/YYYY'),20) ;
  debug('p_effective_end_date :' ||to_char(p_effective_end_date, 'DD/MM/YYYY'),30) ;
  debug('p_sal_bal_type_id :' ||to_char(p_sal_bal_type_id),35) ;

  open csr_get_end_date (c_assignment_id        => p_assignment_id
                        ,c_effective_start_date => p_effective_start_date
                        ,c_effective_end_date   => p_effective_end_date
                        );
  loop

    fetch csr_get_end_date into l_effective_date;
    exit when csr_get_end_date%notfound;

      --
      debug(l_proc_name, 40);
      --
      debug('l_effective_date :'||to_char(l_effective_date, 'DD/MM/YYYY'),50) ;

      l_part_time_sal := hr_gbbal.calc_asg_proc_ptd_date
                          (p_assignment_id   => p_assignment_id
                          -- 4336613 : OSLA_3A : changed from g_sal_bal_type_id
                          ,p_balance_type_id => p_sal_bal_type_id
                          ,p_effective_date  => l_effective_date
                          );
      debug('l_part_time_sal :'||to_char(l_part_time_sal),60) ;
      l_total_part_time_sal := l_total_part_time_sal + l_part_time_sal;

  end loop;

  close csr_get_end_date;

/*
      IF g_date_work_mode = 'Y' AND g_supp_teacher = 'Y' THEN
        OPEN csr_get_supp_ded(p_sal_bal_type_id,p_assignment_id,p_effective_start_date,l_effective_date);
        FETCH csr_get_supp_ded INTO l_supp_claim;
        CLOSE csr_get_supp_ded;
        debug('l_supp_claim :'||to_char(l_supp_claim),51);
        l_total_part_time_sal := l_total_part_time_sal - l_supp_claim;
        debug('l_total_part_time_sal after supply claims deduction:'||to_char(l_total_part_time_sal),52) ;
      END IF;
*/
  --We now need to set date for terminated payments
  --If no complete payroll exist for that person
  -- eg person assignment starts on 1-apr-2000 and terminates b4 30-apr-2000
  -- in such a case, we set the last_payroll_date = effective_start_date of assignment

  -- else we set the last_payroll_date = the next day of the last complete payroll end date
  -- eg person starts 01-apr2000 and terminates on say 15-jun-2000.
  -- Then we set last_payroll_date = 31-may-2000(last complete payrol run date) + 1 = 01-jun-2000

  -- BUG : 4273915
  IF l_effective_date IS NOT NULL THEN
    debug(l_proc_name, 70);
    p_next_payroll_start_date := l_effective_date + 1;
  ELSE
    -- no complete payroll periods
    debug(l_proc_name, 80);
    p_next_payroll_start_date := p_effective_start_date;
  END IF;

  debug('l_total_part_time_sal :'||to_char(l_total_part_time_sal),90);
  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 30);
  --
  debug_exit(l_proc_name);

  return l_total_part_time_sal;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END calc_part_time_sal_old;



-- ----------------------------------------------------------------------------
-- |------------------------< calc_part_time_sal >----------------------------|
-- ----------------------------------------------------------------------------
function calc_part_time_sal (p_assignment_id        in     number
                            ,p_effective_start_date in     date
                            ,p_effective_end_date   in     date
                            ,p_business_group_id    in     number
                            ,p_sal_bal_type_id      IN     NUMBER DEFAULT NULL --4336613 : OSLA_3A
                            ,p_cl_bal_type_id       IN     NUMBER DEFAULT NULL
                            ,p_tab_bal_ele_ids      IN     t_ele_ids_from_bal DEFAULT g_tab_sal_ele_ids
                            )
  return number is
--
  l_proc_name            VARCHAR2(60) := g_proc_name || 'calc_part_time_sal';
  l_effective_date       DATE;
  l_total_part_time_sal  NUMBER := 0;
  l_part_time_sal        NUMBER := 0;
  l_cl_sal               NUMBER := 0;
  l_total_cl_sal         NUMBER := 0;
  l_effective_start_date DATE ;
  l_effective_end_date   DATE ;
  l_period_start_date    DATE ;                 -- rahul supply
  l_period_end_date      DATE ;                 -- rahul supply
  l_return               NUMBER;

  l_pre_part_payment     NUMBER :=0;
  l_post_part_payment    NUMBER :=0;
  l_count                NUMBER; -- Loop counter

  l_terminated_payment   NUMBER :=0;

  --TERM_LSP:BUG :4135481 Check for terminated employees
  l_is_terminated        VARCHAR2(1) := 'N';

  -- RETRO:BUG: 4135481
  l_asg_act_dtl          csr_get_asg_act_id_retro%ROWTYPE;
  l_error                NUMBER;

  l_next_payroll_start_date    DATE;

  -- 4336613 : OSLA_3A
  l_sal_bal_type_id      NUMBER :=0;
  l_cl_bal_type_id       NUMBER :=0;
  i                      NUMBER :=0;

  l_supp_claim           NUMBER := 0;
--
begin

  debug_enter(l_proc_name);

  debug('p_assignment_id: '||to_char(p_assignment_id), 10);
  debug('p_effective_start_date: '||to_char(p_effective_start_date));
  debug('p_effective_end_date: '||to_char(p_effective_end_date));
  debug('p_business_group_id: '||to_char(p_business_group_id));
  debug('p_sal_bal_type_id: '||to_char(p_sal_bal_type_id));

  -- PERF_ENHANC_3A : Performance Enhancements
  -- check if record corresponding to p_assignment_id is present in the
  -- collection g_asg_recalc_details.
  -- If yes, check for matching start_date (a double check,although not necessary)
  -- If part_time_sal_paid has been calculated before, then the row
  -- will contain the value,return it.
  -- If part_time_sal_paid for this assignment has not been calculated before,
  -- compute it, store it in a row for this assignment_id and return it
  -- This step is to avoid recomputing the value for a given LOS. Originally,
  -- calculations were repeated for each data element


  IF (p_sal_bal_type_id IS NULL -- 4336613 : OSLA_3A : if NULL implies we need to calculate
                                -- PT sal paid, and not OSLA
      AND
      g_asg_recalc_details.EXISTS(p_assignment_id) -- check if row exists
      AND
      g_asg_recalc_details(p_assignment_id).eff_start_date = p_effective_start_date
      AND
      -- check below to find if PT sal paid has been calculated before
      g_asg_recalc_details(p_assignment_id).part_time_sal_paid IS NOT NULL
      ) THEN

    debug(l_proc_name, 30);
    l_total_part_time_sal := g_asg_recalc_details(p_assignment_id).part_time_sal_paid;
    debug('l_total_part_time_sal is already present !! '||l_total_part_time_sal, 40);

  ELSE -- calc_part_time_paid has to be computed for this assignment_id for this LOS

    debug(l_proc_name, 50);

    IF p_sal_bal_type_id IS NULL THEN -- calculate PT sal paid, and not OSLA
      debug(l_proc_name, 60);
      l_sal_bal_type_id := g_sal_bal_type_id(p_business_group_id);
      l_cl_bal_type_id  := g_cl_bal_type_id(p_business_group_id);
    ELSE
      debug(l_proc_name, 70);
      l_sal_bal_type_id := p_sal_bal_type_id; -- pick up from the parameter
      l_cl_bal_type_id  := p_cl_bal_type_id;
    END IF;

    debug('l_sal_bal_type_id : '||l_sal_bal_type_id, 80);


    --CALC_PT_SAL_OPTIONS: BUG : 4135481
    -- check if calc_part_time_sal OR calc_part_time_sal_old is to be used
  /*
  IF g_calc_sal_new <> 'Y' AND
       (pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number <> '0966' OR
       g_date_work_mode <> 'Y') THEN -- switch is YES for old method
   */
    IF g_calc_sal_new <> 'Y' THEN
      debug(l_proc_name, 90);

      l_total_part_time_sal := calc_part_time_sal_old
                               (p_assignment_id           => p_assignment_id
                               ,p_effective_start_date    => p_effective_start_date
                               ,p_effective_end_date      => p_effective_end_date
                               ,p_business_group_id       => g_business_group_id
                               ,p_next_payroll_start_date => l_next_payroll_start_date --BUG : 4273915
                                                          -- new parameter (last complete payroll run date)
                               ,p_sal_bal_type_id         => l_sal_bal_type_id -- 4336613 : OSLA_3A
                               );

      debug('l_total_part_time_sal :'||l_total_part_time_sal, 110);
      debug('l_next_payroll_start_date:'|| l_next_payroll_start_date);


    -- BUG : 4273915
    -- We now need to test for terminated person case
    -- If no complete payroll exist for that person
    -- eg person assignment starts on 1-apr-2000 and terminates b4 30-apr-2000
    -- in such a case, we set the last_payroll_date = effective_start_date of assignment

    -- else we set the last_payroll_date = the next day of the last complete payroll end date
    -- eg person starts 01-apr2000 and terminates on say 15-jun-2000.
    -- Then we set last_payroll_date = 31-may-2000(last complete payrol run date) + 1 = 01-jun-2000


      --Check for terminated employees
      IF g_terminated_person = 'Y' THEN

        debug(l_proc_name, 120);

        l_is_terminated := get_terminated_payments
                         ( p_assignment_id        => p_assignment_id
                          ,p_effective_start_date => l_next_payroll_start_date
                          ,p_effective_end_date   => p_effective_end_date
                          ,p_business_group_id    => g_ext_asg_details(p_assignment_id).business_group_id
                          ,p_part_payment         => l_terminated_payment
                          ,p_balance_type_id      => l_sal_bal_type_id -- 4336613 : OSLA_3A
                          ) ;

        l_total_part_time_sal := l_total_part_time_sal + l_terminated_payment;
        debug('l_is_terminated :'|| l_is_terminated ,130);
        debug('l_post_part_payment :'|| to_char(l_post_part_payment));
        debug('l_total_part_time_sal :'|| to_char(l_total_part_time_sal) );

      END IF;


    ELSE -- g_calc_sal_new = 'Y', use the new implementation of calc_part_time_sal

      debug('p_assignment_id :' ||to_char(p_assignment_id),140) ;
      debug('p_effective_start_date :' ||to_char(p_effective_start_date, 'DD/MM/YYYY')) ;
      debug('p_effective_end_date :' ||to_char(p_effective_end_date, 'DD/MM/YYYY')) ;

      l_effective_end_date   := p_effective_end_date ;
      l_effective_start_date := p_effective_start_date ;

      -- PTS: BUG 4135481: get the total salary payments in THREE parts
      -- (1) Pre payments : any prorated payment in the begining of the period
      -- (2) Payments for Full Payroll Periods
      -- (3) Post Payment: any prorated payments at the end of the period.


      --If the person is not terminated then his salary is calculated as per
      --regular post_part_payment method.
      IF g_proration = 'Y'
      THEN
      debug('g_proration is set to Y',299);
      debug('g_ext_asg_details(p_assignment_id).location_id  : ' || to_char(g_ext_asg_details(p_assignment_id).location_id),1212);
      debug('pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number :'|| pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number, 300) ;
      debug('g_date_work_mode is set to ' || g_date_work_mode,299);
 --     IF pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number <> '0966' OR g_date_work_mode <> 'Y' THEN
        debug(l_proc_name, 150);
        -- get the pre payments here. (if any)
        -- the function returns the modified dates for the Full Pyroll Periods
        -- these will be used to get the Full Payroll Period payments.
        l_return := adjust_pre_part_payments
                             ( p_assignment_id        => p_assignment_id -- in
                              ,p_balance_type_id      => l_sal_bal_type_id -- 4336613 : OSLA_3A : g_sal_bal_type_id(p_business_group_id)
                              ,p_effective_start_date => l_effective_start_date --in/out
                              ,p_effective_end_date   => l_effective_end_date  -- in/out
                              ,p_part_payment         => l_pre_part_payment -- out
                              ,p_tab_bal_ele_ids      => p_tab_bal_ele_ids -- in -- 4336613 : OSLA_3A
                              );

        debug('l_return :'||to_char(l_return),160) ;
        debug('l_pre_part_payment :'||to_char(l_pre_part_payment)) ;
        debug('l_effective_start_date :'||to_char(l_effective_start_date, 'DD/MM/YYYY')) ;
        debug('l_effective_end_date :'||to_char(l_effective_end_date, 'DD/MM/YYYY')) ;
 --     END IF;
     END IF;
      -- 4336613 : moved code to fetch defined balance id to global settings.

      l_count := 1;
  --    IF pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number = '0966' and g_date_work_mode = 'Y' THEN
     --ELSE
      debug('Calling csr_get_asg_act_id_retro',302);

      OPEN csr_get_asg_act_id_retro
                   (p_assignment_id        => p_assignment_id
                   ,p_effective_start_date => l_effective_start_date
                   ,p_effective_end_date   => l_effective_end_date
                    );
      LOOP

      FETCH csr_get_asg_act_id_retro into l_asg_act_dtl;
      EXIT WHEN csr_get_asg_act_id_retro%NOTFOUND;
      debug('calling get value for date earned mode',303);
      debug('Defined balance id = '||to_char(g_def_bal_id(l_sal_bal_type_id)),304);

      debug('assignment_action_id: '||to_char(l_asg_act_dtl.assignment_action_id), 170+l_count/10000);
      debug('date_earned: '||to_char(l_asg_act_dtl.date_earned,'DD/MM/YYYY'));
      l_part_time_sal := pay_balance_pkg.get_value
                         ( p_defined_balance_id   => g_def_bal_id(l_sal_bal_type_id)
                          ,p_assignment_action_id => l_asg_act_dtl.assignment_action_id
                         ) ;

      debug('l_part_time_sal :'||to_char(l_part_time_sal), 180+l_count/10000) ;

      l_count := l_count + 1 ;
      l_effective_date := l_asg_act_dtl.date_earned;
      l_total_part_time_sal := l_total_part_time_sal + l_part_time_sal;
      debug('l_total_part_time_sal :'||to_char(l_total_part_time_sal),190+l_count/10000) ;

      END loop;
      CLOSE csr_get_asg_act_id_retro;

    /*
      IF g_date_work_mode = 'Y' AND g_supp_teacher = 'Y' THEN
        OPEN csr_get_supp_ded(l_sal_bal_type_id,p_assignment_id,l_effective_start_date,l_effective_end_date);
        FETCH csr_get_supp_ded INTO l_supp_claim;
        CLOSE csr_get_supp_ded;
        debug('l_supp_claim :'||to_char(l_supp_claim),208);
        l_total_part_time_sal := l_total_part_time_sal - l_supp_claim;
        debug('l_total_part_time_sal after supply claims deduction:'||to_char(l_total_part_time_sal),209) ;
      END IF;
    */

     -- END IF;


     debug('l_total_part_time_sal :'||to_char(l_total_part_time_sal),210) ;
     debug('.....retro payments calc over.....') ;

     debug('l_effective_date :'||to_char(l_effective_date, 'DD/MM/YYYY'),220) ;


      -- PTS:BUG 4135481:  get the post payments here. (if any)
      IF l_effective_date IS NOT NULL THEN

        debug(l_proc_name, 230);
      -- there were few Full payroll periods
      -- so the start for the for post payment is the end of Full Payroll Periods.
        l_effective_date := l_effective_date + 1; -- next date of he last payroll date

      ELSE -- l_effective_date IS NOT NULL THEN
           -- it implies that there are no complete Payroll Periods
           -- so get the Post payments (if any)
           -- for the remaining days in the period.
        debug(l_proc_name, 240);
        l_effective_date := l_effective_start_date;

      END IF;

      debug('l_effective_start_date :' ||to_char(l_effective_start_date, 'DD/MM/YYYY'),250) ;
      debug('p_effective_end_date :' ||to_char(p_effective_end_date, 'DD/MM/YYYY')) ;


      --CALC_PT_SAL_OPTIONS: BUG : 4135481
      --TERM_LSP:BUG :4135481 Check for terminated employees
      --if the global is set to Y  then check if the person is terminated
      IF g_terminated_person = 'Y' THEN

        debug(l_proc_name, 260);

        l_is_terminated := get_terminated_payments
                         ( p_assignment_id        => p_assignment_id
                          ,p_effective_start_date => l_effective_date
                          ,p_effective_end_date   => p_effective_end_date
                          ,p_business_group_id    => g_ext_asg_details(p_assignment_id).business_group_id
                          ,p_part_payment         => l_terminated_payment
                          ,p_balance_type_id      => l_sal_bal_type_id -- 4336613 : OSLA_3A : g_sal_bal_type_id(p_business_group_id)
                          );
        debug('l_is_terminated :'|| l_is_terminated ,270);
      END IF;


      --If the person is not terminated then his salary is calculated as per
      --regular post_part_payment method.

      -- Extra condition has been added for bug 7269761
      -- In case of start date and end date are on same date calculation of
      -- salary for that day is done by prepayments part and no need to run post payments part for that day
      IF l_is_terminated = 'N' AND g_proration = 'Y' AND l_effective_date <> p_effective_end_date
      THEN

        debug(l_proc_name, 280);
        l_return := adjust_post_part_payments
                            ( p_assignment_id       => p_assignment_id
                            ,p_balance_type_id      => l_sal_bal_type_id -- 4336613 : OSLA_3A : parameter based
                            ,p_effective_start_date => l_effective_date
                            ,p_effective_end_date   => p_effective_end_date
                            ,p_part_payment         => l_post_part_payment -- out
                            ,p_tab_bal_ele_ids      => p_tab_bal_ele_ids -- in -- 4336613 : OSLA_3A
                            );
        debug('l_return :' ||to_char(l_return),290) ;
        debug('l_post_part_payment :' ||to_char(l_post_part_payment)) ;
      END IF;


      debug('l_pre_part_payment :'||to_char(l_pre_part_payment),310);
      debug('l_total_part_time_sal :'||to_char(l_total_part_time_sal));
      debug('l_post_part_payment :'||to_char(l_post_part_payment));

      -- PTS: BUG 4135481:  add all the payments to get the final payments
      l_total_part_time_sal := l_pre_part_payment + l_total_part_time_sal
                               + l_post_part_payment + l_terminated_payment;

    END IF; -- end of check if calc_part_time_sal OR calc_part_time_sal_old is to be used

      IF g_date_work_mode = 'Y' THEN
      debug('Calling csr_get_asg_act_id_dw',302);
	 OPEN csr_get_asg_act_id_dw
              (p_assignment_id        => p_assignment_id
               ,p_effective_start_date => p_effective_start_date
               ,p_effective_end_date   => p_effective_end_date
              );
          FETCH csr_get_asg_act_id_dw into l_asg_act_dtl;
         CLOSE csr_get_asg_act_id_dw;

        OPEN csr_get_dw_value(l_cl_bal_type_id,
                              l_asg_act_dtl.assignment_action_id,
                              p_effective_start_date,
                              p_effective_end_date
                             );
        FETCH csr_get_dw_value INTO l_cl_sal;
        CLOSE csr_get_dw_value;

	l_total_cl_sal := l_cl_sal;
        l_effective_date := p_effective_end_date;
        l_total_part_time_sal := l_total_part_time_sal +  l_total_cl_sal;
      END IF;

    IF l_total_part_time_sal IS NULL THEN
      debug(l_proc_name, 320);
      l_total_part_time_sal := 0;
    END IF;

    debug('l_total_part_time_sal :'||to_char(l_total_part_time_sal),330);


    IF p_sal_bal_type_id IS NULL THEN -- 4336613 : OSLA_3A : check if OSLA or PT sal paid
                                      -- IF null => PT sal paid is being computed
      debug(l_proc_name, 340);
      -- PERF_ENHANC_3A : performance enhancements
      -- computed part_time_sal_paid value being stored in the collection for future use
      g_asg_recalc_details(p_assignment_id).part_time_sal_paid := l_total_part_time_sal;
      debug('l_total_part_time_sal (1st time computation) :'||l_total_part_time_sal, 350);

    END IF;
    debug(l_proc_name, 350);
  END IF; -- IF (g_asg_recalc_details.EXISTS.... )

    debug(l_proc_name, 360);
    debug_exit(l_proc_name);

    return l_total_part_time_sal;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END calc_part_time_sal;--


-- 4336613 : OSLA_3A : GET_GROSSED_OSLA_PAYMENTS
-- calculates the OSLA payments for a LOS, and grosses it up for the year.
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_grossed_osla_payments >----------------------------|
-- ----------------------------------------------------------------------------
function get_grossed_osla_payments (p_assignment_id        in     number
                                   ,p_effective_start_date in     date
                                   ,p_effective_end_date   in     date
                                   ,p_business_group_id    in     number
                                    )
  return number is
--
  l_proc_name            VARCHAR2(60) := g_proc_name || 'get_grossed_osla_payments';
  l_grossed_osla_payment NUMBER := 0;
  l_return               NUMBER;

--
begin

  debug_enter(l_proc_name);
  debug('p_effective_start_date: '||to_char(p_effective_start_date), 10);
  debug('p_effective_end_date: '||to_char(p_effective_end_date));

  debug('TOTAL number of OSLA elements: '|| to_char(g_tab_osla_ele_ids.COUNT), 20);

  IF g_tab_osla_ele_ids.COUNT > 0 THEN

    debug(l_proc_name, 30) ;
    -- a call to calc_part_time_sal
    -- the last 2 parameters have been introduced in part_time_sal to make it generic
    l_grossed_osla_payment := calc_part_time_sal
                           (p_assignment_id        => p_assignment_id
                           ,p_effective_start_date => p_effective_start_date
                           ,p_effective_end_date   => p_effective_end_date
                           ,p_business_group_id    => g_business_group_id
                           ,p_sal_bal_type_id      => g_osla_bal_type_id(p_business_group_id)
                           ,p_cl_bal_type_id       => g_osla_cl_bal_type_id(p_business_group_id)
                           ,p_tab_bal_ele_ids      => g_tab_osla_ele_ids
                           );
    debug('l_grossed_osla_payment: '||to_char(l_grossed_osla_payment), 40) ;

    -- grossing up the payment to calculate the rate
    l_grossed_osla_payment := ((l_grossed_osla_payment * 365) / (trunc(p_effective_end_date) - trunc(p_effective_start_date) + 1));

  ELSE
    debug(l_proc_name, 50) ;
    l_grossed_osla_payment := 0;
  END IF;

  debug('l_grossed_osla_payment :'||to_char(l_grossed_osla_payment),60);

  debug_exit(l_proc_name);

  return l_grossed_osla_payment;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END get_grossed_osla_payments;

-- ----------------------------------------------------------------------------
-- |------------------------< get_gtc_payments >----------------------------|
-- ----------------------------------------------------------------------------
function get_gtc_payments         (p_assignment_id        in     number
                                   ,p_effective_start_date in     date
                                   ,p_effective_end_date   in     date
                                   ,p_business_group_id    in     number
                                    )
  return number is
--
  l_proc_name            VARCHAR2(60) := g_proc_name || 'get_gtc_payments';
  l_gtc_payment NUMBER := 0;
  l_return               NUMBER;
  l_next_payroll_start_date  DATE;
--
begin

  debug_enter(l_proc_name);
  debug('p_effective_start_date: '||to_char(p_effective_start_date), 10);
  debug('p_effective_end_date: '||to_char(p_effective_end_date));

  debug('TOTAL number of GTC elements: '|| to_char(g_tab_gtc_ele_ids.COUNT), 20);

  IF g_tab_gtc_ele_ids.COUNT > 0 THEN

    debug(l_proc_name, 30) ;

     l_gtc_payment := calc_part_time_sal_old
                               (p_assignment_id           => p_assignment_id
                               ,p_effective_start_date    => p_effective_start_date
                               ,p_effective_end_date      => p_effective_end_date
                               ,p_business_group_id       => g_business_group_id
                               ,p_next_payroll_start_date => l_next_payroll_start_date
                               ,p_sal_bal_type_id         => g_gtc_bal_type_id(p_business_group_id)
                               );

    debug('l_gtc_payment: '||to_char(l_gtc_payment), 40) ;

  ELSE
    debug(l_proc_name, 50) ;
    l_gtc_payment := 0;
  END IF;

  debug('l_gtc_payment :'||to_char(l_gtc_payment),60);

  debug_exit(l_proc_name);

  return l_gtc_payment;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END get_gtc_payments;


-- ----------------------------------------------------------------------------
-- |------------------------< get_part_time_sal_date >------------------------|
-- ----------------------------------------------------------------------------
function get_part_time_sal_date (p_assignment_id        in     number
                                ,p_effective_start_date in    date
                                ,p_effective_end_date   in    date
                                )
return number is
--
  l_proc_name           varchar2(60) := g_proc_name || 'get_part_time_sal_date';
  l_part_time_sal       number := 0;
  l_tab_mult_asg        t_sec_asgs_type;
  l_error               number;
  l_sec_eff_start_date  date;
  l_sec_eff_end_date    date;
  i                     number;
  l_eff_sec_count       NUMBER := 0 ;--Sec asg tchr on p_effective_start_date
  l_look_for_sec_asg    varchar2(1) := 'Y';
 --
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);
  debug('p_assignment_id: '||p_assignment_id);
  debug('p_effective_start_date: '||p_effective_start_date);
  debug('p_effective_end_date: '||p_effective_end_date);

  debug('g_part_time_asg_count: '||g_part_time_asg_count,10);
  -- Bugfix 3803760:FTSUPPLY
  -- If override ft asg is set, always return zero
  IF g_override_ft_asg_id IS NOT NULL THEN
    debug('Override is set, returning zero', 11);
    debug_exit(l_proc_name);
    RETURN 0;
  -- if there are multiple concurrent part time assignment (primary or secondary) and ft sal rates are not equal
  ELSIF g_part_time_asg_count > 1 AND g_equal_sal_rate = 'N' THEN
    debug('PT Asg count > zero, returning one', 12);
    debug_exit(l_proc_name);
    RETURN 1;
  END IF ;

  -- Check for multiple teaching assignments
  -- Bugfix 3803760:FTSUPPLY : Now using g_tab_sec_asgs instead of
  --  calling get_eff_secondary_asgs
  l_tab_mult_asg := g_tab_sec_asgs;

  debug('l_tab_mult_asg.count: '||l_tab_mult_asg.count,20);
  l_eff_sec_count := l_tab_mult_asg.count ;

  -- there are concurrent assignments and ft sal rates are not equal
  IF l_eff_sec_count > 1 AND g_equal_sal_rate = 'N' THEN

     debug_exit(l_proc_name);
     RETURN 1;

   END IF;

  -- Call this function only if primary assignment qualifies for
  -- report
  -- Bug Fix 3073562:GAP6

  debug('assignemnt_id: '||p_assignment_id,50);
  debug('start_date: '||g_ext_asg_details(p_assignment_id).start_date);
  debug('teacher_start_date: '||g_ext_asg_details(p_assignment_id).teacher_start_date);
  debug('leaver_date: '||g_ext_asg_details(p_assignment_id).leaver_date);
  debug('restarter_date: '||g_ext_asg_details(p_assignment_id).restarter_date);

  -- MULT-LR --
  -- Use the new Function to check the effectivness of an assignment
  -- it takes care of multiple Leaver-Restarter events
  -- where as the old logic used to take into account
  -- only the first restarter event.
  IF ( chk_effective_asg (
           p_assignment_id  => p_assignment_id
          ,p_effective_date => p_effective_start_date
                          ) = 'Y'
      )
  THEN
    debug(l_proc_name, 60);

    --if only the primary is valid on the start date or the ft sal rate is same as other pt assignments.
    IF l_eff_sec_count = 0 OR g_equal_sal_rate = 'Y' THEN
      --
      debug(l_proc_name, 70);
      --
      l_part_time_sal := l_part_time_sal +
                           calc_part_time_sal
                           (p_assignment_id        => p_assignment_id
                           ,p_effective_start_date => p_effective_start_date
                           ,p_effective_end_date   => p_effective_end_date
                           ,p_business_group_id    => g_business_group_id
                           );

  --    l_part_time_sal := round(l_part_time_sal);
      debug('l_part_time_sal of asg '||p_assignment_id||' = '||l_part_time_sal,70);
      -- Look for Secondary assignments also if FT sal rate is equal
      IF g_equal_sal_rate = 'Y' THEN
        l_look_for_sec_asg := 'Y';
      ELSE
         l_look_for_sec_asg := 'N';
      END IF;
      debug('look for secondary assignments ' || l_look_for_sec_asg,70);
    ELSE -- secondary assignment exists
      debug(l_proc_name, 80);
      debug_exit (l_proc_name);

      RETURN 1;

    END IF; -- End if of secondary assignment check ...

  -- ELSE -- primary assignment does not qualify
  END IF; -- End if of primary assignment qualifies check ...

    -- Fetch the part time salary information if there is
    -- only one secondary assignment
    debug(l_proc_name, 90);
 --   IF l_eff_sec_count = 1 THEN
      IF l_look_for_sec_asg = 'Y' THEN
      --
      debug(l_proc_name, 110);
      --
      i := l_tab_mult_asg.FIRST ;

      WHILE i IS NOT NULL
      LOOP
      l_sec_eff_start_date := greatest
                                 (p_effective_start_date
                                 ,g_ext_asg_details(l_tab_mult_asg(i).assignment_id).start_date
                                 );

      -- MULT-LR --
      -- Use the new Function to get the correct end date
      -- based on the multiple restarter events
      -- It takes care of multiple Leaver-Restarter events
      -- where as the old logic used to take into account
      -- only the first restarter event.

      -- Performance changes
      -- no need to call tihs function as we are checking assignment status in chk_effective_asg
      /*
      l_sec_eff_end_date := get_eff_end_date (
                                p_assignment_id        => l_tab_mult_asg(i).assignment_id
                               ,p_effective_start_date => p_effective_start_date
                               ,p_effective_end_date   => p_effective_end_date
                               ) ;
      */

      l_sec_eff_end_date := p_effective_end_date;

      debug('l_sec_eff_end_date: '|| to_char(l_sec_eff_end_date,'DD/MM/YYYY'),112) ;

      l_part_time_sal := l_part_time_sal +
                           calc_part_time_sal
                           (p_assignment_id        => l_tab_mult_asg(i).assignment_id
                           ,p_effective_start_date => l_sec_eff_start_date
                           ,p_effective_end_date   => l_sec_eff_end_date
                           ,p_business_group_id    => g_ext_asg_details(l_tab_mult_asg(i).assignment_id).business_group_id
                           );
 debug('l_part_time_sal of after processing asg '||l_tab_mult_asg(i).assignment_id||' = '||l_part_time_sal,80);
  --    l_part_time_sal := round(l_part_time_sal);

      i := l_tab_mult_asg.NEXT(i);
    END LOOP;

    ELSE -- no secondary assignments

  --    l_part_time_sal := 0; --condition should not arise
      debug (l_proc_name ||' This Condition should not arise..',115 );

    END IF; -- End if of secondary assignment exists check ...
  -- round the pt salary after adding all the asg contributions.
    l_part_time_sal := round(l_part_time_sal);
  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 30);
  --
  debug('l_part_time_sal :'||to_char(l_part_time_sal),120);

  -- 4336613 : SAL_VALIDAT_3A : Check whether part time sal value has exceeeded 5 digit limit
  -- If yes, raise warning.
  if l_part_time_sal > 999999 then

     l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                     (p_assignment_id => p_assignment_id
                     ,p_error_text    => 'BEN_93042_EXT_TP1_PT_SAL_EXC'
                     ,p_error_number  => 93042
                     ,p_token1        => TO_CHAR(l_part_time_sal) -- bug : 4336613
                     );
     l_part_time_sal := 999999; -- 4336613 : SAL_VALIDAT_3A : set to 99999 if > 99999

  end if; -- end if of part time sal value maxim limit check ...

  debug('l_part_time_sal :'||to_char(l_part_time_sal),125);

  debug_exit(l_proc_name);
  return l_part_time_sal;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end get_part_time_sal_date;

--
-- ----------------------------------------------------------------------------
-- |------------------------< calc_days_worked >------------------------------|
-- ----------------------------------------------------------------------------
function calc_days_worked (p_assignment_id        in     number
                          ,p_effective_start_date in     date
                          ,p_effective_end_date   in     date
                          ,p_annual_sal_rate      in     number
                          )
  return number is
--
  l_proc_name     varchar2(60) := g_proc_name || 'calc_days_worked';
  l_part_time_sal number;
  l_days_worked   number := 0;
--
begin
  --
  -- hr_utility.set_location ('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- Call this function only if salary rate is non zero

  if p_annual_sal_rate <> 0 then

    -- Get part time salary paid for this period

    l_part_time_sal := calc_part_time_sal
                         (p_assignment_id        => p_assignment_id
                         ,p_effective_start_date => p_effective_start_date
                         ,p_effective_end_date   => p_effective_end_date
                         ,p_business_group_id    => g_ext_asg_details(p_assignment_id).business_group_id
                         );

    -- Calculate days worked

    l_days_worked := (l_part_time_sal/p_annual_sal_rate) * 365;

  else

     l_days_worked := 0;

  end if; -- end if of annual rate value check ...

  --
  -- hr_utility.set_location ('Leaving: '||l_proc_name, 20);
  --
  debug('l_days_worked :'||to_char(l_days_worked));
  debug_exit(l_proc_name);

  return l_days_worked;

  --
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end calc_days_worked;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_eev_info >----------------------------------|
-- ----------------------------------------------------------------------------
procedure get_eev_info (p_element_entry_id     in     number
                       ,p_input_value_id       in     number
                       ,p_effective_start_date in     date
                       ,p_effective_end_date   in     date
                       ,p_tab_eev_info         out nocopy csr_get_eev_info_date%rowtype
                       ) is
--
  l_proc_name      varchar2(60) := g_proc_name || 'get_eev_info';
--
begin
  --
  -- hr_utility.set_location ('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  open csr_get_eev_info_date
    (c_element_entry_id     => p_element_entry_id
    ,c_input_value_id       => p_input_value_id
    ,c_effective_start_date => p_effective_start_date
    ,c_effective_end_date   => p_effective_end_date
    );
  fetch csr_get_eev_info_date into p_tab_eev_info;
  close csr_get_eev_info_date;

  --
  -- hr_utility.set_location ('Leaving :'||l_proc_name, 20);
  --
  debug_exit(l_proc_name);

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(' Others in '||l_proc_name);
       p_tab_eev_info := NULL;
       raise;

end get_eev_info;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_days_absent >-------------------------------|
-- ----------------------------------------------------------------------------
function get_days_absent (p_element_type_id      in     number
                         ,p_element_entry_id     in     number
                         ,p_effective_start_date in     date
                         ,p_effective_end_date   in     date
                         )
  return number is
--
  l_proc_name             varchar2(60) := g_proc_name || 'get_days_absent';
  l_start_dt_iv_info      csr_get_iv_info%rowtype;
  l_days_abs_iv_info      csr_get_iv_info%rowtype;
  l_start_dt_vals         csr_get_eev_info%rowtype;
  l_days_abs_vals         csr_get_eev_info%rowtype;
  l_abs_start_day         date;
  l_days                  number := 0;
  l_total_days            number := 0;
  l_ref_date              date;
--
begin
  --
  -- hr_utility.set_location ('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- Get input value id for Start Date
  open csr_get_iv_info
    (c_element_type_id  => p_element_type_id
    ,c_input_value_name => 'Start Date'
    );
  fetch csr_get_iv_info into l_start_dt_iv_info;
  close csr_get_iv_info;

  -- Get input value id for Days Absent
  open csr_get_iv_info
    (c_element_type_id  => p_element_type_id
    ,c_input_value_name => 'Days Absent'
    );
  fetch csr_get_iv_info into l_days_abs_iv_info;
  close csr_get_iv_info;

  -- Get eev info for start date input value
  --
  debug (l_proc_name, 20);
  --

  open csr_get_eev_info
    (c_element_entry_id     => p_element_entry_id
    ,c_input_value_id       => l_start_dt_iv_info.input_value_id
    ,c_effective_start_date => p_effective_start_date
    ,c_effective_end_date   => p_effective_end_date
    );
  loop
    fetch csr_get_eev_info into l_start_dt_vals;
    exit when csr_get_eev_info%notfound;

    l_abs_start_day := fnd_date.canonical_to_date(l_start_dt_vals.screen_entry_value);
    if trunc(p_effective_end_date) < trunc(l_abs_start_day)
    then

       exit;

    end if; -- end if of effective end date check ...

    -- Get eev info for Days absent input value
    --
    debug (l_proc_name, 30);
    --
    get_eev_info (p_element_entry_id     => p_element_entry_id
                 ,p_input_value_id       => l_days_abs_iv_info.input_value_id
                 ,p_effective_start_date => l_start_dt_vals.effective_start_date
                 ,p_effective_end_date   => l_start_dt_vals.effective_end_date
                 ,p_tab_eev_info         => l_days_abs_vals
                 );

    -- BUGFIX 2340488
    -- Change line below, now doing a minus 1
    l_ref_date := (trunc(l_abs_start_day) +
                    l_days_abs_vals.screen_entry_value) - 1;

    if l_ref_date > trunc(p_effective_end_date) then

       -- BUGFIX 2340488
       -- Changed line below, now doing a + 1
       l_days := (trunc(p_effective_end_date) -
                   trunc(l_abs_start_day)) + 1;

    else

      -- Bug fix 2419860
      if l_ref_date >= trunc(p_effective_start_date) and
         trunc(p_effective_start_date) > trunc(l_abs_start_day)
      then

         l_days := (l_ref_date - trunc(p_effective_start_date)) + 1;

      elsif trunc(p_effective_start_date) <= trunc(l_abs_start_day) then

         l_days := l_days_abs_vals.screen_entry_value;

      end if; -- end of of ref_date > eff_start_date check...

    end if; -- end if of ref date check ...

    l_total_days := l_total_days + l_days;

  end loop;
  close csr_get_eev_info;

  debug('l_total_days :'||to_char(l_total_days), 40);
  --
  -- hr_utility.set_location ('Leaving: '||l_proc_name, 40);
  --
  debug_exit(l_proc_name);

  return l_total_days;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end get_days_absent;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_eet_info >----------------------------------|
-- ----------------------------------------------------------------------------
function get_eet_info (p_assignment_id        in     number
                      ,p_tab_ele_ids          in     t_ele_ids_from_bal
                      ,p_effective_start_date in     date
                      ,p_effective_end_date   in     date
                      )
  return number is
--
  l_proc_name      varchar2(60) := g_proc_name || 'get_eet_info';
  l_eet_details    csr_get_eet_info%rowtype;
  l_days_absent    number := 0;
  l_total_days     number := 0;
--
begin
  --
  -- hr_utility.set_location ('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- Check element entries exist in  absence ele's

  open csr_get_eet_info
    (c_assignment_id        => p_assignment_id
    ,c_effective_start_date => p_effective_start_date
    ,c_effective_end_date   => p_effective_end_date
    );
  loop

    fetch csr_get_eet_info into l_eet_details;
    exit when csr_get_eet_info%notfound;

    if p_tab_ele_ids.exists(l_eet_details.element_type_id) then

       -- absence element exists
       -- get the no of days from the element
       --
       debug (l_proc_name, 20);
       --
       l_days_absent := get_days_absent
                          (p_element_type_id       => l_eet_details.element_type_id
                          ,p_element_entry_id      => l_eet_details.element_entry_id
                          ,p_effective_start_date  => p_effective_start_date
                          ,p_effective_end_date    => p_effective_end_date
                          );
       l_total_days := l_total_days + l_days_absent;

    end if; -- end if of element id exists check ...

  end loop;
  close csr_get_eet_info;

  debug('l_total_days :'||to_char(l_total_days), 30);
  --
  -- hr_utility.set_location ('Leaving: '||l_proc_name, 30);
  --
  debug_exit(l_proc_name);

  return l_total_days;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end get_eet_info;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_ft_days_excluded >--------------------------|
-- ----------------------------------------------------------------------------
function get_ft_days_excluded (p_assignment_id        in     number
                              ,p_effective_start_date in     date
                              ,p_effective_end_date   in     date
                              )
  return number is
--
  l_proc_name        varchar2(60) := g_proc_name || 'get_ft_days_excluded';
  l_absence_bal_name pay_balance_types.balance_name%type;
  l_days_excluded    number;
  l_part_time_sal    number;
  l_eff_start_date   date  ;
  l_eff_end_date     date ;

--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- GAP9: Modified function to incorporate changes for supply teachers
  -- 1. Check whether the assignment location is a supply teacher establishment
  -- 2. If it is get the part time salary paid for the assignment.
  -- 3. Return 365 only if the part time salary paid value is zero
  --    otherwise use the existing logic to determine days excluded value

  l_days_excluded := NULL; -- Initialize first
  debug('g_supply_asg_count ' || to_char(g_supply_asg_count),10);
  IF g_supply_asg_count > 0 THEN

     debug (l_proc_name, 20);
     debug ('Establishment Number: '||
             pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number,30
           );

     -- Check whether the establishment number = 0966
     IF pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number = '0966'
     THEN
       debug (l_proc_name, 40);

       -- Calculate the part time salary paid in the entire year
       -- If the salary paid is Zero, then the days_excluded will be = period length

       l_eff_start_date  := GREATEST(g_pension_year_start_date,p_effective_start_date
                              ,g_ext_asg_details(p_assignment_id).teacher_start_date
                              );

       -- MULT-LR --
       -- Use the new Function to get the correct end date
       -- based on the multiple restarter events
       -- It takes care of multiple Leaver-Restarter events
       -- where as the old logic used to take into account
       -- only the first restarter event.

       -- Performance changes
       -- no need to call tihs function as we are checking assignment status in chk_effective_asg
       /*
       l_eff_end_date := get_eff_end_date (
                                p_assignment_id        => p_assignment_id
                               ,p_effective_start_date => p_effective_start_date
                               ,p_effective_end_date   => p_effective_end_date
                               ) ;
        */

        l_eff_end_date := p_effective_end_date;

        -- Get part time salary paid value for this assignment
        debug ('l_eff_start_date '||fnd_date.date_to_canonical(l_eff_start_date),50);
        debug ('l_eff_end_date '||fnd_date.date_to_canonical(l_eff_end_date));

        l_part_time_sal := calc_part_time_sal
                           (p_assignment_id        => p_assignment_id
                           ,p_effective_start_date => l_eff_start_date
                           ,p_effective_end_date   => l_eff_end_date
                           ,p_business_group_id    => g_ext_asg_details(p_assignment_id).business_group_id
                           );

        debug ('Part Time Sal Paid: '||TO_CHAR(l_part_time_sal),60);

        IF l_part_time_sal = 0 THEN
           debug (l_proc_name, 70);
           --l_days_excluded := 365;
           l_days_excluded := trunc(p_effective_end_date) - trunc(p_effective_start_date) + 1;
        END IF; -- End if of part time salary paid is zero check ...

     END IF; -- End if of establishment number is supply teacher one check ...

  END IF; -- End if of supply asg count > 0 check ...

  debug ('l_days_excluded: '|| to_char(l_days_excluded),80);
  -- If days excluded is set above do not process further...

  IF l_days_excluded IS NULL THEN

    debug (l_proc_name, 90);
    debug ('ext_emp_cat_cd '|| g_ext_asg_details(p_assignment_id).ext_emp_cat_cd);
    IF (g_ext_asg_details(p_assignment_id).ext_emp_cat_cd ='F' ) THEN

      debug (l_proc_name, 110);
      -- Modified the function to include any days excluded from OSP / OMP
      -- call osp function to derive this information
      -- The function should return 0 anyway
      l_days_excluded := pqp_gb_osp_functions.get_absence_paid_days_tp
                         (p_assignment_id => p_assignment_id
                         ,p_start_date    => p_effective_start_date
                         ,p_end_date      => p_effective_end_date
                         ,p_level_of_pay  => 'NOBAND' -- No pay days
                         );
      debug ('Days Excluded from OSP/OMP: ' || l_days_excluded);
      -- check whether absence elements exists for this assignment for this period
      -- get days excluded if element exists

      l_days_excluded := l_days_excluded +
                       get_eet_info
                         (p_assignment_id        => p_assignment_id
                         ,p_tab_ele_ids          => g_tab_abs_ele_ids
                         ,p_effective_start_date => p_effective_start_date
                         ,p_effective_end_date   => p_effective_end_date
                         );
    ELSE
      debug(l_proc_name,115) ;
      l_days_excluded := 0;
    END IF ; --  (g_ext_asg_details(p_assignment_id).ext_emp_cat_cd ='F' )
  END IF; -- End if of l_days_excluded is null check ...

  debug ('l_days_excluded: '|| to_char(l_days_excluded),120);

  -- Bug fix 2411951
  -- Floor the days excluded value to be in favour of teachers

  l_days_excluded := floor(l_days_excluded);

  debug ('Total Days Excluded: '|| to_char(l_days_excluded));
  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 20);
  --
  debug_exit(l_proc_name);

  return l_days_excluded;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
end get_ft_days_excluded;

-- ----------------------------------------------------------------------------
-- |------------------------< get_pt_days_excluded >--------------------------|
-- ----------------------------------------------------------------------------
function get_pt_days_excluded (p_assignment_id        in     number
                              ,p_effective_start_date in     date
                              ,p_effective_end_date   in     date
                              ,p_days                 out nocopy number
                              )
  return number is
--
  l_proc_name          varchar2(60) := g_proc_name || 'get_pt_days_excluded';
  l_tab_mult_asg       t_sec_asgs_type;
  l_safeguarded_yn     varchar2(1) := 'N';
  l_annual_sal_rate    number;
  l_sec_ann_sal_rate   number;
  l_sec_eff_start_date date;
  l_sec_eff_end_date   date;
  l_days_worked        number := 0;
  l_total_days_worked  number := 0;
  l_days_in_period     number := 0;
  l_days_excluded      number := 0;
  l_return             number;
  i                    number;
  l_primary_esd        date;
  l_primary_eed        date;
  l_prev_annual_sal_rate     number := NULL;     -- bug 6275363
  l_equal_sal_rate           varchar2(1) := 'Y'; -- bug 6275363
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- Proceed only if primary assignment qualifies
  -- Bug Fix 3073562:GAP6


  -- Check if hte primary asg is valid TCHR assignment
  -- on the p_effective_start_date

  -- MULT-LR --
  -- Use the new Function to check the effectivness of an assignment
  -- it takes care of multiple Leaver-Restarter events
  -- where as the old logic used to take into account
  -- only the first restarter event.
  IF ( chk_effective_asg (
           p_assignment_id  => p_assignment_id
          ,p_effective_date => p_effective_start_date
                          ) = 'Y'
      )
  THEN


     -- Bugfix 3641851:CBF1 : We need to calculate the days excluded
     --     from start of primary asg as its possible that
     --     primary asg bcomes a teacher after secondary
     l_primary_esd := GREATEST(p_effective_start_date
                              ,g_ext_asg_details(p_assignment_id).start_date
                              );

     -- MULT-LR --
     -- Use the new Function to get the correct end date
     -- based on the multiple restarter events
     -- It takes care of multiple Leaver-Restarter events
     -- where as the old logic used to take into account
     -- only the first restarter event.

     -- Performance changes
     -- no need to call tihs function as we are checking assignment status in chk_effective_asg
     /*
     l_primary_eed := get_eff_end_date (
                                p_assignment_id        => p_assignment_id
                               ,p_effective_start_date => p_effective_start_date
                               ,p_effective_end_date   => p_effective_end_date
                               ) ;
     */

     l_primary_eed := p_effective_end_date;

     debug('l_primary_eSd :'||to_char(l_primary_esd,'DD/MM/YY'));
     debug('l_primary_eEd :'||to_char(l_primary_eed,'DD/MM/YY'));

     -- Get safeguarded information

     l_safeguarded_yn := get_safeguarded_info
                           (p_assignment_id  => p_assignment_id
                           -- Bugfix 3641851:CBF1 : Changed to l_primary_esd
                           ,p_effective_date => l_primary_esd
                           );

     --
     debug(l_proc_name, 20);
     --
     -- Get annual salary rate for primary assignment

     l_return := calc_annual_sal_rate
                   (p_assignment_id        => p_assignment_id
                   -- Bugfix 3641851:CBF1 : Changed to l_primary_esd
                   ,p_calculation_date     => l_primary_esd
                   ,p_safeguarded_yn       => l_safeguarded_yn
                   ,p_fte                  => 'N'
                   ,p_to_time_dim          => 'A'
                   ,p_rate                 => l_annual_sal_rate
                   ,p_effective_start_date => p_effective_start_date
                   ,p_effective_end_date   => p_effective_end_date
                   );

    -- Bugfix 3641851:CBF1 : Moved this here frm below as this
    --  should only be done if primary asg exists and qualifies
    IF l_return <> -1 THEN
      debug (l_proc_name, 25);
      l_prev_annual_sal_rate :=l_annual_sal_rate;  -- bug 6275363
      l_total_days_worked := calc_days_worked
                             (p_assignment_id        => p_assignment_id
                             -- Bugfix 3641851:CBF1 : Using l_primary_esd and l_primary_eed
                             ,p_effective_start_date => l_primary_esd
                             ,p_effective_end_date   => l_primary_eed
                             ,p_annual_sal_rate      => l_annual_sal_rate
                             );
    END IF;
    --
  ELSE -- primary assignment does not qualify
     l_return := 0;
     l_annual_sal_rate := 0;
  END IF; -- primary assignment qualifies check ...

  if l_return <> -1 then

     -- Get days worked for this period
     --
     debug (l_proc_name, 30);
     --

     /* Bugfix 3641851:CBF1 : Moved this into IF part above as this
        should only be done if primary asg exists and qualifies

     l_total_days_worked := calc_days_worked
                              (p_assignment_id        => p_assignment_id
                              ,p_effective_start_date => p_effective_start_date
                              ,p_effective_end_date   => p_effective_end_date
                              ,p_annual_sal_rate      => l_annual_sal_rate
                              );
     */

     -- Check for multiple assignments

     --
     debug(l_proc_name, 40);
     --
     -- Bugfix 3803760:FTSUPPLY : Now using g_tab_sec_asgs instead of
     --  calling get_eff_secondary_asgs
     l_tab_mult_asg := g_tab_sec_asgs;

     if l_tab_mult_asg.count > 0 then

   -- Change the for loop to while loop as the assignment_id is
   -- an index here
   -- BUG FIX 3470242:BUG2

        -- Get annual salary rate for secondary assignments
--        for i in l_tab_mult_asg.first..l_tab_mult_asg.last loop

        i := l_tab_mult_asg.FIRST;
        WHILE i IS NOT NULL
        LOOP

            --
            debug (l_proc_name, 50);
            --

            -- Get safeguarded information

            l_safeguarded_yn := get_safeguarded_info
                                  (p_assignment_id  => l_tab_mult_asg(i).assignment_id
                                  ,p_effective_date => p_effective_start_date
                                  );

            --
            debug (l_proc_name||'Asg Id:'||to_char(nvl(l_tab_mult_asg(i).assignment_id,99999)), 60);

            l_sec_eff_start_date := greatest
                                      (p_effective_start_date
                                      ,g_ext_asg_details(l_tab_mult_asg(i).assignment_id).start_date
                                      );
            -- MULT-LR --
            -- Use the new Function to get the correct end date
            -- based on the multiple restarter events
            -- It takes care of multiple Leaver-Restarter events
            -- where as the old logic used to take into account
            -- only the first restarter event.

            -- Performance changes
            -- no need to call tihs function as we are checking assignment status in chk_effective_asg
            /*
            l_sec_eff_end_date := get_eff_end_date (
                                p_assignment_id        => l_tab_mult_asg(i).assignment_id
                               ,p_effective_start_date => p_effective_start_date
                               ,p_effective_end_date   => p_effective_end_date
                               ) ;
            */

            l_sec_eff_end_date := p_effective_end_date;

            debug('l_sec_eff_start_date: '|| to_char(l_sec_eff_start_date,'DD/MM/YYYY'),65) ;
            debug('l_sec_eff_end_date: '|| to_char(l_sec_eff_end_date,'DD/MM/YYYY')) ;

            l_return := calc_annual_sal_rate
                          (p_assignment_id        => l_tab_mult_asg(i).assignment_id
                          ,p_calculation_date     => l_sec_eff_start_date
                          ,p_safeguarded_yn       => l_safeguarded_yn
                          ,p_fte                  => 'N'
                          ,p_to_time_dim          => 'A'
                          ,p_rate                 => l_sec_ann_sal_rate
                          ,p_effective_start_date => p_effective_start_date
                          ,p_effective_end_date   => p_effective_end_date
                          );

            if l_return <> -1 then

               --
               debug (l_proc_name, 70);
               --
               -------bug 6275363 ------------------
	       --compare with the previous salary rate and set the flag to 'N'
               -- as soon as a different sal_rate is found.

	       IF l_prev_annual_sal_rate is not NULL THEN
                   IF l_sec_ann_sal_rate <> l_prev_annual_sal_rate AND l_sec_ann_sal_rate <> 0 THEN
                      l_equal_sal_rate := 'N' ;
		   ELSE
                      debug('sal_rate are equal for this iteration',71);
                   END IF;
               ELSE  -- l_prev_annual_sal_rate is Null
                     --The first valid assignment
                    debug(l_proc_name, 72);
                    l_prev_annual_sal_rate := l_sec_ann_sal_rate ;
               END IF ;
               ----------------------------------
		-- Calculate days worked
               l_days_worked := calc_days_worked
                                  (p_assignment_id        => l_tab_mult_asg(i).assignment_id
                                  ,p_effective_start_date => l_sec_eff_start_date
                                  ,p_effective_end_date   => l_sec_eff_end_date
                                  ,p_annual_sal_rate      => l_sec_ann_sal_rate
                                  );

               l_total_days_worked := l_total_days_worked + l_days_worked;

            else -- secondary asg annual sal rate is in error

              p_days      := 0;
              --
              -- hr_utility.set_location ('Leaving: '||l_proc_name, 80);
              --
              debug (l_proc_name, 80);

              debug_exit(l_proc_name);

              return -1;

            end if; -- end if of sec asg annual return check ...
          i := l_tab_mult_asg.NEXT(i);

        end loop;
        debug (l_proc_name ||'Total Secondary Asgs: '||to_char(l_tab_mult_asg.COUNT), 85);
        debug ('l_equal_sal_rate : '|| l_equal_sal_rate, 85);
     end if ; -- end if of multiple asg check ...

     --
     l_days_in_period := (trunc(p_effective_end_date) - trunc(p_effective_start_date)) + 1;

     -- Bug Fix 2411951
     -- Ceil the days worked figure...

     l_total_days_worked := ceil(l_total_days_worked);

     -- DE_CALC
     -- Days excluded should not be more than the period length
     -- due to the cieling on salary values, it may be more than the period
     -- hence LEAST
     -- l_days_excluded  := LEAST (l_days_in_period,ABS(l_days_in_period - l_total_days_worked));
     -- the logic above is incorrect.

     -- bugfix : 4926143
     -- new logic
     -- if total days worked for all assignments taken together is > days_in_period,
     -- then days_excluded is 0
     -- else days_excluded = days_in_period - total_days_worked

     IF l_days_in_period < l_total_days_worked
     THEN
       l_days_excluded := 0;
     ELSE
       l_days_excluded := l_days_in_period - l_total_days_worked;
     END IF;

     --
     --
     -- hr_utility.set_location ('Leaving: '||l_proc_name, 80);
     --
     debug_exit(l_proc_name);

     p_days := l_days_excluded;

 -- bug 6275363 --------------
     IF p_days =0 AND l_equal_sal_rate = 'N' and
       g_override_ft_asg_id IS NULL and g_part_time_asg_count > 1 then
        return -2;
     ELSE
       RETURN 0;
     END IF;
-------------------------------
  else -- primary asg annual sal is in error

    --
    -- hr_utility.set_location ('Leaving: '||l_proc_name, 80);
    --
    debug_exit(l_proc_name);

    p_days      := 0;
    return -1;

  end if; -- end if of prim asg annual return check ...

  --

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(' Others in '||l_proc_name);
       p_days := NULL;
       raise;

end get_pt_days_excluded;

--
-- ----------------------------------------------------------------------------
-- |------------------------< get_days_excluded_date >------------------------|
-- ----------------------------------------------------------------------------
function get_days_excluded_date (p_assignment_id        in     number
                                ,p_effective_start_date in     date
                                ,p_effective_end_date   in     date
                                ,p_emp_cat_cd           in     varchar2
                                ,p_days                 out nocopy number
                                )
  return number is
--
  l_proc_name          varchar2(60) := g_proc_name || 'get_days_excluded_date';
  l_return             number := 0;
  l_days_excluded      number;
  l_tab_mult_asg       t_sec_asgs_type;
  l_error_msg          varchar2(2000);
  i                    number;
  l_primary_esd        date;
  l_primary_eed        date;
  l_sec_eff_start_date date;
  l_sec_eff_end_date   date;
  l_error              NUMBER;
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- Check whether employment category is part time or full time
  -- As full time employment category may have multiple assignments
  -- so remove the check that checks for employment category
  -- rather go by multiple assignment check

--  if nvl(p_emp_cat_cd,g_ext_asg_details(p_assignment_id).ext_emp_cat_cd) = 'F' then

     --
     debug(l_proc_name, 20);
     --
--     l_days_excluded := get_ft_days_excluded
--                          (p_assignment_id        => p_assignment_id
--                          ,p_effective_start_date => p_effective_start_date
--                          ,p_effective_end_date   => p_effective_end_date
--                          );

--  elsif nvl(p_emp_cat_cd,g_ext_asg_details(p_assignment_id).ext_emp_cat_cd) = 'P' then

    --
    debug(l_proc_name, 30);
    --

    -- Bugfix 3803760:FTSUPPLY : Now using g_tab_sec_asgs instead of
    --  calling get_eff_secondary_asgs
    l_tab_mult_asg := g_tab_sec_asgs;

    if (
        l_tab_mult_asg.count > 1
       )
       OR
       ( l_tab_mult_asg.count = 1
         AND
         -- Check if hte primary asg is valid TCHR assignment
         -- on the p_effective_start_date
         -- MULT-LR --
         -- Use the new Function to check the effectivness of an assignment
         -- it takes care of multiple Leaver-Restarter events
         -- where as the old logic used to take into account
         -- only the first restarter event.
        ( chk_effective_asg (
              p_assignment_id  => p_assignment_id
             ,p_effective_date => p_effective_start_date
                             ) = 'Y'
        )
       )
    then
        debug(l_proc_name, 40);

        l_return := get_pt_days_excluded
                      (p_assignment_id        => p_assignment_id
                      ,p_effective_start_date => p_effective_start_date
                      ,p_effective_end_date   => p_effective_end_date
                      ,p_days                 => l_days_excluded
                      );

    else

       -- check whether primary assignment qualifies for report
       -- Bug Fix 3073562:GAP6


       -- Check if hte primary asg is valid TCHR assignment
       -- on the p_effective_start_date
       -- MULT-LR --
       -- Use the new Function to check the effectivness of an assignment
       -- it takes care of multiple Leaver-Restarter events
       -- where as the old logic used to take into account
       -- only the first restarter event.
       IF ( chk_effective_asg (
                p_assignment_id  => p_assignment_id
               ,p_effective_date => p_effective_start_date
                               ) = 'Y'
           )
       THEN
         debug(l_proc_name, 50);

         -- Bugfix 3641851:CBF1 : We need to calculate the days excluded
         --         from start of primary asg as its possible that
         --     primary asg bcomes a teacher after secondary
         l_primary_esd := GREATEST(p_effective_start_date
                                  ,g_ext_asg_details(p_assignment_id).start_date
                                  );
         -- MULT-LR --
         -- Use the new Function to get the correct end date
         -- based on the multiple restarter events
         -- It takes care of multiple Leaver-Restarter events
         -- where as the old logic used to take into account
         -- only the first restarter event.

         -- Performance changes
         -- no need to call tihs function as we are checking assignment status in chk_effective_asg
         /*
         l_primary_eed := get_eff_end_date (
                                p_assignment_id        => p_assignment_id
                               ,p_effective_start_date => p_effective_start_date
                               ,p_effective_end_date   => p_effective_end_date
                               ) ;
         */

         l_primary_eed := p_effective_end_date;

         debug('l_primary_eSd :'||to_char(l_primary_esd,'DD/MM/YY'));
         debug('l_primary_eEd :'||to_char(l_primary_eed,'DD/MM/YY'));

         l_days_excluded := get_ft_days_excluded
                            (p_assignment_id        => p_assignment_id
                            -- Bugfix 3641851:CBF1 : Using l_primary_esd and l_primary_eed
                            ,p_effective_start_date => l_primary_esd
                            ,p_effective_end_date   => l_primary_eed
                            );
       ELSE -- primary assignment does not qualify for report

         -- Check whether secondary assignment count is one
         IF l_tab_mult_asg.COUNT = 1 THEN

            debug(l_proc_name, 60);
            i := l_tab_mult_asg.FIRST;
            l_sec_eff_start_date := greatest
                                      (p_effective_start_date
                                      ,g_ext_asg_details(l_tab_mult_asg(i).assignment_id).start_date
                                      );

            -- MULT-LR --
            -- Use the new Function to get the correct end date
            -- based on the multiple restarter events
            -- It takes care of multiple Leaver-Restarter events
            -- where as the old logic used to take into account
            -- only the first restarter event.

            -- Performance changes
            -- no need to call tihs function as we are checking assignment status in chk_effective_asg
            /*
            l_sec_eff_end_date := get_eff_end_date (
                                      p_assignment_id        => l_tab_mult_asg(i).assignment_id
                                     ,p_effective_start_date => p_effective_start_date
                                     ,p_effective_end_date   => p_effective_end_date
                                                    ) ;
            */
            l_sec_eff_end_date := p_effective_end_date;

            debug('l_sec_eff_start_date: '|| to_char(l_sec_eff_start_date,'DD/MM/YYYY'),65) ;
            debug('l_sec_eff_end_date: '|| to_char(l_sec_eff_end_date,'DD/MM/YYYY')) ;


            l_days_excluded := get_ft_days_excluded
                               (p_assignment_id        => l_tab_mult_asg(i).assignment_id
                               ,p_effective_start_date => l_sec_eff_start_date
                               ,p_effective_end_date   => l_sec_eff_end_date
                               );
         ELSE

           debug(l_proc_name, 70);
           l_days_excluded := 0;
         END IF; -- End if of mult assignment count = 1 check ...

       END IF; -- End if of primary assignment qualifies check ...

    end if; -- end if of multiple assignment check ...

--  end if; -- end if of employment category check ...

   --
  -- hr_utility.set_location ('Leaving: '||l_proc_name, 40);
  --
 -- bug  6275363------
  IF l_return = -2 THEN
    debug(l_proc_name, 71);
    debug_exit(l_proc_name);
    RETURN -2;
  END if;
----------------------
  if l_return <> -1 then

     -- Check whether the days excluded has exceeded the allowed 3 digit limit
     debug('Days Excluded = ' ||l_days_excluded, 80);
     if l_days_excluded > 999 then
        debug(l_proc_name, 85);
        l_days_excluded := 999;

     end if; -- End if of days excluded greater than the limit check ...

     -- Cap Number of excluded days to 365, in case
     -- it is 366.
     -- Leave the value as it is if it is > 366 and
     -- Raise a warning cause it is a data issue
     -- (Warning is being raised by the FF)

     IF l_days_excluded = 366 THEN
       debug(l_proc_name, 90);
       l_days_excluded := 365 ;
     END IF ;

     p_days := l_days_excluded;
     debug_exit(l_proc_name);
     return 0;

  else
    debug(l_proc_name, 110);
    p_days := 0;
    debug_exit(l_proc_name);
    return -1;

  end if; -- end if of l_return check ...

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       debug_exit(' Others in '||l_proc_name);
       p_days := NULL;
       raise;

end get_days_excluded_date;

--
-- Check if person has multiple person records
--
FUNCTION chk_does_person_hv_multi_recs
        (p_assignment_id        IN NUMBER
        ,p_business_group_id    IN NUMBER
        ,p_effective_date       IN DATE
        ,p_present_in_masterbg  OUT NOCOPY BOOLEAN
        ,p_person_count         OUT NOCOPY NUMBER
        ) RETURN BOOLEAN
IS


  l_multiper_found      BOOLEAN := FALSE;
  l_present_in_masterbg BOOLEAN := FALSE;
  l_ext_emp_cat_cd      VARCHAR2(1);
  l_person_id           per_all_people_f.person_id%TYPE;

  l_per_details         csr_asg_details_up%ROWTYPE;
  l_multiper            c_multiper%ROWTYPE;
  l_person_count        NUMBER :=0 ;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'chk_does_person_hv_multi_recs';

  -- CROSSPER:
  -- new varaibles introduced to
  -- check for crossperson records
  -- Will set these variables accordng to the
  -- global dates set in TP1/TP2/TP4
  -- depending on the extract type
  -- and pass to c_multiper
  l_eff_start_date      DATE;
  l_eff_end_date        DATE;

BEGIN -- chk_does_person_hv_multi_recs

  debug_enter(l_proc_name);
  debug('g_master_bg_id :'||to_char(nvl(g_master_bg_id,-1)), 05);

  OPEN csr_asg_details_up(p_assignment_id => p_assignment_id
                         ,p_effective_date => p_effective_date
                         );
  FETCH csr_asg_details_up INTO l_per_details;
  l_person_id := l_per_details.person_id;

  CLOSE csr_asg_details_up;

  -- Bugfix 3073562:GAP8
  -- If we find a full-time assignment for this person
  -- then we must treat each person record seperately

  -- Bugfix 3671727:ENH2
  -- This only needs to be done for the Type 1 report
  -- For the Type 2 and 4 we still amalgamate data
  IF g_extract_type IN ('TP1P', 'TP1') THEN


    debug(l_proc_name, 10);

     -- CROSSPER: set the dates
    l_eff_start_date := p_effective_date;
    l_eff_end_date   := g_pension_year_end_date ;

    debug(' l_per_details.asg_emp_cat_cd :'|| l_per_details.asg_emp_cat_cd,11);
    debug(' p_effective_date :'|| to_char(p_effective_date),12);
    -- First chk the assignment id passed
    l_ext_emp_cat_cd := get_translate_asg_emp_cat_code
                            (l_per_details.asg_emp_cat_cd
                            ,p_effective_date
                            ,'Pension Extracts Employment Category Code'
                            ,p_business_group_id
                            );

    debug('l_ext_emp_cat_cd :'|| l_ext_emp_cat_cd,13);
    IF l_ext_emp_cat_cd = 'F' THEN
      debug(l_proc_name, 20);
      l_multiper_found := FALSE;
      l_present_in_masterbg := FALSE;

      --Check if other asgs exists for the same person.
      OPEN c_multiper
           (p_person_id            => l_person_id
           ,p_effective_start_date => l_eff_start_date
           ,p_effective_end_date   => l_eff_end_date
           ,p_assignment_id        => p_assignment_id
           ) ;
      FETCH c_multiper INTO l_multiper ;
      IF c_multiper%FOUND THEN
        l_person_count := 1 ;
      END IF;
      CLOSE c_multiper ;

    ELSE

      l_ext_emp_cat_cd := NULL;

      FOR l_multiper IN c_multiper
                         (p_person_id            => l_person_id
                         ,p_effective_start_date => l_eff_start_date
                         ,p_effective_end_date   => l_eff_end_date
                         ,p_assignment_id        => p_assignment_id
                          )
      LOOP

        debug(l_proc_name, 30);
        l_multiper_found := TRUE;
        l_person_count := l_person_count + 1;

        IF l_multiper.business_group_id = g_master_bg_id THEN
          debug(l_proc_name, 40);
          l_present_in_masterbg := TRUE;
        END IF;

        l_ext_emp_cat_cd := get_translate_asg_emp_cat_code
                              (l_multiper.asg_emp_cat_cd
                              ,p_effective_date
                              ,'Pension Extracts Employment Category Code'
                              ,p_business_group_id
                              );

        -- Bugfix 3073562:GAP8
        -- If we find a full-time assignment for this person
        -- then we must treat each person record seperately
        IF l_ext_emp_cat_cd = 'F' THEN
          debug( 'setting l_multiplier_found =false');
          l_multiper_found := FALSE;
          l_present_in_masterbg := FALSE;
          debug(l_proc_name, 50);
          EXIT;
        END IF;

      END LOOP;

    END IF; -- l_ext_emp_cat_cd = 'F' THEN

  ELSE -- g_extract_type is TP4 or TP2

    -- CROSSPER:check the extract type and set the dates
    IF (g_extract_type = 'TP2' ) THEN
      l_eff_start_date := pqp_gb_tp_type2_functions.g_effective_start_date;
      l_eff_end_date   := pqp_gb_tp_type2_functions.g_effective_end_date;
    ELSIF  (g_extract_type = 'TP4' ) THEN
      l_eff_start_date := pqp_gb_tp_pension_extracts.g_last_effective_date ;
      l_eff_end_date   := pqp_gb_tp_pension_extracts.g_effective_run_date ;
    END IF;

    FOR l_multiper IN c_multiper
                       (p_person_id            => l_person_id
                       ,p_effective_start_date => l_eff_start_date
                       ,p_effective_end_date  => l_eff_end_date
                       ,p_assignment_id        => p_assignment_id
                        )
    LOOP

      debug(l_proc_name, 60);
      l_multiper_found := TRUE;

      IF l_multiper.business_group_id = g_master_bg_id THEN
        debug(l_proc_name, 70);
        l_present_in_masterbg := TRUE;
      END IF;

      -- If both the flags are set to TRUE, no need to check further
      IF l_present_in_masterbg
         AND
         l_multiper_found THEN

        debug(l_proc_name, 80);
        EXIT;

      END IF;

    END LOOP;

  END IF; -- g_extract_type check

  debug_exit(l_proc_name);

  -- Assign value to the OUT param value
  p_present_in_masterbg := l_present_in_masterbg;
  p_person_count        := l_person_count ;

  RETURN l_multiper_found;
EXCEPTION
  WHEN OTHERS THEN
    p_present_in_masterbg := NULL;
    p_person_count        := NULL;
    debug_exit('Others in '||l_proc_name);
    RAISE;
END; -- chk_does_person_hv_multi_recs

--
-- set_multirec_person
--
FUNCTION set_multirec_person(p_business_group_id        IN NUMBER
                            ,p_person_id                IN NUMBER
                            ,p_assignment_id            IN NUMBER
                            ,p_national_identifier      IN VARCHAR2
                            ,p_effective_start_date     IN DATE
                            ,p_effective_end_date       IN DATE
                            ,p_processing_status        IN VARCHAR2
                            ,p_request_id               IN NUMBER
                            ) RETURN BOOLEAN IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR csr_multirec_person IS
  SELECT *
  FROM pqp_ext_cross_person_records emd
  WHERE emd.record_type = 'X'
    AND emd.national_identifier = p_national_identifier
    AND emd.ext_dfn_id = ben_ext_thread.g_ext_dfn_id                  --ENH3
    AND emd.lea_number = g_lea_number                                 --ENH3
  FOR UPDATE OF processing_status NOWAIT;


  l_report_person       BOOLEAN := FALSE;
  l_multirec_per        csr_multirec_person%ROWTYPE;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'set_multirec_person';

BEGIN

  debug_enter(l_proc_name);

  OPEN csr_multirec_person;
  FETCH csr_multirec_person INTO l_multirec_per;

  IF csr_multirec_person%FOUND THEN

    debug(l_proc_name, 10);

    IF nvl(l_multirec_per.processing_status,'U') = 'U' THEN
      BEGIN -- Attempt an update

        debug(l_proc_name, 20);
        UPDATE pqp_ext_cross_person_records
        SET business_group_id           = p_business_group_id
           ,person_id                   = p_person_id
           ,national_identifier         = p_national_identifier
           ,assignment_id               = p_assignment_id
           ,effective_start_date        = p_effective_start_date
           ,effective_end_date          = p_effective_end_date
           ,processing_status           = p_processing_status
           ,request_id                  = p_request_id
           ,last_updated_by             = fnd_global.user_id
           ,last_update_date            = SYSDATE
           ,last_update_login           = fnd_global.login_id
           ,object_version_number       = (l_multirec_per.object_version_number + 1)
        WHERE CURRENT OF csr_multirec_person;

        l_report_person := TRUE;

        debug(l_proc_name, 30);

      EXCEPTION
        WHEN OTHERS THEN

          debug(l_proc_name, 40);
          l_report_person := FALSE;
          -- IF the code is -54 then the row is locked and
          -- is being updated by another extract, we will not
          -- report this person in the current extract.
          -- If its anything other than 54, its a problem
          -- raise it.
          IF SQLCODE <> -54 THEN
            CLOSE csr_multirec_person;
            debug_exit(l_proc_name);
            RAISE;
          END IF;
      END; -- Attempt an update

      debug(l_proc_name, 50);
    ELSE
      debug(l_proc_name, 60);
      l_report_person := FALSE;
    END IF;

  ELSE -- Notfound, Need to insert
    debug(l_proc_name, 70);
    INSERT INTO pqp_ext_cross_person_records
    (record_type
    ,ext_dfn_id                                  --ENH3
    ,lea_number                                  --ENH3
    ,business_group_id
    ,person_id
    ,national_identifier
    ,assignment_id
    ,effective_start_date
    ,effective_end_date
    ,processing_status
    ,request_id
    ,created_by
    ,creation_date
    ,object_version_number
    )
    VALUES
    ('X'
    ,ben_ext_thread.g_ext_dfn_id                  --ENH3
    ,pqp_gb_tp_pension_extracts.g_lea_number      --ENH3
    ,p_business_group_id
    ,p_person_id
    ,p_national_identifier
    ,p_assignment_id
    ,p_effective_start_date
    ,p_effective_end_date
    ,p_processing_status
    ,p_request_id
    ,fnd_global.user_id
    ,SYSDATE
    ,1
    );

    l_report_person := TRUE;

  END IF; -- csr_multirec_person%FOUND THEN

  debug(l_proc_name, 80);

  CLOSE csr_multirec_person;

  COMMIT;

  debug_exit(l_proc_name);

  RETURN l_report_person;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- set_multirec_person

--
-- chk_report_person
--
FUNCTION chk_report_person
  (p_business_group_id        IN      NUMBER  -- context
  ,p_effective_date           IN      DATE    -- context
  ,p_assignment_id            IN      NUMBER  -- context
  ) RETURN BOOLEAN
IS

  CURSOR csr_per_details IS
  SELECT per.person_id                  person_id
        ,per.national_identifier        national_identifier
    FROM per_all_assignments_f asg
        ,per_all_people_f per
   WHERE asg.assignment_id = p_assignment_id
     AND per.person_id = asg.person_id;


  l_person_has_multiple_recs    BOOLEAN := FALSE;
  l_present_in_masterbg         BOOLEAN := FALSE;
  l_report_person               BOOLEAN := FALSE;
  l_error                       NUMBER ;
  l_multiper_dets               csr_multiproc_data%ROWTYPE;
  l_per_details                 csr_per_details%ROWTYPE;


  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_report_person';

BEGIN -- chk_report_person

  debug_enter(l_proc_name);

  -- This function does the following checks and processing
  -- 1) If the current bg is cross bg reporting enabled
  --    then we need to chk if the current BG is the Master BG
  --    a) If it is, then we report this person in this, Master, BG
  --       But before that we need to chk if this person is
  --       already being reported in the current (master) BG
  --       as it could be a cross person in same Bg scenario.
  --    b) If this is not the master bg, then we check if the
  --       person has a record in master bg
  --       b.1) If yes, then v leave the person alone as he will
  --            get processed in the extract for master bg anyway
  --       b.2) If not, then we chk if this person is being
  --            already processed in another/same extract for cross BG
  --            scenario. For this we look for a row in
  --            pqp_ext_cross_person_records for this persons NI number
  --            i) If row found with 'P', then leave this person
  --           ii) If not found or found with NULL or 'U', then we
  --               insert/update the row to tell other extracts that
  --               mite be running parallely that this person is already
  --               being processed


  debug(l_proc_name, 10);
  OPEN csr_per_details;
  FETCH csr_per_details INTO l_per_details;
  CLOSE csr_per_details;

  -- Now chk if this person has multi person recs
  g_person_count := 0;
  debug('p_assignment_id :'||to_char(p_assignment_id));
  debug('p_effective_date :'||to_char(p_effective_date));

  l_person_has_multiple_recs :=
          chk_does_person_hv_multi_recs
            (p_assignment_id        => p_assignment_id
            ,p_business_group_id    => p_business_group_id
            ,p_effective_date       => p_effective_date
            ,p_present_in_masterbg  => l_present_in_masterbg -- OUT
            ,p_person_count         => g_person_count --OUT
            );

  debug('g_person_count :'||to_char(g_person_count));

  -- Bugfix 3073562:GAP8
  -- We must not amalgamate person data from other person
  -- records within or across BGs if the person
  -- has a full-time assignment in any of the person recs
  IF l_person_has_multiple_recs THEN
    debug(l_proc_name,15);
    debug('l_person_has_multiple_recs has multiple recs ');
    g_cross_per_enabled := 'Y';
  ELSE
    debug('l_person_has_multiple_recs doesnt have multiple recs ');
    g_cross_per_enabled := 'N';
  END IF;

  -- Step 1) Is cross Bg reporting enabled
  IF g_crossbg_enabled = 'Y' THEN

    -- Step 2) Is this the master BG.
    IF g_business_group_id = g_master_bg_id THEN

      debug(l_proc_name, 20);

      -- Always report a person from master BG if
      -- there is a person record in the master BG
      l_report_person := TRUE;

      -- If person has multiple records, mark the
      -- row in multiproc_data
      IF l_person_has_multiple_recs THEN

        debug(l_proc_name, 30);

        -- Returns true on successful update or insert
        l_report_person := set_multirec_person
                             (p_business_group_id         => p_business_group_id
                             ,p_person_id                 => l_per_details.person_id
                             ,p_assignment_id             => p_assignment_id
                             ,p_national_identifier       => l_per_details.national_identifier
                             ,p_effective_start_date      => p_effective_date
                             ,p_effective_end_date        => NULL
                             ,p_processing_status         => 'P'
                             ,p_request_id                => fnd_global.conc_request_id
                             );

      END IF; -- l_person_has_multiple_recs THEN

    ELSE -- the report is not running in the master BG

      debug(l_proc_name, 40);

      -- Chk if this person has a rec in master BG.
      IF l_present_in_masterbg THEN
        -- IF Yes then do not report person in current BG
        l_report_person := FALSE;
        debug(l_proc_name, 50);
      ELSE

        -- If person has multiple records, try to mark the
        -- row in multiproc_data
        IF l_person_has_multiple_recs THEN

          -- debug('National Identifier :'||l_per_details.national_identifier, 59);
          debug(l_proc_name, 60);
          IF  csr_multiproc_data%ISOPEN THEN
            CLOSE csr_multiproc_data;
          END IF;

          -- Check if the person is already being processed
          OPEN csr_multiproc_data(p_record_type => 'X'
                                 ,p_national_identifier => l_per_details.national_identifier
                                 );
          FETCH csr_multiproc_data INTO l_multiper_dets;

          debug('Processing Status :'||l_multiper_dets.processing_status, 70);

          IF (csr_multiproc_data%NOTFOUND -- No row for this NI
              OR
              (csr_multiproc_data%FOUND -- Row found for this NI
               AND
               nvl(l_multiper_dets.processing_status,'U') = 'U' -- Unprocessed
              )
             ) THEN

            debug(l_proc_name, 80);

            -- Returns true on successful update or insert
            l_report_person:= set_multirec_person
                                (p_business_group_id       => p_business_group_id
                                ,p_person_id               => l_per_details.person_id
                                ,p_assignment_id           => p_assignment_id
                                ,p_national_identifier     => l_per_details.national_identifier
                                ,p_effective_start_date    => p_effective_date
                                ,p_effective_end_date      => NULL
                                ,p_processing_status       => 'P'
                                ,p_request_id              => fnd_global.conc_request_id
                                );

          ELSE
            -- Person is already being processed by another BG that
            -- mite be running parallely. So do not process in this report
            debug(l_proc_name, 90);
            l_report_person := FALSE;
          END IF; -- (csr_multiproc_data%NOTFOUND -- No row for this NI
          CLOSE csr_multiproc_data;

        ELSE
          debug(l_proc_name, 95);
          l_report_person := TRUE;
        END IF; -- l_person_has_multiple_recs THEN

      END IF; -- l_present_in_masterbg THEN

    END IF; -- g_business_group_id = g_master_bg_id THEN

  ELSE -- g_crossbg_enabled = 'N'

    -- If person has multiple records, mark the
    -- row in multiproc_data
    IF l_person_has_multiple_recs THEN

      debug(l_proc_name, 100);

      -- Returns true on successful update or insert
      l_report_person := set_multirec_person
                           (p_business_group_id         => p_business_group_id
                           ,p_person_id                 => l_per_details.person_id
                           ,p_assignment_id             => p_assignment_id
                           ,p_national_identifier       => l_per_details.national_identifier
                           ,p_effective_start_date      => p_effective_date
                           ,p_effective_end_date        => NULL
                           ,p_processing_status         => 'P'
                           ,p_request_id                => fnd_global.conc_request_id
                           );

    ELSE
      debug(l_proc_name, 105);
      l_report_person := TRUE;
    END IF; -- l_person_has_multiple_recs THEN

    debug(l_proc_name, 110);
  END IF; -- g_crossbg_enabled = 'Y' THEN

  debug_exit(l_proc_name);

  RETURN l_report_person;
EXCEPTION
  WHEN OTHERS THEN
    debug('SQLCODE :'||to_char(SQLCODE), 120);
    debug('SQLERRM :'||SQLERRM, 130);
    debug_exit(' Others in '||l_proc_name);
    RAISE;

END; -- chk_report_person

-- Criteria for Type 1 Periodic Leavers
--
FUNCTION chk_tp1_criteria_periodic
  (p_business_group_id        IN      NUMBER  -- context
  ,p_effective_date           IN      DATE    -- context
  ,p_assignment_id            IN      NUMBER  -- context
  ) RETURN VARCHAR2 -- Y or N
IS

  -- Variable Declaration
  l_inclusion_flag      VARCHAR2(1) := 'Y';
  l_leaver              VARCHAR2(1) := 'N';
  l_leaver_date         DATE;
  l_already_reported    VARCHAR2(1) := 'N';
  l_restarter           VARCHAR2(1) := 'N';
  l_restarter_date      DATE := NULL;
  l_look_for_sec_asgs   BOOLEAN := FALSE;
  l_asg_count           NUMBER;
  l_error               NUMBER;
  -- FOR PROFILING
  l_start_time          NUMBER;
  l_end_time            NUMBER;

  -- Rowtype Variable Declaration
  l_asg_details        csr_asg_details_up%ROWTYPE;
  l_pqp_asg_attributes csr_pqp_asg_attributes_up%ROWTYPE;
  l_temp_asg_details    csr_asg_details_up%ROWTYPE;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'chk_tp1_criteria_periodic';

BEGIN -- chk_tp1_criteria_periodic

  debug_enter(l_proc_name);

  debug('Assignment Id :'||to_char(p_assignment_id),10);

  IF g_business_group_id IS NULL THEN

    -- Bugifx 2848696 : Now using ben_ext_person.g_effective_date
    -- instead of p_effective_date
    set_t1_extract_globals
        (p_business_group_id
        ,ben_ext_person.g_effective_date   -- p_effective_date
        ,p_assignment_id
        );

    set_periodic_run_dates;

    -- Fetch element ids from balance's
    fetch_eles_for_t1_bals (p_assignment_id  => p_assignment_id
                           ,p_effective_date => g_pension_year_start_date
                           );

  END IF;

  -- Bugfix -- Bugfix 3671727: Performance enhancement
  --    If no location exists in the list of valid criteria
  --    establishments, then no point doing all checks
  --    Just warn once and skip every assignment
  IF pqp_gb_tp_pension_extracts.g_criteria_estbs.COUNT = 0 THEN

    debug('Setting inclusion flag to N as no locations EXIST.', 15);
    l_inclusion_flag := 'N';

    pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
    -- Call TP4 pkg proc to warning for no locations
    pqp_gb_tp_pension_extracts.warn_if_no_loc_exist
        (p_assignment_id => p_assignment_id) ;
    pqp_gb_tp_pension_extracts.g_nested_level := 0;

  ELSE -- Valid locations EXIST

    -- Reset the supply assignment count
    g_supply_asg_count := 0;

    -- Bugfix 3641851:ENH6 Reset the part time assignment count
    g_part_time_asg_count := 0;

    -- Resetting cross person reporting and person count
    --  Moved it here from warn_anthr_tchr_asg
    g_cross_per_enabled := 'Y' ;
    g_person_count := 0 ;

    --added for bug fix 3803760 (PRD)
    g_asg_count := 0;

    -- MULT-LR --
    -- setting it to the primary assignment id.
    -- in create_service_lines, it may get overwritten
    g_primary_assignment_id := p_assignment_id;

    -- Added for 5460058
    g_equal_sal_rate             := 'Y';

    -- PER_LVR : Person LEaver changes
    -- new date variable to keep track of the latest start date
    -- associated with a person record,
    -- after which there is no person leaver event
    -- initialize with the g_effective_run_date
    g_latest_start_date := g_effective_run_date;

    -- Check if this person should be reported by the current run
    IF chk_report_person
         (p_business_group_id     => p_business_group_id
         -- PRD : reverted the change made to date.
         ,p_effective_date        => g_pension_year_start_date
         ,p_assignment_id         => p_assignment_id
         ) THEN

      debug('g_cross_person_enabled : '|| g_cross_per_enabled);
      -- Bugfix 3073562:GAP10
      -- Reset the global which stores dates for new lines of
      -- service as there mite be some dates stored for the
      -- prev assignment processed
      g_asg_events.DELETE;

      -- 8iComp Changes
      -- MULT-LR changes.
      -- g_asg_leaver_events_table.DELETE ;

      g_per_asg_leaver_dates.DELETE;

      -- PERF_ENHANC_3A : Performance Enhancements
      -- this table of records will be used in recalc_data_elements to store
      -- details corresponding of assignment IDs. Instead of calling parttime and FT
      -- salary function multiple times, this data collection will be used
      g_asg_recalc_details.DELETE;


      -- Check if the assignment qualifies to be on the Periodic Returns
      --    Pass g_pension_year_start_date as the effective date as we are
      --    checking as of start date of pension year. Basically, we are
      --    reporting annual returns from start of pension year to
      --    the date a person becomes a leaver, if he becomes a leaver that is.

      --PROFILE changes
      IF(NVL(g_trace,'N') = 'Y') THEN
        l_start_time := dbms_utility.get_time;
      END IF ;

      l_inclusion_flag := chk_has_tchr_elected_pension
                            (p_business_group_id            => p_business_group_id
                            ,p_effective_date               => g_pension_year_start_date
                            ,p_assignment_id                => p_assignment_id
                            ,p_asg_details                  => l_asg_details        -- OUT
                            ,p_asg_attributes               => l_pqp_asg_attributes -- OUT
                            );

      --PROFILE changes
      IF (NVL(g_trace,'N') = 'Y') THEN
        l_end_time := dbms_utility.get_time;
        debug('EXECUTION_TIME: chk_has_tchr_elected_pension: '||to_char(ABS(l_end_time - l_start_time)),15) ;
      END IF ;

      IF l_inclusion_flag = 'Y' THEN

        debug('Teacher has elected pension, now doing leaver chk',20);

        -- Check for leaver events between pension year start date and effective run date
        --    Basically, we are reporting annual returns starting from the
        --    start of the pension year to the leaver date, and we want to check
        --    for people who have become leavers in the same date range.
        --    However as we donot want to report people who have already been reported,
        --    we will need to look at previous run results to exclude people who
        --    have already been reported.
        -- Dates :
        --   Start date should be pension year start date
        --   End Date should be the end date of the run date range.
        l_leaver := chk_is_teacher_a_leaver
                            (p_business_group_id            => p_business_group_id
                               -- PRD : Reverted the change made to Date
                            ,p_effective_start_date         => GREATEST(g_pension_year_start_date
                                                                       ,nvl(l_asg_details.start_date
                                                                           ,g_pension_year_start_date
                                                                           )
                                                                       )
                            ,p_effective_end_date           => g_effective_run_date + 1 -- LVRDATE
                            ,p_assignment_id                => p_assignment_id
                            ,p_leaver_date                  => l_leaver_date -- OUT
                            );


        IF l_leaver = 'Y' THEN

          -- Check if the leaver is also a re-starter,
          -- i.e. there is break in service in this pension year
          --   But, do this only if the leaver date is present and
          --   less than the g_effective_run_date
          l_asg_details.restarter_date := NULL;

          IF l_leaver = 'Y'
             AND
             l_leaver_date < g_effective_run_date THEN

            debug('Doing restarter chk',50);

            l_restarter := chk_is_leaver_a_restarter
                                (p_business_group_id        => p_business_group_id
                                ,p_effective_start_date     => (l_leaver_date + 1)
                                ,p_effective_end_date       => g_effective_run_date
                                ,p_assignment_id            => p_assignment_id
                                ,p_restarter_date           => l_restarter_date -- OUT
                                );

            IF l_restarter = 'Y' THEN

              debug('Restarter date :'||to_char(l_restarter_date,'DDMMYY'),60);

              l_asg_details.restarter_date := l_restarter_date;

            END IF; -- l_restarter = 'Y' THEN

          END IF; -- l_leaver = 'Y' AND l_leaver_date < g_effective_run_date THEN
        ELSE -- l_leaver = 'N' THEN

          debug('Not a Leaver',100);
          -- PER_LVR : Person Leaver changes
          -- keep the leaver date in the global.
          -- There is no person level leaver after this date
          -- Will use this date, when checking for person level lever event.
          g_latest_start_date := LEAST (g_latest_start_date, l_asg_details.start_date);
          -- Start of Bug fix 5408932
          -- If this is the only assignment then he should not be reported
          l_inclusion_flag := 'N';

          -- Check for Secondary assignments.
          l_look_for_sec_asgs := TRUE;

          -- Teacher is not a leaver. The primary assignment should not be reported.
          l_asg_details.report_asg := 'N';
          -- End of Bug fix 5408932

        END IF ; -- l_leaver = 'N' THEN
          --  Assignment has passed all checks save the details in
          --   1) Type 4 global collection g_ext_asg_details
          --   2) Type 1 global collection g_ext_asg_details
          --      Has more stuff than the Type 4 counterpart
          --   3) Type 1 global collection g_ext_aat_details
          --
          -- Bug 5408932
          -- Store the globals only if it is the terminated assignment
     IF l_inclusion_flag = 'Y' THEN
        -- First assign the leaver date to the asg details rowtype variable
        debug('Storing values in globals',70);
        l_asg_details.leaver_date := l_leaver_date;

        --   1) Type 4 global collection g_ext_asg_details
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).person_id         := l_asg_details.person_id;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).assignment_id     := l_asg_details.assignment_id;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).start_date        := l_asg_details.start_date;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).effective_end_date:= l_asg_details.effective_end_date;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).creation_date     := l_asg_details.creation_date;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).location_id       := l_asg_details.location_id;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).asg_emp_cat_cd    := l_asg_details.asg_emp_cat_cd;
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).ext_emp_cat_cd    := l_asg_details.ext_emp_cat_cd;

        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number       :=
            pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number;

        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).tp_safeguarded_grade :=
            l_pqp_asg_attributes.tp_safeguarded_grade;

        --   2) Type 1 global collection g_ext_asg_details
        g_ext_asg_details(p_assignment_id) := l_asg_details;

        -- 3) Type 1 global collection g_ext_aat_details
        g_ext_asg_attributes(l_pqp_asg_attributes.assignment_id) := l_pqp_asg_attributes;


        -- Bugfix 3073562:GAP9a
        -- Raise a warning if the assignment is at a
        -- supply location and full time
        warn_if_supply_tchr_is_ft
            (p_assignment_id            => p_assignment_id
            ,p_establishment_number     =>
                pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number
            ,p_ext_emp_cat_code         => l_asg_details.ext_emp_cat_cd
            );

        -- Bugfix 3073562:GAP9b
        -- Increment the supply asg count if this is a supply assignment
        IF pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number = '0966' THEN
          g_supply_asg_count := g_supply_asg_count + 1;
          debug('Incrementing supply teacher count',75);
        END IF;

        -- Bugfix 3641851:ENH6
        -- Increment the part time assignment count if the asg is part time
        IF l_asg_details.ext_emp_cat_cd = 'P' THEN
          g_part_time_asg_count := g_part_time_asg_count + 1;
          debug('Incrementing part time assignment count',76);
        END IF;

        -- Bugfix 3803760:TERMASG : Incrementing asg count (PRD)
        g_asg_count := g_asg_count + 1;

        debug('g_asg_count: '|| to_char(g_asg_count), 75) ;
        debug('Fetching secondary asgs',80);

        debug('g_cross_person_enabled : '|| (g_cross_per_enabled),57);

        -- This procedure also saves the secondary assignments in the global record varialbes
        fetch_secondary_assignments
                  (p_primary_assignment_id        => p_assignment_id
                  ,p_person_id                    => l_asg_details.person_id
                  -- PRD : reverted the change made to date
                  ,p_effective_date               => g_pension_year_start_date
                  ,p_must_be_a_leaver             => TRUE
                  );
     ELSE
        debug('Primary Asg '|| to_char(p_assignment_id)||' is not terminated', 84) ;
     END IF; -- l_inclusion_flag = 'Y' Bug 5408932
        debug('g_asg_count: '|| to_char(g_asg_count), 85) ;
        debug('Number of TP1 teachers on periodic report :'||
          fnd_number.number_to_canonical(pqp_gb_tp_pension_extracts.g_ext_asg_details.COUNT));

      ELSE
        -- Bugfix 3073562:GAP6
        -- Continue looking for secondary asgs
        l_look_for_sec_asgs := TRUE;
      END IF; -- l_inclusion_flag = 'Y' THEN

      -- Bugfix 3073562:GAP6
      -- Even though this asg is not being included, we need to
      -- look for prospective secondary leaver assignments
      IF l_inclusion_flag = 'N'
         AND l_look_for_sec_asgs THEN

        debug('Primary NOT included, checking secondary asgs',110);

        l_asg_count := g_ext_asg_details.COUNT;

        -- Get person id if its NULL
        IF l_asg_details.person_id IS NULL THEN

          debug('Person Id is NULL, get it',120);

          OPEN csr_asg_details_up(p_assignment_id);
          FETCH csr_asg_details_up INTO l_temp_asg_details;
          CLOSE csr_asg_details_up;

          l_asg_details.person_id := l_temp_asg_details.person_id;

        END IF;

        debug('g_asg_count: '|| to_char(g_asg_count), 125) ;

        fetch_secondary_assignments
                (p_primary_assignment_id        => p_assignment_id
                ,p_person_id                    => l_asg_details.person_id
                -- PRD : reverted the change made to date.
                ,p_effective_date               => g_pension_year_start_date
                ,p_must_be_a_leaver             => TRUE
                );

        debug('g_asg_count: '|| to_char(g_asg_count), 128) ;
        -- If proc fetch_secondary_assignments added any new asgs to
        -- global collection, resulting in higher count, then it means
        -- we have secondary asgs for this person.
        IF g_ext_asg_details.COUNT > l_asg_count THEN

          debug('Secondary asg Teacher, report this person',130);
          l_inclusion_flag := 'Y';

        END IF;

      END IF; -- l_inclusion_flag = 'N' AND l_look_for_sec_asgs THEN

    ELSE -- chk_report_person
      debug(l_proc_name,140);
      l_inclusion_flag := 'N';
    END IF; -- chk_report_person

    debug('Inclusion Flag :'||l_inclusion_flag,150);

    IF l_inclusion_flag = 'Y' THEN

      -- PER_LVR change
      -- This piece of code checks for the person level leaver events

      debug('g_latest_start_date : '||to_char(g_latest_start_date),160 );
      debug('teacher_start_date: '|| to_char(g_ext_asg_details(p_assignment_id).teacher_start_date));

      -- 1. check if there is any one continuous assignment over the period Then person is not a leaver.
  --   IF  g_latest_start_date = g_ext_asg_details(p_assignment_id).teacher_start_date THEN -- bug Fix 9383926
      IF  g_latest_start_date <> g_effective_run_date THEN
        debug('There is atleast one continuous asg over the period...',170);
        l_inclusion_flag := 'N';
      ELSE
        -- check for Person level Leaver events.
        l_inclusion_flag := chk_person_leaver
                                ( p_assignment_id => p_assignment_id
                                 ,p_person_id     => l_asg_details.person_id
                                 );

        -- 2. store_leaver_restarter_dates
        -- 3. sort_stored_events
        -- 4. browse events and store person level rehire dates as per g_asg_count status
        --    a). if leaver date found then chk if person has to be reported for this date
        --    b). if yes continue
        --    c). if no, stop, this needs to be reported.
        debug('l_inclusion_flag: '||l_inclusion_flag,180);
      END IF;
        debug('l_inclusion_flag: '||l_inclusion_flag,190);

    END IF; --l_inclusion_flag = 'Y'

    IF l_inclusion_flag = 'Y' THEN

      debug(l_proc_name, 210 );
      -- Now we know that this person wll be reported
      -- Raise all the errors and warnings

      -- Bugfix 3073562:GAP9b
      -- If this person has more than one supply assignments
      -- then raise a warning.
      IF g_supply_asg_count > 1 THEN
        l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                   (p_assignment_id => p_assignment_id
                   ,p_error_text    => 'BEN_93656_SUPPLY_TCHR_MULTIASG'
                   ,p_error_number  => 93656
                   );
      END IF;

      -- The following piece of code raises a warning if
      -- there exist more than one lea with the same lea Number within a BG.
      -- the warning is raised for the first valid assignment for a single Run.
      -- the flag for warning is set during the global setting through set_extract_globals.
      pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
      pqp_gb_tp_pension_extracts.warn_if_multi_lea_exist (p_assignment_id => p_assignment_id);
      pqp_gb_tp_pension_extracts.g_nested_level := 0;

      -- The following proc raises a warning, if there is
      -- one FT teaching asg for the person
      -- and there are multiple person records.
      -- the proc checks for the flags g_cross_person_enabled and g_person_count
      -- and resets those flags.
      warn_anthr_tchr_asg(p_assignment_id => p_assignment_id);

      -- Bugfix 3803760:FTSUPPLY (PRD)
      -- Set the effective assignments as of teacher start date
      debug('g_asg_count: '|| to_char(g_asg_count), 255) ;
      set_effective_assignments
         (p_primary_assignment_id     => p_assignment_id
         ,p_effective_date            => g_ext_asg_details(p_assignment_id).teacher_start_date
         );
    debug('g_asg_count: '|| to_char(g_asg_count), 258) ;
    END IF ; -- l_inclusion_flag = 'Y'

  END IF; -- pqp_gb_tp_pension_extracts.g_criteria_estbs.COUNT = 0

  debug('l_inclusion_flag: '||l_inclusion_flag,260);
  debug_exit(l_proc_name);

  RETURN l_inclusion_flag;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name
              ,'Y' -- turn trace off
              );
    RAISE;
END; -- chk_tp1_criteria_periodic


--
-- Criteria for Type 1 Annual with facility to Include/Exclude Leavers
--
FUNCTION chk_tp1_criteria_annual
  (p_business_group_id        IN      NUMBER  -- context
  ,p_effective_date           IN      DATE    -- context
  ,p_assignment_id            IN      NUMBER  -- context
  ) RETURN VARCHAR2 -- Y or N
IS

  -- Variable Declaration
  l_inclusion_flag      VARCHAR2(1) := 'Y';
  l_leaver              VARCHAR2(1) := 'N';
  l_leaver_date         DATE;
  l_already_reported    VARCHAR2(1) := 'N';
  l_restarter           VARCHAR2(1) := 'N';
  l_restarter_date      DATE := NULL;
  l_person_id           per_all_people_f.person_id%TYPE;
  l_asg_count           NUMBER;
  l_error               NUMBER;

  -- Rowtype Variable Declaration
  l_asg_details        csr_asg_details_up%ROWTYPE;
  l_per_details        csr_asg_details_up%ROWTYPE;
  l_pqp_asg_attributes csr_pqp_asg_attributes_up%ROWTYPE;
  l_temp_asg_details    csr_asg_details_up%ROWTYPE;



  l_proc_name          VARCHAR2(61):=
     g_proc_name||'chk_tp1_criteria_annual';

BEGIN -- chk_tp1_criteria_annual

  debug_enter(l_proc_name);

  debug('Assignment Id :'||to_char(p_assignment_id),10);
  debug('Effective_date :'||to_char(p_effective_date,'dd/mm/yyyy'),15);

  IF g_business_group_id IS NULL THEN

    -- Bugifx 2848696 : Now using ben_ext_person.g_effective_date
    -- instead of p_effective_date
    set_t1_extract_globals
        (p_business_group_id
        ,ben_ext_person.g_effective_date   -- p_effective_date
        ,p_assignment_id
        );


    -- Bugifx 2848696 : Now using ben_ext_person.g_effective_date
    -- instead of p_effective_date
    pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
    g_reporting_mode := upper(pqp_gb_tp_pension_extracts.get_extract_udt_info
                                ('Attribute Location Qualifier 1' -- column
                                ,'Criteria'      -- row
                                ,ben_ext_person.g_effective_date   -- p_effective_date
                                )
                             );
    pqp_gb_tp_pension_extracts.g_nested_level := 0;

    set_annual_run_dates;

    -- Fetch element ids from balance's
    fetch_eles_for_t1_bals (p_assignment_id  => p_assignment_id
                           ,p_effective_date => g_pension_year_start_date
                           );

  END IF;

  -- Bugfix -- Bugfix 3671727: Performance enhancement
  --    If no location exists in the list of valid criteria
  --    establishments, then no point doing all checks
  --    Just warn once and skip every assignment
  IF pqp_gb_tp_pension_extracts.g_criteria_estbs.COUNT = 0 THEN

    debug('Setting inclusion flag to N as no locations EXIST.', 15);
    l_inclusion_flag := 'N';

    pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
    -- Call TP4 pkg proc to warning for no locations
    pqp_gb_tp_pension_extracts.warn_if_no_loc_exist
        (p_assignment_id => p_assignment_id) ;
    pqp_gb_tp_pension_extracts.g_nested_level := 0;

  ELSE -- Valid locations EXIST

    debug('Reporting Mode for leavers is :'||g_reporting_mode,20);

    -- Reset the supply assignment count
    g_supply_asg_count := 0;

    -- Bugfix 3641851:ENH6 Reset the part time assignment count
    g_part_time_asg_count := 0;

    -- Resetting cross person reporting and person count
    --  Moved it here from warn_anthr_tchr_asg
    g_cross_per_enabled := 'Y' ;
    g_person_count := 0 ;

    -- Added for bugfix 3803760:TERMASG
    g_asg_count := 0;

    g_teach_asg_count :=0;

    -- MULT-LR --
    -- setting it to the primary assignment id.
    -- in create_service_lines, it may get overwritten
    g_primary_assignment_id := p_assignment_id;

      -- Added for 5460058
    g_equal_sal_rate             := 'Y';

    g_supp_teacher := 'N';

    -- Check if this person should be reported by the current run
    IF chk_report_person
         (p_business_group_id     => p_business_group_id
         ,p_effective_date        => g_pension_year_start_date
         ,p_assignment_id         => p_assignment_id
         ) THEN

      debug('g_cross_person_enabled : '|| g_cross_per_enabled);
      -- Reset the global which stores dates for new lines of
      -- service as there mite be some dates stored for the
      -- prev assignment processed
      g_asg_events.DELETE;


      -- PERF_ENHANC_3A : Performance Enhancements
      -- this table of records will be used in recalc_data_elements to store
      -- details corresponding of assignment IDs. Instead of calling parttime and FT
      -- salary function multiple times, this data collection will be used
      g_asg_recalc_details.DELETE;


      -- 8iComp Changes
      -- MULT-LR changes.
      -- g_asg_leaver_events_table.DELETE ;

      g_per_asg_leaver_dates.DELETE;

      -- Check if the assignment qualifies to be on the Periodic Returns
      --    Pass g_pension_year_start_date as the effective date as we are
      --    checking as of start date of pension year. Basically, we are
      --    reporting annual returns from start of pension year to
      --    the date a person becomes a leaver, if he becomes a leaver that is.
      l_inclusion_flag := chk_has_tchr_elected_pension
                            (p_business_group_id            => p_business_group_id
                            ,p_effective_date               => g_pension_year_start_date
                            ,p_assignment_id                => p_assignment_id
                            ,p_asg_details                  => l_asg_details        -- OUT
                            ,p_asg_attributes               => l_pqp_asg_attributes -- OUT
                            );

      IF l_inclusion_flag = 'Y' THEN
      -- 1)

        debug('Teacher has elected pension',30);

        -- Check for leaver events between pension year start date and effective run date
        -- For annual report effective run date should be pension year end date
        --    Basically, we are reporting annual returns starting from the
        --    start of the pension year to the end of pension year, and we want
        --    to check for people who have become leavers in the same date range.
        -- Dates :
        --   Start date should be pension year start date
        --   End Date should be the end date of the run date range, i.e. end of pension year
        l_leaver := chk_is_teacher_a_leaver
                            (p_business_group_id            => p_business_group_id
                            ,p_effective_start_date         => GREATEST(g_pension_year_start_date
                                                                       ,nvl(l_asg_details.start_date
                                                                           ,g_pension_year_start_date
                                                                           )
                                                                       )
                            ,p_effective_end_date           => nvl(g_effective_run_date
                                                                  ,g_pension_year_end_date)
                            ,p_assignment_id                => p_assignment_id
                            ,p_leaver_date                  => l_leaver_date -- OUT
                            );


   /*     IF nvl(g_reporting_mode,'EXCLUDE') = 'EXCLUDE'
           AND
           l_leaver = 'Y' THEN

          -- Set the inclusion flag to 'N'o as this person is a leaver
          -- and we are running in EXCLUDE leavers reporting mode
          l_inclusion_flag := 'N';

        END IF; -- nvl(g_reporting_mode,'EXCLUDE') = 'EXCLUDE' THEN  */-- commenting this chk, since it is chking primary assinments 1st leaver event
	                                                             --   with out considering 2ndary asgs leaver events

        IF l_inclusion_flag = 'Y' THEN
        -- 2)

          -- Assignment has passed all checks save the details in
          --   1) Type 4 global collection g_ext_asg_details
          --   2) Type 1 global collection g_ext_asg_details
          --        Has more stuff than the Type 4 counterpart
          --   3) Type 1 global collection g_ext_aat_details
          --

          -- Check if the leaver is also a re-starter,
          -- i.e. there is break in service in this pension year
          --   But, do this only if the leaver date is present and
          --   less than the g_effective_run_date
          l_asg_details.restarter_date := NULL;

          IF l_leaver = 'Y'
             AND
             l_leaver_date < g_effective_run_date THEN

            l_restarter := chk_is_leaver_a_restarter
                                (p_business_group_id        => p_business_group_id
                                ,p_effective_start_date     => (l_leaver_date + 1)
                                ,p_effective_end_date       => g_effective_run_date
                                ,p_assignment_id            => p_assignment_id
                                ,p_restarter_date           => l_restarter_date -- OUT
                                );

            IF l_restarter = 'Y' THEN

              debug('Restarter',40);
              l_asg_details.restarter_date := l_restarter_date;

            END IF; -- l_restarter = 'Y' THEN

          END IF; -- l_leaver = 'Y' AND l_leaver_date < g_effective_run_date THEN


          /* Replacing this with assignment statements for individual elements as
             there is a plan to extent the assignment cursor to include more cols.

          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id) := l_asg_details;

          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number :=
            pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number;

          -- already populated this in l_asg_details before received in this function
          -- pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).start_date := l_pension_start_date;

          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).tp_safeguarded_grade :=
            l_pqp_asg_attributes.tp_safeguarded_grade;
          */

          -- First assign the leaver date to the asg details rowtype variable
          IF l_leaver = 'Y' THEN
            l_asg_details.leaver_date := l_leaver_date;
          ELSE -- l_leaver = 'N'
            l_asg_details.leaver_date := NULL;
          END IF; -- l_leaver = 'Y' THEN

          debug('Storing values in globals',50);

          --   1) Type 4 global collection g_ext_asg_details

          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).person_id           := l_asg_details.person_id;
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).assignment_id       := l_asg_details.assignment_id;
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).start_date          := l_asg_details.start_date;
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).effective_end_date  := l_asg_details.effective_end_date;
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).creation_date       := l_asg_details.creation_date;
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).location_id         := l_asg_details.location_id;
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).asg_emp_cat_cd      := l_asg_details.asg_emp_cat_cd;
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).ext_emp_cat_cd      := l_asg_details.ext_emp_cat_cd;

          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number          :=
            pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number;

          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).tp_safeguarded_grade :=
            l_pqp_asg_attributes.tp_safeguarded_grade;

          --   2) Type 1 global collection g_ext_asg_details
	  g_teach_asg_count :=g_teach_asg_count +1;
          g_ext_asg_details(p_assignment_id) := l_asg_details;

          -- 3) Type 1 global collection g_ext_aat_details
          g_ext_asg_attributes(l_pqp_asg_attributes.assignment_id) := l_pqp_asg_attributes;

          -- Bugfix 3073562:GAP9a
          -- Raise a warning if the assignment is at a
          -- supply location and full time
          warn_if_supply_tchr_is_ft
            (p_assignment_id            => p_assignment_id
            ,p_establishment_number     =>
                pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number
            ,p_ext_emp_cat_code         => l_asg_details.ext_emp_cat_cd
            );

          -- Bugfix 3073562:GAP9b
          -- Increment the supply asg count if this is a supply assignment
          IF pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number = '0966' THEN
            g_supply_asg_count := g_supply_asg_count + 1;
            debug('Incrementing supply teacher count',55);
          END IF;

          -- Bugfix 3641851:ENH6
          -- Increment the part time assignment count if the asg is part time
          IF l_asg_details.ext_emp_cat_cd = 'P' THEN
            g_part_time_asg_count := g_part_time_asg_count + 1;
            debug('Incrementing part time assignment count',56);
          END IF;

          -- Bugfix 3803760:TERMASG : Incrementing asg count
          g_asg_count := g_asg_count + 1;

          debug('g_asg_count: '|| to_char(g_asg_count), 55) ;

          debug('Fetching secondary asgs',60);
          -- This procedure also saves the secondary assignments in the global record varialbes
          fetch_secondary_assignments
                    (p_primary_assignment_id        => p_assignment_id
                    ,p_person_id                    => l_asg_details.person_id
                    ,p_effective_date               => g_pension_year_start_date
                    ,p_must_be_a_leaver             => FALSE
                    );
          debug('g_asg_count: '|| to_char(g_asg_count), 65) ;
          debug('Number of TP1 teachers on annual report :'||
          fnd_number.number_to_canonical(pqp_gb_tp_pension_extracts.g_ext_asg_details.COUNT),70);
          --
        END IF; -- 2) l_inclusion_flag = 'Y' THEN
        --
      ELSE -- 1) inclusion flag is 'N'

        -- Bugfix 3073562:GAP6
        -- Primary asg not to be included
        -- but check for any secondary teaching asgs

        debug('Primary NOT teacher, checking secondary asgs',80);

        l_asg_count := g_ext_asg_details.COUNT;

        -- Get person id if its NULL
        IF l_asg_details.person_id IS NULL THEN

          debug('Person Id is NULL, get it',90);

          OPEN csr_asg_details_up(p_assignment_id);
          FETCH csr_asg_details_up INTO l_temp_asg_details;
          CLOSE csr_asg_details_up;

          l_asg_details.person_id := l_temp_asg_details.person_id;

        END IF;

        debug('g_asg_count: '|| to_char(g_asg_count), 95) ;
        fetch_secondary_assignments
                (p_primary_assignment_id        => p_assignment_id
                ,p_person_id                    => l_asg_details.person_id
                ,p_effective_date               => g_pension_year_start_date
                ,p_must_be_a_leaver             => FALSE
                );
        debug('g_asg_count: '|| to_char(g_asg_count), 95) ;
        -- If proc fetch_secondary_assignments added any new asgs to
        -- global collection, resulting in higher count, then it means
        -- we have secondary asgs for this person.
        IF g_ext_asg_details.COUNT > l_asg_count THEN

          debug('Secondary asg Teacher, report this person',100);
          l_inclusion_flag := 'Y';

        END IF;
        --
      END IF; -- 1) l_inclusion_flag = 'Y' THEN

    ELSE -- chk_report_person
      debug(l_proc_name,110);
      l_inclusion_flag := 'N';
    END IF; -- chk_report_person

   debug('l_inclusion_flag : '|| l_inclusion_flag ,111);

   IF nvl(g_reporting_mode,'EXCLUDE') = 'EXCLUDE'  and l_inclusion_flag = 'Y' then
   -- if criteria is 'Exclude' then we have to chk persons all asgs leaver events
   debug('Criteria is Exclude, need to check person is leaver or not.' ,112);
   l_inclusion_flag := chk_person_leaver
                                ( p_assignment_id => p_assignment_id
                                 ,p_person_id     => l_asg_details.person_id
                                 );
    End if;


    -- Bugfix 3073562:GAP9b
    -- If this person has more than one supply assignments
    -- then raise a warning.
    IF g_supply_asg_count > 1 THEN
      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                   (p_assignment_id => p_assignment_id
                   ,p_error_text    => 'BEN_93656_SUPPLY_TCHR_MULTIASG'
                   ,p_error_number  => 93656
                   );
    END IF;

    debug('Inclusion Flag :'||l_inclusion_flag,120);

    IF l_inclusion_flag = 'Y' THEN
      -- The following piece of code raises a warning if
      -- there exist more than one lea with the same lea Number within a BG.
      -- the warning is raised for the first valid assignment for a single Run.
      -- the flag for warning is set during the global setting through set_extract_globals.
      pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
      pqp_gb_tp_pension_extracts.warn_if_multi_lea_exist (p_assignment_id => p_assignment_id);
      pqp_gb_tp_pension_extracts.g_nested_level := 0;

      -- The following proc raises a warning, if there is
      -- one FT teaching asg for the person
      -- and there are multiple person records.
      -- the proc checks for the flags g_cross_person_enabled and g_person_count
      -- and resets those flags.
      warn_anthr_tchr_asg(p_assignment_id => p_assignment_id);

      -- Bugfix 3803760:FTSUPPLY
      -- Set the effective assignments as of teacher start date
      debug('g_asg_count: '|| to_char(g_asg_count), 130) ;

      set_effective_assignments
         (p_primary_assignment_id     => p_assignment_id
         ,p_effective_date            => g_ext_asg_details(p_assignment_id).teacher_start_date
         );
      debug('g_asg_count: '|| to_char(g_asg_count), 140) ;


    END IF;

  END IF; -- pqp_gb_tp_pension_extracts.g_criteria_estbs.COUNT = 0

  debug_exit(l_proc_name);

  RETURN l_inclusion_flag;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name
              ,'Y' -- turn trace off
              );
    RAISE;
END; -- chk_tp1_criteria_annual
--
-- chk_report_assignment - overloaded
--
FUNCTION chk_report_assignment
    (p_assignment_id            IN  NUMBER
    -- Bugfix 3641851:CBF1 : Added new parameter effective date
    ,p_effective_date           IN  DATE
    ,p_secondary_assignment_id  OUT NOCOPY NUMBER
    ) RETURN VARCHAR2
IS

 l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
 l_retval              VARCHAR2(1) := 'Y';
 l_effective_date      DATE;

 l_proc_name           varchar2(60) := g_proc_name || 'chk_report_assignment1';

BEGIN -- chk_report_assignment

  debug_enter(l_proc_name);

  debug('p_assignment_id :'||to_char(p_assignment_id), 10);

  -- Bugfix 3803760:FTSUPPLY :  Added the override logic
  IF g_override_ft_asg_id IS NULL THEN

    IF (g_ext_asg_details.EXISTS(p_assignment_id)
        AND
       g_ext_asg_details(p_assignment_id).report_asg = 'Y'
       ) THEN

      debug(l_proc_name, 20);
      -- Bugfix 3641851:CBF1: Added date check
      --  When primary asg starts at a later date than secondary asg,
      --  the func that evaluates an attribute from primary asg records
      --  can fail (and raise warning) coz there mite be no row present
      --  for the primary asg. However, the primary is to be reported
      --  frm a later date so we cannot ignore it altogether.
      --  Therefore, we need to use the secondary asgs row for getting
      --  attributes if the primary is not valid at the given eff date.
      --
      l_effective_date := nvl(p_effective_date, g_ext_asg_details(p_assignment_id).teacher_start_date);
      debug('l_effective_date :'||to_char(l_effective_date, 'DD/MM/YYYY'), 30);

      -- MULT-LR --
      -- Use the new Function to check the effectivness of an assignment
      -- it takes care of multiple Leaver-Restarter events
      -- where as the old logic used to take into account
      -- only the first restarter event.
      IF ( chk_effective_asg (
               p_assignment_id  => p_assignment_id
              ,p_effective_date => l_effective_date
                              ) ='Y'
          ) THEN

        debug(l_proc_name, 40);
        l_assignment_id := p_assignment_id;

      ELSE
        l_assignment_id := g_ext_asg_details(p_assignment_id).secondary_assignment_id;
      END IF;

      l_retval := 'Y';

    ELSE
      debug(l_proc_name, 50);
      l_assignment_id := g_ext_asg_details(p_assignment_id).secondary_assignment_id;
      l_retval := 'N';
    END IF;

  ELSE -- g_override_ft_asg_id is NOT NULL

    l_assignment_id := g_override_ft_asg_id;

    IF g_override_ft_asg_id = p_assignment_id THEN
      l_retval := 'Y';
    ELSE
      l_retval := 'N';
    END IF;

  END IF;

  p_secondary_assignment_id := l_assignment_id;

  debug('p_secondary_assignment_id :'||to_char(p_secondary_assignment_id), 60);
  debug_exit(l_proc_name);

  RETURN l_retval;

EXCEPTION
  WHEN OTHERS THEN
    p_secondary_assignment_id := NULL;
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- chk_report_assignment

--
-- chk_report_assignment - overloaded
--
FUNCTION chk_report_assignment
    (p_assignment_id            IN  NUMBER
    -- Bugfix 3641851:CBF1 : Added new parameter effective date
    ,p_effective_date           IN  DATE
    ,p_report_assignment        OUT NOCOPY VARCHAR2
    ) RETURN NUMBER
IS

 l_assignment_id        per_all_assignments_f.assignment_id%TYPE;
 l_retval               VARCHAR2(1) := 'Y';
 l_effective_date       DATE;

 l_proc_name           varchar2(60) := g_proc_name || 'chk_report_assignment2';

BEGIN -- chk_report_assignment

  debug_enter(l_proc_name);
  debug('p_assignment_id :'||to_char(p_assignment_id), 10);

  -- Bugfix 3803760:FTSUPPLY :  Added the override logic
  IF g_override_ft_asg_id IS NULL THEN

    IF (g_ext_asg_details.EXISTS(p_assignment_id)
        AND
       g_ext_asg_details(p_assignment_id).report_asg = 'Y'
       ) THEN

      debug(l_proc_name, 20);
      -- Bugfix 3641851:CBF1: Added date check
      --  When primary asg starts at a later date than secondary asg,
      --  the func that evaluates an attribute from primary asg records
      --  can fail (and raise warning) coz there mite be no row present
      --  for the primary asg. However, the primary is to be reported
      --  frm a later date so we cannot ignore it altogether.
      --  Therefore, we need to use the secondary asgs row for getting
      --  attributes if the primary is not valid at the given eff date.
      --
      l_effective_date := nvl(p_effective_date, g_ext_asg_details(p_assignment_id).teacher_start_date);
      debug('l_effective_date :'||to_char(l_effective_date, 'DD/MM/YYYY'), 30);

      -- MULT-LR --
      -- Use the new Function to check the effectivness of an assignment
      -- it takes care of multiple Leaver-Restarter events
      -- where as the old logic used to take into account
      -- only the first restarter event.
      IF ( chk_effective_asg (
               p_assignment_id  => p_assignment_id
              ,p_effective_date => l_effective_date
                              ) ='Y'
          ) THEN

        debug(l_proc_name, 40);
        l_assignment_id := p_assignment_id;

      ELSE
        l_assignment_id := g_ext_asg_details(p_assignment_id).secondary_assignment_id;
      END IF;

      l_retval := 'Y';

    ELSE
      debug(l_proc_name, 50);
      l_assignment_id := g_ext_asg_details(p_assignment_id).secondary_assignment_id;
      l_retval := 'N';
    END IF;

  ELSE -- g_override_ft_asg_id is NOT NULL

    l_assignment_id := g_override_ft_asg_id;

    IF g_override_ft_asg_id = p_assignment_id THEN
      l_retval := 'Y';
    ELSE
      l_retval := 'N';
    END IF;

  END IF;

  p_report_assignment := l_retval;

  debug('p_report_assignment :'||p_report_assignment, 60);
  debug('l_assignment_id :'||to_char(l_assignment_id), 70);

  debug_exit(l_proc_name);

  RETURN l_assignment_id;

EXCEPTION
  WHEN OTHERS THEN
    p_report_assignment := NULL;
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- chk_report_assignment

--
-- Start Date
--
FUNCTION get_tp1_start_date
  (p_assignment_id     IN      NUMBER
  )
  RETURN VARCHAR2
IS
  l_start_date  VARCHAR2(600);
BEGIN

  -- Bugfix 3641851:CBF1: Now returning teacher_start_date
  l_start_date := to_char(nvl(g_ext_asg_details(p_assignment_id).teacher_start_date
                             ,g_ext_asg_details(p_assignment_id).start_date)
                         ,'DDMMYY'
                         );

  RETURN l_start_date;
END; -- get_tp1_start_date
--
-- End Date
--
FUNCTION get_tp1_end_date
  (p_assignment_id     IN      NUMBER
  ) RETURN VARCHAR2
IS

BEGIN

  RETURN to_char(LEAST(nvl(g_ext_asg_details(p_assignment_id).leaver_date
                          ,g_effective_run_date
                          )
                      ,g_effective_run_date
                      )
                ,'DDMMYY'
                );
END; -- get_tp1_end_date
--
-- Withdrawal Confirmation
--
FUNCTION get_tp1_withdrawal_conf
  (p_assignment_id     IN      NUMBER
  ) RETURN VARCHAR2
IS

  l_withdrawal_conf ben_ext_rslt_dtl.val_15%TYPE := ' ';
  l_proc_name  varchar2(60) := g_proc_name || 'get_tp1_withdrawal_conf';

BEGIN

  debug_enter(l_proc_name);
  debug('g_asg_count :'||to_char(g_asg_count), 10);

  IF g_ext_asg_details(p_assignment_id).leaver_date IS NOT NULL
     AND
     (LEAST(g_ext_asg_details(p_assignment_id).leaver_date
           ,g_effective_run_date
           )
        =
        g_ext_asg_details(p_assignment_id).leaver_date
     ) THEN

    l_withdrawal_conf := 'W';

  END IF;

  debug_exit(l_proc_name);
  RETURN l_withdrawal_conf;

END; -- get_tp1_withdrawal_conf

-- ----------------------------------------------------------------------------
-- |------------------------< get_tp1_days_excluded >-------------------------|
-- ----------------------------------------------------------------------------
function get_tp1_days_excluded (p_assignment_id in     number
                               ,p_days_excluded out    nocopy varchar2
                               )
  return number is
--
  l_proc_name            varchar2(60) := g_proc_name || 'get_tp1_days_excluded';
  l_days_excluded        number;
  l_return               number;
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- Bugfix 3803760:FTSUPPLY
  -- Changed start_date to teacher_start_date
  l_return := get_days_excluded_date
                (p_assignment_id        => p_assignment_id
                ,p_effective_start_date => greatest
                                             (g_pension_year_start_date
                                             ,g_ext_asg_details(p_assignment_id).teacher_start_date
                                             )
                ,p_effective_end_date   => least
                                             (g_effective_run_date
                                             ,nvl(g_ext_asg_details(p_assignment_id).leaver_date,
                                                    g_effective_run_date)
                                             )
                ,p_days                 => l_days_excluded
                );

  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 20);
  --
-- bug 6275363---------
  IF l_return = -2 then
   p_days_excluded := '+00';
   debug_exit(l_proc_name);
   RETURN 0;
  END if;
-------------------------
  debug_exit(l_proc_name);

  if l_return <> -1 then

     p_days_excluded := trim(to_char(l_days_excluded,'099'));
     return 0;

  else

    p_days_excluded := '000';
    return -1;

  end if; -- end of of return check ...

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name
              ,'Y' -- turn trace off
              );
    p_days_excluded := NULL;
    RAISE;
end get_tp1_days_excluded;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_tp1_annual_ft_sal_rate >--------------------|
-- ----------------------------------------------------------------------------
function get_tp1_annual_ft_sal_rate (p_assignment_id in     number
                                    ,p_annual_rate   out    nocopy varchar2
                                    )
  return number is
--
  l_proc_name            varchar2(60) := g_proc_name || 'get_tp1_annual_ft_sal_rate';
  l_return               number;
  l_annual_rate          number;
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  -- Bugfix 3803760:FTSUPPLY
  -- Changed start_date to teacher_start_date
  l_return := get_annual_sal_rate_date
                (p_assignment_id        => p_assignment_id
                ,p_effective_start_date => greatest
                                             (g_pension_year_start_date
                                             ,g_ext_asg_details(p_assignment_id).teacher_start_date
                                             )
                ,p_effective_end_date   => least
                                             (g_effective_run_date
                                             ,nvl(g_ext_asg_details(p_assignment_id).leaver_date,
                                                    g_effective_run_date)
                                             )
                ,p_rate                 => l_annual_rate
                );

  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 20);
  --
  debug_exit(l_proc_name);

  if l_return <> -1 then

     g_annual_rate(p_assignment_id) := l_annual_rate;
     p_annual_rate                  := trim(to_char(l_annual_rate,'099999'));
     return 0;

  else

    p_annual_rate := '000000';
    return -1;

  end if; -- end if of l_return check ...

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name
              ,'Y' -- turn trace off
              );
    p_annual_rate := NULL;
    RAISE;
end get_tp1_annual_ft_sal_rate;

--
-- ----------------------------------------------------------------------------
-- |------------------------< get_tp1_pt_sal_paid >---------------------------|
-- ----------------------------------------------------------------------------
function get_tp1_pt_sal_paid (p_assignment_id in     number
                             ,p_part_time_sal out    nocopy varchar2
                             )
  return number is
--
  l_proc_name            varchar2(60) := g_proc_name || 'get_tp1_pt_sal_paid';
  l_part_time_sal        number;
  l_return               number;
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);
  debug('p_assignment_id '||p_assignment_id,10) ;

  -- Get part time salary paid only if the employment category is part-time

  if g_ext_asg_details(p_assignment_id).ext_emp_cat_cd = 'P' then

    debug(l_proc_name,20);

    -- Bugfix 3803760:FTSUPPLY
    -- Changed start_date to teacher_start_date
    l_part_time_sal := get_part_time_sal_date
                         (p_assignment_id        => p_assignment_id
                         ,p_effective_start_date => greatest
                                                      (g_pension_year_start_date
                                                      ,g_ext_asg_details(p_assignment_id).teacher_start_date
                                                      )
                         ,p_effective_end_date   => least
                                                      (g_effective_run_date
                                                      ,nvl(g_ext_asg_details(p_assignment_id).leaver_date,
                                                             g_effective_run_date)
                                                      )
                         );
    debug ('l_part_time_sal '||to_char(l_part_time_sal),30);

    -- Check whether part time sal exceeds annual salary rate

    if g_annual_rate.exists(p_assignment_id) and
       g_annual_rate(p_assignment_id) < l_part_time_sal
    then

       -- Fill in with zeros instead of space
       -- Bug fix 2353106
       debug ('g_annual_rate(p_assignment_id) '||to_char(g_annual_rate(p_assignment_id)),40);

       debug_exit(l_proc_name);

          IF sign(l_part_time_sal) = -1 THEN
             p_part_time_sal := '-'|| lpad(abs(l_part_time_sal),5,'0');
          ELSE
             p_part_time_sal := lpad(l_part_time_sal,6,'0');
          END IF;

     --  p_part_time_sal := lpad(l_part_time_sal,6,'0');
       return -1;

    else

       -- Fill in with zeros instead of space
       -- Bug fix 2353106
       debug_exit(l_proc_name);

	  IF sign(l_part_time_sal) = -1 THEN   -- added for bug 7313510
             p_part_time_sal := '-'|| lpad(abs(l_part_time_sal),5,'0');
          ELSE
             p_part_time_sal := lpad(l_part_time_sal,6,'0');
          END IF;

      -- p_part_time_sal := lpad(l_part_time_sal,6,'0');
       return 0;

    end if; -- end if of annual rate check ...

  else -- emp cat cd is not part time

       -- Fill in with zeros instead of space
       -- Bug fix 2353106
    debug(l_proc_name, 50) ;
    p_part_time_sal := '000000';

    debug_exit(l_proc_name);
    return 0;

  end if; -- end if of emp cat check ...

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name
              ,'Y' -- turn trace off
              );
    p_part_time_sal := NULL;
    RAISE;
END get_tp1_pt_sal_paid;

--
-- Career Indicator
--
  FUNCTION get_tp1_career_indicator
    (p_assignment_id     IN      NUMBER
    ) RETURN VARCHAR2
  IS
    l_return_value  char(7);
    l_proc_name          VARCHAR2(61):=
       g_proc_name||'get_tp1_career_indicator';
    l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
    l_report_asg          VARCHAR2(1);

  BEGIN -- get_tp1_career_indicator

      debug_enter(l_proc_name);

      -- Check if primary assignment is a teaching assignment
      l_assignment_id := chk_report_assignment
                           (p_assignment_id     => p_assignment_id
                           ,p_report_assignment => l_report_asg
                           );

      l_return_value := Get_Grade_Fasttrack_Info
                        (p_assignment_id  => l_assignment_id
                        ,p_effective_date => GREATEST(g_pension_year_start_date
                                                     ,g_ext_asg_details(l_assignment_id).start_date
                                                     )
                        );

      debug_exit(l_proc_name);
      RETURN l_return_value;

  EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
      RAISE;
  END; -- get_tp1_career_indicator
--
-- London Allowance
--
  FUNCTION get_tp1_london_allowance
    (p_assignment_id     IN      NUMBER
    ) RETURN VARCHAR2
  IS
    l_return_value char(7);
    l_proc_name          VARCHAR2(61):=
       g_proc_name||'get_tp1_london_allowance';
    l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
    l_report_asg          VARCHAR2(1);

  BEGIN -- get_tp1_london_allowance

      debug_enter(l_proc_name);

      -- Check if primary assignment is a teaching assignment
      l_assignment_id := chk_report_assignment
                           (p_assignment_id     => p_assignment_id
                           ,p_report_assignment => l_report_asg
                           );
-- changed for 5743209
/*
      l_return_value := Get_Allowance_Code
                        (p_assignment_id  => l_assignment_id
                        ,p_effective_date => GREATEST(g_pension_year_start_date
                                                     ,g_ext_asg_details(l_assignment_id).start_date
                                                     )
                        ,p_allowance_type => 'LONDON_ALLOWANCE_RULE'
                        );
*/
      l_return_value := Get_Allowance_Code_New
                        (p_assignment_id  => l_assignment_id
                        ,p_effective_date => GREATEST(g_pension_year_start_date
                                                     ,g_ext_asg_details(l_assignment_id).start_date
                                                     )
                        ,p_allowance_type => 'LONDON_ALLOWANCE_RULE'
                        );

      debug_exit(l_proc_name);
      RETURN l_return_value;

  EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
      RAISE;
  END; -- get_tp1_london_allowance

--
-- Special Priority Allowance
--
  FUNCTION get_tp1_sp_allowance
    (p_assignment_id     IN      NUMBER
    ) RETURN VARCHAR2
  IS
    l_return_value char(7);
    l_proc_name          VARCHAR2(61):=
       g_proc_name||'get_tp1_sp_allowance';
    l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
    l_report_asg          VARCHAR2(1);

  BEGIN -- get_tp1_sp_allowance

      debug_enter(l_proc_name);

      -- Check if primary assignment is a teaching assignment
      l_assignment_id := chk_report_assignment
                           (p_assignment_id     => p_assignment_id
                           ,p_report_assignment => l_report_asg
                           );
-- changed for 5743209
/*
      l_return_value := Get_Allowance_Code
                        (p_assignment_id  => l_assignment_id
                        ,p_effective_date => GREATEST(g_pension_year_start_date
                                                     ,g_ext_asg_details(l_assignment_id).start_date
                                                     )
                        ,p_allowance_type => 'SPECIAL_ALLOWANCE_RULE'
                        );
*/
 l_return_value := Get_Allowance_Code_New
                        (p_assignment_id  => l_assignment_id
                        ,p_effective_date => GREATEST(g_pension_year_start_date
                                                     ,g_ext_asg_details(l_assignment_id).start_date
                                                     )
                        ,p_allowance_type => 'SPECIAL_ALLOWANCE_RULE'
                        );

      debug_exit(l_proc_name);
      RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
      RAISE;
  END; -- get_tp1_sp_allowance

--
-- Special Class Addition (Part-time indicator)
--
  FUNCTION get_tp1_pt_contract_indicator
    (p_assignment_id     IN      NUMBER
    ) RETURN VARCHAR2
  IS
    l_return_value char(7);
    l_proc_name          VARCHAR2(61):=
       g_proc_name||'get_tp1_pt_contract_indicator';
    l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
    l_report_asg          VARCHAR2(1);

  BEGIN -- get_tp1_pt_contract_indicator

      debug_enter(l_proc_name);

      -- Check if primary assignment is a teaching assignment
      l_assignment_id := chk_report_assignment
                           (p_assignment_id     => p_assignment_id
                           ,p_report_assignment => l_report_asg
                           );

      l_return_value := Get_Special_ClassRule
                        ( p_assignment_id  => l_assignment_id
                        ,p_effective_date => GREATEST(g_pension_year_start_date
                                                     ,g_ext_asg_details(l_assignment_id).start_date
                                                     )
                        );

      debug_exit(l_proc_name);
      RETURN l_return_value;
  EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
      RAISE;
  END; -- get_tp1_pt_contract_indicator

--
-- ----------------------------------------------------------------------------
-- |------------------------< get_tp1_other_allowances >----------------------|
-- ----------------------------------------------------------------------------
function get_tp1_other_allowances (p_assignment_id in    number)
  return varchar2 is
--
  l_proc_name       varchar2(61) := g_proc_name || 'get_tp1_other_allowances';

  -- Fill in with zeros instead of space
  -- Bug fix 2353106

  l_other_allowance varchar2(5) := '00000';
  l_error           number;
--
begin
  --
  -- hr_utility.set_location('Entering: '||l_proc_name, 10);
  --
  debug_enter(l_proc_name);

  if g_other_allowance.exists(p_assignment_id) then

     -- 4336613 : SAL_VALIDAT_3A : Check whether Other_All value has exceeeded 4 digit limit
     -- If yes, raise warning.
     debug('Other Allowance : '||to_char(g_other_allowance(p_assignment_id)),15);

     if g_other_allowance(p_assignment_id) > 99999 then

        l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                     (p_assignment_id => p_assignment_id
                     ,p_error_text    => 'BEN_93043_EXT_TP1_OTH_VAL_EXC'
                     ,p_error_number  => 93043
                     ,p_token1        => TO_CHAR(g_other_allowance(p_assignment_id)) -- bug : 4336613
                     );

        g_other_allowance(p_assignment_id) := 99999;  -- 4336613 : SAL_VALIDAT_3A :
                                                     -- set to 9999 if > 9999

     end if; -- end if of other allowance max limit check ...

     -- Fill in with zeros instead of space
     -- Bug fix 2353106

     debug('Other Allowance : '||to_char(g_other_allowance(p_assignment_id)),20);

     l_other_allowance := lpad(g_other_allowance(p_assignment_id),5,'0');

  end if; -- end if of other allowance exists check...


  --
  -- hr_utility.set_location('Leaving: '||l_proc_name, 20);
  --
  debug_exit(l_proc_name);

  return l_other_allowance;
EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
      RAISE;
end get_tp1_other_allowances;

--
-- Record Serial Number
--
FUNCTION get_tp1_record_serial_number
  (p_assignment_id     IN      NUMBER
  ) RETURN VARCHAR2
IS

BEGIN

    RETURN '1';
END; -- get_tp1_record_serial_number

--
-- store_emp_cat_changes - finds and stores events due to emp cat change
--
PROCEDURE store_emp_cat_changes(p_assignment_id         IN NUMBER
                               ,p_start_date            IN DATE
                               ,p_end_date              IN DATE
                               )
IS

  -- Variable Declaration
  l_no_of_events        NUMBER(5);
  l_itr                 NUMBER(5);
  l_new_event_itr       NUMBER(5);

  l_event_group         pay_event_groups.event_group_name%TYPE := 'PQP_GB_TP_ASG_EMP_CAT';

  -- Rowtype Variable Declaration
  l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
  l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;

  l_asg_details         csr_asg_details_dn%ROWTYPE;
  l_prev_asg_details    csr_asg_details_dn%ROWTYPE;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'store_emp_cat_changes';

  i                    NUMBER;

BEGIN

  debug_enter(l_proc_name);

  -- a) Get events for Employment Category changes
  l_no_of_events := get_events(p_event_group            => l_event_group
                              ,p_assignment_id          => p_assignment_id
                              ,p_start_date             => p_start_date
                              ,p_end_date               => p_end_date
                              ,t_proration_dates        => l_proration_dates
                              ,t_proration_changes      => l_proration_changes
                              );

  debug('Number of '||l_event_group||' Events: '||
     fnd_number.number_to_canonical(l_no_of_events), 10);

  -- b) Loop through the events and check if any have changed.
  l_itr := l_proration_dates.FIRST;
  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through change proration dates

    debug('Date :'||to_char(l_proration_dates(l_itr),'DD/MM/YYYY'), 20);
    debug('Change :'||l_proration_changes(l_itr), 30);
    IF l_itr = l_proration_dates.FIRST
       OR
       ( l_proration_dates(l_itr) <>
         l_proration_dates(l_proration_dates.PRIOR(l_itr))
       ) THEN

      OPEN csr_asg_details_dn
                  (p_assignment_id
                  ,l_proration_dates(l_itr)
                  );
      FETCH csr_asg_details_dn INTO l_asg_details;


      IF csr_asg_details_dn%FOUND THEN

        debug(l_proc_name, 40);
        -- Bugfix 3073562:GAP1:GAP2
        -- Replacing the type4 func call with the type 1 function
        l_asg_details.ext_emp_cat_cd :=
                get_translate_asg_emp_cat_code
                        (l_asg_details.asg_emp_cat_cd
                        ,l_asg_details.start_date
                        ,'Pension Extracts Employment Category Code'
                        ,l_asg_details.business_group_id
                        );

        -- Get the previous assignment record
        FETCH csr_asg_details_dn INTO l_prev_asg_details;
        -- Bugfix 3073562:GAP1:GAP2
        -- Replacing the type4 func call with the type 1 function
        l_prev_asg_details.ext_emp_cat_cd :=
                get_translate_asg_emp_cat_code
                        (l_prev_asg_details.asg_emp_cat_cd
                        ,l_prev_asg_details.start_date
                        ,'Pension Extracts Employment Category Code'
                        ,l_prev_asg_details.business_group_id
                        );

        debug('Event worth considering', 50);

        --  Check if the employment category change is a valid one to create a new line.
        IF l_asg_details.ext_emp_cat_cd <> l_prev_asg_details.ext_emp_cat_cd THEN

          -- c) Found a change, log in global events collection
          l_new_event_itr := g_asg_events.COUNT+1;

          g_asg_events(l_new_event_itr).event_date      := l_proration_dates(l_itr);
          g_asg_events(l_new_event_itr).event_type      := l_event_group;
          g_asg_events(l_new_event_itr).assignment_id   := p_assignment_id;

          -- Store the new emp cat value
          g_asg_events(l_new_event_itr).new_ext_emp_cat_cd := l_asg_details.ext_emp_cat_cd;

          -- Bugfix 3734942
          --  If the assignment has become part time then
          --   we need to increment the g_part_time_asg_count
          --   when this event is processed. If asg has bcom
          --   full time then we decrement
          IF l_asg_details.ext_emp_cat_cd = 'P' THEN
            debug('PT asg count needs incrementing when event is processed', 55);
            g_asg_events(l_new_event_itr).pt_asg_count_change := 1;
          ELSE
            g_asg_events(l_new_event_itr).pt_asg_count_change := -1;
          END IF;
          -- Also store the new location id coz we need it
          --  in new LOS code to get the new estb number
          --  if change in emp cat has resulted in the
          --  pt asg count going below 2
          g_asg_events(l_new_event_itr).new_location_id := l_asg_details.location_id;

          debug('Assignment has a had an employment category change', 60);

        END IF; -- Check if the locaiton change is a valid one to report as leaver
        --
      END IF; -- csr_asg_details_dn%FOUND THEN
      --
      IF csr_asg_details_dn%ISOPEN THEN
        CLOSE csr_asg_details_dn;
      END IF;
      --
    END IF; -- if this date <> last date to eliminate duplicates
          --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through change proration dates

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- store_emp_cat_changes

--
-- store_event_grp_changes - finds and stores events due to changes
-- to any given entity identified through the event group name
--
PROCEDURE store_event_grp_changes
                        (p_assignment_id        IN NUMBER
                        ,p_event_group          IN pay_event_groups.event_group_name%TYPE
                        ,p_start_date           IN DATE
                        ,p_end_date             IN DATE
                        )
IS

  -- Variable Declaration
  l_no_of_events        NUMBER(5);
  l_itr                 NUMBER(5);
  l_new_event_itr       NUMBER(5);

  -- Rowtype Variable Declaration
  l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
  l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'store_event_grp_changes';

BEGIN

  debug_enter(l_proc_name);

  -- a) Get events for changes for given event group
  l_no_of_events := get_events(p_event_group            => p_event_group
                              ,p_assignment_id          => p_assignment_id
                              ,p_start_date             => p_start_date
                              ,p_end_date               => p_end_date
                              ,t_proration_dates        => l_proration_dates
                              ,t_proration_changes      => l_proration_changes
                              );

  debug('Number of '||p_event_group||' Events: '||
     fnd_number.number_to_canonical(l_no_of_events), 10);

  -- b) Loop through the events and check if any have changed.
  l_itr := l_proration_dates.FIRST;
  WHILE l_itr <= l_proration_dates.LAST
  LOOP -- through change proration dates

    debug('Date :'||to_char(l_proration_dates(l_itr),'DD/MM/YYYY'), 20);
    debug('Change :'||l_proration_changes(l_itr), 30);

    IF l_itr = l_proration_dates.FIRST
       OR
       ( l_proration_dates(l_itr) <>
         l_proration_dates(l_proration_dates.PRIOR(l_itr))
       ) THEN

        -- c) Found a change, log in global events collection
        l_new_event_itr := g_asg_events.COUNT+1;

        g_asg_events(l_new_event_itr).event_date        := l_proration_dates(l_itr);
        g_asg_events(l_new_event_itr).event_type        := p_event_group;
        g_asg_events(l_new_event_itr).assignment_id     := p_assignment_id;

        debug('Assignment attributes have had changes',110);

    END IF; -- if this date <> last date to eliminate duplicates
          --
    l_itr := l_proration_dates.NEXT(l_itr);
    --
  END LOOP; -- through change proration dates

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- store_event_grp_changes

--
-- store_element_changes
--   finds and stores events due to change to a pensionable element
--
-- WARNING : This procedure marks and unmarks the events in PPE for itself.
--           Please donot mark events before calling this proc.
--
PROCEDURE store_element_changes(p_assignment_id IN NUMBER
                               ,p_start_date    IN DATE
                               ,p_end_date      IN DATE
                               )
IS

  -- TYPE declaration
  TYPE t_rate_types IS TABLE of fnd_lookups.meaning%TYPE
  INDEX BY BINARY_INTEGER;

  -- Variable Declaration
  l_no_of_events        NUMBER(5);
  l_itr                 NUMBER(5);
  l_rates_itr           NUMBER(5);
  l_new_event_itr       NUMBER(5);

  l_event_group         pay_event_groups.event_group_name%TYPE;

  -- Rowtype Variable Declaration
  l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
  l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;

  l_rate_types          t_rate_types;
  l_element_set         csr_element_set%ROWTYPE;
  l_element_entries     csr_element_entries%ROWTYPE;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'store_element_changes';

BEGIN

  debug_enter(l_proc_name);

  -- Populate the collection for rate types
  l_rate_types(l_rate_types.COUNT+1) := g_sal_rate_type;
  -- Bug fix 2786740
  -- London Rate type and Other rate type need not have
  -- a value always
  IF g_lon_rate_type IS NOT NULL THEN
     l_rate_types(l_rate_types.COUNT+1) := g_lon_rate_type;
  END IF; -- End if of g_lon_rate_type is not null check ...

  IF g_oth_rate_type IS NOT NULL THEN
     l_rate_types(l_rate_types.COUNT+1) := g_oth_rate_type;
  END IF; -- End if of g_oth_rate_type is not null check ...

  FOR l_rates_itr IN l_rate_types.FIRST..l_rate_types.LAST
  LOOP -- through the rate types
    --
    debug('Rate Type :'||l_rate_types(l_rates_itr), 10);

    FOR l_element_set IN csr_element_set
                                (c_name => l_rate_types(l_rates_itr)
                                ,c_eff_date => g_ext_asg_details(p_assignment_id).start_date
                                )
    LOOP -- Through the elements in this rate type
      --
      debug(l_proc_name, 20);
      FOR l_element_entries IN csr_element_entries(p_assignment_id      => p_assignment_id
                                                  ,p_effective_date
                                                     => g_ext_asg_details(p_assignment_id).start_date
                                                  ,p_element_type_id    => l_element_set.element_type_id
                                                  )
      LOOP -- Through element entries for this element type

        -- Find Element Entry Changes
        l_event_group := 'PQP_GB_TP_ELEMENT_ENTRY';
        -- a) Get events for Element Entry changes
        -- Bug 3015917 : Removed set_pay_process.. and modified get_events which uses
        --               the new style DTI
        l_no_of_events := get_events(p_event_group              => l_event_group
                                    ,p_assignment_id            => p_assignment_id
                                    ,p_element_entry_id         => l_element_entries.element_entry_id
                                    ,p_start_date               => p_start_date
                                    ,p_end_date                 => p_end_date
                                    ,t_proration_dates          => l_proration_dates
                                    ,t_proration_changes        => l_proration_changes
                                    );

        debug('Number of '||l_event_group||' Events for Element Entry Id'||
                l_element_entries.element_entry_id||' : '||
                fnd_number.number_to_canonical(l_no_of_events), 30);

        -- b) Loop through the events and check if any have changed.
        l_itr := l_proration_dates.FIRST;
        WHILE l_itr <= l_proration_dates.LAST
        LOOP -- through change proration dates

          debug('Date :'||to_char(l_proration_dates(l_itr),'DD/MM/YYYY'), 40);
          debug('Change :'||l_proration_changes(l_itr), 50);

          IF l_itr = l_proration_dates.FIRST
             OR
             ( l_proration_dates(l_itr) <>
               l_proration_dates(l_proration_dates.PRIOR(l_itr))
             ) THEN

            -- c) Found a change, log in global events collection

            -- Bugfix 2882220 : Added the following if logic
            -- Only log this event if
            --   1) Its not an End Date Event
            --   2) Its an End DAte event but not on the g_pension_year_end_date
            IF l_proration_changes(l_itr) <> 'E' THEN

              l_new_event_itr := g_asg_events.COUNT+1;

              g_asg_events(l_new_event_itr).event_date    := l_proration_dates(l_itr);
              g_asg_events(l_new_event_itr).event_type    := l_event_group;
              g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

              debug('Event Date :'||to_char(l_proration_dates(l_itr), 'DD/MM/YYYY'), 50);
              debug('Change :'||l_proration_changes(l_itr), 60);
              debug('Element Entry change has happened, UPDATE',70);

            ELSIF l_proration_changes(l_itr) = 'E' -- End Dated Element Entry
                  AND
                  trunc(l_proration_dates(l_itr)) < trunc(g_pension_year_end_date) THEN

              l_new_event_itr := g_asg_events.COUNT+1;

              g_asg_events(l_new_event_itr).event_date    := l_proration_dates(l_itr) + 1;
              g_asg_events(l_new_event_itr).event_type    := l_event_group;
              g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

              debug('Element Entry change has happened, END DATE', 80);

            END IF; -- l_proration_changes(l_itr) <> 'E' THEN
            --
          END IF; -- if this date <> last date to eliminate duplicates
          --
          l_itr := l_proration_dates.NEXT(l_itr);
          --
        END LOOP; -- through change proration dates
        --

        l_proration_dates.DELETE;
        l_proration_changes.DELETE;

        -- Find Entry Value Changes for this element entry
        l_event_group := 'PQP_GB_TP_ENTRY_VALUE';
        -- a) Get events for Entry Value changes
        l_no_of_events := get_events(p_event_group              => l_event_group
                                    ,p_assignment_id            => p_assignment_id
                                    ,p_element_entry_id         => l_element_entries.element_entry_id
                                    ,p_start_date               => p_start_date
                                    ,p_end_date                 => p_end_date
                                    ,t_proration_dates          => l_proration_dates
                                    ,t_proration_changes        => l_proration_changes
                                    );

        debug('Number of '||l_event_group||' Events : '||
                fnd_number.number_to_canonical(l_no_of_events), 90);

        -- b) Loop through the events and check if any have changed.
        l_itr := l_proration_dates.FIRST;
        WHILE l_itr <= l_proration_dates.LAST
        LOOP -- through change proration dates

          debug('Date :'||to_char(l_proration_dates(l_itr),'DD/MM/YYYY'), 100);
          debug('Change :'||l_proration_changes(l_itr), 110);

          IF l_itr = l_proration_dates.FIRST
             OR
             ( l_proration_dates(l_itr) <>
               l_proration_dates(l_proration_dates.PRIOR(l_itr))
             ) THEN

            -- c) Found a change, log in global events collection
            l_new_event_itr := g_asg_events.COUNT+1;

            g_asg_events(l_new_event_itr).event_date    := l_proration_dates(l_itr);
            g_asg_events(l_new_event_itr).event_type    := l_event_group;
            g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

            debug('Element Entry change has happened', 120);

          END IF; -- if this date <> last date to eliminate duplicates
                --
          l_itr := l_proration_dates.NEXT(l_itr);
          --
        END LOOP; -- through change proration dates
        --

        -- UnMark Pay process events for this element entry
        -- Bug 3015917 : Removed set_pay_process.. as we now use the new style DTI

      END LOOP; -- Through element entries for this element type
      --
    END LOOP; -- Through the elements in this rate type
    --
  END LOOP; -- through the rate types

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- store_element_changes

-- Added by sshetty
PROCEDURE set_pay_process_events(p_grade_id      IN  NUMBER
                                 ,p_status       IN  VARCHAR2
                                 ,p_start_date   IN  DATE
                                 ,p_end_date     IN  DATE
                                 )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_proc_name VARCHAR2(61):= 'set_pay_process_events_to_process';

BEGIN

  debug_enter(l_proc_name);

UPDATE pay_process_events ppe
     SET ppe.retroactive_status = p_status
        ,ppe.status             = p_status
   WHERE ppe.assignment_id IS NULL
     AND ppe.change_type = 'REPORTS'
     AND ppe.effective_date -- allow all events effective as of and effective p_start_date
             BETWEEN p_start_date AND p_end_date
     AND ppe.surrogate_key = p_grade_id
     AND EXISTS (SELECT 1
                   FROM pay_dated_tables pdt
                       ,pay_event_updates peu
                  WHERE pdt.table_name = 'PAY_GRADE_RULES_F'
                    AND peu.dated_table_id = pdt.dated_table_id
                    AND peu.change_type = ppe.change_type
                    AND peu.event_update_id = ppe.event_update_id
                )
  ;

 COMMIT;

 debug_exit(l_proc_name);

END set_pay_process_events;
/**********************************************
--get_grade_sp_type
*******************************************/

FUNCTION get_grade_sp_type (p_tab_ele_ids IN t_ele_ids_from_bal)
RETURN VARCHAR2
IS

  l_index               pay_element_types_f.element_type_id%TYPE;
  l_grd_type            pay_grade_rules_f.rate_type%TYPE:='N';
  l_proc_name           varchar2(61) := g_proc_name || 'get_grade_sp_type';

CURSOR csr_chk_pay_src(p_ele_id NUMBER) IS
SELECT  petf.element_type_id
       ,petf.eei_information2 pay_source_value
  FROM pay_element_type_extra_info petf
 WHERE petf.element_type_id =p_ele_id
   AND petf.eei_information_category  ='PQP_UK_ELEMENT_ATTRIBUTION';

l_chk_pay_src csr_chk_pay_src%ROWTYPE;
BEGIN

   debug_enter(l_proc_name);

   FOR i IN 1..p_tab_ele_ids.COUNT
    LOOP

     debug(l_proc_name, 10);
     IF i=1 THEN
      l_index:=p_tab_ele_ids.FIRST;
     ELSE
       l_index:=p_tab_ele_ids.NEXT(l_index);

     END IF;
     OPEN  csr_chk_pay_src(p_tab_ele_ids(l_index).element_type_id);
     LOOP
     debug(l_proc_name, 20);
     FETCH csr_chk_pay_src INTO l_chk_pay_src;
     EXIT WHEN csr_chk_pay_src%NOTFOUND;
      IF l_chk_pay_src.pay_source_value='SP'
         OR l_chk_pay_src.pay_source_value='G' THEN
          debug(l_proc_name, 30);
          IF l_grd_type='N' THEN
           l_grd_type:=l_chk_pay_src.pay_source_value;
          ELSIF l_grd_type<>l_chk_pay_src.pay_source_value
            AND l_grd_type<>'N' THEN
           l_grd_type:='GSP';
          END IF;
      END IF;
     END LOOP;
     CLOSE csr_chk_pay_src;


    END LOOP;

  debug('l_grd_type :'||l_grd_type, 40);
  debug_exit(l_proc_name);

  RETURN(l_grd_type);
EXCEPTION
--------
WHEN OTHERS THEN
debug_exit(' Others in '||l_proc_name);
RETURN ('N');

END get_grade_sp_type;

/*****************************************
--store_grade_sp_changes
*****************************************/
-- Removed this procedure as it is no longer used.

--
-- get_asg_events - gets all qualifying events for the given assignment
--
PROCEDURE get_asg_events(p_assignment_id        IN NUMBER
                        ,p_start_date           IN DATE
                        ,p_end_date             IN DATE
                        )
IS

  -- Variable Declaration
  l_new_event_itr       NUMBER(5);

  -- Rowtype Variable Declaration

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_asg_events';

BEGIN

  debug_enter(l_proc_name);
  debug('Start Date :'||to_char(p_start_date,'DD/MM/YYYY'), 10);
  debug('End Date :'||to_char(p_end_date,'DD/MM/YYYY'), 20);

  -- Update the events in pay_process_events to 'P' for "in process".
  -- Marking all events between
  --  Start     : Later or (Pension year start date +1) and pension start date of the person
  --  End       : pension year end date.
  --              Might need to change this to use earlier of pension year end date
  --              and leaver date.
  -- Bug 3015917 : Removed set_pay_proc_events_to_process as we now use the
  --               new style DTI call

  -- 1) Check for Employment Category change
  --    FS : A change from full to part-time service (and vice versa)
  store_emp_cat_changes(p_assignment_id         => p_assignment_id
                       ,p_start_date            => p_start_date
                       ,p_end_date              => p_end_date
                       );

  -- 2) Check for safeguarded salary change
  --    FS : The comencement or cessation of a safeguarded salary
  store_event_grp_changes(p_assignment_id       => p_assignment_id
                   ,p_event_group       => 'PQP_GB_TP_SAFEGUARDED_SALARY'
                   ,p_start_date            => p_start_date
                   ,p_end_date              => p_end_date
                   );

  -- 3) Check for elected pension flag change
  --    FS : A change in the teacher's pensionable employment position
  --      This should find events only if the elected pension flag change
  --      is not a leaver event, coz if the elected pension flag
  --      change is a leaver event, then it should have been picked
  --      up by the chk_is_teacher_leaver function when called
  --      from the criteria function.
  store_event_grp_changes(p_assignment_id       => p_assignment_id
                   ,p_event_group       => 'PQP_GB_TP_ELECTED_PENSION'
                   ,p_start_date            => p_start_date
                   ,p_end_date              => p_end_date
                   );

  --
  -- 4) Check for fast track flag change
  --    FS : A change in the teacher's fast track flag
  store_event_grp_changes(p_assignment_id       => p_assignment_id
                   ,p_event_group       => 'PQP_GB_TP_FAST_TRACK'
                   ,p_start_date            => p_start_date
                   ,p_end_date              => p_end_date
                   );

  --
  -- 5) Check for grade change on assignment
  --    FS : A change in salary scale
  store_event_grp_changes(p_assignment_id       => p_assignment_id
                   ,p_event_group       => 'PQP_GB_TP_ASG_GRADE'
                   ,p_start_date            => p_start_date
                   ,p_end_date              => p_end_date
                   );

  --
  -- 6) Check for (grade step)/(spinal point placement) change on assignment
  --    FS : A change in salary scale
  store_event_grp_changes(p_assignment_id       => p_assignment_id
                   ,p_event_group       => 'PQP_GB_TP_GRADE_STEP'
                   ,p_start_date            => p_start_date
                   ,p_end_date              => p_end_date
                   );


  -- Reset the events in pay_process_events to 'U' for "Unprocessed".
  -- Bug 3015917 : Removed set_pay_proc_events_to_process as we now use the
  --               new style DTI call

  -- 7) Check for Element entry and entry value changes
  --    FS :
  -- Checking this after unmarking events for this assignment as
  -- this proc marks(and resets) events on the basis of element_entry_id
  -- for pensionable rate types.
  -- Warning : Please DONOT mark events to 'P' in pay process events
  -- b4 calling this proc.
  store_element_changes(p_assignment_id         => p_assignment_id
                       ,p_start_date            => p_start_date
                       ,p_end_date              => p_end_date
                       );

  -- 8) Check for changes to value of a grade rate or spinal point
  --    FS :
  -- Checking this after unmarking events for this assignment as
  -- this proc marks(and resets) events
  -- Warning : Please DONOT mark events to 'P' in pay process events
  -- b4 calling this proc.
  -- Added by sshetty
  -- Bug 3015917 : Replaced old call to store_grade_sp_changes
  -- with this new call. The grade rule validations are now
  -- done using func chk_grd_change_affects_asg which is called
  -- from event qualifier : GB Grade Rule Change
  store_event_grp_changes(p_assignment_id   => p_assignment_id
                   ,p_event_group           => 'PQP_GB_TP_GRADE_RULES'
                   ,p_start_date            => p_start_date
                   ,p_end_date              => p_end_date
                   );


/*
   START : Commenting out nocopy code for 2340488

   IMP : Commenting out nocopy Step 9 as part of bugfix for 2340488 as
         this is now being done for primary and secondary. And we are now
         looking for multiple leaver and restarter dates

  -- 9) Check for leaver date of the secondary assignment and store the date + 1 as
  --    an event to create new line of service if the secondary assignment is a leaver.
  IF p_assignment_id <> g_primary_assignment_id THEN
    --
    IF g_ext_asg_details(p_assignment_id).leaver_date IS NOT NULL
       AND
       -- (Leaver date + 1 ) of secondary asg is before that of the primary asg
       ((g_ext_asg_details(p_assignment_id).leaver_date + 1)
        <  -- Less Than
        nvl(g_ext_asg_details(g_primary_assignment_id).leaver_date
           ,g_effective_run_date
           )
       )
       THEN

      -- Secondary asg is a leaver, store this as an event
      l_new_event_itr := g_asg_events.COUNT+1;

      g_asg_events(l_new_event_itr).event_date    := g_ext_asg_details(p_assignment_id).leaver_date + 1;
      g_asg_events(l_new_event_itr).event_type    := 'SECONDARY_LEAVER';
      g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

    END IF; -- g_ext_asg_details(p_assignment_id).leaver_date IS NOT NULL THEN
    --

    -- Check if the secondary leaver bcame a restarter
    --   But only store if the restarter date is between his leaver date
    --   and least of (primary asg's leaver date and g_effective_run_date)
    --   the "least date bit" has been taken care of when finding the events
    --   so the date comparison sh almost always succeed.
    IF g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL
       AND
       (g_ext_asg_details(p_assignment_id).restarter_date
        < -- Less Than
        nvl(g_ext_asg_details(g_primary_assignment_id).leaver_date
           ,g_effective_run_date
           )
       ) THEN

      -- Store an event for new line of service as the secondary event has now become a restarter
      l_new_event_itr := g_asg_events.COUNT+1;

      g_asg_events(l_new_event_itr).event_date    := g_ext_asg_details(p_assignment_id).restarter_date;
      g_asg_events(l_new_event_itr).event_type    := 'SECONDARY_RESTARTER';
      g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;


    END IF; -- g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL
    --
  END IF; -- p_assignment_id <> g_primary_assignment_id THEN

END : Commenting out nocopy code for 2340488
*/

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- get_asg_events

--
-- sort_stored_events - sorts the stored events in g_asg_events by date in ascending order
--
PROCEDURE sort_stored_events
IS

  l_saved_asg_event  stored_events_type;
  l_asg_events       t_asg_events_type;

  TYPE t_skip_indexes_type IS TABLE OF BOOLEAN
    INDEX BY BINARY_INTEGER;

  l_indexes_to_skip  t_skip_indexes_type;

  l_current          NUMBER;
  l_g_current        NUMBER:= 1;
  l_next             NUMBER;
  l_proc_name        VARCHAR2(61) := g_proc_name || 'sort_stored_events';

BEGIN
-- bubble sort

  debug_enter(l_proc_name);

  l_asg_events := g_asg_events;

  g_asg_events.DELETE;

  l_current := l_asg_events.FIRST;
  WHILE l_current < l_asg_events.LAST
  LOOP

    IF NOT l_indexes_to_skip.EXISTS(l_current) THEN

      l_next := l_asg_events.NEXT(l_current);

      WHILE l_next <= l_asg_events.LAST
      LOOP

        IF NOT l_indexes_to_skip.EXISTS(l_next) THEN

          IF TRUNC(l_asg_events(l_next).event_date) < --next less than current
             TRUNC(l_asg_events(l_current).event_date)
          THEN
          -- swap
             -- save next
             l_saved_asg_event := l_asg_events(l_next);
             -- overwrite next with current
             l_asg_events(l_next) := l_asg_events(l_current);
             -- overwrite current from the saved next
             l_asg_events(l_current) := l_saved_asg_event;

          ELSIF TRUNC(l_asg_events(l_next).event_date) = --next equal current
                TRUNC(l_asg_events(l_current).event_date) THEN
            -- NON generic processing.

            -- concatenate next event type with current
               l_asg_events(l_current).event_type :=
                 l_asg_events(l_current).event_type||','||l_asg_events(l_next).event_type;

            -- Bugfix 3641851:CBF3a : Now storing new_location_id and
            --   new_ext_emp_cat_cd if they r not NULL in the next event.
            --   This is needed coz there cud b more than one events
            --   on same date and we need the new_location_id and
            --   new_ext_emp_cat_cd in the New LOS code.
            IF l_asg_events(l_next).new_location_id IS NOT NULL THEN
              l_asg_events(l_current).new_location_id := l_asg_events(l_next).new_location_id;
            END IF;
            --
            IF l_asg_events(l_next).new_ext_emp_cat_cd IS NOT NULL THEN
              l_asg_events(l_current).new_ext_emp_cat_cd := l_asg_events(l_next).new_ext_emp_cat_cd;
            END IF;

            -- Bugfix 3734942
            -- If the next event type is one of
            --          a) Emp Cat change
            --          b) Secondary Leaver
            --          c) Secondary Starter or Restarter
            --          e) Primary Leaver
            --          e) Primary Starter or Restarter
            -- then we need to accumulate the pt_asg_count_change
            -- for use at time of processing these events
            IF (INSTR(nvl(l_asg_events(l_next).event_type,'XX')
                     ,'PQP_GB_TP_ASG_EMP_CAT'
                     ) > 0
                OR
                INSTR(nvl(l_asg_events(l_next).event_type,'XX')
                     ,'SECONDARY_LEAVER'
                     ) > 0
                OR
                INSTR(nvl(l_asg_events(l_next).event_type,'XX')
                     ,'SECONDARY_RESTARTER'
                     ) > 0
                OR
                INSTR(nvl(l_asg_events(l_next).event_type,'XX')
                     ,'SECONDARY_STARTER'
                     ) > 0
                -- Bugfix 3880543:REHIRE : Primary leaver and restarter events
                --   sh also change the asg count
                OR
                INSTR(nvl(l_asg_events(l_next).event_type,'XX')
                     ,'PRIMARY_LEAVER'
                     ) > 0
                OR
                INSTR(nvl(l_asg_events(l_next).event_type,'XX')
                     ,'PRIMARY_RESTARTER'
                     ) > 0
                OR
                INSTR(nvl(l_asg_events(l_next).event_type,'XX')
                     ,'PRIMARY_STARTER'
                     ) > 0
               ) THEN

              debug('Curr Value for PT Asg Cnt Change :'||
                        to_char(nvl(l_asg_events(l_current).pt_asg_count_change, 0)), 30);

              debug('Next Value for PT Asg Cnt Change :'||
                        to_char(nvl(l_asg_events(l_next).pt_asg_count_change, 0)), 40);

              -- Bugfix 3880543:REHIRE : If the event is on the same date
              --  and both the events hv a change in PT asg count
              --  then we don't want to add them up coz there cud
              --  be an employment category change on the restarter
              --  date of an assignment from FT to PT causing
              --  double addition to g_part_time_asg_count
              IF (l_asg_events(l_next).assignment_id
                  = --next asg equal current
                  l_asg_events(l_current).assignment_id
                 )
                 AND -- Next has a Pt asg count change event
                 (nvl(l_asg_events(l_next).pt_asg_count_change, 0)
                  > 0
                 )
                 AND -- Current too has a Pt asg count change event
                 (nvl(l_asg_events(l_current).pt_asg_count_change, 0)
                  > 0
                 )THEN

                -- Do not add the next pt_asg_count_change event into current
                debug('Skipping as 2 events on same date will cause Pt asg count to double, ', 50);
                NULL;

              ELSE
                l_asg_events(l_current).pt_asg_count_change :=
                  nvl(l_asg_events(l_current).pt_asg_count_change, 0)
                  +
                  nvl(l_asg_events(l_next).pt_asg_count_change, 0);

              END IF;

            END IF;

            -- Bugfix 3803760:TERMASG
            l_asg_events(l_current).asg_count_change :=
                nvl(l_asg_events(l_current).asg_count_change, 0)
                +
                nvl(l_asg_events(l_next).asg_count_change, 0);


            -- mark this "next" index to be skipped
               l_indexes_to_skip(l_next) := TRUE;

          END IF;

        END IF; -- if next index is not marked to skip

        l_next := l_asg_events.NEXT(l_next);

      END LOOP;

      g_asg_events(l_g_current) := l_asg_events(l_current);
      l_g_current := l_g_current + 1;

    END IF; -- if current index is not marked to skip

    l_current := l_asg_events.NEXT(l_current);

  END LOOP;

  IF NOT l_indexes_to_skip.EXISTS(l_asg_events.LAST) THEN
     g_asg_events(l_g_current) := l_asg_events(l_asg_events.LAST);
  END IF;

  debug_exit(l_proc_name);
-- debug only, uncomment the following code to debug
/*
  l_current := l_indexes_to_skip.FIRST;
  WHILE l_current <= l_indexes_to_skip.LAST
  LOOP
    dbms_output.put_line('Skip Index: '||fnd_number.number_to_canonical(l_current));
    l_current := l_indexes_to_skip.NEXT(l_current);
  END LOOP;
*/

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END sort_stored_events;

-- recalc_data_elements
--
PROCEDURE recalc_data_elements
            (p_dtl_rec          IN OUT NOCOPY csr_rslt_dtl%ROWTYPE
            ,p_rec_type         IN VARCHAR2
            ,p_event_details    IN stored_events_type
            ,p_assignment_id    IN per_all_assignments_f.assignment_id%TYPE
            )
IS

  -- Variable Declaration
  l_error                NUMBER;
  l_days_excluded        NUMBER;
  l_return               NUMBER;
  l_annual_rate          NUMBER;
  l_ret_allow            NUMBER;
  l_part_time_sal        NUMBER;
  l_temp_ext_emp_cat_cd  VARCHAR(1) ;
  -- nocopy changes
  l_dtl_rec_nc           csr_rslt_dtl%ROWTYPE;


  -- Fill in with zeros instead of space
  -- Bug fix 2353106

  l_other_allowance      VARCHAR2(5) := '00000';
  l_temp_date            DATE;
  l_temp_date_primary    DATE;
  l_temp_sfgrade         pqp_assignment_attributes_f.tp_safeguarded_grade%TYPE;
  l_new_sfgrade          pqp_assignment_attributes_f.tp_safeguarded_grade%TYPE;
  l_london_allowance     ben_ext_rslt_dtl.val_21%TYPE;
  l_sp_allowance         ben_ext_rslt_dtl.val_22%TYPE;
  l_contract_indicator   ben_ext_rslt_dtl.val_23%TYPE;
  l_rowcount             NUMBER:=0;
  l_pqp_asg_attributes_up csr_pqp_asg_attributes_up%ROWTYPE;
  l_asg_details           csr_asg_details_up%ROWTYPE;
  l_temp_location_id     per_all_assignments_f.location_id%TYPE;

  l_assignment_id       per_all_assignments_f.assignment_id%TYPE;
  l_report_primary_asg  VARCHAR2(1);

  -- Rowtype Variable Declaration

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'recalc_data_elements';

  -- a number;

BEGIN -- recalc_data_elements

  debug_enter(l_proc_name);

  -- nocopy changes
  l_dtl_rec_nc := p_dtl_rec;

  debug('p_assignment_id: '|| to_char(p_assignment_id), 1) ;

  debug('p_event_details_EVENT_TYPE: '|| (p_event_details.event_type), 1.1) ;

  -- RETRO:BUG: 4135481
  -- Reset the global here to raise a warning from recalc_data_element
  -- This global will be set in adjust_pre_part_payments/adjust_post_part_payments
  -- called from calc_part_time_sal
  -- if there are proration and Retro event both for the same line of service
  -- and we are unable to find the exact payments.
  -- Still exploring the way to find out the exact payments in this case.
  -- Till then we will raise this warning.

  -- REMOVE this once a solution is in place for this.
  g_raise_retro_warning := 'N' ;

   -- Added by Sharath
      g_supp_teacher := 'N';
   -- End of Sharath changes
  -- PERF_ENHANC_3A : Performance Enhancements
  -- this table of records will be used in recalc_data_elements to store
  -- details corresponding of assignment IDs. Instead of calling parttime and FT
  -- salary function multiple times, this data collection will be used
  g_asg_recalc_details.DELETE;



  -- Bugfix 2551059 : Developer : rtahilia
  -- At the time of doing this bugfix,
  -- we also discovered that all calls to_date use the format of DDMMYY
  -- in this procedure resulting in data being wrongly calculated
  -- for 2099 instead of 1999. Hence all to_date calls in this procedure
  -- have been changed to use the format of DDMMRR.

  -- PS : The serial numbers below are calcualted as
  --            (actual position of the data element) + 1
  -- This serial number gives us the column name in the table
  -- ben_ext_rslt_dtl where the data element will be stored.
  -- E.g. Salary Scale will be stored in column val_11

  -- Bugfix 3803760:FTSUPPLY
  -- Set the effective assignments as of effective start date
  --  of the current line of service
  debug('g_asg_count: '|| to_char(g_asg_count), 2) ;

  set_effective_assignments
     (p_primary_assignment_id     => p_assignment_id
     ,p_effective_date            => to_date(p_dtl_rec.val_13,'DDMMRR')
     );
  debug('g_asg_count: '|| to_char(g_asg_count), 6) ;

  -- Bugfix 3073562:GAP6
  -- Check if primary asg is to be reported
  l_report_primary_asg :=
        chk_report_assignment
          (p_assignment_id            => p_assignment_id
          ,p_secondary_assignment_id  => l_assignment_id
          -- Bugfix 3641851:CBF1 : Calling with effective start date of new line
          ,p_effective_date           => to_date(p_dtl_rec.val_13,'DDMMRR')
          );


  debug('p_assignment_id :'||p_assignment_id, 10);
  debug('l_assignment_id :'||l_assignment_id, 20);
  debug('l_report_primary_asg :'||l_report_primary_asg, 21);
  debug('p_rec_type :'||p_rec_type, 22);

  -- Bugfix 3880543:REHIRE : So that the unconditional refresh of
  --  some of the data elements works, we need to get the
  --  details from the asg row and apply it to the global
  --  collection row of l_assignment_id. But we only need
  --  to do this if g_override_ft_asg_id IS NULL coz if it
  --  is set (NOT NULL) then the refresh of asg dets in
  --  global collection sh hv alredy happened in the proc
  --  set_effective_assignments
  -- The refresh is mainly for the following
  --  a) Establishment number
  --  b) Employment category
  --  c) Grade - NOT DONE YET, mite hv to consider in future
  IF g_override_ft_asg_id IS NULL THEN

    OPEN csr_asg_details_up
          (l_assignment_id
          ,to_date(p_dtl_rec.val_13,'DDMMRR')
          );
    FETCH csr_asg_details_up INTO l_asg_details;
    IF csr_asg_details_up%NOTFOUND THEN
      -- This situation should never happen,
      debug('IMP : This situation should never happen', 23);
      NULL;
    ELSE -- asg record FOUND

      IF l_asg_details.location_id IS NOT NULL
         AND
         pqp_gb_tp_pension_extracts.g_criteria_estbs.EXISTS(l_asg_details.location_id) THEN

        -- Setting the current ext_emp_cat_cd, location_id and estb_number
        debug('Re-evaluating l_assignment_id details', 24);

        g_ext_asg_details(l_assignment_id).ext_emp_cat_cd :=
                        get_translate_asg_emp_cat_code
                          (l_asg_details.asg_emp_cat_cd
                          ,to_date(p_dtl_rec.val_13,'DDMMRR')
                          ,'Pension Extracts Employment Category Code'
                          ,l_asg_details.business_group_id
                          );

        debug('l_asg_details.location_id :'||to_char(l_asg_details.location_id), 25);
        g_ext_asg_details(l_assignment_id).location_id := l_asg_details.location_id;

        debug('Current estb number for l_assignment_id :'||
                        g_ext_asg_details(l_assignment_id).estb_number, 26);
        debug('Estb number in Global :'||
                        pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number, 27);
        g_ext_asg_details(l_assignment_id).estb_number :=
          pqp_gb_tp_pension_extracts.g_criteria_estbs(l_asg_details.location_id).estb_number;

      ELSE
        debug('WARNING: This asg might hv multiple leaver events', 27);
      END IF;

    END IF; -- csr_asg_details_up%NOTFOUND THEN

    CLOSE csr_asg_details_up;

  END IF;

  -- IF l_report_primary_asg is 'Y' then
  -- l_assignment_id will have the asg id of the primary assignment
  -- ELSE it will have the asg id of the secondary assignment
  --
  -- Guidelines on when to use l_assignment_id instead of p_assignment_id
  --  a) If the func u r calling does not chk if primary is to be reported
  --     or not, then you must pass l_assignment_id.
  --     E.g. Get_Grade_Fasttrack_Info
  --  b) If the func u r calling is intelligent and does the check on its own
  --     then you must pass p_assignment_id
  --     E.g. get_days_excluded_date

  -- 10) Recalc School / Type of Employment Number
  -- Bugfix 3073562:GAP10 : Now recalculating establishment number
  -- as Establishment change within LEA is a new line of service event

  -- Bugfix 3734942
  --  We need to adjust the part time asg count depending
  --  on the events that have occured. The count will get
  --  adjusted if we just add the pt_asg_count_change for
  --  the current event to g_part_time_asg_count coz its
  --  being set correctly when events are found and also
  --  being accumulated for multiple events on same date
  -- IMP Change : This logic has now moved up to create_new_lines
  debug('g_part_time_asg_count :'||to_char(g_part_time_asg_count), 30);

  IF p_rec_type = 'NEW' THEN

    IF g_override_ft_asg_id IS NOT NULL THEN
      -- Bugfix 3803760:FTSUPPLY
      -- If override asg has been set, we need to
      -- refresh estb number from this asg
      debug('Refreshing from override asg', 34);
      p_dtl_rec.val_10 :=
              nvl(pqp_gb_tp_pension_extracts.g_criteria_estbs
                      (g_ext_asg_details(l_assignment_id).location_id
                      ).estb_number
                 ,p_dtl_rec.val_10
                 );

    ELSIF g_part_time_asg_count > 1 THEN
      -- Bugfix 3641851:ENH6 Adding this new clause
      --   coz for concurrent PT asgs we report 0953
      -- Bugfix 3734942 : Refresh the estb number as per
      --  the part time asg count

      -- Multiple Pt asgs exist, estb number sh b 0953
      p_dtl_rec.val_10 := '0953';

    ELSE
      -- PT asg count is NOT GREATER than 1
      --  We should only refresh the estb number if
      --  PT count has fallen due to assignments
      --  leaving or emp cat change or a location
      --  change event has happened
      --  IF Some non relevant event has happened
      --  we should not refresh the estb number
      IF (INSTR(nvl(p_event_details.event_type,'XX')
               ,'PQP_GB_TP_ASG_LOCATION'
               ) > 0
          OR
          INSTR(nvl(p_event_details.event_type,'XX')
               ,'PQP_GB_TP_ASG_EMP_CAT'
               ) > 0
         )
         -- Bugfix 3880543:REHIRE : Only consider this emp cat OR Loc
         --  change if it happened on the asg we r reporting for
         AND
         (p_event_details.assignment_id = l_assignment_id
         ) THEN

        debug('new_location_id :'||to_char(p_event_details.new_location_id), 38);
        debug('val_10 :'||p_dtl_rec.val_10, 39);

        -- Bugfix 3470242:BUG1 : Now using new_location_id, estb_number can
        --     always be sought using the location id
        -- p_dtl_rec.val_10 := nvl(p_event_details.new_estb_number, p_dtl_rec.val_10);
        p_dtl_rec.val_10 := nvl(pqp_gb_tp_pension_extracts.g_criteria_estbs
                                (p_event_details.new_location_id).estb_number
                           , p_dtl_rec.val_10
                           );

      ELSE
        -- Bugfix 3880543:REHIRE : Changed the above elsif to ELSE
        -- We now refresh unconditionally if none of the
        -- above conditions apply to fix the rehire problem
        debug('Refreshing from l_assignment_id', 40);
        p_dtl_rec.val_10
                := nvl(pqp_gb_tp_pension_extracts.g_criteria_estbs
                                (g_ext_asg_details(l_assignment_id).location_id
                                ).estb_number
                      ,p_dtl_rec.val_10
                      );
      END IF;

    END IF; -- g_part_time_asg_count > 1 THEN

    debug('val_10 :'||p_dtl_rec.val_10, 41);

  END IF; -- p_rec_type = 'NEW' THEN

  --11.1)
  debug('val_20 :'||p_dtl_rec.val_20, 49);

  p_dtl_rec.val_20 := Get_Grade_Fasttrack_Info(p_assignment_id  => l_assignment_id
                                              ,p_effective_date => to_date(p_dtl_rec.val_13,'DDMMRR'));

  debug('val_20 :'||p_dtl_rec.val_20, 50);

  -- 11.2) Salary Scale
  --Changed by sshetty, added elsif clause
  --This part added by sshetty fix for a bug# 2478516
  --to vaidate safeguarded grade change.
  IF  p_rec_type = 'NEW'
     AND
     (
     INSTR(nvl(p_event_details.event_type,'XX')
           ,'PQP_GB_TP_SAFEGUARDED_SALARY'
           ) > 0
     OR
     INSTR(nvl(p_event_details.event_type,'XX')
                  ,'PRIMARY_RESTARTER'
           ) > 0
     ) THEN

    OPEN  csr_pqp_asg_attributes_up(l_assignment_id,
                                    TO_DATE(p_dtl_rec.val_13,'DDMMRR'));
    FETCH csr_pqp_asg_attributes_up INTO  l_pqp_asg_attributes_up;

    IF csr_pqp_asg_attributes_up%NOTFOUND THEN
      debug(l_proc_name, 60);
      l_pqp_asg_attributes_up.tp_safeguarded_grade := NULL;
    END IF;

    debug(l_proc_name, 70);
    CLOSE csr_pqp_asg_attributes_up;

    IF l_pqp_asg_attributes_up.tp_safeguarded_grade IS NOT NULL THEN

      pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).tp_safeguarded_grade
                           := l_pqp_asg_attributes_up.tp_safeguarded_grade;
      g_ext_asg_details(l_assignment_id).tp_safeguarded_grade
                           := l_pqp_asg_attributes_up.tp_safeguarded_grade;

      debug(l_proc_name, 80);
      IF l_report_primary_asg = 'N' THEN
        -- We need to keep the global record for primary asg updated as well
        pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).tp_safeguarded_grade
                           := l_pqp_asg_attributes_up.tp_safeguarded_grade;
        g_ext_asg_details(p_assignment_id).tp_safeguarded_grade
                    := l_pqp_asg_attributes_up.tp_safeguarded_grade;

        debug(l_proc_name, 90);
      END IF;

      p_dtl_rec.val_11 := l_pqp_asg_attributes_up.tp_safeguarded_grade;

    ELSE -- l_pqp_asg_attributes_up.tp_safeguarded_grade IS NOT NULL THEN
    --this validation is to make sure that we get the grade for that assignment
    --when safeguarded salary is made null.

      debug(l_proc_name, 100);

      l_temp_date :=
                  pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).start_date;

      -- Bugfix 3880543:GRD : We need to set the date in global
      --  collection for primary row as well, take a bakup
      l_temp_date_primary := g_ext_asg_details(p_assignment_id).teacher_start_date;
      l_temp_sfgrade :=
                  pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).tp_safeguarded_grade;

      pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).start_date
                                  := to_date(p_dtl_rec.val_13,'DDMMRR');

      -- Bugfix 3880543:GRD : We need to set the date in global
      --  collection for primary row as well
      g_ext_asg_details(p_assignment_id).teacher_start_date := to_date(p_dtl_rec.val_13,'DDMMRR');

      pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).tp_safeguarded_grade
                                  := NULL;

      pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
      l_new_sfgrade := pqp_gb_tp_pension_extracts.get_tp4_salary_scale
                                                 (p_assignment_id => p_assignment_id
                                                 );
      pqp_gb_tp_pension_extracts.g_nested_level := 0;

      pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).start_date:=
                                                                      l_temp_date;
      pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).tp_safeguarded_grade:=
                                                                      l_temp_sfgrade;

      -- Bugfix 3880543:GRD : We need to set the date in global
      --  collection for primary row as well, now restoring the date
      g_ext_asg_details(p_assignment_id).teacher_start_date:= l_temp_date_primary;

      IF l_new_sfgrade = 'INVALID' THEN

        l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                            (p_assignment_id     => p_assignment_id
                            ,p_error_text        => 'BEN_93037_EXT_TP1_INV_SAL_SCL'
                            ,p_error_number      => 93037
                            );

      ELSIF l_new_sfgrade = 'UNKNOWN' THEN

        l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                            (p_assignment_id     => p_assignment_id
                            ,p_error_text        => 'BEN_93038_EXT_TP1_UNK_SAL_SCL'
                            ,p_error_number      => 93038
                            );

      ELSIF l_new_sfgrade = 'TOOMANY' THEN

        l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                            (p_assignment_id     => p_assignment_id
                            ,p_error_text        => 'BEN_93039_EXT_TP1_TOOMANY_VALS'
                            ,p_error_number      => 93039
                            );


      ELSE -- valid value has been returned
       p_dtl_rec.val_11 := l_new_sfgrade;
      END IF;
      --
    END IF; -- l_pqp_asg_attributes_up.tp_safeguarded_grade IS NOT NULL THEN
    --
  END IF;
  --
  debug('val_11 :'||p_dtl_rec.val_11, 110);
  --
  IF p_rec_type = 'NEW'
     AND
     (
      (INSTR(nvl(p_event_details.event_type,'XX')
            ,'PQP_GB_TP_ASG_GRADE'
            ) > 0
       -- Bugfix 3470242:BUG1
       -- Before GAP4 enhancements, sal scale code cud only
       -- change at asg grade. But now coz sal scale code
       -- is derived from element entries or location EIT
       -- or spinal points, we must re-evaluate sal scale
       -- codes if any of these change for this asg.
       OR
       -- Bugfix 3470242:BUG1 : Re-evaluating for Element entry(EE) events
       INSTR(nvl(p_event_details.event_type,'XX')
                   ,'PQP_GB_TP_ELEMENT_ENTRY'
            ) > 0
       OR
       -- Bugfix 3470242:BUG1 : Re-evaluating for Location change event
       INSTR(nvl(p_event_details.event_type,'XX')
                   ,'PQP_GB_TP_ASG_LOCATION'
            ) > 0
       OR
       -- Bugfix 3470242:BUG1 : Re-evaluating for Spinal pt. change event
       INSTR(nvl(p_event_details.event_type,'XX')
                   ,'PQP_GB_TP_GRADE_STEP'
            ) > 0
       OR
       -- Bugfix 3880543:REHIRE : Primary leaver also needs to be considered
       --  now as we hv the rehire fix
       INSTR(nvl(p_event_details.event_type,'XX')
                  ,'PRIMARY_LEAVER'
            ) > 0
       OR
       INSTR(nvl(p_event_details.event_type,'XX')
                  ,'PRIMARY_RESTARTER'
            ) > 0
       OR
       INSTR(nvl(p_event_details.event_type,'XX')
                  ,'PRIMARY_STARTER'
            ) > 0
       OR
       INSTR(nvl(p_event_details.event_type,'XX')
                  ,'SECONDARY_STARTER'
            ) > 0
       OR
       INSTR(nvl(p_event_details.event_type,'XX')
                  ,'SECONDARY_LEAVER'
            ) > 0
       OR
       INSTR(nvl(p_event_details.event_type,'XX')
                  ,'SECONDARY_RESTARTER'
            ) > 0
       OR
       INSTR(nvl(p_event_details.event_type,'XX')
                  ,'PQP_GB_TP_ASG_EMP_CAT'
            ) > 0
      )
      AND
      (p_dtl_rec.val_20 <>'S'
      )
     ) THEN

    debug(l_proc_name, 120);
    -- Get the new grade value
    -- We need to fool the type 4 function so manipulate the global variables temporarily

    -- Make a copy of the original values
    l_temp_date := pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).start_date;
    -- Bugfix 3880543:GRD : We need to set the date in global
    --  collection for primary row as well, take a bakup
    l_temp_date_primary := g_ext_asg_details(p_assignment_id).teacher_start_date;
    l_temp_sfgrade := pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).tp_safeguarded_grade;

    -- Assign the effective date we need and make the sfgrade NULL
    pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).start_date
                                          := to_date(p_dtl_rec.val_13,'DDMMRR');

    -- Bugfix 3880543:GRD : We need to set the date in global
    --  collection for primary row as well
    g_ext_asg_details(p_assignment_id).teacher_start_date := to_date(p_dtl_rec.val_13,'DDMMRR');
    pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).tp_safeguarded_grade := NULL;

    -- Bugfix 3470242:BUG1 : Location change has happened so we need to
    --          replace the location_id in tp4 global collection.
    --          Currently not replacing in tp1 collection as its not
    --          used anywhere in code from here on
    IF INSTR(nvl(p_event_details.event_type,'XX')
                   ,'PQP_GB_TP_ASG_LOCATION'
            ) > 0  THEN

      debug(l_proc_name, 130);
      -- l_temp_location_id := pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).location_id;
      pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).location_id :=
        p_event_details.new_location_id;
      IF pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number = '0966' AND
         p_dtl_rec.val_10 <> '0966' THEN
         g_supp_teacher := 'Y';
      END IF;
      pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number := p_dtl_rec.val_10;


    END IF;

    pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
    l_new_sfgrade := pqp_gb_tp_pension_extracts.get_tp4_salary_scale
                                                  (p_assignment_id => p_assignment_id
                                                  );
    pqp_gb_tp_pension_extracts.g_nested_level := 0;

    IF l_new_sfgrade = 'INVALID' THEN

      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                            (p_assignment_id     => p_assignment_id
                            ,p_error_text        => 'BEN_93037_EXT_TP1_INV_SAL_SCL'
                            ,p_error_number      => 93037
                            );

    ELSIF l_new_sfgrade = 'UNKNOWN' THEN

      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                            (p_assignment_id     => p_assignment_id
                            ,p_error_text        => 'BEN_93038_EXT_TP1_UNK_SAL_SCL'
                            ,p_error_number      => 93038
                            );

    ELSIF l_new_sfgrade = 'TOOMANY' THEN

      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                            (p_assignment_id     => p_assignment_id
                            ,p_error_text        => 'BEN_93039_EXT_TP1_TOOMANY_VALS'
                            ,p_error_number      => 93039
                            );


    ELSE -- valid value has been returned

      p_dtl_rec.val_11 := l_new_sfgrade;

    END IF;

    -- Assign back the original values to the global variables
    pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).start_date := l_temp_date;
    -- Bugfix 3880543:GRD :  We need to set the date in global
    --  collection for primary row as well, now restoring the date
    g_ext_asg_details(p_assignment_id).teacher_start_date := l_temp_date_primary;
    pqp_gb_tp_pension_extracts.g_ext_asg_details(l_assignment_id).tp_safeguarded_grade := l_temp_sfgrade;

  END IF; -- p_rec_type = 'NEW' for Salary Scale
  --
  debug('val_11 :'||p_dtl_rec.val_11, 140);

  -- 12) Full or Part-time Indicator
  IF g_override_ft_asg_id IS NOT NULL THEN
    -- Bugfix 3803760:FTSUPPLY
    -- If override asg has been set, we need to
    -- refresh FT Pt indicator from this asg

    p_dtl_rec.val_12 := g_ext_asg_details(l_assignment_id).ext_emp_cat_cd;

  -- ELSE Assign the new value only if the emp cat has changed
  ELSIF p_rec_type = 'NEW'
     AND
     (INSTR(nvl(p_event_details.event_type,'XX')
           ,'PQP_GB_TP_ASG_EMP_CAT'
           ) > 0
     )
     -- Bugfix 3880543:REHIRE : Only consider this emp cat change
     -- if it happened on the asg we r reporting for
     AND
     (p_event_details.assignment_id = l_assignment_id
     ) THEN

       debug('PQP_GB_TP_ASG_EMP_CAT event ',143);

       p_dtl_rec.val_12 := nvl(p_event_details.new_ext_emp_cat_cd,p_dtl_rec.val_12);

       debug('p_dtl_rec.val_12 '|| p_dtl_rec.val_12,144);

  ELSE
        debug('Refresh Emp category anyway ',145);
        -- get ext_emp_cat_cd from asg table as of start date of the
        -- current new line of service being re-evaluated
        p_dtl_rec.val_12 := get_ext_emp_cat_cd
                            (
                              l_assignment_id,
                              to_date(p_dtl_rec.val_13,'DDMMRR')
                            );

        debug('p_dtl_rec.val_12 '|| p_dtl_rec.val_12,146);

  END IF;
  --
  debug('val_12 :'||p_dtl_rec.val_12, 150);

  -- 15) Withdrawal conf
  -- Currently handled from procedure create_new_lines

  -- Added a new param p_emp_cat_cd for Bug fix 2341170,2341276

  -- Fix : 3823873
  -- Store the employment category in temporary variable and
  -- pass the changed emp cat to the get_days_excluded_date
  -- and reset after the call

  debug('g_ext_asg_details(p_assignment_id).ext_emp_cat_cd '||g_ext_asg_details(p_assignment_id).ext_emp_cat_cd, 152 );

  l_temp_ext_emp_cat_cd := g_ext_asg_details(p_assignment_id).ext_emp_cat_cd;
  g_ext_asg_details(p_assignment_id).ext_emp_cat_cd := p_dtl_rec.val_12;

  -- 16) Days Excluded
  l_return := get_days_excluded_date
                (p_assignment_id        => p_assignment_id
                ,p_effective_start_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                ,p_effective_end_date   => to_date(p_dtl_rec.val_14,'DDMMRR')
                ,p_emp_cat_cd           => p_dtl_rec.val_12
                ,p_days                 => l_days_excluded -- OUT
                );
  --reset the employment category.
  g_ext_asg_details(p_assignment_id).ext_emp_cat_cd := l_temp_ext_emp_cat_cd;
  debug('g_ext_asg_details(p_assignment_id).ext_emp_cat_cd '||g_ext_asg_details(p_assignment_id).ext_emp_cat_cd, 154 );

   if l_return = -2 THEN    -- bug 6275363
    p_dtl_rec.val_16 := '+00';

   elsif l_return <> -1 THEN

     p_dtl_rec.val_16 := trim(to_char(l_days_excluded,'099'));

    ELSE

    p_dtl_rec.val_16 := '000';

    END IF;
  l_return := NULL;
  --
  debug('val_16 :'||p_dtl_rec.val_16, 160);
  --
  -- 17) Annual Full-time Salary Rate
  l_return := get_annual_sal_rate_date
                (p_assignment_id        => p_assignment_id
                ,p_effective_start_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                ,p_effective_end_date   => to_date(p_dtl_rec.val_14,'DDMMRR')
                ,p_rate                 => l_annual_rate
                );

  IF l_return <> -1 THEN

    g_annual_rate(p_assignment_id) := l_annual_rate;
    p_dtl_rec.val_17 := trim(to_char(l_annual_rate,'099999'));

  ELSE

    p_dtl_rec.val_17 := '000000';

  END IF;
  l_return := NULL;
  --
  debug('val_17 :'||p_dtl_rec.val_17, 170);
  --
  -- 19) Part-Time Salary Paid
  IF p_dtl_rec.val_12 = 'P' THEN -- Part-time employment

    l_part_time_sal := get_part_time_sal_date
                         (p_assignment_id        => p_assignment_id
                         ,p_effective_start_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                         ,p_effective_end_date   => to_date(p_dtl_rec.val_14,'DDMMRR')
                         );

    -- Check whether part time sal exceeds annual salary rate
    -- Fill in with zeros instead of space
    -- Bug fix 2353106
    -- Bug Fix 6140377
    IF sign(l_part_time_sal) = -1 THEN
       p_dtl_rec.val_19 := '-'|| lpad(abs(l_part_time_sal),5,'0');
    ELSE
       p_dtl_rec.val_19 := lpad(l_part_time_sal,6,'0');
    END IF;
    --
  ELSE -- emp cat cd is not part time
    -- Bug Fix 6140377
    p_dtl_rec.val_19 := '000000';

  END IF; -- p_dtl_rec.val_12 = 'P' THEN
  --
  debug('val_19 :'||p_dtl_rec.val_19, 180);
  --
  -- 20) Safeguarded Salary Fast Track
  ---This part is now is 11.1

  -- 21) London Allowance - Rate Payable
/*
  l_london_allowance := Get_Allowance_Code(p_assignment_id  => l_assignment_id
                                          ,p_effective_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                                          ,p_allowance_type => 'LONDON_ALLOWANCE_RULE'
                                          );
*/
  l_london_allowance := Get_Allowance_Code_New(p_assignment_id  => l_assignment_id
                                          ,p_effective_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                                          ,p_allowance_type => 'LONDON_ALLOWANCE_RULE'
                                          );

  debug('l_london_allowance :'||l_london_allowance, 190);
  IF l_london_allowance = 'UNKNOWN' THEN

    l_london_allowance := ' ';

  ELSIF l_london_allowance = 'TOOMANY' THEN

    l_london_allowance := ' ';
    -- Bugfix 3516282 : Now passing assignment_id
    l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                     (p_assignment_id => p_assignment_id
                     ,p_error_text    => 'BEN_93032_EXT_TP1_LON_ALL_MANY'
                     ,p_error_number  => 93032
                     );

  END IF;
  --
  debug('l_london_allowance :'||l_london_allowance, 200);
  --
  p_dtl_rec.val_21 := substr(l_london_allowance,1,1);


  -- 22) Special Priority - Allowance Payable Special Needs
/*
  l_sp_allowance := Get_Allowance_Code(p_assignment_id  => l_assignment_id
                                      ,p_effective_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                                      ,p_allowance_type => 'SPECIAL_ALLOWANCE_RULE'
                                      );
*/
 l_sp_allowance := Get_Allowance_Code_New(p_assignment_id  => l_assignment_id
                                      ,p_effective_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                                      ,p_allowance_type => 'SPECIAL_ALLOWANCE_RULE'
                                      );

  debug('l_sp_allowance :'||l_sp_allowance, 210);
  IF l_sp_allowance = 'UNKNOWN' THEN

    l_sp_allowance := '0';

  ELSIF l_sp_allowance = 'TOOMANY' THEN

    l_sp_allowance := '0';
    -- Bugfix 3516282 : Now passing assignment_id
    l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                     (p_assignment_id => p_assignment_id
                     ,p_error_text    => 'BEN_93034_EXT_TP1_SP_ALL_MANY'
                     ,p_error_number  => 93034
                     );

  END IF;
  --
  debug('l_sp_allowance :'||l_sp_allowance, 220);
  --
  p_dtl_rec.val_22 := substr(l_sp_allowance,1,1);


  -- 23) Special Class Additions (Part-time Indicator)
  l_contract_indicator := Get_Special_ClassRule(p_assignment_id  => l_assignment_id
                                               ,p_effective_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                                               );

  debug('l_contract_indicator :'||l_contract_indicator, 230);

  IF l_contract_indicator = 'UNKNOWN' THEN

    l_contract_indicator := '0';

  ELSIF l_contract_indicator = 'INVALID' THEN

    l_contract_indicator := '0';
    -- Bugfix 3516282 : Now passing assignment_id
    l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                     (p_assignment_id => p_assignment_id
                     ,p_error_text    => 'BEN_93036_EXT_TP1_INV_EMP_CAT'
                     ,p_error_number  => 93036
                     );

  END IF;
  --
  debug('l_contract_indicator :'||l_contract_indicator, 240);
  --
  p_dtl_rec.val_23 := l_contract_indicator;


  -- 24) Other Allowances
  IF g_other_allowance.EXISTS(p_assignment_id) THEN

     debug('Other Allowance : '||to_char(g_other_allowance(p_assignment_id)),245);

     -- 4336613 : SAL_VALIDAT_3A : Check whether Other_All value has exceeeded 4 digit limit
     -- If yes, raise warning.
     if g_other_allowance(p_assignment_id) > 99999 then

        l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                     (p_assignment_id => p_assignment_id
                     ,p_error_text    => 'BEN_93043_EXT_TP1_OTH_VAL_EXC'
                     ,p_error_number  => 93043
                     ,p_token1        => TO_CHAR(g_other_allowance(p_assignment_id)) -- bug : 4336613
                     );

        g_other_allowance(p_assignment_id) := 99999;  -- 4336613 : SAL_VALIDAT_3A :
                                                    -- set to 9999 if > 9999

     end if; -- end if of other allowance max limit check ...

     -- Fill in with zeros instead of space
     -- Bug fix 2353106

     debug('Other Allowance : '||to_char(g_other_allowance(p_assignment_id)),246);

     l_other_allowance := lpad(g_other_allowance(p_assignment_id),5,'0');

  END IF; -- end if of other allowance exists check
  --
  debug('l_other_allowance :'||l_other_allowance, 250);
  --
  p_dtl_rec.val_24 := l_other_allowance;

  --
  -- 27) Annual Retention Allowance Rate
  -- Added for legislative updates to management and retention allowance changes
  l_return := calc_tp1_retention_allow_rate
                (p_assignment_id        => p_assignment_id
                ,p_effective_start_date => to_date(p_dtl_rec.val_13,'DDMMRR')
                ,p_effective_end_date   => to_date(p_dtl_rec.val_14,'DDMMRR')
                ,p_rate                 => l_ret_allow
                );

  IF l_return <> -1 THEN

    p_dtl_rec.val_27 := trim(to_char(l_ret_allow,'09999'));

  ELSE

    p_dtl_rec.val_27 := '00000';

  END IF;
  l_return := NULL;
  --
  debug('val_27 :'||p_dtl_rec.val_27, 255);
  --

  -- RETRO:BUG: 4135481
  IF g_raise_retro_warning = 'Y' THEN
    -- Raise a warning here if both Prorated/Retro payments exist
    -- for the LoS.

    debug('Raising Warning for RETRO/PRORATION', 260);
    l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94159_EXT_TP_RETRO_PAY'
                 ,p_error_number  => 94159
                 --,p_token1        => fnd_date.string_to_canonical(p_dtl_rec.val_13,'DDMMYY')
                 );
     g_raise_retro_warning := 'N' ;
  END IF;

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug('SQLCODE :'||to_char(SQLCODE), 260);
    debug('SQLERRM :'||SQLERRM, 270);
    debug_exit(' Others in '||l_proc_name);
    p_dtl_rec := l_dtl_rec_nc;
    RAISE;
END; -- recalc_data_elements

PROCEDURE upd_rslt_dtl(p_dtl_rec IN ben_ext_rslt_dtl%ROWTYPE)
IS

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'upd_rslt_dtl';

BEGIN -- upd_rslt_dtl

  debug_enter(l_proc_name);

  UPDATE ben_ext_rslt_dtl
  SET VAL_01                 = p_dtl_rec.VAL_01
     ,VAL_02                 = p_dtl_rec.VAL_02
     ,VAL_03                 = p_dtl_rec.VAL_03
     ,VAL_04                 = p_dtl_rec.VAL_04
     ,VAL_05                 = p_dtl_rec.VAL_05
     ,VAL_06                 = p_dtl_rec.VAL_06
     ,VAL_07                 = p_dtl_rec.VAL_07
     ,VAL_08                 = p_dtl_rec.VAL_08
     ,VAL_09                 = p_dtl_rec.VAL_09
     ,VAL_10                 = p_dtl_rec.VAL_10
     ,VAL_11                 = p_dtl_rec.VAL_11
     ,VAL_12                 = p_dtl_rec.VAL_12
     ,VAL_13                 = p_dtl_rec.VAL_13
     ,VAL_14                 = p_dtl_rec.VAL_14
     ,VAL_15                 = p_dtl_rec.VAL_15
     ,VAL_16                 = p_dtl_rec.VAL_16
     ,VAL_17                 = p_dtl_rec.VAL_17
     ,VAL_19                 = p_dtl_rec.VAL_19
     ,VAL_18                 = p_dtl_rec.VAL_18
     ,VAL_20                 = p_dtl_rec.VAL_20
     ,VAL_21                 = p_dtl_rec.VAL_21
     ,VAL_22                 = p_dtl_rec.VAL_22
     ,VAL_23                 = p_dtl_rec.VAL_23
     ,VAL_24                 = p_dtl_rec.VAL_24
     ,VAL_25                 = p_dtl_rec.VAL_25
     ,VAL_26                 = p_dtl_rec.VAL_26
     ,VAL_27                 = p_dtl_rec.VAL_27
     ,VAL_28                 = p_dtl_rec.VAL_28
     ,VAL_29                 = p_dtl_rec.VAL_29
     ,VAL_30                 = p_dtl_rec.VAL_30
     ,VAL_31                 = p_dtl_rec.VAL_31
     ,VAL_32                 = p_dtl_rec.VAL_32
     ,VAL_33                 = p_dtl_rec.VAL_33
     ,VAL_34                 = p_dtl_rec.VAL_34
     ,VAL_35                 = p_dtl_rec.VAL_35
     ,VAL_36                 = p_dtl_rec.VAL_36
     ,VAL_37                 = p_dtl_rec.VAL_37
     ,VAL_38                 = p_dtl_rec.VAL_38
     ,VAL_39                 = p_dtl_rec.VAL_39
     ,VAL_40                 = p_dtl_rec.VAL_40
     ,VAL_41                 = p_dtl_rec.VAL_41
     ,VAL_42                 = p_dtl_rec.VAL_42
     ,VAL_43                 = p_dtl_rec.VAL_43
     ,VAL_44                 = p_dtl_rec.VAL_44
     ,VAL_45                 = p_dtl_rec.VAL_45
     ,VAL_46                 = p_dtl_rec.VAL_46
     ,VAL_47                 = p_dtl_rec.VAL_47
     ,VAL_48                 = p_dtl_rec.VAL_48
     ,VAL_49                 = p_dtl_rec.VAL_49
     ,VAL_50                 = p_dtl_rec.VAL_50
     ,VAL_51                 = p_dtl_rec.VAL_51
     ,VAL_52                 = p_dtl_rec.VAL_52
     ,VAL_53                 = p_dtl_rec.VAL_53
     ,VAL_54                 = p_dtl_rec.VAL_54
     ,VAL_55                 = p_dtl_rec.VAL_55
     ,VAL_56                 = p_dtl_rec.VAL_56
     ,VAL_57                 = p_dtl_rec.VAL_57
     ,VAL_58                 = p_dtl_rec.VAL_58
     ,VAL_59                 = p_dtl_rec.VAL_59
     ,VAL_60                 = p_dtl_rec.VAL_60
     ,VAL_61                 = p_dtl_rec.VAL_61
     ,VAL_62                 = p_dtl_rec.VAL_62
     ,VAL_63                 = p_dtl_rec.VAL_63
     ,VAL_64                 = p_dtl_rec.VAL_64
     ,VAL_65                 = p_dtl_rec.VAL_65
     ,VAL_66                 = p_dtl_rec.VAL_66
     ,VAL_67                 = p_dtl_rec.VAL_67
     ,VAL_68                 = p_dtl_rec.VAL_68
     ,VAL_69                 = p_dtl_rec.VAL_69
     ,VAL_70                 = p_dtl_rec.VAL_70
     ,VAL_71                 = p_dtl_rec.VAL_71
     ,VAL_72                 = p_dtl_rec.VAL_72
     ,VAL_73                 = p_dtl_rec.VAL_73
     ,VAL_74                 = p_dtl_rec.VAL_74
     ,VAL_75                 = p_dtl_rec.VAL_75
     ,OBJECT_VERSION_NUMBER  = p_dtl_rec.OBJECT_VERSION_NUMBER
     ,THRD_SORT_VAL          = p_dtl_rec.THRD_SORT_VAL
  WHERE ext_rslt_dtl_id = p_dtl_rec.ext_rslt_dtl_id;

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- upd_rslt_dtl

PROCEDURE ins_rslt_dtl(p_dtl_rec IN OUT NOCOPY ben_ext_rslt_dtl%ROWTYPE)
IS


-- nocopy changes
l_dtl_rec_nc     ben_ext_rslt_dtl%ROWTYPE;


  l_proc_name          VARCHAR2(61):=
     g_proc_name||'ins_rslt_dtl';

BEGIN -- ins_rslt_dtl

  debug_enter(l_proc_name);

  -- nocopy changes
  l_dtl_rec_nc := p_dtl_rec;

  SELECT ben_ext_rslt_dtl_s.NEXTVAL INTO p_dtl_rec.ext_rslt_dtl_id FROM dual;

  INSERT INTO ben_ext_rslt_dtl
  (EXT_RSLT_DTL_ID
  ,EXT_RSLT_ID
  ,BUSINESS_GROUP_ID
  ,EXT_RCD_ID
  ,PERSON_ID
  ,VAL_01
  ,VAL_02
  ,VAL_03
  ,VAL_04
  ,VAL_05
  ,VAL_06
  ,VAL_07
  ,VAL_08
  ,VAL_09
  ,VAL_10
  ,VAL_11
  ,VAL_12
  ,VAL_13
  ,VAL_14
  ,VAL_15
  ,VAL_16
  ,VAL_17
  ,VAL_19
  ,VAL_18
  ,VAL_20
  ,VAL_21
  ,VAL_22
  ,VAL_23
  ,VAL_24
  ,VAL_25
  ,VAL_26
  ,VAL_27
  ,VAL_28
  ,VAL_29
  ,VAL_30
  ,VAL_31
  ,VAL_32
  ,VAL_33
  ,VAL_34
  ,VAL_35
  ,VAL_36
  ,VAL_37
  ,VAL_38
  ,VAL_39
  ,VAL_40
  ,VAL_41
  ,VAL_42
  ,VAL_43
  ,VAL_44
  ,VAL_45
  ,VAL_46
  ,VAL_47
  ,VAL_48
  ,VAL_49
  ,VAL_50
  ,VAL_51
  ,VAL_52
  ,VAL_53
  ,VAL_54
  ,VAL_55
  ,VAL_56
  ,VAL_57
  ,VAL_58
  ,VAL_59
  ,VAL_60
  ,VAL_61
  ,VAL_62
  ,VAL_63
  ,VAL_64
  ,VAL_65
  ,VAL_66
  ,VAL_67
  ,VAL_68
  ,VAL_69
  ,VAL_70
  ,VAL_71
  ,VAL_72
  ,VAL_73
  ,VAL_74
  ,VAL_75
  ,CREATED_BY
  ,CREATION_DATE
  ,LAST_UPDATE_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_LOGIN
  ,PROGRAM_APPLICATION_ID
  ,PROGRAM_ID
  ,PROGRAM_UPDATE_DATE
  ,REQUEST_ID
  ,OBJECT_VERSION_NUMBER
  ,PRMY_SORT_VAL
  ,SCND_SORT_VAL
  ,THRD_SORT_VAL
  ,TRANS_SEQ_NUM
  ,RCRD_SEQ_NUM
  )
  VALUES
  (p_dtl_rec.EXT_RSLT_DTL_ID
  ,p_dtl_rec.EXT_RSLT_ID
  ,p_dtl_rec.BUSINESS_GROUP_ID
  ,p_dtl_rec.EXT_RCD_ID
  ,p_dtl_rec.PERSON_ID
  ,p_dtl_rec.VAL_01
  ,p_dtl_rec.VAL_02
  ,p_dtl_rec.VAL_03
  ,p_dtl_rec.VAL_04
  ,p_dtl_rec.VAL_05
  ,p_dtl_rec.VAL_06
  ,p_dtl_rec.VAL_07
  ,p_dtl_rec.VAL_08
  ,p_dtl_rec.VAL_09
  ,p_dtl_rec.VAL_10
  ,p_dtl_rec.VAL_11
  ,p_dtl_rec.VAL_12
  ,p_dtl_rec.VAL_13
  ,p_dtl_rec.VAL_14
  ,p_dtl_rec.VAL_15
  ,p_dtl_rec.VAL_16
  ,p_dtl_rec.VAL_17
  ,p_dtl_rec.VAL_19
  ,p_dtl_rec.VAL_18
  ,p_dtl_rec.VAL_20
  ,p_dtl_rec.VAL_21
  ,p_dtl_rec.VAL_22
  ,p_dtl_rec.VAL_23
  ,p_dtl_rec.VAL_24
  ,p_dtl_rec.VAL_25
  ,p_dtl_rec.VAL_26
  ,p_dtl_rec.VAL_27
  ,p_dtl_rec.VAL_28
  ,p_dtl_rec.VAL_29
  ,p_dtl_rec.VAL_30
  ,p_dtl_rec.VAL_31
  ,p_dtl_rec.VAL_32
  ,p_dtl_rec.VAL_33
  ,p_dtl_rec.VAL_34
  ,p_dtl_rec.VAL_35
  ,p_dtl_rec.VAL_36
  ,p_dtl_rec.VAL_37
  ,p_dtl_rec.VAL_38
  ,p_dtl_rec.VAL_39
  ,p_dtl_rec.VAL_40
  ,p_dtl_rec.VAL_41
  ,p_dtl_rec.VAL_42
  ,p_dtl_rec.VAL_43
  ,p_dtl_rec.VAL_44
  ,p_dtl_rec.VAL_45
  ,p_dtl_rec.VAL_46
  ,p_dtl_rec.VAL_47
  ,p_dtl_rec.VAL_48
  ,p_dtl_rec.VAL_49
  ,p_dtl_rec.VAL_50
  ,p_dtl_rec.VAL_51
  ,p_dtl_rec.VAL_52
  ,p_dtl_rec.VAL_53
  ,p_dtl_rec.VAL_54
  ,p_dtl_rec.VAL_55
  ,p_dtl_rec.VAL_56
  ,p_dtl_rec.VAL_57
  ,p_dtl_rec.VAL_58
  ,p_dtl_rec.VAL_59
  ,p_dtl_rec.VAL_60
  ,p_dtl_rec.VAL_61
  ,p_dtl_rec.VAL_62
  ,p_dtl_rec.VAL_63
  ,p_dtl_rec.VAL_64
  ,p_dtl_rec.VAL_65
  ,p_dtl_rec.VAL_66
  ,p_dtl_rec.VAL_67
  ,p_dtl_rec.VAL_68
  ,p_dtl_rec.VAL_69
  ,p_dtl_rec.VAL_70
  ,p_dtl_rec.VAL_71
  ,p_dtl_rec.VAL_72
  ,p_dtl_rec.VAL_73
  ,p_dtl_rec.VAL_74
  ,p_dtl_rec.VAL_75
  ,p_dtl_rec.CREATED_BY
  ,p_dtl_rec.CREATION_DATE
  ,p_dtl_rec.LAST_UPDATE_DATE
  ,p_dtl_rec.LAST_UPDATED_BY
  ,p_dtl_rec.LAST_UPDATE_LOGIN
  ,p_dtl_rec.PROGRAM_APPLICATION_ID
  ,p_dtl_rec.PROGRAM_ID
  ,p_dtl_rec.PROGRAM_UPDATE_DATE
  ,p_dtl_rec.REQUEST_ID
  ,p_dtl_rec.OBJECT_VERSION_NUMBER
  ,p_dtl_rec.PRMY_SORT_VAL
  ,p_dtl_rec.SCND_SORT_VAL
  ,p_dtl_rec.THRD_SORT_VAL
  ,p_dtl_rec.TRANS_SEQ_NUM
  ,p_dtl_rec.RCRD_SEQ_NUM
  );

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    p_dtl_rec := l_dtl_rec_nc;
    RAISE;
END; -- ins_rslt_dtl

--
-- Validate that the given date is in the range of the primary asg
--
FUNCTION date_in_prmy_range
  (p_date       IN OUT NOCOPY  DATE
  ,p_date_type  IN      VARCHAR2
  ) RETURN VARCHAR2
IS

  -- Variable Declaration
  l_itr         NUMBER(5);
  l_valid       VARCHAR2(20) := 'Y';


  l_proc_name          VARCHAR2(61):=
     g_proc_name||'date_in_prmy_range';

  -- nocopy changes
  l_date_nc    DATE;

BEGIN -- date_in_prmy_range

  debug_enter(l_proc_name);


  -- nocopy changes
  l_date_nc := p_date;

  IF g_primary_leaver_dates.COUNT > 0 THEN

    FOR l_itr IN g_primary_leaver_dates.FIRST..g_primary_leaver_dates.LAST
    LOOP

      debug('p_date :'||to_char(p_date,'DD/MM/YYYY'), 10);

      IF p_date BETWEEN g_primary_leaver_dates(l_itr).start_date
                     AND nvl(g_primary_leaver_dates(l_itr).leaver_date
                            ,g_effective_run_date
                            ) THEN

        debug('The date is valid', 20);
        l_valid := 'Y';
        EXIT;

      ELSIF g_primary_leaver_dates(l_itr).restarter_date IS NOT NULL
            AND
            p_date >= g_primary_leaver_dates(l_itr).restarter_date THEN

         debug('The date might be valid, continue checking', 30);
         l_valid := 'Y';

      ELSIF (p_date BETWEEN g_primary_leaver_dates(l_itr).leaver_date
                     AND nvl(g_primary_leaver_dates(l_itr).restarter_date
                            ,g_effective_run_date
                            )
            ) THEN

        debug(l_proc_name, 40);
        -- Date is invalid in primary date range, but return the nearest
        -- leaver / restarter date of the primary asg  as we want to find
        -- new line of service events for this secondary asg
        IF p_date_type = 'L' --Leaver
        THEN

          p_date := LEAST(g_primary_leaver_dates(l_itr).leaver_date
                         ,p_date
                         );

          l_valid := 'Y';

        ELSE -- ='R' for Restarter

          debug(l_proc_name, 50);
          IF g_primary_leaver_dates(l_itr).restarter_date IS NOT NULL THEN

            p_date := GREATEST(g_primary_leaver_dates(l_itr).restarter_date
                              ,p_date
                              );
            l_valid := 'Y';

          ELSE

            l_valid := 'N';

          END IF; -- g_primary_leaver_dates(l_itr).restarter_date IS NOT NULL THEN
          --
        END IF; -- p_date_type = 'L'
        --
        debug(l_proc_name, 60);
        -- Exit as validation done
        EXIT;
        --
      END IF; -- (p_date BETWEEN g_primary_leaver_dates(l_itr).leaver_date
      --
    END LOOP;
    --
  ELSE
    -- Primary asg does not have a leaver/restarter event
    l_valid := 'Y';
  END IF;
  --
  debug('l_valid :'||l_valid, 70);
  debug('p_date :'||to_char(p_date,'DD/MM/YYYY'), 80);
  debug_exit(l_proc_name);

  RETURN l_valid;

EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name);
      p_date := l_date_nc;
      RAISE;
END; -- date_in_prmy_range


--
-- Store multiple sets of leaver and restarter dates
--
PROCEDURE store_leaver_restarter_dates
  (p_assignment_id            IN      NUMBER  -- context
  )
IS

  -- Variable Declaration
  l_new_event_itr       NUMBER(5);
  l_leaver_dates_itr    NUMBER(5);
  l_prefix              VARCHAR2(20);
  l_leaver              VARCHAR2(1) := 'N';
  l_leaver_date         DATE := NULL;
  l_restarter           VARCHAR2(1) := 'N';
  l_restarter_date      DATE := NULL;
  l_continue            VARCHAR2(1);
  l_business_group_id   per_all_assignments_f.business_group_id%TYPE;
  l_restarter_ext_emp_cat_cd    VARCHAR2(1);
  l_leaver_ext_emp_cat_cd       VARCHAR2(1);

  -- LVRDATE change:
  l_period_end_date     DATE := NULL ;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'store_leaver_restarter_dates';

BEGIN -- store_leaver_restarter_dates

  debug_enter(l_proc_name);

  -- Bugfix 3073562:GAP1:GAP2
  l_business_group_id := nvl(g_ext_asg_details(p_assignment_id).business_group_id
                            ,g_business_group_id
                            );

  IF p_assignment_id = g_primary_assignment_id THEN

    l_prefix := 'PRIMARY_';
    debug('Processing Primary Assignment',20);

    -- Step 1) Store the first set of leaver and restarter dates in the global collection
    IF g_ext_asg_details(p_assignment_id).leaver_date IS NOT NULL THEN

      debug('Leaver Date Found',10);

      l_new_event_itr := g_asg_events.COUNT+1;
      g_asg_events(l_new_event_itr).event_date        := g_ext_asg_details(p_assignment_id).leaver_date;
      g_asg_events(l_new_event_itr).event_type        := l_prefix||'LEAVER';
      g_asg_events(l_new_event_itr).assignment_id     := p_assignment_id;

      -- Bugfix 3880543:REHIRE : Now also changing the pt asg count
      --   If a part time asg is a leaver then
      -- we also need to decrement the g_part_time_asg_count
      -- when this event is processed
      IF g_ext_asg_details(p_assignment_id).ext_emp_cat_cd = 'P' THEN
        g_asg_events(l_new_event_itr).pt_asg_count_change := -1;
      END IF;

      -- Bugfix 3803760:TERMASG
      g_asg_events(l_new_event_itr).asg_count_change  := -1;

      -- Add this leaver date to the global collection for primary assignments only
      l_leaver_dates_itr := g_primary_leaver_dates.COUNT+1;
      g_primary_leaver_dates(l_leaver_dates_itr).start_date     := g_ext_asg_details(p_assignment_id).start_date;
      g_primary_leaver_dates(l_leaver_dates_itr).leaver_date    := g_ext_asg_details(p_assignment_id).leaver_date;
      g_primary_leaver_dates(l_leaver_dates_itr).assignment_id  := p_assignment_id;

      IF g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL THEN

        debug('Restarter date found',30);

        l_new_event_itr := g_asg_events.COUNT+1;
        g_asg_events(l_new_event_itr).event_date        := g_ext_asg_details(p_assignment_id).restarter_date;
        g_asg_events(l_new_event_itr).event_type        := l_prefix||'RESTARTER';
        g_asg_events(l_new_event_itr).assignment_id     := p_assignment_id;

        -- Bugfix 3880543:REHIRE : Now also changing pt asg count
        --   If a leaver is a restarter then
        -- we also need to increment the g_part_time_asg_count
        -- when this event is processed
        l_restarter_ext_emp_cat_cd := NULL;
        l_restarter_ext_emp_cat_cd := get_ext_emp_cat_cd
                                        (p_assignment_id  => p_assignment_id
                                        ,p_effective_date => g_ext_asg_details(p_assignment_id).restarter_date
                                        );
        IF l_restarter_ext_emp_cat_cd = 'P' THEN
          g_asg_events(l_new_event_itr).pt_asg_count_change := 1;
        END IF;

        -- Bugfix 3803760:TERMASG
        g_asg_events(l_new_event_itr).asg_count_change  := 1;

        l_restarter_date := g_ext_asg_details(p_assignment_id).restarter_date;

        -- Store this restarter date in the global collection for primary assignments
        g_primary_leaver_dates(l_leaver_dates_itr).restarter_date := l_restarter_date;

        -- Step 2) Look for more leaver and restarter dates in a loop and store them
        --              If there is no leaver date or no restarter date
        --              then don't do this step.
        debug('B4 loop, # of events in global :'||to_char(g_asg_events.COUNT),40);

        -- LVRDATE changes
        -- Changed the date passed based on Annual/Periodic Criteria
        debug ('g_extract_type: '|| g_extract_type) ;

        IF g_extract_type = 'TP1' THEN
          l_period_end_date := g_effective_run_date;
        ELSIF g_extract_type = 'TP1P' THEN
          l_period_end_date := g_effective_run_date + 1;
        END IF ;

        debug ('l_period_end_date: '|| l_period_end_date) ;

        LOOP

          -- Call the find leaver proc here.
          l_leaver := chk_is_teacher_a_leaver
                        (p_business_group_id            => l_business_group_id
                        ,p_effective_start_date         => (l_restarter_date+1)
                        -- LVRDATE change: changed the date passed based on Annual/Periodic Criteria
                        ,p_effective_end_date           => l_period_end_date
                        --,p_effective_end_date           => g_effective_run_date
                        ,p_assignment_id                => p_assignment_id
                        ,p_leaver_date                  => l_leaver_date -- OUT
                        );

          IF l_leaver = 'Y' THEN

            l_new_event_itr := g_asg_events.COUNT+1;
            g_asg_events(l_new_event_itr).event_date        := l_leaver_date;
            g_asg_events(l_new_event_itr).event_type        := l_prefix||'LEAVER';
            g_asg_events(l_new_event_itr).assignment_id     := p_assignment_id;

            -- Bugfix 3880543:REHIRE : Now also changing the pt asg count
            --  If a part time asg is a leaver then
            -- we also need to decrement the g_part_time_asg_count
            -- when this event is processed
            l_leaver_ext_emp_cat_cd := NULL;
            l_leaver_ext_emp_cat_cd := get_ext_emp_cat_cd
                                         (p_assignment_id  => p_assignment_id
                                         ,p_effective_date => l_leaver_date
                                         );
            IF l_leaver_ext_emp_cat_cd = 'P' THEN
              g_asg_events(l_new_event_itr).pt_asg_count_change := -1;
            END IF;

            -- Bugfix 3803760:TERMASG
            g_asg_events(l_new_event_itr).asg_count_change  := -1;

            -- Add this leaver date to the global collection for primary assignments only
            l_leaver_dates_itr := g_primary_leaver_dates.COUNT+1;
            g_primary_leaver_dates(l_leaver_dates_itr).start_date     :=
                g_primary_leaver_dates((l_leaver_dates_itr-1)).restarter_date;
            g_primary_leaver_dates(l_leaver_dates_itr).leaver_date    := l_leaver_date;
            g_primary_leaver_dates(l_leaver_dates_itr).assignment_id  := p_assignment_id;

            -- Find a restarter date
            l_restarter := chk_is_leaver_a_restarter
                                (p_business_group_id    => l_business_group_id
                                ,p_effective_start_date => (l_leaver_date + 1)
                                ,p_effective_end_date   => g_effective_run_date
                                ,p_assignment_id        => p_assignment_id
                                ,p_restarter_date       => l_restarter_date -- OUT
                                );

            IF l_restarter = 'Y' THEN
              l_new_event_itr := g_asg_events.COUNT+1;
              g_asg_events(l_new_event_itr).event_date    := l_restarter_date;
              g_asg_events(l_new_event_itr).event_type    := l_prefix||'RESTARTER';
              g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

              -- Bugfix 3880543:REHIRE : Now also changing the pt asg count
              --   If a leaver is a restarter then
              -- we also need to increment the g_part_time_asg_count
              -- when this event is processed
              l_restarter_ext_emp_cat_cd := NULL;
              l_restarter_ext_emp_cat_cd := get_ext_emp_cat_cd
                                          (p_assignment_id  => p_assignment_id
                                          ,p_effective_date => l_restarter_date
                                          );
              IF l_restarter_ext_emp_cat_cd = 'P' THEN
                g_asg_events(l_new_event_itr).pt_asg_count_change := 1;
              END IF;

              -- Bugfix 3803760:TERMASG
              g_asg_events(l_new_event_itr).asg_count_change  := 1;

              -- Store this restarter date in the global collection for primary assignments
              g_primary_leaver_dates(l_leaver_dates_itr).restarter_date := l_restarter_date;

            ELSE -- Restarter not found, exit here
              EXIT;
            END IF; -- l_restarter = 'Y' THEN
            --
          ELSE -- Leaver event not found, exit here
            EXIT;
          END IF; -- l_leaver = 'Y' THEN
          -- Reset leaver and restarter flags
          l_leaver := 'N';
          l_restarter := 'N';
          --
        END LOOP;
        debug('After loop, # of events in global :'||to_char(g_asg_events.COUNT),50);
        --
      END IF; -- g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL THEN
      --
    END IF; -- g_ext_asg_details(p_assignment_id).leaver_date IS NOT NULL THEN
    --
  ELSE -- p_assignment_id = g_primary_assignment_id THEN

    -- This update was done in previous version priory to 06/07/2004
    -- IMPORTANT CHANGE : Currently we do not store leaver/restarter events
    -- for a secondary asg as we are not generating new lines of service for these
    -- events. We only need these leaver/restarter events for deciding the
    -- reporting windows of the secodary asg. and then finding out the other
    -- new line of service events in these windows

    -- Bugfix 3734942 : IMPORTANT update as of 06/07/2004
    --  The above IMPORTANT CHANGE statement is not valid anymore,
    --  we are now storing secondary leaver and restarter dates
    --  as new LOS events. TPA keeps confusing us every time this
    --  issue is raised with them.

    l_leaver := 'N';
    l_restarter := 'N';
    l_prefix := 'SECONDARY_';
    l_continue := 'Y';

    debug('Processing Secondary Assignment',60);

    l_leaver_date := g_ext_asg_details(p_assignment_id).leaver_date;

    -- Store all valid leaver dates
    IF g_ext_asg_details(p_assignment_id).leaver_date IS NOT NULL THEN
-- Bugfix 3880543:REHIRE : Remmoved restriction on secondary leaver restarter
--   dates. They dont hv to be in primary range now
--       AND
--       date_in_prmy_range
--         (p_date => l_leaver_date -- IN OUT
--         ,p_date_type => 'L'
--         ) = 'Y' THEN

      debug('Leaver Date found',70);
      -- Secondary asg is a leaver, store this new LOS event as leaver date +1
      l_new_event_itr := g_asg_events.COUNT+1;

      -- Bugfix 3880543:REHIRE : now storing leaver date itself insted of leaver
      --  date + 1
      g_asg_events(l_new_event_itr).event_date    := l_leaver_date;
      g_asg_events(l_new_event_itr).event_type    := l_prefix||'LEAVER';
      g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

      -- Bugfix 3734942 : If a part time asg is a leaver then
      -- we also need to decrement the g_part_time_asg_count
      -- when this event is processed
      l_leaver_ext_emp_cat_cd := NULL;
      l_leaver_ext_emp_cat_cd := get_ext_emp_cat_cd
                                   (p_assignment_id  => p_assignment_id
                                   ,p_effective_date => l_leaver_date
                                   );
      IF l_leaver_ext_emp_cat_cd = 'P' THEN
        g_asg_events(l_new_event_itr).pt_asg_count_change := -1;
      END IF;

      /* IF g_ext_asg_details(p_assignment_id).ext_emp_cat_cd = 'P' THEN
        g_asg_events(l_new_event_itr).pt_asg_count_change := -1;
      END IF; */

      -- Bugfix 3803760:TERMASG
      g_asg_events(l_new_event_itr).asg_count_change  := -1;

      -- Add this leaver date to the global collection for secondary assignments only
      l_leaver_dates_itr := g_sec_leaver_dates.COUNT+1;
      g_sec_leaver_dates(l_leaver_dates_itr).start_date     := g_ext_asg_details(p_assignment_id).start_date;
      g_sec_leaver_dates(l_leaver_dates_itr).leaver_date    := l_leaver_date;
      g_sec_leaver_dates(l_leaver_dates_itr).assignment_id  := p_assignment_id;

      l_restarter_date := g_ext_asg_details(p_assignment_id).restarter_date;

      -- Check for restarter date
      IF g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL THEN

-- Bugfix 3880543:REHIRE : Remmoved restriction on secondary leaver restarter
--   dates. They dont hv to be in primary range now
--         AND
--         date_in_prmy_range
--             (p_date => l_restarter_date -- IN OUT
--             ,p_date_type => 'R'
--             ) = 'Y' THEN

        debug('Restarter Date found',80);

        -- Secondary asg is a restarter, store this as an event
        l_new_event_itr := g_asg_events.COUNT+1;

        g_asg_events(l_new_event_itr).event_date    := l_restarter_date;
        g_asg_events(l_new_event_itr).event_type    := l_prefix||'RESTARTER';
        g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

        -- Bugfix 3734942 : If a leaver is a restarter then
        -- we also need to increment the g_part_time_asg_count
        -- when this event is processed
        l_restarter_ext_emp_cat_cd := NULL;
        l_restarter_ext_emp_cat_cd := get_ext_emp_cat_cd
                                        (p_assignment_id  => p_assignment_id
                                        ,p_effective_date => l_restarter_date
                                        );
        IF l_restarter_ext_emp_cat_cd = 'P' THEN
          g_asg_events(l_new_event_itr).pt_asg_count_change := 1;
        END IF;

        -- Bugfix 3803760:TERMASG
        g_asg_events(l_new_event_itr).asg_count_change  := 1;

        -- Store this restarter date in the global collection for primary assignments
        g_sec_leaver_dates(l_leaver_dates_itr).restarter_date := l_restarter_date;

      ELSE -- g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL

        -- Find the restarter date between leaver date and end of pension year.
        -- If not found till end of pension year, then we don't
        -- want to look for any more leaver / restarter dates for this secondary asg
        l_restarter := chk_is_leaver_a_restarter
                        (p_business_group_id    => l_business_group_id
                        ,p_effective_start_date => (l_leaver_date + 1)
                        ,p_effective_end_date   => g_effective_run_date
                        ,p_assignment_id        => p_assignment_id
                        ,p_restarter_date       => l_restarter_date -- OUT
                        );

        IF l_restarter = 'Y' THEN
-- Bugfix 3880543:REHIRE : Remmoved restriction on secondary leaver restarter
--   dates. They dont hv to be in primary range now
--           AND
--           date_in_prmy_range
--               (p_date => l_restarter_date -- IN OUT
--               ,p_date_type => 'R'
--               ) = 'Y' THEN

          debug('First restarter date found',90);

          -- Secondary asg is a restarter, store this as an event
          l_new_event_itr := g_asg_events.COUNT+1;

          g_asg_events(l_new_event_itr).event_date    := l_restarter_date;
          g_asg_events(l_new_event_itr).event_type    := l_prefix||'RESTARTER';
          g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

          -- Bugfix 3734942 : If a leaver is a restarter then
          -- we also need to increment the g_part_time_asg_count
          -- when this event is processed
          l_restarter_ext_emp_cat_cd := NULL;
          l_restarter_ext_emp_cat_cd := get_ext_emp_cat_cd
                                        (p_assignment_id  => p_assignment_id
                                        ,p_effective_date => l_restarter_date
                                        );
          IF l_restarter_ext_emp_cat_cd = 'P' THEN
            g_asg_events(l_new_event_itr).pt_asg_count_change := 1;
          END IF;

          -- Bugfix 3803760:TERMASG
          g_asg_events(l_new_event_itr).asg_count_change  := 1;

          -- Store this restarter date in the global collection for primary assignments
          g_sec_leaver_dates(l_leaver_dates_itr).restarter_date := l_restarter_date;

        ELSE

          -- Don't look for any further leaver/restarter dates in this pension year
          l_continue := 'N';

        END IF;


      END IF; -- g_ext_asg_details(p_assignment_id).restarter_date IS NOT NULL
      --
    -- Bugfix 3641851:CBF3b : Moved this END IF down to encompass
    --    the entire leaver and restarter chk logic for secondary
    --    assignment. We should only chk for further leaver and
    --    restarter events if the asg was identified as a
    --    leaver by criteria in the first place, otherwise no need.
    -- END IF; -- g_ext_asg_details(p_assignment_id).leaver_date IS NOT NULL THEN

      -- Set restarter date to leaver date so we can find leaver events between this date
      -- and end of pension year

      -- Bugfix 3641851:CBF3b : Commented out as setting restarter date is not
      --    needed any more coz it is set above and now v r only chking for
      --    further leaver and restarter dates only if the asg was identified
      --    as a leaver by the criteria in the first place, not otherwise.
/*      l_restarter_date := nvl(l_leaver_date
                             ,nvl(g_ext_asg_details(g_primary_assignment_id).restarter_date
                                 ,g_pension_year_start_date
                                 )
                             );
*/
      debug('Restarter Date :'||to_char(l_restarter_date, 'DD/MM/YYYY'), 85);

      IF (l_restarter_date + 2) >= g_pension_year_end_date THEN
        l_continue := 'N';
        debug('Setting l_continue to N',90);
      END IF;

      -- LVRDATE changes
      -- Changed the date passed based on Annual/Periodic Criteria
      debug ('g_extract_type: '|| g_extract_type) ;

      IF g_extract_type = 'TP1' THEN
        l_period_end_date := g_effective_run_date;
      ELSIF g_extract_type = 'TP1P' THEN
        l_period_end_date := g_effective_run_date + 1;
      END IF ;

      debug ('l_period_end_date: '|| l_period_end_date) ;

      -- Look for mor leaver events
      WHILE l_continue = 'Y'
      LOOP

        debug('Start of Loop',100);
        -- Call the find leaver proc here.
        l_leaver := chk_is_teacher_a_leaver
                          (p_business_group_id            => l_business_group_id
                          ,p_effective_start_date         => (l_restarter_date + 1)
                          -- LVRDATE change: changed the date passed based on Annual/Periodic Criteria
                          ,p_effective_end_date           => l_period_end_date
                          --,p_effective_end_date           => g_effective_run_date
                          ,p_assignment_id                => p_assignment_id
                          ,p_leaver_date                  => l_leaver_date -- OUT
                          );

        IF l_leaver = 'Y' THEN
-- Bugfix 3880543:REHIRE : Remmoved restriction on secondary leaver restarter
--   dates. They dont hv to be in primary range now
--           AND
--           date_in_prmy_range
--             (p_date => l_leaver_date -- IN OUT
--             ,p_date_type => 'L'
--             ) = 'Y' THEN

          -- Secondary asg is a leaver, store this new LOS event as leaver date +1
          l_new_event_itr := g_asg_events.COUNT+1;

          -- Bugfix 3880543:REHIRE : now storing leaver date itself insted of leaver
          --  date + 1
          g_asg_events(l_new_event_itr).event_date    := l_leaver_date;
          g_asg_events(l_new_event_itr).event_type    := l_prefix||'LEAVER';
          g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

          -- Bugfix 3734942 : If a part time asg is a leaver then
          -- we also need to decrement the g_part_time_asg_count
          -- when this event is processed
          l_leaver_ext_emp_cat_cd := NULL;
          l_leaver_ext_emp_cat_cd := get_ext_emp_cat_cd
                                       (p_assignment_id  => p_assignment_id
                                       ,p_effective_date => l_leaver_date
                                       );
          IF l_leaver_ext_emp_cat_cd = 'P' THEN
            g_asg_events(l_new_event_itr).pt_asg_count_change := -1;
          END IF;

          -- Bugfix 3803760:TERMASG
          g_asg_events(l_new_event_itr).asg_count_change  := -1;

          -- Add this leaver date to the global collection for secondary assignments only
          l_leaver_dates_itr := g_sec_leaver_dates.COUNT+1;

          IF l_leaver_dates_itr = 1 THEN
            g_sec_leaver_dates(l_leaver_dates_itr).start_date :=
                  g_ext_asg_details(p_assignment_id).start_date;
          ELSE
            g_sec_leaver_dates(l_leaver_dates_itr).start_date :=
                  g_sec_leaver_dates(l_leaver_dates_itr-1).restarter_date;
          END IF;
          --
          g_sec_leaver_dates(l_leaver_dates_itr).leaver_date    := l_leaver_date;
          g_sec_leaver_dates(l_leaver_dates_itr).assignment_id  := p_assignment_id;

          -- Find the restarter date. If not found till end of pension year,
          -- then we don't stop looking
          l_restarter := chk_is_leaver_a_restarter
                          (p_business_group_id    => l_business_group_id
                          ,p_effective_start_date => (l_leaver_date + 1)
                          ,p_effective_end_date   => g_effective_run_date
                          ,p_assignment_id        => p_assignment_id
                          ,p_restarter_date       => l_restarter_date -- OUT
                          );

          IF l_restarter = 'Y' THEN
-- Bugfix 3880543:REHIRE : Remmoved restriction on secondary leaver restarter
--   dates. They dont hv to be in primary range now
--             AND
--             date_in_prmy_range
--                 (p_date => l_restarter_date -- IN OUT
--                 ,p_date_type => 'R'
--                 ) = 'Y' THEN

            -- Secondary asg is a restarter, store this as an event
            l_new_event_itr := g_asg_events.COUNT+1;

            g_asg_events(l_new_event_itr).event_date    := l_restarter_date;
            g_asg_events(l_new_event_itr).event_type    := l_prefix||'RESTARTER';
            g_asg_events(l_new_event_itr).assignment_id := p_assignment_id;

            -- Bugfix 3734942 : If a leaver is a restarter then
            -- we also need to increment the g_part_time_asg_count
            -- when this event is processed
            l_restarter_ext_emp_cat_cd := NULL;
            l_restarter_ext_emp_cat_cd := get_ext_emp_cat_cd
                                        (p_assignment_id  => p_assignment_id
                                        ,p_effective_date => l_restarter_date
                                        );
            IF l_restarter_ext_emp_cat_cd = 'P' THEN
              g_asg_events(l_new_event_itr).pt_asg_count_change := 1;
            END IF;

            -- Bugfix 3803760:TERMASG
            g_asg_events(l_new_event_itr).asg_count_change  := 1;

            -- Store this restarter date in the global collection for primary assignments
            g_sec_leaver_dates(l_leaver_dates_itr).restarter_date := l_restarter_date;

          ELSE

            -- Don't look for any further leaver/restarter dates in this pension year
            l_continue := 'N';
            EXIT;

          END IF;
          --
        ELSE -- not a leaver, exit now

          l_continue := 'N';
          EXIT;

        END IF;
        --
      END LOOP;
      --

      -- Bugfix 3641851:CBF3b : Moved this END IF down to encompass
      --    the entire leaver and restarter chk logic for secondary
      --    assignment. We should only chk for further leaver and
      --    restarter events if the asg was identified as a
      --    leaver by criteria in the first place, otherwise no need.
    END IF; -- g_ext_asg_details(p_assignment_id).leaver_date IS NOT NULL THEN
    --
  END IF; -- p_assignment_id = g_primary_assignment_id THEN

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name);
      RAISE;
END; -- store_leaver_restarter_dates

--
-- Store events for this asg in the PRIMARY asg's validity range
--
PROCEDURE get_events_in_prmy_range
  (p_assignment_id            IN      NUMBER  -- context
  )
IS

  -- Variable Declaration
  -- Bugfix 3873376:ESTB
  l_counter            NUMBER := 0 ;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_events_in_prmy_range';

BEGIN -- get_events_in_prmy_range

  debug_enter(l_proc_name);

  -- If there are leaver restarter events then find events during valid period
  IF g_primary_leaver_dates.COUNT > 0 THEN

    debug('Inside If, event count more than zero',20);

    FOR l_itr IN g_primary_leaver_dates.FIRST..g_primary_leaver_dates.LAST
    LOOP

      l_counter := l_counter + 1 ;
      debug('Inside Loop, calling get_asg_events, l_counter: '||l_counter,30);

      -- Bugfix 3873376:ESTB
      IF (l_counter = 1 ) THEN  --for first period.

        -- BUGFIX 2414035 : Changed p_end_date to leaver date - 1
        -- This is needed coz otherwise the Elected Pension flag
        -- change event gets picked up again, this time as new
        -- line of service event
        get_asg_events(p_assignment_id    => p_assignment_id
                      ,p_start_date       => g_primary_leaver_dates(l_itr).start_date + 1
                      ,p_end_date         => g_primary_leaver_dates(l_itr).leaver_date - 1
                      );
      ELSE  --(l_counter = 1 ) --for other periods.
        -- check from the start date to leaver date -1
        get_asg_events(p_assignment_id    => p_assignment_id
                      ,p_start_date       => g_primary_leaver_dates(l_itr).start_date - 1
                      ,p_end_date         => g_primary_leaver_dates(l_itr).leaver_date - 1
                      );
      END IF ; --(l_counter = 1 )

      IF g_primary_leaver_dates.NEXT(l_itr) IS NULL
         AND
         g_primary_leaver_dates(l_itr).restarter_date IS NOT NULL THEN

        debug('Inside Loop and If, calling get_asg_events last time',40);
        -- Get the events between the restarter date and end of period
        get_asg_events(p_assignment_id  => p_assignment_id -- primary assignment
                      -- Bugfix 3873376:ESTB
                      --,p_start_date     => g_primary_leaver_dates(l_itr).restarter_date + 1
                      --changed from restarter_date +1 to restarter_date
                      ,p_start_date     => g_primary_leaver_dates(l_itr).restarter_date - 1
                      ,p_end_date       => g_effective_run_date
                      );
      END IF;

    END LOOP;

  ELSE -- No leaver restarter events found, so find new line events for the entire year

      debug('No Leaver events, calling get_asg_events for pension year',50);
      get_asg_events(p_assignment_id    => p_assignment_id
                    ,p_start_date       => GREATEST(g_pension_year_start_date
                                                   ,g_ext_asg_details(p_assignment_id).start_date
                                                   ) + 1 -- find events starting from next day
                    ,p_end_date         => g_effective_run_date
                    );

  END IF; -- g_primary_leaver_dates.COUNT > 0 THEN

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name);
      RAISE;
END; -- get_events_in_prmy_range

--
-- Store events for this asg in the SECONDARY asg's validity range
--
PROCEDURE get_events_in_sec_range
  (p_assignment_id            IN      NUMBER  -- context
  )
IS

  -- Variable Declaration
  -- Bugfix 3873376:ESTB
  l_counter            NUMBER := 0 ;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_events_in_sec_range';

BEGIN -- get_events_in_sec_range

  debug_enter(l_proc_name);

  -- If there are leaver restarter events then find events during valid period
  IF g_sec_leaver_dates.COUNT > 0 THEN

    FOR l_itr IN g_sec_leaver_dates.FIRST..g_sec_leaver_dates.LAST
    LOOP

      l_counter := l_counter + 1;
      debug('Start of Loop, calling get_asg_events, l_counter: '||l_counter,20);


      -- Step 1c) Get valid events for each secondary assignment

      -- Bugfix 3873376:ESTB
      IF (l_counter = 1) THEN  --for the first period

        -- BUGFIX 2414035 : Changed p_end_date to leaver date - 1
        -- This is needed coz otherwise the Elected Pension flag
        -- change event gets picked up again, this time as new
        -- line of service event
        get_asg_events(p_assignment_id    => p_assignment_id
                      ,p_start_date       => g_sec_leaver_dates(l_itr).start_date + 1
                      ,p_end_date         => g_sec_leaver_dates(l_itr).leaver_date - 1
                      );
      ELSE --(l_counter = 1) --for the next periods
         get_asg_events(p_assignment_id    => p_assignment_id
                       ,p_start_date       => g_sec_leaver_dates(l_itr).start_date - 1
                       ,p_end_date         => g_sec_leaver_dates(l_itr).leaver_date - 1
                        );
      END IF ; --(l_counter = 1)

      IF g_sec_leaver_dates.NEXT(l_itr) IS NULL
         AND
         g_sec_leaver_dates(l_itr).restarter_date IS NOT NULL THEN

        debug('Inside LOOP and IF, calling get_asg_events for last time',30);
        -- Get the events between the restarter date and end of period
        get_asg_events(p_assignment_id  => p_assignment_id
                      -- Bugfix 3873376:ESTB
                      --changed from restarter_date +1 to restarter_date
                      --,p_start_date     => g_sec_leaver_dates(l_itr).restarter_date + 1
                      ,p_start_date     => g_sec_leaver_dates(l_itr).restarter_date - 1
                      ,p_end_date       => g_effective_run_date
                      );

      END IF;
      --
    END LOOP;

  ELSE -- No leaver restarter events found

    debug('No Leaver Restarter events found, getting events in secondary range',40);
    -- IMP: Find leaver restarter events for the SECONDARY asg
    --  between the PRIMARY asg's validity period as the secondary
    --  asg does not have any leaver/restarter dates.
    --  PS : we do this coz we only report events of the secondary
    --       asg in the validity period of the primary asg.

    -- Bugfix 3641851:CBF3b : Commented out call to get_events_in_prmy_range
    --   This results in sec asg events even when sec asg has not bcome
    --   a teacher. Only get events for sec asgs validity range.
    --   And since there are no leaver and restarter events, the
    --   sec asg is valid from its start date to end of period.
    --get_events_in_prmy_range(p_assignment_id => p_assignment_id
    --                        );

    get_asg_events(p_assignment_id  => p_assignment_id
                  ,p_start_date     => GREATEST(g_pension_year_start_date
                                               ,g_ext_asg_details(p_assignment_id).start_date
                                               ) + 1 -- find events starting from next day
                  ,p_end_date       => g_effective_run_date
                  );


  END IF; -- g_sec_leaver_dates.COUNT > 0 THEN

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name);
      RAISE;
END; -- get_events_in_sec_range

--
-- create_new_lines
--
PROCEDURE create_new_lines
                (p_assignment_id IN per_all_assignments_f.assignment_id%TYPE
                )
IS

  -- Variable Declaration
  l_rec_serial_num      NUMBER(3);
  l_itr                 NUMBER(3);
  l_next_itr            NUMBER(3);
  l_skip_itr            NUMBER(3) := NULL;
  l_next_of_next_itr    NUMBER(3);
  l_prev_asg_count      NUMBER(3);
  l_check_new_los       VARCHAR2(1) := '1';


  -- Rowtype Variable Declaration
  l_main_rec            csr_rslt_dtl%ROWTYPE;
  l_new_rec             csr_rslt_dtl%ROWTYPE;
  l_prev_new_rec        csr_rslt_dtl%ROWTYPE;
  l_event_details       stored_events_type;


  l_proc_name          VARCHAR2(61):=
     g_proc_name||'create_new_lines';

BEGIN -- create_new_lines

  debug_enter(l_proc_name);

  debug('ben_ext_thread.g_ext_rslt_id :'||to_char(ben_ext_thread.g_ext_rslt_id),10);
  debug('g_ext_dtl_rcd_id :'||to_char(g_ext_dtl_rcd_id),20);
  debug('person id :'||to_char(g_ext_asg_details(p_assignment_id).person_id),30);
  debug('assignment id :'||to_char(p_assignment_id),40);

  -- Get the main detail record
  OPEN csr_rslt_dtl
              (p_person_id    => g_ext_asg_details(p_assignment_id).person_id
              ,p_ext_rslt_id  => ben_ext_thread.g_ext_rslt_id
              );
  FETCH csr_rslt_dtl INTO l_main_rec;
  IF csr_rslt_dtl%NOTFOUND THEN
    debug('No Data Found in csr_rslt_dtl', 50);
  END IF;
  CLOSE csr_rslt_dtl;

  debug('Original Start Date :'||l_main_rec.val_13,51);
  debug('Original End Date   :'||l_main_rec.val_14,52);

  --The following bugfix(sort order only) has been undone. The reason being:
  --DE PQP GB TP Type 1 Record Serial Number - Detail Teachers Annual Returns ( England and Wales ) has a
  --maximum length of 1 character. So the changes done in 115.99 are being reverted here.

     -- **************************
        -- Set the sort order. Seq 26 for record serial number.
        -- bug fix : 4926143
        -- this is being done as this column in the table is of varchar2 type, due to which
        -- sorting using order_by was incorrect when values are like 1,2,3,4....,9,10,11,12.
        -- For example, 1,2..,9,10,11,12 gets sorted as 1,10,11,12,2,3...,9.
        -- To fix this issue, the value in the thrd_sort_val is being stored as 3 digit numbers,
        -- starting from 001, 002 and so on.

        -- l_main_rec.thrd_sort_val := ltrim(rtrim(to_char(to_number(l_main_rec.val_26),'009')));
     -- **************************

  -- reintroduced from version 115.98
  l_main_rec.thrd_sort_val := l_main_rec.val_26;


  -- Also, increment the object version number
  l_main_rec.object_version_number := nvl(l_main_rec.object_version_number,0) + 1;

  -- Assign the main record to the previous record variable
  -- We do this so even if there are not new line events,
  -- i.e. g_asg_events.COUNT = 0, if there is a restarter date,
  -- then we need a new line for this. Doing this assignment will
  -- ensure that the new restarter line copies from the latest record.
  l_prev_new_rec := l_main_rec;

  --TERM_LSP:global value set to N for checking terminated employees
  g_terminated_person := 'N';

  -- Have we found any events?
  IF g_asg_events.COUNT > 0 THEN

    debug('Number of events to process :'||to_char(g_asg_events.COUNT), 60);

    -- Bugfix 3803760:TERMASG
    debug('Before : g_asg_count :'||to_char(g_asg_count), 62);

    /* Commenting out as we will do this in the loop below
    l_prev_asg_count := g_asg_count;
    g_asg_count := g_asg_count
                   +
                   nvl(g_asg_events(g_asg_events.FIRST).asg_count_change
                      , 0);

    debug('After : g_asg_count :'||to_char(g_asg_count), 63);

    debug('B4 g_part_time_asg_count :'||to_char(g_part_time_asg_count), 64);
    g_part_time_asg_count := g_part_time_asg_count
                             +
                             nvl(g_asg_events(g_asg_events.FIRST).pt_asg_count_change, 0);

    debug('After g_part_time_asg_count :'||to_char(g_part_time_asg_count), 65);
    */

    -- If the first event is a primary leaver event, then we need
    -- a W on withdrawal conf and
    -- the end date should be set as the event date
    IF (g_asg_count
        +
        nvl(g_asg_events(g_asg_events.FIRST).asg_count_change, 0)
       ) <= 0 THEN

      -- Assign end date(seq 14) to the main record
      l_main_rec.val_14  := to_char(g_asg_events(g_asg_events.FIRST).event_date,'DDMMYY');

      debug('Setting W on main record',70);
      l_main_rec.val_15 := 'W';

    ELSE

      -- Assign end date(seq 14) to the main record
      -- Bugfix 3880543:REHIRE : Set end date to event date if this
      --  is a leaver event otherwise event date less one
      IF INSTR(nvl(g_asg_events(g_asg_events.FIRST).event_type,'XX')
              ,'LEAVER'
              ) > 0 THEN
        l_main_rec.val_14  := to_char(g_asg_events(g_asg_events.FIRST).event_date,'DDMMYY');
      ELSE
        l_main_rec.val_14  := to_char(g_asg_events(g_asg_events.FIRST).event_date - 1,'DDMMYY');
      END IF;

      -- Clear the Withdrawal conf flag
      l_main_rec.val_15 := ' ';

    END IF;



    debug('g_terminated_person  val : '||g_terminated_person,74);
    debug('g_asg_events(g_asg_events.FIRST).event_type: '|| (g_asg_events(g_asg_events.FIRST).event_type),75 );
    IF INSTR(nvl(g_asg_events(g_asg_events.FIRST).event_type,'XX'),'PQP_GB_TP_ASG_STATUS') > 0 THEN

      g_terminated_person := 'Y';

      debug('Inside event check g_terminated_person  val : '||g_terminated_person);
    ELSE
     g_terminated_person := 'N';
    END IF;

    debug('After event check g_terminated_person  val : '||g_terminated_person);

    debug('Main Record Start Date :'||l_main_rec.val_13,80);
    debug('Main Record End Date   :'||l_main_rec.val_14,90);

    -- Now recalculate the data elements
    recalc_data_elements
          (p_dtl_rec              => l_main_rec -- IN OUT
          ,p_rec_type             => 'MAIN'
          ,p_event_details        => NULL
          ,p_assignment_id        => p_assignment_id
          );

    debug('Main Record Start Date :'||l_main_rec.val_13,100);
    debug('Main Record End Date   :'||l_main_rec.val_14,110);

    -- Update the main record
--    upd_rslt_dtl(p_dtl_rec => l_main_rec);

    -- Assign the main record to the previous record variable
    l_prev_new_rec := l_main_rec;
    l_check_new_los := '1';

    -- Process each event in the global collection
    FOR l_itr IN g_asg_events.FIRST..g_asg_events.LAST
    LOOP -- through the sorted stored events

      debug('Start of Loop',120);

      -- Bugfix 3803760:TERMASG
      debug('B4 g_asg_count :'||to_char(g_asg_count), 122);
      debug('B4 g_part_time_asg_count :'||to_char(g_part_time_asg_count), 123);
      l_prev_asg_count := g_asg_count;
      --TERM_LSP: global value set to N for checking terminated employees
      g_terminated_person := 'N';
      debug('g_asg_events(l_itr).asg_count_change :' || to_char(g_asg_events(l_itr).asg_count_change),124);
      debug('g_asg_events(l_itr).pt_asg_count_change :' || to_char(g_asg_events(l_itr).pt_asg_count_change),125);
      -- Check if this event needs to be skipped
      IF (l_skip_itr IS NULL
          OR
          l_itr <> l_skip_itr
         ) THEN

        g_asg_count := g_asg_count
                       +
                       nvl(g_asg_events(l_itr).asg_count_change
                          , 0);

        g_part_time_asg_count := g_part_time_asg_count
                                 +
                                 nvl(g_asg_events(l_itr).pt_asg_count_change
                                    , 0);

        debug('After g_asg_count :'||to_char(g_asg_count), 124);
        debug('After g_part_time_asg_count :'||to_char(g_part_time_asg_count), 125);

      END IF;

      -- Eliminate duplicate changes as we will be re-calculating all
      -- data elements that are non-static
      -- Also eliminate the event if its a primary leaver event as
      -- we process these when deciding on withdrawal conf
      -- Now we also skip events if they are set in l_skip_itr
      IF (l_itr = g_asg_events.FIRST -- The event is the first one
          OR -- the date is not the same as previous event date
          g_asg_events(l_itr).event_date <>
           g_asg_events(g_asg_events.PRIOR(l_itr)).event_date
         )
         AND
         (g_asg_count > 0
         )
         AND
         -- Check if this event needs to be skipped
         (l_skip_itr IS NULL
          OR
          l_itr <> l_skip_itr
         ) THEN

        debug('Processing Event Date :'||to_char(g_asg_events(l_itr).event_date,'DD/MM/YYYY'),130);
        debug('           Event Type :'||g_asg_events(l_itr).event_type,140);

        -- Copy the main or previous line of service record
        l_new_rec := l_prev_new_rec;

        -- Set the start date(seq number 13)
        -- Bugfix 3880543:REHIRE : If the current event is a leaver
        --   event then we need an event date + 1 otherwise event date
        IF INSTR(nvl(g_asg_events(l_itr).event_type,'XX')
                ,'LEAVER'
                ) > 0 THEN
          l_new_rec.val_13 := to_char(g_asg_events(l_itr).event_date + 1,'DDMMYY');
        ELSE
          l_new_rec.val_13 := to_char(g_asg_events(l_itr).event_date,'DDMMYY');
        END IF;

	--Bugfix 9441225 --
	-- if last event is asg leaver and it is on 31-mar-YYYY
        -- then new line start date will be '1-apr-yyyy'
        -- hence added check to prevent recalulation on wrong dates

        if to_date(l_new_rec.val_13, 'DDMMYY') > g_effective_run_date then
        debug('Exiting from events loop..', 140.1);
        Exit;
        End if;
        ------ End Bugfix 9441225--
        l_next_itr := g_asg_events.NEXT(l_itr);

        -- Bugfix 3880543:REHIRE :
        -- We need to pre-Evaluate the next event
        --  We might want to skip the next event if the
        --  next event date is equal to current event date+1
        --  as it could result in a line with start date
        --  greater than end date. We only want to skip
        --  if the next event will not result in a primary
        --  leaver event, meaning it will not coz g_asg_count
        --  to become zero.
        IF l_next_itr IS NOT NULL
           AND
           ( (g_asg_count
              +
              nvl(g_asg_events(l_next_itr).asg_count_change, 0)
             ) > 0
           ) THEN


          debug('Pre-Evaluating next event',141);
          -- The start date greater than end data problem
          -- can only occur in the following situation
          -- If the current event is a (new line) leaver event AND
          -- Next event is NOT a leaver event AND
          -- Next event date is EQUAL to current event date + 1
          IF (INSTR(nvl(g_asg_events(l_itr).event_type,'XX')
                  ,'LEAVER'
                  ) > 0
             )
             AND
             (INSTR(nvl(g_asg_events(l_next_itr).event_type,'XX')
                   ,'LEAVER'
                   ) <= 0
             )
             AND
             ( g_asg_events(l_itr).event_date + 1
               =
               g_asg_events(l_next_itr).event_date
             ) THEN

            debug('Pre-Evaluate: Need to skip next event',142);
            -- We want to skip the next event, Set skip itr
            l_skip_itr := l_next_itr;

            -- Since we have set l_skip_itr, we need to adjust the
            -- g_asg_count and g_part_time_asg_count now rather
            -- than later coz we need the updated globals before
            -- recalc_data_elements is called
            l_prev_asg_count := g_asg_count;

            g_asg_count := g_asg_count
                           +
                           nvl(g_asg_events(l_skip_itr).asg_count_change
                              , 0);

            g_part_time_asg_count := g_part_time_asg_count
                                     +
                                     nvl(g_asg_events(l_skip_itr).pt_asg_count_change
                                        , 0);

            debug('After g_asg_count :'||to_char(g_asg_count), 143);
            debug('After g_part_time_asg_count :'||to_char(g_part_time_asg_count), 144);

            -- Get next-of-next and treat it as the next event
            l_next_of_next_itr := g_asg_events.NEXT(l_next_itr);
            l_next_itr := l_next_of_next_itr;

          ELSE
            l_skip_itr := NULL;
          END IF;

        ELSE -- Pre-Evaluating

          debug('Pre-Evaluate: Last event OR next causing primary leaver',145);
          -- UnSet skip itr
          l_skip_itr := NULL;

        END IF; -- Pre-Evaluating

        -- Now doing the real processing
        IF l_next_itr IS NOT NULL THEN

          debug('Next event exists',146);

          -- Also check if the next event is a Primary Leaver event
          IF -- If the next event will cause g_asg_count to become zero
             ( (g_asg_count
                +
                nvl(g_asg_events(l_next_itr).asg_count_change, 0)
               ) <= 0
             ) THEN

            -- Set the end date
            l_new_rec.val_14 := to_char(g_asg_events(l_next_itr).event_date,'DDMMYY');

            debug('Setting W on New record',150);
            -- And the withdrawal conf flag
            l_new_rec.val_15 := 'W';

          ELSE

            -- Set the end date
            -- Bugfix 3880543:REHIRE : If the next event is a leaver
            --   event then we need an event date otherwise
            --   event date less one
            IF INSTR(nvl(g_asg_events(l_next_itr).event_type,'XX')
                ,'LEAVER'
                ) > 0 THEN
              l_new_rec.val_14 := to_char(g_asg_events(l_next_itr).event_date,'DDMMYY');
            ELSE
              l_new_rec.val_14 := to_char(g_asg_events(l_next_itr).event_date -1,'DDMMYY');
            END IF;

            -- And the withdrawal conf flag
            l_new_rec.val_15 := ' ';

          END IF;

          debug('Check if ASG_STATUS event');
          debug('g_terminated_person  val : '||g_terminated_person,170);
          debug('g_asg_events.current_event_type: '|| (g_asg_events(l_itr).event_type),175 );
          debug('g_asg_events.next_event_type: '|| (g_asg_events(l_next_itr).event_type),180 );
          IF INSTR(nvl(g_asg_events(l_next_itr).event_type,'XX'),'PQP_GB_TP_ASG_STATUS') > 0 THEN

            g_terminated_person := 'Y';

           debug('Inside event check g_terminated_person  val : '||g_terminated_person);
          ELSE
            g_terminated_person := 'N';
          END IF;
          debug('After event check g_terminated_person  val : '||g_terminated_person);

        ELSE -- This is the last event

          debug('This is the last event',160);

          -- Set the end date as run end date
          l_new_rec.val_14 := to_char(g_effective_run_date,'DDMMYY');

          -- Reset the Withdrawal conf flag
          l_new_rec.val_15 := ' ';

        END IF; -- l_next_itr IS NOT NULL THEN


  --The following bugfix(sort order only) has been undone. The reason being:
  --DE PQP GB TP Type 1 Record Serial Number - Detail Teachers Annual Returns ( England and Wales ) has a
  --maximum length of 1 character. So the changes done in 115.99 are being reverted here.

     -- **************************
        -- Record serial number
        -- bug fix : 4926143
        -- this is being done as this column in the table is of varchar2 type, due to which
        -- sorting using order_by was incorrect when values are like 1,2,3,4....,9,10,11,12.
        -- For example, 1,2..,9,10,11,12 gets sorted as 1,10,11,12,2,3...,9.
        -- To fix this issue, the value in the thrd_sort_val is being stored as 3 digit numbers,
        -- starting from 001, 002 and so on.

        -- l_new_rec.val_26 := ltrim(rtrim(to_char((to_number(l_prev_new_rec.val_26) + 1),'009')));
     -- **************************

        -- reintroduced from version 115.98
        l_new_rec.val_26 := to_char(to_number(l_prev_new_rec.val_26) + 1);


        -- Set the sorting order
        l_new_rec.thrd_sort_val := l_new_rec.val_26;





        -- Now recalculate the data elements in this new record
        recalc_data_elements
                   (p_dtl_rec              => l_new_rec -- IN OUT
                   ,p_rec_type             => 'NEW'
                   ,p_event_details        => g_asg_events(l_itr)
                   ,p_assignment_id        => p_assignment_id
                   );


        debug('New Record Start Date :'||l_new_rec.val_13,120);
        debug('New Record End Date   :'||l_new_rec.val_14,130);

        IF INSTR(nvl(g_asg_events(l_itr).event_type, 'XX'),'PQP_GB_TP_ELEMENT_ENTRY') > 0 THEN --8616289
        debug('This is element entry change event',131);
	OPEN csr_chk_los_change
                (p_prev_new_rec    =>  l_prev_new_rec
                ,p_new_rec        => l_new_rec
		);
        FETCH csr_chk_los_change INTO l_check_new_los;
        CLOSE csr_chk_los_change;

/*	If l_new_rec.val_15 ='W' and l_prev_new_rec.val_15 = 'W' THEN -- change for bug 7173168
         l_check_new_los := '1';
        end if ;*/-- this part of code is not needed

	   IF l_check_new_los <> '0' THEN
            -- Update the previous record
            upd_rslt_dtl(p_dtl_rec => l_prev_new_rec);

            -- Store this new line
            ins_rslt_dtl(p_dtl_rec => l_new_rec -- IN OUT
                      );
           END IF;
      ELSE
           debug('This is not a element entry change event',132);
            -- Update the previous record
            upd_rslt_dtl(p_dtl_rec => l_prev_new_rec);

            -- Store this new line
            ins_rslt_dtl(p_dtl_rec => l_new_rec -- IN OUT
                      );
      END IF;

     --  CLOSE csr_chk_los_change;                          -- rahul supply
        -- Now assign the current new record to the previous new record
--        l_prev_new_rec := l_new_rec;

        debug('g_effective_run_date :' || to_char(g_effective_run_date),140);

      --   debug('l_check_new_los :'||l_check_new_los,141);

       IF INSTR(nvl(g_asg_events(l_itr).event_type, 'XX'),'PQP_GB_TP_ELEMENT_ENTRY') > 0 THEN --8616289
       IF l_check_new_los <> '0' THEN
           l_prev_new_rec := l_new_rec;
         debug('l_check_new_los :'||l_check_new_los,142);
	ELSE
           debug('l_check_new_los :'||l_check_new_los,143);

           l_prev_new_rec.val_14 := l_new_rec.val_14;

           debug('val_14 :'||l_prev_new_rec.val_14,143);

            debug('l_new_rec.val_19 :'||l_new_rec.val_19,144);

           debug('l_prev_new_rec.val_19 :'||l_prev_new_rec.val_19,145);

	   if l_prev_new_rec.val_19 = 1 and l_new_rec.val_19 = 1 THEN     -- Bug 8946616
                  l_prev_new_rec.val_19 := 1;
           ELSE
        	  l_prev_new_rec.val_19 := l_prev_new_rec.val_19 + l_new_rec.val_19;
           END IF;

          debug('val_19 :'||l_prev_new_rec.val_19,146);

		    IF sign(l_prev_new_rec.val_19) = -1 THEN
		       l_prev_new_rec.val_19 := '-'|| lpad(abs(l_prev_new_rec.val_19),5,'0');
		    ELSE
		       l_prev_new_rec.val_19 := lpad(l_prev_new_rec.val_19,6,'0');
		    END IF;
          debug('val_19 :'||l_prev_new_rec.val_19,147);
	   IF l_next_itr IS NULL THEN
	      debug('Before Update ',147);
              upd_rslt_dtl(p_dtl_rec => l_prev_new_rec);
	      debug('After Update ',147);
           END IF;
	END IF;
      ELSE
          l_prev_new_rec := l_new_rec;
          debug('l_check_new_los :'||l_check_new_los,148);
      END IF;

	l_check_new_los := '1';                   -- rahul supply

      END IF; -- if this date <> last date to eliminate duplicates and primary leaver
      --
    END LOOP; -- through the sorted stored events
    --
    -- update the last record
    upd_rslt_dtl(p_dtl_rec => l_prev_new_rec);	      -- rahul supply

  END IF; -- g_asg_events.COUNT > 0 THEN

  debug_exit(l_proc_name);

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug('SQLCODE :'||to_char(SQLCODE), 140);
    debug('SQLERRM :'||SQLERRM, 150);
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- create_new_lines

-- 8iComp Changes: IMORTANT NOTE
-- Changing he following function to use the 8iComp code.
-- Now it does not reference g_asg_leaver_events_table global
-- but references g_per_asg_leaver_dates global
-- and calls get_g_per_asg_leaver_dates to get the
-- collection for Leaver-Restarter dates for an assignment
--
-- Extended Criteria to generate new lines of service
--
FUNCTION create_service_lines
  (p_assignment_id            IN      NUMBER  -- context
  ) RETURN VARCHAR2
IS

  -- Variable Declaration
  l_curr_asg_id         per_all_assignments_f.assignment_id%TYPE;
  l_prev_asg_id         per_all_assignments_f.assignment_id%TYPE;
  l_sec_asg_id          per_all_assignments_f.assignment_id%TYPE;

  -- Rowtype Variable Declaration
  l_all_sec_asgs        t_sec_asgs_type;

  --l_sec_asg_details   csr_sec_assignments%ROWTYPE := NULL;


  -- 8iComp
  l_insert_rec          NUMBER;
  l_record_count        NUMBER;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'create_service_lines';

BEGIN -- create_service_lines

  debug_enter(l_proc_name);

  -- Step 0) Reset the global variable, it may contain events for the previous person processed
  --   If events will be stored in this global by the basic criteria, then the following
  --   line will need to be commented out
  --   Also, set the global variable for primary assignment id

  -- Bugfix 3073562:GAP10
  -- Commenting out this line as we are now storing LEA Estb to
  -- LEA Estb location change as a new line of service event frm
  -- proc chk_is_teacher_a_leaver
  -- The collection is now reset from the periodic and annual criteria.
  -- g_asg_events.DELETE;
  debug('Count in g_asg_events :'||to_char(g_asg_events.COUNT), 20);

  g_primary_leaver_dates.DELETE;
  g_primary_assignment_id := p_assignment_id;

  -- Bugfix 3803760:FTSUPPLY : Resetting override ft asg id
  --  This is needed coz if for the frist line one of
  --  the secondary was FT, then chk_report_assignment
  --  will return N for the primary asg below and
  --  we will not pick up any new line and leaver restarter
  --  events for the primary asg
  g_override_ft_asg_id := NULL;
  g_tab_sec_asgs.DELETE;

  -- Step 1) Get events( dates, type, assignment id)
  -- This procedure stores into a global collection containing the following :
  -- a) event_date -> to be sorted ascending later
  -- b) event_type -> helps in deciding which columns on the
  --                    report need a refresh
  -- c) assignment_id -> assignment id
  --

  -- Step 1a) Get valid events for primary assignment

  -- Bugfix 3073562:GAP6
  -- But only do this if the primary asg is a teacher
  -- and is to be reported
  IF chk_report_assignment
       (p_assignment_id            => p_assignment_id
       ,p_secondary_assignment_id  => l_sec_asg_id
       ) = 'Y' THEN

   -- PER_LVR change
   -- for PERIODIC REPORT : Logic to store leaver restarter dates for the assignments
   -- has been moved to criteria code.
   -- Now store these dates, only if the Extract type is ANUAL : 'TP1'
   -- for annual report we are calling chk_person_leaver when criteria is Exclude
    IF g_extract_type = 'TP1' and nvl(g_reporting_mode,'EXCLUDE') = 'INCLUDE' THEN
     -- Store all the leaver and restarter dates for the primary asg

     store_leaver_restarter_dates
          (p_assignment_id => p_assignment_id
          );

      -- MULT-LR changes
      -- g_asg_leaver_events_table(p_assignment_id) := g_primary_leaver_dates ;

      --8iComp
      debug('inserting in new collection...', 22);
      l_insert_rec := set_g_per_asg_leaver_dates
                       ( p_leaver_dates_type => g_primary_leaver_dates) ;

      debug('l_insert_rec: '|| l_insert_rec, 24) ;
     -- 8iComp
   ELSE
     debug ('Leaver Restarter Dates are already stored ...',30);
     -- QAB1: restore the leaver dates collection.
     debug ('restoring the collection temporarily for primary dates',40) ;

     -- 8iComp chagnes
     --g_primary_leaver_dates := g_asg_leaver_events_table(p_assignment_id) ;

     l_record_count :=  get_g_per_asg_leaver_dates
                            ( p_assignment_id     => p_assignment_id
                             ,p_leaver_dates_type => g_primary_leaver_dates
                             ) ;

     debug('l_record_count: '|| l_record_count, 45) ;

     -- 8iComp Changes


   END IF;

   -- Store new line of service events for the primary assignment
    get_events_in_prmy_range(p_assignment_id => p_assignment_id
                            );

  ELSE

    -- Bugfix 3880543:REHIRE
    -- Setting the sec asg id as the primary asg
    -- We will treat the sec asg as promary so all
    --  leaver restarter events for this secondary
    --  will b treated as primary leaver restarter events
    g_primary_assignment_id := l_sec_asg_id;

  END IF; -- IF chk_report_assignment

  -- Step 1b) Get secondary assignments
  l_all_sec_asgs := get_all_secondary_asgs
                     (p_primary_assignment_id   => p_assignment_id
                     --changed from start_date to teacher_start_date.
                     ,p_effective_date          => g_ext_asg_details(p_assignment_id).teacher_start_date
                     );


  -- Have we found any secondary assignments?
  --IF l_all_sec_asgs IS NOT NULL THEN, cannot use is NOT NULL with index by tables
  IF l_all_sec_asgs.COUNT > 0 THEN

    l_curr_asg_id := l_all_sec_asgs.FIRST;

    WHILE l_curr_asg_id IS NOT NULL
    LOOP

      debug('Processing Secondary Asg :'||to_char(l_curr_asg_id),50);
      -- Get the asg details, not needed currently,
      -- will uncomment if needed,both here and in declaration
      --l_sec_asg_details := l_all_sec_asgs(l_curr_asg_id);

      -- PER_LVR change
      -- for PERIODIC REPORT : Logic to store leaver restarter dates for the assignments
      -- has been moved to criteria code.
      -- Now store these dates, only if the Extract type is ANUAL : 'TP1'
      -- for annual report we are calling chk_person_leaver when criteria is Exclude
     IF g_extract_type = 'TP1' and nvl(g_reporting_mode,'EXCLUDE') = 'INCLUDE' THEN
        -- Delete the global for lever restarter dates for secondary asg.
        g_sec_leaver_dates.DELETE;

        -- Store all the leaver and restarter dates for the secondary asg
        store_leaver_restarter_dates
                (p_assignment_id => l_curr_asg_id
                );

        -- MULT-LR changes
        IF l_curr_asg_id = g_primary_assignment_id THEN
          --g_asg_leaver_events_table(l_curr_asg_id) := g_primary_leaver_dates ;

          --8iComp
          debug('inserting in new collection...', 22);
          l_insert_rec := set_g_per_asg_leaver_dates
                       ( p_leaver_dates_type => g_primary_leaver_dates) ;

          debug('l_insert_rec: '|| l_insert_rec, 24) ;
          -- 8iComp
        ELSE
          --g_asg_leaver_events_table(l_curr_asg_id) := g_sec_leaver_dates ;
          --8iComp
          debug('inserting in new collection...', 22);
          l_insert_rec := set_g_per_asg_leaver_dates
                       ( p_leaver_dates_type => g_sec_leaver_dates) ;

          debug('l_insert_rec: '|| l_insert_rec, 24) ;
          -- 8iComp
        END IF;

      ELSE --g_extract_type = 'TP1'
        debug ('Leaver Restarter Dates are already stored ...',60);

        -- QAB1: Restore the leaver_dates collection from the
        -- leaver events table as this is required in the following functions
        -- get_events_in_prmy_range/get_events_in_sec_range

        IF l_curr_asg_id = g_primary_assignment_id THEN
          debug ('restoring the collection temporarily for primary dates',70) ;

          -- g_primary_leaver_dates := g_asg_leaver_events_table(l_curr_asg_id) ;
          -- 8iComp
          l_record_count :=  get_g_per_asg_leaver_dates
                            ( p_assignment_id     => p_assignment_id
                             ,p_leaver_dates_type => g_primary_leaver_dates
                             ) ;

          debug('l_record_count: '|| l_record_count, 45) ;

          -- 8iComp Changes

        ELSE
          debug ('restoring the collection temporarily for Secondary dates',80) ;
          -- g_sec_leaver_dates := g_asg_leaver_events_table(l_curr_asg_id) ;

          -- 8iComp
          -- 8iComp
          l_record_count :=  get_g_per_asg_leaver_dates
                            ( p_assignment_id     => l_curr_asg_id
                             ,p_leaver_dates_type => g_primary_leaver_dates
                             ) ;

          debug('l_record_count: '|| l_record_count, 45) ;

          -- 8iComp Changes

        END IF;

      END IF; --g_extract_type = 'TP1'


      -- Bugfix 3880543:REHIRE
      -- If curr sec asg is being treated as the primary then
      --  store events in primary range otherwise in sec range
      IF l_curr_asg_id = g_primary_assignment_id THEN

        -- Store new line of service events for the primary assignment
        get_events_in_prmy_range(p_assignment_id => l_curr_asg_id
                                );
      ELSE

        -- Store new line of service events for the SECONDARY assignment
        get_events_in_sec_range(p_assignment_id => l_curr_asg_id
                               );
      END IF;

      -- Assign the current asg id to prev asg id
      -- and reset curr asg id, ready for the next one
      l_prev_asg_id := l_curr_asg_id;
      l_curr_asg_id := NULL;

      -- Get next secondary assignment
      l_curr_asg_id := l_all_sec_asgs.NEXT(l_prev_asg_id);

    END LOOP; -- l_curr_asg_id IS NOT NULL
    --
  END IF; -- l_all_sec_asgs.COUNT > 0 THEN

  -- MULT-LR --
  -- print all the events stored so far.
  -- Print the Events table only if Debug is switched on.
  IF NVL(g_trace,'N') = 'Y' THEN
    print_events_table ();
  END IF;

  -- Bugfix 3880543:REHIRE
  -- Currently there is not requirement for resetting the global
  --  g_primary_assignment_id to the original primary asg id as it
  --  is not used beyond this point. If in the future we do need
  --  this global beyond this point, uncomment the following statement

  -- MULT-LR:  uncommented the following line.
   g_primary_assignment_id := p_assignment_id;

  -- Step 1d) Sort events by Ascending Date if we have found more than 1 events
  IF g_asg_events.COUNT > 1 THEN
    sort_stored_events;
  END IF;

  -- Step 2) Create new lines of service for each event.
  --            This proc also updates the main record
  create_new_lines
    (p_assignment_id    => p_assignment_id
    );


  -- Step 3) Reset the global variable containing events for this person
  g_asg_events.DELETE;

  debug_exit(l_proc_name);

  RETURN 'DELETE';

EXCEPTION
    WHEN OTHERS THEN

      -- Reset the global variable containing events for this person
      g_asg_events.DELETE;

      debug('SQLCODE :'||to_char(SQLCODE), 40);
      debug('SQLERRM :'||SQLERRM, 50);

      debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
      RAISE;
END; -- create_service_lines
--
-- del_dummy_recs
--
PROCEDURE del_dummy_recs
IS

  -- Variable Declaration
  l_ext_dtl_rcd_id      ben_ext_rcd.ext_rcd_id%TYPE;

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'del_dummy_recs';

BEGIN -- del_dummy_recs

  debug_enter(l_proc_name);

  -- Get the record id for the Type 1 Hidden Detail record
  OPEN csr_ext_rcd_id(p_hide_flag       => 'Y'
                     ,p_rcd_type_cd     => 'D'
                     );
  FETCH csr_ext_rcd_id INTO l_ext_dtl_rcd_id;
  CLOSE csr_ext_rcd_id;

  DELETE
  FROM ben_ext_rslt_dtl dtl
  WHERE dtl.ext_rslt_id = ben_ext_thread.g_ext_rslt_id
    AND dtl.ext_rcd_id = l_ext_dtl_rcd_id
    AND dtl.val_01 = 'DELETE';

  debug('Number of Dummy Records Deleted :'||to_char(SQL%ROWCOUNT));

  debug_exit(l_proc_name);
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
  RAISE;
END; -- del_dummy_recs

--
-- type1_post_proc_rule
--
FUNCTION type1_post_proc_rule
                (p_ext_rslt_id  IN ben_ext_rslt_dtl.ext_rslt_id%TYPE
                ) RETURN VARCHAR2
IS

  -- Variable Declaration

  -- Rowtype Variable Declaration

  l_proc_name          VARCHAR2(61):=
     g_proc_name||'type1_post_proc_rule';

BEGIN -- type1_post_proc_rule

  debug_enter(l_proc_name);

  -- Step 1) Delete detail records which are not being displayed.
  del_dummy_recs;

  -- Step 2) Re-calc total in the trailer
  -- Not needed as now hv modified the SQL in Type 4 pkg which gets the
  -- total number of records to ignore all details records which have
  -- 'DELETE' in column val_01

  debug_exit(l_proc_name);
  RETURN 'T1';

EXCEPTION
    WHEN OTHERS THEN
      debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
      RAISE;
END; -- type1_post_proc_rule

--
-- chk_rate_change_affects_asg
--
FUNCTION chk_rate_change_affects_asg
                (p_assignment_id        IN NUMBER
                ,p_rate_id              IN NUMBER
                ,p_effective_date       IN DATE
                ) RETURN BOOLEAN IS

  CURSOR c_rates IS
  SELECT * FROM pay_rates
  WHERE rate_id = p_rate_id;

  CURSOR c_ele_attr(p_element_type_id IN NUMBER) IS
  SELECT petei.eei_information2 pay_source_value
        ,petei.eei_information3 Qualifier
  FROM pay_element_type_extra_info petei
  WHERE petei.element_type_id = p_element_type_id
    AND petei.eei_information_category  ='PQP_UK_ELEMENT_ATTRIBUTION';

  CURSOR c_element_entry(p_element_type_id IN NUMBER) IS
  SELECT pee.element_entry_id
  FROM pay_element_links_f pel
      ,pay_element_entries_f pee
  where pel.element_type_id = p_element_type_id
    and p_effective_date between pel.effective_start_date
                             and pel.effective_end_date
    and pee.element_link_id = pel.element_link_id
    and p_effective_date between pee.effective_start_date
                             and pee.effective_end_date
    and pee.assignment_id = p_assignment_id;



  l_asg_affected        BOOLEAN := FALSE;
  l_itr                 NUMBER;
  l_current             NUMBER;

  l_rate_dets           c_rates%ROWTYPE;
  l_ele_attr            c_ele_attr%ROWTYPE;
  l_element_entry       c_element_entry%ROWTYPE;

  l_pet_ids             t_ele_ids_from_bal;

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_rate_change_affects_asg';

BEGIN -- chk_rate_change_affects_asg

  debug_enter(l_proc_name);

  -- Get the Rate Details
  OPEN c_rates;
  FETCH c_rates INTO l_rate_dets;
  CLOSE c_rates;

  -- Replace rate type of G with GR as rates history stores GR
  IF l_rate_dets.rate_type = 'G' THEN
    debug(l_proc_name, 10);
    l_rate_dets.rate_type := 'GR';
  END IF;

  -- For each Element Type id, check its Element Attribution
  -- to see if it has the Rate Type being evaluated
  l_itr := 1;
  l_current := g_tab_sal_ele_ids.FIRST;

  WHILE l_itr <= g_tab_sal_ele_ids.COUNT
  LOOP -- through the element type ids in Salary Balance

    debug(l_proc_name, 20);
    -- Get the element attribution info for this element type id
    OPEN c_ele_attr(p_element_type_id => g_tab_sal_ele_ids(l_current).element_type_id);
    FETCH c_ele_attr INTO l_ele_attr;

    IF c_ele_attr%FOUND
       AND -- The rate Type matches
       l_ele_attr.pay_source_value = l_rate_dets.rate_type
       AND -- The Rate Name also matches
       l_ele_attr.qualifier = l_rate_dets.name
    THEN

      debug(l_proc_name, 30);
      -- Add this element type id to list of valid ele ids
      -- so we can check if the asg has an effective Element
      -- entry for this Element Type id
      l_pet_ids(l_pet_ids.COUNT + 1) := g_tab_sal_ele_ids(l_current);

    END IF;

    CLOSE c_ele_attr;

    l_current := g_tab_sal_ele_ids.NEXT(l_current);
    IF l_current IS NULL THEN
      EXIT;
    ELSE
      l_itr := l_itr + 1;
    END IF;

  END LOOP; -- through the element type ids in Salary Balance

  debug(l_proc_name, 40);
  l_itr := NULL;

  -- Now LOOP through element types which have the Rate Type
  -- in Ele Attribution to check if the assignment has an
  -- Element entry for this ele type.
  FOR l_itr IN 1..l_pet_ids.COUNT
  LOOP

    debug(l_proc_name, 50);
    OPEN c_element_entry(p_element_type_id => l_pet_ids(l_itr).element_type_id);
    FETCH c_element_entry INTO l_element_entry;

    IF c_element_entry%FOUND THEN
      debug('Setting l_asg_affected to TRUE', 60);
      l_asg_affected := TRUE;
      EXIT;
    END IF;

    CLOSE c_element_entry;

  END LOOP; -- l_itr INTO 1..l_pet_ids.COUNT

  debug_exit(l_proc_name);

  RETURN l_asg_affected;

EXCEPTION
  WHEN OTHERS THEN
    debug('Other exception :'||SQLCODE||' '||SQLERRM, 70);
    l_asg_affected := FALSE;
    debug_exit(l_proc_name);
    RAISE;

END chk_rate_change_affects_asg;

--
-- chk_grd_change_affects_asg
--
FUNCTION chk_grd_change_affects_asg
                (p_assignment_id        IN NUMBER
                ,p_grade_rule_id        IN NUMBER
                ,p_effective_date       IN DATE
                ) RETURN BOOLEAN IS

  CURSOR c_grade_rule IS
  SELECT effective_start_date
        ,effective_end_date
        ,rate_id
        ,grade_or_spinal_point_id
        ,rate_type
  FROM pay_grade_rules_f
  WHERE grade_rule_id = p_grade_rule_id
    AND p_effective_date BETWEEN effective_start_date
                             AND effective_end_date;

  CURSOR c_asg_grade IS
  SELECT grade_id
  FROM per_all_assignments_f
  WHERE assignment_id = p_assignment_id
    AND p_effective_date BETWEEN effective_start_date
                             AND effective_end_date;

  CURSOR c_asg_grade_step(p_grade_id        IN NUMBER
                         ,p_spinal_point_id IN NUMBER
                         ) IS
  SELECT pspp.placement_id
  FROM per_spinal_point_placements_f pspp
      ,per_grade_spines_f pgs
      ,per_spinal_point_steps_f psps
  WHERE pspp.assignment_id = p_assignment_id
    AND p_effective_date BETWEEN pspp.effective_start_date
                             AND pspp.effective_end_date
    AND pgs.parent_spine_id =  pspp.parent_spine_id
    AND pgs.grade_id = p_grade_id
    AND p_effective_date BETWEEN pgs.effective_start_Date
                             AND pgs.effective_end_Date
    AND psps.grade_spine_id = pgs.grade_spine_id
    AND psps.spinal_point_id = p_spinal_point_id
    AND p_effective_date BETWEEN psps.effective_start_Date
                             AND psps.effective_end_Date
    AND psps.step_id = pspp.step_id;


  l_grade_rule          c_grade_rule%ROWTYPE;
  l_asg_grade           c_asg_grade%ROWTYPE;
  l_asg_grade_step      c_asg_grade_step%ROWTYPE;

  l_asg_affected        BOOLEAN := FALSE;

  l_proc_name           VARCHAR2(61):=
     g_proc_name||'chk_grd_change_affects_asg';

BEGIN -- chk_grd_change_affects_asg

  debug_enter(l_proc_name);

  OPEN c_grade_rule;
  FETCH c_grade_rule INTO l_grade_rule;
  CLOSE c_grade_rule;

  -- Now get the grade id, we need it anyway
  OPEN c_asg_grade;
  FETCH c_asg_grade INTO l_asg_grade;
  CLOSE c_asg_grade;

  IF l_grade_rule.rate_type = 'G' THEN -- Grade Rate

    debug('Rate Type is Grade Rate, id :'||l_grade_rule.grade_or_spinal_point_id, 10);

    -- Grade rule grade id same as asg grade id
    IF l_grade_rule.grade_or_spinal_point_id = l_asg_grade.grade_id THEN
      debug('Setting l_asg_affected to TRUE', 20);
      l_asg_affected := TRUE;
    END IF;

  ELSIF l_grade_rule.rate_type = 'SP' THEN

    debug('Rate Type is Spinal Point, id :'||l_grade_rule.grade_or_spinal_point_id, 30);

    OPEN c_asg_grade_step(p_grade_id        => l_asg_grade.grade_id
                         ,p_spinal_point_id => l_grade_rule.grade_or_spinal_point_id
                         );
    FETCH c_asg_grade_step INTO l_asg_grade_step;

    IF c_asg_grade_step%FOUND THEN
      debug('Setting l_asg_affected to TRUE', 40);
      l_asg_affected := TRUE;
    END IF;

    CLOSE c_asg_grade_step;

  ELSE -- Unrecognised Rate_Type, will return FALSE
    debug('Unrecognized Rate Type :'||l_grade_rule.rate_type, 50);
    l_asg_affected := FALSE;
  END IF; -- l_grade_rule.rate_type =

  IF l_asg_affected -- by Grade change
  THEN -- check if asg also affected by rate change

    IF NOT chk_rate_change_affects_asg
             (p_assignment_id        => p_assignment_id
             ,p_rate_id              => l_grade_rule.rate_id
             ,p_effective_date       => p_effective_date
             ) THEN
      l_asg_affected := FALSE;
    END IF;
    --
  ELSE
    debug('Assignment Affected :FALSE', 60);
  END IF;

  debug_exit(l_proc_name);

  RETURN l_asg_affected;

EXCEPTION
  WHEN OTHERS THEN
    debug('Other exception :'||SQLCODE||' '||SQLERRM, 70);
    debug_exit(l_proc_name);
    RAISE;
END; -- chk_grd_change_affects_asg

--
--
--
--
--
-- The procedure raises a warning if there is a full time
-- teaching assignments.
-- Coz cross person reporting is not enabled, so there may be
-- another teaching assignment for this person

PROCEDURE warn_anthr_tchr_asg (p_assignment_id IN NUMBER)
IS
l_proc_name  VARCHAR2(61):= 'warn_anthr_tchr_asg';
l_error      NUMBER;

BEGIN
    debug_enter(l_proc_name);

    -- Raise a warning if Cross person enable = N and
    -- there are multiple person records.
    IF (g_cross_per_enabled = 'N' AND g_person_count > 0) THEN
      l_error := pqp_gb_tp_extract_functions.raise_extract_warning
                 (p_assignment_id => p_assignment_id
                 ,p_error_text    => 'BEN_94022_TP1_ANTHR_TCHR_ASG'
                 ,p_error_number  => 94022
                 );
    END IF ;

  debug_exit(l_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
     debug_exit(' Others in '||l_proc_name);
    RAISE;
END warn_anthr_tchr_asg ;
--

   PROCEDURE fetch_allow_eles_frm_udt
               (p_assignment_id  IN NUMBER
               ,p_effective_date IN DATE
               )
   IS
      --

      CURSOR csr_get_lon_user_rows (c_udt_id NUMBER)
      IS
      SELECT row_low_range_or_name
        FROM pay_user_rows_f
        WHERE user_table_id = c_udt_id
        AND p_effective_date BETWEEN effective_start_date
                                   AND effective_end_date
        AND row_low_range_or_name in ('LARP Inner Allowance','LARP Outer Allowance',
                                      'LARP Fringe Allowance','LARP Inner Plus Inner Supplement'
                                     )
        ORDER BY display_sequence;

      CURSOR csr_get_spl_user_rows (c_udt_id NUMBER)
      IS
      SELECT row_low_range_or_name
        FROM pay_user_rows_f
        WHERE user_table_id = c_udt_id
        AND p_effective_date BETWEEN effective_start_date
                                   AND effective_end_date
        AND row_low_range_or_name in ('SPAP Lower Rate','SPAP Higher Rate',
                                      'SPAP Special Needs Lower Rate','SPAP Special Needs Higher Rate'
                                     )
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
                           'PQP_GB_TP_TYPE1_EXTRACT_DEFINITIONS';
      l_return            NUMBER;
      l_udt_id            NUMBER;
      l_user_value        pay_user_column_instances_f.value%TYPE;
      l_error_msg         VARCHAR2(2000);

      -- RET1.a : new variables to store element_type_extra_info_id
      l_element_type_extra_info_id  pay_element_type_extra_info.element_type_extra_info_id%type;
      l_retval		 NUMBER;
      l_allow_code       VARCHAR2(1);
      --
   --
   BEGIN
      --
      debug_enter(l_proc_name);
      debug('p_effective_date: '|| p_effective_date);



      -- Get UDT ID
      l_udt_id := pqp_gb_tp_pension_extracts.get_udt_id
                    (p_udt_name => l_udt_name);

      -- Get the user rows information for this UDT
      --
      IF l_udt_id IS NOT NULL THEN

           debug(l_proc_name, 10);

        --
        OPEN csr_get_lon_user_rows (l_udt_id);
        LOOP
          FETCH csr_get_lon_user_rows INTO l_user_row_name;
          EXIT WHEN csr_get_lon_user_rows%NOTFOUND;

          -- Get the user value for this row if one exist
          -- for each type of allowance and store it in their
          -- respective collections
             debug('User Row Name: '
                    || l_user_row_name,20);
             debug('User Column Name: Management Allowance Element Type');
     l_return := pqp_utilities.pqp_gb_get_table_value
		   (p_business_group_id => g_business_group_id
		   ,p_effective_date    => p_effective_date
		   ,p_table_name        => l_udt_name
		   ,p_column_name       => 'Attribute Location Type'
		   ,p_row_name          => l_user_row_name
		   ,p_value             => l_user_value
		   ,p_error_msg         => l_error_msg
		  );
       IF upper(l_user_value) in ('G','GRADE') THEN
         g_lon_all_grd_src := 'Y';
         g_tab_lon_aln_eles.DELETE;
         EXIT;
       END IF;
       IF  upper(l_user_value) in ('E','ELEMENT','R','RATE TYPE') THEN
	     l_return := pqp_utilities.pqp_gb_get_table_value
			   (p_business_group_id => g_business_group_id
			   ,p_effective_date    => p_effective_date
			   ,p_table_name        => l_udt_name
			   ,p_column_name       => 'Allowance Code'
			   ,p_row_name          => l_user_row_name
			   ,p_value             => l_allow_code
			   ,p_error_msg         => l_error_msg
			  );
       END IF;

       IF  upper(l_user_value) in ('E','ELEMENT') THEN

          l_element_type_id := pqp_gb_tp_pension_extracts.get_allow_ele_info
                                 (p_assignment_id  => p_assignment_id
                                 ,p_effective_date => p_effective_date
                                 ,p_table_name     => l_udt_name
                                 ,p_row_name       => l_user_row_name
                                 ,p_column_name    => 'Attribute Location Qualifier 1'
                                 );
          debug('l_element_type_id : '|| to_char(l_element_type_id));

      	  IF l_element_type_id IS NOT NULL
          THEN
             --
             -- Store it in the management allowance collection
             l_tab_mng_aln_eles (l_element_type_id).salary_scale_code
                               := l_allow_code;
             l_tab_mng_aln_eles (l_element_type_id).element_type_id
                               := l_element_type_id;
	  END IF;
      ELSIF upper(l_user_value) in ('R','RATE TYPE') THEN-- element type id is null
            -- Check for rate type
                debug(l_proc_name, 50);

            l_tab_mng_aln_eles := pqp_gb_tp_pension_extracts.get_allow_code_rt_ele_info
                                    (p_assignment_id  => p_assignment_id
                                    ,p_effective_date => p_effective_date
                                    ,p_table_name     => l_udt_name
                                    ,p_row_name       => l_user_row_name
                                    ,p_column_name    => 'Attribute Location Qualifier 1'
                                    ,p_tab_aln_eles   => l_tab_mng_aln_eles
                                    ,p_allowance_code => l_allow_code
                                    );
          END IF; -- End if of element type id not null check ...
          -- end of code for "Management Allowance Element Type" --
        END LOOP;
        CLOSE csr_get_lon_user_rows;

      debug('Managment collection count: '||TO_CHAR(l_tab_mng_aln_eles.COUNT));
      debug('Retention collection count: '||TO_CHAR(l_tab_ret_aln_eles.COUNT));

      g_tab_lon_aln_eles := l_tab_mng_aln_eles;
      l_tab_mng_aln_eles.DELETE;

        OPEN csr_get_spl_user_rows (l_udt_id);
        LOOP
          FETCH csr_get_spl_user_rows INTO l_user_row_name;
          EXIT WHEN csr_get_spl_user_rows%NOTFOUND;

          -- Get the user value for this row if one exist
          -- for each type of allowance and store it in their
          -- respective collections
             debug('User Row Name: '
                    || l_user_row_name,20);
             debug('User Column Name: Management Allowance Element Type');
     l_return := pqp_utilities.pqp_gb_get_table_value
		   (p_business_group_id => g_business_group_id
		   ,p_effective_date    => p_effective_date
		   ,p_table_name        => l_udt_name
		   ,p_column_name       => 'Attribute Location Type'
		   ,p_row_name          => l_user_row_name
		   ,p_value             => l_user_value
		   ,p_error_msg         => l_error_msg
		  );

       IF upper(l_user_value) in ('G','GRADE') THEN
         g_spl_all_grd_src := 'Y';
         g_tab_spl_aln_eles.DELETE;
         EXIT;
       END IF;

       IF  upper(l_user_value) in ('E','ELEMENT','R','RATE TYPE') THEN
	     l_return := pqp_utilities.pqp_gb_get_table_value
			   (p_business_group_id => g_business_group_id
			   ,p_effective_date    => p_effective_date
			   ,p_table_name        => l_udt_name
			   ,p_column_name       => 'Allowance Code'
			   ,p_row_name          => l_user_row_name
			   ,p_value             => l_allow_code
			   ,p_error_msg         => l_error_msg
			  );
       END IF;

       IF  upper(l_user_value) in ('E','ELEMENT') THEN

          l_element_type_id := pqp_gb_tp_pension_extracts.get_allow_ele_info
                                 (p_assignment_id  => p_assignment_id
                                 ,p_effective_date => p_effective_date
                                 ,p_table_name     => l_udt_name
                                 ,p_row_name       => l_user_row_name
                                 ,p_column_name    => 'Attribute Location Qualifier 1'
                                 );
          debug('l_element_type_id : '|| to_char(l_element_type_id));

      	  IF l_element_type_id IS NOT NULL
          THEN
             --
             -- Store it in the management allowance collection
             l_tab_mng_aln_eles (l_element_type_id).salary_scale_code
                               := l_allow_code;
             l_tab_mng_aln_eles (l_element_type_id).element_type_id
                               := l_element_type_id;
	  END IF;
      ELSIF upper(l_user_value) in ('R','RATE TYPE') THEN-- element type id is null
            -- Check for rate type
                debug(l_proc_name, 50);

            l_tab_mng_aln_eles := pqp_gb_tp_pension_extracts.get_allow_code_rt_ele_info
                                    (p_assignment_id  => p_assignment_id
                                    ,p_effective_date => p_effective_date
                                    ,p_table_name     => l_udt_name
                                    ,p_row_name       => l_user_row_name
                                    ,p_column_name    => 'Attribute Location Qualifier 1'
                                    ,p_tab_aln_eles   => l_tab_mng_aln_eles
                                    ,p_allowance_code => l_allow_code
                                    );
          END IF; -- End if of element type id not null check ...
          -- end of code for "Management Allowance Element Type" --
        END LOOP;
        CLOSE csr_get_spl_user_rows;

      END IF; -- End if of udt id is not null check ...

      debug('Managment collection count: '||TO_CHAR(l_tab_mng_aln_eles.COUNT));
      debug('Retention collection count: '||TO_CHAR(l_tab_ret_aln_eles.COUNT));

      g_tab_spl_aln_eles := l_tab_mng_aln_eles;
      debug_exit(l_proc_name);
    --
    END fetch_allow_eles_frm_udt;
   --
Function Get_Allowance_Code_New ( p_assignment_id   in number
                             ,p_effective_date  in date
                             ,p_allowance_type  in varchar2 ) Return varchar2 Is
   CURSOR csr_ele_entry_exists
     (c_assignment_id   NUMBER
     ,c_element_type_id NUMBER
     ,c_effective_date  DATE
     )
   IS
   SELECT 'X'
     FROM pay_element_entries_f pee
         ,pay_element_links_f   pel
    WHERE pee.assignment_id   = c_assignment_id
      AND pee.entry_type      = 'E'
      AND pee.element_link_id = pel.element_link_id
      AND c_effective_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
      AND pel.element_type_id = c_element_type_id
      AND c_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date;

   CURSOR csr_grade_val(c_assignment_id   NUMBER,
                        c_effective_date  DATE,
                        c_allowance_type  varchar2
                       ) IS
   SELECT decode(c_allowance_type,'LONDON_ALLOWANCE_RULE',information6,
                                  'SPECIAL_ALLOWANCE_RULE',information7
                ) indicator
     FROM per_grades pgr,per_all_assignments_f paaf
    WHERE paaf.assignment_id = c_assignment_id
      AND c_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
      AND paaf.grade_id = pgr.grade_id
      AND pgr.information_category = 'GB_PQP_PENSERV_GRADE_INFO';

l_tab_allowances t_allowance_eles;
l_return_value varchar2(1);
l_exists varchar2(1);
i                           NUMBER;
l_error_value        number;
l_count  number;
l_proc_name          varchar2(60) := g_proc_name || 'Get_Allowance_Code_New';

Begin
     -- hr_utility.set_location('Entering: '||l_proc_name, 5);
     debug_enter(l_proc_name);
     debug('p_allowance_type :'||p_allowance_type, 10);



     IF p_allowance_type = 'LONDON_ALLOWANCE_RULE' THEN
       IF g_lon_all_grd_src = 'Y' THEN
         NULL;
       ELSE
        l_tab_allowances := g_tab_lon_aln_eles;
       END IF;
     	OPEN csr_grade_val(p_assignment_id,p_effective_date,p_allowance_type);
     	FETCH csr_grade_val INTO l_return_value;
     	CLOSE csr_grade_val;
     	IF l_return_value IS NOT NULL THEN
           return l_return_value;
        END IF;
     ELSIF p_allowance_type = 'SPECIAL_ALLOWANCE_RULE' THEN
       IF g_spl_all_grd_src = 'Y' THEN
         NULL;
       ELSE
         l_tab_allowances := g_tab_spl_aln_eles;
       END IF;
     	OPEN csr_grade_val(p_assignment_id,p_effective_date,p_allowance_type);
     	FETCH csr_grade_val INTO l_return_value;
     	CLOSE csr_grade_val;
     	IF l_return_value IS NOT NULL THEN
           return l_return_value;
        END IF;
     ELSE
       l_error_value := pqp_gb_tp_extract_functions.raise_extract_error
                         (p_business_group_id => g_business_group_id
                         ,p_assignment_id     => p_assignment_id
                         ,p_error_text        =>'BEN_93024_EXT_TP1_INVALID_ALOW'
                         ,p_error_number      => 93024 );
     END IF;


           i := l_tab_allowances.FIRST;
           l_count := 1; -- initialize the lop counter..

           WHILE i IS NOT NULL
           LOOP
             OPEN csr_ele_entry_exists (p_assignment_id
                                       ,l_tab_allowances(i).element_type_id
                                       ,p_effective_date
                                       );
             FETCH csr_ele_entry_exists INTO l_exists;
             IF csr_ele_entry_exists%FOUND THEN
                debug('Management Element Type: '||TO_CHAR(i), 160+l_count/100);
                l_return_value
                  := TO_CHAR(l_tab_allowances(i).salary_scale_code);
                CLOSE csr_ele_entry_exists;
                EXIT;
             END IF; -- End if of row found check ...
             CLOSE csr_ele_entry_exists;
             i := l_tab_allowances.NEXT(i);
             l_count := l_count + 1;
           END LOOP;
     debug(l_proc_name, 90);


     Return l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    debug_exit(' Others in '||l_proc_name);
    RAISE;
End Get_Allowance_Code_New;

END pqp_gb_t1_pension_extracts;


/
