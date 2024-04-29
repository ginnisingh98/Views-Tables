--------------------------------------------------------
--  DDL for Package QA_CHART_GENERIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CHART_GENERIC_PKG" AUTHID CURRENT_USER AS
/* $Header: qacgens.pls 120.2 2006/03/20 12:08:09 bso noship $ */
/*#
 * This package is currently a private API to interface with
 * Quality's Release 12 Charting Architecture.  It is used to
 * create data points for a generic chart.  A generic chart is
 * one that has simple x-axis ticker labels and y-axis numeric
 * values.
 * @rep:scope private
 * @rep:product QA
 * @rep:displayname Generic Chart Data API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY QA_RESULT
 */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


    /*#
     * This procedure populates the qa_chart_generic table with
     * data points.  The caller passes in a SQL string that must
     * select two columns, x-axis ticker labels and numeric y-axis
     * values.  The SQL should almost always have an ORDER BY clause
     * so the leftmost x-axis ticker as appear on the resultant
     * graph comes first and so forth.
     * @param p_chart_id Foreign key to qa_chart_headers.chart_id.
     * @param p_sql A SQL string
     * @param p_row_limit No. of rows to fetch (default to all)
     * @param x_row_count Return the no. of data rows created
     * @rep:displayname Create generic chart data from a SQL
     */
    PROCEDURE populate_data(
        p_chart_id     NUMBER,
        p_sql          VARCHAR2,
        p_row_limit    NUMBER DEFAULT NULL,
        x_row_count    OUT NOCOPY NUMBER);


    /*#
     * This procedure populates the qa_chart_generic table with
     * data points.  It is the same as populate_data except it
     * performs an autonomous commit.
     * @param p_chart_id Foreign key to qa_chart_headers.chart_id
     * @param p_sql A SQL string
     * @param p_row_limit No. of rows to fetch (default to all)
     * @param x_row_count Return the no. of data rows created
     * @rep:displayname Create generic chart data from a SQL and commit autonomously
     */
    PROCEDURE populate_data_autonomous(
        p_chart_id     NUMBER,
        p_sql          VARCHAR2,
        p_row_limit    NUMBER DEFAULT NULL,
        x_row_count    OUT NOCOPY NUMBER);


    /*#
     * This procedure deletes chart details from qa_chart_generic.
     * @param p_chart_id Chart ID whose data are to be deleted
     * @rep:displayname Delete chart details
     */
    PROCEDURE delete_data(p_chart_id NUMBER);


    /*#
     * This procedure deletes chart details from qa_chart_generic
     * and performs an autonomous commit.
     * @param p_chart_id Chart ID whose data are to be deleted
     * @rep:displayname Delete chart details and commit autonomously
     */
    PROCEDURE delete_data_autonomous(p_chart_id NUMBER);


END qa_chart_generic_pkg;

 

/
