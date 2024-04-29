--------------------------------------------------------
--  DDL for Package Body JTF_TASK_CUSTOM_COLORS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_CUSTOM_COLORS_PUB" AS
/* $Header: jtfptkfb.pls 115.5 2002/12/06 20:47:34 cjang ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|      jtfptkfb.pls                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|      This package is used to get the color for a task.                |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
| Date        Developer        Change                                   |
| ----------- ---------------  ---------------------------------------  |
| 22-Oct-2002 cjang            Created.                                 |
| 30-Oct-2002 cjang            Modified escalated_task():               |
|                               Changed the cursor c_reference          |
|                                  from IN ('L1', 'L2', 'L3')           |
|                                    to NOT IN ('DE', 'NE')             |
| 31-Oct-2002 cjang            Added get_task_bgcolors()                |
|                              Added parameters for the new column      |
|                                     background_col_dec.               |
|                              Defined taskcolor_tbl and                |
|                              Changed the parameter on get_task_bgcolors
|                                  to the type of get_task_bgcolors     |
| 03-Dec-2002   Sanjeev K          BUG 2667735: Added NOCOPY option     |
| 06-Dec-2002   Chan-Ik Jang   Fixed Bug 2696521:                       |
|                                  Added get_task_dec_bgcolor()         |
*=======================================================================*/

    PROCEDURE get_custom_color
    IS
        CURSOR c_custom_color IS
        SELECT type_id
             , priority_id
             , assignment_status_id
             , escalated_task
             , background_col_dec
             , background_col_rgb
          FROM jtf_task_custom_colors
         WHERE active_flag = 'Y'
         ORDER BY color_determination_priority;
        i BINARY_INTEGER := 0;
    BEGIN
        IF g_custom_color_tbl.COUNT = 0
        THEN
            FOR rec IN c_custom_color
            LOOP
                i := i + 1;
                g_custom_color_tbl(i).task_type_id         := rec.type_id;
                g_custom_color_tbl(i).task_priority_id     := rec.priority_id;
                g_custom_color_tbl(i).assignment_status_id := rec.assignment_status_id;
                g_custom_color_tbl(i).escalated_task       := rec.escalated_task;
                g_custom_color_tbl(i).background_col_dec   := rec.background_col_dec;
                g_custom_color_tbl(i).background_col_rgb   := rec.background_col_rgb;
            END LOOP;
        END IF;
    END get_custom_color;

    FUNCTION escalated_task (p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_reference (b_task_id NUMBER)
        IS
        SELECT 'Y'
          FROM jtf_tasks_b esc
             , jtf_task_references_b r
             , jtf_task_statuses_b s
         WHERE r.object_id = b_task_id
           AND r.reference_code = 'ESC'
           AND r.object_type_code = 'TASK'
           AND esc.task_id = r.task_id
           AND esc.task_type_id = 22
           AND esc.escalation_level NOT IN ('DE', 'NE')
           AND NVL(esc.deleted_flag, 'N') <> 'Y'
           AND s.task_status_id = esc.task_status_id
           AND NVL(s.closed_flag, 'N') <> 'Y';

        l_escalated_task VARCHAR2(1);
    BEGIN
        OPEN c_reference (p_task_id);
        FETCH c_reference INTO l_escalated_task;

        IF c_reference%NOTFOUND
        THEN
            l_escalated_task := 'N';
        END IF;
        CLOSE c_reference;

        RETURN l_escalated_task;
    END escalated_task;

    FUNCTION do_match (
        p_task_type_id           IN NUMBER
       ,p_task_priority_id       IN NUMBER
       ,p_assignment_status_id   IN NUMBER
       ,p_escalated_task         IN VARCHAR2
       ,x_index                 OUT NOCOPY NUMBER
    )
    RETURN BOOLEAN
    IS
    BEGIN
        FOR i IN g_custom_color_tbl.FIRST..g_custom_color_tbl.LAST
        LOOP
            IF NVL(g_custom_color_tbl(i).task_type_id, p_task_type_id) = p_task_type_id AND
               NVL(g_custom_color_tbl(i).task_priority_id, p_task_priority_id) = p_task_priority_id AND
               NVL(g_custom_color_tbl(i).assignment_status_id,p_assignment_status_id) = p_assignment_status_id AND
               NVL(g_custom_color_tbl(i).escalated_task, p_escalated_task) = p_escalated_task
            THEN
                x_index := i;
                RETURN TRUE;
            END IF;
        END LOOP;

        RETURN FALSE;
    END do_match;

    FUNCTION get_task_rgb_bgcolor(p_task_id IN NUMBER
                                 ,p_task_type_id IN NUMBER
                                 ,p_task_priority_id IN NUMBER
                                 ,p_assignment_status_id IN NUMBER
    )
    RETURN VARCHAR2
    IS
        l_index NUMBER;
        l_matched BOOLEAN;
    BEGIN
        get_custom_color;

        IF g_custom_color_tbl.COUNT = 0
        THEN
            RETURN NULL;
        END IF;

        l_matched := do_match (
                        p_task_type_id         => p_task_type_id
                       ,p_task_priority_id     => NVL(p_task_priority_id,-9)
                       ,p_assignment_status_id => p_assignment_status_id
                       ,p_escalated_task       => escalated_task(p_task_id)
                       ,x_index                => l_index
                     );
        IF l_matched
        THEN
            RETURN g_custom_color_tbl(l_index).background_col_rgb;
        ELSE
            RETURN NULL;
        END IF;
    END get_task_rgb_bgcolor;

    FUNCTION get_task_dec_bgcolor(p_task_id IN NUMBER
                                 ,p_task_type_id IN NUMBER
                                 ,p_task_priority_id IN NUMBER
                                 ,p_assignment_status_id IN NUMBER
    )
    RETURN NUMBER
    IS
        l_index NUMBER;
        l_matched BOOLEAN;
    BEGIN
        get_custom_color;

        IF g_custom_color_tbl.COUNT = 0
        THEN
            RETURN NULL;
        END IF;

        l_matched := do_match (
                        p_task_type_id         => p_task_type_id
                       ,p_task_priority_id     => NVL(p_task_priority_id,-9)
                       ,p_assignment_status_id => p_assignment_status_id
                       ,p_escalated_task       => escalated_task(p_task_id)
                       ,x_index                => l_index
                     );
        IF l_matched
        THEN
            RETURN g_custom_color_tbl(l_index).background_col_dec;
        ELSE
            RETURN NULL;
        END IF;
    END get_task_dec_bgcolor;

    PROCEDURE get_task_bgcolors(p_taskcolor_tbl IN OUT NOCOPY taskcolor_tbl)
    IS
        l_index NUMBER;
        l_matched BOOLEAN;
    BEGIN
        get_custom_color;

        IF g_custom_color_tbl.COUNT = 0 OR
           p_taskcolor_tbl.COUNT = 0
        THEN
            RETURN;
        END IF;

        FOR i IN p_taskcolor_tbl.FIRST..p_taskcolor_tbl.LAST
        LOOP
            l_matched := do_match (
                            p_task_type_id         => p_taskcolor_tbl(i).task_type_id
                           ,p_task_priority_id     => NVL(p_taskcolor_tbl(i).task_priority_id,-9)
                           ,p_assignment_status_id => p_taskcolor_tbl(i).assignment_status_id
                           ,p_escalated_task       => escalated_task(p_taskcolor_tbl(i).task_id)
                           ,x_index                => l_index
                         );
            IF l_matched
            THEN
                p_taskcolor_tbl(i).background_col_dec := g_custom_color_tbl(l_index).background_col_dec;
                p_taskcolor_tbl(i).background_col_rgb := g_custom_color_tbl(l_index).background_col_rgb;
            END IF;
        END LOOP;
    END get_task_bgcolors;

END JTF_TASK_CUSTOM_COLORS_PUB;

/
