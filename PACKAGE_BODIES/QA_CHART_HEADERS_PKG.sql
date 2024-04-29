--------------------------------------------------------
--  DDL for Package Body QA_CHART_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHART_HEADERS_PKG" AS
/* $Header: qachartb.pls 120.1 2006/03/20 10:51:15 bso noship $ */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --

    PROCEDURE create_chart(
    --
    -- Create a new record in qa_chart_headers.  Return
    -- the newly generated chart header ID in x_chart_id.
    --
    -- bso Mon Jan  9 15:19:52 PST 2006
    --
        p_criteria_id  NUMBER,
        p_title        VARCHAR2,
        p_description  VARCHAR2,
        p_x_label      VARCHAR2,
        p_y_label      VARCHAR2,
        x_chart_id     OUT NOCOPY NUMBER) IS

    BEGIN
        INSERT INTO qa_chart_headers(
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            chart_id,
            criteria_id,
            title,
            description,
            x_label,
            y_label)
        VALUES(
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.login_id,
            qa_chart_headers_s.nextval,
            p_criteria_id,
            p_title,
            p_description,
            p_x_label,
            p_y_label)
        RETURNING
            chart_id
        INTO
            x_chart_id;

    END create_chart;


    PROCEDURE delete_chart(p_chart_id NUMBER) IS
    --
    -- This procedure deletes a chart (header and detail
    -- data points will be deleted together).
    --
    -- bso Mon Jan  9 15:24:20 PST 2006
    --

        l_criteria_id NUMBER;
        l_output_type NUMBER;

    BEGIN

        --
        -- First delete the header, get the criteria ID FK as a
        -- side effect.
        --
        DELETE
        FROM        qa_chart_headers
        WHERE       chart_id = p_chart_id
        RETURNING   criteria_id
        INTO        l_criteria_id;

        --
        -- From the criteria_id FK, find the chart "output type".
        -- which is just the type of chart.
        --
        -- Bug 5043954 Unnecessary error messages after viewing
        -- unsaved charts.  l_criteria_id may be NULL in which
        -- case the SELECT INTO will error out with no data found.
        -- Adding an exception catcher here and then add ELSE in
        -- the CASE statement below.
        -- bso Mon Mar 20 10:40:09 PST 2006
        --

        BEGIN
            SELECT output_type
            INTO   l_output_type
            FROM   qa_criteria_headers
            WHERE  criteria_id = l_criteria_id;
        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        --
        -- Now determine which package to call to delete
        -- the detail data points.
        --

        CASE l_output_type

        WHEN qa_ss_const.output_type_histogram THEN
            qa_chart_histogram_pkg.delete_data(p_chart_id);

        WHEN qa_ss_const.output_type_pareto THEN
            qa_chart_pareto_pkg.delete_data(p_chart_id);

        WHEN qa_ss_const.output_type_trend THEN
            qa_chart_trend_pkg.delete_data(p_chart_id);

        WHEN qa_ss_const.output_type_control THEN
            qa_chart_control_pkg.delete_data(p_chart_id);

        ELSE
            --
            -- Bug 5043954 Unnecessary error messages after viewing
            -- unsaved charts.  This is due to output_type being
            -- NULL.  Perform conservative deletions on all child
            -- data tables since user hasn't saved the criteria
            -- header and we don't know what chart type it is.
            -- Very rare case.
            -- bso Mon Mar 20 10:37:03 PST 2006
            --
            qa_chart_generic_pkg.delete_data(p_chart_id);
            qa_chart_control_pkg.delete_data(p_chart_id);

        END CASE;

    END delete_chart;


    PROCEDURE create_chart_autonomous(
        p_criteria_id  NUMBER,
        p_title        VARCHAR2,
        p_description  VARCHAR2,
        p_x_label      VARCHAR2,
        p_y_label      VARCHAR2,
        x_chart_id     OUT NOCOPY NUMBER) IS

    PRAGMA autonomous_transaction;

    BEGIN
        create_chart(
            p_criteria_id,
            p_title,
            p_description,
            p_x_label,
            p_y_label,
            x_chart_id);
        COMMIT;
    END create_chart_autonomous;


    PROCEDURE delete_chart_autonomous(p_chart_id NUMBER) IS
    PRAGMA autonomous_transaction;
    BEGIN
        delete_chart(p_chart_id);
        COMMIT;
    END delete_chart_autonomous;


    PROCEDURE set_x_label(p_chart_id NUMBER, p_label VARCHAR2) IS
    BEGIN
        UPDATE qa_chart_headers
        SET    x_label = p_label
        WHERE  chart_id = p_chart_id;
    END set_x_label;


    PROCEDURE set_y_label(p_chart_id NUMBER, p_label VARCHAR2) IS
    BEGIN
        UPDATE qa_chart_headers
        SET    y_label = p_label
        WHERE  chart_id = p_chart_id;
    END set_y_label;


    FUNCTION get_function_axis_label(
        p_element_id NUMBER,
        p_function_code NUMBER) RETURN VARCHAR2 IS
    BEGIN
        --
        -- If function code is null, simply return the element
        -- name, else label is constructed from the message
        -- QA_CHART_FUNCTION_LABEL
        --
        IF p_function_code IS NULL THEN
            RETURN qa_chars_api.get_element_name(p_element_id);
        ELSE
            fnd_message.set_name('QA', 'QA_CHART_FUNCTION_LABEL');
            fnd_message.set_token('FUNCTION',
                qa_eres_util.get_mfg_lookups_meaning(
                'QA_FUNCTION', p_function_code));
            fnd_message.set_token('ELEMENT_NAME',
                qa_chars_api.get_element_name(p_element_id));
            RETURN fnd_message.get;
        END IF;
    END get_function_axis_label;

END qa_chart_headers_pkg;

/
