--------------------------------------------------------
--  DDL for Package QA_CHART_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CHART_CONTROL_PKG" AUTHID CURRENT_USER AS
/* $Header: qacctrls.pls 120.2 2006/02/08 15:59:46 bso noship $ */
/*#
 * This package is currently a private API to manage
 * Quality's Release 12 Control Chart charting feature.  It is used to
 * populate create and delete Control chart charting data.
 * @rep:scope private
 * @rep:product QA
 * @rep:displayname Control Chart API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY QA_RESULT
 */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


    /*#
     * This procedure creates a control chart charting instance.
     * @param p_criteria_id Foreign key to qa_criteria_headers.criteria_id
     * @param p_chart_type Control chart subtype code
     * @param p_element_id Charting collection element ID
     * @param p_title Chart title to be displayed in the chart
     * @param p_description Chart description for information only
     * @param p_sql SQL string to retrieve the charting data points
     * @param p_subgroup_size Subgroup size
     * @param p_subgroup_num Number of subgroups
     * @param p_dec_prec Decimal precision
     * @param p_top_ucl Upper Control Limit of top chart
     * @param p_top_mean Center line of top chart
     * @param p_top_lcl Lower Control Limit of top chart
     * @param p_bottom_ucl Upper Control Limit of bottom chart
     * @param p_bottom_mean Center line of bottom chart
     * @param p_bottom_lcl Lower Control Limit of bottom chart
     * @param x_chart_id Return a new chart instance header ID (from qa_chart_headers_s).
     * @param x_row_count Return the no. of data rows created
     * @rep:displayname Create a Control chart charting instance
     */
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
        x_row_count          OUT NOCOPY NUMBER);


    /*#
     * This procedure creates a Control chart charting instance.  It performs
     * autonomous commit.
     * @param p_criteria_id Foreign key to qa_criteria_headers.criteria_id
     * @param p_chart_type Control chart subtype code
     * @param p_element_id Charting collection element ID
     * @param p_title Chart title to be displayed in the chart
     * @param p_description Chart description for information only
     * @param p_sql SQL string to retrieve the charting data points
     * @param p_subgroup_size Subgroup size
     * @param p_subgroup_num Number of subgroups
     * @param p_dec_prec Decimal precision
     * @param p_top_ucl Upper Control Limit of top chart
     * @param p_top_mean Center line of top chart
     * @param p_top_lcl Lower Control Limit of top chart
     * @param p_bottom_ucl Upper Control Limit of bottom chart
     * @param p_bottom_mean Center line of bottom chart
     * @param p_bottom_lcl Lower Control Limit of bottom chart
     * @param x_chart_id Return a new chart instance header ID (from qa_chart_headers_s).
     * @param x_row_count Return the no. of data rows created
     * @rep:displayname Create a Control chart charting instance and commit autonomously
     */
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
        x_row_count          OUT NOCOPY NUMBER);


    /*#
     * This procedure deletes the Control chart data points.
     * @param p_chart_id Chart instance header ID to be deleted.
     * @rep:displayname Delete a Control chart's data points
     */
    PROCEDURE delete_data(p_chart_id NUMBER);

    /*#
     * This procedure deletes the Control chart data points.
     * It performs autonomous commit.
     * @param p_chart_id Chart instance header ID to be deleted.
     * @rep:displayname Delete a Control chart's data points and commit autonomously
     */
    PROCEDURE delete_data_autonomous(p_chart_id NUMBER);


END qa_chart_control_pkg;

 

/
