--------------------------------------------------------
--  DDL for Package Body PAY_EVENTS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVENTS_WRAPPER" AS
/* $Header: pyevtwrp.pkb 120.1 2006/02/13 02:52:31 alogue noship $ */
/*
    +======================================================================+
    |               Copyright (c) 2002 Oracle Corporation UK               |
    |                    Thames Valley Park, Reading, UK                   |
    |                        All rights reserved.                          |
    +======================================================================+
    File Name   : pyevtwrp.pkh

    Description : A wrapper on top of the Payroll Events Model interpreter
                  for use with the summarisation collection programs which
                  are used to increase the performance of the Daily Business
                  Intelligence portlet queries.

    Change History
    --------------
    Name           Date        Version Bug     Text
    -------------- ----------- ------- ------- ------------------------------------
    Ed Jones       31-May-2002 115.0           Initial (Stub) version
    Ed Jones       31-May-2002 115.1           Added dbdrv lines
                                               Removed dbms_output
    Ed Jones       31-May-2002 115.2           Corrected invalid dbdrv lines
    Ed Jones       14-Jun-2002 115.3           Replaced stubs with proper
                                               code, moved wrapper specific
                                               detailed output fields from
                                               interpreter to an additional
                                               cache table here (dated table
                                               extras global variable)
    Ed Jones       02-Jul-2002 115.4           Added refresh period start
                                               and end dates to the
                                               get_refresh_periods routine
                                               and pass these to the interpreter
                                               rather than the effective assignment
                                               dates
    Ed Jones       02-Jul-2002 115.5           Removed owner from join to
                                               all_tab_columns
    Ed Jones       23-Jul-2002 115.6           Add debugging mode and allow
                                               messages to be sent to conc.
                                               manager output file
    Ed Jones       23-Jul-2002 115.7           Added more debug information
                                               Send conc. messages to log
    Ed Jones       23-Jul-2002 115.8           Add supervisor ID column changes
                                               separately to normal payroll event
                                               model updates, this is to detect
                                               and record old and new supervisors
                                               in the list of refresh records
    Ed Jones       27-Mar-2003 115.9   2870801 Changes to support date track
                                               updates to supervisor as well as
                                               corrections.
    Ed Jones       10-Apr-2003 115.10          Changes to pick up correct start date
                                               for updated supervisor correctly
    Ed Jones       02-Jun-2003 115.11  2984406 Moved pay_interpreter_pkg.event_group_tables
                                               call and reset of g_DATED_TABLE_EXTRAS
					       cache to a separate procedure (from
					       get_event_details) so that it's only
					       called once per run.
					       Don't pass around event group name
					       parameter, use the global ID populated in
					       the one-off init_event_group_cache
					       procedure.
					       Major changes to the way in which affected
					       assignments are detected, see specific
					       sections for details (search for this bug).
    Ed Jones       07-Jul-2003 115.13          Moved various cursors to be visible at package
                                               level for ease of access by diagnostics
					       routines.
					       Made dt update SQL building function accessible
					       for this reason too.
					       Change csr_inserts_deletes cursor to decode
					       various event types to match update types.
					       Corrections cursor looks for C type updates
					       as well as U (database updates may be stored
					       in the incident register as corrections)
				       3033981 Changed incident register accessing cursors
				               to get surrogate key and pass that on to
					       the event interpreter, if the table in use
					       is element entries.
    Ed Jones       07-Jul-2003 115.14          Remove 'show errors' for gscc
    Andy Logue     23-DEC-2003 115.15  3329824 Performance fix
    Andy Logue     05-JAN-2004 115.16          Performance fix
    N Bristow      26-JAN-2004 115.17          get_assignments_affected changed to drive
                                               off pay_process_events and to only use
                                               salary entries.
    N Bristow      10-MAR-2004 115.18          Performance changes, the PL/SQL
                                               tables were being over
                                               referenced. Change these tables
                                               to use a hash cache.
    Andy Logue     13-FEB-2006 115.19          Schema clone for all_tab_columns.
    ===============================================================================
*/
    --
    -- < PRIVATE TYPES > -----------------------------------------------------
    TYPE t_dated_table_extras_rec IS RECORD(
        has_supervisor_id         VARCHAR2(1),
        has_location_id           VARCHAR2(1),
        has_assignment_id         VARCHAR2(1),
        sql_statement             VARCHAR2(32767)
    );
    TYPE t_dated_table_extras_tab IS
        TABLE OF t_dated_table_extras_rec
        INDEX BY BINARY_INTEGER;
--
    type t_indexing_rec is record(
         start_ptr number
    );
--
    type t_indexing_tab is table of t_indexing_rec index by BINARY_INTEGER;
--
    type t_location_chn_rec is record
    (
        supervisor_id number,
        location_id   number,
        summary_ptr   number,
        next_ptr      number
    );
--
    type t_location_chn_tab is table of t_location_chn_rec
     index by BINARY_INTEGER;
--
    g_supervisor_hash_tab t_indexing_tab;
    g_location_chn_tab    t_location_chn_tab;

--
    --
    -- < PRIVATE CONSTANTS > -------------------------------------------------
    --
    -- The event model processing mode and other animals
    c_PROCESS_MODE          CONSTANT VARCHAR2(30)   := 'ASG_CREATION';
    c_ASSIGNMENTS_TABLE     CONSTANT VARCHAR2(30)   := 'per_all_assignments_f';
    c_OUTPUT_BUFFER         CONSTANT NUMBER         := 2000000;
    c_OUTPUT_LINE_LENGTH    CONSTANT NUMBER         := 255;
    --
    -- < PRIVATE GLOBALS > ---------------------------------------------------
    --
    g_debugging             BOOLEAN := FALSE;
    g_concurrent            BOOLEAN := FALSE;
    --
    -- How long did the last run take
    g_SECONDS_ELAPSED       NUMBER  := 0;
    --
    -- Cached information about an event group
    g_DATED_TABLE_EXTRAS    t_dated_table_extras_tab;
    g_EVENT_GROUP_ID        NUMBER := NULL;
    --
    -- Globals for record looping
    g_FIRST_RECORD 	    NUMBER := 0;
    g_LAST_RECORD 	    NUMBER := 0;
    g_CURRENT_RECORD 	    NUMBER := 0;
    --
    -- < CURSORS > -----------------------------------------------------------
    --
--
    CURSOR csr_all_changes(p_st IN DATE,p_en IN DATE) IS
        SELECT
                    ppe.assignment_id,
                    ppe.surrogate_key,
                    peu.dated_table_id,
                    MIN(ppe.effective_date)   effective_start_date,
                    MAX(ppe.effective_date)   effective_end_date
        FROM        pay_process_events      ppe,
                    pay_event_updates       peu
        WHERE       ppe.creation_date BETWEEN p_st AND p_en
        AND         ppe.event_update_id = peu.event_update_id
        GROUP BY    ppe.assignment_id,ppe.surrogate_key, peu.dated_table_id
        ORDER BY    ppe.assignment_id, ppe.surrogate_key;
--
    -- Get the inserts into and deletes from the tables we care about
    CURSOR csr_inserts_deletes(p_evt IN NUMBER,p_st IN DATE,p_en IN DATE) RETURN csr_return IS
        SELECT
	            ppe.assignment_id,
	            peu.dated_table_id,
	            ppe.surrogate_key,
                    MIN(ppe.effective_date)   start_date,
                    MAX(ppe.effective_date)   end_date
        FROM        pay_process_events      ppe,
                    pay_event_updates       peu
        WHERE       ppe.creation_date BETWEEN p_st AND p_en
        AND         ppe.event_update_id = peu.event_update_id
        AND         substr(peu.event_type,1,1) in ('D','I','Z')
        AND EXISTS (
                    SELECT  'X'
                    FROM    pay_datetracked_events pde
                    WHERE   pde.event_group_id = p_evt
                    AND     pde.dated_table_id = peu.dated_table_id
                    AND     pde.update_type = SUBSTR(DECODE(peu.event_type,'ZAP','D',peu.event_type),1,1)
        )
        GROUP BY    ppe.assignment_id,peu.dated_table_id,ppe.surrogate_key;
    --
    -- Get the updates (date-track corrections) to columns we care about, excluding supervisor ID
    CURSOR csr_dt_corrections(p_evt IN NUMBER,p_st IN DATE,p_en IN DATE) RETURN csr_return IS
        SELECT
	            ppe.assignment_id,
	            peu.dated_table_id,
                    ppe.surrogate_key,
                    MIN(ppe.effective_date)   start_date,
                    MAX(ppe.effective_date)   end_date
        FROM        pay_process_events      ppe,
                    pay_event_updates       peu
        WHERE       ppe.creation_date BETWEEN p_st AND p_en
        AND         ppe.event_update_id = peu.event_update_id
        AND         substr(peu.event_type,1,1) IN ('U','C')
        AND EXISTS (
                    SELECT  'X'
                    FROM    pay_datetracked_events  pde,
                            pay_dated_tables        pdt
      	            WHERE   pde.event_group_id = p_evt
      	            AND     pde.dated_table_id = peu.dated_table_id
                    AND     pdt.dated_table_id = pde.dated_table_id
	            AND     pde.column_name = peu.column_name
                    AND     NOT (pdt.table_name = 'PER_ALL_ASSIGNMENTS_F' AND pde.column_name = 'SUPERVISOR_ID')
	            AND     pde.update_type = 'C'
                   )
        GROUP BY    ppe.assignment_id,peu.dated_table_id,ppe.surrogate_key;
        --
        -- Decode the description column of pay_process_events to obtain the
        -- before and after values, just for the supervisor ID column on
        -- per_all_assignments_f, and only if that column is one of the ones
        -- we're tracking via our event group. Group by supervisor ID and
        -- optionally location ID and return the earliest and latest effective
        -- dates that were affected by the change
	-- 2984406: Changes for performance
        CURSOR csr_supv_corrections(
            cp_evt      IN NUMBER,
            cp_st       IN DATE,
            cp_en       IN DATE,
            cp_str      IN VARCHAR2
        ) RETURN csr_return IS
            SELECT  TO_NUMBER(DECODE(sic.column_name,'SUPERVISOR_ID',sic.id,NULL))  supervisor_id,
                    DECODE(cp_str,'Y',paaf.location_id,c_BLANK_LOCATION_ID)         location_id,
		    NULL                                                            dummy,
                    MIN(sic.effective_date)                                         effective_start_date,
                    MAX(sic.effective_date)                                         effective_end_date
            FROM    (
                        -- Get the 'before' information, i.e. the ID before the '->' character sequence
                        SELECT  /*+ ordered index(ppe pay_process_events_n3) */
	                        DECODE(SUBSTR(ppe.description,1,INSTR(ppe.description,' -> ')-1),'<null>',NULL,SUBSTR(ppe.description,1,INSTR(ppe.description,' -> ')-1)) id,
                                ppe.effective_date,
                                ppe.assignment_id,
                                peu.dated_table_id,
                                peu.column_name
                        FROM    pay_process_events  ppe,
                                pay_event_updates   peu,
                                pay_dated_tables    pdt,
				pay_datetracked_events pde
                        WHERE   INSTR(ppe.description,' -> ') > 0
                        AND     SUBSTR(ppe.description,1,6) <> '<null>'
                        AND     peu.event_update_id = ppe.event_update_id
                        AND     peu.dated_table_id = pdt.dated_table_id
                        AND     pdt.table_name = 'PER_ALL_ASSIGNMENTS_F'
                        AND     peu.column_name = 'SUPERVISOR_ID'
			AND     pde.update_type = 'C'
			AND     pde.column_name = peu.column_name
			AND     ppe.creation_date BETWEEN cp_st AND cp_en
			AND     cp_evt = pde.event_group_id
			AND     pde.dated_table_id = peu.dated_table_id
                        UNION
                        -- Add the 'after' information, i.e. the ID after the '->' character sequence, don't UNION ALL 'cos that would give us duplicates
                        SELECT  /*+ ordered index(ppe pay_process_events_n3) */
	                        DECODE(SUBSTR(ppe.description,INSTR(ppe.description,' -> ')+4),'<null>',NULL,SUBSTR(ppe.description,INSTR(ppe.description,' -> ')+4)) id,
                                ppe.effective_date,
                                ppe.assignment_id,
                                peu.dated_table_id,
                                peu.column_name
                        FROM    pay_process_events  ppe,
                                pay_event_updates   peu,
                                pay_dated_tables    pdt,
				pay_datetracked_events pde
                        WHERE   INSTR(ppe.description,' -> ') > 0
                        AND     SUBSTR(ppe.description,length(ppe.description)-5) <> '<null>'
                        AND     peu.event_update_id = ppe.event_update_id
                        AND     peu.dated_table_id = pdt.dated_table_id
                        AND     pdt.table_name = 'PER_ALL_ASSIGNMENTS_F'
                        AND     peu.column_name = 'SUPERVISOR_ID'
			AND     pde.update_type = 'C'
			AND     pde.column_name = peu.column_name
			AND     ppe.creation_date BETWEEN cp_st AND cp_en
	                AND     cp_evt = pde.event_group_id
			AND     pde.dated_table_id = pdt.dated_table_id
                    )                       sic,
                    per_all_assignments_f   paaf
            -- Join to the assignment at the effective date of the change to get the location
            WHERE   sic.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
            AND     paaf.assignment_id      = sic.assignment_id
            GROUP BY
                    TO_NUMBER(DECODE(sic.column_name,'SUPERVISOR_ID',sic.id,NULL)),
                    DECODE(cp_str,'Y',paaf.location_id,c_BLANK_LOCATION_ID);
		            --
	-- Get a list of the tables that are in our event group
        CURSOR csr_table_list(p_evt IN NUMBER) RETURN csr_return IS
            SELECT DISTINCT pdt.dated_table_id,NULL,pdt.table_name,NULL,NULL
            FROM   pay_dated_tables pdt,
                   pay_datetracked_events pde
            WHERE  pde.dated_table_id = pdt.dated_table_id
            AND    pde.event_group_id = p_evt
            AND    pde.update_type = 'U';
--
procedure get_summary_idx(p_super_id        in            number,
                          p_location_id     in            number,
                          p_idx                out nocopy number,
                          p_summary_refresh in out nocopy t_summary_refresh_tab_type
                         )
is
hash_key number;
loc_idx  number;
sum_idx  number;
prev_idx number;
l_found  boolean;
begin
--
   hash_key := (p_super_id mod 1009 ) + 1;
--
   begin
--
       if (g_supervisor_hash_tab.exists(hash_key)) then
--
          loc_idx := g_supervisor_hash_tab(hash_key).start_ptr;
--
          l_found := FALSE;
          while (l_found <> TRUE and loc_idx is not null) loop
             if (   g_location_chn_tab(loc_idx).supervisor_id = p_super_id
                and g_location_chn_tab(loc_idx).location_id = p_location_id)
             then
                 l_found := TRUE;
             else
                 prev_idx := loc_idx;
                 loc_idx := g_location_chn_tab(loc_idx).next_ptr;
             end if;
          end loop;
--
          /* OK if we didn't find one the create one */
          if (l_found = FALSE) then
            loc_idx := g_location_chn_tab.count + 1;
            g_location_chn_tab(loc_idx).supervisor_id := p_super_id;
            g_location_chn_tab(loc_idx).location_id   := p_location_id;
            g_location_chn_tab(loc_idx).summary_ptr   := null;
            g_location_chn_tab(loc_idx).next_ptr      := null;
--
            -- Set the previous pointer.
            g_location_chn_tab(prev_idx).next_ptr     := loc_idx;
          end if;
--
       else
--
          loc_idx := g_location_chn_tab.count + 1;
          g_location_chn_tab(loc_idx).supervisor_id := p_super_id;
          g_location_chn_tab(loc_idx).location_id   := p_location_id;
          g_location_chn_tab(loc_idx).summary_ptr   := null;
          g_location_chn_tab(loc_idx).next_ptr      := null;
--
          g_supervisor_hash_tab(hash_key).start_ptr := loc_idx;
       end if;
--
   end;
--
   /* OK we should now have a row for the location table.
      Need to see if we have a row in the summary table
   */
--
   if (g_location_chn_tab(loc_idx).summary_ptr is null) then
--
     sum_idx := p_summary_refresh.count + 1;
--
     p_summary_refresh(sum_idx).supervisor_id := p_super_id;
     p_summary_refresh(sum_idx).location_id   := p_location_id;
--
     g_location_chn_tab(loc_idx).summary_ptr := sum_idx;
--
   end if;
--
   p_idx := g_location_chn_tab(loc_idx).summary_ptr;
--
end get_summary_idx;
    --
    -- < PRIVATE FUNCTIONS > -------------------------------------------------
    --
    -- Increment a data
    FUNCTION inc_date(p_date IN DATE) RETURN DATE IS
    BEGIN
        IF p_date < hr_general.end_of_time THEN
            RETURN p_date + 1;
        ELSE
            RETURN p_date;
        END IF;
    END inc_date;
    --
    -- Decrement a date
    FUNCTION dec_date(p_date IN DATE) RETURN DATE IS
    BEGIN
        IF p_date > hr_general.start_of_time THEN
            RETURN p_date - 1;
        ELSE
            RETURN p_date;
        END IF;
    END dec_date;
    --
    -- Get the business group of an assignment
    FUNCTION get_business_group_id(p_assignment_id IN NUMBER) RETURN NUMBER IS
        --
        CURSOR csr_bg(cp_ass_id IN NUMBER) IS
            SELECT  business_group_id
            FROM    per_assignments_f
            WHERE   assignment_id = cp_ass_id;
        --
        l_business_group_id     NUMBER;
        --
    BEGIN
        OPEN csr_bg(p_assignment_id);
        FETCH csr_bg INTO l_business_group_id;
        CLOSE csr_bg;
        --
        RETURN l_business_group_id;
    END get_business_group_id;
    --
    -- Find the information we need from the dated table cache
    FUNCTION query_dated_table_cache(p_dated_table_id IN NUMBER) RETURN NUMBER IS
        --
        l_tab_idx NUMBER;
        --
    BEGIN
        --
        -- Try to find the table the event occurred on in the cache
        l_tab_idx := -1;
        --
        IF NVL(pay_interpreter_pkg.t_distinct_tab.FIRST,0) > 0 THEN
            FOR k IN pay_interpreter_pkg.t_distinct_tab.FIRST .. pay_interpreter_pkg.t_distinct_tab.LAST LOOP
                IF pay_interpreter_pkg.t_distinct_tab(k).table_id = p_dated_table_id THEN
                    msg('Found dated table '||p_dated_table_id||' at index '||k);
                    l_tab_idx := k;
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            -- Log some debugging info and bail
            msg('No dated table information was cached.');
            RAISE dated_table_cache_empty;
        END IF;
        --
        -- Bail if we didn't find the cached info we wanted
        IF l_tab_idx = -1 THEN
            msg('Dated table '||p_dated_table_id||' was not cached.');
            RAISE dated_table_cache_miss;
        END IF;
        --
        RETURN l_tab_idx;
    END query_dated_table_cache;
    --
    -- Return the value of the elapsed time global populated when a full run is
    -- completed
    FUNCTION get_elapsed_time RETURN NUMBER IS
    BEGIN
        RETURN g_SECONDS_ELAPSED;
    END get_elapsed_time;
    --
    -- Get the time taken to execute the last run
    FUNCTION get_elapsed_time_text RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Elapsed time: '||TO_CHAR(get_elapsed_time,'fm99999990.000')||' seconds';
    END get_elapsed_time_text;
    --
    -- < PRIVATE PROCEDURES > ------------------------------------------------
    --
    -- Get the event details for a single assignment ID
    PROCEDURE get_event_details(
        p_start_date        IN      DATE,
        p_end_date          IN      DATE,
        p_assignment_id     IN      NUMBER,
	p_element_entry_id  IN      NUMBER,
        p_detailed_output   IN OUT  NOCOPY pay_interpreter_pkg.t_detailed_output_table_type,
        p_proration_dates   IN OUT  NOCOPY pay_interpreter_pkg.t_proration_dates_table_type
    ) IS
        -- Business group ID
        l_business_group_id     NUMBER;
        --
        -- Temporary table variables to hold the results from the event model
        -- procedure calls. These results aren't used
        l_dynamic_sql           pay_interpreter_pkg.t_dynamic_sql_tab;
        l_proration_change_type pay_interpreter_pkg.t_proration_type_table_type;
        l_proration_type        pay_interpreter_pkg.t_proration_type_table_type;
        --
    BEGIN
        msg('Getting event details for assignment: '||p_assignment_id);
        --
        -- Get the business group ID
        l_business_group_id := get_business_group_id(p_assignment_id);
        --
        -- Get and parse the events that occurred. Note that we don't call
        -- unique_sort as we do in entry_affected, since we do actually want
        -- a list of all the events that occurred and the effective date of
        -- each one, not just the unique dates, since we'll later merge the
        -- events up to the supervisor level
        pay_interpreter_pkg.event_group_tables_affected(
            p_element_entry_id,
	    NULL,
	    g_EVENT_GROUP_ID,
    	    p_assignment_id,
	    l_business_group_id,
	    p_start_date,
    	    p_end_date,
	    NULL,
	    NULL,
            c_PROCESS_MODE,
	    l_dynamic_sql,
	    p_proration_dates,
    	    l_proration_change_type,
            p_detailed_output
        );
        --
    END get_event_details;
    --
    -- Get a flag to indicated whether or not the given table has the requested column
    PROCEDURE get_column_flag(
        p_table_info    IN      pay_interpreter_pkg.t_distinct_table_rec,
        p_column        IN      VARCHAR2,
        p_flag          IN OUT  NOCOPY VARCHAR2
    ) IS
        -- Find the column in the data-dictionary
        CURSOR get_info(cp_name IN VARCHAR2,cp_column IN VARCHAR2,cp_owner IN VARCHAR2) IS
            SELECT  'Y'
            FROM    all_tab_columns
            WHERE   table_name  = cp_name
            AND     column_name = cp_column
            AND     owner = cp_owner;
        --
        l_schema VARCHAR2(30);
        --
    BEGIN
        l_schema := paywsdyg_pkg.get_table_owner(UPPER(p_table_info.table_name));
        -- If we haven't already populated this flag
        IF NVL(p_flag,'X') = 'X' THEN
            --
            -- Fetch from the cursor
            OPEN get_info(
                UPPER(p_table_info.table_name),
                UPPER(p_column),
                UPPER(l_schema)
            );
            FETCH get_info INTO p_flag;
            --
            -- If nothing came back then that column's not in the table we're looking at
            IF get_info%NOTFOUND THEN
                p_flag := 'N';
            END IF;
            CLOSE get_info;
            --
            -- Write out some debug info
            msg('table = '||LOWER(p_table_info.table_name)||' '||LOWER(p_column)||' ? = '||p_flag);
        END IF;
    END get_column_flag;
    --
    -- Set the column flags in the dated table cache and return a copy of
    -- the record we modified
    PROCEDURE set_dated_table_column_flags(
        p_idx       IN     NUMBER,
        p_rec       IN OUT NOCOPY pay_interpreter_pkg.t_distinct_table_rec,
        p_xrec      IN OUT NOCOPY t_dated_table_extras_rec
    ) IS
    BEGIN
        -- See if there's a supervisor ID on the dated table
        get_column_flag(
            pay_interpreter_pkg.t_distinct_tab(p_idx),
            'SUPERVISOR_ID',
            g_DATED_TABLE_EXTRAS(p_idx).has_supervisor_id
        );
        -- See if there's a location ID on the dated table
        get_column_flag(
            pay_interpreter_pkg.t_distinct_tab(p_idx),
            'LOCATION_ID',
            g_DATED_TABLE_EXTRAS(p_idx).has_location_id
        );
        --
        -- See if we've got an assignment ID (only really need one if supervisor or location is missing)
        get_column_flag(
            pay_interpreter_pkg.t_distinct_tab(p_idx),
            'ASSIGNMENT_ID',
            g_DATED_TABLE_EXTRAS(p_idx).has_assignment_id
        );
        --
        -- Copy the records we updated to the return parameter
        p_rec := pay_interpreter_pkg.t_distinct_tab(p_idx);
        p_xrec := g_DATED_TABLE_EXTRAS(p_idx);
        --
    END set_dated_table_column_flags;
    --
    -- Build the SQL statement we'll need to use to get the supervisor and location IDs
    -- Note that all statements must have the surrogate key ID and the effective
    -- date bind variables, event if there're not used, so we can dynamically open the
    -- cursor in a consistent way
    -- This statement is cached in the t_distinct_tab record
    PROCEDURE get_additional_select(
        p_tab_id        IN      NUMBER,
        p_want_location IN      BOOLEAN,
        p_sql           IN OUT  NOCOPY VARCHAR2
    ) IS
        --
        l_tab_info              pay_interpreter_pkg.t_distinct_table_rec;
        l_tab_extra             t_dated_table_extras_rec;
        l_used_skt              BOOLEAN := FALSE;
        l_used_paf              BOOLEAN := FALSE;
        l_tab_idx               NUMBER;
        --
    BEGIN
        --
        -- Find the dated table information in the cache which was
        -- populated when we called event_group_tables in get_assignment_event_details
        l_tab_idx := query_dated_table_cache(p_tab_id);
        --
        -- Check the cached info in the dated table record to see if we've already built
        -- the SQL statement for this dated table
        IF g_DATED_TABLE_EXTRAS(l_tab_idx).sql_statement IS NOT NULL THEN
            msg('Reusing SQL statement from dated table cache');
            p_sql := g_DATED_TABLE_EXTRAS(l_tab_idx).sql_statement;
            RETURN;
        END IF;
        --
        -- Set the flags indicating which columns we've got on this table and put
        -- a copy of the cached information into l_tab_info
        set_dated_table_column_flags(
            l_tab_idx,
            l_tab_info,
            l_tab_extra
        );
        --
        -- Build the SQL depending on what columns we've got
        msg('Building SQL statement...');
        --
        -- Add the select list
        p_sql := 'SELECT ';
        --
        -- Get the supervisor ID
        IF l_tab_extra.has_supervisor_id = 'Y' THEN
            -- We've got a supervisor ID in this table
            p_sql := p_sql||'skt.supervisor_id, ';
            msg('Got supervisor_id locally');
            l_used_skt := TRUE;
        ELSIF l_tab_extra.has_assignment_id = 'Y' THEN
            -- Find it from the assignment
            p_sql := p_sql||'paf.supervisor_id, ';
            msg('Going to assignment for supervisor_id');
            l_used_paf := TRUE;
        ELSE
            -- Can't get it
            p_sql := p_sql||c_ALL_SUPERVISORS_ID||' supervisor_id, ';
            msg('Can''t get supervisor_id');
        END IF;
        --
        -- Get the location ID
        IF p_want_location THEN
            IF l_tab_extra.has_location_id = 'Y' THEN
                -- We've got a location ID in this table
                p_sql := p_sql||'skt.location_id, ';
                msg('Got location_id locally');
                l_used_skt := TRUE;
            ELSIF l_tab_extra.has_assignment_id = 'Y' THEN
                -- Find it from the assignment
                p_sql := p_sql||'paf.location_id, ';
                msg('Going to assignment for location_id');
                l_used_paf := TRUE;
            ELSE
                -- Can't get it
                p_sql := p_sql||c_BLANK_LOCATION_ID||' location_id, ';
                msg('Can''t get location_id');
            END IF;
        ELSE
            -- Don't want it
            p_sql := p_sql||c_BLANK_LOCATION_ID||' location_id, ';
            msg('Don''t want location_id');
        END IF;
        --
        -- Get the effective dates
        IF (NOT l_used_paf) AND (NOT l_used_skt) THEN
            p_sql := p_sql||'TRUNC(SYSDATE) effective_start_date, '||
                            'TRUNC(SYSDATE) effective_end_date ';
            msg('Adding default dates');
            --
        ELSE
            p_sql := p_sql||'skt.'||l_tab_info.start_date_name||' effective_start_date, '||
                            'skt.'||l_tab_info.end_date_name||' effective_end_date ';
            msg('Using surrogate key table dates');
            --
        END IF;
        --
        -- Add the from list
        p_sql := p_sql||'FROM ';
        --
        -- Which tables did we have to go to?
        IF (NOT l_used_paf) AND (NOT l_used_skt) THEN
            -- Didn't look at any tables
            p_sql := p_sql||'dual ';
            msg('No tables used');
            --
        ELSE
            -- Must always join to the table to which the surrogate key relates
            p_sql := p_sql||l_tab_info.table_name||' skt ';
            msg('Getting info from '||LOWER(l_tab_info.table_name));
            --
            -- Did we also have to go back to the assignment to get anything
            IF l_used_paf THEN
                p_sql := p_sql||', '||c_ASSIGNMENTS_TABLE||' paf ';
                msg('Also getting info from '||c_ASSIGNMENTS_TABLE);
            END IF;
        END IF;
        --
        -- Add the where clause
        p_sql := p_sql||'WHERE ';
        --
        -- Which tables did we have to go to?
        IF (NOT l_used_paf) AND (NOT l_used_skt) THEN
            -- Didn't look at any tables
            p_sql := p_sql||':surrogate_key IS NOT NULL '||
	                    'AND :effective_start_date IS NOT NULL '||
	                    'AND :effective_end_date IS NOT NULL ';
            msg('Didn''t need any where clause, adding default');
            --
        ELSE
            -- Always have to join to the table to which the surrogate key relates
            p_sql := p_sql||'skt.'||l_tab_info.surrogate_key_name||' = :surrogate_key '||
                            'AND :effective_start_date <= skt.'||l_tab_info.end_date_name||' '||
			    'AND :effective_end_date >= skt.'||l_tab_info.start_date_name||' ';
            msg(
                'Adding where clause for '||LOWER(l_tab_info.surrogate_key_name)||', '||
                LOWER(l_tab_info.start_date_name)||' and '||
                LOWER(l_tab_info.end_date_name)||' columns'
            );
            --
            -- Did we also have to go back to the assignment to get anything
            IF l_used_paf THEN
                p_sql := p_sql||'AND paf.assignment_id = skt.assignment_id '||
                                'AND paf.effective_end_date >= skt.'||l_tab_info.start_date_name||' '||
                                'AND paf.effective_start_date <= skt.'||l_tab_info.end_date_name||' ';
                msg('Also joining to assignments table');
                --
            END IF;
        END IF;
        --
        -- Only include rows where the supervisor ID is set (and the location if needed)
        IF l_tab_extra.has_supervisor_id = 'Y' THEN
            p_sql := p_sql||'AND skt.supervisor_id IS NOT NULL ';
            msg('Surrogate table supervisor must not be null');
        ELSIF l_tab_extra.has_assignment_id = 'Y' THEN
            p_sql := p_sql||'AND paf.supervisor_id IS NOT NULL ';
            msg('Assignment table supervisor must not be null');
        END IF;
        --
        IF p_want_location THEN
            IF l_tab_extra.has_location_id = 'Y' THEN
                p_sql := p_sql||'AND skt.location_id IS NOT NULL ';
                msg('Surrogate table location_id must not be null');
            ELSIF l_tab_extra.has_assignment_id = 'Y' THEN
                p_sql := p_sql||'AND paf.location_id IS NOT NULL ';
                msg('Assignment table location_id must not be null');
            END IF;
        ELSE
            msg('Don''t care where location_id comes from, or if it''s null');
        END IF;
        --
        -- Lets see the SQL statement
        msg('Finished building statement');
        msg('<sqlstatement>');
        msg(p_sql);
        msg('</sqlstatement>');
        --
        msg('Caching statement in record '||l_tab_idx);
        g_DATED_TABLE_EXTRAS(l_tab_idx).sql_statement := p_sql;
        --
    END get_additional_select;
    --
    -- < PUBLIC FUNCTIONS > --------------------------------------------------
    --
    -- Return the "all supervisors" constant
    FUNCTION all_supervisors_id RETURN NUMBER IS
    BEGIN
        RETURN c_ALL_SUPERVISORS_ID;
    END all_supervisors_id;
    --
    -- Return the "blank location" constant
    FUNCTION blank_location_id RETURN NUMBER IS
    BEGIN
        RETURN c_BLANK_LOCATION_ID;
    END blank_location_id;
    --
    -- Get the event group ID based on its name and initialise the cache
    PROCEDURE init_event_group_cache(p_event_group_name IN VARCHAR2) IS
        --
        CURSOR get_evt(p_grp IN VARCHAR2) IS
            SELECT          event_group_id
            FROM            pay_event_groups
            WHERE           event_group_name = p_grp;
        --
    BEGIN
	--
        -- Find the event group ID, raises no_data_found
        -- if the event group name is invalid (i.e. not found)
	-- 2984406 - Fetch into a global ID to save repeated queries to get the ID
        OPEN get_evt(p_event_group_name);
        FETCH get_evt INTO g_EVENT_GROUP_ID;
        IF get_evt%NOTFOUND THEN
            -- Trace some debug info and raise the error
            dbg('Event group "'||p_event_group_name||'" not found.');
            CLOSE get_evt;
            RAISE event_group_not_found;
        END IF;
        CLOSE get_evt;
	--
	-- Populate the internal package global caches to hold details of all
        -- the dated tables that this event group uses
        pay_interpreter_pkg.event_group_tables(g_EVENT_GROUP_ID);
        --
        -- Make sure we've got enough extra information records for all the
        -- dated tables we're going to use
        FOR i IN pay_interpreter_pkg.t_distinct_tab.FIRST .. pay_interpreter_pkg.t_distinct_tab.LAST LOOP
            g_DATED_TABLE_EXTRAS(i).has_supervisor_id := 'X';
            g_DATED_TABLE_EXTRAS(i).has_location_id   := 'X';
            g_DATED_TABLE_EXTRAS(i).has_assignment_id := 'X';
            g_DATED_TABLE_EXTRAS(i).sql_statement     := NULL;
        END LOOP;
        --
    END init_event_group_cache;
    --
    -- < PUBLIC PROCEDURES > -------------------------------------------------
    --
    -- Get the event group ID based on its name
    FUNCTION get_event_group_id(p_event_group_name IN VARCHAR2) RETURN NUMBER IS
    BEGIN
        IF g_EVENT_GROUP_ID IS NULL THEN
	    init_event_group_cache(p_event_group_name);
	END IF;
	RETURN g_EVENT_GROUP_ID;
    END get_event_group_id;
    --
    -- Log a message, either using fnd_file, or hr_utility.trace
    PROCEDURE msg(p_text IN VARCHAR2) IS
        l_pos   NUMBER := 1;
        l_txt   VARCHAR2(255);
    BEGIN
        --
        -- Chop up the string into 250 char chunks if we're writing to the
        -- concurrent manager log file
        IF g_concurrent THEN
            LOOP
                l_txt := SUBSTR(p_text,l_pos,c_OUTPUT_LINE_LENGTH);
                fnd_file.put_line(fnd_file.LOG,l_txt);
                --
                l_pos := l_pos + c_OUTPUT_LINE_LENGTH;
                EXIT WHEN l_pos > LENGTH(p_text);
            END LOOP;
        ELSE
            -- Use the normal trace stuff
            hr_utility.trace(p_text);
        END IF;
    END msg;
    --
    PROCEDURE dbg(p_text IN VARCHAR2) IS
    BEGIN
        IF g_debugging THEN
            msg(p_text);
        END IF;
    END dbg;
    --
    -- Switch on or off client debugging.
    PROCEDURE set_client_debugging(p_on IN BOOLEAN) IS
    BEGIN
        -- Stubbed out because we're not allowed to use dbms_output
        RAISE feature_not_supported;
    END set_client_debugging;
    --
    -- Replacement for the above - allow logging to concurrent manager log
    PROCEDURE set_concurrent_logging(p_on IN BOOLEAN) IS
    BEGIN
        g_concurrent := p_on;
    END set_concurrent_logging;
    --
    -- Switch debugging messages on
    PROCEDURE set_debugging(p_on IN BOOLEAN) IS
    BEGIN
        g_debugging := p_on;
    END set_debugging;
    --
    -- Process the detailed output information from an assignment event
    PROCEDURE process_event_details(
        p_detailed_output   IN      pay_interpreter_pkg.t_detailed_output_table_type,
        p_proration_dates   IN      pay_interpreter_pkg.t_proration_dates_table_type,
        p_summary_refresh   IN OUT  NOCOPY t_summary_refresh_tab_type,
        p_location_stripe   IN      BOOLEAN DEFAULT FALSE
    ) IS
        --
        -- Local variables
        l_idx                   NUMBER;
        --
        -- The SQL statement we'll need to use to get the supervisor ID
        -- and the dynamic cursor stuff
        TYPE t_csr IS REF CURSOR;
        --
        l_csr                   t_csr;
        l_sql                   VARCHAR2(2000);
        l_supv                  NUMBER;
        l_loct                  NUMBER;
        l_sdt                   DATE;
        l_edt                   DATE;
        --
    BEGIN
        --
        -- Make sure we have some detailed output and some dates
        IF NVL(p_detailed_output.FIRST,0) < 1 AND
           NVL(p_proration_dates.FIRST,0) < 1
        THEN
            msg('No detailed output supplied to process_event_details, ignoring');
            RETURN;
        END IF;
        --
        -- There should be the same number of records in the detailed output
        -- and proration dates tables, if not then that's an error since we need
        -- to have an effective date for each event
        IF p_detailed_output.FIRST <> p_proration_dates.FIRST OR
           p_detailed_output.LAST <> p_proration_dates.LAST
        THEN
            -- Trace some debug info and raise a custom error
            msg('Records in detailed output don''t match those in proration dates.');
            msg('t_detailed_output = '||p_detailed_output.FIRST||' -> '||p_detailed_output.LAST);
            msg('t_proration_dates = '||p_proration_dates.FIRST||' -> '||p_proration_dates.LAST);
            RAISE mismatch_when_summarizing;
        END IF;
        --
        -- Process each record in the detailed output
        FOR i IN p_detailed_output.FIRST .. p_detailed_output.LAST LOOP
            --
            -- Debugging information for event found
            msg(
                'Processing event found at '||
                dec_date(p_proration_dates(i))||'/'||inc_date(p_proration_dates(i))||' on '||
                p_detailed_output(i).dated_table_id||' ID '||
                p_detailed_output(i).surrogate_key
            );
            --
            -- Build the query to get the additional IDs based on the
            -- information about the dated table that the event occurred on,
            -- must always include the 3 bind variables; surrogate_key,
            -- effective_start/end_date
            get_additional_select(
                p_detailed_output(i).dated_table_id,
                p_location_stripe,
                l_sql
            );
            --
            -- Open a cursor for the SQL we just built
            OPEN l_csr FOR l_sql USING
	        p_detailed_output(i).surrogate_key,
		dec_date(p_proration_dates(i)),
		inc_date(p_proration_dates(i));
            LOOP
                -- Get the IDs and bail when we run out
                FETCH l_csr INTO l_supv,l_loct,l_sdt,l_edt;
                EXIT WHEN l_csr%NOTFOUND;
                --
                -- Find the entry in the summary table
                --
                get_summary_idx(l_supv, l_loct, l_idx, p_summary_refresh);
                --
                -- The start date is the earliest out of the currently recorded effective date
                -- for this combination (NVL'd in case we haven't recorded anything yet) and the
                -- effective date of the event we're recording
                p_summary_refresh(l_idx).effective_start_date := LEAST(
                    NVL(
                        p_summary_refresh(l_idx).effective_start_date,
                        p_proration_dates(i)
                    ),
                    dec_date(l_sdt)
                );
                --
                -- Update the end date similarly, but with the most recent of the two dates
                p_summary_refresh(l_idx).effective_end_date := GREATEST(
                    NVL(
                        p_summary_refresh(l_idx).effective_end_date,
                        p_proration_dates(i)
                    ),
                    inc_date(l_edt)
                );
                --
            END LOOP;
            --
            -- Done with the cursor;
            CLOSE l_csr;
        END LOOP;
        --
    END process_event_details;
    --
    -- Build up the SQL query for determining date-effective updates
    FUNCTION build_csr_dt_updates(p_dtid IN NUMBER,p_dtname IN VARCHAR2,p_eeid IN NUMBER) RETURN VARCHAR2 IS
        --
	-- Get a list of the columns that are in the event group and table
        CURSOR get_columns(p_evt IN NUMBER,p_tab IN NUMBER) IS
            SELECT column_name
            FROM   pay_datetracked_events pde
            WHERE  event_group_id = p_evt
            AND    dated_table_id = p_tab
            AND    update_type = 'U';
        --
        l_qry VARCHAR2(32767);
    BEGIN
        l_qry := 'SELECT n.assignment_id, ';
	--
	IF p_dtid = p_eeid THEN
	    l_qry := l_qry||'n.element_entry_id, ';
	END IF;
	--
        l_qry := l_qry||
	         '       MIN(LEAST(o.effective_start_date,n.effective_start_date)) effective_start_date, '||
                 '       MAX(GREATEST(o.effective_start_date,n.effective_start_date)) effective_end_date '||
                 'FROM   '||p_dtname||' n, '||
                 '       '||p_dtname||' o '||
                 'WHERE n.assignment_id = o.assignment_id '||
                 'AND n.effective_start_date = o.effective_end_date + 1 '||
                 'AND (';
        --
        FOR col_rec IN get_columns(g_EVENT_GROUP_ID,p_dtid) LOOP
            IF get_columns%rowcount > 1 THEN
                l_qry := l_qry||' OR ';
            END IF;
            --
            l_qry := l_qry||'NVL(TO_CHAR(o.'||col_rec.column_name||'), ''$Sys_Def$'') <> '||
                            'NVL(TO_CHAR(n.'||col_rec.column_name||'), ''$Sys_Def$'')';
            --
        END LOOP;
        --
        l_qry := l_qry ||') '||
	             'AND n.assignment_id IN ('||
		     'SELECT '||
		     '    ppe.assignment_id '||
		     '    FROM pay_process_events ppe,pay_event_updates peu '||
		     '    WHERE ppe.creation_date BETWEEN :1 AND :2 '||
		     '    AND peu.event_update_id = ppe.event_update_id '||
		     '    AND peu.dated_table_id = '||p_dtid||
		    ') '||
                    'GROUP BY n.assignment_id';
	IF p_dtid = p_eeid THEN
	    l_qry := l_qry||',n.element_entry_id';
	END IF;
	--
	RETURN l_qry;
    END build_csr_dt_updates;
    --
    FUNCTION get_element_entry_table_id RETURN NUMBER IS
        l_element_entries_dt_id NUMBER;
    BEGIN
    	--
	-- Get the (special case) element entries table ID
	BEGIN
	    SELECT  dated_table_id
	    INTO    l_element_entries_dt_id
	    FROM    pay_dated_tables
	    WHERE   table_name = 'PAY_ELEMENT_ENTRIES_F';
	EXCEPTION
	    WHEN OTHERS THEN l_element_entries_dt_id := NULL;
	END;
	RETURN l_element_entries_dt_id;
    END get_element_entry_table_id;
--
    --
    -- Is the Entry Id supplied a Salary Element
    --
    FUNCTION is_salary(p_ee_id in number)
    RETURN BOOLEAN IS
      l_dummy number;
    BEGIN
--
       select /*+ ordered */ distinct pee.element_entry_id
         into l_dummy
         from pay_element_entries_f    pee,
              per_all_assignments_f    paf,
              per_pay_bases            ppb,
              pay_element_entry_values_f peev
        where pee.element_entry_id = p_ee_id
          and pee.assignment_id = paf.assignment_id
          and paf.pay_basis_id = ppb.pay_basis_id
          and pee.element_entry_id = peev.element_entry_id
          and ppb.input_value_id = peev.input_value_id;
--
         return TRUE;
--
    EXCEPTION
         when no_data_found then
            return FALSE;
--
    END is_salary;
    --
    -- Get a list of the assignments that have events recorded for them.
    -- Bug 2984406: Restructure to fetch affected assignments in three stages,
    -- basically changes the whole structure of this procedure
    PROCEDURE get_assignments_affected(
        p_start_date        IN      DATE,
        p_end_date          IN      DATE,
        p_assignments       IN OUT  NOCOPY t_assignment_id_tab_type
    ) IS
        --
        l_csr 				csr_dyn_ref;
        l_qry 				VARCHAR2(32767);
	l_assignment_id 		NUMBER;
	l_element_entry_id 		NUMBER;
	l_effective_start_date 		DATE;
	l_effective_end_date 		DATE;
	l_element_entries_dt_id 	NUMBER;
	--
        l_loop NUMBER;
        curr_ass_id NUMBER;
        new_assignment BOOLEAN;
        --
    BEGIN
        -- Get the affected assignments
        msg('Getting affected assignments for '||fnd_date.date_to_canonical(p_start_date)||' '||fnd_date.date_to_canonical(p_end_date));
        l_loop := 0;
        l_element_entries_dt_id := get_element_entry_table_id;
	--
	-- Get those affected by inserts and deletes
	msg('Getting inserts and deletes');
        curr_ass_id := -1;
        FOR assrec in csr_all_changes(p_start_date,p_end_date) loop
--
            if(curr_ass_id <> assrec.assignment_id) then
               curr_ass_id := assrec.assignment_id;
               new_assignment := TRUE;
            end if;
--
            /* If the table is element entries then we need to do some thing */
            if assrec.dated_table_id = l_element_entries_dt_id then
--
                  if( is_salary(assrec.surrogate_key) = TRUE) then
--
                    /* It is salary, here comes the tricky part
                    */
                    if (new_assignment = TRUE) then
                      l_loop := l_loop + 1;
                      p_assignments(l_loop).element_entry_id
                                    := assrec.surrogate_key;
                      p_assignments(l_loop).assignment_id
                                    := assrec.assignment_id;
                      p_assignments(l_loop).effective_start_date
                                    := dec_date(assrec.effective_start_date);
                      p_assignments(l_loop).effective_end_date
                                    := inc_date(assrec.effective_end_date);
                      new_assignment := FALSE;
                    else
                      if (p_assignments(l_loop).element_entry_id is null) then
                         p_assignments(l_loop).element_entry_id
                           := assrec.surrogate_key;
                         p_assignments(l_loop).effective_start_date
                           := least(p_assignments(l_loop).effective_start_date,
                                    dec_date(assrec.effective_start_date));
                         p_assignments(l_loop).effective_end_date
                           := greatest(p_assignments(l_loop).effective_end_date,
                                       inc_date(assrec.effective_end_date));
                      else
                         /* Yeah we really need to create a new one */
                         l_loop := l_loop + 1;
                         p_assignments(l_loop).element_entry_id
                                       := assrec.surrogate_key;
                         p_assignments(l_loop).assignment_id
                                       := assrec.assignment_id;
                         p_assignments(l_loop).effective_start_date
                                       := dec_date(assrec.effective_start_date);
                         p_assignments(l_loop).effective_end_date
                                       := inc_date(assrec.effective_end_date);
                      end if;
                    end if;
--
                  else
                     /* do nothing it's not salary, hence
                        not interested
                     */
                     null;
                  end if;
--
            else
                /* It's not an element entry change.
                   Check that a row has not already been placed
                   in the pl/sql table for this assignment
                   If it has just adjust the dates.
                */
                if (new_assignment = TRUE) then
                   l_loop := l_loop + 1;
                   p_assignments(l_loop).element_entry_id := NULL;
                   p_assignments(l_loop).assignment_id
                                 := assrec.assignment_id;
                   p_assignments(l_loop).effective_start_date
                                 := dec_date(assrec.effective_start_date);
                   p_assignments(l_loop).effective_end_date
                                 := inc_date(assrec.effective_end_date);
                   new_assignment := FALSE;
                else
                   p_assignments(l_loop).effective_start_date
                       := least(p_assignments(l_loop).effective_start_date,
                                dec_date(assrec.effective_start_date));
                   p_assignments(l_loop).effective_end_date
                       := greatest(p_assignments(l_loop).effective_end_date,
                                   inc_date(assrec.effective_end_date));
                end if;
            end if;
        END LOOP;
        --
        IF NVL(p_assignments.FIRST,0) < 1 THEN
            msg('No assignment events found within specified date range');
            RAISE no_assignment_events_found;
        END IF;
        --
    END get_assignments_affected;
    --
    -- Get the payroll event details based on a list of assignment IDs
    PROCEDURE get_refresh_periods(
        p_assignments       IN OUT  NOCOPY t_assignment_id_tab_type,
        p_summary_refresh   IN OUT  NOCOPY t_summary_refresh_tab_type,
        p_start_date        IN      DATE,
        p_end_date          IN      DATE,
        p_location_stripe   IN      BOOLEAN DEFAULT FALSE
    ) IS
        --
        -- Local table-type variables for use with processing the event details
        l_detailed_output       pay_interpreter_pkg.t_detailed_output_table_type;
        l_proration_dates       pay_interpreter_pkg.t_proration_dates_table_type;
        --
    BEGIN
        --
        -- Check we've got something to process
        IF NVL(p_assignments.FIRST,0) < 1 THEN
            msg('No data from process in get_assignment_events');
            RAISE no_assignments_supplied;
        END IF;
        --
        -- Process all the assignments we got
        FOR i IN p_assignments.FIRST .. p_assignments.LAST LOOP
--
            l_detailed_output.delete;
            l_proration_dates.delete;
            --
            -- Get the detailed event information for this assignment
            get_event_details(
                p_start_date,
                p_end_date,
                p_assignments(i).assignment_id,
		p_assignments(i).element_entry_id,
                l_detailed_output,
                l_proration_dates
            );
            --
            -- Process the event details for this assignment
            -- (a check is done within this procedure for the detailed output being empty)
            msg(
                'Processing event details ('||
                p_assignments(i).assignment_id||' '||
                p_assignments(i).effective_start_date||' -> '||
                p_assignments(i).effective_end_date||')'
            );
            process_event_details(
                l_detailed_output,
                l_proration_dates,
                p_summary_refresh,
                p_location_stripe
            );
        END LOOP;
    END get_refresh_periods;
    --
    -- If we recorded some information for "all records" (i.e. an event ocurred on a
    -- table which didn't allow us to get a proper supervisor or location ID)
    -- then we need to delete any specific records that fall completely within
    -- "refresh all" period, and chop up any records that just overlap that period, otherwise
    -- we'll just copy the temporary table to the output parameter
    PROCEDURE de_dupe_refresh_periods(
        p_summary_refresh_temp  IN OUT NOCOPY t_summary_refresh_tab_type,
        p_summary_refresh       IN OUT NOCOPY t_summary_refresh_tab_type,
        p_all_supv              IN OUT NOCOPY BOOLEAN,
        p_out_num               IN OUT NOCOPY NUMBER,
        p_all_start             IN OUT NOCOPY DATE,
        p_all_end               IN OUT NOCOPY DATE,
        p_want_location         IN     BOOLEAN DEFAULT FALSE
    ) IS
    BEGIN
        p_all_supv := FALSE;
        p_out_num  := 0;
        --
        IF NVL(p_summary_refresh_temp.FIRST,0) > 0 THEN
            --
            -- Find the "all" record
            FOR i IN p_summary_refresh_temp.FIRST .. p_summary_refresh_temp.LAST LOOP
                IF p_summary_refresh_temp(i).supervisor_id = c_ALL_SUPERVISORS_ID OR
                   (p_summary_refresh_temp(i).location_id = c_BLANK_LOCATION_ID AND p_want_location)
                THEN
                    p_all_start := p_summary_refresh(i).effective_start_date;
                    p_all_end := p_summary_refresh(i).effective_end_date;
                    p_all_supv := TRUE;
                END IF;
            END LOOP;
            --
            IF p_all_supv THEN
                --
                -- If either the start or end date is null then bail
                IF p_all_start IS NULL OR p_all_end IS NULL THEN
                    msg('An "all" record was missing one or other of the required dates');
                    RAISE missing_dates_in_all_record;
                END IF;
                --
                -- Record the "all" record
                p_out_num := p_out_num + 1;
                p_summary_refresh(p_out_num).supervisor_id := c_ALL_SUPERVISORS_ID;
                p_summary_refresh(p_out_num).location_id := c_BLANK_LOCATION_ID;
                p_summary_refresh(p_out_num).effective_start_date := p_all_start;
                p_summary_refresh(p_out_num).effective_end_date := p_all_end;
                --
                -- Go through the other records (skipping the "all" one) and chopping the dates
                FOR i IN p_summary_refresh_temp.FIRST .. p_summary_refresh_temp.LAST LOOP
                    IF p_summary_refresh_temp(i).supervisor_id <> c_ALL_SUPERVISORS_ID AND
                       (p_summary_refresh_temp(i).location_id <> c_BLANK_LOCATION_ID OR (NOT p_want_location))
                    THEN
                        --
                        -- If either the start or end date is null then bail
                        IF p_summary_refresh_temp(i).effective_start_date IS NULL OR
                           p_summary_refresh_temp(i).effective_end_date IS NULL
                        THEN
                            msg(
                                'A specific ('||p_summary_refresh_temp(i).supervisor_id||
                                '/'||p_summary_refresh_temp(i).location_id||
                                ') refresh record is missing a start or end date'
                            );
                            RAISE missing_dates_for_specific;
                        END IF;
                        --
                        -- If the specific refresh record falls completely within the "all"
                        -- period the don't process it
                        IF p_summary_refresh_temp(i).effective_start_date >= p_all_start AND
                           p_summary_refresh_temp(i).effective_end_date <= p_all_end
                        THEN
                            msg(
                                'Specific '||p_summary_refresh_temp(i).supervisor_id||
                                '/'||p_summary_refresh_temp(i).location_id||
                                ' falls entirely within "all" refresh period, ignoring.'
                            );
                        ELSE
                            -- If this record starts before the "all" period then record a segment
                            IF p_summary_refresh_temp(i).effective_start_date < p_all_start THEN
                                msg(
                                    'Specific '||p_summary_refresh_temp(i).supervisor_id||
                                    '/'||p_summary_refresh_temp(i).location_id||
                                    ' starts before the "all" refresh period, processing.'
                                );
                                --
                                p_out_num := p_out_num + 1;
                                p_summary_refresh(p_out_num) := p_summary_refresh_temp(i);
                                p_summary_refresh(p_out_num).effective_end_date := p_all_start - 1;
                            END IF;
                            --
                            -- If this record end after the "all" period then record a segment
                            IF p_summary_refresh_temp(i).effective_end_date > p_all_end THEN
                                msg(
                                    'Specific '||p_summary_refresh_temp(i).supervisor_id||
                                    '/'||p_summary_refresh_temp(i).location_id||
                                    ' ends after the "all" refresh period, processing.'
                                );
                                --
                                p_out_num := p_out_num + 1;
                                p_summary_refresh(p_out_num) := p_summary_refresh_temp(i);
                                p_summary_refresh(p_out_num).effective_start_date := p_all_end + 1;
                            END IF;
                        END IF;
                    END IF;
                END LOOP;
                --
            ELSE
                -- No "all" period, just copy everything to the output parameter
                FOR i IN p_summary_refresh_temp.FIRST .. p_summary_refresh_temp.LAST LOOP
                    --
                    -- If either the start or end date is null then bail
                    IF p_summary_refresh_temp(i).effective_start_date IS NULL OR
                       p_summary_refresh_temp(i).effective_end_date IS NULL
                    THEN
                        msg('A specific ('||
                            p_summary_refresh_temp(i).supervisor_id||'/'||
                            p_summary_refresh_temp(i).location_id||
                            ') refresh record is missing a start or end date'
                        );
                        RAISE missing_dates_for_specific;
                    END IF;
                    --
                    p_out_num := p_out_num + 1;
                    p_summary_refresh(p_out_num) := p_summary_refresh_temp(i);
                END LOOP;
            END IF;
        END IF;
        --
    END de_dupe_refresh_periods;
    --
    -- Add a record to the refresh table, as long as it's not there already
    PROCEDURE add_summary_refresh_record(
        p_idx                IN OUT NOCOPY NUMBER,
        p_table              IN OUT NOCOPY t_summary_refresh_tab_type,
        p_supervisor         IN     NUMBER,
        p_start_date         IN     DATE,
        p_end_date           IN     DATE,
        p_location           IN     NUMBER,
        p_update_mode        IN     BOOLEAN
    ) IS
        l_found     NUMBER := -1;
    BEGIN
        --
        get_summary_idx(p_supervisor, p_location, p_idx, p_table);
        --
        p_table(p_idx).effective_start_date :=
                          LEAST(dec_date(p_start_date),
                                nvl(p_table(p_idx).effective_start_date,
                                    p_start_date));
        p_table(p_idx).effective_end_date :=
                          GREATEST(inc_date(p_end_date),
                                   nvl(p_table(p_idx).effective_end_date,
                                       p_end_date));
        --
    END add_summary_refresh_record;
    --
    -- Add any date track corrections to supervisor ID on per_all_assignments_f
    -- if we've got that column in our event group
    PROCEDURE add_supervisor_corrections(
        p_summary_refresh   IN OUT  NOCOPY t_summary_refresh_tab_type,
        p_start_date        IN      DATE,
        p_end_date          IN      DATE,
        p_location_stripe   IN      BOOLEAN DEFAULT FALSE
    ) IS
        --
        l_start                 NUMBER      := NVL(p_summary_refresh.LAST,0) + 1;
        l_idx                   NUMBER      := l_start;
        l_end                   NUMBER;
        l_stripe                VARCHAR2(1) := 'N';
        --
    BEGIN
        msg('Adding supervisor ID correction changes');
        dbg('Start index is at row '||l_idx);
        dbg('Parameters are (not including output table):');
        dbg('p_start_date => '||fnd_date.date_to_canonical(p_start_date));
        dbg('p_end_date => '||fnd_date.date_to_canonical(p_end_date));
        --
        dbg('g_EVENT_GROUP_ID => '||g_EVENT_GROUP_ID);
        --
        -- Switch on location striping if desired
        IF p_location_stripe THEN
            dbg('Switching on location striping');
            l_stripe := 'Y';
        END IF;
        dbg('p_location_stripe => '||l_stripe);
        --
        -- Get all supervisor ID changes and add them to the list of refresh periods
        FOR l_rec IN csr_supv_corrections(
            g_EVENT_GROUP_ID,
            p_start_date,
            p_end_date,
            l_stripe
        ) LOOP
            add_summary_refresh_record(
                l_idx,
                p_summary_refresh,
                l_rec.assignment_or_supervisor_id,
                l_rec.effective_start_date,
                l_rec.effective_end_date,
                l_rec.table_or_location_id,
                p_update_mode => FALSE
            );
        END LOOP;
        --
        -- Make sure we added some rows to the table, this isn't a fatal exception
        -- yet 'cos we could already have something in the table
        l_end := NVL(p_summary_refresh.LAST,0) + 1;
        dbg('End index is now at row '||l_end);
        IF l_start = l_end THEN
            RAISE no_supervisor_corrections;
        END IF;
        --
    END add_supervisor_corrections;
    --
    -- Get the list of supervisors and the date range across which
    -- each of those supervisors should be refreshed.
    PROCEDURE get_summaries_affected(
        p_event_group     IN     VARCHAR2,
        p_start_date      IN     DATE,
        p_end_date        IN     DATE,
        p_summary_refresh IN OUT NOCOPY t_summary_refresh_tab_type,
        p_location_stripe IN     BOOLEAN DEFAULT FALSE,
        p_raise_no_data   IN     BOOLEAN DEFAULT FALSE
    ) IS
        --
        -- A list of assignments that events have ocurred for
        l_assignments           t_assignment_id_tab_type;
        --
        -- Temporary table to store the results in, before we post-process it
        -- to handle "all supervisor refresh" events
        l_summary_refresh_temp  t_summary_refresh_tab_type;
        --
        -- Parameters used to process the "all supervisor refresh" events
        l_all_supv              BOOLEAN;
        l_out_num               NUMBER;
        l_all_start             DATE;
        l_all_end               DATE;
        --
        -- Profiling (timing) variables
        l_start                 NUMBER;
	l_curr                  NUMBER;
        --
    BEGIN
        --
        dbg('Running get_summaries_affected, parameters;');
        dbg('p_event_group => '||p_event_group);
        dbg('p_start_date => '||p_start_date);
        dbg('p_end_date => '||p_end_date);
        IF p_location_stripe THEN
            dbg('p_location_stripe => TRUE');
        ELSE
            dbg('p_location_stripe => FALSE');
        END IF;
        IF p_raise_no_data THEN
            dbg('p_raise_no_data => TRUE');
        ELSE
            dbg('p_raise_no_data => FALSE');
        END IF;
        --
        -- Get the current time (100th's of a second)
        l_start := dbms_utility.get_time;
        g_SECONDS_ELAPSED := 0;
        --
        -- Clear out the results table, and the event group cache
        p_summary_refresh.DELETE;
	g_DATED_TABLE_EXTRAS.DELETE;
	g_EVENT_GROUP_ID := NULL;
	--
	-- Initialise the events group cache
	-- 2984406: Moved to here, instead of on a per-assignment basis
	init_event_group_cache(p_event_group);
        --
        BEGIN
            --
            -- Get all the assignment IDs for which events
            -- have occurred, but ignore supervisor ID changes
            get_assignments_affected(
                p_start_date,
                p_end_date,
                l_assignments
            );
            --
            -- Process all the assignments we found
            get_refresh_periods(
                l_assignments,
                l_summary_refresh_temp,
                p_start_date,
                p_end_date,
                p_location_stripe
            );
        EXCEPTION WHEN no_assignment_events_found THEN
            msg('No affected assignments were found in the refresh period');
        END;
        --
        BEGIN
            --
            -- Add the refresh periods for changes to the supervisor ID column
            add_supervisor_corrections(
                l_summary_refresh_temp,
                p_start_date,
                p_end_date,
                p_location_stripe
            );
        EXCEPTION WHEN no_supervisor_corrections THEN
            msg('No datetrack corrections to supervisor ID were found within refresh period');
        END;
        --
        -- Check that we've got something in the summary refresh table
        IF NVL(l_summary_refresh_temp.LAST,0) <= 0 THEN
            msg('No records in refresh table, nothing to do');
            dbg('Finished get_summaries_affected');
	    --
	    -- Record the time taken (to get nothing!)
	    l_curr := dbms_utility.get_time;
            g_SECONDS_ELAPSED := (l_curr - l_start) / 100;
            msg(get_elapsed_time_text);
            --
	    -- Clear the looping globals
	    g_FIRST_RECORD := 0;
	    g_LAST_RECORD := 0;
    	    g_CURRENT_RECORD := 0;
	    --
            RETURN;
        END IF;
        --
        -- De-duplicate the records, what this means is that we remove any
        -- portions of refresh records for specific supervisors that overlap
        -- the "all" period. This period will always be contiguous, after the
        -- de-dupe process the specific supervisor records may not be.
        de_dupe_refresh_periods(
            l_summary_refresh_temp,
            p_summary_refresh,
            l_all_supv,
            l_out_num,
            l_all_start,
            l_all_end
        );
        --
        -- We've finished. Record some diagnostics trace information
        msg('Supervisor refresh events recorded: '||l_out_num);
        IF NOT l_all_supv THEN
            msg('There is no "refresh all" period');
        ELSE
            msg('Refresh all supervisors for: '||l_all_start||' -> '||l_all_end);
        END IF;
	--
	-- Record the time taken for the full run
	l_curr := dbms_utility.get_time;
        g_SECONDS_ELAPSED := (l_curr - l_start) / 100;
        msg(get_elapsed_time_text);
        --
	-- Initialise the globals we use for simplified record looping
	g_FIRST_RECORD := NVL(p_summary_refresh.FIRST,0);
	g_LAST_RECORD := NVL(p_summary_refresh.LAST,0);
	g_CURRENT_RECORD := 0;
        --
        -- If we asked then raise no_data_found if there's no data in the table
        dbg('Finished get_summaries_affected');
        IF p_raise_no_data THEN
            IF NVL(p_summary_refresh.FIRST,0) <= 0 THEN
                RAISE no_data_found;
            END IF;
        END IF;
    END get_summaries_affected;
    --
    FUNCTION next_record RETURN BOOLEAN IS
    BEGIN
        g_CURRENT_RECORD := g_CURRENT_RECORD + 1;
	RETURN (g_CURRENT_RECORD >= g_FIRST_RECORD AND g_CURRENT_RECORD <= g_LAST_RECORD);
    END next_record;
    --
    FUNCTION current_record RETURN NUMBER IS
    BEGIN
        RETURN LEAST(g_CURRENT_RECORD,g_LAST_RECORD + 1);
    END current_record;
    --
END pay_events_wrapper;

/
