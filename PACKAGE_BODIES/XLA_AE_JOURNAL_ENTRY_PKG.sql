--------------------------------------------------------
--  DDL for Package Body XLA_AE_JOURNAL_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AE_JOURNAL_ENTRY_PKG" AS
/* $Header: xlajejex.pkb 120.112.12010000.15 2010/02/24 13:19:17 karamakr ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_AE_JOURNAL_ENTRY_PKG                                               |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     10-NOV-2002 K.Boussema  Created                                        |
|     12-DEC-2002 K.Boussema  Added Calls to Validation APIs                 |
|     16-DEC-2002 K.Boussema  Reverse creation of lines before headers       |
|     08-JAN-2003 K.Boussema  Changed xla_temp_journal_entries by            |
|                             xla_journal_entries_temp                       |
|     10-JAN-2003 K.Boussema  Removed gl_sl_link_id column from temp table   |
|                             Added 'dbdrv' command                          |
|     20-FEB-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     09-APR-2003 K.Boussema    Renamed temporary tables :                   |
|                                       xla_je_headers_temp,xla_je_lines_temp|
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     22-APR-2003 K.Boussema    Added DOC_CATEGORY_NAME source               |
|     05-MAI-2003 K.Boussema    Modified to fix bug 2926949                  |
|                               Added sla_ledger_id in ledger cache          |
|     07-MAI-2003 K.Boussema    Changed the call to cache API, bug 2945359   |
|     13-MAI-2003 K.Boussema    Renamed temporary tables xla_je_lines_gt by  |
|                               xla_ae_lines_gt, xla_je_headers_gt by        |
|                               xla_ae_headers_gt                            |
|                               Renamed in xla_distribution_links the column |
|                               base_amount by ledger_amount                 |
|     14-MAI-2003 K.Boussema    Removed the SELECT of application_name       |
|     20-MAI-2003 K.Boussema    Added a Token to XLA_AP_CANNOT_INSERT_JE     |
|                               message                                      |
|     27-MAI-2003 K.Boussema    Renamed code_combination_status by           |
|                                  code_combination_status_flag              |
|                               Renamed base_amount by ledger_amount         |
|     02-JUN-2003 K.Boussema    Changed the insert of headers to fix         |
|                                  bugs 2981358 and 2981862                  |
|     11-JUN-2003 K.Boussema    Renamed Sequence columns, bug 3000007        |
|     17-JUL-2003 K.Boussema    Updated the call to accounting cache, 3055039|
|     18-JUL-2003 K.Boussema    Reviewed the call to GetSessionValueChar API |
|     21-JUL-2003 K.Boussema   Changed the source name from                  |
|                              GL_COA_MAPPINGS_NAME to GL_COA_MAPPING_NAME   |
|                              Reviewed GetAlternateCurrencyLedger           |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     28-JUL-2003 K.Boussema   Reviewed GetAlternateCurrencyLedger Procedure |
|     29-JUL-2003 K.Boussema    Reviewed the code to solve bug 3072881       |
|     31-JUL-2003 K.Boussema   Added in XLA_AE_LINES the two columns:        |
|                               DISPLAYED_LINE_NUMBER and GL_SL_LINK_TABLE   |
|     05-Aug-2003 Shishir J    Removed currency_code column from the         |
|                              xla_distribution_links table                  |
|     13-Aug-2003 Shishir J    Includes Neil's performance changes.          |
|     19-SEP-2003 K.Boussema    Code changed to include reversed_ae_header_id|
|                               and reversed_line_num, see bug 3143095       |
|     16-Oct-2003 Shishir J    Added accounting class code in the call to the|
|                              GET_HASH_VALUE function.                      |
|     22-OCT-2003 K.Boussema    Changed to capture the Merge Matching Lines  |
|                               preference for Accounting Reversal from JLT  |
|     14-NOV-2003 K.Boussema   Reviewed the cache of the primary ledger coa  |
|     26-NOV-2003 K.Boussema   Called the accounting cache to get the coa    |
|                              DYNAMIC_INSERTS_ALLOWED_FLAG, bug3256226      |
|     02-DEC-2003 K.Boussema   Populated xla_ae_lines.gl_sl_link_table column|
|                              with 'XLAJEL'                                 |
|     05-DEC-2003 K.Boussema   Changed the cache of coa to fix  bug3289875   |
|     12-DEC-2003 K.Boussema   Added the validation of event accounting mode |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     07-JAN-2003 K.Boussema   Changed to take in account switch_side in the |
|                              merge, bug 3272564                            |
|     20-JAN-2004 K.Boussema   Reverted the change made in bug 3139470       |
|                              and renamed the how columns by who columns    |
|     05-FEB-2004 S.Singhania   Changes based on bug 3419803.                |
|                                 - correct column names are used            |
|                                   TAX_LINE_REF_ID, TAX_SUMMARY_LINE_REF_ID,|
|                                   TAX_REC_NREC_DIST_REF_ID                 |
|                                 - reference to the column is removed.      |
|                                   TAX_REC_NREC_SUMMARY_DIST_REF            |
|     16-FEB-2004 K.Boussema   Made changes for the FND_LOG.                 |
|     04-MAR-2004 K.Boussema   Revised summarization of entered amounts      |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     25-MAR-2004 K.Boussema   Added the accounting cache call to retrieve   |
|                              the SL_COA_MAPPING_ID value                   |
|     05-MAY-04 K.Boussema  Bug 3502295: Changed the sum of entered and      |
|                           accounted amounts, reviewed InsertLines function |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     17-MAY-2004 W.Shen      Change for Attribute enhancement project       |
|                             InsertHeader and InsertLinks procedure are     |
|                             affected                                       |
|     14-JUN-2004 K.Boussema  Changed to improve performance, bug 3673478    |
|                             Change affects InsertAnalyticalCriteria proc.  |
|                             Removed the call to xla_utility_pkg.trace()    |
|     22-Sep-2004 S.Singhania Made changes for the bulk peroformance. It has |
|                               changed the code at number of places.        |
|     05-Oct-2004 S.Singhania Bug 3931752: Removed the not required where    |
|                               condition from the sqls that inserts into    |
|                               XLA_AE_LINES and XLA_DISTRIBUTION_LINKS.     |
|     05-OCT-2004 K.Boussema  Changed for Extract Source Values Dump feature |
|                             added procedures :                             |
|                                  - insert_extract_event()                  |
|                                  - insert_extract_ledger()                 |
|                             changed functions                              |
|                                   - set_event_info()                       |
|                                   - GetLedgersInfo()                       |
|     08-Dec-2004 K.Boussema  Reviewed and Renamed :                         |
|                             - insert_extract_ledger by insert_diag_ledger  |
|                             - insert_extract_event by insert_diag_event    |
|     09-Mar-2005 W. Shen       Ledger Currency Project                      |
|                               Multiple changes. For details please see DLD |
|     14-Mar-2005 K.Boussema Changed for ADR-enhancements.                   |
|     20-Apr-2005 W. Shen     replace column document_rounding_amount by     |
|                               doc_rounding_acctd_amt                       |
|     27-Apr-2005 W. Shen     Performance change. Insert into xla_ae_headers |
|                               with zero_amount_flag always = 'N'. will     |
|                               update it to 'Y' later in validation package |
|     26-May-2005 W. Shen     change for Unrounded_entered_amount            |
|     26-May-2005 A. Wan      4262811 MPA project                            |
|     1- Jul-2005 W. Shen     fix bug 4243728, calculate amount for 2nd      |
|                               ledger. Add 2 cache to ledger                |
|                                 calculate_amts_flag to ledger cache        |
|                               add ledger_category_code to ledger_cache     |
|                             Also set the entered amount side based on the  |
|                             side of unrounded accounted amount if the      |
|                              entered amount is 0. This is for bug 4444730  |
|     01-Aug-2005 W. Chan     4458381 - Public Sector Enhancement            |
|     01-Sep-2005 K.Boussema  reviewed insert_diag_event() for bug 4577709   |
|     02-Sep-2005 W. Chan     4577174 - Add call to GetTranslatedEventInfo   |
|                             in set_event_info                              |
|     09-Sep-2005 W. Shen     3720250 - new msg when gl date is null         |
|     18-Oct-2005 V. Kumar    Removed code for Analytical Criteria           |
|     04-Nov-2005 S. Singhania  Bug 4719297: Modified update statement in    |
|                                 GetLineNumber to add NVL in the where      |
|                                 condition related to header_num            |
|     20-Dec-2005 W. Chan     4872235 - Fixed the side for the 0 amounts     |
|     27-Dec-2005 A. Wan      4669308 - modify NVL(header_num,-1) to NVL(0)  |
|     02-Jan-2006 V. Kumar    4918497 - Added hint for performance           |
|                             4752807 - Conditional check to execute UPDATE  |
|    1/5/06    W. Shen  bug 4690710, set the amount to null in summerization |
|                         when the amounts are all null in temporary lines   |
|     09-Jan-2006 A. Wan      4669308 - AdjustMpaRevLine                     |
|     11-Jan-2006 W. Shen     4943507 - modify GetLineNum to add more merge  |
|                                       columns when get linehashnum         |
|     13-Feb-2006 V. Kumar    4955764 - Populating Ledger_id,Accounting_date |
|                                       in xla_ae_lines table                |
|     03-Mar-2006 V. Kumar   5041325 Populating GL_SL_LINK_ID in xla_ae_lines|
|     21-Jun-2006 A. Wan     5100860 Performance fix, see bug for detail     |
|     23-Sep-2008 Vijaya.G   7377888 Changes in AdjustMPALine procedure for  |
|                            MPA Accounting                                  |
|     03-Oct-2008 KARAMAKR   7382288 insert analytical criteria for          |
|                             invoice cancellation event in                  |
|                            xla_ae_line_acs, if analytical criteria         |
|			     for invoice validation event exists.            |
|     31-Oct-2008 VGOPISET   7230462 Changes in GetLineNumber and AdjustMPALine|
|                            to stamp the correct Parent_AE_Line_Num for     |
|                            complete MPA Accounting                         |
|     26-Feb-2009 VGOPISET   7560587 changes in GetLineNumber for create     |
|                                    accounting performance issues.          |
|     26-Feb-2009 VGOPISET   8277823 changes in GetLineNumber to populate    |
|                                    correct REF_AE_HEADER_ID for reversal   |
|                                    links created by AccountingReversal     |
|     03-Jun-2009 VGOPISET   8505463 changed the logic to derive accounting  |
|                                    ENTRY STATUS CODE for MPA entries when  |
|                                    MPA Accounting Date > P_END_DATE        |
|     11-Jun-2009 VGOPISET   8619700 Perf issues with REF_AE_HEADER_ID update|
|                                    for changes via bug8277823              |
+===========================================================================*/
--
-- legal_entity_name value is missing
--
--
TYPE t_rec_who_columns IS RECORD
(
  creation_date                  DATE
, created_by                     INTEGER
, last_update_date               DATE
, last_updated_by                INTEGER
, last_update_login              INTEGER
, program_update_date            DATE
, program_application_id         INTEGER
, program_id                     INTEGER
, request_id                     NUMBER
)
;
--
TYPE t_array_rowid IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global variables                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
g_who_columns                         t_rec_who_columns;

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global constant                                                          |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
C_CCID_CREATED                            CONSTANT VARCHAR2(30)  := 'CREATED';
C_CCID_INVALID                            CONSTANT VARCHAR2(30)  := 'INVALID';
--
C_DRAFT_STATUS                            CONSTANT VARCHAR2(1)   := 'D';
C_FINAL_STATUS                            CONSTANT VARCHAR2(1)   := 'F';

C_BULK_LIMIT                              CONSTANT NUMBER        :=2000;
C_OVN                                     CONSTANT NUMBER        :=1;

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Local Trace Routine                                                      |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_AE_JOURNAL_ENTRY_PKG';

g_line_ac_count       PLS_INTEGER;
g_hdr_ac_count        PLS_INTEGER;

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
          fnd_log.message(p_level, p_module);
       ELSIF p_level >= g_log_level THEN
          fnd_log.string(p_level, p_module, p_msg);
       END IF;

EXCEPTION
       WHEN xla_exceptions_pkg.application_exception THEN
          RAISE;
       WHEN OTHERS THEN
          xla_exceptions_pkg.raise_message
             (p_location   => 'XLA_AE_JOURNAL_ENTRY_PKG.trace');
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
--======================================================================
--
PROCEDURE  SetStandardWhoColumn
;
--
PROCEDURE GetLineNumber
;
--
PROCEDURE UpdateLineNumber
;
--
PROCEDURE UpdateLineNumber0
;
--
PROCEDURE UpdateLineNumber10
;
--
PROCEDURE UpdateLineNumber50
;
--
PROCEDURE UpdateLineNumber100
;
--

FUNCTION InsertLines(p_application_id         IN INTEGER
                    ,p_budgetary_control_mode IN VARCHAR2)
RETURN NUMBER
;
PROCEDURE AdjustMpaLine(p_application_id  IN INTEGER)     -- 4262811b
;
-- PROCEDURE AdjustMpaRevLine(p_application_id  IN INTEGER);  -- 4669308

PROCEDURE InsertAnalyticalCriteria
;
PROCEDURE InsertAnalyticalCriteria10
;
PROCEDURE InsertAnalyticalCriteria50
;
PROCEDURE InsertAnalyticalCriteria100
;
--
PROCEDURE InsertLinks(p_application_id    IN INTEGER)
;
--
FUNCTION InsertHeaders(p_application_id                 IN INTEGER
                      ,p_accounting_batch_id            IN NUMBER
                      ,p_end_date                       IN DATE        -- 4262811
                      -- bulk perfromance
                      ,p_accounting_mode                in varchar)
RETURN NUMBER
;
PROCEDURE InsertHdrAnalyticalCriteria
;
PROCEDURE InsertHdrAnalyticalCriteria10
;
PROCEDURE InsertHdrAnalyticalCriteria50
;
PROCEDURE InsertHdrAnalyticalCriteria100
;
--
--
PROCEDURE insert_diag_event(
                               p_event_id                       IN NUMBER
                              ,p_application_id                 IN NUMBER
                              ,p_ledger_id                      IN NUMBER
                              ,p_transaction_num                IN VARCHAR2
                              ,p_entity_code                    IN VARCHAR2
                              ,p_event_class_code               IN VARCHAR2
                              ,p_event_type_code                IN VARCHAR2
                              ,p_event_number                   IN NUMBER
                              ,p_event_date                     IN DATE
)
;
--
PROCEDURE insert_diag_ledger (  p_application_id    IN NUMBER
                              , p_ledger_id         IN NUMBER
                              , p_primary_ledger_id IN NUMBER
                              , p_pad_start_date    IN DATE
                              , p_pad_end_date      IN DATE
)
;
--
PROCEDURE Insert_ANC_Inv_Canc;
/*======================================================================+
|                                                                       |
| PRIVATE Procedure                                                     |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE  SetStandardWhoColumn
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetStandardWhoColumn';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetStandardWhoColumn'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

g_who_columns.creation_date                   := TRUNC(SYSDATE) ;
g_who_columns.created_by                      := xla_environment_pkg.g_Usr_Id ;
g_who_columns.last_update_date                := TRUNC(SYSDATE) ;
g_who_columns.last_updated_by                 := xla_environment_pkg.g_Usr_Id ;
g_who_columns.last_update_login               := xla_environment_pkg.g_Login_Id  ;
g_who_columns.program_update_date             := TRUNC(SYSDATE) ;
g_who_columns.program_application_id          := xla_environment_pkg.g_Prog_Appl_Id ;
g_who_columns.program_id                      := xla_environment_pkg.g_Prog_Id ;
g_who_columns.request_id                      := xla_environment_pkg.g_Req_Id ;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetStandardWhoColumn'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.SetStandardWhoColumn');
END SetStandardWhoColumn;
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
--
FUNCTION GetAlternateCurrencyLedger(p_base_ledger_id           IN NUMBER )
RETURN xla_accounting_cache_pkg.t_array_ledger_id
IS
l_array_alc_ledgers       xla_accounting_cache_pkg.t_array_ledger_id ;
l_array_ledgers           xla_accounting_cache_pkg.t_array_ledger_id ;
l_log_module              VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAlternateCurrencyLedger';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetAlternateCurrencyLedger'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      =>'p_base_ledger_id = '||TO_CHAR( p_base_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      =>'-> CALL xla_accounting_cache_pkg.GetAlcLedgers API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_array_ledgers(1)   := p_base_ledger_id;
--
l_array_alc_ledgers  := xla_accounting_cache_pkg.GetAlcLedgers(
                                          p_primary_ledger_id => p_base_ledger_id
                                        );

IF (C_LEVEL_EVENT >= g_log_level) THEN
          trace
             (p_msg      => '# of alternate ledgers = '||TO_CHAR(l_array_alc_ledgers.COUNT)
             ,p_level    => C_LEVEL_EVENT
             ,p_module   => l_log_module);
END IF;

IF  l_array_alc_ledgers.COUNT > 0 THEN

FOR Idx IN l_array_alc_ledgers.FIRST .. l_array_alc_ledgers.LAST LOOP

  l_array_ledgers(l_array_ledgers.LAST + 1) := l_array_alc_ledgers(Idx);

END LOOP;

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetAlternateCurrencyLedger'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

RETURN l_array_ledgers ;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   xla_accounting_err_pkg.build_message
                                       (p_appli_s_name            => 'XLA'
                                       ,p_msg_name                => 'XLA_AP_ACCT_ENGINE_ERROR'
                                       ,p_token_1                 => 'PROCEDURE'
                                       ,p_value_1                 => 'xla_accounting_cache_pkg.GetAlcLedgers'
                                       ,p_entity_id               => g_cache_event.entity_id
                                       ,p_event_id                => g_cache_event.event_id
                                       ,p_ledger_id               => g_cache_event.target_ledger_id
                              );

  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
                           trace
                              (p_msg      => 'ERROR: XLA_AP_ACCT_ENGINE_ERROR'
                              ,p_level    => C_LEVEL_EXCEPTION
                              ,p_module   => l_log_module);
  END IF;

  RAISE;
WHEN OTHERS  THEN
     xla_exceptions_pkg.raise_message
             (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.GetAlternateCurrencyLedger');
       --
END GetAlternateCurrencyLedger;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE cache_event_ledgers(
    p_base_ledger_id                 IN NUMBER
   ,p_target_ledger_id               IN NUMBER
 )
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.cache_event_ledgers';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of cache_event_ledgers'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
          (p_msg      =>'p_base_ledger_id = '||TO_CHAR(p_base_ledger_id)||
                        ' - p_target_ledger_id = '||TO_CHAR(p_target_ledger_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

   g_cache_event.base_ledger_id                 := p_base_ledger_id;
   g_cache_event.target_ledger_id               := p_target_ledger_id;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of cache_event_ledgers'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.cache_event_ledgers');
END cache_event_ledgers;

/*======================================================================+
|                                                                       |
| Public PROCEDURE                                                      |
|                                                                       |
|  Update the stats of the journal entries creation (0,1,2)             |
+======================================================================*/
--
PROCEDURE UpdateResult(  p_old_status           IN OUT NOCOPY NUMBER
                       , p_new_status           IN NUMBER
)
IS
l_old_status         NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateResult';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of UpdateResult'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_old_status = '||p_old_status
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_new_status = '||p_new_status
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_old_status   := p_old_status;
IF l_old_status = -1 OR
   (p_new_status = 2 AND l_old_status = 2 ) OR
   (p_new_status = 0 AND l_old_status = 0 ) OR
   (p_new_status = 0 AND l_old_status = 2 )
THEN
  p_old_status := p_new_status;
ELSE
  p_old_status := 1;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||p_old_status
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of UpdateResult'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.UpdateResult');
       --
END UpdateResult;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE  SetProductAcctDefinition(
  p_product_rule_code      IN VARCHAR2
, p_product_rule_type_code IN VARCHAR2
, p_product_rule_version   IN VARCHAR2
, p_product_rule_name      IN VARCHAR2
, p_amb_context_code       IN VARCHAR2
)
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetProductAcctDefinition';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of SetProductAcctDefinition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

  g_cache_pad.product_rule_code        := p_product_rule_code      ;
  g_cache_pad.product_rule_type_code   := p_product_rule_type_code ;
  g_cache_pad.product_rule_name        := p_product_rule_name      ;
  g_cache_pad.product_rule_version     := p_product_rule_version   ;
  g_cache_pad.amb_context_code         := p_amb_context_code       ;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'p_product_rule_code = '||p_product_rule_code||
                        ' - p_product_rule_type_code = '||p_product_rule_type_code||
                        ' - p_product_rule_version = '||p_product_rule_version||
                        ' - p_product_rule_name = '||p_product_rule_name||
                        ' -p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetProductAcctDefinition'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.SetProductAcctDefinition');
END SetProductAcctDefinition;

/*======================================================================+
|                                                                       |
| PRIVATE Procedure                                                     |
|                                                                       |
|    Called by Diagnostic Framework to store event info.                |
+======================================================================*/
--
PROCEDURE insert_diag_ledger (
  p_application_id    IN NUMBER
, p_ledger_id         IN NUMBER
, p_primary_ledger_id IN NUMBER
, p_pad_start_date    IN DATE
, p_pad_end_date      IN DATE
)
IS
l_log_module         VARCHAR2(240);
l_request_id         NUMBER;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_diag_ledger';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
     (p_msg      => 'BEGIN of insert_diag_ledger'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;

l_request_id := xla_environment_pkg.g_Req_Id ;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
         (p_msg      => 'SQL- Insert xla_diag_ledgers  the ledger_id ='||p_ledger_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   INSERT INTO xla_diag_ledgers
   (
        application_id
      , ledger_id
      , primary_ledger_id
      , sla_ledger_id
      , description_language
      , nls_desc_language
      , currency_code
      , product_rule_code
      , product_rule_type_code
      , amb_context_code
      , start_date_active
      , end_date_active
      , accounting_request_id
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
       p_application_id
     , p_ledger_id
     , p_primary_ledger_id
     , g_cache_ledgers_info.sla_ledger_id
     , g_cache_ledgers_info.description_language
     , g_cache_ledgers_info.nls_desc_language
     , g_cache_ledgers_info.currency_code
     , g_cache_pad.product_rule_code
     , g_cache_pad.product_rule_type_code
     , g_cache_pad.amb_context_code
     , p_pad_start_date
     , p_pad_end_date
     , l_request_id
     , xla_environment_pkg.g_Usr_Id
     , TRUNC(SYSDATE)
     , TRUNC(SYSDATE)
     , xla_environment_pkg.g_Usr_Id
     , xla_environment_pkg.g_Login_Id
     , TRUNC(SYSDATE)
     , xla_environment_pkg.g_Prog_Appl_Id
     , xla_environment_pkg.g_Prog_Id
     , xla_environment_pkg.g_Req_Id
    FROM xla_subledger_options_v
   WHERE application_id         = p_application_id
     AND ledger_id              = p_ledger_id
     AND primary_ledger_id      = p_primary_ledger_id
     AND not exists (SELECT 'x'
                       FROM xla_diag_ledgers
                      WHERE application_id         = p_application_id
                        AND ledger_id              = p_ledger_id
                        AND primary_ledger_id      = p_primary_ledger_id
                        AND accounting_request_id  = l_request_id
                    )
    ;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'Number of Extract ledgers Inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
trace
     (p_msg      => 'END of insert_diag_ledger'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_journal_entry_pkg.insert_diag_ledger');
  --
END insert_diag_ledger;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
FUNCTION  GetLedgersInfo(
 p_application_id           IN NUMBER
,p_base_ledger_id           IN NUMBER
,p_target_ledger_id         IN NUMBER
-- bulk performance
,p_primary_ledger_id        in number
,p_pad_start_date           IN DATE
,p_pad_end_date             IN DATE
--
)
RETURN BOOLEAN
IS
l_result               BOOLEAN:=TRUE;
l_api_name             VARCHAR2(30);
l_log_module           VARCHAR2(240);
l_sl_coa_mapping_id    NUMBER:=NULL;
l_category_code        VARCHAR2(30);
l_primary_currency     VARCHAR2(30);
l_currency             VARCHAR2(30);
l_alc_enabled_flag   VARCHAR2(1);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetLedgersInfo';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetLedgersInfo'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => '-> CALL xla_accounting_cache_pkg.GetValueChar/Num/Date APIs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
   g_cache_event.base_ledger_id                 := p_base_ledger_id;
   g_cache_event.target_ledger_id               := p_target_ledger_id;

  --
  -- target ledger language
  --
  l_api_name:= 'GetValueChar';
  g_cache_ledgers_info.description_language := xla_accounting_cache_pkg.GetValueChar(
                                  p_source_code        => 'XLA_DESCRIPTION_LANGUAGE'
                                , p_target_ledger_id   => p_target_ledger_id
                                );

  IF g_cache_ledgers_info.description_language IS NULL THEN

  l_result := FALSE;

          xla_accounting_err_pkg.build_message
                   (p_appli_s_name            => 'XLA'
                   ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                   ,p_value_1                 => 'Description Language'
                   ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                   ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                   ,p_ledger_id               => p_target_ledger_id
         );

         IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
         END IF;
  END IF;


  --
  -- target minimum accountable unit
  --
  l_api_name:= 'GetValueNum';
  g_cache_ledgers_info.minimum_accountable_unit:= xla_accounting_cache_pkg.GetValueNum(
                                  p_source_code        => 'XLA_CURRENCY_MAU'
                                , p_target_ledger_id   => p_target_ledger_id
                                );

  IF g_cache_ledgers_info.minimum_accountable_unit IS NULL THEN

  l_result := FALSE;

          xla_accounting_err_pkg.build_message
                   (p_appli_s_name            => 'XLA'
                   ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                   ,p_value_1                 => 'Minimum Accountable Unit'
                   ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                   ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                   ,p_ledger_id               => p_target_ledger_id
         );

         IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
         END IF;
  END IF;

  --
  -- Rounding rule code
  --
  l_api_name:= 'GetValueChar';
  g_cache_ledgers_info.rounding_rule_code:= xla_accounting_cache_pkg.GetValueChar(
                                  p_source_code        => 'XLA_ROUNDING_RULE_CODE'
                                , p_target_ledger_id   => p_target_ledger_id
                                );

  IF g_cache_ledgers_info.rounding_rule_code IS NULL THEN

  l_result := FALSE;

          xla_accounting_err_pkg.build_message
                   (p_appli_s_name            => 'XLA'
                   ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                   ,p_value_1                 => 'Rounding Rule Code'
                   ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                   ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                   ,p_ledger_id               => p_target_ledger_id
         );

         IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
         END IF;
  END IF;
  --
  -- SLA ledger id
  --
  l_api_name:= 'GetValueNum';
  g_cache_ledgers_info.sla_ledger_id      := xla_accounting_cache_pkg.GetValueNum(
                                    p_source_code        => 'SLA_LEDGER_ID'
                                  , p_target_ledger_id   => p_target_ledger_id
                                  );

  IF g_cache_ledgers_info.sla_ledger_id IS NULL THEN

      l_result := FALSE;

      xla_accounting_err_pkg.build_message
                         (p_appli_s_name            => 'XLA'
                         ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                         ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                         ,p_value_1                 => 'Sla ledger id'
                         ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                         ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                         ,p_ledger_id               => p_target_ledger_id
           );

       IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
       END IF;
  END IF;
  --
  -- target currency code
  --
  l_api_name:= 'GetValueChar';
  l_currency := xla_accounting_cache_pkg.GetValueChar(
                                  p_source_code        => 'XLA_CURRENCY_CODE'
                                , p_target_ledger_id   => p_target_ledger_id
                                );
  g_cache_ledgers_info.currency_code      := l_currency;

  IF g_cache_ledgers_info.currency_code IS NULL THEN

    xla_accounting_err_pkg.build_message
                       (p_appli_s_name            => 'XLA'
                       ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                       ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                       ,p_value_1                 => 'Ledger Currency Code'
                       ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                       ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                       ,p_ledger_id               => p_target_ledger_id
         );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
    END IF;

  END IF;

  --
  -- get primary coa id
  --
  l_api_name:= 'GetValueNum';
  g_cache_ledgers_info.source_coa_id  := xla_accounting_cache_pkg.GetValueNum(
                                  p_source_code       => 'XLA_COA_ID'
                                , p_target_ledger_id  => p_primary_ledger_id --g_cache_event.ledger_id
                                 );

  IF g_cache_ledgers_info.source_coa_id IS NULL THEN

    l_result := FALSE;

     xla_accounting_err_pkg.build_message
                       (p_appli_s_name            => 'XLA'
                       ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                       ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                       ,p_value_1                 => 'Chart of accounts'
                       ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                       ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                       ,p_ledger_id               => p_base_ledger_id
         );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
    END IF;
  ELSE
  --
  -- cache source coa info
  --
    XLA_AE_CODE_COMBINATION_PKG.cache_coa(p_coa_id => g_cache_ledgers_info.source_coa_id);
  --
  END IF;
  --
  -- target coa id, used to build the target code combination
  --
  l_api_name:= 'GetValueNum';
  g_cache_ledgers_info.target_coa_id  := xla_accounting_cache_pkg.GetValueNum(
                                  p_source_code       => 'XLA_COA_ID'
                                , p_target_ledger_id  => p_target_ledger_id
                                 );

  IF g_cache_ledgers_info.target_coa_id IS NULL THEN

    l_result := FALSE;

    xla_accounting_err_pkg.build_message
                           (p_appli_s_name            => 'XLA'
                           ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                           ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                           ,p_value_1                 => 'Chart of accounts'
                           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                           ,p_ledger_id               => p_target_ledger_id
         );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
    END IF;

  ELSE
  --
  -- cache target coa info
  --
    XLA_AE_CODE_COMBINATION_PKG.cache_coa( p_coa_id => g_cache_ledgers_info.target_coa_id);
  --
  END IF;
  --
  -- Get multiple posting information
  --
  l_api_name:= 'GetValueChar';
  g_cache_ledgers_info.sl_coa_mapping_name  :=  xla_accounting_cache_pkg.GetValueChar(
                                      p_source_code       => 'GL_COA_MAPPING_NAME'
                                    , p_target_ledger_id  => p_base_ledger_id
                                     );

 --
 -- get SL coa mapping id
 --
    l_api_name:= 'GetValueNum';

    l_sl_coa_mapping_id   :=  xla_accounting_cache_pkg.GetValueNum(
                                          p_source_code       => 'SL_COA_MAPPING_ID'
                                        , p_target_ledger_id  => p_base_ledger_id
                                     );

     g_cache_ledgers_info.sl_coa_mapping_id:= l_sl_coa_mapping_id;

 IF g_cache_ledgers_info.sl_coa_mapping_name IS NOT NULL  AND
    l_sl_coa_mapping_id IS NOT NULL
 THEN
       --
       -- get coa dynamic insert flag
       --
       l_api_name:= 'GetValueChar';

       g_cache_ledgers_info.dynamic_insert_flag  :=  xla_accounting_cache_pkg.GetValueChar(
                                          p_source_code       => 'DYNAMIC_INSERTS_ALLOWED_FLAG'
                                        , p_target_ledger_id  => p_base_ledger_id
                                     );

      --
        XLA_AE_CODE_COMBINATION_PKG.cacheGLMapping(
                         p_sla_coa_mapping_name => g_cache_ledgers_info.sl_coa_mapping_name
                       , p_sla_coa_mapping_id   => g_cache_ledgers_info.sl_coa_mapping_id
                       , p_dynamic_inserts_flag => g_cache_ledgers_info.dynamic_insert_flag
                        );

 END IF;
  --
  -- nls descriptions  of target ledger
  --
  l_api_name:= 'GetValueChar';
  g_cache_ledgers_info.nls_desc_language := xla_accounting_cache_pkg.GetValueChar(
                                  p_source_code        => 'XLA_NLS_DESC_LANGUAGE'
                                , p_target_ledger_id   =>  p_target_ledger_id
                                 );

  IF g_cache_ledgers_info.nls_desc_language IS NULL THEN

    l_result := FALSE;

        xla_accounting_err_pkg.build_message
                               (p_appli_s_name            => 'XLA'
                               ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                               ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                               ,p_value_1                 => 'NLS description language'
                               ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                               ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                               ,p_ledger_id               => p_target_ledger_id
         );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
    END IF;

  END IF;
  --
  -- target reversal option
  --
  l_api_name:= 'GetValueChar';
  g_cache_ledgers_info.ledger_reversal_option  :=  xla_accounting_cache_pkg.GetValueChar(
                                  p_source_code       => 'XLA_ACCT_REVERSAL_OPTION'
                                , p_target_ledger_id  => p_target_ledger_id
                                );



  --
  IF g_cache_ledgers_info.ledger_reversal_option IS NOT NULL AND
     g_cache_ledgers_info.ledger_reversal_option NOT IN ('SIDE','SIGN') THEN

    l_result := FALSE;

    xla_accounting_err_pkg.build_message
                           (p_appli_s_name            => 'XLA'
                           ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                           ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                           ,p_value_1                 => 'Accounting Reversal Option'
                           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                           ,p_ledger_id               => p_target_ledger_id
         );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
              trace
                   (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                   ,p_level    => C_LEVEL_ERROR
                   ,p_module   => l_log_module);
    END IF;

  END IF;
  --
  --

  -- ledger category code
  --
  l_api_name:= 'GetValueChar';
  l_category_code:= xla_accounting_cache_pkg.GetValueChar(
                                  p_source_code        => 'LEDGER_CATEGORY_CODE'
                                , p_target_ledger_id   => p_target_ledger_id
                                );

  g_cache_ledgers_info.ledger_category_code :=l_category_code;

  IF l_category_code IS NULL THEN

    xla_accounting_err_pkg.build_message
                       (p_appli_s_name            => 'XLA'
                       ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                       ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                       ,p_value_1                 => 'Ledger Category Code'
                       ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                       ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                       ,p_ledger_id               => p_primary_ledger_id
         );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
    END IF;

  END IF;

  g_cache_ledgers_info.calculate_amts_flag:='Y';


  IF(l_category_code= 'SECONDARY') THEN

    -- primary currency code
    --
    l_api_name:= 'GetValueChar';
    l_primary_currency:= xla_accounting_cache_pkg.GetValueChar(
                                  p_source_code        => 'XLA_CURRENCY_CODE'
                                , p_target_ledger_id   => p_primary_ledger_id
                                );

    IF l_primary_currency IS NULL THEN

      xla_accounting_err_pkg.build_message
                       (p_appli_s_name            => 'XLA'
                       ,p_msg_name                => 'XLA_AP_INVALID_SYSTEM_SOURCE'
                       ,p_token_1                 => 'SYSTEM_SOURCE_NAME'
                       ,p_value_1                 => 'Ledger Currency Code'
                       ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                       ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                       ,p_ledger_id               => p_primary_ledger_id
         );

      IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SYSTEM_SOURCE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
      END IF;

    END IF;
    IF l_primary_currency = l_currency THEN
      g_cache_ledgers_info.calculate_amts_flag:='N';
    END IF;
  ELSIF l_category_code= 'ALC' THEN
    l_alc_enabled_flag :=xla_accounting_cache_pkg.GetValueChar('XLA_ALC_ENABLED_FLAG');
    IF(l_alc_enabled_flag = 'N') THEN
      g_cache_ledgers_info.calculate_amts_flag:='N';
    END IF;
  END IF;


-----------------------------------------------------------------------
--
-- Call insert_diag_ledger to store event information
--
-----------------------------------------------------------------------
IF ( xla_accounting_engine_pkg.g_diagnostics_mode = 'Y') THEN

   trace
         (p_msg      => '-> Call Extract Source Values Diagnostics routine'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   insert_diag_ledger(
                        p_application_id      => p_application_id
                       ,p_ledger_id           => p_target_ledger_id
                       ,p_primary_ledger_id   => p_primary_ledger_id
                       ,p_pad_start_date      => p_pad_start_date
                       ,p_pad_end_date        => p_pad_end_date
                       );
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'description_language = '||g_cache_ledgers_info.description_language||
                         ' - sla_ledger_id = '||g_cache_ledgers_info.sla_ledger_id||
                         ' - currency_code = '||g_cache_ledgers_info.currency_code||
                         ' - source_coa_id = '||g_cache_ledgers_info.source_coa_id||
                         ' - target_coa_id = '||g_cache_ledgers_info.target_coa_id||
                         ' - sl_coa_mapping_name = '||g_cache_ledgers_info.sl_coa_mapping_name||
                         ' - dynamic_insert_flag = '||g_cache_ledgers_info.dynamic_insert_flag||
                         ' - nls_desc_language = '||g_cache_ledgers_info.nls_desc_language||
                         ' - calculate_amts_flag= '||g_cache_ledgers_info.calculate_amts_flag||
                         ' - ledger_category_code= '||g_cache_ledgers_info.ledger_category_code||
                         ' - ledger_reversal_option = '||g_cache_ledgers_info.ledger_reversal_option

         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetLedgersInfo'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
--
EXCEPTION
  --
WHEN xla_exceptions_pkg.application_exception THEN
   xla_accounting_err_pkg.build_message
                                       (p_appli_s_name            => 'XLA'
                                       ,p_msg_name                => 'XLA_AP_ACCT_ENGINE_ERROR'
                                       ,p_token_1                 => 'PROCEDURE'
                                       ,p_value_1                 => 'xla_accounting_cache_pkg.'||l_api_name
                                       ,p_entity_id               => g_cache_event.entity_id
                                       ,p_event_id                => g_cache_event.event_id
                                       ,p_ledger_id               => g_cache_event.target_ledger_id
                              );

  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
     trace
         (p_msg      => 'ERROR: XLA_AP_ACCT_ENGINE_ERROR'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);

  END IF;
  RAISE;
WHEN OTHERS  THEN
     xla_exceptions_pkg.raise_message
             (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.GetLedgersInfo');
       --
END GetLedgersInfo;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
FUNCTION  GetTranslatedEventInfo
RETURN BOOLEAN
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetTranslatedEventInfo';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of  GetTranslatedEventInfo'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => '-> CALL xla_accounting_cache_pkg.get_event_info API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

 xla_accounting_cache_pkg.get_event_info
        (p_ledger_id                  => g_cache_event.target_ledger_id
        ,p_event_class_code           => g_cache_event.event_class
        ,p_event_type_code            => g_cache_event.event_type
        ,p_ledger_event_class_name    => g_cache_event_tl.event_class_name
        ,p_session_event_class_name   => g_cache_event_tl.session_event_class
        ,p_ledger_event_type_name     => g_cache_event_tl.event_type_name
        ,p_session_event_type_name    => g_cache_event_tl.session_event_type
       );

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of  GetTranslatedEventInfo'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN TRUE;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   xla_accounting_err_pkg.build_message
                                       (p_appli_s_name            => 'XLA'
                                       ,p_msg_name                => 'XLA_AP_ACCT_ENGINE_ERROR'
                                       ,p_token_1                 => 'PROCEDURE'
                                       ,p_value_1                 => 'xla_accounting_cache_pkg.get_event_info'
                                       ,p_entity_id               => g_cache_event.entity_id
                                       ,p_event_id                => g_cache_event.event_id
                                       ,p_ledger_id               => g_cache_event.target_ledger_id
                              );


  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN

         trace
             (p_msg      => 'ERROR: XLA_AP_ACCT_ENGINE_ERROR'
             ,p_level    => C_LEVEL_EXCEPTION
             ,p_module   => l_log_module);

  END IF;
  RAISE;
WHEN OTHERS  THEN
     xla_exceptions_pkg.raise_message
             (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.GetTranslatedEventInfo');
END GetTranslatedEventInfo;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE free_ae_cache
IS
l_null_event             t_rec_event;
l_null_pad               t_rec_product_rule;
l_null_ledgers_info      t_rec_ledgers_info;
l_null_event_tl          t_rec_event_tl;
l_null_sc_value_set      XLA_AE_SOURCES_PKG.t_array_meaning;
--
l_log_module         VARCHAR2(240);
--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.free_ae_cache';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of free_ae_cache'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

   g_global_status             := 2;
   g_cache_event               := l_null_event;
   g_cache_pad                 := l_null_pad;
   g_cache_ledgers_info        := l_null_ledgers_info;
   g_cache_event_tl            := l_null_event_tl;
   --
   XLA_AE_HEADER_PKG.RefreshHeader;
   XLA_AE_LINES_PKG.RefreshLines;
   --
   -- free source value set cache
   --
   XLA_AE_SOURCES_PKG.g_array_meaning:= l_null_sc_value_set;
   --
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of free_ae_cache'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.free_ae_cache');
--
END free_ae_cache;
--
--
/*======================================================================+
|                                                                       |
| GetLineNumber                                                         |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE GetLineNumber
IS
--
l_ae_line_num   NUMBER;
l_ae_header_id  NUMBER;
l_log_module         VARCHAR2(240);
--
type t_array_rowid is table of rowid index by binary_integer;


l_array_rowid        t_array_rowid;
l_array_rowid1       t_array_rowid;
l_array_ae_line_num  t_array_Num;
l_array_doc_rounding_amt1   t_array_Num;
l_array_rounding_entd_amt1   t_array_Num;
l_array_ledger_id    t_array_ledger_id;
l_array_header_id    t_array_Num;
/*
l_array_base_ledgers      xla_accounting_cache_pkg.t_array_ledger_id;
l_array_alc_ledgers       xla_accounting_cache_pkg.t_array_ledger_id ;
l_array_ledgers           xla_accounting_cache_pkg.t_array_ledger_id ;
*/
l_rounding_rule_code VARCHAR2(30);
l_array_rounding_offset  t_array_Num;
l_array_mau              t_array_Num;
l_array_rounding_class_code  t_array_V30L;
l_array_doc_rounding_level   t_array_V30L;
l_array_unrounded_amount     t_array_Num;
l_array_unrounded_entd_amount     t_array_Num;
l_array_entd_mau              t_array_Num;

l_curr_rounding_class_code VARCHAR2(30);
l_curr_doc_rounding_level  VARCHAR2(30);
l_curr_doc_rounding_amount NUMBER;
l_curr_entd_rounding_amount NUMBER;
l_curr_total_unrounded     NUMBER;
l_curr_total_rounded       NUMBER;
l_curr_entd_total_unrounded     NUMBER;
l_curr_entd_total_rounded       NUMBER;
l_curr_max_rowid           ROWID;
l_curr_max_amount          NUMBER;
l_curr_ledger_id           NUMBER;
l_curr_header_id           NUMBER;
l_curr_mau                 NUMBER;
l_curr_entd_mau            NUMBER;
l_curr_offset              NUMBER;
j                          NUMBER;


l_count             NUMBER :=1;

l_ledger_attrs       xla_accounting_cache_pkg.t_array_ledger_attrs;

CURSOR csr_rounding_lines is
SELECT max(xalg.rowid)
       ,rounding_class_code
       ,document_rounding_level
       ,NVL(SUM(unrounded_accounted_cr), 0)
                - NVL(SUM(unrounded_accounted_dr), 0) unrounded_amount
       ,ledger_id
       ,ae_header_id
       ,NVL(SUM(unrounded_entered_cr), 0)
                - NVL(SUM(unrounded_entered_dr), 0) unrounded_entered_amount
       ,entered_currency_mau
FROM   xla_ae_lines_gt xalg
WHERE temp_line_num <> 0
GROUP BY ledger_id, event_id, ae_header_id,
         rounding_class_code, document_rounding_level, ae_line_num
         ,entered_currency_mau
HAVING document_rounding_level is not null
   AND rounding_class_code is not null
ORDER BY document_rounding_level, rounding_class_code;


BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetLineNumber';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetLineNumber'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

xla_accounting_cache_pkg.GetLedgerArray(l_ledger_attrs);

For i in 1..l_ledger_attrs.array_ledger_id.COUNT LOOP
  l_array_mau(l_ledger_attrs.array_ledger_id(i)) := l_ledger_attrs.array_mau(i);
  l_array_rounding_offset(l_ledger_attrs.array_ledger_id(i)) :=
                                        l_ledger_attrs.array_rounding_offset(i);
END LOOP;

BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

IF g_array_event_id.count > 0 then
forall i in 1..g_array_event_id.count
 -- added the hint for bug:7560587
update /*+ index(ael,XLA_AE_LINES_GT_N4) */ xla_ae_lines_gt  ael
set ae_header_id = g_array_ae_header_id(i)
   ,ref_ae_header_id = DECODE(ref_event_id,NULL,g_array_ae_header_id(i),ref_ae_header_id)
/* Calling get_hash_value for each row is expensive.
   Moved the columns to the select statement to retrieve ae_line_num.

   ,line_hash_num =
DBMS_UTILITY.GET_HASH_VALUE
        (ae_header_id
        ||gl_transfer_mode_code
        ||accounting_class_code
        ||rounding_class_code
        ||document_rounding_level
        ||currency_code
        ||currency_conversion_type
        ||currency_conversion_date
        ||currency_conversion_rate
        ||party_id
        ||party_site_id
        ||party_type_code
        ||code_combination_id
        ||code_combination_status_code
        ||segment1
        ||segment2
        ||segment3
        ||segment4
        ||segment5
        ||segment6
        ||segment7
        ||segment8
        ||segment9
        ||segment10
        ||segment11
        ||segment12
        ||segment13
        ||segment14
        ||segment15
        ||segment16
        ||segment17
        ||segment18
        ||segment19
        ||segment20
        ||segment21
        ||segment22
        ||segment23
        ||segment24
        ||segment25
        ||segment26
        ||segment27
        ||segment28
        ||segment29
        ||segment30
        ||alt_code_combination_id
        ||alt_ccid_status_code
        ||alt_segment1
        ||alt_segment2
        ||alt_segment3
        ||alt_segment4
        ||alt_segment5
        ||alt_segment6
        ||alt_segment7
        ||alt_segment8
        ||alt_segment9
        ||alt_segment10
        ||alt_segment11
        ||alt_segment12
        ||alt_segment13
        ||alt_segment14
        ||alt_segment15
        ||alt_segment16
        ||alt_segment17
        ||alt_segment18
        ||alt_segment19
        ||alt_segment20
        ||alt_segment21
        ||alt_segment22
        ||alt_segment23
        ||alt_segment24
        ||alt_segment25
        ||alt_segment26
        ||alt_segment27
        ||alt_segment28
        ||alt_segment29
        ||alt_segment30
        ||description
        ||jgzz_recon_ref
        ||ussgl_transaction_code
        ||merge_duplicate_code
        ||line_definition_owner_code
        ||line_definition_code
        ||business_class_code
        ||mpa_accrual_entry_flag
        ||encumbrance_type_id,
       1,
       1073741824)
*/
   , merge_index = CASE accounting_class_code
                   WHEN 'DUMMY_EXCHANGE_GAIN_LOSS_DUMMY' THEN -1
                   ELSE
                     CASE nvl(code_combination_id,0)
                     WHEN -1 THEN temp_line_num
                     ELSE CASE nvl(alt_code_combination_id,0)
                         WHEN -1 THEN temp_line_num
                         ELSE
                          CASE merge_duplicate_code
                            WHEN 'A' THEN
                              CASE switch_side_flag
                              WHEN 'Y' THEN -1
                              ELSE
                                CASE
                                  WHEN unrounded_accounted_cr is null THEN -2
                                  ELSE -3
                                END
                              END
                            WHEN 'W' THEN
                               CASE
                                 WHEN unrounded_accounted_cr is null THEN -2
                                 ELSE -3
                               END
                            WHEN 'N' THEN temp_line_num
                           END
                         END
                      END
                    END
    /* CASE merge_duplicate_code
                    WHEN 'A' THEN
                      CASE switch_side_flag
                       WHEN 'Y' THEN -1
                       ELSE
                         CASE
                          WHEN accounted_cr is null THEN -2
                          ELSE -3
                         END
                       END
                    WHEN 'W' THEN
                      CASE
                       WHEN accounted_cr is null THEN -2
                       ELSE -3
                      END
                    WHEN 'N' THEN temp_line_num
                   END*/
where ae_header_id = g_array_event_id(i)
  and event_id = g_array_event_id(i)
  and ledger_id = g_array_ledger_id(i)
  and balance_type_code = g_array_balance_type(i)
  --
  -- Bug 4719297 added NVL to the following.
  --
-- 4669308 NVL(-1) creates a separate header for MPA reversal. NVL(0) combines original reversal and MPA reversal into 1 header
--         Also, this was causing XLA_AE_LINES_U1 error
--and nvl(header_num,-1) = nvl(g_array_header_num(i),-1)
  and     header_num     = nvl(g_array_header_num(i), 0);  -- 5100860 instead of nvl(header_num, 0)
--and temp_line_num <> 0;                                  -- 5100860 should never be zero
end if;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 2'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

   UpdateLineNumber;

-- 4262811 ------------------------------------------------------------------
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 3.5'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;


----------------------------------------------------------
-- Populate the parent_ae_line_num by the real ae_line_num
----------------------------------------------------------
/* PROBLEM: incorrectly sets parent_ae_line_num to NULL
forall i in 1..l_array_rowid.count
update xla_ae_headers_gt h
   set parent_ae_line_num =
       (select l_array_ae_line_num(i)
          from xla_ae_lines_gt l
         where h.parent_header_id    = l.event_id   -- awan l.ae_header_id no rows
           and h.ledger_id           = l.ledger_id
           and h.balance_type_code   = l.balance_type_code
           and h.event_id            = l.event_id
           and l.header_num          = 0
           and l.rowid               = l_array_rowid(i))
 where parent_ae_line_num IS NOT NULL;
*/
  -- IF l_array_rowid.count > 0 THEN      commented IF for 7230462
      UPDATE xla_ae_headers_gt h
      SET    parent_ae_line_num =
          (SELECT ae_line_num
             FROM xla_ae_lines_gt l
            WHERE h.parent_header_id    = l.event_id   -- awan l.ae_header_id no rows
              AND h.ledger_id           = l.ledger_id
              AND h.balance_type_code   = l.balance_type_code
              AND h.event_id            = l.event_id
              AND h.event_id            = l.event_id
              AND h.parent_ae_line_num  = l.temp_line_num
              AND l.header_num          = 0)
      WHERE parent_ae_line_num IS NOT NULL;
  -- END IF;

-----------------------------------------------------------------------------

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 4'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

UPDATE xla_ae_lines_gt  ael
   SET (ref_ae_header_id, ref_temp_line_num) =
          (SELECT ae_header_id, temp_line_num
             FROM xla_ae_lines_gt
            WHERE event_id = ael.ref_event_id
              AND ledger_id = ael.ledger_id
              AND balance_type_code = ael.balance_type_code
              AND temp_line_num = ael.temp_line_num * -1)
 WHERE ref_event_id IS NOT NULL
   AND ref_temp_line_num IS NULL;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 5'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

-- added the follwing update to correct REF_AE_HEADER_ID when ORIGINAL AND REVERSAL EVENTS
-- are accounted in the same batch for bug:8277823
-- commented the following code for performance issues faced in bug: 8619700
/*
UPDATE xla_ae_lines_gt  ael
   SET ael.ref_event_id     = -1 * ael.ref_event_id
     , ael.ref_ae_header_id =
                             ( SELECT lgt.ae_header_id
                               FROM  xla_ae_lines_gt lgt
                               WHERE lgt.event_id = -1 * ael.ref_event_id
                               AND   lgt.ledger_id = ael.ledger_id
                               AND   lgt.balance_type_code = ael.balance_type_code
                               AND   lgt.temp_line_num = ael.temp_line_num * -1
			    )
 WHERE ael.ref_event_id < 0
   AND ael.temp_line_num < 0
   AND ael.reversal_code = 'REVERSAL' ;
*/
-- added the following code for performance issues faced in bug:8619700
   forall i in 1..g_array_event_id.count
   UPDATE XLA_AE_LINES_GT AEL
       SET AEL.REF_EVENT_ID = -1 * AEL.REF_EVENT_ID ,
           AEL.REF_AE_HEADER_ID =  g_array_ae_header_id(i)
   WHERE AEL.REF_AE_HEADER_ID = g_array_event_id(i)
   AND   AEL.REF_EVENT_ID = -1 * g_array_event_id(i)
   AND   AEL.TEMP_LINE_NUM < 0
   AND   AEL.LEDGER_ID = g_array_ledger_id(i)
   AND   AEL.BALANCE_TYPE_CODE = g_array_balance_type(i)
   AND   AEL.REVERSAL_CODE = 'REVERSAL'
   AND   AEL.HEADER_NUM = NVL( g_array_header_num(i) , 0) ;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 5_1 for ReversalEvents '|| SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   -- end of changes for bug: 8277823

open csr_rounding_lines;
  j:=1;
/*
  l_curr_rounding_class_code := l_array_rounding_class_code(1);
  l_curr_doc_rounding_level := l_array_doc_rounding_level(1);
  l_curr_total_unrounded :=0;
  l_curr_total_rounded :=0;
  l_curr_max_rowid := l_array_rowid(1);
  l_curr_max_amount := ABS(l_array_unrounded_amount(1));
  l_curr_ledger_id :=l_array_ledger_id(1);
  l_curr_header_id :=l_array_header_id(1);
  l_curr_mau := l_array_mau(l_curr_ledger_id);
  l_curr_offset := l_array_rounding_offset(l_curr_ledger_id);
*/
  l_curr_rounding_class_code := null;
  l_curr_doc_rounding_level := null;
  l_curr_total_unrounded :=null;
  l_curr_total_rounded :=null;
  l_curr_max_rowid :=null;
  l_curr_max_amount := null;
  l_curr_ledger_id :=null;
  l_curr_header_id :=null;
  l_curr_mau := null;
  l_curr_entd_mau := null;
  l_curr_offset := null;
  l_curr_entd_rounding_amount := null;
  l_curr_entd_total_unrounded :=null;
  l_curr_entd_total_rounded :=null;

LOOP
  FETCH csr_rounding_lines
  BULK COLLECT INTO l_array_rowid
                 ,l_array_rounding_class_code
                 ,l_array_doc_rounding_level
                 ,l_array_unrounded_amount
                 ,l_array_ledger_id
                 ,l_array_header_id
                 ,l_array_unrounded_entd_amount
                 ,l_array_entd_mau
  LIMIT C_BULK_LIMIT;

  IF(l_array_rounding_class_code.COUNT=0) THEN
    EXIT;
  END IF;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 6'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'count:'||to_char(l_array_rounding_class_code.count)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  FOR Idx IN l_array_rounding_class_code.FIRST .. l_array_rounding_class_code.LAST LOOP
    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Ixd:'||to_char(Idx) ||' rounding class code:'||l_array_rounding_class_code(Idx) || ' rounding level:'||l_array_doc_rounding_level(Idx)
                           || ' ledgerid:'||to_char(l_array_ledger_id(Idx))||' unrounded:'|| to_char(l_curr_total_unrounded)
                           ||' rounded:'|| to_char(l_curr_total_rounded)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'amount:'||to_char(l_array_unrounded_amount(Idx))||'curr mau:'||to_char(l_curr_mau)||' curr offset:'||to_char(l_curr_offset)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'cur rounding class code:'||l_curr_rounding_class_code || ' rounding level:'||l_curr_doc_rounding_level || ' ledgerid:'||to_char(l_curr_ledger_id)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => ' unrounded entered:'|| to_char(l_curr_entd_total_unrounded)
                           ||' rounded entered:'|| to_char(l_curr_entd_total_rounded)
                           ||' amount:'|| to_char(l_array_unrounded_entd_amount(Idx))
                           ||' mau:'|| to_char(l_array_entd_mau(Idx))
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

    IF(l_array_rounding_class_code(Idx) = l_curr_rounding_class_code
         AND l_array_doc_rounding_level(Idx) = l_curr_doc_rounding_level
         AND  l_array_header_id(Idx) = l_curr_header_id
         AND  l_array_ledger_id(Idx) = l_curr_ledger_id) THEN
      l_curr_total_unrounded:= l_curr_total_unrounded + l_array_unrounded_amount(Idx);
      l_curr_total_rounded:= l_curr_total_rounded
             + ROUND( l_array_unrounded_amount(Idx)/l_curr_mau + l_curr_offset)
             *l_curr_mau;
      l_curr_entd_total_unrounded:= l_curr_entd_total_unrounded + l_array_unrounded_entd_amount(Idx);
      l_curr_entd_total_rounded:= l_curr_entd_total_rounded
             + ROUND( l_array_unrounded_entd_amount(Idx)/l_array_entd_mau(Idx)+ l_curr_offset)
             *l_array_entd_mau(Idx);
      IF(l_curr_max_amount < ABS(l_array_unrounded_amount(Idx))) THEN
        l_curr_max_amount := ABS(l_array_unrounded_amount(Idx));
        l_curr_max_rowid := l_array_rowid(Idx);
      END IF;
    ELSE
      IF(l_curr_total_unrounded is not null) THEN
        l_curr_doc_rounding_amount :=
             ROUND(l_curr_total_unrounded/l_curr_mau + l_curr_offset)
             *l_curr_mau -l_curr_total_rounded;
        l_curr_entd_rounding_amount :=
             ROUND(l_curr_entd_total_unrounded/l_curr_entd_mau + l_curr_offset)
             *l_curr_entd_mau -l_curr_entd_total_rounded;
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
            (p_msg      => 'doc rounding is:'||to_char(l_curr_doc_rounding_amount)
                           ||' unrounded:'|| to_char(l_curr_total_unrounded)
                           ||' rounded:'|| to_char(l_curr_total_rounded)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
           trace
            (p_msg      => 'entd rounding is:'||to_char(l_curr_entd_rounding_amount)
                           ||' unrounded:'|| to_char(l_curr_entd_total_unrounded)
                           ||' rounded:'|| to_char(l_curr_entd_total_rounded)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
        END IF;
        IF(l_curr_doc_rounding_amount <>0 or l_curr_entd_rounding_amount <> 0) THEN
          l_array_rowid1(j):= l_curr_max_rowid;
          l_array_doc_rounding_amt1(j) := l_curr_doc_rounding_amount;
          l_array_rounding_entd_amt1(j) := l_curr_entd_rounding_amount;
          j:= j+1;
          IF (j> C_BULK_LIMIT) THEN
            FORALL i in 1..j-1
              update xla_ae_lines_gt
              set doc_rounding_acctd_amt = l_array_doc_rounding_amt1(i)
                 ,doc_rounding_entered_amt = l_array_rounding_entd_amt1(i)
              where rowid = l_array_rowid1(i);
            j:=1;
          END IF;
        END IF;
      END IF;
      IF(l_curr_ledger_id is null or
             l_curr_ledger_id <> l_array_ledger_id(Idx)) THEN
        l_curr_ledger_id :=l_array_ledger_id(Idx);
        l_curr_mau := l_array_mau(l_curr_ledger_id);
        l_curr_offset := l_array_rounding_offset(l_curr_ledger_id);
      END IF;
      l_curr_entd_mau:=l_array_entd_mau(Idx);
      l_curr_header_id :=l_array_header_id(Idx);
      l_curr_rounding_class_code := l_array_rounding_class_code(Idx);
      l_curr_doc_rounding_level := l_array_doc_rounding_level(Idx);
      l_curr_total_unrounded:= l_array_unrounded_amount(Idx);
      l_curr_total_rounded:=
             ROUND( l_array_unrounded_amount(Idx)/l_curr_mau + l_curr_offset)
             *l_curr_mau;
      l_curr_entd_total_unrounded:= l_array_unrounded_entd_amount(Idx);
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
            (p_msg      => '----l_curr_entd_total_rounded:'||to_char(l_curr_entd_total_rounded)
                           ||' l_array_unrounded_entd_amount(Idx):'|| to_char(l_array_unrounded_entd_amount(Idx))
                           ||' l_curr_entd_mau:'|| to_char(l_curr_entd_mau)
                           ||'l_curr_offset :'|| to_char(l_curr_offset)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
        END IF;
      l_curr_entd_total_rounded:=
             ROUND( l_array_unrounded_entd_amount(Idx)/l_curr_entd_mau+ l_curr_offset)
             *l_curr_entd_mau;
        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
            (p_msg      => '----l_curr_entd_total_rounded:'||to_char(l_curr_entd_total_rounded)
                           ||' l_array_unrounded_entd_amount(Idx):'|| to_char(l_array_unrounded_entd_amount(Idx))
                           ||' l_curr_entd_mau:'|| to_char(l_curr_entd_mau)
                           ||'l_curr_offset :'|| to_char(l_curr_offset)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
           trace
            (p_msg      => '----test:'||to_char(l_array_unrounded_entd_amount(Idx)/l_curr_entd_mau)
                           ||' :'|| to_char(l_array_unrounded_entd_amount(Idx)/l_curr_entd_mau+ l_curr_offset)
                           ||' :'|| to_char(ROUND( l_array_unrounded_entd_amount(Idx)/l_curr_entd_mau+ l_curr_offset))
                           ||':'|| to_char(ROUND( l_array_unrounded_entd_amount(Idx)/l_curr_entd_mau+ l_curr_offset)*l_curr_entd_mau)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
        END IF;
      l_curr_max_rowid := l_array_rowid(Idx);
      l_curr_max_amount := ABS(l_array_unrounded_amount(Idx));
    END IF;
  END LOOP;
END LOOP;
-- process the last one
IF(l_curr_total_unrounded is not null) THEN
  l_curr_doc_rounding_amount :=
             ROUND(l_curr_total_unrounded/l_curr_mau + l_curr_offset)
             *l_curr_mau -l_curr_total_rounded;
  l_curr_entd_rounding_amount :=
             ROUND(l_curr_entd_total_unrounded/l_curr_entd_mau + l_curr_offset)
             *l_curr_entd_mau -l_curr_entd_total_rounded;
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'doc rounding is:'||to_char(l_curr_doc_rounding_amount)
                           ||' unrounded:'|| to_char(l_curr_total_unrounded)
                           ||' rounded:'|| to_char(l_curr_total_rounded)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
  END IF;
END IF;
IF(l_curr_doc_rounding_amount <>0  or l_curr_entd_rounding_amount <> 0) THEN
  l_array_rowid1(j):= l_curr_max_rowid;
  l_array_doc_rounding_amt1(j) := l_curr_doc_rounding_amount;
  l_array_rounding_entd_amt1(j) := l_curr_entd_rounding_amount;
  j:= j+1;
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 7, j='||to_char(j)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF j>1 THEN
  FORALL i in 1..j-1
    update xla_ae_lines_gt
    set doc_rounding_acctd_amt = l_array_doc_rounding_amt1(i)
       ,doc_rounding_entered_amt = l_array_rounding_entd_amt1(i)
    where rowid = l_array_rowid1(i);
END IF;

EXCEPTION
WHEN OTHERS  THEN

  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => sqlerrm
                                    );
END;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetLineNumber'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
  xla_exceptions_pkg.raise_message
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.GetLineNumber');
END GetLineNumber;

PROCEDURE UpdateLineNumber IS

   l_line_ac_count      PLS_INTEGER;
   l_log_module         VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateLineNumber0';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of UpdateLineNumber0'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   l_line_ac_count := xla_analytical_criteria_pkg.get_line_ac_count;

   IF l_line_ac_count = 0 THEN

      UpdateLineNumber0;

   ELSIF l_line_ac_count <= 10 THEN

      UpdateLineNumber10;

   ELSIF l_line_ac_count <= 50 THEN

      UpdateLineNumber50;

   ELSIF l_line_ac_count <= 100 THEN

      UpdateLineNumber100;

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of UpdateLineNumber'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
  xla_exceptions_pkg.raise_message
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.UpdateLineNumber');
END UpdateLineNumber;


PROCEDURE UpdateLineNumber0 IS

   l_array_rowid        t_array_rowid;
   l_array_ae_line_num  t_array_Num;

   l_log_module         VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateLineNumber0';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of UpdateLineNumber0'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   SELECT ROWID
         ,DENSE_RANK() OVER
          (PARTITION BY ae_header_id
               ORDER BY ae_header_id
                       ,gl_transfer_mode_code
                       ,accounting_class_code
		       ,event_type_code
                       ,rounding_class_code
                       ,document_rounding_level
                       ,currency_code
                       ,currency_conversion_type
                       ,currency_conversion_date
                       ,currency_conversion_rate
                       ,party_id
                       ,party_site_id
                       ,party_type_code
                       ,code_combination_id
                       ,code_combination_status_code
                       ,segment1
                       ,segment2
                       ,segment3
                       ,segment4
                       ,segment5
                       ,segment6
                       ,segment7
                       ,segment8
                       ,segment9
                       ,segment10
                       ,segment11
                       ,segment12
                       ,segment13
                       ,segment14
                       ,segment15
                       ,segment16
                       ,segment17
                       ,segment18
                       ,segment19
                       ,segment20
                       ,segment21
                       ,segment22
                       ,segment23
                       ,segment24
                       ,segment25
                       ,segment26
                       ,segment27
                       ,segment28
                       ,segment29
                       ,segment30
                       ,alt_code_combination_id
                       ,alt_ccid_status_code
                       ,alt_segment1
                       ,alt_segment2
                       ,alt_segment3
                       ,alt_segment4
                       ,alt_segment5
                       ,alt_segment6
                       ,alt_segment7
                       ,alt_segment8
                       ,alt_segment9
                       ,alt_segment10
                       ,alt_segment11
                       ,alt_segment12
                       ,alt_segment13
                       ,alt_segment14
                       ,alt_segment15
                       ,alt_segment16
                       ,alt_segment17
                       ,alt_segment18
                       ,alt_segment19
                       ,alt_segment20
                       ,alt_segment21
                       ,alt_segment22
                       ,alt_segment23
                       ,alt_segment24
                       ,alt_segment25
                       ,alt_segment26
                       ,alt_segment27
                       ,alt_segment28
                       ,alt_segment29
                       ,alt_segment30
                       ,description
                       ,jgzz_recon_ref
                       ,ussgl_transaction_code
                       ,merge_duplicate_code
                       ,line_definition_owner_code
                       ,line_definition_code
                       ,business_class_code
                       ,mpa_accrual_entry_flag
                       ,encumbrance_type_id
                       ,merge_index
		       ,calculate_g_l_amts_flag
		       ,entered_currency_mau)

                        ae_line_num
    BULK COLLECT
    INTO l_array_rowid
        ,l_array_ae_line_num
    FROM xla_ae_lines_gt
   WHERE temp_line_num <> 0;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 3'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

   FORALL i IN 1..l_array_rowid.COUNT
     UPDATE xla_ae_lines_gt
        SET ae_line_num = l_array_ae_line_num(i)
      WHERE rowid = l_array_rowid(i);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of UpdateLineNumber0'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
  xla_exceptions_pkg.raise_message
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.UpdateLineNumber0');
END UpdateLineNumber0;


PROCEDURE UpdateLineNumber10 IS

   l_array_rowid        t_array_rowid;
   l_array_ae_line_num  t_array_Num;

   l_log_module         VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateLineNumber10';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of UpdateLineNumber10'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

SELECT ROWID
      ,DENSE_RANK() OVER
          (PARTITION BY ae_header_id
               ORDER BY ae_header_id
                       ,gl_transfer_mode_code
                       ,accounting_class_code
                       ,event_type_code
                       ,rounding_class_code
                       ,document_rounding_level
                       ,currency_code
                       ,currency_conversion_type
                       ,currency_conversion_date
                       ,currency_conversion_rate
                       ,party_id
                       ,party_site_id
                       ,party_type_code
                       ,code_combination_id
                       ,code_combination_status_code
                       ,segment1
                       ,segment2
                       ,segment3
                       ,segment4
                       ,segment5
                       ,segment6
                       ,segment7
                       ,segment8
                       ,segment9
                       ,segment10
                       ,segment11
                       ,segment12
                       ,segment13
                       ,segment14
                       ,segment15
                       ,segment16
                       ,segment17
                       ,segment18
                       ,segment19
                       ,segment20
                       ,segment21
                       ,segment22
                       ,segment23
                       ,segment24
                       ,segment25
                       ,segment26
                       ,segment27
                       ,segment28
                       ,segment29
                       ,segment30
                       ,alt_code_combination_id
                       ,alt_ccid_status_code
                       ,alt_segment1
                       ,alt_segment2
                       ,alt_segment3
                       ,alt_segment4
                       ,alt_segment5
                       ,alt_segment6
                       ,alt_segment7
                       ,alt_segment8
                       ,alt_segment9
                       ,alt_segment10
                       ,alt_segment11
                       ,alt_segment12
                       ,alt_segment13
                       ,alt_segment14
                       ,alt_segment15
                       ,alt_segment16
                       ,alt_segment17
                       ,alt_segment18
                       ,alt_segment19
                       ,alt_segment20
                       ,alt_segment21
                       ,alt_segment22
                       ,alt_segment23
                       ,alt_segment24
                       ,alt_segment25
                       ,alt_segment26
                       ,alt_segment27
                       ,alt_segment28
                       ,alt_segment29
                       ,alt_segment30
                       ,description
                       ,jgzz_recon_ref
                       ,ussgl_transaction_code
                       ,merge_duplicate_code
                       ,analytical_balance_flag
                       ,anc_id_1
                       ,anc_id_2
                       ,anc_id_3
                       ,anc_id_4
                       ,anc_id_5
                       ,anc_id_6
                       ,anc_id_7
                       ,anc_id_8
                       ,anc_id_9
                       ,anc_id_10
                       ,anc_id_11
                       ,anc_id_12
                       ,anc_id_13
                       ,anc_id_14
                       ,anc_id_15
                       ,anc_id_16
                       ,anc_id_17
                       ,anc_id_18
                       ,anc_id_19
                       ,anc_id_20
                       ,anc_id_21
                       ,anc_id_22
                       ,anc_id_23
                       ,anc_id_24
                       ,anc_id_25
                       ,anc_id_26
                       ,anc_id_27
                       ,anc_id_28
                       ,anc_id_29
                       ,anc_id_30
                       ,anc_id_31
                       ,anc_id_32
                       ,anc_id_33
                       ,anc_id_34
                       ,anc_id_35
                       ,anc_id_36
                       ,anc_id_37
                       ,anc_id_38
                       ,anc_id_39
                       ,anc_id_40
                       ,anc_id_41
                       ,anc_id_42
                       ,anc_id_43
                       ,anc_id_44
                       ,anc_id_45
                       ,anc_id_46
                       ,anc_id_47
                       ,anc_id_48
                       ,anc_id_49
                       ,anc_id_50
                       ,anc_id_51
                       ,anc_id_52
                       ,anc_id_53
                       ,anc_id_54
                       ,anc_id_55
                       ,anc_id_56
                       ,anc_id_57
                       ,anc_id_58
                       ,anc_id_59
                       ,anc_id_60
                       ,anc_id_61
                       ,anc_id_62
                       ,anc_id_63
                       ,anc_id_64
                       ,anc_id_65
                       ,anc_id_66
                       ,anc_id_67
                       ,anc_id_68
                       ,anc_id_69
                       ,anc_id_70
                       ,anc_id_71
                       ,anc_id_72
                       ,anc_id_73
                       ,anc_id_74
                       ,anc_id_75
                       ,anc_id_76
                       ,anc_id_77
                       ,anc_id_78
                       ,anc_id_79
                       ,anc_id_80
                       ,anc_id_81
                       ,anc_id_82
                       ,anc_id_83
                       ,anc_id_84
                       ,anc_id_85
                       ,anc_id_86
                       ,anc_id_87
                       ,anc_id_88
                       ,anc_id_89
                       ,anc_id_90
                       ,anc_id_91
                       ,anc_id_92
                       ,anc_id_93
                       ,anc_id_94
                       ,anc_id_95
                       ,anc_id_96
                       ,anc_id_97
                       ,anc_id_98
                       ,anc_id_99
                       ,anc_id_100
                       ,line_definition_owner_code
                       ,line_definition_code
                       ,business_class_code
                       ,mpa_accrual_entry_flag
                       ,encumbrance_type_id
                       ,merge_index
		       ,calculate_g_l_amts_flag
		       ,entered_currency_mau)

                        ae_line_num
BULK COLLECT INTO l_array_rowid, l_array_ae_line_num
FROM xla_ae_lines_gt
WHERE temp_line_num <> 0;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 3'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

forall i in 1..l_array_rowid.count
update xla_ae_lines_gt
set ae_line_num = l_array_ae_line_num(i)
where rowid = l_array_rowid(i);



   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of UpdateLineNumber10'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
  xla_exceptions_pkg.raise_message
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.UpdateLineNumber10');
END UpdateLineNumber10;


PROCEDURE UpdateLineNumber50 IS

   l_array_rowid        t_array_rowid;
   l_array_ae_line_num  t_array_Num;

   l_log_module         VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateLineNumber50';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of UpdateLineNumber50'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

SELECT ROWID
      ,DENSE_RANK() OVER
          (PARTITION BY ae_header_id
               ORDER BY ae_header_id
                       ,gl_transfer_mode_code
                       ,accounting_class_code
                       ,event_type_code
                       ,rounding_class_code
                       ,document_rounding_level
                       ,currency_code
                       ,currency_conversion_type
                       ,currency_conversion_date
                       ,currency_conversion_rate
                       ,party_id
                       ,party_site_id
                       ,party_type_code
                       ,code_combination_id
                       ,code_combination_status_code
                       ,segment1
                       ,segment2
                       ,segment3
                       ,segment4
                       ,segment5
                       ,segment6
                       ,segment7
                       ,segment8
                       ,segment9
                       ,segment10
                       ,segment11
                       ,segment12
                       ,segment13
                       ,segment14
                       ,segment15
                       ,segment16
                       ,segment17
                       ,segment18
                       ,segment19
                       ,segment20
                       ,segment21
                       ,segment22
                       ,segment23
                       ,segment24
                       ,segment25
                       ,segment26
                       ,segment27
                       ,segment28
                       ,segment29
                       ,segment30
                       ,alt_code_combination_id
                       ,alt_ccid_status_code
                       ,alt_segment1
                       ,alt_segment2
                       ,alt_segment3
                       ,alt_segment4
                       ,alt_segment5
                       ,alt_segment6
                       ,alt_segment7
                       ,alt_segment8
                       ,alt_segment9
                       ,alt_segment10
                       ,alt_segment11
                       ,alt_segment12
                       ,alt_segment13
                       ,alt_segment14
                       ,alt_segment15
                       ,alt_segment16
                       ,alt_segment17
                       ,alt_segment18
                       ,alt_segment19
                       ,alt_segment20
                       ,alt_segment21
                       ,alt_segment22
                       ,alt_segment23
                       ,alt_segment24
                       ,alt_segment25
                       ,alt_segment26
                       ,alt_segment27
                       ,alt_segment28
                       ,alt_segment29
                       ,alt_segment30
                       ,description
                       ,jgzz_recon_ref
                       ,ussgl_transaction_code
                       ,merge_duplicate_code
                       ,analytical_balance_flag
                       ,anc_id_1
                       ,anc_id_2
                       ,anc_id_3
                       ,anc_id_4
                       ,anc_id_5
                       ,anc_id_6
                       ,anc_id_7
                       ,anc_id_8
                       ,anc_id_9
                       ,anc_id_10
                       ,anc_id_11
                       ,anc_id_12
                       ,anc_id_13
                       ,anc_id_14
                       ,anc_id_15
                       ,anc_id_16
                       ,anc_id_17
                       ,anc_id_18
                       ,anc_id_19
                       ,anc_id_20
                       ,anc_id_21
                       ,anc_id_22
                       ,anc_id_23
                       ,anc_id_24
                       ,anc_id_25
                       ,anc_id_26
                       ,anc_id_27
                       ,anc_id_28
                       ,anc_id_29
                       ,anc_id_30
                       ,anc_id_31
                       ,anc_id_32
                       ,anc_id_33
                       ,anc_id_34
                       ,anc_id_35
                       ,anc_id_36
                       ,anc_id_37
                       ,anc_id_38
                       ,anc_id_39
                       ,anc_id_40
                       ,anc_id_41
                       ,anc_id_42
                       ,anc_id_43
                       ,anc_id_44
                       ,anc_id_45
                       ,anc_id_46
                       ,anc_id_47
                       ,anc_id_48
                       ,anc_id_49
                       ,anc_id_50
                       ,anc_id_51
                       ,anc_id_52
                       ,anc_id_53
                       ,anc_id_54
                       ,anc_id_55
                       ,anc_id_56
                       ,anc_id_57
                       ,anc_id_58
                       ,anc_id_59
                       ,anc_id_60
                       ,anc_id_61
                       ,anc_id_62
                       ,anc_id_63
                       ,anc_id_64
                       ,anc_id_65
                       ,anc_id_66
                       ,anc_id_67
                       ,anc_id_68
                       ,anc_id_69
                       ,anc_id_70
                       ,anc_id_71
                       ,anc_id_72
                       ,anc_id_73
                       ,anc_id_74
                       ,anc_id_75
                       ,anc_id_76
                       ,anc_id_77
                       ,anc_id_78
                       ,anc_id_79
                       ,anc_id_80
                       ,anc_id_81
                       ,anc_id_82
                       ,anc_id_83
                       ,anc_id_84
                       ,anc_id_85
                       ,anc_id_86
                       ,anc_id_87
                       ,anc_id_88
                       ,anc_id_89
                       ,anc_id_90
                       ,anc_id_91
                       ,anc_id_92
                       ,anc_id_93
                       ,anc_id_94
                       ,anc_id_95
                       ,anc_id_96
                       ,anc_id_97
                       ,anc_id_98
                       ,anc_id_99
                       ,anc_id_100
                       ,line_definition_owner_code
                       ,line_definition_code
                       ,business_class_code
                       ,mpa_accrual_entry_flag
                       ,encumbrance_type_id
                       ,merge_index
		       ,calculate_g_l_amts_flag
		       ,entered_currency_mau)

                        ae_line_num
BULK COLLECT INTO l_array_rowid, l_array_ae_line_num
FROM xla_ae_lines_gt
WHERE temp_line_num <> 0;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 3'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

forall i in 1..l_array_rowid.count
update xla_ae_lines_gt
set ae_line_num = l_array_ae_line_num(i)
where rowid = l_array_rowid(i);


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of UpdateLineNumber50'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
  xla_exceptions_pkg.raise_message
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.UpdateLineNumber50');
END UpdateLineNumber50;

PROCEDURE UpdateLineNumber100 IS

   l_array_rowid        t_array_rowid;
   l_array_ae_line_num  t_array_Num;

   l_log_module         VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateLineNumber100';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of UpdateLineNumber100'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

SELECT ROWID
      ,DENSE_RANK() OVER
          (PARTITION BY ae_header_id
               ORDER BY ae_header_id
                       ,gl_transfer_mode_code
                       ,accounting_class_code
                       ,event_type_code
                       ,rounding_class_code
                       ,document_rounding_level
                       ,currency_code
                       ,currency_conversion_type
                       ,currency_conversion_date
                       ,currency_conversion_rate
                       ,party_id
                       ,party_site_id
                       ,party_type_code
                       ,code_combination_id
                       ,code_combination_status_code
                       ,segment1
                       ,segment2
                       ,segment3
                       ,segment4
                       ,segment5
                       ,segment6
                       ,segment7
                       ,segment8
                       ,segment9
                       ,segment10
                       ,segment11
                       ,segment12
                       ,segment13
                       ,segment14
                       ,segment15
                       ,segment16
                       ,segment17
                       ,segment18
                       ,segment19
                       ,segment20
                       ,segment21
                       ,segment22
                       ,segment23
                       ,segment24
                       ,segment25
                       ,segment26
                       ,segment27
                       ,segment28
                       ,segment29
                       ,segment30
                       ,alt_code_combination_id
                       ,alt_ccid_status_code
                       ,alt_segment1
                       ,alt_segment2
                       ,alt_segment3
                       ,alt_segment4
                       ,alt_segment5
                       ,alt_segment6
                       ,alt_segment7
                       ,alt_segment8
                       ,alt_segment9
                       ,alt_segment10
                       ,alt_segment11
                       ,alt_segment12
                       ,alt_segment13
                       ,alt_segment14
                       ,alt_segment15
                       ,alt_segment16
                       ,alt_segment17
                       ,alt_segment18
                       ,alt_segment19
                       ,alt_segment20
                       ,alt_segment21
                       ,alt_segment22
                       ,alt_segment23
                       ,alt_segment24
                       ,alt_segment25
                       ,alt_segment26
                       ,alt_segment27
                       ,alt_segment28
                       ,alt_segment29
                       ,alt_segment30
                       ,description
                       ,jgzz_recon_ref
                       ,ussgl_transaction_code
                       ,merge_duplicate_code
                       ,analytical_balance_flag
                       ,anc_id_1
                       ,anc_id_2
                       ,anc_id_3
                       ,anc_id_4
                       ,anc_id_5
                       ,anc_id_6
                       ,anc_id_7
                       ,anc_id_8
                       ,anc_id_9
                       ,anc_id_10
                       ,anc_id_11
                       ,anc_id_12
                       ,anc_id_13
                       ,anc_id_14
                       ,anc_id_15
                       ,anc_id_16
                       ,anc_id_17
                       ,anc_id_18
                       ,anc_id_19
                       ,anc_id_20
                       ,anc_id_21
                       ,anc_id_22
                       ,anc_id_23
                       ,anc_id_24
                       ,anc_id_25
                       ,anc_id_26
                       ,anc_id_27
                       ,anc_id_28
                       ,anc_id_29
                       ,anc_id_30
                       ,anc_id_31
                       ,anc_id_32
                       ,anc_id_33
                       ,anc_id_34
                       ,anc_id_35
                       ,anc_id_36
                       ,anc_id_37
                       ,anc_id_38
                       ,anc_id_39
                       ,anc_id_40
                       ,anc_id_41
                       ,anc_id_42
                       ,anc_id_43
                       ,anc_id_44
                       ,anc_id_45
                       ,anc_id_46
                       ,anc_id_47
                       ,anc_id_48
                       ,anc_id_49
                       ,anc_id_50
                       ,anc_id_51
                       ,anc_id_52
                       ,anc_id_53
                       ,anc_id_54
                       ,anc_id_55
                       ,anc_id_56
                       ,anc_id_57
                       ,anc_id_58
                       ,anc_id_59
                       ,anc_id_60
                       ,anc_id_61
                       ,anc_id_62
                       ,anc_id_63
                       ,anc_id_64
                       ,anc_id_65
                       ,anc_id_66
                       ,anc_id_67
                       ,anc_id_68
                       ,anc_id_69
                       ,anc_id_70
                       ,anc_id_71
                       ,anc_id_72
                       ,anc_id_73
                       ,anc_id_74
                       ,anc_id_75
                       ,anc_id_76
                       ,anc_id_77
                       ,anc_id_78
                       ,anc_id_79
                       ,anc_id_80
                       ,anc_id_81
                       ,anc_id_82
                       ,anc_id_83
                       ,anc_id_84
                       ,anc_id_85
                       ,anc_id_86
                       ,anc_id_87
                       ,anc_id_88
                       ,anc_id_89
                       ,anc_id_90
                       ,anc_id_91
                       ,anc_id_92
                       ,anc_id_93
                       ,anc_id_94
                       ,anc_id_95
                       ,anc_id_96
                       ,anc_id_97
                       ,anc_id_98
                       ,anc_id_99
                       ,anc_id_100
                       ,line_definition_owner_code
                       ,line_definition_code
                       ,business_class_code
                       ,mpa_accrual_entry_flag
                       ,encumbrance_type_id
                       ,merge_index
		       ,calculate_g_l_amts_flag
		       ,entered_currency_mau)

                        ae_line_num
BULK COLLECT INTO l_array_rowid, l_array_ae_line_num
FROM xla_ae_lines_gt
WHERE temp_line_num <> 0;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Update xla_ae_lines_gt 3'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

forall i in 1..l_array_rowid.count
update xla_ae_lines_gt
set ae_line_num = l_array_ae_line_num(i)
where rowid = l_array_rowid(i);


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of UpdateLineNumber100'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
  xla_exceptions_pkg.raise_message
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.UpdateLineNumber100');
END UpdateLineNumber100;
--
--
/*======================================================================+
|                                                                       |
| Insert final Lines                                                    |
|                                                                       |
|                                                                       |
+======================================================================*/
--

FUNCTION InsertLines(p_application_id         IN INTEGER
                    ,p_budgetary_control_mode IN VARCHAR2)
RETURN NUMBER
IS
l_log_module         VARCHAR2(240);
l_count number;
l_ledger_attrs       xla_accounting_cache_pkg.t_array_ledger_attrs;
l_accounting_mode    VARCHAR2(1);

BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertLines';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
l_accounting_mode := xla_accounting_pkg.g_accounting_mode;
IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'Accounting_mode = '||l_accounting_mode
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

--
BEGIN

   IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'SQL - Insert into xla_ae_lines'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;
--
xla_accounting_cache_pkg.GetLedgerArray(l_ledger_attrs);


   IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'Before insert...'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;


FORALL i in 1..l_ledger_attrs.array_ledger_id.count
  INSERT INTO xla_ae_lines
  (
     ae_header_id
   , ae_line_num
   , displayed_line_number
   , code_combination_id
   , gl_transfer_mode_code
   , creation_date
   , accounted_cr
   , accounted_dr
   , unrounded_accounted_cr
   , unrounded_accounted_dr
   , gain_or_loss_flag
   , accounting_class_code
   , currency_code
   , currency_conversion_date
   , currency_conversion_rate
   , currency_conversion_type
   , description
   , entered_cr
   , entered_dr
   , unrounded_entered_cr
   , unrounded_entered_dr
   , last_update_date
   , last_update_login
   , party_id
   , party_site_id
   , party_type_code
   , statistical_amount
   , ussgl_transaction_code
   , created_by
   , last_updated_by
   , jgzz_recon_ref
   , program_update_date
   , program_application_id
   , program_id
   , analytical_balance_flag
   , application_id
   , request_id
   , gl_sl_link_table
   , business_class_code    -- 4336173
   , mpa_accrual_entry_flag -- 4262811
   , encumbrance_type_id    -- 4458381 Public Sector Enh
   , ledger_id              --4955764
   , accounting_date        --4955764
   , gl_sl_link_id          --5041325
   , control_balance_flag   --4930177
  )
  (SELECT
      ae_header_id
     ,ae_line_num
     ,decode(nvl(accounted_cr, 0) + nvl(accounted_dr, 0), 0, -1, 1) *
         (ROW_NUMBER() over (PARTITION BY ae_header_id order by
                      DECODE(SIGN(abs(nvl(accounted_dr, 0)) - abs(nvl(accounted_cr, 0))), 1, 3, -1, 2, 0) desc,
                      abs(nvl(accounted_dr, 0) + nvl(accounted_cr, 0)) desc,
                      SIGN(nvl(accounted_dr, 0) + nvl(accounted_cr, 0)) desc))
     ,code_combination_id
     ,gl_transfer_mode_code
     ,creation_date
     ,accounted_cr
     ,accounted_dr
     ,unrounded_accounted_cr
     ,unrounded_accounted_dr
     ,gain_or_loss_flag
     ,decode(accounting_class_code, 'DUMMY_EXCHANGE_GAIN_LOSS_DUMMY', 'EXCHANGE_GAIN_LOSS', accounting_class_code)
     ,currency_code
     ,currency_conversion_date
     ,currency_conversion_rate
     ,currency_conversion_type
     ,description
     ,entered_cr
     ,entered_dr
     ,unrounded_entered_cr
     ,unrounded_entered_dr
     ,last_update_date
     ,last_update_login
     ,party_id
     ,party_site_id
     ,party_type_code
     ,statistical_amount
     ,ussgl_transaction_code
     ,created_by
     ,last_updated_by
     ,jgzz_recon_ref
     ,program_update_date
     ,program_application_id
     ,program_id
     ,analytical_balance_flag
     ,application_id
     ,request_id
     ,gl_sl_link_table
     ,business_class_code
     ,mpa_accrual_entry_flag
     ,encumbrance_type_id
     ,ledger_id
     ,accounting_date
     ,Decode(l_accounting_mode,'F',xla_gl_sl_link_id_s.nextval,NULL)
     ,Decode(control_balance_flag,'Y','P'
	                         ,'CUSTOMER','P'
			         ,'SUPPLIER','P'
                                 ,NULL)
   FROM
  (SELECT /*+ Leading (LIN) Cardinality(LIN 1) use_nl(GCC) */
     lin.ae_header_id  ae_header_id
   , ae_line_num
   , CASE gain_or_loss_flag
     WHEN 'Y' THEN
       CASE calculate_g_l_amts_flag
       WHEN 'Y' THEN
           decode(SIGN(SUM(nvl(unrounded_accounted_cr, 0)-
             nvl(unrounded_accounted_dr, 0))),
             1,
               decode(code_combination_status_code
                  ,C_CCID_CREATED,lin.code_combination_id
                  , -1 ),
               decode(alt_ccid_status_code
                  ,C_CCID_CREATED,alt_code_combination_id
                  , -1 ))
       ELSE
           DECODE(code_combination_status_code
                ,C_CCID_CREATED,lin.code_combination_id
                , -1 )
       END
     ELSE
       DECODE(code_combination_status_code
            ,C_CCID_CREATED,lin.code_combination_id
            , -1 )
     END       code_combination_id
   , gl_transfer_mode_code
   , g_who_columns.creation_date  creation_date
-- accounted_cr
   , decode(nvl(sum(unrounded_accounted_cr), sum(unrounded_accounted_dr)), null, null,
       CASE switch_side_flag
       WHEN 'Y' THEN
         CASE SIGN(
                  NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)+
                  NVL(SUM(doc_rounding_acctd_amt), 0)
                )
         WHEN -1 THEN null
         WHEN 1 THEN
              ROUND(
                (NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)+
                NVL(SUM(doc_rounding_acctd_amt), 0))
                /l_ledger_attrs.array_mau(i)
                +l_ledger_attrs.array_rounding_offset(i))
              *l_ledger_attrs.array_mau(i)
         ELSE
           CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)+
                  NVL(SUM(doc_rounding_entered_amt), 0))
           WHEN -1 THEN null
           WHEN 1 THEN 0
           ELSE DECODE(sum(unrounded_accounted_cr), 0, 0, null)
           END
         END
       ELSE DECODE(SUM(unrounded_accounted_cr), null, to_number(null) ,
              ROUND(
                (SUM(unrounded_accounted_cr) +
                NVL(SUM(doc_rounding_acctd_amt), 0))
                /l_ledger_attrs.array_mau(i)
                +l_ledger_attrs.array_rounding_offset(i))
              *l_ledger_attrs.array_mau(i))
       END) accounted_cr
   -- accounted_dr
   , decode(nvl(sum(unrounded_accounted_cr), sum(unrounded_accounted_dr)), null, null,
     CASE switch_side_flag
     WHEN 'Y' THEN
       CASE SIGN(
                  NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)-
                  NVL(SUM(doc_rounding_acctd_amt), 0)
                )
       WHEN -1 THEN null
       WHEN 1 THEN
            ROUND(
                (NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)-
                NVL(SUM(doc_rounding_acctd_amt), 0))
                /l_ledger_attrs.array_mau(i)
                +l_ledger_attrs.array_rounding_offset(i))
              *l_ledger_attrs.array_mau(i)
       ELSE
         CASE SIGN(NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)-
                   NVL(SUM(doc_rounding_entered_amt), 0))
         WHEN -1 THEN null
         WHEN 1 THEN 0
         ELSE DECODE(sum(unrounded_accounted_cr), 0, to_number(null), 0)
         END
       END
     ELSE
       decode(SUM(unrounded_accounted_cr), null,
            ROUND(
              (SUM(unrounded_accounted_dr)-NVL(SUM(doc_rounding_acctd_amt), 0))
              /l_ledger_attrs.array_mau(i)
              +l_ledger_attrs.array_rounding_offset(i))
              *l_ledger_attrs.array_mau(i)
           ,ROUND(
              SUM(unrounded_accounted_dr) /l_ledger_attrs.array_mau(i)
              +l_ledger_attrs.array_rounding_offset(i))
              *l_ledger_attrs.array_mau(i)
       )
     END) accounted_dr
   -- unrounded_accounted_cr
   , decode(nvl(sum(unrounded_accounted_cr), sum(unrounded_accounted_dr)), null, null,
       CASE switch_side_flag
       WHEN 'Y' THEN
         CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
         WHEN -1 THEN null
         WHEN 1 THEN
           NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)
         ELSE
           CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
           WHEN -1 THEN null
           WHEN 1 THEN 0
           ELSE DECODE(sum(unrounded_accounted_cr), 0, 0, null)
           END
         END
       ELSE SUM(unrounded_accounted_cr)
       END) unrounded_accounted_cr
   -- unrounded_accounted_dr
   , decode(nvl(sum(unrounded_accounted_cr), sum(unrounded_accounted_dr)), null, null,
       CASE switch_side_flag
       WHEN 'Y' THEN
         CASE SIGN(NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0))
         WHEN 1 THEN
           NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)
         WHEN -1 THEN null
         ELSE
           CASE SIGN(NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0))
           WHEN -1 THEN null
           WHEN 1 THEN 0
           ELSE DECODE(sum(unrounded_accounted_cr), 0, to_number(null), 0)
           END
         END
       ELSE SUM(unrounded_accounted_dr)
       END) unrounded_accounted_dr
   , gain_or_loss_flag
   , accounting_class_code
   , currency_code
   --, currency_conversion_date   new condition added below for bug7253542
   , DECODE(l_ledger_attrs.array_ledger_type(i),
            'PRIMARY',
            (DECODE(currency_code,
		    l_ledger_attrs.array_ledger_currency_code(i),
                    NULL,
		    currency_conversion_date)),
             currency_conversion_date) currency_conversion_date
   , currency_conversion_rate
   , currency_conversion_type
   , lin.description   description
   -- entered_cr
   , decode(nvl(sum(unrounded_entered_cr), sum(unrounded_entered_dr)), null, null,
       CASE switch_side_flag
       WHEN 'Y' THEN
         CASE SIGN(
                  NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)+
                  NVL(SUM(doc_rounding_entered_amt), 0)
                )
         WHEN -1 THEN null
         WHEN 1 THEN
              ROUND(
                (NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)+
                NVL(SUM(doc_rounding_entered_amt), 0))
                /entered_currency_mau
                +l_ledger_attrs.array_rounding_offset(i))
              *entered_currency_mau
         ELSE
               CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0)
                         +NVL(SUM(doc_rounding_acctd_amt), 0))
               WHEN -1 THEN null
               WHEN 1 THEN 0
               ELSE DECODE(sum(unrounded_accounted_cr), 0, 0, null)
               END
         END
       ELSE DECODE(SUM(unrounded_entered_cr), null, to_number(null) ,
              ROUND(
                (SUM(unrounded_entered_cr) +
                NVL(SUM(doc_rounding_entered_amt), 0))
                /entered_currency_mau
                +l_ledger_attrs.array_rounding_offset(i))
              *entered_currency_mau)
       END) entered_cr
   -- entered_dr
   , decode(nvl(sum(unrounded_entered_cr), sum(unrounded_entered_dr)), null, null,
       CASE switch_side_flag
       WHEN 'Y' THEN
         CASE SIGN(
                  NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)-
                  NVL(SUM(doc_rounding_entered_amt), 0)
                )
         WHEN -1 THEN null
         WHEN 1 THEN
            ROUND(
                (NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)-
                NVL(SUM(doc_rounding_entered_amt), 0))
                /entered_currency_mau
                +l_ledger_attrs.array_rounding_offset(i))
              *entered_currency_mau
         ELSE
           CASE SIGN(NVL(SUM(unrounded_accounted_dr),0) - NVL(SUM(unrounded_accounted_cr),0)
                     -NVL(SUM(doc_rounding_acctd_amt), 0))
           WHEN -1 THEN null
           WHEN 1 THEN 0
           ELSE DECODE(sum(unrounded_accounted_cr), 0, to_number(null), 0)
           END
         END
       ELSE
           decode(SUM(unrounded_entered_cr), null,
            ROUND(
              (SUM(unrounded_entered_dr)-NVL(SUM(doc_rounding_entered_amt), 0))
              /entered_currency_mau
              +l_ledger_attrs.array_rounding_offset(i))
              *entered_currency_mau
           ,ROUND(
              SUM(unrounded_entered_dr) /entered_currency_mau
              +l_ledger_attrs.array_rounding_offset(i))
              *entered_currency_mau
           )
       END) entered_dr
   -- unrounded_entered_cr
   , decode(nvl(sum(unrounded_entered_cr), sum(unrounded_entered_dr)), null, null,
       CASE switch_side_flag
       WHEN 'Y' THEN
         CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
         WHEN -1 THEN null
         WHEN 1 THEN NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0)
         ELSE
           CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
           WHEN -1 THEN null
           WHEN 1 THEN 0
           ELSE DECODE(sum(unrounded_accounted_cr), 0, 0, null)
           END
         END
       ELSE SUM(unrounded_entered_cr)
       END) unrounded_entered_cr
   -- unrounded_entered_dr
   , decode(nvl(sum(unrounded_entered_cr), sum(unrounded_entered_dr)), null, null,
       CASE switch_side_flag
       WHEN 'Y' THEN
         CASE SIGN(NVL(SUM(unrounded_entered_cr),0) - NVL(SUM(unrounded_entered_dr),0))
         WHEN 1 THEN null
         WHEN -1 THEN NVL(SUM(unrounded_entered_dr),0) - NVL(SUM(unrounded_entered_cr),0)
         ELSE
           CASE SIGN(NVL(SUM(unrounded_accounted_cr),0) - NVL(SUM(unrounded_accounted_dr),0))
           WHEN 1 THEN null
           WHEN -1 THEN 0
           ELSE DECODE(sum(unrounded_accounted_cr), 0, to_number(null), 0)
           END
         END
       ELSE SUM(unrounded_entered_dr)
       END) unrounded_entered_dr
   , g_who_columns.last_update_date      last_update_date
   , g_who_columns.last_update_login     last_update_login
   , party_id
   , party_site_id
   , party_type_code
   , sum(statistical_amount)            statistical_amount
   , ussgl_transaction_code
   , g_who_columns.created_by           created_by
   , g_who_columns.last_updated_by      last_updated_by
   , jgzz_recon_ref
   , g_who_columns.program_update_date  program_update_date
   , g_who_columns.program_application_id  program_application_id
   , g_who_columns.program_id           program_id
   , analytical_balance_flag            analytical_balance_flag
   , p_application_id                   application_id
   , g_who_columns.request_id           request_id
   , 'XLAJEL'                           gl_sl_link_table
   , business_class_code    -- 4336173
   , mpa_accrual_entry_flag -- 4262811
   , encumbrance_type_id    -- 4458381 Public Sector Enh
   , ledger_id              -- 4955764
   , accounting_date        -- 4955764
   , gcc.reference3                     control_balance_flag   --4930177
  FROM xla_ae_lines_gt     lin
      ,gl_code_combinations gcc
  WHERE ledger_id = l_ledger_attrs.array_ledger_id(i)
    AND ae_line_num is not NULL
    AND lin.code_combination_id = gcc.code_combination_id(+)     --5261785
 GROUP BY lin.ae_header_id
        , ae_line_num
        , header_num                    -- 4262811c  MPA reversal lines
        , gl_transfer_mode_code
        , g_who_columns.creation_date
        , g_who_columns.last_update_date
        , g_who_columns.last_update_login
        , g_who_columns.created_by
        , g_who_columns.last_updated_by
        , g_who_columns.program_update_date
        , g_who_columns.program_application_id
        , g_who_columns.program_id
        , g_who_columns.request_id
        , 'XLAJEL'
        , p_application_id
        , accounting_class_code
        , event_class_code
        , event_type_code
        , line_definition_owner_code
        , line_definition_code
        , entered_currency_mau
        , currency_code
        , currency_conversion_type
        , currency_conversion_date
        , currency_conversion_rate
        , party_id
        , party_site_id
        , party_type_code
        , lin.code_combination_id
        , C_CCID_CREATED
        , code_combination_status_code
        , lin.description
        , jgzz_recon_ref
        , ussgl_transaction_code
        , merge_duplicate_code
        , analytical_balance_flag
        , switch_side_flag
        , gain_or_loss_flag
        , calculate_g_l_amts_flag
        , alt_ccid_status_code
        , alt_code_combination_id
        , lin.business_class_code    -- 4336173
        , lin.mpa_accrual_entry_flag -- 4262811
        , encumbrance_type_id -- 4458381 Public Sector Enh
        , merge_index
        , ledger_id
        , accounting_date
        , gcc.reference3
        )
  WHERE accounting_class_code <>'DUMMY_EXCHANGE_GAIN_LOSS_DUMMY' or nvl(accounted_cr, 0) <> nvl(accounted_dr, 0)
);
--

EXCEPTION
WHEN OTHERS  THEN

  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => sqlerrm
                                    );
END;

--
l_count := SQL%ROWCOUNT;
IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# journal entry lines inserted into xla_ae_lines = '||to_char(l_count)
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_count)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);


      trace
         (p_msg      => 'END of InsertLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

RETURN l_count;

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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertLines');
END InsertLines;
--
--
/*======================================================================+
| PRIVATE Procedure                                                     |
|                                                                       |
| InsertAnalyticalCriteria                                              |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertAnalyticalCriteria
IS
l_rowcount           NUMBER;
l_log_module         VARCHAR2(240);
l_reversal_flag      VARCHAR2(1);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertAnalyticalCriteria';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertAnalyticalCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_rowcount  := 0;

BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_line_acs'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

      trace
         (p_msg      => '# of line ACs: ' || g_line_ac_count
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;
   BEGIN
	SELECT 'Y' into l_reversal_flag
	FROM dual
	WHERE exists
	(SELECT 1 FROM xla_ae_lines_gt WHERE reversal_code='REVERSAL');

	IF l_reversal_flag='Y' THEN
	    Insert_ANC_Inv_Canc;
	END IF;

        EXCEPTION
	WHEN NO_DATA_FOUND THEN
	null;
   END;


   IF g_line_ac_count <= 10 THEN

      InsertAnalyticalCriteria10;

   ELSIF g_line_ac_count <= 50 THEN

      InsertAnalyticalCriteria50;

   ELSIF g_line_ac_count <= 100 THEN

      InsertAnalyticalCriteria100;

   END IF;

   --
   l_rowcount := SQL%ROWCOUNT;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# line analytical criteria inserted into xla_ae_line_acs = '||l_rowcount
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   EXCEPTION
   WHEN OTHERS  THEN

     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
              (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
              ,p_level    => C_LEVEL_EXCEPTION
              ,p_module   => l_log_module);
     END IF;

     xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                      ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                      ,p_token_1      => 'ERROR'
                                      ,p_value_1      => sqlerrm
                                      );


   END;

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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertAnalyticalCriteria');
END InsertAnalyticalCriteria;

--
--
/*======================================================================+
| PRIVATE Procedure                                                     |
|                                                                       |
| InsertAnalyticalCriteria10                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertAnalyticalCriteria10
IS
l_rowcount           NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertAnalyticalCriteria10';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertAnalyticalCriteria10'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_rowcount  := 0;

BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_line_acs'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

INSERT ALL
WHEN anc_id_1 IS NOT NULL and anc_id_1 not like 'DUMMY_ANC_%' THEN    -- Bug 8691573
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_1
       ,1
       ,INSTRB(anc_id_1,'(]',1,1) -1)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,1) + 2
       ,INSTRB(anc_id_1,'(]',1,2) -
        INSTRB(anc_id_1,'(]',1,1) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,2) + 2
       ,INSTRB(anc_id_1,'(]',1,3) -
        INSTRB(anc_id_1,'(]',1,2) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,3) + 2
       ,INSTRB(anc_id_1,'(]',1,4) -
        INSTRB(anc_id_1,'(]',1,3) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,4) + 2
       ,INSTRB(anc_id_1,'(]',1,5) -
        INSTRB(anc_id_1,'(]',1,4) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,5) + 2
       ,INSTRB(anc_id_1,'(]',1,6) -
        INSTRB(anc_id_1,'(]',1,5) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,6) + 2
       ,INSTRB(anc_id_1,'(]',1,7) -
        INSTRB(anc_id_1,'(]',1,6) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,7) + 2
       ,LENGTHB(anc_id_1))
)

WHEN anc_id_2 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_2
       ,1
       ,INSTRB(anc_id_2,'(]',1,1) -1)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,1) + 2
       ,INSTRB(anc_id_2,'(]',1,2) -
        INSTRB(anc_id_2,'(]',1,1) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,2) + 2
       ,INSTRB(anc_id_2,'(]',1,3) -
        INSTRB(anc_id_2,'(]',1,2) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,3) + 2
       ,INSTRB(anc_id_2,'(]',1,4) -
        INSTRB(anc_id_2,'(]',1,3) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,4) + 2
       ,INSTRB(anc_id_2,'(]',1,5) -
        INSTRB(anc_id_2,'(]',1,4) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,5) + 2
       ,INSTRB(anc_id_2,'(]',1,6) -
        INSTRB(anc_id_2,'(]',1,5) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,6) + 2
       ,INSTRB(anc_id_2,'(]',1,7) -
        INSTRB(anc_id_2,'(]',1,6) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,7) + 2
       ,LENGTHB(anc_id_2))
)

WHEN anc_id_3 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_3
       ,1
       ,INSTRB(anc_id_3,'(]',1,1) -1)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,1) + 2
       ,INSTRB(anc_id_3,'(]',1,2) -
        INSTRB(anc_id_3,'(]',1,1) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,2) + 2
       ,INSTRB(anc_id_3,'(]',1,3) -
        INSTRB(anc_id_3,'(]',1,2) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,3) + 2
       ,INSTRB(anc_id_3,'(]',1,4) -
        INSTRB(anc_id_3,'(]',1,3) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,4) + 2
       ,INSTRB(anc_id_3,'(]',1,5) -
        INSTRB(anc_id_3,'(]',1,4) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,5) + 2
       ,INSTRB(anc_id_3,'(]',1,6) -
        INSTRB(anc_id_3,'(]',1,5) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,6) + 2
       ,INSTRB(anc_id_3,'(]',1,7) -
        INSTRB(anc_id_3,'(]',1,6) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,7) + 2
       ,LENGTHB(anc_id_3))
)

WHEN anc_id_4 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_4
       ,1
       ,INSTRB(anc_id_4,'(]',1,1) -1)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,1) + 2
       ,INSTRB(anc_id_4,'(]',1,2) -
        INSTRB(anc_id_4,'(]',1,1) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,2) + 2
       ,INSTRB(anc_id_4,'(]',1,3) -
        INSTRB(anc_id_4,'(]',1,2) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,3) + 2
       ,INSTRB(anc_id_4,'(]',1,4) -
        INSTRB(anc_id_4,'(]',1,3) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,4) + 2
       ,INSTRB(anc_id_4,'(]',1,5) -
        INSTRB(anc_id_4,'(]',1,4) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,5) + 2
       ,INSTRB(anc_id_4,'(]',1,6) -
        INSTRB(anc_id_4,'(]',1,5) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,6) + 2
       ,INSTRB(anc_id_4,'(]',1,7) -
        INSTRB(anc_id_4,'(]',1,6) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,7) + 2
       ,LENGTHB(anc_id_4))
)

WHEN anc_id_5 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_5
       ,1
       ,INSTRB(anc_id_5,'(]',1,1) -1)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,1) + 2
       ,INSTRB(anc_id_5,'(]',1,2) -
        INSTRB(anc_id_5,'(]',1,1) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,2) + 2
       ,INSTRB(anc_id_5,'(]',1,3) -
        INSTRB(anc_id_5,'(]',1,2) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,3) + 2
       ,INSTRB(anc_id_5,'(]',1,4) -
        INSTRB(anc_id_5,'(]',1,3) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,4) + 2
       ,INSTRB(anc_id_5,'(]',1,5) -
        INSTRB(anc_id_5,'(]',1,4) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,5) + 2
       ,INSTRB(anc_id_5,'(]',1,6) -
        INSTRB(anc_id_5,'(]',1,5) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,6) + 2
       ,INSTRB(anc_id_5,'(]',1,7) -
        INSTRB(anc_id_5,'(]',1,6) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,7) + 2
       ,LENGTHB(anc_id_5))
)

WHEN anc_id_6 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_6
       ,1
       ,INSTRB(anc_id_6,'(]',1,1) -1)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,1) + 2
       ,INSTRB(anc_id_6,'(]',1,2) -
        INSTRB(anc_id_6,'(]',1,1) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,2) + 2
       ,INSTRB(anc_id_6,'(]',1,3) -
        INSTRB(anc_id_6,'(]',1,2) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,3) + 2
       ,INSTRB(anc_id_6,'(]',1,4) -
        INSTRB(anc_id_6,'(]',1,3) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,4) + 2
       ,INSTRB(anc_id_6,'(]',1,5) -
        INSTRB(anc_id_6,'(]',1,4) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,5) + 2
       ,INSTRB(anc_id_6,'(]',1,6) -
        INSTRB(anc_id_6,'(]',1,5) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,6) + 2
       ,INSTRB(anc_id_6,'(]',1,7) -
        INSTRB(anc_id_6,'(]',1,6) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,7) + 2
       ,LENGTHB(anc_id_6))
)

WHEN anc_id_7 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_7
       ,1
       ,INSTRB(anc_id_7,'(]',1,1) -1)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,1) + 2
       ,INSTRB(anc_id_7,'(]',1,2) -
        INSTRB(anc_id_7,'(]',1,1) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,2) + 2
       ,INSTRB(anc_id_7,'(]',1,3) -
        INSTRB(anc_id_7,'(]',1,2) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,3) + 2
       ,INSTRB(anc_id_7,'(]',1,4) -
        INSTRB(anc_id_7,'(]',1,3) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,4) + 2
       ,INSTRB(anc_id_7,'(]',1,5) -
        INSTRB(anc_id_7,'(]',1,4) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,5) + 2
       ,INSTRB(anc_id_7,'(]',1,6) -
        INSTRB(anc_id_7,'(]',1,5) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,6) + 2
       ,INSTRB(anc_id_7,'(]',1,7) -
        INSTRB(anc_id_7,'(]',1,6) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,7) + 2
       ,LENGTHB(anc_id_7))
)

WHEN anc_id_8 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_8
       ,1
       ,INSTRB(anc_id_8,'(]',1,1) -1)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,1) + 2
       ,INSTRB(anc_id_8,'(]',1,2) -
        INSTRB(anc_id_8,'(]',1,1) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,2) + 2
       ,INSTRB(anc_id_8,'(]',1,3) -
        INSTRB(anc_id_8,'(]',1,2) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,3) + 2
       ,INSTRB(anc_id_8,'(]',1,4) -
        INSTRB(anc_id_8,'(]',1,3) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,4) + 2
       ,INSTRB(anc_id_8,'(]',1,5) -
        INSTRB(anc_id_8,'(]',1,4) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,5) + 2
       ,INSTRB(anc_id_8,'(]',1,6) -
        INSTRB(anc_id_8,'(]',1,5) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,6) + 2
       ,INSTRB(anc_id_8,'(]',1,7) -
        INSTRB(anc_id_8,'(]',1,6) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,7) + 2
       ,LENGTHB(anc_id_8))
)

WHEN anc_id_9 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_9
       ,1
       ,INSTRB(anc_id_9,'(]',1,1) -1)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,1) + 2
       ,INSTRB(anc_id_9,'(]',1,2) -
        INSTRB(anc_id_9,'(]',1,1) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,2) + 2
       ,INSTRB(anc_id_9,'(]',1,3) -
        INSTRB(anc_id_9,'(]',1,2) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,3) + 2
       ,INSTRB(anc_id_9,'(]',1,4) -
        INSTRB(anc_id_9,'(]',1,3) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,4) + 2
       ,INSTRB(anc_id_9,'(]',1,5) -
        INSTRB(anc_id_9,'(]',1,4) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,5) + 2
       ,INSTRB(anc_id_9,'(]',1,6) -
        INSTRB(anc_id_9,'(]',1,5) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,6) + 2
       ,INSTRB(anc_id_9,'(]',1,7) -
        INSTRB(anc_id_9,'(]',1,6) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,7) + 2
       ,LENGTHB(anc_id_9))
)

WHEN anc_id_10 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_10
       ,1
       ,INSTRB(anc_id_10,'(]',1,1) -1)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,1) + 2
       ,INSTRB(anc_id_10,'(]',1,2) -
        INSTRB(anc_id_10,'(]',1,1) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,2) + 2
       ,INSTRB(anc_id_10,'(]',1,3) -
        INSTRB(anc_id_10,'(]',1,2) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,3) + 2
       ,INSTRB(anc_id_10,'(]',1,4) -
        INSTRB(anc_id_10,'(]',1,3) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,4) + 2
       ,INSTRB(anc_id_10,'(]',1,5) -
        INSTRB(anc_id_10,'(]',1,4) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,5) + 2
       ,INSTRB(anc_id_10,'(]',1,6) -
        INSTRB(anc_id_10,'(]',1,5) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,6) + 2
       ,INSTRB(anc_id_10,'(]',1,7) -
        INSTRB(anc_id_10,'(]',1,6) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,7) + 2
       ,LENGTHB(anc_id_10))
)
SELECT  ae_header_id
      , ae_line_num
      , anc_id_1
      , anc_id_2
      , anc_id_3
      , anc_id_4
      , anc_id_5
      , anc_id_6
      , anc_id_7
      , anc_id_8
      , anc_id_9
      , anc_id_10
 FROM  xla_ae_lines_gt
WHERE  ae_line_num is not null
GROUP  BY
       ae_line_num
      ,ae_header_id
      ,anc_id_1
      ,anc_id_2
      ,anc_id_3
      ,anc_id_4
      ,anc_id_5
      ,anc_id_6
      ,anc_id_7
      ,anc_id_8
      ,anc_id_9
      ,anc_id_10
      ;

   --
   l_rowcount := SQL%ROWCOUNT;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# line analytical criteria inserted into xla_ae_line_acs = '||l_rowcount
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   EXCEPTION
   WHEN OTHERS  THEN

     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
              (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
              ,p_level    => C_LEVEL_EXCEPTION
              ,p_module   => l_log_module);
     END IF;

     xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                      ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                      ,p_token_1      => 'ERROR'
                                      ,p_value_1      => sqlerrm
                                      );

   END;

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
       (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertAnalyticalCriteria10');
END InsertAnalyticalCriteria10;


--
--
/*======================================================================+
| PRIVATE Procedure                                                     |
|                                                                       |
| InsertAnalyticalCriteria50                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertAnalyticalCriteria50
IS
l_rowcount           NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertAnalyticalCriteria50';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertAnalyticalCriteria50'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_rowcount  := 0;

BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_line_acs'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

INSERT ALL
WHEN anc_id_1 IS NOT NULL and anc_id_1 not like 'DUMMY_ANC_%' THEN --Bug 8691573
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_1
       ,1
       ,INSTRB(anc_id_1,'(]',1,1) -1)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,1) + 2
       ,INSTRB(anc_id_1,'(]',1,2) -
        INSTRB(anc_id_1,'(]',1,1) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,2) + 2
       ,INSTRB(anc_id_1,'(]',1,3) -
        INSTRB(anc_id_1,'(]',1,2) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,3) + 2
       ,INSTRB(anc_id_1,'(]',1,4) -
        INSTRB(anc_id_1,'(]',1,3) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,4) + 2
       ,INSTRB(anc_id_1,'(]',1,5) -
        INSTRB(anc_id_1,'(]',1,4) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,5) + 2
       ,INSTRB(anc_id_1,'(]',1,6) -
        INSTRB(anc_id_1,'(]',1,5) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,6) + 2
       ,INSTRB(anc_id_1,'(]',1,7) -
        INSTRB(anc_id_1,'(]',1,6) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,7) + 2
       ,LENGTHB(anc_id_1))
)

WHEN anc_id_2 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_2
       ,1
       ,INSTRB(anc_id_2,'(]',1,1) -1)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,1) + 2
       ,INSTRB(anc_id_2,'(]',1,2) -
        INSTRB(anc_id_2,'(]',1,1) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,2) + 2
       ,INSTRB(anc_id_2,'(]',1,3) -
        INSTRB(anc_id_2,'(]',1,2) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,3) + 2
       ,INSTRB(anc_id_2,'(]',1,4) -
        INSTRB(anc_id_2,'(]',1,3) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,4) + 2
       ,INSTRB(anc_id_2,'(]',1,5) -
        INSTRB(anc_id_2,'(]',1,4) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,5) + 2
       ,INSTRB(anc_id_2,'(]',1,6) -
        INSTRB(anc_id_2,'(]',1,5) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,6) + 2
       ,INSTRB(anc_id_2,'(]',1,7) -
        INSTRB(anc_id_2,'(]',1,6) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,7) + 2
       ,LENGTHB(anc_id_2))
)

WHEN anc_id_3 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_3
       ,1
       ,INSTRB(anc_id_3,'(]',1,1) -1)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,1) + 2
       ,INSTRB(anc_id_3,'(]',1,2) -
        INSTRB(anc_id_3,'(]',1,1) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,2) + 2
       ,INSTRB(anc_id_3,'(]',1,3) -
        INSTRB(anc_id_3,'(]',1,2) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,3) + 2
       ,INSTRB(anc_id_3,'(]',1,4) -
        INSTRB(anc_id_3,'(]',1,3) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,4) + 2
       ,INSTRB(anc_id_3,'(]',1,5) -
        INSTRB(anc_id_3,'(]',1,4) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,5) + 2
       ,INSTRB(anc_id_3,'(]',1,6) -
        INSTRB(anc_id_3,'(]',1,5) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,6) + 2
       ,INSTRB(anc_id_3,'(]',1,7) -
        INSTRB(anc_id_3,'(]',1,6) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,7) + 2
       ,LENGTHB(anc_id_3))
)

WHEN anc_id_4 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_4
       ,1
       ,INSTRB(anc_id_4,'(]',1,1) -1)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,1) + 2
       ,INSTRB(anc_id_4,'(]',1,2) -
        INSTRB(anc_id_4,'(]',1,1) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,2) + 2
       ,INSTRB(anc_id_4,'(]',1,3) -
        INSTRB(anc_id_4,'(]',1,2) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,3) + 2
       ,INSTRB(anc_id_4,'(]',1,4) -
        INSTRB(anc_id_4,'(]',1,3) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,4) + 2
       ,INSTRB(anc_id_4,'(]',1,5) -
        INSTRB(anc_id_4,'(]',1,4) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,5) + 2
       ,INSTRB(anc_id_4,'(]',1,6) -
        INSTRB(anc_id_4,'(]',1,5) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,6) + 2
       ,INSTRB(anc_id_4,'(]',1,7) -
        INSTRB(anc_id_4,'(]',1,6) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,7) + 2
       ,LENGTHB(anc_id_4))
)

WHEN anc_id_5 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_5
       ,1
       ,INSTRB(anc_id_5,'(]',1,1) -1)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,1) + 2
       ,INSTRB(anc_id_5,'(]',1,2) -
        INSTRB(anc_id_5,'(]',1,1) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,2) + 2
       ,INSTRB(anc_id_5,'(]',1,3) -
        INSTRB(anc_id_5,'(]',1,2) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,3) + 2
       ,INSTRB(anc_id_5,'(]',1,4) -
        INSTRB(anc_id_5,'(]',1,3) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,4) + 2
       ,INSTRB(anc_id_5,'(]',1,5) -
        INSTRB(anc_id_5,'(]',1,4) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,5) + 2
       ,INSTRB(anc_id_5,'(]',1,6) -
        INSTRB(anc_id_5,'(]',1,5) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,6) + 2
       ,INSTRB(anc_id_5,'(]',1,7) -
        INSTRB(anc_id_5,'(]',1,6) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,7) + 2
       ,LENGTHB(anc_id_5))
)

WHEN anc_id_6 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_6
       ,1
       ,INSTRB(anc_id_6,'(]',1,1) -1)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,1) + 2
       ,INSTRB(anc_id_6,'(]',1,2) -
        INSTRB(anc_id_6,'(]',1,1) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,2) + 2
       ,INSTRB(anc_id_6,'(]',1,3) -
        INSTRB(anc_id_6,'(]',1,2) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,3) + 2
       ,INSTRB(anc_id_6,'(]',1,4) -
        INSTRB(anc_id_6,'(]',1,3) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,4) + 2
       ,INSTRB(anc_id_6,'(]',1,5) -
        INSTRB(anc_id_6,'(]',1,4) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,5) + 2
       ,INSTRB(anc_id_6,'(]',1,6) -
        INSTRB(anc_id_6,'(]',1,5) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,6) + 2
       ,INSTRB(anc_id_6,'(]',1,7) -
        INSTRB(anc_id_6,'(]',1,6) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,7) + 2
       ,LENGTHB(anc_id_6))
)

WHEN anc_id_7 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_7
       ,1
       ,INSTRB(anc_id_7,'(]',1,1) -1)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,1) + 2
       ,INSTRB(anc_id_7,'(]',1,2) -
        INSTRB(anc_id_7,'(]',1,1) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,2) + 2
       ,INSTRB(anc_id_7,'(]',1,3) -
        INSTRB(anc_id_7,'(]',1,2) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,3) + 2
       ,INSTRB(anc_id_7,'(]',1,4) -
        INSTRB(anc_id_7,'(]',1,3) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,4) + 2
       ,INSTRB(anc_id_7,'(]',1,5) -
        INSTRB(anc_id_7,'(]',1,4) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,5) + 2
       ,INSTRB(anc_id_7,'(]',1,6) -
        INSTRB(anc_id_7,'(]',1,5) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,6) + 2
       ,INSTRB(anc_id_7,'(]',1,7) -
        INSTRB(anc_id_7,'(]',1,6) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,7) + 2
       ,LENGTHB(anc_id_7))
)

WHEN anc_id_8 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_8
       ,1
       ,INSTRB(anc_id_8,'(]',1,1) -1)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,1) + 2
       ,INSTRB(anc_id_8,'(]',1,2) -
        INSTRB(anc_id_8,'(]',1,1) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,2) + 2
       ,INSTRB(anc_id_8,'(]',1,3) -
        INSTRB(anc_id_8,'(]',1,2) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,3) + 2
       ,INSTRB(anc_id_8,'(]',1,4) -
        INSTRB(anc_id_8,'(]',1,3) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,4) + 2
       ,INSTRB(anc_id_8,'(]',1,5) -
        INSTRB(anc_id_8,'(]',1,4) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,5) + 2
       ,INSTRB(anc_id_8,'(]',1,6) -
        INSTRB(anc_id_8,'(]',1,5) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,6) + 2
       ,INSTRB(anc_id_8,'(]',1,7) -
        INSTRB(anc_id_8,'(]',1,6) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,7) + 2
       ,LENGTHB(anc_id_8))
)

WHEN anc_id_9 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_9
       ,1
       ,INSTRB(anc_id_9,'(]',1,1) -1)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,1) + 2
       ,INSTRB(anc_id_9,'(]',1,2) -
        INSTRB(anc_id_9,'(]',1,1) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,2) + 2
       ,INSTRB(anc_id_9,'(]',1,3) -
        INSTRB(anc_id_9,'(]',1,2) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,3) + 2
       ,INSTRB(anc_id_9,'(]',1,4) -
        INSTRB(anc_id_9,'(]',1,3) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,4) + 2
       ,INSTRB(anc_id_9,'(]',1,5) -
        INSTRB(anc_id_9,'(]',1,4) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,5) + 2
       ,INSTRB(anc_id_9,'(]',1,6) -
        INSTRB(anc_id_9,'(]',1,5) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,6) + 2
       ,INSTRB(anc_id_9,'(]',1,7) -
        INSTRB(anc_id_9,'(]',1,6) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,7) + 2
       ,LENGTHB(anc_id_9))
)

WHEN anc_id_10 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_10
       ,1
       ,INSTRB(anc_id_10,'(]',1,1) -1)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,1) + 2
       ,INSTRB(anc_id_10,'(]',1,2) -
        INSTRB(anc_id_10,'(]',1,1) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,2) + 2
       ,INSTRB(anc_id_10,'(]',1,3) -
        INSTRB(anc_id_10,'(]',1,2) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,3) + 2
       ,INSTRB(anc_id_10,'(]',1,4) -
        INSTRB(anc_id_10,'(]',1,3) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,4) + 2
       ,INSTRB(anc_id_10,'(]',1,5) -
        INSTRB(anc_id_10,'(]',1,4) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,5) + 2
       ,INSTRB(anc_id_10,'(]',1,6) -
        INSTRB(anc_id_10,'(]',1,5) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,6) + 2
       ,INSTRB(anc_id_10,'(]',1,7) -
        INSTRB(anc_id_10,'(]',1,6) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,7) + 2
       ,LENGTHB(anc_id_10))
)

WHEN anc_id_11 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_11
       ,1
       ,INSTRB(anc_id_11,'(]',1,1) -1)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,1) + 2
       ,INSTRB(anc_id_11,'(]',1,2) -
        INSTRB(anc_id_11,'(]',1,1) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,2) + 2
       ,INSTRB(anc_id_11,'(]',1,3) -
        INSTRB(anc_id_11,'(]',1,2) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,3) + 2
       ,INSTRB(anc_id_11,'(]',1,4) -
        INSTRB(anc_id_11,'(]',1,3) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,4) + 2
       ,INSTRB(anc_id_11,'(]',1,5) -
        INSTRB(anc_id_11,'(]',1,4) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,5) + 2
       ,INSTRB(anc_id_11,'(]',1,6) -
        INSTRB(anc_id_11,'(]',1,5) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,6) + 2
       ,INSTRB(anc_id_11,'(]',1,7) -
        INSTRB(anc_id_11,'(]',1,6) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,7) + 2
       ,LENGTHB(anc_id_11))
)

WHEN anc_id_12 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_12
       ,1
       ,INSTRB(anc_id_12,'(]',1,1) -1)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,1) + 2
       ,INSTRB(anc_id_12,'(]',1,2) -
        INSTRB(anc_id_12,'(]',1,1) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,2) + 2
       ,INSTRB(anc_id_12,'(]',1,3) -
        INSTRB(anc_id_12,'(]',1,2) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,3) + 2
       ,INSTRB(anc_id_12,'(]',1,4) -
        INSTRB(anc_id_12,'(]',1,3) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,4) + 2
       ,INSTRB(anc_id_12,'(]',1,5) -
        INSTRB(anc_id_12,'(]',1,4) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,5) + 2
       ,INSTRB(anc_id_12,'(]',1,6) -
        INSTRB(anc_id_12,'(]',1,5) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,6) + 2
       ,INSTRB(anc_id_12,'(]',1,7) -
        INSTRB(anc_id_12,'(]',1,6) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,7) + 2
       ,LENGTHB(anc_id_12))
)

WHEN anc_id_13 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_13
       ,1
       ,INSTRB(anc_id_13,'(]',1,1) -1)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,1) + 2
       ,INSTRB(anc_id_13,'(]',1,2) -
        INSTRB(anc_id_13,'(]',1,1) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,2) + 2
       ,INSTRB(anc_id_13,'(]',1,3) -
        INSTRB(anc_id_13,'(]',1,2) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,3) + 2
       ,INSTRB(anc_id_13,'(]',1,4) -
        INSTRB(anc_id_13,'(]',1,3) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,4) + 2
       ,INSTRB(anc_id_13,'(]',1,5) -
        INSTRB(anc_id_13,'(]',1,4) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,5) + 2
       ,INSTRB(anc_id_13,'(]',1,6) -
        INSTRB(anc_id_13,'(]',1,5) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,6) + 2
       ,INSTRB(anc_id_13,'(]',1,7) -
        INSTRB(anc_id_13,'(]',1,6) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,7) + 2
       ,LENGTHB(anc_id_13))
)

WHEN anc_id_14 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_14
       ,1
       ,INSTRB(anc_id_14,'(]',1,1) -1)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,1) + 2
       ,INSTRB(anc_id_14,'(]',1,2) -
        INSTRB(anc_id_14,'(]',1,1) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,2) + 2
       ,INSTRB(anc_id_14,'(]',1,3) -
        INSTRB(anc_id_14,'(]',1,2) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,3) + 2
       ,INSTRB(anc_id_14,'(]',1,4) -
        INSTRB(anc_id_14,'(]',1,3) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,4) + 2
       ,INSTRB(anc_id_14,'(]',1,5) -
        INSTRB(anc_id_14,'(]',1,4) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,5) + 2
       ,INSTRB(anc_id_14,'(]',1,6) -
        INSTRB(anc_id_14,'(]',1,5) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,6) + 2
       ,INSTRB(anc_id_14,'(]',1,7) -
        INSTRB(anc_id_14,'(]',1,6) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,7) + 2
       ,LENGTHB(anc_id_14))
)

WHEN anc_id_15 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_15
       ,1
       ,INSTRB(anc_id_15,'(]',1,1) -1)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,1) + 2
       ,INSTRB(anc_id_15,'(]',1,2) -
        INSTRB(anc_id_15,'(]',1,1) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,2) + 2
       ,INSTRB(anc_id_15,'(]',1,3) -
        INSTRB(anc_id_15,'(]',1,2) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,3) + 2
       ,INSTRB(anc_id_15,'(]',1,4) -
        INSTRB(anc_id_15,'(]',1,3) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,4) + 2
       ,INSTRB(anc_id_15,'(]',1,5) -
        INSTRB(anc_id_15,'(]',1,4) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,5) + 2
       ,INSTRB(anc_id_15,'(]',1,6) -
        INSTRB(anc_id_15,'(]',1,5) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,6) + 2
       ,INSTRB(anc_id_15,'(]',1,7) -
        INSTRB(anc_id_15,'(]',1,6) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,7) + 2
       ,LENGTHB(anc_id_15))
)

WHEN anc_id_16 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_16
       ,1
       ,INSTRB(anc_id_16,'(]',1,1) -1)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,1) + 2
       ,INSTRB(anc_id_16,'(]',1,2) -
        INSTRB(anc_id_16,'(]',1,1) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,2) + 2
       ,INSTRB(anc_id_16,'(]',1,3) -
        INSTRB(anc_id_16,'(]',1,2) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,3) + 2
       ,INSTRB(anc_id_16,'(]',1,4) -
        INSTRB(anc_id_16,'(]',1,3) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,4) + 2
       ,INSTRB(anc_id_16,'(]',1,5) -
        INSTRB(anc_id_16,'(]',1,4) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,5) + 2
       ,INSTRB(anc_id_16,'(]',1,6) -
        INSTRB(anc_id_16,'(]',1,5) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,6) + 2
       ,INSTRB(anc_id_16,'(]',1,7) -
        INSTRB(anc_id_16,'(]',1,6) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,7) + 2
       ,LENGTHB(anc_id_16))
)

WHEN anc_id_17 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_17
       ,1
       ,INSTRB(anc_id_17,'(]',1,1) -1)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,1) + 2
       ,INSTRB(anc_id_17,'(]',1,2) -
        INSTRB(anc_id_17,'(]',1,1) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,2) + 2
       ,INSTRB(anc_id_17,'(]',1,3) -
        INSTRB(anc_id_17,'(]',1,2) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,3) + 2
       ,INSTRB(anc_id_17,'(]',1,4) -
        INSTRB(anc_id_17,'(]',1,3) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,4) + 2
       ,INSTRB(anc_id_17,'(]',1,5) -
        INSTRB(anc_id_17,'(]',1,4) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,5) + 2
       ,INSTRB(anc_id_17,'(]',1,6) -
        INSTRB(anc_id_17,'(]',1,5) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,6) + 2
       ,INSTRB(anc_id_17,'(]',1,7) -
        INSTRB(anc_id_17,'(]',1,6) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,7) + 2
       ,LENGTHB(anc_id_17))
)

WHEN anc_id_18 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_18
       ,1
       ,INSTRB(anc_id_18,'(]',1,1) -1)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,1) + 2
       ,INSTRB(anc_id_18,'(]',1,2) -
        INSTRB(anc_id_18,'(]',1,1) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,2) + 2
       ,INSTRB(anc_id_18,'(]',1,3) -
        INSTRB(anc_id_18,'(]',1,2) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,3) + 2
       ,INSTRB(anc_id_18,'(]',1,4) -
        INSTRB(anc_id_18,'(]',1,3) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,4) + 2
       ,INSTRB(anc_id_18,'(]',1,5) -
        INSTRB(anc_id_18,'(]',1,4) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,5) + 2
       ,INSTRB(anc_id_18,'(]',1,6) -
        INSTRB(anc_id_18,'(]',1,5) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,6) + 2
       ,INSTRB(anc_id_18,'(]',1,7) -
        INSTRB(anc_id_18,'(]',1,6) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,7) + 2
       ,LENGTHB(anc_id_18))
)

WHEN anc_id_19 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_19
       ,1
       ,INSTRB(anc_id_19,'(]',1,1) -1)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,1) + 2
       ,INSTRB(anc_id_19,'(]',1,2) -
        INSTRB(anc_id_19,'(]',1,1) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,2) + 2
       ,INSTRB(anc_id_19,'(]',1,3) -
        INSTRB(anc_id_19,'(]',1,2) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,3) + 2
       ,INSTRB(anc_id_19,'(]',1,4) -
        INSTRB(anc_id_19,'(]',1,3) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,4) + 2
       ,INSTRB(anc_id_19,'(]',1,5) -
        INSTRB(anc_id_19,'(]',1,4) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,5) + 2
       ,INSTRB(anc_id_19,'(]',1,6) -
        INSTRB(anc_id_19,'(]',1,5) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,6) + 2
       ,INSTRB(anc_id_19,'(]',1,7) -
        INSTRB(anc_id_19,'(]',1,6) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,7) + 2
       ,LENGTHB(anc_id_19))
)

WHEN anc_id_20 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_20
       ,1
       ,INSTRB(anc_id_20,'(]',1,1) -1)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,1) + 2
       ,INSTRB(anc_id_20,'(]',1,2) -
        INSTRB(anc_id_20,'(]',1,1) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,2) + 2
       ,INSTRB(anc_id_20,'(]',1,3) -
        INSTRB(anc_id_20,'(]',1,2) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,3) + 2
       ,INSTRB(anc_id_20,'(]',1,4) -
        INSTRB(anc_id_20,'(]',1,3) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,4) + 2
       ,INSTRB(anc_id_20,'(]',1,5) -
        INSTRB(anc_id_20,'(]',1,4) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,5) + 2
       ,INSTRB(anc_id_20,'(]',1,6) -
        INSTRB(anc_id_20,'(]',1,5) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,6) + 2
       ,INSTRB(anc_id_20,'(]',1,7) -
        INSTRB(anc_id_20,'(]',1,6) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,7) + 2
       ,LENGTHB(anc_id_20))
)

WHEN anc_id_21 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_21
       ,1
       ,INSTRB(anc_id_21,'(]',1,1) -1)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,1) + 2
       ,INSTRB(anc_id_21,'(]',1,2) -
        INSTRB(anc_id_21,'(]',1,1) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,2) + 2
       ,INSTRB(anc_id_21,'(]',1,3) -
        INSTRB(anc_id_21,'(]',1,2) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,3) + 2
       ,INSTRB(anc_id_21,'(]',1,4) -
        INSTRB(anc_id_21,'(]',1,3) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,4) + 2
       ,INSTRB(anc_id_21,'(]',1,5) -
        INSTRB(anc_id_21,'(]',1,4) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,5) + 2
       ,INSTRB(anc_id_21,'(]',1,6) -
        INSTRB(anc_id_21,'(]',1,5) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,6) + 2
       ,INSTRB(anc_id_21,'(]',1,7) -
        INSTRB(anc_id_21,'(]',1,6) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,7) + 2
       ,LENGTHB(anc_id_21))
)

WHEN anc_id_22 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_22
       ,1
       ,INSTRB(anc_id_22,'(]',1,1) -1)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,1) + 2
       ,INSTRB(anc_id_22,'(]',1,2) -
        INSTRB(anc_id_22,'(]',1,1) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,2) + 2
       ,INSTRB(anc_id_22,'(]',1,3) -
        INSTRB(anc_id_22,'(]',1,2) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,3) + 2
       ,INSTRB(anc_id_22,'(]',1,4) -
        INSTRB(anc_id_22,'(]',1,3) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,4) + 2
       ,INSTRB(anc_id_22,'(]',1,5) -
        INSTRB(anc_id_22,'(]',1,4) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,5) + 2
       ,INSTRB(anc_id_22,'(]',1,6) -
        INSTRB(anc_id_22,'(]',1,5) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,6) + 2
       ,INSTRB(anc_id_22,'(]',1,7) -
        INSTRB(anc_id_22,'(]',1,6) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,7) + 2
       ,LENGTHB(anc_id_22))
)

WHEN anc_id_23 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_23
       ,1
       ,INSTRB(anc_id_23,'(]',1,1) -1)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,1) + 2
       ,INSTRB(anc_id_23,'(]',1,2) -
        INSTRB(anc_id_23,'(]',1,1) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,2) + 2
       ,INSTRB(anc_id_23,'(]',1,3) -
        INSTRB(anc_id_23,'(]',1,2) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,3) + 2
       ,INSTRB(anc_id_23,'(]',1,4) -
        INSTRB(anc_id_23,'(]',1,3) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,4) + 2
       ,INSTRB(anc_id_23,'(]',1,5) -
        INSTRB(anc_id_23,'(]',1,4) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,5) + 2
       ,INSTRB(anc_id_23,'(]',1,6) -
        INSTRB(anc_id_23,'(]',1,5) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,6) + 2
       ,INSTRB(anc_id_23,'(]',1,7) -
        INSTRB(anc_id_23,'(]',1,6) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,7) + 2
       ,LENGTHB(anc_id_23))
)

WHEN anc_id_24 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_24
       ,1
       ,INSTRB(anc_id_24,'(]',1,1) -1)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,1) + 2
       ,INSTRB(anc_id_24,'(]',1,2) -
        INSTRB(anc_id_24,'(]',1,1) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,2) + 2
       ,INSTRB(anc_id_24,'(]',1,3) -
        INSTRB(anc_id_24,'(]',1,2) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,3) + 2
       ,INSTRB(anc_id_24,'(]',1,4) -
        INSTRB(anc_id_24,'(]',1,3) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,4) + 2
       ,INSTRB(anc_id_24,'(]',1,5) -
        INSTRB(anc_id_24,'(]',1,4) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,5) + 2
       ,INSTRB(anc_id_24,'(]',1,6) -
        INSTRB(anc_id_24,'(]',1,5) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,6) + 2
       ,INSTRB(anc_id_24,'(]',1,7) -
        INSTRB(anc_id_24,'(]',1,6) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,7) + 2
       ,LENGTHB(anc_id_24))
)

WHEN anc_id_25 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_25
       ,1
       ,INSTRB(anc_id_25,'(]',1,1) -1)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,1) + 2
       ,INSTRB(anc_id_25,'(]',1,2) -
        INSTRB(anc_id_25,'(]',1,1) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,2) + 2
       ,INSTRB(anc_id_25,'(]',1,3) -
        INSTRB(anc_id_25,'(]',1,2) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,3) + 2
       ,INSTRB(anc_id_25,'(]',1,4) -
        INSTRB(anc_id_25,'(]',1,3) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,4) + 2
       ,INSTRB(anc_id_25,'(]',1,5) -
        INSTRB(anc_id_25,'(]',1,4) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,5) + 2
       ,INSTRB(anc_id_25,'(]',1,6) -
        INSTRB(anc_id_25,'(]',1,5) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,6) + 2
       ,INSTRB(anc_id_25,'(]',1,7) -
        INSTRB(anc_id_25,'(]',1,6) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,7) + 2
       ,LENGTHB(anc_id_25))
)

WHEN anc_id_26 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_26
       ,1
       ,INSTRB(anc_id_26,'(]',1,1) -1)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,1) + 2
       ,INSTRB(anc_id_26,'(]',1,2) -
        INSTRB(anc_id_26,'(]',1,1) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,2) + 2
       ,INSTRB(anc_id_26,'(]',1,3) -
        INSTRB(anc_id_26,'(]',1,2) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,3) + 2
       ,INSTRB(anc_id_26,'(]',1,4) -
        INSTRB(anc_id_26,'(]',1,3) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,4) + 2
       ,INSTRB(anc_id_26,'(]',1,5) -
        INSTRB(anc_id_26,'(]',1,4) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,5) + 2
       ,INSTRB(anc_id_26,'(]',1,6) -
        INSTRB(anc_id_26,'(]',1,5) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,6) + 2
       ,INSTRB(anc_id_26,'(]',1,7) -
        INSTRB(anc_id_26,'(]',1,6) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,7) + 2
       ,LENGTHB(anc_id_26))
)

WHEN anc_id_27 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_27
       ,1
       ,INSTRB(anc_id_27,'(]',1,1) -1)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,1) + 2
       ,INSTRB(anc_id_27,'(]',1,2) -
        INSTRB(anc_id_27,'(]',1,1) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,2) + 2
       ,INSTRB(anc_id_27,'(]',1,3) -
        INSTRB(anc_id_27,'(]',1,2) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,3) + 2
       ,INSTRB(anc_id_27,'(]',1,4) -
        INSTRB(anc_id_27,'(]',1,3) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,4) + 2
       ,INSTRB(anc_id_27,'(]',1,5) -
        INSTRB(anc_id_27,'(]',1,4) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,5) + 2
       ,INSTRB(anc_id_27,'(]',1,6) -
        INSTRB(anc_id_27,'(]',1,5) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,6) + 2
       ,INSTRB(anc_id_27,'(]',1,7) -
        INSTRB(anc_id_27,'(]',1,6) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,7) + 2
       ,LENGTHB(anc_id_27))
)

WHEN anc_id_28 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_28
       ,1
       ,INSTRB(anc_id_28,'(]',1,1) -1)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,1) + 2
       ,INSTRB(anc_id_28,'(]',1,2) -
        INSTRB(anc_id_28,'(]',1,1) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,2) + 2
       ,INSTRB(anc_id_28,'(]',1,3) -
        INSTRB(anc_id_28,'(]',1,2) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,3) + 2
       ,INSTRB(anc_id_28,'(]',1,4) -
        INSTRB(anc_id_28,'(]',1,3) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,4) + 2
       ,INSTRB(anc_id_28,'(]',1,5) -
        INSTRB(anc_id_28,'(]',1,4) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,5) + 2
       ,INSTRB(anc_id_28,'(]',1,6) -
        INSTRB(anc_id_28,'(]',1,5) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,6) + 2
       ,INSTRB(anc_id_28,'(]',1,7) -
        INSTRB(anc_id_28,'(]',1,6) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,7) + 2
       ,LENGTHB(anc_id_28))
)

WHEN anc_id_29 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_29
       ,1
       ,INSTRB(anc_id_29,'(]',1,1) -1)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,1) + 2
       ,INSTRB(anc_id_29,'(]',1,2) -
        INSTRB(anc_id_29,'(]',1,1) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,2) + 2
       ,INSTRB(anc_id_29,'(]',1,3) -
        INSTRB(anc_id_29,'(]',1,2) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,3) + 2
       ,INSTRB(anc_id_29,'(]',1,4) -
        INSTRB(anc_id_29,'(]',1,3) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,4) + 2
       ,INSTRB(anc_id_29,'(]',1,5) -
        INSTRB(anc_id_29,'(]',1,4) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,5) + 2
       ,INSTRB(anc_id_29,'(]',1,6) -
        INSTRB(anc_id_29,'(]',1,5) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,6) + 2
       ,INSTRB(anc_id_29,'(]',1,7) -
        INSTRB(anc_id_29,'(]',1,6) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,7) + 2
       ,LENGTHB(anc_id_29))
)

WHEN anc_id_30 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_30
       ,1
       ,INSTRB(anc_id_30,'(]',1,1) -1)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,1) + 2
       ,INSTRB(anc_id_30,'(]',1,2) -
        INSTRB(anc_id_30,'(]',1,1) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,2) + 2
       ,INSTRB(anc_id_30,'(]',1,3) -
        INSTRB(anc_id_30,'(]',1,2) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,3) + 2
       ,INSTRB(anc_id_30,'(]',1,4) -
        INSTRB(anc_id_30,'(]',1,3) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,4) + 2
       ,INSTRB(anc_id_30,'(]',1,5) -
        INSTRB(anc_id_30,'(]',1,4) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,5) + 2
       ,INSTRB(anc_id_30,'(]',1,6) -
        INSTRB(anc_id_30,'(]',1,5) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,6) + 2
       ,INSTRB(anc_id_30,'(]',1,7) -
        INSTRB(anc_id_30,'(]',1,6) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,7) + 2
       ,LENGTHB(anc_id_30))
)

WHEN anc_id_31 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_31
       ,1
       ,INSTRB(anc_id_31,'(]',1,1) -1)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,1) + 2
       ,INSTRB(anc_id_31,'(]',1,2) -
        INSTRB(anc_id_31,'(]',1,1) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,2) + 2
       ,INSTRB(anc_id_31,'(]',1,3) -
        INSTRB(anc_id_31,'(]',1,2) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,3) + 2
       ,INSTRB(anc_id_31,'(]',1,4) -
        INSTRB(anc_id_31,'(]',1,3) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,4) + 2
       ,INSTRB(anc_id_31,'(]',1,5) -
        INSTRB(anc_id_31,'(]',1,4) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,5) + 2
       ,INSTRB(anc_id_31,'(]',1,6) -
        INSTRB(anc_id_31,'(]',1,5) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,6) + 2
       ,INSTRB(anc_id_31,'(]',1,7) -
        INSTRB(anc_id_31,'(]',1,6) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,7) + 2
       ,LENGTHB(anc_id_31))
)

WHEN anc_id_32 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_32
       ,1
       ,INSTRB(anc_id_32,'(]',1,1) -1)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,1) + 2
       ,INSTRB(anc_id_32,'(]',1,2) -
        INSTRB(anc_id_32,'(]',1,1) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,2) + 2
       ,INSTRB(anc_id_32,'(]',1,3) -
        INSTRB(anc_id_32,'(]',1,2) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,3) + 2
       ,INSTRB(anc_id_32,'(]',1,4) -
        INSTRB(anc_id_32,'(]',1,3) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,4) + 2
       ,INSTRB(anc_id_32,'(]',1,5) -
        INSTRB(anc_id_32,'(]',1,4) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,5) + 2
       ,INSTRB(anc_id_32,'(]',1,6) -
        INSTRB(anc_id_32,'(]',1,5) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,6) + 2
       ,INSTRB(anc_id_32,'(]',1,7) -
        INSTRB(anc_id_32,'(]',1,6) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,7) + 2
       ,LENGTHB(anc_id_32))
)

WHEN anc_id_33 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_33
       ,1
       ,INSTRB(anc_id_33,'(]',1,1) -1)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,1) + 2
       ,INSTRB(anc_id_33,'(]',1,2) -
        INSTRB(anc_id_33,'(]',1,1) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,2) + 2
       ,INSTRB(anc_id_33,'(]',1,3) -
        INSTRB(anc_id_33,'(]',1,2) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,3) + 2
       ,INSTRB(anc_id_33,'(]',1,4) -
        INSTRB(anc_id_33,'(]',1,3) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,4) + 2
       ,INSTRB(anc_id_33,'(]',1,5) -
        INSTRB(anc_id_33,'(]',1,4) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,5) + 2
       ,INSTRB(anc_id_33,'(]',1,6) -
        INSTRB(anc_id_33,'(]',1,5) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,6) + 2
       ,INSTRB(anc_id_33,'(]',1,7) -
        INSTRB(anc_id_33,'(]',1,6) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,7) + 2
       ,LENGTHB(anc_id_33))
)

WHEN anc_id_34 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_34
       ,1
       ,INSTRB(anc_id_34,'(]',1,1) -1)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,1) + 2
       ,INSTRB(anc_id_34,'(]',1,2) -
        INSTRB(anc_id_34,'(]',1,1) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,2) + 2
       ,INSTRB(anc_id_34,'(]',1,3) -
        INSTRB(anc_id_34,'(]',1,2) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,3) + 2
       ,INSTRB(anc_id_34,'(]',1,4) -
        INSTRB(anc_id_34,'(]',1,3) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,4) + 2
       ,INSTRB(anc_id_34,'(]',1,5) -
        INSTRB(anc_id_34,'(]',1,4) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,5) + 2
       ,INSTRB(anc_id_34,'(]',1,6) -
        INSTRB(anc_id_34,'(]',1,5) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,6) + 2
       ,INSTRB(anc_id_34,'(]',1,7) -
        INSTRB(anc_id_34,'(]',1,6) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,7) + 2
       ,LENGTHB(anc_id_34))
)

WHEN anc_id_35 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_35
       ,1
       ,INSTRB(anc_id_35,'(]',1,1) -1)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,1) + 2
       ,INSTRB(anc_id_35,'(]',1,2) -
        INSTRB(anc_id_35,'(]',1,1) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,2) + 2
       ,INSTRB(anc_id_35,'(]',1,3) -
        INSTRB(anc_id_35,'(]',1,2) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,3) + 2
       ,INSTRB(anc_id_35,'(]',1,4) -
        INSTRB(anc_id_35,'(]',1,3) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,4) + 2
       ,INSTRB(anc_id_35,'(]',1,5) -
        INSTRB(anc_id_35,'(]',1,4) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,5) + 2
       ,INSTRB(anc_id_35,'(]',1,6) -
        INSTRB(anc_id_35,'(]',1,5) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,6) + 2
       ,INSTRB(anc_id_35,'(]',1,7) -
        INSTRB(anc_id_35,'(]',1,6) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,7) + 2
       ,LENGTHB(anc_id_35))
)

WHEN anc_id_36 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_36
       ,1
       ,INSTRB(anc_id_36,'(]',1,1) -1)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,1) + 2
       ,INSTRB(anc_id_36,'(]',1,2) -
        INSTRB(anc_id_36,'(]',1,1) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,2) + 2
       ,INSTRB(anc_id_36,'(]',1,3) -
        INSTRB(anc_id_36,'(]',1,2) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,3) + 2
       ,INSTRB(anc_id_36,'(]',1,4) -
        INSTRB(anc_id_36,'(]',1,3) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,4) + 2
       ,INSTRB(anc_id_36,'(]',1,5) -
        INSTRB(anc_id_36,'(]',1,4) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,5) + 2
       ,INSTRB(anc_id_36,'(]',1,6) -
        INSTRB(anc_id_36,'(]',1,5) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,6) + 2
       ,INSTRB(anc_id_36,'(]',1,7) -
        INSTRB(anc_id_36,'(]',1,6) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,7) + 2
       ,LENGTHB(anc_id_36))
)

WHEN anc_id_37 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_37
       ,1
       ,INSTRB(anc_id_37,'(]',1,1) -1)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,1) + 2
       ,INSTRB(anc_id_37,'(]',1,2) -
        INSTRB(anc_id_37,'(]',1,1) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,2) + 2
       ,INSTRB(anc_id_37,'(]',1,3) -
        INSTRB(anc_id_37,'(]',1,2) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,3) + 2
       ,INSTRB(anc_id_37,'(]',1,4) -
        INSTRB(anc_id_37,'(]',1,3) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,4) + 2
       ,INSTRB(anc_id_37,'(]',1,5) -
        INSTRB(anc_id_37,'(]',1,4) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,5) + 2
       ,INSTRB(anc_id_37,'(]',1,6) -
        INSTRB(anc_id_37,'(]',1,5) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,6) + 2
       ,INSTRB(anc_id_37,'(]',1,7) -
        INSTRB(anc_id_37,'(]',1,6) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,7) + 2
       ,LENGTHB(anc_id_37))
)

WHEN anc_id_38 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_38
       ,1
       ,INSTRB(anc_id_38,'(]',1,1) -1)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,1) + 2
       ,INSTRB(anc_id_38,'(]',1,2) -
        INSTRB(anc_id_38,'(]',1,1) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,2) + 2
       ,INSTRB(anc_id_38,'(]',1,3) -
        INSTRB(anc_id_38,'(]',1,2) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,3) + 2
       ,INSTRB(anc_id_38,'(]',1,4) -
        INSTRB(anc_id_38,'(]',1,3) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,4) + 2
       ,INSTRB(anc_id_38,'(]',1,5) -
        INSTRB(anc_id_38,'(]',1,4) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,5) + 2
       ,INSTRB(anc_id_38,'(]',1,6) -
        INSTRB(anc_id_38,'(]',1,5) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,6) + 2
       ,INSTRB(anc_id_38,'(]',1,7) -
        INSTRB(anc_id_38,'(]',1,6) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,7) + 2
       ,LENGTHB(anc_id_38))
)

WHEN anc_id_39 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_39
       ,1
       ,INSTRB(anc_id_39,'(]',1,1) -1)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,1) + 2
       ,INSTRB(anc_id_39,'(]',1,2) -
        INSTRB(anc_id_39,'(]',1,1) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,2) + 2
       ,INSTRB(anc_id_39,'(]',1,3) -
        INSTRB(anc_id_39,'(]',1,2) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,3) + 2
       ,INSTRB(anc_id_39,'(]',1,4) -
        INSTRB(anc_id_39,'(]',1,3) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,4) + 2
       ,INSTRB(anc_id_39,'(]',1,5) -
        INSTRB(anc_id_39,'(]',1,4) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,5) + 2
       ,INSTRB(anc_id_39,'(]',1,6) -
        INSTRB(anc_id_39,'(]',1,5) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,6) + 2
       ,INSTRB(anc_id_39,'(]',1,7) -
        INSTRB(anc_id_39,'(]',1,6) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,7) + 2
       ,LENGTHB(anc_id_39))
)

WHEN anc_id_40 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_40
       ,1
       ,INSTRB(anc_id_40,'(]',1,1) -1)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,1) + 2
       ,INSTRB(anc_id_40,'(]',1,2) -
        INSTRB(anc_id_40,'(]',1,1) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,2) + 2
       ,INSTRB(anc_id_40,'(]',1,3) -
        INSTRB(anc_id_40,'(]',1,2) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,3) + 2
       ,INSTRB(anc_id_40,'(]',1,4) -
        INSTRB(anc_id_40,'(]',1,3) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,4) + 2
       ,INSTRB(anc_id_40,'(]',1,5) -
        INSTRB(anc_id_40,'(]',1,4) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,5) + 2
       ,INSTRB(anc_id_40,'(]',1,6) -
        INSTRB(anc_id_40,'(]',1,5) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,6) + 2
       ,INSTRB(anc_id_40,'(]',1,7) -
        INSTRB(anc_id_40,'(]',1,6) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,7) + 2
       ,LENGTHB(anc_id_40))
)

WHEN anc_id_41 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_41
       ,1
       ,INSTRB(anc_id_41,'(]',1,1) -1)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,1) + 2
       ,INSTRB(anc_id_41,'(]',1,2) -
        INSTRB(anc_id_41,'(]',1,1) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,2) + 2
       ,INSTRB(anc_id_41,'(]',1,3) -
        INSTRB(anc_id_41,'(]',1,2) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,3) + 2
       ,INSTRB(anc_id_41,'(]',1,4) -
        INSTRB(anc_id_41,'(]',1,3) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,4) + 2
       ,INSTRB(anc_id_41,'(]',1,5) -
        INSTRB(anc_id_41,'(]',1,4) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,5) + 2
       ,INSTRB(anc_id_41,'(]',1,6) -
        INSTRB(anc_id_41,'(]',1,5) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,6) + 2
       ,INSTRB(anc_id_41,'(]',1,7) -
        INSTRB(anc_id_41,'(]',1,6) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,7) + 2
       ,LENGTHB(anc_id_41))
)

WHEN anc_id_42 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_42
       ,1
       ,INSTRB(anc_id_42,'(]',1,1) -1)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,1) + 2
       ,INSTRB(anc_id_42,'(]',1,2) -
        INSTRB(anc_id_42,'(]',1,1) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,2) + 2
       ,INSTRB(anc_id_42,'(]',1,3) -
        INSTRB(anc_id_42,'(]',1,2) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,3) + 2
       ,INSTRB(anc_id_42,'(]',1,4) -
        INSTRB(anc_id_42,'(]',1,3) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,4) + 2
       ,INSTRB(anc_id_42,'(]',1,5) -
        INSTRB(anc_id_42,'(]',1,4) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,5) + 2
       ,INSTRB(anc_id_42,'(]',1,6) -
        INSTRB(anc_id_42,'(]',1,5) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,6) + 2
       ,INSTRB(anc_id_42,'(]',1,7) -
        INSTRB(anc_id_42,'(]',1,6) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,7) + 2
       ,LENGTHB(anc_id_42))
)

WHEN anc_id_43 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_43
       ,1
       ,INSTRB(anc_id_43,'(]',1,1) -1)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,1) + 2
       ,INSTRB(anc_id_43,'(]',1,2) -
        INSTRB(anc_id_43,'(]',1,1) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,2) + 2
       ,INSTRB(anc_id_43,'(]',1,3) -
        INSTRB(anc_id_43,'(]',1,2) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,3) + 2
       ,INSTRB(anc_id_43,'(]',1,4) -
        INSTRB(anc_id_43,'(]',1,3) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,4) + 2
       ,INSTRB(anc_id_43,'(]',1,5) -
        INSTRB(anc_id_43,'(]',1,4) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,5) + 2
       ,INSTRB(anc_id_43,'(]',1,6) -
        INSTRB(anc_id_43,'(]',1,5) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,6) + 2
       ,INSTRB(anc_id_43,'(]',1,7) -
        INSTRB(anc_id_43,'(]',1,6) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,7) + 2
       ,LENGTHB(anc_id_43))
)

WHEN anc_id_44 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_44
       ,1
       ,INSTRB(anc_id_44,'(]',1,1) -1)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,1) + 2
       ,INSTRB(anc_id_44,'(]',1,2) -
        INSTRB(anc_id_44,'(]',1,1) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,2) + 2
       ,INSTRB(anc_id_44,'(]',1,3) -
        INSTRB(anc_id_44,'(]',1,2) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,3) + 2
       ,INSTRB(anc_id_44,'(]',1,4) -
        INSTRB(anc_id_44,'(]',1,3) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,4) + 2
       ,INSTRB(anc_id_44,'(]',1,5) -
        INSTRB(anc_id_44,'(]',1,4) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,5) + 2
       ,INSTRB(anc_id_44,'(]',1,6) -
        INSTRB(anc_id_44,'(]',1,5) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,6) + 2
       ,INSTRB(anc_id_44,'(]',1,7) -
        INSTRB(anc_id_44,'(]',1,6) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,7) + 2
       ,LENGTHB(anc_id_44))
)

WHEN anc_id_45 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_45
       ,1
       ,INSTRB(anc_id_45,'(]',1,1) -1)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,1) + 2
       ,INSTRB(anc_id_45,'(]',1,2) -
        INSTRB(anc_id_45,'(]',1,1) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,2) + 2
       ,INSTRB(anc_id_45,'(]',1,3) -
        INSTRB(anc_id_45,'(]',1,2) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,3) + 2
       ,INSTRB(anc_id_45,'(]',1,4) -
        INSTRB(anc_id_45,'(]',1,3) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,4) + 2
       ,INSTRB(anc_id_45,'(]',1,5) -
        INSTRB(anc_id_45,'(]',1,4) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,5) + 2
       ,INSTRB(anc_id_45,'(]',1,6) -
        INSTRB(anc_id_45,'(]',1,5) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,6) + 2
       ,INSTRB(anc_id_45,'(]',1,7) -
        INSTRB(anc_id_45,'(]',1,6) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,7) + 2
       ,LENGTHB(anc_id_45))
)

WHEN anc_id_46 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_46
       ,1
       ,INSTRB(anc_id_46,'(]',1,1) -1)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,1) + 2
       ,INSTRB(anc_id_46,'(]',1,2) -
        INSTRB(anc_id_46,'(]',1,1) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,2) + 2
       ,INSTRB(anc_id_46,'(]',1,3) -
        INSTRB(anc_id_46,'(]',1,2) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,3) + 2
       ,INSTRB(anc_id_46,'(]',1,4) -
        INSTRB(anc_id_46,'(]',1,3) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,4) + 2
       ,INSTRB(anc_id_46,'(]',1,5) -
        INSTRB(anc_id_46,'(]',1,4) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,5) + 2
       ,INSTRB(anc_id_46,'(]',1,6) -
        INSTRB(anc_id_46,'(]',1,5) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,6) + 2
       ,INSTRB(anc_id_46,'(]',1,7) -
        INSTRB(anc_id_46,'(]',1,6) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,7) + 2
       ,LENGTHB(anc_id_46))
)

WHEN anc_id_47 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_47
       ,1
       ,INSTRB(anc_id_47,'(]',1,1) -1)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,1) + 2
       ,INSTRB(anc_id_47,'(]',1,2) -
        INSTRB(anc_id_47,'(]',1,1) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,2) + 2
       ,INSTRB(anc_id_47,'(]',1,3) -
        INSTRB(anc_id_47,'(]',1,2) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,3) + 2
       ,INSTRB(anc_id_47,'(]',1,4) -
        INSTRB(anc_id_47,'(]',1,3) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,4) + 2
       ,INSTRB(anc_id_47,'(]',1,5) -
        INSTRB(anc_id_47,'(]',1,4) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,5) + 2
       ,INSTRB(anc_id_47,'(]',1,6) -
        INSTRB(anc_id_47,'(]',1,5) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,6) + 2
       ,INSTRB(anc_id_47,'(]',1,7) -
        INSTRB(anc_id_47,'(]',1,6) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,7) + 2
       ,LENGTHB(anc_id_47))
)

WHEN anc_id_48 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_48
       ,1
       ,INSTRB(anc_id_48,'(]',1,1) -1)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,1) + 2
       ,INSTRB(anc_id_48,'(]',1,2) -
        INSTRB(anc_id_48,'(]',1,1) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,2) + 2
       ,INSTRB(anc_id_48,'(]',1,3) -
        INSTRB(anc_id_48,'(]',1,2) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,3) + 2
       ,INSTRB(anc_id_48,'(]',1,4) -
        INSTRB(anc_id_48,'(]',1,3) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,4) + 2
       ,INSTRB(anc_id_48,'(]',1,5) -
        INSTRB(anc_id_48,'(]',1,4) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,5) + 2
       ,INSTRB(anc_id_48,'(]',1,6) -
        INSTRB(anc_id_48,'(]',1,5) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,6) + 2
       ,INSTRB(anc_id_48,'(]',1,7) -
        INSTRB(anc_id_48,'(]',1,6) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,7) + 2
       ,LENGTHB(anc_id_48))
)

WHEN anc_id_49 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_49
       ,1
       ,INSTRB(anc_id_49,'(]',1,1) -1)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,1) + 2
       ,INSTRB(anc_id_49,'(]',1,2) -
        INSTRB(anc_id_49,'(]',1,1) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,2) + 2
       ,INSTRB(anc_id_49,'(]',1,3) -
        INSTRB(anc_id_49,'(]',1,2) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,3) + 2
       ,INSTRB(anc_id_49,'(]',1,4) -
        INSTRB(anc_id_49,'(]',1,3) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,4) + 2
       ,INSTRB(anc_id_49,'(]',1,5) -
        INSTRB(anc_id_49,'(]',1,4) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,5) + 2
       ,INSTRB(anc_id_49,'(]',1,6) -
        INSTRB(anc_id_49,'(]',1,5) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,6) + 2
       ,INSTRB(anc_id_49,'(]',1,7) -
        INSTRB(anc_id_49,'(]',1,6) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,7) + 2
       ,LENGTHB(anc_id_49))
)

WHEN anc_id_50 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_50
       ,1
       ,INSTRB(anc_id_50,'(]',1,1) -1)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,1) + 2
       ,INSTRB(anc_id_50,'(]',1,2) -
        INSTRB(anc_id_50,'(]',1,1) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,2) + 2
       ,INSTRB(anc_id_50,'(]',1,3) -
        INSTRB(anc_id_50,'(]',1,2) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,3) + 2
       ,INSTRB(anc_id_50,'(]',1,4) -
        INSTRB(anc_id_50,'(]',1,3) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,4) + 2
       ,INSTRB(anc_id_50,'(]',1,5) -
        INSTRB(anc_id_50,'(]',1,4) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,5) + 2
       ,INSTRB(anc_id_50,'(]',1,6) -
        INSTRB(anc_id_50,'(]',1,5) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,6) + 2
       ,INSTRB(anc_id_50,'(]',1,7) -
        INSTRB(anc_id_50,'(]',1,6) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,7) + 2
       ,LENGTHB(anc_id_50))
)


SELECT  ae_header_id
      , ae_line_num
      , anc_id_1
      , anc_id_2
      , anc_id_3
      , anc_id_4
      , anc_id_5
      , anc_id_6
      , anc_id_7
      , anc_id_8
      , anc_id_9
      , anc_id_10
      , anc_id_11
      , anc_id_12
      , anc_id_13
      , anc_id_14
      , anc_id_15
      , anc_id_16
      , anc_id_17
      , anc_id_18
      , anc_id_19
      , anc_id_20
      , anc_id_21
      , anc_id_22
      , anc_id_23
      , anc_id_24
      , anc_id_25
      , anc_id_26
      , anc_id_27
      , anc_id_28
      , anc_id_29
      , anc_id_30
      , anc_id_31
      , anc_id_32
      , anc_id_33
      , anc_id_34
      , anc_id_35
      , anc_id_36
      , anc_id_37
      , anc_id_38
      , anc_id_39
      , anc_id_40
      , anc_id_41
      , anc_id_42
      , anc_id_43
      , anc_id_44
      , anc_id_45
      , anc_id_46
      , anc_id_47
      , anc_id_48
      , anc_id_49
      , anc_id_50
 FROM  xla_ae_lines_gt
WHERE  ae_line_num is not null
GROUP  BY
       ae_line_num
      ,ae_header_id
      ,anc_id_1
      ,anc_id_2
      ,anc_id_3
      ,anc_id_4
      ,anc_id_5
      ,anc_id_6
      ,anc_id_7
      ,anc_id_8
      ,anc_id_9
      ,anc_id_10
      ,anc_id_11
      ,anc_id_12
      ,anc_id_13
      ,anc_id_14
      ,anc_id_15
      ,anc_id_16
      ,anc_id_17
      ,anc_id_18
      ,anc_id_19
      ,anc_id_20
      ,anc_id_21
      ,anc_id_22
      ,anc_id_23
      ,anc_id_24
      ,anc_id_25
      ,anc_id_26
      ,anc_id_27
      ,anc_id_28
      ,anc_id_29
      ,anc_id_30
      ,anc_id_31
      ,anc_id_32
      ,anc_id_33
      ,anc_id_34
      ,anc_id_35
      ,anc_id_36
      ,anc_id_37
      ,anc_id_38
      ,anc_id_39
      ,anc_id_40
      ,anc_id_41
      ,anc_id_42
      ,anc_id_43
      ,anc_id_44
      ,anc_id_45
      ,anc_id_46
      ,anc_id_47
      ,anc_id_48
      ,anc_id_49
      ,anc_id_50;

   --
   l_rowcount := SQL%ROWCOUNT;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# line analytical criteria inserted into xla_ae_line_acs = '||l_rowcount
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   EXCEPTION
   WHEN OTHERS  THEN

     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
              (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
              ,p_level    => C_LEVEL_EXCEPTION
              ,p_module   => l_log_module);
     END IF;

     xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                      ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                      ,p_token_1      => 'ERROR'
                                      ,p_value_1      => sqlerrm
                                      );


   END;

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
       (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertAnalyticalCriteria50');
END InsertAnalyticalCriteria50;

--
--
/*======================================================================+
| PRIVATE Procedure                                                     |
|                                                                       |
| InsertAnalyticalCriteria100                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertAnalyticalCriteria100
IS
l_rowcount           NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertAnalyticalCriteria100';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertAnalyticalCriteria100'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_rowcount  := 0;

BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_line_acs'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

INSERT ALL
WHEN anc_id_1 IS NOT NULL and anc_id_1 not like 'DUMMY_ANC_%' THEN  --Bug 8691573
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_1
       ,1
       ,INSTRB(anc_id_1,'(]',1,1) -1)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,1) + 2
       ,INSTRB(anc_id_1,'(]',1,2) -
        INSTRB(anc_id_1,'(]',1,1) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,2) + 2
       ,INSTRB(anc_id_1,'(]',1,3) -
        INSTRB(anc_id_1,'(]',1,2) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,3) + 2
       ,INSTRB(anc_id_1,'(]',1,4) -
        INSTRB(anc_id_1,'(]',1,3) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,4) + 2
       ,INSTRB(anc_id_1,'(]',1,5) -
        INSTRB(anc_id_1,'(]',1,4) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,5) + 2
       ,INSTRB(anc_id_1,'(]',1,6) -
        INSTRB(anc_id_1,'(]',1,5) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,6) + 2
       ,INSTRB(anc_id_1,'(]',1,7) -
        INSTRB(anc_id_1,'(]',1,6) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,7) + 2
       ,LENGTHB(anc_id_1))
)

WHEN anc_id_2 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_2
       ,1
       ,INSTRB(anc_id_2,'(]',1,1) -1)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,1) + 2
       ,INSTRB(anc_id_2,'(]',1,2) -
        INSTRB(anc_id_2,'(]',1,1) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,2) + 2
       ,INSTRB(anc_id_2,'(]',1,3) -
        INSTRB(anc_id_2,'(]',1,2) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,3) + 2
       ,INSTRB(anc_id_2,'(]',1,4) -
        INSTRB(anc_id_2,'(]',1,3) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,4) + 2
       ,INSTRB(anc_id_2,'(]',1,5) -
        INSTRB(anc_id_2,'(]',1,4) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,5) + 2
       ,INSTRB(anc_id_2,'(]',1,6) -
        INSTRB(anc_id_2,'(]',1,5) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,6) + 2
       ,INSTRB(anc_id_2,'(]',1,7) -
        INSTRB(anc_id_2,'(]',1,6) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,7) + 2
       ,LENGTHB(anc_id_2))
)

WHEN anc_id_3 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_3
       ,1
       ,INSTRB(anc_id_3,'(]',1,1) -1)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,1) + 2
       ,INSTRB(anc_id_3,'(]',1,2) -
        INSTRB(anc_id_3,'(]',1,1) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,2) + 2
       ,INSTRB(anc_id_3,'(]',1,3) -
        INSTRB(anc_id_3,'(]',1,2) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,3) + 2
       ,INSTRB(anc_id_3,'(]',1,4) -
        INSTRB(anc_id_3,'(]',1,3) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,4) + 2
       ,INSTRB(anc_id_3,'(]',1,5) -
        INSTRB(anc_id_3,'(]',1,4) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,5) + 2
       ,INSTRB(anc_id_3,'(]',1,6) -
        INSTRB(anc_id_3,'(]',1,5) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,6) + 2
       ,INSTRB(anc_id_3,'(]',1,7) -
        INSTRB(anc_id_3,'(]',1,6) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,7) + 2
       ,LENGTHB(anc_id_3))
)

WHEN anc_id_4 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_4
       ,1
       ,INSTRB(anc_id_4,'(]',1,1) -1)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,1) + 2
       ,INSTRB(anc_id_4,'(]',1,2) -
        INSTRB(anc_id_4,'(]',1,1) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,2) + 2
       ,INSTRB(anc_id_4,'(]',1,3) -
        INSTRB(anc_id_4,'(]',1,2) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,3) + 2
       ,INSTRB(anc_id_4,'(]',1,4) -
        INSTRB(anc_id_4,'(]',1,3) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,4) + 2
       ,INSTRB(anc_id_4,'(]',1,5) -
        INSTRB(anc_id_4,'(]',1,4) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,5) + 2
       ,INSTRB(anc_id_4,'(]',1,6) -
        INSTRB(anc_id_4,'(]',1,5) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,6) + 2
       ,INSTRB(anc_id_4,'(]',1,7) -
        INSTRB(anc_id_4,'(]',1,6) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,7) + 2
       ,LENGTHB(anc_id_4))
)

WHEN anc_id_5 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_5
       ,1
       ,INSTRB(anc_id_5,'(]',1,1) -1)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,1) + 2
       ,INSTRB(anc_id_5,'(]',1,2) -
        INSTRB(anc_id_5,'(]',1,1) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,2) + 2
       ,INSTRB(anc_id_5,'(]',1,3) -
        INSTRB(anc_id_5,'(]',1,2) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,3) + 2
       ,INSTRB(anc_id_5,'(]',1,4) -
        INSTRB(anc_id_5,'(]',1,3) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,4) + 2
       ,INSTRB(anc_id_5,'(]',1,5) -
        INSTRB(anc_id_5,'(]',1,4) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,5) + 2
       ,INSTRB(anc_id_5,'(]',1,6) -
        INSTRB(anc_id_5,'(]',1,5) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,6) + 2
       ,INSTRB(anc_id_5,'(]',1,7) -
        INSTRB(anc_id_5,'(]',1,6) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,7) + 2
       ,LENGTHB(anc_id_5))
)

WHEN anc_id_6 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_6
       ,1
       ,INSTRB(anc_id_6,'(]',1,1) -1)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,1) + 2
       ,INSTRB(anc_id_6,'(]',1,2) -
        INSTRB(anc_id_6,'(]',1,1) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,2) + 2
       ,INSTRB(anc_id_6,'(]',1,3) -
        INSTRB(anc_id_6,'(]',1,2) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,3) + 2
       ,INSTRB(anc_id_6,'(]',1,4) -
        INSTRB(anc_id_6,'(]',1,3) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,4) + 2
       ,INSTRB(anc_id_6,'(]',1,5) -
        INSTRB(anc_id_6,'(]',1,4) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,5) + 2
       ,INSTRB(anc_id_6,'(]',1,6) -
        INSTRB(anc_id_6,'(]',1,5) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,6) + 2
       ,INSTRB(anc_id_6,'(]',1,7) -
        INSTRB(anc_id_6,'(]',1,6) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,7) + 2
       ,LENGTHB(anc_id_6))
)

WHEN anc_id_7 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_7
       ,1
       ,INSTRB(anc_id_7,'(]',1,1) -1)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,1) + 2
       ,INSTRB(anc_id_7,'(]',1,2) -
        INSTRB(anc_id_7,'(]',1,1) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,2) + 2
       ,INSTRB(anc_id_7,'(]',1,3) -
        INSTRB(anc_id_7,'(]',1,2) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,3) + 2
       ,INSTRB(anc_id_7,'(]',1,4) -
        INSTRB(anc_id_7,'(]',1,3) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,4) + 2
       ,INSTRB(anc_id_7,'(]',1,5) -
        INSTRB(anc_id_7,'(]',1,4) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,5) + 2
       ,INSTRB(anc_id_7,'(]',1,6) -
        INSTRB(anc_id_7,'(]',1,5) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,6) + 2
       ,INSTRB(anc_id_7,'(]',1,7) -
        INSTRB(anc_id_7,'(]',1,6) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,7) + 2
       ,LENGTHB(anc_id_7))
)

WHEN anc_id_8 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_8
       ,1
       ,INSTRB(anc_id_8,'(]',1,1) -1)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,1) + 2
       ,INSTRB(anc_id_8,'(]',1,2) -
        INSTRB(anc_id_8,'(]',1,1) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,2) + 2
       ,INSTRB(anc_id_8,'(]',1,3) -
        INSTRB(anc_id_8,'(]',1,2) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,3) + 2
       ,INSTRB(anc_id_8,'(]',1,4) -
        INSTRB(anc_id_8,'(]',1,3) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,4) + 2
       ,INSTRB(anc_id_8,'(]',1,5) -
        INSTRB(anc_id_8,'(]',1,4) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,5) + 2
       ,INSTRB(anc_id_8,'(]',1,6) -
        INSTRB(anc_id_8,'(]',1,5) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,6) + 2
       ,INSTRB(anc_id_8,'(]',1,7) -
        INSTRB(anc_id_8,'(]',1,6) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,7) + 2
       ,LENGTHB(anc_id_8))
)

WHEN anc_id_9 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_9
       ,1
       ,INSTRB(anc_id_9,'(]',1,1) -1)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,1) + 2
       ,INSTRB(anc_id_9,'(]',1,2) -
        INSTRB(anc_id_9,'(]',1,1) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,2) + 2
       ,INSTRB(anc_id_9,'(]',1,3) -
        INSTRB(anc_id_9,'(]',1,2) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,3) + 2
       ,INSTRB(anc_id_9,'(]',1,4) -
        INSTRB(anc_id_9,'(]',1,3) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,4) + 2
       ,INSTRB(anc_id_9,'(]',1,5) -
        INSTRB(anc_id_9,'(]',1,4) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,5) + 2
       ,INSTRB(anc_id_9,'(]',1,6) -
        INSTRB(anc_id_9,'(]',1,5) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,6) + 2
       ,INSTRB(anc_id_9,'(]',1,7) -
        INSTRB(anc_id_9,'(]',1,6) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,7) + 2
       ,LENGTHB(anc_id_9))
)

WHEN anc_id_10 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_10
       ,1
       ,INSTRB(anc_id_10,'(]',1,1) -1)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,1) + 2
       ,INSTRB(anc_id_10,'(]',1,2) -
        INSTRB(anc_id_10,'(]',1,1) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,2) + 2
       ,INSTRB(anc_id_10,'(]',1,3) -
        INSTRB(anc_id_10,'(]',1,2) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,3) + 2
       ,INSTRB(anc_id_10,'(]',1,4) -
        INSTRB(anc_id_10,'(]',1,3) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,4) + 2
       ,INSTRB(anc_id_10,'(]',1,5) -
        INSTRB(anc_id_10,'(]',1,4) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,5) + 2
       ,INSTRB(anc_id_10,'(]',1,6) -
        INSTRB(anc_id_10,'(]',1,5) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,6) + 2
       ,INSTRB(anc_id_10,'(]',1,7) -
        INSTRB(anc_id_10,'(]',1,6) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,7) + 2
       ,LENGTHB(anc_id_10))
)

WHEN anc_id_11 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_11
       ,1
       ,INSTRB(anc_id_11,'(]',1,1) -1)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,1) + 2
       ,INSTRB(anc_id_11,'(]',1,2) -
        INSTRB(anc_id_11,'(]',1,1) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,2) + 2
       ,INSTRB(anc_id_11,'(]',1,3) -
        INSTRB(anc_id_11,'(]',1,2) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,3) + 2
       ,INSTRB(anc_id_11,'(]',1,4) -
        INSTRB(anc_id_11,'(]',1,3) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,4) + 2
       ,INSTRB(anc_id_11,'(]',1,5) -
        INSTRB(anc_id_11,'(]',1,4) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,5) + 2
       ,INSTRB(anc_id_11,'(]',1,6) -
        INSTRB(anc_id_11,'(]',1,5) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,6) + 2
       ,INSTRB(anc_id_11,'(]',1,7) -
        INSTRB(anc_id_11,'(]',1,6) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,7) + 2
       ,LENGTHB(anc_id_11))
)

WHEN anc_id_12 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_12
       ,1
       ,INSTRB(anc_id_12,'(]',1,1) -1)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,1) + 2
       ,INSTRB(anc_id_12,'(]',1,2) -
        INSTRB(anc_id_12,'(]',1,1) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,2) + 2
       ,INSTRB(anc_id_12,'(]',1,3) -
        INSTRB(anc_id_12,'(]',1,2) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,3) + 2
       ,INSTRB(anc_id_12,'(]',1,4) -
        INSTRB(anc_id_12,'(]',1,3) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,4) + 2
       ,INSTRB(anc_id_12,'(]',1,5) -
        INSTRB(anc_id_12,'(]',1,4) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,5) + 2
       ,INSTRB(anc_id_12,'(]',1,6) -
        INSTRB(anc_id_12,'(]',1,5) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,6) + 2
       ,INSTRB(anc_id_12,'(]',1,7) -
        INSTRB(anc_id_12,'(]',1,6) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,7) + 2
       ,LENGTHB(anc_id_12))
)

WHEN anc_id_13 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_13
       ,1
       ,INSTRB(anc_id_13,'(]',1,1) -1)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,1) + 2
       ,INSTRB(anc_id_13,'(]',1,2) -
        INSTRB(anc_id_13,'(]',1,1) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,2) + 2
       ,INSTRB(anc_id_13,'(]',1,3) -
        INSTRB(anc_id_13,'(]',1,2) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,3) + 2
       ,INSTRB(anc_id_13,'(]',1,4) -
        INSTRB(anc_id_13,'(]',1,3) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,4) + 2
       ,INSTRB(anc_id_13,'(]',1,5) -
        INSTRB(anc_id_13,'(]',1,4) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,5) + 2
       ,INSTRB(anc_id_13,'(]',1,6) -
        INSTRB(anc_id_13,'(]',1,5) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,6) + 2
       ,INSTRB(anc_id_13,'(]',1,7) -
        INSTRB(anc_id_13,'(]',1,6) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,7) + 2
       ,LENGTHB(anc_id_13))
)

WHEN anc_id_14 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_14
       ,1
       ,INSTRB(anc_id_14,'(]',1,1) -1)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,1) + 2
       ,INSTRB(anc_id_14,'(]',1,2) -
        INSTRB(anc_id_14,'(]',1,1) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,2) + 2
       ,INSTRB(anc_id_14,'(]',1,3) -
        INSTRB(anc_id_14,'(]',1,2) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,3) + 2
       ,INSTRB(anc_id_14,'(]',1,4) -
        INSTRB(anc_id_14,'(]',1,3) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,4) + 2
       ,INSTRB(anc_id_14,'(]',1,5) -
        INSTRB(anc_id_14,'(]',1,4) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,5) + 2
       ,INSTRB(anc_id_14,'(]',1,6) -
        INSTRB(anc_id_14,'(]',1,5) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,6) + 2
       ,INSTRB(anc_id_14,'(]',1,7) -
        INSTRB(anc_id_14,'(]',1,6) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,7) + 2
       ,LENGTHB(anc_id_14))
)

WHEN anc_id_15 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_15
       ,1
       ,INSTRB(anc_id_15,'(]',1,1) -1)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,1) + 2
       ,INSTRB(anc_id_15,'(]',1,2) -
        INSTRB(anc_id_15,'(]',1,1) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,2) + 2
       ,INSTRB(anc_id_15,'(]',1,3) -
        INSTRB(anc_id_15,'(]',1,2) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,3) + 2
       ,INSTRB(anc_id_15,'(]',1,4) -
        INSTRB(anc_id_15,'(]',1,3) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,4) + 2
       ,INSTRB(anc_id_15,'(]',1,5) -
        INSTRB(anc_id_15,'(]',1,4) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,5) + 2
       ,INSTRB(anc_id_15,'(]',1,6) -
        INSTRB(anc_id_15,'(]',1,5) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,6) + 2
       ,INSTRB(anc_id_15,'(]',1,7) -
        INSTRB(anc_id_15,'(]',1,6) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,7) + 2
       ,LENGTHB(anc_id_15))
)

WHEN anc_id_16 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_16
       ,1
       ,INSTRB(anc_id_16,'(]',1,1) -1)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,1) + 2
       ,INSTRB(anc_id_16,'(]',1,2) -
        INSTRB(anc_id_16,'(]',1,1) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,2) + 2
       ,INSTRB(anc_id_16,'(]',1,3) -
        INSTRB(anc_id_16,'(]',1,2) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,3) + 2
       ,INSTRB(anc_id_16,'(]',1,4) -
        INSTRB(anc_id_16,'(]',1,3) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,4) + 2
       ,INSTRB(anc_id_16,'(]',1,5) -
        INSTRB(anc_id_16,'(]',1,4) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,5) + 2
       ,INSTRB(anc_id_16,'(]',1,6) -
        INSTRB(anc_id_16,'(]',1,5) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,6) + 2
       ,INSTRB(anc_id_16,'(]',1,7) -
        INSTRB(anc_id_16,'(]',1,6) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,7) + 2
       ,LENGTHB(anc_id_16))
)

WHEN anc_id_17 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_17
       ,1
       ,INSTRB(anc_id_17,'(]',1,1) -1)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,1) + 2
       ,INSTRB(anc_id_17,'(]',1,2) -
        INSTRB(anc_id_17,'(]',1,1) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,2) + 2
       ,INSTRB(anc_id_17,'(]',1,3) -
        INSTRB(anc_id_17,'(]',1,2) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,3) + 2
       ,INSTRB(anc_id_17,'(]',1,4) -
        INSTRB(anc_id_17,'(]',1,3) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,4) + 2
       ,INSTRB(anc_id_17,'(]',1,5) -
        INSTRB(anc_id_17,'(]',1,4) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,5) + 2
       ,INSTRB(anc_id_17,'(]',1,6) -
        INSTRB(anc_id_17,'(]',1,5) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,6) + 2
       ,INSTRB(anc_id_17,'(]',1,7) -
        INSTRB(anc_id_17,'(]',1,6) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,7) + 2
       ,LENGTHB(anc_id_17))
)

WHEN anc_id_18 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_18
       ,1
       ,INSTRB(anc_id_18,'(]',1,1) -1)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,1) + 2
       ,INSTRB(anc_id_18,'(]',1,2) -
        INSTRB(anc_id_18,'(]',1,1) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,2) + 2
       ,INSTRB(anc_id_18,'(]',1,3) -
        INSTRB(anc_id_18,'(]',1,2) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,3) + 2
       ,INSTRB(anc_id_18,'(]',1,4) -
        INSTRB(anc_id_18,'(]',1,3) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,4) + 2
       ,INSTRB(anc_id_18,'(]',1,5) -
        INSTRB(anc_id_18,'(]',1,4) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,5) + 2
       ,INSTRB(anc_id_18,'(]',1,6) -
        INSTRB(anc_id_18,'(]',1,5) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,6) + 2
       ,INSTRB(anc_id_18,'(]',1,7) -
        INSTRB(anc_id_18,'(]',1,6) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,7) + 2
       ,LENGTHB(anc_id_18))
)

WHEN anc_id_19 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_19
       ,1
       ,INSTRB(anc_id_19,'(]',1,1) -1)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,1) + 2
       ,INSTRB(anc_id_19,'(]',1,2) -
        INSTRB(anc_id_19,'(]',1,1) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,2) + 2
       ,INSTRB(anc_id_19,'(]',1,3) -
        INSTRB(anc_id_19,'(]',1,2) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,3) + 2
       ,INSTRB(anc_id_19,'(]',1,4) -
        INSTRB(anc_id_19,'(]',1,3) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,4) + 2
       ,INSTRB(anc_id_19,'(]',1,5) -
        INSTRB(anc_id_19,'(]',1,4) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,5) + 2
       ,INSTRB(anc_id_19,'(]',1,6) -
        INSTRB(anc_id_19,'(]',1,5) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,6) + 2
       ,INSTRB(anc_id_19,'(]',1,7) -
        INSTRB(anc_id_19,'(]',1,6) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,7) + 2
       ,LENGTHB(anc_id_19))
)

WHEN anc_id_20 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_20
       ,1
       ,INSTRB(anc_id_20,'(]',1,1) -1)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,1) + 2
       ,INSTRB(anc_id_20,'(]',1,2) -
        INSTRB(anc_id_20,'(]',1,1) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,2) + 2
       ,INSTRB(anc_id_20,'(]',1,3) -
        INSTRB(anc_id_20,'(]',1,2) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,3) + 2
       ,INSTRB(anc_id_20,'(]',1,4) -
        INSTRB(anc_id_20,'(]',1,3) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,4) + 2
       ,INSTRB(anc_id_20,'(]',1,5) -
        INSTRB(anc_id_20,'(]',1,4) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,5) + 2
       ,INSTRB(anc_id_20,'(]',1,6) -
        INSTRB(anc_id_20,'(]',1,5) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,6) + 2
       ,INSTRB(anc_id_20,'(]',1,7) -
        INSTRB(anc_id_20,'(]',1,6) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,7) + 2
       ,LENGTHB(anc_id_20))
)

WHEN anc_id_21 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_21
       ,1
       ,INSTRB(anc_id_21,'(]',1,1) -1)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,1) + 2
       ,INSTRB(anc_id_21,'(]',1,2) -
        INSTRB(anc_id_21,'(]',1,1) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,2) + 2
       ,INSTRB(anc_id_21,'(]',1,3) -
        INSTRB(anc_id_21,'(]',1,2) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,3) + 2
       ,INSTRB(anc_id_21,'(]',1,4) -
        INSTRB(anc_id_21,'(]',1,3) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,4) + 2
       ,INSTRB(anc_id_21,'(]',1,5) -
        INSTRB(anc_id_21,'(]',1,4) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,5) + 2
       ,INSTRB(anc_id_21,'(]',1,6) -
        INSTRB(anc_id_21,'(]',1,5) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,6) + 2
       ,INSTRB(anc_id_21,'(]',1,7) -
        INSTRB(anc_id_21,'(]',1,6) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,7) + 2
       ,LENGTHB(anc_id_21))
)

WHEN anc_id_22 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_22
       ,1
       ,INSTRB(anc_id_22,'(]',1,1) -1)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,1) + 2
       ,INSTRB(anc_id_22,'(]',1,2) -
        INSTRB(anc_id_22,'(]',1,1) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,2) + 2
       ,INSTRB(anc_id_22,'(]',1,3) -
        INSTRB(anc_id_22,'(]',1,2) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,3) + 2
       ,INSTRB(anc_id_22,'(]',1,4) -
        INSTRB(anc_id_22,'(]',1,3) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,4) + 2
       ,INSTRB(anc_id_22,'(]',1,5) -
        INSTRB(anc_id_22,'(]',1,4) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,5) + 2
       ,INSTRB(anc_id_22,'(]',1,6) -
        INSTRB(anc_id_22,'(]',1,5) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,6) + 2
       ,INSTRB(anc_id_22,'(]',1,7) -
        INSTRB(anc_id_22,'(]',1,6) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,7) + 2
       ,LENGTHB(anc_id_22))
)

WHEN anc_id_23 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_23
       ,1
       ,INSTRB(anc_id_23,'(]',1,1) -1)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,1) + 2
       ,INSTRB(anc_id_23,'(]',1,2) -
        INSTRB(anc_id_23,'(]',1,1) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,2) + 2
       ,INSTRB(anc_id_23,'(]',1,3) -
        INSTRB(anc_id_23,'(]',1,2) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,3) + 2
       ,INSTRB(anc_id_23,'(]',1,4) -
        INSTRB(anc_id_23,'(]',1,3) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,4) + 2
       ,INSTRB(anc_id_23,'(]',1,5) -
        INSTRB(anc_id_23,'(]',1,4) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,5) + 2
       ,INSTRB(anc_id_23,'(]',1,6) -
        INSTRB(anc_id_23,'(]',1,5) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,6) + 2
       ,INSTRB(anc_id_23,'(]',1,7) -
        INSTRB(anc_id_23,'(]',1,6) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,7) + 2
       ,LENGTHB(anc_id_23))
)

WHEN anc_id_24 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_24
       ,1
       ,INSTRB(anc_id_24,'(]',1,1) -1)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,1) + 2
       ,INSTRB(anc_id_24,'(]',1,2) -
        INSTRB(anc_id_24,'(]',1,1) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,2) + 2
       ,INSTRB(anc_id_24,'(]',1,3) -
        INSTRB(anc_id_24,'(]',1,2) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,3) + 2
       ,INSTRB(anc_id_24,'(]',1,4) -
        INSTRB(anc_id_24,'(]',1,3) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,4) + 2
       ,INSTRB(anc_id_24,'(]',1,5) -
        INSTRB(anc_id_24,'(]',1,4) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,5) + 2
       ,INSTRB(anc_id_24,'(]',1,6) -
        INSTRB(anc_id_24,'(]',1,5) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,6) + 2
       ,INSTRB(anc_id_24,'(]',1,7) -
        INSTRB(anc_id_24,'(]',1,6) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,7) + 2
       ,LENGTHB(anc_id_24))
)

WHEN anc_id_25 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_25
       ,1
       ,INSTRB(anc_id_25,'(]',1,1) -1)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,1) + 2
       ,INSTRB(anc_id_25,'(]',1,2) -
        INSTRB(anc_id_25,'(]',1,1) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,2) + 2
       ,INSTRB(anc_id_25,'(]',1,3) -
        INSTRB(anc_id_25,'(]',1,2) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,3) + 2
       ,INSTRB(anc_id_25,'(]',1,4) -
        INSTRB(anc_id_25,'(]',1,3) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,4) + 2
       ,INSTRB(anc_id_25,'(]',1,5) -
        INSTRB(anc_id_25,'(]',1,4) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,5) + 2
       ,INSTRB(anc_id_25,'(]',1,6) -
        INSTRB(anc_id_25,'(]',1,5) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,6) + 2
       ,INSTRB(anc_id_25,'(]',1,7) -
        INSTRB(anc_id_25,'(]',1,6) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,7) + 2
       ,LENGTHB(anc_id_25))
)

WHEN anc_id_26 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_26
       ,1
       ,INSTRB(anc_id_26,'(]',1,1) -1)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,1) + 2
       ,INSTRB(anc_id_26,'(]',1,2) -
        INSTRB(anc_id_26,'(]',1,1) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,2) + 2
       ,INSTRB(anc_id_26,'(]',1,3) -
        INSTRB(anc_id_26,'(]',1,2) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,3) + 2
       ,INSTRB(anc_id_26,'(]',1,4) -
        INSTRB(anc_id_26,'(]',1,3) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,4) + 2
       ,INSTRB(anc_id_26,'(]',1,5) -
        INSTRB(anc_id_26,'(]',1,4) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,5) + 2
       ,INSTRB(anc_id_26,'(]',1,6) -
        INSTRB(anc_id_26,'(]',1,5) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,6) + 2
       ,INSTRB(anc_id_26,'(]',1,7) -
        INSTRB(anc_id_26,'(]',1,6) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,7) + 2
       ,LENGTHB(anc_id_26))
)

WHEN anc_id_27 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_27
       ,1
       ,INSTRB(anc_id_27,'(]',1,1) -1)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,1) + 2
       ,INSTRB(anc_id_27,'(]',1,2) -
        INSTRB(anc_id_27,'(]',1,1) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,2) + 2
       ,INSTRB(anc_id_27,'(]',1,3) -
        INSTRB(anc_id_27,'(]',1,2) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,3) + 2
       ,INSTRB(anc_id_27,'(]',1,4) -
        INSTRB(anc_id_27,'(]',1,3) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,4) + 2
       ,INSTRB(anc_id_27,'(]',1,5) -
        INSTRB(anc_id_27,'(]',1,4) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,5) + 2
       ,INSTRB(anc_id_27,'(]',1,6) -
        INSTRB(anc_id_27,'(]',1,5) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,6) + 2
       ,INSTRB(anc_id_27,'(]',1,7) -
        INSTRB(anc_id_27,'(]',1,6) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,7) + 2
       ,LENGTHB(anc_id_27))
)

WHEN anc_id_28 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_28
       ,1
       ,INSTRB(anc_id_28,'(]',1,1) -1)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,1) + 2
       ,INSTRB(anc_id_28,'(]',1,2) -
        INSTRB(anc_id_28,'(]',1,1) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,2) + 2
       ,INSTRB(anc_id_28,'(]',1,3) -
        INSTRB(anc_id_28,'(]',1,2) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,3) + 2
       ,INSTRB(anc_id_28,'(]',1,4) -
        INSTRB(anc_id_28,'(]',1,3) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,4) + 2
       ,INSTRB(anc_id_28,'(]',1,5) -
        INSTRB(anc_id_28,'(]',1,4) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,5) + 2
       ,INSTRB(anc_id_28,'(]',1,6) -
        INSTRB(anc_id_28,'(]',1,5) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,6) + 2
       ,INSTRB(anc_id_28,'(]',1,7) -
        INSTRB(anc_id_28,'(]',1,6) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,7) + 2
       ,LENGTHB(anc_id_28))
)

WHEN anc_id_29 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_29
       ,1
       ,INSTRB(anc_id_29,'(]',1,1) -1)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,1) + 2
       ,INSTRB(anc_id_29,'(]',1,2) -
        INSTRB(anc_id_29,'(]',1,1) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,2) + 2
       ,INSTRB(anc_id_29,'(]',1,3) -
        INSTRB(anc_id_29,'(]',1,2) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,3) + 2
       ,INSTRB(anc_id_29,'(]',1,4) -
        INSTRB(anc_id_29,'(]',1,3) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,4) + 2
       ,INSTRB(anc_id_29,'(]',1,5) -
        INSTRB(anc_id_29,'(]',1,4) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,5) + 2
       ,INSTRB(anc_id_29,'(]',1,6) -
        INSTRB(anc_id_29,'(]',1,5) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,6) + 2
       ,INSTRB(anc_id_29,'(]',1,7) -
        INSTRB(anc_id_29,'(]',1,6) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,7) + 2
       ,LENGTHB(anc_id_29))
)

WHEN anc_id_30 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_30
       ,1
       ,INSTRB(anc_id_30,'(]',1,1) -1)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,1) + 2
       ,INSTRB(anc_id_30,'(]',1,2) -
        INSTRB(anc_id_30,'(]',1,1) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,2) + 2
       ,INSTRB(anc_id_30,'(]',1,3) -
        INSTRB(anc_id_30,'(]',1,2) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,3) + 2
       ,INSTRB(anc_id_30,'(]',1,4) -
        INSTRB(anc_id_30,'(]',1,3) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,4) + 2
       ,INSTRB(anc_id_30,'(]',1,5) -
        INSTRB(anc_id_30,'(]',1,4) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,5) + 2
       ,INSTRB(anc_id_30,'(]',1,6) -
        INSTRB(anc_id_30,'(]',1,5) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,6) + 2
       ,INSTRB(anc_id_30,'(]',1,7) -
        INSTRB(anc_id_30,'(]',1,6) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,7) + 2
       ,LENGTHB(anc_id_30))
)

WHEN anc_id_31 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_31
       ,1
       ,INSTRB(anc_id_31,'(]',1,1) -1)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,1) + 2
       ,INSTRB(anc_id_31,'(]',1,2) -
        INSTRB(anc_id_31,'(]',1,1) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,2) + 2
       ,INSTRB(anc_id_31,'(]',1,3) -
        INSTRB(anc_id_31,'(]',1,2) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,3) + 2
       ,INSTRB(anc_id_31,'(]',1,4) -
        INSTRB(anc_id_31,'(]',1,3) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,4) + 2
       ,INSTRB(anc_id_31,'(]',1,5) -
        INSTRB(anc_id_31,'(]',1,4) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,5) + 2
       ,INSTRB(anc_id_31,'(]',1,6) -
        INSTRB(anc_id_31,'(]',1,5) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,6) + 2
       ,INSTRB(anc_id_31,'(]',1,7) -
        INSTRB(anc_id_31,'(]',1,6) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,7) + 2
       ,LENGTHB(anc_id_31))
)

WHEN anc_id_32 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_32
       ,1
       ,INSTRB(anc_id_32,'(]',1,1) -1)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,1) + 2
       ,INSTRB(anc_id_32,'(]',1,2) -
        INSTRB(anc_id_32,'(]',1,1) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,2) + 2
       ,INSTRB(anc_id_32,'(]',1,3) -
        INSTRB(anc_id_32,'(]',1,2) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,3) + 2
       ,INSTRB(anc_id_32,'(]',1,4) -
        INSTRB(anc_id_32,'(]',1,3) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,4) + 2
       ,INSTRB(anc_id_32,'(]',1,5) -
        INSTRB(anc_id_32,'(]',1,4) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,5) + 2
       ,INSTRB(anc_id_32,'(]',1,6) -
        INSTRB(anc_id_32,'(]',1,5) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,6) + 2
       ,INSTRB(anc_id_32,'(]',1,7) -
        INSTRB(anc_id_32,'(]',1,6) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,7) + 2
       ,LENGTHB(anc_id_32))
)

WHEN anc_id_33 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_33
       ,1
       ,INSTRB(anc_id_33,'(]',1,1) -1)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,1) + 2
       ,INSTRB(anc_id_33,'(]',1,2) -
        INSTRB(anc_id_33,'(]',1,1) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,2) + 2
       ,INSTRB(anc_id_33,'(]',1,3) -
        INSTRB(anc_id_33,'(]',1,2) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,3) + 2
       ,INSTRB(anc_id_33,'(]',1,4) -
        INSTRB(anc_id_33,'(]',1,3) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,4) + 2
       ,INSTRB(anc_id_33,'(]',1,5) -
        INSTRB(anc_id_33,'(]',1,4) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,5) + 2
       ,INSTRB(anc_id_33,'(]',1,6) -
        INSTRB(anc_id_33,'(]',1,5) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,6) + 2
       ,INSTRB(anc_id_33,'(]',1,7) -
        INSTRB(anc_id_33,'(]',1,6) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,7) + 2
       ,LENGTHB(anc_id_33))
)

WHEN anc_id_34 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_34
       ,1
       ,INSTRB(anc_id_34,'(]',1,1) -1)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,1) + 2
       ,INSTRB(anc_id_34,'(]',1,2) -
        INSTRB(anc_id_34,'(]',1,1) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,2) + 2
       ,INSTRB(anc_id_34,'(]',1,3) -
        INSTRB(anc_id_34,'(]',1,2) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,3) + 2
       ,INSTRB(anc_id_34,'(]',1,4) -
        INSTRB(anc_id_34,'(]',1,3) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,4) + 2
       ,INSTRB(anc_id_34,'(]',1,5) -
        INSTRB(anc_id_34,'(]',1,4) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,5) + 2
       ,INSTRB(anc_id_34,'(]',1,6) -
        INSTRB(anc_id_34,'(]',1,5) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,6) + 2
       ,INSTRB(anc_id_34,'(]',1,7) -
        INSTRB(anc_id_34,'(]',1,6) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,7) + 2
       ,LENGTHB(anc_id_34))
)

WHEN anc_id_35 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_35
       ,1
       ,INSTRB(anc_id_35,'(]',1,1) -1)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,1) + 2
       ,INSTRB(anc_id_35,'(]',1,2) -
        INSTRB(anc_id_35,'(]',1,1) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,2) + 2
       ,INSTRB(anc_id_35,'(]',1,3) -
        INSTRB(anc_id_35,'(]',1,2) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,3) + 2
       ,INSTRB(anc_id_35,'(]',1,4) -
        INSTRB(anc_id_35,'(]',1,3) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,4) + 2
       ,INSTRB(anc_id_35,'(]',1,5) -
        INSTRB(anc_id_35,'(]',1,4) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,5) + 2
       ,INSTRB(anc_id_35,'(]',1,6) -
        INSTRB(anc_id_35,'(]',1,5) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,6) + 2
       ,INSTRB(anc_id_35,'(]',1,7) -
        INSTRB(anc_id_35,'(]',1,6) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,7) + 2
       ,LENGTHB(anc_id_35))
)

WHEN anc_id_36 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_36
       ,1
       ,INSTRB(anc_id_36,'(]',1,1) -1)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,1) + 2
       ,INSTRB(anc_id_36,'(]',1,2) -
        INSTRB(anc_id_36,'(]',1,1) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,2) + 2
       ,INSTRB(anc_id_36,'(]',1,3) -
        INSTRB(anc_id_36,'(]',1,2) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,3) + 2
       ,INSTRB(anc_id_36,'(]',1,4) -
        INSTRB(anc_id_36,'(]',1,3) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,4) + 2
       ,INSTRB(anc_id_36,'(]',1,5) -
        INSTRB(anc_id_36,'(]',1,4) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,5) + 2
       ,INSTRB(anc_id_36,'(]',1,6) -
        INSTRB(anc_id_36,'(]',1,5) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,6) + 2
       ,INSTRB(anc_id_36,'(]',1,7) -
        INSTRB(anc_id_36,'(]',1,6) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,7) + 2
       ,LENGTHB(anc_id_36))
)

WHEN anc_id_37 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_37
       ,1
       ,INSTRB(anc_id_37,'(]',1,1) -1)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,1) + 2
       ,INSTRB(anc_id_37,'(]',1,2) -
        INSTRB(anc_id_37,'(]',1,1) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,2) + 2
       ,INSTRB(anc_id_37,'(]',1,3) -
        INSTRB(anc_id_37,'(]',1,2) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,3) + 2
       ,INSTRB(anc_id_37,'(]',1,4) -
        INSTRB(anc_id_37,'(]',1,3) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,4) + 2
       ,INSTRB(anc_id_37,'(]',1,5) -
        INSTRB(anc_id_37,'(]',1,4) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,5) + 2
       ,INSTRB(anc_id_37,'(]',1,6) -
        INSTRB(anc_id_37,'(]',1,5) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,6) + 2
       ,INSTRB(anc_id_37,'(]',1,7) -
        INSTRB(anc_id_37,'(]',1,6) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,7) + 2
       ,LENGTHB(anc_id_37))
)

WHEN anc_id_38 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_38
       ,1
       ,INSTRB(anc_id_38,'(]',1,1) -1)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,1) + 2
       ,INSTRB(anc_id_38,'(]',1,2) -
        INSTRB(anc_id_38,'(]',1,1) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,2) + 2
       ,INSTRB(anc_id_38,'(]',1,3) -
        INSTRB(anc_id_38,'(]',1,2) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,3) + 2
       ,INSTRB(anc_id_38,'(]',1,4) -
        INSTRB(anc_id_38,'(]',1,3) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,4) + 2
       ,INSTRB(anc_id_38,'(]',1,5) -
        INSTRB(anc_id_38,'(]',1,4) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,5) + 2
       ,INSTRB(anc_id_38,'(]',1,6) -
        INSTRB(anc_id_38,'(]',1,5) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,6) + 2
       ,INSTRB(anc_id_38,'(]',1,7) -
        INSTRB(anc_id_38,'(]',1,6) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,7) + 2
       ,LENGTHB(anc_id_38))
)

WHEN anc_id_39 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_39
       ,1
       ,INSTRB(anc_id_39,'(]',1,1) -1)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,1) + 2
       ,INSTRB(anc_id_39,'(]',1,2) -
        INSTRB(anc_id_39,'(]',1,1) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,2) + 2
       ,INSTRB(anc_id_39,'(]',1,3) -
        INSTRB(anc_id_39,'(]',1,2) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,3) + 2
       ,INSTRB(anc_id_39,'(]',1,4) -
        INSTRB(anc_id_39,'(]',1,3) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,4) + 2
       ,INSTRB(anc_id_39,'(]',1,5) -
        INSTRB(anc_id_39,'(]',1,4) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,5) + 2
       ,INSTRB(anc_id_39,'(]',1,6) -
        INSTRB(anc_id_39,'(]',1,5) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,6) + 2
       ,INSTRB(anc_id_39,'(]',1,7) -
        INSTRB(anc_id_39,'(]',1,6) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,7) + 2
       ,LENGTHB(anc_id_39))
)

WHEN anc_id_40 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_40
       ,1
       ,INSTRB(anc_id_40,'(]',1,1) -1)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,1) + 2
       ,INSTRB(anc_id_40,'(]',1,2) -
        INSTRB(anc_id_40,'(]',1,1) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,2) + 2
       ,INSTRB(anc_id_40,'(]',1,3) -
        INSTRB(anc_id_40,'(]',1,2) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,3) + 2
       ,INSTRB(anc_id_40,'(]',1,4) -
        INSTRB(anc_id_40,'(]',1,3) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,4) + 2
       ,INSTRB(anc_id_40,'(]',1,5) -
        INSTRB(anc_id_40,'(]',1,4) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,5) + 2
       ,INSTRB(anc_id_40,'(]',1,6) -
        INSTRB(anc_id_40,'(]',1,5) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,6) + 2
       ,INSTRB(anc_id_40,'(]',1,7) -
        INSTRB(anc_id_40,'(]',1,6) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,7) + 2
       ,LENGTHB(anc_id_40))
)

WHEN anc_id_41 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_41
       ,1
       ,INSTRB(anc_id_41,'(]',1,1) -1)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,1) + 2
       ,INSTRB(anc_id_41,'(]',1,2) -
        INSTRB(anc_id_41,'(]',1,1) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,2) + 2
       ,INSTRB(anc_id_41,'(]',1,3) -
        INSTRB(anc_id_41,'(]',1,2) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,3) + 2
       ,INSTRB(anc_id_41,'(]',1,4) -
        INSTRB(anc_id_41,'(]',1,3) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,4) + 2
       ,INSTRB(anc_id_41,'(]',1,5) -
        INSTRB(anc_id_41,'(]',1,4) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,5) + 2
       ,INSTRB(anc_id_41,'(]',1,6) -
        INSTRB(anc_id_41,'(]',1,5) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,6) + 2
       ,INSTRB(anc_id_41,'(]',1,7) -
        INSTRB(anc_id_41,'(]',1,6) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,7) + 2
       ,LENGTHB(anc_id_41))
)

WHEN anc_id_42 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_42
       ,1
       ,INSTRB(anc_id_42,'(]',1,1) -1)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,1) + 2
       ,INSTRB(anc_id_42,'(]',1,2) -
        INSTRB(anc_id_42,'(]',1,1) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,2) + 2
       ,INSTRB(anc_id_42,'(]',1,3) -
        INSTRB(anc_id_42,'(]',1,2) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,3) + 2
       ,INSTRB(anc_id_42,'(]',1,4) -
        INSTRB(anc_id_42,'(]',1,3) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,4) + 2
       ,INSTRB(anc_id_42,'(]',1,5) -
        INSTRB(anc_id_42,'(]',1,4) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,5) + 2
       ,INSTRB(anc_id_42,'(]',1,6) -
        INSTRB(anc_id_42,'(]',1,5) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,6) + 2
       ,INSTRB(anc_id_42,'(]',1,7) -
        INSTRB(anc_id_42,'(]',1,6) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,7) + 2
       ,LENGTHB(anc_id_42))
)

WHEN anc_id_43 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_43
       ,1
       ,INSTRB(anc_id_43,'(]',1,1) -1)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,1) + 2
       ,INSTRB(anc_id_43,'(]',1,2) -
        INSTRB(anc_id_43,'(]',1,1) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,2) + 2
       ,INSTRB(anc_id_43,'(]',1,3) -
        INSTRB(anc_id_43,'(]',1,2) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,3) + 2
       ,INSTRB(anc_id_43,'(]',1,4) -
        INSTRB(anc_id_43,'(]',1,3) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,4) + 2
       ,INSTRB(anc_id_43,'(]',1,5) -
        INSTRB(anc_id_43,'(]',1,4) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,5) + 2
       ,INSTRB(anc_id_43,'(]',1,6) -
        INSTRB(anc_id_43,'(]',1,5) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,6) + 2
       ,INSTRB(anc_id_43,'(]',1,7) -
        INSTRB(anc_id_43,'(]',1,6) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,7) + 2
       ,LENGTHB(anc_id_43))
)

WHEN anc_id_44 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_44
       ,1
       ,INSTRB(anc_id_44,'(]',1,1) -1)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,1) + 2
       ,INSTRB(anc_id_44,'(]',1,2) -
        INSTRB(anc_id_44,'(]',1,1) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,2) + 2
       ,INSTRB(anc_id_44,'(]',1,3) -
        INSTRB(anc_id_44,'(]',1,2) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,3) + 2
       ,INSTRB(anc_id_44,'(]',1,4) -
        INSTRB(anc_id_44,'(]',1,3) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,4) + 2
       ,INSTRB(anc_id_44,'(]',1,5) -
        INSTRB(anc_id_44,'(]',1,4) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,5) + 2
       ,INSTRB(anc_id_44,'(]',1,6) -
        INSTRB(anc_id_44,'(]',1,5) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,6) + 2
       ,INSTRB(anc_id_44,'(]',1,7) -
        INSTRB(anc_id_44,'(]',1,6) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,7) + 2
       ,LENGTHB(anc_id_44))
)

WHEN anc_id_45 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_45
       ,1
       ,INSTRB(anc_id_45,'(]',1,1) -1)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,1) + 2
       ,INSTRB(anc_id_45,'(]',1,2) -
        INSTRB(anc_id_45,'(]',1,1) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,2) + 2
       ,INSTRB(anc_id_45,'(]',1,3) -
        INSTRB(anc_id_45,'(]',1,2) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,3) + 2
       ,INSTRB(anc_id_45,'(]',1,4) -
        INSTRB(anc_id_45,'(]',1,3) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,4) + 2
       ,INSTRB(anc_id_45,'(]',1,5) -
        INSTRB(anc_id_45,'(]',1,4) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,5) + 2
       ,INSTRB(anc_id_45,'(]',1,6) -
        INSTRB(anc_id_45,'(]',1,5) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,6) + 2
       ,INSTRB(anc_id_45,'(]',1,7) -
        INSTRB(anc_id_45,'(]',1,6) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,7) + 2
       ,LENGTHB(anc_id_45))
)

WHEN anc_id_46 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_46
       ,1
       ,INSTRB(anc_id_46,'(]',1,1) -1)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,1) + 2
       ,INSTRB(anc_id_46,'(]',1,2) -
        INSTRB(anc_id_46,'(]',1,1) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,2) + 2
       ,INSTRB(anc_id_46,'(]',1,3) -
        INSTRB(anc_id_46,'(]',1,2) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,3) + 2
       ,INSTRB(anc_id_46,'(]',1,4) -
        INSTRB(anc_id_46,'(]',1,3) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,4) + 2
       ,INSTRB(anc_id_46,'(]',1,5) -
        INSTRB(anc_id_46,'(]',1,4) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,5) + 2
       ,INSTRB(anc_id_46,'(]',1,6) -
        INSTRB(anc_id_46,'(]',1,5) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,6) + 2
       ,INSTRB(anc_id_46,'(]',1,7) -
        INSTRB(anc_id_46,'(]',1,6) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,7) + 2
       ,LENGTHB(anc_id_46))
)

WHEN anc_id_47 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_47
       ,1
       ,INSTRB(anc_id_47,'(]',1,1) -1)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,1) + 2
       ,INSTRB(anc_id_47,'(]',1,2) -
        INSTRB(anc_id_47,'(]',1,1) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,2) + 2
       ,INSTRB(anc_id_47,'(]',1,3) -
        INSTRB(anc_id_47,'(]',1,2) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,3) + 2
       ,INSTRB(anc_id_47,'(]',1,4) -
        INSTRB(anc_id_47,'(]',1,3) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,4) + 2
       ,INSTRB(anc_id_47,'(]',1,5) -
        INSTRB(anc_id_47,'(]',1,4) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,5) + 2
       ,INSTRB(anc_id_47,'(]',1,6) -
        INSTRB(anc_id_47,'(]',1,5) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,6) + 2
       ,INSTRB(anc_id_47,'(]',1,7) -
        INSTRB(anc_id_47,'(]',1,6) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,7) + 2
       ,LENGTHB(anc_id_47))
)

WHEN anc_id_48 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_48
       ,1
       ,INSTRB(anc_id_48,'(]',1,1) -1)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,1) + 2
       ,INSTRB(anc_id_48,'(]',1,2) -
        INSTRB(anc_id_48,'(]',1,1) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,2) + 2
       ,INSTRB(anc_id_48,'(]',1,3) -
        INSTRB(anc_id_48,'(]',1,2) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,3) + 2
       ,INSTRB(anc_id_48,'(]',1,4) -
        INSTRB(anc_id_48,'(]',1,3) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,4) + 2
       ,INSTRB(anc_id_48,'(]',1,5) -
        INSTRB(anc_id_48,'(]',1,4) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,5) + 2
       ,INSTRB(anc_id_48,'(]',1,6) -
        INSTRB(anc_id_48,'(]',1,5) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,6) + 2
       ,INSTRB(anc_id_48,'(]',1,7) -
        INSTRB(anc_id_48,'(]',1,6) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,7) + 2
       ,LENGTHB(anc_id_48))
)

WHEN anc_id_49 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_49
       ,1
       ,INSTRB(anc_id_49,'(]',1,1) -1)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,1) + 2
       ,INSTRB(anc_id_49,'(]',1,2) -
        INSTRB(anc_id_49,'(]',1,1) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,2) + 2
       ,INSTRB(anc_id_49,'(]',1,3) -
        INSTRB(anc_id_49,'(]',1,2) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,3) + 2
       ,INSTRB(anc_id_49,'(]',1,4) -
        INSTRB(anc_id_49,'(]',1,3) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,4) + 2
       ,INSTRB(anc_id_49,'(]',1,5) -
        INSTRB(anc_id_49,'(]',1,4) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,5) + 2
       ,INSTRB(anc_id_49,'(]',1,6) -
        INSTRB(anc_id_49,'(]',1,5) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,6) + 2
       ,INSTRB(anc_id_49,'(]',1,7) -
        INSTRB(anc_id_49,'(]',1,6) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,7) + 2
       ,LENGTHB(anc_id_49))
)

WHEN anc_id_50 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_50
       ,1
       ,INSTRB(anc_id_50,'(]',1,1) -1)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,1) + 2
       ,INSTRB(anc_id_50,'(]',1,2) -
        INSTRB(anc_id_50,'(]',1,1) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,2) + 2
       ,INSTRB(anc_id_50,'(]',1,3) -
        INSTRB(anc_id_50,'(]',1,2) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,3) + 2
       ,INSTRB(anc_id_50,'(]',1,4) -
        INSTRB(anc_id_50,'(]',1,3) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,4) + 2
       ,INSTRB(anc_id_50,'(]',1,5) -
        INSTRB(anc_id_50,'(]',1,4) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,5) + 2
       ,INSTRB(anc_id_50,'(]',1,6) -
        INSTRB(anc_id_50,'(]',1,5) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,6) + 2
       ,INSTRB(anc_id_50,'(]',1,7) -
        INSTRB(anc_id_50,'(]',1,6) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,7) + 2
       ,LENGTHB(anc_id_50))
)

WHEN anc_id_51 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_51
       ,1
       ,INSTRB(anc_id_51,'(]',1,1) -1)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,1) + 2
       ,INSTRB(anc_id_51,'(]',1,2) -
        INSTRB(anc_id_51,'(]',1,1) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,2) + 2
       ,INSTRB(anc_id_51,'(]',1,3) -
        INSTRB(anc_id_51,'(]',1,2) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,3) + 2
       ,INSTRB(anc_id_51,'(]',1,4) -
        INSTRB(anc_id_51,'(]',1,3) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,4) + 2
       ,INSTRB(anc_id_51,'(]',1,5) -
        INSTRB(anc_id_51,'(]',1,4) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,5) + 2
       ,INSTRB(anc_id_51,'(]',1,6) -
        INSTRB(anc_id_51,'(]',1,5) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,6) + 2
       ,INSTRB(anc_id_51,'(]',1,7) -
        INSTRB(anc_id_51,'(]',1,6) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,7) + 2
       ,LENGTHB(anc_id_51))
)

WHEN anc_id_52 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_52
       ,1
       ,INSTRB(anc_id_52,'(]',1,1) -1)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,1) + 2
       ,INSTRB(anc_id_52,'(]',1,2) -
        INSTRB(anc_id_52,'(]',1,1) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,2) + 2
       ,INSTRB(anc_id_52,'(]',1,3) -
        INSTRB(anc_id_52,'(]',1,2) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,3) + 2
       ,INSTRB(anc_id_52,'(]',1,4) -
        INSTRB(anc_id_52,'(]',1,3) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,4) + 2
       ,INSTRB(anc_id_52,'(]',1,5) -
        INSTRB(anc_id_52,'(]',1,4) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,5) + 2
       ,INSTRB(anc_id_52,'(]',1,6) -
        INSTRB(anc_id_52,'(]',1,5) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,6) + 2
       ,INSTRB(anc_id_52,'(]',1,7) -
        INSTRB(anc_id_52,'(]',1,6) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,7) + 2
       ,LENGTHB(anc_id_52))
)

WHEN anc_id_53 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_53
       ,1
       ,INSTRB(anc_id_53,'(]',1,1) -1)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,1) + 2
       ,INSTRB(anc_id_53,'(]',1,2) -
        INSTRB(anc_id_53,'(]',1,1) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,2) + 2
       ,INSTRB(anc_id_53,'(]',1,3) -
        INSTRB(anc_id_53,'(]',1,2) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,3) + 2
       ,INSTRB(anc_id_53,'(]',1,4) -
        INSTRB(anc_id_53,'(]',1,3) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,4) + 2
       ,INSTRB(anc_id_53,'(]',1,5) -
        INSTRB(anc_id_53,'(]',1,4) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,5) + 2
       ,INSTRB(anc_id_53,'(]',1,6) -
        INSTRB(anc_id_53,'(]',1,5) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,6) + 2
       ,INSTRB(anc_id_53,'(]',1,7) -
        INSTRB(anc_id_53,'(]',1,6) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,7) + 2
       ,LENGTHB(anc_id_53))
)

WHEN anc_id_54 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_54
       ,1
       ,INSTRB(anc_id_54,'(]',1,1) -1)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,1) + 2
       ,INSTRB(anc_id_54,'(]',1,2) -
        INSTRB(anc_id_54,'(]',1,1) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,2) + 2
       ,INSTRB(anc_id_54,'(]',1,3) -
        INSTRB(anc_id_54,'(]',1,2) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,3) + 2
       ,INSTRB(anc_id_54,'(]',1,4) -
        INSTRB(anc_id_54,'(]',1,3) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,4) + 2
       ,INSTRB(anc_id_54,'(]',1,5) -
        INSTRB(anc_id_54,'(]',1,4) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,5) + 2
       ,INSTRB(anc_id_54,'(]',1,6) -
        INSTRB(anc_id_54,'(]',1,5) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,6) + 2
       ,INSTRB(anc_id_54,'(]',1,7) -
        INSTRB(anc_id_54,'(]',1,6) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,7) + 2
       ,LENGTHB(anc_id_54))
)

WHEN anc_id_55 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_55
       ,1
       ,INSTRB(anc_id_55,'(]',1,1) -1)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,1) + 2
       ,INSTRB(anc_id_55,'(]',1,2) -
        INSTRB(anc_id_55,'(]',1,1) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,2) + 2
       ,INSTRB(anc_id_55,'(]',1,3) -
        INSTRB(anc_id_55,'(]',1,2) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,3) + 2
       ,INSTRB(anc_id_55,'(]',1,4) -
        INSTRB(anc_id_55,'(]',1,3) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,4) + 2
       ,INSTRB(anc_id_55,'(]',1,5) -
        INSTRB(anc_id_55,'(]',1,4) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,5) + 2
       ,INSTRB(anc_id_55,'(]',1,6) -
        INSTRB(anc_id_55,'(]',1,5) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,6) + 2
       ,INSTRB(anc_id_55,'(]',1,7) -
        INSTRB(anc_id_55,'(]',1,6) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,7) + 2
       ,LENGTHB(anc_id_55))
)

WHEN anc_id_56 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_56
       ,1
       ,INSTRB(anc_id_56,'(]',1,1) -1)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,1) + 2
       ,INSTRB(anc_id_56,'(]',1,2) -
        INSTRB(anc_id_56,'(]',1,1) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,2) + 2
       ,INSTRB(anc_id_56,'(]',1,3) -
        INSTRB(anc_id_56,'(]',1,2) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,3) + 2
       ,INSTRB(anc_id_56,'(]',1,4) -
        INSTRB(anc_id_56,'(]',1,3) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,4) + 2
       ,INSTRB(anc_id_56,'(]',1,5) -
        INSTRB(anc_id_56,'(]',1,4) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,5) + 2
       ,INSTRB(anc_id_56,'(]',1,6) -
        INSTRB(anc_id_56,'(]',1,5) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,6) + 2
       ,INSTRB(anc_id_56,'(]',1,7) -
        INSTRB(anc_id_56,'(]',1,6) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,7) + 2
       ,LENGTHB(anc_id_56))
)

WHEN anc_id_57 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_57
       ,1
       ,INSTRB(anc_id_57,'(]',1,1) -1)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,1) + 2
       ,INSTRB(anc_id_57,'(]',1,2) -
        INSTRB(anc_id_57,'(]',1,1) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,2) + 2
       ,INSTRB(anc_id_57,'(]',1,3) -
        INSTRB(anc_id_57,'(]',1,2) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,3) + 2
       ,INSTRB(anc_id_57,'(]',1,4) -
        INSTRB(anc_id_57,'(]',1,3) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,4) + 2
       ,INSTRB(anc_id_57,'(]',1,5) -
        INSTRB(anc_id_57,'(]',1,4) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,5) + 2
       ,INSTRB(anc_id_57,'(]',1,6) -
        INSTRB(anc_id_57,'(]',1,5) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,6) + 2
       ,INSTRB(anc_id_57,'(]',1,7) -
        INSTRB(anc_id_57,'(]',1,6) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,7) + 2
       ,LENGTHB(anc_id_57))
)

WHEN anc_id_58 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_58
       ,1
       ,INSTRB(anc_id_58,'(]',1,1) -1)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,1) + 2
       ,INSTRB(anc_id_58,'(]',1,2) -
        INSTRB(anc_id_58,'(]',1,1) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,2) + 2
       ,INSTRB(anc_id_58,'(]',1,3) -
        INSTRB(anc_id_58,'(]',1,2) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,3) + 2
       ,INSTRB(anc_id_58,'(]',1,4) -
        INSTRB(anc_id_58,'(]',1,3) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,4) + 2
       ,INSTRB(anc_id_58,'(]',1,5) -
        INSTRB(anc_id_58,'(]',1,4) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,5) + 2
       ,INSTRB(anc_id_58,'(]',1,6) -
        INSTRB(anc_id_58,'(]',1,5) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,6) + 2
       ,INSTRB(anc_id_58,'(]',1,7) -
        INSTRB(anc_id_58,'(]',1,6) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,7) + 2
       ,LENGTHB(anc_id_58))
)

WHEN anc_id_59 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_59
       ,1
       ,INSTRB(anc_id_59,'(]',1,1) -1)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,1) + 2
       ,INSTRB(anc_id_59,'(]',1,2) -
        INSTRB(anc_id_59,'(]',1,1) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,2) + 2
       ,INSTRB(anc_id_59,'(]',1,3) -
        INSTRB(anc_id_59,'(]',1,2) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,3) + 2
       ,INSTRB(anc_id_59,'(]',1,4) -
        INSTRB(anc_id_59,'(]',1,3) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,4) + 2
       ,INSTRB(anc_id_59,'(]',1,5) -
        INSTRB(anc_id_59,'(]',1,4) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,5) + 2
       ,INSTRB(anc_id_59,'(]',1,6) -
        INSTRB(anc_id_59,'(]',1,5) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,6) + 2
       ,INSTRB(anc_id_59,'(]',1,7) -
        INSTRB(anc_id_59,'(]',1,6) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,7) + 2
       ,LENGTHB(anc_id_59))
)

WHEN anc_id_60 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_60
       ,1
       ,INSTRB(anc_id_60,'(]',1,1) -1)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,1) + 2
       ,INSTRB(anc_id_60,'(]',1,2) -
        INSTRB(anc_id_60,'(]',1,1) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,2) + 2
       ,INSTRB(anc_id_60,'(]',1,3) -
        INSTRB(anc_id_60,'(]',1,2) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,3) + 2
       ,INSTRB(anc_id_60,'(]',1,4) -
        INSTRB(anc_id_60,'(]',1,3) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,4) + 2
       ,INSTRB(anc_id_60,'(]',1,5) -
        INSTRB(anc_id_60,'(]',1,4) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,5) + 2
       ,INSTRB(anc_id_60,'(]',1,6) -
        INSTRB(anc_id_60,'(]',1,5) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,6) + 2
       ,INSTRB(anc_id_60,'(]',1,7) -
        INSTRB(anc_id_60,'(]',1,6) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,7) + 2
       ,LENGTHB(anc_id_60))
)

WHEN anc_id_61 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_61
       ,1
       ,INSTRB(anc_id_61,'(]',1,1) -1)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,1) + 2
       ,INSTRB(anc_id_61,'(]',1,2) -
        INSTRB(anc_id_61,'(]',1,1) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,2) + 2
       ,INSTRB(anc_id_61,'(]',1,3) -
        INSTRB(anc_id_61,'(]',1,2) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,3) + 2
       ,INSTRB(anc_id_61,'(]',1,4) -
        INSTRB(anc_id_61,'(]',1,3) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,4) + 2
       ,INSTRB(anc_id_61,'(]',1,5) -
        INSTRB(anc_id_61,'(]',1,4) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,5) + 2
       ,INSTRB(anc_id_61,'(]',1,6) -
        INSTRB(anc_id_61,'(]',1,5) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,6) + 2
       ,INSTRB(anc_id_61,'(]',1,7) -
        INSTRB(anc_id_61,'(]',1,6) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,7) + 2
       ,LENGTHB(anc_id_61))
)

WHEN anc_id_62 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_62
       ,1
       ,INSTRB(anc_id_62,'(]',1,1) -1)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,1) + 2
       ,INSTRB(anc_id_62,'(]',1,2) -
        INSTRB(anc_id_62,'(]',1,1) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,2) + 2
       ,INSTRB(anc_id_62,'(]',1,3) -
        INSTRB(anc_id_62,'(]',1,2) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,3) + 2
       ,INSTRB(anc_id_62,'(]',1,4) -
        INSTRB(anc_id_62,'(]',1,3) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,4) + 2
       ,INSTRB(anc_id_62,'(]',1,5) -
        INSTRB(anc_id_62,'(]',1,4) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,5) + 2
       ,INSTRB(anc_id_62,'(]',1,6) -
        INSTRB(anc_id_62,'(]',1,5) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,6) + 2
       ,INSTRB(anc_id_62,'(]',1,7) -
        INSTRB(anc_id_62,'(]',1,6) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,7) + 2
       ,LENGTHB(anc_id_62))
)

WHEN anc_id_63 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_63
       ,1
       ,INSTRB(anc_id_63,'(]',1,1) -1)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,1) + 2
       ,INSTRB(anc_id_63,'(]',1,2) -
        INSTRB(anc_id_63,'(]',1,1) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,2) + 2
       ,INSTRB(anc_id_63,'(]',1,3) -
        INSTRB(anc_id_63,'(]',1,2) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,3) + 2
       ,INSTRB(anc_id_63,'(]',1,4) -
        INSTRB(anc_id_63,'(]',1,3) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,4) + 2
       ,INSTRB(anc_id_63,'(]',1,5) -
        INSTRB(anc_id_63,'(]',1,4) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,5) + 2
       ,INSTRB(anc_id_63,'(]',1,6) -
        INSTRB(anc_id_63,'(]',1,5) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,6) + 2
       ,INSTRB(anc_id_63,'(]',1,7) -
        INSTRB(anc_id_63,'(]',1,6) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,7) + 2
       ,LENGTHB(anc_id_63))
)

WHEN anc_id_64 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_64
       ,1
       ,INSTRB(anc_id_64,'(]',1,1) -1)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,1) + 2
       ,INSTRB(anc_id_64,'(]',1,2) -
        INSTRB(anc_id_64,'(]',1,1) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,2) + 2
       ,INSTRB(anc_id_64,'(]',1,3) -
        INSTRB(anc_id_64,'(]',1,2) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,3) + 2
       ,INSTRB(anc_id_64,'(]',1,4) -
        INSTRB(anc_id_64,'(]',1,3) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,4) + 2
       ,INSTRB(anc_id_64,'(]',1,5) -
        INSTRB(anc_id_64,'(]',1,4) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,5) + 2
       ,INSTRB(anc_id_64,'(]',1,6) -
        INSTRB(anc_id_64,'(]',1,5) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,6) + 2
       ,INSTRB(anc_id_64,'(]',1,7) -
        INSTRB(anc_id_64,'(]',1,6) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,7) + 2
       ,LENGTHB(anc_id_64))
)

WHEN anc_id_65 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_65
       ,1
       ,INSTRB(anc_id_65,'(]',1,1) -1)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,1) + 2
       ,INSTRB(anc_id_65,'(]',1,2) -
        INSTRB(anc_id_65,'(]',1,1) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,2) + 2
       ,INSTRB(anc_id_65,'(]',1,3) -
        INSTRB(anc_id_65,'(]',1,2) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,3) + 2
       ,INSTRB(anc_id_65,'(]',1,4) -
        INSTRB(anc_id_65,'(]',1,3) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,4) + 2
       ,INSTRB(anc_id_65,'(]',1,5) -
        INSTRB(anc_id_65,'(]',1,4) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,5) + 2
       ,INSTRB(anc_id_65,'(]',1,6) -
        INSTRB(anc_id_65,'(]',1,5) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,6) + 2
       ,INSTRB(anc_id_65,'(]',1,7) -
        INSTRB(anc_id_65,'(]',1,6) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,7) + 2
       ,LENGTHB(anc_id_65))
)

WHEN anc_id_66 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_66
       ,1
       ,INSTRB(anc_id_66,'(]',1,1) -1)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,1) + 2
       ,INSTRB(anc_id_66,'(]',1,2) -
        INSTRB(anc_id_66,'(]',1,1) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,2) + 2
       ,INSTRB(anc_id_66,'(]',1,3) -
        INSTRB(anc_id_66,'(]',1,2) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,3) + 2
       ,INSTRB(anc_id_66,'(]',1,4) -
        INSTRB(anc_id_66,'(]',1,3) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,4) + 2
       ,INSTRB(anc_id_66,'(]',1,5) -
        INSTRB(anc_id_66,'(]',1,4) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,5) + 2
       ,INSTRB(anc_id_66,'(]',1,6) -
        INSTRB(anc_id_66,'(]',1,5) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,6) + 2
       ,INSTRB(anc_id_66,'(]',1,7) -
        INSTRB(anc_id_66,'(]',1,6) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,7) + 2
       ,LENGTHB(anc_id_66))
)

WHEN anc_id_67 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_67
       ,1
       ,INSTRB(anc_id_67,'(]',1,1) -1)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,1) + 2
       ,INSTRB(anc_id_67,'(]',1,2) -
        INSTRB(anc_id_67,'(]',1,1) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,2) + 2
       ,INSTRB(anc_id_67,'(]',1,3) -
        INSTRB(anc_id_67,'(]',1,2) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,3) + 2
       ,INSTRB(anc_id_67,'(]',1,4) -
        INSTRB(anc_id_67,'(]',1,3) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,4) + 2
       ,INSTRB(anc_id_67,'(]',1,5) -
        INSTRB(anc_id_67,'(]',1,4) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,5) + 2
       ,INSTRB(anc_id_67,'(]',1,6) -
        INSTRB(anc_id_67,'(]',1,5) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,6) + 2
       ,INSTRB(anc_id_67,'(]',1,7) -
        INSTRB(anc_id_67,'(]',1,6) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,7) + 2
       ,LENGTHB(anc_id_67))
)

WHEN anc_id_68 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_68
       ,1
       ,INSTRB(anc_id_68,'(]',1,1) -1)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,1) + 2
       ,INSTRB(anc_id_68,'(]',1,2) -
        INSTRB(anc_id_68,'(]',1,1) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,2) + 2
       ,INSTRB(anc_id_68,'(]',1,3) -
        INSTRB(anc_id_68,'(]',1,2) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,3) + 2
       ,INSTRB(anc_id_68,'(]',1,4) -
        INSTRB(anc_id_68,'(]',1,3) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,4) + 2
       ,INSTRB(anc_id_68,'(]',1,5) -
        INSTRB(anc_id_68,'(]',1,4) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,5) + 2
       ,INSTRB(anc_id_68,'(]',1,6) -
        INSTRB(anc_id_68,'(]',1,5) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,6) + 2
       ,INSTRB(anc_id_68,'(]',1,7) -
        INSTRB(anc_id_68,'(]',1,6) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,7) + 2
       ,LENGTHB(anc_id_68))
)

WHEN anc_id_69 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_69
       ,1
       ,INSTRB(anc_id_69,'(]',1,1) -1)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,1) + 2
       ,INSTRB(anc_id_69,'(]',1,2) -
        INSTRB(anc_id_69,'(]',1,1) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,2) + 2
       ,INSTRB(anc_id_69,'(]',1,3) -
        INSTRB(anc_id_69,'(]',1,2) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,3) + 2
       ,INSTRB(anc_id_69,'(]',1,4) -
        INSTRB(anc_id_69,'(]',1,3) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,4) + 2
       ,INSTRB(anc_id_69,'(]',1,5) -
        INSTRB(anc_id_69,'(]',1,4) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,5) + 2
       ,INSTRB(anc_id_69,'(]',1,6) -
        INSTRB(anc_id_69,'(]',1,5) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,6) + 2
       ,INSTRB(anc_id_69,'(]',1,7) -
        INSTRB(anc_id_69,'(]',1,6) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,7) + 2
       ,LENGTHB(anc_id_69))
)

WHEN anc_id_70 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_70
       ,1
       ,INSTRB(anc_id_70,'(]',1,1) -1)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,1) + 2
       ,INSTRB(anc_id_70,'(]',1,2) -
        INSTRB(anc_id_70,'(]',1,1) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,2) + 2
       ,INSTRB(anc_id_70,'(]',1,3) -
        INSTRB(anc_id_70,'(]',1,2) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,3) + 2
       ,INSTRB(anc_id_70,'(]',1,4) -
        INSTRB(anc_id_70,'(]',1,3) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,4) + 2
       ,INSTRB(anc_id_70,'(]',1,5) -
        INSTRB(anc_id_70,'(]',1,4) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,5) + 2
       ,INSTRB(anc_id_70,'(]',1,6) -
        INSTRB(anc_id_70,'(]',1,5) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,6) + 2
       ,INSTRB(anc_id_70,'(]',1,7) -
        INSTRB(anc_id_70,'(]',1,6) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,7) + 2
       ,LENGTHB(anc_id_70))
)

WHEN anc_id_71 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_71
       ,1
       ,INSTRB(anc_id_71,'(]',1,1) -1)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,1) + 2
       ,INSTRB(anc_id_71,'(]',1,2) -
        INSTRB(anc_id_71,'(]',1,1) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,2) + 2
       ,INSTRB(anc_id_71,'(]',1,3) -
        INSTRB(anc_id_71,'(]',1,2) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,3) + 2
       ,INSTRB(anc_id_71,'(]',1,4) -
        INSTRB(anc_id_71,'(]',1,3) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,4) + 2
       ,INSTRB(anc_id_71,'(]',1,5) -
        INSTRB(anc_id_71,'(]',1,4) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,5) + 2
       ,INSTRB(anc_id_71,'(]',1,6) -
        INSTRB(anc_id_71,'(]',1,5) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,6) + 2
       ,INSTRB(anc_id_71,'(]',1,7) -
        INSTRB(anc_id_71,'(]',1,6) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,7) + 2
       ,LENGTHB(anc_id_71))
)

WHEN anc_id_72 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_72
       ,1
       ,INSTRB(anc_id_72,'(]',1,1) -1)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,1) + 2
       ,INSTRB(anc_id_72,'(]',1,2) -
        INSTRB(anc_id_72,'(]',1,1) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,2) + 2
       ,INSTRB(anc_id_72,'(]',1,3) -
        INSTRB(anc_id_72,'(]',1,2) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,3) + 2
       ,INSTRB(anc_id_72,'(]',1,4) -
        INSTRB(anc_id_72,'(]',1,3) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,4) + 2
       ,INSTRB(anc_id_72,'(]',1,5) -
        INSTRB(anc_id_72,'(]',1,4) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,5) + 2
       ,INSTRB(anc_id_72,'(]',1,6) -
        INSTRB(anc_id_72,'(]',1,5) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,6) + 2
       ,INSTRB(anc_id_72,'(]',1,7) -
        INSTRB(anc_id_72,'(]',1,6) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,7) + 2
       ,LENGTHB(anc_id_72))
)

WHEN anc_id_73 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_73
       ,1
       ,INSTRB(anc_id_73,'(]',1,1) -1)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,1) + 2
       ,INSTRB(anc_id_73,'(]',1,2) -
        INSTRB(anc_id_73,'(]',1,1) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,2) + 2
       ,INSTRB(anc_id_73,'(]',1,3) -
        INSTRB(anc_id_73,'(]',1,2) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,3) + 2
       ,INSTRB(anc_id_73,'(]',1,4) -
        INSTRB(anc_id_73,'(]',1,3) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,4) + 2
       ,INSTRB(anc_id_73,'(]',1,5) -
        INSTRB(anc_id_73,'(]',1,4) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,5) + 2
       ,INSTRB(anc_id_73,'(]',1,6) -
        INSTRB(anc_id_73,'(]',1,5) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,6) + 2
       ,INSTRB(anc_id_73,'(]',1,7) -
        INSTRB(anc_id_73,'(]',1,6) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,7) + 2
       ,LENGTHB(anc_id_73))
)

WHEN anc_id_74 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_74
       ,1
       ,INSTRB(anc_id_74,'(]',1,1) -1)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,1) + 2
       ,INSTRB(anc_id_74,'(]',1,2) -
        INSTRB(anc_id_74,'(]',1,1) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,2) + 2
       ,INSTRB(anc_id_74,'(]',1,3) -
        INSTRB(anc_id_74,'(]',1,2) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,3) + 2
       ,INSTRB(anc_id_74,'(]',1,4) -
        INSTRB(anc_id_74,'(]',1,3) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,4) + 2
       ,INSTRB(anc_id_74,'(]',1,5) -
        INSTRB(anc_id_74,'(]',1,4) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,5) + 2
       ,INSTRB(anc_id_74,'(]',1,6) -
        INSTRB(anc_id_74,'(]',1,5) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,6) + 2
       ,INSTRB(anc_id_74,'(]',1,7) -
        INSTRB(anc_id_74,'(]',1,6) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,7) + 2
       ,LENGTHB(anc_id_74))
)

WHEN anc_id_75 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_75
       ,1
       ,INSTRB(anc_id_75,'(]',1,1) -1)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,1) + 2
       ,INSTRB(anc_id_75,'(]',1,2) -
        INSTRB(anc_id_75,'(]',1,1) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,2) + 2
       ,INSTRB(anc_id_75,'(]',1,3) -
        INSTRB(anc_id_75,'(]',1,2) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,3) + 2
       ,INSTRB(anc_id_75,'(]',1,4) -
        INSTRB(anc_id_75,'(]',1,3) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,4) + 2
       ,INSTRB(anc_id_75,'(]',1,5) -
        INSTRB(anc_id_75,'(]',1,4) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,5) + 2
       ,INSTRB(anc_id_75,'(]',1,6) -
        INSTRB(anc_id_75,'(]',1,5) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,6) + 2
       ,INSTRB(anc_id_75,'(]',1,7) -
        INSTRB(anc_id_75,'(]',1,6) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,7) + 2
       ,LENGTHB(anc_id_75))
)

WHEN anc_id_76 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_76
       ,1
       ,INSTRB(anc_id_76,'(]',1,1) -1)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,1) + 2
       ,INSTRB(anc_id_76,'(]',1,2) -
        INSTRB(anc_id_76,'(]',1,1) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,2) + 2
       ,INSTRB(anc_id_76,'(]',1,3) -
        INSTRB(anc_id_76,'(]',1,2) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,3) + 2
       ,INSTRB(anc_id_76,'(]',1,4) -
        INSTRB(anc_id_76,'(]',1,3) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,4) + 2
       ,INSTRB(anc_id_76,'(]',1,5) -
        INSTRB(anc_id_76,'(]',1,4) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,5) + 2
       ,INSTRB(anc_id_76,'(]',1,6) -
        INSTRB(anc_id_76,'(]',1,5) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,6) + 2
       ,INSTRB(anc_id_76,'(]',1,7) -
        INSTRB(anc_id_76,'(]',1,6) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,7) + 2
       ,LENGTHB(anc_id_76))
)

WHEN anc_id_77 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_77
       ,1
       ,INSTRB(anc_id_77,'(]',1,1) -1)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,1) + 2
       ,INSTRB(anc_id_77,'(]',1,2) -
        INSTRB(anc_id_77,'(]',1,1) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,2) + 2
       ,INSTRB(anc_id_77,'(]',1,3) -
        INSTRB(anc_id_77,'(]',1,2) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,3) + 2
       ,INSTRB(anc_id_77,'(]',1,4) -
        INSTRB(anc_id_77,'(]',1,3) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,4) + 2
       ,INSTRB(anc_id_77,'(]',1,5) -
        INSTRB(anc_id_77,'(]',1,4) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,5) + 2
       ,INSTRB(anc_id_77,'(]',1,6) -
        INSTRB(anc_id_77,'(]',1,5) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,6) + 2
       ,INSTRB(anc_id_77,'(]',1,7) -
        INSTRB(anc_id_77,'(]',1,6) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,7) + 2
       ,LENGTHB(anc_id_77))
)

WHEN anc_id_78 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_78
       ,1
       ,INSTRB(anc_id_78,'(]',1,1) -1)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,1) + 2
       ,INSTRB(anc_id_78,'(]',1,2) -
        INSTRB(anc_id_78,'(]',1,1) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,2) + 2
       ,INSTRB(anc_id_78,'(]',1,3) -
        INSTRB(anc_id_78,'(]',1,2) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,3) + 2
       ,INSTRB(anc_id_78,'(]',1,4) -
        INSTRB(anc_id_78,'(]',1,3) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,4) + 2
       ,INSTRB(anc_id_78,'(]',1,5) -
        INSTRB(anc_id_78,'(]',1,4) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,5) + 2
       ,INSTRB(anc_id_78,'(]',1,6) -
        INSTRB(anc_id_78,'(]',1,5) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,6) + 2
       ,INSTRB(anc_id_78,'(]',1,7) -
        INSTRB(anc_id_78,'(]',1,6) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,7) + 2
       ,LENGTHB(anc_id_78))
)

WHEN anc_id_79 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_79
       ,1
       ,INSTRB(anc_id_79,'(]',1,1) -1)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,1) + 2
       ,INSTRB(anc_id_79,'(]',1,2) -
        INSTRB(anc_id_79,'(]',1,1) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,2) + 2
       ,INSTRB(anc_id_79,'(]',1,3) -
        INSTRB(anc_id_79,'(]',1,2) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,3) + 2
       ,INSTRB(anc_id_79,'(]',1,4) -
        INSTRB(anc_id_79,'(]',1,3) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,4) + 2
       ,INSTRB(anc_id_79,'(]',1,5) -
        INSTRB(anc_id_79,'(]',1,4) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,5) + 2
       ,INSTRB(anc_id_79,'(]',1,6) -
        INSTRB(anc_id_79,'(]',1,5) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,6) + 2
       ,INSTRB(anc_id_79,'(]',1,7) -
        INSTRB(anc_id_79,'(]',1,6) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,7) + 2
       ,LENGTHB(anc_id_79))
)

WHEN anc_id_80 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_80
       ,1
       ,INSTRB(anc_id_80,'(]',1,1) -1)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,1) + 2
       ,INSTRB(anc_id_80,'(]',1,2) -
        INSTRB(anc_id_80,'(]',1,1) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,2) + 2
       ,INSTRB(anc_id_80,'(]',1,3) -
        INSTRB(anc_id_80,'(]',1,2) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,3) + 2
       ,INSTRB(anc_id_80,'(]',1,4) -
        INSTRB(anc_id_80,'(]',1,3) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,4) + 2
       ,INSTRB(anc_id_80,'(]',1,5) -
        INSTRB(anc_id_80,'(]',1,4) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,5) + 2
       ,INSTRB(anc_id_80,'(]',1,6) -
        INSTRB(anc_id_80,'(]',1,5) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,6) + 2
       ,INSTRB(anc_id_80,'(]',1,7) -
        INSTRB(anc_id_80,'(]',1,6) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,7) + 2
       ,LENGTHB(anc_id_80))
)

WHEN anc_id_81 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_81
       ,1
       ,INSTRB(anc_id_81,'(]',1,1) -1)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,1) + 2
       ,INSTRB(anc_id_81,'(]',1,2) -
        INSTRB(anc_id_81,'(]',1,1) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,2) + 2
       ,INSTRB(anc_id_81,'(]',1,3) -
        INSTRB(anc_id_81,'(]',1,2) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,3) + 2
       ,INSTRB(anc_id_81,'(]',1,4) -
        INSTRB(anc_id_81,'(]',1,3) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,4) + 2
       ,INSTRB(anc_id_81,'(]',1,5) -
        INSTRB(anc_id_81,'(]',1,4) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,5) + 2
       ,INSTRB(anc_id_81,'(]',1,6) -
        INSTRB(anc_id_81,'(]',1,5) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,6) + 2
       ,INSTRB(anc_id_81,'(]',1,7) -
        INSTRB(anc_id_81,'(]',1,6) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,7) + 2
       ,LENGTHB(anc_id_81))
)

WHEN anc_id_82 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_82
       ,1
       ,INSTRB(anc_id_82,'(]',1,1) -1)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,1) + 2
       ,INSTRB(anc_id_82,'(]',1,2) -
        INSTRB(anc_id_82,'(]',1,1) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,2) + 2
       ,INSTRB(anc_id_82,'(]',1,3) -
        INSTRB(anc_id_82,'(]',1,2) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,3) + 2
       ,INSTRB(anc_id_82,'(]',1,4) -
        INSTRB(anc_id_82,'(]',1,3) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,4) + 2
       ,INSTRB(anc_id_82,'(]',1,5) -
        INSTRB(anc_id_82,'(]',1,4) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,5) + 2
       ,INSTRB(anc_id_82,'(]',1,6) -
        INSTRB(anc_id_82,'(]',1,5) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,6) + 2
       ,INSTRB(anc_id_82,'(]',1,7) -
        INSTRB(anc_id_82,'(]',1,6) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,7) + 2
       ,LENGTHB(anc_id_82))
)

WHEN anc_id_83 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_83
       ,1
       ,INSTRB(anc_id_83,'(]',1,1) -1)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,1) + 2
       ,INSTRB(anc_id_83,'(]',1,2) -
        INSTRB(anc_id_83,'(]',1,1) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,2) + 2
       ,INSTRB(anc_id_83,'(]',1,3) -
        INSTRB(anc_id_83,'(]',1,2) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,3) + 2
       ,INSTRB(anc_id_83,'(]',1,4) -
        INSTRB(anc_id_83,'(]',1,3) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,4) + 2
       ,INSTRB(anc_id_83,'(]',1,5) -
        INSTRB(anc_id_83,'(]',1,4) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,5) + 2
       ,INSTRB(anc_id_83,'(]',1,6) -
        INSTRB(anc_id_83,'(]',1,5) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,6) + 2
       ,INSTRB(anc_id_83,'(]',1,7) -
        INSTRB(anc_id_83,'(]',1,6) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,7) + 2
       ,LENGTHB(anc_id_83))
)

WHEN anc_id_84 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_84
       ,1
       ,INSTRB(anc_id_84,'(]',1,1) -1)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,1) + 2
       ,INSTRB(anc_id_84,'(]',1,2) -
        INSTRB(anc_id_84,'(]',1,1) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,2) + 2
       ,INSTRB(anc_id_84,'(]',1,3) -
        INSTRB(anc_id_84,'(]',1,2) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,3) + 2
       ,INSTRB(anc_id_84,'(]',1,4) -
        INSTRB(anc_id_84,'(]',1,3) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,4) + 2
       ,INSTRB(anc_id_84,'(]',1,5) -
        INSTRB(anc_id_84,'(]',1,4) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,5) + 2
       ,INSTRB(anc_id_84,'(]',1,6) -
        INSTRB(anc_id_84,'(]',1,5) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,6) + 2
       ,INSTRB(anc_id_84,'(]',1,7) -
        INSTRB(anc_id_84,'(]',1,6) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,7) + 2
       ,LENGTHB(anc_id_84))
)

WHEN anc_id_85 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_85
       ,1
       ,INSTRB(anc_id_85,'(]',1,1) -1)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,1) + 2
       ,INSTRB(anc_id_85,'(]',1,2) -
        INSTRB(anc_id_85,'(]',1,1) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,2) + 2
       ,INSTRB(anc_id_85,'(]',1,3) -
        INSTRB(anc_id_85,'(]',1,2) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,3) + 2
       ,INSTRB(anc_id_85,'(]',1,4) -
        INSTRB(anc_id_85,'(]',1,3) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,4) + 2
       ,INSTRB(anc_id_85,'(]',1,5) -
        INSTRB(anc_id_85,'(]',1,4) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,5) + 2
       ,INSTRB(anc_id_85,'(]',1,6) -
        INSTRB(anc_id_85,'(]',1,5) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,6) + 2
       ,INSTRB(anc_id_85,'(]',1,7) -
        INSTRB(anc_id_85,'(]',1,6) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,7) + 2
       ,LENGTHB(anc_id_85))
)

WHEN anc_id_86 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_86
       ,1
       ,INSTRB(anc_id_86,'(]',1,1) -1)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,1) + 2
       ,INSTRB(anc_id_86,'(]',1,2) -
        INSTRB(anc_id_86,'(]',1,1) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,2) + 2
       ,INSTRB(anc_id_86,'(]',1,3) -
        INSTRB(anc_id_86,'(]',1,2) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,3) + 2
       ,INSTRB(anc_id_86,'(]',1,4) -
        INSTRB(anc_id_86,'(]',1,3) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,4) + 2
       ,INSTRB(anc_id_86,'(]',1,5) -
        INSTRB(anc_id_86,'(]',1,4) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,5) + 2
       ,INSTRB(anc_id_86,'(]',1,6) -
        INSTRB(anc_id_86,'(]',1,5) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,6) + 2
       ,INSTRB(anc_id_86,'(]',1,7) -
        INSTRB(anc_id_86,'(]',1,6) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,7) + 2
       ,LENGTHB(anc_id_86))
)

WHEN anc_id_87 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_87
       ,1
       ,INSTRB(anc_id_87,'(]',1,1) -1)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,1) + 2
       ,INSTRB(anc_id_87,'(]',1,2) -
        INSTRB(anc_id_87,'(]',1,1) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,2) + 2
       ,INSTRB(anc_id_87,'(]',1,3) -
        INSTRB(anc_id_87,'(]',1,2) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,3) + 2
       ,INSTRB(anc_id_87,'(]',1,4) -
        INSTRB(anc_id_87,'(]',1,3) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,4) + 2
       ,INSTRB(anc_id_87,'(]',1,5) -
        INSTRB(anc_id_87,'(]',1,4) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,5) + 2
       ,INSTRB(anc_id_87,'(]',1,6) -
        INSTRB(anc_id_87,'(]',1,5) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,6) + 2
       ,INSTRB(anc_id_87,'(]',1,7) -
        INSTRB(anc_id_87,'(]',1,6) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,7) + 2
       ,LENGTHB(anc_id_87))
)

WHEN anc_id_88 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_88
       ,1
       ,INSTRB(anc_id_88,'(]',1,1) -1)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,1) + 2
       ,INSTRB(anc_id_88,'(]',1,2) -
        INSTRB(anc_id_88,'(]',1,1) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,2) + 2
       ,INSTRB(anc_id_88,'(]',1,3) -
        INSTRB(anc_id_88,'(]',1,2) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,3) + 2
       ,INSTRB(anc_id_88,'(]',1,4) -
        INSTRB(anc_id_88,'(]',1,3) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,4) + 2
       ,INSTRB(anc_id_88,'(]',1,5) -
        INSTRB(anc_id_88,'(]',1,4) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,5) + 2
       ,INSTRB(anc_id_88,'(]',1,6) -
        INSTRB(anc_id_88,'(]',1,5) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,6) + 2
       ,INSTRB(anc_id_88,'(]',1,7) -
        INSTRB(anc_id_88,'(]',1,6) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,7) + 2
       ,LENGTHB(anc_id_88))
)

WHEN anc_id_89 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_89
       ,1
       ,INSTRB(anc_id_89,'(]',1,1) -1)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,1) + 2
       ,INSTRB(anc_id_89,'(]',1,2) -
        INSTRB(anc_id_89,'(]',1,1) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,2) + 2
       ,INSTRB(anc_id_89,'(]',1,3) -
        INSTRB(anc_id_89,'(]',1,2) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,3) + 2
       ,INSTRB(anc_id_89,'(]',1,4) -
        INSTRB(anc_id_89,'(]',1,3) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,4) + 2
       ,INSTRB(anc_id_89,'(]',1,5) -
        INSTRB(anc_id_89,'(]',1,4) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,5) + 2
       ,INSTRB(anc_id_89,'(]',1,6) -
        INSTRB(anc_id_89,'(]',1,5) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,6) + 2
       ,INSTRB(anc_id_89,'(]',1,7) -
        INSTRB(anc_id_89,'(]',1,6) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,7) + 2
       ,LENGTHB(anc_id_89))
)

WHEN anc_id_90 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_90
       ,1
       ,INSTRB(anc_id_90,'(]',1,1) -1)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,1) + 2
       ,INSTRB(anc_id_90,'(]',1,2) -
        INSTRB(anc_id_90,'(]',1,1) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,2) + 2
       ,INSTRB(anc_id_90,'(]',1,3) -
        INSTRB(anc_id_90,'(]',1,2) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,3) + 2
       ,INSTRB(anc_id_90,'(]',1,4) -
        INSTRB(anc_id_90,'(]',1,3) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,4) + 2
       ,INSTRB(anc_id_90,'(]',1,5) -
        INSTRB(anc_id_90,'(]',1,4) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,5) + 2
       ,INSTRB(anc_id_90,'(]',1,6) -
        INSTRB(anc_id_90,'(]',1,5) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,6) + 2
       ,INSTRB(anc_id_90,'(]',1,7) -
        INSTRB(anc_id_90,'(]',1,6) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,7) + 2
       ,LENGTHB(anc_id_90))
)

WHEN anc_id_91 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_91
       ,1
       ,INSTRB(anc_id_91,'(]',1,1) -1)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,1) + 2
       ,INSTRB(anc_id_91,'(]',1,2) -
        INSTRB(anc_id_91,'(]',1,1) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,2) + 2
       ,INSTRB(anc_id_91,'(]',1,3) -
        INSTRB(anc_id_91,'(]',1,2) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,3) + 2
       ,INSTRB(anc_id_91,'(]',1,4) -
        INSTRB(anc_id_91,'(]',1,3) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,4) + 2
       ,INSTRB(anc_id_91,'(]',1,5) -
        INSTRB(anc_id_91,'(]',1,4) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,5) + 2
       ,INSTRB(anc_id_91,'(]',1,6) -
        INSTRB(anc_id_91,'(]',1,5) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,6) + 2
       ,INSTRB(anc_id_91,'(]',1,7) -
        INSTRB(anc_id_91,'(]',1,6) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,7) + 2
       ,LENGTHB(anc_id_91))
)

WHEN anc_id_92 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_92
       ,1
       ,INSTRB(anc_id_92,'(]',1,1) -1)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,1) + 2
       ,INSTRB(anc_id_92,'(]',1,2) -
        INSTRB(anc_id_92,'(]',1,1) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,2) + 2
       ,INSTRB(anc_id_92,'(]',1,3) -
        INSTRB(anc_id_92,'(]',1,2) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,3) + 2
       ,INSTRB(anc_id_92,'(]',1,4) -
        INSTRB(anc_id_92,'(]',1,3) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,4) + 2
       ,INSTRB(anc_id_92,'(]',1,5) -
        INSTRB(anc_id_92,'(]',1,4) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,5) + 2
       ,INSTRB(anc_id_92,'(]',1,6) -
        INSTRB(anc_id_92,'(]',1,5) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,6) + 2
       ,INSTRB(anc_id_92,'(]',1,7) -
        INSTRB(anc_id_92,'(]',1,6) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,7) + 2
       ,LENGTHB(anc_id_92))
)

WHEN anc_id_93 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_93
       ,1
       ,INSTRB(anc_id_93,'(]',1,1) -1)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,1) + 2
       ,INSTRB(anc_id_93,'(]',1,2) -
        INSTRB(anc_id_93,'(]',1,1) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,2) + 2
       ,INSTRB(anc_id_93,'(]',1,3) -
        INSTRB(anc_id_93,'(]',1,2) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,3) + 2
       ,INSTRB(anc_id_93,'(]',1,4) -
        INSTRB(anc_id_93,'(]',1,3) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,4) + 2
       ,INSTRB(anc_id_93,'(]',1,5) -
        INSTRB(anc_id_93,'(]',1,4) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,5) + 2
       ,INSTRB(anc_id_93,'(]',1,6) -
        INSTRB(anc_id_93,'(]',1,5) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,6) + 2
       ,INSTRB(anc_id_93,'(]',1,7) -
        INSTRB(anc_id_93,'(]',1,6) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,7) + 2
       ,LENGTHB(anc_id_93))
)

WHEN anc_id_94 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_94
       ,1
       ,INSTRB(anc_id_94,'(]',1,1) -1)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,1) + 2
       ,INSTRB(anc_id_94,'(]',1,2) -
        INSTRB(anc_id_94,'(]',1,1) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,2) + 2
       ,INSTRB(anc_id_94,'(]',1,3) -
        INSTRB(anc_id_94,'(]',1,2) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,3) + 2
       ,INSTRB(anc_id_94,'(]',1,4) -
        INSTRB(anc_id_94,'(]',1,3) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,4) + 2
       ,INSTRB(anc_id_94,'(]',1,5) -
        INSTRB(anc_id_94,'(]',1,4) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,5) + 2
       ,INSTRB(anc_id_94,'(]',1,6) -
        INSTRB(anc_id_94,'(]',1,5) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,6) + 2
       ,INSTRB(anc_id_94,'(]',1,7) -
        INSTRB(anc_id_94,'(]',1,6) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,7) + 2
       ,LENGTHB(anc_id_94))
)

WHEN anc_id_95 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_95
       ,1
       ,INSTRB(anc_id_95,'(]',1,1) -1)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,1) + 2
       ,INSTRB(anc_id_95,'(]',1,2) -
        INSTRB(anc_id_95,'(]',1,1) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,2) + 2
       ,INSTRB(anc_id_95,'(]',1,3) -
        INSTRB(anc_id_95,'(]',1,2) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,3) + 2
       ,INSTRB(anc_id_95,'(]',1,4) -
        INSTRB(anc_id_95,'(]',1,3) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,4) + 2
       ,INSTRB(anc_id_95,'(]',1,5) -
        INSTRB(anc_id_95,'(]',1,4) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,5) + 2
       ,INSTRB(anc_id_95,'(]',1,6) -
        INSTRB(anc_id_95,'(]',1,5) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,6) + 2
       ,INSTRB(anc_id_95,'(]',1,7) -
        INSTRB(anc_id_95,'(]',1,6) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,7) + 2
       ,LENGTHB(anc_id_95))
)

WHEN anc_id_96 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_96
       ,1
       ,INSTRB(anc_id_96,'(]',1,1) -1)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,1) + 2
       ,INSTRB(anc_id_96,'(]',1,2) -
        INSTRB(anc_id_96,'(]',1,1) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,2) + 2
       ,INSTRB(anc_id_96,'(]',1,3) -
        INSTRB(anc_id_96,'(]',1,2) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,3) + 2
       ,INSTRB(anc_id_96,'(]',1,4) -
        INSTRB(anc_id_96,'(]',1,3) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,4) + 2
       ,INSTRB(anc_id_96,'(]',1,5) -
        INSTRB(anc_id_96,'(]',1,4) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,5) + 2
       ,INSTRB(anc_id_96,'(]',1,6) -
        INSTRB(anc_id_96,'(]',1,5) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,6) + 2
       ,INSTRB(anc_id_96,'(]',1,7) -
        INSTRB(anc_id_96,'(]',1,6) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,7) + 2
       ,LENGTHB(anc_id_96))
)

WHEN anc_id_97 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_97
       ,1
       ,INSTRB(anc_id_97,'(]',1,1) -1)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,1) + 2
       ,INSTRB(anc_id_97,'(]',1,2) -
        INSTRB(anc_id_97,'(]',1,1) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,2) + 2
       ,INSTRB(anc_id_97,'(]',1,3) -
        INSTRB(anc_id_97,'(]',1,2) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,3) + 2
       ,INSTRB(anc_id_97,'(]',1,4) -
        INSTRB(anc_id_97,'(]',1,3) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,4) + 2
       ,INSTRB(anc_id_97,'(]',1,5) -
        INSTRB(anc_id_97,'(]',1,4) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,5) + 2
       ,INSTRB(anc_id_97,'(]',1,6) -
        INSTRB(anc_id_97,'(]',1,5) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,6) + 2
       ,INSTRB(anc_id_97,'(]',1,7) -
        INSTRB(anc_id_97,'(]',1,6) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,7) + 2
       ,LENGTHB(anc_id_97))
)

WHEN anc_id_98 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_98
       ,1
       ,INSTRB(anc_id_98,'(]',1,1) -1)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,1) + 2
       ,INSTRB(anc_id_98,'(]',1,2) -
        INSTRB(anc_id_98,'(]',1,1) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,2) + 2
       ,INSTRB(anc_id_98,'(]',1,3) -
        INSTRB(anc_id_98,'(]',1,2) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,3) + 2
       ,INSTRB(anc_id_98,'(]',1,4) -
        INSTRB(anc_id_98,'(]',1,3) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,4) + 2
       ,INSTRB(anc_id_98,'(]',1,5) -
        INSTRB(anc_id_98,'(]',1,4) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,5) + 2
       ,INSTRB(anc_id_98,'(]',1,6) -
        INSTRB(anc_id_98,'(]',1,5) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,6) + 2
       ,INSTRB(anc_id_98,'(]',1,7) -
        INSTRB(anc_id_98,'(]',1,6) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,7) + 2
       ,LENGTHB(anc_id_98))
)

WHEN anc_id_99 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_99
       ,1
       ,INSTRB(anc_id_99,'(]',1,1) -1)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,1) + 2
       ,INSTRB(anc_id_99,'(]',1,2) -
        INSTRB(anc_id_99,'(]',1,1) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,2) + 2
       ,INSTRB(anc_id_99,'(]',1,3) -
        INSTRB(anc_id_99,'(]',1,2) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,3) + 2
       ,INSTRB(anc_id_99,'(]',1,4) -
        INSTRB(anc_id_99,'(]',1,3) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,4) + 2
       ,INSTRB(anc_id_99,'(]',1,5) -
        INSTRB(anc_id_99,'(]',1,4) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,5) + 2
       ,INSTRB(anc_id_99,'(]',1,6) -
        INSTRB(anc_id_99,'(]',1,5) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,6) + 2
       ,INSTRB(anc_id_99,'(]',1,7) -
        INSTRB(anc_id_99,'(]',1,6) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,7) + 2
       ,LENGTHB(anc_id_99))
)

WHEN anc_id_100 IS NOT NULL THEN
  INTO xla_ae_line_acs (
        ae_header_id , ae_line_num , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, ae_line_num, C_OVN
,SUBSTRB(anc_id_100
       ,1
       ,INSTRB(anc_id_100,'(]',1,1) -1)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,1) + 2
       ,INSTRB(anc_id_100,'(]',1,2) -
        INSTRB(anc_id_100,'(]',1,1) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,2) + 2
       ,INSTRB(anc_id_100,'(]',1,3) -
        INSTRB(anc_id_100,'(]',1,2) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,3) + 2
       ,INSTRB(anc_id_100,'(]',1,4) -
        INSTRB(anc_id_100,'(]',1,3) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,4) + 2
       ,INSTRB(anc_id_100,'(]',1,5) -
        INSTRB(anc_id_100,'(]',1,4) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,5) + 2
       ,INSTRB(anc_id_100,'(]',1,6) -
        INSTRB(anc_id_100,'(]',1,5) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,6) + 2
       ,INSTRB(anc_id_100,'(]',1,7) -
        INSTRB(anc_id_100,'(]',1,6) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,7) + 2
       ,LENGTHB(anc_id_100))
)


SELECT  ae_header_id
      , ae_line_num
      , anc_id_1
      , anc_id_2
      , anc_id_3
      , anc_id_4
      , anc_id_5
      , anc_id_6
      , anc_id_7
      , anc_id_8
      , anc_id_9
      , anc_id_10
      , anc_id_11
      , anc_id_12
      , anc_id_13
      , anc_id_14
      , anc_id_15
      , anc_id_16
      , anc_id_17
      , anc_id_18
      , anc_id_19
      , anc_id_20
      , anc_id_21
      , anc_id_22
      , anc_id_23
      , anc_id_24
      , anc_id_25
      , anc_id_26
      , anc_id_27
      , anc_id_28
      , anc_id_29
      , anc_id_30
      , anc_id_31
      , anc_id_32
      , anc_id_33
      , anc_id_34
      , anc_id_35
      , anc_id_36
      , anc_id_37
      , anc_id_38
      , anc_id_39
      , anc_id_40
      , anc_id_41
      , anc_id_42
      , anc_id_43
      , anc_id_44
      , anc_id_45
      , anc_id_46
      , anc_id_47
      , anc_id_48
      , anc_id_49
      , anc_id_50
      , anc_id_51
      , anc_id_52
      , anc_id_53
      , anc_id_54
      , anc_id_55
      , anc_id_56
      , anc_id_57
      , anc_id_58
      , anc_id_59
      , anc_id_60
      , anc_id_61
      , anc_id_62
      , anc_id_63
      , anc_id_64
      , anc_id_65
      , anc_id_66
      , anc_id_67
      , anc_id_68
      , anc_id_69
      , anc_id_70
      , anc_id_71
      , anc_id_72
      , anc_id_73
      , anc_id_74
      , anc_id_75
      , anc_id_76
      , anc_id_77
      , anc_id_78
      , anc_id_79
      , anc_id_80
      , anc_id_81
      , anc_id_82
      , anc_id_83
      , anc_id_84
      , anc_id_85
      , anc_id_86
      , anc_id_87
      , anc_id_88
      , anc_id_89
      , anc_id_90
      , anc_id_91
      , anc_id_92
      , anc_id_93
      , anc_id_94
      , anc_id_95
      , anc_id_96
      , anc_id_97
      , anc_id_98
      , anc_id_99
      , anc_id_100
 FROM  xla_ae_lines_gt
WHERE  ae_line_num is not null
GROUP  BY
       ae_line_num
      ,ae_header_id
      ,anc_id_1
      ,anc_id_2
      ,anc_id_3
      ,anc_id_4
      ,anc_id_5
      ,anc_id_6
      ,anc_id_7
      ,anc_id_8
      ,anc_id_9
      ,anc_id_10
      ,anc_id_11
      ,anc_id_12
      ,anc_id_13
      ,anc_id_14
      ,anc_id_15
      ,anc_id_16
      ,anc_id_17
      ,anc_id_18
      ,anc_id_19
      ,anc_id_20
      ,anc_id_21
      ,anc_id_22
      ,anc_id_23
      ,anc_id_24
      ,anc_id_25
      ,anc_id_26
      ,anc_id_27
      ,anc_id_28
      ,anc_id_29
      ,anc_id_30
      ,anc_id_31
      ,anc_id_32
      ,anc_id_33
      ,anc_id_34
      ,anc_id_35
      ,anc_id_36
      ,anc_id_37
      ,anc_id_38
      ,anc_id_39
      ,anc_id_40
      ,anc_id_41
      ,anc_id_42
      ,anc_id_43
      ,anc_id_44
      ,anc_id_45
      ,anc_id_46
      ,anc_id_47
      ,anc_id_48
      ,anc_id_49
      ,anc_id_50
      ,anc_id_51
      ,anc_id_52
      ,anc_id_53
      ,anc_id_54
      ,anc_id_55
      ,anc_id_56
      ,anc_id_57
      ,anc_id_58
      ,anc_id_59
      ,anc_id_60
      ,anc_id_61
      ,anc_id_62
      ,anc_id_63
      ,anc_id_64
      ,anc_id_65
      ,anc_id_66
      ,anc_id_67
      ,anc_id_68
      ,anc_id_69
      ,anc_id_70
      ,anc_id_71
      ,anc_id_72
      ,anc_id_73
      ,anc_id_74
      ,anc_id_75
      ,anc_id_76
      ,anc_id_77
      ,anc_id_78
      ,anc_id_79
      ,anc_id_80
      ,anc_id_81
      ,anc_id_82
      ,anc_id_83
      ,anc_id_84
      ,anc_id_85
      ,anc_id_86
      ,anc_id_87
      ,anc_id_88
      ,anc_id_89
      ,anc_id_90
      ,anc_id_91
      ,anc_id_92
      ,anc_id_93
      ,anc_id_94
      ,anc_id_95
      ,anc_id_96
      ,anc_id_97
      ,anc_id_98
      ,anc_id_99
      ,anc_id_100;

   --
   l_rowcount := SQL%ROWCOUNT;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# line analytical criteria inserted into xla_ae_line_acs = '||l_rowcount
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

   EXCEPTION
   WHEN OTHERS  THEN

     IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
          trace
              (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
              ,p_level    => C_LEVEL_EXCEPTION
              ,p_module   => l_log_module);
     END IF;

     xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                      ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                      ,p_token_1      => 'ERROR'
                                      ,p_value_1      => sqlerrm
                                      );


   END;

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
       (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertAnalyticalCriteria100');
END InsertAnalyticalCriteria100;
--
/*======================================================================+
|                                                                       |
| 4669308  - Adjust Final MPA Line                                      |
|                                                                       |
| This is to back calculate the rounded amounts on the final period of  |
| MPA reversal lines.  It should only be necessary if all recogniton    |
| periods are reversed.                                                 |
|                                                                       |
+======================================================================*/
--
PROCEDURE AdjustMpaLine(p_application_id  IN INTEGER)
IS
l_log_module         VARCHAR2(240);
l_count number;

CURSOR cur_mpa_lines IS
SELECT parent_header_id
      ,parent_ae_line_num
      ,MIN(ae_header_id)
      ,MAX(ae_header_id)
FROM   xla_ae_headers_gt
WHERE  parent_header_id IS NOT NULL
AND    parent_ae_line_num  IS NOT NULL
AND    balance_type_code = 'A' -- added for bug:7377888
AND    NVL(accrual_reversal_flag,'N') = 'N'
GROUP BY parent_header_id, parent_ae_line_num
HAVING COUNT(*) > 1;

l_array_parent_hdr_idx      t_array_Num;
l_array_parent_line_idx     t_array_Num;
l_array_min_hdr_idx         t_array_Num;
l_array_max_hdr_idx         t_array_Num;

l_array_entered_amt         t_array_Num;
l_array_accted_amt          t_array_Num;
l_array_unround_entered_amt t_array_Num;
l_array_unround_accted_amt  t_array_Num;

l_array_mpa_header_idx      t_array_Num;  -- 5017009
l_array_mpa_line_idx        t_array_Num;  -- 5017009

BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AdjustMpaLine';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AdjustMpaLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

   ------------------------------------------------------------
   -- Find the MPA lines
   ------------------------------------------------------------
   OPEN  cur_mpa_lines;
   FETCH cur_mpa_lines BULK COLLECT INTO l_array_parent_hdr_idx,l_array_parent_line_idx,l_array_min_hdr_idx,l_array_max_hdr_idx;
   CLOSE cur_mpa_lines;


   ------------------------------------------------------------
   -- Find the original amounts
   ------------------------------------------------------------
   FOR i IN 1..l_array_parent_hdr_idx.COUNT LOOP
     /* Excluding the join with XLA_DISTRIBUTION_LINKS bug:7230462 */
    -- SELECT NVL(l.entered_cr, l.entered_dr)
    --        ,NVL(l.accounted_cr, l.accounted_dr)
    --        ,NVL(l.unrounded_entered_cr, l.unrounded_entered_dr)
    --        ,NVL(l.unrounded_accounted_cr, l.unrounded_accounted_dr)
    --  INTO   l_array_entered_amt(i)
    --        ,l_array_accted_amt(i)
    --        ,l_array_unround_entered_amt(i)
    --        ,l_array_unround_accted_amt(i)
    --  FROM   xla_ae_lines l,
    --         xla_distribution_links d                     -- added for bug 7377888
    --  /*WHERE  ae_header_id   = l_array_parent_hdr_idx(i)
    --  AND    ae_line_num    = l_array_parent_line_idx(i)
    --  AND    application_id = p_application_id;*/         -- commented for bug 7377888
    --  WHERE  l.ae_header_id   = d.ae_header_id
    --  AND    l.ae_line_num    = d.ae_line_num
    --  AND    l.application_id = p_application_id
    --  AND    d.application_id = p_application_id
    --  AND    d.ae_header_id = l_array_parent_hdr_idx(i)
    --  AND    d.temp_line_num = l_array_parent_line_idx(i); -- added new WHERE Clause for bug 7377888

    /* Changes for the bug:7230462 */
    SELECT NVL(l.entered_cr, l.entered_dr)
           ,NVL(l.accounted_cr, l.accounted_dr)
           ,NVL(l.unrounded_entered_cr, l.unrounded_entered_dr)
           ,NVL(l.unrounded_accounted_cr, l.unrounded_accounted_dr)
     INTO  l_array_entered_amt(i)
           ,l_array_accted_amt(i)
           ,l_array_unround_entered_amt(i)
           ,l_array_unround_accted_amt(i)
    FROM   xla_ae_lines l
    WHERE  l.ae_header_id   = l_array_parent_hdr_idx(i)
    AND    l.ae_line_num    = l_array_parent_line_idx(i)
    AND    l.application_id = p_application_id ;


   END LOOP;

   -----------------------------------------------------------------------------------------------------------
   -- 5017009 - Update the unrounded amounts with the rounded amounts for each line except the last MPA entry
   -----------------------------------------------------------------------------------------------------------
   FOR i in 1..l_array_parent_hdr_idx.COUNT LOOP

       SELECT xel2.ae_header_id
             ,xel2.ae_line_num
       BULK COLLECT INTO
              l_array_mpa_header_idx
             ,l_array_mpa_line_idx
       FROM   xla_ae_lines   xel2
             ,xla_ae_headers xeh
       WHERE  xel2.ae_header_id       = xeh.ae_header_id
       AND    xel2.application_id     = p_application_id
       AND    xel2.ae_header_id      <> l_array_max_hdr_idx(i)
       AND    xeh.application_id      = p_application_id
       AND    xeh.parent_ae_header_id = l_array_parent_hdr_idx(i);

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
                (p_msg      => 'MPA count='||l_array_mpa_header_idx.COUNT
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);
          FOR j IN 1..l_array_mpa_header_idx.COUNT LOOP
             trace
                (p_msg      => 'parent='||l_array_parent_hdr_idx(i)||' parent_line='||l_array_parent_line_idx(i)||
                               ' mpa_header='||l_array_mpa_header_idx(j)||
                               ' line='||l_array_mpa_line_idx(j)
                ,p_level    => C_LEVEL_STATEMENT
                ,p_module   => l_log_module);
          END LOOP;
       END IF;

       FORALL j IN 1..l_array_mpa_header_idx.COUNT
          UPDATE xla_ae_lines xel
          SET    unrounded_entered_cr   = entered_cr
                ,unrounded_entered_dr   = entered_dr
                ,unrounded_accounted_cr = accounted_cr
                ,unrounded_accounted_dr = accounted_dr
          WHERE application_id = p_application_id
          AND   ae_header_id   = l_array_mpa_header_idx(j)
          AND   ae_line_num    = l_array_mpa_line_idx(j);

       FORALL j IN 1..l_array_mpa_header_idx.COUNT
          UPDATE xla_distribution_links xdl
          SET   (unrounded_entered_cr
                ,unrounded_entered_dr
                ,unrounded_accounted_cr
                ,unrounded_accounted_dr) =
                (SELECT unrounded_entered_cr
                       ,unrounded_entered_dr
                       ,unrounded_accounted_cr
                       ,unrounded_accounted_dr
                 FROM  xla_ae_lines   xel2
                 WHERE xel2.ae_header_id = xdl.ae_header_id
                 AND   xel2.ae_line_num  = xdl.ae_line_num)
          WHERE application_id = p_application_id  -- 4585874
          AND   ae_header_id = l_array_mpa_header_idx(j)
          AND   ae_line_num  = l_array_mpa_line_idx(j);

   END LOOP;
   --------------------------------------------------------------------------------------------

   ------------------------------------------------------------
   -- Update the AMOUNTs for the last MPA line amount
   ------------------------------------------------------------
   FORALL i IN 1..l_array_parent_hdr_idx.COUNT
      UPDATE xla_ae_lines xel
      SET   (entered_cr
            ,entered_dr
            ,accounted_cr
            ,accounted_dr
            ,unrounded_entered_cr
            ,unrounded_entered_dr
            ,unrounded_accounted_cr
            ,unrounded_accounted_dr) =
            (SELECT DECODE(MIN(entered_cr),             NULL,NULL, l_array_entered_amt(i)         - SUM(entered_cr))
                   ,DECODE(MIN(entered_dr),             NULL,NULL, l_array_entered_amt(i)         - SUM(entered_dr))
                   ,DECODE(MIN(accounted_cr),           NULL,NULL, l_array_accted_amt(i)          - SUM(accounted_cr))
                   ,DECODE(MIN(accounted_dr),           NULL,NULL, l_array_accted_amt(i)          - SUM(accounted_dr))
                   ,DECODE(MIN(unrounded_entered_cr),   NULL,NULL, l_array_unround_entered_amt(i) - SUM(unrounded_entered_cr))
                   ,DECODE(MIN(unrounded_entered_dr),   NULL,NULL, l_array_unround_entered_amt(i) - SUM(unrounded_entered_dr))
                   ,DECODE(MIN(unrounded_accounted_cr), NULL,NULL, l_array_unround_accted_amt(i)  - SUM(unrounded_accounted_cr))
                   ,DECODE(MIN(unrounded_accounted_dr), NULL,NULL, l_array_unround_accted_amt(i)  - SUM(unrounded_accounted_dr))
             FROM  xla_ae_lines   xel2
                  ,xla_ae_headers xeh
             WHERE xel2.ae_header_id       = xeh.ae_header_id
             AND   xel2.ae_line_num        = xel.ae_line_num
             AND   xel2.application_id     = p_application_id  -- 4585874
             AND   xel2.ae_header_id      <> l_array_max_hdr_idx(i)
             AND   xeh.application_id      = p_application_id  -- 4585874
             AND   xeh.parent_ae_header_id = l_array_parent_hdr_idx(i)
             AND   xeh.parent_ae_line_num  = l_array_parent_line_idx(i))
      WHERE ae_header_id   = l_array_max_hdr_idx(i)
      AND   application_id = p_application_id;

   --------------------------------------------------------------------------------------------
   -- Update the DOC_ROUNDING values for the corresponding MPA line
   --------------------------------------------------------------------------------------------
   FORALL i IN 1..l_array_parent_hdr_idx.COUNT
      UPDATE xla_distribution_links xdl
      SET   (doc_rounding_acctd_amt
            ,doc_rounding_entered_amt
            ,unrounded_entered_cr       -- 4669308
            ,unrounded_entered_dr       -- 4669308
            ,unrounded_accounted_cr     -- 4669308
            ,unrounded_accounted_dr     -- 4669308
            ) =
            (SELECT DECODE(unrounded_accounted_cr,NULL,DECODE(unrounded_accounted_dr - accounted_dr,0,NULL,
                                                              unrounded_accounted_dr - accounted_dr)
                                                      ,DECODE(unrounded_accounted_cr - accounted_cr,0,NULL,
                                                              unrounded_accounted_cr - accounted_cr))
                   ,DECODE(unrounded_entered_cr,  NULL,DECODE(unrounded_entered_dr   - entered_dr,0,NULL,
                                                              unrounded_entered_dr   - entered_dr)
                                                      ,DECODE(unrounded_entered_cr   - entered_cr,0,NULL,
                                                              unrounded_entered_cr   - entered_cr))
                   ,unrounded_entered_cr
                   ,unrounded_entered_dr
                   ,unrounded_accounted_cr
                   ,unrounded_accounted_dr
             FROM  xla_ae_lines   xel2
             WHERE xel2.ae_header_id = xdl.ae_header_id
             AND   xel2.ae_line_num  = xdl.ae_line_num)
      WHERE application_id = p_application_id  -- 4585874
      AND   ae_header_id = l_array_max_hdr_idx(i);

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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.AdjustMpaLine');
END AdjustMpaLine;
--

/*======================================================================+
|                                                                       |
| 4669308 - Adjust Final MPA Reversal Line                              |
|                                                                       |
+======================================================================*/
--
/*
PROCEDURE AdjustMpaRevLine(p_application_id  IN INTEGER)
IS

l_log_module         VARCHAR2(240);

-- find the reversed parent entry which has all MPA lines reversed. Ignore Accrual reversal and if last MPA period is not reversed
CURSOR cur_mpa_rev_lines IS
SELECT MIN(xdl1.ref_ae_header_id)   -- parent ae_header_id
      ,MAX(xdl1.ae_line_num)
      ,xdl1.ae_header_id
      ,xdl1.ref_event_id
      ,xeh1.ledger_id
FROM   xla_distribution_links xdl1
      ,xla_ae_headers         xeh1
      ,xla_ae_headers_gt      xehg
WHERE xdl1.application_id = p_application_id
AND   xeh1.application_id = p_application_id
AND   xdl1.ae_header_id   = xehg.ae_header_id
AND   xdl1.ae_header_id   = xeh1.ae_header_id
AND   xdl1.temp_line_num  = xdl1.ref_temp_line_num*-1  -- is a reversal
AND   EXISTS (SELECT 1
              FROM   xla_ae_headers
              WHERE  application_id      = p_application_id
              AND    parent_ae_header_id = xdl1.ref_ae_header_id
              AND    parent_ae_line_num IS NOT NULL)                         -- MPA only, not for Accrual Reversal
GROUP BY xdl1.ref_ae_header_id, xdl1.ref_event_id, xdl1.application_id, xeh1.ledger_id, xdl1.ae_header_id
HAVING (SELECT COUNT(*) FROM xla_distribution_links xdl2                     -- count of reversal lines
        WHERE  xdl2.application_id     = p_application_id
        AND    xdl2.ae_header_id       = xdl1.ae_header_id
        AND    xdl2.temp_line_num      = xdl2.ref_temp_line_num*-1
        AND    xdl2.ref_ae_header_id  <> xdl1.ref_ae_header_id
        AND    xdl2.ref_event_id       = xdl1.ref_event_id ) =
       (SELECT COUNT(*) FROM xla_distribution_links xdl3,xla_ae_headers xeh  -- count of original lines
        WHERE  xdl3.application_id     = p_application_id
        AND    xeh.application_id      = p_application_id
        AND    xdl3.ae_header_id       = xeh.ae_header_id
        AND    xdl3.event_id           = xdl1.ref_event_id
        AND    xdl3.ref_temp_line_num IS NULL
        AND    xeh.parent_ae_header_id = xdl1.ref_ae_header_id
        AND    xeh.parent_ae_line_num IS NOT NULL)
ORDER BY xeh1.ledger_id, xdl1.ref_event_id;
     --(SELECT COUNT(*) FROM xla_ae_lines xel,xla_ae_headers xeh    -- count of original lines
     -- WHERE  xeh.application_id      = p_application_id
     -- AND    xel.ae_header_id        = xeh.ae_header_id
     -- AND    xeh.parent_ae_header_id = xdl1.ref_ae_header_id
     -- AND    xeh.parent_ae_line_num IS NOT NULL)

CURSOR cur_last_mpa (l_ae_header   NUMBER, l_max_ae_header  NUMBER) is
SELECT xel.rowid,  xel.*
FROM   xla_ae_lines xel ,
       xla_distribution_links xdl2
WHERE xel.application_id    = p_application_id
  AND xel.ae_header_id      = l_ae_header
  AND xdl2.application_id   = p_application_id
  AND xdl2.ae_header_id     = xel.ae_header_id
  AND xdl2.ref_ae_header_id = l_max_ae_header
  AND xel.ae_line_num       = xdl2.ae_line_num;

l_last_mpa                  cur_last_mpa%ROWTYPE;

l_array_parent_hdr_idx      xla_cmp_source_pkg.t_array_Num;
l_array_parent_max_line     xla_cmp_source_pkg.t_array_Num;
l_array_ae_header_id        xla_cmp_source_pkg.t_array_Num;
l_array_ref_event_id        xla_cmp_source_pkg.t_array_Num;
l_array_ledger_id           xla_cmp_source_pkg.t_array_Num;

l_array_entered_amt         xla_ae_journal_entry_pkg.t_array_Num;
l_array_accted_amt          xla_ae_journal_entry_pkg.t_array_Num;
l_array_unround_entered_amt xla_ae_journal_entry_pkg.t_array_Num;
l_array_unround_accted_amt  xla_ae_journal_entry_pkg.t_array_Num;

l_max_hdr_id                NUMBER;
l_max_lin_id                NUMBER;

BEGIN
   --
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AdjustMpaRevLine';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AdjustMpaRevLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

   END IF;

   ------------------------------------------------------------
   -- Find the MPA Reversal lines
   ------------------------------------------------------------
   OPEN  cur_mpa_rev_lines;
   FETCH cur_mpa_rev_lines BULK COLLECT INTO  l_array_parent_hdr_idx
                                             ,l_array_parent_max_line  -- find the original amount
                                             ,l_array_ae_header_id
                                             ,l_array_ref_event_id
                                             ,l_array_ledger_id;
   CLOSE cur_mpa_rev_lines;


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     for  i in 1..l_array_parent_hdr_idx.COUNT loop
      trace
         (p_msg      => 'parent='||l_array_parent_hdr_idx(i)||
                        ' max_line_id='||l_array_parent_max_line(i)||
                        ' rev_ae_header='||l_array_ae_header_id(i)||
                        ' ref_event='||l_array_ref_event_id(i)||
                        ' ledger='||l_array_ledger_id(i)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     end loop;
   END IF;

   ------------------------------------------------------------
   -- Find the original amounts for each parent
   ------------------------------------------------------------
   FOR i IN 1..l_array_ae_header_id.COUNT LOOP
      SELECT NVL(entered_cr, entered_dr)
            ,NVL(accounted_cr, accounted_dr)
            ,NVL(unrounded_entered_cr, unrounded_entered_dr)
            ,NVL(unrounded_accounted_cr, unrounded_accounted_dr)
      INTO   l_array_entered_amt(i)
            ,l_array_accted_amt(i)
            ,l_array_unround_entered_amt(i)
            ,l_array_unround_accted_amt(i)
      FROM   xla_ae_lines
      WHERE  application_id = p_application_id
      AND    ae_header_id   = l_array_ae_header_id(i)
      AND    ae_line_num    = l_array_parent_max_line(i);
   END LOOP;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     for  i in 1..l_array_parent_hdr_idx.COUNT loop
      trace
         (p_msg      => 'parent='||l_array_parent_hdr_idx(i)||
                        ' ent='||l_array_entered_amt(i)||
                        ' acc='||l_array_accted_amt(i)||
                        ' unr_ent='||l_array_unround_entered_amt(i)||
                        ' unr_acc='||l_array_unround_accted_amt(i)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     end loop;
   END IF;

   ------------------------------------------------------------
   -- Update the AMOUNTs for the last MPA line amount
   ------------------------------------------------------------
   FOR i IN 1..l_array_parent_hdr_idx.COUNT LOOP

      l_max_hdr_id := NULL;
      l_max_lin_id := NULL;

      SELECT MAX(xdl1.ref_ae_header_id)  -- last recognition header
      INTO   l_max_hdr_id
      FROM   xla_distribution_links xdl1
            ,xla_ae_headers         xeh1
      WHERE  xdl1.application_id      = p_application_id
      AND    xdl1.ae_header_id        = l_array_ae_header_id(i)
      AND    xdl1.temp_line_num       = xdl1.ref_temp_line_num*-1
      AND    xdl1.ref_ae_header_id    <> l_array_parent_hdr_idx(i)
      AND    xdl1.ref_event_id        = l_array_ref_event_id(i)
      AND    xeh1.application_id      = p_application_id
      AND    xeh1.parent_ae_header_id = l_array_parent_hdr_idx(i)
      AND    xeh1.parent_ae_line_num IS NOT NULL
      AND    xeh1.ledger_id           = l_array_ledger_id(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
             (p_msg      => 'parent='||l_array_parent_hdr_idx(i)||
                            ' last_recog_header='||l_max_hdr_id
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
      END IF;

      IF l_max_hdr_id IS NOT NULL THEN

       OPEN  cur_last_mpa(l_array_ae_header_id(i), l_max_hdr_id);
       FETCH cur_last_mpa INTO l_last_mpa;
       WHILE cur_last_mpa%FOUND LOOP

         UPDATE xla_ae_lines xel
         SET (entered_cr
             ,entered_dr
             ,accounted_cr
             ,accounted_dr
             ,unrounded_entered_cr
             ,unrounded_entered_dr
             ,unrounded_accounted_cr
             ,unrounded_accounted_dr) =
            (SELECT DECODE((l_last_mpa.entered_cr),             NULL,NULL, l_array_entered_amt(i)         - SUM(xel2.entered_cr))
                   ,DECODE((l_last_mpa.entered_dr),             NULL,NULL, l_array_entered_amt(i)         - SUM(xel2.entered_dr))
                   ,DECODE((l_last_mpa.accounted_cr),           NULL,NULL, l_array_accted_amt(i)          - SUM(xel2.accounted_cr))
                   ,DECODE((l_last_mpa.accounted_dr),           NULL,NULL, l_array_accted_amt(i)          - SUM(xel2.accounted_dr))
                   ,DECODE((l_last_mpa.unrounded_entered_cr),   NULL,NULL, l_array_unround_entered_amt(i) - SUM(xel2.unrounded_entered_cr))
                   ,DECODE((l_last_mpa.unrounded_entered_dr),   NULL,NULL, l_array_unround_entered_amt(i) - SUM(xel2.unrounded_entered_dr))
                   ,DECODE((l_last_mpa.unrounded_accounted_cr), NULL,NULL, l_array_unround_accted_amt(i)  - SUM(xel2.unrounded_accounted_cr))
                   ,DECODE((l_last_mpa.unrounded_accounted_dr), NULL,NULL, l_array_unround_accted_amt(i)  - SUM(xel2.unrounded_accounted_dr))
             FROM   xla_ae_lines xel2
                   ,xla_distribution_links xdl1
                   ,xla_ae_headers         xeh1
             WHERE xel2.application_id      = p_application_id
             AND   xel2.ae_header_id        = xdl1.ae_header_id
             AND   xel2.ae_line_num         = xdl1.ae_line_num
             AND   xdl1.application_id      = p_application_id
             AND   xdl1.ae_header_id        = l_array_ae_header_id(i)
             AND   xdl1.temp_line_num       = xdl1.ref_temp_line_num*-1
             AND   xeh1.application_id      = p_application_id
             AND   xeh1.parent_ae_header_id = l_array_parent_hdr_idx(i)
             AND   xeh1.parent_ae_line_num IS NOT NULL
             AND   xdl1.ref_ae_header_id    = xeh1.ae_header_id
             AND   xdl1.ref_ae_header_id NOT IN (l_array_parent_hdr_idx(i),l_max_hdr_id) -- not the parent or the last period
             AND   xdl1.ref_event_id       = l_array_ref_event_id(i)
             AND   xeh1.ledger_id          = l_array_ledger_id(i))
         WHERE rowid = l_last_mpa.rowid;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace
                 (p_msg      => 'update xla_ae_lines count='||SQL%ROWCOUNT||
                                ' ae_header='||l_last_mpa.ae_header_id||
                                ' ae_line='||l_last_mpa.ae_line_num
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
         END IF;

         --------------------------------------------------------------------------------------------
         -- Update the DOC_ROUNDING values for the corresponding MPA line
         --------------------------------------------------------------------------------------------
         UPDATE xla_distribution_links xdl
         SET   (doc_rounding_acctd_amt
               ,doc_rounding_entered_amt
               ,unrounded_entered_cr
               ,unrounded_entered_dr
               ,unrounded_accounted_cr
               ,unrounded_accounted_dr
               ) =
            (SELECT DECODE(xel.unrounded_accounted_cr,NULL,DECODE(xel.unrounded_accounted_dr - xel.accounted_dr,0,NULL,
                                                                  xel.unrounded_accounted_dr - xel.accounted_dr)
                                                          ,DECODE(xel.unrounded_accounted_cr - xel.accounted_cr,0,NULL,
                                                                  xel.unrounded_accounted_cr - xel.accounted_cr))
                   ,DECODE(xel.unrounded_entered_cr,  NULL,DECODE(xel.unrounded_entered_dr   - xel.entered_dr,0,NULL,
                                                                  xel.unrounded_entered_dr   - xel.entered_dr)
                                                          ,DECODE(xel.unrounded_entered_cr   - xel.entered_cr,0,NULL,
                                                                  xel.unrounded_entered_cr   - xel.entered_cr))
                   ,xel.unrounded_entered_cr
                   ,xel.unrounded_entered_dr
                   ,xel.unrounded_accounted_cr
                   ,xel.unrounded_accounted_dr
             FROM   xla_ae_lines xel
                   ,xla_distribution_links xdl1
             WHERE xel.application_id    = p_application_id
             AND   xel.ae_header_id      = xdl1.ae_header_id
             AND   xel.ae_line_num       = xdl1.ae_line_num
             AND   xdl1.application_id   = p_application_id
             AND   xdl1.ae_header_id     = l_array_ae_header_id(i)
             AND   xdl1.temp_line_num    = xdl1.ref_temp_line_num*-1
             AND   xdl1.ref_ae_header_id = l_max_hdr_id           -- the last
             AND   xel.ae_line_num       = xdl.ae_line_num
             AND   xdl1.ref_event_id     = l_array_ref_event_id(i))
         WHERE application_id = p_application_id
         AND   ae_header_id   = l_last_mpa.ae_header_id
         AND   ae_line_num    = l_last_mpa.ae_line_num;


         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
              trace
                 (p_msg      => 'update xla_dist_link count='||SQL%ROWCOUNT||
                                ' ae_header='||l_last_mpa.ae_header_id||
                                ' ae_line='||l_last_mpa.ae_line_num
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
         END IF;

         FETCH cur_last_mpa INTO l_last_mpa;

       END LOOP;  --  cur_last_mpa%FOUND

       CLOSE cur_last_mpa;


      END IF; -- l_max_hdr_id IS NOT NULL

   END LOOP;  -- l_array_parent_hdr_idx.COUNT


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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.AdjustMpaRevLine');
END AdjustMpaRevLine;
*/

--
/*======================================================================+
| PRIVATE procedure: InsertLinks                                        |
|                                                                       |
| Description: Inserts distribution links                               |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertLinks(p_application_id    IN INTEGER)
IS
l_rowcount           NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertLinks';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertLinks'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
BEGIN

 IF (C_LEVEL_EXCEPTION >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_distribution_links'
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);

 END IF;

l_rowcount := 0;

INSERT INTO xla_distribution_links
(
   application_id
 , event_id
 , source_distribution_id_char_1
 , source_distribution_id_char_2
 , source_distribution_id_char_3
 , source_distribution_id_char_4
 , source_distribution_id_char_5
 , source_distribution_id_num_1
 , source_distribution_id_num_2
 , source_distribution_id_num_3
 , source_distribution_id_num_4
 , source_distribution_id_num_5
 , source_distribution_type
 , APPLIED_TO_APPLICATION_ID
 , APPLIED_TO_ENTITY_CODE
 , APPLIED_TO_ENTITY_ID
 , APPLIED_TO_SOURCE_ID_NUM_1
 , APPLIED_TO_SOURCE_ID_NUM_2
 , APPLIED_TO_SOURCE_ID_NUM_3
 , APPLIED_TO_SOURCE_ID_NUM_4
 , APPLIED_TO_SOURCE_ID_CHAR_1
 , APPLIED_TO_SOURCE_ID_CHAR_2
 , APPLIED_TO_SOURCE_ID_CHAR_3
 , APPLIED_TO_SOURCE_ID_CHAR_4
 , APPLIED_TO_DISTRIBUTION_TYPE
 , APPLIED_TO_DIST_ID_NUM_1
 , APPLIED_TO_DIST_ID_NUM_2
 , APPLIED_TO_DIST_ID_NUM_3
 , APPLIED_TO_DIST_ID_NUM_4
 , APPLIED_TO_DIST_ID_NUM_5
 , APPLIED_TO_DIST_ID_CHAR_1
 , APPLIED_TO_DIST_ID_CHAR_2
 , APPLIED_TO_DIST_ID_CHAR_3
 , APPLIED_TO_DIST_ID_CHAR_4
 , APPLIED_TO_DIST_ID_CHAR_5
 , unrounded_entered_cr
 , unrounded_entered_dr
 , unrounded_accounted_cr
 , unrounded_accounted_dr
 , ae_header_id
 , ae_line_num
 , temp_line_num
 , tax_line_ref_id
 , tax_summary_line_ref_id
 , tax_rec_nrec_dist_ref_id
 , statistical_amount
 , event_class_code
 , event_type_code
 , line_definition_owner_code
 , line_definition_code
 , accounting_line_type_code
 , accounting_line_code
 , ref_event_id
 , ref_ae_header_id
 , ref_temp_line_num
 , gain_or_loss_ref
 , merge_duplicate_code
 , calculate_acctd_amts_flag
 , calculate_g_l_amts_flag
 , rounding_class_code
 , document_rounding_level
 , doc_rounding_acctd_amt
 , doc_rounding_entered_amt
 --
 -- Allocation Attributes
 --
 , alloc_to_application_id
 , alloc_to_entity_code
 , alloc_to_source_id_num_1
 , alloc_to_source_id_num_2
 , alloc_to_source_id_num_3
 , alloc_to_source_id_num_4
 , alloc_to_source_id_char_1
 , alloc_to_source_id_char_2
 , alloc_to_source_id_char_3
 , alloc_to_source_id_char_4
 , alloc_to_distribution_type
 , alloc_to_dist_id_char_1
 , alloc_to_dist_id_char_2
 , alloc_to_dist_id_char_3
 , alloc_to_dist_id_char_4
 , alloc_to_dist_id_char_5
 , alloc_to_dist_id_num_1
 , alloc_to_dist_id_num_2
 , alloc_to_dist_id_num_3
 , alloc_to_dist_id_num_4
 , alloc_to_dist_id_num_5
)
SELECT
          p_application_id
        , event_id
        , source_distribution_id_char_1
        , source_distribution_id_char_2
        , source_distribution_id_char_3
        , source_distribution_id_char_4
        , source_distribution_id_char_5
        , source_distribution_id_num_1
        , source_distribution_id_num_2
        , source_distribution_id_num_3
        , source_distribution_id_num_4
        , source_distribution_id_num_5
        , source_distribution_type
        , BFLOW_APPLICATION_ID
        , BFLOW_ENTITY_CODE
        , APPLIED_TO_ENTITY_ID
        , BFLOW_SOURCE_ID_NUM_1
        , BFLOW_SOURCE_ID_NUM_2
        , BFLOW_SOURCE_ID_NUM_3
        , BFLOW_SOURCE_ID_NUM_4
        , BFLOW_SOURCE_ID_CHAR_1
        , BFLOW_SOURCE_ID_CHAR_2
        , BFLOW_SOURCE_ID_CHAR_3
        , BFLOW_SOURCE_ID_CHAR_4
        , BFLOW_DISTRIBUTION_TYPE
        , BFLOW_DIST_ID_NUM_1
        , BFLOW_DIST_ID_NUM_2
        , BFLOW_DIST_ID_NUM_3
        , BFLOW_DIST_ID_NUM_4
        , BFLOW_DIST_ID_NUM_5
        , BFLOW_DIST_ID_CHAR_1
        , BFLOW_DIST_ID_CHAR_2
        , BFLOW_DIST_ID_CHAR_3
        , BFLOW_DIST_ID_CHAR_4
        , BFLOW_DIST_ID_CHAR_5
        , unrounded_entered_cr
        , unrounded_entered_dr
        , unrounded_accounted_cr
        , unrounded_accounted_dr
        , ae_header_id
        , ae_line_num
        , temp_line_num
        , tax_line_ref_id
        , tax_summary_line_ref_id
        , tax_rec_nrec_dist_ref_id
        , statistical_amount
        , event_class_code
        , event_type_code
        , line_definition_owner_code
        , line_definition_code
        , accounting_line_type_code
        , accounting_line_code
        , ref_event_id
        , ref_ae_header_id
        , ref_temp_line_num
        , gain_or_loss_ref
        , merge_duplicate_code
        , calculate_acctd_amts_flag
        , calculate_g_l_amts_flag
        , rounding_class_code
        , document_rounding_level
        , doc_rounding_acctd_amt
        , doc_rounding_entered_amt
        --
        -- Allocation Attributes
        --
        , alloc_to_application_id
        , alloc_to_entity_code
        , alloc_to_source_id_num_1
        , alloc_to_source_id_num_2
        , alloc_to_source_id_num_3
        , alloc_to_source_id_num_4
        , alloc_to_source_id_char_1
        , alloc_to_source_id_char_2
        , alloc_to_source_id_char_3
        , alloc_to_source_id_char_4
        , alloc_to_distribution_type
        , alloc_to_dist_id_char_1
        , alloc_to_dist_id_char_2
        , alloc_to_dist_id_char_3
        , alloc_to_dist_id_char_4
        , alloc_to_dist_id_char_5
        , alloc_to_dist_id_num_1
        , alloc_to_dist_id_num_2
        , alloc_to_dist_id_num_3
        , alloc_to_dist_id_num_4
        , alloc_to_dist_id_num_5
FROM xla_ae_lines_gt
WHERE ae_line_num IS NOT NULL;

l_rowcount:= SQL%ROWCOUNT;

IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# lines inserted into xla_distribution_links = '||l_rowcount
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
END IF;

EXCEPTION
WHEN OTHERS  THEN

  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => sqlerrm
                                    );
END;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of InsertLinks'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertLinks');
END InsertLinks;
--
/*======================================================================+
|                                                                       |
| Insert final headers and distribution links                           |
|                                                                       |
|                                                                       |
+======================================================================*/
--
FUNCTION InsertHeaders(p_application_id                 IN INTEGER
                      ,p_accounting_batch_id            IN NUMBER
                      ,p_end_date                       IN DATE        -- 4262811
                      -- bulk performance
                      ,p_accounting_mode                 in varchar)
RETURN NUMBER
IS
l_rowcount           NUMBER;
l_log_module         VARCHAR2(240);
i                    NUMBER;     -- 4262811
l_error_msg          VARCHAR2(2000);
l_prod_rule_name      VARCHAR2(80);
l_event_class_name    VARCHAR2(80);
l_event_type_name     VARCHAR2(80);

cursor csr_null_gl_date is
    SELECT  pr.name, ec.name, et.name
    FROM    xla_product_rules_tl    pr
            ,xla_event_classes_tl   ec
            ,xla_event_types_tl     et
            ,xla_ae_headers_gt      h
    WHERE   pr.amb_context_code(+)       = h.amb_context_code
      AND   pr.application_id(+)         = p_application_id
      AND   pr.product_rule_type_code(+) = h.product_rule_type_code
      AND   pr.product_rule_code(+)      = h.product_rule_code
      AND   pr.language(+)               = USERENV('LANG')
      AND   ec.application_id(+)         = et.application_id
      AND   ec.event_class_code(+)       = et.event_class_code
      AND   ec.language(+)               = USERENV('LANG')
      AND   et.application_id(+)         = p_application_id
      AND   et.event_type_code(+)        = h.event_type_code
      AND   et.language(+)               = USERENV('LANG')
      AND   h.balance_type_code <> 'X'
      AND   h.accounting_date is null;

BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertHeaders';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertHeaders'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
l_rowcount := 0;
BEGIN

 IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_headers'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

 END IF;


--------------------------------------------------------
-- 4262811
--------------------------------------------------------
 IF xla_accounting_pkg.g_mpa_accrual_exists = 'Y' THEN      --4752807
   FORALL i IN 1..g_array_ae_header_id.COUNT
     UPDATE /*+ index(XLA_AE_HEADERS_GT, XLA_AE_HEADERS_GT_N1) */ --4918497
            xla_ae_headers_gt
        SET parent_header_id      = g_array_ae_header_id(i)
      WHERE parent_header_id      = g_array_event_id(i)    --  instead of ae_header_id
        AND ledger_id             = g_array_ledger_id(i)
        AND balance_type_code     = g_array_balance_type(i)
        AND g_array_header_num(i) = 0;
 END IF;
--------------------------------------------------------

--------------------------------------------------------
-- always insert into headers table with zero amount flag 'N'.
-- will update it in the validation package */
--
--
-- Bug 5056632
-- if there is no group_id (no transfer requested)
--    do a simple insert
-- else there is group_id (transfer requested along with accounting)
--    do forall insert
-- end if
--------------------------------------------------------

IF xla_accounting_pkg.g_array_group_id.COUNT = 0 THEN
INSERT INTO xla_ae_headers
(
   ae_header_id
 , application_id
 , ledger_id
 , entity_id
 , event_id
 , event_type_code
 , accounting_date
 , gl_transfer_status_code
 , je_category_name
 , accounting_entry_status_code
 , accounting_entry_type_code
 , product_rule_type_code
 , product_rule_code
 , product_rule_version
 , description
 , creation_date
 , created_by
 , last_update_date
 , last_updated_by
 , last_update_login
 , doc_sequence_id
 , doc_sequence_value
 , doc_category_code
 , program_update_date
 , program_application_id
 , program_id
 , request_id
 , budget_version_id
 --, encumbrance_type_id  -- 3358381
 , balance_type_code
 , completed_date
 , period_name
 , accounting_batch_id
 , amb_context_code
 , zero_amount_flag
 , parent_ae_header_id   -- 4262811
 , parent_ae_line_num    -- 4262811
 , accrual_reversal_flag -- 4262811
 , group_id              -- 5056632
)
SELECT
           hed.ae_header_id
         , p_application_id
         , hed.ledger_id
         , hed.entity_id
         , hed.event_id
         , hed.event_type_code
         , hed.accounting_date
         , hed.gl_transfer_status_code
         , hed.je_category_name
--       , hed.accounting_entry_status_code
       -- 4262811
       --, decode(hed.accounting_entry_status_code,C_VALID, p_accounting_mode,C_INVALID,'I',C_RELATED_INVALID, 'R', NULL)
         , decode(hed.accounting_entry_status_code
                 ,C_VALID, CASE WHEN hed.accounting_date<=p_end_date THEN
                                     p_accounting_mode
                                WHEN hed.accounting_date > p_end_date -- AND hed.accrual_reversal_flag = 'N' -- commented for 8505463
				     AND hed.parent_header_id IS NULL -- non MPA/Accrual Reversal's have PARENT_HEADER_ID as NULL for bug8505463
				THEN                                 -- MPA/Accrual Reversal's and Regular Accounting have accrual_reversal_flag as N
				     p_accounting_mode
				ELSE
				     'N'
                           END
                 ,C_INVALID,'I'
                 ,C_RELATED_INVALID, 'R'
                 ,NULL)
         , hed.accounting_entry_type_code
         , hed.product_rule_type_code
         , hed.product_rule_code
         , hed.product_rule_version
         , hed.description
         , g_who_columns.creation_date
         , g_who_columns.created_by
         , g_who_columns.last_update_date
         , g_who_columns.last_updated_by
         , g_who_columns.last_update_login
         , hed.doc_sequence_id
         , hed.doc_sequence_value
         , hed.doc_category_code
         , g_who_columns.program_update_date
         , g_who_columns.program_application_id
         , g_who_columns.program_id
         , g_who_columns.request_id
         , CASE hed.balance_type_code
             WHEN 'B' THEN hed.budget_version_id
             ELSE NULL
           END
         -- , CASE hed.balance_type_code  -- 34458381 Public Sector Enh
         --     WHEN 'E' THEN hed.encumbrance_type_id
         --     ELSE NULL
         --   END
         , hed.balance_type_code
         , sysdate
         , hed.period_name
         , p_accounting_batch_id
         , hed.amb_context_code
         , 'N'
         , hed.parent_header_id      -- 4262811
         , hed.parent_ae_line_num    -- 4262811
         , hed.accrual_reversal_flag -- 4262811
         , NULL                      -- group_id
          FROM xla_ae_headers_gt hed
          where hed.balance_type_code <> 'X';
ELSE  -- xla_accounting_pkg.g_array_group_id.COUNT > 0
FORALL i IN 1..xla_accounting_pkg.g_array_group_id.COUNT
INSERT INTO xla_ae_headers
(
   ae_header_id
 , application_id
 , ledger_id
 , entity_id
 , event_id
 , event_type_code
 , accounting_date
 , gl_transfer_status_code
 , je_category_name
 , accounting_entry_status_code
 , accounting_entry_type_code
 , product_rule_type_code
 , product_rule_code
 , product_rule_version
 , description
 , creation_date
 , created_by
 , last_update_date
 , last_updated_by
 , last_update_login
 , doc_sequence_id
 , doc_sequence_value
 , doc_category_code
 , program_update_date
 , program_application_id
 , program_id
 , request_id
 , budget_version_id
 --, encumbrance_type_id  -- 3358381
 , balance_type_code
 , completed_date
 , period_name
 , accounting_batch_id
 , amb_context_code
 , zero_amount_flag
 , parent_ae_header_id   -- 4262811
 , parent_ae_line_num    -- 4262811
 , accrual_reversal_flag -- 4262811
 , group_id
)
SELECT
           hed.ae_header_id
         , p_application_id
         , hed.ledger_id
         , hed.entity_id
         , hed.event_id
         , hed.event_type_code
         , hed.accounting_date
         , hed.gl_transfer_status_code
         , hed.je_category_name
--       , hed.accounting_entry_status_code
       -- 4262811
       --, decode(hed.accounting_entry_status_code,C_VALID, p_accounting_mode,C_INVALID,'I',C_RELATED_INVALID, 'R', NULL)
         , decode(hed.accounting_entry_status_code
                 ,C_VALID, CASE WHEN hed.accounting_date<=p_end_date THEN
                                     p_accounting_mode
                                WHEN hed.accounting_date > p_end_date -- AND hed.accrual_reversal_flag = 'N' -- commented for 8505463
				     AND hed.parent_header_id IS NULL -- non MPA/Accrual Reversal's have PARENT_HEADER_ID as NULL for bug8505463
				THEN                                 -- MPA/Accrual Reversal's and Regular Accounting have accrual_reversal_flag as N
				     p_accounting_mode
				ELSE
				     'N'
                           END
                 ,C_INVALID,'I'
                 ,C_RELATED_INVALID, 'R'
                 ,NULL)
         , hed.accounting_entry_type_code
         , hed.product_rule_type_code
         , hed.product_rule_code
         , hed.product_rule_version
         , hed.description
         , g_who_columns.creation_date
         , g_who_columns.created_by
         , g_who_columns.last_update_date
         , g_who_columns.last_updated_by
         , g_who_columns.last_update_login
         , hed.doc_sequence_id
         , hed.doc_sequence_value
         , hed.doc_category_code
         , g_who_columns.program_update_date
         , g_who_columns.program_application_id
         , g_who_columns.program_id
         , g_who_columns.request_id
         , CASE hed.balance_type_code
             WHEN 'B' THEN hed.budget_version_id
             ELSE NULL
           END
         -- , CASE hed.balance_type_code  -- 34458381 Public Sector Enh
         --     WHEN 'E' THEN hed.encumbrance_type_id
         --     ELSE NULL
         --   END
         , hed.balance_type_code
         , sysdate
         , hed.period_name
         , p_accounting_batch_id
         , hed.amb_context_code
         , 'N'
         , hed.parent_header_id      -- 4262811
         , hed.parent_ae_line_num    -- 4262811
         , hed.accrual_reversal_flag -- 4262811
         , DECODE(hed.accounting_entry_status_code
                 ,C_VALID, CASE WHEN hed.accounting_date<=p_end_date THEN
                                     xla_accounting_pkg.g_array_group_id(i)
                                ELSE NULL
                           END
                 ,NULL)
          FROM xla_ae_headers_gt hed
          where hed.balance_type_code <> 'X'
          and hed.ledger_id = xla_accounting_pkg.g_array_ledger_id(i);
END IF;

l_rowcount := SQL%ROWCOUNT;

IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# journal entry headers inserted into xla_ae_headers = '||l_rowcount
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
END IF;


EXCEPTION
WHEN OTHERS  THEN

  l_error_msg :=substr(sqlerrm, 1, 1999);

  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||l_error_msg
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  open csr_null_gl_date;
  fetch csr_null_gl_date into l_prod_rule_name, l_event_class_name, l_event_type_name;
  IF(csr_null_gl_date%NOTFOUND) THEN
    close csr_null_gl_date;
    xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => l_error_msg
                                    );
  ELSE
    close csr_null_gl_date;
    xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_NULL_GL_DATE'
                                    ,p_token_1      => 'EVENT_CLASS_NAME'
                                    ,p_value_1      => l_event_class_name
                                    ,p_token_2      => 'EVENT_TYPE_NAME'
                                    ,p_value_2      => l_event_type_name
                                    ,p_token_3      => 'PRODUCT_RULE_NAME'
                                    ,p_value_3      => l_prod_rule_name
                                    );
  END IF;
END;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_rowcount)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of InsertHeaders'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
RETURN l_rowcount;
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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertHeaders');
   --
END InsertHeaders;
--
/*======================================================================+
|                                                                       |
| Insert final Lines                                                    |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertHdrAnalyticalCriteria
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertHdrAnalyticalCriteria';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertHdrAnalyticalCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_header_acs'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;
--

   IF g_hdr_ac_count <= 10 THEN

      InsertHdrAnalyticalCriteria10;

   ELSIF g_hdr_ac_count <= 50 THEN

      InsertHdrAnalyticalCriteria50;

   ELSIF g_hdr_ac_count <= 100 THEN

      InsertHdrAnalyticalCriteria100;

   END IF;


--
IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# header analytical criteria inserted into xla_ae_header_acs = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
END IF;

--
EXCEPTION
WHEN OTHERS THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => sqlerrm
                                    );
END;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of InsertHdrAnalyticalCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertHdrAnalyticalCriteria');
   --
END InsertHdrAnalyticalCriteria;

--
/*======================================================================+
|                                                                       |
| Insert Header Analytical Criteria 10                                  |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertHdrAnalyticalCriteria10
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertHdrAnalyticalCriteria10';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertHdrAnalyticalCriteria10'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_header_acs'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;
--

INSERT ALL
WHEN anc_id_1 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_1
       ,1
       ,INSTRB(anc_id_1,'(]',1,1) -1)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,1) + 2
       ,INSTRB(anc_id_1,'(]',1,2) -
        INSTRB(anc_id_1,'(]',1,1) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,2) + 2
       ,INSTRB(anc_id_1,'(]',1,3) -
        INSTRB(anc_id_1,'(]',1,2) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,3) + 2
       ,INSTRB(anc_id_1,'(]',1,4) -
        INSTRB(anc_id_1,'(]',1,3) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,4) + 2
       ,INSTRB(anc_id_1,'(]',1,5) -
        INSTRB(anc_id_1,'(]',1,4) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,5) + 2
       ,INSTRB(anc_id_1,'(]',1,6) -
        INSTRB(anc_id_1,'(]',1,5) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,6) + 2
       ,INSTRB(anc_id_1,'(]',1,7) -
        INSTRB(anc_id_1,'(]',1,6) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,7) + 2
       ,LENGTHB(anc_id_1))
)

WHEN anc_id_2 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_2
       ,1
       ,INSTRB(anc_id_2,'(]',1,1) -1)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,1) + 2
       ,INSTRB(anc_id_2,'(]',1,2) -
        INSTRB(anc_id_2,'(]',1,1) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,2) + 2
       ,INSTRB(anc_id_2,'(]',1,3) -
        INSTRB(anc_id_2,'(]',1,2) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,3) + 2
       ,INSTRB(anc_id_2,'(]',1,4) -
        INSTRB(anc_id_2,'(]',1,3) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,4) + 2
       ,INSTRB(anc_id_2,'(]',1,5) -
        INSTRB(anc_id_2,'(]',1,4) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,5) + 2
       ,INSTRB(anc_id_2,'(]',1,6) -
        INSTRB(anc_id_2,'(]',1,5) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,6) + 2
       ,INSTRB(anc_id_2,'(]',1,7) -
        INSTRB(anc_id_2,'(]',1,6) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,7) + 2
       ,LENGTHB(anc_id_2))
)

WHEN anc_id_3 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_3
       ,1
       ,INSTRB(anc_id_3,'(]',1,1) -1)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,1) + 2
       ,INSTRB(anc_id_3,'(]',1,2) -
        INSTRB(anc_id_3,'(]',1,1) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,2) + 2
       ,INSTRB(anc_id_3,'(]',1,3) -
        INSTRB(anc_id_3,'(]',1,2) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,3) + 2
       ,INSTRB(anc_id_3,'(]',1,4) -
        INSTRB(anc_id_3,'(]',1,3) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,4) + 2
       ,INSTRB(anc_id_3,'(]',1,5) -
        INSTRB(anc_id_3,'(]',1,4) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,5) + 2
       ,INSTRB(anc_id_3,'(]',1,6) -
        INSTRB(anc_id_3,'(]',1,5) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,6) + 2
       ,INSTRB(anc_id_3,'(]',1,7) -
        INSTRB(anc_id_3,'(]',1,6) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,7) + 2
       ,LENGTHB(anc_id_3))
)

WHEN anc_id_4 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_4
       ,1
       ,INSTRB(anc_id_4,'(]',1,1) -1)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,1) + 2
       ,INSTRB(anc_id_4,'(]',1,2) -
        INSTRB(anc_id_4,'(]',1,1) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,2) + 2
       ,INSTRB(anc_id_4,'(]',1,3) -
        INSTRB(anc_id_4,'(]',1,2) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,3) + 2
       ,INSTRB(anc_id_4,'(]',1,4) -
        INSTRB(anc_id_4,'(]',1,3) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,4) + 2
       ,INSTRB(anc_id_4,'(]',1,5) -
        INSTRB(anc_id_4,'(]',1,4) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,5) + 2
       ,INSTRB(anc_id_4,'(]',1,6) -
        INSTRB(anc_id_4,'(]',1,5) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,6) + 2
       ,INSTRB(anc_id_4,'(]',1,7) -
        INSTRB(anc_id_4,'(]',1,6) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,7) + 2
       ,LENGTHB(anc_id_4))
)

WHEN anc_id_5 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_5
       ,1
       ,INSTRB(anc_id_5,'(]',1,1) -1)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,1) + 2
       ,INSTRB(anc_id_5,'(]',1,2) -
        INSTRB(anc_id_5,'(]',1,1) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,2) + 2
       ,INSTRB(anc_id_5,'(]',1,3) -
        INSTRB(anc_id_5,'(]',1,2) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,3) + 2
       ,INSTRB(anc_id_5,'(]',1,4) -
        INSTRB(anc_id_5,'(]',1,3) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,4) + 2
       ,INSTRB(anc_id_5,'(]',1,5) -
        INSTRB(anc_id_5,'(]',1,4) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,5) + 2
       ,INSTRB(anc_id_5,'(]',1,6) -
        INSTRB(anc_id_5,'(]',1,5) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,6) + 2
       ,INSTRB(anc_id_5,'(]',1,7) -
        INSTRB(anc_id_5,'(]',1,6) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,7) + 2
       ,LENGTHB(anc_id_5))
)

WHEN anc_id_6 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_6
       ,1
       ,INSTRB(anc_id_6,'(]',1,1) -1)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,1) + 2
       ,INSTRB(anc_id_6,'(]',1,2) -
        INSTRB(anc_id_6,'(]',1,1) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,2) + 2
       ,INSTRB(anc_id_6,'(]',1,3) -
        INSTRB(anc_id_6,'(]',1,2) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,3) + 2
       ,INSTRB(anc_id_6,'(]',1,4) -
        INSTRB(anc_id_6,'(]',1,3) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,4) + 2
       ,INSTRB(anc_id_6,'(]',1,5) -
        INSTRB(anc_id_6,'(]',1,4) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,5) + 2
       ,INSTRB(anc_id_6,'(]',1,6) -
        INSTRB(anc_id_6,'(]',1,5) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,6) + 2
       ,INSTRB(anc_id_6,'(]',1,7) -
        INSTRB(anc_id_6,'(]',1,6) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,7) + 2
       ,LENGTHB(anc_id_6))
)

WHEN anc_id_7 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_7
       ,1
       ,INSTRB(anc_id_7,'(]',1,1) -1)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,1) + 2
       ,INSTRB(anc_id_7,'(]',1,2) -
        INSTRB(anc_id_7,'(]',1,1) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,2) + 2
       ,INSTRB(anc_id_7,'(]',1,3) -
        INSTRB(anc_id_7,'(]',1,2) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,3) + 2
       ,INSTRB(anc_id_7,'(]',1,4) -
        INSTRB(anc_id_7,'(]',1,3) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,4) + 2
       ,INSTRB(anc_id_7,'(]',1,5) -
        INSTRB(anc_id_7,'(]',1,4) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,5) + 2
       ,INSTRB(anc_id_7,'(]',1,6) -
        INSTRB(anc_id_7,'(]',1,5) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,6) + 2
       ,INSTRB(anc_id_7,'(]',1,7) -
        INSTRB(anc_id_7,'(]',1,6) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,7) + 2
       ,LENGTHB(anc_id_7))
)

WHEN anc_id_8 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_8
       ,1
       ,INSTRB(anc_id_8,'(]',1,1) -1)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,1) + 2
       ,INSTRB(anc_id_8,'(]',1,2) -
        INSTRB(anc_id_8,'(]',1,1) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,2) + 2
       ,INSTRB(anc_id_8,'(]',1,3) -
        INSTRB(anc_id_8,'(]',1,2) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,3) + 2
       ,INSTRB(anc_id_8,'(]',1,4) -
        INSTRB(anc_id_8,'(]',1,3) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,4) + 2
       ,INSTRB(anc_id_8,'(]',1,5) -
        INSTRB(anc_id_8,'(]',1,4) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,5) + 2
       ,INSTRB(anc_id_8,'(]',1,6) -
        INSTRB(anc_id_8,'(]',1,5) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,6) + 2
       ,INSTRB(anc_id_8,'(]',1,7) -
        INSTRB(anc_id_8,'(]',1,6) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,7) + 2
       ,LENGTHB(anc_id_8))
)

WHEN anc_id_9 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_9
       ,1
       ,INSTRB(anc_id_9,'(]',1,1) -1)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,1) + 2
       ,INSTRB(anc_id_9,'(]',1,2) -
        INSTRB(anc_id_9,'(]',1,1) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,2) + 2
       ,INSTRB(anc_id_9,'(]',1,3) -
        INSTRB(anc_id_9,'(]',1,2) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,3) + 2
       ,INSTRB(anc_id_9,'(]',1,4) -
        INSTRB(anc_id_9,'(]',1,3) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,4) + 2
       ,INSTRB(anc_id_9,'(]',1,5) -
        INSTRB(anc_id_9,'(]',1,4) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,5) + 2
       ,INSTRB(anc_id_9,'(]',1,6) -
        INSTRB(anc_id_9,'(]',1,5) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,6) + 2
       ,INSTRB(anc_id_9,'(]',1,7) -
        INSTRB(anc_id_9,'(]',1,6) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,7) + 2
       ,LENGTHB(anc_id_9))
)

WHEN anc_id_10 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_10
       ,1
       ,INSTRB(anc_id_10,'(]',1,1) -1)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,1) + 2
       ,INSTRB(anc_id_10,'(]',1,2) -
        INSTRB(anc_id_10,'(]',1,1) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,2) + 2
       ,INSTRB(anc_id_10,'(]',1,3) -
        INSTRB(anc_id_10,'(]',1,2) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,3) + 2
       ,INSTRB(anc_id_10,'(]',1,4) -
        INSTRB(anc_id_10,'(]',1,3) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,4) + 2
       ,INSTRB(anc_id_10,'(]',1,5) -
        INSTRB(anc_id_10,'(]',1,4) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,5) + 2
       ,INSTRB(anc_id_10,'(]',1,6) -
        INSTRB(anc_id_10,'(]',1,5) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,6) + 2
       ,INSTRB(anc_id_10,'(]',1,7) -
        INSTRB(anc_id_10,'(]',1,6) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,7) + 2
       ,LENGTHB(anc_id_10))
)

SELECT  ae_header_id
      , anc_id_1
      , anc_id_2
      , anc_id_3
      , anc_id_4
      , anc_id_5
      , anc_id_6
      , anc_id_7
      , anc_id_8
      , anc_id_9
      , anc_id_10
 FROM  xla_ae_headers_gt
WHERE  ae_header_id is not null;

--
IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# header analytical criteria inserted into xla_ae_header_acs = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
END IF;

--
EXCEPTION
WHEN OTHERS THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => sqlerrm
                                    );
END;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of InsertHdrAnalyticalCriteria10'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertHdrAnalyticalCriteria10');
   --
END InsertHdrAnalyticalCriteria10;

--
/*======================================================================+
|                                                                       |
| Insert Header Analytical Criteria 50                                  |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertHdrAnalyticalCriteria50
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertHdrAnalyticalCriteria50';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertHdrAnalyticalCriteria50'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_header_acs'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;
--

INSERT ALL
WHEN anc_id_1 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_1
       ,1
       ,INSTRB(anc_id_1,'(]',1,1) -1)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,1) + 2
       ,INSTRB(anc_id_1,'(]',1,2) -
        INSTRB(anc_id_1,'(]',1,1) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,2) + 2
       ,INSTRB(anc_id_1,'(]',1,3) -
        INSTRB(anc_id_1,'(]',1,2) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,3) + 2
       ,INSTRB(anc_id_1,'(]',1,4) -
        INSTRB(anc_id_1,'(]',1,3) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,4) + 2
       ,INSTRB(anc_id_1,'(]',1,5) -
        INSTRB(anc_id_1,'(]',1,4) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,5) + 2
       ,INSTRB(anc_id_1,'(]',1,6) -
        INSTRB(anc_id_1,'(]',1,5) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,6) + 2
       ,INSTRB(anc_id_1,'(]',1,7) -
        INSTRB(anc_id_1,'(]',1,6) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,7) + 2
       ,LENGTHB(anc_id_1))
)

WHEN anc_id_2 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_2
       ,1
       ,INSTRB(anc_id_2,'(]',1,1) -1)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,1) + 2
       ,INSTRB(anc_id_2,'(]',1,2) -
        INSTRB(anc_id_2,'(]',1,1) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,2) + 2
       ,INSTRB(anc_id_2,'(]',1,3) -
        INSTRB(anc_id_2,'(]',1,2) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,3) + 2
       ,INSTRB(anc_id_2,'(]',1,4) -
        INSTRB(anc_id_2,'(]',1,3) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,4) + 2
       ,INSTRB(anc_id_2,'(]',1,5) -
        INSTRB(anc_id_2,'(]',1,4) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,5) + 2
       ,INSTRB(anc_id_2,'(]',1,6) -
        INSTRB(anc_id_2,'(]',1,5) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,6) + 2
       ,INSTRB(anc_id_2,'(]',1,7) -
        INSTRB(anc_id_2,'(]',1,6) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,7) + 2
       ,LENGTHB(anc_id_2))
)

WHEN anc_id_3 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_3
       ,1
       ,INSTRB(anc_id_3,'(]',1,1) -1)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,1) + 2
       ,INSTRB(anc_id_3,'(]',1,2) -
        INSTRB(anc_id_3,'(]',1,1) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,2) + 2
       ,INSTRB(anc_id_3,'(]',1,3) -
        INSTRB(anc_id_3,'(]',1,2) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,3) + 2
       ,INSTRB(anc_id_3,'(]',1,4) -
        INSTRB(anc_id_3,'(]',1,3) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,4) + 2
       ,INSTRB(anc_id_3,'(]',1,5) -
        INSTRB(anc_id_3,'(]',1,4) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,5) + 2
       ,INSTRB(anc_id_3,'(]',1,6) -
        INSTRB(anc_id_3,'(]',1,5) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,6) + 2
       ,INSTRB(anc_id_3,'(]',1,7) -
        INSTRB(anc_id_3,'(]',1,6) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,7) + 2
       ,LENGTHB(anc_id_3))
)

WHEN anc_id_4 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_4
       ,1
       ,INSTRB(anc_id_4,'(]',1,1) -1)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,1) + 2
       ,INSTRB(anc_id_4,'(]',1,2) -
        INSTRB(anc_id_4,'(]',1,1) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,2) + 2
       ,INSTRB(anc_id_4,'(]',1,3) -
        INSTRB(anc_id_4,'(]',1,2) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,3) + 2
       ,INSTRB(anc_id_4,'(]',1,4) -
        INSTRB(anc_id_4,'(]',1,3) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,4) + 2
       ,INSTRB(anc_id_4,'(]',1,5) -
        INSTRB(anc_id_4,'(]',1,4) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,5) + 2
       ,INSTRB(anc_id_4,'(]',1,6) -
        INSTRB(anc_id_4,'(]',1,5) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,6) + 2
       ,INSTRB(anc_id_4,'(]',1,7) -
        INSTRB(anc_id_4,'(]',1,6) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,7) + 2
       ,LENGTHB(anc_id_4))
)

WHEN anc_id_5 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_5
       ,1
       ,INSTRB(anc_id_5,'(]',1,1) -1)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,1) + 2
       ,INSTRB(anc_id_5,'(]',1,2) -
        INSTRB(anc_id_5,'(]',1,1) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,2) + 2
       ,INSTRB(anc_id_5,'(]',1,3) -
        INSTRB(anc_id_5,'(]',1,2) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,3) + 2
       ,INSTRB(anc_id_5,'(]',1,4) -
        INSTRB(anc_id_5,'(]',1,3) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,4) + 2
       ,INSTRB(anc_id_5,'(]',1,5) -
        INSTRB(anc_id_5,'(]',1,4) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,5) + 2
       ,INSTRB(anc_id_5,'(]',1,6) -
        INSTRB(anc_id_5,'(]',1,5) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,6) + 2
       ,INSTRB(anc_id_5,'(]',1,7) -
        INSTRB(anc_id_5,'(]',1,6) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,7) + 2
       ,LENGTHB(anc_id_5))
)

WHEN anc_id_6 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_6
       ,1
       ,INSTRB(anc_id_6,'(]',1,1) -1)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,1) + 2
       ,INSTRB(anc_id_6,'(]',1,2) -
        INSTRB(anc_id_6,'(]',1,1) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,2) + 2
       ,INSTRB(anc_id_6,'(]',1,3) -
        INSTRB(anc_id_6,'(]',1,2) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,3) + 2
       ,INSTRB(anc_id_6,'(]',1,4) -
        INSTRB(anc_id_6,'(]',1,3) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,4) + 2
       ,INSTRB(anc_id_6,'(]',1,5) -
        INSTRB(anc_id_6,'(]',1,4) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,5) + 2
       ,INSTRB(anc_id_6,'(]',1,6) -
        INSTRB(anc_id_6,'(]',1,5) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,6) + 2
       ,INSTRB(anc_id_6,'(]',1,7) -
        INSTRB(anc_id_6,'(]',1,6) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,7) + 2
       ,LENGTHB(anc_id_6))
)

WHEN anc_id_7 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_7
       ,1
       ,INSTRB(anc_id_7,'(]',1,1) -1)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,1) + 2
       ,INSTRB(anc_id_7,'(]',1,2) -
        INSTRB(anc_id_7,'(]',1,1) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,2) + 2
       ,INSTRB(anc_id_7,'(]',1,3) -
        INSTRB(anc_id_7,'(]',1,2) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,3) + 2
       ,INSTRB(anc_id_7,'(]',1,4) -
        INSTRB(anc_id_7,'(]',1,3) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,4) + 2
       ,INSTRB(anc_id_7,'(]',1,5) -
        INSTRB(anc_id_7,'(]',1,4) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,5) + 2
       ,INSTRB(anc_id_7,'(]',1,6) -
        INSTRB(anc_id_7,'(]',1,5) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,6) + 2
       ,INSTRB(anc_id_7,'(]',1,7) -
        INSTRB(anc_id_7,'(]',1,6) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,7) + 2
       ,LENGTHB(anc_id_7))
)

WHEN anc_id_8 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_8
       ,1
       ,INSTRB(anc_id_8,'(]',1,1) -1)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,1) + 2
       ,INSTRB(anc_id_8,'(]',1,2) -
        INSTRB(anc_id_8,'(]',1,1) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,2) + 2
       ,INSTRB(anc_id_8,'(]',1,3) -
        INSTRB(anc_id_8,'(]',1,2) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,3) + 2
       ,INSTRB(anc_id_8,'(]',1,4) -
        INSTRB(anc_id_8,'(]',1,3) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,4) + 2
       ,INSTRB(anc_id_8,'(]',1,5) -
        INSTRB(anc_id_8,'(]',1,4) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,5) + 2
       ,INSTRB(anc_id_8,'(]',1,6) -
        INSTRB(anc_id_8,'(]',1,5) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,6) + 2
       ,INSTRB(anc_id_8,'(]',1,7) -
        INSTRB(anc_id_8,'(]',1,6) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,7) + 2
       ,LENGTHB(anc_id_8))
)

WHEN anc_id_9 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_9
       ,1
       ,INSTRB(anc_id_9,'(]',1,1) -1)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,1) + 2
       ,INSTRB(anc_id_9,'(]',1,2) -
        INSTRB(anc_id_9,'(]',1,1) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,2) + 2
       ,INSTRB(anc_id_9,'(]',1,3) -
        INSTRB(anc_id_9,'(]',1,2) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,3) + 2
       ,INSTRB(anc_id_9,'(]',1,4) -
        INSTRB(anc_id_9,'(]',1,3) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,4) + 2
       ,INSTRB(anc_id_9,'(]',1,5) -
        INSTRB(anc_id_9,'(]',1,4) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,5) + 2
       ,INSTRB(anc_id_9,'(]',1,6) -
        INSTRB(anc_id_9,'(]',1,5) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,6) + 2
       ,INSTRB(anc_id_9,'(]',1,7) -
        INSTRB(anc_id_9,'(]',1,6) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,7) + 2
       ,LENGTHB(anc_id_9))
)

WHEN anc_id_10 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_10
       ,1
       ,INSTRB(anc_id_10,'(]',1,1) -1)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,1) + 2
       ,INSTRB(anc_id_10,'(]',1,2) -
        INSTRB(anc_id_10,'(]',1,1) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,2) + 2
       ,INSTRB(anc_id_10,'(]',1,3) -
        INSTRB(anc_id_10,'(]',1,2) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,3) + 2
       ,INSTRB(anc_id_10,'(]',1,4) -
        INSTRB(anc_id_10,'(]',1,3) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,4) + 2
       ,INSTRB(anc_id_10,'(]',1,5) -
        INSTRB(anc_id_10,'(]',1,4) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,5) + 2
       ,INSTRB(anc_id_10,'(]',1,6) -
        INSTRB(anc_id_10,'(]',1,5) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,6) + 2
       ,INSTRB(anc_id_10,'(]',1,7) -
        INSTRB(anc_id_10,'(]',1,6) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,7) + 2
       ,LENGTHB(anc_id_10))
)

WHEN anc_id_11 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_11
       ,1
       ,INSTRB(anc_id_11,'(]',1,1) -1)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,1) + 2
       ,INSTRB(anc_id_11,'(]',1,2) -
        INSTRB(anc_id_11,'(]',1,1) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,2) + 2
       ,INSTRB(anc_id_11,'(]',1,3) -
        INSTRB(anc_id_11,'(]',1,2) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,3) + 2
       ,INSTRB(anc_id_11,'(]',1,4) -
        INSTRB(anc_id_11,'(]',1,3) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,4) + 2
       ,INSTRB(anc_id_11,'(]',1,5) -
        INSTRB(anc_id_11,'(]',1,4) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,5) + 2
       ,INSTRB(anc_id_11,'(]',1,6) -
        INSTRB(anc_id_11,'(]',1,5) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,6) + 2
       ,INSTRB(anc_id_11,'(]',1,7) -
        INSTRB(anc_id_11,'(]',1,6) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,7) + 2
       ,LENGTHB(anc_id_11))
)

WHEN anc_id_12 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_12
       ,1
       ,INSTRB(anc_id_12,'(]',1,1) -1)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,1) + 2
       ,INSTRB(anc_id_12,'(]',1,2) -
        INSTRB(anc_id_12,'(]',1,1) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,2) + 2
       ,INSTRB(anc_id_12,'(]',1,3) -
        INSTRB(anc_id_12,'(]',1,2) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,3) + 2
       ,INSTRB(anc_id_12,'(]',1,4) -
        INSTRB(anc_id_12,'(]',1,3) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,4) + 2
       ,INSTRB(anc_id_12,'(]',1,5) -
        INSTRB(anc_id_12,'(]',1,4) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,5) + 2
       ,INSTRB(anc_id_12,'(]',1,6) -
        INSTRB(anc_id_12,'(]',1,5) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,6) + 2
       ,INSTRB(anc_id_12,'(]',1,7) -
        INSTRB(anc_id_12,'(]',1,6) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,7) + 2
       ,LENGTHB(anc_id_12))
)

WHEN anc_id_13 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_13
       ,1
       ,INSTRB(anc_id_13,'(]',1,1) -1)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,1) + 2
       ,INSTRB(anc_id_13,'(]',1,2) -
        INSTRB(anc_id_13,'(]',1,1) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,2) + 2
       ,INSTRB(anc_id_13,'(]',1,3) -
        INSTRB(anc_id_13,'(]',1,2) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,3) + 2
       ,INSTRB(anc_id_13,'(]',1,4) -
        INSTRB(anc_id_13,'(]',1,3) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,4) + 2
       ,INSTRB(anc_id_13,'(]',1,5) -
        INSTRB(anc_id_13,'(]',1,4) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,5) + 2
       ,INSTRB(anc_id_13,'(]',1,6) -
        INSTRB(anc_id_13,'(]',1,5) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,6) + 2
       ,INSTRB(anc_id_13,'(]',1,7) -
        INSTRB(anc_id_13,'(]',1,6) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,7) + 2
       ,LENGTHB(anc_id_13))
)

WHEN anc_id_14 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_14
       ,1
       ,INSTRB(anc_id_14,'(]',1,1) -1)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,1) + 2
       ,INSTRB(anc_id_14,'(]',1,2) -
        INSTRB(anc_id_14,'(]',1,1) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,2) + 2
       ,INSTRB(anc_id_14,'(]',1,3) -
        INSTRB(anc_id_14,'(]',1,2) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,3) + 2
       ,INSTRB(anc_id_14,'(]',1,4) -
        INSTRB(anc_id_14,'(]',1,3) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,4) + 2
       ,INSTRB(anc_id_14,'(]',1,5) -
        INSTRB(anc_id_14,'(]',1,4) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,5) + 2
       ,INSTRB(anc_id_14,'(]',1,6) -
        INSTRB(anc_id_14,'(]',1,5) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,6) + 2
       ,INSTRB(anc_id_14,'(]',1,7) -
        INSTRB(anc_id_14,'(]',1,6) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,7) + 2
       ,LENGTHB(anc_id_14))
)

WHEN anc_id_15 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_15
       ,1
       ,INSTRB(anc_id_15,'(]',1,1) -1)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,1) + 2
       ,INSTRB(anc_id_15,'(]',1,2) -
        INSTRB(anc_id_15,'(]',1,1) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,2) + 2
       ,INSTRB(anc_id_15,'(]',1,3) -
        INSTRB(anc_id_15,'(]',1,2) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,3) + 2
       ,INSTRB(anc_id_15,'(]',1,4) -
        INSTRB(anc_id_15,'(]',1,3) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,4) + 2
       ,INSTRB(anc_id_15,'(]',1,5) -
        INSTRB(anc_id_15,'(]',1,4) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,5) + 2
       ,INSTRB(anc_id_15,'(]',1,6) -
        INSTRB(anc_id_15,'(]',1,5) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,6) + 2
       ,INSTRB(anc_id_15,'(]',1,7) -
        INSTRB(anc_id_15,'(]',1,6) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,7) + 2
       ,LENGTHB(anc_id_15))
)

WHEN anc_id_16 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_16
       ,1
       ,INSTRB(anc_id_16,'(]',1,1) -1)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,1) + 2
       ,INSTRB(anc_id_16,'(]',1,2) -
        INSTRB(anc_id_16,'(]',1,1) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,2) + 2
       ,INSTRB(anc_id_16,'(]',1,3) -
        INSTRB(anc_id_16,'(]',1,2) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,3) + 2
       ,INSTRB(anc_id_16,'(]',1,4) -
        INSTRB(anc_id_16,'(]',1,3) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,4) + 2
       ,INSTRB(anc_id_16,'(]',1,5) -
        INSTRB(anc_id_16,'(]',1,4) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,5) + 2
       ,INSTRB(anc_id_16,'(]',1,6) -
        INSTRB(anc_id_16,'(]',1,5) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,6) + 2
       ,INSTRB(anc_id_16,'(]',1,7) -
        INSTRB(anc_id_16,'(]',1,6) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,7) + 2
       ,LENGTHB(anc_id_16))
)

WHEN anc_id_17 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_17
       ,1
       ,INSTRB(anc_id_17,'(]',1,1) -1)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,1) + 2
       ,INSTRB(anc_id_17,'(]',1,2) -
        INSTRB(anc_id_17,'(]',1,1) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,2) + 2
       ,INSTRB(anc_id_17,'(]',1,3) -
        INSTRB(anc_id_17,'(]',1,2) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,3) + 2
       ,INSTRB(anc_id_17,'(]',1,4) -
        INSTRB(anc_id_17,'(]',1,3) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,4) + 2
       ,INSTRB(anc_id_17,'(]',1,5) -
        INSTRB(anc_id_17,'(]',1,4) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,5) + 2
       ,INSTRB(anc_id_17,'(]',1,6) -
        INSTRB(anc_id_17,'(]',1,5) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,6) + 2
       ,INSTRB(anc_id_17,'(]',1,7) -
        INSTRB(anc_id_17,'(]',1,6) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,7) + 2
       ,LENGTHB(anc_id_17))
)

WHEN anc_id_18 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_18
       ,1
       ,INSTRB(anc_id_18,'(]',1,1) -1)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,1) + 2
       ,INSTRB(anc_id_18,'(]',1,2) -
        INSTRB(anc_id_18,'(]',1,1) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,2) + 2
       ,INSTRB(anc_id_18,'(]',1,3) -
        INSTRB(anc_id_18,'(]',1,2) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,3) + 2
       ,INSTRB(anc_id_18,'(]',1,4) -
        INSTRB(anc_id_18,'(]',1,3) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,4) + 2
       ,INSTRB(anc_id_18,'(]',1,5) -
        INSTRB(anc_id_18,'(]',1,4) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,5) + 2
       ,INSTRB(anc_id_18,'(]',1,6) -
        INSTRB(anc_id_18,'(]',1,5) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,6) + 2
       ,INSTRB(anc_id_18,'(]',1,7) -
        INSTRB(anc_id_18,'(]',1,6) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,7) + 2
       ,LENGTHB(anc_id_18))
)

WHEN anc_id_19 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_19
       ,1
       ,INSTRB(anc_id_19,'(]',1,1) -1)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,1) + 2
       ,INSTRB(anc_id_19,'(]',1,2) -
        INSTRB(anc_id_19,'(]',1,1) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,2) + 2
       ,INSTRB(anc_id_19,'(]',1,3) -
        INSTRB(anc_id_19,'(]',1,2) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,3) + 2
       ,INSTRB(anc_id_19,'(]',1,4) -
        INSTRB(anc_id_19,'(]',1,3) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,4) + 2
       ,INSTRB(anc_id_19,'(]',1,5) -
        INSTRB(anc_id_19,'(]',1,4) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,5) + 2
       ,INSTRB(anc_id_19,'(]',1,6) -
        INSTRB(anc_id_19,'(]',1,5) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,6) + 2
       ,INSTRB(anc_id_19,'(]',1,7) -
        INSTRB(anc_id_19,'(]',1,6) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,7) + 2
       ,LENGTHB(anc_id_19))
)

WHEN anc_id_20 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_20
       ,1
       ,INSTRB(anc_id_20,'(]',1,1) -1)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,1) + 2
       ,INSTRB(anc_id_20,'(]',1,2) -
        INSTRB(anc_id_20,'(]',1,1) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,2) + 2
       ,INSTRB(anc_id_20,'(]',1,3) -
        INSTRB(anc_id_20,'(]',1,2) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,3) + 2
       ,INSTRB(anc_id_20,'(]',1,4) -
        INSTRB(anc_id_20,'(]',1,3) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,4) + 2
       ,INSTRB(anc_id_20,'(]',1,5) -
        INSTRB(anc_id_20,'(]',1,4) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,5) + 2
       ,INSTRB(anc_id_20,'(]',1,6) -
        INSTRB(anc_id_20,'(]',1,5) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,6) + 2
       ,INSTRB(anc_id_20,'(]',1,7) -
        INSTRB(anc_id_20,'(]',1,6) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,7) + 2
       ,LENGTHB(anc_id_20))
)

WHEN anc_id_21 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_21
       ,1
       ,INSTRB(anc_id_21,'(]',1,1) -1)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,1) + 2
       ,INSTRB(anc_id_21,'(]',1,2) -
        INSTRB(anc_id_21,'(]',1,1) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,2) + 2
       ,INSTRB(anc_id_21,'(]',1,3) -
        INSTRB(anc_id_21,'(]',1,2) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,3) + 2
       ,INSTRB(anc_id_21,'(]',1,4) -
        INSTRB(anc_id_21,'(]',1,3) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,4) + 2
       ,INSTRB(anc_id_21,'(]',1,5) -
        INSTRB(anc_id_21,'(]',1,4) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,5) + 2
       ,INSTRB(anc_id_21,'(]',1,6) -
        INSTRB(anc_id_21,'(]',1,5) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,6) + 2
       ,INSTRB(anc_id_21,'(]',1,7) -
        INSTRB(anc_id_21,'(]',1,6) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,7) + 2
       ,LENGTHB(anc_id_21))
)

WHEN anc_id_22 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_22
       ,1
       ,INSTRB(anc_id_22,'(]',1,1) -1)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,1) + 2
       ,INSTRB(anc_id_22,'(]',1,2) -
        INSTRB(anc_id_22,'(]',1,1) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,2) + 2
       ,INSTRB(anc_id_22,'(]',1,3) -
        INSTRB(anc_id_22,'(]',1,2) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,3) + 2
       ,INSTRB(anc_id_22,'(]',1,4) -
        INSTRB(anc_id_22,'(]',1,3) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,4) + 2
       ,INSTRB(anc_id_22,'(]',1,5) -
        INSTRB(anc_id_22,'(]',1,4) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,5) + 2
       ,INSTRB(anc_id_22,'(]',1,6) -
        INSTRB(anc_id_22,'(]',1,5) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,6) + 2
       ,INSTRB(anc_id_22,'(]',1,7) -
        INSTRB(anc_id_22,'(]',1,6) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,7) + 2
       ,LENGTHB(anc_id_22))
)

WHEN anc_id_23 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_23
       ,1
       ,INSTRB(anc_id_23,'(]',1,1) -1)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,1) + 2
       ,INSTRB(anc_id_23,'(]',1,2) -
        INSTRB(anc_id_23,'(]',1,1) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,2) + 2
       ,INSTRB(anc_id_23,'(]',1,3) -
        INSTRB(anc_id_23,'(]',1,2) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,3) + 2
       ,INSTRB(anc_id_23,'(]',1,4) -
        INSTRB(anc_id_23,'(]',1,3) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,4) + 2
       ,INSTRB(anc_id_23,'(]',1,5) -
        INSTRB(anc_id_23,'(]',1,4) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,5) + 2
       ,INSTRB(anc_id_23,'(]',1,6) -
        INSTRB(anc_id_23,'(]',1,5) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,6) + 2
       ,INSTRB(anc_id_23,'(]',1,7) -
        INSTRB(anc_id_23,'(]',1,6) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,7) + 2
       ,LENGTHB(anc_id_23))
)

WHEN anc_id_24 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_24
       ,1
       ,INSTRB(anc_id_24,'(]',1,1) -1)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,1) + 2
       ,INSTRB(anc_id_24,'(]',1,2) -
        INSTRB(anc_id_24,'(]',1,1) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,2) + 2
       ,INSTRB(anc_id_24,'(]',1,3) -
        INSTRB(anc_id_24,'(]',1,2) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,3) + 2
       ,INSTRB(anc_id_24,'(]',1,4) -
        INSTRB(anc_id_24,'(]',1,3) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,4) + 2
       ,INSTRB(anc_id_24,'(]',1,5) -
        INSTRB(anc_id_24,'(]',1,4) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,5) + 2
       ,INSTRB(anc_id_24,'(]',1,6) -
        INSTRB(anc_id_24,'(]',1,5) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,6) + 2
       ,INSTRB(anc_id_24,'(]',1,7) -
        INSTRB(anc_id_24,'(]',1,6) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,7) + 2
       ,LENGTHB(anc_id_24))
)

WHEN anc_id_25 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_25
       ,1
       ,INSTRB(anc_id_25,'(]',1,1) -1)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,1) + 2
       ,INSTRB(anc_id_25,'(]',1,2) -
        INSTRB(anc_id_25,'(]',1,1) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,2) + 2
       ,INSTRB(anc_id_25,'(]',1,3) -
        INSTRB(anc_id_25,'(]',1,2) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,3) + 2
       ,INSTRB(anc_id_25,'(]',1,4) -
        INSTRB(anc_id_25,'(]',1,3) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,4) + 2
       ,INSTRB(anc_id_25,'(]',1,5) -
        INSTRB(anc_id_25,'(]',1,4) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,5) + 2
       ,INSTRB(anc_id_25,'(]',1,6) -
        INSTRB(anc_id_25,'(]',1,5) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,6) + 2
       ,INSTRB(anc_id_25,'(]',1,7) -
        INSTRB(anc_id_25,'(]',1,6) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,7) + 2
       ,LENGTHB(anc_id_25))
)

WHEN anc_id_26 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_26
       ,1
       ,INSTRB(anc_id_26,'(]',1,1) -1)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,1) + 2
       ,INSTRB(anc_id_26,'(]',1,2) -
        INSTRB(anc_id_26,'(]',1,1) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,2) + 2
       ,INSTRB(anc_id_26,'(]',1,3) -
        INSTRB(anc_id_26,'(]',1,2) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,3) + 2
       ,INSTRB(anc_id_26,'(]',1,4) -
        INSTRB(anc_id_26,'(]',1,3) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,4) + 2
       ,INSTRB(anc_id_26,'(]',1,5) -
        INSTRB(anc_id_26,'(]',1,4) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,5) + 2
       ,INSTRB(anc_id_26,'(]',1,6) -
        INSTRB(anc_id_26,'(]',1,5) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,6) + 2
       ,INSTRB(anc_id_26,'(]',1,7) -
        INSTRB(anc_id_26,'(]',1,6) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,7) + 2
       ,LENGTHB(anc_id_26))
)

WHEN anc_id_27 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_27
       ,1
       ,INSTRB(anc_id_27,'(]',1,1) -1)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,1) + 2
       ,INSTRB(anc_id_27,'(]',1,2) -
        INSTRB(anc_id_27,'(]',1,1) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,2) + 2
       ,INSTRB(anc_id_27,'(]',1,3) -
        INSTRB(anc_id_27,'(]',1,2) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,3) + 2
       ,INSTRB(anc_id_27,'(]',1,4) -
        INSTRB(anc_id_27,'(]',1,3) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,4) + 2
       ,INSTRB(anc_id_27,'(]',1,5) -
        INSTRB(anc_id_27,'(]',1,4) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,5) + 2
       ,INSTRB(anc_id_27,'(]',1,6) -
        INSTRB(anc_id_27,'(]',1,5) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,6) + 2
       ,INSTRB(anc_id_27,'(]',1,7) -
        INSTRB(anc_id_27,'(]',1,6) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,7) + 2
       ,LENGTHB(anc_id_27))
)

WHEN anc_id_28 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_28
       ,1
       ,INSTRB(anc_id_28,'(]',1,1) -1)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,1) + 2
       ,INSTRB(anc_id_28,'(]',1,2) -
        INSTRB(anc_id_28,'(]',1,1) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,2) + 2
       ,INSTRB(anc_id_28,'(]',1,3) -
        INSTRB(anc_id_28,'(]',1,2) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,3) + 2
       ,INSTRB(anc_id_28,'(]',1,4) -
        INSTRB(anc_id_28,'(]',1,3) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,4) + 2
       ,INSTRB(anc_id_28,'(]',1,5) -
        INSTRB(anc_id_28,'(]',1,4) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,5) + 2
       ,INSTRB(anc_id_28,'(]',1,6) -
        INSTRB(anc_id_28,'(]',1,5) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,6) + 2
       ,INSTRB(anc_id_28,'(]',1,7) -
        INSTRB(anc_id_28,'(]',1,6) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,7) + 2
       ,LENGTHB(anc_id_28))
)

WHEN anc_id_29 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_29
       ,1
       ,INSTRB(anc_id_29,'(]',1,1) -1)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,1) + 2
       ,INSTRB(anc_id_29,'(]',1,2) -
        INSTRB(anc_id_29,'(]',1,1) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,2) + 2
       ,INSTRB(anc_id_29,'(]',1,3) -
        INSTRB(anc_id_29,'(]',1,2) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,3) + 2
       ,INSTRB(anc_id_29,'(]',1,4) -
        INSTRB(anc_id_29,'(]',1,3) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,4) + 2
       ,INSTRB(anc_id_29,'(]',1,5) -
        INSTRB(anc_id_29,'(]',1,4) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,5) + 2
       ,INSTRB(anc_id_29,'(]',1,6) -
        INSTRB(anc_id_29,'(]',1,5) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,6) + 2
       ,INSTRB(anc_id_29,'(]',1,7) -
        INSTRB(anc_id_29,'(]',1,6) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,7) + 2
       ,LENGTHB(anc_id_29))
)

WHEN anc_id_30 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_30
       ,1
       ,INSTRB(anc_id_30,'(]',1,1) -1)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,1) + 2
       ,INSTRB(anc_id_30,'(]',1,2) -
        INSTRB(anc_id_30,'(]',1,1) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,2) + 2
       ,INSTRB(anc_id_30,'(]',1,3) -
        INSTRB(anc_id_30,'(]',1,2) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,3) + 2
       ,INSTRB(anc_id_30,'(]',1,4) -
        INSTRB(anc_id_30,'(]',1,3) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,4) + 2
       ,INSTRB(anc_id_30,'(]',1,5) -
        INSTRB(anc_id_30,'(]',1,4) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,5) + 2
       ,INSTRB(anc_id_30,'(]',1,6) -
        INSTRB(anc_id_30,'(]',1,5) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,6) + 2
       ,INSTRB(anc_id_30,'(]',1,7) -
        INSTRB(anc_id_30,'(]',1,6) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,7) + 2
       ,LENGTHB(anc_id_30))
)

WHEN anc_id_31 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_31
       ,1
       ,INSTRB(anc_id_31,'(]',1,1) -1)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,1) + 2
       ,INSTRB(anc_id_31,'(]',1,2) -
        INSTRB(anc_id_31,'(]',1,1) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,2) + 2
       ,INSTRB(anc_id_31,'(]',1,3) -
        INSTRB(anc_id_31,'(]',1,2) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,3) + 2
       ,INSTRB(anc_id_31,'(]',1,4) -
        INSTRB(anc_id_31,'(]',1,3) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,4) + 2
       ,INSTRB(anc_id_31,'(]',1,5) -
        INSTRB(anc_id_31,'(]',1,4) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,5) + 2
       ,INSTRB(anc_id_31,'(]',1,6) -
        INSTRB(anc_id_31,'(]',1,5) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,6) + 2
       ,INSTRB(anc_id_31,'(]',1,7) -
        INSTRB(anc_id_31,'(]',1,6) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,7) + 2
       ,LENGTHB(anc_id_31))
)

WHEN anc_id_32 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_32
       ,1
       ,INSTRB(anc_id_32,'(]',1,1) -1)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,1) + 2
       ,INSTRB(anc_id_32,'(]',1,2) -
        INSTRB(anc_id_32,'(]',1,1) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,2) + 2
       ,INSTRB(anc_id_32,'(]',1,3) -
        INSTRB(anc_id_32,'(]',1,2) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,3) + 2
       ,INSTRB(anc_id_32,'(]',1,4) -
        INSTRB(anc_id_32,'(]',1,3) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,4) + 2
       ,INSTRB(anc_id_32,'(]',1,5) -
        INSTRB(anc_id_32,'(]',1,4) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,5) + 2
       ,INSTRB(anc_id_32,'(]',1,6) -
        INSTRB(anc_id_32,'(]',1,5) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,6) + 2
       ,INSTRB(anc_id_32,'(]',1,7) -
        INSTRB(anc_id_32,'(]',1,6) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,7) + 2
       ,LENGTHB(anc_id_32))
)

WHEN anc_id_33 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_33
       ,1
       ,INSTRB(anc_id_33,'(]',1,1) -1)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,1) + 2
       ,INSTRB(anc_id_33,'(]',1,2) -
        INSTRB(anc_id_33,'(]',1,1) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,2) + 2
       ,INSTRB(anc_id_33,'(]',1,3) -
        INSTRB(anc_id_33,'(]',1,2) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,3) + 2
       ,INSTRB(anc_id_33,'(]',1,4) -
        INSTRB(anc_id_33,'(]',1,3) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,4) + 2
       ,INSTRB(anc_id_33,'(]',1,5) -
        INSTRB(anc_id_33,'(]',1,4) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,5) + 2
       ,INSTRB(anc_id_33,'(]',1,6) -
        INSTRB(anc_id_33,'(]',1,5) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,6) + 2
       ,INSTRB(anc_id_33,'(]',1,7) -
        INSTRB(anc_id_33,'(]',1,6) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,7) + 2
       ,LENGTHB(anc_id_33))
)

WHEN anc_id_34 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_34
       ,1
       ,INSTRB(anc_id_34,'(]',1,1) -1)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,1) + 2
       ,INSTRB(anc_id_34,'(]',1,2) -
        INSTRB(anc_id_34,'(]',1,1) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,2) + 2
       ,INSTRB(anc_id_34,'(]',1,3) -
        INSTRB(anc_id_34,'(]',1,2) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,3) + 2
       ,INSTRB(anc_id_34,'(]',1,4) -
        INSTRB(anc_id_34,'(]',1,3) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,4) + 2
       ,INSTRB(anc_id_34,'(]',1,5) -
        INSTRB(anc_id_34,'(]',1,4) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,5) + 2
       ,INSTRB(anc_id_34,'(]',1,6) -
        INSTRB(anc_id_34,'(]',1,5) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,6) + 2
       ,INSTRB(anc_id_34,'(]',1,7) -
        INSTRB(anc_id_34,'(]',1,6) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,7) + 2
       ,LENGTHB(anc_id_34))
)

WHEN anc_id_35 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_35
       ,1
       ,INSTRB(anc_id_35,'(]',1,1) -1)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,1) + 2
       ,INSTRB(anc_id_35,'(]',1,2) -
        INSTRB(anc_id_35,'(]',1,1) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,2) + 2
       ,INSTRB(anc_id_35,'(]',1,3) -
        INSTRB(anc_id_35,'(]',1,2) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,3) + 2
       ,INSTRB(anc_id_35,'(]',1,4) -
        INSTRB(anc_id_35,'(]',1,3) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,4) + 2
       ,INSTRB(anc_id_35,'(]',1,5) -
        INSTRB(anc_id_35,'(]',1,4) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,5) + 2
       ,INSTRB(anc_id_35,'(]',1,6) -
        INSTRB(anc_id_35,'(]',1,5) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,6) + 2
       ,INSTRB(anc_id_35,'(]',1,7) -
        INSTRB(anc_id_35,'(]',1,6) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,7) + 2
       ,LENGTHB(anc_id_35))
)

WHEN anc_id_36 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_36
       ,1
       ,INSTRB(anc_id_36,'(]',1,1) -1)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,1) + 2
       ,INSTRB(anc_id_36,'(]',1,2) -
        INSTRB(anc_id_36,'(]',1,1) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,2) + 2
       ,INSTRB(anc_id_36,'(]',1,3) -
        INSTRB(anc_id_36,'(]',1,2) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,3) + 2
       ,INSTRB(anc_id_36,'(]',1,4) -
        INSTRB(anc_id_36,'(]',1,3) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,4) + 2
       ,INSTRB(anc_id_36,'(]',1,5) -
        INSTRB(anc_id_36,'(]',1,4) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,5) + 2
       ,INSTRB(anc_id_36,'(]',1,6) -
        INSTRB(anc_id_36,'(]',1,5) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,6) + 2
       ,INSTRB(anc_id_36,'(]',1,7) -
        INSTRB(anc_id_36,'(]',1,6) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,7) + 2
       ,LENGTHB(anc_id_36))
)

WHEN anc_id_37 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_37
       ,1
       ,INSTRB(anc_id_37,'(]',1,1) -1)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,1) + 2
       ,INSTRB(anc_id_37,'(]',1,2) -
        INSTRB(anc_id_37,'(]',1,1) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,2) + 2
       ,INSTRB(anc_id_37,'(]',1,3) -
        INSTRB(anc_id_37,'(]',1,2) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,3) + 2
       ,INSTRB(anc_id_37,'(]',1,4) -
        INSTRB(anc_id_37,'(]',1,3) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,4) + 2
       ,INSTRB(anc_id_37,'(]',1,5) -
        INSTRB(anc_id_37,'(]',1,4) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,5) + 2
       ,INSTRB(anc_id_37,'(]',1,6) -
        INSTRB(anc_id_37,'(]',1,5) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,6) + 2
       ,INSTRB(anc_id_37,'(]',1,7) -
        INSTRB(anc_id_37,'(]',1,6) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,7) + 2
       ,LENGTHB(anc_id_37))
)

WHEN anc_id_38 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_38
       ,1
       ,INSTRB(anc_id_38,'(]',1,1) -1)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,1) + 2
       ,INSTRB(anc_id_38,'(]',1,2) -
        INSTRB(anc_id_38,'(]',1,1) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,2) + 2
       ,INSTRB(anc_id_38,'(]',1,3) -
        INSTRB(anc_id_38,'(]',1,2) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,3) + 2
       ,INSTRB(anc_id_38,'(]',1,4) -
        INSTRB(anc_id_38,'(]',1,3) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,4) + 2
       ,INSTRB(anc_id_38,'(]',1,5) -
        INSTRB(anc_id_38,'(]',1,4) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,5) + 2
       ,INSTRB(anc_id_38,'(]',1,6) -
        INSTRB(anc_id_38,'(]',1,5) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,6) + 2
       ,INSTRB(anc_id_38,'(]',1,7) -
        INSTRB(anc_id_38,'(]',1,6) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,7) + 2
       ,LENGTHB(anc_id_38))
)

WHEN anc_id_39 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_39
       ,1
       ,INSTRB(anc_id_39,'(]',1,1) -1)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,1) + 2
       ,INSTRB(anc_id_39,'(]',1,2) -
        INSTRB(anc_id_39,'(]',1,1) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,2) + 2
       ,INSTRB(anc_id_39,'(]',1,3) -
        INSTRB(anc_id_39,'(]',1,2) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,3) + 2
       ,INSTRB(anc_id_39,'(]',1,4) -
        INSTRB(anc_id_39,'(]',1,3) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,4) + 2
       ,INSTRB(anc_id_39,'(]',1,5) -
        INSTRB(anc_id_39,'(]',1,4) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,5) + 2
       ,INSTRB(anc_id_39,'(]',1,6) -
        INSTRB(anc_id_39,'(]',1,5) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,6) + 2
       ,INSTRB(anc_id_39,'(]',1,7) -
        INSTRB(anc_id_39,'(]',1,6) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,7) + 2
       ,LENGTHB(anc_id_39))
)

WHEN anc_id_40 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_40
       ,1
       ,INSTRB(anc_id_40,'(]',1,1) -1)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,1) + 2
       ,INSTRB(anc_id_40,'(]',1,2) -
        INSTRB(anc_id_40,'(]',1,1) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,2) + 2
       ,INSTRB(anc_id_40,'(]',1,3) -
        INSTRB(anc_id_40,'(]',1,2) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,3) + 2
       ,INSTRB(anc_id_40,'(]',1,4) -
        INSTRB(anc_id_40,'(]',1,3) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,4) + 2
       ,INSTRB(anc_id_40,'(]',1,5) -
        INSTRB(anc_id_40,'(]',1,4) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,5) + 2
       ,INSTRB(anc_id_40,'(]',1,6) -
        INSTRB(anc_id_40,'(]',1,5) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,6) + 2
       ,INSTRB(anc_id_40,'(]',1,7) -
        INSTRB(anc_id_40,'(]',1,6) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,7) + 2
       ,LENGTHB(anc_id_40))
)

WHEN anc_id_41 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_41
       ,1
       ,INSTRB(anc_id_41,'(]',1,1) -1)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,1) + 2
       ,INSTRB(anc_id_41,'(]',1,2) -
        INSTRB(anc_id_41,'(]',1,1) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,2) + 2
       ,INSTRB(anc_id_41,'(]',1,3) -
        INSTRB(anc_id_41,'(]',1,2) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,3) + 2
       ,INSTRB(anc_id_41,'(]',1,4) -
        INSTRB(anc_id_41,'(]',1,3) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,4) + 2
       ,INSTRB(anc_id_41,'(]',1,5) -
        INSTRB(anc_id_41,'(]',1,4) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,5) + 2
       ,INSTRB(anc_id_41,'(]',1,6) -
        INSTRB(anc_id_41,'(]',1,5) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,6) + 2
       ,INSTRB(anc_id_41,'(]',1,7) -
        INSTRB(anc_id_41,'(]',1,6) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,7) + 2
       ,LENGTHB(anc_id_41))
)

WHEN anc_id_42 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_42
       ,1
       ,INSTRB(anc_id_42,'(]',1,1) -1)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,1) + 2
       ,INSTRB(anc_id_42,'(]',1,2) -
        INSTRB(anc_id_42,'(]',1,1) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,2) + 2
       ,INSTRB(anc_id_42,'(]',1,3) -
        INSTRB(anc_id_42,'(]',1,2) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,3) + 2
       ,INSTRB(anc_id_42,'(]',1,4) -
        INSTRB(anc_id_42,'(]',1,3) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,4) + 2
       ,INSTRB(anc_id_42,'(]',1,5) -
        INSTRB(anc_id_42,'(]',1,4) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,5) + 2
       ,INSTRB(anc_id_42,'(]',1,6) -
        INSTRB(anc_id_42,'(]',1,5) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,6) + 2
       ,INSTRB(anc_id_42,'(]',1,7) -
        INSTRB(anc_id_42,'(]',1,6) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,7) + 2
       ,LENGTHB(anc_id_42))
)

WHEN anc_id_43 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_43
       ,1
       ,INSTRB(anc_id_43,'(]',1,1) -1)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,1) + 2
       ,INSTRB(anc_id_43,'(]',1,2) -
        INSTRB(anc_id_43,'(]',1,1) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,2) + 2
       ,INSTRB(anc_id_43,'(]',1,3) -
        INSTRB(anc_id_43,'(]',1,2) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,3) + 2
       ,INSTRB(anc_id_43,'(]',1,4) -
        INSTRB(anc_id_43,'(]',1,3) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,4) + 2
       ,INSTRB(anc_id_43,'(]',1,5) -
        INSTRB(anc_id_43,'(]',1,4) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,5) + 2
       ,INSTRB(anc_id_43,'(]',1,6) -
        INSTRB(anc_id_43,'(]',1,5) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,6) + 2
       ,INSTRB(anc_id_43,'(]',1,7) -
        INSTRB(anc_id_43,'(]',1,6) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,7) + 2
       ,LENGTHB(anc_id_43))
)

WHEN anc_id_44 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_44
       ,1
       ,INSTRB(anc_id_44,'(]',1,1) -1)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,1) + 2
       ,INSTRB(anc_id_44,'(]',1,2) -
        INSTRB(anc_id_44,'(]',1,1) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,2) + 2
       ,INSTRB(anc_id_44,'(]',1,3) -
        INSTRB(anc_id_44,'(]',1,2) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,3) + 2
       ,INSTRB(anc_id_44,'(]',1,4) -
        INSTRB(anc_id_44,'(]',1,3) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,4) + 2
       ,INSTRB(anc_id_44,'(]',1,5) -
        INSTRB(anc_id_44,'(]',1,4) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,5) + 2
       ,INSTRB(anc_id_44,'(]',1,6) -
        INSTRB(anc_id_44,'(]',1,5) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,6) + 2
       ,INSTRB(anc_id_44,'(]',1,7) -
        INSTRB(anc_id_44,'(]',1,6) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,7) + 2
       ,LENGTHB(anc_id_44))
)

WHEN anc_id_45 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_45
       ,1
       ,INSTRB(anc_id_45,'(]',1,1) -1)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,1) + 2
       ,INSTRB(anc_id_45,'(]',1,2) -
        INSTRB(anc_id_45,'(]',1,1) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,2) + 2
       ,INSTRB(anc_id_45,'(]',1,3) -
        INSTRB(anc_id_45,'(]',1,2) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,3) + 2
       ,INSTRB(anc_id_45,'(]',1,4) -
        INSTRB(anc_id_45,'(]',1,3) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,4) + 2
       ,INSTRB(anc_id_45,'(]',1,5) -
        INSTRB(anc_id_45,'(]',1,4) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,5) + 2
       ,INSTRB(anc_id_45,'(]',1,6) -
        INSTRB(anc_id_45,'(]',1,5) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,6) + 2
       ,INSTRB(anc_id_45,'(]',1,7) -
        INSTRB(anc_id_45,'(]',1,6) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,7) + 2
       ,LENGTHB(anc_id_45))
)

WHEN anc_id_46 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_46
       ,1
       ,INSTRB(anc_id_46,'(]',1,1) -1)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,1) + 2
       ,INSTRB(anc_id_46,'(]',1,2) -
        INSTRB(anc_id_46,'(]',1,1) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,2) + 2
       ,INSTRB(anc_id_46,'(]',1,3) -
        INSTRB(anc_id_46,'(]',1,2) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,3) + 2
       ,INSTRB(anc_id_46,'(]',1,4) -
        INSTRB(anc_id_46,'(]',1,3) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,4) + 2
       ,INSTRB(anc_id_46,'(]',1,5) -
        INSTRB(anc_id_46,'(]',1,4) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,5) + 2
       ,INSTRB(anc_id_46,'(]',1,6) -
        INSTRB(anc_id_46,'(]',1,5) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,6) + 2
       ,INSTRB(anc_id_46,'(]',1,7) -
        INSTRB(anc_id_46,'(]',1,6) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,7) + 2
       ,LENGTHB(anc_id_46))
)

WHEN anc_id_47 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_47
       ,1
       ,INSTRB(anc_id_47,'(]',1,1) -1)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,1) + 2
       ,INSTRB(anc_id_47,'(]',1,2) -
        INSTRB(anc_id_47,'(]',1,1) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,2) + 2
       ,INSTRB(anc_id_47,'(]',1,3) -
        INSTRB(anc_id_47,'(]',1,2) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,3) + 2
       ,INSTRB(anc_id_47,'(]',1,4) -
        INSTRB(anc_id_47,'(]',1,3) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,4) + 2
       ,INSTRB(anc_id_47,'(]',1,5) -
        INSTRB(anc_id_47,'(]',1,4) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,5) + 2
       ,INSTRB(anc_id_47,'(]',1,6) -
        INSTRB(anc_id_47,'(]',1,5) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,6) + 2
       ,INSTRB(anc_id_47,'(]',1,7) -
        INSTRB(anc_id_47,'(]',1,6) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,7) + 2
       ,LENGTHB(anc_id_47))
)

WHEN anc_id_48 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_48
       ,1
       ,INSTRB(anc_id_48,'(]',1,1) -1)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,1) + 2
       ,INSTRB(anc_id_48,'(]',1,2) -
        INSTRB(anc_id_48,'(]',1,1) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,2) + 2
       ,INSTRB(anc_id_48,'(]',1,3) -
        INSTRB(anc_id_48,'(]',1,2) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,3) + 2
       ,INSTRB(anc_id_48,'(]',1,4) -
        INSTRB(anc_id_48,'(]',1,3) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,4) + 2
       ,INSTRB(anc_id_48,'(]',1,5) -
        INSTRB(anc_id_48,'(]',1,4) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,5) + 2
       ,INSTRB(anc_id_48,'(]',1,6) -
        INSTRB(anc_id_48,'(]',1,5) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,6) + 2
       ,INSTRB(anc_id_48,'(]',1,7) -
        INSTRB(anc_id_48,'(]',1,6) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,7) + 2
       ,LENGTHB(anc_id_48))
)

WHEN anc_id_49 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_49
       ,1
       ,INSTRB(anc_id_49,'(]',1,1) -1)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,1) + 2
       ,INSTRB(anc_id_49,'(]',1,2) -
        INSTRB(anc_id_49,'(]',1,1) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,2) + 2
       ,INSTRB(anc_id_49,'(]',1,3) -
        INSTRB(anc_id_49,'(]',1,2) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,3) + 2
       ,INSTRB(anc_id_49,'(]',1,4) -
        INSTRB(anc_id_49,'(]',1,3) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,4) + 2
       ,INSTRB(anc_id_49,'(]',1,5) -
        INSTRB(anc_id_49,'(]',1,4) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,5) + 2
       ,INSTRB(anc_id_49,'(]',1,6) -
        INSTRB(anc_id_49,'(]',1,5) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,6) + 2
       ,INSTRB(anc_id_49,'(]',1,7) -
        INSTRB(anc_id_49,'(]',1,6) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,7) + 2
       ,LENGTHB(anc_id_49))
)

WHEN anc_id_50 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_50
       ,1
       ,INSTRB(anc_id_50,'(]',1,1) -1)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,1) + 2
       ,INSTRB(anc_id_50,'(]',1,2) -
        INSTRB(anc_id_50,'(]',1,1) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,2) + 2
       ,INSTRB(anc_id_50,'(]',1,3) -
        INSTRB(anc_id_50,'(]',1,2) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,3) + 2
       ,INSTRB(anc_id_50,'(]',1,4) -
        INSTRB(anc_id_50,'(]',1,3) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,4) + 2
       ,INSTRB(anc_id_50,'(]',1,5) -
        INSTRB(anc_id_50,'(]',1,4) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,5) + 2
       ,INSTRB(anc_id_50,'(]',1,6) -
        INSTRB(anc_id_50,'(]',1,5) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,6) + 2
       ,INSTRB(anc_id_50,'(]',1,7) -
        INSTRB(anc_id_50,'(]',1,6) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,7) + 2
       ,LENGTHB(anc_id_50))
)

SELECT  ae_header_id
      , anc_id_1
      , anc_id_2
      , anc_id_3
      , anc_id_4
      , anc_id_5
      , anc_id_6
      , anc_id_7
      , anc_id_8
      , anc_id_9
      , anc_id_10
      , anc_id_11
      , anc_id_12
      , anc_id_13
      , anc_id_14
      , anc_id_15
      , anc_id_16
      , anc_id_17
      , anc_id_18
      , anc_id_19
      , anc_id_20
      , anc_id_21
      , anc_id_22
      , anc_id_23
      , anc_id_24
      , anc_id_25
      , anc_id_26
      , anc_id_27
      , anc_id_28
      , anc_id_29
      , anc_id_30
      , anc_id_31
      , anc_id_32
      , anc_id_33
      , anc_id_34
      , anc_id_35
      , anc_id_36
      , anc_id_37
      , anc_id_38
      , anc_id_39
      , anc_id_40
      , anc_id_41
      , anc_id_42
      , anc_id_43
      , anc_id_44
      , anc_id_45
      , anc_id_46
      , anc_id_47
      , anc_id_48
      , anc_id_49
      , anc_id_50
 FROM  xla_ae_headers_gt
WHERE  ae_header_id is not null;

--
IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# header analytical criteria inserted into xla_ae_header_acs = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
END IF;

--
EXCEPTION
WHEN OTHERS THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => sqlerrm
                                    );
END;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of InsertHdrAnalyticalCriteria50'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertHdrAnalyticalCriteria50');
   --
END InsertHdrAnalyticalCriteria50;

--
/*======================================================================+
|                                                                       |
| Insert Header Analytical Criteria 100                                 |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE InsertHdrAnalyticalCriteria100
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertHdrAnalyticalCriteria100';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertHdrAnalyticalCriteria100'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
BEGIN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - Insert into xla_ae_header_acs'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;
--

INSERT ALL
WHEN anc_id_1 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_1
       ,1
       ,INSTRB(anc_id_1,'(]',1,1) -1)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,1) + 2
       ,INSTRB(anc_id_1,'(]',1,2) -
        INSTRB(anc_id_1,'(]',1,1) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,2) + 2
       ,INSTRB(anc_id_1,'(]',1,3) -
        INSTRB(anc_id_1,'(]',1,2) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,3) + 2
       ,INSTRB(anc_id_1,'(]',1,4) -
        INSTRB(anc_id_1,'(]',1,3) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,4) + 2
       ,INSTRB(anc_id_1,'(]',1,5) -
        INSTRB(anc_id_1,'(]',1,4) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,5) + 2
       ,INSTRB(anc_id_1,'(]',1,6) -
        INSTRB(anc_id_1,'(]',1,5) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,6) + 2
       ,INSTRB(anc_id_1,'(]',1,7) -
        INSTRB(anc_id_1,'(]',1,6) - 2)
,SUBSTRB(anc_id_1
       ,INSTRB(anc_id_1,'(]',1,7) + 2
       ,LENGTHB(anc_id_1))
)

WHEN anc_id_2 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_2
       ,1
       ,INSTRB(anc_id_2,'(]',1,1) -1)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,1) + 2
       ,INSTRB(anc_id_2,'(]',1,2) -
        INSTRB(anc_id_2,'(]',1,1) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,2) + 2
       ,INSTRB(anc_id_2,'(]',1,3) -
        INSTRB(anc_id_2,'(]',1,2) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,3) + 2
       ,INSTRB(anc_id_2,'(]',1,4) -
        INSTRB(anc_id_2,'(]',1,3) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,4) + 2
       ,INSTRB(anc_id_2,'(]',1,5) -
        INSTRB(anc_id_2,'(]',1,4) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,5) + 2
       ,INSTRB(anc_id_2,'(]',1,6) -
        INSTRB(anc_id_2,'(]',1,5) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,6) + 2
       ,INSTRB(anc_id_2,'(]',1,7) -
        INSTRB(anc_id_2,'(]',1,6) - 2)
,SUBSTRB(anc_id_2
       ,INSTRB(anc_id_2,'(]',1,7) + 2
       ,LENGTHB(anc_id_2))
)

WHEN anc_id_3 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_3
       ,1
       ,INSTRB(anc_id_3,'(]',1,1) -1)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,1) + 2
       ,INSTRB(anc_id_3,'(]',1,2) -
        INSTRB(anc_id_3,'(]',1,1) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,2) + 2
       ,INSTRB(anc_id_3,'(]',1,3) -
        INSTRB(anc_id_3,'(]',1,2) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,3) + 2
       ,INSTRB(anc_id_3,'(]',1,4) -
        INSTRB(anc_id_3,'(]',1,3) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,4) + 2
       ,INSTRB(anc_id_3,'(]',1,5) -
        INSTRB(anc_id_3,'(]',1,4) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,5) + 2
       ,INSTRB(anc_id_3,'(]',1,6) -
        INSTRB(anc_id_3,'(]',1,5) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,6) + 2
       ,INSTRB(anc_id_3,'(]',1,7) -
        INSTRB(anc_id_3,'(]',1,6) - 2)
,SUBSTRB(anc_id_3
       ,INSTRB(anc_id_3,'(]',1,7) + 2
       ,LENGTHB(anc_id_3))
)

WHEN anc_id_4 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_4
       ,1
       ,INSTRB(anc_id_4,'(]',1,1) -1)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,1) + 2
       ,INSTRB(anc_id_4,'(]',1,2) -
        INSTRB(anc_id_4,'(]',1,1) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,2) + 2
       ,INSTRB(anc_id_4,'(]',1,3) -
        INSTRB(anc_id_4,'(]',1,2) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,3) + 2
       ,INSTRB(anc_id_4,'(]',1,4) -
        INSTRB(anc_id_4,'(]',1,3) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,4) + 2
       ,INSTRB(anc_id_4,'(]',1,5) -
        INSTRB(anc_id_4,'(]',1,4) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,5) + 2
       ,INSTRB(anc_id_4,'(]',1,6) -
        INSTRB(anc_id_4,'(]',1,5) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,6) + 2
       ,INSTRB(anc_id_4,'(]',1,7) -
        INSTRB(anc_id_4,'(]',1,6) - 2)
,SUBSTRB(anc_id_4
       ,INSTRB(anc_id_4,'(]',1,7) + 2
       ,LENGTHB(anc_id_4))
)

WHEN anc_id_5 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_5
       ,1
       ,INSTRB(anc_id_5,'(]',1,1) -1)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,1) + 2
       ,INSTRB(anc_id_5,'(]',1,2) -
        INSTRB(anc_id_5,'(]',1,1) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,2) + 2
       ,INSTRB(anc_id_5,'(]',1,3) -
        INSTRB(anc_id_5,'(]',1,2) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,3) + 2
       ,INSTRB(anc_id_5,'(]',1,4) -
        INSTRB(anc_id_5,'(]',1,3) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,4) + 2
       ,INSTRB(anc_id_5,'(]',1,5) -
        INSTRB(anc_id_5,'(]',1,4) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,5) + 2
       ,INSTRB(anc_id_5,'(]',1,6) -
        INSTRB(anc_id_5,'(]',1,5) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,6) + 2
       ,INSTRB(anc_id_5,'(]',1,7) -
        INSTRB(anc_id_5,'(]',1,6) - 2)
,SUBSTRB(anc_id_5
       ,INSTRB(anc_id_5,'(]',1,7) + 2
       ,LENGTHB(anc_id_5))
)

WHEN anc_id_6 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_6
       ,1
       ,INSTRB(anc_id_6,'(]',1,1) -1)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,1) + 2
       ,INSTRB(anc_id_6,'(]',1,2) -
        INSTRB(anc_id_6,'(]',1,1) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,2) + 2
       ,INSTRB(anc_id_6,'(]',1,3) -
        INSTRB(anc_id_6,'(]',1,2) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,3) + 2
       ,INSTRB(anc_id_6,'(]',1,4) -
        INSTRB(anc_id_6,'(]',1,3) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,4) + 2
       ,INSTRB(anc_id_6,'(]',1,5) -
        INSTRB(anc_id_6,'(]',1,4) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,5) + 2
       ,INSTRB(anc_id_6,'(]',1,6) -
        INSTRB(anc_id_6,'(]',1,5) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,6) + 2
       ,INSTRB(anc_id_6,'(]',1,7) -
        INSTRB(anc_id_6,'(]',1,6) - 2)
,SUBSTRB(anc_id_6
       ,INSTRB(anc_id_6,'(]',1,7) + 2
       ,LENGTHB(anc_id_6))
)

WHEN anc_id_7 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_7
       ,1
       ,INSTRB(anc_id_7,'(]',1,1) -1)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,1) + 2
       ,INSTRB(anc_id_7,'(]',1,2) -
        INSTRB(anc_id_7,'(]',1,1) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,2) + 2
       ,INSTRB(anc_id_7,'(]',1,3) -
        INSTRB(anc_id_7,'(]',1,2) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,3) + 2
       ,INSTRB(anc_id_7,'(]',1,4) -
        INSTRB(anc_id_7,'(]',1,3) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,4) + 2
       ,INSTRB(anc_id_7,'(]',1,5) -
        INSTRB(anc_id_7,'(]',1,4) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,5) + 2
       ,INSTRB(anc_id_7,'(]',1,6) -
        INSTRB(anc_id_7,'(]',1,5) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,6) + 2
       ,INSTRB(anc_id_7,'(]',1,7) -
        INSTRB(anc_id_7,'(]',1,6) - 2)
,SUBSTRB(anc_id_7
       ,INSTRB(anc_id_7,'(]',1,7) + 2
       ,LENGTHB(anc_id_7))
)

WHEN anc_id_8 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_8
       ,1
       ,INSTRB(anc_id_8,'(]',1,1) -1)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,1) + 2
       ,INSTRB(anc_id_8,'(]',1,2) -
        INSTRB(anc_id_8,'(]',1,1) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,2) + 2
       ,INSTRB(anc_id_8,'(]',1,3) -
        INSTRB(anc_id_8,'(]',1,2) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,3) + 2
       ,INSTRB(anc_id_8,'(]',1,4) -
        INSTRB(anc_id_8,'(]',1,3) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,4) + 2
       ,INSTRB(anc_id_8,'(]',1,5) -
        INSTRB(anc_id_8,'(]',1,4) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,5) + 2
       ,INSTRB(anc_id_8,'(]',1,6) -
        INSTRB(anc_id_8,'(]',1,5) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,6) + 2
       ,INSTRB(anc_id_8,'(]',1,7) -
        INSTRB(anc_id_8,'(]',1,6) - 2)
,SUBSTRB(anc_id_8
       ,INSTRB(anc_id_8,'(]',1,7) + 2
       ,LENGTHB(anc_id_8))
)

WHEN anc_id_9 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_9
       ,1
       ,INSTRB(anc_id_9,'(]',1,1) -1)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,1) + 2
       ,INSTRB(anc_id_9,'(]',1,2) -
        INSTRB(anc_id_9,'(]',1,1) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,2) + 2
       ,INSTRB(anc_id_9,'(]',1,3) -
        INSTRB(anc_id_9,'(]',1,2) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,3) + 2
       ,INSTRB(anc_id_9,'(]',1,4) -
        INSTRB(anc_id_9,'(]',1,3) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,4) + 2
       ,INSTRB(anc_id_9,'(]',1,5) -
        INSTRB(anc_id_9,'(]',1,4) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,5) + 2
       ,INSTRB(anc_id_9,'(]',1,6) -
        INSTRB(anc_id_9,'(]',1,5) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,6) + 2
       ,INSTRB(anc_id_9,'(]',1,7) -
        INSTRB(anc_id_9,'(]',1,6) - 2)
,SUBSTRB(anc_id_9
       ,INSTRB(anc_id_9,'(]',1,7) + 2
       ,LENGTHB(anc_id_9))
)

WHEN anc_id_10 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_10
       ,1
       ,INSTRB(anc_id_10,'(]',1,1) -1)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,1) + 2
       ,INSTRB(anc_id_10,'(]',1,2) -
        INSTRB(anc_id_10,'(]',1,1) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,2) + 2
       ,INSTRB(anc_id_10,'(]',1,3) -
        INSTRB(anc_id_10,'(]',1,2) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,3) + 2
       ,INSTRB(anc_id_10,'(]',1,4) -
        INSTRB(anc_id_10,'(]',1,3) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,4) + 2
       ,INSTRB(anc_id_10,'(]',1,5) -
        INSTRB(anc_id_10,'(]',1,4) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,5) + 2
       ,INSTRB(anc_id_10,'(]',1,6) -
        INSTRB(anc_id_10,'(]',1,5) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,6) + 2
       ,INSTRB(anc_id_10,'(]',1,7) -
        INSTRB(anc_id_10,'(]',1,6) - 2)
,SUBSTRB(anc_id_10
       ,INSTRB(anc_id_10,'(]',1,7) + 2
       ,LENGTHB(anc_id_10))
)

WHEN anc_id_11 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_11
       ,1
       ,INSTRB(anc_id_11,'(]',1,1) -1)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,1) + 2
       ,INSTRB(anc_id_11,'(]',1,2) -
        INSTRB(anc_id_11,'(]',1,1) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,2) + 2
       ,INSTRB(anc_id_11,'(]',1,3) -
        INSTRB(anc_id_11,'(]',1,2) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,3) + 2
       ,INSTRB(anc_id_11,'(]',1,4) -
        INSTRB(anc_id_11,'(]',1,3) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,4) + 2
       ,INSTRB(anc_id_11,'(]',1,5) -
        INSTRB(anc_id_11,'(]',1,4) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,5) + 2
       ,INSTRB(anc_id_11,'(]',1,6) -
        INSTRB(anc_id_11,'(]',1,5) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,6) + 2
       ,INSTRB(anc_id_11,'(]',1,7) -
        INSTRB(anc_id_11,'(]',1,6) - 2)
,SUBSTRB(anc_id_11
       ,INSTRB(anc_id_11,'(]',1,7) + 2
       ,LENGTHB(anc_id_11))
)

WHEN anc_id_12 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_12
       ,1
       ,INSTRB(anc_id_12,'(]',1,1) -1)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,1) + 2
       ,INSTRB(anc_id_12,'(]',1,2) -
        INSTRB(anc_id_12,'(]',1,1) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,2) + 2
       ,INSTRB(anc_id_12,'(]',1,3) -
        INSTRB(anc_id_12,'(]',1,2) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,3) + 2
       ,INSTRB(anc_id_12,'(]',1,4) -
        INSTRB(anc_id_12,'(]',1,3) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,4) + 2
       ,INSTRB(anc_id_12,'(]',1,5) -
        INSTRB(anc_id_12,'(]',1,4) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,5) + 2
       ,INSTRB(anc_id_12,'(]',1,6) -
        INSTRB(anc_id_12,'(]',1,5) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,6) + 2
       ,INSTRB(anc_id_12,'(]',1,7) -
        INSTRB(anc_id_12,'(]',1,6) - 2)
,SUBSTRB(anc_id_12
       ,INSTRB(anc_id_12,'(]',1,7) + 2
       ,LENGTHB(anc_id_12))
)

WHEN anc_id_13 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_13
       ,1
       ,INSTRB(anc_id_13,'(]',1,1) -1)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,1) + 2
       ,INSTRB(anc_id_13,'(]',1,2) -
        INSTRB(anc_id_13,'(]',1,1) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,2) + 2
       ,INSTRB(anc_id_13,'(]',1,3) -
        INSTRB(anc_id_13,'(]',1,2) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,3) + 2
       ,INSTRB(anc_id_13,'(]',1,4) -
        INSTRB(anc_id_13,'(]',1,3) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,4) + 2
       ,INSTRB(anc_id_13,'(]',1,5) -
        INSTRB(anc_id_13,'(]',1,4) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,5) + 2
       ,INSTRB(anc_id_13,'(]',1,6) -
        INSTRB(anc_id_13,'(]',1,5) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,6) + 2
       ,INSTRB(anc_id_13,'(]',1,7) -
        INSTRB(anc_id_13,'(]',1,6) - 2)
,SUBSTRB(anc_id_13
       ,INSTRB(anc_id_13,'(]',1,7) + 2
       ,LENGTHB(anc_id_13))
)

WHEN anc_id_14 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_14
       ,1
       ,INSTRB(anc_id_14,'(]',1,1) -1)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,1) + 2
       ,INSTRB(anc_id_14,'(]',1,2) -
        INSTRB(anc_id_14,'(]',1,1) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,2) + 2
       ,INSTRB(anc_id_14,'(]',1,3) -
        INSTRB(anc_id_14,'(]',1,2) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,3) + 2
       ,INSTRB(anc_id_14,'(]',1,4) -
        INSTRB(anc_id_14,'(]',1,3) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,4) + 2
       ,INSTRB(anc_id_14,'(]',1,5) -
        INSTRB(anc_id_14,'(]',1,4) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,5) + 2
       ,INSTRB(anc_id_14,'(]',1,6) -
        INSTRB(anc_id_14,'(]',1,5) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,6) + 2
       ,INSTRB(anc_id_14,'(]',1,7) -
        INSTRB(anc_id_14,'(]',1,6) - 2)
,SUBSTRB(anc_id_14
       ,INSTRB(anc_id_14,'(]',1,7) + 2
       ,LENGTHB(anc_id_14))
)

WHEN anc_id_15 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_15
       ,1
       ,INSTRB(anc_id_15,'(]',1,1) -1)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,1) + 2
       ,INSTRB(anc_id_15,'(]',1,2) -
        INSTRB(anc_id_15,'(]',1,1) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,2) + 2
       ,INSTRB(anc_id_15,'(]',1,3) -
        INSTRB(anc_id_15,'(]',1,2) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,3) + 2
       ,INSTRB(anc_id_15,'(]',1,4) -
        INSTRB(anc_id_15,'(]',1,3) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,4) + 2
       ,INSTRB(anc_id_15,'(]',1,5) -
        INSTRB(anc_id_15,'(]',1,4) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,5) + 2
       ,INSTRB(anc_id_15,'(]',1,6) -
        INSTRB(anc_id_15,'(]',1,5) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,6) + 2
       ,INSTRB(anc_id_15,'(]',1,7) -
        INSTRB(anc_id_15,'(]',1,6) - 2)
,SUBSTRB(anc_id_15
       ,INSTRB(anc_id_15,'(]',1,7) + 2
       ,LENGTHB(anc_id_15))
)

WHEN anc_id_16 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_16
       ,1
       ,INSTRB(anc_id_16,'(]',1,1) -1)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,1) + 2
       ,INSTRB(anc_id_16,'(]',1,2) -
        INSTRB(anc_id_16,'(]',1,1) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,2) + 2
       ,INSTRB(anc_id_16,'(]',1,3) -
        INSTRB(anc_id_16,'(]',1,2) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,3) + 2
       ,INSTRB(anc_id_16,'(]',1,4) -
        INSTRB(anc_id_16,'(]',1,3) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,4) + 2
       ,INSTRB(anc_id_16,'(]',1,5) -
        INSTRB(anc_id_16,'(]',1,4) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,5) + 2
       ,INSTRB(anc_id_16,'(]',1,6) -
        INSTRB(anc_id_16,'(]',1,5) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,6) + 2
       ,INSTRB(anc_id_16,'(]',1,7) -
        INSTRB(anc_id_16,'(]',1,6) - 2)
,SUBSTRB(anc_id_16
       ,INSTRB(anc_id_16,'(]',1,7) + 2
       ,LENGTHB(anc_id_16))
)

WHEN anc_id_17 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_17
       ,1
       ,INSTRB(anc_id_17,'(]',1,1) -1)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,1) + 2
       ,INSTRB(anc_id_17,'(]',1,2) -
        INSTRB(anc_id_17,'(]',1,1) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,2) + 2
       ,INSTRB(anc_id_17,'(]',1,3) -
        INSTRB(anc_id_17,'(]',1,2) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,3) + 2
       ,INSTRB(anc_id_17,'(]',1,4) -
        INSTRB(anc_id_17,'(]',1,3) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,4) + 2
       ,INSTRB(anc_id_17,'(]',1,5) -
        INSTRB(anc_id_17,'(]',1,4) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,5) + 2
       ,INSTRB(anc_id_17,'(]',1,6) -
        INSTRB(anc_id_17,'(]',1,5) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,6) + 2
       ,INSTRB(anc_id_17,'(]',1,7) -
        INSTRB(anc_id_17,'(]',1,6) - 2)
,SUBSTRB(anc_id_17
       ,INSTRB(anc_id_17,'(]',1,7) + 2
       ,LENGTHB(anc_id_17))
)

WHEN anc_id_18 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_18
       ,1
       ,INSTRB(anc_id_18,'(]',1,1) -1)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,1) + 2
       ,INSTRB(anc_id_18,'(]',1,2) -
        INSTRB(anc_id_18,'(]',1,1) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,2) + 2
       ,INSTRB(anc_id_18,'(]',1,3) -
        INSTRB(anc_id_18,'(]',1,2) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,3) + 2
       ,INSTRB(anc_id_18,'(]',1,4) -
        INSTRB(anc_id_18,'(]',1,3) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,4) + 2
       ,INSTRB(anc_id_18,'(]',1,5) -
        INSTRB(anc_id_18,'(]',1,4) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,5) + 2
       ,INSTRB(anc_id_18,'(]',1,6) -
        INSTRB(anc_id_18,'(]',1,5) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,6) + 2
       ,INSTRB(anc_id_18,'(]',1,7) -
        INSTRB(anc_id_18,'(]',1,6) - 2)
,SUBSTRB(anc_id_18
       ,INSTRB(anc_id_18,'(]',1,7) + 2
       ,LENGTHB(anc_id_18))
)

WHEN anc_id_19 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_19
       ,1
       ,INSTRB(anc_id_19,'(]',1,1) -1)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,1) + 2
       ,INSTRB(anc_id_19,'(]',1,2) -
        INSTRB(anc_id_19,'(]',1,1) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,2) + 2
       ,INSTRB(anc_id_19,'(]',1,3) -
        INSTRB(anc_id_19,'(]',1,2) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,3) + 2
       ,INSTRB(anc_id_19,'(]',1,4) -
        INSTRB(anc_id_19,'(]',1,3) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,4) + 2
       ,INSTRB(anc_id_19,'(]',1,5) -
        INSTRB(anc_id_19,'(]',1,4) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,5) + 2
       ,INSTRB(anc_id_19,'(]',1,6) -
        INSTRB(anc_id_19,'(]',1,5) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,6) + 2
       ,INSTRB(anc_id_19,'(]',1,7) -
        INSTRB(anc_id_19,'(]',1,6) - 2)
,SUBSTRB(anc_id_19
       ,INSTRB(anc_id_19,'(]',1,7) + 2
       ,LENGTHB(anc_id_19))
)

WHEN anc_id_20 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_20
       ,1
       ,INSTRB(anc_id_20,'(]',1,1) -1)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,1) + 2
       ,INSTRB(anc_id_20,'(]',1,2) -
        INSTRB(anc_id_20,'(]',1,1) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,2) + 2
       ,INSTRB(anc_id_20,'(]',1,3) -
        INSTRB(anc_id_20,'(]',1,2) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,3) + 2
       ,INSTRB(anc_id_20,'(]',1,4) -
        INSTRB(anc_id_20,'(]',1,3) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,4) + 2
       ,INSTRB(anc_id_20,'(]',1,5) -
        INSTRB(anc_id_20,'(]',1,4) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,5) + 2
       ,INSTRB(anc_id_20,'(]',1,6) -
        INSTRB(anc_id_20,'(]',1,5) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,6) + 2
       ,INSTRB(anc_id_20,'(]',1,7) -
        INSTRB(anc_id_20,'(]',1,6) - 2)
,SUBSTRB(anc_id_20
       ,INSTRB(anc_id_20,'(]',1,7) + 2
       ,LENGTHB(anc_id_20))
)

WHEN anc_id_21 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_21
       ,1
       ,INSTRB(anc_id_21,'(]',1,1) -1)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,1) + 2
       ,INSTRB(anc_id_21,'(]',1,2) -
        INSTRB(anc_id_21,'(]',1,1) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,2) + 2
       ,INSTRB(anc_id_21,'(]',1,3) -
        INSTRB(anc_id_21,'(]',1,2) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,3) + 2
       ,INSTRB(anc_id_21,'(]',1,4) -
        INSTRB(anc_id_21,'(]',1,3) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,4) + 2
       ,INSTRB(anc_id_21,'(]',1,5) -
        INSTRB(anc_id_21,'(]',1,4) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,5) + 2
       ,INSTRB(anc_id_21,'(]',1,6) -
        INSTRB(anc_id_21,'(]',1,5) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,6) + 2
       ,INSTRB(anc_id_21,'(]',1,7) -
        INSTRB(anc_id_21,'(]',1,6) - 2)
,SUBSTRB(anc_id_21
       ,INSTRB(anc_id_21,'(]',1,7) + 2
       ,LENGTHB(anc_id_21))
)

WHEN anc_id_22 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_22
       ,1
       ,INSTRB(anc_id_22,'(]',1,1) -1)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,1) + 2
       ,INSTRB(anc_id_22,'(]',1,2) -
        INSTRB(anc_id_22,'(]',1,1) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,2) + 2
       ,INSTRB(anc_id_22,'(]',1,3) -
        INSTRB(anc_id_22,'(]',1,2) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,3) + 2
       ,INSTRB(anc_id_22,'(]',1,4) -
        INSTRB(anc_id_22,'(]',1,3) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,4) + 2
       ,INSTRB(anc_id_22,'(]',1,5) -
        INSTRB(anc_id_22,'(]',1,4) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,5) + 2
       ,INSTRB(anc_id_22,'(]',1,6) -
        INSTRB(anc_id_22,'(]',1,5) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,6) + 2
       ,INSTRB(anc_id_22,'(]',1,7) -
        INSTRB(anc_id_22,'(]',1,6) - 2)
,SUBSTRB(anc_id_22
       ,INSTRB(anc_id_22,'(]',1,7) + 2
       ,LENGTHB(anc_id_22))
)

WHEN anc_id_23 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_23
       ,1
       ,INSTRB(anc_id_23,'(]',1,1) -1)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,1) + 2
       ,INSTRB(anc_id_23,'(]',1,2) -
        INSTRB(anc_id_23,'(]',1,1) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,2) + 2
       ,INSTRB(anc_id_23,'(]',1,3) -
        INSTRB(anc_id_23,'(]',1,2) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,3) + 2
       ,INSTRB(anc_id_23,'(]',1,4) -
        INSTRB(anc_id_23,'(]',1,3) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,4) + 2
       ,INSTRB(anc_id_23,'(]',1,5) -
        INSTRB(anc_id_23,'(]',1,4) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,5) + 2
       ,INSTRB(anc_id_23,'(]',1,6) -
        INSTRB(anc_id_23,'(]',1,5) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,6) + 2
       ,INSTRB(anc_id_23,'(]',1,7) -
        INSTRB(anc_id_23,'(]',1,6) - 2)
,SUBSTRB(anc_id_23
       ,INSTRB(anc_id_23,'(]',1,7) + 2
       ,LENGTHB(anc_id_23))
)

WHEN anc_id_24 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_24
       ,1
       ,INSTRB(anc_id_24,'(]',1,1) -1)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,1) + 2
       ,INSTRB(anc_id_24,'(]',1,2) -
        INSTRB(anc_id_24,'(]',1,1) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,2) + 2
       ,INSTRB(anc_id_24,'(]',1,3) -
        INSTRB(anc_id_24,'(]',1,2) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,3) + 2
       ,INSTRB(anc_id_24,'(]',1,4) -
        INSTRB(anc_id_24,'(]',1,3) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,4) + 2
       ,INSTRB(anc_id_24,'(]',1,5) -
        INSTRB(anc_id_24,'(]',1,4) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,5) + 2
       ,INSTRB(anc_id_24,'(]',1,6) -
        INSTRB(anc_id_24,'(]',1,5) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,6) + 2
       ,INSTRB(anc_id_24,'(]',1,7) -
        INSTRB(anc_id_24,'(]',1,6) - 2)
,SUBSTRB(anc_id_24
       ,INSTRB(anc_id_24,'(]',1,7) + 2
       ,LENGTHB(anc_id_24))
)

WHEN anc_id_25 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_25
       ,1
       ,INSTRB(anc_id_25,'(]',1,1) -1)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,1) + 2
       ,INSTRB(anc_id_25,'(]',1,2) -
        INSTRB(anc_id_25,'(]',1,1) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,2) + 2
       ,INSTRB(anc_id_25,'(]',1,3) -
        INSTRB(anc_id_25,'(]',1,2) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,3) + 2
       ,INSTRB(anc_id_25,'(]',1,4) -
        INSTRB(anc_id_25,'(]',1,3) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,4) + 2
       ,INSTRB(anc_id_25,'(]',1,5) -
        INSTRB(anc_id_25,'(]',1,4) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,5) + 2
       ,INSTRB(anc_id_25,'(]',1,6) -
        INSTRB(anc_id_25,'(]',1,5) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,6) + 2
       ,INSTRB(anc_id_25,'(]',1,7) -
        INSTRB(anc_id_25,'(]',1,6) - 2)
,SUBSTRB(anc_id_25
       ,INSTRB(anc_id_25,'(]',1,7) + 2
       ,LENGTHB(anc_id_25))
)

WHEN anc_id_26 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_26
       ,1
       ,INSTRB(anc_id_26,'(]',1,1) -1)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,1) + 2
       ,INSTRB(anc_id_26,'(]',1,2) -
        INSTRB(anc_id_26,'(]',1,1) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,2) + 2
       ,INSTRB(anc_id_26,'(]',1,3) -
        INSTRB(anc_id_26,'(]',1,2) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,3) + 2
       ,INSTRB(anc_id_26,'(]',1,4) -
        INSTRB(anc_id_26,'(]',1,3) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,4) + 2
       ,INSTRB(anc_id_26,'(]',1,5) -
        INSTRB(anc_id_26,'(]',1,4) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,5) + 2
       ,INSTRB(anc_id_26,'(]',1,6) -
        INSTRB(anc_id_26,'(]',1,5) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,6) + 2
       ,INSTRB(anc_id_26,'(]',1,7) -
        INSTRB(anc_id_26,'(]',1,6) - 2)
,SUBSTRB(anc_id_26
       ,INSTRB(anc_id_26,'(]',1,7) + 2
       ,LENGTHB(anc_id_26))
)

WHEN anc_id_27 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_27
       ,1
       ,INSTRB(anc_id_27,'(]',1,1) -1)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,1) + 2
       ,INSTRB(anc_id_27,'(]',1,2) -
        INSTRB(anc_id_27,'(]',1,1) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,2) + 2
       ,INSTRB(anc_id_27,'(]',1,3) -
        INSTRB(anc_id_27,'(]',1,2) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,3) + 2
       ,INSTRB(anc_id_27,'(]',1,4) -
        INSTRB(anc_id_27,'(]',1,3) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,4) + 2
       ,INSTRB(anc_id_27,'(]',1,5) -
        INSTRB(anc_id_27,'(]',1,4) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,5) + 2
       ,INSTRB(anc_id_27,'(]',1,6) -
        INSTRB(anc_id_27,'(]',1,5) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,6) + 2
       ,INSTRB(anc_id_27,'(]',1,7) -
        INSTRB(anc_id_27,'(]',1,6) - 2)
,SUBSTRB(anc_id_27
       ,INSTRB(anc_id_27,'(]',1,7) + 2
       ,LENGTHB(anc_id_27))
)

WHEN anc_id_28 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_28
       ,1
       ,INSTRB(anc_id_28,'(]',1,1) -1)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,1) + 2
       ,INSTRB(anc_id_28,'(]',1,2) -
        INSTRB(anc_id_28,'(]',1,1) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,2) + 2
       ,INSTRB(anc_id_28,'(]',1,3) -
        INSTRB(anc_id_28,'(]',1,2) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,3) + 2
       ,INSTRB(anc_id_28,'(]',1,4) -
        INSTRB(anc_id_28,'(]',1,3) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,4) + 2
       ,INSTRB(anc_id_28,'(]',1,5) -
        INSTRB(anc_id_28,'(]',1,4) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,5) + 2
       ,INSTRB(anc_id_28,'(]',1,6) -
        INSTRB(anc_id_28,'(]',1,5) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,6) + 2
       ,INSTRB(anc_id_28,'(]',1,7) -
        INSTRB(anc_id_28,'(]',1,6) - 2)
,SUBSTRB(anc_id_28
       ,INSTRB(anc_id_28,'(]',1,7) + 2
       ,LENGTHB(anc_id_28))
)

WHEN anc_id_29 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_29
       ,1
       ,INSTRB(anc_id_29,'(]',1,1) -1)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,1) + 2
       ,INSTRB(anc_id_29,'(]',1,2) -
        INSTRB(anc_id_29,'(]',1,1) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,2) + 2
       ,INSTRB(anc_id_29,'(]',1,3) -
        INSTRB(anc_id_29,'(]',1,2) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,3) + 2
       ,INSTRB(anc_id_29,'(]',1,4) -
        INSTRB(anc_id_29,'(]',1,3) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,4) + 2
       ,INSTRB(anc_id_29,'(]',1,5) -
        INSTRB(anc_id_29,'(]',1,4) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,5) + 2
       ,INSTRB(anc_id_29,'(]',1,6) -
        INSTRB(anc_id_29,'(]',1,5) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,6) + 2
       ,INSTRB(anc_id_29,'(]',1,7) -
        INSTRB(anc_id_29,'(]',1,6) - 2)
,SUBSTRB(anc_id_29
       ,INSTRB(anc_id_29,'(]',1,7) + 2
       ,LENGTHB(anc_id_29))
)

WHEN anc_id_30 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_30
       ,1
       ,INSTRB(anc_id_30,'(]',1,1) -1)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,1) + 2
       ,INSTRB(anc_id_30,'(]',1,2) -
        INSTRB(anc_id_30,'(]',1,1) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,2) + 2
       ,INSTRB(anc_id_30,'(]',1,3) -
        INSTRB(anc_id_30,'(]',1,2) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,3) + 2
       ,INSTRB(anc_id_30,'(]',1,4) -
        INSTRB(anc_id_30,'(]',1,3) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,4) + 2
       ,INSTRB(anc_id_30,'(]',1,5) -
        INSTRB(anc_id_30,'(]',1,4) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,5) + 2
       ,INSTRB(anc_id_30,'(]',1,6) -
        INSTRB(anc_id_30,'(]',1,5) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,6) + 2
       ,INSTRB(anc_id_30,'(]',1,7) -
        INSTRB(anc_id_30,'(]',1,6) - 2)
,SUBSTRB(anc_id_30
       ,INSTRB(anc_id_30,'(]',1,7) + 2
       ,LENGTHB(anc_id_30))
)

WHEN anc_id_31 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_31
       ,1
       ,INSTRB(anc_id_31,'(]',1,1) -1)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,1) + 2
       ,INSTRB(anc_id_31,'(]',1,2) -
        INSTRB(anc_id_31,'(]',1,1) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,2) + 2
       ,INSTRB(anc_id_31,'(]',1,3) -
        INSTRB(anc_id_31,'(]',1,2) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,3) + 2
       ,INSTRB(anc_id_31,'(]',1,4) -
        INSTRB(anc_id_31,'(]',1,3) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,4) + 2
       ,INSTRB(anc_id_31,'(]',1,5) -
        INSTRB(anc_id_31,'(]',1,4) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,5) + 2
       ,INSTRB(anc_id_31,'(]',1,6) -
        INSTRB(anc_id_31,'(]',1,5) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,6) + 2
       ,INSTRB(anc_id_31,'(]',1,7) -
        INSTRB(anc_id_31,'(]',1,6) - 2)
,SUBSTRB(anc_id_31
       ,INSTRB(anc_id_31,'(]',1,7) + 2
       ,LENGTHB(anc_id_31))
)

WHEN anc_id_32 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_32
       ,1
       ,INSTRB(anc_id_32,'(]',1,1) -1)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,1) + 2
       ,INSTRB(anc_id_32,'(]',1,2) -
        INSTRB(anc_id_32,'(]',1,1) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,2) + 2
       ,INSTRB(anc_id_32,'(]',1,3) -
        INSTRB(anc_id_32,'(]',1,2) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,3) + 2
       ,INSTRB(anc_id_32,'(]',1,4) -
        INSTRB(anc_id_32,'(]',1,3) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,4) + 2
       ,INSTRB(anc_id_32,'(]',1,5) -
        INSTRB(anc_id_32,'(]',1,4) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,5) + 2
       ,INSTRB(anc_id_32,'(]',1,6) -
        INSTRB(anc_id_32,'(]',1,5) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,6) + 2
       ,INSTRB(anc_id_32,'(]',1,7) -
        INSTRB(anc_id_32,'(]',1,6) - 2)
,SUBSTRB(anc_id_32
       ,INSTRB(anc_id_32,'(]',1,7) + 2
       ,LENGTHB(anc_id_32))
)

WHEN anc_id_33 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_33
       ,1
       ,INSTRB(anc_id_33,'(]',1,1) -1)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,1) + 2
       ,INSTRB(anc_id_33,'(]',1,2) -
        INSTRB(anc_id_33,'(]',1,1) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,2) + 2
       ,INSTRB(anc_id_33,'(]',1,3) -
        INSTRB(anc_id_33,'(]',1,2) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,3) + 2
       ,INSTRB(anc_id_33,'(]',1,4) -
        INSTRB(anc_id_33,'(]',1,3) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,4) + 2
       ,INSTRB(anc_id_33,'(]',1,5) -
        INSTRB(anc_id_33,'(]',1,4) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,5) + 2
       ,INSTRB(anc_id_33,'(]',1,6) -
        INSTRB(anc_id_33,'(]',1,5) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,6) + 2
       ,INSTRB(anc_id_33,'(]',1,7) -
        INSTRB(anc_id_33,'(]',1,6) - 2)
,SUBSTRB(anc_id_33
       ,INSTRB(anc_id_33,'(]',1,7) + 2
       ,LENGTHB(anc_id_33))
)

WHEN anc_id_34 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_34
       ,1
       ,INSTRB(anc_id_34,'(]',1,1) -1)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,1) + 2
       ,INSTRB(anc_id_34,'(]',1,2) -
        INSTRB(anc_id_34,'(]',1,1) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,2) + 2
       ,INSTRB(anc_id_34,'(]',1,3) -
        INSTRB(anc_id_34,'(]',1,2) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,3) + 2
       ,INSTRB(anc_id_34,'(]',1,4) -
        INSTRB(anc_id_34,'(]',1,3) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,4) + 2
       ,INSTRB(anc_id_34,'(]',1,5) -
        INSTRB(anc_id_34,'(]',1,4) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,5) + 2
       ,INSTRB(anc_id_34,'(]',1,6) -
        INSTRB(anc_id_34,'(]',1,5) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,6) + 2
       ,INSTRB(anc_id_34,'(]',1,7) -
        INSTRB(anc_id_34,'(]',1,6) - 2)
,SUBSTRB(anc_id_34
       ,INSTRB(anc_id_34,'(]',1,7) + 2
       ,LENGTHB(anc_id_34))
)

WHEN anc_id_35 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_35
       ,1
       ,INSTRB(anc_id_35,'(]',1,1) -1)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,1) + 2
       ,INSTRB(anc_id_35,'(]',1,2) -
        INSTRB(anc_id_35,'(]',1,1) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,2) + 2
       ,INSTRB(anc_id_35,'(]',1,3) -
        INSTRB(anc_id_35,'(]',1,2) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,3) + 2
       ,INSTRB(anc_id_35,'(]',1,4) -
        INSTRB(anc_id_35,'(]',1,3) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,4) + 2
       ,INSTRB(anc_id_35,'(]',1,5) -
        INSTRB(anc_id_35,'(]',1,4) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,5) + 2
       ,INSTRB(anc_id_35,'(]',1,6) -
        INSTRB(anc_id_35,'(]',1,5) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,6) + 2
       ,INSTRB(anc_id_35,'(]',1,7) -
        INSTRB(anc_id_35,'(]',1,6) - 2)
,SUBSTRB(anc_id_35
       ,INSTRB(anc_id_35,'(]',1,7) + 2
       ,LENGTHB(anc_id_35))
)

WHEN anc_id_36 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_36
       ,1
       ,INSTRB(anc_id_36,'(]',1,1) -1)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,1) + 2
       ,INSTRB(anc_id_36,'(]',1,2) -
        INSTRB(anc_id_36,'(]',1,1) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,2) + 2
       ,INSTRB(anc_id_36,'(]',1,3) -
        INSTRB(anc_id_36,'(]',1,2) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,3) + 2
       ,INSTRB(anc_id_36,'(]',1,4) -
        INSTRB(anc_id_36,'(]',1,3) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,4) + 2
       ,INSTRB(anc_id_36,'(]',1,5) -
        INSTRB(anc_id_36,'(]',1,4) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,5) + 2
       ,INSTRB(anc_id_36,'(]',1,6) -
        INSTRB(anc_id_36,'(]',1,5) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,6) + 2
       ,INSTRB(anc_id_36,'(]',1,7) -
        INSTRB(anc_id_36,'(]',1,6) - 2)
,SUBSTRB(anc_id_36
       ,INSTRB(anc_id_36,'(]',1,7) + 2
       ,LENGTHB(anc_id_36))
)

WHEN anc_id_37 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_37
       ,1
       ,INSTRB(anc_id_37,'(]',1,1) -1)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,1) + 2
       ,INSTRB(anc_id_37,'(]',1,2) -
        INSTRB(anc_id_37,'(]',1,1) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,2) + 2
       ,INSTRB(anc_id_37,'(]',1,3) -
        INSTRB(anc_id_37,'(]',1,2) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,3) + 2
       ,INSTRB(anc_id_37,'(]',1,4) -
        INSTRB(anc_id_37,'(]',1,3) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,4) + 2
       ,INSTRB(anc_id_37,'(]',1,5) -
        INSTRB(anc_id_37,'(]',1,4) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,5) + 2
       ,INSTRB(anc_id_37,'(]',1,6) -
        INSTRB(anc_id_37,'(]',1,5) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,6) + 2
       ,INSTRB(anc_id_37,'(]',1,7) -
        INSTRB(anc_id_37,'(]',1,6) - 2)
,SUBSTRB(anc_id_37
       ,INSTRB(anc_id_37,'(]',1,7) + 2
       ,LENGTHB(anc_id_37))
)

WHEN anc_id_38 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_38
       ,1
       ,INSTRB(anc_id_38,'(]',1,1) -1)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,1) + 2
       ,INSTRB(anc_id_38,'(]',1,2) -
        INSTRB(anc_id_38,'(]',1,1) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,2) + 2
       ,INSTRB(anc_id_38,'(]',1,3) -
        INSTRB(anc_id_38,'(]',1,2) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,3) + 2
       ,INSTRB(anc_id_38,'(]',1,4) -
        INSTRB(anc_id_38,'(]',1,3) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,4) + 2
       ,INSTRB(anc_id_38,'(]',1,5) -
        INSTRB(anc_id_38,'(]',1,4) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,5) + 2
       ,INSTRB(anc_id_38,'(]',1,6) -
        INSTRB(anc_id_38,'(]',1,5) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,6) + 2
       ,INSTRB(anc_id_38,'(]',1,7) -
        INSTRB(anc_id_38,'(]',1,6) - 2)
,SUBSTRB(anc_id_38
       ,INSTRB(anc_id_38,'(]',1,7) + 2
       ,LENGTHB(anc_id_38))
)

WHEN anc_id_39 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_39
       ,1
       ,INSTRB(anc_id_39,'(]',1,1) -1)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,1) + 2
       ,INSTRB(anc_id_39,'(]',1,2) -
        INSTRB(anc_id_39,'(]',1,1) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,2) + 2
       ,INSTRB(anc_id_39,'(]',1,3) -
        INSTRB(anc_id_39,'(]',1,2) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,3) + 2
       ,INSTRB(anc_id_39,'(]',1,4) -
        INSTRB(anc_id_39,'(]',1,3) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,4) + 2
       ,INSTRB(anc_id_39,'(]',1,5) -
        INSTRB(anc_id_39,'(]',1,4) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,5) + 2
       ,INSTRB(anc_id_39,'(]',1,6) -
        INSTRB(anc_id_39,'(]',1,5) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,6) + 2
       ,INSTRB(anc_id_39,'(]',1,7) -
        INSTRB(anc_id_39,'(]',1,6) - 2)
,SUBSTRB(anc_id_39
       ,INSTRB(anc_id_39,'(]',1,7) + 2
       ,LENGTHB(anc_id_39))
)

WHEN anc_id_40 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_40
       ,1
       ,INSTRB(anc_id_40,'(]',1,1) -1)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,1) + 2
       ,INSTRB(anc_id_40,'(]',1,2) -
        INSTRB(anc_id_40,'(]',1,1) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,2) + 2
       ,INSTRB(anc_id_40,'(]',1,3) -
        INSTRB(anc_id_40,'(]',1,2) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,3) + 2
       ,INSTRB(anc_id_40,'(]',1,4) -
        INSTRB(anc_id_40,'(]',1,3) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,4) + 2
       ,INSTRB(anc_id_40,'(]',1,5) -
        INSTRB(anc_id_40,'(]',1,4) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,5) + 2
       ,INSTRB(anc_id_40,'(]',1,6) -
        INSTRB(anc_id_40,'(]',1,5) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,6) + 2
       ,INSTRB(anc_id_40,'(]',1,7) -
        INSTRB(anc_id_40,'(]',1,6) - 2)
,SUBSTRB(anc_id_40
       ,INSTRB(anc_id_40,'(]',1,7) + 2
       ,LENGTHB(anc_id_40))
)

WHEN anc_id_41 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_41
       ,1
       ,INSTRB(anc_id_41,'(]',1,1) -1)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,1) + 2
       ,INSTRB(anc_id_41,'(]',1,2) -
        INSTRB(anc_id_41,'(]',1,1) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,2) + 2
       ,INSTRB(anc_id_41,'(]',1,3) -
        INSTRB(anc_id_41,'(]',1,2) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,3) + 2
       ,INSTRB(anc_id_41,'(]',1,4) -
        INSTRB(anc_id_41,'(]',1,3) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,4) + 2
       ,INSTRB(anc_id_41,'(]',1,5) -
        INSTRB(anc_id_41,'(]',1,4) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,5) + 2
       ,INSTRB(anc_id_41,'(]',1,6) -
        INSTRB(anc_id_41,'(]',1,5) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,6) + 2
       ,INSTRB(anc_id_41,'(]',1,7) -
        INSTRB(anc_id_41,'(]',1,6) - 2)
,SUBSTRB(anc_id_41
       ,INSTRB(anc_id_41,'(]',1,7) + 2
       ,LENGTHB(anc_id_41))
)

WHEN anc_id_42 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_42
       ,1
       ,INSTRB(anc_id_42,'(]',1,1) -1)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,1) + 2
       ,INSTRB(anc_id_42,'(]',1,2) -
        INSTRB(anc_id_42,'(]',1,1) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,2) + 2
       ,INSTRB(anc_id_42,'(]',1,3) -
        INSTRB(anc_id_42,'(]',1,2) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,3) + 2
       ,INSTRB(anc_id_42,'(]',1,4) -
        INSTRB(anc_id_42,'(]',1,3) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,4) + 2
       ,INSTRB(anc_id_42,'(]',1,5) -
        INSTRB(anc_id_42,'(]',1,4) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,5) + 2
       ,INSTRB(anc_id_42,'(]',1,6) -
        INSTRB(anc_id_42,'(]',1,5) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,6) + 2
       ,INSTRB(anc_id_42,'(]',1,7) -
        INSTRB(anc_id_42,'(]',1,6) - 2)
,SUBSTRB(anc_id_42
       ,INSTRB(anc_id_42,'(]',1,7) + 2
       ,LENGTHB(anc_id_42))
)

WHEN anc_id_43 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_43
       ,1
       ,INSTRB(anc_id_43,'(]',1,1) -1)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,1) + 2
       ,INSTRB(anc_id_43,'(]',1,2) -
        INSTRB(anc_id_43,'(]',1,1) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,2) + 2
       ,INSTRB(anc_id_43,'(]',1,3) -
        INSTRB(anc_id_43,'(]',1,2) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,3) + 2
       ,INSTRB(anc_id_43,'(]',1,4) -
        INSTRB(anc_id_43,'(]',1,3) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,4) + 2
       ,INSTRB(anc_id_43,'(]',1,5) -
        INSTRB(anc_id_43,'(]',1,4) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,5) + 2
       ,INSTRB(anc_id_43,'(]',1,6) -
        INSTRB(anc_id_43,'(]',1,5) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,6) + 2
       ,INSTRB(anc_id_43,'(]',1,7) -
        INSTRB(anc_id_43,'(]',1,6) - 2)
,SUBSTRB(anc_id_43
       ,INSTRB(anc_id_43,'(]',1,7) + 2
       ,LENGTHB(anc_id_43))
)

WHEN anc_id_44 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_44
       ,1
       ,INSTRB(anc_id_44,'(]',1,1) -1)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,1) + 2
       ,INSTRB(anc_id_44,'(]',1,2) -
        INSTRB(anc_id_44,'(]',1,1) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,2) + 2
       ,INSTRB(anc_id_44,'(]',1,3) -
        INSTRB(anc_id_44,'(]',1,2) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,3) + 2
       ,INSTRB(anc_id_44,'(]',1,4) -
        INSTRB(anc_id_44,'(]',1,3) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,4) + 2
       ,INSTRB(anc_id_44,'(]',1,5) -
        INSTRB(anc_id_44,'(]',1,4) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,5) + 2
       ,INSTRB(anc_id_44,'(]',1,6) -
        INSTRB(anc_id_44,'(]',1,5) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,6) + 2
       ,INSTRB(anc_id_44,'(]',1,7) -
        INSTRB(anc_id_44,'(]',1,6) - 2)
,SUBSTRB(anc_id_44
       ,INSTRB(anc_id_44,'(]',1,7) + 2
       ,LENGTHB(anc_id_44))
)

WHEN anc_id_45 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_45
       ,1
       ,INSTRB(anc_id_45,'(]',1,1) -1)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,1) + 2
       ,INSTRB(anc_id_45,'(]',1,2) -
        INSTRB(anc_id_45,'(]',1,1) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,2) + 2
       ,INSTRB(anc_id_45,'(]',1,3) -
        INSTRB(anc_id_45,'(]',1,2) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,3) + 2
       ,INSTRB(anc_id_45,'(]',1,4) -
        INSTRB(anc_id_45,'(]',1,3) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,4) + 2
       ,INSTRB(anc_id_45,'(]',1,5) -
        INSTRB(anc_id_45,'(]',1,4) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,5) + 2
       ,INSTRB(anc_id_45,'(]',1,6) -
        INSTRB(anc_id_45,'(]',1,5) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,6) + 2
       ,INSTRB(anc_id_45,'(]',1,7) -
        INSTRB(anc_id_45,'(]',1,6) - 2)
,SUBSTRB(anc_id_45
       ,INSTRB(anc_id_45,'(]',1,7) + 2
       ,LENGTHB(anc_id_45))
)

WHEN anc_id_46 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_46
       ,1
       ,INSTRB(anc_id_46,'(]',1,1) -1)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,1) + 2
       ,INSTRB(anc_id_46,'(]',1,2) -
        INSTRB(anc_id_46,'(]',1,1) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,2) + 2
       ,INSTRB(anc_id_46,'(]',1,3) -
        INSTRB(anc_id_46,'(]',1,2) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,3) + 2
       ,INSTRB(anc_id_46,'(]',1,4) -
        INSTRB(anc_id_46,'(]',1,3) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,4) + 2
       ,INSTRB(anc_id_46,'(]',1,5) -
        INSTRB(anc_id_46,'(]',1,4) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,5) + 2
       ,INSTRB(anc_id_46,'(]',1,6) -
        INSTRB(anc_id_46,'(]',1,5) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,6) + 2
       ,INSTRB(anc_id_46,'(]',1,7) -
        INSTRB(anc_id_46,'(]',1,6) - 2)
,SUBSTRB(anc_id_46
       ,INSTRB(anc_id_46,'(]',1,7) + 2
       ,LENGTHB(anc_id_46))
)

WHEN anc_id_47 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_47
       ,1
       ,INSTRB(anc_id_47,'(]',1,1) -1)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,1) + 2
       ,INSTRB(anc_id_47,'(]',1,2) -
        INSTRB(anc_id_47,'(]',1,1) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,2) + 2
       ,INSTRB(anc_id_47,'(]',1,3) -
        INSTRB(anc_id_47,'(]',1,2) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,3) + 2
       ,INSTRB(anc_id_47,'(]',1,4) -
        INSTRB(anc_id_47,'(]',1,3) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,4) + 2
       ,INSTRB(anc_id_47,'(]',1,5) -
        INSTRB(anc_id_47,'(]',1,4) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,5) + 2
       ,INSTRB(anc_id_47,'(]',1,6) -
        INSTRB(anc_id_47,'(]',1,5) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,6) + 2
       ,INSTRB(anc_id_47,'(]',1,7) -
        INSTRB(anc_id_47,'(]',1,6) - 2)
,SUBSTRB(anc_id_47
       ,INSTRB(anc_id_47,'(]',1,7) + 2
       ,LENGTHB(anc_id_47))
)

WHEN anc_id_48 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_48
       ,1
       ,INSTRB(anc_id_48,'(]',1,1) -1)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,1) + 2
       ,INSTRB(anc_id_48,'(]',1,2) -
        INSTRB(anc_id_48,'(]',1,1) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,2) + 2
       ,INSTRB(anc_id_48,'(]',1,3) -
        INSTRB(anc_id_48,'(]',1,2) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,3) + 2
       ,INSTRB(anc_id_48,'(]',1,4) -
        INSTRB(anc_id_48,'(]',1,3) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,4) + 2
       ,INSTRB(anc_id_48,'(]',1,5) -
        INSTRB(anc_id_48,'(]',1,4) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,5) + 2
       ,INSTRB(anc_id_48,'(]',1,6) -
        INSTRB(anc_id_48,'(]',1,5) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,6) + 2
       ,INSTRB(anc_id_48,'(]',1,7) -
        INSTRB(anc_id_48,'(]',1,6) - 2)
,SUBSTRB(anc_id_48
       ,INSTRB(anc_id_48,'(]',1,7) + 2
       ,LENGTHB(anc_id_48))
)

WHEN anc_id_49 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_49
       ,1
       ,INSTRB(anc_id_49,'(]',1,1) -1)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,1) + 2
       ,INSTRB(anc_id_49,'(]',1,2) -
        INSTRB(anc_id_49,'(]',1,1) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,2) + 2
       ,INSTRB(anc_id_49,'(]',1,3) -
        INSTRB(anc_id_49,'(]',1,2) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,3) + 2
       ,INSTRB(anc_id_49,'(]',1,4) -
        INSTRB(anc_id_49,'(]',1,3) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,4) + 2
       ,INSTRB(anc_id_49,'(]',1,5) -
        INSTRB(anc_id_49,'(]',1,4) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,5) + 2
       ,INSTRB(anc_id_49,'(]',1,6) -
        INSTRB(anc_id_49,'(]',1,5) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,6) + 2
       ,INSTRB(anc_id_49,'(]',1,7) -
        INSTRB(anc_id_49,'(]',1,6) - 2)
,SUBSTRB(anc_id_49
       ,INSTRB(anc_id_49,'(]',1,7) + 2
       ,LENGTHB(anc_id_49))
)

WHEN anc_id_50 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_50
       ,1
       ,INSTRB(anc_id_50,'(]',1,1) -1)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,1) + 2
       ,INSTRB(anc_id_50,'(]',1,2) -
        INSTRB(anc_id_50,'(]',1,1) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,2) + 2
       ,INSTRB(anc_id_50,'(]',1,3) -
        INSTRB(anc_id_50,'(]',1,2) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,3) + 2
       ,INSTRB(anc_id_50,'(]',1,4) -
        INSTRB(anc_id_50,'(]',1,3) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,4) + 2
       ,INSTRB(anc_id_50,'(]',1,5) -
        INSTRB(anc_id_50,'(]',1,4) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,5) + 2
       ,INSTRB(anc_id_50,'(]',1,6) -
        INSTRB(anc_id_50,'(]',1,5) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,6) + 2
       ,INSTRB(anc_id_50,'(]',1,7) -
        INSTRB(anc_id_50,'(]',1,6) - 2)
,SUBSTRB(anc_id_50
       ,INSTRB(anc_id_50,'(]',1,7) + 2
       ,LENGTHB(anc_id_50))
)

WHEN anc_id_51 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_51
       ,1
       ,INSTRB(anc_id_51,'(]',1,1) -1)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,1) + 2
       ,INSTRB(anc_id_51,'(]',1,2) -
        INSTRB(anc_id_51,'(]',1,1) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,2) + 2
       ,INSTRB(anc_id_51,'(]',1,3) -
        INSTRB(anc_id_51,'(]',1,2) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,3) + 2
       ,INSTRB(anc_id_51,'(]',1,4) -
        INSTRB(anc_id_51,'(]',1,3) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,4) + 2
       ,INSTRB(anc_id_51,'(]',1,5) -
        INSTRB(anc_id_51,'(]',1,4) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,5) + 2
       ,INSTRB(anc_id_51,'(]',1,6) -
        INSTRB(anc_id_51,'(]',1,5) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,6) + 2
       ,INSTRB(anc_id_51,'(]',1,7) -
        INSTRB(anc_id_51,'(]',1,6) - 2)
,SUBSTRB(anc_id_51
       ,INSTRB(anc_id_51,'(]',1,7) + 2
       ,LENGTHB(anc_id_51))
)

WHEN anc_id_52 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_52
       ,1
       ,INSTRB(anc_id_52,'(]',1,1) -1)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,1) + 2
       ,INSTRB(anc_id_52,'(]',1,2) -
        INSTRB(anc_id_52,'(]',1,1) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,2) + 2
       ,INSTRB(anc_id_52,'(]',1,3) -
        INSTRB(anc_id_52,'(]',1,2) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,3) + 2
       ,INSTRB(anc_id_52,'(]',1,4) -
        INSTRB(anc_id_52,'(]',1,3) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,4) + 2
       ,INSTRB(anc_id_52,'(]',1,5) -
        INSTRB(anc_id_52,'(]',1,4) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,5) + 2
       ,INSTRB(anc_id_52,'(]',1,6) -
        INSTRB(anc_id_52,'(]',1,5) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,6) + 2
       ,INSTRB(anc_id_52,'(]',1,7) -
        INSTRB(anc_id_52,'(]',1,6) - 2)
,SUBSTRB(anc_id_52
       ,INSTRB(anc_id_52,'(]',1,7) + 2
       ,LENGTHB(anc_id_52))
)

WHEN anc_id_53 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_53
       ,1
       ,INSTRB(anc_id_53,'(]',1,1) -1)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,1) + 2
       ,INSTRB(anc_id_53,'(]',1,2) -
        INSTRB(anc_id_53,'(]',1,1) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,2) + 2
       ,INSTRB(anc_id_53,'(]',1,3) -
        INSTRB(anc_id_53,'(]',1,2) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,3) + 2
       ,INSTRB(anc_id_53,'(]',1,4) -
        INSTRB(anc_id_53,'(]',1,3) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,4) + 2
       ,INSTRB(anc_id_53,'(]',1,5) -
        INSTRB(anc_id_53,'(]',1,4) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,5) + 2
       ,INSTRB(anc_id_53,'(]',1,6) -
        INSTRB(anc_id_53,'(]',1,5) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,6) + 2
       ,INSTRB(anc_id_53,'(]',1,7) -
        INSTRB(anc_id_53,'(]',1,6) - 2)
,SUBSTRB(anc_id_53
       ,INSTRB(anc_id_53,'(]',1,7) + 2
       ,LENGTHB(anc_id_53))
)

WHEN anc_id_54 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_54
       ,1
       ,INSTRB(anc_id_54,'(]',1,1) -1)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,1) + 2
       ,INSTRB(anc_id_54,'(]',1,2) -
        INSTRB(anc_id_54,'(]',1,1) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,2) + 2
       ,INSTRB(anc_id_54,'(]',1,3) -
        INSTRB(anc_id_54,'(]',1,2) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,3) + 2
       ,INSTRB(anc_id_54,'(]',1,4) -
        INSTRB(anc_id_54,'(]',1,3) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,4) + 2
       ,INSTRB(anc_id_54,'(]',1,5) -
        INSTRB(anc_id_54,'(]',1,4) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,5) + 2
       ,INSTRB(anc_id_54,'(]',1,6) -
        INSTRB(anc_id_54,'(]',1,5) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,6) + 2
       ,INSTRB(anc_id_54,'(]',1,7) -
        INSTRB(anc_id_54,'(]',1,6) - 2)
,SUBSTRB(anc_id_54
       ,INSTRB(anc_id_54,'(]',1,7) + 2
       ,LENGTHB(anc_id_54))
)

WHEN anc_id_55 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_55
       ,1
       ,INSTRB(anc_id_55,'(]',1,1) -1)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,1) + 2
       ,INSTRB(anc_id_55,'(]',1,2) -
        INSTRB(anc_id_55,'(]',1,1) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,2) + 2
       ,INSTRB(anc_id_55,'(]',1,3) -
        INSTRB(anc_id_55,'(]',1,2) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,3) + 2
       ,INSTRB(anc_id_55,'(]',1,4) -
        INSTRB(anc_id_55,'(]',1,3) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,4) + 2
       ,INSTRB(anc_id_55,'(]',1,5) -
        INSTRB(anc_id_55,'(]',1,4) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,5) + 2
       ,INSTRB(anc_id_55,'(]',1,6) -
        INSTRB(anc_id_55,'(]',1,5) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,6) + 2
       ,INSTRB(anc_id_55,'(]',1,7) -
        INSTRB(anc_id_55,'(]',1,6) - 2)
,SUBSTRB(anc_id_55
       ,INSTRB(anc_id_55,'(]',1,7) + 2
       ,LENGTHB(anc_id_55))
)

WHEN anc_id_56 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_56
       ,1
       ,INSTRB(anc_id_56,'(]',1,1) -1)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,1) + 2
       ,INSTRB(anc_id_56,'(]',1,2) -
        INSTRB(anc_id_56,'(]',1,1) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,2) + 2
       ,INSTRB(anc_id_56,'(]',1,3) -
        INSTRB(anc_id_56,'(]',1,2) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,3) + 2
       ,INSTRB(anc_id_56,'(]',1,4) -
        INSTRB(anc_id_56,'(]',1,3) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,4) + 2
       ,INSTRB(anc_id_56,'(]',1,5) -
        INSTRB(anc_id_56,'(]',1,4) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,5) + 2
       ,INSTRB(anc_id_56,'(]',1,6) -
        INSTRB(anc_id_56,'(]',1,5) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,6) + 2
       ,INSTRB(anc_id_56,'(]',1,7) -
        INSTRB(anc_id_56,'(]',1,6) - 2)
,SUBSTRB(anc_id_56
       ,INSTRB(anc_id_56,'(]',1,7) + 2
       ,LENGTHB(anc_id_56))
)

WHEN anc_id_57 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_57
       ,1
       ,INSTRB(anc_id_57,'(]',1,1) -1)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,1) + 2
       ,INSTRB(anc_id_57,'(]',1,2) -
        INSTRB(anc_id_57,'(]',1,1) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,2) + 2
       ,INSTRB(anc_id_57,'(]',1,3) -
        INSTRB(anc_id_57,'(]',1,2) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,3) + 2
       ,INSTRB(anc_id_57,'(]',1,4) -
        INSTRB(anc_id_57,'(]',1,3) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,4) + 2
       ,INSTRB(anc_id_57,'(]',1,5) -
        INSTRB(anc_id_57,'(]',1,4) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,5) + 2
       ,INSTRB(anc_id_57,'(]',1,6) -
        INSTRB(anc_id_57,'(]',1,5) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,6) + 2
       ,INSTRB(anc_id_57,'(]',1,7) -
        INSTRB(anc_id_57,'(]',1,6) - 2)
,SUBSTRB(anc_id_57
       ,INSTRB(anc_id_57,'(]',1,7) + 2
       ,LENGTHB(anc_id_57))
)

WHEN anc_id_58 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_58
       ,1
       ,INSTRB(anc_id_58,'(]',1,1) -1)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,1) + 2
       ,INSTRB(anc_id_58,'(]',1,2) -
        INSTRB(anc_id_58,'(]',1,1) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,2) + 2
       ,INSTRB(anc_id_58,'(]',1,3) -
        INSTRB(anc_id_58,'(]',1,2) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,3) + 2
       ,INSTRB(anc_id_58,'(]',1,4) -
        INSTRB(anc_id_58,'(]',1,3) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,4) + 2
       ,INSTRB(anc_id_58,'(]',1,5) -
        INSTRB(anc_id_58,'(]',1,4) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,5) + 2
       ,INSTRB(anc_id_58,'(]',1,6) -
        INSTRB(anc_id_58,'(]',1,5) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,6) + 2
       ,INSTRB(anc_id_58,'(]',1,7) -
        INSTRB(anc_id_58,'(]',1,6) - 2)
,SUBSTRB(anc_id_58
       ,INSTRB(anc_id_58,'(]',1,7) + 2
       ,LENGTHB(anc_id_58))
)

WHEN anc_id_59 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_59
       ,1
       ,INSTRB(anc_id_59,'(]',1,1) -1)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,1) + 2
       ,INSTRB(anc_id_59,'(]',1,2) -
        INSTRB(anc_id_59,'(]',1,1) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,2) + 2
       ,INSTRB(anc_id_59,'(]',1,3) -
        INSTRB(anc_id_59,'(]',1,2) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,3) + 2
       ,INSTRB(anc_id_59,'(]',1,4) -
        INSTRB(anc_id_59,'(]',1,3) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,4) + 2
       ,INSTRB(anc_id_59,'(]',1,5) -
        INSTRB(anc_id_59,'(]',1,4) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,5) + 2
       ,INSTRB(anc_id_59,'(]',1,6) -
        INSTRB(anc_id_59,'(]',1,5) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,6) + 2
       ,INSTRB(anc_id_59,'(]',1,7) -
        INSTRB(anc_id_59,'(]',1,6) - 2)
,SUBSTRB(anc_id_59
       ,INSTRB(anc_id_59,'(]',1,7) + 2
       ,LENGTHB(anc_id_59))
)

WHEN anc_id_60 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_60
       ,1
       ,INSTRB(anc_id_60,'(]',1,1) -1)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,1) + 2
       ,INSTRB(anc_id_60,'(]',1,2) -
        INSTRB(anc_id_60,'(]',1,1) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,2) + 2
       ,INSTRB(anc_id_60,'(]',1,3) -
        INSTRB(anc_id_60,'(]',1,2) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,3) + 2
       ,INSTRB(anc_id_60,'(]',1,4) -
        INSTRB(anc_id_60,'(]',1,3) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,4) + 2
       ,INSTRB(anc_id_60,'(]',1,5) -
        INSTRB(anc_id_60,'(]',1,4) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,5) + 2
       ,INSTRB(anc_id_60,'(]',1,6) -
        INSTRB(anc_id_60,'(]',1,5) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,6) + 2
       ,INSTRB(anc_id_60,'(]',1,7) -
        INSTRB(anc_id_60,'(]',1,6) - 2)
,SUBSTRB(anc_id_60
       ,INSTRB(anc_id_60,'(]',1,7) + 2
       ,LENGTHB(anc_id_60))
)

WHEN anc_id_61 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_61
       ,1
       ,INSTRB(anc_id_61,'(]',1,1) -1)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,1) + 2
       ,INSTRB(anc_id_61,'(]',1,2) -
        INSTRB(anc_id_61,'(]',1,1) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,2) + 2
       ,INSTRB(anc_id_61,'(]',1,3) -
        INSTRB(anc_id_61,'(]',1,2) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,3) + 2
       ,INSTRB(anc_id_61,'(]',1,4) -
        INSTRB(anc_id_61,'(]',1,3) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,4) + 2
       ,INSTRB(anc_id_61,'(]',1,5) -
        INSTRB(anc_id_61,'(]',1,4) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,5) + 2
       ,INSTRB(anc_id_61,'(]',1,6) -
        INSTRB(anc_id_61,'(]',1,5) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,6) + 2
       ,INSTRB(anc_id_61,'(]',1,7) -
        INSTRB(anc_id_61,'(]',1,6) - 2)
,SUBSTRB(anc_id_61
       ,INSTRB(anc_id_61,'(]',1,7) + 2
       ,LENGTHB(anc_id_61))
)

WHEN anc_id_62 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_62
       ,1
       ,INSTRB(anc_id_62,'(]',1,1) -1)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,1) + 2
       ,INSTRB(anc_id_62,'(]',1,2) -
        INSTRB(anc_id_62,'(]',1,1) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,2) + 2
       ,INSTRB(anc_id_62,'(]',1,3) -
        INSTRB(anc_id_62,'(]',1,2) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,3) + 2
       ,INSTRB(anc_id_62,'(]',1,4) -
        INSTRB(anc_id_62,'(]',1,3) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,4) + 2
       ,INSTRB(anc_id_62,'(]',1,5) -
        INSTRB(anc_id_62,'(]',1,4) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,5) + 2
       ,INSTRB(anc_id_62,'(]',1,6) -
        INSTRB(anc_id_62,'(]',1,5) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,6) + 2
       ,INSTRB(anc_id_62,'(]',1,7) -
        INSTRB(anc_id_62,'(]',1,6) - 2)
,SUBSTRB(anc_id_62
       ,INSTRB(anc_id_62,'(]',1,7) + 2
       ,LENGTHB(anc_id_62))
)

WHEN anc_id_63 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_63
       ,1
       ,INSTRB(anc_id_63,'(]',1,1) -1)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,1) + 2
       ,INSTRB(anc_id_63,'(]',1,2) -
        INSTRB(anc_id_63,'(]',1,1) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,2) + 2
       ,INSTRB(anc_id_63,'(]',1,3) -
        INSTRB(anc_id_63,'(]',1,2) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,3) + 2
       ,INSTRB(anc_id_63,'(]',1,4) -
        INSTRB(anc_id_63,'(]',1,3) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,4) + 2
       ,INSTRB(anc_id_63,'(]',1,5) -
        INSTRB(anc_id_63,'(]',1,4) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,5) + 2
       ,INSTRB(anc_id_63,'(]',1,6) -
        INSTRB(anc_id_63,'(]',1,5) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,6) + 2
       ,INSTRB(anc_id_63,'(]',1,7) -
        INSTRB(anc_id_63,'(]',1,6) - 2)
,SUBSTRB(anc_id_63
       ,INSTRB(anc_id_63,'(]',1,7) + 2
       ,LENGTHB(anc_id_63))
)

WHEN anc_id_64 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_64
       ,1
       ,INSTRB(anc_id_64,'(]',1,1) -1)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,1) + 2
       ,INSTRB(anc_id_64,'(]',1,2) -
        INSTRB(anc_id_64,'(]',1,1) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,2) + 2
       ,INSTRB(anc_id_64,'(]',1,3) -
        INSTRB(anc_id_64,'(]',1,2) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,3) + 2
       ,INSTRB(anc_id_64,'(]',1,4) -
        INSTRB(anc_id_64,'(]',1,3) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,4) + 2
       ,INSTRB(anc_id_64,'(]',1,5) -
        INSTRB(anc_id_64,'(]',1,4) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,5) + 2
       ,INSTRB(anc_id_64,'(]',1,6) -
        INSTRB(anc_id_64,'(]',1,5) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,6) + 2
       ,INSTRB(anc_id_64,'(]',1,7) -
        INSTRB(anc_id_64,'(]',1,6) - 2)
,SUBSTRB(anc_id_64
       ,INSTRB(anc_id_64,'(]',1,7) + 2
       ,LENGTHB(anc_id_64))
)

WHEN anc_id_65 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_65
       ,1
       ,INSTRB(anc_id_65,'(]',1,1) -1)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,1) + 2
       ,INSTRB(anc_id_65,'(]',1,2) -
        INSTRB(anc_id_65,'(]',1,1) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,2) + 2
       ,INSTRB(anc_id_65,'(]',1,3) -
        INSTRB(anc_id_65,'(]',1,2) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,3) + 2
       ,INSTRB(anc_id_65,'(]',1,4) -
        INSTRB(anc_id_65,'(]',1,3) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,4) + 2
       ,INSTRB(anc_id_65,'(]',1,5) -
        INSTRB(anc_id_65,'(]',1,4) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,5) + 2
       ,INSTRB(anc_id_65,'(]',1,6) -
        INSTRB(anc_id_65,'(]',1,5) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,6) + 2
       ,INSTRB(anc_id_65,'(]',1,7) -
        INSTRB(anc_id_65,'(]',1,6) - 2)
,SUBSTRB(anc_id_65
       ,INSTRB(anc_id_65,'(]',1,7) + 2
       ,LENGTHB(anc_id_65))
)

WHEN anc_id_66 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_66
       ,1
       ,INSTRB(anc_id_66,'(]',1,1) -1)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,1) + 2
       ,INSTRB(anc_id_66,'(]',1,2) -
        INSTRB(anc_id_66,'(]',1,1) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,2) + 2
       ,INSTRB(anc_id_66,'(]',1,3) -
        INSTRB(anc_id_66,'(]',1,2) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,3) + 2
       ,INSTRB(anc_id_66,'(]',1,4) -
        INSTRB(anc_id_66,'(]',1,3) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,4) + 2
       ,INSTRB(anc_id_66,'(]',1,5) -
        INSTRB(anc_id_66,'(]',1,4) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,5) + 2
       ,INSTRB(anc_id_66,'(]',1,6) -
        INSTRB(anc_id_66,'(]',1,5) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,6) + 2
       ,INSTRB(anc_id_66,'(]',1,7) -
        INSTRB(anc_id_66,'(]',1,6) - 2)
,SUBSTRB(anc_id_66
       ,INSTRB(anc_id_66,'(]',1,7) + 2
       ,LENGTHB(anc_id_66))
)

WHEN anc_id_67 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_67
       ,1
       ,INSTRB(anc_id_67,'(]',1,1) -1)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,1) + 2
       ,INSTRB(anc_id_67,'(]',1,2) -
        INSTRB(anc_id_67,'(]',1,1) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,2) + 2
       ,INSTRB(anc_id_67,'(]',1,3) -
        INSTRB(anc_id_67,'(]',1,2) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,3) + 2
       ,INSTRB(anc_id_67,'(]',1,4) -
        INSTRB(anc_id_67,'(]',1,3) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,4) + 2
       ,INSTRB(anc_id_67,'(]',1,5) -
        INSTRB(anc_id_67,'(]',1,4) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,5) + 2
       ,INSTRB(anc_id_67,'(]',1,6) -
        INSTRB(anc_id_67,'(]',1,5) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,6) + 2
       ,INSTRB(anc_id_67,'(]',1,7) -
        INSTRB(anc_id_67,'(]',1,6) - 2)
,SUBSTRB(anc_id_67
       ,INSTRB(anc_id_67,'(]',1,7) + 2
       ,LENGTHB(anc_id_67))
)

WHEN anc_id_68 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_68
       ,1
       ,INSTRB(anc_id_68,'(]',1,1) -1)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,1) + 2
       ,INSTRB(anc_id_68,'(]',1,2) -
        INSTRB(anc_id_68,'(]',1,1) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,2) + 2
       ,INSTRB(anc_id_68,'(]',1,3) -
        INSTRB(anc_id_68,'(]',1,2) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,3) + 2
       ,INSTRB(anc_id_68,'(]',1,4) -
        INSTRB(anc_id_68,'(]',1,3) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,4) + 2
       ,INSTRB(anc_id_68,'(]',1,5) -
        INSTRB(anc_id_68,'(]',1,4) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,5) + 2
       ,INSTRB(anc_id_68,'(]',1,6) -
        INSTRB(anc_id_68,'(]',1,5) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,6) + 2
       ,INSTRB(anc_id_68,'(]',1,7) -
        INSTRB(anc_id_68,'(]',1,6) - 2)
,SUBSTRB(anc_id_68
       ,INSTRB(anc_id_68,'(]',1,7) + 2
       ,LENGTHB(anc_id_68))
)

WHEN anc_id_69 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_69
       ,1
       ,INSTRB(anc_id_69,'(]',1,1) -1)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,1) + 2
       ,INSTRB(anc_id_69,'(]',1,2) -
        INSTRB(anc_id_69,'(]',1,1) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,2) + 2
       ,INSTRB(anc_id_69,'(]',1,3) -
        INSTRB(anc_id_69,'(]',1,2) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,3) + 2
       ,INSTRB(anc_id_69,'(]',1,4) -
        INSTRB(anc_id_69,'(]',1,3) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,4) + 2
       ,INSTRB(anc_id_69,'(]',1,5) -
        INSTRB(anc_id_69,'(]',1,4) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,5) + 2
       ,INSTRB(anc_id_69,'(]',1,6) -
        INSTRB(anc_id_69,'(]',1,5) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,6) + 2
       ,INSTRB(anc_id_69,'(]',1,7) -
        INSTRB(anc_id_69,'(]',1,6) - 2)
,SUBSTRB(anc_id_69
       ,INSTRB(anc_id_69,'(]',1,7) + 2
       ,LENGTHB(anc_id_69))
)

WHEN anc_id_70 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_70
       ,1
       ,INSTRB(anc_id_70,'(]',1,1) -1)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,1) + 2
       ,INSTRB(anc_id_70,'(]',1,2) -
        INSTRB(anc_id_70,'(]',1,1) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,2) + 2
       ,INSTRB(anc_id_70,'(]',1,3) -
        INSTRB(anc_id_70,'(]',1,2) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,3) + 2
       ,INSTRB(anc_id_70,'(]',1,4) -
        INSTRB(anc_id_70,'(]',1,3) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,4) + 2
       ,INSTRB(anc_id_70,'(]',1,5) -
        INSTRB(anc_id_70,'(]',1,4) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,5) + 2
       ,INSTRB(anc_id_70,'(]',1,6) -
        INSTRB(anc_id_70,'(]',1,5) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,6) + 2
       ,INSTRB(anc_id_70,'(]',1,7) -
        INSTRB(anc_id_70,'(]',1,6) - 2)
,SUBSTRB(anc_id_70
       ,INSTRB(anc_id_70,'(]',1,7) + 2
       ,LENGTHB(anc_id_70))
)

WHEN anc_id_71 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_71
       ,1
       ,INSTRB(anc_id_71,'(]',1,1) -1)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,1) + 2
       ,INSTRB(anc_id_71,'(]',1,2) -
        INSTRB(anc_id_71,'(]',1,1) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,2) + 2
       ,INSTRB(anc_id_71,'(]',1,3) -
        INSTRB(anc_id_71,'(]',1,2) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,3) + 2
       ,INSTRB(anc_id_71,'(]',1,4) -
        INSTRB(anc_id_71,'(]',1,3) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,4) + 2
       ,INSTRB(anc_id_71,'(]',1,5) -
        INSTRB(anc_id_71,'(]',1,4) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,5) + 2
       ,INSTRB(anc_id_71,'(]',1,6) -
        INSTRB(anc_id_71,'(]',1,5) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,6) + 2
       ,INSTRB(anc_id_71,'(]',1,7) -
        INSTRB(anc_id_71,'(]',1,6) - 2)
,SUBSTRB(anc_id_71
       ,INSTRB(anc_id_71,'(]',1,7) + 2
       ,LENGTHB(anc_id_71))
)

WHEN anc_id_72 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_72
       ,1
       ,INSTRB(anc_id_72,'(]',1,1) -1)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,1) + 2
       ,INSTRB(anc_id_72,'(]',1,2) -
        INSTRB(anc_id_72,'(]',1,1) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,2) + 2
       ,INSTRB(anc_id_72,'(]',1,3) -
        INSTRB(anc_id_72,'(]',1,2) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,3) + 2
       ,INSTRB(anc_id_72,'(]',1,4) -
        INSTRB(anc_id_72,'(]',1,3) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,4) + 2
       ,INSTRB(anc_id_72,'(]',1,5) -
        INSTRB(anc_id_72,'(]',1,4) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,5) + 2
       ,INSTRB(anc_id_72,'(]',1,6) -
        INSTRB(anc_id_72,'(]',1,5) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,6) + 2
       ,INSTRB(anc_id_72,'(]',1,7) -
        INSTRB(anc_id_72,'(]',1,6) - 2)
,SUBSTRB(anc_id_72
       ,INSTRB(anc_id_72,'(]',1,7) + 2
       ,LENGTHB(anc_id_72))
)

WHEN anc_id_73 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_73
       ,1
       ,INSTRB(anc_id_73,'(]',1,1) -1)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,1) + 2
       ,INSTRB(anc_id_73,'(]',1,2) -
        INSTRB(anc_id_73,'(]',1,1) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,2) + 2
       ,INSTRB(anc_id_73,'(]',1,3) -
        INSTRB(anc_id_73,'(]',1,2) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,3) + 2
       ,INSTRB(anc_id_73,'(]',1,4) -
        INSTRB(anc_id_73,'(]',1,3) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,4) + 2
       ,INSTRB(anc_id_73,'(]',1,5) -
        INSTRB(anc_id_73,'(]',1,4) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,5) + 2
       ,INSTRB(anc_id_73,'(]',1,6) -
        INSTRB(anc_id_73,'(]',1,5) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,6) + 2
       ,INSTRB(anc_id_73,'(]',1,7) -
        INSTRB(anc_id_73,'(]',1,6) - 2)
,SUBSTRB(anc_id_73
       ,INSTRB(anc_id_73,'(]',1,7) + 2
       ,LENGTHB(anc_id_73))
)

WHEN anc_id_74 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_74
       ,1
       ,INSTRB(anc_id_74,'(]',1,1) -1)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,1) + 2
       ,INSTRB(anc_id_74,'(]',1,2) -
        INSTRB(anc_id_74,'(]',1,1) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,2) + 2
       ,INSTRB(anc_id_74,'(]',1,3) -
        INSTRB(anc_id_74,'(]',1,2) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,3) + 2
       ,INSTRB(anc_id_74,'(]',1,4) -
        INSTRB(anc_id_74,'(]',1,3) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,4) + 2
       ,INSTRB(anc_id_74,'(]',1,5) -
        INSTRB(anc_id_74,'(]',1,4) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,5) + 2
       ,INSTRB(anc_id_74,'(]',1,6) -
        INSTRB(anc_id_74,'(]',1,5) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,6) + 2
       ,INSTRB(anc_id_74,'(]',1,7) -
        INSTRB(anc_id_74,'(]',1,6) - 2)
,SUBSTRB(anc_id_74
       ,INSTRB(anc_id_74,'(]',1,7) + 2
       ,LENGTHB(anc_id_74))
)

WHEN anc_id_75 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_75
       ,1
       ,INSTRB(anc_id_75,'(]',1,1) -1)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,1) + 2
       ,INSTRB(anc_id_75,'(]',1,2) -
        INSTRB(anc_id_75,'(]',1,1) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,2) + 2
       ,INSTRB(anc_id_75,'(]',1,3) -
        INSTRB(anc_id_75,'(]',1,2) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,3) + 2
       ,INSTRB(anc_id_75,'(]',1,4) -
        INSTRB(anc_id_75,'(]',1,3) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,4) + 2
       ,INSTRB(anc_id_75,'(]',1,5) -
        INSTRB(anc_id_75,'(]',1,4) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,5) + 2
       ,INSTRB(anc_id_75,'(]',1,6) -
        INSTRB(anc_id_75,'(]',1,5) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,6) + 2
       ,INSTRB(anc_id_75,'(]',1,7) -
        INSTRB(anc_id_75,'(]',1,6) - 2)
,SUBSTRB(anc_id_75
       ,INSTRB(anc_id_75,'(]',1,7) + 2
       ,LENGTHB(anc_id_75))
)

WHEN anc_id_76 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_76
       ,1
       ,INSTRB(anc_id_76,'(]',1,1) -1)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,1) + 2
       ,INSTRB(anc_id_76,'(]',1,2) -
        INSTRB(anc_id_76,'(]',1,1) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,2) + 2
       ,INSTRB(anc_id_76,'(]',1,3) -
        INSTRB(anc_id_76,'(]',1,2) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,3) + 2
       ,INSTRB(anc_id_76,'(]',1,4) -
        INSTRB(anc_id_76,'(]',1,3) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,4) + 2
       ,INSTRB(anc_id_76,'(]',1,5) -
        INSTRB(anc_id_76,'(]',1,4) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,5) + 2
       ,INSTRB(anc_id_76,'(]',1,6) -
        INSTRB(anc_id_76,'(]',1,5) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,6) + 2
       ,INSTRB(anc_id_76,'(]',1,7) -
        INSTRB(anc_id_76,'(]',1,6) - 2)
,SUBSTRB(anc_id_76
       ,INSTRB(anc_id_76,'(]',1,7) + 2
       ,LENGTHB(anc_id_76))
)

WHEN anc_id_77 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_77
       ,1
       ,INSTRB(anc_id_77,'(]',1,1) -1)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,1) + 2
       ,INSTRB(anc_id_77,'(]',1,2) -
        INSTRB(anc_id_77,'(]',1,1) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,2) + 2
       ,INSTRB(anc_id_77,'(]',1,3) -
        INSTRB(anc_id_77,'(]',1,2) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,3) + 2
       ,INSTRB(anc_id_77,'(]',1,4) -
        INSTRB(anc_id_77,'(]',1,3) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,4) + 2
       ,INSTRB(anc_id_77,'(]',1,5) -
        INSTRB(anc_id_77,'(]',1,4) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,5) + 2
       ,INSTRB(anc_id_77,'(]',1,6) -
        INSTRB(anc_id_77,'(]',1,5) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,6) + 2
       ,INSTRB(anc_id_77,'(]',1,7) -
        INSTRB(anc_id_77,'(]',1,6) - 2)
,SUBSTRB(anc_id_77
       ,INSTRB(anc_id_77,'(]',1,7) + 2
       ,LENGTHB(anc_id_77))
)

WHEN anc_id_78 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_78
       ,1
       ,INSTRB(anc_id_78,'(]',1,1) -1)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,1) + 2
       ,INSTRB(anc_id_78,'(]',1,2) -
        INSTRB(anc_id_78,'(]',1,1) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,2) + 2
       ,INSTRB(anc_id_78,'(]',1,3) -
        INSTRB(anc_id_78,'(]',1,2) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,3) + 2
       ,INSTRB(anc_id_78,'(]',1,4) -
        INSTRB(anc_id_78,'(]',1,3) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,4) + 2
       ,INSTRB(anc_id_78,'(]',1,5) -
        INSTRB(anc_id_78,'(]',1,4) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,5) + 2
       ,INSTRB(anc_id_78,'(]',1,6) -
        INSTRB(anc_id_78,'(]',1,5) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,6) + 2
       ,INSTRB(anc_id_78,'(]',1,7) -
        INSTRB(anc_id_78,'(]',1,6) - 2)
,SUBSTRB(anc_id_78
       ,INSTRB(anc_id_78,'(]',1,7) + 2
       ,LENGTHB(anc_id_78))
)

WHEN anc_id_79 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_79
       ,1
       ,INSTRB(anc_id_79,'(]',1,1) -1)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,1) + 2
       ,INSTRB(anc_id_79,'(]',1,2) -
        INSTRB(anc_id_79,'(]',1,1) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,2) + 2
       ,INSTRB(anc_id_79,'(]',1,3) -
        INSTRB(anc_id_79,'(]',1,2) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,3) + 2
       ,INSTRB(anc_id_79,'(]',1,4) -
        INSTRB(anc_id_79,'(]',1,3) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,4) + 2
       ,INSTRB(anc_id_79,'(]',1,5) -
        INSTRB(anc_id_79,'(]',1,4) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,5) + 2
       ,INSTRB(anc_id_79,'(]',1,6) -
        INSTRB(anc_id_79,'(]',1,5) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,6) + 2
       ,INSTRB(anc_id_79,'(]',1,7) -
        INSTRB(anc_id_79,'(]',1,6) - 2)
,SUBSTRB(anc_id_79
       ,INSTRB(anc_id_79,'(]',1,7) + 2
       ,LENGTHB(anc_id_79))
)

WHEN anc_id_80 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_80
       ,1
       ,INSTRB(anc_id_80,'(]',1,1) -1)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,1) + 2
       ,INSTRB(anc_id_80,'(]',1,2) -
        INSTRB(anc_id_80,'(]',1,1) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,2) + 2
       ,INSTRB(anc_id_80,'(]',1,3) -
        INSTRB(anc_id_80,'(]',1,2) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,3) + 2
       ,INSTRB(anc_id_80,'(]',1,4) -
        INSTRB(anc_id_80,'(]',1,3) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,4) + 2
       ,INSTRB(anc_id_80,'(]',1,5) -
        INSTRB(anc_id_80,'(]',1,4) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,5) + 2
       ,INSTRB(anc_id_80,'(]',1,6) -
        INSTRB(anc_id_80,'(]',1,5) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,6) + 2
       ,INSTRB(anc_id_80,'(]',1,7) -
        INSTRB(anc_id_80,'(]',1,6) - 2)
,SUBSTRB(anc_id_80
       ,INSTRB(anc_id_80,'(]',1,7) + 2
       ,LENGTHB(anc_id_80))
)

WHEN anc_id_81 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_81
       ,1
       ,INSTRB(anc_id_81,'(]',1,1) -1)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,1) + 2
       ,INSTRB(anc_id_81,'(]',1,2) -
        INSTRB(anc_id_81,'(]',1,1) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,2) + 2
       ,INSTRB(anc_id_81,'(]',1,3) -
        INSTRB(anc_id_81,'(]',1,2) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,3) + 2
       ,INSTRB(anc_id_81,'(]',1,4) -
        INSTRB(anc_id_81,'(]',1,3) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,4) + 2
       ,INSTRB(anc_id_81,'(]',1,5) -
        INSTRB(anc_id_81,'(]',1,4) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,5) + 2
       ,INSTRB(anc_id_81,'(]',1,6) -
        INSTRB(anc_id_81,'(]',1,5) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,6) + 2
       ,INSTRB(anc_id_81,'(]',1,7) -
        INSTRB(anc_id_81,'(]',1,6) - 2)
,SUBSTRB(anc_id_81
       ,INSTRB(anc_id_81,'(]',1,7) + 2
       ,LENGTHB(anc_id_81))
)

WHEN anc_id_82 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_82
       ,1
       ,INSTRB(anc_id_82,'(]',1,1) -1)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,1) + 2
       ,INSTRB(anc_id_82,'(]',1,2) -
        INSTRB(anc_id_82,'(]',1,1) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,2) + 2
       ,INSTRB(anc_id_82,'(]',1,3) -
        INSTRB(anc_id_82,'(]',1,2) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,3) + 2
       ,INSTRB(anc_id_82,'(]',1,4) -
        INSTRB(anc_id_82,'(]',1,3) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,4) + 2
       ,INSTRB(anc_id_82,'(]',1,5) -
        INSTRB(anc_id_82,'(]',1,4) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,5) + 2
       ,INSTRB(anc_id_82,'(]',1,6) -
        INSTRB(anc_id_82,'(]',1,5) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,6) + 2
       ,INSTRB(anc_id_82,'(]',1,7) -
        INSTRB(anc_id_82,'(]',1,6) - 2)
,SUBSTRB(anc_id_82
       ,INSTRB(anc_id_82,'(]',1,7) + 2
       ,LENGTHB(anc_id_82))
)

WHEN anc_id_83 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_83
       ,1
       ,INSTRB(anc_id_83,'(]',1,1) -1)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,1) + 2
       ,INSTRB(anc_id_83,'(]',1,2) -
        INSTRB(anc_id_83,'(]',1,1) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,2) + 2
       ,INSTRB(anc_id_83,'(]',1,3) -
        INSTRB(anc_id_83,'(]',1,2) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,3) + 2
       ,INSTRB(anc_id_83,'(]',1,4) -
        INSTRB(anc_id_83,'(]',1,3) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,4) + 2
       ,INSTRB(anc_id_83,'(]',1,5) -
        INSTRB(anc_id_83,'(]',1,4) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,5) + 2
       ,INSTRB(anc_id_83,'(]',1,6) -
        INSTRB(anc_id_83,'(]',1,5) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,6) + 2
       ,INSTRB(anc_id_83,'(]',1,7) -
        INSTRB(anc_id_83,'(]',1,6) - 2)
,SUBSTRB(anc_id_83
       ,INSTRB(anc_id_83,'(]',1,7) + 2
       ,LENGTHB(anc_id_83))
)

WHEN anc_id_84 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_84
       ,1
       ,INSTRB(anc_id_84,'(]',1,1) -1)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,1) + 2
       ,INSTRB(anc_id_84,'(]',1,2) -
        INSTRB(anc_id_84,'(]',1,1) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,2) + 2
       ,INSTRB(anc_id_84,'(]',1,3) -
        INSTRB(anc_id_84,'(]',1,2) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,3) + 2
       ,INSTRB(anc_id_84,'(]',1,4) -
        INSTRB(anc_id_84,'(]',1,3) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,4) + 2
       ,INSTRB(anc_id_84,'(]',1,5) -
        INSTRB(anc_id_84,'(]',1,4) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,5) + 2
       ,INSTRB(anc_id_84,'(]',1,6) -
        INSTRB(anc_id_84,'(]',1,5) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,6) + 2
       ,INSTRB(anc_id_84,'(]',1,7) -
        INSTRB(anc_id_84,'(]',1,6) - 2)
,SUBSTRB(anc_id_84
       ,INSTRB(anc_id_84,'(]',1,7) + 2
       ,LENGTHB(anc_id_84))
)

WHEN anc_id_85 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_85
       ,1
       ,INSTRB(anc_id_85,'(]',1,1) -1)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,1) + 2
       ,INSTRB(anc_id_85,'(]',1,2) -
        INSTRB(anc_id_85,'(]',1,1) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,2) + 2
       ,INSTRB(anc_id_85,'(]',1,3) -
        INSTRB(anc_id_85,'(]',1,2) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,3) + 2
       ,INSTRB(anc_id_85,'(]',1,4) -
        INSTRB(anc_id_85,'(]',1,3) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,4) + 2
       ,INSTRB(anc_id_85,'(]',1,5) -
        INSTRB(anc_id_85,'(]',1,4) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,5) + 2
       ,INSTRB(anc_id_85,'(]',1,6) -
        INSTRB(anc_id_85,'(]',1,5) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,6) + 2
       ,INSTRB(anc_id_85,'(]',1,7) -
        INSTRB(anc_id_85,'(]',1,6) - 2)
,SUBSTRB(anc_id_85
       ,INSTRB(anc_id_85,'(]',1,7) + 2
       ,LENGTHB(anc_id_85))
)

WHEN anc_id_86 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_86
       ,1
       ,INSTRB(anc_id_86,'(]',1,1) -1)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,1) + 2
       ,INSTRB(anc_id_86,'(]',1,2) -
        INSTRB(anc_id_86,'(]',1,1) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,2) + 2
       ,INSTRB(anc_id_86,'(]',1,3) -
        INSTRB(anc_id_86,'(]',1,2) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,3) + 2
       ,INSTRB(anc_id_86,'(]',1,4) -
        INSTRB(anc_id_86,'(]',1,3) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,4) + 2
       ,INSTRB(anc_id_86,'(]',1,5) -
        INSTRB(anc_id_86,'(]',1,4) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,5) + 2
       ,INSTRB(anc_id_86,'(]',1,6) -
        INSTRB(anc_id_86,'(]',1,5) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,6) + 2
       ,INSTRB(anc_id_86,'(]',1,7) -
        INSTRB(anc_id_86,'(]',1,6) - 2)
,SUBSTRB(anc_id_86
       ,INSTRB(anc_id_86,'(]',1,7) + 2
       ,LENGTHB(anc_id_86))
)

WHEN anc_id_87 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_87
       ,1
       ,INSTRB(anc_id_87,'(]',1,1) -1)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,1) + 2
       ,INSTRB(anc_id_87,'(]',1,2) -
        INSTRB(anc_id_87,'(]',1,1) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,2) + 2
       ,INSTRB(anc_id_87,'(]',1,3) -
        INSTRB(anc_id_87,'(]',1,2) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,3) + 2
       ,INSTRB(anc_id_87,'(]',1,4) -
        INSTRB(anc_id_87,'(]',1,3) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,4) + 2
       ,INSTRB(anc_id_87,'(]',1,5) -
        INSTRB(anc_id_87,'(]',1,4) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,5) + 2
       ,INSTRB(anc_id_87,'(]',1,6) -
        INSTRB(anc_id_87,'(]',1,5) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,6) + 2
       ,INSTRB(anc_id_87,'(]',1,7) -
        INSTRB(anc_id_87,'(]',1,6) - 2)
,SUBSTRB(anc_id_87
       ,INSTRB(anc_id_87,'(]',1,7) + 2
       ,LENGTHB(anc_id_87))
)

WHEN anc_id_88 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_88
       ,1
       ,INSTRB(anc_id_88,'(]',1,1) -1)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,1) + 2
       ,INSTRB(anc_id_88,'(]',1,2) -
        INSTRB(anc_id_88,'(]',1,1) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,2) + 2
       ,INSTRB(anc_id_88,'(]',1,3) -
        INSTRB(anc_id_88,'(]',1,2) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,3) + 2
       ,INSTRB(anc_id_88,'(]',1,4) -
        INSTRB(anc_id_88,'(]',1,3) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,4) + 2
       ,INSTRB(anc_id_88,'(]',1,5) -
        INSTRB(anc_id_88,'(]',1,4) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,5) + 2
       ,INSTRB(anc_id_88,'(]',1,6) -
        INSTRB(anc_id_88,'(]',1,5) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,6) + 2
       ,INSTRB(anc_id_88,'(]',1,7) -
        INSTRB(anc_id_88,'(]',1,6) - 2)
,SUBSTRB(anc_id_88
       ,INSTRB(anc_id_88,'(]',1,7) + 2
       ,LENGTHB(anc_id_88))
)

WHEN anc_id_89 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_89
       ,1
       ,INSTRB(anc_id_89,'(]',1,1) -1)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,1) + 2
       ,INSTRB(anc_id_89,'(]',1,2) -
        INSTRB(anc_id_89,'(]',1,1) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,2) + 2
       ,INSTRB(anc_id_89,'(]',1,3) -
        INSTRB(anc_id_89,'(]',1,2) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,3) + 2
       ,INSTRB(anc_id_89,'(]',1,4) -
        INSTRB(anc_id_89,'(]',1,3) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,4) + 2
       ,INSTRB(anc_id_89,'(]',1,5) -
        INSTRB(anc_id_89,'(]',1,4) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,5) + 2
       ,INSTRB(anc_id_89,'(]',1,6) -
        INSTRB(anc_id_89,'(]',1,5) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,6) + 2
       ,INSTRB(anc_id_89,'(]',1,7) -
        INSTRB(anc_id_89,'(]',1,6) - 2)
,SUBSTRB(anc_id_89
       ,INSTRB(anc_id_89,'(]',1,7) + 2
       ,LENGTHB(anc_id_89))
)

WHEN anc_id_90 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_90
       ,1
       ,INSTRB(anc_id_90,'(]',1,1) -1)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,1) + 2
       ,INSTRB(anc_id_90,'(]',1,2) -
        INSTRB(anc_id_90,'(]',1,1) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,2) + 2
       ,INSTRB(anc_id_90,'(]',1,3) -
        INSTRB(anc_id_90,'(]',1,2) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,3) + 2
       ,INSTRB(anc_id_90,'(]',1,4) -
        INSTRB(anc_id_90,'(]',1,3) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,4) + 2
       ,INSTRB(anc_id_90,'(]',1,5) -
        INSTRB(anc_id_90,'(]',1,4) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,5) + 2
       ,INSTRB(anc_id_90,'(]',1,6) -
        INSTRB(anc_id_90,'(]',1,5) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,6) + 2
       ,INSTRB(anc_id_90,'(]',1,7) -
        INSTRB(anc_id_90,'(]',1,6) - 2)
,SUBSTRB(anc_id_90
       ,INSTRB(anc_id_90,'(]',1,7) + 2
       ,LENGTHB(anc_id_90))
)

WHEN anc_id_91 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_91
       ,1
       ,INSTRB(anc_id_91,'(]',1,1) -1)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,1) + 2
       ,INSTRB(anc_id_91,'(]',1,2) -
        INSTRB(anc_id_91,'(]',1,1) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,2) + 2
       ,INSTRB(anc_id_91,'(]',1,3) -
        INSTRB(anc_id_91,'(]',1,2) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,3) + 2
       ,INSTRB(anc_id_91,'(]',1,4) -
        INSTRB(anc_id_91,'(]',1,3) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,4) + 2
       ,INSTRB(anc_id_91,'(]',1,5) -
        INSTRB(anc_id_91,'(]',1,4) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,5) + 2
       ,INSTRB(anc_id_91,'(]',1,6) -
        INSTRB(anc_id_91,'(]',1,5) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,6) + 2
       ,INSTRB(anc_id_91,'(]',1,7) -
        INSTRB(anc_id_91,'(]',1,6) - 2)
,SUBSTRB(anc_id_91
       ,INSTRB(anc_id_91,'(]',1,7) + 2
       ,LENGTHB(anc_id_91))
)

WHEN anc_id_92 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_92
       ,1
       ,INSTRB(anc_id_92,'(]',1,1) -1)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,1) + 2
       ,INSTRB(anc_id_92,'(]',1,2) -
        INSTRB(anc_id_92,'(]',1,1) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,2) + 2
       ,INSTRB(anc_id_92,'(]',1,3) -
        INSTRB(anc_id_92,'(]',1,2) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,3) + 2
       ,INSTRB(anc_id_92,'(]',1,4) -
        INSTRB(anc_id_92,'(]',1,3) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,4) + 2
       ,INSTRB(anc_id_92,'(]',1,5) -
        INSTRB(anc_id_92,'(]',1,4) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,5) + 2
       ,INSTRB(anc_id_92,'(]',1,6) -
        INSTRB(anc_id_92,'(]',1,5) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,6) + 2
       ,INSTRB(anc_id_92,'(]',1,7) -
        INSTRB(anc_id_92,'(]',1,6) - 2)
,SUBSTRB(anc_id_92
       ,INSTRB(anc_id_92,'(]',1,7) + 2
       ,LENGTHB(anc_id_92))
)

WHEN anc_id_93 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_93
       ,1
       ,INSTRB(anc_id_93,'(]',1,1) -1)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,1) + 2
       ,INSTRB(anc_id_93,'(]',1,2) -
        INSTRB(anc_id_93,'(]',1,1) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,2) + 2
       ,INSTRB(anc_id_93,'(]',1,3) -
        INSTRB(anc_id_93,'(]',1,2) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,3) + 2
       ,INSTRB(anc_id_93,'(]',1,4) -
        INSTRB(anc_id_93,'(]',1,3) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,4) + 2
       ,INSTRB(anc_id_93,'(]',1,5) -
        INSTRB(anc_id_93,'(]',1,4) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,5) + 2
       ,INSTRB(anc_id_93,'(]',1,6) -
        INSTRB(anc_id_93,'(]',1,5) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,6) + 2
       ,INSTRB(anc_id_93,'(]',1,7) -
        INSTRB(anc_id_93,'(]',1,6) - 2)
,SUBSTRB(anc_id_93
       ,INSTRB(anc_id_93,'(]',1,7) + 2
       ,LENGTHB(anc_id_93))
)

WHEN anc_id_94 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_94
       ,1
       ,INSTRB(anc_id_94,'(]',1,1) -1)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,1) + 2
       ,INSTRB(anc_id_94,'(]',1,2) -
        INSTRB(anc_id_94,'(]',1,1) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,2) + 2
       ,INSTRB(anc_id_94,'(]',1,3) -
        INSTRB(anc_id_94,'(]',1,2) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,3) + 2
       ,INSTRB(anc_id_94,'(]',1,4) -
        INSTRB(anc_id_94,'(]',1,3) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,4) + 2
       ,INSTRB(anc_id_94,'(]',1,5) -
        INSTRB(anc_id_94,'(]',1,4) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,5) + 2
       ,INSTRB(anc_id_94,'(]',1,6) -
        INSTRB(anc_id_94,'(]',1,5) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,6) + 2
       ,INSTRB(anc_id_94,'(]',1,7) -
        INSTRB(anc_id_94,'(]',1,6) - 2)
,SUBSTRB(anc_id_94
       ,INSTRB(anc_id_94,'(]',1,7) + 2
       ,LENGTHB(anc_id_94))
)

WHEN anc_id_95 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_95
       ,1
       ,INSTRB(anc_id_95,'(]',1,1) -1)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,1) + 2
       ,INSTRB(anc_id_95,'(]',1,2) -
        INSTRB(anc_id_95,'(]',1,1) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,2) + 2
       ,INSTRB(anc_id_95,'(]',1,3) -
        INSTRB(anc_id_95,'(]',1,2) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,3) + 2
       ,INSTRB(anc_id_95,'(]',1,4) -
        INSTRB(anc_id_95,'(]',1,3) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,4) + 2
       ,INSTRB(anc_id_95,'(]',1,5) -
        INSTRB(anc_id_95,'(]',1,4) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,5) + 2
       ,INSTRB(anc_id_95,'(]',1,6) -
        INSTRB(anc_id_95,'(]',1,5) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,6) + 2
       ,INSTRB(anc_id_95,'(]',1,7) -
        INSTRB(anc_id_95,'(]',1,6) - 2)
,SUBSTRB(anc_id_95
       ,INSTRB(anc_id_95,'(]',1,7) + 2
       ,LENGTHB(anc_id_95))
)

WHEN anc_id_96 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_96
       ,1
       ,INSTRB(anc_id_96,'(]',1,1) -1)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,1) + 2
       ,INSTRB(anc_id_96,'(]',1,2) -
        INSTRB(anc_id_96,'(]',1,1) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,2) + 2
       ,INSTRB(anc_id_96,'(]',1,3) -
        INSTRB(anc_id_96,'(]',1,2) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,3) + 2
       ,INSTRB(anc_id_96,'(]',1,4) -
        INSTRB(anc_id_96,'(]',1,3) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,4) + 2
       ,INSTRB(anc_id_96,'(]',1,5) -
        INSTRB(anc_id_96,'(]',1,4) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,5) + 2
       ,INSTRB(anc_id_96,'(]',1,6) -
        INSTRB(anc_id_96,'(]',1,5) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,6) + 2
       ,INSTRB(anc_id_96,'(]',1,7) -
        INSTRB(anc_id_96,'(]',1,6) - 2)
,SUBSTRB(anc_id_96
       ,INSTRB(anc_id_96,'(]',1,7) + 2
       ,LENGTHB(anc_id_96))
)

WHEN anc_id_97 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_97
       ,1
       ,INSTRB(anc_id_97,'(]',1,1) -1)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,1) + 2
       ,INSTRB(anc_id_97,'(]',1,2) -
        INSTRB(anc_id_97,'(]',1,1) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,2) + 2
       ,INSTRB(anc_id_97,'(]',1,3) -
        INSTRB(anc_id_97,'(]',1,2) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,3) + 2
       ,INSTRB(anc_id_97,'(]',1,4) -
        INSTRB(anc_id_97,'(]',1,3) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,4) + 2
       ,INSTRB(anc_id_97,'(]',1,5) -
        INSTRB(anc_id_97,'(]',1,4) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,5) + 2
       ,INSTRB(anc_id_97,'(]',1,6) -
        INSTRB(anc_id_97,'(]',1,5) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,6) + 2
       ,INSTRB(anc_id_97,'(]',1,7) -
        INSTRB(anc_id_97,'(]',1,6) - 2)
,SUBSTRB(anc_id_97
       ,INSTRB(anc_id_97,'(]',1,7) + 2
       ,LENGTHB(anc_id_97))
)

WHEN anc_id_98 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_98
       ,1
       ,INSTRB(anc_id_98,'(]',1,1) -1)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,1) + 2
       ,INSTRB(anc_id_98,'(]',1,2) -
        INSTRB(anc_id_98,'(]',1,1) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,2) + 2
       ,INSTRB(anc_id_98,'(]',1,3) -
        INSTRB(anc_id_98,'(]',1,2) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,3) + 2
       ,INSTRB(anc_id_98,'(]',1,4) -
        INSTRB(anc_id_98,'(]',1,3) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,4) + 2
       ,INSTRB(anc_id_98,'(]',1,5) -
        INSTRB(anc_id_98,'(]',1,4) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,5) + 2
       ,INSTRB(anc_id_98,'(]',1,6) -
        INSTRB(anc_id_98,'(]',1,5) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,6) + 2
       ,INSTRB(anc_id_98,'(]',1,7) -
        INSTRB(anc_id_98,'(]',1,6) - 2)
,SUBSTRB(anc_id_98
       ,INSTRB(anc_id_98,'(]',1,7) + 2
       ,LENGTHB(anc_id_98))
)

WHEN anc_id_99 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_99
       ,1
       ,INSTRB(anc_id_99,'(]',1,1) -1)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,1) + 2
       ,INSTRB(anc_id_99,'(]',1,2) -
        INSTRB(anc_id_99,'(]',1,1) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,2) + 2
       ,INSTRB(anc_id_99,'(]',1,3) -
        INSTRB(anc_id_99,'(]',1,2) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,3) + 2
       ,INSTRB(anc_id_99,'(]',1,4) -
        INSTRB(anc_id_99,'(]',1,3) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,4) + 2
       ,INSTRB(anc_id_99,'(]',1,5) -
        INSTRB(anc_id_99,'(]',1,4) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,5) + 2
       ,INSTRB(anc_id_99,'(]',1,6) -
        INSTRB(anc_id_99,'(]',1,5) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,6) + 2
       ,INSTRB(anc_id_99,'(]',1,7) -
        INSTRB(anc_id_99,'(]',1,6) - 2)
,SUBSTRB(anc_id_99
       ,INSTRB(anc_id_99,'(]',1,7) + 2
       ,LENGTHB(anc_id_99))
)

WHEN anc_id_100 IS NOT NULL THEN
  INTO xla_ae_header_acs (
        ae_header_id , object_version_number
      , analytical_criterion_code
      , analytical_criterion_type_code
      , amb_context_code
      , ac1,ac2,ac3,ac4,ac5)
VALUES (ae_header_id, C_OVN
,SUBSTRB(anc_id_100
       ,1
       ,INSTRB(anc_id_100,'(]',1,1) -1)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,1) + 2
       ,INSTRB(anc_id_100,'(]',1,2) -
        INSTRB(anc_id_100,'(]',1,1) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,2) + 2
       ,INSTRB(anc_id_100,'(]',1,3) -
        INSTRB(anc_id_100,'(]',1,2) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,3) + 2
       ,INSTRB(anc_id_100,'(]',1,4) -
        INSTRB(anc_id_100,'(]',1,3) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,4) + 2
       ,INSTRB(anc_id_100,'(]',1,5) -
        INSTRB(anc_id_100,'(]',1,4) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,5) + 2
       ,INSTRB(anc_id_100,'(]',1,6) -
        INSTRB(anc_id_100,'(]',1,5) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,6) + 2
       ,INSTRB(anc_id_100,'(]',1,7) -
        INSTRB(anc_id_100,'(]',1,6) - 2)
,SUBSTRB(anc_id_100
       ,INSTRB(anc_id_100,'(]',1,7) + 2
       ,LENGTHB(anc_id_100))
)
SELECT  ae_header_id
      , anc_id_1
      , anc_id_2
      , anc_id_3
      , anc_id_4
      , anc_id_5
      , anc_id_6
      , anc_id_7
      , anc_id_8
      , anc_id_9
      , anc_id_10
      , anc_id_11
      , anc_id_12
      , anc_id_13
      , anc_id_14
      , anc_id_15
      , anc_id_16
      , anc_id_17
      , anc_id_18
      , anc_id_19
      , anc_id_20
      , anc_id_21
      , anc_id_22
      , anc_id_23
      , anc_id_24
      , anc_id_25
      , anc_id_26
      , anc_id_27
      , anc_id_28
      , anc_id_29
      , anc_id_30
      , anc_id_31
      , anc_id_32
      , anc_id_33
      , anc_id_34
      , anc_id_35
      , anc_id_36
      , anc_id_37
      , anc_id_38
      , anc_id_39
      , anc_id_40
      , anc_id_41
      , anc_id_42
      , anc_id_43
      , anc_id_44
      , anc_id_45
      , anc_id_46
      , anc_id_47
      , anc_id_48
      , anc_id_49
      , anc_id_50
      , anc_id_51
      , anc_id_52
      , anc_id_53
      , anc_id_54
      , anc_id_55
      , anc_id_56
      , anc_id_57
      , anc_id_58
      , anc_id_59
      , anc_id_60
      , anc_id_61
      , anc_id_62
      , anc_id_63
      , anc_id_64
      , anc_id_65
      , anc_id_66
      , anc_id_67
      , anc_id_68
      , anc_id_69
      , anc_id_70
      , anc_id_71
      , anc_id_72
      , anc_id_73
      , anc_id_74
      , anc_id_75
      , anc_id_76
      , anc_id_77
      , anc_id_78
      , anc_id_79
      , anc_id_80
      , anc_id_81
      , anc_id_82
      , anc_id_83
      , anc_id_84
      , anc_id_85
      , anc_id_86
      , anc_id_87
      , anc_id_88
      , anc_id_89
      , anc_id_90
      , anc_id_91
      , anc_id_92
      , anc_id_93
      , anc_id_94
      , anc_id_95
      , anc_id_96
      , anc_id_97
      , anc_id_98
      , anc_id_99
      , anc_id_100
 FROM  xla_ae_headers_gt
WHERE  ae_header_id is not null;

--
IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# header analytical criteria inserted into xla_ae_header_acs = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
END IF;

--
EXCEPTION
WHEN OTHERS THEN
  IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
         trace
            (p_msg      => 'ERROR: XLA_AP_CANNOT_INSERT_JE ='||sqlerrm
            ,p_level    => C_LEVEL_EXCEPTION
            ,p_module   => l_log_module);
  END IF;

  xla_exceptions_pkg.raise_message  (p_appli_s_name => 'XLA'
                                    ,p_msg_name     => 'XLA_AP_CANNOT_INSERT_JE'
                                    ,p_token_1      => 'ERROR'
                                    ,p_value_1      => sqlerrm
                                    );
END;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of InsertHdrAnalyticalCriteria100'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertHdrAnalyticalCriteria100');
   --
END InsertHdrAnalyticalCriteria100;
--
/*======================================================================+
|                                                                       |
| Insert final headers and distribution links                           |
|                                                                       |
| Returns 0 if lines inserted in final tables                           |
| Otherwise 2 (if no lines inserted in final tables)                    |
+======================================================================*/
--
FUNCTION InsertJournalEntries
(p_application_id         IN INTEGER
,p_accounting_batch_id    IN NUMBER
,p_end_date               IN DATE     -- 4262811
-- bulk performance
,p_accounting_mode        IN VARCHAR2
,p_budgetary_control_mode IN VARCHAR2) -- 4458381 Public Sector Enh
RETURN NUMBER
IS
  l_result             NUMBER;
  l_log_module         VARCHAR2(240);
BEGIN

  --
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.InsertJournalEntries';
  END IF;
  --
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg      => 'BEGIN of InsertJournalEntries'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  --
  SetStandardWhoColumn;
  --l_result := XLA_AE_CODE_COMBINATION_PKG.BuildCcids;

  --=========================
  -- Insert journal entries
  --=========================

  l_result := 0;
  GetLineNumber;

  IF (InsertLines(p_application_id, p_budgetary_control_mode) +
      InsertHeaders(p_application_id,p_accounting_batch_id
                   ,p_end_date  -- 4262811
                   -- bulk performance
                   ,p_accounting_mode) > 0 ) THEN

      InsertLinks(p_application_id);
      AdjustMpaLine(p_application_id);   -- 4262811b

      --
      -- Retrieve the number ACs assigned. Call Insert ACs only when
      -- ACs are assigned.
      --
      g_line_ac_count := xla_analytical_criteria_pkg.get_line_ac_count;
      g_hdr_ac_count  := xla_analytical_criteria_pkg.get_hdr_ac_count;

      IF g_line_ac_count > 0 THEN
         InsertAnalyticalCriteria;
      END IF;

      IF g_hdr_ac_count > 0 THEN
         InsertHdrAnalyticalCriteria;
      END IF;
   -- AdjustMpaRevLine(p_application_id);   -- added for 4669308, removed for 5017009

      l_result := 0;

    ELSE
      l_result:= 2;
    END IF;

  --
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg      => 'return value. = '||TO_CHAR(l_result)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace(p_msg      => 'END of InsertJournalEntries'
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
                (p_location => 'XLA_AE_JOURNAL_ENTRY_PKG.InsertJournalEntries');
   --
END InsertJournalEntries;
--

/*======================================================================+
|                                                                       |
| Public PROCEDURE - 4219869                                            |
|                                                                       |
|  Update the journal entry header status for specified balance type.   |
+======================================================================*/
--
PROCEDURE UpdateJournalEntryStatus(  p_hdr_idx              IN NUMBER
                                   , p_balance_type_code    IN VARCHAR2
)
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateJournalEntryStatus';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
trace
     (p_msg      => 'BEGIN of UpdateJournalEntryStatus'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'g_global_status [0 is valid, 1 is invalid] = '||g_global_status
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF g_global_status = C_INVALID THEN
   CASE p_balance_type_code
      WHEN 'A' THEN
         XLA_AE_HEADER_PKG.g_rec_header_new.array_actual_status(p_hdr_idx) := C_INVALID;
      WHEN 'B' THEN
         XLA_AE_HEADER_PKG.g_rec_header_new.array_budget_status(p_hdr_idx) := C_INVALID;
      WHEN 'E' THEN
         XLA_AE_HEADER_PKG.g_rec_header_new.array_encumbrance_status(p_hdr_idx) := C_INVALID;
   END CASE;
   --
   -- update event status on the header record to invalid if the line created is invalid.
   --
   XLA_AE_HEADER_PKG.g_rec_header_new.array_event_status(p_hdr_idx) := 'I';
   --
   -- reset the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
   --
   g_global_status := C_VALID;
   --
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
trace
     (p_msg      => 'END of UpdateJournalEntryStatus'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;

EXCEPTION
--
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_journal_entry_pkg.UpdateJournalEntryStatus');
  --
END UpdateJournalEntryStatus;

/*======================================================================+
|                                                                       |
| Public PROCEDURE - 4262811 (for MPA)                                  |
|                                                                       |
|  Update the journal entry header status for specified balance type.   |
|                                                                       |
|  Parameter: p_hdr_idx                                                 |
|                                                                       |
+======================================================================*/
--
PROCEDURE UpdateJournalEntryStatus(  p_hdr_idx              IN NUMBER
)
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.UpdateJournalEntryStatus - p_hdr_idx';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
trace
     (p_msg      => 'BEGIN of UpdateJournalEntryStatus - p_hdr_idx'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'g_global_status [0 is valid, 1 is invalid] = '||g_global_status -- 5019460
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF g_global_status = C_INVALID THEN

   XLA_AE_HEADER_PKG.g_rec_header_new.array_actual_status(p_hdr_idx)      := C_INVALID;
   XLA_AE_HEADER_PKG.g_rec_header_new.array_budget_status(p_hdr_idx)      := C_INVALID;
   XLA_AE_HEADER_PKG.g_rec_header_new.array_encumbrance_status(p_hdr_idx) := C_INVALID;
   --
   -- update event status on the header record to invalid if the line created is invalid.
   --
   XLA_AE_HEADER_PKG.g_rec_header_new.array_event_status(p_hdr_idx) := 'I';
   --
   -- reset the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
   --
   g_global_status := C_VALID;
   --
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
trace
     (p_msg      => 'END of UpdateJournalEntryStatus - p_hdr_idx'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;

EXCEPTION
--
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_journal_entry_pkg.UpdateJournalEntryStatus - p_hdr_idx');
  --
END UpdateJournalEntryStatus;


/*======================================================================+
|                                                                       |
| PRIVATE Procedure: insert_diag_event                                  |
|                                                                       |
|    Called by Diagnostic framework to store event info.                |
+======================================================================*/
--
PROCEDURE insert_diag_event(
                               p_event_id                       IN NUMBER
                              ,p_application_id                 IN NUMBER
                              ,p_ledger_id                      IN NUMBER
                              ,p_transaction_num                IN VARCHAR2
                              ,p_entity_code                    IN VARCHAR2
                              ,p_event_class_code               IN VARCHAR2
                              ,p_event_type_code                IN VARCHAR2
                              ,p_event_number                   IN NUMBER
                              ,p_event_date                     IN DATE
)
IS
l_log_module         VARCHAR2(240);
l_count              NUMBER;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_diag_event';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
trace
     (p_msg      => 'BEGIN of insert_diag_event'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
         (p_msg      => 'SQL- Insert xla_diag_events the event_id ='||p_event_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

INSERT INTO xla_diag_events
   (
        event_id
      , application_id
      , ledger_id
      , transaction_number
      , event_number
      , event_date
      , entity_code
      , event_class_code
      , event_type_code
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
       xe.event_id
     , p_application_id
     , p_ledger_id
     , p_transaction_num
     , p_event_number
     , p_event_date
     , p_entity_code
     , p_event_class_code
     , p_event_type_code
     , xla_environment_pkg.g_Usr_Id
     , TRUNC(SYSDATE)
     , TRUNC(SYSDATE)
     , xla_environment_pkg.g_Usr_Id
     , xla_environment_pkg.g_Login_Id
     , TRUNC(SYSDATE)
     , xla_environment_pkg.g_Prog_Appl_Id
     , xla_environment_pkg.g_Prog_Id
     , xla_environment_pkg.g_Req_Id
  FROM xla_events_gt xe
 WHERE xe.event_id = p_event_id
   AND NOT EXISTS ( SELECT 'x'
                       FROM xla_diag_events
                      WHERE event_id       = p_event_id
                        AND application_id = p_application_id
                        AND ledger_id      = p_ledger_id
                   )
 ;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'Number of Diagnostic events inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
trace
     (p_msg      => 'END of insert_diag_event'
     ,p_level    => C_LEVEL_PROCEDURE
     ,p_module   => l_log_module);
END IF;

EXCEPTION
--
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_journal_entry_pkg.insert_diag_event');
  --
END insert_diag_event;

/*======================================================================+
|                                                                       |
+======================================================================*/
PROCEDURE set_event_info
   (p_application_id          IN NUMBER
   ,p_primary_ledger_id       IN NUMBER
   ,p_base_ledger_id          IN NUMBER
   ,p_target_ledger_id        IN NUMBER
   ,p_entity_id               IN NUMBER
   ,p_legal_entity_id         IN NUMBER
   ,p_entity_code             IN VARCHAR2
   ,p_transaction_num         IN VARCHAR2
   ,p_event_id                IN NUMBER
   ,p_event_class_code        IN VARCHAR2
   ,p_event_type_code         IN VARCHAR2
   ,p_event_number            IN NUMBER
   ,p_event_date              IN DATE
   ,p_transaction_date        IN DATE
   ,p_reference_num_1         IN NUMBER
   ,p_reference_num_2         IN NUMBER
   ,p_reference_num_3         IN NUMBER
   ,p_reference_num_4         IN NUMBER
   ,p_reference_char_1        IN VARCHAR2
   ,p_reference_char_2        IN VARCHAR2
   ,p_reference_char_3        IN VARCHAR2
   ,p_reference_char_4        IN VARCHAR2
   ,p_reference_date_1        IN DATE
   ,p_reference_date_2        IN DATE
   ,p_reference_date_3        IN DATE
   ,p_reference_date_4        IN DATE
   ,p_event_created_by        IN VARCHAR2
   ,p_budgetary_control_flag  IN VARCHAR2  -- 4458381 Public Sector Enh
) IS
l_temp               BOOLEAN;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_event_info';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of set_event_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_event_id = '||p_event_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
g_cache_event.application_id       := p_application_id;
--g_cache_event.application_name     := g_array_event(p_event_id).array_value_char('application_name');
g_cache_event.ledger_id            := p_primary_ledger_id;
g_cache_event.base_ledger_id       := p_base_ledger_id;
g_cache_event.target_ledger_id     := p_target_ledger_id;
g_cache_event.legal_entity_id      := p_legal_entity_id;
g_cache_event.entity_id            := p_entity_id;
g_cache_event.entity_code          := p_entity_code;
g_cache_event.transaction_num      := p_transaction_num;
g_cache_event.event_id             := p_event_id;
g_cache_event.event_class          := p_event_class_code;
g_cache_event.event_type           := p_event_type_code;
g_cache_event.event_number         := p_event_number;
g_cache_event.event_date           := p_event_date;
g_cache_event.transaction_date     := p_transaction_date;
g_cache_event.reference_num_1      := p_reference_num_1;
g_cache_event.reference_num_2      := p_reference_num_2;
g_cache_event.reference_num_3      := p_reference_num_3;
g_cache_event.reference_num_4      := p_reference_num_4;
g_cache_event.reference_char_1     := p_reference_char_1;
g_cache_event.reference_char_2     := p_reference_char_2;
g_cache_event.reference_char_3     := p_reference_char_3;
g_cache_event.reference_char_4     := p_reference_char_4;
g_cache_event.reference_date_1     := p_reference_date_1;
g_cache_event.reference_date_2     := p_reference_date_2;
g_cache_event.reference_date_3     := p_reference_date_3;
g_cache_event.reference_date_4     := p_reference_date_4;
g_cache_event.event_created_by     := p_event_created_by;
g_cache_event.budgetary_control_flag:= p_budgetary_control_flag; -- 4458381 Public Sector Enh
--g_cache_event.accounting_mode      := g_array_event(p_event_id).array_value_char('accounting_mode');
--g_cache_event.accounting_batch_id  := g_array_event(p_event_id).array_value_num('accounting_batch_id');

l_temp := GetTranslatedEventInfo;

IF ( xla_accounting_engine_pkg.g_diagnostics_mode = 'Y' )THEN

   trace
         (p_msg      => '-> Call Extract Source Values Disagnostics routine'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   insert_diag_event ( p_event_id         => p_event_id
                      ,p_application_id   => p_application_id
                      ,p_ledger_id        => p_primary_ledger_id
                      ,p_transaction_num  => p_transaction_num
                      ,p_entity_code      => p_entity_code
                      ,p_event_class_code => p_event_class_code
                      ,p_event_type_code  => p_event_type_code
                      ,p_event_number     => p_event_number
                      ,p_event_date       => p_event_date
                      );
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of set_event_info'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
END set_event_info;

/*======================================================================+
|   PRIVATE PROCEDURE :   Insert_ANC_Inv_Canc                           |
|   Bug# 7382288:Insert analytical criteria for invoice cancellation    |
|    into xla_ae_line_acs table if analytical criteria exists for       |
|   invoice validation event.                                           |
+======================================================================*/
procedure Insert_ANC_Inv_Canc
is
l_rowcount           NUMBER;
l_log_module         VARCHAR2(240);
l_array_base_ledgers    xla_accounting_cache_pkg.t_array_ledger_id;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertAnalyticalCriteria_Inv_canc';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of InsertAnalyticalCriteria_Inv_canc'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_rowcount  := 0;
l_array_base_ledgers := xla_accounting_cache_pkg.GetLedgers;

for i in 1..l_array_base_ledgers.count loop
insert into xla_ae_line_acs (
	ae_header_id,
	ae_line_num,
	analytical_criterion_code,
	analytical_criterion_type_code,
	amb_context_code,
	object_version_number,
	ac1,
	ac2,
	ac3,
	ac4,
	ac5)
	(select    /*+ index(gt XLA_AE_LINES_GT_U1) */
                       gt.ae_header_id,
                       gt.ae_line_num,
                       la.analytical_criterion_code,
                       la.analytical_criterion_type_code,
                       la.amb_context_code,
                       la.object_version_number,
                       la.ac1,
                       la.ac2,
                       la.ac3,
                       la.ac4,
                       la.ac5
                from xla_ae_line_acs la,
                     xla_ae_lines_gt gt
                where la.ae_header_id=gt.ref_ae_header_id
                and gt.ref_ae_header_id<> gt.ae_header_id
                and la.ae_line_num = gt.ref_ae_line_num
                and gt.ref_ae_line_num is not null
                and gt.temp_line_num <0
                and gt.ledger_id = l_array_base_ledgers(i)
                and gt.reversal_code='REVERSAL'
		group by
                       gt.ae_header_id,
                       gt.ae_line_num,
                       la.analytical_criterion_code,
                       la.analytical_criterion_type_code,
                       la.amb_context_code,
                       la.object_version_number,
                       la.ac1,
                       la.ac2,
                       la.ac3,
                       la.ac4,
                       la.ac5
	);
  end loop;



   l_rowcount := SQL%ROWCOUNT;

   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# line analytical criteria inserted in xla_ae_line_acs for invoice cancellation = '||l_rowcount
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;


END Insert_ANC_Inv_Canc;
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

END xla_ae_journal_entry_pkg;

/
