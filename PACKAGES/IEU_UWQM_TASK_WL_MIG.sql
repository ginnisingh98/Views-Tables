--------------------------------------------------------
--  DDL for Package IEU_UWQM_TASK_WL_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQM_TASK_WL_MIG" AUTHID CURRENT_USER AS
/* $Header: IEUVTKPS.pls 120.0 2005/06/02 16:01:19 appldev noship $ */

 TYPE l_priority_rec IS RECORD
 ( importance_level number := null,
   task_count       number := null);

 TYPE l_pty_list IS TABLE OF l_priority_rec INDEX BY BINARY_INTEGER;

 FUNCTION get_tasks_by_priority
 RETURN SYSTEM.IEU_UWQM_TASK_PRIORITY_NST;

end IEU_UWQM_TASK_WL_MIG;

 

/
