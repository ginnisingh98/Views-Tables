--------------------------------------------------------
--  DDL for Package Body QA_CHART_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHART_CONTROL_PKG" AS
/* $Header: qacctrlb.pls 120.3 2006/02/08 16:26:15 bso noship $ */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


--
-- Define a character to be used as separator to pass two y-axis
-- labels in one shot.  It can be anything that is not possible as
-- as collection element name nor one of the seeded characters.
-- We will use a vertical bar.  The Control Chart Controller
-- Object will use the same character to parse out the y-axises.
--
g_separator CONSTANT VARCHAR2(1) := '|';


    FUNCTION get_x_axis_label(p_subgroup_size NUMBER) RETURN VARCHAR2 IS
    BEGIN
        --
        -- x-axis label is constructed by QA_CHART_CONTROL_X_LABEL
        --
        fnd_message.set_name('QA', 'QA_CHART_CONTROL_X_LABEL');
        fnd_message.set_token('SIZE', p_subgroup_size);
        RETURN fnd_message.get;
    END get_x_axis_label;


    FUNCTION get_y_axis_label(
        p_chart_type NUMBER,
        p_element_id NUMBER) RETURN VARCHAR2 IS

        l_label VARCHAR2(2000);
        l_element qa_chars.name%TYPE;

    BEGIN
        --
        -- The y-axis label is constructed by concatenating the
        -- top chart label and the bottom chart label into one
        -- string by g_separator.  They will be parsed out by
        -- the control chart's Controller Object then set to
        -- the appropriate chart bean.
        --
        -- Top label is QA_CHART_CONTROL_TOP_Y_LABELxx
        -- Bottom label is QA_CHART_CONTROL_BOT_Y_LABELxx
        --
        -- where xx is the subchart type.
        --
        l_element := qa_chars_api.get_element_name(p_element_id);
        fnd_message.set_name('QA', 'QA_CHART_CONTROL_TOP_Y_LABEL' ||
            p_chart_type);
        fnd_message.set_token('ELEMENT_NAME', l_element);
        l_label := fnd_message.get;

        fnd_message.set_name('QA', 'QA_CHART_CONTROL_BOT_Y_LABEL' ||
            p_chart_type);
        fnd_message.set_token('ELEMENT_NAME', l_element);
        l_label := l_label || g_separator || fnd_message.get;

        RETURN l_label;
    END get_y_axis_label;


        PROCEDURE populate_data(
            p_chart_id      NUMBER,
            p_top_ucl       NUMBER,
            p_top_mean      NUMBER,
            p_top_lcl       NUMBER,
            p_bottom_ucl    NUMBER,
            p_bottom_mean   NUMBER,
            p_bottom_lcl    NUMBER,
            x_row_count     OUT NOCOPY NUMBER) IS

        --
        -- This is a very specific private procedure that assumes
        -- qltcontb has been called to populate qa_chart_data
        -- (the old data point table), it then migrates the data over
        -- to the qa_chart_control table.  It does a direct INSERT INTO
        -- qa_chart_control...SELECT FROM qa_chart_data.  This is not
        -- the most efficient way to achieve a histogram, but in order
        -- to completely re-use the legacy code for implementation and
        -- maintenance efficient and, more importantly, to not destabilize
        -- existing code, this is a reasonable approach.
        --
        -- bso Fri Jan 13 18:52:25 PST 2006
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
            -- bso Fri Jan 13 18:57:22 PST 2006
            --
            INSERT INTO qa_chart_control(
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                chart_id,
                line,
                x_value,
                top_y_value,
                top_ucl_value,
                top_mean_value,
                top_lcl_value,
                bottom_y_value,
                bottom_ucl_value,
                bottom_mean_value,
                bottom_lcl_value)
            SELECT
                /* Small amount of data from one session only. */
                /* FTS expected and reviewed by bso 1/13/2006. */
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.login_id,
                p_chart_id,
                rownum,
                subgroup_number,
                average,
                p_top_ucl,
                p_top_mean,
                p_top_lcl,
                nvl(range, 0),  -- range can be NULL for XmR
                p_bottom_ucl,
                p_bottom_mean,
                p_bottom_lcl
            FROM
                qa_chart_data;

            x_row_count := sql%ROWCOUNT;

        END populate_data;


    PROCEDURE create_chart(
        p_criteria_id                   NUMBER,
        p_chart_type                    NUMBER,
        p_element_id                    NUMBER,
        p_title                         VARCHAR2,
        p_description                   VARCHAR2,
        p_sql                           VARCHAR2,
        p_subgroup_size                 NUMBER,
        p_subgroup_num                  NUMBER,
        p_dec_prec                      NUMBER,
        p_top_ucl                       NUMBER,
        p_top_mean                      NUMBER,
        p_top_lcl                       NUMBER,
        p_bottom_ucl                    NUMBER,
        p_bottom_mean                   NUMBER,
        p_bottom_lcl                    NUMBER,
        x_chart_id           OUT NOCOPY NUMBER,
        x_row_count          OUT NOCOPY NUMBER) IS

        l_dec_prec       NUMBER;
        l_subgroup_num   NUMBER;

        --
        -- The following are dummies required by qltcontb
        --
        l_top_mean       NUMBER;
        l_bottom_mean    NUMBER;
        l_top_ucl        NUMBER;
        l_top_lcl        NUMBER;
        l_bottom_ucl     NUMBER;
        l_bottom_lcl     NUMBER;
        l_dummy          NUMBER;

    BEGIN

        l_dec_prec := nvl(p_dec_prec, 12);
        l_subgroup_num := p_subgroup_num;

        qa_chart_headers_pkg.create_chart(
            p_criteria_id => p_criteria_id,
            p_title => p_title,
            p_description => p_description,
            p_x_label => get_x_axis_label(p_subgroup_size),
            p_y_label => get_y_axis_label(p_chart_type, p_element_id),
            x_chart_id => x_chart_id);

        CASE p_chart_type
        WHEN qa_ss_const.control_chart_XBarR THEN
            qltcontb.x_bar_r(
                sql_string => p_sql,
                subgrp_size => p_subgroup_size,
                num_subgroups => l_subgroup_num,
                dec_prec => l_dec_prec,
                grand_mean => l_top_mean,
                range_average => l_bottom_mean,
                ucl => l_top_ucl,
                lcl => l_top_lcl,
                r_ucl => l_bottom_ucl,
                r_lcl => l_bottom_lcl,
                not_enough_data => l_dummy,
                compute_new_limits => false);

        WHEN qa_ss_const.control_chart_XmR THEN
            qltcontb.xmr(
                sql_string => p_sql,
                subgrp_size => p_subgroup_size,
                num_points => l_subgroup_num,
                dec_prec => l_dec_prec,
                grand_mean => l_top_mean,
                range_average => l_bottom_mean,
                ucl => l_top_ucl,
                lcl => l_top_lcl,
                r_ucl => l_bottom_ucl,
                r_lcl => l_bottom_lcl,
                not_enough_data => l_dummy,
                compute_new_limits => false);

        WHEN qa_ss_const.control_chart_XBarS THEN
            qltcontb.x_bar_s(
                sql_string => p_sql,
                subgrp_size => p_subgroup_size,
                num_subgroups => l_subgroup_num,
                dec_prec => l_dec_prec,
                grand_mean => l_top_mean,
                std_dev_average => l_bottom_mean,
                ucl => l_top_ucl,
                lcl => l_top_lcl,
                r_ucl => l_bottom_ucl,
                r_lcl => l_bottom_lcl,
                not_enough_data => l_dummy,
                compute_new_limits => false);
        END CASE;

        populate_data(
            p_chart_id => x_chart_id,
            p_top_ucl => p_top_ucl,
            p_top_mean => p_top_mean,
            p_top_lcl => p_top_lcl,
            p_bottom_ucl => p_bottom_ucl,
            p_bottom_mean => p_bottom_mean,
            p_bottom_lcl => p_bottom_lcl,
            x_row_count => x_row_count);

        DELETE
            /* Small amount of data from one session only. */
            /* FTS expected and reviewed by bso 1/13/2006. */
            FROM qa_chart_data;

    END create_chart;


    PROCEDURE create_chart_autonomous(
        p_criteria_id                   NUMBER,
        p_chart_type                    NUMBER,
        p_element_id                    NUMBER,
        p_title                         VARCHAR2,
        p_description                   VARCHAR2,
        p_sql                           VARCHAR2,
        p_subgroup_size                 NUMBER,
        p_subgroup_num                  NUMBER,
        p_dec_prec                      NUMBER,
        p_top_ucl                       NUMBER,
        p_top_mean                      NUMBER,
        p_top_lcl                       NUMBER,
        p_bottom_ucl                    NUMBER,
        p_bottom_mean                   NUMBER,
        p_bottom_lcl                    NUMBER,
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
            p_chart_type,
            p_element_id,
            p_title,
            p_description,
            p_sql,
            p_subgroup_size,
            p_subgroup_num,
            p_dec_prec,
            p_top_ucl,
            p_top_mean,
            p_top_lcl,
            p_bottom_ucl,
            p_bottom_mean,
            p_bottom_lcl,
            x_chart_id,
            x_row_count);
        COMMIT;
    END create_chart_autonomous;


    PROCEDURE delete_data(p_chart_id NUMBER) IS
    BEGIN
        DELETE FROM qa_chart_control
        WHERE chart_id = p_chart_id;
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


END qa_chart_control_pkg;

/
