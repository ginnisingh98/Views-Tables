--------------------------------------------------------
--  DDL for Package QA_CHART_HISTOGRAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CHART_HISTOGRAM_PKG" AUTHID CURRENT_USER AS
/* $Header: qachists.pls 120.2 2006/08/09 01:04:54 bso noship $ */
/*#
 * This package is currently a private API to manage
 * Quality's Release 12 Histogram charting feature.  It is used to
 * populate create and delete histogram charting data.
 * @rep:scope private
 * @rep:product QA
 * @rep:displayname Histogram API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY QA_RESULT
 */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


    --  Bug 5130880 Added target value.
    /*#
     * This procedure creates a histogram charting instance.
     * @param p_criteria_id Foreign key to qa_criteria_headers.criteria_id
     * @param p_element_id Charting collection element ID
     * @param p_spec_id Specification used if non-null
     * @param p_title Chart title to be displayed in the chart
     * @param p_description Chart description for information only
     * @param p_sql SQL string to retrieve the charting data points
     * @param p_dec_prec Decimal precision
     * @param p_usl Upper spec limit
     * @param p_lsl Lower spec limit
     * @param p_target_value Target value
     * @param x_cp Statistical data: cp
     * @param x_cpk Statistical data: cpk
     * @param x_num_points Statistical data: number of points
     * @param x_num_bars Number of bars to show in the histogram
     * @param x_chart_id Return a new chart instance header ID (from qa_chart_headers_s).
     * @param x_row_count Return the no. of data rows created
     * @rep:displayname Create a histogram charting instance
     */
    PROCEDURE create_chart(
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
        x_row_count          OUT NOCOPY NUMBER);


    --  Bug 5130880 Added target value.
    /*#
     * This procedure creates a histogram charting instance.
     * It performs autonomous commit.
     * @param p_criteria_id Foreign key to qa_criteria_headers.criteria_id
     * @param p_element_id Charting collection element ID
     * @param p_spec_id Specification used if non-null
     * @param p_title Chart title to be displayed in the chart
     * @param p_description Chart description for information only
     * @param p_sql SQL string to retrieve the charting data points
     * @param p_dec_prec Decimal precision
     * @param p_usl Upper spec limit
     * @param p_lsl Lower spec limit
     * @param p_target_value Target value
     * @param x_cp Statistical data: cp
     * @param x_cpk Statistical data: cpk
     * @param x_num_points Statistical data: number of points
     * @param x_num_bars Number of bars to show in the histogram
     * @param x_chart_id Return a new chart instance header ID (from qa_chart_headers_s).
     * @param x_row_count Return the no. of data rows created
     * @rep:displayname Create a histogram charting instance and commit autonomously
     */
    PROCEDURE create_chart_autonomous(
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
        x_row_count          OUT NOCOPY NUMBER);


    /*#
     * This procedure deletes the histogram data points.
     * @param p_chart_id Chart instance header ID to be deleted.
     * @rep:displayname Delete a histogram's data points
     */
    PROCEDURE delete_data(p_chart_id NUMBER);

    /*#
     * This procedure deletes the histogram data points.
     * It performs autonomous commit.
     * @param p_chart_id Chart instance header ID to be deleted.
     * @rep:displayname Delete a histogram's data points and commit autonomously
     */
    PROCEDURE delete_data_autonomous(p_chart_id NUMBER);


END qa_chart_histogram_pkg;

 

/
