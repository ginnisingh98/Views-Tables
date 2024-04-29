--------------------------------------------------------
--  DDL for Package XLA_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmutl.pkh 120.5 2005/10/22 00:05:37 awan ship $ */
/*======================================================================+
|             Copyright (c) 2000-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_utility_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Utility Package                                                |
|                                                                       |
|    This package provides wrapper for debugging/benchmark/testing      |
|    facilities.                                                        |
|                                                                       |
|    A] Trace/Debugging facilities.                                     |
|                                                                       |
|       The output debug messages are either:                           |
|          - printed on the standard OUTPUT,                            |
|          - sent to another SRS process waiting for a pipe,            |
|          - written to the current logfile through fnd_file            |
|          - written in an HTML page                                    |
|          - written in a flat file                                     |
|                                                                       |
|       Usage from SRS|Forms4.5+:                                       |
|          Setting up profile options:                                  |
|             xla_debug_mode               (Yes/No)                     |
|             xla_debug_level              (1..100)                     |
|             xla_debug_timeout in seconds (1..n)                       |
|                                                                       |
|       Usage from SQL*Plus:                                            |
|          BEGIN                                                        |
|          xla_utility_pkg.init_trace('OUTPUT|FILE',location);          |
|          <PL/SQL source>(...);                                        |
|          xla_utility_pkg.trace_off('OUTPUT|FILE',location);           |
|          END;                                                         |
|                                                                       |
|       PL/SQL coding standard:                                         |
|          BEGIN                                                        |
|          xla_utility_pkg.init_trace(mode,location)                    |
|          .../...                                                      |
|          xla_utility_pkg.trace('String',trace_level);                 |
|          xla_utility_pkg.trace('String',trace_level);                 |
|          .../...                                                      |
|          xla_utility_pkg.trace_off(location);                         |
|          END;                                                         |
|                                                                       |
|                                                                       |
|    B] SRS Output and logfile facilities                               |
|                                                                       |
|       Example of calls:                                               |
|          BEGIN                                                        |
|          .../...                                                      |
|          xla_utility_pkg.print_outputfile(msg);                       |
|          xla_utility_pkg.print_logfile(msg);                          |
|          .../...                                                      |
|          END;                                                         |
|                                                                       |
|                                                                       |
|    C] Statistics                                                      |
|                                                                       |
|       Example of calls:                                               |
|          BEGIN                                                        |
|          xla_utility_pkg.init_stat;                                   |
|          <PL/SQL source>(...);                                        |
|          xla_utility_pkg.stat_off;                                    |
|          END;                                                         |
|                                                                       |
|                                                                       |
|    D] SQL Trace facilities                                            |
|                                                                       |
|       Example of calls:                                               |
|          BEGIN                                                        |
|          .../...                                                      |
|          xla_utility_pkg.init_sqltrace;                               |
|          .../...                                                      |
|          xla_utility_pkg.sqltrace_off;                                |
|          .../...                                                      |
|          END;                                                         |
|                                                                       |
|                                                                       |
|                                                                       |
| WARNING                                                               |
|    Procedure init_trace performs a commit in SRS_DBP mode             |
|                                                                       |
| HISTORY                                                               |
|    07-Dec-95 P. Labrevois    Created                                  |
|    08-Feb-01                 Created for XLA                          |
|    22-Mar-01                 Added Trace level                        |
|    08-May-01                 Added get_session_info                   |
|    20-Sep-01                 Added dbms_trace                         |
|    20-Oct-05 A.Wan 4693865   ATG Profile Options                      |
+=======================================================================*/

g_unique_location                 VARCHAR2(2000)        := NULL;

g_debug                           BOOLEAN               := FALSE;
g_trace                           VARCHAR2(1);
g_stat                            VARCHAR2(1);

--
-- Debug level (0 min - 100 max)
--
g_trace_level                     INTEGER;
g_profiler                        VARCHAR2(1);
g_dbms_trace                      VARCHAR2(1);


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
| Activation/Deactivation                                               |
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
| Public Procedure                                                      |
|                                                                       |
| Activate                                                              |
|                                                                       |
| Activate the XLA Debug mode.                                          |
|                                                                       |
+======================================================================*/
PROCEDURE Activate
  (p_debug_mode                   IN  VARCHAR2
  ,p_Location                     IN  VARCHAR2);


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| deactivate                                                            |
|                                                                       |
| De-Activate, if set, the XLA debug mode.                              |
|                                                                       |
+======================================================================*/
PROCEDURE Deactivate
  (p_Location                     IN  VARCHAR2);


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_option                                                            |
|                                                                       |
| Set any option.                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE set_option
  (p_option                       IN  VARCHAR2
  ,p_option_value                 IN  VARCHAR2);


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_session_info                                                      |
|                                                                       |
| Return system informations about the current session.                 |
|                                                                       |
+======================================================================*/
FUNCTION  get_session_info
  (p_option                       IN  VARCHAR2)
RETURN VARCHAR2;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_option_value                                                      |
|                                                                       |
| Set any option.                                                       |
|                                                                       |
+======================================================================*/
FUNCTION  get_option_value
  (p_option                       IN  VARCHAR2)
RETURN VARCHAR2;



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
| Trace                                                                 |
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
| Public Procedure                                                      |
|                                                                       |
| Activate_trace                                                        |
|                                                                       |
| Activate the XLA Trace mode.                                          |
|                                                                       |
+======================================================================*/
PROCEDURE Activate_trace
  (p_debug_mode                   IN  VARCHAR2
  ,p_Location                     IN  VARCHAR2);


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| deactivate                                                            |
|                                                                       |
| De-Activate, if set, the XLA Trace.                                   |
|                                                                       |
+======================================================================*/
PROCEDURE Deactivate_trace
  (p_Location                     IN  VARCHAR2);


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_trace_on                                                          |
|                                                                       |
| Activate the XLA trace.                                               |
|                                                                       |
+======================================================================*/
PROCEDURE set_trace_on;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_trace_off                                                         |
|                                                                       |
| De-Activate, if set, the XLA Trace.                                   |
|                                                                       |
+======================================================================*/
PROCEDURE set_trace_off;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| trace                                                                 |
|                                                                       |
| Debugging. Msg will be printed in the std trace output if the level   |
| satifsy the context criteria.                                         |
|                                                                       |
+======================================================================*/
PROCEDURE trace
  (p_msg                          IN  VARCHAR2
  ,p_level                        IN  NUMBER  );


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| print_trace_info                                                      |
|                                                                       |
| Print all information related to the trace to the std Trace output.   |
|                                                                       |
+======================================================================*/
PROCEDURE print_trace_info;



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
| Print                                                                 |
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
| Public Procedure                                                      |
|                                                                       |
| print                                                                 |
|                                                                       |
| Debugging. Msg will be printed in the std debug output.               |
|                                                                       |
+======================================================================*/
PROCEDURE print
  (p_msg                          IN  VARCHAR2);


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
| SRS log and output files utilities                                    |
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
| Public Procedure                                                      |
|                                                                       |
| print_logfile                                                         |
|                                                                       |
| Print the messgage to the fnd output file                             |
|                                                                       |
+======================================================================*/
PROCEDURE print_outputfile
  (p_msg                          IN  VARCHAR2) ;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| print_logfile                                                         |
|                                                                       |
| Print the messgage to the fnd log file                                |
|                                                                       |
+======================================================================*/
PROCEDURE print_logfile
  (p_msg                          IN  VARCHAR2) ;


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
| Statistics                                                            |
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
| Public Procedure                                                      |
|                                                                       |
| Activate_stat                                                         |
|                                                                       |
| Activate the XLA Stat mode.                                           |
|                                                                       |
+======================================================================*/
PROCEDURE Activate_stat
  (p_debug_mode                   IN  VARCHAR2
  ,p_Location                     IN  VARCHAR2);


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| deactivate_stat                                                       |
|                                                                       |
| De-Activate, if set, the XLA Statistical mode                         |
|                                                                       |
+======================================================================*/
PROCEDURE Deactivate_stat
  (p_Location                     IN  VARCHAR2);


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_trace_on                                                          |
|                                                                       |
| Activate the XLA Statistics.                                          |
|                                                                       |
+======================================================================*/
PROCEDURE set_stat_on;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_trace_off                                                         |
|                                                                       |
| De-Activate, if set, the XLA Statistics.                              |
|                                                                       |
+======================================================================*/
PROCEDURE set_stat_off;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| print_stat_info                                                       |
|                                                                       |
| Print all information related to the stat to the std Trace output.    |
|                                                                       |
+======================================================================*/
PROCEDURE print_stat_info;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_stat_info                                                         |
|                                                                       |
| Return a statistic information                                        |
|                                                                       |
+======================================================================*/
FUNCTION  get_stat_info
  (p_option                       IN  VARCHAR2)
RETURN VARCHAR2;


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
| SQL_Trace                                                             |
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
| Public Procedure                                                      |
|                                                                       |
| set_sqltrace_on                                                       |
|                                                                       |
| Alter the session to start the sql trace mode.                        |
|                                                                       |
+======================================================================*/
PROCEDURE set_sqltrace_on;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_sqltrace_off                                                      |
|                                                                       |
| Alter the session to finish the sql trace mode.                       |
|                                                                       |
+======================================================================*/
PROCEDURE set_sqltrace_off;


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
| Reset                                                                 |
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
| Public Procedure                                                      |
|                                                                       |
| reset                                                                 |
|                                                                       |
| Reset the global variables.                                           |
|                                                                       |
+======================================================================*/
PROCEDURE reset;

END xla_utility_pkg;
 

/
