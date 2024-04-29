--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_UTIL_PUB" as
/* $Header: cacputlb.pls 115.1 2004/05/10 22:59:34 cijang noship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|      cacputlb.pls                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|      This package is view public utility for calendar view.           |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
| Date         Developer        Change                                  |
| -----------  ---------------  --------------------------------------- |
| 06-May-2004  Chan-Ik Jang     Created                                 |
*=======================================================================*/

    /* -----------------------------------------------------------------
     * -- Function Name: get_attendees
     * -- Description  : This function returns the list of attendees.
     * --                The attendee names are concatenated as a string.
     * -- Parameter    : p_task_id = Task Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_attendees(p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
    BEGIN
        RETURN get_attendees(p_task_id);
    END get_attendees;

    /* -----------------------------------------------------------------
     * -- Function Name: get_related_items
     * -- Description  : This function returns the concatednated information
     * --                of items related to the given task id.
     * -- Parameter    : p_task_id  = Task Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_related_items (p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
    BEGIN
        RETURN CAC_VIEW_ACC_DAILY_VIEW_PVT.get_related_items(p_task_id);
    EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
    END get_related_items;

    /* -----------------------------------------------------------------
     * -- Function Name: get_locations
     * -- Description  : This function returns the concatednated information
     * --                of location related to the given task id.
     * -- Parameter    : p_task_id  = Task Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_locations(p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
    BEGIN
        RETURN CAC_VIEW_PVT.get_locations(p_task_id);
    EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
    END get_locations;

END CAC_VIEW_UTIL_PUB;

/
