--------------------------------------------------------
--  DDL for Package Body XLA_UPGRADE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_UPGRADE_PUB" AS
-- $Header: xlaugupg.pkb 120.41.12010000.7 2009/08/25 09:22:29 vgopiset ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlaugupg.pkb                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    XLA_UPGRADE_PUB                                                         |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a XLA package which contains all the APIs required by the       |
|    product teams to validate data in journal entry tables and also to      |
|    input data in analytical criteria and ae segment values tables.         |
| HISTORY                                                                    |
|    15-Dec-04 G. Bellary      Created                                       |
|    23-Dec-05 Koushik VS      Modification of validation entries            |
|    04-Jan-06 Koushik VS      Modification of set_status_code being used    |
|                              for Upgrade On Demand Project                 |
|    15-Feb-06 Jorge Larre     Bug 5011584                                   |
|       Set je_from_sla_flag to 'U' as part of the upgrade                   |
|    16-May-06 Jorge Larre     Add pre_upgrade_set_status_code               |
|    19-May-06 Jorge Larre     Add the call to AR upgrade program as per     |
|       Herve Yu's confirmation by mail.                                     |
|    25-May-06 Jorge Larre     Bug 5222005: populate l_source_name from      |
|       XLA_SUBLEDGERS instead of populating l_application_name from         |
|       FND_APPLICATIONS_VL, and use it to select the lines to update in     |
|       GL_JE_HEADERS.                                                       |
|    17-Aug-2006 Jorge Larre  Bug 5468416: Add a parameter of type VARCHAR2  |
|       to call the Costing upgrade program.                                 |
|    24-Aug-2006 Jorge Larre  Bug 5473838: when calling the Costing upgrade  |
|       program, X_init_msg_list must be passed the value FND_API.G_FALSE.   |
|    05-SEP-2006 Jorge Larre  Bug 5484337: AR needs to store the calling     |
|       parameters in a new table (XLA_UPGRADE_REQUESTS). Add ledger_id and  |
|       period_name as calling parameters in set_status_code.                |
|    07-NOV-2006 Jorge Larre  Bug 5648571: Obsolete the procedure            |
|       set_status_code. This change is to be in sync with xlaugupg.pkh.     |
|       The code is left commented in case we decide to use it again.        |
|    22-JUL-2009  VGOPISET    Bug 8717476 Enabled Procedures SET_STATUS_CODE |
|                             and added procedures: UPDATE_UPG_REQUEST_STATUS|
|                             and RESET_PERIOD_STATUSES.                     |
|    24-AUG-2009  VGOPISET    Bug 8834301 Resetting the Periods to NULL from |
|                             PENDING when EXCEPTION is raised by Product API|
+===========================================================================*/
--=============================================================================
--           ****************  declarations  ********************
--=============================================================================


-------------------------------------------------------------------------------
-- declaring global variables
-------------------------------------------------------------------------------

   g_batch_id INTEGER ;
   g_batch_size INTEGER := 30000;
   g_source_application_id NUMBER ;
   g_application_id NUMBER;
   g_validate_complete xla_upg_batches.VALIDATE_COMPLETE_FLAG%TYPE;
   g_crsegvals_complete  xla_upg_batches.CRSEGVALS_COMPLETE_FLAG%TYPE;
-------------------------------------------------------------------------------
-- declaring global pl/sql types
-------------------------------------------------------------------------------

   TYPE t_entity_id IS TABLE OF
      xla_transaction_entities.entity_id%type
   INDEX BY BINARY_INTEGER;
   TYPE t_error_flag     IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
   TYPE t_event_id IS TABLE OF
      xla_events.event_id%type
   INDEX BY BINARY_INTEGER;
   TYPE t_header_id IS TABLE OF
      xla_ae_headers.ae_header_id%type
   INDEX BY BINARY_INTEGER;
   TYPE t_line_num IS TABLE OF
      xla_ae_lines.ae_line_num%type
   INDEX BY BINARY_INTEGER;
   TYPE t_seg_value IS TABLE OF
      xla_ae_segment_values.segment_value%type
   INDEX BY BINARY_INTEGER;
   TYPE t_line_count IS TABLE OF
      xla_ae_segment_values.ae_lines_count%type
   INDEX BY BINARY_INTEGER;
   TYPE t_seg_type IS TABLE OF
      xla_ae_segment_values.segment_type_code%type
   INDEX BY BINARY_INTEGER;
   TYPE t_error_id IS TABLE OF
      xla_upg_errors.upg_error_id%type
   INDEX BY BINARY_INTEGER;
   TYPE T_ARRAY_LEDGER_ID IS TABLE OF XLA_TRANSACTION_ENTITIES.LEDGER_ID%TYPE
                               INDEX BY BINARY_INTEGER ; -- bug:8717476

-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------
-- The segment type code
C_BAL_SEGMENT                   CONSTANT VARCHAR2(1) := 'B';
C_MGT_SEGMENT                   CONSTANT VARCHAR2(1) := 'M';
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

C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_UPGRADE_PUB';
/* new constant values added for 8717476 */
C_PROGRESS_STATUS     CONSTANT VARCHAR2(30) := 'IN PROGRESS';
C_ERROR_STATUS        CONSTANT VARCHAR2(30) := 'ERROR';
C_SUCCESS_STATUS      CONSTANT VARCHAR2(30) := 'FINISHED';
C_INITIAL_STATUS      CONSTANT VARCHAR2(30) := 'INITIAL ROW';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;
g_array_ledger_id     T_ARRAY_LEDGER_ID ; -- bug:8717476

-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------
PROCEDURE recover_previous_run;
--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
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
         (p_location   => 'XLA_UPGRADE_PUB.trace');
END trace;

--=============================================================================
--      ********** Procedure to Update the Upgrade Request Status**********
--      **********          added for bug: 8717476               **********
--=============================================================================
PROCEDURE Update_upg_request_status
     (p_application_id  IN NUMBER,
      p_status_code     IN VARCHAR2)
IS
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := c_default_module
                    ||'.update_upg_request_status';
  END IF;

  IF (c_level_statement >= g_log_level) THEN
    Trace('update_upg_request_status.Begin',c_level_statement,
          l_log_module);

    Trace('Status being Updated for Application: '
          ||p_application_id
          ||' is: '
          ||p_status_code,c_level_statement,l_log_module);
  END IF;

  UPDATE xla_upgrade_requests
  SET    status_code = p_status_code,
         last_update_date = SYSDATE
  WHERE  application_id = p_application_id
  AND program_code = 'ONDEMAND UPGRADE'
  AND status_code <> C_SUCCESS_STATUS;

  COMMIT;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    xla_exceptions_pkg.Raise_message(p_location => 'XLA_UPGRADE_PUB.update_upg_request_status');
END update_upg_request_status;

--=============================================================================
--****** Procedure to RESET periods selected for UPGRADE as NOT-MIGRATED ******
--**********                 added for bug: 8717476                      ******
--=============================================================================
PROCEDURE Reset_period_statuses
     (p_application_id  IN NUMBER)
IS
  l_log_module  VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := c_default_module
                    ||'.reset_period_statuses';
  END IF;

  IF (c_level_statement >= g_log_level) THEN
    Trace('reset_period_statuses.Begin',c_level_statement,
          l_log_module);
  END IF;

  IF p_application_id = 275 THEN
    NULL;
  -- Commented as Project's is not participating in this Upgrade.
  /*
  FOR i IN 1..g_array_ledger_id.COUNT
        LOOP
        UPDATE gl_period_statuses gps
        SET migration_status_code = NULL
        WHERE   gps.migration_status_code = 'P'
        AND     gps.application_id IN (275, 8721)
        AND     gps.adjustment_period_flag = 'N'
	AND     gps.closing_status in ('F', 'O', 'C', 'N')
	AND     gps.ledger_id =  g_array_ledger_id(i) ;

              fnd_file.put_line(fnd_file.log, '*Migration status code Updated to NULL for ledger_id : '|| g_array_ledger_id(i)
                                        || ' are : '|| to_char(SQL%ROWCOUNT));
         END LOOP;
  */
  ELSE
    FOR i IN 1.. g_array_ledger_id.COUNT LOOP
      UPDATE gl_period_statuses gps
      SET    migration_status_code = NULL
      WHERE  gps.migration_status_code = 'P'
      AND gps.application_id = p_application_id
      AND gps.adjustment_period_flag = 'N'
      AND gps.closing_status in ('F', 'O', 'C', 'N')
      AND gps.ledger_id = g_array_ledger_id(i);

      fnd_file.Put_line(fnd_file.LOG,'*Migration status code Updated to NULL for ledger_id : '
                                     ||G_array_ledger_id(i)
                                     ||' are : '
                                     ||To_char(SQL%ROWCOUNT));
    END LOOP;
  END IF;

  COMMIT;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    xla_exceptions_pkg.Raise_message(p_location => 'XLA_UPGRADE_PUB.reset_period_statuses');
END reset_period_statuses;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Insert_Line_Criteria                                                        |
|                                                                             |
| This routine is called to insert line criteria.                             |
|                                                                             |
+============================================================================*/
PROCEDURE Insert_Line_Criteria  (
                                  p_batch_id IN NUMBER
                                , p_batch_size IN NUMBER
				, p_application_id IN NUMBER
				, p_error_detected OUT NOCOPY BOOLEAN
				, p_overwrite_flag IN BOOLEAN)
IS
   l_log_module                VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Insert_Line_Criteria';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Insert_Line_Criteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;
   SAVEPOINT before_insert_criteria;
   IF p_overwrite_flag
   THEN
      delete xla_ae_line_details xal
      where (ae_header_id, ae_line_num) IN
                    (select xlgt.ae_header_id,ae_line_num
                     from   xla_upg_line_criteria_gt xlgt
		     where  xal.ae_header_id = xlgt.ae_header_id
		     and    xal.ae_line_num = xlgt.ae_line_num);
   END IF;
   update xla_upg_line_criteria_gt xlgt
   set    error_message_name = 'XLA_UPG_INVALID_CRITERIA'
   where  NOT EXISTS
             (select  1
	      from    xla_analytical_hdrs_b xanh
	      where   xanh.amb_context_code = 'DEFAULT'
	      and     xanh.analytical_criterion_code = xlgt.analytical_criterion_code
	      and     xanh.analytical_criterion_type_code = xlgt.analytical_criterion_type_code);
   IF ( SQL%ROWCOUNT > 0 ) THEN
      p_error_detected := true;
   ELSE
      p_error_detected := false;
   END IF;

   INSERT INTO xla_analytical_dtl_vals
            (
              analytical_detail_value_id
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
    SELECT    xla_analytical_dtl_vals_s.nextval
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
             ,sysdate
             ,-1
             ,sysdate
             ,-1
             ,-1
   FROM (    SELECT
             DISTINCT
              analytical_criterion_code
             ,analytical_criterion_type_code
             ,'DEFAULT' amb_context_code
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
        FROM
            XLA_UPG_LINE_CRITERIA_GT
        WHERE ERROR_MESSAGE_NAME IS NOT NULL
   ) adv1
   WHERE NOT exists ( SELECT 'x'
              FROM xla_analytical_dtl_vals adv2
              WHERE adv1.analytical_criterion_code      = adv2.analytical_criterion_code
              AND   adv1.analytical_criterion_type_code = adv2.analytical_criterion_type_code
               AND  adv1.amb_context_code               = adv2.amb_context_code
--Detail 1
               AND NVL( adv1.analytical_detail_char_1
                       ,NVL( TO_CHAR( adv1.analytical_detail_date_1
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( adv1.analytical_detail_number_1
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv2.analytical_detail_char_1
                         ,NVL( TO_CHAR( adv2.analytical_detail_date_1
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv2.analytical_detail_number_1
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
               --Detail 2
               AND NVL( adv1.analytical_detail_char_2
                       ,NVL( TO_CHAR( adv1.analytical_detail_date_2
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( adv1.analytical_detail_number_2
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv2.analytical_detail_char_2
                         ,NVL( TO_CHAR( adv2.analytical_detail_date_2
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv2.analytical_detail_number_2
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
               --Detail 3
               AND NVL( adv1.analytical_detail_char_3
                       ,NVL( TO_CHAR( adv1.analytical_detail_date_3
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( adv1.analytical_detail_number_3
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv2.analytical_detail_char_3
                         ,NVL( TO_CHAR( adv2.analytical_detail_date_3
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv2.analytical_detail_number_3
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
               --Detail 4
               AND NVL( adv1.analytical_detail_char_4
                       ,NVL( TO_CHAR( adv1.analytical_detail_date_4
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( adv1.analytical_detail_number_4
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv2.analytical_detail_char_4
                         ,NVL( TO_CHAR( adv2.analytical_detail_date_4
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv2.analytical_detail_number_4
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
               --Detail 5
               AND NVL( adv1.analytical_detail_char_5
                       ,NVL( TO_CHAR( adv1.analytical_detail_date_5
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( adv1.analytical_detail_number_5
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv2.analytical_detail_char_5
                         ,NVL( TO_CHAR( adv2.analytical_detail_date_5
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv2.analytical_detail_number_5
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
                   );

   INSERT INTO XLA_AE_LINE_DETAILS
            (
              ae_header_id
             , ae_line_num
             , analytical_detail_value_id
            )
   SELECT    adv.analytical_detail_value_id
             ,alcg.ae_header_id
             ,alcg.ae_line_num

   FROM
            XLA_UPG_LINE_CRITERIA_GT alcg, xla_analytical_dtl_vals adv
   WHERE       --Detail 1
                   NVL( alcg.analytical_detail_char_1
                       ,NVL( TO_CHAR( alcg.analytical_detail_date_1
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( alcg.analytical_detail_number_1
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv.analytical_detail_char_1
                         ,NVL( TO_CHAR( adv.analytical_detail_date_1
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv.analytical_detail_number_1
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
               --Detail 2
               AND NVL( alcg.analytical_detail_char_2
                       ,NVL( TO_CHAR( alcg.analytical_detail_date_2
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( alcg.analytical_detail_number_2
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv.analytical_detail_char_2
                         ,NVL( TO_CHAR( adv.analytical_detail_date_2
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv.analytical_detail_number_2
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
               --Detail 3
               AND NVL( alcg.analytical_detail_char_3
                       ,NVL( TO_CHAR( alcg.analytical_detail_date_3
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( alcg.analytical_detail_number_3
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv.analytical_detail_char_3
                         ,NVL( TO_CHAR( adv.analytical_detail_date_3
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv.analytical_detail_number_3
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
               --Detail 4
               AND NVL( alcg.analytical_detail_char_4
                       ,NVL( TO_CHAR( alcg.analytical_detail_date_4
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( alcg.analytical_detail_number_4
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv.analytical_detail_char_4
                         ,NVL( TO_CHAR( adv.analytical_detail_date_4
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv.analytical_detail_number_4
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        )
               --Detail 5
               AND NVL( alcg.analytical_detail_char_5
                       ,NVL( TO_CHAR( alcg.analytical_detail_date_5
                                     ,'J'||'.'||'HH24MISS'
                                    )
                            ,NVL( TO_CHAR( alcg.analytical_detail_number_5
                                          ,'TM'
                                          ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                         )
                                 ,'%'
                                )
                           )
                      )
                   = NVL( adv.analytical_detail_char_5
                         ,NVL( TO_CHAR( adv.analytical_detail_date_5
                                       ,'J'||'.'||'HH24MISS'
                                      )
                              ,NVL( TO_CHAR( adv.analytical_detail_number_5
                                            ,'TM'
                                            ,'NLS_NUMERIC_CHARACTERS = ''.,'''
                                           )
                                   ,'%'
                                  )
                             )
                        );
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure Insert_Line_Criteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      ROLLBACK to SAVEPOINT before_insert_criteria;
      RAISE;
   WHEN OTHERS                                   THEN
      ROLLBACK to SAVEPOINT before_insert_criteria;
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPGRADE_PUB.Validate_Entries');
END Insert_Line_Criteria;
/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| recover_previous_run                                                        |
|                                                                             |
| This routine is called to recover the previous run.                         |
|                                                                             |
+============================================================================*/
PROCEDURE recover_previous_run IS
   cursor csr_previous_entity_errors IS
   select entity_id
   from xla_upg_errors
   where  error_level = 'N'
   and    upg_batch_id = g_batch_id;

   cursor csr_previous_event_errors IS
   select event_id
   from xla_upg_errors
   where  error_level = 'E'
   and    upg_batch_id = g_batch_id;

   cursor csr_previous_header_errors IS
   select distinct ae_header_id
   from   xla_upg_errors
   where  error_level IN ('H','L','D')
   and    upg_batch_id = g_batch_id;

   cursor csr_previous_errors IS
   select upg_error_id
   from   xla_upg_errors
   where  upg_batch_id = g_batch_id;

   cursor csr_segs_previous_run IS
   select ae_header_id, segment_type_code
   from   xla_ae_segment_values
   where  upg_batch_id = g_batch_id;

   -- Local Variables
   l_entity_id   t_entity_id;
   l_event_id    t_event_id;
   l_header_id   t_header_id;
   l_error_id    t_error_id;
   l_seg_type    t_seg_type;

BEGIN
   OPEN csr_previous_entity_errors;
   LOOP

      FETCH csr_previous_entity_errors
      BULK COLLECT INTO
           l_entity_id
      LIMIT g_batch_size;
      EXIT when l_entity_id.COUNT = 0;

      FORALL i IN l_entity_id.FIRST..l_entity_id.LAST
         update xla_transaction_entities_upg
         set    upg_valid_flag = null
         where  entity_id = l_entity_id(i);

   COMMIT;
   END LOOP;
   CLOSE csr_previous_entity_errors;

   OPEN csr_previous_event_errors;
   LOOP
      FETCH csr_previous_event_errors
      BULK COLLECT INTO
           l_event_id
      LIMIT g_batch_size;
      EXIT WHEN l_event_id.COUNT = 0;

      FORALL i IN l_event_id.FIRST..l_event_id.LAST
         update xla_events
         set    upg_valid_flag = null
         where  event_id = l_event_id(i);

   COMMIT;
   END LOOP;
   CLOSE csr_previous_event_errors;
   OPEN csr_previous_header_errors;
   LOOP
      FETCH csr_previous_header_errors
      BULK COLLECT INTO
           l_header_id
      LIMIT g_batch_size;
      EXIT WHEN l_header_id.COUNT = 0;

      FORALL i IN l_header_id.FIRST..l_header_id.LAST
         update xla_ae_headers
         set    upg_valid_flag = null
         where  ae_header_id  = l_header_id(i)
         and    application_id = g_application_id;

   COMMIT;
   END LOOP;
   CLOSE csr_previous_header_errors;

   OPEN csr_previous_errors;
   LOOP
      FETCH csr_previous_errors
      BULK COLLECT INTO
           l_error_id
      LIMIT g_batch_size;
      EXIT WHEN l_error_id.COUNT = 0;

      FORALL i IN l_error_id.FIRST..l_error_id.LAST
	 delete xla_upg_errors
         where  upg_error_id  = l_error_id(i);

   COMMIT;
   END LOOP;
   CLOSE csr_previous_errors;

   OPEN csr_segs_previous_run;
   LOOP
      FETCH csr_segs_previous_run
      BULK COLLECT INTO
           l_header_id, l_seg_type
      LIMIT g_batch_size;
      EXIT WHEN l_header_id.COUNT = 0;

      FORALL i IN l_header_id.FIRST..l_header_id.LAST
         delete xla_ae_segment_values
         where  ae_header_id = l_header_id(i)
	 and    segment_type_code = l_seg_type(i);

   COMMIT;
   END LOOP;
   CLOSE csr_segs_previous_run;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPGRADE_PUB.recover_previous_run');

END recover_previous_run;
/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Set_Migration_Status_Code                                                   |
|                                                                             |
| This routine is called to set the migration status code for an upgrade      |
| for the particular periods.                                                 |
+============================================================================*/
FUNCTION set_migration_status_code
(p_application_id   in number,
 p_set_of_books_id  in number,
 p_period_name      in varchar2 default null,
 p_period_year      in number default null)
return varchar2 IS

p_status_code      varchar2(10);
l_application_id   number;
l_set_of_books_id  number;
l_period_name      varchar2(15) ;
l_period_year      number ;
L_LOG_MODULE       VARCHAR2(240);

begin

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Set_Migration_Status_Code';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Set_Migration_Status_Code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

    l_application_id    := p_application_id;
    l_set_of_books_id   := p_set_of_books_id;
    l_period_name       := p_period_name;
    l_period_year       := p_period_year;

    if (l_application_id is null ) then
       p_status_code := 'F';
       return p_status_code;
    end if;


    if ( l_set_of_books_id is null ) then

       if (l_period_name is null and l_period_year is null) then

      	 update gl_period_statuses
	    set migration_status_code = 'U'
	  where application_id        = l_application_id
	    and migration_status_code = 'P';

	 p_status_code := 'P';
	 COMMIT;
	 return p_status_code;

       elsif l_period_name is null then

	 update gl_period_statuses
   	    set migration_status_code = 'U'
	  where period_year           = l_period_year
	    and migration_status_code = 'P'
	    and application_id        = l_application_id;

	 p_status_code := 'P';
	 COMMIT;
	 return p_status_code;

       elsif l_period_year is null then

	 update gl_period_statuses
  	    set migration_status_code = 'U'
 	  where period_name           = l_period_name
	    and migration_status_code = 'P'
	    and application_id        = l_application_id;

	 p_status_code := 'P';
	 COMMIT;
         return p_status_code;

       elsif (l_period_name is not null and l_period_year is not null) then

	  update gl_period_statuses
	     set migration_status_code = 'U'
	   where period_year           = l_period_year
 	     and period_name           = l_period_name
	     and migration_status_code = 'P'
	     and application_id        = l_application_id;

	  p_status_code := 'P';
	  COMMIT;
	  return p_status_code;

       end if;

   end if;

/* Set_Of_Books_ID is not null */

  if (l_period_name is null and l_period_year is null) then

      update gl_period_statuses
         set migration_status_code = 'U'
       where application_id        = l_application_id
         and migration_status_code = 'P'
         and ledger_id             = l_set_of_books_id;

      p_status_code := 'P';
      COMMIT;
      return p_status_code;

  elsif l_period_name is null then

      update gl_period_statuses
 	 set migration_status_code = 'U'
       where period_year           = l_period_year
	 and migration_status_code = 'P'
	 and ledger_id             = l_set_of_books_id
	 and application_id        = l_application_id;

      p_status_code := 'P';
      COMMIT;
      return p_status_code;

  elsif l_period_year is null then

      update gl_period_statuses
	 set migration_status_code = 'U'
       where period_name           = l_period_name
	 and migration_status_code = 'P'
	 and ledger_id             = l_set_of_books_id
	 and application_id        = l_application_id;

      p_status_code := 'P';
      COMMIT;
      return p_status_code;

  elsif (l_period_name is not null and l_period_year is not null) then

      update gl_period_statuses
         set migration_status_code = 'U'
       where period_year           = l_period_year
         and period_name           = l_period_name
         and migration_status_code = 'P'
         and ledger_id             = l_set_of_books_id
         and application_id        = l_application_id;

      p_status_code := 'P';
      COMMIT;
      return p_status_code;

  end if;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of procedure Set_Migration_Status_Code'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN

      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
           trace
             (p_msg      => 'Set_Migration_Status_Code ended in error'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
      END IF;

      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'XLA_UPGRADE_PUB.Set_Migration_Status_Code');

end set_migration_status_code;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Set_Status_Code                                                             |
|                                                                             |
| This procedure is called during the Upgrade On-Demand, to update the        |
| status code, and also to call the product team hooks.                       |
+============================================================================*/

PROCEDURE Set_status_code
     (p_errbuf          OUT NOCOPY VARCHAR2,
      p_retcode            OUT NOCOPY NUMBER,
      p_application_id     IN NUMBER,
      p_ledger_id          IN NUMBER,
      p_period_name        IN VARCHAR2,
      p_number_of_workers  IN NUMBER,
      p_batch_size         IN NUMBER)
IS
  l_application_id            NUMBER;
  l_source_name               xla_subledgers.je_source_name%TYPE;
  l_application_name          fnd_application_vl.application_name%TYPE;
  l_ledger_id                 NUMBER;
  l_period_name               VARCHAR2(15);
  l_upgraded_period_name      VARCHAR2(15);
  l_batch_size                NUMBER;
  l_number_of_workers         NUMBER;
  l_error_buf                 VARCHAR2(1000);
  l_retcode                   NUMBER      := -1 ;
  l_processed                 VARCHAR2(1) := ' ';
  l_start_date                DATE;
  l_end_date                  DATE;
  l_log_module                VARCHAR2(240);
  no_upgrade                  EXCEPTION;
  upgrade_error               EXCEPTION;
  l_temp                      BOOLEAN;
  l_retcode_char              VARCHAR2(10);
  /* variables added for bug:8717476 */
  l_program_running           NUMBER;
  l_prev_run_status           VARCHAR2(20);
  l_hotpatch_running          NUMBER;
  mutliple_prgms_running      EXCEPTION;
  recovery_run_incorrect      EXCEPTION;
  incorrect_upg_date          EXCEPTION;
  pending_periods             EXCEPTION;
  un_registered_application   EXCEPTION;
  incorrect_prior_run_status  EXCEPTION;
  upgrade_by_patch_running    EXCEPTION;
  l_upg_ledger_name           VARCHAR2(30);
  l_upg_ledger_id             NUMBER;
  l_upg_start_date            DATE;
  l_upg_end_date              DATE;
  l_upg_period_name           VARCHAR2(15);
  l_upg_batch_size            NUMBER;
  l_upg_number_of_workers     NUMBER;
  l_pending_periods           NUMBER;
  l_step_value                VARCHAR2(100);
  C_DEFAULT_BATCH_SIZE        NUMBER := 10000 ;
  C_DEFAULT_NUM_OF_WORKERS    NUMBER := 1 ;
  /* end of new variables */

  -- Cursor to get the Ledger and Minimum Upgraded Period for Projects Accounting
  -- Projects use 275 application of Oralce Grants(8721)
  CURSOR c_pa_last_date(i_ledger_id NUMBER) IS
    SELECT   gps.ledger_id       ledger_id,
             Min(gps.start_date) last_date
    FROM     gl_period_statuses gps
    WHERE    gps.migration_status_code = 'U'
             AND gps.application_id IN (275,8721)
             AND gps.ledger_id IN (SELECT l.ledger_id
                                   FROM   gl_ledgers l
                                   WHERE  l.ledger_id IN (SELECT DISTINCT target_ledger_id
                                                          FROM   gl_ledger_relationships glr
                                                          WHERE  glr.primary_ledger_id = i_ledger_id
                                                                 AND glr.application_id = 101
                                                                 AND ((glr.target_ledger_category_code IN ('SECONDARY','ALC')
                                                                       AND glr.relationship_type_code = 'SUBLEDGER')
                                                                       OR (glr.target_ledger_category_code IN ('PRIMARY')
                                                                           AND glr.relationship_type_code = 'NONE')))

                                          AND Nvl(l.complete_flag,'Y') = 'Y')
    GROUP BY gps.ledger_id;

  -- Cursor to get the Ledger and Minimum Upgraded Period for NON-Projects Accounting
  CURSOR c_last_date(i_application_id NUMBER,
                      i_ledger_id NUMBER) IS
    SELECT   gps.ledger_id   ledger_id,
             Min(start_date) last_date
    FROM     gl_period_statuses gps
    WHERE    gps.migration_status_code = 'U'
             AND gps.application_id = i_application_id
             AND gps.ledger_id IN (SELECT l.ledger_id
                                   FROM   gl_ledgers l
                                   WHERE  l.ledger_id IN (SELECT DISTINCT target_ledger_id
                                                          FROM   gl_ledger_relationships glr
                                                          WHERE  glr.primary_ledger_id = i_ledger_id
                                                                 AND glr.application_id = 101
                                                                 AND ((glr.target_ledger_category_code IN ('SECONDARY','ALC')
                                                                       AND glr.relationship_type_code = 'SUBLEDGER')
                                                                       OR (glr.target_ledger_category_code IN ('PRIMARY')
                                                                           AND glr.relationship_type_code = 'NONE')))
                                          AND Nvl(l.complete_flag,'Y') = 'Y')
    GROUP BY gps.ledger_id;
BEGIN
  IF g_log_enabled THEN
    l_log_module := c_default_module
                    ||'.set_status_code';
  END IF;

  IF (c_level_statement >= g_log_level) THEN
    Trace('set_status_code.Begin',c_level_statement,
          l_log_module);
  END IF;

  IF p_batch_size IS NOT NULL THEN
    l_batch_size := p_batch_size;
  ELSE
    l_batch_size := C_DEFAULT_BATCH_SIZE ;
  END IF;

  IF p_number_of_workers IS NOT NULL THEN
    l_number_of_workers := p_number_of_workers;
  ELSE
    l_number_of_workers := C_DEFAULT_NUM_OF_WORKERS ;
  END IF;

  l_application_id := p_application_id;

  l_period_name := p_period_name;

  l_ledger_id := p_ledger_id;

  IF (c_level_statement >= g_log_level) THEN
    Trace('l_application_id '
          ||l_application_id,c_level_statement,l_log_module);
  END IF;

  IF (c_level_statement >= g_log_level) THEN
    Trace('l_ledger_id '
          ||l_ledger_id,c_level_statement,l_log_module);
  END IF;

  IF (c_level_statement >= g_log_level) THEN
    Trace('l_period_name '
          ||l_period_name,c_level_statement,l_log_module);
  END IF;

  IF (c_level_statement >= g_log_level) THEN
    Trace('l_number_of_workers '
          ||l_number_of_workers,c_level_statement,l_log_module);
  END IF;

  IF (c_level_statement >= g_log_level) THEN
    Trace('l_batch_size '
          ||l_batch_size,c_level_statement,l_log_module);
  END IF;

  SELECT application_name
  INTO   l_application_name
  FROM   fnd_application_vl v
  WHERE  v.application_id = p_application_id;


  /* 707 - Cost Management     201 - Purchasing
     200 - Payables            222 - Receivables      140 - Fixed Assets
     New Applications need to add application ID here */
  IF p_application_id NOT IN (707,201,200,222,140) THEN
    RAISE un_registered_application;
  END IF;

  /* FA uses GL's period
     Cost Management Uses Inventory Periods */
  IF p_application_id = 140 THEN
    l_application_id := 101;
  ELSIF p_application_id = 707 THEN
    l_application_id := 401;
  END IF;

  -- This has been achieved by CP Incompatibility, by making upgrade CP incompatible with itself.
  /*
  -- Check that no TWO Upgrade Program's Run at the SAME TIME
  SELECT Count(1)
  INTO   l_program_running
  FROM   fnd_concurrent_requests fcr
  WHERE  (fcr.program_application_id,fcr.concurrent_program_id) IN (SELECT fcp.application_id,
                                                                           fcp.concurrent_program_id
                                                                    FROM   fnd_concurrent_programs fcp
                                                                    WHERE  fcp.application_id = 602
                                                                    AND    fcp.concurrent_program_name = 'XLAONDEUPG')
  AND    fcr.phase_code = 'R';

  -- For Multiple Programs Running Raise Error.
  IF (l_program_running > 1) THEN
    RAISE mutliple_prgms_running;
  END IF;
  */
  -- Check the status of the previous run
  BEGIN
    SELECT status_code
    INTO   l_prev_run_status
    FROM   xla_upgrade_requests
    WHERE  application_id = p_application_id
           AND program_code = 'ONDEMAND UPGRADE';
  EXCEPTION
    WHEN no_data_found THEN
      l_prev_run_status := C_INITIAL_STATUS;
  END;

  IF (l_prev_run_status NOT IN ( C_INITIAL_STATUS ,C_SUCCESS_STATUS ,C_ERROR_STATUS)) THEN
    IF (l_prev_run_status = C_PROGRESS_STATUS ) THEN
      fnd_file.Put_line(fnd_file.LOG,'Previous Run for Upgrade for Application : '
                                     ||l_application_name
                                     ||' is in PENDING STATUS.'
                                     ||'Marking it as ERROR and Proceeding ');

      l_prev_run_status := C_ERROR_STATUS;
    ELSE
      RAISE incorrect_prior_run_status;
    END IF;
  END IF;

  -- Extra Validation in place to not to allow any two concurrent program's
  -- to run simultaneously
  EXECUTE IMMEDIATE 'LOCK TABLE XLA_UPGRADE_DATES IN EXCLUSIVE MODE NOWAIT ';
  EXECUTE IMMEDIATE 'LOCK TABLE XLA_UPGRADE_REQUESTS IN EXCLUSIVE MODE NOWAIT ';

  SELECT Count(1)
  INTO  l_hotpatch_running
  FROM xla_upgrade_requests
  WHERE application_id = 602
  AND   status_code IN (C_INITIAL_STATUS , C_PROGRESS_STATUS) ;

  IF( l_hotpatch_running > 0 ) THEN
	RAISE upgrade_by_patch_running ;
  END IF;

  -- Retreive the List of Primary and ALC Ledgers for Upgrade
  SELECT target_ledger_id
  BULK COLLECT INTO g_array_ledger_id
  FROM   gl_ledger_relationships glr
  WHERE  glr.application_id = 101
         AND glr.primary_ledger_id = p_ledger_id
         AND ((glr.target_ledger_category_code IN ('SECONDARY','ALC')
               AND glr.relationship_type_code = 'SUBLEDGER')
               OR (glr.target_ledger_category_code IN ('PRIMARY')
                   AND glr.relationship_type_code = 'NONE'));

  IF l_application_id = 275 THEN
    -- As Projects are not participating in this Upgrade, commenting the code for time being
    NULL;
  /*
-- Since Application ID 275(Projects) might have periods either iby 275
-- or 8721 , so query both the application_ids'
       SELECT gps.start_date
        INTO l_start_date
        FROM gl_period_statuses gps
       WHERE gps.application_id IN (275, 8721)
         AND gps.ledger_id      = p_ledger_id
         AND gps.period_name    = p_period_name;

     fnd_file.put_line(fnd_file.log, '*Start date     : '|| to_char(l_start_date));

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace('Start date of upgrade '|| l_start_date,
                C_LEVEL_STATEMENT, l_Log_module);
      END IF;

       SELECT min(gps.start_date)
        INTO l_end_date
        FROM gl_period_statuses gps
       WHERE gps.migration_status_code = 'U'
         AND gps.ledger_id       = p_ledger_id
         AND gps.application_id  IN (275, 8721) ;

    fnd_file.put_line(fnd_file.log, '*End date       : '|| to_char(l_end_date));

    IF l_end_date IS NOT NULL THEN

             select distinct gps.period_name
             into l_upgraded_period_name
             from gl_period_statuses gps
             WHERE gps.migration_status_code = 'U'
             AND gps.ledger_id  = p_ledger_id
             AND gps.start_date = l_end_date
             AND gps.application_id IN (275, 8721) ;

    END IF;

    SELECT  count(*)
    INTO  l_pending_periods
    FROM  gl_period_statuses gps
    WHERE  gps.migration_status_code = 'P'
    AND    gps.application_id IN (275, 8721)
    AND    gps.ledger_id IN ( SELECT l.ledger_id
                              FROM gl_ledgers l
                              WHERE l.ledger_id IN (SELECT DISTINCT glr.target_ledger_id
                                                         FROM gl_ledger_relationships glr
                                                         WHERE glr.primary_ledger_id = p_ledger_id
                                                         AND glr.application_id = 101
                                                         AND (( glr.target_ledger_category_code IN ('SECONDARY' , 'ALC')
                                                                AND glr.relationship_type_code = 'SUBLEDGER' )
                                                              OR
                                                              ( glr.target_ledger_category_code IN ('PRIMARY')
                                                                AND glr.relationship_type_code = 'NONE'  )
                                                             )
                                                         )
                              AND nvl(l.complete_flag,'Y') = 'Y' ) ;
*/
  ELSE
    -- Choosing the start date of the first period that has to be migrated.
    SELECT gps.start_date
    INTO   l_start_date
    FROM   gl_period_statuses gps
    WHERE  gps.application_id = l_application_id
           AND gps.ledger_id = p_ledger_id
           AND gps.period_name = p_period_name;

    fnd_file.Put_line(fnd_file.LOG,'*Start date     : '||To_char(l_start_date));

    IF (c_level_statement >= g_log_level) THEN
      Trace('Start date of upgrade '||l_start_date,c_level_statement,l_log_module);
    END IF;

    -- Choosing the start date of the last period that was migrated.
    SELECT Min(gps.start_date)
    INTO   l_end_date
    FROM   gl_period_statuses gps
    WHERE  gps.migration_status_code = 'U'
           AND gps.ledger_id = p_ledger_id
           AND gps.application_id = l_application_id;

    fnd_file.Put_line(fnd_file.LOG,'*End date       : '||To_char(l_end_date));

    IF l_end_date IS NOT NULL THEN

             select gps.period_name
             into l_upgraded_period_name
             from gl_period_statuses gps
             WHERE gps.migration_status_code = 'U'
             AND gps.ledger_id  = p_ledger_id
             AND gps.start_date = l_end_date
             AND gps.application_id = l_application_id ;

	     IF (c_level_statement >= g_log_level) THEN
      		Trace('Last Successfully Upgraded Period '||l_upgraded_period_name,c_level_statement,l_log_module);
    	     END IF;

    END IF;

    SELECT Count(*)
    INTO   l_pending_periods
    FROM   gl_period_statuses gps
    WHERE  gps.migration_status_code = 'P'
           AND gps.application_id = l_application_id
           AND gps.ledger_id IN (SELECT l.ledger_id
                                 FROM   gl_ledgers l
                                 WHERE  l.ledger_id IN (SELECT DISTINCT glr.target_ledger_id
                                                        FROM   gl_ledger_relationships glr
                                                        WHERE  glr.primary_ledger_id = p_ledger_id
                                                               AND glr.application_id = 101
                                                               AND ((glr.target_ledger_category_code IN ('SECONDARY','ALC')
                                                                     AND glr.relationship_type_code = 'SUBLEDGER')
                                                                     OR (glr.target_ledger_category_code IN ('PRIMARY')
                                                                         AND glr.relationship_type_code = 'NONE')))
                                        AND Nvl(l.complete_flag,'Y') = 'Y');
  END IF;

  /************ ALL VALIDATIONS BEFORE UPGRADE KICKS OFF **************************/
  IF l_end_date IS NULL THEN
    RAISE no_upgrade;
  END IF;

  -- Check for Correct Dates being passed.
  IF l_start_date >= l_end_date THEN
    RAISE incorrect_upg_date;
  END IF;

  -- Check for any pending Upgrade Periods.
  IF l_pending_periods <> 0 THEN
    RAISE pending_periods;
  END IF;

  -- Check if its a RE-RUN or a FRESH Run
  --  If ReRun then DATES in XLA_UPGRADES should be same as L_START_DATE AND L_END_DATE
  IF l_prev_run_status = C_ERROR_STATUS THEN
    -- Need to Check if the ledger is same or not ???
    BEGIN
      SELECT xur.ledger_id,
             xur.start_date,
             xur.end_date,
	     xur.workers_num,
	     xur.batch_size,
             xur.period_name
      INTO   l_upg_ledger_id,
      	     l_upg_start_date,
	     l_upg_end_date,
             l_upg_number_of_workers,
             l_upg_batch_size,
	     l_upg_period_name
      FROM   xla_upgrade_requests xur
      WHERE  xur.application_id = p_application_id
             AND xur.program_code = 'ONDEMAND UPGRADE';

	IF (c_level_statement >= g_log_level) THEN
            Trace('Last Run Upgrade Details '||
	          'upg_ledger_id: '||l_upg_ledger_id ||
		  ' upg_start_date: '||l_upg_start_date ||
		  ' upg_end_date: '||l_upg_end_date ||
		  ' upg_number_of_workers: '||l_upg_number_of_workers ||
		  ' upg_batch_size: '|| l_upg_batch_size ||
		  ' l_upg_period_name: '|| l_upg_period_name ,c_level_statement,l_log_module);
        END IF;

        SELECT l.name
        INTO   l_upg_ledger_name
        FROM   gl_ledgers l
        WHERE  l.ledger_id = l_upg_ledger_id  ;



    EXCEPTION
      WHEN no_data_found THEN
        IF (c_level_statement >= g_log_level) THEN
      		Trace('No Concurrent Program Upgrade is run for application: '||p_application_id,c_level_statement,l_log_module);
    	END IF;
        l_upg_ledger_id := 0;
	l_upg_ledger_name := '-1' ;
    END;

    IF ((l_upg_ledger_id <> l_ledger_id)
         OR (l_upg_start_date <> l_start_date)
         OR ((l_upg_end_date + 1) <> l_end_date)
         OR (l_upg_period_name <> l_period_name)
	 OR (NVL(l_upg_number_of_workers,C_DEFAULT_NUM_OF_WORKERS ) <> l_number_of_workers)
	 OR (NVL(l_upg_batch_size,C_DEFAULT_BATCH_SIZE ) <> l_batch_size )) THEN
      RAISE recovery_run_incorrect;
    END IF;

  ELSIF l_prev_run_status = C_INITIAL_STATUS THEN
      INSERT INTO xla_upgrade_requests
                 (application_id,
                  request_control_id,
                  status_code,
                  phase_num,
                  ledger_id,
                  order_num,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  program_code)
      VALUES     (p_application_id,
                  0,
                  C_INITIAL_STATUS ,
                  p_application_id,
                  p_ledger_id,
                  p_application_id,
                  SYSDATE,
                  -169,
                  SYSDATE,
                  -169,
                  'ONDEMAND UPGRADE');
     IF (c_level_statement >= g_log_level) THEN
      	Trace('Inserted a row into XLA_UPGRADE_REQUESTS for application: '||p_application_id,c_level_statement,l_log_module);
     END IF;
  END IF;

  -- This has been achieved by CP Incompatibility, by making upgrade CP incompatible with itself.
  /*
  -- Check that no TWO Upgrade Program's Run at the SAME TIME
  SELECT Count(1)
  INTO   l_program_running
  FROM   fnd_concurrent_requests fcr
  WHERE  (fcr.program_application_id,fcr.concurrent_program_id) IN (SELECT fcp.application_id,
                                                                           fcp.concurrent_program_id
                                                                    FROM   fnd_concurrent_programs fcp
                                                                    WHERE  fcp.application_id = 602
                                                                           AND fcp.concurrent_program_name = 'XLAONDEUPG')
  AND fcr.phase_code = 'R';

  -- For Multiple Programs Running Raise Error.
  IF (l_program_running > 1) THEN
    RAISE mutliple_prgms_running;
  END IF;
  */

  IF l_start_date <> l_end_date THEN

    /* Update the data for the current run */
  	UPDATE xla_upgrade_requests
  	SET     status_code = C_PROGRESS_STATUS,
       	        request_control_id = xla_upgrade_requests_s.nextval,
         	batch_size = p_batch_size,
		workers_num = p_number_of_workers,
         	period_name = p_period_name,
         	start_date = l_start_date,
         	end_date = l_end_date - 1,
         	ledger_id = p_ledger_id,
         	last_update_date = SYSDATE ,
		last_updated_by = -169
  	WHERE  application_id = p_application_id
  	AND program_code = 'ONDEMAND UPGRADE';

  	COMMIT;

  	l_step_value := 'PERIOD_PENDING_UPGRADE';

  	IF p_application_id = 275 THEN
    		NULL;
  		-- Projects are not participating in this upgrade, so for time being commented
  	/*
    		FOR i_ledger_periods IN c_pa_last_date( p_ledger_id )
     		LOOP
  		UPDATE gl_period_statuses
         	SET migration_status_code = 'P'
		    ,last_update_date = SYSDATE
                    ,last_updated_by = -169
                    ,last_update_login = -169
          	WHERE ledger_id = i_ledger_periods.ledger_id
         	AND (	end_date >= l_start_date
              	and end_date < i_ledger_periods.last_date)
         	AND application_id IN (275, 8721)
   		AND adjustment_period_flag = 'N'
		AND closing_status in ('F', 'O', 'C', 'N')
   		AND migration_status_code IS NULL;

   		fnd_file.put_line(fnd_file.log, '*Periods updated to P for ledger_id: '
							|| i_ledger_periods.ledger_id || ' are : '|| to_char(SQL%ROWCOUNT));

     		END LOOP ;
  	*/
  	ELSE
    		FOR i_ledger_periods IN c_last_date(l_application_id,p_ledger_id) LOOP
      		UPDATE gl_period_statuses
      		SET    migration_status_code = 'P'
		       ,last_update_date = SYSDATE
                       ,last_updated_by = -169
                       ,last_update_login = -169
      		WHERE  application_id = l_application_id
             	AND ledger_id = i_ledger_periods.ledger_id
             	AND (end_date >= l_start_date
                  	AND end_date < i_ledger_periods.last_date)
             	AND adjustment_period_flag = 'N'
		AND closing_status in ('F', 'O', 'C', 'N')
             	AND migration_status_code IS NULL;

      	        fnd_file.Put_line(fnd_file.LOG,'*Periods updated to P for ledger_id: ' ||i_ledger_periods.ledger_id
                                             ||' are : ' ||To_char(SQL%ROWCOUNT));
    		END LOOP;
  	END IF;

    DELETE FROM xla_upgrade_dates;

    -- Inserting details of ledgers , start date and end date for use by product teams
    IF p_application_id = 275 THEN
      NULL;
    -- Projects is not participating in this upgrade. So for time being upgraded the code.
    /*
        FORALL i IN 1..v_array_ledger_id.COUNT
  	  INSERT INTO xla_upgrade_dates
          (ledger_id
          ,start_date
          ,end_date)
         SELECT   gps.ledger_id
                  ,min(start_date)
                  ,max(end_date)
         FROM    gl_period_statuses gps
         WHERE   gps.migration_status_code = 'P'
         AND     gps.application_id IN (275, 8721)
         AND     gps.ledger_id = v_array_ledger_id(i)
         GROUP BY gps.ledger_id ;
	*/
    ELSE
      FORALL i IN 1..g_array_ledger_id.COUNT
        INSERT INTO xla_upgrade_dates
                   (ledger_id,
                    start_date,
                    end_date)
        SELECT   gps.ledger_id,
                 Min(start_date),
                 Max(end_date)
        FROM     gl_period_statuses gps
        WHERE    gps.migration_status_code = 'P'
        AND gps.application_id = l_application_id
        AND gps.ledger_id = G_array_ledger_id(i)
        GROUP BY gps.ledger_id;
    END IF;

    COMMIT;

    IF (c_level_statement >= g_log_level) THEN
      	Trace('Gather Statistics on XLA_UPGRADE_DATES',c_level_statement,l_log_module);
    END IF;
    fnd_stats.gather_table_stats('XLA', 'XLA_UPGRADE_DATES');

    --  Call Product Team Upgrade Manager API's for Upgrade
    IF (c_level_statement >= g_log_level) THEN
      	Trace('Calling Product APIs for actual upgrade.',c_level_statement,l_log_module);
    END IF;

    BEGIN
    	IF l_application_id = 101 THEN
		l_step_value := 'Upgrade for Assets via FA Master API' ;
      		fa_upgharness_pkg.Fa_master_upg(l_error_buf,l_retcode,l_number_of_workers,
                	                      l_batch_size);

      		fnd_file.Put_line(fnd_file.LOG,'*Return code from FA: '||To_char(l_retcode));

    	ELSIF l_application_id = 200 THEN
      		l_step_value := 'E-Tax Upgrade for Payables via E-Tax Master API' ;
		zx_on_demand_trx_upgrade_pkg.Zx_trx_update_mgr(
						x_errbuf => l_error_buf,
						x_retcode => l_retcode,
						x_batch_size => l_batch_size,
						x_num_workers => l_number_of_workers,
                       	 	        	p_application_id => l_application_id,
						p_ledger_id => l_ledger_id ,
						p_period_name => l_period_name);

      		fnd_file.Put_line(fnd_file.LOG,'*Return code from ZX: '||To_char(l_retcode));

      		IF l_retcode = 0 THEN
       		      -- resetting the return code to NON-ZERO so that the success of ZX is not propagated to Products run.
       		      -- Also, if Product API's donot initiliaze the recode correctly,then ZX retcode is treated as Products Retcode.
        		l_retcode := -1 ;
			l_step_value := 'Upgrade for Payables via Payables Master API' ;
       			 ap_xla_upgrade_pkg.Ap_xla_upgrade_ondemand(
						errbuf => l_error_buf,
						retcode => l_retcode,
                                   		p_batch_size => l_batch_size,
						p_num_workers => l_number_of_workers);

        		fnd_file.Put_line(fnd_file.LOG,'*Return code from AP: '||To_char(l_retcode));
      		END IF;
    	ELSIF l_application_id = 222 THEN
      		l_step_value := 'E-Tax Upgrade for Receivables via E-Tax Master API' ;
		zx_on_demand_trx_upgrade_pkg.Zx_trx_update_mgr(
						x_errbuf => l_error_buf,
						x_retcode => l_retcode,
                                   	        x_batch_size => l_batch_size,
						x_num_workers => l_number_of_workers,
                                   	        p_application_id => l_application_id,
						p_ledger_id => l_ledger_id ,
						p_period_name => l_period_name );

      		fnd_file.Put_line(fnd_file.LOG,'*Return code from ZX: '||To_char(l_retcode));

      		IF l_retcode = 0 THEN
       		  -- resetting the return code to NON-ZERO so that the success of ZX is not propagated to Products run.
      		  -- Also, if Product API's donot initiliaze the recode correctly,then ZX retcode is treated as Products Retcode.
        		l_retcode := -1 ;
        		l_step_value := 'Upgrade for Receivables via Receivables Master API' ;
			ar_upgharness_pkg.Ar_master_upg(l_error_buf,
						l_retcode,
						l_ledger_id,
						l_period_name,
                                        	l_number_of_workers,
						l_batch_size);

        		fnd_file.Put_line(fnd_file.LOG,'*Return code from AR: ' ||To_char(l_retcode));
     		END IF;
   	ELSIF l_application_id = 275 THEN
      		NULL;
   		 -- Proect's is not participating in this upgrade. So, commented call for time being.
    		/*
		 l_step_value := 'Upgrade for Projects via Projects Master API' ;
		 PA_UPGHARNESS_PKG.pa_master_upg
       			(l_error_buf
        		,l_retcode
        		,l_number_of_workers
        		,l_batch_size);

   	   	fnd_file.put_line(fnd_file.log, '*Return code from PA: '|| to_char(l_retcode));
		*/
   	ELSIF l_application_id IN (401) THEN
      		l_retcode := -1 ;
      		l_step_value := 'Upgrade for Inventory/WIP via Costing Master API' ;
               CST_SLA_UPDATE_PKG.CST_Upgrade_Wrapper (
               X_errbuf         => l_error_buf ,
               X_retcode        => l_retcode_char ,
               X_batch_size     => l_batch_size ,
               X_Num_Workers    => l_number_of_workers ,
               X_ledger_id      => p_ledger_id ,
               X_application_id => l_application_id ) ;

		fnd_file.Put_line(fnd_file.LOG,'*Return code from CST :' ||l_retcode_char ||' '||l_error_buf);

      		IF l_retcode_char = 'S' THEN
        		l_retcode := 0;
     		END IF;

    	ELSIF l_application_id = 201 THEN
      		l_step_value := 'E-Tax Upgrade for Receiving via E-Tax Master API' ;
		zx_on_demand_trx_upgrade_pkg.Zx_trx_update_mgr(	x_errbuf => l_error_buf,
 						     	x_retcode => l_retcode,
					            	x_batch_size => l_batch_size,
							x_num_workers => l_number_of_workers,
            						p_application_id => l_application_id,
							p_ledger_id => l_ledger_id ,
							p_period_name => l_period_name);

      		fnd_file.Put_line(fnd_file.LOG,'*Return code from ZX: '||To_char(l_retcode));

      		IF l_retcode = 0 THEN
       		-- resetting the return code to NON-ZERO so that the success of ZX is not propagated to Products run.
      		-- Also, if Product API's donot initiliaze the recode correctly,then ZX retcode is treated as Products Retcode.
        		l_retcode := -1 ;

			l_step_value := 'Upgrade for Receiving via Costing Master API' ;
			CST_SLA_UPDATE_PKG.CST_Upgrade_Wrapper (
 				X_errbuf         => l_error_buf ,
                		X_retcode        => l_retcode_char ,
      				X_batch_size     => l_batch_size ,
      				X_Num_Workers    => l_number_of_workers ,
      				X_ledger_id      => p_ledger_id ,
      				X_application_id => l_application_id ) ;

       			fnd_file.Put_line(fnd_file.LOG,'*Return code from Receiving(PO): ' ||l_retcode_char);

        		IF l_retcode_char = 'S' THEN
          			l_retcode := 0;
        		END IF;
     		END IF;
    	END IF;
    EXCEPTION
    	WHEN OTHERS THEN
      	     IF (c_level_statement >= g_log_level) THEN
      		Trace('Upgrade failed at: '||l_step_value ,c_level_statement,l_log_module);
    	     END IF;

	     fnd_file.Put_line(fnd_file.LOG,'Upgrade failed at: '||l_step_value );
	     fnd_file.Put_line(fnd_file.LOG,'Updating the Return Code as 2(ERROR)');
	  -- Set the Retcode as 2, so that it marks the product upgrade as ERROR
	     l_retcode := 2 ; -- changes for 8834301
    END;

    IF l_retcode = 0 THEN      /* means no error in the upgrade */
      -- Upgrade The Request Status as SUCCESS
      Update_upg_request_status(p_application_id,C_SUCCESS_STATUS );

      --  Upgdate the GL Journal's JE_FROM_SLA_FLAG as Upgraded.
      IF p_application_id NOT IN (200,275) THEN
        SELECT je_source_name
        INTO   l_source_name
        FROM   xla_subledgers
        WHERE  application_id = p_application_id;

        fnd_file.Put_line(fnd_file.LOG,'*Source name : '|| l_source_name);

        FORALL i IN 1..g_array_ledger_id.COUNT
          UPDATE gl_je_headers a
          SET    a.je_from_sla_flag = decode(a.reversed_je_header_id,null,'U','N') ,
                 a.je_source = Decode(a.je_source,'Inventory','Cost Management',
                                                  'Purchasing','Cost Management',
                                                  je_source),
                 a.last_update_date = SYSDATE,
                 a.last_updated_by = -169,
                 a.last_update_login = -169
          WHERE  (Decode(a.je_source,'Receivables',222,
                                     'Assets',101,
                                     'Inventory',401,
                                     'Purchasing',201,
                                     -101),ledger_id,period_name) IN (SELECT gps.application_id,
                                                                             gps.ledger_id,
                                                                             gps.period_name
                                                                      FROM   gl_period_statuses gps
                                                                      WHERE  gps.end_date >= l_start_date
                                                                             AND gps.end_date < l_end_date
                                                                             AND gps.ledger_id = G_array_ledger_id(i)
                                                                             AND gps.application_id = l_application_id
									     AND gps.migration_status_code = 'U')
                 AND a.je_from_sla_flag IS NULL
                 AND a.je_source <> 'Project Accounting'
		 AND a.actual_flag = 'A'
                 AND EXISTS (SELECT 1
                             FROM   xla_subledgers xsu
                             WHERE  xsu.je_source_name = a.je_source);

        fnd_file.Put_line(fnd_file.LOG,'*Flags updated to U : '||To_char(SQL%ROWCOUNT));

        IF (c_level_statement >= g_log_level) THEN
          Trace('Updated gl_je_headers',c_level_statement,l_log_module);
        END IF;
      END IF;
    ELSE
      -- Upgrade The Request Status as ERROR
      Update_upg_request_status(p_application_id,C_ERROR_STATUS);

      -- Reset the periods to NULL
      Reset_period_statuses(l_application_id);

      -- Raise Error
      RAISE upgrade_error;
    END IF;
  END IF;

  COMMIT;


EXCEPTION
  WHEN no_upgrade THEN
   ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('This is either a fresh R12 installation or upgrade from an existing 11i instance has not taken place.',
            c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_OD_UPG_NOT_ELIGIBLE'
             );
    p_retcode := 2 ;
    p_errbuf  := xla_messages_pkg.get_message ;

  WHEN upgrade_error THEN
    ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('There has been an error in the Product Upgrade',c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_OD_PROD_API_ERROR'
             ,p_token_1        => 'P_APPLICATION_NAME'
             ,p_value_1        =>  l_application_name
         );
    fnd_file.Put_line(fnd_file.LOG, l_error_buf) ;
    p_retcode := 2 ;
    p_errbuf  := xla_messages_pkg.get_message ;

  WHEN incorrect_upg_date THEN
    ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('The provided start date for upgrade is incorrect. Please provide a valid start period for upgrade',
            c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_OD_INCORRECT_PERIOD'
             ,p_token_1        => 'P_PERIOD_NAME'
             ,p_value_1        =>  l_upgraded_period_name
         );
    p_retcode := 2 ;
    p_errbuf := xla_messages_pkg.get_message ;

  WHEN pending_periods THEN
    ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('There are periods pending in upgrade, upgrade cannot be run.',
            c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_OD_PENDING_PERIODS'
             );
    p_retcode := 2 ;
    p_errbuf := xla_messages_pkg.get_message ;

  WHEN recovery_run_incorrect THEN
    ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('Paremeters between Failed Request and present request are incorrect',
            c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_OD_INCORRECT_RERUN'
             ,p_token_1        => 'P_LED'
             ,p_value_1        =>  l_upg_ledger_name
             ,p_token_2        => 'P_PRD'
             ,p_value_2        =>  l_upg_period_name
             ,p_token_3        => 'P_BTCH'
             ,p_value_3        =>  l_upg_batch_size
             ,p_token_4        => 'P_NUM_WRK'
             ,p_value_4        =>  l_upg_number_of_workers
             ) ;
    p_retcode := 2 ;
    p_errbuf := xla_messages_pkg.get_message ;

  WHEN un_registered_application THEN
    ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('SLA UPGRADE is not enabled for this Application',c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       =>'XLA_OD_UNREG_APPLICATION'
             ,p_token_1        => 'P_APPLICATION_NAME'
             ,p_value_1        =>  l_application_name
             );
    p_retcode := 2 ;
    p_errbuf := xla_messages_pkg.get_message ;

  /*
  WHEN mutliple_prgms_running THEN
    ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('Multiple upgrade by concurrent programs cannot be run.', c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_OD_MULTI_PRGM_RUNNING'
             );
    p_retcode := 2 ;
    p_errbuf := xla_messages_pkg.get_message ;
    */

  WHEN incorrect_prior_run_status THEN
    ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('Incorrect status for Prior Upgrade Run.', c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_OD_INCORRECT_STATUS'
             );
    p_retcode := 2 ;
    p_errbuf := xla_messages_pkg.get_message ;

  WHEN upgrade_by_patch_running THEN
    ROLLBACK ;
    IF (c_level_statement >= g_log_level) THEN
      Trace('On Demand Upgrade by Patch is running, upgrade by concurrent program cannot be run.', c_level_error,l_log_module);
    END IF;
    xla_messages_pkg.build_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_OD_HOTPATCH_RUNNING'
             );
    p_retcode := 2 ;
    p_errbuf := xla_messages_pkg.get_message ;

  WHEN xla_exceptions_pkg.application_exception THEN
    -- Upgrade The Request Status as ERROR
    Update_upg_request_status(p_application_id,C_ERROR_STATUS);

    -- Reset the periods to NULL
    Reset_period_statuses(l_application_id);
    p_errbuf   := xla_messages_pkg.get_message || l_error_buf;
    p_retcode  := 2;

  WHEN OTHERS THEN
    -- Upgrade The Request Status as ERROR
    Update_upg_request_status(p_application_id,C_ERROR_STATUS);

    -- Reset the periods to NULL
    Reset_period_statuses(l_application_id);
    p_retcode  := 2;
    p_errbuf   := sqlerrm ;

END set_status_code;


--PROCEDURE set_status_code
--(p_error_buf             OUT NOCOPY VARCHAR2,
-- p_retcode               OUT NOCOPY NUMBER,
-- p_application_id        IN NUMBER,
-- p_ledger_id             IN NUMBER,
-- p_period_name           IN VARCHAR2,
-- p_number_of_workers     IN NUMBER,
-- p_batch_size            IN NUMBER) IS

--l_application_id         NUMBER;
--l_source_name		 XLA_SUBLEDGERS.JE_SOURCE_NAME%TYPE;
--l_application_name       FND_APPLICATION_VL.APPLICATION_NAME%TYPE;
--l_ledger_id              NUMBER;
--l_period_name            VARCHAR2(15) ;
--l_batch_size             NUMBER;
--l_number_of_workers      NUMBER;
--l_error_buf              VARCHAR2(1000);
--l_retcode                NUMBER;
--l_processed              VARCHAR2(1) := ' ';
--l_start_date             date;
--l_end_date               date;
--l_log_module             VARCHAR2(240);
--NO_UPGRADE               EXCEPTION;
--UPGRADE_ERROR            EXCEPTION;
--l_temp                   BOOLEAN;
--l_retcode_char		 VARCHAR2(10);

--BEGIN

--   IF g_log_enabled THEN
--      l_log_module := C_DEFAULT_MODULE||'.set_status_code';
--   END IF;

--   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--      trace('set_status_code.Begin',C_LEVEL_STATEMENT,l_log_module);
--   END IF;

--   IF p_batch_size IS NOT NULL THEN
--      l_batch_size         := p_batch_size;
--   ELSE
--      l_batch_size         := 10000;
--   END IF;

--   IF p_number_of_workers IS NOT NULL THEN
--      l_number_of_workers  := p_number_of_workers;
--   ELSE
--      l_number_of_workers  := 1;
--   END IF;

--   l_application_id        := p_application_id;
--   l_period_name           := p_period_name;
--   l_ledger_id             := p_ledger_id;

--   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--       trace('l_application_id '||l_application_id,
--             C_LEVEL_STATEMENT, l_Log_module);
--   END IF;

--   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--       trace('l_ledger_id '||l_ledger_id,
--             C_LEVEL_STATEMENT, l_Log_module);
--   END IF;

--   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--       trace('l_period_name '||l_period_name,
--             C_LEVEL_STATEMENT, l_Log_module);
--   END IF;

--   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--       trace('l_number_of_workers '||l_number_of_workers,
--             C_LEVEL_STATEMENT, l_Log_module);
--   END IF;

--   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--       trace('l_batch_size '||l_batch_size,
--             C_LEVEL_STATEMENT, l_Log_module);
--   END IF;

--   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--       trace('Processing periods...',
--             C_LEVEL_STATEMENT, l_Log_module);
--   END IF;

   /* FA uses GL's period */

--   IF p_application_id = 140 then
--      l_application_id :=101;
--   END IF;

   -- Check with application id 707 is done separately, since there will be
   -- no rows in GL_PERIOD_STATUSES corresponding to Application ID 707.
   -- Associated Applications are 201 (PO) and 401 (INV).

--   IF p_application_id = 707 then

   -- Since Application ID 707 will have no rows in GL_PERIOD_STATUSES
   -- we are getting the minimum of start date for one of the two
   -- applications which are associated with Costing (707)

--      SELECT start_date
--        INTO l_start_date
--        FROM gl_period_statuses
--       WHERE application_id = 401
--         AND ledger_id      = p_ledger_id
--         AND period_name    = p_period_name;

--fnd_file.put_line(fnd_file.log, '*Start date     : '|| to_char(l_start_date));

--      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--          trace('Start date of upgrade '|| l_start_date,
--                C_LEVEL_STATEMENT, l_Log_module);
--      END IF;

--      SELECT min(start_date)
--        INTO l_end_date
--        FROM gl_period_statuses
--       WHERE migration_status_code = 'U'
--         AND ledger_id       = p_ledger_id
--         AND application_id  = 401;

--fnd_file.put_line(fnd_file.log, '*End date       : '|| to_char(l_end_date));

--      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--          trace('End date of upgrade '|| l_end_date,
--                C_LEVEL_STATEMENT, l_Log_module);
--      END IF;

      -- if l_end_date is NULL it means that the database that the On Demand
      -- Program is being run on is a fresh installation or Upgrade has
      -- never been performed on this instance. Hence, warning will be raised.

--      IF l_end_date is NULL THEN
--         RAISE NO_UPGRADE;
--      END IF;

      -- Updation of GL Period Statuses.

--      UPDATE gl_period_statuses
--         SET migration_status_code = 'P'
--       WHERE ledger_id = l_ledger_id
--         AND (start_date >= l_start_date
--              and end_date < l_end_date)
--         AND application_id in (201,401)
--	 AND adjustment_period_flag = 'N'
--	 AND migration_status_code IS NULL;

--fnd_file.put_line(fnd_file.log, '*Periods updated to P : '|| to_char(SQL%ROWCOUNT));

--      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--          trace('Updated gl_period_statuses. '
--	        , C_LEVEL_STATEMENT, l_Log_module);
--      END IF;

--   ELSE /*End for 707 Case and begin for all other applications*/

      -- Choosing the start date of the first period that
      -- has to be migrated.

--      SELECT start_date
--        INTO l_start_date
--        FROM gl_period_statuses
--       WHERE application_id = l_application_id
--         AND ledger_id      = p_ledger_id
--         AND period_name    = p_period_name;

--fnd_file.put_line(fnd_file.log, '*Start date     : '|| to_char(l_start_date));

--      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--          trace('Start date of upgrade '|| l_start_date,
--                C_LEVEL_STATEMENT, l_Log_module);
--      END IF;

      -- Choosing the start date of the last period that
      -- was migrated.

--      SELECT min(start_date)
--        INTO l_end_date
--        FROM gl_period_statuses
--       WHERE migration_status_code = 'U'
--         AND ledger_id       = p_ledger_id
--         AND application_id  = l_application_id;

--fnd_file.put_line(fnd_file.log, '*End date       : '|| to_char(l_end_date));

--      IF l_end_date is NULL THEN
--         RAISE NO_UPGRADE;
--      END IF;

--      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--          trace('Ending date of upgrade '|| l_end_date,
--                C_LEVEL_STATEMENT, l_Log_module);
--      END IF;

--      UPDATE gl_period_statuses
--         SET migration_status_code = 'P'
--       WHERE application_id = l_application_id
--         AND ledger_id      = l_ledger_id
--         AND (start_date   >= l_start_date
--  	      AND end_date  < l_end_date)
--  	 AND adjustment_period_flag = 'N'
--	 AND migration_status_code IS NULL;

--fnd_file.put_line(fnd_file.log, '*Periods updated to P : '|| to_char(SQL%ROWCOUNT));

--      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--          trace('Updated gl_period_statuses',
--                C_LEVEL_STATEMENT, l_Log_module);
--      END IF;

--   END IF;

--   IF l_start_date <> l_end_date THEN

--      DELETE FROM xla_upgrade_dates;

      -- Inserting details of ledgers , start date and end date
      -- for use by product teams
--      INSERT INTO xla_upgrade_dates
--          (ledger_id
--          ,start_date
--          ,end_date)
--      VALUES (l_ledger_id
--          ,l_start_date
--	  ,l_end_date-1);

      /* Call Product Team hooks for Accounting Upgrade */

--      IF l_application_id = 101 THEN

--         FA_UPGHARNESS_PKG.fa_master_upg(
--                   l_error_buf,
--                   l_retcode,
--                   l_number_of_workers,
--                   l_batch_size);

--fnd_file.put_line(fnd_file.log, '*Return code from FA: '|| to_char(l_retcode));

--      ELSIF l_application_id = 200 then

--         AP_XLA_UPGRADE_PKG.AP_XLA_Upgrade_OnDemand(
--                Errbuf        => l_error_buf,
--                Retcode       => l_retcode,
--                P_Batch_Size  => l_batch_size,
--                P_Num_Workers => l_number_of_workers);

--fnd_file.put_line(fnd_file.log, '*Return code from AP: '|| to_char(l_retcode));

--         IF l_retcode = 0 THEN
--	  ZX_ON_DEMAND_TRX_UPGRADE_PKG.zx_trx_update_mgr(
--                        X_errbuf         => l_error_buf,
--                        X_retcode        => l_retcode,
--                        X_batch_size     =>l_batch_size,
--                        X_Num_Workers    =>l_number_of_workers,
--                        p_application_id => l_application_id);

--          fnd_file.put_line(fnd_file.log, '*Return code from ZX: '|| to_char(l_retcode));
--	 END IF;

--      ELSIF l_application_id = 222 then
--          AR_UPGHARNESS_PKG.ar_master_upg(
--                        l_error_buf,
--                        l_retcode,
--                        l_ledger_id,
--                        l_period_name,
--                        l_number_of_workers,
--                        l_batch_size);

--fnd_file.put_line(fnd_file.log, '*Return code from AR: '|| to_char(l_retcode));

--       IF l_retcode = 0 THEN
-- 	ZX_ON_DEMAND_TRX_UPGRADE_PKG.zx_trx_update_mgr(
--                        X_errbuf         => l_error_buf,
--                        X_retcode        => l_retcode,
--                        X_batch_size     =>l_batch_size,
--                        X_Num_Workers    =>l_number_of_workers,
--                        p_application_id => l_application_id);

--  	fnd_file.put_line(fnd_file.log, '*Return code from ZX: '|| to_char(l_retcode));
--       END IF;
--      ELSIF l_application_id = 275 THEN

--            PA_UPGHARNESS_PKG.pa_master_upg
--   	              (l_error_buf
--      		       ,l_retcode
--                       ,l_number_of_workers
--   		       ,l_batch_size);

--fnd_file.put_line(fnd_file.log, '*Return code from PA: '|| to_char(l_retcode));

--      ELSIF l_application_id = 707 THEN

--	CST_SLA_UPDATE_PKG.Update_Proc_MGR (
--              X_errbuf         => l_error_buf,
--              X_retcode        => l_retcode_char,
--              X_api_version    => 1.0,
--              X_init_msg_list  => FND_API.G_FALSE,
--              X_batch_size     => l_batch_size,
--              X_Num_Workers    => l_number_of_workers,
--              X_Argument4      => 'NULL',
--              X_Argument5      => 'NULL',
--              X_Argument6      => 'NULL',
--              X_Argument7      => 'NULL',
--              X_Argument8      => 'NULL',
--              X_Argument9      => 'NULL',
--              X_Argument10     => 'NULL');

--fnd_file.put_line(fnd_file.log, '*Return code from COST: '|| l_retcode_char);
--	IF l_retcode_char = 'S' THEN
--	   l_retcode := 0;
--	END IF;

--      END IF;

     -- Updating gl_je_headers
     -- Check to ensure rows are not updated if process errors out

--     IF l_retcode = 0 THEN
       /* means no error in the upgrade */

--        IF p_application_id <> 707 THEN

--           SELECT je_source_name
--             INTO l_source_name
--             FROM XLA_SUBLEDGERS
--            WHERE application_id = p_application_id;

--fnd_file.put_line(fnd_file.log, '*Source name : '|| l_source_name);

--           UPDATE gl_je_headers a
--              SET a.je_from_sla_flag = 'U'
--            WHERE (decode(a.je_source, l_source_name, p_application_id)
--   	              ,ledger_id, period_name) in
--              (SELECT application_id, ledger_id, period_name
--                 FROM gl_period_statuses b
--                WHERE b.start_date  >= l_start_date
--		  AND b.end_date     <  l_end_date
--		  AND b.ledger_id    = l_ledger_id
--                  AND application_id = p_application_id)
--		  AND a.ledgeR_id    = l_ledger_id;

--fnd_file.put_line(fnd_file.log, '*Flags updated to U : '|| to_char(SQL%ROWCOUNT));

--          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--              trace('Updated gl_je_headers',
--                    C_LEVEL_STATEMENT, l_Log_module);
--          END IF;

--        ELSE

--           UPDATE gl_je_headers a
--              SET a.je_from_sla_flag = 'U'
--            WHERE (decode(a.je_source,'Purchasing',201,'Inventory',401)
--   	              ,ledger_id, period_name) in
--              (SELECT application_id, ledger_id, period_name
--                 FROM gl_period_statuses b
--                WHERE b.start_date  >= l_start_date
--		  AND b.end_date < l_end_date
--		  AND b.ledger_id = l_ledger_id
--                  AND application_id in (201,401))
--		  AND a.ledgeR_id = l_ledger_id;

--fnd_file.put_line(fnd_file.log, '*Flags updated to U : '|| to_char(SQL%ROWCOUNT));

--          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--              trace('Updated gl_je_headers',
--                    C_LEVEL_STATEMENT, l_Log_module);
--          END IF;

--	  COMMIT;
--        END IF;

--     ELSE

--         IF p_application_id = 707 THEN

--	      UPDATE gl_period_statuses
--		 SET migration_status_code = NULL
--	       WHERE ledger_id = l_ledger_id
--		 AND (start_date >= l_start_date
--		      and end_date < l_end_date)
--		 AND application_id in (201,401)
--		 AND adjustment_period_flag = 'N'
--		 AND migration_status_code = 'P';

--fnd_file.put_line(fnd_file.log, '*Migration status code back to NULL : '|| to_char(SQL%ROWCOUNT));

--	 ELSE

--	      UPDATE gl_period_statuses
--		 SET migration_status_code = NULL
--	       WHERE application_id = l_application_id
--		 AND ledger_id      = l_ledger_id
--		 AND (start_date   >= l_start_date
--		      AND end_date  < l_end_date)
--		 AND adjustment_period_flag = 'N'
--		 AND migration_status_code = 'P';

--fnd_file.put_line(fnd_file.log, '*Migration status code back to NULL : '|| to_char(SQL%ROWCOUNT));

--	 END IF;

--         RAISE UPGRADE_ERROR;

--     END IF;

--  END IF;

--  COMMIT;

--EXCEPTION
--   WHEN NO_UPGRADE THEN
--      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--          trace('This is either a fresh R12 installation or upgrade from
--	         an existing 11i instance has not taken place.',
--                C_LEVEL_ERROR, l_Log_module);
--      END IF;

--   fnd_file.put_line(fnd_file.log, 'This is either a fresh R12
--                                    installation or upgrade
--                                    from an existing 11i instance
--				    has not taken place.');

--      l_temp := fnd_concurrent.set_completion_status
--  	             (status    => 'WARNING'
--  	             ,message   => NULL);

--   WHEN UPGRADE_ERROR THEN
--      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
--          trace('There has been an error in the Product Upgrade',
--                C_LEVEL_ERROR, l_Log_module);
--      END IF;

--   fnd_file.put_line(fnd_file.log, 'Product Team API Failed');

--      l_temp := fnd_concurrent.set_completion_status
--  	             (status    => 'ERROR'
--  	             ,message   => NULL);

--   WHEN xla_exceptions_pkg.application_exception THEN
--      RAISE;
--   WHEN OTHERS THEN
--      xla_exceptions_pkg.raise_message
--         (p_location   => 'XLA_UPGRADE_PUB.set_status_code');
--END SET_STATUS_CODE;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Validate_Header_Line_Entries                                                |
|                                                                             |
| This routine is called to validate the Header entries in upgrade.           |
|                                                                             |
+============================================================================*/

 PROCEDURE Validate_Header_Line_Entries
 (p_application_id IN NUMBER,
  p_header_id      IN NUMBER) IS

   l_entity_id t_entity_id;
   l_event_id t_event_id;
   l_header_id t_header_id;
   l_line_num t_line_num;
   l_header_error1 t_error_flag;
   l_header_error2 t_error_flag;
   l_header_error3 t_error_flag;
   l_header_error4 t_error_flag;
   l_header_error5 t_error_flag;
   l_line_error1 t_error_flag;
   l_line_error2 t_error_flag;
   l_line_error3 t_error_flag;
   l_line_error4 t_error_flag;
   l_line_error5 t_error_flag;
   l_line_error6 t_error_flag;
   l_line_error7 t_error_flag;
   l_line_error8 t_error_flag;
   l_line_error9 t_error_flag;
   l_line_error10 t_error_flag;
   l_log_module   VARCHAR2(240);
   l_rowcount   number(15) := 0;

BEGIN

   g_application_id        := p_application_id;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace
         (p_msg      => 'BEGIN of procedure Validate_Header_Line_Entries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   =>l_log_module);
   END IF;

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Validate_Header_Line_Entries';
   END IF;

   -- Deleting all xla_upg_errors from previous run

   delete from xla_upg_errors
    where application_id = p_application_id
      and error_message_name IN ('XLA_UPG_LEDGER_INVALID'
                                 ,'XLA_UPG_NO_BUDGET_VER'
				 ,'XLA_UPG_NO_ENC_TYPE'
				 ,'XLA_UPG_BALTYP_INVALID'
				 ,'XLA_UPG_HDR_WO_EVT'
				 ,'XLA_UPG_UNBAL_ACCAMT'
				 ,'XLA_UPG_UNBAL_ENTRAMT'
				 ,'XLA_UPG_HDR_WO_LINES'
				 , 'XLA_UPG_CCID_INVALID'
                                 ,'XLA_UPG_CCID_SUMACCT'
				 ,'XLA_UPG_CCID_NOBUDGET'
				 ,'XLA_UPG_PARTY_TYP_INVALID'
				 ,'XLA_UPG_DRCR_NULL'
				 ,'XLA_UPG_ENTAMT_DIFF_ACCAMT'
				 ,'XLA_UPG_LINE_NO_HDR'
				 ,'XLA_UPG_ENTAMT_ACCAMT_DIFFSIDE'
				 ,'XLA_UPG_PARTY_ID_INVALID'
				 ,'XLA_UPG_PARTY_SITE_INVALID'
				 ,'XLA_LINE_VERIFICATION_RECORD'
				 ,'XLA_HDR_VERIFICATION_RECORD');

         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
	 (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name, ae_header_id)
	 (select
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,-9999
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'H'
         ,decode(grm.multiplier,1,'XLA_UPG_LEDGER_INVALID'
	                       ,2,'XLA_UPG_NO_BUDGET_VER'
			       ,3,'XLA_UPG_NO_ENC_TYPE'
			       ,4,'XLA_UPG_BALTYP_INVALID'
			         ,'XLA_UPG_HDR_WO_EVT')
	 ,ae_header_id
	 from ( select ae_header_id
                       ,CASE when gll.ledger_id IS NULL THEN 'Y'
                        ELSE 'N' END header_error1-- Ledger Id is Invalid
                       ,CASE when xah.BALANCE_TYPE_CODE = 'B'
                               and xah.BUDGET_VERSION_ID IS NULL THEN 'Y'
                        ELSE 'N' END header_error2-- No Budget Version
                       ,CASE when xah.BALANCE_TYPE_CODE = 'E'
                              and  xah.ENCUMBRANCE_TYPE_ID IS NULL THEN 'Y'
                        ELSE 'N' END header_error3-- No Enc Type
                       ,CASE when xah.BALANCE_TYPE_CODE NOT IN ('A','B','E')
		             THEN 'Y'
                        ELSE 'N' END header_error4-- Balance type code invalid
                      ,CASE when xe.event_id IS NULL THEN 'Y'
                       ELSE 'N' END header_error5-- Header without valid event
                  from xla_ae_headers xah
                      ,gl_ledgers gll
                      ,xla_events xe
                 where gll.ledger_id (+) = xah.ledger_id
                   and xe.event_id (+) = xah.event_id
                   and (gll.ledger_id IS NULL OR
                       (xah.BALANCE_TYPE_CODE = 'B' AND
                        xah.BUDGET_VERSION_ID IS NULL) OR
                       (xah.BALANCE_TYPE_CODE = 'E' AND
                        xah.ENCUMBRANCE_TYPE_ID IS NULL) OR
                       xah.BALANCE_TYPE_CODE NOT IN ('A','B','E') OR
                       xe.event_id IS NULL)
                   and xah.application_id = p_application_id
		   and xah.ae_header_id = p_header_id) xah
              ,gl_row_multipliers grm
        where grm.multiplier < 6
          and decode(grm.multiplier,
	             1,header_error1,
		     2,header_error2,
		     3,header_error3,
		     4,header_error4,
		       header_error5) = 'Y');
         COMMIT;

         l_rowcount := l_rowcount + sql%rowcount;

         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
         (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name, ae_header_id)
         (select
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,-9999
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
         ,-9999
         , 'H'
         ,decode(grm.multiplier,1,'XLA_UPG_UNBAL_ACCAMT'
	                         ,'XLA_UPG_UNBAL_ENTRAMT')
	 ,ae_header_id
         from (select /*+ no_merge */ xal.ae_header_id,
                 case when nvl(sum(accounted_dr), 0) <> nvl(sum(accounted_cr), 0)
                 then 'Y' else 'N' end header_error1, -- amts not balanced,
                 case when nvl(sum(entered_dr), 0) <> nvl(sum(entered_cr), 0)
                 then 'Y' else 'N' end header_error2 -- entered amts not balanced
                 from xla_ae_lines xal
                where xal.application_id = p_application_id
		  and xal.ae_header_id = p_header_id
                  and xal.currency_code <> 'STAT'
                  and xal.ledger_id in (select gll.ledger_id
                                          from gl_ledgers gll
                                         where gll.suspense_allowed_flag = 'N')
                                      group by xal.ae_header_id
                                        having nvl(sum(accounted_dr), 0)
					       <> nvl(sum(accounted_cr), 0)
                                            or nvl(sum(entered_dr), 0)
					       <> nvl(sum(entered_cr), 0)) xal,
              gl_row_multipliers grm
        where xal.ae_header_id in ( select /*+ use_hash(xah) swap_join_inputs(xah) */
                                          xah.ae_header_id
                                     from xla_ae_headers xah
                                    where xah.application_id = p_application_id
				      and xah.ae_header_id = p_header_id
                                      and xah.balance_type_code <> 'B')
         and grm.multiplier < 3
         and decode(grm.multiplier, 1, header_error1, header_error2) = 'Y');

         COMMIT;

         l_rowcount := l_rowcount + sql%rowcount;

         INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
         (upg_error_id, application_id, upg_source_application_id,creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, ae_header_id, error_message_name)
	 (select xla_upg_errors_s.nextval
	 ,g_application_id
	 ,-9999
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
         ,-9999
         , 'H'
         ,ae_header_id
         ,'XLA_UPG_HDR_WO_LINES'
	 from (select xah.ae_header_id
                 from  xla_ae_headers xah
                where NOT EXISTS (SELECT xal.ae_header_id
                                    from xla_ae_lines xal
                                   where xah.ae_header_id = xal.ae_header_id
                                     and xah.application_id = xal.application_id
                            	     and xal.application_id = p_application_id
                                     and xal.ae_header_id = p_header_id)
                  and application_id = p_application_id
		  and ae_header_id = p_header_id));
         COMMIT;

       l_rowcount := l_rowcount + sql%rowcount;

       If l_rowcount > 0 THEN
          UPDATE xla_ae_headers
             set upg_valid_flag = CASE upg_valid_flag
                               WHEN 'F' THEN 'L'
                               WHEN 'J' THEN 'M'
                               WHEN 'I' THEN 'N'
                               ELSE 'K'
			       END
           where  ae_header_id = p_header_id;
       end if;

        l_rowcount := sql%rowcount;

     INSERT INTO XLA_UPG_ERRORS
       (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name,entity_id)
        values(
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,-9999
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'V'
	 ,'XLA_HDR_VERIFICATION_RECORD'
         ,l_rowcount);

   COMMIT;

   l_rowcount := 0;

            INSERT /*+ APPEND */ INTO XLA_UPG_ERRORS
         (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, ae_header_id, ae_line_num,error_message_name)
         (select
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,-9999
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
         ,-9999
         , 'L'
         ,ae_header_id
         ,ae_line_num
         ,decode(grm.multiplier,1,'XLA_UPG_CCID_INVALID'
	                       ,2,'XLA_UPG_CCID_SUMACCT'
			       ,3,'XLA_UPG_CCID_NOBUDGET'
			       ,4,'XLA_UPG_PARTY_TYP_INVALID'
			       ,5,'XLA_UPG_DRCR_NULL'
			       ,6,'XLA_UPG_ENTAMT_DIFF_ACCAMT'
			       ,7,'XLA_UPG_LINE_NO_HDR'
			       ,8,'XLA_UPG_ENTAMT_ACCAMT_DIFFSIDE'
			       ,9,'XLA_UPG_PARTY_ID_INVALID'
			       ,'XLA_UPG_PARTY_SITE_INVALID')
         from ( select  xal.ae_header_id
          , ae_line_num
          , CASE when glcc.CHART_OF_ACCOUNTS_ID IS NULL THEN 'Y'
                 ELSE 'N'  END line_error1-- Invalid Code Combination Id
          , CASE when glcc.CHART_OF_ACCOUNTS_ID IS NOT NULL
                 and  glcc.SUMMARY_FLAG = 'Y' THEN 'Y'
   	         ELSE 'N'  END line_error2-- CCID not a Summary Account
          , CASE when glcc.CHART_OF_ACCOUNTS_ID IS NOT NULL
                 and  xah.APPLICATION_ID IS NOT NULL
                 and  xah.BALANCE_TYPE_CODE = 'B'
                 and  glcc.DETAIL_BUDGETING_ALLOWED_FLAG  <> 'Y' THEN 'Y'
   	         ELSE 'N'  END line_error3-- Budgeting not allowed
          , CASE when xal.PARTY_TYPE_CODE IS NOT NULL
                 and  xal.PARTY_TYPE_CODE NOT IN ('C','S') THEN 'Y'
                 ELSE 'N'  END line_error4-- Invalid Party Type Code
          , CASE when (xal.accounted_dr is NULL AND xal.accounted_cr is NULL)
                 or   (xal.entered_dr is NULL AND xal.entered_cr is NULL)
                 or   (xal.accounted_dr is NOT NULL
		       AND xal.accounted_cr is NOT NULL)
                 or   (xal.entered_dr is NOT NULL
		       AND xal.entered_cr is NOT NULL)
   	         THEN 'Y'
   	         ELSE 'N'  END line_error5
          , CASE when gll.currency_code IS NOT NULL
                 and  xal.currency_code = gll.currency_code
   	         and  (nvl(xal.entered_dr,0) <> nvl(xal.accounted_dr,0)
   	         or    nvl(xal.entered_cr,0) <> nvl(xal.accounted_cr,0))
		 THEN 'Y'
   	         ELSE 'N'  END line_error6
          , CASE when xah.application_id IS NULL THEN 'Y'
                 ELSE 'N'  END line_error7-- Orphan Line.
          , CASE when (xal.accounted_dr is NOT NULL and
                       xal.entered_cr is NOT NULL) or
                      (xal.accounted_cr is NOT NULL and
                       xal.entered_dr is NOT NULL) THEN 'Y'
                 ELSE 'N'  END line_error8
          ,CASE when xal.party_id IS NULL THEN 'Y'
	         ELSE 'N' END line_error9
	  , CASE when xal.party_site_id IS NULL
	          and xal.party_id IS NULL then 'Y'
	         ELSE 'N' END line_error10
  FROM     xla_ae_headers         xah
          , xla_ae_lines           xal
          , gl_code_combinations   glcc
          , gl_ledgers             gll
	  , hz_parties             hz
	  , hz_party_sites         hps
   WHERE  glcc.code_combination_id(+) = xal.code_combination_id
   AND    xah.ae_header_id            = xal.ae_header_id
   AND    gll.ledger_id(+)            = xah.ledger_id
   AND    xal.party_id(+)             = hz.party_id
   AND    xal.party_site_id           = hps.party_site_id
   AND    (glcc.CHART_OF_ACCOUNTS_ID IS NULL OR
           (glcc.CHART_OF_ACCOUNTS_ID IS NOT NULL AND
            glcc.SUMMARY_FLAG = 'Y' ) OR
           (glcc.CHART_OF_ACCOUNTS_ID IS NOT NULL AND
            xah.APPLICATION_ID IS NOT NULL AND
            xah.BALANCE_TYPE_CODE = 'B' AND
            glcc.DETAIL_BUDGETING_ALLOWED_FLAG  <> 'Y') OR
           (xal.PARTY_TYPE_CODE IS NOT NULL AND
            xal.PARTY_TYPE_CODE NOT IN ('C','S') ) OR
           (xal.accounted_dr is NULL AND xal.accounted_cr is NULL) OR
           (xal.entered_dr is NULL AND xal.entered_cr is NULL) OR
           (xal.accounted_dr is NOT NULL AND xal.accounted_cr is NOT NULL) OR
           (xal.entered_dr is NOT NULL AND xal.entered_cr is NOT NULL) OR
           (gll.currency_code IS NOT NULL AND
            xal.currency_code = gll.currency_code AND
            (nvl(xal.entered_dr,0) <> nvl(xal.accounted_dr,0) OR
             nvl(xal.entered_cr,0) <> nvl(xal.accounted_cr,0))) OR
           ((xal.accounted_dr is NOT NULL and xal.entered_cr is NOT NULL) OR
            (xal.accounted_cr is NOT NULL and xal.entered_dr is NOT NULL)) OR
           (xah.application_id IS NULL))
   and    xal.application_id = p_application_id
   and    xal.ae_header_id   = p_header_id) xal
   ,gl_row_multipliers grm
   where grm.multiplier < 11
   and decode (grm.multiplier,1,line_error1
                             ,2,line_error2
                             ,3,line_error3
                             ,4,line_error4
                             ,5,line_error5
                             ,6,line_error6
                             ,7,line_error7
                             ,8,line_error8
                             ,9,line_error9
                             ,line_error10) = 'Y');

   COMMIT;

         l_rowcount := l_rowcount + sql%rowcount;

         If l_rowcount > 0 THEN
           UPDATE xla_ae_headers
              set upg_valid_flag = CASE upg_valid_flag
                               WHEN 'F' THEN 'P'
                               WHEN 'J' THEN 'Q'
                               WHEN 'I' THEN 'R'
                               WHEN 'L' THEN 'S'
                               WHEN 'M' THEN 'T'
                               WHEN 'N' THEN 'U'
                               ELSE 'O'
			       END
           where  ae_header_id = p_header_id
   	     and    application_id = p_application_id;

	  end if;


      -- finding out how many rows got updated.

         l_rowcount := sql%rowcount;

      INSERT INTO XLA_UPG_ERRORS
       (upg_error_id, application_id, upg_source_application_id, creation_date
	 , created_by, last_update_date, last_updated_by, upg_batch_id
	 , error_level, error_message_name,entity_id)
        values(
	 xla_upg_errors_s.nextval
	 ,g_application_id
	 ,-9999
	 ,sysdate
	 ,-1
	 ,sysdate
	 ,-1
	 ,-9999
	 , 'V'
	 ,'XLA_LINE_VERIFICATION_RECORD'
         ,l_rowcount);

   COMMIT;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'XLA_UPGRADE_PUB.Validate_Header_Line_Entries');

END Validate_Header_Line_Entries;

/*============================================================================+
|                                                                             |
| Public Procedure                                                            |
|                                                                             |
| Pre_Upgrade_Set_Status_Code                                                 |
|                                                                             |
| This procedure is called during the Pre Upgrade phase, to update the        |
| status code.                                                                |
+============================================================================*/

PROCEDURE pre_upgrade_set_status_code
(p_error_buf             OUT NOCOPY VARCHAR2,
 p_retcode               OUT NOCOPY NUMBER,
 p_migrate_all_ledgers   IN VARCHAR2,
 p_dummy_parameter       IN VARCHAR2,
 p_ledger_id             IN NUMBER DEFAULT NULL,
 p_start_date            IN VARCHAR2
) IS

CURSOR CUR_ALL_LEDGERS IS SELECT DISTINCT ledger_id
                            FROM gl_period_statuses;

l_migrate_all_ledgers    VARCHAR2(30);
l_ledger_id              NUMBER;
l_start_date             date;
l_error_buf              VARCHAR2(1000);
l_retcode                NUMBER;
l_end_date               date;
l_log_module             VARCHAR2(240);

l_all_ledgers            CUR_ALL_LEDGERS%ROWTYPE;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.pre_upgrade_set_status_code';
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('pre_upgrade_set_status_code.Begin',C_LEVEL_STATEMENT,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Date '||p_start_date,C_LEVEL_STATEMENT,l_log_module);
   END IF;

   l_migrate_all_ledgers   := p_migrate_all_ledgers;
   l_start_date            := fnd_date.canonical_to_date(p_start_date);
   l_ledger_id             := p_ledger_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_migrate_all_ledgers '|| l_migrate_all_ledgers,
             C_LEVEL_STATEMENT, l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_ledger_id '||l_ledger_id,
             C_LEVEL_STATEMENT, l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('l_start_date '||l_start_date,
             C_LEVEL_STATEMENT, l_Log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace('Processing periods...',
             C_LEVEL_STATEMENT, l_Log_module);
   END IF;

  IF l_migrate_all_ledgers = 'N' THEN

          SELECT min(start_date) - 1
            INTO l_end_date
            FROM gl_period_statuses
           WHERE migration_status_code = 'P'
             AND ledger_id       = l_ledger_id
             AND application_id  in (200,222,275,201,401,101,8721);

          IF l_end_date is NULL THEN

             SELECT max(end_date)
               INTO l_end_date
               FROM gl_period_statuses
              WHERE ledger_id       = l_ledger_id
                AND application_id  IN (200,222,275,201,401,101,8721);
          END IF;

          UPDATE gl_period_statuses
             SET migration_status_code = 'P'
           WHERE ledger_id = l_ledger_id
             AND (start_date >= l_start_date
                    and end_date <= l_end_date)
             AND application_id in (200,222,275,201,401,101,8721)
             AND adjustment_period_flag = 'N'
             AND migration_status_code IS NULL;

  ELSE

       OPEN CUR_ALL_LEDGERS;
       LOOP
           FETCH CUR_ALL_LEDGERS INTO l_all_ledgers;
           EXIT when CUR_ALL_LEDGERS%notfound;

           SELECT min(start_date) - 1
             INTO l_end_date
             FROM gl_period_statuses
            WHERE migration_status_code = 'P'
              AND ledger_id       = l_all_ledgers.ledger_id
              AND application_id  in (200,222,275,201,401,101,8721);

           IF l_end_date is NULL THEN

              SELECT max(end_date)
                INTO l_end_date
                FROM gl_period_statuses
               WHERE ledger_id       = l_all_ledgers.ledger_id
                 AND application_id  in (200,222,275,201,401,101,8721);

           END IF;

           -- Updation of GL Period Statuses.

           UPDATE gl_period_statuses
              SET migration_status_code = 'P'
            WHERE ledger_id      = l_all_ledgers.ledger_id
              AND (start_date   >= l_start_date
                   and end_date <= l_end_date)
              AND application_id in (200,222,275,201,401,101,8721)
              AND adjustment_period_flag = 'N'
              AND migration_status_code IS NULL;


          IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace('Updated gl_period_statuses.'
                     , C_LEVEL_STATEMENT, l_Log_module);
           END IF;

        END LOOP;
        CLOSE CUR_ALL_LEDGERS;

   END IF;

EXCEPTION

   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'XLA_UPGRADE_PUB.pre_upgrade_set_status_code');

END PRE_UPGRADE_SET_STATUS_CODE;


BEGIN
      g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,MODULE     => C_DEFAULT_MODULE);

      IF NOT g_log_enabled  THEN
         g_log_level := C_LEVEL_LOG_DISABLED;
      END IF;

END XLA_UPGRADE_PUB;

/
