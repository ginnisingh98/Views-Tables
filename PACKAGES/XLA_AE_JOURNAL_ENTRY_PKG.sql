--------------------------------------------------------
--  DDL for Package XLA_AE_JOURNAL_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AE_JOURNAL_ENTRY_PKG" AUTHID CURRENT_USER AS
/* $Header: xlajejex.pkh 120.25.12010000.1 2008/07/29 10:05:29 appldev ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_ae_journal_entry_pkg                                               |
|                                                                            |
| DESCRIPTION                                                                |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     20-NOV-2002 K.Boussema    Created                                      |
|     10-JAN-2003 K.Boussema    Added 'dbdrv' command                        |
|     20-FEB-2003 K.Boussema    Made changes for the new bulk approach of the|
|                               accounting engine                            |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     05-MAI-2003 K.Boussema    Added sla_ledger_id in ledger cache          |
|     07-MAI-2003 K.Boussema    Added event_created_by in event cache        |
|     17-JUL-2003 K.Boussema    Updated the call to accounting cache, 3055039|
|     29-JAN-2003 K.Boussema    Reviewed the code to solve bug 3072881       |
|     13-NOV-2003 K.Boussema    Increased the size of sl_coa_mapping_name    |
|     26-NOV-2003 K.Boussema    Added the pl/sql structure t_array_V33L      |
|     21-Sep-2004 S.Singhania   Made ffg changes for the Bulk Performance:   |
|                                 -- Defined new structures and global       |
|                                    variables.                              |
|                                 -- Defined a new constant C_RELATED_INVALID|
|                                 -- Modified routines GetLedgersInfo and    |
|                                    InsertJournalEntries                    |
|                                 -- Added new routine set_event_info        |
|                                 -- Removed routine cache_event_info        |
|     06-Oct-2004 K.Boussema    Made changes for the Accounting Event Extract|
|                               Diagnostics feature.                         |
|     09-Mar-2005 W. Shen       Ledger Currency Project                      |
|                               change the type definition t_rec_ledgers_info|
|                               Add a new function adjust_display_line_num   |
|     14-Mar-2005 K.Boussema Changed for ADR-enhancements.                   |
|     10-May-2005 W. Shen    Ledger currency Project. Add transaction_date   |
|                               to t_rec_event(will add to procedure         |
|                               set_event_info later)                        |
|                               remove the adjust_display_linenum function   |
|     26-May-2005 A. Wan     4262811 MPA project                             |
|     1-Jul-2005 W. Shen      add calculate_amts_flag to ledger cache        |
|                               add ledger_category_code to ledger_cache     |
+===========================================================================*/
--
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| PUBLIC structures                                                        |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
TYPE t_array_value_num  IS TABLE OF NUMBER        INDEX BY VARCHAR2(30);
TYPE t_array_value_char IS TABLE OF VARCHAR2(240) INDEX BY VARCHAR2(30);
TYPE t_array_value_date IS TABLE OF DATE          INDEX BY VARCHAR2(30);

TYPE t_array_header_num IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER; -- 4262811

TYPE t_rec_value IS RECORD
 (array_value_num     t_array_value_num
 ,array_value_char    t_array_value_char
 ,array_value_date    t_array_value_date);

TYPE t_array_event IS TABLE OF  t_rec_value INDEX BY BINARY_INTEGER;

g_array_event        t_array_event;
g_null_array_event   t_array_event;

TYPE t_array_event_id     IS TABLE OF NUMBER      INDEX BY BINARY_INTEGER;
TYPE t_array_ledger_id    IS TABLE OF NUMBER      INDEX BY BINARY_INTEGER;
TYPE t_array_balance_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE t_array_ae_header_id IS TABLE OF NUMBER      INDEX BY BINARY_INTEGER;

--
--
TYPE t_array_V1L    IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE t_array_V15L   IS TABLE OF VARCHAR2(15)   INDEX BY BINARY_INTEGER;
TYPE t_array_V25L   IS TABLE OF VARCHAR2(25)   INDEX BY BINARY_INTEGER;
TYPE t_array_V30L   IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE t_array_V33L   IS TABLE OF VARCHAR2(33)   INDEX BY BINARY_INTEGER;
TYPE t_array_V80L   IS TABLE OF VARCHAR2(80)   INDEX BY BINARY_INTEGER;
TYPE t_array_V100L  IS TABLE OF VARCHAR2(100)  INDEX BY BINARY_INTEGER;
TYPE t_array_V240L  IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE t_array_V4000L IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE t_array_Num    IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE t_array_Int    IS TABLE OF INTEGER        INDEX BY BINARY_INTEGER;
TYPE t_array_Date   IS TABLE OF DATE           INDEX BY BINARY_INTEGER;
--
--
TYPE t_rec_event_tl IS RECORD
   (event_class_name                   VARCHAR2(80)
   ,session_event_class                VARCHAR2(80)
   ,event_type_name                    VARCHAR2(80)
   ,session_event_type                 VARCHAR2(80)
   );
--
--
TYPE t_rec_event IS RECORD
   (application_id                 NUMBER
   ,application_name               VARCHAR2(240)
   ,ledger_id                      NUMBER
   ,base_ledger_id                 NUMBER
   ,target_ledger_id               NUMBER
   ,legal_entity_id                NUMBER
   ,entity_id                      NUMBER
   ,entity_code                    VARCHAR2(30)
   ,transaction_num                VARCHAR2(240)
   ,event_id                       NUMBER
   ,event_class                    VARCHAR2(30)
   ,event_type                     VARCHAR2(30)
   ,event_number                   NUMBER
   ,event_date                     DATE
   ,transaction_date               DATE
   ,reference_num_1                NUMBER
   ,reference_num_2                NUMBER
   ,reference_num_3                NUMBER
   ,reference_num_4                NUMBER
   ,reference_char_1               VARCHAR2(240)
   ,reference_char_2               VARCHAR2(240)
   ,reference_char_3               VARCHAR2(240)
   ,reference_char_4               VARCHAR2(240)
   ,reference_date_1               DATE
   ,reference_date_2               DATE
   ,reference_date_3               DATE
   ,reference_date_4               DATE
   ,event_created_by               VARCHAR2(100)
   ,accounting_mode                VARCHAR2(1)
   ,accounting_batch_id            NUMBER
   ,budgetary_control_flag         VARCHAR2(1)
   );
--
-- bulk performance
--
type t_array_event_new is table of t_rec_event index by binary_integer;
--
--
TYPE t_rec_ledgers_info IS RECORD
(
 description_language     VARCHAR2(15)
,nls_desc_language        VARCHAR2(30)
,currency_code            VARCHAR2(30)
,sla_ledger_id            INTEGER
,source_coa_id            INTEGER
,target_coa_id            INTEGER
,ledger_reversal_option   VARCHAR2(30)
,sl_coa_mapping_name      VARCHAR2(33)
,sl_coa_mapping_id        NUMBER
,dynamic_insert_flag      VARCHAR2(1)
,minimum_accountable_unit NUMBER
,rounding_rule_code       VARCHAR2(30)
,ledger_category_code     VARCHAR2(30)
,calculate_amts_flag    VARCHAR2(1)
-- This flag indicate whether the amount needs to be calculate for secondary
-- and alc
)
;
--
--
TYPE t_rec_product_rule IS RECORD
(
product_rule_type_code         VARCHAR2(1),
product_rule_code              VARCHAR2(30),
product_rule_version           VARCHAR2(30),
product_rule_name              VARCHAR2(80),
pad_session_name               VARCHAR2(80),
pad_compile_status             VARCHAR2(1),
amb_context_code               VARCHAR2(30),
pad_package_name               VARCHAR2(30)
)
;
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| PUBLIC constants                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
--
C_FINAL_JE       CONSTANT VARCHAR2(1)      := 'F';
C_INVALID_JE     CONSTANT VARCHAR2(1)      := 'I';
C_DRAFT_JE       CONSTANT VARCHAR2(1)      := 'D';
C_INCOMPLETE_JE  CONSTANT VARCHAR2(1)      := 'N';
--
--
C_ACTUAL            CONSTANT VARCHAR2(1)   := 'A';
C_BUDGET            CONSTANT VARCHAR2(1)   := 'B';
C_ENCUMBRANCE       CONSTANT VARCHAR2(1)   := 'E';
--
C_VALID               CONSTANT NUMBER      := 0;
C_INVALID             CONSTANT NUMBER      := 1;
C_NOT_CREATED         CONSTANT NUMBER      := 2;
--
-- bulk performance
--
C_RELATED_INVALID     CONSTANT NUMBER      := 3;
--
--
-- Accounting entry type code
--
C_STANDARD            CONSTANT VARCHAR2(30)      := 'STANDARD';
--
C_ALL                 CONSTANT  VARCHAR2(1) := 'A';
C_SAME_SIDE           CONSTANT  VARCHAR2(1) := 'W';
C_NO_MERGE            CONSTANT  VARCHAR2(1) := 'N';
--
--
C_NUM                           CONSTANT NUMBER      := 9.99E125;
C_CHAR                          CONSTANT VARCHAR2(1) := '#';
C_DATE                          CONSTANT DATE        := TO_DATE('1','j');
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global variables                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+
--
--
g_array_event_id        t_array_event_id;  -- linear indexed
g_null_array_event_id   t_array_event_id;
g_array_ledger_id       t_array_ledger_id; -- linear indexed
g_array_balance_type    t_array_balance_type; -- linear indexed
g_array_ae_header_id    t_array_ae_header_id; -- linear indexed
g_array_header_num      t_array_ae_header_id; -- 4262811

--
--
g_cache_event                           t_rec_event;
g_cache_event_tl                        t_rec_event_tl;
g_cache_ledgers_info                    t_rec_ledgers_info;
g_cache_pad                             t_rec_product_rule;
g_global_status                         NUMBER         :=2;

--
/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/
--
FUNCTION GetAlternateCurrencyLedger(p_base_ledger_id           IN NUMBER)
RETURN xla_accounting_cache_pkg.t_array_ledger_id
;
--
--
--
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
;
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
;
--
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
|                                                                       |
+======================================================================*/
--

PROCEDURE  SetProductAcctDefinition(
  p_product_rule_code      IN VARCHAR2
, p_product_rule_type_code IN VARCHAR2
, p_product_rule_version   IN VARCHAR2
, p_product_rule_name      IN VARCHAR2
, p_amb_context_code       IN VARCHAR2
);

--
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
,p_primary_ledger_id        IN NUMBER
,p_pad_start_date           IN DATE DEFAULT NULL
,p_pad_end_date             IN DATE DEFAULT NULL
)
RETURN BOOLEAN
;
--
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
;
--
--
/*======================================================================+
|                                                                       |
| Insert final headers and distribution links                           |
|                                                                       |
|                                                                       |
+======================================================================*/
--
FUNCTION InsertJournalEntries(p_application_id                 IN INTEGER
                             ,p_accounting_batch_id            IN NUMBER
                             ,p_end_date                       IN DATE       -- 4262811
                             ,p_accounting_mode                in VARCHAR2
                             ,p_budgetary_control_mode         IN VARCHAR2)  -- 4458381
RETURN NUMBER
;
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
;

/*======================================================================+
|                                                                       |
| Public PROCEDURE - 4262811 (for MPA)                                  |
|                                                                       |
|  Update the journal entry header status for specified balance type.   |
+======================================================================*/
--
PROCEDURE UpdateJournalEntryStatus(  p_hdr_idx              IN NUMBER
)
;

--
/*======================================================================+
|                                                                       |
|                                                                       |
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
   ,p_budgetary_control_flag  IN VARCHAR2);
--

--PROCEDURE adjust_display_line_num(p_application_id in number);

END xla_ae_journal_entry_pkg; -- end of package spec

/
