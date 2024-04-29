--------------------------------------------------------
--  DDL for Package Body QA_CHART_HISTOGRAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHART_HISTOGRAM_PKG" AS
/* $Header: qachistb.pls 120.1 2006/08/09 01:05:16 bso noship $ */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


        PROCEDURE populate_data(
            p_chart_id NUMBER,
            x_row_count OUT NOCOPY NUMBER) IS

        --
        -- This is a very specific private procedure that assumes
        -- qltcontb.histogram has been called to populate qa_chart_data
        -- (the old data point table), it then migrates the data over
        -- to the qa_chart_generic table.  It does a direct INSERT INTO
        -- qa_chart_generic...SELECT FROM qa_chart_data.  This is not
        -- the most efficient way to achieve a histogram, but in order
        -- to completely re-use the legacy code for implementation and
        -- maintenance efficient and, more importantly, to not destabilize
        -- existing code, this is a reasonable approach.
        --
        -- bso Wed Jan 11 13:53:16 PST 2006
        --

        BEGIN
            --
            -- There is no WHERE clause because this table always
            -- hold data for one single session.  This will result
            -- in a Full Table Scan in Performance Repository.
            -- This is expected and there is no performance issue
            -- as the session data will be rolled back momentarily,
            -- so it always contains a small no. of records only.
            --
            -- bso Wed Jan 11 13:54:47 PST 2006
            --
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
            SELECT
                /* Small amount of data from one session only. */
                /* FTS expected and reviewed by bso 1/11/2006. */
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.login_id,
                p_chart_id,
                bar_number,
                hist_range,
                num_occurrences
            FROM
                qa_chart_data;

            x_row_count := sql%ROWCOUNT;

        END populate_data;


        FUNCTION get_x_axis_label(
            p_element_id NUMBER,
            p_spec_id NUMBER) RETURN VARCHAR2 IS
        --
        -- Construct the x-axis label.
        -- If p_spec_id is null, it is simply the <element name>.
        -- Else, it features both the <element name> and the <spec name>
        -- in a message QA_CHART_HISTOGRAM_X_LABEL.
        --
        BEGIN

            IF p_spec_id IS NULL THEN
                RETURN qa_chars_api.get_element_name(p_element_id);
            ELSE
                fnd_message.set_name('QA', 'QA_CHART_HISTOGRAM_X_LABEL');
                fnd_message.set_token('ELEMENT_NAME',
                    qa_chars_api.get_element_name(p_element_id));
                fnd_message.set_token('SPEC_NAME',
                    qa_specs_pkg.get_spec_name(p_spec_id));

                RETURN fnd_message.get;
            END IF;

        END get_x_axis_label;


        FUNCTION get_y_axis_label RETURN VARCHAR2 IS
        --
        -- y-axis label is always the function name "Count", translated.
        --
        BEGIN
            RETURN qa_eres_util.get_mfg_lookups_meaning(
                p_lookup_type => 'QA_FUNCTION',
                p_lookup_code => qa_ss_const.chart_function_count);
        END get_y_axis_label;


    PROCEDURE create_chart(
    --
    --  This is a wrapper to the original qltcontb.histogram
    --  procedure.  It calls qltcontb.histogram and then calls
    --  populate_data.  It will be called by QLTENGIN.pld.
    --
    --  Bug 5130880 Added target value.
    --
        p_criteria_id                   NUMBER,
        p_element_id                    NUMBER,
        p_spec_id                       NUMBER,
        p_title                         VARCHAR2,
        p_description                   VARCHAR2,
        p_sql                           VARCHAR2,
        p_dec_prec                      NUMBER,
        p_usl                           NUMBER,
        p_lsl                           NUMBER,
        p_target_value                  NUMBER,
        x_cp              IN OUT NOCOPY NUMBER,
        x_cpk             IN OUT NOCOPY NUMBER,
        x_num_points      IN OUT NOCOPY NUMBER,
        x_num_bars        IN OUT NOCOPY NUMBER,
        x_chart_id           OUT NOCOPY NUMBER,
        x_row_count          OUT NOCOPY NUMBER) IS

        l_dummy NUMBER;

    BEGIN

        --
        -- Main worker to populate the data points in qa_chart_data
        -- table.  This is a pre-R12 existing API.
        --
        qltcontb.histogram(
            sql_string => p_sql,
            num_points => x_num_points,
            dec_prec => p_dec_prec,
            num_bars => x_num_bars,
            usl => p_usl,
            lsl => p_lsl,
            cp => x_cp,
            cpk => x_cpk,
            not_enough_data => l_dummy);

        qa_chart_headers_pkg.create_chart(
            p_criteria_id => p_criteria_id,
            p_title => p_title,
            p_description => p_description,
            p_x_label => get_x_axis_label(p_element_id, p_spec_id),
            p_y_label => get_y_axis_label,
            x_chart_id => x_chart_id);

        --
        -- Bug 5130880.  Need to have spec limits, cp, cpk and uom code
        -- in the chart header for display purpose.
        -- bso Tue Aug  8 17:25:53 PDT 2006
        --
        UPDATE qa_chart_headers
        SET    last_update_date = sysdate,
               upper_spec_limit = p_usl,
               lower_spec_limit = p_lsl,
               target_value = p_target_value,
               cp = x_cp,
               cpk = x_cpk,
               uom_code = (
                   SELECT uom_code
                   FROM   qa_spec_chars
                   WHERE  spec_id = p_spec_id AND
                          char_id = p_element_id)
        WHERE  chart_id = x_chart_id;

        populate_data(x_chart_id, x_row_count);

        DELETE
            /* Small amount of data from one session only. */
            /* FTS expected and reviewed by bso 1/11/2006. */
            FROM qa_chart_data;

    END create_chart;


    PROCEDURE create_chart_autonomous(
    --
    --  This is a wrapper to create_chart and performs
    --  autonomous commit.
    --
    --  Bug 5130880 Added target value.
    --
        p_criteria_id                   NUMBER,
        p_element_id                    NUMBER,
        p_spec_id                       NUMBER,
        p_title                         VARCHAR2,
        p_description                   VARCHAR2,
        p_sql                           VARCHAR2,
        p_dec_prec                      NUMBER,
        p_usl                           NUMBER,
        p_lsl                           NUMBER,
        p_target_value                  NUMBER,
        x_cp              IN OUT NOCOPY NUMBER,
        x_cpk             IN OUT NOCOPY NUMBER,
        x_num_points      IN OUT NOCOPY NUMBER,
        x_num_bars        IN OUT NOCOPY NUMBER,
        x_chart_id           OUT NOCOPY NUMBER,
        x_row_count          OUT NOCOPY NUMBER) IS

    PRAGMA autonomous_transaction;

    BEGIN
        create_chart(
            p_criteria_id,
            p_element_id,
            p_spec_id,
            p_title,
            p_description,
            p_sql,
            p_dec_prec,
            p_usl,
            p_lsl,
            p_target_value,
            x_cp,
            x_cpk,
            x_num_points,
            x_num_bars,
            x_chart_id,
            x_row_count);
        COMMIT;
    END create_chart_autonomous;


    PROCEDURE delete_data(p_chart_id NUMBER) IS
    --
    -- This is a simple wrapper to qa_chart_generic_pkg
    -- since Histogram uses generic charting architecture.
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


END qa_chart_histogram_pkg;

/
