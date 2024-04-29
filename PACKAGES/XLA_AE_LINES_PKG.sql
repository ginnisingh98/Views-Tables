--------------------------------------------------------
--  DDL for Package XLA_AE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AE_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajelns.pkh 120.44.12010000.2 2009/05/07 05:21:00 vgopiset ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_ae_lines_pkg                                                       |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema  Created                                        |
|     10-JAN-2003 K.Boussema  Removed gl_sl_link_id column from temp table   |
|                             Added 'dbdrv' command                          |
|     11-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     03-APR-2003 K.Boussema    Included Analytical criteria feature         |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     06-MAI-2003 K.Boussema    Modified to fix bug 2936066(Unbalanced JE)   |
|     27-MAI-2003 K.Boussema    Renamed code_combination_status by           |
|                                  code_combination_status_flag              |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     24-JUL-2003 K.Boussema    Updated the error messages                   |
|     10-SEP-2003 K.Boussema    Changed to fix bug3095206:Accounting Reversal|
|     13-NOV-2003 K.Boussema    Changed to store Accounting and transaction  |
|                               coa ids defined in Account Derivation rules  |
|     05-DEC-2003 K.Boussema    Changed the code to fix bug3289875           |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     05-FEB-2004 S.Singhania   Changes based on bug 3419803. Modified the   |
|                                 structure t_rec_lines to remove the        |
|                                 attribute representing the column          |
|                                 TAX_REC_NREC_SUMMARY_DIST_REF.             |
|     17-FEB-2004 K.Boussema    Removed array_accounting_line_name and       |
|                               array_accounting_line_owner from t_rec_lines |
|     17-MAY-2004 W.Shen        change for attribute enhancement project     |
|                                 add StandardAccountingReversal to spec     |
|     21-Sep-2004 S.Singhania   Made ffg changes for the Bulk Performance:   |
|                                 - Added new structures and global variables|
|                                 - Removed the routines SetAccountingSource,|
|                                   accounting_reversal and StandardAccountin|
|                                   gReversal                                |
|                                 - Added routines AccountingReversal,       |
|                                   set_ae_header_id, SetLineAcctAttrs,      |
|                                   SetAcctReversalAttrs, SetTrxReversalAttrs|
|     09-MAR-2005 W.Shen       Ledger Currency Project.                      |
|     14-Mar-2005 K.Boussema   Changed for ADR-enhancements.                 |
|     28-Mar-2005 A.Wan        Changed for Business Flow. 4219869            |
|     11-Jul-2005 A.Wan        Changed for MPA.  4642811                     |
|     22-Sep-2005 S.Singhania  Bug 4544725. Implemented Business Flows and   |
|                                Reversals for Non-Upgraded JEs.             |
|     18-Oct-2005 V. Kumar    Removed code for Analytical Criteria           |
|     20-Jan-2006 W.Chan      4946123 - BC changes for prior entry           |
|     09-Feb-2006 V. Kumar    4955764 - Added array_gl_date to t_rec_lines   |
|     27-Mar-2006 A.Wan       5108415 - performance fix for Incomplete       |
|                                       MPA/AccRev. Added following:         |
|                                       - type t_rec_incomplete_mpa_acc_rev  |
|                                       - global g_incomplete_mpa_acc_LR     |
|                                       - global g_incomplete_mpa_acc_TR     |
|                                       - p_accounting_mode to accounting    |
|                                         reversal.                          |
|     15-Apr-2006 A.Wan       5132302 - add Applied To Amount for Gain/Loss  |
|     19-May-2005 V.Kumar     5229264 -Modified procedure SetTrxReversalAttrs|
|     28-Jul-2006 A.Wan       5357406 - add p_ledger_id to bflow prior entry |
|     26-jan-2007 A.Wan       5845547 - upgrade fail for not upgraded bflow  |
|                                       and reversal transactions.  Add      |
|                                       upgrade party attributes.            |
|     14-Dec-2007 V.Swapna    6648062 - Added override_acctd_amt_flag        |
|                                       to t_rec_lines to be used in the     |
|                                       BusinessFlowPriorEntries procedure   |
|     01-Mar-2009 VGOPISET    7109881   Included new procedures like         |
|                                   InsertMPARecogLineInfo,SetNullMPALineInfo|
|                                   Over Loaded CopyLineInfo and added a new |
|                                   global variable G_MPA_RECOG_LINES        |
+===========================================================================*/
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| PUBLIC structures                                                        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
TYPE t_array_number   IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE t_array_integer  IS TABLE OF INTEGER        INDEX BY BINARY_INTEGER;
TYPE t_array_date     IS TABLE OF DATE           INDEX BY BINARY_INTEGER;
TYPE t_array_char1    IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE t_array_char30   IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE t_array_char240  IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE t_array_char2000 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

TYPE t_rec_acct_attrs IS RECORD
(array_acct_attr_code        t_array_char30
,array_num_value             t_array_number
,array_char_value            t_array_char2000
,array_date_value            t_array_date);
--
--
TYPE t_rec_lines IS RECORD (
 array_ae_header_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_line_num                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_extract_line_num                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_accounting_class                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_rounding_class                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_doc_rounding_level                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_gain_or_loss_ref                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_event_class_code                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_event_type_code                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_line_defn_owner_code              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_line_defn_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_accounting_line_code              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_accounting_line_type              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_calculate_acctd_flag              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_calculate_g_l_flag                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_gain_or_loss_flag                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
--
-- line flexfield accounts
--
,array_accounting_coa_id                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_transaction_coa_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_sl_coa_mapping_name               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V33L
,array_ccid_flag                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_ccid                              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
 --
,array_segment1                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment2                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment3                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment4                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment5                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment6                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment7                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment8                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment9                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment10                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment11                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment12                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment13                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment14                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment15                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment16                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment17                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment18                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment19                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment20                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment21                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment22                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment23                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment24                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment25                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment26                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment27                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment28                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment29                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_segment30                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_ccid_flag                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_ccid                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,alt_array_segment1                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment2                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment3                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment4                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment5                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment6                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment7                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment8                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment9                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment10                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment11                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment12                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment13                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment14                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment15                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment16                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment17                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment18                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment19                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment20                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment21                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment22                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment23                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment24                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment25                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment26                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment27                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment28                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment29                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,alt_array_segment30                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
--
-- Option lines
--
,array_gl_transfer_mode                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_natural_side_code                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_acct_entry_type_code              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_switch_side_flag                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_merge_duplicate_code              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
 --
 -- line amounts
 --
,array_entered_amount                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_ledger_amount                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_entered_dr                        XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_entered_cr                        XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_accounted_dr                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_accounted_cr                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_currency_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V15L
,array_currency_mau                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_curr_conversion_date              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date
,array_curr_conversion_rate              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_curr_conversion_type              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_description                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_V4000L
 --
 -- line descriptions
 --
,array_party_id                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_party_site_id                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_party_type_code                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
 --
,array_statistical_amount                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_ussgl_transaction                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
--
,array_jgzz_recon_ref                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
-- distribution links
--
,array_distribution_id_char_1            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_distribution_id_char_2            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_distribution_id_char_3            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_distribution_id_char_4            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_distribution_id_char_5            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_sys_distribution_type             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_distribution_id_num_1             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_distribution_id_num_2             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_distribution_id_num_3             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_distribution_id_num_4             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_distribution_id_num_5             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
--
-- reversal attributes
--
,array_rev_dist_id_char_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_char_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_char_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_char_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_char_5                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_num_1                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_num_2                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_num_3                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_num_4                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_id_num_5                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_rev_dist_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
--
-----------------------------------------------------------------------------------------
-- 4262811  MPA
-----------------------------------------------------------------------------------------
,array_header_num                        XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_mpa_acc_entry_flag                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_mpa_option                        XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_mpa_start_date                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_DATE
,array_mpa_end_date                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_DATE

-- deferred info  -- REMOVED for 4262811 MPA
--
-- array_deferred_indicator              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L,
-- array_deferred_start_date             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date,
-- array_deferred_end_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date,
-- array_deferred_no_period              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num,
-- array_deferred_period_type            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L,
--
-- reversal info
--
,array_acc_reversal_option               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
--
-- tax info
--
,array_tax_line_ref                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_tax_summary_line_ref              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_tax_rec_nrec_dist_ref             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
--
-- bulk performance
,array_balance_type_code                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_ledger_id                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
--
,array_anc_balance_flag                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_anc_id_1                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_2                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_3                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_4                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_5                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_6                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_7                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_8                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_9                          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_10                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_11                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_12                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_13                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_14                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_15                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_16                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_17                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_18                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_19                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_20                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_21                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_22                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_23                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_24                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_25                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_26                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_27                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_28                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_29                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_30                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_31                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_32                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_33                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_34                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_35                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_36                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_37                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_38                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_39                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_40                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_41                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_42                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_43                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_44                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_45                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_46                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_47                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_48                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_49                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_50                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_51                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_52                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_53                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_54                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_55                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_56                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_57                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_58                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_59                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_60                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_61                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_62                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_63                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_64                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_65                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_66                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_67                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_68                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_69                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_70                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_71                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_72                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_73                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_74                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_75                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_76                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_77                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_78                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_79                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_80                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_81                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_82                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_83                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_84                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_85                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_86                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_87                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_88                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_89                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_90                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_91                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_92                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_93                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_94                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_95                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_96                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_97                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_98                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_99                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_anc_id_100                        XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L

--
,array_event_number                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Int
,array_entity_id                         XLA_AE_JOURNAL_ENTRY_PKG.t_array_Int
,array_reversal_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
--------------------------------------
-- 4219869
-- Business Flow Applied To Attributes
--------------------------------------
,array_business_method_code              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_business_class_code               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_inherit_desc_flag                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
,array_bflow_application_id              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num

,array_bflow_entity_code                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_bflow_source_id_num_1             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_source_id_num_2             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_source_id_num_3             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_source_id_num_4             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_source_id_char_1            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_bflow_source_id_char_2            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_bflow_source_id_char_3            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_bflow_source_id_char_4            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L

,array_bflow_distribution_type           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_bflow_dist_id_num_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_dist_id_num_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_dist_id_num_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_dist_id_num_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_dist_id_num_5               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_bflow_dist_id_char_1              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_bflow_dist_id_char_2              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_bflow_dist_id_char_3              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_bflow_dist_id_char_4              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_bflow_dist_id_char_5              XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_override_acctd_amt_flag           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_bflow_applied_to_amt              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num  -- 5132302

,array_encumbrance_type_id               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Int
,array_gl_date                           XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date  --4955764

-------------------------------------------------
--
--Upgrade Attributes
--
-------------------------------------------------

,array_actual_upg_option                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_actual_upg_dr_ccid                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_actual_upg_cr_ccid                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_actual_upg_dr_ent_amt             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_actual_upg_cr_ent_amt             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_actual_upg_dr_ent_curr            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_actual_upg_cr_ent_curr            XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_actual_upg_dr_ledger_amt          XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_actual_upg_cr_ledger_amt          XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_actual_upg_dr_acct_class          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_actual_upg_cr_acct_class          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_actual_upg_dr_xrate               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_actual_upg_dr_xrate_type          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_actual_upg_dr_xdate               XLA_AE_JOURNAL_ENTRY_PKG.t_array_DATE
,array_actual_upg_cr_xrate               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_actual_upg_cr_xrate_type          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_actual_upg_cr_xdate               XLA_AE_JOURNAL_ENTRY_PKG.t_array_DATE
,array_enc_upg_option                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_enc_upg_dr_ccid                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_enc_upg_cr_ccid                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_upg_dr_enc_type_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_upg_cr_enc_type_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_enc_upg_dr_ent_amt                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_enc_upg_cr_ent_amt                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_enc_upg_dr_ent_curr               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_enc_upg_cr_ent_curr               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_enc_upg_dr_ledger_amt             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_enc_upg_cr_ledger_amt             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_enc_upg_dr_acct_class             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_enc_upg_cr_acct_class             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
 -- 5845547
,array_upg_party_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_upg_party_site_id                 XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_upg_party_type_code               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V1L
 --
-------------------------------------------------
--
--Allocation Attributes
--
-------------------------------------------------
,array_alloct_application_id             XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_entity_code                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_alloct_source_id_num_1            XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_source_id_num_2            XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_source_id_num_3            XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_source_id_num_4            XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_source_id_char_1           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_alloct_source_id_char_2           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_alloct_source_id_char_3           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_alloct_source_id_char_4           XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_alloct_distribution_type          XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
,array_alloct_dist_id_num_1              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_dist_id_num_2              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_dist_id_num_3              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_dist_id_num_4              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_dist_id_num_5              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
,array_alloct_dist_id_char_1             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_alloct_dist_id_char_2             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_alloct_dist_id_char_3             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_alloct_dist_id_char_4             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
,array_alloct_dist_id_char_5             XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
);

-- 5108415 for incomplete MPA/AccRev reversal
TYPE t_rec_incomplete_mpa_acc_rev IS RECORD (
l_array_ae_header_id       XLA_AE_JOURNAL_ENTRY_PKG.t_array_num,
l_array_ae_line_num        XLA_AE_JOURNAL_ENTRY_PKG.t_array_num,
l_array_parent_ae_header   XLA_AE_JOURNAL_ENTRY_PKG.t_array_num
);

--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--|  GLobal variables                                                        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
g_rec_lines                    t_rec_lines;
g_null_lines                   t_rec_lines;
g_mpa_recog_lines              t_rec_lines; -- added for bug:7109881
--
g_override_acctd_amt_flag      VARCHAR2(1);
g_LineNumber                   NUMBER;
g_ExtractLine                  NUMBER;
g_ActualLineNum                NUMBER;
g_BudgetLineNum                NUMBER;
g_EncumbLineNum                NUMBER;
--
g_temp_line_num                NUMBER;
--
g_incomplete_mpa_acc_LR        t_rec_incomplete_mpa_acc_rev;  -- 5108415 for incomplete MPA/AccRev line reversal
g_incomplete_mpa_acc_TR        t_rec_incomplete_mpa_acc_rev;  -- 5108415 for incomplete MPA/AccRev transaction reversal

g_hist_reversal_error_exists  BOOLEAN DEFAULT FALSE;    --bug7135700


--
--====================================================================
--
--
--
--
--
--                    STANDARD ACCOUNTING PROCESS
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
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE InitLines
;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetExtractLine(p_extract_line IN NUMBER)
;

--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetNullLine
;

--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetNewLine
;

--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetLineDescription( p_description     IN VARCHAR2
                             ,p_ae_header_id    IN NUMBER DEFAULT NULL)
;

--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|    SetCcid                                                            |
|                                                                       |
+======================================================================*/
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
;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|    SetSegment                                                         |
|                                                                       |
+======================================================================*/
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
;


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
;

--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION SetAcctLineOption(
  p_natural_side_code          IN VARCHAR2
, p_gain_or_loss_flag          IN VARCHAR2
, p_gl_transfer_mode_code      IN VARCHAR2
, p_acct_entry_type_code       IN VARCHAR2
, p_switch_side_flag           IN VARCHAR2
, p_merge_duplicate_code       IN VARCHAR2
)
RETURN NUMBER
;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetAcctClass( p_accounting_class_code      IN VARCHAR2
                      , p_ae_header_id               IN NUMBER DEFAULT NULL
)
;
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
 , p_analytical_detail_char_1     IN VARCHAR2 DEFAULT NULL
 , p_analytical_detail_num_1      IN NUMBER   DEFAULT NULL
 , p_analytical_detail_date_1     IN DATE     DEFAULT NULL
 , p_analytical_detail_char_2     IN VARCHAR2 DEFAULT NULL
 , p_analytical_detail_num_2      IN NUMBER   DEFAULT NULL
 , p_analytical_detail_date_2     IN DATE     DEFAULT NULL
 , p_analytical_detail_char_3     IN VARCHAR2 DEFAULT NULL
 , p_analytical_detail_num_3      IN NUMBER   DEFAULT NULL
 , p_analytical_detail_date_3     IN DATE     DEFAULT NULL
 , p_analytical_detail_char_4     IN VARCHAR2 DEFAULT NULL
 , p_analytical_detail_num_4      IN NUMBER   DEFAULT NULL
 , p_analytical_detail_date_4     IN DATE     DEFAULT NULL
 , p_analytical_detail_char_5     IN VARCHAR2 DEFAULT NULL
 , p_analytical_detail_num_5      IN NUMBER   DEFAULT NULL
 , p_analytical_detail_date_5     IN DATE     DEFAULT NULL
 , p_ae_header_id                 IN NUMBER   DEFAULT NULL
--
)
RETURN VARCHAR2
;

--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION InsertLines
RETURN BOOLEAN
;
--
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
;
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
;
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
;
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
;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/

--;
PROCEDURE AccountingReversal(
  p_accounting_mode        IN VARCHAR2
);

--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE RefreshLines
;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|   ValidateCurrentLine                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE ValidateCurrentLine
;

--
--bulk performance
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
procedure set_ae_header_id
       (p_ae_header_id      in number
       ,p_header_num        in NUMBER);  -- 4262811

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
procedure SetLineAcctAttrs
       (p_rec_acct_attrs    in t_rec_acct_attrs);

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
       ,p_calculate_g_l_flag       IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetTrxReversalAttrs
       (p_event_id                     IN NUMBER
       ,p_gl_date                      IN DATE
       ,p_trx_reversal_source          IN VARCHAR2);

PROCEDURE CalculateUnroundedAmounts;

PROCEDURE CalculateGainLossAmounts;

/*======================================================================+
|                                                                       |
| Public Procedure- Business Flow Validaton - 4219869                   |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE Business_Flow_Validation
       (p_business_method_code         IN VARCHAR2
       ,p_business_class_code          IN VARCHAR2
       ,p_inherit_description_flag     IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure- Business Flow Prior Entry - 4219869                 |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE BusinessFlowPriorEntries
       (p_accounting_mode              IN VARCHAR2
       ,p_ledger_id                    IN NUMBER
       ,p_bc_mode                      IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Procedure- Business Flow Same Entry - 4219869                  |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE BusinessFlowSameEntries;

/*======================================================================+
|                                                                       |
| Public Procedure- Validate Business Flow Applied To Links - 4219869   |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE ValidateBFlowLinks;

/*======================================================================+
|                                                                       |
| Public Procedure- 4219869 : making this public for  Business Flow     |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetDebitCreditAmounts;

/*======================================================================+
|                                                                       |
| Public Procedure- 4262811                                             |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE CopyLineInfo(
   p_line_num   NUMBER
);

/*======================================================================+
|                                                                       |
| Public Procedure- 7109881                                             |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE CopyLineInfo(
   p_line_num   NUMBER,
   p_rec_lines IN t_rec_lines
);

/*======================================================================+
|                                                                       |
| Public Procedure- 7109881                                             |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE InsertMPARecogLineInfo(
   p_line_num   NUMBER
);

/*======================================================================+
|                                                                       |
| Public Procedure- 7109881                                             |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetNullMPALineInfo;

PROCEDURE BflowUpgEntry
       (p_business_method_code      IN VARCHAR2
       ,p_business_class_code       IN VARCHAR2
       ,p_balance_type              IN VARCHAR2);

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
)
;
END xla_ae_lines_pkg; -- end of package spec

/
