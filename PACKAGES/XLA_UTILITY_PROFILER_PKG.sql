--------------------------------------------------------
--  DDL for Package XLA_UTILITY_PROFILER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_UTILITY_PROFILER_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmupr.pkh 120.1 2003/02/22 19:01:34 svjoshi ship $ */
/*======================================================================+
|             Copyright (c) 2000-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_utility_profiler_pkg                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Utility profiler_Package                                       |
|                                                                       |
|    Debug/Profiler activities.                                         |
|                                                                       |
| HISTORY                                                               |
|    12-Jan-00 P. Labrevois    Created                                  |
|    08-Feb-01                 Created for XLA                          |
+=======================================================================*/


/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| Profiler                                                              |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| start_profiler                                                        |
|                                                                       |
| Activate the profiler.                                                |
|                                                                       |
+======================================================================*/
PROCEDURE start_profiler;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Stop_profiler                                                         |
|                                                                       |
| Unactivate the profiler.                                              |
|                                                                       |
+======================================================================*/
PROCEDURE stop_profiler;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| dump_profiler_data                                                    |
|                                                                       |
| Print the information from the profiler                               |
|                                                                       |
+======================================================================*/
PROCEDURE  dump_profiler_data;

END xla_utility_profiler_pkg;
 

/
