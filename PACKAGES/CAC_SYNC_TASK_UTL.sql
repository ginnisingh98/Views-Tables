--------------------------------------------------------
--  DDL for Package CAC_SYNC_TASK_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_TASK_UTL" AUTHID CURRENT_USER AS
/* $Header: cacvstns.pls 120.1 2005/06/10 20:22:52 rhshriva noship $ */
/*=======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA |
|                            All rights reserved.                        |
+========================================================================+
| FILENAME
|  jtavstns.pls
|
| DESCRIPTION
|  This package spec defines the utility commonly used for sync.
|
| NOTES
|
| UPDATE NOTES
| Date          Developer                Change
|------------   ---------------     -------------------------------------
| 28-May-2002   Chanik Jang         Created.
*=======================================================================*/

    FUNCTION is_this_first_task(p_task_id IN NUMBER)
    RETURN BOOLEAN;

    FUNCTION get_new_first_taskid(p_calendar_start_date IN DATE,
                                  p_recurrence_rule_id  IN NUMBER)
    RETURN NUMBER;

    FUNCTION exist_syncid(p_task_id  IN NUMBER,
                          x_sync_id OUT NOCOPY NUMBER,
                          x_principal_id OUT NOCOPY NUMBER)

   RETURN BOOLEAN;


    PROCEDURE update_mapping(p_task_id IN NUMBER);

END cac_sync_task_utl;

 

/
