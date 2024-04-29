--------------------------------------------------------
--  DDL for Package JTF_TASK_CUSTOM_COLORS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_CUSTOM_COLORS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkfs.pls 115.5 2002/12/06 20:47:40 cjang ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|      jtfptkfs.pls                                                     |
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
| 31-Oct-2002 cjang            Added get_task_bgcolors()                |
|                              Added parameters for the new column      |
|                                     background_col_dec.               |
|                              Defined taskcolor_tbl and                |
|                              Changed the parameter on get_task_bgcolors
|                                  to the type of get_task_bgcolors     |
| 06-Nov-2002 cjang            Removed task_assignment_id from taskcolor_rec
| 06-Dec-2002 Chan-Ik Jang     Fixed Bug 2696521:                       |
|                                  Added get_task_dec_bgcolor()         |
*=======================================================================*/

    ----------------------------------------------------------------
    -- PL/SQL Table of record to contain the color setup data
    ----------------------------------------------------------------
    TYPE custom_color_rec IS RECORD (
        task_type_id            NUMBER,
        task_priority_id        NUMBER,
        assignment_status_id    NUMBER,
        escalated_task          VARCHAR2(1),
        background_col_dec      NUMBER,
        background_col_rgb      VARCHAR2(12)
    );
    TYPE custom_color_tbl IS TABLE OF custom_color_rec INDEX BY BINARY_INTEGER;

    g_custom_color_tbl custom_color_tbl;

    ----------------------------------------------------------------
    -- PL/SQL Table of record to contain the combination of task_id
    -- and task_assignment_id with the colors
    ----------------------------------------------------------------
    TYPE taskcolor_rec IS RECORD (
        task_id                 NUMBER,
        task_type_id            NUMBER,
        task_priority_id        NUMBER,
        assignment_status_id    NUMBER,
        background_col_dec      NUMBER,
        background_col_rgb      VARCHAR2(12)
    );
    TYPE taskcolor_tbl IS TABLE OF taskcolor_rec INDEX BY BINARY_INTEGER;

    ----------------------------------------------------------------
    -- FUNCTION GET_TASK_RGB_BGCOLOR:
    ----------------------------------------------------------------
    --   This procedure returns the background color for rgb
    --
    -- PARAMETERS:
    --   p_task_id              : used to check whether it has an escalation.
    --   p_task_type_id         : used to match the coloring rule.
    --   p_task_priority_id     : used to match the coloring rule.
    --   p_assignment_status_id : used to match the coloring rule.
    ----------------------------------------------------------------
    FUNCTION get_task_rgb_bgcolor(p_task_id IN NUMBER
                                 ,p_task_type_id IN NUMBER
                                 ,p_task_priority_id IN NUMBER
                                 ,p_assignment_status_id IN NUMBER
    )
    RETURN VARCHAR2;

    ----------------------------------------------------------------
    -- FUNCTION GET_TASK_DEC_BGCOLOR:
    ----------------------------------------------------------------
    --   This procedure returns the background color as decimal
    --
    -- PARAMETERS:
    --   p_task_id              : used to check whether it has an escalation.
    --   p_task_type_id         : used to match the coloring rule.
    --   p_task_priority_id     : used to match the coloring rule.
    --   p_assignment_status_id : used to match the coloring rule.
    ----------------------------------------------------------------
    FUNCTION get_task_dec_bgcolor(p_task_id IN NUMBER
                                 ,p_task_type_id IN NUMBER
                                 ,p_task_priority_id IN NUMBER
                                 ,p_assignment_status_id IN NUMBER
    )
    RETURN NUMBER;

    ----------------------------------------------------------------
    -- PROCEDURE GET_TASK_BGCOLORS:
    --   This procedure returns the background color
    --   for decimal and rgb.
    ----------------------------------------------------------------
    PROCEDURE get_task_bgcolors(p_taskcolor_tbl IN OUT NOCOPY taskcolor_tbl);

END JTF_TASK_CUSTOM_COLORS_PUB;

 

/
