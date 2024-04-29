--------------------------------------------------------
--  DDL for Package Body HRI_DBI_WMV_SEPARATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_DBI_WMV_SEPARATION" AS
/* $Header: hridbite.pkb 115.21 2003/06/17 23:57:49 exjones noship $ */
    --
    -- ***********************************************************************
    -- * Private globals and types                                           *
    -- ***********************************************************************
    --
    -- Cache separations against subordinates (inc. direct reports)
    TYPE t_subord_cache_rec IS RECORD(
        subordinate_id          NUMBER,
        voluntary_seps          NUMBER,
        involuntary_seps        NUMBER
    );
    TYPE t_subord_cache_table IS
        TABLE OF t_subord_cache_rec
        INDEX BY BINARY_INTEGER;
    --
    -- Cache subordinate rows against supervisors
    TYPE t_supv_cache_rec IS RECORD(
        supervisor_id       NUMBER,
        subordinate_rows    t_subord_cache_table
    );
    TYPE t_supv_cache_table IS
        TABLE OF t_supv_cache_rec
        INDEX BY BINARY_INTEGER;
    --
    -- Cache all supervisor separations against effective dates
    TYPE t_effdt_cache_rec IS RECORD(
        effective_date      DATE,
        supervisor_rows     t_supv_cache_table
    );
    TYPE t_effdt_cache_table IS
        TABLE OF t_effdt_cache_rec
        INDEX BY BINARY_INTEGER;
    --
    -- Global setup variables
    g_appl_err              CONSTANT NUMBER       := -20000;
    g_direct_insert         CONSTANT BOOLEAN      := FALSE;
    g_debugging                      BOOLEAN;
    g_concurrent                     BOOLEAN;
    --
    -- Globals for who columns
    g_who_id                         NUMBER;
    g_who_date                       DATE;
    g_who_version                    NUMBER;
    g_who_login                      NUMBER;
    g_who_request                    NUMBER;
    g_who_application                NUMBER;
    g_who_program                    NUMBER;
    --
    -- Global workforce measurement type
    g_global_wmt                     VARCHAR2(30);
    --
    -- Globals for messages to output to the logs
    g_success_message                VARCHAR2(2000);
    g_failure_message                VARCHAR2(2000);
    g_start_full_msg                 VARCHAR2(2000);
    g_start_delta_msg                VARCHAR2(2000);
    g_setup_failure                  VARCHAR2(2000);
    --
    -- Cache all inserts to save us going back and forth to the summary table
    g_insert_cache                   t_effdt_cache_table;
    --
    -- Shared cursor to traverse up the supervisor hierarchy
    CURSOR get_supsup(
        cp_sup_id   IN NUMBER,
        cp_eff_dt   IN DATE
    ) IS
        SELECT    sup_person_id,
                  sub_relative_level,
                  0 row_number
        FROM      hri_cs_suph_v
        WHERE     sub_person_id = cp_sup_id
        AND       sub_relative_level > 0
        AND       cp_eff_dt BETWEEN effective_start_date AND effective_end_date
        ORDER BY  sub_relative_level ASC;
    --
    -- ***********************************************************************
    -- * Get the global WMT we're going to use                               *
    -- ***********************************************************************
    FUNCTION global_wmt RETURN VARCHAR2 IS
    BEGIN
        RETURN g_global_wmt;
    END global_wmt;
    --
    -- ***********************************************************************
    -- * Log a message using the BIS refresh framework logging routine       *
    -- ***********************************************************************
    PROCEDURE msg(p_msg IN VARCHAR2) IS
    BEGIN
        IF g_concurrent THEN
            bis_collection_utilities.log(p_msg,0);
        ELSE
            hr_utility.trace(p_msg);
        END IF;
    END msg;
    --
    PROCEDURE dbg(p_msg IN VARCHAR2) IS
    BEGIN
        IF g_debugging THEN
            msg(p_msg);
        END IF;
    END dbg;
    --
    PROCEDURE set_debugging(p_on IN BOOLEAN) IS
    BEGIN
        g_debugging := p_on;
    END set_debugging;
    --
    PROCEDURE set_concurrent_logging(p_on IN BOOLEAN) IS
    BEGIN
        g_concurrent := p_on;
    END set_concurrent_logging;
    --
    -- ***********************************************************************
    -- * Initialise all the global values                                    *
    -- ***********************************************************************
    PROCEDURE initialise_globals IS
    BEGIN
        g_who_id          := fnd_global.user_id;
        g_who_date        := TRUNC(SYSDATE);
        g_who_version     := 1;
        g_who_login       := fnd_global.conc_login_id;
        g_who_request     := fnd_global.conc_request_id;
        g_who_application := fnd_global.prog_appl_id;
        g_who_program     := fnd_global.conc_program_id;
        --
        g_global_wmt      := bis_common_parameters.get_workforce_mes_type_id;
        --
        g_start_full_msg  := 'Begin summary refresh full update run...';
        g_start_delta_msg := 'Begin summary refresh delta update run...';
        g_success_message := 'Refresh run completed successfully.';
        g_failure_message := 'Refresh run failed: ';
        g_setup_failure   := 'A failure occurred using the BIS run setup routine.';
        --
        g_debugging       := FALSE;
        g_concurrent      := TRUE;
        --
    END initialise_globals;
    --
    -- ***********************************************************************
    -- * Build the table of refresh records in exactly the same format as is *
    -- * returned from the payroll events wrapper, but based on the          *
    -- * effective dates rather than actual calendar dates                   *
    -- * Also deletes all appropriate records from the summary table         *
    -- ***********************************************************************
    PROCEDURE build_full_refresh_table(
        p_supv_tab      IN OUT NOCOPY pay_events_wrapper.t_summary_refresh_tab_type,
        p_start_date    IN      DATE,
        p_end_date      IN      DATE
    ) IS
        --
        -- Get a list of supervisors for which terminations have occurred
        -- between the dates specified, and the effective dates of those terminations
        CURSOR get_supervisors_affected(
            cp_start    IN      DATE,
            cp_end      IN      DATE
        ) IS
            SELECT  asg.supervisor_id                    supervisor_id,
                    MIN(pos.actual_termination_date-1)   effective_start_date,
                    MAX(pos.actual_termination_date+1)   effective_end_date
            FROM per_all_assignments_f     asg
               , per_periods_of_service    pos
            WHERE asg.supervisor_id IS NOT NULL
            AND asg.period_of_service_id = pos.period_of_service_id
            AND pos.actual_termination_date <= TRUNC(SYSDATE)
            AND asg.effective_end_date = pos.actual_termination_date
            AND pos.actual_termination_date BETWEEN cp_start AND cp_end
            GROUP BY asg.supervisor_id;
        --
        l_recs NUMBER;
        l_sql_stmt         VARCHAR2(500);
        l_dummy1           VARCHAR2(2000);
        l_dummy2           VARCHAR2(2000);
        l_schema           VARCHAR2(400);
        --
    BEGIN
        --
        -- Get all the supervisors for which separations have occurred
        -- within the date range specified
        msg('Finding all separations affected supervisors between '||p_start_date||' and '||p_end_date);
        l_recs := 0;
        FOR rec_supv IN get_supervisors_affected(p_start_date,p_end_date) LOOP
            l_recs := l_recs + 1;
            dbg('Supervisor('||l_recs||'): '||rec_supv.supervisor_id);
            p_supv_tab(l_recs).supervisor_id         := rec_supv.supervisor_id;
            p_supv_tab(l_recs).location_id           := pay_events_wrapper.blank_location_id;
            p_supv_tab(l_recs).effective_start_date  := rec_supv.effective_start_date;
            p_supv_tab(l_recs).effective_end_date    := rec_supv.effective_end_date;
        END LOOP;
        msg('Found '||NVL((p_supv_tab.LAST - p_supv_tab.FIRST)+1,0)||' ('||l_recs||') records');
        --
        -- Delete all our records from the summary table, regardless of
        -- dates and supervisors since this is a full refresh
        msg('Deleting all existing summary rows');
        IF (fnd_installation.get_app_info('PER',l_dummy1, l_dummy2, l_schema)) THEN

            l_sql_stmt := 'ALTER TABLE '|| l_schema ||'.HR_PTL_SUMMARY_DATA TRUNCATE PARTITION ' ||
                           information_category;
            EXECUTE IMMEDIATE(l_sql_stmt);
        END IF;
        --
        msg('Deleted all rows');
        --
    END build_full_refresh_table;
    --
    -- ***********************************************************************
    -- * Use the payroll events model wrapper to build the table of          *
    -- * supervisors that we need to refresh                                 *
    -- * Also deletes all appropriate records from the summary table         *
    -- ***********************************************************************
    PROCEDURE build_delta_refresh_table(
        p_supv_tab      IN OUT NOCOPY pay_events_wrapper.t_summary_refresh_tab_type,
        p_start_date    IN      DATE,
        p_end_date      IN      DATE
    ) IS
        --
        CURSOR get_deletes_todo(
            cp_id       IN NUMBER,
            cp_st       IN DATE,
            cp_en       IN DATE
        ) IS
            SELECT  summary_context_id  supervisor_id,
                    effective_date,
                    sum_information4 voluntary_char,
                    sum_information5 involuntary_char
            FROM    hr_ptl_summary_data
            WHERE   effective_date BETWEEN cp_st AND cp_en
            AND     summary_context_id = cp_id
            AND     sum_information_category = information_category;
        --
        l_sub_id      NUMBER;
        l_loop        NUMBER;
        --
    BEGIN
        --
        -- Use the payroll events model to calculate the supervisors and
        -- date ranges that we need to recalculate
        msg('Getting affected supervisors from Payroll Events Model wrapper');
        pay_events_wrapper.get_summaries_affected(
            p_event_group     => event_group,
            p_start_date      => p_start_date,
            p_end_date        => p_end_date,
            p_summary_refresh => p_supv_tab,
            p_location_stripe => FALSE,
            p_raise_no_data   => FALSE
        );
        msg('Found '||NVL((p_supv_tab.LAST - p_supv_tab.FIRST)+1,0)||' records');
        --
        -- Delete all summary records for the supervisors and date ranges
        -- we were given, since this is the data we're going to refresh
        IF NVL(p_supv_tab.FIRST,0) > 0 THEN
            msg('Deleting supervisor specific records and super-ordinate supervisors');
            FOR i IN p_supv_tab.FIRST .. p_supv_tab.LAST LOOP
                --
                -- Get the details of all the supervisors we're going to delete
                l_loop := 0;
                FOR del_rec IN get_deletes_todo(
                    p_supv_tab(i).supervisor_id,
                    p_supv_tab(i).effective_start_date,
                    p_supv_tab(i).effective_end_date
                ) LOOP
                    l_loop := l_loop + 1;
                    dbg(
                        'Processing deletes for '||
                        p_supv_tab(i).supervisor_id||' between '||
                        p_supv_tab(i).effective_start_date||' and '||
                        p_supv_tab(i).effective_end_date
                    );
                    --
                    -- First subordinate is the current supervisor
                    l_sub_id := del_rec.supervisor_id;
                    --
                    -- Get all the superordinates of the supervisor we're going to delete
                    FOR sup_rec IN get_supsup(
                        del_rec.supervisor_id,
                        del_rec.effective_date
                    ) LOOP
                        dbg(
                            'Removing '||del_rec.voluntary_char||'/'||del_rec.voluntary_char||' '||
                            'values from supervisor '||sup_rec.sup_person_id||' subordinate '||
                            l_sub_id
                        );
                        --
                        UPDATE  hr_ptl_summary_data
                        SET     sum_information4 = TO_NUMBER(sum_information4) - TO_NUMBER(del_rec.voluntary_char),
                                sum_information5 = TO_NUMBER(sum_information5) - TO_NUMBER(del_rec.involuntary_char)
                        WHERE   sum_information2 = TO_CHAR(sup_rec.sup_person_id)
                        AND     sum_information3 = TO_CHAR(l_sub_id)
                        AND     sum_information1 = fnd_date.date_to_canonical(del_rec.effective_date)
                        AND     sum_information_category = information_category;
                        --
                        -- Next subordinate is this supervisor 'cos we're going to step up the heirarchy
                        l_sub_id := sup_rec.sup_person_id;
                    END LOOP;
                    --
                    IF l_sub_id = del_rec.supervisor_id THEN
                        dbg(
                            'No rows returned by get_supsup for '||
                            del_rec.supervisor_id||' and '||
                            fnd_date.date_to_canonical(del_rec.effective_date)
                        );
                    END IF;
                    --
                END LOOP;
                --
                IF l_loop = 0 THEN
                    dbg('No rows returned by get_deletes_todo for '||
                        p_supv_tab(i).supervisor_id||' '||
                        fnd_date.date_to_canonical(p_supv_tab(i).effective_start_date)||' '||
                        fnd_date.date_to_canonical(p_supv_tab(i).effective_end_date)||
                        ' (data not previously record in summary, not an error)'
                    );
                END IF;
                --
                -- Delete the supervisors we're going to refresh, we've just taken the
                -- values we're going to delete off of their superordinates
                DELETE
                    FROM    hr_ptl_summary_data
                    WHERE   effective_date BETWEEN
                                p_supv_tab(i).effective_start_date AND
                                p_supv_tab(i).effective_end_date
                    AND     summary_context_id = p_supv_tab(i).supervisor_id
                    AND     sum_information_category = information_category;
                --
                msg(
                    'Supervisor '||
                    p_supv_tab(i).supervisor_id||' '||
                    p_supv_tab(i).effective_start_date||' -> '||
                    p_supv_tab(i).effective_end_date||
                    ' deleted '||SQL%ROWCOUNT||' rows'
                );
            END LOOP;
        END IF;
        --
    END build_delta_refresh_table;
    --
    -- ***********************************************************************
    -- * Do the actual insert into the summary table, used by the direct     *
    -- * insert procedure and the cache flusher                              *
    -- * TODO: Convert to bulk binds to improve performance?                 *
    -- ***********************************************************************
    PROCEDURE do_insert(
        p_eff_dt        IN DATE,
        p_supv_id       IN NUMBER,
        p_sub_supv_id   IN NUMBER,
        p_vol_sep       IN NUMBER,
        p_invol_sep     IN NUMBER
    ) IS
    BEGIN
        dbg(
            'Inserting new row for '||p_supv_id||'/'||p_sub_supv_id||'/'||p_eff_dt||
            ' data '||p_vol_sep||'/'||p_invol_sep
        );
        INSERT INTO hr_ptl_summary_data (
            summary_data_id,
            summary_context_type,
            summary_context_id,
            effective_date,
            created_by,
            creation_date,
            object_version_number,
            last_updated_by,
            last_update_date,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            sum_information_category,
            sum_information1,
            sum_information2,
            sum_information3,
            sum_information4,
            sum_information5
        ) VALUES (
            hr_ptl_summary_data_s.NEXTVAL,
            context_type,
            p_supv_id,
            p_eff_dt,
            g_who_id,
            g_who_date,
            g_who_version,
            g_who_id,
            g_who_date,
            g_who_login,
            g_who_request,
            g_who_application,
            g_who_program,
            g_who_date,
            information_category,
            fnd_date.date_to_canonical(p_eff_dt),
            TO_CHAR(p_supv_id),
            TO_CHAR(p_sub_supv_id),
            TO_CHAR(p_vol_sep),
            TO_CHAR(p_invol_sep)
        );
    END do_insert;
    --
    -- ***********************************************************************
    -- * Insert data into a cache table, from where we'll insert into the    *
    -- * portal summary table later. This saves us having to select back out *
    -- * from the summary table                                              *
    -- ***********************************************************************
    PROCEDURE insert_cache_data(
        p_supv_id       IN NUMBER,
        p_sub_supv_id   IN NUMBER,
        p_eff_dt        IN DATE,
        p_vol_sep       IN NUMBER,
        p_invol_sep     IN NUMBER
    ) IS
        --
        -- Convert the date to a number to enable use to use it
        -- as a hash key into a PL/SQL table
        l_dt_num     NUMBER := TO_NUMBER(TO_CHAR(p_eff_dt,'YYYYMMDD'));
        --
        l_vol_sep    NUMBER;
        l_invol_sep  NUMBER;
    BEGIN
        --
        -- Make sure we've got a cache record for the effective date
        IF NOT g_insert_cache.EXISTS(l_dt_num) THEN
            g_insert_cache(l_dt_num).effective_date := p_eff_dt;
        END IF;
        --
        -- Make sure we've got a cache record for the supervisor on the effective date
        IF NOT g_insert_cache(l_dt_num).supervisor_rows.EXISTS(p_supv_id) THEN
            g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).supervisor_id := p_supv_id;
        END IF;
        --
        -- Make sure we've got a subordinate record cached for the required supervisor and date
        IF NOT g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).subordinate_rows.EXISTS(p_sub_supv_id) THEN
            g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).subordinate_rows(p_sub_supv_id).subordinate_id   := p_sub_supv_id;
            g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).subordinate_rows(p_sub_supv_id).voluntary_seps   := 0;
            g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).subordinate_rows(p_sub_supv_id).involuntary_seps := 0;
        END IF;
        --
        -- Get the current values against the cached record (neater syntax than doing the updates in one line)
        l_vol_sep   := g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).subordinate_rows(p_sub_supv_id).voluntary_seps;
        l_invol_sep := g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).subordinate_rows(p_sub_supv_id).involuntary_seps;
        --
        -- Add the passed values to the cached record
        g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).subordinate_rows(p_sub_supv_id).voluntary_seps   := l_vol_sep + p_vol_sep;
        g_insert_cache(l_dt_num).supervisor_rows(p_supv_id).subordinate_rows(p_sub_supv_id).involuntary_seps := l_invol_sep + p_invol_sep;
        --
    END insert_cache_data;
    --
    -- ***********************************************************************
    -- * Flush the insert cache table to the database, then clear the cache  *
    -- * in case the procedure gets run again in the same session            *
    -- ***********************************************************************
    PROCEDURE flush_insert_cache IS
        --
        l_effdt     NUMBER;
        l_supv      NUMBER;
        l_subor     NUMBER;
    BEGIN
        --
        -- Only do this if we're not directly inserting into the summary table
        IF NOT g_direct_insert THEN
            --
            -- Loop over all the effective dates for which we cached data
            l_effdt := g_insert_cache.FIRST;
            WHILE l_effdt IS NOT NULL LOOP
                --
                -- Loop over all the supervisors we cached for this date
                l_supv := g_insert_cache(l_effdt).supervisor_rows.FIRST;
                WHILE l_supv IS NOT NULL LOOP
                    --
                    -- Loop over all the subordinates cached for this supervisor on this date
                    l_subor := g_insert_cache(l_effdt).supervisor_rows(l_supv).subordinate_rows.FIRST;
                    WHILE l_subor IS NOT NULL LOOP
                        --
                        -- Do the actual insert
                        do_insert(
                            g_insert_cache(l_effdt).effective_date,
                            g_insert_cache(l_effdt).supervisor_rows(l_supv).supervisor_id,
                            g_insert_cache(l_effdt).supervisor_rows(l_supv).subordinate_rows(l_subor).subordinate_id,
                            g_insert_cache(l_effdt).supervisor_rows(l_supv).subordinate_rows(l_subor).voluntary_seps,
                            g_insert_cache(l_effdt).supervisor_rows(l_supv).subordinate_rows(l_subor).involuntary_seps
                        );
                        --
                        -- Next subordinate
                        l_subor := g_insert_cache(l_effdt).supervisor_rows(l_supv).subordinate_rows.NEXT(l_subor);
                    END LOOP;
                    --
                    -- Next supervisor
                    l_supv := g_insert_cache(l_effdt).supervisor_rows.NEXT(l_supv);
                END LOOP;
                --
                -- Next effective date
                l_effdt := g_insert_cache.NEXT(l_effdt);
            END LOOP;
            --
            -- Bin the whole of the cache, in case the summary gets run twice in one session
            g_insert_cache.DELETE;
        END IF;
    END flush_insert_cache;
    --
    -- ***********************************************************************
    -- * Insert our specific summary data into the global summary table, and *
    -- * fill in all the other necessary stuff too                           *
    -- ***********************************************************************
    PROCEDURE insert_summary_data(
        p_supv_id       IN NUMBER,
        p_sub_supv_id   IN NUMBER,
        p_eff_dt        IN DATE,
        p_vol_sep       IN NUMBER,
        p_invol_sep     IN NUMBER
    ) IS
        --
        -- Cursor to see if we've already inserted a row
        -- for this date/supervisor/subordinate
        CURSOR chk_exists(
            cp_eff_dt   IN VARCHAR2,
            cp_sup_id   IN VARCHAR2,
            cp_sub_id   IN VARCHAR2
        ) IS
            -- Get rowid for fast updates and the current separation figures
            SELECT      rowid,
                        sum_information4,
                        sum_information5
            FROM        hr_ptl_summary_data
            -- Make sure we're looking at the right rows
            WHERE       sum_information_category = information_category
            -- Use the text versions of the foreign keys to hit the index
            AND         sum_information1 = cp_eff_dt
            AND         sum_information2 = cp_sup_id
            AND         sum_information3 = cp_sub_id;
        --
        l_rid           ROWID;
        l_vol           hr_ptl_summary_data.sum_information4%TYPE;
        l_invol         hr_ptl_summary_data.sum_information5%TYPE;
        --
    BEGIN
        --
        -- See if there's already a row for this supervisor/subordinate on this date
        OPEN chk_exists(fnd_date.date_to_canonical(p_eff_dt),TO_CHAR(p_supv_id),TO_CHAR(p_sub_supv_id));
        FETCH chk_exists INTO l_rid,l_vol,l_invol;
        IF chk_exists%FOUND THEN
            CLOSE chk_exists;
            --
            -- Update the existing row that we've just found
            dbg(
                'Found row for '||p_supv_id||'/'||p_sub_supv_id||'/'||p_eff_dt||
                ' with data '||l_vol||'/'||l_invol||
                ' updating with '||p_vol_sep||'/'||p_invol_sep
            );
            --
            -- TODO: Would it be quicker to just try updating the row and then do the insert
            -- if nothing got updated (i.e. the row didn't exist)?
            UPDATE hr_ptl_summary_data
            SET    sum_information4 = TO_CHAR(TO_NUMBER(l_vol) + p_vol_sep),
                   sum_information5 = TO_CHAR(TO_NUMBER(l_invol) + p_invol_sep)
            WHERE  rowid = l_rid;
            --
        ELSE
            CLOSE chk_exists;
            --
            -- Insert the data as an entirely new row
            do_insert(p_eff_dt,p_supv_id,p_sub_supv_id,p_vol_sep,p_invol_sep);
        END IF;
        --
    END insert_summary_data;
    --
    -- ***********************************************************************
    -- * Either insert into the cache table for later flushing, or directly  *
    -- * insert into the summary table. Cached version is quicker, but the   *
    -- * direct insert version will use less memory since the cached version *
    -- * can result in quite a hefty PL/SQL table being created              *
    -- ***********************************************************************
    PROCEDURE proxy_insert_data(
        p_supv_id       IN NUMBER,
        p_sub_supv_id   IN NUMBER,
        p_eff_dt        IN DATE,
        p_vol_sep       IN NUMBER,
        p_invol_sep     IN NUMBER
    ) IS
    BEGIN
        --
        -- Insert directly into the table, a performance hit, since it first
        -- has to select back from the table to see if the row's already there
        IF g_direct_insert THEN
            insert_summary_data(
                p_supv_id,
                p_sub_supv_id,
                p_eff_dt,
                p_vol_sep,
                p_invol_sep
            );
        --
        -- Insert the data into the cache, must remember to flush it to the
        -- database before the program exits
        ELSE
            insert_cache_data(
                p_supv_id,
                p_sub_supv_id,
                p_eff_dt,
                p_vol_sep,
                p_invol_sep
            );
        END IF;
    END proxy_insert_data;
    --
    -- ***********************************************************************
    -- * Calculate and insert the summarized data for each refresh record    *
    -- * into the summary table                                              *
    -- * Return a count of the records inserted                              *
    -- ***********************************************************************
    FUNCTION process_refresh_table(
        p_supv_tab      IN OUT NOCOPY pay_events_wrapper.t_summary_refresh_tab_type
    ) RETURN NUMBER IS
        --
        -- Main cursor to calculate the separations that have happened for a
        -- supervisor between the given effective dates
        CURSOR csr_get_supv(
            cp_supv_id      IN NUMBER,
            cp_st_dt        IN DATE,
            cp_en_dt        IN DATE
        ) IS
            SELECT
                pos.actual_termination_date + 1        effective_date,
                SUM(DECODE(scr.separation_category_code,
                             involuntary_code, 0,    -- Involuntary is zero
                           DECODE(g_global_wmt,
                                    'FTE', wmv.fte,
                                    'HEAD', wmv.head,
                                  0)))              voluntary_separations,
                SUM(DECODE(scr.separation_category_code,
                             involuntary_code, DECODE(g_global_wmt,
                                                        'FTE', wmv.fte,
                                                        'HEAD', wmv.head,
                                                      0),
                           0))                      involuntary_separations
            FROM
                per_all_assignments_f         asg
              , per_periods_of_service        pos
              , per_assignment_status_types   ast
              , hri_cs_sepcr_v                scr
              , hri_mb_wmv                    wmv
            WHERE asg.assignment_id = wmv.assignment_id
            AND asg.supervisor_id = cp_supv_id
            AND asg.period_of_service_id = pos.period_of_service_id
            AND ast.assignment_status_type_id = asg.assignment_status_type_id
            AND NVL(pos.leaving_reason,'NA_EDW') = scr.separation_reason_code
            AND pos.actual_termination_date <= TRUNC(SYSDATE)
            AND asg.effective_end_date = pos.actual_termination_date
            AND pos.actual_termination_date BETWEEN cp_st_dt
                                                AND cp_en_dt
            AND pos.actual_termination_date BETWEEN wmv.effective_start_date
                                                AND wmv.effective_end_date
            GROUP BY
                pos.actual_termination_date + 1;
        --
        l_dir_tot     NUMBER;
        l_rup_tot     NUMBER;
        l_prev_supv   NUMBER;
        l_loop_cnt    NUMBER;
        --
    BEGIN
        --
        msg('Processing refresh table');
        --
        -- Check that there's data in the table
        IF NVL(p_supv_tab.FIRST,0) < 1 THEN
            msg('No data supplied in the refresh table');
            RETURN 0;
        END IF;
        --
        -- For each supervisor in the list, sum up their separations
        l_dir_tot := 0;
        l_rup_tot := 0;
        dbg('Records range from '||p_supv_tab.FIRST||' to '||p_supv_tab.LAST);
        FOR i IN p_supv_tab.FIRST .. p_supv_tab.LAST LOOP
            l_loop_cnt := 0;
            FOR l_supv_rec IN csr_get_supv(
                p_supv_tab(i).supervisor_id,
                p_supv_tab(i).effective_start_date,
                p_supv_tab(i).effective_end_date
            ) LOOP
                l_loop_cnt := l_loop_cnt + 1;
                --
                -- Track back up the hierarchy, rolling the data up to the
                -- superordinate managers as we go
                dbg('Checking and adding super-ordinate managers for supervisor '||p_supv_tab(i).supervisor_id||' row '||i);
                l_prev_supv := -1;
                FOR rec IN get_supsup(
                    p_supv_tab(i).supervisor_id,
                    l_supv_rec.effective_date
                ) LOOP
                    rec.row_number := get_supsup%ROWCOUNT;
                    --
                    -- Make sure we're traversing up the supervisor heirarchy properly, the
                    -- subordionate relative level should match the row number, i.e. we
                    -- should start with the superordinate who's one level up, then the
                    -- manager that's a level up from that, and so on. This error should
                    -- only ever occur if the supervisor heirarchy is corrupt, you should
                    -- always have a chain of superordinate managers on sequential levels
                    IF rec.row_number <> rec.sub_relative_level THEN
                        dbg('ERROR: Supervisor heirarchy seems to be corrupt, sequential chain of superordinate managers is broken.');
                        dbg('Subordinate manager:   '||p_supv_tab(i).supervisor_id);
                        dbg('Effective date:        '||l_supv_rec.effective_date);
                        dbg('Superordinate manager: '||rec.sup_person_id);
                        dbg('Row number:            '||rec.row_number);
                        dbg('Relative level       : '||rec.sub_relative_level);
                    ELSE
                        --
                        -- Add a direct reports row for this superordinate on the current date
                        dbg('Add direct reports row: '||rec.sup_person_id);
                        proxy_insert_data(
                            rec.sup_person_id,
                            direct_report_id,
                            l_supv_rec.effective_date,
                            0,
                            0
                        );
                        --
                        -- The first superordinate has this manager as it's subordinate
                        IF l_prev_supv = -1 THEN
                            l_prev_supv := p_supv_tab(i).supervisor_id;
                        END IF;
                        --
                        -- Add a row for the current superordinate manager and the
                        -- subordinate of whom to which the current manager reports
                        dbg('Add superordinate row: '||rec.sup_person_id||'/'||l_prev_supv);
                        proxy_insert_data(
                            rec.sup_person_id,
                            l_prev_supv,
                            l_supv_rec.effective_date,
                            l_supv_rec.voluntary_separations,
                            l_supv_rec.involuntary_separations
                        );
                        l_rup_tot := l_rup_tot + 1;
                        --
                        -- Subsequent superordinates have the previous manager as their subordinates
                        l_prev_supv := rec.sup_person_id;
                    END IF;
                END LOOP;
                --
                IF l_prev_supv = -1 THEN
                    dbg(
                        'No rows returned by get_supsup cursor for '||
                        p_supv_tab(i).supervisor_id||
                        ' and '||
                        fnd_date.date_to_canonical(l_supv_rec.effective_date)
                    );
                END IF;
                --
                -- Write some debugging info and insert the data
                dbg('Adding direct reports summary row for '||p_supv_tab(i).supervisor_id);
                proxy_insert_data(
                    p_supv_tab(i).supervisor_id,
                    direct_report_id,
                    l_supv_rec.effective_date,
                    l_supv_rec.voluntary_separations,
                    l_supv_rec.involuntary_separations
                );
                l_dir_tot := l_dir_tot + 1;
            END LOOP;
            --
            IF l_loop_cnt = 0 THEN
                dbg('No rows returned by csr_get_supv cursor for '||
                    p_supv_tab(i).supervisor_id||', '||
                    fnd_date.date_to_canonical(p_supv_tab(i).effective_start_date)||', '||
                    fnd_date.date_to_canonical(p_supv_tab(i).effective_end_date)
                );
            END IF;
        END LOOP;
        --
        msg('Inserted '||l_dir_tot||' direct report rows');
        msg('Inserted '||l_rup_tot||' rollup rows');
        --
        -- Flush the cache (this procedure won't do anything if we're doing direct inserts)
        flush_insert_cache;
        --
        RETURN l_dir_tot + l_rup_tot;
    END process_refresh_table;
    --
    -- ***********************************************************************
    -- * Fully refresh all summary data for the Annualized Turnover portlets *
    -- * within the specified time period                                    *
    -- ***********************************************************************
    PROCEDURE full_refresh(
        errbuf          OUT NOCOPY VARCHAR2,
        retcode         OUT NOCOPY NUMBER,
        p_start_date    IN  VARCHAR2,
        p_end_date      IN  VARCHAR2 DEFAULT eot_char
    ) IS
        --
        l_start_date    DATE := fnd_date.canonical_to_date(p_start_date);
        l_end_date      DATE := fnd_date.canonical_to_date(NVL(p_end_date,eot_char));
        l_tot_rec       NUMBER := 0;
        l_supv_tab      pay_events_wrapper.t_summary_refresh_tab_type;
        --
    BEGIN
        -- Do the BIS refresh framework setup
        IF bis_collection_utilities.setup(p_object_name => object_name) = FALSE THEN
            dbg('Failed to setup bis collection utilities');
            errbuf := g_setup_failure;
            raise_application_error(g_appl_err,g_setup_failure);
        END IF;
        msg(g_start_full_msg);
        dbg('Starting full refresh: '||l_start_date||'->'||l_end_date);
        --
        -- Get the list of all supervisors for which separations have occurred
        -- within the *effective* dates specified by the input parameters
        -- Any deletions from the summary table take place here
        build_full_refresh_table(l_supv_tab,l_start_date,l_end_date);
        dbg('Built refresh table: '||NVL(l_supv_tab.LAST,0)||' rows');
        --
        -- Process all the records in the refresh table, creates direct reports rows
        -- and rolls back up the heirarchy as it goes
        l_tot_rec := process_refresh_table(l_supv_tab);
        dbg('Processed refresh table: '||l_tot_rec||' records');
        --
        -- Do the proper refresh framework wrapup
        msg(g_success_message);
        bis_collection_utilities.wrapup(
            p_status        => TRUE,
            p_count         => l_tot_rec,
            p_message       => g_success_message,
            p_period_from   => l_start_date,
            p_period_to     => l_end_date
        );
        dbg('Run done OK');
    --
    -- Handle an exception by logging it with the collection framework
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        dbg('Run failed, logging errors');
        msg(g_failure_message||SQLERRM);
        errbuf := g_failure_message||SQLERRM;
        bis_collection_utilities.wrapup(
            p_status        => FALSE,
            p_count         => l_tot_rec,
            p_message       => g_failure_message||SQLERRM,
            p_period_from   => l_start_date,
            p_period_to     => l_end_date
        );
        raise_application_error(g_appl_err,g_failure_message||SQLERRM);
        --
    END full_refresh;
    --
    -- ***********************************************************************
    -- * Refresh the summary data for the Annualized Turnover portlets based *
    -- * on the events that have occurred since we last ran this refresh     *
    -- ***********************************************************************
    PROCEDURE refresh_from_deltas(
        errbuf          OUT NOCOPY VARCHAR2,
        retcode         OUT NOCOPY NUMBER
    ) IS
        --
        l_start_date        DATE;
        l_end_date          DATE;
        l_bis_start_date    DATE;
        l_bis_end_date      DATE;
        l_period_from       DATE;
        l_period_to         DATE;
        l_tot_rec           NUMBER := 0;
        l_supv_tab          pay_events_wrapper.t_summary_refresh_tab_type;
        --
    BEGIN
        -- Do the BIS refresh framework setup
        IF bis_collection_utilities.setup(p_object_name => object_name) = FALSE THEN
            dbg('Failed to set up bis collection utilities');
            errbuf := g_setup_failure;
            raise_application_error(g_appl_err,g_setup_failure);
        END IF;
        msg(g_start_delta_msg);
        --
        -- Get the dates of the last refresh of this program
        bis_collection_utilities.get_last_refresh_dates(
            object_name,
            l_bis_start_date,
            l_bis_end_date,
            l_period_from,
            l_period_to
        );
        --
        -- The start of this refresh should be the time at which the last one started running so
        -- that any changes made during the last run are picked up by this one
        -- The end should be now
        l_start_date := l_bis_start_date;
        l_end_date   := SYSDATE;
        --
        dbg(
            'Refreshing from deltas: '||
            fnd_date.date_to_canonical(l_start_date)||
            '->'||
            fnd_date.date_to_canonical(l_end_date)
        );
        IF l_start_date > l_end_date THEN
            dbg('ERROR: BIS collection utilities reports last refresh period later than current date, trying to continue anyway');
        END IF;
        --
        -- Get the list of all supervisors for which separations have potentially
        -- occurred within the *real* dates specified by the input parameters
        -- Should use the payroll event model wrapper
        -- Any deletions from the summary table take place here
        build_delta_refresh_table(l_supv_tab,l_start_date,l_end_date);
        dbg('Built delta refresh table: '||NVL(l_supv_tab.LAST,0)||' rows');
        --
        -- Process all the records in the refresh table, creates direct reports rows
        -- and rolls back up the heirarchy as it goes
        l_tot_rec := process_refresh_table(l_supv_tab);
        dbg('Processed refresh table: '||l_tot_rec||' records');
        --
        -- Do the proper refresh framework wrapup
        msg(g_success_message);
        bis_collection_utilities.wrapup(
            p_status        => TRUE,
            p_count         => l_tot_rec,
            p_message       => g_success_message,
            p_period_from   => l_start_date,
            p_period_to     => l_end_date
        );
        dbg('Run completed OK');
    --
    -- Handle an exception by logging it with the collection framework
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        dbg('Run failed, logging errors');
        msg(g_failure_message||SQLERRM);
        errbuf := g_failure_message||SQLERRM;
        bis_collection_utilities.wrapup(
            p_status        => FALSE,
            p_count         => l_tot_rec,
            p_message       => g_failure_message||SQLERRM,
            p_period_from   => l_start_date,
            p_period_to     => l_end_date
        );
        raise_application_error(g_appl_err,g_failure_message||SQLERRM);
        --
    END refresh_from_deltas;
    --
    -- ***********************************************************************
    -- * Special debug modes just set the globals (and the wrapper log mode) *
    -- * and then call the normal routines                                   *
    -- ***********************************************************************
    PROCEDURE full_refresh_debug(
        errbuf          OUT NOCOPY VARCHAR2,
        retcode         OUT NOCOPY NUMBER,
        p_start_date    IN  VARCHAR2,
        p_end_date      IN  VARCHAR2 DEFAULT eot_char
    ) IS
    BEGIN
        set_debugging(TRUE);
        full_refresh(
            errbuf       => errbuf,
            retcode      => retcode,
            p_start_date => p_start_date,
            p_end_date   => p_end_date
        );
    END full_refresh_debug;
    --
    PROCEDURE refresh_from_deltas_debug(
        errbuf          OUT NOCOPY VARCHAR2,
        retcode         OUT NOCOPY NUMBER
    ) IS
    BEGIN
        set_debugging(TRUE);
        pay_events_wrapper.set_concurrent_logging(TRUE);
        pay_events_wrapper.set_debugging(TRUE);
        refresh_from_deltas(errbuf,retcode);
    END refresh_from_deltas_debug;
    --
BEGIN
    -- Start up this package
    initialise_globals;
    --
END hri_dbi_wmv_separation;

/
