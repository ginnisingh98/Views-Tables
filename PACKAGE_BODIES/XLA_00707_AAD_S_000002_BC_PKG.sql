--------------------------------------------------------
--  DDL for Package Body XLA_00707_AAD_S_000002_BC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_00707_AAD_S_000002_BC_PKG" AS
--
/*======================================================================+
|                Copyright (c) 1997 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| Package Name                                                          |
|     XLA_00707_AAD_S_000002_BC_PKG                                     |
|                                                                       |
| DESCRIPTION                                                           |
|     Package generated From Product Accounting Definition              |
|      Name    : Cost Management Encumbrance Application Accounting Defi|
|      Code    : COST_MANAGEMENT_ENCUMBRANCE                            |
|      Owner   : PRODUCT                                                |
|      Version :                                                        |
|      AMB Context Code: DEFAULT                                        |
| HISTORY                                                               |
|     Generated at 29-08-2013 at 11:08:57 by user ANONYMOUS             |
+=======================================================================*/
--
--
TYPE t_rec_array_event IS RECORD
   (array_legal_entity_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
   ,array_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
   ,array_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
   ,array_transaction_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
   ,array_event_id                       xla_number_array_type --XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
   ,array_class_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
   ,array_event_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L
   ,array_event_number                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
   ,array_event_date                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date
   ,array_reference_num_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
   ,array_reference_num_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
   ,array_reference_num_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
   ,array_reference_num_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num
   ,array_reference_char_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
   ,array_reference_char_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
   ,array_reference_char_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
   ,array_reference_char_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L
   ,array_reference_date_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date
   ,array_reference_date_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date
   ,array_reference_date_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date
   ,array_reference_date_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date
   ,array_event_created_by               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V100L
   );
--
type t_array_value_num is table of number index by varchar2(30);
type t_array_value_char is table of varchar2(240) index by varchar2(30);
type t_array_value_date is table of date index by varchar2(30);

type t_rec_value is record
 (array_value_num     t_array_value_num
 ,array_value_char    t_array_value_char
 ,array_value_date    t_array_value_date);

type t_array_event is table of  t_rec_value index by binary_integer;

g_array_event   t_array_event;

--=============================================================================
--               *********** Diagnostics **********
--=============================================================================

g_diagnostics_mode          VARCHAR2(1);
g_last_hdr_idx              NUMBER;        -- 4262811 MPA
g_hdr_extract_count         PLS_INTEGER;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.XLA_00707_AAD_S_000002_BC_PKG';

C_CHAR                CONSTANT       VARCHAR2(30) := fnd_global.local_chr(12); -- 4219869 Business flow
C_NUM                 CONSTANT       NUMBER       := 9.99E125;                 -- 4219869 Business flow

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2 ) IS
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
             (p_location   => 'XLA_00707_AAD_S_000002_BC_PKG.trace');
END trace;

--
--+============================================+
--|                                            |
--|  PRIVATE  PROCEDURES/FUNCTIONS             |
--|                                            |
--+============================================+
--

--
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    ValidateLookupMeaning                                              |
|                                                                       |
+======================================================================*/
FUNCTION ValidateLookupMeaning(
  p_meaning                IN VARCHAR2
, p_lookup_code            IN VARCHAR2
, p_lookup_type            IN VARCHAR2
, p_source_code            IN VARCHAR2
, p_source_type_code       IN VARCHAR2
, p_source_application_id  IN INTEGER
)
RETURN VARCHAR2
IS
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.ValidateLookupMeaning';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of ValidateLookupMeaning'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace
         (p_msg      => 'p_source_code = '|| p_source_code||
                        ' - p_source_type_code = '|| p_source_type_code||
                        ' - p_source_application_id = '|| p_source_application_id||
                        ' - p_lookup_code = '|| p_lookup_code||
                        ' - p_lookup_type = '|| p_lookup_type||
                        ' - p_meaning = '|| p_meaning
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF p_lookup_code IS NOT NULL AND p_meaning IS NULL THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
   xla_accounting_err_pkg. build_message
               (p_appli_s_name            => 'XLA'
               ,p_msg_name                => 'XLA_AP_NO_LOOKUP_MEANING'
               ,p_token_1                 => 'SOURCE_NAME'
               ,p_value_1                 =>  xla_ae_sources_pkg.GetSourceName(
                                                           p_source_code
                                                         , p_source_type_code
                                                         , p_source_application_id
                                                         )
               ,p_token_2                 => 'LOOKUP_CODE'
               ,p_value_2                 =>  p_lookup_code
               ,p_token_3                 => 'LOOKUP_TYPE'
               ,p_value_3                 =>  p_lookup_type
               ,p_token_4                 => 'PRODUCT_NAME'
               ,p_value_4                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
               ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
               ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
               ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
       );

   IF (C_LEVEL_ERROR >= g_log_level) THEN
           trace
                (p_msg      => 'ERROR: XLA_AP_NO_LOOKUP_MEANING'
                ,p_level    => C_LEVEL_ERROR
                ,p_module   => l_log_module);
   END IF;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
        trace
          (p_msg      => 'END of ValidateLookupMeaning'
          ,p_level    => C_LEVEL_PROCEDURE
          ,p_module   => l_log_module);
END IF;
RETURN p_meaning;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RETURN p_meaning;
WHEN OTHERS  THEN
   xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.ValidateLookupMeaning');
       --
END ValidateLookupMeaning;
--
--

FUNCTION GetMeaning (
  p_flex_value_set_id               IN INTEGER
, p_flex_value                      IN VARCHAR2
, p_source_code                     IN VARCHAR2
, p_source_type_code                IN VARCHAR2
, p_source_application_id           IN INTEGER
)
RETURN VARCHAR2
IS
BEGIN
--
RETURN NULL ;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.GetMeaning');
END GetMeaning;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctDerRule_1
--
---------------------------------------
FUNCTION AcctDerRule_1 (
  p_application_id              IN NUMBER
, p_ae_header_id                IN NUMBER
, p_side                        IN VARCHAR2 
--Cost Management Default Account
 , p_source_1            IN NUMBER
, x_transaction_coa_id         OUT NOCOPY NUMBER
, x_accounting_coa_id          OUT NOCOPY NUMBER
, x_value_type_code            OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
l_component_type       VARCHAR2(80)  ;
l_component_code       VARCHAR2(30)  ;
l_component_type_code  VARCHAR2(1)   ;
l_component_appl_id    INTEGER       ;
l_amb_context_code     VARCHAR2(30)  ;
l_log_module           VARCHAR2(240) ;
l_output_value         NUMBER        ;
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctDerRule_1';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of AcctDerRule_1'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
l_component_type         := 'AMB_ADR';
l_component_code         := 'CST_DEFAULT';
l_component_type_code    := 'S';
l_component_appl_id      :=  707;
l_amb_context_code       := 'DEFAULT';
x_transaction_coa_id     :=  null;
x_accounting_coa_id      :=  null;
--

 --
  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of AcctDerRule_1'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
  END IF;
  x_value_type_code := 'S';
  l_output_value    := TO_NUMBER(TO_NUMBER(p_source_1));
  RETURN l_output_value;

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of AcctDerRule_1(invalid)'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;
x_value_type_code := null;
l_output_value    := null;
xla_accounting_err_pkg.build_message
                 (p_appli_s_name            => 'XLA'
                 ,p_msg_name                => 'XLA_AP_INVALID_ADR'
                 ,p_token_1                 => 'COMPONENT_NAME'
                 ,p_value_1                 => xla_ae_sources_pkg.GetComponentName (
                                                            l_component_type
                                                          , l_component_code
                                                          , l_component_type_code
                                                          , l_component_appl_id
                                                          , l_amb_context_code
                                                          )
                 ,p_token_2                 => 'OWNER'
                 ,p_value_2                 => xla_lookups_pkg.get_meaning(
                                                        'XLA_OWNER_TYPE'
                                                        ,l_component_type_code
                                                        )
                 ,p_token_3                 => 'PAD_NAME'
                 ,p_value_3                 => xla_ae_journal_entry_pkg.g_cache_pad.pad_session_name
                 ,p_token_4                 => 'PAD_OWNER'
                 ,p_value_4                 => xla_lookups_pkg.get_meaning(
                                                        'XLA_OWNER_TYPE'
                                                        ,xla_ae_journal_entry_pkg.g_cache_pad.product_rule_type_code
                                                        )
                 ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
                 ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
                 ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id
                 ,p_ae_header_id            => NULL
);
RETURN l_output_value;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctDerRule_1');
END AcctDerRule_1;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_2
--
---------------------------------------
PROCEDURE AcctLineType_2 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Purchasing Encumbrance Flag
 , p_source_2            IN VARCHAR2
--Reserved Flag
 , p_source_3            IN VARCHAR2
--Organization Encumbrance Reversal Indicator
 , p_source_4            IN VARCHAR2
--Accounting Line Type
 , p_source_6            IN NUMBER
--Applied to Application ID
 , p_source_7            IN NUMBER
--Applied to Distribution Link Type
 , p_source_8            IN VARCHAR2
--Applied to Entity Code
 , p_source_9            IN VARCHAR2
--TXN_PO_DISTRIBUTION_ID
 , p_source_10            IN NUMBER
--Applied To Purchase Document Identifier
 , p_source_11            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--PO Budget Account
 , p_source_14            IN NUMBER
--Encumbrance Reversal Amount Entered
 , p_source_15            IN NUMBER
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Transaction Encumbrance Reversal Amount
 , p_source_17            IN NUMBER
--Costing Encumbrance Upgrade Option
 , p_source_18            IN VARCHAR2
--Purchasing Encumbrance Type Identifier
 , p_source_19            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_2';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_2'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'ADJUST_PO_ENC_DTI';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'MTL_ACCOUNTING_EVENTS';
l_event_class_code           := 'PURCHASE_ORDER';
l_event_type_code            := 'PURCHASE_ORDER_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'PO_ENCUM_FOR_DEL_TO_INV';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'PRIOR_ENTRY';   -- 4219869 Business Flow
l_bflow_class_code           := 'PO_ENCUMBRANCE';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_2,'
') =  'Y' AND 
NVL(p_source_3,'
') =  'Y' AND 
NVL(p_source_4,'
') =  'Y' AND 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'PO_DEL_ADJ' AND 
NVL(p_source_6,9E125) =  1
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'C'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'Y'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'D';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'PURCHASE_ORDER'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'PURCHASE_ORDER';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
   
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 17;
   l_accted_amt_idx  := 19;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_7;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_8;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_9;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_10);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_11);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENC_UPG_CR_CCID';
   l_rec_acct_attrs.array_num_value(8)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENC_UPG_CR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(9)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'ENC_UPG_CR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(10)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'ENC_UPG_CR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(11)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'ENC_UPG_DR_CCID';
   l_rec_acct_attrs.array_num_value(12)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(13) := 'ENC_UPG_DR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(14) := 'ENC_UPG_DR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(14)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(15) := 'ENC_UPG_DR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(15)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(16) := 'ENC_UPG_OPTION';
   l_rec_acct_attrs.array_char_value(16)  := p_source_18;
   l_rec_acct_attrs.array_acct_attr_code(17) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(17)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(18) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(18)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(19) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(19)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(20) := 'UPG_CR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(20)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(21) := 'UPG_DR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(21)  := p_source_19;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);
   END IF;

   --
   -- call analytical criteria
   --
   -- Inherited Analytical Criteria for business flow method of Prior Entry.
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 1
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   -- No ValidateCurrentLine for business flow method of Prior Entry

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_2'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_2');
END AcctLineType_2;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_3
--
---------------------------------------
PROCEDURE AcctLineType_3 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Cost Management Default Account
 , p_source_1            IN NUMBER
--Accounting Line Type
 , p_source_6            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Entered Amount
 , p_source_20            IN NUMBER
--Currency Conversion Date
 , p_source_21            IN DATE
--Currency Conversion Rate
 , p_source_22            IN NUMBER
--Currency Conversion Type
 , p_source_23            IN VARCHAR2
--Accounted Amount
 , p_source_24            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_3';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_3'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'INTERNAL_ORDER_ENC_RELIEVE';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'MTL_ACCOUNTING_EVENTS';
l_event_class_code           := 'INT_ORDER_TO_EXP';
l_event_type_code            := 'INT_ORDER_TO_EXP_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'INTERNAL_ORDER_ENC_RELIEVE';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'NONE';   -- 4219869 Business Flow
l_bflow_class_code           := '';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'N';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_6,9E125) =  15
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'D'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'Y'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'C';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'REQUISITION'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'REQUISITION';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
      XLA_AE_LINES_PKG.g_rec_lines.array_encumbrance_type_id(XLA_AE_LINES_PKG.g_LineNumber) := 1000;
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 3;
   l_accted_amt_idx  := 8;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(1)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(2) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(3)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(4)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(5) := 'EXCHANGE_DATE';
   l_rec_acct_attrs.array_date_value(5)  := p_source_21;
   l_rec_acct_attrs.array_acct_attr_code(6) := 'EXCHANGE_RATE';
   l_rec_acct_attrs.array_num_value(6)  := p_source_22;
   l_rec_acct_attrs.array_acct_attr_code(7) := 'EXCHANGE_RATE_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_23;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_24;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
-- No business flow processing for business flow method of NONE.
   END IF;

   --
   -- call analytical criteria
   --
   
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
  l_ccid := AcctDerRule_1(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_1 => p_source_1
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_value_type_code          => l_adr_value_type_code
         , p_side                     => 'NA'
   );

   xla_ae_lines_pkg.set_ccid(
    p_code_combination_id          => l_ccid
  , p_value_type_code              => l_adr_value_type_code
  , p_transaction_coa_id           => l_adr_transaction_coa_id
  , p_accounting_coa_id            => l_adr_accounting_coa_id
  , p_adr_code                     => 'CST_DEFAULT'
  , p_adr_type_code                => 'S'
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => 'NA'
  );


   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 2
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.ValidateCurrentLine;

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
  l_ccid := AcctDerRule_1(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_1 => p_source_1
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_value_type_code          => l_adr_value_type_code
         , p_side                     => 'NA'
   );

   xla_ae_lines_pkg.set_ccid(
    p_code_combination_id          => l_ccid
  , p_value_type_code              => l_adr_value_type_code
  , p_transaction_coa_id           => l_adr_transaction_coa_id
  , p_accounting_coa_id            => l_adr_accounting_coa_id
  , p_adr_code                     => 'CST_DEFAULT'
  , p_adr_type_code                => 'S'
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => 'NA'
  );


   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_3'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_3');
END AcctLineType_3;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_4
--
---------------------------------------
PROCEDURE AcctLineType_4 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Purchasing Encumbrance Flag
 , p_source_2            IN VARCHAR2
--Organization Encumbrance Reversal Indicator
 , p_source_4            IN VARCHAR2
--Applied to Application ID
 , p_source_7            IN NUMBER
--Applied to Distribution Link Type
 , p_source_8            IN VARCHAR2
--Applied to Entity Code
 , p_source_9            IN VARCHAR2
--TXN_PO_DISTRIBUTION_ID
 , p_source_10            IN NUMBER
--Applied To Purchase Document Identifier
 , p_source_11            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--PO Budget Account
 , p_source_14            IN NUMBER
--Encumbrance Reversal Amount Entered
 , p_source_15            IN NUMBER
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Transaction Encumbrance Reversal Amount
 , p_source_17            IN NUMBER
--Costing Encumbrance Upgrade Option
 , p_source_18            IN VARCHAR2
--Purchasing Encumbrance Type Identifier
 , p_source_19            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_4';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_4'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'REINSTATE_PO_ENC_ON_RFI';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'MTL_ACCOUNTING_EVENTS';
l_event_class_code           := 'PURCHASE_ORDER';
l_event_type_code            := 'PURCHASE_ORDER_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'PO_ENCUM_FOR_DEL_TO_INV';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'PRIOR_ENTRY';   -- 4219869 Business Flow
l_bflow_class_code           := 'PO_ENCUMBRANCE';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_2,'
') =  'Y' AND 
NVL(p_source_4,'
') =  'Y' AND 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'RET_RI_INV'
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'D'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'N'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'C';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'PURCHASE_ORDER'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'PURCHASE_ORDER';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
   
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 17;
   l_accted_amt_idx  := 19;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_7;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_8;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_9;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_10);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_11);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENC_UPG_CR_CCID';
   l_rec_acct_attrs.array_num_value(8)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENC_UPG_CR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(9)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'ENC_UPG_CR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(10)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'ENC_UPG_CR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(11)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'ENC_UPG_DR_CCID';
   l_rec_acct_attrs.array_num_value(12)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(13) := 'ENC_UPG_DR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(14) := 'ENC_UPG_DR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(14)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(15) := 'ENC_UPG_DR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(15)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(16) := 'ENC_UPG_OPTION';
   l_rec_acct_attrs.array_char_value(16)  := p_source_18;
   l_rec_acct_attrs.array_acct_attr_code(17) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(17)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(18) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(18)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(19) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(19)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(20) := 'UPG_CR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(20)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(21) := 'UPG_DR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(21)  := p_source_19;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);
   END IF;

   --
   -- call analytical criteria
   --
   -- Inherited Analytical Criteria for business flow method of Prior Entry.
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 1
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   -- No ValidateCurrentLine for business flow method of Prior Entry

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_4'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_4');
END AcctLineType_4;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_5
--
---------------------------------------
PROCEDURE AcctLineType_5 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Purchasing Encumbrance Flag
 , p_source_2            IN VARCHAR2
--Applied to Application ID
 , p_source_7            IN NUMBER
--Applied to Distribution Link Type
 , p_source_8            IN VARCHAR2
--Applied to Entity Code
 , p_source_9            IN VARCHAR2
--Applied To Purchase Document Identifier
 , p_source_11            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--PO Budget Account
 , p_source_14            IN NUMBER
--Encumbrance Reversal Amount Entered
 , p_source_15            IN NUMBER
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Transaction Encumbrance Reversal Amount
 , p_source_17            IN NUMBER
--Costing Encumbrance Upgrade Option
 , p_source_18            IN VARCHAR2
--Purchasing Encumbrance Type Identifier
 , p_source_19            IN NUMBER
--Receiving Accounting Line Type
 , p_source_25            IN VARCHAR2
--PO_DISTRIBUTION_ID
 , p_source_26            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_5';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_5'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'REINSTATE_PO_ENC_ON_RTR';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'RCV_ACCOUNTING_EVENTS';
l_event_class_code           := 'DELIVER_EXPENSE';
l_event_type_code            := 'DELIVER_EXPENSE_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'PO_ENCUM_FOR_DEL_TO_EXP';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'PRIOR_ENTRY';   -- 4219869 Business Flow
l_bflow_class_code           := 'PO_ENCUMBRANCE';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_2,'
') =  'Y' AND 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'RETURN_TO_RECEIVING' AND 
NVL(p_source_25,'
') =  'Charge'
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'D'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'Y'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'C';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'PURCHASE_ORDER'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'PURCHASE_ORDER';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
   
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 17;
   l_accted_amt_idx  := 19;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_7;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_8;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_9;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_26);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_11);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENC_UPG_CR_CCID';
   l_rec_acct_attrs.array_num_value(8)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENC_UPG_CR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(9)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'ENC_UPG_CR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(10)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'ENC_UPG_CR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(11)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'ENC_UPG_DR_CCID';
   l_rec_acct_attrs.array_num_value(12)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(13) := 'ENC_UPG_DR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(14) := 'ENC_UPG_DR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(14)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(15) := 'ENC_UPG_DR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(15)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(16) := 'ENC_UPG_OPTION';
   l_rec_acct_attrs.array_char_value(16)  := p_source_18;
   l_rec_acct_attrs.array_acct_attr_code(17) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(17)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(18) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(18)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(19) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(19)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(20) := 'UPG_CR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(20)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(21) := 'UPG_DR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(21)  := p_source_19;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);
   END IF;

   --
   -- call analytical criteria
   --
   -- Inherited Analytical Criteria for business flow method of Prior Entry.
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 1
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   -- No ValidateCurrentLine for business flow method of Prior Entry

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_5'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_5');
END AcctLineType_5;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_6
--
---------------------------------------
PROCEDURE AcctLineType_6 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Purchasing Encumbrance Flag
 , p_source_2            IN VARCHAR2
--Reserved Flag
 , p_source_3            IN VARCHAR2
--Applied to Application ID
 , p_source_7            IN NUMBER
--Applied to Distribution Link Type
 , p_source_8            IN VARCHAR2
--Applied to Entity Code
 , p_source_9            IN VARCHAR2
--Applied To Purchase Document Identifier
 , p_source_11            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--PO Budget Account
 , p_source_14            IN NUMBER
--Encumbrance Reversal Amount Entered
 , p_source_15            IN NUMBER
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Transaction Encumbrance Reversal Amount
 , p_source_17            IN NUMBER
--Costing Encumbrance Upgrade Option
 , p_source_18            IN VARCHAR2
--Purchasing Encumbrance Type Identifier
 , p_source_19            IN NUMBER
--Receiving Accounting Line Type
 , p_source_25            IN VARCHAR2
--PO_DISTRIBUTION_ID
 , p_source_26            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_6';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_6'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'RELIEVE_PO_ENC_ON_DTE';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'RCV_ACCOUNTING_EVENTS';
l_event_class_code           := 'DELIVER_EXPENSE';
l_event_type_code            := 'DELIVER_EXPENSE_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'PO_ENCUM_FOR_DEL_TO_EXP';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'PRIOR_ENTRY';   -- 4219869 Business Flow
l_bflow_class_code           := 'PO_ENCUMBRANCE';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_2,'
') =  'Y' AND 
NVL(p_source_3,'
') =  'Y' AND 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'DELIVER_EXPENSE' AND 
NVL(p_source_25,'
') =  'Charge'
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'D'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'Y'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'C';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'PURCHASE_ORDER'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'PURCHASE_ORDER';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
   
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 17;
   l_accted_amt_idx  := 19;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_7;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_8;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_9;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_26);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_11);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENC_UPG_CR_CCID';
   l_rec_acct_attrs.array_num_value(8)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENC_UPG_CR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(9)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'ENC_UPG_CR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(10)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'ENC_UPG_CR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(11)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'ENC_UPG_DR_CCID';
   l_rec_acct_attrs.array_num_value(12)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(13) := 'ENC_UPG_DR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(14) := 'ENC_UPG_DR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(14)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(15) := 'ENC_UPG_DR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(15)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(16) := 'ENC_UPG_OPTION';
   l_rec_acct_attrs.array_char_value(16)  := p_source_18;
   l_rec_acct_attrs.array_acct_attr_code(17) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(17)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(18) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(18)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(19) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(19)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(20) := 'UPG_CR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(20)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(21) := 'UPG_DR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(21)  := p_source_19;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);
   END IF;

   --
   -- call analytical criteria
   --
   -- Inherited Analytical Criteria for business flow method of Prior Entry.
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 1
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   -- No ValidateCurrentLine for business flow method of Prior Entry

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_6'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_6');
END AcctLineType_6;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_7
--
---------------------------------------
PROCEDURE AcctLineType_7 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Purchasing Encumbrance Flag
 , p_source_2            IN VARCHAR2
--Reserved Flag
 , p_source_3            IN VARCHAR2
--Organization Encumbrance Reversal Indicator
 , p_source_4            IN VARCHAR2
--Accounting Line Type
 , p_source_6            IN NUMBER
--Applied to Application ID
 , p_source_7            IN NUMBER
--Applied to Distribution Link Type
 , p_source_8            IN VARCHAR2
--Applied to Entity Code
 , p_source_9            IN VARCHAR2
--TXN_PO_DISTRIBUTION_ID
 , p_source_10            IN NUMBER
--Applied To Purchase Document Identifier
 , p_source_11            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--PO Budget Account
 , p_source_14            IN NUMBER
--Encumbrance Reversal Amount Entered
 , p_source_15            IN NUMBER
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Transaction Encumbrance Reversal Amount
 , p_source_17            IN NUMBER
--Costing Encumbrance Upgrade Option
 , p_source_18            IN VARCHAR2
--Purchasing Encumbrance Type Identifier
 , p_source_19            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_7';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_7'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'RELIEVE_PO_ENC_ON_DTI';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'MTL_ACCOUNTING_EVENTS';
l_event_class_code           := 'PURCHASE_ORDER';
l_event_type_code            := 'PURCHASE_ORDER_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'PO_ENCUM_FOR_DEL_TO_INV';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'PRIOR_ENTRY';   -- 4219869 Business Flow
l_bflow_class_code           := 'PO_ENCUMBRANCE';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_2,'
') =  'Y' AND 
NVL(p_source_3,'
') =  'Y' AND 
NVL(p_source_4,'
') =  'Y' AND 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'PO_DEL_INV' AND 
NVL(p_source_6,9E125) =  15
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'C'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'N'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'D';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'PURCHASE_ORDER'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'PURCHASE_ORDER';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
   
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 17;
   l_accted_amt_idx  := 19;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_7;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_8;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_9;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_10);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_11);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENC_UPG_CR_CCID';
   l_rec_acct_attrs.array_num_value(8)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENC_UPG_CR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(9)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'ENC_UPG_CR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(10)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'ENC_UPG_CR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(11)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'ENC_UPG_DR_CCID';
   l_rec_acct_attrs.array_num_value(12)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(13) := 'ENC_UPG_DR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(14) := 'ENC_UPG_DR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(14)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(15) := 'ENC_UPG_DR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(15)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(16) := 'ENC_UPG_OPTION';
   l_rec_acct_attrs.array_char_value(16)  := p_source_18;
   l_rec_acct_attrs.array_acct_attr_code(17) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(17)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(18) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(18)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(19) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(19)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(20) := 'UPG_CR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(20)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(21) := 'UPG_DR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(21)  := p_source_19;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);
   END IF;

   --
   -- call analytical criteria
   --
   -- Inherited Analytical Criteria for business flow method of Prior Entry.
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 1
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   -- No ValidateCurrentLine for business flow method of Prior Entry

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_7'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_7');
END AcctLineType_7;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_8
--
---------------------------------------
PROCEDURE AcctLineType_8 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Purchasing Encumbrance Flag
 , p_source_2            IN VARCHAR2
--Applied to Application ID
 , p_source_7            IN NUMBER
--Applied to Distribution Link Type
 , p_source_8            IN VARCHAR2
--Applied to Entity Code
 , p_source_9            IN VARCHAR2
--Applied To Purchase Document Identifier
 , p_source_11            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--PO Budget Account
 , p_source_14            IN NUMBER
--Encumbrance Reversal Amount Entered
 , p_source_15            IN NUMBER
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Transaction Encumbrance Reversal Amount
 , p_source_17            IN NUMBER
--Purchasing Encumbrance Type Identifier
 , p_source_19            IN NUMBER
--Receiving Accounting Line Type
 , p_source_25            IN VARCHAR2
--PO_DISTRIBUTION_ID
 , p_source_26            IN NUMBER
--Costing Period End Accrual Encumbrance Upgrade Option
 , p_source_27            IN VARCHAR2
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_8';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_8'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'RELIEVE_PO_ENC_ON_PEA';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'RCV_ACCOUNTING_EVENTS';
l_event_class_code           := 'PERIOD_END_ACCRUAL';
l_event_type_code            := 'PERIOD_END_ACCRUAL_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'PO_ENCUM_FOR_PERIOD_END_ACCR';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'PRIOR_ENTRY';   -- 4219869 Business Flow
l_bflow_class_code           := 'PO_ENCUMBRANCE';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_2,'
') =  'Y' AND 
NVL(
xla_ae_sources_pkg.GetSystemSourceChar(
   p_source_code           => 'XLA_EVENT_TYPE_CODE'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
),'
') =  'PERIOD_END_ACCRUAL' AND 
NVL(p_source_25,'
') =  'Charge'
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'D'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'Y'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'C';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'PURCHASE_ORDER'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'PURCHASE_ORDER';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
   
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 17;
   l_accted_amt_idx  := 19;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_7;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_8;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_9;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_26);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_11);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENC_UPG_CR_CCID';
   l_rec_acct_attrs.array_num_value(8)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENC_UPG_CR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(9)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'ENC_UPG_CR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(10)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'ENC_UPG_CR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(11)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'ENC_UPG_DR_CCID';
   l_rec_acct_attrs.array_num_value(12)  := TO_NUMBER(p_source_14);
   l_rec_acct_attrs.array_acct_attr_code(13) := 'ENC_UPG_DR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(14) := 'ENC_UPG_DR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(14)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(15) := 'ENC_UPG_DR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(15)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(16) := 'ENC_UPG_OPTION';
   l_rec_acct_attrs.array_char_value(16)  := p_source_27;
   l_rec_acct_attrs.array_acct_attr_code(17) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(17)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(18) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(18)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(19) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(19)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(20) := 'UPG_CR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(20)  := p_source_19;
   l_rec_acct_attrs.array_acct_attr_code(21) := 'UPG_DR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(21)  := p_source_19;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);
   END IF;

   --
   -- call analytical criteria
   --
   -- Inherited Analytical Criteria for business flow method of Prior Entry.
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 1
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   -- No ValidateCurrentLine for business flow method of Prior Entry

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_8'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_8');
END AcctLineType_8;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_9
--
---------------------------------------
PROCEDURE AcctLineType_9 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Organization Encumbrance Reversal Indicator
 , p_source_4            IN VARCHAR2
--Applied to Application ID
 , p_source_7            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--Encumbrance Reversal Amount Entered
 , p_source_15            IN NUMBER
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Transaction Encumbrance Reversal Amount
 , p_source_17            IN NUMBER
--Costing Encumbrance Upgrade Option
 , p_source_18            IN VARCHAR2
--Requisition Encumbrance Flag
 , p_source_28            IN VARCHAR2
--Requisition Reserved Flag
 , p_source_29            IN VARCHAR2
--Business Flow Requisition Distribution Type
 , p_source_30            IN VARCHAR2
--Business Flow Requisition Entity Code
 , p_source_31            IN VARCHAR2
--Business Flow Requisition Distribution Identifier
 , p_source_32            IN NUMBER
--Business Flow Requisition Identifier
 , p_source_33            IN NUMBER
--Requisition Budget Account
 , p_source_34            IN NUMBER
--Requisition Encumbrance Type Identifier
 , p_source_35            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_9';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_9'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'RELIEVE_REQ_ENC_ON_DIR';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'MTL_ACCOUNTING_EVENTS';
l_event_class_code           := 'DIR_INTERORG_RCPT';
l_event_type_code            := 'DIR_INTERORG_RCPT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'REQ_ENCUM_ON_DIR';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'PRIOR_ENTRY';   -- 4219869 Business Flow
l_bflow_class_code           := 'REQ_ENCUMBRANCE';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_28,'
') =  'Y' AND 
NVL(p_source_4,'
') =  'Y' AND 
NVL(p_source_29,'
') =  'Y'
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'C'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'N'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'D';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'REQUISITION'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'REQUISITION';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
   
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 17;
   l_accted_amt_idx  := 19;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_7;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_30;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_31;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_32);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_33);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENC_UPG_CR_CCID';
   l_rec_acct_attrs.array_num_value(8)  := TO_NUMBER(p_source_34);
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENC_UPG_CR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(9)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'ENC_UPG_CR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(10)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'ENC_UPG_CR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(11)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'ENC_UPG_DR_CCID';
   l_rec_acct_attrs.array_num_value(12)  := TO_NUMBER(p_source_34);
   l_rec_acct_attrs.array_acct_attr_code(13) := 'ENC_UPG_DR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(14) := 'ENC_UPG_DR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(14)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(15) := 'ENC_UPG_DR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(15)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(16) := 'ENC_UPG_OPTION';
   l_rec_acct_attrs.array_char_value(16)  := p_source_18;
   l_rec_acct_attrs.array_acct_attr_code(17) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(17)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(18) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(18)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(19) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(19)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(20) := 'UPG_CR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(20)  := p_source_35;
   l_rec_acct_attrs.array_acct_attr_code(21) := 'UPG_DR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(21)  := p_source_35;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);
   END IF;

   --
   -- call analytical criteria
   --
   -- Inherited Analytical Criteria for business flow method of Prior Entry.
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 1
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   -- No ValidateCurrentLine for business flow method of Prior Entry

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_9'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_9');
END AcctLineType_9;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_10
--
---------------------------------------
PROCEDURE AcctLineType_10 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Organization Encumbrance Reversal Indicator
 , p_source_4            IN VARCHAR2
--Accounting Line Type
 , p_source_6            IN NUMBER
--Applied to Application ID
 , p_source_7            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--Encumbrance Reversal Amount Entered
 , p_source_15            IN NUMBER
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Transaction Encumbrance Reversal Amount
 , p_source_17            IN NUMBER
--Costing Encumbrance Upgrade Option
 , p_source_18            IN VARCHAR2
--Requisition Encumbrance Flag
 , p_source_28            IN VARCHAR2
--Requisition Reserved Flag
 , p_source_29            IN VARCHAR2
--Business Flow Requisition Distribution Type
 , p_source_30            IN VARCHAR2
--Business Flow Requisition Entity Code
 , p_source_31            IN VARCHAR2
--Business Flow Requisition Distribution Identifier
 , p_source_32            IN NUMBER
--Business Flow Requisition Identifier
 , p_source_33            IN NUMBER
--Requisition Budget Account
 , p_source_34            IN NUMBER
--Requisition Encumbrance Type Identifier
 , p_source_35            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_10';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_10'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'RELIEVE_REQ_ENC_ON_REC_IIRFOBR';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'MTL_ACCOUNTING_EVENTS';
l_event_class_code           := 'FOB_RCPT_RECIPIENT_RCPT';
l_event_type_code            := 'FOB_RCPT_RECIPIENT_RCPT_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'REQ_ENCUM_ON_REC_IIRFOBR';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'PRIOR_ENTRY';   -- 4219869 Business Flow
l_bflow_class_code           := 'REQ_ENCUMBRANCE';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'Y';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_28,'
') =  'Y' AND 
NVL(p_source_4,'
') =  'Y' AND 
NVL(p_source_29,'
') =  'Y' AND 
NVL(p_source_6,9E125) =  15
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'C'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'N'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'D';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'REQUISITION'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'REQUISITION';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
   
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 17;
   l_accted_amt_idx  := 19;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'APPLIED_TO_APPLICATION_ID';
   l_rec_acct_attrs.array_num_value(1)  := p_source_7;
   l_rec_acct_attrs.array_acct_attr_code(2) := 'APPLIED_TO_DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_30;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'APPLIED_TO_ENTITY_CODE';
   l_rec_acct_attrs.array_char_value(3)  := p_source_31;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'APPLIED_TO_FIRST_DIST_ID';
   l_rec_acct_attrs.array_num_value(4)  :=  to_char(p_source_32);
   l_rec_acct_attrs.array_acct_attr_code(5) := 'APPLIED_TO_FIRST_SYS_TRAN_ID';
   l_rec_acct_attrs.array_num_value(5)  :=  to_char(p_source_33);
   l_rec_acct_attrs.array_acct_attr_code(6) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(6)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(7) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'ENC_UPG_CR_CCID';
   l_rec_acct_attrs.array_num_value(8)  := TO_NUMBER(p_source_34);
   l_rec_acct_attrs.array_acct_attr_code(9) := 'ENC_UPG_CR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(9)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(10) := 'ENC_UPG_CR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(10)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(11) := 'ENC_UPG_CR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(11)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(12) := 'ENC_UPG_DR_CCID';
   l_rec_acct_attrs.array_num_value(12)  := TO_NUMBER(p_source_34);
   l_rec_acct_attrs.array_acct_attr_code(13) := 'ENC_UPG_DR_ENTERED_AMT';
   l_rec_acct_attrs.array_num_value(13)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(14) := 'ENC_UPG_DR_ENTERED_CURR';
   l_rec_acct_attrs.array_char_value(14)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(15) := 'ENC_UPG_DR_LEDGER_AMT';
   l_rec_acct_attrs.array_num_value(15)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(16) := 'ENC_UPG_OPTION';
   l_rec_acct_attrs.array_char_value(16)  := p_source_18;
   l_rec_acct_attrs.array_acct_attr_code(17) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(17)  := p_source_15;
   l_rec_acct_attrs.array_acct_attr_code(18) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(18)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(19) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(19)  := p_source_17;
   l_rec_acct_attrs.array_acct_attr_code(20) := 'UPG_CR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(20)  := p_source_35;
   l_rec_acct_attrs.array_acct_attr_code(21) := 'UPG_DR_ENC_TYPE_ID';
   l_rec_acct_attrs.array_num_value(21)  := p_source_35;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);
   END IF;

   --
   -- call analytical criteria
   --
   -- Inherited Analytical Criteria for business flow method of Prior Entry.
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 1
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   -- No ValidateCurrentLine for business flow method of Prior Entry

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_10'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_10');
END AcctLineType_10;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_11
--
---------------------------------------
PROCEDURE AcctLineType_11 (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 
--Cost Management Default Account
 , p_source_1            IN NUMBER
--Accounting Line Type
 , p_source_6            IN NUMBER
--DISTRIBUTION_IDENTIFIER
 , p_source_12            IN NUMBER
--Distribution Type
 , p_source_13            IN VARCHAR2
 , p_source_13_meaning    IN VARCHAR2
--Entered Currency Code
 , p_source_16            IN VARCHAR2
--Entered Amount
 , p_source_20            IN NUMBER
--Currency Conversion Date
 , p_source_21            IN DATE
--Currency Conversion Rate
 , p_source_22            IN NUMBER
--Currency Conversion Type
 , p_source_23            IN VARCHAR2
--Accounted Amount
 , p_source_24            IN NUMBER
)
IS

l_component_type              VARCHAR2(80);
l_component_code              VARCHAR2(30);
l_component_type_code         VARCHAR2(1);
l_component_appl_id           INTEGER;
l_amb_context_code            VARCHAR2(30);
l_entity_code                 VARCHAR2(30);
l_event_class_code            VARCHAR2(30);
l_ae_header_id                NUMBER;
l_event_type_code             VARCHAR2(30);
l_line_definition_code        VARCHAR2(30);
l_line_definition_owner_code  VARCHAR2(1);
--
-- adr variables
l_segment                     VARCHAR2(30);
l_ccid                        NUMBER;
l_adr_transaction_coa_id      NUMBER;
l_adr_accounting_coa_id       NUMBER;
l_adr_flexfield_segment_code  VARCHAR2(30);
l_adr_flex_value_set_id       NUMBER;
l_adr_value_type_code         VARCHAR2(30);
l_adr_value_combination_id    NUMBER;
l_adr_value_segment_code      VARCHAR2(30);

l_bflow_method_code           VARCHAR2(30);  -- 4219869 Business Flow
l_bflow_class_code            VARCHAR2(30);  -- 4219869 Business Flow
l_inherit_desc_flag           VARCHAR2(1);   -- 4219869 Business Flow
l_budgetary_control_flag      VARCHAR2(1);   -- 4458381 Public Sector Enh

-- 4262811 Variables ------------------------------------------------------------------------------------------
l_entered_amt_idx             NUMBER;
l_accted_amt_idx              NUMBER;
l_acc_rev_flag                VARCHAR2(1);
l_accrual_line_num            NUMBER;
l_tmp_amt                     NUMBER;
l_acc_rev_natural_side_code   VARCHAR2(1);

l_num_entries                 NUMBER;
l_gl_dates                    xla_ae_journal_entry_pkg.t_array_date;
l_accted_amts                 xla_ae_journal_entry_pkg.t_array_num;
l_entered_amts                xla_ae_journal_entry_pkg.t_array_num;
l_period_names                xla_ae_journal_entry_pkg.t_array_V15L;
l_recog_line_1                NUMBER;
l_recog_line_2                NUMBER;

l_bflow_applied_to_amt_idx    NUMBER;                                -- 5132302
l_bflow_applied_to_amt        NUMBER;                                -- 5132302
l_bflow_applied_to_amts       xla_ae_journal_entry_pkg.t_array_num;  -- 5132302

l_event_id                    NUMBER;  -- To handle MPA header Description: xla_ae_header_pkg.SetHdrDescription

--l_rounding_ccy                VARCHAR2(15); -- To handle MPA rounding  4262811b
l_same_currency               BOOLEAN;        -- To handle MPA rounding  4262811b

---------------------------------------------------------------------------------------------------------------


--
-- bulk performance
--
l_balance_type_code           VARCHAR2(1);
l_rec_acct_attrs              XLA_AE_LINES_PKG.t_rec_acct_attrs;
l_log_module                  VARCHAR2(240);

--
-- Upgrade strategy
--
l_actual_upg_option           VARCHAR2(1);
l_enc_upg_option           VARCHAR2(1);

--
BEGIN
--
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.AcctLineType_11';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of AcctLineType_11'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := 'AMB_JLT';
l_component_code             := 'RELIEVE_REQ_ENC_ON_REC_IIRFOBS';
l_component_type_code        := 'S';
l_component_appl_id          :=  707;
l_amb_context_code           := 'DEFAULT';
l_entity_code                := 'MTL_ACCOUNTING_EVENTS';
l_event_class_code           := 'FOB_SHIP_SENDER_SHIP';
l_event_type_code            := 'FOB_SHIP_SENDER_SHIP_ALL';
l_line_definition_owner_code := 'S';
l_line_definition_code       := 'REQ_ENCUM_ON_REC_IIRFOBS';
--
l_balance_type_code          := 'E';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := 'NONE';   -- 4219869 Business Flow
l_bflow_class_code           := '';    -- 4219869 Business Flow
l_inherit_desc_flag          := 'N';   -- 4219869 Business Flow
l_budgetary_control_flag     := 'Y';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
 
IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> 'B' THEN
IF NVL(p_source_6,9E125) =  15
 THEN 

   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   
   IF(l_balance_type_code = 'A' and p_actual_flag is null) THEN
     p_actual_flag :='A';
   END IF;

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => 'D'
         , p_gain_or_loss_flag          => 'N'
         , p_gl_transfer_mode_code      => 'S'
         , p_acct_entry_type_code       => 'E'
         , p_switch_side_flag           => 'Y'
         , p_merge_duplicate_code       => 'N'
         );
   --
   l_acc_rev_natural_side_code := 'C';  -- 4262811
   -- 
   --
   -- set accounting line type info
   --
   xla_ae_lines_pkg.SetAcctLineType
      (p_component_type             => l_component_type
      ,p_event_type_code            => l_event_type_code
      ,p_line_definition_owner_code => l_line_definition_owner_code
      ,p_line_definition_code       => l_line_definition_code
      ,p_accounting_line_code       => l_component_code
      ,p_accounting_line_type_code  => l_component_type_code
      ,p_accounting_line_appl_id    => l_component_appl_id
      ,p_amb_context_code           => l_amb_context_code
      ,p_entity_code                => l_entity_code
      ,p_event_class_code           => l_event_class_code);
   --
   -- set accounting class
   --
   xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => 'REQUISITION'
         , p_ae_header_id           => l_ae_header_id
         );

   --
   -- set rounding class
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      'REQUISITION';

   --
   xla_ae_lines_pkg.g_rec_lines.array_calculate_acctd_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_acctd_flag;
   xla_ae_lines_pkg.g_rec_lines.array_calculate_g_l_flag(xla_ae_lines_pkg.g_LineNumber) := p_calculate_g_l_flag;
   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.g_rec_lines.array_balance_type_code(XLA_AE_LINES_PKG.g_LineNumber) := l_balance_type_code;

   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id;

   -- 4955764
   XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('header_index'));

   -- 4458381 Public Sector Enh
      XLA_AE_LINES_PKG.g_rec_lines.array_encumbrance_type_id(XLA_AE_LINES_PKG.g_LineNumber) := 1000;
   --
   -- set accounting attributes for the line type
   --
   l_entered_amt_idx := 3;
   l_accted_amt_idx  := 8;
   l_bflow_applied_to_amt_idx  := NULL;  -- 5132302
   l_rec_acct_attrs.array_acct_attr_code(1) := 'DISTRIBUTION_IDENTIFIER_1';
   l_rec_acct_attrs.array_num_value(1)  :=  to_char(p_source_12);
   l_rec_acct_attrs.array_acct_attr_code(2) := 'DISTRIBUTION_TYPE';
   l_rec_acct_attrs.array_char_value(2)  := p_source_13;
   l_rec_acct_attrs.array_acct_attr_code(3) := 'ENTERED_CURRENCY_AMOUNT';
   l_rec_acct_attrs.array_num_value(3)  := p_source_20;
   l_rec_acct_attrs.array_acct_attr_code(4) := 'ENTERED_CURRENCY_CODE';
   l_rec_acct_attrs.array_char_value(4)  := p_source_16;
   l_rec_acct_attrs.array_acct_attr_code(5) := 'EXCHANGE_DATE';
   l_rec_acct_attrs.array_date_value(5)  := p_source_21;
   l_rec_acct_attrs.array_acct_attr_code(6) := 'EXCHANGE_RATE';
   l_rec_acct_attrs.array_num_value(6)  := p_source_22;
   l_rec_acct_attrs.array_acct_attr_code(7) := 'EXCHANGE_RATE_TYPE';
   l_rec_acct_attrs.array_char_value(7)  := p_source_23;
   l_rec_acct_attrs.array_acct_attr_code(8) := 'LEDGER_AMOUNT';
   l_rec_acct_attrs.array_num_value(8)  := p_source_24;

   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => 'LEDGER_CATEGORY_CODE'
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN ('PRIMARY','ALC')
   AND l_bflow_method_code = 'PRIOR_ENTRY'
--   AND (l_actual_upg_option = 'Y' OR l_enc_upg_option = 'Y') Bug 4922099
   AND ( (NVL(l_actual_upg_option, 'N') IN ('Y', 'O')) OR
         (NVL(l_enc_upg_option, 'N') IN ('Y', 'O'))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
-- No business flow processing for business flow method of NONE.
   END IF;

   --
   -- call analytical criteria
   --
   
   --
   -- call description
   --
   -- No description or it is inherited.
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
  l_ccid := AcctDerRule_1(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_1 => p_source_1
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_value_type_code          => l_adr_value_type_code
         , p_side                     => 'NA'
   );

   xla_ae_lines_pkg.set_ccid(
    p_code_combination_id          => l_ccid
  , p_value_type_code              => l_adr_value_type_code
  , p_transaction_coa_id           => l_adr_transaction_coa_id
  , p_accounting_coa_id            => l_adr_accounting_coa_id
  , p_adr_code                     => 'CST_DEFAULT'
  , p_adr_type_code                => 'S'
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => 'NA'
  );


   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, 'N') = 'O') OR
          (NVL(l_enc_upg_option, 'N') = 'O')
        ) AND
        (l_bflow_method_code = 'PRIOR_ENTRY')
      )
   THEN
      IF
      --
      1 = 2
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => 'XLA'
                                    ,p_msg_name                => 'XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                                    ,p_token_1                 => 'LINE_NUMBER'
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => 'LINE_TYPE_NAME'
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => 'OWNER'
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => 'XLA_OWNER_TYPE'
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => 'PRODUCT_NAME'
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => 'ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED'
                      ,p_level    => C_LEVEL_ERROR
                      ,p_module   => l_log_module);
        END IF;
      END IF;
   END IF;
   --
   --
   ------------------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- NOTE: XLA_AE_LINES_PKG.ValidateCurrentLine should NOT be generated if business flow method is
   -- Prior Entry.  Currently, the following code is always generated.
   ------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.ValidateCurrentLine;

   ------------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Populated credit and debit amounts -- Need to generate this within IF <condition>
   ------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.SetDebitCreditAmounts;

   ----------------------------------------------------------------------------------
   -- 4219869 Business Flow
   -- Update journal entry status -- Need to generate this within IF <condition>
   ----------------------------------------------------------------------------------
   XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
         (p_hdr_idx => g_array_event(p_event_id).array_value_num('header_index')
         ,p_balance_type_code => l_balance_type_code
         );

   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num('header_index'));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := 'N';
   END;
   --
   IF (l_acc_rev_flag = 'Y') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := 'Y';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> 'PRIOR_ENTRY') OR
        (NVL(l_actual_upg_option, 'N') = 'O') OR
        (NVL(l_enc_upg_option, 'N') = 'O')
      )
   THEN
   NULL;
   --
   --
   
  l_ccid := AcctDerRule_1(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id 
, p_source_1 => p_source_1
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_value_type_code          => l_adr_value_type_code
         , p_side                     => 'NA'
   );

   xla_ae_lines_pkg.set_ccid(
    p_code_combination_id          => l_ccid
  , p_value_type_code              => l_adr_value_type_code
  , p_transaction_coa_id           => l_adr_transaction_coa_id
  , p_accounting_coa_id            => l_adr_accounting_coa_id
  , p_adr_code                     => 'CST_DEFAULT'
  , p_adr_type_code                => 'S'
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => 'NA'
  );


   --
   --
   END IF;

       --
       -- Update the line information that should be overwritten
       --
       XLA_AE_LINES_PKG.set_ae_header_id(p_ae_header_id => p_event_id ,
                                         p_header_num   => 1);
       XLA_AE_LINES_PKG.g_rec_lines.array_header_num(XLA_AE_LINES_PKG.g_LineNumber)  :=1;

       XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := NULL; -- 4669271

       IF l_bflow_method_code <> 'NONE' THEN  -- 4655713b
          XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT('MPA_',l_bflow_method_code);
       END IF;

      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = 'SIDE') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := 'N';  -- 5052518
          XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_ledger_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_entered_amount(XLA_AE_LINES_PKG.g_LineNumber) * -1;
          -- 5132302
          XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) :=
                      XLA_AE_LINES_PKG.g_rec_lines.array_bflow_applied_to_amt(XLA_AE_LINES_PKG.g_LineNumber) * -1;

      END IF;

      -- 4955764
      XLA_AE_LINES_PKG.g_rec_lines.array_gl_date(XLA_AE_LINES_PKG.g_LineNumber) :=
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num('acc_rev_header_index'));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num('acc_rev_header_index')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
     -- No MPA option is assigned.


END IF;
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of AcctLineType_11'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.AcctLineType_11');
END AcctLineType_11;
--

---------------------------------------
--
-- PRIVATE PROCEDURE
--         insert_sources_12
--
----------------------------------------
--
PROCEDURE insert_sources_12(
                                p_target_ledger_id       IN NUMBER
                              , p_language               IN VARCHAR2
                              , p_sla_ledger_id          IN NUMBER
                              , p_pad_start_date         IN DATE
                              , p_pad_end_date           IN DATE
                         )
IS

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'DELIVER_EXPENSE_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'DELIVER_EXPENSE';
p_apps_owner                   VARCHAR2(30);
l_log_module                   VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_sources_12';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of insert_sources_12'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- select APPS owner
SELECT oracle_username
  INTO p_apps_owner
  FROM fnd_oracle_userid
 WHERE read_only_flag = 'U'
;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_target_ledger_id = '||p_target_ledger_id||
                        ' - p_language = '||p_language||
                        ' - p_sla_ledger_id  = '||p_sla_ledger_id ||
                        ' - p_pad_start_date = '||TO_CHAR(p_pad_start_date)||
                        ' - p_pad_end_date = '||TO_CHAR(p_pad_end_date)||
                        ' - p_apps_owner = '||TO_CHAR(p_apps_owner)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


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
               WHEN 1 THEN 'PO_HEADERS_REF_V' 
                WHEN 2 THEN 'PO_DISTS_REF_V' 
                WHEN 3 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 4 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 5 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 6 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 7 THEN 'CST_XLA_RCV_HEADERS_V' 
                WHEN 8 THEN 'PO_DISTS_REF_V' 
                WHEN 9 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 10 THEN 'CST_XLA_RCV_HEADERS_V' 
                WHEN 11 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 12 THEN 'PSA_CST_XLA_UPG_V' 
                WHEN 13 THEN 'PO_HEADERS_REF_V' 
                WHEN 14 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 15 THEN 'CST_XLA_RCV_HEADERS_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                WHEN 2 THEN 'HEADER' 
                WHEN 3 THEN 'HEADER' 
                WHEN 4 THEN 'HEADER' 
                WHEN 5 THEN 'HEADER' 
                WHEN 6 THEN 'HEADER' 
                WHEN 7 THEN 'HEADER' 
                WHEN 8 THEN 'HEADER' 
                WHEN 9 THEN 'HEADER' 
                WHEN 10 THEN 'HEADER' 
                WHEN 11 THEN 'HEADER' 
                WHEN 12 THEN 'HEADER' 
                WHEN 13 THEN 'HEADER' 
                WHEN 14 THEN 'HEADER' 
                WHEN 15 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '201' 
                WHEN 2 THEN '201' 
                WHEN 3 THEN '707' 
                WHEN 4 THEN '707' 
                WHEN 5 THEN '707' 
                WHEN 6 THEN '707' 
                WHEN 7 THEN '707' 
                WHEN 8 THEN '201' 
                WHEN 9 THEN '707' 
                WHEN 10 THEN '707' 
                WHEN 11 THEN '707' 
                WHEN 12 THEN '707' 
                WHEN 13 THEN '201' 
                WHEN 14 THEN '707' 
                WHEN 15 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'PURCH_ENCUMBRANCE_FLAG' 
                WHEN 2 THEN 'RESERVED_FLAG' 
                WHEN 3 THEN 'APPLIED_TO_APPL_ID' 
                WHEN 4 THEN 'APPLIED_TO_DIST_LINK_TYPE' 
                WHEN 5 THEN 'APPLIED_TO_ENTITY_CODE' 
                WHEN 6 THEN 'APPLIED_TO_PO_DOC_ID' 
                WHEN 7 THEN 'DISTRIBUTION_TYPE' 
                WHEN 8 THEN 'PO_BUDGET_ACCOUNT' 
                WHEN 9 THEN 'ENCUM_REVERSAL_AMOUNT_ENTERED' 
                WHEN 10 THEN 'CURRENCY_CODE' 
                WHEN 11 THEN 'ENCUMBRANCE_REVERSAL_AMOUNT' 
                WHEN 12 THEN 'CST_ENCUM_UPG_OPTION' 
                WHEN 13 THEN 'PURCH_ENCUMBRANCE_TYPE_ID' 
                WHEN 14 THEN 'PO_DISTRIBUTION_ID' 
                WHEN 15 THEN 'TRANSFER_TO_GL_INDICATOR' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h5.PURCH_ENCUMBRANCE_FLAG)
                WHEN 2 THEN TO_CHAR(h4.RESERVED_FLAG)
                WHEN 3 THEN TO_CHAR(h3.APPLIED_TO_APPL_ID)
                WHEN 4 THEN TO_CHAR(h3.APPLIED_TO_DIST_LINK_TYPE)
                WHEN 5 THEN TO_CHAR(h3.APPLIED_TO_ENTITY_CODE)
                WHEN 6 THEN TO_CHAR(h3.APPLIED_TO_PO_DOC_ID)
                WHEN 7 THEN TO_CHAR(h1.DISTRIBUTION_TYPE)
                WHEN 8 THEN TO_CHAR(h4.PO_BUDGET_ACCOUNT)
                WHEN 9 THEN TO_CHAR(h3.ENCUM_REVERSAL_AMOUNT_ENTERED)
                WHEN 10 THEN TO_CHAR(h1.CURRENCY_CODE)
                WHEN 11 THEN TO_CHAR(h3.ENCUMBRANCE_REVERSAL_AMOUNT)
                WHEN 12 THEN TO_CHAR(h6.CST_ENCUM_UPG_OPTION)
                WHEN 13 THEN TO_CHAR(h5.PURCH_ENCUMBRANCE_TYPE_ID)
                WHEN 14 THEN TO_CHAR(h3.PO_DISTRIBUTION_ID)
                WHEN 15 THEN TO_CHAR(h1.TRANSFER_TO_GL_INDICATOR)
                
                ELSE null
              END                           source_value
            , CASE r
                WHEN 7 THEN fvl13.meaning
                WHEN 15 THEN fvl37.meaning
                
                ELSE null
              END               source_meaning
         FROM xla_events_gt     xet  
      , CST_XLA_RCV_HEADERS_V  h1
      , CST_XLA_RCV_REF_V  h3
      , PO_DISTS_REF_V  h4
      , PO_HEADERS_REF_V  h5
      , PSA_CST_XLA_UPG_V  h6
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
             ,(select rownum r from all_objects where rownum <= 15 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id
 AND h3.ref_rcv_accounting_event_id = h1.rcv_accounting_event_id AND h3.po_header_id = h4.po_header_id  (+)  and h3.po_distribution_id = h4.po_distribution_id (+)  AND h3.po_header_id = h5.po_header_id (+)  AND h3.rcv_transaction_id = h6.transaction_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of header sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--



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
            , l2.line_number                 line_number
            , CASE r
               WHEN 1 THEN 'CST_XLA_RCV_LINES_V' 
                WHEN 2 THEN 'CST_XLA_RCV_LINES_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'LINE' 
                WHEN 2 THEN 'LINE' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'DISTRIBUTION_IDENTIFIER' 
                WHEN 2 THEN 'RCV_ACCOUNTING_LINE_TYPE' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(l2.DISTRIBUTION_IDENTIFIER)
                WHEN 2 THEN TO_CHAR(l2.RCV_ACCOUNTING_LINE_TYPE)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM  xla_events_gt     xet  
        , CST_XLA_RCV_LINES_V  l2
            , (select rownum r from all_objects where rownum <= 2 and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_class_code = C_EVENT_CLASS_CODE
            AND l2.event_id          = xet.event_id

)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of line sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of insert_sources_12'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
      END IF;
      RAISE;
  WHEN OTHERS THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.insert_sources_12');
END insert_sources_12;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         EventClass_12
--
----------------------------------------
--
FUNCTION EventClass_12
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_target_ledger_id       IN NUMBER
       ,p_language               IN VARCHAR2
       ,p_currency_code          IN VARCHAR2
       ,p_sla_ledger_id          IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN BOOLEAN IS
--
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'DELIVER_EXPENSE_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'DELIVER_EXPENSE';

l_calculate_acctd_flag   VARCHAR2(1) :='N';
l_calculate_g_l_flag     VARCHAR2(1) :='N';
--
l_array_legal_entity_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_transaction_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_event_id                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_class_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_number                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_event_date                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_transaction_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_num_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_char_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_date_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_event_created_by               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V100L;
l_array_budgetary_control_flag         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_header_events                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added
l_array_duplicate_checker              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added

l_event_id                             NUMBER;
l_previous_event_id                    NUMBER;
l_first_event_id                       NUMBER;
l_last_event_id                        NUMBER;

l_rec_acct_attrs                       XLA_AE_HEADER_PKG.t_rec_acct_attrs;
l_rec_rev_acct_attrs                   XLA_AE_LINES_PKG.t_rec_acct_attrs;
--
--
l_result                    BOOLEAN := TRUE;
l_rows                      NUMBER  := 1000;
l_event_type_name           VARCHAR2(80) := 'All';
l_event_class_name          VARCHAR2(80) := 'Delivery to Expense Destination';
l_description               VARCHAR2(4000);
l_transaction_reversal      NUMBER;
l_ae_header_id              NUMBER;
l_array_extract_line_num    xla_ae_journal_entry_pkg.t_array_Num;
l_log_module                VARCHAR2(240);
--
l_acct_reversal_source      VARCHAR2(30);
l_trx_reversal_source       VARCHAR2(30);

l_continue_with_lines       BOOLEAN := TRUE;
--
l_acc_rev_gl_date_source    DATE;                      -- 4262811
--
type t_array_event_id is table of number index by binary_integer;

l_rec_array_event                    t_rec_array_event;
l_null_rec_array_event               t_rec_array_event;
l_array_ae_header_id                 xla_number_array_type;
l_actual_flag                        VARCHAR2(1) := NULL;
l_actual_gain_loss_ref               VARCHAR2(30) := '#####';
l_balance_type_code                  VARCHAR2(1) :=NULL;
l_gain_or_loss_ref                   VARCHAR2(30) :=NULL;

--
TYPE t_array_lookup_meaning IS TABLE OF fnd_lookup_values.meaning%TYPE INDEX BY BINARY_INTEGER;
--

TYPE t_array_source_2 IS TABLE OF PO_HEADERS_REF_V.PURCH_ENCUMBRANCE_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_3 IS TABLE OF PO_DISTS_REF_V.RESERVED_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_7 IS TABLE OF CST_XLA_RCV_REF_V.APPLIED_TO_APPL_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_8 IS TABLE OF CST_XLA_RCV_REF_V.APPLIED_TO_DIST_LINK_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_9 IS TABLE OF CST_XLA_RCV_REF_V.APPLIED_TO_ENTITY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_11 IS TABLE OF CST_XLA_RCV_REF_V.APPLIED_TO_PO_DOC_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_13 IS TABLE OF CST_XLA_RCV_HEADERS_V.DISTRIBUTION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_14 IS TABLE OF PO_DISTS_REF_V.PO_BUDGET_ACCOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_15 IS TABLE OF CST_XLA_RCV_REF_V.ENCUM_REVERSAL_AMOUNT_ENTERED%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_16 IS TABLE OF CST_XLA_RCV_HEADERS_V.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_17 IS TABLE OF CST_XLA_RCV_REF_V.ENCUMBRANCE_REVERSAL_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_18 IS TABLE OF PSA_CST_XLA_UPG_V.CST_ENCUM_UPG_OPTION%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_19 IS TABLE OF PO_HEADERS_REF_V.PURCH_ENCUMBRANCE_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_26 IS TABLE OF CST_XLA_RCV_REF_V.PO_DISTRIBUTION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_37 IS TABLE OF CST_XLA_RCV_HEADERS_V.TRANSFER_TO_GL_INDICATOR%TYPE INDEX BY BINARY_INTEGER;

TYPE t_array_source_12 IS TABLE OF CST_XLA_RCV_LINES_V.DISTRIBUTION_IDENTIFIER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_25 IS TABLE OF CST_XLA_RCV_LINES_V.RCV_ACCOUNTING_LINE_TYPE%TYPE INDEX BY BINARY_INTEGER;

l_array_source_2              t_array_source_2;
l_array_source_3              t_array_source_3;
l_array_source_7              t_array_source_7;
l_array_source_8              t_array_source_8;
l_array_source_9              t_array_source_9;
l_array_source_11              t_array_source_11;
l_array_source_13              t_array_source_13;
l_array_source_13_meaning      t_array_lookup_meaning;
l_array_source_14              t_array_source_14;
l_array_source_15              t_array_source_15;
l_array_source_16              t_array_source_16;
l_array_source_17              t_array_source_17;
l_array_source_18              t_array_source_18;
l_array_source_19              t_array_source_19;
l_array_source_26              t_array_source_26;
l_array_source_37              t_array_source_37;
l_array_source_37_meaning      t_array_lookup_meaning;

l_array_source_12      t_array_source_12;
l_array_source_25      t_array_source_25;

--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: DELIVER_EXPENSE
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
  , h5.PURCH_ENCUMBRANCE_FLAG    source_2
  , h4.RESERVED_FLAG    source_3
  , h3.APPLIED_TO_APPL_ID    source_7
  , h3.APPLIED_TO_DIST_LINK_TYPE    source_8
  , h3.APPLIED_TO_ENTITY_CODE    source_9
  , h3.APPLIED_TO_PO_DOC_ID    source_11
  , h1.DISTRIBUTION_TYPE    source_13
  , fvl13.meaning   source_13_meaning
  , h4.PO_BUDGET_ACCOUNT    source_14
  , h3.ENCUM_REVERSAL_AMOUNT_ENTERED    source_15
  , h1.CURRENCY_CODE    source_16
  , h3.ENCUMBRANCE_REVERSAL_AMOUNT    source_17
  , h6.CST_ENCUM_UPG_OPTION    source_18
  , h5.PURCH_ENCUMBRANCE_TYPE_ID    source_19
  , h3.PO_DISTRIBUTION_ID    source_26
  , h1.TRANSFER_TO_GL_INDICATOR    source_37
  , fvl37.meaning   source_37_meaning
  FROM xla_events_gt     xet 
  , CST_XLA_RCV_HEADERS_V  h1
  , CST_XLA_RCV_REF_V  h3
  , PO_DISTS_REF_V  h4
  , PO_HEADERS_REF_V  h5
  , PSA_CST_XLA_UPG_V  h6
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id
 AND h3.REF_RCV_ACCOUNTING_EVENT_ID = h1.RCV_ACCOUNTING_EVENT_ID AND h3.po_header_id = h4.po_header_id  (+)  AND h3.po_distribution_id = h4.po_distribution_id (+)  AND h3.po_header_id = h5.po_header_id (+)  AND h3.rcv_transaction_id = h6.transaction_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: DELIVER_EXPENSE
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
 , l2.LINE_NUMBER  
  , l2.DISTRIBUTION_IDENTIFIER    source_12
  , l2.RCV_ACCOUNTING_LINE_TYPE    source_25
  FROM xla_events_gt     xet 
  , CST_XLA_RCV_LINES_V  l2
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'   AND l2.event_id      = xet.event_id
;

--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.EventClass_12';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of EventClass_12'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'p_application_id = '||p_application_id||
                     ' - p_base_ledger_id = '||p_base_ledger_id||
                     ' - p_target_ledger_id  = '||p_target_ledger_id||
                     ' - p_language = '||p_language||
                     ' - p_currency_code = '||p_currency_code||
                     ' - p_sla_ledger_id = '||p_sla_ledger_id
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
-- initialze arrays
--
g_array_event.DELETE;
l_rec_array_event := l_null_rec_array_event;
--
--------------------------------------
-- 4262811 Initialze MPA Line Number
--------------------------------------
XLA_AE_HEADER_PKG.g_mpa_line_num := 0;

--

--
OPEN header_cur;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
   (p_msg      => 'SQL - FETCH header_cur'
   ,p_level    => C_LEVEL_STATEMENT
   ,p_module   => l_log_module);
END IF;
--
LOOP
FETCH header_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag 
      , l_array_source_2
      , l_array_source_3
      , l_array_source_7
      , l_array_source_8
      , l_array_source_9
      , l_array_source_11
      , l_array_source_13
      , l_array_source_13_meaning
      , l_array_source_14
      , l_array_source_15
      , l_array_source_16
      , l_array_source_17
      , l_array_source_18
      , l_array_source_19
      , l_array_source_26
      , l_array_source_37
      , l_array_source_37_meaning
      LIMIT l_rows;
--
IF (C_LEVEL_EVENT >= g_log_level) THEN
   trace
   (p_msg      => '# rows extracted from header extract objects = '||TO_CHAR(header_cur%ROWCOUNT)
   ,p_level    => C_LEVEL_EVENT
   ,p_module   => l_log_module);
END IF;
--
EXIT WHEN l_array_entity_id.COUNT = 0;

-- initialize arrays
XLA_AE_HEADER_PKG.g_rec_header_new        := NULL;
XLA_AE_LINES_PKG.g_rec_lines              := NULL;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;


-- 4262811 - when creating Accrual Reversal or MPA, use g_last_hdr_idx to increment for next header id
g_last_hdr_idx := l_array_event_id.LAST;
--
-- loop for the headers. Each iteration is for each header extract row
-- fetched in header cursor
--
FOR hdr_idx IN l_array_event_id.FIRST .. l_array_event_id.LAST LOOP

--
-- set event info as cache for other routines to refer event attributes
--
XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
   (p_application_id           => p_application_id
   ,p_primary_ledger_id        => p_primary_ledger_id
   ,p_base_ledger_id           => p_base_ledger_id
   ,p_target_ledger_id         => p_target_ledger_id
   ,p_entity_id                => l_array_entity_id(hdr_idx)
   ,p_legal_entity_id          => l_array_legal_entity_id(hdr_idx)
   ,p_entity_code              => l_array_entity_code(hdr_idx)
   ,p_transaction_num          => l_array_transaction_num(hdr_idx)
   ,p_event_id                 => l_array_event_id(hdr_idx)
   ,p_event_class_code         => l_array_class_code(hdr_idx)
   ,p_event_type_code          => l_array_event_type(hdr_idx)
   ,p_event_number             => l_array_event_number(hdr_idx)
   ,p_event_date               => l_array_event_date(hdr_idx)
   ,p_transaction_date         => l_array_transaction_date(hdr_idx)
   ,p_reference_num_1          => l_array_reference_num_1(hdr_idx)
   ,p_reference_num_2          => l_array_reference_num_2(hdr_idx)
   ,p_reference_num_3          => l_array_reference_num_3(hdr_idx)
   ,p_reference_num_4          => l_array_reference_num_4(hdr_idx)
   ,p_reference_char_1         => l_array_reference_char_1(hdr_idx)
   ,p_reference_char_2         => l_array_reference_char_2(hdr_idx)
   ,p_reference_char_3         => l_array_reference_char_3(hdr_idx)
   ,p_reference_char_4         => l_array_reference_char_4(hdr_idx)
   ,p_reference_date_1         => l_array_reference_date_1(hdr_idx)
   ,p_reference_date_2         => l_array_reference_date_2(hdr_idx)
   ,p_reference_date_3         => l_array_reference_date_3(hdr_idx)
   ,p_reference_date_4         => l_array_reference_date_4(hdr_idx)
   ,p_event_created_by         => l_array_event_created_by(hdr_idx)
   ,p_budgetary_control_flag   => l_array_budgetary_control_flag(hdr_idx));

--
-- set the status of entry to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;

--
-- initialize a row for ae header
--
XLA_AE_HEADER_PKG.InitHeader(hdr_idx);

l_event_id := l_array_event_id(hdr_idx);

--
-- storing the hdr_idx for event. May be used by line cursor.
--
g_array_event(l_event_id).array_value_num('header_index') := hdr_idx;

--
-- store sources from header extract. This can be improved to
-- store only those sources from header extract that may be used in lines
--

g_array_event(l_event_id).array_value_char('source_2') := l_array_source_2(hdr_idx);
g_array_event(l_event_id).array_value_char('source_3') := l_array_source_3(hdr_idx);
g_array_event(l_event_id).array_value_num('source_7') := l_array_source_7(hdr_idx);
g_array_event(l_event_id).array_value_char('source_8') := l_array_source_8(hdr_idx);
g_array_event(l_event_id).array_value_char('source_9') := l_array_source_9(hdr_idx);
g_array_event(l_event_id).array_value_num('source_11') := l_array_source_11(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13') := l_array_source_13(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13_meaning') := l_array_source_13_meaning(hdr_idx);
g_array_event(l_event_id).array_value_num('source_14') := l_array_source_14(hdr_idx);
g_array_event(l_event_id).array_value_num('source_15') := l_array_source_15(hdr_idx);
g_array_event(l_event_id).array_value_char('source_16') := l_array_source_16(hdr_idx);
g_array_event(l_event_id).array_value_num('source_17') := l_array_source_17(hdr_idx);
g_array_event(l_event_id).array_value_char('source_18') := l_array_source_18(hdr_idx);
g_array_event(l_event_id).array_value_num('source_19') := l_array_source_19(hdr_idx);
g_array_event(l_event_id).array_value_num('source_26') := l_array_source_26(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37') := l_array_source_37(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37_meaning') := l_array_source_37_meaning(hdr_idx);

--
-- initilaize the status of ae headers for diffrent balance types
-- the status is initialised to C_NOT_CREATED (2)
--
--g_array_event(l_event_id).array_value_num('actual_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('budget_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('encumbrance_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;

--
-- call api to validate and store accounting attributes for header
--

------------------------------------------------------------
-- Accrual Reversal : to get date for Standard Source (NONE)
------------------------------------------------------------
l_acc_rev_gl_date_source := NULL;

     l_rec_acct_attrs.array_acct_attr_code(1)   := 'ENCUMBRANCE_TYPE_ID';
      l_rec_acct_attrs.array_num_value(1) := g_array_event(l_event_id).array_value_num('source_19');
     l_rec_acct_attrs.array_acct_attr_code(2)   := 'GL_DATE';
      l_rec_acct_attrs.array_date_value(2) := 
xla_ae_sources_pkg.GetSystemSourceDate(
   p_source_code           => 'XLA_REFERENCE_DATE_1'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
);
     l_rec_acct_attrs.array_acct_attr_code(3)   := 'GL_TRANSFER_FLAG';
      l_rec_acct_attrs.array_char_value(3) := g_array_event(l_event_id).array_value_char('source_37');


XLA_AE_HEADER_PKG.SetHdrAcctAttrs(l_rec_acct_attrs);

XLA_AE_HEADER_PKG.SetJeCategoryName;

XLA_AE_HEADER_PKG.g_rec_header_new.array_event_type_code(hdr_idx)  := l_array_event_type(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(hdr_idx)         := l_array_event_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_entity_id(hdr_idx)        := l_array_entity_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_number(hdr_idx)     := l_array_event_number(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_target_ledger_id(hdr_idx) := p_target_ledger_id;


-- No header level analytical criteria

--
--accounting attribute enhancement, bug 3612931
--
l_trx_reversal_source := SUBSTR(NULL, 1,30);

IF NVL(l_trx_reversal_source, 'N') NOT IN ('N','Y') THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name            => 'XLA'
      ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
      ,p_token_1                 => 'ACCT_ATTR_NAME'
      ,p_value_1                 => xla_ae_sources_pkg.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
      ,p_token_2                 => 'PRODUCT_NAME'
      ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
      ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
      ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
      ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

ELSIF NVL(l_trx_reversal_source, 'N') = 'Y' THEN
   --
   -- following sets the accounting attributes needed to reverse
   -- accounting for a distributeion
   --
   xla_ae_lines_pkg.SetTrxReversalAttrs
      (p_event_id              => l_event_id
      ,p_gl_date               => XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(hdr_idx)
      ,p_trx_reversal_source   => l_trx_reversal_source);

END IF;


----------------------------------------------------------------
-- 4262811 -  update the header statuses to invalid in need be
----------------------------------------------------------------
--
XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx => hdr_idx);


  -----------------------------------------------
  -- No accrual reversal for the event class/type
  -----------------------------------------------
----------------------------------------------------------------

--
-- this ends the header loop iteration for one bulk fetch
--
END LOOP;

l_first_event_id   := l_array_event_id(l_array_event_id.FIRST);
l_last_event_id    := l_array_event_id(l_array_event_id.LAST);

--
-- insert dummy rows into lines gt table that were created due to
-- transaction reversals
--
IF XLA_AE_LINES_PKG.g_rec_lines.array_ae_header_id.COUNT > 0 THEN
   l_result := XLA_AE_LINES_PKG.InsertLines;
END IF;

--
-- reset the temp_line_num for each set of events fetched from header
-- cursor rather than doing it for each new event in line cursor
-- Bug 3939231
--
xla_ae_lines_pkg.g_temp_line_num := 0;



--
OPEN line_cur(x_first_event_id  => l_first_event_id, x_last_event_id  => l_last_event_id);
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - FETCH line_cur'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
LOOP
  --
  FETCH line_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag
      , l_array_extract_line_num 
      , l_array_source_12
      , l_array_source_25
      LIMIT l_rows;

  --
  IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => '# rows extracted from line extract objects = '||TO_CHAR(line_cur%ROWCOUNT)
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
  END IF;
  --
  EXIT WHEN l_array_entity_id.count = 0;

  XLA_AE_LINES_PKG.g_rec_lines := null;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;
--
--

FOR Idx IN 1..l_array_event_id.count LOOP
   --
   -- 5648433 (move l_event_id out of IF statement)  set l_event_id to be used inside IF condition
   --
   l_event_id := l_array_event_id(idx);  -- 5648433

   --
   -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
   --

   IF NVL(xla_ae_header_pkg.g_rec_header_new.array_trx_acct_reversal_option
             (g_array_event(l_event_id).array_value_num('header_index'))
         ,'N'
         ) <> 'Y'
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is not Y '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

--
-- set the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
--
-- set event info as cache for other routines to refer event attributes
--

IF l_event_id <> NVL(l_previous_event_id, -1) THEN
   l_previous_event_id := l_event_id;

   XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
      (p_application_id           => p_application_id
      ,p_primary_ledger_id        => p_primary_ledger_id
      ,p_base_ledger_id           => p_base_ledger_id
      ,p_target_ledger_id         => p_target_ledger_id
      ,p_entity_id                => l_array_entity_id(Idx)
      ,p_legal_entity_id          => l_array_legal_entity_id(Idx)
      ,p_entity_code              => l_array_entity_code(Idx)
      ,p_transaction_num          => l_array_transaction_num(Idx)
      ,p_event_id                 => l_array_event_id(Idx)
      ,p_event_class_code         => l_array_class_code(Idx)
      ,p_event_type_code          => l_array_event_type(Idx)
      ,p_event_number             => l_array_event_number(Idx)
      ,p_event_date               => l_array_event_date(Idx)
      ,p_transaction_date         => l_array_transaction_date(Idx)
      ,p_reference_num_1          => l_array_reference_num_1(Idx)
      ,p_reference_num_2          => l_array_reference_num_2(Idx)
      ,p_reference_num_3          => l_array_reference_num_3(Idx)
      ,p_reference_num_4          => l_array_reference_num_4(Idx)
      ,p_reference_char_1         => l_array_reference_char_1(Idx)
      ,p_reference_char_2         => l_array_reference_char_2(Idx)
      ,p_reference_char_3         => l_array_reference_char_3(Idx)
      ,p_reference_char_4         => l_array_reference_char_4(Idx)
      ,p_reference_date_1         => l_array_reference_date_1(Idx)
      ,p_reference_date_2         => l_array_reference_date_2(Idx)
      ,p_reference_date_3         => l_array_reference_date_3(Idx)
      ,p_reference_date_4         => l_array_reference_date_4(Idx)
      ,p_event_created_by         => l_array_event_created_by(Idx)
      ,p_budgetary_control_flag   => l_array_budgetary_control_flag(Idx));
       --
END IF;



--
xla_ae_lines_pkg.SetExtractLine(p_extract_line => l_array_extract_line_num(Idx));

l_acct_reversal_source := SUBSTR(NULL, 1,30);

IF l_continue_with_lines THEN
   IF NVL(l_acct_reversal_source, 'N') NOT IN ('N','Y','B') THEN
      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_INVALID_REVERSAL_OPTION'
         ,p_token_1                 => 'LINE_NUMBER'
         ,p_value_1                 => l_array_extract_line_num(Idx)
         ,p_token_2                 => 'PRODUCT_NAME'
         ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
         ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
         ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

   ELSIF NVL(l_acct_reversal_source, 'N') IN ('Y','B') THEN
      --
      -- following sets the accounting attributes needed to reverse
      -- accounting for a distributeion
      --

      --
      -- 5217187
      --
      l_rec_rev_acct_attrs.array_acct_attr_code(1):= 'GL_DATE';
      l_rec_rev_acct_attrs.array_date_value(1) := XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(
                                       g_array_event(l_event_id).array_value_num('header_index'));
      --
      --

      -- No reversal code generated

      xla_ae_lines_pkg.SetAcctReversalAttrs
         (p_event_id             => l_event_id
         ,p_rec_acct_attrs       => l_rec_rev_acct_attrs
         ,p_calculate_acctd_flag => l_calculate_acctd_flag
         ,p_calculate_g_l_flag   => l_calculate_g_l_flag);
   END IF;

   IF NVL(l_acct_reversal_source, 'N') IN ('N','B') THEN
       l_actual_flag := NULL;  l_actual_gain_loss_ref := '#####';

--
AcctLineType_5 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_2 => g_array_event(l_event_id).array_value_char('source_2')
 , p_source_7 => g_array_event(l_event_id).array_value_num('source_7')
 , p_source_8 => g_array_event(l_event_id).array_value_char('source_8')
 , p_source_9 => g_array_event(l_event_id).array_value_char('source_9')
 , p_source_11 => g_array_event(l_event_id).array_value_num('source_11')
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_14 => g_array_event(l_event_id).array_value_num('source_14')
 , p_source_15 => g_array_event(l_event_id).array_value_num('source_15')
 , p_source_16 => g_array_event(l_event_id).array_value_char('source_16')
 , p_source_17 => g_array_event(l_event_id).array_value_num('source_17')
 , p_source_18 => g_array_event(l_event_id).array_value_char('source_18')
 , p_source_19 => g_array_event(l_event_id).array_value_num('source_19')
 , p_source_25 => l_array_source_25(Idx)
 , p_source_26 => g_array_event(l_event_id).array_value_num('source_26')
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_6 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_2 => g_array_event(l_event_id).array_value_char('source_2')
 , p_source_3 => g_array_event(l_event_id).array_value_char('source_3')
 , p_source_7 => g_array_event(l_event_id).array_value_num('source_7')
 , p_source_8 => g_array_event(l_event_id).array_value_char('source_8')
 , p_source_9 => g_array_event(l_event_id).array_value_char('source_9')
 , p_source_11 => g_array_event(l_event_id).array_value_num('source_11')
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_14 => g_array_event(l_event_id).array_value_num('source_14')
 , p_source_15 => g_array_event(l_event_id).array_value_num('source_15')
 , p_source_16 => g_array_event(l_event_id).array_value_char('source_16')
 , p_source_17 => g_array_event(l_event_id).array_value_num('source_17')
 , p_source_18 => g_array_event(l_event_id).array_value_char('source_18')
 , p_source_19 => g_array_event(l_event_id).array_value_num('source_19')
 , p_source_25 => l_array_source_25(Idx)
 , p_source_26 => g_array_event(l_event_id).array_value_num('source_26')
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--

      -- only execute it if calculate g/l flag is yes, and primary or secondary ledger
      -- or secondary ledger that has different currency with primary
      -- or alc that is calculated by sla
      IF (((l_calculate_g_l_flag = 'Y' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> 'ALC') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in ('ALC', 'SECONDARY') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='Y'))

--      IF((l_calculate_g_l_flag='Y' or XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id <>
--                    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id)
          AND (l_actual_flag = 'A')) THEN
        XLA_AE_LINES_PKG.CreateGainOrLossLines(
          p_event_id         => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_application_id   => p_application_id
         ,p_amb_context_code => 'DEFAULT'
         ,p_entity_code      => xla_ae_journal_entry_pkg.g_cache_event.entity_code
         ,p_event_class_code => C_EVENT_CLASS_CODE
         ,p_event_type_code  => C_EVENT_TYPE_CODE
         
         ,p_gain_ccid        => -1
         ,p_loss_ccid        => -1

         ,p_actual_flag      => l_actual_flag
         ,p_enc_flag         => null
         ,p_actual_g_l_ref   => l_actual_gain_loss_ref
         ,p_enc_g_l_ref      => null
         );
      END IF;
   END IF;
END IF;

   ELSE
      --
      -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is Y'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

END LOOP;
l_result := XLA_AE_LINES_PKG.InsertLines ;
end loop;
close line_cur;


--
-- insert headers into xla_ae_headers_gt table
--
l_result := XLA_AE_HEADER_PKG.InsertHeaders ;

-- insert into errors table here.

END LOOP;

--
-- 4865292
--
-- Compare g_hdr_extract_count with event count in
-- CreateHeadersAndLines.
--
g_hdr_extract_count := g_hdr_extract_count + header_cur%ROWCOUNT;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace (p_msg     => '# rows extracted from header extract objects '
                    || ' (running total): '
                    || g_hdr_extract_count
         ,p_level   => C_LEVEL_STATEMENT
         ,p_module  => l_log_module);
END IF;

CLOSE header_cur;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of EventClass_12'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   
IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;

   
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

   RAISE;

WHEN NO_DATA_FOUND THEN

IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

FOR header_record IN header_cur
LOOP
    l_array_header_events(header_record.event_id) := header_record.event_id;
END LOOP;

l_first_event_id := l_array_header_events(l_array_header_events.FIRST);
l_last_event_id := l_array_header_events(l_array_header_events.LAST);

fnd_file.put_line(fnd_file.LOG, '                    ');
fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, 'EVENT CLASS CODE = ' || C_EVENT_CLASS_CODE );
fnd_file.put_line(fnd_file.LOG, 'The following events are present in the line extract but MISSING in the header extract: ');

FOR line_record IN line_cur(l_first_event_id, l_last_event_id)
LOOP
	IF (NOT l_array_header_events.EXISTS(line_record.event_id))  AND (NOT l_array_duplicate_checker.EXISTS(line_record.event_id)) THEN
	fnd_file.put_line(fnd_file.log, 'Event_id = ' || line_record.event_id);
        l_array_duplicate_checker(line_record.event_id) := line_record.event_id;
	END IF;
END LOOP;

fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, '                    ');


xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_12');


WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_12');
END EventClass_12;
--

---------------------------------------
--
-- PRIVATE PROCEDURE
--         insert_sources_13
--
----------------------------------------
--
PROCEDURE insert_sources_13(
                                p_target_ledger_id       IN NUMBER
                              , p_language               IN VARCHAR2
                              , p_sla_ledger_id          IN NUMBER
                              , p_pad_start_date         IN DATE
                              , p_pad_end_date           IN DATE
                         )
IS

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'DIR_INTERORG_RCPT_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'DIR_INTERORG_RCPT';
p_apps_owner                   VARCHAR2(30);
l_log_module                   VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_sources_13';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of insert_sources_13'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- select APPS owner
SELECT oracle_username
  INTO p_apps_owner
  FROM fnd_oracle_userid
 WHERE read_only_flag = 'U'
;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_target_ledger_id = '||p_target_ledger_id||
                        ' - p_language = '||p_language||
                        ' - p_sla_ledger_id  = '||p_sla_ledger_id ||
                        ' - p_pad_start_date = '||TO_CHAR(p_pad_start_date)||
                        ' - p_pad_end_date = '||TO_CHAR(p_pad_end_date)||
                        ' - p_apps_owner = '||TO_CHAR(p_apps_owner)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


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
               WHEN 1 THEN 'CST_XLA_INV_ORG_PARAMS_REF_V' 
                WHEN 2 THEN 'CST_XLA_INV_REF_V' 
                WHEN 3 THEN 'CST_XLA_INV_HEADERS_V' 
                WHEN 4 THEN 'CST_XLA_INV_REF_V' 
                WHEN 5 THEN 'CST_XLA_INV_REF_V' 
                WHEN 6 THEN 'PSA_CST_XLA_UPG_V' 
                WHEN 7 THEN 'PO_REQ_HEADERS_REF_V' 
                WHEN 8 THEN 'PO_REQ_DISTS_REF_V' 
                WHEN 9 THEN 'CST_XLA_INV_REF_V' 
                WHEN 10 THEN 'CST_XLA_INV_REF_V' 
                WHEN 11 THEN 'CST_XLA_INV_REF_V' 
                WHEN 12 THEN 'CST_XLA_INV_REF_V' 
                WHEN 13 THEN 'PO_REQ_DISTS_REF_V' 
                WHEN 14 THEN 'PO_REQ_HEADERS_REF_V' 
                WHEN 15 THEN 'CST_XLA_INV_HEADERS_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                WHEN 2 THEN 'HEADER' 
                WHEN 3 THEN 'HEADER' 
                WHEN 4 THEN 'HEADER' 
                WHEN 5 THEN 'HEADER' 
                WHEN 6 THEN 'HEADER' 
                WHEN 7 THEN 'HEADER' 
                WHEN 8 THEN 'HEADER' 
                WHEN 9 THEN 'HEADER' 
                WHEN 10 THEN 'HEADER' 
                WHEN 11 THEN 'HEADER' 
                WHEN 12 THEN 'HEADER' 
                WHEN 13 THEN 'HEADER' 
                WHEN 14 THEN 'HEADER' 
                WHEN 15 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                WHEN 3 THEN '707' 
                WHEN 4 THEN '707' 
                WHEN 5 THEN '707' 
                WHEN 6 THEN '707' 
                WHEN 7 THEN '201' 
                WHEN 8 THEN '201' 
                WHEN 9 THEN '707' 
                WHEN 10 THEN '707' 
                WHEN 11 THEN '707' 
                WHEN 12 THEN '707' 
                WHEN 13 THEN '201' 
                WHEN 14 THEN '201' 
                WHEN 15 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'ENCUMBRANCE_REVERSAL_FLAG' 
                WHEN 2 THEN 'APPLIED_TO_APPL_ID' 
                WHEN 3 THEN 'DISTRIBUTION_TYPE' 
                WHEN 4 THEN 'ENCUM_REVERSAL_AMOUNT_ENTERED' 
                WHEN 5 THEN 'ENCUMBRANCE_REVERSAL_AMOUNT' 
                WHEN 6 THEN 'CST_ENCUM_UPG_OPTION' 
                WHEN 7 THEN 'REQ_ENCUMBRANCE_FLAG' 
                WHEN 8 THEN 'REQ_RESERVED_FLAG' 
                WHEN 9 THEN 'BUS_FLOW_REQ_DIST_TYPE' 
                WHEN 10 THEN 'BUS_FLOW_REQ_ENTITY_CODE' 
                WHEN 11 THEN 'BUS_FLOW_REQ_DIST_ID' 
                WHEN 12 THEN 'BUS_FLOW_REQ_ID' 
                WHEN 13 THEN 'REQ_BUDGET_ACCOUNT' 
                WHEN 14 THEN 'REQ_ENCUMBRANCE_TYPE_ID' 
                WHEN 15 THEN 'TRANSFER_TO_GL_INDICATOR' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h3.ENCUMBRANCE_REVERSAL_FLAG)
                WHEN 2 THEN TO_CHAR(h4.APPLIED_TO_APPL_ID)
                WHEN 3 THEN TO_CHAR(h1.DISTRIBUTION_TYPE)
                WHEN 4 THEN TO_CHAR(h4.ENCUM_REVERSAL_AMOUNT_ENTERED)
                WHEN 5 THEN TO_CHAR(h4.ENCUMBRANCE_REVERSAL_AMOUNT)
                WHEN 6 THEN TO_CHAR(h7.CST_ENCUM_UPG_OPTION)
                WHEN 7 THEN TO_CHAR(h6.REQ_ENCUMBRANCE_FLAG)
                WHEN 8 THEN TO_CHAR(h5.REQ_RESERVED_FLAG)
                WHEN 9 THEN TO_CHAR(h4.BUS_FLOW_REQ_DIST_TYPE)
                WHEN 10 THEN TO_CHAR(h4.BUS_FLOW_REQ_ENTITY_CODE)
                WHEN 11 THEN TO_CHAR(h4.BUS_FLOW_REQ_DIST_ID)
                WHEN 12 THEN TO_CHAR(h4.BUS_FLOW_REQ_ID)
                WHEN 13 THEN TO_CHAR(h5.REQ_BUDGET_ACCOUNT)
                WHEN 14 THEN TO_CHAR(h6.REQ_ENCUMBRANCE_TYPE_ID)
                WHEN 15 THEN TO_CHAR(h1.TRANSFER_TO_GL_INDICATOR)
                
                ELSE null
              END                           source_value
            , CASE r
                WHEN 3 THEN fvl13.meaning
                WHEN 15 THEN fvl37.meaning
                
                ELSE null
              END               source_meaning
         FROM xla_events_gt     xet  
      , CST_XLA_INV_HEADERS_V  h1
      , CST_XLA_INV_ORG_PARAMS_REF_V  h3
      , CST_XLA_INV_REF_V  h4
      , PO_REQ_DISTS_REF_V  h5
      , PO_REQ_HEADERS_REF_V  h6
      , PSA_CST_XLA_UPG_V  h7
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
             ,(select rownum r from all_objects where rownum <= 15 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id
 AND h3.inv_organization_id  (+) = h1.organization_id AND h4.ref_transaction_id = h1.transaction_id AND h4.bus_flow_req_dist_id=h5.req_distribution_id (+)  AND h4.bus_flow_req_id = h6.req_id (+)  AND h4.rcv_transaction_id = h7.transaction_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of header sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--



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
            , l2.line_number                 line_number
            , CASE r
               WHEN 1 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 2 THEN 'CST_XLA_INV_LINES_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'LINE' 
                WHEN 2 THEN 'LINE' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'DISTRIBUTION_IDENTIFIER' 
                WHEN 2 THEN 'CURRENCY_CODE' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(l2.DISTRIBUTION_IDENTIFIER)
                WHEN 2 THEN TO_CHAR(l2.CURRENCY_CODE)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM  xla_events_gt     xet  
        , CST_XLA_INV_LINES_V  l2
            , (select rownum r from all_objects where rownum <= 2 and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_class_code = C_EVENT_CLASS_CODE
            AND l2.event_id          = xet.event_id

)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of line sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of insert_sources_13'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
      END IF;
      RAISE;
  WHEN OTHERS THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.insert_sources_13');
END insert_sources_13;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         EventClass_13
--
----------------------------------------
--
FUNCTION EventClass_13
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_target_ledger_id       IN NUMBER
       ,p_language               IN VARCHAR2
       ,p_currency_code          IN VARCHAR2
       ,p_sla_ledger_id          IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN BOOLEAN IS
--
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'DIR_INTERORG_RCPT_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'DIR_INTERORG_RCPT';

l_calculate_acctd_flag   VARCHAR2(1) :='N';
l_calculate_g_l_flag     VARCHAR2(1) :='N';
--
l_array_legal_entity_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_transaction_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_event_id                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_class_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_number                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_event_date                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_transaction_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_num_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_char_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_date_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_event_created_by               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V100L;
l_array_budgetary_control_flag         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_header_events                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added
l_array_duplicate_checker              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added

l_event_id                             NUMBER;
l_previous_event_id                    NUMBER;
l_first_event_id                       NUMBER;
l_last_event_id                        NUMBER;

l_rec_acct_attrs                       XLA_AE_HEADER_PKG.t_rec_acct_attrs;
l_rec_rev_acct_attrs                   XLA_AE_LINES_PKG.t_rec_acct_attrs;
--
--
l_result                    BOOLEAN := TRUE;
l_rows                      NUMBER  := 1000;
l_event_type_name           VARCHAR2(80) := 'All';
l_event_class_name          VARCHAR2(80) := 'Direct Interorg Receipt';
l_description               VARCHAR2(4000);
l_transaction_reversal      NUMBER;
l_ae_header_id              NUMBER;
l_array_extract_line_num    xla_ae_journal_entry_pkg.t_array_Num;
l_log_module                VARCHAR2(240);
--
l_acct_reversal_source      VARCHAR2(30);
l_trx_reversal_source       VARCHAR2(30);

l_continue_with_lines       BOOLEAN := TRUE;
--
l_acc_rev_gl_date_source    DATE;                      -- 4262811
--
type t_array_event_id is table of number index by binary_integer;

l_rec_array_event                    t_rec_array_event;
l_null_rec_array_event               t_rec_array_event;
l_array_ae_header_id                 xla_number_array_type;
l_actual_flag                        VARCHAR2(1) := NULL;
l_actual_gain_loss_ref               VARCHAR2(30) := '#####';
l_balance_type_code                  VARCHAR2(1) :=NULL;
l_gain_or_loss_ref                   VARCHAR2(30) :=NULL;

--
TYPE t_array_lookup_meaning IS TABLE OF fnd_lookup_values.meaning%TYPE INDEX BY BINARY_INTEGER;
--

TYPE t_array_source_4 IS TABLE OF CST_XLA_INV_ORG_PARAMS_REF_V.ENCUMBRANCE_REVERSAL_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_7 IS TABLE OF CST_XLA_INV_REF_V.APPLIED_TO_APPL_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_13 IS TABLE OF CST_XLA_INV_HEADERS_V.DISTRIBUTION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_15 IS TABLE OF CST_XLA_INV_REF_V.ENCUM_REVERSAL_AMOUNT_ENTERED%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_17 IS TABLE OF CST_XLA_INV_REF_V.ENCUMBRANCE_REVERSAL_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_18 IS TABLE OF PSA_CST_XLA_UPG_V.CST_ENCUM_UPG_OPTION%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_28 IS TABLE OF PO_REQ_HEADERS_REF_V.REQ_ENCUMBRANCE_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_29 IS TABLE OF PO_REQ_DISTS_REF_V.REQ_RESERVED_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_30 IS TABLE OF CST_XLA_INV_REF_V.BUS_FLOW_REQ_DIST_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_31 IS TABLE OF CST_XLA_INV_REF_V.BUS_FLOW_REQ_ENTITY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_32 IS TABLE OF CST_XLA_INV_REF_V.BUS_FLOW_REQ_DIST_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_33 IS TABLE OF CST_XLA_INV_REF_V.BUS_FLOW_REQ_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_34 IS TABLE OF PO_REQ_DISTS_REF_V.REQ_BUDGET_ACCOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_35 IS TABLE OF PO_REQ_HEADERS_REF_V.REQ_ENCUMBRANCE_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_37 IS TABLE OF CST_XLA_INV_HEADERS_V.TRANSFER_TO_GL_INDICATOR%TYPE INDEX BY BINARY_INTEGER;

TYPE t_array_source_12 IS TABLE OF CST_XLA_INV_LINES_V.DISTRIBUTION_IDENTIFIER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_16 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;

l_array_source_4              t_array_source_4;
l_array_source_7              t_array_source_7;
l_array_source_13              t_array_source_13;
l_array_source_13_meaning      t_array_lookup_meaning;
l_array_source_15              t_array_source_15;
l_array_source_17              t_array_source_17;
l_array_source_18              t_array_source_18;
l_array_source_28              t_array_source_28;
l_array_source_29              t_array_source_29;
l_array_source_30              t_array_source_30;
l_array_source_31              t_array_source_31;
l_array_source_32              t_array_source_32;
l_array_source_33              t_array_source_33;
l_array_source_34              t_array_source_34;
l_array_source_35              t_array_source_35;
l_array_source_37              t_array_source_37;
l_array_source_37_meaning      t_array_lookup_meaning;

l_array_source_12      t_array_source_12;
l_array_source_16      t_array_source_16;

--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: DIR_INTERORG_RCPT
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
  , h3.ENCUMBRANCE_REVERSAL_FLAG    source_4
  , h4.APPLIED_TO_APPL_ID    source_7
  , h1.DISTRIBUTION_TYPE    source_13
  , fvl13.meaning   source_13_meaning
  , h4.ENCUM_REVERSAL_AMOUNT_ENTERED    source_15
  , h4.ENCUMBRANCE_REVERSAL_AMOUNT    source_17
  , h7.CST_ENCUM_UPG_OPTION    source_18
  , h6.REQ_ENCUMBRANCE_FLAG    source_28
  , h5.REQ_RESERVED_FLAG    source_29
  , h4.BUS_FLOW_REQ_DIST_TYPE    source_30
  , h4.BUS_FLOW_REQ_ENTITY_CODE    source_31
  , h4.BUS_FLOW_REQ_DIST_ID    source_32
  , h4.BUS_FLOW_REQ_ID    source_33
  , h5.REQ_BUDGET_ACCOUNT    source_34
  , h6.REQ_ENCUMBRANCE_TYPE_ID    source_35
  , h1.TRANSFER_TO_GL_INDICATOR    source_37
  , fvl37.meaning   source_37_meaning
  FROM xla_events_gt     xet 
  , CST_XLA_INV_HEADERS_V  h1
  , CST_XLA_INV_ORG_PARAMS_REF_V  h3
  , CST_XLA_INV_REF_V  h4
  , PO_REQ_DISTS_REF_V  h5
  , PO_REQ_HEADERS_REF_V  h6
  , PSA_CST_XLA_UPG_V  h7
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id
 AND h3.INV_ORGANIZATION_ID  (+) = h1.ORGANIZATION_ID AND h4.ref_transaction_id = h1.transaction_id AND h4.BUS_FLOW_REQ_DIST_ID=h5.REQ_DISTRIBUTION_ID (+)  AND h4.BUS_FLOW_REQ_ID = h6.REQ_ID (+)  AND h4.rcv_transaction_id = h7.transaction_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: DIR_INTERORG_RCPT
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
 , l2.LINE_NUMBER  
  , l2.DISTRIBUTION_IDENTIFIER    source_12
  , l2.CURRENCY_CODE    source_16
  FROM xla_events_gt     xet 
  , CST_XLA_INV_LINES_V  l2
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'   AND l2.event_id      = xet.event_id
;

--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.EventClass_13';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of EventClass_13'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'p_application_id = '||p_application_id||
                     ' - p_base_ledger_id = '||p_base_ledger_id||
                     ' - p_target_ledger_id  = '||p_target_ledger_id||
                     ' - p_language = '||p_language||
                     ' - p_currency_code = '||p_currency_code||
                     ' - p_sla_ledger_id = '||p_sla_ledger_id
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
-- initialze arrays
--
g_array_event.DELETE;
l_rec_array_event := l_null_rec_array_event;
--
--------------------------------------
-- 4262811 Initialze MPA Line Number
--------------------------------------
XLA_AE_HEADER_PKG.g_mpa_line_num := 0;

--

--
OPEN header_cur;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
   (p_msg      => 'SQL - FETCH header_cur'
   ,p_level    => C_LEVEL_STATEMENT
   ,p_module   => l_log_module);
END IF;
--
LOOP
FETCH header_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag 
      , l_array_source_4
      , l_array_source_7
      , l_array_source_13
      , l_array_source_13_meaning
      , l_array_source_15
      , l_array_source_17
      , l_array_source_18
      , l_array_source_28
      , l_array_source_29
      , l_array_source_30
      , l_array_source_31
      , l_array_source_32
      , l_array_source_33
      , l_array_source_34
      , l_array_source_35
      , l_array_source_37
      , l_array_source_37_meaning
      LIMIT l_rows;
--
IF (C_LEVEL_EVENT >= g_log_level) THEN
   trace
   (p_msg      => '# rows extracted from header extract objects = '||TO_CHAR(header_cur%ROWCOUNT)
   ,p_level    => C_LEVEL_EVENT
   ,p_module   => l_log_module);
END IF;
--
EXIT WHEN l_array_entity_id.COUNT = 0;

-- initialize arrays
XLA_AE_HEADER_PKG.g_rec_header_new        := NULL;
XLA_AE_LINES_PKG.g_rec_lines              := NULL;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;


-- 4262811 - when creating Accrual Reversal or MPA, use g_last_hdr_idx to increment for next header id
g_last_hdr_idx := l_array_event_id.LAST;
--
-- loop for the headers. Each iteration is for each header extract row
-- fetched in header cursor
--
FOR hdr_idx IN l_array_event_id.FIRST .. l_array_event_id.LAST LOOP

--
-- set event info as cache for other routines to refer event attributes
--
XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
   (p_application_id           => p_application_id
   ,p_primary_ledger_id        => p_primary_ledger_id
   ,p_base_ledger_id           => p_base_ledger_id
   ,p_target_ledger_id         => p_target_ledger_id
   ,p_entity_id                => l_array_entity_id(hdr_idx)
   ,p_legal_entity_id          => l_array_legal_entity_id(hdr_idx)
   ,p_entity_code              => l_array_entity_code(hdr_idx)
   ,p_transaction_num          => l_array_transaction_num(hdr_idx)
   ,p_event_id                 => l_array_event_id(hdr_idx)
   ,p_event_class_code         => l_array_class_code(hdr_idx)
   ,p_event_type_code          => l_array_event_type(hdr_idx)
   ,p_event_number             => l_array_event_number(hdr_idx)
   ,p_event_date               => l_array_event_date(hdr_idx)
   ,p_transaction_date         => l_array_transaction_date(hdr_idx)
   ,p_reference_num_1          => l_array_reference_num_1(hdr_idx)
   ,p_reference_num_2          => l_array_reference_num_2(hdr_idx)
   ,p_reference_num_3          => l_array_reference_num_3(hdr_idx)
   ,p_reference_num_4          => l_array_reference_num_4(hdr_idx)
   ,p_reference_char_1         => l_array_reference_char_1(hdr_idx)
   ,p_reference_char_2         => l_array_reference_char_2(hdr_idx)
   ,p_reference_char_3         => l_array_reference_char_3(hdr_idx)
   ,p_reference_char_4         => l_array_reference_char_4(hdr_idx)
   ,p_reference_date_1         => l_array_reference_date_1(hdr_idx)
   ,p_reference_date_2         => l_array_reference_date_2(hdr_idx)
   ,p_reference_date_3         => l_array_reference_date_3(hdr_idx)
   ,p_reference_date_4         => l_array_reference_date_4(hdr_idx)
   ,p_event_created_by         => l_array_event_created_by(hdr_idx)
   ,p_budgetary_control_flag   => l_array_budgetary_control_flag(hdr_idx));

--
-- set the status of entry to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;

--
-- initialize a row for ae header
--
XLA_AE_HEADER_PKG.InitHeader(hdr_idx);

l_event_id := l_array_event_id(hdr_idx);

--
-- storing the hdr_idx for event. May be used by line cursor.
--
g_array_event(l_event_id).array_value_num('header_index') := hdr_idx;

--
-- store sources from header extract. This can be improved to
-- store only those sources from header extract that may be used in lines
--

g_array_event(l_event_id).array_value_char('source_4') := l_array_source_4(hdr_idx);
g_array_event(l_event_id).array_value_num('source_7') := l_array_source_7(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13') := l_array_source_13(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13_meaning') := l_array_source_13_meaning(hdr_idx);
g_array_event(l_event_id).array_value_num('source_15') := l_array_source_15(hdr_idx);
g_array_event(l_event_id).array_value_num('source_17') := l_array_source_17(hdr_idx);
g_array_event(l_event_id).array_value_char('source_18') := l_array_source_18(hdr_idx);
g_array_event(l_event_id).array_value_char('source_28') := l_array_source_28(hdr_idx);
g_array_event(l_event_id).array_value_char('source_29') := l_array_source_29(hdr_idx);
g_array_event(l_event_id).array_value_char('source_30') := l_array_source_30(hdr_idx);
g_array_event(l_event_id).array_value_char('source_31') := l_array_source_31(hdr_idx);
g_array_event(l_event_id).array_value_num('source_32') := l_array_source_32(hdr_idx);
g_array_event(l_event_id).array_value_num('source_33') := l_array_source_33(hdr_idx);
g_array_event(l_event_id).array_value_num('source_34') := l_array_source_34(hdr_idx);
g_array_event(l_event_id).array_value_num('source_35') := l_array_source_35(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37') := l_array_source_37(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37_meaning') := l_array_source_37_meaning(hdr_idx);

--
-- initilaize the status of ae headers for diffrent balance types
-- the status is initialised to C_NOT_CREATED (2)
--
--g_array_event(l_event_id).array_value_num('actual_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('budget_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('encumbrance_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;

--
-- call api to validate and store accounting attributes for header
--

------------------------------------------------------------
-- Accrual Reversal : to get date for Standard Source (NONE)
------------------------------------------------------------
l_acc_rev_gl_date_source := NULL;

     l_rec_acct_attrs.array_acct_attr_code(1)   := 'ENCUMBRANCE_TYPE_ID';
      l_rec_acct_attrs.array_num_value(1) := g_array_event(l_event_id).array_value_num('source_35');
     l_rec_acct_attrs.array_acct_attr_code(2)   := 'GL_DATE';
      l_rec_acct_attrs.array_date_value(2) := 
xla_ae_sources_pkg.GetSystemSourceDate(
   p_source_code           => 'XLA_REFERENCE_DATE_1'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
);
     l_rec_acct_attrs.array_acct_attr_code(3)   := 'GL_TRANSFER_FLAG';
      l_rec_acct_attrs.array_char_value(3) := g_array_event(l_event_id).array_value_char('source_37');


XLA_AE_HEADER_PKG.SetHdrAcctAttrs(l_rec_acct_attrs);

XLA_AE_HEADER_PKG.SetJeCategoryName;

XLA_AE_HEADER_PKG.g_rec_header_new.array_event_type_code(hdr_idx)  := l_array_event_type(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(hdr_idx)         := l_array_event_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_entity_id(hdr_idx)        := l_array_entity_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_number(hdr_idx)     := l_array_event_number(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_target_ledger_id(hdr_idx) := p_target_ledger_id;


-- No header level analytical criteria

--
--accounting attribute enhancement, bug 3612931
--
l_trx_reversal_source := SUBSTR(NULL, 1,30);

IF NVL(l_trx_reversal_source, 'N') NOT IN ('N','Y') THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name            => 'XLA'
      ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
      ,p_token_1                 => 'ACCT_ATTR_NAME'
      ,p_value_1                 => xla_ae_sources_pkg.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
      ,p_token_2                 => 'PRODUCT_NAME'
      ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
      ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
      ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
      ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

ELSIF NVL(l_trx_reversal_source, 'N') = 'Y' THEN
   --
   -- following sets the accounting attributes needed to reverse
   -- accounting for a distributeion
   --
   xla_ae_lines_pkg.SetTrxReversalAttrs
      (p_event_id              => l_event_id
      ,p_gl_date               => XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(hdr_idx)
      ,p_trx_reversal_source   => l_trx_reversal_source);

END IF;


----------------------------------------------------------------
-- 4262811 -  update the header statuses to invalid in need be
----------------------------------------------------------------
--
XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx => hdr_idx);


  -----------------------------------------------
  -- No accrual reversal for the event class/type
  -----------------------------------------------
----------------------------------------------------------------

--
-- this ends the header loop iteration for one bulk fetch
--
END LOOP;

l_first_event_id   := l_array_event_id(l_array_event_id.FIRST);
l_last_event_id    := l_array_event_id(l_array_event_id.LAST);

--
-- insert dummy rows into lines gt table that were created due to
-- transaction reversals
--
IF XLA_AE_LINES_PKG.g_rec_lines.array_ae_header_id.COUNT > 0 THEN
   l_result := XLA_AE_LINES_PKG.InsertLines;
END IF;

--
-- reset the temp_line_num for each set of events fetched from header
-- cursor rather than doing it for each new event in line cursor
-- Bug 3939231
--
xla_ae_lines_pkg.g_temp_line_num := 0;



--
OPEN line_cur(x_first_event_id  => l_first_event_id, x_last_event_id  => l_last_event_id);
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - FETCH line_cur'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
LOOP
  --
  FETCH line_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag
      , l_array_extract_line_num 
      , l_array_source_12
      , l_array_source_16
      LIMIT l_rows;

  --
  IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => '# rows extracted from line extract objects = '||TO_CHAR(line_cur%ROWCOUNT)
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
  END IF;
  --
  EXIT WHEN l_array_entity_id.count = 0;

  XLA_AE_LINES_PKG.g_rec_lines := null;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;
--
--

FOR Idx IN 1..l_array_event_id.count LOOP
   --
   -- 5648433 (move l_event_id out of IF statement)  set l_event_id to be used inside IF condition
   --
   l_event_id := l_array_event_id(idx);  -- 5648433

   --
   -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
   --

   IF NVL(xla_ae_header_pkg.g_rec_header_new.array_trx_acct_reversal_option
             (g_array_event(l_event_id).array_value_num('header_index'))
         ,'N'
         ) <> 'Y'
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is not Y '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

--
-- set the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
--
-- set event info as cache for other routines to refer event attributes
--

IF l_event_id <> NVL(l_previous_event_id, -1) THEN
   l_previous_event_id := l_event_id;

   XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
      (p_application_id           => p_application_id
      ,p_primary_ledger_id        => p_primary_ledger_id
      ,p_base_ledger_id           => p_base_ledger_id
      ,p_target_ledger_id         => p_target_ledger_id
      ,p_entity_id                => l_array_entity_id(Idx)
      ,p_legal_entity_id          => l_array_legal_entity_id(Idx)
      ,p_entity_code              => l_array_entity_code(Idx)
      ,p_transaction_num          => l_array_transaction_num(Idx)
      ,p_event_id                 => l_array_event_id(Idx)
      ,p_event_class_code         => l_array_class_code(Idx)
      ,p_event_type_code          => l_array_event_type(Idx)
      ,p_event_number             => l_array_event_number(Idx)
      ,p_event_date               => l_array_event_date(Idx)
      ,p_transaction_date         => l_array_transaction_date(Idx)
      ,p_reference_num_1          => l_array_reference_num_1(Idx)
      ,p_reference_num_2          => l_array_reference_num_2(Idx)
      ,p_reference_num_3          => l_array_reference_num_3(Idx)
      ,p_reference_num_4          => l_array_reference_num_4(Idx)
      ,p_reference_char_1         => l_array_reference_char_1(Idx)
      ,p_reference_char_2         => l_array_reference_char_2(Idx)
      ,p_reference_char_3         => l_array_reference_char_3(Idx)
      ,p_reference_char_4         => l_array_reference_char_4(Idx)
      ,p_reference_date_1         => l_array_reference_date_1(Idx)
      ,p_reference_date_2         => l_array_reference_date_2(Idx)
      ,p_reference_date_3         => l_array_reference_date_3(Idx)
      ,p_reference_date_4         => l_array_reference_date_4(Idx)
      ,p_event_created_by         => l_array_event_created_by(Idx)
      ,p_budgetary_control_flag   => l_array_budgetary_control_flag(Idx));
       --
END IF;



--
xla_ae_lines_pkg.SetExtractLine(p_extract_line => l_array_extract_line_num(Idx));

l_acct_reversal_source := SUBSTR(NULL, 1,30);

IF l_continue_with_lines THEN
   IF NVL(l_acct_reversal_source, 'N') NOT IN ('N','Y','B') THEN
      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_INVALID_REVERSAL_OPTION'
         ,p_token_1                 => 'LINE_NUMBER'
         ,p_value_1                 => l_array_extract_line_num(Idx)
         ,p_token_2                 => 'PRODUCT_NAME'
         ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
         ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
         ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

   ELSIF NVL(l_acct_reversal_source, 'N') IN ('Y','B') THEN
      --
      -- following sets the accounting attributes needed to reverse
      -- accounting for a distributeion
      --

      --
      -- 5217187
      --
      l_rec_rev_acct_attrs.array_acct_attr_code(1):= 'GL_DATE';
      l_rec_rev_acct_attrs.array_date_value(1) := XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(
                                       g_array_event(l_event_id).array_value_num('header_index'));
      --
      --

      -- No reversal code generated

      xla_ae_lines_pkg.SetAcctReversalAttrs
         (p_event_id             => l_event_id
         ,p_rec_acct_attrs       => l_rec_rev_acct_attrs
         ,p_calculate_acctd_flag => l_calculate_acctd_flag
         ,p_calculate_g_l_flag   => l_calculate_g_l_flag);
   END IF;

   IF NVL(l_acct_reversal_source, 'N') IN ('N','B') THEN
       l_actual_flag := NULL;  l_actual_gain_loss_ref := '#####';

--
AcctLineType_9 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_4 => g_array_event(l_event_id).array_value_char('source_4')
 , p_source_7 => g_array_event(l_event_id).array_value_num('source_7')
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_15 => g_array_event(l_event_id).array_value_num('source_15')
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => g_array_event(l_event_id).array_value_num('source_17')
 , p_source_18 => g_array_event(l_event_id).array_value_char('source_18')
 , p_source_28 => g_array_event(l_event_id).array_value_char('source_28')
 , p_source_29 => g_array_event(l_event_id).array_value_char('source_29')
 , p_source_30 => g_array_event(l_event_id).array_value_char('source_30')
 , p_source_31 => g_array_event(l_event_id).array_value_char('source_31')
 , p_source_32 => g_array_event(l_event_id).array_value_num('source_32')
 , p_source_33 => g_array_event(l_event_id).array_value_num('source_33')
 , p_source_34 => g_array_event(l_event_id).array_value_num('source_34')
 , p_source_35 => g_array_event(l_event_id).array_value_num('source_35')
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--

      -- only execute it if calculate g/l flag is yes, and primary or secondary ledger
      -- or secondary ledger that has different currency with primary
      -- or alc that is calculated by sla
      IF (((l_calculate_g_l_flag = 'Y' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> 'ALC') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in ('ALC', 'SECONDARY') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='Y'))

--      IF((l_calculate_g_l_flag='Y' or XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id <>
--                    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id)
          AND (l_actual_flag = 'A')) THEN
        XLA_AE_LINES_PKG.CreateGainOrLossLines(
          p_event_id         => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_application_id   => p_application_id
         ,p_amb_context_code => 'DEFAULT'
         ,p_entity_code      => xla_ae_journal_entry_pkg.g_cache_event.entity_code
         ,p_event_class_code => C_EVENT_CLASS_CODE
         ,p_event_type_code  => C_EVENT_TYPE_CODE
         
         ,p_gain_ccid        => -1
         ,p_loss_ccid        => -1

         ,p_actual_flag      => l_actual_flag
         ,p_enc_flag         => null
         ,p_actual_g_l_ref   => l_actual_gain_loss_ref
         ,p_enc_g_l_ref      => null
         );
      END IF;
   END IF;
END IF;

   ELSE
      --
      -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is Y'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

END LOOP;
l_result := XLA_AE_LINES_PKG.InsertLines ;
end loop;
close line_cur;


--
-- insert headers into xla_ae_headers_gt table
--
l_result := XLA_AE_HEADER_PKG.InsertHeaders ;

-- insert into errors table here.

END LOOP;

--
-- 4865292
--
-- Compare g_hdr_extract_count with event count in
-- CreateHeadersAndLines.
--
g_hdr_extract_count := g_hdr_extract_count + header_cur%ROWCOUNT;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace (p_msg     => '# rows extracted from header extract objects '
                    || ' (running total): '
                    || g_hdr_extract_count
         ,p_level   => C_LEVEL_STATEMENT
         ,p_module  => l_log_module);
END IF;

CLOSE header_cur;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of EventClass_13'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   
IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;

   
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

   RAISE;

WHEN NO_DATA_FOUND THEN

IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

FOR header_record IN header_cur
LOOP
    l_array_header_events(header_record.event_id) := header_record.event_id;
END LOOP;

l_first_event_id := l_array_header_events(l_array_header_events.FIRST);
l_last_event_id := l_array_header_events(l_array_header_events.LAST);

fnd_file.put_line(fnd_file.LOG, '                    ');
fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, 'EVENT CLASS CODE = ' || C_EVENT_CLASS_CODE );
fnd_file.put_line(fnd_file.LOG, 'The following events are present in the line extract but MISSING in the header extract: ');

FOR line_record IN line_cur(l_first_event_id, l_last_event_id)
LOOP
	IF (NOT l_array_header_events.EXISTS(line_record.event_id))  AND (NOT l_array_duplicate_checker.EXISTS(line_record.event_id)) THEN
	fnd_file.put_line(fnd_file.log, 'Event_id = ' || line_record.event_id);
        l_array_duplicate_checker(line_record.event_id) := line_record.event_id;
	END IF;
END LOOP;

fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, '                    ');


xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_13');


WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_13');
END EventClass_13;
--

---------------------------------------
--
-- PRIVATE PROCEDURE
--         insert_sources_14
--
----------------------------------------
--
PROCEDURE insert_sources_14(
                                p_target_ledger_id       IN NUMBER
                              , p_language               IN VARCHAR2
                              , p_sla_ledger_id          IN NUMBER
                              , p_pad_start_date         IN DATE
                              , p_pad_end_date           IN DATE
                         )
IS

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'FOB_RCPT_RECIPIENT_RCPT_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'FOB_RCPT_RECIPIENT_RCPT';
p_apps_owner                   VARCHAR2(30);
l_log_module                   VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_sources_14';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of insert_sources_14'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- select APPS owner
SELECT oracle_username
  INTO p_apps_owner
  FROM fnd_oracle_userid
 WHERE read_only_flag = 'U'
;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_target_ledger_id = '||p_target_ledger_id||
                        ' - p_language = '||p_language||
                        ' - p_sla_ledger_id  = '||p_sla_ledger_id ||
                        ' - p_pad_start_date = '||TO_CHAR(p_pad_start_date)||
                        ' - p_pad_end_date = '||TO_CHAR(p_pad_end_date)||
                        ' - p_apps_owner = '||TO_CHAR(p_apps_owner)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


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
               WHEN 1 THEN 'CST_XLA_INV_ORG_PARAMS_REF_V' 
                WHEN 2 THEN 'CST_XLA_INV_REF_V' 
                WHEN 3 THEN 'CST_XLA_INV_HEADERS_V' 
                WHEN 4 THEN 'CST_XLA_INV_REF_V' 
                WHEN 5 THEN 'CST_XLA_INV_REF_V' 
                WHEN 6 THEN 'PSA_CST_XLA_UPG_V' 
                WHEN 7 THEN 'PO_REQ_HEADERS_REF_V' 
                WHEN 8 THEN 'PO_REQ_DISTS_REF_V' 
                WHEN 9 THEN 'CST_XLA_INV_REF_V' 
                WHEN 10 THEN 'CST_XLA_INV_REF_V' 
                WHEN 11 THEN 'CST_XLA_INV_REF_V' 
                WHEN 12 THEN 'CST_XLA_INV_REF_V' 
                WHEN 13 THEN 'PO_REQ_DISTS_REF_V' 
                WHEN 14 THEN 'PO_REQ_HEADERS_REF_V' 
                WHEN 15 THEN 'CST_XLA_INV_HEADERS_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                WHEN 2 THEN 'HEADER' 
                WHEN 3 THEN 'HEADER' 
                WHEN 4 THEN 'HEADER' 
                WHEN 5 THEN 'HEADER' 
                WHEN 6 THEN 'HEADER' 
                WHEN 7 THEN 'HEADER' 
                WHEN 8 THEN 'HEADER' 
                WHEN 9 THEN 'HEADER' 
                WHEN 10 THEN 'HEADER' 
                WHEN 11 THEN 'HEADER' 
                WHEN 12 THEN 'HEADER' 
                WHEN 13 THEN 'HEADER' 
                WHEN 14 THEN 'HEADER' 
                WHEN 15 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                WHEN 3 THEN '707' 
                WHEN 4 THEN '707' 
                WHEN 5 THEN '707' 
                WHEN 6 THEN '707' 
                WHEN 7 THEN '201' 
                WHEN 8 THEN '201' 
                WHEN 9 THEN '707' 
                WHEN 10 THEN '707' 
                WHEN 11 THEN '707' 
                WHEN 12 THEN '707' 
                WHEN 13 THEN '201' 
                WHEN 14 THEN '201' 
                WHEN 15 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'ENCUMBRANCE_REVERSAL_FLAG' 
                WHEN 2 THEN 'APPLIED_TO_APPL_ID' 
                WHEN 3 THEN 'DISTRIBUTION_TYPE' 
                WHEN 4 THEN 'ENCUM_REVERSAL_AMOUNT_ENTERED' 
                WHEN 5 THEN 'ENCUMBRANCE_REVERSAL_AMOUNT' 
                WHEN 6 THEN 'CST_ENCUM_UPG_OPTION' 
                WHEN 7 THEN 'REQ_ENCUMBRANCE_FLAG' 
                WHEN 8 THEN 'REQ_RESERVED_FLAG' 
                WHEN 9 THEN 'BUS_FLOW_REQ_DIST_TYPE' 
                WHEN 10 THEN 'BUS_FLOW_REQ_ENTITY_CODE' 
                WHEN 11 THEN 'BUS_FLOW_REQ_DIST_ID' 
                WHEN 12 THEN 'BUS_FLOW_REQ_ID' 
                WHEN 13 THEN 'REQ_BUDGET_ACCOUNT' 
                WHEN 14 THEN 'REQ_ENCUMBRANCE_TYPE_ID' 
                WHEN 15 THEN 'TRANSFER_TO_GL_INDICATOR' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h3.ENCUMBRANCE_REVERSAL_FLAG)
                WHEN 2 THEN TO_CHAR(h4.APPLIED_TO_APPL_ID)
                WHEN 3 THEN TO_CHAR(h1.DISTRIBUTION_TYPE)
                WHEN 4 THEN TO_CHAR(h4.ENCUM_REVERSAL_AMOUNT_ENTERED)
                WHEN 5 THEN TO_CHAR(h4.ENCUMBRANCE_REVERSAL_AMOUNT)
                WHEN 6 THEN TO_CHAR(h7.CST_ENCUM_UPG_OPTION)
                WHEN 7 THEN TO_CHAR(h6.REQ_ENCUMBRANCE_FLAG)
                WHEN 8 THEN TO_CHAR(h5.REQ_RESERVED_FLAG)
                WHEN 9 THEN TO_CHAR(h4.BUS_FLOW_REQ_DIST_TYPE)
                WHEN 10 THEN TO_CHAR(h4.BUS_FLOW_REQ_ENTITY_CODE)
                WHEN 11 THEN TO_CHAR(h4.BUS_FLOW_REQ_DIST_ID)
                WHEN 12 THEN TO_CHAR(h4.BUS_FLOW_REQ_ID)
                WHEN 13 THEN TO_CHAR(h5.REQ_BUDGET_ACCOUNT)
                WHEN 14 THEN TO_CHAR(h6.REQ_ENCUMBRANCE_TYPE_ID)
                WHEN 15 THEN TO_CHAR(h1.TRANSFER_TO_GL_INDICATOR)
                
                ELSE null
              END                           source_value
            , CASE r
                WHEN 3 THEN fvl13.meaning
                WHEN 15 THEN fvl37.meaning
                
                ELSE null
              END               source_meaning
         FROM xla_events_gt     xet  
      , CST_XLA_INV_HEADERS_V  h1
      , CST_XLA_INV_ORG_PARAMS_REF_V  h3
      , CST_XLA_INV_REF_V  h4
      , PO_REQ_DISTS_REF_V  h5
      , PO_REQ_HEADERS_REF_V  h6
      , PSA_CST_XLA_UPG_V  h7
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
             ,(select rownum r from all_objects where rownum <= 15 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id
 AND h3.inv_organization_id  (+) = h1.organization_id AND h4.ref_transaction_id = h1.transaction_id AND h4.bus_flow_req_dist_id=h5.req_distribution_id (+)  AND h4.bus_flow_req_id = h6.req_id (+)  AND h4.rcv_transaction_id = h7.transaction_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of header sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--



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
            , l2.line_number                 line_number
            , CASE r
               WHEN 1 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 2 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 3 THEN 'CST_XLA_INV_LINES_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'LINE' 
                WHEN 2 THEN 'LINE' 
                WHEN 3 THEN 'LINE' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                WHEN 3 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'ACCOUNTING_LINE_TYPE_CODE' 
                WHEN 2 THEN 'DISTRIBUTION_IDENTIFIER' 
                WHEN 3 THEN 'CURRENCY_CODE' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(l2.ACCOUNTING_LINE_TYPE_CODE)
                WHEN 2 THEN TO_CHAR(l2.DISTRIBUTION_IDENTIFIER)
                WHEN 3 THEN TO_CHAR(l2.CURRENCY_CODE)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM  xla_events_gt     xet  
        , CST_XLA_INV_LINES_V  l2
            , (select rownum r from all_objects where rownum <= 3 and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_class_code = C_EVENT_CLASS_CODE
            AND l2.event_id          = xet.event_id

)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of line sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of insert_sources_14'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
      END IF;
      RAISE;
  WHEN OTHERS THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.insert_sources_14');
END insert_sources_14;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         EventClass_14
--
----------------------------------------
--
FUNCTION EventClass_14
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_target_ledger_id       IN NUMBER
       ,p_language               IN VARCHAR2
       ,p_currency_code          IN VARCHAR2
       ,p_sla_ledger_id          IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN BOOLEAN IS
--
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'FOB_RCPT_RECIPIENT_RCPT_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'FOB_RCPT_RECIPIENT_RCPT';

l_calculate_acctd_flag   VARCHAR2(1) :='N';
l_calculate_g_l_flag     VARCHAR2(1) :='N';
--
l_array_legal_entity_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_transaction_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_event_id                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_class_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_number                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_event_date                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_transaction_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_num_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_char_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_date_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_event_created_by               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V100L;
l_array_budgetary_control_flag         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_header_events                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added
l_array_duplicate_checker              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added

l_event_id                             NUMBER;
l_previous_event_id                    NUMBER;
l_first_event_id                       NUMBER;
l_last_event_id                        NUMBER;

l_rec_acct_attrs                       XLA_AE_HEADER_PKG.t_rec_acct_attrs;
l_rec_rev_acct_attrs                   XLA_AE_LINES_PKG.t_rec_acct_attrs;
--
--
l_result                    BOOLEAN := TRUE;
l_rows                      NUMBER  := 1000;
l_event_type_name           VARCHAR2(80) := 'All';
l_event_class_name          VARCHAR2(80) := 'Recipient-side Intransit Interorg Receipt for FOB Receipt';
l_description               VARCHAR2(4000);
l_transaction_reversal      NUMBER;
l_ae_header_id              NUMBER;
l_array_extract_line_num    xla_ae_journal_entry_pkg.t_array_Num;
l_log_module                VARCHAR2(240);
--
l_acct_reversal_source      VARCHAR2(30);
l_trx_reversal_source       VARCHAR2(30);

l_continue_with_lines       BOOLEAN := TRUE;
--
l_acc_rev_gl_date_source    DATE;                      -- 4262811
--
type t_array_event_id is table of number index by binary_integer;

l_rec_array_event                    t_rec_array_event;
l_null_rec_array_event               t_rec_array_event;
l_array_ae_header_id                 xla_number_array_type;
l_actual_flag                        VARCHAR2(1) := NULL;
l_actual_gain_loss_ref               VARCHAR2(30) := '#####';
l_balance_type_code                  VARCHAR2(1) :=NULL;
l_gain_or_loss_ref                   VARCHAR2(30) :=NULL;

--
TYPE t_array_lookup_meaning IS TABLE OF fnd_lookup_values.meaning%TYPE INDEX BY BINARY_INTEGER;
--

TYPE t_array_source_4 IS TABLE OF CST_XLA_INV_ORG_PARAMS_REF_V.ENCUMBRANCE_REVERSAL_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_7 IS TABLE OF CST_XLA_INV_REF_V.APPLIED_TO_APPL_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_13 IS TABLE OF CST_XLA_INV_HEADERS_V.DISTRIBUTION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_15 IS TABLE OF CST_XLA_INV_REF_V.ENCUM_REVERSAL_AMOUNT_ENTERED%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_17 IS TABLE OF CST_XLA_INV_REF_V.ENCUMBRANCE_REVERSAL_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_18 IS TABLE OF PSA_CST_XLA_UPG_V.CST_ENCUM_UPG_OPTION%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_28 IS TABLE OF PO_REQ_HEADERS_REF_V.REQ_ENCUMBRANCE_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_29 IS TABLE OF PO_REQ_DISTS_REF_V.REQ_RESERVED_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_30 IS TABLE OF CST_XLA_INV_REF_V.BUS_FLOW_REQ_DIST_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_31 IS TABLE OF CST_XLA_INV_REF_V.BUS_FLOW_REQ_ENTITY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_32 IS TABLE OF CST_XLA_INV_REF_V.BUS_FLOW_REQ_DIST_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_33 IS TABLE OF CST_XLA_INV_REF_V.BUS_FLOW_REQ_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_34 IS TABLE OF PO_REQ_DISTS_REF_V.REQ_BUDGET_ACCOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_35 IS TABLE OF PO_REQ_HEADERS_REF_V.REQ_ENCUMBRANCE_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_37 IS TABLE OF CST_XLA_INV_HEADERS_V.TRANSFER_TO_GL_INDICATOR%TYPE INDEX BY BINARY_INTEGER;

TYPE t_array_source_6 IS TABLE OF CST_XLA_INV_LINES_V.ACCOUNTING_LINE_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_12 IS TABLE OF CST_XLA_INV_LINES_V.DISTRIBUTION_IDENTIFIER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_16 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;

l_array_source_4              t_array_source_4;
l_array_source_7              t_array_source_7;
l_array_source_13              t_array_source_13;
l_array_source_13_meaning      t_array_lookup_meaning;
l_array_source_15              t_array_source_15;
l_array_source_17              t_array_source_17;
l_array_source_18              t_array_source_18;
l_array_source_28              t_array_source_28;
l_array_source_29              t_array_source_29;
l_array_source_30              t_array_source_30;
l_array_source_31              t_array_source_31;
l_array_source_32              t_array_source_32;
l_array_source_33              t_array_source_33;
l_array_source_34              t_array_source_34;
l_array_source_35              t_array_source_35;
l_array_source_37              t_array_source_37;
l_array_source_37_meaning      t_array_lookup_meaning;

l_array_source_6      t_array_source_6;
l_array_source_12      t_array_source_12;
l_array_source_16      t_array_source_16;

--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: FOB_RCPT_RECIPIENT_RCPT
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
  , h3.ENCUMBRANCE_REVERSAL_FLAG    source_4
  , h4.APPLIED_TO_APPL_ID    source_7
  , h1.DISTRIBUTION_TYPE    source_13
  , fvl13.meaning   source_13_meaning
  , h4.ENCUM_REVERSAL_AMOUNT_ENTERED    source_15
  , h4.ENCUMBRANCE_REVERSAL_AMOUNT    source_17
  , h7.CST_ENCUM_UPG_OPTION    source_18
  , h6.REQ_ENCUMBRANCE_FLAG    source_28
  , h5.REQ_RESERVED_FLAG    source_29
  , h4.BUS_FLOW_REQ_DIST_TYPE    source_30
  , h4.BUS_FLOW_REQ_ENTITY_CODE    source_31
  , h4.BUS_FLOW_REQ_DIST_ID    source_32
  , h4.BUS_FLOW_REQ_ID    source_33
  , h5.REQ_BUDGET_ACCOUNT    source_34
  , h6.REQ_ENCUMBRANCE_TYPE_ID    source_35
  , h1.TRANSFER_TO_GL_INDICATOR    source_37
  , fvl37.meaning   source_37_meaning
  FROM xla_events_gt     xet 
  , CST_XLA_INV_HEADERS_V  h1
  , CST_XLA_INV_ORG_PARAMS_REF_V  h3
  , CST_XLA_INV_REF_V  h4
  , PO_REQ_DISTS_REF_V  h5
  , PO_REQ_HEADERS_REF_V  h6
  , PSA_CST_XLA_UPG_V  h7
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id
 AND h3.INV_ORGANIZATION_ID  (+) = h1.ORGANIZATION_ID AND h4.ref_transaction_id = h1.transaction_id AND h4.BUS_FLOW_REQ_DIST_ID=h5.REQ_DISTRIBUTION_ID (+)  AND h4.BUS_FLOW_REQ_ID = h6.REQ_ID (+)  AND h4.rcv_transaction_id = h7.transaction_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: FOB_RCPT_RECIPIENT_RCPT
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
 , l2.LINE_NUMBER  
  , l2.ACCOUNTING_LINE_TYPE_CODE    source_6
  , l2.DISTRIBUTION_IDENTIFIER    source_12
  , l2.CURRENCY_CODE    source_16
  FROM xla_events_gt     xet 
  , CST_XLA_INV_LINES_V  l2
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'   AND l2.event_id      = xet.event_id
;

--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.EventClass_14';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of EventClass_14'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'p_application_id = '||p_application_id||
                     ' - p_base_ledger_id = '||p_base_ledger_id||
                     ' - p_target_ledger_id  = '||p_target_ledger_id||
                     ' - p_language = '||p_language||
                     ' - p_currency_code = '||p_currency_code||
                     ' - p_sla_ledger_id = '||p_sla_ledger_id
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
-- initialze arrays
--
g_array_event.DELETE;
l_rec_array_event := l_null_rec_array_event;
--
--------------------------------------
-- 4262811 Initialze MPA Line Number
--------------------------------------
XLA_AE_HEADER_PKG.g_mpa_line_num := 0;

--

--
OPEN header_cur;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
   (p_msg      => 'SQL - FETCH header_cur'
   ,p_level    => C_LEVEL_STATEMENT
   ,p_module   => l_log_module);
END IF;
--
LOOP
FETCH header_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag 
      , l_array_source_4
      , l_array_source_7
      , l_array_source_13
      , l_array_source_13_meaning
      , l_array_source_15
      , l_array_source_17
      , l_array_source_18
      , l_array_source_28
      , l_array_source_29
      , l_array_source_30
      , l_array_source_31
      , l_array_source_32
      , l_array_source_33
      , l_array_source_34
      , l_array_source_35
      , l_array_source_37
      , l_array_source_37_meaning
      LIMIT l_rows;
--
IF (C_LEVEL_EVENT >= g_log_level) THEN
   trace
   (p_msg      => '# rows extracted from header extract objects = '||TO_CHAR(header_cur%ROWCOUNT)
   ,p_level    => C_LEVEL_EVENT
   ,p_module   => l_log_module);
END IF;
--
EXIT WHEN l_array_entity_id.COUNT = 0;

-- initialize arrays
XLA_AE_HEADER_PKG.g_rec_header_new        := NULL;
XLA_AE_LINES_PKG.g_rec_lines              := NULL;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;


-- 4262811 - when creating Accrual Reversal or MPA, use g_last_hdr_idx to increment for next header id
g_last_hdr_idx := l_array_event_id.LAST;
--
-- loop for the headers. Each iteration is for each header extract row
-- fetched in header cursor
--
FOR hdr_idx IN l_array_event_id.FIRST .. l_array_event_id.LAST LOOP

--
-- set event info as cache for other routines to refer event attributes
--
XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
   (p_application_id           => p_application_id
   ,p_primary_ledger_id        => p_primary_ledger_id
   ,p_base_ledger_id           => p_base_ledger_id
   ,p_target_ledger_id         => p_target_ledger_id
   ,p_entity_id                => l_array_entity_id(hdr_idx)
   ,p_legal_entity_id          => l_array_legal_entity_id(hdr_idx)
   ,p_entity_code              => l_array_entity_code(hdr_idx)
   ,p_transaction_num          => l_array_transaction_num(hdr_idx)
   ,p_event_id                 => l_array_event_id(hdr_idx)
   ,p_event_class_code         => l_array_class_code(hdr_idx)
   ,p_event_type_code          => l_array_event_type(hdr_idx)
   ,p_event_number             => l_array_event_number(hdr_idx)
   ,p_event_date               => l_array_event_date(hdr_idx)
   ,p_transaction_date         => l_array_transaction_date(hdr_idx)
   ,p_reference_num_1          => l_array_reference_num_1(hdr_idx)
   ,p_reference_num_2          => l_array_reference_num_2(hdr_idx)
   ,p_reference_num_3          => l_array_reference_num_3(hdr_idx)
   ,p_reference_num_4          => l_array_reference_num_4(hdr_idx)
   ,p_reference_char_1         => l_array_reference_char_1(hdr_idx)
   ,p_reference_char_2         => l_array_reference_char_2(hdr_idx)
   ,p_reference_char_3         => l_array_reference_char_3(hdr_idx)
   ,p_reference_char_4         => l_array_reference_char_4(hdr_idx)
   ,p_reference_date_1         => l_array_reference_date_1(hdr_idx)
   ,p_reference_date_2         => l_array_reference_date_2(hdr_idx)
   ,p_reference_date_3         => l_array_reference_date_3(hdr_idx)
   ,p_reference_date_4         => l_array_reference_date_4(hdr_idx)
   ,p_event_created_by         => l_array_event_created_by(hdr_idx)
   ,p_budgetary_control_flag   => l_array_budgetary_control_flag(hdr_idx));

--
-- set the status of entry to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;

--
-- initialize a row for ae header
--
XLA_AE_HEADER_PKG.InitHeader(hdr_idx);

l_event_id := l_array_event_id(hdr_idx);

--
-- storing the hdr_idx for event. May be used by line cursor.
--
g_array_event(l_event_id).array_value_num('header_index') := hdr_idx;

--
-- store sources from header extract. This can be improved to
-- store only those sources from header extract that may be used in lines
--

g_array_event(l_event_id).array_value_char('source_4') := l_array_source_4(hdr_idx);
g_array_event(l_event_id).array_value_num('source_7') := l_array_source_7(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13') := l_array_source_13(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13_meaning') := l_array_source_13_meaning(hdr_idx);
g_array_event(l_event_id).array_value_num('source_15') := l_array_source_15(hdr_idx);
g_array_event(l_event_id).array_value_num('source_17') := l_array_source_17(hdr_idx);
g_array_event(l_event_id).array_value_char('source_18') := l_array_source_18(hdr_idx);
g_array_event(l_event_id).array_value_char('source_28') := l_array_source_28(hdr_idx);
g_array_event(l_event_id).array_value_char('source_29') := l_array_source_29(hdr_idx);
g_array_event(l_event_id).array_value_char('source_30') := l_array_source_30(hdr_idx);
g_array_event(l_event_id).array_value_char('source_31') := l_array_source_31(hdr_idx);
g_array_event(l_event_id).array_value_num('source_32') := l_array_source_32(hdr_idx);
g_array_event(l_event_id).array_value_num('source_33') := l_array_source_33(hdr_idx);
g_array_event(l_event_id).array_value_num('source_34') := l_array_source_34(hdr_idx);
g_array_event(l_event_id).array_value_num('source_35') := l_array_source_35(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37') := l_array_source_37(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37_meaning') := l_array_source_37_meaning(hdr_idx);

--
-- initilaize the status of ae headers for diffrent balance types
-- the status is initialised to C_NOT_CREATED (2)
--
--g_array_event(l_event_id).array_value_num('actual_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('budget_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('encumbrance_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;

--
-- call api to validate and store accounting attributes for header
--

------------------------------------------------------------
-- Accrual Reversal : to get date for Standard Source (NONE)
------------------------------------------------------------
l_acc_rev_gl_date_source := NULL;

     l_rec_acct_attrs.array_acct_attr_code(1)   := 'ENCUMBRANCE_TYPE_ID';
      l_rec_acct_attrs.array_num_value(1) := g_array_event(l_event_id).array_value_num('source_35');
     l_rec_acct_attrs.array_acct_attr_code(2)   := 'GL_DATE';
      l_rec_acct_attrs.array_date_value(2) := 
xla_ae_sources_pkg.GetSystemSourceDate(
   p_source_code           => 'XLA_REFERENCE_DATE_1'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
);
     l_rec_acct_attrs.array_acct_attr_code(3)   := 'GL_TRANSFER_FLAG';
      l_rec_acct_attrs.array_char_value(3) := g_array_event(l_event_id).array_value_char('source_37');


XLA_AE_HEADER_PKG.SetHdrAcctAttrs(l_rec_acct_attrs);

XLA_AE_HEADER_PKG.SetJeCategoryName;

XLA_AE_HEADER_PKG.g_rec_header_new.array_event_type_code(hdr_idx)  := l_array_event_type(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(hdr_idx)         := l_array_event_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_entity_id(hdr_idx)        := l_array_entity_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_number(hdr_idx)     := l_array_event_number(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_target_ledger_id(hdr_idx) := p_target_ledger_id;


-- No header level analytical criteria

--
--accounting attribute enhancement, bug 3612931
--
l_trx_reversal_source := SUBSTR(NULL, 1,30);

IF NVL(l_trx_reversal_source, 'N') NOT IN ('N','Y') THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name            => 'XLA'
      ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
      ,p_token_1                 => 'ACCT_ATTR_NAME'
      ,p_value_1                 => xla_ae_sources_pkg.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
      ,p_token_2                 => 'PRODUCT_NAME'
      ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
      ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
      ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
      ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

ELSIF NVL(l_trx_reversal_source, 'N') = 'Y' THEN
   --
   -- following sets the accounting attributes needed to reverse
   -- accounting for a distributeion
   --
   xla_ae_lines_pkg.SetTrxReversalAttrs
      (p_event_id              => l_event_id
      ,p_gl_date               => XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(hdr_idx)
      ,p_trx_reversal_source   => l_trx_reversal_source);

END IF;


----------------------------------------------------------------
-- 4262811 -  update the header statuses to invalid in need be
----------------------------------------------------------------
--
XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx => hdr_idx);


  -----------------------------------------------
  -- No accrual reversal for the event class/type
  -----------------------------------------------
----------------------------------------------------------------

--
-- this ends the header loop iteration for one bulk fetch
--
END LOOP;

l_first_event_id   := l_array_event_id(l_array_event_id.FIRST);
l_last_event_id    := l_array_event_id(l_array_event_id.LAST);

--
-- insert dummy rows into lines gt table that were created due to
-- transaction reversals
--
IF XLA_AE_LINES_PKG.g_rec_lines.array_ae_header_id.COUNT > 0 THEN
   l_result := XLA_AE_LINES_PKG.InsertLines;
END IF;

--
-- reset the temp_line_num for each set of events fetched from header
-- cursor rather than doing it for each new event in line cursor
-- Bug 3939231
--
xla_ae_lines_pkg.g_temp_line_num := 0;



--
OPEN line_cur(x_first_event_id  => l_first_event_id, x_last_event_id  => l_last_event_id);
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - FETCH line_cur'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
LOOP
  --
  FETCH line_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag
      , l_array_extract_line_num 
      , l_array_source_6
      , l_array_source_12
      , l_array_source_16
      LIMIT l_rows;

  --
  IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => '# rows extracted from line extract objects = '||TO_CHAR(line_cur%ROWCOUNT)
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
  END IF;
  --
  EXIT WHEN l_array_entity_id.count = 0;

  XLA_AE_LINES_PKG.g_rec_lines := null;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;
--
--

FOR Idx IN 1..l_array_event_id.count LOOP
   --
   -- 5648433 (move l_event_id out of IF statement)  set l_event_id to be used inside IF condition
   --
   l_event_id := l_array_event_id(idx);  -- 5648433

   --
   -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
   --

   IF NVL(xla_ae_header_pkg.g_rec_header_new.array_trx_acct_reversal_option
             (g_array_event(l_event_id).array_value_num('header_index'))
         ,'N'
         ) <> 'Y'
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is not Y '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

--
-- set the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
--
-- set event info as cache for other routines to refer event attributes
--

IF l_event_id <> NVL(l_previous_event_id, -1) THEN
   l_previous_event_id := l_event_id;

   XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
      (p_application_id           => p_application_id
      ,p_primary_ledger_id        => p_primary_ledger_id
      ,p_base_ledger_id           => p_base_ledger_id
      ,p_target_ledger_id         => p_target_ledger_id
      ,p_entity_id                => l_array_entity_id(Idx)
      ,p_legal_entity_id          => l_array_legal_entity_id(Idx)
      ,p_entity_code              => l_array_entity_code(Idx)
      ,p_transaction_num          => l_array_transaction_num(Idx)
      ,p_event_id                 => l_array_event_id(Idx)
      ,p_event_class_code         => l_array_class_code(Idx)
      ,p_event_type_code          => l_array_event_type(Idx)
      ,p_event_number             => l_array_event_number(Idx)
      ,p_event_date               => l_array_event_date(Idx)
      ,p_transaction_date         => l_array_transaction_date(Idx)
      ,p_reference_num_1          => l_array_reference_num_1(Idx)
      ,p_reference_num_2          => l_array_reference_num_2(Idx)
      ,p_reference_num_3          => l_array_reference_num_3(Idx)
      ,p_reference_num_4          => l_array_reference_num_4(Idx)
      ,p_reference_char_1         => l_array_reference_char_1(Idx)
      ,p_reference_char_2         => l_array_reference_char_2(Idx)
      ,p_reference_char_3         => l_array_reference_char_3(Idx)
      ,p_reference_char_4         => l_array_reference_char_4(Idx)
      ,p_reference_date_1         => l_array_reference_date_1(Idx)
      ,p_reference_date_2         => l_array_reference_date_2(Idx)
      ,p_reference_date_3         => l_array_reference_date_3(Idx)
      ,p_reference_date_4         => l_array_reference_date_4(Idx)
      ,p_event_created_by         => l_array_event_created_by(Idx)
      ,p_budgetary_control_flag   => l_array_budgetary_control_flag(Idx));
       --
END IF;



--
xla_ae_lines_pkg.SetExtractLine(p_extract_line => l_array_extract_line_num(Idx));

l_acct_reversal_source := SUBSTR(NULL, 1,30);

IF l_continue_with_lines THEN
   IF NVL(l_acct_reversal_source, 'N') NOT IN ('N','Y','B') THEN
      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_INVALID_REVERSAL_OPTION'
         ,p_token_1                 => 'LINE_NUMBER'
         ,p_value_1                 => l_array_extract_line_num(Idx)
         ,p_token_2                 => 'PRODUCT_NAME'
         ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
         ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
         ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

   ELSIF NVL(l_acct_reversal_source, 'N') IN ('Y','B') THEN
      --
      -- following sets the accounting attributes needed to reverse
      -- accounting for a distributeion
      --

      --
      -- 5217187
      --
      l_rec_rev_acct_attrs.array_acct_attr_code(1):= 'GL_DATE';
      l_rec_rev_acct_attrs.array_date_value(1) := XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(
                                       g_array_event(l_event_id).array_value_num('header_index'));
      --
      --

      -- No reversal code generated

      xla_ae_lines_pkg.SetAcctReversalAttrs
         (p_event_id             => l_event_id
         ,p_rec_acct_attrs       => l_rec_rev_acct_attrs
         ,p_calculate_acctd_flag => l_calculate_acctd_flag
         ,p_calculate_g_l_flag   => l_calculate_g_l_flag);
   END IF;

   IF NVL(l_acct_reversal_source, 'N') IN ('N','B') THEN
       l_actual_flag := NULL;  l_actual_gain_loss_ref := '#####';

--
AcctLineType_10 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_4 => g_array_event(l_event_id).array_value_char('source_4')
 , p_source_6 => l_array_source_6(Idx)
 , p_source_7 => g_array_event(l_event_id).array_value_num('source_7')
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_15 => g_array_event(l_event_id).array_value_num('source_15')
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => g_array_event(l_event_id).array_value_num('source_17')
 , p_source_18 => g_array_event(l_event_id).array_value_char('source_18')
 , p_source_28 => g_array_event(l_event_id).array_value_char('source_28')
 , p_source_29 => g_array_event(l_event_id).array_value_char('source_29')
 , p_source_30 => g_array_event(l_event_id).array_value_char('source_30')
 , p_source_31 => g_array_event(l_event_id).array_value_char('source_31')
 , p_source_32 => g_array_event(l_event_id).array_value_num('source_32')
 , p_source_33 => g_array_event(l_event_id).array_value_num('source_33')
 , p_source_34 => g_array_event(l_event_id).array_value_num('source_34')
 , p_source_35 => g_array_event(l_event_id).array_value_num('source_35')
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--

      -- only execute it if calculate g/l flag is yes, and primary or secondary ledger
      -- or secondary ledger that has different currency with primary
      -- or alc that is calculated by sla
      IF (((l_calculate_g_l_flag = 'Y' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> 'ALC') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in ('ALC', 'SECONDARY') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='Y'))

--      IF((l_calculate_g_l_flag='Y' or XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id <>
--                    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id)
          AND (l_actual_flag = 'A')) THEN
        XLA_AE_LINES_PKG.CreateGainOrLossLines(
          p_event_id         => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_application_id   => p_application_id
         ,p_amb_context_code => 'DEFAULT'
         ,p_entity_code      => xla_ae_journal_entry_pkg.g_cache_event.entity_code
         ,p_event_class_code => C_EVENT_CLASS_CODE
         ,p_event_type_code  => C_EVENT_TYPE_CODE
         
         ,p_gain_ccid        => -1
         ,p_loss_ccid        => -1

         ,p_actual_flag      => l_actual_flag
         ,p_enc_flag         => null
         ,p_actual_g_l_ref   => l_actual_gain_loss_ref
         ,p_enc_g_l_ref      => null
         );
      END IF;
   END IF;
END IF;

   ELSE
      --
      -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is Y'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

END LOOP;
l_result := XLA_AE_LINES_PKG.InsertLines ;
end loop;
close line_cur;


--
-- insert headers into xla_ae_headers_gt table
--
l_result := XLA_AE_HEADER_PKG.InsertHeaders ;

-- insert into errors table here.

END LOOP;

--
-- 4865292
--
-- Compare g_hdr_extract_count with event count in
-- CreateHeadersAndLines.
--
g_hdr_extract_count := g_hdr_extract_count + header_cur%ROWCOUNT;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace (p_msg     => '# rows extracted from header extract objects '
                    || ' (running total): '
                    || g_hdr_extract_count
         ,p_level   => C_LEVEL_STATEMENT
         ,p_module  => l_log_module);
END IF;

CLOSE header_cur;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of EventClass_14'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   
IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;

   
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

   RAISE;

WHEN NO_DATA_FOUND THEN

IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

FOR header_record IN header_cur
LOOP
    l_array_header_events(header_record.event_id) := header_record.event_id;
END LOOP;

l_first_event_id := l_array_header_events(l_array_header_events.FIRST);
l_last_event_id := l_array_header_events(l_array_header_events.LAST);

fnd_file.put_line(fnd_file.LOG, '                    ');
fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, 'EVENT CLASS CODE = ' || C_EVENT_CLASS_CODE );
fnd_file.put_line(fnd_file.LOG, 'The following events are present in the line extract but MISSING in the header extract: ');

FOR line_record IN line_cur(l_first_event_id, l_last_event_id)
LOOP
	IF (NOT l_array_header_events.EXISTS(line_record.event_id))  AND (NOT l_array_duplicate_checker.EXISTS(line_record.event_id)) THEN
	fnd_file.put_line(fnd_file.log, 'Event_id = ' || line_record.event_id);
        l_array_duplicate_checker(line_record.event_id) := line_record.event_id;
	END IF;
END LOOP;

fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, '                    ');


xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_14');


WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_14');
END EventClass_14;
--

---------------------------------------
--
-- PRIVATE PROCEDURE
--         insert_sources_15
--
----------------------------------------
--
PROCEDURE insert_sources_15(
                                p_target_ledger_id       IN NUMBER
                              , p_language               IN VARCHAR2
                              , p_sla_ledger_id          IN NUMBER
                              , p_pad_start_date         IN DATE
                              , p_pad_end_date           IN DATE
                         )
IS

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'FOB_SHIP_SENDER_SHIP_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'FOB_SHIP_SENDER_SHIP';
p_apps_owner                   VARCHAR2(30);
l_log_module                   VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_sources_15';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of insert_sources_15'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- select APPS owner
SELECT oracle_username
  INTO p_apps_owner
  FROM fnd_oracle_userid
 WHERE read_only_flag = 'U'
;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_target_ledger_id = '||p_target_ledger_id||
                        ' - p_language = '||p_language||
                        ' - p_sla_ledger_id  = '||p_sla_ledger_id ||
                        ' - p_pad_start_date = '||TO_CHAR(p_pad_start_date)||
                        ' - p_pad_end_date = '||TO_CHAR(p_pad_end_date)||
                        ' - p_apps_owner = '||TO_CHAR(p_apps_owner)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


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
               WHEN 1 THEN 'CST_XLA_INV_HEADERS_V' 
                WHEN 2 THEN 'CST_XLA_INV_HEADERS_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                WHEN 2 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'DISTRIBUTION_TYPE' 
                WHEN 2 THEN 'TRANSFER_TO_GL_INDICATOR' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h1.DISTRIBUTION_TYPE)
                WHEN 2 THEN TO_CHAR(h1.TRANSFER_TO_GL_INDICATOR)
                
                ELSE null
              END                           source_value
            , CASE r
                WHEN 1 THEN fvl13.meaning
                WHEN 2 THEN fvl37.meaning
                
                ELSE null
              END               source_meaning
         FROM xla_events_gt     xet  
      , CST_XLA_INV_HEADERS_V  h1
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
             ,(select rownum r from all_objects where rownum <= 2 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id
   AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of header sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--



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
            , l2.line_number                 line_number
            , CASE r
               WHEN 1 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 2 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 3 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 4 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 5 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 6 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 7 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 8 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 9 THEN 'CST_XLA_INV_LINES_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'LINE' 
                WHEN 2 THEN 'LINE' 
                WHEN 3 THEN 'LINE' 
                WHEN 4 THEN 'LINE' 
                WHEN 5 THEN 'LINE' 
                WHEN 6 THEN 'LINE' 
                WHEN 7 THEN 'LINE' 
                WHEN 8 THEN 'LINE' 
                WHEN 9 THEN 'LINE' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                WHEN 3 THEN '707' 
                WHEN 4 THEN '707' 
                WHEN 5 THEN '707' 
                WHEN 6 THEN '707' 
                WHEN 7 THEN '707' 
                WHEN 8 THEN '707' 
                WHEN 9 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'CODE_COMBINATION_ID' 
                WHEN 2 THEN 'ACCOUNTING_LINE_TYPE_CODE' 
                WHEN 3 THEN 'DISTRIBUTION_IDENTIFIER' 
                WHEN 4 THEN 'CURRENCY_CODE' 
                WHEN 5 THEN 'ENTERED_AMOUNT' 
                WHEN 6 THEN 'CURRENCY_CONVERSION_DATE' 
                WHEN 7 THEN 'CURRENCY_CONVERSION_RATE' 
                WHEN 8 THEN 'CURRENCY_CONVERSION_TYPE' 
                WHEN 9 THEN 'ACCOUNTED_AMOUNT' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(l2.CODE_COMBINATION_ID)
                WHEN 2 THEN TO_CHAR(l2.ACCOUNTING_LINE_TYPE_CODE)
                WHEN 3 THEN TO_CHAR(l2.DISTRIBUTION_IDENTIFIER)
                WHEN 4 THEN TO_CHAR(l2.CURRENCY_CODE)
                WHEN 5 THEN TO_CHAR(l2.ENTERED_AMOUNT)
                WHEN 6 THEN TO_CHAR(l2.CURRENCY_CONVERSION_DATE)
                WHEN 7 THEN TO_CHAR(l2.CURRENCY_CONVERSION_RATE)
                WHEN 8 THEN TO_CHAR(l2.CURRENCY_CONVERSION_TYPE)
                WHEN 9 THEN TO_CHAR(l2.ACCOUNTED_AMOUNT)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM  xla_events_gt     xet  
        , CST_XLA_INV_LINES_V  l2
            , (select rownum r from all_objects where rownum <= 9 and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_class_code = C_EVENT_CLASS_CODE
            AND l2.event_id          = xet.event_id

)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of line sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of insert_sources_15'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
      END IF;
      RAISE;
  WHEN OTHERS THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.insert_sources_15');
END insert_sources_15;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         EventClass_15
--
----------------------------------------
--
FUNCTION EventClass_15
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_target_ledger_id       IN NUMBER
       ,p_language               IN VARCHAR2
       ,p_currency_code          IN VARCHAR2
       ,p_sla_ledger_id          IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN BOOLEAN IS
--
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'FOB_SHIP_SENDER_SHIP_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'FOB_SHIP_SENDER_SHIP';

l_calculate_acctd_flag   VARCHAR2(1) :='N';
l_calculate_g_l_flag     VARCHAR2(1) :='N';
--
l_array_legal_entity_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_transaction_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_event_id                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_class_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_number                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_event_date                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_transaction_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_num_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_char_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_date_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_event_created_by               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V100L;
l_array_budgetary_control_flag         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_header_events                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added
l_array_duplicate_checker              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added

l_event_id                             NUMBER;
l_previous_event_id                    NUMBER;
l_first_event_id                       NUMBER;
l_last_event_id                        NUMBER;

l_rec_acct_attrs                       XLA_AE_HEADER_PKG.t_rec_acct_attrs;
l_rec_rev_acct_attrs                   XLA_AE_LINES_PKG.t_rec_acct_attrs;
--
--
l_result                    BOOLEAN := TRUE;
l_rows                      NUMBER  := 1000;
l_event_type_name           VARCHAR2(80) := 'All';
l_event_class_name          VARCHAR2(80) := 'Sender-side Intransit Interorg Shipment for FOB Shipment';
l_description               VARCHAR2(4000);
l_transaction_reversal      NUMBER;
l_ae_header_id              NUMBER;
l_array_extract_line_num    xla_ae_journal_entry_pkg.t_array_Num;
l_log_module                VARCHAR2(240);
--
l_acct_reversal_source      VARCHAR2(30);
l_trx_reversal_source       VARCHAR2(30);

l_continue_with_lines       BOOLEAN := TRUE;
--
l_acc_rev_gl_date_source    DATE;                      -- 4262811
--
type t_array_event_id is table of number index by binary_integer;

l_rec_array_event                    t_rec_array_event;
l_null_rec_array_event               t_rec_array_event;
l_array_ae_header_id                 xla_number_array_type;
l_actual_flag                        VARCHAR2(1) := NULL;
l_actual_gain_loss_ref               VARCHAR2(30) := '#####';
l_balance_type_code                  VARCHAR2(1) :=NULL;
l_gain_or_loss_ref                   VARCHAR2(30) :=NULL;

--
TYPE t_array_lookup_meaning IS TABLE OF fnd_lookup_values.meaning%TYPE INDEX BY BINARY_INTEGER;
--

TYPE t_array_source_13 IS TABLE OF CST_XLA_INV_HEADERS_V.DISTRIBUTION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_37 IS TABLE OF CST_XLA_INV_HEADERS_V.TRANSFER_TO_GL_INDICATOR%TYPE INDEX BY BINARY_INTEGER;

TYPE t_array_source_1 IS TABLE OF CST_XLA_INV_LINES_V.CODE_COMBINATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_6 IS TABLE OF CST_XLA_INV_LINES_V.ACCOUNTING_LINE_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_12 IS TABLE OF CST_XLA_INV_LINES_V.DISTRIBUTION_IDENTIFIER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_16 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_20 IS TABLE OF CST_XLA_INV_LINES_V.ENTERED_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_21 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CONVERSION_DATE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_22 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CONVERSION_RATE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_23 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CONVERSION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_24 IS TABLE OF CST_XLA_INV_LINES_V.ACCOUNTED_AMOUNT%TYPE INDEX BY BINARY_INTEGER;

l_array_source_13              t_array_source_13;
l_array_source_13_meaning      t_array_lookup_meaning;
l_array_source_37              t_array_source_37;
l_array_source_37_meaning      t_array_lookup_meaning;

l_array_source_1      t_array_source_1;
l_array_source_6      t_array_source_6;
l_array_source_12      t_array_source_12;
l_array_source_16      t_array_source_16;
l_array_source_20      t_array_source_20;
l_array_source_21      t_array_source_21;
l_array_source_22      t_array_source_22;
l_array_source_23      t_array_source_23;
l_array_source_24      t_array_source_24;

--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: FOB_SHIP_SENDER_SHIP
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
  , h1.DISTRIBUTION_TYPE    source_13
  , fvl13.meaning   source_13_meaning
  , h1.TRANSFER_TO_GL_INDICATOR    source_37
  , fvl37.meaning   source_37_meaning
  FROM xla_events_gt     xet 
  , CST_XLA_INV_HEADERS_V  h1
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id
   AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: FOB_SHIP_SENDER_SHIP
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
 , l2.LINE_NUMBER  
  , l2.CODE_COMBINATION_ID    source_1
  , l2.ACCOUNTING_LINE_TYPE_CODE    source_6
  , l2.DISTRIBUTION_IDENTIFIER    source_12
  , l2.CURRENCY_CODE    source_16
  , l2.ENTERED_AMOUNT    source_20
  , l2.CURRENCY_CONVERSION_DATE    source_21
  , l2.CURRENCY_CONVERSION_RATE    source_22
  , l2.CURRENCY_CONVERSION_TYPE    source_23
  , l2.ACCOUNTED_AMOUNT    source_24
  FROM xla_events_gt     xet 
  , CST_XLA_INV_LINES_V  l2
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'   AND l2.event_id      = xet.event_id
;

--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.EventClass_15';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of EventClass_15'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'p_application_id = '||p_application_id||
                     ' - p_base_ledger_id = '||p_base_ledger_id||
                     ' - p_target_ledger_id  = '||p_target_ledger_id||
                     ' - p_language = '||p_language||
                     ' - p_currency_code = '||p_currency_code||
                     ' - p_sla_ledger_id = '||p_sla_ledger_id
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
-- initialze arrays
--
g_array_event.DELETE;
l_rec_array_event := l_null_rec_array_event;
--
--------------------------------------
-- 4262811 Initialze MPA Line Number
--------------------------------------
XLA_AE_HEADER_PKG.g_mpa_line_num := 0;

--

--
OPEN header_cur;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
   (p_msg      => 'SQL - FETCH header_cur'
   ,p_level    => C_LEVEL_STATEMENT
   ,p_module   => l_log_module);
END IF;
--
LOOP
FETCH header_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag 
      , l_array_source_13
      , l_array_source_13_meaning
      , l_array_source_37
      , l_array_source_37_meaning
      LIMIT l_rows;
--
IF (C_LEVEL_EVENT >= g_log_level) THEN
   trace
   (p_msg      => '# rows extracted from header extract objects = '||TO_CHAR(header_cur%ROWCOUNT)
   ,p_level    => C_LEVEL_EVENT
   ,p_module   => l_log_module);
END IF;
--
EXIT WHEN l_array_entity_id.COUNT = 0;

-- initialize arrays
XLA_AE_HEADER_PKG.g_rec_header_new        := NULL;
XLA_AE_LINES_PKG.g_rec_lines              := NULL;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;


-- 4262811 - when creating Accrual Reversal or MPA, use g_last_hdr_idx to increment for next header id
g_last_hdr_idx := l_array_event_id.LAST;
--
-- loop for the headers. Each iteration is for each header extract row
-- fetched in header cursor
--
FOR hdr_idx IN l_array_event_id.FIRST .. l_array_event_id.LAST LOOP

--
-- set event info as cache for other routines to refer event attributes
--
XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
   (p_application_id           => p_application_id
   ,p_primary_ledger_id        => p_primary_ledger_id
   ,p_base_ledger_id           => p_base_ledger_id
   ,p_target_ledger_id         => p_target_ledger_id
   ,p_entity_id                => l_array_entity_id(hdr_idx)
   ,p_legal_entity_id          => l_array_legal_entity_id(hdr_idx)
   ,p_entity_code              => l_array_entity_code(hdr_idx)
   ,p_transaction_num          => l_array_transaction_num(hdr_idx)
   ,p_event_id                 => l_array_event_id(hdr_idx)
   ,p_event_class_code         => l_array_class_code(hdr_idx)
   ,p_event_type_code          => l_array_event_type(hdr_idx)
   ,p_event_number             => l_array_event_number(hdr_idx)
   ,p_event_date               => l_array_event_date(hdr_idx)
   ,p_transaction_date         => l_array_transaction_date(hdr_idx)
   ,p_reference_num_1          => l_array_reference_num_1(hdr_idx)
   ,p_reference_num_2          => l_array_reference_num_2(hdr_idx)
   ,p_reference_num_3          => l_array_reference_num_3(hdr_idx)
   ,p_reference_num_4          => l_array_reference_num_4(hdr_idx)
   ,p_reference_char_1         => l_array_reference_char_1(hdr_idx)
   ,p_reference_char_2         => l_array_reference_char_2(hdr_idx)
   ,p_reference_char_3         => l_array_reference_char_3(hdr_idx)
   ,p_reference_char_4         => l_array_reference_char_4(hdr_idx)
   ,p_reference_date_1         => l_array_reference_date_1(hdr_idx)
   ,p_reference_date_2         => l_array_reference_date_2(hdr_idx)
   ,p_reference_date_3         => l_array_reference_date_3(hdr_idx)
   ,p_reference_date_4         => l_array_reference_date_4(hdr_idx)
   ,p_event_created_by         => l_array_event_created_by(hdr_idx)
   ,p_budgetary_control_flag   => l_array_budgetary_control_flag(hdr_idx));

--
-- set the status of entry to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;

--
-- initialize a row for ae header
--
XLA_AE_HEADER_PKG.InitHeader(hdr_idx);

l_event_id := l_array_event_id(hdr_idx);

--
-- storing the hdr_idx for event. May be used by line cursor.
--
g_array_event(l_event_id).array_value_num('header_index') := hdr_idx;

--
-- store sources from header extract. This can be improved to
-- store only those sources from header extract that may be used in lines
--

g_array_event(l_event_id).array_value_char('source_13') := l_array_source_13(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13_meaning') := l_array_source_13_meaning(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37') := l_array_source_37(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37_meaning') := l_array_source_37_meaning(hdr_idx);

--
-- initilaize the status of ae headers for diffrent balance types
-- the status is initialised to C_NOT_CREATED (2)
--
--g_array_event(l_event_id).array_value_num('actual_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('budget_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('encumbrance_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;

--
-- call api to validate and store accounting attributes for header
--

------------------------------------------------------------
-- Accrual Reversal : to get date for Standard Source (NONE)
------------------------------------------------------------
l_acc_rev_gl_date_source := NULL;

     l_rec_acct_attrs.array_acct_attr_code(1)   := 'GL_DATE';
      l_rec_acct_attrs.array_date_value(1) := 
xla_ae_sources_pkg.GetSystemSourceDate(
   p_source_code           => 'XLA_REFERENCE_DATE_1'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
);
     l_rec_acct_attrs.array_acct_attr_code(2)   := 'GL_TRANSFER_FLAG';
      l_rec_acct_attrs.array_char_value(2) := g_array_event(l_event_id).array_value_char('source_37');


XLA_AE_HEADER_PKG.SetHdrAcctAttrs(l_rec_acct_attrs);

XLA_AE_HEADER_PKG.SetJeCategoryName;

XLA_AE_HEADER_PKG.g_rec_header_new.array_event_type_code(hdr_idx)  := l_array_event_type(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(hdr_idx)         := l_array_event_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_entity_id(hdr_idx)        := l_array_entity_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_number(hdr_idx)     := l_array_event_number(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_target_ledger_id(hdr_idx) := p_target_ledger_id;


-- No header level analytical criteria

--
--accounting attribute enhancement, bug 3612931
--
l_trx_reversal_source := SUBSTR(NULL, 1,30);

IF NVL(l_trx_reversal_source, 'N') NOT IN ('N','Y') THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name            => 'XLA'
      ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
      ,p_token_1                 => 'ACCT_ATTR_NAME'
      ,p_value_1                 => xla_ae_sources_pkg.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
      ,p_token_2                 => 'PRODUCT_NAME'
      ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
      ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
      ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
      ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

ELSIF NVL(l_trx_reversal_source, 'N') = 'Y' THEN
   --
   -- following sets the accounting attributes needed to reverse
   -- accounting for a distributeion
   --
   xla_ae_lines_pkg.SetTrxReversalAttrs
      (p_event_id              => l_event_id
      ,p_gl_date               => XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(hdr_idx)
      ,p_trx_reversal_source   => l_trx_reversal_source);

END IF;


----------------------------------------------------------------
-- 4262811 -  update the header statuses to invalid in need be
----------------------------------------------------------------
--
XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx => hdr_idx);


  -----------------------------------------------
  -- No accrual reversal for the event class/type
  -----------------------------------------------
----------------------------------------------------------------

--
-- this ends the header loop iteration for one bulk fetch
--
END LOOP;

l_first_event_id   := l_array_event_id(l_array_event_id.FIRST);
l_last_event_id    := l_array_event_id(l_array_event_id.LAST);

--
-- insert dummy rows into lines gt table that were created due to
-- transaction reversals
--
IF XLA_AE_LINES_PKG.g_rec_lines.array_ae_header_id.COUNT > 0 THEN
   l_result := XLA_AE_LINES_PKG.InsertLines;
END IF;

--
-- reset the temp_line_num for each set of events fetched from header
-- cursor rather than doing it for each new event in line cursor
-- Bug 3939231
--
xla_ae_lines_pkg.g_temp_line_num := 0;



--
OPEN line_cur(x_first_event_id  => l_first_event_id, x_last_event_id  => l_last_event_id);
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - FETCH line_cur'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
LOOP
  --
  FETCH line_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag
      , l_array_extract_line_num 
      , l_array_source_1
      , l_array_source_6
      , l_array_source_12
      , l_array_source_16
      , l_array_source_20
      , l_array_source_21
      , l_array_source_22
      , l_array_source_23
      , l_array_source_24
      LIMIT l_rows;

  --
  IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => '# rows extracted from line extract objects = '||TO_CHAR(line_cur%ROWCOUNT)
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
  END IF;
  --
  EXIT WHEN l_array_entity_id.count = 0;

  XLA_AE_LINES_PKG.g_rec_lines := null;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;
--
--

FOR Idx IN 1..l_array_event_id.count LOOP
   --
   -- 5648433 (move l_event_id out of IF statement)  set l_event_id to be used inside IF condition
   --
   l_event_id := l_array_event_id(idx);  -- 5648433

   --
   -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
   --

   IF NVL(xla_ae_header_pkg.g_rec_header_new.array_trx_acct_reversal_option
             (g_array_event(l_event_id).array_value_num('header_index'))
         ,'N'
         ) <> 'Y'
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is not Y '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

--
-- set the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
--
-- set event info as cache for other routines to refer event attributes
--

IF l_event_id <> NVL(l_previous_event_id, -1) THEN
   l_previous_event_id := l_event_id;

   XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
      (p_application_id           => p_application_id
      ,p_primary_ledger_id        => p_primary_ledger_id
      ,p_base_ledger_id           => p_base_ledger_id
      ,p_target_ledger_id         => p_target_ledger_id
      ,p_entity_id                => l_array_entity_id(Idx)
      ,p_legal_entity_id          => l_array_legal_entity_id(Idx)
      ,p_entity_code              => l_array_entity_code(Idx)
      ,p_transaction_num          => l_array_transaction_num(Idx)
      ,p_event_id                 => l_array_event_id(Idx)
      ,p_event_class_code         => l_array_class_code(Idx)
      ,p_event_type_code          => l_array_event_type(Idx)
      ,p_event_number             => l_array_event_number(Idx)
      ,p_event_date               => l_array_event_date(Idx)
      ,p_transaction_date         => l_array_transaction_date(Idx)
      ,p_reference_num_1          => l_array_reference_num_1(Idx)
      ,p_reference_num_2          => l_array_reference_num_2(Idx)
      ,p_reference_num_3          => l_array_reference_num_3(Idx)
      ,p_reference_num_4          => l_array_reference_num_4(Idx)
      ,p_reference_char_1         => l_array_reference_char_1(Idx)
      ,p_reference_char_2         => l_array_reference_char_2(Idx)
      ,p_reference_char_3         => l_array_reference_char_3(Idx)
      ,p_reference_char_4         => l_array_reference_char_4(Idx)
      ,p_reference_date_1         => l_array_reference_date_1(Idx)
      ,p_reference_date_2         => l_array_reference_date_2(Idx)
      ,p_reference_date_3         => l_array_reference_date_3(Idx)
      ,p_reference_date_4         => l_array_reference_date_4(Idx)
      ,p_event_created_by         => l_array_event_created_by(Idx)
      ,p_budgetary_control_flag   => l_array_budgetary_control_flag(Idx));
       --
END IF;



--
xla_ae_lines_pkg.SetExtractLine(p_extract_line => l_array_extract_line_num(Idx));

l_acct_reversal_source := SUBSTR(NULL, 1,30);

IF l_continue_with_lines THEN
   IF NVL(l_acct_reversal_source, 'N') NOT IN ('N','Y','B') THEN
      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_INVALID_REVERSAL_OPTION'
         ,p_token_1                 => 'LINE_NUMBER'
         ,p_value_1                 => l_array_extract_line_num(Idx)
         ,p_token_2                 => 'PRODUCT_NAME'
         ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
         ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
         ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

   ELSIF NVL(l_acct_reversal_source, 'N') IN ('Y','B') THEN
      --
      -- following sets the accounting attributes needed to reverse
      -- accounting for a distributeion
      --

      --
      -- 5217187
      --
      l_rec_rev_acct_attrs.array_acct_attr_code(1):= 'GL_DATE';
      l_rec_rev_acct_attrs.array_date_value(1) := XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(
                                       g_array_event(l_event_id).array_value_num('header_index'));
      --
      --

      -- No reversal code generated

      xla_ae_lines_pkg.SetAcctReversalAttrs
         (p_event_id             => l_event_id
         ,p_rec_acct_attrs       => l_rec_rev_acct_attrs
         ,p_calculate_acctd_flag => l_calculate_acctd_flag
         ,p_calculate_g_l_flag   => l_calculate_g_l_flag);
   END IF;

   IF NVL(l_acct_reversal_source, 'N') IN ('N','B') THEN
       l_actual_flag := NULL;  l_actual_gain_loss_ref := '#####';

--
AcctLineType_11 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_1 => l_array_source_1(Idx)
 , p_source_6 => l_array_source_6(Idx)
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_16 => l_array_source_16(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_21 => l_array_source_21(Idx)
 , p_source_22 => l_array_source_22(Idx)
 , p_source_23 => l_array_source_23(Idx)
 , p_source_24 => l_array_source_24(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--

      -- only execute it if calculate g/l flag is yes, and primary or secondary ledger
      -- or secondary ledger that has different currency with primary
      -- or alc that is calculated by sla
      IF (((l_calculate_g_l_flag = 'Y' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> 'ALC') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in ('ALC', 'SECONDARY') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='Y'))

--      IF((l_calculate_g_l_flag='Y' or XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id <>
--                    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id)
          AND (l_actual_flag = 'A')) THEN
        XLA_AE_LINES_PKG.CreateGainOrLossLines(
          p_event_id         => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_application_id   => p_application_id
         ,p_amb_context_code => 'DEFAULT'
         ,p_entity_code      => xla_ae_journal_entry_pkg.g_cache_event.entity_code
         ,p_event_class_code => C_EVENT_CLASS_CODE
         ,p_event_type_code  => C_EVENT_TYPE_CODE
         
         ,p_gain_ccid        => -1
         ,p_loss_ccid        => -1

         ,p_actual_flag      => l_actual_flag
         ,p_enc_flag         => null
         ,p_actual_g_l_ref   => l_actual_gain_loss_ref
         ,p_enc_g_l_ref      => null
         );
      END IF;
   END IF;
END IF;

   ELSE
      --
      -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is Y'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

END LOOP;
l_result := XLA_AE_LINES_PKG.InsertLines ;
end loop;
close line_cur;


--
-- insert headers into xla_ae_headers_gt table
--
l_result := XLA_AE_HEADER_PKG.InsertHeaders ;

-- insert into errors table here.

END LOOP;

--
-- 4865292
--
-- Compare g_hdr_extract_count with event count in
-- CreateHeadersAndLines.
--
g_hdr_extract_count := g_hdr_extract_count + header_cur%ROWCOUNT;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace (p_msg     => '# rows extracted from header extract objects '
                    || ' (running total): '
                    || g_hdr_extract_count
         ,p_level   => C_LEVEL_STATEMENT
         ,p_module  => l_log_module);
END IF;

CLOSE header_cur;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of EventClass_15'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   
IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;

   
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

   RAISE;

WHEN NO_DATA_FOUND THEN

IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

FOR header_record IN header_cur
LOOP
    l_array_header_events(header_record.event_id) := header_record.event_id;
END LOOP;

l_first_event_id := l_array_header_events(l_array_header_events.FIRST);
l_last_event_id := l_array_header_events(l_array_header_events.LAST);

fnd_file.put_line(fnd_file.LOG, '                    ');
fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, 'EVENT CLASS CODE = ' || C_EVENT_CLASS_CODE );
fnd_file.put_line(fnd_file.LOG, 'The following events are present in the line extract but MISSING in the header extract: ');

FOR line_record IN line_cur(l_first_event_id, l_last_event_id)
LOOP
	IF (NOT l_array_header_events.EXISTS(line_record.event_id))  AND (NOT l_array_duplicate_checker.EXISTS(line_record.event_id)) THEN
	fnd_file.put_line(fnd_file.log, 'Event_id = ' || line_record.event_id);
        l_array_duplicate_checker(line_record.event_id) := line_record.event_id;
	END IF;
END LOOP;

fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, '                    ');


xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_15');


WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_15');
END EventClass_15;
--

---------------------------------------
--
-- PRIVATE PROCEDURE
--         insert_sources_16
--
----------------------------------------
--
PROCEDURE insert_sources_16(
                                p_target_ledger_id       IN NUMBER
                              , p_language               IN VARCHAR2
                              , p_sla_ledger_id          IN NUMBER
                              , p_pad_start_date         IN DATE
                              , p_pad_end_date           IN DATE
                         )
IS

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'INT_ORDER_TO_EXP_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'INT_ORDER_TO_EXP';
p_apps_owner                   VARCHAR2(30);
l_log_module                   VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_sources_16';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of insert_sources_16'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- select APPS owner
SELECT oracle_username
  INTO p_apps_owner
  FROM fnd_oracle_userid
 WHERE read_only_flag = 'U'
;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_target_ledger_id = '||p_target_ledger_id||
                        ' - p_language = '||p_language||
                        ' - p_sla_ledger_id  = '||p_sla_ledger_id ||
                        ' - p_pad_start_date = '||TO_CHAR(p_pad_start_date)||
                        ' - p_pad_end_date = '||TO_CHAR(p_pad_end_date)||
                        ' - p_apps_owner = '||TO_CHAR(p_apps_owner)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


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
               WHEN 1 THEN 'CST_XLA_INV_HEADERS_V' 
                WHEN 2 THEN 'CST_XLA_INV_HEADERS_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                WHEN 2 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'DISTRIBUTION_TYPE' 
                WHEN 2 THEN 'TRANSFER_TO_GL_INDICATOR' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h1.DISTRIBUTION_TYPE)
                WHEN 2 THEN TO_CHAR(h1.TRANSFER_TO_GL_INDICATOR)
                
                ELSE null
              END                           source_value
            , CASE r
                WHEN 1 THEN fvl13.meaning
                WHEN 2 THEN fvl37.meaning
                
                ELSE null
              END               source_meaning
         FROM xla_events_gt     xet  
      , CST_XLA_INV_HEADERS_V  h1
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
             ,(select rownum r from all_objects where rownum <= 2 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id
   AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of header sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--



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
            , l2.line_number                 line_number
            , CASE r
               WHEN 1 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 2 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 3 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 4 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 5 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 6 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 7 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 8 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 9 THEN 'CST_XLA_INV_LINES_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'LINE' 
                WHEN 2 THEN 'LINE' 
                WHEN 3 THEN 'LINE' 
                WHEN 4 THEN 'LINE' 
                WHEN 5 THEN 'LINE' 
                WHEN 6 THEN 'LINE' 
                WHEN 7 THEN 'LINE' 
                WHEN 8 THEN 'LINE' 
                WHEN 9 THEN 'LINE' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                WHEN 3 THEN '707' 
                WHEN 4 THEN '707' 
                WHEN 5 THEN '707' 
                WHEN 6 THEN '707' 
                WHEN 7 THEN '707' 
                WHEN 8 THEN '707' 
                WHEN 9 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'CODE_COMBINATION_ID' 
                WHEN 2 THEN 'ACCOUNTING_LINE_TYPE_CODE' 
                WHEN 3 THEN 'DISTRIBUTION_IDENTIFIER' 
                WHEN 4 THEN 'CURRENCY_CODE' 
                WHEN 5 THEN 'ENTERED_AMOUNT' 
                WHEN 6 THEN 'CURRENCY_CONVERSION_DATE' 
                WHEN 7 THEN 'CURRENCY_CONVERSION_RATE' 
                WHEN 8 THEN 'CURRENCY_CONVERSION_TYPE' 
                WHEN 9 THEN 'ACCOUNTED_AMOUNT' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(l2.CODE_COMBINATION_ID)
                WHEN 2 THEN TO_CHAR(l2.ACCOUNTING_LINE_TYPE_CODE)
                WHEN 3 THEN TO_CHAR(l2.DISTRIBUTION_IDENTIFIER)
                WHEN 4 THEN TO_CHAR(l2.CURRENCY_CODE)
                WHEN 5 THEN TO_CHAR(l2.ENTERED_AMOUNT)
                WHEN 6 THEN TO_CHAR(l2.CURRENCY_CONVERSION_DATE)
                WHEN 7 THEN TO_CHAR(l2.CURRENCY_CONVERSION_RATE)
                WHEN 8 THEN TO_CHAR(l2.CURRENCY_CONVERSION_TYPE)
                WHEN 9 THEN TO_CHAR(l2.ACCOUNTED_AMOUNT)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM  xla_events_gt     xet  
        , CST_XLA_INV_LINES_V  l2
            , (select rownum r from all_objects where rownum <= 9 and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_class_code = C_EVENT_CLASS_CODE
            AND l2.event_id          = xet.event_id

)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of line sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of insert_sources_16'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
      END IF;
      RAISE;
  WHEN OTHERS THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.insert_sources_16');
END insert_sources_16;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         EventClass_16
--
----------------------------------------
--
FUNCTION EventClass_16
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_target_ledger_id       IN NUMBER
       ,p_language               IN VARCHAR2
       ,p_currency_code          IN VARCHAR2
       ,p_sla_ledger_id          IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN BOOLEAN IS
--
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'INT_ORDER_TO_EXP_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'INT_ORDER_TO_EXP';

l_calculate_acctd_flag   VARCHAR2(1) :='N';
l_calculate_g_l_flag     VARCHAR2(1) :='N';
--
l_array_legal_entity_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_transaction_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_event_id                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_class_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_number                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_event_date                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_transaction_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_num_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_char_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_date_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_event_created_by               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V100L;
l_array_budgetary_control_flag         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_header_events                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added
l_array_duplicate_checker              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added

l_event_id                             NUMBER;
l_previous_event_id                    NUMBER;
l_first_event_id                       NUMBER;
l_last_event_id                        NUMBER;

l_rec_acct_attrs                       XLA_AE_HEADER_PKG.t_rec_acct_attrs;
l_rec_rev_acct_attrs                   XLA_AE_LINES_PKG.t_rec_acct_attrs;
--
--
l_result                    BOOLEAN := TRUE;
l_rows                      NUMBER  := 1000;
l_event_type_name           VARCHAR2(80) := 'All';
l_event_class_name          VARCHAR2(80) := 'Internal Order to Expense';
l_description               VARCHAR2(4000);
l_transaction_reversal      NUMBER;
l_ae_header_id              NUMBER;
l_array_extract_line_num    xla_ae_journal_entry_pkg.t_array_Num;
l_log_module                VARCHAR2(240);
--
l_acct_reversal_source      VARCHAR2(30);
l_trx_reversal_source       VARCHAR2(30);

l_continue_with_lines       BOOLEAN := TRUE;
--
l_acc_rev_gl_date_source    DATE;                      -- 4262811
--
type t_array_event_id is table of number index by binary_integer;

l_rec_array_event                    t_rec_array_event;
l_null_rec_array_event               t_rec_array_event;
l_array_ae_header_id                 xla_number_array_type;
l_actual_flag                        VARCHAR2(1) := NULL;
l_actual_gain_loss_ref               VARCHAR2(30) := '#####';
l_balance_type_code                  VARCHAR2(1) :=NULL;
l_gain_or_loss_ref                   VARCHAR2(30) :=NULL;

--
TYPE t_array_lookup_meaning IS TABLE OF fnd_lookup_values.meaning%TYPE INDEX BY BINARY_INTEGER;
--

TYPE t_array_source_13 IS TABLE OF CST_XLA_INV_HEADERS_V.DISTRIBUTION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_37 IS TABLE OF CST_XLA_INV_HEADERS_V.TRANSFER_TO_GL_INDICATOR%TYPE INDEX BY BINARY_INTEGER;

TYPE t_array_source_1 IS TABLE OF CST_XLA_INV_LINES_V.CODE_COMBINATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_6 IS TABLE OF CST_XLA_INV_LINES_V.ACCOUNTING_LINE_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_12 IS TABLE OF CST_XLA_INV_LINES_V.DISTRIBUTION_IDENTIFIER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_16 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_20 IS TABLE OF CST_XLA_INV_LINES_V.ENTERED_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_21 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CONVERSION_DATE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_22 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CONVERSION_RATE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_23 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CONVERSION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_24 IS TABLE OF CST_XLA_INV_LINES_V.ACCOUNTED_AMOUNT%TYPE INDEX BY BINARY_INTEGER;

l_array_source_13              t_array_source_13;
l_array_source_13_meaning      t_array_lookup_meaning;
l_array_source_37              t_array_source_37;
l_array_source_37_meaning      t_array_lookup_meaning;

l_array_source_1      t_array_source_1;
l_array_source_6      t_array_source_6;
l_array_source_12      t_array_source_12;
l_array_source_16      t_array_source_16;
l_array_source_20      t_array_source_20;
l_array_source_21      t_array_source_21;
l_array_source_22      t_array_source_22;
l_array_source_23      t_array_source_23;
l_array_source_24      t_array_source_24;

--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: INT_ORDER_TO_EXP
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
  , h1.DISTRIBUTION_TYPE    source_13
  , fvl13.meaning   source_13_meaning
  , h1.TRANSFER_TO_GL_INDICATOR    source_37
  , fvl37.meaning   source_37_meaning
  FROM xla_events_gt     xet 
  , CST_XLA_INV_HEADERS_V  h1
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id
   AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: INT_ORDER_TO_EXP
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
 , l2.LINE_NUMBER  
  , l2.CODE_COMBINATION_ID    source_1
  , l2.ACCOUNTING_LINE_TYPE_CODE    source_6
  , l2.DISTRIBUTION_IDENTIFIER    source_12
  , l2.CURRENCY_CODE    source_16
  , l2.ENTERED_AMOUNT    source_20
  , l2.CURRENCY_CONVERSION_DATE    source_21
  , l2.CURRENCY_CONVERSION_RATE    source_22
  , l2.CURRENCY_CONVERSION_TYPE    source_23
  , l2.ACCOUNTED_AMOUNT    source_24
  FROM xla_events_gt     xet 
  , CST_XLA_INV_LINES_V  l2
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'   AND l2.event_id      = xet.event_id
;

--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.EventClass_16';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of EventClass_16'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'p_application_id = '||p_application_id||
                     ' - p_base_ledger_id = '||p_base_ledger_id||
                     ' - p_target_ledger_id  = '||p_target_ledger_id||
                     ' - p_language = '||p_language||
                     ' - p_currency_code = '||p_currency_code||
                     ' - p_sla_ledger_id = '||p_sla_ledger_id
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
-- initialze arrays
--
g_array_event.DELETE;
l_rec_array_event := l_null_rec_array_event;
--
--------------------------------------
-- 4262811 Initialze MPA Line Number
--------------------------------------
XLA_AE_HEADER_PKG.g_mpa_line_num := 0;

--

--
OPEN header_cur;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
   (p_msg      => 'SQL - FETCH header_cur'
   ,p_level    => C_LEVEL_STATEMENT
   ,p_module   => l_log_module);
END IF;
--
LOOP
FETCH header_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag 
      , l_array_source_13
      , l_array_source_13_meaning
      , l_array_source_37
      , l_array_source_37_meaning
      LIMIT l_rows;
--
IF (C_LEVEL_EVENT >= g_log_level) THEN
   trace
   (p_msg      => '# rows extracted from header extract objects = '||TO_CHAR(header_cur%ROWCOUNT)
   ,p_level    => C_LEVEL_EVENT
   ,p_module   => l_log_module);
END IF;
--
EXIT WHEN l_array_entity_id.COUNT = 0;

-- initialize arrays
XLA_AE_HEADER_PKG.g_rec_header_new        := NULL;
XLA_AE_LINES_PKG.g_rec_lines              := NULL;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;


-- 4262811 - when creating Accrual Reversal or MPA, use g_last_hdr_idx to increment for next header id
g_last_hdr_idx := l_array_event_id.LAST;
--
-- loop for the headers. Each iteration is for each header extract row
-- fetched in header cursor
--
FOR hdr_idx IN l_array_event_id.FIRST .. l_array_event_id.LAST LOOP

--
-- set event info as cache for other routines to refer event attributes
--
XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
   (p_application_id           => p_application_id
   ,p_primary_ledger_id        => p_primary_ledger_id
   ,p_base_ledger_id           => p_base_ledger_id
   ,p_target_ledger_id         => p_target_ledger_id
   ,p_entity_id                => l_array_entity_id(hdr_idx)
   ,p_legal_entity_id          => l_array_legal_entity_id(hdr_idx)
   ,p_entity_code              => l_array_entity_code(hdr_idx)
   ,p_transaction_num          => l_array_transaction_num(hdr_idx)
   ,p_event_id                 => l_array_event_id(hdr_idx)
   ,p_event_class_code         => l_array_class_code(hdr_idx)
   ,p_event_type_code          => l_array_event_type(hdr_idx)
   ,p_event_number             => l_array_event_number(hdr_idx)
   ,p_event_date               => l_array_event_date(hdr_idx)
   ,p_transaction_date         => l_array_transaction_date(hdr_idx)
   ,p_reference_num_1          => l_array_reference_num_1(hdr_idx)
   ,p_reference_num_2          => l_array_reference_num_2(hdr_idx)
   ,p_reference_num_3          => l_array_reference_num_3(hdr_idx)
   ,p_reference_num_4          => l_array_reference_num_4(hdr_idx)
   ,p_reference_char_1         => l_array_reference_char_1(hdr_idx)
   ,p_reference_char_2         => l_array_reference_char_2(hdr_idx)
   ,p_reference_char_3         => l_array_reference_char_3(hdr_idx)
   ,p_reference_char_4         => l_array_reference_char_4(hdr_idx)
   ,p_reference_date_1         => l_array_reference_date_1(hdr_idx)
   ,p_reference_date_2         => l_array_reference_date_2(hdr_idx)
   ,p_reference_date_3         => l_array_reference_date_3(hdr_idx)
   ,p_reference_date_4         => l_array_reference_date_4(hdr_idx)
   ,p_event_created_by         => l_array_event_created_by(hdr_idx)
   ,p_budgetary_control_flag   => l_array_budgetary_control_flag(hdr_idx));

--
-- set the status of entry to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;

--
-- initialize a row for ae header
--
XLA_AE_HEADER_PKG.InitHeader(hdr_idx);

l_event_id := l_array_event_id(hdr_idx);

--
-- storing the hdr_idx for event. May be used by line cursor.
--
g_array_event(l_event_id).array_value_num('header_index') := hdr_idx;

--
-- store sources from header extract. This can be improved to
-- store only those sources from header extract that may be used in lines
--

g_array_event(l_event_id).array_value_char('source_13') := l_array_source_13(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13_meaning') := l_array_source_13_meaning(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37') := l_array_source_37(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37_meaning') := l_array_source_37_meaning(hdr_idx);

--
-- initilaize the status of ae headers for diffrent balance types
-- the status is initialised to C_NOT_CREATED (2)
--
--g_array_event(l_event_id).array_value_num('actual_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('budget_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('encumbrance_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;

--
-- call api to validate and store accounting attributes for header
--

------------------------------------------------------------
-- Accrual Reversal : to get date for Standard Source (NONE)
------------------------------------------------------------
l_acc_rev_gl_date_source := NULL;

     l_rec_acct_attrs.array_acct_attr_code(1)   := 'GL_DATE';
      l_rec_acct_attrs.array_date_value(1) := 
xla_ae_sources_pkg.GetSystemSourceDate(
   p_source_code           => 'XLA_REFERENCE_DATE_1'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
);
     l_rec_acct_attrs.array_acct_attr_code(2)   := 'GL_TRANSFER_FLAG';
      l_rec_acct_attrs.array_char_value(2) := g_array_event(l_event_id).array_value_char('source_37');


XLA_AE_HEADER_PKG.SetHdrAcctAttrs(l_rec_acct_attrs);

XLA_AE_HEADER_PKG.SetJeCategoryName;

XLA_AE_HEADER_PKG.g_rec_header_new.array_event_type_code(hdr_idx)  := l_array_event_type(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(hdr_idx)         := l_array_event_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_entity_id(hdr_idx)        := l_array_entity_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_number(hdr_idx)     := l_array_event_number(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_target_ledger_id(hdr_idx) := p_target_ledger_id;


-- No header level analytical criteria

--
--accounting attribute enhancement, bug 3612931
--
l_trx_reversal_source := SUBSTR(NULL, 1,30);

IF NVL(l_trx_reversal_source, 'N') NOT IN ('N','Y') THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name            => 'XLA'
      ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
      ,p_token_1                 => 'ACCT_ATTR_NAME'
      ,p_value_1                 => xla_ae_sources_pkg.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
      ,p_token_2                 => 'PRODUCT_NAME'
      ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
      ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
      ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
      ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

ELSIF NVL(l_trx_reversal_source, 'N') = 'Y' THEN
   --
   -- following sets the accounting attributes needed to reverse
   -- accounting for a distributeion
   --
   xla_ae_lines_pkg.SetTrxReversalAttrs
      (p_event_id              => l_event_id
      ,p_gl_date               => XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(hdr_idx)
      ,p_trx_reversal_source   => l_trx_reversal_source);

END IF;


----------------------------------------------------------------
-- 4262811 -  update the header statuses to invalid in need be
----------------------------------------------------------------
--
XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx => hdr_idx);


  -----------------------------------------------
  -- No accrual reversal for the event class/type
  -----------------------------------------------
----------------------------------------------------------------

--
-- this ends the header loop iteration for one bulk fetch
--
END LOOP;

l_first_event_id   := l_array_event_id(l_array_event_id.FIRST);
l_last_event_id    := l_array_event_id(l_array_event_id.LAST);

--
-- insert dummy rows into lines gt table that were created due to
-- transaction reversals
--
IF XLA_AE_LINES_PKG.g_rec_lines.array_ae_header_id.COUNT > 0 THEN
   l_result := XLA_AE_LINES_PKG.InsertLines;
END IF;

--
-- reset the temp_line_num for each set of events fetched from header
-- cursor rather than doing it for each new event in line cursor
-- Bug 3939231
--
xla_ae_lines_pkg.g_temp_line_num := 0;



--
OPEN line_cur(x_first_event_id  => l_first_event_id, x_last_event_id  => l_last_event_id);
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - FETCH line_cur'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
LOOP
  --
  FETCH line_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag
      , l_array_extract_line_num 
      , l_array_source_1
      , l_array_source_6
      , l_array_source_12
      , l_array_source_16
      , l_array_source_20
      , l_array_source_21
      , l_array_source_22
      , l_array_source_23
      , l_array_source_24
      LIMIT l_rows;

  --
  IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => '# rows extracted from line extract objects = '||TO_CHAR(line_cur%ROWCOUNT)
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
  END IF;
  --
  EXIT WHEN l_array_entity_id.count = 0;

  XLA_AE_LINES_PKG.g_rec_lines := null;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;
--
--

FOR Idx IN 1..l_array_event_id.count LOOP
   --
   -- 5648433 (move l_event_id out of IF statement)  set l_event_id to be used inside IF condition
   --
   l_event_id := l_array_event_id(idx);  -- 5648433

   --
   -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
   --

   IF NVL(xla_ae_header_pkg.g_rec_header_new.array_trx_acct_reversal_option
             (g_array_event(l_event_id).array_value_num('header_index'))
         ,'N'
         ) <> 'Y'
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is not Y '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

--
-- set the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
--
-- set event info as cache for other routines to refer event attributes
--

IF l_event_id <> NVL(l_previous_event_id, -1) THEN
   l_previous_event_id := l_event_id;

   XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
      (p_application_id           => p_application_id
      ,p_primary_ledger_id        => p_primary_ledger_id
      ,p_base_ledger_id           => p_base_ledger_id
      ,p_target_ledger_id         => p_target_ledger_id
      ,p_entity_id                => l_array_entity_id(Idx)
      ,p_legal_entity_id          => l_array_legal_entity_id(Idx)
      ,p_entity_code              => l_array_entity_code(Idx)
      ,p_transaction_num          => l_array_transaction_num(Idx)
      ,p_event_id                 => l_array_event_id(Idx)
      ,p_event_class_code         => l_array_class_code(Idx)
      ,p_event_type_code          => l_array_event_type(Idx)
      ,p_event_number             => l_array_event_number(Idx)
      ,p_event_date               => l_array_event_date(Idx)
      ,p_transaction_date         => l_array_transaction_date(Idx)
      ,p_reference_num_1          => l_array_reference_num_1(Idx)
      ,p_reference_num_2          => l_array_reference_num_2(Idx)
      ,p_reference_num_3          => l_array_reference_num_3(Idx)
      ,p_reference_num_4          => l_array_reference_num_4(Idx)
      ,p_reference_char_1         => l_array_reference_char_1(Idx)
      ,p_reference_char_2         => l_array_reference_char_2(Idx)
      ,p_reference_char_3         => l_array_reference_char_3(Idx)
      ,p_reference_char_4         => l_array_reference_char_4(Idx)
      ,p_reference_date_1         => l_array_reference_date_1(Idx)
      ,p_reference_date_2         => l_array_reference_date_2(Idx)
      ,p_reference_date_3         => l_array_reference_date_3(Idx)
      ,p_reference_date_4         => l_array_reference_date_4(Idx)
      ,p_event_created_by         => l_array_event_created_by(Idx)
      ,p_budgetary_control_flag   => l_array_budgetary_control_flag(Idx));
       --
END IF;



--
xla_ae_lines_pkg.SetExtractLine(p_extract_line => l_array_extract_line_num(Idx));

l_acct_reversal_source := SUBSTR(NULL, 1,30);

IF l_continue_with_lines THEN
   IF NVL(l_acct_reversal_source, 'N') NOT IN ('N','Y','B') THEN
      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_INVALID_REVERSAL_OPTION'
         ,p_token_1                 => 'LINE_NUMBER'
         ,p_value_1                 => l_array_extract_line_num(Idx)
         ,p_token_2                 => 'PRODUCT_NAME'
         ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
         ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
         ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

   ELSIF NVL(l_acct_reversal_source, 'N') IN ('Y','B') THEN
      --
      -- following sets the accounting attributes needed to reverse
      -- accounting for a distributeion
      --

      --
      -- 5217187
      --
      l_rec_rev_acct_attrs.array_acct_attr_code(1):= 'GL_DATE';
      l_rec_rev_acct_attrs.array_date_value(1) := XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(
                                       g_array_event(l_event_id).array_value_num('header_index'));
      --
      --

      -- No reversal code generated

      xla_ae_lines_pkg.SetAcctReversalAttrs
         (p_event_id             => l_event_id
         ,p_rec_acct_attrs       => l_rec_rev_acct_attrs
         ,p_calculate_acctd_flag => l_calculate_acctd_flag
         ,p_calculate_g_l_flag   => l_calculate_g_l_flag);
   END IF;

   IF NVL(l_acct_reversal_source, 'N') IN ('N','B') THEN
       l_actual_flag := NULL;  l_actual_gain_loss_ref := '#####';

--
AcctLineType_3 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_1 => l_array_source_1(Idx)
 , p_source_6 => l_array_source_6(Idx)
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_16 => l_array_source_16(Idx)
 , p_source_20 => l_array_source_20(Idx)
 , p_source_21 => l_array_source_21(Idx)
 , p_source_22 => l_array_source_22(Idx)
 , p_source_23 => l_array_source_23(Idx)
 , p_source_24 => l_array_source_24(Idx)
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--

      -- only execute it if calculate g/l flag is yes, and primary or secondary ledger
      -- or secondary ledger that has different currency with primary
      -- or alc that is calculated by sla
      IF (((l_calculate_g_l_flag = 'Y' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> 'ALC') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in ('ALC', 'SECONDARY') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='Y'))

--      IF((l_calculate_g_l_flag='Y' or XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id <>
--                    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id)
          AND (l_actual_flag = 'A')) THEN
        XLA_AE_LINES_PKG.CreateGainOrLossLines(
          p_event_id         => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_application_id   => p_application_id
         ,p_amb_context_code => 'DEFAULT'
         ,p_entity_code      => xla_ae_journal_entry_pkg.g_cache_event.entity_code
         ,p_event_class_code => C_EVENT_CLASS_CODE
         ,p_event_type_code  => C_EVENT_TYPE_CODE
         
         ,p_gain_ccid        => -1
         ,p_loss_ccid        => -1

         ,p_actual_flag      => l_actual_flag
         ,p_enc_flag         => null
         ,p_actual_g_l_ref   => l_actual_gain_loss_ref
         ,p_enc_g_l_ref      => null
         );
      END IF;
   END IF;
END IF;

   ELSE
      --
      -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is Y'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

END LOOP;
l_result := XLA_AE_LINES_PKG.InsertLines ;
end loop;
close line_cur;


--
-- insert headers into xla_ae_headers_gt table
--
l_result := XLA_AE_HEADER_PKG.InsertHeaders ;

-- insert into errors table here.

END LOOP;

--
-- 4865292
--
-- Compare g_hdr_extract_count with event count in
-- CreateHeadersAndLines.
--
g_hdr_extract_count := g_hdr_extract_count + header_cur%ROWCOUNT;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace (p_msg     => '# rows extracted from header extract objects '
                    || ' (running total): '
                    || g_hdr_extract_count
         ,p_level   => C_LEVEL_STATEMENT
         ,p_module  => l_log_module);
END IF;

CLOSE header_cur;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of EventClass_16'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   
IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;

   
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

   RAISE;

WHEN NO_DATA_FOUND THEN

IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

FOR header_record IN header_cur
LOOP
    l_array_header_events(header_record.event_id) := header_record.event_id;
END LOOP;

l_first_event_id := l_array_header_events(l_array_header_events.FIRST);
l_last_event_id := l_array_header_events(l_array_header_events.LAST);

fnd_file.put_line(fnd_file.LOG, '                    ');
fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, 'EVENT CLASS CODE = ' || C_EVENT_CLASS_CODE );
fnd_file.put_line(fnd_file.LOG, 'The following events are present in the line extract but MISSING in the header extract: ');

FOR line_record IN line_cur(l_first_event_id, l_last_event_id)
LOOP
	IF (NOT l_array_header_events.EXISTS(line_record.event_id))  AND (NOT l_array_duplicate_checker.EXISTS(line_record.event_id)) THEN
	fnd_file.put_line(fnd_file.log, 'Event_id = ' || line_record.event_id);
        l_array_duplicate_checker(line_record.event_id) := line_record.event_id;
	END IF;
END LOOP;

fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, '                    ');


xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_16');


WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_16');
END EventClass_16;
--

---------------------------------------
--
-- PRIVATE PROCEDURE
--         insert_sources_17
--
----------------------------------------
--
PROCEDURE insert_sources_17(
                                p_target_ledger_id       IN NUMBER
                              , p_language               IN VARCHAR2
                              , p_sla_ledger_id          IN NUMBER
                              , p_pad_start_date         IN DATE
                              , p_pad_end_date           IN DATE
                         )
IS

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'PERIOD_END_ACCRUAL_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'PERIOD_END_ACCRUAL';
p_apps_owner                   VARCHAR2(30);
l_log_module                   VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_sources_17';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of insert_sources_17'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- select APPS owner
SELECT oracle_username
  INTO p_apps_owner
  FROM fnd_oracle_userid
 WHERE read_only_flag = 'U'
;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_target_ledger_id = '||p_target_ledger_id||
                        ' - p_language = '||p_language||
                        ' - p_sla_ledger_id  = '||p_sla_ledger_id ||
                        ' - p_pad_start_date = '||TO_CHAR(p_pad_start_date)||
                        ' - p_pad_end_date = '||TO_CHAR(p_pad_end_date)||
                        ' - p_apps_owner = '||TO_CHAR(p_apps_owner)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


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
               WHEN 1 THEN 'PO_HEADERS_REF_V' 
                WHEN 2 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 3 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 4 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 5 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 6 THEN 'CST_XLA_RCV_HEADERS_V' 
                WHEN 7 THEN 'PO_DISTS_REF_V' 
                WHEN 8 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 9 THEN 'CST_XLA_RCV_HEADERS_V' 
                WHEN 10 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 11 THEN 'PO_HEADERS_REF_V' 
                WHEN 12 THEN 'CST_XLA_RCV_REF_V' 
                WHEN 13 THEN 'PSA_CST_XLA_PEA_UPG_V' 
                WHEN 14 THEN 'CST_XLA_RCV_HEADERS_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                WHEN 2 THEN 'HEADER' 
                WHEN 3 THEN 'HEADER' 
                WHEN 4 THEN 'HEADER' 
                WHEN 5 THEN 'HEADER' 
                WHEN 6 THEN 'HEADER' 
                WHEN 7 THEN 'HEADER' 
                WHEN 8 THEN 'HEADER' 
                WHEN 9 THEN 'HEADER' 
                WHEN 10 THEN 'HEADER' 
                WHEN 11 THEN 'HEADER' 
                WHEN 12 THEN 'HEADER' 
                WHEN 13 THEN 'HEADER' 
                WHEN 14 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '201' 
                WHEN 2 THEN '707' 
                WHEN 3 THEN '707' 
                WHEN 4 THEN '707' 
                WHEN 5 THEN '707' 
                WHEN 6 THEN '707' 
                WHEN 7 THEN '201' 
                WHEN 8 THEN '707' 
                WHEN 9 THEN '707' 
                WHEN 10 THEN '707' 
                WHEN 11 THEN '201' 
                WHEN 12 THEN '707' 
                WHEN 13 THEN '707' 
                WHEN 14 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'PURCH_ENCUMBRANCE_FLAG' 
                WHEN 2 THEN 'APPLIED_TO_APPL_ID' 
                WHEN 3 THEN 'APPLIED_TO_DIST_LINK_TYPE' 
                WHEN 4 THEN 'APPLIED_TO_ENTITY_CODE' 
                WHEN 5 THEN 'APPLIED_TO_PO_DOC_ID' 
                WHEN 6 THEN 'DISTRIBUTION_TYPE' 
                WHEN 7 THEN 'PO_BUDGET_ACCOUNT' 
                WHEN 8 THEN 'ENCUM_REVERSAL_AMOUNT_ENTERED' 
                WHEN 9 THEN 'CURRENCY_CODE' 
                WHEN 10 THEN 'ENCUMBRANCE_REVERSAL_AMOUNT' 
                WHEN 11 THEN 'PURCH_ENCUMBRANCE_TYPE_ID' 
                WHEN 12 THEN 'PO_DISTRIBUTION_ID' 
                WHEN 13 THEN 'CST_PEA_ENC_UPG_OPTION' 
                WHEN 14 THEN 'TRANSFER_TO_GL_INDICATOR' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h5.PURCH_ENCUMBRANCE_FLAG)
                WHEN 2 THEN TO_CHAR(h3.APPLIED_TO_APPL_ID)
                WHEN 3 THEN TO_CHAR(h3.APPLIED_TO_DIST_LINK_TYPE)
                WHEN 4 THEN TO_CHAR(h3.APPLIED_TO_ENTITY_CODE)
                WHEN 5 THEN TO_CHAR(h3.APPLIED_TO_PO_DOC_ID)
                WHEN 6 THEN TO_CHAR(h1.DISTRIBUTION_TYPE)
                WHEN 7 THEN TO_CHAR(h4.PO_BUDGET_ACCOUNT)
                WHEN 8 THEN TO_CHAR(h3.ENCUM_REVERSAL_AMOUNT_ENTERED)
                WHEN 9 THEN TO_CHAR(h1.CURRENCY_CODE)
                WHEN 10 THEN TO_CHAR(h3.ENCUMBRANCE_REVERSAL_AMOUNT)
                WHEN 11 THEN TO_CHAR(h5.PURCH_ENCUMBRANCE_TYPE_ID)
                WHEN 12 THEN TO_CHAR(h3.PO_DISTRIBUTION_ID)
                WHEN 13 THEN TO_CHAR(h6.CST_PEA_ENC_UPG_OPTION)
                WHEN 14 THEN TO_CHAR(h1.TRANSFER_TO_GL_INDICATOR)
                
                ELSE null
              END                           source_value
            , CASE r
                WHEN 6 THEN fvl13.meaning
                WHEN 14 THEN fvl37.meaning
                
                ELSE null
              END               source_meaning
         FROM xla_events_gt     xet  
      , CST_XLA_RCV_HEADERS_V  h1
      , CST_XLA_RCV_REF_V  h3
      , PO_DISTS_REF_V  h4
      , PO_HEADERS_REF_V  h5
      , PSA_CST_XLA_PEA_UPG_V  h6
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
             ,(select rownum r from all_objects where rownum <= 14 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id
 AND h3.ref_rcv_accounting_event_id = h1.rcv_accounting_event_id AND h3.po_header_id = h4.po_header_id  (+)  and h3.po_distribution_id = h4.po_distribution_id (+)  AND h3.po_header_id = h5.po_header_id (+)  AND h3.ref_rcv_accounting_event_id = h6.accounting_event_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of header sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--



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
            , l2.line_number                 line_number
            , CASE r
               WHEN 1 THEN 'CST_XLA_RCV_LINES_V' 
                WHEN 2 THEN 'CST_XLA_RCV_LINES_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'LINE' 
                WHEN 2 THEN 'LINE' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'DISTRIBUTION_IDENTIFIER' 
                WHEN 2 THEN 'RCV_ACCOUNTING_LINE_TYPE' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(l2.DISTRIBUTION_IDENTIFIER)
                WHEN 2 THEN TO_CHAR(l2.RCV_ACCOUNTING_LINE_TYPE)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM  xla_events_gt     xet  
        , CST_XLA_RCV_LINES_V  l2
            , (select rownum r from all_objects where rownum <= 2 and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_class_code = C_EVENT_CLASS_CODE
            AND l2.event_id          = xet.event_id

)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of line sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of insert_sources_17'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
      END IF;
      RAISE;
  WHEN OTHERS THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.insert_sources_17');
END insert_sources_17;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         EventClass_17
--
----------------------------------------
--
FUNCTION EventClass_17
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_target_ledger_id       IN NUMBER
       ,p_language               IN VARCHAR2
       ,p_currency_code          IN VARCHAR2
       ,p_sla_ledger_id          IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN BOOLEAN IS
--
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'PERIOD_END_ACCRUAL_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'PERIOD_END_ACCRUAL';

l_calculate_acctd_flag   VARCHAR2(1) :='N';
l_calculate_g_l_flag     VARCHAR2(1) :='N';
--
l_array_legal_entity_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_transaction_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_event_id                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_class_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_number                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_event_date                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_transaction_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_num_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_char_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_date_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_event_created_by               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V100L;
l_array_budgetary_control_flag         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_header_events                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added
l_array_duplicate_checker              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added

l_event_id                             NUMBER;
l_previous_event_id                    NUMBER;
l_first_event_id                       NUMBER;
l_last_event_id                        NUMBER;

l_rec_acct_attrs                       XLA_AE_HEADER_PKG.t_rec_acct_attrs;
l_rec_rev_acct_attrs                   XLA_AE_LINES_PKG.t_rec_acct_attrs;
--
--
l_result                    BOOLEAN := TRUE;
l_rows                      NUMBER  := 1000;
l_event_type_name           VARCHAR2(80) := 'All';
l_event_class_name          VARCHAR2(80) := 'Period End Accrual';
l_description               VARCHAR2(4000);
l_transaction_reversal      NUMBER;
l_ae_header_id              NUMBER;
l_array_extract_line_num    xla_ae_journal_entry_pkg.t_array_Num;
l_log_module                VARCHAR2(240);
--
l_acct_reversal_source      VARCHAR2(30);
l_trx_reversal_source       VARCHAR2(30);

l_continue_with_lines       BOOLEAN := TRUE;
--
l_acc_rev_gl_date_source    DATE;                      -- 4262811
--
type t_array_event_id is table of number index by binary_integer;

l_rec_array_event                    t_rec_array_event;
l_null_rec_array_event               t_rec_array_event;
l_array_ae_header_id                 xla_number_array_type;
l_actual_flag                        VARCHAR2(1) := NULL;
l_actual_gain_loss_ref               VARCHAR2(30) := '#####';
l_balance_type_code                  VARCHAR2(1) :=NULL;
l_gain_or_loss_ref                   VARCHAR2(30) :=NULL;

--
TYPE t_array_lookup_meaning IS TABLE OF fnd_lookup_values.meaning%TYPE INDEX BY BINARY_INTEGER;
--

TYPE t_array_source_2 IS TABLE OF PO_HEADERS_REF_V.PURCH_ENCUMBRANCE_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_7 IS TABLE OF CST_XLA_RCV_REF_V.APPLIED_TO_APPL_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_8 IS TABLE OF CST_XLA_RCV_REF_V.APPLIED_TO_DIST_LINK_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_9 IS TABLE OF CST_XLA_RCV_REF_V.APPLIED_TO_ENTITY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_11 IS TABLE OF CST_XLA_RCV_REF_V.APPLIED_TO_PO_DOC_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_13 IS TABLE OF CST_XLA_RCV_HEADERS_V.DISTRIBUTION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_14 IS TABLE OF PO_DISTS_REF_V.PO_BUDGET_ACCOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_15 IS TABLE OF CST_XLA_RCV_REF_V.ENCUM_REVERSAL_AMOUNT_ENTERED%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_16 IS TABLE OF CST_XLA_RCV_HEADERS_V.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_17 IS TABLE OF CST_XLA_RCV_REF_V.ENCUMBRANCE_REVERSAL_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_19 IS TABLE OF PO_HEADERS_REF_V.PURCH_ENCUMBRANCE_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_26 IS TABLE OF CST_XLA_RCV_REF_V.PO_DISTRIBUTION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_27 IS TABLE OF PSA_CST_XLA_PEA_UPG_V.CST_PEA_ENC_UPG_OPTION%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_37 IS TABLE OF CST_XLA_RCV_HEADERS_V.TRANSFER_TO_GL_INDICATOR%TYPE INDEX BY BINARY_INTEGER;

TYPE t_array_source_12 IS TABLE OF CST_XLA_RCV_LINES_V.DISTRIBUTION_IDENTIFIER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_25 IS TABLE OF CST_XLA_RCV_LINES_V.RCV_ACCOUNTING_LINE_TYPE%TYPE INDEX BY BINARY_INTEGER;

l_array_source_2              t_array_source_2;
l_array_source_7              t_array_source_7;
l_array_source_8              t_array_source_8;
l_array_source_9              t_array_source_9;
l_array_source_11              t_array_source_11;
l_array_source_13              t_array_source_13;
l_array_source_13_meaning      t_array_lookup_meaning;
l_array_source_14              t_array_source_14;
l_array_source_15              t_array_source_15;
l_array_source_16              t_array_source_16;
l_array_source_17              t_array_source_17;
l_array_source_19              t_array_source_19;
l_array_source_26              t_array_source_26;
l_array_source_27              t_array_source_27;
l_array_source_37              t_array_source_37;
l_array_source_37_meaning      t_array_lookup_meaning;

l_array_source_12      t_array_source_12;
l_array_source_25      t_array_source_25;

--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: PERIOD_END_ACCRUAL
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
  , h5.PURCH_ENCUMBRANCE_FLAG    source_2
  , h3.APPLIED_TO_APPL_ID    source_7
  , h3.APPLIED_TO_DIST_LINK_TYPE    source_8
  , h3.APPLIED_TO_ENTITY_CODE    source_9
  , h3.APPLIED_TO_PO_DOC_ID    source_11
  , h1.DISTRIBUTION_TYPE    source_13
  , fvl13.meaning   source_13_meaning
  , h4.PO_BUDGET_ACCOUNT    source_14
  , h3.ENCUM_REVERSAL_AMOUNT_ENTERED    source_15
  , h1.CURRENCY_CODE    source_16
  , h3.ENCUMBRANCE_REVERSAL_AMOUNT    source_17
  , h5.PURCH_ENCUMBRANCE_TYPE_ID    source_19
  , h3.PO_DISTRIBUTION_ID    source_26
  , h6.CST_PEA_ENC_UPG_OPTION    source_27
  , h1.TRANSFER_TO_GL_INDICATOR    source_37
  , fvl37.meaning   source_37_meaning
  FROM xla_events_gt     xet 
  , CST_XLA_RCV_HEADERS_V  h1
  , CST_XLA_RCV_REF_V  h3
  , PO_DISTS_REF_V  h4
  , PO_HEADERS_REF_V  h5
  , PSA_CST_XLA_PEA_UPG_V  h6
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id
 AND h3.REF_RCV_ACCOUNTING_EVENT_ID = h1.RCV_ACCOUNTING_EVENT_ID AND h3.po_header_id = h4.po_header_id  (+)  AND h3.po_distribution_id = h4.po_distribution_id (+)  AND h3.po_header_id = h5.po_header_id (+)  AND h3.ref_rcv_accounting_event_id = h6.accounting_event_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: PERIOD_END_ACCRUAL
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
 , l2.LINE_NUMBER  
  , l2.DISTRIBUTION_IDENTIFIER    source_12
  , l2.RCV_ACCOUNTING_LINE_TYPE    source_25
  FROM xla_events_gt     xet 
  , CST_XLA_RCV_LINES_V  l2
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'   AND l2.event_id      = xet.event_id
;

--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.EventClass_17';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of EventClass_17'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'p_application_id = '||p_application_id||
                     ' - p_base_ledger_id = '||p_base_ledger_id||
                     ' - p_target_ledger_id  = '||p_target_ledger_id||
                     ' - p_language = '||p_language||
                     ' - p_currency_code = '||p_currency_code||
                     ' - p_sla_ledger_id = '||p_sla_ledger_id
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
-- initialze arrays
--
g_array_event.DELETE;
l_rec_array_event := l_null_rec_array_event;
--
--------------------------------------
-- 4262811 Initialze MPA Line Number
--------------------------------------
XLA_AE_HEADER_PKG.g_mpa_line_num := 0;

--

--
OPEN header_cur;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
   (p_msg      => 'SQL - FETCH header_cur'
   ,p_level    => C_LEVEL_STATEMENT
   ,p_module   => l_log_module);
END IF;
--
LOOP
FETCH header_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag 
      , l_array_source_2
      , l_array_source_7
      , l_array_source_8
      , l_array_source_9
      , l_array_source_11
      , l_array_source_13
      , l_array_source_13_meaning
      , l_array_source_14
      , l_array_source_15
      , l_array_source_16
      , l_array_source_17
      , l_array_source_19
      , l_array_source_26
      , l_array_source_27
      , l_array_source_37
      , l_array_source_37_meaning
      LIMIT l_rows;
--
IF (C_LEVEL_EVENT >= g_log_level) THEN
   trace
   (p_msg      => '# rows extracted from header extract objects = '||TO_CHAR(header_cur%ROWCOUNT)
   ,p_level    => C_LEVEL_EVENT
   ,p_module   => l_log_module);
END IF;
--
EXIT WHEN l_array_entity_id.COUNT = 0;

-- initialize arrays
XLA_AE_HEADER_PKG.g_rec_header_new        := NULL;
XLA_AE_LINES_PKG.g_rec_lines              := NULL;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;


-- 4262811 - when creating Accrual Reversal or MPA, use g_last_hdr_idx to increment for next header id
g_last_hdr_idx := l_array_event_id.LAST;
--
-- loop for the headers. Each iteration is for each header extract row
-- fetched in header cursor
--
FOR hdr_idx IN l_array_event_id.FIRST .. l_array_event_id.LAST LOOP

--
-- set event info as cache for other routines to refer event attributes
--
XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
   (p_application_id           => p_application_id
   ,p_primary_ledger_id        => p_primary_ledger_id
   ,p_base_ledger_id           => p_base_ledger_id
   ,p_target_ledger_id         => p_target_ledger_id
   ,p_entity_id                => l_array_entity_id(hdr_idx)
   ,p_legal_entity_id          => l_array_legal_entity_id(hdr_idx)
   ,p_entity_code              => l_array_entity_code(hdr_idx)
   ,p_transaction_num          => l_array_transaction_num(hdr_idx)
   ,p_event_id                 => l_array_event_id(hdr_idx)
   ,p_event_class_code         => l_array_class_code(hdr_idx)
   ,p_event_type_code          => l_array_event_type(hdr_idx)
   ,p_event_number             => l_array_event_number(hdr_idx)
   ,p_event_date               => l_array_event_date(hdr_idx)
   ,p_transaction_date         => l_array_transaction_date(hdr_idx)
   ,p_reference_num_1          => l_array_reference_num_1(hdr_idx)
   ,p_reference_num_2          => l_array_reference_num_2(hdr_idx)
   ,p_reference_num_3          => l_array_reference_num_3(hdr_idx)
   ,p_reference_num_4          => l_array_reference_num_4(hdr_idx)
   ,p_reference_char_1         => l_array_reference_char_1(hdr_idx)
   ,p_reference_char_2         => l_array_reference_char_2(hdr_idx)
   ,p_reference_char_3         => l_array_reference_char_3(hdr_idx)
   ,p_reference_char_4         => l_array_reference_char_4(hdr_idx)
   ,p_reference_date_1         => l_array_reference_date_1(hdr_idx)
   ,p_reference_date_2         => l_array_reference_date_2(hdr_idx)
   ,p_reference_date_3         => l_array_reference_date_3(hdr_idx)
   ,p_reference_date_4         => l_array_reference_date_4(hdr_idx)
   ,p_event_created_by         => l_array_event_created_by(hdr_idx)
   ,p_budgetary_control_flag   => l_array_budgetary_control_flag(hdr_idx));

--
-- set the status of entry to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;

--
-- initialize a row for ae header
--
XLA_AE_HEADER_PKG.InitHeader(hdr_idx);

l_event_id := l_array_event_id(hdr_idx);

--
-- storing the hdr_idx for event. May be used by line cursor.
--
g_array_event(l_event_id).array_value_num('header_index') := hdr_idx;

--
-- store sources from header extract. This can be improved to
-- store only those sources from header extract that may be used in lines
--

g_array_event(l_event_id).array_value_char('source_2') := l_array_source_2(hdr_idx);
g_array_event(l_event_id).array_value_num('source_7') := l_array_source_7(hdr_idx);
g_array_event(l_event_id).array_value_char('source_8') := l_array_source_8(hdr_idx);
g_array_event(l_event_id).array_value_char('source_9') := l_array_source_9(hdr_idx);
g_array_event(l_event_id).array_value_num('source_11') := l_array_source_11(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13') := l_array_source_13(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13_meaning') := l_array_source_13_meaning(hdr_idx);
g_array_event(l_event_id).array_value_num('source_14') := l_array_source_14(hdr_idx);
g_array_event(l_event_id).array_value_num('source_15') := l_array_source_15(hdr_idx);
g_array_event(l_event_id).array_value_char('source_16') := l_array_source_16(hdr_idx);
g_array_event(l_event_id).array_value_num('source_17') := l_array_source_17(hdr_idx);
g_array_event(l_event_id).array_value_num('source_19') := l_array_source_19(hdr_idx);
g_array_event(l_event_id).array_value_num('source_26') := l_array_source_26(hdr_idx);
g_array_event(l_event_id).array_value_char('source_27') := l_array_source_27(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37') := l_array_source_37(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37_meaning') := l_array_source_37_meaning(hdr_idx);

--
-- initilaize the status of ae headers for diffrent balance types
-- the status is initialised to C_NOT_CREATED (2)
--
--g_array_event(l_event_id).array_value_num('actual_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('budget_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('encumbrance_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;

--
-- call api to validate and store accounting attributes for header
--

------------------------------------------------------------
-- Accrual Reversal : to get date for Standard Source (NONE)
------------------------------------------------------------
l_acc_rev_gl_date_source := NULL;

     l_rec_acct_attrs.array_acct_attr_code(1)   := 'ENCUMBRANCE_TYPE_ID';
      l_rec_acct_attrs.array_num_value(1) := g_array_event(l_event_id).array_value_num('source_19');
     l_rec_acct_attrs.array_acct_attr_code(2)   := 'GL_DATE';
      l_rec_acct_attrs.array_date_value(2) := 
xla_ae_sources_pkg.GetSystemSourceDate(
   p_source_code           => 'XLA_REFERENCE_DATE_1'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
);
     l_rec_acct_attrs.array_acct_attr_code(3)   := 'GL_TRANSFER_FLAG';
      l_rec_acct_attrs.array_char_value(3) := g_array_event(l_event_id).array_value_char('source_37');


XLA_AE_HEADER_PKG.SetHdrAcctAttrs(l_rec_acct_attrs);

XLA_AE_HEADER_PKG.SetJeCategoryName;

XLA_AE_HEADER_PKG.g_rec_header_new.array_event_type_code(hdr_idx)  := l_array_event_type(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(hdr_idx)         := l_array_event_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_entity_id(hdr_idx)        := l_array_entity_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_number(hdr_idx)     := l_array_event_number(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_target_ledger_id(hdr_idx) := p_target_ledger_id;


-- No header level analytical criteria

--
--accounting attribute enhancement, bug 3612931
--
l_trx_reversal_source := SUBSTR(NULL, 1,30);

IF NVL(l_trx_reversal_source, 'N') NOT IN ('N','Y') THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name            => 'XLA'
      ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
      ,p_token_1                 => 'ACCT_ATTR_NAME'
      ,p_value_1                 => xla_ae_sources_pkg.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
      ,p_token_2                 => 'PRODUCT_NAME'
      ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
      ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
      ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
      ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

ELSIF NVL(l_trx_reversal_source, 'N') = 'Y' THEN
   --
   -- following sets the accounting attributes needed to reverse
   -- accounting for a distributeion
   --
   xla_ae_lines_pkg.SetTrxReversalAttrs
      (p_event_id              => l_event_id
      ,p_gl_date               => XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(hdr_idx)
      ,p_trx_reversal_source   => l_trx_reversal_source);

END IF;


----------------------------------------------------------------
-- 4262811 -  update the header statuses to invalid in need be
----------------------------------------------------------------
--
XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx => hdr_idx);


--
-- Generate the accrual reversal headers
--
IF NVL(l_trx_reversal_source, 'N') = 'N' THEN



-- indicate that the accrual entry has a reversal entry
XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag(hdr_idx) := 'Y';

--
-- initialize a row for ae header
--
g_last_hdr_idx := g_last_hdr_idx + 1;
XLA_AE_HEADER_PKG.CopyHeaderInfo (p_parent_hdr_idx => hdr_idx,
                                  p_hdr_idx        => g_last_hdr_idx) ;
XLA_AE_HEADER_PKG.g_rec_header_new.array_header_num      (g_last_hdr_idx) := 1;
XLA_AE_HEADER_PKG.g_rec_header_new.array_parent_header_id(g_last_hdr_idx) :=
               XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(hdr_idx);

--
-- record the index for the reversal entry, it will be used by the journal
-- line creation
--
g_array_event(l_event_id).array_value_num('acc_rev_header_index') := g_last_hdr_idx;

--
-- Populate the GL Date and override the GL date defined in the
-- SetHdrAcctAttrs if necessary
--

              ---------------------- XLA_FIRST_DAY_NEXT_GL_PERIOD ----------------------
              XLA_AE_HEADER_PKG.g_rec_header_new.array_acc_rev_gl_date_option(g_last_hdr_idx) := 'XLA_FIRST_DAY_NEXT_GL_PERIOD';
              XLA_AE_HEADER_PKG.GetAccrualRevDate(g_last_hdr_idx
                                       ,XLA_AE_HEADER_PKG.g_rec_header_new.array_target_ledger_id(g_last_hdr_idx)
                                       ,XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(hdr_idx)
                                       ,XLA_AE_HEADER_PKG.g_rec_header_new.array_acc_rev_gl_date_option(g_last_hdr_idx));
              

--
-- Update the header status
--
XLA_AE_JOURNAL_ENTRY_PKG.updateJournalEntryStatus (p_hdr_idx => g_last_hdr_idx);



END IF;


----------------------------------------------------------------

--
-- this ends the header loop iteration for one bulk fetch
--
END LOOP;

l_first_event_id   := l_array_event_id(l_array_event_id.FIRST);
l_last_event_id    := l_array_event_id(l_array_event_id.LAST);

--
-- insert dummy rows into lines gt table that were created due to
-- transaction reversals
--
IF XLA_AE_LINES_PKG.g_rec_lines.array_ae_header_id.COUNT > 0 THEN
   l_result := XLA_AE_LINES_PKG.InsertLines;
END IF;

--
-- reset the temp_line_num for each set of events fetched from header
-- cursor rather than doing it for each new event in line cursor
-- Bug 3939231
--
xla_ae_lines_pkg.g_temp_line_num := 0;



--
OPEN line_cur(x_first_event_id  => l_first_event_id, x_last_event_id  => l_last_event_id);
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - FETCH line_cur'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
LOOP
  --
  FETCH line_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag
      , l_array_extract_line_num 
      , l_array_source_12
      , l_array_source_25
      LIMIT l_rows;

  --
  IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => '# rows extracted from line extract objects = '||TO_CHAR(line_cur%ROWCOUNT)
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
  END IF;
  --
  EXIT WHEN l_array_entity_id.count = 0;

  XLA_AE_LINES_PKG.g_rec_lines := null;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;
--
--

FOR Idx IN 1..l_array_event_id.count LOOP
   --
   -- 5648433 (move l_event_id out of IF statement)  set l_event_id to be used inside IF condition
   --
   l_event_id := l_array_event_id(idx);  -- 5648433

   --
   -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
   --

   IF NVL(xla_ae_header_pkg.g_rec_header_new.array_trx_acct_reversal_option
             (g_array_event(l_event_id).array_value_num('header_index'))
         ,'N'
         ) <> 'Y'
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is not Y '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

--
-- set the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
--
-- set event info as cache for other routines to refer event attributes
--

IF l_event_id <> NVL(l_previous_event_id, -1) THEN
   l_previous_event_id := l_event_id;

   XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
      (p_application_id           => p_application_id
      ,p_primary_ledger_id        => p_primary_ledger_id
      ,p_base_ledger_id           => p_base_ledger_id
      ,p_target_ledger_id         => p_target_ledger_id
      ,p_entity_id                => l_array_entity_id(Idx)
      ,p_legal_entity_id          => l_array_legal_entity_id(Idx)
      ,p_entity_code              => l_array_entity_code(Idx)
      ,p_transaction_num          => l_array_transaction_num(Idx)
      ,p_event_id                 => l_array_event_id(Idx)
      ,p_event_class_code         => l_array_class_code(Idx)
      ,p_event_type_code          => l_array_event_type(Idx)
      ,p_event_number             => l_array_event_number(Idx)
      ,p_event_date               => l_array_event_date(Idx)
      ,p_transaction_date         => l_array_transaction_date(Idx)
      ,p_reference_num_1          => l_array_reference_num_1(Idx)
      ,p_reference_num_2          => l_array_reference_num_2(Idx)
      ,p_reference_num_3          => l_array_reference_num_3(Idx)
      ,p_reference_num_4          => l_array_reference_num_4(Idx)
      ,p_reference_char_1         => l_array_reference_char_1(Idx)
      ,p_reference_char_2         => l_array_reference_char_2(Idx)
      ,p_reference_char_3         => l_array_reference_char_3(Idx)
      ,p_reference_char_4         => l_array_reference_char_4(Idx)
      ,p_reference_date_1         => l_array_reference_date_1(Idx)
      ,p_reference_date_2         => l_array_reference_date_2(Idx)
      ,p_reference_date_3         => l_array_reference_date_3(Idx)
      ,p_reference_date_4         => l_array_reference_date_4(Idx)
      ,p_event_created_by         => l_array_event_created_by(Idx)
      ,p_budgetary_control_flag   => l_array_budgetary_control_flag(Idx));
       --
END IF;



--
xla_ae_lines_pkg.SetExtractLine(p_extract_line => l_array_extract_line_num(Idx));

l_acct_reversal_source := SUBSTR(NULL, 1,30);

IF l_continue_with_lines THEN
   IF NVL(l_acct_reversal_source, 'N') NOT IN ('N','Y','B') THEN
      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_INVALID_REVERSAL_OPTION'
         ,p_token_1                 => 'LINE_NUMBER'
         ,p_value_1                 => l_array_extract_line_num(Idx)
         ,p_token_2                 => 'PRODUCT_NAME'
         ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
         ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
         ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

   ELSIF NVL(l_acct_reversal_source, 'N') IN ('Y','B') THEN
      --
      -- following sets the accounting attributes needed to reverse
      -- accounting for a distributeion
      --

      --
      -- 5217187
      --
      l_rec_rev_acct_attrs.array_acct_attr_code(1):= 'GL_DATE';
      l_rec_rev_acct_attrs.array_date_value(1) := XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(
                                       g_array_event(l_event_id).array_value_num('header_index'));
      --
      --

      -- No reversal code generated

      xla_ae_lines_pkg.SetAcctReversalAttrs
         (p_event_id             => l_event_id
         ,p_rec_acct_attrs       => l_rec_rev_acct_attrs
         ,p_calculate_acctd_flag => l_calculate_acctd_flag
         ,p_calculate_g_l_flag   => l_calculate_g_l_flag);
   END IF;

   IF NVL(l_acct_reversal_source, 'N') IN ('N','B') THEN
       l_actual_flag := NULL;  l_actual_gain_loss_ref := '#####';

--
AcctLineType_8 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_2 => g_array_event(l_event_id).array_value_char('source_2')
 , p_source_7 => g_array_event(l_event_id).array_value_num('source_7')
 , p_source_8 => g_array_event(l_event_id).array_value_char('source_8')
 , p_source_9 => g_array_event(l_event_id).array_value_char('source_9')
 , p_source_11 => g_array_event(l_event_id).array_value_num('source_11')
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_14 => g_array_event(l_event_id).array_value_num('source_14')
 , p_source_15 => g_array_event(l_event_id).array_value_num('source_15')
 , p_source_16 => g_array_event(l_event_id).array_value_char('source_16')
 , p_source_17 => g_array_event(l_event_id).array_value_num('source_17')
 , p_source_19 => g_array_event(l_event_id).array_value_num('source_19')
 , p_source_25 => l_array_source_25(Idx)
 , p_source_26 => g_array_event(l_event_id).array_value_num('source_26')
 , p_source_27 => g_array_event(l_event_id).array_value_char('source_27')
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--

      -- only execute it if calculate g/l flag is yes, and primary or secondary ledger
      -- or secondary ledger that has different currency with primary
      -- or alc that is calculated by sla
      IF (((l_calculate_g_l_flag = 'Y' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> 'ALC') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in ('ALC', 'SECONDARY') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='Y'))

--      IF((l_calculate_g_l_flag='Y' or XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id <>
--                    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id)
          AND (l_actual_flag = 'A')) THEN
        XLA_AE_LINES_PKG.CreateGainOrLossLines(
          p_event_id         => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_application_id   => p_application_id
         ,p_amb_context_code => 'DEFAULT'
         ,p_entity_code      => xla_ae_journal_entry_pkg.g_cache_event.entity_code
         ,p_event_class_code => C_EVENT_CLASS_CODE
         ,p_event_type_code  => C_EVENT_TYPE_CODE
         
         ,p_gain_ccid        => -1
         ,p_loss_ccid        => -1

         ,p_actual_flag      => l_actual_flag
         ,p_enc_flag         => null
         ,p_actual_g_l_ref   => l_actual_gain_loss_ref
         ,p_enc_g_l_ref      => null
         );
      END IF;
   END IF;
END IF;

   ELSE
      --
      -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is Y'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

END LOOP;
l_result := XLA_AE_LINES_PKG.InsertLines ;
end loop;
close line_cur;


--
-- insert headers into xla_ae_headers_gt table
--
l_result := XLA_AE_HEADER_PKG.InsertHeaders ;

-- insert into errors table here.

END LOOP;

--
-- 4865292
--
-- Compare g_hdr_extract_count with event count in
-- CreateHeadersAndLines.
--
g_hdr_extract_count := g_hdr_extract_count + header_cur%ROWCOUNT;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace (p_msg     => '# rows extracted from header extract objects '
                    || ' (running total): '
                    || g_hdr_extract_count
         ,p_level   => C_LEVEL_STATEMENT
         ,p_module  => l_log_module);
END IF;

CLOSE header_cur;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of EventClass_17'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   
IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;

   
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

   RAISE;

WHEN NO_DATA_FOUND THEN

IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

FOR header_record IN header_cur
LOOP
    l_array_header_events(header_record.event_id) := header_record.event_id;
END LOOP;

l_first_event_id := l_array_header_events(l_array_header_events.FIRST);
l_last_event_id := l_array_header_events(l_array_header_events.LAST);

fnd_file.put_line(fnd_file.LOG, '                    ');
fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, 'EVENT CLASS CODE = ' || C_EVENT_CLASS_CODE );
fnd_file.put_line(fnd_file.LOG, 'The following events are present in the line extract but MISSING in the header extract: ');

FOR line_record IN line_cur(l_first_event_id, l_last_event_id)
LOOP
	IF (NOT l_array_header_events.EXISTS(line_record.event_id))  AND (NOT l_array_duplicate_checker.EXISTS(line_record.event_id)) THEN
	fnd_file.put_line(fnd_file.log, 'Event_id = ' || line_record.event_id);
        l_array_duplicate_checker(line_record.event_id) := line_record.event_id;
	END IF;
END LOOP;

fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, '                    ');


xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_17');


WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_17');
END EventClass_17;
--

---------------------------------------
--
-- PRIVATE PROCEDURE
--         insert_sources_18
--
----------------------------------------
--
PROCEDURE insert_sources_18(
                                p_target_ledger_id       IN NUMBER
                              , p_language               IN VARCHAR2
                              , p_sla_ledger_id          IN NUMBER
                              , p_pad_start_date         IN DATE
                              , p_pad_end_date           IN DATE
                         )
IS

C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'PURCHASE_ORDER_ALL';
C_EVENT_CLASS_CODE   CONSTANT  VARCHAR2(30) := 'PURCHASE_ORDER';
p_apps_owner                   VARCHAR2(30);
l_log_module                   VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.insert_sources_18';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of insert_sources_18'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

-- select APPS owner
SELECT oracle_username
  INTO p_apps_owner
  FROM fnd_oracle_userid
 WHERE read_only_flag = 'U'
;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_target_ledger_id = '||p_target_ledger_id||
                        ' - p_language = '||p_language||
                        ' - p_sla_ledger_id  = '||p_sla_ledger_id ||
                        ' - p_pad_start_date = '||TO_CHAR(p_pad_start_date)||
                        ' - p_pad_end_date = '||TO_CHAR(p_pad_end_date)||
                        ' - p_apps_owner = '||TO_CHAR(p_apps_owner)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;


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
               WHEN 1 THEN 'PO_HEADERS_REF_V' 
                WHEN 2 THEN 'PO_DISTS_REF_V' 
                WHEN 3 THEN 'CST_XLA_INV_ORG_PARAMS_REF_V' 
                WHEN 4 THEN 'CST_XLA_INV_REF_V' 
                WHEN 5 THEN 'CST_XLA_INV_REF_V' 
                WHEN 6 THEN 'CST_XLA_INV_REF_V' 
                WHEN 7 THEN 'CST_XLA_INV_REF_V' 
                WHEN 8 THEN 'CST_XLA_INV_REF_V' 
                WHEN 9 THEN 'CST_XLA_INV_HEADERS_V' 
                WHEN 10 THEN 'PO_DISTS_REF_V' 
                WHEN 11 THEN 'CST_XLA_INV_REF_V' 
                WHEN 12 THEN 'CST_XLA_INV_REF_V' 
                WHEN 13 THEN 'PSA_CST_XLA_UPG_V' 
                WHEN 14 THEN 'PO_HEADERS_REF_V' 
                WHEN 15 THEN 'CST_XLA_INV_HEADERS_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'HEADER' 
                WHEN 2 THEN 'HEADER' 
                WHEN 3 THEN 'HEADER' 
                WHEN 4 THEN 'HEADER' 
                WHEN 5 THEN 'HEADER' 
                WHEN 6 THEN 'HEADER' 
                WHEN 7 THEN 'HEADER' 
                WHEN 8 THEN 'HEADER' 
                WHEN 9 THEN 'HEADER' 
                WHEN 10 THEN 'HEADER' 
                WHEN 11 THEN 'HEADER' 
                WHEN 12 THEN 'HEADER' 
                WHEN 13 THEN 'HEADER' 
                WHEN 14 THEN 'HEADER' 
                WHEN 15 THEN 'HEADER' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '201' 
                WHEN 2 THEN '201' 
                WHEN 3 THEN '707' 
                WHEN 4 THEN '707' 
                WHEN 5 THEN '707' 
                WHEN 6 THEN '707' 
                WHEN 7 THEN '707' 
                WHEN 8 THEN '707' 
                WHEN 9 THEN '707' 
                WHEN 10 THEN '201' 
                WHEN 11 THEN '707' 
                WHEN 12 THEN '707' 
                WHEN 13 THEN '707' 
                WHEN 14 THEN '201' 
                WHEN 15 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'PURCH_ENCUMBRANCE_FLAG' 
                WHEN 2 THEN 'RESERVED_FLAG' 
                WHEN 3 THEN 'ENCUMBRANCE_REVERSAL_FLAG' 
                WHEN 4 THEN 'APPLIED_TO_APPL_ID' 
                WHEN 5 THEN 'APPLIED_TO_DIST_LINK_TYPE' 
                WHEN 6 THEN 'APPLIED_TO_ENTITY_CODE' 
                WHEN 7 THEN 'TXN_PO_DISTRIBUTION_ID' 
                WHEN 8 THEN 'APPLIED_TO_PO_DOC_ID' 
                WHEN 9 THEN 'DISTRIBUTION_TYPE' 
                WHEN 10 THEN 'PO_BUDGET_ACCOUNT' 
                WHEN 11 THEN 'ENCUM_REVERSAL_AMOUNT_ENTERED' 
                WHEN 12 THEN 'ENCUMBRANCE_REVERSAL_AMOUNT' 
                WHEN 13 THEN 'CST_ENCUM_UPG_OPTION' 
                WHEN 14 THEN 'PURCH_ENCUMBRANCE_TYPE_ID' 
                WHEN 15 THEN 'TRANSFER_TO_GL_INDICATOR' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(h6.PURCH_ENCUMBRANCE_FLAG)
                WHEN 2 THEN TO_CHAR(h5.RESERVED_FLAG)
                WHEN 3 THEN TO_CHAR(h3.ENCUMBRANCE_REVERSAL_FLAG)
                WHEN 4 THEN TO_CHAR(h4.APPLIED_TO_APPL_ID)
                WHEN 5 THEN TO_CHAR(h4.APPLIED_TO_DIST_LINK_TYPE)
                WHEN 6 THEN TO_CHAR(h4.APPLIED_TO_ENTITY_CODE)
                WHEN 7 THEN TO_CHAR(h4.TXN_PO_DISTRIBUTION_ID)
                WHEN 8 THEN TO_CHAR(h4.APPLIED_TO_PO_DOC_ID)
                WHEN 9 THEN TO_CHAR(h1.DISTRIBUTION_TYPE)
                WHEN 10 THEN TO_CHAR(h5.PO_BUDGET_ACCOUNT)
                WHEN 11 THEN TO_CHAR(h4.ENCUM_REVERSAL_AMOUNT_ENTERED)
                WHEN 12 THEN TO_CHAR(h4.ENCUMBRANCE_REVERSAL_AMOUNT)
                WHEN 13 THEN TO_CHAR(h7.CST_ENCUM_UPG_OPTION)
                WHEN 14 THEN TO_CHAR(h6.PURCH_ENCUMBRANCE_TYPE_ID)
                WHEN 15 THEN TO_CHAR(h1.TRANSFER_TO_GL_INDICATOR)
                
                ELSE null
              END                           source_value
            , CASE r
                WHEN 9 THEN fvl13.meaning
                WHEN 15 THEN fvl37.meaning
                
                ELSE null
              END               source_meaning
         FROM xla_events_gt     xet  
      , CST_XLA_INV_HEADERS_V  h1
      , CST_XLA_INV_ORG_PARAMS_REF_V  h3
      , CST_XLA_INV_REF_V  h4
      , PO_DISTS_REF_V  h5
      , PO_HEADERS_REF_V  h6
      , PSA_CST_XLA_UPG_V  h7
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
             ,(select rownum r from all_objects where rownum <= 15 and owner = p_apps_owner)
         WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
           AND xet.event_class_code = C_EVENT_CLASS_CODE
              AND h1.event_id = xet.event_id
 AND h3.inv_organization_id  (+) = h1.organization_id AND h4.ref_transaction_id = h1.transaction_id AND h4.txn_po_header_id = h5.po_header_id  (+)  and h4.txn_po_distribution_id = h5.po_distribution_id (+)  AND h4.txn_po_header_id = h6.po_header_id (+)  AND h4.rcv_transaction_id = h7.transaction_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of header sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--



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
            , l2.line_number                 line_number
            , CASE r
               WHEN 1 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 2 THEN 'CST_XLA_INV_LINES_V' 
                WHEN 3 THEN 'CST_XLA_INV_LINES_V' 
                
               ELSE null
              END                           object_name
            , CASE r
                WHEN 1 THEN 'LINE' 
                WHEN 2 THEN 'LINE' 
                WHEN 3 THEN 'LINE' 
                
                ELSE null
              END                           object_type_code
            , CASE r
                WHEN 1 THEN '707' 
                WHEN 2 THEN '707' 
                WHEN 3 THEN '707' 
                
                ELSE null
              END                           source_application_id
            , 'S'             source_type_code
            , CASE r
                WHEN 1 THEN 'ACCOUNTING_LINE_TYPE_CODE' 
                WHEN 2 THEN 'DISTRIBUTION_IDENTIFIER' 
                WHEN 3 THEN 'CURRENCY_CODE' 
                
                ELSE null
              END                           source_code
            , CASE r
                WHEN 1 THEN TO_CHAR(l2.ACCOUNTING_LINE_TYPE_CODE)
                WHEN 2 THEN TO_CHAR(l2.DISTRIBUTION_IDENTIFIER)
                WHEN 3 THEN TO_CHAR(l2.CURRENCY_CODE)
                
                ELSE null
              END                           source_value
            , null              source_meaning
         FROM  xla_events_gt     xet  
        , CST_XLA_INV_LINES_V  l2
            , (select rownum r from all_objects where rownum <= 3 and owner = p_apps_owner)
        WHERE xet.event_date between p_pad_start_date AND p_pad_end_date
          AND xet.event_class_code = C_EVENT_CLASS_CODE
            AND l2.event_id          = xet.event_id

)
;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'number of line sources inserted = '||SQL%ROWCOUNT
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of insert_sources_18'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
      END IF;
      RAISE;
  WHEN OTHERS THEN
      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
       END IF;
       xla_exceptions_pkg.raise_message
           (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.insert_sources_18');
END insert_sources_18;
--

---------------------------------------
--
-- PRIVATE FUNCTION
--         EventClass_18
--
----------------------------------------
--
FUNCTION EventClass_18
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_target_ledger_id       IN NUMBER
       ,p_language               IN VARCHAR2
       ,p_currency_code          IN VARCHAR2
       ,p_sla_ledger_id          IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN BOOLEAN IS
--
C_EVENT_TYPE_CODE    CONSTANT  VARCHAR2(30)  := 'PURCHASE_ORDER_ALL';
C_EVENT_CLASS_CODE    CONSTANT  VARCHAR2(30) := 'PURCHASE_ORDER';

l_calculate_acctd_flag   VARCHAR2(1) :='N';
l_calculate_g_l_flag     VARCHAR2(1) :='N';
--
l_array_legal_entity_id                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_id                      XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_entity_code                    XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_transaction_num                XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_event_id                       XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_class_code                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_type                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_event_number                   XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_event_date                     XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_transaction_date               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_num_1                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_2                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_3                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_num_4                XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;
l_array_reference_char_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_char_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V240L;
l_array_reference_date_1               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_2               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_3               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_reference_date_4               XLA_AE_JOURNAL_ENTRY_PKG.t_array_Date;
l_array_event_created_by               XLA_AE_JOURNAL_ENTRY_PKG.t_array_V100L;
l_array_budgetary_control_flag         XLA_AE_JOURNAL_ENTRY_PKG.t_array_V30L;
l_array_header_events                  XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added
l_array_duplicate_checker              XLA_AE_JOURNAL_ENTRY_PKG.t_array_Num;  --added

l_event_id                             NUMBER;
l_previous_event_id                    NUMBER;
l_first_event_id                       NUMBER;
l_last_event_id                        NUMBER;

l_rec_acct_attrs                       XLA_AE_HEADER_PKG.t_rec_acct_attrs;
l_rec_rev_acct_attrs                   XLA_AE_LINES_PKG.t_rec_acct_attrs;
--
--
l_result                    BOOLEAN := TRUE;
l_rows                      NUMBER  := 1000;
l_event_type_name           VARCHAR2(80) := 'All';
l_event_class_name          VARCHAR2(80) := 'PO Delivery into Inventory';
l_description               VARCHAR2(4000);
l_transaction_reversal      NUMBER;
l_ae_header_id              NUMBER;
l_array_extract_line_num    xla_ae_journal_entry_pkg.t_array_Num;
l_log_module                VARCHAR2(240);
--
l_acct_reversal_source      VARCHAR2(30);
l_trx_reversal_source       VARCHAR2(30);

l_continue_with_lines       BOOLEAN := TRUE;
--
l_acc_rev_gl_date_source    DATE;                      -- 4262811
--
type t_array_event_id is table of number index by binary_integer;

l_rec_array_event                    t_rec_array_event;
l_null_rec_array_event               t_rec_array_event;
l_array_ae_header_id                 xla_number_array_type;
l_actual_flag                        VARCHAR2(1) := NULL;
l_actual_gain_loss_ref               VARCHAR2(30) := '#####';
l_balance_type_code                  VARCHAR2(1) :=NULL;
l_gain_or_loss_ref                   VARCHAR2(30) :=NULL;

--
TYPE t_array_lookup_meaning IS TABLE OF fnd_lookup_values.meaning%TYPE INDEX BY BINARY_INTEGER;
--

TYPE t_array_source_2 IS TABLE OF PO_HEADERS_REF_V.PURCH_ENCUMBRANCE_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_3 IS TABLE OF PO_DISTS_REF_V.RESERVED_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_4 IS TABLE OF CST_XLA_INV_ORG_PARAMS_REF_V.ENCUMBRANCE_REVERSAL_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_7 IS TABLE OF CST_XLA_INV_REF_V.APPLIED_TO_APPL_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_8 IS TABLE OF CST_XLA_INV_REF_V.APPLIED_TO_DIST_LINK_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_9 IS TABLE OF CST_XLA_INV_REF_V.APPLIED_TO_ENTITY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_10 IS TABLE OF CST_XLA_INV_REF_V.TXN_PO_DISTRIBUTION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_11 IS TABLE OF CST_XLA_INV_REF_V.APPLIED_TO_PO_DOC_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_13 IS TABLE OF CST_XLA_INV_HEADERS_V.DISTRIBUTION_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_14 IS TABLE OF PO_DISTS_REF_V.PO_BUDGET_ACCOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_15 IS TABLE OF CST_XLA_INV_REF_V.ENCUM_REVERSAL_AMOUNT_ENTERED%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_17 IS TABLE OF CST_XLA_INV_REF_V.ENCUMBRANCE_REVERSAL_AMOUNT%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_18 IS TABLE OF PSA_CST_XLA_UPG_V.CST_ENCUM_UPG_OPTION%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_19 IS TABLE OF PO_HEADERS_REF_V.PURCH_ENCUMBRANCE_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_37 IS TABLE OF CST_XLA_INV_HEADERS_V.TRANSFER_TO_GL_INDICATOR%TYPE INDEX BY BINARY_INTEGER;

TYPE t_array_source_6 IS TABLE OF CST_XLA_INV_LINES_V.ACCOUNTING_LINE_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_12 IS TABLE OF CST_XLA_INV_LINES_V.DISTRIBUTION_IDENTIFIER%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_source_16 IS TABLE OF CST_XLA_INV_LINES_V.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;

l_array_source_2              t_array_source_2;
l_array_source_3              t_array_source_3;
l_array_source_4              t_array_source_4;
l_array_source_7              t_array_source_7;
l_array_source_8              t_array_source_8;
l_array_source_9              t_array_source_9;
l_array_source_10              t_array_source_10;
l_array_source_11              t_array_source_11;
l_array_source_13              t_array_source_13;
l_array_source_13_meaning      t_array_lookup_meaning;
l_array_source_14              t_array_source_14;
l_array_source_15              t_array_source_15;
l_array_source_17              t_array_source_17;
l_array_source_18              t_array_source_18;
l_array_source_19              t_array_source_19;
l_array_source_37              t_array_source_37;
l_array_source_37_meaning      t_array_lookup_meaning;

l_array_source_6      t_array_source_6;
l_array_source_12      t_array_source_12;
l_array_source_16      t_array_source_16;

--
CURSOR header_cur
IS
SELECT /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: PURCHASE_ORDER
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
  , h6.PURCH_ENCUMBRANCE_FLAG    source_2
  , h5.RESERVED_FLAG    source_3
  , h3.ENCUMBRANCE_REVERSAL_FLAG    source_4
  , h4.APPLIED_TO_APPL_ID    source_7
  , h4.APPLIED_TO_DIST_LINK_TYPE    source_8
  , h4.APPLIED_TO_ENTITY_CODE    source_9
  , h4.TXN_PO_DISTRIBUTION_ID    source_10
  , h4.APPLIED_TO_PO_DOC_ID    source_11
  , h1.DISTRIBUTION_TYPE    source_13
  , fvl13.meaning   source_13_meaning
  , h5.PO_BUDGET_ACCOUNT    source_14
  , h4.ENCUM_REVERSAL_AMOUNT_ENTERED    source_15
  , h4.ENCUMBRANCE_REVERSAL_AMOUNT    source_17
  , h7.CST_ENCUM_UPG_OPTION    source_18
  , h6.PURCH_ENCUMBRANCE_TYPE_ID    source_19
  , h1.TRANSFER_TO_GL_INDICATOR    source_37
  , fvl37.meaning   source_37_meaning
  FROM xla_events_gt     xet 
  , CST_XLA_INV_HEADERS_V  h1
  , CST_XLA_INV_ORG_PARAMS_REF_V  h3
  , CST_XLA_INV_REF_V  h4
  , PO_DISTS_REF_V  h5
  , PO_HEADERS_REF_V  h6
  , PSA_CST_XLA_UPG_V  h7
  , fnd_lookup_values    fvl13
  , fnd_lookup_values    fvl37
 WHERE xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'  AND h1.event_id = xet.event_id
 AND h3.INV_ORGANIZATION_ID  (+) = h1.ORGANIZATION_ID AND h4.ref_transaction_id = h1.transaction_id AND h4.txn_po_header_id = h5.po_header_id  (+)  AND h4.txn_po_distribution_id = h5.po_distribution_id (+)  AND h4.txn_po_header_id = h6.po_header_id (+)  AND h4.rcv_transaction_id = h7.transaction_id (+)    AND fvl13.lookup_type(+)         = 'CST_DISTRIBUTION_TYPE'
  AND fvl13.lookup_code(+)         = h1.DISTRIBUTION_TYPE
  AND fvl13.view_application_id(+) = 700
  AND fvl13.language(+)            = USERENV('LANG')
     AND fvl37.lookup_type(+)         = 'YES_NO'
  AND fvl37.lookup_code(+)         = h1.TRANSFER_TO_GL_INDICATOR
  AND fvl37.view_application_id(+) = 0
  AND fvl37.language(+)            = USERENV('LANG')
  
 ORDER BY event_id
;


--
CURSOR line_cur (x_first_event_id    in number, x_last_event_id    in number)
IS
SELECT  /*+ leading(xet) cardinality(xet,1) */
-- Event Class Code: PURCHASE_ORDER
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
 , l2.LINE_NUMBER  
  , l2.ACCOUNTING_LINE_TYPE_CODE    source_6
  , l2.DISTRIBUTION_IDENTIFIER    source_12
  , l2.CURRENCY_CODE    source_16
  FROM xla_events_gt     xet 
  , CST_XLA_INV_LINES_V  l2
 WHERE xet.event_id between x_first_event_id and x_last_event_id
   and xet.event_date between p_pad_start_date and p_pad_end_date
   and xet.event_class_code = C_EVENT_CLASS_CODE
   and xet.event_status_code <> 'N'   AND l2.event_id      = xet.event_id
;

--
BEGIN
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.EventClass_18';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of EventClass_18'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'p_application_id = '||p_application_id||
                     ' - p_base_ledger_id = '||p_base_ledger_id||
                     ' - p_target_ledger_id  = '||p_target_ledger_id||
                     ' - p_language = '||p_language||
                     ' - p_currency_code = '||p_currency_code||
                     ' - p_sla_ledger_id = '||p_sla_ledger_id
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
-- initialze arrays
--
g_array_event.DELETE;
l_rec_array_event := l_null_rec_array_event;
--
--------------------------------------
-- 4262811 Initialze MPA Line Number
--------------------------------------
XLA_AE_HEADER_PKG.g_mpa_line_num := 0;

--

--
OPEN header_cur;
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
   (p_msg      => 'SQL - FETCH header_cur'
   ,p_level    => C_LEVEL_STATEMENT
   ,p_module   => l_log_module);
END IF;
--
LOOP
FETCH header_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag 
      , l_array_source_2
      , l_array_source_3
      , l_array_source_4
      , l_array_source_7
      , l_array_source_8
      , l_array_source_9
      , l_array_source_10
      , l_array_source_11
      , l_array_source_13
      , l_array_source_13_meaning
      , l_array_source_14
      , l_array_source_15
      , l_array_source_17
      , l_array_source_18
      , l_array_source_19
      , l_array_source_37
      , l_array_source_37_meaning
      LIMIT l_rows;
--
IF (C_LEVEL_EVENT >= g_log_level) THEN
   trace
   (p_msg      => '# rows extracted from header extract objects = '||TO_CHAR(header_cur%ROWCOUNT)
   ,p_level    => C_LEVEL_EVENT
   ,p_module   => l_log_module);
END IF;
--
EXIT WHEN l_array_entity_id.COUNT = 0;

-- initialize arrays
XLA_AE_HEADER_PKG.g_rec_header_new        := NULL;
XLA_AE_LINES_PKG.g_rec_lines              := NULL;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;


-- 4262811 - when creating Accrual Reversal or MPA, use g_last_hdr_idx to increment for next header id
g_last_hdr_idx := l_array_event_id.LAST;
--
-- loop for the headers. Each iteration is for each header extract row
-- fetched in header cursor
--
FOR hdr_idx IN l_array_event_id.FIRST .. l_array_event_id.LAST LOOP

--
-- set event info as cache for other routines to refer event attributes
--
XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
   (p_application_id           => p_application_id
   ,p_primary_ledger_id        => p_primary_ledger_id
   ,p_base_ledger_id           => p_base_ledger_id
   ,p_target_ledger_id         => p_target_ledger_id
   ,p_entity_id                => l_array_entity_id(hdr_idx)
   ,p_legal_entity_id          => l_array_legal_entity_id(hdr_idx)
   ,p_entity_code              => l_array_entity_code(hdr_idx)
   ,p_transaction_num          => l_array_transaction_num(hdr_idx)
   ,p_event_id                 => l_array_event_id(hdr_idx)
   ,p_event_class_code         => l_array_class_code(hdr_idx)
   ,p_event_type_code          => l_array_event_type(hdr_idx)
   ,p_event_number             => l_array_event_number(hdr_idx)
   ,p_event_date               => l_array_event_date(hdr_idx)
   ,p_transaction_date         => l_array_transaction_date(hdr_idx)
   ,p_reference_num_1          => l_array_reference_num_1(hdr_idx)
   ,p_reference_num_2          => l_array_reference_num_2(hdr_idx)
   ,p_reference_num_3          => l_array_reference_num_3(hdr_idx)
   ,p_reference_num_4          => l_array_reference_num_4(hdr_idx)
   ,p_reference_char_1         => l_array_reference_char_1(hdr_idx)
   ,p_reference_char_2         => l_array_reference_char_2(hdr_idx)
   ,p_reference_char_3         => l_array_reference_char_3(hdr_idx)
   ,p_reference_char_4         => l_array_reference_char_4(hdr_idx)
   ,p_reference_date_1         => l_array_reference_date_1(hdr_idx)
   ,p_reference_date_2         => l_array_reference_date_2(hdr_idx)
   ,p_reference_date_3         => l_array_reference_date_3(hdr_idx)
   ,p_reference_date_4         => l_array_reference_date_4(hdr_idx)
   ,p_event_created_by         => l_array_event_created_by(hdr_idx)
   ,p_budgetary_control_flag   => l_array_budgetary_control_flag(hdr_idx));

--
-- set the status of entry to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status    := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;

--
-- initialize a row for ae header
--
XLA_AE_HEADER_PKG.InitHeader(hdr_idx);

l_event_id := l_array_event_id(hdr_idx);

--
-- storing the hdr_idx for event. May be used by line cursor.
--
g_array_event(l_event_id).array_value_num('header_index') := hdr_idx;

--
-- store sources from header extract. This can be improved to
-- store only those sources from header extract that may be used in lines
--

g_array_event(l_event_id).array_value_char('source_2') := l_array_source_2(hdr_idx);
g_array_event(l_event_id).array_value_char('source_3') := l_array_source_3(hdr_idx);
g_array_event(l_event_id).array_value_char('source_4') := l_array_source_4(hdr_idx);
g_array_event(l_event_id).array_value_num('source_7') := l_array_source_7(hdr_idx);
g_array_event(l_event_id).array_value_char('source_8') := l_array_source_8(hdr_idx);
g_array_event(l_event_id).array_value_char('source_9') := l_array_source_9(hdr_idx);
g_array_event(l_event_id).array_value_num('source_10') := l_array_source_10(hdr_idx);
g_array_event(l_event_id).array_value_num('source_11') := l_array_source_11(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13') := l_array_source_13(hdr_idx);
g_array_event(l_event_id).array_value_char('source_13_meaning') := l_array_source_13_meaning(hdr_idx);
g_array_event(l_event_id).array_value_num('source_14') := l_array_source_14(hdr_idx);
g_array_event(l_event_id).array_value_num('source_15') := l_array_source_15(hdr_idx);
g_array_event(l_event_id).array_value_num('source_17') := l_array_source_17(hdr_idx);
g_array_event(l_event_id).array_value_char('source_18') := l_array_source_18(hdr_idx);
g_array_event(l_event_id).array_value_num('source_19') := l_array_source_19(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37') := l_array_source_37(hdr_idx);
g_array_event(l_event_id).array_value_char('source_37_meaning') := l_array_source_37_meaning(hdr_idx);

--
-- initilaize the status of ae headers for diffrent balance types
-- the status is initialised to C_NOT_CREATED (2)
--
--g_array_event(l_event_id).array_value_num('actual_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('budget_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;
--g_array_event(l_event_id).array_value_num('encumbrance_je_status') := XLA_AE_JOURNAL_ENTRY_PKG.C_NOT_CREATED;

--
-- call api to validate and store accounting attributes for header
--

------------------------------------------------------------
-- Accrual Reversal : to get date for Standard Source (NONE)
------------------------------------------------------------
l_acc_rev_gl_date_source := NULL;

     l_rec_acct_attrs.array_acct_attr_code(1)   := 'ENCUMBRANCE_TYPE_ID';
      l_rec_acct_attrs.array_num_value(1) := g_array_event(l_event_id).array_value_num('source_19');
     l_rec_acct_attrs.array_acct_attr_code(2)   := 'GL_DATE';
      l_rec_acct_attrs.array_date_value(2) := 
xla_ae_sources_pkg.GetSystemSourceDate(
   p_source_code           => 'XLA_REFERENCE_DATE_1'
 , p_source_type_code      => 'Y'
 , p_source_application_id =>  602
);
     l_rec_acct_attrs.array_acct_attr_code(3)   := 'GL_TRANSFER_FLAG';
      l_rec_acct_attrs.array_char_value(3) := g_array_event(l_event_id).array_value_char('source_37');


XLA_AE_HEADER_PKG.SetHdrAcctAttrs(l_rec_acct_attrs);

XLA_AE_HEADER_PKG.SetJeCategoryName;

XLA_AE_HEADER_PKG.g_rec_header_new.array_event_type_code(hdr_idx)  := l_array_event_type(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(hdr_idx)         := l_array_event_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_entity_id(hdr_idx)        := l_array_entity_id(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_event_number(hdr_idx)     := l_array_event_number(hdr_idx);
XLA_AE_HEADER_PKG.g_rec_header_new.array_target_ledger_id(hdr_idx) := p_target_ledger_id;


-- No header level analytical criteria

--
--accounting attribute enhancement, bug 3612931
--
l_trx_reversal_source := SUBSTR(NULL, 1,30);

IF NVL(l_trx_reversal_source, 'N') NOT IN ('N','Y') THEN
   xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

   xla_accounting_err_pkg.build_message
      (p_appli_s_name            => 'XLA'
      ,p_msg_name                => 'XLA_AP_INVALID_HDR_ATTR'
      ,p_token_1                 => 'ACCT_ATTR_NAME'
      ,p_value_1                 => xla_ae_sources_pkg.GetAccountingSourceName('TRX_ACCT_REVERSAL_OPTION')
      ,p_token_2                 => 'PRODUCT_NAME'
      ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
      ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
      ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
      ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

ELSIF NVL(l_trx_reversal_source, 'N') = 'Y' THEN
   --
   -- following sets the accounting attributes needed to reverse
   -- accounting for a distributeion
   --
   xla_ae_lines_pkg.SetTrxReversalAttrs
      (p_event_id              => l_event_id
      ,p_gl_date               => XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(hdr_idx)
      ,p_trx_reversal_source   => l_trx_reversal_source);

END IF;


----------------------------------------------------------------
-- 4262811 -  update the header statuses to invalid in need be
----------------------------------------------------------------
--
XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx => hdr_idx);


  -----------------------------------------------
  -- No accrual reversal for the event class/type
  -----------------------------------------------
----------------------------------------------------------------

--
-- this ends the header loop iteration for one bulk fetch
--
END LOOP;

l_first_event_id   := l_array_event_id(l_array_event_id.FIRST);
l_last_event_id    := l_array_event_id(l_array_event_id.LAST);

--
-- insert dummy rows into lines gt table that were created due to
-- transaction reversals
--
IF XLA_AE_LINES_PKG.g_rec_lines.array_ae_header_id.COUNT > 0 THEN
   l_result := XLA_AE_LINES_PKG.InsertLines;
END IF;

--
-- reset the temp_line_num for each set of events fetched from header
-- cursor rather than doing it for each new event in line cursor
-- Bug 3939231
--
xla_ae_lines_pkg.g_temp_line_num := 0;



--
OPEN line_cur(x_first_event_id  => l_first_event_id, x_last_event_id  => l_last_event_id);
--
--
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'SQL - FETCH line_cur'
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;
--
--
LOOP
  --
  FETCH line_cur BULK COLLECT INTO
        l_array_entity_id
      , l_array_legal_entity_id
      , l_array_entity_code
      , l_array_transaction_num
      , l_array_event_id
      , l_array_class_code
      , l_array_event_type
      , l_array_event_number
      , l_array_event_date
      , l_array_transaction_date
      , l_array_reference_num_1
      , l_array_reference_num_2
      , l_array_reference_num_3
      , l_array_reference_num_4
      , l_array_reference_char_1
      , l_array_reference_char_2
      , l_array_reference_char_3
      , l_array_reference_char_4
      , l_array_reference_date_1
      , l_array_reference_date_2
      , l_array_reference_date_3
      , l_array_reference_date_4
      , l_array_event_created_by
      , l_array_budgetary_control_flag
      , l_array_extract_line_num 
      , l_array_source_6
      , l_array_source_12
      , l_array_source_16
      LIMIT l_rows;

  --
  IF (C_LEVEL_EVENT >= g_log_level) THEN
            trace
               (p_msg      => '# rows extracted from line extract objects = '||TO_CHAR(line_cur%ROWCOUNT)
               ,p_level    => C_LEVEL_EVENT
               ,p_module   => l_log_module);
  END IF;
  --
  EXIT WHEN l_array_entity_id.count = 0;

  XLA_AE_LINES_PKG.g_rec_lines := null;

--
-- Bug 4458708
--
XLA_AE_LINES_PKG.g_LineNumber := 0;
--
--

FOR Idx IN 1..l_array_event_id.count LOOP
   --
   -- 5648433 (move l_event_id out of IF statement)  set l_event_id to be used inside IF condition
   --
   l_event_id := l_array_event_id(idx);  -- 5648433

   --
   -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
   --

   IF NVL(xla_ae_header_pkg.g_rec_header_new.array_trx_acct_reversal_option
             (g_array_event(l_event_id).array_value_num('header_index'))
         ,'N'
         ) <> 'Y'
   THEN
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is not Y '
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;

--
-- set the XLA_AE_JOURNAL_ENTRY_PKG.g_global_status to C_VALID (0)
--
XLA_AE_JOURNAL_ENTRY_PKG.g_global_status := XLA_AE_JOURNAL_ENTRY_PKG.C_VALID;
--
-- set event info as cache for other routines to refer event attributes
--

IF l_event_id <> NVL(l_previous_event_id, -1) THEN
   l_previous_event_id := l_event_id;

   XLA_AE_JOURNAL_ENTRY_PKG.set_event_info
      (p_application_id           => p_application_id
      ,p_primary_ledger_id        => p_primary_ledger_id
      ,p_base_ledger_id           => p_base_ledger_id
      ,p_target_ledger_id         => p_target_ledger_id
      ,p_entity_id                => l_array_entity_id(Idx)
      ,p_legal_entity_id          => l_array_legal_entity_id(Idx)
      ,p_entity_code              => l_array_entity_code(Idx)
      ,p_transaction_num          => l_array_transaction_num(Idx)
      ,p_event_id                 => l_array_event_id(Idx)
      ,p_event_class_code         => l_array_class_code(Idx)
      ,p_event_type_code          => l_array_event_type(Idx)
      ,p_event_number             => l_array_event_number(Idx)
      ,p_event_date               => l_array_event_date(Idx)
      ,p_transaction_date         => l_array_transaction_date(Idx)
      ,p_reference_num_1          => l_array_reference_num_1(Idx)
      ,p_reference_num_2          => l_array_reference_num_2(Idx)
      ,p_reference_num_3          => l_array_reference_num_3(Idx)
      ,p_reference_num_4          => l_array_reference_num_4(Idx)
      ,p_reference_char_1         => l_array_reference_char_1(Idx)
      ,p_reference_char_2         => l_array_reference_char_2(Idx)
      ,p_reference_char_3         => l_array_reference_char_3(Idx)
      ,p_reference_char_4         => l_array_reference_char_4(Idx)
      ,p_reference_date_1         => l_array_reference_date_1(Idx)
      ,p_reference_date_2         => l_array_reference_date_2(Idx)
      ,p_reference_date_3         => l_array_reference_date_3(Idx)
      ,p_reference_date_4         => l_array_reference_date_4(Idx)
      ,p_event_created_by         => l_array_event_created_by(Idx)
      ,p_budgetary_control_flag   => l_array_budgetary_control_flag(Idx));
       --
END IF;



--
xla_ae_lines_pkg.SetExtractLine(p_extract_line => l_array_extract_line_num(Idx));

l_acct_reversal_source := SUBSTR(NULL, 1,30);

IF l_continue_with_lines THEN
   IF NVL(l_acct_reversal_source, 'N') NOT IN ('N','Y','B') THEN
      xla_ae_journal_entry_pkg.g_global_status      :=  xla_ae_journal_entry_pkg.C_INVALID;

      xla_accounting_err_pkg.build_message
         (p_appli_s_name            => 'XLA'
         ,p_msg_name                => 'XLA_AP_INVALID_REVERSAL_OPTION'
         ,p_token_1                 => 'LINE_NUMBER'
         ,p_value_1                 => l_array_extract_line_num(Idx)
         ,p_token_2                 => 'PRODUCT_NAME'
         ,p_value_2                 => xla_ae_journal_entry_pkg.g_cache_event.application_name
         ,p_entity_id               => xla_ae_journal_entry_pkg.g_cache_event.entity_id
         ,p_event_id                => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_ledger_id               => xla_ae_journal_entry_pkg.g_cache_event.target_ledger_id);

   ELSIF NVL(l_acct_reversal_source, 'N') IN ('Y','B') THEN
      --
      -- following sets the accounting attributes needed to reverse
      -- accounting for a distributeion
      --

      --
      -- 5217187
      --
      l_rec_rev_acct_attrs.array_acct_attr_code(1):= 'GL_DATE';
      l_rec_rev_acct_attrs.array_date_value(1) := XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(
                                       g_array_event(l_event_id).array_value_num('header_index'));
      --
      --

      -- No reversal code generated

      xla_ae_lines_pkg.SetAcctReversalAttrs
         (p_event_id             => l_event_id
         ,p_rec_acct_attrs       => l_rec_rev_acct_attrs
         ,p_calculate_acctd_flag => l_calculate_acctd_flag
         ,p_calculate_g_l_flag   => l_calculate_g_l_flag);
   END IF;

   IF NVL(l_acct_reversal_source, 'N') IN ('N','B') THEN
       l_actual_flag := NULL;  l_actual_gain_loss_ref := '#####';

--
AcctLineType_2 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_2 => g_array_event(l_event_id).array_value_char('source_2')
 , p_source_3 => g_array_event(l_event_id).array_value_char('source_3')
 , p_source_4 => g_array_event(l_event_id).array_value_char('source_4')
 , p_source_6 => l_array_source_6(Idx)
 , p_source_7 => g_array_event(l_event_id).array_value_num('source_7')
 , p_source_8 => g_array_event(l_event_id).array_value_char('source_8')
 , p_source_9 => g_array_event(l_event_id).array_value_char('source_9')
 , p_source_10 => g_array_event(l_event_id).array_value_num('source_10')
 , p_source_11 => g_array_event(l_event_id).array_value_num('source_11')
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_14 => g_array_event(l_event_id).array_value_num('source_14')
 , p_source_15 => g_array_event(l_event_id).array_value_num('source_15')
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => g_array_event(l_event_id).array_value_num('source_17')
 , p_source_18 => g_array_event(l_event_id).array_value_char('source_18')
 , p_source_19 => g_array_event(l_event_id).array_value_num('source_19')
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_4 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_2 => g_array_event(l_event_id).array_value_char('source_2')
 , p_source_4 => g_array_event(l_event_id).array_value_char('source_4')
 , p_source_7 => g_array_event(l_event_id).array_value_num('source_7')
 , p_source_8 => g_array_event(l_event_id).array_value_char('source_8')
 , p_source_9 => g_array_event(l_event_id).array_value_char('source_9')
 , p_source_10 => g_array_event(l_event_id).array_value_num('source_10')
 , p_source_11 => g_array_event(l_event_id).array_value_num('source_11')
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_14 => g_array_event(l_event_id).array_value_num('source_14')
 , p_source_15 => g_array_event(l_event_id).array_value_num('source_15')
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => g_array_event(l_event_id).array_value_num('source_17')
 , p_source_18 => g_array_event(l_event_id).array_value_char('source_18')
 , p_source_19 => g_array_event(l_event_id).array_value_num('source_19')
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--


--
AcctLineType_7 (
 p_application_id  => p_application_id
 ,p_event_id     => l_event_id
 ,p_calculate_acctd_flag => l_calculate_acctd_flag
 ,p_calculate_g_l_flag => l_calculate_g_l_flag
 ,p_actual_flag => l_actual_flag
 ,p_balance_type_code => l_balance_type_code
 ,p_gain_or_loss_ref=> l_gain_or_loss_ref
 
 , p_source_2 => g_array_event(l_event_id).array_value_char('source_2')
 , p_source_3 => g_array_event(l_event_id).array_value_char('source_3')
 , p_source_4 => g_array_event(l_event_id).array_value_char('source_4')
 , p_source_6 => l_array_source_6(Idx)
 , p_source_7 => g_array_event(l_event_id).array_value_num('source_7')
 , p_source_8 => g_array_event(l_event_id).array_value_char('source_8')
 , p_source_9 => g_array_event(l_event_id).array_value_char('source_9')
 , p_source_10 => g_array_event(l_event_id).array_value_num('source_10')
 , p_source_11 => g_array_event(l_event_id).array_value_num('source_11')
 , p_source_12 => l_array_source_12(Idx)
 , p_source_13 => g_array_event(l_event_id).array_value_char('source_13')
 , p_source_13_meaning => g_array_event(l_event_id).array_value_char('source_13_meaning')
 , p_source_14 => g_array_event(l_event_id).array_value_num('source_14')
 , p_source_15 => g_array_event(l_event_id).array_value_num('source_15')
 , p_source_16 => l_array_source_16(Idx)
 , p_source_17 => g_array_event(l_event_id).array_value_num('source_17')
 , p_source_18 => g_array_event(l_event_id).array_value_char('source_18')
 , p_source_19 => g_array_event(l_event_id).array_value_num('source_19')
 );
If(l_balance_type_code = 'A') THEN
  l_actual_gain_loss_ref := l_gain_or_loss_ref;
END IF;

--

      -- only execute it if calculate g/l flag is yes, and primary or secondary ledger
      -- or secondary ledger that has different currency with primary
      -- or alc that is calculated by sla
      IF (((l_calculate_g_l_flag = 'Y' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> 'ALC') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in ('ALC', 'SECONDARY') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag='Y'))

--      IF((l_calculate_g_l_flag='Y' or XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id <>
--                    XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id)
          AND (l_actual_flag = 'A')) THEN
        XLA_AE_LINES_PKG.CreateGainOrLossLines(
          p_event_id         => xla_ae_journal_entry_pkg.g_cache_event.event_id
         ,p_application_id   => p_application_id
         ,p_amb_context_code => 'DEFAULT'
         ,p_entity_code      => xla_ae_journal_entry_pkg.g_cache_event.entity_code
         ,p_event_class_code => C_EVENT_CLASS_CODE
         ,p_event_type_code  => C_EVENT_TYPE_CODE
         
         ,p_gain_ccid        => -1
         ,p_loss_ccid        => -1

         ,p_actual_flag      => l_actual_flag
         ,p_enc_flag         => null
         ,p_actual_g_l_ref   => l_actual_gain_loss_ref
         ,p_enc_g_l_ref      => null
         );
      END IF;
   END IF;
END IF;

   ELSE
      --
      -- Bug 4872078 - Do nothing if the event is meant for transaction reversal
      --
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
            (p_msg      => 'Trancaction revesal option is Y'
            ,p_level    => C_LEVEL_STATEMENT
            ,p_module   => l_log_module);
      END IF;
   END IF;

END LOOP;
l_result := XLA_AE_LINES_PKG.InsertLines ;
end loop;
close line_cur;


--
-- insert headers into xla_ae_headers_gt table
--
l_result := XLA_AE_HEADER_PKG.InsertHeaders ;

-- insert into errors table here.

END LOOP;

--
-- 4865292
--
-- Compare g_hdr_extract_count with event count in
-- CreateHeadersAndLines.
--
g_hdr_extract_count := g_hdr_extract_count + header_cur%ROWCOUNT;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace (p_msg     => '# rows extracted from header extract objects '
                    || ' (running total): '
                    || g_hdr_extract_count
         ,p_level   => C_LEVEL_STATEMENT
         ,p_module  => l_log_module);
END IF;

CLOSE header_cur;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of EventClass_18'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   
IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;

   
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

   RAISE;

WHEN NO_DATA_FOUND THEN

IF header_cur%ISOPEN THEN CLOSE header_cur; END IF;
IF line_cur%ISOPEN   THEN CLOSE line_cur;   END IF;

FOR header_record IN header_cur
LOOP
    l_array_header_events(header_record.event_id) := header_record.event_id;
END LOOP;

l_first_event_id := l_array_header_events(l_array_header_events.FIRST);
l_last_event_id := l_array_header_events(l_array_header_events.LAST);

fnd_file.put_line(fnd_file.LOG, '                    ');
fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, 'EVENT CLASS CODE = ' || C_EVENT_CLASS_CODE );
fnd_file.put_line(fnd_file.LOG, 'The following events are present in the line extract but MISSING in the header extract: ');

FOR line_record IN line_cur(l_first_event_id, l_last_event_id)
LOOP
	IF (NOT l_array_header_events.EXISTS(line_record.event_id))  AND (NOT l_array_duplicate_checker.EXISTS(line_record.event_id)) THEN
	fnd_file.put_line(fnd_file.log, 'Event_id = ' || line_record.event_id);
        l_array_duplicate_checker(line_record.event_id) := line_record.event_id;
	END IF;
END LOOP;

fnd_file.put_line(fnd_file.LOG, '***************************************************************************');
fnd_file.put_line(fnd_file.LOG, '                    ');


xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_18');


WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.EventClass_18');
END EventClass_18;
--

--
--+============================================+
--|                                            |
--|  PRIVATE FUNCTION                          |
--|                                            |
--+============================================+
--
FUNCTION CreateHeadersAndLines
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_target_ledger_id       IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN BOOLEAN IS
l_created                   BOOLEAN:=FALSE;
l_event_id                  NUMBER;
l_event_date                DATE;
l_language                  VARCHAR2(30);
l_currency_code             VARCHAR2(30);
l_sla_ledger_id             NUMBER;
l_log_module                VARCHAR2(240);

BEGIN
--
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.CreateHeadersAndLines';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of CreateHeadersAndLines'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

l_language         := xla_ae_journal_entry_pkg.g_cache_ledgers_info.description_language;
l_currency_code    := xla_ae_journal_entry_pkg.g_cache_ledgers_info.currency_code;
l_sla_ledger_id    := xla_ae_journal_entry_pkg.g_cache_ledgers_info.sla_ledger_id;

--
-- initialize array of lines with NULL
--
xla_ae_lines_pkg.SetNullLine;

--
-- initialize header extract count -- Bug 4865292
--
g_hdr_extract_count:= 0;


l_created := EventClass_12(
   p_application_id         => p_application_id
 , p_base_ledger_id         => p_base_ledger_id
 , p_target_ledger_id       => p_target_ledger_id
 , p_language               => l_language
 , p_currency_code          => l_currency_code
 , p_sla_ledger_id          => l_sla_ledger_id
 , p_pad_start_date         => p_pad_start_date
 , p_pad_end_date           => p_pad_end_date
 , p_primary_ledger_id      => p_primary_ledger_id
);



     IF ( g_diagnostics_mode ='Y' ) THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => 'CALL Transaction Objects Diagnostics'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

         END IF;

         insert_sources_12(
                          p_target_ledger_id => p_target_ledger_id
                        , p_language         => l_language
                        , p_sla_ledger_id    => l_sla_ledger_id
                        , p_pad_start_date   => p_pad_start_date
                        , p_pad_end_date     => p_pad_end_date
                          );

     END IF;

l_created := EventClass_13(
   p_application_id         => p_application_id
 , p_base_ledger_id         => p_base_ledger_id
 , p_target_ledger_id       => p_target_ledger_id
 , p_language               => l_language
 , p_currency_code          => l_currency_code
 , p_sla_ledger_id          => l_sla_ledger_id
 , p_pad_start_date         => p_pad_start_date
 , p_pad_end_date           => p_pad_end_date
 , p_primary_ledger_id      => p_primary_ledger_id
);



     IF ( g_diagnostics_mode ='Y' ) THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => 'CALL Transaction Objects Diagnostics'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

         END IF;

         insert_sources_13(
                          p_target_ledger_id => p_target_ledger_id
                        , p_language         => l_language
                        , p_sla_ledger_id    => l_sla_ledger_id
                        , p_pad_start_date   => p_pad_start_date
                        , p_pad_end_date     => p_pad_end_date
                          );

     END IF;

l_created := EventClass_14(
   p_application_id         => p_application_id
 , p_base_ledger_id         => p_base_ledger_id
 , p_target_ledger_id       => p_target_ledger_id
 , p_language               => l_language
 , p_currency_code          => l_currency_code
 , p_sla_ledger_id          => l_sla_ledger_id
 , p_pad_start_date         => p_pad_start_date
 , p_pad_end_date           => p_pad_end_date
 , p_primary_ledger_id      => p_primary_ledger_id
);



     IF ( g_diagnostics_mode ='Y' ) THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => 'CALL Transaction Objects Diagnostics'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

         END IF;

         insert_sources_14(
                          p_target_ledger_id => p_target_ledger_id
                        , p_language         => l_language
                        , p_sla_ledger_id    => l_sla_ledger_id
                        , p_pad_start_date   => p_pad_start_date
                        , p_pad_end_date     => p_pad_end_date
                          );

     END IF;

l_created := EventClass_15(
   p_application_id         => p_application_id
 , p_base_ledger_id         => p_base_ledger_id
 , p_target_ledger_id       => p_target_ledger_id
 , p_language               => l_language
 , p_currency_code          => l_currency_code
 , p_sla_ledger_id          => l_sla_ledger_id
 , p_pad_start_date         => p_pad_start_date
 , p_pad_end_date           => p_pad_end_date
 , p_primary_ledger_id      => p_primary_ledger_id
);



     IF ( g_diagnostics_mode ='Y' ) THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => 'CALL Transaction Objects Diagnostics'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

         END IF;

         insert_sources_15(
                          p_target_ledger_id => p_target_ledger_id
                        , p_language         => l_language
                        , p_sla_ledger_id    => l_sla_ledger_id
                        , p_pad_start_date   => p_pad_start_date
                        , p_pad_end_date     => p_pad_end_date
                          );

     END IF;

l_created := EventClass_16(
   p_application_id         => p_application_id
 , p_base_ledger_id         => p_base_ledger_id
 , p_target_ledger_id       => p_target_ledger_id
 , p_language               => l_language
 , p_currency_code          => l_currency_code
 , p_sla_ledger_id          => l_sla_ledger_id
 , p_pad_start_date         => p_pad_start_date
 , p_pad_end_date           => p_pad_end_date
 , p_primary_ledger_id      => p_primary_ledger_id
);



     IF ( g_diagnostics_mode ='Y' ) THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => 'CALL Transaction Objects Diagnostics'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

         END IF;

         insert_sources_16(
                          p_target_ledger_id => p_target_ledger_id
                        , p_language         => l_language
                        , p_sla_ledger_id    => l_sla_ledger_id
                        , p_pad_start_date   => p_pad_start_date
                        , p_pad_end_date     => p_pad_end_date
                          );

     END IF;

l_created := EventClass_17(
   p_application_id         => p_application_id
 , p_base_ledger_id         => p_base_ledger_id
 , p_target_ledger_id       => p_target_ledger_id
 , p_language               => l_language
 , p_currency_code          => l_currency_code
 , p_sla_ledger_id          => l_sla_ledger_id
 , p_pad_start_date         => p_pad_start_date
 , p_pad_end_date           => p_pad_end_date
 , p_primary_ledger_id      => p_primary_ledger_id
);



     IF ( g_diagnostics_mode ='Y' ) THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => 'CALL Transaction Objects Diagnostics'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

         END IF;

         insert_sources_17(
                          p_target_ledger_id => p_target_ledger_id
                        , p_language         => l_language
                        , p_sla_ledger_id    => l_sla_ledger_id
                        , p_pad_start_date   => p_pad_start_date
                        , p_pad_end_date     => p_pad_end_date
                          );

     END IF;

l_created := EventClass_18(
   p_application_id         => p_application_id
 , p_base_ledger_id         => p_base_ledger_id
 , p_target_ledger_id       => p_target_ledger_id
 , p_language               => l_language
 , p_currency_code          => l_currency_code
 , p_sla_ledger_id          => l_sla_ledger_id
 , p_pad_start_date         => p_pad_start_date
 , p_pad_end_date           => p_pad_end_date
 , p_primary_ledger_id      => p_primary_ledger_id
);



     IF ( g_diagnostics_mode ='Y' ) THEN

         IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace
              (p_msg      => 'CALL Transaction Objects Diagnostics'
              ,p_level    => C_LEVEL_STATEMENT
              ,p_module   => l_log_module);

         END IF;

         insert_sources_18(
                          p_target_ledger_id => p_target_ledger_id
                        , p_language         => l_language
                        , p_sla_ledger_id    => l_sla_ledger_id
                        , p_pad_start_date   => p_pad_start_date
                        , p_pad_end_date     => p_pad_end_date
                          );

     END IF;


 --
 -- Bug 4865292
 -- When the number of events and that of header extract do not match,
 -- set the no header extract flag to indicate there are some issues
 -- in header extract.
 --
 -- Event count context is set in xla_accounting_pkg.unit_processor.
 -- Build_Message for this error is called in xla_accounting_pkg.post_accounting
 -- to report it as a general error.
 --
 IF  xla_context_pkg.get_event_count_context <> g_hdr_extract_count
 AND xla_context_pkg.get_event_nohdr_context <> 'Y' THEN

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
          (p_msg      => '# of extracted headers and events does not match'
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

        trace
          (p_msg      => '# of extracted headers: '
                         ||g_hdr_extract_count
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

        trace
          (p_msg      => '# of events in xla_events_gt: '
                         ||xla_context_pkg.get_event_count_context
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

        trace
          (p_msg      => 'Event No Header Extract Context: '
                         ||xla_context_pkg.get_event_nohdr_context
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);

     END IF;


     xla_context_pkg.set_event_nohdr_context
       (p_nohdr_extract_flag => 'Y'
       ,p_client_id => sys_context('USERENV','CLIENT_IDENTIFIER'));

     IF (C_LEVEL_STATEMENT >= g_log_level) THEN
        trace
          (p_msg      => 'No Header Extract Flag is set to Y'
          ,p_level    => C_LEVEL_STATEMENT
          ,p_module   => l_log_module);
     END IF;

 END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'END of CreateHeadersAndLines'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

RETURN l_created;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.CreateHeadersAndLines');
END CreateHeadersAndLines;
--
--

--
--+============================================+
--|                                            |
--|  PUBLIC FUNCTION                           |
--|                                            |
--+============================================+
--
FUNCTION CreateJournalEntries
       (p_application_id         IN NUMBER
       ,p_base_ledger_id         IN NUMBER
       ,p_pad_start_date         IN DATE
       ,p_pad_end_date           IN DATE
       ,p_primary_ledger_id      IN NUMBER)
RETURN NUMBER IS
l_log_module                   VARCHAR2(240);
l_array_ledgers                xla_accounting_cache_pkg.t_array_ledger_id;
l_temp_result                  BOOLEAN;
l_result                       NUMBER;
BEGIN
--
IF g_log_enabled THEN
   l_log_module := C_DEFAULT_MODULE||'.CreateJournalEntries';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'BEGIN of CreateJournalEntries'||
                     ' - p_base_ledger_id = '||TO_CHAR(p_base_ledger_id)
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);

END IF;

--
g_diagnostics_mode:= xla_accounting_engine_pkg.g_diagnostics_mode;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace
      (p_msg      => 'g_diagnostics_mode = '||g_diagnostics_mode
      ,p_level    => C_LEVEL_STATEMENT
      ,p_module   => l_log_module);
END IF;
--
xla_ae_journal_entry_pkg.SetProductAcctDefinition
   (p_product_rule_code      => 'COST_MANAGEMENT_ENCUMBRANCE'
   ,p_product_rule_type_code => 'S'
   ,p_product_rule_version   => ''
   ,p_product_rule_name      => 'Cost Management Encumbrance Application Accounting Definition'
   ,p_amb_context_code       => 'DEFAULT'
   );

l_array_ledgers :=
   xla_ae_journal_entry_pkg.GetAlternateCurrencyLedger
      (p_base_ledger_id  => p_base_ledger_id);

FOR Idx IN 1 .. l_array_ledgers.COUNT LOOP
   l_temp_result :=
      XLA_AE_JOURNAL_ENTRY_PKG.GetLedgersInfo
         (p_application_id           => p_application_id
         ,p_base_ledger_id           => p_base_ledger_id
         ,p_target_ledger_id         => l_array_ledgers(Idx)
         ,p_primary_ledger_id        => p_primary_ledger_id
         ,p_pad_start_date           => p_pad_start_date
         ,p_pad_end_date             => p_pad_end_date);

   l_temp_result :=
      l_temp_result AND
      CreateHeadersAndLines
         (p_application_id             => p_application_id
         ,p_base_ledger_id             => p_base_ledger_id
         ,p_target_ledger_id           => l_array_ledgers(Idx)
         ,p_pad_start_date             => p_pad_start_date
         ,p_pad_end_date               => p_pad_end_date
         ,p_primary_ledger_id          => p_primary_ledger_id
         );
END LOOP;


IF (g_diagnostics_mode = 'Y' AND
    C_LEVEL_UNEXPECTED >= g_log_level AND
    xla_environment_pkg.g_Req_Id IS NOT NULL ) THEN

   xla_accounting_dump_pkg.acctg_event_extract_log(
    p_application_id  => p_application_id
    ,p_request_id     => xla_environment_pkg.g_Req_Id
   );

END IF;

CASE l_temp_result
  WHEN TRUE THEN l_result := 0;
  ELSE l_result := 2;
END CASE;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'return value. = '||TO_CHAR(l_result)
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   trace
      (p_msg      => 'END of CreateJournalEntries '
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;

RETURN l_result;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'ERROR. = '||sqlerrm
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   END IF;
   RAISE;
WHEN OTHERS THEN
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => 'ERROR. = '||sqlerrm
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location => 'XLA_00707_AAD_S_000002_BC_PKG.CreateJournalEntries');
END CreateJournalEntries;
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
END XLA_00707_AAD_S_000002_BC_PKG;
--

/
