--------------------------------------------------------
--  DDL for Package Body JTA_SYNC_TASK_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_SYNC_TASK_UTL" AS
/* $Header: jtavstnb.pls 120.2 2006/02/10 02:48:13 sbarat ship $ */
/*=======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA |
|                            All rights reserved.                        |
+========================================================================+
| FILENAME
|  jtavstnb.pls
|
| DESCRIPTION
|  This package defines the utility commonly used for sync.
|
| NOTES
|
| UPDATE NOTES
| Date          Developer                Change
|------------   ---------------     -------------------------------------
| 28-May-2002   Chanik Jang         Created.
| 10-Feb-2006   Swapan Barat        Added NOCOPY hint for OUT parameter. Bug# 5029957
|                                   (Using dual check-in option to check-in file so that the
|                                   code can be propagated in both ver 11 and 12 line, since
|                                   NOCOPY is a mandatory mandate for all pl/sql packages.)
*=======================================================================*/

    FUNCTION is_this_first_task(p_task_id IN NUMBER)
    RETURN BOOLEAN
    IS
        CURSOR c_first_taskid (b_task_id NUMBER) IS
        SELECT min(task_id) task_id
          FROM jtf_tasks_b
         WHERE NVL(deleted_flag,'N') = 'N'
           AND recurrence_rule_id = (SELECT recurrence_rule_id
                                       FROM jtf_tasks_b
                                      WHERE task_id = b_task_id);

        rec_first_taskid  c_first_taskid%ROWTYPE;
        l_result          BOOLEAN := FALSE;
    BEGIN
        OPEN c_first_taskid(b_task_id => p_task_id);
        FETCH c_first_taskid INTO rec_first_taskid;
        IF c_first_taskid%FOUND
        THEN
            IF p_task_id = rec_first_taskid.task_id
            THEN
                l_result := TRUE;
            END IF;
        END IF;
        CLOSE c_first_taskid;

        RETURN l_result;
    END is_this_first_task;

    FUNCTION get_new_first_taskid(p_calendar_start_date IN DATE,
                                  p_recurrence_rule_id  IN NUMBER)
    RETURN NUMBER
    IS
        CURSOR c_task (b_start_date DATE, b_recurrence_rule_id NUMBER) IS
        SELECT task_id
          FROM jtf_tasks_b
         WHERE calendar_start_date > b_start_date
           AND recurrence_rule_id = b_recurrence_rule_id
           AND NVL(deleted_flag,'N') = 'N'
        HAVING ROWNUM = 1
        GROUP BY ROWNUM, task_id, calendar_start_date
        ORDER BY calendar_start_date;

        l_task_id NUMBER;
    BEGIN
        OPEN c_task(p_calendar_start_date, p_recurrence_rule_id);
        FETCH c_task INTO l_task_id;
        IF c_task%NOTFOUND
        THEN
            l_task_id := 0;
        END IF;
        CLOSE c_task;

        RETURN l_task_id;
    END get_new_first_taskid;

    FUNCTION exist_syncid(p_task_id  IN         NUMBER,
                          x_sync_id  OUT NOCOPY NUMBER)
    RETURN BOOLEAN
    IS
        CURSOR c_sync (b_task_id NUMBER) IS
        SELECT task_sync_id
          FROM jta_sync_task_mapping
         WHERE task_id = b_task_id;

        l_result  BOOLEAN := FALSE;
    BEGIN
        OPEN c_sync (p_task_id);
        FETCH c_sync INTO x_sync_id;
        ----------------------------------------------------------------------
        -- If it's already been sycned,
        -- then we must update the mapping table with the new minimum task id
        ----------------------------------------------------------------------
        IF c_sync%FOUND
        THEN
            l_result := TRUE;
        END IF;
        CLOSE c_sync;

        RETURN l_result;
    END exist_syncid;

    PROCEDURE update_mapping(p_task_id IN NUMBER)
    IS
        CURSOR c_assignee (b_task_id NUMBER) IS
        SELECT jtaa.resource_id
             , jtb.calendar_start_date
             , jtb.recurrence_rule_id
          FROM jtf_task_all_assignments jtaa
             , jtf_tasks_b jtb
         WHERE jtaa.task_id = b_task_id
           AND jtb.task_id = jtaa.task_id;

        l_sync_id NUMBER;
        l_first BOOLEAN := FALSE;
        l_exist_new_first_task BOOLEAN := FALSE;
        l_new_minimum_task_id NUMBER;
    BEGIN
        l_first := is_this_first_task(p_task_id => p_task_id);

        FOR rec_assignee IN c_assignee(p_task_id)
        LOOP
            l_new_minimum_task_id := get_new_first_taskid(
                                        p_calendar_start_date => rec_assignee.calendar_start_date,
                                        p_recurrence_rule_id  => rec_assignee.recurrence_rule_id
                                     );
            IF l_new_minimum_task_id > 0
            THEN
                l_exist_new_first_task := TRUE;
            END IF;

            IF l_first and l_exist_new_first_task
            THEN
                IF exist_syncid(p_task_id => p_task_id,
                                x_sync_id => l_sync_id)
                THEN
                    jta_sync_task_map_pkg.update_row (
                        p_task_sync_id => l_sync_id,
                        p_task_id      => l_new_minimum_task_id,
                        p_resource_id  => rec_assignee.resource_id
                    );
                END IF;
            END IF;
        END LOOP;

    END update_mapping;

END jta_sync_task_utl;

/
