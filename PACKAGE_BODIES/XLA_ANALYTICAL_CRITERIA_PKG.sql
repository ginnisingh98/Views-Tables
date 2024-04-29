--------------------------------------------------------
--  DDL for Package Body XLA_ANALYTICAL_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ANALYTICAL_CRITERIA_PKG" AS
/* $Header: xlabaacr.pkb 120.23.12010000.2 2010/03/26 05:36:12 karamakr ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_criteria_pkg                                        |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Analytical Criteria Package                                    |
|                                                                       |
| HISTORY                                                               |
|    27-AUG-02 A. Quaglia     Created                                   |
|    02-APR-03 A. Quaglia     Major revisions                           |
|    10-APR-03 A. Quaglia     Final adjustments                         |
|    08-SEP-03 A. Quaglia     Included the following functions/procs:   |
|                             get_first_free_view_col_number            |
|                             compile_criterion                         |
|                             build_criteria_view                       |
|    16-SEP-03 A. Quaglia     In build_criteria_view removed condition  |
|                             on enabled_flag in lc_displayable_details |
|    18-SEP-03 A. Quaglia     insert_line_detail: delete dummy line     |
|                             detail before inserting the detail        |
|                             delete_line_detail: created. It all       |
|                             details removed for a line, the dummy line|
|                             detail is inserted.                       |
|    27-JAN-03 A. Quaglia     bug3402449: removed previous changes      |
|                                         delete_line_detail left since |
|                                         the code is cleaner.          |
|                             Changed trace handling as per Sandeep's   |
|                             code.                                     |
|    12-Feb-04 Shishir Joshi  Replaced hh24miss with HH24MISS to improve|
|                             the performance.                          |
|    26-MAR-04 A.Quaglia      Fixed debug changes issues:               |
|                               -Replaced global variable for trace     |
|                                with local one                         |
|                               -Fixed issue with SQL%ROWCOUNT which is |
|                                modified after calling debug proc      |
|    14-APR-04 A.Quaglia      Performance changes in get_detail_value_id|
|                             Removed hardcoded APPS in                 |
|                             build_criteria_view                       |
|    30-JUN-05 W.Chan         Fix bug 4299125 - Modify compile_criteria |
|                             to use the same view_column for details of|
|                             the same amb context.  Modify             |
|                             build_criteria_views not to use amb       |
|                             context when building the views           |
|    01-SEP-05 W.Chan         Fix bug 4583524 - Fix                     |
|                             get_view_column_number to ignore rows     |
|                             NULL is in the view_column_num            |
|                                                                       |
+======================================================================*/


--
-- Private exceptions
--
   le_resource_busy                   EXCEPTION;
   PRAGMA exception_init(le_resource_busy, -00054);

--
-- Private constants
--
   --accounting line is eligible for analytical criteria balance calc.
   C_ANALYTICAL_BAL_FLAG_PEND CONSTANT VARCHAR2(1) := 'P';
   --accounting line is not eligible for analytical criteria balance calc.
   C_ANALYTICAL_BAL_FLAG_NO   CONSTANT VARCHAR2(1) := NULL;
   --accounting line has been processed by analytical criteria balance calc.
   C_ANALYTICAL_BAL_FLAG_DONE CONSTANT VARCHAR2(1) := 'Y';


   --Number of slots available for each datatype of analytical criteria details
   C_MAX_MAPPABLE_VARCHAR_DETAILS CONSTANT INTEGER := 50; --400;
   C_MAX_MAPPABLE_DATE_DETAILS    CONSTANT INTEGER := 10; --200;
   C_MAX_MAPPABLE_NUMBER_DETAILS  CONSTANT INTEGER := 40; --200;
   --Total number of slots available
   C_MAX_MAPPABLE_DETAILS         CONSTANT INTEGER := C_MAX_MAPPABLE_VARCHAR_DETAILS
                                                     +C_MAX_MAPPABLE_DATE_DETAILS
                                                     +C_MAX_MAPPABLE_NUMBER_DETAILS;
   --Offset to add to the view column number contained in xla_analytical_dtls_b
   --to get the actual column position in xla_analytical_criteria_v
   C_MAPPABLE_VARCHAR_OFFSET      CONSTANT INTEGER := 0;
   C_MAPPABLE_DATE_OFFSET         CONSTANT INTEGER := C_MAPPABLE_VARCHAR_OFFSET
                                                     +C_MAX_MAPPABLE_VARCHAR_DETAILS;
   C_MAPPABLE_NUMBER_OFFSET       CONSTANT INTEGER := C_MAPPABLE_DATE_OFFSET
                                                     +C_MAX_MAPPABLE_DATE_DETAILS;
   -- Mizuru
   C_AC_DELIMITER                 CONSTANT VARCHAR2(2) := '(]';

   --
   -- Private variables
   --
   g_user_id         INTEGER     := xla_environment_pkg.g_usr_id;
   g_login_id        INTEGER     := xla_environment_pkg.g_login_id;
   g_date            DATE        := SYSDATE;

   g_hdr_ac_count    PLS_INTEGER;
   g_line_ac_count   PLS_INTEGER;

   --Cache structures
   C_ANACRI_CACHE_MAX_SIZE          CONSTANT INTEGER := 10;
   g_anacri_cache_next_avail_pos             INTEGER := 1;

   TYPE gt_anacri_id            IS TABLE OF INTEGER
                                         INDEX BY BINARY_INTEGER;
   TYPE gt_anacri_code          IS TABLE OF VARCHAR2(30)
                                         INDEX BY BINARY_INTEGER;
   TYPE gt_anacri_type_code     IS TABLE OF VARCHAR2(1)
                                         INDEX BY BINARY_INTEGER;
   TYPE gt_amb_context_code     IS TABLE OF VARCHAR2(30)
                                         INDEX BY BINARY_INTEGER;
   TYPE gt_anacri_detail_char   IS TABLE OF VARCHAR2(240)
                                         INDEX BY BINARY_INTEGER;
   TYPE gt_anacri_detail_date   IS TABLE OF DATE
                                         INDEX BY BINARY_INTEGER;
   TYPE gt_anacri_detail_number IS TABLE OF NUMBER
                                         INDEX BY BINARY_INTEGER;


   ga_anacri_id              gt_anacri_id               ;
   ga_anacri_code            gt_anacri_code             ;
   ga_anacri_type_code       gt_anacri_type_code        ;
   ga_amb_context_code       gt_amb_context_code        ;

   ga_anacri_detail_char_1   gt_anacri_detail_char      ;
   ga_anacri_detail_char_2   gt_anacri_detail_char      ;
   ga_anacri_detail_char_3   gt_anacri_detail_char      ;
   ga_anacri_detail_char_4   gt_anacri_detail_char      ;
   ga_anacri_detail_char_5   gt_anacri_detail_char      ;

   ga_anacri_detail_date_1   gt_anacri_detail_date      ;
   ga_anacri_detail_date_2   gt_anacri_detail_date      ;
   ga_anacri_detail_date_3   gt_anacri_detail_date      ;
   ga_anacri_detail_date_4   gt_anacri_detail_date      ;
   ga_anacri_detail_date_5   gt_anacri_detail_date      ;

   ga_anacri_detail_number_1 gt_anacri_detail_number    ;
   ga_anacri_detail_number_2 gt_anacri_detail_number    ;
   ga_anacri_detail_number_3 gt_anacri_detail_number    ;
   ga_anacri_detail_number_4 gt_anacri_detail_number    ;
   ga_anacri_detail_number_5 gt_anacri_detail_number    ;

   --
   -- Cursor declarations
   --

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_analytical_criteria_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

--1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

PROCEDURE trace
       ( p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE
        ,p_msg                        IN VARCHAR2
        ,p_level                      IN NUMBER
        ) IS
BEGIN
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, p_module);
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, p_module, p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_analytical_criteria_pkg.trace');
END trace;

/*

******* Obsolete in R12 + ********

*/


FUNCTION insert_detail_value
  ( p_anacri_code             IN VARCHAR2
   ,p_anacri_type_code        IN VARCHAR2
   ,p_amb_context_code        IN VARCHAR2
   ,p_detail_char_1           IN VARCHAR2 DEFAULT NULL
   ,p_detail_char_2           IN VARCHAR2 DEFAULT NULL
   ,p_detail_char_3           IN VARCHAR2 DEFAULT NULL
   ,p_detail_char_4           IN VARCHAR2 DEFAULT NULL
   ,p_detail_char_5           IN VARCHAR2 DEFAULT NULL
   ,p_detail_date_1           IN DATE     DEFAULT NULL
   ,p_detail_date_2           IN DATE     DEFAULT NULL
   ,p_detail_date_3           IN DATE     DEFAULT NULL
   ,p_detail_date_4           IN DATE     DEFAULT NULL
   ,p_detail_date_5           IN DATE     DEFAULT NULL
   ,p_detail_number_1         IN NUMBER   DEFAULT NULL
   ,p_detail_number_2         IN NUMBER   DEFAULT NULL
   ,p_detail_number_3         IN NUMBER   DEFAULT NULL
   ,p_detail_number_4         IN NUMBER   DEFAULT NULL
   ,p_detail_number_5         IN NUMBER   DEFAULT NULL
   ,p_detail_char_id          IN INTEGER  DEFAULT NULL
  ) RETURN INTEGER
IS
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|  Inserts a new record in the table xla_analytical_dtl_vals.           |
|                                                                       |
+======================================================================*/

l_detail_value_id    INTEGER;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_detail_value';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_detail_char_id IS NULL THEN
      INSERT INTO xla_analytical_dtl_vals
      ( analytical_detail_value_id
       ,analytical_criterion_code
       ,analytical_criterion_type_code
       ,amb_context_code
       ,analytical_detail_char_1
       ,analytical_detail_char_2
       ,analytical_detail_char_3
       ,analytical_detail_char_4
       ,analytical_detail_char_5
       ,analytical_detail_date_1
       ,analytical_detail_date_2
       ,analytical_detail_date_3
       ,analytical_detail_date_4
       ,analytical_detail_date_5
       ,analytical_detail_number_1
       ,analytical_detail_number_2
       ,analytical_detail_number_3
       ,analytical_detail_number_4
       ,analytical_detail_number_5
       ,creation_date
       ,created_by
       ,last_update_date
       ,last_updated_by
       ,last_update_login
      )
      VALUES
      ( xla_analytical_dtl_vals_s.nextval
       ,p_anacri_code
       ,p_anacri_type_code
       ,p_amb_context_code
       ,p_detail_char_1
       ,p_detail_char_2
       ,p_detail_char_3
       ,p_detail_char_4
       ,p_detail_char_5
       ,p_detail_date_1
       ,p_detail_date_2
       ,p_detail_date_3
       ,p_detail_date_4
       ,p_detail_date_5
       ,p_detail_number_1
       ,p_detail_number_2
       ,p_detail_number_3
       ,p_detail_number_4
       ,p_detail_number_5
       ,g_date
       ,g_user_id
       ,g_date
       ,g_user_id
       ,g_login_id
      )
      RETURNING analytical_detail_value_id
           INTO l_detail_value_id;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => SQL%ROWCOUNT ||
                           ' row(s) inserted into xla_analytical_dtl_vals '
             ,p_level    => C_LEVEL_STATEMENT);
      END IF;

   ELSE
      l_detail_value_id := p_detail_char_id;

      INSERT INTO xla_analytical_dtl_vals
      ( analytical_detail_value_id
       ,analytical_criterion_code
       ,analytical_criterion_type_code
       ,amb_context_code
       ,analytical_detail_char_1
       ,analytical_detail_char_2
       ,analytical_detail_char_3
       ,analytical_detail_char_4
       ,analytical_detail_char_5
       ,analytical_detail_date_1
       ,analytical_detail_date_2
       ,analytical_detail_date_3
       ,analytical_detail_date_4
       ,analytical_detail_date_5
       ,analytical_detail_number_1
       ,analytical_detail_number_2
       ,analytical_detail_number_3
       ,analytical_detail_number_4
       ,analytical_detail_number_5
       ,creation_date
       ,created_by
       ,last_update_date
       ,last_updated_by
       ,last_update_login
      )
      VALUES
      ( l_detail_value_id
       ,p_anacri_code
       ,p_anacri_type_code
       ,p_amb_context_code
       ,p_detail_char_1
       ,p_detail_char_2
       ,p_detail_char_3
       ,p_detail_char_4
       ,p_detail_char_5
       ,p_detail_date_1
       ,p_detail_date_2
       ,p_detail_date_3
       ,p_detail_date_4
       ,p_detail_date_5
       ,p_detail_number_1
       ,p_detail_number_2
       ,p_detail_number_3
       ,p_detail_number_4
       ,p_detail_number_5
       ,g_date
       ,g_user_id
       ,g_date
       ,g_user_id
       ,g_login_id
      );

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => SQL%ROWCOUNT
                           || ' row(s) inserted into xla_analytical_dtl_vals '
            ,p_level    => C_LEVEL_STATEMENT);
      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_detail_value_id;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.insert_detail_value');
END insert_detail_value;


FUNCTION format_detail_value ( p_detail_char   VARCHAR2
                              ,p_detail_date   DATE
                              ,p_detail_number NUMBER
                             )
RETURN VARCHAR2
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| It returns the first nonnull among the given params, formatted to     |
| VARCHAR2                                                              |
|                                                                       |
| MUST BE KEPT IN SYNCH WITH THE FUNCTION USED IN THE FUNCTION-BASED    |
| INDEX ON XLA_ANALYTICAL_DTL_VALS.                                     |
+======================================================================*/
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.format_detail_value';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'BEGIN+END ' || l_log_module
          ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN  SUBSTRB(
              NVL( p_detail_char
                 ,NVL( TO_CHAR( p_detail_date
                              ,'YYYY/MM/DD HH24:MI:SS'
                              )
                      ,TO_CHAR( p_detail_number
                                ,'TM'
                                ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                              )
                     )
                 )
            ,1,30); -- MAX 30 characters

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.format_detail_value');
END format_detail_value;


FUNCTION maintain_detail_values
  ( p_anacri_code              IN VARCHAR2
   ,p_anacri_type_code         IN VARCHAR2
   ,p_amb_context_code         IN VARCHAR2
   ,p_detail_char_1            IN VARCHAR2
   ,p_detail_char_2            IN VARCHAR2
   ,p_detail_char_3            IN VARCHAR2
   ,p_detail_char_4            IN VARCHAR2
   ,p_detail_char_5            IN VARCHAR2
   ,p_detail_date_1            IN DATE
   ,p_detail_date_2            IN DATE
   ,p_detail_date_3            IN DATE
   ,p_detail_date_4            IN DATE
   ,p_detail_date_5            IN DATE
   ,p_detail_number_1          IN NUMBER
   ,p_detail_number_2          IN NUMBER
   ,p_detail_number_3          IN NUMBER
   ,p_detail_number_4          IN NUMBER
   ,p_detail_number_5          IN NUMBER
  ) RETURN INTEGER
IS
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|  Wrapper for accessing the table xla_analytical_dtl_vals.             |
|                                                                       |
|  Returns the detail_value_id of the analytical detail value if it     |
|  exists, or inserts a new record.                                     |
|                                                                       |
|  No validation is done on the parameters.                             |
|                                                                       |
|                                                                       |
+======================================================================*/

l_detail_value_id     INTEGER;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.maintain_detail_values';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   BEGIN
      SELECT analytical_detail_value_id
        INTO l_detail_value_id
        FROM xla_analytical_dtl_vals
       WHERE analytical_criterion_code      = p_anacri_code
         AND analytical_criterion_type_code = p_anacri_type_code
         AND amb_context_code               = p_amb_context_code
         --Detail 1
         AND NVL( analytical_detail_char_1
                 ,NVL( TO_CHAR( analytical_detail_date_1
                               ,'J'||'.'||'HH24MISS'
                              )
                      ,NVL( TO_CHAR( analytical_detail_number_1
                                    ,'TM'
                                    ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                   )
                           ,'%'
                          )
                     )
                )
             = NVL( p_detail_char_1
                   ,NVL( TO_CHAR( p_detail_date_1
                                 ,'J'||'.'||'HH24MISS'
                                )
                        ,NVL( TO_CHAR( p_detail_number_1
                                      ,'TM'
                                      ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                     )
                             ,'%'
                            )
                       )
                  )
         --Detail 2
         AND NVL( analytical_detail_char_2
                 ,NVL( TO_CHAR( analytical_detail_date_2
                               ,'J'||'.'||'HH24MISS'
                              )
                      ,NVL( TO_CHAR( analytical_detail_number_2
                                    ,'TM'
                                    ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                   )
                           ,'%'
                          )
                     )
                )
             = NVL( p_detail_char_2
                   ,NVL( TO_CHAR( p_detail_date_2
                                 ,'J'||'.'||'HH24MISS'
                                )
                        ,NVL( TO_CHAR( p_detail_number_2
                                      ,'TM'
                                      ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                     )
                             ,'%'
                            )
                       )
                  )
         --Detail 3
         AND NVL( analytical_detail_char_3
                 ,NVL( TO_CHAR( analytical_detail_date_3
                               ,'J'||'.'||'HH24MISS'
                              )
                      ,NVL( TO_CHAR( analytical_detail_number_3
                                    ,'TM'
                                    ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                   )
                           ,'%'
                          )
                     )
                )
             = NVL( p_detail_char_3
                   ,NVL( TO_CHAR( p_detail_date_3
                                 ,'J'||'.'||'HH24MISS'
                                )
                        ,NVL( TO_CHAR( p_detail_number_3
                                      ,'TM'
                                      ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                     )
                             ,'%'
                            )
                       )
                  )
         --Detail 4
         AND NVL( analytical_detail_char_4
                 ,NVL( TO_CHAR( analytical_detail_date_4
                               ,'J'||'.'||'HH24MISS'
                              )
                      ,NVL( TO_CHAR( analytical_detail_number_4
                                    ,'TM'
                                    ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                   )
                           ,'%'
                          )
                     )
                )
             = NVL( p_detail_char_4
                   ,NVL( TO_CHAR( p_detail_date_4
                                 ,'J'||'.'||'HH24MISS'
                                )
                        ,NVL( TO_CHAR( p_detail_number_4
                                      ,'TM'
                                      ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                     )
                             ,'%'
                            )
                       )
                  )
         --Detail 5
         AND NVL( analytical_detail_char_5
                 ,NVL( TO_CHAR( analytical_detail_date_5
                               ,'J'||'.'||'HH24MISS'
                              )
                      ,NVL( TO_CHAR( analytical_detail_number_5
                                    ,'TM'
                                    ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                   )
                           ,'%'
                          )
                     )
                )
             = NVL( p_detail_char_5
                   ,NVL( TO_CHAR( p_detail_date_5
                                 ,'J'||'.'||'HH24MISS'
                                )
                        ,NVL( TO_CHAR( p_detail_number_5
                                      ,'TM'
                                      ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                     )
                             ,'%'
                            )
                       )
                  )
      ;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => SQL%ROWCOUNT
                           || ' row(s) selected from xla_analytical_dtl_vals '
             ,p_level    => C_LEVEL_STATEMENT);
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_detail_value_id := NULL;
   END;

   IF l_detail_value_id IS NULL
   THEN
      l_detail_value_id :=  insert_detail_value
                     ( p_anacri_code         => p_anacri_code
                      ,p_anacri_type_code    => p_anacri_type_code
                      ,p_amb_context_code    => p_amb_context_code
                      ,p_detail_char_1       => p_detail_char_1
                      ,p_detail_char_2       => p_detail_char_2
                      ,p_detail_char_3       => p_detail_char_3
                      ,p_detail_char_4       => p_detail_char_4
                      ,p_detail_char_5       => p_detail_char_5
                      ,p_detail_date_1       => p_detail_date_1
                      ,p_detail_date_2       => p_detail_date_2
                      ,p_detail_date_3       => p_detail_date_3
                      ,p_detail_date_4       => p_detail_date_4
                      ,p_detail_date_5       => p_detail_date_5
                      ,p_detail_number_1     => p_detail_number_1
                      ,p_detail_number_2     => p_detail_number_2
                      ,p_detail_number_3     => p_detail_number_3
                      ,p_detail_number_4     => p_detail_number_4
                      ,p_detail_number_5     => p_detail_number_5
                     );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_detail_value_id;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.maintain_detail_values');
END maintain_detail_values;


PROCEDURE insert_header_detail
  ( p_ae_header_id               IN INTEGER
   ,p_analytical_detail_value_id IN INTEGER
  )
IS
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
|  Inserts a new record in the table xla_ae_header_details.             |
|                                                                       |
+======================================================================*/
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_header_detail';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   INSERT INTO xla_ae_header_details
      ( ae_header_id
       ,analytical_detail_value_id
      )
   VALUES
      ( p_ae_header_id
       ,p_analytical_detail_value_id
      );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => SQL%ROWCOUNT ||
                        ' row(s) inserted into xla_ae_headers_details '
          ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.insert_header_detail');
END insert_header_detail;


PROCEDURE insert_line_detail
  ( p_ae_header_id               IN INTEGER
   ,p_ae_line_num                IN INTEGER
   ,p_analytical_detail_value_id IN INTEGER
  )
IS
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Inserts a new record in the table xla_ae_line_details                 |
|                                                                       |
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
+======================================================================*/
l_log_module                 VARCHAR2 (2000);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_line_detail';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   INSERT INTO xla_ae_line_details
      ( ae_header_id
       ,ae_line_num
       ,analytical_detail_value_id
      )
   VALUES
      ( p_ae_header_id
       ,p_ae_line_num
       ,p_analytical_detail_value_id
      );

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => SQL%ROWCOUNT ||
                        ' row(s) inserted into xla_ae_line_details '
          ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.insert_line_detail');
END insert_line_detail;


PROCEDURE delete_line_details
  ( p_ae_header_id               IN INTEGER
   ,p_ae_line_num                IN INTEGER
   ,p_analytical_detail_value_id IN INTEGER
  )
IS
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Deletes one or all (if none specified) of the line details of a       |
| journal entry line.
|                                                                       |
| Open issues                                                           |
| -----------                                                           |
+======================================================================*/

l_details_count INTEGER;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.delete_line_details';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --If p_analytical_detail_value_id is null
   IF p_analytical_detail_value_id IS NULL
   THEN
      --Remove all the line details
      DELETE
        FROM xla_ae_line_details
       WHERE ae_header_id               = p_ae_header_id
         AND ae_line_num                = p_ae_line_num;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => SQL%ROWCOUNT
                           || ' row(s) deleted from xla_ae_line_details'
             ,p_level    => C_LEVEL_STATEMENT);
      END IF;

   --Else (p_analytical_detail_value_id is not null)
   ELSE
      --Remove only the detail specified
      DELETE
        FROM xla_ae_line_details
       WHERE ae_header_id               = p_ae_header_id
         AND ae_line_num                = p_ae_line_num
         AND analytical_detail_value_id = p_analytical_detail_value_id;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => SQL%ROWCOUNT
                           || ' row(s) deleted from xla_ae_line_details'
             ,p_level    => C_LEVEL_STATEMENT);
      END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.delete_line_details');
END delete_line_details;


FUNCTION add_criterion
  ( p_application_id                     IN INTEGER
   ,p_ae_header_id                       IN INTEGER
   ,p_ae_line_num                        IN INTEGER
   ,p_anacri_code                        IN VARCHAR2
   ,p_anacri_type_code                   IN VARCHAR2
   ,p_amb_context_code                   IN VARCHAR2
   ,p_detail_char_1                      IN VARCHAR2
   ,p_detail_char_2                      IN VARCHAR2
   ,p_detail_char_3                      IN VARCHAR2
   ,p_detail_char_4                      IN VARCHAR2
   ,p_detail_char_5                      IN VARCHAR2
   ,p_detail_date_1                      IN DATE
   ,p_detail_date_2                      IN DATE
   ,p_detail_date_3                      IN DATE
   ,p_detail_date_4                      IN DATE
   ,p_detail_date_5                      IN DATE
   ,p_detail_number_1                    IN NUMBER
   ,p_detail_number_2                    IN NUMBER
   ,p_detail_number_3                    IN NUMBER
   ,p_detail_number_4                    IN NUMBER
   ,p_detail_number_5                    IN NUMBER
  )
RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|  Obsolete in R12+ Supporting References Re-Architecture               |
| Description                                                           |
| -----------                                                           |
| Adds a criterion to a journal entry header or line.                   |
| If p_ae_line_num is null the criterion is added to the header         |
| otherwise to the line.                                                |
| If one or more lines have already contributed to analytical balances  |
| their contribution is removed from control and analytical balances.   |
|                                                                       |
+======================================================================*/

   CURSOR lc_lock_ae_line_details
                ( cp_ae_header_id   INTEGER
                 ,cp_ae_line_num    INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_line_details  xald
       WHERE xald.ae_header_id     = cp_ae_header_id
         AND xald.ae_line_num      = cp_ae_line_num
      FOR UPDATE NOWAIT;

l_balancing_flag            VARCHAR2(1);
l_detail_value_id           INTEGER;
l_analytical_balance_flag   VARCHAR2(1);
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.add_criterion';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_application_id:'   || p_application_id
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_ae_header_id:'     || p_ae_header_id
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_anacri_code:'      || p_anacri_code
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_anacri_type_code:' || p_anacri_type_code
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_amb_context_code:' || p_amb_context_code
          ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF p_application_id   IS NULL
   OR p_ae_header_id     IS NULL
   OR p_anacri_code      IS NULL
   OR p_anacri_type_code IS NULL
   OR p_amb_context_code IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:'
                           || 'p_application_id,p_ae_header_id,p_anacri_code,'
                           || 'p_anacri_type_code, p_amb_context_code'
                           || 'cannot be NULL '
             ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.add_criterion');
   END IF;

   SELECT xah.balancing_flag
     INTO l_balancing_flag
     FROM xla_analytical_hdrs_b xah
    WHERE xah.analytical_criterion_code      = p_anacri_code
      AND xah.analytical_criterion_type_code = p_anacri_type_code
      AND xah.amb_context_code               = p_amb_context_code
      AND xah.enabled_flag                   = 'Y';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => 'balancing_flag from xla_analytical_hdrs_b:'
                           || l_balancing_flag
             ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF p_ae_line_num IS NULL
   THEN
      --Retrieve/Create the detail value
      l_detail_value_id := get_detail_value_id
                    ( p_anacri_code            => p_anacri_code
                     ,p_anacri_type_code       => p_anacri_type_code
                     ,p_amb_context_code       => p_amb_context_code
                     ,p_detail_char_1          => p_detail_char_1
                     ,p_detail_char_2          => p_detail_char_2
                     ,p_detail_char_3          => p_detail_char_3
                     ,p_detail_char_4          => p_detail_char_4
                     ,p_detail_char_5          => p_detail_char_5
                     ,p_detail_date_1          => p_detail_date_1
                     ,p_detail_date_2          => p_detail_date_2
                     ,p_detail_date_3          => p_detail_date_3
                     ,p_detail_date_4          => p_detail_date_4
                     ,p_detail_date_5          => p_detail_date_5
                     ,p_detail_number_1        => p_detail_number_1
                     ,p_detail_number_2        => p_detail_number_2
                     ,p_detail_number_3        => p_detail_number_3
                     ,p_detail_number_4        => p_detail_number_4
                     ,p_detail_number_5        => p_detail_number_5
                    );

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'l_detail_value_id: ' || l_detail_value_id
             ,p_level    => C_LEVEL_STATEMENT);
      END IF;

      insert_header_detail
              ( p_ae_header_id               => p_ae_header_id
               ,p_analytical_detail_value_id => l_detail_value_id
              );
   ELSE --p_ae_line_num IS NOT NULL
      IF l_balancing_flag = 'Y'
      THEN
         OPEN lc_lock_ae_line_details
                  ( cp_ae_header_id   => p_ae_header_id
                   ,cp_ae_line_num    => p_ae_line_num
                  );
         CLOSE lc_lock_ae_line_details;

         SELECT xal.analytical_balance_flag
           INTO l_analytical_balance_flag
           FROM xla_ae_lines xal
          WHERE xal.application_id = p_application_id
            AND xal.ae_header_id   = p_ae_header_id
            AND xal.ae_line_num    = p_ae_line_num;

         IF l_analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_DONE
         THEN
            IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
		IF NOT xla_balances_pkg.single_update
		  ( p_application_id       => p_application_id
		   ,p_ae_header_id         => p_ae_header_id
		   ,p_ae_line_num          => p_ae_line_num
		   ,p_update_mode          => 'D'
		  )
		THEN
		   IF (C_LEVEL_ERROR >= g_log_level) THEN
		  trace
		    ( p_module   => l_log_module
		     ,p_msg      => 'Balance removal unsuccessful'
		     ,p_level    => C_LEVEL_ERROR);
		  trace
		    ( p_module   => l_log_module
		     ,p_msg      => 'Cannot remove the details'
		     ,p_level    => C_LEVEL_ERROR);
		   END IF;
		   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		  trace
		     ( p_module   => l_log_module
		      ,p_msg      => 'END ' || l_log_module
		      ,p_level    => C_LEVEL_PROCEDURE);
		   END IF;
		   RETURN FALSE;
		END IF;
		ELSE
		   IF NOT xla_balances_calc_pkg.single_update
			  ( p_application_id       => p_application_id
			   ,p_ae_header_id         => p_ae_header_id
			   ,p_ae_line_num          => p_ae_line_num
			   ,p_update_mode          => 'D'
			  )
		   THEN
		      IF (C_LEVEL_ERROR >= g_log_level) THEN
			   trace
				( p_module   => l_log_module
				 ,p_msg      => 'Balance removal unsuccessful'
				 ,p_level    => C_LEVEL_ERROR);
			    trace
				( p_module   => l_log_module
				 ,p_msg      => 'Cannot remove the details'
				 ,p_level    => C_LEVEL_ERROR);
		      END IF;
		      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			  trace
				 ( p_module   => l_log_module
				  ,p_msg      => 'END ' || l_log_module
				  ,p_level    => C_LEVEL_PROCEDURE);
		      END IF;
		   RETURN FALSE;
		END IF;
	    END IF;
         END IF; --l_analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_DONE
      END IF; --l_balancing_flag = 'Y'

      --Retrieve/Create the detail value
      l_detail_value_id := get_detail_value_id
                    ( p_anacri_code              => p_anacri_code
                     ,p_anacri_type_code         => p_anacri_type_code
                     ,p_amb_context_code         => p_amb_context_code
                     ,p_detail_char_1            => p_detail_char_1
                     ,p_detail_char_2            => p_detail_char_2
                     ,p_detail_char_3            => p_detail_char_3
                     ,p_detail_char_4            => p_detail_char_4
                     ,p_detail_char_5            => p_detail_char_5
                     ,p_detail_date_1            => p_detail_date_1
                     ,p_detail_date_2            => p_detail_date_2
                     ,p_detail_date_3            => p_detail_date_3
                     ,p_detail_date_4            => p_detail_date_4
                     ,p_detail_date_5            => p_detail_date_5
                     ,p_detail_number_1          => p_detail_number_1
                     ,p_detail_number_2          => p_detail_number_2
                     ,p_detail_number_3          => p_detail_number_3
                     ,p_detail_number_4          => p_detail_number_4
                     ,p_detail_number_5          => p_detail_number_5
                    );

      insert_line_detail
              ( p_ae_header_id               => p_ae_header_id
               ,p_ae_line_num                => p_ae_line_num
               ,p_analytical_detail_value_id => l_detail_value_id
              );

      IF l_balancing_flag = 'Y'
      THEN
         UPDATE xla_ae_lines xal
            SET xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_PEND
          WHERE xal.application_id = p_application_id
            AND xal.ae_header_id   = p_ae_header_id
            AND xal.ae_line_num    = p_ae_line_num;
      END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.add_criterion');

END add_criterion;


/*======================================================================+
|                                                                       |
| Private Function                                                      |
| Added for R12+ Supporting Reference Re-Architecture                   |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| If one or more lines have already contributed to analytical balances  |
| their contribution is removed from control and analytical balances.   |
|                                                                       |
+======================================================================*/
FUNCTION add_criterion
  ( p_application_id                     IN INTEGER
   ,p_ae_header_id                       IN INTEGER
   ,p_ae_line_num                        IN INTEGER
   ,p_anacri_code                        IN VARCHAR2
   ,p_anacri_type_code                   IN VARCHAR2
   ,p_amb_context_code                   IN VARCHAR2
  )
RETURN BOOLEAN
IS

   CURSOR lc_lock_ae_line_details
                ( cp_ae_header_id   INTEGER
                 ,cp_ae_line_num    INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_line_acs  xald
       WHERE xald.ae_header_id     = cp_ae_header_id
         AND xald.ae_line_num      = cp_ae_line_num
      FOR UPDATE NOWAIT;

l_balancing_flag            VARCHAR2(1);
l_detail_value_id           INTEGER;
l_analytical_balance_flag   VARCHAR2(1);
l_log_module                VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.add_criterion';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_application_id:'   || p_application_id
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_ae_header_id:'     || p_ae_header_id
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_anacri_code:'      || p_anacri_code
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_anacri_type_code:' || p_anacri_type_code
          ,p_level    => C_LEVEL_STATEMENT);
      trace
         ( p_module   => l_log_module
          ,p_msg      => 'p_amb_context_code:' || p_amb_context_code
          ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF p_application_id   IS NULL
   OR p_ae_header_id     IS NULL
   OR p_anacri_code      IS NULL
   OR p_anacri_type_code IS NULL
   OR p_amb_context_code IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'EXCEPTION:'
                           || 'p_application_id,p_ae_header_id,p_anacri_code,'
                           || 'p_anacri_type_code, p_amb_context_code'
                           || 'cannot be NULL '
             ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.add_criterion');
   END IF;

   SELECT xah.balancing_flag
     INTO l_balancing_flag
     FROM xla_analytical_hdrs_b xah
    WHERE xah.analytical_criterion_code      = p_anacri_code
      AND xah.analytical_criterion_type_code = p_anacri_type_code
      AND xah.amb_context_code               = p_amb_context_code
      AND xah.enabled_flag                   = 'Y';

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
            ( p_module   => l_log_module
             ,p_msg      => 'balancing_flag from xla_analytical_hdrs_b:'
                           || l_balancing_flag
             ,p_level    => C_LEVEL_STATEMENT);
   END IF;

   IF p_ae_line_num IS NOT NULL THEN
      IF l_balancing_flag = 'Y'
      THEN
         OPEN lc_lock_ae_line_details
                  ( cp_ae_header_id   => p_ae_header_id
                   ,cp_ae_line_num    => p_ae_line_num
                  );
         CLOSE lc_lock_ae_line_details;

         SELECT xal.analytical_balance_flag
           INTO l_analytical_balance_flag
           FROM xla_ae_lines xal
          WHERE xal.application_id = p_application_id
            AND xal.ae_header_id   = p_ae_header_id
            AND xal.ae_line_num    = p_ae_line_num;

         IF l_analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_DONE
         THEN
	    IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
	       IF NOT xla_balances_pkg.single_update
		  ( p_application_id       => p_application_id
		   ,p_ae_header_id         => p_ae_header_id
		   ,p_ae_line_num          => p_ae_line_num
		   ,p_update_mode          => 'D'
		  )
	       THEN
	          IF (C_LEVEL_ERROR >= g_log_level) THEN
		     trace
		       ( p_module   => l_log_module
		        ,p_msg      => 'Balance removal unsuccessful'
		        ,p_level    => C_LEVEL_ERROR);
		     trace
		       ( p_module   => l_log_module
		        ,p_msg      => 'Cannot remove the details'
		        ,p_level    => C_LEVEL_ERROR);
	          END IF;
	          IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		     trace
		        ( p_module   => l_log_module
		         ,p_msg      => 'END ' || l_log_module
		         ,p_level    => C_LEVEL_PROCEDURE);
	          END IF;
	          RETURN FALSE;
	       END IF;
	       ELSE
		IF NOT xla_balances_calc_pkg.single_update
		  ( p_application_id       => p_application_id
		   ,p_ae_header_id         => p_ae_header_id
		   ,p_ae_line_num          => p_ae_line_num
		   ,p_update_mode          => 'D'
		  )
		THEN
		IF (C_LEVEL_ERROR >= g_log_level) THEN
		  trace
			( p_module   => l_log_module
			 ,p_msg      => 'Balance removal unsuccessful'
			 ,p_level    => C_LEVEL_ERROR);
			  trace
			( p_module   => l_log_module
			 ,p_msg      => 'Cannot remove the details'
			 ,p_level    => C_LEVEL_ERROR);
		END IF;
		IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		  trace
			( p_module   => l_log_module
			 ,p_msg      => 'END ' || l_log_module
			 ,p_level    => C_LEVEL_PROCEDURE);
		END IF;
		RETURN FALSE;
	       END IF;
	   END IF;
         END IF; --l_analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_DONE
      END IF; --l_balancing_flag = 'Y'

      IF l_balancing_flag = 'Y'
      THEN
         UPDATE xla_ae_lines xal
            SET xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_PEND
          WHERE xal.application_id = p_application_id
            AND xal.ae_header_id   = p_ae_header_id
            AND xal.ae_line_num    = p_ae_line_num;
      END IF;

   ELSE -- IF p_ae_line_num IS NOT NULL THEN
      --
      -- Do nothing for header supporting references
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg      => 'No balance update for headers.'
             ,p_level    => C_LEVEL_STATEMENT);
      END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.add_criterion');

END add_criterion;


FUNCTION remove_criterion
  ( p_application_id                     IN INTEGER
   ,p_ae_header_id                       IN INTEGER
   ,p_ae_line_num                        IN INTEGER
   ,p_anacri_code                        IN VARCHAR2
   ,p_anacri_type_code                   IN VARCHAR2
   ,p_amb_context_code                   IN VARCHAR2
   ,p_analytical_detail_value_id         IN INTEGER
  )

RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Private Function                                                      |
| Obsolete in R12+ Re-Architecture. Refer to the override function      |                                                            |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Removes one or all the criteria from a journal entry header or line.  |
| If p_ae_header_id, p_ae_line_num and p_analytical_detail_value_id     |
| are null ALL header and line details are removed.                     |
| If p_ae_line_num is null and p_ae_header_id is not null header        |
| details are affected.                                                 |
| If p_ae_line_num is not null line details are affected.               |
| If p_analytical_detail_value_id is not null, only that specific       |
| detail value is affected.                                             |
| If one or more lines have already contributed to analytical balances  |
| their contribution is removed from control and analytical balances.   |
+======================================================================*/

   CURSOR lc_lock_ae_header_details
                ( cp_ae_header_id   INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_header_details xahd
       WHERE xahd.ae_header_id     = cp_ae_header_id
      FOR UPDATE NOWAIT;

   CURSOR lc_lock_ae_header_detail
                ( cp_ae_header_id               INTEGER
                 ,cp_analytical_detail_value_id INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_header_details xahd
       WHERE xahd.ae_header_id               = cp_ae_header_id
         AND xahd.analytical_detail_value_id = cp_analytical_detail_value_id
      FOR UPDATE NOWAIT;


   CURSOR lc_lock_ae_lines_and_details
                ( cp_ae_header_id   INTEGER
                 ,cp_application_id INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_lines         xal
            ,xla_ae_line_details  xald
       WHERE xal.ae_header_id     = cp_ae_header_id
         AND xal.application_id   = cp_application_id
         AND xald.ae_header_id    = xal.ae_header_id
      FOR UPDATE NOWAIT;


   CURSOR lc_lock_ae_line_details
                ( cp_ae_header_id   INTEGER
                 ,cp_ae_line_num    INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_line_details  xald
       WHERE xald.ae_header_id     = cp_ae_header_id
         AND xald.ae_line_num      = cp_ae_line_num
      FOR UPDATE NOWAIT;

l_accounting_line_type_code   VARCHAR2(1);
l_balancing_flag              VARCHAR2(1);
l_analytical_balance_flag     VARCHAR2(1);
l_detail_value_id             INTEGER;
l_balanced_lined_count        INTEGER;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.remove_criterion';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_anacri_code IS NULL
   THEN
      IF p_ae_header_id IS NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'p_anacri_code and p_header_id cannot be both NULL'
               ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
            (p_location => 'xla_analytical_criteria_pkg.remove_criterion');
      ELSE
         IF p_ae_line_num IS NULL
         THEN
            IF p_analytical_detail_value_id IS NULL
            THEN
               --All header and line criteria must be removed
               OPEN lc_lock_ae_header_details
                         ( cp_ae_header_id   => p_ae_header_id
                         );
               CLOSE lc_lock_ae_header_details;

               OPEN lc_lock_ae_lines_and_details
                         ( cp_ae_header_id   => p_ae_header_id
                          ,cp_application_id => p_application_id
                         );
               CLOSE lc_lock_ae_lines_and_details;

               SELECT COUNT(*)
                 INTO l_balanced_lined_count
                 FROM xla_ae_lines xal
                WHERE xal.application_id          = p_application_id
                  AND xal.ae_header_id            = p_ae_header_id
                  AND xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_DONE;

               IF l_balanced_lined_count > 0
               THEN
		 IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
		     IF NOT xla_balances_pkg.single_update
		       ( p_application_id       => p_application_id
		        ,p_ae_header_id         => p_ae_header_id
		        ,p_ae_line_num          => NULL
		        ,p_update_mode          => 'D'
		       )
		    THEN
		       IF (C_LEVEL_ERROR >= g_log_level) THEN
		          trace
			    ( p_module   => l_log_module
			     ,p_msg      => 'Balance removal unsuccessful'
			     ,p_level    => C_LEVEL_ERROR);
		          trace
			    ( p_msg      => 'Cannot remove the details'
			     ,p_level    => C_LEVEL_ERROR);
		       END IF;
		       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
		          trace
		          (p_module   => l_log_module
		          ,p_msg      => 'END ' || l_log_module
		          ,p_level    => C_LEVEL_PROCEDURE);
		       END IF;

		       RETURN FALSE;
		    END IF;
		 ELSE
		       IF NOT xla_balances_calc_pkg.single_update
			   ( p_application_id       => p_application_id
			    ,p_ae_header_id         => p_ae_header_id
			    ,p_ae_line_num          => NULL
			    ,p_update_mode          => 'D'
			    )
			THEN
			    IF (C_LEVEL_ERROR >= g_log_level) THEN
			        trace
				  ( p_module   => l_log_module
				   ,p_msg      => 'Balance removal unsuccessful'
				   ,p_level    => C_LEVEL_ERROR);
				trace
				  ( p_msg      => 'Cannot remove the details'
				   ,p_level    => C_LEVEL_ERROR);
			    END IF;
			    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			         trace
				   (p_module   => l_log_module
				   ,p_msg      => 'END ' || l_log_module
				   ,p_level    => C_LEVEL_PROCEDURE);
			    END IF;

			    RETURN FALSE;
		       END IF;
		 END IF;
               END IF; --l_balanced_lined_count > 0

               --delete all the header details
               DELETE
                 FROM xla_ae_header_details xhd
                WHERE xhd.ae_header_id = p_ae_header_id;
               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    ( p_module   => l_log_module
                     ,p_msg   => SQL%ROWCOUNT
                                 || ' row(s) deleted from xla_ae_header_details'
                     ,p_level => C_LEVEL_STATEMENT);
               END IF;

               --loop on all the journal entry lines
               FOR i IN (
                         SELECT xal.ae_line_num
                           FROM xla_ae_headers xah
                               ,xla_ae_lines   xal
                          WHERE xah.application_id   = p_application_id
                            AND xah.ae_header_id     = p_ae_header_id
                            AND xal.application_id   = xah.application_id
                            AND xal.ae_header_id     = xah.ae_header_id
                        )
               LOOP
                  --call delete_line_details
                  delete_line_details
                     ( p_ae_header_id               => p_ae_header_id
                      ,p_ae_line_num                => i.ae_line_num
                      ,p_analytical_detail_value_id => NULL
                     );
               END LOOP;

               --update the balance flag of the lines to NULL
               UPDATE xla_ae_lines xal
                  SET xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_NO
                WHERE xal.application_id          = p_application_id
                  AND xal.ae_header_id            = p_ae_header_id;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    ( p_module   => l_log_module
                     ,p_msg   => SQL%ROWCOUNT
                                 || ' row(s) updated to '
                                 || NVL(C_ANALYTICAL_BAL_FLAG_NO, 'NULL')
                                 || ' in xla_ae_lines'
                     ,p_level => C_LEVEL_STATEMENT);
               END IF;

            ELSE --p_analytical_detail_value_id IS NOT NULL
               OPEN lc_lock_ae_header_detail

        ( cp_ae_header_id               => p_ae_header_id
         ,cp_analytical_detail_value_id => p_analytical_detail_value_id
        );
               CLOSE lc_lock_ae_header_detail;

               --delete the specified header detail
               DELETE
                 FROM xla_ae_header_details xahd
                WHERE xahd.ae_header_id               = p_ae_header_id
                  AND xahd.analytical_detail_value_id = p_analytical_detail_value_id;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    ( p_module   => l_log_module
                     ,p_msg   => SQL%ROWCOUNT
                                 || ' row(s) deleted from xla_ae_header_details'
                     ,p_level => C_LEVEL_STATEMENT);
               END IF;
            END IF;

         ELSE --p_ae_line_num IS NOT NULL

            OPEN lc_lock_ae_line_details
                  ( cp_ae_header_id   => p_ae_header_id
                   ,cp_ae_line_num    => p_ae_line_num
                  );

            CLOSE lc_lock_ae_line_details;

            SELECT xal.analytical_balance_flag
              INTO l_analytical_balance_flag
              FROM xla_ae_lines xal
             WHERE xal.application_id = p_application_id
               AND xal.ae_header_id   = p_ae_header_id
               AND xal.ae_line_num    = p_ae_line_num;

            IF l_analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_DONE
            THEN
               IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
		   IF NOT xla_balances_pkg.single_update
			 ( p_application_id       => p_application_id
			  ,p_ae_header_id         => p_ae_header_id
			  ,p_ae_line_num          => p_ae_line_num
			  ,p_update_mode          => 'D'
			 )
		   THEN
			 IF (C_LEVEL_ERROR >= g_log_level) THEN
			    trace
			( p_module   => l_log_module
			 ,p_msg   => 'Balance removal unsuccessful.'
				     || 'Cannot remove the details.'
			 ,p_level => C_LEVEL_ERROR
			);
			 END IF;
			 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			    trace
			(p_module   => l_log_module
			,p_msg      => 'END ' || l_log_module
			,p_level    => C_LEVEL_PROCEDURE);
			 END IF;
			 RETURN FALSE;
		   END IF;
		ELSE
		    IF NOT xla_balances_calc_pkg.single_update
			  ( p_application_id       => p_application_id
			   ,p_ae_header_id         => p_ae_header_id
			   ,p_ae_line_num          => p_ae_line_num
			   ,p_update_mode          => 'D'
			  )
			  THEN
			  IF (C_LEVEL_ERROR >= g_log_level) THEN
				 trace
					( p_module   => l_log_module
					 ,p_msg   => 'Balance removal unsuccessful.'
								 || 'Cannot remove the details.'
					 ,p_level => C_LEVEL_ERROR
					);
			  END IF;
			  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				 trace
					(p_module   => l_log_module
					,p_msg      => 'END ' || l_log_module
					,p_level    => C_LEVEL_PROCEDURE);
			  END IF;
			  RETURN FALSE;
			  END IF;
		END IF;
            END IF;

            IF p_analytical_detail_value_id IS NULL
            THEN
               --delete all the line details of the line
               delete_line_details
                     ( p_ae_header_id               => p_ae_header_id
                      ,p_ae_line_num                => p_ae_line_num
                      ,p_analytical_detail_value_id => NULL
                     );

               UPDATE xla_ae_lines xal
                  SET xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_NO
                WHERE xal.application_id          = p_application_id
                  AND xal.ae_header_id            = p_ae_header_id
                  AND xal.ae_line_num              = p_ae_line_num;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    ( p_module   => l_log_module
                     ,p_msg   => SQL%ROWCOUNT
                                 || ' row(s) updated in xla_ae_lines: '
                                 || 'analytical_balance_flag updated to '
                                 || NVL(C_ANALYTICAL_BAL_FLAG_NO, 'NULL')
                     ,p_level => C_LEVEL_STATEMENT
                    );
               END IF;

            ELSE --p_analytical_detail_value_id IS NOT NULL

               --delete the specified line detail
               delete_line_details
                     ( p_ae_header_id               => p_ae_header_id
                      ,p_ae_line_num                => p_ae_line_num
                      ,p_analytical_detail_value_id => p_analytical_detail_value_id
                     );

               --set balance flag for the line to NULL if no details left
--disregarded indentation for readability
   UPDATE xla_ae_lines xal
      SET xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_NO
    WHERE xal.application_id          = p_application_id
      AND xal.ae_header_id            = p_ae_header_id
      AND xal.ae_line_num             = p_ae_line_num
      AND 0 =
(
SELECT count(xald.ae_line_num)
  FROM xla_ae_line_details     xald
      ,xla_analytical_dtl_vals xadv
      ,xla_analytical_hdrs_b   xahb
 WHERE xald.ae_header_id                    = p_ae_header_id
AND xald.ae_line_num                     = p_ae_line_num
AND xadv.analytical_detail_value_id      = xald.analytical_detail_value_id
AND xahb.amb_context_code                = xadv.amb_context_code
AND xahb.analytical_criterion_code       = xadv.analytical_criterion_code
AND xahb.analytical_criterion_type_code  = xadv.analytical_criterion_type_code
AND xahb.balancing_flag                  = 'Y'
);

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    ( p_module   => l_log_module
                     ,p_msg   => SQL%ROWCOUNT
                                 || ' row(s) updated in xla_ae_lines: '
                                 || 'analytical_balance_flag updated to '
                                 || NVL(C_ANALYTICAL_BAL_FLAG_NO, 'NULL')
                     ,p_level => C_LEVEL_STATEMENT
                    );
               END IF;

            END IF;--p_analytical_detail_value_id IS NULL
         END IF;--p_ae_line_num IS NULL
      END IF; --p_ae_header_id IS NULL
   ELSE --p_anacri_code IS NOT NULL
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'p_anacri_code NOT NULL currently supported.'
                ,p_level => C_LEVEL_EXCEPTION
               );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.remove_criterion');
   END IF; --p_anacri_code IS NOT NULL

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN le_resource_busy
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
        ( p_module   => l_log_module
         ,p_msg      => 'EXCEPTION:'
                           ||'Unable to lock the records'
         ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.remove_criterion');

END remove_criterion;

FUNCTION remove_criterion
  ( p_application_id                     IN INTEGER
   ,p_ae_header_id                       IN INTEGER
   ,p_ae_line_num                        IN INTEGER
   ,p_anacri_code                        IN VARCHAR2
   ,p_anacri_type_code                   IN VARCHAR2
   ,p_amb_context_code                   IN VARCHAR2
   ,p_ac1                                IN VARCHAR2
   ,p_ac2                                IN VARCHAR2
   ,p_ac3                                IN VARCHAR2
   ,p_ac4                                IN VARCHAR2
   ,p_ac5                                IN VARCHAR2
  )

RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Private Function                                                      |
| Added for R12+ Re-Architecture. Refer to the override function        |                                                            |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| If p_ac<N> is not null, only that specific  detail value is affected. |                                            |
| If one or more lines have already contributed to analytical balances  |
| their contribution is removed from control and analytical balances.   |
+======================================================================*/

   CURSOR lc_lock_ae_header_details
                ( cp_ae_header_id   INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_header_acs xahd
       WHERE xahd.ae_header_id     = cp_ae_header_id
      FOR UPDATE NOWAIT;

   CURSOR lc_lock_ae_header_detail
                ( cp_ae_header_id               INTEGER
                 ,cp_anacri_code                VARCHAR2
                 ,cp_anacri_type_code           VARCHAR2
                 ,cp_amb_context_code           VARCHAR2
                )
   IS
      SELECT 1
        FROM xla_ae_header_acs xahd
       WHERE xahd.ae_header_id              = cp_ae_header_id
         AND xahd.analytical_criterion_code = cp_anacri_code
         AND xahd.analytical_criterion_type_code = cp_anacri_type_code
         AND xahd.amb_context_code = cp_amb_context_code

      FOR UPDATE NOWAIT;


   CURSOR lc_lock_ae_lines_and_details
                ( cp_ae_header_id   INTEGER
                 ,cp_application_id INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_lines         xal
            ,xla_ae_line_acs  xald
       WHERE xal.ae_header_id     = cp_ae_header_id
         AND xal.application_id   = cp_application_id
         AND xald.ae_header_id    = xal.ae_header_id
      FOR UPDATE NOWAIT;


   CURSOR lc_lock_ae_line_details
                ( cp_ae_header_id   INTEGER
                 ,cp_ae_line_num    INTEGER
                )
   IS
      SELECT 1
        FROM xla_ae_line_acs  xald
       WHERE xald.ae_header_id     = cp_ae_header_id
         AND xald.ae_line_num      = cp_ae_line_num
      FOR UPDATE NOWAIT;

l_accounting_line_type_code   VARCHAR2(1);
l_balancing_flag              VARCHAR2(1);
l_analytical_balance_flag     VARCHAR2(1);
l_detail_value_id             INTEGER;
l_balanced_lined_count        INTEGER;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.remove_criterion';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_anacri_code IS NULL
   THEN
      IF p_ae_header_id IS NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'p_anacri_code and p_header_id cannot be both NULL'
               ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
            (p_location => 'xla_analytical_criteria_pkg.remove_criterion');
      ELSE
         IF p_ae_line_num IS NULL
         THEN
            IF (p_anacri_code IS NULL)
            THEN
               --All header and line criteria must be removed
               OPEN lc_lock_ae_header_details
                         ( cp_ae_header_id   => p_ae_header_id
                         );
               CLOSE lc_lock_ae_header_details;

               OPEN lc_lock_ae_lines_and_details
                         ( cp_ae_header_id   => p_ae_header_id
                          ,cp_application_id => p_application_id
                         );
               CLOSE lc_lock_ae_lines_and_details;

               SELECT COUNT(*)
                 INTO l_balanced_lined_count
                 FROM xla_ae_lines xal
                WHERE xal.application_id          = p_application_id
                  AND xal.ae_header_id            = p_ae_header_id
                  AND xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_DONE;

               IF l_balanced_lined_count > 0
               THEN
	          IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
		     IF NOT xla_balances_pkg.single_update
			   ( p_application_id       => p_application_id
			    ,p_ae_header_id         => p_ae_header_id
			    ,p_ae_line_num          => NULL
			    ,p_update_mode          => 'D'
			   )
			THEN
			   IF (C_LEVEL_ERROR >= g_log_level) THEN
			trace
			  ( p_module   => l_log_module
			   ,p_msg      => 'Balance removal unsuccessful'
			   ,p_level    => C_LEVEL_ERROR);
			trace
			  ( p_msg      => 'Cannot remove the details'
			   ,p_level    => C_LEVEL_ERROR);
			   END IF;
			   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			trace
			(p_module   => l_log_module
			,p_msg      => 'END ' || l_log_module
			,p_level    => C_LEVEL_PROCEDURE);
			   END IF;

			   RETURN FALSE;
		      END IF;
		   ELSE
		      IF NOT xla_balances_calc_pkg.single_update
			 ( p_application_id       => p_application_id
			  ,p_ae_header_id         => p_ae_header_id
			  ,p_ae_line_num          => NULL
			  ,p_update_mode          => 'D'
			 )
			 THEN
			 IF (C_LEVEL_ERROR >= g_log_level) THEN
				trace
				  ( p_module   => l_log_module
				   ,p_msg      => 'Balance removal unsuccessful'
				   ,p_level    => C_LEVEL_ERROR);
				trace
				  ( p_msg      => 'Cannot remove the details'
				   ,p_level    => C_LEVEL_ERROR);
			 END IF;
			 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				trace
				(p_module   => l_log_module
				,p_msg      => 'END ' || l_log_module
				,p_level    => C_LEVEL_PROCEDURE);
			 END IF;

			 RETURN FALSE;
			 END IF;
		   END IF;
               END IF; --l_balanced_lined_count > 0

               --update the balance flag of the lines to NULL
               UPDATE xla_ae_lines xal
                  SET xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_NO
                WHERE xal.application_id          = p_application_id
                  AND xal.ae_header_id            = p_ae_header_id;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    ( p_module   => l_log_module
                     ,p_msg   => SQL%ROWCOUNT
                                 || ' row(s) updated to '
                                 || NVL(C_ANALYTICAL_BAL_FLAG_NO, 'NULL')
                                 || ' in xla_ae_lines'
                     ,p_level => C_LEVEL_STATEMENT);
               END IF;

            END IF;

         ELSE --p_ae_line_num IS NOT NULL

            OPEN lc_lock_ae_line_details
                  ( cp_ae_header_id   => p_ae_header_id
                   ,cp_ae_line_num    => p_ae_line_num
                  );

            CLOSE lc_lock_ae_line_details;

            SELECT xal.analytical_balance_flag
              INTO l_analytical_balance_flag
              FROM xla_ae_lines xal
             WHERE xal.application_id = p_application_id
               AND xal.ae_header_id   = p_ae_header_id
               AND xal.ae_line_num    = p_ae_line_num;

            IF l_analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_DONE
            THEN
		IF fnd_profile.value('XLA_BAL_PARALLEL_MODE') IS NULL THEN
		       IF NOT xla_balances_pkg.single_update
			  ( p_application_id       => p_application_id
			   ,p_ae_header_id         => p_ae_header_id
			   ,p_ae_line_num          => p_ae_line_num
			   ,p_update_mode          => 'D'
			  )
		       THEN
			  IF (C_LEVEL_ERROR >= g_log_level) THEN
			     trace
				( p_module   => l_log_module
				 ,p_msg   => 'Balance removal unsuccessful.'
					     || 'Cannot remove the details.'
				 ,p_level => C_LEVEL_ERROR
				);
			  END IF;
			  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
			     trace
				(p_module   => l_log_module
				,p_msg      => 'END ' || l_log_module
				,p_level    => C_LEVEL_PROCEDURE);
			  END IF;
			  RETURN FALSE;
		       END IF;
		 ELSE
		       IF NOT xla_balances_calc_pkg.single_update
			  ( p_application_id       => p_application_id
			   ,p_ae_header_id         => p_ae_header_id
			   ,p_ae_line_num          => p_ae_line_num
			   ,p_update_mode          => 'D'
			  )
			 THEN
			  IF (C_LEVEL_ERROR >= g_log_level) THEN
				 trace
					( p_module   => l_log_module
					 ,p_msg   => 'Balance removal unsuccessful.'
								 || 'Cannot remove the details.'
					 ,p_level => C_LEVEL_ERROR
					);
			  END IF;
			  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
				 trace
					(p_module   => l_log_module
					,p_msg      => 'END ' || l_log_module
					,p_level    => C_LEVEL_PROCEDURE);
			  END IF;
			  RETURN FALSE;
			END IF;
		END IF;
            END IF;

            IF (p_anacri_code IS NULL)
            THEN

               UPDATE xla_ae_lines xal
                  SET xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_NO
                WHERE xal.application_id          = p_application_id
                  AND xal.ae_header_id            = p_ae_header_id
                  AND xal.ae_line_num             = p_ae_line_num;

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    ( p_module   => l_log_module
                     ,p_msg   => SQL%ROWCOUNT
                                 || ' row(s) updated in xla_ae_lines: '
                                 || 'analytical_balance_flag updated to '
                                 || NVL(C_ANALYTICAL_BAL_FLAG_NO, 'NULL')
                     ,p_level => C_LEVEL_STATEMENT
                    );
               END IF;

            ELSE --p_anacri_code IS NOT NULL

               --set balance flag for the line to NULL if no details left
               --disregarded indentation for readability
               UPDATE xla_ae_lines xal
                  SET xal.analytical_balance_flag = C_ANALYTICAL_BAL_FLAG_NO
                WHERE xal.application_id          = p_application_id
                  AND xal.ae_header_id            = p_ae_header_id
                  AND xal.ae_line_num             = p_ae_line_num
                  AND 0 =
(
SELECT count(xald.ae_line_num)
  FROM xla_ae_line_acs     xald
      ,xla_analytical_hdrs_b   xahb
 WHERE xald.ae_header_id                 = p_ae_header_id
AND xald.ae_line_num                     = p_ae_line_num
AND xahb.amb_context_code                = xald.amb_context_code
AND xahb.analytical_criterion_code       = xald.analytical_criterion_code
AND xahb.analytical_criterion_type_code  = xald.analytical_criterion_type_code
AND xahb.balancing_flag                  = 'Y'
);

               IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                  trace
                    ( p_module   => l_log_module
                     ,p_msg   => SQL%ROWCOUNT
                                 || ' row(s) updated in xla_ae_lines: '
                                 || 'analytical_balance_flag updated to '
                                 || NVL(C_ANALYTICAL_BAL_FLAG_NO, 'NULL')
                     ,p_level => C_LEVEL_STATEMENT
                    );
               END IF;

            END IF;--p_anacri_code IS NULL
         END IF;--p_ae_line_num IS NULL
      END IF; --p_ae_header_id IS NULL
   ELSE --p_anacri_code IS NOT NULL
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'p_anacri_code NOT NULL currently supported.'
                ,p_level => C_LEVEL_EXCEPTION
               );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.remove_criterion');
   END IF; --p_anacri_code IS NOT NULL

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN TRUE;

EXCEPTION
WHEN le_resource_busy
THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
        ( p_module   => l_log_module
         ,p_msg      => 'EXCEPTION:'
                           ||'Unable to lock the records'
         ,p_level    => C_LEVEL_EXCEPTION);
   END IF;
   RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.remove_criterion');

END remove_criterion;

FUNCTION update_detail_value ( p_application_id   IN INTEGER
                              ,p_ae_header_id     IN INTEGER
                              ,p_ae_line_num      IN INTEGER
                              ,p_list_of_criteria IN OUT NOCOPY t_list_of_criteria
                              ,p_update_mode      IN VARCHAR2
                             )
RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Refer to the Detail Level Design document                             |
+======================================================================*/

CURSOR lc_lock_ae_header
                ( cp_application_id INTEGER
                 ,cp_ae_header_id   INTEGER
                )
IS
   SELECT 1
     FROM xla_ae_headers xah
    WHERE xah.application_id   = cp_application_id
      AND xah.ae_header_id     = cp_ae_header_id
   FOR UPDATE NOWAIT;

CURSOR lc_lock_ae_header_and_line
                ( cp_application_id INTEGER
                 ,cp_ae_header_id   INTEGER
                 ,cp_ae_line_num    INTEGER
                )
IS
   SELECT 1
     FROM xla_ae_headers xah
         ,xla_ae_lines   xal
    WHERE xah.application_id   = cp_application_id
      AND xah.ae_header_id     = cp_ae_header_id
      AND xal.application_id   = xah.application_id
      AND xal.ae_header_id     = xah.ae_header_id
      AND xal.ae_line_num      = cp_ae_line_num
   FOR UPDATE NOWAIT;

l_return_value              BOOLEAN;
l_analytical_balance_flag   VARCHAR2( 1);
l_ae_line_rowid             UROWID;
l_count_balanced_rows       INTEGER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_detail_value';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_application_id IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'p_application_id cannot be NULL'
                ,p_level => C_LEVEL_EXCEPTION
               );
      END IF;

      xla_exceptions_pkg.raise_message
              (p_location => 'xla_analytical_criteria_pkg.update_detail_value');
   END IF;

   --Lock the headers (and the lines if necessary)
   IF p_ae_line_num IS NULL
   THEN
      --lock the header
      OPEN lc_lock_ae_header
          ( cp_application_id => p_application_id
           ,cp_ae_header_id   => p_ae_header_id
          );
      CLOSE lc_lock_ae_header;

   ELSE --p_ae_line_num IS NOT NULL
      --lock the header and the line
      OPEN lc_lock_ae_header_and_line
          ( cp_application_id => p_application_id
           ,cp_ae_header_id   => p_ae_header_id
           ,cp_ae_line_num    => p_ae_line_num
          );
      CLOSE lc_lock_ae_header_and_line;

   END IF;

   IF p_update_mode = 'A'
   THEN
      IF p_list_of_criteria      IS NULL
      OR p_list_of_criteria.LAST IS NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'p_list_of_criteria is empty'
                ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
              (p_location => 'xla_analytical_criteria_pkg.update_detail_value');
      END IF;

      FOR i IN 1..p_list_of_criteria.LAST
      LOOP
         IF (   p_list_of_criteria(i).list_of_detail_chars.LAST
             <> p_list_of_criteria(i).list_of_detail_dates.LAST
            )
         OR (   p_list_of_criteria(i).list_of_detail_chars.LAST
             <> p_list_of_criteria(i).list_of_detail_numbers.LAST
            )
         THEN
            IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'detail list must be initialized for all datatypes'
                ,p_level => C_LEVEL_EXCEPTION
               );
            END IF;
            xla_exceptions_pkg.raise_message
              (p_location => 'xla_analytical_criteria_pkg.update_detail_value');
         END IF;

         CASE p_list_of_criteria(i).list_of_detail_chars.LAST
         WHEN 0
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'No detail values'
                  ,p_level => C_LEVEL_STATEMENT
                 );
            END IF;
            l_return_value := FALSE;
         WHEN 1
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'One detail value'
                  ,p_level => C_LEVEL_STATEMENT
                 );
            END IF;
            l_return_value :=
               add_criterion
                  ( p_application_id            => p_application_id
                   ,p_ae_header_id              => p_ae_header_id
                   ,p_ae_line_num               => p_ae_line_num
                   ,p_anacri_code               => p_list_of_criteria(i).anacri_code
                   ,p_anacri_type_code          => p_list_of_criteria(i).anacri_type_code
                   ,p_amb_context_code          => p_list_of_criteria(i).amb_context_code
                   ,p_detail_char_1             => p_list_of_criteria(i).list_of_detail_chars(1)
                   ,p_detail_char_2             => NULL
                   ,p_detail_char_3             => NULL
                   ,p_detail_char_4             => NULL
                   ,p_detail_char_5             => NULL
                   ,p_detail_date_1             => p_list_of_criteria(i).list_of_detail_dates(1)
                   ,p_detail_date_2             => NULL
                   ,p_detail_date_3             => NULL
                   ,p_detail_date_4             => NULL
                   ,p_detail_date_5             => NULL
                   ,p_detail_number_1           => p_list_of_criteria(i).list_of_detail_numbers(1)
                   ,p_detail_number_2           => NULL
                   ,p_detail_number_3           => NULL
                   ,p_detail_number_4           => NULL
                   ,p_detail_number_5           => NULL
                  );
         WHEN 2
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'Two detail values'
                  ,p_level => C_LEVEL_STATEMENT
                 );
            END IF;
            l_return_value :=
               add_criterion
                  ( p_application_id            => p_application_id
                   ,p_ae_header_id              => p_ae_header_id
                   ,p_ae_line_num               => p_ae_line_num
                   ,p_anacri_code               => p_list_of_criteria(i).anacri_code
                   ,p_anacri_type_code          => p_list_of_criteria(i).anacri_type_code
                   ,p_amb_context_code          => p_list_of_criteria(i).amb_context_code
                   ,p_detail_char_1             => p_list_of_criteria(i).list_of_detail_chars(1)
                   ,p_detail_char_2             => p_list_of_criteria(i).list_of_detail_chars(2)
                   ,p_detail_char_3             => NULL
                   ,p_detail_char_4             => NULL
                   ,p_detail_char_5             => NULL
                   ,p_detail_date_1             => p_list_of_criteria(i).list_of_detail_dates(1)
                   ,p_detail_date_2             => p_list_of_criteria(i).list_of_detail_dates(2)
                   ,p_detail_date_3             => NULL
                   ,p_detail_date_4             => NULL
                   ,p_detail_date_5             => NULL
                   ,p_detail_number_1           => p_list_of_criteria(i).list_of_detail_numbers(1)
                   ,p_detail_number_2           => p_list_of_criteria(i).list_of_detail_numbers(2)
                   ,p_detail_number_3           => NULL
                   ,p_detail_number_4           => NULL
                   ,p_detail_number_5           => NULL
                  );
         WHEN 3
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'Three detail values'
                  ,p_level => C_LEVEL_STATEMENT
                 );
            END IF;

            l_return_value :=
               add_criterion
                  ( p_application_id            => p_application_id
                   ,p_ae_header_id              => p_ae_header_id
                   ,p_ae_line_num               => p_ae_line_num
                   ,p_anacri_code               => p_list_of_criteria(i).anacri_code
                   ,p_anacri_type_code          => p_list_of_criteria(i).anacri_type_code
                   ,p_amb_context_code          => p_list_of_criteria(i).amb_context_code
                   ,p_detail_char_1             => p_list_of_criteria(i).list_of_detail_chars(1)
                   ,p_detail_char_2             => p_list_of_criteria(i).list_of_detail_chars(2)
                   ,p_detail_char_3             => p_list_of_criteria(i).list_of_detail_chars(3)
                   ,p_detail_char_4             => NULL
                   ,p_detail_char_5             => NULL
                   ,p_detail_date_1             => p_list_of_criteria(i).list_of_detail_dates(1)
                   ,p_detail_date_2             => p_list_of_criteria(i).list_of_detail_dates(2)
                   ,p_detail_date_3             => p_list_of_criteria(i).list_of_detail_dates(3)
                   ,p_detail_date_4             => NULL
                   ,p_detail_date_5             => NULL
                   ,p_detail_number_1           => p_list_of_criteria(i).list_of_detail_numbers(1)
                   ,p_detail_number_2           => p_list_of_criteria(i).list_of_detail_numbers(2)
                   ,p_detail_number_3           => p_list_of_criteria(i).list_of_detail_numbers(3)
                   ,p_detail_number_4           => NULL
                   ,p_detail_number_5           => NULL
                  );
         WHEN 4
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'Four detail values'
                  ,p_level => C_LEVEL_STATEMENT
                 );
            END IF;
            l_return_value :=
               add_criterion
                  ( p_application_id            => p_application_id
                   ,p_ae_header_id              => p_ae_header_id
                   ,p_ae_line_num               => p_ae_line_num
                   ,p_anacri_code               => p_list_of_criteria(i).anacri_code
                   ,p_anacri_type_code          => p_list_of_criteria(i).anacri_type_code
                   ,p_amb_context_code          => p_list_of_criteria(i).amb_context_code
                   ,p_detail_char_1             => p_list_of_criteria(i).list_of_detail_chars(1)
                   ,p_detail_char_2             => p_list_of_criteria(i).list_of_detail_chars(2)
                   ,p_detail_char_3             => p_list_of_criteria(i).list_of_detail_chars(3)
                   ,p_detail_char_4             => p_list_of_criteria(i).list_of_detail_chars(4)
                   ,p_detail_char_5             => NULL
                   ,p_detail_date_1             => p_list_of_criteria(i).list_of_detail_dates(1)
                   ,p_detail_date_2             => p_list_of_criteria(i).list_of_detail_dates(2)
                   ,p_detail_date_3             => p_list_of_criteria(i).list_of_detail_dates(3)
                   ,p_detail_date_4             => p_list_of_criteria(i).list_of_detail_dates(4)
                   ,p_detail_date_5             => NULL
                   ,p_detail_number_1           => p_list_of_criteria(i).list_of_detail_numbers(1)
                   ,p_detail_number_2           => p_list_of_criteria(i).list_of_detail_numbers(2)
                   ,p_detail_number_3           => p_list_of_criteria(i).list_of_detail_numbers(3)
                   ,p_detail_number_4           => p_list_of_criteria(i).list_of_detail_numbers(4)
                   ,p_detail_number_5           => NULL
                  );
         WHEN 5
         THEN
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'Five detail values'
                  ,p_level => C_LEVEL_STATEMENT
                 );
            END IF;
            l_return_value :=
               add_criterion
                  ( p_application_id            => p_application_id
                   ,p_ae_header_id              => p_ae_header_id
                   ,p_ae_line_num               => p_ae_line_num
                   ,p_anacri_code               => p_list_of_criteria(i).anacri_code
                   ,p_anacri_type_code          => p_list_of_criteria(i).anacri_type_code
                   ,p_amb_context_code          => p_list_of_criteria(i).amb_context_code
                   ,p_detail_char_1             => p_list_of_criteria(i).list_of_detail_chars(1)
                   ,p_detail_char_2             => p_list_of_criteria(i).list_of_detail_chars(2)
                   ,p_detail_char_3             => p_list_of_criteria(i).list_of_detail_chars(3)
                   ,p_detail_char_4             => p_list_of_criteria(i).list_of_detail_chars(4)
                   ,p_detail_char_5             => p_list_of_criteria(i).list_of_detail_chars(5)
                   ,p_detail_date_1             => p_list_of_criteria(i).list_of_detail_dates(1)
                   ,p_detail_date_2             => p_list_of_criteria(i).list_of_detail_dates(2)
                   ,p_detail_date_3             => p_list_of_criteria(i).list_of_detail_dates(3)
                   ,p_detail_date_4             => p_list_of_criteria(i).list_of_detail_dates(4)
                   ,p_detail_date_5             => p_list_of_criteria(i).list_of_detail_chars(5)
                   ,p_detail_number_1           => p_list_of_criteria(i).list_of_detail_numbers(1)
                   ,p_detail_number_2           => p_list_of_criteria(i).list_of_detail_numbers(2)
                   ,p_detail_number_3           => p_list_of_criteria(i).list_of_detail_numbers(3)
                   ,p_detail_number_4           => p_list_of_criteria(i).list_of_detail_numbers(4)
                   ,p_detail_number_5           => p_list_of_criteria(i).list_of_detail_chars(5)
                  );
         ELSE
            IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               trace
                  ( p_module   => l_log_module
                   ,p_msg   => 'EXCEPTION:'
                              ||'Unable to handle ' ||
                              p_list_of_criteria(i).list_of_detail_chars.LAST
                              || ' details.'
                   ,p_level => C_LEVEL_EXCEPTION
                  );
            END IF;
            xla_exceptions_pkg.raise_message
              (p_location => 'xla_analytical_criteria_pkg.update_detail_value');
         END CASE;
         IF  NOT l_return_value
         THEN
            EXIT;
         END IF;
      END LOOP;
   ELSIF p_update_mode = 'D'
   THEN
      IF p_list_of_criteria      IS NULL
      OR p_list_of_criteria.LAST IS NULL
      THEN
         l_return_value :=remove_criterion
              ( p_application_id             => p_application_id
               ,p_ae_header_id               => p_ae_header_id
               ,p_ae_line_num                => p_ae_line_num
               ,p_anacri_code                => NULL
               ,p_anacri_type_code           => NULL
               ,p_amb_context_code           => NULL
               ,p_analytical_detail_value_id => NULL
              );
      ELSE --specific criteria must be removed
         FOR i IN 1..p_list_of_criteria.LAST
         LOOP
            IF NOT
               remove_criterion
                        ( p_application_id             => p_application_id
                         ,p_ae_header_id               => p_ae_header_id
                         ,p_ae_line_num                => p_ae_line_num
                         ,p_anacri_code                => p_list_of_criteria(i).anacri_code
                         ,p_anacri_type_code           => p_list_of_criteria(i).anacri_type_code
                         ,p_amb_context_code           => p_list_of_criteria(i).amb_context_code
                         ,p_analytical_detail_value_id => NULL
                        )
            THEN
               l_return_value := FALSE;
               EXIT;
            END IF;
         END LOOP;
      END IF;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:'
                         ||'Unkown p_update_mode value: ' || p_update_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.update_detail_value');
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN  l_return_value;

EXCEPTION
WHEN le_resource_busy
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
                           ||'Unable to lock the records'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.update_detail_value');

END update_detail_value;


FUNCTION single_update_detail_value
                    ( p_application_id             IN INTEGER
                     ,p_ae_header_id               IN INTEGER
                     ,p_ae_line_num                IN INTEGER
                     ,p_analytical_detail_value_id IN INTEGER
                     ,p_anacri_code                IN VARCHAR2
                     ,p_anacri_type_code           IN VARCHAR2
                     ,p_amb_context_code           IN VARCHAR2
                     ,p_update_mode                IN VARCHAR2
                     ,p_detail_char_1              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_1              IN DATE     DEFAULT NULL
                     ,p_detail_number_1            IN NUMBER   DEFAULT NULL
                     ,p_detail_char_2              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_2              IN DATE     DEFAULT NULL
                     ,p_detail_number_2            IN NUMBER   DEFAULT NULL
                     ,p_detail_char_3              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_3              IN DATE     DEFAULT NULL
                     ,p_detail_number_3            IN NUMBER   DEFAULT NULL
                     ,p_detail_char_4              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_4              IN DATE     DEFAULT NULL
                     ,p_detail_number_4            IN NUMBER   DEFAULT NULL
                     ,p_detail_char_5              IN VARCHAR2 DEFAULT NULL
                     ,p_detail_date_5              IN DATE     DEFAULT NULL
                     ,p_detail_number_5            IN NUMBER   DEFAULT NULL
                    )
RETURN BOOLEAN
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
| Obsolete in R12+ Supporting References Re-Architecture                |
| No need to maintain xla_analytical_dtl_vals
| From AeLineAcEOImpl.java, call update_balances.                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Replaced with update_balances in R12+ Re-Architecture                 |
+======================================================================*/
CURSOR lc_lock_ae_header
                ( cp_application_id INTEGER
                 ,cp_ae_header_id   INTEGER
                )
IS
   SELECT 1
     FROM xla_ae_headers xah
    WHERE xah.application_id   = cp_application_id
      AND xah.ae_header_id     = cp_ae_header_id
   FOR UPDATE NOWAIT;

CURSOR lc_lock_ae_header_and_line
                ( cp_application_id INTEGER
                 ,cp_ae_header_id   INTEGER
                 ,cp_ae_line_num    INTEGER
                )
IS
   SELECT 1
     FROM xla_ae_headers xah
         ,xla_ae_lines   xal
    WHERE xah.application_id   = cp_application_id
      AND xah.ae_header_id     = cp_ae_header_id
      AND xal.application_id   = xah.application_id
      AND xal.ae_header_id     = xah.ae_header_id
      AND xal.ae_line_num      = cp_ae_line_num
   FOR UPDATE NOWAIT;

l_return_value              BOOLEAN;
l_application_id            INTEGER;
l_analytical_balance_flag   VARCHAR2( 1);
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.single_update_detail_value';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_ae_header_id IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'p_ae_header_id cannot be NULL.'
                ,p_level => C_LEVEL_EXCEPTION
               );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
   END IF;

   IF p_ae_line_num IS NULL
   THEN
      --lock the header
      OPEN lc_lock_ae_header
          ( cp_application_id => p_application_id
           ,cp_ae_header_id   => p_ae_header_id
          );
      CLOSE lc_lock_ae_header;

   ELSE --p_ae_line_num IS NOT NULL
      --lock the header and the line
      OPEN lc_lock_ae_header_and_line
          ( cp_application_id => p_application_id
           ,cp_ae_header_id   => p_ae_header_id
           ,cp_ae_line_num    => p_ae_line_num
          );
      CLOSE lc_lock_ae_header_and_line;

   END IF; --p_ae_line_num IS NULL

   IF p_update_mode = 'A'
   THEN
      IF p_anacri_code      IS NULL
      OR p_anacri_type_code IS NULL
      OR p_amb_context_code IS NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                            ||'When adding, p_anacri_code, p_anacri_type_code and'
                            ||'p_amb_context_code cannot be NULL'
                ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
              (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
      END IF;
      IF p_analytical_detail_value_id IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'When adding p_analytical_detail_value_id ' ||
                           'must be NULL'
                ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
              (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
      END IF;

      l_return_value :=
         add_criterion
                  ( p_application_id            => p_application_id
                   ,p_ae_header_id              => p_ae_header_id
                   ,p_ae_line_num               => p_ae_line_num
                   ,p_anacri_code               => p_anacri_code
                   ,p_anacri_type_code          => p_anacri_type_code
                   ,p_amb_context_code          => p_amb_context_code
                   ,p_detail_char_1             => p_detail_char_1
                   ,p_detail_char_2             => p_detail_char_2
                   ,p_detail_char_3             => p_detail_char_3
                   ,p_detail_char_4             => p_detail_char_4
                   ,p_detail_char_5             => p_detail_char_5
                   ,p_detail_date_1             => p_detail_date_1
                   ,p_detail_date_2             => p_detail_date_2
                   ,p_detail_date_3             => p_detail_date_3
                   ,p_detail_date_4             => p_detail_date_4
                   ,p_detail_date_5             => p_detail_date_5
                   ,p_detail_number_1           => p_detail_number_1
                   ,p_detail_number_2           => p_detail_number_2
                   ,p_detail_number_3           => p_detail_number_3
                   ,p_detail_number_4           => p_detail_number_4
                   ,p_detail_number_5           => p_detail_number_5
                  );
   ELSIF p_update_mode = 'D'
   THEN
      IF p_ae_header_id IS NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'When deleting p_ae_header_id cannot be NULL: ' ||
                            p_ae_header_id
                ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
      ELSE
      IF p_anacri_code      IS NOT NULL
      OR p_anacri_type_code IS NOT NULL
      OR p_amb_context_code IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'When deleting, p_anacri_code ,p_anacri_type_code '
                           || 'and p_amb_context_code must be NULL.'
                ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
      END IF;

      IF p_detail_char_1     IS NOT NULL
      OR p_detail_char_2     IS NOT NULL
      OR p_detail_char_3     IS NOT NULL
      OR p_detail_char_4     IS NOT NULL
      OR p_detail_char_5     IS NOT NULL
      OR p_detail_date_1     IS NOT NULL
      OR p_detail_date_2     IS NOT NULL
      OR p_detail_date_3     IS NOT NULL
      OR p_detail_date_4     IS NOT NULL
      OR p_detail_date_5     IS NOT NULL
      OR p_detail_number_1   IS NOT NULL
      OR p_detail_number_2   IS NOT NULL
      OR p_detail_number_3   IS NOT NULL
      OR p_detail_number_4   IS NOT NULL
      OR p_detail_number_5   IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'When deleting, all DETAILS must be NULL.'
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_1:   ' || p_detail_char_1
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_2:   ' || p_detail_char_2
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_3:   ' || p_detail_char_3
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_4:   ' || p_detail_char_4
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_5:   ' || p_detail_char_5
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_1:   ' || p_detail_date_1
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_2:   ' || p_detail_date_2
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_3:   ' || p_detail_date_3
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_4:   ' || p_detail_date_4
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_5:   ' || p_detail_date_5
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_1: ' || p_detail_number_1
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_2: ' || p_detail_number_2
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_3: ' || p_detail_number_3
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_4: ' || p_detail_number_4
                ,p_level => C_LEVEL_EXCEPTION );
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_5: ' || p_detail_number_5
                ,p_level => C_LEVEL_EXCEPTION );
         END IF;

         xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
      END IF;

      l_return_value :=
            remove_criterion
                        ( p_ae_header_id               => p_ae_header_id
                         ,p_ae_line_num                => p_ae_line_num
                         ,p_application_id             => p_application_id
                         ,p_anacri_code                => p_anacri_code
                         ,p_anacri_type_code           => p_anacri_type_code
                         ,p_amb_context_code           => p_amb_context_code
                         ,p_analytical_detail_value_id => p_analytical_detail_value_id
                        );
       END IF;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:'
                           ||'Unkown p_update_mode value: '
                        || p_update_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN  l_return_value;

EXCEPTION
WHEN le_resource_busy
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
                           ||'Unable to lock the records'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
END single_update_detail_value;


FUNCTION single_update_detail_value
                    ( p_application_id             IN INTEGER
                     ,p_ae_header_id               IN INTEGER
                     ,p_ae_line_num                IN INTEGER
                     ,p_anacri_code                IN VARCHAR2
                     ,p_anacri_type_code           IN VARCHAR2
                     ,p_amb_context_code           IN VARCHAR2
                     ,p_update_mode                IN VARCHAR2
                     ,p_ac1                        IN VARCHAR2 DEFAULT NULL
                     ,p_ac2                        IN VARCHAR2 DEFAULT NULL
                     ,p_ac3                        IN VARCHAR2 DEFAULT NULL
                     ,p_ac4                        IN VARCHAR2 DEFAULT NULL
                     ,p_ac5                        IN VARCHAR2 DEFAULT NULL
                    )
RETURN BOOLEAN IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
                                                                        |
| Description                                                           |
| -----------                                                           |
| Added for R12+ Supporting References Re-Architecture                  |
| Called From:                                                          |
|    - AeLineAcEOImpl.java                                              |
+======================================================================*/

CURSOR lc_lock_ae_header
                ( cp_application_id INTEGER
                 ,cp_ae_header_id   INTEGER
                )
IS
   SELECT 1
     FROM xla_ae_headers xah
    WHERE xah.application_id   = cp_application_id
      AND xah.ae_header_id     = cp_ae_header_id
   FOR UPDATE NOWAIT;

CURSOR lc_lock_ae_header_and_line
                ( cp_application_id INTEGER
                 ,cp_ae_header_id   INTEGER
                 ,cp_ae_line_num    INTEGER
                )
IS
   SELECT 1
     FROM xla_ae_headers xah
         ,xla_ae_lines   xal
    WHERE xah.application_id   = cp_application_id
      AND xah.ae_header_id     = cp_ae_header_id
      AND xal.application_id   = xah.application_id
      AND xal.ae_header_id     = xah.ae_header_id
      AND xal.ae_line_num      = cp_ae_line_num
   FOR UPDATE NOWAIT;

l_return_value              BOOLEAN;
l_application_id            INTEGER;
l_analytical_balance_flag   VARCHAR2( 1);
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.update_balances';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'p_ac1:   ' || p_ac1
          ,p_level => C_LEVEL_EXCEPTION );
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'p_ac2:   ' || p_ac2
          ,p_level => C_LEVEL_EXCEPTION );
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'p_ac3:   ' || p_ac3
          ,p_level => C_LEVEL_EXCEPTION );
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'p_ac4:   ' || p_ac4
          ,p_level => C_LEVEL_EXCEPTION );
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'p_ac5:   ' || p_ac5
          ,p_level => C_LEVEL_EXCEPTION );

   END IF;


   IF p_ae_header_id IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'p_ae_header_id cannot be NULL.'
                ,p_level => C_LEVEL_EXCEPTION
               );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
   END IF;

   IF p_ae_line_num IS NULL
   THEN
      --lock the header
      OPEN lc_lock_ae_header
          ( cp_application_id => p_application_id
           ,cp_ae_header_id   => p_ae_header_id
          );
      CLOSE lc_lock_ae_header;

   ELSE --p_ae_line_num IS NOT NULL
      --lock the header and the line
      OPEN lc_lock_ae_header_and_line
          ( cp_application_id => p_application_id
           ,cp_ae_header_id   => p_ae_header_id
           ,cp_ae_line_num    => p_ae_line_num
          );
      CLOSE lc_lock_ae_header_and_line;

   END IF; --p_ae_line_num IS NULL

   IF p_update_mode = 'A'
   THEN
      IF p_anacri_code      IS NULL
      OR p_anacri_type_code IS NULL
      OR p_amb_context_code IS NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                            ||'When adding, p_anacri_code, p_anacri_type_code and'
                            ||'p_amb_context_code cannot be NULL'
                ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
              (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
      END IF;

      l_return_value :=
         add_criterion
                  ( p_application_id            => p_application_id
                   ,p_ae_header_id              => p_ae_header_id
                   ,p_ae_line_num               => p_ae_line_num
                   ,p_anacri_code               => p_anacri_code
                   ,p_anacri_type_code          => p_anacri_type_code
                   ,p_amb_context_code          => p_amb_context_code
                  );

   ELSIF p_update_mode = 'D'
   THEN
      IF p_ae_header_id IS NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'When deleting p_ae_header_id cannot be NULL: ' ||
                            p_ae_header_id
                ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
      ELSE
      IF p_anacri_code      IS NOT NULL
      OR p_anacri_type_code IS NOT NULL
      OR p_amb_context_code IS NOT NULL
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               ( p_module   => l_log_module
                ,p_msg   => 'EXCEPTION:'
                           ||'When deleting, p_anacri_code ,p_anacri_type_code '
                           || 'and p_amb_context_code must be NULL.'
                ,p_level => C_LEVEL_EXCEPTION
               );
         END IF;
         xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
      END IF;

      l_return_value :=
            remove_criterion
                        ( p_ae_header_id               => p_ae_header_id
                         ,p_ae_line_num                => p_ae_line_num
                         ,p_application_id             => p_application_id
                         ,p_anacri_code                => p_anacri_code
                         ,p_anacri_type_code           => p_anacri_type_code
                         ,p_amb_context_code           => p_amb_context_code
                         ,p_ac1                        => p_ac1
                         ,p_ac2                        => p_ac2
                         ,p_ac3                        => p_ac3
                         ,p_ac4                        => p_ac4
                         ,p_ac5                        => p_ac5
                        );
     END IF;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:'
                           ||'Unkown p_update_mode value: '
                        || p_update_mode
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
   RETURN  l_return_value;

EXCEPTION
WHEN le_resource_busy
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
                           ||'Unable to lock the records'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      RETURN FALSE;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.single_update_detail_value');

END single_update_detail_value;



FUNCTION get_detail_value_id
                ( p_anacri_code              IN VARCHAR2
                 ,p_anacri_type_code         IN VARCHAR2
                 ,p_amb_context_code         IN VARCHAR2
                 ,p_detail_char_1            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_1            IN DATE     DEFAULT NULL
                 ,p_detail_number_1          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_2            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_2            IN DATE     DEFAULT NULL
                 ,p_detail_number_2          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_3            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_3            IN DATE     DEFAULT NULL
                 ,p_detail_number_3          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_4            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_4            IN DATE     DEFAULT NULL
                 ,p_detail_number_4          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_5            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_5            IN DATE     DEFAULT NULL
                 ,p_detail_number_5          IN NUMBER   DEFAULT NULL
                )
RETURN INTEGER
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Refer to the Detail Level Design document                             |
+======================================================================*/

l_detail_value_id INTEGER;
l_loop_count      PLS_INTEGER := 0;
l_current_pos     PLS_INTEGER := 0;
l_cache_elm_count PLS_INTEGER;

l_log_module                 VARCHAR2 (2000);
l_det_1           VARCHAR2(240);
l_det_2           VARCHAR2(240);
l_det_3           VARCHAR2(240);
l_det_4           VARCHAR2(240);
l_det_5           VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_detail_value_id';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_anacri_code      IS NULL
   OR p_anacri_type_code IS NULL
   OR p_amb_context_code IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level)
      THEN
         trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:'
                           ||'When deleting p_anacri_code, p_anacri_type_code, ' ||
                        'p_amb_context_code cannot be NULL.'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg..get_detail_value_id');
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'Input parameters:'
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_1  :' || p_detail_char_1
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_1  : ' || p_detail_date_1
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_1: ' || p_detail_number_1
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_2  : ' || p_detail_char_2
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_2  : ' || p_detail_date_2
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_2: ' || p_detail_number_2
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_3  : ' || p_detail_char_3
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_3  : ' || p_detail_date_3
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_3: ' || p_detail_number_3
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_4  : ' || p_detail_char_4
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_4  : ' || p_detail_date_4
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_4: ' || p_detail_number_4
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_5  : ' || p_detail_char_5
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_5  : ' || p_detail_date_5
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_5: ' || p_detail_number_5
                ,p_level => C_LEVEL_STATEMENT );
   END IF;

   IF (  p_detail_char_1 IS NOT NULL AND (    p_detail_date_1   IS NOT NULL
                                           OR p_detail_number_1 IS NOT NULL)
      )
   OR (  p_detail_char_2 IS NOT NULL AND (    p_detail_date_2   IS NOT NULL
                                           OR p_detail_number_2 IS NOT NULL)
      )
   OR (  p_detail_char_3 IS NOT NULL AND (    p_detail_date_3   IS NOT NULL
                                           OR p_detail_number_3 IS NOT NULL)
      )
   OR (  p_detail_char_4 IS NOT NULL AND (    p_detail_date_4   IS NOT NULL
                                           OR p_detail_number_4 IS NOT NULL)
      )
   OR (  p_detail_char_5 IS NOT NULL AND (    p_detail_date_5   IS NOT NULL
                                           OR p_detail_number_5 IS NOT NULL)
      )
   OR (p_detail_date_1 IS NOT NULL AND p_detail_number_1 IS NOT NULL)
   OR (p_detail_date_2 IS NOT NULL AND p_detail_number_2 IS NOT NULL)
   OR (p_detail_date_3 IS NOT NULL AND p_detail_number_3 IS NOT NULL)
   OR (p_detail_date_4 IS NOT NULL AND p_detail_number_4 IS NOT NULL)
   OR (p_detail_date_5 IS NOT NULL AND p_detail_number_5 IS NOT NULL)
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:'
                           ||'At most one detail of each triple can have a value'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg..get_detail_value_id');
   END IF;
   l_cache_elm_count := ga_anacri_code.COUNT;
   l_current_pos := g_anacri_cache_next_avail_pos - 1 ;

   --Retrieve the converted segment values
   l_det_1      := format_detail_value ( p_detail_char   => p_detail_char_1
                               ,p_detail_date   => p_detail_date_1
                               ,p_detail_number => p_detail_number_1
                              );
   l_det_2      := format_detail_value ( p_detail_char   => p_detail_char_2
                               ,p_detail_date   => p_detail_date_2
                               ,p_detail_number => p_detail_number_2
                              );
   l_det_3      := format_detail_value ( p_detail_char   => p_detail_char_3
                               ,p_detail_date   => p_detail_date_3
                               ,p_detail_number => p_detail_number_3
                              );
   l_det_4      := format_detail_value ( p_detail_char   => p_detail_char_4
                               ,p_detail_date   => p_detail_date_4
                               ,p_detail_number => p_detail_number_4
                              );
   l_det_5      := format_detail_value ( p_detail_char  => p_detail_char_5
                               ,p_detail_date   => p_detail_date_5
                               ,p_detail_number => p_detail_number_5
                              );

   WHILE l_loop_count < l_cache_elm_count
   LOOP
      IF l_current_pos = 0
      THEN
         l_current_pos := l_cache_elm_count;
      END IF;

      IF  ga_anacri_code      (l_current_pos) = p_anacri_code
      AND ga_anacri_type_code (l_current_pos) = p_anacri_type_code
      AND ga_amb_context_code (l_current_pos) = p_amb_context_code
      AND l_det_1
          = ga_anacri_detail_char_1 (l_current_pos)

      AND l_det_2
          = ga_anacri_detail_char_2 (l_current_pos)

      AND l_det_3
          = ga_anacri_detail_char_3 (l_current_pos)

      AND l_det_4
          = ga_anacri_detail_char_4 (l_current_pos)

      AND l_det_5
          = ga_anacri_detail_char_5 (l_current_pos)

      THEN
         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'Cache hit: POS(' || l_current_pos || '), ID: '
                              || ga_anacri_id(l_current_pos)
                  ,p_level => C_LEVEL_STATEMENT
                 );
         END IF;
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
            trace
               (p_module   => l_log_module
               ,p_msg      => 'END ' || l_log_module
               ,p_level    => C_LEVEL_PROCEDURE);
         END IF;
         RETURN ga_anacri_id(l_current_pos);
      END IF;

      l_loop_count  := l_loop_count + 1;
      l_current_pos := l_current_pos - 1;

      IF l_current_pos = 0
      THEN
         l_current_pos := l_cache_elm_count;
      END IF;

   END LOOP;

   l_detail_value_id := maintain_detail_values
                ( p_anacri_code        => p_anacri_code
                 ,p_anacri_type_code   => p_anacri_type_code
                 ,p_amb_context_code   => p_amb_context_code
                 ,p_detail_char_1      => p_detail_char_1
                 ,p_detail_char_2      => p_detail_char_2
                 ,p_detail_char_3      => p_detail_char_3
                 ,p_detail_char_4      => p_detail_char_4
                 ,p_detail_char_5      => p_detail_char_5
                 ,p_detail_date_1      => p_detail_date_1
                 ,p_detail_date_2      => p_detail_date_2
                 ,p_detail_date_3      => p_detail_date_3
                 ,p_detail_date_4      => p_detail_date_4
                 ,p_detail_date_5      => p_detail_date_5
                 ,p_detail_number_1    => p_detail_number_1
                 ,p_detail_number_2    => p_detail_number_2
                 ,p_detail_number_3    => p_detail_number_3
                 ,p_detail_number_4    => p_detail_number_4
                 ,p_detail_number_5    => p_detail_number_5
                );

   ga_anacri_id              (g_anacri_cache_next_avail_pos)
      := l_detail_value_id;
   ga_anacri_code            (g_anacri_cache_next_avail_pos)
      := p_anacri_code;
   ga_anacri_type_code       (g_anacri_cache_next_avail_pos)
      := p_anacri_type_code;
   ga_amb_context_code       (g_anacri_cache_next_avail_pos)
      := p_amb_context_code;

   ga_anacri_detail_char_1   (g_anacri_cache_next_avail_pos)
      := l_det_1;
   ga_anacri_detail_char_2   (g_anacri_cache_next_avail_pos)
      := l_det_2;

   ga_anacri_detail_char_3   (g_anacri_cache_next_avail_pos)
      := l_det_3;

   ga_anacri_detail_char_4   (g_anacri_cache_next_avail_pos)
      := l_det_4;

   ga_anacri_detail_char_5   (g_anacri_cache_next_avail_pos)
      := l_det_5;

   IF g_anacri_cache_next_avail_pos = C_ANACRI_CACHE_MAX_SIZE
   THEN
      g_anacri_cache_next_avail_pos := 1;
   ELSE
      g_anacri_cache_next_avail_pos := g_anacri_cache_next_avail_pos + 1;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'Returned ID: ' || l_detail_value_id
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_detail_value_id;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.get_detail_value_id');


END get_detail_value_id;

FUNCTION concat_detail_values
                ( p_anacri_code              IN VARCHAR2
                 ,p_anacri_type_code         IN VARCHAR2
                 ,p_amb_context_code         IN VARCHAR2
                 ,p_detail_char_1            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_1            IN DATE     DEFAULT NULL
                 ,p_detail_number_1          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_2            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_2            IN DATE     DEFAULT NULL
                 ,p_detail_number_2          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_3            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_3            IN DATE     DEFAULT NULL
                 ,p_detail_number_3          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_4            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_4            IN DATE     DEFAULT NULL
                 ,p_detail_number_4          IN NUMBER   DEFAULT NULL
                 ,p_detail_char_5            IN VARCHAR2 DEFAULT NULL
                 ,p_detail_date_5            IN DATE     DEFAULT NULL
                 ,p_detail_number_5          IN NUMBER   DEFAULT NULL
                )
RETURN VARCHAR2
IS
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Refer to the Detail Level Design document                             |
+======================================================================*/

l_detail_value_id INTEGER;
l_detail_value    VARCHAR2(240);

l_loop_count      PLS_INTEGER := 0;
l_current_pos     PLS_INTEGER := 0;
l_cache_elm_count PLS_INTEGER;

l_log_module                 VARCHAR2 (2000);
l_det_1           VARCHAR2(240);
l_det_2           VARCHAR2(240);
l_det_3           VARCHAR2(240);
l_det_4           VARCHAR2(240);
l_det_5           VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_detail_value_id';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF p_anacri_code      IS NULL
   OR p_anacri_type_code IS NULL
   OR p_amb_context_code IS NULL
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level)
      THEN
         trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:'
                           ||'When deleting p_anacri_code, p_anacri_type_code, ' ||
                        'p_amb_context_code cannot be NULL.'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg..get_detail_value_id');
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level)
   THEN
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'Input parameters:'
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_1  :' || p_detail_char_1
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_1  : ' || p_detail_date_1
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_1: ' || p_detail_number_1
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_2  : ' || p_detail_char_2
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_2  : ' || p_detail_date_2
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_2: ' || p_detail_number_2
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_3  : ' || p_detail_char_3
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_3  : ' || p_detail_date_3
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_3: ' || p_detail_number_3
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_4  : ' || p_detail_char_4
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_4  : ' || p_detail_date_4
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_4: ' || p_detail_number_4
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_char_5  : ' || p_detail_char_5
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_date_5  : ' || p_detail_date_5
                ,p_level => C_LEVEL_STATEMENT );
      trace
               ( p_module   => l_log_module
                ,p_msg   => 'p_detail_number_5: ' || p_detail_number_5
                ,p_level => C_LEVEL_STATEMENT );
   END IF;

   IF (  p_detail_char_1 IS NOT NULL AND (    p_detail_date_1   IS NOT NULL
                                           OR p_detail_number_1 IS NOT NULL)
      )
   OR (  p_detail_char_2 IS NOT NULL AND (    p_detail_date_2   IS NOT NULL
                                           OR p_detail_number_2 IS NOT NULL)
      )
   OR (  p_detail_char_3 IS NOT NULL AND (    p_detail_date_3   IS NOT NULL
                                           OR p_detail_number_3 IS NOT NULL)
      )
   OR (  p_detail_char_4 IS NOT NULL AND (    p_detail_date_4   IS NOT NULL
                                           OR p_detail_number_4 IS NOT NULL)
      )
   OR (  p_detail_char_5 IS NOT NULL AND (    p_detail_date_5   IS NOT NULL
                                           OR p_detail_number_5 IS NOT NULL)
      )
   OR (p_detail_date_1 IS NOT NULL AND p_detail_number_1 IS NOT NULL)
   OR (p_detail_date_2 IS NOT NULL AND p_detail_number_2 IS NOT NULL)
   OR (p_detail_date_3 IS NOT NULL AND p_detail_number_3 IS NOT NULL)
   OR (p_detail_date_4 IS NOT NULL AND p_detail_number_4 IS NOT NULL)
   OR (p_detail_date_5 IS NOT NULL AND p_detail_number_5 IS NOT NULL)
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:'
                           ||'At most one detail of each triple can have a value'
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg..get_detail_value_id');
   END IF;

   --Retrieve the converted segment values
   l_det_1      := format_detail_value (
                      p_detail_char   => p_detail_char_1
                     ,p_detail_date   => p_detail_date_1
                     ,p_detail_number => p_detail_number_1
                     );
   l_det_2      := format_detail_value (
                      p_detail_char   => p_detail_char_2
                     ,p_detail_date   => p_detail_date_2
                     ,p_detail_number => p_detail_number_2
                     );
   l_det_3      := format_detail_value ( p_detail_char   => p_detail_char_3
                               ,p_detail_date   => p_detail_date_3
                               ,p_detail_number => p_detail_number_3
                              );
   l_det_4      := format_detail_value ( p_detail_char   => p_detail_char_4
                               ,p_detail_date   => p_detail_date_4
                               ,p_detail_number => p_detail_number_4
                              );
   l_det_5      := format_detail_value ( p_detail_char  => p_detail_char_5
                               ,p_detail_date   => p_detail_date_5
                               ,p_detail_number => p_detail_number_5
                              );
   IF  l_det_1 IS NULL
   AND l_det_2 IS NULL
   AND l_det_3 IS NULL
   AND l_det_4 IS NULL
   AND l_det_5 IS NULL
   THEN
      l_detail_value := null;
   ELSE
      l_detail_value := p_anacri_code
                     || C_AC_DELIMITER
                     || p_anacri_type_code
                     || C_AC_DELIMITER
                     || p_amb_context_code
                     || C_AC_DELIMITER
                     || l_det_1
                     || C_AC_DELIMITER
                     || l_det_2
                     || C_AC_DELIMITER
                     || l_det_3
                     || C_AC_DELIMITER
                     || l_det_4
                     || C_AC_DELIMITER
                     || l_det_5;
    END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'Returned ID: ' || l_detail_value_id
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_detail_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.get_detail_value_id');


END concat_detail_values;

FUNCTION get_first_free_view_col_number (
            p_data_type_code  IN VARCHAR2
           ,p_balance_flag    IN VARCHAR2)

RETURN INTEGER
IS

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Returns a first free view column nuumber.                             |
| Due to R12+ re-architecture, Details with balances are not displayed  |
| in Lines Inquiry (use 1000+ as view column numbers).                  |
| e.g.                                                                  |
| Detail Code Balance Flag  Data Type  View Column Number               |
| ----------- ------------  ---------  ------------------               |                                           |
| AC_DTL_1    N             C           1                               |
| AC_DTL_2    N             C           2                               |
| AC_DTL_3    N             N           1                               |
| AC_DTL_1B   Y             C           1001                            |
|                                                                       |
| Input Data Type Balance Flag Output  First Free View Column Number    |
| --------------- -------------------- -----------------------------    |
| C               N                    3                                |
| C               Y                    1002                             |
| N               N                    2                                |
| N               Y                    1001                             |
| D               N                    1                                |
| D               Y                    1                                |
+======================================================================*/

--locks all the record needed to assign a new view_column_num
--for the specified data type
--note that the case in which slot = 1 is free and subsequent ones are not
--must be treated separately
CURSOR lc_next_free_view_col_number
                ( cp_data_type_code           VARCHAR2
                )
IS
   SELECT xdtb.view_column_num
     FROM xla_analytical_dtls_b xdtb
         ,xla_analytical_hdrs_b xhtb
    WHERE xdtb.analytical_criterion_code = xhtb.analytical_criterion_code
      AND xdtb.analytical_criterion_type_code = xhtb.analytical_criterion_type_code
      AND xhtb.balancing_flag = p_balance_flag
      AND xdtb.data_type_code = cp_data_type_code
      AND NVL(xdtb.view_column_num, -1) =
           (SELECT NVL( MIN(xdtb2.view_column_num), -1)
              FROM xla_analytical_dtls_b xdtb2
                  ,xla_analytical_dtls_b xdtb3
                  ,xla_analytical_hdrs_b xhtb2
             WHERE xdtb2.data_type_code        = xdtb.data_type_code
               AND xdtb2.analytical_criterion_code = xhtb2.analytical_criterion_code
               AND xdtb2.analytical_criterion_type_code = xhtb2.analytical_criterion_type_code
               AND xhtb2.balancing_flag = p_balance_flag
               AND xdtb3.data_type_code     (+)= xdtb2.data_type_code
               AND xdtb3.view_column_num    (+)= xdtb2.view_column_num + 1
               AND xdtb3.rowid                 IS NULL
           )
   FOR UPDATE NOWAIT;

l_next_free_view_col_number    INTEGER;
l_max_mappable_details         INTEGER;
l_return_value                 INTEGER;
l_count_in_slot_1              INTEGER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_first_free_view_col_number';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --pick the limit of details assignable for the given datatype
   IF p_data_type_code = 'C'
   THEN
      l_max_mappable_details := C_MAX_MAPPABLE_VARCHAR_DETAILS;
   ELSIF p_data_type_code = 'D'
   THEN
      l_max_mappable_details := C_MAX_MAPPABLE_DATE_DETAILS;
   ELSIF p_data_type_code = 'N'
   THEN
      l_max_mappable_details := C_MAX_MAPPABLE_NUMBER_DETAILS;
   ELSE
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            ( p_module   => l_log_module
             ,p_msg   => 'EXCEPTION:'
                           ||'Invalid value for parameter p_data_type_code:'
                        || p_data_type_code
             ,p_level => C_LEVEL_EXCEPTION
            );
      END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_analytical_criteria_pkg.get_first_free_view_col_number');
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'max assignable details for this datatype: '
                      || l_max_mappable_details
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

  --Lock(NW) row in xla_analytical_dtls_with the lowest
  --view_column_num with no successor (for the given datatype only)
  --or lock all of them if all are NULL (for the given datatype only)

   BEGIN
      OPEN lc_next_free_view_col_number (cp_data_type_code => p_data_type_code);
      FETCH lc_next_free_view_col_number
       INTO l_next_free_view_col_number;
      CLOSE lc_next_free_view_col_number;

   EXCEPTION
   WHEN le_resource_busy
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
                           ||'Unable to lock the records'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      l_return_value := C_CANNOT_LOCK_DETAIL_ROW;
   END;

   --see if slot 1 is free for this data type
   SELECT count(*)
     INTO l_count_in_slot_1
     FROM xla_analytical_dtls_b xdtb
    WHERE xdtb.data_type_code     = p_data_type_code
      AND xdtb.view_column_num = 1;

   --if it is free override the selection
   IF l_count_in_slot_1 = 0
   THEN
      l_next_free_view_col_number := NULL;
   END IF;

   --if the record(s) could be locked (no err code in l_return_value) then
      --if the value found is equal to the limit for the datatype
      --or the NVL(limit, 0) <= 0 then return -1
      --elsif the value is null then return 1
      --else return the max + 1
   IF l_return_value IS NULL
   THEN
      IF (l_next_free_view_col_number = l_max_mappable_details
      OR NVL(l_max_mappable_details, 0) <= 0) and p_balance_flag = 'N'
      THEN
         l_return_value := C_NO_AVAILABLE_VIEW_COLUMN;
      ELSIF l_next_free_view_col_number IS NULL
      THEN
         -- R12+ Re-Architecture
         IF p_balance_flag = 'Y' THEN
           l_return_value := 1001;
         ELSE
           l_return_value := 1;
         END IF;
      ELSE
         l_return_value := l_next_free_view_col_number + 1;
      END IF;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'Returned value: ' || l_return_value
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN  l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.get_first_free_view_col_number');

END get_first_free_view_col_number;


FUNCTION get_view_column_number
(p_anacri_code              IN VARCHAR2
,p_anacri_type_code         IN VARCHAR2
,p_anacri_detail_code       IN VARCHAR2
,p_data_type_code           IN VARCHAR2)
RETURN INTEGER
IS
CURSOR c IS
  SELECT view_column_num
    FROM xla_analytical_dtls_b
   WHERE analytical_criterion_code      = p_anacri_code
     AND analytical_criterion_type_code = p_anacri_type_code
     AND analytical_detail_code         = p_anacri_detail_code
     AND data_type_code                 = p_data_type_code
     AND view_column_num                IS NOT NULL; -- bug 4583524

l_return_value               INTEGER;
l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_view_column_number';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module ||
                        ' - '||p_anacri_code||','||p_anacri_type_code||
                        ','||p_anacri_detail_code||','||p_data_type_code
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   OPEN c;
   FETCH c INTO l_return_value;
   CLOSE c;

   IF (l_return_value IS NULL) THEN
      l_return_value := -1;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module || ' : ' || l_return_value
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN  l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.get_view_column_number');

END get_view_column_number;



FUNCTION compile_criterion ( p_anacri_code              IN VARCHAR2
                            ,p_anacri_type_code         IN VARCHAR2
                            ,p_amb_context_code         IN VARCHAR2
                           )

RETURN INTEGER
IS

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Refer to the Detail Level Design document                             |
+======================================================================*/


CURSOR lc_details
                ( cp_anacri_code              VARCHAR2
                 ,cp_anacri_type_code         VARCHAR2
                 ,cp_amb_context_code         VARCHAR2
                )
IS
   SELECT xdtb.analytical_detail_code
         ,xdtb.view_column_num
         ,xdtb.data_type_code
     FROM xla_analytical_dtls_b xdtb
    WHERE xdtb.analytical_criterion_code      = cp_anacri_code
      AND xdtb.analytical_criterion_type_code = cp_anacri_type_code
      AND xdtb.amb_context_code               = cp_amb_context_code
   ORDER BY xdtb.grouping_order
   FOR UPDATE NOWAIT;

l_enabled_flag              VARCHAR2(1);
l_display_in_inquiries_flag VARCHAR2(1);
l_balance_flag              VARCHAR2(1);
l_view_column_number        INTEGER;
l_update_required           BOOLEAN;
l_count_exist_dvals         INTEGER;
l_return_value              INTEGER;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.compile_criterion';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'p_anacri_code: ' || p_anacri_code
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'p_anacri_type_code: ' || p_anacri_type_code
          ,p_level => C_LEVEL_STATEMENT
         );
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'p_amb_context_code: ' || p_amb_context_code
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

SAVEPOINT START_SAVEPOINT;

   --begin a new block that traps the resource busy exception
   BEGIN
      --retrieve enabled_flag and display_in_inquiries_flag
      --from the criterion header, locking it
      SELECT xhdb.enabled_flag
            ,xhdb.display_in_inquiries_flag
            ,xhdb.balancing_flag
        INTO l_enabled_flag
            ,l_display_in_inquiries_flag
            ,l_balance_flag
        FROM xla_analytical_hdrs_b xhdb
       WHERE xhdb.analytical_criterion_code      = p_anacri_code
         AND xhdb.analytical_criterion_type_code = p_anacri_type_code
         AND xhdb.amb_context_code               = p_amb_context_code
      FOR UPDATE NOWAIT;

      --check if there is at least one detail value for the criterion
      SELECT count(*)
        INTO l_count_exist_dvals
        FROM xla_analytical_dtl_vals xadv
       WHERE xadv.analytical_criterion_code      = p_anacri_code
         AND xadv.analytical_criterion_type_code = p_anacri_type_code
         AND xadv.amb_context_code               = p_amb_context_code
         AND ROWNUM = 1;

      --loop on the criterion details
      FOR current_detail IN lc_details
          ( cp_anacri_code        => p_anacri_code
           ,cp_anacri_type_code   => p_anacri_type_code
           ,cp_amb_context_code   => p_amb_context_code
          )
      LOOP
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
              ( p_module   => l_log_module
               ,p_msg   => 'analytical_detail_code: '||current_detail.analytical_detail_code
               ,p_level => C_LEVEL_STATEMENT
              );
           trace
              ( p_module   => l_log_module
               ,p_msg   => 'l_display_in_inquiries_flag: '||l_display_in_inquiries_flag
               ,p_level => C_LEVEL_STATEMENT
              );
           trace
              ( p_module   => l_log_module
               ,p_msg   => 'l_enabled_flag: '||l_enabled_flag
               ,p_level => C_LEVEL_STATEMENT
              );
           trace
              ( p_module   => l_log_module
               ,p_msg   => 'view_column_num: '||current_detail.view_column_num
               ,p_level => C_LEVEL_STATEMENT
              );
           trace
              ( p_module   => l_log_module
               ,p_msg   => 'data_type_code: '||current_detail.data_type_code
               ,p_level => C_LEVEL_STATEMENT
              );
         END IF;

         IF l_display_in_inquiries_flag = 'N' THEN

            IF current_detail.view_column_num IS NOT NULL THEN
               l_view_column_number := NULL;
               l_update_required := TRUE;

               --Remove lookup value for the reporting tool
               --TBD
            END IF;
         ELSIF l_display_in_inquiries_flag = 'Y' THEN
            IF l_enabled_flag = 'Y' THEN
               IF  current_detail.data_type_code  IS NOT NULL AND
                   current_detail.view_column_num IS NULL THEN
                  l_view_column_number := get_view_column_number
                            (p_anacri_code        => p_anacri_code
                            ,p_anacri_type_code   => p_anacri_type_code
                            ,p_anacri_detail_code => current_detail.analytical_detail_code
                            ,p_data_type_code     => current_detail.data_type_code);

                  --try to get the next free view column number for the datatype
                  IF (l_view_column_number < 0) THEN
                    l_view_column_number := get_first_free_view_col_number
                            (p_data_type_code => current_detail.data_type_code
                            ,p_balance_flag   => l_balance_flag);
                  END IF;

                  --handle error return values setting the final return value
                  IF l_view_column_number = C_CANNOT_LOCK_DETAIL_ROW THEN
                     --resource busy
                     l_return_value := C_CANNOT_LOCK_DETAIL_ROW;
                     EXIT;
                  ELSIF l_view_column_number = C_NO_AVAILABLE_VIEW_COLUMN THEN
                     --no free column available
                     l_return_value := C_NO_AVAILABLE_VIEW_COLUMN;
                     EXIT;
                  ELSE
                     --success
                     l_update_required := TRUE;
                     --Add lookup value for the reporting tool
                     --TBD

                  END IF;
               --else current view_column_number IS NOT NULL
               ELSE
                  l_update_required := FALSE;
               END IF;
            ELSIF l_enabled_flag = 'N' THEN
               --if current view_column_number IS NOT NULL
               --we remove the view column number only if no detail value exists
               IF current_detail.view_column_num IS NOT NULL AND
                  l_count_exist_dvals = 0 THEN
                  l_view_column_number := NULL;
                  l_update_required := TRUE;
                  --Remove lookup value for the reporting tool
                  --TBD
               ELSE
                  l_update_required := FALSE;
               END IF;
            ELSE
               IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                  trace
                     ( p_module   => l_log_module
                      ,p_msg   => 'EXCEPTION:'
                                  ||'Unsupported value for enabled_flag:'
                                  || l_enabled_flag
                      ,p_level => C_LEVEL_EXCEPTION
                     );
               END IF;
               xla_exceptions_pkg.raise_message
               (p_location => 'xla_analytical_criteria_pkg.compile_criterion');
            END IF;
         ELSE
            IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               trace
                  ( p_module   => l_log_module
                   ,p_msg   => 'EXCEPTION:'
                               ||'Unsupported value for'
                               || ' display_in_inquiries_flag:'
                               || l_display_in_inquiries_flag
                   ,p_level => C_LEVEL_EXCEPTION
                  );
            END IF;
            xla_exceptions_pkg.raise_message
               (p_location => 'xla_analytical_criteria_pkg.compile_criterion');

         END IF;

         IF l_update_required THEN
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'l_updated_required: '||current_detail.analytical_detail_code||
                              ', l_view_column_number = '||l_view_column_number
                  ,p_level => C_LEVEL_STATEMENT
                 );
            END IF;

            UPDATE xla_analytical_dtls_b xdtb
               SET xdtb.view_column_num = l_view_column_number
             WHERE xdtb.analytical_criterion_code      = p_anacri_code
               AND xdtb.analytical_criterion_type_code = p_anacri_type_code
               AND xdtb.amb_context_code               = p_amb_context_code
               AND xdtb.analytical_detail_code         = current_detail.analytical_detail_code;
         END IF;

      END LOOP;

   EXCEPTION
   WHEN le_resource_busy
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
                           ||'Unable to lock the records'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      l_return_value := C_CANNOT_LOCK_DETAIL_ROW;
   END;

   IF l_return_value <> C_SUCCESS
   THEN
      ROLLBACK TO START_SAVEPOINT;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         ( p_module   => l_log_module
          ,p_msg   => 'Returned value: ' || l_return_value
          ,p_level => C_LEVEL_STATEMENT
         );
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN  l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.compile_criterion');

END compile_criterion;

FUNCTION build_criteria_view
RETURN INTEGER
IS

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Refer to the Detail Level Design document                             |
+======================================================================*/

CURSOR lc_displayable_details
                ( cp_data_type_code        VARCHAR2
                )
IS
   SELECT xhdb.analytical_criterion_code
         ,xhdb.analytical_criterion_type_code
         --,xhdb.amb_context_code
         ,xdtb.analytical_detail_code
         ,xdtb.grouping_order
         ,xdtb.view_column_num
     FROM xla_analytical_hdrs_b xhdb
         ,xla_analytical_dtls_b xdtb
    WHERE xhdb.display_in_inquiries_flag      = 'Y'
      AND xdtb.analytical_criterion_code      = xhdb.analytical_criterion_code
      AND xdtb.analytical_criterion_type_code = xhdb.analytical_criterion_type_code
      AND xdtb.amb_context_code               = xhdb.amb_context_code
      AND xdtb.data_type_code                 = NVL(cp_data_type_code, xdtb.data_type_code)
   GROUP BY xhdb.analytical_criterion_code
         ,xhdb.analytical_criterion_type_code
         --,xhdb.amb_context_code
         ,xdtb.analytical_detail_code
         ,xdtb.grouping_order
         ,xdtb.view_column_num
   ORDER BY xdtb.view_column_num
;
   --FOR UPDATE NOWAIT;


l_statement                  DBMS_SQL.VARCHAR2S;
--l_hdr_statement              DBMS_SQL.VARCHAR2S;
l_rep_ln_statement           DBMS_SQL.VARCHAR2S;
l_rep_hdr_statement          DBMS_SQL.VARCHAR2S;
l_cursor_handle              NUMBER;
l_view_column_number         INTEGER;

l_current_anacri_code        VARCHAR2(30);
l_current_anacri_type_code   VARCHAR2(1);
--l_current_amb_context_code   VARCHAR2(30);
l_current_anacri_detail_code VARCHAR2(30);
l_current_grouping_order     INTEGER;
l_current_view_column_number INTEGER;

l_current_line               VARCHAR2(256);
l_current_detail_field_name  VARCHAR2(256);
l_current_detail_string_id   VARCHAR2(256);

l_ln_fixed_part_header          VARCHAR2(256) :=
'CREATE OR REPLACE VIEW xla_analytical_criteria_v (
   ae_header_id
  ,ae_line_num
';

l_hdr_fixed_part_header          VARCHAR2(256) :=
'CREATE OR REPLACE VIEW xla_analytical_criteria_hdr_v (
   ae_header_id
';

l_rep_ln_fixed_part_header          VARCHAR2(256) :=
'CREATE OR REPLACE VIEW xla_ac_lines_v AS
SELECT
   xald.ae_header_id AE_HEADER_ID
  ,xald.ae_line_num  AE_LINE_NUM
';
l_rep_hdr_fixed_part_header          VARCHAR2(256) :=
'CREATE OR REPLACE VIEW xla_ac_headers_v AS
SELECT
   xahd.ae_header_id AE_HEADER_ID
';

l_selected_field_name_template   VARCHAR2(256) :=
'analytical_detail_<N>';


l_select_row_template   VARCHAR2(256) :=
',<SELECTED_FIELD_NAME>';


l_ln_fixed_part_middle   VARCHAR2(256) :=
'
 )
AS
SELECT xald.ae_header_id
      ,xald.ae_line_num';

l_hdr_fixed_part_middle   VARCHAR2(256) :=
'
 )
AS
SELECT xahd.ae_header_id';

l_field_name_template   VARCHAR2(256) :=
'analytical_detail_<DATATYPE>_<N>';

l_field_template_fixed_part            VARCHAR2(256) :=
'      ,MAX( DECODE( xadv.analytical_criterion_type_code
                     --|| RPAD(xadv.amb_context_code, 30)
                     || xadv.analytical_criterion_code';

l_field_template_variable_part         VARCHAR2(256) :=
'                   ,''<ANALYTICAL_CRITERION_STRING_ID>'',xadv.<ANALYTICAL_DETAIL_FIELD_NAME>))';

l_field_template_null                  VARCHAR2(256) :=
'      ,MAX(DECODE( 1, 2, xadv.<ANALYTICAL_DETAIL_FIELD_NAME>))';

l_ln_fixed_part_footer_1         VARCHAR2(256) :=
'FROM xla_ae_line_details     xald
     ,xla_analytical_dtl_vals xadv';

l_hdr_fixed_part_footer_1         VARCHAR2(256) :=
'FROM xla_ae_header_details     xahd
     ,xla_analytical_dtl_vals xadv';


l_hdr_fixed_part_footer_2         VARCHAR2(256) :=
'WHERE xadv.analytical_detail_value_id     = xahd.analytical_detail_value_id
GROUP BY xahd.ae_header_id';

l_ln_fixed_part_footer_2         VARCHAR2(256) :=
'WHERE xadv.analytical_detail_value_id     = xald.analytical_detail_value_id
GROUP BY xald.ae_header_id
        ,xald.ae_line_num';


l_no_more_details           BOOLEAN;
l_return_value              INTEGER;

l_log_module                 VARCHAR2 (2000);


BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.build_criteria_view';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Initialize collection with the first fixed part of the SELECT stmt
   l_statement(1) := l_ln_fixed_part_header;
   --l_hdr_statement(1) := l_hdr_fixed_part_header;
   l_rep_ln_statement(1) := l_rep_ln_fixed_part_header;
   l_rep_hdr_statement(1) := l_rep_hdr_fixed_part_header;


   --Add the selected fields
   FOR i IN 1..C_MAX_MAPPABLE_DETAILS
   LOOP
      l_current_detail_field_name  := REPLACE(l_selected_field_name_template, '<N>', i);
      l_current_line := REPLACE(l_select_row_template, '<SELECTED_FIELD_NAME>', l_current_detail_field_name);
      l_statement (l_statement.LAST + 1) := l_current_line;
      --l_hdr_statement (l_hdr_statement.LAST + 1) := l_current_line;
   END LOOP;

   l_statement (l_statement.LAST + 1) := l_ln_fixed_part_middle   ;
   --l_hdr_statement (l_hdr_statement.LAST + 1) := l_hdr_fixed_part_middle   ;

   --Read details belonging to headers that have
   --display in inquiries and reports = yes

   DECLARE
      --function that generates the selected fields in the inner SELECT stmt
      FUNCTION loop_on_details ( p_data_type_code   VARCHAR2
                                ,p_data_type_suffix VARCHAR2
                                ,p_max_details      INTEGER
                                ,p_column_offset    INTEGER
                               )
      RETURN INTEGER
      IS
      BEGIN
         OPEN lc_displayable_details
                   ( cp_data_type_code   => p_data_type_code
                   );
         FETCH lc_displayable_details
          INTO l_current_anacri_code
              ,l_current_anacri_type_code
              --,l_current_amb_context_code
              ,l_current_anacri_detail_code
              ,l_current_grouping_order
              ,l_current_view_column_number;

         IF lc_displayable_details%NOTFOUND
         THEN
            l_no_more_details := TRUE;
         ELSE
            l_no_more_details := FALSE;
         END IF;

         FOR i IN 1..p_max_details LOOP
            IF l_no_more_details THEN
               --generate string for unassigned field
               l_current_detail_field_name  := REPLACE( l_field_name_template
                                                       ,'<DATATYPE>'
                                                       ,p_data_type_suffix
                                                      );
               l_current_detail_field_name  := REPLACE( l_current_detail_field_name
                                                       ,'<N>'
                                                       ,1
                                                      );

               l_current_line := REPLACE( l_field_template_null
                                         ,'<ANALYTICAL_DETAIL_FIELD_NAME>'
                                         ,l_current_detail_field_name
                                        );

               l_statement (l_statement.LAST + 1) := l_current_line;
               --l_hdr_statement (l_hdr_statement.LAST + 1) := l_current_line;
            ELSE
               IF i = l_current_view_column_number THEN
                  --generate string for assigned field
                  --add the fixed part of the column extract statement
                  l_statement (l_statement.LAST + 1) := '--'
                                     || (i + p_column_offset) || ': '
                                     || l_current_anacri_code
                                     || ', ' || l_current_anacri_detail_code ;
                  l_statement (l_statement.LAST + 1) :=
                                     l_field_template_fixed_part;

                  l_rep_ln_statement(l_rep_ln_statement.LAST + 1) := '-- '
                                     || l_current_anacri_code
                                     || ', ' || l_current_anacri_detail_code ;
                  l_rep_ln_statement(l_rep_ln_statement.LAST + 1) :=
                                     l_field_template_fixed_part;

                  l_rep_hdr_statement(l_rep_hdr_statement.LAST + 1) := '-- '
                                     || l_current_anacri_code
                                     || ', ' || l_current_anacri_detail_code ;
                  l_rep_hdr_statement(l_rep_hdr_statement.LAST + 1) :=
                                     l_field_template_fixed_part;

                  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                       ( p_module   => l_log_module
                        ,p_msg   => 'current detail: ' || l_current_anacri_detail_code
                        ,p_level => C_LEVEL_STATEMENT
                       );
                  END IF;

                  l_current_detail_field_name :=REPLACE( l_field_name_template
                                                        ,'<DATATYPE>'
                                                        , p_data_type_suffix
                                                       );
                  l_current_detail_field_name :=REPLACE( l_current_detail_field_name
                                                        , '<N>'
                                                        , l_current_grouping_order
                                                       );

                  l_current_detail_string_id := l_current_anacri_type_code
                                               --|| RPAD(l_current_amb_context_code, 30)
                                               || l_current_anacri_code;

                  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                     trace
                       ( p_module   => l_log_module
                        ,p_msg   => 'l_current_detail_string_id: '
                                    || l_current_detail_string_id
                        ,p_level => C_LEVEL_STATEMENT
                       );
                  END IF;

                  l_current_line := REPLACE(
                                             l_field_template_variable_part
                                            ,'<ANALYTICAL_CRITERION_STRING_ID>'
                                            ,l_current_detail_string_id
                                           );

                  l_current_line := REPLACE(
                                             l_current_line
                                            ,'<ANALYTICAL_DETAIL_FIELD_NAME>'
                                            ,l_current_detail_field_name
                                           );


                  l_statement (l_statement.LAST + 1) := l_current_line;
                  --l_hdr_statement (l_hdr_statement.LAST + 1) := l_current_line;

                  l_rep_ln_statement (l_rep_ln_statement.LAST + 1) := l_current_line ||
                                         '    L_'||l_current_anacri_type_code||'_'||l_current_anacri_detail_code;
                  l_rep_hdr_statement (l_rep_hdr_statement.LAST + 1) := l_current_line||
                                         '    H_'||l_current_anacri_type_code||'_'||l_current_anacri_detail_code;


                  --fetch following detail
                  FETCH lc_displayable_details
                  INTO l_current_anacri_code
                      ,l_current_anacri_type_code
                      --,l_current_amb_context_code
                      ,l_current_anacri_detail_code
                      ,l_current_grouping_order
                      ,l_current_view_column_number;

                  IF lc_displayable_details%NOTFOUND THEN
                     l_no_more_details := TRUE;
                  ELSE
                     l_no_more_details := FALSE;
                  END IF;
               ELSE --i=
                 --generate string for unassigned field
                  l_current_detail_field_name  := REPLACE( l_field_name_template
                                                          ,'<DATATYPE>'
                                                          ,p_data_type_suffix
                                                         );
                  l_current_detail_field_name  := REPLACE( l_current_detail_field_name
                                                          ,'<N>'
                                                          ,1
                                                         );

                  l_current_line := REPLACE( l_field_template_null
                                            ,'<ANALYTICAL_DETAIL_FIELD_NAME>'
                                            ,l_current_detail_field_name
                                           );

                  l_statement (l_statement.LAST + 1) := l_current_line;
                  --l_hdr_statement (l_hdr_statement.LAST + 1) := l_current_line;

                  --if the view column number is null log a message
                  IF l_current_view_column_number IS NULL
                  THEN
                     IF (C_LEVEL_ERROR >= g_log_level) THEN
                       trace
                       ( p_module   => l_log_module
                        ,p_msg      =>
'WARNING: view column number is null for Analytical Criterion code '
|| l_current_anacri_code || ', detail code ' || l_current_anacri_detail_code
                      ,p_level    => C_LEVEL_ERROR);
                     END IF;

                     --fetch following detail
                     FETCH lc_displayable_details
                     INTO l_current_anacri_code
                         ,l_current_anacri_type_code
                         --,l_current_amb_context_code
                         ,l_current_anacri_detail_code
                         ,l_current_grouping_order
                         ,l_current_view_column_number;

                     IF lc_displayable_details%NOTFOUND
                     THEN
                        l_no_more_details := TRUE;
                     ELSE
                        l_no_more_details := FALSE;
                     END IF;

                  END IF;
               END IF;
            END IF;
         END LOOP;

         CLOSE lc_displayable_details;

         RETURN C_SUCCESS;

      END loop_on_details;

   --begin a new block that traps the resource busy exception
   BEGIN

      --try to get a lock on all the displayable details
      --that must be included in the view
      OPEN lc_displayable_details
                ( cp_data_type_code   => NULL
                );
      CLOSE lc_displayable_details;

      --loop on the details with data type 'C'
      l_return_value := loop_on_details( p_data_type_code   => 'C'
                                        ,p_data_type_suffix => 'char'
                                        ,p_max_details      => C_MAX_MAPPABLE_VARCHAR_DETAILS
                                        ,p_column_offset    => C_MAPPABLE_VARCHAR_OFFSET
                                       );

      --loop on the details with data type 'D'
      l_return_value := loop_on_details( p_data_type_code   => 'D'
                                        ,p_data_type_suffix => 'date'
                                        ,p_max_details      => C_MAX_MAPPABLE_DATE_DETAILS
                                        ,p_column_offset    => C_MAPPABLE_DATE_OFFSET
                                       );


      --loop on the details with data type 'N'
      l_return_value := loop_on_details( p_data_type_code   => 'N'
                                        ,p_data_type_suffix => 'number'
                                        ,p_max_details      => C_MAX_MAPPABLE_NUMBER_DETAILS
                                        ,p_column_offset    => C_MAPPABLE_NUMBER_OFFSET
                                       );


   EXCEPTION
   WHEN le_resource_busy
   THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
           ( p_module   => l_log_module
            ,p_msg      => 'EXCEPTION:'
                           ||'Unable to lock the records'
            ,p_level    => C_LEVEL_EXCEPTION);
      END IF;
      l_return_value := C_CANNOT_LOCK_DETAIL_ROW;
   END;

   IF l_return_value = C_SUCCESS
   THEN

      l_statement (l_statement.LAST + 1) := l_ln_fixed_part_footer_1;
      l_statement (l_statement.LAST + 1) := l_ln_fixed_part_footer_2;
--      l_hdr_statement (l_hdr_statement.LAST + 1) := l_hdr_fixed_part_footer_1;
--      l_hdr_statement (l_hdr_statement.LAST + 1) := l_hdr_fixed_part_footer_2;
      l_rep_ln_statement (l_rep_ln_statement.LAST + 1) := l_ln_fixed_part_footer_1;
      l_rep_ln_statement (l_rep_ln_statement.LAST + 1) := l_ln_fixed_part_footer_2;
      l_rep_hdr_statement (l_rep_hdr_statement.LAST + 1) := l_hdr_fixed_part_footer_1;
      l_rep_hdr_statement (l_rep_hdr_statement.LAST + 1) := l_hdr_fixed_part_footer_2;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         FOR i IN 1..l_statement.LAST
         LOOP
            trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'View creation SQL statement:'
                  ,p_level => C_LEVEL_STATEMENT
                 );
            trace
                 ( p_module   => l_log_module
                  ,p_msg   => l_statement(i)
                  ,p_level => C_LEVEL_STATEMENT
                 );
         END LOOP;
/*
         FOR i IN 1..l_hdr_statement.LAST
         LOOP
            trace
                 ( p_module   => l_log_module
                  ,p_msg   => 'View creation SQL statement:'
                  ,p_level => C_LEVEL_STATEMENT
                 );
            trace
                 ( p_module   => l_log_module
                  ,p_msg   => l_hdr_statement(i)
                  ,p_level => C_LEVEL_STATEMENT
                 );
         END LOOP;
*/
      END IF;

      l_cursor_handle:= dbms_sql.open_cursor;
      --parse the statement
      dbms_sql.parse (
                    c              =>  l_cursor_handle
                   ,statement      =>  l_statement
                   ,lb             =>  1
                   ,ub             =>  l_statement.LAST
                   ,lfflg          =>  TRUE --line feed
                   ,language_flag  =>  DBMS_SQL.NATIVE);
      dbms_sql.close_cursor(l_cursor_handle);

      l_cursor_handle:= dbms_sql.open_cursor;
      --parse the statement
      dbms_sql.parse (
                    c              =>  l_cursor_handle
                   ,statement      =>  l_rep_ln_statement
                   ,lb             =>  1
                   ,ub             =>  l_rep_ln_statement.LAST
                   ,lfflg          =>  TRUE --line feed
                   ,language_flag  =>  DBMS_SQL.NATIVE);
      dbms_sql.close_cursor(l_cursor_handle);

      l_cursor_handle:= dbms_sql.open_cursor;
      l_cursor_handle:= dbms_sql.open_cursor;
      --parse the statement
      dbms_sql.parse (
                    c              =>  l_cursor_handle
                   ,statement      =>  l_rep_hdr_statement
                   ,lb             =>  1
                   ,ub             =>  l_rep_hdr_statement.LAST
                   ,lfflg          =>  TRUE --line feed
                   ,language_flag  =>  DBMS_SQL.NATIVE);
      dbms_sql.close_cursor(l_cursor_handle);

/*
      l_cursor_handle:= dbms_sql.open_cursor;
      --parse the statement
      dbms_sql.parse (
                    c              =>  l_cursor_handle
                   ,statement      =>  l_hdr_statement
                   ,lb             =>  1
                   ,ub             =>  l_hdr_statement.LAST
                   ,lfflg          =>  TRUE --line feed
                   ,language_flag  =>  DBMS_SQL.NATIVE);
      dbms_sql.close_cursor(l_cursor_handle);
*/
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN  l_return_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.build_criteria_view');

END build_criteria_view;

FUNCTION get_hdr_ac_count
RETURN INTEGER IS

   l_hdr_ac_count            PLS_INTEGER;
   l_mpa_hdr_ac_count        PLS_INTEGER;
   l_log_module              VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_hdr_ac_count';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

    IF g_hdr_ac_count IS NOT NULL THEN

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_module   => l_log_module
           ,p_msg      => 'g_hdr_ac_count(cached): ' || g_hdr_ac_count
           ,p_level    => C_LEVEL_PROCEDURE);
         trace
           (p_module   => l_log_module
           ,p_msg      => 'END ' || l_log_module
           ,p_level    => C_LEVEL_PROCEDURE);
       END IF;

       RETURN g_hdr_ac_count;

    ELSE

       --
       -- MAX(COUNT(1)) with GROUP BY could return null
       -- when there is no row in the table. Added NVL.
       --
       SELECT NVL(MAX(COUNT(1)),0)
         INTO l_hdr_ac_count
         FROM xla_aad_header_ac_assgns
        GROUP BY
              amb_context_code
             ,application_id
             ,product_rule_type_code
             ,product_rule_code
             ,event_class_code
             ,event_type_code;

       -- MPA Header ACs
       SELECT NVL(MAX(COUNT(1)),0)
         INTO l_mpa_hdr_ac_count
         FROM xla_mpa_header_ac_assgns
        GROUP BY
              amb_context_code
             ,application_id
             ,event_class_code
             ,event_type_code
             ,line_definition_owner_code
             ,line_definition_code
             ,accounting_line_type_code
             ,accounting_line_code;

       IF l_hdr_ac_count >= l_mpa_hdr_ac_count THEN
          g_hdr_ac_count := l_hdr_ac_count;
       ELSE
          g_hdr_ac_count := l_mpa_hdr_ac_count;
       END IF;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_module   => l_log_module
           ,p_msg      => 'g_hdr_ac_count(db): ' || g_hdr_ac_count
           ,p_level    => C_LEVEL_PROCEDURE);
         trace
           (p_module   => l_log_module
           ,p_msg      => 'END ' || l_log_module
           ,p_level    => C_LEVEL_PROCEDURE);
       END IF;

       RETURN g_hdr_ac_count;

   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.get_hdr_ac_count');

END get_hdr_ac_count;

FUNCTION get_line_ac_count
RETURN INTEGER IS

   l_line_ac_count           PLS_INTEGER;
   l_mpa_line_ac_count       PLS_INTEGER;
   l_log_module              VARCHAR2(255);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.get_line_ac_count';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   IF g_line_ac_count IS NOT NULL THEN

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
           (p_module   => l_log_module
           ,p_msg      => 'g_line_ac_count(cached): ' || g_line_ac_count
          ,p_level    => C_LEVEL_PROCEDURE);
         trace
          (p_module   => l_log_module
          ,p_msg      => 'END ' || l_log_module
          ,p_level    => C_LEVEL_PROCEDURE);
      END IF;

      RETURN g_line_ac_count;

   ELSE

      SELECT NVL(MAX(COUNT(1)),0)
        INTO l_line_ac_count
        FROM xla_line_defn_ac_assgns
       GROUP BY
             amb_context_code
            ,application_id
            ,event_class_code
            ,event_type_code
            ,line_definition_owner_code
            ,line_definition_code
            ,accounting_line_type_code
            ,accounting_line_code;

      SELECT NVL(MAX(COUNT(1)),0)
        INTO l_mpa_line_ac_count
        FROM xla_mpa_jlt_ac_assgns
       GROUP BY
             amb_context_code
            ,application_id
            ,event_class_code
            ,event_type_code
            ,line_definition_owner_code
            ,line_definition_code
            ,accounting_line_type_code
            ,accounting_line_code;

      IF l_line_ac_count >= l_mpa_line_ac_count THEN
         g_line_ac_count := l_line_ac_count;
      ELSE
         g_line_ac_count := l_mpa_line_ac_count;
      END IF;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'g_line_ac_count(db): ' || g_line_ac_count
         ,p_level    => C_LEVEL_PROCEDURE);
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN g_line_ac_count;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.get_line_ac_count');
END get_line_ac_count;

/*
FUNCTION uncompile_product_rules ( p_anacri_code              IN VARCHAR2
                                  ,p_anacri_type_code         IN VARCHAR2
                                  ,p_amb_context_code         IN VARCHAR2
                                 )
RETURN INTEGER
IS
*/
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Description                                                           |
| -----------                                                           |
| Refer to the Detail Level Design document                             |
+======================================================================*/
/*
CURSOR lc_assigned_rules
   SELECT xpr.name
     FROM xla_product_rules_vl   xpr
    WHERE ( xpr.application_id
           ,xpr.amb_context_code
           ,xpr.product_rule_type_code
           ,xpr.product_rule_code
          )
      IN ( SELECT DISTINCT
                  xaa.application_id
		 ,xaa.amb_context_code
		 ,xaa.product_rule_type_code
                 ,xaa.product_rule_code
             FROM xla_analytical_assgns xaa
            WHERE xaa.amb_context_code               = p_amb_context_code
              AND xaa.analytical_criterion_code      = p_anacri_code
              AND xaa.analytical_criterion_type_code = p_anacri_type_code
          )
      AND xpr.compile_status_code       IN ('E','N','Y')
--      AND xpr.locking_status_flag       = 'N'
   FOR UPDATE of compile_status_code NOWAIT;

l_log_module                 VARCHAR2 (2000);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.uncompile_product_rules';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'BEGIN ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   --Loop on all the accounting definitions the criterion is assigned to
   FOR i IN lc_assigned_rules
   LOOP
      If the
      IF i.locking_status_flag = 'Y'
      THEN
         --store the
      END IF;

   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_module   => l_log_module
         ,p_msg      => 'END ' || l_log_module
         ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN  l_return_value;

EXCEPTION
WHEN le_resource_busy
THEN
     trace('get_first_free_view_col_number could not lock the records', 20);
     l_return_value := ;
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_analytical_criteria_pkg.uncompile_product_rules');

END uncompile_product_rules;
*/

BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;


END xla_analytical_criteria_pkg;

/
