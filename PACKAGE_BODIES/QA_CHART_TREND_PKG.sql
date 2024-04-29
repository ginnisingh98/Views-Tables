--------------------------------------------------------
--  DDL for Package Body QA_CHART_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHART_TREND_PKG" AS
/* $Header: qactrndb.pls 120.0 2006/02/07 16:03:37 bso noship $ */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


    FUNCTION get_x_axis_label(p_code NUMBER) RETURN VARCHAR2 IS
    BEGIN
        --
        -- x-axis label for Trend chart is the meaning of the
        -- mfg_lookups QA_TIME_SERIES_AXIS.  So the p_code
        -- is actually the lookup_code.
        --
        RETURN qa_eres_util.get_mfg_lookups_meaning(
            p_lookup_type => 'QA_TIME_SERIES_AXIS',
            p_lookup_code => p_code);
    END get_x_axis_label;


    PROCEDURE create_chart(
        p_criteria_id                   NUMBER,
        p_x_element_id                  NUMBER,
        p_y_element_id                  NUMBER,
        p_function_code                 NUMBER,
        p_title                         VARCHAR2,
        p_description                   VARCHAR2,
        p_sql                           VARCHAR2,
        x_chart_id           OUT NOCOPY NUMBER,
        x_row_count          OUT NOCOPY NUMBER) IS

    BEGIN
        --
        -- Simple wrapper to qa_chart_generic_pkg since a Trend
        -- Chart uses the generic charting architecture.
        --

        qa_chart_headers_pkg.create_chart(
            p_criteria_id => p_criteria_id,
            p_title => p_title,
            p_description => p_description,
            p_x_label => get_x_axis_label(p_x_element_id),
            p_y_label =>
                qa_chart_headers_pkg.get_function_axis_label(
                    p_element_id => p_y_element_id,
                    p_function_code => p_function_code),
            x_chart_id => x_chart_id);

        qa_chart_generic_pkg.populate_data(
            p_chart_id => x_chart_id,
            p_sql => p_sql,
            x_row_count => x_row_count);

    END create_chart;


    PROCEDURE create_chart_autonomous(
        p_criteria_id                   NUMBER,
        p_x_element_id                  NUMBER,
        p_y_element_id                  NUMBER,
        p_function_code                 NUMBER,
        p_title                         VARCHAR2,
        p_description                   VARCHAR2,
        p_sql                           VARCHAR2,
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
            x_chart_id,
            x_row_count);
        COMMIT;
    END create_chart_autonomous;


    PROCEDURE delete_data(p_chart_id NUMBER) IS
    --
    -- This is a simple wrapper to qa_chart_generic_pkg
    -- since Trend Chart uses generic charting architecture.
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


END qa_chart_trend_pkg;

/
