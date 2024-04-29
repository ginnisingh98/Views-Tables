--------------------------------------------------------
--  DDL for Package Body QA_CHART_PARETO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHART_PARETO_PKG" AS
/* $Header: qacprtob.pls 120.1 2006/03/20 12:06:58 bso noship $ */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


    FUNCTION get_x_axis_label(
        p_element_id NUMBER,
        p_count NUMBER) RETURN VARCHAR2 IS
    BEGIN
        --
        -- x-axis label is constructed from the message
        -- QA_CHART_PARETO_X_LABEL
        --
        fnd_message.set_name('QA', 'QA_CHART_PARETO_X_LABEL');
        fnd_message.set_token('ELEMENT_NAME',
            qa_chars_api.get_element_name(p_element_id));
        fnd_message.set_token('COUNT', p_count);

        RETURN fnd_message.get;
    END get_x_axis_label;


    --
    -- Bug 5044017.  Added p_top_n_groups bso Mon Mar 20 11:33:24 PST 2006
    --
    PROCEDURE create_chart(
        p_criteria_id                   NUMBER,
        p_x_element_id                  NUMBER,
        p_y_element_id                  NUMBER,
        p_function_code                 NUMBER,
        p_title                         VARCHAR2,
        p_description                   VARCHAR2,
        p_sql                           VARCHAR2,
        p_top_n_groups                  NUMBER DEFAULT NULL,
        x_chart_id           OUT NOCOPY NUMBER,
        x_row_count          OUT NOCOPY NUMBER) IS

    BEGIN
        --
        -- Simple wrapper to qa_chart_generic_pkg since a Pareto
        -- Chart uses the generic charting architecture.
        --

        qa_chart_headers_pkg.create_chart(
            p_criteria_id => p_criteria_id,
            p_title => p_title,
            p_description => p_description,
            p_x_label => 'DUMMY',
            p_y_label =>
                qa_chart_headers_pkg.get_function_axis_label(
                    p_element_id => p_y_element_id,
                    p_function_code => p_function_code),
            x_chart_id => x_chart_id);

        --
        -- Bug 5044017.  Need to limit the SQL to select top_n_groups
        --
        qa_chart_generic_pkg.populate_data(
            p_chart_id => x_chart_id,
            p_sql => p_sql,
            p_row_limit => p_top_n_groups,
            x_row_count => x_row_count);

        --
        -- x-axis label is a bit tricky, it needs to know the
        -- row_count, therefore we created the header with a
        -- 'DUMMY' x-axis label and now update it.
        --
        qa_chart_headers_pkg.set_x_label(
            p_chart_id => x_chart_id,
            p_label => get_x_axis_label(p_x_element_id, x_row_count));

    END create_chart;


    --
    -- Bug 5044017.  Added p_top_n_groups bso Mon Mar 20 11:33:24 PST 2006
    --
    PROCEDURE create_chart_autonomous(
        p_criteria_id                   NUMBER,
        p_x_element_id                  NUMBER,
        p_y_element_id                  NUMBER,
        p_function_code                 NUMBER,
        p_title                         VARCHAR2,
        p_description                   VARCHAR2,
        p_sql                           VARCHAR2,
        p_top_n_groups                  NUMBER DEFAULT NULL,
        x_chart_id           OUT NOCOPY NUMBER,
        x_row_count          OUT NOCOPY NUMBER) IS

    --
    -- This is a wrapper to create_chart and performs
    -- autonomous commit.
    --
    PRAGMA autonomous_transaction;

    BEGIN
        create_chart(
            p_criteria_id,
            p_x_element_id,
            p_y_element_id,
            p_function_code,
            p_title,
            p_description,
            p_sql,
            p_top_n_groups,
            x_chart_id,
            x_row_count);
        COMMIT;
    END create_chart_autonomous;


    PROCEDURE delete_data(p_chart_id NUMBER) IS
    --
    -- This is a simple wrapper to qa_chart_generic_pkg
    -- since Pareto Chart uses generic charting architecture.
    --
    BEGIN
        qa_chart_generic_pkg.delete_data(p_chart_id);
    END delete_data;


    PROCEDURE delete_data_autonomous(p_chart_id NUMBER) IS
    --
    -- This is a wrapper to delete_data and performs
    -- autonomous commit.
    --
    PRAGMA autonomous_transaction;
    BEGIN
        delete_data(p_chart_id);
        COMMIT;
    END delete_data_autonomous;


END qa_chart_pareto_pkg;

/
