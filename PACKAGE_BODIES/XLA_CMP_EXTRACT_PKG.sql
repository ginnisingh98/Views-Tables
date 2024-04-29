--------------------------------------------------------
--  DDL for Package Body XLA_CMP_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_EXTRACT_PKG" AS
/* $Header: xlacpext.pkb 120.60.12000000.2 2007/10/12 06:09:08 samejain ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_extract_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to generate header and line cursors from AMB specifcations             |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUN-2002 K.Boussema    Created                                      |
|     10-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added amb_context_code                       |
|     14-APR-2003 K.Bouusema    Added the error messages                     |
|     05-MAI-2003 K.Boussema    Modified to retrieve data base on ledger_id  |
|     13-MAI-2003 K.Boussema    Modified the Extract according to bug 2857548|
|     24-JUN-2003 K.Boussema    Reviewed the erro messages, bug 3022261      |
|     17-JUL-2003 K.Boussema    Reviewed the code                            |
|     26-AUG-2003 K.Boussema    Reviewed the generation of the extract to    |
|                               handle the use of line_number as source      |
|     22-SEP-2003 K.Boussema    Added validation of primary keys columns     |
|     29-SEP-2003 K.Boussema    Added Error message XLA_CMP_PK_MISSING       |
|     09-OCT-2003 K.Boussema    Changed to accept AADs differents Extract    |
|                               specifcations                                |
|     12-DEC-2003 K.Boussema    Reviewed for bug bug 3042840                 |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     22-DEC-2003 K.Boussema    Replaced Extract Validations by a call to    |
|                               Extract Integrity Checker routine            |
|     30-DEC-2003 K.Boussema    Reviewed  GetExtractObjects procedure        |
|     05-JAN-2004 K.Boussema    Changed GenerateLineCursor,                  |
|                               GenerateExtractColumns and                   |
|                               GenerateHeaderCursor procedures              |
|     02-FEB-2004 K.Boussema    Reviewed FlushGtTable procedure              |
|     11-FEB-2004 K.Boussema    Revised GenerateHeaderCursor procedure       |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups |
|                               from the extract objects                     |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema    Removed the call to XLA trace routine from   |
|                               trace() procedure                            |
|     20-Sep-2004 S.Singhania   Made chnages for the bulk performance:       |
|                                 - Added routines GenerateHdrStructure and  |
|                                   GenerateCacheHdrSources                  |
|                                 - Modified routines GenerateHdrVariables,  |
|                                   GenerateLineStructure,GenerateLineCursor,|
|                                   GenerateHeaderCursor, GenerateFetchLineCu|
|                                   rsor, GenerateFetchHeaderCursor          |
|                                 - Replace the constant C_HDR_CUR with C_HDR|
|                                   _CUR_EVENT_TYPE and C_HDR_CUR_EVENT_CLASS|
|                                 - Replace the constant C_LINE_CUR with C_LI|
|                                   NE_CUR_EVENT_TYPE, C_LINE_CUR_EVENT_CLASS|
|     06-Oct-2004 K.Boussema    Made changes for the Accounting Event Extract|
|                               Diagnostics feature.                         |
|     08-DEC-2004 K.Boussema    Updated to change  xla_extract_sources table |
|                               by xla_diag_sources                          |
|     03-Mar-2005 W.shen        remove the hint in line cursor               |
|     06-Mar-2005 W.shen        Ledger Currency Project.                     |
|                                 Remove the ledger currency level extract   |
|                                 object. Add ledger_id to ledger line level |
|                                 object. join to ledger_id depends on alc   |
|                                 setting .                                  |
|     08-Jun-2005 K.Boussema   Reviewed C_INSERT_LINE_SOURCES_CLASS constant |
|                                 to fix bug 4200257                         |
|     21-JUL-2005 K.Boussema   Reviewed to handle the two cases:             |
|                                - no header Transaction objects and         |
|                                - no line Transaction objects               |
|     01-Aug-2005 W. Chan     4458381 - Public Sector Enhancement            |
|     11-Sep-2006 V. Swapna    Bug 5478323: Correct an ORA-01400             |
|                              error on the table xla_diag_sources.          |
+===========================================================================*/
--
--
--+==========================================================================+
--|                                                                          |
--| GLOBAL CONSTANTS                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--+==========================================================================+
--|                                                                          |
--| Header CURSOR Template                                                   |
--|                                                                          |
--+==========================================================================+
--
--
C_HDR_CUR_EVENT_TYPE         CONSTANT   VARCHAR2(10000):='
--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Type Code: $event_type_code$
-- Event Class Code: $event_class_code$
    xet.entity_id
  , xet.legal_entity_id
  , xet.entity_code
  , xet.transaction_number
  , xet.event_id
  , xet.event_class_code
  , xet.event_type_code
  , xet.event_number
  , xet.event_date
  , xet.transaction_date
  , xet.reference_num_1
  , xet.reference_num_2
  , xet.reference_num_3
  , xet.reference_num_4
  , xet.reference_char_1
  , xet.reference_char_2
  , xet.reference_char_3
  , xet.reference_char_4
  , xet.reference_date_1
  , xet.reference_date_2
  , xet.reference_date_3
  , xet.reference_date_4
  , xet.event_created_by
  , xet.budgetary_control_flag $hdr_sources$
  FROM xla_events_gt     xet $hdr_tabs$
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_type_code = C_EVENT_TYPE_CODE
   and xet.event_status_code <> ''N'' $hdr_clauses$
 ORDER BY event_id
;
';

C_HDR_CUR_EVENT_CLASS         CONSTANT   VARCHAR2(10000):='
--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: $event_class_code$
    xet.entity_id
   ,xet.legal_entity_id
   ,xet.entity_code
   ,xet.transaction_number
   ,xet.event_id
   ,xet.event_class_code
   ,xet.event_type_code
   ,xet.event_number
   ,xet.event_date
   ,xet.transaction_date
   ,xet.reference_num_1
   ,xet.reference_num_2
   ,xet.reference_num_3
   ,xet.reference_num_4
   ,xet.reference_char_1
   ,xet.reference_char_2
   ,xet.reference_char_3
   ,xet.reference_char_4
   ,xet.reference_date_1
   ,xet.reference_date_2
   ,xet.reference_date_3
   ,xet.reference_date_4
   ,xet.event_created_by
   ,xet.budgetary_control_flag $hdr_sources$
  FROM xla_events_gt     xet $hdr_tabs$
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> ''N'' $hdr_clauses$
 ORDER BY event_id
;
';
--
--
--+==========================================================================+
--|                                                                          |
--| Line CURSOR Template                                                     |
--|                                                                          |
--+==========================================================================+
--
--
C_LINE_CUR_EVENT_TYPE        CONSTANT   VARCHAR2(10000):='
--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Type Code: $event_type_code$
-- Event Class Code: $event_class_code$
    xet.entity_id
   ,xet.legal_entity_id
   ,xet.entity_code
   ,xet.transaction_number
   ,xet.event_id
   ,xet.event_class_code
   ,xet.event_type_code
   ,xet.event_number
   ,xet.event_date
   ,xet.transaction_date
   ,xet.reference_num_1
   ,xet.reference_num_2
   ,xet.reference_num_3
   ,xet.reference_num_4
   ,xet.reference_char_1
   ,xet.reference_char_2
   ,xet.reference_char_3
   ,xet.reference_char_4
   ,xet.reference_date_1
   ,xet.reference_date_2
   ,xet.reference_date_3
   ,xet.reference_date_4
   ,xet.event_created_by
   ,xet.budgetary_control_flag $line_sources$
  FROM xla_events_gt     xet $line_tabs$
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_type_code = C_EVENT_TYPE_CODE
   and xet.event_status_code <> ''N'' $line_clauses$;
';

C_LINE_CUR_EVENT_CLASS        CONSTANT   VARCHAR2(10000):='
--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: $event_class_code$
    xet.entity_id
   ,xet.legal_entity_id
   ,xet.entity_code
   ,xet.transaction_number
   ,xet.event_id
   ,xet.event_class_code
   ,xet.event_type_code
   ,xet.event_number
   ,xet.event_date
   ,xet.transaction_date
   ,xet.reference_num_1
   ,xet.reference_num_2
   ,xet.reference_num_3
   ,xet.reference_num_4
   ,xet.reference_char_1
   ,xet.reference_char_2
   ,xet.reference_char_3
   ,xet.reference_char_4
   ,xet.reference_date_1
   ,xet.reference_date_2
   ,xet.reference_date_3
   ,xet.reference_date_4
   ,xet.event_created_by
   ,xet.budgetary_control_flag
$line_sources$
  FROM xla_events_gt     xet $line_tabs$
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> ''N'' $line_clauses$;
';

--
-----------------------------------------------------------------------------
--
--             Accounting Event Extract Diagnostics Constants/Templates
--
------------------------------------------------------------------------------
--
--+==========================================================================+
--|                                                                          |
--| Insert header sources Template                                           |
--|                                                                          |
--+==========================================================================+
--
--
C_INSERT_HDR_SOURCES_EVT         CONSTANT   VARCHAR2(10000):='
--
INSERT INTO xla_diag_sources --hdr1
(
        event_id
      , ledger_id
      , sla_ledger_id
      , description_language
      , object_name
      , object_type_code
      , line_number
      , source_application_id
      , source_type_code
      , source_code
      , source_value
      , source_meaning
      , created_by
      , creation_date
      , last_update_date
      , last_updated_by
      , last_update_login
      , program_update_date
      , program_application_id
      , program_id
      , request_id
)
SELECT
        event_id
      , p_target_ledger_id
      , p_sla_ledger_id
      , p_language
      , object_name
      , object_type_code
      , line_number
      , source_application_id
      , source_type_code
      , source_code
      , SUBSTR(source_value ,1,1996)
      , SUBSTR(source_meaning,1,200)
      , xla_environment_pkg.g_Usr_Id
      , TRUNC(SYSDATE)
      , TRUNC(SYSDATE)
      , xla_environment_pkg.g_Usr_Id
      , xla_environment_pkg.g_Login_Id
      , TRUNC(SYSDATE)
      , xla_environment_pkg.g_Prog_Appl_Id
      , xla_environment_pkg.g_Prog_Id
      , xla_environment_pkg.g_Req_Id
  FROM (
       SELECT xet.event_id                  event_id
            , 0                             line_number
            , CASE r
               $object_name$
               ELSE null
              END                           object_name
            , CASE r
                $object_type_code$
                ELSE null
              END                           object_type_code
            , CASE r
                $source_application_id$
                ELSE null
              END                           source_application_id
            , $source_type_code$            source_type_code
            , CASE r
                $source_code$
                ELSE null
              END                           source_code
            , CASE r
                $source_value$
                ELSE null
              END                           source_value
            , $source_meaning$              source_meaning
        FROM xla_events_gt     xet  $hdr_tabs$
            ,(select rownum r from all_objects where rownum <= $source_number$ and owner = p_apps_owner)
       WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
         AND xet.event_type_code = C_EVENT_TYPE_CODE
         $hdr_clauses$
)
;
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => ''number of header sources inserted = ''||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
';
--
--
--+==========================================================================+
--|                                                                          |
--| Insert header sources Template                                           |
--|                                                                          |
--+==========================================================================+
--
--
C_INSERT_HDR_SOURCES_CLASS         CONSTANT   VARCHAR2(10000):='
--
INSERT INTO xla_diag_sources --hdr2
(
        event_id
      , ledger_id
      , sla_ledger_id
      , description_language
      , object_name
      , object_type_code
      , line_number
      , source_application_id
      , source_type_code
      , source_code
      , source_value
      , source_meaning
      , created_by
      , creation_date
      , last_update_date
      , last_updated_by
      , last_update_login
      , program_update_date
      , program_application_id
      , program_id
      , request_id
)
SELECT
        event_id
      , p_target_ledger_id
      , p_sla_ledger_id
      , p_language
      , object_name
      , object_type_code
      , line_number
      , source_application_id
      , source_type_code
      , source_code
      , SUBSTR(source_value ,1,1996)
      , SUBSTR(source_meaning ,1,200)
      , xla_environment_pkg.g_Usr_Id
      , TRUNC(SYSDATE)
      , TRUNC(SYSDATE)
      , xla_environment_pkg.g_Usr_Id
      , xla_environment_pkg.g_Login_Id
      , TRUNC(SYSDATE)
      , xla_environment_pkg.g_Prog_Appl_Id
      , xla_environment_pkg.g_Prog_Id
      , xla_environment_pkg.g_Req_Id
  FROM (
       SELECT xet.event_id                  event_id
            , 0                          line_number
            , CASE r
               $object_name$
               ELSE null
              END                           object_name
            , CASE r
                $object_type_code$
                ELSE null
              END                           object_type_code
            , CASE r
                $source_application_id$
                ELSE null
              END                           source_application_id
            , $source_type_code$            source_type_code
            , CASE r
                $source_code$
                ELSE null
              END                           source_code
            , CASE r
                $source_value$
                ELSE null
              END                           source_value
            , $source_meaning$              source_meaning
         FROM xla_events_gt     xet  $hdr_tabs$
             ,(select rownum r from all_objects where rownum <= $source_number$ and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
           $hdr_clauses$
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => ''number of header sources inserted = ''||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
';
--
--
--+==========================================================================+
--|                                                                          |
--| Insert Line sources Template                                             |
--|                                                                          |
--+==========================================================================+
--
--
C_INSERT_LINE_SOURCES_EVT         CONSTANT   VARCHAR2(10000):='
--
INSERT INTO xla_diag_sources --line1
(
        event_id
      , ledger_id
      , sla_ledger_id
      , description_language
      , object_name
      , object_type_code
      , line_number
      , source_application_id
      , source_type_code
      , source_code
      , source_value
      , source_meaning
      , created_by
      , creation_date
      , last_update_date
      , last_updated_by
      , last_update_login
      , program_update_date
      , program_application_id
      , program_id
      , request_id
)
SELECT  event_id
      , p_target_ledger_id
      , p_sla_ledger_id
      , p_language
      , object_name
      , object_type_code
      , line_number
      , source_application_id
      , source_type_code
      , source_code
      , SUBSTR(source_value,1,1996)
      , SUBSTR(source_meaning,1,200)
      , xla_environment_pkg.g_Usr_Id
      , TRUNC(SYSDATE)
      , TRUNC(SYSDATE)
      , xla_environment_pkg.g_Usr_Id
      , xla_environment_pkg.g_Login_Id
      , TRUNC(SYSDATE)
      , xla_environment_pkg.g_Prog_Appl_Id
      , xla_environment_pkg.g_Prog_Id
      , xla_environment_pkg.g_Req_Id
  FROM (
       SELECT xet.event_id                  event_id
            , $line_number$                 line_number
            , CASE r
               $object_name$
               ELSE null
              END                           object_name
            , CASE r
                $object_type_code$
                ELSE null
              END                           object_type_code
            , CASE r
                $source_application_id$
                ELSE null
              END                           source_application_id
            , $source_type_code$            source_type_code
            , CASE r
                $source_code$
                ELSE null
              END                           source_code
            , CASE r
                $source_value$
                ELSE null
              END                           source_value
            , $source_meaning$              source_meaning
         FROM  xla_events_gt     xet  $line_tabs$
            ,(select rownum r from all_objects where rownum <= $source_number$ and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_type_code = C_EVENT_TYPE_CODE
          $line_clauses$
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => ''number of line sources inserted = ''||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
';
--
--
--+==========================================================================+
--|                                                                          |
--| Insert Line sources Template                                             |
--|                                                                          |
--+==========================================================================+
--
--
C_INSERT_LINE_SOURCES_CLASS         CONSTANT   VARCHAR2(10000):='
--
INSERT INTO xla_diag_sources  --line2
(
        event_id
      , ledger_id
      , sla_ledger_id
      , description_language
      , object_name
      , object_type_code
      , line_number
      , source_application_id
      , source_type_code
      , source_code
      , source_value
      , source_meaning
      , created_by
      , creation_date
      , last_update_date
      , last_updated_by
      , last_update_login
      , program_update_date
      , program_application_id
      , program_id
      , request_id
)
SELECT  event_id
      , p_target_ledger_id
      , p_sla_ledger_id
      , p_language
      , object_name
      , object_type_code
      , line_number
      , source_application_id
      , source_type_code
      , source_code
      , SUBSTR(source_value,1,1996)
      , SUBSTR(source_meaning ,1,200)
      , xla_environment_pkg.g_Usr_Id
      , TRUNC(SYSDATE)
      , TRUNC(SYSDATE)
      , xla_environment_pkg.g_Usr_Id
      , xla_environment_pkg.g_Login_Id
      , TRUNC(SYSDATE)
      , xla_environment_pkg.g_Prog_Appl_Id
      , xla_environment_pkg.g_Prog_Id
      , xla_environment_pkg.g_Req_Id
  FROM (
       SELECT xet.event_id                  event_id
            , $line_number$                 line_number
            , CASE r
               $object_name$
               ELSE null
              END                           object_name
            , CASE r
                $object_type_code$
                ELSE null
              END                           object_type_code
            , CASE r
                $source_application_id$
                ELSE null
              END                           source_application_id
            , $source_type_code$            source_type_code
            , CASE r
                $source_code$
                ELSE null
              END                           source_code
            , CASE r
                $source_value$
                ELSE null
              END                           source_value
            , $source_meaning$              source_meaning
         FROM  xla_events_gt     xet  $line_tabs$
            , (select rownum r from all_objects where rownum <= $source_number$ and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_class_code = C_EVENT_CLASS_CODE
          $line_clauses$
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => ''number of line sources inserted = ''||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
';
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  CONSTANT                                                        |
--|                                                                          |
--+==========================================================================+
--
C_HEADER                     CONSTANT VARCHAR2(30) := 'HEADER'       ;
C_MLS_HEADER                 CONSTANT VARCHAR2(30) := 'HEADER_MLS'   ;
C_LINE                       CONSTANT VARCHAR2(30) := 'LINE'         ;
C_BC_LINE                    CONSTANT VARCHAR2(30) := 'LINE_BASE_CUR';
C_MLS_LINE                   CONSTANT VARCHAR2(30) := 'LINE_MLS'     ;
--
C_DATE                       CONSTANT VARCHAR2(30) := 'DATE';
C_NUMBER                     CONSTANT VARCHAR2(30) := 'NUMBER';
C_VARCHAR2                   CONSTANT VARCHAR2(30) := 'VARCHAR2';
--
C_NOT_ALWAYS_POPULATED       CONSTANT VARCHAR2(1)  := 'N';
C_ALWAYS_POPULATED           CONSTANT VARCHAR2(1)  := 'Y';
--
C_NOT_REF_OBJ                CONSTANT VARCHAR2(1)  := 'N';
--
g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;
g_application_id            XLA_SUBLEDGERS.APPLICATION_ID%TYPE;
--
--
--+==========================================================================+
--|                                                                          |
--| CALL FND_LOG trace API                                                   |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_extract_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2)
IS
BEGIN
----------------------------------------------------------------------------
-- Following is for FND log.
----------------------------------------------------------------------------
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
             (p_location   => 'xla_cmp_extract_pkg.trace');
END trace;


--+==========================================================================+
--|                                                                          |
--| PRIVATE PROCEDURES AND FUNCTIONS                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

FUNCTION GenerateFromHdrTabs  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
;

FUNCTION GenerateHdrWhereClause  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
--
, p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
;
--
FUNCTION GenerateFromLineTabs  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
;
--
--
FUNCTION GenerateLineWhereClause  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
;

--+==========================================================================+
--|                                                                          |
--| CALL THE EXTRACT INTEGRITY CHECKER                                       |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE PROCEDURE                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE InitSourceArrays  (
  p_array_evt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_application_id         IN OUT NOCOPY xla_cmp_source_pkg.t_array_Num
, p_array_source_code            IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_source_type_code       IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
, p_array_datatype_code          IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
, p_array_translated_flag        IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
)
IS
--
Jdx                            BINARY_INTEGER;
l_array_evt_source_index       xla_cmp_source_pkg.t_array_ByInt;
l_array_application_id         xla_cmp_source_pkg.t_array_Num;
l_array_source_code            xla_cmp_source_pkg.t_array_VL30;
l_array_source_type_code       xla_cmp_source_pkg.t_array_VL1;
l_array_datatype_code          xla_cmp_source_pkg.t_array_VL1;
l_array_translated_flag        xla_cmp_source_pkg.t_array_VL1;
l_log_module                   VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InitSourceArrays';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InitSourceArrays'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- init PL/SQL arrays
--
Jdx := 1;
--
FOR Idx IN p_array_evt_source_index.FIRST .. p_array_evt_source_index.LAST LOOP

   IF p_array_evt_source_index.EXISTS(Idx) AND
      p_array_evt_source_index(Idx) IS NOT NULL THEN
      --
         --
         l_array_evt_source_index(Jdx) := Idx;
         l_array_source_code(Jdx)      := p_array_source_code(p_array_evt_source_index(Idx));
         l_array_source_type_code(Jdx) := p_array_source_type_code(p_array_evt_source_index(Idx));
         l_array_application_id(Jdx)   := p_array_application_id(p_array_evt_source_index(Idx));
         l_array_datatype_code(Jdx)    := p_array_datatype_code(p_array_evt_source_index(Idx));
         l_array_translated_flag(Jdx)  := p_array_translated_flag(p_array_evt_source_index(Idx));
         --
         Jdx := Jdx + 1;
         --
   END IF;

END LOOP
;
--
p_array_evt_source_index       := l_array_evt_source_index;
p_array_application_id         := l_array_application_id;
p_array_source_code            := l_array_source_code;
p_array_source_type_code       := l_array_source_type_code;
p_array_datatype_code          := l_array_datatype_code;
p_array_translated_flag        := l_array_translated_flag;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of InitSourceArrays'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
    RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.InitSourceArrays ');
END InitSourceArrays;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE PROCEDURE                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE FlushGtTable (
  p_application_id               IN  NUMBER
, p_entity_code                  IN  VARCHAR2
, p_event_class_code             IN  VARCHAR2
)
IS
l_statement      VARCHAR2(4000);
l_log_module     VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.FlushGtTable';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of FlushGtTable'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

   trace(p_msg      => 'SQL - DELETE FROM xla_evt_class_sources_gt '
        ,p_level    => C_LEVEL_STATEMENT
        ,p_module   => l_log_module);
   trace(p_msg      => 'p_application_id = ' ||p_application_id
       ,p_level    => C_LEVEL_STATEMENT
       ,p_module   => l_log_module);

   trace(p_msg      => 'p_entity_code = ' ||p_entity_code
       ,p_level    => C_LEVEL_STATEMENT
       ,p_module   => l_log_module);

   trace(p_msg      => 'p_event_class_code  = ' ||p_event_class_code
       ,p_level    => C_LEVEL_STATEMENT
       ,p_module   => l_log_module);

END IF;

DELETE FROM xla_evt_class_sources_gt gt
WHERE gt.application_id      = p_application_id
  AND gt.entity_code         = p_entity_code
  AND gt.event_class_code    = p_event_class_code
  ;
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => '# rows deleted from xla_evt_class_sources_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of FlushGtTable'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
END FlushGtTable;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE PROCEDURE                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE InsertSourcesIntoGtTable  (
  p_application_id               IN  NUMBER
, p_entity_code                  IN  VARCHAR2
, p_event_class_code             IN  VARCHAR2
, p_array_evt_source_index       IN xla_cmp_source_pkg.t_array_ByInt
, p_array_application_id         IN xla_cmp_source_pkg.t_array_Num
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_type_code       IN xla_cmp_source_pkg.t_array_VL1
, p_array_datatype_code          IN xla_cmp_source_pkg.t_array_VL1
, p_array_translated_flag        IN xla_cmp_source_pkg.t_array_VL1
)
IS
--
l_log_module                   VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertSourcesIntoGtTable';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertSourcesIntoGtTable'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- flush temporary table
--
   FlushGtTable(
      p_application_id
    , p_entity_code
    , p_event_class_code
   );
--
-- insert sources in xla_evt_class_sources_gt temporary table
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL- Insert Into xla_evt_class_sources_gt '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

 --
 FORALL Idx IN p_array_evt_source_index.FIRST .. p_array_evt_source_index.LAST

 INSERT INTO xla_evt_class_sources_gt
     (
       application_id
     , entity_code
     , event_class_code
     , source_application_id
     , source_code
     , source_hash_id
     , source_datatype_code
     , source_level_code
     )

    SELECT
       p_application_id
     , p_entity_code
     , p_event_class_code
     , xes.source_application_id
     , p_array_source_code(Idx)
     , p_array_evt_source_index(Idx)

     , CASE p_array_datatype_code(Idx)

         WHEN 'C' THEN C_VARCHAR2

         WHEN 'D' THEN C_DATE

         ELSE C_NUMBER

       END

     , CASE xes.level_code

        WHEN 'C' THEN C_BC_LINE
-- Added an extra decode for language column (Dimple)
        WHEN 'L' THEN DECODE(p_array_source_code(Idx),'LANGUAGE',C_MLS_LINE,
                             DECODE(p_array_translated_flag(Idx)
                             ,'Y',C_MLS_LINE
                             ,C_LINE))

        WHEN 'H' THEN DECODE(p_array_source_code(Idx),'LANGUAGE',C_MLS_HEADER,
                             DECODE(p_array_translated_flag(Idx)
                             ,'Y', C_MLS_HEADER
                             , C_HEADER))

       END
    --
     FROM xla_event_sources   xes
   WHERE  xes.application_id        = p_application_id
     AND  xes.entity_code           = p_entity_code
     AND  xes.event_class_code      = p_event_class_code
     AND  xes.source_code           = p_array_source_code(Idx)
     AND  xes.source_type_code      = p_array_source_type_code(Idx)
     AND  xes.source_application_id = p_array_application_id(Idx)
     AND  xes.source_type_code      = 'S'
     AND  xes.active_flag           = 'Y'
-- added not exists to prevent inserting sources that are already there in GT table (Dimple)
     AND not exists (SELECT 'x'
                       FROM xla_evt_class_sources_gt gt
                      WHERE gt.application_id        = xes.application_id
                        AND gt.entity_code           = xes.entity_code
                        AND gt.event_class_code      = xes.event_class_code
                        AND gt.source_application_id = xes.source_application_id
                        AND gt.source_code           = xes.source_code)
   ;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => '# rows inserted into xla_evt_class_sources_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of InsertSourcesIntoGtTable'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
    RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.InsertSourcesIntoGtTable ');
END InsertSourcesIntoGtTable;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE PROCEDURE                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE GetSourceLevels  (
  p_application_id               IN  NUMBER
, p_entity_code                  IN  VARCHAR2
, p_event_class_code             IN  VARCHAR2
, p_array_evt_source_Level       OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
)
IS
--
l_array_evt_source_index        xla_cmp_source_pkg.t_array_ByInt;
l_array_evt_source_Level        xla_cmp_source_pkg.t_array_VL1;
--
l_log_module                    VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSourceLevels';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetSourceLevels'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL- SELECT from xla_evt_class_sources_gt '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

--
SELECT  gt.source_hash_id
      , CASE gt.source_level_code
            WHEN  C_HEADER     THEN 'H'
            WHEN  C_MLS_HEADER THEN 'H'
            ELSE 'L'
        END
BULK COLLECT INTO
        l_array_evt_source_index
      , l_array_evt_source_Level
  FROM xla_evt_class_sources_gt gt
WHERE gt.application_id      = p_application_id
  AND gt.entity_code         = p_entity_code
  AND gt.event_class_code    = p_event_class_code
;
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => '# rows inserted into xla_evt_class_sources_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

IF l_array_evt_source_index.COUNT > 0 THEN
--
 FOR Idx IN l_array_evt_source_index.FIRST .. l_array_evt_source_index.LAST LOOP
 --
   IF l_array_evt_source_index.EXISTS(Idx) AND
      l_array_evt_source_index(Idx) IS NOT NULL
   THEN
      --
      p_array_evt_source_Level(l_array_evt_source_index(Idx)) := l_array_evt_source_Level(Idx);
      --
   END IF;
 --
 END LOOP;
END IF;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetSourceLevels'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
    RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GetSourceLevels ');
END GetSourceLevels;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE PROCEDURE                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE GetExtractObjects  (
  p_application_id               IN  NUMBER
, p_entity_code                  IN  VARCHAR2
, p_event_class_code             IN  VARCHAR2
, p_array_object_name            OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_parent_object_index    OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_object_type            OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_object_hash_id         OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
, p_array_ref_obj_flag           OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         OUT NOCOPY xla_cmp_Source_pkg.t_array_VL2000
)
IS
--
l_array_object_name            xla_cmp_source_pkg.t_array_VL30;
l_array_parent_name            xla_cmp_source_pkg.t_array_VL30;
l_array_object_type            xla_cmp_source_pkg.t_array_VL30;
l_array_object_hash_id         xla_cmp_source_pkg.t_array_VL30;
l_array_populated_flag         xla_cmp_source_pkg.t_array_VL1;
--
l_array_ref_obj_flag           xla_cmp_source_pkg.t_array_VL1;
l_array_join_condition         xla_cmp_source_pkg.t_array_VL2000;
l_array_parent_object_index    xla_cmp_source_pkg.t_array_ByInt;
TYPE t_array_by_VL30 IS        TABLE OF NUMBER INDEX BY VARCHAR2(30);
l_array_table_index            t_array_by_VL30;
--
CURSOR table_cur(   p_application_id       NUMBER
                  , p_entity_code          VARCHAR2
                  , p_event_class_code     VARCHAR2
                 )
IS
SELECT
       gt.extract_object_name
     , gt.extract_object_type_code
     , nvl(gt.always_populated_flag,C_NOT_ALWAYS_POPULATED)
     , nvl(gt.reference_object_flag,C_NOT_REF_OBJ)
     , gt.join_condition
     , nvl(ro.linked_to_ref_obj_name, ro.object_name)
FROM xla_evt_class_sources_gt gt
     , xla_reference_objects ro
WHERE gt.application_id      = p_application_id
  AND gt.entity_code         = p_entity_code
  AND gt.event_class_code    = p_event_class_code
  AND ro.application_id        (+)= p_application_id
  AND ro.entity_code           (+)= p_entity_code
  AND ro.event_class_code      (+)= p_event_class_code
  AND ro.reference_object_name (+)= gt.extract_object_name
UNION
SELECT ro1.reference_object_name
         , gt.extract_object_type_code
         , nvl(ro1.always_populated_flag,C_NOT_ALWAYS_POPULATED)
         , 'Y'
         , ro1.join_condition
         , nvl(ro1.linked_to_ref_obj_name, ro1.object_name)
FROM xla_evt_class_sources_gt gt
         , xla_reference_objects ro
         , xla_reference_objects ro1
WHERE gt.application_id      = p_application_id
  AND gt.entity_code         = p_entity_code
  AND gt.event_class_code    = p_event_class_code
  AND ro.application_id =     p_application_id
  AND ro.entity_code         = p_entity_code
  AND ro.event_class_code    = p_event_class_code
  AND ro.reference_object_name = gt.extract_object_name
  AND ro1.application_id =     p_application_id
  AND ro1.entity_code         = p_entity_code
  AND ro1.event_class_code    = p_event_class_code
  AND ro1.reference_object_name = ro.linked_to_ref_obj_name
UNION
SELECT eo.object_name
     ,gt.extract_object_type_code
     ,nvl(eo.always_populated_flag,C_NOT_ALWAYS_POPULATED)
     ,'N'
     ,null
     ,null
FROM xla_evt_class_sources_gt gt
     , xla_reference_objects ro
     , xla_extract_objects eo
WHERE  gt.application_id      = p_application_id
  AND gt.entity_code         = p_entity_code
  AND gt.event_class_code    = p_event_class_code
  AND ro.application_id =     p_application_id
  AND ro.entity_code         = p_entity_code
  AND ro.event_class_code    = p_event_class_code
  AND ro.reference_object_name = gt.extract_object_name
  AND eo.application_id =     p_application_id
  AND eo.entity_code         = p_entity_code
  AND eo.event_class_code    = p_event_class_code
  AND eo.object_name      = ro.object_name
;
--
l_log_module                   VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetExtractObjects';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetExtractObjects'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
OPEN table_cur(   p_application_id   => p_application_id
                , p_entity_code      => p_entity_code
                , p_event_class_code => p_event_class_code
               );
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Fetch xla_evt_class_sources_gt '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--

FETCH table_cur BULK COLLECT INTO  l_array_object_name
                                 , l_array_object_type
                                 , l_array_populated_flag
                                 , l_array_ref_obj_flag
                                 , l_array_join_condition
                                 , l_array_parent_name
                                 ;
--

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => '# rows selected from xla_evt_class_sources_gt = '||table_cur%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
CLOSE table_cur;


IF l_array_object_name.COUNT > 0 THEN

  FOR Idx IN l_array_object_name.FIRST .. l_array_object_name.LAST LOOP

    IF l_array_object_name.EXISTS(Idx) AND
       l_array_object_name(Idx) IS NOT NULL AND
       l_array_object_type(Idx) IS NOT NULL THEN

      l_array_table_index(l_array_object_name(Idx)) := Idx;
      CASE l_array_object_type(Idx)

        WHEN C_HEADER      THEN l_array_object_hash_id(Idx)    := CONCAT('h',Idx);

        WHEN C_MLS_HEADER  THEN l_array_object_hash_id(Idx)   := CONCAT('hmls',Idx);

        WHEN C_LINE        THEN l_array_object_hash_id(Idx)   := CONCAT('l',Idx);

        WHEN C_BC_LINE     THEN l_array_object_hash_id(Idx)   := CONCAT('lbc',Idx);

        WHEN C_MLS_LINE    THEN l_array_object_hash_id(Idx)   := CONCAT('lmls',Idx);

        ELSE
          null;
      END CASE;

    END IF;

  END LOOP;

  FOR Idx IN l_array_object_name.FIRST .. l_array_object_name.LAST LOOP
   IF l_array_parent_name.EXISTS(Idx) AND
       l_array_parent_name(Idx) IS NOT NULL AND
       l_array_table_index.EXISTS(l_array_parent_name(Idx)) AND
       l_array_table_index(l_array_parent_name(Idx)) IS NOT NULL THEN
     l_array_parent_object_index(Idx):= l_array_table_index(l_array_parent_name(Idx));
   END IF;

  END LOOP;

END IF;
--
p_array_object_name      := l_array_object_name;
p_array_object_type      := l_array_object_type;
p_array_object_hash_id   := l_array_object_hash_id;
p_array_populated_flag   := l_array_populated_flag;
p_array_ref_obj_flag     := l_array_ref_obj_flag;
p_array_join_condition   := l_array_join_condition;
p_array_parent_object_index     := l_array_parent_object_index;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetExtractObjects'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
    RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GetExtractObjects ');
END GetExtractObjects;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE PROCEDURE                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION  GetObjectIndex (
 p_object_name                 IN VARCHAR2
,p_array_object_name           IN xla_cmp_source_pkg.t_array_VL30
)
RETURN BINARY_INTEGER
IS
objectIndex                    BINARY_INTEGER:=NULL;
l_log_module                   VARCHAR2(240);
BEGIN
--
IF p_array_object_name.COUNT > 0 THEN
   --
  FOR Idx IN p_array_object_name.FIRST .. p_array_object_name.LAST LOOP
    --
    IF p_array_object_name.EXISTS(Idx) AND
       p_array_object_name(Idx) = p_object_name THEN
            --
            objectIndex := Idx;
            --
    END IF;
         --
   END LOOP;
      --
END IF;
--
RETURN objectIndex;
END GetObjectIndex;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE PROCEDURE                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE GetSourcesWithExtractObject  (
  p_application_id               IN  NUMBER
, p_entity_code                  IN  VARCHAR2
, p_event_class_code             IN  VARCHAR2
, p_array_object_name            IN  xla_cmp_source_pkg.t_array_VL30
--
, p_array_h_source_index         OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
--
, p_array_h_mls_source_index     OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_source_index         OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
--
)
IS
--
--
l_array_source_hash_id           xla_cmp_source_pkg.t_array_ByInt;
l_array_object_name              xla_cmp_source_pkg.t_array_VL30;
l_array_object_type              xla_cmp_source_pkg.t_array_VL30;
l_log_module                     VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetSourcesWithExtractObject';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetSourcesWithExtractObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL- SELECT from xla_evt_class_sources_gt'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
SELECT  gt.source_hash_id
      , gt.extract_object_name
      , gt.extract_object_type_code

BULK COLLECT INTO
        l_array_source_hash_id
      , l_array_object_name
      , l_array_object_type

  FROM xla_evt_class_sources_gt gt
WHERE gt.application_id      = p_application_id
  AND gt.entity_code         = p_entity_code
  AND gt.event_class_code    = p_event_class_code
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => '# rows selected from xla_evt_class_sources_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

--
IF l_array_source_hash_id.COUNT > 0 THEN

  FOR Idx IN l_array_source_hash_id.FIRST .. l_array_source_hash_id.LAST LOOP

    CASE l_array_object_type(Idx)

          WHEN C_HEADER      THEN

             p_array_h_source_index(l_array_source_hash_id(Idx)) := l_array_source_hash_id(Idx);
             p_array_h_table_index(l_array_source_hash_id(Idx))  := GetObjectIndex (
                                                                        l_array_object_name(Idx)
                                                                      , p_array_object_name
                                                                      );
          WHEN C_MLS_HEADER  THEN

             p_array_h_mls_source_index(l_array_source_hash_id(Idx)) := l_array_source_hash_id(Idx);
             p_array_h_mls_table_index(l_array_source_hash_id(Idx))  := GetObjectIndex (
                                                                        l_array_object_name(Idx)
                                                                      , p_array_object_name
                                                                      );

          WHEN C_LINE        THEN

             p_array_l_source_index(l_array_source_hash_id(Idx)) := l_array_source_hash_id(Idx);
             p_array_l_table_index(l_array_source_hash_id(Idx))  := GetObjectIndex (
                                                                        l_array_object_name(Idx)
                                                                      , p_array_object_name
                                                                      );


          WHEN C_MLS_LINE    THEN

             p_array_l_mls_source_index(l_array_source_hash_id(Idx)) := l_array_source_hash_id(Idx);
             p_array_l_mls_table_index(l_array_source_hash_id(Idx))  := GetObjectIndex (
                                                                        l_array_object_name(Idx)
                                                                      , p_array_object_name
                                                                      );

          ELSE
            null;
    END CASE;

  END LOOP;

END IF;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetSourcesWithExtractObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
    RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GetSourcesWithExtractObject ');
END GetSourcesWithExtractObject;

--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  FUNCTION                                                        |
--|                                                                          |
--|      Add Oracle Join Operator (+) to join conditions                     |
--|                                                                          |
--+==========================================================================+
--
FUNCTION  AddOuterJoinOps (
   p_join_condition IN VARCHAR2
  ,p_ref_obj_name   IN VARCHAR2)
RETURN VARCHAR2
IS

  l_out_where_clause      VARCHAR2(2000);
  l_in_str_lower          VARCHAR2(2000);
  l_multiple_flag         VARCHAR2(1);

  l_col_start_pos         PLS_INTEGER;
  l_and_pos               PLS_INTEGER;
  l_start_pos             PLS_INTEGER;
  i                       PLS_INTEGER;
  l_array_join_condition  xla_cmp_source_pkg.t_array_VL2000;
  l_relation              VARCHAR2(2);

  l_log_module            VARCHAR2(240);

BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AddOuterJoinOps';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AddOuterJoinOps'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--

l_multiple_flag    := 'N';
l_in_str_lower     := lower(p_join_condition);

--
-- Assign each join condition into l_array_join_condition (i)
-- For example, for the join contion
--      'ap_inv_dist_ext_s.col1 = pa_projects.col1 AND
--       ap_inv_dist_ext_s.col2 = pa_projects.col2'
--
-- l_array_join_condition (1) stores  'ap_inv_dist_ext_s.col1 = pa_projects.col1'
-- l_array_join_condition (2) stores  'ap_inv_dist_ext_s.col2 = pa_projects.col2'
--

--
--  Check if ' and ' is found in the input strings, that is. Then assume that
--  there are multiple join conditions
--
IF INSTRB(l_in_str_lower, ' and ') > 0 THEN

   i               := 1;
   l_and_pos       := 1;
   l_start_pos     := 1; -- Starting Posistion to search ' AND '
   l_multiple_flag := 'Y';


   WHILE l_and_pos > 0 AND i < 20 LOOP  --  i <20 is to avoid inf loop

      l_and_pos := INSTRB(l_in_str_lower, ' and ', l_start_pos);

      --
      --  ' AND ' is found. l_and_pos is 0 if ' and ' is not found.
      --
      IF l_and_pos <> 0 THEN
      -- bug6487259 added - l_start_pos + 1
         l_array_join_condition(i) := SUBSTRB(p_join_condition,l_start_pos, l_and_pos - l_start_pos + 1);

         l_start_pos := l_and_pos + 5;  -- Move starting posting for the next ' AND '

      --
      --  ' AND ' is not found.  Assume this is the last join condition
      --
      ELSE -- the last join condition
      -- bug6487259 added - l_start_pos + 1
         l_array_join_condition(i) := SUBSTRB(p_join_condition,l_start_pos,lengthb(p_join_condition) - l_start_pos + 1);

      END IF;

      -- Debug
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

         trace
            (p_msg      => 'Before adding outer join operators - '  ||
                           'l_array_join_condition(' || i || ') = ' ||
                            l_array_join_condition (i)
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);

      END IF;

      i := i+1;

   END LOOP;

ELSE -- Single join condition

   l_multiple_flag := 'N';

END IF;


--
-- Add (+) to the join conditions
--

IF l_multiple_flag = 'N' THEN

   --
   -- Add the outer join operator to reference objects
   -- Make no change to trx object conditions
   --
   IF INSTRB(LOWER(p_join_condition),LOWER(p_ref_obj_name)||'.') > 0 THEN

      --
      --  Evaluate two char relations '>=' ,'<>' first.
      --
      IF INSTRB(p_join_condition,'>=') > 0    THEN
         l_relation := '>=';
      ELSIF INSTRB(p_join_condition,'=<') > 0 THEN
         l_relation := '=<';
      ELSIF INSTRB(p_join_condition,'<>') > 0 THEN
         l_relation := '<>';
      ELSIF INSTRB(p_join_condition,'!=') > 0 THEN
         l_relation := '!=';
      ELSIF INSTRB(p_join_condition,'>')  > 0 THEN
         l_relation := '>';
      ELSIF INSTRB(p_join_condition,'<')  > 0 THEN
         l_relation := '<';
      ELSIF INSTRB(p_join_condition,'=')  > 0 THEN
         l_relation := '=';
      END IF;

      --
      -- Reference Object is located right to the equal sign
      -- e.g. ap_inv_dist_ext_s.project_id = pa_projects.project_id
      --
      IF INSTRB(l_in_str_lower,LOWER(p_ref_obj_name)) > INSTRB(l_in_str_lower,l_relation)
      THEN
         l_out_where_clause := p_join_condition || ' (+) ';

      --
      -- Reference Object is located left to the equal sign
      -- e.g. pa_projects.project_id = ap_inv_dist_ext_s.project_id
      --
      ELSE
         l_out_where_clause := REPLACE(p_join_condition, l_relation, ' (+) ' || l_relation);
      END IF;

   END IF;

ELSE  -- l_multipel_flag = 'Y'

   IF l_array_join_condition.COUNT >= 1 THEN
      FOR i IN l_array_join_condition.FIRST .. l_array_join_condition.LAST LOOP

         --
         -- Add the outer join operator to reference objects
         --
         IF INSTRB(LOWER(l_array_join_condition(i)),LOWER(p_ref_obj_name)||'.') > 0 THEN

            --
            --  Evaluate two char relations '>=' ,'<>' first.
            --
            IF INSTRB(l_array_join_condition(i),'>=') > 0    THEN
               l_relation := '>=';
            ELSIF INSTRB(l_array_join_condition(i),'=<') > 0 THEN
               l_relation := '=<';
            ELSIF INSTRB(l_array_join_condition(i),'<>') > 0 THEN
               l_relation := '<>';
            ELSIF INSTRB(l_array_join_condition(i),'!=') > 0 THEN
               l_relation := '!=';
            ELSIF INSTRB(l_array_join_condition(i),'>')  > 0 THEN
               l_relation := '>';
            ELSIF INSTRB(l_array_join_condition(i),'<')  > 0 THEN
               l_relation := '<';
            ELSIF INSTRB(l_array_join_condition(i),'=')  > 0 THEN
               l_relation := '=';
            END IF;

            --
            -- Reference Object is located right to the relation '=', '>', or '<'
            -- e.g. ap_inv_dist_ext_s.project_id = pa_projects.project_id
            -- e.g. 0 < pa_projects.project_id
            --
            IF INSTRB(LOWER(l_array_join_condition(i)),LOWER(p_ref_obj_name)) >
               INSTRB(LOWER(l_array_join_condition(i)),l_relation)
            THEN
               l_array_join_condition(i) := l_array_join_condition(i) || ' (+) ';

            --
            -- Reference Object is located left to the relation '=', '>', or '<'
            -- e.g. pa_projects.project_id = ap_inv_dist_ext_s.project_id
            -- e.g. pa_projects.project_id > 0
            ELSE
               l_array_join_condition(i) :=
                     REPLACE(l_array_join_condition(i),l_relation,' (+) ' || l_relation);
            END IF;

         END IF;

         l_out_where_clause := l_out_where_clause || l_array_join_condition(i);

         IF i < l_array_join_condition.COUNT THEN
            l_out_where_clause := l_out_where_clause || ' AND ';
         END IF;

         -- Debug
         IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

            trace
               (p_msg      => 'After adding outer join operators - '   ||
                              'l_array_join_condition(' || i || ') = ' ||
                               l_array_join_condition (i)
               ,p_level    => C_LEVEL_PROCEDURE
               ,p_module   => l_log_module);

         END IF;

      END LOOP;
   END IF;
END IF;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of AddOuterJoinOps'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

  RETURN NVL(l_out_where_clause,p_join_condition);

END AddOuterJoinOps;


--
--+==========================================================================+
--|                                                                          |
--| PUBLIC FUNCTION                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
FUNCTION CallExtractIntegrityChecker  (
  p_application_id               IN  NUMBER
, p_entity_code                  IN  VARCHAR2
, p_event_class_code             IN  VARCHAR2
, p_amb_context_code             IN  VARCHAR2
, p_product_rule_type_code       IN  VARCHAR2
, p_product_rule_code            IN  VARCHAR2
--
, p_array_evt_source_index       IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_application_id         IN xla_cmp_source_pkg.t_array_Num
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_type_code       IN xla_cmp_source_pkg.t_array_VL1
, p_array_datatype_code          IN xla_cmp_source_pkg.t_array_VL1
, p_array_translated_flag        IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_evt_source_Level       OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
--
, p_array_object_name            OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_parent_object_index    OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_object_type            OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_object_hash_id         OUT NOCOPY xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           OUT NOCOPY xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         OUT NOCOPY xla_cmp_source_pkg.t_array_VL2000
--
, p_array_h_source_index         OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_source_index     OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_source_index         OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_source_index     OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
)
RETURN BOOLEAN
IS
--
l_IsExtractValid               BOOLEAN:=TRUE;
--
l_array_evt_source_index       xla_cmp_source_pkg.t_array_ByInt;
l_array_application_id         xla_cmp_source_pkg.t_array_Num;
l_array_source_code            xla_cmp_source_pkg.t_array_VL30;
l_array_source_type_code       xla_cmp_source_pkg.t_array_VL1;
l_array_datatype_code          xla_cmp_source_pkg.t_array_VL1;
l_array_translated_flag        xla_cmp_source_pkg.t_array_VL1;
--
l_array_evt_source_Level       xla_cmp_source_pkg.t_array_VL1;
--
l_array_object_name            xla_cmp_source_pkg.t_array_VL30;
l_array_parent_object_index    xla_cmp_source_pkg.t_array_ByInt;
l_array_object_type            xla_cmp_source_pkg.t_array_VL30;
l_array_object_hash_id         xla_cmp_source_pkg.t_array_VL30;
l_array_populated_flag         xla_cmp_source_pkg.t_array_VL1;
--
l_array_ref_obj_flag           xla_cmp_source_pkg.t_array_VL1;
l_array_join_condition         xla_cmp_source_pkg.t_array_VL2000;
--
l_array_h_source_index         xla_cmp_source_pkg.t_array_ByInt;
l_array_h_table_index          xla_cmp_source_pkg.t_array_ByInt;
l_array_h_mls_source_index     xla_cmp_source_pkg.t_array_ByInt;
l_array_h_mls_table_index      xla_cmp_source_pkg.t_array_ByInt;
l_array_l_source_index         xla_cmp_source_pkg.t_array_ByInt;
l_array_l_table_index          xla_cmp_source_pkg.t_array_ByInt;
l_array_l_mls_source_index     xla_cmp_source_pkg.t_array_ByInt;
l_array_l_mls_table_index      xla_cmp_source_pkg.t_array_ByInt;
l_log_module                   VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CallExtractIntegrityChecker';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of CallExtractIntegrityChecker'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- Set application ID

   g_application_id := p_application_id;
--
-- init PL/SQL arrays
--
l_array_evt_source_index    := p_array_evt_source_index;
l_array_application_id      := p_array_application_id ;
l_array_source_code         := p_array_source_code ;
l_array_source_type_code    := p_array_source_type_code;
l_array_datatype_code       := p_array_datatype_code;
l_array_translated_flag     := p_array_translated_flag;
--
IF p_array_evt_source_index.COUNT > 0 THEN
--
--
    InitSourceArrays  (
      l_array_evt_source_index
    , l_array_application_id
    , l_array_source_code
    , l_array_source_type_code
    , l_array_datatype_code
    , l_array_translated_flag
    );

--
-- Insert sources in xla_evt_class_sources_gt GT table
--
    InsertSourcesIntoGtTable  (
      p_application_id
    , p_entity_code
    , p_event_class_code
    , l_array_evt_source_index
    , l_array_application_id
    , l_array_source_code
    , l_array_source_type_code
    , l_array_datatype_code
    , l_array_translated_flag
    );
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
          (p_msg      => '-> CALL xla_extract_integrity_pkg.Validate_sources_with_extract API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- Call Extract Integrity Checker
--
l_IsExtractValid := xla_extract_integrity_pkg.Validate_sources_with_extract
          (p_application_id
          ,p_entity_code
          ,p_event_class_code
          ,p_amb_context_code
          ,p_product_rule_type_code
          ,p_product_rule_code
          );
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   IF l_IsExtractValid THEN
      trace
         (p_msg      => 'l_IsExtractValid = TRUE'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   ELSE
      trace
         (p_msg      => 'l_IsExtractValid = FALSE'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;
END IF;

IF l_IsExtractValid  THEN
--
-- Get source levels
--
   GetSourceLevels(
      p_application_id
    , p_entity_code
    , p_event_class_code
    , l_array_evt_source_Level
    );
--
-- Get Extract Objects
--
  GetExtractObjects(
    p_application_id
  , p_entity_code
  , p_event_class_code
  , l_array_object_name
  , l_array_parent_object_index
  , l_array_object_type
  , l_array_object_hash_id
  , l_array_populated_flag
  --
  , l_array_ref_obj_flag
  , l_array_join_condition
  );
--
-- Get Sources with Extract objects
--
   GetSourcesWithExtractObject(
       p_application_id
     , p_entity_code
     , p_event_class_code
     , l_array_object_name
     --
     , l_array_h_source_index
     , l_array_h_table_index
     --
     , l_array_h_mls_source_index
     , l_array_h_mls_table_index
     --
     , l_array_l_source_index
     , l_array_l_table_index
     --
     , l_array_l_mls_source_index
     , l_array_l_mls_table_index
   );

END IF;
--
--
p_array_evt_source_Level       := l_array_evt_source_Level;
--
p_array_object_name            := l_array_object_name;
p_array_parent_object_index    := l_array_parent_object_index;
p_array_object_type            := l_array_object_type;
p_array_object_hash_id         := l_array_object_hash_id;
p_array_populated_flag         := l_array_populated_flag;
--
p_array_ref_obj_flag           := l_array_ref_obj_flag;
p_array_join_condition         := l_array_join_condition;
--
p_array_h_source_index         := l_array_h_source_index;
p_array_h_table_index          := l_array_h_table_index;
p_array_h_mls_source_index     := l_array_h_mls_source_index;
p_array_h_mls_table_index      := l_array_h_mls_table_index;
p_array_l_source_index         := l_array_l_source_index;
p_array_l_table_index          := l_array_l_table_index;
p_array_l_mls_source_index     := l_array_l_mls_source_index;
p_array_l_mls_table_index      := l_array_l_mls_table_index;
--
--
END IF;
--

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   IF l_IsExtractValid THEN
      trace
         (p_msg      => 'return value (l_IsExtractValid) = TRUE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   ELSE
      trace
         (p_msg      => 'return value (l_IsExtractValid) = FALSE'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   trace
      (p_msg      => 'END of CallExtractIntegrityChecker'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

RETURN l_IsExtractValid;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   RETURN FALSE;
WHEN OTHERS    THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_extract_pkg.CallExtractIntegrityChecker ');
END CallExtractIntegrityChecker;
--
--
--+==========================================================================+
--|                                                                          |
--| GENERATION of Accounting Event Extract                                   |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|   Generate the declaration of the sturcture for the line variables       |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateLineStructure  (
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
)
RETURN VARCHAR2
IS
--

C_LINE_STRUCTURE        CONSTANT VARCHAR2(2000):=
'TYPE t_array_source_$Index$ IS TABLE OF $table$.$column$%TYPE INDEX BY BINARY_INTEGER;';
--
l_LineTypes                     VARCHAR2(32000);
l_LineType                      VARCHAR2(2000);
l_log_module                    VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateLineStructure';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateLineStructure'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_LineTypes:= NULL;

IF p_array_l_source_index. COUNT > 0 THEN
--
FOR Idx IN p_array_l_source_index.FIRST .. p_array_l_source_index.LAST LOOP
--
  IF p_array_l_source_index.EXISTS(Idx)  THEN
  --
      l_LineType := C_LINE_STRUCTURE;
      --
      l_LineType := REPLACE(l_LineType,'$Index$' , Idx);
      l_LineType := REPLACE(l_LineType,'$table$' ,
                           p_array_table_name(p_array_l_table_index(Idx)));
      l_LineType := REPLACE(l_LineType,'$column$', p_array_source_code(Idx));
      --
      l_LineTypes := l_LineTypes ||g_chr_newline || l_LineType ;
  --
  END IF;
--
END LOOP;
--
END IF;
--
-- structure of mls line sources
--
IF p_array_l_mls_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_l_mls_source_index.FIRST .. p_array_l_mls_source_index.LAST LOOP
--
  IF p_array_l_mls_source_index.EXISTS(Idx)  THEN
  --
      l_LineType := C_LINE_STRUCTURE;
      --
      l_LineType := REPLACE(l_LineType,'$Index$' , Idx);
      l_LineType := REPLACE(l_LineType,'$table$' ,
                            p_array_table_name(p_array_l_mls_table_index(Idx)));
      l_LineType := REPLACE(l_LineType,'$column$', p_array_source_code(Idx));
      --
      l_LineTypes := l_LineTypes || g_chr_newline || l_LineType ;
  --
  END IF;
--
END LOOP;
--
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateLineStructure'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_LineTypes;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateLineStructure ');
END GenerateLineStructure;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|    Generate the Declaration of header variables                          |
--|                                                                          |
--+==========================================================================+
--

FUNCTION GenerateHdrVariables
       (p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num)
RETURN VARCHAR2 IS

C_HEADER_VAR     CONSTANT VARCHAR2(2000) :='l_array_source_$Index$              t_array_source_$Index$;';
C_LOOKUP_VAR     CONSTANT VARCHAR2(100)  :='l_array_source_$Index$_meaning      t_array_lookup_meaning;';

l_HdrVariables              VARCHAR2(32000);
l_one_var                   VARCHAR2(2000);
l_log_module                VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateHdrVariables';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateHdrVariables'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   --
   -- declare the standard header variables
   --
   l_one_var       :=  NULL;
   l_HdrVariables  :=  l_one_var ;

   IF p_array_h_source_index.COUNT > 0 THEN
      FOR Idx IN p_array_h_source_index.FIRST .. p_array_h_source_index.LAST LOOP
         IF p_array_h_source_index.EXISTS(Idx)  THEN
            l_one_var       := C_HEADER_VAR;

            IF p_array_lookup_type.EXISTS(Idx) AND
               p_array_lookup_type(Idx) IS NOT NULL AND
               p_array_view_application_id.EXISTS(Idx) AND
               p_array_view_application_id(Idx) IS NOT NULL
            THEN
               l_one_var := l_one_var|| g_chr_newline ||C_LOOKUP_VAR;
            END IF;
            l_one_var       := REPLACE(l_one_var,'$Index$' , Idx);
            l_HdrVariables  := l_HdrVariables || g_chr_newline || l_one_var ;
         END IF;
      END LOOP;
   END IF;

   --
   -- declare the mls line variables
   --
   IF p_array_h_mls_source_index.COUNT > 0 THEN
      FOR Idx IN p_array_h_mls_source_index.FIRST .. p_array_h_mls_source_index.LAST LOOP
         IF p_array_h_mls_source_index.EXISTS(Idx)  THEN
            l_one_var       := C_HEADER_VAR;

            IF p_array_lookup_type.EXISTS(Idx) AND
               p_array_lookup_type(Idx) IS NOT NULL AND
               p_array_view_application_id.EXISTS(Idx) AND
               p_array_view_application_id(Idx) IS NOT NULL
            THEN
               l_one_var := l_one_var|| g_chr_newline ||C_LOOKUP_VAR;
            END IF;
            l_one_var       := REPLACE(l_one_var,'$Index$' , Idx);
            l_HdrVariables  := l_HdrVariables || g_chr_newline || l_one_var ;
         END IF;
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateHdrVariables'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_HdrVariables;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RETURN NULL;
WHEN OTHERS    THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_extract_pkg.GenerateHdrVariables ');
END GenerateHdrVariables;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|   Generate Fetch on header cursor into header variables                  |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateFetchHeaderCursor  (
  p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
l_hdr_variables                         VARCHAR2(32000);
l_one_variable                          VARCHAR2(1000);
--
C_HDR_VAR         CONSTANT              VARCHAR2(1000):='      , l_array_source_$Index$';
C_LOOKUP_VAR      CONSTANT              VARCHAR2(100) :='      , l_array_source_$Index$_meaning';
--
l_log_module                            VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateFetchHeaderCursor';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateFetchHeaderCursor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_hdr_variables := null;
--
IF p_array_h_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_h_source_index.FIRST .. p_array_h_source_index.LAST LOOP

  IF p_array_h_source_index.EXISTS(Idx) THEN
  --
    l_one_variable :=  C_HDR_VAR;
     --
     IF p_array_lookup_type.EXISTS(Idx) AND
        p_array_lookup_type(Idx) IS NOT NULL AND
        p_array_view_application_id.EXISTS(Idx) AND
        p_array_view_application_id(Idx) IS NOT NULL THEN

        l_one_variable := l_one_variable|| g_chr_newline ||C_LOOKUP_VAR;

     END IF;
    --
    l_one_variable :=  REPLACE(l_one_variable,'$Index$' , Idx);
    l_hdr_variables:=  l_hdr_variables || g_chr_newline || l_one_variable;
  --
  END IF;

END LOOP;
--
END IF;
--
IF p_array_h_mls_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_h_mls_source_index.FIRST .. p_array_h_mls_source_index.LAST LOOP
  IF p_array_h_mls_source_index.EXISTS(Idx) THEN
  --
    l_one_variable :=  C_HDR_VAR;
     --
     IF p_array_lookup_type.EXISTS(Idx) AND
        p_array_lookup_type(Idx) IS NOT NULL AND
        p_array_view_application_id.EXISTS(Idx) AND
        p_array_view_application_id(Idx) IS NOT NULL THEN

        l_one_variable := l_one_variable|| g_chr_newline ||C_LOOKUP_VAR;

     END IF;
    --
    l_one_variable :=  REPLACE(l_one_variable,'$Index$' , Idx);
    l_hdr_variables:=  l_hdr_variables || g_chr_newline || l_one_variable;
  --
  END IF;
END LOOP;
--
END IF;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateFetchHeaderCursor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_hdr_variables;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateFetchHeaderCursor ');
END GenerateFetchHeaderCursor;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|    Generate the Declaration of line variables                            |
--|                                                                          |
--+==========================================================================+
--
--
FUNCTION GenerateLineVariables(
  p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
C_LINE_VAR       CONSTANT VARCHAR2(2000) :='l_array_source_$Index$      t_array_source_$Index$;';
C_LOOKUP_VAR     CONSTANT VARCHAR2(100)  :='l_array_source_$Index$_meaning      t_array_lookup_meaning;';
--
l_LineVariables             VARCHAR2(32000);
l_one_var                   VARCHAR2(2000);
--
l_log_module                VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateLineVariables';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateLineVariables'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
-- declare the standard line variables
--
l_one_var       :=  NULL;
l_LineVariables :=  l_one_var ;
--
IF p_array_l_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_l_source_index.FIRST .. p_array_l_source_index.LAST LOOP
--
  IF p_array_l_source_index.EXISTS(Idx)  THEN
  --
      l_one_var       := C_LINE_VAR;
       --
       IF p_array_lookup_type.EXISTS(Idx) AND
          p_array_lookup_type(Idx) IS NOT NULL AND
          p_array_view_application_id.EXISTS(Idx) AND
          p_array_view_application_id(Idx) IS NOT NULL THEN

          l_one_var := l_one_var|| g_chr_newline ||C_LOOKUP_VAR;

       END IF;
       --
      l_one_var       := REPLACE(l_one_var,'$Index$' , Idx);
      l_LineVariables := l_LineVariables || g_chr_newline || l_one_var ;
  --
  END IF;
--
END LOOP;
--
END IF;
--
-- declare the mls line variables
--
IF p_array_l_mls_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_l_mls_source_index.FIRST .. p_array_l_mls_source_index.LAST LOOP
--
  IF p_array_l_mls_source_index.EXISTS(Idx)  THEN
  --
      l_one_var       := C_LINE_VAR;
      --
      IF p_array_lookup_type.EXISTS(Idx) AND
          p_array_lookup_type(Idx) IS NOT NULL AND
          p_array_view_application_id.EXISTS(Idx) AND
          p_array_view_application_id(Idx) IS NOT NULL THEN

          l_one_var := l_one_var|| g_chr_newline ||C_LOOKUP_VAR;

      END IF;
      --
      l_one_var       := REPLACE(l_one_var,'$Index$' , Idx);
      l_LineVariables := l_LineVariables || g_chr_newline || l_one_var ;

  END IF;
--
END LOOP;
--
END IF;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateLineVariables'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_LineVariables;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateLineVariables ');
END GenerateLineVariables;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|   Generate Fetch on Line cursor into header variables                    |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateFetchLineCursor(
  p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
C_LINE_VAR                     CONSTANT VARCHAR2(1000):='      , l_array_source_$Index$';
C_LOOKUP_VAR                   CONSTANT VARCHAR2(1000):='      , l_array_source_$Index$_meaning';
l_LineVariables                VARCHAR2(32000);
l_one_var                      VARCHAR2(1000);
--
l_log_module                   VARCHAR2(240);
--
BEGIN
--
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateFetchLineCursor';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateFetchLineCursor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
l_one_var       := '      , l_array_extract_line_num ';
l_LineVariables := l_one_var ;
--
-- Fetch standard line variables
--
IF p_array_l_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_l_source_index.FIRST .. p_array_l_source_index.LAST LOOP
--
  IF p_array_l_source_index.EXISTS(Idx)  THEN
  --
      l_one_var  :=  C_LINE_VAR ;
      --
      IF p_array_lookup_type.EXISTS(Idx) AND
          p_array_lookup_type(Idx) IS NOT NULL AND
          p_array_view_application_id.EXISTS(Idx) AND
          p_array_view_application_id(Idx) IS NOT NULL THEN

            l_one_var := l_one_var|| g_chr_newline ||C_LOOKUP_VAR;

      END IF;
      --
      l_one_var  := REPLACE(l_one_var,'$Index$' , Idx);
      l_LineVariables := l_LineVariables || g_chr_newline || l_one_var ;
  --
  END IF;
--
END LOOP;
--
END IF;
--
-- Fetch mls line variables
--
IF p_array_l_mls_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_l_mls_source_index.FIRST .. p_array_l_mls_source_index.LAST LOOP
--
  IF p_array_l_mls_source_index.EXISTS(Idx) THEN
  --
      l_one_var  :=  C_LINE_VAR;
      --
      IF p_array_lookup_type.EXISTS(Idx) AND
          p_array_lookup_type(Idx) IS NOT NULL AND
          p_array_view_application_id.EXISTS(Idx) AND
          p_array_view_application_id(Idx) IS NOT NULL THEN

            l_one_var := l_one_var|| g_chr_newline ||C_LOOKUP_VAR;

      END IF;
      --
      l_one_var  := REPLACE(l_one_var,'$Index$' , Idx);
      l_LineVariables := l_LineVariables || g_chr_newline || l_one_var ;
  --
  END IF;
--
END LOOP;
--
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateFetchLineCursor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_LineVariables;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateFetchLineCursor ');
END GenerateFetchLineCursor;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  Procedure                                                       |
--|                                                                          |
--|      Get Different Extract Object used by header or Line Cursor          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE GetUsedExtractObject(
  p_array_table_index        IN xla_cmp_source_pkg.t_array_ByInt
, p_array_parent_table_index IN xla_cmp_source_pkg.t_array_ByInt
, p_array_diff_table_index   IN OUT NOCOPY  xla_cmp_source_pkg.t_array_ByInt
)
IS
--
l_log_module                   VARCHAR2(240);
i BINARY_INTEGER;
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetUsedExtractObject';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetUsedExtractObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF p_array_table_index.COUNT > 0 THEN
--
--
FOR Idx IN p_array_table_index.FIRST .. p_array_table_index.LAST LOOP
   --
     IF p_array_table_index.EXISTS(Idx) THEN
       i := p_array_table_index(Idx);
       --
       p_array_diff_table_index(i) := i;
       --
       WHILE (p_array_parent_table_index.exists(i) and
                    p_array_parent_table_index(i)>0) LOOP
         i := p_array_parent_table_index(i);
         p_array_diff_table_index(i) := i;
       END LOOP;

     END IF;
   --
END LOOP;
--
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetUsedExtractObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GetUsedExtractObject ');
END GetUsedExtractObject;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  FUNCTION                                                        |
--|                                                                          |
--|      Generate the column to extract for the header/line cursor           |
--|      value of ($hdr_sources$ or $line_sources$)                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateExtractColumns(
  p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_index            IN xla_cmp_source_pkg.t_array_ByInt
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
C_COLUMN_TO_EXTRACT  CONSTANT VARCHAR2(1000):= '  , $tab$.$column$    source_$Index$' ;
C_LOOKUP_COLUMN      CONSTANT VARCHAR2(200):=  '  , fvl$Index$.meaning   source_$Index$_meaning' ;
l_ColumnsToExtract   VARCHAR2(32000);
l_OneColumn          VARCHAR2(1000);
--
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateExtractColumns';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateExtractColumns'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_ColumnsToExtract := NULL;
--
IF p_array_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_source_index.FIRST .. p_array_source_index.LAST LOOP
   --
     IF p_array_source_index.EXISTS(Idx)  THEN
     --
        l_OneColumn := C_COLUMN_TO_EXTRACT ;
        --
        IF p_array_lookup_type.EXISTS(Idx) AND
           p_array_lookup_type(Idx) IS NOT NULL AND
           p_array_view_application_id.EXISTS(Idx) AND
           p_array_view_application_id(Idx) IS NOT NULL THEN

            l_OneColumn := l_OneColumn|| g_chr_newline ||C_LOOKUP_COLUMN;

         END IF;
        --
        l_OneColumn := REPLACE(l_OneColumn,'$tab$',
                                 p_array_table_hash(p_array_table_index(Idx))
                              );
                                 --
        l_OneColumn := REPLACE(l_OneColumn,'$column$',
                                 p_array_source_code(p_array_source_index(Idx))
                               );
                                 --
        l_OneColumn := REPLACE(l_OneColumn,'$Index$',Idx);
        --
        --
        l_ColumnsToExtract := l_ColumnsToExtract || g_chr_newline ;
        l_ColumnsToExtract := l_ColumnsToExtract || l_OneColumn   ;
        --
     END IF;
--
END LOOP;
--
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateExtractColumns'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_ColumnsToExtract;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateExtractColumns ');
END GenerateExtractColumns;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  FUNCTION                                                        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateLookupTables(
  p_array_source_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_index            IN xla_cmp_source_pkg.t_array_ByInt
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
C_LOOKUP_TAB         CONSTANT     VARCHAR2(100) :='  , fnd_lookup_values    fvl$Index$';
l_one_table                       VARCHAR2(1000);
l_tables                          VARCHAR2(32000);
--
l_log_module                      VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateLookupTables';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateLookupTables'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_tables := NULL;
--
IF p_array_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_source_index.FIRST .. p_array_source_index.LAST LOOP
   --
     IF p_array_source_index.EXISTS(Idx) AND
        p_array_lookup_type.EXISTS(Idx) AND
        p_array_lookup_type(Idx) IS NOT NULL AND
        p_array_view_application_id.EXISTS(Idx) AND
        p_array_view_application_id(Idx) IS NOT NULL THEN

        l_one_table := C_LOOKUP_TAB;
        l_one_table := REPLACE(l_one_table,'$Index$',Idx);
        --
        l_tables  := l_tables|| g_chr_newline || l_one_table ;
        --
     END IF;
--
END LOOP;
--
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateLookupTables'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_tables;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateLookupTables ');
END GenerateLookupTables;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  FUNCTION                                                        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateLookupClauses(
  p_array_source_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_index            IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
--
C_LOOKUP_CLAUSE      CONSTANT     VARCHAR2(1000):='   AND fvl$Index$.lookup_type(+)         = ''$lookup_type$''
  AND fvl$Index$.lookup_code(+)         = $tab$.$source$
  AND fvl$Index$.view_application_id(+) = $view_application_id$
  AND fvl$Index$.language(+)            = USERENV(''LANG'')
  '
;
l_one_clause                     VARCHAR2(1000);
l_clauses                        VARCHAR2(32000);
--
l_log_module                     VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateLookupClauses';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateLookupClauses'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_clauses  := NULL;
--
IF p_array_source_index.COUNT > 0 THEN
--
FOR Idx IN p_array_source_index.FIRST .. p_array_source_index.LAST LOOP
   --

     IF p_array_source_index.EXISTS(Idx) AND
        p_array_lookup_type.EXISTS(Idx)  AND
        p_array_lookup_type(Idx) IS NOT NULL AND
        p_array_view_application_id.EXISTS(Idx) AND
        p_array_view_application_id(Idx) IS NOT NULL

      THEN

        l_one_clause := C_LOOKUP_CLAUSE;
        l_one_clause := REPLACE(l_one_clause,'$Index$',Idx);
        l_one_clause := REPLACE(l_one_clause,'$lookup_type$',p_array_lookup_type(Idx));
        l_one_clause := REPLACE(l_one_clause,'$view_application_id$',p_array_view_application_id(Idx));
        l_one_clause := REPLACE(l_one_clause,'$source$',p_array_source_code(Idx));
        l_one_clause := REPLACE(l_one_clause,'$tab$',p_array_table_hash(p_array_table_index(Idx)));
        --
        l_clauses  := l_clauses||  l_one_clause ;
        --
     END IF;
--
END LOOP;
--
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateLookupClauses'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_clauses;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateLookupClauses ');
END GenerateLookupClauses;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  Procedure                                                       |
--|                                                                          |
--|      Get Different Extract Object used by header or Line Cursor          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GetAnAlwaysPopulatedObject(
  p_array_table_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_populated_flag      IN xla_cmp_source_pkg.t_array_VL1
, p_array_ref_obj_flag        IN xla_cmp_source_pkg.t_array_VL1
)
RETURN NUMBER
IS
l_object_index              NUMBER;
l_log_module                VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAnAlwaysPopulatedObject';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetAnAlwaysPopulatedObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_object_index:= NULL;
--
IF p_array_table_index.COUNT > 0 THEN
--
FOR Idx IN p_array_table_index.FIRST .. p_array_table_index.LAST LOOP
   --
     IF  p_array_table_index.EXISTS(Idx)
     AND l_object_index IS NULL
     AND p_array_populated_flag.EXISTS (Idx)
     AND NVL(p_array_populated_flag(Idx),'N') ='Y'
     AND NVL(p_array_ref_obj_flag(Idx),'N') = 'N'  THEN
        --
         l_object_index := Idx;
        --
     END IF;
   --
END LOOP;

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetAnAlwaysPopulatedObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_object_index;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GetAnAlwaysPopulatedObject ');
END GetAnAlwaysPopulatedObject;

--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|    Generate the declaration of the header Cursor : The Extract of        |
--|    standard and MLS header sources from the Header Extract Object        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateHeaderCursor
       (p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_parent_table_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
       ,p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
       ,p_array_join_condition         IN xla_cmp_source_pkg.t_array_vl2000
       ,p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
       ,p_procedure                    IN VARCHAR2)
RETURN VARCHAR2 IS
--
l_hdr_cur                         VARCHAR2(32000);
l_hdr_sources                     VARCHAR2(20000);
l_hdr_tabs                        VARCHAR2(32000);
l_hdr_clauses                     VARCHAR2(32000);
--
l_hdr_source                      VARCHAR2(1000);
l_hdr_tab                         VARCHAR2(10000);
l_hdr_clause                      VARCHAR2(10000);
l_hdr_ref_clause                  VARCHAR2(10000);
--
l_h_count                         BINARY_INTEGER;
l_h_mls_count                     BINARY_INTEGER;
--
l_array_h_tab                     xla_cmp_source_pkg.t_array_ByInt;
l_array_h_mls_tab                 xla_cmp_source_pkg.t_array_ByInt;
--
l_first_tab                       BINARY_INTEGER;
l_first_mls_tab                   BINARY_INTEGER;
--
l_log_module                      VARCHAR2(240);
--
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateHeaderCursor';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateHeaderCursor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_first_tab     := NULL;
   l_first_mls_tab := NULL;
   --
   --
   l_h_count       := NVL(p_array_h_source_index.COUNT    ,0);
   l_h_mls_count   := NVL(p_array_h_mls_source_index.COUNT,0);
   --
   l_hdr_clauses   := NULL;
   l_hdr_sources   := NULL;
   l_hdr_tabs      := NULL;

   IF l_h_count > 0  THEN
      --
      -- get standard header tables/views
      --
      GetUsedExtractObject
         (p_array_table_index            => p_array_h_table_index
         ,p_array_parent_table_index     => p_array_parent_table_index
         ,p_array_diff_table_index       => l_array_h_tab);

      --
      -- Get the header always populated extract object
      --
      l_first_tab :=
         GetAnAlwaysPopulatedObject
            (p_array_table_index         => l_array_h_tab
            ,p_array_populated_flag      => p_array_populated_flag
            ,p_array_ref_obj_flag        => p_array_ref_obj_flag);

      --
      -- extract standard sources
      --
      l_hdr_sources :=
         l_hdr_sources ||
         GenerateExtractColumns
            (p_array_table_hash           => p_array_table_hash
            ,p_array_source_code          => p_array_source_code
            ,p_array_source_index         => p_array_h_source_index
            ,p_array_table_index          => p_array_h_table_index
            ,p_array_lookup_type          => p_array_lookup_type
            ,p_array_view_application_id  => p_array_view_application_id);
   END IF;

   IF l_h_mls_count > 0 THEN
      --
      -- get mls header tables/views
      --
      GetUsedExtractObject
         (p_array_table_index            => p_array_h_mls_table_index
         ,p_array_parent_table_index     => p_array_parent_table_index
         ,p_array_diff_table_index       => l_array_h_mls_tab);

      --
      -- Get the header mls always populated extract object
      --
       l_first_mls_tab :=
          GetAnAlwaysPopulatedObject
             (p_array_table_index         => l_array_h_mls_tab
             ,p_array_populated_flag      => p_array_populated_flag
             ,p_array_ref_obj_flag        => p_array_ref_obj_flag);

      --
      -- extract mls sources
      --
      l_hdr_sources :=
         l_hdr_sources ||
         GenerateExtractColumns
            (p_array_table_hash           => p_array_table_hash
            ,p_array_source_code          => p_array_source_code
            ,p_array_source_index         => p_array_h_mls_source_index
            ,p_array_table_index          => p_array_h_mls_table_index
            ,p_array_lookup_type          => p_array_lookup_type
            ,p_array_view_application_id  => p_array_view_application_id);
   END IF;

   --
   -- generate first clause
   --
   IF l_first_tab IS NOT NULL AND l_first_mls_tab IS NOT NULL THEN
        l_hdr_clause  :=
           '  AND $first_tab$.event_id      = xet.event_id'            ||g_chr_newline||
           '  AND $first_tab$.event_id      = $first_mls_tab$.event_id'||g_chr_newline||
           '  AND $first_mls_tab$.language  = p_language'              ||g_chr_newline;

        l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_tab));
        l_hdr_clause  := REPLACE(l_hdr_clause,'$first_mls_tab$', p_array_table_hash(l_first_mls_tab));
        l_hdr_clauses := l_hdr_clauses || l_hdr_clause;
        l_hdr_clause  := NULL;
   ELSIF l_first_tab IS NOT NULL AND l_first_mls_tab IS NULL THEN
        l_hdr_clause  := ' AND $first_tab$.event_id = xet.event_id' || g_chr_newline
                      ;
        l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_tab));
        l_hdr_clauses := l_hdr_clauses || l_hdr_clause;
        l_hdr_clause  := NULL;
   ELSIF l_first_tab IS NULL AND l_first_mls_tab IS NOT NULL THEN
        l_hdr_clause :=
           '  AND $first_mls_tab$.event_id   = xet.event_id' ||g_chr_newline||
           '  AND $first_mls_tab$.language   = p_language'   || g_chr_newline;

        l_hdr_clause  := REPLACE(l_hdr_clause,'$first_mls_tab$', p_array_table_hash(l_first_mls_tab));
        l_hdr_clauses := l_hdr_clauses ||l_hdr_clause;
        l_hdr_clause  := NULL;
   END IF;

   IF l_h_count > 0  THEN
      FOR Idx IN l_array_h_tab.FIRST .. l_array_h_tab.LAST LOOP
         IF l_array_h_tab.EXISTS(Idx)  THEN
            --
            -- generate the from experession in the extract
            --
            l_hdr_tab    := '  , $table_name$  $tab$' ;

            l_hdr_tab     := REPLACE(l_hdr_tab, '$table_name$', p_array_table_name(Idx));
            l_hdr_tab     := REPLACE(l_hdr_tab, '$tab$', p_array_table_hash(Idx));
            l_hdr_tabs    := l_hdr_tabs    || g_chr_newline || l_hdr_tab;
            l_hdr_tab     := NULL;

            IF NVL(p_array_ref_obj_flag(Idx),'N') = 'N' THEN
               IF Idx <> NVL(l_first_tab, -1) AND
                  nvl(p_array_populated_flag(Idx),'N') = 'Y'
               THEN
                  l_hdr_clause  := '  AND $tab$.event_id  = $first_tab$.event_id'    || g_chr_newline;
               ELSIF Idx <> NVL(l_first_tab,-1) AND
                  nvl(p_array_populated_flag(Idx),'N') = 'N'
               THEN
                  l_hdr_clause  := '  AND $tab$.event_id (+) = $first_tab$.event_id' || g_chr_newline;
               END IF;

               IF l_first_tab IS NOT NULL OR l_first_mls_tab IS NOT NULL THEN
                  l_hdr_clause  :=
                     REPLACE
                        (l_hdr_clause,'$first_tab$'
                        ,p_array_table_hash(NVL(l_first_tab,l_first_mls_tab)));
               ELSE
                  l_hdr_clause  :=
                     REPLACE
                        (l_hdr_clause,'$first_tab$', 'xet');
               END IF;

            ELSE -- reference objects

               IF nvl(p_array_populated_flag(Idx),'N') = 'Y' THEN
                  l_hdr_ref_clause := p_array_join_condition (Idx);

                  --
                  -- Replace object names with aliases
                  --
                  FOR j IN p_array_table_name.FIRST .. p_array_table_name.LAST LOOP

                     l_hdr_ref_clause :=
                         REGEXP_REPLACE(l_hdr_ref_clause
                                       ,p_array_table_name(j)
                                       ,p_array_table_hash(j)
                                       ,1    -- Position
                                       ,0    -- All Occurrences
                                       ,'im' -- i: case insensitive, m: multiple lines
                                       );
                  END LOOP;

                  l_hdr_ref_clause := ' AND ' || l_hdr_ref_clause;

               ELSE -- always populated flag = 'N'
                  l_hdr_ref_clause := AddOuterJoinOps (
                                         p_join_condition => p_array_join_condition(Idx)
                                        ,p_ref_obj_name   => p_array_table_name(Idx));
                  --
                  -- Replace object names with aliases
                  --
                  FOR j IN p_array_table_name.FIRST .. p_array_table_name.LAST LOOP

                     l_hdr_ref_clause :=
                         REGEXP_REPLACE(l_hdr_ref_clause
                                       ,p_array_table_name(j)
                                       ,p_array_table_hash(j)
                                       ,1    -- Position
                                       ,0    -- All Occurrences
                                       ,'im' -- i: case insensitive, m: multiple lines
                                       );
                  END LOOP;

                  l_hdr_ref_clause := ' AND ' || l_hdr_ref_clause;

               END IF;
            END IF;

            l_hdr_clause     := REPLACE(l_hdr_clause,'$tab$', p_array_table_hash(Idx));
            l_hdr_clauses    := l_hdr_clauses || l_hdr_clause || l_hdr_ref_clause;
            l_hdr_clause     := NULL;
            l_hdr_ref_clause := NULL;
         END IF;
      END LOOP;
   END IF;

   IF l_h_mls_count > 0 THEN
      FOR Idx IN l_array_h_mls_tab.FIRST .. l_array_h_mls_tab.LAST LOOP
         IF l_array_h_mls_tab.EXISTS(Idx)  THEN
            l_hdr_tab    := '  , $table_name$  $tab$' ;

            l_hdr_tab     := REPLACE(l_hdr_tab, '$table_name$', p_array_table_name(Idx));
            l_hdr_tab     := REPLACE(l_hdr_tab, '$tab$', p_array_table_hash(Idx));
            l_hdr_tabs    := l_hdr_tabs    ||g_chr_newline || l_hdr_tab;
            l_hdr_tab     := NULL;

            IF Idx <> NVL(l_first_mls_tab,-1) AND
               nvl(p_array_populated_flag(Idx),'N') = 'Y'
            THEN
               l_hdr_clause  :=
                  '  AND $tab$.event_id  = $first_tab$.event_id' || g_chr_newline||
                  '  AND $tab$.language  = p_language'           || g_chr_newline;
            ELSIF Idx <> NVL(l_first_mls_tab,-1) AND
                  nvl(p_array_populated_flag(Idx),'N') = 'N'
            THEN
               l_hdr_clause  :=
                  '  AND $tab$.event_id (+) = $first_tab$.event_id'|| g_chr_newline||
                  '  AND $tab$.language (+) = p_language'          || g_chr_newline;
            END IF;

            IF l_first_tab IS NOT NULL OR l_first_mls_tab IS NOT NULL THEN
               l_hdr_clause  :=
                  REPLACE
                     (l_hdr_clause,'$first_tab$'
                     ,p_array_table_hash(NVL(l_first_tab,l_first_mls_tab)));
            ELSE
               l_hdr_clause  :=
                  REPLACE
                     (l_hdr_clause,'$first_tab$', 'xet');
            END IF;

            l_hdr_clause     := REPLACE(l_hdr_clause,'$tab$', p_array_table_hash(Idx));
            l_hdr_clauses    := l_hdr_clauses || l_hdr_clause;
            l_hdr_clause     := NULL;
         END IF;
      END LOOP;
   END IF;

   --
   -- generate the extract of lookup sources
   --

   l_hdr_tabs    := l_hdr_tabs || GenerateLookupTables(
     p_array_source_index           => p_array_h_source_index
   , p_array_table_index            => p_array_h_table_index
   , p_array_lookup_type            => p_array_lookup_type
   , p_array_view_application_id    => p_array_view_application_id
   );


   l_hdr_tabs    := l_hdr_tabs || GenerateLookupTables(
     p_array_source_index           => p_array_h_mls_source_index
   , p_array_table_index            => p_array_h_mls_table_index
   , p_array_lookup_type            => p_array_lookup_type
   , p_array_view_application_id    => p_array_view_application_id
   );

   l_hdr_clauses := l_hdr_clauses || GenerateLookupClauses(
     p_array_source_index          => p_array_h_source_index
   , p_array_table_index           => p_array_h_table_index
   , p_array_table_name            => p_array_table_name
   , p_array_table_hash            => p_array_table_hash
   , p_array_source_code           => p_array_source_code
   , p_array_lookup_type           => p_array_lookup_type
   , p_array_view_application_id   => p_array_view_application_id
   );

   l_hdr_clauses := l_hdr_clauses || GenerateLookupClauses(
     p_array_source_index          => p_array_h_mls_source_index
   , p_array_table_index           => p_array_h_mls_table_index
   , p_array_table_name            => p_array_table_name
   , p_array_table_hash            => p_array_table_hash
   , p_array_source_code           => p_array_source_code
   , p_array_lookup_type           => p_array_lookup_type
   , p_array_view_application_id   => p_array_view_application_id
   );

   --
   -- generate the declaration of the header cursor
   --
   IF p_procedure = 'EVENT_TYPE' THEN
         l_hdr_cur     := C_HDR_CUR_EVENT_TYPE;
   ELSE
         l_hdr_cur     := C_HDR_CUR_EVENT_CLASS;
   END IF;

   IF l_hdr_sources IS NOT NULL AND
      l_hdr_tabs    IS NOT NULL AND
      l_hdr_clauses IS NOT NULL
   THEN

      l_hdr_cur     := REPLACE(l_hdr_cur,'$hdr_sources$',l_hdr_sources);
      l_hdr_cur     := REPLACE(l_hdr_cur,'$hdr_tabs$'   ,l_hdr_tabs);
      l_hdr_cur     := REPLACE(l_hdr_cur,'$hdr_clauses$',l_hdr_clauses);

   ELSE
     -- l_hdr_cur := NULL;
      l_hdr_cur     := REPLACE(l_hdr_cur,'$hdr_sources$',' ');
      l_hdr_cur     := REPLACE(l_hdr_cur,'$hdr_tabs$'   ,' ');
      l_hdr_cur     := REPLACE(l_hdr_cur,'$hdr_clauses$',' ');

   END IF;

   l_hdr_sources := NULL;
   l_hdr_tabs    := NULL;
   l_hdr_clauses := NULL;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'l_hdr_cur: ' || SUBSTRB(l_hdr_cur,1,3989)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateHeaderCursor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_hdr_cur;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   RETURN NULL;
WHEN OTHERS    THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_extract_pkg.GenerateHeaderCursor');
END GenerateHeaderCursor;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|    Generate the declaration of the Line Cursor : The Extract of          |
--|    standard BC and MLS line sources from the Header Extract Object       |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateLineCursor
       (p_application_id               IN NUMBER
       ,p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
       ,p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
       ,p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
       ,p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
       ,p_procedure                    IN VARCHAR2)
RETURN VARCHAR2 IS

l_line_cur                         VARCHAR2(32000);
l_line_sources                     VARCHAR2(20000);
l_line_tabs                        VARCHAR2(20000);
l_line_clauses                     VARCHAR2(20000);
--
l_line_source                      VARCHAR2(1000);
l_line_tab                         VARCHAR2(1000);
l_line_clause                      VARCHAR2(1000);
l_line_ref_clause                  VARCHAR2(1000);
--
l_l_count                          BINARY_INTEGER;
l_l_mls_count                      BINARY_INTEGER;
--
--
l_array_l_tab                      xla_cmp_source_pkg.t_array_ByInt;
l_array_l_mls_tab                  xla_cmp_source_pkg.t_array_ByInt;
--
l_first_tab                        BINARY_INTEGER;
l_first_mls_tab                    BINARY_INTEGER;
--
l_called                           BOOLEAN;
--
C_LOOKUP_TAB         CONSTANT     VARCHAR2(100) :=', fnd_lookup_values    fvl$Index$';

C_LOOKUP_CLAUSE      CONSTANT     VARCHAR2(1000):='
  AND  fvl$Index$.lookup_type(+)         = ''$lookup_type$''
  AND  fvl$Index$.lookup_code(+)         = $tab$.$source$
  AND  fvl$Index$.view_application_id(+) = $view_application_id$
  AND  fvl$Index$.language(+)            = USERENV(''LANG'') '
;

C_LINE_NUMBER       CONSTANT     VARCHAR2(100)  :=' , $tab$.LINE_NUMBER  ';
--
cursor c_alc_enabled_flag is
  select alc_enabled_flag
    from xla_subledgers
   where application_id = p_application_id;

l_alc_enabled_flag             VARCHAR2(1);
l_log_module                   VARCHAR2(240);
--
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateLineCursor';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateLineCursor'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   open c_alc_enabled_flag;
   fetch c_alc_enabled_flag into l_alc_enabled_flag;
   close c_alc_enabled_flag;

   l_l_count     := NVL(p_array_l_source_index.COUNT,0);
   l_l_mls_count := NVL(p_array_l_mls_source_index.COUNT,0);

   l_first_tab     := NULL;
   l_first_mls_tab := NULL;
   l_called        := FALSE;

--   l_line_sources := ' , $tab$.LINE_NUMBER  ';

   --
   -- get list of standard line table
   --
   IF l_l_count > 0 THEN
      GetUsedExtractObject
         (p_array_table_index            => p_array_l_table_index
         ,p_array_parent_table_index     => p_array_parent_table_index
         ,p_array_diff_table_index       => l_array_l_tab);

      --
      -- Get the line always populated extract object
      --
      l_first_tab  :=
         GetAnAlwaysPopulatedObject
            (p_array_table_index         => l_array_l_tab
            ,p_array_populated_flag      => p_array_populated_flag
            ,p_array_ref_obj_flag        => p_array_ref_obj_flag);

        --
        -- Use the following to derive the line number, and avoid the loop
        --
          l_line_sources      := REPLACE(C_LINE_NUMBER,'$tab$',
                                     p_array_table_hash(l_first_tab));

      -- Commented the below code for bug 5478323
      --
/*
      FOR Idx IN l_array_l_tab.FIRST .. l_array_l_tab.LAST LOOP
         --
         IF l_array_l_tab.EXISTS(Idx)  THEN

            IF  NOT l_called
            AND NVL(p_array_ref_obj_flag(Idx),'N') = 'N' THEN

               l_line_sources      := REPLACE(C_LINE_NUMBER,'$tab$',
                                     p_array_table_hash(Idx));

               l_called := TRUE;

            END IF;

         END IF;
      END LOOP;
*/


      l_line_sources :=
         l_line_sources ||
         GenerateExtractColumns
            (p_array_table_hash           => p_array_table_hash
            ,p_array_source_code          => p_array_source_code
            ,p_array_source_index         => p_array_l_source_index
            ,p_array_table_index          => p_array_l_table_index
            ,p_array_lookup_type          => p_array_lookup_type
            ,p_array_view_application_id  => p_array_view_application_id);
   END IF;

   --
   -- get list of mls line table
   --
   IF l_l_mls_count > 0 THEN
      GetUsedExtractObject
         (p_array_table_index            => p_array_l_mls_table_index
         ,p_array_parent_table_index     => p_array_parent_table_index
         ,p_array_diff_table_index       => l_array_l_mls_tab);

      --
      -- Get the MLS line always populated extract object
      --
      l_first_mls_tab :=
         GetAnAlwaysPopulatedObject
            (p_array_table_index         => l_array_l_mls_tab
            ,p_array_populated_flag      => p_array_populated_flag
            ,P_array_ref_obj_flag        => p_array_ref_obj_flag);

      --
      -- extract line mls sources
      --
      l_line_sources :=
         l_line_sources ||
         GenerateExtractColumns
            (p_array_table_hash           => p_array_table_hash
            ,p_array_source_code          => p_array_source_code
            ,p_array_source_index         => p_array_l_mls_source_index
            ,p_array_table_index          => p_array_l_mls_table_index
            ,p_array_lookup_type          => p_array_lookup_type
            ,p_array_view_application_id  => p_array_view_application_id)          ;
   END IF;

   --
   --
   -- generate first clause
   --
   IF l_first_tab     IS NOT NULL AND
      l_first_mls_tab IS NOT NULL
   THEN
      l_line_clause  :=
         '  AND $first_tab$.event_id      = xet.event_id'               ||g_chr_newline||
         '  AND $first_tab$.event_id      = $first_mls_tab$.event_id'   ||g_chr_newline||
         '  AND $first_tab$.line_number   = $first_mls_tab$.line_number'||g_chr_newline||
         '  AND $first_mls_tab$.language  = p_language'                 ||g_chr_newline;
      IF(l_alc_enabled_flag = 'N') THEN
        l_line_clause := l_line_clause ||
         '  AND $first_tab$.ledger_id = p_sla_ledger_id'            ||g_chr_newline;
      END IF;

      l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_tab));
      l_line_clause  := REPLACE(l_line_clause,'$first_mls_tab$', p_array_table_hash(l_first_mls_tab));

      l_line_clauses := l_line_clauses ||l_line_clause;
      l_line_clause  := NULL;

   ELSIF l_first_tab     IS NOT NULL AND
         l_first_mls_tab IS NULL
   THEN
      l_line_clause  :=
         '  AND $first_tab$.event_id      = xet.event_id'              ||g_chr_newline;
      IF(l_alc_enabled_flag = 'N') THEN
        l_line_clause := l_line_clause ||
         '  AND $first_tab$.ledger_id = p_sla_ledger_id'            ||g_chr_newline;
      END IF;

      l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_tab));
      l_line_clauses := l_line_clauses ||l_line_clause;
      l_line_clause  := NULL;

   ELSIF l_first_tab     IS NULL AND
         l_first_mls_tab IS NOT NULL
   THEN
      l_line_clause  :=
         '  AND $first_mls_tab$.event_id      = xet.event_id'||g_chr_newline||
         '  AND $first_mls_tab$.language      = p_language'  ||g_chr_newline;

      l_line_clause  := REPLACE(l_line_clause,'$first_mls_tab$', p_array_table_hash(l_first_mls_tab));
      l_line_clauses := l_line_clauses || l_line_clause;
      l_line_clause  := NULL;
   END IF;

   IF l_array_l_tab.COUNT > 0  THEN
      FOR Idx IN l_array_l_tab.FIRST .. l_array_l_tab.LAST LOOP
         IF l_array_l_tab.EXISTS(Idx)  THEN

            l_line_tab    := '  , $table_name$  $tab$' ;

            l_line_tab     := REPLACE(l_line_tab, '$table_name$', p_array_table_name(Idx));
            l_line_tab     := REPLACE(l_line_tab, '$tab$', p_array_table_hash(Idx));
            l_line_tabs    := l_line_tabs    || g_chr_newline || l_line_tab;
            l_line_tab     := NULL;


            IF NVL(p_array_ref_obj_flag(Idx),'N') = 'N' THEN

               IF Idx <> NVL(l_first_tab,-1) AND
                  nvl(p_array_populated_flag(Idx),'N') = 'Y'
               THEN
                  l_line_clause  :=
                     '  AND $tab$.event_id    = $first_tab$.event_id'   ||g_chr_newline||
                     '  AND $tab$.line_number = $first_tab$.line_number'||g_chr_newline;

               ELSIF Idx <> NVL(l_first_tab,-1) AND
                  nvl(p_array_populated_flag(Idx),'N') = 'N'
               THEN
                  l_line_clause  :=
                     '  AND $tab$.event_id (+)    = $first_tab$.event_id'   ||g_chr_newline||
                     '  AND $tab$.line_number (+) = $first_tab$.line_number'||g_chr_newline;

               END IF;

               IF l_first_tab IS NOT NULL OR
                  l_first_mls_tab IS NOT NULL
               THEN
                  l_line_clause  :=
                     REPLACE
                        (l_line_clause,'$first_tab$'
                        ,p_array_table_hash(NVL(l_first_tab,l_first_mls_tab)));
               ELSE
                  l_line_clause  :=
                     REPLACE
                        (l_line_clause,'$first_tab$', 'xet');
               END IF;
            ELSE -- reference objects
               IF nvl(p_array_populated_flag(Idx),'N') = 'Y' THEN
                  l_line_ref_clause := p_array_join_condition(Idx);

                  --
                  -- Replace object names with aliases
                  --
                  FOR j IN p_array_table_name.FIRST .. p_array_table_name.LAST LOOP
                     l_line_ref_clause :=
                         REGEXP_REPLACE(l_line_ref_clause
                                       ,p_array_table_name(j)
                                       ,p_array_table_hash(j)
                                       ,1     -- Position
                                       ,0     -- All Occurrences
                                       ,'im'  -- i: case insensitive m: multiple lines
                                       );
                  END LOOP;

                  l_line_ref_clause := ' AND ' || l_line_ref_clause;

               ELSE -- Always populated flag = 'N'

                  l_line_ref_clause := AddOuterJoinOps (
                                         p_join_condition => p_array_join_condition(Idx)
                                        ,p_ref_obj_name   => p_array_table_name(Idx));

                  --
                  -- Replace object names with aliases
                  --
                  FOR j IN p_array_table_name.FIRST .. p_array_table_name.LAST LOOP
                     l_line_ref_clause :=
                         REGEXP_REPLACE(l_line_ref_clause
                                       ,p_array_table_name(j)
                                       ,p_array_table_hash(j)
                                       ,1     -- Position
                                       ,0     -- All Occurrences
                                       ,'im'  -- i: case insensitive m: multiple lines
                                       );
                  END LOOP;

                  l_line_ref_clause := ' AND ' || l_line_ref_clause;

               END IF;
            END IF;
            --
            l_line_clause     := REPLACE(l_line_clause,'$tab$', p_array_table_hash(Idx));
            l_line_sources    := REPLACE(l_line_sources,'$tab$', p_array_table_hash(Idx));
            l_line_clauses    := l_line_clauses || l_line_clause || l_line_ref_clause;
            l_line_clause     := NULL;
            l_line_ref_clause := NULL;
         END IF;
      END LOOP;
   END IF;

   --
   -- MLS extract where clauses
   --
   IF l_array_l_mls_tab.COUNT > 0  THEN
      FOR Idx IN l_array_l_mls_tab.FIRST .. l_array_l_mls_tab.LAST LOOP
         IF l_array_l_mls_tab.EXISTS(Idx)  THEN

            l_line_tab    := '  , $table_name$  $tab$' ;

            l_line_tab     := REPLACE(l_line_tab, '$table_name$', p_array_table_name(Idx));
            l_line_tab     := REPLACE(l_line_tab, '$tab$', p_array_table_hash(Idx));
            l_line_tabs    := l_line_tabs    || g_chr_newline || l_line_tab;
            l_line_tab     := NULL;
            --
            IF Idx <> NVL(l_first_mls_tab,-1) AND
               nvl(p_array_populated_flag(Idx),'N') = 'Y'
            THEN
               l_line_clause  :=
                  '  AND $tab$.event_id    = $first_tab$.event_id'    ||g_chr_newline||
                  '  AND $tab$.line_number = $first_tab$.line_number' ||g_chr_newline||
                  '  AND $tab$.language    = p_language'              ||g_chr_newline;

            ELSIF Idx <> NVL(l_first_mls_tab,-1) AND
                  nvl(p_array_populated_flag(Idx),'N') = 'N'
            THEN
               l_line_clause  :=
                  '  AND $tab$.event_id (+)    = $first_tab$.event_id'   ||g_chr_newline||
                  '  AND $tab$.line_number (+) = $first_tab$.line_number'||g_chr_newline||
                  '  AND $tab$.language (+)    = p_language'             ||g_chr_newline;

            END IF;

            IF l_first_tab IS NOT NULL OR
               l_first_mls_tab IS NOT NULL
            THEN
               l_line_clause  :=
                  REPLACE
                     (l_line_clause,'$first_tab$'
                     ,p_array_table_hash(NVL(l_first_tab,l_first_mls_tab)));
            ELSE
               l_line_clause  :=
                  REPLACE
                     (l_line_clause,'$first_tab$', 'xet');
            END IF;

            l_line_clause  := REPLACE(l_line_clause,'$tab$', p_array_table_hash(Idx));
            l_line_sources := REPLACE(l_line_sources,'$tab$', p_array_table_hash(Idx));
            l_line_clauses := l_line_clauses ||  l_line_clause;
            l_line_clause  := NULL;
         END IF;
      END LOOP;
   END IF;

   --
   -- generate the where clauses for extract of lookup sources
   --
   l_line_tabs    := l_line_tabs || GenerateLookupTables(
     p_array_source_index           => p_array_l_source_index
   , p_array_table_index            => p_array_l_table_index
   , p_array_lookup_type            => p_array_lookup_type
   , p_array_view_application_id    => p_array_view_application_id
   );
   --
   l_line_tabs    := l_line_tabs || GenerateLookupTables(
     p_array_source_index           => p_array_l_mls_source_index
   , p_array_table_index            => p_array_l_mls_table_index
   , p_array_lookup_type            => p_array_lookup_type
   , p_array_view_application_id    => p_array_view_application_id
   );
   --
   l_line_clauses := l_line_clauses || GenerateLookupClauses(
     p_array_source_index          => p_array_l_source_index
   , p_array_table_index           => p_array_l_table_index
   , p_array_table_name            => p_array_table_name
   , p_array_table_hash            => p_array_table_hash
   , p_array_source_code           => p_array_source_code
   , p_array_lookup_type           => p_array_lookup_type
   , p_array_view_application_id   => p_array_view_application_id
   );
   --
   l_line_clauses := l_line_clauses || GenerateLookupClauses(
     p_array_source_index          => p_array_l_mls_source_index
   , p_array_table_index           => p_array_l_mls_table_index
   , p_array_table_name            => p_array_table_name
   , p_array_table_hash            => p_array_table_hash
   , p_array_source_code           => p_array_source_code
   , p_array_lookup_type           => p_array_lookup_type
   , p_array_view_application_id   => p_array_view_application_id
   );
   --
   IF p_procedure = 'EVENT_TYPE' THEN
         l_line_cur     := C_LINE_CUR_EVENT_TYPE;
    ELSE
         l_line_cur     := C_LINE_CUR_EVENT_CLASS;
    END IF;

   IF l_line_sources IS NOT NULL AND
      l_line_tabs    IS NOT NULL AND
      l_line_clauses IS NOT NULL
   THEN
   --
      l_line_cur     := REPLACE(l_line_cur,'$line_sources$',l_line_sources);
      l_line_cur     := REPLACE(l_line_cur,'$line_tabs$'   ,l_line_tabs);
      l_line_cur     := REPLACE(l_line_cur,'$line_clauses$',l_line_clauses);
   --
   ELSE
   --
    --   l_line_cur := NULL;   -> bug 4492149
      l_line_cur     := REPLACE(l_line_cur,'$line_sources$',' , 0 ');
      l_line_cur     := REPLACE(l_line_cur,'$line_tabs$'   ,' ');
      l_line_cur     := REPLACE(l_line_cur,'$line_clauses$',' ');
   --
   END IF;
   --
   l_line_sources := NULL;
   l_line_tabs    := NULL;
   l_line_clauses := NULL;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

         trace
            (p_msg      => 'l_line_cur: ' || SUBSTRB(l_line_cur,1,3988)
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);

   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

         trace
            (p_msg      => 'END of GenerateLineCursor'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);

   END IF;
   --
   RETURN l_line_cur;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateLineCursor ');
END GenerateLineCursor;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateHdrStructure
       (p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt)
RETURN VARCHAR2 IS

C_STRUCTURE        CONSTANT VARCHAR2(2000):=
'TYPE t_array_source_$Index$ IS TABLE OF $table$.$column$%TYPE INDEX BY BINARY_INTEGER;';

l_HdrTypes                     VARCHAR2(32000);
l_HdrType                      VARCHAR2(2000);
l_log_module                   VARCHAR2(240);
--
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateHdrStructure';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateHdrStructure'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_HdrTypes := NULL;
   --
   -- structure of standard header sources
   --
   IF p_array_h_source_index. COUNT > 0 THEN
      FOR Idx IN p_array_h_source_index.FIRST .. p_array_h_source_index.LAST LOOP
         IF p_array_h_source_index.EXISTS(Idx)  THEN
            l_HdrType := C_STRUCTURE;
            l_HdrType := REPLACE(l_HdrType,'$Index$' , Idx);
            l_HdrType := REPLACE(l_HdrType,'$table$' ,
                                 p_array_table_name(p_array_h_table_index(Idx)));
            l_HdrType := REPLACE(l_HdrType,'$column$', p_array_source_code(Idx));
            l_HdrTypes := l_HdrTypes ||g_chr_newline || l_HdrType ;
         END IF;
      END LOOP;
   END IF;

   --
   -- structure of mls line sources
   --
   IF p_array_h_mls_source_index.COUNT > 0 THEN
      FOR Idx IN p_array_h_mls_source_index.FIRST .. p_array_h_mls_source_index.LAST LOOP
         IF p_array_h_mls_source_index.EXISTS(Idx)  THEN
            l_HdrType := C_STRUCTURE;
            l_HdrType := REPLACE(l_HdrType,'$Index$' , Idx);
            l_HdrType := REPLACE(l_HdrType,'$table$' ,
                                  p_array_table_name(p_array_h_mls_table_index(Idx)));
            l_HdrType := REPLACE(l_HdrType,'$column$', p_array_source_code(Idx));
            l_HdrTypes := l_HdrTypes || g_chr_newline || l_HdrType ;
         END IF;
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateHdrStructure'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_HdrTypes;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateHdrStructure ');
END GenerateHdrStructure;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
FUNCTION GenerateCacheHdrSources
       (p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
       ,p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
       ,p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
       ,p_array_datatype_code          IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL1)

RETURN VARCHAR2 IS
C_SOURCE         CONSTANT VARCHAR2(2000) :='g_array_event(l_event_id).array_value_$datatype$(''source_$index$'') := l_array_source_$index$(hdr_idx);';
C_SOURCE_LKP     CONSTANT VARCHAR2(2000)  :='g_array_event(l_event_id).array_value_char(''source_$index$_meaning'') := l_array_source_$index$_meaning(hdr_idx);';

l_HdrStrings                VARCHAR2(32000);
l_one_var                   VARCHAR2(2000);
l_log_module                VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateCacheHdrSources';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateCacheHdrSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   --
   -- declare the standard header variables
   --
   l_one_var       :=  NULL;
   l_HdrStrings    :=  l_one_var ;

   IF p_array_h_source_index.COUNT > 0 THEN
      FOR Idx IN p_array_h_source_index.FIRST .. p_array_h_source_index.LAST LOOP
         IF p_array_h_source_index.EXISTS(Idx)  THEN
            l_one_var       := C_SOURCE;

            IF p_array_lookup_type.EXISTS(Idx) AND
               p_array_lookup_type(Idx) IS NOT NULL AND
               p_array_view_application_id.EXISTS(Idx) AND
               p_array_view_application_id(Idx) IS NOT NULL
            THEN
               l_one_var := l_one_var|| g_chr_newline ||C_SOURCE_LKP;
            END IF;
            l_one_var       := REPLACE(l_one_var,'$index$' ,to_char(Idx));

                case p_array_datatype_code(Idx)
                when 'F' then
                   l_one_var  := REPLACE(l_one_var,'$datatype$','num') ;
                when 'N' then
                   l_one_var  := REPLACE(l_one_var,'$datatype$','num') ;
                when 'C' then
                   l_one_var  := REPLACE(l_one_var,'$datatype$','char') ;
                when 'D' then
                   l_one_var  := REPLACE(l_one_var,'$datatype$','date') ;
                else
                   l_one_var  := REPLACE(l_one_var,'$datatype$',p_array_datatype_code(Idx)) ;
                end case;


            l_HdrStrings  := l_HdrStrings || g_chr_newline || l_one_var ;
         END IF;
      END LOOP;
   END IF;

   --
   -- declare the mls line variables
   --
   IF p_array_h_mls_source_index.COUNT > 0 THEN
      FOR Idx IN p_array_h_mls_source_index.FIRST .. p_array_h_mls_source_index.LAST LOOP
         IF p_array_h_mls_source_index.EXISTS(Idx)  THEN
            l_one_var       := C_SOURCE;

            IF p_array_lookup_type.EXISTS(Idx) AND
               p_array_lookup_type(Idx) IS NOT NULL AND
               p_array_view_application_id.EXISTS(Idx) AND
               p_array_view_application_id(Idx) IS NOT NULL
            THEN
               l_one_var := l_one_var|| g_chr_newline ||C_SOURCE_LKP;
            END IF;
            l_one_var       := REPLACE(l_one_var,'$index$' , Idx);

                case p_array_datatype_code(Idx)
                when 'F' then
                   l_one_var  := REPLACE(l_one_var,'$datatype$','num') ;
                when 'N' then
                   l_one_var  := REPLACE(l_one_var,'$datatype$','num') ;
                when 'C' then
                   l_one_var  := REPLACE(l_one_var,'$datatype$','char') ;
                when 'D' then
                   l_one_var  := REPLACE(l_one_var,'$datatype$','date') ;
                else
                   l_one_var  := REPLACE(l_one_var,'$datatype$',p_array_datatype_code(Idx)) ;
                end case;

            l_HdrStrings  := l_HdrStrings || g_chr_newline || l_one_var ;
         END IF;
      END LOOP;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateCacheHdrSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_HdrStrings;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateCacheHdrSources');
END GenerateCacheHdrSources;
--
--===========================================================================
--
--
--
--
--
--
--
--
--
--
--                   Accounting Event Extract Diagnostics
--
--
--
--
--
--
--
--
--
--
--
--============================================================================
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE function                                                         |
--|                                                                          |
--|    Generate the in the header cursor the FROM expression :               |
--|    (FROM tab1, tab2, tab3 ...)                                           |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateFromHdrTabs  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
l_hdr_tabs                        VARCHAR2(32000);
l_hdr_tab                         VARCHAR2(10000);
--
l_h_count                         BINARY_INTEGER;
l_h_mls_count                     BINARY_INTEGER;
--
l_array_h_tab                     xla_cmp_source_pkg.t_array_ByInt;
l_array_h_mls_tab                 xla_cmp_source_pkg.t_array_ByInt;
--
l_first_tab                       BINARY_INTEGER;
l_first_mls_tab                   BINARY_INTEGER;
--
l_log_module                      VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateFromHdrTabs';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateFromHdrTabs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_first_tab     := NULL;
l_first_mls_tab := NULL;
--
--
l_h_count       := NVL(p_array_h_source_index.COUNT    ,0);
l_h_mls_count   := NVL(p_array_h_mls_source_index.COUNT,0);
--

l_hdr_tabs      := NULL;
--
--
IF l_h_count > 0  THEN
   --
   -- get standard header tables/views
   --
   --
   GetUsedExtractObject( p_array_table_index      => p_array_h_table_index
                        ,p_array_parent_table_index     => p_array_parent_table_index
                        ,p_array_diff_table_index => l_array_h_tab
                       );

   --
   -- Get the header always populated extract object
   --
   l_first_tab := GetAnAlwaysPopulatedObject(
     p_array_table_index         => l_array_h_tab
   , p_array_populated_flag      => p_array_populated_flag
   , p_array_ref_obj_flag        => p_array_ref_obj_flag
   );

END IF;
--
--
--
IF l_h_mls_count > 0 THEN
   --
   -- get mls header tables/views
   --
   GetUsedExtractObject( p_array_table_index      => p_array_h_mls_table_index
                        ,p_array_parent_table_index     => p_array_parent_table_index
                        ,p_array_diff_table_index => l_array_h_mls_tab
                       );
   --
   -- Get the header mls always populated extract object
   --
    l_first_mls_tab := GetAnAlwaysPopulatedObject(
      p_array_table_index         => l_array_h_mls_tab
    , p_array_populated_flag      => p_array_populated_flag
    , p_array_ref_obj_flag        => p_array_ref_obj_flag
   );

END IF;
--
--
IF l_h_count > 0  THEN

   FOR Idx IN l_array_h_tab.FIRST .. l_array_h_tab.LAST LOOP

    IF l_array_h_tab.EXISTS(Idx)  THEN

       l_hdr_tab    := '      , $table_name$  $tab$' ;
       --
       l_hdr_tab     := REPLACE(l_hdr_tab, '$table_name$', p_array_table_name(Idx));
       l_hdr_tab     := REPLACE(l_hdr_tab, '$tab$', p_array_table_hash(Idx));
       l_hdr_tabs    := l_hdr_tabs    || g_chr_newline || l_hdr_tab;
       l_hdr_tab     := NULL;
       --

    END IF;

   END LOOP;

END IF;
--
--
IF l_h_mls_count > 0 THEN
--
    FOR Idx IN l_array_h_mls_tab.FIRST .. l_array_h_mls_tab.LAST LOOP

    IF l_array_h_mls_tab.EXISTS(Idx)  THEN

       l_hdr_tab    := '      , $table_name$  $tab$' ;
       --
       l_hdr_tab     := REPLACE(l_hdr_tab, '$table_name$', p_array_table_name(Idx));
       l_hdr_tab     := REPLACE(l_hdr_tab, '$tab$', p_array_table_hash(Idx));
       l_hdr_tabs    := l_hdr_tabs    ||g_chr_newline || l_hdr_tab;
       l_hdr_tab     := NULL;

    END IF;

   END LOOP;
--
END IF;

--
-- generate the extract of lookup sources
--

l_hdr_tabs    := l_hdr_tabs || GenerateLookupTables(
  p_array_source_index           => p_array_h_source_index
, p_array_table_index            => p_array_h_table_index
, p_array_lookup_type            => p_array_lookup_type
, p_array_view_application_id    => p_array_view_application_id
);


l_hdr_tabs    := l_hdr_tabs || GenerateLookupTables(
  p_array_source_index           => p_array_h_mls_source_index
, p_array_table_index            => p_array_h_mls_table_index
, p_array_lookup_type            => p_array_lookup_type
, p_array_view_application_id    => p_array_view_application_id
);
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateFromHdrTabs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_hdr_tabs;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateFromHdrTabs ');
END GenerateFromHdrTabs;
--
--
--+==========================================================================+
--|                                                                          |
--| Private  function                                                        |
--|                                                                          |
--|    Generate the in the header cursor the WHERE CLAUSES :                 |
--|    (WHERE col1 = col2 AND ...)                                           |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateHdrWhereClause  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
--
, p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
l_hdr_clauses                     VARCHAR2(32000);
--
l_hdr_clause                      VARCHAR2(10000);
--
l_hdr_ref_clause                  VARCHAR2(10000);
--
l_h_count                         BINARY_INTEGER;
l_h_mls_count                     BINARY_INTEGER;
--
l_array_h_tab                     xla_cmp_source_pkg.t_array_ByInt;
l_array_h_mls_tab                 xla_cmp_source_pkg.t_array_ByInt;
--
l_first_tab                       BINARY_INTEGER;
l_first_mls_tab                   BINARY_INTEGER;
--
l_log_module                      VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateHdrWhereClause';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateHdrWhereClause'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_first_tab     := NULL;
l_first_mls_tab := NULL;
--
l_h_count       := NVL(p_array_h_source_index.COUNT    ,0);
l_h_mls_count   := NVL(p_array_h_mls_source_index.COUNT,0);
--
l_hdr_clauses   := NULL;
--
--
IF l_h_count > 0  THEN
   --
   -- get standard header tables/views
   --
   --
   GetUsedExtractObject( p_array_table_index      => p_array_h_table_index
                        ,p_array_parent_table_index     => p_array_parent_table_index
                        ,p_array_diff_table_index => l_array_h_tab
                       );

   --
   -- Get the header always populated extract object
   --
   l_first_tab := GetAnAlwaysPopulatedObject(
     p_array_table_index         => l_array_h_tab
   , p_array_populated_flag      => p_array_populated_flag
   , p_array_ref_obj_flag        => p_array_ref_obj_flag
   );
   --
END IF;
--
--
--
IF l_h_mls_count > 0 THEN
   --
   -- get mls header tables/views
   --
   GetUsedExtractObject( p_array_table_index      => p_array_h_mls_table_index
                        ,p_array_parent_table_index     => p_array_parent_table_index
                        ,p_array_diff_table_index => l_array_h_mls_tab
                       );
   --
   -- Get the header mls always populated extract object
   --
    l_first_mls_tab := GetAnAlwaysPopulatedObject(
      p_array_table_index         => l_array_h_mls_tab
    , p_array_populated_flag      => p_array_populated_flag
    , p_array_ref_obj_flag        => p_array_ref_obj_flag
   );

END IF;
--
-- generate first clause
--
IF l_first_tab IS NOT NULL AND l_first_mls_tab IS NOT NULL THEN

     l_hdr_clause  :=  '  AND $first_tab$.event_id      = xet.event_id'              ||g_chr_newline
                     ||'  AND $first_tab$.event_id  = $first_mls_tab$.event_id'||g_chr_newline
                     ||'  AND $first_mls_tab$.language  = p_language'          ||g_chr_newline
                     ;

     l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_tab));
     l_hdr_clause  := REPLACE(l_hdr_clause,'$first_mls_tab$', p_array_table_hash(l_first_mls_tab));
     l_hdr_clauses := l_hdr_clauses || l_hdr_clause;
     l_hdr_clause  := NULL;
     --
ELSIF l_first_tab IS NOT NULL AND l_first_mls_tab IS NULL THEN

     l_hdr_clause  := '   AND $first_tab$.event_id = xet.event_id' || g_chr_newline
                   ;
     l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_tab));
     l_hdr_clauses := l_hdr_clauses || l_hdr_clause;
     l_hdr_clause  := NULL;

ELSIF l_first_tab IS NULL AND l_first_mls_tab IS NOT NULL THEN

     l_hdr_clause := '  AND $first_mls_tab$.event_id       = xet.event_id'|| g_chr_newline
                  || '  AND $first_mls_tab$.language   = p_language'|| g_chr_newline
                  ;
     --
     l_hdr_clause  := REPLACE(l_hdr_clause,'$first_mls_tab$', p_array_table_hash(l_first_mls_tab));
     l_hdr_clauses := l_hdr_clauses ||l_hdr_clause;
     l_hdr_clause  := NULL;

END IF;
--
--
IF l_h_count > 0  THEN

   FOR Idx IN l_array_h_tab.FIRST .. l_array_h_tab.LAST LOOP

    IF l_array_h_tab.EXISTS(Idx)  THEN
     --
       IF NVL(p_array_ref_obj_flag (Idx),'N') = 'N' THEN

          IF  Idx <> NVL(l_first_tab,-1)
          AND nvl(p_array_populated_flag(Idx),'N') = 'Y'
          AND l_first_tab IS NOT NULL
          THEN

            l_hdr_clause  := '  AND $tab$.event_id  = $first_tab$.event_id'  || g_chr_newline
                       ;
            l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_tab));

          ELSIF Idx <> NVL(l_first_tab,-1) AND
                nvl(p_array_populated_flag(Idx),'N') = 'N' AND
                l_first_tab IS NOT NULL  THEN

             l_hdr_clause  := '  AND $tab$.event_id (+) = $first_tab$.event_id' || g_chr_newline
                       ;
             l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_tab));

          ELSIF Idx <> NVL(l_first_tab,-1) AND
                nvl(p_array_populated_flag(Idx),'N') = 'Y' AND
                l_first_mls_tab IS NOT NULL
          THEN

            l_hdr_clause  := '  AND $tab$.event_id  = $first_tab$.event_id'   || g_chr_newline
                       ;
            l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_mls_tab));

          ELSIF Idx <> NVL(l_first_tab,-1) AND
                nvl(p_array_populated_flag(Idx),'N') = 'N' AND
                l_first_mls_tab IS NOT NULL THEN

            l_hdr_clause  := '  AND $tab$.event_id (+) = $first_tab$.event_id'|| g_chr_newline
                       ;
            l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_mls_tab));

          END IF;

       ELSE -- reference objects
          IF nvl(p_array_populated_flag(Idx),'N') = 'Y' THEN
             l_hdr_ref_clause := p_array_join_condition(Idx);

             --
             -- Replace object names with aliases
             --
             FOR j IN p_array_table_name.FIRST .. p_array_table_name.LAST LOOP
                l_hdr_ref_clause := REPLACE(LOWER(l_hdr_ref_clause)
                                           ,LOWER(p_array_table_name(j))
                                           ,LOWER(p_array_table_hash(j)));
             END LOOP;

             l_hdr_ref_clause := ' AND ' || l_hdr_ref_clause;

          ELSE
             l_hdr_ref_clause := AddOuterJoinOps(
                                  p_join_condition => p_array_join_condition(Idx)
                                 ,p_ref_obj_name   => p_array_table_name(Idx));

             --
             -- Replace object names with aliases
             --
             FOR j IN p_array_table_name.FIRST .. p_array_table_name.LAST LOOP
                l_hdr_ref_clause := REPLACE(LOWER(l_hdr_ref_clause)
                                           ,LOWER(p_array_table_name(j))
                                           ,LOWER(p_array_table_hash(j)));
             END LOOP;

             l_hdr_ref_clause := ' AND ' || l_hdr_ref_clause;

          END IF;
       END IF;
      --

       l_hdr_clause      := REPLACE(l_hdr_clause,'$tab$', p_array_table_hash(Idx));
       l_hdr_clauses     := l_hdr_clauses || l_hdr_clause || l_hdr_ref_clause;
       l_hdr_clause      := NULL;
       l_hdr_ref_clause  := NULL;
       --

    END IF;

   END LOOP;

END IF;
--
--
IF l_h_mls_count > 0 THEN
--
    FOR Idx IN l_array_h_mls_tab.FIRST .. l_array_h_mls_tab.LAST LOOP

    IF l_array_h_mls_tab.EXISTS(Idx)  THEN

       IF Idx <> NVL(l_first_mls_tab,-1) AND
          nvl(p_array_populated_flag(Idx),'N') = 'Y' AND
          l_first_mls_tab IS NOT NULL THEN

             l_hdr_clause  := '  AND $tab$.event_id  = $first_tab$.event_id' || g_chr_newline
                           || '  AND $tab$.language  = $first_tab$.language' || g_chr_newline
                           ;

             l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_mls_tab));
             l_hdr_clause  := REPLACE(l_hdr_clause,'$tab$', p_array_table_hash(Idx));

       ELSIF Idx <> NVL(l_first_mls_tab,-1) AND
            nvl(p_array_populated_flag(Idx),'N') = 'N' AND
            l_first_mls_tab IS NOT NULL THEN

             l_hdr_clause  := '  AND $tab$.event_id (+) = $first_tab$.event_id'|| g_chr_newline
                           || '  AND $tab$.language (+) = $first_tab$.language'|| g_chr_newline
                           ;

             l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_mls_tab));
             l_hdr_clause  := REPLACE(l_hdr_clause,'$tab$', p_array_table_hash(Idx));

       ELSIF Idx <> NVL(l_first_mls_tab,-1) AND
             nvl(p_array_populated_flag(Idx),'N') = 'Y' AND
             l_first_tab IS NOT NULL THEN

             l_hdr_clause  := '  AND $tab$.event_id  = $first_tab$.event_id'|| g_chr_newline
                           || '  AND $tab$.language  = p_language'          || g_chr_newline
                           ;

             l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_tab));
             l_hdr_clause  := REPLACE(l_hdr_clause,'$tab$', p_array_table_hash(Idx));

       ELSIF Idx <> NVL(l_first_mls_tab,-1) AND
            nvl(p_array_populated_flag(Idx),'N') = 'N' AND
             l_first_tab IS NOT NULL THEN

             l_hdr_clause  := '  AND $tab$.event_id (+) = $first_tab$.event_id'|| g_chr_newline
                           || '  AND $tab$.language (+) = p_language'|| g_chr_newline
                           ;

             l_hdr_clause  := REPLACE(l_hdr_clause,'$first_tab$',p_array_table_hash(l_first_tab));
             l_hdr_clause  := REPLACE(l_hdr_clause,'$tab$', p_array_table_hash(Idx));

       END IF;

       l_hdr_clauses := l_hdr_clauses ||l_hdr_clause;
       l_hdr_clause  := NULL;
    --
    END IF;

   END LOOP;
--
END IF;
--

l_hdr_clauses := l_hdr_clauses || GenerateLookupClauses(
  p_array_source_index          => p_array_h_source_index
, p_array_table_index           => p_array_h_table_index
, p_array_table_name            => p_array_table_name
, p_array_table_hash            => p_array_table_hash
, p_array_source_code           => p_array_source_code
, p_array_lookup_type           => p_array_lookup_type
, p_array_view_application_id   => p_array_view_application_id
);

l_hdr_clauses := l_hdr_clauses || GenerateLookupClauses(
  p_array_source_index          => p_array_h_mls_source_index
, p_array_table_index           => p_array_h_mls_table_index
, p_array_table_name            => p_array_table_name
, p_array_table_hash            => p_array_table_hash
, p_array_source_code           => p_array_source_code
, p_array_lookup_type           => p_array_lookup_type
, p_array_view_application_id   => p_array_view_application_id
);

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'l_hdr_clauses: ' || SUBSTRB(l_hdr_clauses,1, 3985)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateHdrWhereClause'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_hdr_clauses;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateHdrWhereClause ');
END GenerateHdrWhereClause;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  function                                                        |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateFromLineTabs  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
l_line_tabs                        VARCHAR2(20000);
l_line_tab                         VARCHAR2(1000);
l_l_count                          BINARY_INTEGER;
l_l_mls_count                      BINARY_INTEGER;
l_array_l_tab                      xla_cmp_source_pkg.t_array_ByInt;
l_array_l_mls_tab                  xla_cmp_source_pkg.t_array_ByInt;
l_first_tab                        BINARY_INTEGER;
l_first_mls_tab                    BINARY_INTEGER;
--
l_log_module                   VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateFromLineTabs';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateFromLineTabs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_l_count     := NVL(p_array_l_source_index.COUNT,0);
l_l_mls_count := NVL(p_array_l_mls_source_index.COUNT,0);
--
l_first_tab     := NULL;
l_first_mls_tab := NULL;
--

--
-- get list of standard line table
--
IF l_l_count > 0 THEN
   --
   GetUsedExtractObject( p_array_table_index      => p_array_l_table_index
                        ,p_array_parent_table_index     => p_array_parent_table_index
                        ,p_array_diff_table_index => l_array_l_tab
                     );
   --
   -- Get the line always populated extract object
   --
  l_first_tab  := GetAnAlwaysPopulatedObject(
        p_array_table_index         => l_array_l_tab
      , p_array_populated_flag      => p_array_populated_flag
      , p_array_ref_obj_flag        => p_array_ref_obj_flag
      );

END IF;

--
-- get list of mls line table
--
IF l_l_mls_count > 0 THEN
      --
      GetUsedExtractObject( p_array_table_index => p_array_l_mls_table_index
                           ,p_array_parent_table_index     => p_array_parent_table_index
                           ,p_array_diff_table_index => l_array_l_mls_tab
                     );
      --
      -- Get the MLS line always populated extract object
      --
      l_first_mls_tab := GetAnAlwaysPopulatedObject(
        p_array_table_index         => l_array_l_mls_tab
      , p_array_populated_flag      => p_array_populated_flag
      , p_array_ref_obj_flag        => p_array_ref_obj_flag
      );
--
END IF;
--
--
IF l_array_l_tab.COUNT > 0  THEN

   FOR Idx IN l_array_l_tab.FIRST .. l_array_l_tab.LAST LOOP

    IF l_array_l_tab.EXISTS(Idx)  THEN

       l_line_tab    := '        , $table_name$  $tab$' ;
       --
       l_line_tab     := REPLACE(l_line_tab, '$table_name$', p_array_table_name(Idx));
       l_line_tab     := REPLACE(l_line_tab, '$tab$', p_array_table_hash(Idx));
       l_line_tabs    := l_line_tabs    || g_chr_newline || l_line_tab;
       l_line_tab     := NULL;
       --
       --
    END IF;

   END LOOP;

END IF;
--
-- MLS extract where clauses
--
IF l_array_l_mls_tab.COUNT > 0  THEN

   FOR Idx IN l_array_l_mls_tab.FIRST .. l_array_l_mls_tab.LAST LOOP

    IF l_array_l_mls_tab.EXISTS(Idx)  THEN

       l_line_tab    := '        , $table_name$  $tab$' ;
       --
       l_line_tab     := REPLACE(l_line_tab, '$table_name$', p_array_table_name(Idx));
       l_line_tab     := REPLACE(l_line_tab, '$tab$', p_array_table_hash(Idx));
       l_line_tabs    := l_line_tabs    || g_chr_newline || l_line_tab;
       l_line_tab     := NULL;
       --

    END IF;

   END LOOP;

END IF;
--
-- generate the where clauses for extract of lookup sources
--
l_line_tabs    := l_line_tabs || GenerateLookupTables(
  p_array_source_index           => p_array_l_source_index
, p_array_table_index            => p_array_l_table_index
, p_array_lookup_type            => p_array_lookup_type
, p_array_view_application_id    => p_array_view_application_id
);
--
l_line_tabs    := l_line_tabs || GenerateLookupTables(
  p_array_source_index           => p_array_l_mls_source_index
, p_array_table_index            => p_array_l_mls_table_index
, p_array_lookup_type            => p_array_lookup_type
, p_array_view_application_id    => p_array_view_application_id
);
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateFromLineTabs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_line_tabs;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateFromLineTabs ');
END GenerateFromLineTabs;
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE function                                                         |
--|                                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateLineWhereClause  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000

--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
)
RETURN VARCHAR2
IS
--
l_line_clauses                     VARCHAR2(20000);
l_line_clause                      VARCHAR2(1000);
--
l_line_ref_clause                  VARCHAR2(1000);
--
l_l_count                          BINARY_INTEGER;
l_l_mls_count                      BINARY_INTEGER;
--
l_array_l_tab                      xla_cmp_source_pkg.t_array_ByInt;
l_array_l_mls_tab                  xla_cmp_source_pkg.t_array_ByInt;
--
l_first_tab                        BINARY_INTEGER;
l_first_mls_tab                    BINARY_INTEGER;
--
l_log_module                   VARCHAR2(240);

l_alc_enabled_flag             VARCHAR2(1);
--
BEGIN
--


IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateLineWhereClause';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateLineWhereClause'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
  select alc_enabled_flag
    into l_alc_enabled_flag
    from xla_subledgers
   where application_id = g_application_id;

l_l_count     := NVL(p_array_l_source_index.COUNT,0);
l_l_mls_count := NVL(p_array_l_mls_source_index.COUNT,0);
--
l_first_tab     := NULL;
l_first_mls_tab := NULL;
--
--
-- get list of standard line table
--
IF l_l_count > 0 THEN
   --
   GetUsedExtractObject( p_array_table_index      => p_array_l_table_index
                        ,p_array_parent_table_index     => p_array_parent_table_index
                        ,p_array_diff_table_index => l_array_l_tab
                     );
   --
   -- Get the line always populated extract object
   --
  l_first_tab  := GetAnAlwaysPopulatedObject(
        p_array_table_index         => l_array_l_tab
      , p_array_populated_flag      => p_array_populated_flag
      , p_array_ref_obj_flag        => p_array_ref_obj_flag
      );
   --
END IF;

--
-- get list of mls line table
--
IF l_l_mls_count > 0 THEN
      --
      GetUsedExtractObject( p_array_table_index => p_array_l_mls_table_index
                     ,p_array_parent_table_index     => p_array_parent_table_index
                     ,p_array_diff_table_index => l_array_l_mls_tab
                     );

      --
      -- Get the MLS line always populated extract object
      --
      l_first_mls_tab := GetAnAlwaysPopulatedObject(
        p_array_table_index         => l_array_l_mls_tab
      , p_array_populated_flag      => p_array_populated_flag
      , p_array_ref_obj_flag        => p_array_ref_obj_flag
      );
--
END IF;
--
-- generate first clause
--
IF l_first_tab     IS NOT NULL AND
   l_first_mls_tab IS NOT NULL THEN

     l_line_clause  := '  AND $first_tab$.event_id          = xet.event_id'                 ||g_chr_newline
                    || '  AND $first_tab$.event_id      = $first_mls_tab$.event_id'   ||g_chr_newline
                    || '  AND $first_tab$.line_number   = $first_mls_tab$.line_number'||g_chr_newline
                    || '  AND $first_mls_tab$.language  = p_language'                 ||g_chr_newline
                    || '  AND $first_tab$.ledger_id(+)  = p_sla_ledger_id'            ||g_chr_newline
                    ;
     --
     l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_tab));
     l_line_clause  := REPLACE(l_line_clause,'$first_mls_tab$', p_array_table_hash(l_first_mls_tab));

     l_line_clauses := l_line_clauses ||l_line_clause;
     l_line_clause  := NULL;

     --
ELSIF l_first_tab     IS NOT NULL AND
      l_first_mls_tab IS NULL THEN

     l_line_clause  := '  AND $first_tab$.event_id          = xet.event_id'                ||g_chr_newline;
      IF(l_alc_enabled_flag = 'N') THEN
        l_line_clause := l_line_clause ||
        '  AND $first_tab$.ledger_id (+)  = p_sla_ledger_id'           ||g_chr_newline;
END IF;

     --
     l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_tab));
     l_line_clauses := l_line_clauses ||l_line_clause;
     l_line_clause  := NULL;

ELSIF l_first_tab     IS NULL AND
      l_first_mls_tab IS NOT NULL THEN

     l_line_clause  := '  AND $first_mls_tab$.event_id        = xet.event_id'                ||g_chr_newline
                    || '  AND $first_mls_tab$.language    = p_language'                ||g_chr_newline
                    ;

     --
     l_line_clause  := REPLACE(l_line_clause,'$first_mls_tab$', p_array_table_hash(l_first_mls_tab));
     l_line_clauses := l_line_clauses || l_line_clause;
     l_line_clause  := NULL;

END IF;
--
--
IF l_array_l_tab.COUNT > 0  THEN

   FOR Idx IN l_array_l_tab.FIRST .. l_array_l_tab.LAST LOOP

    IF l_array_l_tab.EXISTS(Idx)  THEN
       --
       IF nvl(p_array_ref_obj_flag(Idx),'N') = 'N' THEN

          IF Idx <> NVL(l_first_tab,-1) AND
                nvl(p_array_populated_flag(Idx),'N') = 'Y' AND
                l_first_tab IS NOT NULL
          THEN

            l_line_clause  := '  AND $tab$.event_id    = $first_tab$.event_id'   ||g_chr_newline
                           || '  AND $tab$.line_number = $first_tab$.line_number'||g_chr_newline
                           ;

            l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_tab));

          ELSIF Idx <> NVL(l_first_tab,-1) AND
                nvl(p_array_populated_flag(Idx),'N') = 'N' AND
                l_first_tab IS NOT NULL  THEN

                l_line_clause  := '  AND $tab$.event_id (+)    = $first_tab$.event_id'   ||g_chr_newline
                               || '  AND $tab$.line_number (+) = $first_tab$.line_number'||g_chr_newline
                               ;

            l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_tab));

          ELSIF Idx <> NVL(l_first_tab,-1) AND
                nvl(p_array_populated_flag(Idx),'N') = 'Y' AND
                l_first_mls_tab IS NOT NULL
          THEN

            l_line_clause  := '  AND $tab$.event_id    = $first_tab$.event_id'   ||g_chr_newline
                           || '  AND $tab$.line_number = $first_tab$.line_number'||g_chr_newline
                           ;

            l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_mls_tab));

          ELSIF Idx <> NVL(l_first_tab,-1) AND
                nvl(p_array_populated_flag(Idx),'N') = 'N' AND
                l_first_mls_tab IS NOT NULL THEN

            l_line_clause  := '  AND $tab$.event_id (+)    = $first_tab$.event_id'   ||g_chr_newline
                           || '  AND $tab$.line_number (+) = $first_tab$.line_number'||g_chr_newline
                           ;

            l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_mls_tab));

          END IF;

       ELSE -- reference objects
          IF nvl(p_array_populated_flag(Idx),'N') = 'Y' THEN
             l_line_ref_clause := p_array_join_condition(Idx);

             --
             -- Replace object names with aliases
             --
             FOR j IN p_array_table_name.FIRST .. p_array_table_name.LAST LOOP
                l_line_ref_clause := REPLACE (LOWER(l_line_ref_clause)
                                             ,LOWER(p_array_table_name(j))
                                             ,LOWER(p_array_table_hash(j)));
             END LOOP;

             l_line_ref_clause := ' AND ' || l_line_ref_clause;
          ELSE
             l_line_ref_clause := AddOuterJoinOps(
                                     p_join_condition => p_array_join_condition(Idx)
                                    ,p_ref_obj_name   => p_array_table_name(Idx));

             --
             -- Replace object names with aliases
             --
             FOR j IN p_array_table_name.FIRST .. p_array_table_name.LAST LOOP
                l_line_ref_clause := REPLACE (LOWER(l_line_ref_clause)
                                             ,LOWER(p_array_table_name(j))
                                             ,LOWER(p_array_table_hash(j)));
             END LOOP;

             l_line_ref_clause := ' AND ' || l_line_ref_clause;
          END IF;
       END IF;
       --
       l_line_clause     := REPLACE(l_line_clause,'$tab$', p_array_table_hash(Idx));
       l_line_clauses    := l_line_clauses || l_line_clause || l_line_ref_clause;
       l_line_clause     := NULL;
       l_line_ref_clause := NULL;


    END IF;

   END LOOP;

END IF;
--
-- MLS extract where clauses
--
IF l_array_l_mls_tab.COUNT > 0  THEN

   FOR Idx IN l_array_l_mls_tab.FIRST .. l_array_l_mls_tab.LAST LOOP

    IF l_array_l_mls_tab.EXISTS(Idx)  THEN
       --
       IF Idx <> NVL(l_first_mls_tab,-1) AND
             nvl(p_array_populated_flag(Idx),'N') = 'Y' AND
             l_first_mls_tab IS NOT NULL
       THEN

         l_line_clause  := '  AND $tab$.event_id    = $first_tab$.event_id'    ||g_chr_newline
                        || '  AND $tab$.line_number = $first_tab$.line_number' ||g_chr_newline
                        || '  AND $tab$.language    = $first_tab$.language'    ||g_chr_newline
                        ;

         l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_mls_tab));

       ELSIF Idx <> NVL(l_first_mls_tab,-1) AND
             nvl(p_array_populated_flag(Idx),'N') = 'N' AND
             l_first_mls_tab IS NOT NULL THEN

         l_line_clause  := '  AND $tab$.event_id (+)    = $first_tab$.event_id'   ||g_chr_newline
                        || '  AND $tab$.line_number (+) = $first_tab$.line_number'||g_chr_newline
                        || '  AND $tab$.language (+)    = $first_tab$.language'   ||g_chr_newline
                        ;
         l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_mls_tab));

        ELSIF Idx <> NVL(l_first_mls_tab,-1) AND
              nvl(p_array_populated_flag(Idx),'N') = 'Y' AND
              l_first_tab IS NOT NULL
        THEN

          l_line_clause  := '  AND $tab$.event_id    = $first_tab$.event_id'   ||g_chr_newline
                         || '  AND $tab$.line_number = $first_tab$.line_number'||g_chr_newline
                         || '  AND $tab$.language    = p_language'             ||g_chr_newline
                         ;
          l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_tab));

        ELSIF Idx <> NVL(l_first_mls_tab,-1) AND
              nvl(p_array_populated_flag(Idx),'N') = 'N' AND
              l_first_tab IS NOT NULL  THEN

         l_line_clause  := '  AND $tab$.event_id (+)    = $first_tab$.event_id'   ||g_chr_newline
                        || '  AND $tab$.line_number (+) = $first_tab$.line_number'||g_chr_newline
                        || '  AND $tab$.language (+)    = p_language'             ||g_chr_newline
                        ;

         l_line_clause  := REPLACE(l_line_clause,'$first_tab$',p_array_table_hash(l_first_tab));


       END IF;
       --

       l_line_clause  := REPLACE(l_line_clause,'$tab$', p_array_table_hash(Idx));
       l_line_clauses := l_line_clauses ||  l_line_clause;
       l_line_clause  := NULL;


    END IF;

   END LOOP;

END IF;
--
-- generate the where clauses for extract of lookup sources
--
--
l_line_clauses := l_line_clauses || GenerateLookupClauses(
  p_array_source_index          => p_array_l_source_index
, p_array_table_index           => p_array_l_table_index
, p_array_table_name            => p_array_table_name
, p_array_table_hash            => p_array_table_hash
, p_array_source_code           => p_array_source_code
, p_array_lookup_type           => p_array_lookup_type
, p_array_view_application_id   => p_array_view_application_id
);
--
l_line_clauses := l_line_clauses || GenerateLookupClauses(
  p_array_source_index          => p_array_l_mls_source_index
, p_array_table_index           => p_array_l_mls_table_index
, p_array_table_name            => p_array_table_name
, p_array_table_hash            => p_array_table_hash
, p_array_source_code           => p_array_source_code
, p_array_lookup_type           => p_array_lookup_type
, p_array_view_application_id   => p_array_view_application_id
);
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'l_line_clauses: ' || SUBSTRB(l_line_clauses,1,3984)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateLineWhereClause'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_line_clauses;
EXCEPTION
 WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateLineWhereClause ');
END GenerateLineWhereClause;
--
--
--+==========================================================================+
--|                                                                          |
--| PRIVATE  FUNCTION                                                        |
--|                                                                          |
--|      Generate the CASE expression into the SQL statements used to        |
--|      Insert header and line sources retrieved from the extract           |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateInsertStm(
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_table_type             IN xla_cmp_source_pkg.t_array_VL30
, p_array_table_index            IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_source_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_application_id         IN xla_cmp_source_pkg.t_array_Num
, p_array_source_type_code       IN xla_cmp_source_pkg.t_array_VL1
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
--
, p_level                        IN VARCHAR2
, p_procedure                    IN VARCHAR2
)
RETURN CLOB
IS

--
C_LINE_NUMBER         CONSTANT VARCHAR2(100):= '$tab$.line_number';
C_OBJECT_NAME         CONSTANT VARCHAR2(200):=  'WHEN $index$ THEN ''$object_name$'' ';
C_OBJECT_TYPE_CODE    CONSTANT VARCHAR2(200):=  'WHEN $index$ THEN ''$object_type_code$'' ';
C_SOURCE_APPL_ID      CONSTANT VARCHAR2(200):=  'WHEN $index$ THEN ''$source_application_id$'' ';
C_SOURCE_TYPE_CODE    CONSTANT VARCHAR2(200):=  '''$source_type_code$'' ';
C_SOURCE_CODE         CONSTANT VARCHAR2(200):=  'WHEN $index$ THEN ''$source_code$'' ';
C_SOURCE_VALUE        CONSTANT VARCHAR2(200):=  'WHEN $index$ THEN TO_CHAR($tab$.$source_code$)';
--
C_MEANING_NOT_NULL    CONSTANT VARCHAR2(1000):=   'CASE r
                $source_meaning$
                ELSE null
              END ';
C_MEANING_NULL               CONSTANT VARCHAR2(100):=  'null';
C_SOURCE_MEANING_LOOKUP      CONSTANT VARCHAR2(200):=  'WHEN $index$ THEN fvl$Idx$.meaning';
C_SOURCE_MEANING_VALSET      CONSTANT VARCHAR2(1000):=  'WHEN $index$ THEN $package_name$.GetMeaning(
                          $flex_value_set_id$
                         ,TO_CHAR($tab$.$source_code$)
                         ,''$source_code$''
                         ,''$source_type_code$''
                         ,$source_application_id$)';



--
l_sql_statement          CLOB;

l_object_name            VARCHAR2(32000);
l_object_type_code       VARCHAR2(32000);
l_source_appl_id         VARCHAR2(32000);
l_source_type_code       VARCHAR2(32000);
l_source_code            VARCHAR2(32000);
l_source_value           VARCHAR2(32000);
l_source_meaning         VARCHAR2(32000);
l_line_number            VARCHAR2(32000);
--
--
l_source_num             NUMBER;
--
l_log_module             VARCHAR2(240);
l_space                  VARCHAR2(100);
--
l_called                 BOOLEAN;
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateInsertStm';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateInsertStm'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

--
l_space              := '                ';
l_object_name        := NULL;
l_object_type_code   := NULL;
l_source_appl_id     := NULL;
l_source_type_code   := NULL;
l_source_code        := NULL;
l_source_value       := NULL;
l_source_meaning     := NULL;
--
l_source_num:= 0;
l_called := FALSE;
--
IF p_array_source_index.COUNT > 0 THEN
--
   FOR idx IN p_array_table_index.FIRST..p_array_table_index.LAST LOOP
      IF p_array_table_index.EXISTS(idx) AND
         p_array_populated_flag(p_array_table_index(idx)) = 'Y' AND
         p_array_ref_obj_flag (p_array_table_index(idx)) = 'N' THEN

         l_line_number      := REPLACE(C_LINE_NUMBER,'$tab$',
                                        p_array_table_hash(p_array_table_index(idx))); -- Bug 5478323
         EXIT;
      END IF;
   END LOOP;

   FOR Idx IN p_array_source_index.FIRST .. p_array_source_index.LAST LOOP
   --
      IF p_array_source_index.EXISTS(Idx)  THEN

        l_source_num:= l_source_num + 1 ;

        IF l_source_type_code IS NULL THEN
           l_source_type_code   := REPLACE(C_SOURCE_TYPE_CODE,'$source_type_code$'
                                ,p_array_source_type_code(p_array_source_index(Idx)));
        END IF;

        l_object_name        := l_object_name ||C_OBJECT_NAME||g_chr_newline||l_space;

        l_object_name        := REPLACE(l_object_name,'$object_name$',
                                 p_array_table_name(p_array_table_index(Idx)));

        l_object_name        := REPLACE(l_object_name,'$index$',l_source_num);
        --
        l_object_type_code   := l_object_type_code ||C_OBJECT_TYPE_CODE||g_chr_newline||l_space;

        l_object_type_code   := REPLACE(l_object_type_code,'$object_type_code$',
                                   p_array_table_type(p_array_table_index(Idx)));

        l_object_type_code   := REPLACE(l_object_type_code,'$index$',l_source_num);
        --

        l_source_appl_id        := l_source_appl_id ||C_SOURCE_APPL_ID||g_chr_newline||l_space;

        l_source_appl_id        := REPLACE(l_source_appl_id,'$source_application_id$'
                                ,p_array_application_id(p_array_source_index(Idx)));

        l_source_appl_id        := REPLACE(l_source_appl_id,'$index$',l_source_num);

        --

        l_source_code        := l_source_code ||C_SOURCE_CODE||g_chr_newline||l_space;

        l_source_code        := REPLACE(l_source_code,'$source_code$'
                                ,p_array_source_code(p_array_source_index(Idx)));

        l_source_code        := REPLACE(l_source_code,'$index$',l_source_num);

        --
        l_source_value       := l_source_value ||C_SOURCE_VALUE||g_chr_newline||l_space;

        l_source_value        := REPLACE(l_source_value,'$source_code$'
                                ,p_array_source_code(p_array_source_index(Idx)));

        l_source_value        := REPLACE(l_source_value,'$tab$'
                                ,p_array_table_hash(p_array_table_index(Idx)));

        l_source_value        := REPLACE(l_source_value,'$index$',l_source_num);
        --

        IF p_array_lookup_type.EXISTS(Idx) AND
           p_array_lookup_type(Idx) IS NOT NULL AND
           p_array_view_application_id.EXISTS(Idx) AND
           p_array_view_application_id(Idx) IS NOT NULL THEN

           l_source_meaning     := l_source_meaning || C_SOURCE_MEANING_LOOKUP ||g_chr_newline||l_space;

           l_source_meaning      := REPLACE(l_source_meaning,'$index$',l_source_num);

           l_source_meaning      := REPLACE(l_source_meaning,'$Idx$',Idx);

        ELSIF p_array_flex_value_set_id.EXISTS(Idx) AND
              p_array_flex_value_set_id(Idx) IS NOT NULL THEN

           l_source_meaning     := l_source_meaning || C_SOURCE_MEANING_VALSET ||g_chr_newline||l_space;

           l_source_meaning      := REPLACE(l_source_meaning,'$index$',l_source_num);

           l_source_meaning      := REPLACE(l_source_meaning,'$flex_value_set_id$',p_array_flex_value_set_id(Idx));

           l_source_meaning      := REPLACE(l_source_meaning,'$tab$', p_array_table_hash(p_array_table_index(Idx)));

           l_source_meaning      := REPLACE(l_source_meaning,'$source_code$',
                                           p_array_source_code(p_array_source_index(Idx)));

           l_source_meaning      := REPLACE(l_source_meaning,'$source_type_code$',
                                           p_array_source_type_code(p_array_source_index(Idx)));

           l_source_meaning      := REPLACE(l_source_meaning,'$source_application_id$',
                                           p_array_application_id(p_array_source_index(Idx)));

        ELSE
           null;
        END IF;

        --
     END IF;
--
 END LOOP;
--
END IF;
--

   --


IF l_source_num > 0 THEN

      IF p_level = C_HEADER AND p_procedure = 'EVENT_TYPE' THEN

         l_sql_statement      := C_INSERT_HDR_SOURCES_EVT;

      ELSIF p_level = C_HEADER AND p_procedure = 'EVENT_CLASS' THEN

         l_sql_statement      := C_INSERT_HDR_SOURCES_CLASS;

      ELSIF p_level = C_LINE AND p_procedure = 'EVENT_TYPE' THEN

         l_sql_statement      := C_INSERT_LINE_SOURCES_EVT;

      ELSE

         l_sql_statement      := C_INSERT_LINE_SOURCES_CLASS;

      END IF;

-- Bugfix 4417664 (replace REPLACE with replace_token)

      l_sql_statement      := xla_cmp_string_pkg.replace_token(l_sql_statement,'$source_number$'        ,nvl(TO_CHAR(l_source_num),' '));
      l_sql_statement      := xla_cmp_string_pkg.replace_token(l_sql_statement,'$line_number$'          ,nvl(TO_CHAR(l_line_number),' '));
      l_sql_statement      := xla_cmp_string_pkg.replace_token(l_sql_statement,'$object_name$'          ,nvl(l_object_name,' '));
      l_sql_statement      := xla_cmp_string_pkg.replace_token(l_sql_statement,'$object_type_code$'     ,nvl(l_object_type_code ,' '));
      l_sql_statement      := xla_cmp_string_pkg.replace_token(l_sql_statement,'$source_application_id$',nvl(l_source_appl_id,' '));
      l_sql_statement      := xla_cmp_string_pkg.replace_token(l_sql_statement,'$source_type_code$'     ,nvl(l_source_type_code,' '));
      l_sql_statement      := xla_cmp_string_pkg.replace_token(l_sql_statement,'$source_code$'          ,nvl(l_source_code,' '));
      l_sql_statement      := xla_cmp_string_pkg.replace_token(l_sql_statement,'$source_value$'         ,nvl(l_source_value,' '));
      IF l_source_meaning IS NOT NULL THEN
--
         l_sql_statement   := REPLACE(l_sql_statement,'$source_meaning$'    ,C_MEANING_NOT_NULL);
         l_sql_statement   := REPLACE(l_sql_statement,'$source_meaning$'    ,nvl(l_source_meaning,' '));
      ELSE
         l_sql_statement   := xla_cmp_string_pkg.replace_token(l_sql_statement,'$source_meaning$'    ,C_MEANING_NULL);
      END IF;

ELSE
      l_sql_statement      :=' ';

END IF;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateInsertStm'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_sql_statement;
EXCEPTION
 WHEN VALUE_ERROR THEN

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR '||sqlerrm
               ,p_level    => C_LEVEL_UNEXPECTED
               ,p_module   => l_log_module);
   END IF;

   RAISE;
 WHEN xla_exceptions_pkg.application_exception  THEN
    RETURN NULL;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateInsertStm ');
END GenerateInsertStm;
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC function                                                          |
--|                                                                          |
--|    Generate the INSERT SQL statement used by the Extract Source Values   |
--|    Dump to insert the header source values into xla_diag_sources         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateInsertHdrSources  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_table_type             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_vl1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_vl2000
--
, p_array_h_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_h_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_h_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_application_id         IN xla_cmp_source_pkg.t_array_Num
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_type_code       IN xla_cmp_source_pkg.t_array_VL1
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
--
, p_procedure                    IN VARCHAR2
)
RETURN CLOB
IS
--
l_sql_statement                CLOB;
l_log_module                   VARCHAR2(240);
--
l_array_source_index          xla_cmp_source_pkg.t_array_ByInt;
l_array_table_index           xla_cmp_source_pkg.t_array_ByInt;
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateInsertHdrSources';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateInsertHdrSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF NVL(p_array_h_source_index.COUNT,0) > 0 THEN

   FOR Idx IN p_array_h_source_index.FIRST .. p_array_h_source_index.LAST LOOP

       IF p_array_h_source_index.EXISTS(Idx) THEN

          l_array_source_index(Idx) := p_array_h_source_index(Idx);
          l_array_table_index(Idx)  := p_array_h_table_index(Idx);

       END IF;

   END LOOP;

END IF;

IF NVL(p_array_h_mls_source_index.COUNT,0)> 0 THEN

   FOR Idx IN p_array_h_mls_source_index.FIRST .. p_array_h_mls_source_index.LAST LOOP

       IF p_array_h_mls_source_index.EXISTS(Idx) THEN

          l_array_source_index(Idx) := p_array_h_mls_source_index(Idx);
          l_array_table_index(Idx)  := p_array_h_mls_table_index(Idx);

       END IF;

   END LOOP;

END IF;

IF NVL(p_array_h_source_index.COUNT,0)+ NVL(p_array_h_mls_source_index.COUNT,0) > 0 THEN

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'CALL GenerateInsertStm()'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

  END IF;

  l_sql_statement := GenerateInsertStm(
                           p_array_table_name             => p_array_table_name
                         , p_array_table_type             => p_array_table_type
                         , p_array_table_index            => l_array_table_index
                         , p_array_table_hash             => p_array_table_hash
                         , p_array_ref_obj_flag           => p_array_ref_obj_flag
                         , p_array_populated_flag         => p_array_populated_flag

                         --
                         , p_array_source_index           => l_array_source_index
                         , p_array_source_code            => p_array_source_code
                         , p_array_application_id         => p_array_application_id
                         , p_array_source_type_code       => p_array_source_type_code
                         , p_array_flex_value_set_id      => p_array_flex_value_set_id
                         , p_array_lookup_type            => p_array_lookup_type
                         , p_array_view_application_id    => p_array_view_application_id
                         --
                         , p_level                        => C_HEADER
                         , p_procedure                    => p_procedure
                        );

-- Bugfix 4417664
   l_sql_statement := xla_cmp_string_pkg.replace_token( l_sql_statement,'$hdr_tabs$',
                                nvl(GenerateFromHdrTabs  (
                                --
                                  p_array_table_name
                                , p_array_parent_table_index
                                , p_array_table_hash
                                , p_array_populated_flag
                                --
                                , p_array_ref_obj_flag
                                --
                                , p_array_h_source_index
                                , p_array_h_table_index
                                --
                                , p_array_h_mls_source_index
                                , p_array_h_mls_table_index
                                --
                                , p_array_source_code
                                , p_array_lookup_type
                                , p_array_view_application_id
                                ), ' ')
                              );


   l_sql_statement := xla_cmp_string_pkg.replace_token( l_sql_statement,'$hdr_clauses$',
                                nvl(GenerateHdrWhereClause  (
                                --
                                  p_array_table_name
                                , p_array_parent_table_index
                                , p_array_table_hash
                                , p_array_populated_flag
                                --
                                , p_array_ref_obj_flag
                                , p_array_join_condition
                                --
                                , p_array_h_source_index
                                , p_array_h_table_index
                                --
                                , p_array_h_mls_source_index
                                , p_array_h_mls_table_index
                                --
                                , p_array_source_code
                                , p_array_lookup_type
                                , p_array_view_application_id
                                ),' ')
                                );

ELSE

  l_sql_statement := ' ';

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateInsertHdrSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_sql_statement;
EXCEPTION
 WHEN VALUE_ERROR THEN

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR '||sqlerrm
               ,p_level    => C_LEVEL_UNEXPECTED
               ,p_module   => l_log_module);
   END IF;

   RAISE;
 WHEN xla_exceptions_pkg.application_exception   THEN
   RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateInsertHdrSources ');
END GenerateInsertHdrSources;

--+==========================================================================+
--|                                                                          |
--| PUBLIC function                                                          |
--|                                                                          |
--|    Generate the INSERT SQL statement used by the Extract Source Values   |
--|    Dump to insert the line source values into xla_diag_sources           |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION GenerateInsertLineSources  (
--
  p_array_table_name             IN xla_cmp_source_pkg.t_array_VL30
, p_array_parent_table_index           IN xla_cmp_source_pkg.t_array_ByInt
, p_array_table_hash             IN xla_cmp_source_pkg.t_array_VL30
, p_array_table_type             IN xla_cmp_source_pkg.t_array_VL30
, p_array_populated_flag         IN xla_cmp_source_pkg.t_array_VL1
--
, p_array_ref_obj_flag           IN xla_cmp_source_pkg.t_array_VL1
, p_array_join_condition         IN xla_cmp_source_pkg.t_array_VL2000
--
, p_array_l_source_index         IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_table_index          IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_l_mls_source_index     IN xla_cmp_source_pkg.t_array_ByInt
, p_array_l_mls_table_index      IN xla_cmp_source_pkg.t_array_ByInt
--
, p_array_application_id         IN xla_cmp_source_pkg.t_array_Num
, p_array_source_code            IN xla_cmp_source_pkg.t_array_VL30
, p_array_source_type_code       IN xla_cmp_source_pkg.t_array_VL1
, p_array_flex_value_set_id      IN xla_cmp_source_pkg.t_array_Num
, p_array_lookup_type            IN xla_cmp_source_pkg.t_array_VL30
, p_array_view_application_id    IN xla_cmp_source_pkg.t_array_Num
--
,p_procedure                     IN VARCHAR2
)
RETURN CLOB
IS
--
l_sql_statement                CLOB;
l_log_module                   VARCHAR2(240);
--
l_array_source_index          xla_cmp_source_pkg.t_array_ByInt;
l_array_table_index           xla_cmp_source_pkg.t_array_ByInt;
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateInsertLineSources';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateInsertLineSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--

IF NVL(p_array_l_source_index.COUNT,0) > 0 THEN

   FOR Idx IN p_array_l_source_index.FIRST .. p_array_l_source_index.LAST LOOP

       IF p_array_l_source_index.EXISTS(Idx) THEN

          l_array_source_index(Idx) := p_array_l_source_index(Idx);
          l_array_table_index(Idx)  := p_array_l_table_index(Idx);

       END IF;

   END LOOP;

END IF;

IF NVL(p_array_l_mls_source_index.COUNT,0)> 0 THEN

   FOR Idx IN p_array_l_mls_source_index.FIRST .. p_array_l_mls_source_index.LAST LOOP

       IF p_array_l_mls_source_index.EXISTS(Idx) THEN

          l_array_source_index(Idx) := p_array_l_mls_source_index(Idx);
          l_array_table_index(Idx)  := p_array_l_mls_table_index(Idx);

       END IF;

   END LOOP;

END IF;

IF NVL(p_array_l_source_index.COUNT,0)+
   NVL(p_array_l_mls_source_index.COUNT,0)> 0 THEN

   l_sql_statement := GenerateInsertStm(
                           p_array_table_name             => p_array_table_name
                         , p_array_table_type             => p_array_table_type
                         , p_array_table_index            => l_array_table_index
                         , p_array_table_hash             => p_array_table_hash
                         , p_array_ref_obj_flag           => p_array_ref_obj_flag
                         , p_array_populated_flag         => p_array_populated_flag
                         --
                         , p_array_source_index           => l_array_source_index
                         , p_array_source_code            => p_array_source_code
                         , p_array_application_id         => p_array_application_id
                         , p_array_source_type_code       => p_array_source_type_code
                         , p_array_flex_value_set_id      => p_array_flex_value_set_id
                         , p_array_lookup_type            => p_array_lookup_type
                         , p_array_view_application_id    => p_array_view_application_id
                         --
                         , p_level                        => C_LINE
                         , p_procedure                    => p_procedure
                        );

-- Bugfix 4417664
   l_sql_statement := xla_cmp_string_pkg.replace_token( l_sql_statement,'$line_tabs$',
                                      nvl(GenerateFromLineTabs  (
                                      --
                                        p_array_table_name
                                      , p_array_parent_table_index
                                      , p_array_table_hash
                                      , p_array_populated_flag
                                      --
                                      , p_array_ref_obj_flag
                                      --
                                      , p_array_l_source_index
                                      , p_array_l_table_index
                                      --
                                      , p_array_l_mls_source_index
                                      , p_array_l_mls_table_index
                                      --
                                      , p_array_source_code
                                      , p_array_lookup_type
                                      , p_array_view_application_id
                                      ),' ')
                                     );

   l_sql_statement := xla_cmp_string_pkg.replace_token( l_sql_statement,'$line_clauses$',
                                     nvl(GenerateLineWhereClause  (
                                     --
                                       p_array_table_name
                                     , p_array_parent_table_index
                                     , p_array_table_hash
                                     , p_array_populated_flag
                                     --
                                     , p_array_ref_obj_flag
                                     , p_array_join_condition
                                     --
                                     , p_array_l_source_index
                                     , p_array_l_table_index
                                     --
                                     , p_array_l_mls_source_index
                                     , p_array_l_mls_table_index
                                     --
                                     , p_array_source_code
                                     , p_array_lookup_type
                                     , p_array_view_application_id
                                     ),' ')
                                  );


ELSE

  l_sql_statement := ' ';

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GenerateInsertLineSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_sql_statement;
EXCEPTION
 WHEN VALUE_ERROR THEN

   IF (C_LEVEL_UNEXPECTED >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR '||sqlerrm
               ,p_level    => C_LEVEL_UNEXPECTED
               ,p_module   => l_log_module);
   END IF;

   RAISE;

 WHEN xla_exceptions_pkg.application_exception   THEN
        RAISE;
 WHEN OTHERS    THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_extract_pkg.GenerateInsertLineSources ');
END GenerateInsertLineSources;





--
--=============================================================================
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--=============================================================================
--=============================================================================
--          *********** Initialization routine **********
--=============================================================================

BEGIN

   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
--
END xla_cmp_extract_pkg;

/
