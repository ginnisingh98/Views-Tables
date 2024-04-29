--------------------------------------------------------
--  DDL for Package QA_CHART_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CHART_HEADERS_PKG" AUTHID CURRENT_USER AS
/* $Header: qacharts.pls 120.1 2006/02/07 23:45:39 bso noship $ */
/*#
 * This package is currently a private API to interface with
 * Quality's Release 12 Charting Architecture.  It is used to
 * create and delete a chart instance (qa_chart_headers)
 * @rep:scope private
 * @rep:product QA
 * @rep:displayname Chart Headers API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY QA_RESULT
 */

    --
    -- Tracking Bug 4939897
    -- R12 Forms Tech Stack Upgrade - Obsolete Oracle Graphics
    --


    /*#
     * This procedure creates a generic chart instance header.
     * After calling this procedure, the user usually needs to populate
     * the chart details (data points) by calling qa_chart_generic_pkg.
     * Null is acceptable for all IN parameters.
     * @param p_criteria_id Foreign key to qa_criteria_headers.criteria_id
     * @param p_title Chart title to be displayed in the chart
     * @param p_description Chart description for information only
     * @param p_x_label X-axis label
     * @param p_y_label Y-axis label
     * @param x_chart_id Return a new chart instance header ID (from qa_chart_headers_s)
     * @rep:displayname Create a chart instance header
     */
    PROCEDURE create_chart(
        p_criteria_id  NUMBER,
        p_title        VARCHAR2,
        p_description  VARCHAR2,
        p_x_label      VARCHAR2,
        p_y_label      VARCHAR2,
        x_chart_id     OUT NOCOPY NUMBER);


    /*#
     * This procedure creates a generic chart instance header.
     * It is identical to create_chart except it performs
     * autonomous commit.
     * @param p_criteria_id Foreign key to qa_criteria_headers.criteria_id
     * @param p_title Chart title to be displayed in the chart
     * @param p_description Chart description for information only
     * @param p_x_label X-axis label
     * @param p_y_label Y-axis label
     * @param x_chart_id Return a new chart instance header ID (from qa_chart_headers_s)
     * @rep:displayname Create a chart instance header and commit autonomously
     */
    PROCEDURE create_chart_autonomous(
        p_criteria_id  NUMBER,
        p_title        VARCHAR2,
        p_description  VARCHAR2,
        p_x_label      VARCHAR2,
        p_y_label      VARCHAR2,
        x_chart_id     OUT NOCOPY NUMBER);


    /*#
     * This procedure deletes a chart (header and detail
     * data points will be deleted together).
     * @param p_chart_id Chart instance header ID to be deleted
     * @rep:displayname Delete a chart instance
     */
    PROCEDURE delete_chart(p_chart_id NUMBER);


    /*#
     * This procedure deletes a chart (header and detail
     * data points will be deleted together).  It performs
     * autonomous commit.
     * @param p_chart_id Chart instance header ID to be deleted
     * @rep:displayname Delete a chart instance and commit autonomously
     */
    PROCEDURE delete_chart_autonomous(p_chart_id NUMBER);


    /*#
     * This procedure sets the x-axis label of a chart.
     * @param p_chart_id Chart instance header ID to be modified
     * @param p_label New label
     * @rep:displayname Set the x-axis label
     */
    PROCEDURE set_x_label(p_chart_id NUMBER, p_label VARCHAR2);


    /*#
     * This procedure sets the y-axis label of a chart.
     * @param p_chart_id Chart instance header ID to be modified
     * @param p_label New label
     * @rep:displayname Set the y-axis label
     */
    PROCEDURE set_y_label(p_chart_id NUMBER, p_label VARCHAR2);


    /*#
     * This function returns a commonly used axis label.
     * Very often an axis label is either a collection element name
     * or "Function of element" if a function is specified by user.
     * @param p_element_id Collection element ID to be used in the axis
     * @param p_function_code Function used in axis if not null.
     * @rep:displayname Return a common axis label
     */
    FUNCTION get_function_axis_label(
        p_element_id NUMBER,
        p_function_code NUMBER) RETURN VARCHAR2;


END qa_chart_headers_pkg;

 

/
