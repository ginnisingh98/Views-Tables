--------------------------------------------------------
--  DDL for Package Body XLA_AE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AE_LINES_PKG" AS
/* $Header: xlajelns.pkb 120.197.12010000.25 2010/04/07 05:41:34 nmsubram ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     XLA_AE_LINES_PKG                                                       |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema    Created                                      |
|     08-JAN-2003 K.Boussema    Changed xla_temp_journal_entries by          |
|                               xla_journal_entries_temp                     |
|     10-JAN-2003 K.Boussema    Removed gl_sl_link_id column from temp table |
|                               Added 'dbdrv' command                        |
|     11-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-MAR-2003 K.Boussema    Added distribution_id_num_1..5 columns       |
|     03-APR-2003 K.Boussema    Included Analytical criteria feature         |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     06-MAI-2003 K.Boussema    Modified to fix bug 2936066(Unbalanced JE)   |
|     13-MAI-2003 K.Boussema    Renamed temporary tables xla_je_lines_gt by  |
|                               xla_ae_lines_gt, xla_je_headers_gt by        |
|                               xla_ae_headers_gt                            |
|                               Renamed in xla_distribution_links the column |
|                               base_amount by ledger_amount                 |
|     20-MAI-2003 K.Boussema    Added a Token to XLA_AP_CANNOT_INSERT_JE     |
|                               message                                      |
|     27-MAI-2003 K.Boussema    Renamed code_combination_status by           |
|                                  code_combination_status_flag              |
|                               Renamed base_amount by ledger_amount         |
|     30-MAI-2003 K.Boussema    Renamed EXCHANGE_RATE_DATE by EXCHANGE_DATE  |
|                                 bug 2979525                                |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     21-JUL-2003 K.Boussema    Changed reversal options from 'S' and 'R' to |
|                               'SIGN' and 'SIDE'                            |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     10-SEP-2003 K.Boussema    Changed to fix bug3095206:Accounting Reversal|
|     19-SEP-2003 K.Boussema    Code changed to include reversed_ae_header_id|
|                               and reversed_line_num, see bug 3143095       |
|     30-SEP-2003 K.Boussema    Added a validation for Accounting reversal   |
|     03-OCT-2003 K.Boussema    Fixed standard accounting reversal,bug3174532|
|                               Changed description width to 1996            |
|     06-OCT-2003 K.Boussema    Reviewed the StandardAccountingReversal() pg,|
|                               bug 3175581                                  |
|     16-OCT-2003 K.Boussema    Fixed the issue when the entered and         |
|                               accounted amounts are reversed.              |
|     22-OCT-2003 K.Boussema    Changed to capture the Merge Matching Lines  |
|                               preference for Accounting Reversal from JLT  |
|     29-OCT-2003 K.Boussema    Reviewed to fix bug 3222733                  |
|     04-NOV-2003 K.Boussema    Added TransactionReversal_2, LineReversal_2  |
|     13-NOV-2003 K.Boussema    Changed to store Accounting and transaction  |
|                               coa ids defined in Account Derivation rules  |
|     21-NOV-2003 K.Boussema    Added SetEnteredAmount to fix bug 3233610    |
|     25-NOV-2003 Shishir Joshi Made changers for accounting reversal.       |
|                               Merged procedures StandardAccountingReversal |
|                               and LineReversal_2.                          |
|                               Merged procedures TransactionReversal and    |
|                               TransactionReversal_2.                       |
|     05-DEC-2003 K.Boussema    Changed the code to fix bug3289875           |
|     12-DEC-2003 K.Boussema    Renamed target_coa_id in xla_ae_lines_gt     |
|                               by ccid_coa_id                               |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     07-JAN-2003 K.Boussema    Changed to populate switch_side_flag column  |
|     19-JAN-2004 K.Boussema    Removed the validation of Third party        |
|     20-JAN-2004 K.Boussema    Updated the message error XLA_AP_COA_INVALID |
|                               and Reviewed the validation of PARTY_TYPE    |
|     05-FEB-2004 S.Singhania   Changes based on bug 3419803.                |
|                                 - correct column names are used            |
|                                   TAX_LINE_REF_ID, TAX_SUMMARY_LINE_REF_ID,|
|                                   TAX_REC_NREC_DIST_REF_ID                 |
|                                 - reference to the column is removed.      |
|                                   TAX_REC_NREC_SUMMARY_DIST_REF            |
|                                 - Aaccounting attribute codes are modified |
|                                 - variables storing the column value       |
|                                   TAX_REC_NREC_SUMMARY_DIST_REF are removed|
|     17-FEB-2004 K.Boussema    Revised SetDebitCreditAmounts to fix issue   |
|                                 reported in bug 3438418                    |
|                               Made changes for the FND_LOG.                |
|     11-MAR-2004 K.Boussema    Reviewed StandardAccountingReversal and      |
|                                 TransactionReversal                        |
|                               Removed the validations of accounting class  |
|                                 and the party type                         |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls|
|                                 and the procedure.                         |
|     04-MAY-2004 K.Boussema    Bug 3531441: updated call to message         |
|                                 XLA_AP_NO_LEDGER_AMOUNT                    |
|     11-MAY-2004 K.Boussema    Removed the call to XLA trace routine from   |
|                                 trace() procedure                          |
|     17-MAY-2004 W.Shen        Changes for attribute enhancement project    |
|                                 Change to InsertLines,                     |
|                                 StandardAccountingReversal                 |
|                              move TransactionReversal toxla_ae_headers_pkg |
|                                 accounting_reversal is no longer used      |
|     26-MAY-2004 W.Shen        remove debug code.                           |
|     17-JUN-2004 K.Boussema    Removed the population with null the         |
|                                 conversion rate and the conversion type    |
|                                 when entered entered currency code = ledger|
|                                 currency code, bug 3592650                 |
|     18-JUN-2004 K.Boussema    Fixed GSCC warning                           |
|     27-JUN-2004 W.Shen        Fix the validation links(ValidateLinks,      |
|                                 ValidateRevLinks bug 3787453               |
|     22-Sep-2004 S.Singhania   Made changes for the bulk peroformance. It   |
|                                 has changed the code at number of places.  |
|     03-Nov-2004 S.Singhania   Bug 3984919. Fixed the technical problem in  |
|                                 AccountingReversal.                        |
|                               Also modified the insert statments in        |
|                                 AccountingRevesal to use amounts from      |
|                                 xla_distribution_links instead of amounts  |
|                                 from xla_ae_lines table.                   |
|     09-MAR-2005 W.Shen       Ledger Currency Project.                      |
|     14-Mar-2005 K.Boussema   Changed for ADR-enhancements.                 |
|     28-Mar-2005 A.Wan        Changed for Business Flow.                    |
|     20-Apr-2005 W. Shen      replace column document_rounding_amount by    |
|                                 doc_rounding_acctd_amt                     |
|     25-Apr-2005 S.singhania  Bug 4257522. Issue fixed with the transaction |
|                                 reversls.                                  |
|     19-MAI-2005 K.Boussema   Reviewed set_segment to fix bug4304098        |
|     25-MAY-2005 W.Chan       fix bug4384869 - BusinessFlowSameEntries      |
|     1-Jul-2005  W. Shen      Bug 4243728, 4444730                      .   |
|                              set entered_cr/dr side based on               |
|                                unrounded_accounted_amount if entered is 0  |
|                                (mainly for gain/loss line)                 |
|                              calculate rounded amount sole based on        |
|                                the calculate_amts_flag.                    |
|                                set calculate_amts_flag correctly.          |
|     11-Jul-2005 A.Wan        4262811 - MPA project                         |
|     12-Jul-2005 W. Chan      Bug 4478604 - Fixed business flow for sec     |
|                              ledg  ALC ledg.  Fixed accounted amount calc  |
|                              for business flow.                            |
|     9-Sep-2005 W. Shen       Bug 4596489, msg XLA_AP_NO_LEDGER_AMOUNT      |
|                                has moved one token                         |
|     22-Sep-2005 S.Singhania  Bug 4544725. Implemented Business Flows and   |
|                                Reversals for Non-Upgraded JEs.             |
|     26-Sep-2005 W. Shen      Bug 4628603. reset g_transaction_accounts     |
|                                after insertion so no duplicated rows will  |
|                                be inserted.                                |
|                                removed the header_num in AccountingReversal|
|                                since it may cause unique index violated    |
|     12-Oct-2005 A.Wan        4656703 - bflow prior entry amt incorrect     |
|     18-Oct-2005 V. Kumar    Removed code for Analytical Criteria           |
|     7-Nov-2005 W.Shen       4655713 - bflow same entry does not work       |
|     17-Nov-2005 W.Shen      4727011 - unique index violated                |
|                                In accountingreversal, when inserting header|
|                                for lines that do not have header yet, the  |
|                                join condition of header_num is not correct |
|                                add nvl for join of header_num since it     |
|                                could be null                               |
|     22-Dec-2005 W.Chan      4903255 - Prior Entry Bflow changes            |
|                             1) Exclude reversal from prior entry           |
|                             2) Allow multiple prior entries                |
|     22-Dec-2005 A.Wan       4669308 - AccountingReversal - for MPA/Accrual |
|                                       reversal.                            |
|     3-Jan-2006  W. Chan     Bug 4924492 - Populate budget version id for   |
|                               accounting reversal                          |
|     4-Jan-2006  A. Govil    Bug 4922099 - Handle Federal Non-upgraded      |
|                             entries.                                       |
|     7-Jan-2006  W. Chan     Bug 4930297 - BflowPriorEntries error cursor   |
|                               not work if bflow app id is null             |
|     20-Jan-2006 W.Chan      4946123 - BC changes for prior entry           |
|     27-Jan-2005 A.Wan       5001981 - Same entry exclude lines with        |
|                             PRIOR_ENTRY business flow method.              |
|     27-Jan-2006 A.Wan       4913967 - performance change for               |
|                                       BusinessFlowSameEntries.             |
|     27-Jan-2006 V.Kumar     4963125 Added hint and join based on appl_id   |
|                               in AccountingReversal.                       |
|     27-Jan-2006 A.Wan       4655713  - to set proper status for SameEntry. |
|     31-Jan-2006 A.Wan       4963422  - set header_num to 0 in acct reversal|
|     01-Feb-2006 A.Wan       4655713b - modify BusinessFlowPriorEntries and |
|                                        BusinessFlowSameEntries to inherit  |
|                                        ae_lines_gt detail for bflow entries|
|                                        for MPA and Accrual Reversal lines. |
|     10-Feb-2006 A.Wan       5019460 - could not reverse prior entries.     |
|     13-Feb-2006 V.Kumar     4955764 Populating Accounting_date in          |
|                                     xla_ae_lines_gt                        |
|     14-Feb-2006 A.Wan       4967526 - copy following for Third Party info  |
|                                       in BusinessFlowPriorEntries:         |
|                                       - merge_code_combination_id          |
|                                       - merge_party_id                     |
|                                       - merge_party_site_id                |
|     20-Feb-2006 A.Wan       4913967 - remove redundant GROUP BY in         |
|                                       BusinessFlowSameEntries.             |
|     28-Feb-2006 A.Wan       5068675 - undo fix on 20-Feb for bug 4913967   |
|     01-Mar-2006 A.Wan       5055878 - Accounting reversal does not handle  |
|                                       reversal method of SIGN.             |
|     07-Mar-2006 A.Wan       4693816 - do not assign PARTY_TYPE is size is  |
|                                       more than 1.                         |
|     08-Mar-2006 V.Kumar     Modified procedure SetNewLines and added new   |
|                             procedure SetNullLine                          |
|     13-Mar-2006 A.Wan       5086984 - modify MPA/Accrual reversal in       |
|                                       AccountingReversal for performance.  |
|     27-Mar-2006 A.Wan       5108415 - modify Accounting reversal for       |
|                                       peformance fix.                      |
|     15-Apr-2006 A.Wan       5132302 - add Applied To Amount for Gain/Loss  |
|     25-Apr-2006 A.Wan       5183946 - line acct reversal error for Accrual |
|                                       Reversal.                            |
|     09-May-2006 V.Kumar     5194849 Modified procedure SetAcctReversalAttrs|
|                                     to populate GL_date for Reversal Acct  |
|     09-May-2006 A.Wan       5204178 - cannot find PE for sec ledger if     |
|                                       valuation method is Yes.             |
|     19-May-2006 V.Kumar     5229264 Modified procedure SetTrxReversalAttrs |
|     11-May-2006 A.Wan       5189664 - reversal line not stamped with       |
|                                       date from reversal event.            |
|     09-May-2006 A.Wan       5162408 - invalid value for acct attribute.    |
|     22-Jun-2006 W.Shen      5294631, 5259776 - put gain/loss amount on dr  |
|                                       side as well so reversal can handle  |
|                                    also, add ccid mapping for g/l lines    |
|     22-Jun-2006 A.Wan       5100860 - make sure to assign a value to       |
|                                       HEADER_NUM in InsertLines.           |
|     28-Jul-2006 A.Wan       5357406 - prior entry performance fix          |
|     01-Aug-2006 A.Wan       5412560 - line reversal for MPA/AccRev.        |
|     17-Aug-2006 A.Wan       5443083 - delete zero amt same entry in ALC    |
|                                       and secondary ledger.                |
|     23-Aug-2006 A.Wan       5486053 - add HINT to same entry               |
|     25-Aug-2006 A.Wan       5479652 - modify condition in line reversal.   |
|     01-SEP-2006 A.Wan       5163338 - raise error when CCID is -1          |
|     20-NOV-2006 A.Wan       5666366 - do not execute MPA-prior entry SQL   |
|                                       if there are no MPA in this run.     |
|     26-jan-2007 A.Wan       5845547 - upgrade fail for not upgraded bflow  |
|                                       and reversal transactions.  Add      |
|                                       upgrade party attributes.            |
|     14-Dec-2007 V.Swapna    6648062 - Populate xla_ae_lines_gt with        |
|                                       the values passed in override acctd  |
|                                       amts accounting attribute and use    |
|                                       it in business flow procedure        |
|     31-Dec-2007 V. Swapna   5339999 - Changes to BusinessFlowPriorEntries  |
|                                       for Historic upgrade of secondary/alc|
|     25-Jan-2007 S.Sawhney   6658161,6727907 --merged branchline fixes onto mainline |
|     05-Nov-2007 KARAMAKR    7485529 - merged branchline fixes onto mainline|
|     06-Nov-2008 VGOPISET    7337288 - AccountingReversal is changed to     |
|                                       consider the SWITCH_SIDE option of   |
|                                       Reversal Event rather than value of  |
|                                       Original Event                       |
|     27-NOV-2008 VGOPISET    7581008 - Reverting C_BULK_LIMIT to 1000 from  |
|                                       5000.                                |
|     29-JAN-2009 VGOPISET    7704240 - SetDebitCreditAmount changed to have |
|                                       absolute BFLOW APPLIED AMOUNT when   |
|                                       change SIDE is used for negative     |
|                                       amounts passed from Subledgers.      |
|     26-FEB-2009 VGOPISET    8277823 - Populate REF_EVENT_ID as negative    |
|                                       in AccountingReversal when Original  |
|                                       and Reversal accounted in same Run   |
|     2-mar-2009 ssawhney    8250875   changed hint in businessflowpriorentry|
|                                      cursor                                |
|     1-MAR-2009 VGOPISET     7109881 - Included new procedures like         |
|                                       InsertMPALineInfo,SetNullMPALineInfo |
|                                       and overloaded CopyLineInfo.         |
|     9-MAR-2009 schodava     7541615 - Procedure SetDebitCreditAmounts -    |
|                                       Nullified the currency conversion    |
|                                       type and rate if entered currency is |
|                                       same as ledger currency              |
|    02-Jun-2009 VGOPISET     8505463 - Changes in AccountingReversal for    |
|                                       MPA Cancellation.                    |
|    20-sep-2009 ssawhney     8773083   Modified CalculateGainLossAmounts    |
|              and 8452052 and 8920369  completely.  Added hint to pick      |
|	                                XALG_U1 for update xla_ae_lines_gt   |
|					in SameEntry/PriorEntry              |
|    18-Mar-2010 ssawhney     9483834   incorrect alias in the hints in CalculateGainLossAmounts |
|    26-Mar-2010 krsankar     8810416   Modified the currency conversion     |
|                                       details in FUNCTION InsertLines for  |
|                                       merging lines issue between Primary  |
|                                       and Secondary Ledgers                |
|    30-Mar-2010 M.S.Narayanan 9352035  Changed BusinessFlowPriorEntries to store|
|                                       exchange rate derived from xla_distribution_links|
|                                       of upstream transactions. This derived exchange rate|
|                                       is used for accounted amount calculation of downstream|
|                                       transactions whose corresponding upstream|
|                                       transactions are merged to zero.	|
+===========================================================================*/
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| CONSTANT                                                                 |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
C_MAXROWS             CONSTANT NATURAL     := 1000;
C_BULK_LIMIT          CONSTANT NUMBER      := 500; -- 5000; reverted,for bug:7581008, reverted again for bug9360982
--
--
-- Accounting entry type code
--
C_STANDARD               CONSTANT VARCHAR2(30) := 'STANDARD';
C_INVALID_STATUS         CONSTANT VARCHAR2(1)  := 'I';
C_DRAFT_STATUS           CONSTANT VARCHAR2(1)  := 'D';
C_FINAL_STATUS           CONSTANT VARCHAR2(1)  := 'F';

-- ccid status
C_CREATED                CONSTANT VARCHAR2(30)  := 'CREATED';
C_PROCESSING             CONSTANT VARCHAR2(30)  := 'PROCESSING';
C_NOT_PROCESSED          CONSTANT VARCHAR2(30)  := 'NOT_PROCESSED';
C_INVALID                CONSTANT VARCHAR2(30)  := 'INVALID';

C_MAP_CCID                   CONSTANT    VARCHAR2(30)  := 'MAP_CCID';
C_MAP_QUALIFIER              CONSTANT    VARCHAR2(30)  := 'MAP_QUALIFIER';
C_MAP_SEGMENT                CONSTANT    VARCHAR2(30)  := 'MAP_SEGMENT';

--
C_ACTUAL            CONSTANT VARCHAR2(1)       := 'A';
C_BUDGET            CONSTANT VARCHAR2(1)       := 'B';
C_ENCUMBRANCE       CONSTANT VARCHAR2(1)       := 'E';
--
C_DEBIT             CONSTANT VARCHAR2(1)       := 'D';
C_CREDIT            CONSTANT VARCHAR2(1)       := 'C';
--
C_SWITCH               CONSTANT VARCHAR2(1)    := 'Y';
C_NO_SWITCH            CONSTANT VARCHAR2(1)    := 'N';
--
C_ALL                 CONSTANT  VARCHAR2(1)    := 'A';
C_SAME_SIDE           CONSTANT  VARCHAR2(1)    := 'W';
C_NO_MERGE            CONSTANT  VARCHAR2(1)    := 'N';
--
-- 4669308
C_NO_REVERSAL         CONSTANT  VARCHAR2(20)   := 'NO_MPA_REVERSAL';
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|  GLobal structure  For Accounting Reversal                               |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

--
TYPE t_rec_reverse_line IS RECORD (
--
 ae_header_id                      NUMBER,
 line_num                          NUMBER,
 accounting_class                  VARCHAR2(30),
--
 ccid                              NUMBER,
--
 gl_transfer_mode                  VARCHAR2(1),
 acct_entry_type_code              VARCHAR2(1),
 merge_duplicate_code              VARCHAR2(1),
 --
 entered_amount                    NUMBER,
 ledger_amount                     NUMBER,
 entered_dr                        NUMBER,
 entered_cr                        NUMBER,
 accounted_dr                      NUMBER,
 accounted_cr                      NUMBER,
 currency_code                     VARCHAR2(15),
 curr_conversion_date              DATE,
 curr_conversion_rate              NUMBER,
 curr_conversion_type              VARCHAR2(30),
 description                       VARCHAR2(1996),
 --
 -- line descriptions
 --
 party_id                          NUMBER,
 party_site_id                     NUMBER,
 party_type_code                   VARCHAR2(1),
 --
 statistical_amount                NUMBER,
 ussgl_transaction                 VARCHAR2(30),
--
 jgzz_recon_ref                    VARCHAR2(240),
--
 distribution_id_char_1            VARCHAR2(240),
 distribution_id_char_2            VARCHAR2(240),
 distribution_id_char_3            VARCHAR2(240),
 distribution_id_char_4            VARCHAR2(240),
 distribution_id_char_5            VARCHAR2(240),
 distribution_id_num_1             NUMBER,
 distribution_id_num_2             NUMBER,
 distribution_id_num_3             NUMBER,
 distribution_id_num_4             NUMBER,
 distribution_id_num_5             NUMBER,
 sys_distribution_type             VARCHAR2(30),
--
 rev_distrib_id_char_1             VARCHAR2(240),
 rev_distrib_id_char_2             VARCHAR2(240),
 rev_distrib_id_char_3             VARCHAR2(240),
 rev_distrib_id_char_4             VARCHAR2(240),
 rev_distrib_id_char_5             VARCHAR2(240),
 rev_distrib_id_num_1              NUMBER,
 rev_distrib_id_num_2              NUMBER,
 rev_distrib_id_num_3              NUMBER,
 rev_distrib_id_num_4              NUMBER,
 rev_distrib_id_num_5              NUMBER,
 rev_sys_distribution_type         VARCHAR2(30),
--
 acc_reversal_option               VARCHAR2(1),
 reversal_credit_ccid              NUMBER,
 reversal_debit_ccid               NUMBER,
--
 mpa_option                        VARCHAR2(30),  -- 4262811
 mpa_start_date                    DATE,          -- 4262811
 mpa_end_date                      DATE,          -- 4262811
-- Removed for 4262811 MPA
-- deferred_indicator                VARCHAR2(1),
-- deferred_start_date               DATE,
-- deferred_end_date                 DATE,
-- deferred_no_period                NUMBER,
-- deferred_period_type              VARCHAR2(1),
--
 tax_line_ref                      NUMBER,
 tax_summary_line_ref              NUMBER,
 tax_rec_nrec_dist_ref             NUMBER
--
);

--
-- cache accounting line type information
--
--g_accounting_line
TYPE t_rec_accounting_line IS RECORD (
    component_type              VARCHAR2(30)
  , accounting_line_code        VARCHAR2(30)
  , accounting_line_type_code   VARCHAR2(1)
  , accounting_line_appl_id     INTEGER
  , amb_context_code            VARCHAR2(30)
  , entity_code                 VARCHAR2(30)
  , event_class_code            VARCHAR2(30)
)
;

--g_transaction_accounts
TYPE t_rec_transaction_accounts IS RECORD (
 array_line_num                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num,
 array_ae_header_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num,
 array_temp_line_num                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num,
 array_code_combination_id               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num,
 array_segment                           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L,
 array_from_segment_code                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V15L,
 array_to_segment_code                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_V15L,
 array_processing_status_code            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L,
 array_side_code                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
)
;

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|  GLobal variables                                                        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

g_reverse_lines                t_rec_reverse_line;
g_application_id               INTEGER;
g_accounting_line              t_rec_accounting_line;
g_transaction_accounts         t_rec_transaction_accounts;

--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|  GLobal variables  For Business Flow - 4219869                           |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
g_num_bflow_prior_entries INTEGER;
g_num_bflow_same_entries  INTEGER;
C_METHOD_PRIOR    CONSTANT VARCHAR2(30) := 'PRIOR_ENTRY';
C_METHOD_SAME     CONSTANT VARCHAR2(30) := 'SAME_ENTRY';
C_DUMMY_PRIOR     CONSTANT VARCHAR2(10) := 'DUMMY_BFPE';
C_DUMMY_SAME      CONSTANT VARCHAR2(10) := 'DUMMY_BFSE';
C_MPA_PRIOR_ENTRY CONSTANT VARCHAR2(30) := 'MPA_PRIOR_ENTRY';  -- 4655713b
C_MPA_SAME_ENTRY  CONSTANT VARCHAR2(30) := 'MPA_SAME_ENTRY';   -- 4655713b
C_CHAR            CONSTANT VARCHAR2(1)  := fnd_global.local_chr(12);
C_NUM             CONSTANT NUMBER       := 9.99E125;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_AE_LINES_PKG';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2) IS
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
             (p_location   => 'XLA_AE_LINES_PKG.trace');
END trace;

--=============================================================================
--                   ******* Print Log File **********
--=============================================================================
PROCEDURE print_logfile(p_msg  IN  VARCHAR2) IS
BEGIN

   fnd_file.put_line(fnd_file.log,p_msg);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_ae_lines_pkg.print_logfile');
END print_logfile;
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

--
PROCEDURE ValidateLinks
;

--
--4219869 : making this a public function for Business Flow
--PROCEDURE SetDebitCreditAmounts
--;
--
--

FUNCTION ValidateRevLinks
RETURN BOOLEAN
;

--===================================================================
--
--
--
--
--
--                     STANDARD ACCOUNTING PROCESS
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
--=====================================================================
--

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
|                                                                       |
+======================================================================*/
PROCEDURE ValidateLinks
IS
l_log_module         VARCHAR2(240);
l_temp               NUMBER;
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateLinks';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of ValidateLinks'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- We need check: 1. distribution_id_1 must be assigned
--                2. distribution_id_2..5 must be assigned in order, that means
--                    if id_3 is assigned, then 2 must be assigned.
--                    if id_4 is assigned, then 2 and 3 must be assigned.
--                    if id_5 is assigned, then 2, 3 and 4 must be assigned.
--                We are using generate a number, l_temp
--                1*decode(id5 is assigned, 1, 0)+
--                2*decode(id4 is assigned, 1, 0)+
--                4*decode(id3 is assigned, 1, 0)+
--                8*decode(id2 is assigned, 1, 0)
--                The valid case, l_temp can only be
--                0 -- no one is assigned
--                8 -- id2 is assigned
--                12 -- id2 and id3 are assigned
--                14 -- id2 , id3 and id4 are assigned
--                15 -- all are assigned


IF g_rec_lines.array_distribution_id_char_5(g_LineNumber) IS NULL AND
      g_rec_lines.array_distribution_id_num_5(g_LineNumber) IS NULL THEN
  l_temp := 0;
ELSE
  l_temp := 1;
END IF;
IF g_rec_lines.array_distribution_id_char_4(g_LineNumber) IS NOT NULL OR
      g_rec_lines.array_distribution_id_num_4(g_LineNumber) IS NOT NULL THEN
  l_temp := 2+l_temp;
END IF;
IF g_rec_lines.array_distribution_id_char_3(g_LineNumber) IS NOT NULL OR
      g_rec_lines.array_distribution_id_num_3(g_LineNumber) IS NOT NULL THEN
  l_temp := 4+l_temp;
END IF;
IF g_rec_lines.array_distribution_id_char_2(g_LineNumber) IS NOT NULL OR
      g_rec_lines.array_distribution_id_num_2(g_LineNumber) IS NOT NULL THEN
  l_temp := 8+l_temp;
END IF;
IF (g_rec_lines.array_distribution_id_char_1(g_LineNumber) IS NULL AND
      g_rec_lines.array_distribution_id_num_1(g_LineNumber) IS NULL) OR
      l_temp not in (0, 8, 12, 14, 15) THEN

    xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
    xla_accounting_err_pkg.build_message
                                  (p_appli_s_name            => 'XLA'
                                  ,p_msg_name                => 'XLA_AP_NO_DIST_LINK_ID'
                                  ,p_token_1                 => 'LINE_NUMBER'
                                  ,p_value_1                 =>  g_ExtractLine
                                  ,p_token_2                 => 'LINE_TYPE_NAME'
                                  ,p_value_2                 =>  xla_ae_sources_pkg.GetComponentName (
                                                                  g_accounting_line.component_type
                                                                , g_accounting_line.accounting_line_code
                                                                , g_accounting_line.accounting_line_type_code
                                                                , g_accounting_line.accounting_line_appl_id
                                                                , g_accounting_line.amb_context_code
                                                                , g_accounting_line.entity_code
                                                                , g_accounting_line.event_class_code
                                                               )
                                  ,p_token_3                 => 'OWNER'
                                  ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                  'XLA_OWNER_TYPE'
                                                                 , g_rec_lines.array_accounting_line_type(g_LineNumber)
                                                                )
                                  ,p_token_4                 => 'PRODUCT_NAME'
                                  ,p_value_4                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
                                  ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                                  ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                                  ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                                  ,p_ae_header_id            => NULL --p_ae_header_id
                         );

         IF (C_LEVEL_ERROR >= g_log_level) THEN
                trace
                     (p_msg      => 'ERROR: XLA_AP_NO_DIST_LINK_ID'
                     ,p_level    => C_LEVEL_ERROR
                     ,p_module   => l_log_module);
         END IF;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of ValidateLinks'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_lines_pkg.ValidateLinks');
  --
END ValidateLinks;
--
--
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|       SetDebitCreditAmounts                                           |
|                                                                       |
+======================================================================*/
PROCEDURE SetDebitCreditAmounts
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetDebitCreditAmounts';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetDebitCreditAmounts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF(nvl(g_override_acctd_amt_flag, 'N') = 'Y') THEN
  g_rec_lines.array_calculate_acctd_flag(g_LineNumber) := 'N';
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
       (p_msg      => 'set amts flag to N '
       ,p_level    => C_LEVEL_STATEMENT
       ,p_module   => l_log_module);
  END IF;

END IF;
/*
1. for alc enabled apps
 primary ledger, the calculate amts flag will be set as user set in the forms
 secondary ledger, if the currency is same as primary, the calculate amts flag will be
     set as user set in the forms
     if not same, the calculate amts flag will be set to 'Y'
 for ALC, the calculate amts flag will be set to 'Y'
 2. For alc not enabled apps:
 primaryledger, the flag set as user set in the form
 secondary, same as the alc_enabled_apps
 ALC, the calculate amts flag is set to 'N'
*/

IF((XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code = 'SECONDARY' or
       XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code = 'ALC') and
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='Y') THEN
  g_rec_lines.array_calculate_acctd_flag(g_LineNumber) := 'Y';
  g_rec_lines.array_calculate_g_l_flag(g_LineNumber) := 'Y';
ELSIF(XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code = 'ALC' and
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='N') THEN
  g_rec_lines.array_calculate_acctd_flag(g_LineNumber) := 'N';
  g_rec_lines.array_calculate_g_l_flag(g_LineNumber) := 'N';
END IF;

-- for performance bug 5394727, set the currency to ledger currency
-- since we need ledger currency later when set the currency code
-- for these gain/loss lines.
IF (g_rec_lines.array_natural_side_code(g_LineNumber) = 'G'
          AND (nvl(g_rec_lines.array_calculate_g_l_flag(g_LineNumber), 'N') = 'Y')) THEN
  g_rec_lines.array_currency_code(g_LineNumber)
                      := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code;
END IF;

IF (nvl(g_rec_lines.array_calculate_acctd_flag(g_LineNumber), 'N')= 'N' AND
      g_rec_lines.array_natural_side_code(g_LineNumber) <> 'G') OR
     (nvl(g_rec_lines.array_calculate_g_l_flag(g_LineNumber), 'N')='N' AND
      g_rec_lines.array_natural_side_code(g_LineNumber) = 'G') THEN

  IF g_rec_lines.array_ledger_amount(g_LineNumber) is null THEN
    XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
    xla_accounting_err_pkg.build_message
           (p_appli_s_name            => 'XLA'
           ,p_msg_name                => 'XLA_AP_NO_LEDGER_AMOUNT'
           ,p_token_1                 => 'LINE_NUMBER'
           ,p_value_1                 =>  g_ExtractLine
           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
           ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
  END IF;
--ELSE
--  g_rec_lines.array_ledger_amount(g_LineNumber) := null;
END IF;

--
-- SetEnteredAmount
-- change for business flow, if business flow, won't set the entered_amount
-- since at this time the final entered currency code is not decided yet.
IF NVL(g_rec_lines.array_currency_code(g_LineNumber),
           XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code) =
           XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code
     AND g_rec_lines.array_natural_side_code(g_LineNumber) <> 'G'
     AND  nvl(g_rec_lines.array_gain_or_loss_flag(g_LineNumber), 'N') <> 'Y'
AND nvl(g_rec_lines.array_reversal_code(g_LineNumber), 'DUMMY') <> C_DUMMY_PRIOR
THEN

  IF nvl(g_rec_lines.array_calculate_acctd_flag(g_LineNumber), 'N')= 'N' THEN
    g_rec_lines.array_entered_amount(g_LineNumber) :=  nvl(g_rec_lines.array_ledger_amount(g_LineNumber), g_rec_lines.array_entered_amount(g_LineNumber));
  ELSE
  --ledger currency proj, assign the entered amount to ledger amount instead
    g_rec_lines.array_ledger_amount(g_LineNumber) :=  g_rec_lines.array_entered_amount(g_LineNumber);
  END IF;

END IF;
--

-- Bug 7541615
-- Nullified the currency conversion type and rate if the entered currency is the same as ledger currency.
-- This nullification was inadvertently done only for non GAIN LOSS lines as a part of bug 4634321
-- This is fixed now, with the rate and type made null for all lines (except BFLow lines)

IF NVL(g_rec_lines.array_currency_code(g_LineNumber),
           XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code) =
           XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code
AND nvl(g_rec_lines.array_reversal_code(g_LineNumber), 'DUMMY') <> C_DUMMY_PRIOR
THEN

    --=======================================
    -- bug 2988192, removed by bug 3592650
    --=======================================
    g_rec_lines.array_curr_conversion_rate(g_LineNumber):= null;
    g_rec_lines.array_curr_conversion_type(g_LineNumber):= null;
  --
END IF;
--
-- bug 5259353
IF(g_rec_lines.array_natural_side_code(g_LineNumber) = 'G' or
                       g_rec_lines.array_gain_or_loss_flag(g_LineNumber) = 'Y') THEN
  g_rec_lines.array_entered_amount(g_LineNumber) := 0;
END IF;


IF(g_rec_lines.array_natural_side_code(g_LineNumber) <> 'G'
   AND  nvl(g_rec_lines.array_gain_or_loss_flag(g_LineNumber), 'N') <> 'Y'
   AND nvl(g_rec_lines.array_reversal_code(g_LineNumber), 'DUMMY') <> C_DUMMY_PRIOR) THEN
  IF g_rec_lines.array_entered_amount(g_LineNumber) is null THEN
    XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
    xla_accounting_err_pkg.build_message
           (p_appli_s_name            => 'XLA'
           ,p_msg_name                => 'XLA_AP_NO_ENTERED_AMOUNT'
           ,p_token_1                 => 'LINE_NUMBER'
           ,p_value_1                 =>  g_ExtractLine
           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
           ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
  ELSIF (nvl(g_rec_lines.array_calculate_acctd_flag(g_LineNumber), 'N')= 'N'
           AND ((sign(g_rec_lines.array_entered_amount(g_LineNumber)) > 0 and
               sign(g_rec_lines.array_ledger_amount(g_LineNumber))<0) or
           (sign(g_rec_lines.array_entered_amount(g_LineNumber)) < 0 and
               sign(g_rec_lines.array_ledger_amount(g_LineNumber))>0))
        ) THEN
    XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
    xla_accounting_err_pkg.build_message
           (p_appli_s_name            => 'XLA'
           ,p_msg_name                => 'XLA_AP_DIFFERENT_SIGN_AMOUNTS'
           ,p_token_1                 => 'LINE_NUMBER'
           ,p_value_1                 =>  g_ExtractLine
           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
           ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
  END IF;
END IF;

--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace
              (p_msg      => 'Entered Amount = '||g_rec_lines.array_entered_amount(g_LineNumber)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'Ledger Amount = '||g_rec_lines.array_ledger_amount(g_LineNumber)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
END IF;
--
IF g_rec_lines.array_switch_side_flag(g_LineNumber) = C_SWITCH AND
  (   g_rec_lines.array_ledger_amount(g_LineNumber) < 0  OR
    ( g_rec_lines.array_ledger_amount(g_LineNumber) = 0 AND
      g_rec_lines.array_entered_amount(g_LineNumber) < 0 )
  )
THEN

 --switch side

   CASE g_rec_lines.array_natural_side_code(g_LineNumber)

      WHEN C_DEBIT THEN
         -- store amount in credit side
          g_rec_lines.array_accounted_cr(g_LineNumber) := ABS(g_rec_lines.array_ledger_amount(g_LineNumber))  ;
          g_rec_lines.array_accounted_dr(g_LineNumber) := NULL;
          --
          g_rec_lines.array_entered_cr(g_LineNumber)   := ABS(g_rec_lines.array_entered_amount(g_LineNumber)) ;
          g_rec_lines.array_entered_dr(g_LineNumber)   := NULL;

      WHEN C_CREDIT THEN
         -- store amount in debit side
          g_rec_lines.array_accounted_dr(g_LineNumber) := ABS(g_rec_lines.array_ledger_amount(g_LineNumber)) ;
          g_rec_lines.array_accounted_cr(g_LineNumber) := NULL;
          --
          g_rec_lines.array_entered_dr(g_LineNumber)   := ABS(g_rec_lines.array_entered_amount(g_LineNumber)) ;
          g_rec_lines.array_entered_cr(g_LineNumber)   := NULL;

      ELSE null;

  END CASE;

     --7704240: Bflow Applied Amount to be ABSOLUTE, when SWITCH SIDE, so that all Entered, Accounted and BflowApplied Amounts are POSITIVE
     g_rec_lines.array_bflow_applied_to_amt(g_LineNumber) := ABS(g_rec_lines.array_bflow_applied_to_amt(g_LineNumber)) ;

ELSE

 -- no switch

   CASE g_rec_lines.array_natural_side_code(g_LineNumber)

      WHEN C_DEBIT THEN
         -- store amount in debit side
          g_rec_lines.array_accounted_dr(g_LineNumber) := g_rec_lines.array_ledger_amount(g_LineNumber) ;
          g_rec_lines.array_accounted_cr(g_LineNumber) := NULL;
          --
          g_rec_lines.array_entered_dr(g_LineNumber)   := g_rec_lines.array_entered_amount(g_LineNumber) ;
          g_rec_lines.array_entered_cr(g_LineNumber)   := NULL;

      WHEN C_CREDIT THEN
         -- store amount in credit side
          g_rec_lines.array_accounted_cr(g_LineNumber) := g_rec_lines.array_ledger_amount(g_LineNumber)  ;
          g_rec_lines.array_accounted_dr(g_LineNumber) := NULL;
          --
          g_rec_lines.array_entered_cr(g_LineNumber)   := g_rec_lines.array_entered_amount(g_LineNumber) ;
          g_rec_lines.array_entered_dr(g_LineNumber)   := NULL;

      ELSE null;

  END CASE;
END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

           trace
              (p_msg      => 'Entered_DR = '||g_rec_lines.array_entered_dr(g_LineNumber)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'Entered_CR = '||g_rec_lines.array_entered_cr(g_LineNumber)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'Accounted_DR = '||g_rec_lines.array_accounted_dr(g_LineNumber)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'Accounted_CR = '||g_rec_lines.array_accounted_cr(g_LineNumber)
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetDebitCreditAmounts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetDebitCreditAmounts');
  --
END SetDebitCreditAmounts;
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
| PUBLIC Procedure                                                      |
|        InitLines  : Reset temporary journal line pl/sql structures    |
|                                                                       |
+======================================================================*/
PROCEDURE InitLines
--
IS
--
l_null_lines          t_rec_lines;
l_null_rev_line       t_rec_reverse_line;
l_null_trans_accounts t_rec_transaction_accounts;
l_log_module          VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InitLines';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of InitLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

g_rec_lines                    := l_null_lines;
g_transaction_accounts         := l_null_trans_accounts;
g_reverse_lines                := l_null_rev_line;
g_LineNumber                   := 0;
g_ExtractLine                  := 0;
g_ActualLineNum                := 0;
g_BudgetLineNum                := 0;
g_EncumbLineNum                := 0;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of InitLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.InitLines');
  --
END InitLines;
--
--
/*======================================================================+
|                                                                       |
| PUBLIC Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetExtractLine(p_extract_line IN NUMBER)
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetExtractLine';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetExtractLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_EVENT >= g_log_level) THEN

       trace
         (p_msg      => 'Extract line number = '||p_extract_line
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);

END IF;

g_ExtractLine                  := p_extract_line;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of SetExtractLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  g_ExtractLine                := null;
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetExtractLine');
  --
END SetExtractLine;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
PROCEDURE SetNullLine
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetNullLine';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetNullLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
FOR Idx IN 1 .. C_BULK_LIMIT LOOP
--
-- init new line
--
 g_null_lines.array_ae_header_id(Idx)          := NULL;
-- g_null_lines.array_line_num(Idx)            := NULL;
 g_null_lines.array_accounting_class(Idx)      := NULL;
 g_null_lines.array_rounding_class(Idx)        := NULL;
 g_null_lines.array_doc_rounding_level(Idx)    := NULL;
 g_null_lines.array_gain_or_loss_ref(Idx)      := NULL;
 g_null_lines.array_event_class_code(Idx)      := NULL;
 g_null_lines.array_event_type_code(Idx)       := NULL;
 g_null_lines.array_line_defn_owner_code(Idx)  := NULL;
 g_null_lines.array_line_defn_code(Idx)        := NULL;
 g_null_lines.array_accounting_line_code(Idx)  := NULL;
 g_null_lines.array_accounting_line_type(Idx)  := NULL;
 g_null_lines.array_calculate_acctd_flag(Idx)  := NULL;
 g_null_lines.array_calculate_g_l_flag(Idx)    := NULL;
 g_null_lines.array_gain_or_loss_flag(Idx)    := NULL;
--
-- line flexfield accounts
--
 g_null_lines.array_ccid_flag(Idx)  := C_INVALID;
 g_null_lines.array_ccid(Idx)       := NULL;
--
 g_null_lines.array_accounting_coa_id(Idx)   := NULL;
 g_null_lines.array_transaction_coa_id(Idx)  := NULL;
 g_null_lines.array_sl_coa_mapping_name(Idx) := NULL;
--
 g_null_lines.array_segment1(Idx)   := NULL;
 g_null_lines.array_segment2(Idx)   := NULL;
 g_null_lines.array_segment3(Idx)   := NULL;
 g_null_lines.array_segment4(Idx)   := NULL;
 g_null_lines.array_segment5(Idx)   := NULL;
 g_null_lines.array_segment6(Idx)   := NULL;
 g_null_lines.array_segment7(Idx)   := NULL;
 g_null_lines.array_segment8(Idx)   := NULL;
 g_null_lines.array_segment9(Idx)   := NULL;
 g_null_lines.array_segment10(Idx)  := NULL;
 g_null_lines.array_segment11(Idx)  := NULL;
 g_null_lines.array_segment12(Idx)  := NULL;
 g_null_lines.array_segment13(Idx)  := NULL;
 g_null_lines.array_segment14(Idx)  := NULL;
 g_null_lines.array_segment15(Idx)  := NULL;
 g_null_lines.array_segment16(Idx)  := NULL;
 g_null_lines.array_segment17(Idx)  := NULL;
 g_null_lines.array_segment18(Idx)  := NULL;
 g_null_lines.array_segment19(Idx)  := NULL;
 g_null_lines.array_segment20(Idx)  := NULL;
 g_null_lines.array_segment21(Idx)  := NULL;
 g_null_lines.array_segment22(Idx)  := NULL;
 g_null_lines.array_segment23(Idx)  := NULL;
 g_null_lines.array_segment24(Idx)  := NULL;
 g_null_lines.array_segment25(Idx)  := NULL;
 g_null_lines.array_segment26(Idx)  := NULL;
 g_null_lines.array_segment27(Idx)  := NULL;
 g_null_lines.array_segment28(Idx)  := NULL;
 g_null_lines.array_segment29(Idx)  := NULL;
 g_null_lines.array_segment30(Idx)  := NULL;
--
 g_null_lines.alt_array_ccid_flag(Idx)   := C_INVALID;
 g_null_lines.alt_array_ccid(Idx)       := NULL;
 g_null_lines.alt_array_segment1(Idx)   := NULL;
 g_null_lines.alt_array_segment2(Idx)   := NULL;
 g_null_lines.alt_array_segment3(Idx)   := NULL;
 g_null_lines.alt_array_segment4(Idx)   := NULL;
 g_null_lines.alt_array_segment5(Idx)   := NULL;
 g_null_lines.alt_array_segment6(Idx)   := NULL;
 g_null_lines.alt_array_segment7(Idx)   := NULL;
 g_null_lines.alt_array_segment8(Idx)   := NULL;
 g_null_lines.alt_array_segment9(Idx)   := NULL;
 g_null_lines.alt_array_segment10(Idx)  := NULL;
 g_null_lines.alt_array_segment11(Idx)  := NULL;
 g_null_lines.alt_array_segment12(Idx)  := NULL;
 g_null_lines.alt_array_segment13(Idx)  := NULL;
 g_null_lines.alt_array_segment14(Idx)  := NULL;
 g_null_lines.alt_array_segment15(Idx)  := NULL;
 g_null_lines.alt_array_segment16(Idx)  := NULL;
 g_null_lines.alt_array_segment17(Idx)  := NULL;
 g_null_lines.alt_array_segment18(Idx)  := NULL;
 g_null_lines.alt_array_segment19(Idx)  := NULL;
 g_null_lines.alt_array_segment20(Idx)  := NULL;
 g_null_lines.alt_array_segment21(Idx)  := NULL;
 g_null_lines.alt_array_segment22(Idx)  := NULL;
 g_null_lines.alt_array_segment23(Idx)  := NULL;
 g_null_lines.alt_array_segment24(Idx)  := NULL;
 g_null_lines.alt_array_segment25(Idx)  := NULL;
 g_null_lines.alt_array_segment26(Idx)  := NULL;
 g_null_lines.alt_array_segment27(Idx)  := NULL;
 g_null_lines.alt_array_segment28(Idx)  := NULL;
 g_null_lines.alt_array_segment29(Idx)  := NULL;
 g_null_lines.alt_array_segment30(Idx)  := NULL;
--
-- Option lines
--
 g_null_lines.array_gl_transfer_mode(Idx)      := NULL;
 g_null_lines.array_natural_side_code(Idx)     := NULL;
 g_null_lines.array_acct_entry_type_code(Idx)  := NULL;
 g_null_lines.array_switch_side_flag(Idx)      := NULL;
 g_null_lines.array_merge_duplicate_code(Idx)  := NULL;
 --
 -- line amounts
 --
 g_null_lines.array_entered_amount(Idx)        := NULL;
 g_null_lines.array_ledger_amount(Idx)         := NULL;
 g_null_lines.array_entered_dr(Idx)            := NULL;
 g_null_lines.array_entered_cr(Idx)            := NULL;
 g_null_lines.array_accounted_dr(Idx)          := NULL;
 g_null_lines.array_accounted_cr(Idx)          := NULL;
 g_null_lines.array_currency_code(Idx)         := NULL;
 g_null_lines.array_currency_mau(Idx)          := NULL;
 g_null_lines.array_curr_conversion_date(Idx)  := NULL;
 g_null_lines.array_curr_conversion_rate(Idx)  := NULL;
 g_null_lines.array_curr_conversion_type(Idx)  := NULL;
 g_null_lines.array_description(Idx)           := NULL;
 --
 -- line descriptions
 --
 g_null_lines.array_party_id(Idx)              := NULL;
 g_null_lines.array_party_site_id(Idx)         := NULL;
 g_null_lines.array_party_type_code(Idx)       := NULL;
 --
 g_null_lines.array_statistical_amount(Idx)    := NULL;
 g_null_lines.array_ussgl_transaction(Idx)     := NULL;
--
 g_null_lines.array_jgzz_recon_ref(Idx)        := NULL;
--
-- distribution links
--
 g_null_lines.array_distribution_id_char_1(Idx)  := NULL;
 g_null_lines.array_distribution_id_char_2(Idx)  := NULL;
 g_null_lines.array_distribution_id_char_3(Idx)  := NULL;
 g_null_lines.array_distribution_id_char_4(Idx)  := NULL;
 g_null_lines.array_distribution_id_char_5(Idx)  := NULL;
 g_null_lines.array_distribution_id_num_1(Idx)   := NULL;
 g_null_lines.array_distribution_id_num_2(Idx)   := NULL;
 g_null_lines.array_distribution_id_num_3(Idx)   := NULL;
 g_null_lines.array_distribution_id_num_4(Idx)   := NULL;
 g_null_lines.array_distribution_id_num_5(Idx)   := NULL;
 g_null_lines.array_sys_distribution_type(Idx)   := NULL;
--
-- reverse distribution links
--
 g_null_lines.array_rev_dist_id_char_1(Idx)  := NULL;
 g_null_lines.array_rev_dist_id_char_2(Idx)  := NULL;
 g_null_lines.array_rev_dist_id_char_3(Idx)  := NULL;
 g_null_lines.array_rev_dist_id_char_4(Idx)  := NULL;
 g_null_lines.array_rev_dist_id_char_5(Idx)  := NULL;
 g_null_lines.array_rev_dist_id_num_1(Idx)   := NULL;
 g_null_lines.array_rev_dist_id_num_2(Idx)   := NULL;
 g_null_lines.array_rev_dist_id_num_3(Idx)   := NULL;
 g_null_lines.array_rev_dist_id_num_4(Idx)   := NULL;
 g_null_lines.array_rev_dist_id_num_5(Idx)   := NULL;
 g_null_lines.array_rev_dist_type(Idx)       := NULL;

-- 4262811 MPA
 g_null_lines.array_header_num(Idx)          := NULL;
 g_null_lines.array_mpa_acc_entry_flag(Idx)  := 'N';
 g_null_lines.array_mpa_option(Idx)          := NULL;
 g_null_lines.array_mpa_start_date(Idx)      := NULL;
 g_null_lines.array_mpa_end_date(Idx)        := NULL;
--
-- deferred info - replace by MPA
--
-- g_null_lines.array_deferred_indicator(Idx)    := NULL;
-- g_null_lines.array_deferred_start_date(Idx)   := NULL;
-- g_null_lines.array_deferred_end_date(Idx)     := NULL;
-- g_null_lines.array_deferred_no_period(Idx)    := NULL;
-- g_null_lines.array_deferred_period_type(Idx)  := NULL;
--
-- reversal info
--
 g_null_lines.array_acc_reversal_option(Idx)   := NULL;
--
-- tax info
--
 g_null_lines.array_tax_line_ref(Idx)           := NULL;
 g_null_lines.array_tax_summary_line_ref(Idx)   := NULL;
 g_null_lines.array_tax_rec_nrec_dist_ref(Idx)  := NULL;
--
-- Analytical Criteria
--
 g_null_lines.array_anc_balance_flag(Idx)      := NULL;
 g_null_lines.array_anc_id_1(Idx)              := NULL;
 g_null_lines.array_anc_id_2(Idx)              := NULL;
 g_null_lines.array_anc_id_3(Idx)              := NULL;
 g_null_lines.array_anc_id_4(Idx)              := NULL;
 g_null_lines.array_anc_id_5(Idx)              := NULL;
 g_null_lines.array_anc_id_6(Idx)              := NULL;
 g_null_lines.array_anc_id_7(Idx)              := NULL;
 g_null_lines.array_anc_id_8(Idx)              := NULL;
 g_null_lines.array_anc_id_9(Idx)              := NULL;
 g_null_lines.array_anc_id_10(Idx)             := NULL;
 g_null_lines.array_anc_id_11(Idx)             := NULL;
 g_null_lines.array_anc_id_12(Idx)             := NULL;
 g_null_lines.array_anc_id_13(Idx)             := NULL;
 g_null_lines.array_anc_id_14(Idx)             := NULL;
 g_null_lines.array_anc_id_15(Idx)             := NULL;
 g_null_lines.array_anc_id_16(Idx)             := NULL;
 g_null_lines.array_anc_id_17(Idx)             := NULL;
 g_null_lines.array_anc_id_18(Idx)             := NULL;
 g_null_lines.array_anc_id_19(Idx)             := NULL;
 g_null_lines.array_anc_id_20(Idx)             := NULL;
 g_null_lines.array_anc_id_21(Idx)             := NULL;
 g_null_lines.array_anc_id_22(Idx)             := NULL;
 g_null_lines.array_anc_id_23(Idx)             := NULL;
 g_null_lines.array_anc_id_24(Idx)             := NULL;
 g_null_lines.array_anc_id_25(Idx)             := NULL;
 g_null_lines.array_anc_id_26(Idx)             := NULL;
 g_null_lines.array_anc_id_27(Idx)             := NULL;
 g_null_lines.array_anc_id_28(Idx)             := NULL;
 g_null_lines.array_anc_id_29(Idx)             := NULL;
 g_null_lines.array_anc_id_30(Idx)             := NULL;
 g_null_lines.array_anc_id_31(Idx)             := NULL;
 g_null_lines.array_anc_id_32(Idx)             := NULL;
 g_null_lines.array_anc_id_33(Idx)             := NULL;
 g_null_lines.array_anc_id_34(Idx)             := NULL;
 g_null_lines.array_anc_id_35(Idx)             := NULL;
 g_null_lines.array_anc_id_36(Idx)             := NULL;
 g_null_lines.array_anc_id_37(Idx)             := NULL;
 g_null_lines.array_anc_id_38(Idx)             := NULL;
 g_null_lines.array_anc_id_39(Idx)             := NULL;
 g_null_lines.array_anc_id_40(Idx)             := NULL;
 g_null_lines.array_anc_id_41(Idx)             := NULL;
 g_null_lines.array_anc_id_42(Idx)             := NULL;
 g_null_lines.array_anc_id_43(Idx)             := NULL;
 g_null_lines.array_anc_id_44(Idx)             := NULL;
 g_null_lines.array_anc_id_45(Idx)             := NULL;
 g_null_lines.array_anc_id_46(Idx)             := NULL;
 g_null_lines.array_anc_id_47(Idx)             := NULL;
 g_null_lines.array_anc_id_48(Idx)             := NULL;
 g_null_lines.array_anc_id_49(Idx)             := NULL;
 g_null_lines.array_anc_id_50(Idx)             := NULL;
 g_null_lines.array_anc_id_51(Idx)             := NULL;
 g_null_lines.array_anc_id_52(Idx)             := NULL;
 g_null_lines.array_anc_id_53(Idx)             := NULL;
 g_null_lines.array_anc_id_54(Idx)             := NULL;
 g_null_lines.array_anc_id_55(Idx)             := NULL;
 g_null_lines.array_anc_id_56(Idx)             := NULL;
 g_null_lines.array_anc_id_57(Idx)             := NULL;
 g_null_lines.array_anc_id_58(Idx)             := NULL;
 g_null_lines.array_anc_id_59(Idx)             := NULL;
 g_null_lines.array_anc_id_60(Idx)             := NULL;
 g_null_lines.array_anc_id_61(Idx)             := NULL;
 g_null_lines.array_anc_id_62(Idx)             := NULL;
 g_null_lines.array_anc_id_63(Idx)             := NULL;
 g_null_lines.array_anc_id_64(Idx)             := NULL;
 g_null_lines.array_anc_id_65(Idx)             := NULL;
 g_null_lines.array_anc_id_66(Idx)             := NULL;
 g_null_lines.array_anc_id_67(Idx)             := NULL;
 g_null_lines.array_anc_id_68(Idx)             := NULL;
 g_null_lines.array_anc_id_69(Idx)             := NULL;
 g_null_lines.array_anc_id_70(Idx)             := NULL;
 g_null_lines.array_anc_id_71(Idx)             := NULL;
 g_null_lines.array_anc_id_72(Idx)             := NULL;
 g_null_lines.array_anc_id_73(Idx)             := NULL;
 g_null_lines.array_anc_id_74(Idx)             := NULL;
 g_null_lines.array_anc_id_75(Idx)             := NULL;
 g_null_lines.array_anc_id_76(Idx)             := NULL;
 g_null_lines.array_anc_id_77(Idx)             := NULL;
 g_null_lines.array_anc_id_78(Idx)             := NULL;
 g_null_lines.array_anc_id_79(Idx)             := NULL;
 g_null_lines.array_anc_id_80(Idx)             := NULL;
 g_null_lines.array_anc_id_81(Idx)             := NULL;
 g_null_lines.array_anc_id_82(Idx)             := NULL;
 g_null_lines.array_anc_id_83(Idx)             := NULL;
 g_null_lines.array_anc_id_84(Idx)             := NULL;
 g_null_lines.array_anc_id_85(Idx)             := NULL;
 g_null_lines.array_anc_id_86(Idx)             := NULL;
 g_null_lines.array_anc_id_87(Idx)             := NULL;
 g_null_lines.array_anc_id_88(Idx)             := NULL;
 g_null_lines.array_anc_id_89(Idx)             := NULL;
 g_null_lines.array_anc_id_90(Idx)             := NULL;
 g_null_lines.array_anc_id_91(Idx)             := NULL;
 g_null_lines.array_anc_id_92(Idx)             := NULL;
 g_null_lines.array_anc_id_93(Idx)             := NULL;
 g_null_lines.array_anc_id_94(Idx)             := NULL;
 g_null_lines.array_anc_id_95(Idx)             := NULL;
 g_null_lines.array_anc_id_96(Idx)             := NULL;
 g_null_lines.array_anc_id_97(Idx)             := NULL;
 g_null_lines.array_anc_id_98(Idx)             := NULL;
 g_null_lines.array_anc_id_99(Idx)             := NULL;
 g_null_lines.array_anc_id_100(Idx)            := NULL;
--
 g_null_lines.array_event_number(Idx)          := NULL;
 g_null_lines.array_entity_id(Idx)             := NULL;
 g_null_lines.array_reversal_code(Idx)         := NULL;
--------------------------------------------------------------------------
-- 4262811 - Initialised to prevent element at index[x] does not exist error
 g_null_lines.array_balance_type_code(Idx)     := NULL;
 g_null_lines.array_ledger_id(Idx)             := NULL;
 g_null_lines.array_override_acctd_amt_flag(Idx) := NULL;
--------------------------------------------------------------------------
 g_null_lines.array_encumbrance_type_id(Idx)   := NULL;
--
 --------------------------------------
 -- 4219869
 -- Business Flow Applied To Attributes
 --------------------------------------
 g_null_lines.array_business_method_code(Idx)   := NULL;
 g_null_lines.array_business_class_code(Idx)    := NULL;
 g_null_lines.array_inherit_desc_flag(Idx)      := 'N';
 g_null_lines.array_bflow_application_id(Idx)   := NULL;

 g_null_lines.array_bflow_entity_code(Idx)      := NULL;
 g_null_lines.array_bflow_source_id_num_1(Idx)  := NULL;
 g_null_lines.array_bflow_source_id_num_2(Idx)  := NULL;
 g_null_lines.array_bflow_source_id_num_3(Idx)  := NULL;
 g_null_lines.array_bflow_source_id_num_4(Idx)  := NULL;
 g_null_lines.array_bflow_source_id_char_1(Idx) := NULL;
 g_null_lines.array_bflow_source_id_char_2(Idx) := NULL;
 g_null_lines.array_bflow_source_id_char_3(Idx) := NULL;
 g_null_lines.array_bflow_source_id_char_4(Idx) := NULL;

 g_null_lines.array_bflow_distribution_type(Idx):= NULL;
 g_null_lines.array_bflow_dist_id_num_1(Idx)    := NULL;
 g_null_lines.array_bflow_dist_id_num_2(Idx)    := NULL;
 g_null_lines.array_bflow_dist_id_num_3(Idx)    := NULL;
 g_null_lines.array_bflow_dist_id_num_4(Idx)    := NULL;
 g_null_lines.array_bflow_dist_id_num_5(Idx)    := NULL;
 g_null_lines.array_bflow_dist_id_char_1(Idx)   := NULL;
 g_null_lines.array_bflow_dist_id_char_2(Idx)   := NULL;
 g_null_lines.array_bflow_dist_id_char_3(Idx)   := NULL;
 g_null_lines.array_bflow_dist_id_char_4(Idx)   := NULL;
 g_null_lines.array_bflow_dist_id_char_5(Idx)   := NULL;

 g_null_lines.array_bflow_applied_to_amt(Idx)   := NULL;  -- 5132302
--
--
-- Upgrade Attributes
--


g_null_lines.array_actual_upg_option(Idx)         := NULL;
g_null_lines.array_actual_upg_dr_ccid(Idx)        := NULL;
g_null_lines.array_actual_upg_cr_ccid(Idx)        := NULL;
g_null_lines.array_actual_upg_dr_ent_amt(Idx)     := NULL;
g_null_lines.array_actual_upg_cr_ent_amt(Idx)     := NULL;
g_null_lines.array_actual_upg_dr_ent_curr(Idx)    := NULL;
g_null_lines.array_actual_upg_cr_ent_curr(Idx)    := NULL;
g_null_lines.array_actual_upg_dr_ledger_amt(Idx)  := NULL;
g_null_lines.array_actual_upg_cr_ledger_amt(Idx)  := NULL;
g_null_lines.array_actual_upg_dr_acct_class(Idx)  := NULL;
g_null_lines.array_actual_upg_cr_acct_class(Idx)  := NULL;
g_null_lines.array_actual_upg_dr_xrate(Idx)       := NULL;
g_null_lines.array_actual_upg_dr_xrate_type(Idx)  := NULL;
g_null_lines.array_actual_upg_dr_xdate(Idx)       := NULL;
g_null_lines.array_actual_upg_cr_xrate(Idx)       := NULL;
g_null_lines.array_actual_upg_cr_xrate_type(Idx)  := NULL;
g_null_lines.array_actual_upg_cr_xdate(Idx)       := NULL;
g_null_lines.array_enc_upg_option(Idx)            := NULL;
g_null_lines.array_enc_upg_dr_ccid(Idx)           := NULL;
g_null_lines.array_enc_upg_cr_ccid(Idx)           := NULL;
g_null_lines.array_upg_dr_enc_type_id(Idx)        := NULL;
g_null_lines.array_upg_cr_enc_type_id(Idx)        := NULL;
g_null_lines.array_enc_upg_dr_ent_amt(Idx)        := NULL;
g_null_lines.array_enc_upg_cr_ent_amt(Idx)        := NULL;
g_null_lines.array_enc_upg_dr_ent_curr(Idx)       := NULL;
g_null_lines.array_enc_upg_cr_ent_curr(Idx)       := NULL;
g_null_lines.array_enc_upg_dr_ledger_amt(Idx)     := NULL;
g_null_lines.array_enc_upg_cr_ledger_amt(Idx)     := NULL;
g_null_lines.array_enc_upg_dr_acct_class(Idx)     := NULL;
g_null_lines.array_enc_upg_cr_acct_class(Idx)     := NULL;
--  5845547
g_null_lines.array_upg_party_type_code(Idx)       := NULL;
g_null_lines.array_upg_party_id(Idx)              := NULL;
g_null_lines.array_upg_party_site_id(Idx)         := NULL;
--
--
-- Allocation Attributes
--
g_null_lines.array_alloct_application_id(Idx)   := NULL;

g_null_lines.array_alloct_entity_code(Idx)      := NULL;
g_null_lines.array_alloct_source_id_num_1(Idx)  := NULL;
g_null_lines.array_alloct_source_id_num_2(Idx)  := NULL;
g_null_lines.array_alloct_source_id_num_3(Idx)  := NULL;
g_null_lines.array_alloct_source_id_num_4(Idx)  := NULL;
g_null_lines.array_alloct_source_id_char_1(Idx) := NULL;
g_null_lines.array_alloct_source_id_char_2(Idx) := NULL;
g_null_lines.array_alloct_source_id_char_3(Idx) := NULL;
g_null_lines.array_alloct_source_id_char_4(Idx) := NULL;

g_null_lines.array_alloct_distribution_type(Idx):= NULL;
g_null_lines.array_alloct_dist_id_num_1(Idx)    := NULL;
g_null_lines.array_alloct_dist_id_num_2(Idx)    := NULL;
g_null_lines.array_alloct_dist_id_num_3(Idx)    := NULL;
g_null_lines.array_alloct_dist_id_num_4(Idx)    := NULL;
g_null_lines.array_alloct_dist_id_num_5(Idx)    := NULL;
g_null_lines.array_alloct_dist_id_char_1(Idx)   := NULL;
g_null_lines.array_alloct_dist_id_char_2(Idx)   := NULL;
g_null_lines.array_alloct_dist_id_char_3(Idx)   := NULL;
g_null_lines.array_alloct_dist_id_char_4(Idx)   := NULL;
g_null_lines.array_alloct_dist_id_char_5(Idx)   := NULL;

--
-- bug 4955764
--
g_null_lines.array_gl_date(Idx)                 := NULL;


--
END LOOP;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetNullLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetNullLine');
  --
END SetNullLine;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetNewLine
IS
l_log_module         VARCHAR2(240);
l_result                   BOOLEAN;
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetNewLine';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetNewLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF NVL(g_LineNumber,0) = 0 THEN
   g_rec_lines := g_null_lines;

ELSIF g_LineNumber = C_BULK_LIMIT THEN
   --
   -- insert headers into xla_ae_lines_gt table
   --
   l_result := xla_ae_lines_pkg.InsertLines;
   g_LineNumber := 0;
   g_rec_lines  := g_null_lines;

END IF;

g_LineNumber       := NVL(g_LineNumber ,0) + 1;
g_override_acctd_amt_flag :='N';
g_temp_line_num    := NVL(g_temp_line_num ,0) + 1;

--
-- following sets the temp line number
--
g_rec_lines.array_line_num(g_LineNumber) := g_temp_line_num;
--
-- following sets the extract line number
--
g_rec_lines.array_extract_line_num(g_LineNumber) := g_ExtractLine;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetNewLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetNewLine');
  --
END SetNewLine;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetAcctLineType(
  p_component_type                   IN VARCHAR2
, p_event_type_code                  IN VARCHAR2
, p_line_definition_owner_code       IN VARCHAR2
, p_line_definition_code             IN VARCHAR2
, p_accounting_line_code             IN VARCHAR2
, p_accounting_line_type_code        IN VARCHAR2
, p_accounting_line_appl_id          IN INTEGER
, p_amb_context_code                 IN VARCHAR2
, p_entity_code                      IN VARCHAR2
, p_event_class_code                 IN VARCHAR2
)
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetAcctLineType';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetAcctLineType'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_accounting_line_type_code = '||p_accounting_line_type_code||
                        '- p_accounting_line_code= '||p_accounting_line_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'p_component_type = '||p_component_type||
                        ' - p_accounting_line_appl_id = '||p_accounting_line_appl_id||
                        ' - p_amb_context_code = '||p_amb_context_code||
                        ' - p_entity_code = '||p_entity_code||
                        ' - p_event_class_code = '||p_event_class_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

 g_rec_lines.array_event_class_code(g_LineNumber)      := p_event_class_code;
 g_rec_lines.array_event_type_code(g_LineNumber)       := p_event_type_code;
 g_rec_lines.array_line_defn_owner_code(g_LineNumber)  := p_line_definition_owner_code;
 g_rec_lines.array_line_defn_code(g_LineNumber)        := p_line_definition_code;
 g_rec_lines.array_accounting_line_code(g_LineNumber)  := p_accounting_line_code;
 g_rec_lines.array_accounting_line_type(g_LineNumber)  := p_accounting_line_type_code;

--
-- cache accounting line type information
--
 g_accounting_line.component_type              := p_component_type;
 g_accounting_line.accounting_line_code        := p_accounting_line_code;
 g_accounting_line.accounting_line_type_code   := p_accounting_line_type_code;
 g_accounting_line.accounting_line_appl_id     := p_accounting_line_appl_id;
 g_accounting_line.amb_context_code            := p_amb_context_code;
 g_accounting_line.entity_code                 := p_entity_code;
 g_accounting_line.event_class_code            := p_event_class_code;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetAcctLineType'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetAcctLineType');
  --
END SetAcctLineType;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
Function SetAcctLineOption(
  p_natural_side_code          IN VARCHAR2
, p_gain_or_loss_flag          IN VARCHAR2
, p_gl_transfer_mode_code      IN VARCHAR2
, p_acct_entry_type_code       IN VARCHAR2
, p_switch_side_flag           IN VARCHAR2
, p_merge_duplicate_code       IN VARCHAR2
)
RETURN NUMBER
IS
l_ae_header_id        NUMBER;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetAcctLineOption';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetAcctLineOption'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_natural_side_code = '||p_natural_side_code||
                        ' - p_gl_transfer_mode_code = '||p_gl_transfer_mode_code||
                        ' - p_acct_entry_type_code = '||p_acct_entry_type_code||
                        ' - p_switch_side_flag = '||p_switch_side_flag||
                        ' - p_merge_duplicate_code = '||p_merge_duplicate_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
--
-- I THINK WE DONT' NEED THIS IN BULK APPROACH
--
--  SetHdrLineNum(p_balance_type_code => p_acct_entry_type_code);
--
  --
  g_rec_lines.array_gl_transfer_mode(g_LineNumber)      := p_gl_transfer_mode_code ;
  g_rec_lines.array_natural_side_code(g_LineNumber)     := p_natural_side_code     ;
  g_rec_lines.array_gain_or_loss_flag(g_LineNumber)     := p_gain_or_loss_flag     ;
  g_rec_lines.array_acct_entry_type_code(g_LineNumber)  := p_acct_entry_type_code  ;
  g_rec_lines.array_switch_side_flag(g_LineNumber)      := p_switch_side_flag      ;
  g_rec_lines.array_merge_duplicate_code(g_LineNumber)  := p_merge_duplicate_code  ;
--
--
    l_ae_header_id := g_rec_lines.array_ae_header_id(g_LineNumber);
    --
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_ae_header_id)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of SetAcctLineOption'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_ae_header_id;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
 RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetAcctLineOption');
  --
END SetAcctLineOption;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetLineDescription(p_description      IN VARCHAR2
                            ,p_ae_header_id     IN NUMBER)
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetLineDescription';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetLineDescription'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
  g_rec_lines.array_description(g_LineNumber)  := SUBSTR(p_description,1,1996);
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of SetLineDescription'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetLineDescription');
  --
END SetLineDescription;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|    set_ccid                                                           |
|                                                                       |
| Caches the transaction and accounting CCIDs in the JE temporary lines |
|                                                                       |
+======================================================================*/
--replace SetCcid
PROCEDURE  set_ccid(
  p_code_combination_id      IN NUMBER
, p_value_type_code          IN VARCHAR2
, p_transaction_coa_id       IN NUMBER
, p_accounting_coa_id        IN NUMBER
, p_adr_code                 IN VARCHAR2
, p_adr_type_code            IN VARCHAR2
, p_component_type           IN VARCHAR2
, p_component_code           IN VARCHAR2
, p_component_type_code      IN VARCHAR2
, p_component_appl_id        IN INTEGER
, p_amb_context_code         IN VARCHAR2
, p_side                     IN VARCHAR2
)
IS
l_Idx                BINARY_INTEGER;
null_combination_id  EXCEPTION;
no_sl_coa_mapping    EXCEPTION;
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_ccid';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of set_ccid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

 trace
         (p_msg      => ' p_side = '||p_side ||
                        ', p_code_combination_id = '||p_code_combination_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
         (p_msg      => ' p_value_type_code   = '||p_value_type_code ||
                        ', p_transaction_coa_id = '|| p_transaction_coa_id||
                        ', p_accounting_coa_id = '||p_accounting_coa_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

       trace
         (p_msg      => ' p_adr_code   = '||p_adr_code||
                        ', p_adr_type_code = '|| p_adr_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => ' p_component_type = '||p_component_type||
                        ', p_component_code = '||p_component_code||
                        ', p_component_type_code = '||p_component_type_code||
                        ', p_component_appl_id = '||p_component_appl_id||
                        ', p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

IF p_code_combination_id IS NULL OR p_code_combination_id = -1 THEN  -- 5163338
  RAISE null_combination_id;
END IF;

IF p_value_type_code ='S' AND
   ( XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id <>
    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.source_coa_id ) THEN
-- transaction ccid

   IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id IS NULL THEN
     RAISE no_sl_coa_mapping ;
   END IF;

   l_Idx := NVL(g_transaction_accounts.array_ae_header_id.COUNT,0) + 1;
   g_transaction_accounts.array_line_num(l_Idx)        := l_Idx ;
   g_transaction_accounts.array_ae_header_id(l_Idx)    := g_rec_lines.array_ae_header_id(g_LineNumber);
   g_transaction_accounts.array_temp_line_num(l_Idx)   := g_rec_lines.array_line_num(g_LineNumber);
   g_transaction_accounts.array_code_combination_id (l_Idx)   := p_code_combination_id;
   g_transaction_accounts.array_segment(l_Idx)                := NULL;
   g_transaction_accounts.array_from_segment_code(l_Idx)      := NULL;
   g_transaction_accounts.array_to_segment_code(l_Idx)        := NULL;
   g_transaction_accounts.array_processing_status_code(l_Idx) := C_MAP_CCID;
   g_transaction_accounts.array_side_code(l_Idx)              := p_side;


  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
         (p_msg      => ' Transaction ccid  = '||p_code_combination_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

ELSE
-- accounting ccid

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
         (p_msg      => ' Accounting ccid   = '||p_code_combination_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  CASE p_side

   WHEN 'ALL' THEN
      g_rec_lines.array_ccid(g_LineNumber)     := p_code_combination_id ;
      g_rec_lines.alt_array_ccid(g_LineNumber) := p_code_combination_id ;

      CASE nvl(g_rec_lines.array_ccid_flag(g_LineNumber),C_INVALID)
        WHEN C_INVALID    THEN g_rec_lines.array_ccid_flag(g_LineNumber) := C_CREATED;
        WHEN C_PROCESSING THEN g_rec_lines.array_ccid_flag(g_LineNumber) := C_NOT_PROCESSED;
        ELSE null;
      END CASE;

      CASE nvl(g_rec_lines.alt_array_ccid_flag(g_LineNumber),C_INVALID)
        WHEN C_INVALID    THEN g_rec_lines.alt_array_ccid_flag(g_LineNumber) := C_CREATED;
        WHEN C_PROCESSING THEN g_rec_lines.alt_array_ccid_flag(g_LineNumber) := C_NOT_PROCESSED;
        ELSE null;
      END CASE;

   WHEN 'NA'     THEN
      g_rec_lines.array_ccid(g_LineNumber) := p_code_combination_id ;

      CASE nvl(g_rec_lines.array_ccid_flag(g_LineNumber),C_INVALID)
        WHEN C_INVALID    THEN g_rec_lines.array_ccid_flag(g_LineNumber) := C_CREATED;
        WHEN C_PROCESSING THEN g_rec_lines.array_ccid_flag(g_LineNumber) := C_NOT_PROCESSED;
        ELSE null;
      END CASE;

   WHEN 'CREDIT' THEN
      g_rec_lines.array_ccid(g_LineNumber) := p_code_combination_id ;

      CASE nvl(g_rec_lines.array_ccid_flag(g_LineNumber),C_INVALID)
        WHEN C_INVALID    THEN g_rec_lines.array_ccid_flag(g_LineNumber) := C_CREATED;
        WHEN C_PROCESSING THEN g_rec_lines.array_ccid_flag(g_LineNumber) := C_NOT_PROCESSED;
        ELSE null;
      END CASE;

   WHEN 'DEBIT'  THEN
      g_rec_lines.alt_array_ccid(g_LineNumber) := p_code_combination_id ;

      CASE nvl(g_rec_lines.alt_array_ccid_flag(g_LineNumber),C_INVALID)
        WHEN C_INVALID    THEN g_rec_lines.alt_array_ccid_flag(g_LineNumber) := C_CREATED;
        WHEN C_PROCESSING THEN g_rec_lines.alt_array_ccid_flag(g_LineNumber) := C_NOT_PROCESSED;
        ELSE null;
      END CASE;

  ELSE
     g_rec_lines.array_ccid(g_LineNumber) := p_code_combination_id ;

      CASE nvl(g_rec_lines.array_ccid_flag(g_LineNumber),C_INVALID)
        WHEN C_INVALID    THEN g_rec_lines.array_ccid_flag(g_LineNumber) := C_CREATED;
        WHEN C_PROCESSING THEN g_rec_lines.array_ccid_flag(g_LineNumber) := C_NOT_PROCESSED;
        ELSE null;
      END CASE;
  END CASE;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'End of set_ccid'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN null_combination_id THEN

  CASE p_side
   WHEN 'ALL' THEN
      g_rec_lines.array_ccid(g_LineNumber)     := -1;
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber)    := C_INVALID;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   WHEN 'NA'     THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'CREDIT' THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'DEBIT'  THEN
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   ELSE
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
  END CASE;

  XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
  xla_accounting_err_pkg.build_message
                 (p_appli_s_name            => 'XLA'
                 ,p_msg_name                => 'XLA_AP_CCID_NULL'
                 ,p_token_1                 => 'COMPONENT_NAME'
                 ,p_value_1                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                 'AMB_ADR'
                                                                ,p_adr_code
                                                                ,p_adr_type_code
                                                                ,p_component_appl_id
                                                                ,p_amb_context_code
                                                               )
                 ,p_token_2                 => 'OWNER'
                 ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                                 'XLA_OWNER_TYPE'
                                                                ,p_component_type_code
                                                                )
                 ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                 ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                 ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                 ,p_ae_header_id            => NULL
                );

  IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_CCID_NULL'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
  END IF;
WHEN no_sl_coa_mapping THEN

  CASE p_side
   WHEN 'ALL' THEN
      g_rec_lines.array_ccid(g_LineNumber)     := -1;
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber)    := C_INVALID;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   WHEN 'NA'     THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'CREDIT' THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'DEBIT'  THEN
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   ELSE
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
  END CASE;

  XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;

  xla_accounting_err_pkg.build_message
                 (p_appli_s_name            => 'XLA'
                 ,p_msg_name                => 'XLA_AP_NO_SL_COA_MAPPING'
                 ,p_token_1                 => 'SEGMENT_RULE_NAME'
                 ,p_value_1                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                 'AMB_ADR'
                                                                ,p_adr_code
                                                                ,p_adr_type_code
                                                                ,p_component_appl_id
                                                                ,p_amb_context_code
                                                               )
                 ,p_token_2                 => 'OWNER'
                 ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                                 'XLA_OWNER_TYPE'
                                                                ,p_adr_type_code
                                                                )
                 ,p_token_3                 => 'LEDGER_NAME'
                 ,p_value_3                 => xla_accounting_cache_pkg.GetValueChar
                                             (
                                             p_source_code => 'XLA_LEDGER_NAME'
                                           , p_target_ledger_id  =>
                                             XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                             )
                 ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                 ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                 ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                 ,p_ae_header_id            => NULL
                );

  IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_NO_SL_COA_MAPPING'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
  END IF;
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
           (p_location => 'XLA_AE_LINES_PKG.set_ccid');
END set_ccid;

/*=========================================================================+
|                                                                          |
| Public Procedure                                                         |
|                                                                          |
|    set_segment                                                           |
|                                                                          |
| Caches the transaction and accounting segments in the JE temporary lines |
|                                                                          |
+=========================================================================*/

PROCEDURE set_segment(
  p_to_segment_code         IN VARCHAR2
, p_segment_value           IN VARCHAR2
, p_from_segment_code       IN VARCHAR2
, p_from_combination_id     IN NUMBER
, p_value_type_code         IN VARCHAR2
, p_transaction_coa_id      IN NUMBER
, p_accounting_coa_id       IN NUMBER
, p_flexfield_segment_code  IN VARCHAR2
, p_flex_value_set_id       IN NUMBER
, p_adr_code                IN VARCHAR2
, p_adr_type_code           IN VARCHAR2
, p_component_type          IN VARCHAR2
, p_component_code          IN VARCHAR2
, p_component_type_code     IN VARCHAR2
, p_component_appl_id       IN INTEGER
, p_amb_context_code        IN VARCHAR2
, p_entity_code             IN VARCHAR2
, p_event_class_code        IN VARCHAR2
, p_side                    IN VARCHAR2
)
IS
l_Idx                     BINARY_INTEGER;
l_accounting_values       BOOLEAN;
l_to_segment_code         VARCHAR2(30);
l_from_segment_code       VARCHAR2(30);
l_segment_value           VARCHAR2(30);
l_coa_name                VARCHAR2(240);
invalid_segment_code      EXCEPTION;
invalid_segment_qualifier EXCEPTION;
null_segment_value        EXCEPTION;
no_sl_coa_mapping         EXCEPTION;
l_log_module              VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_segment';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of set_segment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  trace
         (p_msg      => 'p_to_segment_code = '||p_to_segment_code ||
                        ', p_segment_value = '||p_segment_value||
                        ',p_side ='||p_side
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
         (p_msg      => 'p_from_segment_code = '||p_from_segment_code ||
                        ', p_from_combination_id   = '||p_from_combination_id ||
                        ', p_value_type_code   = '||p_value_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

     trace
         (p_msg      => ' p_adr_code   = '||p_adr_code||
                        ', p_adr_type_code = '|| p_adr_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

     trace
         (p_msg      => '  p_flexfield_segment_code = '||p_flexfield_segment_code ||
                        ', p_flex_value_set_id   = '||p_flex_value_set_id ||
                        ', p_transaction_coa_id = '|| p_transaction_coa_id||
                        ', p_accounting_coa_id = '||p_accounting_coa_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    trace
         (p_msg      => ' p_component_type = '||p_component_type||
                        ', p_component_code = '||p_component_code||
                        ', p_component_type_code = '||p_component_type_code||
                        ', p_component_appl_id = '||p_component_appl_id||
                        ', p_amb_context_code = '||p_amb_context_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


l_segment_value       := p_segment_value;
l_from_segment_code   := p_from_segment_code;
l_to_segment_code     := p_to_segment_code;
l_accounting_values   := TRUE;


IF l_from_segment_code IS NOT NULL AND l_from_segment_code NOT LIKE 'SEGMENT%' THEN

    l_from_segment_code   := xla_ae_code_combination_pkg.get_segment_code(
       p_flex_application_id    => 101
      ,p_application_short_name =>  'SQLGL'
      ,p_id_flex_code           => 'GL#'
      ,p_id_flex_num            => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.source_coa_id
      ,p_segment_qualifier      => l_from_segment_code
      ,p_component_type         => p_component_type
      ,p_component_code         => p_component_code
      ,p_component_type_code    => p_component_type_code
      ,p_component_appl_id      => p_component_appl_id
      ,p_amb_context_code       => p_amb_context_code
      ,p_entity_code            => p_entity_code
      ,p_event_class_code       => p_event_class_code
                        );
END IF;

IF l_to_segment_code IS NOT NULL AND l_to_segment_code NOT LIKE 'SEGMENT%' THEN

    l_to_segment_code     := xla_ae_code_combination_pkg.get_segment_code(
       p_flex_application_id    => 101
      ,p_application_short_name =>  'SQLGL'
      ,p_id_flex_code           => 'GL#'
      ,p_id_flex_num            => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id
      ,p_segment_qualifier      => l_to_segment_code
      ,p_component_type         => p_component_type
      ,p_component_code         => p_component_code
      ,p_component_type_code    => p_component_type_code
      ,p_component_appl_id      => p_component_appl_id
      ,p_amb_context_code       => p_amb_context_code
      ,p_entity_code            => p_entity_code
      ,p_event_class_code       => p_event_class_code
                        );
END IF;

IF l_to_segment_code IS NULL THEN
       RAISE invalid_segment_code;
END IF;


IF ( XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id <>
    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.source_coa_id ) AND
    p_accounting_coa_id                                   IS NULL AND
    p_value_type_code ='S'                                        AND
    p_from_combination_id                                 IS NULL AND
    p_flexfield_segment_code                          IS NOT NULL THEN
    -- segment qualifier, secondary ledger , not value set

    IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id IS NULL THEN
      RAISE no_sl_coa_mapping ;
    END IF;

    IF p_segment_value IS NULL THEN
       RAISE null_segment_value;
    END IF;

    IF nvl(p_flexfield_segment_code ,'X') NOT IN ('GL_BALANCING',
                                         'GL_ACCOUNT'  ,
                                         'GL_INTERCOMPANY',
                                         'GL_MANAGEMENT',
                                         'FA_COST_CTR'
                                         ) THEN
        RAISE invalid_segment_qualifier;
    END IF;

    l_Idx := NVL(g_transaction_accounts.array_ae_header_id.COUNT,0)+1;
    g_transaction_accounts.array_line_num(l_Idx)        := l_Idx ;
    g_transaction_accounts.array_ae_header_id(l_Idx)    := g_rec_lines.array_ae_header_id(g_LineNumber);
    g_transaction_accounts.array_temp_line_num(l_Idx)        := g_rec_lines.array_line_num(g_LineNumber);
    g_transaction_accounts.array_code_combination_id(l_Idx)    := NULL;
    g_transaction_accounts.array_segment (l_Idx)               := p_segment_value;
    g_transaction_accounts.array_from_segment_code (l_Idx)     := p_flexfield_segment_code;
    g_transaction_accounts.array_to_segment_code(l_Idx)        := l_to_segment_code;
    g_transaction_accounts.array_processing_status_code(l_Idx) := C_MAP_QUALIFIER;
    g_transaction_accounts.array_side_code(l_Idx)              := p_side;

    l_accounting_values := FALSE;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
         (p_msg      => ' Transaction seg qualifier  = '||p_segment_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;

ELSIF ( XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id <>
    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.source_coa_id ) AND
    p_value_type_code ='S'                                        AND
    p_from_combination_id                            IS NOT NULL THEN
    --transaction segment, secondary ledger

    IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id IS NULL THEN
      RAISE no_sl_coa_mapping ;
    END IF;

    l_Idx := NVL(g_transaction_accounts.array_ae_header_id.COUNT,0) + 1;
    g_transaction_accounts.array_line_num(l_Idx)        := l_Idx ;
    g_transaction_accounts.array_ae_header_id(l_Idx)    := g_rec_lines.array_ae_header_id(g_LineNumber);
    g_transaction_accounts.array_temp_line_num(l_Idx)        := g_rec_lines.array_line_num(g_LineNumber);
    g_transaction_accounts.array_code_combination_id(l_Idx)    := p_from_combination_id;
    g_transaction_accounts.array_segment (l_Idx)               := NULL;
    g_transaction_accounts.array_from_segment_code (l_Idx)     := l_from_segment_code;
    g_transaction_accounts.array_to_segment_code (l_Idx)       := l_to_segment_code;
    g_transaction_accounts.array_processing_status_code(l_Idx) := C_MAP_SEGMENT;
    g_transaction_accounts.array_side_code(l_Idx)              := p_side;

    l_accounting_values := FALSE;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
         (p_msg      => ' get seg '||l_from_segment_code||'from ccid  = '||p_from_combination_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;

ELSIF ( XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id =
    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.source_coa_id )     AND
--    p_accounting_coa_id                                   IS NOT NULL AND -- bug 4304098
    p_value_type_code ='S'                                            AND
    p_from_combination_id                                IS NOT NULL THEN

    -- primary ledger
    l_segment_value := xla_ae_code_combination_pkg.get_flex_segment_value(
           p_combination_id         => p_from_combination_id
          ,p_segment_code           => l_from_segment_code
          ,p_id_flex_code           => 'GL#'
          ,p_flex_application_id    => 101
          ,p_application_short_name => 'SQLGL'
          ,p_component_type         => p_component_type
          ,p_component_code         => p_component_code
          ,p_component_type_code    => p_component_type_code
          ,p_component_appl_id      => p_component_appl_id
          ,p_amb_context_code       => p_amb_context_code
          ,p_entity_code            => p_entity_code
          ,p_event_class_code       => p_event_class_code
          ,p_ae_header_id           => NULL
           );

   l_accounting_values := TRUE;

END IF;

IF l_accounting_values THEN

IF p_side = 'CREDIT' or p_side = 'ALL' or p_side = 'NA' OR p_side is null THEN

 CASE NVL(g_rec_lines.array_ccid_flag(g_LineNumber),C_INVALID)
   WHEN C_CREATED       THEN g_rec_lines.array_ccid_flag(g_LineNumber)   := C_NOT_PROCESSED;
   WHEN C_INVALID       THEN
         IF g_rec_lines.array_ccid(g_LineNumber) IS NULL THEN
              g_rec_lines.array_ccid_flag(g_LineNumber)   := C_PROCESSING;
         END IF;
   ELSE null;
  END CASE;

 CASE  l_to_segment_code
  WHEN  'SEGMENT1'   THEN g_rec_lines.array_segment1(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT2'   THEN g_rec_lines.array_segment2(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT3'   THEN g_rec_lines.array_segment3(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT4'   THEN g_rec_lines.array_segment4(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT5'   THEN g_rec_lines.array_segment5(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT6'   THEN g_rec_lines.array_segment6(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT7'   THEN g_rec_lines.array_segment7(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT8'   THEN g_rec_lines.array_segment8(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT9'   THEN g_rec_lines.array_segment9(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT10'  THEN g_rec_lines.array_segment10(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT11'  THEN g_rec_lines.array_segment11(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT12'  THEN g_rec_lines.array_segment12(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT13'  THEN g_rec_lines.array_segment13(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT14'  THEN g_rec_lines.array_segment14(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT15'  THEN g_rec_lines.array_segment15(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT16'  THEN g_rec_lines.array_segment16(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT17'  THEN g_rec_lines.array_segment17(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT18'  THEN g_rec_lines.array_segment18(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT19'  THEN g_rec_lines.array_segment19(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT20'  THEN g_rec_lines.array_segment20(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT21'  THEN g_rec_lines.array_segment21(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT22'  THEN g_rec_lines.array_segment22(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT23'  THEN g_rec_lines.array_segment23(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT24'  THEN g_rec_lines.array_segment24(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT25'  THEN g_rec_lines.array_segment25(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT26'  THEN g_rec_lines.array_segment26(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT27'  THEN g_rec_lines.array_segment27(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT28'  THEN g_rec_lines.array_segment28(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT29'  THEN g_rec_lines.array_segment29(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT30'  THEN g_rec_lines.array_segment30(g_LineNumber) := l_segment_value;
  ELSE
     RAISE invalid_segment_code;
 END CASE;

END IF;

IF p_side = 'DEBIT' or p_side = 'ALL' THEN

 CASE NVL(g_rec_lines.alt_array_ccid_flag(g_LineNumber),C_INVALID)
   WHEN C_CREATED       THEN g_rec_lines.alt_array_ccid_flag(g_LineNumber)   := C_NOT_PROCESSED;
   WHEN C_INVALID       THEN
         IF g_rec_lines.alt_array_ccid(g_LineNumber) IS NULL THEN
              g_rec_lines.alt_array_ccid_flag(g_LineNumber)   := C_PROCESSING;
         END IF;
   ELSE null;
  END CASE;

 CASE  l_to_segment_code
  WHEN  'SEGMENT1'   THEN g_rec_lines.alt_array_segment1(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT2'   THEN g_rec_lines.alt_array_segment2(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT3'   THEN g_rec_lines.alt_array_segment3(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT4'   THEN g_rec_lines.alt_array_segment4(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT5'   THEN g_rec_lines.alt_array_segment5(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT6'   THEN g_rec_lines.alt_array_segment6(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT7'   THEN g_rec_lines.alt_array_segment7(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT8'   THEN g_rec_lines.alt_array_segment8(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT9'   THEN g_rec_lines.alt_array_segment9(g_LineNumber)  := l_segment_value;
  WHEN  'SEGMENT10'  THEN g_rec_lines.alt_array_segment10(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT11'  THEN g_rec_lines.alt_array_segment11(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT12'  THEN g_rec_lines.alt_array_segment12(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT13'  THEN g_rec_lines.alt_array_segment13(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT14'  THEN g_rec_lines.alt_array_segment14(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT15'  THEN g_rec_lines.alt_array_segment15(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT16'  THEN g_rec_lines.alt_array_segment16(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT17'  THEN g_rec_lines.alt_array_segment17(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT18'  THEN g_rec_lines.alt_array_segment18(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT19'  THEN g_rec_lines.alt_array_segment19(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT20'  THEN g_rec_lines.alt_array_segment20(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT21'  THEN g_rec_lines.alt_array_segment21(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT22'  THEN g_rec_lines.alt_array_segment22(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT23'  THEN g_rec_lines.alt_array_segment23(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT24'  THEN g_rec_lines.alt_array_segment24(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT25'  THEN g_rec_lines.alt_array_segment25(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT26'  THEN g_rec_lines.alt_array_segment26(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT27'  THEN g_rec_lines.alt_array_segment27(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT28'  THEN g_rec_lines.alt_array_segment28(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT29'  THEN g_rec_lines.alt_array_segment29(g_LineNumber) := l_segment_value;
  WHEN  'SEGMENT30'  THEN g_rec_lines.alt_array_segment30(g_LineNumber) := l_segment_value;
  ELSE
      RAISE invalid_segment_code;
 END CASE;

END IF;

    IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
         (p_msg      => ' Accounting seg = '||l_segment_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
    END IF;

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
         (p_msg      => 'l_to_segment_code = '||l_to_segment_code ||
                        ', l_segment_value   = '||l_segment_value
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of set_segment'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN no_sl_coa_mapping THEN

  CASE p_side
   WHEN 'ALL' THEN
      g_rec_lines.array_ccid(g_LineNumber)     := -1;
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber)    := C_INVALID;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   WHEN 'NA'     THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'CREDIT' THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'DEBIT'  THEN
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   ELSE
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
  END CASE;

  XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;

  xla_accounting_err_pkg.build_message
                 (p_appli_s_name            => 'XLA'
                 ,p_msg_name                => 'XLA_AP_NO_SL_COA_MAPPING'
                 ,p_token_1                 => 'SEGMENT_RULE_NAME'
                 ,p_value_1                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                 'AMB_ADR'
                                                                ,p_adr_code
                                                                ,p_adr_type_code
                                                                ,p_component_appl_id
                                                                ,p_amb_context_code
                                                               )
                 ,p_token_2                 => 'OWNER'
                 ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                                 'XLA_OWNER_TYPE'
                                                                ,p_adr_type_code
                                                                )
                 ,p_token_3                 => 'LEDGER_NAME'
                 ,p_value_3                 => xla_accounting_cache_pkg.GetValueChar
                                             (
                                             p_source_code => 'XLA_LEDGER_NAME'
                                           , p_target_ledger_id  =>
                                             XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                             )
                 ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                 ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                 ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                 ,p_ae_header_id            => NULL
                );

  IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_NO_SL_COA_MAPPING'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
  END IF;

WHEN invalid_segment_code THEN

   CASE p_side
   WHEN 'ALL' THEN
      g_rec_lines.array_ccid(g_LineNumber)     := -1;
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber)    := C_INVALID;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   WHEN 'NA'     THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'CREDIT' THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'DEBIT'  THEN
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   ELSE
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   END CASE;

   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;

   l_coa_name := xla_accounting_cache_pkg.GetValueChar
     (
      p_source_code       => 'XLA_COA_NAME'
    , p_target_ledger_id  => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
     );

   xla_accounting_err_pkg.build_message
                      (p_appli_s_name            => 'XLA'
                      ,p_msg_name                => 'XLA_AP_INVALID_SEGMENT'
                      ,p_token_1                 => 'COMPONENT_TYPE'
                      ,p_value_1                 => xla_lookups_pkg.get_meaning(
                                                            'XLA_AMB_COMPONENT_TYPE'
                                                           , p_component_type
                                                            )
                      ,p_token_2                 => 'COMPONENT_NAME'
                      ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                 p_component_type
                                                                ,p_component_code
                                                                ,p_component_type_code
                                                                ,p_component_appl_id
                                                                ,p_amb_context_code
                                                                ,p_entity_code
                                                                ,p_event_class_code
                                                               )
                      ,p_token_3                 => 'OWNER'
                      ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                 'XLA_OWNER_TYPE'
                                                                ,p_component_type_code
                                                                )
                      ,p_token_4                 => 'QUALIFIER_NAME'
                      ,p_value_4                 => xla_lookups_pkg.get_meaning(
                                                        p_lookup_type    => 'XLA_FLEXFIELD_SEGMENTS_QUAL'
                                                      , p_lookup_code    => p_to_segment_code
                                                      )
                      ,p_token_5                 => 'ACCOUNTING_COA'
                      ,p_value_5                 => l_coa_name
                      ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                      ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                      ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                      ,p_ae_header_id            => NULL -- p_ae_header_id
                );

     IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INVALID_SEGMENT'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
     END IF;

WHEN null_segment_value THEN

   CASE p_side
   WHEN 'ALL' THEN
      g_rec_lines.array_ccid(g_LineNumber)     := -1;
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber)    := C_INVALID;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   WHEN 'NA'     THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'CREDIT' THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'DEBIT'  THEN
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   ELSE
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   END CASE;

   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;

   xla_accounting_err_pkg.build_message
                      (p_appli_s_name            => 'XLA'
                      ,p_msg_name                => 'XLA_AP_NULL_SEGMENT_VALUE'
                      ,p_token_1                 => 'SEGMENT_RULE_NAME'
                      ,p_value_1                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                 'AMB_ADR'
                                                                ,p_adr_code
                                                                ,p_adr_type_code
                                                                ,p_component_appl_id
                                                                ,p_amb_context_code
                                                               )
                      ,p_token_2                 => 'OWNER'
                      ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                                 'XLA_OWNER_TYPE'
                                                                ,p_adr_type_code
                                                                )
                      ,p_token_3                 => 'QUALIFIER_NAME'
                      ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                        p_lookup_type    => 'XLA_FLEXFIELD_SEGMENTS_QUAL'
                                                      , p_lookup_code    => p_flexfield_segment_code
                                                      )
                      ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                      ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                      ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                      ,p_ae_header_id            => NULL -- p_ae_header_id
                );

     IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_NULL_SEGMENT_VALUE'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
     END IF;

WHEN invalid_segment_qualifier THEN

   CASE p_side
   WHEN 'ALL' THEN
      g_rec_lines.array_ccid(g_LineNumber)     := -1;
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber)    := C_INVALID;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   WHEN 'NA'     THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'CREDIT' THEN
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   WHEN 'DEBIT'  THEN
      g_rec_lines.alt_array_ccid(g_LineNumber) := -1;
      g_rec_lines.alt_array_ccid_flag(g_LineNumber):= C_INVALID;
   ELSE
      g_rec_lines.array_ccid(g_LineNumber) := -1;
      g_rec_lines.array_ccid_flag(g_LineNumber) := C_INVALID;
   END CASE;

   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;

   l_coa_name := xla_accounting_cache_pkg.GetValueChar
     (
      p_source_code       => 'XLA_COA_NAME'
    , p_target_ledger_id  => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
     );

   xla_accounting_err_pkg.build_message
                      (p_appli_s_name            => 'XLA'
                      ,p_msg_name                => 'XLA_AP_INV_SEGMENT_QUAL'
                      ,p_token_1                 => 'SEGMENT_RULE_NAME'
                      ,p_value_1                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                 'AMB_ADR'
                                                                ,p_adr_code
                                                                ,p_adr_type_code
                                                                ,p_component_appl_id
                                                                ,p_amb_context_code
                                                               )
                      ,p_token_2                 => 'OWNER'
                      ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                                 'XLA_OWNER_TYPE'
                                                                ,p_adr_type_code
                                                                )

                      ,p_token_3                 => 'QUALIFIER_NAME'
                      ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                        p_lookup_type    => 'XLA_FLEXFIELD_SEGMENTS_QUAL'
                                                      , p_lookup_code    => p_flexfield_segment_code
                                                      )
                      ,p_token_4                 => 'ACCOUNTING_COA'
                      ,p_value_4                 => l_coa_name
                      ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                      ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                      ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                      ,p_ae_header_id            => NULL -- p_ae_header_id
                );

     IF (C_LEVEL_ERROR >= g_log_level) THEN
             trace
                  (p_msg      => 'ERROR: XLA_AP_INV_SEGMENT_QUAL'
                  ,p_level    => C_LEVEL_ERROR
                  ,p_module   => l_log_module);
     END IF;
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
           (p_location => 'XLA_AE_LINES_PKG.set_segment');
END set_segment;

--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|   ValidateCurrentLine                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE ValidateCurrentLine
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateCurrentLine';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of ValidateCurrentLine'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF nvl(g_LineNumber,0) > 0 THEN

     -----------------------------------------------------------
     -- 4219869 Business Flow
     -- Call is moved to XLA_CMP_ACCT_LINE_TYPE_PKG.C_ALT_BODY
     -----------------------------------------------------------
     -- SetDebitCreditAmounts(p_ae_header_id => p_ae_header_id);
     -----------------------------------------------------------

     ValidateLinks;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of ValidateCurrentLine = '||g_LineNumber
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.ValidateCurrentLine');
  --
END ValidateCurrentLine;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetAcctClass(p_accounting_class_code      IN VARCHAR2
                      ,p_ae_header_id               IN NUMBER)
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetAcctClass';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetAcctClass'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_accounting_class_code = '||p_accounting_class_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

  g_rec_lines.array_accounting_class(g_LineNumber) := p_accounting_class_code;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetAcctClass'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetAcctClass');
END SetAcctClass;
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
 , p_ae_header_id                 IN NUMBER
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

      trace
          (p_msg      => '-> CALL XLA_ANALYTICAL_CRITERIA_PKG.concat_detail_values API'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

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
IF g_rec_lines.array_anc_balance_flag(g_LineNumber) IS NULL AND
    nvl(p_balancing_flag,'N') = 'Y'
THEN
    g_rec_lines.array_anc_balance_flag(g_LineNumber) := 'P';
END IF;

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
 XLA_AE_JOURNAL_ENTRY_PKG.g_global_status :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
 RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetAnalyticalCriteria');
  --
END SetAnalyticalCriteria;


--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION InsertLines
RETURN BOOLEAN
IS
l_result                   BOOLEAN;
l_ledger_currency          VARCHAR2(30);
l_ledger_category_code     VARCHAR2(30);
l_rowcount                 NUMBER;
l_null_trans_accounts t_rec_transaction_accounts;
l_log_module               VARCHAR2(240);
errors                     NUMBER; -- 7453943
ERR_IND                    NUMBER; -- 7453943
ERR_CODE                   VARCHAR2(100); -- 7453943
dml_errors                 EXCEPTION; -- 7453943
PRAGMA exception_init(dml_errors, -24381); -- 7453943
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertLines';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of InsertLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_result   :=TRUE;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
 trace
  (p_msg      => '# temporary journal lines to insert into GT xla_ae_lines_gt = '||g_rec_lines.array_line_num.COUNT
  ,p_level    => C_LEVEL_STATEMENT
  ,p_module   => l_log_module);
END IF;

--
-- Bug 4458708
--
IF g_rec_lines.array_line_num.COUNT > 0 THEN

  l_result   := FALSE;
  l_rowcount := 0;

  --cache accounting COA
  xla_ae_code_combination_pkg.cache_coa
       (p_coa_id     => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id
       ,p_target_coa => 'Y');

  --get the ledger currency
  -- when this fuction is called, all the lines are always for one ledger

  l_ledger_currency := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code;
  l_ledger_category_code:= XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'ledger_currency:'||l_ledger_currency||' category_coe:'||l_ledger_category_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  IF l_ledger_category_code = 'ALC' THEN
    IF (xla_accounting_cache_pkg.GetValueChar('XLA_ALC_ENABLED_FLAG')='N') THEN
      l_ledger_category_code :='PRIMARY';
    END IF;
  END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'SQL - Insert into xla_ae_lines_gt'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  ------------------------------------------------------------------------------------------------------

  FORALL Idx IN g_rec_lines.array_line_num.FIRST .. g_rec_lines.array_line_num.LAST SAVE EXCEPTIONS --7453943
   INSERT INTO xla_ae_lines_gt
         ( ae_header_id
         , temp_line_num
         , extract_line_num
         , event_id
         , ref_ae_header_id
         --
         , accounting_date        --4955764
         , accounting_class_code
         , rounding_class_code
         , event_class_code
         , event_type_code
         , line_definition_owner_code
         , line_definition_code
         , accounting_line_type_code
         , accounting_line_code
         , document_rounding_level
         , gain_or_loss_ref
         --
         , calculate_acctd_amts_flag
         , calculate_g_l_amts_flag
         , gain_or_loss_flag
         --
         , code_combination_status_code
         , code_combination_id
         , sl_coa_mapping_name
         , sl_coa_mapping_id
         , dynamic_insert_flag
         , source_coa_id
         , ccid_coa_id
         , segment1
         , segment2
         , segment3
         , segment4
         , segment5
         , segment6
         , segment7
         , segment8
         , segment9
         , segment10
         , segment11
         , segment12
         , segment13
         , segment14
         , segment15
         , segment16
         , segment17
         , segment18
         , segment19
         , segment20
         , segment21
         , segment22
         , segment23
         , segment24
         , segment25
         , segment26
         , segment27
         , segment28
         , segment29
         , segment30
         --
         , alt_ccid_status_code
         , alt_code_combination_id
         , alt_segment1
         , alt_segment2
         , alt_segment3
         , alt_segment4
         , alt_segment5
         , alt_segment6
         , alt_segment7
         , alt_segment8
         , alt_segment9
         , alt_segment10
         , alt_segment11
         , alt_segment12
         , alt_segment13
         , alt_segment14
         , alt_segment15
         , alt_segment16
         , alt_segment17
         , alt_segment18
         , alt_segment19
         , alt_segment20
         , alt_segment21
         , alt_segment22
         , alt_segment23
         , alt_segment24
         , alt_segment25
         , alt_segment26
         , alt_segment27
         , alt_segment28
         , alt_segment29
         , alt_segment30
         --
         , description
         , gl_transfer_mode_code
         , merge_duplicate_code
         , switch_side_flag
         --
         , entered_amount
         , ledger_amount
         , unrounded_entered_dr
         , unrounded_entered_cr
         , unrounded_accounted_dr
         , unrounded_accounted_cr
         , entered_currency_mau
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
         , reverse_dist_id_char_1
         , reverse_dist_id_char_2
         , reverse_dist_id_char_3
         , reverse_dist_id_char_4
         , reverse_dist_id_char_5
         , reverse_dist_id_num_1
         , reverse_dist_id_num_2
         , reverse_dist_id_num_3
         , reverse_dist_id_num_4
         , reverse_dist_id_num_5
         , reverse_distribution_type
         --
         , tax_line_ref_id
         , tax_summary_line_ref_id
         , tax_rec_nrec_dist_ref_id
         --
         --
         -- 4262811
         , header_num
         , mpa_accrual_entry_flag
         , multiperiod_option_flag
         , multiperiod_start_date
         , multiperiod_end_date
         --
         , analytical_balance_flag
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
         --, deferred_indicator
         --, deferred_start_date
         --, deferred_end_date
         --, deferred_no_period
         --, deferred_period_type
        -- bulk performance
         , balance_type_code  -- element at index [x] does not exist.
         , ledger_id          -- element at index [x] does not exist.
         , event_number
         , entity_id
         , reversal_code
         , encumbrance_type_id -- 4458381
         --------------------------------------
         -- 4219869
         -- Business Flow Applied To attributes
         --------------------------------------
         ,inherit_desc_flag
         ,natural_side_code
         ,business_method_code
         ,business_class_code
         ,bflow_application_id
         ,bflow_entity_code
         ,bflow_source_id_num_1
         ,bflow_source_id_num_2
         ,bflow_source_id_num_3
         ,bflow_source_id_num_4
         ,bflow_source_id_char_1
         ,bflow_source_id_char_2
         ,bflow_source_id_char_3
         ,bflow_source_id_char_4
         ,bflow_distribution_type
         ,bflow_dist_id_num_1
         ,bflow_dist_id_num_2
         ,bflow_dist_id_num_3
         ,bflow_dist_id_num_4
         ,bflow_dist_id_num_5
         ,bflow_dist_id_char_1
         ,bflow_dist_id_char_2
         ,bflow_dist_id_char_3
         ,bflow_dist_id_char_4
         ,bflow_dist_id_char_5
         ,bflow_applied_to_amount  -- 5132302
     ,override_acctd_amt_flag
         --
         -- Allocation Attributes
         --
         ,alloc_to_application_id
         ,alloc_to_entity_code
         ,alloc_to_source_id_num_1
         ,alloc_to_source_id_num_2
         ,alloc_to_source_id_num_3
         ,alloc_to_source_id_num_4
         ,alloc_to_source_id_char_1
         ,alloc_to_source_id_char_2
         ,alloc_to_source_id_char_3
         ,alloc_to_source_id_char_4
         ,alloc_to_distribution_type
         ,alloc_to_dist_id_num_1
         ,alloc_to_dist_id_num_2
         ,alloc_to_dist_id_num_3
         ,alloc_to_dist_id_num_4
         ,alloc_to_dist_id_num_5
         ,alloc_to_dist_id_char_1
         ,alloc_to_dist_id_char_2
         ,alloc_to_dist_id_char_3
         ,alloc_to_dist_id_char_4
         ,alloc_to_dist_id_char_5
   )
   VALUES
   (
     g_rec_lines.array_ae_header_id(Idx)
   , g_rec_lines.array_line_num(Idx)
   , g_rec_lines.array_extract_line_num(Idx)
   , g_rec_lines.array_ae_header_id(Idx)
   , g_rec_lines.array_ae_header_id(Idx)
  --
   , g_rec_lines.array_gl_date(Idx)           --4955764
   , g_rec_lines.array_accounting_class(Idx)
   , g_rec_lines.array_rounding_class(Idx)
   , g_rec_lines.array_event_class_code(Idx)
   , g_rec_lines.array_event_type_code(Idx)
   , g_rec_lines.array_line_defn_owner_code(Idx)
   , g_rec_lines.array_line_defn_code(Idx)
   , g_rec_lines.array_accounting_line_type(Idx)
   , g_rec_lines.array_accounting_line_code(Idx)
   , g_rec_lines.array_doc_rounding_level(Idx)
   , nvl(g_rec_lines.array_gain_or_loss_ref(Idx), '#line#'||g_rec_lines.array_extract_line_num(Idx))
   --
   , g_rec_lines.array_calculate_acctd_flag(Idx)
   , g_rec_lines.array_calculate_g_l_flag(Idx)
   , decode(g_rec_lines.array_gain_or_loss_flag(Idx), 'Y', 'Y', decode(g_rec_lines.array_natural_side_code(Idx), 'G', 'Y', 'N'))
   --
   , g_rec_lines.array_ccid_flag(Idx)
   , g_rec_lines.array_ccid(Idx)
   --
   , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_name
   , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id
  --
   , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.dynamic_insert_flag
   , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.source_coa_id
   , XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id
  --
   , g_rec_lines.array_segment1(Idx)
   , g_rec_lines.array_segment2(Idx)
   , g_rec_lines.array_segment3(Idx)
   , g_rec_lines.array_segment4(Idx)
   , g_rec_lines.array_segment5(Idx)
   , g_rec_lines.array_segment6(Idx)
   , g_rec_lines.array_segment7(Idx)
   , g_rec_lines.array_segment8(Idx)
   , g_rec_lines.array_segment9(Idx)
   , g_rec_lines.array_segment10(Idx)
   , g_rec_lines.array_segment11(Idx)
   , g_rec_lines.array_segment12(Idx)
   , g_rec_lines.array_segment13(Idx)
   , g_rec_lines.array_segment14(Idx)
   , g_rec_lines.array_segment15(Idx)
   , g_rec_lines.array_segment16(Idx)
   , g_rec_lines.array_segment17(Idx)
   , g_rec_lines.array_segment18(Idx)
   , g_rec_lines.array_segment19(Idx)
   , g_rec_lines.array_segment20(Idx)
   , g_rec_lines.array_segment21(Idx)
   , g_rec_lines.array_segment22(Idx)
   , g_rec_lines.array_segment23(Idx)
   , g_rec_lines.array_segment24(Idx)
   , g_rec_lines.array_segment25(Idx)
   , g_rec_lines.array_segment26(Idx)
   , g_rec_lines.array_segment27(Idx)
   , g_rec_lines.array_segment28(Idx)
   , g_rec_lines.array_segment29(Idx)
   , g_rec_lines.array_segment30(Idx)
    --
   , g_rec_lines.alt_array_ccid_flag(Idx)
   , g_rec_lines.alt_array_ccid(Idx)
   , g_rec_lines.alt_array_segment1(Idx)
   , g_rec_lines.alt_array_segment2(Idx)
   , g_rec_lines.alt_array_segment3(Idx)
   , g_rec_lines.alt_array_segment4(Idx)
   , g_rec_lines.alt_array_segment5(Idx)
   , g_rec_lines.alt_array_segment6(Idx)
   , g_rec_lines.alt_array_segment7(Idx)
   , g_rec_lines.alt_array_segment8(Idx)
   , g_rec_lines.alt_array_segment9(Idx)
   , g_rec_lines.alt_array_segment10(Idx)
   , g_rec_lines.alt_array_segment11(Idx)
   , g_rec_lines.alt_array_segment12(Idx)
   , g_rec_lines.alt_array_segment13(Idx)
   , g_rec_lines.alt_array_segment14(Idx)
   , g_rec_lines.alt_array_segment15(Idx)
   , g_rec_lines.alt_array_segment16(Idx)
   , g_rec_lines.alt_array_segment17(Idx)
   , g_rec_lines.alt_array_segment18(Idx)
   , g_rec_lines.alt_array_segment19(Idx)
   , g_rec_lines.alt_array_segment20(Idx)
   , g_rec_lines.alt_array_segment21(Idx)
   , g_rec_lines.alt_array_segment22(Idx)
   , g_rec_lines.alt_array_segment23(Idx)
   , g_rec_lines.alt_array_segment24(Idx)
   , g_rec_lines.alt_array_segment25(Idx)
   , g_rec_lines.alt_array_segment26(Idx)
   , g_rec_lines.alt_array_segment27(Idx)
   , g_rec_lines.alt_array_segment28(Idx)
   , g_rec_lines.alt_array_segment29(Idx)
   , g_rec_lines.alt_array_segment30(Idx)
    --
   , g_rec_lines.array_description(Idx)
   , g_rec_lines.array_gl_transfer_mode(Idx)
   , g_rec_lines.array_merge_duplicate_code(Idx)
   , decode(g_rec_lines.array_natural_side_code(Idx), 'G', 'Y',
           g_rec_lines.array_switch_side_flag(Idx))
      --
   , g_rec_lines.array_entered_amount(Idx)
   , g_rec_lines.array_ledger_amount(Idx)
   , g_rec_lines.array_entered_dr(Idx)
   , g_rec_lines.array_entered_cr(Idx)
   , g_rec_lines.array_accounted_dr(Idx)
   , g_rec_lines.array_accounted_cr(Idx)
   -- currency mau, put some dummy value for gain/loss line
   , decode(g_rec_lines.array_natural_side_code(Idx), 'G', .01
            , g_rec_lines.array_currency_mau(Idx))
   , decode(g_rec_lines.array_natural_side_code(Idx), 'G', l_ledger_currency
            , g_rec_lines.array_currency_code(Idx))--
   /*, decode(l_ledger_category_code
           ,'PRIMARY',TRUNC(g_rec_lines.array_curr_conversion_date(Idx))
           ,decode(l_ledger_currency
                  ,g_rec_lines.array_currency_code(Idx),NULL
                  ,TRUNC(g_rec_lines.array_curr_conversion_date(Idx))
                  )
           )    -- currency_conversion_date*/
   /* Modified for bug 8810416 */
   ,decode(l_ledger_currency ,g_rec_lines.array_currency_code(Idx),NULL,
              TRUNC(g_rec_lines.array_curr_conversion_date(Idx))) -- currency_conversion_date
   /*, decode(l_ledger_category_code, 'PRIMARY',
        g_rec_lines.array_curr_conversion_rate(Idx)
        ,decode(l_ledger_currency, g_rec_lines.array_currency_code(Idx),
           null, g_rec_lines.array_curr_conversion_rate(Idx))) */
   /* Modified for bug 8810416 */
    ,decode(l_ledger_currency, g_rec_lines.array_currency_code(Idx),null
            , g_rec_lines.array_curr_conversion_rate(Idx)) -- currency_conversion_rate
   /*, decode(l_ledger_category_code, 'PRIMARY',
        g_rec_lines.array_curr_conversion_type(Idx)
        ,decode(l_ledger_currency, g_rec_lines.array_currency_code(Idx),
           null, g_rec_lines.array_curr_conversion_type(Idx))) */
   /* Modified for bug 8810416 */
      ,decode(l_ledger_currency, g_rec_lines.array_currency_code(Idx),null,
                  g_rec_lines.array_curr_conversion_type(Idx)) -- currency_conversion_type
   , g_rec_lines.array_statistical_amount(Idx)
    --
   , g_rec_lines.array_party_id(Idx)
   , g_rec_lines.array_party_site_id(Idx)
   , g_rec_lines.array_party_type_code(Idx)
    --
   , g_rec_lines.array_ussgl_transaction(Idx)
   , g_rec_lines.array_jgzz_recon_ref(Idx)
    --
   , g_rec_lines.array_distribution_id_char_1(Idx)
   , g_rec_lines.array_distribution_id_char_2(Idx)
   , g_rec_lines.array_distribution_id_char_3(Idx)
   , g_rec_lines.array_distribution_id_char_4(Idx)
   , g_rec_lines.array_distribution_id_char_5(Idx)
   , g_rec_lines.array_distribution_id_num_1(Idx)
   , g_rec_lines.array_distribution_id_num_2(Idx)
   , g_rec_lines.array_distribution_id_num_3(Idx)
   , g_rec_lines.array_distribution_id_num_4(Idx)
   , g_rec_lines.array_distribution_id_num_5(Idx)
   , g_rec_lines.array_sys_distribution_type(Idx)
   --
   , g_rec_lines.array_rev_dist_id_char_1(Idx)
   , g_rec_lines.array_rev_dist_id_char_2(Idx)
   , g_rec_lines.array_rev_dist_id_char_3(Idx)
   , g_rec_lines.array_rev_dist_id_char_4(Idx)
   , g_rec_lines.array_rev_dist_id_char_5(Idx)
   , g_rec_lines.array_rev_dist_id_num_1(Idx)
   , g_rec_lines.array_rev_dist_id_num_2(Idx)
   , g_rec_lines.array_rev_dist_id_num_3(Idx)
   , g_rec_lines.array_rev_dist_id_num_4(Idx)
   , g_rec_lines.array_rev_dist_id_num_5(Idx)
   , g_rec_lines.array_rev_dist_type(Idx)
   --
   , g_rec_lines.array_tax_line_ref(Idx)
   , g_rec_lines.array_tax_summary_line_ref(Idx)
   , g_rec_lines.array_tax_rec_nrec_dist_ref(Idx)
  -- 4262811
   , NVL(g_rec_lines.array_header_num(Idx),0)  -- 5100860  always assign a value
   , g_rec_lines.array_mpa_acc_entry_flag(Idx)
   , g_rec_lines.array_mpa_option(Idx)
   , g_rec_lines.array_mpa_start_date(Idx)
   , g_rec_lines.array_mpa_end_date(Idx)
   -- Analytical Criteria
   , g_rec_lines.array_anc_balance_flag(Idx)
   , g_rec_lines.array_anc_id_1(Idx)
   , g_rec_lines.array_anc_id_2(Idx)
   , g_rec_lines.array_anc_id_3(Idx)
   , g_rec_lines.array_anc_id_4(Idx)
   , g_rec_lines.array_anc_id_5(Idx)
   , g_rec_lines.array_anc_id_6(Idx)
   , g_rec_lines.array_anc_id_7(Idx)
   , g_rec_lines.array_anc_id_8(Idx)
   , g_rec_lines.array_anc_id_9(Idx)
   , g_rec_lines.array_anc_id_10(Idx)
   , g_rec_lines.array_anc_id_11(Idx)
   , g_rec_lines.array_anc_id_12(Idx)
   , g_rec_lines.array_anc_id_13(Idx)
   , g_rec_lines.array_anc_id_14(Idx)
   , g_rec_lines.array_anc_id_15(Idx)
   , g_rec_lines.array_anc_id_16(Idx)
   , g_rec_lines.array_anc_id_17(Idx)
   , g_rec_lines.array_anc_id_18(Idx)
   , g_rec_lines.array_anc_id_19(Idx)
   , g_rec_lines.array_anc_id_20(Idx)
   , g_rec_lines.array_anc_id_21(Idx)
   , g_rec_lines.array_anc_id_22(Idx)
   , g_rec_lines.array_anc_id_23(Idx)
   , g_rec_lines.array_anc_id_24(Idx)
   , g_rec_lines.array_anc_id_25(Idx)
   , g_rec_lines.array_anc_id_26(Idx)
   , g_rec_lines.array_anc_id_27(Idx)
   , g_rec_lines.array_anc_id_28(Idx)
   , g_rec_lines.array_anc_id_29(Idx)
   , g_rec_lines.array_anc_id_30(Idx)
   , g_rec_lines.array_anc_id_31(Idx)
   , g_rec_lines.array_anc_id_32(Idx)
   , g_rec_lines.array_anc_id_33(Idx)
   , g_rec_lines.array_anc_id_34(Idx)
   , g_rec_lines.array_anc_id_35(Idx)
   , g_rec_lines.array_anc_id_36(Idx)
   , g_rec_lines.array_anc_id_37(Idx)
   , g_rec_lines.array_anc_id_38(Idx)
   , g_rec_lines.array_anc_id_39(Idx)
   , g_rec_lines.array_anc_id_40(Idx)
   , g_rec_lines.array_anc_id_41(Idx)
   , g_rec_lines.array_anc_id_42(Idx)
   , g_rec_lines.array_anc_id_43(Idx)
   , g_rec_lines.array_anc_id_44(Idx)
   , g_rec_lines.array_anc_id_45(Idx)
   , g_rec_lines.array_anc_id_46(Idx)
   , g_rec_lines.array_anc_id_47(Idx)
   , g_rec_lines.array_anc_id_48(Idx)
   , g_rec_lines.array_anc_id_49(Idx)
   , g_rec_lines.array_anc_id_50(Idx)
   , g_rec_lines.array_anc_id_51(Idx)
   , g_rec_lines.array_anc_id_52(Idx)
   , g_rec_lines.array_anc_id_53(Idx)
   , g_rec_lines.array_anc_id_54(Idx)
   , g_rec_lines.array_anc_id_55(Idx)
   , g_rec_lines.array_anc_id_56(Idx)
   , g_rec_lines.array_anc_id_57(Idx)
   , g_rec_lines.array_anc_id_58(Idx)
   , g_rec_lines.array_anc_id_59(Idx)
   , g_rec_lines.array_anc_id_60(Idx)
   , g_rec_lines.array_anc_id_61(Idx)
   , g_rec_lines.array_anc_id_62(Idx)
   , g_rec_lines.array_anc_id_63(Idx)
   , g_rec_lines.array_anc_id_64(Idx)
   , g_rec_lines.array_anc_id_65(Idx)
   , g_rec_lines.array_anc_id_66(Idx)
   , g_rec_lines.array_anc_id_67(Idx)
   , g_rec_lines.array_anc_id_68(Idx)
   , g_rec_lines.array_anc_id_69(Idx)
   , g_rec_lines.array_anc_id_70(Idx)
   , g_rec_lines.array_anc_id_71(Idx)
   , g_rec_lines.array_anc_id_72(Idx)
   , g_rec_lines.array_anc_id_73(Idx)
   , g_rec_lines.array_anc_id_74(Idx)
   , g_rec_lines.array_anc_id_75(Idx)
   , g_rec_lines.array_anc_id_76(Idx)
   , g_rec_lines.array_anc_id_77(Idx)
   , g_rec_lines.array_anc_id_78(Idx)
   , g_rec_lines.array_anc_id_79(Idx)
   , g_rec_lines.array_anc_id_80(Idx)
   , g_rec_lines.array_anc_id_81(Idx)
   , g_rec_lines.array_anc_id_82(Idx)
   , g_rec_lines.array_anc_id_83(Idx)
   , g_rec_lines.array_anc_id_84(Idx)
   , g_rec_lines.array_anc_id_85(Idx)
   , g_rec_lines.array_anc_id_86(Idx)
   , g_rec_lines.array_anc_id_87(Idx)
   , g_rec_lines.array_anc_id_88(Idx)
   , g_rec_lines.array_anc_id_89(Idx)
   , g_rec_lines.array_anc_id_90(Idx)
   , g_rec_lines.array_anc_id_91(Idx)
   , g_rec_lines.array_anc_id_92(Idx)
   , g_rec_lines.array_anc_id_93(Idx)
   , g_rec_lines.array_anc_id_94(Idx)
   , g_rec_lines.array_anc_id_95(Idx)
   , g_rec_lines.array_anc_id_96(Idx)
   , g_rec_lines.array_anc_id_97(Idx)
   , g_rec_lines.array_anc_id_98(Idx)
   , g_rec_lines.array_anc_id_99(Idx)
   , g_rec_lines.array_anc_id_100(Idx)
  -- , g_rec_lines.array_deferred_indicator(Idx)
  -- , g_rec_lines.array_deferred_start_date(Idx)
  -- , g_rec_lines.array_deferred_end_date(Idx)
  -- , g_rec_lines.array_deferred_no_period(Idx)
  -- , g_rec_lines.array_deferred_period_type(Idx)
  -- bulk performance
   , g_rec_lines.array_balance_type_code(Idx)  -- element at index [x] does not exist.
   , g_rec_lines.array_ledger_id(Idx)          -- element at index [x] does not exist.
   , g_rec_lines.array_event_number(Idx)
   , g_rec_lines.array_entity_id(Idx)
   , g_rec_lines.array_reversal_code(Idx)
   , g_rec_lines.array_encumbrance_type_id(Idx) -- 4458381
   --------------------------------------
   -- 4219869
   -- Business Flow Applied To attributes
   --------------------------------------
   , g_rec_lines.array_inherit_desc_flag(Idx)
   , g_rec_lines.array_natural_side_code(Idx)
   , g_rec_lines.array_business_method_code(Idx)
   , g_rec_lines.array_business_class_code(Idx)
   , g_rec_lines.array_bflow_application_id(Idx)
   --
   , g_rec_lines.array_bflow_entity_code(Idx)
   , g_rec_lines.array_bflow_source_id_num_1(Idx)
   , g_rec_lines.array_bflow_source_id_num_2(Idx)
   , g_rec_lines.array_bflow_source_id_num_3(Idx)
   , g_rec_lines.array_bflow_source_id_num_4(Idx)
   , g_rec_lines.array_bflow_source_id_char_1(Idx)
   , g_rec_lines.array_bflow_source_id_char_2(Idx)
   , g_rec_lines.array_bflow_source_id_char_3(Idx)
   , g_rec_lines.array_bflow_source_id_char_4(Idx)
   --
   , g_rec_lines.array_bflow_distribution_type(Idx)
   , g_rec_lines.array_bflow_dist_id_num_1(Idx)
   , g_rec_lines.array_bflow_dist_id_num_2(Idx)
   , g_rec_lines.array_bflow_dist_id_num_3(Idx)
   , g_rec_lines.array_bflow_dist_id_num_4(Idx)
   , g_rec_lines.array_bflow_dist_id_num_5(Idx)
   , g_rec_lines.array_bflow_dist_id_char_1(Idx)
   , g_rec_lines.array_bflow_dist_id_char_2(Idx)
   , g_rec_lines.array_bflow_dist_id_char_3(Idx)
   , g_rec_lines.array_bflow_dist_id_char_4(Idx)
   , g_rec_lines.array_bflow_dist_id_char_5(Idx)
   , g_rec_lines.array_bflow_applied_to_amt(Idx)  -- 5132302
   , g_rec_lines.array_override_acctd_amt_flag(Idx)
   --
   -- Allocation Attributes
   --
   , g_rec_lines.array_alloct_application_id(Idx)
   , g_rec_lines.array_alloct_entity_code(Idx)
   , g_rec_lines.array_alloct_source_id_num_1(Idx)
   , g_rec_lines.array_alloct_source_id_num_2(Idx)
   , g_rec_lines.array_alloct_source_id_num_3(Idx)
   , g_rec_lines.array_alloct_source_id_num_4(Idx)
   , g_rec_lines.array_alloct_source_id_char_1(Idx)
   , g_rec_lines.array_alloct_source_id_char_2(Idx)
   , g_rec_lines.array_alloct_source_id_char_3(Idx)
   , g_rec_lines.array_alloct_source_id_char_4(Idx)
   , g_rec_lines.array_alloct_distribution_type(Idx)
   , g_rec_lines.array_alloct_dist_id_num_1(Idx)
   , g_rec_lines.array_alloct_dist_id_num_2(Idx)
   , g_rec_lines.array_alloct_dist_id_num_3(Idx)
   , g_rec_lines.array_alloct_dist_id_num_4(Idx)
   , g_rec_lines.array_alloct_dist_id_num_5(Idx)
   , g_rec_lines.array_alloct_dist_id_char_1(Idx)
   , g_rec_lines.array_alloct_dist_id_char_2(Idx)
   , g_rec_lines.array_alloct_dist_id_char_3(Idx)
   , g_rec_lines.array_alloct_dist_id_char_4(Idx)
   , g_rec_lines.array_alloct_dist_id_char_5(Idx)
   )
  ;

  l_rowcount := SQL%ROWCOUNT;
  l_result   := ( l_rowcount> 0);

  IF (C_LEVEL_EVENT >= g_log_level) THEN
    trace
      (p_msg      => '# temporary journal lines inserted into GT xla_ae_lines_gt = '||TO_CHAR(l_rowcount)
      ,p_level    => C_LEVEL_EVENT
      ,p_module   => l_log_module);
  END IF;

END IF; --  g_rec_lines.array_line_num.COUNT > 0

IF g_transaction_accounts.array_line_num.COUNT > 0 AND l_result THEN

  FORALL Jdx IN g_transaction_accounts.array_line_num.FIRST .. g_transaction_accounts.array_line_num.LAST
    INSERT INTO xla_transaction_accts_gt
       (line_number,
        ae_header_id,
        temp_line_num,
        ledger_id,
        code_combination_id,
        segment,
        from_segment_code,
        to_segment_code,
        processing_status_code,
        side_code,
        sl_coa_mapping_id
       )
    VALUES
       (g_transaction_accounts.array_line_num(Jdx),
        g_transaction_accounts.array_ae_header_id(Jdx),
        g_transaction_accounts.array_temp_line_num(Jdx),
        XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id,
        g_transaction_accounts.array_code_combination_id(Jdx),
        g_transaction_accounts.array_segment(Jdx),
        g_transaction_accounts.array_from_segment_code(Jdx),
        g_transaction_accounts.array_to_segment_code(Jdx),
        g_transaction_accounts.array_processing_status_code(Jdx),
        g_transaction_accounts.array_side_code(Jdx),
        XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id
  )
  ;

  l_rowcount := SQL%ROWCOUNT;

  IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => '# lines inserted into xla_transaction_accts_gt = '||TO_CHAR(l_rowcount)
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);

  END IF;
  g_transaction_accounts         := l_null_trans_accounts;

ELSE
  IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'No rows to insert into xla_transaction_accts_gt'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
  END IF;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of InsertLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_result;
EXCEPTION
----Added to handle Exceptions and send to Out file  7453943------------
WHEN dml_errors THEN
   errors := SQL%BULK_EXCEPTIONS.COUNT;
   FOR i IN 1..errors LOOP
      ERR_IND:= SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
      ERR_CODE:= SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE);
      fnd_file.put_line(fnd_file.log, 'ERROR : '|| UPPER(ERR_CODE)); -- added in 12.1.1
      fnd_file.put_line(fnd_file.output, 'temp_line_num: '||g_rec_lines.array_line_num(ERR_IND));
      fnd_file.put_line(fnd_file.output, 'extract_line_num: '||g_rec_lines.array_extract_line_num(ERR_IND));
      fnd_file.put_line(fnd_file.output, 'event_id: '||g_rec_lines.array_ae_header_id(ERR_IND));
      fnd_file.put_line(fnd_file.output, 'accounting_class_code: '||g_rec_lines.array_accounting_class(ERR_IND));
      fnd_file.put_line(fnd_file.output, 'event_type_code: '||g_rec_lines.array_event_type_code(ERR_IND));
      fnd_file.put_line(fnd_file.output, 'balance_type_code: '||g_rec_lines.array_balance_type_code(ERR_IND));
  END LOOP;
--------------------------------------------------------------------------

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
      (p_location => 'XLA_AE_LINES_PKG.InsertLines');
END InsertLines;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE RefreshLines
IS
l_null_lines          t_rec_lines;
l_null_rev_line       t_rec_reverse_line;
l_null_accounts       t_rec_transaction_accounts;
l_log_module          VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.RefreshLines';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of RefreshLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

g_rec_lines                    := l_null_lines;
g_transaction_accounts         := l_null_accounts;
g_LineNumber                   := null;
g_ExtractLine                  := null;
g_ActualLineNum                := null;
g_BudgetLineNum                := null;
g_EncumbLineNum                := null;

g_reverse_lines                := l_null_rev_line;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of RefreshLines'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.RefreshLines');
END RefreshLines;
--
--
--====================================================================
--
--
--
--
--
--                    REVERSAL ACCOUNTING PROCESS
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
--====================================================================
--
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


--
--
/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION ValidateRevLinks
RETURN BOOLEAN
IS
l_log_module         VARCHAR2(240);
l_temp               NUMBER;
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateRevLinks';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of ValidateRevLinks'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- please refer to the comments in method ValidateLinks for explanation.

IF g_rec_lines.array_distribution_id_char_5(g_LineNumber) IS NULL AND
      g_rec_lines.array_distribution_id_num_5(g_LineNumber) IS NULL THEN
  l_temp := 0;
ELSE
  l_temp := 1;
END IF;
IF g_rec_lines.array_distribution_id_char_4(g_LineNumber) IS NOT NULL OR
      g_rec_lines.array_distribution_id_num_4(g_LineNumber) IS NOT NULL THEN
  l_temp := 2+l_temp;
END IF;
IF g_rec_lines.array_distribution_id_char_3(g_LineNumber) IS NOT NULL OR
      g_rec_lines.array_distribution_id_num_3(g_LineNumber) IS NOT NULL THEN
  l_temp := 4+l_temp;
END IF;
IF g_rec_lines.array_distribution_id_char_2(g_LineNumber) IS NOT NULL OR
      g_rec_lines.array_distribution_id_num_2(g_LineNumber) IS NOT NULL THEN
  l_temp := 8+l_temp;
END IF;
IF g_rec_lines.array_sys_distribution_type(g_LineNumber) IS NULL
   OR (g_rec_lines.array_distribution_id_char_1(g_LineNumber) IS NULL AND
      g_rec_lines.array_distribution_id_num_1(g_LineNumber) IS NULL)
   OR   l_temp not in (0, 8, 12, 14, 15) THEN

    xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
    xla_accounting_err_pkg.build_message
                                  (p_appli_s_name            => 'XLA'
                                  ,p_msg_name                => 'XLA_AP_NO_DIST_LINK_ID'
                                  ,p_token_1                 => 'LINE_NUMBER'
                                  ,p_value_1                 =>  g_ExtractLine
                                  ,p_token_2                 => 'LINE_TYPE_NAME'
                                  ,p_value_2                 => 'Accounting Reversal'
                                  ,p_token_3                 => 'OWNER'
                                  ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                      p_lookup_type    => 'XLA_OWNER_TYPE'
                                                                    , p_lookup_code    => 'S'
                                                                    )
                                  ,p_token_4                 => 'PRODUCT_NAME'
                                  ,p_value_4                 => 'Subledger Accounting Architecture'
                                  ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                                  ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                                  ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                         );

     IF (C_LEVEL_ERROR >= g_log_level) THEN
                        trace
                           (p_msg      => 'ERROR: XLA_AP_NO_DIST_LINK_ID'
                           ,p_level    => C_LEVEL_ERROR
                           ,p_module   => l_log_module);
     END IF;

     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
           trace
              (p_msg      => 'return value. = FALSE'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);
           trace
              (p_msg      => 'END of ValidateRevLinks'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);

     END IF;
     RETURN FALSE;
ELSE
-- please refer to the comments in method ValidateLinks for explanation.

  IF g_rec_lines.array_rev_dist_id_char_5(g_LineNumber) IS NULL AND
        g_rec_lines.array_rev_dist_id_num_5(g_LineNumber) IS NULL THEN
    l_temp := 0;
  ELSE
    l_temp := 1;
  END IF;
  IF g_rec_lines.array_rev_dist_id_char_4(g_LineNumber) IS NOT NULL OR
        g_rec_lines.array_rev_dist_id_num_4(g_LineNumber) IS NOT NULL THEN
    l_temp := 2+l_temp;
  END IF;
  IF g_rec_lines.array_rev_dist_id_char_3(g_LineNumber) IS NOT NULL OR
        g_rec_lines.array_rev_dist_id_num_3(g_LineNumber) IS NOT NULL THEN
    l_temp := 4+l_temp;
  END IF;
  IF g_rec_lines.array_rev_dist_id_char_2(g_LineNumber) IS NOT NULL OR
        g_rec_lines.array_rev_dist_id_num_2(g_LineNumber) IS NOT NULL THEN
    l_temp := 8+l_temp;
  END IF;
  IF g_rec_lines.array_rev_dist_type(g_LineNumber) IS NULL
     OR (g_rec_lines.array_rev_dist_id_char_1(g_LineNumber) IS NULL AND
        g_rec_lines.array_rev_dist_id_num_1(g_LineNumber) IS NULL)
     OR   l_temp not in (0, 8, 12, 14, 15) THEN

      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
      xla_accounting_err_pkg.build_message
                                  (p_appli_s_name            => 'XLA'
                                  ,p_msg_name                => 'XLA_AP_NO_REV_DIST_LINK_ID'
                                  ,p_token_1                 => 'LINE_NUMBER'
                                  ,p_value_1                 =>  g_ExtractLine
                                  ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                                  ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                                  ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                         );

       IF (C_LEVEL_ERROR >= g_log_level) THEN
                        trace
                           (p_msg      => 'ERROR: XLA_AP_NO_REV_DIST_LINK_ID'
                           ,p_level    => C_LEVEL_ERROR
                           ,p_module   => l_log_module);
       END IF;

       IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
           trace
              (p_msg      => 'return value. = FALSE'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);
           trace
              (p_msg      => 'END of ValidateRevLinks'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);

       END IF;
       RETURN FALSE;
  ELSE
     IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
           trace
              (p_msg      => 'return value. = TRUE'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);
           trace
              (p_msg      => 'END of ValidateRevLinks'
              ,p_level    => C_LEVEL_PROCEDURE
              ,p_module   => l_log_module);

     END IF;
     RETURN TRUE;
  END IF;
END IF;


EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'xla_ae_lines_pkg.ValidateRevLinks');
  --
END ValidateRevLinks;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/

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
PROCEDURE AccountingReversal (
  p_accounting_mode      IN VARCHAR2
) IS

l_log_module         VARCHAR2(240);
l_array_event_id                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_ledger_id                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_source_dist_id_num_1         XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_source_dist_id_num_2         XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_source_dist_id_num_3         XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_source_dist_id_num_4         XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_source_dist_id_num_5         XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_source_dist_id_char_1        XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_source_dist_id_char_2        XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_source_dist_id_char_3        XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_source_dist_id_char_4        XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_source_dist_id_char_5        XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_source_dist_type             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_rev_dist_id_num_1            XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_rev_dist_id_num_2            XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_rev_dist_id_num_3            XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_rev_dist_id_num_4            XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_rev_dist_id_num_5            XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_rev_dist_id_char_1           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_rev_dist_id_char_2           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_rev_dist_id_char_3           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_rev_dist_id_char_4           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_rev_dist_id_char_5           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_rev_dist_type                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;

l_array_balance_type_code            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L;
l_array_entry_status_code            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L;
l_array_event_number                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_entity_id                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_header_num                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;    -- 4262811c MPA header for Line reversal
l_array_switch_side_flag             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L;    -- 5055878 Reversal method. Y=SIDE, N=SIGN
l_array_tax_line_ref                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;  -- bug 7159711
l_array_tax_summary_line_ref         XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;  -- bug 7159711
l_array_tax_rec_nrec_dist_ref        XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;  -- bug 7159711

l_application_id                     NUMBER;

-- 5086984 Performance fix
l_array_mpa_acc_ledger_id            XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_mpa_acc_event_id             XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_mpa_acc_ref_ae_header        XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_mpa_acc_temp_line_num        XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_mpa_acc_ae_header_id         XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_mpa_acc_header_num           XLA_AE_JOURNAL_ENTRY_PKG.t_array_num;
l_array_mpa_acc_balance_type         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L;

l_array_gl_date                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_date;  -- 5189664
l_array_accounting_date              XLA_AE_JOURNAL_ENTRY_PKG.t_array_date;  -- 8505463

l_default_switch_side_flag           CHAR(1);
l_ledger_attrs                       XLA_ACCOUNTING_CACHE_PKG.t_array_ledger_attrs;   --7135700
l_upgrade_check                      NUMBER  DEFAULT 0;                               --7135700
l_primary_ledger_id                  NUMBER;                                          --7135700
l_max_first_open_period              DATE   DEFAULT NULL;                             --7135700
l_min_ref_event_date                 DATE   DEFAULT NULL;                             --7135700
l_error_count                        NUMBER DEFAULT 0;                                --7135700 + 7253269



BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AccountingReversal';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of AccountingReversal'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Performing line level accounting reversal'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

  l_application_id :=  xla_accounting_cache_pkg.getvaluenum('XLA_EVENT_APPL_ID');

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace
        (p_msg      => 'Application ID ='||to_char(l_application_id)
        ,p_level    => C_LEVEL_STATEMENT
        ,p_module   => l_log_module);
     trace -- 5412560
        (p_msg      => 'MPA Line Reversal exists = '||xla_accounting_pkg.g_mpa_accrual_exists
        ,p_level    => C_LEVEL_STATEMENT
        ,p_module   => l_log_module);
  END IF;

  ----------------------------------------
  -- 5108415 Incomplete MPA
  ----------------------------------------
  g_incomplete_mpa_acc_LR := NULL;
  g_incomplete_mpa_acc_TR := NULL;


--***************************************************************************************************************
--***************************************************************************************************************
--*******************    L I N E      R E V E R S A L    ********************************************************
--***************************************************************************************************************
--***************************************************************************************************************

   --
   -- selecting all the dummy lines from xla_ae_lines_gt that are due to
   -- line level reversal option
   --
   SELECT event_id
         ,ledger_id
         ,event_number
         ,entity_id
         ,source_distribution_type
         ,source_distribution_id_num_1
         ,source_distribution_id_num_2
         ,source_distribution_id_num_3
         ,source_distribution_id_num_4
         ,source_distribution_id_num_5
         ,source_distribution_id_char_1
         ,source_distribution_id_char_2
         ,source_distribution_id_char_3
         ,source_distribution_id_char_4
         ,source_distribution_id_char_5
         ,reverse_distribution_type
         ,reverse_dist_id_num_1
         ,reverse_dist_id_num_2
         ,reverse_dist_id_num_3
         ,reverse_dist_id_num_4
         ,reverse_dist_id_num_5
         ,reverse_dist_id_char_1
         ,reverse_dist_id_char_2
         ,reverse_dist_id_char_3
         ,reverse_dist_id_char_4
         ,reverse_dist_id_char_5
         ,switch_side_flag        -- 5055878
         ,accounting_date         -- 5189664
         ,tax_line_ref_id            -- 7159711
         ,tax_summary_line_ref_id    -- 7159711
         ,tax_rec_nrec_dist_ref_id   -- 7159711
     BULK COLLECT INTO
          l_array_event_id
         ,l_array_ledger_id
         ,l_array_event_number
         ,l_array_entity_id
         ,l_array_source_dist_type
         ,l_array_source_dist_id_num_1
         ,l_array_source_dist_id_num_2
         ,l_array_source_dist_id_num_3
         ,l_array_source_dist_id_num_4
         ,l_array_source_dist_id_num_5
         ,l_array_source_dist_id_char_1
         ,l_array_source_dist_id_char_2
         ,l_array_source_dist_id_char_3
         ,l_array_source_dist_id_char_4
         ,l_array_source_dist_id_char_5
         ,l_array_rev_dist_type
         ,l_array_rev_dist_id_num_1
         ,l_array_rev_dist_id_num_2
         ,l_array_rev_dist_id_num_3
         ,l_array_rev_dist_id_num_4
         ,l_array_rev_dist_id_num_5
         ,l_array_rev_dist_id_char_1
         ,l_array_rev_dist_id_char_2
         ,l_array_rev_dist_id_char_3
         ,l_array_rev_dist_id_char_4
         ,l_array_rev_dist_id_char_5
         ,l_array_switch_side_flag     -- 5055878
         ,l_array_gl_date              -- 5189664
         ,l_array_tax_line_ref           -- 7159711
         ,l_array_tax_summary_line_ref   -- 7159711
         ,l_array_tax_rec_nrec_dist_ref  -- 7159711
     FROM xla_ae_lines_gt
    WHERE reversal_code = 'DUMMY_LR'
    ORDER by entity_id, event_number;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Line Reversal - Extract lines with reversal option set to Y = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   --=======================================================================================================
   -- 4669308 Delete the MPA/Accrual Line Reversal (still in GT ables, not in distribution links yet)
   --=======================================================================================================
   --
   ---------------------------------------------------------------------------------------------------------
   -- 4669308 Delete the MPA/Accrual Line Reversal in xla_ae_lines_gt (not in distribution links yet)
   ---------------------------------------------------------------------------------------------------------
   --
   IF xla_accounting_pkg.g_mpa_accrual_exists = 'Y' THEN  -- 5412560
      -- Modify for performance bug 5086984
      FOR i IN 1..l_array_entity_id.count LOOP
         SELECT /*+ Leading(HGT) cardinality(hgt 1) index(lgt XLA_AE_LINES_GT_U1) */
                lgt.ledger_id
               ,lgt.event_id
               ,lgt.ref_ae_header_id
               ,lgt.temp_line_num
               ,lgt.ae_header_id
               ,lgt.header_num
               ,lgt.balance_type_code
         BULK COLLECT INTO
                l_array_mpa_acc_ledger_id
               ,l_array_mpa_acc_event_id
               ,l_array_mpa_acc_ref_ae_header
               ,l_array_mpa_acc_temp_line_num
               ,l_array_mpa_acc_ae_header_id
               ,l_array_mpa_acc_header_num
               ,l_array_mpa_acc_balance_type
         FROM   xla_ae_lines_gt   lgt
               ,xla_ae_headers_gt hgt
         WHERE l_array_ledger_id(i)                   = lgt.ledger_id
           AND l_array_rev_dist_type(i)               = lgt.source_distribution_type
           AND nvl(l_array_rev_dist_id_num_1(i),-99)  = nvl(lgt.source_distribution_id_num_1,-99)
           AND nvl(l_array_rev_dist_id_num_2(i),-99)  = nvl(lgt.source_distribution_id_num_2,-99)
           AND nvl(l_array_rev_dist_id_num_3(i),-99)  = nvl(lgt.source_distribution_id_num_3,-99)
           AND nvl(l_array_rev_dist_id_num_4(i),-99)  = nvl(lgt.source_distribution_id_num_4,-99)
           AND nvl(l_array_rev_dist_id_num_5(i),-99)  = nvl(lgt.source_distribution_id_num_5,-99)
           AND nvl(l_array_rev_dist_id_char_1(i),' ') = nvl(lgt.source_distribution_id_char_1,' ')
           AND nvl(l_array_rev_dist_id_char_2(i),' ') = nvl(lgt.source_distribution_id_char_2,' ')
           AND nvl(l_array_rev_dist_id_char_3(i),' ') = nvl(lgt.source_distribution_id_char_3,' ')
           AND nvl(l_array_rev_dist_id_char_4(i),' ') = nvl(lgt.source_distribution_id_char_4,' ')
           AND nvl(l_array_rev_dist_id_char_5(i),' ') = nvl(lgt.source_distribution_id_char_5,' ')
           AND lgt.reversal_code IS NULL        -- the lines created form revesal are not reversed again
            -- 5412560 replacement
           AND NVL(lgt.header_num,0) > 0
           AND lgt.header_num          = hgt.header_num
           AND hgt.event_id            = lgt.event_id
           AND hgt.ledger_id           = lgt.ledger_id
           AND hgt.balance_type_code   = lgt.balance_type_code
           AND hgt.ae_header_id        = lgt.ae_header_id
           AND hgt.entity_id           = l_array_entity_id(i)
           AND hgt.event_number        < l_array_event_number(i);
           /* 5412560 replaced
           AND NOT EXISTS (                     -- the lines already reversed are not reversed again
                      SELECT 1
                      FROM xla_ae_lines_gt
                      WHERE ledger_id        = lgt.ledger_id
                        AND ref_ae_header_id = lgt.ref_ae_header_id
                        AND temp_line_num    = lgt.temp_line_num * -1)
           AND NVL(lgt.header_num,0) > 0
           AND lgt.header_num          = hgt.header_num
           AND hgt.event_id            = lgt.event_id
           AND hgt.ledger_id           = lgt.ledger_id
           AND hgt.balance_type_code   = lgt.balance_type_code
           AND hgt.entity_id           = l_array_entity_id(i)
           AND hgt.event_number        < l_array_event_number(i);
           */

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN  -- 5412560
               trace
               (p_msg      => 'MPA Line Reversal entity='||l_array_entity_id(i)||
                              ' count = '||l_array_mpa_acc_ae_header_id.COUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            for a in 1..l_array_mpa_acc_ae_header_id.count loop
               trace
               (p_msg      => 'MPA Line Reversal ledger='||l_array_mpa_acc_ledger_id(a)||
                              ' ref_header='||l_array_mpa_acc_ref_ae_header(a)||
                              ' line='||l_array_mpa_acc_temp_line_num(a)||
                              '  header='||l_array_mpa_acc_ae_header_id(a)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
            end loop;
         END IF;

         ---------------------------------------------------------------------------------------------------------
         -- 4669308 Delete the MPA/Accrual Line Reversal in xla_ae_lines_gt (not in distribution links yet)
         ---------------------------------------------------------------------------------------------------------
         FORALL j IN 1..l_array_mpa_acc_ae_header_id.count
            DELETE xla_ae_lines_gt
            WHERE  ledger_id        = l_array_mpa_acc_ledger_id(j)
            AND    ref_ae_header_id = l_array_mpa_acc_ref_ae_header(j)
            AND    temp_line_num    = l_array_mpa_acc_temp_line_num(j)
            AND    ae_header_id     = l_array_mpa_acc_ae_header_id(j)
            AND    header_num       = l_array_mpa_acc_header_num(j);

         ---------------------------------------------------------------------------------------------------------
         -- 4669308 Delete the MPA/Accrual Line Reversal in xla_ae_headers_gt (not in distribution links yet)
         ---------------------------------------------------------------------------------------------------------
         FORALL j IN 1..l_array_mpa_acc_event_id.count
            DELETE xla_ae_headers_gt
            WHERE  ledger_id         = l_array_mpa_acc_ledger_id(j)
            AND    event_id          = l_array_mpa_acc_event_id(j)
            AND    ae_header_id      = l_array_mpa_acc_ae_header_id(j)
            AND    balance_type_code = l_array_mpa_acc_balance_type(j)
            AND    header_num        = l_array_mpa_acc_header_num(j);

      END LOOP;
      --
   END IF; -- xla_accounting_pkg.g_mpa_accrual_exists = 'Y'
   -------------------------------------------------------------------------------------------------------------------------
   /****** CHANGES FOR MPA CANCELLATION  *******/
  /*    ACCOUNTING BOTH ORIGINAL AND MPA/ACCRUAL REVERSAL PRIOR TO CANCELLATION DATE
 	                                   IS REVERSED ON THE CANCELLATION DATE.
 	       FUTURE PERIODS FINAL ACCOUNTED DATA WOULD BE REVERSED WITH THE RESPECTIVE
 	                                   FUTURE ACCOUNTING DATES.

  NOTE: Changes have been done only for Cancellation from XLA_AE_LINES and not LINES_GT as the
        MPA/Accrual Reversal data is deleted from above when Original and cancellation Event
        are accounted in the same Run.
  */
   --
      -- reverse the lines in xla_ae_lines_gt table (not in distribution links yet)
   --
   INSERT INTO xla_ae_lines_gt
      (ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,ledger_id
      ,balance_type_code
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,sl_coa_mapping_name
      ,dynamic_insert_flag
      ,source_coa_id
      ,ccid_coa_id
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,DOC_ROUNDING_ACCTD_AMT
      ,DOC_ROUNDING_ENTERED_AMT
      ,alt_ccid_status_code
      ,alt_code_combination_id
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
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,switch_side_flag
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,source_distribution_id_char_1
      ,source_distribution_id_char_2
      ,source_distribution_id_char_3
      ,source_distribution_id_char_4
      ,source_distribution_id_char_5
      ,source_distribution_id_num_1
      ,source_distribution_id_num_2
      ,source_distribution_id_num_3
      ,source_distribution_id_num_4
      ,source_distribution_id_num_5
      ,source_distribution_type
      ,reverse_dist_id_char_1
      ,reverse_dist_id_char_2
      ,reverse_dist_id_char_3
      ,reverse_dist_id_char_4
      ,reverse_dist_id_char_5
      ,reverse_dist_id_num_1
      ,reverse_dist_id_num_2
      ,reverse_dist_id_num_3
      ,reverse_dist_id_num_4
      ,reverse_dist_id_num_5
      ,reverse_distribution_type
      ,tax_line_ref_id
      ,tax_summary_line_ref_id
      ,tax_rec_nrec_dist_ref_id
      -- 4262811
      ,header_num
      ,mpa_accrual_entry_flag
      ,multiperiod_option_flag
      ,multiperiod_start_date
      ,multiperiod_end_date
      ,reversal_code
      ,inherit_desc_flag              -- 4219869
      ,encumbrance_type_id            -- 4458381
      ,accounting_entry_status_code
      ,accounting_date
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
 , alloc_to_dist_id_num_5    -- 4955764
  , analytical_balance_flag  -- Bug 7382288
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
 , anc_id_100)
  (SELECT
       ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,ledger_id
      ,balance_type_code
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,sl_coa_mapping_name
      ,dynamic_insert_flag
      ,source_coa_id
      ,ccid_coa_id
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,doc_rounding_acctd_amt
      ,doc_rounding_entered_amt
      ,alt_ccid_status_code
      ,alt_code_combination_id
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
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,switch_side_flag
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,source_distribution_id_char_1
      ,source_distribution_id_char_2
      ,source_distribution_id_char_3
      ,source_distribution_id_char_4
      ,source_distribution_id_char_5
      ,source_distribution_id_num_1
      ,source_distribution_id_num_2
      ,source_distribution_id_num_3
      ,source_distribution_id_num_4
      ,source_distribution_id_num_5
      ,source_distribution_type
      ,reverse_dist_id_char_1
      ,reverse_dist_id_char_2
      ,reverse_dist_id_char_3
      ,reverse_dist_id_char_4
      ,reverse_dist_id_char_5
      ,reverse_dist_id_num_1
      ,reverse_dist_id_num_2
      ,reverse_dist_id_num_3
      ,reverse_dist_id_num_4
      ,reverse_dist_id_num_5
      ,reverse_distribution_type
      ,tax_line_ref_id
      ,tax_summary_line_ref_id
      ,tax_rec_nrec_dist_ref_id
      ,header_num
      ,mpa_accrual_entry_flag
      ,multiperiod_option_flag
      ,multiperiod_start_date
      ,multiperiod_end_date
      ,reversal_code
      ,inherit_desc_flag
      ,encumbrance_type_id
      ,accounting_entry_status_code
      ,accounting_date
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
 , analytical_balance_flag  -- Bug 7382288 Included analytical criteria
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
    FROM
     (SELECT /*+ ORDERED USE_HASH(lgt2) USE_NL(hgt) */
         -- populates ae_header_id which is same as event_id till this point
          lgt1.event_id                                AE_HEADER_ID
         -- populates temp_line_num which is (-ve) of original line
         ,0-lgt2.temp_line_num                         TEMP_LINE_NUM
         -- populates event_id which is the event_id of event under process
         ,lgt1.event_id                                EVENT_ID
         -- populates ref_ae_header_id which is ae_header_id of original line
         ,hgt.ae_header_id                             REF_AE_HEADER_ID
         -- populates ref_ae_line_num which is ae_line_num of original line
         ,lgt2.ae_line_num                             REF_AE_LINE_NUM
         -- populates ref_temp_line_num which is ae_line_num of original line
         ,lgt2.temp_line_num                           REF_TEMP_LINE_NUM
         -- populates ref_event_id which is event_id of original line
         ,0-lgt2.event_id                                REF_EVENT_ID  -- REF_EVENT_ID made negative for Bug:8277823
         ,lgt2.ledger_id                               LEDGER_ID
         ,lgt2.balance_type_code                       BALANCE_TYPE_CODE
         ,lgt2.accounting_class_code                   ACCOUNTING_CLASS_CODE
         ,lgt2.event_class_code                        EVENT_CLASS_CODE
         ,lgt2.event_type_code                         EVENT_TYPE_CODE
         ,lgt2.line_definition_owner_code              LINE_DEFINITION_OWNER_CODE
         ,lgt2.line_definition_code                    LINE_DEFINITION_CODE
         ,lgt2.accounting_line_type_code               ACCOUNTING_LINE_TYPE_CODE
         ,lgt2.accounting_line_code                    ACCOUNTING_LINE_CODE
                  ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y'
                ,lgt2.alt_ccid_status_code,lgt2.code_combination_status_code)
         ,lgt2.code_combination_status_code)
                                                       CODE_COMBINATION_STATUS_CODE
         ,decode(lgt2.gain_or_loss_flag, 'Y'
            ,decode(lgt2.calculate_g_l_amts_flag,'Y'
                ,lgt2.alt_code_combination_id, lgt2.code_combination_id)
        , lgt2.code_combination_id)
                                                       CODE_COMBINATION_ID
         ,lgt2.sl_coa_mapping_name                    SL_COA_MAPPING_NAME
         ,lgt2.dynamic_insert_flag                     DYNAMIC_INSERT_FLAG
         ,lgt2.source_coa_id                           SOURCE_COA_ID
         ,lgt2.ccid_coa_id                             CCID_COA_ID
         ,lgt2.calculate_acctd_amts_flag               CALCULATE_ACCTD_AMTS_FLAG
         ,lgt2.calculate_g_l_amts_flag                 CALCULATE_G_L_AMTS_FLAG
         ,lgt2.gain_or_loss_flag                       GAIN_OR_LOSS_FLAG
         ,lgt2.rounding_class_code                     ROUNDING_CLASS_CODE
         ,lgt2.document_rounding_level                 DOCUMENT_ROUNDING_LEVEL
         ,lgt2.doc_rounding_acctd_amt                  DOC_ROUNDING_ACCTD_AMT
         ,lgt2.doc_rounding_entered_amt                DOC_ROUNDING_ENTERED_AMT
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.code_combination_status_code ,lgt2.alt_ccid_status_code)
                                                       ALT_CCID_STATUS_CODE
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.code_combination_id ,lgt2.alt_code_combination_id)
                                                       ALT_CODE_COMBINATION_ID
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment1,lgt2.alt_segment1)     ALT_SEGMENT1
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment2,lgt2.alt_segment2)     ALT_SEGMENT2
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment3,lgt2.alt_segment3)     ALT_SEGMENT3
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment4,lgt2.alt_segment4)     ALT_SEGMENT4
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment5,lgt2.alt_segment5)     ALT_SEGMENT5
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment6,lgt2.alt_segment6)     ALT_SEGMENT6
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment7,lgt2.alt_segment7)     ALT_SEGMENT7
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment8,lgt2.alt_segment8)     ALT_SEGMENT8
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment9,lgt2.alt_segment9)     ALT_SEGMENT9
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment10,lgt2.alt_segment10)   ALT_SEGMENT10
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment11,lgt2.alt_segment11)   ALT_SEGMENT11
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment12,lgt2.alt_segment12)   ALT_SEGMENT12
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment13,lgt2.alt_segment13)   ALT_SEGMENT13
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment14,lgt2.alt_segment14)   ALT_SEGMENT14
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment15,lgt2.alt_segment15)   ALT_SEGMENT15
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment16,lgt2.alt_segment16)   ALT_SEGMENT16
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment17,lgt2.alt_segment17)   ALT_SEGMENT17
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment18,lgt2.alt_segment18)   ALT_SEGMENT18
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment19,lgt2.alt_segment19)   ALT_SEGMENT19
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment20,lgt2.alt_segment20)   ALT_SEGMENT20
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment21,lgt2.alt_segment21)   ALT_SEGMENT21
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment22,lgt2.alt_segment22)   ALT_SEGMENT22
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment23,lgt2.alt_segment23)   ALT_SEGMENT23
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment24,lgt2.alt_segment24)   ALT_SEGMENT24
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment25,lgt2.alt_segment25)   ALT_SEGMENT25
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment26,lgt2.alt_segment26)   ALT_SEGMENT26
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment27,lgt2.alt_segment27)   ALT_SEGMENT27
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment28,lgt2.alt_segment28)   ALT_SEGMENT28
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment29,lgt2.alt_segment29)   ALT_SEGMENT29
         ,decode(lgt2.gain_or_loss_flag, 'Y', lgt2.segment30,lgt2.alt_segment30)   ALT_SEGMENT30
         ,decode(lgt2.gain_or_loss_flag, 'Y'
         ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment1,lgt2.segment1)
         ,lgt2.segment1)                                                   SEGMENT1
         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment2,lgt2.segment2)
         ,lgt2.segment2)                                                   SEGMENT2

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment3,lgt2.segment3)
         ,lgt2.segment3)                                                   SEGMENT3

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment4,lgt2.segment4)
         ,lgt2.segment4)                                                     SEGMENT4

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment5,lgt2.segment5)
         ,lgt2.segment5)                                                   SEGMENT5

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment6,lgt2.segment6)
         ,lgt2.segment6)                                                   SEGMENT6

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment7,lgt2.segment7)
         ,lgt2.segment7)                                                  SEGMENT7

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment8,lgt2.segment8)
         ,lgt2.segment8)                                                   SEGMENT8

         ,decode(lgt2.gain_or_loss_flag, 'Y'
                ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment9,lgt2.segment9)
         ,lgt2.segment9)                                                   SEGMENT9

         ,decode(lgt2.gain_or_loss_flag, 'Y'
              ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment10,lgt2.segment10)
         ,lgt2.segment10)                                                   SEGMENT10

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment11,lgt2.segment11)
         ,lgt2.segment11)                                                   SEGMENT11

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment12,lgt2.segment12)
         ,lgt2.segment12)                                                   SEGMENT12

         ,decode(lgt2.gain_or_loss_flag, 'Y'
               ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment13,lgt2.segment13)
         ,lgt2.segment13)                                                   SEGMENT13

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment14,lgt2.segment14)
         ,lgt2.segment14)                                                   SEGMENT14

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment15,lgt2.segment15)
         ,lgt2.segment15)                                                   SEGMENT15

         ,decode(lgt2.gain_or_loss_flag, 'Y'
              ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment16,lgt2.segment16)
         ,lgt2.segment16)                                                   SEGMENT16

         ,decode(lgt2.gain_or_loss_flag, 'Y'
              ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment17,lgt2.segment17)
         ,lgt2.segment17)                                                   SEGMENT17

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment18,lgt2.segment18)
         ,lgt2.segment18)                                                   SEGMENT18

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment19,lgt2.segment19)
         ,lgt2.segment19)                                                   SEGMENT19

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment20,lgt2.segment20)
         ,lgt2.segment20)                                                  SEGMENT20

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment21,lgt2.segment21)
         ,lgt2.segment21)                                                   SEGMENT21

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment22,lgt2.segment22)
         ,lgt2.segment22)                                                   SEGMENT22

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment23,lgt2.segment23)
         ,lgt2.segment23)                                                   SEGMENT23

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment24,lgt2.segment24)
         ,lgt2.segment24)                                                   SEGMENT24

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment25,lgt2.segment25)
         ,lgt2.segment25)                                                   SEGMENT25

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment26,lgt2.segment26)
         ,lgt2.segment26)                                                   SEGMENT26

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment27,lgt2.segment27)
         ,lgt2.segment27)                                                   SEGMENT27

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment28,lgt2.segment28)
         ,lgt2.segment28)                                                  SEGMENT28

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment29,lgt2.segment29)
         ,lgt2.segment29)                                                   SEGMENT29

         ,decode(lgt2.gain_or_loss_flag, 'Y'
             ,decode(lgt2.calculate_g_l_amts_flag,'Y',lgt2.alt_segment30,lgt2.segment30)
         ,lgt2.segment30)                                                   SEGMENT30
         ,lgt2.description                             DESCRIPTION
         ,lgt2.gl_transfer_mode_code                   GL_TRANSFER_MODE_CODE
         ,lgt2.merge_duplicate_code                    MERGE_DUPLICATE_CODE
         ,decode(lgt2.gain_or_loss_flag, 'Y', decode(lgt2.calculate_g_l_amts_flag, 'Y', 'Y', 'N'), lgt1.switch_side_flag)
                                                       SWITCH_SIDE_FLAG -- bug:7337288 changed lgt2 to lgt1 for switch side flag
         -- 5055878 amounts modified for reversal method of SIDE or SIGN
         ,DECODE(lgt1.switch_side_flag,'Y',lgt2.unrounded_entered_cr,  -lgt2.unrounded_entered_dr)       UNROUNDED_ENTERED_DR
         ,DECODE(lgt1.switch_side_flag,'Y',lgt2.unrounded_entered_dr,  -lgt2.unrounded_entered_cr)       UNROUNDED_ENTERED_CR
         ,DECODE(lgt1.switch_side_flag,'Y',lgt2.unrounded_accounted_cr,-lgt2.unrounded_accounted_dr)     UNROUNDED_ACCOUNTED_DR
         ,DECODE(lgt1.switch_side_flag,'Y',lgt2.unrounded_accounted_dr,-lgt2.unrounded_accounted_cr)     UNROUNDED_ACCOUNTED_CR
         --
         ,lgt2.entered_currency_mau                    ENTERED_CURRENCY_MAU
         ,lgt2.currency_code                           CURRENCY_CODE
         ,lgt2.currency_conversion_date                CURRENCY_CONVERSION_DATE
         ,lgt2.currency_conversion_rate                CURRENCY_CONVERSION_RATE
         ,lgt2.currency_conversion_type                CURRENCY_CONVERSION_TYPE
         ,lgt2.statistical_amount                      STATISTICAL_AMOUNT
         ,lgt2.party_id                                PARTY_ID
         ,lgt2.party_site_id                           PARTY_SITE_ID
         ,lgt2.party_type_code                         PARTY_TYPE_CODE
         ,lgt2.ussgl_transaction_code                  USSGL_TRANSACTION_CODE
         ,lgt2.jgzz_recon_ref                          JGZZ_RECON_REF
         ,lgt1.source_distribution_id_char_1           SOURCE_DISTRIBUTION_ID_CHAR_1
         ,lgt1.source_distribution_id_char_2           SOURCE_DISTRIBUTION_ID_CHAR_2
         ,lgt1.source_distribution_id_char_3           SOURCE_DISTRIBUTION_ID_CHAR_3
         ,lgt1.source_distribution_id_char_4           SOURCE_DISTRIBUTION_ID_CHAR_4
         ,lgt1.source_distribution_id_char_5           SOURCE_DISTRIBUTION_ID_CHAR_5
         ,lgt1.source_distribution_id_num_1            SOURCE_DISTRIBUTION_ID_NUM_1
         ,lgt1.source_distribution_id_num_2            SOURCE_DISTRIBUTION_ID_NUM_2
         ,lgt1.source_distribution_id_num_3            SOURCE_DISTRIBUTION_ID_NUM_3
         ,lgt1.source_distribution_id_num_4            SOURCE_DISTRIBUTION_ID_NUM_4
         ,lgt1.source_distribution_id_num_5            SOURCE_DISTRIBUTION_ID_NUM_5
         ,lgt1.source_distribution_type                SOURCE_DISTRIBUTION_TYPE
         ,lgt2.source_distribution_id_char_1           REVERSE_DIST_ID_CHAR_1
         ,lgt2.source_distribution_id_char_2           REVERSE_DIST_ID_CHAR_2
         ,lgt2.source_distribution_id_char_3           REVERSE_DIST_ID_CHAR_3
         ,lgt2.source_distribution_id_char_4           REVERSE_DIST_ID_CHAR_4
         ,lgt2.source_distribution_id_char_5           REVERSE_DIST_ID_CHAR_5
         ,lgt2.source_distribution_id_num_1            REVERSE_DIST_ID_NUM_1
         ,lgt2.source_distribution_id_num_2            REVERSE_DIST_ID_NUM_2
         ,lgt2.source_distribution_id_num_3            REVERSE_DIST_ID_NUM_3
         ,lgt2.source_distribution_id_num_4            REVERSE_DIST_ID_NUM_4
         ,lgt2.source_distribution_id_num_5            REVERSE_DIST_ID_NUM_5
         ,lgt2.source_distribution_type                REVERSE_DISTRIBUTION_TYPE
         ,nvl(lgt1.tax_line_ref_id,lgt2.tax_line_ref_id)                   TAX_LINE_REF_ID          -- bug 7159711
         ,nvl(lgt1.tax_summary_line_ref_id,lgt2.tax_summary_line_ref_id)   TAX_SUMMARY_LINE_REF_ID  -- bug 7159711
         ,nvl(lgt1.tax_rec_nrec_dist_ref_id,lgt2.tax_rec_nrec_dist_ref_id) TAX_REC_NREC_DIST_REF_ID -- bug 7159711
         ,NVL(lgt2.header_num,0)                       HEADER_NUM
         ,lgt2.mpa_accrual_entry_flag                  MPA_ACCRUAL_ENTRY_FLAG
         ,lgt2.multiperiod_option_flag                 MULTIPERIOD_OPTION_FLAG
         ,lgt2.multiperiod_start_date                  MULTIPERIOD_START_DATE
         ,lgt2.multiperiod_end_date                    MULTIPERIOD_END_DATE
         -- populate reversal_code indicating that line is result of reversal
         ,'REVERSAL'                                   REVERSAL_CODE
         ,'N'                                          INHERIT_DESC_FLAG
         ,lgt2.encumbrance_type_id                     ENCUMBRANCE_TYPE_ID
         -- denormalises entry status from headers to line to determine the status of entry being created
         ,hgt.accounting_entry_status_code             ACCOUNTING_ENTRY_STATUS_CODE
         ,lgt1.accounting_date                         ACCOUNTING_DATE
         -- the following assigns duplicate rownum to reversal lines created from same
         -- original line. This is used to filter duplicate rows in the outer query.
         ,row_number() over
              (partition by lgt2.ref_ae_header_Id, lgt2.ledger_id,lgt2.temp_line_num
                   order by lgt1.event_number
              ) rn
 , lgt2.BFLOW_APPLICATION_ID
        , lgt2.BFLOW_ENTITY_CODE
        , lgt2.APPLIED_TO_ENTITY_ID
        , lgt2.BFLOW_SOURCE_ID_NUM_1
        , lgt2.BFLOW_SOURCE_ID_NUM_2
        , lgt2.BFLOW_SOURCE_ID_NUM_3
        , lgt2.BFLOW_SOURCE_ID_NUM_4
        , lgt2.BFLOW_SOURCE_ID_CHAR_1
        , lgt2.BFLOW_SOURCE_ID_CHAR_2
        , lgt2.BFLOW_SOURCE_ID_CHAR_3
        , lgt2.BFLOW_SOURCE_ID_CHAR_4
        , lgt2.BFLOW_DISTRIBUTION_TYPE
        , lgt2.BFLOW_DIST_ID_NUM_1
        , lgt2.BFLOW_DIST_ID_NUM_2
        , lgt2.BFLOW_DIST_ID_NUM_3
        , lgt2.BFLOW_DIST_ID_NUM_4
        , lgt2.BFLOW_DIST_ID_NUM_5
        , lgt2.BFLOW_DIST_ID_CHAR_1
        , lgt2.BFLOW_DIST_ID_CHAR_2
        , lgt2.BFLOW_DIST_ID_CHAR_3
        , lgt2.BFLOW_DIST_ID_CHAR_4
        , lgt2.BFLOW_DIST_ID_CHAR_5
 , lgt2.alloc_to_application_id     alloc_to_application_id
 , lgt2.alloc_to_entity_code        alloc_to_entity_code
 , lgt2.alloc_to_source_id_num_1        alloc_to_source_id_num_1
 , lgt2.alloc_to_source_id_num_2        alloc_to_source_id_num_2
 , lgt2.alloc_to_source_id_num_3        alloc_to_source_id_num_3
 , lgt2.alloc_to_source_id_num_4        alloc_to_source_id_num_4
 , lgt2.alloc_to_source_id_char_1   alloc_to_source_id_char_1
 , lgt2.alloc_to_source_id_char_2   alloc_to_source_id_char_2
 , lgt2.alloc_to_source_id_char_3   alloc_to_source_id_char_3
 , lgt2.alloc_to_source_id_char_4   alloc_to_source_id_char_4
 , lgt2.alloc_to_distribution_type  alloc_to_distribution_type
 , lgt2.alloc_to_dist_id_char_1     alloc_to_dist_id_char_1
 , lgt2.alloc_to_dist_id_char_2     alloc_to_dist_id_char_2
 , lgt2.alloc_to_dist_id_char_3     alloc_to_dist_id_char_3
 , lgt2.alloc_to_dist_id_char_4     alloc_to_dist_id_char_4
 , lgt2.alloc_to_dist_id_char_5     alloc_to_dist_id_char_5
 , lgt2.alloc_to_dist_id_num_1      alloc_to_dist_id_num_1
 , lgt2.alloc_to_dist_id_num_2      alloc_to_dist_id_num_2
 , lgt2.alloc_to_dist_id_num_3      alloc_to_dist_id_num_3
 , lgt2.alloc_to_dist_id_num_4      alloc_to_dist_id_num_4
 , lgt2.alloc_to_dist_id_num_5      alloc_to_dist_id_num_5
 , lgt2.analytical_balance_flag -- Bug 7382288- Included analytical criteria
 , lgt2.anc_id_1
 , lgt2.anc_id_2
 , lgt2.anc_id_3
 , lgt2.anc_id_4
 , lgt2.anc_id_5
 , lgt2.anc_id_6
 , lgt2.anc_id_7
 , lgt2.anc_id_8
 , lgt2.anc_id_9
 , lgt2.anc_id_10
 , lgt2.anc_id_11
 , lgt2.anc_id_12
 , lgt2.anc_id_13
 , lgt2.anc_id_14
 , lgt2.anc_id_15
 , lgt2.anc_id_16
 , lgt2.anc_id_17
 , lgt2.anc_id_18
 , lgt2.anc_id_19
 , lgt2.anc_id_20
 , lgt2.anc_id_21
 , lgt2.anc_id_22
 , lgt2.anc_id_23
 , lgt2.anc_id_24
 , lgt2.anc_id_25
 , lgt2.anc_id_26
 , lgt2.anc_id_27
 , lgt2.anc_id_28
 , lgt2.anc_id_29
 , lgt2.anc_id_30
 , lgt2.anc_id_31
 , lgt2.anc_id_32
 , lgt2.anc_id_33
 , lgt2.anc_id_34
 , lgt2.anc_id_35
 , lgt2.anc_id_36
 , lgt2.anc_id_37
 , lgt2.anc_id_38
 , lgt2.anc_id_39
 , lgt2.anc_id_40
 , lgt2.anc_id_41
 , lgt2.anc_id_42
 , lgt2.anc_id_43
 , lgt2.anc_id_44
 , lgt2.anc_id_45
 , lgt2.anc_id_46
 , lgt2.anc_id_47
 , lgt2.anc_id_48
 , lgt2.anc_id_49
 , lgt2.anc_id_50
 , lgt2.anc_id_51
 , lgt2.anc_id_52
 , lgt2.anc_id_53
 , lgt2.anc_id_54
 , lgt2.anc_id_55
 , lgt2.anc_id_56
 , lgt2.anc_id_57
 , lgt2.anc_id_58
 , lgt2.anc_id_59
 , lgt2.anc_id_60
 , lgt2.anc_id_61
 , lgt2.anc_id_62
 , lgt2.anc_id_63
 , lgt2.anc_id_64
 , lgt2.anc_id_65
 , lgt2.anc_id_66
 , lgt2.anc_id_67
 , lgt2.anc_id_68
 , lgt2.anc_id_69
 , lgt2.anc_id_70
 , lgt2.anc_id_71
 , lgt2.anc_id_72
 , lgt2.anc_id_73
 , lgt2.anc_id_74
 , lgt2.anc_id_75
 , lgt2.anc_id_76
 , lgt2.anc_id_77
 , lgt2.anc_id_78
 , lgt2.anc_id_79
 , lgt2.anc_id_80
 , lgt2.anc_id_81
 , lgt2.anc_id_82
 , lgt2.anc_id_83
 , lgt2.anc_id_84
 , lgt2.anc_id_85
 , lgt2.anc_id_86
 , lgt2.anc_id_87
 , lgt2.anc_id_88
 , lgt2.anc_id_89
 , lgt2.anc_id_90
 , lgt2.anc_id_91
 , lgt2.anc_id_92
 , lgt2.anc_id_93
 , lgt2.anc_id_94
 , lgt2.anc_id_95
 , lgt2.anc_id_96
 , lgt2.anc_id_97
 , lgt2.anc_id_98
 , lgt2.anc_id_99
 , lgt2.anc_id_100
        FROM
          xla_ae_lines_gt     lgt1
         ,xla_ae_lines_gt     lgt2
         ,xla_ae_headers_gt   hgt
      WHERE lgt1.reversal_code                              = 'DUMMY_LR'
        AND lgt2.ledger_id                                  = lgt1.ledger_id
        AND lgt2.source_distribution_type                   = lgt1.reverse_distribution_type
        AND nvl(lgt2.source_distribution_id_num_1,-99)      = nvl(lgt1.reverse_dist_id_num_1,-99)
        AND nvl(lgt2.source_distribution_id_num_2,-99)      = nvl(lgt1.reverse_dist_id_num_2,-99)
        AND nvl(lgt2.source_distribution_id_num_3,-99)      = nvl(lgt1.reverse_dist_id_num_3,-99)
        AND nvl(lgt2.source_distribution_id_num_4,-99)      = nvl(lgt1.reverse_dist_id_num_4,-99)
        AND nvl(lgt2.source_distribution_id_num_5,-99)      = nvl(lgt1.reverse_dist_id_num_5,-99)
        AND nvl(lgt2.source_distribution_id_char_1,' ')     = nvl(lgt1.reverse_dist_id_char_1,' ')
        AND nvl(lgt2.source_distribution_id_char_2,' ')     = nvl(lgt1.reverse_dist_id_char_2,' ')
        AND nvl(lgt2.source_distribution_id_char_3,' ')     = nvl(lgt1.reverse_dist_id_char_3,' ')
        AND nvl(lgt2.source_distribution_id_char_4,' ')     = nvl(lgt1.reverse_dist_id_char_4,' ')
        AND nvl(lgt2.source_distribution_id_char_5,' ')     = nvl(lgt1.reverse_dist_id_char_5,' ')
        AND hgt.event_id            = lgt2.event_id
        AND hgt.ledger_id           = lgt2.ledger_id
        AND hgt.balance_type_code   = lgt2.balance_type_code
        AND hgt.entity_id           = lgt1.entity_id
        -- lines for events with event number > current event number are not reversed.
        AND hgt.event_number        < lgt1.event_number
        AND hgt.header_num          = lgt2.header_num-- 4262811c  Line Reversal (xla_ae_lines_gt_u1 error)
        AND hgt.ae_header_id        = lgt2.ae_header_id
     )
    WHERE rn = 1
  );


   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Line Reversal - Reversal lines created from xla_ae_lines_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   --------------------------------------------------------------------------------------------------------
   -- 5108415 For Line Reversal, Store the incomplete MPA/AccRev entries to be used in DeleteIncompleteMPA
   --------------------------------------------------------------------------------------------------------
   IF p_accounting_mode IN ('F','RESERVE_FUNDS') THEN

      SELECT /*+ Leading(LGT,XDL)  use_nl(lgt xdl aeh ael)*/  -- 5262950
             ael.ae_header_id
            ,ael.ae_line_num
            ,aeh.parent_ae_header_id
      BULK COLLECT INTO
             g_incomplete_mpa_acc_LR.l_array_ae_header_id
            ,g_incomplete_mpa_acc_LR.l_array_ae_line_num
            ,g_incomplete_mpa_acc_LR.l_array_parent_ae_header
      FROM
           xla_ae_lines_gt           lgt
          ,xla_ae_lines              ael
          ,xla_ae_headers            aeh
          ,xla_distribution_links    xdl
      WHERE xdl.application_id                          = l_application_id
        AND xdl.source_distribution_type                = lgt.reverse_distribution_type
        AND lgt.reversal_code                           = 'DUMMY_LR'
        AND     xdl.source_distribution_id_num_1        =     lgt.reverse_dist_id_num_1       -- 5479652
        AND nvl(xdl.source_distribution_id_num_2,-99)   = nvl(lgt.reverse_dist_id_num_2,-99)
        AND nvl(xdl.source_distribution_id_num_3,-99)   = nvl(lgt.reverse_dist_id_num_3,-99)
        AND nvl(xdl.source_distribution_id_num_4,-99)   = nvl(lgt.reverse_dist_id_num_4,-99)
        AND nvl(xdl.source_distribution_id_num_5,-99)   = nvl(lgt.reverse_dist_id_num_5,-99)
        AND nvl(xdl.source_distribution_id_char_1,' ')  = nvl(lgt.reverse_dist_id_char_1,' ')
        AND nvl(xdl.source_distribution_id_char_2,' ')  = nvl(lgt.reverse_dist_id_char_2,' ')
        AND nvl(xdl.source_distribution_id_char_3,' ')  = nvl(lgt.reverse_dist_id_char_3,' ')
        AND nvl(xdl.source_distribution_id_char_4,' ')  = nvl(lgt.reverse_dist_id_char_4,' ')
        AND nvl(xdl.source_distribution_id_char_5,' ')  = nvl(lgt.reverse_dist_id_char_5,' ')
        AND aeh.application_id                          = xdl.application_id
        AND aeh.ae_header_id                            = xdl.ae_header_id
        AND aeh.ledger_id                               = lgt.ledger_id
        AND aeh.entity_id                               = lgt.entity_id
        AND ael.application_id                          = aeh.application_id
        AND ael.ae_header_id                            = aeh.ae_header_id
        AND ael.ae_line_num                             = xdl.ae_line_num
        AND aeh.parent_ae_header_id IS NOT NULL AND aeh.accounting_entry_status_code IN ('D','N','I','R','RELATED_EVENT_ERROR');  -- 5262950 incomplete MPA/AccRev

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_msg      => 'Incomplete mpa_acc_LR  count='||g_incomplete_mpa_acc_LR.l_array_ae_header_id.COUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         FOR i in 1..g_incomplete_mpa_acc_LR.l_array_ae_header_id.COUNT LOOP
            trace
               (p_msg      => 'Incomplete mpa_acc_LR  ae_header='||g_incomplete_mpa_acc_LR.l_array_ae_header_id(i)||
                              ' ae_line='||g_incomplete_mpa_acc_LR.l_array_ae_line_num(i)||
                              ' parent='||g_incomplete_mpa_acc_LR.l_array_parent_ae_header(i)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END LOOP;
      END IF;
   END IF;
   -------------------------------------------------------------------------------------------

   --
   ---------------------------------------------------------------------------------------------------------
   -- Reverse the lines in xla_ae_lines table
   --
   -- Some for 4669308:
   --          For MPA entries, only reverse what is necessary , ie create reversal for Complete MPA only.
   --          Do not create reversal for incomplete entry (since it will get deleted anyway).
   --          Also, since the redundant lines will affect ROUNDING calculation.
   --          Need to create reversal in Draft mode also (so can be viewed).
   ---------------------------------------------------------------------------------------------------------
   --
   INSERT INTO xla_ae_lines_gt
      (ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,ledger_id
      ,balance_type_code
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,alt_ccid_status_code
      ,alt_code_combination_id
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,switch_side_flag  -- 5055878
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,doc_rounding_acctd_amt
      ,doc_rounding_entered_amt
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,source_distribution_id_char_1
      ,source_distribution_id_char_2
      ,source_distribution_id_char_3
      ,source_distribution_id_char_4
      ,source_distribution_id_char_5
      ,source_distribution_id_num_1
      ,source_distribution_id_num_2
      ,source_distribution_id_num_3
      ,source_distribution_id_num_4
      ,source_distribution_id_num_5
      ,source_distribution_type
      ,reverse_dist_id_char_1
      ,reverse_dist_id_char_2
      ,reverse_dist_id_char_3
      ,reverse_dist_id_char_4
      ,reverse_dist_id_char_5
      ,reverse_dist_id_num_1
      ,reverse_dist_id_num_2
      ,reverse_dist_id_num_3
      ,reverse_dist_id_num_4
      ,reverse_dist_id_num_5
      ,reverse_distribution_type
      ,reversal_code
      ,accounting_entry_status_code
      ,inherit_desc_flag
      ,header_num
      ,encumbrance_type_id
      ,mpa_accrual_entry_flag
      ,accounting_date
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
 ,TAX_LINE_REF_ID           -- Bug 7159711
 ,TAX_SUMMARY_LINE_REF_ID   -- Bug 7159711
 ,TAX_REC_NREC_DIST_REF_ID  -- Bug 7159711
 ,analytical_balance_flag   -- Bug 7382288
 ,ANC_ID_1 -- 8691573
 )
   (SELECT
       ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,ledger_id
      ,balance_type_code
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,code_combination_status_code
      ,code_combination_id
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,switch_side_flag  -- 5055878
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,doc_rounding_acctd_amt
      ,doc_rounding_entered_amt
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,source_distribution_id_char_1
      ,source_distribution_id_char_2
      ,source_distribution_id_char_3
      ,source_distribution_id_char_4
      ,source_distribution_id_char_5
      ,source_distribution_id_num_1
      ,source_distribution_id_num_2
      ,source_distribution_id_num_3
      ,source_distribution_id_num_4
      ,source_distribution_id_num_5
      ,source_distribution_type
      ,reverse_dist_id_char_1
      ,reverse_dist_id_char_2
      ,reverse_dist_id_char_3
      ,reverse_dist_id_char_4
      ,reverse_dist_id_char_5
      ,reverse_dist_id_num_1
      ,reverse_dist_id_num_2
      ,reverse_dist_id_num_3
      ,reverse_dist_id_num_4
      ,reverse_dist_id_num_5
      ,reverse_distribution_type
      ,reversal_code
      ,accounting_entry_status_code
      ,inherit_desc_flag
      ,header_num
      ,encumbrance_type_id
      ,mpa_accrual_entry_flag
      ,accounting_date
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
 ,TAX_LINE_REF_ID           -- Bug 7159711
 ,TAX_SUMMARY_LINE_REF_ID   -- Bug 7159711
 ,TAX_REC_NREC_DIST_REF_ID  -- Bug 7159711
 ,analytical_balance_flag   -- Bug 7382288
 ,ANC_ID_1 -- 8691573
   FROM
      (SELECT /*+ leading(lgt) use_nl(xdl,ael,aeh) */
          -- populates ae_header_id which is same as event_id till this point
          lgt.event_id                                          AE_HEADER_ID
         -- populates temp_line_num which is (-ve) of original line
         ,0 - xdl.temp_line_num                                 TEMP_LINE_NUM
         -- populates event_id which is the event_id of event under process
         ,lgt.event_id                                          EVENT_ID
         -- populates ref_ae_header_id which is ae_header_id of original line
         ,ael.ae_header_id                                      REF_AE_HEADER_ID
         -- populates ref_ae_line_num which is ae_line_num of original line
         ,ael.ae_line_num                                       REF_AE_LINE_NUM
         -- populates ref_temp_line_num which is ae_line_num of original line
         ,xdl.temp_line_num                                     REF_TEMP_LINE_NUM
         -- populates ref_event_id which is event_id of original line
         ,xdl.event_id                                          REF_EVENT_ID
         ,lgt.ledger_id                                         LEDGER_ID
         ,aeh.balance_type_code                                 BALANCE_TYPE_CODE
         ,ael.accounting_class_code                             ACCOUNTING_CLASS_CODE
         ,xdl.event_class_code                                  EVENT_CLASS_CODE
         ,xdl.event_type_code                                   EVENT_TYPE_CODE
         ,xdl.line_definition_owner_code                        LINE_DEFINITION_OWNER_CODE
         ,xdl.line_definition_code                              LINE_DEFINITION_CODE
         ,xdl.accounting_line_type_code                         ACCOUNTING_LINE_TYPE_CODE
         ,xdl.accounting_line_code                              ACCOUNTING_LINE_CODE
         ,C_CREATED                                             CODE_COMBINATION_STATUS_CODE
         ,ael.code_combination_id                               CODE_COMBINATION_ID
         ,ael.description                                       DESCRIPTION
         ,ael.gl_transfer_mode_code                             GL_TRANSFER_MODE_CODE
         ,xdl.merge_duplicate_code                              MERGE_DUPLICATE_CODE
         ,decode(ael.gain_or_loss_flag, 'Y', decode(xdl.calculate_g_l_amts_flag, 'Y', 'Y', 'N'), lgt.switch_side_flag)
                                                                SWITCH_SIDE_FLAG
         -- 5055878 amounts modified for reversal method of SIDE or SIGN
         ,DECODE(lgt.switch_side_flag,'Y',xdl.unrounded_entered_cr,  -xdl.unrounded_entered_dr)     UNROUNDED_ENTERED_DR
         ,DECODE(lgt.switch_side_flag,'Y',xdl.unrounded_entered_dr,  -xdl.unrounded_entered_cr)     UNROUNDED_ENTERED_CR
         ,DECODE(lgt.switch_side_flag,'Y',xdl.unrounded_accounted_cr,-xdl.unrounded_accounted_dr)   UNROUNDED_ACCOUNTED_DR
         ,DECODE(lgt.switch_side_flag,'Y',xdl.unrounded_accounted_dr,-xdl.unrounded_accounted_cr)   UNROUNDED_ACCOUNTED_CR
         --
         ,xdl.calculate_acctd_amts_flag                         CALCULATE_ACCTD_AMTS_FLAG
         ,xdl.calculate_g_l_amts_flag                           CALCULATE_G_L_AMTS_FLAG
         ,ael.gain_or_loss_flag                                 GAIN_OR_LOSS_FLAG
         ,xdl.rounding_class_code                               ROUNDING_CLASS_CODE
         ,xdl.document_rounding_level                           DOCUMENT_ROUNDING_LEVEL
         ,NULL                                                  DOC_ROUNDING_ACCTD_AMT
         ,NULL                                                  DOC_ROUNDING_ENTERED_AMT
         -- bug8642358 ,nvl(fcu.minimum_accountable_unit, power(10, -1*fcu.precision))         ENTERED_CURRENCY_MAU
         ,decode(ael.gain_or_loss_flag, 'Y', 0.01, nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))) ENTERED_CURRENCY_MAU
	 ,ael.currency_code                                     CURRENCY_CODE
         ,ael.currency_conversion_date                          CURRENCY_CONVERSION_DATE
         ,ael.currency_conversion_rate                          CURRENCY_CONVERSION_RATE
         ,ael.currency_conversion_type                          CURRENCY_CONVERSION_TYPE
         ,ael.statistical_amount                                STATISTICAL_AMOUNT
         ,ael.party_id                                          PARTY_ID
         ,ael.party_site_id                                     PARTY_SITE_ID
         ,ael.party_type_code                                   PARTY_TYPE_CODE
         ,ael.ussgl_transaction_code                            USSGL_TRANSACTION_CODE
         ,ael.jgzz_recon_ref                                    JGZZ_RECON_REF
         ,lgt.source_distribution_id_char_1                     SOURCE_DISTRIBUTION_ID_CHAR_1
         ,lgt.source_distribution_id_char_2                     SOURCE_DISTRIBUTION_ID_CHAR_2
         ,lgt.source_distribution_id_char_3                     SOURCE_DISTRIBUTION_ID_CHAR_3
         ,lgt.source_distribution_id_char_4                     SOURCE_DISTRIBUTION_ID_CHAR_4
         ,lgt.source_distribution_id_char_5                     SOURCE_DISTRIBUTION_ID_CHAR_5
         ,lgt.source_distribution_id_num_1                      SOURCE_DISTRIBUTION_ID_NUM_1
         ,lgt.source_distribution_id_num_2                      SOURCE_DISTRIBUTION_ID_NUM_2
         ,lgt.source_distribution_id_num_3                      SOURCE_DISTRIBUTION_ID_NUM_3
         ,lgt.source_distribution_id_num_4                      SOURCE_DISTRIBUTION_ID_NUM_4
         ,lgt.source_distribution_id_num_5                      SOURCE_DISTRIBUTION_ID_NUM_5
         ,lgt.source_distribution_type                          SOURCE_DISTRIBUTION_TYPE
         ,lgt.reverse_dist_id_char_1                            REVERSE_DIST_ID_CHAR_1
         ,lgt.reverse_dist_id_char_2                            REVERSE_DIST_ID_CHAR_2
         ,lgt.reverse_dist_id_char_3                            REVERSE_DIST_ID_CHAR_3
         ,lgt.reverse_dist_id_char_4                            REVERSE_DIST_ID_CHAR_4
         ,lgt.reverse_dist_id_char_5                            REVERSE_DIST_ID_CHAR_5
         ,lgt.reverse_dist_id_num_1                             REVERSE_DIST_ID_NUM_1
         ,lgt.reverse_dist_id_num_2                             REVERSE_DIST_ID_NUM_2
         ,lgt.reverse_dist_id_num_3                             REVERSE_DIST_ID_NUM_3
         ,lgt.reverse_dist_id_num_4                             REVERSE_DIST_ID_NUM_4
         ,lgt.reverse_dist_id_num_5                             REVERSE_DIST_ID_NUM_5
         ,lgt.reverse_distribution_type                         REVERSE_DISTRIBUTION_TYPE
         -- populate reversal_code indicating that line is result of reversal
         ,'REVERSAL'                                            REVERSAL_CODE
         -- denormalises entry status from headers to line to determine the status of entry being created
         -- populates 0 for a valid entry (F or D) else poulates 1
         ,DECODE(aeh.accounting_entry_status_code,'F',0,'D',0,1) ACCOUNTING_ENTRY_STATUS_CODE
         ,'N'                                                    INHERIT_DESC_FLAG
          -- 4669308 combine header with reversal of original entry
         --,0                                                      HEADER_NUM -- commented for bug8505463`
         , DECODE(aeh.parent_ae_header_id , NULL , 0 ,
                                            CASE
                                            WHEN aeh.accounting_date <= lgt.accounting_date
                                                 THEN 0
                                            ELSE -1 * dense_rank() over ( partition by aeh.parent_ae_header_id , aeh.parent_ae_line_num
 	                                                                      order by aeh.ae_header_Id )
                                            END
           )                                              HEADER_NUM -- added for bug8505463 for MPA Cancellation
         ,ael.encumbrance_type_id                                ENCUMBRANCE_TYPE_ID
         ,'N'                                                    MPA_ACCRUAL_ENTRY_FLAG
         --,lgt.accounting_date                                    ACCOUNTING_DATE -- commented for bug8505463
	 , DECODE(aeh.parent_ae_header_id , NULL , lgt.accounting_date ,  -- Regular Cancellation, hence Cancellation Event Date
 	                                    CASE
 	                                    WHEN aeh.accounting_date <= lgt.accounting_date
 	                                         THEN lgt.accounting_date  -- Accounting Date of Cancellation Event for prior Period's MPA Accounting
 	                                    ELSE  aeh.accounting_date          -- Accounting Date of Original MPA Accounting
 	                                    END
 	                   )                                              ACCOUNTING_DATE -- added for bug8505463 for MPA Cancellation
            -- original line. This is used to filter duplicate rows in the outer query.
         ,row_number() over
              (partition by xdl.ae_header_Id,xdl.temp_line_num
                   order by lgt.event_number
              ) rn
      , xdl.APPLIED_TO_APPLICATION_ID   APPLIED_TO_APPLICATION_ID
 , xdl.APPLIED_TO_ENTITY_CODE       APPLIED_TO_ENTITY_CODE
 , xdl.APPLIED_TO_ENTITY_ID     APPLIED_TO_ENTITY_ID
 , xdl.APPLIED_TO_SOURCE_ID_NUM_1   APPLIED_TO_SOURCE_ID_NUM_1
 , xdl.APPLIED_TO_SOURCE_ID_NUM_2   APPLIED_TO_SOURCE_ID_NUM_2
 , xdl.APPLIED_TO_SOURCE_ID_NUM_3   APPLIED_TO_SOURCE_ID_NUM_3
 , xdl.APPLIED_TO_SOURCE_ID_NUM_4   APPLIED_TO_SOURCE_ID_NUM_4
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_1  APPLIED_TO_SOURCE_ID_CHAR_1
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_2  APPLIED_TO_SOURCE_ID_CHAR_2
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_3  APPLIED_TO_SOURCE_ID_CHAR_3
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_4  APPLIED_TO_SOURCE_ID_CHAR_4
 , xdl.APPLIED_TO_DISTRIBUTION_TYPE APPLIED_TO_DISTRIBUTION_TYPE
 , xdl.APPLIED_TO_DIST_ID_NUM_1     APPLIED_TO_DIST_ID_NUM_1
 , xdl.APPLIED_TO_DIST_ID_NUM_2     APPLIED_TO_DIST_ID_NUM_2
 , xdl.APPLIED_TO_DIST_ID_NUM_3     APPLIED_TO_DIST_ID_NUM_3
 , xdl.APPLIED_TO_DIST_ID_NUM_4     APPLIED_TO_DIST_ID_NUM_4
 , xdl.APPLIED_TO_DIST_ID_NUM_5     APPLIED_TO_DIST_ID_NUM_5
 , xdl.APPLIED_TO_DIST_ID_CHAR_1    APPLIED_TO_DIST_ID_CHAR_1
 , xdl.APPLIED_TO_DIST_ID_CHAR_2    APPLIED_TO_DIST_ID_CHAR_2
 , xdl.APPLIED_TO_DIST_ID_CHAR_3    APPLIED_TO_DIST_ID_CHAR_3
 , xdl.APPLIED_TO_DIST_ID_CHAR_4    APPLIED_TO_DIST_ID_CHAR_4
 , xdl.APPLIED_TO_DIST_ID_CHAR_5    APPLIED_TO_DIST_ID_CHAR_5
 , xdl.alloc_to_application_id      alloc_to_application_id
 , xdl.alloc_to_entity_code     alloc_to_entity_code
 , xdl.alloc_to_source_id_num_1     alloc_to_source_id_num_1
 , xdl.alloc_to_source_id_num_2     alloc_to_source_id_num_2
 , xdl.alloc_to_source_id_num_3     alloc_to_source_id_num_3
 , xdl.alloc_to_source_id_num_4     alloc_to_source_id_num_4
 , xdl.alloc_to_source_id_char_1    alloc_to_source_id_char_1
 , xdl.alloc_to_source_id_char_2    alloc_to_source_id_char_2
 , xdl.alloc_to_source_id_char_3    alloc_to_source_id_char_3
 , xdl.alloc_to_source_id_char_4    alloc_to_source_id_char_4
 , xdl.alloc_to_distribution_type   alloc_to_distribution_type
 , xdl.alloc_to_dist_id_char_1      alloc_to_dist_id_char_1
 , xdl.alloc_to_dist_id_char_2      alloc_to_dist_id_char_2
 , xdl.alloc_to_dist_id_char_3      alloc_to_dist_id_char_3
 , xdl.alloc_to_dist_id_char_4      alloc_to_dist_id_char_4
 , xdl.alloc_to_dist_id_char_5      alloc_to_dist_id_char_5
 , xdl.alloc_to_dist_id_num_1       alloc_to_dist_id_num_1
 , xdl.alloc_to_dist_id_num_2       alloc_to_dist_id_num_2
 , xdl.alloc_to_dist_id_num_3       alloc_to_dist_id_num_3
 , xdl.alloc_to_dist_id_num_4       alloc_to_dist_id_num_4
 , xdl.alloc_to_dist_id_num_5       alloc_to_dist_id_num_5
 ,nvl(lgt.tax_line_ref_id, xdl.tax_line_ref_id)                   TAX_LINE_REF_ID          -- Bug 7159711
 ,nvl(lgt.tax_summary_line_ref_id, xdl.tax_summary_line_ref_id)   TAX_SUMMARY_LINE_REF_ID  -- Bug 7159711
 ,nvl(lgt.tax_rec_nrec_dist_ref_id, xdl.tax_rec_nrec_dist_ref_id) TAX_REC_NREC_DIST_REF_ID -- Bug 7159711
 ,decode(ael.analytical_balance_flag, 'Y','P',
                                  'P','P',
                                  null) analytical_balance_flag   -- Bug 7382288
,nvl2(ael.analytical_balance_flag, 'DUMMY_ANC_'||ael.ae_header_id||ael.ae_line_num,null) ANC_ID_1 --Bug 8691573
       FROM
           xla_ae_lines_gt           lgt
          ,xla_distribution_links    xdl
          ,xla_ae_lines              ael
          ,xla_ae_headers            aeh
          ,fnd_currencies            fcu
          ,xla_events                evt
       WHERE lgt.reversal_code                              = 'DUMMY_LR'
         AND xdl.application_id                             = l_application_id
         AND xdl.source_distribution_type                   = lgt.reverse_distribution_type
         AND xdl.source_distribution_id_num_1               = nvl(lgt.reverse_dist_id_num_1,-99)
         AND nvl(xdl.source_distribution_id_num_2,-99)      = nvl(lgt.reverse_dist_id_num_2,-99)
         AND nvl(xdl.source_distribution_id_num_3,-99)      = nvl(lgt.reverse_dist_id_num_3,-99)
         AND nvl(xdl.source_distribution_id_num_4,-99)      = nvl(lgt.reverse_dist_id_num_4,-99)
         AND nvl(xdl.source_distribution_id_num_5,-99)      = nvl(lgt.reverse_dist_id_num_5,-99)
         AND nvl(xdl.source_distribution_id_char_1,' ')     = nvl(lgt.reverse_dist_id_char_1,' ')
         AND nvl(xdl.source_distribution_id_char_2,' ')     = nvl(lgt.reverse_dist_id_char_2,' ')
         AND nvl(xdl.source_distribution_id_char_3,' ')     = nvl(lgt.reverse_dist_id_char_3,' ')
         AND nvl(xdl.source_distribution_id_char_4,' ')     = nvl(lgt.reverse_dist_id_char_4,' ')
         AND nvl(xdl.source_distribution_id_char_5,' ')     = nvl(lgt.reverse_dist_id_char_5,' ')
         -- lines that are due to reversals are not reversed again
         AND NVL(xdl.temp_line_num,0)                    >= 0
         AND aeh.application_id                          = xdl.application_id
         AND aeh.ae_header_id                            = xdl.ae_header_id
         AND aeh.ledger_id                               = lgt.ledger_id
         AND aeh.entity_id                               = lgt.entity_id
         AND ael.application_id                          = aeh.application_id
         AND ael.ae_header_id                            = aeh.ae_header_id
         AND ael.ae_line_num                             = xdl.ae_line_num
         AND fcu.currency_code                           = ael.currency_code
         -- lines that have been reversed before in previous run are not reversed again
         AND NOT EXISTS (
                    SELECT /*+ no_unnest */ 1
                    FROM xla_distribution_links
                    WHERE ref_ae_header_id = xdl.ae_header_id
                      AND temp_line_num    = xdl.temp_line_num * -1
                      AND application_id   = xdl.application_id
                   )
         AND evt.application_id                          = aeh.application_id
         AND evt.event_id                                = aeh.event_id
         AND NVL(evt.budgetary_control_flag,'N')         = DECODE(p_accounting_mode
                                                                 ,'FUNDS_CHECK','Y'
                                                                 ,'FUNDS_RESERVE','Y'
                                                                 ,'N'
                                                                 )
         AND  ((aeh.parent_ae_header_id IS NOT NULL AND aeh.accounting_entry_status_code = 'F') OR
               (aeh.parent_ae_header_id IS NULL)
              )
      )
   WHERE rn = 1
   );

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Line Reversal - Reversal lines created from xla_ae_lines = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;


-- bug7135700 code change, case: reversal lines created for primary but not for secondary for same event.
-- Note: This code may not, or may unnessecarily throw this warning for cash basis secondary legders also,
--       that case has not been considered

 l_upgrade_check := 0;
 xla_accounting_cache_pkg.GetLedgerArray(l_ledger_attrs);

 FOR i in 1..l_ledger_attrs.array_ledger_id.COUNT
 LOOP
  IF l_ledger_attrs.array_ledger_type(i) = 'PRIMARY' THEN
    l_primary_ledger_id := l_ledger_attrs.array_ledger_id(i);
  END IF;
 END LOOP;


 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_primary_ledger_id = '|| l_primary_ledger_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
 END IF;


 BEGIN
    SELECT 1
    INTO l_upgrade_check
    FROM DUAL
    WHERE EXISTS
        (SELECT 1
        FROM gl_ledger_relationships
        WHERE hist_conv_status_code = 'SUCCESSFUL'
        AND primary_ledger_id = l_primary_ledger_id
        AND relationship_enabled_flag = 'Y');
 EXCEPTION WHEN OTHERS THEN
     l_upgrade_check := 0;
 END;


 IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_upgrade_check = '|| l_upgrade_check
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
 END IF;


 IF l_upgrade_check = 1 THEN

 -- find the latest 'first ledger open period name' of all the secondary/alc ledgers

    SELECT max(glp.start_date)
      INTO l_max_first_open_period
      FROM  gl_period_statuses glp,
            gl_ledgers gl,
            gl_ledger_relationships glr
      WHERE glp.period_name = gl.first_ledger_period_name
      AND  glp.ledger_id = gl.ledger_id
      AND  glp.application_id = 101
      AND  gl.ledger_id = glr.target_ledger_id
      AND  glr.primary_ledger_id = l_primary_ledger_id
      AND  glr.relationship_enabled_flag = 'Y'
      AND  gl.ledger_category_code <> 'PRIMARY';


-- find the reference event (upstream entry exists for primary but not alc/secondary) with the least accounting date


  SELECT min(xla_ae_headers.accounting_date)
    INTO l_min_ref_event_date
    FROM xla_ae_lines_gt gt1, xla_ae_headers
   WHERE gt1.reversal_code = 'REVERSAL'
     AND gt1.ref_event_id = xla_ae_headers.event_id;


IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_max_first_open_period = '|| l_max_first_open_period
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
 END IF;


IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_min_ref_event_date = '|| l_min_ref_event_date
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
 END IF;


END IF;  --l_upgrade_check if end


 IF l_upgrade_check = 1 AND l_min_ref_event_date <= l_max_first_open_period THEN


 print_logfile('***************************************************************************************************');
 print_logfile('The following REVERSAL (LR) events do not have historic entries replicated in secondary/alc ledgers');
 print_logfile('Manual GL adjustments in the secondary/alc ledgers needs to be done for these events');


 FOR c_not_reversed_entries IN
 (SELECT DISTINCT gt1.event_id, gt1.ledger_id
 FROM xla_ae_lines_gt gt1, gl_ledgers gll
 WHERE gt1.reversal_code = 'DUMMY_LR'
 AND gll.ledger_id = gt1.ledger_id
 AND gll.ledger_category_code <> 'PRIMARY'
 AND NOT EXISTS (SELECT 1
                 FROM xla_ae_lines_gt gt2
         WHERE gt2.reversal_code = 'REVERSAL'
         AND gt1.event_id = gt2.event_id
         AND gt1.ledger_id = gt2.ledger_id)
 AND EXISTS (SELECT 1
            FROM xla_ae_lines_gt gt3
            WHERE gt3.reversal_code = 'REVERSAL'
        AND gt1.event_id = gt3.event_id))

 LOOP
  --IF (C_LEVEL_STATEMENT >= g_log_level) THEN
  --    trace
  --       (p_msg      => 'WARNING - Reversal (LR) lines could not be created for event  ' || c_not_reversed_entries.event_id || ' of ledger ' || c_not_reversed_entries.ledger_id || '. Please create Manual Adjustment Entries.'
  --       ,p_level    => C_LEVEL_STATEMENT
  --       ,p_module   => l_log_module);
  --END IF;
  print_logfile('Event ' || c_not_reversed_entries.event_id || ' of ledger ' || c_not_reversed_entries.ledger_id);
  l_error_count := l_error_count + 1;
 END LOOP;

 IF l_error_count > 0 THEN
   g_hist_reversal_error_exists := TRUE;
 END IF;

 IF l_error_count = 0 THEN
 print_logfile('    NO SUCH ENTRIES');
 END IF;

 print_logfile('***************************************************************************************************');

END IF;


-- bug7135700 code change end;




   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Performing transaction level accounting reversal'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;


--***************************************************************************************************************
--***************************************************************************************************************
--*************    T R A N S A C T I O N      R E V E R S A L    ************************************************
--***************************************************************************************************************
--***************************************************************************************************************

   --
   -- selecting all the dummy lines from xla_ae_lines_gt that are due to
   -- transaction level reversal option
   --
   SELECT event_id
         ,ledger_id
         ,event_number
         ,entity_id
         ,source_distribution_type
         ,source_distribution_id_num_1
         ,source_distribution_id_num_2
         ,source_distribution_id_num_3
         ,source_distribution_id_num_4
         ,source_distribution_id_num_5
         ,source_distribution_id_char_1
         ,source_distribution_id_char_2
         ,source_distribution_id_char_3
         ,source_distribution_id_char_4
         ,source_distribution_id_char_5
         ,switch_side_flag        -- 5055878
         ,accounting_date         -- 5189664
         ,tax_line_ref_id            -- 7226263
         ,tax_summary_line_ref_id    -- 7226263
         ,tax_rec_nrec_dist_ref_id   -- 7226263
     BULK COLLECT INTO
          l_array_event_id
         ,l_array_ledger_id
         ,l_array_event_number
         ,l_array_entity_id
         ,l_array_source_dist_type
         ,l_array_source_dist_id_num_1
         ,l_array_source_dist_id_num_2
         ,l_array_source_dist_id_num_3
         ,l_array_source_dist_id_num_4
         ,l_array_source_dist_id_num_5
         ,l_array_source_dist_id_char_1
         ,l_array_source_dist_id_char_2
         ,l_array_source_dist_id_char_3
         ,l_array_source_dist_id_char_4
         ,l_array_source_dist_id_char_5
         ,l_array_switch_side_flag     -- 5055878
         ,l_array_gl_date              -- 5189664
         ,l_array_tax_line_ref           -- 7226263
         ,l_array_tax_summary_line_ref   -- 7226263
         ,l_array_tax_rec_nrec_dist_ref  -- 7226263
     FROM xla_ae_lines_gt
    WHERE reversal_code = 'DUMMY_TR'
    ORDER by entity_id, event_number;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Transaction Revesal - Events with reversal options set to Y = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   --=======================================================================================================
   -- 4669308 Delete the MPA/Accrual Transaction Reversal (still in GT tables, not in distribution links yet)
   --=======================================================================================================
   --
   ---------------------------------------------------------------------------------------------------------
   -- 4669308 Delete the MPA/Accrual Transaction Reversal in xla_ae_lines_gt (not in distribution links yet)
   ---------------------------------------------------------------------------------------------------------
   --
   IF xla_accounting_pkg.g_mpa_accrual_exists = 'Y' THEN  -- 5412560
      FORALL i IN 1..l_array_entity_id.count
      DELETE xla_ae_lines_gt lgt
      WHERE l_array_ledger_id(i)          = lgt.ledger_id
        AND lgt.reversal_code IS NULL        -- the lines created from reversal are not reversed again
        AND NOT EXISTS (                     -- the lines already reversed are not reversed again
                   SELECT 1
                   FROM xla_ae_lines_gt
                   WHERE ledger_id        = lgt.ledger_id
                     AND ref_ae_header_id = lgt.ae_header_id  -- 5499367 lgt.ref_ae_header_id
                     AND temp_line_num    = lgt.temp_line_num * -1
                  )
        AND  NVL(lgt.header_num,0) > 0
        AND lgt.header_num IN
            (SELECT hgt.header_num
             FROM   xla_ae_headers_gt hgt
             WHERE  hgt.entity_id           = l_array_entity_id(i)
             AND    hgt.ledger_id           = l_array_ledger_id(i)
             AND    hgt.event_number        < l_array_event_number(i)
             AND    lgt.event_id            = hgt.event_id
             AND    lgt.ledger_id           = hgt.ledger_id
             AND    lgt.balance_type_code   = hgt.balance_type_code
             AND    lgt.header_num          = hgt.header_num)
      ;
      --
      ---------------------------------------------------------------------------------------------------------
      -- 4669308 Delete the MPA/Accrual Transaction Reversal in xla_ae_headers_gt (not in distribution links yet)
      ---------------------------------------------------------------------------------------------------------
      --
      FORALL i IN 1..l_array_entity_id.count
      DELETE xla_ae_headers_gt hgt
      WHERE  hgt.ledger_id         = l_array_ledger_id(i)
      AND    hgt.entity_id         = l_array_entity_id(i)
      AND    hgt.event_number      < l_array_event_number(i)
      AND    NVL(hgt.header_num,0) > 0
      ;
   END IF;
   ---------------------------------------------------------------------------------------------------------


   --
   -- reverse the lines in xla_ae_lines_gt table (not in distribution links yet)
   --
   FORALL i IN 1..l_array_event_id.count
   INSERT INTO xla_ae_lines_gt
      (ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,ledger_id
      ,balance_type_code
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,sl_coa_mapping_name
      ,dynamic_insert_flag
      ,source_coa_id
      ,ccid_coa_id
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
      , calculate_acctd_amts_flag
      , calculate_g_l_amts_flag
      , gain_or_loss_flag
      , rounding_class_code
      , document_rounding_level
      , doc_rounding_acctd_amt
      , doc_rounding_entered_amt
      ,alt_ccid_status_code
      ,alt_code_combination_id
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
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,switch_side_flag
--      ,entered_amount
--      ,ledger_amount
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,source_distribution_id_char_1
      ,source_distribution_id_char_2
      ,source_distribution_id_char_3
      ,source_distribution_id_char_4
      ,source_distribution_id_char_5
      ,source_distribution_id_num_1
      ,source_distribution_id_num_2
      ,source_distribution_id_num_3
      ,source_distribution_id_num_4
      ,source_distribution_id_num_5
      ,source_distribution_type
      ,reverse_dist_id_char_1
      ,reverse_dist_id_char_2
      ,reverse_dist_id_char_3
      ,reverse_dist_id_char_4
      ,reverse_dist_id_char_5
      ,reverse_dist_id_num_1
      ,reverse_dist_id_num_2
      ,reverse_dist_id_num_3
      ,reverse_dist_id_num_4
      ,reverse_dist_id_num_5
      ,reverse_distribution_type
      ,tax_line_ref_id
      ,tax_summary_line_ref_id
      ,tax_rec_nrec_dist_ref_id
    -- 4262811
      ,header_num
      ,mpa_accrual_entry_flag
      ,multiperiod_option_flag
      ,multiperiod_start_date
      ,multiperiod_end_date
    --,deferred_indicator
    --,deferred_start_date
    --,deferred_end_date
    --,deferred_no_period
    --,deferred_period_type
      ,reversal_code
      ,accounting_entry_status_code
      ,encumbrance_type_id -- 4458381
      ,inherit_desc_flag   -- 4219869
      ,accounting_date
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
 , analytical_balance_flag    --8417496
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
 , anc_id_100)

   SELECT
       -- populates ae_header_id which is same as event_id till this point
       l_array_event_id(i)
      -- populates temp_line_num which is (-ve) of original line
      ,0-lgt.temp_line_num
      -- populates event_id which is the event_id of event under process
      ,l_array_event_id(i)
      -- populates ref_ae_header_id which is ae_header_id of original line
      ,hgt.ae_header_id
      -- populates ref_ae_line_num which is ae_line_num of original line
      ,lgt.ae_line_num
      -- populates ref_temp_line_num which is ae_line_num of original line
      ,lgt.temp_line_num
      -- populates ref_event_id which is event_id of original line
      ,0-lgt.event_id                                           -- REF_EVENT_ID made negative for Bug:8277823
      ,lgt.ledger_id
      ,lgt.balance_type_code
      ,lgt.accounting_class_code
      ,lgt.event_class_code
      ,lgt.event_type_code
      ,lgt.line_definition_owner_code
      ,lgt.line_definition_code
      ,lgt.accounting_line_type_code
      ,lgt.accounting_line_code
      ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y'
                ,lgt.alt_ccid_status_code,lgt.code_combination_status_code)
         ,lgt.code_combination_status_code)
                                                       CODE_COMBINATION_STATUS_CODE
      ,decode(lgt.gain_or_loss_flag, 'Y'
            ,decode(lgt.calculate_g_l_amts_flag,'Y'
                 ,lgt.alt_code_combination_id, lgt.code_combination_id)
       , lgt.code_combination_id)
                                                       CODE_COMBINATION_ID
      ,lgt.sl_coa_mapping_name
      ,lgt.dynamic_insert_flag
      ,lgt.source_coa_id
      ,lgt.ccid_coa_id
         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment1,lgt.segment1)
         ,lgt.segment1)                                                   SEGMENT1
         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment2,lgt.segment2)
         ,lgt.segment2)                                                   SEGMENT2

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment3,lgt.segment3)
         ,lgt.segment3)                                                   SEGMENT3

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment4,lgt.segment4)
         ,lgt.segment4)                                                     SEGMENT4

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment5,lgt.segment5)
         ,lgt.segment5)                                                   SEGMENT5

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment6,lgt.segment6)
         ,lgt.segment6)                                                   SEGMENT6

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment7,lgt.segment7)
         ,lgt.segment7)                                                  SEGMENT7

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment8,lgt.segment8)
         ,lgt.segment8)                                                   SEGMENT8

         ,decode(lgt.gain_or_loss_flag, 'Y'
                ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment9,lgt.segment9)
         ,lgt.segment9)                                                   SEGMENT9

         ,decode(lgt.gain_or_loss_flag, 'Y'
              ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment10,lgt.segment10)
         ,lgt.segment10)                                                   SEGMENT10

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment11,lgt.segment11)
         ,lgt.segment11)                                                   SEGMENT11

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment12,lgt.segment12)
         ,lgt.segment12)                                                   SEGMENT12

         ,decode(lgt.gain_or_loss_flag, 'Y'
               ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment13,lgt.segment13)
         ,lgt.segment13)                                                   SEGMENT13

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment14,lgt.segment14)
         ,lgt.segment14)                                                   SEGMENT14

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment15,lgt.segment15)
         ,lgt.segment15)                                                   SEGMENT15

         ,decode(lgt.gain_or_loss_flag, 'Y'
              ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment16,lgt.segment16)
         ,lgt.segment16)                                                   SEGMENT16

         ,decode(lgt.gain_or_loss_flag, 'Y'
              ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment17,lgt.segment17)
         ,lgt.segment17)                                                   SEGMENT17

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment18,lgt.segment18)
         ,lgt.segment18)                                                   SEGMENT18

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment19,lgt.segment19)
         ,lgt.segment19)                                                   SEGMENT19

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment20,lgt.segment20)
         ,lgt.segment20)                                                  SEGMENT20

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment21,lgt.segment21)
         ,lgt.segment21)                                                   SEGMENT21

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment22,lgt.segment22)
         ,lgt.segment22)                                                   SEGMENT22

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment23,lgt.segment23)
         ,lgt.segment23)                                                   SEGMENT23

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment24,lgt.segment24)
         ,lgt.segment24)                                                   SEGMENT24

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment25,lgt.segment25)
         ,lgt.segment25)                                                   SEGMENT25

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment26,lgt.segment26)
         ,lgt.segment26)                                                   SEGMENT26

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment27,lgt.segment27)
         ,lgt.segment27)                                                   SEGMENT27

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment28,lgt.segment28)
         ,lgt.segment28)                                                  SEGMENT28

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment29,lgt.segment29)
         ,lgt.segment29)                                                   SEGMENT29

         ,decode(lgt.gain_or_loss_flag, 'Y'
             ,decode(lgt.calculate_g_l_amts_flag,'Y',lgt.alt_segment30,lgt.segment30)
         ,lgt.segment30)                                                   SEGMENT30
      ,lgt.calculate_acctd_amts_flag
      ,lgt.calculate_g_l_amts_flag
      ,lgt.gain_or_loss_flag
      ,lgt.rounding_class_code
      ,lgt.document_rounding_level
      ,lgt.doc_rounding_acctd_amt
      ,lgt.doc_rounding_entered_amt
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.code_combination_status_code ,lgt.alt_ccid_status_code)
                                                       ALT_CCID_STATUS_CODE
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.code_combination_id ,lgt.alt_code_combination_id)
                                                       ALT_CODE_COMBINATION_ID
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment1,lgt.alt_segment1)     ALT_SEGMENT1
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment2,lgt.alt_segment2)     ALT_SEGMENT2
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment3,lgt.alt_segment3)     ALT_SEGMENT3
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment4,lgt.alt_segment4)     ALT_SEGMENT4
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment5,lgt.alt_segment5)     ALT_SEGMENT5
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment6,lgt.alt_segment6)     ALT_SEGMENT6
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment7,lgt.alt_segment7)     ALT_SEGMENT7
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment8,lgt.alt_segment8)     ALT_SEGMENT8
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment9,lgt.alt_segment9)     ALT_SEGMENT9
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment10,lgt.alt_segment10)   ALT_SEGMENT10
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment11,lgt.alt_segment11)   ALT_SEGMENT11
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment12,lgt.alt_segment12)   ALT_SEGMENT12
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment13,lgt.alt_segment13)   ALT_SEGMENT13
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment14,lgt.alt_segment14)   ALT_SEGMENT14
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment15,lgt.alt_segment15)   ALT_SEGMENT15
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment16,lgt.alt_segment16)   ALT_SEGMENT16
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment17,lgt.alt_segment17)   ALT_SEGMENT17
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment18,lgt.alt_segment18)   ALT_SEGMENT18
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment19,lgt.alt_segment19)   ALT_SEGMENT19
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment20,lgt.alt_segment20)   ALT_SEGMENT20
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment21,lgt.alt_segment21)   ALT_SEGMENT21
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment22,lgt.alt_segment22)   ALT_SEGMENT22
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment23,lgt.alt_segment23)   ALT_SEGMENT23
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment24,lgt.alt_segment24)   ALT_SEGMENT24
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment25,lgt.alt_segment25)   ALT_SEGMENT25
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment26,lgt.alt_segment26)   ALT_SEGMENT26
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment27,lgt.alt_segment27)   ALT_SEGMENT27
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment28,lgt.alt_segment28)   ALT_SEGMENT28
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment29,lgt.alt_segment29)   ALT_SEGMENT29
      ,decode(lgt.gain_or_loss_flag, 'Y', lgt.segment30,lgt.alt_segment30)   ALT_SEGMENT30
      ,lgt.description
      ,lgt.gl_transfer_mode_code
      ,lgt.merge_duplicate_code
      ,decode(lgt.gain_or_loss_flag, 'Y', decode(lgt.calculate_g_l_amts_flag, 'Y', 'Y', 'N'), lgt.switch_side_flag)      -- 5055878  lgt.switch_side_flag
--      ,lgt.entered_amount
--      ,lgt.ledger_amount
      -- 5055878 amounts modified for reversal method of SIDE or SIGN
      ,DECODE(l_array_switch_side_flag(i),'Y',lgt.unrounded_entered_cr,  -lgt.unrounded_entered_dr)
      ,DECODE(l_array_switch_side_flag(i),'Y',lgt.unrounded_entered_dr,  -lgt.unrounded_entered_cr)
      ,DECODE(l_array_switch_side_flag(i),'Y',lgt.unrounded_accounted_cr,-lgt.unrounded_accounted_dr)
      ,DECODE(l_array_switch_side_flag(i),'Y',lgt.unrounded_accounted_dr,-lgt.unrounded_accounted_cr)
      --
/*
      ,DECODE(lgt.switch_side_flag
             ,C_NO_SWITCH, - lgt.entered_dr
             ,C_SWITCH, lgt.entered_cr
             )
      ,DECODE(lgt.switch_side_flag
             ,C_NO_SWITCH, - lgt.entered_cr
             ,C_SWITCH,   lgt.entered_dr
             )
      ,DECODE(lgt.switch_side_flag
             ,C_NO_SWITCH, - lgt.unrounded_accounted_dr
             ,C_SWITCH,lgt.unrounded_accounted_cr
             )
      ,DECODE(lgt.switch_side_flag
             ,C_NO_SWITCH, - lgt.unrounded_accounted_cr
             ,C_SWITCH, lgt.unrounded_accounted_dr
             )
*/
      ,lgt.entered_currency_mau
      ,lgt.currency_code
      ,lgt.currency_conversion_date
      ,lgt.currency_conversion_rate
      ,lgt.currency_conversion_type
      ,lgt.statistical_amount
      ,lgt.party_id
      ,lgt.party_site_id
      ,lgt.party_type_code
      ,lgt.ussgl_transaction_code
      ,lgt.jgzz_recon_ref
      -- if there are no distributions for this event
      -- populate with the distribution if lines that is being reversed
      ,NVL(l_array_source_dist_id_char_1(i),lgt.source_distribution_id_char_1)
      ,NVL(l_array_source_dist_id_char_2(i),lgt.source_distribution_id_char_2)
      ,NVL(l_array_source_dist_id_char_3(i),lgt.source_distribution_id_char_3)
      ,NVL(l_array_source_dist_id_char_4(i),lgt.source_distribution_id_char_4)
      ,NVL(l_array_source_dist_id_char_5(i),lgt.source_distribution_id_char_5)
      ,NVL(l_array_source_dist_id_num_1(i),lgt.source_distribution_id_num_1)
      ,NVL(l_array_source_dist_id_num_2(i),lgt.source_distribution_id_num_2)
      ,NVL(l_array_source_dist_id_num_3(i),lgt.source_distribution_id_num_3)
      ,NVL(l_array_source_dist_id_num_4(i),lgt.source_distribution_id_num_4)
      ,NVL(l_array_source_dist_id_num_5(i),lgt.source_distribution_id_num_5)
      ,NVL(l_array_source_dist_type(i),lgt.source_distribution_type)
      -- populate reverse distibutions from original line
      ,lgt.source_distribution_id_char_1
      ,lgt.source_distribution_id_char_2
      ,lgt.source_distribution_id_char_3
      ,lgt.source_distribution_id_char_4
      ,lgt.source_distribution_id_char_5
      ,lgt.source_distribution_id_num_1
      ,lgt.source_distribution_id_num_2
      ,lgt.source_distribution_id_num_3
      ,lgt.source_distribution_id_num_4
      ,lgt.source_distribution_id_num_5
      ,lgt.source_distribution_type
      ,lgt.tax_line_ref_id
      ,lgt.tax_summary_line_ref_id
      ,lgt.tax_rec_nrec_dist_ref_id
    -- 4262811
      ,NVL(lgt.header_num,0)  -- 4963422
      ,lgt.mpa_accrual_entry_flag
      ,lgt.multiperiod_option_flag
      ,lgt.multiperiod_start_date
      ,lgt.multiperiod_end_date
    --,lgt.deferred_indicator
    --,lgt.deferred_start_date
    --,lgt.deferred_end_date
    --,lgt.deferred_no_period
    --,lgt.deferred_period_type
      -- populate reversal_code to indicate that line is due to a reversal
      ,'REVERSAL'
      -- denormalize entry status to lines from header to decide on status of new entry
      ,hgt.accounting_entry_status_code
      ,lgt.encumbrance_type_id -- 4458381
      ,'N'    -- lgt.inherit_desc_flag            -- 4219869  Should it be from l_array
      ,l_array_gl_date(i)      -- 5189664     hgt.accounting_date     -- 4955764
      , lgt.BFLOW_APPLICATION_ID
        , lgt.BFLOW_ENTITY_CODE
        , lgt.APPLIED_TO_ENTITY_ID
        , lgt.BFLOW_SOURCE_ID_NUM_1
        , lgt.BFLOW_SOURCE_ID_NUM_2
        , lgt.BFLOW_SOURCE_ID_NUM_3
        , lgt.BFLOW_SOURCE_ID_NUM_4
        , lgt.BFLOW_SOURCE_ID_CHAR_1
        , lgt.BFLOW_SOURCE_ID_CHAR_2
        , lgt.BFLOW_SOURCE_ID_CHAR_3
        , lgt.BFLOW_SOURCE_ID_CHAR_4
        , lgt.BFLOW_DISTRIBUTION_TYPE
        , lgt.BFLOW_DIST_ID_NUM_1
        , lgt.BFLOW_DIST_ID_NUM_2
        , lgt.BFLOW_DIST_ID_NUM_3
        , lgt.BFLOW_DIST_ID_NUM_4
        , lgt.BFLOW_DIST_ID_NUM_5
        , lgt.BFLOW_DIST_ID_CHAR_1
        , lgt.BFLOW_DIST_ID_CHAR_2
        , lgt.BFLOW_DIST_ID_CHAR_3
        , lgt.BFLOW_DIST_ID_CHAR_4
        , lgt.BFLOW_DIST_ID_CHAR_5
 , lgt.alloc_to_application_id      alloc_to_application_id
 , lgt.alloc_to_entity_code     alloc_to_entity_code
 , lgt.alloc_to_source_id_num_1     alloc_to_source_id_num_1
 , lgt.alloc_to_source_id_num_2     alloc_to_source_id_num_2
 , lgt.alloc_to_source_id_num_3     alloc_to_source_id_num_3
 , lgt.alloc_to_source_id_num_4     alloc_to_source_id_num_4
 , lgt.alloc_to_source_id_char_1    alloc_to_source_id_char_1
 , lgt.alloc_to_source_id_char_2    alloc_to_source_id_char_2
 , lgt.alloc_to_source_id_char_3    alloc_to_source_id_char_3
 , lgt.alloc_to_source_id_char_4    alloc_to_source_id_char_4
 , lgt.alloc_to_distribution_type   alloc_to_distribution_type
 , lgt.alloc_to_dist_id_char_1      alloc_to_dist_id_char_1
 , lgt.alloc_to_dist_id_char_2      alloc_to_dist_id_char_2
 , lgt.alloc_to_dist_id_char_3      alloc_to_dist_id_char_3
 , lgt.alloc_to_dist_id_char_4      alloc_to_dist_id_char_4
 , lgt.alloc_to_dist_id_char_5      alloc_to_dist_id_char_5
 , lgt.alloc_to_dist_id_num_1       alloc_to_dist_id_num_1
 , lgt.alloc_to_dist_id_num_2       alloc_to_dist_id_num_2
 , lgt.alloc_to_dist_id_num_3       alloc_to_dist_id_num_3
 , lgt.alloc_to_dist_id_num_4       alloc_to_dist_id_num_4
 , lgt.alloc_to_dist_id_num_5       alloc_to_dist_id_num_5
 , lgt.analytical_balance_flag      analytical_balance_flag  --8417496
 , lgt.anc_id_1
 , lgt.anc_id_2
 , lgt.anc_id_3
 , lgt.anc_id_4
 , lgt.anc_id_5
 , lgt.anc_id_6
 , lgt.anc_id_7
 , lgt.anc_id_8
 , lgt.anc_id_9
 , lgt.anc_id_10
 , lgt.anc_id_11
 , lgt.anc_id_12
 , lgt.anc_id_13
 , lgt.anc_id_14
 , lgt.anc_id_15
 , lgt.anc_id_16
 , lgt.anc_id_17
 , lgt.anc_id_18
 , lgt.anc_id_19
 , lgt.anc_id_20
 , lgt.anc_id_21
 , lgt.anc_id_22
 , lgt.anc_id_23
 , lgt.anc_id_24
 , lgt.anc_id_25
 , lgt.anc_id_26
 , lgt.anc_id_27
 , lgt.anc_id_28
 , lgt.anc_id_29
 , lgt.anc_id_30
 , lgt.anc_id_31
 , lgt.anc_id_32
 , lgt.anc_id_33
 , lgt.anc_id_34
 , lgt.anc_id_35
 , lgt.anc_id_36
 , lgt.anc_id_37
 , lgt.anc_id_38
 , lgt.anc_id_39
 , lgt.anc_id_40
 , lgt.anc_id_41
 , lgt.anc_id_42
 , lgt.anc_id_43
 , lgt.anc_id_44
 , lgt.anc_id_45
 , lgt.anc_id_46
 , lgt.anc_id_47
 , lgt.anc_id_48
 , lgt.anc_id_49
 , lgt.anc_id_50
 , lgt.anc_id_51
 , lgt.anc_id_52
 , lgt.anc_id_53
 , lgt.anc_id_54
 , lgt.anc_id_55
 , lgt.anc_id_56
 , lgt.anc_id_57
 , lgt.anc_id_58
 , lgt.anc_id_59
 , lgt.anc_id_60
 , lgt.anc_id_61
 , lgt.anc_id_62
 , lgt.anc_id_63
 , lgt.anc_id_64
 , lgt.anc_id_65
 , lgt.anc_id_66
 , lgt.anc_id_67
 , lgt.anc_id_68
 , lgt.anc_id_69
 , lgt.anc_id_70
 , lgt.anc_id_71
 , lgt.anc_id_72
 , lgt.anc_id_73
 , lgt.anc_id_74
 , lgt.anc_id_75
 , lgt.anc_id_76
 , lgt.anc_id_77
 , lgt.anc_id_78
 , lgt.anc_id_79
 , lgt.anc_id_80
 , lgt.anc_id_81
 , lgt.anc_id_82
 , lgt.anc_id_83
 , lgt.anc_id_84
 , lgt.anc_id_85
 , lgt.anc_id_86
 , lgt.anc_id_87
 , lgt.anc_id_88
 , lgt.anc_id_89
 , lgt.anc_id_90
 , lgt.anc_id_91
 , lgt.anc_id_92
 , lgt.anc_id_93
 , lgt.anc_id_94
 , lgt.anc_id_95
 , lgt.anc_id_96
 , lgt.anc_id_97
 , lgt.anc_id_98
 , lgt.anc_id_99
 , lgt.anc_id_100

    FROM xla_ae_lines_gt     lgt
        ,xla_ae_headers_gt   hgt
   WHERE hgt.entity_id                  = l_array_entity_id(i)
     AND hgt.ledger_id                  = l_array_ledger_id(i)
     AND hgt.event_number               < l_array_event_number(i)
     AND lgt.event_id                   = hgt.event_id
     AND lgt.ledger_id                  = hgt.ledger_id
     AND lgt.balance_type_code          = hgt.balance_type_code
     -- lines that are reversal lines are not revrsed again
     AND lgt.reversal_code              IS NULL
     -- lines that are reversed earlier are not reversed again
     AND NOT EXISTS (
                SELECT 1
                FROM xla_ae_lines_gt
                WHERE ledger_id        = lgt.ledger_id
                  AND ref_ae_header_id = lgt.ae_header_id  -- 5499367 lgt.ref_ae_header_id
                  AND temp_line_num    = lgt.temp_line_num * -1
               )
     AND lgt.header_num = hgt.header_num     -- 4262811c  Transaction Reversal (not yet finalised)
   ;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Transaction Reversal - Reversal lines created from xla_ae_lines_gt = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;


   --------------------------------------------------------------------------------------------------------------
   -- 5108415 For Transaction Reversal, Store the incomplete MPA/AccRev entries to be used in DeleteIncompleteMPA
   --------------------------------------------------------------------------------------------------------------
   IF p_accounting_mode IN ('F','RESERVE_FUNDS') THEN

      SELECT /*+ Leading(LGT,XET) use_nl(lgt xet aeh ael)*/  -- 5262950
             ael.ae_header_id
            ,ael.ae_line_num
            ,aeh.parent_ae_header_id
      BULK COLLECT INTO
             g_incomplete_mpa_acc_TR.l_array_ae_header_id
            ,g_incomplete_mpa_acc_TR.l_array_ae_line_num
            ,g_incomplete_mpa_acc_TR.l_array_parent_ae_header
      FROM
           xla_ae_lines_gt           lgt
          ,xla_ae_lines              ael
          ,xla_ae_headers            aeh
          ,xla_events                xet -- 5262950
      WHERE aeh.application_id                        = l_application_id
      AND lgt.reversal_code                           = 'DUMMY_TR'
      AND xet.application_id                          = l_application_id -- 5262950
      AND xet.entity_id                               = lgt.entity_id    -- 5262950
      AND aeh.event_id                                = xet.event_id     -- 5262950
      AND aeh.ledger_id                               = lgt.ledger_id
      AND aeh.entity_id                               = xet.entity_id    -- 5262950 lgt.entity_id
   -- AND aeh.entity_id                               = lgt.entity_id
      AND ael.application_id                          = aeh.application_id   -- 5262950
      AND ael.ae_header_id                            = aeh.ae_header_id     -- 5262950
      AND aeh.parent_ae_header_id IS NOT NULL AND aeh.accounting_entry_status_code IN ('D','N','I','R','RELATED_EVENT_ERROR');  -- 5262950

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
               (p_msg      => 'Incomplete mpa_acc_TR  count='||g_incomplete_mpa_acc_TR.l_array_ae_header_id.COUNT
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         FOR i in 1..g_incomplete_mpa_acc_TR.l_array_ae_header_id.COUNT LOOP
            trace
               (p_msg      => 'Incomplete mpa_acc_TR  ae_header='||g_incomplete_mpa_acc_TR.l_array_ae_header_id(i)||
                              ' ae_line='||g_incomplete_mpa_acc_TR.l_array_ae_line_num(i)||
                              ' parent='||g_incomplete_mpa_acc_TR.l_array_parent_ae_header(i)
               ,p_level    => C_LEVEL_STATEMENT
               ,p_module   => l_log_module);
         END LOOP;
      END IF;

   END IF;

   --bug#6933157 24-Apr-2008
   -- To consider switch_side_flag depending on the ledger reversal option when gain_or_loss_flag is not
   -- equal to 'Y'. In the following insert below it was defaulted to 'N' due to which the merge_index
   -- was getting calculated differently, leading to receivable being debited with double the amount in case
   -- of receipt reversals on create accounting.

   IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE' THEN
      l_default_switch_side_flag := 'Y';
   ELSE
      l_default_switch_side_flag := 'N';
   END IF;

   --end bug#6933157 24-Apr-2008

   --
   ---------------------------------------------------------------------------------------------------------
   -- reverse the lines in xla_ae_lines table
   --
   -- Some for 4669308:
   --          For MPA entries, only reverse what is necessary , ie create reversal for Complete MPA only.
   --          Do not create reversal for incomplete entry (since it will get deleted anyway).
   --          Also, since the redundant lines will affect ROUNDING calculation.
   --          Need to create reversal in Draft mode also (so can be viewed).
   ---------------------------------------------------------------------------------------------------------
   --
   FORALL i IN 1..l_array_event_id.count
   INSERT INTO xla_ae_lines_gt
      (ae_header_id
      ,temp_line_num
      ,event_id
      ,ref_ae_header_id
      ,ref_ae_line_num
      ,ref_temp_line_num
      ,ref_event_id
      ,balance_type_code
      ,ledger_id
      ,accounting_class_code
      ,event_class_code
      ,event_type_code
      ,line_definition_owner_code
      ,line_definition_code
      ,accounting_line_type_code
      ,accounting_line_code
      ,code_combination_status_code
      ,code_combination_id
      ,alt_ccid_status_code
      ,alt_code_combination_id
      ,description
      ,gl_transfer_mode_code
      ,merge_duplicate_code
      ,switch_side_flag   -- 5055878
--      ,entered_amount
--      ,ledger_amount
      ,unrounded_entered_dr
      ,unrounded_entered_cr
      ,unrounded_accounted_dr
      ,unrounded_accounted_cr
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
      ,gain_or_loss_flag
      ,rounding_class_code
      ,document_rounding_level
      ,doc_rounding_acctd_amt
      ,doc_rounding_entered_amt
      ,entered_currency_mau
      ,currency_code
      ,currency_conversion_date
      ,currency_conversion_rate
      ,currency_conversion_type
      ,statistical_amount
      ,party_id
      ,party_site_id
      ,party_type_code
      ,ussgl_transaction_code
      ,jgzz_recon_ref
      ,tax_line_ref_id                  -- bug 7159711
      ,tax_summary_line_ref_id          -- bug 7159711
      ,tax_rec_nrec_dist_ref_id         -- bug 7159711
      ,source_distribution_id_char_1
      ,source_distribution_id_char_2
      ,source_distribution_id_char_3
      ,source_distribution_id_char_4
      ,source_distribution_id_char_5
      ,source_distribution_id_num_1
      ,source_distribution_id_num_2
      ,source_distribution_id_num_3
      ,source_distribution_id_num_4
      ,source_distribution_id_num_5
      ,source_distribution_type
      ,reverse_dist_id_char_1
      ,reverse_dist_id_char_2
      ,reverse_dist_id_char_3
      ,reverse_dist_id_char_4
      ,reverse_dist_id_char_5
      ,reverse_dist_id_num_1
      ,reverse_dist_id_num_2
      ,reverse_dist_id_num_3
      ,reverse_dist_id_num_4
      ,reverse_dist_id_num_5
      ,reverse_distribution_type
      ,reversal_code
      ,accounting_entry_status_code
      ,encumbrance_type_id -- 4458381
      ,inherit_desc_flag   -- 4219869
      ,header_num               -- 4669308
      ,mpa_accrual_entry_flag   -- 4262811
      ,accounting_date
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
 , alloc_to_dist_id_num_5         -- 4955764
 , analytical_balance_flag     --8417496
 ,ANC_ID_1 --   8691573
 )
   SELECT /*+ index(xdl XLA_DISTRIBUTION_LINKS_N3) */
       -- populates ae_header_id which is same as event_id till this point
       l_array_event_id(i)
      -- populates temp_line_num which is (-ve) of original line
      ,0 - xdl.temp_line_num
      -- populates event_id which is the event_id of event under process
      ,l_array_event_id(i)
      -- populates ref_ae_header_id which is ae_header_id of original line
      ,ael.ae_header_id
      -- populates ref_ae_line_num which is ae_line_num of original line
      ,ael.ae_line_num
      -- populates ref_temp_line_num which is ae_line_num of original line
      ,xdl.temp_line_num
      -- populates ref_event_id which is event_id of original line
      ,xdl.event_id
      ,aeh.balance_type_code
      ,l_array_ledger_id(i)
      ,ael.accounting_class_code
      ,xdl.event_class_code
      ,xdl.event_type_code
      ,xdl.line_definition_owner_code
      ,xdl.line_definition_code
      ,xdl.accounting_line_type_code
      ,xdl.accounting_line_code
      ,C_CREATED
      ,ael.code_combination_id
      ,C_CREATED
      ,ael.code_combination_id
      ,ael.description
      ,ael.gl_transfer_mode_code
      ,xdl.merge_duplicate_code
      --,decode(ael.gain_or_loss_flag, 'Y', decode(xdl.calculate_g_l_amts_flag, 'Y', 'Y', 'N'), 'N')
                            -- 5055878  switch_side_flag
      -- 5055878 amounts modified for reversal method of SIDE or SIGN
      , decode(ael.gain_or_loss_flag, 'Y', decode(xdl.calculate_g_l_amts_flag, 'Y', 'Y', 'N'), l_default_switch_side_flag)
      --bug#6933157 24-Apr-2008
      ,DECODE(l_array_switch_side_flag(i),'Y',xdl.unrounded_entered_cr,  -xdl.unrounded_entered_dr)
      ,DECODE(l_array_switch_side_flag(i),'Y',xdl.unrounded_entered_dr,  -xdl.unrounded_entered_cr)
      ,DECODE(l_array_switch_side_flag(i),'Y',xdl.unrounded_accounted_cr,-xdl.unrounded_accounted_dr)
      ,DECODE(l_array_switch_side_flag(i),'Y',xdl.unrounded_accounted_dr,-xdl.unrounded_accounted_cr)
      --
      ,xdl.calculate_acctd_amts_flag
      ,xdl.calculate_g_l_amts_flag
      ,ael.gain_or_loss_flag
      ,xdl.rounding_class_code
      ,xdl.document_rounding_level
      ,NULL     -- xdl.doc_rounding_acctd_amt    4669308 creates wrong ROUNDING line for MPA reversal
      ,NULL     -- xdl.doc_rounding_entered_amt  4669308 creates wrong ROUNDING line for MPA reversal
/*
      ,xdl.entered_amount
      ,xdl.ledger_amount
      -- populates entered_dr. amount should be equal to the entered amount in distribution links
      ,DECODE(ael.entered_cr,NULL,NULL,xdl.entered_amount)
      -- populates entered_cr. amount should be equal to the entered amount in distribution links
      ,DECODE(ael.entered_dr,NULL,NULL,xdl.entered_amount)
      -- populates accounted_dr. amount should be equal to the ledger amount in distribution links
      ,DECODE(ael.accounted_cr,NULL,NULL,xdl.ledger_amount)
      -- populates accounted_cr. amount should be equal to the ledger amount in distribution links
      ,DECODE(ael.accounted_dr,NULL,NULL,xdl.ledger_amount)
*/
--      ,ael.entered_cr
--      ,ael.entered_dr
--      ,ael.accounted_cr
--      ,ael.accounted_dr
       --  bug8642358 ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
      ,decode(ael.gain_or_loss_flag, 'Y', 0.01, nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision)))
      ,ael.currency_code
      ,ael.currency_conversion_date
      ,ael.currency_conversion_rate
      ,ael.currency_conversion_type
      ,ael.statistical_amount
      ,ael.party_id
      ,ael.party_site_id
      ,ael.party_type_code
      ,ael.ussgl_transaction_code
      ,ael.jgzz_recon_ref
      -- if there are no distributions for this event
      -- populate with the distribution if lines that is being reversed
      ,NVL(l_array_tax_line_ref(i),xdl.tax_line_ref_id)                   -- bug7159711
      ,NVL(l_array_tax_summary_line_ref(i),xdl.tax_summary_line_ref_id)   -- bug7159711
      ,NVL(l_array_tax_rec_nrec_dist_ref(i),xdl.tax_rec_nrec_dist_ref_id) -- bug7159711
      ,NVL(l_array_source_dist_id_char_1(i),xdl.source_distribution_id_char_1)
      ,NVL(l_array_source_dist_id_char_2(i),xdl.source_distribution_id_char_2)
      ,NVL(l_array_source_dist_id_char_3(i),xdl.source_distribution_id_char_3)
      ,NVL(l_array_source_dist_id_char_4(i),xdl.source_distribution_id_char_4)
      ,NVL(l_array_source_dist_id_char_5(i),xdl.source_distribution_id_char_5)
      ,NVL(l_array_source_dist_id_num_1(i),xdl.source_distribution_id_num_1)
      ,NVL(l_array_source_dist_id_num_2(i),xdl.source_distribution_id_num_2)
      ,NVL(l_array_source_dist_id_num_3(i),xdl.source_distribution_id_num_3)
      ,NVL(l_array_source_dist_id_num_4(i),xdl.source_distribution_id_num_4)
      ,NVL(l_array_source_dist_id_num_5(i),xdl.source_distribution_id_num_5)
      ,NVL(l_array_source_dist_type(i),xdl.source_distribution_type)
      ,xdl.source_distribution_id_char_1
      ,xdl.source_distribution_id_char_2
      ,xdl.source_distribution_id_char_3
      ,xdl.source_distribution_id_char_4
      ,xdl.source_distribution_id_char_5
      ,xdl.source_distribution_id_NUM_1
      ,xdl.source_distribution_id_NUM_2
      ,xdl.source_distribution_id_NUM_3
      ,xdl.source_distribution_id_NUM_4
      ,xdl.source_distribution_id_NUM_5
      ,xdl.source_distribution_type
      -- populate reversal_code indicating that line is result of reversal
      ,'REVERSAL'
      -- denormalises entry status from headers to line to determine the status of entry being created
      -- populates 0 for a valid entry (F or D) else poulates 1
      ,DECODE(aeh.accounting_entry_status_code,'F',0,'D',0,1)
      ,ael.encumbrance_type_id  -- 4458381
      ,'N'            -- 4219869 inherit_desc_flag  Should it be from l_array?
     -- ,0              -- 4669308 combine header with reversal of original entry -- commented  for bug8505463
     , DECODE(aeh.parent_ae_header_id , NULL , 0 ,
                                        CASE
                                        WHEN aeh.accounting_date <= l_array_gl_date(i)
                                        THEN 0
                                        ELSE -1 * dense_rank() over ( partition by aeh.parent_ae_header_id , aeh.parent_ae_line_num
                                                                      order by ael.ae_header_Id )
                                        END
            )                                              HEADER_NUM -- added for bug8505463 for MPA Cancellation
      ,'N'            -- 4262811 mpa_accrual_entry_flag
--      ,l_array_gl_date(i)    -- 5189664    aeh.accounting_date  -- 4955764 -- commented  for bug8505463
     , DECODE(aeh.parent_ae_header_id , NULL , l_array_gl_date(i) ,  -- Regular Cancellation, hence Cancellation Event Date
                                        CASE
                                        WHEN aeh.accounting_date <= l_array_gl_date(i)
                                             THEN l_array_gl_date(i)  -- Accounting Date of Cancellation Event for prior Period's MPA Accounting
                                        ELSE aeh.accounting_date          -- Accounting Date of Original MPA Accounting
                                        END
 	               )                          ACCOUNTING_DATE                 -- added for bug8505463 for MPA Cancellation
      , xdl.APPLIED_TO_APPLICATION_ID   APPLIED_TO_APPLICATION_ID
 , xdl.APPLIED_TO_ENTITY_CODE       APPLIED_TO_ENTITY_CODE
 , xdl.APPLIED_TO_ENTITY_ID     APPLIED_TO_ENTITY_ID
 , xdl.APPLIED_TO_SOURCE_ID_NUM_1   APPLIED_TO_SOURCE_ID_NUM_1
 , xdl.APPLIED_TO_SOURCE_ID_NUM_2   APPLIED_TO_SOURCE_ID_NUM_2
 , xdl.APPLIED_TO_SOURCE_ID_NUM_3   APPLIED_TO_SOURCE_ID_NUM_3
 , xdl.APPLIED_TO_SOURCE_ID_NUM_4   APPLIED_TO_SOURCE_ID_NUM_4
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_1  APPLIED_TO_SOURCE_ID_CHAR_1
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_2  APPLIED_TO_SOURCE_ID_CHAR_2
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_3  APPLIED_TO_SOURCE_ID_CHAR_3
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_4  APPLIED_TO_SOURCE_ID_CHAR_4
 , xdl.APPLIED_TO_DISTRIBUTION_TYPE APPLIED_TO_DISTRIBUTION_TYPE
 , xdl.APPLIED_TO_DIST_ID_NUM_1     APPLIED_TO_DIST_ID_NUM_1
 , xdl.APPLIED_TO_DIST_ID_NUM_2     APPLIED_TO_DIST_ID_NUM_2
 , xdl.APPLIED_TO_DIST_ID_NUM_3     APPLIED_TO_DIST_ID_NUM_3
 , xdl.APPLIED_TO_DIST_ID_NUM_4     APPLIED_TO_DIST_ID_NUM_4
 , xdl.APPLIED_TO_DIST_ID_NUM_5     APPLIED_TO_DIST_ID_NUM_5
 , xdl.APPLIED_TO_DIST_ID_CHAR_1    APPLIED_TO_DIST_ID_CHAR_1
 , xdl.APPLIED_TO_DIST_ID_CHAR_2    APPLIED_TO_DIST_ID_CHAR_2
 , xdl.APPLIED_TO_DIST_ID_CHAR_3    APPLIED_TO_DIST_ID_CHAR_3
 , xdl.APPLIED_TO_DIST_ID_CHAR_4    APPLIED_TO_DIST_ID_CHAR_4
 , xdl.APPLIED_TO_DIST_ID_CHAR_5    APPLIED_TO_DIST_ID_CHAR_5
 , xdl.alloc_to_application_id      alloc_to_application_id
 , xdl.alloc_to_entity_code     alloc_to_entity_code
 , xdl.alloc_to_source_id_num_1     alloc_to_source_id_num_1
 , xdl.alloc_to_source_id_num_2     alloc_to_source_id_num_2
 , xdl.alloc_to_source_id_num_3     alloc_to_source_id_num_3
 , xdl.alloc_to_source_id_num_4     alloc_to_source_id_num_4
 , xdl.alloc_to_source_id_char_1    alloc_to_source_id_char_1
 , xdl.alloc_to_source_id_char_2    alloc_to_source_id_char_2
 , xdl.alloc_to_source_id_char_3    alloc_to_source_id_char_3
 , xdl.alloc_to_source_id_char_4    alloc_to_source_id_char_4
 , xdl.alloc_to_distribution_type   alloc_to_distribution_type
 , xdl.alloc_to_dist_id_char_1      alloc_to_dist_id_char_1
 , xdl.alloc_to_dist_id_char_2      alloc_to_dist_id_char_2
 , xdl.alloc_to_dist_id_char_3      alloc_to_dist_id_char_3
 , xdl.alloc_to_dist_id_char_4      alloc_to_dist_id_char_4
 , xdl.alloc_to_dist_id_char_5      alloc_to_dist_id_char_5
 , xdl.alloc_to_dist_id_num_1       alloc_to_dist_id_num_1
 , xdl.alloc_to_dist_id_num_2       alloc_to_dist_id_num_2
 , xdl.alloc_to_dist_id_num_3       alloc_to_dist_id_num_3
 , xdl.alloc_to_dist_id_num_4       alloc_to_dist_id_num_4
 , xdl.alloc_to_dist_id_num_5       alloc_to_dist_id_num_5
 , decode(ael.analytical_balance_flag, 'Y','P',
                                  'P','P',
                                  null) analytical_balance_flag  --8417496
,nvl2(ael.analytical_balance_flag,'DUMMY_ANC_'||ael.ae_header_id||ael.ae_line_num,null) ANC_ID_1 --Bug 8691573

   FROM
        xla_ae_lines              ael
       ,xla_ae_headers            aeh
       ,xla_distribution_links    xdl
       ,fnd_currencies            fcu
       ,xla_events                xe
   WHERE aeh.application_id                          = l_application_id
     AND aeh.ledger_id                               = l_array_ledger_id(i)
     AND aeh.entity_id                               = l_array_entity_id(i)
     AND aeh.ae_header_id                            = ael.ae_header_id  /* bug 9194744 */
   --  AND aeh.event_number                            < l_array_event_number(i)
     AND xdl.application_id                          = aeh.application_id
     AND xdl.ae_header_id                        = aeh.ae_header_id         -- 5499367
     -- AND xdl.ref_temp_line_num                       IS NULL  -- 5019460 old
     AND NVL(xdl.temp_line_num,0)                    >= 0        -- 5019460 new
     AND ael.application_id                          = xdl.application_id
     AND ael.ae_header_id                            = xdl.ae_header_id     -- 5499367
     AND ael.ae_line_num                             = xdl.ae_line_num
     AND ael.currency_code                           = fcu.currency_code
     AND NOT EXISTS (
                SELECT /*+ no_unnest */ 1
                FROM xla_distribution_links
                WHERE ref_ae_header_id = xdl.ae_header_id
                  AND temp_line_num    = xdl.temp_line_num * -1
                  AND application_id   = xdl.application_id
               )
     AND NOT EXISTS (
                SELECT /*+ no_unnest */ 1
                FROM xla_ae_lines_gt
                WHERE ref_ae_header_id = xdl.ae_header_id
                  AND temp_line_num    = xdl.temp_line_num * -1
                  AND ledger_id        = l_array_ledger_id(i)
               )
     AND xe.application_id                  = aeh.application_id
     AND xe.event_id                        = aeh.event_id
     AND NVL(xe.budgetary_control_flag,'N') = DECODE(p_accounting_mode
                                                    ,'FUNDS_CHECK','Y'
                                                    ,'FUNDS_RESERVE','Y'
                                                    ,'N')
     AND  ((aeh.parent_ae_header_id IS NOT NULL AND aeh.accounting_entry_status_code = 'F') OR  -- 4669308
           (aeh.parent_ae_header_id IS NULL))                                                   -- 4669308
   GROUP BY
       (0 - xdl.temp_line_num)
      ,ael.ae_header_id
      ,ael.ae_line_num
      ,xdl.temp_line_num
      ,xdl.event_id
      ,aeh.balance_type_code
      ,ael.accounting_class_code
      ,xdl.event_class_code
      ,xdl.event_type_code
      ,xdl.line_definition_owner_code
      ,xdl.line_definition_code
      ,xdl.accounting_line_type_code
      ,xdl.accounting_line_code
      ,xdl.unrounded_entered_cr
      ,xdl.unrounded_entered_dr
      ,xdl.unrounded_accounted_cr
      ,xdl.unrounded_accounted_dr
      ,xdl.calculate_acctd_amts_flag
      ,xdl.calculate_g_l_amts_flag
      ,ael.gain_or_loss_flag
      ,xdl.rounding_class_code
      ,xdl.document_rounding_level
      ,xdl.doc_rounding_acctd_amt
      ,xdl.doc_rounding_entered_amt
      ,ael.code_combination_id
      ,ael.description
      ,ael.gl_transfer_mode_code
      ,xdl.merge_duplicate_code
--      ,ael.entered_cr
--      ,ael.entered_dr
--      ,ael.accounted_cr
--      ,ael.accounted_dr
      ,nvl(fcu.minimum_accountable_unit, power(10, -1* fcu.precision))
      ,ael.currency_code
      ,ael.currency_conversion_date
      ,ael.currency_conversion_rate
      ,ael.currency_conversion_type
      ,ael.statistical_amount
      ,ael.party_id
      ,ael.party_site_id
      ,ael.party_type_code
      ,ael.ussgl_transaction_code
      ,ael.jgzz_recon_ref
      ,aeh.accounting_entry_status_code
      ,ael.encumbrance_type_id
      ,xdl.tax_line_ref_id              -- bug7226263
      ,xdl.tax_summary_line_ref_id      -- bug7226263
      ,xdl.tax_rec_nrec_dist_ref_id     -- bug7226263
      ,xdl.source_distribution_id_char_1
      ,xdl.source_distribution_id_char_2
      ,xdl.source_distribution_id_char_3
      ,xdl.source_distribution_id_char_4
      ,xdl.source_distribution_id_char_5
      ,xdl.source_distribution_id_NUM_1
      ,xdl.source_distribution_id_NUM_2
      ,xdl.source_distribution_id_NUM_3
      ,xdl.source_distribution_id_NUM_4
      ,xdl.source_distribution_id_NUM_5
      ,xdl.source_distribution_type
      ,aeh.accounting_date
      , aeh.parent_ae_header_id  -- added for bug8505463
      , aeh.parent_ae_line_num -- added for bug8505463
      , xdl.APPLIED_TO_APPLICATION_ID
 , xdl.APPLIED_TO_ENTITY_CODE
 , xdl.APPLIED_TO_ENTITY_ID
 , xdl.APPLIED_TO_SOURCE_ID_NUM_1
 , xdl.APPLIED_TO_SOURCE_ID_NUM_2
 , xdl.APPLIED_TO_SOURCE_ID_NUM_3
 , xdl.APPLIED_TO_SOURCE_ID_NUM_4
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_1
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_2
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_3
 , xdl.APPLIED_TO_SOURCE_ID_CHAR_4
 , xdl.APPLIED_TO_DISTRIBUTION_TYPE
 , xdl.APPLIED_TO_DIST_ID_NUM_1
 , xdl.APPLIED_TO_DIST_ID_NUM_2
 , xdl.APPLIED_TO_DIST_ID_NUM_3
 , xdl.APPLIED_TO_DIST_ID_NUM_4
 , xdl.APPLIED_TO_DIST_ID_NUM_5
 , xdl.APPLIED_TO_DIST_ID_CHAR_1
 , xdl.APPLIED_TO_DIST_ID_CHAR_2
 , xdl.APPLIED_TO_DIST_ID_CHAR_3
 , xdl.APPLIED_TO_DIST_ID_CHAR_4
 , xdl.APPLIED_TO_DIST_ID_CHAR_5
 , xdl.alloc_to_application_id
 , xdl.alloc_to_entity_code
 , xdl.alloc_to_source_id_num_1
 , xdl.alloc_to_source_id_num_2
 , xdl.alloc_to_source_id_num_3
 , xdl.alloc_to_source_id_num_4
 , xdl.alloc_to_source_id_char_1
 , xdl.alloc_to_source_id_char_2
 , xdl.alloc_to_source_id_char_3
 , xdl.alloc_to_source_id_char_4
 , xdl.alloc_to_distribution_type
 , xdl.alloc_to_dist_id_char_1
 , xdl.alloc_to_dist_id_char_2
 , xdl.alloc_to_dist_id_char_3
 , xdl.alloc_to_dist_id_char_4
 , xdl.alloc_to_dist_id_char_5
 , xdl.alloc_to_dist_id_num_1
 , xdl.alloc_to_dist_id_num_2
 , xdl.alloc_to_dist_id_num_3
 , xdl.alloc_to_dist_id_num_4
 , xdl.alloc_to_dist_id_num_5
 , ael.analytical_balance_flag --8417496
, nvl2(ael.analytical_balance_flag,'DUMMY_ANC_'||ael.ae_header_id||ael.ae_line_num,null) --Bug 8691573
   ;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Transaction Reversal - Reversal lines created from xla_ae_lines = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

 -- 8919497 : update DUMMY value into anc_id_1 column in xla_ae_lines_gt to avoid merging of lines which has supporting reference details.
  update xla_ae_lines_gt gt
  set anc_id_1 = (select 'DUMMY_ANC_'||xac.ae_header_id||xac.ae_line_num
                  from xla_ae_line_acs xac
                  where gt.ref_ae_header_id= xac.ae_header_id
                  and gt.ref_ae_line_num=xac.ae_line_num
                  and rownum<2
                  )
  where gt.temp_line_num <0
  and gt.reversal_code='REVERSAL'
  and gt.ref_ae_header_id<> gt.ae_header_id;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_msg      => 'Supporting Reference - Lines updated in xla_ae_lines_gt = '||SQL%ROWCOUNT
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
   END IF;

  -- bug7135700 code change, case: reversal lines created for primary but not for secondary for same event.

IF l_upgrade_check = 1 THEN

SELECT min(xla_ae_headers.accounting_date)
INTO l_min_ref_event_date
FROM xla_ae_lines_gt gt1, xla_ae_headers
WHERE gt1.reversal_code = 'REVERSAL'
AND gt1.ref_event_id = xla_ae_headers.event_id;

l_error_count := 0;



 IF l_min_ref_event_date <= l_max_first_open_period  THEN

 print_logfile('***************************************************************************************************');
 print_logfile('The following REVERSAL (TR) events do not have historic entries replicated in secondary/alc ledgers');
 print_logfile('Manual GL adjustments in the secondary/alc ledgers needs to be done for these events');


 FOR c_not_reversed_entries IN
 (SELECT DISTINCT gt1.event_id, gt1.ledger_id
 FROM xla_ae_lines_gt gt1, gl_ledgers gll
 WHERE gt1.reversal_code = 'DUMMY_TR'
 AND gll.ledger_id = gt1.ledger_id
 AND gll.ledger_category_code <> 'PRIMARY'
 AND NOT EXISTS (SELECT 1
                 FROM xla_ae_lines_gt gt2
         WHERE gt2.reversal_code = 'REVERSAL'
         AND gt1.event_id = gt2.event_id
         AND gt1.ledger_id = gt2.ledger_id)
 AND EXISTS (SELECT 1
            FROM xla_ae_lines_gt gt3
            WHERE gt3.reversal_code = 'REVERSAL'
        AND gt1.event_id = gt3.event_id))

 LOOP
  --IF (C_LEVEL_STATEMENT >= g_log_level) THEN
  --    trace
  --       (p_msg      => 'WARNING - Reversal (TR) lines could not be created for event  ' || c_not_reversed_entries.event_id || ' of ledger ' || c_not_reversed_entries.ledger_id || '. Please create Manual Adjustment Entries.'
  --       ,p_level    => C_LEVEL_STATEMENT
  --       ,p_module   => l_log_module);
  --END IF;
  print_logfile('Event ' || c_not_reversed_entries.event_id || ' of ledger ' || c_not_reversed_entries.ledger_id);
  l_error_count := l_error_count + 1;
 END LOOP;

 IF l_error_count > 0 THEN
   g_hist_reversal_error_exists := TRUE;
 END IF;

 IF l_error_count = 0 THEN
 print_logfile('    NO SUCH ENTRIES');
 END IF;

 print_logfile('***************************************************************************************************');

END IF;
END IF;

 -- bug7135700 code change end


   --
   -- select all the reversal lines that do not have a header in xla_ae_headers_gt
   --
   SELECT event_id
         ,ledger_id
         ,balance_type_code
         ,max(accounting_entry_status_code)
         ,NVL(header_num,0)                   -- 4262811c missing mpa reversal lines, 4963422 set header_num to 0
	 ,accounting_date                 -- added for bug8505463
     BULK COLLECT INTO
          l_array_event_id
         ,l_array_ledger_id
         ,l_array_balance_type_code
         ,l_array_entry_status_code
         ,l_array_header_num                  -- 4262811c missing mpa reversal lines
	 ,l_array_accounting_date         -- added for bug8505463
     FROM xla_ae_lines_gt  lgt
    WHERE reversal_code = 'REVERSAL'
      AND NOT EXISTS
         (SELECT 1
            FROM xla_ae_headers_gt
           WHERE event_id = lgt.event_id
             AND ledger_id = lgt.ledger_id
          -- AND nvl(header_num, -1) = nvl(lgt.header_num, -1)  -- 4262811c missing mpa reversal lines
                                                                -- 4669308  NVL(-1) give separate headers for MPA
                                                                --          also causing XLA_AE_LINES_U1 error
             AND nvl(header_num,  0) = nvl(lgt.header_num,  0)  -- 4669308  NVL(0) combine replacement and MPA to 1 header
             AND balance_type_code = lgt.balance_type_code
	     AND accounting_date   = lgt.accounting_date ) -- added for bug8505463
    GROUP BY event_id
            ,ledger_id
            ,header_num                       -- 4262811c missing mpa reversal lines
            ,balance_type_code
	    ,accounting_date
    ORDER BY event_id
             ,ledger_id
             ,balance_type_code
             ,accounting_date
             ,header_num ;   -- added for bug 8505463 to sequence the headers based on accounting_date when multiple headers

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Number of Headers that need to be created for reversal lines = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   --
   -- inserting new rows in xla_ae_headers_gt for the reversal lines that did not have a header
   --
   FORALL I IN 1..l_array_event_id.count
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
          , period_name
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
          , header_num              -- 4262811c  MPA header for line reversal
          ,accrual_reversal_flag)   -- 4262811
       (SELECT
            ae_header_id
          , l_array_entry_status_code(i)
          , accounting_entry_type_code
          , ledger_id
          , entity_id
          , event_id
          , event_type_code
          --, accounting_date commented for bug8505463
	  , CASE
              WHEN l_array_header_num(i) <>  0
              THEN l_array_accounting_date(i)
              ELSE accounting_date
              END                                -- added for bug8505463
          , product_rule_type_code
          , product_rule_code
          , product_rule_version
          , je_category_name
          , period_name
          , doc_sequence_id
          , doc_sequence_value
          , description
          , DECODE(l_array_balance_type_code(i),'B',budget_version_id,NULL) -- 4924492
          --, encumbrance_type_id
          , l_array_balance_type_code(i)
          , amb_context_code
          , doc_category_code
          , gl_transfer_status_code
          , decode(l_array_entry_status_code(i),XLA_AE_JOURNAL_ENTRY_PKG.C_VALID,'X','I')
          , l_array_header_num(i)    -- 4262811c  MPA header for line reversal
          , accrual_reversal_flag    -- 4262811a
       FROM xla_ae_headers_gt
      WHERE event_id = l_array_event_id(i)
        AND ledger_id = l_array_ledger_id(i)
        AND balance_type_code = 'X'
        AND NVL(header_num,0) = 0);   -- 5183946  xla_ae_headers_gt_u1 error


   IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'Headers inserted in xla_ae_headers_gt = '||TO_CHAR(SQL%ROWCOUNT)
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;
   --

-- bug 7253269 reversal error start

 l_error_count := 0;

 print_logfile('***************************************************************************************************');
 print_logfile('The following REVERSAL events could not be processed. The event/process status is U/U: ');
 print_logfile('Note: this warning may be ignored for any events whose ledger is a cash-basis ledger');



 FOR c_not_reversed_entries IN
 (SELECT DISTINCT gt1.event_id, gt1.ledger_id
 FROM xla_ae_lines_gt gt1
 WHERE gt1.reversal_code IN ('DUMMY_LR', 'DUMMY_TR')
 AND NOT EXISTS (SELECT 1
                 FROM xla_ae_lines_gt gt2
         WHERE gt2.reversal_code = 'REVERSAL'
         AND gt1.event_id = gt2.event_id
         AND gt1.ledger_id = gt2.ledger_id))


 LOOP
  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'EVENT not reversed ' || c_not_reversed_entries.event_id || ' of ledger ' || c_not_reversed_entries.ledger_id
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
  print_logfile('Event ' || c_not_reversed_entries.event_id || ' of ledger ' || c_not_reversed_entries.ledger_id);
  l_error_count := l_error_count + 1;
 END LOOP;

 IF l_error_count > 0 THEN
   xla_accounting_cache_pkg.g_reversal_error := TRUE;
 END IF;

 IF l_error_count = 0 THEN
  print_logfile('-------NO SUCH EVENTS-----------');
  IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace
         (p_msg      => 'No errors related to reversal'
         ,p_level    => C_LEVEL_EVENT
         ,p_module   => l_log_module);
   END IF;
 END IF;

 print_logfile('***************************************************************************************************');


-- bug 7253269 reversal error end



   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of AccountingReversal'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_ae_lines_pkg.AccountingReversal');
END AccountingReversal;
--
/*======================================================================+
|                                                                       |
| PUBLIC Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION SetLineNum(
  p_balance_type_code      IN VARCHAR2
)
RETURN NUMBER
IS
l_line_num                  NUMBER;
l_log_module                VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetLineNum';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of SetLineNum'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_balance_type_code = '||p_balance_type_code
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
CASE p_balance_type_code
  --
  WHEN C_ACTUAL         THEN
     --
     g_ActualLineNum                                     := NVL(g_ActualLineNum,0) + 1 ;
     l_line_num                                          := g_ActualLineNum;
     --
  WHEN C_BUDGET         THEN
     --
     g_BudgetLineNum                                     := NVL(g_BudgetLineNum,0) + 1 ;
     l_line_num                                          := g_BudgetLineNum;
     --
  WHEN C_ENCUMBRANCE    THEN
     --
     g_EncumbLineNum                                     := NVL(g_EncumbLineNum,0) + 1 ;
     l_line_num                                          := g_EncumbLineNum;
     --
  ELSE  null;
--
END CASE;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. = '||TO_CHAR(l_line_num)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of SetLineNum'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_line_num;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetLineNum');
  --
END SetLineNum;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetRevAccountingSource (
  p_accounting_source      IN VARCHAR2
, p_standard_source        IN VARCHAR2
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN NUMBER
)
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetRevAccountingSource';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetRevAccountingSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_accounting_source = '||p_accounting_source
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_standard_source = '||p_standard_source
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

           trace
              (p_msg      => 'p_source_code = '||p_source_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'p_source_type_code = '||p_source_type_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'p_source_application_id = '||p_source_application_id
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

END IF;
--
CASE p_accounting_source
  --
  -- line accounting sources
  --
  WHEN 'PARTY_TYPE'                THEN

             g_reverse_lines.party_type_code        := p_standard_source;

  WHEN 'ENTERED_CURRENCY_CODE'     THEN g_reverse_lines.currency_code          := p_standard_source;
  --
  -- accounting reversal
  --
  WHEN 'ACCOUNTING_REVERSAL_OPTION' THEN g_reverse_lines.acc_reversal_option   := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_TYPE' THEN g_reverse_lines.sys_distribution_type := p_standard_source;
  WHEN 'DISTRIBUTION_TYPE'          THEN g_reverse_lines.rev_sys_distribution_type := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID1'  THEN g_reverse_lines.distribution_id_char_1 := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID2'  THEN g_reverse_lines.distribution_id_char_2 := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID3'  THEN g_reverse_lines.distribution_id_char_3 := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID4'  THEN g_reverse_lines.distribution_id_char_4 := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID5'  THEN g_reverse_lines.distribution_id_char_5 := p_standard_source;
  --
  WHEN 'DISTRIBUTION_IDENTIFIER_1'  THEN g_reverse_lines.rev_distrib_id_char_1 := p_standard_source;
  WHEN 'DISTRIBUTION_IDENTIFIER_2'  THEN g_reverse_lines.rev_distrib_id_char_2 := p_standard_source;
  WHEN 'DISTRIBUTION_IDENTIFIER_3'  THEN g_reverse_lines.rev_distrib_id_char_3 := p_standard_source;
  WHEN 'DISTRIBUTION_IDENTIFIER_4'  THEN g_reverse_lines.rev_distrib_id_char_4 := p_standard_source;
  WHEN 'DISTRIBUTION_IDENTIFIER_5'  THEN g_reverse_lines.rev_distrib_id_char_5 := p_standard_source;
  --
  -- line base currency accounting sources
  --
  WHEN 'EXCHANGE_RATE_TYPE'        THEN g_reverse_lines.curr_conversion_type := p_standard_source;
  WHEN 'USSGL_TRANSACTION_CODE'    THEN g_reverse_lines.ussgl_transaction    := p_standard_source;
  WHEN 'RECON_REF'                 THEN g_reverse_lines.jgzz_recon_ref       := p_standard_source;

  ELSE null;
--
END CASE;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of SetRevAccountingSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetRevAccountingSource');
  --
END SetRevAccountingSource;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetRevAccountingSource (
  p_accounting_source      IN VARCHAR2
, p_standard_source        IN NUMBER
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN NUMBER
)
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetRevAccountingSource';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetRevAccountingSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_accounting_source = '||p_accounting_source
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_standard_source = '||p_standard_source
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

           trace
              (p_msg      => 'p_source_code = '||p_source_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'p_source_type_code = '||p_source_type_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'p_source_application_id = '||p_source_application_id
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

END IF;

--
CASE p_accounting_source

  WHEN 'LEDGER_AMOUNT'                 THEN g_reverse_lines.ledger_amount             := p_standard_source;
  WHEN 'EXCHANGE_RATE'                 THEN g_reverse_lines.curr_conversion_rate      := p_standard_source;
  WHEN 'PARTY_ID'                      THEN g_reverse_lines.party_id                  := p_standard_source;
  WHEN 'PARTY_SITE_ID'                 THEN g_reverse_lines.party_site_id             := p_standard_source;
  WHEN 'ENTERED_CURRENCY_AMOUNT'       THEN g_reverse_lines.entered_amount            := p_standard_source;
  WHEN 'STATISTICAL_AMOUNT'            THEN g_reverse_lines.statistical_amount        := p_standard_source;


  WHEN 'TAX_LINE_REF_ID'               THEN g_reverse_lines.tax_line_ref          := p_standard_source;
  WHEN 'TAX_SUMMARY_LINE_REF_ID'       THEN g_reverse_lines.tax_summary_line_ref  := p_standard_source;
  WHEN 'TAX_REC_NREC_DIST_REF_ID'      THEN g_reverse_lines.tax_rec_nrec_dist_ref := p_standard_source;
--
  WHEN 'REVERSED_DISTRIBUTION_ID1'    THEN g_reverse_lines.distribution_id_num_1   := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID2'    THEN g_reverse_lines.distribution_id_num_2   := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID3'    THEN g_reverse_lines.distribution_id_num_3   := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID4'    THEN g_reverse_lines.distribution_id_num_4   := p_standard_source;
  WHEN 'REVERSED_DISTRIBUTION_ID5'    THEN g_reverse_lines.distribution_id_num_5   := p_standard_source;
  --
  WHEN 'DISTRIBUTION_IDENTIFIER_1'    THEN g_reverse_lines.rev_distrib_id_num_1   := p_standard_source;
  WHEN 'DISTRIBUTION_IDENTIFIER_2'    THEN g_reverse_lines.rev_distrib_id_num_2   := p_standard_source;
  WHEN 'DISTRIBUTION_IDENTIFIER_3'    THEN g_reverse_lines.rev_distrib_id_num_3   := p_standard_source;
  WHEN 'DISTRIBUTION_IDENTIFIER_4'    THEN g_reverse_lines.rev_distrib_id_num_4   := p_standard_source;
  WHEN 'DISTRIBUTION_IDENTIFIER_5'    THEN g_reverse_lines.rev_distrib_id_num_5   := p_standard_source;
  --
  WHEN 'REVERSED_UPGRADE_DEBIT_CCID'  THEN g_reverse_lines.reversal_debit_ccid     := p_standard_source;
  WHEN 'REVERSED_UPGRADE_CREDIT_CCID' THEN g_reverse_lines.reversal_credit_ccid    := p_standard_source;
  --
  ELSE null;
--
END CASE;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of SetRevAccountingSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetRevAccountingSource');
  --
END SetRevAccountingSource;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetRevAccountingSource (
  p_accounting_source      IN VARCHAR2
, p_standard_source        IN DATE
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN NUMBER
)
IS
l_log_module         VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetRevAccountingSource';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetRevAccountingSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_accounting_source = '||p_accounting_source
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_standard_source = '||p_standard_source
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

           trace
              (p_msg      => 'p_source_code = '||p_source_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'p_source_type_code = '||p_source_type_code
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

           trace
              (p_msg      => 'p_source_application_id = '||p_source_application_id
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

END IF;
--
CASE p_accounting_source
  --
  -- line accounting sources
  --
  -- 4262811 MPA ------------------------------------------------------------------------------------
  WHEN 'MULTIPERIOD_START_DATE'    THEN g_reverse_lines.mpa_start_date      := p_standard_source;
  WHEN 'MULTIPERIOD_END_DATE'      THEN g_reverse_lines.mpa_end_date        := p_standard_source;
--WHEN 'DEFERRED_START_DATE'       THEN g_reverse_lines.deferred_start_date := p_standard_source;
--WHEN 'DEFERRED_END_DATE'         THEN g_reverse_lines.deferred_end_date   := p_standard_source;
  ---------------------------------------------------------------------------------------------------
  WHEN 'EXCHANGE_DATE'             THEN g_reverse_lines.curr_conversion_date:= p_standard_source;
  --
  ELSE null;
--
END CASE;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of SetRevAccountingSource'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.SetRevAccountingSource');
END SetRevAccountingSource;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
| This procedure is no longer used after attribute enhancement project  |
|                                                                       |
+======================================================================*/
--
-- This might not be needed with bulk perfromance changes
--
/*
PROCEDURE accounting_reversal(p_accounting_reversal_option IN VARCHAR2
                             ,p_transaction_reversal       IN OUT NOCOPY NUMBER)
IS
l_null_rev_line        t_rec_reverse_line;
l_transaction_reversal NUMBER;
l_log_module           VARCHAR2(240);
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.accounting_reversal';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of accounting_reversal'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
          (p_msg      => 'p_accounting_reversal_option = '||p_accounting_reversal_option
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'p_transaction_reversal = '||p_transaction_reversal
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_transaction_reversal:= p_transaction_reversal ;
--

  IF   p_accounting_reversal_option IN ('Y','B','Z','C') AND
       g_reverse_lines.sys_distribution_type IS NULL AND
       l_transaction_reversal = 0 THEN

--       TransactionReversal;
       l_transaction_reversal:= 1;

  ELSIF p_accounting_reversal_option IN ('Y','B','Z','C') AND
        g_reverse_lines.sys_distribution_type IS NOT NULL AND
        l_transaction_reversal IN (0,2) THEN

--    StandardAccountingReversal;
--      (p_accounting_reversal_option => p_accounting_reversal_option
--      );
    l_transaction_reversal:= 2;


  ELSIF p_accounting_reversal_option = 'U' THEN

    UpgradeAccountingReversal;

  ELSIF p_accounting_reversal_option IN ('Y','B','Z','C') AND
        g_reverse_lines.sys_distribution_type IS NULL AND
        l_transaction_reversal = 1
  THEN
     XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;

     xla_accounting_err_pkg.build_message
                                        (p_appli_s_name            => 'XLA'
                                        ,p_msg_name                => 'XLA_AP_TRANS_REVERSAL_INCONST'
                                        ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                        ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                        ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
    );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
                        trace
                           (p_msg      => 'ERROR: XLA_AP_TRANS_REVERSAL_INCONST'
                           ,p_level    => C_LEVEL_ERROR
                           ,p_module   => l_log_module);
    END IF;

  ELSE
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;

      xla_accounting_err_pkg.build_message
                                              (p_appli_s_name            => 'XLA'
                                              ,p_msg_name                => 'XLA_AP_REVERSAL_INCONSISTENT'
                                              ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                              ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                              ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
    );

    IF (C_LEVEL_ERROR >= g_log_level) THEN
                        trace
                           (p_msg      => 'ERROR: XLA_AP_REVERSAL_INCONSISTENT'
                           ,p_level    => C_LEVEL_ERROR
                           ,p_module   => l_log_module);
    END IF;

  END IF;

  p_transaction_reversal:= l_transaction_reversal ;
--
-- Reset reverse line record
--
  g_reverse_lines                := l_null_rev_line;
--
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'return value. p_transaction_reversal = '||p_transaction_reversal
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

      trace
         (p_msg      => 'END of accounting_reversal'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  XLA_AE_JOURNAL_ENTRY_PKG.g_global_status       := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_LINES_PKG.accounting_reversal');
  --
END accounting_reversal;
--
*/
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
+======================================================================*/
--
--bulk performance
--
procedure set_ae_header_id
       (p_ae_header_id      in number
       ,p_header_num        in number) is   -- 4262811

l_log_module     varchar2(240);
begin
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.set_ae_header_id';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of set_ae_header_id'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'p_ae_header_id = '||p_ae_header_id
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
g_rec_lines.array_ae_header_id(g_LineNumber) := p_ae_header_id;
g_rec_lines.array_header_num(g_LineNumber)   := p_header_num;   -- 4262811

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of set_ae_header_id'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
end set_ae_header_id;
--
/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
procedure SetLineAcctAttrs
       (p_rec_acct_attrs    in t_rec_acct_attrs) is
l_log_module                 VARCHAR2(240);
l_attr_error                 VARCHAR2(30);
l_invalid_attr               VARCHAR2(30) := 'XLA_AP_INVALID_LINE_ATTR';
l_missing_attr               VARCHAR2(30) := 'XLA_AP_MISSING_LINE_ATTR';

BEGIN

IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetLineAcctAttrs';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of SetLineAcctAttrs'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
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

  l_attr_error := NULL; -- 5162408

  CASE p_rec_acct_attrs.array_acct_attr_code(i)

  WHEN 'PARTY_TYPE'                THEN

     -- 4693816 Do not assign if size is more than 1
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        IF length(p_rec_acct_attrs.array_char_value(i)) > 1 THEN
           g_rec_lines.array_party_type_code(g_LineNumber)     := 'X';
           l_attr_error := l_invalid_attr;
        ELSE
           g_rec_lines.array_party_type_code(g_LineNumber)     := p_rec_acct_attrs.array_char_value(i);
        END IF;
     ELSE
        -- 5162408
        g_rec_lines.array_party_type_code(g_LineNumber)  := NULL;
        IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
           l_attr_error := l_invalid_attr;
        END IF;
     END IF;

  WHEN 'ENTERED_CURRENCY_CODE'     THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) AND length(p_rec_acct_attrs.array_char_value(i)) <= 15 THEN
        g_rec_lines.array_currency_code(g_LineNumber)  := p_rec_acct_attrs.array_char_value(i);
        g_rec_lines.array_currency_mau(g_LineNumber)   := xla_accounting_cache_pkg.GetCurrencyMau(p_rec_acct_attrs.array_char_value(i));
     ELSE
        -- 5162408
        g_rec_lines.array_currency_code(g_LineNumber)  := ' ';  -- otherwise insert NULL error in currency_code
        g_rec_lines.array_currency_mau(g_LineNumber)   := 0.01; -- dummy MAU
        IF (p_rec_acct_attrs.array_num_value.EXISTS(i)) OR
           (p_rec_acct_attrs.array_char_value.EXISTS(i) AND p_rec_acct_attrs.array_char_value(i) IS NOT NULL) THEN
           l_attr_error := l_invalid_attr;   -- wrong datatype or too long
        ELSE
           l_attr_error := l_missing_attr;   -- required
        END IF;
     END IF;

  -------------------------------------------------------------------
  -- 4262811 - replaced DEFERRED
  -------------------------------------------------------------------
--WHEN 'DEFERRED_INDICATOR'        THEN
--   g_rec_lines.array_deferred_indicator(g_LineNumber)     := p_rec_acct_attrs.array_char_value(i);
--WHEN 'DEFERRED_PERIOD_TYPE'      THEN
--   g_rec_lines.array_deferred_period_type(g_LineNumber)   := p_rec_acct_attrs.array_char_value(i);
  WHEN 'MULTIPERIOD_OPTION'        THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) AND p_rec_acct_attrs.array_char_value(i) IS NOT NULL THEN
        IF length(p_rec_acct_attrs.array_char_value(i)) = 1 THEN
           g_rec_lines.array_mpa_option(g_LineNumber)  := p_rec_acct_attrs.array_char_value(i);
        ELSE
           g_rec_lines.array_mpa_option(g_LineNumber)  := NULL;
        END IF;

        IF NVL(g_rec_lines.array_mpa_option(g_LineNumber),'N') NOT IN ('Y','N') OR
           length(p_rec_acct_attrs.array_char_value(i)) > 1 THEN
           XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
           xla_accounting_err_pkg.build_message
              (p_appli_s_name            => 'XLA'
              ,p_msg_name                => 'XLA_MA_INVALID_OPTION'   -- 4262811a XLA_AP_INV_DEFERRED_OPTION'
              ,p_token_1                 => 'LINE_NUMBER'
              ,p_value_1                 =>  g_ExtractLine
              ,p_token_2                 => 'ACCOUNTING_SOURCE_NAME'
              ,p_value_2                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName
                                             (p_rec_acct_attrs.array_acct_attr_code(i))
              ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
              ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
              ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
        END IF;
     ELSE
        -- 5162408
        g_rec_lines.array_mpa_option(g_LineNumber)  := NULL;
        IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
           l_attr_error := l_invalid_attr;
        END IF;
     END IF;

  WHEN 'DISTRIBUTION_TYPE'         THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_sys_distribution_type(g_LineNumber)  := p_rec_acct_attrs.array_char_value(i);
     ELSE
       g_rec_lines.array_sys_distribution_type(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     END IF;

     IF g_rec_lines.array_sys_distribution_type(g_LineNumber) IS NULL THEN
        XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
        xla_accounting_err_pkg.build_message
              (p_appli_s_name            => 'XLA'
              ,p_msg_name                => 'XLA_AP_NO_DIST_LINK_TYPE'
              ,p_token_1                 => 'LINE_NUMBER'
              ,p_value_1                 =>  g_ExtractLine
              ,p_token_2                 => 'ACCOUNTING_SOURCE_NAME'
              ,p_value_2                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName
                                                       (p_rec_acct_attrs.array_acct_attr_code(i))
              ,p_token_3                 => 'SOURCE_NAME'
              ,p_value_3                 => NULL
              ,p_token_4                 => 'LINE_TYPE_NAME'
              ,p_value_4                 =>  XLA_AE_SOURCES_PKG.GetComponentName (
                                                        g_accounting_line.component_type
                                                      , g_accounting_line.accounting_line_code
                                                      , g_accounting_line.accounting_line_type_code
                                                      , g_accounting_line.accounting_line_appl_id
                                                      , g_accounting_line.amb_context_code
                                                      , g_accounting_line.entity_code
                                                      , g_accounting_line.event_class_code
                                                     )
              ,p_token_5                 => 'OWNER'
              ,p_value_5                 => xla_lookups_pkg.get_meaning(
                                                        'XLA_OWNER_TYPE'
                                                       , g_rec_lines.array_accounting_line_type(g_LineNumber)
                                                      )
              ,p_token_6                 => 'PRODUCT_NAME'
              ,p_value_6                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
              ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
              ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
              ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
     END IF;

  WHEN 'ACCOUNTING_REVERSAL_OPTION' THEN
     -- 5162408
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        IF length(p_rec_acct_attrs.array_char_value(i)) = 1 THEN
           g_rec_lines.array_acc_reversal_option(g_LineNumber)  := p_rec_acct_attrs.array_char_value(i);
        ELSE
           g_rec_lines.array_acc_reversal_option(g_LineNumber)  := NULL;
        END IF;
        IF NVL(g_rec_lines.array_acc_reversal_option(g_LineNumber),'N') NOT IN ('Y','N','B') OR
           length(p_rec_acct_attrs.array_char_value(i)) > 1 THEN
           l_attr_error := l_invalid_attr;
        END IF;
     ELSE
        g_rec_lines.array_acc_reversal_option(g_LineNumber)  := NULL;
        IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
           l_attr_error := l_invalid_attr;
        END IF;
     END IF;

  WHEN 'EXCHANGE_RATE_TYPE'        THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_curr_conversion_type(g_LineNumber):= p_rec_acct_attrs.array_char_value(i);
     ELSE
       g_rec_lines.array_curr_conversion_type(g_LineNumber):= p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'USSGL_TRANSACTION_CODE'    THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_ussgl_transaction(g_LineNumber)   := p_rec_acct_attrs.array_char_value(i);
     ELSE
       g_rec_lines.array_ussgl_transaction(g_LineNumber)   := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'RECON_REF'                 THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_jgzz_recon_ref(g_LineNumber)      := p_rec_acct_attrs.array_char_value(i);
     ELSE
       g_rec_lines.array_jgzz_recon_ref(g_LineNumber)      := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'OVERRIDE_ACCTD_AMT_FLAG'                 THEN
     -- 5162408
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        IF length(p_rec_acct_attrs.array_char_value(i)) = 1 THEN
           g_override_acctd_amt_flag      := p_rec_acct_attrs.array_char_value(i);
       g_rec_lines.array_override_acctd_amt_flag(g_LineNumber)  := p_rec_acct_attrs.array_char_value(i);
        ELSE
           g_override_acctd_amt_flag      := NULL;
       g_rec_lines.array_override_acctd_amt_flag(g_LineNumber)  := NULL;
        END IF;
        IF NVL(g_override_acctd_amt_flag,'N') NOT IN ('Y','N') OR
           length(p_rec_acct_attrs.array_char_value(i)) > 1 THEN
           l_attr_error := l_invalid_attr;
        END IF;
     ELSE
        g_override_acctd_amt_flag  := NULL;
    g_rec_lines.array_override_acctd_amt_flag(g_LineNumber)  := NULL;
        IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
           l_attr_error := l_invalid_attr;
        END IF;
     END IF;
     -- Bug 7044870
     -- Bug 8238617 set g_override_acctd_amt_flag to null only if the currency_code of secondary,ALC is different from primary
     IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code IN ('SECONDARY','ALC')
     AND xla_accounting_cache_pkg.g_primary_ledger_currency <> XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code
     THEN
       g_override_acctd_amt_flag := NULL;
       g_rec_lines.array_override_acctd_amt_flag(g_LineNumber)  := NULL;
     END IF;
     --

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'g_primary_ledger_currency : '     || xla_accounting_cache_pkg.g_primary_ledger_currency
	                || 'Secondary Ledger Currency code : '|| XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code
			|| 'g_override_acctd_amt_flag : '     || g_override_acctd_amt_flag
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
     END IF;


     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'override_acctd_amt_flag= '||g_override_acctd_amt_flag
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
     END IF;

  WHEN 'GAIN_LOSS_REFERENCE'                 THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_gain_or_loss_ref(g_LineNumber)      := p_rec_acct_attrs.array_char_value(i);
     ELSE
       g_rec_lines.array_gain_or_loss_ref(g_LineNumber)      := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'TRX_ROUNDING_REF'                 THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_doc_rounding_level(g_LineNumber)      := p_rec_acct_attrs.array_char_value(i);
     ELSE
       g_rec_lines.array_doc_rounding_level(g_LineNumber)      := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'DISTRIBUTION_IDENTIFIER_1' THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_char_1(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_num_1(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'DISTRIBUTION_IDENTIFIER_2' THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_char_2(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_num_2(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'DISTRIBUTION_IDENTIFIER_3' THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_char_3(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_num_3(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'DISTRIBUTION_IDENTIFIER_4' THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_char_4(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_num_4(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'DISTRIBUTION_IDENTIFIER_5' THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_char_5(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_distribution_id_num_5(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'PARTY_ID'                  THEN
     g_rec_lines.array_party_id(g_LineNumber)               := p_rec_acct_attrs.array_num_value(i);

  WHEN 'PARTY_SITE_ID'             THEN
     g_rec_lines.array_party_site_id(g_LineNumber)          := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ENTERED_CURRENCY_AMOUNT'   THEN
     g_rec_lines.array_entered_amount(g_LineNumber)         := p_rec_acct_attrs.array_num_value(i);

  WHEN 'STATISTICAL_AMOUNT'        THEN
     g_rec_lines.array_statistical_amount(g_LineNumber)     := p_rec_acct_attrs.array_num_value(i);

-- 4262811
--WHEN 'DEFERRED_NO_OF_PERIODS'    THEN
--   g_rec_lines.array_deferred_no_period(g_LineNumber)     := p_rec_acct_attrs.array_num_value(i);

  WHEN 'TAX_LINE_REF_ID'               THEN
     g_rec_lines.array_tax_line_ref(g_LineNumber)           := p_rec_acct_attrs.array_num_value(i);

  WHEN 'TAX_SUMMARY_LINE_REF_ID'       THEN
     g_rec_lines.array_tax_summary_line_ref(g_LineNumber)   := p_rec_acct_attrs.array_num_value(i);

  WHEN 'TAX_REC_NREC_DIST_REF_ID'      THEN
     g_rec_lines.array_tax_rec_nrec_dist_ref(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'LEDGER_AMOUNT'             THEN
     g_rec_lines.array_ledger_amount(g_LineNumber)          := p_rec_acct_attrs.array_num_value(i);

/* Since now after ledger currency project, the ledger amount could be null
   this validation is moved to SetDebitCreditAmounts
     IF p_rec_acct_attrs.array_num_value(i) IS NULL THEN
        XLA_AE_JOURNAL_ENTRY_PKG.g_global_status      :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
        xla_accounting_err_pkg.build_message
           (p_appli_s_name            => 'XLA'
           ,p_msg_name                => 'XLA_AP_NO_LEDGER_AMOUNT'
           ,p_token_1                 => 'LINE_NUMBER'
           ,p_value_1                 =>  g_ExtractLine
           ,p_token_2                 => 'SOURCE_NAME'
           ,p_value_2                 => NULL
           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
           ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
      END IF;
*/

  WHEN 'EXCHANGE_RATE'             THEN
     g_rec_lines.array_curr_conversion_rate(g_LineNumber)   := p_rec_acct_attrs.array_num_value(i);

  -- 4262811 ------------------------------------------------------------------------------------
--WHEN 'DEFERRED_START_DATE'       THEN
--   g_rec_lines.array_deferred_start_date(g_LineNumber) := p_rec_acct_attrs.array_date_value(i);
--WHEN 'DEFERRED_END_DATE'         THEN
--   g_rec_lines.array_deferred_end_date(g_LineNumber)   := p_rec_acct_attrs.array_date_value(i);
  WHEN 'MULTIPERIOD_START_DATE'    THEN
     g_rec_lines.array_mpa_start_date(g_LineNumber)      := p_rec_acct_attrs.array_date_value(i);

  WHEN 'MULTIPERIOD_END_DATE'      THEN
     g_rec_lines.array_mpa_end_date(g_LineNumber)        := p_rec_acct_attrs.array_date_value(i);


  WHEN 'EXCHANGE_DATE'        THEN
     g_rec_lines.array_curr_conversion_date(g_LineNumber):= p_rec_acct_attrs.array_date_value(i);

  ----------------------------------------------------------------------------------------------------
  -- 4219869
  -- Business Flow Applied To attributes - code must match those in Accounting Attribute in AAA form.
  --                                       See xla11iass.ldt for seeded data.
  ----------------------------------------------------------------------------------------------------
  WHEN 'APPLIED_TO_APPLICATION_ID' THEN
     g_rec_lines.array_bflow_application_id(g_LineNumber) := p_rec_acct_attrs.array_num_value(i);

  WHEN 'APPLIED_TO_ENTITY_CODE' THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_bflow_entity_code(g_LineNumber)   := p_rec_acct_attrs.array_char_value(i);
     ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
       g_rec_lines.array_bflow_entity_code(g_LineNumber)   := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'APPLIED_TO_FIRST_SYS_TRAN_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_source_id_num_1(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_source_id_char_1(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_SECOND_SYS_TRAN_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_source_id_num_2(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_source_id_char_2(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_THIRD_SYS_TRAN_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_source_id_num_3(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_source_id_char_3(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;
  WHEN 'APPLIED_TO_FOURTH_SYS_TRAN_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_source_id_num_4(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_source_id_char_4(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_DISTRIBUTION_TYPE' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
       g_rec_lines.array_bflow_distribution_type(g_LineNumber) := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_bflow_distribution_type(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_FIRST_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_num_1(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_char_1(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_SECOND_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_num_2(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_char_2(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_THIRD_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_num_3(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_char_3(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_FOURTH_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_num_4(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_char_4(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_FIFTH_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_num_5(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_bflow_dist_id_char_5(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'APPLIED_TO_AMOUNT' THEN  -- 5132302
     g_rec_lines.array_bflow_applied_to_amt(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  --
  -- Upgrade attributes
  --

  WHEN 'ACTUAL_UPG_OPTION' THEN
        g_rec_lines.array_actual_upg_option(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ACTUAL_UPG_DR_CCID' THEN
        g_rec_lines.array_actual_upg_dr_ccid(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ACTUAL_UPG_CR_CCID' THEN
        g_rec_lines.array_actual_upg_cr_ccid(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ACTUAL_UPG_DR_ENTERED_AMT' THEN
        g_rec_lines.array_actual_upg_dr_ent_amt(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ACTUAL_UPG_CR_ENTERED_AMT' THEN
        g_rec_lines.array_actual_upg_cr_ent_amt(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ACTUAL_UPG_DR_ENTERED_CURR' THEN
        g_rec_lines.array_actual_upg_dr_ent_curr(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ACTUAL_UPG_CR_ENTERED_CURR' THEN
         g_rec_lines.array_actual_upg_cr_ent_curr(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ACTUAL_UPG_DR_LEDGER_AMT' THEN
        g_rec_lines.array_actual_upg_dr_ledger_amt(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ACTUAL_UPG_CR_LEDGER_AMT' THEN
        g_rec_lines.array_actual_upg_cr_ledger_amt(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ACTUAL_UPG_DR_ACCT_CLASS' THEN
        g_rec_lines.array_actual_upg_dr_acct_class(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ACTUAL_UPG_CR_ACCT_CLASS' THEN
        g_rec_lines.array_actual_upg_dr_acct_class(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ACTUAL_UPG_DR_XRATE' THEN
        g_rec_lines.array_actual_upg_dr_xrate(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ACTUAL_UPG_DR_XRATE_TYPE' THEN
        g_rec_lines.array_actual_upg_dr_xrate_type(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ACTUAL_UPG_DR_XDATE' THEN
        g_rec_lines.array_actual_upg_dr_xdate(g_LineNumber) := p_rec_acct_attrs.array_date_value(i);

  WHEN 'ACTUAL_UPG_CR_XRATE' THEN
        g_rec_lines.array_actual_upg_cr_xrate(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ACTUAL_UPG_CR_XRATE_TYPE' THEN
        g_rec_lines.array_actual_upg_cr_xrate_type(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ACTUAL_UPG_CR_XDATE' THEN
        g_rec_lines.array_actual_upg_cr_xdate(g_LineNumber) := p_rec_acct_attrs.array_date_value(i);

  WHEN 'ENC_UPG_OPTION' THEN
       g_rec_lines.array_enc_upg_option(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ENC_UPG_DR_CCID' THEN
       g_rec_lines.array_enc_upg_dr_ccid(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ENC_UPG_CR_CCID' THEN
       g_rec_lines.array_enc_upg_cr_ccid(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'UPG_DR_ENC_TYPE_ID' THEN
       g_rec_lines.array_upg_dr_enc_type_id(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'UPG_CR_ENC_TYPE_ID' THEN
       g_rec_lines.array_upg_cr_enc_type_id(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ENC_UPG_DR_ENTERED_AMT' THEN
       g_rec_lines.array_enc_upg_dr_ent_amt(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ENC_UPG_CR_ENTERED_AMT' THEN
        g_rec_lines.array_enc_upg_cr_ent_amt(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ENC_UPG_DR_ENTERED_CURR' THEN
        g_rec_lines.array_enc_upg_dr_ent_curr(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ENC_UPG_CR_ENTERED_CURR' THEN
        g_rec_lines.array_enc_upg_cr_ent_curr(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ENC_UPG_DR_LEDGER_AMT' THEN
        g_rec_lines.array_enc_upg_dr_ledger_amt(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ENC_UPG_CR_LEDGER_AMT' THEN
        g_rec_lines.array_enc_upg_cr_ledger_amt(g_linenumber)  := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ENC_UPG_DR_ACCT_CLASS' THEN
        g_rec_lines.array_enc_upg_dr_acct_class(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);

  WHEN 'ENC_UPG_CR_ACCT_CLASS' THEN
        g_rec_lines.array_enc_upg_cr_acct_class(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
  -- 5845547
  WHEN 'UPG_PARTY_TYPE' THEN
        g_rec_lines.array_upg_party_type_code(g_LineNumber)   := p_rec_acct_attrs.array_char_value(i);

  WHEN 'UPG_PARTY_ID' THEN
        g_rec_lines.array_upg_party_id(g_LineNumber)          := p_rec_acct_attrs.array_num_value(i);

  WHEN 'UPG_PARTY_SITE_ID' THEN
        g_rec_lines.array_upg_party_site_id(g_LineNumber)     := p_rec_acct_attrs.array_num_value(i);
  --
  -- end upgrade attributes
  --

  --
  --  Allocation Attributes
  --
  WHEN 'ALLOC_TO_APPLICATION_ID' THEN
     g_rec_lines.array_alloct_application_id(g_LineNumber) := p_rec_acct_attrs.array_num_value(i);

  WHEN 'ALLOC_TO_ENTITY_CODE' THEN
     IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_alloct_entity_code(g_LineNumber)   := p_rec_acct_attrs.array_char_value(i);
     ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
       g_rec_lines.array_alloct_entity_code(g_LineNumber)   := p_rec_acct_attrs.array_num_value(i);
     END IF;

  WHEN 'ALLOC_TO_FIRST_SYS_TRAN_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_source_id_num_1(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_source_id_char_1(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'ALLOC_TO_SECOND_SYS_TRAN_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_source_id_num_2(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_source_id_char_2(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'ALLOC_TO_THIRD_SYS_TRAN_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_source_id_num_3(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_source_id_char_3(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;
  WHEN 'ALLOC_TO_FOURTH_SYS_TRAN_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_source_id_num_4(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_source_id_char_4(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'ALLOC_TO_DISTRIBUTION_TYPE' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
       g_rec_lines.array_alloct_distribution_type(g_LineNumber) := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
       g_rec_lines.array_alloct_distribution_type(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'ALLOC_TO_FIRST_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_num_1(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_char_1(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'ALLOC_TO_SECOND_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_num_2(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_char_2(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'ALLOC_TO_THIRD_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_num_3(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_char_3(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'ALLOC_TO_FOURTH_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_num_4(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_char_4(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;

  WHEN 'ALLOC_TO_FIFTH_DIST_ID' THEN
     IF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_num_5(g_LineNumber)  := p_rec_acct_attrs.array_num_value(i);
     ELSIF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
        g_rec_lines.array_alloct_dist_id_char_5(g_LineNumber) := p_rec_acct_attrs.array_char_value(i);
     END IF;
  --
  --  End of Allocation Attributes
  --


  ELSE NULL;
  END CASE;

  -- 5162408 log error for attribute
  IF l_attr_error IS NOT NULL THEN
     XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
     xla_accounting_err_pkg.build_message
                  (p_appli_s_name            => 'XLA'
                  ,p_msg_name                => l_attr_error
                  ,p_token_1                 => 'ACCT_ATTR_NAME'
                  ,p_value_1                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName
                                                           (p_rec_acct_attrs.array_acct_attr_code(i))
                  ,p_token_2                 => 'LINE_TYPE_NAME'
                  ,p_value_2                 =>  XLA_AE_SOURCES_PKG.GetComponentName (
                                                     g_accounting_line.component_type
                                                   , g_accounting_line.accounting_line_code
                                                   , g_accounting_line.accounting_line_type_code
                                                   , g_accounting_line.accounting_line_appl_id
                                                   , g_accounting_line.amb_context_code
                                                   , g_accounting_line.entity_code
                                                   , g_accounting_line.event_class_code
                                                  )
                  ,p_token_3                 => 'OWNER'
                  ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                            'XLA_OWNER_TYPE'
                                                           , g_rec_lines.array_accounting_line_type(g_LineNumber)
                                                          )
                  ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                  ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                  ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
  END IF;

end loop;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_AE_HEADER_PKG.SetLineAcctAttrs');
  --
end SetLineAcctAttrs;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetAcctReversalAttrs
       (p_event_id                 IN NUMBER
       ,p_rec_acct_attrs           IN XLA_AE_LINES_PKG.t_rec_acct_attrs
       ,p_calculate_acctd_flag     IN VARCHAR2
       ,p_calculate_g_l_flag       IN VARCHAR2) IS

l_sys_distribution_type             VARCHAR2(30);
l_acc_reversal_option               VARCHAR2(30);
l_distribution_id_char_1            VARCHAR2(30);
l_distribution_id_char_2            VARCHAR2(30);
l_distribution_id_char_3            VARCHAR2(30);
l_distribution_id_char_4            VARCHAR2(30);
l_distribution_id_char_5            VARCHAR2(30);
l_distribution_id_num_1             NUMBER;
l_distribution_id_num_2             NUMBER;
l_distribution_id_num_3             NUMBER;
l_distribution_id_num_4             NUMBER;
l_distribution_id_num_5             NUMBER;
l_rev_dist_id_char_1                VARCHAR2(30);
l_rev_dist_id_char_2                VARCHAR2(30);
l_rev_dist_id_char_3                VARCHAR2(30);
l_rev_dist_id_char_4                VARCHAR2(30);
l_rev_dist_id_char_5                VARCHAR2(30);
l_rev_dist_id_num_1                 NUMBER;
l_rev_dist_id_num_2                 NUMBER;
l_rev_dist_id_num_3                 NUMBER;
l_rev_dist_id_num_4                 NUMBER;
l_rev_dist_id_num_5                 NUMBER;
l_rev_dist_type                     VARCHAR2(30);
l_actual_upg_option                 VARCHAR2(30);
l_actual_upg_dr_ccid                NUMBER;
l_actual_upg_cr_ccid                NUMBER;
l_actual_upg_dr_entered_amt         NUMBER;
l_actual_upg_cr_entered_amt         NUMBER;
l_actual_upg_dr_entered_curr        VARCHAR2(30);
l_actual_upg_cr_entered_curr        VARCHAR2(30);
l_actual_upg_dr_ledger_amt          NUMBER;
l_actual_upg_cr_ledger_amt          NUMBER;
l_actual_upg_dr_acct_class          VARCHAR2(30);
l_actual_upg_cr_acct_class          VARCHAR2(30);
l_actual_upg_dr_xrate               NUMBER;
l_actual_upg_dr_xrate_type          VARCHAR2(30);
l_actual_upg_dr_xdate               DATE;
l_actual_upg_cr_xrate               NUMBER;
l_actual_upg_cr_xrate_type          VARCHAR2(30);
l_actual_upg_cr_xdate               DATE;
l_enc_upg_option                    VARCHAR2(30);
l_enc_upg_dr_ccid                   NUMBER;
l_enc_upg_cr_ccid                   NUMBER;
l_upg_dr_enc_type_id                NUMBER;
l_upg_cr_enc_type_id                NUMBER;
l_enc_upg_dr_entered_amt            NUMBER;
l_enc_upg_cr_entered_amt            NUMBER;
l_enc_upg_dr_entered_curr           VARCHAR2(30);
l_enc_upg_cr_entered_curr           VARCHAR2(30);
l_enc_upg_dr_ledger_amt             NUMBER;
l_enc_upg_cr_ledger_amt             NUMBER;
l_enc_upg_dr_acct_class             VARCHAR2(30);
l_enc_upg_cr_acct_class             VARCHAR2(30);
l_gl_date                           DATE;

l_upg_party_type                    VARCHAR2(1);  -- 5845547
l_upg_party_id                      NUMBER;       -- 5845547
l_upg_party_site_id                 NUMBER;       -- 5845547


l_tax_line_ref                      NUMBER(15,0);  --7159711
l_tax_summary_line_ref              NUMBER(15,0);  --7159711
l_tax_rec_nrec_dist_ref             NUMBER(15,0);  --7159711


l_log_module                        VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetAcctReversalAttrs';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetAcctReversalAttrs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   FOR i IN 1..p_rec_acct_attrs.array_acct_attr_code.COUNT LOOP
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

      WHEN 'GL_DATE'         THEN
         l_gl_date := p_rec_acct_attrs.array_date_value(i);

      WHEN 'DISTRIBUTION_TYPE'         THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
           l_sys_distribution_type := p_rec_acct_attrs.array_char_value(i);
         ELSE
           l_sys_distribution_type := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'ACCOUNTING_REVERSAL_OPTION' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
           l_acc_reversal_option := p_rec_acct_attrs.array_char_value(i);
         ELSE
           l_acc_reversal_option := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'DISTRIBUTION_IDENTIFIER_1' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_distribution_id_char_1 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_distribution_id_num_1  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'DISTRIBUTION_IDENTIFIER_2' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_distribution_id_char_2 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_distribution_id_num_2  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'DISTRIBUTION_IDENTIFIER_3' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_distribution_id_char_3 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_distribution_id_num_3  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'DISTRIBUTION_IDENTIFIER_4' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_distribution_id_char_4 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_distribution_id_num_4  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'DISTRIBUTION_IDENTIFIER_5' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_distribution_id_char_5 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_distribution_id_num_5  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'REVERSED_DISTRIBUTION_ID1' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_rev_dist_id_char_1 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_rev_dist_id_num_1  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'REVERSED_DISTRIBUTION_ID2' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_rev_dist_id_char_2 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_rev_dist_id_num_2  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'REVERSED_DISTRIBUTION_ID3' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_rev_dist_id_char_3 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_rev_dist_id_num_3  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'REVERSED_DISTRIBUTION_ID4' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_rev_dist_id_char_4 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_rev_dist_id_num_4  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'REVERSED_DISTRIBUTION_ID5' THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
            l_rev_dist_id_char_5 := p_rec_acct_attrs.array_char_value(i);
         ELSIF p_rec_acct_attrs.array_num_value.EXISTS(i) THEN
            l_rev_dist_id_num_5  := p_rec_acct_attrs.array_num_value(i);
         END IF;

      WHEN 'REVERSED_DISTRIBUTION_TYPE'         THEN
         IF p_rec_acct_attrs.array_char_value.EXISTS(i) THEN
           l_rev_dist_type  := p_rec_acct_attrs.array_char_value(i);
         ELSE
           l_rev_dist_type  := p_rec_acct_attrs.array_num_value(i);
         END IF;
      --
      -- Upgrade attributes
      --
      WHEN 'ACTUAL_UPG_OPTION' THEN
            l_actual_upg_option := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ACTUAL_UPG_DR_CCID' THEN
            l_actual_upg_dr_ccid  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ACTUAL_UPG_CR_CCID' THEN
            l_actual_upg_cr_ccid  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ACTUAL_UPG_DR_ENTERED_AMT' THEN
            l_actual_upg_dr_entered_amt  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ACTUAL_UPG_CR_ENTERED_AMT' THEN
            l_actual_upg_cr_entered_amt  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ACTUAL_UPG_DR_ENTERED_CURR' THEN
            l_actual_upg_dr_entered_curr := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ACTUAL_UPG_CR_ENTERED_CURR' THEN
            l_actual_upg_cr_entered_curr := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ACTUAL_UPG_DR_LEDGER_AMT' THEN
            l_actual_upg_dr_ledger_amt  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ACTUAL_UPG_CR_LEDGER_AMT' THEN
            l_actual_upg_cr_ledger_amt  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ACTUAL_UPG_DR_ACCT_CLASS' THEN
            l_actual_upg_dr_acct_class := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ACTUAL_UPG_CR_ACCT_CLASS' THEN
            l_actual_upg_cr_acct_class := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ACTUAL_UPG_DR_XRATE' THEN
            l_actual_upg_dr_xrate  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ACTUAL_UPG_DR_XRATE_TYPE' THEN
            l_actual_upg_dr_xrate_type := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ACTUAL_UPG_DR_XDATE' THEN
            l_actual_upg_dr_xdate := p_rec_acct_attrs.array_date_value(i);

      WHEN 'ACTUAL_UPG_CR_XRATE' THEN
            l_actual_upg_cr_xrate  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ACTUAL_UPG_CR_XRATE_TYPE' THEN
            l_actual_upg_cr_xrate_type := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ACTUAL_UPG_CR_XDATE' THEN
            l_actual_upg_cr_xdate := p_rec_acct_attrs.array_date_value(i);

      WHEN 'ENC_UPG_OPTION' THEN
            l_enc_upg_option := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ENC_UPG_DR_CCID' THEN
           l_enc_upg_dr_ccid  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ENC_UPG_CR_CCID' THEN
           l_enc_upg_cr_ccid  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'UPG_DR_ENC_TYPE_ID' THEN
           l_upg_dr_enc_type_id  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'UPG_CR_ENC_TYPE_ID' THEN
           l_upg_cr_enc_type_id  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ENC_UPG_DR_ENTERED_AMT' THEN
           l_enc_upg_dr_entered_amt  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ENC_UPG_CR_ENTERED_AMT' THEN
            l_enc_upg_cr_entered_amt  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ENC_UPG_DR_ENTERED_CURR' THEN
            l_enc_upg_dr_entered_curr := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ENC_UPG_CR_ENTERED_CURR' THEN
            l_enc_upg_cr_entered_curr := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ENC_UPG_DR_LEDGER_AMT' THEN
            l_enc_upg_dr_ledger_amt  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ENC_UPG_CR_LEDGER_AMT' THEN
            l_enc_upg_cr_ledger_amt  := p_rec_acct_attrs.array_num_value(i);

      WHEN 'ENC_UPG_DR_ACCT_CLASS' THEN
            l_enc_upg_dr_acct_class := p_rec_acct_attrs.array_char_value(i);

      WHEN 'ENC_UPG_CR_ACCT_CLASS' THEN
            l_enc_upg_cr_acct_class := p_rec_acct_attrs.array_char_value(i);
      -- 5845547  for reversal
      WHEN 'UPG_PARTY_TYPE' THEN
            l_upg_party_type        := p_rec_acct_attrs.array_char_value(i);

      WHEN 'UPG_PARTY_ID' THEN
            l_upg_party_id          := p_rec_acct_attrs.array_num_value(i);

      WHEN 'UPG_PARTY_SITE_ID' THEN
            l_upg_party_site_id     := p_rec_acct_attrs.array_num_value(i);
      --
      -- end upgrade attributes
      --

      --  bug 7159711
         WHEN 'TAX_LINE_REF_ID'               THEN
            l_tax_line_ref := p_rec_acct_attrs.array_num_value(i);

         WHEN 'TAX_SUMMARY_LINE_REF_ID'       THEN
            l_tax_summary_line_ref :=  p_rec_acct_attrs.array_num_value(i);

         WHEN 'TAX_REC_NREC_DIST_REF_ID'      THEN
            l_tax_rec_nrec_dist_ref  :=  p_rec_acct_attrs.array_num_value(i);


      ELSE null;
      END CASE;
   END LOOP;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'l_actual_upg_option = '||l_actual_upg_option
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_enc_upg_option = '||l_enc_upg_option
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
   END IF;

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('SECONDARY')
   OR (NVL(l_actual_upg_option,'N') = 'N' OR NVL(l_enc_upg_option,'N') = 'N')
   THEN

      SetNewLine;

      set_ae_header_id (p_ae_header_id => p_event_id,
                        p_header_num   => 0);      -- 4262811 by default all zero.  1,2,.. are used by Accl Reversal or MPA.

      g_rec_lines.array_balance_type_code(g_LineNumber) := 'X';

      g_rec_lines.array_ledger_id(g_LineNumber) :=
         XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

      g_rec_lines.array_event_number(g_LineNumber) := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_number;

      g_rec_lines.array_entity_id(g_LineNumber) := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id;

      g_rec_lines.array_reversal_code(g_LineNumber) := 'DUMMY_LR';

      ------------------------------------------------------------------------------------------
      -- 5055878 Handle line reversal method option - SIDE and SIGN
      ------------------------------------------------------------------------------------------
      IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE' THEN
         g_rec_lines.array_switch_side_flag(g_LineNumber) := 'Y';
      ELSE
         g_rec_lines.array_switch_side_flag(g_LineNumber) := 'N';
      END IF;
      ------------------------------------------------------------------------------------------

      g_rec_lines.array_sys_distribution_type(g_LineNumber)  := l_sys_distribution_type;
      g_rec_lines.array_acc_reversal_option(g_LineNumber)    := l_acc_reversal_option;
      g_rec_lines.array_distribution_id_char_1(g_LineNumber) := l_distribution_id_char_1;
      g_rec_lines.array_distribution_id_num_1(g_LineNumber)  := l_distribution_id_num_1;
      g_rec_lines.array_distribution_id_char_2(g_LineNumber) := l_distribution_id_char_2;
      g_rec_lines.array_distribution_id_num_2(g_LineNumber)  := l_distribution_id_num_2;
      g_rec_lines.array_distribution_id_char_3(g_LineNumber) := l_distribution_id_char_3;
      g_rec_lines.array_distribution_id_num_3(g_LineNumber)  := l_distribution_id_num_3;
      g_rec_lines.array_distribution_id_char_4(g_LineNumber) := l_distribution_id_char_4;
      g_rec_lines.array_distribution_id_num_4(g_LineNumber)  := l_distribution_id_num_4;
      g_rec_lines.array_distribution_id_char_5(g_LineNumber) := l_distribution_id_char_5;
      g_rec_lines.array_distribution_id_num_5(g_LineNumber)  := l_distribution_id_num_5;
      g_rec_lines.array_rev_dist_id_char_1(g_LineNumber)     := l_rev_dist_id_char_1;
      g_rec_lines.array_rev_dist_id_num_1(g_LineNumber)      := l_rev_dist_id_num_1;
      g_rec_lines.array_rev_dist_id_char_2(g_LineNumber)     := l_rev_dist_id_char_2;
      g_rec_lines.array_rev_dist_id_num_2(g_LineNumber)      := l_rev_dist_id_num_2;
      g_rec_lines.array_rev_dist_id_char_3(g_LineNumber)     := l_rev_dist_id_char_3;
      g_rec_lines.array_rev_dist_id_num_3(g_LineNumber)      := l_rev_dist_id_num_3;
      g_rec_lines.array_rev_dist_id_char_4(g_LineNumber)     := l_rev_dist_id_char_4;
      g_rec_lines.array_rev_dist_id_num_4(g_LineNumber)      := l_rev_dist_id_num_4;
      g_rec_lines.array_rev_dist_id_char_5(g_LineNumber)     := l_rev_dist_id_char_5;
      g_rec_lines.array_rev_dist_id_num_5(g_LineNumber)      := l_rev_dist_id_num_5;
      g_rec_lines.array_rev_dist_type(g_LineNumber)          := l_rev_dist_type;
      g_rec_lines.array_gl_date(g_LineNumber)                := l_gl_date;    --5194849

      g_rec_lines.array_tax_line_ref(g_LineNumber)           := l_tax_line_ref;           -- Bug7159711
      g_rec_lines.array_tax_summary_line_ref(g_LineNumber)   := l_tax_summary_line_ref;   -- Bug7159711
      g_rec_lines.array_tax_rec_nrec_dist_ref(g_LineNumber)  := l_tax_rec_nrec_dist_ref;  -- Bug7159711


      --
      -- Validate the distribution links for the extract line
      -- if the validation fails, mark the dummy line as 'DUMMY_LR_ERROR'
      --
      IF NOT ValidateRevLinks THEN
         g_rec_lines.array_reversal_code(g_LineNumber) := 'DUMMY_LR_ERROR';
      END IF;
   END IF;


   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND (NVL(l_actual_upg_option,'N') = 'Y')
   THEN

      SetNewLine;

      set_ae_header_id
         (p_ae_header_id => p_event_id
         ,p_header_num   => 0);

      g_rec_lines.array_gl_date(g_LineNumber)           := l_gl_date;
      g_rec_lines.array_ledger_id(g_LineNumber)         := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;
      g_rec_lines.array_event_number(g_LineNumber)      := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_number;
      g_rec_lines.array_reversal_code(g_LineNumber)     := 'REVERSAL';
      g_rec_lines.array_entity_id(g_LineNumber)         := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id;
      g_rec_lines.array_balance_type_code(g_LineNumber) := 'A';
      g_rec_lines.array_calculate_acctd_flag(g_LineNumber) := p_calculate_acctd_flag;
      g_rec_lines.array_calculate_g_l_flag(g_LineNumber)   := p_calculate_g_l_flag;

      g_rec_lines.array_sys_distribution_type(g_LineNumber)  := l_sys_distribution_type;
      g_rec_lines.array_distribution_id_char_1(g_LineNumber) := l_distribution_id_char_1;
      g_rec_lines.array_distribution_id_num_1(g_LineNumber)  := l_distribution_id_num_1;
      g_rec_lines.array_distribution_id_char_2(g_LineNumber) := l_distribution_id_char_2;
      g_rec_lines.array_distribution_id_num_2(g_LineNumber)  := l_distribution_id_num_2;
      g_rec_lines.array_distribution_id_char_3(g_LineNumber) := l_distribution_id_char_3;
      g_rec_lines.array_distribution_id_num_3(g_LineNumber)  := l_distribution_id_num_3;
      g_rec_lines.array_distribution_id_char_4(g_LineNumber) := l_distribution_id_char_4;
      g_rec_lines.array_distribution_id_num_4(g_LineNumber)  := l_distribution_id_num_4;
      g_rec_lines.array_distribution_id_char_5(g_LineNumber) := l_distribution_id_char_5;
      g_rec_lines.array_distribution_id_num_5(g_LineNumber)  := l_distribution_id_num_5;
      g_rec_lines.array_rev_dist_id_char_1(g_LineNumber)     := l_rev_dist_id_char_1;
      g_rec_lines.array_rev_dist_id_num_1(g_LineNumber)      := l_rev_dist_id_num_1;
      g_rec_lines.array_rev_dist_id_char_2(g_LineNumber)     := l_rev_dist_id_char_2;
      g_rec_lines.array_rev_dist_id_num_2(g_LineNumber)      := l_rev_dist_id_num_2;
      g_rec_lines.array_rev_dist_id_char_3(g_LineNumber)     := l_rev_dist_id_char_3;
      g_rec_lines.array_rev_dist_id_num_3(g_LineNumber)      := l_rev_dist_id_num_3;
      g_rec_lines.array_rev_dist_id_char_4(g_LineNumber)     := l_rev_dist_id_char_4;
      g_rec_lines.array_rev_dist_id_num_4(g_LineNumber)      := l_rev_dist_id_num_4;
      g_rec_lines.array_rev_dist_id_char_5(g_LineNumber)     := l_rev_dist_id_char_5;
      g_rec_lines.array_rev_dist_id_num_5(g_LineNumber)      := l_rev_dist_id_num_5;
      g_rec_lines.array_rev_dist_type(g_LineNumber)          := l_rev_dist_type;

      g_rec_lines.array_entered_amount(g_LineNumber)       := l_actual_upg_dr_entered_amt;
      g_rec_lines.array_currency_code(g_LineNumber)        := l_actual_upg_dr_entered_curr;
      g_rec_lines.array_ledger_amount(g_LineNumber)        := l_actual_upg_dr_ledger_amt;
      g_rec_lines.array_accounting_class(g_LineNumber)     := l_actual_upg_dr_acct_class;
      g_rec_lines.array_curr_conversion_rate(g_LineNumber) := l_actual_upg_dr_xrate;
      g_rec_lines.array_curr_conversion_date(g_LineNumber) := l_actual_upg_dr_xdate;
      g_rec_lines.array_curr_conversion_type(g_LineNumber) := l_actual_upg_dr_xrate_type;

      -- 5845547 upgrade party attributes
      g_rec_lines.array_party_type_code(g_LineNumber)      := l_upg_party_type;
      g_rec_lines.array_party_id(g_LineNumber)             := l_upg_party_id;
      g_rec_lines.array_party_site_id(g_LineNumber)        := l_upg_party_site_id;

      g_rec_lines.array_natural_side_code(g_LineNumber)    := 'D';
      g_rec_lines.array_acct_entry_type_code(g_LineNumber) := 'A';
      g_rec_lines.array_switch_side_flag(g_LineNumber)     := 'Y';
      g_rec_lines.array_merge_duplicate_code(g_LineNumber) := 'N';
      g_rec_lines.array_gl_transfer_mode(g_LineNumber)     := 'S';

      g_rec_lines.array_currency_mau(g_LineNumber)         :=
         xla_accounting_cache_pkg.GetCurrencyMau(g_rec_lines.array_currency_code(g_LineNumber));

      xla_ae_lines_pkg.set_ccid(
       p_code_combination_id          => l_actual_upg_dr_ccid
     , p_value_type_code              => 'S' --l_adr_value_type_code
     , p_transaction_coa_id           => NULL --l_adr_transaction_coa_id
     , p_accounting_coa_id            => NULL --l_adr_accounting_coa_id
     , p_adr_code                     => NULL --'SS_TEST'
     , p_adr_type_code                => NULL --'C'
     , p_component_type               => g_accounting_line.component_type --l_component_type
     , p_component_code               => g_accounting_line.accounting_line_code  --l_component_code
     , p_component_type_code          => g_accounting_line.accounting_line_type_code --l_component_type_code
     , p_component_appl_id            => g_accounting_line.accounting_line_appl_id --l_component_appl_id
     , p_amb_context_code             => g_accounting_line.amb_context_code --l_amb_context_code
     , p_side                         => 'NA'
     );

      SetDebitCreditAmounts;

      SetNewLine;

      set_ae_header_id
         (p_ae_header_id => p_event_id
         ,p_header_num   => 0);

      g_rec_lines.array_gl_date(g_LineNumber)           := l_gl_date;
      g_rec_lines.array_ledger_id(g_LineNumber)         := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;
      g_rec_lines.array_event_number(g_LineNumber)      := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_number;
      g_rec_lines.array_reversal_code(g_LineNumber)     := 'REVERSAL';
      g_rec_lines.array_entity_id(g_LineNumber)         := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id;
      g_rec_lines.array_balance_type_code(g_LineNumber) := 'A';
      g_rec_lines.array_calculate_acctd_flag(g_LineNumber) := p_calculate_acctd_flag;
      g_rec_lines.array_calculate_g_l_flag(g_LineNumber)   := p_calculate_g_l_flag;

      g_rec_lines.array_sys_distribution_type(g_LineNumber)  := l_sys_distribution_type;
      g_rec_lines.array_distribution_id_char_1(g_LineNumber) := l_distribution_id_char_1;
      g_rec_lines.array_distribution_id_num_1(g_LineNumber)  := l_distribution_id_num_1;
      g_rec_lines.array_distribution_id_char_2(g_LineNumber) := l_distribution_id_char_2;
      g_rec_lines.array_distribution_id_num_2(g_LineNumber)  := l_distribution_id_num_2;
      g_rec_lines.array_distribution_id_char_3(g_LineNumber) := l_distribution_id_char_3;
      g_rec_lines.array_distribution_id_num_3(g_LineNumber)  := l_distribution_id_num_3;
      g_rec_lines.array_distribution_id_char_4(g_LineNumber) := l_distribution_id_char_4;
      g_rec_lines.array_distribution_id_num_4(g_LineNumber)  := l_distribution_id_num_4;
      g_rec_lines.array_distribution_id_char_5(g_LineNumber) := l_distribution_id_char_5;
      g_rec_lines.array_distribution_id_num_5(g_LineNumber)  := l_distribution_id_num_5;
      g_rec_lines.array_rev_dist_id_char_1(g_LineNumber)     := l_rev_dist_id_char_1;
      g_rec_lines.array_rev_dist_id_num_1(g_LineNumber)      := l_rev_dist_id_num_1;
      g_rec_lines.array_rev_dist_id_char_2(g_LineNumber)     := l_rev_dist_id_char_2;
      g_rec_lines.array_rev_dist_id_num_2(g_LineNumber)      := l_rev_dist_id_num_2;
      g_rec_lines.array_rev_dist_id_char_3(g_LineNumber)     := l_rev_dist_id_char_3;
      g_rec_lines.array_rev_dist_id_num_3(g_LineNumber)      := l_rev_dist_id_num_3;
      g_rec_lines.array_rev_dist_id_char_4(g_LineNumber)     := l_rev_dist_id_char_4;
      g_rec_lines.array_rev_dist_id_num_4(g_LineNumber)      := l_rev_dist_id_num_4;
      g_rec_lines.array_rev_dist_id_char_5(g_LineNumber)     := l_rev_dist_id_char_5;
      g_rec_lines.array_rev_dist_id_num_5(g_LineNumber)      := l_rev_dist_id_num_5;
      g_rec_lines.array_rev_dist_type(g_LineNumber)          := l_rev_dist_type;

      g_rec_lines.array_entered_amount(g_LineNumber)       := l_actual_upg_cr_entered_amt;
      g_rec_lines.array_currency_code(g_LineNumber)        := l_actual_upg_cr_entered_curr;
      g_rec_lines.array_ledger_amount(g_LineNumber)        := l_actual_upg_cr_ledger_amt;
      g_rec_lines.array_accounting_class(g_LineNumber)     := l_actual_upg_cr_acct_class;
      g_rec_lines.array_curr_conversion_rate(g_LineNumber) := l_actual_upg_cr_xrate;
      g_rec_lines.array_curr_conversion_date(g_LineNumber) := l_actual_upg_cr_xdate;
      g_rec_lines.array_curr_conversion_type(g_LineNumber) := l_actual_upg_cr_xrate_type;

      -- 5845547 upgrade party attributes
      g_rec_lines.array_party_type_code(g_LineNumber)      := l_upg_party_type;
      g_rec_lines.array_party_id(g_LineNumber)             := l_upg_party_id;
      g_rec_lines.array_party_site_id(g_LineNumber)        := l_upg_party_site_id;

      g_rec_lines.array_natural_side_code(g_LineNumber)    := 'C';
      g_rec_lines.array_acct_entry_type_code(g_LineNumber) := 'A';
      g_rec_lines.array_switch_side_flag(g_LineNumber)     := 'Y';
      g_rec_lines.array_merge_duplicate_code(g_LineNumber) := 'N';
      g_rec_lines.array_gl_transfer_mode(g_LineNumber)     := 'S';

      g_rec_lines.array_currency_mau(g_LineNumber)         :=
         xla_accounting_cache_pkg.GetCurrencyMau(g_rec_lines.array_currency_code(g_LineNumber));

      xla_ae_lines_pkg.set_ccid(
       p_code_combination_id          => l_actual_upg_cr_ccid
     , p_value_type_code              => 'S' --l_adr_value_type_code
     , p_transaction_coa_id           => NULL --l_adr_transaction_coa_id
     , p_accounting_coa_id            => NULL --l_adr_accounting_coa_id
     , p_adr_code                     => NULL --'SS_TEST'
     , p_adr_type_code                => NULL --'C'
     , p_component_type               => g_accounting_line.component_type --l_component_type
     , p_component_code               => g_accounting_line.accounting_line_code  --l_component_code
     , p_component_type_code          => g_accounting_line.accounting_line_type_code --l_component_type_code
     , p_component_appl_id            => g_accounting_line.accounting_line_appl_id --l_component_appl_id
     , p_amb_context_code             => g_accounting_line.amb_context_code --l_amb_context_code
     , p_side                         => 'NA'
     );

      SetDebitCreditAmounts;

      --
      -- Validate the distribution links for the extract line
      -- if the validation fails, mark the dummy line as 'DUMMY_LR_ERROR'
      --
--      IF NOT ValidateRevLinks THEN
--         g_rec_lines.array_reversal_code(g_LineNumber) := 'DUMMY_LR_ERROR';
--      END IF;
   END IF;

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND (l_enc_upg_option = 'Y')
   THEN

      IF l_upg_dr_enc_type_id IS NOT NULL THEN
         SetNewLine;

         set_ae_header_id
            (p_ae_header_id => p_event_id
            ,p_header_num   => 0);

         g_rec_lines.array_gl_date(g_LineNumber)           := l_gl_date;
         g_rec_lines.array_ledger_id(g_LineNumber)         := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;
         g_rec_lines.array_event_number(g_LineNumber)      := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_number;
         g_rec_lines.array_reversal_code(g_LineNumber)     := 'REVERSAL';
         g_rec_lines.array_entity_id(g_LineNumber)         := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id;
         g_rec_lines.array_balance_type_code(g_LineNumber) := 'E';
         g_rec_lines.array_calculate_acctd_flag(g_LineNumber) := 'N';
         g_rec_lines.array_calculate_g_l_flag(g_LineNumber)   := 'N';

         g_rec_lines.array_sys_distribution_type(g_LineNumber)  := l_sys_distribution_type;
         g_rec_lines.array_distribution_id_char_1(g_LineNumber) := l_distribution_id_char_1;
         g_rec_lines.array_distribution_id_num_1(g_LineNumber)  := l_distribution_id_num_1;
         g_rec_lines.array_distribution_id_char_2(g_LineNumber) := l_distribution_id_char_2;
         g_rec_lines.array_distribution_id_num_2(g_LineNumber)  := l_distribution_id_num_2;
         g_rec_lines.array_distribution_id_char_3(g_LineNumber) := l_distribution_id_char_3;
         g_rec_lines.array_distribution_id_num_3(g_LineNumber)  := l_distribution_id_num_3;
         g_rec_lines.array_distribution_id_char_4(g_LineNumber) := l_distribution_id_char_4;
         g_rec_lines.array_distribution_id_num_4(g_LineNumber)  := l_distribution_id_num_4;
         g_rec_lines.array_distribution_id_char_5(g_LineNumber) := l_distribution_id_char_5;
         g_rec_lines.array_distribution_id_num_5(g_LineNumber)  := l_distribution_id_num_5;
         g_rec_lines.array_rev_dist_id_char_1(g_LineNumber)     := l_rev_dist_id_char_1;
         g_rec_lines.array_rev_dist_id_num_1(g_LineNumber)      := l_rev_dist_id_num_1;
         g_rec_lines.array_rev_dist_id_char_2(g_LineNumber)     := l_rev_dist_id_char_2;
         g_rec_lines.array_rev_dist_id_num_2(g_LineNumber)      := l_rev_dist_id_num_2;
         g_rec_lines.array_rev_dist_id_char_3(g_LineNumber)     := l_rev_dist_id_char_3;
         g_rec_lines.array_rev_dist_id_num_3(g_LineNumber)      := l_rev_dist_id_num_3;
         g_rec_lines.array_rev_dist_id_char_4(g_LineNumber)     := l_rev_dist_id_char_4;
         g_rec_lines.array_rev_dist_id_num_4(g_LineNumber)      := l_rev_dist_id_num_4;
         g_rec_lines.array_rev_dist_id_char_5(g_LineNumber)     := l_rev_dist_id_char_5;
         g_rec_lines.array_rev_dist_id_num_5(g_LineNumber)      := l_rev_dist_id_num_5;
         g_rec_lines.array_rev_dist_type(g_LineNumber)          := l_rev_dist_type;

         g_rec_lines.array_entered_amount(g_LineNumber)       := l_enc_upg_dr_entered_amt;
         g_rec_lines.array_currency_code(g_LineNumber)        := l_enc_upg_dr_entered_curr;
         g_rec_lines.array_ledger_amount(g_LineNumber)        := l_enc_upg_dr_ledger_amt;
         g_rec_lines.array_accounting_class(g_LineNumber)     := l_enc_upg_dr_acct_class;
         g_rec_lines.array_encumbrance_type_id(g_LineNumber)  := l_upg_dr_enc_type_id;  -- 5845547

         -- 5845547 upgrade party attributes
         g_rec_lines.array_party_type_code(g_LineNumber)      := l_upg_party_type;
         g_rec_lines.array_party_id(g_LineNumber)             := l_upg_party_id;
         g_rec_lines.array_party_site_id(g_LineNumber)        := l_upg_party_site_id;

         g_rec_lines.array_natural_side_code(g_LineNumber)    := 'D';
         g_rec_lines.array_acct_entry_type_code(g_LineNumber) := 'E';
         g_rec_lines.array_switch_side_flag(g_LineNumber)     := 'Y';
         g_rec_lines.array_merge_duplicate_code(g_LineNumber) := 'N';
         g_rec_lines.array_gl_transfer_mode(g_LineNumber)     := 'S';

         g_rec_lines.array_currency_mau(g_LineNumber)         :=
            xla_accounting_cache_pkg.GetCurrencyMau(g_rec_lines.array_currency_code(g_LineNumber));

         xla_ae_lines_pkg.set_ccid(
           p_code_combination_id          => l_enc_upg_dr_ccid
         , p_value_type_code              => 'S' --l_adr_value_type_code
         , p_transaction_coa_id           => NULL --l_adr_transaction_coa_id
         , p_accounting_coa_id            => NULL --l_adr_accounting_coa_id
         , p_adr_code                     => NULL --'SS_TEST'
         , p_adr_type_code                => NULL --'C'
         , p_component_type               => g_accounting_line.component_type --l_component_type
         , p_component_code               => g_accounting_line.accounting_line_code  --l_component_code
         , p_component_type_code          => g_accounting_line.accounting_line_type_code --l_component_type_code
         , p_component_appl_id            => g_accounting_line.accounting_line_appl_id --l_component_appl_id
         , p_amb_context_code             => g_accounting_line.amb_context_code --l_amb_context_code
         , p_side                         => 'NA'
         );

                  SetDebitCreditAmounts;
      END IF;

      IF l_upg_cr_enc_type_id IS NOT NULL THEN
         SetNewLine;

          set_ae_header_id
             (p_ae_header_id => p_event_id
             ,p_header_num   => 0);

         g_rec_lines.array_gl_date(g_LineNumber)           := l_gl_date;
         g_rec_lines.array_ledger_id(g_LineNumber)         := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;
         g_rec_lines.array_event_number(g_LineNumber)      := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_number;
         g_rec_lines.array_reversal_code(g_LineNumber)     := 'REVERSAL';
         g_rec_lines.array_entity_id(g_LineNumber)         := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id;
         g_rec_lines.array_balance_type_code(g_LineNumber) := 'E';
         g_rec_lines.array_calculate_acctd_flag(g_LineNumber) := 'N';
         g_rec_lines.array_calculate_g_l_flag(g_LineNumber)   := 'N';

         g_rec_lines.array_sys_distribution_type(g_LineNumber)  := l_sys_distribution_type;
         g_rec_lines.array_distribution_id_char_1(g_LineNumber) := l_distribution_id_char_1;
         g_rec_lines.array_distribution_id_num_1(g_LineNumber)  := l_distribution_id_num_1;
         g_rec_lines.array_distribution_id_char_2(g_LineNumber) := l_distribution_id_char_2;
         g_rec_lines.array_distribution_id_num_2(g_LineNumber)  := l_distribution_id_num_2;
         g_rec_lines.array_distribution_id_char_3(g_LineNumber) := l_distribution_id_char_3;
         g_rec_lines.array_distribution_id_num_3(g_LineNumber)  := l_distribution_id_num_3;
         g_rec_lines.array_distribution_id_char_4(g_LineNumber) := l_distribution_id_char_4;
         g_rec_lines.array_distribution_id_num_4(g_LineNumber)  := l_distribution_id_num_4;
         g_rec_lines.array_distribution_id_char_5(g_LineNumber) := l_distribution_id_char_5;
         g_rec_lines.array_distribution_id_num_5(g_LineNumber)  := l_distribution_id_num_5;
         g_rec_lines.array_rev_dist_id_char_1(g_LineNumber)     := l_rev_dist_id_char_1;
         g_rec_lines.array_rev_dist_id_num_1(g_LineNumber)      := l_rev_dist_id_num_1;
         g_rec_lines.array_rev_dist_id_char_2(g_LineNumber)     := l_rev_dist_id_char_2;
         g_rec_lines.array_rev_dist_id_num_2(g_LineNumber)      := l_rev_dist_id_num_2;
         g_rec_lines.array_rev_dist_id_char_3(g_LineNumber)     := l_rev_dist_id_char_3;
         g_rec_lines.array_rev_dist_id_num_3(g_LineNumber)      := l_rev_dist_id_num_3;
         g_rec_lines.array_rev_dist_id_char_4(g_LineNumber)     := l_rev_dist_id_char_4;
         g_rec_lines.array_rev_dist_id_num_4(g_LineNumber)      := l_rev_dist_id_num_4;
         g_rec_lines.array_rev_dist_id_char_5(g_LineNumber)     := l_rev_dist_id_char_5;
         g_rec_lines.array_rev_dist_id_num_5(g_LineNumber)      := l_rev_dist_id_num_5;
         g_rec_lines.array_rev_dist_type(g_LineNumber)          := l_rev_dist_type;

         g_rec_lines.array_entered_amount(g_LineNumber)       := l_enc_upg_cr_entered_amt;
         g_rec_lines.array_currency_code(g_LineNumber)        := l_enc_upg_cr_entered_curr;
         g_rec_lines.array_ledger_amount(g_LineNumber)        := l_enc_upg_cr_ledger_amt;
         g_rec_lines.array_accounting_class(g_LineNumber)     := l_enc_upg_cr_acct_class;
         g_rec_lines.array_encumbrance_type_id(g_LineNumber)  := l_upg_cr_enc_type_id;  -- 5845547

         -- 5845547 upgrade party attributes
         g_rec_lines.array_party_type_code(g_LineNumber)      := l_upg_party_type;
         g_rec_lines.array_party_id(g_LineNumber)             := l_upg_party_id;
         g_rec_lines.array_party_site_id(g_LineNumber)        := l_upg_party_site_id;


         g_rec_lines.array_natural_side_code(g_LineNumber)    := 'C';
         g_rec_lines.array_acct_entry_type_code(g_LineNumber) := 'E';
         g_rec_lines.array_switch_side_flag(g_LineNumber)     := 'Y';
         g_rec_lines.array_merge_duplicate_code(g_LineNumber) := 'N';
         g_rec_lines.array_gl_transfer_mode(g_LineNumber)     := 'S';

         g_rec_lines.array_currency_mau(g_LineNumber)         :=
            xla_accounting_cache_pkg.GetCurrencyMau(g_rec_lines.array_currency_code(g_LineNumber));

         xla_ae_lines_pkg.set_ccid(
          p_code_combination_id          => l_enc_upg_cr_ccid
        , p_value_type_code              => 'S' --l_adr_value_type_code
        , p_transaction_coa_id           => NULL --l_adr_transaction_coa_id
        , p_accounting_coa_id            => NULL --l_adr_accounting_coa_id
        , p_adr_code                     => NULL --'SS_TEST'
        , p_adr_type_code                => NULL --'C'
        , p_component_type               => g_accounting_line.component_type --l_component_type
        , p_component_code               => g_accounting_line.accounting_line_code  --l_component_code
        , p_component_type_code          => g_accounting_line.accounting_line_type_code --l_component_type_code
        , p_component_appl_id            => g_accounting_line.accounting_line_appl_id --l_component_appl_id
        , p_amb_context_code             => g_accounting_line.amb_context_code --l_amb_context_code
        , p_side                         => 'NA'
        );

        SetDebitCreditAmounts;
     END IF;

      --
      -- Validate the distribution links for the extract line
      -- if the validation fails, mark the dummy line as 'DUMMY_LR_ERROR'
      --
--      IF NOT ValidateRevLinks THEN
--         g_rec_lines.array_reversal_code(g_LineNumber) := 'DUMMY_LR_ERROR';
--      END IF;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetAcctReversalAttrs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
END SetAcctReversalAttrs;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetTrxReversalAttrs
       (p_event_id                     IN NUMBER
       ,p_gl_date                      IN DATE
       ,p_trx_reversal_source          IN VARCHAR2) IS
l_log_module         VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetTrxReversalAttrs';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of SetTrxReversalAttrs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   g_temp_line_num := -1;

   SetNewLine;

   set_ae_header_id (p_ae_header_id => p_event_id,
                     p_header_num   => 0);      -- 4262811 by default all zero.  1,2,.. are used by Accl Reversal or MPA.

   g_rec_lines.array_balance_type_code(g_LineNumber) := 'X';

   g_rec_lines.array_ledger_id(g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   g_rec_lines.array_event_number(g_LineNumber) := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_number;

   g_rec_lines.array_entity_id(g_LineNumber) := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id;

   g_rec_lines.array_reversal_code(g_LineNumber) := 'DUMMY_TR';

   g_rec_lines.array_gl_date(g_LineNumber) := p_gl_date;

   ------------------------------------------------------------------------------------------
   -- 5055878 Handle transaction reversal method option - SIDE and SIGN
   ------------------------------------------------------------------------------------------
   IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE' THEN
      g_rec_lines.array_switch_side_flag(g_LineNumber) := 'Y';
   ELSE
      g_rec_lines.array_switch_side_flag(g_LineNumber) := 'N';
   END IF;
   ------------------------------------------------------------------------------------------

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of SetTrxReversalAttrs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;
END SetTrxReversalAttrs;


PROCEDURE CalculateUnroundedAmounts
is
l_log_module         VARCHAR2(240);
l_ledger_attrs       xla_accounting_cache_pkg.t_array_ledger_attrs;
l_ledger_attrs1       xla_accounting_cache_pkg.t_array_ledger_attrs;
l_primary_ledger_currency  VARCHAR2(30):=null;
l_primary_ledger_id  NUMBER;
l_secondary_ledger_currency  VARCHAR2(30);
l_secondary_ledger_id  NUMBER;
l_ledger_id  NUMBER;
l_count number;
l_max_ledger_index   NUMBER;
l_euro               VARCHAR2(30);

/*
type t_array_derive_type table of FND_CURRENCY.derive_type%TYPE index by binary_integer;
l_array_from_derive_type  t_array_derive_type;
l_array_to_derive_type    t_array_derive_type;
l_array_from_rate         xla_ae_journal_entry_pkg.t_array_Num;
l_array_to_rate           xla_ae_journal_entry_pkg.t_array_Num;
l_array_from_curr         xla_ae_journal_entry_pkg.t_array_V30L;
l_array_to_curr           xla_ae_journal_entry_pkg.t_array_V30L;
*/

l_array_calculate_amts_flag  xla_ae_journal_entry_pkg.t_array_V1L;
l_array_conversion_type      xla_ae_journal_entry_pkg.t_array_V30L;
l_array_entered_curr         xla_ae_journal_entry_pkg.t_array_V30L;
l_array_conversion_date      xla_ae_journal_entry_pkg.t_array_Date;
l_array_conversion_rate      xla_ae_journal_entry_pkg.t_array_Num;
l_array_new_rate             xla_ae_journal_entry_pkg.t_array_Num;
l_array_new_type             xla_ae_journal_entry_pkg.t_array_V30L;
l_array_ledger_id            xla_ae_journal_entry_pkg.t_array_Int;
l_array_from_type            xla_ae_journal_entry_pkg.t_array_V30L;
l_array_to_type              xla_ae_journal_entry_pkg.t_array_V30L;
l_array_primary_type         xla_ae_journal_entry_pkg.t_array_V30L;

l_rate   NUMBER;
i        NUMBER;

cursor csr_lines is
  SELECT xal.calculate_acctd_amts_flag
        ,xal.currency_conversion_type
        ,TRUNC(nvl(xal.currency_conversion_date, xeg.transaction_date))
        ,decode(xal.currency_conversion_type, 'User', xal.currency_conversion_rate, -1)
        ,xal.currency_code
        ,xal.ledger_id
        ,decode( fc.derive_type, 'EURO', 'EURO', 'EMU',
                  decode( sign( trunc(nvl(xal.currency_conversion_date, xeg.transaction_date)) -
                      trunc(fc.derive_effective)), -1, 'OTHER', 'EMU'), 'OTHER' ) from_type
        ,decode( fc1.derive_type, 'EURO', 'EURO', 'EMU',
                  decode( sign( trunc(nvl(xal.currency_conversion_date, xeg.transaction_date)) -
                      trunc(fc1.derive_effective)), -1, 'OTHER', 'EMU'), 'OTHER' ) to_type
        ,decode( fc2.derive_type, 'EURO', 'EURO', 'EMU',
                  decode( sign( trunc(nvl(xal.currency_conversion_date, xeg.transaction_date)) -
                      trunc(fc2.derive_effective)), -1, 'OTHER', 'EMU'), 'OTHER' ) primary_type
    FROM xla_ae_lines_gt xal
        ,gl_ledgers gl
        ,fnd_currencies fc
        ,fnd_currencies fc1
        ,fnd_currencies fc2
        ,xla_events_gt xeg
   WHERE xal.ledger_id = gl.ledger_id
     AND gl.object_type_code      = 'L' /* only ledgers (not ledger sets) */
     AND gl.le_ledger_type_code   = 'L' /* only legal ledgers */
     AND xal.currency_code <> gl.currency_code
     AND xal.gain_or_loss_flag = 'N'
     AND xal.balance_type_code <> 'X'
     AND xal.calculate_acctd_amts_flag = 'Y'
     AND fc.currency_code = xal.currency_code
     AND fc1.currency_code = gl.currency_code
     AND fc2.currency_code = l_primary_ledger_currency
     AND xal.event_id = xeg.event_id
     AND nvl(xal.reversal_code,C_CHAR) <> C_DUMMY_PRIOR
  GROUP BY
         xal.calculate_acctd_amts_flag
        ,xal.currency_conversion_type
        ,TRUNC(nvl(xal.currency_conversion_date, xeg.transaction_date))
        ,xal.currency_conversion_rate
        ,xal.currency_code
        ,xal.ledger_id
        ,fc.derive_type
        ,fc.derive_effective
        ,fc1.derive_type
        ,fc1.derive_effective
        ,fc2.derive_type
        ,fc2.derive_effective
        ,decode(xal.currency_conversion_type, 'User', xal.currency_conversion_rate, -1)
        ;

BEGIN
  IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CalculateUnroundedAmounts';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of CalculateUnroundedAmounts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

  l_euro :='EUR';

  xla_accounting_cache_pkg.BuildLedgerArray(l_ledger_attrs1);

  l_max_ledger_index := l_ledger_attrs1.array_ledger_id.COUNT;
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'l_max_ledger_index:'||to_char(l_max_ledger_index)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
  For i in 1..l_max_ledger_index LOOP
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'i:'||to_char(i)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;
    l_ledger_id := l_ledger_attrs1.array_ledger_id(i);
    IF(l_ledger_attrs1.array_ledger_type(i) = 'PRIMARY') THEN
      l_primary_ledger_currency:= l_ledger_attrs1.array_ledger_currency_code(i);
      l_primary_ledger_id := l_ledger_id;
    ELSIF(l_ledger_attrs1.array_ledger_type(i) = 'SECONDARY') THEN
      l_secondary_ledger_currency:= l_ledger_attrs1.array_ledger_currency_code(i);
      l_secondary_ledger_id := l_ledger_id;
    END IF;
    l_ledger_attrs.array_ledger_currency_code(l_ledger_id)
                      := l_ledger_attrs1.array_ledger_currency_code(i);
    l_ledger_attrs.array_ledger_type(l_ledger_id)
                      := l_ledger_attrs1.array_ledger_type(i);
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'middle of loop, i:'||to_char(i)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;
    l_ledger_attrs.array_default_rate_type(l_ledger_id)
                      := l_ledger_attrs1.array_default_rate_type(i);
    l_ledger_attrs.array_inhert_type_flag(l_ledger_id)
                      := l_ledger_attrs1.array_inhert_type_flag(i);
    l_ledger_attrs.array_max_roll_date(l_ledger_id)
                      := l_ledger_attrs1.array_max_roll_date(i);
  END LOOP;

  IF l_primary_ledger_currency is null THEN
    l_primary_ledger_currency:=l_secondary_ledger_currency;
    l_primary_ledger_id:=l_secondary_ledger_id;
  END IF;

  OPEN csr_lines;

  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'Starting Loop'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;
  LOOP
    FETCH csr_lines
    BULK COLLECT INTO
         l_array_calculate_amts_flag
         ,l_array_conversion_type
         ,l_array_conversion_date
         ,l_array_conversion_rate
         ,l_array_entered_curr
         ,l_array_ledger_id
         ,l_array_from_type
         ,l_array_to_type
         ,l_array_primary_type
    LIMIT C_BULK_LIMIT;

    IF l_array_conversion_type.COUNT = 0 THEN
      EXIT;
    END IF;
    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'Loop Count:'||to_char(l_array_conversion_type.COUNT)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

    FOR i in 1..l_array_conversion_type.COUNT LOOP
      IF (C_LEVEL_STATEMENT>= g_log_level) THEN
          trace
             (p_msg      => 'i:'||to_char(i) || ' ledger id:'|| to_char(l_array_ledger_id (i))
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
          trace
             (p_msg      => 'ledger currency code:'||l_ledger_attrs.array_ledger_currency_code(l_array_ledger_id (i)) ||' entered curr:'|| l_array_entered_curr(i)
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
          trace
             (p_msg      => 'from type:'||l_array_from_type(i) || ' tto type:'||l_array_to_type(i)
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);
      END IF;
      BEGIN
        IF(l_array_from_type(i) in ('EMU', 'EURO')
           AND l_array_to_type(i) in ('EMU', 'EURO')) THEN
          IF (C_LEVEL_STATEMENT>= g_log_level) THEN
              trace
                 (p_msg      => 'if block1'
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
          END IF;

          l_array_new_type(i) :='EMU Fixed';
          l_array_new_rate(i) :=gl_currency_api.get_closest_rate(
                x_from_currency    => l_array_entered_curr(i)
                ,x_to_currency      => l_ledger_attrs.array_ledger_currency_code(l_array_ledger_id (i))
                ,x_conversion_date  => l_array_conversion_date(i)
                ,x_conversion_type  => 'EMU Fixed'
               ,x_max_roll_days    => l_ledger_attrs.array_max_roll_date(l_primary_ledger_id));
        ELSIF(l_array_ledger_id (i) = l_primary_ledger_id) THEN
          IF (C_LEVEL_STATEMENT>= g_log_level) THEN
              trace
                 (p_msg      => 'if block2'
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
          END IF;
          l_array_new_type(i) :=l_array_conversion_type(i);
          IF (l_array_conversion_type(i) = 'User') THEN
            l_array_new_rate(i) := l_array_conversion_rate(i);
            IF (C_LEVEL_STATEMENT>= g_log_level) THEN
              trace
                 (p_msg      => 'if block2:'||to_char(l_array_new_rate(i))
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
            END IF;

          ELSE
            l_array_new_rate(i):=gl_currency_api.get_closest_rate(
                x_from_currency    => l_array_entered_curr(i)
                ,x_to_currency      => l_primary_ledger_currency
                ,x_conversion_date  => l_array_conversion_date(i)
                ,x_conversion_type  => l_array_conversion_type(i)
               ,x_max_roll_days    => l_ledger_attrs.array_max_roll_date(l_primary_ledger_id));
            IF (C_LEVEL_STATEMENT>= g_log_level) THEN
              trace
                 (p_msg      => 'iif block2:'||to_char(l_array_new_rate(i))|| ' ent:'||l_array_entered_curr(i)||' to cur:'|| l_primary_ledger_currency || ' date:'||to_char(l_array_conversion_date(i))||' type:'||l_array_conversion_type(i)
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
            END IF;
          END IF;
        ELSE
          IF (C_LEVEL_STATEMENT>= g_log_level) THEN
              trace
                 (p_msg      => 'if block3'
                 ,p_level    => C_LEVEL_STATEMENT
                 ,p_module   => l_log_module);
          END IF;
          IF(l_array_conversion_type(i) = 'User' ) THEN
            IF(l_array_primary_type(i) in ('EMU', 'EURO')
                 AND l_array_from_type(i) in ('EMU', 'EURO')) THEN
              IF (C_LEVEL_STATEMENT>= g_log_level) THEN
                  trace
                     (p_msg      => 'if block4'
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   => l_log_module);
              END IF;
              l_array_new_type(i) :=l_ledger_attrs.array_default_rate_type(l_array_ledger_id (i));
              l_array_new_rate(i):=gl_currency_api.get_closest_rate(
                x_from_currency    => l_array_entered_curr(i)
                ,x_to_currency      => l_ledger_attrs.array_ledger_currency_code(l_array_ledger_id (i))
                ,x_conversion_date  => l_array_conversion_date(i)
                ,x_conversion_type  => l_array_new_type(i)
           ,x_max_roll_days    => l_ledger_attrs.array_max_roll_date(l_array_ledger_id (i)));
            ELSE
              IF (C_LEVEL_STATEMENT>= g_log_level) THEN
                  trace
                     (p_msg      => 'if block5'
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   => l_log_module);
              END IF;
              l_array_new_type(i) :=l_array_conversion_type(i);
              l_rate:=gl_currency_api.get_closest_rate(
                x_from_currency    => l_primary_ledger_currency
                ,x_to_currency      => l_ledger_attrs.array_ledger_currency_code(l_array_ledger_id (i))
                ,x_conversion_date  => l_array_conversion_date(i)
                ,x_conversion_type  => l_ledger_attrs.array_default_rate_type(l_array_ledger_id (i))
           ,x_max_roll_days    => l_ledger_attrs.array_max_roll_date(l_array_ledger_id (i)));
              l_array_new_rate(i):= l_array_conversion_rate(i) * l_rate;
            END IF;
          ELSIF(l_ledger_attrs.array_inhert_type_flag(l_array_ledger_id (i))='Y'and l_array_conversion_type(i) is not null) THEN
              IF (C_LEVEL_STATEMENT>= g_log_level) THEN
                  trace
                     (p_msg      => 'if block6'
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   => l_log_module);
              END IF;
            l_array_new_type(i) :=l_array_conversion_type(i);
            l_array_new_rate(i):=gl_currency_api.get_closest_rate(
                x_from_currency    => l_array_entered_curr(i)
                ,x_to_currency      => l_ledger_attrs.array_ledger_currency_code(l_array_ledger_id (i))
                ,x_conversion_date  => l_array_conversion_date(i)
                ,x_conversion_type  => l_array_conversion_type(i)
           ,x_max_roll_days    => l_ledger_attrs.array_max_roll_date(l_array_ledger_id (i)));
          ELSE
              IF (C_LEVEL_STATEMENT>= g_log_level) THEN
                  trace
                     (p_msg      => 'if block7'
                     ,p_level    => C_LEVEL_STATEMENT
                     ,p_module   => l_log_module);
              END IF;
            l_array_new_type(i) :=l_ledger_attrs.array_default_rate_type(l_array_ledger_id (i));
            l_array_new_rate(i):=gl_currency_api.get_closest_rate(
                x_from_currency    => l_array_entered_curr(i)
                ,x_to_currency      => l_ledger_attrs.array_ledger_currency_code(l_array_ledger_id (i))
                ,x_conversion_date  => l_array_conversion_date(i)
                ,x_conversion_type  => l_array_new_type(i)
           ,x_max_roll_days    => l_ledger_attrs.array_max_roll_date(l_array_ledger_id (i)));
          END IF;
        END IF;
      EXCEPTION
        WHEN gl_currency_api.NO_RATE THEN
          IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
              trace
                 (p_msg      => 'No rate for:'
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'entered:'||l_array_entered_curr(i)
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'accounting curr:'||l_ledger_attrs.array_ledger_currency_code(l_array_ledger_id(i))
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'date:'||to_char(l_array_conversion_date(i))
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'type:'||l_array_conversion_type(i)
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'ledger ID:'||to_char(l_array_ledger_id (i))
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
          END IF;
          l_array_new_rate(i) := null;
        WHEN others THEN
          IF (C_LEVEL_EXCEPTION>= g_log_level) THEN
              trace
                 (p_msg      => 'Exception:'
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'entered:'||l_array_entered_curr(i)
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'accounting curr:'||l_ledger_attrs.array_ledger_currency_code(l_array_ledger_id(i))
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'date:'||to_char(l_array_conversion_date(i))
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'type:'||l_array_conversion_type(i)
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
              trace
                 (p_msg      => 'ledger ID:'||to_char(l_array_ledger_id (i))
                 ,p_level    => C_LEVEL_EXCEPTION
                 ,p_module   => l_log_module);
          END IF;
          RAISE;
      END;
    END LOOP;

    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'ending Loop'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

/*
      FOR i in 1..l_array_conversion_type.COUNT LOOP
        trace
           (p_msg      => 'i:'||to_char(i)|| ' new rate:'||to_char(l_array_new_rate(i))||' type:'||l_array_new_type(i)
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
        trace
           (p_msg      => 'i:'||to_char(i)|| ' ledger id:'||to_char(l_array_ledger_id(i))||' curr:'||l_array_entered_curr(i)||' type:'|| l_array_conversion_type(i)||' date:'||to_char(l_array_conversion_date(i))
           ,p_level    => C_LEVEL_STATEMENT
           ,p_module   => l_log_module);
      END LOOP;
*/

    END IF;
    FORALL i in 1..l_array_conversion_type.COUNT
        UPDATE xla_ae_lines_gt xal
           SET currency_conversion_rate = l_array_new_rate(i)
              ,currency_conversion_type = l_array_new_type(i)
              ,currency_conversion_date = l_array_conversion_date(i)
              ,unrounded_accounted_cr   = unrounded_entered_cr * l_array_new_rate(i)
              ,unrounded_accounted_dr   = unrounded_entered_dr * l_array_new_rate(i)
         WHERE xal.ledger_id = l_array_ledger_id(i)
           AND xal.currency_code = l_array_entered_curr(i)
           AND xal.gain_or_loss_flag = 'N'
           AND xal.balance_type_code <> 'X'
           AND xal.calculate_acctd_amts_flag = 'Y'
           AND (xal.currency_conversion_type = l_array_conversion_type(i)
                 or (xal.currency_conversion_type is null and l_array_conversion_type(i) is null))
           AND l_array_conversion_date(i) =
                  (select TRUNC(nvl(xal.currency_conversion_date, xeg.transaction_date))
                     from xla_events_gt xeg
                    where xal.event_id = xeg.event_id)
           AND decode(currency_conversion_type, 'User', currency_conversion_rate, -1) = l_array_conversion_rate(i)
           AND nvl(xal.reversal_code,'dd') <> C_DUMMY_PRIOR
           ;

    IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'ending update'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
    END IF;

  END LOOP;
  IF (C_LEVEL_STATEMENT>= g_log_level) THEN
      trace
         (p_msg      => 'ending loop outside'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

  CLOSE csr_lines;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'Before the assignment of unrounded amount and conversion rate'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      trace
         (p_msg      => 'l_ledger_attrs.array_ledger_id.count:'||to_char(l_ledger_attrs.array_ledger_id.COUNT)||' loop count:'||to_char(l_max_ledger_index)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
  END IF;

/*
  FORALL i in 1..l_max_ledger_index
    UPDATE xla_ae_lines_gt xal
       SET (xal.unrounded_accounted_dr
           ,xal.unrounded_accounted_cr
           ,xal.currency_conversion_rate
           )
        =
     (SELECT
        CASE xal.currency_code
        WHEN l_ledger_attrs.array_ledger_currency_code(i) THEN
          xal.entered_dr
        ELSE
          CASE l_ledger_attrs.array_ledger_type(i)
          WHEN 'PRIMARY' THEN
            CASE calculate_acctd_amts_flag
            WHEN 'Y' THEN
              CASE xal.currency_conversion_type
              WHEN 'User' THEN
                xal.entered_dr * xal.currency_conversion_rate
              ELSE
                xal.entered_dr *
                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END
              END
            ELSE
              xal.unrounded_accounted_dr
            END
          ELSE
            CASE xal.currency_conversion_type
            WHEN 'User' THEN
              xal.entered_dr * xal.currency_conversion_rate *
                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END
            ELSE
              xal.entered_dr *
                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END
            END
          END
        END,
        CASE xal.currency_code
        WHEN l_ledger_attrs.array_ledger_currency_code(i) THEN
          xal.entered_cr
        ELSE
          CASE l_ledger_attrs.array_ledger_type(i)
          WHEN 'PRIMARY' THEN
            CASE calculate_acctd_amts_flag
            WHEN 'Y' THEN
              CASE xal.currency_conversion_type
              WHEN 'User' THEN
                xal.entered_cr * xal.currency_conversion_rate
              ELSE
                xal.entered_cr *
                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END
              END
            ELSE
              xal.unrounded_accounted_cr
            END
          ELSE
            CASE xal.currency_conversion_type
            WHEN 'User' THEN
              xal.entered_cr * xal.currency_conversion_rate *
                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END
            ELSE
              xal.entered_cr *
                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END
            END
          END
        END,
        CASE xal.currency_code
        WHEN l_ledger_attrs.array_ledger_currency_code(i) THEN
          null
        ELSE
          CASE l_ledger_attrs.array_ledger_type(i)
          WHEN 'PRIMARY' THEN
            CASE calculate_acctd_amts_flag
            WHEN 'Y' THEN
              CASE xal.currency_conversion_type
              WHEN 'User' THEN
                xal.currency_conversion_rate
              ELSE
                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END
              END
            ELSE
              xal.currency_conversion_rate
            END
          ELSE
            CASE xal.currency_conversion_type
            WHEN 'User' THEN
              xal.currency_conversion_rate *
                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END
            ELSE

                CASE decode( fc.derive_type,'EURO', 'EURO',
                     'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                     trunc(xah.accounting_date)) -trunc(fc.derive_effective)),
                   -1, 'OTHER','EMU'),'OTHER' )
                WHEN 'EMU' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )/
                     decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  WHEN 'EURO' THEN
                     1/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate/decode( fc.derive_type, 'EURO', 1,
                  'EMU', fc.derive_factor,'OTHER', -1 )
                  END
                WHEN 'EURO' THEN
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) -trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                     decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                ELSE
                  CASE decode( fc1.derive_type,'EURO', 'EURO',
                       'EMU', decode( sign(nvl(trunc(xal.currency_conversion_date),
                       trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                  WHEN 'EMU' THEN
                      ra.conversion_rate*decode( fc1.derive_type, 'EURO', 1,
                  'EMU', fc1.derive_factor,'OTHER', -1 )
                  ELSE ra.conversion_rate
                  END
                END

            END
          END
        END
      FROM   gl_daily_rates ra
            ,xla_ae_headers_gt xah
            ,FND_CURRENCIES fc
            ,FND_CURRENCIES fc1
      WHERE  ra.conversion_date(+)=
                 nvl(trunc(xal.currency_conversion_date), trunc(xah.accounting_date))
        AND  ra.conversion_type        (+)=
               CASE l_ledger_attrs.array_ledger_type(i)
               WHEN 'PRIMARY' THEN xal.currency_conversion_type
               ELSE
                 CASE xal.currency_conversion_type
                 WHEN 'User' THEN l_ledger_attrs.array_default_rate_type(i)
                 ELSE
                   CASE l_ledger_attrs.array_inhert_type_flag(i)
                   WHEN 'Y' THEN
                     CASE xal.currency_code
                     WHEN l_primary_ledger_currency THEN
                       l_ledger_attrs.array_default_rate_type(i)
                     ELSE xal.currency_conversion_type
                     END
                   ELSE l_ledger_attrs.array_default_rate_type(i)
                   END
                 END
               END
       AND  ra.from_currency (+)=
               CASE decode( fc.derive_type,'EURO', 'EURO','EMU',
                    decode( sign(nvl(trunc(xal.currency_conversion_date),
                    trunc(xah.accounting_date)) - trunc(fc.derive_effective)),
                    -1, 'OTHER','EMU'),'OTHER' )
               WHEN 'EMU' THEN
                 CASE decode( fc1.derive_type,'EURO', 'EURO','EMU',
                      decode( sign(nvl(trunc(xal.currency_conversion_date),
                      trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                 WHEN 'OTHER' THEN l_euro
                 ELSE decode(xal.currency_conversion_type, 'User',
                          l_primary_ledger_currency, xal.currency_code)
                 END
               ELSE decode(xal.currency_conversion_type, 'User',
                          l_primary_ledger_currency, xal.currency_code)
               END
       AND    ra.to_currency (+)=
               CASE decode( fc.derive_type,'EURO', 'EURO','EMU',
                    decode( sign(nvl(trunc(xal.currency_conversion_date),
                    trunc(xah.accounting_date)) - trunc(fc.derive_effective)),
                    -1, 'OTHER','EMU'),'OTHER' )
               WHEN 'OTHER' THEN
                 CASE decode( fc1.derive_type,'EURO', 'EURO','EMU',
                      decode( sign(nvl(trunc(xal.currency_conversion_date),
                      trunc(xah.accounting_date)) - trunc(fc1.derive_effective)),
                      -1, 'OTHER','EMU'),'OTHER' )
                 WHEN 'EMU' THEN l_euro
                 ELSE l_ledger_attrs.array_ledger_currency_code(i)
                 END
               ELSE l_ledger_attrs.array_ledger_currency_code(i)
               END
       AND xal.ae_header_id = xah.ae_header_id
       AND xal.ledger_id = xah.ledger_id
       AND xal.balance_type_code = xah.balance_type_code
       AND xah.balance_type_code <> 'X'
          )
   WHERE xal.gain_or_loss_flag = 'N'
     AND xal.ledger_id = l_ledger_attrs.array_ledger_id(i)
--     AND xal.ledger_amount is null
     AND xal.balance_type_code <> 'X'
     AND xal.reversal_code is null;
*/
/*

  FORALL i in 1..l_max_ledger_index
    UPDATE xla_ae_lines_gt xal
       SET (xal.unrounded_accounted_dr
           ,xal.unrounded_accounted_cr
           ,xal.currency_conversion_rate
           )
        =
     (SELECT
        CASE xal.currency_code
        WHEN l_ledger_attrs.array_ledger_currency_code(i) THEN
          xal.entered_dr
        ELSE
          CASE l_ledger_attrs.array_ledger_type(i)
          WHEN 'PRIMARY' THEN
            CASE calculate_acctd_amts_flag
            WHEN 'Y' THEN
              CASE xal.currency_conversion_type
              WHEN 'User' THEN
                xal.entered_dr * xal.currency_conversion_rate
              ELSE
                xal.entered_dr * ra.conversion_rate
              END
            ELSE
              xal.unrounded_accounted_dr
            END
          ELSE
            CASE xal.currency_conversion_type
            WHEN 'User' THEN
              xal.entered_dr * xal.currency_conversion_rate * ra.conversion_rate
            ELSE
              xal.entered_dr * ra.conversion_rate
            END
          END
        END,
        CASE xal.currency_code
        WHEN l_ledger_attrs.array_ledger_currency_code(i) THEN
          xal.entered_cr
        ELSE
          CASE l_ledger_attrs.array_ledger_type(i)
          WHEN 'PRIMARY' THEN
            CASE calculate_acctd_amts_flag
            WHEN 'Y' THEN
              CASE xal.currency_conversion_type
              WHEN 'User' THEN
                xal.entered_cr * xal.currency_conversion_rate
              ELSE
                xal.entered_cr * ra.conversion_rate
              END
            ELSE
              xal.unrounded_accounted_cr
            END
          ELSE
            CASE xal.currency_conversion_type
            WHEN 'User' THEN
              xal.entered_cr * xal.currency_conversion_rate * ra.conversion_rate
            ELSE
              xal.entered_cr * ra.conversion_rate
            END
          END
        END,
        CASE xal.currency_code
        WHEN l_ledger_attrs.array_ledger_currency_code(i) THEN
          null
        ELSE
          CASE l_ledger_attrs.array_ledger_type(i)
          WHEN 'PRIMARY' THEN
            CASE calculate_acctd_amts_flag
            WHEN 'Y' THEN
              CASE xal.currency_conversion_type
              WHEN 'User' THEN
                xal.currency_conversion_rate
              ELSE
                ra.conversion_rate
              END
            ELSE
              xal.currency_conversion_rate
            END
          ELSE
            CASE xal.currency_conversion_type
            WHEN 'User' THEN
              xal.currency_conversion_rate * ra.conversion_rate
            ELSE
              ra.conversion_rate
            END
          END
        END
      FROM   gl_daily_rates ra
            ,xla_ae_headers_gt xah
      WHERE  ra.conversion_date(+)=
                 nvl(trunc(xal.currency_conversion_date), trunc(xah.accounting_date))
        AND  ra.conversion_type        (+)=
               CASE l_ledger_attrs.array_ledger_type(i)
               WHEN 'PRIMARY' THEN xal.currency_conversion_type
               ELSE
                 CASE xal.currency_conversion_type
                 WHEN 'User' THEN l_ledger_attrs.array_default_rate_type(i)
                 ELSE
                   CASE l_ledger_attrs.array_inhert_type_flag(i)
                   WHEN 'Y' THEN
                     CASE xal.currency_code
                     WHEN l_primary_ledger_currency THEN
                       l_ledger_attrs.array_default_rate_type(i)
                     ELSE xal.currency_conversion_type
                     END
                   ELSE l_ledger_attrs.array_default_rate_type(i)
                   END
                 END
               END
       AND  ra.from_currency (+)= decode(xal.currency_conversion_type, 'User',
                          l_primary_ledger_currency, xal.currency_code)
       AND    ra.to_currency (+)= l_ledger_attrs.array_ledger_currency_code(i)
       AND xal.ae_header_id = xah.ae_header_id
       AND xal.ledger_id = xah.ledger_id
       AND xal.balance_type_code = xah.balance_type_code
       AND xah.balance_type_code <> 'X'
          )
   WHERE xal.gain_or_loss_flag = 'N'
     AND xal.ledger_id = l_ledger_attrs.array_ledger_id(i)
     AND xal.balance_type_code <> 'X'
     AND xal.reversal_code is null;
*/


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of CalculateUnroundedAmounts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;

Exception
  When OTHERS THEN
    IF (C_LEVEL_UNEXPECTED>= g_log_level) THEN
      trace
         (p_msg      => 'ERROR HERE:'||sqlerrm
         ,p_level    => C_LEVEL_UNEXPECTED
         ,p_module   => l_log_module);
    END IF;

    raise;

END CalculateUnroundedAmounts;

--  bug 8773083  Modified CalculateGainLossAmounts

PROCEDURE CalculateGainLossAmounts
is
l_log_module         VARCHAR2(240);
l_ledger_attrs       xla_accounting_cache_pkg.t_array_ledger_attrs;
l_ledger_currency    xla_accounting_cache_pkg.t_array_varchar;
--l_primary_ledger_id  NUMBER;
l_temp               number;

l_array_accounted_amount    t_array_number;
l_array_entered_amount      t_array_number;
l_array_currency_code       t_array_char30;
l_array_balance_type_code   t_array_char1;
l_array_ae_header_id        t_array_number;
l_array_gain_or_loss_ref    t_array_char30;
l_array_ledger_id           t_array_number;
l_array_event_id            t_array_number;
l_array_gain_or_loss_flag   t_array_char1;
l_array_cal_g_l_flag        t_array_char1;

l_res_array_ledger_id          t_array_number;
l_res_array_ae_header_id       t_array_number;
l_res_array_temp_line_num      t_array_number;
l_res_array_ref_ae_header_id   t_array_number;
l_res_array_header_num         t_array_number;
l_res_array_accounted_amount   t_array_number;
l_res_array_entered_amount     t_array_number;
l_res_array_min_currency_code  t_array_char30;
l_res_array_max_currency_code  t_array_char30;
l_res_array_extract_line_num   t_array_number;

CURSOR csr_gain_loss_amts IS
SELECT /*+ ordered use_hash(xal2) */
       nvl(sum(xal2.unrounded_accounted_dr), 0)
               - nvl(sum(xal2.unrounded_accounted_cr), 0)
      ,min(xal2.currency_code)
      ,max(xal2.currency_code)
      ,min(xal2.extract_line_num)
      ,iv.ledger_id
      ,iv.ae_header_id
      ,balance_type_code
      ,gain_or_loss_ref
      ,event_id
FROM
   ( SELECT /*+ use_hash(xal) no_merge */ DISTINCT xal.ae_header_id,xal.ledger_id -- bug9445893
      FROM XLA_AE_LINES_GT xal
      WHERE nvl(xal.gain_or_loss_flag, 'N') = 'Y'
      AND xal.balance_type_code          <> 'X'
      AND xal.calculate_g_l_amts_flag    = 'Y'
      AND xal.reversal_code              IS NULL    ) iv,
   XLA_AE_LINES_GT xal2
   WHERE nvl(xal2.gain_or_loss_flag, 'N') = 'N'
     AND xal2.balance_type_code               <> 'X'
     AND (xal2.reversal_code  is NULL OR xal2.reversal_code =C_DUMMY_SAME )
     AND xal2.ae_header_id = iv.ae_header_id
     AND xal2.ledger_id = iv.ledger_id
HAVING nvl(sum(xal2.unrounded_accounted_dr), 0)  <> nvl(sum(xal2.unrounded_accounted_cr), 0)
GROUP by iv.ledger_id, iv.ae_header_id, balance_type_code, gain_or_loss_ref, event_id ;

BEGIN
  IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CalculateGainLossAmounts';
  END IF;
 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of CalculateGainLossAmounts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;


--redoing code changes to multiple fixes bug 6675871 and
--perf fixes via 6658161,6727907 ,5745199,5394727,6332205
/* final understanding:
Per distribution we'd have a DR row, a CR row and a row which is the gain/loss row (if XLA is asked to cal G/L)
The demarcation is via gain_or_loss_flag. effectively the gain_or_loss_ref is either passed by subledgers or we stamp it to #extract line num,
and we calculate the sum (dr-cr) for rows with GAIN_OR_LOSS_FLAG=N and then update that amount to row with GAIN_OR_LOSS_FLAG=Y
of the same gain_or_loss_ref value (under the same header/ledger..).
this is how we are calculating the gain loss. And we need to do this calculation ONLY when gain_or_loss_flag=Y row exists
code is now similar to 120.175 except the HINTs and CURSOR.
*/
OPEN csr_gain_loss_amts;
LOOP
    FETCH csr_gain_loss_amts BULK COLLECT INTO  l_res_array_accounted_amount
                                             ,l_res_array_min_currency_code
                                             ,l_res_array_max_currency_code
                                             ,l_res_array_extract_line_num
                                             ,l_array_ledger_id
                                             ,l_array_ae_header_id
                                             ,l_array_balance_type_code
                                             ,l_array_gain_or_loss_ref
                                             ,l_array_event_id
    LIMIT C_BULK_LIMIT;

    IF l_res_array_accounted_amount.COUNT = 0 THEN
      IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
       trace
         (p_msg      => 'Count 0 EXIT CalculateGainLossAmounts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
      END IF;
      EXIT;
    END IF;

 FORALL Idx IN 1 .. l_array_ae_header_id.COUNT
      UPDATE /*+ index(xal XLA_AE_LINES_GT_N4)*/  xla_ae_lines_gt xal   --9483834  incorrect alias in the hint.
         SET xal.unrounded_accounted_cr =
                     CASE sign(l_res_array_accounted_amount(Idx))
                     WHEN -1 THEN NULL
                     ELSE l_res_array_accounted_amount(Idx)
                     END
            ,xal.unrounded_entered_cr =
                     CASE sign(l_res_array_accounted_amount(Idx))
                     WHEN -1 THEN NULL
                     ELSE 0
                     END
            ,xal.unrounded_accounted_dr =
                     CASE sign(l_res_array_accounted_amount(Idx))
                     WHEN -1 THEN 0-l_res_array_accounted_amount(Idx)
                     ELSE NULL
                     END
            ,xal.unrounded_entered_dr =
                     CASE sign(l_res_array_accounted_amount(Idx))
                     WHEN -1 THEN 0
                     ELSE NULL
                     END
            ,xal.currency_code =
                     DECODE (l_res_array_min_currency_code(Idx),
                               xal.currency_code,
                               l_res_array_max_currency_code(Idx),
                               l_res_array_min_currency_code(Idx))
            ,xal.balance_type_code = decode(l_res_array_accounted_amount(Idx), 0, 'X',
                                        decode(xal.extract_line_num,
                                               l_res_array_extract_line_num(Idx),
                                               xal.balance_type_code,
                                               'X'))
     WHERE nvl(xal.gain_or_loss_flag, 'N') = 'Y'
       AND balance_type_code               <> 'X'
       AND xal.calculate_g_l_amts_flag     = 'Y'
       AND xal.reversal_code               is NULL
       AND xal.ae_header_id                = l_array_ae_header_id(Idx)
       AND xal.balance_type_code           = l_array_balance_type_code(Idx)
       AND xal.gain_or_loss_ref            = l_array_gain_or_loss_ref(Idx)
       AND xal.ledger_id                   = l_array_ledger_id(Idx)
       AND (xal.currency_code              <> l_res_array_min_currency_code(Idx)
            OR xal.currency_code           <> l_res_array_max_currency_code(Idx))
      -- this OR condition was added in 120.173
       AND xal.event_id                    = l_array_event_id(Idx);

  END LOOP;
  CLOSE csr_gain_loss_amts;

  IF (g_num_bflow_prior_entries > 0) THEN
    UPDATE /*+ index(xal XLA_AE_LINES_GT_N3)*/ xla_ae_lines_gt xal     --9483834  incorrect alias in the hint.
       SET xal.currency_code =
            (SELECT /*+ index(xal2 XLA_AE_LINES_GT_N4)*/  max(currency_code)
               FROM xla_ae_lines_gt xal2
              WHERE xal2.ae_header_id = xal.ae_header_id
                AND xal2.balance_type_code <> 'X'
                AND xal2.gain_or_loss_ref = xal.gain_or_loss_ref
                AND xal2.ledger_id = xal.ledger_id
                AND xal2.event_id = xal.event_id
                AND nvl(xal2.gain_or_loss_flag, 'N') = 'N'
                AND xal2.reversal_code = C_DUMMY_PRIOR)
     WHERE xal.gain_or_loss_flag = 'Y'
       AND balance_type_code <> 'X'
       AND xal.calculate_g_l_amts_flag = 'Y'
       AND xal.reversal_code  is NULL
       and (xal.ae_header_id, balance_type_code, gain_or_loss_ref, ledger_id, event_id)
           in
           (select /*+ index(xal XLA_AE_LINES_GT_N4)*/ ae_header_id, balance_type_code, gain_or_loss_ref, ledger_id, event_id
	   --9483834  incorrect alias in the hint.
              from xla_ae_lines_gt xal3
              where xal3.ae_header_id = xal.ae_header_id
                AND xal3.balance_type_code <> 'X'
                AND xal3.gain_or_loss_ref = xal.gain_or_loss_ref
                AND xal3.ledger_id = xal.ledger_id
                AND xal3.event_id = xal.event_id
                AND nvl(xal3.gain_or_loss_flag, 'N') = 'N'
                and xal3.reversal_code = C_DUMMY_PRIOR);
  END IF;


  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of CalculateGainLossAmounts'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
Exception
  When OTHERS THEN
    raise;

END CalculateGainLossAmounts;




/*======================================================================+
|                                                                       |
| Public Procedure- Business Flow Validaton - 4219869                   |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE Business_Flow_Validation
       (p_business_method_code         IN VARCHAR2
       ,p_business_class_code          IN VARCHAR2
       ,p_inherit_description_flag     IN VARCHAR2) IS

   l_log_module         VARCHAR2(240);
   l_ledger_ccy         VARCHAR2(30);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.Business_Flow_Validation';
   END IF;
--
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'BEGIN of Business_Flow_Validation'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

   g_rec_lines.array_business_method_code(g_LineNumber) := p_business_method_code;
 --g_rec_lines.array_business_class_code(g_LineNumber)  := p_business_class_code;  -- 4336173 move to xla_cmp_acct_line_type_pkg.C_ALT_BODY
   g_rec_lines.array_inherit_desc_flag(g_LineNumber)    := p_inherit_description_flag;

   IF p_inherit_description_flag = 'Y' THEN
      g_rec_lines.array_description(g_LineNumber) := NULL;
   END IF;

   IF p_business_method_code = C_METHOD_PRIOR THEN

      ------------------------------------------------
      -- Validate the applied-to accounting attributes
      ------------------------------------------------
      ValidateBFlowLinks;

      -------------------------------------------------
      -- Reset values for certain fields in g_rec_lines
      -------------------------------------------------
      /* 4482069  This will be set in xla_cmp_acct_line_type_pkg.GetAccountingSources
      l_ledger_ccy := xla_accounting_cache_pkg.GetValueChar(
                           p_source_code =>       'XLA_CURRENCY_CODE'
                          ,p_target_ledger_id=>   g_rec_lines.array_ledger_id(g_LineNumber));
      g_rec_lines.array_currency_code(g_LineNumber)         := l_ledger_ccy;
      */

      --g_rec_lines.array_currency_mau(g_LineNumber)          := xla_accounting_cache_pkg.GetCurrencyMau(l_ledger_ccy);
      g_rec_lines.array_curr_conversion_date(g_LineNumber)  := NULL;
      g_rec_lines.array_curr_conversion_rate(g_LineNumber)  := NULL;
      g_rec_lines.array_curr_conversion_type(g_LineNumber)  := NULL;
      g_rec_lines.array_party_type_code(g_LineNumber)       := NULL;
      g_rec_lines.array_party_id(g_LineNumber)              := NULL;
      g_rec_lines.array_party_site_id(g_LineNumber)         := NULL;
      g_rec_lines.array_encumbrance_type_id(g_LineNumber)   := NULL;

      ----------------------------------
      -- Set reversal code to DUMMY_BFPE
      ----------------------------------
      g_rec_lines.array_reversal_code(g_LineNumber) := C_DUMMY_PRIOR;

      ------------------------------------------------------
      -- Increment number of business flow prior entry lines
      ------------------------------------------------------
      g_num_bflow_prior_entries := g_num_bflow_prior_entries + 1;

   ELSIF p_business_method_code = C_METHOD_SAME THEN

      ----------------------------------
      -- Set reversal code to DUMMY_BFSE
      ----------------------------------
      g_rec_lines.array_reversal_code(g_LineNumber) := C_DUMMY_SAME;

      -----------------------------------------------------
      -- Increment number of business flow same entry lines
      -----------------------------------------------------
      g_num_bflow_same_entries := g_num_bflow_same_entries + 1;

   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'END of Business_Flow_Validation'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

EXCEPTION
--
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_lines_pkg.Business_Flow_Validation');
  --
END Business_Flow_Validation;


/*======================================================================+
|                                                                       |
| Public Procedure- Business Flow Prior Entry - 4219869                 |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE BusinessFlowPriorEntries
(p_accounting_mode      IN VARCHAR2
,p_ledger_id            IN NUMBER
,p_bc_mode              IN VARCHAR2)
IS

   --------------------------------------------------------------------------------
   --  5357406 - prior entry performance fix
   l_array_row_id                            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
   l_array_ccid                              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_description                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_V4000L;
   l_array_currency_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V15L;
   l_array_curr_conversion_rate              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_curr_conversion_type              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
   l_array_curr_conversion_date              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
   l_array_currency_mau                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_unrounded_entered_cr              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_unrounded_entered_dr              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_party_type_code                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L;
   l_array_party_id                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_party_site_id                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_encumbrance_type_id               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Int;
   l_array_ccid_status_code                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
   l_array_ref_event_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_temp_ref_ae_header_id             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_ref_ae_line_num                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_ref_temp_line_num                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_bflow_pe_status_code              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
   l_array_pe_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
   l_array_pe_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;


   CURSOR c_bflow_ae_lines IS
   SELECT gt.ROW_ID
               ,gt.code_combination_id
               ,gt.description
               ,gt.currency_code
               ,gt.currency_conversion_rate
               ,gt.currency_conversion_type
               ,gt.currency_conversion_date
               ,gt.entered_currency_mau
               ,gt.unrounded_entered_cr
               ,gt.unrounded_entered_dr
               ,gt.party_type_code
               ,gt.party_id
               ,gt.party_site_id
               ,gt.encumbrance_type_id
               ,gt.code_combination_status_code
               ,gt.ref_event_id
               ,gt.temp_ref_ae_header_id
               ,gt.ref_ae_line_num
               ,gt.ref_temp_line_num
               ,gt.bflow_prior_entry_status_code
               ,gt.applied_to_entity_id
			   	--Added for 9352035
			   ,gt.DERIVED_EXCH_RATE
   FROM (SELECT /*+Leading(xalg xte xdl) use_nl(xalg xte xah xal xdl) */
   --         Bug 8250875 changed hint to xah xal and xdl
               xalg.ROWID                                                                       ROW_ID
               , RANK() OVER ( PARTITION BY xalg.ROWID
                               ORDER BY xdl.ae_header_id desc, xdl.ae_line_num ASC  )             line_rank
               ,(NVL(xal.merge_code_combination_id,xal.code_combination_id))                    code_combination_id
               ,(DECODE(xalg.inherit_desc_flag, 'Y', xal.description, xalg.description))         description
               ,(xal.currency_code)                                                              currency_code
               ,(DECODE(xal.currency_code
                      ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                      ,NULL
                      ,xal.currency_conversion_rate))                                            currency_conversion_rate
               ,(DECODE(xal.currency_code
                      ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                      ,NULL
                      ,xal.currency_conversion_type))                                            currency_conversion_type
               ,(DECODE(xal.currency_code
                      ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                      ,NULL
                      ,xal.currency_conversion_date))                                            currency_conversion_date
               ,(xla_accounting_cache_pkg.GetCurrencyMau(xal.currency_code))                     entered_currency_mau
               ,(DECODE(xdl.calculate_acctd_amts_flag
                      ,'N', DECODE(xalg.currency_code
                                 ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                                 ,NVL(xalg.unrounded_accounted_cr,xalg.unrounded_entered_cr)
                                 ,xalg.unrounded_entered_cr)
                     ,xalg.unrounded_entered_cr)  )                                               unrounded_entered_cr
               ,(DECODE(xdl.calculate_acctd_amts_flag
                     ,'N', DECODE(xalg.currency_code
                                 ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                                 ,NVL(xalg.unrounded_accounted_dr,xalg.unrounded_entered_dr)
                                 ,xalg.unrounded_entered_dr)
                     ,xalg.unrounded_entered_dr))                                               unrounded_entered_dr
               ,(xal.party_type_code)                                                          party_type_code
               ,(NVL(xal.merge_party_id,xal.party_id))                                        party_id
               ,(NVL(xal.merge_party_site_id,xal.party_site_id))                              party_site_id
               ,(xal.encumbrance_type_id)                                                      encumbrance_type_id
               ,C_CREATED                                                                       code_combination_status_code
               ,(xdl.event_id)                                                                 ref_event_id
               ,(xdl.ae_header_id)                                                             temp_ref_ae_header_id
               ,(xal.ae_line_num)                                                              ref_ae_line_num
               ,(xdl.temp_line_num)                                                            ref_temp_line_num
               ,(DECODE(xalg.currency_code,xal.currency_code,xah.accounting_entry_status_code,
                        DECODE(xalg.bflow_applied_to_amount, NULL, 'X', xah.accounting_entry_status_code))) bflow_prior_entry_status_code
               ,(xah.entity_id)                                                                applied_to_entity_id
			   --Added for 9352035
			   ,(DECODE(xal.currency_code
                      ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                      ,NULL
                      ,DECODE (xdl.unrounded_accounted_dr,NULL
                                ,CASE WHEN nvl(xdl.unrounded_entered_cr,0) <> 0
                                      THEN
                                           (xdl.unrounded_accounted_cr/xdl.unrounded_entered_cr)
                                      ELSE xal.currency_conversion_rate END
                                ,CASE WHEN nvl(xdl.unrounded_entered_dr,0) <> 0
                                      THEN
                                           (xdl.unrounded_accounted_dr/xdl.unrounded_entered_dr)
                                      ELSE xal.currency_conversion_rate END
								)
						)
				) DERIVED_EXCH_RATE
           FROM   xla_ae_lines_gt          xalg
                 ,xla_transaction_entities xte
                 ,xla_ae_headers    xah
                 ,xla_distribution_links   xdl
                 ,xla_ae_lines      xal
--               ,xla_ledger_relationships_v  xlr
--               ,xla_gl_ledgers_v            xgl
--               ,xla_ledger_options          xlo
           WHERE  xah.application_id               = xdl.application_id
           AND    xah.ae_header_id                 = xdl.ae_header_id
	   --         Bug 8250875 join headers to lines also
	   AND    xah.application_id               = xal.application_id
           AND    xah.ae_header_id                 = xal.ae_header_id
           AND    xal.application_id               = xdl.application_id
           AND    xal.ae_header_id                 = xdl.ae_header_id
           AND    xal.ae_line_num                  = xdl.ae_line_num
           AND    xal.business_class_code          = xalg.business_class_code
           AND    xdl.source_distribution_type     = xalg.bflow_distribution_type
           AND    xdl.source_distribution_id_num_1   = NVL(xalg.bflow_dist_id_num_1,-99)
           AND    NVL(xdl.source_distribution_id_num_2,-99)   = NVL(xalg.bflow_dist_id_num_2,-99)
           AND    NVL(xdl.source_distribution_id_num_3,-99)   = NVL(xalg.bflow_dist_id_num_3,-99)
           AND    NVL(xdl.source_distribution_id_num_4,-99)   = NVL(xalg.bflow_dist_id_num_4,-99)
           AND    NVL(xdl.source_distribution_id_num_5,-99)   = NVL(xalg.bflow_dist_id_num_5,-99)
           AND    NVL(xdl.source_distribution_id_char_1,' ') = NVL(xalg.bflow_dist_id_char_1,' ')
           AND    NVL(xdl.source_distribution_id_char_2,' ') = NVL(xalg.bflow_dist_id_char_2,' ')
           AND    NVL(xdl.source_distribution_id_char_3,' ') = NVL(xalg.bflow_dist_id_char_3,' ')
           AND    NVL(xdl.source_distribution_id_char_4,' ') = NVL(xalg.bflow_dist_id_char_4,' ')
           AND    NVL(xdl.source_distribution_id_char_5,' ') = NVL(xalg.bflow_dist_id_char_5,' ')
           AND    xah.parent_ae_header_id IS NULL
           --
           -- exclude reversed entries
           -- When running in BC mode, draft reversal entries are not considered
       -- ignore exclude reversal for AP.6647974/6614418
           AND NOT EXISTS (SELECT /*+ no_unnest */  1
                             FROM xla_distribution_links xdl4
                                , xla_ae_headers xah4
                            WHERE xdl4.ref_ae_header_id = xdl.ae_header_id
                              AND xdl4.application_id   = xdl.application_id
                              AND xdl4.temp_line_num    = xdl.temp_line_num * -1
                              AND xah4.application_id   = xdl4.application_id
                              AND xah4.ae_header_id     = xdl4.ae_header_id
                  AND xah4.application_id <> 200
                  AND xdl4.application_id <> 200
                              AND (xah4.accounting_entry_status_code = 'F' OR
                                   (xah4.accounting_entry_status_code = 'D' AND
                                    p_accounting_mode = 'D' AND
                                    p_bc_mode = 'NONE')))
           AND    xdl.application_id       = xalg.bflow_application_id
           --
--         AND    xgl.ledger_id          = xalg.ledger_id
--         AND    xlr.ledger_id          = xgl.ledger_id
           AND    xte.application_id     = xalg.bflow_application_id
           AND    xte.entity_code        = xalg.bflow_entity_code
           AND    xte.ledger_id          = p_ledger_id
--         AND    xte.ledger_id          = DECODE(xla_accounting_cache_pkg.GetValueChar('VALUATION_METHOD_FLAG'),
--                                                        'N', xlr.primary_ledger_id,
--                                                        DECODE(xlr.ledger_category_code
--                                                              ,'ALC', xlr.primary_ledger_id
--                                                              ,DECODE(NVL(xlo.capture_event_flag,'N'),'N',xlr.primary_ledger_id
--                                                              ,xlr.ledger_id)))  -- 5204178 requires secondary ledger event
--         AND    xlo.ledger_id (+)      = xgl.ledger_id
--         AND    xlo.application_id (+) = g_application_id
           --
           AND    NVL(xte.source_id_int_1,-99)   = NVL(xalg.bflow_source_id_num_1,-99)
           AND    NVL(xte.source_id_int_2,-99)   = NVL(xalg.bflow_source_id_num_2,-99)
           AND    NVL(xte.source_id_int_3,-99)   = NVL(xalg.bflow_source_id_num_3,-99)
           AND    NVL(xte.source_id_int_4,-99)   = NVL(xalg.bflow_source_id_num_4,-99)
           AND    NVL(xte.source_id_char_1,' ') = NVL(xalg.bflow_source_id_char_1,' ')
           AND    NVL(xte.source_id_char_2,' ') = NVL(xalg.bflow_source_id_char_2,' ')
           AND    NVL(xte.source_id_char_3,' ') = NVL(xalg.bflow_source_id_char_3,' ')
           AND    NVL(xte.source_id_char_4,' ') = NVL(xalg.bflow_source_id_char_4,' ')
           --
           AND    xah.application_id              = xte.application_id
           AND    xah.ledger_id                   = xalg.ledger_id
           AND    xah.entity_id                   = xte.entity_id
           AND    xah.balance_type_code           = xalg.balance_type_code
           --
           AND    xdl.event_id                    = xah.event_id
           --
           AND    xah.accounting_entry_status_code  IN ('F', DECODE(p_bc_mode,'NONE',p_accounting_mode,'F'))
           AND    xalg.reversal_code = C_DUMMY_PRIOR
          ) gt
   WHERE   gt.line_rank = 1;
   --------------------------------------------------------------------------------

   CURSOR c_bflow_valid_lines IS
   SELECT ae_header_id,
          event_id,
          ledger_id,
          balance_type_code,
          temp_line_num
     FROM xla_ae_lines_gt
    WHERE reversal_code = C_DUMMY_PRIOR
      AND bflow_prior_entry_status_code IS NOT NULL AND bflow_prior_entry_status_code <> 'X';  -- 5132302  if applied to amt is null
      --AND (bflow_prior_entry_status_code IN ('F', DECODE(p_accounting_mode, 'D', 'D', 'F')));

   l_array_line_num                       xla_cmp_source_pkg.t_array_Num;


   CURSOR c_bflow_err_lines IS
   SELECT /*+ index(xte xla_transaction_entities_n1) */ xal.ae_header_id
         ,xal.temp_line_num
         ,xal.event_id
         ,xal.ledger_id
         ,xal.bflow_prior_entry_status_code
         ,xal.balance_type_code
         ,xal.entity_id
         ,fav.application_name
         ,'N'
         ,gl.ledger_category_code
         ,glp.start_date
         ,xte.entity_id xte_entity_id
         ,xte.entity_code
     FROM xla_ae_lines_gt xal
         ,fnd_application_vl fav
         ,gl_ledgers gl
         ,gl_period_statuses glp
         ,xla_transaction_entities_upg xte
    WHERE ((reversal_code = C_DUMMY_PRIOR
            AND NVL(bflow_prior_entry_status_code,'X') = 'X')  -- 5132302
           OR   reversal_code = C_MPA_PRIOR_ENTRY)      -- 4655713b
      AND fav.application_id(+)  = xal.bflow_application_id
      AND xal.ledger_id      = gl.ledger_id
      AND glp.period_name    = gl.first_ledger_period_name
      AND glp.ledger_id      = gl.ledger_id
      AND glp.application_id = 101
      AND NVL(xte.source_id_int_1(+),-99)   = NVL(xal.bflow_source_id_num_1,-99)
      AND NVL(xte.source_id_int_2(+),-99)   = NVL(xal.bflow_source_id_num_2,-99)
      AND NVL(xte.source_id_int_3(+),-99)   = NVL(xal.bflow_source_id_num_3,-99)
      AND NVL(xte.source_id_int_4(+),-99)   = NVL(xal.bflow_source_id_num_4,-99)
      AND NVL(xte.source_id_char_1(+),' ')  = NVL(xal.bflow_source_id_char_1,' ')
      AND NVL(xte.source_id_char_2(+),' ')  = NVL(xal.bflow_source_id_char_2,' ')
      AND NVL(xte.source_id_char_3(+),' ')  = NVL(xal.bflow_source_id_char_3,' ')
      AND NVL(xte.source_id_char_4(+),' ')  = NVL(xal.bflow_source_id_char_4,' ')
      AND xte.ledger_id (+)     = p_ledger_id
      AND xte.application_id (+)= xal.bflow_application_id
      AND xte.entity_code (+)   = xal.bflow_entity_code;

   l_log_module         VARCHAR2(240);
   l_array_ae_header_id                   xla_cmp_source_pkg.t_array_Num;
   l_array_event_id                       xla_cmp_source_pkg.t_array_Num;
   l_array_ledger_id                      xla_cmp_source_pkg.t_array_Num;
   l_array_bflow_prior_status             xla_cmp_source_pkg.t_array_VL30;
   l_array_balance_type_code              xla_cmp_source_pkg.t_array_VL30;
   l_array_entity_id                      xla_cmp_source_pkg.t_array_Num;
   l_array_app_name                       xla_cmp_source_pkg.t_array_VL240;
   l_array_hist_bflow_err                 xla_cmp_source_pkg.t_array_Num;

-- 4655713b MPA and Accrual Reversal
l_array_mpa_segment1                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment2                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment3                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment4                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment5                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment6                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment7                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment8                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment9                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment10                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment11                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment12                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment13                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment14                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment15                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment16                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment17                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment18                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment19                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment20                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment21                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment22                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment23                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment24                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment25                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment26                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment27                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment28                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment29                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment30                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_ccid                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_mpa_ccid_status_code             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_description                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V4000L;
l_array_mpa_currency_code                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V15L;
l_array_mpa_currency_code_pe             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V15L;  -- 5132302
l_array_mpa_curr_conv_rate               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_mpa_curr_conv_type               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_curr_conv_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_mpa_currency_mau                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_mpa_party_type_code              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L;
l_array_mpa_party_id                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_mpa_party_site_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_mpa_encum_type_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Int;
l_array_mpa_acct_cr_ratio                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_mpa_acct_dr_ratio                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_mpa_ledger_id                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_mpa_ref_ae_header_id             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_mpa_temp_line_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_mpa_ae_header_id                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_mpa_header_num                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_acc_rev_flag                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L;  -- join conditions
--Added for 9352035
l_DERIVED_EXCH_RATE						 XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;

-- Historic upgrade
l_array_ledger_category                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_period_start_date                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_bflow_historic                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_primary_start_date                     DATE;
l_hist_count                             NUMBER :=0;

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.BusinessFlowPriorEntries';
   END IF;
--
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'BEGIN of BusinessFlowPriorEntries'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'p_accounting_mode = '||p_accounting_mode
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'p_bc_mode = '||p_bc_mode
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'method = '||xla_accounting_cache_pkg.GetValueChar('VALUATION_METHOD_FLAG')
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'g_mpa_accrual_exists = '||xla_accounting_pkg.g_mpa_accrual_exists
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
           (p_msg      => 'g_num_bflow_prior_entries = '||g_num_bflow_prior_entries
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;


   IF (g_num_bflow_prior_entries > 0) THEN

     --
     -- Update DUMMY_BFPE rows based on upstream journal lines in XLA_AE_LINES
     --

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN

       FOR c IN c_bflow_ae_lines LOOP
            trace
               (p_msg      => 'ae_header='||c.temp_ref_ae_header_id||
                              ' ae_line='||c.ref_ae_line_num
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
       END LOOP;

       FOR l IN (SELECT * FROM xla_ae_lines_gt WHERE reversal_code = C_DUMMY_PRIOR) LOOP
         trace(p_msg      => 'event_id='||l.event_id||
                             ' ae_header_id='||l.ae_header_id
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);
         trace(p_msg    => ' business_class_code='||l.business_class_code||
                           ' bflow_application_id='||l.bflow_application_id||
                           ' ledger_id='||l.ledger_id||
                           ' bflow_entity_code='||l.bflow_entity_code||
                           ' balance_type_code='||l.balance_type_code||
                           ' bflow_applied_to_amt='||l.bflow_applied_to_amount||  -- 5132302
                           ' currency_code='||l.currency_code||                   -- 5132302
                           ' source_distribution_type='||l.source_distribution_type||
                           ' bflow_distribution_type='||l.bflow_distribution_type
              ,p_level  => C_LEVEL_STATEMENT
              ,p_module => l_log_module);
         trace (p_msg   => ' bflow_dist_id_num_1='||l.bflow_dist_id_num_1||
                           ' bflow_dist_id_num_2='||l.bflow_dist_id_num_2||
                           ' bflow_dist_id_num_3='||l.bflow_dist_id_num_3||
                           ' bflow_dist_id_num_4='||l.bflow_dist_id_num_4||
                           ' bflow_dist_id_num_5='||l.bflow_dist_id_num_5||
                           ' bflow_dist_id_char_1='||l.bflow_dist_id_char_1||
                           ' bflow_dist_id_char_2='||l.bflow_dist_id_char_2||
                           ' bflow_dist_id_char_3='||l.bflow_dist_id_char_3||
                           ' bflow_dist_id_char_4='||l.bflow_dist_id_char_4||
                           ' bflow_dist_id_char_5='||l.bflow_dist_id_char_5||
               ' override_acctd_amt_flag='||l.override_acctd_amt_flag
              ,p_level  => C_LEVEL_STATEMENT
              ,p_module => l_log_module);
         trace
           (p_msg       => ' bflow_source_id_num_1='||l.bflow_source_id_num_1||
                           ' bflow_source_id_num_2='||l.bflow_source_id_num_2||
                           ' bflow_source_id_num_3='||l.bflow_source_id_num_3||
                           ' bflow_source_id_num_4='||l.bflow_source_id_num_4||
                           ' bflow_source_id_char_1='||l.bflow_source_id_char_1||
                           ' bflow_source_id_char_2='||l.bflow_source_id_char_2||
                           ' bflow_source_id_char_3='||l.bflow_source_id_char_3||
                           ' bflow_source_id_char_4='||l.bflow_source_id_char_4
              ,p_level  => C_LEVEL_STATEMENT
              ,p_module => l_log_module);
       END LOOP;
     END IF;

     ----------------------------------------------------------------
     --  5357406 - prior entry performance fix
     OPEN c_bflow_ae_lines;

     LOOP FETCH c_bflow_ae_lines BULK COLLECT INTO
        l_array_row_id
       ,l_array_ccid
       ,l_array_description
       ,l_array_currency_code
       ,l_array_curr_conversion_rate
       ,l_array_curr_conversion_type
       ,l_array_curr_conversion_date
       ,l_array_currency_mau
       ,l_array_unrounded_entered_cr
       ,l_array_unrounded_entered_dr
       ,l_array_party_type_code
       ,l_array_party_id
       ,l_array_party_site_id
       ,l_array_encumbrance_type_id
       ,l_array_ccid_status_code
       ,l_array_ref_event_id
       ,l_array_temp_ref_ae_header_id
       ,l_array_ref_ae_line_num
       ,l_array_ref_temp_line_num
       ,l_array_bflow_pe_status_code
       ,l_array_pe_entity_id
	   ,l_DERIVED_EXCH_RATE --Added for 9352035
     LIMIT C_BULK_LIMIT;

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
           (p_module => l_log_module
           ,p_msg => 'Count of prior entry =' || l_array_row_id.COUNT
           ,p_level => C_LEVEL_STATEMENT
           );
     END IF;

     IF l_array_row_id.COUNT = 0 THEN
          EXIT;
     END IF;

     FORALL i IN 1..l_array_row_id.LAST
          UPDATE xla_ae_lines_gt
          SET  code_combination_id = l_array_ccid (i)
              ,description         = l_array_description (i)
              ,temp_currency_code  = l_array_currency_code (i)     -- upstream currency code
              ,currency_conversion_rate = l_array_curr_conversion_rate (i)
              ,currency_conversion_type = l_array_curr_conversion_type (i)
              ,currency_conversion_date = TRUNC(l_array_curr_conversion_date (i))
              ,entered_currency_mau     = l_array_currency_mau (i)
              ,unrounded_entered_cr     = l_array_unrounded_entered_cr (i)
              ,unrounded_entered_dr     = l_array_unrounded_entered_dr (i)
              ,party_type_code          = l_array_party_type_code (i)
              ,party_id                 = l_array_party_id (i)
              ,party_site_id            = l_array_party_site_id (i)
              ,encumbrance_type_id      = l_array_encumbrance_type_id (i)
              ,code_combination_status_code = l_array_ccid_status_code (i)
              ,ref_event_id             = l_array_ref_event_id (i)
              ,temp_ref_ae_header_id    = l_array_temp_ref_ae_header_id (i)
              ,ref_ae_line_num          = l_array_ref_ae_line_num (i)
              ,ref_temp_line_num        = l_array_ref_temp_line_num (i)
              ,bflow_prior_entry_status_code = l_array_bflow_pe_status_code (i)
              ,applied_to_entity_id     = l_array_pe_entity_id (i)
			  ,DERIVED_EXCH_RATE      = l_DERIVED_EXCH_RATE(i) --Added for 9352035
          WHERE rowid = l_array_row_id (i);
     END LOOP;
     CLOSE c_bflow_ae_lines;
     ----------------------------------------------------------------

     ----------------------------------------------------------------
     /*  performance bug 5357406
     UPDATE xla_ae_lines_gt xalg
      SET (code_combination_id
          ,description
          ,temp_currency_code       -- upstream currency code
          ,currency_conversion_rate
          ,currency_conversion_type
          ,currency_conversion_date
          ,entered_currency_mau      -- 4482069
          ,unrounded_entered_cr      -- 4482069
          ,unrounded_entered_dr      -- 4482069
          ,party_type_code
          ,party_id
          ,party_site_id
          ,encumbrance_type_id
          ,code_combination_status_code
          ,ref_event_id
          ,temp_ref_ae_header_id
          ,ref_ae_line_num
          ,ref_temp_line_num
          ,bflow_prior_entry_status_code
          ,applied_to_entity_id
         ) =
        (SELECT MIN(NVL(xal3.merge_code_combination_id,xal3.code_combination_id))     -- 4967526
               ,MIN(DECODE(xalg.inherit_desc_flag, 'Y', xal3.description, xalg.description))
               ,MIN(xal3.currency_code)
               ,MIN(DECODE(xal3.currency_code
                      ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                      ,NULL
                      ,xal3.currency_conversion_rate))
               ,MIN(DECODE(xal3.currency_code
                      ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                      ,NULL
                      ,xal3.currency_conversion_type))
               ,MIN(DECODE(xal3.currency_code
                      ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                      ,NULL
                      ,xal3.currency_conversion_date))
               ---------------------------------------------------------------------------
               -- 4482069 error XLA_AP_INVALID_AMT_BASE
               -- Occurs when upstream is invalid so c_bflow_valid_lines
               -- is not found hence entered amounts will not calc.
               -- Upstream invalid need not prevent this value to be assigned.
               ---------------------------------------------------------------------------
               ,MIN(xla_accounting_cache_pkg.GetCurrencyMau(xal3.currency_code))
               ---------------------------------------------------------------------------
               -- 4482069 based on calculate_acctd_amts_flag and transaction currency
               -- Note: In theory, when calculate_acctd_amts_flag is 'No', entered and
               --       accounted amt should be the same (therefore we need not recalc
               --       accounted amt.) But just in case, perform the following copy to
               --       make sure they will be the same.
               ---------------------------------------------------------------------------
               ,MIN(DECODE(calculate_acctd_amts_flag
                      ,'N', DECODE(xalg.currency_code
                                 ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                                 ,NVL(xalg.unrounded_accounted_cr,xalg.unrounded_entered_cr)
                                 ,xalg.unrounded_entered_cr)
                     ,xalg.unrounded_entered_cr)  )
               ---------------------------------------------------------------------------
               -- 4482069 based on calculate_acctd_amts_flag and transaction currency
               ---------------------------------------------------------------------------
               ,MIN(DECODE(calculate_acctd_amts_flag
                     ,'N', DECODE(xalg.currency_code
                                 ,xla_accounting_cache_pkg.GetValueChar('XLA_CURRENCY_CODE',xalg.ledger_id)
                                 ,NVL(xalg.unrounded_accounted_dr,xalg.unrounded_entered_dr)
                                 ,xalg.unrounded_entered_dr)
                     ,xalg.unrounded_entered_dr))
              ,MIN(xal3.party_type_code)
              ,MIN(NVL(xal3.merge_party_id,xal3.party_id))             -- 4967526
              ,MIN(NVL(xal3.merge_party_site_id,xal3.party_site_id))   -- 4967526
              ,MIN(xal3.encumbrance_type_id)
              ,C_CREATED
              ,MIN(xdl3.event_id)
              ,MIN(xdl3.ae_header_id)
              ,MIN(xal3.ae_line_num)
              ,MIN(xdl3.temp_line_num)
            --,MIN(xah3.accounting_entry_status_code)
              ,MIN(DECODE(xalg.currency_code,xal3.currency_code,xah3.accounting_entry_status_code,                            -- 5132302
                                             DECODE(xalg.bflow_applied_to_amount, NULL, 'X', xah3.accounting_entry_status_code))) -- 5132302
              ,MIN(xah3.entity_id)
          FROM xla_ae_lines xal3
             , xla_ae_headers xah3
             , xla_distribution_links xdl3
         WHERE xah3.application_id               = xdl3.application_id
           AND xah3.ae_header_id                 = xdl3.ae_header_id
           AND xal3.application_id               = xdl3.application_id
           AND xal3.ae_header_id                 = xdl3.ae_header_id
           AND xal3.ae_line_num                  = xdl3.ae_line_num
           AND xal3.business_class_code          = xalg.business_class_code -- 4336173
           AND xdl3.source_distribution_type     = xalg.bflow_distribution_type
           AND NVL(xdl3.source_distribution_id_num_1,C_NUM)   = NVL(xalg.bflow_dist_id_num_1,C_NUM)
           AND NVL(xdl3.source_distribution_id_num_2,C_NUM)   = NVL(xalg.bflow_dist_id_num_2,C_NUM)
           AND NVL(xdl3.source_distribution_id_num_3,C_NUM)   = NVL(xalg.bflow_dist_id_num_3,C_NUM)
           AND NVL(xdl3.source_distribution_id_num_4,C_NUM)   = NVL(xalg.bflow_dist_id_num_4,C_NUM)
           AND NVL(xdl3.source_distribution_id_num_5,C_NUM)   = NVL(xalg.bflow_dist_id_num_5,C_NUM)
           AND NVL(xdl3.source_distribution_id_char_1,C_CHAR) = NVL(xalg.bflow_dist_id_char_1,C_CHAR)
           AND NVL(xdl3.source_distribution_id_char_2,C_CHAR) = NVL(xalg.bflow_dist_id_char_2,C_CHAR)
           AND NVL(xdl3.source_distribution_id_char_3,C_CHAR) = NVL(xalg.bflow_dist_id_char_3,C_CHAR)
           AND NVL(xdl3.source_distribution_id_char_4,C_CHAR) = NVL(xalg.bflow_dist_id_char_4,C_CHAR)
           AND NVL(xdl3.source_distribution_id_char_5,C_CHAR) = NVL(xalg.bflow_dist_id_char_5,C_CHAR)
           AND xah3.parent_ae_header_id IS NULL -- 4655713b  MPA/Accrual Reversal lines cannot be used as prior entries
           -- exclude reversed entries
           AND NOT EXISTS (SELECT 1
                             FROM xla_distribution_links xdl4
                                , xla_ae_headers xah4
                            WHERE xdl4.ref_ae_header_id = xdl3.ae_header_id
                              AND xdl4.temp_line_num    = xdl3.temp_line_num * -1
                              AND xah4.application_id   = xdl4.application_id
                              AND xah4.ae_header_id     = xdl4.ae_header_id
                              AND (xah4.accounting_entry_status_code = 'F' OR
                                   (xah4.accounting_entry_status_code = 'D' AND
                                    p_accounting_mode = 'D' AND
                                    p_bc_mode = 'NONE')))
           AND xdl3.application_id       = xalg.bflow_application_id
           AND xdl3.ae_header_id =
        (SELECT MAX(xdl.ae_header_id)
          FROM xla_transaction_entities xte
             , xla_ae_headers           xah
             , xla_distribution_links   xdl
             , xla_ae_lines             xal
             , xla_ledger_relationships_v  xlr   -- 4478604
             , xla_gl_ledgers_v            xgl   -- 4478604
             , xla_ledger_options   xlo  -- 5204178
         WHERE xgl.ledger_id            = xalg.ledger_id -- 4478604
           AND xlr.ledger_id            = xgl.ledger_id -- 4478604
           AND xte.application_id       = xalg.bflow_application_id
           AND xte.entity_code          = xalg.bflow_entity_code
           AND xte.ledger_id            = DECODE(xla_accounting_cache_pkg.GetValueChar('VALUATION_METHOD_FLAG'),
                                                  'N', xlr.primary_ledger_id,
                                                  DECODE(xlr.ledger_category_code
                                                        ,'ALC', xlr.primary_ledger_id
                                                        ,DECODE(NVL(xlo.capture_event_flag,'N'),'N',xlr.primary_ledger_id
                                                        ,xlr.ledger_id)))  -- 5204178 requires secondary ledger event
            AND  xlo.ledger_id (+)      = xgl.ledger_id
            AND  xlo.application_id (+) = g_application_id
            --
            AND NVL(xte.source_id_int_1,C_NUM)   = NVL(xalg.bflow_source_id_num_1,C_NUM)
            AND NVL(xte.source_id_int_2,C_NUM)   = NVL(xalg.bflow_source_id_num_2,C_NUM)
            AND NVL(xte.source_id_int_3,C_NUM)   = NVL(xalg.bflow_source_id_num_3,C_NUM)
            AND NVL(xte.source_id_int_4,C_NUM)   = NVL(xalg.bflow_source_id_num_4,C_NUM)
            AND NVL(xte.source_id_char_1,C_CHAR) = NVL(xalg.bflow_source_id_char_1,C_CHAR)
            AND NVL(xte.source_id_char_2,C_CHAR) = NVL(xalg.bflow_source_id_char_2,C_CHAR)
            AND NVL(xte.source_id_char_3,C_CHAR) = NVL(xalg.bflow_source_id_char_3,C_CHAR)
            AND NVL(xte.source_id_char_4,C_CHAR) = NVL(xalg.bflow_source_id_char_4,C_CHAR)
            --
            AND xah.application_id               = xte.application_id
            AND xah.ledger_id                    = xalg.ledger_id
            AND xah.entity_id                    = xte.entity_id
            AND xah.balance_type_code            = xalg.balance_type_code
            --
            AND xdl.application_id               = xah.application_id
            AND xdl.event_id                     = xah.event_id
            AND xdl.ae_header_id                 = xah.ae_header_id
            AND xdl.source_distribution_type     = xalg.bflow_distribution_type
            AND NVL(xdl.source_distribution_id_num_1,C_NUM)   = NVL(xalg.bflow_dist_id_num_1,C_NUM)
            AND NVL(xdl.source_distribution_id_num_2,C_NUM)   = NVL(xalg.bflow_dist_id_num_2,C_NUM)
            AND NVL(xdl.source_distribution_id_num_3,C_NUM)   = NVL(xalg.bflow_dist_id_num_3,C_NUM)
            AND NVL(xdl.source_distribution_id_num_4,C_NUM)   = NVL(xalg.bflow_dist_id_num_4,C_NUM)
            AND NVL(xdl.source_distribution_id_num_5,C_NUM)   = NVL(xalg.bflow_dist_id_num_5,C_NUM)
            AND NVL(xdl.source_distribution_id_char_1,C_CHAR) = NVL(xalg.bflow_dist_id_char_1,C_CHAR)
            AND NVL(xdl.source_distribution_id_char_2,C_CHAR) = NVL(xalg.bflow_dist_id_char_2,C_CHAR)
            AND NVL(xdl.source_distribution_id_char_3,C_CHAR) = NVL(xalg.bflow_dist_id_char_3,C_CHAR)
            AND NVL(xdl.source_distribution_id_char_4,C_CHAR) = NVL(xalg.bflow_dist_id_char_4,C_CHAR)
            AND NVL(xdl.source_distribution_id_char_5,C_CHAR) = NVL(xalg.bflow_dist_id_char_5,C_CHAR)
            --
            AND xal.business_class_code           = xalg.business_class_code -- 4336173
            AND xal.application_id                = xdl.application_id
            AND xal.ae_header_id                  = xdl.ae_header_id
            AND xal.ae_line_num                   = xdl.ae_line_num
            -- bug 4946123 - limit the status of the prior entry
            -- Final entries are always considered
            -- If running in BC mode, draft is not considered
            -- Otherwise, draft is considered only if running in draft mode
            AND xah.accounting_entry_status_code  IN ('F', DECODE(p_bc_mode,'NONE',p_accounting_mode,'F'))
            -- exclude reversed entries
            -- When running in BC mode, draft reversal entries are not considered
            AND NOT EXISTS (SELECT 1
                              FROM xla_distribution_links xdl2
                                 , xla_ae_headers xah2
                             WHERE xdl2.ref_ae_header_id = xdl.ae_header_id
                               AND xdl2.temp_line_num    = xdl.temp_line_num * -1
                               AND xah2.application_id   = xdl2.application_id
                               AND xah2.ae_header_id     = xdl2.ae_header_id
                               AND (xah2.accounting_entry_status_code = 'F' OR
                                    (xah2.accounting_entry_status_code = 'D' AND
                                     p_accounting_mode = 'D' AND
                                     p_bc_mode = 'NONE')))
            ))
      WHERE xalg.reversal_code = C_DUMMY_PRIOR;
      */

      -------------------------------------------------------------------------
      -- Update the ref_ae_header_id of the line where the prior entry is found
      -------------------------------------------------------------------------
      OPEN c_bflow_valid_lines;
      FETCH c_bflow_valid_lines BULK COLLECT INTO  l_array_ae_header_id
                                                  ,l_array_event_id
                                                  ,l_array_ledger_id
                                                  ,l_array_balance_type_code
                                                  ,l_array_line_num;
      CLOSE c_bflow_valid_lines;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
           (p_msg      => '# bflow valid lines = '||l_array_balance_type_code.COUNT
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
      END IF;

      IF (l_array_balance_type_code.COUNT > 0) THEN
        FORALL i IN 1..l_array_balance_type_code.COUNT
           UPDATE /*+ index(xalg xla_ae_lines_gt_n2) */  xla_ae_lines_gt xalg   -- 6990256
              SET ref_ae_header_id  = temp_ref_ae_header_id,
                  currency_code     = temp_currency_code,
                  reversal_code     = null,                -- 5499367
                 (unrounded_entered_cr         -- 5132302
                 ,unrounded_entered_dr         -- 5132302
		 ,analytical_balance_flag
                 ,unrounded_accounted_cr
                 ,unrounded_accounted_dr) =
                 ----------------------------------------------------------------------------------------------------------
                 -- Modified for bug 4482069
                 -- Normally, business flow should be setup between different sides.  So just in case, we first try
                 -- to use the amount from the opposite side.  And if it is null, take amount from same side.
                 --
                 -- Modify for bug 4656703
                 -- Modify for bug 4873615 - Handle the 'divided by zero' error
                 --
                 -- Modify for bug 5132302 - calculate accounted amt from applied_to_amt if currencies are different
                 ----------------------------------------------------------------------------------------------------------
                 (SELECT  DECODE(xalg.currency_code,xalg.temp_currency_code, xalg.unrounded_entered_cr,
                                      DECODE(xalg.unrounded_entered_cr,NULL,NULL,NVL(xalg.bflow_applied_to_amount,xalg.unrounded_entered_cr)))
                         ,DECODE(xalg.currency_code,xalg.temp_currency_code, xalg.unrounded_entered_dr,
                                      DECODE(xalg.unrounded_entered_dr,NULL,NULL,NVL(xalg.bflow_applied_to_amount,xalg.unrounded_entered_dr)))
                         ,DECODE (xal.analytical_balance_flag,'P','P'
                                       ,'Y','P',null) analytical_balance_flag
			 ,DECODE(xalg.override_acctd_amt_flag,'Y'
                     ,xalg.unrounded_accounted_cr,
                                (DECODE (xal.unrounded_accounted_dr,NULL
                                ,CASE WHEN xal.unrounded_entered_cr <> 0
                                      THEN DECODE(xalg.currency_code,xalg.temp_currency_code,
                                           (xal.unrounded_accounted_cr/xal.unrounded_entered_cr)*xalg.unrounded_entered_cr,
                                           (xal.unrounded_accounted_cr/xal.unrounded_entered_cr)* DECODE(xalg.unrounded_entered_cr,NULL,NULL,
                                                                                 NVL(xalg.bflow_applied_to_amount,xalg.unrounded_entered_cr)))
                                     --Changed for bug 9352035
									 -- ELSE xalg.unrounded_entered_cr END
                                      ELSE xalg.unrounded_entered_cr * nvl(xalg.DERIVED_EXCH_RATE,1) END
                                ,CASE WHEN xal.unrounded_entered_dr <> 0
                                      THEN DECODE(xalg.currency_code,xalg.temp_currency_code,
                                           (xal.unrounded_accounted_dr/xal.unrounded_entered_dr)*xalg.unrounded_entered_cr,
                                           (xal.unrounded_accounted_dr/xal.unrounded_entered_dr)* DECODE(xalg.unrounded_entered_cr,NULL,NULL,
                                                                                 NVL(xalg.bflow_applied_to_amount,xalg.unrounded_entered_cr)))
                                      --Changed for bug 9352035
									  --ELSE xalg.unrounded_entered_cr END))
                                      ELSE xalg.unrounded_entered_cr * nvl(xalg.DERIVED_EXCH_RATE,1) END))
                                 )
                         ,DECODE(xalg.override_acctd_amt_flag,'Y'
                     ,xalg.unrounded_accounted_dr,
                                (DECODE (xal.unrounded_accounted_cr,NULL
                                ,CASE WHEN xal.unrounded_entered_dr <> 0
                                      THEN DECODE(xalg.currency_code,xalg.temp_currency_code,
                                           (xal.unrounded_accounted_dr/xal.unrounded_entered_dr)*xalg.unrounded_entered_dr,
                                           (xal.unrounded_accounted_dr/xal.unrounded_entered_dr)* DECODE(xalg.unrounded_entered_dr,NULL,NULL,
                                                                                 NVL(xalg.bflow_applied_to_amount,xalg.unrounded_entered_dr)))
                                      --Changed for bug 9352035
									  --ELSE xalg.unrounded_entered_dr END
									  ELSE xalg.unrounded_entered_dr * nvl(xalg.DERIVED_EXCH_RATE,1) END
                                ,CASE WHEN xal.unrounded_entered_cr <> 0
                                      THEN DECODE(xalg.currency_code,xalg.temp_currency_code,
                                           (xal.unrounded_accounted_cr/xal.unrounded_entered_cr)*xalg.unrounded_entered_dr,
                                           (xal.unrounded_accounted_cr/xal.unrounded_entered_cr)* DECODE(xalg.unrounded_entered_dr,NULL,NULL,
                                                                                 NVL(xalg.bflow_applied_to_amount,xalg.unrounded_entered_dr)))
                                      --Changed for bug 9352035
									  --ELSE xalg.unrounded_entered_dr END))
									  ELSE xalg.unrounded_entered_dr * nvl(xalg.DERIVED_EXCH_RATE,1) END))
                                 )

                     FROM xla_ae_lines xal
                    WHERE xal.application_id              = xalg.bflow_application_id
                      AND xal.ae_header_id                = xalg.temp_ref_ae_header_id
                      AND xal.ae_line_num                 = xalg.ref_ae_line_num),
                  entered_currency_mau = xla_accounting_cache_pkg.GetCurrencyMau(temp_currency_code),
                  (segment1,  segment2,  segment3,  segment4,  segment5,  segment6,  segment7,  segment8,  segment9,  segment10
                  ,segment11, segment12, segment13, segment14, segment15, segment16, segment17, segment18, segment19, segment20
                  ,segment21, segment22, segment23, segment24, segment25, segment26, segment27, segment28, segment29, segment30) =
                  (SELECT gcc.segment1,  gcc.segment2,  gcc.segment3,  gcc.segment4,  gcc.segment5
                         ,gcc.segment6,  gcc.segment7,  gcc.segment8,  gcc.segment9,  gcc.segment10
                         ,gcc.segment11, gcc.segment12, gcc.segment13, gcc.segment14, gcc.segment15
                         ,gcc.segment16, gcc.segment17, gcc.segment18, gcc.segment19, gcc.segment20
                         ,gcc.segment21, gcc.segment22, gcc.segment23, gcc.segment24, gcc.segment25
                         ,gcc.segment26, gcc.segment27, gcc.segment28, gcc.segment29, gcc.segment30
                     FROM gl_code_combinations gcc
                    WHERE gcc.code_combination_id = xalg.code_combination_id),
                         (anc_id_1,  anc_id_2,  anc_id_3,  anc_id_4,  anc_id_5
                         ,anc_id_6,  anc_id_7,  anc_id_8,  anc_id_9,  anc_id_10
                         ,anc_id_11, anc_id_12, anc_id_13, anc_id_14, anc_id_15
                         ,anc_id_16, anc_id_17, anc_id_18, anc_id_19, anc_id_20
                         ,anc_id_21, anc_id_22, anc_id_23, anc_id_24, anc_id_25
                         ,anc_id_26, anc_id_27, anc_id_28, anc_id_29, anc_id_30
                         ,anc_id_31, anc_id_32, anc_id_33, anc_id_34, anc_id_35
                         ,anc_id_36, anc_id_37, anc_id_38, anc_id_39, anc_id_40
                         ,anc_id_41, anc_id_42, anc_id_43, anc_id_44, anc_id_45
                         ,anc_id_46, anc_id_47, anc_id_48, anc_id_49, anc_id_50
                         ,anc_id_51, anc_id_52, anc_id_53, anc_id_54, anc_id_55
                         ,anc_id_56, anc_id_57, anc_id_58, anc_id_59, anc_id_60
                         ,anc_id_61, anc_id_62, anc_id_63, anc_id_64, anc_id_65
                         ,anc_id_66, anc_id_67, anc_id_68, anc_id_69, anc_id_70
                         ,anc_id_71, anc_id_72, anc_id_73, anc_id_74, anc_id_75
                         ,anc_id_76, anc_id_77, anc_id_78, anc_id_79, anc_id_80
                         ,anc_id_81, anc_id_82, anc_id_83, anc_id_84, anc_id_85
                         ,anc_id_86, anc_id_87, anc_id_88, anc_id_89, anc_id_90
                         ,anc_id_91, anc_id_92, anc_id_93, anc_id_94, anc_id_95
                         ,anc_id_96, anc_id_97, anc_id_98, anc_id_99, anc_id_100) =
                 (SELECT
                          MAX(DECODE(rank,1,anc_id))   ,MAX(DECODE(rank,2,anc_id))
                         ,MAX(DECODE(rank,3,anc_id))   ,MAX(DECODE(rank,4,anc_id))
                         ,MAX(DECODE(rank,5,anc_id))   ,MAX(DECODE(rank,6,anc_id))
                         ,MAX(DECODE(rank,7,anc_id))   ,MAX(DECODE(rank,8,anc_id))
                         ,MAX(DECODE(rank,9,anc_id))   ,MAX(DECODE(rank,10,anc_id))
                         ,MAX(DECODE(rank,11,anc_id))  ,MAX(DECODE(rank,12,anc_id))
                         ,MAX(DECODE(rank,13,anc_id))  ,MAX(DECODE(rank,14,anc_id))
                         ,MAX(DECODE(rank,15,anc_id))  ,MAX(DECODE(rank,16,anc_id))
                         ,MAX(DECODE(rank,17,anc_id))  ,MAX(DECODE(rank,18,anc_id))
                         ,MAX(DECODE(rank,19,anc_id))  ,MAX(DECODE(rank,20,anc_id))
                         ,MAX(DECODE(rank,21,anc_id))  ,MAX(DECODE(rank,22,anc_id))
                         ,MAX(DECODE(rank,23,anc_id))  ,MAX(DECODE(rank,24,anc_id))
                         ,MAX(DECODE(rank,25,anc_id))  ,MAX(DECODE(rank,26,anc_id))
                         ,MAX(DECODE(rank,27,anc_id))  ,MAX(DECODE(rank,28,anc_id))
                         ,MAX(DECODE(rank,29,anc_id))  ,MAX(DECODE(rank,30,anc_id))
                         ,MAX(DECODE(rank,31,anc_id))  ,MAX(DECODE(rank,32,anc_id))
                         ,MAX(DECODE(rank,33,anc_id))  ,MAX(DECODE(rank,34,anc_id))
                         ,MAX(DECODE(rank,35,anc_id))  ,MAX(DECODE(rank,36,anc_id))
                         ,MAX(DECODE(rank,37,anc_id))  ,MAX(DECODE(rank,38,anc_id))
                         ,MAX(DECODE(rank,39,anc_id))  ,MAX(DECODE(rank,40,anc_id))
                         ,MAX(DECODE(rank,41,anc_id))  ,MAX(DECODE(rank,42,anc_id))
                         ,MAX(DECODE(rank,43,anc_id))  ,MAX(DECODE(rank,44,anc_id))
                         ,MAX(DECODE(rank,45,anc_id))  ,MAX(DECODE(rank,46,anc_id))
                         ,MAX(DECODE(rank,47,anc_id))  ,MAX(DECODE(rank,48,anc_id))
                         ,MAX(DECODE(rank,49,anc_id))  ,MAX(DECODE(rank,50,anc_id))
                         ,MAX(DECODE(rank,51,anc_id))  ,MAX(DECODE(rank,52,anc_id))
                         ,MAX(DECODE(rank,53,anc_id))  ,MAX(DECODE(rank,54,anc_id))
                         ,MAX(DECODE(rank,55,anc_id))  ,MAX(DECODE(rank,56,anc_id))
                         ,MAX(DECODE(rank,57,anc_id))  ,MAX(DECODE(rank,58,anc_id))
                         ,MAX(DECODE(rank,59,anc_id))  ,MAX(DECODE(rank,60,anc_id))
                         ,MAX(DECODE(rank,61,anc_id))  ,MAX(DECODE(rank,62,anc_id))
                         ,MAX(DECODE(rank,63,anc_id))  ,MAX(DECODE(rank,64,anc_id))
                         ,MAX(DECODE(rank,65,anc_id))  ,MAX(DECODE(rank,66,anc_id))
                         ,MAX(DECODE(rank,67,anc_id))  ,MAX(DECODE(rank,68,anc_id))
                         ,MAX(DECODE(rank,69,anc_id))  ,MAX(DECODE(rank,70,anc_id))
                         ,MAX(DECODE(rank,71,anc_id))  ,MAX(DECODE(rank,72,anc_id))
                         ,MAX(DECODE(rank,73,anc_id))  ,MAX(DECODE(rank,74,anc_id))
                         ,MAX(DECODE(rank,75,anc_id))  ,MAX(DECODE(rank,76,anc_id))
                         ,MAX(DECODE(rank,77,anc_id))  ,MAX(DECODE(rank,78,anc_id))
                         ,MAX(DECODE(rank,79,anc_id))  ,MAX(DECODE(rank,80,anc_id))
                         ,MAX(DECODE(rank,81,anc_id))  ,MAX(DECODE(rank,82,anc_id))
                         ,MAX(DECODE(rank,83,anc_id))  ,MAX(DECODE(rank,84,anc_id))
                         ,MAX(DECODE(rank,85,anc_id))  ,MAX(DECODE(rank,86,anc_id))
                         ,MAX(DECODE(rank,87,anc_id))  ,MAX(DECODE(rank,88,anc_id))
                         ,MAX(DECODE(rank,89,anc_id))  ,MAX(DECODE(rank,90,anc_id))
                         ,MAX(DECODE(rank,91,anc_id))  ,MAX(DECODE(rank,92,anc_id))
                         ,MAX(DECODE(rank,93,anc_id))  ,MAX(DECODE(rank,94,anc_id))
                         ,MAX(DECODE(rank,95,anc_id))  ,MAX(DECODE(rank,96,anc_id))
                         ,MAX(DECODE(rank,97,anc_id))  ,MAX(DECODE(rank,98,anc_id))
                         ,MAX(DECODE(rank,99,anc_id))  ,MAX(DECODE(rank,100,anc_id))
                    FROM (SELECT ae_header_id
                                ,ae_line_num
                                ,analytical_criterion_code      || '(]' ||
                                 analytical_criterion_type_code || '(]' ||
                                 amb_context_code               || '(]' ||
                                 ac1                            || '(]' ||
                                 ac2                            || '(]' ||
                                 ac3                            || '(]' ||
                                 ac4                            || '(]' ||
                                 ac5           anc_id
                                ,RANK() OVER (
                                  PARTITION BY ae_header_id, ae_line_num
                                      ORDER BY analytical_criterion_code
                                              ,analytical_criterion_type_code
                                              ,amb_context_code
                                              ,ac1
                                              ,ac2
                                              ,ac3
                                              ,ac4
                                              ,ac5) rank
             FROM xla_ae_line_acs) aed
            WHERE aed.ae_header_id        = xalg.temp_ref_ae_header_id
              AND aed.ae_line_num         = xalg.ref_ae_line_num)
            WHERE balance_type_code = l_array_balance_type_code(i)
              AND ae_header_id      = l_array_ae_header_id(i)
              AND event_id          = l_array_event_id(i)
              AND ledger_id         = l_array_ledger_id(i)
              AND temp_line_num     = l_array_line_num(i);
      END IF;


      -------------------------------------------------------------------------------------------------------------------------
      -- 4655713b Update MPA and Accrual Reversal lines with Prior Entry
      -------------------------------------------------------------------------------------------------------------------------
   IF xla_accounting_pkg.g_mpa_accrual_exists = 'Y' THEN                                                                -- 5666366
      SELECT /*+ Leading (xal1,xah1,xal2) index(xah1 XLA_AE_HEADERS_GT_U1) index(xal2 XLA_AE_LINES_GT_N2) no_expand */  -- 5666366
             xal2.segment1,  xal2.segment2,  xal2.segment3,  xal2.segment4,  xal2.segment5
            ,xal2.segment6,  xal2.segment7,  xal2.segment8,  xal2.segment9,  xal2.segment10
            ,xal2.segment11, xal2.segment12, xal2.segment13, xal2.segment14, xal2.segment15
            ,xal2.segment16, xal2.segment17, xal2.segment18, xal2.segment19, xal2.segment20
            ,xal2.segment21, xal2.segment22, xal2.segment23, xal2.segment24, xal2.segment25
            ,xal2.segment26, xal2.segment27, xal2.segment28, xal2.segment29, xal2.segment30
            ,xal2.code_combination_id
            ,xal2.code_combination_status_code
            ,DECODE(NVL(xal1.inherit_desc_flag,'N'), 'Y', xal2.description, xal1.description)
            ,xal2.currency_code   -- upstream
            ,xal1.currency_code   -- downstream  5132302
            ,xal2.currency_conversion_rate
            ,xal2.currency_conversion_type
            ,xal2.currency_conversion_date
            ,xal2.entered_currency_mau
            ,xal2.party_type_code
            ,xal2.party_id
            ,xal2.party_site_id
            ,xal2.encumbrance_type_id
            -- CALCULATE_ACCTD_AMTS_FLAG is ignored for Prior Entry (see bug 4482069 for details). Same applies to MPA lines.
            ,DECODE (xal3.unrounded_accounted_dr,NULL
                    ,CASE WHEN xal3.unrounded_entered_cr <> 0
                          THEN xal3.unrounded_accounted_cr/xal3.unrounded_entered_cr
                          ELSE 1 END
                    ,CASE WHEN xal3.unrounded_entered_dr <> 0
                          THEN xal3.unrounded_accounted_dr/xal3.unrounded_entered_dr
                          ELSE 1 END)
            ,DECODE (xal3.unrounded_accounted_cr,NULL
                    ,CASE WHEN xal3.unrounded_entered_dr <> 0
                          THEN xal3.unrounded_accounted_dr/xal3.unrounded_entered_dr
                          ELSE 1 END
                    ,CASE WHEN xal3.unrounded_entered_cr <> 0
                          THEN xal3.unrounded_accounted_cr/xal3.unrounded_entered_cr
                          ELSE 1 END)
            -- join conditions
            ,xal1.ledger_id
            ,xal1.ref_ae_header_id
            ,xal1.temp_line_num
            ,xal1.ae_header_id
            ,xal1.header_num
            ,DECODE(xah1.parent_ae_line_num,NULL,'Y','N')  -- accrual_reversal_flag
      BULK COLLECT INTO
             l_array_mpa_segment1 ,l_array_mpa_segment2 ,l_array_mpa_segment3 ,l_array_mpa_segment4 ,l_array_mpa_segment5
            ,l_array_mpa_segment6 ,l_array_mpa_segment7 ,l_array_mpa_segment8 ,l_array_mpa_segment9 ,l_array_mpa_segment10
            ,l_array_mpa_segment11 ,l_array_mpa_segment12 ,l_array_mpa_segment13 ,l_array_mpa_segment14 ,l_array_mpa_segment15
            ,l_array_mpa_segment16 ,l_array_mpa_segment17 ,l_array_mpa_segment18 ,l_array_mpa_segment19 ,l_array_mpa_segment20
            ,l_array_mpa_segment21 ,l_array_mpa_segment22 ,l_array_mpa_segment23 ,l_array_mpa_segment24 ,l_array_mpa_segment25
            ,l_array_mpa_segment26 ,l_array_mpa_segment27 ,l_array_mpa_segment28 ,l_array_mpa_segment29 ,l_array_mpa_segment30
            ,l_array_mpa_ccid
            ,l_array_mpa_ccid_status_code
            ,l_array_mpa_description
            ,l_array_mpa_currency_code
            ,l_array_mpa_currency_code_pe  -- 5132302
            ,l_array_mpa_curr_conv_rate
            ,l_array_mpa_curr_conv_type
            ,l_array_mpa_curr_conv_date
            ,l_array_mpa_currency_mau
            ,l_array_mpa_party_type_code
            ,l_array_mpa_party_id
            ,l_array_mpa_party_site_id
            ,l_array_mpa_encum_type_id
            ,l_array_mpa_acct_cr_ratio
            ,l_array_mpa_acct_dr_ratio
            -- join conditions
            ,l_array_mpa_ledger_id
            ,l_array_mpa_ref_ae_header_id
            ,l_array_mpa_temp_line_num
            ,l_array_mpa_ae_header_id
            ,l_array_mpa_header_num
            ,l_array_acc_rev_flag
      FROM  xla_ae_lines_gt   xal2   -- original downstream line
           ,xla_ae_headers_gt xah1   -- original downstream header
           ,xla_ae_lines_gt   xal1   -- recognition lines
           ,xla_ae_lines      xal3   -- upstream line
      WHERE xal2.source_distribution_type                  = xal1.source_distribution_type
      AND   NVL(xal2.source_distribution_id_num_1,C_NUM)   = NVL(xal1.source_distribution_id_num_1,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_2,C_NUM)   = NVL(xal1.source_distribution_id_num_2,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_3,C_NUM)   = NVL(xal1.source_distribution_id_num_3,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_4,C_NUM)   = NVL(xal1.source_distribution_id_num_4,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_5,C_NUM)   = NVL(xal1.source_distribution_id_num_5,C_NUM)
      AND   NVL(xal2.source_distribution_id_char_1,C_CHAR) = NVL(xal1.source_distribution_id_char_1,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_2,C_CHAR) = NVL(xal1.source_distribution_id_char_2,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_3,C_CHAR) = NVL(xal1.source_distribution_id_char_3,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_4,C_CHAR) = NVL(xal1.source_distribution_id_char_4,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_5,C_CHAR) = NVL(xal1.source_distribution_id_char_5,C_CHAR)
      AND   xal2.event_id                      = xal1.event_id
      AND   xal2.ledger_id                     = xal1.ledger_id
      AND   xal2.balance_type_code             = xal1.balance_type_code
      AND   xal2.event_class_code              = xal1.event_class_code
      AND   xal2.event_type_code               = xal1.event_type_code
      AND   xal2.line_definition_owner_code    = xal1.line_definition_owner_code
      AND   xal2.line_definition_code          = xal1.line_definition_code
      AND   xal2.ACCOUNTING_LINE_TYPE_CODE     = xal1.ACCOUNTING_LINE_TYPE_CODE
      AND   xal2.ACCOUNTING_LINE_CODE          = xal1.ACCOUNTING_LINE_CODE
      --
      AND   xah1.ledger_id        = xal1.ledger_id
      AND   xah1.ae_header_id     = xal1.ae_header_id
      AND   xah1.header_num       = xal1.header_num
      AND ((xah1.parent_ae_line_num IS NOT NULL AND xal2.temp_line_num = xah1.parent_ae_line_num)  -- MPA
      OR    xah1.parent_ae_line_num IS NULL)                                                       -- Accrual Reversal
      --  5666366  -------------------------------------
      AND XAL1.BALANCE_TYPE_CODE  = XAH1.BALANCE_TYPE_CODE
      AND XAL2.AE_HEADER_ID       = XAL1.AE_HEADER_ID
      --------------------------------------------------
      AND   xal2.header_num       = 0
      AND   xal1.reversal_code    = C_MPA_PRIOR_ENTRY
      --
      AND   xal2.bflow_prior_entry_status_code IS NOT NULL AND xal2.bflow_prior_entry_status_code <> 'X'  -- 5132302
      --
      AND   xal3.application_id   = xal2.bflow_application_id
      AND   xal3.ae_header_id     = xal2.temp_ref_ae_header_id
      AND   xal3.ae_line_num      = xal2.ref_ae_line_num;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'BusinessFlowPriorEntries - no of MPA/AccRev rows found = '||l_array_mpa_ledger_id.COUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         FOR i IN 1..l_array_mpa_ledger_id.COUNT LOOP
            trace
            (p_msg      => 'BusinessFlowPriorEntries - mpa lines  ledger='||l_array_mpa_ledger_id(i)||
                           ' ref_header='||l_array_mpa_ref_ae_header_id(i)||
                           ' temp_line='||l_array_mpa_temp_line_num(i)||
                           ' ae_header='||l_array_mpa_ae_header_id(i)||
                           ' header_num='||l_array_mpa_header_num(i)||
                           ' up_curr='||l_array_mpa_currency_code(i)||
                           ' dn_curr='||l_array_mpa_currency_code_pe(i)||
                           ' acc_rev='||l_array_acc_rev_flag(i)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         END LOOP;

         FOR i IN (select * from xla_ae_Lines_gt where reversal_code=C_MPA_PRIOR_ENTRY) LOOP
            trace
            (p_msg      => 'ae_lines_gt  PE dist ledger='||i.ledger_id||' ref_ae_header='||i.ref_ae_header_id||
                           ' temp_line='||i.temp_line_num||' ae_header='||i.ae_header_id||' header_num='||i.header_num||
                           ' bflow='||i.business_method_code||
                           ' curr='||i.currency_code||' applied_amt='||i.bflow_applied_to_amount||  -- 5132302
                           ' conv_type='||i.currency_conversion_type||' conv_rate='||i.currency_conversion_rate||
                           ' udr='||i.unrounded_ACCOUNTED_DR||' ucr='||i.unrounded_ACCOUNTED_CR||' switch='||i.switch_side_flag||
                           ' line='||i.line_definition_code|| ' dist='||i.source_distribution_type||' rev='||i.reversal_code||
                           ' n1='||i.source_distribution_id_num_1|| ' n2='||i.source_distribution_id_num_2||
                           ' n3='||i.source_distribution_id_num_3|| ' n4='||i.source_distribution_id_num_4||
                           ' n5='||i.source_distribution_id_num_5|| ' c1='||i.source_distribution_id_char_1||
                           ' c2='||i.source_distribution_id_char_2|| ' c3='||i.source_distribution_id_char_3||
                           ' c4='||i.source_distribution_id_char_4|| ' c5='||i.source_distribution_id_char_5||
                           ' bal='||i.balance_type_code|| ' side='||i.natural_side_code||
                           ' rev='||i.reversal_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         END LOOP;

         FOR i IN (select * from xla_ae_Lines_gt where reversal_code=C_MPA_PRIOR_ENTRY) LOOP
             trace
            (p_msg      => '                seg s1='||i.segment1||' s2='||i.segment2|| ' s3='||i.segment3||' s4='||i.segment4||
                                       ' s5='||i.segment5||' s6='||i.segment6|| ' s7='||i.segment7||' s8='||i.segment8||
                                       ' s9='||i.segment9||' s10='||i.segment10|| ' s11='||i.segment11||' s12='||i.segment12||
                                       ' s13='||i.segment13||' s14='||i.segment14|| ' s15='||i.segment15||' s16='||i.segment16||
                                       ' s17='||i.segment17||' s18='||i.segment18|| ' s19='||i.segment19||' s20='||i.segment20||
                                       ' s21='||i.segment21||' s22='||i.segment22|| ' s23='||i.segment23||' s24='||i.segment24||
                                       ' s25='||i.segment25||' s26='||i.segment26|| ' s27='||i.segment27||' s28='||i.segment28||
                                       ' s29='||i.segment29||' s30='||i.segment30||' ccid='||i.code_combination_id
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         END LOOP;

      END IF;

      ---------------------------------------------------------------------------------------------------------------
      -- Updates only the Accrual-Reversal or MPA-Accrual line which is a PRIOR_ENTRY.
      -- NOTE: for Accrual-Reversal, one line may be Prior Entry and the rest may not, so update only Prior Entry line.
      ---------------------------------------------------------------------------------------------------------------
      FORALL i in 1..l_array_mpa_ledger_id.COUNT
  -- added hint for 8920369
         UPDATE /*+ INDEX(xal, XLA_AE_LINES_GT_U1)*/  xla_ae_lines_gt xal
         SET      segment1  = l_array_mpa_segment1(i)
                , segment2  = l_array_mpa_segment2(i)
                , segment3  = l_array_mpa_segment3(i)
                , segment4  = l_array_mpa_segment4(i)
                , segment5  = l_array_mpa_segment5(i)
                , segment6  = l_array_mpa_segment6(i)
                , segment7  = l_array_mpa_segment7(i)
                , segment8  = l_array_mpa_segment8(i)
                , segment9  = l_array_mpa_segment9(i)
                , segment10 = l_array_mpa_segment10(i)
                , segment11 = l_array_mpa_segment11(i)
                , segment12 = l_array_mpa_segment12(i)
                , segment13 = l_array_mpa_segment13(i)
                , segment14 = l_array_mpa_segment14(i)
                , segment15 = l_array_mpa_segment15(i)
                , segment16 = l_array_mpa_segment16(i)
                , segment17 = l_array_mpa_segment17(i)
                , segment18 = l_array_mpa_segment18(i)
                , segment19 = l_array_mpa_segment19(i)
                , segment20 = l_array_mpa_segment20(i)
                , segment21 = l_array_mpa_segment21(i)
                , segment22 = l_array_mpa_segment22(i)
                , segment23 = l_array_mpa_segment23(i)
                , segment24 = l_array_mpa_segment24(i)
                , segment25 = l_array_mpa_segment25(i)
                , segment26 = l_array_mpa_segment26(i)
                , segment27 = l_array_mpa_segment27(i)
                , segment28 = l_array_mpa_segment28(i)
                , segment29 = l_array_mpa_segment29(i)
                , segment30 = l_array_mpa_segment30(i)
                , description              = l_array_mpa_description(i)
                , code_combination_id      = l_array_mpa_ccid(i)
                , code_combination_status_code = DECODE(l_array_mpa_ccid(i),NULL,C_PROCESSING     -- 4655713b used in Create_CCID
                                                                                ,l_array_mpa_ccid_status_code(i))
                , reversal_code            = null
                --
                , currency_code            = l_array_mpa_currency_code(i)
                , currency_conversion_rate = l_array_mpa_curr_conv_rate(i)
                , currency_conversion_type = l_array_mpa_curr_conv_type(i)
                , currency_conversion_date = TRUNC(l_array_mpa_curr_conv_date(i))
                , party_type_code          = l_array_mpa_party_type_code(i)
                , party_id                 = l_array_mpa_party_id(i)
                , party_site_id            = l_array_mpa_party_site_id(i)
                , encumbrance_type_id      = l_array_mpa_encum_type_id(i)
                , unrounded_entered_cr     = DECODE(l_array_mpa_currency_code(i),l_array_mpa_currency_code_pe(i),  -- 5132302
                                                    unrounded_entered_cr,
                                                    DECODE(unrounded_entered_cr,NULL,NULL,NVL(bflow_applied_to_amount,unrounded_entered_cr)))
                , unrounded_entered_dr     = DECODE(l_array_mpa_currency_code(i),l_array_mpa_currency_code_pe(i),  -- 5132302
                                                    unrounded_entered_dr,
                                                    DECODE(unrounded_entered_dr,NULL,NULL,NVL(bflow_applied_to_amount,unrounded_entered_dr)))
                , unrounded_accounted_cr   = DECODE(l_array_mpa_currency_code(i),l_array_mpa_currency_code_pe(i),  -- 5132302
                                                    unrounded_entered_cr*l_array_mpa_acct_cr_ratio(i),
                                                    DECODE(unrounded_entered_cr,NULL,NULL,
                                                           NVL(bflow_applied_to_amount,unrounded_entered_cr))*l_array_mpa_acct_cr_ratio(i))
                , unrounded_accounted_dr   = DECODE(l_array_mpa_currency_code(i),l_array_mpa_currency_code_pe(i),  -- 5132302
                                                    unrounded_entered_dr*l_array_mpa_acct_dr_ratio(i),
                                                    DECODE(unrounded_entered_dr,NULL,NULL,
                                                           NVL(bflow_applied_to_amount,unrounded_entered_dr))*l_array_mpa_acct_dr_ratio(i))
           WHERE xal.ledger_id             = l_array_mpa_ledger_id(i)
           AND   xal.ref_ae_header_id      = l_array_mpa_ref_ae_header_id(i)
           AND   xal.temp_line_num         = l_array_mpa_temp_line_num(i)  -- Acc-Rev or MPA-Accrual line which is a PRIOR_ENTR
           AND   xal.ae_header_id          = l_array_mpa_ae_header_id(i)
           AND   NVL(xal.header_num,0)     = l_array_mpa_header_num(i);


      ---------------------------------------------------------------------------------------------------------------
      -- a) Updates MPA-Recognition lines only (MPA-Accrual and Accrual-Reversal lines are updated above.)
      -- b) Both MPA-Accrual and MPA-Recognition lines need to inherit values from Prior Entry.
      -- c) GetRecognitionEntries sets unrounded_accounted amounts to NULL when CALCULATE_ACCTD_AMTS_FLAG is 'Y'
      --    which is correct for non-bflow MPA.  When it is bflow, flag is ignored.
      --
      -- NOTE: some columns are set to NULL during Business_Flow_Validation
      ---------------------------------------------------------------------------------------------------------------
      FORALL i in 1..l_array_mpa_ledger_id.COUNT
         UPDATE xla_ae_lines_gt xal
         SET      currency_code            = DECODE(l_array_acc_rev_flag(i),'N',l_array_mpa_currency_code(i)
                                                                               ,currency_code)
                , currency_conversion_rate = DECODE(l_array_acc_rev_flag(i),'N',l_array_mpa_curr_conv_rate(i)
                                                                               ,currency_conversion_rate)
                , currency_conversion_type = DECODE(l_array_acc_rev_flag(i),'N',l_array_mpa_curr_conv_type(i)
                                                                               ,currency_conversion_type)
                , currency_conversion_date = DECODE(l_array_acc_rev_flag(i),'N',TRUNC(l_array_mpa_curr_conv_date(i))
                                                                               ,TRUNC(currency_conversion_date))
                , party_type_code          = DECODE(l_array_acc_rev_flag(i),'N',l_array_mpa_party_type_code(i)
                                                                               ,party_type_code)
                , party_id                 = DECODE(l_array_acc_rev_flag(i),'N',l_array_mpa_party_id(i)
                                                                               ,party_id)
                , party_site_id            = DECODE(l_array_acc_rev_flag(i),'N',l_array_mpa_party_site_id(i)
                                                                               ,party_site_id)
         --       , encumbrance_type_id      = DECODE(l_array_acc_rev_flag(i),'N',encumbrance_type_id,l_array_mpa_encum_type_id(i)
         --                                                                      ,encumbrance_type_id)
                , entered_currency_mau     = DECODE(l_array_acc_rev_flag(i),'N',l_array_mpa_currency_mau(i)
                                                                               ,entered_currency_mau)
                , unrounded_entered_cr     = DECODE(l_array_acc_rev_flag(i),'N',DECODE(l_array_mpa_currency_code(i),l_array_mpa_currency_code_pe(i),  -- 5132302
                                                    unrounded_entered_cr,
                                                    DECODE(unrounded_entered_cr,NULL,NULL,NVL(bflow_applied_to_amount,unrounded_entered_cr)))
                                                   ,unrounded_entered_cr)
                , unrounded_entered_dr     = DECODE(l_array_acc_rev_flag(i),'N',DECODE(l_array_mpa_currency_code(i),l_array_mpa_currency_code_pe(i),  -- 5132302
                                                    unrounded_entered_dr,
                                                    DECODE(unrounded_entered_dr,NULL,NULL,NVL(bflow_applied_to_amount,unrounded_entered_dr)))
                                                   ,unrounded_entered_dr)
                , unrounded_accounted_cr   = DECODE(l_array_acc_rev_flag(i),'N',DECODE(l_array_mpa_currency_code(i),l_array_mpa_currency_code_pe(i),  -- 5132302
                                                                                       unrounded_entered_cr*l_array_mpa_acct_cr_ratio(i),
                                                                                       DECODE(unrounded_entered_cr,NULL,NULL,
                                                                                       NVL(bflow_applied_to_amount,unrounded_entered_cr)*l_array_mpa_acct_cr_ratio(i)))
                                                                               ,unrounded_accounted_cr)
                , unrounded_accounted_dr   = DECODE(l_array_acc_rev_flag(i),'N',DECODE(l_array_mpa_currency_code(i),l_array_mpa_currency_code_pe(i),  -- 5132302
                                                                                       unrounded_entered_dr*l_array_mpa_acct_dr_ratio(i),
                                                                                       DECODE(unrounded_entered_dr,NULL,NULL,
                                                                                       NVL(bflow_applied_to_amount,unrounded_entered_dr)*l_array_mpa_acct_dr_ratio(i)))
                                                                               ,unrounded_accounted_dr)
           WHERE xal.ledger_id         = l_array_mpa_ledger_id(i)
           AND   xal.ref_ae_header_id  = l_array_mpa_ref_ae_header_id(i)
           AND   xal.ae_header_id      = l_array_mpa_ae_header_id(i)
           AND   NVL(xal.header_num,0) = l_array_mpa_header_num(i);
   END IF;  -- 5666366  xla_accounting_pkg.g_mpa_accrual_exists = 'Y'
      -------------------------------------------------------------------------------------------------------------------------


      -------------------------------------------------------------------------
      -- Log error messages for the rows still with DUMMY_BFPE
      -------------------------------------------------------------------------

      OPEN c_bflow_err_lines;
      FETCH c_bflow_err_lines BULK COLLECT INTO  l_array_ae_header_id
                                                ,l_array_line_num
                                                ,l_array_event_id
                                                ,l_array_ledger_id
                                                ,l_array_bflow_prior_status
                                                ,l_array_balance_type_code
                                                ,l_array_entity_id
                                                ,l_array_app_name
                                                ,l_array_bflow_historic
                                                ,l_array_ledger_category
                                                ,l_array_period_start_date
                                                ,l_array_pe_entity_id
                                                ,l_array_pe_entity_code;
      CLOSE c_bflow_err_lines;

      IF (C_LEVEL_EVENT >= g_log_level) THEN
         trace
           (p_msg      => '# bflow error lines = '||l_array_balance_type_code.COUNT
           ,p_level    => C_LEVEL_EVENT
           ,p_module   => l_log_module);
      END IF;

      -------------------------------------------------------------------------
      -- Historic Upgrade enhancement
      -------------------------------------------------------------------------

      -- Get the start_date of the Primary ledger
      SELECT glp.start_date
       INTO l_primary_start_date
      FROM  gl_period_statuses glp
           ,gl_ledgers gl
      WHERE glp.period_name = gl.first_ledger_period_name
      AND  glp.ledger_id = gl.ledger_id
      AND  glp.application_id = 101
      AND  gl.ledger_id = p_ledger_id;

       IF (l_array_bflow_prior_status.COUNT > 0) THEN -- prior entry status

        FOR i IN 1..l_array_bflow_prior_status.COUNT LOOP
              IF NVL(l_array_bflow_prior_status(i),'N') = 'X' THEN   -- 5132302

                 xla_accounting_err_pkg.build_message
                     (p_appli_s_name  => 'XLA'
                     ,p_msg_name      => 'XLA_AP_BFLOW_PE_NO_APPLIED_AMT'
                     ,p_entity_id     => l_array_entity_id(i)
                     ,p_event_id      => l_array_event_id(i)
                     ,p_ledger_id     => l_array_ledger_id(i));

              ELSE

               -- If the errored line belongs to primary ledger,
           -- throw the error 'prior entry not found'.

           IF(l_array_ledger_category (i) = 'PRIMARY') THEN
                 XLA_AE_JOURNAL_ENTRY_PKG.g_global_status  :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;

                 IF (C_LEVEL_EVENT >= g_log_level) THEN
                    trace
                       (p_msg      => 'l_array_event_id(i):'||l_array_event_id(i)
                       ,p_level    => C_LEVEL_EVENT
                       ,p_module   => l_log_module);
                    trace
                       (p_msg      => 'l_array_pe_entity_id(i):'||l_array_pe_entity_id(i)
                       ,p_level    => C_LEVEL_EVENT
                       ,p_module   => l_log_module);
                 END IF;

                 IF l_array_pe_entity_id(i) IS NOT NULL THEN
                    xla_accounting_errors_pkg.modify_message
                      (p_application_id => g_application_id
                      ,p_appli_s_name   => 'XLA'
                      ,p_msg_name       => 'XLA_AP_BFLOW_PE_NOT_FOUND'
                      ,p_token_1        => 'APPLICATION_NAME'
                      ,p_value_1        => l_array_app_name(i)
                      ,p_token_2        => 'APPLIED_TO_ENTITY_ID'
                      ,p_value_2        => l_array_pe_entity_id(i)
                      ,p_token_3        => 'APPLIED_TO_ENTITY_CODE'
                      ,p_value_3        => l_array_pe_entity_code(i)
                      ,p_entity_id      => l_array_entity_id(i)
                      ,p_event_id       => l_array_event_id(i)
                      ,p_ledger_id      => l_array_ledger_id(i));
                 ELSE
                    xla_accounting_err_pkg.build_message
                      (p_appli_s_name  => 'XLA'
                      ,p_msg_name      => 'XLA_AP_BFLOW_PE_NOT_FOUND'
                      ,p_token_1       => 'APPLICATION_NAME'
                      ,p_value_1       => l_array_app_name(i)
                      ,p_entity_id     => l_array_entity_id(i)
                      ,p_event_id      => l_array_event_id(i)
                      ,p_ledger_id     => l_array_ledger_id(i));
                 END IF;



               ELSE -- for secondary/alc

           -- If the problematic line belongs to secondary/alc ledger, compare the startdate
           -- of the first open period for that ledger with that of primary ledger. If it is
           -- less than or equal to the start date of primary, throw the error. Else,
           -- assume that historic upgrade process is run, and don't raise any error.
           -- Bug 5339999


        IF (l_array_period_start_date(i) <= l_primary_start_date) then
         XLA_AE_JOURNAL_ENTRY_PKG.g_global_status  :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
                 IF (C_LEVEL_EVENT >= g_log_level) THEN
                    trace
                       (p_msg      => 'l_array_event_id(i):'||l_array_event_id(i)
                       ,p_level    => C_LEVEL_EVENT
                       ,p_module   => l_log_module);
                    trace
                       (p_msg      => 'l_array_pe_entity_id(i):'||l_array_pe_entity_id(i)
                       ,p_level    => C_LEVEL_EVENT
                       ,p_module   => l_log_module);
                 END IF;

                 IF l_array_pe_entity_id(i) IS NOT NULL THEN
                    xla_accounting_errors_pkg.modify_message
                      (p_application_id => g_application_id
                      ,p_appli_s_name   => 'XLA'
                      ,p_msg_name       => 'XLA_AP_BFLOW_PE_NOT_FOUND'
                      ,p_token_1        => 'APPLICATION_NAME'
                      ,p_value_1        => l_array_app_name(i)
                      ,p_token_2        => 'APPLIED_TO_ENTITY_ID'
                      ,p_value_2        => l_array_pe_entity_id(i)
                      ,p_token_3        => 'APPLIED_TO_ENTITY_CODE'
                      ,p_value_3        => l_array_pe_entity_code(i)
                      ,p_entity_id      => l_array_entity_id(i)
                      ,p_event_id       => l_array_event_id(i)
                      ,p_ledger_id      => l_array_ledger_id(i));
                 ELSE
                    xla_accounting_err_pkg.build_message
                      (p_appli_s_name  => 'XLA'
                      ,p_msg_name      => 'XLA_AP_BFLOW_PE_NOT_FOUND'
                      ,p_token_1       => 'APPLICATION_NAME'
                      ,p_value_1       => l_array_app_name(i)
                      ,p_entity_id     => l_array_entity_id(i)
                      ,p_event_id      => l_array_event_id(i)
                      ,p_ledger_id     => l_array_ledger_id(i));
                 END IF;



                ELSE
          l_array_bflow_historic (i) :='Y';  -- This line belongs to historic upgraded data.
          l_array_hist_bflow_err(l_array_event_id(i)) :=1;
          xla_accounting_cache_pkg.g_hist_bflow_error_exists := TRUE;
                END IF;

               END IF;  -- for secondary
              END IF; -- 5132302

        END LOOP;

       -- Print out all the events whose upstream entries are not upgraded in secondary/alc ledgers.
       IF l_array_hist_bflow_err.COUNT>0 THEN
         print_logfile('******************************************************************************');
         print_logfile('The following events do not have historic entries replicated in secondary/alc ledgers');
         print_logfile('Manual gl adjustments in the secondary/alc ledgers needs to be done for these events');
         print_logfile('==============================================================================');
         l_hist_count := l_array_hist_bflow_err.FIRST;
         WHILE (l_hist_count <= l_array_hist_bflow_err.LAST) LOOP
           print_logfile('event_id :'||l_hist_count);
           l_hist_count := l_array_hist_bflow_err.next(l_hist_count);
         END LOOP;
         print_logfile('==============================================================================');
       END IF;




       --
       -- Bug 5339999 Delete the problematic lines from xla_ae_lines_gt.
       --
       FORALL i IN 1..l_array_balance_type_code.COUNT
       DELETE FROM XLA_AE_LINES_GT
       WHERE ae_header_id      = l_array_ae_header_id(i)
       AND event_id            = l_array_event_id(i)
       AND ledger_id           = l_array_ledger_id(i)
       AND 'Y'                 = l_array_bflow_historic (i);

       --
       -- Bug 5339999 Delete the problematic lines from xla_ae_headers_gt.
       --

       FORALL i IN 1..l_array_balance_type_code.COUNT
       DELETE FROM XLA_AE_HEADERS_GT
       WHERE ae_header_id    = l_array_ae_header_id(i)
       AND event_id          = l_array_event_id(i)
       AND ledger_id         = l_array_ledger_id(i)
       AND 'Y'               = l_array_bflow_historic (i);





-------------------------------------------------------------------------
 -- Update JE header status for invalid entries
 -------------------------------------------------------------------------

 FORALL i IN 1..l_array_balance_type_code.COUNT

           UPDATE xla_ae_headers_gt
              SET accounting_entry_status_code = XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID  -- C_INVALID_STATUS
            WHERE balance_type_code = l_array_balance_type_code(i)
            AND ae_header_id        = l_array_ae_header_id(i)
            AND event_id            = l_array_event_id(i)
            AND ledger_id           = l_array_ledger_id(i);


-------------------------------------------------------------------------
 -- Update JE line for invalid entries
 -------------------------------------------------------------------------

        FORALL i IN 1..l_array_balance_type_code.COUNT
           UPDATE /*+ index(xalg xla_ae_lines_gt_n2) */ xla_ae_lines_gt xalg
              SET xalg.code_combination_status_code = C_INVALID
                , xalg.code_combination_id = -1
            WHERE xalg.balance_type_code = l_array_balance_type_code(i)
            AND xalg.ae_header_id        = l_array_ae_header_id(i)
            AND xalg.temp_line_num       = l_array_line_num(i)
            AND xalg.event_id            = l_array_event_id(i)
            AND xalg.ledger_id           = l_array_ledger_id(i);

     END IF;
   END IF;


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace(p_msg      => 'END of BusinessFlowPriorEntries'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

EXCEPTION
   --
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS  THEN
      xla_exceptions_pkg.raise_message
                  (p_location => 'xla_ae_lines_pkg.BusinessFlowPriorEntries');
   --
END BusinessFlowPriorEntries;

/*======================================================================+
|                                                                       |
| Public Procedure- Business Flow Same Entry - 4219869                  |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE BusinessFlowSameEntries IS

   l_log_module         VARCHAR2(240);
   --
   -- Define local variables
   --
   l_err_count INTEGER;
   l_array_ae_header_id                   xla_cmp_source_pkg.t_array_Num;
   l_array_temp_line_num                  xla_cmp_source_pkg.t_array_Num; -- 5443083 l_array_ae_line_num
   l_array_event_id                       xla_cmp_source_pkg.t_array_Num;
   l_array_ledger_id                      xla_cmp_source_pkg.t_array_Num;
   l_array_balance_type_code              xla_cmp_source_pkg.t_array_VL30;
   l_array_entity_id                      xla_cmp_source_pkg.t_array_Num;
   l_array_ref_ae_header_id               xla_cmp_source_pkg.t_array_Num;  -- 5443083
   l_array_header_num                     xla_cmp_source_pkg.t_array_Num;  -- 5443083
   l_array_ledger_category                xla_cmp_source_pkg.t_array_VL30; -- 5443083
   l_array_zero_amount_flag               xla_cmp_source_pkg.t_array_VL1;  -- 5443083
   --
   -- Cursor to return the same entry lines that are not processed
   --
   CURSOR c_bflow_unprocessed_lines IS
     SELECT l.ae_header_id
          , l.temp_line_num           -- 5443083 l.ae_line_num
          , l.event_id
          , l.ledger_id
          , l.balance_type_code
          , h.entity_id
          , l.ref_ae_header_id        -- 5443083
          , l.header_num              -- 5443083
          , xlr.ledger_category_code  -- 5443083
          , DECODE(NVL(l.unrounded_entered_dr,0)
                      ,0, DECODE(NVL(l.unrounded_entered_cr,0)
                                ,0, DECODE(NVL(l.unrounded_accounted_dr,0)
                                          ,0, DECODE(NVL(l.unrounded_accounted_cr,0)
                                                    ,0,'Y'
                                                    ,'N')
                                          ,'N')
                                ,'N')
                      ,'N')           -- 5443083
       FROM xla_ae_lines_gt l
           ,xla_ae_headers_gt h
           ,xla_gl_ledgers_v  xlr
      WHERE (reversal_code = C_DUMMY_SAME
      OR     reversal_code = C_MPA_SAME_ENTRY)  -- 4655713b
      AND   l.ae_header_id      = h.ae_header_id
      AND   l.ledger_id         = h.ledger_id            -- 5443083
      AND   l.balance_type_code = h.balance_type_code    -- 5443083
      AND   l.header_num        = h.header_num           -- 5443083
      AND   l.ledger_id         = xlr.ledger_id          -- 5443083
     ORDER BY l.ae_header_id;

-- 4913967 for performance fix
l_array_same_segment1                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment2                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment3                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment4                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment5                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment6                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment7                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment8                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment9                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment10                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment11                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment12                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment13                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment14                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment15                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment16                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment17                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment18                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment19                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment20                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment21                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment22                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment23                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment24                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment25                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment26                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment27                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment28                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment29                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_segment30                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_same_ccid                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_same_description                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V4000L;
l_array_same_reversal_code                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_join_ledger_id                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_join_ref_ae_header_id             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_join_temp_line_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_join_ae_header_id                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_join_header_num                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions

-- 4655713b MPA and Accrual Reversal
l_array_mpa_segment1                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment2                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment3                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment4                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment5                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment6                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment7                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment8                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment9                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment10                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment11                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment12                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment13                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment14                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment15                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment16                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment17                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment18                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment19                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment20                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment21                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment22                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment23                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment24                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment25                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment26                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment27                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment28                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment29                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_segment30                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_ccid                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_mpa_ccid_status_code             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_mpa_description                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V4000L;
l_array_mpa_ledger_id                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_mpa_ref_ae_header_id             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_mpa_temp_line_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_mpa_ae_header_id                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions
l_array_mpa_header_num                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  -- join conditions

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.BusinessFlowSameEntries';
   END IF;
--
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'BEGIN of BusinessFlowSameEntries'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
       trace
           (p_msg      => 'g_num_bflow_same_entries = '||g_num_bflow_same_entries
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF;


   IF (g_num_bflow_same_entries > 0) THEN
--
      -- Update DUMMY_BFSE rows based on the other line in the same entry
      -- If not exactly one line is found for the same entry, it is an error
      --
      --
      -- Fix bug4384869 - if segment values is null from the same entry, determine
      -- the segment from the ccid of the prior entry

      -----------------------------------------------------------------------------------------------------------
      -- 4913967  Modify for performance
      -----------------------------------------------------------------------------------------------------------
      SELECT      CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment1, C_CHAR, NVL(xal2.segment1,gcc.segment1), xal.segment1))
                       ELSE MIN(DECODE(xal.segment1, C_CHAR, NULL, xal.segment1)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment2, C_CHAR, NVL(xal2.segment2,gcc.segment2), xal.segment2))
                       ELSE MIN(DECODE(xal.segment2, C_CHAR, NULL, xal.segment2)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment3, C_CHAR, NVL(xal2.segment3,gcc.segment3), xal.segment3))
                       ELSE MIN(DECODE(xal.segment3, C_CHAR, NULL, xal.segment3)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment4, C_CHAR, NVL(xal2.segment4,gcc.segment4), xal.segment4))
                       ELSE MIN(DECODE(xal.segment4, C_CHAR, NULL, xal.segment4)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment5, C_CHAR, NVL(xal2.segment5,gcc.segment5), xal.segment5))
                       ELSE MIN(DECODE(xal.segment5, C_CHAR, NULL, xal.segment5)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment6, C_CHAR, NVL(xal2.segment6,gcc.segment6), xal.segment6))
                       ELSE MIN(DECODE(xal.segment6, C_CHAR, NULL, xal.segment6)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment7, C_CHAR, NVL(xal2.segment7,gcc.segment7), xal.segment7))
                       ELSE MIN(DECODE(xal.segment7, C_CHAR, NULL, xal.segment7)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment8, C_CHAR, NVL(xal2.segment8,gcc.segment8), xal.segment8))
                       ELSE MIN(DECODE(xal.segment8, C_CHAR, NULL, xal.segment8)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment9, C_CHAR, NVL(xal2.segment9,gcc.segment9), xal.segment9))
                       ELSE MIN(DECODE(xal.segment9, C_CHAR, NULL, xal.segment9)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment10, C_CHAR, NVL(xal2.segment10,gcc.segment10), xal.segment10))
                       ELSE MIN(DECODE(xal.segment10, C_CHAR, NULL, xal.segment10)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment11, C_CHAR, NVL(xal2.segment11,gcc.segment11), xal.segment11))
                       ELSE MIN(DECODE(xal.segment11, C_CHAR, NULL, xal.segment11)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment12, C_CHAR, NVL(xal2.segment12,gcc.segment12), xal.segment12))
                       ELSE MIN(DECODE(xal.segment12, C_CHAR, NULL, xal.segment12)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment13, C_CHAR, NVL(xal2.segment13,gcc.segment13), xal.segment13))
                       ELSE MIN(DECODE(xal.segment13, C_CHAR, NULL, xal.segment13)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment14, C_CHAR, NVL(xal2.segment14,gcc.segment14), xal.segment14))
                       ELSE MIN(DECODE(xal.segment14, C_CHAR, NULL, xal.segment14)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment15, C_CHAR, NVL(xal2.segment15,gcc.segment15), xal.segment15))
                       ELSE MIN(DECODE(xal.segment15, C_CHAR, NULL, xal.segment15)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment16, C_CHAR, NVL(xal2.segment16,gcc.segment16), xal.segment16))
                       ELSE MIN(DECODE(xal.segment16, C_CHAR, NULL, xal.segment16)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment17, C_CHAR, NVL(xal2.segment17,gcc.segment17), xal.segment17))
                       ELSE MIN(DECODE(xal.segment17, C_CHAR, NULL, xal.segment17)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment18, C_CHAR, NVL(xal2.segment18,gcc.segment18), xal.segment18))
                       ELSE MIN(DECODE(xal.segment18, C_CHAR, NULL, xal.segment18)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment19, C_CHAR, NVL(xal2.segment19,gcc.segment19), xal.segment19))
                       ELSE MIN(DECODE(xal.segment19, C_CHAR, NULL, xal.segment19)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment20, C_CHAR, NVL(xal2.segment20,gcc.segment20), xal.segment20))
                       ELSE MIN(DECODE(xal.segment20, C_CHAR, NULL, xal.segment20)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment21, C_CHAR, NVL(xal2.segment21,gcc.segment21), xal.segment21))
                       ELSE MIN(DECODE(xal.segment21, C_CHAR, NULL, xal.segment21)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment22, C_CHAR, NVL(xal2.segment22,gcc.segment22), xal.segment22))
                       ELSE MIN(DECODE(xal.segment22, C_CHAR, NULL, xal.segment22)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment23, C_CHAR, NVL(xal2.segment23,gcc.segment23), xal.segment23))
                       ELSE MIN(DECODE(xal.segment23, C_CHAR, NULL, xal.segment23)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment24, C_CHAR, NVL(xal2.segment24,gcc.segment24), xal.segment24))
                       ELSE MIN(DECODE(xal.segment24, C_CHAR, NULL, xal.segment24)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment25, C_CHAR, NVL(xal2.segment25,gcc.segment25), xal.segment25))
                       ELSE MIN(DECODE(xal.segment25, C_CHAR, NULL, xal.segment25)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment26, C_CHAR, NVL(xal2.segment26,gcc.segment26), xal.segment26))
                       ELSE MIN(DECODE(xal.segment26, C_CHAR, NULL, xal.segment26)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment27, C_CHAR, NVL(xal2.segment27,gcc.segment27), xal.segment27))
                       ELSE MIN(DECODE(xal.segment27, C_CHAR, NULL, xal.segment27)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment28, C_CHAR, NVL(xal2.segment28,gcc.segment28), xal.segment28))
                       ELSE MIN(DECODE(xal.segment28, C_CHAR, NULL, xal.segment28)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment29, C_CHAR, NVL(xal2.segment29,gcc.segment29), xal.segment29))
                       ELSE MIN(DECODE(xal.segment29, C_CHAR, NULL, xal.segment29)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment30, C_CHAR, NVL(xal2.segment30,gcc.segment30), xal.segment30))
                       ELSE MIN(DECODE(xal.segment30, C_CHAR, NULL, xal.segment30)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.code_combination_id, C_NUM, xal2.code_combination_id, xal.code_combination_id))
                       ELSE -1 END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.inherit_desc_flag, 'Y', xal2.description, xal.description)) ELSE NULL END
                , CASE WHEN count(*) = 1
                       THEN NULL ELSE MIN(xal.reversal_code) END
                -- join conditions
                , CASE WHEN count(*) = 1
                       THEN xal.ledger_id ELSE NULL END
                , CASE WHEN count(*) = 1
                       THEN xal.ref_ae_header_id ELSE NULL END
                , CASE WHEN count(*) = 1
                       THEN xal.temp_line_num ELSE NULL END
                , CASE WHEN count(*) = 1
                       THEN xal.ae_header_id ELSE NULL END
                , CASE WHEN count(*) = 1
                       THEN NVL(xal.header_num,0) ELSE NULL END
      BULK COLLECT INTO
                  l_array_same_segment1
                , l_array_same_segment2
                , l_array_same_segment3
                , l_array_same_segment4
                , l_array_same_segment5
                , l_array_same_segment6
                , l_array_same_segment7
                , l_array_same_segment8
                , l_array_same_segment9
                , l_array_same_segment10
                , l_array_same_segment11
                , l_array_same_segment12
                , l_array_same_segment13
                , l_array_same_segment14
                , l_array_same_segment15
                , l_array_same_segment16
                , l_array_same_segment17
                , l_array_same_segment18
                , l_array_same_segment19
                , l_array_same_segment20
                , l_array_same_segment21
                , l_array_same_segment22
                , l_array_same_segment23
                , l_array_same_segment24
                , l_array_same_segment25
                , l_array_same_segment26
                , l_array_same_segment27
                , l_array_same_segment28
                , l_array_same_segment29
                , l_array_same_segment30
                , l_array_same_ccid
                , l_array_same_description
                , l_array_same_reversal_code
                -- join conditions
                , l_array_join_ledger_id
                , l_array_join_ref_ae_header_id
                , l_array_join_temp_line_num
                , l_array_join_ae_header_id
                , l_array_join_header_num
      FROM  xla_ae_lines_gt          xal2
         ,  xla_ae_lines_gt          xal
         ,  gl_code_combinations     gcc
      WHERE xal2.source_distribution_type                  = xal.source_distribution_type
      AND   NVL(xal2.source_distribution_id_num_1,C_NUM)   = NVL(xal.source_distribution_id_num_1,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_2,C_NUM)   = NVL(xal.source_distribution_id_num_2,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_3,C_NUM)   = NVL(xal.source_distribution_id_num_3,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_4,C_NUM)   = NVL(xal.source_distribution_id_num_4,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_5,C_NUM)   = NVL(xal.source_distribution_id_num_5,C_NUM)
      AND   NVL(xal2.source_distribution_id_char_1,C_CHAR) = NVL(xal.source_distribution_id_char_1,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_2,C_CHAR) = NVL(xal.source_distribution_id_char_2,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_3,C_CHAR) = NVL(xal.source_distribution_id_char_3,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_4,C_CHAR) = NVL(xal.source_distribution_id_char_4,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_5,C_CHAR) = NVL(xal.source_distribution_id_char_5,C_CHAR)
      AND   xal2.event_id                      = xal.event_id
      AND   xal2.ledger_id                     = xal.ledger_id
      AND   xal2.balance_type_code             = xal.balance_type_code
      AND   xal2.event_class_code              = xal.event_class_code
      AND   xal2.event_type_code               = xal.event_type_code
      AND   xal2.line_definition_owner_code    = xal.line_definition_owner_code
      AND   xal2.line_definition_code          = xal.line_definition_code
      AND   xal2.natural_side_code             = DECODE(xal.natural_side_code, 'C', 'D', 'C')
      AND   gcc.code_combination_id(+)         = xal2.code_combination_id -- bug4384869
   -- AND   nvl(xal2.reversal_code, 'A') not in (C_DUMMY_SAME, C_DUMMY_PRIOR)  -- 5001981
      AND   xal.reversal_code = C_DUMMY_SAME
      AND   NVL(xal2.header_num,0) = 0  -- 4655713b  excludes MPA/Accrual Reversal lines,cannot be used for bflow
      GROUP BY xal.ledger_id    -- 5068675
              ,xal.ref_ae_header_id
              ,xal.temp_line_num
              ,xal.ae_header_id
              ,xal.header_num;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Number of events = '||l_array_join_ledger_id.COUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         FOR i IN 1..l_array_join_ledger_id.COUNT LOOP
             trace
            (p_msg      => 'from array    ledger='||l_array_join_ledger_id(i)|| ' ref_ae_header='||l_array_join_ref_ae_header_id(i)||
                           ' temp_line='||l_array_join_temp_line_num(i)|| ' ae_header='||l_array_join_ae_header_id(i)||
                           ' header_num='||l_array_join_header_num(i)||
                           ' s1='||l_array_same_segment1(i)||' s2='||l_array_same_segment2(i)||
                           ' s3='||l_array_same_segment3(i)||' s4='||l_array_same_segment4(i)||
                           ' s5='||l_array_same_segment5(i)||' s6='||l_array_same_segment6(i)||
                           ' s7='||l_array_same_segment7(i)||' s8='||l_array_same_segment8(i)||
                           ' s9='||l_array_same_segment9(i)||' s10='||l_array_same_segment10(i)||
                           ' s11='||l_array_same_segment11(i)||' s12='||l_array_same_segment12(i)||
                           ' s13='||l_array_same_segment13(i)||' s14='||l_array_same_segment14(i)||
                           ' s15='||l_array_same_segment15(i)||' s16='||l_array_same_segment16(i)||
                           ' s17='||l_array_same_segment17(i)||' s18='||l_array_same_segment18(i)||
                           ' s19='||l_array_same_segment19(i)||' s20='||l_array_same_segment20(i)||
                           ' s21='||l_array_same_segment21(i)||' s22='||l_array_same_segment22(i)||
                           ' s23='||l_array_same_segment23(i)||' s24='||l_array_same_segment24(i)||
                           ' s25='||l_array_same_segment25(i)||' s26='||l_array_same_segment26(i)||
                           ' s27='||l_array_same_segment27(i)||' s28='||l_array_same_segment28(i)||
                           ' s29='||l_array_same_segment29(i)||' s30='||l_array_same_segment30(i)||
                           ' ccid='||l_array_same_ccid(i)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         END LOOP;

         FOR i IN (select * from xla_ae_Lines_gt where reversal_code=C_DUMMY_SAME) LOOP
            trace
            (p_msg      => 'ae_lines_gt  SE dist ledger='||i.ledger_id||' ref_ae_header='||i.ref_ae_header_id||
                           ' temp_line='||i.temp_line_num||' ae_header='||i.ae_header_id||' header_num='||i.header_num||
                           ' bflow='||i.business_method_code||
                           ' line='||i.line_definition_code|| ' dist='||i.source_distribution_type||' rev='||i.reversal_code||
                           ' n1='||i.source_distribution_id_num_1|| ' n2='||i.source_distribution_id_num_2||
                           ' n3='||i.source_distribution_id_num_3|| ' n4='||i.source_distribution_id_num_4||
                           ' n5='||i.source_distribution_id_num_5|| ' c1='||i.source_distribution_id_char_1||
                           ' c2='||i.source_distribution_id_char_2|| ' c3='||i.source_distribution_id_char_3||
                           ' c4='||i.source_distribution_id_char_4|| ' c5='||i.source_distribution_id_char_5||
                           ' bal='||i.balance_type_code|| ' side='||i.natural_side_code||
                           ' rev='||i.reversal_code
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         END LOOP;

         FOR i IN (select * from xla_ae_Lines_gt where reversal_code=C_DUMMY_SAME) LOOP
             trace
            (p_msg      => '                seg s1='||i.segment1||' s2='||i.segment2|| ' s3='||i.segment3||' s4='||i.segment4||
                                       ' s5='||i.segment5||' s6='||i.segment6|| ' s7='||i.segment7||' s8='||i.segment8||
                                       ' s9='||i.segment9||' s10='||i.segment10|| ' s11='||i.segment11||' s12='||i.segment12||
                                       ' s13='||i.segment13||' s14='||i.segment14|| ' s15='||i.segment15||' s16='||i.segment16||
                                       ' s17='||i.segment17||' s18='||i.segment18|| ' s19='||i.segment19||' s20='||i.segment20||
                                       ' s21='||i.segment21||' s22='||i.segment22|| ' s23='||i.segment23||' s24='||i.segment24||
                                       ' s25='||i.segment25||' s26='||i.segment26|| ' s27='||i.segment27||' s28='||i.segment28||
                                       ' s29='||i.segment29||' s30='||i.segment30||' ccid='||i.code_combination_id
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         END LOOP;

      END IF;

      FORALL i IN 1..l_array_join_ledger_id.COUNT
         UPDATE /*+ INDEX(xal, XLA_AE_LINES_GT_U1)*/  xla_ae_lines_gt xal
	       -- added hint for 8920369
         SET      segment1  = l_array_same_segment1(i)
                , segment2  = l_array_same_segment2(i)
                , segment3  = l_array_same_segment3(i)
                , segment4  = l_array_same_segment4(i)
                , segment5  = l_array_same_segment5(i)
                , segment6  = l_array_same_segment6(i)
                , segment7  = l_array_same_segment7(i)
                , segment8  = l_array_same_segment8(i)
                , segment9  = l_array_same_segment9(i)
                , segment10 = l_array_same_segment10(i)
                , segment11 = l_array_same_segment11(i)
                , segment12 = l_array_same_segment12(i)
                , segment13 = l_array_same_segment13(i)
                , segment14 = l_array_same_segment14(i)
                , segment15 = l_array_same_segment15(i)
                , segment16 = l_array_same_segment16(i)
                , segment17 = l_array_same_segment17(i)
                , segment18 = l_array_same_segment18(i)
                , segment19 = l_array_same_segment19(i)
                , segment20 = l_array_same_segment20(i)
                , segment21 = l_array_same_segment21(i)
                , segment22 = l_array_same_segment22(i)
                , segment23 = l_array_same_segment23(i)
                , segment24 = l_array_same_segment24(i)
                , segment25 = l_array_same_segment25(i)
                , segment26 = l_array_same_segment26(i)
                , segment27 = l_array_same_segment27(i)
                , segment28 = l_array_same_segment28(i)
                , segment29 = l_array_same_segment29(i)
                , segment30 = l_array_same_segment30(i)
                , code_combination_id  = l_array_same_ccid(i)
                , code_combination_status_code = DECODE(l_array_same_ccid(i),NULL,C_PROCESSING     -- 4655713b used in Create_CCID
                                                                                 ,C_NOT_PROCESSED) -- 4655713  used in Override_CCID
                , description          = l_array_same_description(i)
                , reversal_code        = l_array_same_reversal_code(i)
           WHERE xal.ledger_id         = l_array_join_ledger_id(i)
           AND   xal.ref_ae_header_id  = l_array_join_ref_ae_header_id(i)
           AND   xal.temp_line_num     = l_array_join_temp_line_num(i)
           AND   xal.ae_header_id      = l_array_join_ae_header_id(i)
           AND   NVL(xal.header_num,0) = l_array_join_header_num(i);

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'BusinessFlowSameEntries - no of rows updated = '||SQL%ROWCOUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

      -------------------------------------------------------------------------------------------------------------------------
      -- 4655713b Updates MPA-Accrual (not MPA-Recognition) and Accrual Reversal lines with Same Entry
      -------------------------------------------------------------------------------------------------------------------------
   IF xla_accounting_pkg.g_mpa_accrual_exists = 'Y' THEN                                                                -- 7128871
            SELECT /*+ Leading (xal1,xah1,xal2) index(xah1 XLA_AE_HEADERS_GT_U1) index(xal2 XLA_AE_LINES_GT_N2) no_expand */  -- 7128871
                   xal2.segment1,  xal2.segment2,  xal2.segment3,  xal2.segment4,  xal2.segment5
            ,xal2.segment6,  xal2.segment7,  xal2.segment8,  xal2.segment9,  xal2.segment10
            ,xal2.segment11, xal2.segment12, xal2.segment13, xal2.segment14, xal2.segment15
            ,xal2.segment16, xal2.segment17, xal2.segment18, xal2.segment19, xal2.segment20
            ,xal2.segment21, xal2.segment22, xal2.segment23, xal2.segment24, xal2.segment25
            ,xal2.segment26, xal2.segment27, xal2.segment28, xal2.segment29, xal2.segment30
            ,xal2.code_combination_id
            ,xal2.code_combination_status_code
            ,DECODE(NVL(xal1.inherit_desc_flag,'N'), 'Y', xal2.description, xal1.description)
            -- join conditions
            ,xal1.ledger_id
            ,xal1.ref_ae_header_id
            ,xal1.temp_line_num
            ,xal1.ae_header_id
            ,xal1.header_num
      BULK COLLECT INTO
             l_array_mpa_segment1 ,l_array_mpa_segment2 ,l_array_mpa_segment3 ,l_array_mpa_segment4 ,l_array_mpa_segment5
            ,l_array_mpa_segment6 ,l_array_mpa_segment7 ,l_array_mpa_segment8 ,l_array_mpa_segment9 ,l_array_mpa_segment10
            ,l_array_mpa_segment11 ,l_array_mpa_segment12 ,l_array_mpa_segment13 ,l_array_mpa_segment14 ,l_array_mpa_segment15
            ,l_array_mpa_segment16 ,l_array_mpa_segment17 ,l_array_mpa_segment18 ,l_array_mpa_segment19 ,l_array_mpa_segment20
            ,l_array_mpa_segment21 ,l_array_mpa_segment22 ,l_array_mpa_segment23 ,l_array_mpa_segment24 ,l_array_mpa_segment25
            ,l_array_mpa_segment26 ,l_array_mpa_segment27 ,l_array_mpa_segment28 ,l_array_mpa_segment29 ,l_array_mpa_segment30
            ,l_array_mpa_ccid
            ,l_array_mpa_ccid_status_code
            ,l_array_mpa_description
            -- join conditions
            ,l_array_mpa_ledger_id
            ,l_array_mpa_ref_ae_header_id
            ,l_array_mpa_temp_line_num
            ,l_array_mpa_ae_header_id
            ,l_array_mpa_header_num
      FROM  xla_ae_lines_gt   xal2   -- Original line
           ,xla_ae_headers_gt xah1
           ,xla_ae_lines_gt   xal1   -- MPA line
      WHERE xal2.source_distribution_type                  = xal1.source_distribution_type
      AND   NVL(xal2.source_distribution_id_num_1,C_NUM)   = NVL(xal1.source_distribution_id_num_1,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_2,C_NUM)   = NVL(xal1.source_distribution_id_num_2,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_3,C_NUM)   = NVL(xal1.source_distribution_id_num_3,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_4,C_NUM)   = NVL(xal1.source_distribution_id_num_4,C_NUM)
      AND   NVL(xal2.source_distribution_id_num_5,C_NUM)   = NVL(xal1.source_distribution_id_num_5,C_NUM)
      AND   NVL(xal2.source_distribution_id_char_1,C_CHAR) = NVL(xal1.source_distribution_id_char_1,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_2,C_CHAR) = NVL(xal1.source_distribution_id_char_2,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_3,C_CHAR) = NVL(xal1.source_distribution_id_char_3,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_4,C_CHAR) = NVL(xal1.source_distribution_id_char_4,C_CHAR)
      AND   NVL(xal2.source_distribution_id_char_5,C_CHAR) = NVL(xal1.source_distribution_id_char_5,C_CHAR)
      AND   xal2.event_id                      = xal1.event_id
      AND   xal2.ledger_id                     = xal1.ledger_id
      AND   xal2.balance_type_code             = xal1.balance_type_code
      AND   xal2.event_class_code              = xal1.event_class_code
      AND   xal2.event_type_code               = xal1.event_type_code
      AND   xal2.line_definition_owner_code    = xal1.line_definition_owner_code
      AND   xal2.line_definition_code          = xal1.line_definition_code
      AND   xal2.ACCOUNTING_LINE_TYPE_CODE     = xal1.ACCOUNTING_LINE_TYPE_CODE
      AND   xal2.ACCOUNTING_LINE_CODE          = xal1.ACCOUNTING_LINE_CODE
      --
      AND   xah1.ledger_id        = xal1.ledger_id
      AND   xah1.ae_header_id     = xal1.ae_header_id
      AND   xah1.header_num       = xal1.header_num
      AND ((xah1.parent_ae_line_num IS NOT NULL AND xal2.temp_line_num = xah1.parent_ae_line_num)  -- MPA
      OR    xah1.parent_ae_line_num IS NULL)                                                       -- Accrual Reversal
      --  7128871  -------------------------------------
      AND XAL1.BALANCE_TYPE_CODE  = XAH1.BALANCE_TYPE_CODE
      AND XAL2.AE_HEADER_ID       = XAL1.AE_HEADER_ID
      --------------------------------------------------
      AND   xal2.header_num       = 0
      AND   xal2.reversal_code IS NULL     -- 5443083 found the same entry
      AND   xal1.reversal_code    = C_MPA_SAME_ENTRY;

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'BusinessFlowSameEntries - no of MPA/AccRev rows found = '||l_array_mpa_ledger_id.COUNT
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         FOR i IN 1..l_array_mpa_ledger_id.COUNT LOOP
            trace
            (p_msg      => 'BusinessFlowSameEntries - mpa lines  ledger='||l_array_mpa_ledger_id(i)||
                           ' ref_header='||l_array_mpa_ref_ae_header_id(i)||
                           ' temp_line='||l_array_mpa_temp_line_num(i)||
                           ' ae_header='||l_array_mpa_ae_header_id(i)||
                           ' header_num='||l_array_mpa_header_num(i)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
         END LOOP;
      END IF;

      FORALL i in 1..l_array_mpa_ledger_id.COUNT
              -- added hint for 8920369
         UPDATE /*+ INDEX(xal, XLA_AE_LINES_GT_U1)*/  xla_ae_lines_gt xal
         SET      segment1  = l_array_mpa_segment1(i)
                , segment2  = l_array_mpa_segment2(i)
                , segment3  = l_array_mpa_segment3(i)
                , segment4  = l_array_mpa_segment4(i)
                , segment5  = l_array_mpa_segment5(i)
                , segment6  = l_array_mpa_segment6(i)
                , segment7  = l_array_mpa_segment7(i)
                , segment8  = l_array_mpa_segment8(i)
                , segment9  = l_array_mpa_segment9(i)
                , segment10 = l_array_mpa_segment10(i)
                , segment11 = l_array_mpa_segment11(i)
                , segment12 = l_array_mpa_segment12(i)
                , segment13 = l_array_mpa_segment13(i)
                , segment14 = l_array_mpa_segment14(i)
                , segment15 = l_array_mpa_segment15(i)
                , segment16 = l_array_mpa_segment16(i)
                , segment17 = l_array_mpa_segment17(i)
                , segment18 = l_array_mpa_segment18(i)
                , segment19 = l_array_mpa_segment19(i)
                , segment20 = l_array_mpa_segment20(i)
                , segment21 = l_array_mpa_segment21(i)
                , segment22 = l_array_mpa_segment22(i)
                , segment23 = l_array_mpa_segment23(i)
                , segment24 = l_array_mpa_segment24(i)
                , segment25 = l_array_mpa_segment25(i)
                , segment26 = l_array_mpa_segment26(i)
                , segment27 = l_array_mpa_segment27(i)
                , segment28 = l_array_mpa_segment28(i)
                , segment29 = l_array_mpa_segment29(i)
                , segment30 = l_array_mpa_segment30(i)
                , code_combination_id          = l_array_mpa_ccid(i)
                , code_combination_status_code = l_array_mpa_ccid_status_code(i)  -- 4655713 used in Override_CCID
                , description          = l_array_mpa_description(i)
                , reversal_code        = null
           WHERE xal.ledger_id         = l_array_mpa_ledger_id(i)
           AND   xal.ref_ae_header_id  = l_array_mpa_ref_ae_header_id(i)
           AND   xal.temp_line_num     = l_array_mpa_temp_line_num(i)
           AND   xal.ae_header_id      = l_array_mpa_ae_header_id(i)
           AND   NVL(xal.header_num,0) = l_array_mpa_header_num(i);
      -------------------------------------------------------------------------------------------------------------------------
   END IF;  -- 7128871  xla_accounting_pkg.g_mpa_accrual_exists = 'Y'


     /*-------------------------------------------------------------------------------------------------------------------
     -- Replaced for performance fix above
     ---------------------------------------------------------------------------------------------------------------------
      UPDATE xla_ae_lines_gt xal
      SET (segment1,  segment2,  segment3,  segment4,  segment5,  segment6,  segment7,  segment8,  segment9,  segment10
          ,segment11, segment12, segment13, segment14, segment15, segment16, segment17, segment18, segment19, segment20
          ,segment21, segment22, segment23, segment24, segment25, segment26, segment27, segment28, segment29, segment30
          ,code_combination_id
          ,description
          ,reversal_code) =
          (SELECT CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment1, C_CHAR, NVL(xal2.segment1,gcc.segment1), xal.segment1))
                       ELSE MIN(DECODE(xal.segment1, C_CHAR, NULL, xal.segment1)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment2, C_CHAR, NVL(xal2.segment2,gcc.segment2), xal.segment2))
                       ELSE MIN(DECODE(xal.segment2, C_CHAR, NULL, xal.segment2)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment3, C_CHAR, NVL(xal2.segment3,gcc.segment3), xal.segment3))
                       ELSE MIN(DECODE(xal.segment3, C_CHAR, NULL, xal.segment3)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment4, C_CHAR, NVL(xal2.segment4,gcc.segment4), xal.segment4))
                       ELSE MIN(DECODE(xal.segment4, C_CHAR, NULL, xal.segment4)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment5, C_CHAR, NVL(xal2.segment5,gcc.segment5), xal.segment5))
                       ELSE MIN(DECODE(xal.segment5, C_CHAR, NULL, xal.segment5)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment6, C_CHAR, NVL(xal2.segment6,gcc.segment6), xal.segment6))
                       ELSE MIN(DECODE(xal.segment6, C_CHAR, NULL, xal.segment6)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment7, C_CHAR, NVL(xal2.segment7,gcc.segment7), xal.segment7))
                       ELSE MIN(DECODE(xal.segment7, C_CHAR, NULL, xal.segment7)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment8, C_CHAR, NVL(xal2.segment8,gcc.segment8), xal.segment8))
                       ELSE MIN(DECODE(xal.segment8, C_CHAR, NULL, xal.segment8)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment9, C_CHAR, NVL(xal2.segment9,gcc.segment9), xal.segment9))
                       ELSE MIN(DECODE(xal.segment9, C_CHAR, NULL, xal.segment9)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment10, C_CHAR, NVL(xal2.segment10,gcc.segment10), xal.segment10))
                       ELSE MIN(DECODE(xal.segment10, C_CHAR, NULL, xal.segment10)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment11, C_CHAR, NVL(xal2.segment11,gcc.segment11), xal.segment11))
                       ELSE MIN(DECODE(xal.segment11, C_CHAR, NULL, xal.segment11)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment12, C_CHAR, NVL(xal2.segment12,gcc.segment12), xal.segment12))
                       ELSE MIN(DECODE(xal.segment12, C_CHAR, NULL, xal.segment12)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment13, C_CHAR, NVL(xal2.segment13,gcc.segment13), xal.segment13))
                       ELSE MIN(DECODE(xal.segment13, C_CHAR, NULL, xal.segment13)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment14, C_CHAR, NVL(xal2.segment14,gcc.segment14), xal.segment14))
                       ELSE MIN(DECODE(xal.segment14, C_CHAR, NULL, xal.segment14)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment15, C_CHAR, NVL(xal2.segment15,gcc.segment15), xal.segment15))
                       ELSE MIN(DECODE(xal.segment15, C_CHAR, NULL, xal.segment15)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment16, C_CHAR, NVL(xal2.segment16,gcc.segment16), xal.segment16))
                       ELSE MIN(DECODE(xal.segment16, C_CHAR, NULL, xal.segment16)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment17, C_CHAR, NVL(xal2.segment17,gcc.segment17), xal.segment17))
                       ELSE MIN(DECODE(xal.segment17, C_CHAR, NULL, xal.segment17)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment18, C_CHAR, NVL(xal2.segment18,gcc.segment18), xal.segment18))
                       ELSE MIN(DECODE(xal.segment18, C_CHAR, NULL, xal.segment18)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment19, C_CHAR, NVL(xal2.segment19,gcc.segment19), xal.segment19))
                       ELSE MIN(DECODE(xal.segment19, C_CHAR, NULL, xal.segment19)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment20, C_CHAR, NVL(xal2.segment20,gcc.segment20), xal.segment20))
                       ELSE MIN(DECODE(xal.segment20, C_CHAR, NULL, xal.segment20)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment21, C_CHAR, NVL(xal2.segment21,gcc.segment21), xal.segment21))
                       ELSE MIN(DECODE(xal.segment21, C_CHAR, NULL, xal.segment21)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment22, C_CHAR, NVL(xal2.segment22,gcc.segment22), xal.segment22))
                       ELSE MIN(DECODE(xal.segment22, C_CHAR, NULL, xal.segment22)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment23, C_CHAR, NVL(xal2.segment23,gcc.segment23), xal.segment23))
                       ELSE MIN(DECODE(xal.segment23, C_CHAR, NULL, xal.segment23)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment24, C_CHAR, NVL(xal2.segment24,gcc.segment24), xal.segment24))
                       ELSE MIN(DECODE(xal.segment24, C_CHAR, NULL, xal.segment24)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment25, C_CHAR, NVL(xal2.segment25,gcc.segment25), xal.segment25))
                       ELSE MIN(DECODE(xal.segment25, C_CHAR, NULL, xal.segment25)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment26, C_CHAR, NVL(xal2.segment26,gcc.segment26), xal.segment26))
                       ELSE MIN(DECODE(xal.segment26, C_CHAR, NULL, xal.segment26)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment27, C_CHAR, NVL(xal2.segment27,gcc.segment27), xal.segment27))
                       ELSE MIN(DECODE(xal.segment27, C_CHAR, NULL, xal.segment27)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment28, C_CHAR, NVL(xal2.segment28,gcc.segment28), xal.segment28))
                       ELSE MIN(DECODE(xal.segment28, C_CHAR, NULL, xal.segment28)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment29, C_CHAR, NVL(xal2.segment29,gcc.segment29), xal.segment29))
                       ELSE MIN(DECODE(xal.segment29, C_CHAR, NULL, xal.segment29)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.segment30, C_CHAR, NVL(xal2.segment30,gcc.segment30), xal.segment30))
                       ELSE MIN(DECODE(xal.segment30, C_CHAR, NULL, xal.segment30)) END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.code_combination_id, C_NUM, xal2.code_combination_id, xal.code_combination_id))
                       ELSE -1 END
                , CASE WHEN count(*) = 1
                       THEN MIN(DECODE(xal.inherit_desc_flag, 'Y', xal2.description, xal.description)) ELSE NULL END
                , CASE WHEN count(*) = 1
                       THEN NULL ELSE xal.reversal_code END
           FROM  xla_ae_lines_gt          xal2
              ,  gl_code_combinations     gcc   -- bug4384869
           WHERE xal2.source_distribution_type      = xal.source_distribution_type
           AND   NVL(xal2.source_distribution_id_num_1,C_NUM)   = NVL(xal.source_distribution_id_num_1,C_NUM)
           AND   NVL(xal2.source_distribution_id_num_2,C_NUM)   = NVL(xal.source_distribution_id_num_2,C_NUM)
           AND   NVL(xal2.source_distribution_id_num_3,C_NUM)   = NVL(xal.source_distribution_id_num_3,C_NUM)
           AND   NVL(xal2.source_distribution_id_num_4,C_NUM)   = NVL(xal.source_distribution_id_num_4,C_NUM)
           AND   NVL(xal2.source_distribution_id_num_5,C_NUM)   = NVL(xal.source_distribution_id_num_5,C_NUM)
           AND   NVL(xal2.source_distribution_id_char_1,C_CHAR) = NVL(xal.source_distribution_id_char_1,C_CHAR)
           AND   NVL(xal2.source_distribution_id_char_2,C_CHAR) = NVL(xal.source_distribution_id_char_2,C_CHAR)
           AND   NVL(xal2.source_distribution_id_char_3,C_CHAR) = NVL(xal.source_distribution_id_char_3,C_CHAR)
           AND   NVL(xal2.source_distribution_id_char_4,C_CHAR) = NVL(xal.source_distribution_id_char_4,C_CHAR)
           AND   NVL(xal2.source_distribution_id_char_5,C_CHAR) = NVL(xal.source_distribution_id_char_5,C_CHAR)
           AND   xal2.event_id                      = xal.event_id
           AND   xal2.ledger_id                     = xal.ledger_id
           AND   xal2.balance_type_code             = xal.balance_type_code
           AND   xal2.event_class_code              = xal.event_class_code
           AND   xal2.event_type_code               = xal.event_type_code
           AND   xal2.line_definition_owner_code    = xal.line_definition_owner_code
           AND   xal2.line_definition_code          = xal.line_definition_code
           AND   xal2.natural_side_code             = DECODE(xal.natural_side_code, 'C', 'D', 'C')
           AND   gcc.code_combination_id(+)         = xal2.code_combination_id -- bug4384869
           AND   nvl(xal2.reversal_code, 'A') not in (C_DUMMY_SAME, C_DUMMY_PRIOR)
           )
      WHERE xal.reversal_code = C_DUMMY_SAME;
     -------------------------------------------------------------------------------------------------------------------*/

      --
      -- Handle the same entry line that are not processed - ERROR
      --
      OPEN c_bflow_unprocessed_lines;
      LOOP FETCH c_bflow_unprocessed_lines BULK COLLECT INTO l_array_ae_header_id,
                                                             l_array_temp_line_num,        -- 5443083 l_array_ae_line_num
                                                             l_array_event_id,
                                                             l_array_ledger_id,
                                                             l_array_balance_type_code,
                                                             l_array_entity_id,
                                                             l_array_ref_ae_header_id,     -- 5443083
                                                             l_array_header_num,           -- 5443083
                                                             l_array_ledger_category,      -- 5443083
                                                             l_array_zero_amount_flag      -- 5443083
                                                             LIMIT C_BULK_LIMIT;

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
            trace
               (p_module => l_log_module
               ,p_msg => 'Count of unprocessed same entry =' || l_array_ae_header_id.COUNT
               ,p_level => C_LEVEL_STATEMENT
               );
         END IF;

         IF l_array_ae_header_id.COUNT = 0 THEN
              EXIT;
         END IF;


         FOR i IN 1..l_array_ae_header_id.COUNT LOOP

             IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                trace
                   (p_module => l_log_module
                   ,p_msg => 'same entry ledger='||l_array_ledger_id(i)||
                             ' category='||l_array_ledger_category(i)||
                             ' ref_ae_header='||l_array_ref_ae_header_id(i)||
                             ' line='||l_array_temp_line_num(i)||
                             ' ae_header='||l_array_ae_header_id(i)||
                             ' header_num='||l_array_header_num(i)||
                             ' zero='||l_array_zero_amount_flag(i)||
                             ' event='||l_array_event_id(i)||
                             ' bal_type='||l_array_balance_type_code(i)
                   ,p_level => C_LEVEL_STATEMENT
                   );
             END IF;

             IF l_array_zero_amount_flag(i) = 'Y' AND l_array_ledger_category(i) IN ('ALC','SECONDARY') THEN  -- 5443083

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                   trace
                      (p_module => l_log_module
                      ,p_msg => 'zero amt same entry ledger='||l_array_ledger_id(i)||
                                ' ref_ae_header='||l_array_ref_ae_header_id(i)||
                                ' temp_line='||l_array_temp_line_num(i)||
                                ' ae_header='||l_array_ae_header_id(i)||
                                ' header_num='||l_array_header_num(i)||
                                ' event='||l_array_event_id(i)
                   ,p_level => C_LEVEL_STATEMENT
                   );
                END IF;

                DELETE xla_ae_lines_gt
                WHERE  ledger_id        = l_array_ledger_id(i)
                AND    ref_ae_header_id = l_array_ref_ae_header_id(i)
                AND    temp_line_num    = l_array_temp_line_num(i)
                AND    ae_header_id     = l_array_ae_header_id(i)
                AND    header_num       = l_array_header_num(i);

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                   trace
                      (p_module => l_log_module
                      ,p_msg => '     zero amt line deleted='||SQL%ROWCOUNT
                      ,p_level => C_LEVEL_STATEMENT
                   );
                END IF;

                DELETE xla_ae_headers_gt hgt
                WHERE  ledger_id         = l_array_ledger_id(i)
                AND    ae_header_id      = l_array_ae_header_id(i)
                AND    balance_type_code = l_array_balance_type_code(i)
                AND    header_num        = l_array_header_num(i)
                AND NOT EXISTS  (SELECT /*+ index(lgt XLA_AE_LINES_GT_N2) */ 1
                                 FROM   xla_ae_lines_gt lgt
                                 WHERE  lgt.ledger_id    = hgt.ledger_id
                                 AND    lgt.ae_header_id = hgt.ae_header_id
                                 AND    lgt.header_num   = hgt.header_num
                                 AND    lgt.balance_type_code = hgt.balance_type_code);

                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                   trace
                      (p_module => l_log_module
                      ,p_msg => '     zero amt header deleted='||SQL%ROWCOUNT
                      ,p_level => C_LEVEL_STATEMENT
                   );
                END IF;

             ELSE
                XLA_AE_JOURNAL_ENTRY_PKG.g_global_status  :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
                xla_accounting_err_pkg.build_message
                         (p_appli_s_name  => 'XLA'
                         ,p_msg_name      => 'XLA_AP_BFLOW_SE_NOT_FOUND'
                         ,p_entity_id     => l_array_entity_id(i)    -- XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                         ,p_event_id      => l_array_event_id(i)     -- XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                         ,p_ledger_id     => l_array_ledger_id(i));  -- XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
             END IF;
         END LOOP;

         --
         -- Update JE lines for those that encountered error
         --
         FORALL i IN 1..l_array_balance_type_code.COUNT
                 UPDATE /*+ INDEX(xla_ae_lines_gt, XLA_AE_LINES_GT_U1)*/  xla_ae_lines_gt
                 SET    description = DECODE(description, C_CHAR, NULL, description)
                      , code_combination_id = DECODE(code_combination_id, C_NUM, -1, code_combination_id)
                      , code_combination_status_code = C_INVALID     -- 4655713
                      , segment1  = DECODE(segment1,   C_CHAR, NULL, segment1)
                      , segment2  = DECODE(segment2,   C_CHAR, NULL, segment2)
                      , segment3  = DECODE(segment3,   C_CHAR, NULL, segment3)
                      , segment4  = DECODE(segment4,   C_CHAR, NULL, segment4)
                      , segment5  = DECODE(segment5,   C_CHAR, NULL, segment5)
                      , segment6  = DECODE(segment6,   C_CHAR, NULL, segment6)
                      , segment7  = DECODE(segment7,   C_CHAR, NULL, segment7)
                      , segment8  = DECODE(segment8,   C_CHAR, NULL, segment8)
                      , segment9  = DECODE(segment9,   C_CHAR, NULL, segment9)
                      , segment10 = DECODE(segment10,  C_CHAR, NULL, segment10)
                      , segment11 = DECODE(segment11,  C_CHAR, NULL, segment11)
                      , segment12 = DECODE(segment12,  C_CHAR, NULL, segment12)
                      , segment13 = DECODE(segment13,  C_CHAR, NULL, segment13)
                      , segment14 = DECODE(segment14,  C_CHAR, NULL, segment14)
                      , segment15 = DECODE(segment15,  C_CHAR, NULL, segment15)
                      , segment16 = DECODE(segment16,  C_CHAR, NULL, segment16)
                      , segment17 = DECODE(segment17,  C_CHAR, NULL, segment17)
                      , segment18 = DECODE(segment18,  C_CHAR, NULL, segment18)
                      , segment19 = DECODE(segment19,  C_CHAR, NULL, segment19)
                      , segment20 = DECODE(segment20,  C_CHAR, NULL, segment20)
                      , segment21 = DECODE(segment21,  C_CHAR, NULL, segment21)
                      , segment22 = DECODE(segment22,  C_CHAR, NULL, segment22)
                      , segment23 = DECODE(segment23,  C_CHAR, NULL, segment23)
                      , segment24 = DECODE(segment24,  C_CHAR, NULL, segment24)
                      , segment25 = DECODE(segment25,  C_CHAR, NULL, segment25)
                      , segment26 = DECODE(segment26,  C_CHAR, NULL, segment26)
                      , segment27 = DECODE(segment27,  C_CHAR, NULL, segment27)
                      , segment28 = DECODE(segment28,  C_CHAR, NULL, segment28)
                      , segment29 = DECODE(segment29,  C_CHAR, NULL, segment29)
                      , segment30 = DECODE(segment30,  C_CHAR, NULL, segment30)
                 WHERE ae_header_id      = l_array_ae_header_id(i)
             --  AND   ae_line_num       = l_array_ae_line_num(i)        -- 5443083
                 AND   temp_line_num     = l_array_temp_line_num(i)      -- 5443083
                 AND   ref_ae_header_id  = l_array_ref_ae_header_id(i)   -- 5443083
                 AND   header_num        = l_array_header_num(i)         -- 5443083
                 AND   event_id          = l_array_event_id(i)
                 AND   ledger_id         = l_array_ledger_id(i)
                 AND   balance_type_code = l_array_balance_type_code(i);

         --
         -- Update JE header status for invalid entries
         --
         FORALL i IN 1..l_array_balance_type_code.COUNT
                 UPDATE xla_ae_headers_gt hgt
                 SET   accounting_entry_status_code = XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID  -- C_INVALID_STATUS
                 WHERE ae_header_id      = l_array_ae_header_id(i)
                 AND   event_id          = l_array_event_id(i)
                 AND   ledger_id         = l_array_ledger_id(i)
                 AND   header_num        = l_array_header_num(i)         -- 5443083
                 AND   balance_type_code = l_array_balance_type_code(i)
                 AND EXISTS  (SELECT /*+ index(lgt XLA_AE_LINES_GT_N2) */ 1  - 5443083
                              FROM   xla_ae_lines_gt lgt
                              WHERE  lgt.ledger_id    = hgt.ledger_id
                              AND    lgt.ae_header_id = hgt.ae_header_id
                              AND    lgt.header_num   = hgt.header_num
                              AND    lgt.balance_type_code = hgt.balance_type_code
                              AND   (lgt.reversal_code = C_DUMMY_SAME
                              OR     lgt.reversal_code = C_MPA_SAME_ENTRY));

      END LOOP;
      CLOSE c_bflow_unprocessed_lines;

   END IF; -- g_num_bflow_same_entries > 0


   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'END of BusinessFlowSameEntries'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

EXCEPTION
--
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS  THEN
      xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_lines_pkg.BusinessFlowSameEntries');
  --
END BusinessFlowSameEntries;

/*======================================================================+
|                                                                       |
| Public Procedure- Validate Business Flow Applied To Links - 4219869   |
|                   (Refer to ValidateLinks for similar logic.)         |
|                                                                       |
+======================================================================*/
PROCEDURE ValidateBFlowLinks IS

   l_log_module         VARCHAR2(240);
   l_source_temp        NUMBER;
   l_dist_temp          NUMBER;
   l_app_name           VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateBFlowLinks';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'BEGIN of ValidateBFlowLinks'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;


 --IF g_rec_lines.array_bflow_application_id(g_LineNumber) IS NOT NULL THEN

      IF g_rec_lines.array_bflow_application_id(g_LineNumber) IS NULL OR   -- log error if application id is null
         g_rec_lines.array_bflow_entity_code(g_LineNumber) IS NULL OR
         g_rec_lines.array_bflow_distribution_type(g_LineNumber) IS NULL OR
        (g_rec_lines.array_bflow_source_id_char_1(g_LineNumber) IS NULL AND
         g_rec_lines.array_bflow_source_id_num_1(g_LineNumber) IS NULL) OR
        (g_rec_lines.array_bflow_dist_id_char_1(g_LineNumber) IS NULL AND
         g_rec_lines.array_bflow_dist_id_num_1(g_LineNumber) IS NULL)  THEN

         XLA_AE_JOURNAL_ENTRY_PKG.g_global_status  :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
         xla_accounting_err_pkg.build_message
               (p_appli_s_name  => 'XLA'
               ,p_msg_name      => 'XLA_AP_BFPE_INVALID_APPLIED_TO'
               ,p_entity_id     => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
               ,p_event_id      => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
               ,p_ledger_id     => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);

      ELSE

         l_app_name := xla_accounting_cache_pkg.GetSessionValueChar('XLA_EVENT_APPL_NAME');

         ---------------------------------------------------------------------
         -- Verify applied-to system transaction ids
         ---------------------------------------------------------------------
         IF g_rec_lines.array_bflow_source_id_char_4(g_LineNumber) IS NULL AND
            g_rec_lines.array_bflow_source_id_num_4(g_LineNumber) IS NULL THEN
            l_source_temp := 0;
         ELSE
           l_source_temp := 1;
         END IF;
         IF g_rec_lines.array_bflow_source_id_char_3(g_LineNumber) IS NOT NULL OR
            g_rec_lines.array_bflow_source_id_num_3(g_LineNumber) IS NOT NULL THEN
            l_source_temp := 2+l_source_temp;
         END IF;
         IF g_rec_lines.array_bflow_source_id_char_2(g_LineNumber) IS NOT NULL OR
            g_rec_lines.array_bflow_source_id_num_2(g_LineNumber) IS NOT NULL THEN
            l_source_temp := 4+l_source_temp;
         END IF;

         IF (g_rec_lines.array_bflow_source_id_char_1(g_LineNumber) IS NULL AND
             g_rec_lines.array_bflow_source_id_num_1(g_LineNumber) IS NULL) OR
             l_source_temp not in (0, 4, 6, 7) THEN

             xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
             xla_accounting_err_pkg.build_message
                                           (p_appli_s_name            => 'XLA'
                                           ,p_msg_name                => 'XLA_AP_BFLOW_NO_SYS_TRX_ID'
                                           ,p_token_1                 => 'LINE_NUMBER'
                                           ,p_value_1                 =>  g_ExtractLine
                                           ,p_token_2                 => 'LINE_TYPE_NAME'
                                           ,p_value_2                 =>  xla_ae_sources_pkg.GetComponentName (
                                                                           g_accounting_line.component_type
                                                                         , g_accounting_line.accounting_line_code
                                                                         , g_accounting_line.accounting_line_type_code
                                                                         , g_accounting_line.accounting_line_appl_id
                                                                         , g_accounting_line.amb_context_code
                                                                         , g_accounting_line.entity_code
                                                                         , g_accounting_line.event_class_code)
                                           ,p_token_3                 => 'OWNER'
                                           ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                           'XLA_OWNER_TYPE'
                                                                          , g_rec_lines.array_accounting_line_type(g_LineNumber))
                                           ,p_token_4                 => 'PRODUCT_NAME'
                                         --,p_value_4                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
                                           ,p_value_4                 => l_app_name
                                           ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                                           ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                                           ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                                           ,p_ae_header_id            => NULL);

            IF (C_LEVEL_ERROR >= g_log_level) THEN
                   trace
                        (p_msg      => 'ERROR: XLA_AP_BFLOW_NO_SYS_TRX_ID'
                        ,p_level    => C_LEVEL_ERROR
                        ,p_module   => l_log_module);
            END IF;

         END IF;  -- g_rec_lines.array_bflow_source_id_char_1(g_LineNumber) IS NULL

         ---------------------------------------------------------------------
         -- Verify applied-to distribution ids
         ---------------------------------------------------------------------
         IF g_rec_lines.array_bflow_dist_id_char_5(g_LineNumber) IS NULL AND
            g_rec_lines.array_bflow_dist_id_num_5(g_LineNumber) IS NULL THEN
            l_dist_temp := 0;
         ELSE
            l_dist_temp := 1;
         END IF;
         IF g_rec_lines.array_bflow_dist_id_char_4(g_LineNumber) IS NOT NULL OR
            g_rec_lines.array_bflow_dist_id_num_4(g_LineNumber) IS NOT NULL THEN
            l_dist_temp := 2+l_dist_temp;
         END IF;
         IF g_rec_lines.array_bflow_dist_id_char_3(g_LineNumber) IS NOT NULL OR
            g_rec_lines.array_bflow_dist_id_num_3(g_LineNumber) IS NOT NULL THEN
            l_dist_temp := 4+l_dist_temp;
         END IF;
         IF g_rec_lines.array_bflow_dist_id_char_2(g_LineNumber) IS NOT NULL OR
            g_rec_lines.array_bflow_dist_id_num_2(g_LineNumber) IS NOT NULL THEN
            l_dist_temp := 8+l_dist_temp;
         END IF;

         IF (g_rec_lines.array_bflow_dist_id_char_1(g_LineNumber) IS NULL AND
             g_rec_lines.array_bflow_dist_id_num_1(g_LineNumber) IS NULL) OR
             l_dist_temp not in (0, 8, 12, 14, 15) THEN

             xla_ae_journal_entry_pkg.g_global_status :=  xla_ae_journal_entry_pkg.C_INVALID;
             xla_accounting_err_pkg.build_message
                                           (p_appli_s_name            => 'XLA'
                                           ,p_msg_name                => 'XLA_AP_BFLOW_NO_DIST_LINK_ID'
                                           ,p_token_1                 => 'LINE_NUMBER'
                                           ,p_value_1                 =>  g_ExtractLine
                                           ,p_token_2                 => 'LINE_TYPE_NAME'
                                           ,p_value_2                 =>  xla_ae_sources_pkg.GetComponentName (
                                                                           g_accounting_line.component_type
                                                                         , g_accounting_line.accounting_line_code
                                                                         , g_accounting_line.accounting_line_type_code
                                                                         , g_accounting_line.accounting_line_appl_id
                                                                         , g_accounting_line.amb_context_code
                                                                         , g_accounting_line.entity_code
                                                                         , g_accounting_line.event_class_code)
                                           ,p_token_3                 => 'OWNER'
                                           ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                           'XLA_OWNER_TYPE'
                                                                          , g_rec_lines.array_accounting_line_type(g_LineNumber))
                                           ,p_token_4                 => 'PRODUCT_NAME'
                                         --,p_value_4                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
                                           ,p_value_4                 => l_app_name
                                           ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                                           ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                                           ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                                           ,p_ae_header_id            => NULL);

            IF (C_LEVEL_ERROR >= g_log_level) THEN
                   trace
                        (p_msg      => 'ERROR: XLA_AP_BFLOW_NO_DIST_LINK_ID'
                        ,p_level    => C_LEVEL_ERROR
                        ,p_module   => l_log_module);
            END IF;
         END IF; -- (g_rec_lines.array_bflow_dist_id_char_1(g_LineNumber) IS NULL

      END IF; -- if bflow_entity_code is null

 --END IF;  -- if bflow_application_id is not null

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'END of ValidateBFlowLinks'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

EXCEPTION
--
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_lines_pkg.ValidateBFlowLinks');
  --
END ValidateBFlowLinks;

/*======================================================================+
|                                                                       |
| Public Procedure-  4262811                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE CopyLineInfo(
   p_line_num   NUMBER
) IS

   l_log_module         VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CopyLineInfo';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'BEGIN of CopyLineInfo'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

   -- added the call to overloaded procedure with source as G_REC_LINES as per bug: 7109881
   CopyLineInfo(p_line_num,g_rec_lines);

  -- commented the code, as code moved to overloaded procedure

   /*   SetNewLine;

   -------------------------------------------------------------------------------------------------------
   -- Copy all information in g_rec_lines from p_line_num to g_LineNumber with the following exceptions:
   -------------------------------------------------------------------------------------------------------
   --
   --
   -------------------------------------------------------------------------------------------------------
   -- Skipped a TEMP_LINE_NUM in distribution links for MPA as SetNewLine also increased by 1
   --
   -- following sets the temp line number
   -- g_rec_lines.array_line_num(g_LineNumber)     := NVL(g_temp_line_num ,0) + 1;
   -------------------------------------------------------------------------------------------------------
   --
   g_rec_lines.array_ae_header_id(g_LineNumber) := g_rec_lines.array_ae_header_id(p_line_num);
   g_rec_lines.array_header_num(g_LineNumber)   := g_rec_lines.array_header_num(p_line_num);

   -- =================================================================================================
   g_rec_lines.array_accounting_class(g_LineNumber)      := g_rec_lines.array_accounting_class(p_line_num);
   g_rec_lines.array_rounding_class(g_LineNumber)        := g_rec_lines.array_rounding_class(p_line_num);
   g_rec_lines.array_doc_rounding_level(g_LineNumber)    := g_rec_lines.array_doc_rounding_level(p_line_num);
   g_rec_lines.array_gain_or_loss_ref(g_LineNumber):=    g_rec_lines.array_gain_or_loss_ref(p_line_num);
   g_rec_lines.array_event_class_code(g_LineNumber)      := g_rec_lines.array_event_class_code(p_line_num);
   g_rec_lines.array_event_type_code(g_LineNumber)       := g_rec_lines.array_event_type_code(p_line_num);
   g_rec_lines.array_line_defn_owner_code(g_LineNumber)  := g_rec_lines.array_line_defn_owner_code(p_line_num);
   g_rec_lines.array_line_defn_code(g_LineNumber)        := g_rec_lines.array_line_defn_code(p_line_num);
   g_rec_lines.array_accounting_line_code(g_LineNumber)  := g_rec_lines.array_accounting_line_code(p_line_num);
   g_rec_lines.array_accounting_line_type(g_LineNumber)  := g_rec_lines.array_accounting_line_type(p_line_num);
   g_rec_lines.array_calculate_acctd_flag(g_LineNumber)  := g_rec_lines.array_calculate_acctd_flag(p_line_num);
   g_rec_lines.array_calculate_g_l_flag(g_LineNumber)    := g_rec_lines.array_calculate_g_l_flag(p_line_num);
   g_rec_lines.array_gain_or_loss_flag(g_LineNumber)    := g_rec_lines.array_gain_or_loss_flag(p_line_num);

   --
   -- following sets the extract line number
   --
   g_rec_lines.array_extract_line_num(g_LineNumber) := g_rec_lines.array_extract_line_num(p_line_num);

   --
   -- line flexfield accounts
   --
   g_rec_lines.array_ccid_flag(g_LineNumber)  := g_rec_lines.array_ccid_flag(p_line_num);
   g_rec_lines.array_ccid(g_LineNumber)       := g_rec_lines.array_ccid(p_line_num);
   --
   g_rec_lines.array_accounting_coa_id(g_LineNumber)   := g_rec_lines.array_accounting_coa_id(p_line_num);
   g_rec_lines.array_transaction_coa_id(g_LineNumber)  := g_rec_lines.array_transaction_coa_id(p_line_num);
   g_rec_lines.array_sl_coa_mapping_name(g_LineNumber) := g_rec_lines.array_sl_coa_mapping_name(p_line_num);
   --
   g_rec_lines.array_segment1(g_LineNumber)   := g_rec_lines.array_segment1(p_line_num);
   g_rec_lines.array_segment2(g_LineNumber)   := g_rec_lines.array_segment2(p_line_num);
   g_rec_lines.array_segment3(g_LineNumber)   := g_rec_lines.array_segment3(p_line_num);
   g_rec_lines.array_segment4(g_LineNumber)   := g_rec_lines.array_segment4(p_line_num);
   g_rec_lines.array_segment5(g_LineNumber)   := g_rec_lines.array_segment5(p_line_num);
   g_rec_lines.array_segment6(g_LineNumber)   := g_rec_lines.array_segment6(p_line_num);
   g_rec_lines.array_segment7(g_LineNumber)   := g_rec_lines.array_segment7(p_line_num);
   g_rec_lines.array_segment8(g_LineNumber)   := g_rec_lines.array_segment8(p_line_num);
   g_rec_lines.array_segment9(g_LineNumber)   := g_rec_lines.array_segment9(p_line_num);
   g_rec_lines.array_segment10(g_LineNumber)  := g_rec_lines.array_segment10(p_line_num);
   g_rec_lines.array_segment11(g_LineNumber)  := g_rec_lines.array_segment11(p_line_num);
   g_rec_lines.array_segment12(g_LineNumber)  := g_rec_lines.array_segment12(p_line_num);
   g_rec_lines.array_segment13(g_LineNumber)  := g_rec_lines.array_segment13(p_line_num);
   g_rec_lines.array_segment14(g_LineNumber)  := g_rec_lines.array_segment14(p_line_num);
   g_rec_lines.array_segment15(g_LineNumber)  := g_rec_lines.array_segment15(p_line_num);
   g_rec_lines.array_segment16(g_LineNumber)  := g_rec_lines.array_segment16(p_line_num);
   g_rec_lines.array_segment17(g_LineNumber)  := g_rec_lines.array_segment17(p_line_num);
   g_rec_lines.array_segment18(g_LineNumber)  := g_rec_lines.array_segment18(p_line_num);
   g_rec_lines.array_segment19(g_LineNumber)  := g_rec_lines.array_segment19(p_line_num);
   g_rec_lines.array_segment20(g_LineNumber)  := g_rec_lines.array_segment20(p_line_num);
   g_rec_lines.array_segment21(g_LineNumber)  := g_rec_lines.array_segment21(p_line_num);
   g_rec_lines.array_segment22(g_LineNumber)  := g_rec_lines.array_segment22(p_line_num);
   g_rec_lines.array_segment23(g_LineNumber)  := g_rec_lines.array_segment23(p_line_num);
   g_rec_lines.array_segment24(g_LineNumber)  := g_rec_lines.array_segment24(p_line_num);
   g_rec_lines.array_segment25(g_LineNumber)  := g_rec_lines.array_segment25(p_line_num);
   g_rec_lines.array_segment26(g_LineNumber)  := g_rec_lines.array_segment26(p_line_num);
   g_rec_lines.array_segment27(g_LineNumber)  := g_rec_lines.array_segment27(p_line_num);
   g_rec_lines.array_segment28(g_LineNumber)  := g_rec_lines.array_segment28(p_line_num);
   g_rec_lines.array_segment29(g_LineNumber)  := g_rec_lines.array_segment29(p_line_num);
   g_rec_lines.array_segment30(g_LineNumber)  := g_rec_lines.array_segment30(p_line_num);
   --
   g_rec_lines.alt_array_ccid_flag(g_LineNumber)  := g_rec_lines.alt_array_ccid_flag(p_line_num);
   g_rec_lines.alt_array_ccid(g_LineNumber)       := g_rec_lines.alt_array_ccid(p_line_num);
   g_rec_lines.alt_array_segment1(g_LineNumber)   := g_rec_lines.alt_array_segment1(p_line_num);
   g_rec_lines.alt_array_segment2(g_LineNumber)   := g_rec_lines.alt_array_segment2(p_line_num);
   g_rec_lines.alt_array_segment3(g_LineNumber)   := g_rec_lines.alt_array_segment3(p_line_num);
   g_rec_lines.alt_array_segment4(g_LineNumber)   := g_rec_lines.alt_array_segment4(p_line_num);
   g_rec_lines.alt_array_segment5(g_LineNumber)   := g_rec_lines.alt_array_segment5(p_line_num);
   g_rec_lines.alt_array_segment6(g_LineNumber)   := g_rec_lines.alt_array_segment6(p_line_num);
   g_rec_lines.alt_array_segment7(g_LineNumber)   := g_rec_lines.alt_array_segment7(p_line_num);
   g_rec_lines.alt_array_segment8(g_LineNumber)   := g_rec_lines.alt_array_segment8(p_line_num);
   g_rec_lines.alt_array_segment9(g_LineNumber)   := g_rec_lines.alt_array_segment9(p_line_num);
   g_rec_lines.alt_array_segment10(g_LineNumber)  := g_rec_lines.alt_array_segment10(p_line_num);
   g_rec_lines.alt_array_segment11(g_LineNumber)  := g_rec_lines.alt_array_segment11(p_line_num);
   g_rec_lines.alt_array_segment12(g_LineNumber)  := g_rec_lines.alt_array_segment12(p_line_num);
   g_rec_lines.alt_array_segment13(g_LineNumber)  := g_rec_lines.alt_array_segment13(p_line_num);
   g_rec_lines.alt_array_segment14(g_LineNumber)  := g_rec_lines.alt_array_segment14(p_line_num);
   g_rec_lines.alt_array_segment15(g_LineNumber)  := g_rec_lines.alt_array_segment15(p_line_num);
   g_rec_lines.alt_array_segment16(g_LineNumber)  := g_rec_lines.alt_array_segment16(p_line_num);
   g_rec_lines.alt_array_segment17(g_LineNumber)  := g_rec_lines.alt_array_segment17(p_line_num);
   g_rec_lines.alt_array_segment18(g_LineNumber)  := g_rec_lines.alt_array_segment18(p_line_num);
   g_rec_lines.alt_array_segment19(g_LineNumber)  := g_rec_lines.alt_array_segment19(p_line_num);
   g_rec_lines.alt_array_segment20(g_LineNumber)  := g_rec_lines.alt_array_segment20(p_line_num);
   g_rec_lines.alt_array_segment21(g_LineNumber)  := g_rec_lines.alt_array_segment21(p_line_num);
   g_rec_lines.alt_array_segment22(g_LineNumber)  := g_rec_lines.alt_array_segment22(p_line_num);
   g_rec_lines.alt_array_segment23(g_LineNumber)  := g_rec_lines.alt_array_segment23(p_line_num);
   g_rec_lines.alt_array_segment24(g_LineNumber)  := g_rec_lines.alt_array_segment24(p_line_num);
   g_rec_lines.alt_array_segment25(g_LineNumber)  := g_rec_lines.alt_array_segment25(p_line_num);
   g_rec_lines.alt_array_segment26(g_LineNumber)  := g_rec_lines.alt_array_segment26(p_line_num);
   g_rec_lines.alt_array_segment27(g_LineNumber)  := g_rec_lines.alt_array_segment27(p_line_num);
   g_rec_lines.alt_array_segment28(g_LineNumber)  := g_rec_lines.alt_array_segment28(p_line_num);
   g_rec_lines.alt_array_segment29(g_LineNumber)  := g_rec_lines.alt_array_segment29(p_line_num);
   g_rec_lines.alt_array_segment30(g_LineNumber)  := g_rec_lines.alt_array_segment30(p_line_num);
   --
   -- Option lines
   --
   g_rec_lines.array_gl_transfer_mode(g_LineNumber)      := g_rec_lines.array_gl_transfer_mode(p_line_num);
   g_rec_lines.array_natural_side_code(g_LineNumber)     := g_rec_lines.array_natural_side_code(p_line_num);
   g_rec_lines.array_acct_entry_type_code(g_LineNumber)  := g_rec_lines.array_acct_entry_type_code(p_line_num);
   g_rec_lines.array_switch_side_flag(g_LineNumber)      := g_rec_lines.array_switch_side_flag(p_line_num);
   g_rec_lines.array_merge_duplicate_code(g_LineNumber)  := g_rec_lines.array_merge_duplicate_code(p_line_num);
   --
   -- line amounts
   --
   g_rec_lines.array_entered_amount(g_LineNumber)        := g_rec_lines.array_entered_amount(p_line_num);
   g_rec_lines.array_ledger_amount(g_LineNumber)         := g_rec_lines.array_ledger_amount(p_line_num);
   g_rec_lines.array_entered_dr(g_LineNumber)            := g_rec_lines.array_entered_dr(p_line_num);
   g_rec_lines.array_entered_cr(g_LineNumber)            := g_rec_lines.array_entered_cr(p_line_num);
   g_rec_lines.array_accounted_dr(g_LineNumber)          := g_rec_lines.array_accounted_dr(p_line_num);
   g_rec_lines.array_accounted_cr(g_LineNumber)          := g_rec_lines.array_accounted_cr(p_line_num);
   g_rec_lines.array_currency_code(g_LineNumber)         := g_rec_lines.array_currency_code(p_line_num);
   g_rec_lines.array_currency_mau(g_LineNumber)          := xla_accounting_cache_pkg.GetCurrencyMau(g_rec_lines.array_currency_code(g_LineNumber));
   g_rec_lines.array_curr_conversion_date(g_LineNumber)  := g_rec_lines.array_curr_conversion_date(p_line_num);
   g_rec_lines.array_curr_conversion_rate(g_LineNumber)  := g_rec_lines.array_curr_conversion_rate(p_line_num);
   g_rec_lines.array_curr_conversion_type(g_LineNumber)  := g_rec_lines.array_curr_conversion_type(p_line_num);
   g_rec_lines.array_description(g_LineNumber)           := g_rec_lines.array_description(p_line_num);
   --
   -- line descriptions
   --
   g_rec_lines.array_party_id(g_LineNumber)              := g_rec_lines.array_party_id(p_line_num);
   g_rec_lines.array_party_site_id(g_LineNumber)         := g_rec_lines.array_party_site_id(p_line_num);
   g_rec_lines.array_party_type_code(g_LineNumber)       := g_rec_lines.array_party_type_code(p_line_num);
   --
   g_rec_lines.array_statistical_amount(g_LineNumber)    := g_rec_lines.array_statistical_amount(p_line_num);
   g_rec_lines.array_ussgl_transaction(g_LineNumber)     := g_rec_lines.array_ussgl_transaction(p_line_num);
   --
   g_rec_lines.array_jgzz_recon_ref(g_LineNumber)           := g_rec_lines.array_jgzz_recon_ref(p_line_num);
   --
   -- distribution links
   --
   g_rec_lines.array_distribution_id_char_1(g_LineNumber)  := g_rec_lines.array_distribution_id_char_1(p_line_num);
   g_rec_lines.array_distribution_id_char_2(g_LineNumber)  := g_rec_lines.array_distribution_id_char_2(p_line_num);
   g_rec_lines.array_distribution_id_char_3(g_LineNumber)  := g_rec_lines.array_distribution_id_char_3(p_line_num);
   g_rec_lines.array_distribution_id_char_4(g_LineNumber)  := g_rec_lines.array_distribution_id_char_4(p_line_num);
   g_rec_lines.array_distribution_id_char_5(g_LineNumber)  := g_rec_lines.array_distribution_id_char_5(p_line_num);
   g_rec_lines.array_distribution_id_num_1(g_LineNumber)   := g_rec_lines.array_distribution_id_num_1(p_line_num);
   g_rec_lines.array_distribution_id_num_2(g_LineNumber)   := g_rec_lines.array_distribution_id_num_2(p_line_num);
   g_rec_lines.array_distribution_id_num_3(g_LineNumber)   := g_rec_lines.array_distribution_id_num_3(p_line_num);
   g_rec_lines.array_distribution_id_num_4(g_LineNumber)   := g_rec_lines.array_distribution_id_num_4(p_line_num);
   g_rec_lines.array_distribution_id_num_5(g_LineNumber)   := g_rec_lines.array_distribution_id_num_5(p_line_num);
   g_rec_lines.array_sys_distribution_type(g_LineNumber)   := g_rec_lines.array_sys_distribution_type(p_line_num);
   --
   -- reverse distribution links
   --
   g_rec_lines.array_rev_dist_id_char_1(g_LineNumber)  := g_rec_lines.array_rev_dist_id_char_1(p_line_num);
   g_rec_lines.array_rev_dist_id_char_2(g_LineNumber)  := g_rec_lines.array_rev_dist_id_char_2(p_line_num);
   g_rec_lines.array_rev_dist_id_char_3(g_LineNumber)  := g_rec_lines.array_rev_dist_id_char_3(p_line_num);
   g_rec_lines.array_rev_dist_id_char_4(g_LineNumber)  := g_rec_lines.array_rev_dist_id_char_4(p_line_num);
   g_rec_lines.array_rev_dist_id_char_5(g_LineNumber)  := g_rec_lines.array_rev_dist_id_char_5(p_line_num);
   g_rec_lines.array_rev_dist_id_num_1(g_LineNumber)   := g_rec_lines.array_rev_dist_id_num_1(p_line_num);
   g_rec_lines.array_rev_dist_id_num_2(g_LineNumber)   := g_rec_lines.array_rev_dist_id_num_2(p_line_num);
   g_rec_lines.array_rev_dist_id_num_3(g_LineNumber)   := g_rec_lines.array_rev_dist_id_num_3(p_line_num);
   g_rec_lines.array_rev_dist_id_num_4(g_LineNumber)   := g_rec_lines.array_rev_dist_id_num_4(p_line_num);
   g_rec_lines.array_rev_dist_id_num_5(g_LineNumber)   := g_rec_lines.array_rev_dist_id_num_5(p_line_num);
   g_rec_lines.array_rev_dist_type(g_LineNumber)       := g_rec_lines.array_rev_dist_type(p_line_num);
   --
   -- multiperiod accounting
   --
   -- DO NOT COPY g_rec_lines.array_mpa_acc_entry_flag
   g_rec_lines.array_header_num(g_LineNumber)          := g_rec_lines.array_header_num(p_line_num);
   g_rec_lines.array_mpa_option(g_LineNumber)          := g_rec_lines.array_mpa_option(p_line_num);
   g_rec_lines.array_mpa_start_date(g_LineNumber)      := g_rec_lines.array_mpa_start_date(p_line_num);
   g_rec_lines.array_mpa_end_date(g_LineNumber)        := g_rec_lines.array_mpa_end_date(p_line_num);
   --
   -- reversal info
   --
   g_rec_lines.array_acc_reversal_option(g_LineNumber)   := g_rec_lines.array_acc_reversal_option(p_line_num);
   --
   -- tax info
   --
   g_rec_lines.array_tax_line_ref(g_LineNumber)           := g_rec_lines.array_tax_line_ref(p_line_num);
   g_rec_lines.array_tax_summary_line_ref(g_LineNumber)   := g_rec_lines.array_tax_summary_line_ref(p_line_num);
   g_rec_lines.array_tax_rec_nrec_dist_ref(g_LineNumber)  := g_rec_lines.array_tax_rec_nrec_dist_ref(p_line_num);
   --
   --
   g_rec_lines.array_anc_balance_flag(g_LineNumber)      := g_rec_lines.array_anc_balance_flag(p_line_num);
   g_rec_lines.array_anc_id_1(g_LineNumber)              := g_rec_lines.array_anc_id_1(p_line_num);
   g_rec_lines.array_anc_id_2(g_LineNumber)              := g_rec_lines.array_anc_id_2(p_line_num);
   g_rec_lines.array_anc_id_3(g_LineNumber)              := g_rec_lines.array_anc_id_3(p_line_num);
   g_rec_lines.array_anc_id_4(g_LineNumber)              := g_rec_lines.array_anc_id_4(p_line_num);
   g_rec_lines.array_anc_id_5(g_LineNumber)              := g_rec_lines.array_anc_id_5(p_line_num);
   g_rec_lines.array_anc_id_6(g_LineNumber)              := g_rec_lines.array_anc_id_6(p_line_num);
   g_rec_lines.array_anc_id_7(g_LineNumber)              := g_rec_lines.array_anc_id_7(p_line_num);
   g_rec_lines.array_anc_id_8(g_LineNumber)              := g_rec_lines.array_anc_id_8(p_line_num);
   g_rec_lines.array_anc_id_9(g_LineNumber)              := g_rec_lines.array_anc_id_9(p_line_num);
   g_rec_lines.array_anc_id_10(g_LineNumber)             := g_rec_lines.array_anc_id_10(p_line_num);
   g_rec_lines.array_anc_id_11(g_LineNumber)             := g_rec_lines.array_anc_id_11(p_line_num);
   g_rec_lines.array_anc_id_12(g_LineNumber)             := g_rec_lines.array_anc_id_12(p_line_num);
   g_rec_lines.array_anc_id_13(g_LineNumber)             := g_rec_lines.array_anc_id_13(p_line_num);
   g_rec_lines.array_anc_id_14(g_LineNumber)             := g_rec_lines.array_anc_id_14(p_line_num);
   g_rec_lines.array_anc_id_15(g_LineNumber)             := g_rec_lines.array_anc_id_15(p_line_num);
   g_rec_lines.array_anc_id_16(g_LineNumber)             := g_rec_lines.array_anc_id_16(p_line_num);
   g_rec_lines.array_anc_id_17(g_LineNumber)             := g_rec_lines.array_anc_id_17(p_line_num);
   g_rec_lines.array_anc_id_18(g_LineNumber)             := g_rec_lines.array_anc_id_18(p_line_num);
   g_rec_lines.array_anc_id_19(g_LineNumber)             := g_rec_lines.array_anc_id_19(p_line_num);
   g_rec_lines.array_anc_id_20(g_LineNumber)             := g_rec_lines.array_anc_id_20(p_line_num);
   g_rec_lines.array_anc_id_21(g_LineNumber)             := g_rec_lines.array_anc_id_21(p_line_num);
   g_rec_lines.array_anc_id_22(g_LineNumber)             := g_rec_lines.array_anc_id_22(p_line_num);
   g_rec_lines.array_anc_id_23(g_LineNumber)             := g_rec_lines.array_anc_id_23(p_line_num);
   g_rec_lines.array_anc_id_24(g_LineNumber)             := g_rec_lines.array_anc_id_24(p_line_num);
   g_rec_lines.array_anc_id_25(g_LineNumber)             := g_rec_lines.array_anc_id_25(p_line_num);
   g_rec_lines.array_anc_id_26(g_LineNumber)             := g_rec_lines.array_anc_id_26(p_line_num);
   g_rec_lines.array_anc_id_27(g_LineNumber)             := g_rec_lines.array_anc_id_27(p_line_num);
   g_rec_lines.array_anc_id_28(g_LineNumber)             := g_rec_lines.array_anc_id_28(p_line_num);
   g_rec_lines.array_anc_id_29(g_LineNumber)             := g_rec_lines.array_anc_id_29(p_line_num);
   g_rec_lines.array_anc_id_30(g_LineNumber)             := g_rec_lines.array_anc_id_30(p_line_num);
   g_rec_lines.array_anc_id_31(g_LineNumber)             := g_rec_lines.array_anc_id_31(p_line_num);
   g_rec_lines.array_anc_id_32(g_LineNumber)             := g_rec_lines.array_anc_id_32(p_line_num);
   g_rec_lines.array_anc_id_33(g_LineNumber)             := g_rec_lines.array_anc_id_33(p_line_num);
   g_rec_lines.array_anc_id_34(g_LineNumber)             := g_rec_lines.array_anc_id_34(p_line_num);
   g_rec_lines.array_anc_id_35(g_LineNumber)             := g_rec_lines.array_anc_id_35(p_line_num);
   g_rec_lines.array_anc_id_36(g_LineNumber)             := g_rec_lines.array_anc_id_36(p_line_num);
   g_rec_lines.array_anc_id_37(g_LineNumber)             := g_rec_lines.array_anc_id_37(p_line_num);
   g_rec_lines.array_anc_id_38(g_LineNumber)             := g_rec_lines.array_anc_id_38(p_line_num);
   g_rec_lines.array_anc_id_39(g_LineNumber)             := g_rec_lines.array_anc_id_39(p_line_num);
   g_rec_lines.array_anc_id_40(g_LineNumber)             := g_rec_lines.array_anc_id_40(p_line_num);
   g_rec_lines.array_anc_id_41(g_LineNumber)             := g_rec_lines.array_anc_id_41(p_line_num);
   g_rec_lines.array_anc_id_42(g_LineNumber)             := g_rec_lines.array_anc_id_42(p_line_num);
   g_rec_lines.array_anc_id_43(g_LineNumber)             := g_rec_lines.array_anc_id_43(p_line_num);
   g_rec_lines.array_anc_id_44(g_LineNumber)             := g_rec_lines.array_anc_id_44(p_line_num);
   g_rec_lines.array_anc_id_45(g_LineNumber)             := g_rec_lines.array_anc_id_45(p_line_num);
   g_rec_lines.array_anc_id_46(g_LineNumber)             := g_rec_lines.array_anc_id_46(p_line_num);
   g_rec_lines.array_anc_id_47(g_LineNumber)             := g_rec_lines.array_anc_id_47(p_line_num);
   g_rec_lines.array_anc_id_48(g_LineNumber)             := g_rec_lines.array_anc_id_48(p_line_num);
   g_rec_lines.array_anc_id_49(g_LineNumber)             := g_rec_lines.array_anc_id_49(p_line_num);
   g_rec_lines.array_anc_id_50(g_LineNumber)             := g_rec_lines.array_anc_id_50(p_line_num);
   g_rec_lines.array_anc_id_51(g_LineNumber)             := g_rec_lines.array_anc_id_51(p_line_num);
   g_rec_lines.array_anc_id_52(g_LineNumber)             := g_rec_lines.array_anc_id_52(p_line_num);
   g_rec_lines.array_anc_id_53(g_LineNumber)             := g_rec_lines.array_anc_id_53(p_line_num);
   g_rec_lines.array_anc_id_54(g_LineNumber)             := g_rec_lines.array_anc_id_54(p_line_num);
   g_rec_lines.array_anc_id_55(g_LineNumber)             := g_rec_lines.array_anc_id_55(p_line_num);
   g_rec_lines.array_anc_id_56(g_LineNumber)             := g_rec_lines.array_anc_id_56(p_line_num);
   g_rec_lines.array_anc_id_57(g_LineNumber)             := g_rec_lines.array_anc_id_57(p_line_num);
   g_rec_lines.array_anc_id_58(g_LineNumber)             := g_rec_lines.array_anc_id_58(p_line_num);
   g_rec_lines.array_anc_id_59(g_LineNumber)             := g_rec_lines.array_anc_id_59(p_line_num);
   g_rec_lines.array_anc_id_60(g_LineNumber)             := g_rec_lines.array_anc_id_60(p_line_num);
   g_rec_lines.array_anc_id_61(g_LineNumber)             := g_rec_lines.array_anc_id_61(p_line_num);
   g_rec_lines.array_anc_id_62(g_LineNumber)             := g_rec_lines.array_anc_id_62(p_line_num);
   g_rec_lines.array_anc_id_63(g_LineNumber)             := g_rec_lines.array_anc_id_63(p_line_num);
   g_rec_lines.array_anc_id_64(g_LineNumber)             := g_rec_lines.array_anc_id_64(p_line_num);
   g_rec_lines.array_anc_id_65(g_LineNumber)             := g_rec_lines.array_anc_id_65(p_line_num);
   g_rec_lines.array_anc_id_66(g_LineNumber)             := g_rec_lines.array_anc_id_66(p_line_num);
   g_rec_lines.array_anc_id_67(g_LineNumber)             := g_rec_lines.array_anc_id_67(p_line_num);
   g_rec_lines.array_anc_id_68(g_LineNumber)             := g_rec_lines.array_anc_id_68(p_line_num);
   g_rec_lines.array_anc_id_69(g_LineNumber)             := g_rec_lines.array_anc_id_69(p_line_num);
   g_rec_lines.array_anc_id_70(g_LineNumber)             := g_rec_lines.array_anc_id_70(p_line_num);
   g_rec_lines.array_anc_id_71(g_LineNumber)             := g_rec_lines.array_anc_id_71(p_line_num);
   g_rec_lines.array_anc_id_72(g_LineNumber)             := g_rec_lines.array_anc_id_72(p_line_num);
   g_rec_lines.array_anc_id_73(g_LineNumber)             := g_rec_lines.array_anc_id_73(p_line_num);
   g_rec_lines.array_anc_id_74(g_LineNumber)             := g_rec_lines.array_anc_id_74(p_line_num);
   g_rec_lines.array_anc_id_75(g_LineNumber)             := g_rec_lines.array_anc_id_75(p_line_num);
   g_rec_lines.array_anc_id_76(g_LineNumber)             := g_rec_lines.array_anc_id_76(p_line_num);
   g_rec_lines.array_anc_id_77(g_LineNumber)             := g_rec_lines.array_anc_id_77(p_line_num);
   g_rec_lines.array_anc_id_78(g_LineNumber)             := g_rec_lines.array_anc_id_78(p_line_num);
   g_rec_lines.array_anc_id_79(g_LineNumber)             := g_rec_lines.array_anc_id_79(p_line_num);
   g_rec_lines.array_anc_id_80(g_LineNumber)             := g_rec_lines.array_anc_id_80(p_line_num);
   g_rec_lines.array_anc_id_81(g_LineNumber)             := g_rec_lines.array_anc_id_81(p_line_num);
   g_rec_lines.array_anc_id_82(g_LineNumber)             := g_rec_lines.array_anc_id_82(p_line_num);
   g_rec_lines.array_anc_id_83(g_LineNumber)             := g_rec_lines.array_anc_id_83(p_line_num);
   g_rec_lines.array_anc_id_84(g_LineNumber)             := g_rec_lines.array_anc_id_84(p_line_num);
   g_rec_lines.array_anc_id_85(g_LineNumber)             := g_rec_lines.array_anc_id_85(p_line_num);
   g_rec_lines.array_anc_id_86(g_LineNumber)             := g_rec_lines.array_anc_id_86(p_line_num);
   g_rec_lines.array_anc_id_87(g_LineNumber)             := g_rec_lines.array_anc_id_87(p_line_num);
   g_rec_lines.array_anc_id_88(g_LineNumber)             := g_rec_lines.array_anc_id_88(p_line_num);
   g_rec_lines.array_anc_id_89(g_LineNumber)             := g_rec_lines.array_anc_id_89(p_line_num);
   g_rec_lines.array_anc_id_90(g_LineNumber)             := g_rec_lines.array_anc_id_90(p_line_num);
   g_rec_lines.array_anc_id_91(g_LineNumber)             := g_rec_lines.array_anc_id_91(p_line_num);
   g_rec_lines.array_anc_id_92(g_LineNumber)             := g_rec_lines.array_anc_id_92(p_line_num);
   g_rec_lines.array_anc_id_93(g_LineNumber)             := g_rec_lines.array_anc_id_93(p_line_num);
   g_rec_lines.array_anc_id_94(g_LineNumber)             := g_rec_lines.array_anc_id_94(p_line_num);
   g_rec_lines.array_anc_id_95(g_LineNumber)             := g_rec_lines.array_anc_id_95(p_line_num);
   g_rec_lines.array_anc_id_96(g_LineNumber)             := g_rec_lines.array_anc_id_96(p_line_num);
   g_rec_lines.array_anc_id_97(g_LineNumber)             := g_rec_lines.array_anc_id_97(p_line_num);
   g_rec_lines.array_anc_id_98(g_LineNumber)             := g_rec_lines.array_anc_id_98(p_line_num);
   g_rec_lines.array_anc_id_99(g_LineNumber)             := g_rec_lines.array_anc_id_99(p_line_num);
   g_rec_lines.array_anc_id_100(g_LineNumber)            := g_rec_lines.array_anc_id_100(p_line_num);
   --
   --
   g_rec_lines.array_event_number(g_LineNumber)          := g_rec_lines.array_event_number(p_line_num);
   g_rec_lines.array_entity_id(g_LineNumber)             := g_rec_lines.array_entity_id(p_line_num);
   g_rec_lines.array_reversal_code(g_LineNumber)         := g_rec_lines.array_reversal_code(p_line_num);
   g_rec_lines.array_balance_type_code(g_LineNumber)     := g_rec_lines.array_balance_type_code(p_line_num);
   g_rec_lines.array_ledger_id(g_LineNumber)             := g_rec_lines.array_ledger_id(p_line_num);
   --
   -- business flow
   --
   g_rec_lines.array_business_method_code(g_LineNumber)   := g_rec_lines.array_business_method_code(p_line_num);
   g_rec_lines.array_business_class_code(g_LineNumber)    := g_rec_lines.array_business_class_code(p_line_num);
   g_rec_lines.array_inherit_desc_flag(g_LineNumber)      := g_rec_lines.array_inherit_desc_flag(p_line_num);
   g_rec_lines.array_bflow_application_id(g_LineNumber)   := g_rec_lines.array_bflow_application_id(p_line_num);

   g_rec_lines.array_bflow_entity_code(g_LineNumber)      := g_rec_lines.array_bflow_entity_code(p_line_num);
   g_rec_lines.array_bflow_source_id_num_1(g_LineNumber)  := g_rec_lines.array_bflow_source_id_num_1(p_line_num);
   g_rec_lines.array_bflow_source_id_num_2(g_LineNumber)  := g_rec_lines.array_bflow_source_id_num_2(p_line_num);
   g_rec_lines.array_bflow_source_id_num_3(g_LineNumber)  := g_rec_lines.array_bflow_source_id_num_3(p_line_num);
   g_rec_lines.array_bflow_source_id_num_4(g_LineNumber)  := g_rec_lines.array_bflow_source_id_num_4(p_line_num);
   g_rec_lines.array_bflow_source_id_char_1(g_LineNumber) := g_rec_lines.array_bflow_source_id_char_1(p_line_num);
   g_rec_lines.array_bflow_source_id_char_2(g_LineNumber) := g_rec_lines.array_bflow_source_id_char_2(p_line_num);
   g_rec_lines.array_bflow_source_id_char_3(g_LineNumber) := g_rec_lines.array_bflow_source_id_char_3(p_line_num);
   g_rec_lines.array_bflow_source_id_char_4(g_LineNumber) := g_rec_lines.array_bflow_source_id_char_4(p_line_num);

   g_rec_lines.array_bflow_distribution_type(g_LineNumber):= g_rec_lines.array_bflow_distribution_type(p_line_num);
   g_rec_lines.array_bflow_dist_id_num_1(g_LineNumber)    := g_rec_lines.array_bflow_dist_id_num_1(p_line_num);
   g_rec_lines.array_bflow_dist_id_num_2(g_LineNumber)    := g_rec_lines.array_bflow_dist_id_num_2(p_line_num);
   g_rec_lines.array_bflow_dist_id_num_3(g_LineNumber)    := g_rec_lines.array_bflow_dist_id_num_3(p_line_num);
   g_rec_lines.array_bflow_dist_id_num_4(g_LineNumber)    := g_rec_lines.array_bflow_dist_id_num_4(p_line_num);
   g_rec_lines.array_bflow_dist_id_num_5(g_LineNumber)    := g_rec_lines.array_bflow_dist_id_num_5(p_line_num);
   g_rec_lines.array_bflow_dist_id_char_1(g_LineNumber)   := g_rec_lines.array_bflow_dist_id_char_1(p_line_num);
   g_rec_lines.array_bflow_dist_id_char_2(g_LineNumber)   := g_rec_lines.array_bflow_dist_id_char_2(p_line_num);
   g_rec_lines.array_bflow_dist_id_char_3(g_LineNumber)   := g_rec_lines.array_bflow_dist_id_char_3(p_line_num);
   g_rec_lines.array_bflow_dist_id_char_4(g_LineNumber)   := g_rec_lines.array_bflow_dist_id_char_4(p_line_num);
   g_rec_lines.array_bflow_dist_id_char_5(g_LineNumber)   := g_rec_lines.array_bflow_dist_id_char_5(p_line_num);

   g_rec_lines.array_override_acctd_amt_flag(g_LineNumber)   := g_rec_lines.array_override_acctd_amt_flag(p_line_num);


   g_rec_lines.array_bflow_applied_to_amt(g_LineNumber)   := g_rec_lines.array_bflow_applied_to_amt(p_line_num); -- 5132302
   --
   -- Allocation Attributes
   --
   g_rec_lines.array_alloct_application_id(g_LineNumber)   := g_rec_lines.array_alloct_application_id(p_line_num);

   g_rec_lines.array_alloct_entity_code(g_LineNumber)      := g_rec_lines.array_alloct_entity_code(p_line_num);
   g_rec_lines.array_alloct_source_id_num_1(g_LineNumber)  := g_rec_lines.array_alloct_source_id_num_1(p_line_num);
   g_rec_lines.array_alloct_source_id_num_2(g_LineNumber)  := g_rec_lines.array_alloct_source_id_num_2(p_line_num);
   g_rec_lines.array_alloct_source_id_num_3(g_LineNumber)  := g_rec_lines.array_alloct_source_id_num_3(p_line_num);
   g_rec_lines.array_alloct_source_id_num_4(g_LineNumber)  := g_rec_lines.array_alloct_source_id_num_4(p_line_num);
   g_rec_lines.array_alloct_source_id_char_1(g_LineNumber) := g_rec_lines.array_alloct_source_id_char_1(p_line_num);
   g_rec_lines.array_alloct_source_id_char_2(g_LineNumber) := g_rec_lines.array_alloct_source_id_char_2(p_line_num);
   g_rec_lines.array_alloct_source_id_char_3(g_LineNumber) := g_rec_lines.array_alloct_source_id_char_3(p_line_num);
   g_rec_lines.array_alloct_source_id_char_4(g_LineNumber) := g_rec_lines.array_alloct_source_id_char_4(p_line_num);

   g_rec_lines.array_alloct_distribution_type(g_LineNumber):= g_rec_lines.array_alloct_distribution_type(p_line_num);
   g_rec_lines.array_alloct_dist_id_num_1(g_LineNumber)    := g_rec_lines.array_alloct_dist_id_num_1(p_line_num);
   g_rec_lines.array_alloct_dist_id_num_2(g_LineNumber)    := g_rec_lines.array_alloct_dist_id_num_2(p_line_num);
   g_rec_lines.array_alloct_dist_id_num_3(g_LineNumber)    := g_rec_lines.array_alloct_dist_id_num_3(p_line_num);
   g_rec_lines.array_alloct_dist_id_num_4(g_LineNumber)    := g_rec_lines.array_alloct_dist_id_num_4(p_line_num);
   g_rec_lines.array_alloct_dist_id_num_5(g_LineNumber)    := g_rec_lines.array_alloct_dist_id_num_5(p_line_num);
   g_rec_lines.array_alloct_dist_id_char_1(g_LineNumber)   := g_rec_lines.array_alloct_dist_id_char_1(p_line_num);
   g_rec_lines.array_alloct_dist_id_char_2(g_LineNumber)   := g_rec_lines.array_alloct_dist_id_char_2(p_line_num);
   g_rec_lines.array_alloct_dist_id_char_3(g_LineNumber)   := g_rec_lines.array_alloct_dist_id_char_3(p_line_num);
   g_rec_lines.array_alloct_dist_id_char_4(g_LineNumber)   := g_rec_lines.array_alloct_dist_id_char_4(p_line_num);
   g_rec_lines.array_alloct_dist_id_char_5(g_LineNumber)   := g_rec_lines.array_alloct_dist_id_char_5(p_line_num);
   -- =================================================================================================
   --
   -- for 7029018
   IF NVL(g_rec_lines.array_balance_type_code(g_LineNumber),'N')='E'  THEN
      IF ((NVL(g_rec_lines.array_actual_upg_option(p_line_num), 'N') = 'Y') OR
          (NVL(g_rec_lines.array_enc_upg_option(p_line_num), 'N') = 'Y')) THEN
       --temp fix for Period End Accrual Encumbrance for Upgraded Entries.
           g_rec_lines.array_encumbrance_type_id(g_LineNumber) := nvl(g_rec_lines.array_upg_cr_enc_type_id(p_line_num),
                                                              g_rec_lines.array_upg_dr_enc_type_id(p_line_num));
            IF (C_LEVEL_EVENT >= g_log_level) THEN
                trace
               (p_msg       =>   'Period End Accrual Encumbrance for Upgraded Entries'
               ,p_level     =>   C_LEVEL_EVENT
               ,p_module    =>   l_log_module);
            END IF;
       END IF;
    END IF;

   --
   -- Validate line accounting attributes
   --
   IF g_rec_lines.array_mpa_option(g_LineNumber) NOT IN ('Y','N') THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      xla_accounting_err_pkg.build_message
           (p_appli_s_name            => 'XLA'
           ,p_msg_name                => 'XLA_MA_INVALID_OPTION'    -- 4262811a
           ,p_token_1                 => 'LINE_NUMBER'
           ,p_value_1                 =>  g_ExtractLine
           ,p_token_2                 => 'ACCOUNTING_SOURCE_NAME'
           ,p_value_2                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('MULTIPERIOD_OPTION')
                                                         --(g_rec_lines.array_acct_attr_code(p_line_num))
           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
           ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
   END IF;

   IF g_rec_lines.array_sys_distribution_type(g_LineNumber) IS NULL THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      xla_accounting_err_pkg.build_message
           (p_appli_s_name            => 'XLA'
           ,p_msg_name                => 'XLA_AP_NO_DIST_LINK_TYPE'
           ,p_token_1                 => 'LINE_NUMBER'
           ,p_value_1                 =>  g_ExtractLine
           ,p_token_2                 => 'ACCOUNTING_SOURCE_NAME'
           ,p_value_2                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('DISTRIBUTION_TYPE')
                                                             --(p_rec_acct_attrs.array_acct_attr_code(i))
           ,p_token_3                 => 'SOURCE_NAME'
           ,p_value_3                 => NULL
           ,p_token_4                 => 'LINE_TYPE_NAME'
           ,p_value_4                 =>  XLA_AE_SOURCES_PKG.GetComponentName (
                                                     g_accounting_line.component_type
                                                   , g_accounting_line.accounting_line_code
                                                   , g_accounting_line.accounting_line_type_code
                                                   , g_accounting_line.accounting_line_appl_id
                                                   , g_accounting_line.amb_context_code
                                                   , g_accounting_line.entity_code
                                                   , g_accounting_line.event_class_code
                                                  )
           ,p_token_5                 => 'OWNER'
           ,p_value_5                 => xla_lookups_pkg.get_meaning(
                                                     'XLA_OWNER_TYPE'
                                                    , g_rec_lines.array_accounting_line_type(g_LineNumber)
                                                   )
           ,p_token_6                 => 'PRODUCT_NAME'
           ,p_value_6                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
           ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
   END IF;

----------------------------------------------
-- 4623638  This change is on top of 120.85
----------------------------------------------
IF nvl(g_rec_lines.array_calculate_acctd_flag(g_LineNumber), 'N')= 'N' OR
     (nvl(g_rec_lines.array_calculate_g_l_flag(g_LineNumber), 'N')='N' AND
      g_rec_lines.array_natural_side_code(g_LineNumber) = 'G') THEN

   IF g_rec_lines.array_ledger_amount(g_LineNumber) IS NULL THEN
      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
      xla_accounting_err_pkg.build_message
           (p_appli_s_name            => 'XLA'
           ,p_msg_name                => 'XLA_AP_NO_LEDGER_AMOUNT'
           ,p_token_1                 => 'LINE_NUMBER'
           ,p_value_1                 =>  g_ExtractLine
           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
           ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
   END IF;

END IF;
*/

EXCEPTION
--
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS  THEN
      xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_lines_pkg.CopyLineInfo');
  --
END CopyLineInfo;

/*======================================================================+
|                                                                       |
| Public Procedure-  CopyLineInfo 7109881                               |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE CopyLineInfo(
   p_line_num   NUMBER,
   p_rec_lines t_rec_lines
) IS

   l_log_module         VARCHAR2(240);
   l_rec_lines t_rec_lines; -- added for bug:7109881

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.CopyLineInfo';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'BEGIN of CopyLineInfo(OverLoaded)'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;

--------------------------------------------------------------------------------------------------------------------
--                 g_mpa_recog_lines             g_rec_lines                                                      --
--                        |                           |                                                           --
--                        ---->    p_rec_lines   <-----                                                           --
--                                     |                                                                          --
--                   IF ( g_LineNumber = C_BULK_LIMIT )                                                           --
--                                     |           		                                                  --
--                        --<--TRUE----|----FALSE-->--		                                                  --
--                       |                            |		                                                  --
--                       |                            |		                                                  --
--                    l_rec_lines --->----<------------		                                                  --
--                                     |			                                                  --
--                                     |			                                                  --
--                                g_rec_lines			                                                  --
--								                                                  --
--------------------------------------------------------------------------------------------------------------------

IF( NVL(g_LineNumber,0) = C_BULK_LIMIT)
   THEN
	   -------------------------------------------------------------------------------------------------------
	   -- Copy all information in p_rec_lines from p_line_num to l_rec_lines p_line_num with the following exceptions:
	   -------------------------------------------------------------------------------------------------------
	   --
	   --
	   l_rec_lines.array_ae_header_id(p_line_num) := p_rec_lines.array_ae_header_id(p_line_num);
	   l_rec_lines.array_header_num(p_line_num)   := p_rec_lines.array_header_num(p_line_num);

	   -- =================================================================================================
	   l_rec_lines.array_accounting_class(p_line_num)      := p_rec_lines.array_accounting_class(p_line_num);
	   l_rec_lines.array_rounding_class(p_line_num)        := p_rec_lines.array_rounding_class(p_line_num);
	   l_rec_lines.array_doc_rounding_level(p_line_num)    := p_rec_lines.array_doc_rounding_level(p_line_num);
	   l_rec_lines.array_gain_or_loss_ref(p_line_num):=    p_rec_lines.array_gain_or_loss_ref(p_line_num);
	   l_rec_lines.array_event_class_code(p_line_num)      := p_rec_lines.array_event_class_code(p_line_num);
	   l_rec_lines.array_event_type_code(p_line_num)       := p_rec_lines.array_event_type_code(p_line_num);
	   l_rec_lines.array_line_defn_owner_code(p_line_num)  := p_rec_lines.array_line_defn_owner_code(p_line_num);
	   l_rec_lines.array_line_defn_code(p_line_num)        := p_rec_lines.array_line_defn_code(p_line_num);
	   l_rec_lines.array_accounting_line_code(p_line_num)  := p_rec_lines.array_accounting_line_code(p_line_num);
	   l_rec_lines.array_accounting_line_type(p_line_num)  := p_rec_lines.array_accounting_line_type(p_line_num);
	   l_rec_lines.array_calculate_acctd_flag(p_line_num)  := p_rec_lines.array_calculate_acctd_flag(p_line_num);
	   l_rec_lines.array_calculate_g_l_flag(p_line_num)    := p_rec_lines.array_calculate_g_l_flag(p_line_num);
	   l_rec_lines.array_gain_or_loss_flag(p_line_num)    := p_rec_lines.array_gain_or_loss_flag(p_line_num);

	   --
	   -- following sets the extract line number
	   --
	   l_rec_lines.array_extract_line_num(p_line_num) := p_rec_lines.array_extract_line_num(p_line_num);

	   --
	   -- line flexfield accounts
	   --
	   l_rec_lines.array_ccid_flag(p_line_num)  := p_rec_lines.array_ccid_flag(p_line_num);
	   l_rec_lines.array_ccid(p_line_num)       := p_rec_lines.array_ccid(p_line_num);
	   --
	   l_rec_lines.array_accounting_coa_id(p_line_num)   := p_rec_lines.array_accounting_coa_id(p_line_num);
	   l_rec_lines.array_transaction_coa_id(p_line_num)  := p_rec_lines.array_transaction_coa_id(p_line_num);
	   l_rec_lines.array_sl_coa_mapping_name(p_line_num) := p_rec_lines.array_sl_coa_mapping_name(p_line_num);
	   --
	   l_rec_lines.array_segment1(p_line_num)   := p_rec_lines.array_segment1(p_line_num);
	   l_rec_lines.array_segment2(p_line_num)   := p_rec_lines.array_segment2(p_line_num);
	   l_rec_lines.array_segment3(p_line_num)   := p_rec_lines.array_segment3(p_line_num);
	   l_rec_lines.array_segment4(p_line_num)   := p_rec_lines.array_segment4(p_line_num);
	   l_rec_lines.array_segment5(p_line_num)   := p_rec_lines.array_segment5(p_line_num);
	   l_rec_lines.array_segment6(p_line_num)   := p_rec_lines.array_segment6(p_line_num);
	   l_rec_lines.array_segment7(p_line_num)   := p_rec_lines.array_segment7(p_line_num);
	   l_rec_lines.array_segment8(p_line_num)   := p_rec_lines.array_segment8(p_line_num);
	   l_rec_lines.array_segment9(p_line_num)   := p_rec_lines.array_segment9(p_line_num);
	   l_rec_lines.array_segment10(p_line_num)  := p_rec_lines.array_segment10(p_line_num);
	   l_rec_lines.array_segment11(p_line_num)  := p_rec_lines.array_segment11(p_line_num);
	   l_rec_lines.array_segment12(p_line_num)  := p_rec_lines.array_segment12(p_line_num);
	   l_rec_lines.array_segment13(p_line_num)  := p_rec_lines.array_segment13(p_line_num);
	   l_rec_lines.array_segment14(p_line_num)  := p_rec_lines.array_segment14(p_line_num);
	   l_rec_lines.array_segment15(p_line_num)  := p_rec_lines.array_segment15(p_line_num);
	   l_rec_lines.array_segment16(p_line_num)  := p_rec_lines.array_segment16(p_line_num);
	   l_rec_lines.array_segment17(p_line_num)  := p_rec_lines.array_segment17(p_line_num);
	   l_rec_lines.array_segment18(p_line_num)  := p_rec_lines.array_segment18(p_line_num);
	   l_rec_lines.array_segment19(p_line_num)  := p_rec_lines.array_segment19(p_line_num);
	   l_rec_lines.array_segment20(p_line_num)  := p_rec_lines.array_segment20(p_line_num);
	   l_rec_lines.array_segment21(p_line_num)  := p_rec_lines.array_segment21(p_line_num);
	   l_rec_lines.array_segment22(p_line_num)  := p_rec_lines.array_segment22(p_line_num);
	   l_rec_lines.array_segment23(p_line_num)  := p_rec_lines.array_segment23(p_line_num);
	   l_rec_lines.array_segment24(p_line_num)  := p_rec_lines.array_segment24(p_line_num);
	   l_rec_lines.array_segment25(p_line_num)  := p_rec_lines.array_segment25(p_line_num);
	   l_rec_lines.array_segment26(p_line_num)  := p_rec_lines.array_segment26(p_line_num);
	   l_rec_lines.array_segment27(p_line_num)  := p_rec_lines.array_segment27(p_line_num);
	   l_rec_lines.array_segment28(p_line_num)  := p_rec_lines.array_segment28(p_line_num);
	   l_rec_lines.array_segment29(p_line_num)  := p_rec_lines.array_segment29(p_line_num);
	   l_rec_lines.array_segment30(p_line_num)  := p_rec_lines.array_segment30(p_line_num);
	   --
	   l_rec_lines.alt_array_ccid_flag(p_line_num)  := p_rec_lines.alt_array_ccid_flag(p_line_num);
	   l_rec_lines.alt_array_ccid(p_line_num)       := p_rec_lines.alt_array_ccid(p_line_num);
	   l_rec_lines.alt_array_segment1(p_line_num)   := p_rec_lines.alt_array_segment1(p_line_num);
	   l_rec_lines.alt_array_segment2(p_line_num)   := p_rec_lines.alt_array_segment2(p_line_num);
	   l_rec_lines.alt_array_segment3(p_line_num)   := p_rec_lines.alt_array_segment3(p_line_num);
	   l_rec_lines.alt_array_segment4(p_line_num)   := p_rec_lines.alt_array_segment4(p_line_num);
	   l_rec_lines.alt_array_segment5(p_line_num)   := p_rec_lines.alt_array_segment5(p_line_num);
	   l_rec_lines.alt_array_segment6(p_line_num)   := p_rec_lines.alt_array_segment6(p_line_num);
	   l_rec_lines.alt_array_segment7(p_line_num)   := p_rec_lines.alt_array_segment7(p_line_num);
	   l_rec_lines.alt_array_segment8(p_line_num)   := p_rec_lines.alt_array_segment8(p_line_num);
	   l_rec_lines.alt_array_segment9(p_line_num)   := p_rec_lines.alt_array_segment9(p_line_num);
	   l_rec_lines.alt_array_segment10(p_line_num)  := p_rec_lines.alt_array_segment10(p_line_num);
	   l_rec_lines.alt_array_segment11(p_line_num)  := p_rec_lines.alt_array_segment11(p_line_num);
	   l_rec_lines.alt_array_segment12(p_line_num)  := p_rec_lines.alt_array_segment12(p_line_num);
	   l_rec_lines.alt_array_segment13(p_line_num)  := p_rec_lines.alt_array_segment13(p_line_num);
	   l_rec_lines.alt_array_segment14(p_line_num)  := p_rec_lines.alt_array_segment14(p_line_num);
	   l_rec_lines.alt_array_segment15(p_line_num)  := p_rec_lines.alt_array_segment15(p_line_num);
	   l_rec_lines.alt_array_segment16(p_line_num)  := p_rec_lines.alt_array_segment16(p_line_num);
	   l_rec_lines.alt_array_segment17(p_line_num)  := p_rec_lines.alt_array_segment17(p_line_num);
	   l_rec_lines.alt_array_segment18(p_line_num)  := p_rec_lines.alt_array_segment18(p_line_num);
	   l_rec_lines.alt_array_segment19(p_line_num)  := p_rec_lines.alt_array_segment19(p_line_num);
	   l_rec_lines.alt_array_segment20(p_line_num)  := p_rec_lines.alt_array_segment20(p_line_num);
	   l_rec_lines.alt_array_segment21(p_line_num)  := p_rec_lines.alt_array_segment21(p_line_num);
	   l_rec_lines.alt_array_segment22(p_line_num)  := p_rec_lines.alt_array_segment22(p_line_num);
	   l_rec_lines.alt_array_segment23(p_line_num)  := p_rec_lines.alt_array_segment23(p_line_num);
	   l_rec_lines.alt_array_segment24(p_line_num)  := p_rec_lines.alt_array_segment24(p_line_num);
	   l_rec_lines.alt_array_segment25(p_line_num)  := p_rec_lines.alt_array_segment25(p_line_num);
	   l_rec_lines.alt_array_segment26(p_line_num)  := p_rec_lines.alt_array_segment26(p_line_num);
	   l_rec_lines.alt_array_segment27(p_line_num)  := p_rec_lines.alt_array_segment27(p_line_num);
	   l_rec_lines.alt_array_segment28(p_line_num)  := p_rec_lines.alt_array_segment28(p_line_num);
	   l_rec_lines.alt_array_segment29(p_line_num)  := p_rec_lines.alt_array_segment29(p_line_num);
	   l_rec_lines.alt_array_segment30(p_line_num)  := p_rec_lines.alt_array_segment30(p_line_num);
	   --
	   -- Option lines
	   --
	   l_rec_lines.array_gl_transfer_mode(p_line_num)      := p_rec_lines.array_gl_transfer_mode(p_line_num);
	   l_rec_lines.array_natural_side_code(p_line_num)     := p_rec_lines.array_natural_side_code(p_line_num);
	   l_rec_lines.array_acct_entry_type_code(p_line_num)  := p_rec_lines.array_acct_entry_type_code(p_line_num);
	   l_rec_lines.array_switch_side_flag(p_line_num)      := p_rec_lines.array_switch_side_flag(p_line_num);
	   l_rec_lines.array_merge_duplicate_code(p_line_num)  := p_rec_lines.array_merge_duplicate_code(p_line_num);
	   --
	   -- line amounts
	   --
	   l_rec_lines.array_entered_amount(p_line_num)        := p_rec_lines.array_entered_amount(p_line_num);
	   l_rec_lines.array_ledger_amount(p_line_num)         := p_rec_lines.array_ledger_amount(p_line_num);
	   l_rec_lines.array_entered_dr(p_line_num)            := p_rec_lines.array_entered_dr(p_line_num);
	   l_rec_lines.array_entered_cr(p_line_num)            := p_rec_lines.array_entered_cr(p_line_num);
	   l_rec_lines.array_accounted_dr(p_line_num)          := p_rec_lines.array_accounted_dr(p_line_num);
	   l_rec_lines.array_accounted_cr(p_line_num)          := p_rec_lines.array_accounted_cr(p_line_num);
	   l_rec_lines.array_currency_code(p_line_num)         := p_rec_lines.array_currency_code(p_line_num);
	   l_rec_lines.array_currency_mau(p_line_num)          := xla_accounting_cache_pkg.GetCurrencyMau(p_rec_lines.array_currency_code(p_line_num));
	   l_rec_lines.array_curr_conversion_date(p_line_num)  := p_rec_lines.array_curr_conversion_date(p_line_num);
	   l_rec_lines.array_curr_conversion_rate(p_line_num)  := p_rec_lines.array_curr_conversion_rate(p_line_num);
	   l_rec_lines.array_curr_conversion_type(p_line_num)  := p_rec_lines.array_curr_conversion_type(p_line_num);
	   l_rec_lines.array_description(p_line_num)           := p_rec_lines.array_description(p_line_num);
	   --
	   -- line descriptions
	   --
	   l_rec_lines.array_party_id(p_line_num)              := p_rec_lines.array_party_id(p_line_num);
	   l_rec_lines.array_party_site_id(p_line_num)         := p_rec_lines.array_party_site_id(p_line_num);
	   l_rec_lines.array_party_type_code(p_line_num)       := p_rec_lines.array_party_type_code(p_line_num);
	   --
	   l_rec_lines.array_statistical_amount(p_line_num)    := p_rec_lines.array_statistical_amount(p_line_num);
	   l_rec_lines.array_ussgl_transaction(p_line_num)     := p_rec_lines.array_ussgl_transaction(p_line_num);
	   --
	   l_rec_lines.array_jgzz_recon_ref(p_line_num)           := p_rec_lines.array_jgzz_recon_ref(p_line_num);
	   --
	   -- distribution links
	   --
	   l_rec_lines.array_distribution_id_char_1(p_line_num)  := p_rec_lines.array_distribution_id_char_1(p_line_num);
	   l_rec_lines.array_distribution_id_char_2(p_line_num)  := p_rec_lines.array_distribution_id_char_2(p_line_num);
	   l_rec_lines.array_distribution_id_char_3(p_line_num)  := p_rec_lines.array_distribution_id_char_3(p_line_num);
	   l_rec_lines.array_distribution_id_char_4(p_line_num)  := p_rec_lines.array_distribution_id_char_4(p_line_num);
	   l_rec_lines.array_distribution_id_char_5(p_line_num)  := p_rec_lines.array_distribution_id_char_5(p_line_num);
	   l_rec_lines.array_distribution_id_num_1(p_line_num)   := p_rec_lines.array_distribution_id_num_1(p_line_num);
	   l_rec_lines.array_distribution_id_num_2(p_line_num)   := p_rec_lines.array_distribution_id_num_2(p_line_num);
	   l_rec_lines.array_distribution_id_num_3(p_line_num)   := p_rec_lines.array_distribution_id_num_3(p_line_num);
	   l_rec_lines.array_distribution_id_num_4(p_line_num)   := p_rec_lines.array_distribution_id_num_4(p_line_num);
	   l_rec_lines.array_distribution_id_num_5(p_line_num)   := p_rec_lines.array_distribution_id_num_5(p_line_num);
	   l_rec_lines.array_sys_distribution_type(p_line_num)   := p_rec_lines.array_sys_distribution_type(p_line_num);
	   --
	   -- reverse distribution links
	   --
	   l_rec_lines.array_rev_dist_id_char_1(p_line_num)  := p_rec_lines.array_rev_dist_id_char_1(p_line_num);
	   l_rec_lines.array_rev_dist_id_char_2(p_line_num)  := p_rec_lines.array_rev_dist_id_char_2(p_line_num);
	   l_rec_lines.array_rev_dist_id_char_3(p_line_num)  := p_rec_lines.array_rev_dist_id_char_3(p_line_num);
	   l_rec_lines.array_rev_dist_id_char_4(p_line_num)  := p_rec_lines.array_rev_dist_id_char_4(p_line_num);
	   l_rec_lines.array_rev_dist_id_char_5(p_line_num)  := p_rec_lines.array_rev_dist_id_char_5(p_line_num);
	   l_rec_lines.array_rev_dist_id_num_1(p_line_num)   := p_rec_lines.array_rev_dist_id_num_1(p_line_num);
	   l_rec_lines.array_rev_dist_id_num_2(p_line_num)   := p_rec_lines.array_rev_dist_id_num_2(p_line_num);
	   l_rec_lines.array_rev_dist_id_num_3(p_line_num)   := p_rec_lines.array_rev_dist_id_num_3(p_line_num);
	   l_rec_lines.array_rev_dist_id_num_4(p_line_num)   := p_rec_lines.array_rev_dist_id_num_4(p_line_num);
	   l_rec_lines.array_rev_dist_id_num_5(p_line_num)   := p_rec_lines.array_rev_dist_id_num_5(p_line_num);
	   l_rec_lines.array_rev_dist_type(p_line_num)       := p_rec_lines.array_rev_dist_type(p_line_num);
	   --
	   -- multiperiod accounting
	   --
	   -- DO NOT COPY p_rec_lines.array_mpa_acc_entry_flag
	   l_rec_lines.array_header_num(p_line_num)          := p_rec_lines.array_header_num(p_line_num);
	   l_rec_lines.array_mpa_option(p_line_num)          := p_rec_lines.array_mpa_option(p_line_num);
	   l_rec_lines.array_mpa_start_date(p_line_num)      := p_rec_lines.array_mpa_start_date(p_line_num);
	   l_rec_lines.array_mpa_end_date(p_line_num)        := p_rec_lines.array_mpa_end_date(p_line_num);
	   --
	   -- reversal info
	   --
	   l_rec_lines.array_acc_reversal_option(p_line_num)   := p_rec_lines.array_acc_reversal_option(p_line_num);
	   --
	   -- tax info
	   --
	   l_rec_lines.array_tax_line_ref(p_line_num)           := p_rec_lines.array_tax_line_ref(p_line_num);
	   l_rec_lines.array_tax_summary_line_ref(p_line_num)   := p_rec_lines.array_tax_summary_line_ref(p_line_num);
	   l_rec_lines.array_tax_rec_nrec_dist_ref(p_line_num)  := p_rec_lines.array_tax_rec_nrec_dist_ref(p_line_num);
	   --
	   --
	   l_rec_lines.array_anc_balance_flag(p_line_num)      := p_rec_lines.array_anc_balance_flag(p_line_num);
	   l_rec_lines.array_anc_id_1(p_line_num)              := p_rec_lines.array_anc_id_1(p_line_num);
	   l_rec_lines.array_anc_id_2(p_line_num)              := p_rec_lines.array_anc_id_2(p_line_num);
	   l_rec_lines.array_anc_id_3(p_line_num)              := p_rec_lines.array_anc_id_3(p_line_num);
	   l_rec_lines.array_anc_id_4(p_line_num)              := p_rec_lines.array_anc_id_4(p_line_num);
	   l_rec_lines.array_anc_id_5(p_line_num)              := p_rec_lines.array_anc_id_5(p_line_num);
	   l_rec_lines.array_anc_id_6(p_line_num)              := p_rec_lines.array_anc_id_6(p_line_num);
	   l_rec_lines.array_anc_id_7(p_line_num)              := p_rec_lines.array_anc_id_7(p_line_num);
	   l_rec_lines.array_anc_id_8(p_line_num)              := p_rec_lines.array_anc_id_8(p_line_num);
	   l_rec_lines.array_anc_id_9(p_line_num)              := p_rec_lines.array_anc_id_9(p_line_num);
	   l_rec_lines.array_anc_id_10(p_line_num)             := p_rec_lines.array_anc_id_10(p_line_num);
	   l_rec_lines.array_anc_id_11(p_line_num)             := p_rec_lines.array_anc_id_11(p_line_num);
	   l_rec_lines.array_anc_id_12(p_line_num)             := p_rec_lines.array_anc_id_12(p_line_num);
	   l_rec_lines.array_anc_id_13(p_line_num)             := p_rec_lines.array_anc_id_13(p_line_num);
	   l_rec_lines.array_anc_id_14(p_line_num)             := p_rec_lines.array_anc_id_14(p_line_num);
	   l_rec_lines.array_anc_id_15(p_line_num)             := p_rec_lines.array_anc_id_15(p_line_num);
	   l_rec_lines.array_anc_id_16(p_line_num)             := p_rec_lines.array_anc_id_16(p_line_num);
	   l_rec_lines.array_anc_id_17(p_line_num)             := p_rec_lines.array_anc_id_17(p_line_num);
	   l_rec_lines.array_anc_id_18(p_line_num)             := p_rec_lines.array_anc_id_18(p_line_num);
	   l_rec_lines.array_anc_id_19(p_line_num)             := p_rec_lines.array_anc_id_19(p_line_num);
	   l_rec_lines.array_anc_id_20(p_line_num)             := p_rec_lines.array_anc_id_20(p_line_num);
	   l_rec_lines.array_anc_id_21(p_line_num)             := p_rec_lines.array_anc_id_21(p_line_num);
	   l_rec_lines.array_anc_id_22(p_line_num)             := p_rec_lines.array_anc_id_22(p_line_num);
	   l_rec_lines.array_anc_id_23(p_line_num)             := p_rec_lines.array_anc_id_23(p_line_num);
	   l_rec_lines.array_anc_id_24(p_line_num)             := p_rec_lines.array_anc_id_24(p_line_num);
	   l_rec_lines.array_anc_id_25(p_line_num)             := p_rec_lines.array_anc_id_25(p_line_num);
	   l_rec_lines.array_anc_id_26(p_line_num)             := p_rec_lines.array_anc_id_26(p_line_num);
	   l_rec_lines.array_anc_id_27(p_line_num)             := p_rec_lines.array_anc_id_27(p_line_num);
	   l_rec_lines.array_anc_id_28(p_line_num)             := p_rec_lines.array_anc_id_28(p_line_num);
	   l_rec_lines.array_anc_id_29(p_line_num)             := p_rec_lines.array_anc_id_29(p_line_num);
	   l_rec_lines.array_anc_id_30(p_line_num)             := p_rec_lines.array_anc_id_30(p_line_num);
	   l_rec_lines.array_anc_id_31(p_line_num)             := p_rec_lines.array_anc_id_31(p_line_num);
	   l_rec_lines.array_anc_id_32(p_line_num)             := p_rec_lines.array_anc_id_32(p_line_num);
	   l_rec_lines.array_anc_id_33(p_line_num)             := p_rec_lines.array_anc_id_33(p_line_num);
	   l_rec_lines.array_anc_id_34(p_line_num)             := p_rec_lines.array_anc_id_34(p_line_num);
	   l_rec_lines.array_anc_id_35(p_line_num)             := p_rec_lines.array_anc_id_35(p_line_num);
	   l_rec_lines.array_anc_id_36(p_line_num)             := p_rec_lines.array_anc_id_36(p_line_num);
	   l_rec_lines.array_anc_id_37(p_line_num)             := p_rec_lines.array_anc_id_37(p_line_num);
	   l_rec_lines.array_anc_id_38(p_line_num)             := p_rec_lines.array_anc_id_38(p_line_num);
	   l_rec_lines.array_anc_id_39(p_line_num)             := p_rec_lines.array_anc_id_39(p_line_num);
	   l_rec_lines.array_anc_id_40(p_line_num)             := p_rec_lines.array_anc_id_40(p_line_num);
	   l_rec_lines.array_anc_id_41(p_line_num)             := p_rec_lines.array_anc_id_41(p_line_num);
	   l_rec_lines.array_anc_id_42(p_line_num)             := p_rec_lines.array_anc_id_42(p_line_num);
	   l_rec_lines.array_anc_id_43(p_line_num)             := p_rec_lines.array_anc_id_43(p_line_num);
	   l_rec_lines.array_anc_id_44(p_line_num)             := p_rec_lines.array_anc_id_44(p_line_num);
	   l_rec_lines.array_anc_id_45(p_line_num)             := p_rec_lines.array_anc_id_45(p_line_num);
	   l_rec_lines.array_anc_id_46(p_line_num)             := p_rec_lines.array_anc_id_46(p_line_num);
	   l_rec_lines.array_anc_id_47(p_line_num)             := p_rec_lines.array_anc_id_47(p_line_num);
	   l_rec_lines.array_anc_id_48(p_line_num)             := p_rec_lines.array_anc_id_48(p_line_num);
	   l_rec_lines.array_anc_id_49(p_line_num)             := p_rec_lines.array_anc_id_49(p_line_num);
	   l_rec_lines.array_anc_id_50(p_line_num)             := p_rec_lines.array_anc_id_50(p_line_num);
	   l_rec_lines.array_anc_id_51(p_line_num)             := p_rec_lines.array_anc_id_51(p_line_num);
	   l_rec_lines.array_anc_id_52(p_line_num)             := p_rec_lines.array_anc_id_52(p_line_num);
	   l_rec_lines.array_anc_id_53(p_line_num)             := p_rec_lines.array_anc_id_53(p_line_num);
	   l_rec_lines.array_anc_id_54(p_line_num)             := p_rec_lines.array_anc_id_54(p_line_num);
	   l_rec_lines.array_anc_id_55(p_line_num)             := p_rec_lines.array_anc_id_55(p_line_num);
	   l_rec_lines.array_anc_id_56(p_line_num)             := p_rec_lines.array_anc_id_56(p_line_num);
	   l_rec_lines.array_anc_id_57(p_line_num)             := p_rec_lines.array_anc_id_57(p_line_num);
	   l_rec_lines.array_anc_id_58(p_line_num)             := p_rec_lines.array_anc_id_58(p_line_num);
	   l_rec_lines.array_anc_id_59(p_line_num)             := p_rec_lines.array_anc_id_59(p_line_num);
	   l_rec_lines.array_anc_id_60(p_line_num)             := p_rec_lines.array_anc_id_60(p_line_num);
	   l_rec_lines.array_anc_id_61(p_line_num)             := p_rec_lines.array_anc_id_61(p_line_num);
	   l_rec_lines.array_anc_id_62(p_line_num)             := p_rec_lines.array_anc_id_62(p_line_num);
	   l_rec_lines.array_anc_id_63(p_line_num)             := p_rec_lines.array_anc_id_63(p_line_num);
	   l_rec_lines.array_anc_id_64(p_line_num)             := p_rec_lines.array_anc_id_64(p_line_num);
	   l_rec_lines.array_anc_id_65(p_line_num)             := p_rec_lines.array_anc_id_65(p_line_num);
	   l_rec_lines.array_anc_id_66(p_line_num)             := p_rec_lines.array_anc_id_66(p_line_num);
	   l_rec_lines.array_anc_id_67(p_line_num)             := p_rec_lines.array_anc_id_67(p_line_num);
	   l_rec_lines.array_anc_id_68(p_line_num)             := p_rec_lines.array_anc_id_68(p_line_num);
	   l_rec_lines.array_anc_id_69(p_line_num)             := p_rec_lines.array_anc_id_69(p_line_num);
	   l_rec_lines.array_anc_id_70(p_line_num)             := p_rec_lines.array_anc_id_70(p_line_num);
	   l_rec_lines.array_anc_id_71(p_line_num)             := p_rec_lines.array_anc_id_71(p_line_num);
	   l_rec_lines.array_anc_id_72(p_line_num)             := p_rec_lines.array_anc_id_72(p_line_num);
	   l_rec_lines.array_anc_id_73(p_line_num)             := p_rec_lines.array_anc_id_73(p_line_num);
	   l_rec_lines.array_anc_id_74(p_line_num)             := p_rec_lines.array_anc_id_74(p_line_num);
	   l_rec_lines.array_anc_id_75(p_line_num)             := p_rec_lines.array_anc_id_75(p_line_num);
	   l_rec_lines.array_anc_id_76(p_line_num)             := p_rec_lines.array_anc_id_76(p_line_num);
	   l_rec_lines.array_anc_id_77(p_line_num)             := p_rec_lines.array_anc_id_77(p_line_num);
	   l_rec_lines.array_anc_id_78(p_line_num)             := p_rec_lines.array_anc_id_78(p_line_num);
	   l_rec_lines.array_anc_id_79(p_line_num)             := p_rec_lines.array_anc_id_79(p_line_num);
	   l_rec_lines.array_anc_id_80(p_line_num)             := p_rec_lines.array_anc_id_80(p_line_num);
	   l_rec_lines.array_anc_id_81(p_line_num)             := p_rec_lines.array_anc_id_81(p_line_num);
	   l_rec_lines.array_anc_id_82(p_line_num)             := p_rec_lines.array_anc_id_82(p_line_num);
	   l_rec_lines.array_anc_id_83(p_line_num)             := p_rec_lines.array_anc_id_83(p_line_num);
	   l_rec_lines.array_anc_id_84(p_line_num)             := p_rec_lines.array_anc_id_84(p_line_num);
	   l_rec_lines.array_anc_id_85(p_line_num)             := p_rec_lines.array_anc_id_85(p_line_num);
	   l_rec_lines.array_anc_id_86(p_line_num)             := p_rec_lines.array_anc_id_86(p_line_num);
	   l_rec_lines.array_anc_id_87(p_line_num)             := p_rec_lines.array_anc_id_87(p_line_num);
	   l_rec_lines.array_anc_id_88(p_line_num)             := p_rec_lines.array_anc_id_88(p_line_num);
	   l_rec_lines.array_anc_id_89(p_line_num)             := p_rec_lines.array_anc_id_89(p_line_num);
	   l_rec_lines.array_anc_id_90(p_line_num)             := p_rec_lines.array_anc_id_90(p_line_num);
	   l_rec_lines.array_anc_id_91(p_line_num)             := p_rec_lines.array_anc_id_91(p_line_num);
	   l_rec_lines.array_anc_id_92(p_line_num)             := p_rec_lines.array_anc_id_92(p_line_num);
	   l_rec_lines.array_anc_id_93(p_line_num)             := p_rec_lines.array_anc_id_93(p_line_num);
	   l_rec_lines.array_anc_id_94(p_line_num)             := p_rec_lines.array_anc_id_94(p_line_num);
	   l_rec_lines.array_anc_id_95(p_line_num)             := p_rec_lines.array_anc_id_95(p_line_num);
	   l_rec_lines.array_anc_id_96(p_line_num)             := p_rec_lines.array_anc_id_96(p_line_num);
	   l_rec_lines.array_anc_id_97(p_line_num)             := p_rec_lines.array_anc_id_97(p_line_num);
	   l_rec_lines.array_anc_id_98(p_line_num)             := p_rec_lines.array_anc_id_98(p_line_num);
	   l_rec_lines.array_anc_id_99(p_line_num)             := p_rec_lines.array_anc_id_99(p_line_num);
	   l_rec_lines.array_anc_id_100(p_line_num)            := p_rec_lines.array_anc_id_100(p_line_num);
	   --
	   --
	   l_rec_lines.array_event_number(p_line_num)          := p_rec_lines.array_event_number(p_line_num);
	   l_rec_lines.array_entity_id(p_line_num)             := p_rec_lines.array_entity_id(p_line_num);
	   l_rec_lines.array_reversal_code(p_line_num)         := p_rec_lines.array_reversal_code(p_line_num);
	   l_rec_lines.array_balance_type_code(p_line_num)     := p_rec_lines.array_balance_type_code(p_line_num);
	   l_rec_lines.array_ledger_id(p_line_num)             := p_rec_lines.array_ledger_id(p_line_num);
	   --
	   -- business flow
	   --
	   l_rec_lines.array_business_method_code(p_line_num)   := p_rec_lines.array_business_method_code(p_line_num);
	   l_rec_lines.array_business_class_code(p_line_num)    := p_rec_lines.array_business_class_code(p_line_num);
	   l_rec_lines.array_inherit_desc_flag(p_line_num)      := p_rec_lines.array_inherit_desc_flag(p_line_num);
	   l_rec_lines.array_bflow_application_id(p_line_num)   := p_rec_lines.array_bflow_application_id(p_line_num);

	   l_rec_lines.array_bflow_entity_code(p_line_num)      := p_rec_lines.array_bflow_entity_code(p_line_num);
	   l_rec_lines.array_bflow_source_id_num_1(p_line_num)  := p_rec_lines.array_bflow_source_id_num_1(p_line_num);
	   l_rec_lines.array_bflow_source_id_num_2(p_line_num)  := p_rec_lines.array_bflow_source_id_num_2(p_line_num);
	   l_rec_lines.array_bflow_source_id_num_3(p_line_num)  := p_rec_lines.array_bflow_source_id_num_3(p_line_num);
	   l_rec_lines.array_bflow_source_id_num_4(p_line_num)  := p_rec_lines.array_bflow_source_id_num_4(p_line_num);
	   l_rec_lines.array_bflow_source_id_char_1(p_line_num) := p_rec_lines.array_bflow_source_id_char_1(p_line_num);
	   l_rec_lines.array_bflow_source_id_char_2(p_line_num) := p_rec_lines.array_bflow_source_id_char_2(p_line_num);
	   l_rec_lines.array_bflow_source_id_char_3(p_line_num) := p_rec_lines.array_bflow_source_id_char_3(p_line_num);
	   l_rec_lines.array_bflow_source_id_char_4(p_line_num) := p_rec_lines.array_bflow_source_id_char_4(p_line_num);

	   l_rec_lines.array_bflow_distribution_type(p_line_num):= p_rec_lines.array_bflow_distribution_type(p_line_num);
	   l_rec_lines.array_bflow_dist_id_num_1(p_line_num)    := p_rec_lines.array_bflow_dist_id_num_1(p_line_num);
	   l_rec_lines.array_bflow_dist_id_num_2(p_line_num)    := p_rec_lines.array_bflow_dist_id_num_2(p_line_num);
	   l_rec_lines.array_bflow_dist_id_num_3(p_line_num)    := p_rec_lines.array_bflow_dist_id_num_3(p_line_num);
	   l_rec_lines.array_bflow_dist_id_num_4(p_line_num)    := p_rec_lines.array_bflow_dist_id_num_4(p_line_num);
	   l_rec_lines.array_bflow_dist_id_num_5(p_line_num)    := p_rec_lines.array_bflow_dist_id_num_5(p_line_num);
	   l_rec_lines.array_bflow_dist_id_char_1(p_line_num)   := p_rec_lines.array_bflow_dist_id_char_1(p_line_num);
	   l_rec_lines.array_bflow_dist_id_char_2(p_line_num)   := p_rec_lines.array_bflow_dist_id_char_2(p_line_num);
	   l_rec_lines.array_bflow_dist_id_char_3(p_line_num)   := p_rec_lines.array_bflow_dist_id_char_3(p_line_num);
	   l_rec_lines.array_bflow_dist_id_char_4(p_line_num)   := p_rec_lines.array_bflow_dist_id_char_4(p_line_num);
	   l_rec_lines.array_bflow_dist_id_char_5(p_line_num)   := p_rec_lines.array_bflow_dist_id_char_5(p_line_num);

	   l_rec_lines.array_override_acctd_amt_flag(p_line_num)   := p_rec_lines.array_override_acctd_amt_flag(p_line_num);


	   l_rec_lines.array_bflow_applied_to_amt(p_line_num)   := p_rec_lines.array_bflow_applied_to_amt(p_line_num); -- 5132302
	   --
	   -- Allocation Attributes
	   --
	   l_rec_lines.array_alloct_application_id(p_line_num)   := p_rec_lines.array_alloct_application_id(p_line_num);

	   l_rec_lines.array_alloct_entity_code(p_line_num)      := p_rec_lines.array_alloct_entity_code(p_line_num);
	   l_rec_lines.array_alloct_source_id_num_1(p_line_num)  := p_rec_lines.array_alloct_source_id_num_1(p_line_num);
	   l_rec_lines.array_alloct_source_id_num_2(p_line_num)  := p_rec_lines.array_alloct_source_id_num_2(p_line_num);
	   l_rec_lines.array_alloct_source_id_num_3(p_line_num)  := p_rec_lines.array_alloct_source_id_num_3(p_line_num);
	   l_rec_lines.array_alloct_source_id_num_4(p_line_num)  := p_rec_lines.array_alloct_source_id_num_4(p_line_num);
	   l_rec_lines.array_alloct_source_id_char_1(p_line_num) := p_rec_lines.array_alloct_source_id_char_1(p_line_num);
	   l_rec_lines.array_alloct_source_id_char_2(p_line_num) := p_rec_lines.array_alloct_source_id_char_2(p_line_num);
	   l_rec_lines.array_alloct_source_id_char_3(p_line_num) := p_rec_lines.array_alloct_source_id_char_3(p_line_num);
	   l_rec_lines.array_alloct_source_id_char_4(p_line_num) := p_rec_lines.array_alloct_source_id_char_4(p_line_num);

	   l_rec_lines.array_alloct_distribution_type(p_line_num):= p_rec_lines.array_alloct_distribution_type(p_line_num);
	   l_rec_lines.array_alloct_dist_id_num_1(p_line_num)    := p_rec_lines.array_alloct_dist_id_num_1(p_line_num);
	   l_rec_lines.array_alloct_dist_id_num_2(p_line_num)    := p_rec_lines.array_alloct_dist_id_num_2(p_line_num);
	   l_rec_lines.array_alloct_dist_id_num_3(p_line_num)    := p_rec_lines.array_alloct_dist_id_num_3(p_line_num);
	   l_rec_lines.array_alloct_dist_id_num_4(p_line_num)    := p_rec_lines.array_alloct_dist_id_num_4(p_line_num);
	   l_rec_lines.array_alloct_dist_id_num_5(p_line_num)    := p_rec_lines.array_alloct_dist_id_num_5(p_line_num);
	   l_rec_lines.array_alloct_dist_id_char_1(p_line_num)   := p_rec_lines.array_alloct_dist_id_char_1(p_line_num);
	   l_rec_lines.array_alloct_dist_id_char_2(p_line_num)   := p_rec_lines.array_alloct_dist_id_char_2(p_line_num);
	   l_rec_lines.array_alloct_dist_id_char_3(p_line_num)   := p_rec_lines.array_alloct_dist_id_char_3(p_line_num);
	   l_rec_lines.array_alloct_dist_id_char_4(p_line_num)   := p_rec_lines.array_alloct_dist_id_char_4(p_line_num);
	   l_rec_lines.array_alloct_dist_id_char_5(p_line_num)   := p_rec_lines.array_alloct_dist_id_char_5(p_line_num);

	   l_rec_lines.array_upg_cr_enc_type_id(p_line_num)      := p_rec_lines.array_upg_cr_enc_type_id(p_line_num);
	   l_rec_lines.array_upg_dr_enc_type_id(p_line_num)      := p_rec_lines.array_upg_dr_enc_type_id(p_line_num);
	   l_rec_lines.array_actual_upg_option(p_line_num)       := p_rec_lines.array_actual_upg_option(p_line_num);
	   l_rec_lines.array_enc_upg_option(p_line_num)          := p_rec_lines.array_enc_upg_option(p_line_num);

ELSE

           l_rec_lines := p_rec_lines ;

END IF ;

	   SetNewLine;


	   -------------------------------------------------------------------------------------------------------
	   -- Copy all information in l_rec_lines from p_line_num to g_LineNumber
	   -------------------------------------------------------------------------------------------------------

	   g_rec_lines.array_ae_header_id(g_LineNumber) := l_rec_lines.array_ae_header_id(p_line_num);
	   g_rec_lines.array_header_num(g_LineNumber)   := l_rec_lines.array_header_num(p_line_num);

	   -- =================================================================================================
	   g_rec_lines.array_accounting_class(g_LineNumber)      := l_rec_lines.array_accounting_class(p_line_num);
	   g_rec_lines.array_rounding_class(g_LineNumber)        := l_rec_lines.array_rounding_class(p_line_num);
	   g_rec_lines.array_doc_rounding_level(g_LineNumber)    := l_rec_lines.array_doc_rounding_level(p_line_num);
	   g_rec_lines.array_gain_or_loss_ref(g_LineNumber):=    l_rec_lines.array_gain_or_loss_ref(p_line_num);
	   g_rec_lines.array_event_class_code(g_LineNumber)      := l_rec_lines.array_event_class_code(p_line_num);
	   g_rec_lines.array_event_type_code(g_LineNumber)       := l_rec_lines.array_event_type_code(p_line_num);
	   g_rec_lines.array_line_defn_owner_code(g_LineNumber)  := l_rec_lines.array_line_defn_owner_code(p_line_num);
	   g_rec_lines.array_line_defn_code(g_LineNumber)        := l_rec_lines.array_line_defn_code(p_line_num);
	   g_rec_lines.array_accounting_line_code(g_LineNumber)  := l_rec_lines.array_accounting_line_code(p_line_num);
	   g_rec_lines.array_accounting_line_type(g_LineNumber)  := l_rec_lines.array_accounting_line_type(p_line_num);
	   g_rec_lines.array_calculate_acctd_flag(g_LineNumber)  := l_rec_lines.array_calculate_acctd_flag(p_line_num);
	   g_rec_lines.array_calculate_g_l_flag(g_LineNumber)    := l_rec_lines.array_calculate_g_l_flag(p_line_num);
	   g_rec_lines.array_gain_or_loss_flag(g_LineNumber)    := l_rec_lines.array_gain_or_loss_flag(p_line_num);

	   --
	   -- following sets the extract line number
	   --
	   g_rec_lines.array_extract_line_num(g_LineNumber) := l_rec_lines.array_extract_line_num(p_line_num);

	   --
	   -- line flexfield accounts
	   --
	   g_rec_lines.array_ccid_flag(g_LineNumber)  := l_rec_lines.array_ccid_flag(p_line_num);
	   g_rec_lines.array_ccid(g_LineNumber)       := l_rec_lines.array_ccid(p_line_num);
	   --
	   g_rec_lines.array_accounting_coa_id(g_LineNumber)   := l_rec_lines.array_accounting_coa_id(p_line_num);
	   g_rec_lines.array_transaction_coa_id(g_LineNumber)  := l_rec_lines.array_transaction_coa_id(p_line_num);
	   g_rec_lines.array_sl_coa_mapping_name(g_LineNumber) := l_rec_lines.array_sl_coa_mapping_name(p_line_num);
	   --
	   g_rec_lines.array_segment1(g_LineNumber)   := l_rec_lines.array_segment1(p_line_num);
	   g_rec_lines.array_segment2(g_LineNumber)   := l_rec_lines.array_segment2(p_line_num);
	   g_rec_lines.array_segment3(g_LineNumber)   := l_rec_lines.array_segment3(p_line_num);
	   g_rec_lines.array_segment4(g_LineNumber)   := l_rec_lines.array_segment4(p_line_num);
	   g_rec_lines.array_segment5(g_LineNumber)   := l_rec_lines.array_segment5(p_line_num);
	   g_rec_lines.array_segment6(g_LineNumber)   := l_rec_lines.array_segment6(p_line_num);
	   g_rec_lines.array_segment7(g_LineNumber)   := l_rec_lines.array_segment7(p_line_num);
	   g_rec_lines.array_segment8(g_LineNumber)   := l_rec_lines.array_segment8(p_line_num);
	   g_rec_lines.array_segment9(g_LineNumber)   := l_rec_lines.array_segment9(p_line_num);
	   g_rec_lines.array_segment10(g_LineNumber)  := l_rec_lines.array_segment10(p_line_num);
	   g_rec_lines.array_segment11(g_LineNumber)  := l_rec_lines.array_segment11(p_line_num);
	   g_rec_lines.array_segment12(g_LineNumber)  := l_rec_lines.array_segment12(p_line_num);
	   g_rec_lines.array_segment13(g_LineNumber)  := l_rec_lines.array_segment13(p_line_num);
	   g_rec_lines.array_segment14(g_LineNumber)  := l_rec_lines.array_segment14(p_line_num);
	   g_rec_lines.array_segment15(g_LineNumber)  := l_rec_lines.array_segment15(p_line_num);
	   g_rec_lines.array_segment16(g_LineNumber)  := l_rec_lines.array_segment16(p_line_num);
	   g_rec_lines.array_segment17(g_LineNumber)  := l_rec_lines.array_segment17(p_line_num);
	   g_rec_lines.array_segment18(g_LineNumber)  := l_rec_lines.array_segment18(p_line_num);
	   g_rec_lines.array_segment19(g_LineNumber)  := l_rec_lines.array_segment19(p_line_num);
	   g_rec_lines.array_segment20(g_LineNumber)  := l_rec_lines.array_segment20(p_line_num);
	   g_rec_lines.array_segment21(g_LineNumber)  := l_rec_lines.array_segment21(p_line_num);
	   g_rec_lines.array_segment22(g_LineNumber)  := l_rec_lines.array_segment22(p_line_num);
	   g_rec_lines.array_segment23(g_LineNumber)  := l_rec_lines.array_segment23(p_line_num);
	   g_rec_lines.array_segment24(g_LineNumber)  := l_rec_lines.array_segment24(p_line_num);
	   g_rec_lines.array_segment25(g_LineNumber)  := l_rec_lines.array_segment25(p_line_num);
	   g_rec_lines.array_segment26(g_LineNumber)  := l_rec_lines.array_segment26(p_line_num);
	   g_rec_lines.array_segment27(g_LineNumber)  := l_rec_lines.array_segment27(p_line_num);
	   g_rec_lines.array_segment28(g_LineNumber)  := l_rec_lines.array_segment28(p_line_num);
	   g_rec_lines.array_segment29(g_LineNumber)  := l_rec_lines.array_segment29(p_line_num);
	   g_rec_lines.array_segment30(g_LineNumber)  := l_rec_lines.array_segment30(p_line_num);
	   --
	   g_rec_lines.alt_array_ccid_flag(g_LineNumber)  := l_rec_lines.alt_array_ccid_flag(p_line_num);
	   g_rec_lines.alt_array_ccid(g_LineNumber)       := l_rec_lines.alt_array_ccid(p_line_num);
	   g_rec_lines.alt_array_segment1(g_LineNumber)   := l_rec_lines.alt_array_segment1(p_line_num);
	   g_rec_lines.alt_array_segment2(g_LineNumber)   := l_rec_lines.alt_array_segment2(p_line_num);
	   g_rec_lines.alt_array_segment3(g_LineNumber)   := l_rec_lines.alt_array_segment3(p_line_num);
	   g_rec_lines.alt_array_segment4(g_LineNumber)   := l_rec_lines.alt_array_segment4(p_line_num);
	   g_rec_lines.alt_array_segment5(g_LineNumber)   := l_rec_lines.alt_array_segment5(p_line_num);
	   g_rec_lines.alt_array_segment6(g_LineNumber)   := l_rec_lines.alt_array_segment6(p_line_num);
	   g_rec_lines.alt_array_segment7(g_LineNumber)   := l_rec_lines.alt_array_segment7(p_line_num);
	   g_rec_lines.alt_array_segment8(g_LineNumber)   := l_rec_lines.alt_array_segment8(p_line_num);
	   g_rec_lines.alt_array_segment9(g_LineNumber)   := l_rec_lines.alt_array_segment9(p_line_num);
	   g_rec_lines.alt_array_segment10(g_LineNumber)  := l_rec_lines.alt_array_segment10(p_line_num);
	   g_rec_lines.alt_array_segment11(g_LineNumber)  := l_rec_lines.alt_array_segment11(p_line_num);
	   g_rec_lines.alt_array_segment12(g_LineNumber)  := l_rec_lines.alt_array_segment12(p_line_num);
	   g_rec_lines.alt_array_segment13(g_LineNumber)  := l_rec_lines.alt_array_segment13(p_line_num);
	   g_rec_lines.alt_array_segment14(g_LineNumber)  := l_rec_lines.alt_array_segment14(p_line_num);
	   g_rec_lines.alt_array_segment15(g_LineNumber)  := l_rec_lines.alt_array_segment15(p_line_num);
	   g_rec_lines.alt_array_segment16(g_LineNumber)  := l_rec_lines.alt_array_segment16(p_line_num);
	   g_rec_lines.alt_array_segment17(g_LineNumber)  := l_rec_lines.alt_array_segment17(p_line_num);
	   g_rec_lines.alt_array_segment18(g_LineNumber)  := l_rec_lines.alt_array_segment18(p_line_num);
	   g_rec_lines.alt_array_segment19(g_LineNumber)  := l_rec_lines.alt_array_segment19(p_line_num);
	   g_rec_lines.alt_array_segment20(g_LineNumber)  := l_rec_lines.alt_array_segment20(p_line_num);
	   g_rec_lines.alt_array_segment21(g_LineNumber)  := l_rec_lines.alt_array_segment21(p_line_num);
	   g_rec_lines.alt_array_segment22(g_LineNumber)  := l_rec_lines.alt_array_segment22(p_line_num);
	   g_rec_lines.alt_array_segment23(g_LineNumber)  := l_rec_lines.alt_array_segment23(p_line_num);
	   g_rec_lines.alt_array_segment24(g_LineNumber)  := l_rec_lines.alt_array_segment24(p_line_num);
	   g_rec_lines.alt_array_segment25(g_LineNumber)  := l_rec_lines.alt_array_segment25(p_line_num);
	   g_rec_lines.alt_array_segment26(g_LineNumber)  := l_rec_lines.alt_array_segment26(p_line_num);
	   g_rec_lines.alt_array_segment27(g_LineNumber)  := l_rec_lines.alt_array_segment27(p_line_num);
	   g_rec_lines.alt_array_segment28(g_LineNumber)  := l_rec_lines.alt_array_segment28(p_line_num);
	   g_rec_lines.alt_array_segment29(g_LineNumber)  := l_rec_lines.alt_array_segment29(p_line_num);
	   g_rec_lines.alt_array_segment30(g_LineNumber)  := l_rec_lines.alt_array_segment30(p_line_num);
	   --
	   -- Option lines
	   --
	   g_rec_lines.array_gl_transfer_mode(g_LineNumber)      := l_rec_lines.array_gl_transfer_mode(p_line_num);
	   g_rec_lines.array_natural_side_code(g_LineNumber)     := l_rec_lines.array_natural_side_code(p_line_num);
	   g_rec_lines.array_acct_entry_type_code(g_LineNumber)  := l_rec_lines.array_acct_entry_type_code(p_line_num);
	   g_rec_lines.array_switch_side_flag(g_LineNumber)      := l_rec_lines.array_switch_side_flag(p_line_num);
	   g_rec_lines.array_merge_duplicate_code(g_LineNumber)  := l_rec_lines.array_merge_duplicate_code(p_line_num);
	   --
	   -- line amounts
	   --
	   g_rec_lines.array_entered_amount(g_LineNumber)        := l_rec_lines.array_entered_amount(p_line_num);
	   g_rec_lines.array_ledger_amount(g_LineNumber)         := l_rec_lines.array_ledger_amount(p_line_num);
	   g_rec_lines.array_entered_dr(g_LineNumber)            := l_rec_lines.array_entered_dr(p_line_num);
	   g_rec_lines.array_entered_cr(g_LineNumber)            := l_rec_lines.array_entered_cr(p_line_num);
	   g_rec_lines.array_accounted_dr(g_LineNumber)          := l_rec_lines.array_accounted_dr(p_line_num);
	   g_rec_lines.array_accounted_cr(g_LineNumber)          := l_rec_lines.array_accounted_cr(p_line_num);
	   g_rec_lines.array_currency_code(g_LineNumber)         := l_rec_lines.array_currency_code(p_line_num);
	   g_rec_lines.array_currency_mau(g_LineNumber)          := xla_accounting_cache_pkg.GetCurrencyMau(g_rec_lines.array_currency_code(g_LineNumber));
	   g_rec_lines.array_curr_conversion_date(g_LineNumber)  := l_rec_lines.array_curr_conversion_date(p_line_num);
	   g_rec_lines.array_curr_conversion_rate(g_LineNumber)  := l_rec_lines.array_curr_conversion_rate(p_line_num);
	   g_rec_lines.array_curr_conversion_type(g_LineNumber)  := l_rec_lines.array_curr_conversion_type(p_line_num);
	   g_rec_lines.array_description(g_LineNumber)           := l_rec_lines.array_description(p_line_num);
	   --
	   -- line descriptions
	   --
	   g_rec_lines.array_party_id(g_LineNumber)              := l_rec_lines.array_party_id(p_line_num);
	   g_rec_lines.array_party_site_id(g_LineNumber)         := l_rec_lines.array_party_site_id(p_line_num);
	   g_rec_lines.array_party_type_code(g_LineNumber)       := l_rec_lines.array_party_type_code(p_line_num);
	   --
	   g_rec_lines.array_statistical_amount(g_LineNumber)    := l_rec_lines.array_statistical_amount(p_line_num);
	   g_rec_lines.array_ussgl_transaction(g_LineNumber)     := l_rec_lines.array_ussgl_transaction(p_line_num);
	   --
	   g_rec_lines.array_jgzz_recon_ref(g_LineNumber)           := l_rec_lines.array_jgzz_recon_ref(p_line_num);
	   --
	   -- distribution links
	   --
	   g_rec_lines.array_distribution_id_char_1(g_LineNumber)  := l_rec_lines.array_distribution_id_char_1(p_line_num);
	   g_rec_lines.array_distribution_id_char_2(g_LineNumber)  := l_rec_lines.array_distribution_id_char_2(p_line_num);
	   g_rec_lines.array_distribution_id_char_3(g_LineNumber)  := l_rec_lines.array_distribution_id_char_3(p_line_num);
	   g_rec_lines.array_distribution_id_char_4(g_LineNumber)  := l_rec_lines.array_distribution_id_char_4(p_line_num);
	   g_rec_lines.array_distribution_id_char_5(g_LineNumber)  := l_rec_lines.array_distribution_id_char_5(p_line_num);
	   g_rec_lines.array_distribution_id_num_1(g_LineNumber)   := l_rec_lines.array_distribution_id_num_1(p_line_num);
	   g_rec_lines.array_distribution_id_num_2(g_LineNumber)   := l_rec_lines.array_distribution_id_num_2(p_line_num);
	   g_rec_lines.array_distribution_id_num_3(g_LineNumber)   := l_rec_lines.array_distribution_id_num_3(p_line_num);
	   g_rec_lines.array_distribution_id_num_4(g_LineNumber)   := l_rec_lines.array_distribution_id_num_4(p_line_num);
	   g_rec_lines.array_distribution_id_num_5(g_LineNumber)   := l_rec_lines.array_distribution_id_num_5(p_line_num);
	   g_rec_lines.array_sys_distribution_type(g_LineNumber)   := l_rec_lines.array_sys_distribution_type(p_line_num);
	   --
	   -- reverse distribution links
	   --
	   g_rec_lines.array_rev_dist_id_char_1(g_LineNumber)  := l_rec_lines.array_rev_dist_id_char_1(p_line_num);
	   g_rec_lines.array_rev_dist_id_char_2(g_LineNumber)  := l_rec_lines.array_rev_dist_id_char_2(p_line_num);
	   g_rec_lines.array_rev_dist_id_char_3(g_LineNumber)  := l_rec_lines.array_rev_dist_id_char_3(p_line_num);
	   g_rec_lines.array_rev_dist_id_char_4(g_LineNumber)  := l_rec_lines.array_rev_dist_id_char_4(p_line_num);
	   g_rec_lines.array_rev_dist_id_char_5(g_LineNumber)  := l_rec_lines.array_rev_dist_id_char_5(p_line_num);
	   g_rec_lines.array_rev_dist_id_num_1(g_LineNumber)   := l_rec_lines.array_rev_dist_id_num_1(p_line_num);
	   g_rec_lines.array_rev_dist_id_num_2(g_LineNumber)   := l_rec_lines.array_rev_dist_id_num_2(p_line_num);
	   g_rec_lines.array_rev_dist_id_num_3(g_LineNumber)   := l_rec_lines.array_rev_dist_id_num_3(p_line_num);
	   g_rec_lines.array_rev_dist_id_num_4(g_LineNumber)   := l_rec_lines.array_rev_dist_id_num_4(p_line_num);
	   g_rec_lines.array_rev_dist_id_num_5(g_LineNumber)   := l_rec_lines.array_rev_dist_id_num_5(p_line_num);
	   g_rec_lines.array_rev_dist_type(g_LineNumber)       := l_rec_lines.array_rev_dist_type(p_line_num);
	   --
	   -- multiperiod accounting
	   --
	   -- DO NOT COPY g_rec_lines.array_mpa_acc_entry_flag
	   g_rec_lines.array_header_num(g_LineNumber)          := l_rec_lines.array_header_num(p_line_num);
	   g_rec_lines.array_mpa_option(g_LineNumber)          := l_rec_lines.array_mpa_option(p_line_num);
	   g_rec_lines.array_mpa_start_date(g_LineNumber)      := l_rec_lines.array_mpa_start_date(p_line_num);
	   g_rec_lines.array_mpa_end_date(g_LineNumber)        := l_rec_lines.array_mpa_end_date(p_line_num);
	   --
	   -- reversal info
	   --
	   g_rec_lines.array_acc_reversal_option(g_LineNumber)   := l_rec_lines.array_acc_reversal_option(p_line_num);
	   --
	   -- tax info
	   --
	   g_rec_lines.array_tax_line_ref(g_LineNumber)           := l_rec_lines.array_tax_line_ref(p_line_num);
	   g_rec_lines.array_tax_summary_line_ref(g_LineNumber)   := l_rec_lines.array_tax_summary_line_ref(p_line_num);
	   g_rec_lines.array_tax_rec_nrec_dist_ref(g_LineNumber)  := l_rec_lines.array_tax_rec_nrec_dist_ref(p_line_num);
	   --
	   --
	   g_rec_lines.array_anc_balance_flag(g_LineNumber)      := l_rec_lines.array_anc_balance_flag(p_line_num);
	   g_rec_lines.array_anc_id_1(g_LineNumber)              := l_rec_lines.array_anc_id_1(p_line_num);
	   g_rec_lines.array_anc_id_2(g_LineNumber)              := l_rec_lines.array_anc_id_2(p_line_num);
	   g_rec_lines.array_anc_id_3(g_LineNumber)              := l_rec_lines.array_anc_id_3(p_line_num);
	   g_rec_lines.array_anc_id_4(g_LineNumber)              := l_rec_lines.array_anc_id_4(p_line_num);
	   g_rec_lines.array_anc_id_5(g_LineNumber)              := l_rec_lines.array_anc_id_5(p_line_num);
	   g_rec_lines.array_anc_id_6(g_LineNumber)              := l_rec_lines.array_anc_id_6(p_line_num);
	   g_rec_lines.array_anc_id_7(g_LineNumber)              := l_rec_lines.array_anc_id_7(p_line_num);
	   g_rec_lines.array_anc_id_8(g_LineNumber)              := l_rec_lines.array_anc_id_8(p_line_num);
	   g_rec_lines.array_anc_id_9(g_LineNumber)              := l_rec_lines.array_anc_id_9(p_line_num);
	   g_rec_lines.array_anc_id_10(g_LineNumber)             := l_rec_lines.array_anc_id_10(p_line_num);
	   g_rec_lines.array_anc_id_11(g_LineNumber)             := l_rec_lines.array_anc_id_11(p_line_num);
	   g_rec_lines.array_anc_id_12(g_LineNumber)             := l_rec_lines.array_anc_id_12(p_line_num);
	   g_rec_lines.array_anc_id_13(g_LineNumber)             := l_rec_lines.array_anc_id_13(p_line_num);
	   g_rec_lines.array_anc_id_14(g_LineNumber)             := l_rec_lines.array_anc_id_14(p_line_num);
	   g_rec_lines.array_anc_id_15(g_LineNumber)             := l_rec_lines.array_anc_id_15(p_line_num);
	   g_rec_lines.array_anc_id_16(g_LineNumber)             := l_rec_lines.array_anc_id_16(p_line_num);
	   g_rec_lines.array_anc_id_17(g_LineNumber)             := l_rec_lines.array_anc_id_17(p_line_num);
	   g_rec_lines.array_anc_id_18(g_LineNumber)             := l_rec_lines.array_anc_id_18(p_line_num);
	   g_rec_lines.array_anc_id_19(g_LineNumber)             := l_rec_lines.array_anc_id_19(p_line_num);
	   g_rec_lines.array_anc_id_20(g_LineNumber)             := l_rec_lines.array_anc_id_20(p_line_num);
	   g_rec_lines.array_anc_id_21(g_LineNumber)             := l_rec_lines.array_anc_id_21(p_line_num);
	   g_rec_lines.array_anc_id_22(g_LineNumber)             := l_rec_lines.array_anc_id_22(p_line_num);
	   g_rec_lines.array_anc_id_23(g_LineNumber)             := l_rec_lines.array_anc_id_23(p_line_num);
	   g_rec_lines.array_anc_id_24(g_LineNumber)             := l_rec_lines.array_anc_id_24(p_line_num);
	   g_rec_lines.array_anc_id_25(g_LineNumber)             := l_rec_lines.array_anc_id_25(p_line_num);
	   g_rec_lines.array_anc_id_26(g_LineNumber)             := l_rec_lines.array_anc_id_26(p_line_num);
	   g_rec_lines.array_anc_id_27(g_LineNumber)             := l_rec_lines.array_anc_id_27(p_line_num);
	   g_rec_lines.array_anc_id_28(g_LineNumber)             := l_rec_lines.array_anc_id_28(p_line_num);
	   g_rec_lines.array_anc_id_29(g_LineNumber)             := l_rec_lines.array_anc_id_29(p_line_num);
	   g_rec_lines.array_anc_id_30(g_LineNumber)             := l_rec_lines.array_anc_id_30(p_line_num);
	   g_rec_lines.array_anc_id_31(g_LineNumber)             := l_rec_lines.array_anc_id_31(p_line_num);
	   g_rec_lines.array_anc_id_32(g_LineNumber)             := l_rec_lines.array_anc_id_32(p_line_num);
	   g_rec_lines.array_anc_id_33(g_LineNumber)             := l_rec_lines.array_anc_id_33(p_line_num);
	   g_rec_lines.array_anc_id_34(g_LineNumber)             := l_rec_lines.array_anc_id_34(p_line_num);
	   g_rec_lines.array_anc_id_35(g_LineNumber)             := l_rec_lines.array_anc_id_35(p_line_num);
	   g_rec_lines.array_anc_id_36(g_LineNumber)             := l_rec_lines.array_anc_id_36(p_line_num);
	   g_rec_lines.array_anc_id_37(g_LineNumber)             := l_rec_lines.array_anc_id_37(p_line_num);
	   g_rec_lines.array_anc_id_38(g_LineNumber)             := l_rec_lines.array_anc_id_38(p_line_num);
	   g_rec_lines.array_anc_id_39(g_LineNumber)             := l_rec_lines.array_anc_id_39(p_line_num);
	   g_rec_lines.array_anc_id_40(g_LineNumber)             := l_rec_lines.array_anc_id_40(p_line_num);
	   g_rec_lines.array_anc_id_41(g_LineNumber)             := l_rec_lines.array_anc_id_41(p_line_num);
	   g_rec_lines.array_anc_id_42(g_LineNumber)             := l_rec_lines.array_anc_id_42(p_line_num);
	   g_rec_lines.array_anc_id_43(g_LineNumber)             := l_rec_lines.array_anc_id_43(p_line_num);
	   g_rec_lines.array_anc_id_44(g_LineNumber)             := l_rec_lines.array_anc_id_44(p_line_num);
	   g_rec_lines.array_anc_id_45(g_LineNumber)             := l_rec_lines.array_anc_id_45(p_line_num);
	   g_rec_lines.array_anc_id_46(g_LineNumber)             := l_rec_lines.array_anc_id_46(p_line_num);
	   g_rec_lines.array_anc_id_47(g_LineNumber)             := l_rec_lines.array_anc_id_47(p_line_num);
	   g_rec_lines.array_anc_id_48(g_LineNumber)             := l_rec_lines.array_anc_id_48(p_line_num);
	   g_rec_lines.array_anc_id_49(g_LineNumber)             := l_rec_lines.array_anc_id_49(p_line_num);
	   g_rec_lines.array_anc_id_50(g_LineNumber)             := l_rec_lines.array_anc_id_50(p_line_num);
	   g_rec_lines.array_anc_id_51(g_LineNumber)             := l_rec_lines.array_anc_id_51(p_line_num);
	   g_rec_lines.array_anc_id_52(g_LineNumber)             := l_rec_lines.array_anc_id_52(p_line_num);
	   g_rec_lines.array_anc_id_53(g_LineNumber)             := l_rec_lines.array_anc_id_53(p_line_num);
	   g_rec_lines.array_anc_id_54(g_LineNumber)             := l_rec_lines.array_anc_id_54(p_line_num);
	   g_rec_lines.array_anc_id_55(g_LineNumber)             := l_rec_lines.array_anc_id_55(p_line_num);
	   g_rec_lines.array_anc_id_56(g_LineNumber)             := l_rec_lines.array_anc_id_56(p_line_num);
	   g_rec_lines.array_anc_id_57(g_LineNumber)             := l_rec_lines.array_anc_id_57(p_line_num);
	   g_rec_lines.array_anc_id_58(g_LineNumber)             := l_rec_lines.array_anc_id_58(p_line_num);
	   g_rec_lines.array_anc_id_59(g_LineNumber)             := l_rec_lines.array_anc_id_59(p_line_num);
	   g_rec_lines.array_anc_id_60(g_LineNumber)             := l_rec_lines.array_anc_id_60(p_line_num);
	   g_rec_lines.array_anc_id_61(g_LineNumber)             := l_rec_lines.array_anc_id_61(p_line_num);
	   g_rec_lines.array_anc_id_62(g_LineNumber)             := l_rec_lines.array_anc_id_62(p_line_num);
	   g_rec_lines.array_anc_id_63(g_LineNumber)             := l_rec_lines.array_anc_id_63(p_line_num);
	   g_rec_lines.array_anc_id_64(g_LineNumber)             := l_rec_lines.array_anc_id_64(p_line_num);
	   g_rec_lines.array_anc_id_65(g_LineNumber)             := l_rec_lines.array_anc_id_65(p_line_num);
	   g_rec_lines.array_anc_id_66(g_LineNumber)             := l_rec_lines.array_anc_id_66(p_line_num);
	   g_rec_lines.array_anc_id_67(g_LineNumber)             := l_rec_lines.array_anc_id_67(p_line_num);
	   g_rec_lines.array_anc_id_68(g_LineNumber)             := l_rec_lines.array_anc_id_68(p_line_num);
	   g_rec_lines.array_anc_id_69(g_LineNumber)             := l_rec_lines.array_anc_id_69(p_line_num);
	   g_rec_lines.array_anc_id_70(g_LineNumber)             := l_rec_lines.array_anc_id_70(p_line_num);
	   g_rec_lines.array_anc_id_71(g_LineNumber)             := l_rec_lines.array_anc_id_71(p_line_num);
	   g_rec_lines.array_anc_id_72(g_LineNumber)             := l_rec_lines.array_anc_id_72(p_line_num);
	   g_rec_lines.array_anc_id_73(g_LineNumber)             := l_rec_lines.array_anc_id_73(p_line_num);
	   g_rec_lines.array_anc_id_74(g_LineNumber)             := l_rec_lines.array_anc_id_74(p_line_num);
	   g_rec_lines.array_anc_id_75(g_LineNumber)             := l_rec_lines.array_anc_id_75(p_line_num);
	   g_rec_lines.array_anc_id_76(g_LineNumber)             := l_rec_lines.array_anc_id_76(p_line_num);
	   g_rec_lines.array_anc_id_77(g_LineNumber)             := l_rec_lines.array_anc_id_77(p_line_num);
	   g_rec_lines.array_anc_id_78(g_LineNumber)             := l_rec_lines.array_anc_id_78(p_line_num);
	   g_rec_lines.array_anc_id_79(g_LineNumber)             := l_rec_lines.array_anc_id_79(p_line_num);
	   g_rec_lines.array_anc_id_80(g_LineNumber)             := l_rec_lines.array_anc_id_80(p_line_num);
	   g_rec_lines.array_anc_id_81(g_LineNumber)             := l_rec_lines.array_anc_id_81(p_line_num);
	   g_rec_lines.array_anc_id_82(g_LineNumber)             := l_rec_lines.array_anc_id_82(p_line_num);
	   g_rec_lines.array_anc_id_83(g_LineNumber)             := l_rec_lines.array_anc_id_83(p_line_num);
	   g_rec_lines.array_anc_id_84(g_LineNumber)             := l_rec_lines.array_anc_id_84(p_line_num);
	   g_rec_lines.array_anc_id_85(g_LineNumber)             := l_rec_lines.array_anc_id_85(p_line_num);
	   g_rec_lines.array_anc_id_86(g_LineNumber)             := l_rec_lines.array_anc_id_86(p_line_num);
	   g_rec_lines.array_anc_id_87(g_LineNumber)             := l_rec_lines.array_anc_id_87(p_line_num);
	   g_rec_lines.array_anc_id_88(g_LineNumber)             := l_rec_lines.array_anc_id_88(p_line_num);
	   g_rec_lines.array_anc_id_89(g_LineNumber)             := l_rec_lines.array_anc_id_89(p_line_num);
	   g_rec_lines.array_anc_id_90(g_LineNumber)             := l_rec_lines.array_anc_id_90(p_line_num);
	   g_rec_lines.array_anc_id_91(g_LineNumber)             := l_rec_lines.array_anc_id_91(p_line_num);
	   g_rec_lines.array_anc_id_92(g_LineNumber)             := l_rec_lines.array_anc_id_92(p_line_num);
	   g_rec_lines.array_anc_id_93(g_LineNumber)             := l_rec_lines.array_anc_id_93(p_line_num);
	   g_rec_lines.array_anc_id_94(g_LineNumber)             := l_rec_lines.array_anc_id_94(p_line_num);
	   g_rec_lines.array_anc_id_95(g_LineNumber)             := l_rec_lines.array_anc_id_95(p_line_num);
	   g_rec_lines.array_anc_id_96(g_LineNumber)             := l_rec_lines.array_anc_id_96(p_line_num);
	   g_rec_lines.array_anc_id_97(g_LineNumber)             := l_rec_lines.array_anc_id_97(p_line_num);
	   g_rec_lines.array_anc_id_98(g_LineNumber)             := l_rec_lines.array_anc_id_98(p_line_num);
	   g_rec_lines.array_anc_id_99(g_LineNumber)             := l_rec_lines.array_anc_id_99(p_line_num);
	   g_rec_lines.array_anc_id_100(g_LineNumber)            := l_rec_lines.array_anc_id_100(p_line_num);
	   --
	   --
	   g_rec_lines.array_event_number(g_LineNumber)          := l_rec_lines.array_event_number(p_line_num);
	   g_rec_lines.array_entity_id(g_LineNumber)             := l_rec_lines.array_entity_id(p_line_num);
	   g_rec_lines.array_reversal_code(g_LineNumber)         := l_rec_lines.array_reversal_code(p_line_num);
	   g_rec_lines.array_balance_type_code(g_LineNumber)     := l_rec_lines.array_balance_type_code(p_line_num);
	   g_rec_lines.array_ledger_id(g_LineNumber)             := l_rec_lines.array_ledger_id(p_line_num);
	   --
	   -- business flow
	   --
	   g_rec_lines.array_business_method_code(g_LineNumber)   := l_rec_lines.array_business_method_code(p_line_num);
	   g_rec_lines.array_business_class_code(g_LineNumber)    := l_rec_lines.array_business_class_code(p_line_num);
	   g_rec_lines.array_inherit_desc_flag(g_LineNumber)      := l_rec_lines.array_inherit_desc_flag(p_line_num);
	   g_rec_lines.array_bflow_application_id(g_LineNumber)   := l_rec_lines.array_bflow_application_id(p_line_num);

	   g_rec_lines.array_bflow_entity_code(g_LineNumber)      := l_rec_lines.array_bflow_entity_code(p_line_num);
	   g_rec_lines.array_bflow_source_id_num_1(g_LineNumber)  := l_rec_lines.array_bflow_source_id_num_1(p_line_num);
	   g_rec_lines.array_bflow_source_id_num_2(g_LineNumber)  := l_rec_lines.array_bflow_source_id_num_2(p_line_num);
	   g_rec_lines.array_bflow_source_id_num_3(g_LineNumber)  := l_rec_lines.array_bflow_source_id_num_3(p_line_num);
	   g_rec_lines.array_bflow_source_id_num_4(g_LineNumber)  := l_rec_lines.array_bflow_source_id_num_4(p_line_num);
	   g_rec_lines.array_bflow_source_id_char_1(g_LineNumber) := l_rec_lines.array_bflow_source_id_char_1(p_line_num);
	   g_rec_lines.array_bflow_source_id_char_2(g_LineNumber) := l_rec_lines.array_bflow_source_id_char_2(p_line_num);
	   g_rec_lines.array_bflow_source_id_char_3(g_LineNumber) := l_rec_lines.array_bflow_source_id_char_3(p_line_num);
	   g_rec_lines.array_bflow_source_id_char_4(g_LineNumber) := l_rec_lines.array_bflow_source_id_char_4(p_line_num);

	   g_rec_lines.array_bflow_distribution_type(g_LineNumber):= l_rec_lines.array_bflow_distribution_type(p_line_num);
	   g_rec_lines.array_bflow_dist_id_num_1(g_LineNumber)    := l_rec_lines.array_bflow_dist_id_num_1(p_line_num);
	   g_rec_lines.array_bflow_dist_id_num_2(g_LineNumber)    := l_rec_lines.array_bflow_dist_id_num_2(p_line_num);
	   g_rec_lines.array_bflow_dist_id_num_3(g_LineNumber)    := l_rec_lines.array_bflow_dist_id_num_3(p_line_num);
	   g_rec_lines.array_bflow_dist_id_num_4(g_LineNumber)    := l_rec_lines.array_bflow_dist_id_num_4(p_line_num);
	   g_rec_lines.array_bflow_dist_id_num_5(g_LineNumber)    := l_rec_lines.array_bflow_dist_id_num_5(p_line_num);
	   g_rec_lines.array_bflow_dist_id_char_1(g_LineNumber)   := l_rec_lines.array_bflow_dist_id_char_1(p_line_num);
	   g_rec_lines.array_bflow_dist_id_char_2(g_LineNumber)   := l_rec_lines.array_bflow_dist_id_char_2(p_line_num);
	   g_rec_lines.array_bflow_dist_id_char_3(g_LineNumber)   := l_rec_lines.array_bflow_dist_id_char_3(p_line_num);
	   g_rec_lines.array_bflow_dist_id_char_4(g_LineNumber)   := l_rec_lines.array_bflow_dist_id_char_4(p_line_num);
	   g_rec_lines.array_bflow_dist_id_char_5(g_LineNumber)   := l_rec_lines.array_bflow_dist_id_char_5(p_line_num);

	   g_rec_lines.array_override_acctd_amt_flag(g_LineNumber)   := l_rec_lines.array_override_acctd_amt_flag(p_line_num);


	   g_rec_lines.array_bflow_applied_to_amt(g_LineNumber)   := l_rec_lines.array_bflow_applied_to_amt(p_line_num); -- 5132302
	   --
	   -- Allocation Attributes
	   --
	   g_rec_lines.array_alloct_application_id(g_LineNumber)   := l_rec_lines.array_alloct_application_id(p_line_num);

	   g_rec_lines.array_alloct_entity_code(g_LineNumber)      := l_rec_lines.array_alloct_entity_code(p_line_num);
	   g_rec_lines.array_alloct_source_id_num_1(g_LineNumber)  := l_rec_lines.array_alloct_source_id_num_1(p_line_num);
	   g_rec_lines.array_alloct_source_id_num_2(g_LineNumber)  := l_rec_lines.array_alloct_source_id_num_2(p_line_num);
	   g_rec_lines.array_alloct_source_id_num_3(g_LineNumber)  := l_rec_lines.array_alloct_source_id_num_3(p_line_num);
	   g_rec_lines.array_alloct_source_id_num_4(g_LineNumber)  := l_rec_lines.array_alloct_source_id_num_4(p_line_num);
	   g_rec_lines.array_alloct_source_id_char_1(g_LineNumber) := l_rec_lines.array_alloct_source_id_char_1(p_line_num);
	   g_rec_lines.array_alloct_source_id_char_2(g_LineNumber) := l_rec_lines.array_alloct_source_id_char_2(p_line_num);
	   g_rec_lines.array_alloct_source_id_char_3(g_LineNumber) := l_rec_lines.array_alloct_source_id_char_3(p_line_num);
	   g_rec_lines.array_alloct_source_id_char_4(g_LineNumber) := l_rec_lines.array_alloct_source_id_char_4(p_line_num);

	   g_rec_lines.array_alloct_distribution_type(g_LineNumber):= l_rec_lines.array_alloct_distribution_type(p_line_num);
	   g_rec_lines.array_alloct_dist_id_num_1(g_LineNumber)    := l_rec_lines.array_alloct_dist_id_num_1(p_line_num);
	   g_rec_lines.array_alloct_dist_id_num_2(g_LineNumber)    := l_rec_lines.array_alloct_dist_id_num_2(p_line_num);
	   g_rec_lines.array_alloct_dist_id_num_3(g_LineNumber)    := l_rec_lines.array_alloct_dist_id_num_3(p_line_num);
	   g_rec_lines.array_alloct_dist_id_num_4(g_LineNumber)    := l_rec_lines.array_alloct_dist_id_num_4(p_line_num);
	   g_rec_lines.array_alloct_dist_id_num_5(g_LineNumber)    := l_rec_lines.array_alloct_dist_id_num_5(p_line_num);
	   g_rec_lines.array_alloct_dist_id_char_1(g_LineNumber)   := l_rec_lines.array_alloct_dist_id_char_1(p_line_num);
	   g_rec_lines.array_alloct_dist_id_char_2(g_LineNumber)   := l_rec_lines.array_alloct_dist_id_char_2(p_line_num);
	   g_rec_lines.array_alloct_dist_id_char_3(g_LineNumber)   := l_rec_lines.array_alloct_dist_id_char_3(p_line_num);
	   g_rec_lines.array_alloct_dist_id_char_4(g_LineNumber)   := l_rec_lines.array_alloct_dist_id_char_4(p_line_num);
	   g_rec_lines.array_alloct_dist_id_char_5(g_LineNumber)   := l_rec_lines.array_alloct_dist_id_char_5(p_line_num);
	   -- =================================================================================================
	   --
	   -- for 7029018
	   IF NVL(g_rec_lines.array_balance_type_code(g_LineNumber),'N')='E'  THEN

	      IF ((NVL(l_rec_lines.array_actual_upg_option(p_line_num), 'N') = 'Y') OR
		  (NVL(l_rec_lines.array_enc_upg_option(p_line_num), 'N') = 'Y')) THEN

		   --temp fix for Period End Accrual Encumbrance for Upgraded Entries.
		   g_rec_lines.array_encumbrance_type_id(g_LineNumber) := nvl(l_rec_lines.array_upg_cr_enc_type_id(p_line_num),
								      l_rec_lines.array_upg_dr_enc_type_id(p_line_num));
		    IF (C_LEVEL_EVENT >= g_log_level) THEN
			trace
		       (p_msg       =>   'Period End Accrual Encumbrance for Upgraded Entries'
		       ,p_level     =>   C_LEVEL_EVENT
		       ,p_module    =>   l_log_module);
		    END IF;
	       ELSE
		    -- bug9325101
		    g_rec_lines.array_encumbrance_type_id(g_LineNumber) := l_rec_lines.array_encumbrance_type_id(p_line_num);

		    IF (C_LEVEL_EVENT >= g_log_level) THEN
			trace
		       (p_msg       =>   'Period End Accrual Encumbrance for Non-Upgraded Entries'
		       ,p_level     =>   C_LEVEL_EVENT
		       ,p_module    =>   l_log_module);
		    END IF;

	       END IF;

	   END IF;
	   --
	   -- Validate line accounting attributes
	   --
	   IF g_rec_lines.array_mpa_option(g_LineNumber) NOT IN ('Y','N') THEN
	      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
	      xla_accounting_err_pkg.build_message
		   (p_appli_s_name            => 'XLA'
		   ,p_msg_name                => 'XLA_MA_INVALID_OPTION'    -- 4262811a
		   ,p_token_1                 => 'LINE_NUMBER'
		   ,p_value_1                 =>  g_ExtractLine
		   ,p_token_2                 => 'ACCOUNTING_SOURCE_NAME'
		   ,p_value_2                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('MULTIPERIOD_OPTION')
								 --(l_rec_lines.array_acct_attr_code(p_line_num))
		   ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
		   ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
		   ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
	   END IF;

	   IF g_rec_lines.array_sys_distribution_type(g_LineNumber) IS NULL THEN
	      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
	      xla_accounting_err_pkg.build_message
		   (p_appli_s_name            => 'XLA'
		   ,p_msg_name                => 'XLA_AP_NO_DIST_LINK_TYPE'
		   ,p_token_1                 => 'LINE_NUMBER'
		   ,p_value_1                 =>  g_ExtractLine
		   ,p_token_2                 => 'ACCOUNTING_SOURCE_NAME'
		   ,p_value_2                 => XLA_AE_SOURCES_PKG.GetAccountingSourceName('DISTRIBUTION_TYPE')
								     --(p_rec_acct_attrs.array_acct_attr_code(i))
		   ,p_token_3                 => 'SOURCE_NAME'
		   ,p_value_3                 => NULL
		   ,p_token_4                 => 'LINE_TYPE_NAME'
		   ,p_value_4                 =>  XLA_AE_SOURCES_PKG.GetComponentName (
							     g_accounting_line.component_type
							   , g_accounting_line.accounting_line_code
							   , g_accounting_line.accounting_line_type_code
							   , g_accounting_line.accounting_line_appl_id
							   , g_accounting_line.amb_context_code
							   , g_accounting_line.entity_code
							   , g_accounting_line.event_class_code
							  )
		   ,p_token_5                 => 'OWNER'
		   ,p_value_5                 => xla_lookups_pkg.get_meaning(
							     'XLA_OWNER_TYPE'
							    , g_rec_lines.array_accounting_line_type(g_LineNumber)
							   )
		   ,p_token_6                 => 'PRODUCT_NAME'
		   ,p_value_6                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
		   ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
		   ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
		   ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
	   END IF;

	----------------------------------------------
	-- 4623638  This change is on top of 120.85
	----------------------------------------------
	IF nvl(g_rec_lines.array_calculate_acctd_flag(g_LineNumber), 'N')= 'N' OR
	     (nvl(g_rec_lines.array_calculate_g_l_flag(g_LineNumber), 'N')='N' AND
	      g_rec_lines.array_natural_side_code(g_LineNumber) = 'G') THEN

	   IF g_rec_lines.array_ledger_amount(g_LineNumber) IS NULL THEN
	      XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
	      xla_accounting_err_pkg.build_message
		   (p_appli_s_name            => 'XLA'
		   ,p_msg_name                => 'XLA_AP_NO_LEDGER_AMOUNT'
		   ,p_token_1                 => 'LINE_NUMBER'
		   ,p_value_1                 =>  g_ExtractLine
		   ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
		   ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
		   ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);
	   END IF;

	END IF;

	l_rec_lines := NULL ;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'END CopyLineInfo(OverLoaded)'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;

EXCEPTION
--
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS  THEN
      xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_lines_pkg.CopyLineInfo(OverLoaded)');
  --
END CopyLineInfo;


/*======================================================================+
|                                                                       |
| Public Procedure-  Business Flow Upgrade Entries                      |
|                                                                       |
|                                                                       |
+======================================================================*/

PROCEDURE BflowUpgEntry
       (p_business_method_code      IN VARCHAR2
       ,p_business_class_code       IN VARCHAR2
       ,p_balance_type              IN VARCHAR2) IS
l_ledger_ccy            VARCHAR2(30);
l_ccid                  NUMBER;
l_enc_type_id           NUMBER;
l_entered_amt           NUMBER;
l_accounted_amt         NUMBER;
l_entered_curr          VARCHAR2(30);
l_xchange_rate          NUMBER;
l_xchange_type          VARCHAR2(30);
l_xchange_date          DATE;

l_log_module            VARCHAR2(240); -- Bug 4922099

BEGIN
   -- Bug 4922099
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE || '.BflowUpgEntry';
   END IF;

   --8238617 Added FND Debug statements
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'BEGIN of BflowUpgEntry'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;


   g_rec_lines.array_business_method_code(g_LineNumber) :=  p_business_method_code;

   -- Bug 4922099
   IF ((g_rec_lines.array_actual_upg_option(g_LineNumber) = 'O' OR g_rec_lines.array_enc_upg_option(g_LineNumber) = 'O')
       AND g_rec_lines.array_acc_reversal_option(g_LineNumber) IN ('Y', 'B')) THEN
      xla_ae_journal_entry_pkg.g_global_status := xla_ae_journal_entry_pkg.C_INVALID;
      xla_accounting_err_pkg.build_message
           (p_appli_s_name            => 'XLA'
           ,p_msg_name                => 'XLA_UPG_OVERRIDE_NA_REVERSAL'
           ,p_token_1                 => 'LINE_NUMBER'
           ,p_value_1                 =>  g_ExtractLine
           ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
           ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
           ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id);

      IF (C_LEVEL_ERROR >= g_log_level) THEN
          trace
               (p_msg       =>   'ERROR: XLA_UPG_OVERRIDE_NA_REVERSAL'
               ,p_level     =>   C_LEVEL_ERROR
               ,p_module    =>   l_log_module);
      END IF;
    END IF;


   ------------------------------------------------
   -- Validate the applied-to accounting attributes
   ------------------------------------------------
   ValidateBFlowLinks;

   -------------------------------------------------
   -- Reset values for certain fields in g_rec_lines
   -------------------------------------------------

   IF p_balance_type = 'A' THEN
      IF g_rec_lines.array_natural_side_code(g_LineNumber) = C_CREDIT THEN
         -- Bug 4922099
         IF (NVL(g_rec_lines.array_actual_upg_option(g_LineNumber), 'N') = 'Y') THEN
           l_ccid           := g_rec_lines.array_actual_upg_cr_ccid(g_LineNumber);
         END IF;
         l_enc_type_id    := NULL;
         l_entered_amt    := g_rec_lines.array_actual_upg_cr_ent_amt(g_LineNumber);
         l_accounted_amt  := g_rec_lines.array_actual_upg_cr_ledger_amt(g_LineNumber);
         l_entered_curr   := g_rec_lines.array_actual_upg_cr_ent_curr(g_LineNumber);
         l_xchange_rate   := g_rec_lines.array_actual_upg_cr_xrate(g_LineNumber);
         l_xchange_type   := g_rec_lines.array_actual_upg_cr_xrate_type(g_LineNumber);
         l_xchange_date   := g_rec_lines.array_actual_upg_cr_xdate(g_LineNumber);
      ELSE
         -- Bug 4922099
         IF (NVL(g_rec_lines.array_actual_upg_option(g_LineNumber), 'N') = 'Y') THEN
           l_ccid           := g_rec_lines.array_actual_upg_dr_ccid(g_LineNumber);
         END IF;
         l_enc_type_id    := NULL;
         l_entered_amt    := g_rec_lines.array_actual_upg_dr_ent_amt(g_LineNumber);
         l_accounted_amt  := g_rec_lines.array_actual_upg_dr_ledger_amt(g_LineNumber);
         l_entered_curr   := g_rec_lines.array_actual_upg_dr_ent_curr(g_LineNumber);
         l_xchange_rate   := g_rec_lines.array_actual_upg_dr_xrate(g_LineNumber);
         l_xchange_type   := g_rec_lines.array_actual_upg_dr_xrate_type(g_LineNumber);
         l_xchange_date   := g_rec_lines.array_actual_upg_dr_xdate(g_LineNumber);
      END IF;
   ELSIF p_balance_type = 'E' THEN
      IF g_rec_lines.array_natural_side_code(g_LineNumber) = C_CREDIT THEN
        -- Bug 4922099
         IF (NVL(g_rec_lines.array_enc_upg_option(g_LineNumber), 'N') = 'Y') THEN
           l_ccid           := g_rec_lines.array_enc_upg_cr_ccid(g_LineNumber);
         END IF;
         l_enc_type_id    := g_rec_lines.array_upg_cr_enc_type_id(g_LineNumber);
         l_entered_amt    := g_rec_lines.array_enc_upg_cr_ent_amt(g_LineNumber);
         l_accounted_amt  := g_rec_lines.array_enc_upg_cr_ledger_amt(g_LineNumber);
         l_entered_curr   := g_rec_lines.array_enc_upg_cr_ent_curr(g_LineNumber);
      ELSE
         -- Bug 4922099
         IF (NVL(g_rec_lines.array_enc_upg_option(g_LineNumber), 'N') = 'Y') THEN
           l_ccid           := g_rec_lines.array_enc_upg_dr_ccid(g_LineNumber);
         END IF;
         l_enc_type_id    := g_rec_lines.array_upg_dr_enc_type_id(g_LineNumber);
         l_entered_amt    := g_rec_lines.array_enc_upg_dr_ent_amt(g_LineNumber);
         l_accounted_amt  := g_rec_lines.array_enc_upg_dr_ledger_amt(g_LineNumber);
         l_entered_curr   := g_rec_lines.array_enc_upg_dr_ent_curr(g_LineNumber);
      END IF;

      g_override_acctd_amt_flag                           := 'Y';
   END IF;

   g_rec_lines.array_encumbrance_type_id(g_LineNumber) := l_enc_type_id;
   g_rec_lines.array_entered_amount(g_LineNumber)      := l_entered_amt;
   g_rec_lines.array_ledger_amount(g_LineNumber)    := l_accounted_amt;
   g_rec_lines.array_currency_code(g_LineNumber)       := l_entered_curr;
   g_rec_lines.array_curr_conversion_date(g_LineNumber):= l_xchange_date;
   g_rec_lines.array_curr_conversion_rate(g_LineNumber):= l_xchange_rate;
   g_rec_lines.array_curr_conversion_type(g_LineNumber):= l_xchange_type;
   -- 5845547
   g_rec_lines.array_party_type_code(g_LineNumber)     := g_rec_lines.array_upg_party_type_code(g_LineNumber);
   g_rec_lines.array_party_id(g_LineNumber)            := g_rec_lines.array_upg_party_id(g_LineNumber);
   g_rec_lines.array_party_site_id(g_LineNumber)       := g_rec_lines.array_upg_party_site_id(g_LineNumber);

   --8238617 Added debug statements
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'p_balance_type = '||p_balance_type
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'Natural Side = '||g_rec_lines.array_natural_side_code(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'ccid = '||l_ccid
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'Encumbrance_type_id = '||g_rec_lines.array_encumbrance_type_id(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'Entered Amount = '||g_rec_lines.array_entered_amount(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'Ledger Amount = '|| g_rec_lines.array_ledger_amount(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'Currency Code = '|| g_rec_lines.array_currency_code(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'curr_conversion_date = '|| g_rec_lines.array_curr_conversion_date(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'curr_conversion_rate = '|| g_rec_lines.array_curr_conversion_rate(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'curr_conversion_type = '|| g_rec_lines.array_curr_conversion_type(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'party_type_code = '|| g_rec_lines.array_party_type_code(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'party_id = '||g_rec_lines.array_party_id(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);

         trace
            (p_msg      => 'party_site_id = '||g_rec_lines.array_party_site_id(g_LineNumber)
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
   END IF; --8238617 Added debug statements.


  -- Bug 4922099
  IF ((NVL(g_rec_lines.array_actual_upg_option(g_LineNumber), 'N') = 'Y') OR
      (NVL(g_rec_lines.array_enc_upg_option(g_LineNumber), 'N') = 'Y')) THEN
   xla_ae_lines_pkg.set_ccid(
    p_code_combination_id          => l_ccid
  , p_value_type_code              => 'S'  --l_adr_value_type_code
  , p_transaction_coa_id           => NULL --l_adr_transaction_coa_id
  , p_accounting_coa_id            => NULL --l_adr_accounting_coa_id
  , p_adr_code                     => NULL --'SS_TEST'
  , p_adr_type_code                => NULL --'C'
  , p_component_type               => g_accounting_line.component_type --l_component_type
  , p_component_code               => g_accounting_line.accounting_line_code  --l_component_code
  , p_component_type_code          => g_accounting_line.accounting_line_type_code --l_component_type_code
  , p_component_appl_id            => g_accounting_line.accounting_line_appl_id --l_component_appl_id
  , p_amb_context_code             => g_accounting_line.amb_context_code --l_amb_context_code
  , p_side                         => 'NA'
  );
  END IF;

  --8238617 Added FND Debug statements
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'End of BflowUpgEntry'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;


END BflowUpgEntry;

PROCEDURE CreateGainOrLossLine
       (p_event_id                  IN NUMBER
       ,p_application_id            IN NUMBER
       ,p_amb_context_code          IN VARCHAR2
       ,p_entity_code               IN VARCHAR2
       ,p_event_class_code          IN VARCHAR2
       ,p_event_type_code           IN VARCHAR2
       ,p_gain_ccid                 IN NUMBER
       ,p_loss_ccid                 IN NUMBER
/*
       ,p_rounding_class            IN VARCHAR2
       ,p_doc_rounding_level        IN VARCHAR2
       ,p_merge_duplicate_code      IN VARCHAR2
       ,p_gl_transfer_mode_code     IN VARCHAR2
*/
       ,p_distribution_id_char_1    IN VARCHAR2
       ,p_distribution_id_char_2    IN VARCHAR2
       ,p_distribution_id_char_3    IN VARCHAR2
       ,p_distribution_id_char_4    IN VARCHAR2
       ,p_distribution_id_char_5    IN VARCHAR2
       ,p_distribution_id_num_1     IN NUMBER
       ,p_distribution_id_num_2     IN NUMBER
       ,p_distribution_id_num_3     IN NUMBER
       ,p_distribution_id_num_4     IN NUMBER
       ,p_distribution_id_num_5     IN NUMBER
       ,p_distribution_type         IN VARCHAR2
       ,p_gl_date                   IN DATE
       ,p_gain_loss_ref             IN VARCHAR2
       ,p_balance_type_flag         IN VARCHAR2
) IS
l_ledger_ccy            VARCHAR2(30);
l_ccid                  NUMBER;
l_enc_type_id           NUMBER;
l_entered_amt           NUMBER;
l_accounted_amt         NUMBER;
l_entered_curr          VARCHAR2(30);
l_ae_header_id          NUMBER;
l_Idx                   NUMBER;

l_log_module            VARCHAR2(240);
-- extract line num is in g_ExtractLine
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE || '.CreateGainOrLossLine';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
           (p_msg      => 'BEGIN of CreateGainOrLossLine'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    trace
           (p_msg      => 'p_gain_ccid:'||to_char(p_gain_ccid)||' p_loss_ccid:'||to_char(p_loss_ccid)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;

  -- this need to be called before SetNewLine
  SetNewLine;

  set_ae_header_id (p_ae_header_id => p_event_id ,
                                p_header_num   => 0);

  -- this is a gain/loss line
  l_ae_header_id := SetAcctLineOption(
           p_natural_side_code          => 'G'
         , p_gain_or_loss_flag          => 'Y'
         , p_gl_transfer_mode_code      => 'D' -- always use detail
         , p_acct_entry_type_code       => 'A'
         , p_switch_side_flag           => 'Y'
         , p_merge_duplicate_code       => 'A' --p_merge_duplicate_code
         );
  SetAcctLineType
      (p_component_type             => 'AUTO_GEN_GAIN_LOSS'
      ,p_event_type_code            => p_event_type_code
      ,p_line_definition_owner_code => 'O'
      ,p_line_definition_code       => 'AUTO_GEN_GAIN_LOSS'
      ,p_accounting_line_code       => 'AUTO_GEN_GAIN_LOSS'
      ,p_accounting_line_type_code  => 'S'
      ,p_accounting_line_appl_id    => p_application_id
      ,p_amb_context_code           => p_amb_context_code
      ,p_entity_code                => p_entity_code
      ,p_event_class_code           => p_event_class_code);
  SetAcctClass(
           p_accounting_class_code  => 'DUMMY_EXCHANGE_GAIN_LOSS_DUMMY'
--           p_accounting_class_code  => 'EXCHANGE_GAIN_LOSS'
         , p_ae_header_id           => l_ae_header_id
         );

  g_rec_lines.array_calculate_acctd_flag(g_LineNumber) := 'Y';
  g_rec_lines.array_calculate_g_l_flag(g_LineNumber) := 'Y';
  g_rec_lines.array_balance_type_code(g_LineNumber) := p_balance_type_flag;

  g_rec_lines.array_ledger_id(g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

  g_rec_lines.array_gl_date(g_LineNumber) := p_gl_date;

  g_rec_lines.array_distribution_id_char_1(g_LineNumber) := p_distribution_id_char_1;
  g_rec_lines.array_distribution_id_char_2(g_LineNumber) := p_distribution_id_char_2;
  g_rec_lines.array_distribution_id_char_3(g_LineNumber) := p_distribution_id_char_3;
  g_rec_lines.array_distribution_id_char_4(g_LineNumber) := p_distribution_id_char_4;
  g_rec_lines.array_distribution_id_char_5(g_LineNumber) := p_distribution_id_char_5;
  g_rec_lines.array_distribution_id_num_1(g_LineNumber)  := p_distribution_id_num_1;
  g_rec_lines.array_distribution_id_num_2(g_LineNumber)  := p_distribution_id_num_2;
  g_rec_lines.array_distribution_id_num_3(g_LineNumber)  := p_distribution_id_num_3;
  g_rec_lines.array_distribution_id_num_4(g_LineNumber)  := p_distribution_id_num_4;
  g_rec_lines.array_distribution_id_num_5(g_LineNumber)  := p_distribution_id_num_5;
  g_rec_lines.array_sys_distribution_type(g_LineNumber)  := p_distribution_type;
  g_rec_lines.array_sys_distribution_type(g_LineNumber)  := p_distribution_type;
  g_rec_lines.array_gain_or_loss_ref(g_LineNumber)       := p_gain_loss_ref;
  g_rec_lines.array_currency_code(g_LineNumber)          :=
                                  XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code;

  IF(p_gain_ccid is null or p_gain_ccid = -1 ) THEN
    g_rec_lines.array_ccid(g_LineNumber)          := -1;
    g_rec_lines.array_ccid_flag(g_LineNumber)     := C_INVALID;
  ELSIF( XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id <>
         XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.source_coa_id ) THEN
    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'credit map here, sl_coa_mapping_id is:'||XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'map here, ledger_id is:'||XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'map here, array_ae_header_id is:'||g_rec_lines.array_ae_header_id(g_LineNumber)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'map here, temp_line_num is:'||g_rec_lines.array_line_num(g_LineNumber)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'map here, ccid is:'||p_gain_ccid
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    g_rec_lines.array_ccid_flag(g_LineNumber)     := C_INVALID;
    IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id IS NULL THEN
      null;
    ELSE
      l_Idx := NVL(g_transaction_accounts.array_ae_header_id.COUNT,0) + 1;
      g_transaction_accounts.array_line_num(l_Idx)        := l_Idx ;
      g_transaction_accounts.array_ae_header_id(l_Idx)    := g_rec_lines.array_ae_header_id(g_LineNumber);
      g_transaction_accounts.array_temp_line_num(l_Idx)   := g_rec_lines.array_line_num(g_LineNumber);
      g_transaction_accounts.array_code_combination_id (l_Idx)   := p_gain_ccid;
      g_transaction_accounts.array_segment(l_Idx)                := NULL;
      g_transaction_accounts.array_from_segment_code(l_Idx)      := NULL;
      g_transaction_accounts.array_to_segment_code(l_Idx)        := NULL;
      g_transaction_accounts.array_processing_status_code(l_Idx) := C_MAP_CCID;
      g_transaction_accounts.array_side_code(l_Idx)              := 'CREDIT';
    END IF;
  ELSE
    g_rec_lines.array_ccid(g_LineNumber)          := p_gain_ccid;
    g_rec_lines.array_ccid_flag(g_LineNumber)     := C_CREATED;
  END IF;

  IF(p_loss_ccid is null or p_loss_ccid = -1) THEN
    g_rec_lines.alt_array_ccid(g_LineNumber)      :=  -1;
    g_rec_lines.alt_array_ccid_flag(g_LineNumber) := C_INVALID;
  ELSIF( XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.target_coa_id <>
         XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.source_coa_id ) THEN

    IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'debit map here, sl_coa_mapping_id is:'||XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'map here, ledger_id is:'||XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'map here, array_ae_header_id is:'||g_rec_lines.array_ae_header_id(g_LineNumber)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'map here, temp_line_num is:'||g_rec_lines.array_line_num(g_LineNumber)
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'map here, ccid is:'||p_loss_ccid
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
    END IF;
    g_rec_lines.array_ccid_flag(g_LineNumber)     := C_INVALID;
    IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.sl_coa_mapping_id IS NULL THEN
      null;
    ELSE
      l_Idx := NVL(g_transaction_accounts.array_ae_header_id.COUNT,0) + 1;
      g_transaction_accounts.array_line_num(l_Idx)        := l_Idx ;
      g_transaction_accounts.array_ae_header_id(l_Idx)    := g_rec_lines.array_ae_header_id(g_LineNumber);
      g_transaction_accounts.array_temp_line_num(l_Idx)   := g_rec_lines.array_line_num(g_LineNumber);
      g_transaction_accounts.array_code_combination_id (l_Idx)   := p_loss_ccid;
      g_transaction_accounts.array_segment(l_Idx)                := NULL;
      g_transaction_accounts.array_from_segment_code(l_Idx)      := NULL;
      g_transaction_accounts.array_to_segment_code(l_Idx)        := NULL;
      g_transaction_accounts.array_processing_status_code(l_Idx) := C_MAP_CCID;
      g_transaction_accounts.array_side_code(l_Idx)              := 'DEBIT';
    END IF;
  ELSE
    g_rec_lines.alt_array_ccid(g_LineNumber)      :=  p_loss_ccid;
    g_rec_lines.alt_array_ccid_flag(g_LineNumber) := C_CREATED;
  END IF;

  g_rec_lines.array_entered_cr(g_LineNumber)    := 0;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
           (p_msg      => 'END of CreateGainOrLossLine'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
END CreateGainOrLossLine;


PROCEDURE CreateGainOrLossLines
       (p_event_id                  IN NUMBER
       ,p_application_id            IN NUMBER
       ,p_amb_context_code          IN VARCHAR2
       ,p_entity_code               IN VARCHAR2
       ,p_event_class_code          IN VARCHAR2
       ,p_event_type_code           IN VARCHAR2
       ,p_gain_ccid                 IN NUMBER
       ,p_loss_ccid                 IN NUMBER
       ,p_actual_flag               IN VARCHAR2
       ,p_enc_flag                  IN VARCHAR2
       ,p_actual_g_l_ref            IN VARCHAR2
       ,p_enc_g_l_ref               IN VARCHAR2
) IS
l_ledger_ccy            VARCHAR2(30);
l_ccid                  NUMBER;
l_enc_type_id           NUMBER;
l_entered_amt           NUMBER;
l_accounted_amt         NUMBER;
l_entered_curr          VARCHAR2(30);
l_ae_header_id          NUMBER;
l_rounding_class        VARCHAR2(30);
l_doc_rounding_level    VARCHAR2(30);
l_gain_or_loss_ref      VARCHAR2(30);
l_merge_duplicate_code  VARCHAR2(30);
l_gl_transfer_mode_code VARCHAR2(30);

l_distribution_id_char_1 VARCHAR2(30);
l_distribution_id_char_2 VARCHAR2(30);
l_distribution_id_char_3 VARCHAR2(30);
l_distribution_id_char_4 VARCHAR2(30);
l_distribution_id_char_5 VARCHAR2(30);
l_distribution_id_num_1  NUMBER;
l_distribution_id_num_2  NUMBER;
l_distribution_id_num_3  NUMBER;
l_distribution_id_num_4  NUMBER;
l_distribution_id_num_5  NUMBER;
l_distribution_type      VARCHAR2(30);
l_gl_date                DATE;

l_log_module            VARCHAR2(240);
-- extract line num is in g_ExtractLine
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE || '.CreateGainOrLossLines';
  END IF;
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
           (p_msg      => 'BEGIN of CreateGainOrLossLines'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;

  IF(p_actual_flag = 'A') THEN

    -- this need to be called before SetNewLine
    l_rounding_class := g_rec_lines.array_rounding_class(g_LineNumber);
    l_doc_rounding_level:= g_rec_lines.array_doc_rounding_level(g_LineNumber);
    l_gain_or_loss_ref:= g_rec_lines.array_gain_or_loss_ref(g_LineNumber);
    l_merge_duplicate_code := g_rec_lines.array_merge_duplicate_code(g_LineNumber);
    l_gl_transfer_mode_code := g_rec_lines.array_gl_transfer_mode(g_LineNumber);
    l_distribution_id_char_1 := g_rec_lines.array_distribution_id_char_1(g_LineNumber);
    l_distribution_id_char_2 := g_rec_lines.array_distribution_id_char_2(g_LineNumber);
    l_distribution_id_char_3 := g_rec_lines.array_distribution_id_char_3(g_LineNumber);
    l_distribution_id_char_4 := g_rec_lines.array_distribution_id_char_4(g_LineNumber);
    l_distribution_id_char_5 := g_rec_lines.array_distribution_id_char_5(g_LineNumber);
    l_distribution_id_num_1  := g_rec_lines.array_distribution_id_num_1(g_LineNumber);
    l_distribution_id_num_2  := g_rec_lines.array_distribution_id_num_2(g_LineNumber);
    l_distribution_id_num_3  := g_rec_lines.array_distribution_id_num_3(g_LineNumber);
    l_distribution_id_num_4  := g_rec_lines.array_distribution_id_num_4(g_LineNumber);
    l_distribution_id_num_5  := g_rec_lines.array_distribution_id_num_5(g_LineNumber);
    l_distribution_type      := g_rec_lines.array_sys_distribution_type(g_LineNumber);
    l_gl_date                := g_rec_lines.array_gl_date(g_LineNumber);

  -- need create a gain/loss for actual lines
    CreateGainOrLossLine
       (p_event_id                  => p_event_id
       ,p_application_id            => p_application_id
       ,p_amb_context_code          => p_amb_context_code
       ,p_entity_code               => p_entity_code
       ,p_event_class_code          => p_event_class_code
       ,p_event_type_code           => p_event_type_code
       ,p_gain_ccid                 => p_gain_ccid
       ,p_loss_ccid                 => p_loss_ccid
       ,p_distribution_id_char_1    => l_distribution_id_char_1
       ,p_distribution_id_char_2    => l_distribution_id_char_2
       ,p_distribution_id_char_3    => l_distribution_id_char_3
       ,p_distribution_id_char_4    => l_distribution_id_char_4
       ,p_distribution_id_char_5    => l_distribution_id_char_5
       ,p_distribution_id_num_1     => l_distribution_id_num_1
       ,p_distribution_id_num_2     => l_distribution_id_num_2
       ,p_distribution_id_num_3     => l_distribution_id_num_3
       ,p_distribution_id_num_4     => l_distribution_id_num_4
       ,p_distribution_id_num_5     => l_distribution_id_num_5
       ,p_distribution_type         => l_distribution_type
       ,p_gl_date                   => l_gl_date
       ,p_gain_loss_ref             => p_actual_g_l_ref
       ,p_balance_type_flag         => 'A');
  END IF;
/*

  IF(p_enc_flag = 'E') THEN
  -- need create a gain/loss for actual lines
    CreateGainOrLossLine
       (p_event_id                  => p_event_id
       ,p_application_id            => p_application_id
       ,p_amb_context_code          => p_amb_context_code
       ,p_entity_code               => p_entity_code
       ,p_event_class_code          => p_event_class_code
       ,p_event_type_code           => p_event_type_code
       ,p_gain_ccid                 => p_gain_ccid
       ,p_loss_ccid                 => p_loss_ccid
       ,p_distribution_id_char_1    => l_distribution_id_char_1
       ,p_distribution_id_char_2    => l_distribution_id_char_2
       ,p_distribution_id_char_3    => l_distribution_id_char_3
       ,p_distribution_id_char_4    => l_distribution_id_char_4
       ,p_distribution_id_char_5    => l_distribution_id_char_5
       ,p_distribution_id_num_1     => l_distribution_id_num_1
       ,p_distribution_id_num_2     => l_distribution_id_num_2
       ,p_distribution_id_num_3     => l_distribution_id_num_3
       ,p_distribution_id_num_4     => l_distribution_id_num_4
       ,p_distribution_id_num_5     => l_distribution_id_num_5
       ,p_distribution_type         => l_distribution_type
       ,p_gl_date                   => l_gl_date
       ,p_gain_loss_ref             => p_enc_g_l_ref
       ,p_balance_type_flag         => 'E');
  END IF;
*/

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
           (p_msg      => 'END of CreateGainOrLossLines'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
  END IF;
END CreateGainOrLossLines;

/*======================================================================+
|                                                                       |
| Public Procedure- InsertMPARecogLineInfo 7109881                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE InsertMPARecogLineInfo(
   p_line_num   NUMBER
) IS

   l_log_module         VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.InsertMPARecogLineInfo';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'BEGIN of InsertMPARecogLineInfo '
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
      trace
           (p_msg      => 'Recognition Line(p_line_num): ' || p_line_num
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
   END IF;
-- Copy all the data from G_REC_LINES to G_MPA_RECOG_LINES for a given Recognition Line
g_mpa_recog_lines.array_ae_header_id(p_line_num)                    := g_rec_lines.array_ae_header_id(p_line_num)  ;
g_mpa_recog_lines.array_line_num(p_line_num)                        := g_rec_lines.array_line_num(p_line_num)       ;
g_mpa_recog_lines.array_extract_line_num(p_line_num)                := g_rec_lines.array_extract_line_num(p_line_num) ;
g_mpa_recog_lines.array_accounting_class(p_line_num)                := g_rec_lines.array_accounting_class(p_line_num)  ;
g_mpa_recog_lines.array_rounding_class(p_line_num)                  := g_rec_lines.array_rounding_class(p_line_num) ;
g_mpa_recog_lines.array_doc_rounding_level(p_line_num)              := g_rec_lines.array_doc_rounding_level(p_line_num) ;
g_mpa_recog_lines.array_gain_or_loss_ref(p_line_num)                := g_rec_lines.array_gain_or_loss_ref(p_line_num) ;
g_mpa_recog_lines.array_event_class_code(p_line_num)                := g_rec_lines.array_event_class_code(p_line_num) ;
g_mpa_recog_lines.array_event_type_code(p_line_num)                 := g_rec_lines.array_event_type_code(p_line_num) ;
g_mpa_recog_lines.array_line_defn_owner_code(p_line_num)            := g_rec_lines.array_line_defn_owner_code(p_line_num) ;
g_mpa_recog_lines.array_line_defn_code(p_line_num)                  := g_rec_lines.array_line_defn_code(p_line_num)  ;
g_mpa_recog_lines.array_accounting_line_code(p_line_num)            := g_rec_lines.array_accounting_line_code(p_line_num) ;
g_mpa_recog_lines.array_accounting_line_type(p_line_num)            := g_rec_lines.array_accounting_line_type(p_line_num) ;
g_mpa_recog_lines.array_calculate_acctd_flag(p_line_num)            := g_rec_lines.array_calculate_acctd_flag(p_line_num) ;
g_mpa_recog_lines.array_calculate_g_l_flag(p_line_num)              := g_rec_lines.array_calculate_g_l_flag(p_line_num) ;
g_mpa_recog_lines.array_gain_or_loss_flag(p_line_num)               := g_rec_lines.array_gain_or_loss_flag(p_line_num)  ;
--
-- line flexfield accounts
--
g_mpa_recog_lines.array_accounting_coa_id(p_line_num)               := g_rec_lines.array_accounting_coa_id(p_line_num)  ;
g_mpa_recog_lines.array_transaction_coa_id(p_line_num)              := g_rec_lines.array_transaction_coa_id(p_line_num) ;
g_mpa_recog_lines.array_sl_coa_mapping_name(p_line_num)             := g_rec_lines.array_sl_coa_mapping_name(p_line_num) ;
g_mpa_recog_lines.array_ccid_flag(p_line_num)                       := g_rec_lines.array_ccid_flag(p_line_num)      ;
g_mpa_recog_lines.array_ccid(p_line_num)                            := g_rec_lines.array_ccid(p_line_num)  ;
 --                                    				     --
g_mpa_recog_lines.array_segment1(p_line_num)                        := g_rec_lines.array_segment1(p_line_num)  ;
g_mpa_recog_lines.array_segment2(p_line_num)                        := g_rec_lines.array_segment2(p_line_num)  ;
g_mpa_recog_lines.array_segment3(p_line_num)                        := g_rec_lines.array_segment3(p_line_num)  ;
g_mpa_recog_lines.array_segment4(p_line_num)                        := g_rec_lines.array_segment4(p_line_num)  ;
g_mpa_recog_lines.array_segment5(p_line_num)                        := g_rec_lines.array_segment5(p_line_num)  ;
g_mpa_recog_lines.array_segment6(p_line_num)                        := g_rec_lines.array_segment6(p_line_num)  ;
g_mpa_recog_lines.array_segment7(p_line_num)                        := g_rec_lines.array_segment7(p_line_num)  ;
g_mpa_recog_lines.array_segment8(p_line_num)                        := g_rec_lines.array_segment8(p_line_num)  ;
g_mpa_recog_lines.array_segment9(p_line_num)                        := g_rec_lines.array_segment9(p_line_num)  ;
g_mpa_recog_lines.array_segment10(p_line_num)                       := g_rec_lines.array_segment10(p_line_num) ;
g_mpa_recog_lines.array_segment11(p_line_num)                       := g_rec_lines.array_segment11(p_line_num) ;
g_mpa_recog_lines.array_segment12(p_line_num)                       := g_rec_lines.array_segment12(p_line_num) ;
g_mpa_recog_lines.array_segment13(p_line_num)                       := g_rec_lines.array_segment13(p_line_num) ;
g_mpa_recog_lines.array_segment14(p_line_num)                       := g_rec_lines.array_segment14(p_line_num) ;
g_mpa_recog_lines.array_segment15(p_line_num)                       := g_rec_lines.array_segment15(p_line_num) ;
g_mpa_recog_lines.array_segment16(p_line_num)                       := g_rec_lines.array_segment16(p_line_num) ;
g_mpa_recog_lines.array_segment17(p_line_num)                       := g_rec_lines.array_segment17(p_line_num) ;
g_mpa_recog_lines.array_segment18(p_line_num)                       := g_rec_lines.array_segment18(p_line_num) ;
g_mpa_recog_lines.array_segment19(p_line_num)                       := g_rec_lines.array_segment19(p_line_num) ;
g_mpa_recog_lines.array_segment20(p_line_num)                       := g_rec_lines.array_segment20(p_line_num) ;
g_mpa_recog_lines.array_segment21(p_line_num)                       := g_rec_lines.array_segment21(p_line_num) ;
g_mpa_recog_lines.array_segment22(p_line_num)                       := g_rec_lines.array_segment22(p_line_num) ;
g_mpa_recog_lines.array_segment23(p_line_num)                       := g_rec_lines.array_segment23(p_line_num) ;
g_mpa_recog_lines.array_segment24(p_line_num)                       := g_rec_lines.array_segment24(p_line_num) ;
g_mpa_recog_lines.array_segment25(p_line_num)                       := g_rec_lines.array_segment25(p_line_num) ;
g_mpa_recog_lines.array_segment26(p_line_num)                       := g_rec_lines.array_segment26(p_line_num) ;
g_mpa_recog_lines.array_segment27(p_line_num)                       := g_rec_lines.array_segment27(p_line_num) ;
g_mpa_recog_lines.array_segment28(p_line_num)                       := g_rec_lines.array_segment28(p_line_num) ;
g_mpa_recog_lines.array_segment29(p_line_num)                       := g_rec_lines.array_segment29(p_line_num) ;
g_mpa_recog_lines.array_segment30(p_line_num)                       := g_rec_lines.array_segment30(p_line_num) ;
g_mpa_recog_lines.alt_array_ccid_flag(p_line_num)                   := g_rec_lines.alt_array_ccid_flag(p_line_num)  ;
g_mpa_recog_lines.alt_array_ccid(p_line_num)                        := g_rec_lines.alt_array_ccid(p_line_num)       ;
g_mpa_recog_lines.alt_array_segment1(p_line_num)                    := g_rec_lines.alt_array_segment1(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment2(p_line_num)                    := g_rec_lines.alt_array_segment2(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment3(p_line_num)                    := g_rec_lines.alt_array_segment3(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment4(p_line_num)                    := g_rec_lines.alt_array_segment4(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment5(p_line_num)                    := g_rec_lines.alt_array_segment5(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment6(p_line_num)                    := g_rec_lines.alt_array_segment6(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment7(p_line_num)                    := g_rec_lines.alt_array_segment7(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment8(p_line_num)                    := g_rec_lines.alt_array_segment8(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment9(p_line_num)                    := g_rec_lines.alt_array_segment9(p_line_num)   ;
g_mpa_recog_lines.alt_array_segment10(p_line_num)                   := g_rec_lines.alt_array_segment10(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment11(p_line_num)                   := g_rec_lines.alt_array_segment11(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment12(p_line_num)                   := g_rec_lines.alt_array_segment12(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment13(p_line_num)                   := g_rec_lines.alt_array_segment13(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment14(p_line_num)                   := g_rec_lines.alt_array_segment14(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment15(p_line_num)                   := g_rec_lines.alt_array_segment15(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment16(p_line_num)                   := g_rec_lines.alt_array_segment16(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment17(p_line_num)                   := g_rec_lines.alt_array_segment17(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment18(p_line_num)                   := g_rec_lines.alt_array_segment18(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment19(p_line_num)                   := g_rec_lines.alt_array_segment19(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment20(p_line_num)                   := g_rec_lines.alt_array_segment20(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment21(p_line_num)                   := g_rec_lines.alt_array_segment21(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment22(p_line_num)                   := g_rec_lines.alt_array_segment22(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment23(p_line_num)                   := g_rec_lines.alt_array_segment23(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment24(p_line_num)                   := g_rec_lines.alt_array_segment24(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment25(p_line_num)                   := g_rec_lines.alt_array_segment25(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment26(p_line_num)                   := g_rec_lines.alt_array_segment26(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment27(p_line_num)                   := g_rec_lines.alt_array_segment27(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment28(p_line_num)                   := g_rec_lines.alt_array_segment28(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment29(p_line_num)                   := g_rec_lines.alt_array_segment29(p_line_num)  ;
g_mpa_recog_lines.alt_array_segment30(p_line_num)                   := g_rec_lines.alt_array_segment30(p_line_num)  ;
--
-- Option lines
--
g_mpa_recog_lines.array_gl_transfer_mode(p_line_num)                := g_rec_lines.array_gl_transfer_mode(p_line_num)  ;
g_mpa_recog_lines.array_natural_side_code(p_line_num)               := g_rec_lines.array_natural_side_code(p_line_num) ;
g_mpa_recog_lines.array_acct_entry_type_code(p_line_num)            := g_rec_lines.array_acct_entry_type_code(p_line_num) ;
g_mpa_recog_lines.array_switch_side_flag(p_line_num)                := g_rec_lines.array_switch_side_flag(p_line_num)  ;
g_mpa_recog_lines.array_merge_duplicate_code(p_line_num)            := g_rec_lines.array_merge_duplicate_code(p_line_num) ;
 --
 -- line amounts
 --
g_mpa_recog_lines.array_entered_amount(p_line_num)                  := g_rec_lines.array_entered_amount(p_line_num)  ;
g_mpa_recog_lines.array_ledger_amount(p_line_num)                   := g_rec_lines.array_ledger_amount(p_line_num)   ;
g_mpa_recog_lines.array_entered_dr(p_line_num)                      := g_rec_lines.array_entered_dr(p_line_num)      ;
g_mpa_recog_lines.array_entered_cr(p_line_num)                      := g_rec_lines.array_entered_cr(p_line_num)      ;
g_mpa_recog_lines.array_accounted_dr(p_line_num)                    := g_rec_lines.array_accounted_dr(p_line_num)    ;
g_mpa_recog_lines.array_accounted_cr(p_line_num)                    := g_rec_lines.array_accounted_cr(p_line_num)    ;
g_mpa_recog_lines.array_currency_code(p_line_num)                   := g_rec_lines.array_currency_code(p_line_num)   ;
g_mpa_recog_lines.array_currency_mau(p_line_num)                    := g_rec_lines.array_currency_mau(p_line_num)    ;
g_mpa_recog_lines.array_curr_conversion_date(p_line_num)            := g_rec_lines.array_curr_conversion_date(p_line_num) ;
g_mpa_recog_lines.array_curr_conversion_rate(p_line_num)            := g_rec_lines.array_curr_conversion_rate(p_line_num) ;
g_mpa_recog_lines.array_curr_conversion_type(p_line_num)            := g_rec_lines.array_curr_conversion_type(p_line_num) ;
g_mpa_recog_lines.array_description(p_line_num)                     := g_rec_lines.array_description(p_line_num)     ;
 --
 -- line descriptions
 --
g_mpa_recog_lines.array_party_id(p_line_num)                        := g_rec_lines.array_party_id(p_line_num)        ;
g_mpa_recog_lines.array_party_site_id(p_line_num)                   := g_rec_lines.array_party_site_id(p_line_num)   ;
g_mpa_recog_lines.array_party_type_code(p_line_num)                 := g_rec_lines.array_party_type_code(p_line_num) ;
 --
g_mpa_recog_lines.array_statistical_amount(p_line_num)              := g_rec_lines.array_statistical_amount(p_line_num)   ;
g_mpa_recog_lines.array_ussgl_transaction(p_line_num)               := g_rec_lines.array_ussgl_transaction(p_line_num)    ;
--
g_mpa_recog_lines.array_jgzz_recon_ref(p_line_num)                  := g_rec_lines.array_jgzz_recon_ref(p_line_num)       ;
-- distribution links
--
g_mpa_recog_lines.array_distribution_id_char_1(p_line_num)         := g_rec_lines.array_distribution_id_char_1(p_line_num) ;
g_mpa_recog_lines.array_distribution_id_char_2(p_line_num)         := g_rec_lines.array_distribution_id_char_2(p_line_num) ;
g_mpa_recog_lines.array_distribution_id_char_3(p_line_num)         := g_rec_lines.array_distribution_id_char_3(p_line_num) ;
g_mpa_recog_lines.array_distribution_id_char_4(p_line_num)         := g_rec_lines.array_distribution_id_char_4(p_line_num) ;
g_mpa_recog_lines.array_distribution_id_char_5(p_line_num)         := g_rec_lines.array_distribution_id_char_5(p_line_num) ;
g_mpa_recog_lines.array_sys_distribution_type(p_line_num)          := g_rec_lines.array_sys_distribution_type(p_line_num)  ;
g_mpa_recog_lines.array_distribution_id_num_1(p_line_num)          := g_rec_lines.array_distribution_id_num_1(p_line_num)  ;
g_mpa_recog_lines.array_distribution_id_num_2(p_line_num)          := g_rec_lines.array_distribution_id_num_2(p_line_num)  ;
g_mpa_recog_lines.array_distribution_id_num_3(p_line_num)          := g_rec_lines.array_distribution_id_num_3(p_line_num)  ;
g_mpa_recog_lines.array_distribution_id_num_4(p_line_num)          := g_rec_lines.array_distribution_id_num_4(p_line_num)  ;
g_mpa_recog_lines.array_distribution_id_num_5(p_line_num)          := g_rec_lines.array_distribution_id_num_5(p_line_num)  ;
--
-- reversal attributes
--
g_mpa_recog_lines.array_rev_dist_id_char_1(p_line_num)             := g_rec_lines.array_rev_dist_id_char_1(p_line_num)     ;
g_mpa_recog_lines.array_rev_dist_id_char_2(p_line_num)             := g_rec_lines.array_rev_dist_id_char_2(p_line_num)     ;
g_mpa_recog_lines.array_rev_dist_id_char_3(p_line_num)             := g_rec_lines.array_rev_dist_id_char_3(p_line_num)     ;
g_mpa_recog_lines.array_rev_dist_id_char_4(p_line_num)             := g_rec_lines.array_rev_dist_id_char_4(p_line_num)     ;
g_mpa_recog_lines.array_rev_dist_id_char_5(p_line_num)             := g_rec_lines.array_rev_dist_id_char_5(p_line_num)     ;
g_mpa_recog_lines.array_rev_dist_id_num_1(p_line_num)              := g_rec_lines.array_rev_dist_id_num_1(p_line_num)      ;
g_mpa_recog_lines.array_rev_dist_id_num_2(p_line_num)              := g_rec_lines.array_rev_dist_id_num_2(p_line_num)      ;
g_mpa_recog_lines.array_rev_dist_id_num_3(p_line_num)              := g_rec_lines.array_rev_dist_id_num_3(p_line_num)      ;
g_mpa_recog_lines.array_rev_dist_id_num_4(p_line_num)              := g_rec_lines.array_rev_dist_id_num_4(p_line_num)      ;
g_mpa_recog_lines.array_rev_dist_id_num_5(p_line_num)              := g_rec_lines.array_rev_dist_id_num_5(p_line_num)      ;
g_mpa_recog_lines.array_rev_dist_type(p_line_num)                  := g_rec_lines.array_rev_dist_type(p_line_num)          ;
--
---------------------------------------
-- 4262811  MPA
---------------------------------------
g_mpa_recog_lines.array_header_num(p_line_num)                     := g_rec_lines.array_header_num(p_line_num)             ;
g_mpa_recog_lines.array_mpa_acc_entry_flag(p_line_num)             := g_rec_lines.array_mpa_acc_entry_flag(p_line_num)     ;
g_mpa_recog_lines.array_mpa_option(p_line_num)                     := g_rec_lines.array_mpa_option(p_line_num)             ;
g_mpa_recog_lines.array_mpa_start_date(p_line_num)                 := g_rec_lines.array_mpa_start_date(p_line_num)         ;
g_mpa_recog_lines.array_mpa_end_date(p_line_num)                   := g_rec_lines.array_mpa_end_date(p_line_num)           ;
-- deferred info  -- REMOVED for 426281
--
-- array_deferred_indicator
-- array_deferred_start_date
-- array_deferred_end_date
-- array_deferred_no_period
-- array_deferred_period_type
--
-- reversal info
--
g_mpa_recog_lines.array_acc_reversal_option(p_line_num)            := g_rec_lines.array_acc_reversal_option(p_line_num)    ;
--
-- tax info
--
g_mpa_recog_lines.array_tax_line_ref(p_line_num)                   := g_rec_lines.array_tax_line_ref(p_line_num)           ;
g_mpa_recog_lines.array_tax_summary_line_ref(p_line_num)           := g_rec_lines.array_tax_summary_line_ref(p_line_num)   ;
g_mpa_recog_lines.array_tax_rec_nrec_dist_ref(p_line_num)          := g_rec_lines.array_tax_rec_nrec_dist_ref(p_line_num)  ;
--
-- bulk performance(p_line_num)
g_mpa_recog_lines.array_balance_type_code(p_line_num)              := g_rec_lines.array_balance_type_code(p_line_num)      ;
g_mpa_recog_lines.array_ledger_id(p_line_num)                      := g_rec_lines.array_ledger_id(p_line_num)              ;
--
g_mpa_recog_lines.array_anc_balance_flag(p_line_num)               := g_rec_lines.array_anc_balance_flag(p_line_num)       ;
g_mpa_recog_lines.array_anc_id_1(p_line_num)                       := g_rec_lines.array_anc_id_1(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_2(p_line_num)                       := g_rec_lines.array_anc_id_2(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_3(p_line_num)                       := g_rec_lines.array_anc_id_3(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_4(p_line_num)                       := g_rec_lines.array_anc_id_4(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_5(p_line_num)                       := g_rec_lines.array_anc_id_5(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_6(p_line_num)                       := g_rec_lines.array_anc_id_6(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_7(p_line_num)                       := g_rec_lines.array_anc_id_7(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_8(p_line_num)                       := g_rec_lines.array_anc_id_8(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_9(p_line_num)                       := g_rec_lines.array_anc_id_9(p_line_num)               ;
g_mpa_recog_lines.array_anc_id_10(p_line_num)                      := g_rec_lines.array_anc_id_10(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_11(p_line_num)                      := g_rec_lines.array_anc_id_11(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_12(p_line_num)                      := g_rec_lines.array_anc_id_12(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_13(p_line_num)                      := g_rec_lines.array_anc_id_13(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_14(p_line_num)                      := g_rec_lines.array_anc_id_14(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_15(p_line_num)                      := g_rec_lines.array_anc_id_15(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_16(p_line_num)                      := g_rec_lines.array_anc_id_16(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_17(p_line_num)                      := g_rec_lines.array_anc_id_17(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_18(p_line_num)                      := g_rec_lines.array_anc_id_18(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_19(p_line_num)                      := g_rec_lines.array_anc_id_19(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_20(p_line_num)                      := g_rec_lines.array_anc_id_20(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_21(p_line_num)                      := g_rec_lines.array_anc_id_21(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_22(p_line_num)                      := g_rec_lines.array_anc_id_22(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_23(p_line_num)                      := g_rec_lines.array_anc_id_23(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_24(p_line_num)                      := g_rec_lines.array_anc_id_24(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_25(p_line_num)                      := g_rec_lines.array_anc_id_25(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_26(p_line_num)                      := g_rec_lines.array_anc_id_26(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_27(p_line_num)                      := g_rec_lines.array_anc_id_27(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_28(p_line_num)                      := g_rec_lines.array_anc_id_28(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_29(p_line_num)                      := g_rec_lines.array_anc_id_29(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_30(p_line_num)                      := g_rec_lines.array_anc_id_30(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_31(p_line_num)                      := g_rec_lines.array_anc_id_31(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_32(p_line_num)                      := g_rec_lines.array_anc_id_32(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_33(p_line_num)                      := g_rec_lines.array_anc_id_33(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_34(p_line_num)                      := g_rec_lines.array_anc_id_34(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_35(p_line_num)                      := g_rec_lines.array_anc_id_35(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_36(p_line_num)                      := g_rec_lines.array_anc_id_36(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_37(p_line_num)                      := g_rec_lines.array_anc_id_37(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_38(p_line_num)                      := g_rec_lines.array_anc_id_38(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_39(p_line_num)                      := g_rec_lines.array_anc_id_39(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_40(p_line_num)                      := g_rec_lines.array_anc_id_40(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_41(p_line_num)                      := g_rec_lines.array_anc_id_41(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_42(p_line_num)                      := g_rec_lines.array_anc_id_42(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_43(p_line_num)                      := g_rec_lines.array_anc_id_43(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_44(p_line_num)                      := g_rec_lines.array_anc_id_44(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_45(p_line_num)                      := g_rec_lines.array_anc_id_45(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_46(p_line_num)                      := g_rec_lines.array_anc_id_46(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_47(p_line_num)                      := g_rec_lines.array_anc_id_47(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_48(p_line_num)                      := g_rec_lines.array_anc_id_48(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_49(p_line_num)                      := g_rec_lines.array_anc_id_49(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_50(p_line_num)                      := g_rec_lines.array_anc_id_50(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_51(p_line_num)                      := g_rec_lines.array_anc_id_51(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_52(p_line_num)                      := g_rec_lines.array_anc_id_52(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_53(p_line_num)                      := g_rec_lines.array_anc_id_53(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_54(p_line_num)                      := g_rec_lines.array_anc_id_54(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_55(p_line_num)                      := g_rec_lines.array_anc_id_55(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_56(p_line_num)                      := g_rec_lines.array_anc_id_56(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_57(p_line_num)                      := g_rec_lines.array_anc_id_57(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_58(p_line_num)                      := g_rec_lines.array_anc_id_58(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_59(p_line_num)                      := g_rec_lines.array_anc_id_59(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_60(p_line_num)                      := g_rec_lines.array_anc_id_60(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_61(p_line_num)                      := g_rec_lines.array_anc_id_61(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_62(p_line_num)                      := g_rec_lines.array_anc_id_62(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_63(p_line_num)                      := g_rec_lines.array_anc_id_63(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_64(p_line_num)                      := g_rec_lines.array_anc_id_64(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_65(p_line_num)                      := g_rec_lines.array_anc_id_65(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_66(p_line_num)                      := g_rec_lines.array_anc_id_66(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_67(p_line_num)                      := g_rec_lines.array_anc_id_67(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_68(p_line_num)                      := g_rec_lines.array_anc_id_68(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_69(p_line_num)                      := g_rec_lines.array_anc_id_69(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_70(p_line_num)                      := g_rec_lines.array_anc_id_70(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_71(p_line_num)                      := g_rec_lines.array_anc_id_71(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_72(p_line_num)                      := g_rec_lines.array_anc_id_72(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_73(p_line_num)                      := g_rec_lines.array_anc_id_73(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_74(p_line_num)                      := g_rec_lines.array_anc_id_74(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_75(p_line_num)                      := g_rec_lines.array_anc_id_75(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_76(p_line_num)                      := g_rec_lines.array_anc_id_76(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_77(p_line_num)                      := g_rec_lines.array_anc_id_77(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_78(p_line_num)                      := g_rec_lines.array_anc_id_78(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_79(p_line_num)                      := g_rec_lines.array_anc_id_79(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_80(p_line_num)                      := g_rec_lines.array_anc_id_80(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_81(p_line_num)                      := g_rec_lines.array_anc_id_81(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_82(p_line_num)                      := g_rec_lines.array_anc_id_82(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_83(p_line_num)                      := g_rec_lines.array_anc_id_83(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_84(p_line_num)                      := g_rec_lines.array_anc_id_84(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_85(p_line_num)                      := g_rec_lines.array_anc_id_85(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_86(p_line_num)                      := g_rec_lines.array_anc_id_86(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_87(p_line_num)                      := g_rec_lines.array_anc_id_87(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_88(p_line_num)                      := g_rec_lines.array_anc_id_88(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_89(p_line_num)                      := g_rec_lines.array_anc_id_89(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_90(p_line_num)                      := g_rec_lines.array_anc_id_90(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_91(p_line_num)                      := g_rec_lines.array_anc_id_91(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_92(p_line_num)                      := g_rec_lines.array_anc_id_92(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_93(p_line_num)                      := g_rec_lines.array_anc_id_93(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_94(p_line_num)                      := g_rec_lines.array_anc_id_94(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_95(p_line_num)                      := g_rec_lines.array_anc_id_95(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_96(p_line_num)                      := g_rec_lines.array_anc_id_96(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_97(p_line_num)                      := g_rec_lines.array_anc_id_97(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_98(p_line_num)                      := g_rec_lines.array_anc_id_98(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_99(p_line_num)                      := g_rec_lines.array_anc_id_99(p_line_num)              ;
g_mpa_recog_lines.array_anc_id_100(p_line_num)                     := g_rec_lines.array_anc_id_100(p_line_num)             ;
--
g_mpa_recog_lines.array_event_number(p_line_num)                   := g_rec_lines.array_event_number(p_line_num)           ;
g_mpa_recog_lines.array_entity_id(p_line_num)                      := g_rec_lines.array_entity_id(p_line_num)              ;
g_mpa_recog_lines.array_reversal_code(p_line_num)                  := g_rec_lines.array_reversal_code(p_line_num)          ;
--------------------------------------
-- 4219869
-- Business Flow Applied To Attributes
--------------------------------------
g_mpa_recog_lines.array_business_method_code(p_line_num)           := g_rec_lines.array_business_method_code(p_line_num)   ;
g_mpa_recog_lines.array_business_class_code(p_line_num)            := g_rec_lines.array_business_class_code(p_line_num)    ;
g_mpa_recog_lines.array_inherit_desc_flag(p_line_num)              := g_rec_lines.array_inherit_desc_flag(p_line_num)      ;
g_mpa_recog_lines.array_bflow_application_id(p_line_num)           := g_rec_lines.array_bflow_application_id(p_line_num)   ;
g_mpa_recog_lines.array_bflow_entity_code(p_line_num)              := g_rec_lines.array_bflow_entity_code(p_line_num)      ;
g_mpa_recog_lines.array_bflow_source_id_num_1(p_line_num)          := g_rec_lines.array_bflow_source_id_num_1(p_line_num)  ;
g_mpa_recog_lines.array_bflow_source_id_num_2(p_line_num)          := g_rec_lines.array_bflow_source_id_num_2(p_line_num)  ;
g_mpa_recog_lines.array_bflow_source_id_num_3(p_line_num)          := g_rec_lines.array_bflow_source_id_num_3(p_line_num)  ;
g_mpa_recog_lines.array_bflow_source_id_num_4(p_line_num)          := g_rec_lines.array_bflow_source_id_num_4(p_line_num)  ;
g_mpa_recog_lines.array_bflow_source_id_char_1(p_line_num)         := g_rec_lines.array_bflow_source_id_char_1(p_line_num) ;
g_mpa_recog_lines.array_bflow_source_id_char_2(p_line_num)         := g_rec_lines.array_bflow_source_id_char_2(p_line_num) ;
g_mpa_recog_lines.array_bflow_source_id_char_3(p_line_num)         := g_rec_lines.array_bflow_source_id_char_3(p_line_num) ;
g_mpa_recog_lines.array_bflow_source_id_char_4(p_line_num)         := g_rec_lines.array_bflow_source_id_char_4(p_line_num) ;
g_mpa_recog_lines.array_bflow_distribution_type(p_line_num)        := g_rec_lines.array_bflow_distribution_type(p_line_num);
g_mpa_recog_lines.array_bflow_dist_id_num_1(p_line_num)            := g_rec_lines.array_bflow_dist_id_num_1(p_line_num)    ;
g_mpa_recog_lines.array_bflow_dist_id_num_2(p_line_num)            := g_rec_lines.array_bflow_dist_id_num_2(p_line_num)    ;
g_mpa_recog_lines.array_bflow_dist_id_num_3(p_line_num)            := g_rec_lines.array_bflow_dist_id_num_3(p_line_num)    ;
g_mpa_recog_lines.array_bflow_dist_id_num_4(p_line_num)            := g_rec_lines.array_bflow_dist_id_num_4(p_line_num)    ;
g_mpa_recog_lines.array_bflow_dist_id_num_5(p_line_num)            := g_rec_lines.array_bflow_dist_id_num_5(p_line_num)    ;
g_mpa_recog_lines.array_bflow_dist_id_char_1(p_line_num)           := g_rec_lines.array_bflow_dist_id_char_1(p_line_num)   ;
g_mpa_recog_lines.array_bflow_dist_id_char_2(p_line_num)           := g_rec_lines.array_bflow_dist_id_char_2(p_line_num)   ;
g_mpa_recog_lines.array_bflow_dist_id_char_3(p_line_num)           := g_rec_lines.array_bflow_dist_id_char_3(p_line_num)   ;
g_mpa_recog_lines.array_bflow_dist_id_char_4(p_line_num)           := g_rec_lines.array_bflow_dist_id_char_4(p_line_num)   ;
g_mpa_recog_lines.array_bflow_dist_id_char_5(p_line_num)           := g_rec_lines.array_bflow_dist_id_char_5(p_line_num)   ;
g_mpa_recog_lines.array_override_acctd_amt_flag(p_line_num)        := g_rec_lines.array_override_acctd_amt_flag(p_line_num);
g_mpa_recog_lines.array_bflow_applied_to_amt(p_line_num)           := g_rec_lines.array_bflow_applied_to_amt(p_line_num)   ;

g_mpa_recog_lines.array_encumbrance_type_id(p_line_num)            := g_rec_lines.array_encumbrance_type_id(p_line_num)    ;
g_mpa_recog_lines.array_gl_date(p_line_num)                        := g_rec_lines.array_gl_date(p_line_num)                ;

---------------------------------------
--
--Upgrade Attributes
--
---------------------------------------

g_mpa_recog_lines.array_actual_upg_option(p_line_num)              := g_rec_lines.array_actual_upg_option(p_line_num)      ;
g_mpa_recog_lines.array_actual_upg_dr_ccid(p_line_num)             := g_rec_lines.array_actual_upg_dr_ccid(p_line_num)     ;
g_mpa_recog_lines.array_actual_upg_cr_ccid(p_line_num)             := g_rec_lines.array_actual_upg_cr_ccid(p_line_num)     ;
g_mpa_recog_lines.array_actual_upg_dr_ent_amt(p_line_num)          := g_rec_lines.array_actual_upg_dr_ent_amt(p_line_num)  ;
g_mpa_recog_lines.array_actual_upg_cr_ent_amt(p_line_num)          := g_rec_lines.array_actual_upg_cr_ent_amt(p_line_num)  ;
g_mpa_recog_lines.array_actual_upg_dr_ent_curr(p_line_num)         := g_rec_lines.array_actual_upg_dr_ent_curr(p_line_num) ;
g_mpa_recog_lines.array_actual_upg_cr_ent_curr(p_line_num)         := g_rec_lines.array_actual_upg_cr_ent_curr(p_line_num) ;
g_mpa_recog_lines.array_actual_upg_dr_ledger_amt(p_line_num)       := g_rec_lines.array_actual_upg_dr_ledger_amt(p_line_num);
g_mpa_recog_lines.array_actual_upg_cr_ledger_amt(p_line_num)       := g_rec_lines.array_actual_upg_cr_ledger_amt(p_line_num);
g_mpa_recog_lines.array_actual_upg_dr_acct_class(p_line_num)       := g_rec_lines.array_actual_upg_dr_acct_class(p_line_num);
g_mpa_recog_lines.array_actual_upg_cr_acct_class(p_line_num)       := g_rec_lines.array_actual_upg_cr_acct_class(p_line_num);
g_mpa_recog_lines.array_actual_upg_dr_xrate(p_line_num)            := g_rec_lines.array_actual_upg_dr_xrate(p_line_num)    ;
g_mpa_recog_lines.array_actual_upg_dr_xrate_type(p_line_num)       := g_rec_lines.array_actual_upg_dr_xrate_type(p_line_num);
g_mpa_recog_lines.array_actual_upg_dr_xdate(p_line_num)            := g_rec_lines.array_actual_upg_dr_xdate(p_line_num)    ;
g_mpa_recog_lines.array_actual_upg_cr_xrate(p_line_num)            := g_rec_lines.array_actual_upg_cr_xrate(p_line_num)    ;
g_mpa_recog_lines.array_actual_upg_cr_xrate_type(p_line_num)       := g_rec_lines.array_actual_upg_cr_xrate_type(p_line_num);
g_mpa_recog_lines.array_actual_upg_cr_xdate(p_line_num)            := g_rec_lines.array_actual_upg_cr_xdate(p_line_num)    ;
g_mpa_recog_lines.array_enc_upg_option(p_line_num)                 := g_rec_lines.array_enc_upg_option(p_line_num)         ;
g_mpa_recog_lines.array_enc_upg_dr_ccid(p_line_num)                := g_rec_lines.array_enc_upg_dr_ccid(p_line_num)        ;
g_mpa_recog_lines.array_enc_upg_cr_ccid(p_line_num)                := g_rec_lines.array_enc_upg_cr_ccid(p_line_num)        ;
g_mpa_recog_lines.array_upg_dr_enc_type_id(p_line_num)             := g_rec_lines.array_upg_dr_enc_type_id(p_line_num)     ;
g_mpa_recog_lines.array_upg_cr_enc_type_id(p_line_num)             := g_rec_lines.array_upg_cr_enc_type_id(p_line_num)     ;
g_mpa_recog_lines.array_enc_upg_dr_ent_amt(p_line_num)             := g_rec_lines.array_enc_upg_dr_ent_amt(p_line_num)     ;
g_mpa_recog_lines.array_enc_upg_cr_ent_amt(p_line_num)             := g_rec_lines.array_enc_upg_cr_ent_amt(p_line_num)     ;
g_mpa_recog_lines.array_enc_upg_dr_ent_curr(p_line_num)            := g_rec_lines.array_enc_upg_dr_ent_curr(p_line_num)    ;
g_mpa_recog_lines.array_enc_upg_cr_ent_curr(p_line_num)            := g_rec_lines.array_enc_upg_cr_ent_curr(p_line_num)    ;
g_mpa_recog_lines.array_enc_upg_dr_ledger_amt(p_line_num)          := g_rec_lines.array_enc_upg_dr_ledger_amt(p_line_num)  ;
g_mpa_recog_lines.array_enc_upg_cr_ledger_amt(p_line_num)          := g_rec_lines.array_enc_upg_cr_ledger_amt(p_line_num)  ;
g_mpa_recog_lines.array_enc_upg_dr_acct_class(p_line_num)          := g_rec_lines.array_enc_upg_dr_acct_class(p_line_num)  ;
g_mpa_recog_lines.array_enc_upg_cr_acct_class(p_line_num)          := g_rec_lines.array_enc_upg_cr_acct_class(p_line_num)  ;
 -- 5845547                            				     -- 5845547
g_mpa_recog_lines.array_upg_party_id(p_line_num)                   := g_rec_lines.array_upg_party_id(p_line_num)           ;
g_mpa_recog_lines.array_upg_party_site_id(p_line_num)              := g_rec_lines.array_upg_party_site_id(p_line_num)      ;
g_mpa_recog_lines.array_upg_party_type_code(p_line_num)            := g_rec_lines.array_upg_party_type_code(p_line_num)    ;
 --
---------------------------------------
--
--Allocation Attributes
--
---------------------------------------
g_mpa_recog_lines.array_alloct_application_id(p_line_num)          := g_rec_lines.array_alloct_application_id(p_line_num)  ;
g_mpa_recog_lines.array_alloct_entity_code(p_line_num)             := g_rec_lines.array_alloct_entity_code(p_line_num)     ;
g_mpa_recog_lines.array_alloct_source_id_num_1(p_line_num)         := g_rec_lines.array_alloct_source_id_num_1(p_line_num) ;
g_mpa_recog_lines.array_alloct_source_id_num_2(p_line_num)         := g_rec_lines.array_alloct_source_id_num_2(p_line_num) ;
g_mpa_recog_lines.array_alloct_source_id_num_3(p_line_num)         := g_rec_lines.array_alloct_source_id_num_3(p_line_num) ;
g_mpa_recog_lines.array_alloct_source_id_num_4(p_line_num)         := g_rec_lines.array_alloct_source_id_num_4(p_line_num) ;
g_mpa_recog_lines.array_alloct_source_id_char_1(p_line_num)        := g_rec_lines.array_alloct_source_id_char_1(p_line_num);
g_mpa_recog_lines.array_alloct_source_id_char_2(p_line_num)        := g_rec_lines.array_alloct_source_id_char_2(p_line_num);
g_mpa_recog_lines.array_alloct_source_id_char_3(p_line_num)        := g_rec_lines.array_alloct_source_id_char_3(p_line_num);
g_mpa_recog_lines.array_alloct_source_id_char_4(p_line_num)        := g_rec_lines.array_alloct_source_id_char_4(p_line_num);
g_mpa_recog_lines.array_alloct_distribution_type(p_line_num)       := g_rec_lines.array_alloct_distribution_type(p_line_num);
g_mpa_recog_lines.array_alloct_dist_id_num_1(p_line_num)           := g_rec_lines.array_alloct_dist_id_num_1(p_line_num)   ;
g_mpa_recog_lines.array_alloct_dist_id_num_2(p_line_num)           := g_rec_lines.array_alloct_dist_id_num_2(p_line_num)   ;
g_mpa_recog_lines.array_alloct_dist_id_num_3(p_line_num)           := g_rec_lines.array_alloct_dist_id_num_3(p_line_num)   ;
g_mpa_recog_lines.array_alloct_dist_id_num_4(p_line_num)           := g_rec_lines.array_alloct_dist_id_num_4(p_line_num)   ;
g_mpa_recog_lines.array_alloct_dist_id_num_5(p_line_num)           := g_rec_lines.array_alloct_dist_id_num_5(p_line_num)   ;
g_mpa_recog_lines.array_alloct_dist_id_char_1(p_line_num)          := g_rec_lines.array_alloct_dist_id_char_1(p_line_num)  ;
g_mpa_recog_lines.array_alloct_dist_id_char_2(p_line_num)          := g_rec_lines.array_alloct_dist_id_char_2(p_line_num)  ;
g_mpa_recog_lines.array_alloct_dist_id_char_3(p_line_num)          := g_rec_lines.array_alloct_dist_id_char_3(p_line_num)  ;
g_mpa_recog_lines.array_alloct_dist_id_char_4(p_line_num)          := g_rec_lines.array_alloct_dist_id_char_4(p_line_num)  ;
g_mpa_recog_lines.array_alloct_dist_id_char_5(p_line_num)          := g_rec_lines.array_alloct_dist_id_char_5(p_line_num)  ;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
           (p_msg      => 'END InsertMPARecogLineInfo'
           ,p_level    => C_LEVEL_PROCEDURE
           ,p_module   => l_log_module);
END IF;

EXCEPTION
--
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS  THEN
      xla_exceptions_pkg.raise_message
               (p_location => 'xla_ae_lines_pkg.InsertMPARecogLineInfo');
  --
END InsertMPARecogLineInfo;

/*======================================================================+
|                                                                       |
| Public Procedure- SetNullMPALineInfo  7109881                         |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetNullMPALineInfo
IS
	l_log_module         VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.SetNullMPALineInfo';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
	   (p_msg      => 'BEGIN of SetNullMPALineInfo'
	   ,p_level    => C_LEVEL_PROCEDURE
	   ,p_module   => l_log_module);
   END IF;

   XLA_AE_LINES_PKG.g_mpa_recog_lines := NULL ;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
	   (p_msg      => 'End of SetNullMPALineInfo'
	   ,p_level    => C_LEVEL_PROCEDURE
	   ,p_module   => l_log_module);
   END IF;
EXCEPTION
--
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS  THEN
      xla_exceptions_pkg.raise_message
	       (p_location => 'xla_ae_lines_pkg.SetNullMPALineInfo');
  --
END SetNullMPALineInfo;


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
   g_application_id := xla_accounting_cache_pkg.GetValueNum('XLA_EVENT_APPL_ID');

   ----------------------------------------
   -- 4219869 Init Business Flow counts
   ----------------------------------------
   g_num_bflow_prior_entries := 0;
   g_num_bflow_same_entries  := 0;

   ----------------------------------------
   -- 5108415 Incomplete MPA
   ----------------------------------------
   g_incomplete_mpa_acc_LR := NULL;
   g_incomplete_mpa_acc_TR := NULL;

   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;

END xla_ae_lines_pkg;

/
