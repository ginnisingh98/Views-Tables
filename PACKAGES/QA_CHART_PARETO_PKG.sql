--------------------------------------------------------
--  DDL for Package QA_CHART_PARETO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CHART_PARETO_PKG" AUTHID CURRENT_USER AS
/* $Header: qacprtos.pls 120.2 2006/03/20 12:06:15 bso noship $ */
/*#
 * This package is currently a private API to manage
 * Quality's Release 12 Pareto charting feature.  It is used to
 * populate create and delete Pareto chart charting data.
 * @rep:scope private
 * @rep:product QA
 * @rep:displayname Pareto Chart API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY QA_RESULT
 */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


    /*#
     * This procedure creates a pareto charting instance.
     * @param p_criteria_id Foreign key to qa_criteria_headers.criteria_id
     * @param p_x_element_id Charting x-axis collection element ID
     * @param p_y_element_id Charting y-axis collection element ID
     * @param p_function_code y-axis aggregate function
     * @param p_title Chart title to be displayed in the chart
     * @param p_description Chart description for information only
     * @param p_sql SQL string to retrieve the charting data points
     * @param p_top_n_groups Top N groups to plot.  Default to all points.
     * @param x_chart_id Return a new chart instance header ID (from qa_chart_headers_s).
     * @param x_row_count Return the no. of data rows created
     * @rep:displayname Create a Pareto chart charting instance
     */
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
        x_row_count          OUT NOCOPY NUMBER);


    /*#
     * This procedure creates a pareto charting instance.  It performs
     * autonomous commit.
     * @param p_criteria_id Foreign key to qa_criteria_headers.criteria_id
     * @param p_x_element_id Charting x-axis collection element ID
     * @param p_y_element_id Charting y-axis collection element ID
     * @param p_function_code y-axis aggregate function
     * @param p_title Chart title to be displayed in the chart
     * @param p_description Chart description for information only
     * @param p_sql SQL string to retrieve the charting data points
     * @param p_top_n_groups Top N groups to plot.  Default to all points.
     * @param x_chart_id Return a new chart instance header ID (from qa_chart_headers_s).
     * @param x_row_count Return the no. of data rows created
     * @rep:displayname Create a Pareto chart charting instance and commit autonomously
     */
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
        x_row_count          OUT NOCOPY NUMBER);


    /*#
     * This procedure deletes the Pareto chart data points.
     * @param p_chart_id Chart instance header ID to be deleted.
     * @rep:displayname Delete a Pareto chart's data points
     */
    PROCEDURE delete_data(p_chart_id NUMBER);

    /*#
     * This procedure deletes the Pareto chart data points.
     * It performs autonomous commit.
     * @param p_chart_id Chart instance header ID to be deleted.
     * @rep:displayname Delete a Pareto chart's data points and commit autonomously
     */
    PROCEDURE delete_data_autonomous(p_chart_id NUMBER);


END qa_chart_pareto_pkg;

 

/
