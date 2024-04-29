--------------------------------------------------------
--  DDL for Package Body XLA_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_UTILITY_PKG" AS
/* $Header: xlacmutl.pkb 120.11 2005/10/22 00:06:21 awan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_utility_pkg                                                    |
|                                                                       |
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
|             xla_debug_trace_mode         (Yes/No)                     |
|             xla_debug_trace_level        (1..100)                     |
|             xla_debug_timeout in seconds (1..n)                       |
|                                                                       |
|       Usage from SQL*Plus:                                            |
|          BEGIN                                                        |
|          xla_utility_pkg.activate('OUTPUT|FILE',location);            |
|          <PL/SQL source>(...);                                        |
|          xla_utility_pkg.deactivate('OUTPUT|FILE',location);          |
|          END;                                                         |
|                                                                       |
|       PL/SQL coding standard:                                         |
|          BEGIN                                                        |
|          xla_utility_pkg.activate(mode,location)                      |
|          .../...                                                      |
|          xla_utility_pkg.trace('String',trace_level);                 |
|          xla_utility_pkg.trace('String',trace_level);                 |
|          .../...                                                      |
|          xla_utility_pkg.deactivate(location);                        |
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
|          xla_utility_pkg.activate_stat;                               |
|          <PL/SQL source>(...);                                        |
|          xla_utility_pkg.deactivate_stat;                             |
|          END;                                                         |
|                                                                       |
|                                                                       |
|    D] SQL Trace facilities                                            |
|                                                                       |
|       Example of calls:                                               |
|          BEGIN                                                        |
|          .../...                                                      |
|          xla_utility_pkg.set_sqltrace_on;                             |
|          .../...                                                      |
|          xla_utility_pkg.set_sqltrace_off;                            |
|          .../...                                                      |
|          END;                                                         |
|                                                                       |
| DEPENDENCIES                                                          |
|    dbms_pipe                                                          |
|    dbms_utility                                                       |
|    dbms_output                                                        |
|    dbms_session                                                       |
|    fnd_file                                                           |
|    fnd_log                                                            |
|    fnd_request                                                        |
|    fnd_global                                                         |
|                                                                       |
| HISTORY                                                               |
|    07-Dec-95 P. Labrevois    Created                                  |
|    08-Feb-01                 Created for XLA                          |
|    28-Mar-01                 Major review                             |
|    17-Apr-01                 Review stat handling                     |
|    08-May-01                 Added get_session_info                   |
|    20-Sep-01                 Integrated with dbms_trace               |
|    11-Apr-03 Shishir Joshi   Modified call to the raise_message.      |
|                              Added parameter name to the call.        |
|    20-Oct-05 A.Wan 4693865   ATG Profile Options                      |
|                              profiles obsoleted:                      |
|                                   XLA_DEBUG_DBMS_TRACE                |
|                                   XLA_DEBUG_DBMS_TRACE_LEVEL          |
|                                   XLA_DEBUG_DBMS_TRACE_MODE           |
|                                   XLA_DEBUG_KEEP_GOING                |
|                                   XLA_DEBUG_SYSSTAT                   |
|                              code removed:                            |
|                                   KEEP_GOING func and related code    |
|                                   print_sysstat_data function         |
|                                                                       |
|                                                                       |
+======================================================================*/

--
-- Constant default location
--
c_unknown_location             CONSTANT VARCHAR2(70)  := '_ UNKNOWN ORIGIN _';

--
-- Mode available
--
c_mode_tracer                  CONSTANT VARCHAR2(50)  := 'TRACER';
c_mode_stracer                 CONSTANT VARCHAR2(50)  := 'STRACER';
c_mode_jtracer                 CONSTANT VARCHAR2(50)  := 'JTRACER';
c_mode_logfile                 CONSTANT VARCHAR2(50)  := 'LOGFILE';
c_mode_aflog                   CONSTANT VARCHAR2(50)  := 'AFLOG';
c_mode_file                    CONSTANT VARCHAR2(50)  := 'FILE';
c_mode_output                  CONSTANT VARCHAR2(50)  := 'OUTPUT';
c_mode_htm                     CONSTANT VARCHAR2(50)  := 'HTM';

--
-- Default options set through constants
--
c_dflt_trace_level             CONSTANT PLS_INTEGER   := 100;
c_dflt_profiler                CONSTANT VARCHAR2(1)   := 'N';
c_dflt_header                  CONSTANT VARCHAR2(1)   := 'Y';
c_dflt_footer                  CONSTANT VARCHAR2(1)   := 'Y';
c_dflt_trace_datetime          CONSTANT VARCHAR2(1)   := 'N';
c_dflt_sqltrace                CONSTANT VARCHAR2(1)   := 'N';
c_dflt_file_flush_option       CONSTANT VARCHAR2(1)   := 'N';
c_dflt_file_override_directory CONSTANT VARCHAR2(2000):= NULL;
c_dflt_file_override_filename  CONSTANT VARCHAR2(240) := NULL;
c_dflt_trace                   CONSTANT VARCHAR2(1)   := 'N';
c_dflt_srs_mode                CONSTANT VARCHAR2(30)  := c_mode_tracer;
c_dflt_of_mode                 CONSTANT VARCHAR2(30)  := c_mode_file;
c_dflt_timeout                 CONSTANT PLS_INTEGER   := 600;
c_dflt_srs_output_enable       CONSTANT VARCHAR2(1)   := 'Y';

--
-- Constants for tracer mode
--
c_pipe_name_suffix             CONSTANT VARCHAR2(50)  := '_TRC';
c_pipe_buffer_size             CONSTANT PLS_INTEGER   := 65536;
c_cp_appli                     CONSTANT VARCHAR2(50)  := 'XLA';
c_cp_tracer                    CONSTANT VARCHAR2(50)  := 'XLAMTR';
c_cp_stracer                   CONSTANT VARCHAR2(50)  := 'XLAMTS';
c_cp_jtracer                   CONSTANT VARCHAR2(50)  := 'XLAMTJ';
c_max_msg_pipe                 CONSTANT PLS_INTEGER   := 1950;
c_max_msg_output               CONSTANT PLS_INTEGER   := 255;

--
-- Constants for file mode
--
c_file_prefix                  CONSTANT VARCHAR2(10)  := 'xla_';
c_file_suffix                  CONSTANT VARCHAR2(10)  := '.trc';

--
-- Constants for formatting
--
c_equal_position               PLS_INTEGER     := 40;
c_equal_symbol                 VARCHAR2(1);

--
-- Default value options
--
g_dflt_trace_level             PLS_INTEGER;
g_dflt_profiler                VARCHAR2(1);
g_dflt_header                  VARCHAR2(1);
g_dflt_footer                  VARCHAR2(1);
g_dflt_trace_datetime          VARCHAR2(1);
g_dflt_sqltrace                VARCHAR2(1);
g_dflt_file_flush_option       VARCHAR2(1);
g_dflt_file_override_directory VARCHAR2(2000);
g_dflt_file_override_filename  VARCHAR2(240);
g_dflt_trace                   VARCHAR2(1);
g_dflt_srs_mode                VARCHAR2(30);
g_dflt_of_mode                 VARCHAR2(30);
g_dflt_timeout                 INTEGER;
g_dflt_srs_output_enable       VARCHAR2(1);

--
-- Generic global variables
--
g_trace_datetime               VARCHAR2(1);
g_header                       VARCHAR2(1);
g_footer                       VARCHAR2(1);
g_sqltrace                     VARCHAR2(1);
g_file_flush_option            VARCHAR2(1);
g_file_override_directory      VARCHAR2(2000);
g_file_override_filename       VARCHAR2(240);
g_srs_mode                     VARCHAR2(30);
g_of_mode                      VARCHAR2(30);
g_timeout                      INTEGER;
g_srs_output_enable            VARCHAR2(1);
g_debug_mode                   VARCHAR2(20)          := NULL;   -- Debug mode requested
g_mode                         VARCHAR2(30);                    -- Actual debug mode
g_location                     VARCHAR2(255)         := NULL;
g_RequestId                    NUMBER                := NULL;   -- Last request that submitted trace

--
-- Tracer mode specific global variables
--
g_pipe_name                    VARCHAR2(100);
g_pipename_increment           PLS_INTEGER           := 0;
g_trace_reqid                  NUMBER;                          -- Tracer request id

--
-- File mode specific global variables
--
g_file_handler                 utl_file.file_type;
g_file_directory               VARCHAR2(2000);
g_file_name                    VARCHAR2(240);

--
-- File mode specific global variables
--
g_format                       VARCHAR2(1);


g_stat_datetime_start          PLS_INTEGER;
g_stat_datetime_stop           PLS_INTEGER;



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
| Options Functions                                                     |
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
| set_default_options                                                   |
|                                                                       |
| Set the default option. This procedure is called when the package is  |
| instanciated.                                                         |
|                                                                       |
+======================================================================*/
PROCEDURE set_default_options
IS
BEGIN
g_dflt_trace_level             := c_dflt_trace_level;
g_dflt_profiler                := c_dflt_profiler;
g_dflt_header                  := c_dflt_header;
g_dflt_footer                  := c_dflt_footer;
g_dflt_trace_datetime          := c_dflt_trace_datetime;
g_dflt_sqltrace                := c_dflt_sqltrace;
g_dflt_file_flush_option       := c_dflt_file_flush_option;
g_dflt_file_override_directory := c_dflt_file_override_directory;
g_dflt_file_override_filename  := c_dflt_file_override_filename;
g_dflt_trace                   := c_dflt_trace;
g_dflt_srs_mode                := c_dflt_srs_mode;
g_dflt_of_mode                 := c_dflt_of_mode;
g_dflt_timeout                 := c_dflt_timeout;
g_dflt_srs_output_enable       := c_dflt_srs_output_enable;
END set_default_options;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| set_options                                                           |
|                                                                       |
| Keep the options set in global variables.                             |
|                                                                       |
+======================================================================*/
PROCEDURE set_options
IS
BEGIN
--
-- Profile options value take precedance over default values
--
g_trace_level      := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_TRACE_LEVEL')      , g_dflt_trace_level);
g_profiler         := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_PROFILER')         , g_dflt_profiler);
g_trace_datetime   := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_TRACE_DATETIME')   , g_dflt_trace_datetime);
g_sqltrace         := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_SQLTRACE')         , g_dflt_sqltrace);
g_file_flush_option:= NVL(xla_profiles_pkg.get_value('XLA_DEBUG_FILE_FLUSH_OPTION'), g_dflt_file_flush_option);
g_file_override_directory
                   := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_FILE_OVERRIDE_DIRECTORY')
                                                                                   , g_dflt_file_override_directory);
g_file_override_filename
                   := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_FILE_OVERRIDE_FILENAME')
                                                                                   , g_dflt_file_override_filename);
g_trace            := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_TRACE')            , g_dflt_trace);
g_srs_mode         := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_SRS_MODE')         , g_dflt_srs_mode);
g_of_mode          := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_OF_MODE')          , g_dflt_of_mode);
g_timeout          := NVL(xla_profiles_pkg.get_value('XLA_DEBUG_TIMEOUT')          , g_dflt_timeout);
g_srs_output_enable:= NVL(xla_profiles_pkg.get_value('XLA_DEBUG_SRS_OUTPUT_ENABLE'), g_dflt_srs_output_enable);

--
-- Evaluate the status of the statistics from both the profiler and the system statistics
--
IF g_profiler = 'Y' THEN
   g_stat     := 'Y';
ELSE
   g_stat     := 'N';
END IF;

g_header   := g_dflt_header;
g_footer   := g_dflt_footer;

END set_options;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| reset_options                                                         |
|                                                                       |
| Reset all global variables to the default value. Reset as well global |
| variables not derived from profile options                            |
|                                                                       |
+======================================================================*/
PROCEDURE reset_options
IS
BEGIN
set_options;
g_RequestId         := NULL;
g_pipe_name         := NULL;
g_location          := NULL;
END reset_options;


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
| Private Print Functions                                               |
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
| open-srs_files                                                        |
|                                                                       |
| Open the temporary log and output files used by the FND concurrent    |
| processing.                                                           |
|                                                                       |
+======================================================================*/
PROCEDURE open_srs_files

IS

BEGIN
--
-- Print in the SRS output/logfile only if both the current context is inside
-- a concurrent request and this output is enabled.
--
IF g_requestid          NOT IN (0,-1)
AND g_srs_output_enable      = 'Y' THEN
   fnd_file.put_line(fnd_file.log   ,'');
   fnd_file.put_line(fnd_file.output,'');
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   g_srs_output_enable := 'N';
      RAISE;
WHEN OTHERS                                   THEN
   g_srs_output_enable := 'N';
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_utility_pkg.open_srs_files');
END open_srs_files;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| get_root_dir                                                          |
|                                                                       |
| Return the root directory                                             |
|                                                                       |
+======================================================================*/
FUNCTION  get_root_dir
  (p_path                         IN  VARCHAR2)
RETURN VARCHAR2

IS

BEGIN
IF INSTR(p_path,',',1) = 0 THEN
   IF INSTR(p_path,';',1) = 0 THEN
      RETURN SUBSTR(p_path , 1 ,LENGTH(p_path));
   ELSE
      RETURN SUBSTR(p_path , 1 ,INSTR(p_path,';',1)-1);
   END IF;
ELSE
   RETURN SUBSTR(p_path , 1 ,INSTR(p_path,',',1)-1);
END IF;

EXCEPTION
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_utility_pkg.get_root_dir');
END get_root_dir;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| open_file                                                             |
|                                                                       |
| Get a directory to be written                                         |
|                                                                       |
+======================================================================*/
PROCEDURE open_file

IS

l_parameter_value                 VARCHAR2(255);
l_dir                             VARCHAR2(255);
l_override_directory              VARCHAR2(2000);
l_override_filename               VARCHAR2(2000);

BEGIN

SELECT pa.value
INTO   l_parameter_value
FROM   v$parameter       pa
WHERE  pa.name   = 'utl_file_dir'
;


-- IF xla_utility_event_pkg.is_event_set('RAISE_UTL_FILE_OPEN_FAILURE') THEN
--    l_dir := '/dummy';
-- ELSE

--
-- Get the directory from the override directory if set
--
g_file_directory
   := NVL(g_file_override_directory,get_root_dir (l_parameter_value));

--
-- Get the filename from the override filename if set
--
g_file_name
   := NVL(g_file_override_filename
              ,c_file_prefix
           ||  xla_environment_pkg.g_process_id
           ||  '_'
           ||  xla_environment_pkg.g_session_id
           ||  c_file_suffix);

---
--- The file mode must be opened in 'w' mode in 7.3, otherwise in 'a' mode
---
BEGIN
g_file_handler := utl_file.fopen(g_file_directory, g_file_name          ,'a');

EXCEPTION
WHEN utl_file.invalid_mode                   THEN
   g_file_handler := utl_file.fopen(g_file_directory, g_file_name          ,'w');
END;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   g_trace := 'N';
   RAISE;
WHEN utl_file.invalid_path                   THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_PATH'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_mode                   THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_MODE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_filehandle             THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_HANDLE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_operation              THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_OPE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.write_error                     THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_WRITE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.internal_error                 THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_ERROR'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_utility_pkg.open_file');
END open_file;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| close_file                                                            |
|                                                                       |
| Get a directory to be written                                         |
|                                                                       |
+======================================================================*/
PROCEDURE close_file

IS

BEGIN
utl_file.fclose(g_file_handler);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   g_trace := 'N';
   RAISE;
WHEN utl_file.invalid_path                   THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_PATH'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_mode                   THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_MODE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_filehandle             THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_HANDLE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_operation              THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_OPE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.write_error                     THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_WRITE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.internal_error                 THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_ERROR'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_utility_pkg.close_file');
END close_file;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| convert_msg                                                           |
|                                                                       |
| Convert the message to place the symbol = after 25 characters         |
|                                                                       |
+======================================================================*/
FUNCTION convert_msg
  (p_msg                          IN  VARCHAR2)
RETURN VARCHAR2

IS

l_equal_position                  INTEGER    ;
l_pos                             INTEGER;
l_datetime                        VARCHAR2(30);
l_new_msg                         VARCHAR2(2000);
l_msg                         VARCHAR2(2000);

BEGIN

c_equal_symbol     := '=';

IF g_format = 'N' THEN
   RETURN p_msg;
END IF;

IF g_trace_datetime = 'Y' THEN
   l_equal_position := c_equal_position + 20;
   l_datetime       := TO_CHAR(sysdate,'DD-MON HH24:MI:SS');
ELSE
   l_equal_position := c_equal_position;
END IF;

l_pos      := NVL(INSTR(p_msg,c_equal_symbol,1,1),0);

IF l_pos = 0 THEN
   l_new_msg := p_msg;
ELSE
   IF    l_pos = l_equal_position   THEN
      l_new_msg := p_msg;
   ELSIF l_pos < l_equal_position   THEN
      l_new_msg := RPAD(NVL(SUBSTR(RTRIM(REPLACE(p_msg,' ',' ')),1,l_pos-1),'@'),l_equal_position-1,' ')||'='||SUBSTR(p_msg,l_pos+1);
   ELSE
      --
      -- Symbol is after the threshold.
      -- PLAB: To review to handle nested new lines
      --
      l_new_msg := SUBSTR(p_msg,1,l_pos-1)
         ||  xla_environment_pkg.g_chr_newline
         ||  ' '||LPAD('=',l_equal_position-1,' ')
         ||  SUBSTR(p_msg,l_pos+1);
   END IF;
END IF;

IF g_trace_datetime = 'Y' THEN
   --
   -- Add the time on the left side and left pad the new line character
   -- with the space allocated to the timing
   --
   RETURN l_datetime || ' '||REPLACE(l_new_msg,xla_environment_pkg.g_chr_newline
                                              ,xla_environment_pkg.g_chr_newline || RPAD(' ',16,' '));
ELSE
   RETURN l_new_msg;
END IF;
END convert_msg;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| print_output                                                          |
|                                                                       |
| Print the messgae to the standard dbms_output                         |
|                                                                       |
| Parameters                                                            |
|             1  IN  p_msg                VARCHAR2 Debug message        |
|                                                                       |
+======================================================================*/
PROCEDURE print_output
  (p_msg                          IN  VARCHAR2)

IS

l_length             NUMBER;
l_compt              NUMBER;
l_sub                VARCHAR2(4000);
l_pos                NUMBER;
l_l                  NUMBER;

BEGIN
l_length := LENGTHB(p_msg);
l_compt  := 1;
WHILE (l_compt <= l_length) LOOP
   BEGIN
   l_pos := INSTR(p_msg,xla_environment_pkg.g_chr_newline,l_compt,1);
   IF ((l_pos = 0) OR ((l_pos -l_compt) > c_max_msg_output)) THEN
      l_l     := LEAST(c_max_msg_output,l_length-l_compt+1);
      l_sub   := SUBSTR(p_msg,l_compt,l_l);
      l_compt := l_compt+l_l;
   ELSE
      l_l     := l_pos - l_compt;
      l_sub   := SUBSTR(p_msg,l_compt,l_l);
      l_compt := l_compt+l_l+1;
   END IF;
   END;
END LOOP;
END print_output;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| print_html                                                            |
|                                                                       |
| Print the messgae to the standard dbms_output                         |
|                                                                       |
| Parameters                                                            |
|             1  IN  p_msg                VARCHAR2 Debug message        |
|                                                                       |
+======================================================================*/
PROCEDURE print_html
  (p_msg                          IN  VARCHAR2)

IS

BEGIN
htp.p(p_msg);
END print_html;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| print_fndfile                                                         |
|                                                                       |
| Print the messgage to the fndfile                                     |
|                                                                       |
| Parameters                                                            |
|             1  IN  p_msg                VARCHAR2 Debug message        |
|                                                                       |
+======================================================================*/
PROCEDURE print_fndfile
  (p_msg                          IN  VARCHAR2)

IS

BEGIN
fnd_file.put_line(fnd_file.log,p_msg);

-- IF xla_utility_event_pkg.is_event_set('RAISE_FND_FILE_OPEN_FAILURE') THEN
--   RAISE utl_file.invalid_path;
-- END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   g_srs_output_enable := 'N';
      RAISE;
WHEN OTHERS  THEN
   g_srs_output_enable := 'N';
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_utility_pkg.print_fndfile');
END print_fndfile;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| print_aflog                                                           |
|                                                                       |
| Print the messgage to the af log                                      |
|                                                                       |
| Parameters                                                            |
|             1  IN  p_msg                VARCHAR2 Debug message        |
|                                                                       |
+======================================================================*/
PROCEDURE print_aflog
  (p_msg                          IN  VARCHAR2)

IS

BEGIN
IF fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL THEN
fnd_log.string
  (fnd_log.LEVEL_STATEMENT ,'xla-plsql' ,p_msg);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS  THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_utility_pkg.print_aflog');
END print_aflog;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| print_fndfile                                                         |
|                                                                       |
| Print the messgage to the fndfile                                     |
|                                                                       |
| Parameters                                                            |
|             1  IN  p_msg                VARCHAR2 Debug message        |
|                                                                       |
+======================================================================*/
PROCEDURE print_file
  (p_msg                          IN  VARCHAR2)

IS

BEGIN
utl_file.put_line(g_file_handler,p_msg);

IF g_file_flush_option = 'Y' THEN
   utl_file.fflush(g_file_handler);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   g_trace := 'N';
   RAISE;
WHEN utl_file.invalid_path                   THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_PATH'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_mode                   THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_MODE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_filehandle             THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_HANDLE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.invalid_operation              THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_OPE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.write_error                     THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_WRITE'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN utl_file.internal_error                 THEN
      xla_exceptions_pkg.raise_message
     ('XLA'        , 'XLA_TRACE_FILE_ERROR'
     ,'FILENAME'   , g_file_name
     ,'DIRECTORY'  , g_file_directory);
WHEN OTHERS  THEN
   g_trace := 'N';
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_utility_pkg.print_file');
END print_file;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| send_pipe                                                             |
|                                                                       |
| Print the message to the pipe.                                        |
|                                                                       |
+======================================================================*/
PROCEDURE send_pipe
  (p_msg                          IN  VARCHAR2)

IS

l_cr                 NUMBER;
BEGIN
dbms_pipe.pack_message(NVL(p_msg,' ') );
l_cr := dbms_pipe.send_message(g_pipe_name,g_timeout,c_pipe_buffer_size);
IF l_cr <> 0 THEN
   IF    l_cr = 1 THEN
      --
      -- Switch the trace to OFF to avoid indefinite recursive loop
      --
      g_trace := 'N';
      xla_exceptions_pkg.raise_message
                (p_appli_s_name => 'XLA'
               , p_msg_name    => 'XLA_TRACE_PIPE_TIMEOUT');
   ELSIF l_cr = 3 THEN
      --
      -- Switch the trace to OFF to avoid indefinite recursive loop
      --
      g_trace := 'N';
      xla_exceptions_pkg.raise_message
                (p_appli_s_name => 'XLA'
                ,p_msg_name     =>  'XLA_TRACE_PIPE_ERROR');
   ELSE
      --
      -- Switch the trace to OFF to avoid indefinite recursive loop
      --
      g_trace := 'N';
      xla_exceptions_pkg.raise_message  ('XLA'          , 'XLA_TRACE_PIPE_ERROR2'
                                        ,'ERROR'        , l_cr);
   END IF;
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS  THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_utility_pkg.send_pipe');
END send_pipe;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| print_pipe                                                            |
|                                                                       |
| Print the message to the pipe                                         |
|                                                                       |
+======================================================================*/
PROCEDURE print_pipe
  (p_msg                          IN  VARCHAR2)

IS

l_length             NUMBER;
l_compt              NUMBER;
l_sub                VARCHAR2(4000);
l_pos                NUMBER;
l_l                  NUMBER;

BEGIN
l_length := LENGTHB(p_msg);
l_compt  := 1;
WHILE (l_compt <= l_length) LOOP
   BEGIN
   l_pos := INSTR(p_msg,xla_environment_pkg.g_chr_newline,l_compt,1);
   IF ((l_pos = 0) OR ((l_pos -l_compt) > c_max_msg_pipe)) THEN
      l_l     := LEAST(c_max_msg_pipe,l_length-l_compt+1);
      l_sub   := SUBSTR(p_msg,l_compt,l_l);
      l_compt := l_compt+l_l;
   ELSE
      l_l     := l_pos - l_compt;
      l_sub   := SUBSTR(p_msg,l_compt,l_l);
      l_compt := l_compt+l_l+1;
   END IF;
   send_pipe(l_sub);
   END;
END LOOP;
END print_pipe;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| set_unique_session_info                                               |
|                                                                       |
| Set the pipe name.                                                    |
|                                                                       |
+======================================================================*/
PROCEDURE set_unique_session_info

IS

BEGIN
g_pipename_increment  := g_pipename_increment + 1;
g_pipe_name           := xla_environment_pkg.g_session_name
                      || '_'
                      || LTRIM(RTRIM(TO_CHAR(g_pipename_increment)))
                      || c_pipe_name_suffix;
g_unique_location     := REPLACE(g_location ,'''','')
                      || '_'
                      || xla_environment_pkg.g_session_name
                      || '_'
                      || LTRIM(RTRIM(TO_CHAR(g_pipename_increment)));
END set_unique_session_info;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| stop_tracer                                                           |
|                                                                       |
| Stop the tracer by sending the STOP message. Any error is ignored.    |
|                                                                       |
+======================================================================*/
PROCEDURE stop_tracer

IS

l_cr                 NUMBER;
BEGIN
dbms_pipe.pack_message('STOP');
l_cr := dbms_pipe.send_message(g_pipe_name,g_timeout,c_pipe_buffer_size);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   g_trace := 'N';
   RAISE;
WHEN OTHERS  THEN
   g_trace := 'N';
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_utility_pkg.stop_tracer');
END stop_tracer;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| SubmitTracer                                                          |
|                                                                       |
| Call the tracer                                                       |
|                                                                       |
| Return                                                                |
|             0  Success                                                |
|             2  Failure                                                |
|                                                                       |
+======================================================================*/
PROCEDURE SubmitTracer
IS

PRAGMA               autonomous_transaction;
l_reqid              NUMBER;
l_temp               VARCHAR2(255);

BEGIN

IF g_debug_mode = 'OF' THEN
   l_temp := g_location;
ELSE
   IF g_RequestId NOT IN (0,-1) THEN
      l_temp := TO_CHAR(g_RequestId);
   ELSE
      l_temp := g_location;
   END IF;
END IF;

IF    g_mode = c_mode_stracer THEN
   l_reqid := fnd_request.submit_request (c_cp_appli
                                         ,c_cp_stracer
                                         ,description => 'Trace '||l_temp
                                         ,argument1   => g_pipe_name) ;
   IF l_reqid = 0 THEN
      l_reqid := fnd_request.submit_request (c_cp_appli
                                            ,c_cp_tracer
                                            ,description => 'Trace '||l_temp
                                            ,argument1   => g_pipe_name);
   END IF;
ELSIF g_mode = c_mode_jtracer THEN
   l_reqid := fnd_request.submit_request (c_cp_appli
                                         ,c_cp_jtracer
                                         ,description => 'Trace '||l_temp
                                         ,argument1   => g_pipe_name) ;
   IF l_reqid = 0 THEN
      l_reqid := fnd_request.submit_request (c_cp_appli
                                            ,c_cp_tracer
                                            ,description => 'Trace '||l_temp
                                            ,argument1   => g_pipe_name);
   END IF;

ELSE
   l_reqid := fnd_request.submit_request (c_cp_appli
                                         ,c_cp_tracer
                                         ,description => 'Trace '||l_temp
                                         ,argument1   => g_pipe_name);
END IF;

IF l_reqid = 0 THEN
   RAISE xla_exceptions_pkg.application_exception;
END IF;

g_trace_reqid := l_reqid;
COMMIT;

IF g_trace = 'Y' THEN
   dbms_pipe.purge(g_pipe_name);
   dbms_pipe.reset_buffer;
END IF;
END SubmitTracer;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| print_header                                                          |
|                                                                       |
| Printer the standard header                                           |
|                                                                       |
+======================================================================*/
PROCEDURE print_header

IS

BEGIN
IF g_header = 'Y' THEN
   trace('Utilities activated'                                             ,-10);
   trace(RPAD('+',76,'-')||'+'                                             ,-10);
   trace('Revision                   = $Revision: 120.11 $'                 ,-10);
   trace('Datetime                   = ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')
                                                                        ,-10);
   trace('OS Module                  = ' || xla_environment_pkg.g_module   ,-10);
   trace('OS Process id              = ' || xla_environment_pkg.g_process_id, -10);
   trace('RDBMS Session id           = ' || xla_environment_pkg.g_session_id, -10);
   trace('SRS Program                = ' || xla_environment_pkg.g_program  ,-10);
   trace('Location                   = ' || g_location                     ,-10);
   trace('Timeout                    = ' || g_timeout                      ,-10);
   trace('Type                       = ' || g_debug_mode                   ,-10);
   trace('Mode                       = ' || g_mode                         ,-10);
   trace('File flush                 = ' || g_file_flush_option            ,-10);
   trace('SRS output enabled         = ' || g_srs_output_enable            ,-10);
   trace('Trace enabled              = ' || g_trace                        ,-10);
   trace('Trace Level                = ' || g_trace_level                  ,-10);
   trace('Profiler enabled           = ' || g_profiler                     ,-10);
   trace('Profiler location          = ' || g_unique_location              ,-10);
   trace(RPAD('+',76,'-')||'+'                                             ,-10);
END IF;
END;


/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| print_footer                                                          |
|                                                                       |
| Printer the standard footer                                           |
|                                                                       |
+======================================================================*/
PROCEDURE print_footer

IS

BEGIN
IF g_footer = 'Y' THEN
   trace(RPAD('+',76,'-')||'+'                                             ,-10);
   trace('Utilities deactivated'                                           ,-10);
   trace('Datetime                   = ' || TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS')
                                                                        ,-10);
   trace('Trace Origin Location      = ' || g_location                     ,-10);
END IF;
END;


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
| Activate/Deactivate                                                   |
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
  ,p_Location                     IN  VARCHAR2)

IS

BEGIN
IF NOT g_debug THEN

   --
   -- Debug if OFF, or (in a very few cases) switched back from ON to OFF
   --

   IF NVL(g_location,'UNKNOWN') = 'UNKNOWN' THEN

      --
      -- First debug initialization.
      -- Keep the location where the first init_trace has been requested.
      --
      g_Location           := p_Location;

      ---
      --- Determinate the options for the session
      ---
      set_unique_session_info;
      set_options;

      IF p_debug_mode  IN ('SRS_DBP','OR','OF') THEN

         --
         -- Caller is either SRS, Reports, Forms, conditionnally set
         --

         --
         -- Get the request id. This will be used to determinate if the program is running within a
         -- concurrent program or not.
         -- A direct call to fnd is used to avoid side effects when the debug is implicity launched
         --
         g_RequestId         := fnd_global.conc_request_id;

         IF g_trace      = 'Y'
         OR g_stat       = 'Y' THEN

            --
            -- Debug is ON
            --
            g_debug_mode         := p_debug_mode;

            ---
            --- Logfile is supported for SRS_DBP ONLY
            ---
            IF    g_debug_mode      IN ('SRS_DBP','DBP') THEN
               g_mode  := g_srs_mode;
            ELSIF g_debug_mode      IN ('OF') THEN
               g_mode  := g_of_mode;
            END IF;

            --
            -- Depending on the mode
            -- * Launch the tracer
            -- * open the file
            --
            IF    g_mode IN       (c_mode_tracer
                                  ,c_mode_stracer
                                  ,c_mode_jtracer) THEN

               SubmitTracer;
            ELSIF g_mode  = 'FILE'                    THEN
               open_file;
            END IF;

            --
            -- Switch the trace ON after initialization
            --
            g_debug             := TRUE;

         END IF;

         --
         -- Open SRS files since the first call may perform a commit.
         --
         -- This call must be made in SRS context. To verify this, we check whether the Trace
         -- is ON or OFF for SRS_DBP calls
         --
         IF  p_debug_mode IN ('SRS_DBP')  THEN
            open_srs_files;
         END IF;

      ELSIF p_debug_mode IN ('OUTPUT')  THEN

         --
         -- Trace activated from SQL*Plus or SQL*Dba
         -- The level trace is setup to the max level
         --
         g_debug_mode  := p_debug_mode;
         g_mode        := g_debug_mode;
         g_RequestId   := NULL;
         g_Location    := p_Location;
         g_debug       := TRUE;


      ELSIF p_debug_mode IN ('STD_DBP') THEN

         --
         -- Trace undirectly activated from non XLA packages
         --
         IF  g_trace = 'Y' THEN
            open_file;
            g_debug_mode  := p_debug_mode;
            g_mode        := g_debug_mode;
            g_RequestId   := NULL;
            g_Location    := p_Location;
            g_debug       := TRUE;
         END IF;

      ELSIF p_debug_mode IN ('FILE') THEN

         --
         -- Trace activated from one anonymous package from SQL*Plus
         --
         open_file;
         g_debug_mode  := p_debug_mode;
         g_mode        := g_debug_mode;
         g_RequestId   := NULL;
         g_Location    := p_Location;
         g_debug       := TRUE;

      ELSIF p_debug_mode IN ('HTML','HTM') THEN

         --
         -- Trace activated from one anonymous package from SQL*Plus
         --

         g_debug_mode  := p_debug_mode;
         g_mode        := g_debug_mode;
         g_RequestId   := NULL;
         g_Location    := p_Location;
         g_debug       := TRUE;

      ELSIF p_debug_mode IN ('AFLOG')      THEN

         --
         -- Trace activated in AFLOG mode
         --

         g_debug_mode  := p_debug_mode;
         g_mode        := g_debug_mode;
         g_RequestId   := NULL;
         g_Location    := p_Location;
         g_debug       := TRUE;

      END IF;

      IF g_stat       = 'Y' THEN
         set_stat_on;
      END IF;

      --
      -- Print the standard header
      --
      print_header;

   END IF;
END IF;
END Activate;



/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| deactivate                                                            |
|                                                                       |
| De-Activate, if set, the XLA utility mode.                            |
|                                                                       |
+======================================================================*/
PROCEDURE Deactivate
  (p_Location                     IN  VARCHAR2)
IS

l_timeout                         INTEGER;
l_old_stat                        VARCHAR2(1);

BEGIN

--
-- Need to handle situation when origin location = ending location
--
IF g_location = p_Location THEN

   --
   -- Unactivate the stat, if enabled
   --
   l_old_stat      := g_stat;

   IF g_stat        = 'Y' THEN
      set_stat_off;
   END IF;

   --
   -- Need to print a footer when Trace or Stat is ON
   --
   IF g_debug   THEN

      ---
      --- Handle timeouts/write failures, forced to 20 seconds
      ---
      l_timeout            := g_timeout;
      g_timeout            := 20;

      BEGIN
      --
      -- Print the standard footer as well as the statistics
      --
      IF l_old_stat   = 'Y' THEN
         print_stat_info;
      END IF;

      print_footer;

      EXCEPTION
      WHEN xla_exceptions_pkg.application_exception THEN
         NULL;
      END;

      --
      -- Reset the timeout to the actual value
      --
      l_timeout  := g_timeout;

      --
      -- If any of them apply
      --   Shutdown the tracer
      --   Close the file
      --
      IF g_mode  IN (c_mode_tracer
                     ,c_mode_stracer
                     ,c_mode_jtracer) THEN

         BEGIN
         stop_tracer;
         EXCEPTION
         WHEN xla_exceptions_pkg.application_exception THEN
            NULL;
         END;
      ELSIF g_mode IN ('FILE') THEN
         close_file;
      END IF;
   END IF;

   --
   -- Reset all variables
   --
   g_debug := FALSE;

   reset_options;
ELSE
   trace('Deactivate rejected        = ' || p_location       ,  10);
END IF;
END DeActivate;



/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_location                                                          |
|                                                                       |
| Set any option.                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE set_option
  (p_option                       IN  VARCHAR2
  ,p_option_value                 IN  VARCHAR2)

IS

BEGIN
IF    p_option = 'TRACE_LEVEL'                THEN
   g_dflt_trace_level              := p_option_value;
ELSIF p_option = 'PROFILER'                   THEN
   g_dflt_profiler                 := p_option_value;
ELSIF p_option = 'HEADER'                     THEN
   g_dflt_header                   := p_option_value;
ELSIF p_option = 'FOOTER'                     THEN
   g_dflt_footer                   := p_option_value;
ELSIF p_option = 'TRACE_DATETIME'             THEN
   g_dflt_trace_datetime           := p_option_value;
ELSIF p_option = 'SQLTRACE'                   THEN
   g_dflt_sqltrace                 := p_option_value;
ELSIF p_option = 'FILE_FLUSH_OPTION'          THEN
   g_dflt_file_flush_option        := p_option_value;
ELSIF p_option = 'FILE_OVERRIDE_DIRECTORY'    THEN
   g_dflt_file_override_directory := p_option_value;
ELSIF p_option = 'FILE_OVERRIDE_FILENAME'     THEN
   g_dflt_file_override_filename  := p_option_value;
ELSIF p_option = 'TRACE'                      THEN
   g_dflt_trace                   := p_option_value;
ELSIF p_option = 'SRS_MODE'                   THEN
   g_dflt_srs_mode                := p_option_value;
ELSIF p_option = 'OF_MODE'                    THEN
   g_dflt_of_mode                 := p_option_value;
ELSIF p_option = 'TIMEOUT'                    THEN
   g_dflt_timeout                 := p_option_value;
ELSIF p_option = 'SRS_OUTPUT_ENABLE'          THEN
   g_dflt_srs_output_enable       := p_option_value;
ELSE
   xla_exceptions_pkg.raise_message
     ('XLA'      ,'XLA_INTERNAL_ERROR'
     ,'ERROR'    ,'Invalid option '||p_option
     ,'LOCATION' ,'xla_utility_pkg.set_option');
END IF;
END set_option;


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
| Tracer                                                                |
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
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| Public Trace procedures                                               |
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
| Activate, if set, the XLA Trace.                                      |
|                                                                       |
+======================================================================*/
PROCEDURE Activate_trace
  (p_debug_mode                   IN  VARCHAR2
  ,p_location                     IN  VARCHAR2)

IS

BEGIN
IF NOT g_debug THEN
   g_dflt_trace := 'Y';

   activate
     (p_debug_mode   => p_debug_mode
     ,p_location     => p_location);

END IF;
END Activate_trace;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| DeActivate_trace                                                      |
|                                                                       |
| De-Activate, if set, the XLA Trace, if called by the same funtion that|
| activated.                                                            |
|                                                                       |
+======================================================================*/
PROCEDURE Deactivate_trace
  (p_Location                     IN  VARCHAR2 )

IS

BEGIN
deactivate
  (p_location => p_location);
END Deactivate_trace;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_traceoff                                                         |
|                                                                       |
| Switch the trace off.                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE set_trace_off

IS

BEGIN
g_trace := 'N';
END set_trace_off;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_trace_on                                                          |
|                                                                       |
| Switch the trace on.                                                  |
|                                                                       |
+======================================================================*/
PROCEDURE set_trace_on

IS

BEGIN
g_trace := 'Y';
END set_trace_on;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| trace                                                                 |
|                                                                       |
| Print the trace message                                               |
|                                                                       |
+======================================================================*/
PROCEDURE trace
  (p_msg                          IN  VARCHAR2
  ,p_level                        IN  NUMBER  )

IS

l_cr                              INTEGER;

BEGIN
IF ((g_trace        = 'Y'
AND  p_level       <= g_trace_level
AND  g_trace_level >= 0)
OR  (g_trace        = 'Y'
AND  p_level       >= ABS(g_trace_level )
AND  g_trace_level  < 0)
OR  (g_trace        = 'N'
AND  p_level        < 0))
AND  g_debug               THEN
   print(p_msg);
END IF;
END trace;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| print_trace_info                                                      |
|                                                                       |
| Print all information related to the trace to the std Trace output.   |
|                                                                       |
+======================================================================*/
PROCEDURE print_trace_info

IS

BEGIN
NULL;
END print_trace_info;


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
RETURN VARCHAR2

IS

BEGIN
IF    p_option = 'SESSION_ID'                   THEN
   RETURN xla_environment_pkg.g_session_id;
ELSIF p_option = 'PROCESS_ID'                   THEN
   RETURN xla_environment_pkg.g_process_id;
ELSE
   xla_exceptions_pkg.raise_message
     ('XLA'      ,'XLA_INTERNAL_ERROR'
     ,'ERROR'    ,'Invalid option '||p_option
     ,'LOCATION' ,'xla_utility_pkg.get_session_info');
END IF;
END get_session_info;


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
RETURN VARCHAR2
IS
BEGIN
IF p_option = 'TIMEOUT'                      THEN
   RETURN g_timeout;
ELSIF p_option = 'DEBUG'                        THEN
   RETURN g_trace;
ELSIF p_option = 'TRACE_LEVEL'                  THEN
   RETURN g_trace_level;
ELSE
   xla_exceptions_pkg.raise_message
     ('XLA'      ,'XLA_INTERNAL_ERROR'
     ,'ERROR'    ,'Invalid option '||p_option
     ,'LOCATION' ,'xla_utility_pkg.get_session_info');
END IF;
END;


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
  (p_msg                          IN  VARCHAR2)
IS
BEGIN
IF    g_mode            IN (c_mode_tracer
                           ,c_mode_jtracer
                           ,c_mode_stracer) THEN
   print_pipe(convert_msg(p_msg));
ELSIF g_mode     = 'LOGFILE'           THEN
   print_fndfile(convert_msg(p_msg));
ELSIF g_mode    IN ('AFLOG')           THEN
   print_aflog(convert_msg(p_msg));
ELSIF g_mode    IN ('FILE')            THEN
   print_file(convert_msg(p_msg));
ELSIF g_mode    IN ('OUTPUT')          THEN
   print_output(convert_msg(p_msg));
ELSIF g_mode    IN ('HTML')            THEN
   print_html(convert_msg(p_msg));
ELSE
   --
   -- New mode probably, need to trace off before raising exception
   -- to prevent entering in an infinite loop
   --
   g_trace := 'N';
   xla_exceptions_pkg.raise_message  ('XLA'         , 'XLA_TRACE_INV_MODE'
                                        ,'MODE'        , g_mode);
END IF;
END print;



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
| Activate the statistics.                                              |
|                                                                       |
+======================================================================*/
PROCEDURE Activate_stat
  (p_debug_mode                   IN  VARCHAR2
  ,p_location                     IN  VARCHAR2)

IS

BEGIN
IF NOT g_debug THEN
   g_dflt_profiler := 'Y';

   activate
     (p_debug_mode   => p_debug_mode
     ,p_location     => p_location);

END IF;
END Activate_stat;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| DeActivate_stat                                                       |
|                                                                       |
| De-Activate, if set, the XLA Statistics.                              |
|                                                                       |
+======================================================================*/
PROCEDURE Deactivate_stat
  (p_Location                     IN  VARCHAR2 )

IS

BEGIN
deactivate
  (p_location => p_location);
END Deactivate_stat;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_stat_on                                                           |
|                                                                       |
| Switch the stat on.                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE set_stat_on

IS

BEGIN
IF g_profiler            = 'Y' THEN
   xla_utility_profiler_pkg.start_profiler;
END IF;

g_stat_datetime_start := dbms_utility.get_time;

g_stat := 'Y';
END set_stat_on;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_stat_off                                                          |
|                                                                       |
| Switch the stat off.                                                  |
|                                                                       |
+======================================================================*/
PROCEDURE set_stat_off

IS

BEGIN
IF g_stat = 'Y' THEN
   g_stat_datetime_stop := dbms_utility.get_time;

   IF g_profiler = 'Y' THEN
      xla_utility_profiler_pkg.stop_profiler;
   END IF;
   g_stat := 'N';
END IF;
END set_stat_off;



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
RETURN VARCHAR2

IS

BEGIN
IF    p_option = 'DURATION'                   THEN
   RETURN TO_CHAR(g_stat_datetime_stop
           -      g_stat_datetime_start);
ELSE
   xla_exceptions_pkg.raise_message
     ('XLA'      ,'XLA_INTERNAL_ERROR'
     ,'ERROR'    ,'Invalid option '||p_option
     ,'LOCATION' ,'xla_utility_pkg.set_option');
END IF;
END get_stat_info;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| print_stat_info                                                       |
|                                                                       |
| Print all information related to the stat to the std Trace output.    |
|                                                                       |
+======================================================================*/
PROCEDURE print_stat_info

IS

BEGIN
-- to be enhanced to support timing across days
print(RPAD('+',76,'-')||'+');
print(RPAD('Duration ',c_equal_position -1)
             || '= '
             ||
                TO_CHAR(g_stat_datetime_stop
                 -      g_stat_datetime_start));
print(RPAD('+',76,'-')||'+');

IF g_profiler = 'Y' THEN
   g_format := 'N';
   xla_utility_profiler_pkg.dump_profiler_data;
   g_format := 'Y';
END IF;
END print_stat_info;


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
| init_sqltrace                                                         |
|                                                                       |
| Alter the session to enter in sql_trace mode.                         |
|                                                                       |
+======================================================================*/
PROCEDURE set_sqltrace_on

IS

BEGIN
IF g_sqltrace = 'Y' THEN
   dbms_session.set_sql_trace(TRUE);
END IF;
END;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| sqltrace_off                                                          |
|                                                                       |
| Alter the session to finish the sql trace mode.                       |
|                                                                       |
+======================================================================*/
PROCEDURE set_sqltrace_off

IS

BEGIN
IF g_sqltrace = 'Y' THEN
  dbms_session.set_sql_trace(FALSE);
END IF;
END;


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
| Print the messgage to the fnd logfile                                 |
|                                                                       |
| Parameters                                                            |
|             1  IN  p_msg                VARCHAR2 Debug message        |
|                                                                       |
+======================================================================*/
PROCEDURE print_outputfile
  (p_msg                          IN  VARCHAR2)

IS

BEGIN
IF  g_RequestId      NOT IN (-1,0)
AND g_srs_output_enable   = 'Y' THEN
   fnd_file.put_line(fnd_file.output,p_msg);
END IF;
END print_outputfile;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| print_logfile                                                         |
|                                                                       |
| Print the messgage to the fnd output file                             |
|                                                                       |
| Parameters                                                            |
|             1  IN  p_msg                VARCHAR2 Debug message        |
|                                                                       |
+======================================================================*/
PROCEDURE print_logfile        (p_msg                          IN  VARCHAR2)
IS

BEGIN
IF  g_RequestId      NOT IN (0,-1)
AND g_srs_output_enable   = 'Y' THEN
   fnd_file.put_line(fnd_file.log,p_msg);
END IF;
END print_logfile;


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
| Private Procedure                                                     |
|                                                                       |
| reset                                                                 |
|                                                                       |
| Reset the global variables.                                           |
| instanciated.                                                         |
|                                                                       |
+======================================================================*/
PROCEDURE reset
IS
BEGIN
xla_environment_pkg.refresh;
set_default_options;
g_stat := 'N';
END reset;


BEGIN
reset;

END xla_utility_pkg;

/
