--------------------------------------------------------
--  DDL for Package Body XLA_ACCOUNTING_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCOUNTING_ENGINE_PKG" AS
/* $Header: xlajeaex.pkb 120.87.12010000.6 2010/01/20 09:45:59 pshukla ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_accounting_engine_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema    Created                                      |
|     09-DEC-2002 K.Boussema    Added Call to Validation API                 |
|     10-JAN-2003 K.Boussema    Added 'dbdrv' command                        |
|     20-FEB-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     28-APR-2003 K.Boussema    Added validation of PAD retrieved            |
|     06-MAI-2003 K.Boussema    Added the update of event status, bug2936071 |
|     07-MAI-2003 K.Boussema    Changed the call to cache API, bug 2945359   |
|     16-MAI-2003 K.Boussema    Changed the call of InsertJournalEntries,    |
|                               bug 2963366                                  |
|     03-JUN-2003 K.Boussema    Capture the uncompiled PADs, bug 2963448     |
|     13-JUN-2003 K.Boussema    Changed the error message, bug 2963448       |
|     17-JUL-2003 K.Boussema    Modified the update of events, bug 3051978   |
|                               Updated the call to accounting cache, 3055039|
|     21-JUL-2003 K.Boussema    Reviewed the call to GetSessionValueChar API |
|     22-JUL-2003 K.Boussema    Added the update of journal entries          |
|     29-JAN-2003 K.Boussema    Reviewed the code to solve bug 3072881       |
|     01-AUG-2003 K.Boussema    Modified according to recommendation in bug  |
|                               3076645                                      |
|     27-AUG-2003 K.Boussema    Reviewed the code according to bug 3084324   |
|     03-SEP-2003 K.Boussema    Changed to fix bug 3125028                   |
|     23-OCT-2003 K.Boussema    Changed to fix issue raise in bug 3209099    |
|     17-NOV-2003 K.Boussema    Changed the call to validation routine       |
|                               xla_je_validation_pkg.balance_amounts,3233969|
|     21-NOV-2003 K.Boussema    Revised message XLA_AP_PAD_INACTIVE,bg3266350|
|     01-DEC-2003 K.Boussema    Added InitExtractErrors, CacheExtractErrors, |
|                               BuildExtractErrors to validate the extract   |
|     03-FEB-2004 K.Boussema    Added the extract object name and level in   |
|                               extract error message.                       |
|                               Added CacheExtractObject proc. and changed   |
|                               CacheExtractErrors procedure                 |
|     04-FEB-2004 K.Boussema    Removed the token LEDGER_NAME from message   |
|                               XLA_AP_INV_PAD_SETUP, bug 3320707            |
|     12-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     11-MAY-2004 K.Boussema    Removed the call to XLA trace routine from   |
|                                 trace() procedure                          |
|     17-MAY-2004 W.Shen        change SubmitAccountingEngine for accounting |
|                                 attribute enhancement project              |
|     26-Jul-2004 W. Shen       Add a new parameter to CacheExtractErrors    |
|                                 if it is called from transaction reversal  |
|                                 The line count is 0 or null is not treated |
|                                 as an error.                               |
|                                 bug 3786968.                               |
|     23-Sep-2004 S.Singhania   Made changes for the bulk peroformance.It has|
|                                 changed the code at number of places.      |
|     05-Oct-2004 S.Singhania   Bug 3931752: Added code to remove dummy rows |
|                                 from XLA_AE_LINES_GT and XLA_AE_HEADERS_GT |
|                                 (rows with balance_type_code = 'X') in     |
|                                 PostAccountingEngine                       |
|     08-Oct-2004 S.Singhania   Bug 3928357: Made changes to make sure the   |
|                                 following cases are handled:               |
|                                 - Mark events in error when AAD is invalid |
|                                 - Mark events in error when AAD is missing |
|                                 Following routines are modified:           |
|                                 - SubmitAccountingEngine                   |
|                                 - CatchErr_UncompliedAAD                   |
|                                 - PostAccountingEngine                     |
|                                 Following new routine is added:            |
|                                 - CatchErr_MissingAAD                      |
|     21-Oct-2004 S.Singhania   Bug 3962951. Modified PostAccounting. Update |
|                                 statement to update event status in        |
|                                 xla_events_gt is  modified.                |
|                               Added one update statement on xla_events_gt  |
|                                 to update the event status to ERROR for the|
|                                 case where validation in AccoutningRevesal |
|                                 fails.                                     |
|     02-Nov-2004 K.Boussema    Changed for Diagnostic Framework. Included   |
|                                the set of gobal variable g_diagnostics_mode|
|     16-Dec-2004 S.Singhania   Bug 4056420. Performance changes made in:    |
|                                 - PostAccounting                           |
|                               Fixed GSCC warning File.Sql.35 in TRACE.     |
|     9-Mar-2005  W. SHen       Ledger Currency Project                      |
|                                 add call to                                |
|                                 XLA_AE_LINES_PKG.CalculateUnroundedAmounts |
|                                 XLA_AE_LINES_PKG.CalculateGainLossAmounts  |
|                                 XLA_AE_LINES_PKG.adjust_display_line_num   |
|     14-Mar-2005 K.Boussema Changed for ADR-enhancements.                   |
|     25-May-2005  W. SHen       remove call                                 |
|                                    XLA_AE_LINES_PKG.adjust_display_line_num|
|     17-Jun-2005  W. SHen       add call UpdateRelatedErrorsStatus back     |
|                                    bug 4155511                             |
|     24-Jun-2005  W. Chan      Fix bug4092230 - Add ValidateCompleteAADDefn |
|     11-Jul-2005  A. Wan    Changed for MPA.  4262811                       |
|     12-Jul-2005  W. Chan   Fix bug 4480650 - fix  ValidateCompleteAADDefn  |
|     01-Aug-2005 W. Chan     4458381 - Public Sector Enhancement            |
|     27-Dec-2005 A.Wan       4669308 - DeleteIncompleteMPA                  |
|     20-Jan-2006 W.Chan      4946123 - BC changes for prior entry           |
|     24-Jan-2006 A.Wan       4884853 - modify PostAccountingEngine when     |
|                                       rollover MPA/Accrual Reversal date.  |
|     27-Apr-2006 A.Wan       5095554 - performance fix for non-mergable view|
|                                       xla_subledger_options_v              |
|     02-May-2006 A.Wan       5054831  Moved check CatchErr_UncompliedAAD to |
|                                      xla_accounting_pkg.ValidateAAD        |
|     28-Jul-2006 A.Wan       5357406 - add p_ledger_id in PostAcctingEngine |
|                                       when calling bflow prior entry API.  |
|     18-DEC-2009 VGOPISET    9086275  ORDER BY EVENT_STATUS_CODE to be used |
|                                   to update EVENTS_GT process_status_code  |
|     13-JAN-2010 VGOPISET    9245677  Avoid Calling Non-BC AAD while the    |
|                                   accounting is for BC Accounting.         |
+===========================================================================*/
--
/*======================================================================+
|                                                                       |
| CONSTANTS                                                             |
|                                                                       |
|                                                                       |
+======================================================================*/
--
C_FINAL          CONSTANT     VARCHAR2(1) := 'F';
C_UNPROCESSED    CONSTANT     VARCHAR2(1) := 'U';
C_ERROR          CONSTANT     VARCHAR2(1) := 'E';
C_PROCESSED      CONSTANT     VARCHAR2(1) := 'P';
C_DRAFT          CONSTANT     VARCHAR2(1) := 'D';
C_INVALID        CONSTANT     VARCHAR2(1) := 'I';
C_RELATED        CONSTANT     VARCHAR2(1) := 'R';
C_EVT_RELATED    CONSTANT     VARCHAR2(1) := 'R';
C_AE_EVT_RELATED CONSTANT     VARCHAR2(30):= 'RELATED_EVENT_ERROR';

--
--
C_UNPROCESSED_ENTRIES   CONSTANT  NUMBER:= -1;
C_NO_ENTRIES            CONSTANT  NUMBER:=  2;
C_INVALID_ENTRIES       CONSTANT  NUMBER:=  1;
C_VALID_ENTRIES         CONSTANT  NUMBER:=  0;
--
--
C_EXTRACT_INVALID       CONSTANT VARCHAR2(1) := 'N';
C_EXTRACT_VALID         CONSTANT VARCHAR2(1) := 'Y';
--
--
C_DRAFT_STATUS          CONSTANT VARCHAR2(1)   := 'D';
C_FINAL_STATUS          CONSTANT VARCHAR2(1)   := 'F';
--
--
/*======================================================================+
|                                                                       |
| STRUCTURES                                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
--
--
TYPE t_rec_array_event IS RECORD
   (array_legal_entity_id                xla_ae_journal_entry_pkg.t_array_Num
   ,array_entity_id                      xla_ae_journal_entry_pkg.t_array_Num
   ,array_entity_code                    xla_ae_journal_entry_pkg.t_array_V30L
   ,array_transaction_num                xla_ae_journal_entry_pkg.t_array_V240L
   ,array_event_id                       xla_ae_journal_entry_pkg.t_array_Num
   ,array_class_code                     xla_ae_journal_entry_pkg.t_array_V30L
   ,array_event_type                     xla_ae_journal_entry_pkg.t_array_V30L
   ,array_event_number                   xla_ae_journal_entry_pkg.t_array_Num
   ,array_event_date                     xla_ae_journal_entry_pkg.t_array_Date
   ,array_reference_num_1                xla_ae_journal_entry_pkg.t_array_Num
   ,array_reference_num_2                xla_ae_journal_entry_pkg.t_array_Num
   ,array_reference_num_3                xla_ae_journal_entry_pkg.t_array_Num
   ,array_reference_num_4                xla_ae_journal_entry_pkg.t_array_Num
   ,array_reference_char_1               xla_ae_journal_entry_pkg.t_array_V240L
   ,array_reference_char_2               xla_ae_journal_entry_pkg.t_array_V240L
   ,array_reference_char_3               xla_ae_journal_entry_pkg.t_array_V240L
   ,array_reference_char_4               xla_ae_journal_entry_pkg.t_array_V240L
   ,array_reference_date_1               xla_ae_journal_entry_pkg.t_array_Date
   ,array_reference_date_2               xla_ae_journal_entry_pkg.t_array_Date
   ,array_reference_date_3               xla_ae_journal_entry_pkg.t_array_Date
   ,array_reference_date_4               xla_ae_journal_entry_pkg.t_array_Date
   ,array_event_created_by               xla_ae_journal_entry_pkg.t_array_V100L
   );
--
--
--
TYPE t_rec_error IS RECORD
(
entity_id                           NUMBER,
event_id                            NUMBER,
ledger_id                           NUMBER,
object_name                   VARCHAR2(30),
object_level                  VARCHAR2(30),
event_class                  VARCHAR2(240)
)
;

TYPE t_array_error    IS TABLE OF  t_rec_error INDEX BY BINARY_INTEGER;

/*======================================================================+
|                                                                       |
| Global variables                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
g_array_error_flag               xla_ae_journal_entry_pkg.t_array_V1L;
g_array_error_cache              t_array_error;
g_event_err_Index                BINARY_INTEGER;
g_hdr_rowcount                   NUMBER ;
g_line_rowcount                  NUMBER ;
--
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_accounting_engine_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER
       ,p_module                     IN VARCHAR2) IS
BEGIN

   ----------------------------------------------------------------------------
   -- Following is for FND log.
   ----------------------------------------------------------------------------
   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
      fnd_log.message(p_level, NVL(p_module,C_DEFAULT_MODULE));
   ELSIF p_level >= g_log_level THEN
      fnd_log.string(p_level, NVL(p_module,C_DEFAULT_MODULE), p_msg);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_accounting_engine_pkg.trace');
END trace;
--
--====================================================================
--
--
--
--
-- Forward declaration of local routines
--
--
--
--
--=====================================================================
--
PROCEDURE UpdateRelatedErrorsStatus
;
--
FUNCTION PostAccountingEngine(p_application_id                 IN NUMBER
                             ,p_accounting_batch_id            IN NUMBER
                             ,p_ledger_id                      IN NUMBER
                             ,p_end_date                       IN DATE    -- 4262811
                             ,p_accounting_mode                IN VARCHAR2
                             ,p_min_event_date                 IN DATE
                             ,p_max_event_date                 IN DATE
                             ,p_budgetary_control_mode         IN VARCHAR2)
RETURN NUMBER
;
--
FUNCTION RunPAD (
                      p_application_id         IN NUMBER
                    , p_base_ledger_id         IN NUMBER
                    , p_pad_package            IN VARCHAR2
                    , p_pad_start_date         IN DATE
                    , p_pad_end_date           IN DATE
                    , p_primary_ledger_id      IN NUMBER
                    , p_budgetary_control_mode IN VARCHAR2)
RETURN NUMBER
;
--
FUNCTION SubmitAccountingEngine (
                    p_application_id         IN NUMBER
                  , p_ledger_id              IN NUMBER
                  , p_accounting_mode        IN VARCHAR2
                  , p_budgetary_control_mode IN VARCHAR2
                  , p_accounting_batch_id    IN NUMBER
                  , p_min_event_date         IN OUT NOCOPY DATE
                  , p_max_event_date         IN OUT NOCOPY DATE
                  )
RETURN NUMBER
;

PROCEDURE CatchErr_UncompliedAAD
       (p_ledger_id         IN NUMBER
       ,p_min_date          IN DATE
       ,p_max_date          IN DATE
       ,p_aad_name          IN VARCHAR2
       ,p_aad_owner         IN VARCHAR2
       ,p_slam_name         IN VARCHAR2);

PROCEDURE CatchErr_MissingAAD
       (p_ledger_id                 IN NUMBER
       ,p_min_aad_start_date        IN DATE
       ,p_max_aad_end_date          IN DATE
       ,p_min_event_date            IN VARCHAR2
       ,p_max_event_date            IN VARCHAR2
       ,p_slam_name                 IN VARCHAR2);

--
--====================================================================
--
--
--
--
--  logic to trap the extract error messages
--
--
--
--
--=====================================================================
--
/*======================================================================+
|                                                                       |
| PUBLIC Procedure                                                      |
|                                                                       |
|    CacheExtractErrors                                                 |
|                                                                       |
+======================================================================*/
--
PROCEDURE CacheExtractErrors(
                             p_hdr_rowcount      IN NUMBER
                            ,p_line_rowcount     IN NUMBER
                            ,p_trx_reversal_flag IN VARCHAR2
                           )
IS
--
Idx                                BINARY_INTEGER;
l_array_error_cache                t_array_error;
l_log_module                       VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CacheExtractErrors';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of CacheExtractErrors'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_hdr_rowcount = '||p_hdr_rowcount
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_line_rowcount = '||p_line_rowcount
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
--
g_hdr_rowcount        := g_hdr_rowcount  + NVL(p_hdr_rowcount,0)  ;
g_line_rowcount       := g_line_rowcount + NVL(p_line_rowcount,0) ;
--
IF g_hdr_rowcount > 0 AND (g_line_rowcount > 0 or
          (g_line_rowcount = 0 and nvl(p_trx_reversal_flag, 'N') = 'Y'))THEN

    g_array_error_flag(g_event_err_Index) := C_EXTRACT_VALID;
    g_array_error_cache                   := l_array_error_cache;

ELSE -- g_hdr_rowcount = 0 or g_line_rowcount  = 0

   CASE  g_array_error_flag(g_event_err_Index)

       WHEN C_EXTRACT_VALID THEN  null;

       ELSE       -- null or C_EXTRACT_INVALID

           g_array_error_flag(g_event_err_Index)     := C_EXTRACT_INVALID;

  END CASE;
--
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of CacheExtractErrors'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
                (p_location => 'xla_accounting_engine_pkg.CacheExtractErrors');
   --
END CacheExtractErrors;
--
--
/*======================================================================+
|                                                                       |
| PUBLIC Procedure                                                      |
|                                                                       |
|    CacheExtractObject                                                 |
|                                                                       |
|    Important: this procedure must be called after CacheExtractErrors  |
+======================================================================*/
--
PROCEDURE CacheExtractObject(
                             p_object_name    IN VARCHAR2
                           , p_object_level   IN VARCHAR2
                           , p_event_class    IN VARCHAR2
                           , p_entity_id      IN NUMBER
                           , p_event_id       IN NUMBER
                           , p_ledger_id      IN NUMBER
                           )
IS
--
Idx                                BINARY_INTEGER;
l_array_error_cache                t_array_error;
l_log_module                       VARCHAR2(240);
--
BEGIN
--
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CacheExtractObject';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of CacheExtractObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
--
IF g_array_error_flag.EXISTS(g_event_err_Index) AND
   NVL(g_array_error_flag(g_event_err_Index),C_EXTRACT_VALID)= C_EXTRACT_INVALID
THEN
           --
           -- cache extract object
           --
           Idx := NVL(g_array_error_cache.LAST,0) + 1;
           --
           g_array_error_cache(Idx).entity_id      := p_entity_id;
           g_array_error_cache(Idx).event_id       := p_event_id;
           g_array_error_cache(Idx).ledger_id      := p_ledger_id;
           g_array_error_cache(Idx).object_name    := p_object_name;
           g_array_error_cache(Idx).object_level   := p_object_level;
           g_array_error_cache(Idx).event_class    := p_event_class;

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of CacheExtractObject'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
                (p_location => 'xla_accounting_engine_pkg.CacheExtractObject');
END CacheExtractObject;

--
/*======================================================================+
|                                                                       |
| PRIVATE Procedure                                                     |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE UpdateRelatedErrorsStatus
IS
l_log_module         VARCHAR2(240);

-- this cursor find all the entity_id which has both error and no-error event
-- so that we can set all the no-error event to related-error status
/*
CURSOR c_related_events is
  SELECT xeg.entity_id, xeg.event_id
    FROM xla_events_gt xeg
   WHERE xeg.process_status_code = C_EVT_RELATED;

CURSOR c_related_headers is
  SELECT xe.event_id, xah.ae_header_id, xah.ledger_id
    FROM xla_ae_headers xah
         ,xla_events_gt xe
   WHERE xah.event_id           = xe.event_id
     AND xah.application_id     = xe.application_id
     AND xe.process_status_code = C_EVT_RELATED;
*/

l_current_entity_id number:= -1;
l_current_event_number number:=null;
l_current_event_id number;
l_current_header_id number;
l_current_ledger_id number;
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateRelatedErrorsStatus';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of UpdateRelatedErrorsStatus'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
--
-- Add hint as per bug 5529420
--
  UPDATE xla_events_gt xeg
     SET xeg.process_status_code = C_EVT_RELATED
   WHERE xeg.process_status_code in (C_DRAFT, C_PROCESSED)
     AND EXISTS (SELECT /*+ HASH_SJ */ 1
                   FROM xla_events_gt xeg2
                  WHERE xeg2.entity_id = xeg.entity_id
                    AND xeg2.process_status_code in (C_INVALID,
                                     C_ERROR));

/* we decide not to insert the error message for the event
  OPEN c_related_events;
  LOOP
     fetch c_related_events into l_current_entity_id, l_current_entity_id;
     EXIT WHEN c_related_events%NOTFOUND;

     xla_accounting_err_pkg.build_message(
                       p_appli_s_name             => 'XLA'
                      ,p_msg_name                => 'XLA_AP_RELATED_INVALID_EVENT'
                      ,p_entity_id               => l_current_entity_id
                      ,p_event_id                => l_current_event_id
                      ,p_ledger_id               => null
                      ,p_ae_header_id            => null
                      ,p_ae_line_num             => null
                      ,p_accounting_batch_id     => null
                   );

  END LOOP;
  close c_related_events;
*/

  /* update related entry status */
  UPDATE xla_ae_headers xah
     SET xah.accounting_entry_status_code = C_AE_EVT_RELATED
         -- Bug 5056632. update group_id to NULL if entry is in error
        ,group_id                         = NULL
   WHERE xah.event_id in
             (SELECT xe.event_id
                FROM xla_events_gt xe
               WHERE xe.process_status_code = C_EVT_RELATED );

/*
  OPEN c_related_headers;
  LOOP
    FETCH c_related_headers into l_current_event_id,
                      l_current_header_id, l_current_ledger_id;
    EXIT WHEN c_related_headers%NOTFOUND;

    xla_accounting_err_pkg.build_message(
                   p_appli_s_name             => 'XLA'
                  ,p_msg_name                => 'XLA_AP_JE_RELATED_INVALID_EVT'
                  ,p_entity_id               => l_current_entity_id
                  ,p_event_id                => l_current_event_id
                  ,p_ledger_id               => l_current_ledger_id
                  ,p_ae_header_id            => l_current_header_id
               );

  END LOOP;
  close c_related_headers;
*/

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of UpdateRelatedErrorsStatus'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
                (p_location => 'xla_accounting_engine_pkg.UpdateRelatedErrorsStatus');
   --
END UpdateRelatedErrorsStatus;


/*======================================================================+
|                                                                       |
| PRIVATE Procedure                                                     |
|                                                                       |
|    DeleteIncompleteMPA  - 4669308                                     |
|                                                                       |
|  Delete incomplete MPA after all the validation checks taken place,   |
|  and the deletion should take place only for FINAL mode.              |
|  Since the reversal of the original entry could result in invalid     |
|  status after various validation (eg CCID, GL period).  So do not     |
|  delete the incomplete entries unless it is FINAL. This way we can    |
|  allow user to correct any error before deleting the incomplete MPA.  |
|  And also, once the incomplete MPA is deleted, it cannot be recreated.|
|                                                                       |
+======================================================================*/
PROCEDURE DeleteIncompleteMPA(p_application_id       IN NUMBER)
IS

   l_log_module               VARCHAR2(240);
   l_array_LR_incomplete_mpa  XLA_AE_JOURNAL_ENTRY_PKG.t_array_ae_header_id;
   l_array_LR_ledger_id       xla_accounting_cache_pkg.t_array_ledger_id;
   l_array_LR_entity_id       xla_ae_journal_entry_pkg.t_array_Num;
   l_array_TR_incomplete_mpa  XLA_AE_JOURNAL_ENTRY_PKG.t_array_ae_header_id;
   l_array_TR_ledger_id       xla_accounting_cache_pkg.t_array_ledger_id;
   l_array_TR_entity_id       xla_ae_journal_entry_pkg.t_array_Num;


BEGIN
   --
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.DeleteIncompleteMPA';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of DeleteIncompleteMPA'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => '#Line reversal lines = '||xla_ae_lines_pkg.g_incomplete_mpa_acc_LR.l_array_ae_header_id.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => '#Tran reversal lines = '||xla_ae_lines_pkg.g_incomplete_mpa_acc_TR.l_array_ae_header_id.COUNT
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
   --

   ------------------------------
   -- Line Reversal
   ------------------------------
   FOR i in 1..xla_ae_lines_pkg.g_incomplete_mpa_acc_LR.l_array_ae_header_id.COUNT LOOP      -- 5108415

      ------------------------------------------------------------------------------------
      --  Find incomplete MPA entries whose original/parent has been reversed
      ------------------------------------------------------------------------------------

      SELECT distinct xeh3.ae_header_id, xeh3.ledger_id, xeh3.entity_id
      BULK COLLECT INTO  l_array_LR_incomplete_mpa, l_array_LR_ledger_id, l_array_LR_entity_id
      FROM   xla_ae_headers         xeh1  -- reversal of original entry
            ,xla_distribution_links xdl2  -- reversal of original entry
            ,xla_ae_headers         xeh3  -- incomplete MPA entries
            ,xla_ae_headers         xeh4  -- original entries
            --------------------------------------------------------------
            -- Find the original/parent
            --------------------------------------------------------------
      WHERE  xeh4.ae_header_id            = xla_ae_lines_pkg.g_incomplete_mpa_acc_LR.l_array_parent_ae_header(i) -- 5108415
      AND    xeh4.application_id          = p_application_id
      AND    xdl2.application_id          = p_application_id
      AND    xdl2.ref_ae_header_id        = xeh4.ae_header_id           -- original's ae_header_id
      AND    xdl2.ref_event_id            = xeh4.event_id
            --------------------------------------------------------------
            -- Check this is a reversal of original entry
            --------------------------------------------------------------
      AND    xeh1.application_id          = p_application_id
      AND    xeh1.ae_header_id            = xdl2.ae_header_id
      AND    xeh1.event_id                = xdl2.event_id
      AND    xdl2.ref_temp_line_num is not null
      AND    xdl2.ref_temp_line_num       = -1 * xdl2.temp_line_num
      AND    xeh1.accounting_entry_status_code = 'F'                    --  FINAL and without errors !!!!!
            --------------------------------------------------------------
            -- Determine this is a incomplete MPA with same orginal/parent
            --------------------------------------------------------------
      AND    xeh3.application_id               = p_application_id
      AND    xeh3.ae_header_id                 = xla_ae_lines_pkg.g_incomplete_mpa_acc_LR.l_array_ae_header_id(i) -- 5108415
      AND    xeh3.parent_ae_header_id          = xeh4.ae_header_id
      AND    xeh3.event_id                     = xeh4.event_id
      AND    xeh3.accounting_entry_status_code <> 'F'
      ORDER by xeh3.ledger_id, xeh3.entity_id, xeh3.ae_header_id;

  /*
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => '# LR rows incomplete MPA in xla_ae_headers ='||l_array_LR_incomplete_mpa.COUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
          FOR j in 1..l_array_LR_incomplete_mpa.COUNT LOOP
            trace
               (p_msg      => 'MPA ledger='||l_array_LR_ledger_id(j)||
                              ' entity='||l_array_LR_entity_id(j)||
                              ' ae_header='||l_array_LR_incomplete_mpa(j)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
          END LOOP;
      END IF;
*/

      ---------------------------------------------------------------
      --  Delete incomplete MPA entries
      ---------------------------------------------------------------
      FORALL k in 1..l_array_LR_incomplete_mpa.COUNT
         DELETE xla_ae_lines           WHERE application_id = p_application_id AND ae_header_id = l_array_LR_incomplete_mpa(k);
      FORALL l in 1..l_array_LR_incomplete_mpa.COUNT
         DELETE xla_ae_headers         WHERE application_id = p_application_id AND ae_header_id = l_array_LR_incomplete_mpa(l);
      FORALL m in 1..l_array_LR_incomplete_mpa.COUNT
         DELETE xla_distribution_links WHERE application_id = p_application_id AND ae_header_id = l_array_LR_incomplete_mpa(m);

   END LOOP;


   ------------------------------
   -- Transaction Reversal
   ------------------------------
   FOR i in 1..xla_ae_lines_pkg.g_incomplete_mpa_acc_TR.l_array_ae_header_id.COUNT LOOP  -- 5108415
      ------------------------------------------------------------------------------------
      --  Find incomplete MPA entries whose original/parent has been reversed
      ------------------------------------------------------------------------------------
      SELECT distinct xeh3.ae_header_id, xeh3.ledger_id, xeh3.entity_id
      BULK COLLECT INTO  l_array_TR_incomplete_mpa, l_array_TR_ledger_id, l_array_TR_entity_id
      FROM   xla_ae_headers         xeh1  -- reversal of original entry
            ,xla_distribution_links xdl2  -- reversal of original entry
            ,xla_ae_headers         xeh3  -- incomplete MPA entries
            ,xla_ae_headers         xeh4  -- original entries
            --------------------------------------------------------------
            -- Find the original/parent
            --------------------------------------------------------------
      WHERE  xeh4.ae_header_id            = xla_ae_lines_pkg.g_incomplete_mpa_acc_TR.l_array_parent_ae_header(i) -- 5108415
      AND    xeh4.application_id          = p_application_id
      AND    xdl2.application_id          = p_application_id
      AND    xdl2.ref_ae_header_id        = xeh4.ae_header_id           -- original's ae_header_id
      AND    xdl2.ref_event_id            = xeh4.event_id
            --------------------------------------------------------------
            -- Check this is a reversal of original entry
            --------------------------------------------------------------
      AND    xeh1.application_id          = p_application_id
      AND    xeh1.ae_header_id            = xdl2.ae_header_id
      AND    xeh1.event_id                = xdl2.event_id
      AND    xdl2.ref_temp_line_num is not null
      AND    xdl2.ref_temp_line_num       = -1 * xdl2.temp_line_num
      AND    xeh1.accounting_entry_status_code = 'F'                    --  FINAL and without errors !!!!!
            --------------------------------------------------------------
            -- Determine this is a incomplete MPA with same orginal/parent
            --------------------------------------------------------------
      AND    xeh3.application_id               = p_application_id
      AND    xeh3.ae_header_id                 = xla_ae_lines_pkg.g_incomplete_mpa_acc_TR.l_array_ae_header_id(i) -- 5108415
      AND    xeh3.parent_ae_header_id          = xeh4.ae_header_id
      AND    xeh3.event_id                     = xeh4.event_id
      AND    xeh3.accounting_entry_status_code <> 'F'
      ORDER by xeh3.ledger_id, xeh3.entity_id, xeh3.ae_header_id;

 /*
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => '# TR rows incomplete MPA in xla_ae_headers ='||l_array_TR_incomplete_mpa.COUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
          FOR j in 1..l_array_TR_incomplete_mpa.COUNT LOOP
            trace
               (p_msg      => 'MPA ledger='||l_array_TR_ledger_id(j)||
                              ' entity='||l_array_TR_entity_id(j)||
                              ' ae_header='||l_array_TR_incomplete_mpa(j)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
          END LOOP;
      END IF;
*/

      ---------------------------------------------------------------
      --  Delete incomplete MPA entries
      ---------------------------------------------------------------
      FORALL k in 1..l_array_TR_incomplete_mpa.COUNT
         DELETE xla_ae_lines           WHERE application_id = p_application_id AND ae_header_id = l_array_TR_incomplete_mpa(k);
      FORALL l in 1..l_array_TR_incomplete_mpa.COUNT
         DELETE xla_ae_headers         WHERE application_id = p_application_id AND ae_header_id = l_array_TR_incomplete_mpa(l);
      FORALL m in 1..l_array_TR_incomplete_mpa.COUNT
         DELETE xla_distribution_links WHERE application_id = p_application_id AND ae_header_id = l_array_TR_incomplete_mpa(m);

   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'END of DeleteIncompleteMPA'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
   END IF;
   --

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
                (p_location => 'xla_accounting_engine_pkg.DeleteIncompleteMPA');
   --
END DeleteIncompleteMPA;

--
/*======================================================================+
|                                                                       |
| PRIVATE Procedure                                                     |
|                                                                       |
|    ValidateCompleteAADDefn                                            |
|                                                                       |
+======================================================================*/
PROCEDURE ValidateCompleteAADDefn
(p_application_id       INTEGER
,p_ledger_id            INTEGER
,p_min_event_date       DATE
,p_max_event_date       DATE)
IS
CURSOR c IS
SELECT xpa.event_type_code
  FROM xla_prod_acct_headers      xpa,
       (SELECT t1.product_rule_type_code
             , t1.product_rule_code
             , sum(1) over (partition by 1) aad_count
        FROM (SELECT acd.product_rule_type_code
                   , acd.product_rule_code
                   , sum(1) over (partition by subl.application_id) aad_count
             -- FROM xla_subledger_options_v    xso   -- 5095554
                FROM gl_ledgers ledg             -- (1)
                   , gl_ledger_relationships glr -- (2)
                   , xla_ledger_options lopt     -- (4)
                   , xla_subledgers subl          -- (5)
             --    , xla_acctg_methods_b        acm
                   , xla_acctg_method_rules     acd
                   , gl_ledgers                 led
               WHERE subl.application_id = p_application_id
                 --
                 AND   ledg.ledger_id             = glr.target_ledger_id
                 AND    ledg.ledger_id             = lopt.ledger_id
                 AND    subl.application_id        = lopt.application_id
                 AND    ledg.object_type_code      = 'L' /* only ledgers (not ledger sets) */
                 AND    ledg.le_ledger_type_code   = 'L' /* only legal ledgers */
                 AND    ledg.ledger_category_code in ('PRIMARY', 'SECONDARY')
                 AND    glr.application_id         = 101
                 AND    ( (glr.relationship_type_code = 'SUBLEDGER') OR
                          (glr.target_ledger_category_code = 'PRIMARY'
                 AND glr.relationship_type_code = 'NONE'))
                 --
                 AND DECODE(led.ledger_category_code
                               ,'PRIMARY',glr.primary_ledger_id
                               ,ledg.ledger_id)            = p_ledger_id
                 AND DECODE(led.ledger_category_code
                               ,'PRIMARY',DECODE(ledg.ledger_category_code
                                                ,'PRIMARY','Y'
                                                ,'N')
                               ,'Y')                      = lopt.capture_event_flag
                 AND lopt.enabled_flag   = 'Y'
                 AND glr.relationship_enabled_flag    = 'Y'
                 AND led.ledger_id = p_ledger_id
                 AND ledg.sla_accounting_method_code  = acd.accounting_method_code
                 AND ledg.sla_accounting_method_type  = acd.accounting_method_type_code
              -- AND acm.accounting_method_code      = acd.accounting_method_code
              -- AND acm.accounting_method_type_code = acd.accounting_method_type_code
                 AND acd.application_id = p_application_id
                 AND acd.amb_context_code = NVL(fnd_profile.value('XLA_AMB_CONTEXT'),'DEFAULT')
                 AND nvl(acd.start_date_active,p_min_event_date) <= p_min_event_date
                 AND nvl(acd.end_date_active,p_max_event_date) >= p_max_event_date) t1
        GROUP BY t1.product_rule_type_code, t1.product_rule_code) t
 WHERE xpa.product_rule_type_code = t.product_rule_type_code
   AND xpa.product_rule_code      = t.product_rule_code
   AND xpa.amb_context_code       = NVL(fnd_profile.value('XLA_AMB_CONTEXT'),'DEFAULT')
   AND xpa.application_id         = p_application_id
 GROUP BY xpa.event_type_code, aad_count
 HAVING count(*) < aad_count;

CURSOR c_je(x_event_type VARCHAR2) IS
  SELECT entity_id, event_id
    FROM xla_ae_headers_gt
   WHERE event_type_code = x_event_type;

l_array_event_type                 xla_ae_journal_entry_pkg.t_array_V30L;
l_count                            INTEGER;
l_log_module                       VARCHAR2(240);
--
BEGIN
--
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateCompleteAADDefn';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of ValidateCompleteAADDefn'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

OPEN c;
FETCH c BULK COLLECT INTO l_array_event_type;
CLOSE c;

IF (l_array_event_type.COUNT > 0) THEN

   FORALL i IN 1..l_array_event_type.COUNT
    UPDATE xla_ae_headers_gt
       SET accounting_entry_status_code = xla_ae_journal_entry_pkg.C_RELATED_INVALID
          ,event_status_code            = 'I'
     WHERE event_type_code = l_array_event_type(i);

   l_count := SQL%ROWCOUNT;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '# rows updated in  xla_ae_headers_gt ='||l_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF (l_count > 0) THEN
      FOR i IN 1..l_array_event_type.COUNT LOOP
         FOR l_je IN c_je(l_array_event_type(i)) LOOP
            xla_accounting_err_pkg.build_message(
                       p_appli_s_name            => 'XLA'
                      ,p_msg_name                => 'XLA_AP_INCOMP_EVENT_TYPE_DEFN'
                      ,p_entity_id               => l_je.entity_id
                      ,p_event_id                => l_je.event_id
                      ,p_ledger_id               => null
                      ,p_ae_header_id            => null
                      ,p_ae_line_num             => null
                      ,p_accounting_batch_id     => null);
         END LOOP;
      END LOOP;
   END IF;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of ValidateCompleteAADDefn'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
                (p_location => 'xla_accounting_engine_pkg.ValidateCompleteAADDefn');
END ValidateCompleteAADDefn;

--
/*======================================================================+
|                                                                       |
| PRIVATE Procedure                                                     |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION PostAccountingEngine(p_application_id                 IN NUMBER
                             ,p_accounting_batch_id            IN NUMBER
                             ,p_ledger_id                      IN NUMBER
                             ,p_end_date                       IN DATE    -- 4262811
                             ,p_accounting_mode                in VARCHAR2
                             ,p_min_event_date                 IN DATE
                             ,p_max_event_date                 IN DATE
                             ,p_budgetary_control_mode         IN VARCHAR2)
RETURN NUMBER
IS
--
l_array_temp_events  xla_ae_journal_entry_pkg.t_array_Num;
l_array_temp_status  xla_ae_journal_entry_pkg.t_array_V30L;
l_result             NUMBER;
l_log_module         VARCHAR2(240);
--

BEGIN
--
IF g_log_enabled THEN
  l_log_module := C_DEFAULT_MODULE||'.PostAccountingEngine';
END IF;
--

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg      => 'BEGIN of PostAccountingEngine'
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
  trace(p_msg      => 'p_application_id = '||TO_CHAR(p_application_id) ||
                      ' - p_accounting_batch_id = '||TO_CHAR(p_accounting_batch_id) ||
                      ' - p_ledger_id = '||TO_CHAR(p_ledger_id)
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
END IF;

/* 4219869 moved to after bflow procedures
--
-- perform the creation of the ccid
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '--> CALL XLA_AE_CODE_COMBINATION_PKG.BuildCcids'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_result := XLA_AE_CODE_COMBINATION_PKG.BuildCcids;
*/

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '--> CALL XLA_AE_LINES_PKG.CalculateUnroundedAmounts'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

-- set the unrounded accounted amount
XLA_AE_LINES_PKG.CalculateUnroundedAmounts;

---------------------------------------
-- 4219869 - Process Business Flow Entries
---------------------------------------
XLA_AE_LINES_PKG.BusinessFlowPriorEntries(p_accounting_mode,p_ledger_id,p_budgetary_control_mode); -- 5357406
-- Moved call to BusinessflowSameEntry after Map_ccid,bug 6675871
--XLA_AE_LINES_PKG.BusinessFlowSameEntries;



IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '--> CALL LA_AE_LINES_PKG.CalculateGainLossAmounts'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
-- calculate the gain/loss amount
XLA_AE_LINES_PKG.CalculateGainLossAmounts;


---------------------------------------------------------------------------
-- 4219869 moved to after bflow procedures
-- perform the creation of the ccid
----------------------------------------------------------------------------
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '--> CALL XLA_AE_CODE_COMBINATION_PKG.BuildCcids'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_result := XLA_AE_CODE_COMBINATION_PKG.BuildCcids;
----------------------------------------------------------------------------
--
-- bulk performance
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '--> CALL XLA_AE_LINES_PKG.AccountingReversal'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

XLA_AE_LINES_PKG.AccountingReversal(CASE WHEN p_budgetary_control_mode = 'NONE'
                                         THEN p_accounting_mode
                                         ELSE p_budgetary_control_mode END);

--
-- The following will mark the events with ERROR when the validation in AccountingReversal
-- routine fails. i.e the DUMMY_LR lines are converted to DUMMY_LR_ERROR.
--
-- Bug 4056420. To improve performance the single update is replaced by a select and then
-- the update
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL- update xla_events_gt'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

SELECT DISTINCT event_id BULK COLLECT
INTO l_array_temp_events
FROM xla_ae_lines_gt
WHERE reversal_code = 'DUMMY_LR_ERROR';

FORALL i IN 1..l_array_temp_events.COUNT
UPDATE xla_events_gt
SET process_status_code = 'E'
WHERE event_id = l_array_temp_events(i);


IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '# rows updated in xla_events_gt ='||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;
--
-- Delete the dummy lines from xla_ae_lines_gt table
--
DELETE FROM xla_ae_lines_gt
  WHERE balance_type_code = 'X'
     OR (unrounded_accounted_cr is null AND unrounded_accounted_dr is null AND gain_or_loss_flag = 'Y' AND calculate_g_l_amts_flag= 'Y');

DELETE FROM xla_ae_headers_gt
  WHERE balance_type_code = 'X';

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL- update xla_ae_headers_gt (1)'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


UPDATE xla_ae_headers_gt     aeh
   SET ae_header_id = xla_ae_headers_s.nextval
      ,(period_name
      , period_year
      , period_closing_status
      , period_start_date
      , period_end_date) =       -- 4262811
       (SELECT period_name
             , period_year
             , closing_status
             , start_date
             , end_date                        -- 4262811
          FROM gl_period_statuses     gps
         WHERE gps.application_id          = 101
           AND gps.ledger_id               = aeh.ledger_id
           AND gps.adjustment_period_flag  = 'N'
           AND aeh.ACCOUNTING_DATE BETWEEN gps.start_date AND gps.end_date)
RETURNING event_id, ledger_id, balance_type_code, header_num, ae_header_id BULK COLLECT  -- 4262811
INTO xla_ae_journal_entry_pkg.g_array_event_id
     ,xla_ae_journal_entry_pkg.g_array_ledger_id
     ,xla_ae_journal_entry_pkg.g_array_balance_type
     ,xla_ae_journal_entry_pkg.g_array_header_num          -- 4262811
     ,xla_ae_journal_entry_pkg.g_array_ae_header_id;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '# rows updated in xla_ae_headers_gt(1) ='||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


-- 4262811 ----------------------------------------------------------------------
-- For the following situition, the first day in the next open GL period is used:
-- 1. the accrual reversal gl date mode is First Day Next GL Period
-- 2. the accrual reversal gl date mode is Next Day but currenly the next day is
--    in a closed or permentently closed period
-- 3. the accrual reversal gl date mode is Next Day but currenly the next day is
--    in a future open period and the gl date is before the End GL date parameter
--
UPDATE xla_ae_headers_gt xah
   SET first_day_next_gl_period =
       (SELECT min(gps.start_date)
          FROM gl_period_statuses gps
         WHERE gps.application_id         = 101
           AND gps.ledger_id              = xah.ledger_id
           AND gps.adjustment_period_flag = 'N'
           AND gps.closing_status         = 'O'
           AND gps.start_date             > xah.accounting_date)
 WHERE  xah.acc_rev_gl_date_option = 'XLA_FIRST_DAY_NEXT_GL_PERIOD'
    OR  xah.acc_rev_gl_date_option = 'XLA_LAST_DAY_NEXT_GL_PERIOD'
--  4262811a  Rollover MPA Gl Date
    OR (xah.acc_rev_gl_date_option in ('XLA_NEXT_DAY','FIRST_DAY_GL_PERIOD','LAST_DAY_GL_PERIOD','ORIGINATING_DAY') AND
        xah.period_closing_status IN ('P', 'C'))
    OR (xah.acc_rev_gl_date_option in ('XLA_NEXT_DAY','FIRST_DAY_GL_PERIOD','LAST_DAY_GL_PERIOD','ORIGINATING_DAY') AND
        xah.period_closing_status = 'N' and xah.accounting_date <= p_end_date);
--  OR (xah.acc_rev_gl_date_option = 'XLA_NEXT_DAY' AND xah.period_closing_status IN ('P', 'C'))
--  OR (xah.acc_rev_gl_date_option = 'XLA_NEXT_DAY' AND xah.period_closing_status = 'N' and xah.accounting_date <= p_end_date);


--
-- If the first day next GL period is determined for any journal entry, it
-- indicates that some journal entry need to move the GL date to the next
-- open GL period.  Update the GL Date to the first day next GL period.
--
IF (SQL%ROWCOUNT > 0) THEN

  UPDATE xla_ae_headers_gt  xah
     SET (accounting_date
         ,period_name
         ,period_year
         ,period_closing_status
         ,period_start_date
         ,period_end_date) =
       --(SELECT DECODE(xah.acc_rev_gl_date_option, 'XLA_LAST_DAY_NEXT_GL_PERIOD'
       --              ,NVL(gps.end_date, xah.accounting_date)
       --              ,NVL(gps.start_date, xah.accounting_date))
         (SELECT NVL(gps.start_date, xah.accounting_date)        -- 4884853 rollover to the first day of next open period
               , NVL(gps.period_name, xah.period_name)
               , NVL(gps.period_year, xah.period_year)
               , NVL(gps.closing_status, xah.period_closing_status)
               , NVL(gps.start_date, xah.period_start_date)
               , NVL(gps.end_date, xah.period_end_date)
            FROM xla_ae_headers_gt  xah2
               , gl_period_statuses gps
           WHERE xah.ae_header_id               = xah2.ae_header_id
             AND gps.application_id         (+) = 101
             AND gps.ledger_id              (+) = xah2.ledger_id
             AND gps.adjustment_period_flag (+) = 'N'
             AND gps.closing_status         (+) = 'O'
             AND gps.start_date             (+) = xah2.first_day_next_gl_period)
   -- 4884853
   WHERE  xah.acc_rev_gl_date_option IN ('XLA_FIRST_DAY_NEXT_GL_PERIOD','XLA_LAST_DAY_NEXT_GL_PERIOD','XLA_NEXT_DAY',
                                         'FIRST_DAY_GL_PERIOD','LAST_DAY_GL_PERIOD','ORIGINATING_DAY')
     AND (xah.period_closing_status IN ('P', 'C') OR (xah.period_closing_status = 'N' AND xah.accounting_date <= p_end_date));

END IF;


--
-- When rolling the GL date using the transaction date rule, if the accrual
-- reversal gl date mode is XLA_NEXT_DAY, GL date is not rolled backward
--
xla_ae_header_pkg.ValidateBusinessDate
   (p_ledger_id => p_ledger_id);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL- update xla_ae_headers_gt (2)'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

ValidateCompleteAADDefn
    (p_application_id  => p_application_id
    ,p_ledger_id       => p_ledger_id
    ,p_min_event_date  => p_min_event_date
    ,p_max_event_date  => p_max_event_date);


UPDATE xla_ae_headers_gt a
SET accounting_entry_status_code = xla_ae_journal_entry_pkg.C_RELATED_INVALID
   ,event_status_code            = 'I'
WHERE accounting_entry_status_code = xla_ae_journal_entry_pkg.C_VALID
AND EXISTS
   (SELECT /*+ HASH_SJ */ '1'
      FROM xla_ae_headers_gt
     WHERE event_id = a.event_id
       AND accounting_entry_status_code = xla_ae_journal_entry_pkg.C_INVALID);


IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '# rows updated in  xla_ae_headers_gt(2) ='||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '--> CALL xla_ae_journal_entry_pkg.InsertJournalEntries'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


l_result := xla_ae_journal_entry_pkg.InsertJournalEntries
               (p_application_id         => p_application_id
               ,p_accounting_batch_id    => p_accounting_batch_id
               ,p_end_date               => p_end_date             -- 4262811
               ,p_accounting_mode        => p_accounting_mode
               ,p_budgetary_control_mode => p_budgetary_control_mode);


--
-- fixed bug 3962951. Added a decode over p_accounting_mode
--
-- Bug 4056420. To improve performance the single update is replaced by a select and then
-- the update
--

/* NOTE-  For Bug# 9086275
          Event's Process Status stamped as P even when there is a INVALID
Header for Event.  This is bcos, below array has the following
  Index1: EventID1   I
  Index2: EventID2   X --(X Stands for SUCCESS)
Hence, I status is overriden by X From  second row. So,to mark the event's
statsus as Invalid, Order by EVENT STATUS DESC from Headers_GT is used, which
would give Success as the First Line in the Array and I as sencod row. Hence
ensure always to have SUCCESS(X) as the first row in the Global Array.
 */

SELECT DISTINCT event_id, event_status_code BULK COLLECT
INTO l_array_temp_events, l_array_temp_status
FROM xla_ae_headers_gt
order by event_id , event_status_code desc -- added for bug#9086275
;

FORALL i IN 1..l_array_temp_events.COUNT
UPDATE xla_events_gt
SET process_status_code = DECODE(l_array_temp_status(i)
                                ,'X', DECODE(process_status_code
                                            ,'E','I'
                                            ,DECODE(p_accounting_mode
                                                    ,'F','P'
                                                    ,'D'
                                                    )
                                            )
                                ,NULL,'U'
                                ,l_array_temp_status(i)
                                )
WHERE event_id = l_array_temp_events(i);


IF (l_result  = C_VALID_ENTRIES  OR  l_result = C_INVALID_ENTRIES ) THEN

    l_result := C_VALID_ENTRIES;

    --=========================
    -- call validation routine
    --=========================

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

          trace
             (p_msg      => '-> CALL xla_je_validation_pkg.balance_amounts API '||l_result
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);



    END IF;

     xla_ae_journal_entry_pkg.UpdateResult(
       p_old_status => l_result
     , p_new_status => xla_je_validation_pkg.balance_amounts
                         (p_application_id         => p_application_id
                         ,p_end_date               => p_end_date           -- 4262811
                         ,p_mode                   => 'CREATE_ACCOUNTING'  -- 4262811
                         ,p_ledger_id              => p_ledger_id
                         ,p_budgetary_control_mode => p_budgetary_control_mode
                         ,p_accounting_mode        => p_accounting_mode));


END IF;

IF (p_budgetary_control_mode = 'NONE') THEN  -- bug 5173426
  UpdateRelatedErrorsStatus;
END IF;

-- 4669308
DeleteIncompleteMPA (p_application_id         => p_application_id);

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_result)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of PostAccountingEngine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
  RAISE;
WHEN OTHERS  THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
       trace
           (p_msg      => 'Error. = '||sqlerrm
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
                (p_location => 'xla_accounting_engine_pkg.PostAccountingEngine');
   --
END PostAccountingEngine;
--
--
--
--+==========================================================================+
--|  PRIVATE FUNCTION                                                        |
--|      RunPAD                                                              |
--+==========================================================================+
--
FUNCTION RunPAD
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_pad_package            IN VARCHAR2
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER
       ,p_budgetary_control_mode IN VARCHAR2)
RETURN NUMBER IS
--
l_result             NUMBER         := 2 ;
l_statement          VARCHAR2(1000) := NULL ;
l_log_module         VARCHAR2(240);
l_ledger_category_code VARCHAR2(30);
l_enable_bc_flag       VARCHAR2(1):=null;

invalid_package      EXCEPTION;
PRAGMA EXCEPTION_INIT(invalid_package,-04063);
--
BEGIN
--
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.RunPAD';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of RunPAD'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   trace
      (p_msg      => 'p_application_id = '||TO_CHAR(p_application_id)||
                     ' - p_base_ledger_id = '||TO_CHAR(p_base_ledger_id)||
                     ' - p_pad_package = '||TO_CHAR(p_pad_package)
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;



IF p_pad_package IS NOT NULL THEN
   --===========================================================================
   -- launch the creation of the journal entries for primary/secondary ledgers
   --
   -- Example :
   -- l_statement := BEGIN
   --                   l_result :=
   --                      XLA_00200_PAD_C_000001_PKG.CreateJournalEntries
   --                         (p_application_id
   --                         ,p_base_ledger_id
   --                         ,p_pad_start_date
   --                         ,p_pad_end_date
   --                         ,p_primary_ledger_id);
   --                END;
   --===========================================================================
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => '-> CALL '||p_pad_package||'.CreateJournalEntries() API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (p_budgetary_control_mode = 'NONE') THEN
     l_statement := 'BEGIN :1 := '||p_pad_package ||'.CreateJournalEntries(:2,:3,:4,:5,:6 ); END;';
   ELSE
       -- 6509160 Process non bc AAd package for Secondary non bc enabled ledger
      -- get category code of ledger
     SELECT ledger_category_code,enable_budgetary_control_flag
     INTO l_ledger_category_code,l_enable_bc_flag
     FROM gl_ledgers
     WHERE ledger_id = p_base_ledger_id;
   IF l_ledger_category_code='SECONDARY' and l_enable_bc_flag='N' THEN
    /* commented for bug-9245677 */
    /* l_statement := 'BEGIN :1 := '||p_pad_package ||'.CreateJournalEntries(:2,:3,:4,:5,:6 ); END;'; */
    NULL ; /* added for bug-9245677 */
   ELSE
     l_statement := 'BEGIN :1 := '||replace(p_pad_package,'_PKG','_BC_PKG') ||'.CreateJournalEntries(:2,:3,:4,:5,:6 ); END;';
   END IF;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => '>> EXECUTE Dynamic SQL = '||l_statement
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   /* added for bug-9245677 */
   IF ( p_budgetary_control_mode = 'NONE'
        OR
	NOT( l_ledger_category_code='SECONDARY' and l_enable_bc_flag='N')
      )
   THEN
	EXECUTE IMMEDIATE l_statement
        USING OUT l_result
             ,IN p_application_id
             ,IN p_base_ledger_id
             ,IN p_pad_start_date
             ,IN p_pad_end_date
             ,IN p_primary_ledger_id;
   ELSE
        l_result := 0 ; /* added for bug-9245677 */
   END IF;

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'return value. = '||TO_CHAR(l_result)
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);

   trace
      (p_msg      => 'END of RunPAD'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

RETURN l_result;

EXCEPTION

WHEN xla_exceptions_pkg.application_exception THEN
     RAISE;

-- handle the error due to invalid AAD package. Bug 3718471.
WHEN invalid_package  THEN
     xla_exceptions_pkg.raise_message
             (p_appli_s_name   => 'XLA'
             ,p_msg_name       => 'XLA_COMMON_ERROR'
             ,p_token_1        => 'ERROR'
             ,p_value_1        => 'The AAD package is not valid in the database.'||
                                  'Please Recompile the AAD and resubmit Accounting.'
             ,p_token_2        => 'LOCATION'
            ,p_value_2        => 'xla_accounting_engine_pkg.RunPAD');

WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_engine_pkg.RunPAD');

END RunPAD;
--
--
--+==========================================================================+
--| PRIVATE FUNCTION                                                         |
--|      SubmitAccountingEngine                                              |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION SubmitAccountingEngine
       (p_application_id         IN NUMBER
       ,p_ledger_id              IN NUMBER
       ,p_accounting_mode        IN VARCHAR2
       ,p_budgetary_control_mode IN VARCHAR2
       ,p_accounting_batch_id    IN NUMBER
       ,p_min_event_date         IN OUT NOCOPY DATE
       ,p_max_event_date         IN OUT NOCOPY DATE)
RETURN NUMBER
IS
--

l_result                             NUMBER;
l_je_result                          NUMBER;
l_pad_package                        VARCHAR2(30);
l_array_base_ledgers                 xla_accounting_cache_pkg.t_array_ledger_id;
l_array_null_event_ids               xla_ae_journal_entry_pkg.t_array_Num;
l_array_null_event_status            xla_ae_journal_entry_pkg.t_array_V1L;
l_rec_array_event                    t_rec_array_event;
l_rows                               NATURAL:=1000;
Idx                                  BINARY_INTEGER;
EventIdx                             BINARY_INTEGER;
--
l_log_module           VARCHAR2(240);
--
l_array_pads           xla_accounting_cache_pkg.t_array_pad;
l_slam_name_session    VARCHAR2(240);
l_min_aad_start_date   DATE;
l_max_aad_end_date     DATE;
l_ledger_category_code VARCHAR2(30);
l_enable_bc_flag       VARCHAR2(1);
--
BEGIN
--
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.SubmitAccountingEngine';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
       (p_msg      => 'BEGIN of SubmitAccountingEngine'
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
END IF;
--
-- init local variables
--
l_result              := C_UNPROCESSED_ENTRIES;
l_je_result           := C_NO_ENTRIES;
g_array_event_ids     := l_array_null_event_ids;
g_array_event_status  := l_array_null_event_status;
EventIdx              := 0;

--
-- get all the base ledgers
--
l_array_base_ledgers := xla_accounting_cache_pkg.GetLedgers;

--
-- get min and max event date from the xla_events_gt_table.
-- this information is used to find the AADs that will used
-- to account for events
--
SELECT MIN(event_date), MAX(event_date)
  INTO p_min_event_date, p_max_event_date
  FROM xla_events_gt;

--
-- looping for base ledgers
--
FOR Jdx IN 1 .. l_array_base_ledgers.COUNT LOOP
   --IF (p_budgetary_control_mode = 'NONE' OR
   --    l_array_base_ledgers(Jdx) = p_ledger_id) THEN
   --
   -- get AADs for the base ledger that fall between min and max event dates
   --
   l_array_pads :=
      xla_accounting_cache_pkg.GetArrayPad
         (p_ledger_id            => l_array_base_ledgers(Jdx)
         ,p_min_event_date       => p_min_event_date
         ,p_max_event_date       => p_max_event_date);

   l_min_aad_start_date := NULL;
   l_max_aad_end_date   := NULL;
   l_slam_name_session :=
      xla_accounting_cache_pkg.GetSessionValueChar
         (p_source_code         => 'XLA_ACCOUNTING_METHOD_NAME'
         ,p_target_ledger_id    => l_array_base_ledgers(Jdx));

   --
   -- looping for each AAD
   --
   FOR Kdx IN 1 .. l_array_pads.COUNT LOOP
      --
      -- following code will be used to see if there are missing AADs for
      -- which there are events in the XLA_EVENTS_GT table.
      -- These events should actually be marked as error/invalid.
      --
      IF (l_min_aad_start_date IS NULL OR
         l_min_aad_start_date > NVL(l_array_pads(Kdx).start_date_active,p_min_event_date))
      THEN
         l_min_aad_start_date :=
            NVL(l_array_pads(Kdx).start_date_active,p_min_event_date);
      END IF;

      IF (l_max_aad_end_date IS NULL OR
         l_max_aad_end_date < NVL(l_array_pads(Kdx).end_date_active,p_max_event_date))
      THEN
         l_max_aad_end_date :=
            NVL(l_array_pads(Kdx).end_date_active,p_max_event_date);
      END IF;

      /* 5054831  Moved to xla_accounting_pkg.ValidateAAD.
      IF l_array_pads(Kdx).product_rule_code IS NOT NULL AND
         NVL(l_array_pads(Kdx).compile_status_code,'N') <> 'Y'
      THEN
         IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'The AAD '||l_array_pads(Kdx).product_rule_code||' is not compiled.'
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
         END IF;
         --
         -- calling routine to mark the events with error and
         -- build messages
         --
         CatchErr_UncompliedAAD
            (p_ledger_id     => l_array_base_ledgers(Jdx)
            ,p_min_date      => NVL(l_array_pads(Kdx).start_date_active,p_min_event_date)
            ,p_max_date      => NVL(l_array_pads(Kdx).end_date_active,p_max_event_date)
            ,p_aad_name      => l_array_pads(Kdx).session_product_rule_name
            ,p_aad_owner     => l_array_pads(Kdx).product_rule_owner
            ,p_slam_name     => l_slam_name_session);

      ELSIF l_array_pads(Kdx).product_rule_code IS NULL THEN
      */
      IF l_array_pads(Kdx).product_rule_code IS NULL THEN
         --
         -- How can this situation ever happen???
         --
         -- build messages for each event/ledger that the PAD setup is invalid

         -- update event status for the events.
         -- .....
         -- .....
         --
         IF (C_LEVEL_ERROR >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_AP_INV_PAD_SETUP'
               ,p_level    => C_LEVEL_ERROR
               ,p_module   => l_log_module);
         END IF;
      ELSE

         l_je_result :=
            RunPAD
               (p_application_id       => p_application_id
               ,p_base_ledger_id       => l_array_base_ledgers(Jdx)
               ,p_pad_package          => l_array_pads(Kdx).pad_package_name
               ,p_pad_start_date       => nvl(l_array_pads(Kdx).start_date_active,p_min_event_date)
               ,p_pad_end_date         => nvl(l_array_pads(Kdx).end_date_active,p_max_event_date)
               ,p_primary_ledger_id    => p_ledger_id
               ,p_budgetary_control_mode => p_budgetary_control_mode);
      END IF;

   END LOOP; -- end of AAD loop
   --
   -- If there are no AADs attached to the SLAM
   --
   IF (l_min_aad_start_date IS NULL AND
       l_max_aad_end_date IS NULL)
   THEN
      l_min_aad_start_date := p_max_event_date +1;
      l_max_aad_end_date   := p_max_event_date +1;
   END IF;

   --
   -- calling routine to mark the events with error and
   -- build messages for which there were no AADs in the ledger
   --
   IF (p_min_event_date < l_min_aad_start_date OR
       p_max_event_date > l_max_aad_end_date)
   THEN

    -- bug 6414911 For applications where AAd is not defined for secondary ledger,it implies product teams do not want to account for secondary ledger during funds reserve/check,hence dont stamp the budgetary event with error status.
     SELECT ledger_category_code,enable_budgetary_control_flag
     INTO l_ledger_category_code,l_enable_bc_flag
     FROM gl_ledgers
     WHERE ledger_id = l_array_base_ledgers(Jdx);

    IF nvl(p_budgetary_control_mode,'NONE')<>'NONE' and l_ledger_category_code ='SECONDARY' and l_enable_bc_flag='N' THEN
           IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
                (p_msg      => 'ledger category code ='||l_ledger_category_code||' bc flag='||l_enable_bc_flag
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);

          END IF;
     Else
      CatchErr_MissingAAD
         (p_ledger_id               => l_array_base_ledgers(Jdx)
         ,p_min_aad_start_date      => l_min_aad_start_date
         ,p_max_aad_end_date        => l_max_aad_end_date
         ,p_min_event_date          => p_min_event_date
         ,p_max_event_date          => p_max_event_date
         ,p_slam_name               => l_slam_name_session);
         End if;
   END IF;

   --END IF;

END LOOP;  -- end of base ledger loop

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'return value. = '||TO_CHAR(l_result)
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   trace
      (p_msg      => 'END of SubmitAccountingEngine'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_engine_pkg.RunPAD');
END SubmitAccountingEngine;
--
--+==========================================================================+
--|  PUBLIC FUNCTION                                                         |
--|    CreateJournalEntries                                                  |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
FUNCTION AccountingEngine
       (p_application_id         IN NUMBER
       ,p_ledger_id              IN NUMBER
       ,p_end_date               IN DATE        -- 4262811
       ,p_accounting_mode        IN VARCHAR2
       ,p_accounting_batch_id    IN NUMBER
       ,p_budgetary_control_mode IN VARCHAR2)
RETURN NUMBER IS
--
l_TempJE       NUMBER  := 2;
l_FinalJE      NUMBER  := 2;
l_log_module         VARCHAR2(240);
--
l_min_event_date        date;
l_max_event_date        date;
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AccountingEngine';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AccountingEngine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_application_id = '||TO_CHAR(p_application_id)||
                        ' - p_ledger_id = '||TO_CHAR(p_ledger_id)||
                        ' - p_accounting_mode = '||p_accounting_mode||
                        ' - p_accounting_batch_id = '||TO_CHAR(p_accounting_batch_id)

         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

--
-- Diagnotic Framework
--
xla_accounting_engine_pkg.g_diagnostics_mode := nvl(fnd_profile.value('XLA_DIAGNOSTIC_MODE'),'N');

--
-- validate to make sure that the accounting mode parameter is correct
-- (it should either be 'D' or 'F' for DRAFT/FINAL)
--
IF p_accounting_mode NOT IN (C_DRAFT_STATUS,C_FINAL_STATUS) THEN
   IF (C_LEVEL_ERROR >= g_log_level) THEN
      trace
         (p_msg      => 'p_accounting_mode = '||p_accounting_mode||' is invalid value'
         ,p_level    => C_LEVEL_ERROR
         ,p_module   => l_log_module);
   END IF;

   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_engine_pkg.AccountingEngine');
END IF;


l_TempJE :=
   SubmitAccountingEngine
     (p_application_id         => p_application_id
     ,p_ledger_id              => p_ledger_id
     ,p_accounting_mode        => p_accounting_mode
     ,p_budgetary_control_mode => p_budgetary_control_mode
     ,p_accounting_batch_id    => p_accounting_batch_id
     ,p_min_event_date         => l_min_event_date
     ,p_max_event_date         => l_max_event_date);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
     (p_msg      => 'l_TempJE = '||TO_CHAR(l_TempJE)
     ,p_level    => C_LEVEL_STATEMENT
     ,p_module   => l_log_module);
END IF;

l_FinalJE :=
   PostAccountingEngine
      (p_application_id              =>  p_application_id
      ,p_accounting_batch_id         =>  p_accounting_batch_id
      ,p_ledger_id                   =>  p_ledger_id
      ,p_end_date                    =>  p_end_date   -- 4262811
      ,p_accounting_mode             =>  p_accounting_mode
      ,p_min_event_date              => l_min_event_date
      ,p_max_event_date              => l_max_event_date
      ,p_budgetary_control_mode      => p_budgetary_control_mode);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
     (p_msg      => 'l_FinalJE = '||TO_CHAR(l_FinalJE)
     ,p_level    => C_LEVEL_STATEMENT
     ,p_module   => l_log_module);
END IF;

--
--   XLA_AE_CODE_COMBINATION_PKG.refreshCcidCache;

--
-- Zero temporary journal entries created
-- Update events processed
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
     (p_msg      => 'END of AccountingEngine'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;

RETURN l_FinalJE;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_engine_pkg.AccountingEngine');
END AccountingEngine;
--
--+==========================================================================+
--|  PRIVATE FUNCTION                                                        |
--|    CatchErr_UncompliedAAD                                                |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE CatchErr_UncompliedAAD
       (p_ledger_id         IN NUMBER
       ,p_min_date          IN DATE
       ,p_max_date          IN DATE
       ,p_aad_name          IN VARCHAR2
       ,p_aad_owner         IN VARCHAR2
       ,p_slam_name         IN VARCHAR2) IS
l_array_entity_id    xla_ae_journal_entry_pkg.t_array_Num;
l_array_event_id     xla_ae_journal_entry_pkg.t_array_Num;
l_log_module         VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CatchErr_UncompliedAAD';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
        (p_msg      => 'BEGIN of CatchErr_UncompliedAAD'
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
      trace
        (p_msg      => ' p_ledger_id = '||p_ledger_id||
                       ' - p_aad_name = '||p_aad_name||
                       ' - p_min_date = '||p_min_date||
                       ' - p_max_date = '||p_max_date||
                       ' - p_aad_owner = '||p_aad_owner
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
      trace
        (p_msg      => 'p_slam_name = '||p_slam_name
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
   END IF;

   UPDATE xla_events_gt
      SET process_status_code = DECODE(process_status_code, 'U', 'E', process_status_code)
    WHERE event_date BETWEEN p_min_date AND p_max_date
   RETURNING entity_id, event_id
   BULK COLLECT INTO
       l_array_entity_id
      ,l_array_event_id;

   FOR i IN 1..l_array_event_id.COUNT LOOP
      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_PAD_INACTIVE'
         ,p_token_1                 => 'PAD_NAME'
         ,p_value_1                 => p_aad_name
         ,p_token_2                 => 'OWNER'
         ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                          'XLA_OWNER_TYPE'
                                          ,p_aad_owner)
         ,p_token_3                 => 'SUBLEDGER_ACCTG_METHOD'
         ,p_value_3                 => p_slam_name
         ,p_entity_id               => l_array_entity_id(i)
         ,p_event_id                => l_array_event_id(i)
         ,p_ledger_id               => p_ledger_id);
   END LOOP;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
        (p_msg      => 'END of CatchErr_UncompliedAAD'
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_engine_pkg.CatchErr_UncompliedAAD');
END CatchErr_UncompliedAAD;


--
--+==========================================================================+
--|  PRIVATE FUNCTION                                                        |
--|    CatchErr_MissingAAD                                                   |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE CatchErr_MissingAAD
       (p_ledger_id                 IN NUMBER
       ,p_min_aad_start_date        IN DATE
       ,p_max_aad_end_date          IN DATE
       ,p_min_event_date            IN VARCHAR2
       ,p_max_event_date            IN VARCHAR2
       ,p_slam_name                 IN VARCHAR2) IS
l_array_entity_id    xla_ae_journal_entry_pkg.t_array_Num;
l_array_event_id     xla_ae_journal_entry_pkg.t_array_Num;
l_application_name   VARCHAR2(240);
l_slam_owner         VARCHAR2(240);
l_log_module         VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CatchErr_MissingAAD';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
        (p_msg      => 'BEGIN of CatchErr_MissingAAD'
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
      trace
        (p_msg      => 'p_ledger_id = '||p_ledger_id
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
      trace
        (p_msg      => 'p_min_aad_start_date = '||p_min_aad_start_date
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
      trace
        (p_msg      => 'p_max_aad_end_date = '||p_max_aad_end_date
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
      trace
        (p_msg      => 'p_min_event_date = '||p_min_event_date
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
      trace
        (p_msg      => 'p_max_event_date = '||p_max_event_date
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
      trace
        (p_msg      => 'p_slam_name = '||p_slam_name
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
   END IF;

   IF (p_min_event_date < p_min_aad_start_date AND
      p_max_event_date  > p_max_aad_end_date)
   THEN
      UPDATE xla_events_gt
         SET process_status_code = DECODE(process_status_code, 'U', 'E', process_status_code)
       WHERE event_date BETWEEN p_min_event_date AND (p_min_aad_start_date -1)
          OR event_date BETWEEN (p_max_aad_end_date +1) AND p_max_event_date
      RETURNING entity_id, event_id
      BULK COLLECT INTO
          l_array_entity_id
         ,l_array_event_id;
   ELSIF p_min_event_date < p_min_aad_start_date THEN
      UPDATE xla_events_gt
         SET process_status_code = DECODE(process_status_code, 'U', 'E', process_status_code)
       WHERE event_date BETWEEN p_min_event_date AND (p_min_aad_start_date -1)
      RETURNING entity_id, event_id
      BULK COLLECT INTO
          l_array_entity_id
         ,l_array_event_id;
   ELSIF p_max_event_date > p_max_aad_end_date THEN
      UPDATE xla_events_gt
         SET process_status_code = DECODE(process_status_code, 'U', 'E', process_status_code)
       WHERE event_date BETWEEN (p_max_aad_end_date +1) AND p_max_event_date
      RETURNING entity_id, event_id
      BULK COLLECT INTO
          l_array_entity_id
         ,l_array_event_id;

   END IF;

   l_application_name :=
      xla_accounting_cache_pkg.GetSessionValueChar
         (p_source_code         => 'XLA_EVENT_APPL_NAME');

   l_slam_owner :=
      xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'XLA_ACCOUNTING_METHOD_OWNER'
         ,p_target_ledger_id    => p_ledger_id);

   FOR i IN 1..l_array_event_id.COUNT LOOP
      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_INV_PAD_SETUP'
         ,p_token_1                 => 'PRODUCT_NAME'
         ,p_value_1                 => l_application_name
         ,p_token_2                 => 'SUBLEDGER_ACCTG_METHOD'
         ,p_value_2                 => p_slam_name
         ,p_token_3                 => 'OWNER'
         ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                       'XLA_OWNER_TYPE',l_slam_owner)
         ,p_entity_id               => l_array_entity_id(i)
         ,p_event_id                => l_array_event_id(i)
         ,p_ledger_id               => p_ledger_id);
   END LOOP;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
        (p_msg      => 'END of CatchErr_MissingAAD'
        ,p_level    => C_LEVEL_PROCEDURE
        ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_accounting_engine_pkg.CatchErr_MissingAAD');
END CatchErr_MissingAAD;

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

END xla_accounting_engine_pkg; -- end of package spec

/
