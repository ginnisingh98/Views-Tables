--------------------------------------------------------
--  DDL for Package Body XLA_CMP_ACCT_LINE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_CMP_ACCT_LINE_TYPE_PKG" AS
/* $Header: xlacpalt.pkb 120.66.12010000.4 2009/09/24 12:01:33 vkasina ship $   */
/*============================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                      |
|                       Redwood Shores, CA, USA                               |
|                         All rights reserved.                                |
+=============================================================================+
| PACKAGE NAME                                                                |
|     xla_cmp_acct_line_type_pkg                                              |
|                                                                             |
| DESCRIPTION                                                                 |
|     This is a XLA private package, which contains all the logic required    |
|     to generate Accounting line type procedures from AMB specifcations      |
|                                                                             |
|                                                                             |
| HISTORY                                                                     |
|     15-JUN-2002 K.Boussema    Created                                       |
|     20-FEB-2003 K.Boussema    Added 'dbdrv' command                         |
|     21-FEB-2003 K.Boussela    Changed GenerateAcctLineType function         |
|     13-MAR-2003 K.Boussema    Made changes for the new bulk approach of the |
|                               accounting engine                             |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                 |
|     02-APR-2003 K.boussema    Added generation of analytical criteria       |
|     22-APR-2003 K.Boussema    Included error messages                       |
|     06-MAI-2003 K.Boussema    Modified to fix bug 2936066(Unbalanced JE)    |
|     22-MAI-2003 K.Boussema    Modified the Extract of line Accounting       |
|                               sources, bug 2972421                          |
|     02-JUN-2003 K.Boussema    Modified to fix bug 2975670 and bug 2729143   |
|     17-JUL-2003 K.Boussema    Reviewd the code                              |
|     27-AUG-2003 K.Boussema    Reviewed the generation of SetAccountingSource|
|     27-SEP-2003 K.Boussema    Changed the event_class clauses using '_ALL'  |
|     27-SEP-2003 K.Boussema    Reviewed GetAccountingSources() procedure     |
|     27-NOV-2003 K.Boussema    Changed to pass accounting class meaning      |
|                               instead of the lookup code                    |
|     01-DEC-2003 K.Boussema    Remove changed introduced in 27-NOV-2003      |
|     18-DEC-2003 K.Boussema    Changed to fix bug 3042840,3307761,3268940    |
|                               3310291 and 3320689                           |
|     30-DEC-2003 K.Boussema    Removed validation of JLT side, bug 3239528   |
|     23-FEB-2004 K.Boussema    Made changes for the FND_LOG.                 |
|     12-MAR-2004 K.Boussema    Changed to incorporate the select of lookups  |
|                               from the extract objects                      |
|     22-MAR-2004 K.Boussema    Added a parameter p_module to the TRACE calls |
|                               and the procedure.                            |
|     11-MAY-2004 K.Boussema    Removed the call to XLA trace routine from    |
|                               trace() procedure                             |
|     17-MAY-2004 W.Shen        Accounting attribute enhancement project      |
|                               change to GenerateAcctLineTypeProcs,          |
|                               GetAccountingSources procedure                |
|     20-Sep-2004 S.Singhania   Made following changes for bulk processing:   |
|                                 - Added constatnt C_ALT_BODY                |
|                                 - Modified contants C_ALT_PROC and          |
|                                   C_SET_ACCT_SOURCES                        |
|                                 - Modified routines GetAccountingSources,   |
|                                   GetALTBody and GenerateDefAcctLineType    |
|     27-DEC-2004 K.Boussema    Changed the VARCHAR2 type by CLOB to handle   |
|                                 the large ALT                               |
|     12-Feb-2004 W.Shen        Modify C_ALT_PROC to add two parameters for   |
|                                 calculate amount, gain lost                 |
|                               Modify for ledger Currency Project            |
|     28-MAR-2005 A.Wan         Changed for business flow. Bug 4219869        |
|     11-Jul-2005 A.Wan         Changed for MPA . Bug 4262811                 |
|     22-Sep-2005 S.Singhania   Bug 4544725. Implemented Business Flows and   |
|                                 Reversals for Non-Upgraded JEs.             |
|     12-Oct-2005 A.Wan         Bug 4645092 - MPA report changes              |
|     18-Oct-2005 V. Kumar      Removed code for Analytical Criteria          |
|     05-Jan-2005 A. Govil      Bug 4922099 - Added code for Federal          |
|                               Non-upgraded entries.                         |
|     09-Jan-2006 A.Wan         Bug 4669271 - do not copy bflow class for     |
|                                             Accrual reversal                |
|     30-Jan-2006 A.Wan         Bug 4655713 -                                 |
|                               - in GenerateCallADR, process ALL segment 1st |
|                               - in GenerateADRCalls, if same entry, and ALL |
|                                 segment is inherited, then set C_CHAR to    |
|                                 each segments.                              |
|     03-Feb-2006 A.Wan         Bug 4655713b -                                |
|                               - if accrual reversal uses business flow,     |
|                                 set reversal_code to 'MPA_' + bflow method  |
|     07-FEB-2006 A.Wan       4897417 error if MPA's GL periods not defined.  |
|     13-FEB-2006 V.Kumar     4955764 Modified C_ALT_BODY , C_ACC_REV_MPA_BODY|
|     01-Mar-2006 A.Wan       5052518 Accrual reversal did not change SIGN    |
|                                     as defined in reversal method.          |
|     15-Apr-2006 A.Wan       5132303 -  applied to amt for Gain/Loss         |
|     01-Jan-2009 VGOPISET    7109881 Changed MPA parent line Num. Added call |
|                                     to InsertMPARecogLineInfo proedure      |
+============================================================================*/
--
--+==========================================================================+
--|                                                                          |
--|                                                                          |
--| Global Constants                                                         |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

G_ADRS                       CLOB;
--
-- ADR segment or flexfield procedures
--
C_ALT_PROC                    CONSTANT      VARCHAR2(20000):= '
---------------------------------------
--
-- PRIVATE FUNCTION
--         AcctLineType_$alt_hash_id$
--
---------------------------------------
PROCEDURE AcctLineType_$alt_hash_id$ (
  p_application_id        IN NUMBER
 ,p_event_id              IN NUMBER
 ,p_calculate_acctd_flag  IN VARCHAR2
 ,p_calculate_g_l_flag    IN VARCHAR2
 ,p_actual_flag           IN OUT VARCHAR2
 ,p_balance_type_code     OUT VARCHAR2
 ,p_gain_or_loss_ref      OUT VARCHAR2
 $parameters$
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
      l_log_module := C_DEFAULT_MODULE||''.AcctLineType_$alt_hash_id$'';
END IF;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => ''BEGIN of AcctLineType_$alt_hash_id$''
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
--
l_component_type             := ''AMB_JLT'';
l_component_code             := ''$alt_code$'';
l_component_type_code        := ''$alt_type_code$'';
l_component_appl_id          :=  $alt_appl_id$;
l_amb_context_code           := ''$amb_context_code$'';
l_entity_code                := ''$entity_code$'';
l_event_class_code           := ''$event_class_code$'';
l_event_type_code            := ''$event_type_code$'';
l_line_definition_owner_code := ''$line_definition_owner_code$'';
l_line_definition_code       := ''$line_definition_code$'';
--
l_balance_type_code          := ''$balance_type_code$'';
l_segment                     := NULL;
l_ccid                        := NULL;
l_adr_transaction_coa_id      := NULL;
l_adr_accounting_coa_id       := NULL;
l_adr_flexfield_segment_code  := NULL;
l_adr_flex_value_set_id       := NULL;
l_adr_value_type_code         := NULL;
l_adr_value_combination_id    := NULL;
l_adr_value_segment_code      := NULL;

l_bflow_method_code          := ''$bflow_method_code$'';   -- 4219869 Business Flow
l_bflow_class_code           := ''$bflow_class_code$'';    -- 4219869 Business Flow
l_inherit_desc_flag          := ''$inherit_desc_flag$'';   -- 4219869 Business Flow
l_budgetary_control_flag     := ''$budgetary_control_flag$'';

l_bflow_applied_to_amt_idx   := NULL; -- 5132302
l_bflow_applied_to_amt       := NULL; -- 5132302
l_entered_amt_idx            := NULL;          -- 4262811
l_accted_amt_idx             := NULL;          -- 4262811
l_acc_rev_flag               := NULL;          -- 4262811
l_accrual_line_num           := NULL;          -- 4262811
l_tmp_amt                    := NULL;          -- 4262811
--
$alt_proc_gain_or_loss_cond$
$alt_proc_cond$
$alt_body$
END IF;
--

--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
   trace
      (p_msg      => ''END of AcctLineType_$alt_hash_id$''
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
--
EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
  WHEN OTHERS THEN
       xla_exceptions_pkg.raise_message
           (p_location => ''$package_name$.AcctLineType_$alt_hash_id$'');
END AcctLineType_$alt_hash_id$;
--
';  -- C_ALT_PROC


C_ACC_REV_MPA_BODY            CONSTANT      VARCHAR2(20000):= '
   -------------------------------------------------------------------------------------------
   -- 4262811 - Generate the Accrual Reversal lines
   -------------------------------------------------------------------------------------------
   BEGIN
      l_acc_rev_flag := XLA_AE_HEADER_PKG.g_rec_header_new.array_accrual_reversal_flag
                              (g_array_event(p_event_id).array_value_num(''header_index''));
      IF l_acc_rev_flag IS NULL THEN
         l_acc_rev_flag := ''N'';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_acc_rev_flag := ''N'';
   END;
   --
   IF (l_acc_rev_flag = ''Y'') THEN

       -- 4645092  ------------------------------------------------------------------------------
       -- To allow MPA report to determine if it should generate report process
       XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := ''Y'';
       ------------------------------------------------------------------------------------------

       l_accrual_line_num := XLA_AE_LINES_PKG.g_LineNumber;
       XLA_AE_LINES_PKG.CopyLineInfo(l_accrual_line_num);
   -- added call to set_ccid to execute mapping  for secondary accrual reversal entries bug 7444204
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> ''PRIOR_ENTRY'') OR
        (NVL(l_actual_upg_option, ''N'') = ''O'') OR
        (NVL(l_enc_upg_option, ''N'') = ''O'')
      )
   THEN
   NULL;
   --
   --
   $call_adr$
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

       IF l_bflow_method_code <> ''NONE''
          AND (NVL(l_actual_upg_option, ''N'') IN (''Y'', ''O'')
               OR NVL(l_enc_upg_option, ''N'') IN (''Y'', ''O'')) THEN  -- bug#8935054

          NULL;

       ELSIF l_bflow_method_code <> ''NONE'' THEN -- 4655713b

         XLA_AE_LINES_PKG.g_rec_lines.array_reversal_code(XLA_AE_LINES_PKG.g_LineNumber) := CONCAT(''MPA_'',l_bflow_method_code);

       END IF;
      --
      -- Depending on the Reversal Method setup, do a switch side or changes sign for the amounts
      --
      IF (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_reversal_option = ''SIDE'') THEN
          XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) :=  l_acc_rev_natural_side_code;
      ELSE
          ---------------------------------------------------------------------------------------------------
          -- 4262811a Switch Sign
          ---------------------------------------------------------------------------------------------------
          XLA_AE_LINES_PKG.g_rec_lines.array_switch_side_flag(XLA_AE_LINES_PKG.g_LineNumber) := ''N'';  -- 5052518
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
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num(''acc_rev_header_index''));


      XLA_AE_LINES_PKG.ValidateCurrentLine;
      XLA_AE_LINES_PKG.SetDebitCreditAmounts;

      XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus
               (p_hdr_idx           => g_array_event(p_event_id).array_value_num(''acc_rev_header_index'')
               ,p_balance_type_code => l_balance_type_code);

   END IF;

   -----------------------------------------------------------------------------------------
   -- 4262811 Multiperiod Accounting
   -----------------------------------------------------------------------------------------
   $mpa_body$

'; --  C_ACC_REV_MPA_BODY

--
-- alt body template
--
C_ALT_BODY                   CONSTANT      VARCHAR2(10000):=
'
   --
   XLA_AE_LINES_PKG.SetNewLine;

   p_balance_type_code          := l_balance_type_code;
   -- set the flag so later we will know whether the gain loss line needs to be created
   $set_actual_enc_flag$

   --
   -- bulk performance
   --
   XLA_AE_LINES_PKG.set_ae_header_id (p_ae_header_id => p_event_id ,
                                      p_header_num   => 0); -- 4262811
   --
   -- set accounting line options
   --
   $acct_line_options$
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
   $set_acct_class$
   --
   -- set rounding class
   --
   $set_rounding_class$
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
      XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date(g_array_event(p_event_id).array_value_num(''header_index''));

   -- 4458381 Public Sector Enh
   $set_encumbrance_type_id$
   --
   -- set accounting attributes for the line type
   --
$alt_acct_attributes$
   XLA_AE_LINES_PKG.SetLineAcctAttrs(l_rec_acct_attrs);
   p_gain_or_loss_ref  := XLA_AE_LINES_PKG.g_rec_lines.array_gain_or_loss_ref(XLA_AE_LINES_PKG.g_LineNumber);

   ---------------------------------------------------------------------------------------------------------------
   -- 4336173 -- assign Business Flow Class (replace code in xla_ae_lines_pkg.Business_Flow_Validation)
   ---------------------------------------------------------------------------------------------------------------
   XLA_AE_LINES_PKG.g_rec_lines.array_business_class_code(XLA_AE_LINES_PKG.g_LineNumber) := l_bflow_class_code;

   l_actual_upg_option  := XLA_AE_LINES_PKG.g_rec_lines.array_actual_upg_option(XLA_AE_LINES_PKG.g_LineNumber);
   l_enc_upg_option     := XLA_AE_LINES_PKG.g_rec_lines.array_enc_upg_option(XLA_AE_LINES_PKG.g_LineNumber);

   IF xla_accounting_cache_pkg.GetValueChar
         (p_source_code         => ''LEDGER_CATEGORY_CODE''
         ,p_target_ledger_id    => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id) IN (''PRIMARY'',''ALC'')
   AND l_bflow_method_code = ''PRIOR_ENTRY''
--   AND (l_actual_upg_option = ''Y'' OR l_enc_upg_option = ''Y'') Bug 4922099
   AND ( (NVL(l_actual_upg_option, ''N'') IN (''Y'', ''O'')) OR
         (NVL(l_enc_upg_option, ''N'') IN (''Y'', ''O''))
       )
   THEN
         xla_ae_lines_pkg.BflowUpgEntry
           (p_business_method_code    => l_bflow_method_code
           ,p_business_class_code     => l_bflow_class_code
           ,p_balance_type            => l_balance_type_code);
   ELSE
      NULL;
$call_bflow_validation$
   END IF;

   --
   -- call analytical criteria
   --
   $call_analytical_criteria$
   --
   -- call description
   --
   $call_description$
   --
   -- call ADRs
   -- Bug 4922099
   --
   IF ( (l_bflow_method_code <> ''PRIOR_ENTRY'') OR
        (NVL(l_actual_upg_option, ''N'') = ''O'') OR
        (NVL(l_enc_upg_option, ''N'') = ''O'')
      )
   THEN
   NULL;
   --
   --
   $call_adr$
   --
   --
   END IF;
   --
   -- Bug 4922099
   IF ( ( (NVL(l_actual_upg_option, ''N'') = ''O'') OR
          (NVL(l_enc_upg_option, ''N'') = ''O'')
        ) AND
        (l_bflow_method_code = ''PRIOR_ENTRY'')
      )
   THEN
      IF
      --
      $no_adr_assigned$
      --
      THEN
      xla_accounting_err_pkg.build_message
                                    (p_appli_s_name            => ''XLA''
                                    ,p_msg_name                => ''XLA_UPG_OVERRIDE_ADR_UNDEFINED''
                                    ,p_token_1                 => ''LINE_NUMBER''
                                    ,p_value_1                 => XLA_AE_LINES_PKG.g_LineNumber
                                    ,p_token_2                 => ''LINE_TYPE_NAME''
                                    ,p_value_2                 => XLA_AE_SOURCES_PKG.GetComponentName (
                                                                             l_component_type
                                                                            ,l_component_code
                                                                            ,l_component_type_code
                                                                            ,l_component_appl_id
                                                                            ,l_amb_context_code
                                                                            ,l_entity_code
                                                                            ,l_event_class_code
                                                                           )
                                    ,p_token_3                 => ''OWNER''
                                    ,p_value_3                 => xla_lookups_pkg.get_meaning(
                                                                          p_lookup_type     => ''XLA_OWNER_TYPE''
                                                                          ,p_lookup_code    => l_component_type_code
                                                                         )
                                    ,p_token_4                 => ''PRODUCT_NAME''
                                    ,p_value_4                 => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.application_name
                                    ,p_entity_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                                    ,p_event_id                => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                                    ,p_ledger_id               => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                                    ,p_ae_header_id            =>  NULL
                                       );

        IF (C_LEVEL_ERROR>= g_log_level) THEN
                 trace
                      (p_msg      => ''ERROR: XLA_UPG_OVERRIDE_ADR_UNDEFINED''
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
   $call_validate_line$

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
         (p_hdr_idx => g_array_event(p_event_id).array_value_num(''header_index'')
         ,p_balance_type_code => l_balance_type_code
         );
';  -- C_ALT_BODY

C_SET_ENCUMBRANCE_TYPE_ID    CONSTANT      VARCHAR2(1000):=
'   XLA_AE_LINES_PKG.g_rec_lines.array_encumbrance_type_id(XLA_AE_LINES_PKG.g_LineNumber) := $encumbrance_type_id$;';

---------------------------------------------------------------------------------------------------------
-- 4262811  - Generates MPA Body if Multiperiod Option is set to Yes
---------------------------------------------------------------------------------------------------------
C_MPA_BODY             CONSTANT VARCHAR2(10000) :=
'
   IF (XLA_AE_LINES_PKG.g_rec_lines.array_mpa_option(XLA_AE_LINES_PKG.g_LineNumber) = ''Y''
      AND $mpa_start_date$ IS NOT NULL AND $mpa_end_date$ IS NOT NULL) THEN

      XLA_AE_LINES_PKG.g_rec_lines.array_mpa_acc_entry_flag(XLA_AE_LINES_PKG.g_LineNumber) := ''Y'';

      -------------------------------------------------------------------------------------
      -- 4262811b  Rounding not needed here
      -------------------------------------------------------------------------------------
      -- To handle MPA rounding
      -- IF XLA_AE_LINES_PKG.g_rec_lines.array_natural_side_code(XLA_AE_LINES_PKG.g_LineNumber) = ''G'' THEN
      --  --l_rounding_ccy := XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code;
      --    l_rounding_ccy := xla_accounting_cache_pkg.GetValueChar(
      --                            p_source_code =>     ''XLA_CURRENCY_CODE''
      --                           ,p_target_ledger_id=>   XLA_AE_LINES_PKG.g_rec_lines.array_ledger_id(
      --                                                   XLA_AE_LINES_PKG.g_rec_lines.array_line_num.FIRST));
      -- ELSE
      --    l_rounding_ccy := XLA_AE_LINES_PKG.g_rec_lines.array_currency_code(XLA_AE_LINES_PKG.g_LineNumber);
      -- END IF;

      -------------------------------------------------------------------------------------
      -- 4262811b  Check if transaction currency is the same as ledger currency
      -------------------------------------------------------------------------------------
      IF XLA_AE_LINES_PKG.g_rec_lines.array_currency_code(XLA_AE_LINES_PKG.g_LineNumber) =
         XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.currency_code THEN
         l_same_currency := TRUE;
      ELSE
         l_same_currency := FALSE;
      END IF;
      -------------------------------------------------------------------------------------

      -------------------------------------------------------------------------------------
      -- 5132302
      IF l_bflow_applied_to_amt_idx IS NULL THEN
         l_bflow_applied_to_amt := NULL;
      ELSE
         l_bflow_applied_to_amt := l_rec_acct_attrs.array_num_value(l_bflow_applied_to_amt_idx);
      END IF;
      -------------------------------------------------------------------------------------

      XLA_AE_HEADER_PKG.GetRecognitionEntriesInfo
         (p_ledger_id          => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
         ,p_start_date         => $mpa_start_date$
         ,p_end_date           => $mpa_end_date$
         ,p_gl_date_option     => ''$mpa_gl_dates$''
         ,p_num_entries_option => ''$mpa_num_je$''
         ,p_proration_code     => ''$mpa_proration_code$''
         ,p_calculate_acctd_flag => p_calculate_acctd_flag  -- 4262811b for MPA rounding
         ,p_same_currency      => l_same_currency           -- 4262811b for MPA rounding
         ,p_accted_amt         => l_rec_acct_attrs.array_num_value(l_accted_amt_idx)
         ,p_entered_amt        => l_rec_acct_attrs.array_num_value(l_entered_amt_idx)
         ,p_bflow_applied_to_amt      => l_bflow_applied_to_amt    -- 5132302
         ,x_bflow_applied_to_amts     => l_bflow_applied_to_amts   -- 5132302
         ,x_num_entries        => l_num_entries
         ,x_gl_dates           => l_gl_dates
         ,x_accted_amts        => l_accted_amts
         ,x_entered_amts       => l_entered_amts
         ,x_period_names       => l_period_names);

      IF l_num_entries = 0 THEN  -- 4897417 do not generate if no entries

         XLA_AE_JOURNAL_ENTRY_PKG.g_global_status  :=  XLA_AE_JOURNAL_ENTRY_PKG.C_INVALID;
         xla_accounting_err_pkg.build_message
                 (p_appli_s_name  => ''XLA''
                 ,p_msg_name      => ''XLA_AP_NO_MPA_GL_PERIOD''
                 ,p_token_1       => ''LEDGER_NAME''
                 ,p_value_1       => xla_accounting_cache_pkg.GetValueChar
                                     ( p_source_code      => ''XLA_LEDGER_NAME''
                                      ,p_target_ledger_id => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id)
                 ,p_entity_id     => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.entity_id
                 ,p_event_id      => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.event_id
                 ,p_ledger_id     => XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id
                 ,p_ae_header_id  => NULL);

      ELSE

         -- 4645092  ------------------------------------------------------------------------------
         -- To allow MPA report to determine if it should generate report process
         XLA_ACCOUNTING_PKG.g_mpa_accrual_exists := ''Y'';
         ------------------------------------------------------------------------------------------

         --========================================================================
         -- Create the first MPA Recognition Header (one Header per MPA period)
         --========================================================================
         g_last_hdr_idx := g_last_hdr_idx + 1;

         XLA_AE_HEADER_PKG.CopyHeaderInfo (p_parent_hdr_idx => g_array_event(p_event_id).array_value_num(''header_index'')
                                          ,p_hdr_idx        => g_last_hdr_idx);

         --------------------------------------------------------------------
         -- g_mpa_line_num: to prevent multiple MPA-JLT grouped into one line
         --------------------------------------------------------------------
         --XLA_AE_HEADER_PKG.g_rec_header_new.array_header_num      (g_last_hdr_idx) := 1;
         XLA_AE_HEADER_PKG.g_mpa_line_num := XLA_AE_HEADER_PKG.g_mpa_line_num + 1;  -- JUN28 new
         XLA_AE_HEADER_PKG.g_rec_header_new.array_header_num      (g_last_hdr_idx) := XLA_AE_HEADER_PKG.g_mpa_line_num;

         ----------------------------------------------------------------------------------------------------------
         -- 4262811a  To handle rollover of MPA date in PostAccountingEngines
         ----------------------------------------------------------------------------------------------------------
         XLA_AE_HEADER_PKG.g_rec_header_new.array_acc_rev_gl_date_option (g_last_hdr_idx) := ''$mpa_gl_dates$'';
         ----------------------------------------------------------------------------------------------------------

         XLA_AE_HEADER_PKG.g_rec_header_new.array_gl_date         (g_last_hdr_idx) := trunc(l_gl_dates(1));

       -- xla_ae_headers.parent_ae_header_id = 1 is wrong
       --XLA_AE_HEADER_PKG.g_rec_header_new.array_parent_header_id(g_last_hdr_idx) := g_array_event(p_event_id).array_value_num(''header_index'');
         XLA_AE_HEADER_PKG.g_rec_header_new.array_parent_header_id(g_last_hdr_idx) :=
                           XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(g_array_event(p_event_id).array_value_num(''header_index''));
         --bug:7109881 changed arrary_parent_line_num to hold Temp_Line_Number rather than g_LineNumber
       -- XLA_AE_HEADER_PKG.g_rec_header_new.array_parent_line_num (g_last_hdr_idx) := XLA_AE_LINES_PKG.g_LineNumber;
          XLA_AE_HEADER_PKG.g_rec_header_new.array_parent_line_num (g_last_hdr_idx) := XLA_AE_LINES_PKG.g_rec_lines.array_line_num(XLA_AE_LINES_PKG.g_LineNumber) ;
         XLA_AE_HEADER_PKG.g_rec_header_new.array_period_name     (g_last_hdr_idx) := l_period_names(1);

         --
         -- Populate MPA header description
         --
         $mpa_description$

         --
         -- Populate MPA header analytical criteria
         --
         $mpa_analytical_criteria$

         XLA_AE_JOURNAL_ENTRY_PKG.UpdateJournalEntryStatus (p_hdr_idx => g_last_hdr_idx);

         --
         -- Update the amount of the line accounting attribute which will be used
         -- to generate the line of the recognition entries
         --
         IF (l_accted_amt_idx IS NOT NULL) THEN
             l_rec_acct_attrs.array_num_value(l_accted_amt_idx) := l_accted_amts(1);
         END IF;
         IF (l_entered_amt_idx IS NOT NULL) THEN
             l_rec_acct_attrs.array_num_value(l_entered_amt_idx):= l_entered_amts(1);
         END IF;

         --======================================================================================
         -- Generate the first 2 Recognition Lines, one from MPA JLT 1 and one from MPA JLT 2
         -- Returns l_recog_line_1, l_recog_line_2
         --======================================================================================
         l_recog_line_1 := NULL;
         l_recog_line_2 := NULL;
         $mpa_jlt$

         --==========================================================================
         -- Create the remaining Recognition Lines from Recognition JLT 1 and JLT 2
         --==========================================================================
         IF l_recog_line_1 IS NOT NULL AND l_recog_line_2 IS NOT NULL THEN
            g_last_hdr_idx := XLA_AE_HEADER_PKG.CreateRecognitionEntries
                   (p_event_id              => p_event_id
                   ,p_num_entries           => l_num_entries
                   ,p_last_hdr_idx          => g_last_hdr_idx
                   ,p_recog_line_num_1      => l_recog_line_1
                   ,p_recog_line_num_2      => l_recog_line_2
                   ,p_gl_dates              => l_gl_dates
                   ,p_bflow_applied_to_amts  => l_bflow_applied_to_amts  -- 5132302
                   ,p_accted_amts           => l_accted_amts
                   ,p_entered_amts          => l_entered_amts);
          END IF;

	 XLA_AE_LINES_PKG.SetNullMPALineInfo ; -- added for bug: 7109881

       END IF;  -- if x_num_entries > 0

   END IF;  -- Create Multiperiod Accounting
';  -- C_MPA_BODY



-- 4262811
C_MPA_RECOG_JLT_BODY             CONSTANT VARCHAR2(10000) :=
'
RecognitionJLT_$mpa_jlt_index$
        (p_application_id        => p_application_id
        ,p_event_id              => p_event_id
        ,p_hdr_idx               => g_last_hdr_idx
        ,p_period_num            => XLA_AE_HEADER_PKG.g_mpa_line_num  -- instead of 1
        ,p_calculate_acctd_flag  => p_calculate_acctd_flag
        ,p_calculate_g_l_flag    => p_calculate_g_l_flag
        ,p_rec_acct_attrs        => l_rec_acct_attrs
        ,p_bflow_applied_to_amt  => l_bflow_applied_to_amts(1)  -- 5132302
        -- Sources
        $parameters$
        );

';  -- C_MPA_RECOG_JLT_BODY




-- 4262811
C_LINE_ACCT_BODY                 CONSTANT VARCHAR2(10000) :=
'   l_entered_amt_idx := $entered_amt_idx$;
   l_accted_amt_idx  := $accted_amt_idx$;
   l_bflow_applied_to_amt_idx  := $bflow_applied_to_amt_idx$;  -- 5132302
';  -- C_LINE_ACCT_BODY

-- 4262811
C_MPA_HDR_DESC_IDX               CONSTANT VARCHAR2(10000) := '
       -- To set value of header index for mpa description
       l_event_id := XLA_AE_HEADER_PKG.g_rec_header_new.array_event_id(g_last_hdr_idx);
';  -- C_MPA_HDR_DESC_IDX


-- 4590313
C_MPA_HDR_NO_DESC                CONSTANT VARCHAR2(10000) := '
       XLA_AE_HEADER_PKG.g_rec_header_new.array_description(g_last_hdr_idx) := NULL;
';  -- C_MPA_HDR_NO_DESC


-----------------------------------------------------------------
-- Business Flow constants - 4219869
-----------------------------------------------------------------
C_METHOD_PRIOR   CONSTANT       VARCHAR2(30) := 'PRIOR_ENTRY';
C_METHOD_SAME    CONSTANT       VARCHAR2(30) := 'SAME_ENTRY';
C_METHOD_NONE    CONSTANT       VARCHAR2(30) := 'NONE';
--


--+==========================================================================+
--|                                                                          |
--| Private global constant declarations                                     |
--|                                                                          |
--+==========================================================================+
--
--
g_chr_newline      CONSTANT VARCHAR2(10):= xla_environment_pkg.g_chr_newline;
g_package_name     VARCHAR2(30);
--
--
g_component_type                VARCHAR2(30):='AMB_JLT';
g_no_adr_assigned  BOOLEAN := FALSE; -- Bug 4922099
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_cmp_acct_line_type_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           ( p_msg                        IN VARCHAR2
           , p_level                      IN NUMBER
           , p_module                     IN VARCHAR2)
IS
BEGIN

----------------------------------------------------------------
-- Following is for FND log.
----------------------------------------------------------------
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
             (p_location   => 'xla_cmp_acct_line_type_pkg.trace');
END trace;

/*---------------------------------------------------------------+
|                                                                |
|  Private Function                                              |
|                                                                |
|     GetALTOption                                               |
|                                                                |
|  Generates in  AcctLineType_xxx() procedure the set of journal |
|  line type options                                             |
|                                                                |
+---------------------------------------------------------------*/

FUNCTION GetALTOption   (
  p_acct_entry_type_code         IN VARCHAR2
, p_gain_or_loss_flag            IN VARCHAR2
, p_natural_side_code            IN VARCHAR2
, p_transfer_mode_code           IN VARCHAR2
, p_switch_side_flag             IN VARCHAR2
, p_merge_duplicate_code         IN VARCHAR2
)
RETURN VARCHAR2
IS

C_SET_ALT_OPTION                 CONSTANT       VARCHAR2(10000):=
'l_ae_header_id:= xla_ae_lines_pkg.SetAcctLineOption(
           p_natural_side_code          => ''$natural_side_code$''
         , p_gain_or_loss_flag          => ''$gain_or_loss_flag$''
         , p_gl_transfer_mode_code      => ''$gl_transfer_mode_code$''
         , p_acct_entry_type_code       => ''$acct_entry_type_code$''
         , p_switch_side_flag           => ''$switch_side_flag$''
         , p_merge_duplicate_code       => ''$merge_duplicate_code$''
         );
   --
   l_acc_rev_natural_side_code := ''$acc_rev_natural_side_code$'';  -- 4262811
   -- ';

l_alt              VARCHAR2(32000);
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetALTOption';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetALTOption'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

l_alt := C_SET_ALT_OPTION;
l_alt := REPLACE(l_alt, '$natural_side_code$', p_natural_side_code);
l_alt := REPLACE(l_alt, '$gain_or_loss_flag$', p_gain_or_loss_flag);
l_alt := REPLACE(l_alt,'$gl_transfer_mode_code$', p_transfer_mode_code );
l_alt := REPLACE(l_alt,'$acct_entry_type_code$' , p_acct_entry_type_code);
l_alt := REPLACE(l_alt,'$switch_side_flag$'     , p_switch_side_flag );
l_alt := REPLACE(l_alt,'$merge_duplicate_code$' , p_merge_duplicate_code);

-- 4262811 --------------------------------------------------------------------------------------
IF p_natural_side_code = 'C' THEN
   l_alt := REPLACE(l_alt,'$acc_rev_natural_side_code$', 'D');
ELSE
   l_alt := REPLACE(l_alt,'$acc_rev_natural_side_code$', 'C');
END IF;
-------------------------------------------------------------------------------------------------

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetALTOption'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_alt;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetALTOption');
END GetALTOption;

/*---------------------------------------------------------------+
|                                                                |
|  Private Function                                              |
|                                                                |
|      GetAcctClassCode                                          |
|                                                                |
|  Generates in  AcctLineType_xxx() procedure the set Accounting |
|  class code                                                    |
|                                                                |
+---------------------------------------------------------------*/

FUNCTION GetAcctClassCode   (
  p_accounting_class_code        IN VARCHAR2
)
RETURN VARCHAR2
IS

C_SET_ACCT_CLASS      CONSTANT       VARCHAR2(10000):=
'xla_ae_lines_pkg.SetAcctClass(
           p_accounting_class_code  => ''$acct_class_code$''
         , p_ae_header_id           => l_ae_header_id
         );
';
l_alt              VARCHAR2(10000);
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAcctClassCode';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetAcctClassCode'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
l_alt :=NULL;
IF p_accounting_class_code IS NOT NULL THEN

   l_alt := C_SET_ACCT_CLASS;
   l_alt := REPLACE(l_alt,'$acct_class_code$', p_accounting_class_code );

END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetAcctClassCode'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_alt;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetAcctClassCode');
END GetAcctClassCode;

/*---------------------------------------------------------------+
|                                                                |
|  Private Function                                              |
|                                                                |
|      GetAcctClassCode                                          |
|                                                                |
|  Generates in AcctLineType_xxx() procedure the set Ronding     |
|  accounting class code                                         |
|                                                                |
+---------------------------------------------------------------*/

FUNCTION GetRoundingClassCode   (
  p_rounding_class_code        IN VARCHAR2
)
RETURN VARCHAR2
IS

C_SET_ROUNDING_CLASS         CONSTANT       VARCHAR2(1000):=
'XLA_AE_LINES_PKG.g_rec_lines.array_rounding_class(XLA_AE_LINES_PKG.g_LineNumber) :=
                      ''$round_class_code$'';
';
l_alt              VARCHAR2(10000);
l_log_module       VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetRoundingClassCode';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetRoundingClassCode'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_alt :=NULL;

IF p_rounding_class_code IS NOT NULL THEN

   l_alt := C_SET_ROUNDING_CLASS;
   l_alt := REPLACE(l_alt,'$round_class_code$', p_rounding_class_code );

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetRoundingClassCode'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_alt;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetRoundingClassCode');
END GetRoundingClassCode;

/*-----------------------------------------------------------------+
|                                                                  |
|  Private Function                                                |
|                                                                  |
|      GetAccountingSources                                        |
|                                                                  |
|  Generates in AcctLineType_xxx() procedure the set of accounting |
|  attribute sources                                               |
|                                                                  |
+-----------------------------------------------------------------*/

FUNCTION GetAccountingSources   (
  p_application_id               IN NUMBER
, p_accounting_line_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_amb_context_code             IN VARCHAR2
, p_array_acct_attr              IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL30   -- 4262811
, p_array_acct_attr_source       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt  -- 4262811
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN VARCHAR2
IS

C_SET_ACCT_SOURCES                CONSTANT       VARCHAR2(10000):=
'   l_rec_acct_attrs.array_acct_attr_code($index$) := ''$accounting_attribute$'';
   l_rec_acct_attrs.array_$datatype$_value($index$)  := $source$;
';

CURSOR source_cur
IS
SELECT  DISTINCT
        xals.accounting_attribute_code
      , xals.source_code
      , xals.source_type_code
      , xals.source_application_id
      , xaa.datatype_code
  FROM  xla_jlt_acct_attrs  xals
        ,xla_acct_attributes_b xaa
 WHERE  xals.application_id              = p_application_id
   AND  xals.accounting_line_code        = p_accounting_line_code
   AND  xals.accounting_line_type_code   = p_accounting_line_type_code
   AND  xals.amb_context_code            = p_amb_context_code
   AND  xals.event_class_code           = p_event_class_code
   AND  xals.source_code                 IS NOT NULL  -- 4219869  Business Flow
   AND  xals.accounting_attribute_code  = xaa.accounting_attribute_code
union
SELECT DISTINCT
        xals.accounting_attribute_code
      , xals.source_code
      , xals.source_type_code
      , xals.source_application_id
      , xaa.datatype_code
  FROM xla_evt_class_acct_attrs xals
       ,xla_acct_attributes_b xaa
 WHERE  xals.application_id              = p_application_id
   AND  xals.event_class_code           = p_event_class_code
   AND  xaa.assignment_level_code = 'EVT_CLASS_ONLY'
   AND  xaa.accounting_attribute_code=xals.accounting_attribute_code
   AND  xals.default_flag              = 'Y'
   AND  xaa.journal_entry_level_code  in ('L', 'C')
UNION
SELECT DISTINCT                            -- 4482069 To populate the transaction currency. Needed in BusinessFlowPriorEntries.
        xals.accounting_attribute_code
      , xals.source_code
      , xals.source_type_code
      , xals.source_application_id
      , xaa.datatype_code
  FROM xla_evt_class_acct_attrs xals
       ,xla_acct_attributes_b   xaa
       ,xla_jlt_acct_attrs      xjaa
 WHERE  xals.application_id             = p_application_id
   AND  xals.event_class_code           = p_event_class_code
   AND  xaa.accounting_attribute_code=xals.accounting_attribute_code
   AND  xals.default_flag               = 'Y'
   AND  xals.accounting_attribute_code  = 'ENTERED_CURRENCY_CODE'
   AND  xjaa.application_id             = p_application_id
   AND  xjaa.accounting_line_code       = p_accounting_line_code
   AND  xjaa.accounting_line_type_code  = p_accounting_line_type_code
   AND  xjaa.amb_context_code           = p_amb_context_code
   AND  xjaa.event_class_code           = p_event_class_code
   AND  xjaa.source_code                 IS NULL
   AND  xjaa.accounting_attribute_code  = xaa.accounting_attribute_code
   ;

l_alt                       VARCHAR2(32000);
l_temp                      VARCHAR2(10000);
l_array_acct_source_code    xla_cmp_source_pkg.t_array_VL30;
l_array_source_code         xla_cmp_source_pkg.t_array_VL30;
l_array_source_type_code    xla_cmp_source_pkg.t_array_VL1;
l_array_acct_data_type_code xla_cmp_source_pkg.t_array_VL1;
l_array_application_id      xla_cmp_source_pkg.t_array_Num;
l_source_Idx                BINARY_INTEGER;
l_index                     NUMBER;
l_log_module                VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAccountingSources';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GetAccountingSources'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'p_accounting_line_code = '||p_accounting_line_code||
                        ' - p_accounting_line_type_code = '||p_accounting_line_type_code||
                        '# SQL - Fetch xla_acct_line_sources '
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_index := 0;

OPEN  source_cur;

FETCH source_cur BULK COLLECT INTO l_array_acct_source_code
                                 , l_array_source_code
                                 , l_array_source_type_code
                                 , l_array_application_id
                                 , l_array_acct_data_type_code
                                 ;
CLOSE source_cur;

l_alt := C_LINE_ACCT_BODY;  -- 4262811

IF l_array_acct_source_code.COUNT > 0 THEN
  FOR Idx IN l_array_acct_source_code.FIRST .. l_array_acct_source_code.LAST LOOP

    IF l_array_source_code(Idx) IS NOT NULL THEN
       l_index := l_index + 1;

       l_source_Idx := xla_cmp_source_pkg.StackSource (
                    p_source_code             => l_array_source_code(Idx)
                  , p_source_type_code        => l_array_source_type_code(Idx)
                  , p_source_application_id   => l_array_application_id(Idx)
                  , p_array_source_index      => p_array_alt_source_index
                  , p_rec_sources             => p_rec_sources
                  );

       l_alt := l_alt || C_SET_ACCT_SOURCES ;

       l_alt  := REPLACE(l_alt,'$index$',to_char(l_index));
       l_alt  := REPLACE(l_alt,'$accounting_attribute$',l_array_acct_source_code(Idx));

       IF l_array_acct_data_type_code(Idx) = 'C' and p_rec_sources.array_datatype_code(l_source_Idx) = 'N' THEN
         l_temp:=xla_cmp_source_pkg.GenerateSource(
                                  p_Index            => l_source_Idx
                                , p_rec_sources      => p_rec_sources
                               , p_translated_flag  => 'N');
         IF(l_temp is null) THEN
           l_temp := ' null';
         ELSE
           l_temp := ' to_char('||l_temp||')';
         END IF;
         l_alt  := REPLACE(l_alt,'$source$'  , l_temp);
       ELSE
         l_alt  := REPLACE(l_alt,'$source$'  ,
                               nvl(xla_cmp_source_pkg.GenerateSource(
                                   p_Index            => l_source_Idx
                                 , p_rec_sources      => p_rec_sources
                                 , p_translated_flag  => 'N'),' null')
                                );
       END IF;

       CASE p_rec_sources.array_datatype_code(l_source_Idx)
          WHEN 'F' THEN
             l_alt  := REPLACE(l_alt,'$datatype$','num') ;
          WHEN 'I' THEN
             l_alt  := REPLACE(l_alt,'$datatype$','num') ;
          WHEN 'N' THEN
             l_alt  := REPLACE(l_alt,'$datatype$','num') ;
/*
             IF l_array_acct_data_type_code(Idx) = 'C' THEN
               l_alt  := REPLACE(l_alt,'$datatype$','char') ;
             ELSE
               l_alt  := REPLACE(l_alt,'$datatype$','num') ;
             END IF;
*/
          WHEN 'C' THEN
             l_alt  := REPLACE(l_alt,'$datatype$','char') ;
          WHEN 'D' THEN
             l_alt  := REPLACE(l_alt,'$datatype$','date') ;
          ELSE
             l_alt  := REPLACE(l_alt,'$datatype$',p_rec_sources.array_datatype_code(l_source_Idx)) ;
       END CASE;

       ---------------------------------------------------------------------------------------------
       -- 4262811
       ---------------------------------------------------------------------------------------------
       p_array_acct_attr(Idx)        := l_array_acct_source_code(Idx);
       p_array_acct_attr_source(Idx) := l_source_idx;

       ---------------------------------------------------------------------------------------------
       -- 4262811 - for C_LINE_ACCT_BODY:  entered_amt_idx, accted_amt_idx
       ---------------------------------------------------------------------------------------------
       IF (l_array_acct_source_code(Idx) = 'ENTERED_CURRENCY_AMOUNT') THEN
           l_alt := REPLACE(l_alt, '$entered_amt_idx$', to_char(l_index));
       END IF;
       --
       IF (l_array_acct_source_code(Idx) = 'LEDGER_AMOUNT') THEN
           l_alt := REPLACE(l_alt, '$accted_amt_idx$', to_char(l_index));
       END IF;
       --
       ---------------------------------------------------------------------------------------------
       -- 5132302
       ---------------------------------------------------------------------------------------------
       IF (l_array_acct_source_code(Idx) = 'APPLIED_TO_AMOUNT') THEN
           l_alt := REPLACE(l_alt, '$bflow_applied_to_amt_idx$', to_char(l_index));
       END IF;
       --------------------------------------------------------------------------------------------

    END IF;

  END LOOP;
ELSE
  l_alt := 'null;';
END IF;

-----------------------------------------------------------------------------------------
-- 4262811 - if not set above, then following will set it to null
-----------------------------------------------------------------------------------------
l_alt := REPLACE(l_alt, '$bflow_applied_to_amt_idx$','NULL');  -- 5132302
l_alt := REPLACE(l_alt, '$entered_amt_idx$','NULL');
l_alt := REPLACE(l_alt, '$accted_amt_idx$','NULL');

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetAccountingSources = '||length(l_alt)
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

RETURN l_alt;

EXCEPTION
  WHEN VALUE_ERROR THEN
   IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      IF source_cur%ISOPEN THEN CLOSE source_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetAccountingSources');
END GetAccountingSources;

/*-----------------------------------------------------------------+
|                                                                  |
|  Private Function                                                |
|                                                                  |
|    GetCallAnalyticCriteria                                       |
|                                                                  |
|  Generates in AcctLineType_xxx() the set of analytical criteria  |
|                                                                  |
+-----------------------------------------------------------------*/

FUNCTION GetCallAnalyticCriteria   (
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_accounting_line_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
l_analytic_criteria         CLOB; -- VARCHAR2(32000);
l_log_module                VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetCallAnalyticCriteria';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetCallAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
l_analytic_criteria := xla_cmp_analytic_criteria_pkg.GenerateLineAnalyticCriteria(
                          p_application_id             => p_application_id
                        , p_amb_context_code           => p_amb_context_code
                        , p_event_class                => p_event_class
                        , p_event_type                 => p_event_type
                        , p_line_definition_owner_code => p_line_definition_owner_code
                        , p_line_definition_code       => p_line_definition_code
                        , p_accounting_line_code       => p_accounting_line_code
                        , p_accounting_line_type_code  => p_accounting_line_type_code
                        , p_array_alt_source_index     => p_array_alt_source_index
                        , p_rec_sources                => p_rec_sources
                        );
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetCallAnalyticCriteria'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_analytic_criteria;
--
EXCEPTION
   WHEN VALUE_ERROR THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetCallAnalyticCriteria');
END GetCallAnalyticCriteria;

/*---------------------------------------------------------------+
|                                                                |
|  Private Function                                              |
|                                                                |
|      GetOverrideSegFLag                                        |
|                                                                |                                                 |
|      Check if segments overrides ccid or not                   |
+---------------------------------------------------------------*/

FUNCTION GetOverrideSegFlag   (
  p_array_adr_segment_code        IN xla_cmp_source_pkg.t_array_VL30
)
RETURN VARCHAR2
IS

l_override_seg_flag  VARCHAR2(1);
l_log_module         VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetOverrideSegFlag';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetOverrideSegFlag'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_override_seg_flag := 'N';

IF p_array_adr_segment_code.COUNT > 0 THEN
   FOR i IN p_array_adr_segment_code.FIRST .. p_array_adr_segment_code.LAST LOOP

      IF p_array_adr_segment_code(i) = 'ALL' THEN
         --
         -- 'All Segments' does exist
         --
         l_override_seg_flag := 'Y';

         --
         -- Exit Loop;
         --
         EXIT;

      END IF;

   END LOOP;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetOverrideSegFlag'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

RETURN l_override_seg_flag;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetOverrideSegFlag');
END GetOverrideSegFlag;


/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|  GenerateCallDescription                                 |
|                                                          |
|  Generates in AcctLineType_xxx() a call to appropriate   |
|  Description_x() function (description assigned to       |
|  journal line definition).                               |
|                                                          |
+----------------------------------------------------------*/

FUNCTION GenerateCallDescription  (
  p_application_id               IN NUMBER
, p_description_type_code        IN VARCHAR2
, p_description_code             IN VARCHAR2
, p_header_line                  IN VARCHAR2
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS

C_CALL_LINE_DESC                    CONSTANT      VARCHAR2(10000):= '
xla_ae_lines_pkg.SetLineDescription(
   p_ae_header_id => l_ae_header_id
  ,p_description  => Description_$desc_index$ (
     p_application_id         => p_application_id
   , p_ae_header_id           => l_ae_header_id $parameters$
   )
);

'; -- C_CALL_LINE_DESC


l_desc             CLOB;
l_ObjectIndex      BINARY_INTEGER;
l_ObjectType       VARCHAR2(1);
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateCallDescription';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateCallDescription'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'application_id = '  ||p_application_id ||
                        ' - p_description_type_code = ' ||p_description_type_code ||
                        ' - p_description_code = '    ||p_description_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_desc  :=  NULL;

IF p_application_id         IS NOT NULL AND
   p_description_type_code  IS NOT NULL AND
   p_description_code       IS NOT NULL
THEN
    l_ObjectIndex :=xla_cmp_source_pkg.GetAADObjectPosition(
               p_object                   => xla_cmp_source_pkg.C_DESC
             , p_object_code              => p_description_code
             , p_object_type_code         => p_description_type_code
             , p_application_id           => p_application_id
             , p_rec_aad_objects          => p_rec_aad_objects
              );

    l_ObjectType:= xla_cmp_source_pkg.C_DESC;

    IF l_ObjectIndex IS NOT NULL THEN

       IF p_header_line = 'L' THEN      -- 4262811
          xla_cmp_source_pkg.GetSourcesInAADObject(
                             p_object                   => l_ObjectType
                           , p_object_code              => p_description_code
                           , p_object_type_code         => p_description_type_code
                           , p_application_id           => p_application_id
                           , p_array_source_Index       => p_array_alt_source_index
                           , p_rec_aad_objects          => p_rec_aad_objects
           );

          l_desc  := C_CALL_LINE_DESC;
          l_desc  := xla_cmp_string_pkg.replace_token(l_desc,'$desc_index$',TO_CHAR(l_ObjectIndex));  -- 4417664
          l_desc  := xla_cmp_string_pkg.replace_token(l_desc,'$parameters$',
                     xla_cmp_call_fct_pkg.GetSourceParameters(
                            p_array_source_index  => p_rec_aad_objects.array_array_object(l_ObjectIndex)
                          , p_rec_sources         => p_rec_sources
                          )
                     );
       --------------------------------------------------------------------------------------------------------------
       -- 4262811 to call xla_ae_header_pkg.SetHdrDescription in Multiperiod Accounting Option inside AcctLineType_xx
       --------------------------------------------------------------------------------------------------------------
       ELSE -- p_header_line = 'H'

          -- 4590313 --------------------------------------------------------------
          xla_cmp_source_pkg.GetSourcesInAADObject(
                             p_object                   => l_ObjectType
                           , p_object_code              => p_description_code
                           , p_object_type_code         => p_description_type_code
                           , p_application_id           => p_application_id
                           , p_array_source_Index       => p_array_alt_source_index
                           , p_rec_aad_objects          => p_rec_aad_objects);
          -------------------------------------------------------------------------

          l_desc := xla_cmp_event_type_pkg.GenerateHdrDescription(
                             p_hdr_description_index  => l_ObjectIndex
                           , p_rec_aad_objects        => p_rec_aad_objects
                           , p_rec_sources            => p_rec_sources
                           );
       END IF;

    ELSE

      IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= issue to generate a call to description ='
                         ||p_description_code
                         ||' - '||p_description_type_code
                         ||' - '||p_application_id

         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
      END IF;
      l_desc  :=NULL;
    END IF;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateCallDescription '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_desc;
EXCEPTION
   WHEN VALUE_ERROR THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GenerateCallDescription');
END GenerateCallDescription;


/*---------------------------------------------------------+
|                                                          |
|  Public  Function                                        |
|                                                          |
|  GenerateADRCalls - 4262811                              |
|                                                          |
|                                                          |
+----------------------------------------------------------*/

FUNCTION GenerateADRCalls  (
  p_application_id               IN NUMBER
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_array_adr_type_code          IN xla_cmp_source_pkg.t_array_VL1
, p_array_adr_code               IN xla_cmp_source_pkg.t_array_VL30
, p_array_adr_segment_code       IN xla_cmp_source_pkg.t_array_VL30
, p_array_side_code              IN xla_cmp_source_pkg.t_array_VL30
, p_array_adr_appl_id            IN xla_cmp_source_pkg.t_array_NUM
, p_array_inherit_adr_flag       IN xla_cmp_source_pkg.t_array_VL1
, p_bflow_method_code            IN VARCHAR2  -- 4655713
, p_array_accounting_coa_id      IN xla_cmp_source_pkg.t_array_NUM
, p_array_transaction_coa_id     IN xla_cmp_source_pkg.t_array_NUM
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_aad_objects              IN            xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN  CLOB
IS
l_adrs                          CLOB;
l_adr                           CLOB;
l_ObjectIndex                   BINARY_INTEGER;
l_log_module                    VARCHAR2(240);

--ccid ADR
C_CALL_SET_CCID   CONSTANT VARCHAR2(10000):=
'
  l_ccid := AcctDerRule_$adr_index$(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id $parameters$
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_value_type_code          => l_adr_value_type_code
         , p_side                     => ''$Side$''
   );

   xla_ae_lines_pkg.set_ccid(
    p_code_combination_id          => l_ccid
  , p_value_type_code              => l_adr_value_type_code
  , p_transaction_coa_id           => l_adr_transaction_coa_id
  , p_accounting_coa_id            => l_adr_accounting_coa_id
  , p_adr_code                     => ''$adr_code$''
  , p_adr_type_code                => ''$adr_type_code$''
  , p_component_type               => l_component_type
  , p_component_code               => l_component_code
  , p_component_type_code          => l_component_type_code
  , p_component_appl_id            => l_component_appl_id
  , p_amb_context_code             => l_amb_context_code
  , p_side                         => ''$Side$''
  );

';
--segment ADR
C_CALL_SET_SEGMENT   CONSTANT VARCHAR2(10000):=
'
   l_segment := AcctDerRule_$adr_index$(
           p_application_id           => p_application_id
         , p_ae_header_id             => l_ae_header_id $parameters$
         , x_transaction_coa_id       => l_adr_transaction_coa_id
         , x_accounting_coa_id        => l_adr_accounting_coa_id
         , x_flexfield_segment_code   => l_adr_flexfield_segment_code
         , x_flex_value_set_id        => l_adr_flex_value_set_id
         , x_value_type_code          => l_adr_value_type_code
         , x_value_combination_id     => l_adr_value_combination_id
         , x_value_segment_code       => l_adr_value_segment_code
         , p_side                     => ''$Side$''
         , p_override_seg_flag        => ''$override_seg_flag$''
   );

   IF NVL(l_segment,''NULL'') <> ''#$NO_OVERRIDE#$'' THEN  -- 4465612

      xla_ae_lines_pkg.set_segment(
          p_to_segment_code         => ''$segment_code$''
        , p_segment_value           => l_segment
        , p_from_segment_code       => l_adr_value_segment_code
        , p_from_combination_id     => l_adr_value_combination_id
        , p_value_type_code         => l_adr_value_type_code
        , p_transaction_coa_id      => l_adr_transaction_coa_id
        , p_accounting_coa_id       => l_adr_accounting_coa_id
        , p_flexfield_segment_code  => l_adr_flexfield_segment_code
        , p_flex_value_set_id       => l_adr_flex_value_set_id
        , p_adr_code                => ''$adr_code$''
        , p_adr_type_code           => ''$adr_type_code$''
        , p_component_type          => l_component_type
        , p_component_code          => l_component_code
        , p_component_type_code     => l_component_type_code
        , p_component_appl_id       => l_component_appl_id
        , p_amb_context_code        => l_amb_context_code
        , p_entity_code             => ''$entity_code$''
        , p_event_class_code        => ''$event_class_code$''
        , p_side                    => ''$Side$''
        );

  END IF;
';

-----------------------------------------------------------------
-- Insert CCID - 4219869 Business Flow
-- This is the template use for the xla_ae_lines_pkg.SetCcid API.
-----------------------------------------------------------------
C_CCID           CONSTANT       VARCHAR2(10000):='
   xla_ae_lines_pkg.Set_Ccid(                         -- replaced SetCcid
     p_code_combination_id      => TO_NUMBER(C_NUM)
   , p_value_type_code          => NULL
   , p_transaction_coa_id       => $transaction_coa_id$
   , p_accounting_coa_id        => $accounting_coa_id$
   , p_adr_code                 => NULL
   , p_adr_type_code            => NULL
   , p_component_type           => l_component_type
   , p_component_code           => l_component_code
   , p_component_type_code      => l_component_type_code
   , p_component_appl_id        => l_component_appl_id
   , p_amb_context_code         => l_amb_context_code
   , p_side                     => NULL
   );

   $default_segments$
   --
';

-----------------------------------------------------------------
-- Default segments - 4655713
-----------------------------------------------------------------
C_DEFAULT_SEGMENTS        CONSTANT       VARCHAR2(10000):='
  -- initialise segments
  XLA_AE_LINES_PKG.g_rec_lines.array_segment1(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment2(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment3(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment4(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment5(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment6(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment7(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment8(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment9(XLA_AE_LINES_PKG.g_LineNumber)  := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment10(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment11(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment12(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment13(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment14(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment15(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment16(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment17(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment18(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment19(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment20(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment21(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment22(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment23(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment24(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment25(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment26(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment27(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment28(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment29(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  XLA_AE_LINES_PKG.g_rec_lines.array_segment30(XLA_AE_LINES_PKG.g_LineNumber) := C_CHAR;
  --
';

-----------------------------------------------------------------
-- Insert Segment- 4219869 Business Flow
-- This is the template use for the xla_ae_lines_pkg.Set_Segment API.
-----------------------------------------------------------------
C_SEGMENT        CONSTANT       VARCHAR2(10000):='
   xla_ae_lines_pkg.Set_Segment(                           -- replaced SetSegment
     p_to_segment_code         => ''$flexfield_segment_code$''
   , p_segment_value           => C_CHAR
   , p_from_segment_code       => NULL
   , p_from_combination_id     => NULL
   , p_value_type_code         => NULL
   , p_transaction_coa_id      => $transaction_coa_id$
   , p_accounting_coa_id       => $accounting_coa_id$
   , p_flexfield_segment_code  => NULL
   , p_flex_value_set_id       => NULL
   , p_adr_code                => NULL
   , p_adr_type_code           => NULL
   , p_component_type          => l_component_type
   , p_component_code          => l_component_code
   , p_component_type_code     => l_component_type_code
   , p_component_appl_id       => l_component_appl_id
   , p_amb_context_code        => l_amb_context_code
   , p_entity_code             => ''$entity_code$''
   , p_event_class_code        => ''$event_class_code$''
   , p_side                    => ''$Side$''
   );
   --
';

--

BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateADRCalls';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateADRCalls'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;


l_adrs := NULL;
l_adr  := NULL;

-- START ----------------------------------------------------------------------------------------------------
IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace(p_msg    => '# ADR = '||p_array_adr_code.COUNT
        ,p_level  => C_LEVEL_STATEMENT
        ,p_module => l_log_module);
END IF;

IF p_array_adr_code.COUNT > 0 THEN

FOR Idx IN p_array_adr_code.FIRST .. p_array_adr_code.LAST LOOP

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN

          trace
             (p_msg      => 'array_inherit_adr_flag = '||p_array_inherit_adr_flag(Idx)
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);

          trace
             (p_msg      => 'array_accounting_coa_id = '||to_char(p_array_accounting_coa_id(Idx))
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);

          trace
             (p_msg      => 'array_transaction_coa_id = '||to_char(p_array_transaction_coa_id(Idx))
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);

          trace
             (p_msg      => 'bflow_method = '||p_bflow_method_code
             ,p_level    => C_LEVEL_STATEMENT
             ,p_module   => l_log_module);

   END IF;

   ----------------------------------------------------
   -- 4219869
   -- To inherit ADR segments for Business Flow
   ----------------------------------------------------
   IF NVL(p_array_inherit_adr_flag(Idx),'N') = 'Y' THEN
      IF (p_array_adr_segment_code(Idx) = 'ALL') THEN

           IF p_array_transaction_coa_id(Idx) IS NOT NULL THEN
              l_adr := REPLACE(C_CCID,'$transaction_coa_id$' ,TO_CHAR(p_array_transaction_coa_id(Idx)));
           ELSE
              l_adr := REPLACE(C_CCID,'$transaction_coa_id$' ,'null');
           END IF;

           IF p_array_accounting_coa_id(Idx) IS NOT NULL THEN
              l_adr := xla_cmp_string_pkg.replace_token(l_adr,'$accounting_coa_id$'  ,TO_CHAR(p_array_accounting_coa_id(Idx)));  -- 4417664
           ELSE
              l_adr := xla_cmp_string_pkg.replace_token(l_adr,'$accounting_coa_id$'  ,'null');  -- 4417664
           END IF;

           -- 4655713 initialis all segments to C_CHAR ------------------------------------------------------
           IF NVL(p_bflow_method_code,C_METHOD_NONE) = C_METHOD_SAME THEN
              l_adr := xla_cmp_string_pkg.replace_token(l_adr,'$default_segments$'  , C_DEFAULT_SEGMENTS);
           ELSE
              l_adr := xla_cmp_string_pkg.replace_token(l_adr,'$default_segments$'  ,'-- Business flow method is NONE.');
           END IF;
           --------------------------------------------------------------------------------------------------

           l_adr  := l_adr  || g_chr_newline;
           l_adrs := l_adrs || l_adr;
      ELSE

           IF p_array_transaction_coa_id(Idx) IS NOT NULL THEN
              l_adr := REPLACE(C_SEGMENT,'$transaction_coa_id$' ,TO_CHAR(p_array_transaction_coa_id(Idx)));
           ELSE
              l_adr := REPLACE(C_SEGMENT,'$transaction_coa_id$' ,'null');
           END IF;

           IF p_array_accounting_coa_id(Idx) IS NOT NULL THEN
              l_adr := xla_cmp_string_pkg.replace_token(l_adr,'$accounting_coa_id$'  ,TO_CHAR(p_array_accounting_coa_id(Idx)));  -- 4417664
           ELSE
              l_adr := xla_cmp_string_pkg.replace_token(l_adr,'$accounting_coa_id$'  ,'null');  -- 4417664
           END IF;

           l_adr  := xla_cmp_string_pkg.replace_token(l_adr, '$flexfield_segment_code$'   , p_array_adr_segment_code(Idx));  -- 4417664
           l_adr  := xla_cmp_string_pkg.replace_token(l_adr, '$Side$',p_array_side_code(Idx));  -- 4417664
           l_adr  := xla_cmp_string_pkg.replace_token(l_adr, '$entity_code$', p_entity_code );  -- 4417664
           l_adr  := xla_cmp_string_pkg.replace_token(l_adr, '$event_class_code$', p_event_class_code);  -- 4417664
           l_adr  := l_adr  || g_chr_newline;
           l_adrs := l_adrs || l_adr;

      END IF;

   ELSIF p_array_adr_code.EXISTS(Idx) THEN

      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
           trace(p_msg    => ' # ADR code = '||p_array_adr_code(Idx)||
                             ' - ADR owner = '||p_array_adr_type_code(Idx)||
                             ' - ADR type = '||p_array_adr_segment_code(Idx)
          ,p_level  => C_LEVEL_STATEMENT
          ,p_module => l_log_module);

      END IF;


      l_ObjectIndex := xla_cmp_source_pkg.GetAADObjectPosition(
                 p_object                   => xla_cmp_source_pkg.C_ADR
               , p_object_code              => p_array_adr_code(Idx)
               , p_object_type_code         => p_array_adr_type_code(Idx)
               , p_application_id           => p_array_adr_appl_id(Idx)
               , p_rec_aad_objects          => p_rec_aad_objects
               );

      IF l_ObjectIndex IS NOT NULL THEN

           xla_cmp_source_pkg.GetSourcesInAADObject(
              p_object                   => xla_cmp_source_pkg.C_ADR
            , p_object_code              => p_array_adr_code(Idx)
            , p_object_type_code         => p_array_adr_type_code(Idx)
            , p_application_id           => p_array_adr_appl_id(Idx)
            , p_array_source_Index       => p_array_alt_source_index
            , p_rec_aad_objects          => p_rec_aad_objects
            );

           IF p_array_adr_segment_code(Idx) = 'ALL' THEN

              l_adr  := C_CALL_SET_CCID;
              l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$adr_index$',TO_CHAR(l_ObjectIndex));  -- 4417664
              l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$adr_code$', p_array_adr_code(Idx));  -- 4417664
              l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$Side$',p_array_side_code(Idx));  -- 4417664
              l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$adr_type_code$', p_array_adr_type_code(Idx));  -- 4417664
              l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$entity_code$', p_entity_code );  -- 4417664
              l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$event_class_code$', p_event_class_code);  -- 4417664

           ELSE

               l_adr  := C_CALL_SET_SEGMENT;
               l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$adr_index$',TO_CHAR(l_ObjectIndex));  -- 4417664
               l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$segment_code$',p_array_adr_segment_code(Idx));   -- 4417664
               l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$Side$',p_array_side_code(Idx));  -- 4417664
               l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$adr_code$', p_array_adr_code(Idx));  -- 4417664
               l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$adr_type_code$', p_array_adr_type_code(Idx));  -- 4417664
               l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$entity_code$', p_entity_code );  -- 4417664
               l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$event_class_code$', p_event_class_code);  -- 4417664
               --
               -- bug 4307087
               --
               l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$override_seg_flag$'
                                       ,GetOverrideSegFlag (p_array_adr_segment_code));  -- 4417664
           END IF;

           l_adr  := xla_cmp_string_pkg.replace_token( l_adr,'$parameters$',
                           xla_cmp_call_fct_pkg.GetSourceParameters(
                               p_array_source_index  => p_rec_aad_objects.array_array_object(l_ObjectIndex)
                             , p_rec_sources         => p_rec_sources
                             )
                          );

           l_adrs := l_adrs || l_adr;


      ELSE

           IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
               trace
                    (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR= inable to generate call to ADR '||
                                    p_array_adr_code(Idx)
                                    ||' - '|| p_array_adr_type_code(Idx)
                    ,p_level    => C_LEVEL_EXCEPTION
                    ,p_module   => l_log_module);
           END IF;

      END IF;  -- l_ObjectIndex IS NOT NULL

   END IF;   -- NVL(p_array_inherit_adr_flag(Idx),'N') = 'Y'

END LOOP;  -- FOR Idx
END IF;  --  p_array_adr_code.COUNT > 0

-- END   ----------------------------------------------------------------------------------------------------

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateADRCalls '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

RETURN l_adrs;

EXCEPTION
  WHEN VALUE_ERROR THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GenerateADRCalls');
END GenerateADRCalls;



/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|  GenerateCallADR                                         |
|                                                          |
|  Generates in AcctLineType_xxx() a call appropriate      |
|  AcctDerRule_x() functions (ADRs assigned to  journal    |
|  line definition).                                       |
|                                                          |
+----------------------------------------------------------*/

FUNCTION GenerateCallADR  (
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_event_type_code              IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_accounting_line_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_bflow_method_code            IN VARCHAR2  -- 4655713
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN  CLOB
IS

CURSOR adr_cur IS
SELECT DISTINCT
        NVL(xlda.segment_rule_appl_id,xlda.application_id)
      , xlda.segment_rule_type_code
      , xlda.segment_rule_code
      , xlda.flexfield_segment_code
      , xlda.side_code
      , xlda.inherit_adr_flag            -- 4219869 Business Flow
      , xld.accounting_coa_id            -- 4219869 Business Flow
      , xld.transaction_coa_id           -- 4219869 Business Flow
  FROM  xla_line_defn_adr_assgns    xlda
      , xla_line_defn_jlt_assgns    xldj
      , xla_line_definitions_b      xld  -- 4219869 Business Flow
 WHERE xldj.application_id             =  p_application_id
   AND xldj.amb_context_code           =  p_amb_context_code
   AND xldj.line_definition_owner_code =  p_line_definition_owner_code
   AND xldj.line_definition_code       =  p_line_definition_code
   AND xldj.event_class_code           =  p_event_class_code
   AND ( xldj.event_type_code          =  p_event_type_code
       OR
         xldj.event_type_code          =  xldj.event_class_code || '_ALL'
       )
   AND xldj.accounting_line_type_code  =  p_accounting_line_type_code
   AND xldj.accounting_line_code       =  p_accounting_line_code
   --
   AND xlda.application_id             = xldj.application_id
   AND xlda.amb_context_code           = xldj.amb_context_code
   AND xlda.event_class_code           = xldj.event_class_code
   AND xlda.event_type_code            = xldj.event_type_code
   AND xlda.line_definition_owner_code = xldj.line_definition_owner_code
   AND xlda.line_definition_code       = xldj.line_definition_code
   AND xlda.accounting_line_type_code  = xldj.accounting_line_type_code
   AND xlda.accounting_line_code       = xldj.accounting_line_code
   AND xld.application_id              = xldj.application_id             -- 4219869  Business Flow
   AND xld.amb_context_code            = xldj.amb_context_code           -- 4219869  Business Flow
   AND xld.event_class_code            = xldj.event_class_code           -- 4219869  Business Flow
   AND xld.event_type_code             = xldj.event_type_code            -- 4219869  Business Flow
   AND xld.line_definition_owner_code  = xldj.line_definition_owner_code -- 4219869  Business Flow
   AND xld.line_definition_code        = xldj.line_definition_code       -- 4219869  Business Flow
--ORDER BY xlda.inherit_adr_flag, xlda.segment_rule_code                 -- 4219869  Business Flow, process non-inherited first
ORDER BY decode(xlda.FLEXFIELD_SEGMENT_CODE,'ALL',1,2),                  -- 4655713  process ALL segment first
         xlda.inherit_adr_flag, xlda.segment_rule_code
;

l_adrs                          CLOB;
--
l_array_adr_appl_id             xla_cmp_source_pkg.t_array_Num;
l_array_adr_type_code           xla_cmp_source_pkg.t_array_VL1;
l_array_adr_code                xla_cmp_source_pkg.t_array_VL30;
l_array_adr_segment_code        xla_cmp_source_pkg.t_array_VL30;
l_array_side_code               xla_cmp_source_pkg.t_array_VL30;
l_array_inherit_adr_flag        xla_cmp_source_pkg.t_array_VL1;   -- 4219869  Business Flow
l_array_accounting_coa_id       xla_cmp_source_pkg.t_array_Num;   -- 4219869  Business Flow
l_array_transaction_coa_id      xla_cmp_source_pkg.t_array_Num;   -- 4219869  Business Flow
--
l_ObjectIndex                   BINARY_INTEGER;
l_log_module                    VARCHAR2(240);

BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateCallADR';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateCallADR'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'application_id = '       ||p_application_id  ||
                        ' - amb_context_code = '    ||p_amb_context_code ||
                        ' - event_class_code = '    ||p_event_class_code ||
                        ' - event_type_code = '     ||p_event_type_code  ||
                        ' - line_definition_code = '||p_line_definition_code ||
                                               '-'||p_line_definition_owner_code ||
                        ' - accounting_line_code = '||p_accounting_line_code ||
                                               '-'||p_accounting_line_type_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

OPEN adr_cur;
FETCH adr_cur BULK COLLECT INTO    l_array_adr_appl_id
                                 , l_array_adr_type_code
                                 , l_array_adr_code
                                 , l_array_adr_segment_code
                                 , l_array_side_code
                                 , l_array_inherit_adr_flag        -- 4219869 Business Flow
                                 , l_array_accounting_coa_id       -- 4219869 Business Flow
                                 , l_array_transaction_coa_id      -- 4219869 Business Flow
                                 ;
CLOSE adr_cur;

l_adrs := NULL;
g_adrs := NULL;

-- 4262811 --------------------------------------------
l_adrs :=  GenerateADRCalls
                   (p_application_id
                   ,p_entity_code
                   ,p_event_class_code
                   ,l_array_adr_type_code
                   ,l_array_adr_code
                   ,l_array_adr_segment_code
                   ,l_array_side_code
                   ,l_array_adr_appl_id
                   ,l_array_inherit_adr_flag
                   ,p_bflow_method_code    -- 4655713
                   ,l_array_accounting_coa_id
                   ,l_array_transaction_coa_id
                   ,p_array_alt_source_index
                   ,p_rec_aad_objects
                   ,p_rec_sources);
-- added bug 7444204
g_adrs := l_adrs;
-- end bug 7444204
-------------------------------------------------------

-- 4922099 ------------------------------------------------------
IF (l_array_adr_appl_id.COUNT = 0) THEN
  g_no_adr_assigned := TRUE;
ELSE
  g_no_adr_assigned := FALSE;
END IF;
-----------------------------------------------------------------


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateCallADR '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

RETURN l_adrs;

EXCEPTION
  WHEN VALUE_ERROR THEN
   IF adr_cur%ISOPEN THEN CLOSE adr_cur; END IF;
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF adr_cur%ISOPEN THEN CLOSE adr_cur; END IF;
        RETURN NULL;
   WHEN OTHERS THEN
      IF adr_cur%ISOPEN THEN CLOSE adr_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GenerateCallADR');
END GenerateCallADR;

/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|     GetEncumbranceTypeId                                 |
|                                                          |
|  Retrieve encumbrance type id                            |
|                                                          |
+---------------------------------------------------------*/

FUNCTION GetEncumbranceTypeId  (
  p_encumbrance_type_id          IN INTEGER
)
RETURN VARCHAR2
IS
l_alt              VARCHAR2(2000);
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetEncumbranceTypeId';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetEncumbranceTypeId'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

l_alt := NULL;
IF (p_encumbrance_type_id IS NOT NULL) THEN
  l_alt := C_SET_ENCUMBRANCE_TYPE_ID;
  l_alt := REPLACE(l_alt, '$encumbrance_type_id$', p_encumbrance_type_id);
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetEncumbranceTypeId'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_alt;
EXCEPTION
   WHEN VALUE_ERROR THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetEncumbranceTypeId');
END GetEncumbranceTypeId;



/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|     GenerateCallMpaJLT   - 4262811                       |
|                                                          |
|                                                          |
|                                                          |
+---------------------------------------------------------*/
FUNCTION GenerateCallMpaJLT  (
  p_application_id               IN NUMBER
, p_mpa_jlt_owner_code           IN VARCHAR2
, p_mpa_jlt_code                 IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_line_num                     IN NUMBER
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
--
)
RETURN CLOB
IS

l_line             CLOB;
l_ObjectIndex      NUMBER;
l_log_module       VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateCallMpaJLT';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'BEGIN of GenerateCallMpaJLT'
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
   END IF;

   l_line             := NULL;
   l_ObjectIndex      := NULL;

   l_ObjectIndex := xla_cmp_source_pkg.GetAADObjectPosition(
              p_object                       => xla_cmp_source_pkg.C_RECOG_JLT     -- C_MPA_JLT
            , p_object_code                  => p_mpa_jlt_code
            , p_object_type_code             => p_mpa_jlt_owner_code
            , p_application_id               => p_application_id
            , p_line_definition_owner_code   => p_line_definition_owner_code
            , p_line_definition_code         => p_line_definition_code
            , p_event_class_code             => p_event_class
            , p_event_type_code              => p_event_type
            , p_rec_aad_objects              => p_rec_aad_objects);


   IF l_ObjectIndex IS NOT NULL THEN

      xla_cmp_source_pkg.GetSourcesInAADObject(
                 p_object                       => xla_cmp_source_pkg.C_RECOG_JLT     -- C_MPA_JLT
               , p_object_code                  => p_mpa_jlt_code
               , p_object_type_code             => p_mpa_jlt_owner_code
               , p_application_id               => p_application_id
               , p_line_definition_owner_code   => p_line_definition_owner_code
               , p_line_definition_code         => p_line_definition_code
               , p_event_class_code             => p_event_class
               , p_event_type_code              => p_event_type
               , p_array_source_Index           => p_array_alt_source_index
               , p_rec_aad_objects              => p_rec_aad_objects);

      l_line := C_MPA_RECOG_JLT_BODY;
      l_line := xla_cmp_string_pkg.replace_token(l_line,'$mpa_jlt_index$',TO_CHAR(l_ObjectIndex));
      l_line := xla_cmp_string_pkg.replace_token(l_line,'$parameters$',
                    xla_cmp_call_fct_pkg.GetSourceParameters(
                           p_array_source_index  => p_rec_aad_objects.array_array_object(l_ObjectIndex)
                         , p_rec_sources         => p_rec_sources));
   ELSE
      IF (C_LEVEL_STATEMENT >= g_log_level) THEN
         trace
         (p_msg      => 'MPA procedure not generated for application_id = '     ||p_application_id  ||
                        ' - p_mpa_jlt_code = '  ||p_mpa_jlt_code ||
                                             '-'||p_mpa_jlt_owner_code||
                        ' - p_event_class = '   ||p_event_class ||
                        ' - p_event_type = '    ||p_event_type ||
                        ' - line_definition_code = '||p_line_definition_code ||
                                               '-'||p_line_definition_owner_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
      END IF;

      l_line  := NULL;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateCallMpaJLT'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_line;

EXCEPTION
   WHEN VALUE_ERROR THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
        xla_exceptions_pkg.raise_message
           (p_location => 'xla_cmp_acct_line_type_pkg.GenerateCallMpaJLT');
END GenerateCallMpaJLT;



/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|     GetAcctAttrSourceIdx - 4262811                       |
|                                                          |
|                                                          |
|                                                          |
+---------------------------------------------------------*/
FUNCTION GetAcctAttrSourceIdx  (
  p_acct_attr_code              IN VARCHAR2
, p_array_acct_attr             IN xla_cmp_source_pkg.t_array_VL30
, p_array_acct_attr_source_idx  IN xla_cmp_source_pkg.t_array_ByInt
)
RETURN NUMBER
IS

l_source_idx         NUMBER;
l_log_module         VARCHAR2(240);

BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAcctAttrSourceIdx';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetAcctAttrSourceIdx'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   l_source_idx    := NULL;
   --
   IF p_array_acct_attr.COUNT > 0 THEN
   --
      FOR Idx IN p_array_acct_attr.FIRST .. p_array_acct_attr.LAST LOOP
          --
          IF p_array_acct_attr.EXISTS(Idx) AND p_array_acct_attr(Idx) = p_acct_attr_code THEN
             l_source_idx := p_array_acct_attr_source_idx(Idx);
             EXIT;
          END IF;
          --
      END LOOP;
    --
   END IF;
   --

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetAcctAttrSourceIdx'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   RETURN l_source_idx;

EXCEPTION
   WHEN VALUE_ERROR THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
        trace
          (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
          ,p_level    => C_LEVEL_EXCEPTION
          ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
        xla_exceptions_pkg.raise_message
           (p_location => 'xla_cmp_acct_line_type_pkg.GetAcctAttrSourceIdx');
END GetAcctAttrSourceIdx;



/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|     GenerateMpaBody - 4262811                            |
|                                                          |
|                                                          |
|                                                          |
+---------------------------------------------------------*/

FUNCTION GenerateMpaBody (
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_accounting_line_code         IN VARCHAR2
, p_mpa_header_desc_type_code    IN VARCHAR2
, p_mpa_header_desc_code         IN VARCHAR2
, p_num_je_code                  IN VARCHAR2
, p_gl_dates_code                IN VARCHAR2
, p_proration_code               IN VARCHAR2
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_acct_attr              IN            xla_cmp_source_pkg.t_array_VL30
, p_array_acct_attr_source_idx   IN            xla_cmp_source_pkg.t_array_ByInt
, p_rec_aad_objects              IN            xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN CLOB
IS
--
-- Only two rows - Recognition Line 1 (for ACCRUAL) and Recognition Line 2 (for non ACCRUAL)
CURSOR c_mpa_jlt IS
  SELECT mpa_accounting_line_type_code
       , mpa_accounting_line_code
       , description_type_code
       , description_code
    FROM xla_mpa_jlt_assgns
   WHERE application_id             = p_application_id
     AND amb_context_code           = p_amb_context_code
     AND event_class_code           = p_event_class
     AND event_type_code            = p_event_type
     AND line_definition_owner_code = p_line_definition_owner_code
     AND line_definition_code       = p_line_definition_code
     AND accounting_line_type_code  = p_accounting_line_type_code
     AND accounting_line_code       = p_accounting_line_code;

i                       NUMBER;
l_alt                   CLOB;
l_body                  CLOB;
l_body2                 CLOB := NULL;
l_mpa_jlt               c_mpa_jlt%ROWTYPE;
l_mpa_jlt_body          CLOB;
l_log_module            VARCHAR2(240);

l_mpa_option_source_idx      NUMBER;
l_mpa_start_date_source_idx  NUMBER;
l_mpa_end_date_source_idx    NUMBER;


BEGIN
   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateMpaBody';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateMpaBody'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'application_id = '       ||p_application_id  ||
                        ' - amb_context_code = '    ||p_amb_context_code ||
                        ' - event_class      = '    ||p_event_class      ||
                        ' - event_type      = '     ||p_event_type       ||
                        ' - num_je_entries  = '     ||p_num_je_code  ||
                        ' - line_definition_code = '||p_line_definition_code ||
                                               '-'||p_line_definition_owner_code ||
                        ' - accounting_line_code = '||p_accounting_line_code ||
                                               '-'||p_accounting_line_type_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

   END IF;

   l_alt         := NULL;
   l_body        := NULL;
   p_IsCompiled  := TRUE;

   l_mpa_option_source_idx := GetAcctAttrSourceIdx
                (p_acct_attr_code             => 'MULTIPERIOD_OPTION'
                ,p_array_acct_attr            => p_array_acct_attr
                ,p_array_acct_attr_source_idx => p_array_acct_attr_source_idx);

   IF (l_mpa_option_source_idx IS NULL) OR
       p_gl_dates_code IS NULL OR p_num_je_code IS NULL THEN  -- prevent generating incorrect MPA header
      l_body := '  -- No MPA option is assigned.';
   ELSE

      l_mpa_start_date_source_idx := GetAcctAttrSourceIdx
                (p_acct_attr_code             => 'MULTIPERIOD_START_DATE'
                ,p_array_acct_attr            => p_array_acct_attr
                ,p_array_acct_attr_source_idx => p_array_acct_attr_source_idx);

      l_mpa_end_date_source_idx := GetAcctAttrSourceIdx
                (p_acct_attr_code             => 'MULTIPERIOD_END_DATE'
                ,p_array_acct_attr            => p_array_acct_attr
                ,p_array_acct_attr_source_idx => p_array_acct_attr_source_idx);

      IF l_mpa_start_date_source_idx IS NULL OR l_mpa_end_date_source_idx IS NULL THEN
         l_body := '  -- No MPA Start Date or End Date.' ;  -- 4262811

      ELSE
         l_body := C_MPA_BODY;

         --
         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_option$',
                     xla_cmp_source_pkg.GenerateSource(
                          p_Index                     => l_mpa_option_source_idx
                        , p_rec_sources               => p_rec_sources
                        , p_translated_flag           => 'N')
                        );
         --
         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_start_date$',
                     xla_cmp_source_pkg.GenerateSource(
                          p_Index                     => l_mpa_start_date_source_idx
                        , p_rec_sources               => p_rec_sources
                        , p_translated_flag           => 'N')
                        );
         --
         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_end_date$',
                     xla_cmp_source_pkg.GenerateSource(
                          p_Index                     => l_mpa_end_date_source_idx
                        , p_rec_sources               => p_rec_sources
                        , p_translated_flag           => 'N')
                        );

         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_gl_dates$', p_gl_dates_code);        -- p_mpa_gl_date_code
         --
         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_num_je$', p_num_je_code);            -- p_mpa_num_je_code

         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_proration_code$', p_proration_code); -- 4262811

         -- Generate MPA header description -------------------------------------------
         l_body2:= GenerateCallDescription
                       (p_application_id         => p_application_id
                       ,p_description_type_code  => p_mpa_header_desc_type_code
                       ,p_description_code       => p_mpa_header_desc_code
                       ,p_header_line            => 'H'                        -- Header
                       ,p_array_alt_source_index => p_array_alt_source_index
                       ,p_rec_aad_objects        => p_rec_aad_objects
                       ,p_rec_sources            => p_rec_sources);
         IF l_body2 IS NOT NULL THEN
            l_body2 := C_MPA_HDR_DESC_IDX || l_body2;

         ELSE
            l_body2 := C_MPA_HDR_NO_DESC; -- 4590313
         END IF;

         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_description$', l_body2);
         --------------------------------------------------------------------------------

         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_analytical_criteria$',
                     xla_cmp_analytic_criteria_pkg.GenerateMpaHeaderAC(
                         p_application_id             => p_application_id
                       , p_amb_context_code           => p_amb_context_code
                       , p_event_class                => p_event_class
                       , p_event_type                 => p_event_type
                       , p_line_definition_owner_code => p_line_definition_owner_code
                       , p_line_definition_code       => p_line_definition_code
                       , p_accrual_jlt_owner_code     => p_accounting_line_type_code
                       , p_accrual_jlt_code           => p_accounting_line_code
                       , p_array_alt_source_index     => p_array_alt_source_index
                       , p_rec_sources                => p_rec_sources
                       ));

         i := 0;
         l_mpa_jlt_body := NULL;
         FOR l_mpa_jlt IN c_mpa_jlt LOOP
              i := i + 1;
              l_body2 := NULL;
              l_body2 := GenerateCallMpaJLT(
                                        p_application_id             => p_application_id
                                      , p_mpa_jlt_owner_code         => l_mpa_jlt.mpa_accounting_line_type_code
                                      , p_mpa_jlt_code               => l_mpa_jlt.mpa_accounting_line_code
                                      , p_event_class                => p_event_class
                                      , p_event_type                 => p_event_type
                                      , p_line_definition_owner_code => p_line_definition_owner_code
                                      , p_line_definition_code       => p_line_definition_code
                                      , p_line_num                   => i
                                      , p_array_alt_source_index     => p_array_alt_source_index
                                      , p_rec_sources                => p_rec_sources
                                      , p_rec_aad_objects            => p_rec_aad_objects);
              IF l_body2 IS NOT NULL THEN
                 l_mpa_jlt_body := l_mpa_jlt_body ||'l_recog_line_'||to_char(i)||' := ' || l_body2;
		 l_mpa_jlt_body := l_mpa_jlt_body ||'XLA_AE_LINES_PKG.InsertMPARecogLineInfo( l_recog_line_'||to_char(i)||' );
		 ';-- added for bug:7109881
              END IF;
         END LOOP;

         l_body := xla_cmp_string_pkg.replace_token(l_body, '$mpa_jlt$',l_mpa_jlt_body);

      END IF;  -- l_mpa_start_date_source_idx IS NULL

   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
         trace
            (p_msg      => 'END of GenerateMpaBody '
            ,p_level    => C_LEVEL_PROCEDURE
            ,p_module   => l_log_module);
   END IF;

   RETURN l_body;

EXCEPTION

   WHEN VALUE_ERROR THEN
        IF c_mpa_jlt%ISOPEN THEN CLOSE c_mpa_jlt; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
        trace
          (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
          ,p_level    => C_LEVEL_EXCEPTION
          ,p_module   => l_log_module);
        END IF;
        p_IsCompiled := FALSE;
        RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF c_mpa_jlt%ISOPEN THEN CLOSE c_mpa_jlt; END IF;
        p_IsCompiled := FALSE;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN NULL;
   WHEN OTHERS THEN
        IF c_mpa_jlt%ISOPEN THEN CLOSE c_mpa_jlt; END IF;
        p_IsCompiled := FALSE;
        xla_exceptions_pkg.raise_message
           (p_location => 'xla_cmp_acct_line_type_pkg.GenerateMpaBody');

END GenerateMpaBody;

/*---------------------------------------------------------+
|                                                          |
|  Private Function - 4262811                              |
|                                                          |
|     GetAccRevMPABody                                     |
|                                                          |
|                                                          |
+---------------------------------------------------------*/

FUNCTION GetAccRevMPABody (
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class                  IN VARCHAR2
, p_event_type                   IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_accounting_line_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_mpa_header_desc_type_code    IN VARCHAR2
, p_mpa_header_desc_code         IN VARCHAR2
, p_num_je_code                  IN VARCHAR2
, p_gl_dates_code                IN VARCHAR2
, p_proration_code               IN VARCHAR2
--
, p_bflow_method_code           IN VARCHAR2
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
, p_array_acct_attr              IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL30  -- 4262811
, p_array_acct_attr_source_idx   IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt -- 4262811
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
l_alt              CLOB;
l_log_module       VARCHAR2(240);
l_IsCompiled       BOOLEAN;

BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAccRevMPABody';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetAccRevMPABody'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'application_id = '       ||p_application_id  ||
                        ' - amb_context_code = '    ||p_amb_context_code ||
                        ' - event_class      = '    ||p_event_class      ||
                        ' - event_type      = '     ||p_event_type       ||
                        ' - num_je_entries  = '     ||p_num_je_code  ||
                        ' - line_definition_code = '||p_line_definition_code ||
                                               '-'||p_line_definition_owner_code ||
                        ' - accounting_line_code = '||p_accounting_line_code ||
                                               '-'||p_accounting_line_type_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

l_alt := C_ACC_REV_MPA_BODY;

--added bug 7444204
IF p_line_definition_code       IS NOT NULL AND
   p_line_definition_owner_code IS NOT NULL AND
   p_accounting_line_code       IS NOT NULL AND
   p_accounting_line_type_code  IS NOT NULL THEN
--   p_bflow_method_code <> C_METHOD_PRIOR THEN Bug 4922099
--
   l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$call_adr$'
                , g_adrs
                );
ELSE
   l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$call_adr$'
                ,'-- No adrs. ');
END IF; --end  bug 7444204



l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$mpa_body$',
              GenerateMpaBody (
                      p_application_id               => p_application_id
                    , p_amb_context_code             => p_amb_context_code
                    , p_event_class                  => p_event_class
                    , p_event_type                   => p_event_type
                    , p_line_definition_owner_code   => p_line_definition_owner_code
                    , p_line_definition_code         => p_line_definition_code
                    , p_accounting_line_type_code    => p_accounting_line_type_code
                    , p_accounting_line_code         => p_accounting_line_code
                    , p_mpa_header_desc_type_code    => p_mpa_header_desc_type_code
                    , p_mpa_header_desc_code         => p_mpa_header_desc_code
                    , p_num_je_code                  => p_num_je_code
                    , p_gl_dates_code                => p_gl_dates_code
                    , p_proration_code               => p_proration_code
                    , p_array_alt_source_index       => p_array_alt_source_index
                    , p_array_acct_attr              => p_array_acct_attr
                    , p_array_acct_attr_source_idx   => p_array_acct_attr_source_idx
                    , p_rec_aad_objects              => p_rec_aad_objects
                    , p_rec_sources                  => p_rec_sources
                    , p_IsCompiled                   => l_IsCompiled
                     )
                     );

RETURN l_alt;

EXCEPTION
   WHEN VALUE_ERROR THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetAccRevMPABody');
END GetAccRevMPABody;


/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|     GetALTBody                                           |
|                                                          |
|  Generates one Journal Line Definition in the procedure  |
|  AcctLineType_xxx().                                     |
|                                                          |
+---------------------------------------------------------*/

FUNCTION GetALTBody   (
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_event_type_code              IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
--
, p_accounting_line_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_accounting_line_name         IN VARCHAR2
--
, p_description_type_code        IN VARCHAR2
, p_description_code             IN VARCHAR2
--
, p_acct_entry_type_code         IN VARCHAR2
, p_natural_side_code            IN VARCHAR2
, p_transfer_mode_code           IN VARCHAR2
, p_switch_side_flag             IN VARCHAR2
, p_merge_duplicate_code         IN VARCHAR2
, p_accounting_class_code        IN VARCHAR2
, p_rounding_class_code          IN VARCHAR2
, p_gain_or_loss_flag            IN VARCHAR2
--
, p_bflow_method_code            IN VARCHAR2  -- 4219869 Business Flow
, p_bflow_class_code             IN VARCHAR2  -- 4219869 Business Flow
, p_inherit_desc_flag            IN VARCHAR2  -- 4219869 Business Flow
--
, p_encumbrance_type_id          IN INTEGER   -- 4458381 Public Sector Enh
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
--
,p_array_acct_attr               IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL30  -- 4262811
,p_array_acct_attr_source_idx    IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt -- 4262811
--
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
)
RETURN CLOB
IS
l_alt              CLOB;
l_log_module       VARCHAR2(240);


BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetALTBody';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetALTBody'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN

      trace
         (p_msg      => 'application_id = '       ||p_application_id  ||
                        ' - amb_context_code = '    ||p_amb_context_code ||
                        ' - p_entity_code = '       ||p_entity_code ||
                        ' - event_class_code = '    ||p_event_class_code ||
                        ' - event_type_code = '     ||p_event_type_code  ||
                        ' - line_definition_code = '||p_line_definition_code ||
                                               '-'||p_line_definition_owner_code ||
                        ' - accounting_line_code = '||p_accounting_line_code ||
                                               '-'||p_accounting_line_type_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);

END IF;

l_alt := C_ALT_BODY;
IF((p_gain_or_loss_flag is null or p_gain_or_loss_flag = 'N') AND p_natural_side_code <> 'G') THEN
  l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$set_actual_enc_flag$', '
   IF(l_balance_type_code = ''A'' and p_actual_flag is null) THEN
     p_actual_flag :=''A'';
   END IF;');
ELSE
  l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$set_actual_enc_flag$', '
   IF(l_balance_type_code = ''A'' ) THEN
     p_actual_flag :=''G'';
   END IF;');
END IF;

--
-- set accounting line type
--
--
l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$acct_line_options$'
                ,GetALTOption
                   (p_acct_entry_type_code
                   ,nvl(p_gain_or_loss_flag, 'N')
                   ,p_natural_side_code
                   ,p_transfer_mode_code
                   ,p_switch_side_flag
                   ,p_merge_duplicate_code)
                );
--
l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$set_acct_class$'
                ,GetAcctClassCode
                   (p_accounting_class_code)
                );
--
l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$set_rounding_class$'
                ,GetRoundingClassCode
                   (p_rounding_class_code)
                );
-- 4458381 Public Sector Enh
IF (p_acct_entry_type_code = 'E') THEN
  l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$set_encumbrance_type_id$'
                ,GetEncumbranceTypeId(p_encumbrance_type_id));
ELSE
  l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$set_encumbrance_type_id$'
                ,'');
END IF;
--
l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$alt_acct_attributes$'
                ,GetAccountingSources
                   (p_application_id
                   ,p_accounting_line_code
                   ,p_accounting_line_type_code
                   ,p_entity_code
                   ,p_event_class_code
                   ,p_amb_context_code
                   ,p_array_acct_attr             -- 4262811  IN OUT
                   ,p_array_acct_attr_source_idx  -- 4262811  IN OUT
                   ,p_array_alt_source_index      --          IN OUT
                   ,p_rec_sources)                --          IN OUT
                );
--
----------------------------------------------------------------------------
-- 4219869
-- Perform Business Flow validation only if business flow method is not NONE
----------------------------------------------------------------------------
IF p_bflow_method_code <> C_METHOD_NONE THEN
  l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$call_bflow_validation$'
                ,'XLA_AE_LINES_PKG.business_flow_validation(
                                p_business_method_code     => l_bflow_method_code
                               ,p_business_class_code      => l_bflow_class_code
                               ,p_inherit_description_flag => l_inherit_desc_flag);');
ELSE
  l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$call_bflow_validation$'
                ,'-- No business flow processing for business flow method of NONE.');
END IF;
--

-----------------------------------------------
-- 4219869 Business Flow
-- Do not generate AC for Prior Entry method
-----------------------------------------------
IF p_bflow_method_code <> C_METHOD_PRIOR THEN
  l_alt := xla_cmp_string_pkg.replace_token(l_alt
                  ,'$call_analytical_criteria$'
                  ,GetCallAnalyticCriteria
                     (p_application_id
                     ,p_amb_context_code
                     ,p_event_class_code
                     ,p_event_type_code
                     ,p_line_definition_code
                     ,p_line_definition_owner_code
                     ,p_accounting_line_code
                     ,p_accounting_line_type_code
                     ,p_array_alt_source_index
                     ,p_rec_sources)
                 );
ELSE  -- 4219869 - Do not generate AC for Prior Entry method
  l_alt := xla_cmp_string_pkg.replace_token(l_alt
                  ,'$call_analytical_criteria$'
                  ,'-- Inherited Analytical Criteria for business flow method of Prior Entry.');
END IF;


-----------------------------------------------
-- 4219869 Business Flow
-- Do not generate Description if it is inherited
-----------------------------------------------
IF p_description_type_code IS NOT NULL AND
   p_description_code      IS NOT NULL AND
   nvl(p_inherit_desc_flag,'N') = 'N' THEN
   --
   -- generate call to description functions
   --
   l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$call_description$'
                ,GenerateCallDescription
                       (p_application_id         => p_application_id
                       ,p_description_type_code  => p_description_type_code
                       ,p_description_code       => p_description_code
                       ,p_header_line            => 'L'                        -- line
                       ,p_array_alt_source_index => p_array_alt_source_index
                       ,p_rec_aad_objects        => p_rec_aad_objects
                       ,p_rec_sources            => p_rec_sources)
                );
  --
ELSE
   l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$call_description$'
                ,'-- No description or it is inherited.');
END IF;
--
--
-----------------------------------------------
-- 4219869 Business Flow
-- Do not generate ADR for Prior Entry method
--------------------------------------------------------------------
-- 4922099
-- NOTE: ADR is now also defined for prior entry business flow JLT.
--       THe upgrade option is not known until the run-time.
--------------------------------------------------------------------
IF p_line_definition_code       IS NOT NULL AND
   p_line_definition_owner_code IS NOT NULL AND
   p_accounting_line_code       IS NOT NULL AND
   p_accounting_line_type_code  IS NOT NULL THEN
--   p_bflow_method_code <> C_METHOD_PRIOR THEN Bug 4922099
--
   l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$call_adr$'
                ,GenerateCallADR
                   (p_application_id
                   ,p_amb_context_code
                   ,p_entity_code
                   ,p_event_class_code
                   ,p_event_type_code
                   ,p_line_definition_code
                   ,p_line_definition_owner_code
                   ,p_accounting_line_code
                   ,p_accounting_line_type_code
                   ,p_bflow_method_code             -- 4655713
                   ,p_array_alt_source_index
                   ,p_rec_aad_objects
                   ,p_rec_sources)
                );
ELSE
   l_alt := xla_cmp_string_pkg.replace_token(l_alt
                ,'$call_adr$'
                ,'-- No adrs. ');
END IF;

---------------------------------------------------------------------------------
-- 4922099
IF (g_no_adr_assigned) THEN
   l_alt := xla_cmp_string_pkg.replace_token(l_alt, '$no_adr_assigned$', '1 = 1');
ELSE
   l_alt := xla_cmp_string_pkg.replace_token(l_alt, '$no_adr_assigned$', '1 = 2');
END IF;

-- reset the global variable
g_no_adr_assigned := FALSE;

-------------------------------------------------------------------------
-- 4219869
-- Call validate line only if the Business Flow method is not Prior Entry
-------------------------------------------------------------------------
IF p_bflow_method_code <> C_METHOD_PRIOR THEN
   l_alt := xla_cmp_string_pkg.replace_token(l_alt
                 ,'$call_validate_line$'
                 ,'XLA_AE_LINES_PKG.ValidateCurrentLine;'
                 );
ELSE
   l_alt := xla_cmp_string_pkg.replace_token(l_alt
                 ,'$call_validate_line$'
                 ,'-- No ValidateCurrentLine for business flow method of Prior Entry');
END IF;
--

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GetALTBody'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_alt;
EXCEPTION
   WHEN VALUE_ERROR THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
      trace
         (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
         ,p_level    => C_LEVEL_EXCEPTION
         ,p_module   => l_log_module);
   END IF;
   RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        RETURN NULL;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetALTBody');
END GetALTBody;


/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|     GetAcctLineTypeBody                                  |
|                                                          |
|  Generates one Journal Line Definition ad its condition  |
|  in the procedure  AcctLineType_xxx().                   |
|                                                          |
+---------------------------------------------------------*/

FUNCTION GetAcctLineTypeBody   (
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_event_type_code              IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
--
, p_accounting_line_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_accounting_line_name         IN VARCHAR2
--
, p_description_type_code        IN VARCHAR2
, p_description_code             IN VARCHAR2
--
, p_acct_entry_type_code         IN VARCHAR2
, p_natural_side_code            IN VARCHAR2
, p_transfer_mode_code           IN VARCHAR2
, p_switch_side_flag             IN VARCHAR2
, p_merge_duplicate_code         IN VARCHAR2
, p_accounting_class_code        IN VARCHAR2
, p_rounding_class_code          IN VARCHAR2
, p_gain_or_loss_flag            IN VARCHAR2
--
, p_bflow_method_code            IN VARCHAR2  -- 4219869 Business Flow
, p_bflow_class_code             IN VARCHAR2  -- 4219869 Business Flow
, p_inherit_desc_flag            IN VARCHAR2  -- 4219869 Business Flow
--
, p_num_je_code                  IN VARCHAR2  -- 4262811
, p_gl_dates_code                IN VARCHAR2  -- 4262811
, p_proration_code               IN VARCHAR2  -- 4262811
, p_mpa_header_desc_type_code    IN VARCHAR2  -- 4262811
, p_mpa_header_desc_code         IN VARCHAR2  -- 4262811
--
, p_budgetary_control_flag       IN VARCHAR2  -- 4458381 Public Sector Enh
, p_encumbrance_type_id          IN INTEGER   -- 4458381 Public Sector Enh
--
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
--
, p_array_acct_attr              IN OUT NOCOPY xla_cmp_source_pkg.t_array_VL30  -- 4262811
, p_array_acct_attr_source_idx   IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt -- 4262811
--
, p_rec_aad_objects              IN xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
--
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN CLOB
IS
--
l_alt              CLOB;
l_detail           CLOB;
l_cond             VARCHAR2(32000);
l_log_module       VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GetAcctLineTypeBody';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GetAcctLineTypeBody'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'application_id = '       ||p_application_id  ||
                        ' - amb_context_code = '    ||p_amb_context_code ||
                        ' - p_entity_code = '       ||p_entity_code ||
                        ' - event_class_code = '    ||p_event_class_code ||
                        ' - event_type_code = '     ||p_event_type_code  ||
                        ' - num_je_entries  = '     ||p_num_je_code  ||
                        ' - line_definition_code = '||p_line_definition_code ||
                                               '-'||p_line_definition_owner_code ||
                        ' - accounting_line_code = '||p_accounting_line_code ||
                                               '-'||p_accounting_line_type_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_alt         := NULL;
l_detail      := NULL;
p_IsCompiled  := FALSE;

l_cond := xla_cmp_condition_pkg.GetCondition   (
        p_application_id             => p_application_id
      , p_component_type             => 'AMB_JLT'
      , p_component_code             => p_accounting_line_code
      , p_component_type_code        => p_accounting_line_type_code
      , p_component_name             => p_accounting_line_name
      , p_entity_code                => p_entity_code
      , p_event_class_code           => p_event_class_code
      , p_amb_context_code           => p_amb_context_code
      , p_acctg_line_code            => p_accounting_line_code
      , p_acctg_line_type_code       => p_accounting_line_type_code
      , p_array_cond_source_index    => p_array_alt_source_index
      , p_rec_sources                => p_rec_sources
       );

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => ' # condition length = ' ||length(l_cond)
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_detail := GetALTBody   (
       p_application_id              => p_application_id
     , p_amb_context_code            => p_amb_context_code
     , p_entity_code                 => p_entity_code
     , p_event_class_code            => p_event_class_code
     , p_event_type_code             => p_event_type_code
     , p_line_definition_code        => p_line_definition_code
     , p_line_definition_owner_code  => p_line_definition_owner_code
     , p_accounting_line_code        => p_accounting_line_code
     , p_accounting_line_type_code   => p_accounting_line_type_code
     , p_accounting_line_name        => p_accounting_line_name
     , p_description_type_code       => p_description_type_code
     , p_description_code            => p_description_code
     , p_acct_entry_type_code        => p_acct_entry_type_code
     , p_natural_side_code           => p_natural_side_code
     , p_transfer_mode_code          => p_transfer_mode_code
     , p_switch_side_flag            => p_switch_side_flag
     , p_merge_duplicate_code        => p_merge_duplicate_code
     , p_accounting_class_code       => p_accounting_class_code
     , p_rounding_class_code         => p_rounding_class_code
     , p_gain_or_loss_flag           => p_gain_or_loss_flag
     , p_bflow_method_code           => p_bflow_method_code          -- 4219869 Business Flow
     , p_bflow_class_code            => p_bflow_class_code           -- 4219869 Business Flow
     , p_inherit_desc_flag           => p_inherit_desc_flag          -- 4219869 Business Flow
     , p_encumbrance_type_id         => p_encumbrance_type_id        -- 4458381 Public Sector Enh
     , p_array_alt_source_index      => p_array_alt_source_index
     , p_array_acct_attr             => p_array_acct_attr            -- 4262811
     , p_array_acct_attr_source_idx  => p_array_acct_attr_source_idx -- 4262811
     , p_rec_aad_objects             => p_rec_aad_objects
     , p_rec_sources                 => p_rec_sources
      );
------------------------------------------------------------------------------------
-- 4262811
------------------------------------------------------------------------------------
l_detail := l_detail || GetAccRevMPABody(
                      p_application_id               => p_application_id
                    , p_amb_context_code             => p_amb_context_code
                    , p_entity_code                  => p_entity_code
                    , p_event_class                  => p_event_class_code
                    , p_event_type                   => p_event_type_code
                    , p_line_definition_owner_code   => p_line_definition_owner_code
                    , p_line_definition_code         => p_line_definition_code
                    , p_accounting_line_type_code    => p_accounting_line_type_code
                    , p_accounting_line_code         => p_accounting_line_code
                    , p_mpa_header_desc_type_code    => p_mpa_header_desc_type_code
                    , p_mpa_header_desc_code         => p_mpa_header_desc_code
                    , p_num_je_code                  => p_num_je_code
                    , p_gl_dates_code                => p_gl_dates_code
                    , p_proration_code               => p_proration_code
                    , p_bflow_method_code           => p_bflow_method_code
                    , p_array_alt_source_index       => p_array_alt_source_index
                    , p_array_acct_attr              => p_array_acct_attr
                    , p_array_acct_attr_source_idx   => p_array_acct_attr_source_idx
                    , p_rec_aad_objects              => p_rec_aad_objects
                    , p_rec_sources                  => p_rec_sources
                     );
------------------------------------------------------------------------------------

IF l_detail IS NULL THEN l_detail := 'null;'; END IF;

IF l_cond IS NOT NULL THEN
  l_alt := 'IF '|| l_cond||' THEN '||g_chr_newline ;
  l_alt :=  l_alt || l_detail || g_chr_newline ||'END IF;';
ELSE
  l_alt := l_detail;
END IF;

p_IsCompiled :=TRUE;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'END of GetAcctLineTypeBody '
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;
RETURN l_alt;
EXCEPTION
   WHEN VALUE_ERROR THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
        trace
          (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR='||sqlerrm
          ,p_level    => C_LEVEL_EXCEPTION
          ,p_module   => l_log_module);
        END IF;
        p_IsCompiled := FALSE;
        RETURN NULL;
   WHEN xla_exceptions_pkg.application_exception   THEN
        p_IsCompiled := FALSE;
        RETURN NULL;
   WHEN OTHERS THEN
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GetAcctLineTypeBody');
END GetAcctLineTypeBody;



/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|     GenerateDefAcctLineType                              |
|                                                          |
|  Generates AcctLineType_xxx() procedure                  |
|                                                          |
+---------------------------------------------------------*/

FUNCTION GenerateDefAcctLineType(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_event_type_code              IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
--
, p_accounting_line_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_accounting_line_name         IN VARCHAR2
 --
, p_description_type_code        IN VARCHAR2
, p_description_code             IN VARCHAR2
--
, p_acct_entry_type_code         IN VARCHAR2
, p_natural_side_code            IN VARCHAR2
, p_transfer_mode_code           IN VARCHAR2
, p_switch_side_flag             IN VARCHAR2
, p_merge_duplicate_code         IN VARCHAR2
, p_accounting_class_code        IN VARCHAR2
, p_rounding_class_code          IN VARCHAR2
, p_gain_or_loss_flag            IN VARCHAR2
--
, p_bflow_method_code            IN VARCHAR2  -- 4219869 Business Flow
, p_bflow_class_code             IN VARCHAR2  -- 4219869 Business Flow
, p_inherit_desc_flag            IN VARCHAR2  -- 4219869 Business Flow
--
, p_num_je_code                  IN VARCHAR2  -- 4262811
, p_gl_dates_code                IN VARCHAR2  -- 4262811
, p_proration_code               IN VARCHAR2  -- 4262811
, p_mpa_header_desc_type_code    IN VARCHAR2  -- 4262811
, p_mpa_header_desc_code         IN VARCHAR2  -- 4262811
--
, p_budgetary_control_flag       IN VARCHAR2  -- 4458381 Public Sector Enh
, p_encumbrance_type_id          IN INTEGER   -- 4458381 Public Sector Enh
--
, p_array_alt_source_index       IN OUT NOCOPY xla_cmp_source_pkg.t_array_ByInt
--
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
--
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
--
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN CLOB
IS

l_alt              CLOB;
l_parameters       VARCHAR2(32000);
l_ObjectIndex      BINARY_INTEGER;
l_log_module       VARCHAR2(240);
l_array_acct_attr              xla_cmp_source_pkg.t_array_VL30;  -- 4262811
l_array_acct_attr_source_idx   xla_cmp_source_pkg.t_array_ByInt; -- 4262811
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateDefAcctLineType';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN

      trace
         (p_msg      => 'BEGIN of GenerateDefAcctLineType'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'application_id = '       ||p_application_id  ||
                        ' - amb_context_code = '    ||p_amb_context_code ||
                        ' - p_entity_code = '       ||p_entity_code ||
                        ' - event_class_code = '    ||p_event_class_code ||
                        ' - event_type_code = '     ||p_event_type_code  ||
                        ' - line_definition_code = '||p_line_definition_code ||
                                               '-'||p_line_definition_owner_code ||
                        ' - accounting_line_code = '||p_accounting_line_code ||
                                               '-'||p_accounting_line_type_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_alt := C_ALT_PROC;
IF(p_natural_side_code = 'G') THEN
  l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$alt_proc_gain_or_loss_cond$',
            'IF NOT ((p_calculate_g_l_flag = ''Y'' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> ''ALC'') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in (''ALC'', ''SECONDARY'') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag=''Y'')) THEN
               return;
  END IF;
  ');
ELSIF(p_gain_or_loss_flag is null or p_gain_or_loss_flag = 'N') THEN
  l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$alt_proc_gain_or_loss_cond$', ' ');
ELSE
  -- only execute for primary, vm-secondary, secondary with same currency of primary
  l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$alt_proc_gain_or_loss_cond$',
            'IF ((p_calculate_g_l_flag = ''Y'' AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code <> ''ALC'') or
            (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code in (''ALC'', ''SECONDARY'') AND XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag=''Y'')) THEN
               return;
  END IF;
  ');
/*
  l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$alt_proc_gain_or_loss_cond$',
            'IF p_calculate_g_l_flag = ''Y'' OR (NOT ((XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id =
             XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id) OR
             (XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.ledger_category_code = ''SECONDARY'' AND
             XLA_AE_JOURNAL_ENTRY_PKG.g_cache_ledgers_info.calculate_amts_flag=''N''))) THEN
               return;
  END IF;
  ');
*/
END IF;
--
-- 4458381, 5394730 (replicate BC JEs to secondary/ALC for Actual and encumbrance)
--IF (p_budgetary_control_flag = 'N') THEN
  l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$alt_proc_cond$',
'IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id = XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id OR
    l_balance_type_code <> ''B'' THEN');
/*
ELSE
  l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$alt_proc_cond$',
'IF XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.budgetary_control_flag = l_budgetary_control_flag AND
   XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.target_ledger_id =
             XLA_AE_JOURNAL_ENTRY_PKG.g_cache_event.ledger_id THEN');
END IF;
*/

l_alt := xla_cmp_string_pkg.replace_token(l_alt,'$alt_body$',
       GetAcctLineTypeBody   (
         p_application_id                => p_application_id
       , p_amb_context_code              => p_amb_context_code
       , p_entity_code                   => p_entity_code
       , p_event_class_code              => p_event_class_code
       , p_event_type_code               => p_event_type_code
       , p_line_definition_code          => p_line_definition_code
       , p_line_definition_owner_code    => p_line_definition_owner_code
       --
       , p_accounting_line_code          => p_accounting_line_code
       , p_accounting_line_type_code     => p_accounting_line_type_code
       , p_accounting_line_name          => p_accounting_line_name
       --
       , p_description_type_code         => p_description_type_code
       , p_description_code              => p_description_code
       --
       , p_acct_entry_type_code          => p_acct_entry_type_code
       , p_natural_side_code             => p_natural_side_code
       , p_transfer_mode_code            => p_transfer_mode_code
       , p_switch_side_flag              => p_switch_side_flag
       , p_merge_duplicate_code          => p_merge_duplicate_code
       , p_accounting_class_code         => p_accounting_class_code
       , p_rounding_class_code           => p_rounding_class_code
       , p_gain_or_loss_flag             => p_gain_or_loss_flag
       --
       , p_bflow_method_code             => p_bflow_method_code       -- 4219869 Business Flow
       , p_bflow_class_code              => p_bflow_class_code        -- 4219869 Business Flow
       , p_inherit_desc_flag             => p_inherit_desc_flag       -- 4219869 Business Flow
       --
       , p_mpa_header_desc_type_code    => p_mpa_header_desc_type_code -- 4262811
       , p_mpa_header_desc_code         => p_mpa_header_desc_code      -- 4262811
       , p_num_je_code                  => p_num_je_code               -- 4262811
       , p_gl_dates_code                => p_gl_dates_code             -- 4262811
       , p_proration_code               => p_proration_code            -- 4262811
       --
       , p_budgetary_control_flag        => p_budgetary_control_flag   -- 4458381 Public Sector Enh
       , p_encumbrance_type_id           => p_encumbrance_type_id      -- 4458381 Public Sector Enh
       --
       , p_array_alt_source_index        => p_array_alt_source_index
       --
       , p_array_acct_attr               => l_array_acct_attr              -- 4262811
       , p_array_acct_attr_source_idx    => l_array_acct_attr_source_idx   -- 4262811
       , p_rec_aad_objects               => p_rec_aad_objects
       --
       , p_rec_sources                   => p_rec_sources
       --
       , p_IsCompiled                    => p_IsCompiled
                     )
                   );

l_parameters := xla_cmp_source_pkg.GenerateParameters(
              p_array_source_index    => p_array_alt_source_index
            , p_rec_sources           => p_rec_sources
            ) ;
 --
IF l_parameters IS NULL THEN
 l_alt := xla_cmp_string_pkg.replace_token(l_alt, '$parameters$' ,' ');  -- 4417664
ELSE
 l_alt := xla_cmp_string_pkg.replace_token(l_alt, '$parameters$'   ,l_parameters );
END IF;
--
-- cache JLT in AAD object cache
--
l_ObjectIndex := xla_cmp_source_pkg.CacheAADObject (
    p_object                      => xla_cmp_source_pkg.C_ALT
  , p_object_code                 => p_accounting_line_code
  , p_object_type_code            => p_accounting_line_type_code
  , p_application_id              => p_application_id
  , p_event_class_code            => p_event_class_code
  , p_event_type_code             => p_event_type_code
  , p_line_definition_owner_code  => p_line_definition_owner_code
  , p_line_definition_code        => p_line_definition_code
  , p_array_source_index          => p_array_alt_source_index
  , p_rec_aad_objects             => p_rec_aad_objects
);
--
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$alt_hash_id$'                ,TO_CHAR(l_ObjectIndex));
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$alt_code$'                   ,p_accounting_line_code);
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$alt_type_code$'              ,p_accounting_line_type_code);
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$alt_appl_id$'                ,TO_CHAR(p_application_id));
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$amb_context_code$'           ,nvl(p_amb_context_code,' '));
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$entity_code$'                ,nvl(p_entity_code, ' '));
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$event_class_code$'           ,nvl(p_event_class_code,' '));
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$event_type_code$'            ,nvl(p_event_type_code,' '));
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$line_definition_owner_code$' ,nvl(p_line_definition_owner_code,' '));
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$line_definition_code$'       ,nvl(p_line_definition_code,' '));
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$balance_type_code$'          ,nvl(p_acct_entry_type_code,' '));
-- 4219869 Business Flow
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$bflow_method_code$'          ,p_bflow_method_code);
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$bflow_class_code$'           ,p_bflow_class_code);
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$inherit_desc_flag$'          ,p_inherit_desc_flag);
-- 4458381 Public Sector Enh
l_alt := xla_cmp_string_pkg.replace_token(l_alt ,'$budgetary_control_flag$'     ,p_budgetary_control_flag);
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'END of GenerateDefAcctLineType'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
RETURN l_alt;
--
EXCEPTION
   WHEN VALUE_ERROR THEN
       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        xla_exceptions_pkg.raise_message
                                           ('XLA'
                                           ,'XLA_CMP_COMPILER_ERROR'
                                           ,'PROCEDURE'
                                           ,'xla_cmp_acct_line_type_pkg.GenerateDefAcctLineType'
                                           ,'ERROR'
                                           , sqlerrm
                                   );

   WHEN xla_exceptions_pkg.application_exception   THEN
        p_IsCompiled := FALSE;
        RETURN NULL;
   WHEN OTHERS THEN
      p_IsCompiled := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GenerateDefAcctLineType');
END GenerateDefAcctLineType;


/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|     GenerateOneAcctLineType                              |
|                                                          |
|  Generates AcctLineType_xxx() procedure and returns the  |
|  result in DBMS_SQL.VARCHAR2S datatype                   |
|                                                          |
+---------------------------------------------------------*/

FUNCTION GenerateOneAcctLineType(
  p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_entity_code                  IN VARCHAR2
, p_event_class_code             IN VARCHAR2
, p_event_type_code              IN VARCHAR2
, p_line_definition_owner_code   IN VARCHAR2
, p_line_definition_code         IN VARCHAR2
--
, p_accounting_line_code         IN VARCHAR2
, p_accounting_line_type_code    IN VARCHAR2
, p_accounting_line_name         IN VARCHAR2
 --
, p_description_type_code        IN VARCHAR2
, p_description_code             IN VARCHAR2
--
, p_acct_entry_type_code         IN VARCHAR2
, p_natural_side_code            IN VARCHAR2
, p_transfer_mode_code           IN VARCHAR2
, p_switch_side_flag             IN VARCHAR2
, p_merge_duplicate_code         IN VARCHAR2
, p_accounting_class_code        IN VARCHAR2
, p_rounding_class_code          IN VARCHAR2
, p_gain_or_loss_flag            IN VARCHAR2
--
, p_bflow_method_code            IN VARCHAR2  -- 4219869 Business Flow
, p_bflow_class_code             IN VARCHAR2  -- 4219869 Business Flow
, p_inherit_desc_flag            IN VARCHAR2  -- 4219869 Business Flow
--
, p_num_je_code                  IN VARCHAR2  -- 4262811
, p_gl_dates_code                IN VARCHAR2  -- 4262811
, p_proration_code               IN VARCHAR2  -- 4262811
, p_mpa_header_desc_type_code    IN VARCHAR2  -- 4262811
, p_mpa_header_desc_code         IN VARCHAR2  -- 4262811
--
, p_budgetary_control_flag       IN VARCHAR2  -- 4458381 Public Sector Enh
, p_encumbrance_type_id          IN INTEGER   -- 4458381 Public Sector Enh
--
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
--
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
--
, p_IsCompiled                   OUT NOCOPY BOOLEAN
)
RETURN DBMS_SQL.VARCHAR2S
IS
--

l_alt                            CLOB;
l_alt_code                       VARCHAR2(30);
l_IsCompiled                     BOOLEAN;
l_array_alt_source_index         xla_cmp_source_pkg.t_array_ByInt;
l_array_null_alt_source_idx      xla_cmp_source_pkg.t_array_ByInt;
--
l_array_alt                      DBMS_SQL.VARCHAR2S;
l_log_module                     VARCHAR2(240);
--
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateOneAcctLineType';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateOneAcctLineType'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);

END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace
         (p_msg      => 'application_id = '       ||p_application_id  ||
                        ' - amb_context_code = '    ||p_amb_context_code ||
                        ' - p_entity_code = '       ||p_entity_code ||
                        ' - event_class_code = '    ||p_event_class_code ||
                        ' - event_type_code = '     ||p_event_type_code  ||
                        ' - line_definition_code = '||p_line_definition_code ||
                                               '-'||p_line_definition_owner_code ||
                        ' - accounting_line_code = '||p_accounting_line_code ||
                                               '-'||p_accounting_line_type_code
         ,p_level    => C_LEVEL_STATEMENT
         ,p_module   => l_log_module);
END IF;

l_IsCompiled  := TRUE;
l_alt         :=NULL;

l_alt := GenerateDefAcctLineType(
                      p_application_id                => p_application_id
                    , p_amb_context_code              => p_amb_context_code
                    , p_entity_code                   => p_entity_code
                    , p_event_class_code              => p_event_class_code
                    , p_event_type_code               => p_event_type_code
                    , p_line_definition_code          => p_line_definition_code
                    , p_line_definition_owner_code    => p_line_definition_owner_code
                    --
                    , p_accounting_line_code          => p_accounting_line_code
                    , p_accounting_line_type_code     => p_accounting_line_type_code
                    , p_accounting_line_name          => p_accounting_line_name
                    --
                    , p_description_type_code         => p_description_type_code
                    , p_description_code              => p_description_code
                    --
                    , p_acct_entry_type_code          => p_acct_entry_type_code
                    , p_natural_side_code             => p_natural_side_code
                    , p_transfer_mode_code            => p_transfer_mode_code
                    , p_switch_side_flag              => p_switch_side_flag
                    , p_merge_duplicate_code          => p_merge_duplicate_code
                    , p_accounting_class_code         => p_accounting_class_code
                    , p_rounding_class_code           => p_rounding_class_code
                    , p_gain_or_loss_flag             => p_gain_or_loss_flag
                    --
                    , p_bflow_method_code             => p_bflow_method_code        -- 4219869 Business Flow
                    , p_bflow_class_code              => p_bflow_class_code         -- 4219869 Business Flow
                    , p_inherit_desc_flag             => p_inherit_desc_flag        -- 4219869 Business Flow
                    --
                    , p_num_je_code                   => p_num_je_code                -- 4262811
                    , p_gl_dates_code                 => p_gl_dates_code              -- 4262811
                    , p_proration_code                => p_proration_code             -- 4262811
                    , p_mpa_header_desc_type_code     => p_mpa_header_desc_type_code  -- 4262811
                    , p_mpa_header_desc_code          => p_mpa_header_desc_code       -- 4262811
                    --
                    , p_budgetary_control_flag        => p_budgetary_control_flag     -- 4458381 Public Sector Enh
                    , p_encumbrance_type_id           => p_encumbrance_type_id        -- 4458381 Public Sector Enh
                    --
                    , p_array_alt_source_index        => l_array_alt_source_index
                    --
                    , p_rec_aad_objects               =>  p_rec_aad_objects
                    --
                    , p_rec_sources                   =>  p_rec_sources
                    --
                    , p_IsCompiled                    =>  l_IsCompiled
);

l_alt     := xla_cmp_string_pkg.replace_token(l_alt,'$package_name$',g_package_name);  -- 4417664

xla_cmp_string_pkg.CreateString(
                      p_package_text  => l_alt
                     ,p_array_string  => l_array_alt
                     );

p_IsCompiled                     := l_IsCompiled ;
l_array_alt_source_index         := l_array_null_alt_source_idx;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace
       (p_msg      => 'return value. = '||
            CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);

  trace
       (p_msg      => 'END of GenerateOneAcctLineType'
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
END IF;

RETURN l_array_alt;
EXCEPTION
   WHEN VALUE_ERROR THEN
       IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        p_IsCompiled  := FALSE;
        RETURN xla_cmp_string_pkg.g_null_varchar2s;
   WHEN xla_exceptions_pkg.application_exception   THEN
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        p_IsCompiled  := FALSE;
        RETURN xla_cmp_string_pkg.g_null_varchar2s;
   WHEN OTHERS THEN
      p_IsCompiled  := FALSE;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GenerateOneAcctLineType');
END GenerateOneAcctLineType;

/*---------------------------------------------------------+
|                                                          |
|  Private Function                                        |
|                                                          |
|   GenerateAcctLineTypeProcs                              |
|                                                          |
|  Drives the generation of AcctLineType_xxx() procedures  |
|                                                          |
+---------------------------------------------------------*/

FUNCTION GenerateAcctLineTypeProcs(
  p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
--
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
--
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
--
, p_IsCompiled                   IN OUT NOCOPY BOOLEAN
)
RETURN DBMS_SQL.VARCHAR2S
IS
--
--
CURSOR alt_cur
IS
SELECT  DISTINCT
        xldj.accounting_line_code
      , xldj.accounting_line_type_code
      --
      , REPLACE(xaltt.name , '''','''''')
      --
      , xldj.description_type_code
      , xldj.description_code
      , xldj.inherit_desc_flag       -- 4219869 Business Flow
      --
      , xaltb.accounting_entry_type_code
      , xaltb.natural_side_code
      , xaltb.gl_transfer_mode_code
      , xaltb.switch_side_flag
      , xaltb.merge_duplicate_code
      --
      , xaltb.accounting_class_code
      , xaltb.rounding_class_code
      , xaltb.gain_or_loss_flag
      --
      , xaltb.business_method_code   -- 4219869 Business Flow
      , xaltb.business_class_code    -- 4219869 Business Flow
      --
      , xpah.entity_code
      , xpah.event_class_code
      , xpah.event_type_code
      --
      , xald.line_definition_code
      , xald.line_definition_owner_code
      --
      , xldj.mpa_num_je_code            -- 4262811
      , xldj.mpa_gl_dates_code          -- 4262811
      , xldj.mpa_proration_code         -- 4262811
      , xldj.mpa_header_desc_type_code  -- 4262811
      , xldj.mpa_header_desc_code       -- 4262811
      --
      , xldt.budgetary_control_flag     -- 4458381 Public Sector Enh
      , xaltb.encumbrance_type_id       -- 4458381 Public Sector Enh
  FROM  xla_aad_line_defn_assgns  xald
      , xla_line_defn_jlt_assgns  xldj
      , xla_prod_acct_headers     xpah
      , xla_acct_line_types_b     xaltb
      , xla_acct_line_types_tl    xaltt
      , xla_line_definitions_b    xldt
      --
 WHERE  xpah.application_id              = p_application_id
   AND  xpah.product_rule_type_code      = p_product_rule_type_code
   AND  xpah.product_rule_code           = p_product_rule_code
   AND  xpah.amb_context_code            = p_amb_context_code
   AND  xpah.accounting_required_flag    = 'Y'
   AND  xpah.validation_status_code      = 'R'
   --
   AND  xald.application_id              = xpah.application_id
   AND  xald.amb_context_code            = xpah.amb_context_code
   AND  xald.product_rule_type_code      = xpah.product_rule_type_code
   AND  xald.product_rule_code           = xpah.product_rule_code
   AND  xald.event_class_code            = xpah.event_class_code
   AND  xald.event_type_code             = xpah.event_type_code
   --
   AND  xldj.application_id              = xald.application_id
   AND  xldj.amb_context_code            = xald.amb_context_code
   AND  xldj.event_class_code            = xald.event_class_code
   AND  xldj.event_type_code             = xald.event_type_code
   AND  xldj.line_definition_owner_code  = xald.line_definition_owner_code
   AND  xldj.line_definition_code        = xald.line_definition_code
   AND  xldj.active_flag                 = 'Y'
   --
   AND  xldj.application_id              = xaltb.application_id
   AND  xldj.amb_context_code            = xaltb.amb_context_code
   AND  xldj.accounting_line_code        = xaltb.accounting_line_code
   AND  xldj.accounting_line_type_code   = xaltb.accounting_line_type_code
   AND  xldj.event_class_code            = xaltb.event_class_code
   AND  xaltb.enabled_flag               = 'Y'
   --
   AND  xaltb.application_id             = xaltt.application_id           (+)
   AND  xaltb.amb_context_code           = xaltt.amb_context_code         (+)
   AND  xaltb.entity_code                = xaltt.entity_code              (+)
   AND  xaltb.event_class_code           = xaltt.event_class_code         (+)
   AND  xaltb.accounting_line_code       = xaltt.accounting_line_code     (+)
   AND  xaltb.accounting_line_type_code  = xaltt.accounting_line_type_code(+)
   AND  xaltt.language               (+) = USERENV('LANG')
   --
   AND  xldt.application_id              = xald.application_id
   AND  xldt.amb_context_code            = xald.amb_context_code
   AND  xldt.event_class_code            = xald.event_class_code
   AND  xldt.event_type_code             = xald.event_type_code
   AND  xldt.line_definition_owner_code  = xald.line_definition_owner_code
   AND  xldt.line_definition_code        = xald.line_definition_code
   AND  xldt.budgetary_control_flag      = XLA_CMP_PAD_PKG.g_bc_pkg_flag
   --
 ORDER BY xldj.accounting_line_type_code, xldj.accounting_line_code
;
--
--
l_AcctlineTypes               DBMS_SQL.VARCHAR2S;
l_array_alt                   DBMS_SQL.VARCHAR2S;
--
l_array_alt_code              xla_cmp_source_pkg.t_array_VL30;
l_array_alt_type_code         xla_cmp_source_pkg.t_array_VL1;
l_array_alt_name              xla_cmp_source_pkg.t_array_VL80;
--
l_array_desc_code             xla_cmp_source_pkg.t_array_VL30;
l_array_desc_type_code        xla_cmp_source_pkg.t_array_VL1;
--
l_array_entry_type_code       xla_cmp_source_pkg.t_array_VL1;
l_array_natural_side_code     xla_cmp_source_pkg.t_array_VL1;
l_array_transfer_mode         xla_cmp_source_pkg.t_array_VL1;
l_array_switch_side_flag      xla_cmp_source_pkg.t_array_VL1;
l_array_merge_code            xla_cmp_source_pkg.t_array_VL1;
--
l_array_acct_class_code       xla_cmp_source_pkg.t_array_VL30;
l_array_rounding_class_code   xla_cmp_source_pkg.t_array_VL30;
l_array_gain_or_loss_flag     xla_cmp_source_pkg.t_array_VL1;
--
l_array_entity_code           xla_cmp_source_pkg.t_array_VL30;
l_array_class_code            xla_cmp_source_pkg.t_array_VL30;
l_array_event_type            xla_cmp_source_pkg.t_array_VL30;
--
l_array_jld_owner_code        xla_cmp_source_pkg.t_array_VL1;
l_array_jld_code              xla_cmp_source_pkg.t_array_VL30;
--
l_array_bflow_method_code     xla_cmp_source_pkg.t_array_VL30;  -- 4219869 Business Flow
l_array_bflow_class_code      xla_cmp_source_pkg.t_array_VL30;  -- 4219869 Business Flow
l_array_inherit_desc_flag     xla_cmp_source_pkg.t_array_VL1;   -- 4219869 Business Flow
--
l_array_mpa_num_je_code    xla_cmp_source_pkg.t_array_VL30;    -- 4262811
l_array_mpa_gl_dates_code  xla_cmp_source_pkg.t_array_VL30;    -- 4262811
l_array_mpa_proration_code xla_cmp_source_pkg.t_array_VL30;    -- 4262811
l_array_mpa_desc_type_code xla_cmp_source_pkg.t_array_VL1;     -- 4262811
l_array_mpa_desc_code      xla_cmp_source_pkg.t_array_VL30;    -- 4262811
--
l_array_budgetary_control_flag xla_cmp_source_pkg.t_array_VL1; -- 4458381 Public Sector Enh
l_array_encumbrance_type_id   xla_cmp_source_pkg.t_array_Int;  -- 4458381 Public Sector Enh
--
l_IsCompiled                  BOOLEAN;
l_number                      NUMBER;
--
l_log_module                  VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateAcctLineTypeProcs';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateAcctLineTypeProcs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;

IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',product_rule_type_code = '||p_product_rule_type_code||
                      ',product_rule_code = '||p_product_rule_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
END IF;

OPEN  alt_cur;

FETCH alt_cur BULK COLLECT INTO   l_array_alt_code
                                , l_array_alt_type_code
                                , l_array_alt_name
                                , l_array_desc_type_code
                                , l_array_desc_code
                                , l_array_inherit_desc_flag       -- 4219869 Business Flow
                                , l_array_entry_type_code
                                , l_array_natural_side_code
                                , l_array_transfer_mode
                                , l_array_switch_side_flag
                                , l_array_merge_code
                                , l_array_acct_class_code
                                , l_array_rounding_class_code
                                , l_array_gain_or_loss_flag
                                , l_array_bflow_method_code       -- 4219869 Business Flow
                                , l_array_bflow_class_code        -- 4219869 Business Flow
                                , l_array_entity_code
                                , l_array_class_code
                                , l_array_event_type
                                , l_array_jld_code
                                , l_array_jld_owner_code
                                , l_array_mpa_num_je_code        -- 4262811
                                , l_array_mpa_gl_dates_code      -- 4262811
                                , l_array_mpa_proration_code     -- 4262811
                                , l_array_mpa_desc_type_code     -- 4262811
                                , l_array_mpa_desc_code          -- 4262811
                                , l_array_budgetary_control_flag -- 4458381 Public Sector Enh
                                , l_array_encumbrance_type_id    -- 4458381 Public Sector Enh
                                ;
CLOSE alt_cur;

l_AcctlineTypes   := xla_cmp_string_pkg.g_null_varchar2s;


IF (C_LEVEL_STATEMENT >= g_log_level) THEN
   trace(p_msg    => '# ALT = '||l_array_alt_code.COUNT
        ,p_level  => C_LEVEL_STATEMENT
        ,p_module => l_log_module);
END IF;

IF l_array_alt_code.COUNT > 0 THEN

   p_IsCompiled   := TRUE;

   FOR Idx In l_array_alt_code.FIRST .. l_array_alt_code.LAST LOOP
    --
    IF l_array_alt_code.EXISTS(Idx) THEN

       IF (C_LEVEL_STATEMENT >= g_log_level) THEN
          trace(p_msg    => 'event_type_code = '   ||l_array_event_type(Idx)        ||
                            ',journal_line_type = '||l_array_alt_code(Idx)          ||
                                                '-'||l_array_alt_type_code(Idx)     ||
                            ',line_definition = '  ||l_array_jld_code(Idx)          ||
                                                '-'||l_array_jld_owner_code(Idx)    ||  -- 4219869 Business Flow
                            ',inherit descrip = '  ||l_array_inherit_desc_flag(Idx) ||  -- 4219869 Business Flow
                            ',bflow method    = '  ||l_array_bflow_method_code(Idx) ||  -- 4219869 Business Flow
                            ',bflow class     = '  ||l_array_bflow_class_code(Idx)      -- 4219869 Business Flow
               ,p_level  => C_LEVEL_STATEMENT
               ,p_module => l_log_module);

       END IF;
       l_array_alt := GenerateOneAcctLineType(
                      p_application_id              => p_application_id
                    , p_amb_context_code            => p_amb_context_code
                    , p_entity_code                 => l_array_entity_code(Idx)
                    , p_event_class_code            => l_array_class_code(Idx)
                    , p_event_type_code             => l_array_event_type(Idx)
                    , p_line_definition_owner_code  => l_array_jld_owner_code(Idx)
                    , p_line_definition_code        => l_array_jld_code(Idx)
                    --
                    , p_accounting_line_code        => l_array_alt_code(Idx)
                    , p_accounting_line_type_code   => l_array_alt_type_code(Idx)
                    , p_accounting_line_name        => l_array_alt_name(Idx)
                    --
                    , p_description_type_code       => l_array_desc_type_code(Idx)
                    , p_description_code            => l_array_desc_code(Idx)
                    , p_acct_entry_type_code        => l_array_entry_type_code(Idx)
                    , p_natural_side_code           => l_array_natural_side_code(Idx)
                    , p_transfer_mode_code          => l_array_transfer_mode(Idx)
                    , p_switch_side_flag            => l_array_switch_side_flag(Idx)
                    , p_merge_duplicate_code        => l_array_merge_code(Idx)
                    , p_accounting_class_code       => l_array_acct_class_code(Idx)
                    , p_rounding_class_code         => l_array_rounding_class_code(Idx)
                    , p_gain_or_loss_flag           => l_array_gain_or_loss_flag(Idx)
                    --
                    , p_bflow_method_code           => l_array_bflow_method_code(Idx)  -- 4219869 Business Flow
                    , p_bflow_class_code            => l_array_bflow_class_code(Idx)   -- 4219869 Business Flow
                    , p_inherit_desc_flag           => l_array_inherit_desc_flag(Idx)  -- 4219869 Business Flow
                    --
                    , p_num_je_code                 => l_array_mpa_num_je_code(Idx)    -- 4262811
                    , p_gl_dates_code               => l_array_mpa_gl_dates_code(Idx)  -- 4262811
                    , p_proration_code              => l_array_mpa_proration_code(Idx) -- 4262811
                    , p_mpa_header_desc_type_code   => l_array_mpa_desc_type_code(Idx) -- 4262811
                    , p_mpa_header_desc_code        => l_array_mpa_desc_code(Idx)      -- 4262811
                    --
                    , p_budgetary_control_flag      => l_array_budgetary_control_flag(Idx) -- 4458381
                    , p_encumbrance_type_id         => l_array_encumbrance_type_id(Idx)    -- 4458381
                    --
                    , p_rec_aad_objects             =>  p_rec_aad_objects
                    --
                    , p_rec_sources                 =>  p_rec_sources
                    --
                    , p_IsCompiled                  =>  l_IsCompiled
                   );

         l_AcctlineTypes := xla_cmp_string_pkg.ConcatTwoStrings (
                                 p_array_string_1    => l_AcctlineTypes
                                ,p_array_string_2    => l_array_alt
                          );

      END IF;

      p_IsCompiled := p_IsCompiled AND l_IsCompiled;

  END LOOP;

END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
       (p_msg      => 'return value. = '||
            CASE p_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
       ,p_level    => C_LEVEL_PROCEDURE
       ,p_module   => l_log_module);
      trace
         (p_msg      => 'END of GenerateAcctLineTypeProcs'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
RETURN l_AcctlineTypes;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception   THEN
        p_IsCompiled    := FALSE;
        IF alt_cur%ISOPEN THEN CLOSE alt_cur; END IF;
        IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
        RETURN xla_cmp_string_pkg.g_null_varchar2s;
   WHEN OTHERS THEN
      p_IsCompiled    := FALSE;
      IF alt_cur%ISOPEN THEN CLOSE alt_cur; END IF;
      xla_exceptions_pkg.raise_message
         (p_location => 'xla_cmp_acct_line_type_pkg.GenerateAcctLineTypeProcs');
END GenerateAcctLineTypeProcs;


/*------------------------------------------------------------+
|                                                             |
|  Public Function                                            |
|                                                             |
|       GenerateAcctLineType                                  |
|                                                             |
|  Generates the AcctLineType_XXX() functions from the AMB    |
|  Journal line types assigned to the AAD.                    |
|  It returns TRUE if generation succeeds, FALSE otherwise    |
|                                                             |
+------------------------------------------------------------*/

FUNCTION GenerateAcctLineType(
  p_product_rule_code            IN VARCHAR2
, p_product_rule_type_code       IN VARCHAR2
, p_application_id               IN NUMBER
, p_amb_context_code             IN VARCHAR2
, p_package_name                 IN VARCHAR2
, p_rec_aad_objects              IN OUT NOCOPY xla_cmp_source_pkg.t_rec_aad_objects
, p_rec_sources                  IN OUT NOCOPY xla_cmp_source_pkg.t_rec_sources
, p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S
)
RETURN BOOLEAN
IS
l_AcctLineTypes    DBMS_SQL.VARCHAR2S;
l_IsCompiled       BOOLEAN;
l_log_module       VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.GenerateAcctLineType';
END IF;
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace
         (p_msg      => 'BEGIN of GenerateAcctLineType'
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
END IF;
--
-- Init global variables
--
l_IsCompiled     := TRUE;
l_AcctLineTypes  := xla_cmp_string_pkg.g_null_varchar2s;
--
g_package_name   := p_package_name;
--
l_AcctLineTypes  := GenerateAcctLineTypeProcs(
   p_product_rule_code            =>  p_product_rule_code
 , p_product_rule_type_code       =>  p_product_rule_type_code
 , p_application_id               =>  p_application_id
 , p_amb_context_code             =>  p_amb_context_code
 , p_rec_aad_objects              =>  p_rec_aad_objects
 , p_rec_sources                  =>  p_rec_sources
 , p_IsCompiled                   =>  l_IsCompiled
);
--
--
p_package_body := l_AcctLineTypes;
g_package_name := NULL;
--
IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace
         (p_msg      => 'return value (l_IsCompiled) = '||
          CASE l_IsCompiled WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END
         ,p_level    => C_LEVEL_PROCEDURE
         ,p_module   => l_log_module);
   trace
      (p_msg      => 'END of GenerateAcctLineType'
      ,p_level    => C_LEVEL_PROCEDURE
      ,p_module   => l_log_module);
END IF;
RETURN l_IsCompiled;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception   THEN
   IF (C_LEVEL_EXCEPTION >= g_log_level) THEN
            trace
               (p_msg      => 'ERROR: XLA_CMP_COMPILER_ERROR = '||sqlerrm
               ,p_level    => C_LEVEL_EXCEPTION
               ,p_module   => l_log_module);
        END IF;
   RETURN FALSE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location => 'xla_cmp_acct_line_type_pkg.GenerateAcctLineType');
END GenerateAcctLineType;
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

END xla_cmp_acct_line_type_pkg; --

/
