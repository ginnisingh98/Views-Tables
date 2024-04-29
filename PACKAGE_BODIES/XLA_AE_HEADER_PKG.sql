--------------------------------------------------------
--  DDL for Package Body XLA_AE_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AE_HEADER_PKG" AS
/* $Header: xlajehdr.pkb 120.59.12010000.8 2010/02/08 23:17:47 kapkumar ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_AE_HEADER_PKG                                                      |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema  Created                                        |
|     08-JAN-2003 K.Boussema  Changed xla_temp_journal_entries by            |
|                              xla_journal_entries_temp                      |
|     10-JAN-2003 K.Boussema  Removed gl_sl_link_id column from temp table   |
|                             Added 'dbdrv' command                          |
|     10-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|                             Changed xla_journal_entries_temp by            |
|                               xla_je_lines_temp                            |
|     01-APR-2003 K.Boussema    Included amb_context_code                    |
|     03-APR-2003 K.Boussema    Included Analytical criteria feature         |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     22-APR-2003 K.Boussema    Added DOC_CATEGORY_NAME source               |
|     28-APR-2003 K.Boussema    Added validation of Accounting Event Extract |
|                               bug 2925651                                  |
|     06-MAI-2003 K.Boussema    Modifcation included for bug2936071          |
|     13-MAI-2003 K.Boussema    Renamed temporary tables xla_je_lines_gt by  |
|                               xla_ae_lines_gt, xla_je_headers_gt by        |
|                               xla_ae_headers_gt                            |
|                               Renamed in xla_distribution_links the column |
|                               base_amount by ledger_amount                 |
|     20-MAI-2003 K.Boussema    Added a Token to XLA_AP_CANNOT_INSERT_JE     |
|                               message                                      |
|     27-MAI-2003 K.Boussema    Renamed the Document seq. Accounting sources |
|     27-MAI-2003 K.Boussema    Renamed code_combination_status by           |
|                                  code_combination_status_flag              |
|                               Renamed base_amount by ledger_amount         |
|     30-MAI-2003 K.Boussema   Renamed BUSGET_VERSION_ID by BUDGET_VERSION_ID|
|                               bug 2981358                                  |
|     11-JUN-2003 K.Boussema    Renamed Sequence columns, bug 3000007        |
|     23-JUN-2003 K.Boussema   Updated the call to get_period_name bug3005754|
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     17-SEP-2003 K.Boussema    Updated to Get je_category from cache:3109690|
|     19-SEP-2003 K.Boussema    Code changed to include reversed_ae_header_id|
|                               and reversed_line_num, see bug 3143095       |
|     03-OCT-2003 K.Boussema    Changed description width to 1996            |
|     16-OCT-2003 K.Boussema    Fixed the issue when the entered and         |
|                               accounted amounts are reversed.              |
|     22-OCT-2003 K.Boussema    Changed to capture the Merge Matching Lines  |
|                               preference for Accounting Reversal from JLT  |
|     26-NOV-2003 K.Boussema    Removed the insert of the sl_coa_mapping name|
|                               for change third party lines, bug 3278955    |
|     12-DEC-2003 K. Boussema   Renamed target_coa_id in xla_ae_lines_gt     |
|                               by ccid_coa_id                               |
|                               Reviewed the InsertHeaders, bug 3042840      |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     07-JAN-2004 K.Boussema    Changed to populate switch_side_flag column  |
|     19-JAN-2004 K.Boussema    Removed the validation of doc sequence       |
|     05-FEB-2004 S.Singhania   Changes based on bug 3419803.                |
|                                 - correct column names are used            |
|                                   TAX_LINE_REF_ID, TAX_SUMMARY_LINE_REF_ID,|
|                                   TAX_REC_NREC_DIST_REF_ID                 |
|                                 - reference to the column is removed.      |
|                                   TAX_REC_NREC_SUMMARY_DIST_REF            |
|     17-FEB-2004 K.Boussema    Made changes for the FND_LOG.                |
|                               passed ae_header_id to error messages        |
|     12-MAR-2004 K.Boussema    Removed the validation of the party type     |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                               and the procedure.                           |
|     29-MAR-2204 K.Boussema    Changed based on bug 3528667                 |
|                                - added get_period_name function to retrieve|
|                                the period_name from gl_period_statuses     |
|                                - added the cache of period_name            |
|                                - changed the insert into xla_ae_headers_gt |
|     11-MAY-2004 K.Boussema  Removed the call to XLA trace routine from     |
|                             trace() procedure                              |
|     17-MAY-2004 W.Shen      change for attribute enhancement project       |
|                             1. add TransactionReversal procedure from      |
|                                lines package                               |
|                             2. SetHdrAccountingSource, add gl_transfer_flag|
|                                and trx_acct_reversal_option                |
|                             3. SetHdrAccountingSource, add gl_date         |
|                             4. change to InsertHeaders procedure           |
|                             5. rename reversed_ae_header_id to             |
|                                ref_ae_header_id, reversed_ae_line_num to   |
|                                ref_ae_line_num                             |
|     26-MAY-2004 W.Shen      change error message                           |
|     02-JUL-2004 W.Shen      if gl_transfer_flag is not mapped at all, set  |
|                                the default value to 'N' instead of 'NT'    |
|                                bug 3741223                                 |
|     27-JUL-2004 W.Shen      In SetHeaderId, if all the 3 flag is 'N',      |
|                               (which is the case when transaction reversal)|
|                               3 header ids are generated and assigned      |
|                               bug 3786980                                  |
|     23-Sep-2004 S.Singhania Made changes for the bulk peroformance. It has |
|                               changed the code at number of places.        |
|     25-May-2005 W. Shen     Remove column ledger_amount,entered amount     |
|                               from xla_distribution_links, change the      |
|                               function change_third_party to remove the    |
|                               reference to the columns.                    |
|     11-Jul-2005 A. Wan      Changed for MPA.  4262811                      |
|     01-Aug-2005 W. Chan     4458381 - Public Sector Enhancement            |
|     18-Oct-2005 V. Kumar    Removed code for Analytical Criteria           |
|     23-Nov-2005 V. Kumar    Bug 4752774 - Added Hints for performance      |
|     3-Jan-2006  W. Chan     Bug 4924492 - Populate budget version id for   |
|                               accounting reversal                          |
|     20-JAN-2006 A.Wan       4884853 add GetAccrualRevDate                  |
|     07-FEB-2006 A.Wan       4897417 error if MPA's GL periods not defined. |
|     13-Feb-2006 A.Wan       4955764 - set MPA's g_rec_lines.array_gl_date  |
|     16-Apr-2006 A.Wan       5132302 - applied to amt for Gain/Loss         |
|     09-May-2006 A.Wan       5161760 - chk header attributes is valid.      |
|     21-Jun-2006 A.Wan       5100860 Performance fix, see bug for detail    |
|     01-Mar-2009 VGOPISET    7109881 Changed the call of CopyLineInfo from  |
|                                     CreateRecongitionEntries procedure     |
|     01-Mar-2009 VGOPISET    8214450 Changed GetRecognitionEntries to use   |
|                                     CEIL rather than ROUND in calculating  |
|                                    future GL_DATE for ORIGINATIONDAY option|
+===========================================================================*/
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| CONSTANTS                                                                |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
C_VALID             CONSTANT NUMBER        := 0;
C_INVALID           CONSTANT NUMBER        := 1;
--
--
C_STANDARD          CONSTANT VARCHAR2(30)  := 'STANDARD';
C_INVALID_STATUS    CONSTANT VARCHAR2(1)   := 'I';
C_DRAFT_STATUS      CONSTANT VARCHAR2(1)   := 'D';
C_FINAL_STATUS      CONSTANT VARCHAR2(1)   := 'F';
--
-- bulk performance
C_INCOMPLETE        CONSTANT VARCHAR2(1)   := 'X';
--
C_ACTUAL            CONSTANT VARCHAR2(1)   := 'A';
C_BUDGET            CONSTANT VARCHAR2(1)   := 'B';
C_ENCUMBRANCE       CONSTANT VARCHAR2(1)   := 'E';
--
--
C_ALL                 CONSTANT  VARCHAR2(1)    := 'A';
C_SAME_SIDE           CONSTANT  VARCHAR2(1)    := 'W';
C_NO_MERGE            CONSTANT  VARCHAR2(1)    := 'N';
--
C_CCID                   CONSTANT VARCHAR2(30)  := 'CREATED';

-- Application id for GL
C_GL_APPLICATION_ID             CONSTANT INTEGER := 101;
--
C_SWITCH               CONSTANT VARCHAR2(1)    := 'Y';
C_NO_SWITCH            CONSTANT VARCHAR2(1)    := 'N';
--
--====================================================================
--
--
--
--
--
--                                   FND_LOG trace
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
--======================================================================
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_AE_HEADER_PKG';

--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| PL/SQL structures                                                        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
-- period_name cache structure
--
TYPE t_rec_period_name IS RECORD
   (period_name                        VARCHAR2(25)
   ,ledger_id                          NUMBER
   ,start_date                         DATE
   ,end_date                           DATE
   )
;
--
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global Variables                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
-- period_name cache
--
g_cache_period_name    t_rec_period_name;
g_application_id               INTEGER :=  xla_accounting_cache_pkg.GetValueNum('XLA_EVENT_APPL_ID');

--
--
-- FND log global variables
--

g_log_level            NUMBER;
g_log_enabled          BOOLEAN;

--====================================================================
--
--
--
--
--
--        list of PRIVATE  procedures and functions
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
--======================================================================
PROCEDURE trace (
   p_msg                 IN VARCHAR2
  ,p_level               IN NUMBER
  ,p_module              IN VARCHAR2 DEFAULT C_DEFAULT_MODULE
)
;

--====================================================================
--
--
--
--
--
--        PRIVATE  procedures and functions
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
--======================================================================
--
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
|      trace                                                            |
+======================================================================*/
PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2 DEFAULT C_DEFAULT_MODULE) IS
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
             (p_location   => 'XLA_AE_HEADER_PKG.trace');
END trace;
--
--
--====================================================================
--
--
--
--
--
--        PUBLIC  procedures and functions
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
--======================================================================
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--bulk performance
-- modified to initilize a record in array
PROCEDURE InitHeader
       (p_header_idx       in number)
IS
--l_rec_header_new_line            t_rec_header_new;
l_log_module                 VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InitHeader';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of InitHeader'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_header_idx = '||p_header_idx
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
-- g_header_idx is used as index for array values in g_rec_header_new
-- This is a counter coming from header loop in aad package. For each
-- header fetched (one header per event) incremented counter value is passed
-- as p_header_idx
  g_header_idx                                := p_header_idx;

-- This initializes a new row in the array values in g_rec_header_new to NULL;
g_rec_header_new.array_event_type_code(g_header_idx)           := NULL;
g_rec_header_new.array_event_id(g_header_idx)                  := NULL;
g_rec_header_new.array_entity_id(g_header_idx)                 := NULL;
--
g_rec_header_new.array_header_num(g_header_idx)                := 0;       -- 4262811
g_rec_header_new.array_parent_header_id(g_header_idx)          := NULL;    -- 4262811
g_rec_header_new.array_parent_line_num(g_header_idx)           := NULL;    -- 4262811
g_rec_header_new.array_accrual_reversal_flag(g_header_idx)     := 'N';     -- 4262811
g_rec_header_new.array_acc_rev_gl_date_option(g_header_idx)    := 'NONE';  -- 4262811
--
g_rec_header_new.array_target_ledger_id(g_header_idx)          := NULL;
g_rec_header_new.array_actual_header_id(g_header_idx)          := NULL;
g_rec_header_new.array_budget_header_id(g_header_idx)          := NULL;
g_rec_header_new.array_encumb_header_id(g_header_idx)          := NULL;
g_rec_header_new.array_je_category_name(g_header_idx)          := NULL;
g_rec_header_new.array_period_name(g_header_idx)               := NULL;
g_rec_header_new.array_description(g_header_idx)               := NULL;
g_rec_header_new.array_doc_sequence_id(g_header_idx)           := NULL;
g_rec_header_new.array_doc_sequence_value(g_header_idx)        := NULL;
g_rec_header_new.array_doc_category_code(g_header_idx)         := NULL;
g_rec_header_new.array_budget_version_id(g_header_idx)         := NULL;
--g_rec_header_new.array_encumbrance_type_id(g_header_idx)       := NULL; -- 4458381
g_rec_header_new.array_party_change_option(g_header_idx)       := NULL;
g_rec_header_new.array_party_change_type(g_header_idx)         := NULL;
g_rec_header_new.array_new_party_id(g_header_idx)              := NULL;
g_rec_header_new.array_new_party_site_id(g_header_idx)         := NULL;
g_rec_header_new.array_previous_party_id(g_header_idx)         := NULL;
g_rec_header_new.array_previous_party_site_id(g_header_idx)    := NULL;
g_rec_header_new.array_gl_transfer_flag(g_header_idx)          := NULL;
g_rec_header_new.array_trx_acct_reversal_option(g_header_idx)  := NULL;
g_rec_header_new.array_gl_date(g_header_idx)                   := NULL;
--
g_rec_header_new.array_anc_id_1(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_2(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_3(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_4(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_5(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_6(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_7(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_8(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_9(g_header_idx)                  := NULL;
g_rec_header_new.array_anc_id_10(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_11(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_12(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_13(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_14(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_15(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_16(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_17(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_18(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_19(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_20(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_21(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_22(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_23(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_24(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_25(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_26(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_27(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_28(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_29(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_30(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_31(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_32(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_33(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_34(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_35(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_36(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_37(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_38(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_39(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_40(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_41(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_42(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_43(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_44(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_45(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_46(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_47(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_48(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_49(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_50(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_51(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_52(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_53(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_54(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_55(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_56(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_57(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_58(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_59(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_60(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_61(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_62(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_63(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_64(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_65(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_66(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_67(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_68(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_69(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_70(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_71(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_72(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_73(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_74(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_75(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_76(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_77(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_78(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_79(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_80(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_81(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_82(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_83(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_84(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_85(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_86(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_87(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_88(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_89(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_90(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_91(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_92(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_93(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_94(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_95(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_96(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_97(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_98(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_99(g_header_idx)    := NULL;
g_rec_header_new.array_anc_id_100(g_header_idx)   := NULL;

--
g_rec_header_new.array_event_number(g_header_idx)              := NULL;

--
-- bulk performance
-- Following may not be needed in the bulk approach as
-- je status is handled in a different way.
--  XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
--
-- bulk performance
-- following initial1ses the status of je headers for each balance type
-- initial status is kept as 'valid'
g_rec_header_new.array_actual_status(g_header_idx)   := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
g_rec_header_new.array_budget_status(g_header_idx)   := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
g_rec_header_new.array_encumbrance_status(g_header_idx)   := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;

/* Events Process_Status_Code Update is soley written with X as SUCCESS so any
 * change in the code to represent SUCCESS/New Status Code changes please revisit the code
 * changes in xlajeaex.pkb PostAccountingEngine code done for bug#9086275 */

g_rec_header_new.array_event_status(g_header_idx)   := 'X'; -- X indicates processed sucessfully.

--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of InitHeader'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      RAISE;
  WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'XLA_AE_HEADER_PKG.InitHeader');
       --
END InitHeader;
--


/*======================================================================+
|                                                                       |
| Public Procedure - 4884853                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE GetAccrualRevDate(
  p_hdr_idx           IN NUMBER
, p_ledger_id         IN NUMBER
, p_gl_date           IN DATE
, p_gl_date_option    IN VARCHAR2
)
IS
--
CURSOR c_one_period IS
SELECT period_name
      ,CASE p_gl_date_option
            WHEN 'XLA_FIRST_DAY_NEXT_GL_PERIOD' THEN start_date
            WHEN 'XLA_LAST_DAY_NEXT_GL_PERIOD'  THEN end_date
            ELSE  p_gl_date + 1
            END                                   GL_DATE
  FROM gl_period_statuses gps
 WHERE gps.application_id         = 101
   AND gps.ledger_id              = p_ledger_id
   AND gps.adjustment_period_flag = 'N'
   AND p_gl_date < gps.start_date
ORDER BY gps.start_date ASC;


l_period_name     gl_period_statuses.period_name%TYPE;
l_accrev_date     DATE;
l_log_module      VARCHAR2(240);


BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAccrualRevDate';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
             (p_msg      => 'BEGIN of GetAccrualRevDate'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);

   END IF;

   l_period_name := NULL;
   OPEN  c_one_period;
   FETCH c_one_period INTO l_period_name, l_accrev_date;
      IF c_one_period%NOTFOUND or l_accrev_date < p_gl_date THEN
         l_accrev_date := p_gl_date;
      END IF;
   CLOSE c_one_period;

   g_rec_header_new.array_gl_date(p_hdr_idx) := l_accrev_date;
   IF l_period_name IS NOT NULL THEN
      g_rec_header_new.array_period_name(p_hdr_idx) := l_period_name;
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
          (p_msg      => 'g_rec_header_new.array_gl_date = '||g_rec_header_new.array_gl_date(p_hdr_idx)||
                         ' g_rec_header_new.array_period_name = '||g_rec_header_new.array_period_name(p_hdr_idx)
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
   END IF;


EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_ae_header_pkg.GetAccrualRevDate');
END GetAccrualRevDate;


/*======================================================================+
|                                                                       |
| Public Procedure - 4262811                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE GetRecognitionEntriesInfo(
  p_ledger_id            IN NUMBER
, p_start_date           IN DATE
, p_end_date             IN DATE
, p_gl_date_option       IN VARCHAR2
, p_num_entries_option   IN VARCHAR2
, p_proration_code       IN VARCHAR2
, p_calculate_acctd_flag IN VARCHAR2  -- 4262811b for accounted amount
, p_same_currency        IN BOOLEAN   -- 4262811b for accounted amount
, p_accted_amt           IN NUMBER    -- this should be the unrounded_accounted_amount
, p_entered_amt          IN NUMBER    -- this should be the unrounded_entered_amount
, p_bflow_applied_to_amt  IN NUMBER                                           -- 5132302
, x_num_entries          IN OUT NOCOPY NUMBER
, x_gl_dates             IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_date
, x_accted_amts          IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_num
, x_entered_amts         IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_num
, x_period_names         IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_V15L
, x_bflow_applied_to_amts IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_num  -- 5132302
)
IS
--
cursor c_one_period is
SELECT period_name
      ,CASE p_gl_date_option
              WHEN 'FIRST_DAY_GL_PERIOD' THEN start_date
              WHEN 'LAST_DAY_GL_PERIOD' THEN  end_date
             -- ELSE  ADD_MONTHS(p_start_date, ROUND(MONTHS_BETWEEN(start_date, p_start_date)))  -- originating_day
	     ELSE  ADD_MONTHS(p_start_date, CEIL(MONTHS_BETWEEN(start_date, p_start_date)))  -- originating_day
	             -- changed from ROUND to CEIL for bug: 8214450
              END                                   GL_DATE
  FROM gl_period_statuses gps
 WHERE gps.application_id         = 101
   AND gps.ledger_id              = p_ledger_id
   AND gps.adjustment_period_flag = 'N'
   AND p_end_date BETWEEN gps.start_date AND gps.end_date
 ORDER BY gps.start_date DESC;

--
-- Cursor to populate the recognition journal entry
--
CURSOR c_periods IS
  SELECT period_name,
         CASE p_gl_date_option
              WHEN 'FIRST_DAY_GL_PERIOD' THEN start_date
              WHEN 'LAST_DAY_GL_PERIOD' THEN  end_date
              --ELSE  ADD_MONTHS(p_start_date, ROUND(MONTHS_BETWEEN(start_date, p_start_date)))  -- originating_day
	      ELSE  ADD_MONTHS(p_start_date, CEIL(MONTHS_BETWEEN(start_date, p_start_date)))  -- originating_day
	                  -- changed from ROUND to CEIL for bug: 8214450
              END                                   GL_DATE,
      -- closing_status,    -- Not needed.  Updated in PostAccountingEngine (?)
         CASE p_proration_code
              WHEN '360_DAYS' THEN 30
              ELSE  end_date-start_date+1
              END                                   DAYS_IN_PERIOD,
         CASE p_proration_code
              WHEN '360_DAYS' THEN least(end_date-p_start_date+1,30)
              ELSE  end_date-p_start_date+1
              END                                   DAYS_IN_FIRST_PERIOD,  -- only valid for first period
         CASE p_proration_code
              WHEN '360_DAYS' THEN least(p_end_date-start_date+1,30)
              ELSE  p_end_date-start_date+1
              END                                   DAYS_IN_LAST_PERIOD    -- only valid for last period
    FROM gl_period_statuses
   WHERE application_id         = 101
     AND ledger_id              = p_ledger_id
     AND adjustment_period_flag = 'N'
     AND end_date               > p_start_date
     AND start_date             < p_end_date
   ORDER BY start_date;

--l_closing_statuses         xla_ae_journal_entry_pkg.t_array_V30L;
l_days_in_periods          xla_ae_journal_entry_pkg.t_array_num;
l_days_in_first_periods    xla_ae_journal_entry_pkg.t_array_num;
l_days_in_last_periods     xla_ae_journal_entry_pkg.t_array_num;

l_total_months             NUMBER;
l_whole_months             NUMBER;
l_other_accted_amt         NUMBER;
l_other_entered_amt        NUMBER;
l_total_days               NUMBER;
l_total_accted_amt         NUMBER;
l_total_entered_amt        NUMBER;
l_log_module               VARCHAR2(240);

l_other_bflow_applied_to_amt   NUMBER;  -- 5132302
l_total_bflow_applied_to_amt   NUMBER;  -- 5132302

-- l_rounding_fac          NUMBER;  -- 4262811b

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetRecognitionEntriesInfo';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
             (p_msg      => 'BEGIN of GetRecognitionEntriesInfo'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);

   END IF;


   IF (p_num_entries_option = 'ONE') THEN   -- see XLA_MPA_NUM_OF_ENTRIES

      --x_gl_dates(1)      := p_end_date;   -- depends on Gl period option
      open c_one_period;
      fetch c_one_period into x_period_names(1), x_gl_dates(1);
      close c_one_period;

      IF x_period_names.count=0  THEN  -- 4897417
         x_num_entries := 0;

      ELSE
         x_num_entries      := 1;

         x_entered_amts (1) := p_entered_amt;
         IF p_calculate_acctd_flag = 'N' THEN  -- 4262811b
            IF p_same_currency THEN            -- 4262811b
               x_accted_amts  (1) := p_entered_amt;
            ELSE
               x_accted_amts  (1) := p_accted_amt;
            END IF;
         ELSE
            x_accted_amts (1) := NULL;
         END IF;

         x_bflow_applied_to_amts (1) := p_bflow_applied_to_amt; -- 5132302

      END IF;


   ELSE  -- ONE_PER_PERIOD
      OPEN  c_periods;
      FETCH c_periods BULK COLLECT INTO x_period_names
                                      , x_gl_dates
                                    --, l_closing_statuses
                                      , l_days_in_periods
                                      , l_days_in_first_periods
                                      , l_days_in_last_periods;
      CLOSE c_periods;

      x_num_entries := x_period_names.count;

      IF x_num_entries > 0 THEN  -- 4897417
         ----------------------------------------------------------------------------------
         -- If the GL date of the first period is before the start date, use the start date
         ----------------------------------------------------------------------------------
         IF (x_gl_dates(1) < p_start_date) THEN
             x_gl_dates(1) := p_start_date;
         END IF;

         /*  awan Let cursor determine the last period date
         --------------------------------------------------------------------------------
         -- If the GL date of the last period is after the end date, use the end date
         --------------------------------------------------------------------------------
         IF (x_gl_dates(x_num_entries) > p_end_date) THEN
             x_gl_dates(x_num_entries) := p_end_date;
         END IF;
         */

         IF x_num_entries = 1 THEN

            x_entered_amts (1) := p_entered_amt;
            IF p_calculate_acctd_flag = 'N' THEN  -- 4262811b
               IF p_same_currency THEN            -- 4262811b
                  x_accted_amts  (1) := p_entered_amt;
               ELSE
                  x_accted_amts  (1) := p_accted_amt;
               END IF;
            ELSE
               x_accted_amts (1) := NULL;
            END IF;

            x_bflow_applied_to_amts (1) := p_bflow_applied_to_amt; -- 5132302

         ELSE

            -----------------------------------------
            -- Calculate whole months
            -----------------------------------------
            IF x_num_entries > 2 THEN
               l_whole_months := x_num_entries - 2;
            ELSE
               l_whole_months := 0;
            END IF;

            --===================================================================================================
            -- Calculate the accounted amount and entered amount of the first, last,
            -- and 'the other' period for the different proration types.
            -- See XLA_MPA_PRORATION lookup type
            --===================================================================================================

            ---------------------------------------------------------------------------
            IF (p_proration_code = 'DAYS_IN_PERIOD') THEN  -- actual days in each month
            ---------------------------------------------------------------------------
               l_total_months := (l_days_in_first_periods(1) / l_days_in_periods(1)) +
                                 (l_days_in_last_periods(x_num_entries) / l_days_in_periods(x_num_entries)) +  l_whole_months;

               l_other_entered_amt   := p_entered_amt / l_total_months;
               x_entered_amts (1)    := l_other_entered_amt * l_days_in_first_periods(1) / l_days_in_periods(1);

               IF p_calculate_acctd_flag = 'N' THEN  -- 4262811b
                  IF p_same_currency THEN            -- 4262811b
                     l_other_accted_amt    := l_other_entered_amt;
                     x_accted_amts (1)     := x_entered_amts (1);
                  ELSE
                     l_other_accted_amt    := p_accted_amt / l_total_months;
                     x_accted_amts (1)     := l_other_accted_amt * l_days_in_first_periods(1) / l_days_in_periods(1);
                  END IF;
               ELSE
                  l_other_accted_amt := NULL;
                  x_accted_amts (1)  := NULL;
               END IF;

               -- 5132302
               l_other_bflow_applied_to_amt  := p_bflow_applied_to_amt / l_total_months;
               x_bflow_applied_to_amts (1)   := l_other_bflow_applied_to_amt * l_days_in_first_periods(1) / l_days_in_periods(1);

            ---------------------------------------------------------------------------------
            ELSIF (p_proration_code = '360_DAYS') THEN  -- 30 days per month, 360 days a year
            ---------------------------------------------------------------------------------
               l_total_months := (l_days_in_first_periods(1) / 360 * 12) +
                                 (l_days_in_last_periods(x_num_entries) / 360 * 12) + l_whole_months;

               l_other_entered_amt    := p_entered_amt / l_total_months;
               x_entered_amts (1)     := l_other_entered_amt * l_days_in_first_periods(1) / 360 * 12;

               IF p_calculate_acctd_flag = 'N' THEN  -- 4262811b
                  IF p_same_currency THEN            -- 4262811b
                     l_other_accted_amt     := l_other_entered_amt;
                     x_accted_amts (1)      := x_entered_amts (1);
                  ELSE
                     l_other_accted_amt     := p_accted_amt / l_total_months;
                     x_accted_amts (1)      := l_other_accted_amt * l_days_in_first_periods(1) / 360 * 12;
                  END IF;
               ELSE
                  l_other_accted_amt := NULL;
                  x_accted_amts (1)  := NULL;
               END IF;

               -- 5132302
               l_other_bflow_applied_to_amt    := p_bflow_applied_to_amt / l_total_months;
               x_bflow_applied_to_amts (1)     := l_other_bflow_applied_to_amt * l_days_in_first_periods(1) / 360 * 12;

            -------------------------------------------------------------------------------------
            ELSIF (p_proration_code = 'TOTAL_DAYS_IN_PERIOD') THEN  -- total days in all periods
            -------------------------------------------------------------------------------------
            -- NOTE: the result is one penny different after rounding for the following example:
            --       1) US$23000 * 17 / 366
            --       2) 17 / 366 * US$23000
            -------------------------------------------------------------------------------------

               l_total_days := l_days_in_first_periods(1) + l_days_in_last_periods(x_num_entries);

               FOR i IN 2..x_num_entries-1 LOOP
                   l_total_days := l_total_days + l_days_in_periods(i);
               END LOOP;

               x_entered_amts (1) := p_entered_amt * l_days_in_first_periods(1) / l_total_days;
               IF p_calculate_acctd_flag = 'N' THEN  -- 4262811b
                  IF p_same_currency THEN            -- 4262811b
                     x_accted_amts (1)  := x_entered_amts (1);
                  ELSE
                     x_accted_amts (1)  := p_accted_amt * l_days_in_first_periods(1) / l_total_days;
                  END IF;
               ELSE
                  x_accted_amts (1) := NULL;
               END IF;

               -- 5132302
               x_bflow_applied_to_amts (1)   := p_bflow_applied_to_amt * l_days_in_first_periods(1) / l_total_days;
               l_total_bflow_applied_to_amt  := x_bflow_applied_to_amts (1);

               l_total_accted_amt  := x_accted_amts (1);
               l_total_entered_amt := x_entered_amts (1);

               FOR i IN 2..x_num_entries-1 LOOP
                   x_entered_amts (i)  := p_entered_amt * l_days_in_periods(i) / l_total_days;
                   l_total_entered_amt := l_total_entered_amt + x_entered_amts (i);

                   IF p_calculate_acctd_flag = 'N' THEN  -- 4262811b
                      IF p_same_currency THEN            -- 4262811b
                         x_accted_amts (i)   := x_entered_amts (i);
                         l_total_accted_amt  := l_total_entered_amt;
                      ELSE
                         x_accted_amts (i)   := p_accted_amt * l_days_in_periods(i) / l_total_days;
                         l_total_accted_amt  := l_total_accted_amt + x_accted_amts (i);
                      END IF;
                   ELSE
                      x_accted_amts (i)  := NULL;
                      l_total_accted_amt := NULL;
                   END IF;

                   -- 5132302
                   x_bflow_applied_to_amts (i)    := p_bflow_applied_to_amt * l_days_in_periods(i) / l_total_days;
                   l_total_bflow_applied_to_amt   := l_total_bflow_applied_to_amt + x_bflow_applied_to_amts (i);

               END LOOP;

               -------------------------------------------
               -- To adjust rounding for last MPA period
               -------------------------------------------
               x_entered_amts (x_num_entries) := p_entered_amt - l_total_entered_amt;
               IF p_calculate_acctd_flag = 'N' THEN  -- 4262811b
                  IF p_same_currency THEN            -- 4262811b
                     x_accted_amts (x_num_entries)  := x_entered_amts (x_num_entries);
                  ELSE
                     x_accted_amts (x_num_entries)  := p_accted_amt - l_total_accted_amt;
                  END IF;
               ELSE
                  x_accted_amts (x_num_entries)  := NULL;
               END IF;

               x_bflow_applied_to_amts (x_num_entries)  := p_bflow_applied_to_amt - l_total_bflow_applied_to_amt;  -- 5132302

            ----------------------------------------------------------------------
            ELSE  -- FIRST_PERIOD (zero amount on the last period)
            ----------------------------------------------------------------------

               ------------------------------------------------------------------------------------
               -- Removing final period
               ------------------------------------------------------------------------------------
               IF x_num_entries > 1 THEN
                  x_period_names.DELETE(x_num_entries);
                  x_num_entries := x_period_names.count;
               END IF;

               x_entered_amts (1)        := p_entered_amt / x_num_entries;
               l_other_entered_amt       := x_entered_amts (1);

               IF p_calculate_acctd_flag = 'N' THEN  -- 4262811b
                  IF p_same_currency THEN            -- 4262811b
                     x_accted_amts (1)   := x_entered_amts (1);
                     l_other_accted_amt  := l_other_entered_amt;
                  ELSE
                     x_accted_amts (1)   := p_accted_amt / x_num_entries;
                     l_other_accted_amt  := x_accted_amts (1);
                  END IF;
               ELSE
                  x_accted_amts (1)  := NULL;
                  l_total_accted_amt := NULL;
               END IF;

               -- 5132302
               x_bflow_applied_to_amts (1)   := p_bflow_applied_to_amt / x_num_entries;
               l_other_bflow_applied_to_amt  := x_bflow_applied_to_amts (1);


            END IF; -- p_proration_code = 'DAYS_IN_PERIOD'

            --==============================================================================
            -- Populate 'the other' periods and adjust rounding for last MPA period
            --==============================================================================
            IF (p_proration_code <> 'TOTAL_DAYS_IN_PERIOD') THEN
               --
               -- Copy the accounted amount and the entered amount of 'the other' period
               -- from the 'second' to the 'second-to-last' entries.
               --
               l_total_accted_amt  := x_accted_amts (1);
               l_total_entered_amt := x_entered_amts (1);

               l_total_bflow_applied_to_amt := x_bflow_applied_to_amts (1);  -- 5132302

               -- To handle final period
               FOR i IN 2.. x_num_entries-1 LOOP
                   x_accted_amts (i)   := l_other_accted_amt;
                   x_entered_amts (i)  := l_other_entered_amt;
                   l_total_accted_amt  := l_total_accted_amt + x_accted_amts (i);
                   l_total_entered_amt := l_total_entered_amt + x_entered_amts (i);
                   --
                   x_bflow_applied_to_amts (i)  := l_other_bflow_applied_to_amt;  -- 5132302
                   l_total_bflow_applied_to_amt := l_total_bflow_applied_to_amt + x_bflow_applied_to_amts (i);  -- 5132302
               END LOOP;

               ------------------------------------------------------------------------
               -- awan To adjust rounding for last MPA period
               ------------------------------------------------------------------------
               IF x_num_entries <> 1 THEN  -- in case FIRST_PERIOD results in only one period
                  x_accted_amts (x_num_entries)  := p_accted_amt - l_total_accted_amt;
                  x_entered_amts (x_num_entries) := p_entered_amt - l_total_entered_amt;
                  x_bflow_applied_to_amts (x_num_entries) := p_bflow_applied_to_amt - l_total_bflow_applied_to_amt;
               END IF;

            END IF;

         END IF; -- x_num_entries = 1

      END IF; -- x_num_entries > 0

   END IF; -- p_num_entries_option = 'ONE'

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_ae_header_pkg.GetRecognitionEntriesInfo');
END GetRecognitionEntriesInfo;


/*======================================================================+
|                                                                       |
| Public Procedure - 4262811                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE CopyHeaderInfo(
   p_parent_hdr_idx   IN NUMBER
 , p_hdr_idx          IN NUMBER
)
IS
l_log_module               VARCHAR2(240);

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CopyHeaderInfo';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
             (p_msg      => 'BEGIN of CopyHeaderInfo'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);

   END IF;

   -------------------------------------------
   -- Create a new header
   -------------------------------------------
   InitHeader(p_hdr_idx);

   -------------------------------------------------------------------------------
   -- Copy all information in g_rec_header_new from p_parent_hdr_idx to p_hdr_idx:
   -- with the following exceptions:
   --
   -- Not copied:
   --     array_accrual_reversal_flag
   --     array_acc_rev_gl_date_option
   --------------------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------------------
   g_rec_header_new.array_event_type_code(p_hdr_idx)           := g_rec_header_new.array_event_type_code(p_parent_hdr_idx);
   g_rec_header_new.array_event_id(p_hdr_idx)                  := g_rec_header_new.array_event_id(p_parent_hdr_idx);

   g_rec_header_new.array_header_num(p_hdr_idx)                := g_rec_header_new.array_header_num(p_parent_hdr_idx);
   g_rec_header_new.array_entity_id(p_hdr_idx)                 := g_rec_header_new.array_entity_id(p_parent_hdr_idx);

   g_rec_header_new.array_parent_header_id(p_hdr_idx)          := g_rec_header_new.array_parent_header_id(p_parent_hdr_idx);
   g_rec_header_new.array_parent_line_num(p_hdr_idx)           := g_rec_header_new.array_parent_line_num(p_parent_hdr_idx);

   --
   g_rec_header_new.array_target_ledger_id(p_hdr_idx)          := g_rec_header_new.array_target_ledger_id(p_parent_hdr_idx);
   g_rec_header_new.array_actual_header_id(p_hdr_idx)          := g_rec_header_new.array_actual_header_id(p_parent_hdr_idx);
   g_rec_header_new.array_budget_header_id(p_hdr_idx)          := g_rec_header_new.array_budget_header_id(p_parent_hdr_idx);
   g_rec_header_new.array_encumb_header_id(p_hdr_idx)          := g_rec_header_new.array_encumb_header_id(p_parent_hdr_idx);
   g_rec_header_new.array_je_category_name(p_hdr_idx)          := g_rec_header_new.array_je_category_name(p_parent_hdr_idx);
   g_rec_header_new.array_period_name(p_hdr_idx)               := g_rec_header_new.array_period_name(p_parent_hdr_idx);
   g_rec_header_new.array_description(p_hdr_idx)               := g_rec_header_new.array_description(p_parent_hdr_idx);
   g_rec_header_new.array_doc_sequence_id(p_hdr_idx)           := g_rec_header_new.array_doc_sequence_id(p_parent_hdr_idx);
   g_rec_header_new.array_doc_sequence_value(p_hdr_idx)        := g_rec_header_new.array_doc_sequence_value(p_parent_hdr_idx);
   g_rec_header_new.array_doc_category_code(p_hdr_idx)         := g_rec_header_new.array_doc_category_code(p_parent_hdr_idx);
   g_rec_header_new.array_budget_version_id(p_hdr_idx)         := g_rec_header_new.array_budget_version_id(p_parent_hdr_idx);
   -- g_rec_header_new.array_encumbrance_type_id(p_hdr_idx)       := g_rec_header_new.array_encumbrance_type_id(p_parent_hdr_idx);
   g_rec_header_new.array_party_change_option(p_hdr_idx)       := g_rec_header_new.array_party_change_option(p_parent_hdr_idx);
   g_rec_header_new.array_party_change_type(p_hdr_idx)         := g_rec_header_new.array_party_change_type(p_parent_hdr_idx);
   g_rec_header_new.array_new_party_id(p_hdr_idx)              := g_rec_header_new.array_new_party_id(p_parent_hdr_idx);
   g_rec_header_new.array_new_party_site_id(p_hdr_idx)         := g_rec_header_new.array_new_party_site_id(p_parent_hdr_idx);
   g_rec_header_new.array_previous_party_id(p_hdr_idx)         := g_rec_header_new.array_previous_party_id(p_parent_hdr_idx);
   g_rec_header_new.array_previous_party_site_id(p_hdr_idx)    := g_rec_header_new.array_previous_party_site_id(p_parent_hdr_idx);
   g_rec_header_new.array_gl_transfer_flag(p_hdr_idx)          := g_rec_header_new.array_gl_transfer_flag(p_parent_hdr_idx);
   g_rec_header_new.array_trx_acct_reversal_option(p_hdr_idx)  := g_rec_header_new.array_trx_acct_reversal_option(p_parent_hdr_idx);
   g_rec_header_new.array_gl_date(p_hdr_idx)                   := g_rec_header_new.array_gl_date(p_parent_hdr_idx);
   --
   IF NVL(g_rec_header_new.array_accrual_reversal_flag(p_parent_hdr_idx),'N') = 'Y' OR
          g_rec_header_new.array_parent_header_id(p_parent_hdr_idx) IS NOT NULL THEN
   g_rec_header_new.array_anc_id_1(p_hdr_idx)     := g_rec_header_new.array_anc_id_1(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_2(p_hdr_idx)     := g_rec_header_new.array_anc_id_2(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_3(p_hdr_idx)     := g_rec_header_new.array_anc_id_3(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_4(p_hdr_idx)     := g_rec_header_new.array_anc_id_4(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_5(p_hdr_idx)     := g_rec_header_new.array_anc_id_5(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_6(p_hdr_idx)     := g_rec_header_new.array_anc_id_6(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_7(p_hdr_idx)     := g_rec_header_new.array_anc_id_7(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_8(p_hdr_idx)     := g_rec_header_new.array_anc_id_8(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_9(p_hdr_idx)     := g_rec_header_new.array_anc_id_9(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_10(p_hdr_idx)    := g_rec_header_new.array_anc_id_10(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_11(p_hdr_idx)    := g_rec_header_new.array_anc_id_11(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_12(p_hdr_idx)    := g_rec_header_new.array_anc_id_12(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_13(p_hdr_idx)    := g_rec_header_new.array_anc_id_13(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_14(p_hdr_idx)    := g_rec_header_new.array_anc_id_14(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_15(p_hdr_idx)    := g_rec_header_new.array_anc_id_15(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_16(p_hdr_idx)    := g_rec_header_new.array_anc_id_16(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_17(p_hdr_idx)    := g_rec_header_new.array_anc_id_17(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_18(p_hdr_idx)    := g_rec_header_new.array_anc_id_18(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_19(p_hdr_idx)    := g_rec_header_new.array_anc_id_19(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_20(p_hdr_idx)    := g_rec_header_new.array_anc_id_20(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_21(p_hdr_idx)    := g_rec_header_new.array_anc_id_21(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_22(p_hdr_idx)    := g_rec_header_new.array_anc_id_22(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_23(p_hdr_idx)    := g_rec_header_new.array_anc_id_23(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_24(p_hdr_idx)    := g_rec_header_new.array_anc_id_24(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_25(p_hdr_idx)    := g_rec_header_new.array_anc_id_25(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_26(p_hdr_idx)    := g_rec_header_new.array_anc_id_26(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_27(p_hdr_idx)    := g_rec_header_new.array_anc_id_27(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_28(p_hdr_idx)    := g_rec_header_new.array_anc_id_28(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_29(p_hdr_idx)    := g_rec_header_new.array_anc_id_29(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_30(p_hdr_idx)    := g_rec_header_new.array_anc_id_30(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_31(p_hdr_idx)    := g_rec_header_new.array_anc_id_31(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_32(p_hdr_idx)    := g_rec_header_new.array_anc_id_32(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_33(p_hdr_idx)    := g_rec_header_new.array_anc_id_33(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_34(p_hdr_idx)    := g_rec_header_new.array_anc_id_34(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_35(p_hdr_idx)    := g_rec_header_new.array_anc_id_35(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_36(p_hdr_idx)    := g_rec_header_new.array_anc_id_36(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_37(p_hdr_idx)    := g_rec_header_new.array_anc_id_37(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_38(p_hdr_idx)    := g_rec_header_new.array_anc_id_38(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_39(p_hdr_idx)    := g_rec_header_new.array_anc_id_39(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_40(p_hdr_idx)    := g_rec_header_new.array_anc_id_40(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_41(p_hdr_idx)    := g_rec_header_new.array_anc_id_41(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_42(p_hdr_idx)    := g_rec_header_new.array_anc_id_42(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_43(p_hdr_idx)    := g_rec_header_new.array_anc_id_43(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_44(p_hdr_idx)    := g_rec_header_new.array_anc_id_44(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_45(p_hdr_idx)    := g_rec_header_new.array_anc_id_45(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_46(p_hdr_idx)    := g_rec_header_new.array_anc_id_46(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_47(p_hdr_idx)    := g_rec_header_new.array_anc_id_47(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_48(p_hdr_idx)    := g_rec_header_new.array_anc_id_48(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_49(p_hdr_idx)    := g_rec_header_new.array_anc_id_49(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_50(p_hdr_idx)    := g_rec_header_new.array_anc_id_50(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_51(p_hdr_idx)    := g_rec_header_new.array_anc_id_51(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_52(p_hdr_idx)    := g_rec_header_new.array_anc_id_52(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_53(p_hdr_idx)    := g_rec_header_new.array_anc_id_53(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_54(p_hdr_idx)    := g_rec_header_new.array_anc_id_54(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_55(p_hdr_idx)    := g_rec_header_new.array_anc_id_55(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_56(p_hdr_idx)    := g_rec_header_new.array_anc_id_56(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_57(p_hdr_idx)    := g_rec_header_new.array_anc_id_57(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_58(p_hdr_idx)    := g_rec_header_new.array_anc_id_58(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_59(p_hdr_idx)    := g_rec_header_new.array_anc_id_59(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_60(p_hdr_idx)    := g_rec_header_new.array_anc_id_60(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_61(p_hdr_idx)    := g_rec_header_new.array_anc_id_61(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_62(p_hdr_idx)    := g_rec_header_new.array_anc_id_62(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_63(p_hdr_idx)    := g_rec_header_new.array_anc_id_63(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_64(p_hdr_idx)    := g_rec_header_new.array_anc_id_64(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_65(p_hdr_idx)    := g_rec_header_new.array_anc_id_65(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_66(p_hdr_idx)    := g_rec_header_new.array_anc_id_66(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_67(p_hdr_idx)    := g_rec_header_new.array_anc_id_67(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_68(p_hdr_idx)    := g_rec_header_new.array_anc_id_68(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_69(p_hdr_idx)    := g_rec_header_new.array_anc_id_69(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_70(p_hdr_idx)    := g_rec_header_new.array_anc_id_70(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_71(p_hdr_idx)    := g_rec_header_new.array_anc_id_71(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_72(p_hdr_idx)    := g_rec_header_new.array_anc_id_72(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_73(p_hdr_idx)    := g_rec_header_new.array_anc_id_73(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_74(p_hdr_idx)    := g_rec_header_new.array_anc_id_74(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_75(p_hdr_idx)    := g_rec_header_new.array_anc_id_75(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_76(p_hdr_idx)    := g_rec_header_new.array_anc_id_76(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_77(p_hdr_idx)    := g_rec_header_new.array_anc_id_77(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_78(p_hdr_idx)    := g_rec_header_new.array_anc_id_78(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_79(p_hdr_idx)    := g_rec_header_new.array_anc_id_79(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_80(p_hdr_idx)    := g_rec_header_new.array_anc_id_80(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_81(p_hdr_idx)    := g_rec_header_new.array_anc_id_81(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_82(p_hdr_idx)    := g_rec_header_new.array_anc_id_82(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_83(p_hdr_idx)    := g_rec_header_new.array_anc_id_83(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_84(p_hdr_idx)    := g_rec_header_new.array_anc_id_84(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_85(p_hdr_idx)    := g_rec_header_new.array_anc_id_85(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_86(p_hdr_idx)    := g_rec_header_new.array_anc_id_86(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_87(p_hdr_idx)    := g_rec_header_new.array_anc_id_87(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_88(p_hdr_idx)    := g_rec_header_new.array_anc_id_88(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_89(p_hdr_idx)    := g_rec_header_new.array_anc_id_89(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_90(p_hdr_idx)    := g_rec_header_new.array_anc_id_90(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_91(p_hdr_idx)    := g_rec_header_new.array_anc_id_91(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_92(p_hdr_idx)    := g_rec_header_new.array_anc_id_92(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_93(p_hdr_idx)    := g_rec_header_new.array_anc_id_93(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_94(p_hdr_idx)    := g_rec_header_new.array_anc_id_94(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_95(p_hdr_idx)    := g_rec_header_new.array_anc_id_95(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_96(p_hdr_idx)    := g_rec_header_new.array_anc_id_96(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_97(p_hdr_idx)    := g_rec_header_new.array_anc_id_97(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_98(p_hdr_idx)    := g_rec_header_new.array_anc_id_98(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_99(p_hdr_idx)    := g_rec_header_new.array_anc_id_99(p_parent_hdr_idx);
   g_rec_header_new.array_anc_id_100(p_hdr_idx)   := g_rec_header_new.array_anc_id_100(p_parent_hdr_idx);
   END IF;

   --
   g_rec_header_new.array_event_number(p_hdr_idx)       := g_rec_header_new.array_event_number(p_parent_hdr_idx);
   g_rec_header_new.array_actual_status(p_hdr_idx)      := g_rec_header_new.array_actual_status(p_parent_hdr_idx);
   g_rec_header_new.array_budget_status(p_hdr_idx)      := g_rec_header_new.array_budget_status(p_parent_hdr_idx);
   g_rec_header_new.array_encumbrance_status(p_hdr_idx) := g_rec_header_new.array_encumbrance_status(p_parent_hdr_idx);
   g_rec_header_new.array_event_status(p_hdr_idx)       := g_rec_header_new.array_event_status(p_parent_hdr_idx);

   --------------------------------------------------------------------------------------------------
   --------------------------------------------------------------------------------------------------

   -------------------------------------------
   -- Validate header accounting attributes
   -------------------------------------------
   IF NVL(g_rec_header_new.array_party_change_option(p_hdr_idx),'N') NOT IN ('Y','N') THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      xla_accounting_err_pkg.build_message
            (p_appli_s_name            => 'XLA'
            ,p_msg_name                => 'XLA_AP_THIRD_PARTY_OPTION'
            ,p_token_1                 => 'PRODUCT_NAME'
            ,p_value_1                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
            ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
            ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
            ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
   END IF;

   IF g_rec_header_new.array_gl_transfer_flag(p_hdr_idx) NOT IN ('Y', 'N') THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      xla_accounting_err_pkg.build_message
            (p_appli_s_name            => 'XLA'
            ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
            ,p_token_1                 => 'ACCT_ATTR_NAME'
            ,p_value_1                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('GL_TRANSFER_FLAG')
            ,p_token_2                 => 'PRODUCT_NAME'
            ,p_value_2                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
            ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
            ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
            ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
   END IF;

   IF g_rec_header_new.array_trx_acct_reversal_option(p_hdr_idx) NOT IN ('Y', 'N') THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      xla_accounting_err_pkg.build_message
            (p_appli_s_name            => 'XLA'
            ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
            ,p_token_1                 => 'ACCT_ATTR_NAME'
            ,p_value_1                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
            ,p_token_2                 => 'PRODUCT_NAME'
            ,p_value_2                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
            ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
            ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
            ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
   END IF;

   IF g_rec_header_new.array_gl_date(p_hdr_idx) is NULL THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      xla_accounting_err_pkg.build_message
            (p_appli_s_name            => 'XLA'
            ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
            ,p_token_1                 => 'ACCT_ATTR_NAME'
            ,p_value_1                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('GL_DATE')
            ,p_token_2                 => 'PRODUCT_NAME'
            ,p_value_2                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
            ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
            ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
            ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
   END IF;

   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
             (p_msg      => 'END of CopyHeaderInfo'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
   END IF;

EXCEPTION

WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_ae_header_pkg.CopyHeaderInfo');
END CopyHeaderInfo;


/*======================================================================+
|                                                                       |
| Public  Procedure - 4262811                                           |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION CreateRecognitionEntries(
  p_event_id           IN INTEGER
, p_num_entries        IN INTEGER
, p_last_hdr_idx       IN INTEGER
, p_recog_line_num_1   IN INTEGER
, p_recog_line_num_2   IN INTEGER
, p_gl_dates           IN xla_ae_journal_entry_pkg.t_array_date
, p_accted_amts        IN xla_ae_journal_entry_pkg.t_array_num
, p_entered_amts       IN xla_ae_journal_entry_pkg.t_array_num
, p_bflow_applied_to_amts   IN xla_ae_journal_entry_pkg.t_array_num  -- 5132302
) RETURN NUMBER
IS

l_hdr_idx             NUMBER;
l_log_module          VARCHAR2(240);

i                     NUMBER;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CreateRecognitionEntries';
   END IF;
   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
             (p_msg      => 'BEGIN of CreateRecognitionEntries'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
   END IF;

   l_hdr_idx := p_last_hdr_idx;  -- initialise

   -------------------------------------------------------------------------------------
   -- Copy the following information from the first recognition line to the current line
   -------------------------------------------------------------------------------------
   FOR i IN 2..p_num_entries LOOP

      --**************************************************************************************************************
      -- awan Problem with multiple Accrual JLT, they are all created under the first Accrual JLT
      -- Need to differentiate the different JLT journal lines
      --**************************************************************************************************************
      g_mpa_line_num := NVL(g_mpa_line_num,0) + 1;
      --**************************************************************************************************************

      -----------------------------------
      -- create header
      -----------------------------------
      l_hdr_idx := l_hdr_idx + 1;

      CopyHeaderInfo( p_parent_hdr_idx => p_last_hdr_idx
                    , p_hdr_idx        => l_hdr_idx);

      --**************************************************************************************************************
      -- 4262811a  Copy the MPA Gl date Option to be used in PostAccountingEngine
      g_rec_header_new.array_acc_rev_gl_date_option (l_hdr_idx) :=
                                                       g_rec_header_new.array_acc_rev_gl_date_option (p_last_hdr_idx);
      --**************************************************************************************************************

      --**************************************************************************************************************
      g_rec_header_new.array_header_num(l_hdr_idx) := g_mpa_line_num ;  --  multiple JLT
      --g_rec_header_new.array_header_num(l_hdr_idx) := i;              --  multiple JLT  original
      --**************************************************************************************************************
      g_rec_header_new.array_gl_date(l_hdr_idx)    := trunc(p_gl_dates(i));


      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx           => l_hdr_idx
                                                        ,p_balance_type_code => 'A');

      -----------------------------------------------------------
      -- create recognition line - for Recognition JLT1
      -----------------------------------------------------------
      -- changed the call of CopyLineInfo to pass the data source for copy process: bug-7109881
      -- XLA_AE_LINES_PKG.CopyLineInfo(p_recog_line_num_1);
      XLA_AE_LINES_PKG.CopyLineInfo(p_recog_line_num_1 , XLA_AE_LINES_PKG.g_mpa_recog_lines );
      --**************************************************************************************************************
      XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id
                                       ,p_header_num   => g_mpa_line_num );  -- multiple JLT
                                     --,p_header_num   => i);                -- original multiple JLT
      --**************************************************************************************************************
      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount (XLA_AE_LINES_PKG.g_LineNumber)  := p_accted_amts(i);
      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount (XLA_AE_LINES_PKG.g_LineNumber) := p_entered_amts(i);
      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt (XLA_AE_LINES_PKG.g_LineNumber) := p_bflow_applied_to_amts(i); -- 5132302

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
                                                                   g_rec_header_new.array_gl_date(l_hdr_idx);

      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx           => l_hdr_idx
                                                        ,p_balance_type_code => 'A');

      -----------------------------------------------------------
      -- create recognition line - for Recognition JLT2
      -----------------------------------------------------------
      -- changed the call of CopyLineInfo to pass the data source for copy process: bug-7109881
      -- XLA_AE_LINES_PKG.CopyLineInfo(p_recog_line_num_2);
       XLA_AE_LINES_PKG.CopyLineInfo(p_recog_line_num_2 , XLA_AE_LINES_PKG.g_mpa_recog_lines );
      --**************************************************************************************************************
      XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id
                                       ,p_header_num   => g_mpa_line_num );   -- multiple JLT
                                     --,p_header_num   => i);                 -- original  multiple JLT
      --**************************************************************************************************************
      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount (XLA_AE_LINES_PKG.g_LineNumber) := p_accted_amts(i);
      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount (XLA_AE_LINES_PKG.g_LineNumber) := p_entered_amts(i);
      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt (XLA_AE_LINES_PKG.g_LineNumber) := p_bflow_applied_to_amts(i); -- 5132302

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
                                                                   g_rec_header_new.array_gl_date(l_hdr_idx);
      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx           => l_hdr_idx
                                                        ,p_balance_type_code => 'A');

   END LOOP;

   --
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
          trace
             (p_msg      => 'END of CreateRecognitionEntries'
             ,p_level    => C_LEVEL_PROCEDURE
             ,p_module   => l_log_module);
   END IF;

   RETURN l_hdr_idx;  -- return to g_last_hdr_idx

EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_ae_header_pkg.CreateRecognitionEntries');

END CreateRecognitionEntries;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetJeCategoryName
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetJeCategoryName';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of SetJeCategoryName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
g_rec_header_new.array_je_category_name(g_header_idx)  := xla_accounting_cache_pkg.get_je_category(
               p_ledger_id        => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.base_ledger_id
              ,p_event_class_code => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_class);
--

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||g_rec_header_new.array_je_category_name(g_header_idx)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of SetJeCategoryName'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      RAISE;
  WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'XLA_AE_HEADER_PKG.InitHeader');
       --
END SetJeCategoryName;
--
--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|   SetAnalyticalCriteria                                               |
|                                                                       |
+======================================================================*/
--
FUNCTION SetAnalyticalCriteria(
   p_analytical_criterion_name    IN VARCHAR2
 , p_analytical_criterion_owner   IN VARCHAR2
 , p_analytical_criterion_code    IN VARCHAR2
 , p_amb_context_code             IN VARCHAR2
 , p_balancing_flag               IN VARCHAR2
--
 , p_analytical_detail_char_1     IN VARCHAR2
 , p_analytical_detail_num_1      IN NUMBER
 , p_analytical_detail_date_1     IN DATE
 , p_analytical_detail_char_2     IN VARCHAR2
 , p_analytical_detail_num_2      IN NUMBER
 , p_analytical_detail_date_2     IN DATE
 , p_analytical_detail_char_3     IN VARCHAR2
 , p_analytical_detail_num_3      IN NUMBER
 , p_analytical_detail_date_3     IN DATE
 , p_analytical_detail_char_4     IN VARCHAR2
 , p_analytical_detail_num_4      IN NUMBER
 , p_analytical_detail_date_4     IN DATE
 , p_analytical_detail_char_5     IN VARCHAR2
 , p_analytical_detail_num_5      IN NUMBER
 , p_analytical_detail_date_5     IN DATE
--
)
RETURN VARCHAR2
IS
l_analytical_criteria  VARCHAR2(240);
l_log_module           VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetAnalyticalCriteria';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of SetAnalyticalCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

     trace
         (p_msg      => 'p_analytical_criterion_name  = '||p_analytical_criterion_name
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_criterion_owner = '||p_analytical_criterion_owner
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_criterion_code = '||p_analytical_criterion_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_balancing_flag = '||p_balancing_flag
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     trace
         (p_msg      => 'p_analytical_detail_char_1 = '||p_analytical_detail_char_1
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_char_2 = '||p_analytical_detail_char_2
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_char_3 = '||p_analytical_detail_char_3
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_char_4 = '||p_analytical_detail_char_4
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_char_5 = '||p_analytical_detail_char_5
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_num_1 = '||p_analytical_detail_num_1
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_num_2 = '||p_analytical_detail_num_2
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_num_3 = '||p_analytical_detail_num_3
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
     trace
         (p_msg      => 'p_analytical_detail_num_4 = '||p_analytical_detail_num_4
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_num_5 = '||p_analytical_detail_num_5
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_date_1 = '||p_analytical_detail_date_1
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_date_2 = '||p_analytical_detail_date_2
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_date_3 = '||p_analytical_detail_date_3
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_date_4 = '||p_analytical_detail_date_4
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

     trace
         (p_msg      => 'p_analytical_detail_date_5 = '||p_analytical_detail_date_5
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
l_analytical_criteria :=  XLA_ANALYTICAL_CRITERIA_PKG.concat_detail_values
                ( p_anacri_code              => p_analytical_criterion_code
                 ,p_anacri_type_code         => p_analytical_criterion_owner
                 ,p_amb_context_code         => p_amb_context_code
                 ,p_detail_char_1            => p_analytical_detail_char_1
                 ,p_detail_date_1            => p_analytical_detail_date_1
                 ,p_detail_number_1          => p_analytical_detail_num_1
                 ,p_detail_char_2            => p_analytical_detail_char_2
                 ,p_detail_date_2            => p_analytical_detail_date_2
                 ,p_detail_number_2          => p_analytical_detail_num_2
                 ,p_detail_char_3            => p_analytical_detail_char_3
                 ,p_detail_date_3            => p_analytical_detail_date_3
                 ,p_detail_number_3          => p_analytical_detail_num_3
                 ,p_detail_char_4            => p_analytical_detail_char_4
                 ,p_detail_date_4            => p_analytical_detail_date_4
                 ,p_detail_number_4          => p_analytical_detail_num_4
                 ,p_detail_char_5            => p_analytical_detail_char_5
                 ,p_detail_date_5            => p_analytical_detail_date_5
                 ,p_detail_number_5          => p_analytical_detail_num_5
                );
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_analytical_criteria)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of SetAnalyticalCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_analytical_criteria;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
 XLA_AE_JOURNAL_ENTRY_PKG.g_global_status     :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
 RETURN NULL;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_HEADER_PKG.SetAnalyticalCriteria');
  --
END SetAnalyticalCriteria;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|   SetHdrDescription                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE SetHdrDescription(
  p_description         IN VARCHAR2
)
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetHdrDescription';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of SetHdrDescription'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
   g_rec_header_new.array_description(g_header_idx)  := SUBSTR(p_description,1,1996);
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of SetHdrDescription'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
--
WHEN xla_exceptions_pkg.application_exception THEN
  XLA_AE_JOURNAL_ENTRY_PKG.g_global_status     :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_HEADER_PKG.SetHdrDescription');
END SetHdrDescription;
--
/*======================================================================+
|                                                                       |
| PRIVATE Procedure                                                     |
|     InsertHeaders                                                     |
|                                                                       |
+======================================================================*/
FUNCTION  InsertHeaders
RETURN BOOLEAN
IS
--
l_period_name            VARCHAR2(25);
l_array_header_id        XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_balance_type     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L;
l_result                 BOOLEAN;
l_Idx                    BINARY_INTEGER := 0;
l_log_module             VARCHAR2(240);
-- added 7526530
errors                     NUMBER;
ERR_IND                    NUMBER;
ERR_CODE                   VARCHAR2(100);
dml_errors                 EXCEPTION;
PRAGMA exception_init(dml_errors, -24381);
-- end 7526530
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
l_result            := TRUE;

--
-- create headers
--
-- how is the following used??
/*
IF g_rec_header_new.array_actual_header_id(g_header_idx) > 0 THEN
   --
    l_Idx                            :=  l_Idx + 1;
    l_array_header_id(l_Idx)         :=  g_rec_header_new.array_actual_header_id(g_header_idx);
    l_array_balance_type(l_Idx)      :=  C_ACTUAL;
   --
    l_period_name                    := get_period_name(
                                            p_ledger_id        => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                          , p_accounting_date  => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_date
                                          , p_ae_header_id     => g_rec_header_new.array_actual_header_id(g_header_idx)
                                          );
END IF;
  --
IF g_rec_header_new.array_budget_header_id(g_header_idx) > 0 THEN
    --
    l_Idx                            :=  l_Idx + 1;
    l_array_header_id(l_Idx)         :=  g_rec_header_new.array_budget_header_id(g_header_idx);
    l_array_balance_type(l_Idx)      :=  C_BUDGET;
    --
    l_period_name                    := get_period_name(
                                            p_ledger_id        => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                          , p_accounting_date  => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_date
                                          , p_ae_header_id     => g_rec_header_new.array_budget_header_id(g_header_idx)
                                          );
END IF;
  --
IF g_rec_header_new.array_encumb_header_id(g_header_idx) > 0 THEN
   --
   l_Idx                            :=  l_Idx + 1;
   l_array_header_id(l_Idx)         :=  g_rec_header_new.array_encumb_header_id(g_header_idx);
   l_array_balance_type(l_Idx)      :=  C_ENCUMBRANCE;
   --
   l_period_name                    := get_period_name(
                                            p_ledger_id        => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                          , p_accounting_date  => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_date
                                          , p_ae_header_id     => g_rec_header_new.array_encumb_header_id(g_header_idx)
                                          );
END IF;
*/
--
-- insert the headers created
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
       (p_msg      => 'g_rec_header_new.array_je_category_name.count = '||
                      g_rec_header_new.array_je_category_name.count
       ,p_level    => C_LEVEL_STATEMENT
       ,p_module   => l_log_module);
END IF;
--
--
--IF l_array_header_id.COUNT > 0  AND l_period_name IS NOT NULL THEN

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN

         trace
            (p_msg      => 'SQL - Insert into  xla_ae_headers_gt'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
     END IF;


FORALL Idx IN 1..g_rec_header_new.array_je_category_name.count  SAVE EXCEPTIONS --added Save exception 7526530
    INSERT INTO xla_ae_headers_gt
       ( ae_header_id
       , accounting_entry_status_code
       , accounting_entry_type_code
       , ledger_id
       , entity_id
       , event_id
       , event_type_code
       , accounting_date
       , product_rule_type_code
       , product_rule_code
       , product_rule_version
       , je_category_name
       --, period_name
       , doc_sequence_id
       , doc_sequence_value
       , description
       , budget_version_id
       --, encumbrance_type_id
       , balance_type_code
       , amb_context_code
       , doc_category_code
       , gl_transfer_status_code
       , event_status_code
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
       --
       , event_number
       , header_num               -- 4262811
       , accrual_reversal_flag    -- 4262811
       , acc_rev_gl_date_option   -- 4262811
       , parent_header_id         -- 4262811
       , parent_ae_line_num)      -- 4262811
       (SELECT  /*+ INDEX (AEL, XLA_AE_LINES_GT_N3) */      -- 4752774  -- changed in  8319065 performance changes
                 g_rec_header_new.array_event_id(Idx)
               , CASE ael.balance_type_code
                   when C_BUDGET THEN
                      g_rec_header_new.array_budget_status(Idx)
                   when C_ENCUMBRANCE THEN
                      g_rec_header_new.array_encumbrance_status(Idx)
                   when C_ACTUAL THEN
                      g_rec_header_new.array_actual_status(Idx)
                   ELSE
                      XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED
                 END CASE
               , C_STANDARD
               , g_rec_header_new.array_target_ledger_id(Idx)
               , g_rec_header_new.array_entity_id(Idx)
               , g_rec_header_new.array_event_id(Idx)
               , g_rec_header_new.array_event_type_code(Idx)
               , g_rec_header_new.array_gl_date(Idx)
               , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_pad.product_rule_type_code
               , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_pad.product_rule_code
               , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_pad.product_rule_version
               , g_rec_header_new.array_je_category_name(Idx)
               --, 'XYZ' --l_period_name
               , g_rec_header_new.array_doc_sequence_id(Idx)
               , g_rec_header_new.array_doc_sequence_value(Idx)
               , g_rec_header_new.array_description(Idx)
               , DECODE(ael.balance_type_code  -- 4924492
                       ,C_BUDGET, g_rec_header_new.array_budget_version_id(Idx)
                       ,'X', g_rec_header_new.array_budget_version_id(Idx)
                       ,NULL)
               --, DECODE(ael.balance_type_code, C_ENCUMBRANCE, g_rec_header_new.array_encumbrance_type_id(Idx)
               --         , NULL)  -- 4458381  Public Sector Enh
               , ael.balance_type_code
               , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_pad.amb_context_code
               , g_rec_header_new.array_doc_category_code(Idx)
               , DECODE(g_rec_header_new.array_gl_transfer_flag(Idx), 'N', 'NT', 'Y', 'N', 'N')
               , g_rec_header_new.array_event_status(Idx)
               , g_rec_header_new.array_anc_id_1(Idx)
               , g_rec_header_new.array_anc_id_2(Idx)
               , g_rec_header_new.array_anc_id_3(Idx)
               , g_rec_header_new.array_anc_id_4(Idx)
               , g_rec_header_new.array_anc_id_5(Idx)
               , g_rec_header_new.array_anc_id_6(Idx)
               , g_rec_header_new.array_anc_id_7(Idx)
               , g_rec_header_new.array_anc_id_8(Idx)
               , g_rec_header_new.array_anc_id_9(Idx)
               , g_rec_header_new.array_anc_id_10(Idx)
               , g_rec_header_new.array_anc_id_11(Idx)
               , g_rec_header_new.array_anc_id_12(Idx)
               , g_rec_header_new.array_anc_id_13(Idx)
               , g_rec_header_new.array_anc_id_14(Idx)
               , g_rec_header_new.array_anc_id_15(Idx)
               , g_rec_header_new.array_anc_id_16(Idx)
               , g_rec_header_new.array_anc_id_17(Idx)
               , g_rec_header_new.array_anc_id_18(Idx)
               , g_rec_header_new.array_anc_id_19(Idx)
               , g_rec_header_new.array_anc_id_20(Idx)
               , g_rec_header_new.array_anc_id_21(Idx)
               , g_rec_header_new.array_anc_id_22(Idx)
               , g_rec_header_new.array_anc_id_23(Idx)
               , g_rec_header_new.array_anc_id_24(Idx)
               , g_rec_header_new.array_anc_id_25(Idx)
               , g_rec_header_new.array_anc_id_26(Idx)
               , g_rec_header_new.array_anc_id_27(Idx)
               , g_rec_header_new.array_anc_id_28(Idx)
               , g_rec_header_new.array_anc_id_29(Idx)
               , g_rec_header_new.array_anc_id_30(Idx)
               , g_rec_header_new.array_anc_id_31(Idx)
               , g_rec_header_new.array_anc_id_32(Idx)
               , g_rec_header_new.array_anc_id_33(Idx)
               , g_rec_header_new.array_anc_id_34(Idx)
               , g_rec_header_new.array_anc_id_35(Idx)
               , g_rec_header_new.array_anc_id_36(Idx)
               , g_rec_header_new.array_anc_id_37(Idx)
               , g_rec_header_new.array_anc_id_38(Idx)
               , g_rec_header_new.array_anc_id_39(Idx)
               , g_rec_header_new.array_anc_id_40(Idx)
               , g_rec_header_new.array_anc_id_41(Idx)
               , g_rec_header_new.array_anc_id_42(Idx)
               , g_rec_header_new.array_anc_id_43(Idx)
               , g_rec_header_new.array_anc_id_44(Idx)
               , g_rec_header_new.array_anc_id_45(Idx)
               , g_rec_header_new.array_anc_id_46(Idx)
               , g_rec_header_new.array_anc_id_47(Idx)
               , g_rec_header_new.array_anc_id_48(Idx)
               , g_rec_header_new.array_anc_id_49(Idx)
               , g_rec_header_new.array_anc_id_50(Idx)
               , g_rec_header_new.array_anc_id_51(Idx)
               , g_rec_header_new.array_anc_id_52(Idx)
               , g_rec_header_new.array_anc_id_53(Idx)
               , g_rec_header_new.array_anc_id_54(Idx)
               , g_rec_header_new.array_anc_id_55(Idx)
               , g_rec_header_new.array_anc_id_56(Idx)
               , g_rec_header_new.array_anc_id_57(Idx)
               , g_rec_header_new.array_anc_id_58(Idx)
               , g_rec_header_new.array_anc_id_59(Idx)
               , g_rec_header_new.array_anc_id_60(Idx)
               , g_rec_header_new.array_anc_id_61(Idx)
               , g_rec_header_new.array_anc_id_62(Idx)
               , g_rec_header_new.array_anc_id_63(Idx)
               , g_rec_header_new.array_anc_id_64(Idx)
               , g_rec_header_new.array_anc_id_65(Idx)
               , g_rec_header_new.array_anc_id_66(Idx)
               , g_rec_header_new.array_anc_id_67(Idx)
               , g_rec_header_new.array_anc_id_68(Idx)
               , g_rec_header_new.array_anc_id_69(Idx)
               , g_rec_header_new.array_anc_id_70(Idx)
               , g_rec_header_new.array_anc_id_71(Idx)
               , g_rec_header_new.array_anc_id_72(Idx)
               , g_rec_header_new.array_anc_id_73(Idx)
               , g_rec_header_new.array_anc_id_74(Idx)
               , g_rec_header_new.array_anc_id_75(Idx)
               , g_rec_header_new.array_anc_id_76(Idx)
               , g_rec_header_new.array_anc_id_77(Idx)
               , g_rec_header_new.array_anc_id_78(Idx)
               , g_rec_header_new.array_anc_id_79(Idx)
               , g_rec_header_new.array_anc_id_80(Idx)
               , g_rec_header_new.array_anc_id_81(Idx)
               , g_rec_header_new.array_anc_id_82(Idx)
               , g_rec_header_new.array_anc_id_83(Idx)
               , g_rec_header_new.array_anc_id_84(Idx)
               , g_rec_header_new.array_anc_id_85(Idx)
               , g_rec_header_new.array_anc_id_86(Idx)
               , g_rec_header_new.array_anc_id_87(Idx)
               , g_rec_header_new.array_anc_id_88(Idx)
               , g_rec_header_new.array_anc_id_89(Idx)
               , g_rec_header_new.array_anc_id_90(Idx)
               , g_rec_header_new.array_anc_id_91(Idx)
               , g_rec_header_new.array_anc_id_92(Idx)
               , g_rec_header_new.array_anc_id_93(Idx)
               , g_rec_header_new.array_anc_id_94(Idx)
               , g_rec_header_new.array_anc_id_95(Idx)
               , g_rec_header_new.array_anc_id_96(Idx)
               , g_rec_header_new.array_anc_id_97(Idx)
               , g_rec_header_new.array_anc_id_98(Idx)
               , g_rec_header_new.array_anc_id_99(Idx)
               , g_rec_header_new.array_anc_id_100(Idx)
               --
               , g_rec_header_new.array_event_number(Idx)
               , g_rec_header_new.array_header_num(Idx)              -- 4262811
               , g_rec_header_new.array_accrual_reversal_flag(Idx)   -- 4262811
               , g_rec_header_new.array_acc_rev_gl_date_option(Idx)  -- 4262811
               , g_rec_header_new.array_parent_header_id(Idx)        -- 4262811
               , g_rec_header_new.array_parent_line_num(Idx)         -- 4262811
          FROM   xla_ae_lines_gt ael
         WHERE   ael.ae_header_id = g_rec_header_new.array_event_id(Idx)
           AND   ael.ledger_id    = g_rec_header_new.array_target_ledger_id(Idx)
           AND   (nvl(ael.gain_or_loss_flag, 'N') <> 'Y' or nvl(ael.calculate_g_l_amts_flag, 'N') <> 'Y')
           AND   ael.header_num =
                                 NVL2(g_rec_header_new.array_parent_header_id(Idx),g_rec_header_new.array_header_num(Idx)
, NVL(g_rec_header_new.array_header_num(Idx),0) )
                                -- added for bug#9162117

--           AND   nvl(ael.entered_amount,0) > 0
--           AND   ael.temp_line_num <> 0
           group by ael.balance_type_code
           );
--


     IF (C_LEVEL_EVENT >= g_log_level) THEN

         trace
             (p_msg      => '# temporary headers inserted into GT xla_ae_headers_gt = '||SQL%ROWCOUNT
             ,p_level    => C_LEVEL_EVENT
             ,p_module   => l_log_module);
     END IF;
--
  l_result:= ( (SQL%ROWCOUNT > 0) OR
               (XLA_AE_JOURNAL_ENTRY_PKG.g_global_status =  XLA_AE_JOURNAL_ENTRY_PKG.C_VALID)) ;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of InsertHeaders'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
RETURN l_result;
--
EXCEPTION

WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
-- added 7526530

----Added  to handle Exceptions and send to Out file ------------
WHEN dml_errors THEN
   errors := SQL%BULK_EXCEPTIONS.COUNT;
   FOR i IN 1..errors LOOP
      ERR_IND:= SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
      ERR_CODE:= SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);
      fnd_file.put_line(fnd_file.log, 'ERROR : '|| UPPER(ERR_CODE));
      fnd_file.put_line(fnd_file.log, 'event_id: '||g_rec_header_new.array_event_id(ERR_IND));
      fnd_file.put_line(fnd_file.log, 'header_num: '||g_rec_header_new.array_header_num(ERR_IND));
      fnd_file.put_line(fnd_file.log, 'ledger_id: '||g_rec_header_new.array_target_ledger_id(ERR_IND));

  END LOOP;
  xla_exceptions_pkg.raise_message
      (p_location => 'XLA_AE_HEADER_PKG.InsertHeaders');
  WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_AE_HEADER_PKG.InsertHeaders');
END InsertHeaders;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE change_third_party

IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.change_third_party';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of change_third_party'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

     trace
         (p_msg      => 'SQL - Insert into xla_ae_lines_gt  '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;
--
 INSERT INTO xla_ae_lines_gt
 (
  ae_header_id
, temp_line_num
, event_id
--
, ref_ae_header_id
, ref_ae_line_num
, ref_temp_line_num
--
, accounting_class_code
, event_class_code
, event_type_code
, line_definition_owner_code
, line_definition_code
, accounting_line_type_code
, accounting_line_code
--
, code_combination_status_code
, code_combination_id
, sl_coa_mapping_name
, dynamic_insert_flag
, source_coa_id
, ccid_coa_id
--
, description
, gl_transfer_mode_code
, merge_duplicate_code
, switch_side_flag
--
--, entered_amount
--, ledger_amount
, unrounded_entered_cr
, unrounded_entered_dr
, unrounded_accounted_cr
, unrounded_accounted_dr
, entered_cr
, entered_dr
, accounted_cr
, accounted_dr
, currency_code
, currency_conversion_date
, currency_conversion_rate
, currency_conversion_type
, statistical_amount
--
, party_id
, party_site_id
, party_type_code
--
, ussgl_transaction_code
, jgzz_recon_ref
--
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
--
, tax_line_ref_id
, tax_summary_line_ref_id
, tax_rec_nrec_dist_ref_id
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
, inherit_desc_flag        -- 4219869
, mpa_accrual_entry_flag   -- 4262811
, encumbrance_type_id      -- 4458381  Public Sector Enh
, header_num               -- 5100860  assign value to avoid using function index
)

SELECT
        CASE xah.balance_type_code
          WHEN C_ACTUAL      THEN g_rec_header_new.array_actual_header_id(g_header_idx)
          WHEN C_BUDGET      THEN g_rec_header_new.array_budget_header_id(g_header_idx)
          WHEN C_ENCUMBRANCE THEN g_rec_header_new.array_encumb_header_id(g_header_idx)
        END
     ,  XLA_AE_LINES_PKG.SetLineNum(xah.balance_type_code)
     ,  XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
    --
     ,  xal.ae_header_id
     ,  xal.ae_line_num
     ,  xdl.temp_line_num
    --
     ,  xal.accounting_class_code
     ,  xdl.event_class_code
     ,  xdl.event_type_code
     ,  xdl.line_definition_owner_code
     ,  xdl.line_definition_code
     ,  xdl.accounting_line_type_code
     ,  xdl.accounting_line_code
    --
     , C_CCID
     , xal.code_combination_id
     , NULL
     , NULL
     , NULL
     , NULL
     , xal.description
     , xal.gl_transfer_mode_code
     , xdl.merge_duplicate_code
     , DECODE(XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option,
                  'SIDE', C_SWITCH,
                   C_NO_SWITCH
              )
/*     , xdl.entered_amount
     , xdl.ledger_amount */
     --
     , xal.unrounded_entered_dr
     , xal.unrounded_entered_cr
     , xal.unrounded_accounted_dr
     , xal.unrounded_accounted_cr
     , xal.entered_dr
     , xal.entered_cr
     , xal.accounted_dr
     , xal.accounted_cr
     --
     , xal.currency_code
     , xal.currency_conversion_date
     , xal.currency_conversion_rate
     , xal.currency_conversion_type
     , xal.statistical_amount
     --
     , xal.party_id
     , xal.party_site_id
     , xal.party_type_code
     --
     , xal.ussgl_transaction_code
     , xal.jgzz_recon_ref
      --
     , xdl.source_distribution_id_char_1
     , xdl.source_distribution_id_char_2
     , xdl.source_distribution_id_char_3
     , xdl.source_distribution_id_char_4
     , xdl.source_distribution_id_char_5
     , xdl.source_distribution_id_num_1
     , xdl.source_distribution_id_num_2
     , xdl.source_distribution_id_num_3
     , xdl.source_distribution_id_num_4
     , xdl.source_distribution_id_num_5
     , xdl.source_distribution_type
     --
     , xdl.tax_line_ref_id
     , xdl.tax_summary_line_ref_id
     , xdl.tax_rec_nrec_dist_ref_id
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
     , 'N'   -- 4219869  inherit_desc_flag
     , 'N'   -- 4262811  mpa_accrual_entry_flag
     , xal.encumbrance_type_id -- 4458381  Public Sector Enh
     , 0                       -- 5100860  assign value to avoid using function index
     --
FROM  xla_ae_lines            xal,
      xla_ae_headers          xah,
      xla_distribution_links  xdl,
      xla_events              xe,
     (SELECT ae_header_id
            ,ae_line_num
            ,MAX(DECODE(rank,1,anc_id)) anc_id_1
            ,MAX(DECODE(rank,2,anc_id)) anc_id_2
            ,MAX(DECODE(rank,3,anc_id)) anc_id_3
            ,MAX(DECODE(rank,4,anc_id)) anc_id_4
            ,MAX(DECODE(rank,5,anc_id)) anc_id_5
            ,MAX(DECODE(rank,6,anc_id)) anc_id_6
            ,MAX(DECODE(rank,7,anc_id)) anc_id_7
            ,MAX(DECODE(rank,8,anc_id)) anc_id_8
            ,MAX(DECODE(rank,9,anc_id)) anc_id_9
            ,MAX(DECODE(rank,10,anc_id)) anc_id_10
            ,MAX(DECODE(rank,11,anc_id)) anc_id_11
            ,MAX(DECODE(rank,12,anc_id)) anc_id_12
            ,MAX(DECODE(rank,13,anc_id)) anc_id_13
            ,MAX(DECODE(rank,14,anc_id)) anc_id_14
            ,MAX(DECODE(rank,15,anc_id)) anc_id_15
            ,MAX(DECODE(rank,16,anc_id)) anc_id_16
            ,MAX(DECODE(rank,17,anc_id)) anc_id_17
            ,MAX(DECODE(rank,18,anc_id)) anc_id_18
            ,MAX(DECODE(rank,19,anc_id)) anc_id_19
            ,MAX(DECODE(rank,20,anc_id)) anc_id_20
            ,MAX(DECODE(rank,21,anc_id)) anc_id_21
            ,MAX(DECODE(rank,22,anc_id)) anc_id_22
            ,MAX(DECODE(rank,23,anc_id)) anc_id_23
            ,MAX(DECODE(rank,24,anc_id)) anc_id_24
            ,MAX(DECODE(rank,25,anc_id)) anc_id_25
            ,MAX(DECODE(rank,26,anc_id)) anc_id_26
            ,MAX(DECODE(rank,27,anc_id)) anc_id_27
            ,MAX(DECODE(rank,28,anc_id)) anc_id_28
            ,MAX(DECODE(rank,29,anc_id)) anc_id_29
            ,MAX(DECODE(rank,30,anc_id)) anc_id_30
            ,MAX(DECODE(rank,31,anc_id)) anc_id_31
            ,MAX(DECODE(rank,32,anc_id)) anc_id_32
            ,MAX(DECODE(rank,33,anc_id)) anc_id_33
            ,MAX(DECODE(rank,34,anc_id)) anc_id_34
            ,MAX(DECODE(rank,35,anc_id)) anc_id_35
            ,MAX(DECODE(rank,36,anc_id)) anc_id_36
            ,MAX(DECODE(rank,37,anc_id)) anc_id_37
            ,MAX(DECODE(rank,38,anc_id)) anc_id_38
            ,MAX(DECODE(rank,39,anc_id)) anc_id_39
            ,MAX(DECODE(rank,40,anc_id)) anc_id_40
            ,MAX(DECODE(rank,41,anc_id)) anc_id_41
            ,MAX(DECODE(rank,42,anc_id)) anc_id_42
            ,MAX(DECODE(rank,43,anc_id)) anc_id_43
            ,MAX(DECODE(rank,44,anc_id)) anc_id_44
            ,MAX(DECODE(rank,45,anc_id)) anc_id_45
            ,MAX(DECODE(rank,46,anc_id)) anc_id_46
            ,MAX(DECODE(rank,47,anc_id)) anc_id_47
            ,MAX(DECODE(rank,48,anc_id)) anc_id_48
            ,MAX(DECODE(rank,49,anc_id)) anc_id_49
            ,MAX(DECODE(rank,50,anc_id)) anc_id_50
            ,MAX(DECODE(rank,51,anc_id)) anc_id_51
            ,MAX(DECODE(rank,52,anc_id)) anc_id_52
            ,MAX(DECODE(rank,53,anc_id)) anc_id_53
            ,MAX(DECODE(rank,54,anc_id)) anc_id_54
            ,MAX(DECODE(rank,55,anc_id)) anc_id_55
            ,MAX(DECODE(rank,56,anc_id)) anc_id_56
            ,MAX(DECODE(rank,57,anc_id)) anc_id_57
            ,MAX(DECODE(rank,58,anc_id)) anc_id_58
            ,MAX(DECODE(rank,59,anc_id)) anc_id_59
            ,MAX(DECODE(rank,60,anc_id)) anc_id_60
            ,MAX(DECODE(rank,61,anc_id)) anc_id_61
            ,MAX(DECODE(rank,62,anc_id)) anc_id_62
            ,MAX(DECODE(rank,63,anc_id)) anc_id_63
            ,MAX(DECODE(rank,64,anc_id)) anc_id_64
            ,MAX(DECODE(rank,65,anc_id)) anc_id_65
            ,MAX(DECODE(rank,66,anc_id)) anc_id_66
            ,MAX(DECODE(rank,67,anc_id)) anc_id_67
            ,MAX(DECODE(rank,68,anc_id)) anc_id_68
            ,MAX(DECODE(rank,69,anc_id)) anc_id_69
            ,MAX(DECODE(rank,70,anc_id)) anc_id_70
            ,MAX(DECODE(rank,71,anc_id)) anc_id_71
            ,MAX(DECODE(rank,72,anc_id)) anc_id_72
            ,MAX(DECODE(rank,73,anc_id)) anc_id_73
            ,MAX(DECODE(rank,74,anc_id)) anc_id_74
            ,MAX(DECODE(rank,75,anc_id)) anc_id_75
            ,MAX(DECODE(rank,76,anc_id)) anc_id_76
            ,MAX(DECODE(rank,77,anc_id)) anc_id_77
            ,MAX(DECODE(rank,78,anc_id)) anc_id_78
            ,MAX(DECODE(rank,79,anc_id)) anc_id_79
            ,MAX(DECODE(rank,80,anc_id)) anc_id_80
            ,MAX(DECODE(rank,81,anc_id)) anc_id_81
            ,MAX(DECODE(rank,82,anc_id)) anc_id_82
            ,MAX(DECODE(rank,83,anc_id)) anc_id_83
            ,MAX(DECODE(rank,84,anc_id)) anc_id_84
            ,MAX(DECODE(rank,85,anc_id)) anc_id_85
            ,MAX(DECODE(rank,86,anc_id)) anc_id_86
            ,MAX(DECODE(rank,87,anc_id)) anc_id_87
            ,MAX(DECODE(rank,88,anc_id)) anc_id_88
            ,MAX(DECODE(rank,89,anc_id)) anc_id_89
            ,MAX(DECODE(rank,90,anc_id)) anc_id_90
            ,MAX(DECODE(rank,91,anc_id)) anc_id_91
            ,MAX(DECODE(rank,92,anc_id)) anc_id_92
            ,MAX(DECODE(rank,93,anc_id)) anc_id_93
            ,MAX(DECODE(rank,94,anc_id)) anc_id_94
            ,MAX(DECODE(rank,95,anc_id)) anc_id_95
            ,MAX(DECODE(rank,96,anc_id)) anc_id_96
            ,MAX(DECODE(rank,97,anc_id)) anc_id_97
            ,MAX(DECODE(rank,98,anc_id)) anc_id_98
            ,MAX(DECODE(rank,99,anc_id)) anc_id_99
            ,MAX(DECODE(rank,100,anc_id)) anc_id_100
     FROM
     (SELECT  xald.ae_header_id
            , xald.ae_line_num
            , xald.analytical_criterion_code      || '(]' ||
              xald.analytical_criterion_type_code || '(]' ||
              xald.amb_context_code               || '(]' ||
              xald.ac1                            || '(]' ||
              xald.ac2                            || '(]' ||
              xald.ac3                            || '(]' ||
              xald.ac4                            || '(]' ||
              xald.ac5                            anc_id
            , RANK() OVER (
              PARTITION BY ae_header_id, ae_line_num
                  ORDER BY analytical_criterion_code
                          ,analytical_criterion_type_code
                          ,amb_context_code
                          ,ac1
                          ,ac2
                          ,ac3
                          ,ac4
                          ,ac5) rank
       FROM  xla_ae_line_acs xald)
      GROUP  BY ae_header_id, ae_line_num) anc

WHERE xe.event_id                         = xdl.event_id
  AND xe.event_id                         = xah.event_id
  AND xal.ae_header_id                    = xdl.ae_header_id
  AND xal.ae_header_id                    = xah.ae_header_id
  AND xal.ae_line_num                     = xdl.ae_line_num
  AND xe.entity_id                        = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
  AND anc.ae_header_id                    = xdl.ae_header_id
  AND anc.ae_line_num                     = xdl.ae_line_num
  AND xah.ledger_id                       = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
  AND (g_rec_header_new.array_previous_party_id(g_header_idx) IS NULL
      OR
      xal.party_id                        = g_rec_header_new.array_previous_party_id(g_header_idx))
  AND (g_rec_header_new.array_previous_party_site_id(g_header_idx) IS NULL
      OR
      xal.party_site_id                   = g_rec_header_new.array_previous_party_site_id(g_header_idx))
  AND (g_rec_header_new.array_party_change_type(g_header_idx) IS NULL
      OR
      xal.party_type_code                 = g_rec_header_new.array_party_change_type(g_header_idx))
;

IF (C_LEVEL_EVENT >= g_log_level) THEN

     trace
         (p_msg      => '# temporary journal lines inserted into GT xla_ae_lines_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);

END IF;


IF SQL%ROWCOUNT > 0 THEN
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

     trace
         (p_msg      => 'SQL - Insert into xla_ae_lines_gt  '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;
--
--
 INSERT INTO xla_ae_lines_gt
 (
  ae_header_id
, temp_line_num
, event_id
--
, ref_ae_header_id
, ref_ae_line_num
, ref_temp_line_num
--
, accounting_class_code
, event_class_code
, event_type_code
, line_definition_owner_code
, line_definition_code
, accounting_line_type_code
, accounting_line_code
--
, code_combination_status_code
, code_combination_id
, sl_coa_mapping_name
, dynamic_insert_flag
, source_coa_id
, ccid_coa_id
--
, description
, gl_transfer_mode_code
, merge_duplicate_code
, switch_side_flag
--
--, entered_amount
--, ledger_amount
, unrounded_entered_dr
, unrounded_entered_cr
, unrounded_accounted_dr
, unrounded_accounted_cr
, entered_dr
, entered_cr
, accounted_dr
, accounted_cr
, currency_code
, currency_conversion_date
, currency_conversion_rate
, currency_conversion_type
, statistical_amount
--
, party_id
, party_site_id
, party_type_code
--
, ussgl_transaction_code
, jgzz_recon_ref
--
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
--
, tax_line_ref_id
, tax_summary_line_ref_id
, tax_rec_nrec_dist_ref_id
, inherit_desc_flag        -- 4219869
, mpa_accrual_entry_flag   -- 4262811
, encumbrance_type_id      -- 4458381  Public Sector Enh
, header_num               -- 5100860  assign value to avoid using function index
)

SELECT
        CASE xah.balance_type_code
          WHEN C_ACTUAL      THEN g_rec_header_new.array_actual_header_id(g_header_idx)
          WHEN C_BUDGET      THEN g_rec_header_new.array_budget_header_id(g_header_idx)
          WHEN C_ENCUMBRANCE THEN g_rec_header_new.array_encumb_header_id(g_header_idx)
        END
     ,  XLA_AE_LINES_PKG.SetLineNum(xah.balance_type_code)
     ,  XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
    --
     ,  xal.ae_header_id
     ,  xal.ae_line_num
     ,  xdl.temp_line_num
    --
     ,  xal.accounting_class_code
     ,  xdl.event_class_code
     ,  xdl.event_type_code
     ,  xdl.line_definition_owner_code
     ,  xdl.line_definition_code
     ,  xdl.accounting_line_type_code
     ,  xdl.accounting_line_code
    --
     , C_CCID
     , xal.code_combination_id
     , NULL
     , NULL
     , NULL
     , NULL
     , xal.description
     , xal.gl_transfer_mode_code
     , xdl.merge_duplicate_code
     , DECODE(XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option,
                  'SIDE', C_SWITCH,
                   C_NO_SWITCH
              )
--     , xdl.entered_amount
--     , xdl.ledger_amount
     --
     , xal.unrounded_entered_dr
     , xal.unrounded_entered_cr
     , xal.unrounded_accounted_dr
     , xal.unrounded_accounted_cr
     , xal.entered_dr
     , xal.entered_cr
     , xal.accounted_dr
     , xal.accounted_cr
     --
     , xal.currency_code
     , xal.currency_conversion_date
     , xal.currency_conversion_rate
     , xal.currency_conversion_type
     , xal.statistical_amount
     --
     , g_rec_header_new.array_new_party_id(g_header_idx)
     , g_rec_header_new.array_new_party_site_id(g_header_idx)
     , g_rec_header_new.array_party_change_type(g_header_idx)
     --
     , xal.ussgl_transaction_code
     , xal.jgzz_recon_ref
      --
     , xdl.source_distribution_id_char_1
     , xdl.source_distribution_id_char_2
     , xdl.source_distribution_id_char_3
     , xdl.source_distribution_id_char_4
     , xdl.source_distribution_id_char_5
     , xdl.source_distribution_id_num_1
     , xdl.source_distribution_id_num_2
     , xdl.source_distribution_id_num_3
     , xdl.source_distribution_id_num_4
     , xdl.source_distribution_id_num_5
     , xdl.source_distribution_type
     --
     , xdl.tax_line_ref_id
     , xdl.tax_summary_line_ref_id
     , xdl.tax_rec_nrec_dist_ref_id
     , 'N'   -- 4219869 inherit_desc_flag
     , 'N'   -- 4262811 mpa_accrual_entry_flag
     , xal.encumbrance_type_id -- 4458381  Public Sector Enh
     , 0                       -- 5100860  assign value to avoid using function index
     --
FROM  xla_ae_lines            xal,
      xla_ae_headers          xah,
      xla_distribution_links  xdl,
      xla_events              xe
WHERE xe.event_id                         = xdl.event_id
  AND xe.event_id                         = xah.event_id
  AND xal.ae_header_id                    = xdl.ae_header_id
  AND xal.ae_header_id                    = xah.ae_header_id
  AND xal.ae_line_num                     = xdl.ae_line_num
  AND xe.entity_id                        = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
  AND xah.ledger_id                       = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
  AND ( g_rec_header_new.array_previous_party_id(g_header_idx) IS NULL
      OR
      xal.party_id                        = g_rec_header_new.array_previous_party_id(g_header_idx))
  AND ( g_rec_header_new.array_previous_party_site_id(g_header_idx) IS NULL
      OR
      xal.party_site_id                   = g_rec_header_new.array_previous_party_site_id(g_header_idx))
  AND ( g_rec_header_new.array_party_change_type(g_header_idx) IS NULL
      OR
      xal.party_type_code                 = g_rec_header_new.array_party_change_type(g_header_idx))
;
--
--
   IF (C_LEVEL_EVENT >= g_log_level) THEN

     trace
         (p_msg      => '# temporary journal lines inserted into GT xla_ae_lines_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;

END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of change_third_party'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_HEADER_PKG.change_third_party');
  --
END change_third_party;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE RefreshHeader
IS
l_null_rec_header_new        t_rec_header_new;
l_null_rec_period_name       t_rec_period_name;
l_log_module                 VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.RefreshHeader';
END IF;
--

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of RefreshHeader'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
  g_rec_header_new                               := l_null_rec_header_new  ;
  g_cache_period_name                         := l_null_rec_period_name;
  XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := NULL;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of RefreshHeader'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS  THEN
       xla_exceptions_pkg.raise_message
               (p_location => 'XLA_AE_HEADER_PKG.RefreshHeader');
       --
END RefreshHeader;
--
/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
procedure SetHdrAcctAttrs
       (p_rec_acct_attrs    in t_rec_acct_attrs) is
l_log_module                 VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetHdrAcctAttrs';
END IF;

   FOR i in 1..p_rec_acct_attrs.array_acct_attr_code.count loop

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            trace(p_msg      => 'Loop count = '||i||
                                ' (char) : '||p_rec_acct_attrs.array_acct_attr_code(i)||
                                ' = '||p_rec_acct_attrs.array_char_value(i)
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
         ELSIF p_rec_acct_attrs.array_date_value.EXISTS(i) THEN
            trace(p_msg      => 'Loop count = '||i||
                                ' (date) : '||p_rec_acct_attrs.array_acct_attr_code(i)||
                                ' = '||p_rec_acct_attrs.array_date_value(i)
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
         ELSE
            trace(p_msg      => 'Loop count = '||i||
                                ' (num) : '||p_rec_acct_attrs.array_acct_attr_code(i)||
                                ' = '||p_rec_acct_attrs.array_num_value(i)
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
         END IF;

      END IF;

      CASE p_rec_acct_attrs.array_acct_attr_code(i)
         WHEN 'DOC_CATEGORY_CODE'     THEN
            IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
              g_rec_header_new.array_doc_category_code(g_header_idx)     := p_rec_acct_attrs.array_char_value(i);
            ELSE
              g_rec_header_new.array_doc_category_code(g_header_idx)     := p_rec_acct_attrs.array_num_value(i);
            END IF;

         WHEN 'PARTY_CHANGE_OPTION' THEN
            -- 5161760
            IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
               IF length(p_rec_acct_attrs.array_char_value(i)) > 1 THEN
                  g_rec_header_new.array_party_change_option(g_header_idx)     := 'X';
               ELSE
                  g_rec_header_new.array_party_change_option(g_header_idx)     := p_rec_acct_attrs.array_char_value(i);
               END IF;
            ELSE
              g_rec_header_new.array_party_change_option(g_header_idx)     := p_rec_acct_attrs.array_num_value(i);
            END IF;

            IF NVL(g_rec_header_new.array_party_change_option(g_header_idx),'N') NOT IN ('Y','N') THEN
               XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
               xla_accounting_err_pkg.build_message
                  (p_appli_s_name            => 'XLA'
                  ,p_msg_name                => 'XLA_AP_THIRD_PARTY_OPTION'
                  ,p_token_1                 => 'PRODUCT_NAME'
                  ,p_value_1                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                  ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                  ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                  ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
             END IF;

         WHEN 'GL_TRANSFER_FLAG'          THEN
            -- 5161760
            IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
               IF length(p_rec_acct_attrs.array_char_value(i)) > 1 THEN
                  g_rec_header_new.array_gl_transfer_flag(g_header_idx) := 'X';
               ELSE
                  g_rec_header_new.array_gl_transfer_flag(g_header_idx) := nvl(p_rec_acct_attrs.array_char_value(i), 'Y');
               END IF;
            ELSE
              g_rec_header_new.array_gl_transfer_flag(g_header_idx) := nvl(p_rec_acct_attrs.array_num_value(i), 'Y');
            END IF;

            IF NVL(g_rec_header_new.array_gl_transfer_flag(g_header_idx),'Y') NOT IN ('Y', 'N') THEN
               XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
               xla_accounting_err_pkg.build_message
                  (p_appli_s_name            => 'XLA'
                  ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
                  ,p_token_1                 => 'ACCT_ATTR_NAME'
                  ,p_value_1                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('GL_TRANSFER_FLAG')
                  ,p_token_2                 => 'PRODUCT_NAME'
                  ,p_value_2                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                  ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                  ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                  ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
            END IF;

         WHEN 'TRX_ACCT_REVERSAL_OPTION'          THEN
            -- 5161760
            IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
               IF length(p_rec_acct_attrs.array_char_value(i)) > 1 THEN
                  g_rec_header_new.array_trx_acct_reversal_option(g_header_idx) := 'X';
               ELSE
                  g_rec_header_new.array_trx_acct_reversal_option(g_header_idx) := nvl(p_rec_acct_attrs.array_char_value(i), 'N');
               END IF;
            ELSE
               g_rec_header_new.array_trx_acct_reversal_option(g_header_idx) := nvl(p_rec_acct_attrs.array_num_value(i), 'N');
            END IF;

            IF NVL(g_rec_header_new.array_trx_acct_reversal_option(g_header_idx),'N') NOT IN ('Y', 'N') THEN
               XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
               xla_accounting_err_pkg.build_message
                  (p_appli_s_name            => 'XLA'
                  ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
                  ,p_token_1                 => 'ACCT_ATTR_NAME'
                  ,p_value_1                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
                  ,p_token_2                 => 'PRODUCT_NAME'
                  ,p_value_2                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                  ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                  ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                  ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
            END IF;

         WHEN 'PARTY_CHANGE_TYPE'         THEN
            IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
              g_rec_header_new.array_party_change_type(g_header_idx)          := p_rec_acct_attrs.array_char_value(i);
            ELSE
              g_rec_header_new.array_party_change_type(g_header_idx)          := p_rec_acct_attrs.array_num_value(i);
            END IF;

         WHEN 'DOC_SEQUENCE_ID'           THEN
            g_rec_header_new.array_doc_sequence_id(g_header_idx)         := p_rec_acct_attrs.array_num_value(i);

         WHEN 'DOC_SEQUENCE_VALUE'        THEN
            g_rec_header_new.array_doc_sequence_value(g_header_idx)      := p_rec_acct_attrs.array_num_value(i);

/*  -- 4458381 Public Sector Enh
         WHEN 'ENCUMBRANCE_TYPE_ID'       THEN
            g_rec_header_new.array_encumbrance_type_id(g_header_idx)     := p_rec_acct_attrs.array_num_value(i);
*/

         WHEN 'BUDGET_VERSION_ID'         THEN
            g_rec_header_new.array_budget_version_id(g_header_idx)       := p_rec_acct_attrs.array_num_value(i);

         WHEN 'NEW_PARTY_ID'              THEN
            g_rec_header_new.array_new_party_id(g_header_idx)            := p_rec_acct_attrs.array_num_value(i);

         WHEN 'NEW_PARTY_SITE_ID'         THEN
            g_rec_header_new.array_new_party_site_id(g_header_idx)       := p_rec_acct_attrs.array_num_value(i);

         WHEN 'PREVIOUS_PARTY_ID'         THEN
            g_rec_header_new.array_previous_party_id(g_header_idx)       := p_rec_acct_attrs.array_num_value(i);

         WHEN 'PREVIOUS_PARTY_SITE_ID'    THEN
            g_rec_header_new.array_previous_party_site_id(g_header_idx)  := p_rec_acct_attrs.array_num_value(i);

         WHEN 'GL_DATE'                   THEN
            g_rec_header_new.array_gl_date(g_header_idx) := trunc(p_rec_acct_attrs.array_date_value(i));
            IF p_rec_acct_attrs.array_date_value(i) is NULL THEN
               XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
               xla_accounting_err_pkg.build_message
                  (p_appli_s_name            => 'XLA'
                  ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
                  ,p_token_1                 => 'ACCT_ATTR_NAME'
                  ,p_value_1                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('GL_DATE')
                  ,p_token_2                 => 'PRODUCT_NAME'
                  ,p_value_2                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                  ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                  ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                  ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
            END IF;
         ELSE null;
      END CASE;
   end loop;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_HEADER_PKG.SetHdrAcctAttrs');
  --
end SetHdrAcctAttrs;
--
/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
 +======================================================================*/
PROCEDURE ValidateBusinessDate
(p_ledger_id                      IN NUMBER
)
IS
l_transaction_calendar_id          INTEGER;
l_effective_date_rule_code         VARCHAR2(1);

l_log_module                       VARCHAR2(240);
l_count                            NUMBER DEFAULT 0;    --bug7025386

BEGIN

IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateBusinessDate';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of ValidateBusinessDate'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_transaction_calendar_id := xla_accounting_cache_pkg.GetValueNum('TRANSACTION_CALENDAR_ID', p_ledger_id);

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_transaction_calendar_id ='||l_transaction_calendar_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

IF (xla_accounting_cache_pkg.getValueChar('ENABLE_AVERAGE_BALANCES_FLAG',p_ledger_id) = 'Y' AND
    xla_accounting_cache_pkg.getValueChar('EFFECTIVE_DATE_RULE_CODE',p_ledger_id) = 'R' AND
    l_transaction_calendar_id IS NOT NULL) THEN

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
       (p_msg      => 'SQL - update xla_ae_headers_gt'
       ,p_level    => C_LEVEL_STATEMENT
       ,p_module   => l_log_module);
  END IF;

  -- bug 8898196
  UPDATE xla_ae_headers_gt xah
     SET accounting_date =
         DECODE(xah.acc_rev_gl_date_option,
                'XLA_NEXT_DAY',
                (SELECT min(transaction_date)
                   FROM gl_transaction_dates d1
                  WHERE d1.business_day_flag = 'Y'
                    AND d1.transaction_date >= xah.accounting_date
                    AND d1.transaction_calendar_id = l_transaction_calendar_id),
                -- XLA_FIRST_DAY_NEXT_GL_PERIOD, XLA_LAST_DAY_NEXT_GL_PERIOD, NONE
                (SELECT transaction_date
                   FROM (SELECT /*+  USE_NL_WITH_INDEX(XAH2, GL_TRANSACTION_DATES_U1) */ xah2.ae_header_id
                              , d.transaction_date
                           FROM xla_ae_headers_gt xah2
                              , gl_transaction_dates d
                          WHERE d.transaction_calendar_id = l_transaction_calendar_id
                            AND d.business_day_flag       = 'Y'
                            AND d.transaction_date        >= xah2.period_start_date
                          ORDER by CASE WHEN d.transaction_date = xah2.accounting_date
                                        THEN 0
                           --       added vdamerla bug 8898196
                           --             WHEN d.transaction_date < xah2.accounting_date
                           --             THEN xah2.accounting_date - d.transaction_date
                                        WHEN d.transaction_date > xah2.accounting_date
                                        THEN 1000 + d.transaction_date - xah2.accounting_date
                                        END ) tmp
                  WHERE ROWNUM = 1
                    AND xah.ae_header_id = tmp.ae_header_id
                    and  tmp.TRANSACTION_DATE >= XAH.PERIOD_START_DATE  /* added vdamerla bug 8898196 */));


--bug7025386 START

        l_count := SQL%ROWCOUNT;



        IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_msg      => '# rows updated in xla_ae_headers_gt(1.2) ='|| l_count
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
        END IF;



        IF l_count > 0 THEN


               FORALL i IN xla_ae_journal_entry_pkg.g_array_ae_header_id.FIRST .. xla_ae_journal_entry_pkg.g_array_ae_header_id.LAST
                    UPDATE xla_ae_lines_gt XAL
                    SET XAL.ACCOUNTING_DATE = (SELECT xah.accounting_date
                                               FROM xla_ae_headers_gt xah
                                               WHERE xah.ae_header_id = xla_ae_journal_entry_pkg.g_array_ae_header_id(i)
                                                 and   xah.ledger_id = xla_ae_journal_entry_pkg.g_array_ledger_id(i)
                                                  and  xah.event_id = xla_ae_journal_entry_pkg.g_array_event_id(i)
                                                  and  xah.balance_type_code = xla_ae_journal_entry_pkg.g_array_balance_type(i)
                                                )
                    WHERE xal.ae_header_id = xla_ae_journal_entry_pkg.g_array_event_id(i)
                         and   xal.ledger_id = xla_ae_journal_entry_pkg.g_array_ledger_id(i)
                         and  xal.event_id = xla_ae_journal_entry_pkg.g_array_event_id(i)
                         and xal.balance_type_code = xla_ae_journal_entry_pkg.g_array_balance_type(i);


                l_count := SQL%ROWCOUNT;

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                    trace
                       (p_msg      => '# rows updated in xla_ae_lines_gt(date_adjust) =' || l_count
                       ,p_level    => C_LEVEL_STATEMENT
                       ,p_module   => l_log_module);
                END IF;

        END IF;



END IF;


--bug7025386 END



IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of ValidateBusinessDate'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
                (p_location => 'xla_ae_header_pkg.ValidateBusinessDate');
END ValidateBusinessDate;

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

END xla_ae_header_pkg; --

/
