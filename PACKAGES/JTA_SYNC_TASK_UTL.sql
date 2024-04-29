--------------------------------------------------------
--  DDL for Package JTA_SYNC_TASK_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_SYNC_TASK_UTL" AUTHID CURRENT_USER AS
/* $Header: jtavstns.pls 120.2 2006/02/10 02:47:25 sbarat ship $ */
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
| 10-Feb-2006   Swapan Barat        Added NOCOPY hint for OUT parameter.. Bug# 5029957
|                                   (Using dual check-in option to check-in file so that the
|                                   code can be propagated in both ver 11 and 12 line, since
|                                   NOCOPY is a mandatory mandate for all pl/sql packages.)
*=======================================================================*/

    FUNCTION is_this_first_task(p_task_id IN NUMBER)
    RETURN BOOLEAN;

    FUNCTION get_new_first_taskid(p_calendar_start_date IN DATE,
                                  p_recurrence_rule_id  IN NUMBER)
    RETURN NUMBER;

    FUNCTION exist_syncid(p_task_id  IN         NUMBER,
                          x_sync_id  OUT NOCOPY NUMBER)
    RETURN BOOLEAN;

    PROCEDURE update_mapping(p_task_id IN NUMBER);

END jta_sync_task_utl;

 

/
