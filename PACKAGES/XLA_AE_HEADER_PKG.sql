--------------------------------------------------------
--  DDL for Package XLA_AE_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AE_HEADER_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajehdr.pkh 120.20.12010000.1 2008/07/29 10:05:13 appldev ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_ae_header_pkg                                                      |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema    Created                                      |
|     10-JAN-2003 K.Boussema    Added 'dbdrv' command                        |
|     10-MAR-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     03-APR-2003 K.Boussema    Included Analytical criteria feature         |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     22-APR-2003 K.Boussema    Added DOC_CATEGORY_NAME source               |
|     11-JUN-2003 K.Boussema    Renamed Sequence columns, bug 3000007        |
|     17-JUL-2003 K.Boussema    Reviewd the code                             |
|     17-SEP-2003 K.Boussema    Updated to Get je_category from cache:3109690|
|     19-SEP-2003 K.Boussema    Code changed to include reversed_ae_header_id|
|                               and reversed_line_num, see bug 3143095       |
|     12-DEC-2003 K.Boussema    Reviewed for bug bug 3042840                 |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940   |
|                               3310291 and 3320689                          |
|     17-May-2004 W.Shen        add gl_transfer_flag, gl_date,               |
|                               and trx_acct_reversal_option to t_rec_header |
|                               This is for attribute enhancement project    |
|                               add transactionreversal procedure from       |
|                               xla_ae_lines_pkg                             |
|     21-Sep-2004 S.Singhania   Made ffg changes for the Bulk Performance:   |
|                                 -- Obsoleted structure t_rec_header        |
|                                 -- Obsoleted SetHeaderId, GetHeaderId,     |
|                                    SetHdrAccountingSource (all of three),  |
|                                    and TransactionReversal.                |
|                                 -- Added strucntures t_rec_header_new and  |
|                                    t_rec_acct_attrs                        |
|                                 -- Added routine SetHdrAcctAttrs.          |
|     11-Jul-2005 A.Wan         Changed for MPA.  4262811                    |
|     18-Oct-2005 V. Kumar    Removed code for Analytical Criteria           |
|     20-JAN-2006 A.Wan       4884853 add GetAccrualRevDate                  |
|     15-Apr-2006 A.Wan       5132302 applied to amt for Gain/Loss           |
+===========================================================================*/

--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| PUBLIC structures                                                        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
TYPE t_array_number   IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE t_array_integer  IS TABLE OF INTEGER        INDEX BY BINARY_INTEGER;
TYPE t_array_date     IS TABLE OF DATE           INDEX BY BINARY_INTEGER;
TYPE t_array_char1    IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE t_array_char30   IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE t_array_char240  IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE t_array_char2000 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
--
TYPE t_rec_acct_attrs IS RECORD
   (array_acct_attr_code        t_array_char30
   ,array_num_value             t_array_number
   ,array_char_value            t_array_char2000
   ,array_date_value            t_array_date);


--
TYPE t_rec_header_new IS RECORD
(
--
array_event_type_code             t_array_char30,
array_event_id                    t_array_number,
array_event_number                t_array_number,
array_entity_id                   t_array_number,
array_target_ledger_id            t_array_number,
--
array_actual_header_id             t_array_number,
array_budget_header_id             t_array_number,
array_encumb_header_id             t_array_number,
--
array_je_category_name             t_array_char30,
array_period_name                  t_array_char30,
--
array_description                  t_array_char2000,
--
array_doc_sequence_id              t_array_number,
array_doc_sequence_value           t_array_number,
array_doc_category_code            t_array_char30,
array_budget_version_id            t_array_number,
-- array_encumbrance_type_id       t_array_number, -- 4458381 Public Sector Enh
--
array_actual_status                t_array_integer,
array_budget_status                t_array_integer,
array_encumbrance_status           t_array_integer,
array_event_status                 t_array_char1,
--
array_party_change_option          t_array_char1,
array_party_change_type            t_array_char1,
array_new_party_id                 t_array_number,
array_new_party_site_id            t_array_number,
array_previous_party_id            t_array_number,
array_previous_party_site_id       t_array_number,
array_gl_transfer_flag             t_array_char1,
array_trx_acct_reversal_option     t_array_char1,
array_gl_date                      t_array_date,
--
array_header_num                   t_array_number,  -- 4262811
array_accrual_reversal_flag        t_array_char1,   -- 4262811
array_acc_rev_gl_date_option       t_array_char30,  -- 4262811
array_parent_header_id             t_array_number,  -- 4262811
array_parent_line_num              t_array_number,  -- 4262811
--
array_anc_id_1                     t_array_char240,
array_anc_id_2                     t_array_char240,
array_anc_id_3                     t_array_char240,
array_anc_id_4                     t_array_char240,
array_anc_id_5                     t_array_char240,
array_anc_id_6                     t_array_char240,
array_anc_id_7                     t_array_char240,
array_anc_id_8                     t_array_char240,
array_anc_id_9                     t_array_char240,
array_anc_id_10                    t_array_char240,
array_anc_id_11                    t_array_char240,
array_anc_id_12                    t_array_char240,
array_anc_id_13                    t_array_char240,
array_anc_id_14                    t_array_char240,
array_anc_id_15                    t_array_char240,
array_anc_id_16                    t_array_char240,
array_anc_id_17                    t_array_char240,
array_anc_id_18                    t_array_char240,
array_anc_id_19                    t_array_char240,
array_anc_id_20                    t_array_char240,
array_anc_id_21                    t_array_char240,
array_anc_id_22                    t_array_char240,
array_anc_id_23                    t_array_char240,
array_anc_id_24                    t_array_char240,
array_anc_id_25                    t_array_char240,
array_anc_id_26                    t_array_char240,
array_anc_id_27                    t_array_char240,
array_anc_id_28                    t_array_char240,
array_anc_id_29                    t_array_char240,
array_anc_id_30                    t_array_char240,
array_anc_id_31                    t_array_char240,
array_anc_id_32                    t_array_char240,
array_anc_id_33                    t_array_char240,
array_anc_id_34                    t_array_char240,
array_anc_id_35                    t_array_char240,
array_anc_id_36                    t_array_char240,
array_anc_id_37                    t_array_char240,
array_anc_id_38                    t_array_char240,
array_anc_id_39                    t_array_char240,
array_anc_id_40                    t_array_char240,
array_anc_id_41                    t_array_char240,
array_anc_id_42                    t_array_char240,
array_anc_id_43                    t_array_char240,
array_anc_id_44                    t_array_char240,
array_anc_id_45                    t_array_char240,
array_anc_id_46                    t_array_char240,
array_anc_id_47                    t_array_char240,
array_anc_id_48                    t_array_char240,
array_anc_id_49                    t_array_char240,
array_anc_id_50                    t_array_char240,
array_anc_id_51                    t_array_char240,
array_anc_id_52                    t_array_char240,
array_anc_id_53                    t_array_char240,
array_anc_id_54                    t_array_char240,
array_anc_id_55                    t_array_char240,
array_anc_id_56                    t_array_char240,
array_anc_id_57                    t_array_char240,
array_anc_id_58                    t_array_char240,
array_anc_id_59                    t_array_char240,
array_anc_id_60                    t_array_char240,
array_anc_id_61                    t_array_char240,
array_anc_id_62                    t_array_char240,
array_anc_id_63                    t_array_char240,
array_anc_id_64                    t_array_char240,
array_anc_id_65                    t_array_char240,
array_anc_id_66                    t_array_char240,
array_anc_id_67                    t_array_char240,
array_anc_id_68                    t_array_char240,
array_anc_id_69                    t_array_char240,
array_anc_id_70                    t_array_char240,
array_anc_id_71                    t_array_char240,
array_anc_id_72                    t_array_char240,
array_anc_id_73                    t_array_char240,
array_anc_id_74                    t_array_char240,
array_anc_id_75                    t_array_char240,
array_anc_id_76                    t_array_char240,
array_anc_id_77                    t_array_char240,
array_anc_id_78                    t_array_char240,
array_anc_id_79                    t_array_char240,
array_anc_id_80                    t_array_char240,
array_anc_id_81                    t_array_char240,
array_anc_id_82                    t_array_char240,
array_anc_id_83                    t_array_char240,
array_anc_id_84                    t_array_char240,
array_anc_id_85                    t_array_char240,
array_anc_id_86                    t_array_char240,
array_anc_id_87                    t_array_char240,
array_anc_id_88                    t_array_char240,
array_anc_id_89                    t_array_char240,
array_anc_id_90                    t_array_char240,
array_anc_id_91                    t_array_char240,
array_anc_id_92                    t_array_char240,
array_anc_id_93                    t_array_char240,
array_anc_id_94                    t_array_char240,
array_anc_id_95                    t_array_char240,
array_anc_id_96                    t_array_char240,
array_anc_id_97                    t_array_char240,
array_anc_id_98                    t_array_char240,
array_anc_id_99                    t_array_char240,
array_anc_id_100                   t_array_char240
);
--
--
/*======================================================================+
|                                                                       |
|  Variable Global                                                      |
|                                                                       |
+======================================================================*/
--
g_rec_header_new         t_rec_header_new;
g_header_idx             number;
g_mpa_line_num           number;   -- 4262811
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE InitHeader
       (p_header_idx       in number);
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
);

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
, p_calculate_acctd_flag IN VARCHAR2  -- 4262811b
, p_same_currency        IN BOOLEAN   -- 4262811b
, p_accted_amt           IN NUMBER
, p_entered_amt          IN NUMBER
, p_bflow_applied_to_amt  IN NUMBER                                           -- 5132302
, x_num_entries          IN OUT NOCOPY NUMBER
, x_gl_dates             IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_date
, x_accted_amts          IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_num
, x_entered_amts         IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_num
, x_period_names         IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_V15L
, x_bflow_applied_to_amts  IN OUT NOCOPY xla_ae_journal_entry_pkg.t_array_num  -- 5132302
);


/*======================================================================+
|                                                                       |
| Public Procedure - 4262811                                            |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE CopyHeaderInfo(
   p_parent_hdr_idx   IN NUMBER
 , p_hdr_idx          IN NUMBER
);

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
) RETURN NUMBER;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
-- This might not be required with bulk performance changes
--
/*
PROCEDURE SetHeaderId( p_ae_header_id        IN NUMBER
                     , p_actual_flag         IN VARCHAR2
                     , p_budget_flag         IN VARCHAR2
                     , p_encumbrance_flag    IN VARCHAR2
                     )
;
*/
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetHdrDescription(
 p_description         IN VARCHAR2
)
;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
/*
PROCEDURE SetHdrAccountingSource (
  p_accounting_source      IN VARCHAR2
, p_standard_source        IN VARCHAR2
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN NUMBER
)
;
*/
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
/*
PROCEDURE SetHdrAccountingSource (
  p_accounting_source      IN VARCHAR2
, p_standard_source        IN NUMBER
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN NUMBER
)
;
*/
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
/*
PROCEDURE SetHdrAccountingSource (
  p_accounting_source      IN VARCHAR2
, p_standard_source        IN DATE
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN NUMBER
)
;
*/
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE SetJeCategoryName
;
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
--
)
RETURN VARCHAR2
;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--
/*
FUNCTION  GetHeaderId(p_balance_type_code IN VARCHAR2)
RETURN NUMBER
;
*/
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
FUNCTION InsertHeaders
RETURN BOOLEAN
;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE change_third_party
;
--
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE RefreshHeader
;

/*
PROCEDURE TransactionReversal
;
*/
--
-- bulk performance
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
procedure SetHdrAcctAttrs
       (p_rec_acct_attrs    in t_rec_acct_attrs);
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE ValidateBusinessDate
(p_ledger_id                      IN NUMBER);

END xla_ae_header_pkg; -- end of package spec

/
