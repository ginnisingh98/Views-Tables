--------------------------------------------------------
--  DDL for Package Body QA_CHART_GENERIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHART_GENERIC_PKG" AS
/* $Header: qacgenb.pls 120.2 2006/03/20 12:08:39 bso noship $ */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --

    PROCEDURE populate_data(
    --
    -- A simple procedure to execute a SQL and populate the
    -- qa_chart_generic table with the resulting values.  The SQL
    -- should always select two columns: x-axis ticker label and
    -- numeric y-value and should almost ways have an ORDER BY clause
    -- so that the leftmost x-axis ticker as appear on the resultant
    -- graph comes first and so forth.
    --
    -- bso Tue Jan 10 16:10:13 PST 2006
    --
        p_chart_id NUMBER,
        p_sql VARCHAR2,
        p_row_limit NUMBER DEFAULT NULL,
        x_row_count OUT NOCOPY NUMBER) IS

        l_x_values dbms_sql.varchar2s;
        l_y_values dbms_sql.number_table;
        l_line_values dbms_sql.number_table;
        l_row_count NUMBER;
        l_sql VARCHAR2(30000);

    BEGIN
        --
        -- Dev Notes: This does not work if l_sql contains GROUP BY
        -- becuase rownum cannot be used as SELECT when there is GB.
        --
        -- Constructed a simple SQL by using the input p_sql string
        -- so to query all all data selected by it and populate
        -- the qa_chart_generic table with the results.
        --
        -- l_sql :=
        --   'INSERT INTO qa_chart_generic(
        --        created_by,
        --        creation_date,
        --        last_updated_by,
        --        last_update_date,
        --        last_update_login,
        --        chart_id,
        --        line,
        --        x_value,
        --        y_value)
        --    SELECT
        --        fnd_global.user_id,
        --        sysdate,
        --        fnd_global.user_id,
        --        sysdate,
        --        fnd_global.login_id,
        --        :1,
        --        rownum,' ||
        --    l_sql;
        --

            --
            -- Dev Notes: A different method has been investigated to
            -- see if there is really a need to chop off the SELECT:
            --
            -- SELECT * FROM
            --     (SELECT fnd_global.user_id, sysdate ... etc FROM dual),
            --     (<original SQL>);
            --
            -- It seems to work, except there doesn't seem to be a way
            -- to generate incremental line numbers for the line column.
            -- Adding rownum to the dual clause simply generates rownum
            -- once (i.e., all lines will have 1).
            --
            -- bso Tue Jan 10 16:48:14 PST 2006
            --

        --
        -- Rewritten to use BULK COLLECT
        -- bso Wed Feb  8 14:43:03 PST 2006
        --

        --
        -- Bug 5044017.  If p_row_limit is given, rewrite the SQL so
        -- only first p_row_limit rows are fetched by applying a rownum
        -- filter.  Needed for Pareto top_n_groups feature but is also
        -- a generic feature for future purpose.
        -- bso Mon Mar 20 11:43:04 PST 2006
        --
        IF p_row_limit IS NULL THEN
            EXECUTE IMMEDIATE p_sql
            BULK COLLECT INTO l_x_values, l_y_values;
        ELSE
            l_sql := 'SELECT * FROM (' || p_sql ||
                     ') WHERE rownum <= :1';

            EXECUTE IMMEDIATE l_sql
            BULK COLLECT INTO l_x_values, l_y_values
            USING p_row_limit;
        END IF;

        l_row_count := sql%ROWCOUNT;

        FOR i IN l_x_values.FIRST .. l_x_values.LAST LOOP
            l_line_values(i) := i;
        END LOOP;

        --
        -- Notice, currently the legend column of qa_chart_generic
        -- is unused.  In future expansion, we may introduce a new
        -- procedure populate_data_with_legend where the input SQL
        -- string selects a third (legend) column to populate it.
        --
        IF l_row_count > 0 THEN
            FORALL i IN 1 .. l_row_count
                INSERT INTO qa_chart_generic(
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    chart_id,
                    line,
                    x_value,
                    y_value)
                VALUES (
                    fnd_global.user_id,  -- created_by
                    sysdate,             -- creation_date
                    fnd_global.user_id,  -- last_updated_by
                    sysdate,             -- last_update_date
                    fnd_global.login_id, -- last_update_login
                    p_chart_id,          -- chart_id
                    l_line_values(i),    -- line
                    l_x_values(i),       -- x_value
                    l_y_values(i));      -- y_value
        END IF;

        x_row_count := l_row_count;

    END populate_data;


    PROCEDURE populate_data_autonomous(
        p_chart_id NUMBER,
        p_sql VARCHAR2,
        p_row_limit NUMBER DEFAULT NULL,
        x_row_count OUT NOCOPY NUMBER) IS

    PRAGMA autonomous_transaction;

    BEGIN
        populate_data(
            p_chart_id,
            p_sql,
            p_row_limit,
            x_row_count);
        COMMIT;
    END populate_data_autonomous;


    PROCEDURE delete_data(p_chart_id NUMBER) IS
    BEGIN
        DELETE FROM qa_chart_generic
        WHERE chart_id = p_chart_id;
    END delete_data;


    PROCEDURE delete_data_autonomous(p_chart_id NUMBER) IS
    PRAGMA autonomous_transaction;
    BEGIN
        delete_data(p_chart_id);
        COMMIT;
    END delete_data_autonomous;



END qa_chart_generic_pkg;

/
