--------------------------------------------------------
--  DDL for Package JTF_TASK_UWQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_UWQ_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkqs.pls 115.1 2002/06/06 17:25:47 pkm ship   $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|   jtfvtkqs.pls                                                        |
|                                                                       |
| DESCRIPTION                                                           |
|   This package is used by JTF_TASK_UWQ_MYOWN_V                        |
|                                                                       |
| Date          Developer    Change                                     |
| -----------   -----------  ---------------------------------------    |
| 10-Apr-2002   cjang        Created                                    |
*=======================================================================*/
    FUNCTION get_primary_phone (p_task_id IN NUMBER)
    RETURN VARCHAR2;

    FUNCTION get_primary_email (p_task_id IN NUMBER)
    RETURN VARCHAR2;

END jtf_task_uwq_pvt;

 

/
