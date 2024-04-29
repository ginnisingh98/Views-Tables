--------------------------------------------------------
--  DDL for Package CAC_VIEW_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_VIEW_UTIL_PUB" AUTHID CURRENT_USER as
/* $Header: cacputls.pls 120.2 2006/06/30 10:40:43 sbarat noship $ */
/*#
 * This package is a public utility for Calendar views.
 * @rep:scope internal
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Public Calendar View Util
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_APPOINTMENT
 */

/**
 * This function returns the list of attendees.
 * The attendee names are delimited by comma.
 * @param p_task_id task id
 * @return The list of attendees
 * @rep:displayname Get Attendees
 * @rep:lifecycle active
 * @rep:compatibility S
 */
FUNCTION get_attendees(p_task_id IN NUMBER)
RETURN VARCHAR2;

/**
 * This function returns the concatednated information
 * of items related to the given task id.
 * @param p_task_id task id
 * @return The related items
 * @rep:displayname Get Related Items
 * @rep:lifecycle active
 * @rep:compatibility S
 */
FUNCTION get_related_items (p_task_id IN NUMBER)
RETURN VARCHAR2;

/**
 * This function returns the concatednated information
 * of location related to the given task id.
 * @param p_task_id task id
 * @return The location
 * @rep:displayname Get Locations
 * @rep:lifecycle active
 * @rep:compatibility S
 */
FUNCTION get_locations(p_task_id IN NUMBER)
RETURN VARCHAR2;

END CAC_VIEW_UTIL_PUB;

 

/
