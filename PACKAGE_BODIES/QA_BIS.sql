--------------------------------------------------------
--  DDL for Package Body QA_BIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_BIS" AS
/* $Header: qltbisb.plb 115.19 2002/11/27 19:22:13 jezheng ship $ */


    --
    -- Create a mirror image of QA_RESULTS into QA_BIS_RESULTS for
    -- BIS reporting purpose.  QA_BIS_RESULTS is also called a
    -- Summary Table.  Not all columns of QA_RESULTS are selected.
    -- Only those that BIS reports on will be included.
    --
    -- There are two methodologies for this mirroring process.
    -- One is a complete rebuild where the summary table is first
    -- deleted and truncated.  Then the results are transferred.
    -- Another is by incremental refresh, where only the recently
    -- inserted or updated records are transferred.
    --
    -- A last refresh time is kept in the table QA_BIS_UPDATE_HISTORY.
    -- It is updated in both complete rebuild and incremental refresh.
    --
    -- **OBSOLETE**
    -- The incremental refresh method does not take care of deletion.
    -- This means deleted records in QA_RESULTS will appear in the
    -- summary table, and consequently, in the BIS Report.  The current
    -- strategy is to modify QLTRSMDF/QLTRSINF so that when a row is
    -- deleted from direct data entry, the corresponding row from
    -- QA_BIS_RESULTS will be deleted as well.
    --
    -- Change of status in QA_RESULTS, however, will be taken care of.
    -- There is a status column in QA_RESULTS which can be set to 1
    -- to indicate an invalid rows.  Those rows with status=1 will
    -- not be included in the summary table.  When the status is
    -- updated to other values, as long as the qa_last_update_date is
    -- also correctly updated, this row will be included in the next
    -- refresh (complete or incremental).  Changing the status of a
    -- valid row to invalid (status=1) will also delete the row from
    -- the summary table in the next refresh (complete or incremental).
    --
    -- Incremental refresh now takes care of deletion by using
    -- QA_BIS_UPDATE_HISTORY as delete log.  When a record is deleted
    -- from QA_RESUTLS, qa_bis.delete_log is called to record an audit
    -- trail.
    --
    -- Author:  Bryan So (bso)
    -- Contribution: Revathy Narasimhan (rnarasim)
    --
    -- Mon Jun 21 17:49:22 PDT 1999
    --

    Incremental constant number := 1;
    Complete constant number := 2;

    --
    -- Maximum no. of rows inserted before a commit.  We have had
    -- reports of performance problem when inserting a large no. of
    -- records with a single commit at the end.  The problem happens
    -- because of the immensely large rollback segment that needs to
    -- be maintained.  Intermittent commit will solve the problem.
    -- This variable will be initiated by the wrapper from a SRS param.
    --
    g_intermittent_commit number;

    --
    -- Date of last refresh.  Could be null if never performed.
    -- Initialized by wrapper.
    --
    g_last_refresh date;

    --
    -- Current system date.  Initialized by the wrapper.
    -- When performing incremental refresh of the BIS Summary Table,
    -- all records updated *before* (but not at) this and *after or at*
    -- last refresh datetime will be inserted.
    --
    g_current_datetime date;

    --
    -- Standard who columns.
    --
    who_user_id                 constant number := fnd_global.conc_login_id;
    who_request_id              constant number := fnd_global.conc_request_id;
    who_last_update_login       constant number := fnd_global.conc_login_id;
    who_program_id              constant number := fnd_global.conc_program_id;
    who_program_application_id  constant number := fnd_global.prog_appl_id;

    --
    -- schema information for DDL
    --
    qa_status   varchar2(1);
    qa_industry varchar2(10);
    qa_schema   varchar2(30);


        --
        -- Private Functions
        --

        PROCEDURE truncate_summary_table IS
        --
        -- Delete the entire BIS Summary Table.  Done for complete rebuild.
        --
        BEGIN
            --
            -- Truncate is used for quicker performance and reuse of
            -- space.  The reuse storage clause actually means do not
            -- purge the storage but reserve it for the QBR table.
            -- Since this command is followed by immediate inserts, this
            -- would be a good option.
            --
            qlttrafb.exec_sql('truncate table ' ||
                qa_schema || '.QA_BIS_RESULTS reuse storage');

            --
            -- Performance notes.  appsperf actually recommends an alternative
            -- of dropping the table here.  Then the new table can be created:
            -- create table as <select_stmt>.  This approach will not make
            -- use of a rollback segment; therefore no need for intermittent
            -- commits.
            --
            -- Problem is, there are many areas to pay attention to.  We have
            -- to drop and create the table using ad_ddl.do_array_ddl calls.
            -- We have to worry about recreating indices on qa_bis_results...
            -- Not implemented yet.
            -- bso
            --
        END truncate_summary_table;


        PROCEDURE delete_update_history IS
        --
        -- Delete the audit trail in the update history table.  The audit
        -- trail stores the primary key of the purged records (i.e. those
        -- deleted from qa_results).  This procedure should be called only
        -- by complete rebuild or by procedure delete_purged_rows.
        --
        BEGIN
            DELETE
            FROM   qa_bis_update_history
            WHERE  occurrence >= 0 AND
                   last_update_date < g_current_datetime;
            commit;
        END delete_update_history;


        PROCEDURE delete_purged_rows IS
        --
        -- Delete those records that have been deleted from qa_results.
        --
        BEGIN
            DELETE
            FROM   qa_bis_results qbr
            WHERE  qbr.occurrence IN
               (SELECT h.occurrence
                FROM   qa_bis_update_history h
                WHERE  h.occurrence >= 0 AND
                       h.last_update_date < g_current_datetime);
            commit;
            delete_update_history;
        END delete_purged_rows;


        PROCEDURE delete_updated_rows IS
        --
        -- Delete those rows in BIS Summary Table whose counterpart in
        -- QA_RESULTS have been modified since last_refresh.
        --
        -- Notes on efficiency:
        --   . QA_RESULTS must have either an index on qa_creation_date
        --     or an index on qa_last_update_date (preferrable)
        --
        --   . QA_BIS_RESULTS must have a unique index on occurrence.
        --
        -- Notes on coding standard:
        --   . Never use WHO columns to quality rows for processing.
        --     Coding Standards R10SC p. 3-4.
        --     Therefore, qa_last_update_date is used instead.
        --
        BEGIN
            DELETE
            FROM   qa_bis_results qbr
            WHERE  occurrence IN (
                SELECT occurrence
                FROM   qa_results qr
                WHERE  qr.qa_last_update_date < g_current_datetime AND
                       g_last_refresh BETWEEN
                           qr.qa_creation_date AND qr.qa_last_update_date);
            commit;

        END delete_updated_rows;


        PROCEDURE construct_decode(alias varchar2, x_char_id number,
            s in out NOCOPY varchar2) IS
        --
        -- Dynamically construct a decode function that decodes the
        -- value for a softcoded collection element.  The decode
        -- statement started at the end of s.
        --
        -- Performance notes: Will be more efficient if qa_plan_chars
        -- has an index on char_id.
        --
            x_plan_id number;
            x_result_column_name varchar2(30);
            CURSOR c IS
                SELECT plan_id, result_column_name
                FROM   qa_plan_chars
                WHERE  char_id = x_char_id;

        --
        -- Bug 1357601.  The decode statement used to "straighten" softcoded
        -- elements into a single column has a sever limit of 255 parameters.
        -- These variables are added to resolve the limit.  When the limit is
        -- up, we use the very last parameter of the decode statement to
        -- start a new decode, which can have another 255 params.  This is
        -- repeated as necessary.
        --
        -- decode_count keeps the no. of decodes being used so far.
        -- decode_param keeps the no. of parameters in the current decode.
        -- decode_limit is the server limit.  This should be updated if
        --    the server is enhanced in the future.
        --
        -- bso Thu Sep 21 13:11:19 PDT 2000
        --
        decode_count NUMBER;
        decode_param NUMBER;
        decode_limit CONSTANT NUMBER := 255;

        BEGIN
            OPEN c;
            FETCH c INTO x_plan_id, x_result_column_name;

            IF c%found THEN

                s := s || 'decode(' || alias || '.plan_id';

                decode_count := 1;
                decode_param := 1;

                --
                -- Find <plan_id, result_column_name> pairs for all plans
                -- with x_char_id as collection element.
                --
                WHILE c%found LOOP

                    IF decode_param >= (decode_limit - 2) THEN
                      s := s || ', decode(qr.plan_id';
                      decode_count := decode_count + 1;
                      decode_param := 1;
                    END IF;

                    s := s || ', ' || to_char(x_plan_id) || ', ' ||
                        alias || '.' || x_result_column_name;
                    decode_param := decode_param + 2;

                    FETCH c INTO x_plan_id, x_result_column_name;
                END LOOP;
                CLOSE c;

                FOR n IN 1 .. decode_count LOOP
                    s := s || ')';
                END LOOP;
            ELSE
                CLOSE c;
                s := s || 'null';  -- no such char_id, simply select null
            END IF;
        END construct_decode;


        PROCEDURE construct_summary_table(s in out NOCOPY varchar2) IS
        --
        -- Construct a SQL statement that selects from QA_RESULTS and
        -- format it so that the results can be directly inserted into
        -- the BIS Summary Table after putting in WHO information.
        --
        -- The final sql statement looks like this:
        --
        -- SELECT
        --     :w1 to :w9  standard who columns
        --     qr.organization_id,
        --     'decoded by view' organization_name,
        --     qr.plan_id,
        --     qr.collection_id,
        --     qr.occurrence,
        --     'decoded by view' plan_type_code,
        --     'decoded by view' meaning,
        --     'decoded by view' plan_name,
        --     qr.item_id,
        --     'decoded by view' item,
        --     -1 lot_control_code,
        --     qr.lot_number,
        --     decode(qr.plan_id, 120, qr.CHARACTER3 ...) defect_code,
        --     decode(qr.plan_id, 120, qr.CHARACTER2 ...) quantity_defective,
        --     qr.qa_creation_date,
        --     qr.qa_last_update_date
        -- FROM
        --     qa_results qr
        -- WHERE
        --     (qr.status is null or qr.status = 2)
        --     and qr.qa_last_update_date < :today
        --
        -- bso
        --
            defect_code_char_id constant number := 100;
            quantity_defective_char_id constant number := 101;
        BEGIN
            --
            -- Construct the select clause
            --
            s := 'SELECT '||
                who_request_id || ',' ||
                who_program_application_id || ',' ||
                who_program_id || ',' ||
                'sysdate,' ||
                who_user_id || ',' ||
                'sysdate,' ||
                who_last_update_login || ',' ||
                who_user_id || ',' ||
                'sysdate,' ||
                'qr.organization_id,' ||
                '''decoded by view'' organization_name,' ||
                'qr.plan_id,' ||
                'qr.collection_id,' ||
                'qr.occurrence,' ||
                '''decoded by view'' plan_type_code,' ||
                '''decoded by view'' meaning,' ||
                '''decoded by view'' plan_name,' ||
                'qr.item_id,' ||
                '''decoded by view'' item,' ||
                '-1 lot_control_code,' ||
                'qr.lot_number,';

            --
            -- The followings construct the dynamic select clauses
            -- required for softcoded collection elements.
            --
            construct_decode('qr', defect_code_char_id, s);
            s := s || ' defect_code,';

            construct_decode('qr', quantity_defective_char_id, s);
            s := s || ' quantity_defective,' ||
                'qr.qa_creation_date,' ||
                'qr.qa_last_update_date ' ||
                'FROM qa_results qr ' ||
                'WHERE (qr.status is null or qr.status = 2) ' ||
                'and qr.qa_last_update_date < :today';

        END construct_summary_table;


        PROCEDURE write_last_refresh_datetime(x_last_refresh_time date) IS
        --
        -- Write a refresh time to the QA_BIS_UPDATE_HISTORY table.
        --
        BEGIN
            UPDATE qa_bis_update_history SET
                request_id = who_request_id,
                program_application_id = who_program_application_id,
                program_id = who_program_id,
                program_update_date = sysdate,
                last_update_login = who_last_update_login,
                last_updated_by = who_user_id,
                last_update_date = sysdate,
                last_refresh_time = x_last_refresh_time
            WHERE occurrence = -1;  -- special record for refresh time.
            commit;
        END write_last_refresh_datetime;


        PROCEDURE init_last_refresh_datetime IS
        --
        -- Initialize the QA_BIS_UPDATE_HISTORY table.
        --
        BEGIN
            INSERT INTO qa_bis_update_history(
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                created_by,
                creation_date,
                last_update_login,
                last_updated_by,
                last_update_date,
                occurrence,
                last_refresh_time
            )
            VALUES (
                who_request_id,                 -- request_id
                who_program_application_id,     -- program_application_id
                who_program_id,                 -- program_id
                sysdate,                        -- program_update_date
                who_user_id,                    -- created_by
                sysdate,                        -- creation_date
                who_last_update_login,          -- last_update_login
                who_user_id,                    -- last_updated_by
                sysdate,                        -- last_update_date
                -1,                             -- special flag
                sysdate);                       -- last_refresh_time
            commit;
        END init_last_refresh_datetime;


        FUNCTION get_last_refresh_datetime RETURN date IS
        --
        -- Get last refresh time from the QA_BIS_UPDATE_HISTORY table
        --
            d date;
            CURSOR c IS
                SELECT last_refresh_time
                FROM   qa_bis_update_history
                WHERE  occurrence = -1;
                    -- special flag that indicates this is the record
                    -- to look for refresh time
        BEGIN
            OPEN c;
            FETCH c INTO d;
            IF c%notfound THEN
                CLOSE c;
                init_last_refresh_datetime;
                RETURN null;
            ELSE
                CLOSE c;
                RETURN d;
            END IF;
        END get_last_refresh_datetime;


        PROCEDURE insert_summary_table(select_statement varchar2,
            method number) IS
        --
        -- Insert into the summary table by selecting rows from the
        -- select_statement.
        --
        -- See comments for construct_summary_table to find out what
        -- columns are selected.
        --
        -- The summary table looks like this:
        --
        --      request_id              number
        --      program_application_id  number
        --      program_id              number
        --      program_update_date     date
        --      created_by              number
        --      creation_date           date
        --      last_update_login       number
        --      last_updated_by         number
        --      last_update_date        date
        --      qa_creation_date        date            not null
        --      qa_last_update_date     date            not null
        --      organization_id         number          not null
        --      organization_name       varchar2(60)    not null
        --      plan_id                 number          not null
        --      plan_name               varchar2(30)    not null
        --      collection_id           number          not null
        --      occurrence              number          not null    unique
        --      plan_type_code          varchar2(30)
        --      plan_type_meaning       varchar2(80)
        --      item_id                 number
        --      item                    varchar2(2000)
        --      lot_control_code        number
        --      lot_number              varchar2(30)
        --      defect_code             varchar2(150)
        --      quantity_defective      varchar2(150)
        --
        -- bso
        --
            insert_statement varchar2(32000);

        BEGIN

            --
            -- The following defines the cursor for inserting data into
            -- QA_BIS_RESULTS.
            --
            insert_statement := 'INSERT /*+ parallel (qb,default) append */ ' ||
                'INTO qa_bis_results qb(' ||
                'request_id,' ||
                'program_application_id,' ||
                'program_id,' ||
                'program_update_date,' ||
                'created_by,' ||
                'creation_date,' ||
                'last_update_login,' ||
                'last_updated_by,' ||
                'last_update_date,' ||
                'organization_id,' ||
                'organization_name,' ||
                'plan_id,' ||
                'collection_id,' ||
                'occurrence,' ||
                'plan_type_code,' ||
                'plan_type_meaning,' ||
                'plan_name,' ||
                'item_id,' ||
                'item,' ||
                'lot_control_code,' ||
                'lot_number,' ||
                'defect_code,' ||
                'quantity_defective,' ||
                'qa_creation_date,' ||
                'qa_last_update_date) ' || select_statement;

            IF method = Complete THEN
                EXECUTE IMMEDIATE insert_statement USING
                    g_current_datetime;
            ELSE
                EXECUTE IMMEDIATE insert_statement USING
                    g_current_datetime,
                    g_last_refresh;
            END IF;

            COMMIT;

        END insert_summary_table;



    --
    -- Main Entry Points
    --



    FUNCTION complete_rebuild RETURN number IS
    --
    -- Completely rebuild the BIS Summary Table.  This involves deleting
    -- the existing table, truncate it, and re-compute the records.
    -- Return a SQL error code.  0 indicates no error.
    -- bso
    --
        select_statement varchar2(30000);
    BEGIN
        truncate_summary_table;
        delete_update_history;
        construct_summary_table(select_statement);
        insert_summary_table(select_statement, Complete);
        write_last_refresh_datetime(g_current_datetime);

        RETURN 0;
    END complete_rebuild;


    FUNCTION incremental_rebuild RETURN number IS
    --
    -- Rebuild the BIS Summary Table by incremental refresh method.
    -- The records in QA_RESULTS that have been modified since the
    -- previous refresh datetime will be inserted into the BIS
    -- Table.  Two kinds of records in QA_RESULTS will be processed,
    -- those that are new and those that have been updated.
    --
    -- Notes on efficiency:
    --   . QA_RESULTS should have an index on qa_last_update_date.
    --
    -- Return a SQL error code.  0 indicates no error.
    -- bso
    --
        select_statement varchar2(30000);
    BEGIN
        IF g_last_refresh is null THEN
            --
            -- Exception.  The first time Rebuild is run, last_refresh
            -- will be null.  Just do complete rebuild.
            --
            RETURN complete_rebuild;
        ELSE
            delete_purged_rows;
            delete_updated_rows;
            construct_summary_table(select_statement);
            --
            -- Add where clause to select only the new data.
            --
            select_statement := select_statement ||
                ' and qr.qa_last_update_date >= :refresh';
            insert_summary_table(select_statement, Incremental);
            write_last_refresh_datetime(g_current_datetime);
            RETURN 0;
        END IF;
    END incremental_rebuild;




    --
    -- Public Functions
    --



    procedure rebuild is
    --
    -- Debug routine for testing purpose only.
    --
        dummy boolean;
        n number;
    begin
        dummy := fnd_installation.get_app_info('QA', qa_status,
            qa_industry, qa_schema);
        g_intermittent_commit := 1000;
        g_current_datetime := qltdate.get_sysdate;
        g_last_refresh := get_last_refresh_datetime;

        n := complete_rebuild;
    end;


    procedure refresh is
    --
    -- Debug routine for testing purpose only.
    --
        dummy boolean;
        n number;
    begin
        dummy := fnd_installation.get_app_info('QA', qa_status,
            qa_industry, qa_schema);
        g_intermittent_commit := 1000;
        g_current_datetime := qltdate.get_sysdate;
        g_last_refresh := get_last_refresh_datetime;

        n := incremental_rebuild;
    end;


    PROCEDURE delete_log(x_occurrence number) IS
    --
    -- This procedure is used when a row is deleted from qa_results.
    -- Called by QLTRES.Q_RES_PRIVATE.delete_row.
    --
    BEGIN
        --
        -- Insert a row into QA_BIS_UPDATE_HISTORY to log the deletion.
        --

            INSERT INTO qa_bis_update_history(
                created_by,
                creation_date,
                last_update_login,
                last_updated_by,
                last_update_date,
                occurrence
            )
            VALUES (
                who_user_id,                    -- created_by
                sysdate,                        -- creation_date
                who_last_update_login,          -- last_update_login
                who_user_id,                    -- last_updated_by
                sysdate,                        -- last_update_date
                x_occurrence);

        -- Do not commit because the user may rollback their delete.
        -- Wait until forms does it.

    END delete_log;


    PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
                      RETCODE OUT NOCOPY NUMBER,
                      ARGUMENT1 IN VARCHAR2,     -- Rebuild strategy
                      ARGUMENT2 IN VARCHAR2) IS  -- # of rows between commits
        method number := nvl(to_number(argument1), 1);
        dummy boolean;
    BEGIN

        dummy := fnd_installation.get_app_info('QA', qa_status,
            qa_industry, qa_schema);

        --
        -- Intermittent_commit specifies the no. of rows to process
        -- between commits.  It is here for performance purpose.  If
        -- there is a large no. of rows to process, the rollback segment
        -- becomes increasingly large and drags down performance.
        --
        -- OBSOLETE.  The parallel and append database hints do much
        -- better than intermittent commit.
        -- bso Mon May 21 18:26:38 PDT 2001
        g_intermittent_commit := nvl(to_number(argument2), 1000);

        --
        -- Get current time and last refresh time.  If last refresh is
        -- null, then a complete rebuild will be performed.  This usually
        -- means this is the first time the summary table is being used.
        --
        -- For incremental rebuild:
        --
        -- Delete all rows from QA_BIS_RESULTS that satisfy this
        --
        --     qr.qa_creation_date <= last_refresh <= qr.qa_last_update_date
        --        and qr.qa_last_update_date < current_date
        --
        --        The last condition is needed because we will be writing
        --        current_date to the QA_BIS_UPDATE_HISTORY table as last
        --        refresh time.  All rows updated at or after current_date
        --        will be excluded in this rebuild.  They will be mirrored
        --        in the next rebulid.
        --
        -- Then mirror all rows in QA_RESULTS that satify this
        --
        --     last_refresh <= qr.qa_last_update_date < current_date
        --
        g_current_datetime := qltdate.get_sysdate;
        g_last_refresh := get_last_refresh_datetime;

        IF method = Incremental THEN
            retcode := incremental_rebuild;
        ELSIF method = Complete THEN
            retcode := complete_rebuild;
        ELSE
            retcode := 2;
        END IF;

        errbuf := '';
    END;


END QA_BIS;


/
